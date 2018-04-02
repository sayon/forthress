mtype string  mend

1 string >meta-is-value !

: string-show ." Str: " QUOTE emit prints QUOTE emit ." \"" ;
' string-show string >meta-printer ! 


: m" ' h" execute compiling if
    ' dup , ' string , ' manage , 
    else dup string  manage then ; IMMEDIATE
