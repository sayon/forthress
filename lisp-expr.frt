( Expressions )

class Lisp class-end


class lisp-number
  Int :: >lisp-number-value
class-end

class lisp-string
  String :: >lisp-string-value
class-end

class lisp-bool
  Int :: >lisp-bool-value
class-end

class lisp-pair
  Lisp :: >lisp-pair-car
  Lisp :: >lisp-pair-cdr
class-end

class lisp-builtin
      raw-cell :: >lisp-builtin-xt
class-end

class lisp-symbol
    String :: >lisp-symbol-name
class-end

class lisp-special
    raw-cell :: >lisp-special-xt
class-end

class lisp-unspecific class-end

class lisp-compound
    Lisp :: >lisp-compound-args
    Lisp :: >lisp-compound-body
class-end

class lisp-error
    String :: >lisp-error-string
    Lisp :: >lisp-error-lisp
class-end


lisp-number  show=[ >lisp-number-value @ show ]show;
lisp-string  show=[ >lisp-string-value @ show ]show;
lisp-bool    show=[ >lisp-bool-value @ @ if ." true" else ." false" then ]show;
: lisp-pair-destruct dup >lisp-pair-car @ swap >lisp-pair-cdr @ ;

( list fun -- )
: lisp-list-foreach
  >r
repeat
dup if
  dup >lisp-pair-car @ r@ execute
  >lisp-pair-cdr @ 0
else 1 then
until
r> 2drop
;

: lisp-list-map rec
                >r
                dup if
                  lisp-pair-destruct ( car cdr )
                  swap r@ execute swap r> recurse swap lisp-pair new
                else r> drop  then
;



: lisp-is-pair lisp-pair is-of-type ;

: lisp-is-list
  repeat
    dup lisp-is-pair if >lisp-pair-cdr @ 0 else 1 then
  until
  not
;

: lisp-show-list ( assumes a list ! )
    ." ("
    dup if
      lisp-pair-destruct swap show then
      repeat
      dup if lisp-pair-destruct swap ."  " show  0 else ." )" drop 1 then
      until
;

lisp-pair show=[ 
  dup lisp-is-list if
    lisp-show-list
  else
    ." ("  dup >lisp-pair-car @ show ."  . " >lisp-pair-cdr @ show ." )"
  then
]show;


lisp-builtin show=[ >lisp-builtin-xt @ ? ]show;
lisp-special show=[ >lisp-special-xt @ ." ^" ? ]show;
lisp-symbol  show=[ >lisp-symbol-name @ prints ]show;
lisp-special show=[ >lisp-special-xt @ show ]show;
lisp-unspecific show=[ ." <unspecific>" ]show;
lisp-compound show=[
." (λ " dup >lisp-compound-args @ show ." -> " >lisp-compound-body @ show ." )"
]show;

lisp-unspecific ctor=[ class-alloc-default ]ctor;
lisp-unspecific show=[ drop ." # "]ctor;

1 i lisp-bool new singleton lisp-true
0 i lisp-bool new singleton lisp-false
lisp-unspecific new singleton lisp-#

lisp-error show=[ dup >lisp-error-string @ show >lisp-error-lisp @ show ]show;


: li i lisp-number new ;
: cons lisp-pair new ;
: lambda lisp-compound new ;
: s lisp-symbol new ;
: lsp" ' m" execute  compiling if
         ' lisp-string , ' new ,
       else
         lisp-string new
       then ; IMMEDIATE


: lisp-is-error lisp-error is-of-type ;
