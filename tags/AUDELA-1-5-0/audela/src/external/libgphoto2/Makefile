###include ../Makefile.defs


MYTARGETS = libltdl libgphoto2_port/libgphoto2_port libgphoto2_port/usb libgphoto2  camlibs/canon

.PHONY: $(MYTARGETS) clean cleanall install

all: $(MYTARGETS)



$(MYTARGETS):
	(cd $@/linux; make)

clean cleanall:
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR)/linux $@ ; )



.PHONY: local-clean dist-clean dist

local-clean:
	$(RM) *~

dist-clean: local-clean
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR)/linux distclean -o makedep ; )

dist: dist-clean
	mkdir -p $(distdir)
	cp -r * $(distdir)

install: 
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR)/linux $@ install; )

