.PHONY: clean

all:

clean:
	rm -f libavi.so avi.o

INCLUDES=-I /opt/ffmpeg-0.8.5/libavformat -I /opt/ffmpeg-0.8.5/libavutil -I /opt/ffmpeg-0.8.5/libavcodec -I /opt/ffmpeg-0.8.5/libswscale
all: libavi.so

avi.o: avi.c
	gcc -shared -fPIC $(INCLUDES) -c -o $@ -DUSE_TCL_STUBS $<

libavi.so: avi.o
	gcc -shared -fPIC \
	-I /opt/ffmpeg-0.8.5/libavformat -L /opt/ffmpeg-0.8.5/libavformat \
	-I /opt/ffmpeg-0.8.5/libavfilter -L /opt/ffmpeg-0.8.5/libavfilter \
	-I /opt/ffmpeg-0.8.5/libavutil -L /opt/ffmpeg-0.8.5/libavutil \
	-I /opt/ffmpeg-0.8.5/libavcodec -L /opt/ffmpeg-0.8.5/libavcodec \
	-I /opt/ffmpeg-0.8.5/libswscale -L /opt/ffmpeg-0.8.5/libswscale \
	-I /opt/ffmpeg-0.8.5/libavdevice -L /opt/ffmpeg-0.8.5/libavdevice \
	$< \
	-lavdevice -lavformat -lavcodec -lavutil -lswscale \
	-ltclstub8.5 -lm \
	-o $@
