;;; rholang-doctor.el --- Diagnostic utilities for Rholang mode -*- lexical-binding: t; -*-

;; Author: Dylon Edwards <dylon@vinarytree.io>
;; Version: 0.0.4
;; Package-Requires: ((emacs "25.1"))
;; Keywords: languages, rholang, diagnostics
;; URL: https://github.com/F1R3FLY-io/rholang-emacs-client
;; License: SSL

;;; Commentary:
;; Provides diagnostic utilities for troubleshooting Rholang mode setup.
;; Run `M-x rholang-doctor' to check your installation.

;;; Code:

(require 'lsp-mode nil t)

(defvar rholang-doctor-buffer-name "*Rholang Doctor*"
  "Buffer name for diagnostic output.")

(defun rholang-doctor--log (level message)
  "Log a diagnostic MESSAGE at LEVEL (ok, warn, error, info)."
  (with-current-buffer (get-buffer-create rholang-doctor-buffer-name)
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (insert
       (pcase level
         ('ok    (propertize "✓ OK:    " 'face '(:foreground "green")))
         ('warn  (propertize "⚠ WARN:  " 'face '(:foreground "yellow")))
         ('error (propertize "✗ ERROR: " 'face '(:foreground "red")))
         ('info  (propertize "ℹ INFO:  " 'face '(:foreground "cyan")))
         (_      "        "))
       message "\n"))))

(defun rholang-doctor--section (title)
  "Start a new diagnostic section with TITLE."
  (with-current-buffer (get-buffer-create rholang-doctor-buffer-name)
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (insert "\n" (propertize title 'face 'bold) "\n"
              (make-string (length title) ?─) "\n"))))

(defun rholang-doctor--check-emacs-version ()
  "Check if Emacs version meets requirements."
  (rholang-doctor--section "Checking Emacs Version")
  (let ((version-string (format "%d.%d" emacs-major-version emacs-minor-version)))
    (if (version<= "25.1" emacs-version)
        (rholang-doctor--log 'ok (format "Emacs %s meets requirement (>= 25.1)" version-string))
      (rholang-doctor--log 'error (format "Emacs %s is too old. Requires >= 25.1" version-string)))))

(defun rholang-doctor--check-lsp-mode ()
  "Check if lsp-mode is installed."
  (rholang-doctor--section "Checking Dependencies")
  (if (featurep 'lsp-mode)
      (rholang-doctor--log 'ok "lsp-mode is installed")
    (rholang-doctor--log 'error "lsp-mode is not installed. Install it via your package manager.")))

(defun rholang-doctor--check-tree-sitter ()
  "Check tree-sitter support (Emacs 29.1+)."
  (if (and (fboundp 'treesit-available-p) (treesit-available-p))
      (progn
        (rholang-doctor--log 'ok (format "Tree-sitter is available (Emacs %d.%d)"
                                         emacs-major-version emacs-minor-version))
        (if (and (fboundp 'treesit-ready-p) (treesit-ready-p 'rholang t))
            (rholang-doctor--log 'ok "Rholang tree-sitter grammar is installed")
          (rholang-doctor--log 'warn "Rholang tree-sitter grammar is not installed. See TREE-SITTER.md for setup.")))
    (rholang-doctor--log 'info "Tree-sitter not available (requires Emacs 29.1+)")))

(defun rholang-doctor--check-executable (cmd)
  "Check if CMD is executable."
  (if (executable-find cmd)
      (rholang-doctor--log 'ok (format "%s is installed and executable at: %s"
                                       cmd (executable-find cmd)))
    (rholang-doctor--log 'error (format "%s is not found in PATH" cmd))))

(defun rholang-doctor--check-lsp-config ()
  "Check LSP configuration for Rholang."
  (rholang-doctor--section "Checking LSP Configuration")

  ;; Check if LSP is enabled
  (if (boundp 'rholang-lsp-enable)
      (if rholang-lsp-enable
          (rholang-doctor--log 'ok "LSP is enabled (rholang-lsp-enable = t)")
        (rholang-doctor--log 'warn "LSP is disabled (rholang-lsp-enable = nil)"))
    (rholang-doctor--log 'warn "rholang-lsp-enable is not defined"))

  ;; Report RNode mode
  (when (boundp 'rholang-use-rnode)
    (if rholang-use-rnode
        (let ((host (if (boundp 'rholang-grpc-host) rholang-grpc-host "localhost"))
              (port (if (boundp 'rholang-grpc-port) rholang-grpc-port 40402)))
          (rholang-doctor--log 'info
                               (format "LSP mode: Using legacy RNode via gRPC at %s:%d" host port)))
      (rholang-doctor--log 'info "LSP mode: Using embedded Rust parser/interpreter (--no-rnode)")))

  ;; Check language server executable
  (let ((lsp-path (if (boundp 'rholang-lsp-server-path)
                      rholang-lsp-server-path
                    "rholang-language-server")))
    (rholang-doctor--check-executable lsp-path))

  ;; Check if LSP is running
  (if (and (featurep 'lsp-mode) (fboundp 'lsp-workspaces))
      (let ((workspaces (lsp-workspaces)))
        (if workspaces
            (rholang-doctor--log 'ok (format "LSP workspace is active (%d workspace(s))"
                                             (length workspaces)))
          (rholang-doctor--log 'warn "No LSP workspace active. Open a .rho file to start LSP.")))
    (rholang-doctor--log 'info "LSP mode not loaded. Open a .rho file to initialize.")))

(defun rholang-doctor--check-mode-config ()
  "Check Rholang mode configuration."
  (rholang-doctor--section "Checking Rholang Mode Configuration")

  ;; Check if rholang-mode is loaded
  (if (featurep 'rholang-mode)
      (rholang-doctor--log 'ok "rholang-mode is loaded")
    (rholang-doctor--log 'warn "rholang-mode is not loaded. It will load when you open a .rho file."))

  ;; Check tree-sitter mode availability
  (if (featurep 'rholang-ts-mode)
      (rholang-doctor--log 'ok "rholang-ts-mode is loaded (tree-sitter support)")
    (if (version<= "29.1" emacs-version)
        (rholang-doctor--log 'info "rholang-ts-mode is not loaded. Set rholang-use-tree-sitter = t to enable.")
      (rholang-doctor--log 'info "rholang-ts-mode requires Emacs 29.1+")))

  ;; Check indent size
  (when (boundp 'rholang-indent-size)
    (rholang-doctor--log 'info (format "Indentation size: %d" rholang-indent-size)))

  ;; Check tree-sitter preference
  (when (boundp 'rholang-use-tree-sitter)
    (if rholang-use-tree-sitter
        (rholang-doctor--log 'info "Configured to use tree-sitter mode (rholang-use-tree-sitter = t)")
      (rholang-doctor--log 'info "Configured to use traditional mode (rholang-use-tree-sitter = nil)"))))

(defun rholang-doctor--check-file-associations ()
  "Check if .rho files are associated with rholang-mode."
  (rholang-doctor--section "Checking File Associations")

  (let ((rho-mode (cdr (assoc "\\.rho\\'" auto-mode-alist))))
    (if rho-mode
        (rholang-doctor--log 'ok (format ".rho files are associated with: %s" rho-mode))
      (rholang-doctor--log 'error ".rho files are not associated with any mode"))))

(defun rholang-doctor--check-optional-packages ()
  "Check optional package integrations."
  (rholang-doctor--section "Checking Optional Packages")

  ;; Check smartparens
  (if (featurep 'smartparens)
      (rholang-doctor--log 'ok "smartparens is installed (optional)")
    (rholang-doctor--log 'info "smartparens not installed (optional, for enhanced brace handling)"))

  ;; Check company-mode
  (if (featurep 'company)
      (rholang-doctor--log 'ok "company-mode is installed (optional, for completion)")
    (rholang-doctor--log 'info "company-mode not installed (optional, for auto-completion)")))

;;;###autoload
(defun rholang-doctor ()
  "Run diagnostic checks for Rholang mode installation.
Opens a buffer with detailed diagnostic information about the
Rholang mode setup, including Emacs version, dependencies,
LSP configuration, and RNode mode settings."
  (interactive)

  ;; Create/clear the diagnostic buffer
  (with-current-buffer (get-buffer-create rholang-doctor-buffer-name)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert (propertize "Rholang Mode Diagnostics\n" 'face 'bold)
              (propertize "═══════════════════════════\n\n" 'face 'bold))
      (insert "Run this command to check your Rholang mode installation.\n")
      (insert "If you encounter issues, refer to the messages below.\n")))

  ;; Run all checks
  (rholang-doctor--check-emacs-version)
  (rholang-doctor--check-lsp-mode)
  (rholang-doctor--check-tree-sitter)
  (rholang-doctor--check-lsp-config)
  (rholang-doctor--check-mode-config)
  (rholang-doctor--check-file-associations)
  (rholang-doctor--check-optional-packages)

  ;; Add summary
  (with-current-buffer (get-buffer-create rholang-doctor-buffer-name)
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (insert "\n" (propertize "Diagnostics Complete\n" 'face 'bold))
      (insert (propertize "════════════════════\n" 'face 'bold))
      (insert "\nFor more information, see:\n")
      (insert "  - README.md for installation and configuration\n")
      (insert "  - TREE-SITTER.md for tree-sitter setup (Emacs 29.1+)\n")
      (insert "\nTo re-run diagnostics: M-x rholang-doctor\n"))

    ;; Make buffer read-only
    (special-mode)
    (goto-char (point-min)))

  ;; Display the buffer
  (display-buffer rholang-doctor-buffer-name))

(provide 'rholang-doctor)

;;; rholang-doctor.el ends here
