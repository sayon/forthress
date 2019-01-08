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
    QUOTE of 0 endof
       dup char-is-digit not swap
   endcase ;    ( )

: char-is-quote .' " = ;

: char-not-quote char-is-quote not ;

: char-ident-tail  ( c - b ) >r
        r@ char-is-ws not
        r@ .' ( = not land
        r@ .' ) = not land
        r@ .' . = not land
        r> land ;
: char-is-ws ( c - b )
  case
    10 of 1 endof
    32 of 1 endof
    9 of  1  endof
    0 swap
  endcase ;


: char-ident-start ( c - b )
  case
    .' ( of 0 endof
    .' ) of 0 endof
    .' . of 0 endof
       dup char-is-digit not swap
   endcase ;

: char-is-quote .' " = ;

: char-not-quote char-is-quote not ;


: char-is-digit .' 0 .' 9 in-range ;


class Parser
    String :: >parser-text
    Int    :: >parser-at
class-end

Parser show=[
    ." Parser (" dup >parser-text @ show ." , " >parser-at @ show ." )"
]show;


( string - parser )
: parser-init 1 :args
              String :arg1

              0 i swap Parser new ;

( parser - offset )
: parser-offset 1 :args
                Parser :arg1

                >parser-at @ @ ;

( parser - parser addr )
: parser-current-addr 1 :args
  dup >parser-text @ over parser-offset +  ;

( parser - parser char )
: parser-peek 1 :args
              Parser :arg1
              parser-current-addr c@ ;

( parser inc - parser )
: parser-advance
  2 :args
  Parser :arg2

  over parser-peek swap drop if
    over parser-offset +
    over >parser-at @ !
  else drop then
;

( parser - parser )
: parser-next 
  1 :args
  Parser :arg1 
  1 parser-advance ;

( parser - parser 0/1 )
: parser-end
  1 :args
  Parser :arg1
  parser-peek c@ 0 <> ;

( parser checker - parser char 1 | parser 0 )
: parse-char-class 
  2 :args
  Parser :arg2
  >r parser-peek dup r> execute if swap parser-next swap 1 else drop 0 then ;

: parse-digit ( parser - parser digit 1 or parser 0 ) 1 :args
  ' char-is-digit parse-char-class ;

: parse-number ( parser - parser number 1 or parser 0 ) 1 :args
  parse-digit if
    .' 0 -  >r
    repeat
      parse-digit if
        r> 10 * .' 0 -  + >r 0
      else 1  then
    until r> 1
  else 0
  then ;

: parse-skip-ws ( parser - parser ) 1 :args
  repeat
  parser-peek char-is-ws if parser-next 0 else 1 then
  until ;

: parse-char ( parser c - parser 0/1 )
  >r parser-peek r> = if parser-next 1 else 0 then ;


global dispatch-parse-lisp
: parse-lisp dispatch-parse-lisp @ execute ;


: parse-symbol ( parser - parser 0 | parser lisp 1 ) 1 :args
  ' char-ident-start parse-char-class if
    inbuf c! inbuf 1 + >r
    repeat
' char-ident-tail parse-char-class if
  r@ c!
  r> 1 + >r
  0
    else 0 r> c!
        inbuf string-from-buffer lisp-symbol new
        1 1
    then
    until
  else
    0
  then
;


: parser-current-text
  dup >parser-text @ swap >parser-at @ @ +
;

: parse-keyword ( parser str  - parser 0/1 ) 2 :args
  over parser-current-text
  over string-prefix if count parser-advance 1
                     else drop 0 then ;

: lisp-pair-reverse
  dup >lisp-pair-car @ copy
  swap >lisp-pair-cdr @ copy
  cons ;


: parse-list-rev
  1 :args
  dup copy >r
  " (" parse-keyword not if drop r> 0 exit then 
  0 >r
repeat
parse-skip-ws
" )" parse-keyword if r> r> drop 1 1 else
                     parse-lisp if
                       r> swap lisp-pair new >r 0
                     else
                       r> drop r> 0 1 then
                   then
until
;


: lisp-list-reverse
  1 :args
  ignore-null
  0 swap
    repeat
    dup if
      lisp-pair-destruct -rot cons swap 0
    else drop 1
    then
    until
;


: parse-list ( parser - parser 0 | parser list 1 )
  1 :args
dup copy >r parse-list-rev if r> drop lisp-list-reverse 1 else drop r> 0 then ;

: parse-pair ( parser - parser 0 | parser pair 1 )
  1 :args
  dup copy >r
  " (" parse-keyword not if drop r>  0 exit then
  parse-skip-ws
  parse-lisp not if drop r> 0 exit then
  swap ( fst parser )
  parse-skip-ws
  " ." parse-keyword not
  if 2drop r> 0 exit then  ( ")
  parse-skip-ws
  parse-lisp not if 2drop r> 0 exit then
  swap
  ( fst snd parser )
  parse-skip-ws
  " )" parse-keyword not if 2drop drop r> 0 exit then
  -rot swap lisp-pair new
  r> drop 1
;

: parse-string  ( parser - parser heapstring 1 | parser 0 )
  1 :args

    ' char-is-quote parse-char-class if
        drop
        inbuf >r
        repeat
        ' char-not-quote parse-char-class if
             r@ c!
             r> 1 + >r
             0
            else  0 r> c!
                  parser-next
            inbuf string-from-buffer
            1 1
            then
        until
else 0
then ;

: parse-expr
  1 :args
    parse-skip-ws
    parse-number if i lisp-number new 1 exit then
    parse-string if string-unescape lisp-string new 1 exit then
    parse-list if 1 exit then
    parse-pair if 1 exit then
    " nil" parse-keyword if 0 1 exit then
    " #t" parse-keyword if lisp-true 1 exit then
    " #f" parse-keyword if lisp-false 1 exit then
    parse-symbol if 1 exit then
    .RED[ ." Can not parse! " ]NOCOL. ?
; ' parse-expr dispatch-parse-lisp !
