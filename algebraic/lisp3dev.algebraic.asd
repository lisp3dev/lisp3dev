;; -*- coding: utf-8 -*-
;; This file is part of lisp3dev.
;; Copyright (c) 2012-2021 junneko.net

(asdf:defsystem :lisp3dev.algebraic
  :license "LLGPL"
  :depends-on (:lisp3dev.base)
  :serial t
  :components (
               (:module "xdata"
                        :components
                        ((:file "package")
                         (:file "defs"))
                        )
               (:module "core"
                        :components
                        ((:file "package")
                         (:file "applicable")
                         (:file "data-1")
                         (:file "data-2")))
                        
               
               (:file "package")


               ))



