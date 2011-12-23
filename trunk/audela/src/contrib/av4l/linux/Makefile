.PHONY: all clean ffmpeg-clean ffmpeg-config ffmpeg ffmpeg-uninstall ffmpeg-links install uninstall grab

ARCH=64

ifeq ($(ARCH),32)
 AFLAGS = -march=i686 -m32 -msse4
else
 AFLAGS =
endif

FFMPEG=../ffmpeg-0.8.5
SRC=../src

LDFLAGS1 = -v -L$(FFMPEG)/libavformat -L$(FFMPEG)/libavcodec 
LDFLAGS2 = -L$(FFMPEG)/libavcodec -L$(FFMPEG)/libavutil -L$(FFMPEG)/libavdevice -L$(FFMPEG)/libswscale
LDFLAGS  = $(LDFLAGS1)  $(LDFLAGS2)

LDLIBS = -lavformat -lavcodec -lavutil -lavdevice -lswscale -lm -lz -lpthread

INCLUDES=-I $(FFMPEG)/libavformat -I $(FFMPEG)/libavutil -I $(FFMPEG)/libavcodec \
         -I $(FFMPEG)/libswscale -I $(FFMPEG)/libavdevice -I $(FFMPEG) \
	 -I /usr/include/tcl8.5

all:

clean: ffmpeg-clean
	rm -f libavi.so avi.o
	rm -f grab grab.o proto_filex.o proto_null.o 
	rm -rf dox

all: ffmpeg-config ffmpeg ffmpeg-links libavi.so grab

avi.o: $(SRC)/avi.c
	gcc -shared -fPIC $(INCLUDES) -c -o $@ -DUSE_TCL_STUBS $<

libavi.so: avi.o
	gcc -shared -fPIC \
	-I $(FFMPEG)/libavformat -L $(FFMPEG)/libavformat \
	-I $(FFMPEG)/libavfilter -L $(FFMPEG)/libavfilter \
	-I $(FFMPEG)/libavutil -L $(FFMPEG)/libavutil \
	-I $(FFMPEG)/libavcodec -L $(FFMPEG)/libavcodec \
	-I $(FFMPEG)/libswscale -L $(FFMPEG)/libswscale \
	$< \
	-lavformat -lavcodec -lavutil -lswscale \
	-ltclstub8.5 -lm \
	-o $@

grab.o: $(SRC)/grab.c
	gcc -c -Wall -g -O2 -I $(FFMPEG) $(AFLAGS) $(SRC)/grab.c -o $@

grab: grab.o proto_filex.o proto_null.o
	gcc -Wall -g -O2 -I $(FFMPEG) $(AFLAGS) $(LDFLAGS)  grab.o proto_filex.o proto_null.o $(LDLIBS) -o $@

proto_filex.o: $(SRC)/proto_filex.c
	gcc -g -O2 -I $(FFMPEG) $(AFLAGS) $(LDFLAGS) -c -o $@ $<

proto_null.o: $(SRC)/proto_null.c
	gcc -g -O2 -I $(FFMPEG) $(AFLAGS) $(LDFLAGS) -c -o $@ $<

doc: Doxyfile $(SRC)/grab.c $(SRC)/proto_filex.c $(SRC)/proto_null.c
	doxygen

ffmpeg-clean:
	cd $(FFMPEG) && make clean && rm -f config.mak

ffmpeg-config:
	cd $(FFMPEG) && \
	if test ! -e config.mak ; then \
	./configure --enable-pic --enable-shared --enable-static \
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
	--disable-yasm \
	; fi

ffmpeg:
	cd $(FFMPEG) && make

ffmpeg-links:
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

install:
	cp -vf libavi.so ../../../../bin/
	cp -vf grab ../../../../bin/av4l-grab


