# Thread 2.6.5.1
#    = Thread 2.6.5 ( http://sourceforge.net/projects/tcl )
#    with new command "copycommand" for Audela.

if { $::tcl_platform(os) == "Linux" } {
   package ifneeded Thread 2.6.5.1  [list load [file join $dir libthread2.6.5.1.so]]
} else {
   package ifneeded Thread 2.6.5.1  [list load [file join $dir thread2651.dll]]
}

