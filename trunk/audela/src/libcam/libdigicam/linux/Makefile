
LIBCAM = 1

OUTPUT = libdigicam.so

SRC  = $(LIBCAMDIR)/libcam.c
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c $(SRCDIR)/gp_api.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.c, %.o, $(filter $(LIBCAMDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS = -c -Wall -O2 -g3 -fmessage-length=0 -DUSE_TCL_STUBS -DUSE_TK_STUBS -DUSE_COMPOSITELESS_PHOTO_PUT_BLOCK -DUSE_COMPAT_CONST -I $(INCLUDE) $(AUD_TCL_INCLUDE_SPEC) -I ../src -I /usr/include/gphoto2 -I ../../../external/libftd2xx/include

$(OUTPUT): $(OBJ)
	$(LD)  -shared -lgphoto2 -ltclstub8.4 -o $@ $? /usr/local/lib/libusb-0.1.so.4
	$(CP) $@ $(OUTPUTDIR)

#	@echo "*** Linking library $@"

#  -ldl -lm  -ltkstub8.4 /usr/lib/libusb-0.1.so.4
# -L/usr/lib -lftd2xx -lusb 
#  $(LDFLAGS) 

