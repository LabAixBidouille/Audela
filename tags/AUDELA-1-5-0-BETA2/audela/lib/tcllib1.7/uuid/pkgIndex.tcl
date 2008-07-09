# pkgIndex.tcl - 
#
# uuid package index file
#
# $Id: pkgIndex.tcl,v 1.1 2005/02/15 21:12:59 Administrateur Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded uuid 1.0.0 [list source [file join $dir uuid.tcl]]
