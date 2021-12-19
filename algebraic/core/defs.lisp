;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(in-package :lisp3dev.algebraic.core)


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
  local?
  fp-ctor)

;; lisp3advから(間接的に)呼ばれる
(defun <xquery> (info key)
  (case key
    (:class (xtypeinfo-class info))
    (:arity (xtypeinfo-arity info))
    (:id (xtypeinfo-id info))
    (t (error "internal error: defs.lisp <xquery>"))))

(defun <make-fp-ctor> (class local? info)
  (let* ((base-name (string-downcase class))
         (q-pkg (memoized (find-package :lisp3dev.mspace)))
         (fp-ctor (if local?
                    (intern (string-concat "@@" base-name) *package*)
                    (intern (string-concat "@" base-name) q-pkg))))
    (setf (get fp-ctor '%XQUERY%)
            (lambda (key) (<xquery> info key)))
    fp-ctor))

(defpackage :lisp3dev.algebraic.core.isolated)
(defparameter *<class-id-cnt>* 0)
(defun <generate-class-id> (class)
  (intern (format nil "xdata:~A/~A" (string-downcase class) (incf *<class-id-cnt>*))
          (find-package :lisp3dev.algebraic.core.isolated)))

(defun get-xtypeinfo (class &optional local?)
  (aif (get class '%xtypeinfo%)
       (cond ((or (and (xtypeinfo-local? it) local?)
                  (and (not (xtypeinfo-local? it)) (not local?)))
               it)
             (t
               (setf (xtypeinfo-local? it) local?
                     (xtypeinfo-fp-ctor it) (<make-fp-ctor> class local? it)
                     (get class '%fp-ctor%) (xtypeinfo-fp-ctor it))

               it))
       (let* ((id (<generate-class-id> class))
              (info (make-xtypeinfo
                     :class class
                     :id id
                     :local? local?))
              (fp-ctor (<make-fp-ctor> class local? info)))
         (setf (xtypeinfo-fp-ctor info) fp-ctor
               (get class '%xtypeinfo%) info
               (get class '%fp-ctor%) fp-ctor
               (get id '%assoc-class%) class)
         info)))




(defun xtuple-p (x) (typep x 'xtuple))
'(define-compiler-macro xtuple-p (x) `(typep ,x 'xtuple))

(defun xdata-p (x) (typep x 'xdata))
'(define-compiler-macro xdata (x) `(typep ,x 'xdata))

(defun xfst (x)
  (slot-value x '<fst>))

(defun xsnd (x)
  (slot-value x '<snd>))

;; lisp3advから呼ばれる
(defun %xconstruct% (class data)
  (let ((info (get-xtypeinfo class)))
    (unless info
      (error "XCONSTRUCT: class ~A is not a XDATA" class))
    (let ((arity (xtypeinfo-arity info))
          (types (xtypeinfo-types info)))
      (declare (type fixnum arity))
      (case arity
        (0 (make-instance class))
        (1 (when types
             (unless (typep data (svref types 0))
               (error "XCONSTRUCT: type mismatch ~A:~A" class (svref types 0))))
          (make-instance class '<data> data))    
        (t
          (assert (simple-vector-p data))
          (let ((n (length data)))
            (unless (eql arity n)
              (error "XCONSTRUCT: len err"))
            (when types
              (dotimes (i arity)
                (declare (type fixnum i))
                (let ((typ (svref types i)))
                  (unless (or (eq typ t)
                              (typep (svref data i) typ))
                    (error "XCONS: type mismatch ~A[~A]:~A" class i typ)))))
            (make-instance class '<data> data))))))) 
    


'(DEFUN XTUPLE (fst snd &OPTIONAL (class 'XTUPLE))
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

'(defun xtuple* (a b)
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

