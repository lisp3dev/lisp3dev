;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(lisp3dev.base:lisp3dev-base-header)
(in-package :lisp3dev.algebraic.core)

(defmacro defun.. (name lambda-list &body body)
  `(applicable (defun ,name ,lambda-list ,@body)))
(defmacro named-lambda.. (name lambda-list &body body)
  `(applicable (named-lambda ,name ,lambda-list ,@body)))
(defmacro lambda.. (lambda-list &body body)
  `(applicable (lambda ,lambda-list ,@body)))
(defmacro flet.. (definitions &body body)
  `(applicable (flet ,definitions body)))
(defmacro labels.. (definitions &body body)
  `(applicable (labels ,definitions body)))
(defmacro lambda-bind.. (lambda-list &body body)
  `(applicable (bind:lambda-bind ,lambda-list ,@body)))
(defmacro lambda/bind.. (lambda-list &body body)
  `(applicable (lambda/bind ,lambda-list ,@body)))


(defun <check-for-applicable> (form m allow-declares original-form)
  (labels ((single-exp? (exps)
             (flet ((is-declare? (x) (and (consp x) (eq (car x) 'declare))))
               (when exps
                 (if (cdr exps)
                   (and (is-declare? (car exps))
                        (single-exp? (cdr exps)))
                   (not (is-declare? (car exps))))))))
    (unless
        (when (proper-list-p form)
          (let ((k (- (list-length form) m)))
            (if allow-declares
              (and (>= k 1) (single-exp? (nthcdr m form)))
              (eql k 1))))
      (error "applicable: cannot expand (applicable ~A)" original-form))))

(defmacro applicable (form)
  (let ((original-form form)
        pure-op)
    (until (and (consp form)
                (awhen (assoc (car form)
                              '((defun . <pure-defun>) (lambda . <pure-lambda>)
                                (named-lambda . <pure-named-lambda>)
                                (labels . <pure-labels>) (flet . <pure-flet>)
                                (let 2 . t) (let* 2 . t) (progn 1 . nil) (eval-when 2 . nil)
                                (destructuring-bind 3 . t) (multiple-value-bind 3 . t)
                                ))
                  (setq pure-op (cdr it))))
      (let ((expanded (macroexpand-1 form)))
        (if (eq expanded form)
          (error "applicable: cannot expand: (applicable ~A)" original-form)
          (setq form expanded))))
    (if (symbolp pure-op)
      (cons pure-op (cdr form))
      (let ((m (car pure-op))
            (allow-declares (cdr pure-op)))
        (<check-for-applicable> form m allow-declares original-form)
        (nconc (butlast form) (list (list 'applicable (lastcar form))))))))


(defun <make-code/pure-defun> (def-op name lambda-list body)                                            
  (multiple-value-bind (normvars optvars)
      (parse-ordinary-lambda-list lambda-list)
    (if (null normvars)
      `(,@(case def-op
            ((LAMBDA) '(LAMBDA))
            ((NAMED-LAMBDA DEFUN) (list def-op name))
            ((LABELS FLET) (list name)))
          ,lambda-list ,@body)
      (let* ((n (list-length normvars))
             ;(k (+ n (list-length optvars)))
             (has-optvars optvars)
             (need-rest (or optvars (member-if (lambda (x) (or (eq x '&key) (eq x '&rest)))
                                               lambda-list)))
             (tmpval (gensym "U"))
             (common-call-form (if need-rest
                                 `(apply (function ,name) ,@normvars ,tmpval)
                                 `(,name ,@normvars)))

                                        ;(lastvar (lastcar normvars))
             (frontvar (first normvars))
             (newvars (mapcar (lambda (v) `(,v ',tmpval)) (cdr normvars)))
             (new-lambda-list `(,frontvar
                                &optional ,@newvars
                                ,@(nthcdr (if has-optvars (1+ n) n) lambda-list))))
        (multiple-value-bind (def-body unused def-doc) (case def-op
                                                         ((DEFUN) (parse-body body :documentation t))
                                                         (T body))
                                                             
          (values `(,@(case def-op
                        ((NAMED-LAMBDA LAMBDA) '(NAMED-LAMBDA))
                        ((DEFUN) '(DEFUN)))
                      ,name ,new-lambda-list
                      ,@(when def-doc (list def-doc))
                      (cond
                        ((not (eq ,(lastcar normvars) ',tmpval)) ,@def-body)
                        ,@(nreverse
                           (aprog1 (maplist (lambda (vs)
                                              (list `(eq ,(first vs) ',tmpval)
                                                    `(lambda (,(first vs)
                                                              ,@(awhen (cdr (member (first vs) newvars :key #'first))
                                                                    (cons '&optional it))
                                                              ,@(when need-rest (list '&rest tmpval)))
                                                       ,common-call-form)))
                                            (reverse (cdr normvars)))
                             (setf (caar it) T)))
                        ))
                  normvars)
          )))))



(defmacro <pure-defun> (name (&rest lambda-list) &body body)
  (<make-code/pure-defun> 'DEFUN name lambda-list body))

(defmacro <pure-named-lambda> (name (&rest lambda-list) &body body)
  (<make-code/pure-defun> 'NAMED-LAMBDA name lambda-list body))

(defmacro <pure-lambda> ((&rest lambda-list) &body body)
  (<make-code/pure-defun> 'LAMBDA (gensym) lambda-list body))

(defmacro <pure-labels> ((&rest clauses) &body main-body)
  (let (transformed-clauses)
    (dolist (definition clauses)
      (destructuring-bind (name (&rest lambda-list) &rest body)
          definition
        (push (<make-code/pure-defun> 'LABELS name lambda-list body)
              transformed-clauses)))
    (list* 'LABELS (nreverse transformed-clauses) main-body)))

(defmacro <pure-flet> ((&rest clauses) &body main-body)
  (let (transformed-clauses)
    (dolist (definition clauses)
      (destructuring-bind (name (&rest lambda-list) &rest body)
          definition
        (let ((proxy (gensym (symbol-name name))))
          (multiple-value-bind (transformed normvars)
              (<make-code/pure-defun> 'LABELS proxy lambda-list body)
            (cond ((null normvars) (setf (first transformed) name))
                  (t (let* ((m (list-length normvars))
                            (transformed-lambda-list (second transformed))
                            (n (1- (list-length transformed-lambda-list)))
                            (main-lambda-list (append (subseq transformed-lambda-list 0 (1+ m))
                                                      (unless (eql m n) '(&rest |<restArgs>|))))
                            (internal-lambda-list (append normvars (nthcdr (1+ m) transformed-lambda-list)))
                            (transformed-body (cddr transformed))
                            (proxy-call (if (eql m n)
                                          (list* proxy normvars)
                                          `(APPLY (function ,proxy) ,@normvars |<restArgs>|))))
                       (setq transformed `(,name ,main-lambda-list
                                                 (labels (,transformed);;((,proxy ,internal-lambda-list ,@transformed-body))
                                                   ,proxy-call))))))
            (push transformed transformed-clauses)))))
    (list* 'FLET (nreverse transformed-clauses) main-body)))


;; APPLIED / APPLIED*

(defun <make-code/applied> (f arity prescribed-args reversed-application? &optional rest-var)
  (flet ((fn-name? (x) (when (proper-list-p x)
                         (flet ((lambda-exp? (exp) (and (consp exp) (eq (car exp) 'lambda))))
                           (cond ((and (proper-list-p x)
                                       (eql 2 (list-length x))
                                       (let ((f (second x)))
                                         (or (symbolp f) (lambda-exp? f))))
                                           
                                   (second x))
                                 ((lambda-exp? x) x))))))
    ;(when (and rest-var (fn-name? f))(setq f (list 'function f)))
    (let* ((vars (freplicate arity #'gensym))
           (proxy-pairs (mapcar (lambda (exp) (list (gensym) exp))
                                prescribed-args))
           (pre-args (mapcar #'car proxy-pairs))
           fn-obj
           (op (if rest-var 'apply 'funcall))
           (extra-param (when rest-var (list '&rest rest-var)))
           (extra-var (when extra-param (cdr extra-param)))
           (front (if reversed-application? vars pre-args))
           (back  (if reversed-application? pre-args vars))
           (call-form (acond ((fn-name? f)
                              (if (eq op 'funcall)
                                `(,it ,@front ,@back)
                                `(apply ,f ,@front ,@back ,@extra-var)))
                             (t (setq fn-obj (gensym))
                                `(,op ,fn-obj ,@front ,@back ,@extra-var)))))
      (if (and (null proxy-pairs) (not fn-obj))
        `(lambda (,@vars ,@extra-param) ,call-form)
        `(let (,@(when fn-obj (list (list fn-obj f)))
               ,@proxy-pairs)
           (lambda (,@vars ,@extra-param) ,call-form))))))

