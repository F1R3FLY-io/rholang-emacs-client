# Rholang for Emacs

`rholang-emacs-client` is integrates with `rholang-language-server` and `rnode` to provide support for editing Rholang files with syntax highlighting, automatic indentation, and related Language Server Protocol (LSP) features.

## Features

- **Syntax Highlighting**: Comprehensive syntax highlighting for Rholang keywords, constants, operators, strings, and comments.
- **Semantic Highlighting**: LSP-powered context-aware highlighting that distinguishes parameters, variables, functions, and types based on semantic meaning.
- **Automatic Indentation**: Automatic indentation using SMIE (Simple Minded Indentation Engine) with customizable indentation size.
- **Tree-Sitter Support**: Modern AST-based syntax highlighting and indentation for Emacs 29.1+ (see [TREE-SITTER.md](rholang-mode/TREE-SITTER.md)).
- **LSP Integration**: Seamless integration with `rholang-language-server` for features like code completion, go-to-definition, diagnostics, and semantic tokens.
- **Spacemacs Layer**: Dedicated Spacemacs layer for enhanced keybindings and workspace layout.
- **Smartparens Support**: Optional integration with `smartparens` for automatic brace handling.
- **Dual Diagnostic Modes**: Support for both embedded Rust parser/interpreter and legacy RNode via gRPC.

## Prerequisites

