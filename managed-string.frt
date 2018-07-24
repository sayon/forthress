class string  class-end
string :value-type

: string-show QUOTE emit prints QUOTE emit ;
' string-show string >class-printer ! 

: m" ' h" execute compiling if
      ' dup , ' string , ' manage , 
        else dup string  manage then ; IMMEDIATE
        