# $Id$

LIBCAM = 1

OUTPUT = libqsi.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera_linux.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I$(EXTINC)
LDFLAGS += -L$(EXTLIB) -lqsiapi -lftd2xx -Wl,-rpath,$(EXTLIB)


