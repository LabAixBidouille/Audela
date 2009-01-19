# Copyright (c) 2001 by Jean-Luc Fontaine <jfontain@free.fr>.
# This code may be distributed under the same terms as Tcl.
#
# $Id: pkgIndex.tcl,v 1.1 2008-11-29 23:05:09 denismarchais Exp $

# Since stooop redefines the proc command and the default package facility will
# only load the stooop package at the first unknown command, proc being
# obviously known by default, forcing the loading of stooop is mandatory prior
# to the first proc declaration.

if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded stooop 4.4.1 [list source [file join $dir stooop.tcl]]

# the following package index instruction was generated using:
#   "tclsh mkpkgidx.tcl switched switched.tcl"
# (comment out the following line if you do not want to use the switched class
# as a package)

package ifneeded switched 2.2.1 [list source [file join $dir switched.tcl]]
