;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(in-package :lisp3dev.algebraic.xdata)


(defclass xtuple ()
  ((<fst> :allocation :class :initform nil)
   (<fst-readonly> :allocation :class :initform t)
   (<snd> :allocation :class :initform nil)
   (<snd-readonly> :allocation :class :initform t)))

(defclass xdata (xtuple)
  ((<snd> :allocation :instance :initarg <data>)
   (<snd-readonly> :allocation :class :initform nil)))

(defstruct xtypeinfo
  class
  arity
  types
  id
  fp-ctor)

(defun get-xtypeinfo (sym)
  (get sym '<xtypeinfo>))



(defun xtuple-p (x) (typep x 'xtuple))
'(define-compiler-macro xtuple-p (x) `(typep ,x 'xtuple))

(defun xdata-p (x) (typep x 'xdata))
'(define-compiler-macro xdata (x) `(typep ,x 'xdata))

(defun xfst (x)
  (slot-value x '<fst>))

(defun xsnd (x)
  (slot-value x '<snd>))


(DEFUN XTUPLE (fst snd &OPTIONAL (class 'XTUPLE))
  (LET ((xtuple (MAKE-INSTANCE class)))
    (SETF (SLOT-VALUE xtuple 'fst) fst
          (SLOT-VALUE xtuple 'snd) snd)
    xtuple))

; XTUPLE compiler macro版に深刻な不具合？
'(DEFINE-COMPILER-MACRO XTUPLE (fst snd &OPTIONAL (class ''XTUPLE))
  `(LET ((xtuple (MAKE-INSTANCE ,class)))
    (SETF (SLOT-VALUE xtuple 'fst) ,fst
          (SLOT-VALUE xtuple 'snd) ,snd)
    xtuple))

(defun xtuple* (a b)
  (IF (SYMBOLP a)
    (LET ((lisp-ident (GET a '|%classdata%|)))
      (IF lisp-ident
        (XTUPLE a b lisp-ident)
        (XTUPLE a b 'P2)))
    (XTUPLE a b 'P2)))

; (@p 'just# 3)
;(just# 3) ==> (xtuple* '|just#| 3)
;(string-downcase "")
;(just# 

'(DEFUN XTUPLE-FST (xtuple)  (SLOT-VALUE xtuple 'fst))
'(DEFUN XTUPLE-SND (xtuple)  (SLOT-VALUE xtuple 'snd))

'(DEFINE-COMPILER-MACRO XTUPLE-FST (xtuple)  `(SLOT-VALUE ,xtuple 'fst))
'(DEFINE-COMPILER-MACRO XTUPLE-SND (xtuple)  `(SLOT-VALUE ,xtuple 'snd))

'(DEFUN (SETF XTUPLE-FST) (val x)  (SETF (SLOT-VALUE x 'fst) val))
'(DEFUN (SETF XTUPLE-SND) (val x)  (SETF (SLOT-VALUE x 'snd) val))
'(DEFINE-COMPILER-MACRO (SETF XTUPLE-FST) (val x)  `(SETF (SLOT-VALUE ,x 'fst) ,val))
'(DEFINE-COMPILER-MACRO (SETF XTUPLE-SND) (val x)  `(SETF (SLOT-VALUE ,x 'snd) ,val))

