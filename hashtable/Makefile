
compile:
	gcc -g -O0 -c main.c
	gcc -g -O0 -c hashtable.s
	gcc -g -O0 -c helpers.s

link: compile
	gcc main.o hashtable.o helpers.o -o exec

clean:
	rm -f *.o
	rm -f exec

all: clean compile link