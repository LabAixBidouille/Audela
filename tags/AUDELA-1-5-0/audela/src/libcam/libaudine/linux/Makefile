
LIBCAM = 1

OUTPUT = libaudine.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c $(SRCDIR)/tp.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1
