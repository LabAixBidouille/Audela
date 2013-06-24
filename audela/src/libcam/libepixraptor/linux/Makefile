LIBCAM = 1

OUTPUT = libepixraptor.so

SRC = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c
SRC += $(SRCDIR)/raptor.c $(SRCDIR)/serial.c

OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -Wextra -I $(EXTINC)/epix
LDFLAGS  += -L$(EXTLIB) -lkxclib_x86_64

