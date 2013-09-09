# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/begin_funcs.tcl
source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl

proc begin { } {

   set ::eqmod::home {GPS 2.0 E 48.5 150.0}
   set now [clock format [clock seconds] -gmt 1 -format "%Y %m %d %H %M %S"]
   set tsl [mc_date2lst $now $::eqmod::home]
   ::console::affiche_resultat "TSL = $tsl\n"
   set t [expr ([lindex $tsl 0] + [lindex $tsl 1]/60. + [lindex $tsl 2]/3600.)*15.]

   # Definir les coordonnees de l observateur
   tel1 home $::eqmod::home
   
   # etat des moteurs
   ::console::affiche_resultat "Moteurs = [tel1 radec state]\n"
   
}

proc begin_on_north { } {

   set hdeg 0
   set de1 [expr int($hdeg/360.*9024000)]
   set he1 [eqmod_encode $de1]
   set de2 [expr int(90./360.*9024000)]
   set he2 [eqmod_encode $de2]

   ::console::affiche_resultat "Axe 1 HEX : $he1\n"
   ::console::affiche_resultat "Axe 1 DEC : $de1\n"
   ::console::affiche_resultat "Axe 2 HEX : $he2\n"
   ::console::affiche_resultat "Axe 2 DEC : $de2\n"
   
   tel1 put :E1$he1
   tel1 put :E2$he2
}


proc move_test { } {

   tel1 put :K1
   tel1 put :K2
   
   tel1 put :G200
   tel1 put :H2C0BC05
   tel1 put :J2

}


proc move_to_north_pole { } {

   move_to_coord 0 90
 
}



proc move_to_east { } {

   move_to_coord 0 0

}

proc move_to_east2 { } {

   move_to_coord -180 180

}

proc move_to_west { } {

   move_to_coord 0 180

}

proc move_to_west2 { } {

   move_to_coord 180 0

}

proc move_to_south { } {

   set l [lindex $::eqmod::home 3]
   ::console::affiche_resultat "Lat : $l\n"
   set de2 [expr 180 + $l]
   move_to_coord -90 $de2

}

proc move_to_zenith { } {

   set l [lindex $::eqmod::home 3]
   set de2 [expr 90 + $l]
   move_to_coord -90 $de2

}

proc move_to_north { } {

   set l [lindex $::eqmod::home 3]
   move_to_coord -90 $l
}

proc move_to_equator_south { } {

   move_to_coord -90 180

}

proc move_to_equator_south_m1H { } {

   move_to_coord -75 180

}
proc move_to_equator_south_p1H { } {

   move_to_coord -105 180

}



