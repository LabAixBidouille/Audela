# $Id$
.PHONY: build install clean distclean uninstall

include ../../Makefile.defs

DIR = qsiapi-6.4.1
BINDIR = $(EXTDIR)/qsi/$(DIR)/bin

build:
	@if test ! -e $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
		chmod +x configure ; \
		./configure --quiet --enable-shared --enable-static=no --enable-libftd2xx --bindir=$(BINDIR) --libdir=$(EXTLIB) --includedir=$(EXTINC) LDFLAGS="-L$(EXTLIB) -Wl,-rpath,$(OUTPUTDIR)" ; \
		 \
	fi;
	$(MAKE) -C $(DIR)

install: build
	$(MAKE) -C $(DIR) install

clean:
	$(MAKE) -C $(DIR) clean

distclean:
	$(MAKE) -C $(DIR) distclean

uninstall :
	$(MAKE) -C $(DIR) uninstall
	@if [ -e $(BINDIR) ] ; then \
		$(RM) -r $(BINDIR) ; \
	fi;


