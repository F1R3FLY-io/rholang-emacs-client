;;; rholang-syntax.el --- Syntax highlighting for Rholang -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.3
;; Package-Requires: ((emacs "25.1") (lsp-mode "8.0.0"))
;; Keywords: languages, rholang, lsp
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client
;; License: SSL

;;; Commentary:
;; Syntax highlighting definitions for Rholang, based on VSCode and Neovim extensions.

;;; Code:

(defconst rholang-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?` "\"" table)
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)
    table)
  "Syntax table for `rholang-mode'.")

(defconst rholang-font-lock-keywords
  `(
    ;; Keywords
    ("\\b\\(contract\\|for\\|in\\|if\\|else\\|match\\|new\\|select\\|case\\|bundle\\|bundle0\\|bundle+\\|bundle-\\)\\b" . font-lock-keyword-face)
    ;; Constants
    ("\\b\\(_\\|Nil\\|true\\|false\\|Bool\\|Int\\|String\\|ByteArray\\|Uri\\|not\\|matches\\|and\\|or\\|Set\\)\\b" . font-lock-constant-face)
    ;; Operators
    ("\\(?:||\\||&\\|/\\\\\\|\\\\/\\|~\\|/\\|%%\\|+\\|-\\|++\\|<=\\|<\\|>=\\|>\\|==\\|!=\\|<-\\|=>\\|\\.\\.\\.\\)" . font-lock-builtin-face)
    ;; Channels
    ("\\@" . font-lock-builtin-face)
    ;; Numbers
    ("-?\\b[0-9]+\\b" . font-lock-constant-face)
    ;; Strings
    ("\"\\(\\\\.\\|[^\"\\]\\)*\"" . font-lock-string-face)
    ;; URIs/System procs
    ("`\\(\\\\.\\|[^`\\]\\)*`" . font-lock-string-face)
    ;; Comments
    ("//.*$" . font-lock-comment-face)
    ("/\\*\\(.\\|\n\\)*?\\*/" . font-lock-comment-face))
  "Font-lock keywords for `rholang-mode'.")

(provide 'rholang-syntax)

;;; rholang-syntax.el ends here
