.PHONY: build install clean distclean

build:

install:
	cp -f ./include/oscadine_driver.h ../include
	#--- je copie la librairie dynamique dans le repertoire des librairies pour l'edition de lien
	cp -f ./lib/libOscadineDriver.so ../lib
	#--- je copie la librairie dynamique dans le repertoire des binaires pour l'execution
	cp -f ./lib/libOscadineDriver.so ../../../bin

clean:
	rm -f ../include/oscadine_driver.h
	rm -f ../lib/libOscadineDriver.so
	rm -f ../../../bin/libOscadineDriver.so

distclean: clean
	rm -f *~ *.bak
