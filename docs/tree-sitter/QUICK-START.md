# Tree-Sitter Mode Quick Start Guide

This guide will help you set up tree-sitter mode for Rholang in Emacs.

## Prerequisites Check

Before starting, verify you have the required tools:

### 1. Check Emacs Version

```elisp
M-x emacs-version
```

You need **Emacs 29.1 or later**.

### 2. Check Tree-Sitter Support

```elisp
M-: (treesit-available-p)
```

Should return `t`. If not, your Emacs was compiled without tree-sitter support.

### 3. Verify C Compiler (for manual compilation)

```bash
gcc --version
# or
clang --version
```

## Installation Methods

Choose one of the following methods:

### Method 1: Automatic Installation (Recommended)

Use Emacs's built-in grammar installation:

```elisp
;; In your Emacs configuration or *scratch* buffer
(require 'treesit)

;; Add Rholang grammar source
(add-to-list 'treesit-language-source-alist
             '(rholang "https://github.com/F1R3FLY-io/rholang-rs"
                       "main"  ; branch
                       "rholang-tree-sitter"))  ; subdirectory

;; Install the grammar
(treesit-install-language-grammar 'rholang)
```

This will:
1. Clone the repository
2. Compile the grammar with `tree-sitter generate`
3. Build the dynamic library
4. Install to `~/.emacs.d/tree-sitter/`

**Note**: Requires `tree-sitter` CLI and a C compiler.

### Method 2: Manual Compilation

If automatic installation fails or you want more control:

```bash
# 1. Clone the grammar repository
git clone https://github.com/F1R3FLY-io/rholang-rs.git
cd rholang-rs/rholang-tree-sitter

# 2. Install tree-sitter CLI (if not already installed)
npm install -g tree-sitter-cli

# 3. Generate the parser
tree-sitter generate

# 4. Compile to dynamic library
# Linux:
gcc -shared -o libtree-sitter-rholang.so -fPIC src/parser.c -I./src

# macOS:
gcc -shared -o libtree-sitter-rholang.dylib -fPIC src/parser.c -I./src

# Windows (MinGW):
gcc -shared -o tree-sitter-rholang.dll src/parser.c -I./src

# 5. Install the library
mkdir -p ~/.emacs.d/tree-sitter/
cp libtree-sitter-rholang.* ~/.emacs.d/tree-sitter/
```

### Method 3: Using Pre-built Binary (Future)

Pre-built binaries will be available from releases:

```bash
# Download from GitHub releases (when available)
curl -L https://github.com/F1R3FLY-io/rholang-rs/releases/download/v1.1.0/libtree-sitter-rholang-linux-x64.so.gz | gunzip > ~/.emacs.d/tree-sitter/libtree-sitter-rholang.so
```

## Verification

Check if the grammar was installed correctly:

```elisp
;; Check if Rholang grammar is ready
M-: (treesit-ready-p 'rholang)
```

