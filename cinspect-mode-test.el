;;; cinspect-mode-test.el --- Tests for cinspect-mode

;; Copyright (C) 2015 Ben Yelsey

;; Author: Ben Yelsey <ben.yelsey@gmail.com>
;; Version: 0.0.1
;; Keywords: python

;;; Commentary:

;; I'm just here so I don't get fined

;;; Code:

(require 'ert)
(require 'deferred)
(require 'cinspect-mode)

(ert-deftest cinspect-mode-test-python-cinspect ()
  (deferred:sync!
    (cinspect:--python-cinspect "map"))
  (with-current-buffer "cinspect"
    (should (string-match "builtin_map" (buffer-substring-no-properties 1 (1+ (buffer-size)))))))

;;; cinspect-mode-test.el ends here
