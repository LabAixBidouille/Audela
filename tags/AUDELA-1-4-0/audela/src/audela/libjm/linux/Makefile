
OUTPUT   = libjm.so

SRC = $(SRCDIR)/jm_c_tcl.c $(SRCDIR)/jm_temps.c $(SRCDIR)/libjm.c  \
      $(SRCDIR)/jm_util.c $(SRCDIR)/jm_photo.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS)
