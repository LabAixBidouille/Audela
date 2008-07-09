.PHONY: build install clean distclean

# remarque : 
#     la librairie lftdxx doit s'appeler libftd2xx.so pour compiler audela
#     la librairie lftdxx doit s'appeler libftd2xx.so.0 pour executer audela

build:

install:
	@if [ ! -d ../include/linux ]; then mkdir ../include/linux; fi
	cp -f include/linux/*.h ../include/linux
	cp -f lib/libftd2xx.so.0.4.10    ../lib/libftd2xx.so
	cp -f lib/libftd2xx.so.0.4.10    ../../../bin/libftd2xx.so.0
	chmod +x ../../../bin/libftd2xx.so.0

clean:
	rm -f ../include/linux/ftd2xx.h
	rm -f ../include/linux/WinTypes.h
	rm -f ../../../bin/libftd2xx.so.0 

distclean: clean
	rm -f *~ *.bak

