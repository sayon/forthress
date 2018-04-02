: IMMEDIATE  last_word @ cfa 1 - dup c@ 1 or swap c! ;

: rot >r swap r> swap ;
: -rot swap >r swap  r> ;

: over >r dup r> swap ;
: 2dup over over ;

: <> = not ;
: <= 2dup < -rot =  lor ;
: > <= not ;
: >= < not ; 


: cell% 8 ;
: cells cell% * ;
: KB 1024 * ;
: MB KB KB  ;

: allot dp @ swap over + dp ! ;

: begin here ; IMMEDIATE
: again ' branch , , ; IMMEDIATE

: if ' 0branch , here 0  , ; IMMEDIATE
: else ' branch , here 0 , swap here swap !  ; IMMEDIATE
: then here swap ! ; IMMEDIATE
: endif ' then execute ; IMMEDIATE

: repeat here ; IMMEDIATE
: until  ' 0branch , , ; IMMEDIATE


: for 
      ' swap ,
      ' >r , 
      ' >r , 
here  ' r> , 
      ' r> , 
      ' 2dup , 
      ' >r , 
      ' >r , 
      ' < ,  
      ' 0branch ,  
here    0 , 
       swap ; IMMEDIATE

: endfor 
      ' r> , 
      ' lit , 1 ,   
        ' + , 
       ' >r , 
   ' branch , 
            ,  here swap ! 
       ' r> , 
     ' drop , 
       ' r> , 
     ' drop ,  

;  IMMEDIATE

: do  ' swap , ' >r , ' >r ,  here ; IMMEDIATE

: loop 
        ' r> , 
        ' lit , 1 , 
        ' + , 
        ' dup ,     
        ' r@ , 
        ' < , 
        ' not , 
        '  swap , 
        ' >r , 
        ' 0branch , ,
        ' r> , 
        ' drop ,
        ' r> , 
        ' drop ,
 ;  IMMEDIATE


: sys-read-no 0 ;
: sys-write-no 1 ;

: sys-read  >r >r >r sys-read-no r> r> r> 0 0 0  syscall drop ;
: sys-write >r >r >r sys-write-no r> r> r> 0 0 0  syscall drop ;

: readc@ in_fd @ swap 1 sys-read ;
: readc inbuf readc@ drop inbuf c@ ;

: ( repeat readc 41 - not until ; IMMEDIATE

( Now we can define comments :)


: 2drop drop drop ;
: 2over >r >r dup r> swap r> swap ;
: case 0 ; IMMEDIATE
: of ' over , ' = , ' if execute ' drop , ; IMMEDIATE
: endof ' else execute ; IMMEDIATE
: endcase ' drop , dup if repeat ' then execute dup not until drop then  ; IMMEDIATE


( num from to -- 1/0)
: in-range rot swap over >= -rot <= land ;

( 1 if we are compiling )
: compiling state @ ;

: compnumber compiling if ' lit , , then ;

( -- input character's code )
: .' readc compnumber ; IMMEDIATE

: readce readc dup .' \ = if
         readc dup .' n = if
           drop drop 10
         else
           drop drop 0
         then
then
;

: cr 10 emit ;
: QUOTE 34 ;

: _"
  compiling if
    ' branch , here 0 , here
    repeat
readc dup 34 =
if
  drop
  0 c, ( null terminator )
  ( label_to_link string_start )
  swap
  ( string_start label_to_link )
  here swap !
  ( string_start )
  ' lit , , 1
else c, 0
then
    until
  else
    repeat
readce dup 34 = if drop 1 else emit 0 then
    until 
  then ; IMMEDIATE

: " compiling if
      ' branch , here 0 , here
      repeat
readce dup 34 =
if
  drop
  0 c, ( null terminator )
  ( label_to_link string_start )
  swap
  ( string_start label_to_link )
  here swap !
  ( string_start )
  ' lit , , 1
else c, 0
then
      until
    else
      repeat
readce dup 34 = if drop 1 else emit 0 then
      until 
    then ; IMMEDIATE

: g" 
    dp @ 

    repeat
        readce dup 34 = if 
            drop 0 1 allot c! 1 
        else 1 allot c! 0 then
    until 
  
    compiling if 
    ' lit , , 
    then ; IMMEDIATE


: ." ' " execute compiling if ' prints , then ; IMMEDIATE

: read-digit readc dup .' 0 .' 9 in-range if .' 0 - else drop -1 then ;
: read-hex-digit
  readc dup .' 0 .' 9 in-range if
    .' 0 -
  else dup .' a .' f in-range if
         .' a - 10 +
       else dup .' A .' F in-range if
              .' A - 10 +
    else
    drop -1 then
    then
then ;

: read-oct-digit
readc dup .' 0 .' 7 in-range if
    .' 0 -
    else
    drop -1
then ;

: 08x 0
repeat
read-oct-digit dup -1 = if
    else
    swap 8 * swap +
    0
    then
until
compnumber
; IMMEDIATE

( adds hexadecimal literals )
: 0x 0
repeat
read-hex-digit dup -1 = if
    else
    swap 16 * swap +
    0
    then

until
compnumber
; IMMEDIATE


( File I/O )
: O_APPEND 0x 400 ;
: O_CREAT 0x 40 ;
: O_TRUNC 0x 200 ;
: O_RDWR 0x 2 ;
: O_WRONLY 0x 1 ;
: O_RDONLY 0x 0 ;

: sys-open-no 2 ;

: sys-open  >r >r >r sys-open-no r> r> r> 0 0 0 syscall drop ;

: sys-close-no 3 ;
: sys-close  >r sys-close-no r> 0 0 0 0 0 syscall drop ;

: file-create O_RDWR O_CREAT O_TRUNC or or  08x 700 sys-open ;
: file-open-append O_APPEND O_RDWR O_CREAT or or  08x 700 sys-open ;
: file-open-read  O_RDONLY 08x 700 sys-open ;
: file-close sys-close drop ;

( fd string - )
: file-print count sys-write ;

: include
    inbuf word drop
    inbuf file-open-append >r
    ( place descriptor on top of data stack and interpret it )
    r@ interpret-fd
    r@ file-close
    r> drop ;


: global inbuf word drop 0  inbuf create ' docol @ , ' lit , cell% allot , ' exit ,  ;
: constant inbuf word drop 0 inbuf create ' docol @ , ' lit , , ' exit , ;

( structures )
: struct 0 ;
: field over inbuf word drop 0 inbuf create ' docol @ , ' lit , , ' + ,  ' exit , + ;
: end-struct constant  ;

include diagnostics.frt
include doc-engine.frt
include documentation.frt

16 MB ( heap size )
include heap.frt
drop

include string.frt
include hash.frt 

: enum 0 repeat
    inbuf word drop dup
    0 inbuf create ' docol @ , ' lit , ,  ' exit ,
    1 +
    " end"
    inbuf string-eq until drop ;


include recursion.frt

include runtime-meta.frt
include managed-string.frt

." Forthress -- a tiny Forth from scratch > (c) Igor Zhirkov 2017-2018 " cr

include fib.frt

include native.frt

