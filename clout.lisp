;;;; CLOUT - Common Lisp Okay Unit Tester

(defpackage :clout
  (:use :cl)
  (:export :test :test-stdout :test-error :run :show-failures))

(in-package :clout)

;;;; private symbols

(defparameter *tests* '())
(defvar *test-failures* '())

(defun coloured (colour text)
  (format nil "~c[~am~a~c[0m" #\Escape colour text #\Escape))

(defun run-test (test)
  "Runs the provided test"
  (let ((actual-val (funcall (getf test :actual)))
        (expected-val (getf test :expected)))
    (unless (equal actual-val expected-val)
      (push (format nil "~a~%Expected: ~a~%Actual: ~a"
                    (getf test :text) expected-val actual-val)
            *test-failures*))))

;;;; public symbols

;; the "expected nil expected-p" case is there to make it so supplying nil still works in case a unit test requires it
(defmacro test (name &key actual (expected nil expected-p) text)
  "Registers a test with the test framework. Tests don't run unless called with ut:run."
  (unless (and actual expected-p text)
    (error "Malformed test. Must contain :actual, :expected and :text"))
  `(pushnew (list :name ',name
                  :actual (lambda () ,actual)
                  :expected ,expected
                  :text ,text)
            *tests* :key (lambda (entry) (getf entry :name))))

(defmacro test-stdout (name &key actual (expected nil expected-p) text)
  "Registers a test that captures stdout and compares it to expected."
  `(test ,name
         :actual (with-output-to-string (*standard-output*) ,actual)
         :expected ,expected
         :text ,text))

(defmacro test-error (name &key condition actual text)
  "Registers a test that expects a condition to be signalled."
  `(test ,name
         :actual (handler-case (progn ,actual nil)
                   (,condition () t))
         :expected t
         :text ,text))

(defun show-failures (&key (print t))
  "Prints the list of failed tests and returns it. Pass :print nil to suppress output."
  (when print
    (if *test-failures*
      (dolist (f (reverse *test-failures*))
        (format t "~a~%" (coloured 31 (format nil "FAIL: ~a" f))))
      (format t "~a~%" (coloured 32 "All tests passed"))))
  *test-failures*)

(defun run (&rest names)
  "Runs the unit tests. If the names parameter is absent, it runs all the tests, otherwise it only runs the tests."
  (setf *test-failures* '())
  (let* ((named-in-list (lambda (test) (member (getf test :name) names)))
         (tests (if names
                 (remove-if-not named-in-list *tests*)
                 *tests*)))
    (dolist (test (reverse tests))
      (run-test test)))
  (show-failures))
