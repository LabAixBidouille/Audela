# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl

namespace eval eqmod {



   variable home





   proc ::eqmod::ressource { } {
      
      source [file join $audace(rep_install) src libtel libeqmod extra src init.tcl]
      source [file join $audace(rep_install) src libtel libeqmod extra src eqmod_move.tcl]
      source [file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]
      source [file join $audace(rep_install) src libtel libeqmod extra src eqmod_tools.tcl]
   }


   proc ::eqmod::decode {s} {
      return [ expr int(0x[ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]00) / 256 ]
   }

   # decimal to hexadecimal
   proc ::eqmod::encode {int} {
      set s [ string range [ format %08X $int ] 2 end ]
      return [ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]
   }

   proc ::eqmod::celestial_to_mount { h_deg dec_deg } {

      set deg1 [expr - $h_deg - 90 ]
      set deg2 [expr 180 - $dec_deg]

      return  [ list  $deg1 $deg2 ]

   }

   proc ::eqmod::mount_to_celestial { deg1 deg2 } {

      set h_deg [expr - $deg1 - 90 ]
      set dec_deg [expr 180 - $deg2]

      return  [ list  $h_deg $dec_deg ]
   }

   proc ::eqmod::get_coord_decimal { p_de1 p_de2 } {

      upvar $p_de1 de1
      upvar $p_de2 de2

      set he1 [tel1 putread :j1]
      set de1 [::eqmod::decode $he1]
      set he2 [tel1 putread :j2]
      set de2 [::eqmod::decode $he2]

      return 0
   }

   proc ::eqmod::get_coord_deg { p_h_deg p_dec_deg } {

      upvar $p_h_deg h_deg
      upvar $p_dec_deg dec_deg

      get_coord_decimal de1 de2
      set h_deg [expr $de1 * 360. / 9024000. - 579.303829787234 ]
      set dec_deg [expr 180 - $de2 * 360. / 9024000.]

      return 0
   }

   proc ::eqmod::get_coord_hmsdms { p_h_hms p_dec_dms } {

      upvar $p_h_hms h_hms
      upvar $p_dec_dms dec_dms

      get_coord_deg h_deg dec_deg
      set h_hms   [mc_angle2hms $h_deg 360 zero 1 auto string]
      set dec_dms [mc_angle2dms $dec_deg 90 zero 1 + string]

      return 0
   }

   # Demarrage du deplacement du telescope 
   # en donnant une coordonnee Celeste
   # h : agle horaire
   # d : declinaison

   proc ::eqmod::move_to_coord_celestial {  h_deg dec_deg } {

      set r [celestial_to_mount $h_deg $dec_deg]
      set hm [lindex $r 0]
      set dm [lindex $r 1]
      move_to_coord_mount $hm $dm
      return 0
   }

   # Demarrage du deplacement du telescope 
   # en donnant une coordonnees Monture

   proc ::eqmod::move_to_coord_mount { nxt_de1 nxt_de2 } {

      get_coord_decimal de1 de2

      set nxt_de1 [expr int($nxt_de1/360.*9024000)]
      set nxt_de2 [expr int($nxt_de2/360.*9024000)]

      set diff_de1 [expr $nxt_de1 - $de1]
      set diff_de2 [expr $nxt_de2 - $de2]

      ::console::affiche_resultat "diff_de1 : $diff_de1\n"
      ::console::affiche_resultat "diff_de2 : $diff_de2\n"

      if {$diff_de1!=0} {
         tel1 put :K1
         if {$diff_de1>0} {
            tel1 put :G100
         } else {
            set diff_de1 [expr -$diff_de1]
            tel1 put :G101
         }
         set he1 [::eqmod::encode $diff_de1]
         tel1 put :H1$he1
         tel1 put :J1
      }

      if {$diff_de2!=0} {
         tel1 put :K2
         if {$diff_de2>0} {
            tel1 put :G200
         } else {
            set diff_de2 [expr -$diff_de2]
            tel1 put :G201
         }
         set he2 [::eqmod::encode $diff_de2]
         tel1 put :H2$he2
         tel1 put :J2
      }

      return 0

   }

   proc ::eqmod::set_coord_mount { hm dm } {


      set de1 [expr int($hm/360.*9024000)]
      set he1 [::eqmod::encode $de1]
      set de2 [expr int($dm/360.*9024000)]
      set he2 [::eqmod::encode $de2]

      ::console::affiche_resultat "Axe 1 HEX : $he1\n"
      ::console::affiche_resultat "Axe 1 DEC : $de1\n"
      ::console::affiche_resultat "Axe 2 HEX : $he2\n"
      ::console::affiche_resultat "Axe 2 DEC : $de2\n"

      tel1 put :E1$he1
      tel1 put :E2$he2

      return 0
   }


}
