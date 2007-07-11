
OUTPUT   = libaudelatk.so

SRC = $(SRCDIR)/libaudelatk.cpp  $(SRCDIR)/visu_tcl.cpp  $(SRCDIR)/cvisu.cpp 

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I$(EXTINC) -I../../include

# Link 
# Remarque : ajout de l'option "-rpath ."
# L'option -rpath permet d'eviter l'utilisation deconseillee de la variable 
# LB_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquesl les librairies
# dynamiques libaudela.so sera recherche en priorite au runtime.
# L'option -rpath ne peut pas etre passee directement en parametre sur la ligne de 
# commande de gcc. Elle doit etre enregistree dans un fichier qui est passe en 
# parametre a gcc avec l'option -specs

$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libaudela.so 
	@echo "*lib:" > libaudelatk.specs
	@echo "    -rpath ." >> libaudelatk.specs
	$(LD) $(LDFLAGS) -specs libaudelatk.specs -L $(OUTPUTDIR) -laudela -o $@ $(OBJ)
	$(CP) $@ $(OUTPUTDIR)
	@$(RM) libaudelatk.specs






