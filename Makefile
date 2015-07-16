EMACS=emacs

EMACS_CLEAN=-Q
EMACS_BATCH=$(EMACS_CLEAN) --batch
TESTS=

CASK ?= ~/.cask/bin/cask
CASKEMACS = $(CASK) exec $(EMACS)

CURL=curl --silent
WORK_DIR=$(shell pwd)
PACKAGE_NAME=$(shell basename $(WORK_DIR))
AUTOLOADS_FILE=$(PACKAGE_NAME)-autoloads.el
TRAVIS_FILE=.travis.yml

.PHONY : build downloads downloads-latest autoloads test-autoloads test-travis \
         test test-interactive clean edit

build :
	$(CASKEMACS) $(EMACS_BATCH) --eval            \
	    "(progn                                   \
	      (setq byte-compile-error-on-warn t)     \
	      (batch-byte-compile))" cinspect.el

autoloads :
	$(EMACS) $(EMACS_BATCH) --eval                                         \
	    "(progn                                                            \
	      (setq generated-autoload-file \"$(WORK_DIR)/$(AUTOLOADS_FILE)\") \
	      (update-directory-autoloads \"$(WORK_DIR)\"))"

test-autoloads : autoloads
	@$(EMACS) $(EMACS_BATCH) -L . -l "./$(AUTOLOADS_FILE)"        || \
	 ( echo "failed to load autoloads: $(AUTOLOADS_FILE)" && false )

test-travis :
	@if test -z "$$TRAVIS" && test -e $(TRAVIS_FILE); then travis-lint $(TRAVIS_FILE); fi

cask:
	@$(CASK)

test : cask build test-autoloads
	(for test_lib in *-test.el; do                                                                 \
	    $(CASKEMACS) $(EMACS_BATCH) -L . -l cl -l $$test_lib --eval                                \
	    "(progn                                                                                    \
	      (fset 'ert--print-backtrace 'ignore)                                                     \
	      (ert-run-tests-batch-and-exit '(and \"$(TESTS)\" (not (tag :interactive)))))" || exit 1; \
	done)

clean :
	@rm -f $(AUTOLOADS_FILE) *.elc *~ */*.elc */*~
