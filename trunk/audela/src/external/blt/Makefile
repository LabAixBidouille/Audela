.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = blt2.4z

build:
	@if test ! -f $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
		echo chmod +x configure ; \
		./configure --enable-threads --with-tcl=$(AUD_TCL_BIN_DIR) --with-blt=$(ROOT)/../lib ; \
		 \
	fi;
	make -C $(DIR)

install: build
	make -C $(DIR) install

clean:
	make -C $(DIR) clean
	rm -f $(DIR)/Makefile

distclean: clean
	rm -f *~ *.bak
	rm -f $(ROOT)/../lib/blt2.4/libBLT24.so
	rm -f $(ROOT)/../lib/blt2.4/pkgIndex.tcl
