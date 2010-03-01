
LIBCAM = 1

OUTPUT = libsbig.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c ./bzero.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst ./%.c, %.o, $(filter ./%.c, $(SRC)))

# include Makefile1 initilise LDFLAGS 
# et doit etre place avant les modifications de LDFLAGS
include ../../../Makefile1

# L'option -rpath permet d'eviter l'utilisation deconseillee de la 
# variable LD_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquels les librairies
# dynamiques .so seront recherchees en priorite au runtime.

A_LIBS = $(EXTLIB)/libsbigudrv.1.4.43.so
LDFLAGS +=  -Wl,-rpath,. -L$(OUTPUTDIR) -lsbigudrv.1.4.43 -lm 

CXXFLAGS += -I $(EXTINC)
