# Spacemacs Configuration Guide for Rholang

This guide provides comprehensive configuration instructions for using the Rholang layer in Spacemacs.

## Quick Start

### 1. Install the Layer

Copy the layer to your Spacemacs layers directory:

```bash
mkdir -p ~/.spacemacs.d/layers/
cp -a layers/rholang/ ~/.spacemacs.d/layers/
```

### 2. Configure in .spacemacs

Add the `rholang` layer to your `dotspacemacs-configuration-layers`:

```elisp
(defun dotspacemacs/layers ()
  (setq-default
   dotspacemacs-configuration-layers
   '(
     ;; ... other layers ...
     rholang
     ;; ... other layers ...
     )))
```

### 3. Reload Configuration

Restart Spacemacs or reload: `SPC f e R`

## Complete Configuration Reference

### Basic Configuration (Recommended)

```elisp
(rholang :variables
         ;; LSP Configuration
         rholang-lsp-server-path "rholang-language-server"
         rholang-lsp-log-level "info"
         rholang-lsp-enable t

         ;; Use embedded Rust parser (default, faster, no dependencies)
         rholang-use-rnode nil

         ;; Editor preferences
         rholang-indent-size 2)
```

### Advanced Configuration (All Options)

```elisp
(rholang :variables
         ;; ===== LSP Configuration =====
         rholang-lsp-server-path "rholang-language-server"  ; Path to server executable
         rholang-lsp-log-level "info"                      ; Log level: error, warn, info, debug, trace
         rholang-lsp-enable t                              ; Enable LSP features

         ;; ===== Backend Configuration =====
         ;; Choose between embedded Rust parser or legacy RNode
         rholang-use-rnode nil                             ; nil = Embedded Rust (default)
                                                            ; t = Legacy RNode via gRPC

         ;; RNode gRPC settings (only used when rholang-use-rnode is t)
         rholang-grpc-host "localhost"                     ; RNode gRPC server host
         rholang-grpc-port 40402                           ; RNode gRPC server port

         ;; ===== Editor Configuration =====
         rholang-indent-size 2                             ; Indentation size (default: 2)

         ;; ===== Tree-Sitter Mode (Emacs 29.1+) =====
         rholang-use-tree-sitter nil                       ; nil = Traditional mode (default)
                                                            ; t = Tree-sitter mode (requires grammar)
         )
```

## Configuration Variables Explained

### LSP Configuration

#### `rholang-lsp-server-path`
- **Type**: String
- **Default**: `"rholang-language-server"`
- **Description**: Path to the rholang-language-server executable
- **Examples**:
  ```elisp
  rholang-lsp-server-path "rholang-language-server"           ; In PATH
  rholang-lsp-server-path "/usr/local/bin/rholang-language-server"  ; Absolute path
  rholang-lsp-server-path "~/bin/rholang-language-server"     ; Home directory
  ```

#### `rholang-lsp-log-level`
- **Type**: String (choice)
- **Default**: `"info"`
- **Options**: `"error"`, `"warn"`, `"info"`, `"debug"`, `"trace"`
- **Description**: Controls verbosity of LSP server logging
- **Usage**:
  - `"error"`: Only critical errors
  - `"warn"`: Errors and warnings
  - `"info"`: General information (recommended)
  - `"debug"`: Detailed debugging information
  - `"trace"`: Very verbose (for troubleshooting)

#### `rholang-lsp-enable`
- **Type**: Boolean
- **Default**: `t`
- **Description**: Enable or disable LSP support entirely
- **When to disable**: Only if you want pure syntax highlighting without LSP features

### Backend Configuration

#### `rholang-use-rnode`
- **Type**: Boolean
- **Default**: `nil`
- **Description**: Choose diagnostic backend
- **Options**:
  - `nil`: Use embedded Rust parser/interpreter (default, recommended)
    - ✅ Faster startup
    - ✅ No external dependencies
    - ✅ Easier to set up
  - `t`: Use legacy RNode via gRPC
    - Requires RNode instance running
    - Required for production RNode compatibility
    - Legacy option for existing workflows

