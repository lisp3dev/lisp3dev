;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.core:lisp3dev-core-header)

(in-package :lisp3dev.base.unify)


;@eval-always
(defun valid-let-head? (x)
  (do-unify x (:each (:and (:or (?v ?) (?v) ?v)
                           (:here (symbolp v))))))

(defun valid-variables-list? (x)
  (do-unify x (:each (:-> :type symbol))))


(defun valid-define-list? (x)
  (do-unify x (:each (:list* (:or (:-> :type symbol)
                                  (:LIST* (:-> :type symbol) (:-> :type proper-list)))
                             (:-> :type proper-list)))))

(defun valid-case-clause? (x)
  (do-unify x (:each (:list* ? (:-> :type proper-list)))))

(defun valid-append-clause? (x)
  (do-unify x
         (:each (:or (:-> :and listp );true-list?)
                     (:-> :view (x) (and (symbolp x) (is-var? x)))
                     (:-> :eq :maximize :minimize)))))

