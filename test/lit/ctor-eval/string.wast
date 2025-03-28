;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; RUN: foreach %s %t wasm-ctor-eval --ctors=test --kept-exports=test --quiet -all -S -o - | filecheck %s

;; We should not error on precomputing this string. Nothing should change in
;; the output, as precomputing a string results in an identical string.

(module
 (global $global (ref string) (string.const "one"))

 (export "test" (func $test))

 (func $test (result externref)
  (global.get $global)
 )
)
;; CHECK:      (type $0 (func (result externref)))

;; CHECK:      (export "test" (func $test_1))

;; CHECK:      (func $test_1 (type $0) (result externref)
;; CHECK-NEXT:  (string.const "one")
;; CHECK-NEXT: )
