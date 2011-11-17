ARCH=64

ifeq ($(ARCH),32)
 AFLAGS = -march=i686 -m32 -msse4
 FFDIR = /opt/ffmpeg32
else
 AFLAGS=
 FFDIR = /opt/ffmpeg-0.8.5
endif

LDFLAGS = -v -static -L $(FFDIR)/libavformat -L $(FFDIR)/libavcodec -L $(FFDIR)/libavcodec -L $(FFDIR)/libavutil -L $(FFDIR)/libavdevice -L $(FFDIR)/libswscale
LDLIBS = -lavformat -lavcodec -lavutil -lavdevice -lswscale -lm -lz -lpthread

.PHONY: all doc

all: grab

grab.o: grab.c
	gcc -c -Wall -g -O2 -I $(FFDIR) $(AFLAGS) grab.c -o $@

grab: grab.o proto_filex.o proto_null.o
	gcc -Wall -g -O2 -I $(FFDIR) $(AFLAGS) $(LDFLAGS)  grab.o proto_filex.o proto_null.o $(LDLIBS) -o $@

proto_filex.o: proto_filex.c
	gcc -g -O2 -I $(FFDIR) $(AFLAGS) $(LDFLAGS) -c -o $@ $<

proto_null.o: proto_null.c
	gcc -g -O2 -I $(FFDIR) $(AFLAGS) $(LDFLAGS) -c -o $@ $<

doc: Doxyfile grab.c proto_filex.c proto_null.c
	doxygen

clean:
	rm -f grab grab.o proto_filex.o proto_null.o 
	rm -rf dox
