#
# Fichier : pretrfcSetup.tcl
# Description : Choisir l'affichage ou non de messages sur la Console
# Auteur : Robert DELMAS
# Mise a jour $Id: pretrfcSetup.tcl,v 1.1 2007-04-11 18:04:26 robertdelmas Exp $
#

namespace eval pretrfcSetup {

   #
   # pretrfcSetup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool pretrfc pretrfcSetup.cap ]
   }

   #
   # pretrfcSetup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { } {
      global conf_pt_fc

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists conf_pt_fc(pretrfc,messages) ] } { set conf_pt_fc(pretrfc,messages) "1" }
   }

   #
   # pretrfcSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { } {
      global conf_pt_fc panneau

      #--- confToWidget
      set panneau(pretrfc,messages) $conf_pt_fc(pretrfc,messages)
   }

   #
   # pretrfcSetup::run this
   # Cree la fenetre de configuration de l'affichage de messages sur la Console
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # pretrfcSetup::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre du choix de l'affichage ou non de messages sur la Console
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # pretrfcSetup::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # pretrfcSetup::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1090msg_console.htm"
   }

   #
   # pretrfcSetup::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # pretrfcSetup::createDialog
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
      set posx_config [ lindex [ split [ wm geometry $audace(base).fenetrePretr ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $audace(base).fenetrePretr ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_config + 40 ]+[ expr $posy_config + 390 ]
      wm resizable $This 0 0
      wm title $This $caption(pretrfcSetup,titre)

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
      label $This.lab1 -text "$caption(pretrfcSetup,texte)"
      pack $This.lab1 -in $This.frame3 -side top -fill both -expand 1 -padx 5 -pady 2

      #--- Cree le label et les radio-boutons de l'outil de pretraitement
      if { [ info exists panneau(menu_name,pretraitFC) ] == "1" } {
         label $This.lab4 -text "$panneau(menu_name,pretraitFC)"
         pack $This.lab4 -in $This.frame6 -side left -anchor w -padx 5 -pady 5

         radiobutton $This.radio2 -anchor w -highlightthickness 0 \
            -text "$caption(pretrfcSetup,non)" -value 0 \
            -variable panneau(pretrfc,messages)
         pack $This.radio2 -in $This.frame7 -side right -padx 5 -pady 5 -ipady 0

         radiobutton $This.radio3 -anchor w -highlightthickness 0 \
            -text "$caption(pretrfcSetup,oui)" -value 1 \
            -variable panneau(pretrfc,messages)
         pack $This.radio3 -in $This.frame7 -side right -padx 5 -pady 5 -ipady 0
      } else {
         label $This.lab4 -text ""
         pack $This.lab4 -in $This.frame6 -side left -anchor w -padx 5 -pady 0
         label $This.lab4a -text ""
         pack $This.lab4a -in $This.frame7 -side right -anchor w -padx 5 -pady 0
      }

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(pretrfcSetup,ok)" -width 7 -borderwidth 2 \
         -command { ::pretrfcSetup::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(pretrfcSetup,appliquer)" -width 8 -borderwidth 2 \
         -command { ::pretrfcSetup::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label 'Invisible' pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(pretrfcSetup,fermer)" -width 7 -borderwidth 2 \
         -command { ::pretrfcSetup::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(pretrfcSetup,aide)" -width 7 -borderwidth 2 \
         -command { ::pretrfcSetup::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # pretrfcSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf_pt_fc panneau

      set conf_pt_fc(pretrfc,messages) $panneau(pretrfc,messages)
   }
}

#--- Initialisation au demarrage
::pretrfcSetup::init

