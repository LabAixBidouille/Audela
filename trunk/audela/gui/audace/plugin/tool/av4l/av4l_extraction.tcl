#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_extraction.tcl
#--------------------------------------------------
#
# Fichier        : av4l_extraction.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: av4l_extraction.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::av4l_extraction {


   #
   # av4l_extraction::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_extraction.cap ]
   }

   #
   # av4l_extraction::initToConf
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
   # av4l_extraction::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_extraction::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_extraction::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_extraction::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_extraction::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_extraction::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)
   }

   #
   # av4l_extraction::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

   }


   #
   # av4l_extraction::run 
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

      set panneau(av4l,$visuNo,av4l_extraction) $this
      ::confGenerique::run $visuNo "$panneau(av4l,$visuNo,av4l_extraction)" "::av4l_extraction" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(av4l,$visuNo,av4l_extraction) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # av4l_extraction::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc apply { visuNo } {
      ::av4l_extraction::widgetToConf $visuNo
   }

   #
   # av4l_extraction::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_extraction.htm
   }


   #
   # av4l_extraction::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc closeWindow { visuNo } {

      ::av4l_tools::avi_close

   }

   #
   # av4l_extraction::getLabel
   # Retourne le nom de la fenetre d extraction
   #
   proc getLabel { } {
      global caption

      return "$caption(av4l_extraction,titre)"
   }




   #
   # av4l_extraction::fillConfigPage
   # Creation de l'interface graphique
   #
   proc fillConfigPage { frm visuNo } {
      global caption panneau av4lconf color audace

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_extraction::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]
      set base $panneau(av4l,$visuNo,av4l_extraction)
      set frm $panneau(av4l,$visuNo,av4l_extraction).frmextraction
      set frmbbar $panneau(av4l,$visuNo,av4l_extraction).frmextractionbar


      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $base -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "$caption(av4l_extraction,titre)"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3

        #--- Cree un frame pour 
        frame $frm.open \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.open \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1
        #--- Creation du bouton open
        button $frm.open.but_open \
           -text "open" -borderwidth 2 \
           -command "::av4l_tools::avi_open $visuNo $frm"
        pack $frm.open.but_open \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton select
        button $frm.open.but_select \
           -text "..." -borderwidth 2 -takefocus 1 \
           -command "::av4l_tools::avi_select $visuNo $frm"
        pack $frm.open.but_select \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un label pour le chemin de l'AVI
        entry $frm.open.avipath 
        pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

        #--- Creation de la barre de defilement
        scale $frm.percent -from 0 -to 100 -length 600 -variable pc \
           -label Percentage -tickinterval 10 -orient horizontal \
           -state disabled
        pack $frm.percent -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

        #--- Cree un frame pour afficher
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

        #--- Creation du bouton quick prev image
        image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool av4l img arr.png ]
        button $frm.qprevimage -image .arr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command ""
        pack $frm.qprevimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool av4l img arn.png ]
        button $frm.previmage -image .arn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command ""
        pack $frm.previmage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool av4l img avn.png ]
        button $frm.nextimage -image .avn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_tools::avi_next_image"
        pack $frm.nextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool av4l img avr.png ]
        button $frm.qnextimage -image .avr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command ""
        pack $frm.qnextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton setmin
        button $frm.setmin \
           -text "setmin" -borderwidth 2 \
           -command { ::av4l_tools::avi_setmin  }
        pack $frm.setmin \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton setmax
        button $frm.setmax \
           -text "setmax" -borderwidth 2 \
           -command { ::av4l_tools::avi_setmax  }
        pack $frm.setmax \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


        #--- Cree un frame pour 
        frame $frm.pos \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.pos \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Cree un frame pour afficher
          frame $frm.pos.min -borderwidth 0
          pack $frm.pos.min -in $frm.pos -side left
            #--- Cree un label pour
            entry $frm.datemin -fg $color(blue) -relief sunken
            pack $frm.datemin -in $frm.pos.min -side top -pady 1 -anchor w
            #--- Cree un label pour
            entry $frm.posmin -fg $color(blue) -relief sunken
            pack $frm.posmin -in $frm.pos.min -side top -pady 1 -anchor w


          #--- Cree un frame pour afficher
          frame $frm.pos.max -borderwidth 0
          pack $frm.pos.max -in $frm.pos -side left
            #--- Cree un label pour
            entry $frm.datemax -fg $color(blue) -relief sunken
            pack $frm.datemax -in $frm.pos.max -side top -pady 1 -anchor w
            #--- Cree un label pour
            entry $frm.posmax -fg $color(blue) -relief sunken
            pack $frm.posmax -in $frm.pos.max -side top -pady 1 -anchor w

          #--- Cree un frame pour afficher
          frame $frm.count -borderwidth 0
          pack $frm.count -in $frm -side top
            #--- Cree un label pour
            button $frm.doimagecount \
             -text "count" -borderwidth 2 \
             -command { ::av4l_tools::avi_imagecount  }
            pack $frm.doimagecount -in $frm.count -side left -pady 1 -anchor w
            #--- Cree un label pour
            entry $frm.imagecount -fg $color(blue) -relief sunken
            pack $frm.imagecount -in $frm.count -side left -pady 1 -anchor w

        #--- Cree un frame pour 
        frame $frm.status \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.status \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

        #--- Cree un label pour
        #label $frm.statusbdd -font $av4lconf(font,arial_12_b) \
        #     -text "LBL $caption(av4l_extraction,label_bdd)"
        #pack $frm.statusbdd -in $frm.status -side top -padx 3 -pady 1 -anchor w


          #--- Cree un frame pour afficher les intitules
          set intitle [frame $frm.status.l -borderwidth 0]
          pack $intitle -in $frm.status -side left

            #--- Cree un label pour le status
            label $intitle.ok -font $av4lconf(font,courier_10) -padx 3 \
                  -text "repertoire destination"
            pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
            #--- Cree un label pour le nb d image
            label $intitle.requetes -font $av4lconf(font,courier_10) \
                  -text "prefixe des fichiers"
            pack $intitle.requetes -in $intitle -side top -padx 3 -pady 1 -anchor w


          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $frm.status.v -borderwidth 0]
          pack $inparam -in $frm.status -side right -expand 1 -fill x

            #--- Cree un label pour le nb image
            entry $inparam.requetes -fg $color(blue)
            pack $inparam.requetes -in $inparam -side top -pady 1 -anchor w
            #--- Cree un label pour le nb de header
            entry $inparam.scenes  -fg $color(blue)
            pack $inparam.scenes -in $inparam -side top -pady 1 -anchor w


   #---
        button $frm.extract \
           -text "extract" -borderwidth 2 \
           -command { ::av4l_tools::avi_extract }
        pack $frm.extract \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un frame pour le status des repertoires
        frame $frm.rep \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.rep \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1


      #--- Cree un frame pour y mettre la barre de defilement et les boutons
      frame $frmbbar \
         -borderwidth 0 -cursor arrow
      pack $frmbbar \
         -in $base -anchor s -side bottom -expand 0 -fill x

        #--- Creation du bouton fermer
        button $frmbbar.but_fermer \
           -text "$caption(av4l_extraction,fermer)" -borderwidth 2 \
           -command { ::av4l_extraction::fermer }
        pack $frmbbar.but_fermer \
           -in $frmbbar -side right -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton aide
        button $frmbbar.but_aide \
           -text "$caption(av4l_extraction,aide)" -borderwidth 2 \
           -command { ::audace::showHelpPlugin tool av4l av4l.htm }
        pack $frmbbar.but_aide \
           -in $frmbbar -side right -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


   }

}


#--- Initialisation au demarrage
::av4l_extraction::init
