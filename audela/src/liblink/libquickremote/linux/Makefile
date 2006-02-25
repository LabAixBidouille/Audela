LIBLINK = 1

OUTPUT = libquickremote.so

SRC = $(LIBLINKDIR)/liblink.cpp $(SRCDIR)/cquickremote.cpp $(SRCDIR)/quickremote_tcl.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBLINKDIR)/%.cpp, %.o, $(filter $(LIBLINKDIR)/%.cpp, $(SRC)))



include ../../../Makefile1
CXXFLAGS += -I $(EXTINC) -I $(SRCDIR)
LDFLAGS += -lftd2xx