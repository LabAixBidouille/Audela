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

   ::eqmod::set_coord_mount 0 90

}


proc move_test { } {

   tel1 put :K1
   tel1 put :K2
   
   tel1 put :G200
   tel1 put :H2C0BC05
   tel1 put :J2

}




