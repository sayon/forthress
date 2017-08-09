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
	dup symtab-name @ ?prints ."  ("
	symtab-next @ . ." )" 
;

: symtab-dump symtab-first 
    repeat 
    @ dup if dup symtab-show ." ;  " 0 else drop 1 then 
    until 
;

: symtab-init 
    " hello" 0 symtab-add 
    " other" 0 symtab-add 
; symtab-init

enum 
    lisp-pair-tag-value
    lisp-number-tag-value
    lisp-builtin-tag-value
    lisp-symbol-tag-value
    lisp-special-tag-value
    lisp-compound-tag-value
    lisp-max-tag-value
end


struct
    cell% field lisp-pair-tag
    cell% field lisp-pair-car
    cell% field lisp-pair-cdr
end-struct lisp-pair%

: lisp-pair ( car cdr - a ) 
    lisp-pair% heap-alloc dup >r if 
        
        lisp-pair-tag-value 
        r@ lisp-pair-tag !
        r@ lisp-pair-cdr !  
        r@ lisp-pair-car !  
    then r> ;
;

struct
    cell% field lisp-number-tag
    cell% field lisp-number-value
end-struct lisp-number%

: lisp-number ( n - a )
    lisp-number% heap-alloc dup >r if 
        lisp-number-tag-value 
        r@ lisp-number-tag !
        r@ lisp-number-value !
    then r> ;
;

struct
    cell% field lisp-builtin-tag
    cell% field lisp-builtin-xt
end-struct lisp-builtin%

: lisp-builtin ( xt - a ) 
    lisp-builtin% heap-alloc dup >r if 
        lisp-builtin-tag-value 
        r@ lisp-builtin-tag !
        r@ lisp-builtin-xt !
    then r> ;
;

struct
    cell% field lisp-special-tag
    cell% field lisp-special-xt
end-struct lisp-special%

: lisp-special ( xt - a ) 
    lisp-special% heap-alloc dup >r if 
        lisp-special-tag-value 
        r@ lisp-special-tag !
        r@ lisp-special-xt !
    then r> ;
;

struct
    cell% field lisp-symbol-tag
    cell% field lisp-symbol-name
end-struct lisp-symbol%

: lisp-symbol ( name - a ) 
    lisp-symbol% heap-alloc dup >r if 
        lisp-symbol-tag-value
        r@ lisp-symbol-tag !
        r@ lisp-symbol-name !
    then r> ; 


: lisp-show rec
    dup dup if @ case 
    lisp-pair-tag-value of 
        dup 
        ." (" lisp-pair-car @ recurse ."  " lisp-pair-cdr @ recurse ." )" 
       endof
    lisp-number-tag-value of lisp-number-value @ .       endof
    lisp-symbol-tag-value of lisp-symbol-name  @ prints  endof
    lisp-builtin-tag-value of lisp-builtin-xt @ decompile endof
    endcase  
    else ." nil " drop  drop 
    then 
;


lisp-max-tag-value cells allot constant lisp-eval-dispatch 


: lisp-eval ( lisp - lisp )
." lisp-eval " dup . cr
dup if 
	dup @ cells lisp-eval-dispatch + @ execute
then
;

: lisp-eval-number ( lisp - lisp )
( ." lisp-eval-number " dup lisp-number-value @ . cr
    dup lisp-number-value @ 1 + over lisp-number-value ! )
;

' lisp-eval-number lisp-number-tag-value cells lisp-eval-dispatch + !

: lisp-eval-list rec ( lisp - lisp )
." eval list " dup . cr 
dup if
    dup lisp-pair-car @ lisp-eval swap lisp-pair-cdr  @ recurse lisp-pair 
then ;


: lisp-apply-func ( fun args -- lisp )
    swap dup @ case 
        lisp-builtin-tag-value of 
            lisp-builtin-xt @  
            swap lisp-eval-list swap execute 
            endof 
        lisp-special-tag-value of 
            lisp-special-xt @ execute 
            endof 
        ." Apply not implemented" cr
        endcase
;


: lisp-eval-pair  ( lisp - lisp )    
    dup if
        dup lisp-pair-car @ swap lisp-pair-cdr @ list-apply-func 
    then ;

: lisp-list-reduce ( f lisp - lisp )
    dup if 
       dup @ lisp-pair-tag-value = if 
        
        dup lisp-pair-cdr @ if 
           swap >r 
            
            r> drop 
        then then then ;
    ( >r
    r@ car lisp-eval
    dup lisp-tag @ lisp-special-tag = if
	r> cdr swap special-xt @ execute
    else
	r> cdr lisp-eval-list lisp-apply
    endif ; )

' lisp-eval-list lisp-pair-tag-value cells lisp-eval-dispatch  + !

42 lisp-number 43 lisp-number 44 lisp-number  0 lisp-pair lisp-pair lisp-pair dup lisp-show
lisp-eval lisp-show



(  
 
struct
    cell% field >compound-tag
    cell% field >compound-args
    cell% field >compound-body
end-struct lisp-compound%

)
