lisp-max-tag-value cells allot constant lisp-eq-dispatch 

: lisp-same-tags-2 @ swap @ = ;

: lisp-eq ( lisp lisp - b )
    2dup land if 
        2dup lisp-same-tags-2 if
            over @ cells lisp-eq-dispatch + @ execute
        else 0
        then
    else 
    = 
    then ;

: lisp-eq-builtin ( lisp lisp - b ) = ;

: lisp-eq-number ( lisp lisp - b )
    lisp-number-value @ swap lisp-number-value @ =  
;

: lisp-noeq 2drop 0 ;

: lisp-eq-pair  
    lisp-pair-destruct >r  ( x y1 , y2 )
    swap lisp-pair-destruct >r ( y1 x1 , y2 x2)
    swap lisp-eq
    r> r> lisp-eq
    land ;

: lisp-eq-compound 
   over lisp-compound-args @ over lisp-compound-args @ lisp-eq >r 
   lisp-compound-body @ swap lisp-compound-body @ lisp-eq r> land 
; 

: lisp-eq-symbol 
    lisp-symbol-name @ 
    swap lisp-symbol-name @ 
    string-eq 
;

: lisp-eq-bool
    lisp-is-true swap lisp-is-true = ; 
      
' lisp-eq-symbol    lisp-symbol-tag-value     cells lisp-eq-dispatch + !
' lisp-eq-pair      lisp-pair-tag-value       cells lisp-eq-dispatch + !
' lisp-eq-number    lisp-number-tag-value     cells lisp-eq-dispatch + !
' lisp-eq-compound  lisp-compound-tag-value   cells lisp-eq-dispatch + !
' lisp-eq-builtin   lisp-builtin-tag-value    cells lisp-eq-dispatch + !
' lisp-noeq         lisp-error-tag-value      cells lisp-eq-dispatch + !

' lisp-eq-bool      lisp-bool-tag-value       cells lisp-eq-dispatch + !

( FIXME unspecifics can not be compared and should not be! Gotta throw invalid type error) 
