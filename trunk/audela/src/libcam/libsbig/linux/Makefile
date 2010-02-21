
LIBCAM = 1

OUTPUT = libsbig.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c ./bzero.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst ./%.c, %.o, $(filter ./%.c, $(SRC)))

A_LIBS = $(EXTLIB)/libsbigudrv.1.4.43.so
LDFLAGS += -L$(EXTLIB) -lsbigudrv.1.4.43.so -lm 

include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)
