.PHONY: build install clean distclean

include ../../Makefile.defs
DIR = cfitsio3340

build:
	@if test ! -e $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
		chmod +x configure ; \
		./configure --prefix=`pwd`/../.. ; \
	fi;
	#--- create static library libcfitsio.a (for libtt.so)
	make -C $(DIR)
	#--- create dynamic library libcfitsio.so ( for libtt.so and libfitstcl.so )
	make -C $(DIR) shared

install:
	#--- copy libcfitsio.a and libcfitsio.so to $(ROOT)/external/lib
	make -C $(DIR) install
	#--- copy libcfitsio.so to $(ROOT)/../bin
	cp $(ROOT)/external/lib/libcfitsio.so $(ROOT)/../bin

clean:
	make -C $(DIR) clean

distclean:
	make -C $(DIR) distclean
	rm -f *~ *.bak
