( str - num )
: string-hash 
  0 >r ( init accumulator )
  repeat 
    dup c@ ( stacks: str char, acc ) 
    dup if ( not end of the line )  
        r> 13 * + 65537 % ( iteration of hash computations )
        >r 1 +  0 
    else ( end of line )
         drop drop r> 1
    then 
  until
;