(defun <<error/applied>> (arity n)
  (error "APPLIED/APPLIED*/RAPPLIED/RAPPLIED*'ed partial function needs ~A arguments but ~A was given." arity n))
  
(defun <<applied>> (function-designator arity prescribed-args reversed-application? allow-rest?)
  (lambda (&rest args)
    (let ((n (length args)))
      (cond ((eql n arity)
              (if reversed-application?
                (apply function-designator (nconc args prescribed-args))
                (apply function-designator (append prescribed-args args))))              
            ((and allow-rest? (>= n arity))
              (if reversed-application?
                (let ((rest (prog1 (nthcdr arity args)
                              (setf (cdr (nthcdr (1- arity) args)) nil))))
                                   
                  (apply function-designator (nconc args prescribed-args rest)))
                (apply function-designator (append prescribed-args args))))
            (t (<<error/applied>> arity n))))))


(defun applied (function-designator arity &rest prescribed-args)
  (<<applied>> function-designator arity prescribed-args nil nil))

(define-compiler-macro applied (function-designator arity &rest prescribed-args)
  (if (integerp arity)
    (<make-code/applied> function-designator arity prescribed-args nil)
    `(<<applied>> ,function-designator ,arity (list ,@prescribed-args) nil nil)))

(defun applied* (function-designator arity &rest prescribed-args)
  (<<applied>> function-designator arity prescribed-args nil t))

(define-compiler-macro applied* (function-designator arity &rest prescribed-args)
  (if (integerp arity)
    (<make-code/applied> function-designator arity prescribed-args nil (memoized (gensym)))
    `(<<applied>> ,function-designator ,arity (list ,@prescribed-args) nil t)))
  

