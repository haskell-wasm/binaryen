;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt %s -all -o %t.text.wast -g -S
;; RUN: wasm-as %s -all -g -o %t.wasm
;; RUN: wasm-dis %t.wasm -all -o %t.bin.wast
;; RUN: wasm-as %s -all -o %t.nodebug.wasm
;; RUN: wasm-dis %t.nodebug.wasm -all -o %t.bin.nodebug.wast
;; RUN: cat %t.text.wast | filecheck %s --check-prefix=CHECK-TEXT
;; RUN: cat %t.bin.wast | filecheck %s --check-prefix=CHECK-BIN
;; RUN: cat %t.bin.nodebug.wast | filecheck %s --check-prefix=CHECK-BIN-NODEBUG

(module
 ;; CHECK-TEXT:      (type $0 (func (param i32) (result i64)))

 ;; CHECK-TEXT:      (type $1 (func (result i64)))

 ;; CHECK-TEXT:      (tag $t (type $0) (param i32) (result i64))
 ;; CHECK-BIN:      (type $0 (func (param i32) (result i64)))

 ;; CHECK-BIN:      (type $1 (func (result i64)))

 ;; CHECK-BIN:      (tag $t (type $0) (param i32) (result i64))
 (tag $t (param i32) (result i64))

 ;; CHECK-TEXT:      (func $f (type $1) (result i64)
 ;; CHECK-TEXT-NEXT:  (suspend $t
 ;; CHECK-TEXT-NEXT:   (i32.const 123)
 ;; CHECK-TEXT-NEXT:  )
 ;; CHECK-TEXT-NEXT: )
 ;; CHECK-BIN:      (func $f (type $1) (result i64)
 ;; CHECK-BIN-NEXT:  (suspend $t
 ;; CHECK-BIN-NEXT:   (i32.const 123)
 ;; CHECK-BIN-NEXT:  )
 ;; CHECK-BIN-NEXT: )
 (func $f (result i64)
   (suspend $t (i32.const 123))
 )
)
;; CHECK-BIN-NODEBUG:      (type $0 (func (param i32) (result i64)))

;; CHECK-BIN-NODEBUG:      (type $1 (func (result i64)))

;; CHECK-BIN-NODEBUG:      (tag $tag$0 (type $0) (param i32) (result i64))

;; CHECK-BIN-NODEBUG:      (func $0 (type $1) (result i64)
;; CHECK-BIN-NODEBUG-NEXT:  (suspend $tag$0
;; CHECK-BIN-NODEBUG-NEXT:   (i32.const 123)
;; CHECK-BIN-NODEBUG-NEXT:  )
;; CHECK-BIN-NODEBUG-NEXT: )
