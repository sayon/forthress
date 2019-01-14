include lisp-expr.frt
include lisp-symtab.frt
include lisp-parser.frt

include lisp-eval.frt

: lisp-special-quote >lisp-pair-car @ ;

( define name val )
: lisp-special-define
   lisp-pair-destruct
   swap >lisp-symbol-name @
   swap >lisp-pair-car @
   symtab-add
   lisp-#
 ;

: --add-special raw-cell new lisp-special new symtab-add ;
: --add-builtin raw-cell new lisp-builtin new symtab-add ;

: symtab-init
  m" +"       ' lisp-builtin-+        --add-builtin
  m" -"       ' lisp-builtin--        --add-builtin
  m" *"       ' lisp-builtin-*        --add-builtin
  m" /"       ' lisp-builtin-/        --add-builtin
  m" <"       ' lisp-builtin-<        --add-builtin 
  m" quote"   ' lisp-special-quote    --add-special
  m" define"  ' lisp-builtin-define   --add-special
  m" print"   ' lisp-builtin-print    --add-builtin
  m" progn"   ' lisp-builtin-progn    --add-builtin
  m" lambda"  ' lisp-special-lambda   --add-special
  m" set"     ' lisp-special-set      --add-special
  m" <"       ' lisp-builtin-<        --add-builtin
  m" eql"     ' lisp-builtin-eql      --add-builtin
  m" eq"      ' lisp-builtin-eq       --add-builtin
  m" car"     ' lisp-builtin-car      --add-builtin
  m" cdr"     ' lisp-builtin-cdr      --add-builtin
  m" cons"    ' lisp-builtin-cons     --add-builtin
  m" cons?"   ' lisp-builtin-cons?    --add-builtin
  m" nil?"    ' lisp-builtin-nil?     --add-builtin
  m" symbol?" ' lisp-builtin-symbol?  --add-builtin
  m" number?" ' lisp-builtin-number?  --add-builtin
  m" string?" ' lisp-builtin-string?  --add-builtin
  m" set"       0                     --add-builtin
  m" if"      ' lisp-special-if       --add-special
  ;  symtab-init



: lisp-repl
  repeat
  ." \nlisp> "
  stdin file-read-line
  ( ." Read: " dup show cr  )
  dup string-empty? if
    ( ." Empty string " cr  )
    drop 1
  else
    parser-init parse-lisp if
      ( ." Parsed " dup show  cr )
      lisp-eval show drop 0
    else drop ." Parse error \n" 1
    then
  then
  until
;


: parse parser-init parse-lisp drop ;
: e parse 
." Program: \n" dup show  cr cr cr
lisp-eval 
cr
." Result: " show cr ;


: lisp-init  _" init.lsp" file-read-text-name e ; 
999
888
777
666
555
444
333
222
111

lisp-init
