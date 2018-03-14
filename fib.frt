( n -- )
: fib-n
  dup 0 < if ." Negative argument " else
  dup 2 < if 1 else
    >r
    1 1 
    r> 1 
    do
        swap over + 
    loop 
    swap drop 
    then 
then ; 

: prime ; 

: perfect-sq ; 



