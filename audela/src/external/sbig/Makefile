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
	$(CP) -f sbig/lib/libsbigudrv.1.4.43.so  $(EXTLIB)/libsbigudrv.1.4.43.so
	$(CP) -f sbig/lib/libsbigudrv.1.4.43.so  $(OUTPUTDIR)/libsbigudrv.1.4.43.so

clean:
	$(RM) $(EXTINC)/Sbigudrv.h
	$(RM) $(EXTLIB)/libsbigudrv.1.4.43.so
	$(RM) $(OUTPUTDIR)/libsbigudrv.1.4.43.so

distclean: clean
	$(RM) *~ *.bak
