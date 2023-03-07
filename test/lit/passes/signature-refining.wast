;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; RUN: foreach %s %t wasm-opt --nominal --signature-refining -all -S -o - | filecheck %s

(module
  ;; $func is defined with an anyref parameter but always called with a $struct,
  ;; and we can specialize the heap type to that. That will both update the
  ;; heap type's definition as well as the types of the parameters as printed
  ;; on the function (which are derived from the heap type).

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; CHECK:      (type $sig (func (param (ref $struct))))
  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (func $func (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (struct.new $struct)
    )
  )
)

(module
  ;; As above, but the call is via call_ref.

  ;; CHECK:      (type $sig (func (param (ref $struct))))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (elem declare func $func)

  ;; CHECK:      (func $func (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call_ref $sig
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:   (ref.func $func)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call_ref $sig
      (struct.new $struct)
      (ref.func $func)
    )
  )
)

(module
  ;; A combination of call types, and the LUB is affected by all of them: one
  ;; call uses a nullable $struct, the other a non-nullable i31, so the LUB
  ;; is a nullable eqref.

  ;; CHECK:      (type $sig (func (param eqref)))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (elem declare func $func)

  ;; CHECK:      (func $func (type $sig) (param $x eqref)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (local $struct (ref null $struct))
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (local.get $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $sig
  ;; CHECK-NEXT:   (i31.new
  ;; CHECK-NEXT:    (i32.const 0)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (ref.func $func)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (local $struct (ref null $struct))
    (call $func
      ;; Use a local to avoid a bottom type.
      (local.get $struct)
    )
    (call_ref $sig
      (i31.new (i32.const 0))
      (ref.func $func)
    )
  )
)

(module
  ;; Multiple functions with the same heap type. Again, the LUB is in the
  ;; middle, this time the parent $struct and not a subtype.

  ;; CHECK:      (type $sig (func (param (ref $struct))))
  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (type $struct (struct ))

  ;; CHECK:      (type $struct-sub1 (struct_subtype  $struct))
  (type $struct-sub1 (struct_subtype $struct))

  ;; CHECK:      (type $struct-sub2 (struct_subtype  $struct))
  (type $struct-sub2 (struct_subtype $struct))

  (type $struct (struct))

  ;; CHECK:      (func $func-1 (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func-1 (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $func-2 (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func-2 (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func-1
  ;; CHECK-NEXT:   (struct.new_default $struct-sub1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $func-2
  ;; CHECK-NEXT:   (struct.new_default $struct-sub2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func-1
      (struct.new $struct-sub1)
    )
    (call $func-2
      (struct.new $struct-sub2)
    )
  )
)

(module
  ;; As above, but now only one of the functions is called. The other is still
  ;; updated, though, as they share a heap type.

  ;; CHECK:      (type $sig (func (param (ref $struct))))
  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (func $func-1 (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func-1 (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $func-2 (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func-2 (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func-1
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func-1
      (struct.new $struct)
    )
  )
)

(module
  ;; Define a field in the struct of the signature type that will be updated,
  ;; to check for proper validation after the update.

  ;; CHECK:      (type $sig (func (param (ref $struct) (ref $sig))))
  (type $sig (func_subtype (param anyref funcref) func))

  ;; CHECK:      (type $struct (struct (field (ref $sig))))
  (type $struct (struct_subtype (field (ref $sig)) data))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (elem declare func $func)

  ;; CHECK:      (func $func (type $sig) (param $x (ref $struct)) (param $f (ref $sig))
  ;; CHECK-NEXT:  (local $temp (ref null $sig))
  ;; CHECK-NEXT:  (local $3 funcref)
  ;; CHECK-NEXT:  (local.set $3
  ;; CHECK-NEXT:   (local.get $f)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (block
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (local.set $3
  ;; CHECK-NEXT:    (local.get $temp)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref) (param $f funcref)
    ;; Define a local of the signature type that is updated.
    (local $temp (ref null $sig))
    ;; Do a local.get of the param, to verify its type is valid.
    (drop
      (local.get $x)
    )
    ;; Copy from a funcref local to the formerly funcref param to verify their
    ;; types are still compatible after the update. Note that we will need to
    ;; add a fixup local here, as $f's new type becomes too specific to be
    ;; assigned the value here.
    (local.set $f
      (local.get $temp)
    )
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (struct.new $struct
  ;; CHECK-NEXT:    (ref.func $func)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (ref.func $func)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (struct.new $struct
        (ref.func $func)
      )
      (ref.func $func)
    )
  )
)

(module
  ;; An unreachable value does not prevent optimization: we will update the
  ;; param to be $struct.

  ;; CHECK:      (type $sig (func (param (ref $struct))))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (elem declare func $func)

  ;; CHECK:      (func $func (type $sig) (param $x (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $sig
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:   (ref.func $func)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (struct.new $struct)
    )
    (call_ref $sig
      (unreachable)
      (ref.func $func)
    )
  )
)

(module
  ;; When we have only unreachable values, there is nothing to optimize, and we
  ;; should not crash.

  (type $struct (struct))

  ;; CHECK:      (type $sig (func (param anyref)))
  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (elem declare func $func)

  ;; CHECK:      (func $func (type $sig) (param $x anyref)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call_ref $sig
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:   (ref.func $func)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call_ref $sig
      (unreachable)
      (ref.func $func)
    )
  )
)

(module
  ;; When we have no calls, there is nothing to optimize, and we should not
  ;; crash.

  (type $struct (struct))

  ;; CHECK:      (type $sig (func (param anyref)))
  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (func $func (type $sig) (param $x anyref)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )
)

(module
  ;; Test multiple fields in multiple types.
  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; CHECK:      (type $sig-2 (func (param eqref (ref $struct))))

  ;; CHECK:      (type $sig-1 (func (param structref anyref)))
  (type $sig-1 (func_subtype (param anyref) (param anyref) func))
  (type $sig-2 (func_subtype (param anyref) (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (elem declare func $func-2)

  ;; CHECK:      (func $func-1 (type $sig-1) (param $x structref) (param $y anyref)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func-1 (type $sig-1) (param $x anyref) (param $y anyref)
  )

  ;; CHECK:      (func $func-2 (type $sig-2) (param $x eqref) (param $y (ref $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func-2 (type $sig-2) (param $x anyref) (param $y anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (local $any anyref)
  ;; CHECK-NEXT:  (local $struct structref)
  ;; CHECK-NEXT:  (local $i31 i31ref)
  ;; CHECK-NEXT:  (call $func-1
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:   (local.get $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $func-1
  ;; CHECK-NEXT:   (local.get $struct)
  ;; CHECK-NEXT:   (local.get $any)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $func-2
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $sig-2
  ;; CHECK-NEXT:   (local.get $i31)
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:   (ref.func $func-2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (local $any (ref null any))
    (local $struct (ref null struct))
    (local $i31 (ref null i31))

    (call $func-1
      (struct.new $struct)
      (local.get $struct)
    )
    (call $func-1
      (local.get $struct)
      (local.get $any)
    )
    (call $func-2
      (struct.new $struct)
      (struct.new $struct)
    )
    (call_ref $sig-2
      (local.get $i31)
      (struct.new $struct)
      (ref.func $func-2)
    )
  )
)

(module
  ;; The presence of a table prevents us from doing any optimizations.

  ;; CHECK:      (type $sig (func (param anyref)))
  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  (table 1 1 anyref)

  ;; CHECK:      (table $0 1 1 anyref)

  ;; CHECK:      (func $func (type $sig) (param $x anyref)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (struct.new $struct)
    )
  )
)

(module
  ;; Pass a null in one call to the function. The null can be updated which
  ;; allows us to refine (but the new type must be nullable).

  ;; CHECK:      (type $struct (struct ))

  ;; CHECK:      (type $sig (func (param (ref null $struct))))
  (type $sig (func_subtype (param anyref) func))

  (type $struct (struct))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (func $func (type $sig) (param $x (ref null $struct))
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (ref.null none)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (struct.new $struct)
    )
    (call $func
      (ref.null none)
    )
  )
)

(module
  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; This signature has a single function using it, which returns a more
  ;; refined type, and we can refine to that.
  ;; CHECK:      (type $sig-can-refine (func (result (ref $struct))))
  (type $sig-can-refine (func_subtype (result anyref) func))

  ;; Also a single function, but no refinement is possible.
  ;; CHECK:      (type $sig-cannot-refine (func (result (ref func))))
  (type $sig-cannot-refine (func_subtype (result (ref func)) func))

  ;; The single function never returns, so no refinement is possible.
  ;; CHECK:      (type $sig-unreachable (func (result anyref)))
  (type $sig-unreachable (func_subtype (result anyref) func))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (elem declare func $func-can-refine $func-cannot-refine)

  ;; CHECK:      (func $func-can-refine (type $sig-can-refine) (result (ref $struct))
  ;; CHECK-NEXT:  (struct.new_default $struct)
  ;; CHECK-NEXT: )
  (func $func-can-refine (type $sig-can-refine) (result anyref)
    (struct.new $struct)
  )

  ;; CHECK:      (func $func-cannot-refine (type $sig-cannot-refine) (result (ref func))
  ;; CHECK-NEXT:  (select (result (ref func))
  ;; CHECK-NEXT:   (ref.func $func-can-refine)
  ;; CHECK-NEXT:   (ref.func $func-cannot-refine)
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $func-cannot-refine (type $sig-cannot-refine) (result (ref func))
    (select
      (ref.func $func-can-refine)
      (ref.func $func-cannot-refine)
      (i32.const 0)
    )
  )

  ;; CHECK:      (func $func-unreachable (type $sig-unreachable) (result anyref)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $func-unreachable (type $sig-unreachable) (result anyref)
    (unreachable)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (if (result (ref $struct))
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:    (call $func-can-refine)
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (if (result (ref $struct))
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:    (call_ref $sig-can-refine
  ;; CHECK-NEXT:     (ref.func $func-can-refine)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    ;; Add a call to see that we update call types properly.
    ;; Put the call in an if so the refinalize will update the if type and get
    ;; printed out conveniently.
    (drop
      (if (result anyref)
        (i32.const 1)
        (call $func-can-refine)
        (unreachable)
      )
    )
    ;; The same with a call_ref.
    (drop
      (if (result anyref)
        (i32.const 1)
        (call_ref $sig-can-refine
          (ref.func $func-can-refine)
        )
        (unreachable)
      )
    )
  )
)

(module
  ;; CHECK:      (type $sig (func (result (ref null $struct))))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; This signature has multiple functions using it, and some of them have nulls
  ;; which should be updated when we refine.
  (type $sig (func_subtype (result anyref) func))

  ;; CHECK:      (func $func-1 (type $sig) (result (ref null $struct))
  ;; CHECK-NEXT:  (struct.new_default $struct)
  ;; CHECK-NEXT: )
  (func $func-1 (type $sig) (result anyref)
    (struct.new $struct)
  )

  ;; CHECK:      (func $func-2 (type $sig) (result (ref null $struct))
  ;; CHECK-NEXT:  (ref.null none)
  ;; CHECK-NEXT: )
  (func $func-2 (type $sig) (result anyref)
    (ref.null any)
  )

  ;; CHECK:      (func $func-3 (type $sig) (result (ref null $struct))
  ;; CHECK-NEXT:  (ref.null none)
  ;; CHECK-NEXT: )
  (func $func-3 (type $sig) (result anyref)
    (ref.null eq)
  )

  ;; CHECK:      (func $func-4 (type $sig) (result (ref null $struct))
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:   (return
  ;; CHECK-NEXT:    (ref.null none)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $func-4 (type $sig) (result anyref)
    (if
      (i32.const 1)
      (return
        (ref.null any)
      )
    )
    (unreachable)
  )
)

;; Exports prevent optimization, so $func's type will not change here.
(module
  ;; CHECK:      (type $sig (func (param anyref)))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  (type $sig (func_subtype (param anyref) func))

  ;; CHECK:      (export "prevent-opts" (func $func))

  ;; CHECK:      (func $func (type $sig) (param $x anyref)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $func (export "prevent-opts") (type $sig) (param $x anyref)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (struct.new $struct)
    )
  )
)

(module
  ;; CHECK:      (type $A (func (param i32)))
  (type $A (func_subtype (param i32) func))
  ;; CHECK:      (type $B (func_subtype (param i32) $A))
  (type $B (func_subtype (param i32) $A))

  ;; CHECK:      (func $bar (type $B) (param $x i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $bar (type $B) (param $x i32)
   ;; The parameter to this function can be pruned. But while doing so we must
   ;; properly preserve the subtyping of $B from $A, which means we cannot just
   ;; remove it - we'd need to remove it from $A as well, which we don't
   ;; attempt to do in the pass atm. So we do not optimize here.
    (nop)
  )
)

(module
  ;; CHECK:      (type $ref|${}|_i32_=>_none (func (param (ref ${}) i32)))

  ;; CHECK:      (type ${} (struct ))
  (type ${} (struct))

  ;; CHECK:      (func $foo (type $ref|${}|_i32_=>_none) (param $ref (ref ${})) (param $i32 i32)
  ;; CHECK-NEXT:  (local $2 eqref)
  ;; CHECK-NEXT:  (local.set $2
  ;; CHECK-NEXT:   (local.get $ref)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (block
  ;; CHECK-NEXT:   (call $foo
  ;; CHECK-NEXT:    (block
  ;; CHECK-NEXT:     (unreachable)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (i32.const 0)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (local.set $2
  ;; CHECK-NEXT:    (ref.null none)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $foo (param $ref eqref) (param $i32 i32)
    (call $foo
      ;; The only reference to the ${} type is in this block signature. Even
      ;; this will go away in the internal ReFinalize (which makes the block
      ;; type unreachable).
      (block (result (ref ${}))
        (unreachable)
      )
      (i32.const 0)
    )
    ;; Write something of type eqref into $ref. When we refine the type of the
    ;; parameter from eqref to ${} we must do something here, as we can no
    ;; longer just write this (ref.null eq) into a parameter of the more
    ;; refined type. While doing so, we must not be confused by the fact that
    ;; the only mention of ${} in the original module gets removed during our
    ;; processing, as mentioned in the earlier comment. This is a regression
    ;; test for a crash because of that.
    (local.set $ref
      (ref.null eq)
    )
  )
)

;; Do not modify the types used on imported functions (until the spec and VM
;; support becomes stable).
(module
  ;; CHECK:      (type $structref_=>_none (func (param structref)))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; CHECK:      (import "a" "b" (func $import (param structref)))
  (import "a" "b" (func $import (param (ref null struct))))

  ;; CHECK:      (func $test (type $none_=>_none)
  ;; CHECK-NEXT:  (call $import
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $test
    (call $import
      (struct.new $struct)
    )
  )
)

;; If we refine a type, that may require changes to its subtypes. For now, we
;; skip such optimizations. TODO
(module
  (rec
    ;; CHECK:      (type $A (func (param (ref null $B)) (result (ref null $A))))
    (type $A (func         (param (ref null $B)) (result (ref null $A))))
    ;; CHECK:      (type $B (func_subtype (param (ref null $A)) (result (ref null $B)) $A))
    (type $B (func_subtype (param (ref null $A)) (result (ref null $B)) $A))
  )

  ;; CHECK:      (elem declare func $func)

  ;; CHECK:      (func $func (type $A) (param $0 (ref null $B)) (result (ref null $A))
  ;; CHECK-NEXT:  (ref.func $func)
  ;; CHECK-NEXT: )
  (func $func (type $A) (param $0 (ref null $B)) (result (ref null $A))
    ;; This result is non-nullable, and we could refine type $A accordingly. But
    ;; if we did that, we'd need to refine $B as well.
    (ref.func $func)
  )
)

;; Until we handle contravariance, do not try to optimize a type that has a
;; supertype. In this example, refining the child's anyref to nullref would
;; cause an error.
(module
  ;; CHECK:      (type $parent (func (param anyref)))
  (type $parent (func (param anyref)))
  ;; CHECK:      (type $child (func_subtype (param anyref) $parent))
  (type $child (func_subtype (param anyref) $parent))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (func $func (type $child) (param $0 anyref)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $func (type $child) (param anyref)
    (unreachable)
  )

  ;; CHECK:      (func $caller (type $none_=>_none)
  ;; CHECK-NEXT:  (call $func
  ;; CHECK-NEXT:   (ref.null none)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $caller
    (call $func
      (ref.null eq)
    )
  )
)
