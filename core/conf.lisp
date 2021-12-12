;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.core.init:define-package :lisp3dev.core.global-configurations ()
  (:use :lisp3cfg)

  (:export
   ;; Export from lisp3cfg
   #:*ignore-testing*
   #:*force-testing*
   #:*impl-opt-level*
   #:*allow-compiler-macro*))

