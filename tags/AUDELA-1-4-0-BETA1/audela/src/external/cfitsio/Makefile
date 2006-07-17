.PHONY: build install clean distclean

DIR = cfitsio2510

build:
	( cd $(DIR) ; chmod +x configure ; ./configure --prefix=`pwd`/../.. )
	make -C $(DIR)

install: build
	make -C $(DIR) install

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak
