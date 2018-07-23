' dup g" 
( a - a a )
Duplicate the cell on top of the stack.
" doc-word 

' drop g"
( a -- )
Drop the topmost element of the stack
" doc-word

' swap g" 
( a b -- b a )
Swap two topmost elements of the stack
" doc-word

' do g"
( a b -- )
`a b do ` launches a loop; at each iteration return stack contains limit and the
current index. Index goes from `b` inclusive to `a` exclusive.
" doc-word


' rot g" 
( a b c -- b c a )
Third element of the stack becomes the first
" doc-word

' + g" 
( x y -- [ x + y ] )
Add two topmost elements of the stack up
" doc-word

' * g" 
( x y -- [ x * y ] )
Multiply two topmost elements of the stack
" doc-word

' / g" 
( x y -- [ x / y ] )
Divide second element of the stack by the first
" doc-word

' % g" 
( x y -- [ x mod y ] )
Take the remainder of of division of the second element by the first
" doc-word

' - g" 
( x y -- [x - y] )
Deduct the first element from the second one
" doc-word

' < g" 
( x y -- [x < y] )
Compare two topmost elements of the stack, return 1 if true else return 0
" doc-word

' not g" 
( a -- a' ) a' = 0 if a != 0 a' = 1 if a == 0
Return 0 if the topmost element is not 0, else return 1
" doc-word

' = g" 
( a b -- c ) c = 1 if a == b c = 0 if a != b
Compare two topmost elements, return 1 if they are equal, else return 0
" doc-word

' land g" 
( a b -- a && b ) Logical and
If a != 0 and b != 0 return a, else return 0
" doc-word

' lor g" 
( a b -- a || b ) Logical or
If a != 0 or b != 0 return any non-zero element of these two, else return 0
" doc-word

' cfa g"
( word_addr -- xt )
Get the execution token of the word from its header start
" doc-word

' find g"
( str -- header_addr )
Accept a pointer to a string containing word's name and return its header address
" doc-word

' r@ g"
Copy the topmost element of the return stack and push it to data stack. Don't change return stack
" doc-word

' r> g"
Pop element from return stack and pop it to data stack. Use only in compilation mode.
" doc-word

' >r g"
Pop element from data stack and pop it to return stack. Use only in compilation mode.
" doc-word

' exit g"
Exit from colon word. Restore pc value and go to the next word
" doc-word

' init g"
Initialize Forth machine
" doc-word

' .S g"
Show stack contents. Doesn't change stack
" doc-word

' . g"
Drop element from stack and print it
" doc-word

' or g"
( a b -- a | b )
Accept two arguments and return result of their bitwise or
" doc-word

' and g" 
( a b -- a & b )
Accept two arguments and return result of their bitwise and
" doc-word


