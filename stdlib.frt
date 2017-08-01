: IMMEDIATE  last_word @ cfa 1 - dup @ 1 or swap c! ;

: begin here ; IMMEDIATE
: again ' branch , , ; IMMEDIATE

: if ' 0branch , here 0  , ; IMMEDIATE
: else ' branch , here 0 , swap here swap !  ; IMMEDIATE
: then here swap ! ; IMMEDIATE

: repeat here ; IMMEDIATE
: until  ' 0branch , , ; IMMEDIATE

: for ' >r , here ' dup , ' r@ , ' > , ' 0branch ,  here 0 , swap ; IMMEDIATE
: endfor ' r> , ' lit , 1 , ' + , ' >r , ' branch , , here swap ! ' r> , ;  IMMEDIATE


: do  ' swap , ' >r , ' >r ,  here ; IMMEDIATE
 
: loop ' r> , ' lit , 1 , ' + , ' dup , ' r@ , ' < , ' not , '  swap , ' >r , ' 0branch , , 
' r> , ' drop , 
' r> , ' drop , 
 ;  IMMEDIATE

: sys_read_no 0 ;
: sys_write_no 1 ;

: sys_read  >r >r >r sys_read_no r> r> r> 0 0 0  syscall drop ; 
: sys_write >r >r >r sys_write_no r> r> r> 0 0 0  syscall drop ;

: readc@ 0 swap 1 sys_read ; 
: readc inbuf readc@ drop inbuf c@ ;

: ( repeat readc 41 - not until ; IMMEDIATE

( Now we can define comments :) 

: \ repeat readc 10 not until ; IMMEDIATE 
: -rot swap >r swap  r> ;

: over >r dup r> swap ;
: 2dup over over ;
: 2over >r >r dup r> swap r> swap ;


: <= 2dup < -rot =  lor ;
: >= 2dup > -rot = lor ;


( num from to -- 1/0) 
: in_range rot swap over >= -rot <= land ;

( 1 if we are compiling )
: compiling state @ ;

: compnumber compiling if ' lit , , else then ; 

( -- input character's code )
: .' readc compnumber ; IMMEDIATE

: readce readc dup .' \ = if
    readc dup .' n = if
        drop drop 10
        else
        drop drop 0
        then        
    else 
    then 
;

: cr 10 emit ; 

: ." compiling if 
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
                    ' lit , , ' prints , 1 
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



: read_digit readc dup .' 0 .' 9 in_range if .' 0 - else drop -1 then ;
: read_hex_digit 
readc dup .' 0 .' 9 in_range if 
    .' 0 - 
    else dup .' a .' f in_range if 
    .' a - 10 +
    else dup .' A .' F in_range if 
    .' A - 10 +
    else
    drop -1 then 
    then 
then ;

: read_oct_digit 
readc dup .' 0 .' 7 in_range if 
    .' 0 - 
    else
    drop -1 
then ;

: 08x 0
repeat 
read_oct_digit dup -1 = if
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
read_hex_digit dup -1 = if
    else 
    swap 16 * swap + 
    0
    then 

until 
compnumber
; IMMEDIATE



( diagnostics )
: info dup 9 + prints ." : " cfa . cr ; 
: dump last_word @
repeat 
dup info @ 
dup not until ;

: word_foreach >r last_word @
repeat 
dup r@ execute @ 
dup not until r> ;

: word_any >r last_word @
repeat 
dup r@ execute 
if dup 
else @ dup not 
then
until r> drop ;

: is_word >r last_word @
repeat 
dup cfa r@  = 
if dup 
else @ dup not  
then
until r> drop ;

: decompile is_word dup if ." <" 9 + prints ." >" cr else . cr then ;

: trap cr ."  Exception!\n" ;

( File I/O )
: O_APPEND 0x 400 ; 
: O_CREAT 0x 40 ; 
: O_TRUNC 0x 200 ; 
: O_RDWR 0x 2 ; 
: O_WRONLY 0x 1 ; 
: O_RDONLY 0x 0 ; 

: sys_open_no 2 ;

: sys_open  >r >r >r sys_open_no r> r> r> 0 0 0 syscall drop ;

: sys_close_no 3 ;
: sys_close  >r sys_close_no r> 0 0 0 0 0 syscall drop ;

: file-create O_RDWR O_CREAT O_TRUNC or or  08x 700 sys_open ;
: file-open-append O_APPEND O_RDWR O_CREAT or or  08x 700 sys_open ;
: file-close sys_close ;

( fd string - ) 
: file-print count sys_write ;
 
( include! )
: test " out.txt" file-open dup " test" dup file-print drop file-close ; test

