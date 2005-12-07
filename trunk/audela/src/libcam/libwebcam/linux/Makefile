
LIBCAM = 1

OUTPUT = libwebcam.so

SRC  = $(LIBCAMDIR)/util.c $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

LDFLAGS += -lstdc++

