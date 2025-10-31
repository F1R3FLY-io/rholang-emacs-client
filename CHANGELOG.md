# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2025-10-31

### Changed
- **BREAKING**: Reorganized Spacemacs keybindings to follow standard Spacemacs conventions with prefix-based organization
  - `SPC m d` (go to definition) → `SPC m g d`
  - `SPC m r` (find references) → `SPC m g r`
  - `SPC m h` (describe at point) → `SPC m h h`
  - The `r` prefix now used for refactoring commands
- Expanded keybindings from 5 to 43 comprehensive LSP keybindings organized into 10 categories

### Added
- Navigation keybindings: find implementation, type definition, declaration
- Peek navigation keybindings (requires lsp-ui): peek definitions, references, implementation
- Refactoring keybindings: rename symbol, organize imports
- Code action keybindings: execute code action, avy lens
- Help/documentation keybindings: signature help, doc glance
- Formatting keybindings: format buffer, format region
- Workspace management keybindings: restart, shutdown, describe session, show log
- Toggle keybindings: code lens, breadcrumb, hover docs, sideline
- Error/diagnostics keybindings: next/previous error, errors list, check buffer
- Treemacs integration keybindings: symbols, call hierarchy, type hierarchy
- Optional package support: lsp-ui, lsp-treemacs, flycheck
- Comprehensive keybinding documentation in README with migration guide
- CHANGELOG.md to track version history

### Improved
- README documentation with organized keybinding reference tables
- Prerequisites section now distinguishes between required and optional packages
- Better documentation of optional package dependencies

## [0.0.3] - 2025-10-30

### Added
- Validator backend configuration support
- `rholang-use-rnode` variable to choose between embedded Rust parser and legacy RNode
- `rholang-grpc-host` and `rholang-grpc-port` variables for RNode gRPC configuration
- Documentation for dual backend system (embedded Rust vs RNode via gRPC)

### Changed
- Default backend is now embedded Rust parser/interpreter (no external dependencies)
- Language server receives `--no-rnode` flag by default
- RNode mode now optional via `rholang-use-rnode` configuration

## [0.0.2] - 2025-10-29

### Added
- Improved README.md documentation
- Better installation instructions
- Enhanced configuration examples

## [0.0.1] - 2025-10-28

### Added
- Initial Emacs extension for Rholang
- Basic syntax highlighting
- SMIE-based automatic indentation
- Tree-sitter mode support (Emacs 29.1+)
- LSP integration with rholang-language-server
- Spacemacs layer with custom layout
- Basic keybindings (5 commands)
- rholang-doctor diagnostic tool
- Smartparens integration
- Configuration variables for LSP and indentation

[0.0.4]: https://github.com/F1R3FLY-io/rholang-emacs-client/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/F1R3FLY-io/rholang-emacs-client/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/F1R3FLY-io/rholang-emacs-client/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/F1R3FLY-io/rholang-emacs-client/releases/tag/v0.0.1
