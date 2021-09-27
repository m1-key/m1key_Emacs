
;;;        ;;;       ;;;   ;;    ;;   ;;;;;;;   ;;      ;;
;; ;;    ;; ;;     ;; ;;   ;;   ;;    ;;         ;;    ;;
;;  ;;  ;;  ;;    ;;  ;;   ;;  ;;     ;;          ;;  ;;
;;    ;;    ;;   ;;   ;;   ;; ;;      ;;;;;;;       ;;
;;          ;;        ;;   ;;  ;;     ;;            ;;
;;          ;;        ;;   ;;   ;;    ;;            ;;
;;          ;;        ;;   ;;    ;;   ;;;;;;;       ;;

; ------------------------------------------------------------------------

(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)       ;Disable toolbar
(tooltip-mode -1)        ;Disable tooltip
(set-fringe-mode 10)

;; Set uo the visible bell
(setq visible-bell t)

(setq auth-sources '("~/.authinfo.gpg"))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package command-log-mode)

;; Set default font
(set-face-attribute 'default nil
                    :family "FantasqueSansMono Nerd Font Mono"
                    :height 110
                    :weight 'normal
                    :width 'normal)

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-gruvbox t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure
  :init(doom-modeline-mode 1))

;; Source code blocks shortcuts
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src sh"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist( mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		vterm-mode-hook
		shell-mode-hook))
  (add-hook mode(lambda()(display-line-numbers-mode 0))))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ("C-M-l" . counsel-imenu)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-f" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

(use-package magit
  :bind ("C-M-;" . magit-status)
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge)

(use-package org
  :config
  (setq org-ellipsis " ▾"))

;; Replace list hyphen with dot
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package fish-completion
  :hook (eshell-mode . fish-completion-mode))

(use-package term
  :config
  (setq explicit-shell-file-name "fish"))


(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))



(defun m1key/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . m1key/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Predefined to 's-l' (Super + l)
  :config
  (lsp-enable-which-key-integration t))


(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; My Keys
(global-set-key (kbd "M-z") 'vterm)
(global-set-key (kbd "C-c f") 'format-all-buffer)
(global-set-key (kbd "C-c C-p") 'forge-pull)
