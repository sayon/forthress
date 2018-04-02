( This is the Fortress part of establishing an interface to C code 
 
The native primitive word is `ncall`. 
It accepts a lot of arguments: 

   function* rdi rsi rdx rcx r8 r9 rax xmm0 xmm1 xmm2 xmm3 xmm4 xmm5 xmm6 xmm7 

This allows us to use any number of arguments, also variable; the arguments 
might even be floating point numbers, although Fortress has no inherent support
for floating point arithmetics. 
)

( ." dlsym address: "  p_dlsym . cr)

g" Used to describe a function which accepts no arguments through XMM registers"
: native-no-xmm-arguments 0 0 0 0 0 0 0 0 ; with-doc

: result-in-rax drop drop drop ;

g" ( arg1 function* -- retval )

Call a native function with one ordinary argument (pointer or integer)."
: call1 swap 0 0 0 0 0 0 native-no-xmm-arguments ncall result-in-rax ; 
with-doc

g" ( arg1 arg2 function* -- retval )

Call a native function with two ordinary arguments (pointer or integer)."

: call2 -rot 0 0 0 0 0 native-no-xmm-arguments ncall result-in-rax ; 
with-doc

g" ( arg1 arg2 arg3 function* -- retval )"
: call3 
swap >r -rot r> 0 0 0 0 native-no-xmm-arguments ncall result-in-rax ;
 with-doc


: call4 
swap >r swap >r  -rot r> r>  0 0 0 native-no-xmm-arguments ncall result-in-rax ;

: call5
swap >r swap >r swap >r  -rot r> r> r> 0 0 native-no-xmm-arguments ncall result-in-rax ;

g" This flag is used by `dlopen`. One of these flags is mandatory: `RTLD_LAZY`
or `RTLD_NOW`"

1 constant RTLD_LAZY with-doc
 
g" This flag is used by `dlopen`. One of these flags is mandatory: `RTLD_LAZY`
or `RTLD_NOW`"

2 constant RTLD_NOW with-doc


g" ( handle symbol-name - symbol-address )"

: dlsym p_dlsym call2 ; 
with-doc

g" ( symbol-name - symbol-address)

Looks up a symbol with the given name. The corresponding shared object should
be loaded. 
"
: ** 0 swap dlsym ; 
with-doc

g" ( library-name - handle ) 

Shorthand to not pass RTLD_LAZY flag manually
"

: dlopen RTLD_LAZY " dlopen" **  call2 ; with-doc

( Some examples: )
: shell " system" ** call1 ; 
: ls  " ls" shell ; 
