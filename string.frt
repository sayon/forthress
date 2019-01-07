
: 2inc-by ( x y d -- x+d y+d )
	>r r@ + swap r> + swap ;

: 2inc ( x y -- x+1 y+1 )
  1 2inc-by ;

( src dest - )
: copy-cell
  swap @ swap !
;

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


: string-eq ( s1 s2 - 0/1 )
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
    dup _" \n" string-prefix if drop 2 else c@ 0 <> then ;

: string-allot ( ptr - allotptr)
    dup count 1 + allot dup >r swap string-copy r> ;

: string-new ( buf - a )
    dup count 1 + heap-alloc ( buf a ) >r r@ swap string-copy r> ;

( string in heap )
: h" compiling not if
    0
    repeat
    read-char-extended --read-non-escaped-quote if
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

g"
( a b -- a++b )
Concatenates two strings. The result is allocated on heap.
"
: string-concat
2dup count swap count 1 + + heap-alloc >r
swap r@ swap string-copy
r@ count r@ +
swap string-copy
r>
; with-doc

g"
( - addr )
Read word and allocate it with `allot`
"
: word-allot
  inbuf word drop
  inbuf string-allot
; with-doc


g"
( str str-to-append - )
Append `str-to-append` after the last address of `str`. Unsafe.
"
: string-append-in-place
  swap dup count + swap string-copy ; with-doc

g"
( prefix name buf -- buf )
Prefix a string with another string and a dash.
After that, `buf` will hold 'prefix-name'.
"
: string-prefix-with
  dup 0 swap c!
  dup >r
  rot string-append-in-place
  r@ " -" string-append-in-place
  r@ swap string-append-in-place
  r>
; with-doc 
