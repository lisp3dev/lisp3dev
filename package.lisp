;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.base:define-package :lisp3dev ()
  (:use :cl)
  (:nicknames :3dev)
  (:import/export :lisp3dev.base :lisp3dev.algebraic.core :lisp3dev.prolog)
  (:export
   #:use-reader
   )
  (:unexport
   ;;#:lisp3dev-base-header
   #:enable-reader)
  )

(in-package :lisp3dev)

(defmacro use-reader()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (lisp3dev.base:enable-reader nil :ignores '(:lpar))))







