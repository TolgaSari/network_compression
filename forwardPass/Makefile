CC=clang
CFLAGS=-I.
DEPS = nnlib.h

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

forwardPass: forwardPass.o nnlib.o
	$(CC) -o forwardPass forwardPass.o nnlib.o
	make clean

debug: forwardPass.o nnlib.o
	$(CC) -g forwardPass.o nnlib.o -o debug
	make clean 

.PHONY: clean

clean:
	rm *.o
