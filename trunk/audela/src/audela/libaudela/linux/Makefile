
OUTPUT   = libaudela.so

SRC = $(SRCDIR)/psfimcce_nr.cpp $(SRCDIR)/psfimcce_funcs.cpp $(SRCDIR)/psfimcce.cpp \
      $(SRCDIR)/buf_tcl.cpp $(SRCDIR)/cam_tcl.cpp $(SRCDIR)/cbuffer.cpp \
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
	$(LD) $(OBJ) $(LDFLAGS) -Wl,-rpath,. -L$(OUTPUTDIR) -ldcraw -ldcjpeg -lpthread -o $@
	$(CP) $@ $(OUTPUTDIR)
	mkdir -p  ../../include
	cp -f ../src/cpool.h   ../../include
	cp -f ../src/cdevice.h  ../../include
	cp -f ../src/cerror.h  ../../include
	cp -f ../src/palette.h  ../../include
	cp -f ../src/cbuffer.h  ../../include
	cp -f ../src/cpixels.h  ../../include
	cp -f ../src/cpixelsgray.h  ../../include
	cp -f ../src/cpixelsrgb.h  ../../include
	cp -f ../src/fitskw.h   ../../include
	cp -f ../src/cfile.h   ../../include
	cp -f ../src/libtt.h   ../../include
	cp -f ../src/libstd.h   ../../include
	cp -f ../src/psfimcce.h   ../../include

all: $(OUTPUT)

libdcraw.so : $(OBJ) $(A_LIBS)
	@echo "*** Linking library $@"
	$(LD) $^ $(LDFLAGS) -o $@ 
	$(CP) $@ $(OUTPUTDIR)

libdcjpeg.so : $(OBJ) $(A_LIBS)
	@echo "*** Linking library $@"
	$(LD) $^ $(LDFLAGS) -o $@ 
	$(CP) $@ $(OUTPUTDIR)
	
%.o: $(SRCDIR)/%.cpp
	@echo "*** Compiling $<"
	$(CXX) $(CXXFLAGS) -o $@ $<

%.o: $(SRCDIR)/%.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<

%.o: %.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<

.PHONY: clean cleanall
clean:
	$(RM) $(OBJ) $(OUTPUT)
cleanall: clean
	$(RM) makedep *~ *.bak *.BAK *.swp 

.PHONY: indent
indent:
	indent $(SRCDIR)/*.[ch] -kr -line-length1000 --ignore-newlines

.PHONY: local-clean src-clean vc60-clean distclean
vc60-clean:
	-$(RM) -rf ../vc60/Debug ../vc60/Release 
	-$(RM) ../vc60/*.mak ../vc60/*.ncb ../vc60/*.opt ../vc60/*.plg 
	-$(RM) ../vc60/*~ ../vc60/*.bak 
local-clean:
	-$(RM) *~ *.bak makedep
src-clean:
	-$(RM) $(SRCDIR)/*~ $(SRCDIR)/*.bak 
distclean: local-clean src-clean vc60-clean clean
