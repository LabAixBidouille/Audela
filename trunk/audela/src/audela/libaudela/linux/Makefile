
OUTPUT   = libaudela.so

SRC = $(SRCDIR)/buf_tcl.cpp $(SRCDIR)/cam_tcl.cpp $(SRCDIR)/cbuffer.cpp \
      $(SRCDIR)/cdevice.cpp $(SRCDIR)/cpool.cpp  $(SRCDIR)/setip.cpp \
      $(SRCDIR)/fitskw.cpp $(SRCDIR)/history.cpp $(SRCDIR)/ping.cpp \
      $(SRCDIR)/libstd.cpp $(SRCDIR)/pool_tcl.cpp $(SRCDIR)/stats.cpp \
      $(SRCDIR)/tel_tcl.cpp $(SRCDIR)/tt.cpp $(SRCDIR)/cfile.cpp\
      $(SRCDIR)/utils.cpp $(SRCDIR)/cerror.cpp $(SRCDIR)/cpixels.cpp \
      $(SRCDIR)/cpixelsgray.cpp $(SRCDIR)/cpixelsrgb.cpp $(SRCDIR)/link_tcl.cpp \
      $(SRCDIR)/file_tcl.cpp

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile.defs

CXXFLAGS += -I$(EXTINC) -Wno-deprecated

# Remarque : ajout de l'option "-rpath ."
# L'option -rpath permet d'eviter l'utilisation deconseillee de la variable
# LD_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquels les librairies
# dynamiques libdcraw.so et libdcjpeg.so seront recherchees en priorite au runtime.


$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libdcraw.so $(OUTPUTDIR)/libdcjpeg.so
	$(LD) $(LDFLAGS) -Wl,-rpath,. -L$(OUTPUTDIR) -ldcraw -ldcjpeg -o $@ $(OBJ) -lpthread
	$(CP) $@ $(OUTPUTDIR)
	mkdir -p  ../../include
	cp -f ../src/cpool.h   ../../include
	cp -f ../src/cdevice.h  ../../include
	cp -f ../src/cerror.h  ../../include
	cp -f ../src/palette.h  ../../include
	cp -f ../src/cdevice.h  ../../include
	cp -f ../src/cbuffer.h  ../../include
	cp -f ../src/cpixels.h  ../../include
	cp -f ../src/fitskw.h   ../../include


$(OUTPUTDIR)/libdcraw.so : 
	make -f ../../../Makefile1 $@

$(OUTPUTDIR)/libdcjpeg.so : 
	make -f ../../../Makefile1 $@
