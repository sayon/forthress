; ------------------------------------------------
; Forthress, a Forth dialect
;
; This file is storing the predefined words
; Check README.md in the root directory for
; word semantics
;
; Author: igorjirkov@gmail.com
; Date  : 26-02-2016
;
; ------------------------------------------------


; Read word and place its address on stack
; ( -- a )
colon "'", tick, 1
	dq xt_inbuf
	dq xt_word
	dq xt_drop
	dq xt_inbuf
	dq xt_find, xt_dup
    branch0 .no_such_word
	dq xt_cfa
    dq xt_state, xt_fetch
    branch0 .interpret
    dq xt_lit, xt_lit
    dq xt_comma
    dq xt_comma
.interpret:
	dq xt_exit
    .no_such_word:
    dq xt_inbuf, xt_prints
    dq xt_lit, msg_no_such_word, xt_prints
    dq xt_exit

; Drop TOS
; ( a -- )
native "drop", drop
    add rsp, 8
    jmp next

; Swap two cells on top of the stack
; ( a b -- b a )
native "swap", swap
    pop rax
    pop rdx
    push rax
    push rdx
    jmp next

; Duplicate cell on top of the stack
; ( a -- a a )
native "dup", dup
    push qword [rsp]
    jmp next

; ( y x -- [ x + y ] )
native "+", plus
    pop rax
    add [rsp], rax
    jmp next

; ( y x -- [ x * y ] )
native "*", mul
    pop rax
    pop rdx
    imul rdx
    push rax
    jmp next

; ( y x -- [ x / y ] )
native "/", div
    pop rcx
    pop rax
    cqo
    idiv rcx
    push rax
    jmp next

; ( y x -- [ x mod y ] )
native "%", mod
    pop rcx
    pop rax
    cqo
    idiv rcx
    push rdx
    jmp next

; ( y x -- [x - y] )
native "-", minus
    pop rax
    sub [rsp], rax
    jmp next

