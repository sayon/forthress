( Lisp interpreter written in Forthress )

struct 
	cell% field >next
end-struct llist%

struct
    llist% field symtab-next
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

: symtab-show ( a  - )
	dup ." at " . ." : " dup symtab-name @ ?prints ."  ("
	symtab-next @ . ." )" 
;

: symtab-dump symtab-first 
    repeat 
    @ dup if dup symtab-show ." ;  " 0 else drop 1 then 
    until 
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

: lisp-show rec
    dup dup if @ case 
    lisp-pair-tag-value of 
        dup 
        ." (" lisp-pair-car @ recurse ."  " lisp-pair-cdr @ recurse ." )" 
       endof
    lisp-number-tag-value of 
        lisp-number-value @ .       
        endof
    lisp-symbol-tag-value of 
        lisp-symbol-name  @ prints  
        endof
    lisp-builtin-tag-value of 
        lisp-builtin-xt @ decompile 
        endof
    lisp-compound-tag-value of 
        ." (lambda (" dup lisp-compound-args @ recurse ." ) (" lis-compound-body @ recurse ." )"
        endof
    endcase  
    else ." nil " drop  drop 
    then 
;


lisp-max-tag-value cells allot constant lisp-eval-dispatch 


: lisp-eval ( lisp - lisp )
." eval: " dup lisp-show cr
dup if 
	dup @ cells lisp-eval-dispatch + @ execute
then
;

: lisp-eval-number ( lisp - lisp )
    ." eval: number " dup lisp-number-value @ .  cr 
    ;

' lisp-eval-number lisp-number-tag-value cells lisp-eval-dispatch + !

: lisp-eval-list rec ( lisp - lisp )
    ." eval list " dup lisp-show  cr
    dup if
        dup lisp-pair-car @ lisp-eval swap lisp-pair-cdr  @ recurse lisp-pair 
    then ;


: lisp-apply-func ( fun args -- lisp )
    ." eval: apply function "
    swap dup @ case 
        lisp-builtin-tag-value of 
            ." builtin " dup lisp-show  over ."  to " lisp-show cr 

            lisp-builtin-xt @  
            swap lisp-eval-list swap 
            ." eval: executing... "
            execute 
            endof 
        lisp-special-tag-value of 
            lisp-special-xt @ execute 
            endof 
        ." Apply not implemented" cr
        endcase
;

: lisp-pair-destruct ( lisp - lisp lisp )
    dup lisp-pair-car @ swap lisp-pair-cdr @ ;

: lisp-eval-pair  ( lisp - lisp )    
    ." eval: pair " cr 
    dup if
        dup lisp-pair-car @ swap lisp-pair-cdr @ lisp-apply-func 
    then ;

' lisp-eval-pair lisp-pair-tag-value cells lisp-eval-dispatch  + !

: lisp-eval-symbol ( lisp - lisp )    
    ." eval: symbol " cr 
    dup if
        lisp-symbol-name @ symtab-lookup symtab-lisp @  
    then ;

' lisp-eval-pair lisp-pair-tag-value cells lisp-eval-dispatch  + !



: lisp-helper-unpack-pair lisp-pair-destruct lisp-pair-car @ lisp-number-value @  swap lisp-number-value @ swap ;
: lisp-builtin-+ lisp-helper-unpack-pair + lisp-number ;   
: lisp-builtin-- lisp-helper-unpack-pair - lisp-number ;   
: lisp-builtin-* lisp-helper-unpack-pair * lisp-number ;   
: lisp-builtin-/ lisp-helper-unpack-pair / lisp-number ;   

( ' lisp-builtin-- lisp-builtin 42 lisp-number 2 lisp-number 0 lisp-pair lisp-pair lisp-pair dup lisp-show lisp-eval cr lisp-show)




: symtab-init 
    " hello" 0 symtab-add 
    " other" 0 symtab-add 
; symtab-init