(defun rapplied (function-designator arity &rest prescribed-args)
  (<<applied>> function-designator arity prescribed-args t nil))

(define-compiler-macro rapplied (function-designator arity &rest prescribed-args)
  (if (integerp arity)
    (<make-code/applied> function-designator arity prescribed-args t)
    `(<<applied>> ,function-designator ,arity (list ,@prescribed-args) t nil)))

(defun rapplied* (function-designator arity &rest prescribed-args)
  (<<applied>> function-designator arity prescribed-args t t))

(define-compiler-macro rapplied* (function-designator arity &rest prescribed-args)
  (if (integerp arity)
    (<make-code/applied> function-designator arity prescribed-args t (memoized (gensym)))
    `(<<applied>> ,function-designator ,arity (list ,@prescribed-args) t t)))



;;;;;; PURE ;;;;;;;;



(defun <<pure>> (f arity pre-args allow-rest?)
  (let ((cnt arity))
    (lambda (x &rest xs)
      (let* ((xs (cons x xs))
             (n (list-length xs))
             (args (append pre-args xs)))
        (cond ((or (eql cnt n)
                   (and allow-rest? (> n cnt)))
                (apply f args))
              ((< n cnt) (<<pure>> f (- cnt n) args allow-rest?))
              (t (error "pure-1")))))))

'(defun <<rpure>> (f arity pre-args allow-rest?)
  (if (null pre-args)
    (<<pure>> f arity nil allow-rest?)
    (let ((cnt arity))
      (lambda (x &rest xs)
        (let* ((xs (cons x xs))
               (n (list-length xs))
               (args (append pre-args xs)))
          (cond ((or (eql cnt n)
                     (and allow-rest? (> n cnt)))
                  (apply f args))
                ((< n cnt) (<<pure>> f (- cnt n) args allow-rest?))
                (t (error "pure-2 ~A" (list n cnt args allow-rest?)))))))))


