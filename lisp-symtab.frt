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

( 
: symtab-init
    0 symtab-first !
    " define"   ' lisp-special-define-xt lisp-special symtab-add
    " begin"    ' lisp-special-begin-xt  lisp-special symtab-add
    " quote"    ' lisp-special-quote-xt  lisp-special symtab-add
    " lambda"   ' lisp-special-lambda    lisp-special symtab-add
    " set!"     ' lisp-special-set!-xt   lisp-special symtab-add
    " +"        ' lisp-builtin-+         lisp-builtin symtab-add
    " -"        ' lisp-builtin--         lisp-builtin symtab-add
    " *"        ' lisp-builtin-*         lisp-builtin symtab-add
    " /"        ' lisp-builtin-/         lisp-builtin symtab-add
    " <"        ' lisp-builtin-<         lisp-builtin symtab-add
    " print"    ' lisp-builtin-print     lisp-builtin symtab-add
    " eql"      ' lisp-builtin-eql       lisp-builtin symtab-add
    " cond"     ' lisp-special-cond      lisp-special symtab-add
    " symbol?"  ' lisp-builtin-symbol?   lisp-builtin symtab-add
    " error?"   ' lisp-builtin-error?    lisp-builtin symtab-add
    " string?"  ' lisp-builtin-string?   lisp-builtin symtab-add
    " pair?"    ' lisp-builtin-pair?     lisp-builtin symtab-add
; symtab-init
)


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

