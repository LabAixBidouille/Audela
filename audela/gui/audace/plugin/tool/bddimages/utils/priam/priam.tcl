#--------------------------------------------------
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/priam/priam.tcl
#--------------------------------------------------
#
# Fichier        : priam.tcl
# Description    : Utilisation de Priam pour faire l astrometrie
# Auteur         : Frederic Vachier
# Mise à jour $Id: priam.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::priam {






proc ::priam::create_file_oldformat { listsources stars listmesure } {

   global bddconf


   ::manage_source::imprim_3_sources $listsources
   
   set filelocal [file join $bddconf(dirtmp) local.cat]
   # cration du fichier stellaire
   set chan [open $filelocal w]
   puts $chan "ici le local.cat"
   
   set fields  [lindex $listsources 0]
   foreach s $fields { 
         ::console::affiche_resultat "$s\n"
         }
   set newsources {}
   set sources [lindex $listsources 1]
   foreach s $sources {
      foreach cata $s {
         if {[lindex $cata 0] == $stars} {
            foreach u $s {
               if {[lindex $u 0] == "IMG"} {
                  set data [lindex $u 1]
               }
            }
            set ra [lindex $data 0]
            set dec [lindex $data 1]
            puts $chan "$ra|$dec"
         }
      }
   }

   close $chan
}


}
