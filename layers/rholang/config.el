;;; config.el --- Rholang Layer Configuration -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.4
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

(defvar rholang-indent-size 2
  "Indentation size for Rholang code.")

(defvar rholang-use-tree-sitter nil
  "When non-nil, use tree-sitter based mode (rholang-ts-mode) instead of traditional rholang-mode.
Requires Emacs 29.1+ with tree-sitter support and the Rholang grammar installed.")

(defvar rholang-use-rnode nil
  "Use RNode for diagnostics via gRPC.
When non-nil, the language server will communicate with RNode via gRPC.
When nil, the embedded Rust parser/interpreter will be used.")

(defvar rholang-grpc-host "localhost"
  "RNode gRPC server host.
Used when `rholang-use-rnode' is non-nil.")

(defvar rholang-grpc-port 40402
  "RNode gRPC server port.
Used when `rholang-use-rnode' is non-nil.")

;; Configure lsp-mode languageId for rholang-mode
(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration '(rholang-mode . "rholang"))
  (add-to-list 'lsp-language-id-configuration '(rholang-ts-mode . "rholang"))
  (add-to-list 'lsp-language-id-configuration '("\\.rho\\'" . "rholang")))

(provide 'config)

;;; config.el ends here
