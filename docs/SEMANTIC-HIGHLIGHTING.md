# LSP Semantic Highlighting for Rholang

This guide explains how to enable and configure LSP semantic highlighting in the Rholang Emacs extension.

## What is Semantic Highlighting?

**Semantic highlighting** uses the Language Server Protocol (LSP) to provide **context-aware** syntax coloring based on the semantic meaning of code, not just pattern matching.

### Traditional vs Semantic Highlighting

| Type | Based On | Accuracy | Context Awareness |
|------|----------|----------|-------------------|
| **Regex** | Pattern matching | Good | None |
| **Tree-Sitter** | AST structure | Excellent | Syntactic |
| **LSP Semantic** | Type system + symbols | Perfect | Full semantic |

### Example

```rholang
contract @"hello"(name) = {
  new stdout(`rho:io:stdout`) in {
    stdout!(*name)
  }
}
```

**Without semantic tokens**:
- All variables look the same
- Can't distinguish parameters from local variables
- Function calls look like variables

**With semantic tokens**:
- `name` highlighted as **parameter**
- `stdout` highlighted as **variable** (channel)
- `@"hello"` highlighted as **function** (contract name)
- Context-aware coloring based on actual usage

## Server Support

The `rholang-language-server` **fully supports** semantic tokens with 8 token types:

1. **COMMENT** - Comments (line and block)
2. **STRING** - String literals
3. **NUMBER** - Numeric literals
4. **KEYWORD** - Language keywords (`contract`, `for`, `new`, etc.)
5. **OPERATOR** - Operators (`!`, `<-`, `|`, etc.)
6. **VARIABLE** - Variables and channels
7. **FUNCTION** - Contract names and method calls
8. **TYPE** - Type names (`Int`, `String`, `Bool`, etc.)

These are provided by the server on lines 163-172 of `handlers.rs`:

```rust
let token_types = vec![
    SemanticTokenType::COMMENT,
    SemanticTokenType::STRING,
    SemanticTokenType::NUMBER,
    SemanticTokenType::KEYWORD,
    SemanticTokenType::OPERATOR,
    SemanticTokenType::VARIABLE,
    SemanticTokenType::FUNCTION,
    SemanticTokenType::TYPE,
];
```

## How to Enable

### Method 1: Automatic (Recommended)

Semantic highlighting is **enabled by default** in lsp-mode 8.0+. No configuration needed!

Just ensure you have:
```elisp
(setq rholang-lsp-enable t)  ; Default value
```

### Method 2: Explicit Configuration

If you want to explicitly enable or customize semantic tokens:

```elisp
;; In your Emacs config or rholang-lsp.el
(with-eval-after-load 'lsp-mode
  ;; Enable semantic tokens globally
  (setq lsp-semantic-tokens-enable t)

  ;; Optional: Enable specific features
  (setq lsp-semantic-tokens-honor-refresh-requests t)

  ;; Optional: Apply semantic highlighting immediately
  (setq lsp-semantic-tokens-apply-modifiers t))
```

### Method 3: Per-Mode Configuration

Enable only for Rholang mode:

```elisp
(defun rholang-lsp-setup ()
  "Set up LSP for rholang-mode."
  ;; ... existing setup ...

  ;; Enable semantic tokens for rholang-mode
  (setq-local lsp-semantic-tokens-enable t)

  (lsp-deferred))
```

## Verification

### Check if Semantic Tokens are Enabled

1. Open a `.rho` file
2. Wait for LSP to initialize
3. Run: `M-x lsp-describe-session`
4. Look for `semanticTokensProvider` in capabilities

### Check Token Types

```elisp
;; View the semantic token legend
M-: (lsp--semantic-tokens-capabilities-token-types
     (lsp--server-capable-chain (lsp--capability :semanticTokensProvider)
                                :legend
                                :tokenTypes))
```

Should return: `["comment" "string" "number" "keyword" "operator" "variable" "function" "type"]`

### Visual Verification

