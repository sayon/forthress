# Forthress

## Summary

Forthress is a Forth dialect made for fun and educational purposes.
Forthress is written in NASM using bootstrap technique. It means that the main
interpreter/compiler loop (outer loop) is written in Forthress. The inner 
interpreter (see `next` in `src/forthress.asm`) is written in assembly, and so 
are some words.

Most of the language traits are fairy close to the classic Forth dialects.
Several things have to be mentioned about Forthress:

* It uses Indirect Threaded Code
* Strings are null-terminated
* XT stands for _execution token_, an address immediately following word header
* Word header has zero-bytes around the name. Here is the example for `dup`:

| link (8 bytes)     | zero (1) | name (variable) | zero (1) | flags (1) | implementation |
| ---                | ---      | ---             | ---      | ---       | ---            |
| 0x0000000000000000 | 0        | d u p           | 0        | 0         | dup_impl       |

Forthress was written as an exercise and an example of how one can 
create a working Forth interpreter which bootstraps itself.

Forthress is also created as an example for my course book ["Low-Level
Programming: C, Assembly, and Program Execution on Intel x86-64 Architecture"](http://www.apress.com/us/book/9781484224021).

## Predefined words

* `drop` ( a -- )
* `swap` ( a b -- b a )
* `dup` ( a -- a a )
* `rot` ( a b c -- b c a )
* Arithmetic:
  * `+` ( x y-- [ x + y ] )
  * `*` ( x y-- [ x * y ] )
  * `/` ( x y-- [ x / y ] )
  * `%` ( x y-- [ x mod y ] )
  * `-` ( x y-- [x - y] )
  * `<` ( x y-- [x < y] )
* Logic:
  * `not` ( a -- a' )
    a' = 0 if a != 0
    a' = 1 if a == 0
  * `=` ( a b -- c )
    c = 1 if a == b
    c = 0 if a != b
    
  * `land` ( a b --  a && b ) Logical and
  * `lor` ( a b --  a || b ) Logical or 
  
* Bitwise
  * `and` ( a b --  a & b ) Bitwise and
  * `or` ( a b --  a | b ) Bitwise or 

* `'` Read word, find its XT, place on stack (or zero if no such word).

Example:

```forth
' dup . ( will output dup's address ) 
```

colon "info", info


* `count` ( str -- len )
  Accepts a null-terminated string, calculates its length.
* `printc` ( str cnt -- ) 
Prints a certain amount of characters from string. 
* `.`
  Drops element from stack and sends it to stdout.
* `.S`
  Shows stack contents. Does not pop elements.
* `init` 
  Stores the data stack base. It is useful for `.S`.
* `docol`
  This is the implementation of any colon-word.
  The XT itself is not used, but the implementation (`i_docol`) is.
* `exit`
  Exit from colon word. 
* `r>`
  Push from return stack into data stack.
* `>r`
  Pop from data stack into return stack.
* `r@`
  Non-destructive copy from the top of return stack 
  to the top of data stack.

* `find` ( str -- header_addr )
  Accepts a pointer to a string, returns pointer to the word header in dictionary.
* `cfa` ( word_addr -- xt )
  Converts word header start address to the 
  execution token
* `emit` ( c -- )
  Outputs a single character to _stdout_
* `word` ( addr -- len ) 
  Reads word from stdin and stores it starting at address _addr_.
  Word length is pushed into stack
* `number`
  ( str -- len num ) 
  Parses an integer from string.
* `prints`
  ( addr -- ) 
  Prints a null-terminated string.
* `bye`
  Exits Forthress
* `syscall`
  ( call_num a1 a2 a3 a4 a5 a6 -- new_rax new_rdx)
  Executes syscall
  The following registers store arguments (according to ABI) 
  __rdi__ , __rsi__ , __rdx__ , __r10__ , __r8__ and __r9__
* `branch` Jump to a location. Location is **absolute**. That means that using
  it interactively is quasi-impossible; however, using it as a low-level
  primitive to implement `if` and similar constructs is much more convenient.

  Branch is a compile-only word. 

* `0branch`
  Jump to a location if TOS = 0. Location is calculated in a similar way.
  
  Branch0 is a compile-only word. 

* `lit`
  Pushes a value immediately following this XT.
* `inbuf`
  Address of the input buffer (is used by interpreter/compiler).
* `mem`
  Address of user memory.
* `last_word`
  Header of last word address.
* `state`, state
  State cell __address__.
  The state cell stores either 1 (compilation mode) or 0 (interpretation mode).
*  `here`
  Points to the last cell of the word currently being defined .
* `execute`
  ( xt -- )
  Execute word with this execution token on TOS.
* `@`
  ( addr -- value )
  Fetch value from memory.
* `!`
  ( val addr -- ) 
  Store value by address.
* `c!`
  ( char addr -- ) 
  Store one byte by address.
* `c@`
  ( addr -- char )
  Read one byte starting at addr.
* `,`
  ( x -- ) 
  Add x to the word being defined.
* `c,`
  ( c -- )
  Add a single byte to the word being defined.
* `create`
  ( flags name --  )
  Create an entry in the dictionary
  name is the new name.
  Only immediate flag is implemented ATM.
* `:`
  Read word from current input stream and start defining it.
* `;`" 
  End the current word definition
  
* `interpret` Forthress interpreter/compiler. Uses `in_fd` internally to know
  what to interpret.

* `interpret-fd`  (fd -- )
Interpret everything read from file descriptor `fd`.

### Extras

* `trap` default implementation of a word that will be executed on SIGSEGV.
* `trap_dispatch` selects the most recent `trap` version.

### Constants

* `dp` Address of a cell storing the end of global data segment. 
* `mem` Address of the start of global data segment. 
* `state` compile (1) or interpret (0)
* `here` Current position in current word. Used in compile mode by immediate words.
* `in_fd` The file descriptor from which we are currently reading words.

## Bootstrap

Forthress interpreter uses following words (in order of appearance):

```forth
dup
find
branch0 
cfa
state
fetch
lit
minus,
fetch_char
not
swap
drop
comma
exit
execute
number 
state
here
equals
prints
bye 
```

## Compatibility
Linux/LXSS only (it relies on system calls).
I don't think we should support more systems because this is an educational
project first, and multiple preprocessor directives will clutter it to death.

## Code overview
* `src/forthress.asm` defines the entry point, most important constants, inner interpreter,
memory regions etc.
* `src/macro.inc` is an utility file which stores macro definitions to sweeten the words definition. 
* `src/words.inc` is the assembly file containing all predefined words.
* `src/util.asm` is built into a separate static library containing input
  and output utility functions to read strings or numbers from _arbitrary descriptor_ and output them to _arbitrary descriptor_.
  Forthress is using Linux system calls directly to deal with I/O and does not
  rely on any library (such as `libc`).

