: lisp-pair-destruct lisp-pair :arg1 dup >lisp-pair-car @ swap >lisp-pair-cdr @ ;

: lisp-pair-reverse dup lisp-car copy swap lisp-cdr copy cons ;

( [x::xs] acc f - xs [f x acc] f ) 
: lisp-list-foldl-rec
   >r >r lisp-pair-destruct swap r> swap 
   r@ execute r> 
;

( xs acc f - acc' ) 
: lisp-list-foldl

    :while-condition:
       over2 lisp-nil? not
    :perform: lisp-list-foldl-rec

    drop swap drop 
;  

: lisp-list-reverse lisp-nil ' cons lisp-list-foldl ;

: lisp-list-foreach-rec >r lisp-pair-destruct swap r@ execute r> ;

( list fun -- )
: lisp-list-foreach
    :while-condition: 
        over lisp-nil? not
    :perform: lisp-list-foreach-rec

    2drop ;


: lisp-list-map-rev-rec ( [x::xs] acc f -  xs [x'::acc] f )
>r >r lisp-pair-destruct swap r> swap  ( xs acc x, f )
r@ execute cons r> 
;


: lisp-list-map ( xs f - ys )
lisp-nil swap 
:while-condition: over2 lisp-nil? not :perform: lisp-list-map-rev-rec 
( xs [x'::acc] f )
drop swap drop lisp-list-reverse 
;


: lisp-is-list
  repeat
    dup lisp-is-pair if >lisp-pair-cdr @ 0 else 1 then
  until
  lisp-nil?
;

: lisp-show-list ( assumes a list ! )
    ." ("
    dup lisp-nil? not if
      lisp-pair-destruct swap show then
      repeat
      dup lisp-nil? not if lisp-pair-destruct swap ."  " show  0 else ." )" drop 1 then
      until
;


( x::xs y::ys -- xs ys x y  )
: lisp-two-list-destruct
  >r lisp-pair-destruct ( x xs , y::ys)
  swap r> lisp-pair-destruct ( xs x y ys )
  -rot
  ;

: lisp-list-apply-2-rec ( xs ys f - xs ys f ) 
>r lisp-two-list-destruct r@ execute r> 
;

: lisp-list-apply-2 ( xs ys f ) 
    :while-condition: 
    over2 lisp-nil? not over2 lisp-nil? not land 
    :perform: lisp-list-apply-2-rec 
    3drop  ;

: lisp-is-last-element 
dup lisp-is-pair if lisp-cdr lisp-nil?  else drop 0 then ;

: lisp-list-last
dup lisp-nil? if exit then 

:while-condition: 
    dup lisp-is-last-element not
:perform: lisp-cdr 
    lisp-car
;

