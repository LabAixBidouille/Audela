#
# Fichier : photometry.tcl
# Description : Panneau de traitement d'images de photometrie
# Auteur : Alain Klotz
# Date de mise a jour : 27 mai 2006
#

package provide photometry 1.0

namespace eval ::photometry {
	global audace

	source [ file join $audace(rep_plugin) tool photometry photometry.cap ]

	proc init { { in "" } } {
		createPanel $in.photometry
	}

	proc createPanel { this } {
		variable This
		global panneau
		global caption

		set This $this
      #---
      set panneau(menu_name,photometry) "$caption(photometry,titre,panneau)"
      set panneau(photometry,aide)      "$caption(photometry,help,titre)"
      set panneau(photometry,recherche) " 2 ou 3 couleurs"
      set panneau(photometry,configure)     "Configurer"
      set panneau(photometry,prepare)    "Préparer"
      set panneau(photometry,calibre)    "Caibrer"
      set panneau(photometry,mesure)    "Mesurer"

      photometryBuildIF $This
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

proc photometryBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,photometry) \
            -command {
               ::audace::showHelpPlugin tool supernovae supernovae_go.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(photometry,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(photometry,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton configure
         button $This.fra2.but1 -borderwidth 2 -text $panneau(photometry,configure) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_configure.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton prepare
         button $This.fra2.but2 -borderwidth 2 -text $panneau(photometry,prepare) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_prepare.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton calibre
         button $This.fra2.but3 -borderwidth 2 -text $panneau(photometry,calibre) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_calibre.tcl ] }
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton mesure
         button $This.fra2.but4 -borderwidth 2 -text $panneau(photometry,mesure) \
            -command { source [ file join $audace(rep_plugin) tool photometry photometry_mesure.tcl ] }
         pack $This.fra2.but4 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::photometry::init $audace(base)