Should return `t`. If not, see [Troubleshooting](#troubleshooting).

## Configuration

### Vanilla Emacs

Add to your `~/.emacs.d/init.el`:

```elisp
;; Add rholang-mode directory to load path
(add-to-list 'load-path "~/.emacs.d/private/rholang-mode")

;; Load tree-sitter mode
(require 'rholang-ts-mode)

;; Optional: Customize indentation
(setq rholang-ts-indent-offset 2)

;; The mode will automatically be used for .rho files if tree-sitter is available
```

### use-package

```elisp
(use-package rholang-ts-mode
  :load-path "~/.emacs.d/private/rholang-mode"
  :mode "\\.rho\\'"
  :config
  (setq rholang-ts-indent-offset 2))
```

### Spacemacs

Add to your `.spacemacs`:

```elisp
(defun dotspacemacs/layers ()
  (setq-default
   dotspacemacs-configuration-layers
   '((rholang :variables
              rholang-use-tree-sitter t      ; Enable tree-sitter mode
              rholang-ts-indent-offset 2      ; Optional: set indentation
              rholang-lsp-enable t            ; Enable LSP
              rholang-use-rnode nil))))       ; Use embedded Rust parser
```

Then reload: `SPC f e R`

### Doom Emacs

In `~/.doom.d/packages.el`:

```elisp
(package! rholang-mode
  :recipe (:local-repo "~/.doom.d/local/rholang-mode"))
```

In `~/.doom.d/config.el`:

```elisp
(use-package! rholang-ts-mode
  :mode "\\.rho\\'"
  :config
  (setq rholang-ts-indent-offset 2))
```

## Usage

### Opening Rholang Files

Open any `.rho` file. If tree-sitter is available, it will automatically use `rholang-ts-mode`.

You'll see `Rholang[TS]` in the mode line.

### Manual Mode Switching

If you want to explicitly use tree-sitter mode:

```
M-x rholang-ts-mode
```

Or fall back to traditional mode:

```
M-x rholang-mode
```

### Inspecting the Parse Tree

Enable tree-sitter inspector to see the AST:

```
M-x treesit-inspect-mode
```

This shows the AST node under point in the mode line, useful for debugging or learning the grammar.

### Exploring Tree-Sitter Features

```elisp
;; View all tree-sitter functions
M-x apropos RET treesit RET

;; Inspect node at point
M-x treesit-inspect-node-at-point

;; Toggle explorer
M-x treesit-explore-mode
```

## Verifying Installation

Create a test file `test.rho`:

```rholang
// Test contract
contract @"hello"(name) = {
  new stdout(`rho:io:stdout`) in {
    stdout!(*name)
  }
}
```

Open it in Emacs and verify:

1. **Syntax highlighting**: Keywords, strings, and comments are colored
2. **Indentation**: Press `TAB` on any line - it should indent correctly
3. **Navigation**: `M-x imenu` should show "Contract: hello"
4. **Mode line**: Should show `Rholang[TS]`

## LSP Integration

Tree-sitter mode works seamlessly with the language server:

```elisp
;; LSP should start automatically if configured
;; Verify with:
M-x lsp-describe-session
```

All [43 LSP keybindings](../../README.md#keybindings-spacemacs) work identically in tree-sitter mode!

## Troubleshooting

### Grammar Not Found

**Symptom**: `(treesit-ready-p 'rholang)` returns `nil`

**Solutions**:

1. Check library location:
   ```bash
   ls -l ~/.emacs.d/tree-sitter/libtree-sitter-rholang.*
   ```

2. Verify library name:
   - Linux: `libtree-sitter-rholang.so`
   - macOS: `libtree-sitter-rholang.dylib`
   - Windows: `tree-sitter-rholang.dll`

3. Check additional load paths:
   ```elisp
   M-: treesit-extra-load-path
   ```

4. Try forcing a load path:
   ```elisp
   (add-to-list 'treesit-extra-load-path "~/custom/path/")
   ```

### Compilation Errors

**Symptom**: `tree-sitter generate` or `gcc` fails

**Solutions**:

1. Update tree-sitter CLI:
   ```bash
   npm install -g tree-sitter-cli@latest
   ```

2. Install build dependencies:
   ```bash
   # Debian/Ubuntu
   sudo apt-get install build-essential

   # macOS
   xcode-select --install

   # Fedora/RHEL
   sudo dnf install gcc make
   ```

3. Check Node.js version (needs 16+):
   ```bash
   node --version
   ```

### Mode Not Activating

**Symptom**: `.rho` files still open in traditional `rholang-mode`

**Solutions**:

1. Check if tree-sitter is available:
   ```elisp
   M-: (treesit-available-p)
   ```

2. Manually switch modes:
   ```
   M-x rholang-ts-mode
   ```

3. Check auto-mode-alist:
   ```elisp
   M-: (assoc "\\.rho\\'" auto-mode-alist)
   ```

4. Force tree-sitter mode:
   ```elisp
   (add-to-list 'auto-mode-alist '("\\.rho\\'" . rholang-ts-mode))
   ```

### Syntax Highlighting Issues

**Symptom**: Code is all one color or incorrectly colored

**Solutions**:

1. Check font-lock level:
   ```elisp
   M-: treesit-font-lock-level  ; Should be 3 or 4
   (setq treesit-font-lock-level 4)
   ```

2. Reload the mode:
   ```
   M-x revert-buffer
   M-x rholang-ts-mode
   ```

3. Check for theme conflicts:
   ```elisp
   M-x describe-face RET font-lock-keyword-face
   ```

### Indentation Issues

**Symptom**: Auto-indentation behaves incorrectly

**Solutions**:

1. Check indent offset:
   ```elisp
   M-: rholang-ts-indent-offset  ; Should be 2 (default)
   ```

2. Inspect the parse tree at the problematic line:
   ```
   M-x treesit-inspect-mode
   ```

3. Report as a bug with the parse tree output

### Performance Issues

**Symptom**: Emacs feels slow with large `.rho` files

**Solutions**:

1. Increase parser timeout:
   ```elisp
   (setq treesit-max-buffer-size 10000000)  ; 10MB
   ```

2. Disable unnecessary features temporarily:
   ```elisp
   (setq treesit-font-lock-level 2)  ; Reduce to basic highlighting
   ```

3. Fall back to traditional mode for very large files:
   ```
   M-x rholang-mode
   ```

## Advanced Configuration

### Custom Font-Lock Level

```elisp
;; Set highlighting detail level (1-4, default: 3)
(setq treesit-font-lock-level 4)
```

Levels:
- **1**: Comments only
- **2**: Comments + keywords + literals
- **3**: Level 2 + types + operators + variables (default)
- **4**: Level 3 + functions + definitions + properties

### Custom Query Path

If you've modified query files:

```elisp
;; Override default query directory
(setq treesit-language-source-alist
      '((rholang . ("~/my-rholang-grammar"))))
```

### Debugging

Enable tree-sitter logging:

```elisp
(setq treesit-debug-functions t)
```

## Next Steps

- **Read the [Architecture doc](ARCHITECTURE.md)** to understand how it works
- **Explore the [Grammar spec](GRAMMAR.md)** to learn about the parser
- **Customize syntax highlighting** in `rholang-ts-mode.el`
- **Contribute improvements** to the grammar or extension

## Getting Help

If you encounter issues:

1. Check the [main README troubleshooting section](../../README.md#troubleshooting)
2. Run `M-x rholang-doctor` for diagnostic information
3. Open an issue at https://github.com/F1R3FLY-io/rholang-emacs-client/issues

Include in your report:
- Emacs version (`M-x emacs-version`)
- `(treesit-available-p)` result
- `(treesit-ready-p 'rholang)` result
- Output of `M-x rholang-doctor`
