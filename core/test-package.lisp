;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.core.init:define-package :lisp3dev.core.test ()
  (:import/export :lisp3dev.core.reader)
  (:use :cl :alexandria)

  (:export
   ;;#:*ignore-testing*
   ;;#:*force-testing* 
   #:enable-testing #:disable-testing
   #:testing

   ;; cl-annot annotations
   #:test #:verify #:todo
   #:eval-when-test
   
   ;;;;;
   #:todo..

   #:check-unit #:check-unit*
   #:check-units #:check-units*
   
   #:check-assert #:check-assert*

   #:precond 

   #:has-errors 
   #:has-no-errors
   #:protected-multiple-value-list #:protected-multiple-value-list*)

  )
