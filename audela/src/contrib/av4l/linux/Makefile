.PHONY: all clean cleanall distclean install uninstall 
.PHONY: ffmpeg-clean ffmpeg-config ffmpeg ffmpeg-uninstall ffmpeg-install

include ../../../Makefile.defs

FFMPEG=../ffmpeg-0.8.5
SRC=../src
VPATH = ../src

CFLAGS = -Wall -g -O2
LDFLAGS = 
#TARGET_ARCH = -m32

INCLUDES_FFMPEG =
INCLUDES_FFMPEG += -I $(FFMPEG)

LDFLAGS_FFMPEG =
LDFLAGS_FFMPEG += -L$(FFMPEG)/libavformat -L$(FFMPEG)/libavcodec
LDFLAGS_FFMPEG += -L$(FFMPEG)/libavutil -L$(FFMPEG)/libavdevice -L$(FFMPEG)/libswscale


all:

all: ffmpeg-install libavi.so grab install


cleanall: clean

distclean: clean uninstall

clean: ffmpeg-clean
	rm -f libavi.so avi.o
	rm -f grab grab.o proto_filex.o proto_null.o 
	rm -rf dox


libavi.so: CFLAGS += -shared -fPIC
libavi.so: CPPFLAGS += $(INCLUDES_FFMPEG) $(AUD_TCL_INCLUDE_SPEC)
libavi.so: LDFLAGS += $(LDFLAGS_FFMPEG) -shared -fPIC
libavi.so: LDLIBS = -lavformat -lavcodec -lavutil -lswscale -lm $(AUD_TCL_STUB_LIB_SPEC)
libavi.so: avi.o
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@


grab: CPPFLAGS += $(INCLUDES_FFMPEG)
grab: LDFLAGS += $(LDFLAGS_FFMPEG)
grab: LDLIBS += -lavformat -lavcodec -lavutil -lavdevice -lswscale -lm -lpthread
grab: grab.o proto_filex.o proto_null.o
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@


doc: Doxyfile $(SRC)/grab.c $(SRC)/proto_filex.c $(SRC)/proto_null.c
	doxygen


ffmpeg-clean:
	$(MAKE) -C $(FFMPEG) clean

ifeq ($(TARGET_ARCH),-m32)
 ffmpeg_config_extra = --extra-cflags=-m32 --extra-ldflags=-m32
else
 ffmpeg_config_extra =
endif

ffmpeg-config: $(FFMPEG)/config.mak

$(FFMPEG)/config.mak: Makefile
	cd $(FFMPEG) && \
	./configure --enable-pic --enable-shared --enable-static $(ffmpeg_config_extra) \
	--disable-doc --disable-pthreads --disable-network \
	--disable-outdevs \
	--disable-indevs --enable-indev=v4l2 \
	--disable-protocols --enable-protocol=file \
	--disable-encoders --enable-encoder=ffvhuff --enable-encoder=huffyuv --enable-encoder=rawvideo \
	--disable-decoders --enable-decoder=ffvhuff --enable-decoder=huffyuv --enable-decoder=rawvideo \
	--disable-muxers --enable-muxer=avi \
	--disable-demuxers --enable-demuxer=avi \
	--disable-bsfs \
	--disable-parsers \
	--disable-yasm

ffmpeg: ffmpeg-config
	$(MAKE) -C $(FFMPEG)

ffmpeg-install: ffmpeg
	cp -vf $(FFMPEG)/libavcodec/libavcodec.so.53 ../../../../bin/
	cp -avf $(FFMPEG)/libavcodec/libavcodec.so ../../../../bin/
	cp -vf $(FFMPEG)/libavfilter/libavfilter.so.2 ../../../../bin/
	cp -avf $(FFMPEG)/libavfilter/libavfilter.so ../../../../bin/
	cp -vf $(FFMPEG)/libavformat/libavformat.so.53 ../../../../bin/
	cp -avf $(FFMPEG)/libavformat/libavformat.so ../../../../bin/
	cp -vf $(FFMPEG)/libavutil/libavutil.so.51 ../../../../bin/
	cp -avf $(FFMPEG)/libavutil/libavutil.so ../../../../bin/
	cp -vf $(FFMPEG)/libswscale/libswscale.so.2 ../../../../bin/
	cp -avf $(FFMPEG)/libswscale/libswscale.so ../../../../bin/
	cp -avf $(FFMPEG)/libavdevice/libavdevice.so ../../../../bin/
	cp -vf $(FFMPEG)/libavdevice/libavdevice.so.53 ../../../../bin/

ffmpeg-uninstall:
	rm -f ../../../../bin/{libavcodec.*,libavfilter.*,libavformat.*,libavutil.*,libswscale.*,libavdevice.*}

uninstall: ffmpeg-uninstall clean
	rm -f ../../../../bin/libavi.so
	rm -f ../../../../bin/av4l-grab

install: libavi.so grab ffmpeg-install
	cp -vf libavi.so ../../../../bin/
	cp -vf grab ../../../../bin/av4l-grab


