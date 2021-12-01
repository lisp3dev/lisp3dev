;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(in-package :cl-user)

(asdf:defsystem :lisp3dev.prolog  
  :license "LLGPL"
  :depends-on (:lisp3dev.base)
  :serial t
  :components
  ((:file "0-prolog-core")
   (:file "1-prolog-base")
   (:file "package")
   (:file "pl-lib-1")
   ))




