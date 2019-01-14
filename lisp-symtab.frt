class Symtab-Entry
  Lisp :: >symtab-lisp
  String :: >symtab-name
class-end

Symtab-Entry show=[
   dup >symtab-name @ show ." := " >symtab-lisp @ show cr
]show;


managed-global symtab


( name lisp - )
: symtab-add 
  Symtab-Entry new
  symtab @ swap list-prepend symtab !
;

: symtab-dump symtab @ ' show list-foreach ;

( str - lisp )
: symtab-lookup String :arg1

  >r symtab @
repeat
dup if
  dup >list-value @ >symtab-name @
  r@ string-eq if
    >list-value @ >symtab-lisp  1
  else
    >list-next @ 0
  then
else 1 then
until
r> drop ;




: symtab-save symtab @ ;
: symtab-restore symtab ! ;

