#
# Fichier : obj_lune_go.tcl
# Description : Outil de lancement d'Objectif Lune
# Auteur : Robert DELMAS
# Date de mise a jour : 18 juin 2005
#

package provide obj_lune 1.0

namespace eval ::Obj_Lune_Go {
   variable This
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
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(Obj_Lune_Go,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(Obj_Lune_Go,largeur_outil) "130"
      } else {
         set panneau(Obj_Lune_Go,largeur_outil) "101"
      }
      #---
      set panneau(menu_name,Obj_Lune_Go) "$caption(obj_lune_go,obj_lune)"
      set panneau(Obj_Lune_Go,aide)      "$caption(obj_lune_go,help_titre)"
      set panneau(Obj_Lune_Go,execute)   "$caption(obj_lune_go,executer)"
      Obj_Lune_GoBuildIF $This
   }

   proc pack { } {
      variable This
      global unpackFunction

      set unpackFunction ::Obj_Lune_Go::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
   }

   proc unpack { } {
      variable This

      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }

}

proc Obj_Lune_GoBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(Obj_Lune_Go,largeur_outil)

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Obj_Lune_Go) \
            -command {
               ::audace::showHelpPlugin tool obj_lune obj_lune.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $This.fra1.but -text $panneau(Obj_Lune_Go,aide)

      place $This.fra1 -x 4 -y 4 -height 22 -width [ expr $panneau(Obj_Lune_Go,largeur_outil) - 6 ] -anchor nw \
         -bordermode ignore

      #--- Frame du bouton de lancement
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton Execute
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Obj_Lune_Go,execute) \
            -command {
               source [ file join $audace(rep_plugin) tool obj_lune obj_lune.tcl ] 
               ::obj_Lune::run
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -padx 5 -pady 5 -ipadx 5 -ipady 5

      place $This.fra2 -x 4 -y 32 -height 42 -width [ expr $panneau(Obj_Lune_Go,largeur_outil) - 6 ] -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Obj_Lune_Go::init $audace(base)

