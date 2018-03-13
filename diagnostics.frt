( diagnostics words: decompilation, exception handling )

: info dup 9 + prints ." : " cfa . cr ; 
: dump last_word @
repeat 
dup info @ 
dup not until ;

: word_foreach >r last_word @
repeat 
dup r@ execute @ 
dup not until r> ;

: word_any >r last_word @
repeat 
dup r@ execute 
if dup 
else @ dup not 
then
until r> drop ;

: is-word >r last_word @
repeat 
dup cfa r@  = 
if dup 
else @ dup not  
then
until r> drop ;


: word-predecessor  ( wa - wa )
    >r last_word @
    repeat 
        dup @ dup if cfa r@ =  if 1 
                else @ 0
                then
            else drop drop 0 1
          then 
    until r> drop ;

: word-size ( xt - sz ) 
    dup word-predecessor dup not if drop here then
    swap - 
;

: word-contains-addr ( w a -- 0/1 )
    swap dup dup word-size + in-range ;

: ? " decompile" find cfa execute ;

: decompile >r last_word
    repeat 
    @ dup if 
        dup r@ word-contains-addr if 
                ." <" dup 9 + prints 
                r@ swap cfa - dup if ." +" . else drop then ." >"  1 
                else 0 then 
        else r@ . drop 1 then
    until r> drop ;

64 constant OFF_r11
72 constant OFF_r12
80 constant OFF_r13
88 constant OFF_r14
96 constant OFF_r15
160 constant OFF_rsp
168 constant OFF_rip

OFF_r15 constant OFF_PC
OFF_r14 constant OFF_W 
OFF_r13 constant OFF_rstack

( stackbase context - )
: trap >r drop 
." Exception. Here is some useful information: " cr
." PC = " r@ OFF_PC + @ dup . ."   " ?  cr
." W  = " r@ OFF_W  + @ dup . ."   " ?  cr

." program : " cr 
r@ OFF_PC + @ 
."      " 2 cells - dup ? ."     " dup @ ?  cr
."      " cell% +   dup ? ."     " dup @ ?  cr
." pc=> " cell% +   dup ? ."     " dup @ ?  cr
."      " cell% +   dup ? ."     " dup @ ?  cr
."      " cell% +   dup ? ."     " dup @ ?  cr
."      " cell% +   dup ? ."     " dup @ ?  cr
."      " cell% +   dup ? ."     " dup @ ?  cr


." Stack : " cr 
r@ OFF_rsp + @ 
."     " 2 cells - dup @ ? cr
."     " cell%   + dup @ ? cr
." sp=>" cell%   + dup @ ? cr
."     " cell%   + dup @ ? cr
."     " cell%   + dup @ ? cr
."     " cell%   + dup @ ? cr
."     " cell%   + dup @ ? cr


." Return stack : " cr 
r@ OFF_rstack + @ 2 cells - 
."     " cell% + dup   @ ."   " ?  cr
."   =>" cell% + dup   @ ."   " ?  cr
."     " cell% + dup   @ ."   " ?  cr
."     " cell% + dup   @ ."   " ?  cr
."     " cell% + dup   @ ."   " ?  cr

( dump )
( cr ." dictionary " cr dump ) ( TODO: Add dump to file )
 r> drop ;


