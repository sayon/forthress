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

include lisp-eval.frt

: symtab-init 
    0 symtab-first !
    " define"   ' lisp-special-define-xt lisp-special symtab-add 
    " quote"    ' lisp-special-quote-xt  lisp-special symtab-add 
    " lambda"   ' lisp-builtin-lambda    lisp-special symtab-add 
    " set"      ' lisp-builtin-set-xt    lisp-builtin symtab-add 
    " +"        ' lisp-builtin-+         lisp-builtin symtab-add 
    " -"        ' lisp-builtin--         lisp-builtin symtab-add 
    " *"        ' lisp-builtin-*         lisp-builtin symtab-add 
    " /"        ' lisp-builtin-/         lisp-builtin symtab-add 
    " print"    ' lisp-builtin-print              lisp-builtin symtab-add 
; symtab-init  

include lisp-parser.frt

: string-empty? c@ not ; 


: lisp-process-file ( fd - ) 
    file-read-text-name
        parser-new parse-lisp if
                dup ." lisp: " lisp-show cr
                lisp-eval 
                else  
            ." ERROR " cr 
            then
        ; 


( 
global x        h" x" lisp-symbol x !
global y        h" y" lisp-symbol y !
global quote    h" quote" lisp-symbol quote !
global set     h" set" lisp-symbol set !

h" define" lisp-symbol h" x" lisp-symbol 42 lisp-number lisp-pair lisp-pair dup

set @ quote @ x @ lisp-pair 44 lisp-number lisp-pair lisp-pair  dup lisp-show   cr cr
lisp-eval 
symtab-dump cr 


x @ y @ 0 lisp-pair lisp-pair 
h" +" lisp-symbol x @ y @ 0 lisp-pair lisp-pair lisp-pair 
lisp-compound 


4 lisp-number 5 lisp-number 0 lisp-pair lisp-pair lisp-pair dup lisp-eval lisp-show

symtab-dump cr


(  
1. equality 
2. recursion
3. if then else or cond 
4. GC )
 

( h" lsp.lsp" lisp-process-file )
 
