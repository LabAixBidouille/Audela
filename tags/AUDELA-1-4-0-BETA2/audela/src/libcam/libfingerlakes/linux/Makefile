
LIBCAM = 1

OUTPUT = libfingerlakes.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

A_LIBS = $(EXTLIB)/libfli.a

include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)
