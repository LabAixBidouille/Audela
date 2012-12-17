LIBCAM = 1

OUTPUT = liboscadine.so

SRC = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))

include ../../../Makefile1

CFLAGS += -Wextra -I $(EXTINC)
CXXFLAGS += -I $(EXTINC)
LDFLAGS  += -L$(EXTLIB) -lOscadineDriver
