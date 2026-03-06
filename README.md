# CLOUT
Common Lisp Okay Unit Tester

A very simple single file testing framework for Common Lisp.

Made this for my own personal needs, but I figured I might as well share it with the class.
It doesn't (yet) use qicklisp, just load the package into your project and write your tests.

There are three principal test macros, `test`, `test-stdout`, and `test-error`.

`(clout:run)` runs the unit tests that are currently loaded.

`(clout:show-failures :print t)` will print all the errors without re-running the tests and return the list of failed tests.
`:print` is `t` by default. Set it to `nil` to disable printing to stdout and only return the list of failed tests.

## Test
Registers a test with the framework.
It takes a `:name`, an `:actual` value, an `:expected` value, and `:text`.

Example:
```lisp
(clout:test fibonacci-0-1
      :actual (fib 0 1 *iteration-depth*)
      :expected '(0 1 1 2 3 5 8 13 21 34)
      :text "Fibonacci starting from 0 1 failed")
```

## Test-Stdout
Same as `test` except it captures *standard-output* so you can test if a function would print what you expect it to.
It takes the same arguments as `test`, except the expected value is a string.

Example:
```lisp
(clout:test-stdout test-hello
      :actual (format t "Hello, world!")
      :expected "Hello, world!"
      :text "Prints hello world")
```

## Test-Error
Tests to see if a function signalled a condition.
It takes the same arguments as `test` except no `:expected`, as the "expected value" is the condition being signalled.

Example:
```lisp
(clout:test-error n=-1
      :condition error
      :actual (fib 0 1 -1)
      :text "n=-1 should signal an error")
```
