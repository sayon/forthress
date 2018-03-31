( 
This file implements Forthress documentation engine. To use it, place a
string on the stack before defining a new word, and use `wit-doc` after
semicolon to create documentation entry for the last word defined. 
)

global doc-start 
0 doc-start ! 

struct 
 cell% field >doc-next
 cell% field >doc-addr
 cell% field >doc-string
end-struct doc-header%

( word-address docstring )
: doc-word 
    swap 
    doc-header% allot >r
    swap 
                    r@ >doc-string !
    doc-start @     r@ >doc-next !
                    r@ >doc-addr !
    r> doc-start !
;

( string - )
: with-doc last_word @ cfa swap doc-word ;

g" 
( addr - doc-header? )
Given an XT of a word, finds a relevant `doc-header` in the documentation DB
"
: doc-find 
   doc-start @
    repeat 
      dup 0 = if 2drop 0 1 ( return 0 ) 
          else
           2dup >doc-addr @ = if 
              swap drop 1 
          else >doc-next @ 0
        then
    then 
    until   
; with-doc

g"
( addr - )
Display documentation for the word address 
" 
: doc-show dup doc-find dup if
    >doc-string @ dup if 
         cr
         ." # Documentation for " swap ? cr 
          prints cr
         ."  ------" cr 
    else 2drop ." Error: empty documentation string " then  
  else  drop ." No documentation for " ? cr  then 
; with-doc 

g" 
Alias for `doc-show`
"
: ?? doc-show ; with-doc

' doc-word g" 
( word-address docstring )
Document an existing word with a documenting string. Prefer using global strings for that matter.
" doc-word

' doc-start g"
Global variable storing the address of documentation database. 
The database itself is a linked list of `doc-header` structures.
" doc-word
