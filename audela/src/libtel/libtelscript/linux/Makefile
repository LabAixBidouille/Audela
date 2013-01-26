
LIBTEL = 1

OUTPUT = libtelscript.so $(OBJ) -lpthread

SRC  = $(LIBTELDIR)/util.cpp $(LIBTELDIR)/libtel.cpp
SRC += $(SRCDIR)/telescop.c $(SRCDIR)/teltcl.c

OBJ  = $(patsubst $(LIBTELDIR)/%.cpp, %.o, $(filter $(LIBTELDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

