class raw-cell class-end
' cell% raw-cell >class-size !

raw-cell show=[ @ ." raw <" .hex ." >" ]show;
raw-cell ctor=[ cell% class-alloc dup -rot ! ]ctor;

class Ref
  raw-cell :: >ptr
class-end

Ref ctor=[ cell% class-alloc dup -rot ! ]ctor;
Ref show=[ @ ." & (" dup .hex ." ) "
dup type-of if 
  show
  else .hex then   ]show;

class Int class-end
' cell% Int >class-size !

Int show=[ @ . ]show;
Int ctor=[ cell% class-alloc dup -rot  ! ]ctor;
: int-copy @ Int new ;
' int-copy Int >class-copy !

: i Int new ;



class Pair
Ref :: >fst
Ref :: >snd
class-end



class List
Ref  :: >list-value
List :: >list-next
class-end


( list value -- new-list )
: list-prepend List new ;

( list fun -- )
: list-foreach
  >r
repeat
dup if
  dup >list-value @ r@ execute
  >list-next @ 0
else 1 then
until
r> 2drop
;

: c list-prepend ; 
List show=[ ." [ " ' --show-space list-foreach ." ]" ]show;
