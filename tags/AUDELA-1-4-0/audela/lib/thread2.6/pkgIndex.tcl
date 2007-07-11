#
# Tcl package index file, version 1.1
#
if {[package vsatisfies [package provide Tcl] 8.4]} {
    package ifneeded Thread 2.6.3 [list thread_load $dir]
    proc thread_load {dir} {
        load [file join $dir thread26.dll]
    }
}
