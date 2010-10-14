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
	cp -f sbig/include/sbigudrv.h $(EXTINC)
	@if [ ! -d $(EXTLIB) ]; then mkdir -p $(EXTLIB); fi	
	$(CP) -f sbig/lib/libsbigudrv.1.4.60.so  $(EXTLIB)/libsbigudrv.1.4.60.so
	$(CP) -f sbig/lib/libsbigudrv.1.4.60.so  $(OUTPUTDIR)/libsbigudrv.1.4.60.so
	$(CP) -f sbig/lib/udrv4.0.a $(EXTLIB)/udrv4.0.a

clean:
	$(RM) $(EXTINC)/sbigudrv.h
	$(RM) $(EXTLIB)/libsbigudrv.1.4.60.so
	$(RM) $(EXTLIB)/udrv4.0.a
	$(RM) $(OUTPUTDIR)/libsbigudrv.1.4.60.so

distclean: clean
	$(RM) *~ *.bak
