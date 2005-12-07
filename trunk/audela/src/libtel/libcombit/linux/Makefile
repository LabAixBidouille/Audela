
LIBTEL = 1

OUTPUT = libcombit.so

SRC  = $(LIBTELDIR)/util.c
SRC += $(SRCDIR)/combit.c

OBJ  = $(patsubst $(LIBTELDIR)/%.c, %.o, $(filter $(LIBTELDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

