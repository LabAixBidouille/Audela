# Thread 2.6.5.1
#    Modified Thread 2.6.5 : New command "copycommand" for Audela.

if { $::tcl_platform(os) == "Linux" } {
   package ifneeded Thread 2.6.5.1  [list load [file join $dir libthread2.6.5.1.so]]
} else {
   package ifneeded Thread 2.6.5.1  [list load [file join $dir libthread2.6.5.1.dll]]
}

