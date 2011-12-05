.PHONY: all clean ffmpeg-clean ffmpeg-config ffmpeg ffmpeg-uninstall ffmpeg-links install uninstall grab

FFMPEG=/opt/ffmpeg-0.8.5

INCLUDES=-I $(FFMPEG)/libavformat -I $(FFMPEG)/libavutil -I $(FFMPEG)/libavcodec \
         -I $(FFMPEG)/libswscale -I $(FFMPEG)/libavdevice -I $(FFMPEG) \
	-I /usr/include/tcl8.5

all:

clean:
	rm -f libavi.so avi.o
	( cd grab && make clean )

all: libavi.so grab

avi.o: avi.c
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

grab:
	( cd grab && make )

ffmpeg-clean:
	cd $(FFMPEG) && make clean

ffmpeg-config:
	cd $(FFMPEG) && \
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
	--disable-yasm

ffmpeg:
	cd $(FFMPEG) && make

ffmpeg-links:
	ln -sf $(FFMPEG)/libavcodec/libavcodec.so.53 ../../../../../../bin/
	ln -sf $(FFMPEG)/libavcodec/libavcodec.so ../../../../../../bin/
	ln -sf $(FFMPEG)/libavfilter/libavfilter.so.2 ../../../../../../bin/
	ln -sf $(FFMPEG)/libavfilter/libavfilter.so ../../../../../../bin/
	ln -sf $(FFMPEG)/libavformat/libavformat.so.53 ../../../../../../bin/
	ln -sf $(FFMPEG)/libavformat/libavformat.so ../../../../../../bin/
	ln -sf $(FFMPEG)/libavutil/libavutil.so.51 ../../../../../../bin/
	ln -sf $(FFMPEG)/libavutil/libavutil.so ../../../../../../bin/
	ln -sf $(FFMPEG)/libswscale/libswscale.so.2 ../../../../../../bin/
	ln -sf $(FFMPEG)/libswscale/libswscale.so ../../../../../../bin/

ffmpeg-uninstall:
	rm -f ../../../../../../bin/{libavcodec.*,libavfilter.*,libavformat.*,libavutil.*,libswscale.*}

uninstall: ffmpeg-uninstall
	rm -f ../../../../../../bin/libavi.so
	rm -f ../../../../../../bin/av4l-grab

install:
	cp libavi.so ../../../../../../bin/
	cp grab/grab ../../../../../../bin/av4l-grab

