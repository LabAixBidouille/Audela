#
# Fichier : pretrfcSetup.tcl
# Description : Choisir l'affichage ou non de messages sur la Console
# Auteur : Robert DELMAS
# Mise a jour $Id: pretrfcSetup.tcl,v 1.7 2007-09-09 19:30:36 robertdelmas Exp $
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
      if { ! [ info exists conf_pt_fc(messages) ] }      { set conf_pt_fc(messages)      "1" }
      if { ! [ info exists conf_pt_fc(save_file_log) ] } { set conf_pt_fc(save_file_log) "1" }
   }

   #
   # pretrfcSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { } {
      global conf_pt_fc panneau

      #--- confToWidget
      set panneau(pretrfc,messages)      $conf_pt_fc(messages)
      set panneau(pretrfc,save_file_log) $conf_pt_fc(save_file_log)
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
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::pretrfc::getPluginType ] ] pretrfc pretrfcSetup.htm
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
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0
      pack $This.frame5 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame6 -borderwidth 0
      pack $This.frame6 -in $This.frame3 -side right -fill both -expand 1

      frame $This.frame7 -borderwidth 0
      pack $This.frame7 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0
      pack $This.frame8 -in $This.frame4 -side right -fill both -expand 1

      #--- Cree le label pour le commentaire 1
      label $This.lab1 -text "$caption(pretrfcSetup,texte1)"
      pack $This.lab1 -in $This.frame5 -side left -fill both -expand 0 -padx 5 -pady 5

      #--- Cree le checkbutton pour le commentaire 1
      checkbutton $This.check1 -highlightthickness 0 -variable panneau(pretrfc,messages)
      pack $This.check1 -in $This.frame6 -side right -padx 5 -pady 0

      #--- Cree le label pour le commentaire 2
      label $This.lab2 -text "$caption(pretrfcSetup,texte2)"
      pack $This.lab2 -in $This.frame7 -side left -fill both -expand 0 -padx 5 -pady 5

      #--- Cree le checkbutton pour le commentaire 2
      checkbutton $This.check2 -highlightthickness 0 -variable panneau(pretrfc,save_file_log)
      pack $This.check2 -in $This.frame8 -side right -padx 5 -pady 0

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
      label $This.lab_invisible -width 7
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

      set conf_pt_fc(messages)      $panneau(pretrfc,messages)
      set conf_pt_fc(save_file_log) $panneau(pretrfc,save_file_log)
   }
}

#--- Initialisation au demarrage
::pretrfcSetup::init

