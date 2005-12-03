# pkgIndex.tcl for the tcllib http module.
#
# $Id: pkgIndex.tcl,v 1.1 2005/02/15 21:12:42 Administrateur Exp $

if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded autoproxy 1.2.0 [list source [file join $dir autoproxy.tcl]]
