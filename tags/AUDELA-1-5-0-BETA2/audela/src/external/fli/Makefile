.PHONY: build install clean distclean

DIR = libfli/lib

build:
	make -C $(DIR)

install:
	cp $(DIR)/libfli.h ../include
	cp $(DIR)/libfli.a ../lib

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak
