#
# Fichier : obj_lune_go.tcl
# Description : Outil pour le lancement d'Objectif Lune
# Auteur : Robert DELMAS
# Mise a jour $Id: obj_lune_go.tcl,v 1.5 2007-01-20 10:09:05 robertdelmas Exp $
#

package provide obj_lune 1.0

namespace eval ::Obj_Lune_Go {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool obj_lune obj_lune_go.cap ]

   proc init { { in "" } } {
      createPanel $in.obj_lune_go
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(menu_name,Obj_Lune_Go) "$caption(obj_lune_go,obj_lune)"
      set panneau(Obj_Lune_Go,aide)      "$caption(obj_lune_go,help_titre)"
      set panneau(Obj_Lune_Go,execute)   "$caption(obj_lune_go,executer)"
      Obj_Lune_GoBuildIF $This
   }

   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
      #--- Chargement du package Img pour visualiser les cartes de la Lune au format jpg
      package require Img 1.3
   }

   proc stopTool { visuNo } {
      variable This

      pack forget $This
   }

}

proc Obj_Lune_GoBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Obj_Lune_Go) \
            -command {
               ::audace::showHelpPlugin tool obj_lune obj_lune.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Obj_Lune_Go,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du bouton de lancement
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton Execute
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Obj_Lune_Go,execute) \
            -command {
               source [ file join $audace(rep_plugin) tool obj_lune obj_lune.tcl ] 
               ::obj_Lune::run
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -padx 5 -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Obj_Lune_Go::init $audace(base)

