#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_ocr.tcl
#--------------------------------------------------
#
# Fichier        : av4l_ocr.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frederic Vachier
# Mise à jour $Id: av4l_ocr.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::av4l_ocr {


   #
   # av4l_ocr::init
   # Chargement des captions
   #
   proc ::av4l_ocr::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_ocr.cap ]
   }

   #
   # av4l_ocr::initToConf
   # Initialisation des variables de configuration
   #
   proc ::av4l_ocr::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,messages) ] }                           { set ::av4l::parametres(av4l,$visuNo,messages)                           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,save_file_log) ] }                      { set ::av4l::parametres(av4l,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,alarme_fin_serie) ] }                   { set ::av4l::parametres(av4l,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier) ] }           { set ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_index_depart) ] }              { set ::av4l::parametres(av4l,$visuNo,verifier_index_depart)              "1" }
   }

   #
   # av4l_ocr::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc ::av4l_ocr::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_ocr::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_ocr::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_ocr::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_ocr::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_ocr::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)
   }

   #
   # av4l_ocr::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::av4l_ocr::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }


   #
   # av4l_ocr::run 
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::av4l_ocr::run { visuNo this } {
     global audace panneau


      set panneau(av4l,$visuNo,av4l_ocr) $this
      #::confGenerique::run $visuNo "$panneau(av4l,$visuNo,av4l_ocr)" "::av4l_ocr" -modal 1

      ::av4l_ocr::createdialog $this $visuNo   

   }


   #
   # av4l_ocr::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::av4l_ocr::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_ocr.htm
   }


   #
   # av4l_ocr::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::av4l_ocr::closeWindow { this visuNo } {

      ::av4l_ocr::widgetToConf $visuNo
      destroy $this
   }

   #
   # av4l_ocr::getLabel
   # Retourne le nom de la fenetre d extraction
   #
   proc ::av4l_ocr::getLabel { } {
      global caption

      return "$caption(av4l_ocr,bar_title)"
   }



   proc ::av4l_ocr::run_fits { this visuNo base } {

     set ::av4l_tools::traitement "fits"
     ::av4l_ocr_gui::run  $visuNo $base.av4l_ocr_gui 
     ::av4l_ocr::closeWindow $this $visuNo
   }

   proc ::av4l_ocr::run_avi { this visuNo base } {

      set ::av4l_tools::traitement "avi"
     ::av4l_ocr_gui::run  $visuNo $base.av4l_ocr_gui
     ::av4l_ocr::closeWindow $this $visuNo
   }


   #
   # av4l_ocr::fillConfigPage
   # Creation de l'interface graphique
   #
   proc ::av4l_ocr::createdialog { this visuNo } {

      package require Img

      global caption panneau av4lconf color audace

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #--- Creation de la fenetre
      if { [winfo exists $this] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }
      toplevel $this -class Toplevel

      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $this +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $this 1 1
      wm title $this $caption(av4l_ocr,bar_title)
      wm protocol $this WM_DELETE_WINDOW "::av4l_ocr::closeWindow $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_ocr::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_ocr_fits

      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "$caption(av4l_ocr,titre)"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3


        #--- Cree un frame pour les 2 actions de traitement
        frame $frm.traitement -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement -in $frm -side top -expand 0 -fill x -padx 1 -pady 1



        #--- Creation du traitement cdl par liste de fits
        frame $frm.traitement.fits -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement.fits -in $frm.traitement -side left -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton
           image create photo .visu -format PNG -file [ file join $audace(rep_plugin) tool av4l img bouton_visu.png ]
           button $frm.traitement.fits.ico -image .visu\
              -borderwidth 2 -width 130 -height 130 -compound center \
              -command "::av4l_ocr::run_fits $this $visuNo $base"
           pack $frm.traitement.fits.ico \
              -in $frm.traitement.fits \
              -side top -anchor w \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add  $frm.traitement.fits.ico -text "Traitement par lot d'images"


        #--- Creation du traitement cdl par  avi
        frame $frm.traitement.avi -borderwidth 1 -relief raised -cursor arrow
        pack $frm.traitement.avi -in $frm.traitement -side right -expand 0 -fill x -padx 1 -pady 1


           #--- Creation du bouton
           image create photo .video -format PNG -file [ file join $audace(rep_plugin) tool av4l img bouton_video.png ]
           button $frm.traitement.avi.ico -image .video\
              -borderwidth 2 -width 130 -height 130 -compound center \
              -command "::av4l_ocr::run_avi $this $visuNo $base"
           pack $frm.traitement.avi.ico \
              -in $frm.traitement.avi \
              -side left -anchor w \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0
           DynamicHelp::add  $frm.traitement.avi.ico -text "Traitement direct de la video"




   #---
        #--- Cree un frame pour  les boutons d action 
        frame $frm.action \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(av4l_ocr,fermer)" -borderwidth 2 \
              -command "::av4l_ocr::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(av4l_ocr,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool av4l av4l_ocr.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0





   }

}


#--- Initialisation au demarrage
::av4l_ocr::init
