
OUTPUT   = libaudela.so ../../include/cpool.h

SRC = $(SRCDIR)/buf_tcl.cpp $(SRCDIR)/cam_tcl.cpp $(SRCDIR)/cbuffer.cpp \
      $(SRCDIR)/cdevice.cpp $(SRCDIR)/cpool.cpp  \
      $(SRCDIR)/fitskw.cpp $(SRCDIR)/history.cpp $(SRCDIR)/ping.cpp \
      $(SRCDIR)/libstd.cpp $(SRCDIR)/pool_tcl.cpp $(SRCDIR)/stats.cpp \
      $(SRCDIR)/tel_tcl.cpp $(SRCDIR)/tt.cpp $(SRCDIR)/cfile.cpp\
      $(SRCDIR)/utils.cpp $(SRCDIR)/cerror.cpp $(SRCDIR)/cpixels.cpp \
      $(SRCDIR)/cpixelsgray.cpp $(SRCDIR)/cpixelsrgb.cpp $(SRCDIR)/link_tcl.cpp \
      $(SRCDIR)/file_tcl.cpp

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
A_LIBS = $(OUTPUTDIR)/libdcraw.so $(OUTPUTDIR)/libdcjpeg.so

include ../../../Makefile1

CXXFLAGS += -I$(EXTINC)

../../include/cpool.h: ../src/cpool.h 
	mkdir -p  ../../include
	cp -f ../src/cpool.h   ../../include
	cp -f ../src/cdevice.h  ../../include
	cp -f ../src/cerror.h  ../../include
	cp -f ../src/palette.h  ../../include
	cp -f ../src/cdevice.h  ../../include
	cp -f ../src/cbuffer.h  ../../include
	cp -f ../src/cpixels.h  ../../include
	cp -f ../src/fitskw.h   ../../include
	



