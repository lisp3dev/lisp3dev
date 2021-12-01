;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.core:lisp3dev-core-header)
 
(lisp3dev.core:define-package :lisp3dev.base.text* (:lisp3dev.base.text)
  (:use :cl :cl-ppcre)
  (:import/export :lisp3dev.base.guard*)

  (:export
   #:=~ #:!~

   #:$ #:text-compile-literal

   
   #:text-scan
   #:text-matches #:text-unmatches
   #:text-replace
   #:text-split
   #:regex
   
   #:do-text-matches #:do-text-unmatches
   #:text-all-matches #:text-all-matches-as-strings
   #:text-all-unmatches #:text-all-unmatches-as-strings
   )
  )

(in-package :lisp3dev.base.text)