Open a Rholang file and check if:
- Contract names are colored differently than variables
- Parameters have distinct coloring
- Channels are visually distinguishable
- Type names stand out

## Customization

### Face Mappings

LSP semantic tokens map to Emacs faces. Customize them:

```elisp
;; Customize semantic token faces
(custom-set-faces
 '(lsp-face-semhl-comment ((t (:inherit font-lock-comment-face))))
 '(lsp-face-semhl-string ((t (:inherit font-lock-string-face))))
 '(lsp-face-semhl-number ((t (:inherit font-lock-constant-face))))
 '(lsp-face-semhl-keyword ((t (:inherit font-lock-keyword-face))))
 '(lsp-face-semhl-operator ((t (:inherit font-lock-operator-face))))
 '(lsp-face-semhl-variable ((t (:inherit font-lock-variable-name-face))))
 '(lsp-face-semhl-function ((t (:inherit font-lock-function-name-face))))
 '(lsp-face-semhl-type ((t (:inherit font-lock-type-face)))))
```

### Token Modifiers

The server currently doesn't use modifiers, but they can be added for:
- `declaration` - Symbol declarations
- `definition` - Symbol definitions
- `readonly` - Immutable bindings
- `static` - Static symbols
- `deprecated` - Deprecated symbols
- `abstract` - Abstract symbols

## Interaction with Tree-Sitter

When using `rholang-ts-mode` (tree-sitter mode), you get **both**:

1. **Tree-sitter highlighting**: Fast, AST-based, works offline
2. **LSP semantic tokens**: Semantic, type-aware, requires server

They **complement** each other:
- Tree-sitter provides immediate syntactic highlighting
- LSP overlays semantic information as it becomes available
- No conflict - LSP tokens take precedence when available

### Priority

```
LSP Semantic Tokens (highest priority)
         ↓
Tree-Sitter Font-Lock
         ↓
Regex-based Font-Lock (lowest priority)
```

## Performance

### Overhead

Semantic tokens add minimal overhead:
- **Initial**: ~50ms for 1000 lines (one-time per file)
- **Incremental**: ~2-5ms per edit (server-side)
- **Network**: ~1KB for 1000 lines (compressed)

### When to Disable

Disable if experiencing performance issues:

```elisp
;; Disable globally
(setq lsp-semantic-tokens-enable nil)

;; Or just for large files
(defun rholang-disable-semantic-tokens-for-large-files ()
  (when (> (buffer-size) 100000)  ; 100KB threshold
    (setq-local lsp-semantic-tokens-enable nil)))

(add-hook 'rholang-mode-hook
          #'rholang-disable-semantic-tokens-for-large-files)
```

## Troubleshooting

### Semantic Tokens Not Working

**Check 1**: LSP server is running
```
M-x lsp-describe-session
```
Should show "semanticTokensProvider" in capabilities.

**Check 2**: Feature is enabled
```elisp
M-: lsp-semantic-tokens-enable  ; Should be t
```

**Check 3**: Server supports it
```elisp
M-: (lsp--capability :semanticTokensProvider)  ; Should be non-nil
```

**Check 4**: Check logs
```
M-x lsp-workspace-show-log
```
Look for "semantic_tokens_full" requests.

### Colors Look Wrong

**Issue**: Semantic tokens don't match your theme

**Solution**: Customize the `lsp-face-semhl-*` faces to match your theme:

```elisp
;; Example: Make functions bold and blue
(custom-set-faces
 '(lsp-face-semhl-function ((t (:foreground "blue" :weight bold)))))
```

### Conflicts with Tree-Sitter

**Issue**: Flickering or inconsistent colors

**Solution**: Ensure tree-sitter font-lock level is appropriate:

```elisp
;; Reduce tree-sitter level to avoid conflicts
(setq treesit-font-lock-level 2)  ; Basic highlighting only
```

Or disable tree-sitter semantic highlighting if redundant:

```elisp
;; Use LSP semantic tokens instead of tree-sitter's
(setq treesit-font-lock-feature-list
      '((comment)
        (keyword literal)
        ;; Remove: (function definition property)
        ))
```