#### `rholang-grpc-host`
- **Type**: String
- **Default**: `"localhost"`
- **Description**: RNode gRPC server hostname (only used when `rholang-use-rnode` is `t`)
- **Examples**:
  ```elisp
  rholang-grpc-host "localhost"      ; Local RNode
  rholang-grpc-host "192.168.1.100"  ; Remote RNode
  rholang-grpc-host "rnode.example.com"  ; Domain name
  ```

#### `rholang-grpc-port`
- **Type**: Integer
- **Default**: `40402`
- **Description**: RNode gRPC server port (only used when `rholang-use-rnode` is `t`)
- **Note**: RNode's default gRPC port is 40402

### Editor Configuration

#### `rholang-indent-size`
- **Type**: Integer
- **Default**: `2`
- **Description**: Number of spaces for each indentation level
- **Common values**:
  - `2`: Compact (default, recommended for Rholang)
  - `4`: Standard (common in C/Java)
  - `8`: Wide (Linux kernel style)

#### `rholang-use-tree-sitter`
- **Type**: Boolean
- **Default**: `nil`
- **Description**: Use tree-sitter mode instead of traditional mode
- **Requirements**:
  - Emacs 29.1 or later
  - Tree-sitter grammar installed
  - See [docs/tree-sitter/QUICK-START.md](tree-sitter/QUICK-START.md)
- **Benefits**:
  - More accurate syntax highlighting
  - Better indentation
  - AST-based navigation
  - Incremental parsing

## Common Configuration Scenarios

### Scenario 1: Basic Development (Recommended)

```elisp
(rholang :variables
         rholang-lsp-enable t
         rholang-use-rnode nil
         rholang-indent-size 2)
```

**Use when**: Learning Rholang, general development, no RNode required

### Scenario 2: With Tree-Sitter (Emacs 29.1+)

```elisp
(rholang :variables
         rholang-lsp-enable t
         rholang-use-rnode nil
         rholang-indent-size 2
         rholang-use-tree-sitter t)  ; Enable tree-sitter
```

**Requirements**: Install grammar first (see [tree-sitter guide](tree-sitter/QUICK-START.md))

### Scenario 3: Legacy RNode Integration

```elisp
(rholang :variables
         rholang-lsp-enable t
         rholang-use-rnode t          ; Use RNode
         rholang-grpc-host "localhost"
         rholang-grpc-port 40402
         rholang-indent-size 2)
```

**Requirements**: RNode instance running on localhost:40402

### Scenario 4: Remote RNode

```elisp
(rholang :variables
         rholang-lsp-enable t
         rholang-use-rnode t
         rholang-grpc-host "192.168.1.100"  ; Remote host
         rholang-grpc-port 40402
         rholang-indent-size 2)
```

**Requirements**: RNode accessible at 192.168.1.100:40402

### Scenario 5: Debug Mode

```elisp
(rholang :variables
         rholang-lsp-enable t
         rholang-lsp-log-level "debug"  ; Verbose logging
         rholang-use-rnode nil
         rholang-indent-size 2)
```

**Use when**: Troubleshooting LSP issues
**Check logs**: `M-x lsp-workspace-show-log`

## Optional User Configuration Enhancements

Add these to `dotspacemacs/user-config` for additional features:

### Enable LSP Semantic Tokens Globally

```elisp
(defun dotspacemacs/user-config ()
  ;; Enable semantic highlighting for all LSP modes
  (with-eval-after-load 'lsp-mode
    (setq lsp-semantic-tokens-enable t)
    (setq lsp-semantic-tokens-apply-modifiers t))
  )
```

### Customize LSP Performance

```elisp
(defun dotspacemacs/user-config ()
  ;; Optimize LSP for larger files
  (with-eval-after-load 'lsp-mode
    (setq lsp-idle-delay 0.5)              ; Debounce: wait 500ms before updating
    (setq read-process-output-max (* 1024 1024))  ; 1MB (default is 4KB)
    (setq lsp-log-io nil))                 ; Disable I/O logging (faster)
  )
```

