;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt %s -all -S -o - | filecheck %s
;; RUN: wasm-opt %s -all --roundtrip -S -o - | filecheck %s

(module
  ;; CHECK:      (type $0 (func (param (ref null (shared i31))) (result i32)))

  ;; CHECK:      (type $1 (func (param i32) (result (ref (shared i31)))))

  ;; CHECK:      (func $make (type $1) (param $0 i32) (result (ref (shared i31)))
  ;; CHECK-NEXT:  (ref.i31_shared
  ;; CHECK-NEXT:   (local.get $0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $make (param i32) (result (ref (shared i31)))
    (ref.i31_shared (local.get 0))
  )

  ;; CHECK:      (func $get_s (type $0) (param $0 (ref null (shared i31))) (result i32)
  ;; CHECK-NEXT:  (i31.get_s
  ;; CHECK-NEXT:   (local.get $0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $get_s (param (ref null (shared i31))) (result i32)
    (i31.get_s (local.get 0))
  )

  ;; CHECK:      (func $get_u (type $0) (param $0 (ref null (shared i31))) (result i32)
  ;; CHECK-NEXT:  (i31.get_u
  ;; CHECK-NEXT:   (local.get $0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $get_u (param (ref null (shared i31))) (result i32)
    (i31.get_u (local.get 0))
  )
)