: read-char-fd ( fd mem - c )
     dup >r 1 sys-read drop r> c@ ;

: read-line-fd ( fd addr - ) repeat
    2dup read-char-fd dup 10 = not over 13 = not land land if
           1 +  0
        else 0 swap c! drop  1 then
    until ;


256 KB constant max-file-size
max-file-size allot constant read-file-buffer
0 constant stdin
1 constant stdout
2 constant stderr

: file-read-text ( fd - a )
    read-file-buffer max-file-size sys-read .S
    read-file-buffer + 0 swap c!
    read-file-buffer string-from-buffer ;

: file-read-text-name ( name - a )
    file-open-read dup
    read-file-buffer max-file-size sys-read
    read-file-buffer + 0 swap c!
    file-close
    read-file-buffer string-from-buffer ;
