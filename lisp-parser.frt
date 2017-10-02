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


: parser-info dup prints cr ;

: parser-peek ( parser - parser char ) 
    dup c@ ;
: parser-advance ( parser n - parser ) + ;
: parser-next ( parser - parser ) 1 parser-advance ;
: parse-char-class ( parser checker - parser char 1 | parser 0 )
    >r parser-peek dup r> execute if swap parser-next swap 1 else drop 0 then ;

: parse-digit ( parser - parser digit 1 or parser 0 ) 
    ' char-is-digit parse-char-class ;

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

: parse-symbol ( parser - parser 0 | parser lisp 1 )
' char-ident-start parse-char-class if 
    inbuf c! inbuf 1 + >r 
    repeat
    ' char-ident-tail parse-char-class if
         r@ c!
         r> parser-next >r 
         0 
        else 0 r> c!
        inbuf string-new lisp-symbol
        1 1
        then
    until 
else
." Can't find symbol here \n" parser-info 0  cr 
then
;

: parse-keyword ( parser str  - parser 0/1 )
    2dup string-prefix if    
        count parser-advance 1
        else
        drop 0
        then ;

: parse-list-rev " (" parse-keyword if
    0 >r
    repeat 
        parse-skip-ws
        " )" parse-keyword if 
            r> 1 1
        else 
            parse-lisp if 
                r> lisp-pair >r 0 
            else 
                r> drop ( fixme: lisp-destroy instead of drop ) 
                0 1 then 
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

: parse-list ( parser - parser 0 | parser list 1 )
    parse-list-rev if lisp-list-reverse 1 else 0 then ;

: parse-pair ( parser - parser 0 | parser pair 1 )
    " (" parse-keyword if
        parse-lisp if
            >r  
            " ." parse-keyword if
                   parse-lisp if
                       >r 
                        " )" parse-keyword if  
                            r> r> lisp-pair 1  
                       else r> drop 0 
                   else r> drop 0
            else 0
        else 0
    else 0
    then then then then then ;


: parse-expr parse-skip-ws  
        parse-number if lisp-number 1 
    else
        dup >r parse-list if r> drop 1 
    else drop r>  
        ( dup >r parse-pair if r> drop 1 
    else drop r>  )
        " nil" parse-keyword if 0 1 
    else 
        parse-symbol if 1 
    else 0
then then then then ( then ) ;

' parse-expr parse-lisp-helper !


h" (hello hey)" parse-list .S
