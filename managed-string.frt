mtype string  mend

1 string >meta-is-value !

: string-show ." Str: " QUOTE prints QUOTE ." \"" ;
' string-show string >meta-printer ! 


: m" ' h" execute compiling if
    ' dup , ' string , ' manage , 
    else dup string  manage then ;
