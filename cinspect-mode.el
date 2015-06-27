;;; cinspect-mode.el --- Use cinspect to look at the CPython source of builtins and other C objects!

;; Copyright (C) 2015 Ben Yelsey

;; Author: Ben Yelsey <ben.yelsey@gmail.com>
;; Version: 0.0.1
;; Keywords: python
;; Homepage: https://github.com/inlinestyle/cinspect-mode

;; Package-Requires: ((emacs "24") (cl-lib "0.5") (deferred "0.3.1") (python-environment "0.0.2"))

;;; Commentary:

;; Use [cinspect](https://github.com/punchagan/cinspect) to look at the CPython source of builtins and other C objects!
;; `cinspect-mode` can and optimally should be used in concert with [Jedi.el](http://tkf.github.io/emacs-jedi).

;;; Code:

(require 'cl-lib)
(require 'deferred)
(require 'python-environment)


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
      (lambda (response)
        (with-temp-buffer-window "cinspect" nil nil
                                 (with-current-buffer "cinspect"
                                   (c-mode))
                                 (princ response))))))

(defun cinspect:install-cinspect ()
  (interactive)
  (lexical-let ((current-dir default-directory)
                (tmp-dir "/tmp/cinspect")
                (index-dir "~/.cinspect"))
    (deferred:$
      (deferred:$
        (if (file-exists-p tmp-dir)
            (message "cinspect download found at %s, skipping download" tmp-dir)
          (deferred:process "git" "clone" "https://github.com/punchagan/cinspect.git" tmp-dir))
        (deferred:nextc it
          (lambda () (cd tmp-dir)))
        (deferred:nextc it
          (lambda ()
            (python-environment-run '("python" "setup.py" "develop"))))
        (deferred:nextc it
          (lambda ()
            (if (file-exists-p index-dir)
                (message "cinspect indexes found at %s, skipping index download" index-dir)
              (python-environment-run '("cinspect-download")))))
        (deferred:nextc it
          (lambda (reply)
            (message "Done installing cinspect"))))
      (deferred:error it
        (lambda (err) (message "Error installing cinspect: %s" err)))
      (deferred:nextc it
        (lambda ()
          (cd current-dir)
          (when (file-exists-p tmp-dir)
            (delete-directory tmp-dir t))
          (message "Done cleaning up"))))))

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