### Customize Rholang Faces (Theme Integration)

```elisp
(defun dotspacemacs/user-config ()
  ;; Customize semantic token faces for your theme
  (with-eval-after-load 'lsp-mode
    (custom-set-faces
     '(lsp-face-semhl-function ((t (:foreground "#61afef" :weight bold))))
     '(lsp-face-semhl-variable ((t (:foreground "#e06c75"))))
     '(lsp-face-semhl-type ((t (:foreground "#c678dd"))))
     '(lsp-face-semhl-keyword ((t (:foreground "#c678dd" :weight bold))))))
  )
```

### Tree-Sitter Grammar Auto-Install

```elisp
(defun dotspacemacs/user-config ()
  ;; Auto-install tree-sitter grammar if missing
  (with-eval-after-load 'treesit
    (add-to-list 'treesit-language-source-alist
                 '(rholang "https://github.com/F1R3FLY-io/rholang-rs"
                           "main"
                           "rholang-tree-sitter"))

    ;; Auto-install if not present
    (unless (treesit-ready-p 'rholang)
      (message "Installing Rholang tree-sitter grammar...")
      (treesit-install-language-grammar 'rholang)))
  )
```

### File Association Overrides

```elisp
(defun dotspacemacs/user-config ()
  ;; Force tree-sitter mode for .rho files (if grammar installed)
  (when (treesit-ready-p 'rholang)
    (add-to-list 'auto-mode-alist '("\\.rho\\'" . rholang-ts-mode)))
  )
```

## Keybindings Reference

