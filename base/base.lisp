;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.core:lisp3dev-core-header)

(lisp3dev.core:define-package :lisp3dev.base ()
  (:use :cl)
  (:import/export :lisp3dev.base.ffi*)
  (:export

   #:lisp3dev-base-header
   
   #:wired-p
   #:unwired-p
   #:define-wired #:define-unwired
   #:do-wire #:do-unwire
   #:set-standalone-application

   #:complete-and-register-wiring
   )

  (:unexport #:lisp3dev-core-header)
  )

(in-package :lisp3dev.base)

(defmacro lisp3dev-base-header (&rest args)
  `(lisp3dev.core:lisp3dev-core-header ,@args))


(defparameter *app-wired-p* t)

(defun wired-p   ()      *app-wired-p*)
(defun unwired-p () (not *app-wired-p*))


(defgeneric <wired>   (package))
(defgeneric <unwired> (package))


(defun <defw> (method-name body)
  (with-gensyms (x)
    `(eval-when (:load-toplevel :execute)
      (defmethod ,method-name ((,x (eql *package*)))
        (declare (ignore ,x))
        ,@body)
      nil)))

(defmacro define-wired (&body body)
  (<defw> '<wired> body))

(defmacro define-unwired (&body body)
  (<defw> '<unwired> body))


(defparameter *wiring* nil)
(defun complete-and-register-wiring (&optional (pkg *package*))
  (pushnew pkg *wiring*)
  (when (wired-p)
    (<wired> pkg)))

(defun do-wire ()
  (setq *app-wired-p* t)
  ;; FIFO順に実行
  (mapc #'<wired> (reverse *wiring*)))

(defun do-unwire ()
  (setq *app-wired-p* nil)
  ;; FILO順に実行
  (mapc #'<unwired> *wiring*))

(defun set-standalone-application (&optional (this-is-standalone-app t))
  (if this-is-standalone-app
    (pushnew :CL-UNWIRED-STANDALONE-APPLICATION *features*)
    (removef *features* :CL-UNWIRED-STANDALONE-APPLICATION)))

