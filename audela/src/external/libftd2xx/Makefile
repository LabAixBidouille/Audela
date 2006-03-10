.PHONY: build install clean distclean

build:

install:
	cp -f include/linux/*.h ../include
	cp -f bin/libftd2xx.so.0.4.8    ../../bin

clean:
	rm -f ../include/ftd2xx.h
	rm -f ../include/WinTypes.h
	rm -f ../..bin/libftd2xx.so.0.4.8 

distclean: clean
	rm -f *~ *.bak
