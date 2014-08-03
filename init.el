;; --------------------------------------------------
;; Load all files in the "lisp" directory recursively
;; --------------------------------------------------
(let ((default-directory "~/.emacs.d/lisp/"))
  (normal-top-level-add-subdirs-to-load-path))
(setq my-dir (expand-file-name "~/.emacs.d/lisp/"))
(dolist (file (directory-files my-dir t "\\w+"))
  (when (file-regular-p file)
      (load file)))

;; --------------------------------------------------
;; Encoding
;; --------------------------------------------------
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; --------------------------------------------------
;; General settings
;; --------------------------------------------------
(setq case-fold-search t
      column-number-mode t
      major-mode 'org-mode
      inhibit-startup-message t
      inhibit-splash-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      save-place t
      transient-mark-mode t
      uniquify-buffer-name-style 'forward
      vc-follow-symlinks t
      visible-bell t
      default-line-spacing 3
      tab-width 2
      confirm-kill-emacs 'yes-or-no-p
      longlines-wrap-follows-window-size t
      sentence-end-double-space nil)
(tool-bar-mode -1)
;(menu-bar-mode -1)
(scroll-bar-mode -1)
(show-paren-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(display-time)
(global-visual-line-mode t)
(pending-delete-mode t) ; type over a region

;; Set the name of the host and current path/file in title bar:
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; --------------------------------------------------
;; Environment Setup
;; --------------------------------------------------
backup-directory-alist '(("." . "~/.emacs.d/backups"))
(setq my-dir "~/.emacs.d/"
      my-ac-dict-dir (format "%s/%s" my-dir "ac-dict"))

;; --------------------------------------------------
;; Autoloads
;; --------------------------------------------------
(require 'ido)(ido-mode t)
(require 'smex)
(require 'solarized-light-theme)
;(require 'solarized-dark-theme)
(require 'pomodoro)(pomodoro-add-to-mode-line) ;enabling pomodoro mode
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; --------------------------------------------------
;; Key bindings
;; --------------------------------------------------
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key [(control home)] 'beginning-of-buffer)
(global-set-key [(control end)] 'end-of-buffer)
(define-key emacs-lisp-mode-map (kbd "C-c .") 'find-function-at-point)
(global-set-key [(control meta l)] 'longlines-mode)
(global-set-key [f9] 'deft)
(global-set-key [f10] 'rotate-windows)
(global-set-key [f12] 'toggle-selective-display)
(global-set-key [f11] 'toggle-fullscreen)
(global-set-key [(meta f1)] 'kill-other-buffers)
(global-set-key [(meta q)] 'close-and-kill-this-pane)
(global-set-key [(meta f2)] 'close-and-kill-next-pane)
(global-set-key (kbd "M-+") 'text-scale-increase)
(global-set-key (kbd "M--") 'text-scale-decrease)
(global-set-key (kbd "M-0") 'text-scale-adjust)
;; powerful counterparts ?
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)
;; comment/uncomment block
(global-set-key (kbd "C-M-f") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c c") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c u") 'uncomment-region)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; --------------------------------------------------
;; Functions
;; --------------------------------------------------

;; (un)hide function definitions. Mimics the M-1 C-x $ and C-x $ behavior.
(defun toggle-selective-display ()
	(interactive)
	(set-selective-display (if selective-display nil 1)))
 
;; enable fullscreen toggle on f11
(defun toggle-fullscreen (&optional f)
	(interactive)
	(let ((current-value (frame-parameter nil 'fullscreen)))
		(set-frame-parameter nil 'fullscreen
												 (if (equal 'fullboth current-value)
														 (if (boundp 'old-fullscreen) old-fullscreen nil)
													 (progn (setq old-fullscreen current-value)
																	'fullboth)))))

;; Rotate Windows on F10
(defun rotate-windows ()
	"Rotate your windows"
	(interactive)
	(cond
	 ((not (> (count-windows) 1))
		(message "You can't rotate a single window!"))
	 (t
		(let ((i 1)
					(num-windows (count-windows)))
			(while (< i num-windows)
				(let* ((w1 (elt (window-list) i))
							 (w2 (elt (window-list) (+ (% i num-windows) 1)))
							 (b1 (window-buffer w1))
							 (b2 (window-buffer w2))
							 (s1 (window-start w1))
							 (s2 (window-start w2)))
					(set-window-buffer w1 b2)
					(set-window-buffer w2 b1)
					(set-window-start w1 s2)
					(set-window-start w2 s1)
					(setq i (1+ i))))))))

;; three little buffer killing helpers
(defun kill-other-buffers ()
	(interactive)
	(mapc 'kill-buffer (delq (current-buffer) (buffer-list))))
(defun close-and-kill-this-pane ()
	(interactive)
	(kill-this-buffer)
	(if (not (one-window-p))
			(delete-window)))
(defun close-and-kill-next-pane ()
	(interactive)
	(other-window 1)
	(kill-this-buffer)
	(if (not (one-window-p))
			(delete-window)))

;; --------------------------------------------------
;; Setting up org-mode
;; --------------------------------------------------
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(setq org-agenda-files (list (format "%s/%s" my-dir "task.org")
(format "%s/%s" my-dir "life.org")))
;; strikethrough DONE headlines
(setq org-fontify-done-headline t)
 
;; --------------------------------------------------
;; Setting up Deft
;; --------------------------------------------------
(require 'deft)(setq deft-extension "txt")
(setq deft-directory my-dir)
(setq deft-use-filename-as-title t)
 
;; --------------------------------------------------
;; Setting up autocomplete
;; --------------------------------------------------
(require 'auto-complete)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories my-ac-dict-dir)
(ac-config-default)
(global-auto-complete-mode t)
 
;; --------------------------------------------------
;; Setting up org-present
;; --------------------------------------------------
(autoload 'org-present "org-present" nil t)
(add-hook 'org-present-mode-hook
	  (lambda ()
	    (org-present-big)
	    (org-display-inline-images)))
(add-hook 'org-present-mode-quit-hook
	  (lambda ()
	    (org-present-small)
	    (org-remove-inline-images)))

;; --------------------------------------------------
;; Setting up python-mode
;; --------------------------------------------------
;(add-to-list 'load-path py-install-directory)
(require 'python-mode)
(global-set-key [(meta f)] 'py-execute-statement)
(setq-default py-shell-name "python")
(setq-default py-which-bufname "Python")
(setq py-python-command-args '("--gui=wx" "--pylab=wx" "-colors" "Linux")) ; use the wx backend, for both mayavi and matplotlib
(setq py-force-py-shell-name-p t)
(setq py-shell-switch-buffers-on-execute-p nil) ; switch to the interpreter after executing code
(setq py-switch-buffers-on-execute-p nil)
(setq py-split-windows-on-execute-p nil) ; don't split windows
(setq py-smart-indentation t) ; try to automagically figure out indentation
 
;; init.el ends here ;;
