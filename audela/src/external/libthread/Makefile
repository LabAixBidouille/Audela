.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = thread26

build:
	@if test ! -f $(DIR)/Makefile; then \
		cd $(DIR) && \
			chmod +x configure ; ./configure --enable-threads --exec-prefix=$(ROOT)/.. --with-tcl=$(AUD_TCL_SPEC)/lib/tcl8.4 ; \
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
