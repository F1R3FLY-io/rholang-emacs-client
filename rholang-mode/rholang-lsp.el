;;; rholang-lsp.el --- LSP integration for Rholang -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.4
;; Package-Requires: ((emacs "25.1") (lsp-mode "8.0.0"))
;; Keywords: languages, rholang, lsp
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client
;; License: SSL

;;; Commentary:
;; Configures lsp-mode for rholang-language-server, with a check for RNode.

;;; Code:

(require 'lsp-mode)
(require 'url)

(defgroup rholang nil
  "Customization group for Rholang language support."
  :group 'languages
  :prefix "rholang-")

(defcustom rholang-lsp-server-path "rholang-language-server"
  "Path to the rholang-language-server executable."
  :type 'string
  :group 'rholang)

(defcustom rholang-lsp-log-level "info"
  "Log level for rholang-language-server communication."
  :type '(choice (const "error") (const "warn") (const "info") (const "debug") (const "trace"))
  :group 'rholang)

(defcustom rholang-lsp-enable t
  "Enable LSP support for rholang-mode."
  :type 'boolean
  :group 'rholang)

(defcustom rholang-use-rnode nil
  "Use RNode for diagnostics via gRPC.
When non-nil, the language server will communicate with RNode via gRPC.
When nil, the embedded Rust parser/interpreter will be used."
  :type 'boolean
  :group 'rholang)

(defcustom rholang-grpc-host "localhost"
  "RNode gRPC server host.
Used when `rholang-use-rnode' is non-nil."
  :type 'string
  :group 'rholang)

(defcustom rholang-grpc-port 40402
  "RNode gRPC server port.
Used when `rholang-use-rnode' is non-nil."
  :type 'integer
  :group 'rholang)

(defun rholang-lsp-setup ()
  "Set up LSP for rholang-mode."
  (message "Attempting to set up LSP for rholang-mode")
  (when rholang-lsp-enable
    (message "Registering LSP client for rholang-mode")
    ;; Enable semantic tokens (context-aware highlighting)
    (setq-local lsp-semantic-tokens-enable t)
    ;; Set workspace root to file's directory
    (when (buffer-file-name)
      (lsp-workspace-folders-add (file-name-directory (buffer-file-name))))

    ;; Build command based on RNode configuration
    (let* ((base-cmd `(,rholang-lsp-server-path
                       "--no-color"
                       "--stdio"
                       ,(concat "--log-level=" rholang-lsp-log-level)
                       ,(concat "--client-process-id=" (number-to-string (emacs-pid)))))
           (lsp-cmd (if rholang-use-rnode
                        ;; When using RNode, pass gRPC host and port, do NOT pass --no-rnode
                        (append base-cmd
                                `("--grpc-host" ,rholang-grpc-host
                                  "--grpc-port" ,(number-to-string rholang-grpc-port)))
                      ;; When not using RNode, pass --no-rnode flag
                      (append base-cmd '("--no-rnode")))))
      (message "Rholang LSP command: %s" (mapconcat 'identity lsp-cmd " "))
      (when rholang-use-rnode
        (message "Rholang LSP: Using RNode at %s:%d" rholang-grpc-host rholang-grpc-port))
      (unless rholang-use-rnode
        (message "Rholang LSP: Using embedded Rust parser/interpreter"))
      (lsp-register-client
       (make-lsp-client
        :new-connection (lsp-stdio-connection lsp-cmd)
        :major-modes '(rholang-mode)
        :server-id 'rholang-lsp
        :language-id "rholang"
        :notification-handlers
        (lsp-ht ("window/logMessage" 'lsp--on-message)
                ("textDocument/publishDiagnostics" 'lsp--on-diagnostics))
        :priority 0
        :multi-root nil))
      (message "Starting LSP for rholang-mode")
      (lsp-deferred))))

(provide 'rholang-lsp)

;;; rholang-lsp.el ends here
