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
: cons lisp-pair new ;
: lisp-car >lisp-pair-car @ ;
: lisp-cdr >lisp-pair-cdr @ ;
: lisp-is-pair lisp-pair is-of-type ;

class lisp-nil-class class-end
lisp-nil-class ctor=[ class-alloc-default ]ctor;
lisp-nil-class show=[ drop ." nil"]ctor;
\ : nil-copy ; ' nil-copy lisp-nil-class >class-copy !

lisp-nil-class new singleton lisp-nil
: lisp-nil? lisp-nil-class is-of-type ; 

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

include lisp-list.frt

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
\  : lisp-unspecific-copy ; ' lisp-unspecific-copy lisp-unspecific >class-copy !

lisp-error show=[ dup >lisp-error-string @ show >lisp-error-lisp @ show ]show;


: li i lisp-number new ;
: lambda lisp-compound new ;
: s lisp-symbol new ;
: lsp" ' m" execute  compiling if ( ") 
         ' lisp-string , ' new ,
       else
         lisp-string new
       then ; IMMEDIATE


: lisp-is-error lisp-error is-of-type ;

: lisp-bool-is-true ignore-null @ @ 0 <> ;
: lisp-bool-from-forth 0 = if lisp-false else lisp-true then ;

: lisp-bool-from-int lisp-number :arg1
 >lisp-number-value @ @
 if lisp-true else lisp-false then 
;


