lisp-max-tag-value cells allot constant lisp-eq-dispatch 

: lisp-eq ( lisp lisp - b )
    ." eq: " 2dup lisp-show ."  " lisp-show cr
    2dup land if 
        2dup @ swap @ cells lisp-eq-dispatch + @ execute
    then ;

: lisp-eq-number ( lisp lisp - b )
    lisp-number-value @ swap lisp-number-value @ = ;

: lisp-pair-destruct ( lisp - lisp lisp )
    dup lisp-pair-car @ swap lisp-pair-cdr @ ;

: lisp-pairs-destruct ( l1 l2 -- tail1 tail2 head1 head2 )
    >r lisp-pair-destruct swap r> swap >r  ( tail1 l2 , head1 )
    lisp-pair-destruct swap r> swap  ;  

: lisp-bind-args  ( args values ) rec  
   2dup land if 
       lisp-pairs-destruct  
   2dup lisp-show cr lisp-show cr 
       swap lisp-symbol-name @ swap symtab-add
       recurse
    else 2drop
    then ;

: lisp-apply-func ( fun args -- lisp )
    ." eq: apply function "
    swap dup @ case 
        lisp-builtin-tag-value of 
            
            ." builtin " dup lisp-show ."  to " over  lisp-show cr 
            
            lisp-builtin-xt @  
            swap lisp-eq-list swap 
            ." eq: executing  " dup decompile  ." " cr
            execute 
            endof 
        lisp-special-tag-value of 

            ." special " 

            lisp-special-xt @ 
            dup decompile
            execute 
            endof 
        lisp-compound-tag-value of

            ." compound " dup lisp-show  over ."  to " lisp-show cr 

            ( args fun )
            symtab-save >r 
            dup >r
            lisp-compound-args @
            swap lisp-bind-args 
             
            symtab-dump
            r> lisp-compound-body @ lisp-eq 
            r> symtab-restore 
            endof
        endcase
cr
;

: lisp-noeq ( lisp - lisp ) ;

: lisp-eq-pair  ( lisp - lisp )    
    ." eq: pair " cr 
    dup if
        dup lisp-pair-car @ lisp-eq swap lisp-pair-cdr @ lisp-apply-func 
    then ;


: lisp-eq-symbol ( lisp - lisp )    
    ." eq: symbol " cr 
    dup if
        lisp-symbol-name @ symtab-lookup symtab-lisp @  
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
: lisp-builtin-+ ' + lisp-helper-binop ; 
: lisp-builtin-- ' - lisp-helper-binop ; 
: lisp-builtin-* ' * lisp-helper-binop ; 
: lisp-builtin-/ ' / lisp-helper-binop ; 

: lisp-special-define-xt ( lisp - lisp ) 
    lisp-pair-destruct swap lisp-symbol-name @ swap lisp-eq dup >r symtab-add r> ; 

: lisp-error-no-such-symbol 
    ( lisp - lisp )
    " No such symbol" swap lisp-error ;

: lisp-builtin-set-xt ( lisp - lisp ) 
    lisp-pair-destruct lisp-eq swap lisp-symbol-name @ dup symtab-lookup dup if 
         symtab-lisp ! drop 
        else drop lisp-error-no-such-symbol 
        then ; 

: lisp-special-quote-xt ( lisp - ) ;

: lisp-builtin-lambda  ( lisp - lisp ) 
    lisp-pair-destruct lisp-compound ; 
    
' lisp-eq-symbol    lisp-symbol-tag-value     cells lisp-eq-dispatch + !
' lisp-eq-pair      lisp-pair-tag-value       cells lisp-eq-dispatch + !
' lisp-eq-number    lisp-number-tag-value     cells lisp-eq-dispatch + !
' lisp-noeq         lisp-compound-tag-value   cells lisp-eq-dispatch + !
' lisp-noeq         lisp-error-tag-value      cells lisp-eq-dispatch + !
