;;; cinspect-mode-test.el --- Tests for cinspect-mode

;; Copyright (C) 2015 Ben Yelsey

;; Author: Ben Yelsey <ben.yelsey@gmail.com>
;; Version: 0.0.1
;; Keywords: python

;;; Commentary:

;; I'm just here so I don't get fined

;;; Code:

(require 'ert)
(require 'cinspect-mode)

(ert-deftest cinspect-mode-test-hello-world ()
  (should (equal "a" "a")))

;;; cinspect-mode-test.el ends here
