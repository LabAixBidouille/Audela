#
# Fichier : aud_menu_6.tcl
# Description : Script regroupant les fonctionnalites du menu Outils
# Mise à jour $Id$
#

namespace eval ::audace {
}

   #
   # pasOutil
   # Efface l'interface graphique de l'outil affichee dans la visu
   #
   proc ::audace::pasOutil { visuNo } {
      variable private
      global audace

      if { $::confVisu::private($visuNo,currentTool) != "" } {
         set private(currentTool) $::confVisu::private($visuNo,currentTool)
         ::confVisu::stopTool $visuNo
         set ::confVisu::private($visuNo,currentTool) ""
      } else {
         #--- Je relance automatiquement l'outil currentTool
         ::confVisu::selectTool $visuNo $private(currentTool)
      }
   }

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

   #
   # afficheOutilF2
   # Affiche automatiquement au demarrage l'outil ayant F2 pour raccourci
   #
   proc ::audace::afficheOutilF2 { } {
      global audace conf

      foreach { namespace affiche_raccourci } $conf(outilsActifsInactifs) {
         set raccourci [ lindex $affiche_raccourci 1 ]
         if { $raccourci == "F2" } {
            #--- Lancement automatique de l'outil ayant le raccourci F2
            ::confVisu::selectTool $audace(visuNo) ::$namespace
         }
      }
   }

############################# Fin du namespace audace #############################

