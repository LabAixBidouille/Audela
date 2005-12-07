.PHONY: build install clean distclean

build:

install:
	cp -f sbig/include/Sbigudrv.h ../include
	cp -f sbig/lib/udrv4.0.a ../lib
	cp -f sbig/bin/SBIGUDrv.dll ../../../bin

clean:
	rm -f ../include/Sbigudrv.h
	rm -f ../lib/udrv4.0.a
	rm -f ../../../bin/SBIGUDrv.dll

distclean: clean
	rm -f *~ *.bak
