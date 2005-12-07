
OUTPUT   = libbm.so

SRC = $(SRCDIR)/libbm.cpp $(SRCDIR)/bm_c_tcl.cpp $(SRCDIR)/bm_trt-img.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS)
