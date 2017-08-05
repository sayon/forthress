: O_RDONLY 0 ;
: PROT_READ 0x 1 ;

: PROT_WRITE  0x 2 ;

: MAP_PRIVATE 0x 2 ;
: MAP_ANONYMOUS 0x 20 ;

: sys-mmap-no 9 ;

( size - )
: sys-mmap >r sys-mmap-no 
0 r> 
PROT_READ PROT_WRITE or
MAP_PRIVATE MAP_ANONYMOUS or
0 0 syscall drop ;
