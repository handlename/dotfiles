;;; Custom variables

(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p (expand-file-name custom-file))
      (load-file (expand-file-name custom-file)))

;;; UI

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;;; Packages

(require 'package)
(add-to-list 'package-archives '("gnu-elpa-devel" . "https://elpa.gnu.org/devel/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(use-package use-package
  :config
  (setq use-package-always-ensure t))

(use-package evil
  :after projectile
  :init
  (setq evil-want-keybinding nil) ; for evil-collection
  (define-prefix-command 'my/leader-map)
  :config
  (keymap-set evil-normal-state-map "SPC" 'my/leader-map)
  (evil-define-key nil my/leader-map
    (kbd "SPC") 'execute-extended-command
    "bb" 'switch-to-buffer
    "br" 'recentf
    "bD" 'kill-current-buffer
    "gs" 'magit-status
    "wm" 'maximize-window
    "wn" 'next-window-any-frame
    "w-" 'split-window-vertically
    "w|" 'split-window-horizontally
    "wD" 'delete-window
    "p" 'projectile-command-map)
  (define-key evil-insert-state-map (kbd "C-h") 'delete-backward-char)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package files
  :ensure nil
  :config
  (setq auto-save-visited-interval 30)
  (auto-save-visited-mode))

(use-package server
  :config
  (unless (server-running-p)
    (server-start)))

(use-package vertico
  :init
  (setq vertico-cycle t)
  (vertico-mode))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package corfu
  :config
  (setq corfu-auto t
	corfu-quit-no-match 'separator)
  :init
  (global-corfu-mode))

(use-package corfu-popupinfo
  :ensure nil
  :hook (corfu-mode . corfu-popupinfo-mode))

(use-package recentf
  :init
  (setq recentf-max-saved-items 100)
  (recentf-mode))

(use-package magit)

(use-package diff-hl
  :after magit
  :init
  (global-diff-hl-mode)
  :config
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(use-package which-key
  :init
  (setq which-key-idle-delay 0.1)
  (which-key-mode))

(use-package projectile
  :config
  (projectile-mode +1))
