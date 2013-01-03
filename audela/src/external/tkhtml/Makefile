.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = htmlwidget

build:
	@if test ! -f $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
			chmod +x configure ; ./configure --prefix=$(ROOT)/.. --exec-prefix=$(ROOT)/.. --with-tcl=$(AUD_TCL_BIN_DIR) --with-mysql-lib=$(AUD_TCL_BIN_DIR) ; make clean ; \
	fi;
	make -C $(DIR)

install: build
	rm -rf $(ROOT)/../lib/tkhtml3.0
	make -C $(DIR) install-lib-binaries

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak
	make -C $(DIR) distclean
