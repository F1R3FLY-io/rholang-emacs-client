;;; rholang-lsp.el --- LSP integration for Rholang -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.3
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

(defcustom rholang-rnode-host "localhost"
  "Host for RNode instance."
  :type 'string
  :group 'rholang)

(defcustom rholang-rnode-port 40403
  "Port for RNode status endpoint."
  :type 'integer
  :group 'rholang)

(defun rholang-lsp--check-rnode ()
  "Check if RNode is running by querying the status endpoint."
  (condition-case nil
      (let* ((url (format "http://%s:%d/status" rholang-rnode-host rholang-rnode-port))
             (url-request-method "GET")
             (buffer (url-retrieve-synchronously url t)))
        (unwind-protect
            (with-current-buffer buffer
              (goto-char (point-min))
              (if (re-search-forward "HTTP/[0-9.]+ 200 OK" nil t)
                  (progn
                    (message "RNode detected at %s:%d" rholang-rnode-host rholang-rnode-port)
                    t)
                (message "RNode not running at %s:%d. Please start RNode." rholang-rnode-host rholang-rnode-port)
                nil))
          (when (buffer-live-p buffer)
            (kill-buffer buffer))))
    (error
     (message "Failed to connect to RNode at %s:%d. Please ensure RNode is running and accessible."
              rholang-rnode-host rholang-rnode-port)
     nil)))

(defun rholang-lsp-setup ()
  "Set up LSP for rholang-mode."
  (message "Attempting to set up LSP for rholang-mode")
  (when (and rholang-lsp-enable (rholang-lsp--check-rnode))
    (message "RNode check passed, registering LSP client for rholang-mode")
    ;; Set workspace root to file's directory
    (when (buffer-file-name)
      (lsp-workspace-folders-add (file-name-directory (buffer-file-name))))
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection
                       `(,rholang-lsp-server-path
                         "--no-color"
                         "--stdio"
                         ,(concat "--log-level=" rholang-lsp-log-level)
                         ,(concat "--client-process-id=" (number-to-string (emacs-pid)))))
      :major-modes '(rholang-mode)
      :server-id 'rholang-lsp
      :language-id "rholang"
      :notification-handlers
      (lsp-ht ("window/logMessage" 'lsp--on-message)
              ("textDocument/publishDiagnostics" 'lsp--on-diagnostics))
      :priority 0
      :multi-root nil))
    (message "Starting LSP for rholang-mode")
    (lsp-deferred)))

(provide 'rholang-lsp)

;;; rholang-lsp.el ends here
