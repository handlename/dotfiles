;;; package --- init
;;; Commentary:
;;; Configurations for my Emacs.

;;; Code:

;;; Custom variables

(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p (expand-file-name custom-file))
      (load-file (expand-file-name custom-file)))

;;; UI

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)

;;; Editing

(electric-pair-mode t)

;;; Keys

(setq ns-command-modifier 'meta)
(setq ns-alternate-modifier 'super)

(setq scroll-step 1)

;;; Packages

(require 'package)
(add-to-list 'package-archives '("gnu-elpa-devel" . "https://elpa.gnu.org/devel/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(use-package use-package
  :config
  (setq use-package-always-ensure t))

(defvar evil-want-C-u-scroll t) ; need to set before evil loaded. set in :init not satisfies condition.
(use-package evil
  :after projectile
  :init
  (setq evil-want-keybinding nil) ; for evil-collection
  (setq evil-undo-system 'undo-fu)
  (define-prefix-command 'my/evil-leader-map)
  (define-prefix-command 'my/evil-buffer-map)
  (define-prefix-command 'my/evil-git-map)
  (define-prefix-command 'my/evil-window-map)
  :config
  (keymap-set evil-normal-state-map "SPC" 'my/evil-leader-map)
  (evil-define-key nil my/evil-buffer-map
    "b" 'switch-to-buffer
    "r" 'recentf
    "D" 'kill-current-buffer)
  (evil-define-key nil my/evil-git-map
    "s" 'magit-status)
  (evil-define-key nil my/evil-window-map
    "m" 'maximize-window
    "n" 'next-window-any-frame
    "-" 'split-window-vertically
    "|" 'split-window-horizontally
    "D" 'delete-window)
  (evil-define-key nil my/evil-leader-map
    (kbd "SPC") 'execute-extended-command
    (kbd "TAB") 'previous-buffer
    "b" 'my/evil-buffer-map
    "g" 'my/evil-git-map
    "w" 'my/evil-window-map
    "p" 'projectile-command-map)
  (define-key evil-insert-state-map (kbd "C-h") 'delete-backward-char)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package undo-fu)

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

(use-package consult
  :bind (("M-f" . 'consult-line)))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

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

(use-package fontaine
  :config
  (setq fontaine-presets
	'((regular
	   :default-family "Moralerspace Xenon NF"
	   :fixed-pitch-family "Moralerspace Xenon NF"
	   :variable-pitch-family "Moralerspace Xenon NF"
	   :italic-family "Moralerspace Xenon NF")))
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset))

(use-package rg
  :defer t)

(use-package solarized-theme
  :config
  (load-theme 'solarized-light t))

;;; Languages

(use-package lsp-mode
  :init
  (setq lsp-enable-snippet nil
	lsp-completion-provider nil)
  :config
  (add-to-list 'warning-suppress-log-types '(lsp-mode))
  (add-to-list 'warning-suppress-types '(lsp-mode))
  :hook ((rust-mode . lsp-deferred)
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferrerd))

(use-package lsp-ui
  :config
  (setq lsp-ui-sideline-show-hover t))

(use-package flycheck
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package flycheck-projectile)

(use-package rust-mode
  :hook ((rust-mode . (lambda () (setq indent-tabs-mode nil))))
  :config
  (setq rust-format-on-save t))

;;; init.el ends here
