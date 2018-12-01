CC=cc
CFLAGS=-I.
DEPS = nnlib.h

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

forwardPass: forwardPass.o nnlib.o
	$(CC) -o forwardPass forwardPass.o nnlib.o

clean:
	rm *.o
