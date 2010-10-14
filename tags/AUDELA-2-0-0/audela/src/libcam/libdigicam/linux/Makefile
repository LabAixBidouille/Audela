
LIBCAM = 1

OUTPUT = libdigicam.so

SRC  = $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1


CXXFLAGS += -I $(EXTINC)



$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libgphoto2.so 
	$(LD) -L$(OUTPUTDIR) $(LDFLAGS) -Xlinker -rpath $(OUTPUTDIR) -lgphoto2 -o $@ $(OBJ)
	$(CP) $@ $(OUTPUTDIR)


