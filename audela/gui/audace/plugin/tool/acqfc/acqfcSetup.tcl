#
# Fichier : acqfcSetup.tcl
# Description : Choisir l'affichage ou non de messages sur la Console
# Auteur : Robert DELMAS
# Mise a jour $Id: acqfcSetup.tcl,v 1.1 2007-04-11 17:40:36 robertdelmas Exp $
#

namespace eval acqfcSetup {

   #
   # acqfcSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqfc acqfcSetup.cap ]
   }

   #
   # acqfcSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::AcqFC::parametres(AcqFC,$visuNo,messages) ] } { set ::AcqFC::parametres(AcqFC,$visuNo,messages) "1" }
   }

   #
   # acqfcSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(AcqFC,$visuNo,messages) $::AcqFC::parametres(AcqFC,$visuNo,messages)
   }

   #
   # acqfcSetup::run this
   # Cree la fenetre de configuration de l'affichage de messages sur la Console
   # this = chemin de la fenetre
   #
   proc run { visuNo this } {
      variable This

      set This $this
      createDialog $visuNo
      tkwait visibility $This
   }

   #
   # acqfcSetup::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre du choix de l'affichage ou non de messages sur la Console
   #
   proc ok { visuNo } {
      appliquer $visuNo
      fermer
   }

   #
   # acqfcSetup::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { visuNo } {
      widgetToConf $visuNo
   }

   #
   # acqfcSetup::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      ::audace::showHelpPlugin tool acqfc acqfcSetup.htm
   }

   #
   # acqfcSetup::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # acqfcSetup::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { visuNo } {
      variable This
      global audace caption conf panneau

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $This 0 0
      wm title $This $caption(acqfcSetup,titre)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0
      pack $This.frame4 -in $This.frame1 -side left -fill both -expand 1

      frame $This.frame5 -borderwidth 0
      pack $This.frame5 -in $This.frame1 -side right -fill both -expand 1

      frame $This.frame6 -borderwidth 0
      pack $This.frame6 -in $This.frame4 -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0
      pack $This.frame7 -in $This.frame5 -side top -fill both -expand 1

      #--- Cree le label pour les commentaires
      label $This.lab1 -text "$caption(acqfcSetup,texte)"
      pack $This.lab1 -in $This.frame3 -side top -fill both -expand 1 -padx 5 -pady 2

      #--- Cree le label et les radio-boutons de l'outil d'acquisition
      if { [ info exists panneau(menu_name,AcqFC) ] == "1" } {
         label $This.lab3 -text "$panneau(menu_name,AcqFC)"
         pack $This.lab3 -in $This.frame6 -side left -anchor w -padx 5 -pady 5

         radiobutton $This.radio0 -anchor w -highlightthickness 0 \
            -text "$caption(acqfcSetup,non)" -value 0 \
            -variable panneau(AcqFC,$visuNo,messages)
         pack $This.radio0 -in $This.frame7 -side right -padx 5 -pady 5 -ipady 0

         radiobutton $This.radio1 -anchor w -highlightthickness 0 \
            -text "$caption(acqfcSetup,oui)" -value 1 \
            -variable panneau(AcqFC,$visuNo,messages)
         pack $This.radio1 -in $This.frame7 -side right -padx 5 -pady 5 -ipady 0
      } else {
         label $This.lab3 -text " "
         pack $This.lab3 -in $This.frame6 -side left -anchor w -padx 5 -pady 0
         label $This.lab3a -text " "
         pack $This.lab3a -in $This.frame7 -side right -anchor w -padx 5 -pady 0
      }

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(acqfcSetup,ok)" -width 7 -borderwidth 2 \
         -command "::acqfcSetup::ok $visuNo"
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(acqfcSetup,appliquer)" -width 8 -borderwidth 2 \
         -command "::acqfcSetup::appliquer $visuNo"
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label 'Invisible' pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(acqfcSetup,fermer)" -width 7 -borderwidth 2 \
         -command "::acqfcSetup::fermer"
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(acqfcSetup,aide)" -width 7 -borderwidth 2 \
         -command "::acqfcSetup::afficheAide"
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # acqfcSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      set ::AcqFC::parametres(AcqFC,$visuNo,messages) $panneau(AcqFC,$visuNo,messages)
   }
}

#--- Initialisation au demarrage
::acqfcSetup::init

