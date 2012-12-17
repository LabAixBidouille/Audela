LIBCAM = 1

OUTPUT = liboscadine.so

SRC = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))

include ../../../Makefile1

CFLAGS += -Wextra
LDFLAGS  += -L/home/damien/svn/audela/sources/audela/src/libcam/liboscadine/src/driver -lOscadineDriver
