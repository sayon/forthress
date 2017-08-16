lisp-max-tag-value cells allot constant lisp-eval-dispatch 

: lisp-eval ( lisp - lisp )
." eval: " dup lisp-show cr
dup if 
	dup @ cells lisp-eval-dispatch + @ execute
then
;

: lisp-eval-number ( lisp - lisp )
    ." eval: number "  dup lisp-show cr 
    ;


: lisp-eval-list rec ( lisp - lisp )
    ." eval list " dup lisp-show  cr
    dup if
        dup lisp-pair? if 
            dup lisp-pair-car @ lisp-eval swap lisp-pair-cdr  @ recurse lisp-pair 
        else lisp-eval 
        then 
    then ;

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
    then
;

: lisp-apply-func ( fun args -- lisp )
    ." eval: apply function "
    swap dup @ case 
        lisp-builtin-tag-value of 
            ." builtin " dup lisp-show  over ."  to " lisp-show cr 
            lisp-builtin-xt @  
            swap lisp-eval-list swap 
            ." eval: executing  " dup decompile  ." "
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
                symtab-save >r 
                over lisp-compound-args @
                swap lisp-bind-args 
                symtab-dump
                lisp-compound-body @ lisp-eval 
                r> symtab-restore 
            endof
        endcase
cr
;


: lisp-eval-compound  ( lisp - lisp ) ;

: lisp-eval-pair  ( lisp - lisp )    
    ." eval: pair " cr 
    dup if
        dup lisp-pair-car @ lisp-eval swap lisp-pair-cdr @ lisp-apply-func 
    then ;


: lisp-eval-symbol ( lisp - lisp )    
    ." eval: symbol " cr 
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

( ' lisp-builtin-- lisp-builtin 42 lisp-number 2 lisp-number 0 lisp-pair lisp-pair lisp-pair dup lisp-show lisp-eval cr lisp-show)

( specials: lisp argument is on TOS )
: lisp-special-define-xt ( lisp - lisp ) 
    lisp-pair-destruct swap lisp-symbol-name @ swap lisp-eval dup >r symtab-add r> ; 

: lisp-builtin-set!-xt ( lisp - lisp ) 
    lisp-pair-destruct lisp-eval swap lisp-symbol-name @ symtab-lookup symtab-lisp ! ; 

: lisp-special-quote-xt ( lisp - ) ;
    
' lisp-eval-symbol    lisp-symbol-tag-value     cells lisp-eval-dispatch + !
' lisp-eval-pair      lisp-pair-tag-value       cells lisp-eval-dispatch + !
' lisp-eval-number    lisp-number-tag-value     cells lisp-eval-dispatch + !
' lisp-eval-compound  lisp-compound-tag-value   cells lisp-eval-dispatch + !
