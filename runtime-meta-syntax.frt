( classinf - )
: show=[
  dup >class-name @ " show" inbuf string-prefix-with ( classinf "classname-show" )
  drop
  0 inbuf create ' docol @ ,
  last_word @ cfa swap >class-show !
  compilation-start ;

: ]show;   ' ; execute ; IMMEDIATE


( classinf - )
: ctor=[
dup >class-name @ " ctor" inbuf string-prefix-with ( classinf "classname-ctor" )
drop
0 inbuf create ' docol @ ,
last_word @ cfa swap >class-ctor !
compilation-start ;

: ]ctor;   ' ; execute ; IMMEDIATE

: copy=[
dup >class-name @ " copy" inbuf string-prefix-with ( classinf "classname-copy" )
drop
0 inbuf create ' docol @ ,
last_word @ cfa swap >class-copy !
compilation-start ;

: ]copy;   ' ; execute ; IMMEDIATE