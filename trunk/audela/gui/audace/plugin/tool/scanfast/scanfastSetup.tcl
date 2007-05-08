#
# Fichier : scanfastSetup.tcl
# Description : Configuration de la temporisation entre l'arret du moteur d'AD et le debut de la pose du scan
# Auteur : Robert DELMAS
# Mise a jour $Id: scanfastSetup.tcl,v 1.2 2007-05-08 16:45:02 robertdelmas Exp $
#

namespace eval scanfastSetup {

   #
   # scanfastSetup::init
   # Chargement des captions et initialisation de variables
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool scanfast scanfastSetup.cap ]
   }

   #
   # scanfastSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::scanfast::parametres(scanfast,delai) ] }  { set ::scanfast::parametres(scanfast,delai)  "3" }
      if { ! [ info exists ::scanfast::parametres(scanfast,active) ] } { set ::scanfast::parametres(scanfast,active) "1" }
   }

   #
   # scanfastSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(scanfast,delai)  $::scanfast::parametres(scanfast,delai)
      set panneau(scanfast,active) $::scanfast::parametres(scanfast,active)
   }

   #
   # scanfastSetup::run this
   # Cree la fenetre de configuration
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # scanfastSetup::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration de la temporisation des scans
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # scanfastSetup::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # scanfastSetup::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      ::audace::showHelpPlugin tool scanfast scanfastSetup.htm
   }

   #
   # scanfastSetup::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # scanfastSetup::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption conf panneau

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_config + 135 ]+[ expr $posy_config + 70 ]
      wm resizable $This 0 0
      wm title $This $caption(scanfastSetup,configuration)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

      #--- Commentaire sur la temporisation
      label $This.lab1 -text "$caption(scanfastSetup,titre)"
      pack $This.lab1 -in $This.frame3 -anchor w -side top -padx 10 -pady 3

      #--- Radio-bouton 'sans temporisation'
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 \
         -text "$caption(scanfastSetup,sans_scan)" -value 0 -variable panneau(scanfast,active)
      pack $This.rad1 -in $This.frame4 -anchor w -side top -padx 30 -pady 3

      #--- Radio-bouton 'avec temporisation'
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 \
         -text "$caption(scanfastSetup,avec_scan)" -value 1 -variable panneau(scanfast,active)
      pack $This.rad2 -in $This.frame4 -anchor w -side top -padx 30 -pady 3

      #--- Cree la zone a renseigner du delai entre l'arret du moteur d'A.D. et le debut de la pose
      label $This.lab3 -text "$caption(scanfastSetup,delai)"
      pack $This.lab3 -in $This.frame5 -anchor w -side left -padx 10 -pady 3

      entry $This.delai -textvariable panneau(scanfast,delai) -width 3 -justify center
      pack $This.delai -in $This.frame5 -anchor w -side left -padx 0 -pady 2

      label $This.lab4 -text "$caption(scanfastSetup,seconde)"
      pack $This.lab4 -in $This.frame5 -anchor w -side left -padx 0 -pady 3

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(scanfastSetup,ok)" -width 7 -borderwidth 2 \
         -command { ::scanfastSetup::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(scanfastSetup,appliquer)" -width 8 -borderwidth 2 \
         -command { ::scanfastSetup::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(scanfastSetup,fermer)" -width 7 -borderwidth 2 \
         -command { ::scanfastSetup::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(scanfastSetup,aide)" -width 7 -borderwidth 2 \
         -command { ::scanfastSetup::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # scanfastSetup::widgetToConf
   # Acquisition de la configuration
   #
   proc widgetToConf { } {
      variable parametres
      global panneau

      set ::scanfast::parametres(scanfast,delai)  $panneau(scanfast,delai)
      set ::scanfast::parametres(scanfast,active) $panneau(scanfast,active)
   }

}

#--- Initialisation au demarrage
::scanfastSetup::init

