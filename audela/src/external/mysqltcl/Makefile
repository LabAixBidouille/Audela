include ../../Makefile.defs

.PHONY: build install clean distclean

DIR = mysqltcl-3.05

build:
	@if test ! -f $(DIR)/Makefile; then \
		cd $(DIR) && \
			chmod +x configure ; ./configure --exec-prefix=$(ROOT)/.. --with-tcl=$(AUD_TCL_BIN_DIR) ; \
	fi;
	make -C $(DIR)

install: build
	make -C $(DIR) install-lib-binaries

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak
