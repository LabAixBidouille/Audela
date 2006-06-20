#
# Fichier : supernovae_go.tcl
# Description : Outil pour l'observation des SnAudes
# Auteur : Alain KLOTZ
# Mise a jour $Id: supernovae_go.tcl,v 1.3 2006-06-20 21:28:44 robertdelmas Exp $
#

package provide supernovae 1.0

namespace eval ::Snaude {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool supernovae supernovae_go.cap ]

   proc init { { in "" } } {
      createPanel $in.snaude
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(menu_name,Snaude) "$caption(supernovae_go,supernovae)"
      set panneau(Snaude,aide)      "$caption(supernovae_go,help,titre)"
      set panneau(Snaude,recherche) "$caption(supernovae_go,recherche_sn)"
      set panneau(Snaude,snacq)     "$caption(supernovae_go,sn_acq)"
      set panneau(Snaude,snvisu)    "$caption(supernovae_go,sn_visu)"
      set panneau(Snaude,photom)    "$caption(supernovae_go,photometrie)"

      SnaudeBuildIF $This
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

proc SnaudeBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Snaude) \
            -command {
               ::audace::showHelpPlugin tool supernovae supernovae_go.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Snaude,aide)

      pack $This.fra1 -side top -fill x
      
      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(Snaude,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton Sn Acq
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Snaude,snacq) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snacq.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton Sn Visu
         button $This.fra2.but2 -borderwidth 2 -text $panneau(Snaude,snvisu) \
            -command { source [ file join $audace(rep_plugin) tool supernovae snvisu.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x
      
      #--- Frame de Photometrie
      frame $This.fra3 -borderwidth 1 -relief groove

         label $This.fra3.lab1 -borderwidth 0 -text $panneau(Snaude,photom)
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -expand 1 -fill both -side top

      pack $This.fra3 -side top -fill x
      
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Snaude::init $audace(base)

