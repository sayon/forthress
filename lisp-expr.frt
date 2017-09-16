enum 
    lisp-pair-tag-value
    lisp-number-tag-value
    lisp-builtin-tag-value
    lisp-symbol-tag-value
    lisp-special-tag-value
    lisp-compound-tag-value
    lisp-error-tag-value
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

: lisp-pair? @ lisp-pair-tag-value = ;

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

: lisp-number? @ lisp-number-tag-value = ;
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

struct
    cell% field lisp-compound-tag
    cell% field lisp-compound-args
    cell% field lisp-compound-body
end-struct lisp-compound% 


: lisp-compound ( args body - a ) 
    lisp-compound% heap-alloc dup >r if 
        lisp-compound-tag-value
        r@ lisp-compound-tag !
        r@ lisp-compound-body !
        r@ lisp-compound-args !
    then r> ; 

struct
    cell% field lisp-error-tag
    cell% field lisp-error-str
    cell% field lisp-error-lisp
end-struct lisp-error%

: lisp-error ( str lisp - a )
    lisp-error% heap-alloc dup >r if 
        lisp-error-tag-value 
        r@ lisp-error-tag !
        r@ lisp-error-lisp !
        r@ lisp-error-str  !
    then r> ;
;


( todo: equality )
