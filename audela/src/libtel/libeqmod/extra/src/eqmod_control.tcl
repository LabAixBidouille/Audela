#  Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil d'Alain KLOTZ <alain.klotz@free.fr>
#  Modifie/adapte pour l'AZEQ6-GT par Jerome Berthier <berthier@imcce.fr>

namespace eval eqmod_control {

   set ::eqmod_control::test_delay 500

}

#
#
#
proc ::eqmod_control::init { } {

   ::eqmod::init_mount
   ::eqmod::init_mount_to_hour_coord 180 90

   after $::::eqmod_control::test_delay
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::park { } {

   ::console::affiche_erreur   "----------------------------------------------------------\n"
   ::console::affiche_resultat "  * Goto home position (0,+90)\n"
   ::console::affiche_erreur   "----------------------------------------------------------\n"
   
   # Goto
   ::eqmod::goto_hour_coord 0 90

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test1 { dec } {

   # Recupere les coordonnees horaires courantes
   ::eqmod::get_mount_hour_coord h_crte dec_crte

   ::console::affiche_resultat "TEST 1: mouvement de l'axe de declinaison\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Slewing to DEC = $dec deg. toward East\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   # Goto
   ::eqmod::goto_hour_coord $h_crte $dec

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test2 { h } {

   # Recupere les coordonnees horaires courantes
   ::eqmod::get_mount_hour_coord h_crte dec_crte

   ::console::affiche_resultat "TEST 2: mouvement de l'axe horaire\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Slewing to H = $h deg. toward [::eqmod::get_direction $h]\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   # Goto
   ::eqmod::goto_hour_coord $h $dec_crte

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test3 { h dec } {

   ::console::affiche_resultat "TEST 3: mouvements combines des axes horaire et de declinaison\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Slewing to H, DEC = $h $dec deg. toward [::eqmod::get_direction $h]\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   # Goto
   ::eqmod::goto_hour_coord $h $dec

   # Attente de l'arret complet des axes
   set m1_state [::eqmod::get_mount_state 1]
   set m2_state [::eqmod::get_mount_state 2]
   while {[lindex $m1_state 1] != 0 || [lindex $m2_state 1] != 0} {
      set m1_state [::eqmod::get_mount_state 1]
      set m2_state [::eqmod::get_mount_state 2]
   }

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test4 { star } {

   ::console::affiche_resultat "TEST 4: pointage d'une etoile\n"

   # Get star hour coordinates
   set c [::eqmod_control::get_star_coords $star]
   set h [lindex $c 2]
   set dec [lindex $c 3]

   ::console::affiche_erreur   "--------------------------------------------------------------------\n"
   ::console::affiche_resultat "  * Goto star = $star @ H, DEC = $h $dec deg.\n"
   ::console::affiche_erreur   "--------------------------------------------------------------------\n"

   ::eqmod::goto_hour_coord $h $dec

   # Affiche les coordonnees pointees
   ::eqmod_control::display_pos

}

#
#
#
proc ::eqmod_control::test5 { } {

   ::console::affiche_resultat "TEST 5: suivi sideral\n"

   ::eqmod::start_drift [expr 360.0/86164.0] 1 0
   ::eqmod::stop_drift 1

}

#
#
#
proc ::eqmod_control::test6 { speed axe {sens 1} } {

   set $d [expr {$sens == 0 ? "croissant" : "decroissant"}]
   ::console::affiche_resultat "TEST 6: suivi quelconque axe $axe a la vitesse $speed (sens $d)\n"

   ::eqmod::start_drift $speed $axe $sens
   ::eqmod::stop_drift $axe

}

#
#
#
proc ::eqmod_control::display_pos { } {

   ::console::affiche_erreur   "----------------------------------------------------------\n"
   ::console::affiche_resultat "  * Current position of the telescope\n"
   ::console::affiche_erreur   "----------------------------------------------------------\n"
   
   # Affiche les coordonnees pointees
   ::eqmod::get_mount_equatorial_coord ra dec
   ::eqmod::display_radec_coord $ra $dec
}

#
#
#
proc ::eqmod_control::get_star_coords { name } {

   switch $name {
      "altair"   {
                  #ALTAIR AR: 19h51m28.419s DE:+08°54'37.74" 
                  set ra "19h51m28.419s"
                  set dec  "+08d54m37.74s"
                 }
      "alpeg"    {
                  # Alp Peg : Apparente AR: 23h05m28.750s DE:+15°17'00.86" 
                  set ra "23h05m28.750s"
                  set dec  "+15d17m00.86s"
                 }
      "vega"     {
                  # Vega Apparente AR: 18h37m25.006s DE:+38°48'14.57" 
                  set ra  "18h37m25.006s"
                  set dec "+38d48m14.57"
                 }
      "arcturus" {
                  # Arcturus 14h16m16.622s DE:+19°06'52.06"
                  set ra  "14h16m16.622s"
                  set dec "+19d06m52.06"
                 }
      "capella"  {
                  # Capella J2000
                  set ra  "5h17m41.458s"
                  set dec "+45d59m46.87"
                 }
      default    {
                  set ra  "0h0m0s"
                  set dec "+90d0m0s"
                 }
   }

   set ra_deg  [mc_angle2deg $ra]
   set dec_deg [mc_angle2deg $dec]
   set hdec [::eqmod::coord_equatorial_to_hour $ra_deg $dec_deg]

   return [list $ra_deg $dec_deg [lindex $hdec 0] [lindex $hdec 1]]

}
