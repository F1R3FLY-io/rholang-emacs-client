;;; rholang-ts-mode.el --- Tree-sitter based major mode for Rholang -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages, rholang, tree-sitter
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client
;; License: SSL

;;; Commentary:
;; Tree-sitter based major mode for editing Rholang files.
;; Requires Emacs 29.1 or later with tree-sitter support.
;; The tree-sitter grammar for Rholang must be installed.

;;; Code:

(require 'treesit)
(require 'rholang-lsp)

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-node-child-by-field-name "treesit.c")

(defgroup rholang-ts nil
  "Tree-sitter based major mode for Rholang."
  :group 'languages
  :prefix "rholang-ts-")

(defcustom rholang-ts-indent-offset 2
  "Number of spaces for each indentation step in `rholang-ts-mode'."
  :type 'integer
  :group 'rholang-ts)

;;; Font Lock

(defvar rholang-ts--font-lock-settings
  (treesit-font-lock-rules
   :language 'rholang
   :feature 'comment
   '((line_comment) @font-lock-comment-face
     (block_comment) @font-lock-comment-face)

   :language 'rholang
   :feature 'keyword
   '(["contract" "for" "in" "if" "else" "match" "select" "new" "let" "bundle"]
     @font-lock-keyword-face

     ;; Word-based operators
     ["or" "and" "matches" "not"] @font-lock-keyword-face

     ;; Bundle keywords
     [(bundle_write) (bundle_read) (bundle_equiv) (bundle_read_write)]
     @font-lock-preprocessor-face)

   :language 'rholang
   :feature 'operator
   '(["|" "!?" "==" "!=" "<" "<=" ">" ">=" "+" "++" "-" "--" "*" "/"
      "%" "%%" "~" "\\/" "/\\" "<-" "<<-" "<=" "?!" "=>" ":" "=" "&"]
     @font-lock-operator-face

     (send_single) @font-lock-operator-face
     (send_multiple) @font-lock-operator-face
     (var_ref_kind) @font-lock-operator-face

     ;; Special operators in context
     (quote "@" @font-lock-operator-face)
     (eval "*" @font-lock-operator-face))

   :language 'rholang
   :feature 'literal
   '((bool_literal) @font-lock-constant-face
     (long_literal) @font-lock-number-face
     (string_literal) @font-lock-string-face
     (uri_literal) @font-lock-string-face
     (nil) @font-lock-constant-face
     (unit) @font-lock-constant-face)

   :language 'rholang
   :feature 'type
   '((simple_type) @font-lock-type-face
     (set "Set" @font-lock-type-face))

   :language 'rholang
   :feature 'variable
   '((var) @font-lock-variable-name-face
     (wildcard) @font-lock-constant-face
     (var_ref var: (var) @font-lock-variable-use-face))

   :language 'rholang
   :feature 'function
   '(;; Contract definitions
     (contract name: (quote) @font-lock-function-name-face)
     (contract name: (var) @font-lock-function-name-face)
     (contract name: (wildcard) @font-lock-function-name-face)

     ;; Method calls
     (method name: (var) @font-lock-function-call-face)
     (method receiver: (_) @font-lock-variable-use-face)

     ;; Channels (quotes and evals)
     (quote) @font-lock-function-call-face
     (eval name: (_) @font-lock-variable-use-face)

     ;; Send operations
     (send channel: (_) @font-lock-function-call-face)
     (send_sync channel: (_) @font-lock-function-call-face))

   :language 'rholang
   :feature 'definition
   '(;; Name declarations
     (name_decl (var) @font-lock-variable-name-face)
     (name_decl uri: (uri_literal) @font-lock-string-face)

     ;; Receipts and bindings
     (linear_bind names: (names) @font-lock-variable-name-face)
     (repeated_bind names: (names) @font-lock-variable-name-face)
     (peek_bind names: (names) @font-lock-variable-name-face)

     ;; Let declarations
     (decl names: (names) @font-lock-variable-name-face)

     ;; Patterns
     (case pattern: (_) @font-lock-variable-name-face)
     (branch pattern: (_) @font-lock-variable-name-face))

   :language 'rholang
   :feature 'property
   '((key_value_pair key: (_) @font-lock-property-name-face))

   :language 'rholang
   :feature 'delimiter
   '(["(" ")" "{" "}" "[" "]"] @font-lock-bracket-face
     ["," ";" "." "..."] @font-lock-delimiter-face
     (pathmap "{|" @font-lock-bracket-face)
     (pathmap "|}" @font-lock-bracket-face)))
  "Tree-sitter font-lock settings for Rholang.")

;;; Indentation

