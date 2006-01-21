CC	= gcc
INC	= ../lib $(HOME)/templates
#CFLAGS	= -Wall -O2 $(patsubst %, -I%, $(INC))
CFLAGS	= -Wall -g $(patsubst %, -I%, $(INC))
LIBS	= fli
LIBPATH	= ../lib
LDLIBS	= $(patsubst %, -l%, $(LIBS))
LOADLIBES= $(patsubst %, -L%, $(LIBPATH))

filter: filter.c
	$(CC) $(CFLAGS) -o $@ $^ $(LOADLIBES) $(LDLIBS) -lm /usr/lib/libm.a

.PHONY: clean
clean:
	rm -f filter
