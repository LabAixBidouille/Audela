# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl

namespace eval eqmod_tools {


   proc ::eqmod_tools::affich_coord { } {

      set he1 [tel$::eqmod::telno putread :j1]
      set de1 [::eqmod::decode $he1]

#      set h_deg [expr $de1 * 360. / 9024000. - 579.303829787234 ]
      set h_deg [expr $de1 * 360. / 9024000. ]

      set h  [mc_angle2hms $h_deg 360 zero 1 auto string]

      set he2 [tel$::eqmod::telno putread :j2]
      set de2 [::eqmod::decode $he2]
      set dec_deg [expr 180 - $de2 * 360. / 9024000.]
      set dec  [mc_angle2dms $dec_deg 90 zero 1 + string]


      set r [::eqmod::coord_hour_to_equatorial $h_deg $dec_deg]
      set ra_deg [lindex $r 0]
      set ra  [mc_angle2hms $ra_deg 360 zero 1 auto string]

      set now [clock format [clock seconds] -gmt 1 -format "%Y %m %d %H %M %S"]
      set tsl [mc_date2lst $now $::eqmod::home]
      set t "[lindex $tsl 0] h [lindex $tsl 1] m [format "%.1f" [lindex $tsl 2] ] s"

      ::console::affiche_resultat "Axe 1 HEX : $he1\n"
      ::console::affiche_resultat "Axe 1 DEC : $de1\n"
      ::console::affiche_resultat "Axe 2 HEX : $he2\n"
      ::console::affiche_resultat "Axe 2 DEC : $de2\n"
      ::console::affiche_resultat "--\n"
      ::console::affiche_resultat "H deg : $h_deg\n"
      ::console::affiche_resultat "H hms : $h\n"
      ::console::affiche_resultat "RA  deg : $ra_deg\n"
      ::console::affiche_resultat "RA  hms : $ra\n"
      ::console::affiche_resultat "Dec deg : $dec_deg\n"
      ::console::affiche_resultat "Dec dms : $dec\n"
      ::console::affiche_resultat "TSL hms : $t\n"

   }


}
