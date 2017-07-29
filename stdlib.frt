: IMMEDIATE 1 last_word @ cfa 1 - c! ;


: sys_read_no 0 ;
: sys_write_no 1 ;
: sys_open_no 2 ;
: sys_read >r >r >r sys_read_no r> r> r> 0 0 0  syscall ;
: readc@ 0 swap 1 sys_read drop ; 
: readc inbuf readc@ drop inbuf c@ ;

: if ' 0branch , here 0  , ; IMMEDIATE
: else ' branch , here 0 , swap here swap !  ; IMMEDIATE
: then here swap ! ; IMMEDIATE


: is_compile state @ ;

: .' readc is_compile if ' lit , , else then  ; IMMEDIATE

: cr 10 emit ; 

: repeat here ; IMMEDIATE
: until  ' 0branch , , ; IMMEDIATE


: ( repeat readc 41 - not until ; IMMEDIATE
( Now we can define comments :) 

: _testif 0 if 42 dup else 99 100 then ;
: _testuntil repeat readc dup emit until ;

( We need to establish a kind of a diagnostic system! )


: ." is_compile if 
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
                    ' lit , , ' prints , 1 
                else c, 0 
                then 
            until
else
repeat
     readc dup 34 = if drop 1 else emit 0 then 
until  
then ; IMMEDIATE


