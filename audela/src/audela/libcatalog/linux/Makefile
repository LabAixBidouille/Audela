
OUTPUT   = libcatalog.so

SRC = $(SRCDIR)/libcatalog.cpp $(SRCDIR)/cstycho.cpp $(SRCDIR)/csucac2.cpp $(SRCDIR)/csucac3.cpp $(SRCDIR)/csusnoa2.cpp
SRC += $(SRCDIR)/useful.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

#CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
##LDFLAGS  += $(AUD_GSL_LIBS)

