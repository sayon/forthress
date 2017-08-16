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
    " quote"    ' lisp-special-quote-xt lisp-special symtab-add 
    " set!"     ' lisp-builtin-set!-xt lisp-builtin symtab-add 
    " +"        ' lisp-builtin-+ lisp-builtin symtab-add 
    " -"        ' lisp-builtin-- lisp-builtin symtab-add 
    " *"        ' lisp-builtin-* lisp-builtin symtab-add 
    " /"        ' lisp-builtin-/ lisp-builtin symtab-add 
; symtab-init  

(  
 h" define" lisp-symbol h" x" lisp-symbol 42 lisp-number lisp-pair lisp-pair dup
lisp-show cr
lisp-eval cr
lisp-show cr
symtab-dump cr

." vars " cr
global quote    h" quote" lisp-symbol quote !
global set!     h" set!" lisp-symbol set! !

." shows:" cr
set! @ quote @ x @ lisp-pair 44 lisp-number lisp-pair lisp-pair  dup lisp-show   cr cr
lisp-eval 
symtab-dump cr )

global x        h" x" lisp-symbol x !
global y        h" y" lisp-symbol y !

( body )
x @ y @ 0 lisp-pair lisp-pair 
h" +" lisp-symbol x @ y @ 0 lisp-pair lisp-pair lisp-pair 
lisp-compound 


4 lisp-number 5 lisp-number 0 lisp-pair lisp-pair lisp-pair dup lisp-eval lisp-show


