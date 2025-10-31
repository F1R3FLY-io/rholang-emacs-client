# Rholang Tree-Sitter Grammar Specification

This document explains how the Rholang grammar is defined, compiled, and used in the Emacs extension.

## Table of Contents

- [Grammar Location](#grammar-location)
- [Grammar Definition (grammar.js)](#grammar-definition-grammarjs)
- [Compilation Process](#compilation-process)
- [Named Comments Feature](#named-comments-feature)
- [Grammar Structure](#grammar-structure)
- [Node Types](#node-types)
- [Working with the Grammar](#working-with-the-grammar)

## Grammar Location

The Rholang tree-sitter grammar is maintained in a separate repository:

- **Repository**: https://github.com/F1R3FLY-io/rholang-rs
- **Path**: `rholang-tree-sitter/`
- **Main file**: `grammar.js`
- **Version**: 1.1.0

The grammar is written as a JavaScript DSL that tree-sitter compiles to C code.

## Grammar Definition (grammar.js)

The grammar is defined using tree-sitter's JavaScript DSL in `grammar.js`:

```javascript
module.exports = grammar({
  name: 'rholang',

  externals: $ => [
    $._line_comment,
    $._block_comment
  ],

  extras: $ => [
    /\s/,
    $._line_comment,
    $._block_comment
  ],

  rules: {
    source_file: $ => repeat($._proc),

    _proc: $ => choice(
      $.nil,
      $.contract,
      $.new,
      $.for,
      // ... more process types
    ),

    contract: $ => seq(
      'contract',
      field('name', $._name),
      '(',
      optional(field('params', $.params)),
      ')',
      '=',
      '{',
      field('body', $._proc),
      '}'
    ),

    // ... hundreds more rules
  }
});
```

### Key Grammar Concepts

#### 1. **Rules** (`$.rule_name`)
Define the structure of language constructs:
```javascript
contract: $ => seq('contract', $.name, '=', $.body)
```

#### 2. **Fields** (`field('name', $.pattern)`)
Name important parts of the AST for queries:
```javascript
field('name', $.identifier)  // Access via (contract name: ...)
```

#### 3. **Choice** (`choice(a, b, c)`)
Multiple alternatives (OR):
```javascript
_proc: $ => choice($.send, $.receive, $.parallel)
```

#### 4. **Sequence** (`seq(a, b, c)`)
Ordered elements (AND):
```javascript
send: $ => seq($.channel, '!', '(', $.message, ')')
```

#### 5. **Repeat** (`repeat()`, `repeat1()`)
Zero-or-more, one-or-more:
```javascript
params: $ => repeat1($.param)
```

#### 6. **Optional** (`optional()`)
May or may not be present:
```javascript
for: $ => seq('for', '(', optional($.bindings), ')', $.body)
```

## Compilation Process

### Step 1: Grammar Definition

Write the grammar in `grammar.js` using the tree-sitter DSL.

### Step 2: Generate Parser

The tree-sitter CLI compiles `grammar.js` to C code:

```bash
cd rholang-tree-sitter
tree-sitter generate
```

**Output**:
- `src/parser.c` - Main parser (100,000+ lines of generated C)
- `src/tree_sitter/parser.h` - Parser interface
- `src/node-types.json` - AST node definitions
- `src/grammar.json` - Compiled grammar representation

### Step 3: Compile to Dynamic Library

The C code is compiled to a platform-specific library:

```bash
# Linux
gcc -shared -o libtree-sitter-rholang.so -fPIC src/parser.c -I./src

# macOS
gcc -shared -o libtree-sitter-rholang.dylib -fPIC src/parser.c -I./src

# Windows
gcc -shared -o tree-sitter-rholang.dll src/parser.c -I./src
```

**Output**: Dynamic library that Emacs loads via `treesit.el`.

### Step 4: Install for Emacs

Place the library where Emacs can find it:

```bash
mkdir -p ~/.emacs.d/tree-sitter/
mv libtree-sitter-rholang.so ~/.emacs.d/tree-sitter/
```

Emacs searches:
1. `~/.emacs.d/tree-sitter/`
2. Directories in `treesit-extra-load-path`

### Automated Compilation (Language Server)

The `rholang-language-server` automates this in its build script (`build.rs`):

```rust
fn ensure_rholang_parser_with_named_comments() -> Result<()> {
    let tree_sitter_path = "../rholang-rs/rholang-tree-sitter";

    // Check if regeneration is needed
    if !marker_path.exists() || grammar_changed() {
        // Regenerate with RHOLANG_NAMED_COMMENTS=1
        Command::new("npx")
            .args(&["tree-sitter", "generate"])
            .env("RHOLANG_NAMED_COMMENTS", "1")
            .status()?;
    }

    Ok(())
}
```

This ensures the parser is always built with the correct features.

## Named Comments Feature

### What is it?

By default, tree-sitter treats comments as **unnamed nodes** (invisible in the AST). The Rholang grammar supports a **named comments** feature that makes comments visible as AST nodes.

### Why is it important?

LSP features need to access comments for:
- Documentation strings (hover information)
- Comment-based directives
- Code analysis tools

### How it works

The grammar checks an environment variable during generation:

```javascript
// In grammar.js
const NAMED_COMMENTS = process.env.RHOLANG_NAMED_COMMENTS === '1';

module.exports = grammar({
  name: 'rholang',

  externals: $ => NAMED_COMMENTS ? [
    $._line_comment,
    $._block_comment
  ] : [],

  extras: $ => NAMED_COMMENTS ? [
    /\s/,
    $._line_comment,
    $._block_comment
  ] : [
    /\s/,
    /\/\/.*/,           // Unnamed line comment
    /\/\*[^*]*\*+([^/*][^*]*\*+)*\//  // Unnamed block comment
  ],
});
```

### Enabling Named Comments

```bash
# Set environment variable before generating
export RHOLANG_NAMED_COMMENTS=1
tree-sitter generate

# Or inline
RHOLANG_NAMED_COMMENTS=1 tree-sitter generate
```

### Verification

The `build.rs` script verifies comments are named:

```rust
fn verify_named_comments_enabled(tree_sitter_path: &str) -> Result<()> {
    // Parse test file with comments
    let test_code = "// line comment\n/* block comment */\nNil";
    let output = parse_with_tree_sitter(test_code)?;

    // Check AST contains (line_comment) and (block_comment) nodes
    assert!(output.contains("line_comment"));
    assert!(output.contains("block_comment"));
    Ok(())
}
```

## Grammar Structure

The Rholang grammar defines these major categories:

### 1. **Processes** (Core concurrency primitives)
- `nil` - Empty process
- `par` - Parallel composition (`P | Q`)
- `send` - Send message (`ch!(msg)`)
- `receive` - Receive message (`for(x <- ch)`)
- `new` - Create new channel (`new x in P`)
- `contract` - Define contract (`contract @"name"(params) = { body }`)

### 2. **Names** (Channels and addresses)
- `quote` - Quote process (`@P`)
- `var` - Variable name
- `uri` - URI literal (`` `rho:uri` ``)
- `wildcard` - Wildcard pattern (`_`)

### 3. **Expressions** (Data and computation)
- `var` - Variables
- `bool_literal` - Booleans
- `long_literal` - Integers
- `string_literal` - Strings
- `list` - Lists (`[1, 2, 3]`)
- `tuple` - Tuples (`(1, 2, 3)`)
- `set` - Sets (`Set(1, 2, 3)`)
- `map` - Maps (`{"key": value}`)

### 4. **Control Flow**
- `ifElse` - Conditional (`if (cond) P else Q`)
- `match` - Pattern matching (`match expr { case => P }`)
- `choice` - Non-deterministic choice (`select { case => P }`)

### 5. **Operators**
- Arithmetic: `+`, `-`, `*`, `/`, `%`, `%%`
- Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Logical: `and`, `or`, `not`
- Channels: `!` (send), `!!` (send-receive), `<-` (receive)

## Node Types

Every AST node has a **type** that can be queried. Example node types:

```
source_file
├── contract
│   ├── name: (quote)
│   ├── params: (params
│   │   └── param: (var))
│   └── body: (block
│       └── send
│           ├── channel: (quote)
│           └── message: (string_literal))
```

### Field Names

Important nodes have **field names** for precise queries:

```scheme
; Query contracts by name field
(contract name: (quote) @function-name)

; Query for-loops by binding field
(for receipts: (receipts) @binding)

; Query if-else by condition field
(ifElse condition: (_) @condition)
```

See `src/node-types.json` for the complete list.

## Working with the Grammar

### 1. Viewing the Grammar Locally

```bash
git clone https://github.com/F1R3FLY-io/rholang-rs.git
cd rholang-rs/rholang-tree-sitter
less grammar.js
```

### 2. Testing Grammar Changes

```bash
# Add test cases to test/corpus/
cat > test/corpus/my_test.txt <<EOF
===================
Test: Simple contract
===================

contract @"hello"() = {
  Nil
}

---

(source_file
  (contract
    name: (quote (string_literal))
    params: (params)
    body: (block (nil))))
EOF

# Run tests
tree-sitter test
```

### 3. Inspecting Parse Trees

```bash
echo 'contract @"test"() = { Nil }' | tree-sitter parse
```

Output:
```
(source_file [0, 0] - [1, 0]
  (contract [0, 0] - [0, 30]
    name: (quote [0, 9] - [0, 16]
      (string_literal [0, 10] - [0, 16]))
    params: (params [0, 16] - [0, 18])
    body: (block [0, 23] - [0, 30]
      (nil [0, 25] - [0, 28]))))
```

### 4. Playground (Interactive Development)

```bash
tree-sitter build --wasm
tree-sitter playground
```

Opens a web UI where you can:
- Edit grammar.js in real-time
- See parse tree updates instantly
- Test queries interactively

## Grammar Dependencies

The grammar is specified in `package.json`:

```json
{
  "name": "tree-sitter-rholang",
  "version": "1.1.0",
  "repository": "https://github.com/F1R3FLY-io/rholang-rs",
  "dependencies": {
    "node-addon-api": "^8.2.1",
    "node-gyp-build": "^4.8.2"
  },
  "devDependencies": {
    "tree-sitter-cli": "^0.25.6"
  }
}
```

And referenced in Rust code via `Cargo.toml`:

```toml
[dependencies]
rholang-tree-sitter = {
    git = "https://github.com/dylon/rholang-rs.git",
    branch = "dylon/comments",
    features = ["named-comments"]
}
tree-sitter = "0.25"
```

## Query Files

The grammar repository should include query files in `queries/`:

```
queries/
├── highlights.scm     # Syntax highlighting
├── indents.scm        # Indentation rules
├── locals.scm         # Variable scoping
├── folds.scm          # Code folding
├── injections.scm     # Embedded languages
└── textobjects.scm    # Text object definitions
```

These are **editor-agnostic** and work with:
- Emacs (via `treesit.el`)
- Neovim (via `nvim-treesitter`)
- Helix editor
- Any editor with tree-sitter support

## Common Grammar Patterns

### Pattern: Optional trailing separator

```javascript
seq(
  repeat(seq($.item, ',')),
  optional($.item)  // Last item without comma
)
```

### Pattern: Left-associative binary operator

```javascript
prec.left(1, seq(
  field('left', $._expr),
  field('operator', '+'),
  field('right', $._expr)
))
```

### Pattern: Right-associative operator

```javascript
prec.right(2, seq(
  field('base', $._expr),
  field('operator', '^'),
  field('exponent', $._expr)
))
```

### Pattern: Postfix operator

```javascript
prec.left(seq(
  field('operand', $._expr),
  '!'  // Bang after expression
))
```

## Error Recovery

Tree-sitter has robust error recovery built-in:

```
contract @"broken"( = {  // Missing closing paren
  Nil
}
```

Parse tree with ERROR node:
```
(contract
  name: (quote ...)
  params: (ERROR)  ← Parser recovered here
  body: (block ...))
```

The grammar uses `MISSING` and `UNEXPECTED` markers to indicate errors while maintaining a valid AST structure.

## Resources

### Tree-Sitter Grammar Documentation
- [Creating parsers guide](https://tree-sitter.github.io/tree-sitter/creating-parsers)
- [Grammar DSL reference](https://tree-sitter.github.io/tree-sitter/creating-parsers#the-grammar-dsl)
- [Example grammars](https://github.com/tree-sitter)

### Rholang Language Reference
- [RChain documentation](https://rchain.atlassian.net/wiki/spaces/DOC/overview)
- [Rholang specification](https://github.com/rchain/rchain/tree/dev/rholang)

## Contributing

To contribute grammar improvements:

1. Fork [rholang-rs](https://github.com/F1R3FLY-io/rholang-rs)
2. Modify `rholang-tree-sitter/grammar.js`
3. Add test cases to `test/corpus/`
4. Run `tree-sitter test`
5. Submit a pull request

Grammar changes automatically propagate to:
- The Rust parser crate
- The language server
- This Emacs extension (after updating dependencies)
