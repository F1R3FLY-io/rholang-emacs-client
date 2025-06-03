;;; config.el --- Rholang Layer Configuration -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.3
;; Keywords: languages, rholang
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client
;; License: SSL

;;; Commentary:
;; Configuration for the Rholang Spacemacs layer.

;;; Code:

(spacemacs|define-custom-layout "@Rholang"
  :binding "r"
  :body
  (find-file (expand-file-name "~/.emacs.d/private/rholang-mode/rholang-mode.el"))
  (split-window-right)
  (find-file (expand-file-name "~/.emacs.d/private/rholang-mode/rholang-lsp.el")))

(defvar rholang-lsp-server-path "rholang-language-server"
  "Path to the rholang-language-server executable.")

(defvar rholang-lsp-log-level "info"
  "Log level for rholang-language-server communication.")

(defvar rholang-lsp-enable t
  "Enable LSP support for rholang-mode.")

(defvar rholang-rnode-host "localhost"
  "Host for RNode instance.")

(defvar rholang-rnode-port 40403
  "Port for RNode status endpoint.")

(defvar rholang-indent-size 2
  "Indentation size for Rholang code.")

;; Configure lsp-mode languageId for rholang-mode
(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration '(rholang-mode . "rholang"))
  (add-to-list 'lsp-language-id-configuration '("\\.rho\\'" . "rholang")))

(provide 'config)

;;; config.el ends here
