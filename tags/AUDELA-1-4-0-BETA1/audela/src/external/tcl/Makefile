.PHONY: build install uninstall clean distclean

build:

install:
	mkdir -p ../include/win
	cp -f tcl/include/tcl.h ../include/win
	cp -f tcl/include/tclDecls.h ../include/win
	cp -f tcl/include/tclPlatDecls.h ../include/win
	cp -f tcl/include/tk.h ../include/win
	cp -f tcl/include/tkDecls.h ../include/win
	cp -f tcl/include/tkIntXlibDecls.h ../include/win
	cp -f tcl/include/tkPlatDecls.h ../include/win
	mkdir -p ../include/win/x11
	cp -f tcl/include/x11/cursorfont.h ../include/win/x11
	cp -f tcl/include/x11/keysym.h ../include/win/x11
	cp -f tcl/include/x11/keysymdef.h ../include/win/x11
	cp -f tcl/include/x11/license.terms ../include/win/x11
	cp -f tcl/include/x11/X.h ../include/win/x11
	cp -f tcl/include/x11/Xatom.h ../include/win/x11
	cp -f tcl/include/x11/Xfuncproto.h ../include/win/x11
	cp -f tcl/include/x11/Xlib.h ../include/win/x11
	cp -f tcl/include/x11/Xutil.h ../include/win/x11
	cp -f tcl/lib/tcl84.lib ../lib
	cp -f tcl/lib/tclstub84.lib ../lib
	cp -f tcl/lib/tk84.lib ../lib
	cp -f tcl/lib/tkstub84.lib ../lib
	cp -f tcl/bin/tcl84.dll ../../../bin
	cp -f tcl/bin/tk84.dll ../../../bin

uninstall:
	cp -f ../include/win/x11/cursorfont.h
	cp -f ../include/win/x11/keysym.h
	cp -f ../include/win/x11/keysymdef.h
	cp -f ../include/win/x11/license.terms
	cp -f ../include/win/x11/X.h
	cp -f ../include/win/x11/Xatom.h
	cp -f ../include/win/x11/Xfuncproto.h
	cp -f ../include/win/x11/Xlib.h
	cp -f ../include/win/x11/Xutil.h
	rmdir ../include/win/x11
	cp -f ../include/win/tcl.h
	cp -f ../include/win/tclDecls.h
	cp -f ../include/win/tclPlatDecls.h
	cp -f ../include/win/tk.h
	cp -f ../include/win/tkDecls.h
	cp -f ../include/win/tkIntXlibDecls.h
	cp -f ../include/win/tkPlatDecls.h
	rmdir ../include/win
	cp -f ../lib/tcl84.lib
	cp -f ../lib/tclstub84.lib
	cp -f ../lib/tk84.lib
	cp -f ../lib/tkstub84.lib
	cp -f ../../../bin/tcl84.dll
	cp -f ../../../bin/tk84.dll

clean:

distclean: clean
	rm -f *~ *.bak
