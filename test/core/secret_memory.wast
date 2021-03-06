(module (memory secret 0 1))

(assert_invalid (module (memory secret 0 1) (memory secret 0 2)) "multiple memories are not allowed (yet)")

(assert_invalid
    (module
        (memory secret 0)
        (func (i32.load (i32.const 0)))
    ) "cannot perform public memop on secret memory")

(assert_invalid
    (module
        (memory 0)
        (func (s32.load (i32.const 0)))
    ) "cannot perform secret memop on public memory")

(module
    (memory secret 0)

    (func (export "load_at_zero") (result s32) (s32.load (i32.const 0)))
    (func (export "store_at_zero") (s32.store (i32.const 0) (s32.const 2)))

    (func (export "load_at_page_size") (result s32) (s32.load (i32.const 0x10000)))
    (func (export "store_at_page_size") (s32.store (i32.const 0x10000) (s32.const 3)))

    (func (export "grow") (param $sz i32) (result i32) (grow_memory (get_local $sz)))
    (func (export "size") (result i32) (current_memory))
)

(assert_return (invoke "size") (i32.const 0))
(assert_trap (invoke "store_at_zero") "out of bounds memory access")
(assert_trap (invoke "load_at_zero") "out of bounds memory access")
(assert_trap (invoke "store_at_page_size") "out of bounds memory access")
(assert_trap (invoke "load_at_page_size") "out of bounds memory access")
(assert_return (invoke "grow" (i32.const 1)) (i32.const 0))
(assert_return (invoke "size") (i32.const 1))
(assert_return (invoke "load_at_zero") (s32.const 0))
(assert_return (invoke "store_at_zero"))
(assert_return (invoke "load_at_zero") (s32.const 2))
(assert_trap (invoke "store_at_page_size") "out of bounds memory access")
(assert_trap (invoke "load_at_page_size") "out of bounds memory access")
(assert_return (invoke "grow" (i32.const 4)) (i32.const 1))
(assert_return (invoke "size") (i32.const 5))
(assert_return (invoke "load_at_zero") (s32.const 2))
(assert_return (invoke "store_at_zero"))
(assert_return (invoke "load_at_zero") (s32.const 2))
(assert_return (invoke "load_at_page_size") (s32.const 0))
(assert_return (invoke "store_at_page_size"))
(assert_return (invoke "load_at_page_size") (s32.const 3))


(module
  (memory secret 0)
  (func (export "grow") (param i32) (result i32) (grow_memory (get_local 0)))
)

(assert_return (invoke "grow" (i32.const 0)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 1)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 0)) (i32.const 1))
(assert_return (invoke "grow" (i32.const 2)) (i32.const 1))
(assert_return (invoke "grow" (i32.const 800)) (i32.const 3))
(assert_return (invoke "grow" (i32.const 0x10000)) (i32.const -1))

(module
  (memory secret 0 10)
  (func (export "grow") (param i32) (result i32) (grow_memory (get_local 0)))
)

(assert_return (invoke "grow" (i32.const 0)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 1)) (i32.const 0))
(assert_return (invoke "grow" (i32.const 1)) (i32.const 1))
(assert_return (invoke "grow" (i32.const 2)) (i32.const 2))
(assert_return (invoke "grow" (i32.const 6)) (i32.const 4))
(assert_return (invoke "grow" (i32.const 0)) (i32.const 10))
(assert_return (invoke "grow" (i32.const 1)) (i32.const -1))
(assert_return (invoke "grow" (i32.const 0x10000)) (i32.const -1))
