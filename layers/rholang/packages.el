;;; packages.el --- Rholang Layer packages File for Spacemacs -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.3
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client

;;; Commentary:
;; Package configuration for the Rholang Spacemacs layer.

;;; Code:

(defconst rholang-packages
  '(rholang-mode))

(defun rholang/init-rholang-mode ()
  "Initialize rholang-mode."
  (use-package rholang-mode
    :defer t
    :mode ("\\.rho\\'" . rholang-mode)
    :init
    (progn
      (setq rholang-lsp-server-path rholang-lsp-server-path
            ;; rholang-lsp-trace-server rholang-lsp-trace-server
            rholang-lsp-log-level rholang-lsp-log-level
            rholang-lsp-enable rholang-lsp-enable
            rholang-rnode-host rholang-rnode-host
            rholang-rnode-port rholang-rnode-port
            rholang-indent-size rholang-indent-size)
      (spacemacs/set-leader-keys-for-major-mode 'rholang-mode
        "l" 'lsp
        "d" 'lsp-find-definition
        "r" 'lsp-find-references
        "h" 'lsp-describe-thing-at-point))))

(provide 'packages)

;;; packages.el ends here
