.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = thread26

build:
	( cd $(DIR) ; chmod +x configure ; ./configure --enable-threads --with-tcl=$(AUD_TCL_SPEC)/lib )
	make -C $(DIR)
	@mkdir -p $(ROOT)/../lib/thread2.6
	cp $(DIR)/libthread2.6.5.1.so $(ROOT)/../lib/thread2.6
	cp $(DIR)/pkgIndex.tcl        $(ROOT)/../lib/thread2.6

install: build
	@mkdir -p $(ROOT)/../lib/thread2.6
	cp $(DIR)/libthread2.6.5.1.so $(ROOT)/../lib/thread2.6
	cp $(DIR)/pkgIndex.tcl        $(ROOT)/../lib/thread2.6

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak
	rm -f $(ROOT)/../lib/thread2.6/libthread2.6.5.1.so
	rm -f $(ROOT)/../lib/thread2.6/pkgIndex.tcl
