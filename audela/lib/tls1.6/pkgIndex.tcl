if {![package vsatisfies [package provide Tcl] 8.3]} {return}
package ifneeded tls 1.6 "source \[file join [list $dir] tls.tcl\] ; tls::initlib [list $dir] tls16.dll"
