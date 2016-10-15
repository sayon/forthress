# forthress
A Forth dialect implementation for educational purposes

; ( a -- )
native "drop", drop
; ( a b -- b a )
native "swap", swap
; ( a -- a a )
native "dup", dup
; ( a b c -- b c a )
native "rot", rot
; ( y x -- [ x + y ] )
native "+", plus
; ( y x -- [ x * y ] )
native "*", mul
; ( y x -- [ x / y ] )
native "/", div
; ( y x -- [ x mod y ] )
native "%", mod 
; ( y x -- [x - y] )
native "-", minus
; ( a -- a' )
; a' = 0 if a != 0
; a' = 1 if a == 0
native "not", not
; ( a b -- c )
; c = 1 if a == b
; c = 0 if a != b
native "=", equals
; ( str -- len )
native "count", count
; Drops element from stack and sends it to stdout
native ".", dot
; Shows stack contents. Does not pop elements
native ".S", show_stack
; Stores the data stack base. It is useful for .S
native "init", init
; This is the implementation of any colon-word.
; The XT itself is not used, but the implementation (i_docol) is.
native "docol", docol
; Exit from colon word
native "exit", exit
; Pop from data stack into return stack
native ">r", to_r
; Push from return stack into data stack
native "r>", from_r
; Non-destructive copy from the top of return stack 
; to the top of data stack
native "r@", r_fetch
colon "constant", constant
; ( str -- header_addr )
native "find", find
; ( word_addr -- xt )
; Converts word header start address to the 
; execution token
native "cfa", cfa
; ( c -- )
; Outputs a single character to stdout
native "emit", emit
; ( addr -- len ) 
; Reads word from stdin and stores it starting at address  
; Word length is pushed into stack
native "word", word
; ( str -- len num ) 
; Parses an integer from string
native "number", number 
; ( addr -- ) 
; Prints a null-terminated string
native "prints", prints 
; Exits Forthress
native "bye", bye
; ( call_num a1 a2 a3 a4 a5 a6 -- new_rax )
; Executes syscall
; The following registers store arguments (according to ABI) 
; rdi , rsi , rdx , r10 , r8 and r9 
native "syscall", syscall
; Jump to a location. Location is an offset relative to the argument end
; F.e.: |xt_branch|   24 | <next command> 
;                         ^ branch adds 24 to this address and stores it in PC
; Branch is a compile-only word. 
native "branch", branch
; Jump to a location if TOS = 0. Location is calculated in a similar way
; F.e.: |xt_branch|   24 | <next command> 
;                         ^ branch adds 24 to this address and stores it in PC
; Branch0 is a compile-only word. 
native "0branch", branch0
; Pushes a value immediately following this XT
native "lit", lit
; Address of the input buffer (is used by interpreter/compiler)
const inbuf, input_buf
; Address of user memory.  
const mem, user_mem 
; Last word address
const last_word, last_word 
; State cell address.
; The state cell stores either 1 (compilation mode) or 0 (interpretation mode)
const state, state
const here, [here]
; ( xt -- )
; Execute word with this execution token on TOS
native "execute", execute
; ( addr -- value )
; Fetch value from memory
native "@", fetch
; ( val addr -- ) 
; Store value by address
native "!", write
; ( addr -- char )
; Read one byte starting at addr
native "@c", fetch_char
; ( x -- ) 
; Add x to the word being defined
native ",", comma
; ( c -- )
; Add a single byte to the word being defined
native "c,", char_comma
; ( name flags --  )
; Create an entry in the dictionary
; name is the new name 
; only immediate flag is implemented ATM 
native "create", create
; Read word from stdin and start defining it
colon ":", colon
; End the current word definition
colon ";", semicolon, 1
; Forthress interpreter 
; Check the 'branch' and 'branch0' macros in 'macro.inc'
colon "interpreter", interpreter
