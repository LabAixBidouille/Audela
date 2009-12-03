.PHONY: build install clean distclean

include ../../Makefile.defs

os_version := $(shell sh -c 'uname -m 2>/dev/null || echo not')
lib_version := 32
ifneq ($(patsubst %64,%,$(os_version)),$(os_version))
	lib_version := 64
endif

build:

install:
	@if [ ! -d $(EXTINC) ]; then mkdir -p $(EXTINC); fi
	cp -f sbig/include/Sbigudrv.h $(EXTINC)
	@if [ ! -d $(EXTLIB) ]; then mkdir -p $(EXTLIB); fi
	$(CP) -f sbig/lib_$(lib_version)/libsbigudrv-4.57-linux-amd$(lib_version).a  $(EXTLIB)/udrv4.0.a

clean:
	$(RM) $(EXTINC)/Sbigudrv.h
	$(RM) $(EXTLIB)/udrv4.0.a

distclean: clean
	$(RM) *~ *.bak
