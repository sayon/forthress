class String class-end
' count String >class-size !

: string-show QUOTE emit prints QUOTE emit ;
' string-show String >class-show !

: m" ' h" execute compiling if
       ' dup , ' String , ' manage ,
       ' dup , ' gc-mark-collectable ,
     else
       dup String manage
       dup gc-mark-collectable
     then ; IMMEDIATE

( prefix str -- "prefix-str" )
: ++
  over count over count + 2 + heap-alloc dup String manage
  string-prefix-with
; 

: string-from-buffer string-new dup String manage dup gc-mark-collectable ; 