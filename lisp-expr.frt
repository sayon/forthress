enum 
    lisp-pair-tag-value
    lisp-number-tag-value
    lisp-bool-tag-value
    lisp-string-tag-value
    lisp-builtin-tag-value
    lisp-symbol-tag-value
    lisp-special-tag-value
    lisp-compound-tag-value
    lisp-error-tag-value
    lisp-unspecific-tag-value
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

: lisp-pair-destruct ( lisp - lisp lisp )
    dup lisp-pair-car @ swap lisp-pair-cdr @ ;

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
    cell% field lisp-bool-tag
    cell% field lisp-bool-value
end-struct lisp-bool%

: lisp-bool ( b - a )
    lisp-bool% heap-alloc dup >r if 
        lisp-bool-tag-value
        r@ lisp-bool-tag !
        r@ lisp-bool-value !
    then r> ;
;

: lisp-bool? @ lisp-bool-tag-value = ;

: lisp-true  1 lisp-bool ;

: lisp-false 0 lisp-bool ;

: lisp-is-true ( lisp - b ) dup 0 = if
        drop 1 
    else
        dup lisp-bool? if
            lisp-bool-value @ 0 = not 
        else drop 1 
        then
    then ;
    
struct
    cell% field lisp-string-tag
    cell% field lisp-string-value
end-struct lisp-string%

: lisp-string ( s - a )
    lisp-string% heap-alloc dup >r if 
        lisp-string-tag-value 
        r@ lisp-string-tag !
        r@ lisp-string-value !
    then r> ;
;

: lisp-string? @ lisp-string-tag-value = ;


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

: lisp-symbol? @ lisp-symbol-tag-value = ;

struct
    cell% field lisp-unspecific-tag
end-struct lisp-unspecific% 

: lisp-unspecific 
    lisp-unspecific% heap-alloc dup >r if
        lisp-unspecific-tag-value
        r@ lisp-unspecific-tag !
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

: lisp-error? @ lisp-error-tag-value = ;

