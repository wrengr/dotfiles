;;; Use Evil instead of emacs...
;; BUG: Evil doesn't play nicely with AgdaMode nor ProofGeneral
; (add-to-list 'load-path "~/.emacs.d/evil")
; (setq evil-default-cursor #'cofi/evil-cursor);; BUG: this isn't enough, but what else do we need to do??
; ;(require 'undo-tree)
; ;(require 'evil-numbers)
; (require 'evil)
; (evil-mode 1)
;
; ;;; fancy cursor 
; ;; BUG: this doesn't appear to be working... Or rather, how do we call it?
; (defun cofi/evil-cursor ()
; 	"Change cursor color according to evil-state."
; 	(let ((default "OliveDrab4")
; 		(cursor-colors
; 		  '((insert . "dark orange")
; 			(emacs  . "sienna")
; 			(visual . "white"))))
; 	(setq cursor-type
; 		(if (eq evil-state 'visual)
; 			'hollow
; 			'bar))
; (set-cursor-color (def-assoc evil-state cursor-colors default))))


;; cf <https://github.com/mbriggs/.emacs.d/blob/master/my-keymaps.el>
;; cf <https://github.com/cofi/dotfiles/blob/master/emacs.d/config/cofi-evil.el>

;;; basic stuff
(global-set-key (kbd "RET") 'newline-and-indent)

;; BUG: this doesn't do what you think! You have to :!<return>command
; (evil-ex-define-cmd "!" 'shell-command) 


;;; window commands
; (define-key evil-window-map (kbd "<up>")    'evil-window-up)
; (define-key evil-window-map (kbd "<down>")  'evil-window-down)
; (define-key evil-window-map (kbd "<left>")  'evil-window-left)
; (define-key evil-window-map (kbd "<right>") 'evil-window-right)


;;; esc quits
; (define-key evil-normal-state-map [escape] 'keyboard-quit)
; (define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)


;;; Get the mouse to work!
;; <https://iterm2.com/faq.html>
(require 'mouse)
(xterm-mouse-mode t)
(defun track-mouse (e))

;;; Agda-mode
;; BUG: we get a recursive-load error when using Evil + AgdaMode
;; cf <http://wiki.portal.chalmers.se/agda/agda.php?n=Docs.EmacsModeKeyCombinations>
;; cf <http://wiki.portal.chalmers.se/agda/agda.php?n=Main.QuickGuideToEditingTypeCheckingAndCompilingAgdaCode>
(load-file
  (let ((coding-system-for-read 'utf-8))
	(shell-command-to-string "agda-mode locate")))


;;; Haskell-mode
(setq load-path (cons "~/.emacs.d/haskell-mode" load-path)) ;; TODO: how does this differ from using add-to-list ?


;;; Proof General for Coq and Isabelle
;; BUG: we get a recursive-load error when using Evil + ProofGeneral
(load-file "~/.emacs.d/ProofGeneral/generic/proof-site.el")
;; BUG: if we actually say this, then whenever we try to do something we get the error "Can't exec program"
;(setq coq-prog-name "/sw/bin/coqtop -emacs")
;; TODO: what's the actual variable name for this?
;(setq ?<isabelle-prog-name> "/Users/wren/current/b522/Isabelle2011-1.app/Isabelle/bin/isabelle")
;; TODO: how to tell emacs to automatically assume that yes, we do want to kill the background Coq when exiting emacs?
;; Standard command keybindings
; C-c C-n   = proof-assert-next-command-interactive
; C-c C-u   = proof-undo-last-successful-command
; C-c C-BS  = proof-undo-and-delete-successful-command
; C-c C-RET = proof-goto-point (BUG: C-RET registers as RET instead!)
;             <http://stackoverflow.com/questions/2298811/how-to-turn-off-alternative-enter-with-ctrlm-in-linux>
; C-c C-b   = proof-process-buffer
; C-c C-r   = proof-retract-buffer
; C-c .     = proof-electric-terminator-toggle (for Coq)
; C-c ;     = proof-electric-terminator-toggle (for Isabelle)
;
; C-c C-l   = proof-display-some-buffers
; C-c C-p   = proof-prf (show the current proof state)
; C-c C-t   = proof-ctxt (show the current context)
; C-c C-h   = proof-help
; C-c C-i   = proof-query-identifier
; C-c C-f   = proof-find-theorems
; C-c C-w   = pg-response-clear-displays
; C-c C-c   = proof-interrupt-process
; C-c C-v   = proof-minibuffer-cmd
; C-c C-s   = proof-shell-start
; C-c C-x   = proof-shell-exit
