#
# Fichier : av4l_setup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise à jour $Id: av4l_setup.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::av4l_setup {

   #
   # av4l_setup::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_setup.cap ]
   }

   #
   # av4l_setup::initToConf
   # Initialisation des variables de configuration
   #
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,messages) ] }                           { set ::av4l::parametres(av4l,$visuNo,messages)                           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,save_file_log) ] }                      { set ::av4l::parametres(av4l,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,alarme_fin_serie) ] }                   { set ::av4l::parametres(av4l,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier) ] }           { set ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_index_depart) ] }              { set ::av4l::parametres(av4l,$visuNo,verifier_index_depart)              "1" }
   }

   #
   # av4l_setup::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(av4l,$visuNo,messages)                           $::av4l::parametres(av4l,$visuNo,messages)
      set panneau(av4l,$visuNo,save_file_log)                      $::av4l::parametres(av4l,$visuNo,save_file_log)
      set panneau(av4l,$visuNo,alarme_fin_serie)                   $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set panneau(av4l,$visuNo,verifier_ecraser_fichier)           $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set panneau(av4l,$visuNo,verifier_index_depart)              $::av4l::parametres(av4l,$visuNo,verifier_index_depart)
   }

   #
   # av4l_setup::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

      #--- widgetToConf
      set ::av4l::parametres(av4l,$visuNo,messages)                           $panneau(av4l,$visuNo,messages)
      set ::av4l::parametres(av4l,$visuNo,save_file_log)                      $panneau(av4l,$visuNo,save_file_log)
      set ::av4l::parametres(av4l,$visuNo,alarme_fin_serie)                   $panneau(av4l,$visuNo,alarme_fin_serie)
      set ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)           $panneau(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l::parametres(av4l,$visuNo,verifier_index_depart)              $panneau(av4l,$visuNo,verifier_index_depart)
   }

   #
   # av4l_setup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #---
      set panneau(av4l,$visuNo,av4l_setup) $this
      ::confGenerique::run $visuNo "$panneau(av4l,$visuNo,av4l_setup)" "::av4l_setup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(av4l,$visuNo,av4l_setup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # av4l_setup::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc apply { visuNo } {
      ::av4l_setup::widgetToConf $visuNo
   }

   #
   # av4l_setup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_setup.htm
   }

   #
   # av4l_setup::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc closeWindow { visuNo } {
   }

   #
   # av4l_setup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc getLabel { } {
      global caption

      return "$caption(av4l_setup,titre)"
   }

   #
   # av4l_setup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_setup::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]

      #--- Frame pour les commentaires
      frame $panneau(av4l,$visuNo,av4l_setup).frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete.lab -text $caption(av4l_setup,en-tete_fits)
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete.but -text $caption(av4l_setup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(av4l,keywordConfigName)"
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

            #--- Label du nom de la configuration de l'en-tete FITS
            entry $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete.labNom \
               -state readonly -takefocus 0 -textvariable ::conf(av4l,keywordConfigName) -justify center
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete.labNom -side left -padx 6

         pack $panneau(av4l,$visuNo,av4l_setup).frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame4.frame8 -borderwidth 0
               checkbutton $panneau(av4l,$visuNo,av4l_setup).frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte1)" -variable panneau(av4l,$visuNo,messages)
               pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame4.frame8 -side left

         pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 2
         frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame5 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 2
            frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame5.frame10 -borderwidth 0
               checkbutton $panneau(av4l,$visuNo,av4l_setup).frame3.frame5.frame10.check2 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte2)" -variable panneau(av4l,$visuNo,save_file_log)
               pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame5.frame10.check2 -side right -padx 5 -pady 0
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame5.frame10 -side left

         pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame5 -side top -fill both -expand 1

         #--- Frame pour le commentaire 3
         frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame6 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 3
            frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame6.frame12 -borderwidth 0
               checkbutton $panneau(av4l,$visuNo,av4l_setup).frame3.frame6.frame12.check3 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte3)" -variable panneau(av4l,$visuNo,alarme_fin_serie)
               pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame6.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame6.frame12 -side left

         pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame6 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame7.frame12 -borderwidth 0
               checkbutton $panneau(av4l,$visuNo,av4l_setup).frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte4)" -variable panneau(av4l,$visuNo,verifier_ecraser_fichier)
               pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame7.frame12 -side left

         pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame7 -side top -fill both -expand 1

         #--- Frame pour le commentaire 5 : verifier_index_depart
         frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame8 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 5
            frame $panneau(av4l,$visuNo,av4l_setup).frame3.frame8.frame12 -borderwidth 0
               checkbutton $panneau(av4l,$visuNo,av4l_setup).frame3.frame8.frame12.check3 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte5)" -variable panneau(av4l,$visuNo,verifier_index_depart)
               pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame8.frame12.check3 -side right -padx 5 -pady 0
            pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame8.frame12 -side left

         pack $panneau(av4l,$visuNo,av4l_setup).frame3.frame8 -side top -fill both -expand 1


      pack $panneau(av4l,$visuNo,av4l_setup).frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::av4l_setup::init