The Rholang layer provides **43 LSP keybindings** organized by category. See the main [README](../README.md#keybindings-spacemacs) for the complete list.

### Quick Reference

| Category | Prefix | Example |
|----------|--------|---------|
| Core | `SPC m` | `SPC m l` - Start LSP |
| Navigation | `SPC m g` | `SPC m g d` - Go to definition |
| Refactoring | `SPC m r` | `SPC m r r` - Rename symbol |
| Actions | `SPC m a` | `SPC m a a` - Execute code action |
| Help | `SPC m h` | `SPC m h h` - Describe at point |
| Formatting | `SPC m =` | `SPC m = =` - Format buffer |
| Workspace | `SPC m w` | `SPC m w r` - Restart workspace |
| Diagnostics | `SPC m D` | `SPC m D` - Run rholang-doctor |

## Troubleshooting

### LSP Not Starting

1. Check server is installed:
   ```bash
   which rholang-language-server
   ```

2. Run diagnostics:
   ```
   SPC m D  (or M-x rholang-doctor)
   ```

3. Check LSP session:
   ```
   M-x lsp-describe-session
   ```

4. View LSP logs:
   ```
   M-x lsp-workspace-show-log
   ```

### RNode Connection Issues

**Symptom**: Errors when `rholang-use-rnode` is `t`

**Solutions**:
1. Verify RNode is running:
   ```bash
   curl http://localhost:40402
   ```

2. Check gRPC port:
   ```bash
   netstat -tuln | grep 40402
   ```

3. Try embedded Rust instead:
   ```elisp
   rholang-use-rnode nil
   ```

### Tree-Sitter Mode Not Working

**Symptom**: `.rho` files still use traditional mode

**Solutions**:
1. Check Emacs version:
   ```
   M-x emacs-version  ; Must be 29.1+
   ```

2. Verify grammar installed:
   ```elisp
   M-: (treesit-ready-p 'rholang)  ; Should return t
   ```

3. Install grammar:
   See [docs/tree-sitter/QUICK-START.md](tree-sitter/QUICK-START.md)

### Indentation Issues

**Symptom**: Wrong indentation size

**Check current setting**:
```elisp
M-: rholang-indent-size
```

**Override per-file**:
```rholang
// -*- rholang-indent-size: 4; -*-
contract @"example"() = {
  // ... code with 4-space indent
}
```

## Advanced Configuration

### Per-Project Settings

Create `.dir-locals.el` in your project root:

```elisp
((rholang-mode . ((rholang-indent-size . 4)
                  (rholang-lsp-log-level . "debug"))))
```

### Conditional Backend Selection

```elisp
(defun dotspacemacs/user-config ()
  ;; Use RNode only for production directories
  (dir-locals-set-class-variables 'rholang-production
    '((rholang-mode . ((rholang-use-rnode . t)
                       (rholang-grpc-host . "production-rnode.example.com")))))

  (dir-locals-set-directory-class "/path/to/production/" 'rholang-production)
  )
```

### Custom Keybindings

```elisp
(defun dotspacemacs/user-config ()
  ;; Add custom Rholang keybindings
  (spacemacs/set-leader-keys-for-major-mode 'rholang-mode
    "xc" 'rholang-compile           ; Custom: SPC m x c
    "xr" 'rholang-run-contract      ; Custom: SPC m x r
    "xt" 'rholang-run-tests)        ; Custom: SPC m x t
  )
```

## Migration from Old Versions

### From v0.0.3 to v0.0.4

**Breaking Changes**:
- Keybindings reorganized (see [README](../README.md#keybindings-spacemacs))
- Old: `SPC m d` → New: `SPC m g d`
- Old: `SPC m r` → New: `SPC m g r`
- Old: `SPC m h` → New: `SPC m h h`

**Configuration Changes**:
- `rholang-rnode-host` → `rholang-grpc-host`
- `rholang-rnode-port` → `rholang-grpc-port`
- Default port changed: `40403` → `40402` (to match RNode default)

**Update your .spacemacs**:
```elisp
;; Old (v0.0.3)
(rholang :variables
         rholang-rnode-host "localhost"
         rholang-rnode-port 40403)

;; New (v0.0.4)
(rholang :variables
         rholang-use-rnode t               ; NEW: Explicit backend selection
         rholang-grpc-host "localhost"     ; RENAMED from rholang-rnode-host
         rholang-grpc-port 40402)          ; RENAMED from rholang-rnode-port, port changed
```

## Resources

### Documentation
- [Main README](../README.md)
- [Tree-Sitter Guide](tree-sitter/README.md)
- [Semantic Highlighting](SEMANTIC-HIGHLIGHTING.md)
- [Language Server Repo](https://github.com/F1R3FLY-io/rholang-language-server)

### Getting Help
- Run diagnostics: `SPC m D` or `M-x rholang-doctor`
- Check LSP: `M-x lsp-describe-session`
- View logs: `M-x lsp-workspace-show-log`
- Report issues: [GitHub Issues](https://github.com/F1R3FLY-io/rholang-emacs-client/issues)

## Complete Example Configuration

Here's a complete, production-ready `.spacemacs` configuration:

```elisp
(defun dotspacemacs/layers ()
  (setq-default
   dotspacemacs-configuration-layers
   '(
     ;; Enable LSP layer first
     lsp

     ;; Then Rholang with full configuration
     (rholang :variables
              ;; LSP Configuration
              rholang-lsp-server-path "rholang-language-server"
              rholang-lsp-log-level "info"
              rholang-lsp-enable t

              ;; Backend: Use embedded Rust (faster, no dependencies)
              rholang-use-rnode nil

              ;; Editor preferences
              rholang-indent-size 2

              ;; Tree-sitter (optional, Emacs 29.1+)
              rholang-use-tree-sitter nil)

     ;; Optional: Enable these for enhanced experience
     auto-completion
     syntax-checking
     treemacs
     )))

(defun dotspacemacs/user-config ()
  ;; LSP optimizations
  (with-eval-after-load 'lsp-mode
    ;; Enable semantic tokens
    (setq lsp-semantic-tokens-enable t)

    ;; Performance
    (setq lsp-idle-delay 0.5)
    (setq read-process-output-max (* 1024 1024))

    ;; Reduce file watching overhead
    (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.git\\'")
    (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\build\\'"))
  )
```
