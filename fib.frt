( n -- )
( 1 1 2 3 5 8 13 ...   )
(  
  int x1=1, x2=1;
repeat...
  x3 = x1 + x2;
  x1 = x2;
  x2 = x3;
_______

)
: fib-n ( n ) 
  dup 0 < if ." Negative argument " else
 ( if n < 0 then error return )   
  dup 2 < ( n [n<2])  if ( n ) drop 1 
 ( if n < 2 then return 1 )   
     else
            >r
            1 1 
            r> 1 
            do
                swap over + 
            loop 
            swap drop 
    then 

then ; 

