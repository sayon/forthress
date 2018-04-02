
: 2inc ( x y -- x+1 y+1 )
	>r 1 + r> 1 + ;

: mcopy ( s d - s+1 d+1 ) over c@ over c! 2inc ;

: string-copy ( d s -  )
	repeat 
	2dup 
    ( d s d s - )
    c@ >r r@ swap c!
	2inc
    r> not
	until  
2drop ;
: ?dup dup if dup then ; 
: ?prints dup if prints else ." <NULL> " drop then ;


: string-eq ( s1 s2 - )
	repeat
	over c@ over c@ = if ( x[i] = y[i] ) 
			dup c@ not  if 
				( end of string, return 1 )
				2drop 1 1 
				else 
				2inc 0  ( continue )
				then 
		else 2drop 0 1
		then
	until
;

: string-prefix ( s1 prefix -  0 1)
	repeat
    dup c@ if 
        over c@ over c@ = not if ( x[i] = y[i] ) 
            2drop 0 1 
            else 2inc 0  ( continue )
            then 
    else 2drop 1 1 then
	until
;

: estring-char-length ( string - length )
    _" \n" string-prefix if 2 else 1 then ;

: string-allot ( ptr - allotptr)
    dup count 1 + allot dup >r swap string-copy r> ;

: string-new ( buf - a ) 
    dup count 1 + heap-alloc ( buf a ) >r r@ swap string-copy r> ;

( string in heap )
: h" compiling not if 
    0 
    repeat readc dup QUOTE = if                     
        drop 
        dup dp @ + 0 swap c!
        1 + heap-alloc dup dp @ string-copy 1 
    else 
        >r dup dp @ + r> swap c! 
        1 + 
    0
    then
    until 
else
' " execute ' string-new ,
then
; IMMEDIATE 

: string-empty? ( str - 0 1 ) 
    c@ 0 = ; 

