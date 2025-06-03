# Rholang for Emacs

`rholang-emacs-client` is integrates with `rholang-language-server` and `rnode` to provide support for editing Rholang files with syntax highlighting, automatic indentation, and related Language Server Protocol (LSP) features.

## Features

- **Syntax Highlighting**: Comprehensive syntax highlighting for Rholang keywords, constants, operators, strings, and comments.
- **Automatic Indentation**: Automatic indentation using SMIE (Simple Minded Indentation Engine) with customizable indentation size.
- **LSP Integration**: Seamless integration with `rholang-language-server` for features like code completion, go-to-definition, and diagnostics.
- **Spacemacs Layer**: Dedicated Spacemacs layer for enhanced keybindings and workspace layout.
- **Smartparens Support**: Optional integration with `smartparens` for automatic brace handling.
- **RNode Integration**: Checks for a running RNode instance to enable LSP functionality.

## Prerequisites

- Emacs 25.1 or higher
- `lsp-mode` 8.0.0 or higher
- A running RNode instance (available from [F1R3FLY.io](https://github.com/F1R3FLY-io/f1r3fly))
- `rholang-language-server` executable (available from [F1R3FLY.io](https://github.com/F1R3FLY-io/rholang-language-server))
- (Optional) Spacemacs for layer-based configuration
- (Optional) `smartparens` for enhanced brace handling

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
                   rholang
                   ))
   ```

3. Restart Spacemacs or reload the configuration with `SPC f e R`.

## Configuration

The following customizable variables are available:

- `rholang-lsp-server-path`: Path to the `rholang-language-server` executable (default: `"rholang-language-server"`).
- `rholang-lsp-log-level`: Log level for rholang-language-server communication. (`"error"`, `"warn"`, `"info"`, `"debug"`, or `"trace"`; default: `"info"`).
- `rholang-lsp-enable`: Enable or disable LSP support (default: `t`).
- `rholang-rnode-host`: Host for the RNode instance (default: `"localhost"`).
- `rholang-rnode-port`: Port for the RNode status endpoint (default: `40403`).
- `rholang-indent-size`: Indentation size for Rholang code (default: `2`).

To customize these variables, add to your Emacs configuration:

```emacs-lisp
(setq rholang-lsp-server-path "/path/to/rholang-language-server")
(setq rholang-lsp-log-level "debug")
(setq rholang-indent-size 4)
```

For Spacemacs, these variables are automatically synchronized with the layer configuration.

## Usage

1. Open a `.rho` file, and Emacs will automatically enable `rholang-mode`.
2. Ensure an RNode instance is running at the configured host and port (default: `localhost:40403`).
3. LSP features (e.g., code completion, go-to-definition) are enabled if `rholang-lsp-enable` is `t` and the RNode instance is detected.

### Keybindings (Spacemacs)

In Spacemacs, the following keybindings are available in `rholang-mode`:

- `SPC m l`: Start LSP (`lsp`)
- `SPC m d`: Go to definition (`lsp-find-definition`)
- `SPC m r`: Find references (`lsp-find-references`)
- `SPC m h`: Describe thing at point (`lsp-describe-thing-at-point`)

### Spacemacs Layout

Use `SPC l r` to open a custom layout (`@Rholang`) that loads `rholang-mode.el` and `rholang-lsp.el` in a split window.

## File Structure

```
rholang-emacs-client
├── layers
│   └── rholang
│       ├── config.el      # Spacemacs layer configuration
│       └── packages.el    # Spacemacs package definitions
├── rholang-mode
│   ├── rholang-lsp.el    # LSP integration for Rholang
│   ├── rholang-mode.el   # Major mode for Rholang
│   └── rholang-syntax.el # Syntax highlighting definitions
├── LICENSE.TXT           # License file
└── README.md             # This file
```

## Troubleshooting

- **LSP not starting**: Ensure `rholang-language-server` is in your PATH or set `rholang-lsp-server-path`. Verify the RNode instance is running at the specified host/port.

## Contributing

Contributions are welcome! Please submit issues or pull requests to [https://github.com/F1R3FLY-io/rholang-emacs-client](https://github.com/F1R3FLY-io/rholang-emacs-client).

## License

This project is licensed under the SSL License. See the [LICENSE.TXT](LICENSE.TXT) file for details.