(defvar rholang-ts--indent-rules
  `((rholang
     ;; No indent for top-level
     ((parent-is "source_file") column-0 0)

     ;; Indent blocks and collections
     ((node-is "}") parent-bol 0)
     ((node-is "]") parent-bol 0)
     ((node-is ")") parent-bol 0)
     ((node-is "|") parent-bol 0)
     ((parent-is "block") parent-bol rholang-ts-indent-offset)
     ((parent-is "list") parent-bol rholang-ts-indent-offset)
     ((parent-is "tuple") parent-bol rholang-ts-indent-offset)
     ((parent-is "set") parent-bol rholang-ts-indent-offset)
     ((parent-is "map") parent-bol rholang-ts-indent-offset)
     ((parent-is "pathmap") parent-bol rholang-ts-indent-offset)

     ;; Indent control structures
     ((parent-is "ifElse") parent-bol rholang-ts-indent-offset)
     ((parent-is "match") parent-bol rholang-ts-indent-offset)
     ((parent-is "choice") parent-bol rholang-ts-indent-offset)
     ((parent-is "contract") parent-bol rholang-ts-indent-offset)
     ((parent-is "input") parent-bol rholang-ts-indent-offset)
     ((parent-is "new") parent-bol rholang-ts-indent-offset)
     ((parent-is "let") parent-bol rholang-ts-indent-offset)
     ((parent-is "bundle") parent-bol rholang-ts-indent-offset)

     ;; Indent case and branch bodies
     ((parent-is "case") parent-bol rholang-ts-indent-offset)
     ((parent-is "branch") parent-bol rholang-ts-indent-offset)

     ;; Indent receipts and bindings
     ((parent-is "receipts") parent-bol rholang-ts-indent-offset)
     ((parent-is "linear_bind") parent-bol rholang-ts-indent-offset)
     ((parent-is "repeated_bind") parent-bol rholang-ts-indent-offset)
     ((parent-is "peek_bind") parent-bol rholang-ts-indent-offset)

     ;; Indent declarations
     ((parent-is "name_decls") parent-bol rholang-ts-indent-offset)
     ((parent-is "linear_decls") parent-bol rholang-ts-indent-offset)
     ((parent-is "conc_decls") parent-bol rholang-ts-indent-offset)

     ;; Indent messages/inputs
     ((parent-is "inputs") parent-bol rholang-ts-indent-offset)
     ((parent-is "messages") parent-bol rholang-ts-indent-offset)
     ((parent-is "args") parent-bol rholang-ts-indent-offset)

     ;; Branch alignment for par/case/branch
     ((node-is "=>") parent-bol 0)

     ;; Default: match parent indentation
     (no-node parent-bol 0)))
  "Tree-sitter indentation rules for Rholang.")

;;; Navigation (Imenu)

(defun rholang-ts--defun-name (node)
  "Return the defun name of NODE.
Return nil if there is no name or if NODE is not a defun node."
  (pcase (treesit-node-type node)
    ("contract"
     (let ((name-node (treesit-node-child-by-field-name node "name")))
       (when name-node
         (treesit-node-text name-node t))))
    ("new"
     "new")
    (_ nil)))

(defvar rholang-ts--imenu-settings
  '(("Contract" "\\`contract\\'" nil nil))
  "Imenu settings for `rholang-ts-mode'.")

;;; Mode Definition

;;;###autoload
(define-derived-mode rholang-ts-mode prog-mode "Rholang[TS]"
  "Major mode for editing Rholang files using tree-sitter.

\\{rholang-ts-mode-map}"
  :group 'rholang-ts
  :syntax-table rholang-mode-syntax-table

  ;; Check if tree-sitter is available
  (unless (treesit-ready-p 'rholang)
    (error "Tree-sitter for Rholang is not available.  Please install the Rholang tree-sitter grammar"))

  ;; Create parser
  (treesit-parser-create 'rholang)

  ;; Comments
  (setq-local comment-start "// ")
  (setq-local comment-start-skip "//+\\s-*")
  (setq-local comment-end "")

  ;; Indentation
  (setq-local treesit-simple-indent-rules rholang-ts--indent-rules)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width rholang-ts-indent-offset)

  ;; Font-lock
  (setq-local treesit-font-lock-settings rholang-ts--font-lock-settings)
  (setq-local treesit-font-lock-feature-list
              '((comment)
                (keyword literal)
                (type operator variable)
                (function definition property delimiter)))

  ;; Imenu
  (setq-local treesit-simple-imenu-settings rholang-ts--imenu-settings)

  ;; Navigation
  (setq-local treesit-defun-type-regexp
              (rx (or "contract" "new" "let")))
  (setq-local treesit-defun-name-function #'rholang-ts--defun-name)

  ;; Enable tree-sitter
  (treesit-major-mode-setup)

  ;; Enable LSP if available
  (when (and (fboundp 'lsp) rholang-lsp-enable)
    (condition-case err
        (rholang-lsp-setup)
      (error (message "LSP setup failed: %s" err)))))

;; Auto-detect .rho files for tree-sitter mode
(when (treesit-ready-p 'rholang)
  (add-to-list 'auto-mode-alist '("\\.rho\\'" . rholang-ts-mode)))

(provide 'rholang-ts-mode)

;;; rholang-ts-mode.el ends here
