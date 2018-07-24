class raw-cell class-end
' cell% raw-cell >class-size !
raw-cell declare-show[ @ ." raw <" . ." >" ]end-show;
raw-cell declare-ctor[ raw-cell cell% class-alloc swap over ! ]end-ctor;

class int class-end
' cell% int >class-size !

int declare-show[ @ . ]end-show;
int declare-ctor[ cell% class-alloc dup -rot  ! ]end-ctor;
: int-copy @ int new ;
' int-copy int >class-copy !

: ref raw-cell ;

class pair
ref :: >fst
ref :: >snd
class-end

: =>0 0 ;
( --- managed string --- )

class string class-end
' count string >class-size !

: string-show QUOTE emit prints QUOTE emit ;
' string-show string >class-show !

: m" ' h" execute compiling if
       ' dup , ' string , ' manage ,
     else
       dup string manage
     then ; IMMEDIATE

: i int new ;
