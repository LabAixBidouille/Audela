
LIBCAM = 1

OUTPUT = libsbig.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c ./bzero.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst ./%.c, %.o, $(filter ./%.c, $(SRC)))

A_LIBS = $(EXTLIB)/udrv4.0.a

include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)
