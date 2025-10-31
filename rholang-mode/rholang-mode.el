;;; rholang-mode.el --- Major mode for editing Rholang files -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.4
;; Package-Requires: ((emacs "25.1") (lsp-mode "8.0.0"))
;; Keywords: languages, rholang, lsp
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client
;; License: SSL

;;; Commentary:
;; This package provides a major mode for editing Rholang files with LSP support.
;; It requires a running RNode instance from F1R3FLY-io and the rholang-language-server.

;;; Code:

(require 'rholang-syntax)
(require 'rholang-lsp)
(require 'rholang-doctor)
(require 'smie)

(defgroup rholang nil
  "Customization group for Rholang language support."
  :group 'languages
  :prefix "rholang-")

(defcustom rholang-indent-size 2
  "Indentation size for Rholang code."
  :type 'integer
  :group 'rholang)

(defconst rholang-smie-grammar
  (smie-prec2->grammar
   (smie-bnf->prec2
    '((id)
      (exp
       (id)
       ("@" id)
       (exp "!" exp)
       (exp "<-" exp))
      (exp-list
       (exp)
       (exp "," exp-list))
      (stmt
       ("new" ids "in" block)
       ("for" "(" exp-list ")" block)
       ("contract" id "(" exp-list ")" "=" block)
       ("if" "(" exp-list ")" block)
       ("if" "(" exp-list ")" block "else" block)
       (exp))
      (ids
       (id)
       (id "," ids))
      (block
       ("{" stmts "}"))
      (stmts
       (stmt)
       (stmt ";" stmts)))
    '((assoc ";") (assoc ",") (assoc "<-") (assoc "!")))))

(defun rholang-smie-rules (kind token)
  "SMIE indentation rules for Rholang.
KIND is the rule type (e.g., :elem, :list-intro), TOKEN is the current token."
  (pcase (cons kind token)
    (`(:elem . basic) rholang-indent-size)  ; Basic indentation step
    (`(:list-intro . ,(or "new" "for" "contract" "if" ",")) t)  ; Keywords and comma introduce lists
    (`(:before . "{")
     (smie-rule-parent))  ; Align { with parent
    (`(:after . "{")
     (let ((parent-col (smie-rule-parent)))
       (if (numberp parent-col)
           (+ parent-col rholang-indent-size)
         rholang-indent-size)))  ; Indent one level after {
    (`(:before . "}")
     (smie-rule-parent))  ; Align } with parent
    (`(:after . "}")
     (smie-rule-parent))  ; Reset indent after } to parent
    (`(:after . ")")
     (smie-rule-parent))  ; Reset indent after ) to parent
    (`(:after . "=")
     rholang-indent-size)  ; Indent after =
    (`(:after . "in")
     rholang-indent-size)  ; Indent after in
    (`(:before . ";")
     (smie-rule-parent))  ; Align after ;
    (`(:before . ")")
     (smie-rule-parent))  ; Align ) with (
    (`(:before . ,(or "stmt" "stmts"))
     (if (smie-rule-parent-p "{")
         (let ((parent-col (smie-rule-parent)))
           (if (numberp parent-col)
               (+ parent-col rholang-indent-size)
             rholang-indent-size))  ; Align statements in block
       (smie-rule-parent)))  ; Align outside block
    (`(:after . ",")
     0)))  ; No indent after comma

(defun rholang-smie-forward-token ()
  "Forward token lexer for SMIE."
  (forward-comment (point-max))
  (cond
   ((looking-at "\\<\\(new\\|for\\|contract\\|if\\|else\\|in\\)\\>")
    (goto-char (match-end 0))
    (match-string 0))
   ((looking-at "@")
    (forward-char 1)
    "@")
   ((looking-at "[a-zA-Z_][a-zA-Z0-9_]*")
    (goto-char (match-end 0))
    "id")
   ((looking-at "[{}();!<=]")
    (forward-char 1)
    (match-string 0))
   ((looking-at ",")
    (forward-char 1)
    ",")
   (t
    (forward-char 1)
    nil)))

(defun rholang-smie-backward-token ()
  "Backward token lexer for SMIE."
  (forward-comment (- (point)))
  (cond
   ((looking-back "\\<\\(new\\|for\\|contract\\|if\\|else\\|in\\)\\>" (- (point) 6))
    (goto-char (match-beginning 0))
    (match-string 0))
   ((looking-back "@" (- (point) 1))
    (backward-char 1)
    "@")
   ((looking-back "[a-zA-Z_][a-zA-Z0-9_]*" (- (point) 1))
    (goto-char (match-beginning 0))
    "id")
   ((looking-back "[{}();!<=]" (- (point) 1))
    (backward-char 1)
    (match-string 0))
   ((looking-back "," (- (point) 1))
    (backward-char 1)
    ",")
   (t
    (backward-char 1)
    nil)))

(defun rholang-newline-and-indent ()
  "Insert a newline and indent according to SMIE."
  (interactive)
  (newline)
  (smie-indent-line)
  (beginning-of-line)
  (skip-chars-forward " \t"))

;;;###autoload
(define-derived-mode rholang-mode prog-mode "Rholang"
  "Major mode for editing Rholang files."
  :group 'rholang
  (unless (and (boundp 'rholang-font-lock-keywords) rholang-font-lock-keywords)
    (message "Warning: rholang-font-lock-keywords is nil, check rholang-syntax.el"))
  (set (make-local-variable 'syntax-table) rholang-mode-syntax-table)
  (setq-local comment-start "// ")
  (setq-local comment-start-skip "//+\\s*")
  (setq-local comment-end "")
  (setq-local tab-width rholang-indent-size)
  (setq-local indent-tabs-mode nil)
  (when rholang-font-lock-keywords
    (setq-local font-lock-defaults '(rholang-font-lock-keywords)))
  ;; Enable SMIE
  (condition-case err
      (smie-setup rholang-smie-grammar #'rholang-smie-rules
                  :forward-token #'rholang-smie-forward-token
                  :backward-token #'rholang-smie-backward-token)
    (error (message "SMIE setup failed: %s" err)))
  ;; Bind RET for cursor positioning
  (local-set-key (kbd "RET") #'rholang-newline-and-indent)
  ;; Enable smartparens if available
  (when (featurep 'smartparens)
    (require 'smartparens)
    (sp-local-pair 'rholang-mode "{" "}"
                   :post-handlers '(:add
                                    (lambda (_id action _context)
                                      (when (eq action 'insert)
                                        (save-excursion
                                          (sp-forward-sexp)
                                          (beginning-of-line)
                                          (smie-indent-line)))))))
  ;; Enable LSP if available
  (when (and (fboundp 'lsp) rholang-lsp-enable)
    (condition-case err
        (rholang-lsp-setup)
      (error (message "LSP setup failed: %s" err)))))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.rho\\'" . rholang-mode) t)

(provide 'rholang-mode)

;;; rholang-mode.el ends here
