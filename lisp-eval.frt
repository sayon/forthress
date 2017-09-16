lisp-max-tag-value cells allot constant lisp-eval-dispatch 

: lisp-eval ( lisp - lisp )
    ( ." eval: " dup lisp-show cr)
    dup if 
        dup @ cells lisp-eval-dispatch + @ execute
    then ;


: lisp-eval-number ( lisp - lisp )
    ( ." eval: number "  dup lisp-show cr  ) ;


: lisp-pair-destruct ( lisp - lisp lisp )
    dup lisp-pair-car @ swap lisp-pair-cdr @ ;

: lisp-eval-list rec ( lisp - lisp )
    ( ." eval list " dup lisp-show  cr ) 
    dup if
        dup lisp-pair? if 
            lisp-pair-destruct 
            ( 2dup swap ." 1st: " lisp-show cr ." 2nd: "  lisp-show cr  ) 

swap lisp-eval swap recurse lisp-pair 
        else lisp-eval 
        then 
    then ;


: lisp-pairs-destruct ( l1 l2 -- tail1 tail2 head1 head2 )
    >r lisp-pair-destruct swap r> swap >r  ( tail1 l2 , head1 )
    lisp-pair-destruct swap r> swap  ;  

: lisp-bind-args  ( args values ) rec  
   2dup land if 
       ( ." iteration " cr .S cr )
       lisp-pairs-destruct 
       ( 2dup lisp-show cr lisp-show cr )
       swap lisp-symbol-name @ swap 
       ( 2dup lisp-show ."  -> "  prints cr )
       symtab-add
       ( ." ok " cr )
       recurse
    else 2drop
    then ;

: lisp-apply-func ( fun args -- lisp )
    ( ." eval: apply function " ) 
    swap dup @ case 
        lisp-builtin-tag-value of 
            ( ." builtin " dup lisp-show ."  to " over  lisp-show cr  ) 
            
            lisp-builtin-xt @ 
            ( ." eval: executing  " dup decompile  ." " cr)
            execute 
            endof 
        lisp-special-tag-value of 
            ( ." special " ) 
            lisp-special-xt @ 
            ( dup decompile )
            execute 
            endof 
        lisp-compound-tag-value of 
            ( ." compound " dup lisp-show  over ."  to " lisp-show cr ) 
            ( args fun )
            symtab-save >r 
            dup >r
            ( args fun , fun )
            lisp-compound-args @
            ( ." binding now " cr )
            swap  lisp-eval-list lisp-bind-args 
             
            ( symtab-dump )
            r> lisp-compound-body @ lisp-eval 
            r> symtab-restore 
            endof

        endcase ;

: lisp-noeval ( lisp - lisp ) ;

: lisp-eval-pair  ( lisp - lisp )    
    ( ." eval: pair " dup lisp-show cr ) 
     dup if
        lisp-pair-destruct swap lisp-eval  swap lisp-eval-list lisp-apply-func 
    then ;

: lisp-error-no-such-symbol 
    ( lisp - lisp )
    " No such symbol" swap lisp-error ;


: lisp-eval-symbol ( lisp - lisp )    
    ( ." eval: symbol " cr )
    dup if
        lisp-symbol-name @ dup symtab-lookup dup if 
            swap drop symtab-lisp @  
        else drop lisp-error-no-such-symbol then
    then ;


: lisp-list-fold ( action acc list ) rot >r 
    repeat 
    ( acc list? )
      dup lisp-pair? if 
            lisp-pair-destruct -rot  
            ( cdr acc car ) lisp-number-value @  
            r@ execute 
            ( cdr acc ) swap dup not 
        else lisp-number-value @ r@ execute 0 1 
        then 
    until 
    drop r> drop ;

: lisp-list-reducewith ( action lisp ) 
    lisp-pair-destruct >r lisp-number-value @ r>  lisp-list-fold  
;

: lisp-helper-binop swap lisp-list-reducewith lisp-number ; 
( : lisp-builtin-+ ' + lisp-helper-binop ;  )
: lisp-builtin-+ dup lisp-pair-car @ lisp-number-value @  swap lisp-pair-cdr @ lisp-pair-car @ lisp-number-value @ + lisp-number ;  
: lisp-builtin-- ' - lisp-helper-binop ; 
: lisp-builtin-* ' * lisp-helper-binop ; 
: lisp-builtin-/ ' / lisp-helper-binop ; 

: lisp-builtin-nil 0 ; 
: lisp-special-define-xt ( lisp - lisp ) 
    lisp-pair-destruct swap lisp-symbol-name @ swap lisp-eval dup >r symtab-add r> ; 

: lisp-builtin-set-xt ( lisp - lisp ) 
    lisp-pair-destruct lisp-eval swap lisp-symbol-name @ dup symtab-lookup dup if 
         symtab-lisp ! drop 
        else drop lisp-error-no-such-symbol 
        then ; 

: lisp-special-quote-xt ( lisp - ) ;
: lisp-builtin-print lisp-show ;

: lisp-builtin-lambda  ( lisp - lisp ) 
    lisp-pair-destruct lisp-compound ;

' lisp-eval-symbol    lisp-symbol-tag-value     cells lisp-eval-dispatch + !
' lisp-eval-pair      lisp-pair-tag-value       cells lisp-eval-dispatch + !
' lisp-eval-number    lisp-number-tag-value     cells lisp-eval-dispatch + !
' lisp-noeval         lisp-compound-tag-value   cells lisp-eval-dispatch + !
' lisp-noeval         lisp-error-tag-value      cells lisp-eval-dispatch + !
