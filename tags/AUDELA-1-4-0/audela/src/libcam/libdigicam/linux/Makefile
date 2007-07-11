
LIBCAM = 1

OUTPUT = libdigicam.so

SRC  = $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1


CXXFLAGS += -I $(EXTINC)


$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libgphoto2.so 
	@echo "*lib:" > libdigicam.specs
	@echo "    -rpath ." >> libdigicam.specs
	$(LD) $(LDFLAGS) -specs libdigicam.specs -L$(OUTPUTDIR) -lgphoto2 -o $@ $(OBJ)
	$(CP) $@ $(OUTPUTDIR)
	@$(RM) libdigicam.specs

