# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>
#
#
# Demarrage : 
# - Positionner la monture tube observat la polaire
# - Positionner la monture tube vers l Est et contre poids vers l'Ouest
# - connecte la monture dans Audela
# - dans la console : > source [file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]
# - dans la console : > ::eqmod::ressource
# - dans la console : > begin
# - dans la console : > begin_on_north
# 

proc begin { } {

   set ::eqmod::telno 1
   set ::eqmod::home {GPS 2.0 E 48.5 150.0}

   set now [clock format [clock seconds] -gmt 1 -format "%Y %m %d %H %M %S"]
   set tsl [mc_date2lst $now $::eqmod::home]
   ::console::affiche_resultat "TSL = $tsl\n"
   set t [expr ([lindex $tsl 0] + [lindex $tsl 1]/60. + [lindex $tsl 2]/3600.)*15.]

   # Definir les coordonnees de l observateur
   tel$::eqmod::telno home $::eqmod::home
   
   # etat des moteurs
   ::console::affiche_resultat "Moteurs = [tel$::eqmod::telno radec state]\n"
   
}

proc begin_on_north { } {

   ::eqmod::set_coord_mount 0 90

}


proc move_test { } {

   tel$::eqmod::telno put :K1
   tel$::eqmod::telno put :K2
   
   tel$::eqmod::telno put :G200
   tel$::eqmod::telno put :H2C0BC05
   tel$::eqmod::telno put :J2

}




