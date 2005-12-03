#
# Fichier : telshift_go.tcl
# Description : Outil pour observation avec shift de telescope entre les poses
# Auteur : Christian JASINSKI
# Date de mise a jour : 18 juin 2005
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
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(ImagerDeplacer,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(ImagerDeplacer,largeur_outil) "130"
      } else {
         set panneau(ImagerDeplacer,largeur_outil) "101"
      }
      #---
      set panneau(menu_name,ImagerDeplacer) "$caption(telshift_go,telshift)"
      set panneau(ImagerDeplacer,aide)      "$caption(telshift_go,help_titre)"
      set panneau(ImagerDeplacer,titre1)    "$caption(telshift_go,acquisition)"
      set panneau(ImagerDeplacer,acq)       "$caption(telshift_go,acq)"
      ImagerDeplacerBuildIF $This
   }

   proc pack { } {
      variable This
      global unpackFunction

      set unpackFunction ::ImagerDeplacer::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
   }

   proc unpack { } {
      variable This

      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }

}

proc ImagerDeplacerBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(ImagerDeplacer,largeur_outil)

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,ImagerDeplacer) \
            -command {
               ::audace::showHelpPlugin tool telshift telshift.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $This.fra1.but -text $panneau(ImagerDeplacer,aide)

      place $This.fra1 -x 4 -y 4 -height 22 -width [ expr $panneau(ImagerDeplacer,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Frame du bouton
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du bouton
         label $This.fra2.lab1 -borderwidth 0 -text $panneau(ImagerDeplacer,titre1)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton AcqVisu
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ImagerDeplacer,acq) \
            -command { source [ file join $audace(rep_plugin) tool telshift telshift.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 10 -ipadx 5 -ipady 5

      place $This.fra2 -x 4 -y 32 -height 80 -width [ expr $panneau(ImagerDeplacer,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::ImagerDeplacer::init $audace(base)

