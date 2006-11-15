
OUTPUT   = libaudelatk.so

SRC = $(SRCDIR)/libaudelatk.cpp  $(SRCDIR)/visu_tcl.cpp  $(SRCDIR)/cvisu.cpp 

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I$(EXTINC) -I../../include
A_LIBS = $(OUTPUTDIR)/libaudela.so 





