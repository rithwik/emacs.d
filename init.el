(package-initialize)
(setq package-enable-at-startup nil)
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-always-ensure t)
(eval-when-compile
  (require 'use-package))

; Make OS shell path available in emacs exec path
(use-package exec-path-from-shell
  :config (exec-path-from-shell-copy-env "PATH"))

(use-package ace-window)
(global-set-key (kbd "M-o") 'ace-window)
; (windmove-default-keybindings) ; enable shift-movement among windows

(use-package evil
  :bind (
	 :map evil-normal-state-map
	      ("C-e" . 'move-end-of-line)
	 :map evil-insert-state-map
	 ("C-e" . 'move-end-of-line)
	 ("C-a" . 'evil-beginning-of-line))
  :config
  (evil-mode 1))
(add-hook 'calendar (lambda () (evil-mode -1)))
(add-hook 'magit (lambda () (evil-mode -1)))

(use-package ivy
  :defer 0.1
  :diminish
  :bind (("C-c C-r" . ivy-resume)
         ("C-x B" . ivy-switch-buffer-other-window)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :config
  (setq ivy-initial-inputs-alist nil)
  (ivy-mode))

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package magit
  :bind (("C-x g" . 'magit-status)
	 ("C-x M-g" . 'magit-dispatch)
	 ("C-c M-g" . 'magit-file-dispatch)))

(use-package company
  :config
  ;; Enable company mode everywhere
  (add-hook 'after-init-hook 'global-company-mode)
  ;; Set up TAB to manually trigger autocomplete menu  (define-key company-mode-map (kbd "TAB") 'company-complete)
  (define-key company-active-map (kbd "TAB") 'company-complete-common)
  ;; Set up M-h to see the documentation for items on the autocomplete menu
  (define-key company-active-map (kbd "M-h") 'company-show-doc-buffer))

(use-package doom-themes
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
  (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
  (doom-themes-treemacs-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

; Set up elpy for Python in Emacs
(use-package elpy
  ;; :pin elpy
  :bind ("C-RET" . 'elpy-shell-send-statement)
  :config
  (elpy-enable)
  ;; Enable elpy in a Python mode
  (add-hook 'python-mode-hook 'elpy-mode)
  (setq elpy-rpc-backend "jedi")
  ;; Open the Python shell in a buffer after sending code to it
  (add-hook 'inferior-python-mode-hook 'python-shell-switch-to-shell)
  ;; Use IPython as the default shell, with a workaround to accommodate IPython 5
  ;; https://emacs.stackexchange.com/questions/24453/weird-shell-output-when-using-ipython-5
  (setq python-shell-interpreter "ipython")
  (setq python-shell-interpreter-args "--simple-prompt -i")
  ;; Enable pyvenv, which manages Python virtual environments
  (pyvenv-mode 1)
  ;; Tell Python debugger (pdb) to use the current virtual environment
  ;; https://emacs.stackexchange.com/questions/17808/enable-python-pdb-on-emacs-with-virtualenv
  (setq gud-pdb-command-name "python -m pdb "))
	    
; Set up company-jedi, i.e. tell elpy to use company autocomplete backend
(use-package company-jedi
  :config
  (defun my/python-mode-hook ()
    (add-to-list 'company-backends 'company-jedi))
  (add-hook 'python-mode-hook 'my/python-mode-hook))

; Set up markdown in Emacs
; Tutorial: http://jblevins.org/projects/markdown-mode/
(use-package pandoc-mode
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode))

(add-hook 'text-mode-hook (lambda() (flyspell-mode 1)))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "pandoc"))

;; Beancount mode: github.com/beancount/beancount-mode
(use-package beancount
  :load-path "~/.emacs.d/beancount-mode/"
  :config
  (add-to-list 'auto-mode-alist '("\\.beancount\\'" . beancount-mode))
  (add-hook 'beancount-mode-hook #'outline-minor-mode)
  :bind
  (:map beancount-mode-map
	("C-c C-n" . 'outline-next-visible-heading)
	("C-c C-p" . 'outline-previous-visible-heading)))

;; Org-present: https://github.com/rlister/org-present
(use-package org-present
  :load-path "~/.emacs.d/org-present"
  :config
  (autoload 'org-present "org-present" nil t)
  (add-hook 'org-present-mode-hook
               (lambda ()
                 (org-present-big)
                 (org-display-inline-images)
                 (org-present-hide-cursor)))
                 ;; (org-present-read-only)))
  (add-hook 'org-present-mode-quit-hook
               (lambda ()
                 (org-present-small)
                 (org-remove-inline-images)
                 (org-present-show-cursor)
                 (org-present-read-write))))
(global-set-key (kbd "M-p") 'org-present)

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)

(setq org-agenda-files (list org-directory)) ; "~/org/orgfile.org"))
(setq org-capture-templates
      '(("l" "Link" entry (file+headline "~/org/captures.org" "Links")
         "* %a %^g\n %?\n %T\n %i")
        ("i" "Idea" entry (file+headline "~/org/captures.org" "Ideas")
         "* %?\n%T" :prepend t)
        ("t" "Todo" entry (file+headline "~/org/captures.org" "Todo")
         "* TODO %?\n%u" :prepend t)
        ("n" "Note" entry (file+headline "~/org/captures.org" "Notes")
         "* %u %? " :prepend t)))

(use-package org-journal
  :init
  ;; Change default prefix key; needs to be set before loading org-journal
  (setq org-journal-prefix-key "C-c j ")
  :config
  (setq org-journal-dir "~/org/journal/"
        org-journal-date-format "%Y-%m-%d"
	org-journal-file-type "monthly"
	org-journal-file-format "%Y-%m.org"))

(use-package shell-pop
  :init
  (setq shell-pop-shell-type (quote ("ansi-term" "*ansi-term*" (lambda nil (ansi-term shell-pop-term-shell)))))
  (setq shell-pop-term-shell "/bin/zsh")
  (setq shell-pop-universal-key "s-t"))

;; (add-to-list 'default-frame-alist '(fullscreen . maximized)) ; open fullscreen
(set-face-attribute 'default nil :font "Fira Code Retina 14")
(tool-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Make ESC quit prompts
(global-set-key (kbd "C-c C-t") 'eshell)
(global-set-key (kbd "s-o") 'find-file)
(global-set-key (kbd "s-p") 'counsel-M-x)
(global-set-key (kbd "s-b") 'ivy-switch-buffer)
(global-set-key (kbd "s-B") 'ivy-switch-buffer-other-window)

(show-paren-mode t)
(setq inhibit-startup-message t)         ; Don't show the startup message
(setq inhibit-startup-screen t)          ; or screen
(setq cursor-in-non-selected-windows t)  ; Hide the cursor in inactive windows
(setq echo-keystrokes 0.1)               ; Show keystrokes right away, don't show the message in the scratch buffer
(setq initial-scratch-message nil)       ; Empty scratch buffer
(setq sentence-end-double-space nil)     ; Sentences should end in one space, come on!
(setq confirm-kill-emacs 'y-or-n-p)      ; y and n instead of yes and no when quitting
(setq tool-bar-mode -1)
(setq show-paren-mode t)
(display-time-mode 1)
(setq display-time-default-load-average nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("d6603a129c32b716b3d3541fc0b6bfe83d0e07f1954ee64517aa62c9405a3441" default))
 '(org-confirm-babel-evaluate nil)
 '(org-default-notes-file (concat org-directory "/notes.org"))
 '(org-directory "~/org")
 '(org-export-html-postamble nil)
 '(org-export-with-toc nil)
 '(org-hide-leading-stars t)
 '(org-src-fontify-natively t)
 '(org-startup-folded 'overview)
 '(org-startup-indented t)
 '(package-selected-packages
   '(org-journal shell-pop ace-window epresent magit doom-themes elpy org-bullets yasnippet which-key use-package spacemacs-theme s poet-theme pandoc-mode monokai-theme markdown-mode ivy-rich exec-path-from-shell evil counsel company-jedi)))