### Required
- Emacs 25.1 or higher
- `lsp-mode` 8.0.0 or higher
- `rholang-language-server` executable (available from [F1R3FLY.io](https://github.com/F1R3FLY-io/rholang-language-server))

### Optional
- Running RNode instance for legacy gRPC-based diagnostics (available from [F1R3FLY.io](https://github.com/F1R3FLY-io/f1r3fly))
- Spacemacs for layer-based configuration
- `smartparens` for enhanced brace handling
- `lsp-ui` for peek navigation and enhanced UI features
- `lsp-treemacs` for tree views (symbols, call hierarchy, errors list)
- `flycheck` for error navigation

## Installation

### Manual Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/F1R3FLY-io/rholang-emacs-client.git /path/to/rholang-emacs-client
   ```

2. Copy `rholang-mode/` to `~/.emacs.d/private/`:

   ```bash
   mkdir -p ~/.emacs.d/private/
   cp -a /path/to/rholang-emacs-client/rholang-mode/ ~/.emacs.d/private/
   ```

3. Add the following to your Emacs configuration (`~/.emacs` or `~/.emacs.d/init.el`):

   ```emacs-lisp
   (add-to-list 'load-path "~/.emacs.d/private/rholang-mode")
   (require 'rholang-mode)
   ```

3. Ensure `rholang-language-server` is installed and accessible in your system PATH or configure `rholang-lsp-server-path` to its location.

### Spacemacs Installation

1. Copy `layers/rholang/` to your Spacemacs private layers directory:

   ```bash
   mkdir -p ~/.spacemacs.d/layers/
   cp -a /path/to/rholang-emacs-client/layers/rholang/ ~/.spacemacs.d/layers/
   ```

2. Add `rholang` to the `dotspacemacs-configuration-layers` list in your `.spacemacs` file:

   ```emacs-lisp
   (setq-default dotspacemacs-configuration-layers
                 '(
                   ;; Other layers
                   (rholang :variables
                            rholang-lsp-enable t
                            rholang-use-rnode nil
                            rholang-indent-size 2)
                   ))
   ```

3. Restart Spacemacs or reload the configuration with `SPC f e R`.

**📖 For complete Spacemacs configuration options**, see the [Spacemacs Configuration Guide](docs/SPACEMACS-CONFIG.md).

## Configuration

The following customizable variables are available:

- `rholang-lsp-server-path`: Path to the `rholang-language-server` executable (default: `"rholang-language-server"`).
- `rholang-lsp-log-level`: Log level for rholang-language-server communication (`"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`; default: `"info"`).
- `rholang-lsp-enable`: Enable or disable LSP support (default: `t`).
- `rholang-use-rnode`: Use RNode for diagnostics via gRPC (default: `nil`). When `nil`, the embedded Rust parser/interpreter is used.
- `rholang-grpc-host`: RNode gRPC server host (default: `"localhost"`). Used when `rholang-use-rnode` is non-nil.
- `rholang-grpc-port`: RNode gRPC server port (default: `40402`). Used when `rholang-use-rnode` is non-nil.
- `rholang-indent-size`: Indentation size for Rholang code (default: `2`).
- `rholang-use-tree-sitter`: Use tree-sitter mode instead of traditional mode (default: `nil`). Requires Emacs 29.1+.

### RNode Integration

The language server supports two modes for obtaining diagnostics:

1. **Embedded Rust Parser/Interpreter** (default, `rholang-use-rnode = nil`):
   - Uses the new experimental Rust implementation directly linked into the language server
   - Faster startup, no external dependencies
   - Suitable for most development workflows

2. **Legacy RNode via gRPC** (`rholang-use-rnode = t`):
   - Communicates with legacy Scala RNode server via gRPC on port 40402
   - Stable, production-ready implementation
   - Required for customers using legacy RNode
   - Can run RNode in Docker or locally

**Note**: When `rholang-use-rnode` is `nil`, the language server receives the `--no-rnode` flag. When `rholang-use-rnode` is `t`, the language server receives `--grpc-host` and `--grpc-port` flags to communicate with RNode.

### Configuration Examples

**Basic Configuration (Emacs):**

```emacs-lisp
(setq rholang-lsp-server-path "/path/to/rholang-language-server")
(setq rholang-lsp-log-level "debug")
(setq rholang-indent-size 4)
```

**Use RNode for diagnostics (Emacs):**

```emacs-lisp
(setq rholang-use-rnode t)
(setq rholang-grpc-host "localhost")
(setq rholang-grpc-port 40402)
```

**Spacemacs Configuration (default, embedded Rust):**

```emacs-lisp
(defun dotspacemacs/layers ()
  (setq-default
    dotspacemacs-configuration-layers
    '((rholang :variables
               rholang-lsp-server-path "rholang-language-server"
               rholang-lsp-log-level "info"
               rholang-lsp-enable t
               rholang-use-rnode nil
               rholang-indent-size 2))))
```

**Spacemacs Configuration (use legacy RNode):**

```emacs-lisp
(defun dotspacemacs/layers ()
  (setq-default
    dotspacemacs-configuration-layers
    '((rholang :variables
               rholang-lsp-server-path "rholang-language-server"
               rholang-lsp-log-level "info"
               rholang-lsp-enable t
               rholang-use-rnode t
               rholang-grpc-host "localhost"
               rholang-grpc-port 40402
               rholang-indent-size 2))))
```

## Usage

1. Open a `.rho` file, and Emacs will automatically enable `rholang-mode`.
2. If using RNode (`rholang-use-rnode = t`), ensure an RNode instance is running at the configured gRPC host and port (default: `localhost:40402`).
3. LSP features (e.g., code completion, go-to-definition, semantic highlighting) are enabled if `rholang-lsp-enable` is `t`.

#### LSP Semantic Highlighting

The extension supports **LSP semantic tokens** for context-aware highlighting that goes beyond syntax:

- **Contract names** are highlighted as functions
- **Parameters** get distinct coloring from local variables
- **Type names** are visually distinguished
- **Variables** are colored based on their semantic role

Semantic highlighting is **enabled by default** when LSP is active. For more details, see [SEMANTIC-HIGHLIGHTING.md](docs/SEMANTIC-HIGHLIGHTING.md).

### Using Tree-Sitter Mode (Emacs 29.1+)

Tree-sitter provides superior syntax highlighting, indentation, and navigation using an Abstract Syntax Tree (AST) instead of regular expressions.

**Quick Start**:
1. Ensure Emacs 29.1+ with tree-sitter support
2. Install the Rholang grammar (see [Quick Start Guide](docs/tree-sitter/QUICK-START.md))
3. Load the tree-sitter mode:
   ```emacs-lisp
   (require 'rholang-ts-mode)
   ```
4. Open any `.rho` file - tree-sitter mode activates automatically if available

**Documentation**:
- **[Quick Start Guide](docs/tree-sitter/QUICK-START.md)** - Installation and configuration
- **[Architecture Guide](docs/tree-sitter/ARCHITECTURE.md)** - Technical details and internals
- **[Grammar Specification](docs/tree-sitter/GRAMMAR.md)** - How the parser is defined
- **[Legacy Guide](rholang-mode/TREE-SITTER.md)** - Original setup documentation

**Benefits over traditional mode**:
- 🎯 **Precise**: AST-based highlighting (no regex ambiguity)
- ⚡ **Fast**: Incremental parsing (only re-parse changes)
- 🔧 **Robust**: Error recovery maintains valid AST
- 🧭 **Smart**: Context-aware indentation and navigation

### Keybindings (Spacemacs)

**⚠️ Breaking Change in v0.0.4**: Keybindings have been reorganized to follow Spacemacs conventions with prefix-based organization. Old bindings:
- `SPC m d` (go to definition) → **now** `SPC m g d`
- `SPC m r` (find references) → **now** `SPC m g r`
- `SPC m h` (describe at point) → **now** `SPC m h h`

The `r` prefix is now used for refactoring commands (rename, organize imports).

#### Core Bindings

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m l` | `lsp` | Start LSP server |
| `SPC m D` | `rholang-doctor` | Run diagnostics tool |

#### Navigation (prefix: `g`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m g d` | `lsp-find-definition` | Go to definition |
| `SPC m g r` | `lsp-find-references` | Find all references |
| `SPC m g i` | `lsp-find-implementation` | Find implementation |
| `SPC m g t` | `lsp-find-type-definition` | Find type definition |
| `SPC m g D` | `lsp-find-declaration` | Find declaration |

#### Peek Navigation (prefix: `G`, requires `lsp-ui`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m G d` | `lsp-ui-peek-find-definitions` | Peek at definitions |
| `SPC m G r` | `lsp-ui-peek-find-references` | Peek at references |
| `SPC m G i` | `lsp-ui-peek-find-implementation` | Peek at implementation |

#### Refactoring (prefix: `r`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m r r` | `lsp-rename` | Rename symbol across workspace |
| `SPC m r o` | `lsp-organize-imports` | Organize imports |

#### Code Actions (prefix: `a`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m a a` | `lsp-execute-code-action` | Execute code action at point |
| `SPC m a l` | `lsp-avy-lens` | Jump to code lens with avy |

#### Help/Documentation (prefix: `h`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m h h` | `lsp-describe-thing-at-point` | Show documentation at point |
| `SPC m h s` | `lsp-signature-activate` | Show signature help |
| `SPC m h g` | `lsp-ui-doc-glance` | Peek at documentation (requires `lsp-ui`) |

#### Formatting (prefix: `=`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m = =` | `lsp-format-buffer` | Format entire buffer |
| `SPC m = r` | `lsp-format-region` | Format selected region |

#### Workspace Management (prefix: `w`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m w r` | `lsp-workspace-restart` | Restart LSP workspace |
| `SPC m w q` | `lsp-workspace-shutdown` | Shutdown LSP workspace |
| `SPC m w d` | `lsp-describe-session` | Describe current session |
| `SPC m w s` | `lsp-workspace-show-log` | Show workspace log |

#### Toggles (prefix: `T`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m T l` | `lsp-lens-mode` | Toggle code lens display |
| `SPC m T b` | `lsp-headerline-breadcrumb-mode` | Toggle breadcrumb navigation |
| `SPC m T h` | `lsp-ui-doc-mode` | Toggle hover documentation (requires `lsp-ui`) |
| `SPC m T s` | `lsp-ui-sideline-mode` | Toggle sideline info (requires `lsp-ui`) |

#### Errors/Diagnostics (prefix: `e`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m e n` | `flycheck-next-error` | Jump to next error |
| `SPC m e p` | `flycheck-previous-error` | Jump to previous error |
| `SPC m e l` | `lsp-treemacs-errors-list` | List all errors (requires `lsp-treemacs`) |
| `SPC m e b` | `flycheck-buffer` | Check current buffer |

#### Treemacs Integration (prefix: `t`, requires `lsp-treemacs`)

| Key | Command | Description |
|-----|---------|-------------|
| `SPC m t s` | `lsp-treemacs-symbols` | Show document symbols in treemacs |
| `SPC m t c` | `lsp-treemacs-call-hierarchy` | Show call hierarchy |
| `SPC m t t` | `lsp-treemacs-type-hierarchy` | Show type hierarchy |

### Spacemacs Layout

Use `SPC l r` to open a custom layout (`@Rholang`) that loads `rholang-mode.el` and `rholang-lsp.el` in a split window.

## File Structure

```
rholang-emacs-client
├── docs
│   └── tree-sitter           # Tree-sitter documentation
│       ├── README.md         # Overview and index
│       ├── QUICK-START.md    # Installation guide
│       ├── ARCHITECTURE.md   # Technical details
│       └── GRAMMAR.md        # Grammar specification
├── layers
│   └── rholang
│       ├── config.el         # Spacemacs layer configuration
│       └── packages.el       # Spacemacs package definitions
├── rholang-mode
│   ├── rholang-doctor.el     # Diagnostic utilities
│   ├── rholang-lsp.el        # LSP integration for Rholang
│   ├── rholang-mode.el       # Major mode for Rholang (traditional)
│   ├── rholang-ts-mode.el    # Tree-sitter based mode (Emacs 29.1+)
│   ├── rholang-syntax.el     # Syntax highlighting definitions
│   └── TREE-SITTER.md        # Legacy tree-sitter setup guide
├── queries
│   └── rholang               # Tree-sitter query files
│       ├── highlights.scm    # Syntax highlighting patterns
│       ├── indents.scm       # Indentation rules
│       ├── locals.scm        # Variable scoping
│       ├── folds.scm         # Code folding regions
│       ├── injections.scm    # Embedded language support
│       └── textobjects.scm   # Text object definitions
├── CHANGELOG.md              # Version history
├── LICENSE.TXT               # License file
└── README.md                 # This file
```

## Health Check / Diagnostics

Run `M-x rholang-doctor` to check your Rholang mode installation. The diagnostic tool will verify:

- Emacs version (>= 25.1)
- Dependencies: `lsp-mode`, optional tree-sitter support (Emacs 29.1+)
- LSP configuration: `rholang-language-server` executable, running status
- **RNode mode**: Reports whether using embedded Rust parser or legacy RNode via gRPC
- Rholang mode configuration: tree-sitter preference, indentation settings
- File associations: `.rho` files correctly associated with `rholang-mode`
- Optional packages: `smartparens`, `company-mode`

In **Spacemacs**, you can also run: `SPC m D` (in a Rholang buffer)

The diagnostic output will show color-coded messages:
- ✓ **OK** (green): Component is working correctly
- ⚠ **WARN** (yellow): Optional component missing or disabled
- ✗ **ERROR** (red): Required component missing or misconfigured
- ℹ **INFO** (cyan): Informational message

## Troubleshooting

- **LSP not starting**: Run `M-x rholang-doctor` to diagnose. Ensure `rholang-language-server` is in your PATH or set `rholang-lsp-server-path`.
- **RNode connection issues**: If using `rholang-use-rnode = t`, verify the RNode instance is running and accessible at the configured gRPC host/port (default: `localhost:40402`). Check that the gRPC port is not blocked by firewalls.
- **Docker RNode**: If running RNode in Docker, ensure the gRPC port (40402) is properly exposed and mapped.

## Contributing

Contributions are welcome! Please submit issues or pull requests to [https://github.com/F1R3FLY-io/rholang-emacs-client](https://github.com/F1R3FLY-io/rholang-emacs-client).

## License

This project is licensed under the SSL License. See the [LICENSE.TXT](LICENSE.TXT) file for details.
