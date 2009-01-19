if { $::tcl_platform(os) == "Linux" } {
   package ifneeded zlibtcl 1.2.3  [list load [file join $dir libzlibtcl1.2.3.so]]
} else {
   package ifneeded zlibtcl 1.2.3  [list load [file join $dir zlibtcl123.dll]]
}
