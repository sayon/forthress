global forth-recurse-helper

: rec here cell% - forth-recurse-helper ! ; IMMEDIATE
: recurse forth-recurse-helper @ , ; IMMEDIATE

( : fact rec dup 1 = if  else dup 1 - recurse * then ; )
