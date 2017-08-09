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

: is_word >r last_word @
repeat 
dup cfa r@  = 
if dup 
else @ dup not  
then
until r> drop ;

: decompile dup is_word dup if ." <" 9 + prints ." >" else drop   . then ;

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
." PC = " r@ OFF_PC + @ . 
r@ OFF_W +  @  
."   W = " dup .  ."   ( inside " decompile ."  )"  cr cr


." Stack : " cr 
r@ OFF_rsp + @ 
."     " 2 cells - dup @ . cr
."     " cell% + dup @ . cr
." sp=>" cell% + dup @ . cr
."     " cell% + dup @ . cr
."     " cell% + dup @ . cr
."     " cell% + dup @ . cr
."     " cell% + dup @ . cr


( cr ." dictionary " cr dump ) ( TODO: Add dump to file )
 r> drop ;


