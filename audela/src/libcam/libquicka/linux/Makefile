
LIBCAM = 1

OUTPUT = libquicka.so

SRC  = $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1
CXXFLAGS += -I $(EXTINC) -I $(EXTINC)/linux -I $(SRCDIR)
#--- la librairie ftd2xx est dans le repertoire external/lib pour compiler
LDFLAGS += -L$(EXTLIB) -lftd2xx
