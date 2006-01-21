#
# Fichier : telshift_go.tcl
# Description : Outil pour l'acquisition avec deplacement du telescope entre les poses
# Auteur : Christian JASINSKI
# Date de mise a jour : 13 janvier 2006
#

package provide telshift 1.0

namespace eval ::ImagerDeplacer {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool telshift telshift_go.cap ]

   proc init { { in "" } } {
      createPanel $in.imagerdeplacer
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(menu_name,ImagerDeplacer) "$caption(telshift_go,telshift)"
      set panneau(ImagerDeplacer,aide)      "$caption(telshift_go,help_titre)"
      set panneau(ImagerDeplacer,titre1)    "$caption(telshift_go,acquisition)"
      set panneau(ImagerDeplacer,acq)       "$caption(telshift_go,acq)"
      ImagerDeplacerBuildIF $This
   }

   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
   }

   proc stopTool { visuNo } {
      variable This

      pack forget $This
   }

}

proc ImagerDeplacerBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,ImagerDeplacer) \
            -command {
               ::audace::showHelpPlugin tool telshift telshift.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(ImagerDeplacer,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du bouton
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du bouton
         label $This.fra2.lab1 -borderwidth 0 -text $panneau(ImagerDeplacer,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton AcqVisu
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ImagerDeplacer,acq) \
            -command { source [ file join $audace(rep_plugin) tool telshift telshift.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 10 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::ImagerDeplacer::init $audace(base)

