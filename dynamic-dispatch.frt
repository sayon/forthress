256 allot constant dyn-buffer
256 allot constant dyn-name
global dyn-inside-def

: dyn-create-dispatch-cell
  " dispatch" dyn-name dyn-buffer string-prefix-with --new-global
;

: dyn-init-dispatch-cell
  last_word @ cfa ( Note the hardcoded 'last-word' here )
  " dispatch" dyn-name dyn-buffer string-prefix-with find cfa execute
  !
;

: dyn-create-dispatch-word
  0 dyn-name create ' docol @ ,
  " dispatch" dyn-name dyn-buffer string-prefix-with find cfa ,
  ' @ , ' execute , ' exit ,
;

: dyn-create-impl
  " impl" dyn-name dyn-buffer string-prefix-with
  0 swap create
  ' docol @ ,
;

: :dyn
  dyn-name word drop
  1 dyn-inside-def !
  dyn-create-dispatch-cell
  dyn-create-dispatch-word
  dyn-create-impl
  compilation-start
;

: ;
dyn-inside-def @ if
  dyn-init-dispatch-cell
  0 dyn-inside-def ! 
then
' ; execute
; IMMEDIATE

: :override
  dyn-name word drop
  dyn-create-impl
  1 dyn-inside-def !
  compilation-start
;