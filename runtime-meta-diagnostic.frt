( classinf )
: class-info
  ."  --- " cr
  >r
  r@ ."   name: "   >class-name @ ?prints cr
  r@ ."   ctor: "   >class-ctor @ ? cr
  r@ ."   size: "   >class-size @ ? cr
  r@ ."   copy: "   >class-copy @ ? cr
  r@ ."   show: "   >class-show @ ? cr
  r@ ."   dtor: "   >class-dtor @ ? cr
  r@ >class-fields @ if
    ."   fields: " r@ >class-fields @ . cr

    r@ >class-fields cell% +

    r@ >class-fields @ 0
    do
      dup @ >class-name @ ."   + " ?prints cr
      cell% +
    loop
    drop
  else
     ."   no fields " cr 
  then 
  r> drop
."  --- " cr
;