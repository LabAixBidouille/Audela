#--   cree le fichier cgi_param.tcl dans cgi/cg_bin/audela/
set file [file join $audace(rep_gui) cgi cgi-bin audela cgi_param.tcl]
set f [open $file w]
puts $f "set cgi(audela,rep_userCatalog) \"$audace(rep_userCatalog)\""
puts $f "set cgi(audela,rep_images) \"$audace(rep_images)\""
puts $f "set cgi(audela,home) [list $audace(posobs,observateur,gps)]"
puts $f "set cgi(audela,rep_catalogues) \"$audace(rep_catalogues)\""

close $f