( classinf - )
: declare-show[
  dup >class-name @ " show" inbuf string-prefix-with ( classinf "classname-show" )
  drop
  0 inbuf create ' docol @ ,
  last_word @ cfa swap >class-show !
  compilation-start ;

: ]end-show;   ' ; execute ; IMMEDIATE


( classinf - )
: declare-ctor[
dup >class-name @ " ctor" inbuf string-prefix-with ( classinf "classname-ctor" )
drop
0 inbuf create ' docol @ ,
last_word @ cfa swap >class-ctor !
compilation-start ;

: ]end-ctor;   ' ; execute ; IMMEDIATE