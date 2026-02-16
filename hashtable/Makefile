
compile:
	gcc -g -O0 -c main.c
	gcc -g -O0 -c hashtable.s

link: compile
	gcc main.o hashtable.o -o exec

clean:
	rm -f *.o
	rm -f exec

all: clean compile link