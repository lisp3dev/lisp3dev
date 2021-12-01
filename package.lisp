;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.base:define-package :lisp3dev ()
  (:use :cl)
  (:nicknames :3dev)
  (:import/export :lisp3dev.base :lisp3dev.algebraic.core :lisp3dev.prolog)
  (:export
   #:full-mode
   )
  (:unexport
   #:lisp3dev-base-header)
  )

(in-package :lisp3dev)

(defmacro full-mode ()
  '(lisp3dev.base:lisp3dev-base-header))







