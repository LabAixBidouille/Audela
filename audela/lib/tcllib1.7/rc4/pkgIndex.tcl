# pkgIndex.tcl - 
#
# RC4 package index file
#
# This package has been tested with tcl 8.2.3 and above.
#
# $Id: pkgIndex.tcl,v 1.1 2005/02/15 21:12:50 Administrateur Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded rc4 1.0.0 [list source [file join $dir rc4.tcl]]