@inline
(defun <pure> (f arity prescribed-arguments &optional allow-rest?)
  (assert (and 'pure (positive-integer-p arity)))
  (<<pure>> (ensure-function f) arity prescribed-arguments allow-rest?))

(defun applied.. (function-designator arity &rest prescribed-arguments)
  (<pure> function-designator arity prescribed-arguments))

(defun applied*.. (function-designator arity &rest prescribed-arguments)
  (<pure> function-designator arity prescribed-arguments t))

;; [2021-12-13] TODO ????????????????????????

(defun rapplied.. (function-designator arity &rest prescribed-arguments)
  (let ((fn (ensure-function function-designator)))
    (<pure> (lambda (&rest args)
              (apply fn (nconc args prescribed-arguments)))
            arity nil)))

(defun rapplied*.. (function-designator arity &rest prescribed-arguments)
  (let ((fn (ensure-function function-designator)))
    (<pure> (lambda (&rest args)
              (if (eql arity (length args))
                (apply fn (nconc args prescribed-arguments))
                (let ((rest (prog1 (nthcdr arity args)
                              (setf (cdr (nthcdr (1- arity) args)) nil))))
                  (apply fn (nconc args prescribed-arguments rest)))))

            arity nil t)))




'(define-compiler-macro pure (f arity &rest prescribed-arguments)
  (cond ((non-negative-integer-p arity)
          `(applicable (applied ,f ,arity ,@prescribed-arguments)))
        (prescribed-arguments
          `(<pure> ,f ,arity (list ,@prescribed-arguments)))
        (t (list '<pure> f arity nil))))


#Verify
(and (equal (funcall (applied #'list 3 0 1) 2 3 4)
            '(0 1 2 3 4))
     (equal (funcall (applied* #'list 3 0 1) 2 3 4)
            '(0 1 2 3 4))
     (equal (funcall (applied* #'list 3 0 1) 2 3 4 5 6)
            '(0 1 2 3 4 5 6))
     (equal (funcall (rapplied 'list 3 0 1) 2 3 4)
            '(2 3 4 0 1))
     (equal (funcall (rapplied* 'list 3 0 1) 2 3 4)
            '(2 3 4 0 1))
     (equal (funcall (rapplied* 'list 3 0 1) 2 3 4 5 6)
            '(2 3 4 0 1 5 6)))

#Verify
(and (equal (funcall (applied.. #'list 3 0 1) 2 3 4)
            '(0 1 2 3 4))
     (equal (funcall (funcall (applied.. #'list 3 0 1) 2 3) 4)
            '(0 1 2 3 4))
     (equal (funcall (funcall (applied*.. #'list 3 0 1) 2 3) 4)
            '(0 1 2 3 4))
     (equal (funcall (rapplied.. #'list 3 0 1) 2 3 4)
            '(2 3 4 0 1))
     (equal (funcall (funcall (rapplied.. #'list 3 0 1) 2 3) 4)
            '(2 3 4 0 1))
     (equal (funcall (funcall (rapplied*.. #'list 3 0 1) 2 3) 4)
            '(2 3 4 0 1))
     (equal (funcall (funcall (rapplied*.. #'list 3 0 1) 2 3) 4 5 6)
            '(2 3 4 0 1 5 6)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Comment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(curry* x 2 a b c)
(funcall (curry 'list 1 2))
(funcall (purely (applied* 'list 2 'a)) 1 2)
@applicable (applied 'list 2 'x foo)

(partial 'list * 'x * *)
(funcall* 'list * 'x *)
(apply* 'list 'this * * xs)
;(applicable (let ()  (lambda (a) (declare) a)))
;(applicable (destructuring-bind (a) e (declare) (declare) (lambda (a b c))))
;(applicable (bind (((:values a b) e) (#(f) foo)) (lambda (x y) a)))

(defun foo (n) (dotimes (i n) (funcall (funcall (funcall (pure #'list 3 'a 'b 'c) 1) 2) 3)))
(time (foo 10000000))



(let ((n 3))
  (funcall (pure #'list 3 'a 'b) 1 2 3))

(mflip #'f 5 5)

(defun bar (&optional (arity 2) (ok arity))
  (list arity ok))

(defun f (a) (lambda (b) (lambda (c) (list a b c))))
(defun flp (f) (lambda (a) (lambda (b) (funcall (funcall f b) a))))
(funcall (funcall (funcall (flp #'f) 1) 2) 3)
(funcall (funcall (f 1) 2) 3)


(funcall (funcall (applicable (applied #'list 2 'the 'list 'is)) 1) 'ok 'nh 30 20)
(applicable (lambda (a b c) 'foo))

(funcall (applicable (applied (lambda (&rest xs) (nreverse xs)) 2 'foo 'bar)) 1 2)
(funcall (applicable (rapplied (lambda (&rest xs) (nreverse xs)) 2 'foo 'bar)) 1 2)
(symbol-package 'name)

(applied (t f)
             