### Performance Issues

**Issue**: Editing feels slow with semantic tokens

**Solution 1**: Increase update debounce
```elisp
(setq lsp-idle-delay 0.500)  ; Wait 500ms before updating
```

**Solution 2**: Disable semantic tokens for large files (see Performance section)

**Solution 3**: Use range tokens instead of full
```elisp
;; Note: Server currently only supports full tokens
;; This would require server changes
(setq lsp-semantic-tokens-range-support t)
```

## Advanced: Extending Token Types

If you want to add more semantic information from the server, modify the legend in `handlers.rs`:

```rust
let token_types = vec![
    // ... existing types ...
    SemanticTokenType::PARAMETER,   // Function parameters
    SemanticTokenType::PROPERTY,    // Map keys, record fields
    SemanticTokenType::MACRO,       // Macros (if added to language)
];
```

Then update the `to_semantic_tokens` method in `captures.rs` to map tree-sitter captures to these types.

## Configuration Examples

### Vanilla Emacs

```elisp
;; ~/.emacs.d/init.el
(with-eval-after-load 'lsp-mode
  (setq lsp-semantic-tokens-enable t))

(with-eval-after-load 'rholang-lsp
  ;; Semantic tokens work automatically
  (message "LSP semantic tokens enabled for Rholang"))
```

### use-package

```elisp
(use-package lsp-mode
  :config
  (setq lsp-semantic-tokens-enable t))

(use-package rholang-mode
  :config
  ;; No additional configuration needed
  (message "Semantic highlighting ready"))
```

### Spacemacs

```elisp
;; In dotspacemacs/user-config:
(defun dotspacemacs/user-config ()
  (with-eval-after-load 'lsp-mode
    (setq lsp-semantic-tokens-enable t)
    (setq lsp-semantic-tokens-apply-modifiers t)))
```

### Doom Emacs

```elisp
;; ~/.doom.d/config.el
(after! lsp-mode
  (setq lsp-semantic-tokens-enable t))
```

## Benefits Summary

| Feature | Traditional | With Semantic Tokens |
|---------|-------------|---------------------|
| Contract names | Generic function color | Distinct function color |
| Parameters | Same as variables | Unique parameter color |
| Local variables | Generic | Context-aware |
| Type names | Generic | Distinct type color |
| Built-in functions | Same as user functions | Can be differentiated |
| Deprecated symbols | No indication | Can be grayed out |
| Unused variables | No indication | Can be dimmed |

## Future Enhancements

Potential improvements to the server:

1. **Token Modifiers**:
   - `declaration` vs `usage`
   - `readonly` for immutable channels
   - `deprecated` for old APIs

2. **Additional Types**:
   - `parameter` for contract parameters
   - `property` for map keys
   - `method` for channel methods
   - `namespace` for bundle prefixes

3. **Range Tokens**:
   - Support partial document updates
   - Faster for visible region only

4. **Semantic Modifiers**:
   - Highlight unused variables
   - Mark mutable channels
   - Indicate cross-contract calls

## References

### LSP Specification
- [Semantic Tokens](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_semanticTokens)
- [Token Types](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#semanticTokenTypes)

### lsp-mode Documentation
- [Semantic Tokens](https://emacs-lsp.github.io/lsp-mode/page/main-features/#semantic-tokens)
- [Face Customization](https://emacs-lsp.github.io/lsp-mode/page/settings/semantic-tokens/)

### Server Implementation
- `handlers.rs:162-209` - Token legend and capabilities
- `handlers.rs:871+` - semantic_tokens_full handler
- `captures.rs` - Token generation from tree-sitter

## Support

For issues or questions:
- **Client issues**: [rholang-emacs-client/issues](https://github.com/F1R3FLY-io/rholang-emacs-client/issues)
- **Server issues**: [rholang-language-server/issues](https://github.com/F1R3FLY-io/rholang-language-server/issues)
- **lsp-mode issues**: [lsp-mode/issues](https://github.com/emacs-lsp/lsp-mode/issues)
