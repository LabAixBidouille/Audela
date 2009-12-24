
OUTPUT   = libaudelatk.so

SRC = $(SRCDIR)/libaudelatk.cpp  $(SRCDIR)/visu_tcl.cpp  $(SRCDIR)/cvisu.cpp 

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile.defs

CXXFLAGS += -I$(EXTINC) -I../../include

# Link 
# Remarque : ajout de l'option "-rpath ."
# L'option -rpath permet d'eviter l'utilisation deconseillee de la variable 
# LB_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquesl les librairies
# dynamiques libaudela.so sera recherche en priorite au runtime.

$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libaudela.so 
	$(LD) $(LDFLAGS) -Wl,-rpath,. -L $(OUTPUTDIR) -laudela -o $@ $(OBJ)
	$(CP) $@ $(OUTPUTDIR)
	@$(RM) libaudelatk.specs


$(OUTPUTDIR)/libaudela.so : 
	make -f ../../../Makefile1 $@




