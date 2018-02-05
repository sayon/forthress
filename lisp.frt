( Lisp interpreter written in Forthress )

struct
    cell% field symtab-next
    cell% field symtab-name
    cell% field symtab-lisp
end-struct symtab%

global symtab-first 

: symtab-add ( name sexpr )
	symtab% heap-alloc >r
	symtab-first @ r@ symtab-next !
	r@ symtab-lisp   !
	r@ symtab-name  !
 	r> symtab-first !
;


: symtab-lookup ( name - a )
    >r symtab-first
    repeat @ 
    dup if
        dup symtab-name @ r@ string-eq 
        else drop 0 1 then 
    until r> drop
;

: symtab-save symtab-first @ ;
: symtab-restore symtab-first ! ;

include lisp-expr.frt
include lisp-show.frt

: symtab-show ( a  - )
	dup . ." : " dup symtab-name @ ?prints 
    ."  := "  symtab-lisp @ lisp-show 
    ;

: symtab-dump symtab-first 
    repeat 
    symtab-next @ 
    dup if 
        dup symtab-show cr 0 
        else drop 1 
    then 
    until
;

include lisp-eq.frt
include lisp-eval.frt

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

include lisp-parser.frt

: string-empty? c@ not ; 




( 


x @ y @ 0 lisp-pair lisp-pair 
h" +" lisp-symbol x @ y @ 0 lisp-pair lisp-pair lisp-pair 
lisp-compound 


symtab-dump cr

(  
1. recursion
2. ' syntax? 
2. GC )

: lisp-eval-text parse-lisp if lisp-eval  lisp-show else ." Errors while parsing string " cr then ;
 
: lisp-eval-file file-read-text-name lisp-eval-text ;

h" init.lsp" lisp-eval-file cr

: lisp-repl
    repeat 
        0 read-file-buffer c!  
        ." > "
        stdin read-file-buffer read-line-fd 
        read-file-buffer " :quit" string-prefix not if 
            read-file-buffer string-empty? not if
                    read-file-buffer 
                    lisp-eval-text cr 0
            else 1 then 
            else 1 then 
    until ;

