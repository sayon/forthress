# Forthress

## Description
A Forth dialect for educational purposes.
Forthress is written using bootstrap technique. It means, that the main
interpreter/compiler loop is written in Forthress. 



## Predefined words

* `drop` ( a -- )
* `swap` ( a b -- b a )
* `dup` ( a -- a a )
* `rot` ( a b c -- b c a )
* Arithmetic:
  * `+` ( y x -- [ x + y ] )
  * `*` ( y x -- [ x * y ] )
  * `/` ( y x -- [ x / y ] )
  * `%` ( y x -- [ x mod y ] )
  * `-` ( y x -- [x - y] )
  
* Logic:
  * not ( a -- a' )
    a' = 0 if a != 0
    a' = 1 if a == 0
  * = ( a b -- c )
    c = 1 if a == b
    c = 0 if a != b

* count ( str -- len )
  Accepts a null-terminated string, calculates its length
* .
  Drops element from stack and sends it to stdout
* .S
  Shows stack contents. Does not pop elements
* init
  Stores the data stack base. It is useful for .S
* docol
  This is the implementation of any colon-word.
  The XT itself is not used, but the implementation (`i_docol`) is.
* exit
  Exit from colon word
; Pop from data stack into return stack
>r
; Push from return stack into data stack
r>
; Non-destructive copy from the top of return stack 
; to the top of data stack
r@
colon "constant
; ( str -- header_addr )
find
; ( word_addr -- xt )
; Converts word header start address to the 
; execution token
cfa
; ( c -- )
; Outputs a single character to stdout
emit
; ( addr -- len ) 
; Reads word from stdin and stores it starting at address  
; Word length is pushed into stack
word
; ( str -- len num ) 
; Parses an integer from string
number
; ( addr -- ) 
; Prints a null-terminated string
prints
; Exits Forthress
bye
; ( call_num a1 a2 a3 a4 a5 a6 -- new_rax )
; Executes syscall
; The following registers store arguments (according to ABI) 
; rdi , rsi , rdx , r10 , r8 and r9 
syscall
; Jump to a location. Location is an offset relative to the argument end
; F.e.: |xt_branch|   24 | <next command> 
;                         ^ branch adds 24 to this address and stores it in PC
; Branch is a compile-only word. 
branch
; Jump to a location if TOS = 0. Location is calculated in a similar way
; F.e.: |xt_branch|   24 | <next command> 
;                         ^ branch adds 24 to this address and stores it in PC
; Branch0 is a compile-only word. 
0branch
; Pushes a value immediately following this XT
lit
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
execute
; ( addr -- value )
; Fetch value from memory
@
; ( val addr -- ) 
; Store value by address
!
; ( addr -- char )
; Read one byte starting at addr
@c
; ( x -- ) 
; Add x to the word being defined
,
; ( c -- )
; Add a single byte to the word being defined
c,
; ( name flags --  )
; Create an entry in the dictionary
; name is the new name 
; only immediate flag is implemented ATM 
create
; Read word from stdin and start defining it
colon ":
; End the current word definition
colon ";
; Forthress interpreter 
; Check the 'branch' and 'branch0' macros in 'macro.inc'
colon "interpreter
