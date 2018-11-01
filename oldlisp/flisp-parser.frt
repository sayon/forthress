: char-is-digit .' 0 .' 9 in-range ;

: char-is-ws ( c - b )
  case
    10 of 1 endof
    32 of 1 endof
    9 of  1  endof
    0 swap
  endcase ;


: char-ident-start ( c - b )
  case
    .' ) of 0 endof
    .' ( of 0 endof
    .' . of 0 endof
       dup char-is-digit not swap
   endcase ;    ( ) 

: char-is-quote .' " = ;

: char-not-quote char-is-quote not ;

: char-ident-tail  ( c - b ) >r
        r@ char-is-ws not 
        r@ .' ) = not land 
        r@ .' . = not land  
        r> land ;


mtype parser
    string :: >parser-text
    int    :: >parser-at
mend

: parser-show
  ." (" dup >parser-text @ show ." , " >parser-at @ show ." )" ;

' parser-show parser >meta-printer !

( mstring )
: parser-init 0 int new swap parser new ;


: parser-peek-raw dup >parser-text @ over >parser-at @ >value @ +  ;

: parser-peek ( parser - parser char ) 
  parser-peek-raw
  dup _" \n" string-prefix if drop 10 else c@ then ;

: parser-inc-at ( parser inc - parser )
  over >parser-at @ >value @ + over >parser-at @ >value ! ;

: parser-next ( parser - parser )
  parser-peek-raw estring-char-length parser-inc-at ;

: parser-advance ( parser n - parser )
  0 do parser-next loop ;

: parser-end  ( parser - parser 0/1 )
  parser-peek-raw c@ 0 <> ;

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
    ." Ident start " dup emit  cr
    inbuf c! inbuf 1 + >r 
    repeat
      ' char-ident-tail parse-char-class if
  ." Ident ... " dup emit  cr
         r@ c!
         r> 1 + >r 
         0 
        else 0 r> c!
             inbuf string-new
             dup string manage lisp-symbol new
        1 1
        then
    until 
else
0 
then
;

( m" ahah" parser-init parse-symbol .S)

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
dup >r 
    parse-list-rev if r> drop lisp-list-reverse 1 else drop r> 0 then ;

: parse-pair-aux ( parser - parser 0 | parser pair 1 )
    " (" parse-keyword if
            parse-skip-ws parse-lisp if
      swap parse-skip-ws " ." parse-keyword if
                    parse-skip-ws parse-lisp if
        swap parse-skip-ws " )" parse-keyword if  
        >r lisp-pair r> swap 1  
        else drop drop  0 then
       else  drop  0 then
     else drop  0 then
    else 0 then 
    else 0 then 
    ;

: parse-pair
    dup >r parse-pair-aux if r> drop 1 else drop r> 0 then ;

: parse-string ( parser - parser heapstring 1 | parser 0 )
    ' char-is-quote parse-char-class if
        drop 
( ")
        inbuf >r 
        repeat
        ' char-not-quote parse-char-class if
             r@ c!
             r> parser-next >r 
             0 
            else  0 r> c!
            inbuf string-new
            >r parser-next r> 
            1 1
            then
        until 
else 0
then 
;
    
: parse-expr parse-skip-ws  
        parse-number if lisp-number 1 
    else
        parse-string if lisp-string 1
    else 
        parse-pair if 1
    else 
        parse-list if 1 
    else  
        " nil" parse-keyword if 0 1 
    else 
        " #t" parse-keyword if lisp-true 1
    else 
        " #f" parse-keyword if lisp-false 1
    else 
        parse-symbol if 1 
    else 0
then then then then then then then then ;

' parse-expr parse-lisp-helper !


