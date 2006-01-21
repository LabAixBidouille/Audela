#
# Fichier : viseur_polaire_go.tcl
# Description : Outil proposant 2 types de viseur polaire
# Type Takahashi : Viseur polaire à niveau
# Type EQ6 : Viseur polaire à constellations
# Auteur : Robert DELMAS
# Date de mise a jour : 13 janvier 2006
#

package provide viseur_polaire 1.0

namespace eval ::ViseurPolaire {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_go.cap ]

   proc init { { in "" } } {
      createPanel $in.viseurpolaire
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(menu_name,ViseurPolaire) "$caption(viseur_polaire_go,titre)"
      set panneau(ViseurPolaire,aide)      "$caption(viseur_polaire_go,help_titre)"
      set panneau(ViseurPolaire,taka)      "$caption(viseur_polaire_go,taka)"
      set panneau(ViseurPolaire,eq6)       "$caption(viseur_polaire_go,eq6)"
      ViseurPolaireBuildIF $This
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

proc ViseurPolaireBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,ViseurPolaire) \
            -command {
               ::audace::showHelpPlugin tool viseur_polaire viseur_polaire.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(ViseurPolaire,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du viseur polaire de type Takahashi
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type Takahashi
         button $This.fra2.but1 -borderwidth 2 -text $panneau(ViseurPolaire,taka) \
            -command { 
               source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_taka.tcl ] 
               ::viseurPolaireTaka::run "$audace(base).viseurPolaireTaka"
            }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra2 -side top -fill x

      #--- Frame du viseur polaire de type EQ6
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton d'ouverture du viseur polaire de type EQ6
         button $This.fra3.but1 -borderwidth 2 -text $panneau(ViseurPolaire,eq6) \
            -command { 
               source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_eq6.tcl ]
               ::viseurPolaireEQ6::run "$audace(base).viseurPolaireEQ6"
            }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::ViseurPolaire::init $audace(base)

