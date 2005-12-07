
OUTPUT   = libaudela.so

SRC = $(SRCDIR)/buf_tcl.cpp $(SRCDIR)/cam_tcl.cpp $(SRCDIR)/cbuffer.cpp \
      $(SRCDIR)/cdevice.cpp $(SRCDIR)/cpool.cpp $(SRCDIR)/cvisu.cpp \
      $(SRCDIR)/fitskw.cpp $(SRCDIR)/history.cpp $(SRCDIR)/ping.cpp \
      $(SRCDIR)/libstd.cpp $(SRCDIR)/pool_tcl.cpp $(SRCDIR)/stats.cpp \
      $(SRCDIR)/tel_tcl.cpp $(SRCDIR)/tt.cpp $(SRCDIR)/visu_tcl.cpp \
      $(SRCDIR)/utils.cpp $(SRCDIR)/cerror.cpp $(SRCDIR)/cpixels.cpp \
      $(SRCDIR)/cpixelsgray.cpp $(SRCDIR)/cpixelsrgb.cpp

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
#OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1






