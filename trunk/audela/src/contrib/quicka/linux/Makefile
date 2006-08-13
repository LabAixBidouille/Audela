
OUTPUT   = quicka.so

SRC = $(SRCDIR)/quicka.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

A_LIBS = $(OUTPUTDIR)/libftd2xx.so.0

include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)

