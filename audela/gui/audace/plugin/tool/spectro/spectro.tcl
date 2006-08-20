#
# Fichier : spectro.tcl
# Description : Panneau de traitement d'images de spectro
# Auteur : Alain Klotz
# Date de mise a jour : 20 aout 2006
#

package provide spectro 1.0

namespace eval ::spectro {
	global audace

	source [ file join $audace(rep_plugin) tool spectro spectro.cap ]

	proc init { { in "" } } {
		createPanel $in.spectro
	}

	proc createPanel { this } {
		variable This
		global panneau
		global caption

		set This $this
      #---
      set panneau(menu_name,spectro) "$caption(spectro,titre,panneau)"
      set panneau(spectro,aide)      "$caption(spectro,help,titre)"
      set panneau(spectro,recherche) " "
      set panneau(spectro,configure)     "Configurer"
      set panneau(spectro,editer_profil)    "Editeur profil"
      set panneau(spectro,lhiresIIIBe)    "LHIRES III Be"
      set panneau(spectro,accesBeSS)    "Accès BeSS"

      spectroBuildIF $This
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

proc spectroBuildIF { This } {
   global audace
   global panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,spectro) \
            -command {
               ::audace::showHelpPlugin tool spectro spectro.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(spectro,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de Recherche
      frame $This.fra2 -borderwidth 1 -relief groove

         label $This.fra2.lab1 -borderwidth 0 -text $panneau(spectro,recherche)
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -expand 1 -fill both -side top

         #--- Bouton configure
         button $This.fra2.but1 -borderwidth 2 -text $panneau(spectro,configure) \
            -command { source [ file join $audace(rep_plugin) tool spectro spectro_configure.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton editer_profil
         button $This.fra2.but2 -borderwidth 2 -text $panneau(spectro,editer_profil) \
            -command { source [ file join $audace(rep_plugin) tool spectro spectro_editer_profil.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton lhiresIIIBe
         button $This.fra2.but3 -borderwidth 2 -text $panneau(spectro,lhiresIIIBe) \
            -command { source [ file join $audace(rep_plugin) tool spectro spectro_lhiresIIIBe.tcl ] }
         pack $This.fra2.but3 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton accesBeSS
         button $This.fra2.but4 -borderwidth 2 -text $panneau(spectro,accesBeSS) \
            -command { source [ file join $audace(rep_plugin) tool spectro spectro_accesBeSS.tcl ] }
         pack $This.fra2.but4 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::spectro::init $audace(base)

