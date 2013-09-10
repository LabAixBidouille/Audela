# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl

namespace eval eqmod_tools {


   proc ::eqmod_tools::affich_coord { } {

      set he1 [tel1 putread :j1]
      set de1 [::eqmod::decode $he1]

      set h_deg [expr $de1 * 360. / 9024000. - 579.303829787234 ]
      set h  [mc_angle2hms $h_deg 360 zero 1 auto string]

      set he2 [tel1 putread :j2]
      set de2 [::eqmod::decode $he2]
      set dec_deg [expr 180 - $de2 * 360. / 9024000.]
      set dec  [mc_angle2dms $dec_deg 90 zero 1 + string]

      ::console::affiche_resultat "Axe 1 HEX : $he1\n"
      ::console::affiche_resultat "Axe 1 DEC : $de1\n"
      ::console::affiche_resultat "Axe 2 HEX : $he2\n"
      ::console::affiche_resultat "Axe 2 DEC : $de2\n"
      ::console::affiche_resultat "--\n"
      ::console::affiche_resultat "H deg : $h_deg\n"
      ::console::affiche_resultat "H hms : $h\n"
      ::console::affiche_resultat "Dec deg : $dec_deg\n"
      ::console::affiche_resultat "Dec dms : $dec\n"

   }


}
