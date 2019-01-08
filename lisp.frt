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
  m" +"      ' lisp-builtin-+      --add-builtin
  m" -"      ' lisp-builtin--      --add-builtin
  m" *"      ' lisp-builtin-*      --add-builtin
  m" /"      ' lisp-builtin-/      --add-builtin
  m" quote"  ' lisp-special-quote  --add-special
  m" define" ' lisp-builtin-define --add-builtin
  m" print"  ' lisp-builtin-print  --add-builtin
  m" begin"  ' lisp-special-begin  --add-special
  m" lambda" ' lisp-special-lambda --add-special
  m" set"    ' lisp-special-set    --add-special
  m" <"      ' lisp-builtin-<      --add-builtin
  ;  symtab-init

(

    " <"        ' lisp-builtin-<         lisp-builtin symtab-add
    " eql"      ' lisp-builtin-eql       lisp-builtin symtab-add
    " cond"     ' lisp-special-cond      lisp-special symtab-add
    " symbol?"  ' lisp-builtin-symbol?   lisp-builtin symtab-add
    " error?"   ' lisp-builtin-error?    lisp-builtin symtab-add
    " string?"  ' lisp-builtin-string?   lisp-builtin symtab-add
    " pair?"    ' lisp-builtin-pair?     lisp-builtin symtab-add

)

: file-read-line ( descr - mstring )
  0 read-file-buffer read-line-fd
  read-file-buffer string-from-buffer
;


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
." Program: \n" dup show  cr
lisp-eval drop cr ;


: lisp-init  _" init.lsp" file-read-text-name e ; 
lisp-init

