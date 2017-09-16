lisp-max-tag-value cells allot constant lisp-show-dispatch 

: lisp-show 
    dup if 
        dup @ cells lisp-show-dispatch + @ execute
        else ." nil " drop
    then
;

: lisp-show-pair 
        dup ." (" lisp-pair-car @ lisp-show ."  " lisp-pair-cdr @ lisp-show ." )" ;

: lisp-show-number 
    lisp-number-value @ . ;

: lisp-show-symbol
    lisp-symbol-name  @ prints ;

: lisp-show-builtin
    lisp-builtin-xt @ decompile ;

: lisp-show-special
    ." ^" lisp-special-xt @ decompile ;

: lisp-show-special
    ." ~" lisp-special-xt @ decompile ;

: lisp-show-compound 
   ." (lambda (" dup lisp-compound-args @ lisp-show ." ) (" lisp-compound-body @ lisp-show ." )" ;

: lisp-show-error 
    ." Error in " dup lisp-error-lisp @ lisp-show ." :" dup lisp-error-str @ prints ;


' lisp-show-number   lisp-number-tag-value     cells lisp-show-dispatch + !
' lisp-show-pair     lisp-pair-tag-value       cells lisp-show-dispatch + !
' lisp-show-symbol   lisp-symbol-tag-value     cells lisp-show-dispatch + !
' lisp-show-builtin  lisp-builtin-tag-value    cells lisp-show-dispatch + !
' lisp-show-special  lisp-special-tag-value    cells lisp-show-dispatch + !
' lisp-show-compound lisp-compound-tag-value   cells lisp-show-dispatch + !
' lisp-show-error    lisp-error-tag-value      cells lisp-show-dispatch + !

