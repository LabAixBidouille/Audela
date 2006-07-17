#CXX = gcc
#LD = gcc
#CP = cp
#RM = rm -f -v

OUTPUT = libsext.so

#COMMON    = ../../common
#SRCDIR    = ../src
#OUTPUTDIR = ../../../binlinux

#CXXFLAGS = -c -fPIC -Wall -O2  -I $(COMMON) -DUSE_TCL_STUBS -DUSE_TK_STUBS -DUSE_COMPAT_CONST
#LDFLAGS  = -shared -ltclstub8.4 -ltkstub8.4 -ldl -lm

SRC = $(SRCDIR)/libsext.c   $(SRCDIR)/sexttcl_1.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

#all: $(OUTPUT)

#$(OUTPUT): $(OBJ)
#	@echo "*** Linking library $@"
#	$(LD) $(LDFLAGS) -o $@ $^
#	$(CP) $@ $(OUTPUTDIR)

#%.o: $(SRCDIR)/%.c
#	@echo "*** Compilation de $<"
#	$(CXX) $(CXXFLAGS) -o $@ $<

#depend: makedep
#makedep:
#	@echo "*** Building dependencies file"
#	$(CXX) $(CXXFLAGS) -MM $(SRC) > makedep
#clean:
#	$(RM) $(OBJ) $(OUTPUT)

#include makedep

include ../../../Makefile1

