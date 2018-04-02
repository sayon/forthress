# ------------------------------------------------
# Forthress, a Forth dialect 
#
# Author: igorjirkov@gmail.com
# Date  : 02-04-2018
#
# ------------------------------------------------

ASM			= nasm
ASMFLAGS	= -felf64 -g -Isrc/ 


NATIVE_CALLS_SUPPORT=1

# This feature allows you to call functions from libc and other shared libraries.
# You get support for native calls by address and dlsym.
ifdef NATIVE_CALLS_SUPPORT
LINKERFLAGS = -nostdlib 
LIBS        = -ldl 
LINKER 		= gcc 
ASMFLAGS	+= -DNATIVE_CALLS
else
LINKER 		= ld
LINKERFLAGS = 
LIBS        = 
endif


all: bin/forthress
	
bin/forthress: obj/forthress.o obj/util.o
	mkdir -p bin 
	$(LINKER) -o bin/forthress  $(LINKERFLAGS) -o bin/forthress obj/forthress.o obj/util.o $(LIBS)

obj/forthress.o: src/forthress.asm src/macro.inc src/words.inc src/util.inc
	mkdir -p obj
	$(ASM) $(ASMFLAGS) src/forthress.asm -o obj/forthress.o

obj/util.o: src/util.inc src/util.asm
	mkdir -p obj
	$(ASM) $(ASMFLAGS) src/util.asm -o obj/util.o

clean: 
	rm -rf build obj

.PHONY: clean

