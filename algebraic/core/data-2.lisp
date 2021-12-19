;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.base:lisp3dev-base-header)
(in-package :lisp3dev.algebraic.core)

;; Maybe

(define-global-data maybe nothing (just t))
;(define-internal-data _maybe _nothing (_just t))

;; Either

(define-global-data either (left t) (right t))
;(define-internal-data _either (_left t) (_right t))


;; Tuples P3 ... P20
;; (eval-when (:compile-toplevel :load-toplevel)
;;   (defvar *tuple-max* 20))

;; (eval-when (:compile-toplevel)
;;   (defmacro <define-tuples> ()
;;     (let (data-definitions
;;           conversion-list)
;;       (do ((i 3 (1+ i))
;;            (ts (list t t t) (cons t ts)))
;;           ((> i *tuple-max*) `(eval-when (:load-toplevel)
;;                                 (defvar %tuple-conversion-vector% #(nil nil nil ,@(nreverse conversion-list)))
;;                                 ,@data-definitions))
;;         (let ((ident (intern (format nil "P~A" i))))
;;           (push ident conversion-list)
;;           (push `(define-global-data ,ident (,ident ,@ts))
;;                 data-definitions))))))

;; (<define-tuples>)


(defvar %tuple-max% 20)
(defvar %tuple-class-names% '(p0 p1 p2 p3 p4 p5 p6 p7 p8 p9 p10
                              p11 p12 p13 p14 p15 p16 p17 p18 p19 p20))
                        

(define-global-data tuple p0
  (p1 t)
  (p2 (t fst) (t snd))
  (p3 t t t)
  (p4 t t t t)
  (p5 t t t t t)
  (p6 t t t t t t)
  (p7 t t t t t t t)
  (p8 t t t t t t t t)
  (p9 t t t t t t t t t)
  (p10 t t t t t t t t t t)
  (p11 t t t t t t t t t t t)
  (p12 t t t t t t t t t t t t) 
  (p13 t t t t t t t t t t t t t) 
  (p14 t t t t t t t t t t t t t t) 
  (p15 t t t t t t t t t t t t t t t) 
  (p16 t t t t t t t t t t t t t t t t) 
  (p17 t t t t t t t t t t t t t t t t t) 
  (p18 t t t t t t t t t t t t t t t t t t) 
  (p19 t t t t t t t t t t t t t t t t t t t) 
  (p20 t t t t t t t t t t t t t t t t t t t t))


;; [2021-12-14] todo
;(DEFMETHOD PRINT-OBJECT ((x tuple) stream)
;  (FORMAT stream "(@~A ~W ~W)" (SLOT-VALUE x 'fst) (SLOT-VALUE x 'snd)))

#Comment


(define-data mydat (myd t t t))
(define-internal-data imydat (imyd t t t))

(defclass xcons () ((<car> :initarg <car> :initform nil)
                    (<cdr> :initarg <cdr> :initform nil)))

(defun xcons (xcar xcdr)
  (make-instance 'xcons '<car> xcar '<cdr> xcdr))

(defun xcar (xcons)
  (slot-value xcons '<car>))
(defun xcdr (xcons)
  (slot-value xcons '<cdr>))

(defun xlist (&rest elems)
  (when elems
    (let (last)
      (dolist (e (nreverse elems) last)
        (setf last (xcons e last))))))

(defun xdelist (xcons)
  (let (delist)
    (while xcons
      (push (xcar xcons) delist)
      (setf xcons (xcdr xcons)))
    (nreverse delist)))


(defun copy-xlist (xcons)
  (let (new)
    (while xcons
      (setf cur (xcons (xccar xcons) cur))
      
  
(defun xmap (xcons f)
  (let (mapped)
    (while xcons
      (funcall f (xcar xcons))
      (setf xcons (xcdr xcons)))
    mapped))


(define-internal-data foobar fb-1 (fb-2 t t t))

(defclass tup ()
  ((fst :accessor t-fst :initform nil :allocation :class)
   (snd :accessor t-snd)))

(defclass tup2 (tup)
  ((fst :accessor t2-fst :initform 'ok)))
          
(t-fst (make-instance 'tup))
(setf (t-fst (make-instance 'tup)) 200)

(t2-fst (make-instance 'tup2))
(xcdr (xcons 1 2))



(slot-value (make-instance 'xcons :car 0) 'cdr)

(defun mk () (make-instance 'xcons))
(disassemble 'mk)


(myd 'a nil 'c :source (myd 1 2 3) :mask nil :update t)
(myd 'a nil 'c :mask nil :update t)
(myd 'a nil 'c :mask nil :updPate t)


(just# 3 :update t)

(== (myd 3 2 1) (myd 3 2 1))
(== 3 3)

(typep (just 3) 'maybe)


(symbol-package '==)
