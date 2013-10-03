# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source [file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]

namespace eval eqmod {



   variable home
   variable telno




   proc ::eqmod::ressource { } {

      global audace

      uplevel #0 "source \"[file join $audace(rep_install) src libtel libeqmod extra src init.tcl]\""
      uplevel #0 "source \"[file join $audace(rep_install) src libtel libeqmod extra src eqmod_move.tcl]\""
      uplevel #0 "source \"[file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl]\""
      uplevel #0 "source \"[file join $audace(rep_install) src libtel libeqmod extra src eqmod_tools.tcl]\""

   }


   proc ::eqmod::decode {s} {
      set i [ expr int(0x[ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]00) / 256 ]
#      if {$i > 9024000} {set i [expr $i - 16777216]}
#      if {$i < 0 } { 
#         ::console::affiche_erreur "decode : $i \n" 
#         set i [ expr 9024000 + $i]
#         ::console::affiche_erreur "decode : $i negatif pour hex = $s\n" 
#      }
      ::console::affiche_erreur "decode : $s => $i\n" 
      return $i
   }

   # decimal to hexadecimal
   proc ::eqmod::encode {int} {
      set s [ string range [ format %08X $int ] end-5 end ]
      return [ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]
   }

   proc ::eqmod::celestial_to_mount { h_deg dec_deg } {

      set deg1 [expr $h_deg  ]
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

      set he1 [tel$::eqmod::telno putread :j1]
      set de1 [::eqmod::decode $he1]
      set he2 [tel$::eqmod::telno putread :j2]
      set de2 [::eqmod::decode $he2]

      return 0
   }

   proc ::eqmod::get_coord_deg { p_h_deg p_dec_deg } {

      upvar $p_h_deg h_deg
      upvar $p_dec_deg dec_deg

      get_coord_decimal de1 de2
      set h_deg [expr $de1 * 360. / 9024000. ]
      set dec_deg [expr 180 - $de2 * 360. / 9024000.]

      return 0
   }

   proc ::eqmod::get_coord_hmsdms { p_h_hms p_dec_dms } {

      upvar $p_h_hms h_hms
      upvar $p_dec_dms dec_dms

      ::eqmod::get_coord_deg h_deg dec_deg
      set h_hms   [mc_angle2hms $h_deg 360 zero 1 auto string]
      set dec_dms [mc_angle2dms $dec_deg 90 zero 1 + string]

      return 0
   }

   # Demarrage du deplacement du telescope 
   # en donnant une coordonnee Celeste
   # h : agle horaire
   # d : declinaison

   proc ::eqmod::move_to_coord_celestial {  h_deg dec_deg } {

      set r [::eqmod::celestial_to_mount $h_deg $dec_deg]
      set hm [lindex $r 0]
      set dm [lindex $r 1]
      ::eqmod::move_to_coord_mount $hm $dm
      return 0
   }

   # Demarrage du deplacement du telescope 
   # en donnant une coordonnees Monture

