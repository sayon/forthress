include mmap.frt 
 
: heap-header-size 2 cells ;

: heap-chunk-min-size heap-header-size dup +  ;

global heap-start
global heap-size

( a - a )
: heap-chunk-next @ ;  

( a next - )
: heap-chunk-set-next swap ! ;

( a - 0/1 )
: heap-chunk-is-last heap-chunk-next 0 = ;

: heap-last-address heap-size @ heap-start @ + ;

( a - sz )
: heap-chunk-size 
    dup heap-chunk-is-last if 
        heap-last-address swap - 
        else dup heap-chunk-next swap -  
        then ;

( a - )
: heap-chunk-capacity heap-chunk-size heap-header-size - ;

( a - a )
: >is-free cell% + ;

( a - )
: heap-chunk-set-free swap >is-free ! ;

( a - 1/0 )
: heap-chunk-is-free >is-free @ ;

( a - )
: heap-chunk-init dup 
    0 heap-chunk-set-next 
    1 heap-chunk-set-free ;

( size - 1/0 )
: heap-init 
    dup heap-chunk-min-size < if
        drop 0
    else
        dup
        sys-mmap dup if 
        dup heap-chunk-init 
        heap-start ! 
        heap-size ! 
        1
        else 
        drop drop 0
        then
    then ;

( a -- 1/0 )
: heap-chunk-try-merge >r
    r@ heap-chunk-is-last not if  
        r@ heap-chunk-is-free r@ heap-chunk-next heap-chunk-is-free land if 
            r@ dup heap-chunk-next heap-chunk-next  heap-chunk-set-next 1
        else 0 then  
    else 0 then
    r> drop ;

( sz - addr )
: heap-first-free-of-size >r heap-start 
    repeat
    @ 
    dup if repeat dup heap-chunk-try-merge not until else then 
    dup if 
            dup heap-chunk-is-free over heap-chunk-capacity r@ >= land 
        else 1
        then
    until 
    r> drop ;


( a query - 0/1 )
: heap-chunk-should-split swap 
    heap-chunk-size heap-chunk-min-size -  1 swap 
    ( q 1 [size - minsize]  ) 
    in-range ;

( a query  - )
: heap-chunk-split
    over + >r ( a, a2 )
    dup heap-chunk-next  ( a oldnext , a2 )
    r@ heap-chunk-init 
    r@ swap heap-chunk-set-next 
    dup r> heap-chunk-set-next ;

( sz - addr )
: heap-alloc
heap-header-size + 
dup heap-first-free-of-size dup if 
        ( sz a )
        swap 2dup heap-chunk-should-split  if 
            ( a sz )
             over >r heap-chunk-split r> 
        else ( a sz )
            drop
        then 
        0 heap-chunk-set-free
		heap-header-size + 
    else
        drop drop 0
    then ;

( a - )
: heap-free heap-header-size - 1 heap-chunk-set-free ;


heap-init 
