global forth-recurse-helper

: rec here cell% - forth-recurse-helper ! ; IMMEDIATE
: recurse forth-recurse-helper @ , ; IMMEDIATE
: recurse-addr ' lit , forth-recurse-helper @ , ; IMMEDIATE

