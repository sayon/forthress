lisp-max-tag-value cells allot constant lisp-eval-dispatch 

: lisp-eval ( lisp - lisp )
    ( ." eval: " dup lisp-show cr)
    dup if 
        dup @ cells lisp-eval-dispatch + @ execute
    then ;


: lisp-eval-number ( lisp - lisp ) ;
: lisp-eval-bool  ( lisp - lisp ) ; 

: lisp-fun2 lisp-pair-destruct lisp-pair-destruct drop ;
: lisp-fun1 lisp-pair-car @ ;
: lisp-2head lisp-fun2 ; 

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
     ( ." eval: apply function "  2dup swap lisp-show  ."  to " lisp-show cr )
    swap lisp-eval dup @ case 
        lisp-builtin-tag-value of 
            ( ." builtin " dup lisp-show ."  to " over  lisp-show cr   )
            >r lisp-eval-list r> 
            lisp-builtin-xt @ 
            ( ." eval: executing  " dup decompile  ." " cr )
            execute 
            endof 
        lisp-special-tag-value of 
             ( ." special "  )
            lisp-special-xt @ 
            ( dup decompile  cr )
            execute 
            endof 
        lisp-compound-tag-value of 
             ( ." compound " dup lisp-show  over ."  to " lisp-show cr  )
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
        lisp-error-tag-value of
            swap drop 
            endof
        endcase ;

: lisp-noeval ( lisp - lisp ) ;

: lisp-eval-pair  ( lisp - lisp )    
    ( ." eval: pair " dup lisp-show cr  )
     dup if
        lisp-pair-destruct lisp-apply-func 
    then ;

: lisp-error-no-such-symbol 
    ( lisp - lisp )
    " No such symbol" swap lisp-error ;

: lisp-error-invalid-type 
    ( lisp - lisp )
    " Invalid type " swap lisp-error ;

: lisp-error-no-valid-condition
    ( lisp - lisp )
    " `cond` should have at least one valid branch" swap lisp-error ;
;

: lisp-eval-symbol ( lisp - lisp )    
    dup if
        ( x )
        dup lisp-symbol-name @ symtab-lookup dup if 
        ( x a)
            symtab-lisp @ swap drop  
            else drop lisp-error-no-such-symbol then
    else lisp-error-invalid-type
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

: lisp-2fun-nums 
    dup lisp-number? not if 
        swap drop lisp-error-invalid-type 0
    else 
        over lisp-number? not if 
        drop lisp-error-invalid-type 0 
            else 2drop 1 
        then
    then ;
 
: lisp-builtin-< lisp-fun2  
    lisp-number-value @ swap lisp-number-value @  swap < lisp-bool ;
        
: lisp-builtin-nil 0 ; 
: lisp-special-define-xt ( lisp - lisp ) 
    lisp-2head 
    swap lisp-symbol-name @ swap lisp-eval dup >r symtab-add r> drop  lisp-unspecific ; 

: lisp-special-set!-xt ( lisp - lisp ) 
    lisp-2head 
    lisp-eval swap 
    dup lisp-symbol? if 
        lisp-symbol-name @ symtab-lookup dup if 
         symtab-lisp ! 
            else 
            drop lisp-error-no-such-symbol
            then 
    else drop lisp-error-no-such-symbol 
        then lisp-unspecific ; 

: lisp-special-quote-xt lisp-pair-destruct drop ( lisp - lisp ) ;

: lisp-special-begin-xt ( lisp - lisp )
( ." eval begin" cr ) 
    lisp-unspecific >r 
    dup if 
        repeat
            lisp-pair-destruct swap lisp-eval r> drop >r 
            
        dup not 
        until
        drop r> 
    else r> then  
;
   
 
: lisp-builtin-print 
 lisp-pair-destruct drop 
    dup if 
        dup lisp-string? if
        lisp-string-value @ prints
    else
    lisp-show 
    then
    else lisp-show
then lisp-unspecific ;

: lisp-builtin-eql 
    lisp-2head lisp-eq lisp-bool 
;


: lisp-error-change-expr ( error? newlisp - newerror | oldnoterror ) 
    swap >r  ( newlisp , error?) 
    r@ lisp-error? if
       r@ lisp-error-lisp ! r> 
    else drop r>  
then ;


: lisp-special-cond-r rec
dup if 
    lisp-pair-destruct swap ( tail head  ) 
    lisp-pair-destruct lisp-pair-destruct drop swap 
    ( tail hexpr hcond )
     lisp-eval lisp-is-true if 
            swap drop lisp-eval 
        else
            drop recurse
        then   
    else 
        lisp-error-no-valid-condition
    then
;

: lisp-special-cond ( lisp - lisp )
    dup lisp-special-cond-r swap 

    lisp-error-change-expr 

;
    
: lisp-special-lambda  ( lisp - lisp ) 
    lisp-pair-destruct lisp-pair-destruct drop lisp-compound ;

' lisp-eval-symbol    lisp-symbol-tag-value     cells lisp-eval-dispatch + !
' lisp-eval-pair      lisp-pair-tag-value       cells lisp-eval-dispatch + !
' lisp-noeval         lisp-number-tag-value     cells lisp-eval-dispatch + !
' lisp-noeval         lisp-compound-tag-value   cells lisp-eval-dispatch + !
' lisp-noeval         lisp-error-tag-value      cells lisp-eval-dispatch + !
' lisp-noeval         lisp-string-tag-value     cells lisp-eval-dispatch + !
' lisp-noeval         lisp-bool-tag-value       cells lisp-eval-dispatch + !
' lisp-noeval         lisp-unspecific-tag-value cells lisp-eval-dispatch + !


: lisp-builtin-symbol? lisp-fun1 lisp-symbol? lisp-bool ;
: lisp-builtin-error? lisp-fun1 lisp-error? lisp-bool ;
: lisp-builtin-string? lisp-fun1 lisp-string? lisp-bool ;
: lisp-builtin-pair? lisp-fun1 lisp-pair? lisp-bool ;
