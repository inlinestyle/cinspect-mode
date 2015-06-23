# cinspect-mode [![Build Status](https://travis-ci.org/inlinestyle/cinspect-mode.svg?branch=master)](https://travis-ci.org/inlinestyle/cinspect-mode)
Use [cinspect](https://github.com/punchagan/cinspect) to look at the CPython source of builtins and other C objects!

`cinspect-mode` can and optimally should be used in concert with [Jedi.el](http://tkf.github.io/emacs-jedi).

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

## TODO
 - Make the `"cinspect"` buffer more usable. Currently it's in "readonly" `c-mode`. I'd like to have something more like `help-mode` with `c-mode`'s syntax highlighting.
 - Add test installation of Jedi.el
 - Add Jedi.el integration tests (will have to install Jedi.el)
 - Get on (M)ELPA
 - Add integration with other emacs/python analyzers (accepting PRs!)

## Acknowledgements
 - [cinspect](https://github.com/punchagan/cinspect)
 - [Jedi.el](http://tkf.github.io/emacs-jedi)
 - [emacs-travis](https://github.com/rolandwalker/emacs-travis)
