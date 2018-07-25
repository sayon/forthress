global current-reachable-value 
1 current-reachable-value !

: gc-flip-reachable
  current-reachable-value @ not current-reachable-value !
;

: gc-mark-reachable [managed-only]
    current-reachable-value @
    over object-chunk-start >chunk-mark !
;

: gc-mark-non-collectable [managed-only]
    0 over object-chunk-start >chunk-collectable ! ;

: gc-mark-reachable-recursive rec [managed-only]
    dup gc-mark-reachable
    recurse-addr object-for-each-field
;

: gc-mark-non-collectable-recursive rec [managed-only]
    dup gc-mark-non-collectable
    recurse-addr object-for-each-field
;

: gc-add-to-root-set [managed-only] gc-mark-non-collectable-recursive ;

: gc-analyze-stack-item
  dup type-of if gc-mark-reachable-recursive else drop then 
;

: gc-analyze-stack
  sp
  stack_base over - cell% / 1 + 0 for
  dup @ gc-analyze-stack-item
  cell% +
  endfor
  drop
;

: chunk-is-marked >chunk-mark @ current-reachable-value @ = ;

: gc-delete-unreachable
  heap-start
  repeat
  @ dup chunk-header% + type-of if
    dup chunk-is-marked not if
      dup >chunk-is-free @ not if
        ( ." deleting " dup chunk-show cr) 
        dup chunk-header% + delete 
      then then then
  >chunk-next dup @ not
  until
  drop ;

: gc-collect
  gc-analyze-stack
  gc-delete-unreachable
  gc-flip-reachable
;

global alloc-count
10 constant ALLOCS-BEFORE-GC

:override heap-alloc
  heap-alloc-impl
  alloc-count @ 1 + alloc-count !
  alloc-count @ ALLOCS-BEFORE-GC % if
    ( 0 alloc-count ! )
    gc-collect
  then ;



( GC test
: gc-test
  20 1 do
    r@ i
    r@ 2 % not if drop then
  loop 
;
32 i
123
123
182838
28381
132
12
4
4
1
8383 i
1 i 2 i pair new drop
8 i 9 i pair new
38 i 39 i pair new

heap-show
gc-collect
heap-show
drop
gc-collect
heap-show
)
