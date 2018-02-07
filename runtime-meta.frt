( What we want to do here is to create a system that allows us writing
  structures on steroids. They should have the following functionality:

- declaring fields
- implicitly creating a meta-information common chunk using ALLOT
- creating a 'tostring'-kind of method
- creating a word that accepts a word and applies it to each field address /used by GC /

' word set-printer typename

typename is an alias for its metainformation

adt lisp-expr 
   mconstructor lisp-number 
    int ::      
   mend 
   mconstructor  
endadt 
)


struct
  cell% field >meta-name
  cell% field >meta-printer
  cell% field >meta-is-value
  cell% field >meta-size
end-struct meta-entry%

: meta-default-print  chunk-header% - >chunk-meta @ >meta-name @ ." obj:"  prints ;
    
( : constant inbuf word drop 0 inbuf create ' docol @ , ' lit , , ' exit , ; )
: mtype inbuf word drop
        inbuf string-allot
        meta-entry% allot >r
          r@ >meta-name !
        0 r@ >meta-is-value !
        ( creating 'typename' word to return its metainformation address )
        0 inbuf create ' docol @ , ' lit , r@ , ' exit ,


        ' meta-default-print  r@ >meta-printer ! 
        r> 0
;

( parent-metainf offset field-metainf -- parent-metainf newoffset )
: :: 
    cell% allot !
( parent-metainf offset -- ) 
    inbuf word drop 
    dup 0 inbuf create ' docol @ , ' lit , , ' + ,  ' exit , 
    cell% + 
;

( metainf size - )
: mend swap >meta-size ! 0 cell% allot !  ; 

: meta-show
  ."  --- " cr
  dup ."   type name: " >meta-name     @ prints    cr
  dup ."   printer: "   >meta-printer  @ decompile cr
  dup ."   is value? "  >meta-is-value @ .         cr
  dup ."   size: "      >meta-size     @ dup if . ."  bytes" else ." UNK" drop then  cr
  ."   fields:" cr
  meta-entry% + 
  repeat
  dup @ dup if 
      >meta-name @ prints cr 
      cell% + 
      else drop 1 then 
  until 
  drop
  ."  --- " cr
;

( chunk-contents *metainf )
: meta-execute-printer >meta-printer @ execute  ; 
' meta-execute-printer heap-meta-printer ! 

( addr meta - )
: manage swap chunk-header% - >chunk-meta ! ;

( metainf - addr )
: new dup >meta-size @ heap-alloc  ( metainf addr  ) >r r@ swap manage r> ;

: delete heap-free ; 

( addr metainf - 0/1 )
: of-type 
    over addr-is-chunk-start if 
        swap chunk-header% - >chunk-meta @ =  
    else 2drop 0 
then ; 
 


mtype raw-cell mend 
cell% raw-cell >meta-size ! 


mtype int 
    raw-cell :: >value
mend 

: int-show ." int " >value @ . ; 
' int-show int >meta-printer ! 


( 
mtype spair 
    string :: >fst
    string :: >snd
mend 
)

