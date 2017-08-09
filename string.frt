: 2inc ( x y -- x+1 y+1 )
	>r 1 + r> 1 + ;

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
: ?prints dup if prints else " <NULL> " then ;
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

: string-new dup count 1 + heap-alloc swap string-copy ;

( string in heap )
: h" compiling not if 
    0 
    repeat readc dup .' " = if 
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
' " execute ' dup , ' string-new ,
then
; IMMEDIATE 

