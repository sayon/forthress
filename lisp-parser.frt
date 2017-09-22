: char-is-digit .' 0 .' 9 in-range ;

: char-is-ws ( c - b ) 
    dup 10 = if drop 1 else
    dup 32 = if drop 1 else
    dup 9  = if drop 1 else drop 0 then then then ;

: char-ident-start ( c - b ) >r
        r@ char-is-digit not 
        r@ .' ) = not land  
        r> .' ( = not land  
        ;

: char-ident-tail  ( c - b ) >r
        r@ char-is-ws not 
        r@ .' ) = not land 
        r> land ;

struct 
    cell% field parser-position
end-struct parser%

: parser-info dup @ prints cr ;

: parser-new ( buf - parser ) 
    parser% heap-alloc  dup >r  
    parser-position ! 
    r> ; 

: parser-peek ( parser - parser char ) 
    dup parser-position @ c@ 
    ;

: parser-advance ( parser n - parser ) 
    >r dup parser-position dup @ r> + swap ! 
    ;
: parser-next ( parser - parser ) 1 parser-advance ;

: parse-digit ( parser - parser digit 1 or parser 0 ) 
    parser-peek dup char-is-digit if swap parser-next swap 1 else drop 0 then ;  

: parse-number ( parser - parser number 1 or parser 0 ) 
    parse-digit if
        .' 0 -  >r
        repeat 
        parse-digit if 
            r> 10 * .' 0 -  + >r 0 
            else 1  then
        until r> 1 
    else 0 
    then ;

: parse-skip-ws ( parser - parser )
    repeat 
        parser-peek char-is-ws if parser-next 0 else 1 then 
    until ;

: parse-char ( parser c - parser 0/1 )
    >r parser-peek r> = if parser-next 1 else 0 then ;


global parse-lisp-helper

: parse-lisp parse-lisp-helper @ execute ;

: parse-pair  ( parser - parser lisp 0/1 )
    .' ( parse-char if ( list start ) 
        parse-skip-ws parse-lisp if  >r 
        parse-skip-ws parse-lisp if  >r 
                parse-skip-ws .' ) parse-char if 
                    r> r> swap lisp-pair  1 
                    else r> r> 2drop 0 then 
                else r> r> 2drop 0 then 
            else r> drop 0 then
        else 0 then ;




: parse-symbol ( parser - parser symbol 1 | parser 0 )  
dup parser-position @ 
    inbuf 
    ( parser src dst )
    over c@ char-ident-start if  
    mcopy
        repeat
        over c@ char-ident-tail if 
            mcopy 0
            else 0 over c! drop 
            over parser-position !  1  
            then 
        until
    inbuf string-new lisp-symbol
    1
    else 2drop 
." Can't find symbol here \n" .S  0
    then 
;

: parse-keyword ( parser str  - parser 0/1 )
    >r dup parser-position @ r@  
    string-prefix if    
        r> count parser-advance 1
        else
        r> drop 0
        then ;

: parse-list-rev " (" parse-keyword if
    0 >r
    repeat 
        parse-skip-ws
        " )" parse-keyword if 
            r> 1 1
        else 
            parse-lisp if
                ." LISP: " 
                dup lisp-show cr 
                 r> lisp-pair >r 0 else r> drop 0 1 then 
        then
    until
    else 0
then ;

: lisp-list-reverse 
dup if 
   0 >r
    repeat 
        dup if 
            lisp-pair-destruct swap r> lisp-pair >r 0
        else drop r> 1 
        then   
    until 
then 
;

: parse-list parse-list-rev if lisp-list-reverse 1 else 0 then ;

: parse-expr parse-skip-ws  
    parse-number if lisp-number 1 
." NUMBER " cr 
else
    parse-list if 1 
    ." LIST " cr
else
    " nil" parse-keyword if 0 1 
." NIL KEYWORD" cr
else 
    parse-symbol if ." symbol!" 1 then then then then ;

' parse-expr parse-lisp-helper !


