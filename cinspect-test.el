;;; cinspect-test.el --- Tests for cinspect

;; Copyright (C) 2015 Ben Yelsey

;; Author: Ben Yelsey <ben.yelsey@gmail.com>
;; Version: 0.0.1
;; Keywords: python

;;; Commentary:

;; I'm just here so I don't get fined

;;; Code:

(require 'ert)
(require 'deferred)
(require 'cinspect)

(deferred:sync!
  (cinspect-install-cinspect))

(ert-deftest cinspect-test-python-cinspect ()
  (deferred:sync!
    (cinspect--python-cinspect "map"))
  (with-current-buffer cinspect-buffer-name
    (should (string-match "builtin_map" (buffer-substring-no-properties 1 (1+ (buffer-size)))))))

(ert-deftest cinspect-test-python-cinspect-none ()
  "For whatever reason, 'NoneType' is not directly accessible from __builtin__."
  (deferred:sync!
    (cinspect--python-cinspect "NoneType"))
  (with-current-buffer cinspect-buffer-name
    (should (string-match "PyNone_Type" (buffer-substring-no-properties 1 (1+ (buffer-size)))))))

(ert-deftest cinspect-test-join-python-statements ()
  (should (equal (cinspect--join-python-statements "foo")          "foo; "))
  (should (equal (cinspect--join-python-statements "" "foo")       "foo; "))
  (should (equal (cinspect--join-python-statements "foo" "")       "foo; "))
  (should (equal (cinspect--join-python-statements "foo" "bar")    "foo; bar; "))
  (should (equal (cinspect--join-python-statements "foo" "" "bar") "foo; bar; ")))

(ert-deftest cinspect-test-jedi-response-formatting ()
  (dolist (case cinspect--jedi-definition-cases)
    (let ((response (eval (car case)))
          (expected-import-statement (cadr case))
          (expected-name (caddr case)))
      (cl-destructuring-bind (&key desc_with_module full_name name type &allow-other-keys)
          (car response)
        (let ((module (cinspect--format-module desc_with_module)))
          (should (equal (cinspect--format-import-statement module full_name name type)
                         expected-import-statement))
          (should (equal (cinspect--format-name module full_name name type)
                         expected-name)))))))

(defvar cinspect--jedi-definition-cases
  '((cinspect--True               ""                               "bool")
    (cinspect--None               ""                               "NoneType")
    (cinspect--datetime           "import datetime"                "datetime")
    (cinspect--datetime.timedelta "from datetime import timedelta" "timedelta")
    (cinspect--list               ""                               "list")
    (cinspect--list.append        ""                               "list.append")
    (cinspect--map                ""                               "map"))
  "These are the definitions returned from the 'get_definition endpoint of the jediepcserver.")


;; Output from jediepcserver 'get_definition endpoint

(defvar cinspect--True
  '((:name "bool"
           :column nil
           :doc "bool(x) -> bool

Returns True when the argument x is true, False otherwise.
The builtins True and False are the only two instances of the class bool.
The class bool is a subclass of the class int, and cannot be subclassed."
           :desc_with_module "__builtin__:class bool"
           :full_name "bool"
           :module_path nil
           :type "instance"
           :line_nr nil
           :description "class bool")))
(defvar cinspect--None
  '((:name "NoneType" :column nil :doc "" :desc_with_module "__builtin__:class NoneType" :full_name "NoneType" :module_path nil :type "instance" :line_nr nil :description "class NoneType")))
(defvar cinspect--datetime
  '((:name "datetime" :column nil :doc "Fast implementation of the datetime type." :desc_with_module "datetime:module datetime" :full_name "datetime" :module_path nil :type "module" :line_nr nil :description "module datetime")))
(defvar cinspect--datetime.timedelta
  '((:name "timedelta" :column nil :doc "Difference between two datetime values." :desc_with_module "datetime:class timedelta" :full_name "datetime.timedelta" :module_path nil :type "class" :line_nr nil :description "class timedelta")))
(defvar cinspect--list
  '((:name "list"
           :column nil
           :doc "list() -> new empty list
list(iterable) -> new list initialized from iterable's items"
           :desc_with_module "__builtin__:class list"
           :full_name "list"
           :module_path nil
           :type "class"
           :line_nr nil
           :description "class list")))
(defvar cinspect--list.append
  '((:name "append" :column nil :doc "L.append(object) -- append object to end" :desc_with_module "__builtin__:function append" :full_name "list.append" :module_path nil :type "function" :line_nr nil :description "function append")))
(defvar cinspect--map
  '((:name "map"
           :column nil
           :doc "map(function, sequence[, sequence, ...]) -> list

Return a list of the results of applying the function to the items of
the argument sequence(s).  If more than one sequence is given, the
function is called with an argument list consisting of the corresponding
item of each sequence, substituting None for missing values when not all
sequences have the same length.  If the function is None, return a list of
the items of the sequence (or a list of tuples if more than one sequence)."
           :desc_with_module "__builtin__:function map"
           :full_name "map"
           :module_path nil
           :type "function"
           :line_nr nil
           :description "function map")))

;;; cinspect-test.el ends here
