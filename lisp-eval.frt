global dispatch-lisp-eval
: lisp-eval ignore-null dispatch-lisp-eval @ execute ;


: lisp-extract-args-1 
' lisp-pair-destruct , 
' drop , 
' dup , 
' lisp-error , 
' is-of-type , 
' if execute
' exit ,
' then execute 
; IMMEDIATE

: lisp-extract-args-2 ' lisp-pair-destruct , ' lisp-pair-destruct , ' drop , 
' >r , ( arg1 , arg2 )
' dup , ' lisp-error , ' is-of-type , 
' if execute
' r> , ' drop , 
' exit ,
' then execute 
' r> ,  ( arg1 arg2 )
' dup , ' lisp-error , ' is-of-type , 
' if execute
' swap , ' drop , 
' exit ,
' then execute 
; IMMEDIATE


: lisp-extract-args-3 ' lisp-pair-destruct , ' lisp-pair-destruct , ' lisp-pair-destruct  , ' drop , 
' >r , ' >r ,  ( arg1 , arg3 arg2 )
' dup , ' lisp-error , ' is-of-type , ' if execute
' r> , ' drop , ' r> , ' drop , ' exit , ' then execute
' r> , ( arg1 arg2 , arg3 )
' dup , ' lisp-error , ' is-of-type , ' if execute
' r> , ' drop , 
' swap , ' drop , 
' exit , ' then execute 

' r> , ( arg1 arg2 arg3 )
' dup , ' lisp-error , ' is-of-type , ' if execute
' swap , ' drop , 
' swap , ' drop , 
' exit , ' then execute 
; IMMEDIATE


: lisp-special-quote lisp-extract-args-1 ;

: lisp-builtin-cons lisp-extract-args-2 swap cons ;

: lisp-builtin-car lisp-extract-args-1 lisp-pair-destruct drop  ;

: lisp-builtin-cdr lisp-extract-args-1 lisp-pair-destruct swap drop  ;

: lisp-builtin-print lisp-extract-args-1
                     dup type-of
                     case
                       lisp-string of  dup @ prints endof
                       over show
                     endcase ;

: lisp-builtin-symbol? lisp-extract-args-1 lisp-symbol is-of-type lisp-bool-from-forth ;
: lisp-builtin-nil? lisp-extract-args-1 not lisp-bool-from-forth ;
: lisp-builtin-cons? lisp-extract-args-1 
    dup not if lisp-true 
    else lisp-symbol is-of-type lisp-bool-from-forth then ;

: lisp-builtin-number? lisp-extract-args-1 lisp-number is-of-type lisp-bool-from-forth ;
: lisp-builtin-string? lisp-extract-args-1 lisp-string is-of-type lisp-bool-from-forth ;

: lisp-special-if
    lisp-extract-args-3 
    >r >r lisp-eval lisp-bool-is-true if
    r> r> drop lisp-eval else
    r> drop r> lisp-eval then 
;

: lisp-builtin-progn 
dup lisp-nil? if drop lisp-# else lisp-list-last then 
;

: lisp-special-lambda lisp-extract-args-2 swap lisp-compound new ;



( 
>r 
repeat 
over lisp-nil? not over lisp-nil? not land if
    lisp-two-list-destruct r@ execute 0
     else 2drop 1 then
until
r> drop ;  )


( : lisp-assign-args 
  rec
  2dup 0 = swap 0 = land if 2drop exit then
  lisp-two-list-destruct >lisp-symbol-name @ swap symtab-add
  recurse
;)

: lisp-lift-num 
  >r 
  >lisp-number-value @ @ swap 
  >lisp-number-value @ @ swap 
  r> execute li ; 

: lisp-builtin-+ lisp-extract-args-2 ' + lisp-lift-num ; 
: lisp-builtin-- lisp-extract-args-2 ' - lisp-lift-num ; 
: lisp-builtin-* lisp-extract-args-2 ' * lisp-lift-num ; 
: lisp-builtin-/ lisp-extract-args-2 ' / lisp-lift-num ; 
: lisp-builtin-< lisp-extract-args-2 ' < lisp-lift-num >lisp-number-value @ @ lisp-bool-from-forth ;

: lisp-assign-arg ( symb val ) 
swap >lisp-symbol-name @ swap symtab-add ;

( define name val )
: lisp-builtin-define
  lisp-extract-args-2
    lisp-eval
  lisp-assign-arg
  lisp-#
;


: lisp-apply ( arg builtin/special/compound - res )
  dup type-of case

    lisp-builtin of
      swap ' lisp-eval lisp-list-map swap 
      >lisp-builtin-xt @ @ execute 
    endof

    lisp-special of >lisp-special-xt @ @ execute endof

    lisp-compound of 
      swap
      '  lisp-eval lisp-list-map 
      swap 
      symtab-save >r
      >r
      ( args , oldsymtab compound)
      r@ >lisp-compound-args @ swap ' lisp-assign-arg lisp-list-apply-2 
      ( , oldsymtab compound )  
      r> >lisp-compound-body @ lisp-eval
      r> symtab-restore 
    endof 
     .RED[ ." Can not apply: " ]NOCOL. over ? cr 
     drop drop lisp-# swap
  endcase
;


: lisp-special-quote lisp-extract-args-1 ;

: lisp-special-set 
  lisp-extract-args-2

  lisp-eval swap lisp-eval ( val sym )
  dup >lisp-symbol-name @
  dup symtab-lookup
  dup if
    ( val sym symname symtab-entry-addr )
    swap drop
    swap drop
    >symtab-lisp !
    lisp-#
  else
    ( val sym symname 0 )
    drop drop swap drop
    m" Can not set a non-existing symbol: " lisp-error
  then
;

: lisp-builtin-eq  lisp-extract-args-2 = lisp-bool-from-forth ;

: --lisp-builtin-eql rec
2dup lor not if 2drop lisp-true else
    over type-of over type-of = if

    over type-of case

        lisp-number of 
            swap >lisp-number-value @ @ 
            swap >lisp-number-value @ @  = 
            lisp-bool-from-forth
        endof

        lisp-string of 
            swap >lisp-string-value @ 
            swap >lisp-string-value @ string-eq 
            lisp-bool-from-forth
        endof
        
        lisp-bool of 
            lisp-bool-is-true swap lisp-bool-is-true = 
            lisp-bool-from-forth
        endof

        lisp-symbol of lisp-builtin-eq endof

        lisp-pair of 
           lisp-two-list-destruct
           recurse lisp-bool-is-true >r recurse lisp-bool-is-true r> land
           lisp-bool-from-forth 
        endof
    endcase 
    else 2drop lisp-false then 
then
; 

: lisp-builtin-eql lisp-extract-args-2 --lisp-builtin-eql ; 

( lisp - lisp )
: impl-lisp-eval
  ignore-null
  dup type-of case
    lisp-number of endof
    lisp-string of endof
    lisp-error of endof
    lisp-bool of endof
    lisp-builtin of endof
    lisp-special of endof
    lisp-unspecific of endof
    lisp-compound of endof

    lisp-symbol of

      dup >lisp-symbol-name @ symtab-lookup @ ( name res )

      dup not if
        drop m" Error: can not find symbol " lisp-error new
      else swap drop then
    endof

    lisp-pair of
      lisp-pair-destruct
      swap lisp-eval
      lisp-apply
    endof

  endcase 

; ' impl-lisp-eval dispatch-lisp-eval !
