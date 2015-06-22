;;; cinspect-mode.el --- Use cinspect to look at the CPython source of builtins and other C objects!

;; Copyright (C) 2015 Ben Yelsey

;; Author: Ben Yelsey <ben.yelsey@gmail.com>
;; Version: 0.0.1
;; Keywords: python

;;; Commentary:

;; Use [cinspect](https://github.com/punchagan/cinspect) to look at the CPython source of builtins and other C objects!
;; `cinspect-mode` can and optimally should be used in concert with [Jedi.el](http://tkf.github.io/emacs-jedi).

;;; Code:

(require 'cl-lib)
(require 'deferred)

(defgroup cinspect nil
  "Inspect CPython builtins."
  :group 'completion
  :prefix "cinspect:")

(defcustom cinspect:use-with-jedi t
  "Use jedi's epc server to get the qualified names of builtins."
  :group 'cinspect)

(defcustom cinspect:use-as-jedi-goto-fallback t
  "Automatically use as a fallback when jedi:goto-definition hits a python builtin."
  :group 'cinspect)

(declare-function jedi:goto-definition "jedi-core" ())
(declare-function jedi:call-deferred "jedi-core" (method-name))

(defun cinspect:inspect-with-jedi-as-jedi-fallback ()
  (interactive)
  (deferred:nextc (jedi:goto-definition)
    (lambda (message)
      (when (and message (string-match "builtin" message))
        (cinspect:inspect-with-jedi)))))

(defun cinspect:inspect-with-jedi ()
  (interactive)
  (deferred:nextc (cinspect:--python-jedi-get-name)
    (lambda (name)
      (message "Inspecting `%s'" name)
      (cinspect:--python-cinspect name))))

(defun cinspect:inspect ()
  (interactive)
  (let ((name (symbol-at-point)))
    (message "Inspecting `%s'" name)
    (cinspect:--python-cinspect name)))

(defun cinspect:--python-jedi-get-name ()
  (deferred:nextc (jedi:call-deferred 'get_definition)
    (lambda (response)
      (cl-destructuring-bind (&key full_name &allow-other-keys)
          (car response)
        full_name))))

(defun cinspect:--python-cinspect (name)
  (deferred:$
    (deferred:process "python" "-c"
      (format "import cinspect; print cinspect.getsource(%s)" name))
    (deferred:nextc it
      (lambda (x)
        (with-temp-buffer-window "cinspect" nil nil
                                 (with-current-buffer "cinspect"
                                   (c-mode))
                                 (princ x))))))

;;;###autoload
(define-minor-mode cinspect-mode
  "CInspect Mode.
Uses `cinspect' (https://github.com/punchagan/cinspect) to show CPython source for Python builtins
Can be used as a fallback option for `jedi-mode' (https://github.com/tkf/emacs-jedi)."
  :lighter " cinspect"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c f") (if cinspect:use-with-jedi
                                              'cinspect:inspect-with-jedi
                                            'cinspect:inspect))
            (when cinspect:use-as-jedi-goto-fallback
              (define-key map (kbd "C-c .") 'cinspect:inspect-with-jedi-as-jedi-fallback))
            map))

;;;###autoload
(add-hook 'python-mode-hook 'cinspect-mode)

(provide 'cinspect-mode)

;;; cinspect-mode.el ends here