; ( a -- a' )
; a' = 0 if a != 0
; a' = 1 if a == 0
native "not", not
    pop rax
    test rax, rax
    setz al
    movzx rax, al
    push rax
    jmp next

; ( a b -- c )
; c = 1 if a == b
; c = 0 if a != b
native "=", equals
    pop rax
    pop rdx
    cmp rax, rdx
    sete al
    movzx rax, al
    push rax
    jmp next

; ( y x -- [x < y] )
native "<", lt
    pop rdx
    pop rax
    cmp rax, rdx
    setl al
    movzx rax, al
    push rax
    jmp next

; bitwise and
; ( y x -- y & x )
native "and", and
    pop rax
    and [rsp], rax
    jmp next

; bitwise or
; ( y x -- y | x )
native "or", or
    pop rax
    or [rsp], rax
    jmp next

; logic and
native "land", land
    pop rax
    pop rdx
    test rax, rax
    jz .no
    push rdx
    jmp next
.no:
    push rax
    jmp next

; logic or
native "lor", lor
    pop rax
    pop rdx
    test rax, rax
    jnz .yes
    push rdx
    jmp next
.yes:
    push rax
    jmp next

; Drops element from stack and sends it to stdout
; ( a -- )
native ".", dot
    pop rdi
    call print_int
    jmp next

; Shows all stack contents. Does not pop elements
native ".S", show_stack
    mov rcx, rsp
    .loop:
        cmp rcx, [stack_base]
        jae next
        mov rdi, [rcx]
        push rcx
        call print_int
        call print_newline
        pop rcx
        add rcx, 8
        jmp .loop

; Stores the data stack base. It is useful for .S
section .data
    stack_base: dq 0

; Initialization routine.
native "init", init
    call setup_trap
    mov qword [state], 0
    mov rstack, rstack_start
    mov pc, interpreter_stub
    cmp qword [stack_base], 0
    je  .first
    mov rsp, [stack_base]
    jmp next
    .first:
    mov [stack_base], rsp
    jmp next


native "exit", exit
    rpop pc
    jmp next

native ">r", to_r
    pop rax
    rpush rax
    jmp next

native "r>", from_r
    rpop rax
    push rax
    jmp next

native "r@", r_fetch
    push qword [rstack]
    jmp next

; ( str -- header_addr )
native "find", find
    mov rsi, [last_word]

    ; if compiling, we have to skip the word being defined
    mov rax, [state]
    test rax, rax
    jz .loop
    mov rsi, [rsi]
.loop:
    mov rdi, [rsp]
    push rsi
    add rsi, 9
    call string_equals
    pop rsi
    test rax, rax
    jnz .found

    mov rsi, [rsi]
    test rsi, rsi
    jnz .loop
.not_found:
    mov qword [rsp], 0
    jmp next
.found:
    mov [rsp], rsi
    jmp next

; ( word_addr -- xt )
; Converts word header start address to the
; execution token
native "cfa", cfa
    pop rsi
    add rsi, 9
    .loop:
    mov al, [rsi]
    test al, al
    jz .end
    inc rsi
    jmp .loop

    .end:
    add rsi, 2
    push rsi
    jmp next


; ( c -- )
; Outputs a single character to stdout
native "emit", emit
    pop rdi
    call print_char
    jmp next

; ( addr -- len )
; Reads word from stdin and stores it starting at address
; Word length is pushed into stack
native "word", word
    pop rdi
    call read_word
    push rdx
    jmp next

; ( str -- len num )
; Parses an integer from string
native "number", number
    pop rdi
    call parse_int
    push rax
    push rdx
    jmp next

; null-terminated string length
colon "count", count
     dq xt_dup
 .loop:
     dq xt_dup
     dq xt_fetch_char
     branch0 .exit
     dq xt_lit, 1, xt_plus
     branch .loop
 .exit:
     dq xt_swap, xt_minus, xt_exit


; prints a certain amount of symbols from string
; ( str cnt -- )
colon "printc", printc
    dq xt_to_r
.loop:
    dq xt_r_fetch
    branch0 .exit
    dq xt_dup, xt_fetch_char, xt_emit
    dq xt_lit, 1, xt_plus
    dq xt_from_r, xt_lit, 1, xt_minus, xt_to_r
    branch .loop

    .exit:
    dq xt_from_r, xt_drop, xt_drop, xt_exit


; ( addr len -- )
; Prints a null-terminated string
colon "prints", prints
     dq xt_dup, xt_count, xt_printc, xt_exit

; Exits Forthress
colon "bye", bye
   dq xt_lit, 60
   dq xt_lit, 0
   dq xt_lit, 0
   dq xt_lit, 0
   dq xt_lit, 0
   dq xt_lit, 0
   dq xt_lit, 0
   dq xt_syscall


; Only used to construct words. Implements colon-words
native "docol", docol
    rpush pc
    add w, 8
    mov pc, w
    jmp next

; It is being called when SIGSEGV occurs
_trap:
    push qword [stack_base]
    push rdx
    mov rax, xt_trap_dispatch
    mov w, rax
    jmp [rax]

colon "trap_dispatch", trap_dispatch
    dq xt_lit, trapword
    dq xt_find, xt_cfa, xt_execute
    dq xt_bye

colon "trap", trap
    dq xt_lit, trapword
    dq xt_prints, xt_lit, 10, xt_emit
    dq xt_exit


; ( call_num a1 a2 a3 a4 a5 a6 -- new_rax new_rdx )
; Executes syscall
; The following registers store arguments (according to ABI)
; rdi , rsi , rdx , r10 , r8 and r9
native "syscall", syscall
    pop r9
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi
    pop rax
    syscall
    push rax
    push rdx
    jmp next

%ifdef NATIVE_CALLS

extern dlsym
native "p_dlsym", p_dlsym
    push dlsym
    jmp next


; Experimental feature: native call
; The stack should hold these values, in this order
; ( function* rdi rsi rdx rcx r8 r9 rax xmm0 xmm1 xmm2 xmm3 xmm4 xmm5 xmm6 xmm7 )
; After that, the stack will hold these values:
; ( rax rdx xmm0 xmm1 )
; This way you can call everything even functions with variable arguments count.
; Notice, that you can pass additional integer/pointer arguments on stack, as
; Forthress data stack corresponds to the hardware stack!
native "ncall", ncall
    pop rax, 
    movq xmm7, rax
    pop rax 
    movq xmm6, rax
    pop rax 
    movq xmm5, rax
    pop rax 
    movq xmm4, rax
    pop rax 
    movq xmm3, rax
    pop rax 
    movq xmm2, rax
    pop rax
    movq xmm1, rax
    pop rax
    movq xmm0, rax
    pop rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    add rsp, 8
    call [rsp-8]
    push rax
    push rdx
    movq rcx, xmm0
    push rcx 
    movq rcx, xmm1 
    push rcx 
    jmp next

%endif

; Jump to a location. Location is an absolute address
; Branch is a compile-only word.
native "branch", branch
    mov pc, [pc]
    jmp next

; Jump to a location if TOS = 0. Location is calculated in a similar way
; 0branch is a compile-only word.
native "0branch", branch0
    pop rax
    test rax, rax
    jnz .skip
    mov pc, [pc]
    jmp next
    .skip:
    add pc, 8
    jmp next

; Pushes a value immediately following this XT
native "lit", lit
    push qword [pc]
    add pc, 8
    jmp next

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
const in_fd, in_fd
const dp, dp

; ( xt -- )
; Execute word with this execution token on TOS
native "execute", execute
    pop rax
    mov w, rax
    jmp [rax]


; ( addr -- value )
; Fetch value from memory
native "@", fetch
    pop rax
    push qword[rax]
    jmp next

; ( val addr -- )
; Store value by address
native "!", write
    pop rax
    pop rdx
    mov [rax], rdx
    jmp next

; ( val addr -- )
; Store value by address
native "c!", write_char
    pop rax
    pop rdx
    mov [rax], dl
    jmp next

; ( addr -- char )
; Read one byte starting at addr
native "c@", fetch_char
    pop rax
    movzx rax, byte [rax]
    push rax
    jmp next

; ( x -- )
; Add x to the word being defined
native ",", comma
    mov rax, [here]
    pop qword [rax]
    add qword [here], 8
    jmp next

; ( c -- )
; Add a single byte to the word being defined
native "c,", char_comma
    mov rax, [here]
    pop rdx
    mov [rax], dl
    add qword[here], 1
    jmp next


; ( flags name --  )
; Create an entry in the dictionary
; name is the new name as a null-terminated string
; only immediate flag is implemented ATM
native "create", create
    ; link
    mov rcx, [last_word]
    mov rsi, [here]
    mov [rsi], rcx
    mov [last_word], rsi
    add rsi, 8
    mov byte [rsi], 0
    inc rsi

    ; name
    pop rdi
    push rsi
    call string_copy
    pop rsi
    push rsi
    mov rdi, rsi
    call string_length
    pop rsi
    add rsi, rax
    ; flags
    inc rsi
    pop rax
    mov [rsi], al
    inc rsi

    mov [here], rsi
    jmp next

; Read word from stdin and start defining it
colon ":", colon
    .restart:
    dq xt_inbuf, xt_word
    branch0 .restart
    dq xt_lit, 0, xt_inbuf, xt_create
    dq xt_lit, 1, xt_state, xt_write
    dq xt_lit, i_docol, xt_comma
    dq xt_exit

; End the current word definition
colon ";", semicolon, 1
    dq xt_lit, 0, xt_state, xt_write
    dq xt_lit, xt_exit, xt_comma
    dq xt_exit

section .rodata
interpreter_stub:
    dq xt_lit, 0    ; stdin
    dq xt_interpret_fd
    dq xt_bye

; reads words from an open fd and interprets them
; (  fd -- )
colon "interpret-fd", interpret_fd
    dq xt_lit, in_fd, xt_fetch, xt_to_r
    dq xt_lit, in_fd
    dq xt_write
    .loop:
    dq xt_inbuf, xt_word
    branch0 .end_of_input

    dq xt_inbuf
    dq xt_interpret

    branch .loop

    .end_of_input:
    dq xt_from_r
    dq xt_lit, in_fd, xt_write
    dq xt_exit


; Forthress interpreter
; Check the 'branch' and 'branch0' macros in 'macro.inc'
colon "interpret", interpret
.start:
    ; ( inbuf )
    dq xt_dup, xt_find       ; find in dict

    ; ( inbuf dictaddr )
    dq xt_dup
    branch0 .number  ; if not found, try to parse as a number
    dq xt_cfa

    ; ( inbuf xt )

    ; if compile
    dq xt_state, xt_fetch
    branch0 .interpreting

    ; if is immediate:
    dq xt_dup
    dq xt_lit, 1, xt_minus, xt_fetch_char, xt_not
    branch0 .interpreting

    ; compile ( inbuf xt )
    dq xt_swap, xt_drop
    dq xt_comma
    dq xt_exit

    .interpreting: ; ( inbuf xt )
    dq xt_swap, xt_drop
    dq xt_execute
    dq xt_exit

    .number: ; ( inbuf dictaddr )
    dq xt_drop, xt_dup
    dq xt_number ; ( inbuf num 0/1 )
    branch0 .no_word

   ; ( inbuf num )
    dq xt_swap, xt_drop
    dq xt_state, xt_fetch  ; if interpreting, that's it
    branch0 .exit
                           ; when compiling, check if it was after a branch
   ; ( num )
    dq xt_here, xt_lit, 8, xt_minus, xt_fetch

   ; ( num prev_xt )
    dq xt_dup
    dq xt_lit, xt_branch0
    dq xt_equals, xt_not
    branch0 .is_branch

    dq xt_dup
    dq xt_lit, xt_branch
    dq xt_equals, xt_not
    branch0 .is_branch

    dq xt_lit, xt_lit, xt_comma

.is_branch: ; ( num prev_xt )
    dq xt_drop
    dq xt_comma
    dq xt_exit

.no_word: ; ( inbuf num )
    dq xt_drop
    dq xt_prints
    dq xt_lit, msg_no_such_word, xt_prints
.exit:
    dq xt_exit
