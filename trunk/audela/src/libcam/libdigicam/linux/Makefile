
LIBCAM = 1

OUTPUT = libdigicam.so

SRC  = $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1


CXXFLAGS += -I $(EXTINC)
LDFLAGS += -L$(EXTLIB) -lgphoto2



