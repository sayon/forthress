: gc-set-collectable swap managed-only object-chunk-start >chunk-collectable ! ;

: gc-mark-collectable
dup type-of not if drop exit then
object-chunk-start >chunk-collectable 1 swap ! ;
: gc-mark-non-collectable 
dup type-of not if drop exit then
." non collectable: " dup show  cr
                          object-chunk-start >chunk-collectable 0 swap ! ;

: gc-mark-non-collectable-recursive rec stop-if-null
                                    dup gc-mark-non-collectable
                                    recurse-addr object-for-each-field ;
: gc-mark-collectable-recursive rec stop-if-null managed-only
                                dup gc-mark-collectable
                                recurse-addr object-for-each-field ;

global gc-reachable-value
1 gc-reachable-value !

: gc-update-reachable-value
  gc-reachable-value @ 1 +
  gc-reachable-value ! ;

: gc-is-reachable managed-only
  object-chunk-start >chunk-mark @ gc-reachable-value @ =
;

: gc-mark-reachable stop-if-null managed-only
    gc-reachable-value @ swap
    object-chunk-start >chunk-mark !
;


: gc-mark-reachable-recursive rec stop-if-null managed-only
    dup gc-is-reachable if drop exit then 
    dup gc-mark-reachable
    recurse-addr object-for-each-field
;


global gc-root-set
0 gc-root-set !

: gc-add-to-root-set
  Ref new
  dup gc-mark-non-collectable
  gc-root-set @ swap list-prepend
  dup gc-mark-non-collectable
  gc-root-set !
                     ( gc-root-set @ >list-value @ gc-mark-non-collectable)
;

: gc-analyze-reference stop-if-null
                       dup type-of if
                         gc-mark-reachable-recursive else drop then
;

: gc-analyze-stack
  sp
  stack_base over - cell% / 1 + 0 for
  dup @ gc-analyze-reference
  cell% +
  endfor
  drop

  ret_sp
  rstack_base over - cell% / 1 + 0 for
  dup @ gc-analyze-reference
  cell% +
  endfor
  drop
;

: chunk-is-marked >chunk-mark @ gc-reachable-value @ = ;

: gc-delete-unreachable
  heap-start
  repeat
  @ dup chunk-header% + type-of if
    dup chunk-is-marked not
    over >chunk-collectable @ land
    over >chunk-is-free @ not land
    if dup chunk-header% + heap-free ( dup chunk-header% + delete ) then
  then
  >chunk-next dup @ not
  until
  drop ;

: gc-analyze-root-set
  gc-root-set @ ' gc-analyze-reference list-foreach
;

: gc-collect
  gc-analyze-stack
  gc-analyze-root-set 
  gc-delete-unreachable
  gc-update-reachable-value
;


global alloc-count
10 constant ALLOCS-BEFORE-GC

:override new
impl-new
  dup gc-mark-collectable-recursive
  alloc-count @ 1 + alloc-count !
  alloc-count @ ALLOCS-BEFORE-GC % not if
    0 alloc-count !
    gc-collect
  then
;

: managed-global
  0 Ref new
  dup gc-add-to-root-set
  >ptr ' constant execute
;

managed-global hello

:override copy
  dup gc-mark-non-collectable-recursive
  dup >r
  impl-copy
  dup gc-mark-collectable-recursive
  r> gc-mark-collectable-recursive
;

( obsolete Might be buggy in case of allocations happening during destructors 

:override delete
dup >r
r@ gc-mark-non-collectable
impl-delete
r> gc-mark-collectable
;
)

: singleton
  inbuf word drop
  dup inbuf --new-constant
  gc-add-to-root-set
;


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

