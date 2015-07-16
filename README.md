# cinspect [![Build Status](https://travis-ci.org/inlinestyle/cinspect-mode.svg?branch=master)](https://travis-ci.org/inlinestyle/cinspect-mode)
Use [cinspect](https://github.com/punchagan/cinspect) to look at the CPython source of builtins and other C objects!

`cinspect` (the Emacs mode) can and optimally should be used in concert with [Jedi.el](http://tkf.github.io/emacs-jedi).

![](https://raw.github.com/inlinestyle/cinspect-mode/master/images/cinspect-startswith.png)

In addition to being a great asset for python editing in general, we can use Jedi.el's analysis to trace objects even if they've been renamed. With Jedi.el use enabled, we can put our cursor on `sort` and correctly determine that we're looking at Python's `list.sort` builtin:
```python
foo = [1, 6, 7]
foo.sort()
```
If you put your cursor on the `r` in each of the following lines of code, only the second will be possible to inspect without Jedi.el (since we'd need our own python analyzer):
```python
sorted([1, 6, 7]) # Can do without Jedi.el

[1, 6, 7].sort() # Can't do without Jedi.el
```

## Usage

To enable `cinspect` in python mode:
```elisp
(add-hook 'python-mode-hook 'cinspect-mode)
```

Run `cinspect-install-cinspect` if you don't have `cinspect` installed in your emacs python environent. If it fails, you most likely have permissions issues installing python packages (we try to use `virtualenv`, but if your machine doesn't have it installed already getting it seems to be error prone).

`cinspect` comes with the following keyboard shortcuts:
 - `C-c f`: `cinspect-getsource`
 - `C-c .`: (Requires `Jedi.el`) `jedi:goto-definition` with fallback to `cinspect-getsource-with-jedi`

## TODO
 - Add test installation of Jedi.el
 - Add Jedi.el integration tests (will have to install Jedi.el)
 - Get on the various emacs package repositories
 - Add integration with other emacs/python analyzers (accepting PRs!)
 - Add ability to use locally generated cinspect indexes (may require substantial refactor)

## Acknowledgements
 - [cinspect](https://github.com/punchagan/cinspect)
 - [deferred.el](https://github.com/kiwanami/emacs-deferred)
 - [Jedi.el](http://tkf.github.io/emacs-jedi)
 - [python-environment.el](https://github.com/tkf/emacs-python-environment)
 - [emacs-travis](https://github.com/rolandwalker/emacs-travis)
