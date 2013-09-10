# * Initial author : Fred Vachier <fv@imcce.fr>
#   avec l aide et conseil de Alain KLOTZ <alain.klotz@free.fr>

# source /srv/develop/audela/src/libtel/libeqmod/extra/src/lowlevel_funcs.tcl

namespace eval eqmod_move {



   proc ::eqmod_move::move_to_north_pole_counterweight_bottom { } {

      move_to_coord_celestial -90 90

      # move_to_coord_mount 0 90

   }

   proc ::eqmod_move::move_to_north_pole_counterweight_east { } {

      set r [celestial_to_mount -180 90]
      set hm [lindex $r 0]
      set dm [lindex $r 1]

      move_to_coord_mount $hm $dm

      # move_to_coord_mount 90 90

   }

   proc ::eqmod_move::move_to_north_pole_counterweight_west { } {

      set r [celestial_to_mount 0 90]
      set hm [lindex $r 0]
      set dm [lindex $r 1]

      move_to_coord_mount $hm $dm

      # move_to_coord_mount -90 90

   }


   proc ::eqmod_move::move_to_east { } {

      set r [celestial_to_mount -90 180]
      set hm [lindex $r 0]
      set dm [lindex $r 1]

      move_to_coord_mount $hm $dm

      # move_to_coord_mount 0 0

   }

   proc ::eqmod_move::move_to_east2 { } {

      set r [celestial_to_mount 90 0]
      set hm [lindex $r 0]
      set dm [lindex $r 1]

      move_to_coord_mount $hm $dm

      # move_to_coord_mount -180 180

   }

   proc ::eqmod_move::move_to_west { } {

      set r [celestial_to_mount -90 0]
      set hm [lindex $r 0]
      set dm [lindex $r 1]

      move_to_coord_mount $hm $dm

      #move_to_coord_mount 0 180

   }

   proc ::eqmod_move::move_to_west2 { } {

      set r [celestial_to_mount -270 180]
      set hm [lindex $r 0]
      set dm [lindex $r 1]

      move_to_coord_mount $hm $dm

      #move_to_coord_mount 180 0

   }

   proc ::eqmod_move::move_to_south { } {

      set l [lindex $::eqmod::home 3]
      ::console::affiche_resultat "Lat : $l\n"
      set de2 [expr 180 + $l]

      move_to_coord_mount -90 $de2

   }

   proc ::eqmod_move::move_to_zenith { } {

      set l [lindex $::eqmod::home 3]
      set de2 [expr 90 + $l]
      move_to_coord_mount -90 $de2

   }

   proc ::eqmod_move::move_to_north { } {

      set l [lindex $::eqmod::home 3]
      move_to_coord_mount -90 $l
   }

   proc ::eqmod_move::move_to_equator_south { } {

      move_to_coord_mount -90 180

   }

   proc ::eqmod_move::move_to_equator_south_m1H { } {

      move_to_coord_mount -75 180

   }
   proc ::eqmod_move::move_to_equator_south_p1H { } {

      move_to_coord_mount -105 180

   }


}