   proc ::eqmod::move_to_coord_mount { nxt_de1 nxt_de2 } {

      set log 1

      get_coord_decimal de1 de2
      if {$log} {::console::affiche_resultat "Position H actuelle : $de1\n"}

      set nxt_de1 [expr int($nxt_de1/360.*9024000)]
#      if {$nxt_de1 < 0 } { 
#         if {$log} {::console::affiche_erreur "Position H suivante negative : $nxt_de1\n"} 
#         set nxt_de1 [ expr 9024000 + $nxt_de1]
#      }
      if {$log} {::console::affiche_resultat "Position H suivante : $nxt_de1\n"}
      set diff_de1 [expr $nxt_de1 - $de1]
#      if {$diff_de1 >= 9024000}  {set diff_de1 [expr $diff_de1 - 9024000]}
#      if {$diff_de1 <= -9024000} {set diff_de1 [expr $diff_de1 + 9024000]}
      if {$log} {::console::affiche_resultat "Position H diff : $diff_de1\n"}

      set nxt_de2 [expr int($nxt_de2/360.*9024000)]
      if {$nxt_de2 < 0 } { 
         if {$log} {::console::affiche_erreur "Position DEC suivante negative : $nxt_de2\n"} 
         set nxt_de2 [ expr 9024000 + $nxt_de2]
      }
      if {$log} {::console::affiche_resultat "Position DEC suivante : $nxt_de2\n"}
      set diff_de2 [expr $nxt_de2 - $de2]
      if {$diff_de2 >= 9024000}  {set diff_de2 [expr $diff_de2 - 9024000]}
      if {$diff_de2 <= -9024000} {set diff_de2 [expr $diff_de2 + 9024000]}
      if {$log} {::console::affiche_resultat "Position DEC diff     : $diff_de2\n"}





      if {$diff_de1!=0} {
         tel$::eqmod::telno put :K1
         if {$log} {::console::affiche_resultat "tel$::eqmod::telno put :K1\n"}
         if {$diff_de1>0} {
            tel$::eqmod::telno put :G100
            if {$log} {::console::affiche_resultat "tel$::eqmod::telno put :G100\n"}
         } else {
            set diff_de1 [expr -$diff_de1]
            tel$::eqmod::telno put :G101
            if {$log} {::console::affiche_resultat "tel$::eqmod::telno put :G101\n"}
         }
         set he1 [::eqmod::encode $diff_de1]
         tel$::eqmod::telno put :H1$he1
         if {$log} {::console::affiche_resultat "tel$::eqmod::telno put :H1$he1\n"}
         tel$::eqmod::telno put :J1
         if {$log} {::console::affiche_resultat "tel$::eqmod::telno put :J1\n"}
      }

      if {$diff_de2!=0} {
         tel$::eqmod::telno put :K2
         if {$diff_de2>0} {
            tel$::eqmod::telno put :G200
         } else {
            set diff_de2 [expr -$diff_de2]
            tel$::eqmod::telno put :G201
         }
         set he2 [::eqmod::encode $diff_de2]
         tel$::eqmod::telno put :H2$he2
         tel$::eqmod::telno put :J2
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

      tel$::eqmod::telno put :E1$he1
      tel$::eqmod::telno put :E2$he2

      return 0
   }

   proc ::eqmod::set_coord_celestial { h_deg dec_deg } {
      
      set r [::eqmod::celestial_to_mount $h_deg $dec_deg]
      set hm [lindex $r 0]
      set dm [lindex $r 1]
      ::console::affiche_resultat "mount hm : $hm\n"
      ::console::affiche_resultat "mount dm : $dm\n"
      ::eqmod::set_coord_mount $hm $dm
      return 0
   }

   proc ::eqmod::coord_equatorial_to_hour { ra_deg dec_deg } {

      set now [clock format [clock seconds] -gmt 1 -format "%Y %m %d %H %M %S"]
      set tsl [mc_date2lst $now $::eqmod::home]
      set t [expr ([lindex $tsl 0] + [lindex $tsl 1]/60. + [lindex $tsl 2]/3600.)*15.]

      # H = TSL - RA
      set h_deg [expr $t - $ra_deg ]

      set h    [mc_angle2hms $h_deg 360 zero 1 auto string]
      set dec  [mc_angle2dms $dec_deg 90 zero 1 + string]
      ::console::affiche_resultat "H = $h ; DEC = $dec \n"

      return  [ list  $h_deg $dec_deg ]

   }

   proc ::eqmod::coord_hour_to_equatorial { h_deg dec_deg } {

      set now [clock format [clock seconds] -gmt 1 -format "%Y %m %d %H %M %S"]
      set tsl [mc_date2lst $now $::eqmod::home]
      set t [expr ([lindex $tsl 0] + [lindex $tsl 1]/60. + [lindex $tsl 2]/3600.)*15.]

      # H = TSL - RA
      set ra_deg [expr $t - $h_deg ]

      set ra   [mc_angle2hms $ra_deg 360 zero 1 auto string]
      set dec  [mc_angle2dms $dec_deg 90 zero 1 + string]
      ::console::affiche_resultat "RA = $ra ; DEC = $dec \n"

      return [ list $ra_deg $dec_deg ]

   }

}
