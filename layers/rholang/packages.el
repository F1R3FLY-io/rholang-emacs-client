;;; packages.el --- Rholang Layer packages File for Spacemacs -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.4
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client

;;; Commentary:
;; Package configuration for the Rholang Spacemacs layer.

;;; Code:

(defconst rholang-packages
  '(rholang-mode
    ;; Optional packages for enhanced LSP features
    (lsp-ui :toggle (configuration-layer/package-used-p 'lsp-ui))
    (lsp-treemacs :toggle (configuration-layer/package-used-p 'lsp-treemacs))
    (flycheck :toggle (configuration-layer/package-used-p 'flycheck))))

(defun rholang/init-rholang-mode ()
  "Initialize rholang-mode."
  (use-package rholang-mode
    :defer t
    :mode ("\\.rho\\'" . rholang-mode)
    :init
    (progn
      (setq rholang-lsp-server-path rholang-lsp-server-path
            rholang-lsp-log-level rholang-lsp-log-level
            rholang-lsp-enable rholang-lsp-enable
            rholang-indent-size rholang-indent-size)
      ;; Comprehensive LSP keybindings following Spacemacs conventions
      (spacemacs/set-leader-keys-for-major-mode 'rholang-mode
        ;; Core bindings
        "l"   'lsp                              ; Start LSP
        "D"   'rholang-doctor                   ; Run diagnostics tool

        ;; Navigation (prefix: g)
        "gd"  'lsp-find-definition              ; Go to definition
        "gr"  'lsp-find-references              ; Find references
        "gi"  'lsp-find-implementation          ; Find implementation
        "gt"  'lsp-find-type-definition         ; Find type definition
        "gD"  'lsp-find-declaration             ; Find declaration

        ;; Peek Navigation (prefix: G - requires lsp-ui)
        "Gd"  'lsp-ui-peek-find-definitions     ; Peek definitions
        "Gr"  'lsp-ui-peek-find-references      ; Peek references
        "Gi"  'lsp-ui-peek-find-implementation  ; Peek implementation

        ;; Refactoring (prefix: r)
        "rr"  'lsp-rename                       ; Rename symbol
        "ro"  'lsp-organize-imports             ; Organize imports

        ;; Code Actions (prefix: a)
        "aa"  'lsp-execute-code-action          ; Execute code action
        "al"  'lsp-avy-lens                     ; Avy lens actions

        ;; Help/Documentation (prefix: h)
        "hh"  'lsp-describe-thing-at-point      ; Describe at point
        "hs"  'lsp-signature-activate           ; Show signature
        "hg"  'lsp-ui-doc-glance                ; Peek documentation (lsp-ui)

        ;; Formatting (prefix: =)
        "=="  'lsp-format-buffer                ; Format buffer
        "=r"  'lsp-format-region                ; Format region

        ;; Workspace Management (prefix: w)
        "wr"  'lsp-workspace-restart            ; Restart workspace
        "wq"  'lsp-workspace-shutdown           ; Shutdown workspace
        "wd"  'lsp-describe-session             ; Describe session
        "ws"  'lsp-workspace-show-log           ; Show workspace log

        ;; Toggles (prefix: T)
        "Tl"  'lsp-lens-mode                    ; Toggle code lens
        "Tb"  'lsp-headerline-breadcrumb-mode   ; Toggle breadcrumb
        "Th"  'lsp-ui-doc-mode                  ; Toggle hover docs (lsp-ui)
        "Ts"  'lsp-ui-sideline-mode             ; Toggle sideline (lsp-ui)

        ;; Errors/Diagnostics (prefix: e)
        "en"  'flycheck-next-error              ; Next error
        "ep"  'flycheck-previous-error          ; Previous error
        "el"  'lsp-treemacs-errors-list         ; List errors (lsp-treemacs)
        "eb"  'flycheck-buffer                  ; Check buffer

        ;; Treemacs Integration (prefix: t - requires lsp-treemacs)
        "ts"  'lsp-treemacs-symbols             ; Show symbols
        "tc"  'lsp-treemacs-call-hierarchy      ; Call hierarchy
        "tt"  'lsp-treemacs-type-hierarchy))))  ; Type hierarchy

(provide 'packages)

;;; packages.el ends here
