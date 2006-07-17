LIBLINK = 1

OUTPUT = libparallelport.so

SRC = $(LIBLINKDIR)/liblink.cpp $(SRCDIR)/cparallel.cpp $(SRCDIR)/parallel_tcl.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBLINKDIR)/%.cpp, %.o, $(filter $(LIBLINKDIR)/%.cpp, $(SRC)))



include ../../../Makefile1

