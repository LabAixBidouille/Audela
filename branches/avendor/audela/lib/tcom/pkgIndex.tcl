# $Id: pkgIndex.tcl,v 1.1.1.1 2005-12-03 20:53:19 denismarchais Exp $
package ifneeded tcom 3.8 \
[list load [file join $dir tcom.dll]]\n[list source [file join $dir tcom.tcl]]
