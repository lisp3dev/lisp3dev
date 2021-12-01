;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(asdf:defsystem :lisp3dev
    :version "0.9"
    :description "lisp3dev: Development libraries for `lisp3' scripting system"
    :author "<master@junneko.net>"
    :depends-on (:lisp3dev.core :lisp3dev.base :lisp3dev.algebraic :lisp3dev.prolog)
    :license "LLGPL"
    :serial t
    :components ((:file "package")
                 ))

