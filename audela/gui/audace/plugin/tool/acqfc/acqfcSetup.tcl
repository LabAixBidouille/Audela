#
# Fichier : acqfcSetup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise a jour $Id: acqfcSetup.tcl,v 1.4 2007-09-09 17:04:44 robertdelmas Exp $
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
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,messages) ] }      { set ::acqfc::parametres(acqfc,$visuNo,messages)      "1" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,save_file_log) ] } { set ::acqfc::parametres(acqfc,$visuNo,save_file_log) "1" }
   }

   #
   # acqfcSetup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(acqfc,$visuNo,messages)      $::acqfc::parametres(acqfc,$visuNo,messages)
      set panneau(acqfc,$visuNo,save_file_log) $::acqfc::parametres(acqfc,$visuNo,save_file_log)
   }

   #
   # acqfcSetup::run visuNo this
   # Cree la fenetre de configuration de l'affichage de messages sur la Console
   # this = chemin de la fenetre
   #
   proc run { visuNo this } {
      global panneau

      set panneau(acqfc,$visuNo,acqfcSetup) $this
      createDialog $visuNo
      tkwait visibility $panneau(acqfc,$visuNo,acqfcSetup)
   }

   #
   # acqfcSetup::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre du choix de l'affichage ou non de messages sur la Console
   #
   proc ok { visuNo } {
      appliquer $visuNo
      fermer $visuNo
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
   proc fermer { visuNo } {
      global panneau

      destroy $panneau(acqfc,$visuNo,acqfcSetup)
   }

   #
   # acqfcSetup::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { visuNo } {
      global audace caption conf panneau

      #---
      if { [winfo exists $panneau(acqfc,$visuNo,acqfcSetup)] } {
         wm withdraw $panneau(acqfc,$visuNo,acqfcSetup)
         wm deiconify $panneau(acqfc,$visuNo,acqfcSetup)
         focus $panneau(acqfc,$visuNo,acqfcSetup)
         return
      }

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #--- Cree la fenetre $panneau(acqfc,$visuNo,acqfcSetup) de niveau le plus haut
      toplevel $panneau(acqfc,$visuNo,acqfcSetup) -class Toplevel
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(acqfc,$visuNo,acqfcSetup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $panneau(acqfc,$visuNo,acqfcSetup) 0 0
      wm title $panneau(acqfc,$visuNo,acqfcSetup) "$caption(acqfcSetup,titre) (visu$visuNo)"

      #--- Creation des differents frames
      frame $panneau(acqfc,$visuNo,acqfcSetup).frame1 -borderwidth 1 -relief raised
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame1 -side top -fill both -expand 1

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame2 -borderwidth 1 -relief raised
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame2 -side top -fill x

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame3 -borderwidth 0
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame3 -in $panneau(acqfc,$visuNo,acqfcSetup).frame1 \
         -side top -fill both -expand 1

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame4 -borderwidth 0
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame4 -in $panneau(acqfc,$visuNo,acqfcSetup).frame1 \
         -side top -fill both -expand 1

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame5 -borderwidth 0
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame5 -in $panneau(acqfc,$visuNo,acqfcSetup).frame3 \
         -side left -fill both -expand 1

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame6 -borderwidth 0
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame6 -in $panneau(acqfc,$visuNo,acqfcSetup).frame3 \
         -side right -fill both -expand 1

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame7 -borderwidth 0
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame7 -in $panneau(acqfc,$visuNo,acqfcSetup).frame4 \
         -side left -fill both -expand 1

      frame $panneau(acqfc,$visuNo,acqfcSetup).frame8 -borderwidth 0
      pack $panneau(acqfc,$visuNo,acqfcSetup).frame8 -in $panneau(acqfc,$visuNo,acqfcSetup).frame4 \
         -side right -fill both -expand 1

      #--- Cree le label pour le commentaire 1
      label $panneau(acqfc,$visuNo,acqfcSetup).lab1 -text "$caption(acqfcSetup,texte1)"
      pack $panneau(acqfc,$visuNo,acqfcSetup).lab1 -in $panneau(acqfc,$visuNo,acqfcSetup).frame5 \
         -side left -fill both -expand 0 -padx 5 -pady 5

      #--- Cree le checkbutton pour le commentaire 1
      checkbutton $panneau(acqfc,$visuNo,acqfcSetup).check1 -highlightthickness 0 \
         -variable panneau(acqfc,$visuNo,messages)
      pack $panneau(acqfc,$visuNo,acqfcSetup).check1 -in $panneau(acqfc,$visuNo,acqfcSetup).frame6 \
         -side right -padx 5 -pady 0

      #--- Cree le label pour le commentaire 2
      label $panneau(acqfc,$visuNo,acqfcSetup).lab2 -text "$caption(acqfcSetup,texte2)"
      pack $panneau(acqfc,$visuNo,acqfcSetup).lab2 -in $panneau(acqfc,$visuNo,acqfcSetup).frame7 \
         -side left -fill both -expand 0 -padx 5 -pady 5

      #--- Cree le checkbutton pour le commentaire 2
      checkbutton $panneau(acqfc,$visuNo,acqfcSetup).check2 -highlightthickness 0 \
         -variable panneau(acqfc,$visuNo,save_file_log)
      pack $panneau(acqfc,$visuNo,acqfcSetup).check2 -in $panneau(acqfc,$visuNo,acqfcSetup).frame8 \
         -side right -padx 5 -pady 0

      #--- Cree le bouton 'OK'
      button $panneau(acqfc,$visuNo,acqfcSetup).but_ok -text "$caption(acqfcSetup,ok)" -width 7 -borderwidth 2 \
         -command "::acqfcSetup::ok $visuNo"
      if { $conf(ok+appliquer) == "1" } {
         pack $panneau(acqfc,$visuNo,acqfcSetup).but_ok -in $panneau(acqfc,$visuNo,acqfcSetup).frame2 \
            -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $panneau(acqfc,$visuNo,acqfcSetup).but_appliquer -text "$caption(acqfcSetup,appliquer)" -width 8 \
         -borderwidth 2 -command "::acqfcSetup::appliquer $visuNo"
      pack $panneau(acqfc,$visuNo,acqfcSetup).but_appliquer -in $panneau(acqfc,$visuNo,acqfcSetup).frame2 \
         -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label 'Invisible' pour simuler un espacement
      label $panneau(acqfc,$visuNo,acqfcSetup).lab_invisible -width 7
      pack $panneau(acqfc,$visuNo,acqfcSetup).lab_invisible -in $panneau(acqfc,$visuNo,acqfcSetup).frame2 \
         -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $panneau(acqfc,$visuNo,acqfcSetup).but_fermer -text "$caption(acqfcSetup,fermer)" -width 7 -borderwidth 2 \
         -command "::acqfcSetup::fermer $visuNo"
      pack $panneau(acqfc,$visuNo,acqfcSetup).but_fermer -in $panneau(acqfc,$visuNo,acqfcSetup).frame2 \
         -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $panneau(acqfc,$visuNo,acqfcSetup).but_aide -text "$caption(acqfcSetup,aide)" -width 7 -borderwidth 2 \
         -command "::acqfcSetup::afficheAide"
      pack $panneau(acqfc,$visuNo,acqfcSetup).but_aide -in $panneau(acqfc,$visuNo,acqfcSetup).frame2 \
         -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $panneau(acqfc,$visuNo,acqfcSetup)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $panneau(acqfc,$visuNo,acqfcSetup) <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqfc,$visuNo,acqfcSetup)
   }

   #
   # acqfcSetup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::acqfc::parametres(acqfc,$visuNo,messages)      $panneau(acqfc,$visuNo,messages)
      set ::acqfc::parametres(acqfc,$visuNo,save_file_log) $panneau(acqfc,$visuNo,save_file_log)
   }
}

#--- Initialisation au demarrage
::acqfcSetup::init

