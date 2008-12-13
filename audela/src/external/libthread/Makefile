.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = thread26

build:
	@if test ! -f $(DIR)/Makefile || test ../../Makefile.defs -nt thread26/Makefile; then \
		cd $(DIR) && \
			chmod +x configure ; ./configure --enable-threads --exec-prefix=$(ROOT)/.. --with-tcl=$(AUD_TCL_BIN_DIR) ; make clean ; \
	fi;
	make -C $(DIR)

install: build
	make -C $(DIR) install-lib-binaries

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak
	rm -f $(ROOT)/../lib/thread2.6/libthread2.6.5.1.so
	rm -f $(ROOT)/../lib/thread2.6/pkgIndex.tcl
