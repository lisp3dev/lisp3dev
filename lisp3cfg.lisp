;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;     GLOBAL CONFIGURATION for lisp3dev,lisp3adv     ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defpackage :lisp3cfg
  (:use :cl)
  (:nicknames :3cfg)
  (:export
   #:*ignore-testing*
   #:*force-testing*
   #:*impl-opt-level*
   )
  )

(in-package :lisp3cfg)

;; 真の場合テストを完全に無効化する (最優先フラグ)
(defvar *ignore-testing* t) 

;; *ignore-testing*が偽の場合、このフラグが真であればテストを強制的に有効化する
(defvar *force-testing* nil) 

;; 実装の最適化レベル 0-3
(defvar *impl-opt-level* 3)

;; COMPILER MACRO を使用するか
(defvar *allow-compiler-macro* t)


;; for DEBUG

;; (defparameter *ignore-testing* nil) 

