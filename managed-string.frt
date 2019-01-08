class String class-end
' count String >class-size !

: string-show QUOTE emit prints QUOTE emit ;
' string-show String >class-show !

: m" ' h" execute compiling if                             \  "  
       ' dup , ' String , ' manage ,
       ' dup , ' gc-mark-collectable ,
     else
       dup String manage
       dup gc-mark-collectable
     then ; IMMEDIATE

: string-from-buffer string-new dup String manage dup gc-mark-collectable ;


: string-concat string-concat dup String manage dup gc-mark-collectable ; 
: ++ string-concat ;

String copy=[ string-new dup String manage ]copy;

( from -> from+1 c)
: --read-char-from-mem dup c@ swap 1 + swap ;

: string-escaped-length
-1 >r
repeat
    r> 1 + >r 
    ' --read-char-from-mem read-char-extended-with drop 
    not 
until
drop 
r> 
;

( from to - from+? to+1 )
: --string-unescape-copy-buffer-step
  over ' --read-char-from-mem read-char-extended-with drop swap drop 
  over c!
  swap dup estring-char-length + 
  swap 1 +
;

( from to len - )
: --string-unescape-copy-buffer
  0 for 
  --string-unescape-copy-buffer-step
  endfor 
  0 swap c!
  drop 
;

g"
( str - newstr )

Translates all escaped characters into their true form, f.e. \n becomes line feed.
"
: string-unescape 
    dup string-escaped-length   ( str len)
    dup 1 + heap-alloc dup >r swap  ( str len )

    --string-unescape-copy-buffer

    r> dup String manage
    dup gc-mark-collectable
    ; with-doc

\ BUGS ARE HERE ^
