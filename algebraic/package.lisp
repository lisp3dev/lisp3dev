;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

;; すこしHaskell的な、代数的データ型の実現
;; define-data,define-newtypeは、組み込み言語とのシームレスな接続を実現
;; define-internal-data,define-internal-newtypeは、CL内のみの使用を前提とした効率的な実装

(lisp3dev.base:define-package :lisp3dev.algebraic ()
  (:use :cl :lisp3dev.base)
  (:import/export :lisp3dev.algebraic.core)
  (:export
   
   ))

