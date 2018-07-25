struct
  cell% field >class-name

  ( -- Virtual methods -- )
  cell% field >class-ctor
  cell% field >class-size ( has 0 arguments; returns 0 for string )
  cell% field >class-copy
  cell% field >class-show
  cell% field >class-dtor

  ( -- Field count -- )
  cell% field >class-fields

  ( -- Fields come here --)
end-struct class-entry%

global default-show
global default-copy
global default-ctor
global default-dtor
global default-size


g"
class <newtype>

Creates a new managed type.

Example:

```
class pair
int :: >fst
int :: >snd
class-end
```
"
: class
  word-allot
  class-entry% allot >r
  r@ >class-name !

  default-show @  r@ >class-show !
  default-copy @  r@ >class-copy !
  default-ctor @  r@ >class-ctor !
  default-dtor @  r@ >class-dtor !
  default-size @  r@ >class-size !

  ( creating 'typename' word to return its class information address )
  0 r@ >class-name @ create
  ' docol @ , ' lit , r@ , ' exit ,
  r> 0
; with-doc


( parent-classinf offset field-classinf -- parent-classinf newoffset )
: ::
  cell% allot ! ( parent-classinf offset -- )
  dup add-constant
  cell% +
;

( classinf size - )
: class-end cell% / swap >class-fields ! ;



( chunk-contents *classinf )
: class-show >class-show @ execute  ;
' class-show heap-meta-printer !

( addr class - )
: manage swap chunk-header% - >chunk-meta ! ;


( classinf sz - addr )
: class-alloc heap-alloc dup >r swap manage r> ;

( classinf - addr )
: class-alloc-default dup >class-fields @ cells class-alloc ;

: type-of dup addr-is-chunk-start if chunk-header% - >chunk-meta @ else drop 0 then ;

( addr classinf - 0/1 )
: is-of-type swap type-of dup if = else 2drop 0 then ;

: [managed-only]
  ' dup ,
  ' type-of ,
  ' not ,
  ' if execute
       ' lit , " In word '" , ' prints , 
       ' this-word-name execute ' prints ,
       ' lit , " ': '" , ' prints ,
       ' ? ,
       ' lit , " ' should be a managed type" , ' prints , ' cr ,
       ' exit ,
       ' then execute
; IMMEDIATE

: show   [managed-only] dup type-of >class-show @ execute ;
: new                           dup >class-ctor @ execute ;
: copy   [managed-only] dup type-of >class-copy @ execute ;
: delete [managed-only] dup type-of >class-dtor @ execute ;
: size   [managed-only] dup type-of >class-size @ execute ;

: object-chunk-start [managed-only] chunk-header% - ;
: object-name type-of >class-name @ ;
: object-fields type-of >class-fields @ ;


( addr fun - )
: object-for-each-field
  swap [managed-only]
  dup object-fields 0
  for 
    2dup >r >r ( fun addr , addr fun )
    @ swap execute
    r> r> cell% +
  endfor 
  2drop
;

( addr fun - )
: object-for-each-field-reverse
  swap [managed-only]
  dup object-fields >r
  dup object-fields 1 - cells +
  ( fun addr-last-field ,  fields )
  r> 0
   for 
      2dup >r >r ( fun addr , addr fun )
      @ swap execute
      r> r> cell% -
    endfor
    2drop
;

( --- size --- )
: default-size-impl type-of >class-fields @ cells
; ' default-size-impl default-size !

( --- show --- )
: --show-space show ."  " ;

: show-recursive
  dup object-name ?prints ." "
  dup object-fields if
    ." [ "
    ' --show-space object-for-each-field
    ." ]"
  else drop then
; ' show-recursive default-show !


( --- ctor --- )

( fieldN ... field2 field1 class -- addr )
: default-ctor-impl
  dup >class-fields @ not if
    ." Can not use default ctor for classes with 0 fields \n"
    drop exit then

  class-alloc-default dup >r
  dup object-fields 0 do
    dup -rot !
    cell% +
  loop
  drop r>
; ' default-ctor-impl default-ctor ! 


( --- copy --- )
( old - new )
: default-copy-impl
  [managed-only]
  dup type-of >r
  ( old , type )
  dup object-fields 1 - cells over +

  swap object-fields 0 do
    ( cur-addr )
    dup @ copy swap 
    cell% -
  loop
  drop
  r> new
; ' default-copy-impl default-copy !

( --- dtor --- )
: default-dtor-impl
  dup >class-fields @ if
    dup ' delete object-for-each-field
  then
  heap-free
; ' default-dtor-impl default-dtor ! 


include runtime-meta-diagnostic.frt
include runtime-meta-syntax.frt
include stdclasses.frt
include runtime-gc.frt
