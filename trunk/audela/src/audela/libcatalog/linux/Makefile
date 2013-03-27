
OUTPUT   = libcatalog.so

SRC  = $(SRCDIR)/libcatalog.c $(SRCDIR)/useful.c $(SRCDIR)/cstycho.c $(SRCDIR)/csusnoa2.c 
SRC += $(SRCDIR)/csucac2.c $(SRCDIR)/csucac3.c $(SRCDIR)/csucac4.c $(SRCDIR)/cs2mass.c
SRC += $(SRCDIR)/ppmx.c $(SRCDIR)/ppmxl.c $(SRCDIR)/nomad1.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

#CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
##LDFLAGS  += $(AUD_GSL_LIBS)

