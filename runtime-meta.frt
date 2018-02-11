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
  cell% field >meta-collected
  cell% field >meta-is-value
  cell% field >meta-size
end-struct meta-entry%

: meta-default-print  chunk-header% - >chunk-meta @ >meta-name @ ." obj:"  prints ;
    
( : constant inbuf word drop 0 inbuf create ' docol @ , ' lit , , ' exit , ; )
: mtype inbuf word drop
        inbuf string-allot
        meta-entry% allot >r
          r@ >meta-name !
        0 r@ >meta-collected !
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

( fixme: raw cell is not printing correctly )
: meta-show
  ."  --- " cr
  dup ."   type name: " >meta-name     @ prints    cr
  dup ."   printer: "   >meta-printer  @ ? cr
  ( dup ."   is value? "  >meta-is-value @ .         cr )
  dup ."   size: "      >meta-size     @ dup if . ."  bytes" else ." UNK" drop then  cr
  ."   fields:" cr
  dup >meta-size @ cell% / 
  swap meta-entry% + swap dup if 0
    ( fields-count 0 -- )
      do  
     dup @ >meta-name @ prints cr cell% + 
      loop
then 
drop 
  ."  --- " cr
;

( chunk-contents *metainf )
: meta-execute-printer >meta-printer @ execute  ; 
' meta-execute-printer heap-meta-printer ! 

( addr meta - )
: manage swap chunk-header% - >chunk-meta ! ;

( metainf - addr )
: meta-alloc dup >meta-size @ heap-alloc  ( metainf addr  ) >r r@ swap manage r> ;


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
1 int >meta-is-value !

: int-show ." int " >value @ . ; 
' int-show int >meta-printer ! 

( value )
( : new-int int _new >r r@ ! r> ; )

: meta-fields-count >meta-size @ cell% / ; 

( fieldN ... field2 field1 meta -- addr )
: new 
    dup meta-alloc dup >r swap 
    ( fieldN ... field2 field1 addr count )
     meta-fields-count 0 do
    2dup ! 
    swap drop
    cell% +  
      loop 
    drop r>  
;

: addr-is-managed dup addr-is-chunk-start if
        chunk-header% - >chunk-meta @ 0 <>  
    else drop 0 then ;


( addr -- meta )
: addr-get-meta dup addr-is-managed if chunk-header% - >chunk-meta @ else drop 0 then ;


: delete rec 
    dup addr-get-meta dup if ( addr meta )
        dup >meta-is-value @ not if
             >meta-size @  over + over ( addr limit curaddr ) 
             repeat 
                2dup = if 2drop 1 else 
                    dup @ recurse    
                    cell% + 0
               then 
             until  
             heap-free
    else  drop
    heap-free then 
    else drop heap-free then ;

( addr -- )
: .  
    dup addr-get-meta dup if ( addr meta )
         over . ."    " >meta-printer @  ."   [" execute    ." ]" 
    else drop . then 
;


