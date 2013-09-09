# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl

proc eqmod_decode {s} {
   return [ expr int(0x[ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]00) / 256 ]
}

# decimal to hexadecimal
proc eqmod_encode {int} {
   set s [ string range [ format %08X $int ] 2 end ]
   return [ string range $s 4 5 ][ string range $s 2 3 ][ string range $s 0 1 ]
}

proc celestial_to_mount { h_deg dec_deg } {

   set deg1 [expr - $h_deg - 90 ]
   set deg2 [expr 180 - $dec_deg]
   
   return  [ list  $deg1 $deg2 ]

}

proc mount_to_celestial { deg1 deg2 } {

   set h_deg [expr - $deg1 - 90 ]
   set dec_deg [expr 180 - $deg2]
   
   return  [ list  $h_deg $dec_deg ]
}


proc affich_coord { } {

   set he1 [tel1 putread :j1]
   set de1 [eqmod_decode $he1]

   set hdeg [expr $de1 * 360. / 9024000. - 579.303829787234 ]
   set h  [mc_angle2hms $hdeg 360 zero 1 auto string]

   set he2 [tel1 putread :j2]
   set de2 [eqmod_decode $he2]
   set dec_deg [expr 180 - $de2 * 360. / 9024000.]
   set dec  [mc_angle2dms $dec_deg 90 zero 1 + string]

   ::console::affiche_resultat "Axe 1 HEX : $he1\n"
   ::console::affiche_resultat "Axe 1 DEC : $de1\n"
   ::console::affiche_resultat "Axe 2 HEX : $he2\n"
   ::console::affiche_resultat "Axe 2 DEC : $de2\n"
   ::console::affiche_resultat "--\n"
   ::console::affiche_resultat "H deg : $hdeg\n"
   ::console::affiche_resultat "H hms : $h\n"
   ::console::affiche_resultat "Dec deg : $dec_deg\n"
   ::console::affiche_resultat "Dec dms : $dec\n"
      
}

proc get_coord_decimal { p_de1 p_de2 } {

   upvar $p_de1 de1
   upvar $p_de2 de2
   
   set he1 [tel1 putread :j1]
   set de1 [eqmod_decode $he1]
   set he2 [tel1 putread :j2]
   set de2 [eqmod_decode $he2]
   
   return 0
}

proc move_to_coord { nxt_de1 nxt_de2 } {
 
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
      set he1 [eqmod_encode $diff_de1]
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
      set he2 [eqmod_encode $diff_de2]
      tel1 put :H2$he2
      tel1 put :J2
   }

   return 

}
