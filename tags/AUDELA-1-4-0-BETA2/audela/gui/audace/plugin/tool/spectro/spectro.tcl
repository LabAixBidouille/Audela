#
# Fichier : spectro.tcl
# Description : Outil de traitement d'images de spectro
# Auteur : Alain Klotz
# Mise a jour $Id: spectro.tcl,v 1.15 2007-03-12 19:36:20 robertdelmas Exp $
#

package provide spectro 1.0

namespace eval ::spectro {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool spectro spectro.cap ]

   proc init { { in "" } } {
      global audace

      #--- Chargement des fonctions de spectrographie
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool spectro spcaudace.tcl ]\""
      #--- Mise en place de l'interface graphique
      createPanel $in.spectro
   }

   proc createPanel { this } {
      variable This
      global caption panneau

      #--- Initialisation du nom de la fenetre
      set This $this
      #--- Initialisation des captions
      set panneau(menu_name,spectro)  "$caption(spectro,titre,outil)"
      set panneau(spectro,aide)       "$caption(spectro,help,titre)"
      set panneau(spectro,configure)  "$caption(spectro,configure)"
      set panneau(spectro,spc_audace) "$caption(spectro,spc_audace)"
      #--- Construction de l'interface
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
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,spectro) \
            -command "::audace::showHelpPlugin tool spectro spectro.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(spectro,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame des boutons
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Bouton configurer
         button $This.fra2.but1 -borderwidth 2 -text $panneau(spectro,configure) \
            -command { source [ file join $audace(rep_plugin) tool spectro spectro_configure.tcl ] }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

         #--- Bouton editer un profil
         button $This.fra2.but2 -borderwidth 2 -text $panneau(spectro,spc_audace) \
            -command { source [ file join $audace(rep_plugin) tool spectro spcaudace spc_gui.tcl ] }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

      pack $This.fra2 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::spectro::init $audace(base)
