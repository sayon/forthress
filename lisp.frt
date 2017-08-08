( Lisp interpreter written in Forthress )

struct 
	cell% field >next
end-struct llist%

struct
    llist% field symtab-next
    cell% field symtab-name
    cell% field symtab-lisp
end-struct symtab%

( 
* string helpers 
)
global symtab-first 

: symtab-add ( name sexpr )
	symtab% heap-alloc >r
	symtab-first @ r@ symtab-next  + !
	r@ symtab-lisp  + !
	r@ symtab-name + !
	r> symtab-first !	
;

: symtab-show ( a  - )
	dup symtab-name + @ ?prints ."  ("
	symtab-next + @ . ." )" 
;

: symtab-dump symtab-first 
repeat 
@ dup if dup symtab-show ." ;  " 0 else drop 1 then 
until ;

: symtab-init 
" hello" 0 symtab-add 
" other" 0 symtab-add 
; symtab-init

0 constant lisp-pair-tag
1 constant lisp-number-tag
2 constant lisp-builtin-tag
3 constant lisp-symbol-tag
4 constant lisp-special-tag
5 constant lisp-compound-tag
6 constant lisp-max-tag

struct 
	cell% field >lisp-pair-tag
	cell% field >lisp-tag
end-struct lisp-pair%

struct
    cell% field >pair-tag
    cell% field >pair-car
    cell% field >pair-cdr
end-struct lisp-pair%

struct
    cell% field >number-tag
    cell% field >number-num
end-struct lisp-number%

struct
    cell% field >builtin-tag
    cell% field >builtin-xt
end-struct lisp-builtin%

struct
    cell% field >symbol-tag
    cell% field >symbol-name
end-struct lisp-symbol%

struct
    cell% field >special-tag
    cell% field >special-xt
end-struct lisp-special%

struct
    cell% field >compound-tag
    cell% field >compound-args
    cell% field >compound-body
end-struct lisp-compound%


