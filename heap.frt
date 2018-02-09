include mmap.frt 

( Each heap entry has a header:
| next | is-free | ptrmeta | 
)

struct
    cell% field >chunk-next
    cell% field >chunk-sig
    cell% field >chunk-is-free
    cell% field >chunk-meta
end-struct chunk-header%

0x DEADBEEF constant CHUNK_SIG

: chunk-min-size chunk-header% dup +  ;

global heap-start
global heap-size

( a - 0/1 )
: chunk-is-last >chunk-next @ 0 = ;

( First address after the heap )
: heap-last-address heap-size @ heap-start @ + ;

( a - sz )
: chunk-size 
    dup chunk-is-last if 
        heap-last-address swap - 
        else dup >chunk-next @ swap -  
        then ;

( a - )
: chunk-capacity chunk-size chunk-header% - ;

( a - )
: chunk-mark-free >chunk-is-free 1 swap ! ;

( a - )
: chunk-mark-alloc >chunk-is-free 0 swap ! ;

( a - )
: chunk-init 
    dup >chunk-sig  CHUNK_SIG swap !
    dup >chunk-next 0 swap ! 
    dup chunk-mark-free
    >chunk-meta 0 swap ! ;

( size - 1/0 )
: heap-init 
    dup chunk-min-size < if
        drop 0
    else
        dup
        sys-mmap dup if 
            dup chunk-init
            heap-start ! 
            heap-size ! 
            1
        else 
        drop drop 0
        then
    then ;

( a -- 1/0 )
: chunk-try-merge >r
    r@ chunk-is-last not if  
        r@ >chunk-is-free @  r@ >chunk-next @ >chunk-is-free @ land if 
            r@ >chunk-next @ >chunk-next @ 
            r@ >chunk-next ! 1 
        else 0 then  
    else 0 then
    r> drop ;

( a --  )
: chunk-iterate-try-merge 
    dup chunk-try-merge if
        repeat
            dup chunk-try-merge
        not until
        drop 
    else drop then 
;

( sz - addr )
: heap-first-free-of-size >r heap-start 
    repeat
    @ 
    dup if 
        dup chunk-iterate-try-merge
        dup >chunk-is-free @ over chunk-capacity r@ >= land 
        else 1
        then
    until 
    r> drop ;


( a query - 0/1 )
: chunk-should-split swap 
    chunk-size chunk-min-size -  1 swap 
    ( q 1 [size - minsize]  ) 
    in-range ;

( a query  - )
: chunk-split
    over + 
    dup chunk-init 
    >r ( a, a2 )
    dup >chunk-next @ ( a oldnext , a2 )
    r@ >chunk-next ! 
    r> swap >chunk-next ! 
;

( sz - addr )
: heap-alloc
chunk-header% +  ( HERE ) 
dup heap-first-free-of-size dup if 
        ( sz a )
        swap 2dup chunk-should-split  if 
            ( a sz )
             over >r chunk-split r> 
        else ( a sz )
            drop
        then
        dup chunk-mark-alloc
		chunk-header% + 
    else
        drop drop 0
    then ;

( a - )
: heap-free chunk-header% - chunk-mark-free ; 

( should contain a printer of form: )
( chunk-contents-addr *metainf -- )
global heap-meta-printer

: chunk-show
    ." at " dup . ."  "
    ." | next: "
    dup >chunk-next @ .
    ."  | "
    dup >chunk-is-free @ if ." FREE " else ." ALLOC" 
            ."  | "
            dup >chunk-meta @ dup if
            ( *chunk-start *metainf )
            over chunk-header% + swap  
            ( *chunk-start *chunk-contents  *metainf )
            
            heap-meta-printer @ execute
            else ." <no meta> " drop then 
        then
    ."  | size: " 
    chunk-size . cr
;

: heap-show
    ." Heap size: " heap-size @ . cr
    heap-start
    repeat
       @ dup chunk-show
       >chunk-next dup @ not 
    until 
   drop
; 

: addr-in-heap  heap-start @ heap-last-address 1 - in-range ;

: addr-not-in-first-chunk heap-start @ dup chunk-header% + 1 - in-range not ;

: addr-is-chunk-start
  dup addr-in-heap over addr-not-in-first-chunk land if
        chunk-header% - >chunk-sig @ CHUNK_SIG =  
  else drop 0 then
;

: chunk-show-meta
    dup chunk-header% - >chunk-meta @ dup if 
    ( chunk meta - ) 
    ." <" heap-meta-printer @ execute ." >"  
    else drop drop 
    then  
;

: decompile 
   dup addr-is-chunk-start if 
   dup . ."  " chunk-show-meta  
  else  decompile then 
;

heap-init 
