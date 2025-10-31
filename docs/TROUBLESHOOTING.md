# Troubleshooting Guide for Rholang Emacs Extension

## Common Issues and Solutions

### Issue: .rho Files Open in fundamental-mode

**Symptoms**:
- Opening `.rho` files shows no syntax highlighting
- Mode line shows `Fundamental` instead of `Rholang`
- Running `M-x lsp-mode` gives error: "no language servers supporting current mode"

**Cause**: Configuration conflict between `dotspacemacs-additional-packages` and the Rholang layer.

**Solution**:

**❌ WRONG Configuration** (causes the issue):
```elisp
;; In dotspacemacs-additional-packages
dotspacemacs-additional-packages
'(
  ;; ... other packages ...
  (rholang-mode :location "~/.emacs.d/private/rholang-mode")  ; ← REMOVE THIS
  ;; ... other packages ...
  )

;; Also in dotspacemacs-configuration-layers
dotspacemacs-configuration-layers
'(
  rholang  ; ← Layer also tries to load rholang-mode
)
```

**✅ CORRECT Configuration**:
```elisp
;; In dotspacemacs-additional-packages - DO NOT include rholang-mode
dotspacemacs-additional-packages
'(
  ;; ... other packages, but NOT rholang-mode ...
  )

;; In dotspacemacs-configuration-layers - Let the layer handle it
dotspacemacs-configuration-layers
'(
  (rholang :variables
           rholang-lsp-enable t
           rholang-use-rnode nil
           rholang-indent-size 2)
)
```

**Fix Steps**:
1. Open `~/.spacemacs`
2. Find `dotspacemacs-additional-packages`
3. **Remove** the line: `(rholang-mode :location "~/.emacs.d/private/rholang-mode")`
4. Ensure `rholang` layer is in `dotspacemacs-configuration-layers`
5. Reload: `SPC f e R` or restart Emacs

### Issue: LSP Server Not Found

**Symptoms**:
- Error: "rholang-language-server: command not found"
- LSP doesn't start when opening `.rho` files

**Solutions**:

**Check 1**: Verify server is installed
```bash
which rholang-language-server
```

**Check 2**: Add to PATH or specify full path in `.spacemacs`
```elisp
(rholang :variables
         rholang-lsp-server-path "/full/path/to/rholang-language-server")
```

**Check 3**: Verify executable permissions
```bash
chmod +x /path/to/rholang-language-server
```

### Issue: RNode Connection Errors

**Symptoms**:
- Error: "Failed to connect to RNode at localhost:40402"
- Diagnostics show connection refused

**Solution 1**: Use Embedded Rust (Recommended)
```elisp
(rholang :variables
         rholang-use-rnode nil)  ; Use embedded Rust instead
```

**Solution 2**: Verify RNode is Running
```bash
# Check if RNode is running
curl http://localhost:40402

# Check gRPC port is open
netstat -tuln | grep 40402
```

**Solution 3**: Fix RNode Configuration
```elisp
(rholang :variables
         rholang-use-rnode t
         rholang-grpc-host "localhost"
         rholang-grpc-port 40402)  ; Make sure this matches RNode's port
```

### Issue: Tree-Sitter Grammar Not Found

**Symptoms**:
- Error: "Tree-sitter for Rholang is not available"
- `(treesit-ready-p 'rholang)` returns `nil`

**Solutions**:

**Check Emacs Version**:
```
M-x emacs-version  ; Must be 29.1+
```

**Check Tree-Sitter Support**:
```elisp
M-: (treesit-available-p)  ; Should return t
```

**Install Grammar**:
```elisp
;; Add to ~/.spacemacs in dotspacemacs/user-config
(with-eval-after-load 'treesit
  (add-to-list 'treesit-language-source-alist
               '(rholang "https://github.com/F1R3FLY-io/rholang-rs"
                         "main"
                         "rholang-tree-sitter"))
  (treesit-install-language-grammar 'rholang))
```

See [Tree-Sitter Quick Start](tree-sitter/QUICK-START.md) for detailed instructions.

