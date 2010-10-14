.PHONY: build install clean distclean

build:

install:
	cp -f andor/include/Atmcd32d.h ../include
	cp -f andor/lib/atmcd32m.lib ../lib

clean:
	rm -f ../include/Atmcd32d.h
	rm -f ../lib/atmcd32m.lib

distclean: clean
	rm -f *~ *.bak
