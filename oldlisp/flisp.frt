mtype lisp mend

mtype lisp-pair
      lisp :: >lisp-pair-car
      lisp :: >lisp-pair-cdr
mend

mtype lisp-number
      int :: >lisp-number-value
mend

mtype lisp-bool
      int :: >lisp-bool-value
mend

mtype lisp-string
      string :: >lisp-string-value
mend

mtype lisp-builtin
      raw-cell :: >lisp-builtin-xt
mend

mtype lisp-symbol
    string :: >lisp-symbol-name
mend

mtype lisp-special
    raw-cell :: >lisp-special-xt
mend

mtype lisp-unspecific mend

mtype lisp-compound
    lisp :: >lisp-compound-args
    lisp :: >lisp-compound-body
mend

mtype lisp-error
    string :: >lisp-error-string
    lisp :: >lisp-error-lisp
mend

: lisp-show rec
  dup not if ." nil" drop else
    dup type-of case

      lisp-pair of
        ." ("  dup >lisp-pair-car @
        recurse
        ."  . "
        >lisp-pair-cdr @ recurse ." )"
      endof

      lisp-bool of
        >lisp-bool-value @ if ." t" else ." f" then
      endof

      lisp-symbol of
        >lisp-symbol-name @ prints
      endof

      lisp-builtin of
        >lisp-builtin-xt @ decompile
      endof

      lisp-unspecific of
        ." <unspecific>"
      endof

      lisp-error of
        dup >lisp-error-string @ prints
        >lisp-error-lisp @ recurse
      endof

      lisp-special of
        ." ^" >lisp-special-xt @ decompile
      endof

      lisp-number of
        >lisp-number-value @ >value @ .
      endof

      lisp-compound of
        ." (λ " dup >lisp-compound-args @ recurse ." . " >lisp-compound-body @ recurse ." )"
      endof

      cr ." lisp-show: can not show a value of type " dup
      if dup >meta-name @ prints cr else ." <no type available>" then
    endcase
  then
  ;

: show-lisp-pair
  dup
  ." ("   >lisp-pair-car @ show
  ."  . " >lisp-pair-cdr @ show ." )" ;
' show-lisp-pair lisp-pair >meta-printer !

: show-lisp-number @ show ;
' show-lisp-number lisp-number >meta-printer !

: show-lisp-compound dup
  ." (λ " >lisp-compound-args @ show ." . " >lisp-compound-body @ show ." )" ;
' show-lisp-compound lisp-compound >meta-printer !

: show-lisp-symbol @ show ;
' show-lisp-symbol lisp-symbol >meta-printer !

: show-lisp-bool
  >lisp-bool-value @  if ." t" else ." f" then ;
' show-lisp-bool lisp-bool >meta-printer !

: li int new lisp-number new ;
: cons swap lisp-pair new ;
: lambda lisp-compound new ;
: s lisp-symbol new ;

3 li 2 li 1 li m" x" 0 cons cons cons cons show
( 1 li 2 li cons show )


( ' lisp-show lisp             >meta-printer !
' lisp-show lisp-pair        >meta-printer !
' lisp-show lisp-number      >meta-printer !
' lisp-show lisp-bool        >meta-printer !
' lisp-show lisp-builtin     >meta-printer !
' lisp-show lisp-string      >meta-printer !
' lisp-show lisp-symbol      >meta-printer !
' lisp-show lisp-special     >meta-printer !
' lisp-show lisp-unspecific  >meta-printer !
' lisp-show lisp-compound    >meta-printer !
' lisp-show lisp-error       >meta-printer ! )




mtype symtab
  raw-cell :: >symtab-next
  string :: >symtab-name
  lisp :: >symtab-lisp
mend

global symtab-first 

: symtab-add ( name sexpr )
  symtab-first @ -rot
  symtab new
  symtab-first ! 
;


: symtab-lookup ( name - a )
  >r symtab-first
  repeat @
        dup if
          dup >symtab-name @ r@ string-eq 
        else drop 0 1 then 
  until r> drop
;

: symtab-save symtab-first @ ;
: symtab-restore symtab-first ! ;

( include lisp-expr.frt
include lisp-show.frt )

: symtab-show ( a  - )
	dup . ." : " dup >symtab-name @ ?prints
  ."  := "  >symtab-lisp @ show
;

: symtab-dump symtab-first
  repeat
  >symtab-next @
  dup if
      dup symtab-show cr 0
    else drop 1 then
  until
;

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
