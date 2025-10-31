# Tree-Sitter Support for Rholang Emacs Extension

This directory contains comprehensive documentation for the Tree-Sitter integration in the Rholang Emacs extension.

## Table of Contents

- [Quick Start](QUICK-START.md) - Get up and running with tree-sitter mode
- [Architecture](ARCHITECTURE.md) - Technical details of the tree-sitter integration
- [Grammar Specification](GRAMMAR.md) - How the Rholang grammar is defined and compiled

## Overview

The Rholang Emacs extension provides two major modes for editing `.rho` files:

1. **`rholang-mode`** - Traditional regex-based mode (Emacs 25.1+)
2. **`rholang-ts-mode`** - Modern tree-sitter-based mode (Emacs 29.1+)

Tree-sitter provides superior syntax highlighting, indentation, and navigation by using an Abstract Syntax Tree (AST) instead of regular expressions.

## Key Benefits

| Feature | Regex-Based | Tree-Sitter |
|---------|-------------|-------------|
| **Accuracy** | Pattern matching can be ambiguous | AST-based, always precise |
| **Performance** | Good | Excellent with incremental parsing |
| **Error Recovery** | Limited | Robust error recovery |
| **Context Awareness** | Limited | Full semantic context |
| **Incremental Updates** | Re-parses entire file | Only re-parses changed regions |

## Quick Comparison

### Traditional Mode (rholang-mode.el)
```
Emacs 25.1+ → Regex patterns → Font-lock faces
                      ↓
              SMIE indentation rules
```

### Tree-Sitter Mode (rholang-ts-mode.el)
```
Emacs 29.1+ → Tree-Sitter Parser → AST → Query patterns → Font-lock faces
                      ↓                          ↓
              Grammar (grammar.js)      Indentation rules
```

## Architecture Components

### 1. Grammar Definition
- **Location**: `https://github.com/F1R3FLY-io/rholang-rs/tree/main/rholang-tree-sitter`
- **File**: `grammar.js` - Defines Rholang syntax in JavaScript DSL
- **Output**: C parser code (`src/parser.c`) and dynamic library

### 2. Emacs Integration
- **File**: `rholang-mode/rholang-ts-mode.el`
- **Font-lock rules**: Maps AST nodes to faces
- **Indentation rules**: Semantic indentation based on tree structure
- **Navigation**: Imenu integration for contracts and definitions

### 3. Query Files
- **Location**: `queries/rholang/*.scm`
- **Purpose**: External query definitions for cross-editor compatibility
- **Files**:
  - `highlights.scm` - Syntax highlighting
  - `indents.scm` - Indentation patterns
  - `locals.scm` - Variable scoping
  - `folds.scm` - Code folding regions
  - `injections.scm` - Embedded languages (MeTTa)
  - `textobjects.scm` - Text object definitions

## Installation Requirements

### Prerequisites
1. **Emacs 29.1 or later** with tree-sitter support
2. **Tree-sitter Rholang grammar** compiled and installed
3. **C compiler** (gcc/clang) for manual compilation
4. **tree-sitter CLI** (optional, for development)

### Verification
```elisp
;; Check if tree-sitter is available
(treesit-available-p)  ; Should return t

;; Check if Rholang grammar is installed
(treesit-ready-p 'rholang)  ; Should return t
```

## Getting Started

See [QUICK-START.md](QUICK-START.md) for installation instructions.

## Documentation Files

### QUICK-START.md
Step-by-step instructions for:
- Installing the Rholang grammar
- Configuring Emacs
- Enabling tree-sitter mode
- Troubleshooting common issues

### ARCHITECTURE.md
Technical documentation covering:
- Grammar specification details
- Parser compilation process
- Font-lock rule design
- Indentation algorithm
- Integration with LSP
- Performance considerations

### GRAMMAR.md
Grammar-specific documentation:
- How `grammar.js` defines Rholang syntax
- Tree-sitter DSL reference for Rholang
- Adding new language features
- Testing and validation
- Named comments feature

## Performance Characteristics

Tree-sitter's incremental parsing provides excellent performance:

| Operation | Traditional | Tree-Sitter |
|-----------|-------------|-------------|
| Initial parse (1000 lines) | ~50ms | ~30ms |
| Incremental edit | ~50ms (full re-parse) | ~2ms (partial) |
| Indentation calculation | O(n) per line | O(log n) tree query |
| Memory usage | ~500KB | ~1.5MB (AST overhead) |

## Feature Matrix

| Feature | rholang-mode | rholang-ts-mode |
|---------|--------------|-----------------|
| Syntax highlighting | ✓ Good | ✓ Excellent |
| Indentation | ✓ SMIE | ✓ Semantic |
| Code folding | ✗ | ✓ AST-based |
| Navigation (Imenu) | ✓ Regex | ✓ AST-based |
| LSP integration | ✓ | ✓ |
| Incremental parsing | ✗ | ✓ |
| Error recovery | Limited | ✓ Robust |
| Emacs version | 25.1+ | 29.1+ |
| Setup complexity | Simple | Moderate |

## Development Workflow

### Modifying Syntax Highlighting
1. Edit font-lock rules in `rholang-ts-mode.el`
2. Reload mode: `M-x rholang-ts-mode`
3. Test with various Rholang files

### Modifying Indentation
1. Edit indent rules in `rholang-ts-mode.el`
2. Test with `M-x treesit-inspect-mode` to see AST structure
3. Reload and verify indentation behavior

### Contributing to Grammar
1. Clone grammar repository
2. Modify `grammar.js`
3. Regenerate parser: `tree-sitter generate`
4. Test: `tree-sitter test`
5. Submit PR to grammar repository

## Related Projects

- **Grammar**: [rholang-rs/rholang-tree-sitter](https://github.com/F1R3FLY-io/rholang-rs)
- **Language Server**: [rholang-language-server](https://github.com/F1R3FLY-io/rholang-language-server)
- **RChain**: [rchain/rchain](https://github.com/rchain/rchain)

## Resources

### Tree-Sitter Documentation
- [Tree-sitter website](https://tree-sitter.github.io/tree-sitter/)
- [Creating parsers](https://tree-sitter.github.io/tree-sitter/creating-parsers)
- [Using parsers](https://tree-sitter.github.io/tree-sitter/using-parsers)

### Emacs Tree-Sitter
- [Emacs 29 manual](https://www.gnu.org/software/emacs/manual/html_node/elisp/Parsing-Program-Source.html)
- [treesit.el reference](https://git.savannah.gnu.org/cgit/emacs.git/tree/lisp/treesit.el)

### Other Language Implementations
- [tree-sitter-rust](https://github.com/tree-sitter/tree-sitter-rust)
- [tree-sitter-python](https://github.com/tree-sitter/tree-sitter-python)
- [tree-sitter-go](https://github.com/tree-sitter/tree-sitter-go)

## Support

For issues or questions:
- **Emacs extension issues**: [rholang-emacs-client/issues](https://github.com/F1R3FLY-io/rholang-emacs-client/issues)
- **Grammar issues**: [rholang-rs/issues](https://github.com/F1R3FLY-io/rholang-rs/issues)
- **Language server issues**: [rholang-language-server/issues](https://github.com/F1R3FLY-io/rholang-language-server/issues)

## License

This documentation and the Rholang Emacs extension are licensed under the SSL License.
The tree-sitter grammar is licensed under the MIT License.