### Issue: Wrong Indentation

**Symptoms**:
- TAB indents wrong number of spaces
- Code doesn't align properly

**Solutions**:

**Check Current Setting**:
```elisp
M-: rholang-indent-size  ; Shows current value
```

**Fix in .spacemacs**:
```elisp
(rholang :variables
         rholang-indent-size 2)  ; or 4, whatever you prefer
```

**Per-File Override** (add to top of .rho file):
```rholang
// -*- rholang-indent-size: 4; -*-
contract @"example"() = {
  // ... code with 4-space indent
}
```

### Issue: Keybindings Not Working

**Symptoms**:
- `SPC m d` doesn't go to definition
- Error: "Command not found"

**Cause**: Keybindings changed in v0.0.4

**Migration**:
| Old (v0.0.3) | New (v0.0.4) | Function |
|--------------|--------------|----------|
| `SPC m d` | `SPC m g d` | Go to definition |
| `SPC m r` | `SPC m g r` | Find references |
| `SPC m h` | `SPC m h h` | Describe at point |

See [full keybinding reference](../README.md#keybindings-spacemacs).

### Issue: Semantic Highlighting Not Working

**Symptoms**:
- All code looks the same color
- No context-aware highlighting

**Solutions**:

**Check if Enabled**:
```elisp
M-: lsp-semantic-tokens-enable  ; Should be t
```

**Enable in .spacemacs**:
```elisp
(defun dotspacemacs/user-config ()
  (with-eval-after-load 'lsp-mode
    (setq lsp-semantic-tokens-enable t)))
```

**Verify Server Supports It**:
```
M-x lsp-describe-session
```
Look for `semanticTokensProvider` in capabilities.

See [Semantic Highlighting Guide](SEMANTIC-HIGHLIGHTING.md) for details.

### Issue: Layer Not Loading

**Symptoms**:
- Spacemacs doesn't recognize `rholang` layer
- Error: "Cannot find layer rholang"

**Solutions**:

**Check Layer Location**:
```bash
ls ~/.spacemacs.d/layers/rholang/
# Should show: config.el packages.el
```

**Verify Configuration Path**:
```elisp
;; In dotspacemacs/layers
dotspacemacs-configuration-layer-path '("~/.spacemacs.d/layers/")
```

**Reinstall Layer**:
```bash
cd /path/to/rholang-emacs-client
cp -a layers/rholang/ ~/.spacemacs.d/layers/
```

### Issue: Performance Problems

**Symptoms**:
- Emacs feels slow when editing `.rho` files
- High CPU usage
- Laggy typing

**Solutions**:

**Optimize LSP**:
```elisp
(defun dotspacemacs/user-config ()
  (with-eval-after-load 'lsp-mode
    ;; Increase idle delay
    (setq lsp-idle-delay 0.5)  ; Wait 500ms before updating

    ;; Increase process output buffer
    (setq read-process-output-max (* 1024 1024))  ; 1MB

    ;; Disable logging
    (setq lsp-log-io nil)

    ;; Reduce file watching
    (setq lsp-enable-file-watchers nil)))
```

**Disable Semantic Tokens for Large Files**:
```elisp
(defun rholang-maybe-disable-semantic-tokens ()
  (when (> (buffer-size) 100000)  ; 100KB threshold
    (setq-local lsp-semantic-tokens-enable nil)))

(add-hook 'rholang-mode-hook #'rholang-maybe-disable-semantic-tokens)
```

**Use Embedded Rust (Not RNode)**:
```elisp
(rholang :variables
         rholang-use-rnode nil)  ; Faster than RNode
```

### Issue: Diagnostics Not Showing

**Symptoms**:
- No error highlighting
- No warnings or errors shown

**Solutions**:

**Run Diagnostics Tool**:
```
SPC m D  (or M-x rholang-doctor)
```

**Check LSP Status**:
```
M-x lsp-describe-session
```

**Verify Flycheck**:
```elisp
M-: (bound-and-true-p flycheck-mode)  ; Should be t
```

**Enable Flycheck**:
```elisp
(add-hook 'rholang-mode-hook #'flycheck-mode)
```

## Debugging Tools

### Run Diagnostics

**Primary Tool**: `rholang-doctor`
```
SPC m D
M-x rholang-doctor
```

Checks:
- Emacs version
- Dependencies (lsp-mode, tree-sitter)
- LSP server executable
- Configuration variables
- File associations

### Check LSP Session

```
M-x lsp-describe-session
```

Shows:
- Server status
- Capabilities
- Workspace folders
- Active buffers

### View LSP Logs

```
M-x lsp-workspace-show-log
```

Useful for debugging:
- Server startup issues
- Communication errors
- Request/response problems

### Inspect Variables

```elisp
;; Check specific variables
M-: rholang-lsp-server-path
M-: rholang-use-rnode
M-: rholang-indent-size
M-: lsp-semantic-tokens-enable

;; Check mode
M-: major-mode  ; Should be rholang-mode or rholang-ts-mode

;; Check LSP client
M-: (lsp-workspaces)  ; Should show rholang-lsp workspace
```

### Test File Association

```elisp
M-: (assoc "\\.rho\\'" auto-mode-alist)
;; Should return: ("\\.rho\\'" . rholang-mode)
```

### Check Load Path

```elisp
M-: (locate-library "rholang-mode")
;; Should return path to rholang-mode.el
```

## Getting Help

### Documentation

1. **Main README**: [../README.md](../README.md)
2. **Spacemacs Guide**: [SPACEMACS-CONFIG.md](SPACEMACS-CONFIG.md)
3. **Tree-Sitter**: [tree-sitter/QUICK-START.md](tree-sitter/QUICK-START.md)
4. **Semantic Highlighting**: [SEMANTIC-HIGHLIGHTING.md](SEMANTIC-HIGHLIGHTING.md)

### Diagnostic Commands

| Command | Keybinding | Purpose |
|---------|------------|---------|
| `rholang-doctor` | `SPC m D` | Full health check |
| `lsp-describe-session` | - | LSP status |
| `lsp-workspace-show-log` | - | LSP logs |
| `describe-mode` | `SPC h d m` | Mode info |
| `describe-variable` | `SPC h d v` | Variable value |

### Reporting Issues

When reporting issues, include:

1. **Emacs version**: `M-x emacs-version`
2. **Spacemacs version**: `SPC h d s`
3. **rholang-doctor output**: `SPC m D`
4. **LSP session info**: `M-x lsp-describe-session`
5. **Relevant configuration** from `.spacemacs`
6. **Error messages** from `*Messages*` buffer

**GitHub Issues**: https://github.com/F1R3FLY-io/rholang-emacs-client/issues

## Quick Fixes Checklist

When something doesn't work, try these in order:

- [ ] **Reload configuration**: `SPC f e R`
- [ ] **Run diagnostics**: `SPC m D`
- [ ] **Check .spacemacs** for conflicts (remove `rholang-mode` from `additional-packages`)
- [ ] **Verify server installed**: `which rholang-language-server`
- [ ] **Check LSP session**: `M-x lsp-describe-session`
- [ ] **View logs**: `M-x lsp-workspace-show-log`
- [ ] **Restart LSP**: `M-x lsp-workspace-restart`
- [ ] **Restart Emacs**: Full restart
- [ ] **Check GitHub issues**: Someone may have reported the same problem

## Known Issues

### Issue: Conflict with Additional Packages

**Status**: Common misconfiguration
**Workaround**: Remove `rholang-mode` from `dotspacemacs-additional-packages` (see first issue above)

### Issue: Port 40403 vs 40402

**Status**: Breaking change in v0.0.4
**Workaround**: Update `.spacemacs` to use port 40402 (RNode default) or your custom port

### Issue: Tree-Sitter on Emacs < 29.1

**Status**: Feature not available
**Workaround**: Use traditional `rholang-mode` or upgrade Emacs

### Issue: Windows Support

**Status**: Limited testing
**Workaround**: May need WSL or manual configuration. Report issues on GitHub.

