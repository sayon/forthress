mtype string  mend

: string-show ." Str: " QUOTE prints QUOTE ." \"" ;
' string-show string >meta-printer ! 


: m" ' h" execute compiling if
    ' dup , ' string , ' manage , 
    else dup string  manage then ;
