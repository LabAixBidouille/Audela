.PHONY: build install clean distclean

build:
	@make -C sextractor/linux

install: build
	cp -f sextractor/linux/sex ../../../bin

clean:
	@make -C sextractor/linux clean

distclean: clean
	rm -f *~ *.bak
