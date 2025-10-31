# Tree-Sitter Support for Rholang in Emacs

## Overview

Starting with Emacs 29.1, native tree-sitter support is available. This provides more accurate syntax highlighting, better indentation, and improved navigation compared to the traditional regex-based approach.

## Requirements

- Emacs 29.1 or later with tree-sitter support compiled in
- Rholang tree-sitter grammar installed

## Installing the Rholang Tree-Sitter Grammar

### Using `treesit-install-language-grammar`

Emacs 29+ provides a built-in way to install tree-sitter grammars:

```elisp
(require 'treesit)

;; Add Rholang grammar source
(add-to-list 'treesit-language-source-alist
             '(rholang "https://github.com/F1R3FLY-io/rholang-tree-sitter"))

;; Install the grammar
(treesit-install-language-grammar 'rholang)
```

### Manual Installation

1. Clone the tree-sitter grammar repository:
   ```bash
   git clone https://github.com/F1R3FLY-io/rholang-tree-sitter
   cd rholang-tree-sitter
   ```

2. Compile the grammar:
   ```bash
   # Install tree-sitter CLI if not already installed
   npm install -g tree-sitter-cli

   # Generate and compile the parser
   tree-sitter generate
   gcc -shared -o libtree-sitter-rholang.so -fPIC src/parser.c -I./src
   ```

3. Move the compiled library to Emacs's tree-sitter directory:
   ```bash
   # On Linux/macOS
   mkdir -p ~/.emacs.d/tree-sitter
   mv libtree-sitter-rholang.so ~/.emacs.d/tree-sitter/

   # On macOS, you might need .dylib instead of .so
   # On Windows, you need .dll
   ```

## Usage

### Using rholang-ts-mode

Once the grammar is installed, you can use `rholang-ts-mode`:

```elisp
;; Load the tree-sitter mode
(require 'rholang-ts-mode)

;; It will automatically be used for .rho files if tree-sitter is available
;; You can also manually switch to it:
M-x rholang-ts-mode
```

### Configuration

In your Emacs configuration:

```elisp
;; Set indentation offset (default is 2)
(setq rholang-ts-indent-offset 2)

;; Enable LSP (if you have rholang-language-server installed)
(setq rholang-lsp-enable t)

;; Use embedded Rust parser/interpreter (default)
(setq rholang-use-rnode nil)

;; Or use legacy RNode via gRPC
;; (setq rholang-use-rnode t)
;; (setq rholang-grpc-host "localhost")
;; (setq rholang-grpc-port 40402)

;; If you want to always use tree-sitter mode when available:
(with-eval-after-load 'rholang-ts-mode
  (add-to-list 'auto-mode-alist '("\\.rho\\'" . rholang-ts-mode)))
```

### Spacemacs Layer

If using the Spacemacs layer, configure this in your `.spacemacs`:

```elisp
;; In dotspacemacs/layers:
(defun dotspacemacs/layers ()
  (setq-default
    dotspacemacs-configuration-layers
    '((rholang :variables
               rholang-use-tree-sitter t      ; Use tree-sitter mode
               rholang-lsp-enable t           ; Enable LSP
               rholang-use-rnode nil          ; Use embedded Rust (default)
               ;; Or use legacy RNode:
               ;; rholang-use-rnode t
               ;; rholang-grpc-host "localhost"
               ;; rholang-grpc-port 40402
               ))))

;; In dotspacemacs/user-config:
(defun dotspacemacs/user-config ()
  ;; Make sure the grammar source is configured
  (with-eval-after-load 'treesit
    (add-to-list 'treesit-language-source-alist
                 '(rholang "https://github.com/F1R3FLY-io/rholang-tree-sitter"))))
```

## Features

The tree-sitter mode provides:

### Syntax Highlighting

- **Comments**: Line and block comments
- **Keywords**: `contract`, `for`, `in`, `if`, `else`, `match`, `select`, `new`, `let`, `bundle`
- **Operators**: All Rholang operators with proper semantic highlighting
- **Literals**: Booleans, numbers, strings, URIs, `Nil`, and unit `()`
- **Types**: Built-in types like `Bool`, `Int`, `String`, `Set`, etc.
- **Functions**: Contract names, method calls, channel operations
- **Variables**: Variable declarations and references
- **Properties**: Map keys in key-value pairs

### Indentation

Automatic indentation for:
- Blocks and collections
- Control structures (`if`, `match`, `select`, `for`, `new`, `let`)
- Case and branch patterns
- Declarations and bindings
- Nested structures

### Navigation

- Jump to definitions with `imenu`
- Navigate between contracts and other top-level forms
- Syntax-aware movement commands

## Troubleshooting

### Check if tree-sitter is available

```elisp
(treesit-available-p)  ; Should return t
```

### Check if Rholang grammar is installed

```elisp
(treesit-ready-p 'rholang)  ; Should return t
```

### Debug grammar loading

```elisp
;; See where Emacs looks for grammars
treesit-extra-load-path

;; List all available grammars
(treesit-language-available-p 'rholang t)
```

### Common Issues

1. **Grammar not found**: Make sure the compiled `.so`/`.dylib`/`.dll` file is in `~/.emacs.d/tree-sitter/` or a directory in `treesit-extra-load-path`.

2. **Wrong library name**: The library must be named `libtree-sitter-rholang.so` (or `.dylib` on macOS, `.dll` on Windows).

3. **Compilation errors**: Ensure you have a C compiler and the tree-sitter CLI installed.

## Comparison: Traditional Mode vs Tree-Sitter Mode

| Feature | rholang-mode | rholang-ts-mode |
|---------|--------------|-----------------|
| Emacs Version | 25.1+ | 29.1+ |
| Syntax Highlighting | Regex-based | AST-based |
| Indentation | SMIE | Tree-sitter rules |
| Performance | Good | Excellent |
| Accuracy | Good | Excellent |
| Setup Complexity | Simple | Moderate |

## Contributing

To improve the tree-sitter queries, edit the S-expressions in `rholang-ts-mode.el`. The queries are organized by feature (comments, keywords, operators, etc.).

For updates to the grammar itself, see the [rholang-tree-sitter](https://github.com/F1R3FLY-io/rholang-tree-sitter) repository.
