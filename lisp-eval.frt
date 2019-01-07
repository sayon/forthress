    (
    " <"        ' lisp-builtin-<         lisp-builtin symtab-add
    " print"    ' lisp-builtin-print     lisp-builtin symtab-add
    " eql"      ' lisp-builtin-eql       lisp-builtin symtab-add
    " cond"     ' lisp-special-cond      lisp-special symtab-add
    " symbol?"  ' lisp-builtin-symbol?   lisp-builtin symtab-add
    " error?"   ' lisp-builtin-error?    lisp-builtin symtab-add
    " string?"  ' lisp-builtin-string?   lisp-builtin symtab-add
    " pair?"    ' lisp-builtin-pair?     lisp-builtin symtab-add
    )

global dispatch-lisp-eval
: lisp-eval dup if dispatch-lisp-eval @ execute then ;


: lisp-extract-args-1 lisp-pair-destruct drop ; 
: lisp-extract-args-2 lisp-pair-destruct lisp-pair-destruct drop ;


: lisp-lift ( i1 i2 op  - [op^ i1 i2 ] ) lisp-number :arg2 ( lisp-number :arg3 )
            over  lisp-is-error if drop swap drop exit then
            2over lisp-is-error if 2drop exit then

            >r
            >lisp-number-value @ @ swap >lisp-number-value @ @ swap
            r> execute li ;


: lisp-lift-+ ' + lisp-lift ;
: lisp-lift-- ' - lisp-lift ;
: lisp-lift-* ' * lisp-lift ;
: lisp-lift-/ ' / lisp-lift ;

( lisp acc op^ - remaining-args  newacc op^ )
: lisp-builtin-op-rec

  >r
  swap
  lisp-pair-destruct ( acc car cdr )
  -rot ( cdr acc car )
  r@ execute r>
;

( lisp op^ - ) 
: lisp-builtin-op
  lisp-pair :arg2

  >r lisp-pair-destruct ( car cdr )

  dup not if
    ." An operation should be applied to more than one operand!" r> drop 2drop exit then

  swap r>
repeat
  lisp-builtin-op-rec 2over not
until
drop swap drop 
;

: lisp-builtin-+  ' lisp-lift-+ lisp-builtin-op ;
: lisp-builtin--  ' lisp-lift-- lisp-builtin-op ;
: lisp-builtin-*  ' lisp-lift-* lisp-builtin-op ;
: lisp-builtin-/  ' lisp-lift-/ lisp-builtin-op ;


: lisp-builtin-< lisp-extract-args-2
 >lisp-number-value @ swap >lisp-number-value @ > Int new lisp-number new ;

: lisp-special-quote lisp-extract-args-1 ;

: lisp-builtin-print lisp-extract-args-1
                     dup type-of
                     case
                       lisp-string of  dup @ prints endof
                       over show
                     endcase
;


: lisp-special-begin dup if  
    repeat
    lisp-pair-destruct >r lisp-eval r>  ( y xs ) 
    dup not ( y xs 0? ) 
    until 
    drop
    else drop lisp-# then 
;


: lisp-special-lambda lisp-extract-args-2
                      swap lisp-compound new ;


( x::xs y::ys -- xs ys x y  )
: lisp-two-list-destruct
  >r lisp-pair-destruct ( x xs , y::ys)
  swap r> lisp-pair-destruct ( xs x y ys )
  -rot
  ;


: lisp-assign-args ( argsvalues args )
  rec
  2dup 0 = swap 0 = land if 2drop exit then
  lisp-two-list-destruct >lisp-symbol-name @ swap symtab-add
  recurse
;

: lisp-apply ( arg builtin/special/compound - res )
  dup type-of case
    lisp-builtin of
      swap
      '  lisp-eval lisp-list-map ( evaluate all arguments in a call-by-value fashion )
      swap >lisp-builtin-xt @ @  ( execute implementation in forth )
      execute
    endof
    lisp-special of
      ( specials are different from builtins because they do not force argument evaluation )
      >lisp-special-xt @ @
      execute
    endof

    lisp-compound of
      symtab-save >r
      >r
      ( args , oldsymtab compound)
      r@ >lisp-compound-args @ lisp-assign-args if
        r> >lisp-compound-body @
        lisp-eval
      else
        drop ( args )
        r> m" Invalid arguments count: " lisp-error new
      then
      r> symtab-restore
    endof

  endcase ;


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

( define name val )
: lisp-builtin-define
  lisp-extract-args-2
  swap >lisp-symbol-name @ swap
  symtab-add
  lisp-#
;


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

  endcase ; ' impl-lisp-eval dispatch-lisp-eval !
