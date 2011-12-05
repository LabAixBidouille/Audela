
LIBTEL = 1

OUTPUT = liblxnet.so

LIBAUDINET = ../../../libcam/libaudinet/src

SRC  = $(LIBTELDIR)/util.cpp $(LIBTELDIR)/libtel.cpp
SRC += $(SRCDIR)/telescop.c $(SRCDIR)/teltcl.c 
SRC += $(LIBAUDINET)/socketaudinet.c  $(LIBAUDINET)/log.c $(LIBAUDINET)/setip.c

OBJ  = $(patsubst $(LIBTELDIR)/%.cpp, %.o, $(filter $(LIBTELDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBAUDINET)/%.c, %.o, $(filter $(LIBAUDINET)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I $(LIBAUDINET)

.PHONY=debug
debug:
	@echo "SRC=$(SRC)"
	@echo "OBJ=$(OBJ)"

%.o: $(LIBAUDINET)/%.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<

