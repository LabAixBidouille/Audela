#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_cdl_avi.tcl
#--------------------------------------------------
#
# Fichier        : av4l_cdl_avi.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frédéric Vachier
# Mise à jour $Id: av4l_cdl_avi.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::av4l_cdl_avi {

variable obj
variable ref
variable delta
variable sortie
variable mesure
variable file_mesure

   #
   # av4l_cdl_avi::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_cdl_avi.cap ]
   }

   #
   # av4l_cdl_avi::initToConf
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
   # av4l_cdl_avi::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_cdl_avi::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_cdl_avi::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_cdl_avi::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_cdl_avi::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_cdl_avi::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)


   }















   #
   # av4l_cdl_avi::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

   }















   #
   # av4l_cdl_avi::run 
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
     global audace panneau


      set panneau(av4l,$visuNo,av4l_cdl_avi) $this
      #::confGenerique::run $visuNo "$panneau(av4l,$visuNo,av4l_cdl_avi)" "::av4l_cdl_avi" -modal 1

      createdialog $this $visuNo   

   }
















   #
   # av4l_cdl_avi::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc apply { visuNo } {
      ::av4l_cdl_avi::widgetToConf $visuNo
   }
















   #
   # av4l_cdl_avi::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_cdl_avi.htm
   }
















   #
   # av4l_cdl_avi::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc closeWindow { this visuNo } {

      ::av4l_cdl_avi::widgetToConf $visuNo
      ::av4l_tools::avi_close
      destroy $this
   }















   #
   # av4l_cdl_avi::getLabel
   # Retourne le nom de la fenetre 
   #
   proc getLabel { } {
      global caption

      return "$caption(av4l_cdl_avi,titre)"
   }
















   #
   # av4l_cdl_avi::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire 
   #
   proc chgdir { This } {
      global caption
      global cwdWindow
      global audace

      #--- Initialisation des variables a 2 (0 et 1 reservees a Configuration --> Repertoires)
      set cwdWindow(rep_images)      "2"
      set cwdWindow(rep_travail)     "2"
      set cwdWindow(rep_scripts)     "2"
      set cwdWindow(rep_catalogues)  "2"
      set cwdWindow(rep_userCatalog) "2"

      set parent "$audace(base)"
      set title "Choisir un repertoire de destination"
      set rep "$audace(rep_images)"

      set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep" $title $parent ]" } msg ]
      if { $numerror == "1" } {
         set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $parent ]"
      }


      ::console::affiche_resultat $audace(rep_images)

      $This delete 0 end
      $This insert 0 $filename
      
   }

















   #
   # av4l_cdl_avi::fillConfigPage
   # Creation de l'interface graphique
   #
   proc createdialog { this visuNo } {

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
      wm title $this $caption(av4l_cdl_avi,bar_title)
      wm protocol $this WM_DELETE_WINDOW "::av4l_cdl_avi::closeWindow $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_cdl_avi::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_cdl_avi
      set frmbbar $this.frm_av4l_cdl_avi_bar


      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "$caption(av4l_cdl_avi,titre)"
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
        scale $frm.percent -from 0 -to 1 -length 600 -variable ::av4l_cdl_avi::percent \
           -label "" -orient horizontal \
           -state disabled
        pack $frm.percent -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

        #--- Cree un frame pour afficher
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

        #--- Creation du bouton quick prev image
        image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool av4l img arr.png ]
        button $frm.qprevimage -image .arr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_tools::avi_quick_prev_image"
        pack $frm.qprevimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool av4l img arn.png ]
        button $frm.previmage -image .arn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_cdl_avi::avi_prev_image $frm $visuNo"
        pack $frm.previmage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool av4l img avn.png ]
        button $frm.nextimage -image .avn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_cdl_avi::avi_next_image $frm $visuNo"
        pack $frm.nextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool av4l img avr.png ]
        button $frm.qnextimage -image .avr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_tools::avi_quick_next_image"
        pack $frm.qnextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0



          #--- Affichage positions
          frame $frm.pos \
                -borderwidth 1 -relief raised -cursor arrow
          pack $frm.pos \
               -in $frm -side top -expand 0 -fill x -padx 1 -pady 1


             #--- Creation du bouton setmin
             button $frm.pos.setmin \
                -text "setmin" -borderwidth 2 \
                -command "::av4l_tools::avi_setmin $frm"
             pack $frm.pos.setmin \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.setmax \
                -text "setmax" -borderwidth 2 \
                -command "::av4l_tools::avi_setmax $frm"
             pack $frm.pos.setmax \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Cree un frame pour afficher
             frame $frm.pos.min -borderwidth 0
             pack $frm.pos.min -in $frm.pos -side left

                #--- Cree un label pour
                #entry $frm.datemin -fg $color(blue) -relief sunken
                #pack $frm.datemin -in $frm.pos.min -side top -pady 1 -anchor w
                #--- Cree un label pour
                entry $frm.posmin -fg $color(blue) -relief sunken
                pack $frm.posmin -in $frm.pos.min -side top -pady 1 -anchor w


             #--- Cree un frame pour afficher
             frame $frm.pos.max -borderwidth 0
             pack $frm.pos.max -in $frm.pos -side left

                #--- Cree un label pour
                #entry $frm.datemax -fg $color(blue) -relief sunken
                #pack $frm.datemax -in $frm.pos.max -side top -pady 1 -anchor w
                #--- Cree un label pour
                entry $frm.posmax -fg $color(blue) -relief sunken
                pack $frm.posmax -in $frm.pos.max -side top -pady 1 -anchor w

             #--- Creation du bouton setmax
             button $frm.pos.crop \
                -text "crop" -borderwidth 2 \
                -command ""
             pack $frm.pos.crop \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0




  #--- infos photometrie

          #--- Cree un frame 
          frame $frm.tphotom -borderwidth 0 -cursor arrow
          pack $frm.tphotom -in $frm -side top -anchor w

          #---Titre
          label $frm.tphotom.title -font $av4lconf(font,arial_10_b) -text "Photometrie" 
          pack  $frm.tphotom.title -in $frm.tphotom -side top -anchor w -ipady 10


          #--- Cree un frame 
          frame $frm.photom -borderwidth 1 -relief raised -cursor arrow 
          pack $frm.photom -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Cree un frame 
          frame $frm.photom.values -borderwidth 0 -cursor arrow
          pack $frm.photom.values -in $frm.photom -side top -expand 5







          #--- Cree un frame pour image
          set image [frame $frm.photom.values.image -borderwidth 1]
          pack $image -in $frm.photom.values -side left -padx 30 -pady 1

              #--- Cree un frame
              frame $image.t -borderwidth 0 -cursor arrow
              pack  $image.t -in $image -side top -expand 5 -anchor w

              #--- Cree un label
              label $image.t.titre -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b)  -text "Image"
              pack  $image.t.titre -in $image.t -side left -anchor w -padx 30

              button $image.t.select -text "Select" -borderwidth 1 -takefocus 1 \
                                     -command "::av4l_cdl_avi::select_fullimg $visuNo $image"
              pack $image.t.select -in $image.t -side left -anchor e 
                
              #--- Cree un frame pour les info 
              frame $image.v -borderwidth 0 -cursor arrow
              pack  $image.v -in $image -side top

              frame $image.v.l -borderwidth 0 -cursor arrow
              pack  $image.v.l -in $image.v -side left

              frame $image.v.r -borderwidth 0 -cursor arrow
              pack  $image.v.r -in $image.v -side right


                 #---
                 label $image.v.l.fenetre -font $av4lconf(font,courier_10) -text "Fenetre"
                 pack  $image.v.l.fenetre -in $image.v.l -side top -anchor w
                 label $image.v.r.fenetre -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $image.v.r.fenetre -in $image.v.r -side top -anchor w

                 #---
                 label $image.v.l.intmin -font $av4lconf(font,courier_10) -text "Intensite min"
                 pack  $image.v.l.intmin -in $image.v.l -side top -anchor w
                 label $image.v.r.intmin -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $image.v.r.intmin -in $image.v.r -side top -anchor w

                 #---
                 label $image.v.l.intmax -font $av4lconf(font,courier_10) -text "Intensite max"
                 pack  $image.v.l.intmax -in $image.v.l -side top -anchor w
                 label $image.v.r.intmax -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $image.v.r.intmax -in $image.v.r -side top -anchor w

                 #---
                 label $image.v.l.intmoy -font $av4lconf(font,courier_10) -text "Intensite moyenne"
                 pack  $image.v.l.intmoy -in $image.v.l -side top -anchor w
                 label $image.v.r.intmoy -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $image.v.r.intmoy -in $image.v.r -side top -anchor w

                 #---
                 label $image.v.l.sigma -font $av4lconf(font,courier_10) -text "Ecart-type"
                 pack  $image.v.l.sigma -in $image.v.l -side top -anchor w
                 label $image.v.r.sigma -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $image.v.r.sigma -in $image.v.r -side top -anchor w




          #--- Cree un frame pour object
          set object [frame $frm.photom.values.object -borderwidth 1]
          pack $object -in $frm.photom.values -side left -padx 30 -pady 1

              #--- Cree un frame
              frame $object.t -borderwidth 0 -cursor arrow
              pack  $object.t -in $object -side top -expand 5 -anchor w

              #--- Cree un label
              label $object.t.titre -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b)  -text "object"
              pack  $object.t.titre -in $object.t -side left -anchor w -padx 30

              button $object.t.select -text "Select" -borderwidth 1 -takefocus 1 \
                                     -command "::av4l_cdl_avi::select_obj $visuNo $object"
              pack $object.t.select -in $object.t -side left -anchor e 
                
              #--- Cree un frame pour les info 
              frame $object.v -borderwidth 0 -cursor arrow
              pack  $object.v -in $object -side top

              frame $object.v.l -borderwidth 0 -cursor arrow
              pack  $object.v.l -in $object.v -side left

              frame $object.v.r -borderwidth 0 -cursor arrow
              pack  $object.v.r -in $object.v -side right


                 #---
                 label $object.v.l.position -font $av4lconf(font,courier_10) -text "Position"
                 pack  $object.v.l.position -in $object.v.l -side top -anchor w
                 label $object.v.r.position -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.position -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.delta -font $av4lconf(font,courier_10) -text "Delta"
                 pack  $object.v.l.delta -in $object.v.l -side top -anchor w

                 spinbox $object.v.r.delta -font $av4lconf(font,courier_10) -fg $color(blue) \
                    -value [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 ] \
                    -command "::av4l_cdl_avi::mesure_obj_avance $frm $visuNo" -width 5 
                 pack  $object.v.r.delta -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.fint -font $av4lconf(font,courier_10) -text "Flux integre"
                 pack  $object.v.l.fint -in $object.v.l -side top -anchor w
                 label $object.v.r.fint -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.fint -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.fwhm -font $av4lconf(font,courier_10) -text "Fwhm"
                 pack  $object.v.l.fwhm -in $object.v.l -side top -anchor w
                 label $object.v.r.fwhm -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.fwhm -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.pixmax -font $av4lconf(font,courier_10) -text "Pixmax"
                 pack  $object.v.l.pixmax -in $object.v.l -side top -anchor w
                 label $object.v.r.pixmax -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.pixmax -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.intensite -font $av4lconf(font,courier_10) -text "Intensite"
                 pack  $object.v.l.intensite -in $object.v.l -side top -anchor w
                 label $object.v.r.intensite -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.intensite -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.sigmafond -font $av4lconf(font,courier_10) -text "Sigma fond"
                 pack  $object.v.l.sigmafond -in $object.v.l -side top -anchor w
                 label $object.v.r.sigmafond -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.sigmafond -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.snint -font $av4lconf(font,courier_10) -text "S/B integre"
                 pack  $object.v.l.snint -in $object.v.l -side top -anchor w
                 label $object.v.r.snint -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.snint -in $object.v.r -side top -anchor w

                 #---
                 label $object.v.l.snpx -font $av4lconf(font,courier_10) -text "S/B pix"
                 pack  $object.v.l.snpx -in $object.v.l -side top -anchor w
                 label $object.v.r.snpx -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $object.v.r.snpx -in $object.v.r -side top -anchor w




          #--- Cree un frame pour reference
          set reference [frame $frm.photom.values.reference -borderwidth 1]
          pack $reference -in $frm.photom.values -side left -padx 30 -pady 1

              #--- Cree un frame
              frame $reference.t -borderwidth 0 -cursor arrow
              pack  $reference.t -in $reference -side top -expand 5 -anchor w

              #--- Cree un label
              label $reference.t.titre -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b)  -text "reference"
              pack  $reference.t.titre -in $reference.t -side left -anchor w -padx 30

              button $reference.t.select -text "Select" -borderwidth 1 -takefocus 1 \
                                     -command "::av4l_cdl_avi::select_ref $visuNo $reference"
              pack $reference.t.select -in $reference.t -side left -anchor e 
                
              #--- Cree un frame pour les info 
              frame $reference.v -borderwidth 0 -cursor arrow
              pack  $reference.v -in $reference -side top

              frame $reference.v.l -borderwidth 0 -cursor arrow
              pack  $reference.v.l -in $reference.v -side left

              frame $reference.v.r -borderwidth 0 -cursor arrow
              pack  $reference.v.r -in $reference.v -side right


                 #---
                 label $reference.v.l.position -font $av4lconf(font,courier_10) -text "Position"
                 pack  $reference.v.l.position -in $reference.v.l -side top -anchor w
                 label $reference.v.r.position -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.position -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.delta -font $av4lconf(font,courier_10) -text "Delta"
                 pack  $reference.v.l.delta -in $reference.v.l -side top -anchor w

                 spinbox $reference.v.r.delta -font $av4lconf(font,courier_10) -fg $color(blue) \
                    -value [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 ] \
                    -command "::av4l_cdl_avi::mesure_ref_avance $frm $visuNo" -width 5 
                 pack  $reference.v.r.delta -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.fint -font $av4lconf(font,courier_10) -text "Flux integre"
                 pack  $reference.v.l.fint -in $reference.v.l -side top -anchor w
                 label $reference.v.r.fint -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.fint -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.fwhm -font $av4lconf(font,courier_10) -text "Fwhm"
                 pack  $reference.v.l.fwhm -in $reference.v.l -side top -anchor w
                 label $reference.v.r.fwhm -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.fwhm -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.pixmax -font $av4lconf(font,courier_10) -text "Pixmax"
                 pack  $reference.v.l.pixmax -in $reference.v.l -side top -anchor w
                 label $reference.v.r.pixmax -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.pixmax -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.intensite -font $av4lconf(font,courier_10) -text "Intensite"
                 pack  $reference.v.l.intensite -in $reference.v.l -side top -anchor w
                 label $reference.v.r.intensite -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.intensite -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.sigmafond -font $av4lconf(font,courier_10) -text "Sigma fond"
                 pack  $reference.v.l.sigmafond -in $reference.v.l -side top -anchor w
                 label $reference.v.r.sigmafond -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.sigmafond -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.snint -font $av4lconf(font,courier_10) -text "S/B integre"
                 pack  $reference.v.l.snint -in $reference.v.l -side top -anchor w
                 label $reference.v.r.snint -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.snint -in $reference.v.r -side top -anchor w

                 #---
                 label $reference.v.l.snpx -font $av4lconf(font,courier_10) -text "S/B pix"
                 pack  $reference.v.l.snpx -in $reference.v.l -side top -anchor w
                 label $reference.v.r.snpx -font $av4lconf(font,courier_10) -fg $color(blue) -text "?"
                 pack  $reference.v.r.snpx -in $reference.v.r -side top -anchor w


   #---
        #--- Cree un frame pour  les boutons d action 
        frame $frm.action \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1


           image create photo .start -format PNG -file [ file join $audace(rep_plugin) tool av4l img start.png ]
           image create photo .stop  -format PNG -file [ file join $audace(rep_plugin) tool av4l img stop.png ]

           button $frm.action.start -image .start\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::av4l_cdl_avi::avi_start $visuNo $frm"
           pack $frm.action.start \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

           image create photo .save  -format PNG -file [ file join $audace(rep_plugin) tool av4l img save.png ]
           button $frm.action.save -image .save\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::av4l_cdl_avi::avi_save $visuNo $frm"
           pack $frm.action.save \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(av4l_cdl_avi,fermer)" -borderwidth 2 \
              -command "::av4l_cdl_avi::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(av4l_cdl_avi,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool av4l av4l_cdl_avi.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }
   
   











   proc select_fullimg { visuNo this } {

      global color

      # Recuperation du Rectangle de l image
      set rect  [ ::confVisu::getBox $visuNo ]

      # Affichage de la taille de la fenetre
      if {$rect==""} {
         $this.v.r.fenetre configure -text "Error" -fg $color(red)
         set ::av4l_photom::rect_img ""
      } else {
         set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
         set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
         $this.v.r.fenetre configure -text "${taillex}x${tailley}" -fg $color(blue)
         set ::av4l_photom::rect_img $rect
      }
      ::av4l_cdl_avi::get_fullimg $visuNo $this

   }



   proc get_fullimg { visuNo this } {

      #::console::affiche_resultat "Arect_img = $::av4l_photom::rect_img \n"

      if {$::av4l_photom::rect_img==""} { 
         $this.v.r.intmin configure -text "?"
         $this.v.r.intmax configure -text "?"
         $this.v.r.intmoy configure -text "?"
         $this.v.r.sigma  configure -text "?"

      } else {
         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set stat [buf$bufNo stat $::av4l_photom::rect_img]
         $this.v.r.intmin configure -text [lindex $stat 3]
         $this.v.r.intmax configure -text [lindex $stat 2]
         $this.v.r.intmoy configure -text [lindex $stat 4]
         $this.v.r.sigma  configure -text [lindex $stat 5]
      }

   }










   
   #
   # av4l_cdl_avi::select_object
   # Selection d un objet a partir d une getBox sur l image
   #
   proc select_obj { visuNo this} {
   
      global color
   
      set statebutton [ $this.t.select cget -relief]

      # activation
      if {$statebutton=="raised"} {

         set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]

         if {$err>0 || $rect ==""} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
            $this.v.r.position configure -text "Selectionnez un cadre" -fg $color(red)
            return
         }

         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set err [ catch {set valeurs  [::av4l_photom::select_obj $rect $bufNo]} msg ]
         
         if {$err>0} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Mesure Photometrique impossible\n"
            ::console::affiche_erreur "      * * * *\n"
            $this.v.r.position configure -text "Error" -fg $color(red)
            return
         }
         
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set delta 5
         $this.v.r.delta delete 0 end
         $this.v.r.delta insert 0 $delta
         ::av4l_cdl_avi::mesure_obj $xsm $ysm $visuNo $this $delta
         $this.t.select  configure -relief sunken
         return
      } 
      
      # desactivation
      if {$statebutton=="sunken"} {

         $this.v.r.position  configure -text "?" 
         $this.v.r.delta     configure -text "?" 
         $this.v.r.fint      configure -text "?" 
         $this.v.r.fwhm      configure -text "?" 
         $this.v.r.pixmax    configure -text "?" 
         $this.v.r.intensite configure -text "?" 
         $this.v.r.sigmafond configure -text "?" 
         $this.v.r.snint     configure -text "?" 
         $this.v.r.snpx      configure -text "?" 

         $this.t.select  configure -relief raised
         return
      } 
      
      $this.t.select  configure -relief raised
      return

   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   #
   # av4l_cdl_avi::select_ref
   # Selection d une reference a partir d une getBox sur l image
   #
   proc select_ref { visuNo this} {
   
      global color
   
      set statebutton [ $this.t.select cget -relief]

      # activation
      if {$statebutton=="raised"} {

         set err [ catch {set rect  [ ::confVisu::getBox $visuNo ]} msg ]

         if {$err>0 || $rect ==""} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
            ::console::affiche_erreur "      * * * *\n"
            $this.v.r.position configure -text "Selectionnez un cadre" -fg $color(red)
            return
         }

         set bufNo [ ::confVisu::getBufNo $visuNo ]
         set err [ catch {set valeurs  [::av4l_photom::select_obj $rect $bufNo]} msg ]
         
         if {$err>0} { 
            ::console::affiche_erreur "$msg\n"
            ::console::affiche_erreur "      * * * *\n"
            ::console::affiche_erreur "Mesure Photometrique impossible\n"
            ::console::affiche_erreur "      * * * *\n"
            $this.v.r.position configure -text "Error" -fg $color(red)
            return
         }
         
         set xsm      [lindex $valeurs 0]
         set ysm      [lindex $valeurs 1]
         set delta 5
         $this.v.r.delta delete 0 end
         $this.v.r.delta insert 0 $delta
         ::av4l_cdl_avi::mesure_ref $xsm $ysm $visuNo $this $delta
         $this.t.select  configure -relief sunken
         return
      } 
      
      # desactivation
      if {$statebutton=="sunken"} {

         $this.v.r.position  configure -text "?" 
         $this.v.r.delta     configure -text "?" 
         $this.v.r.fint      configure -text "?" 
         $this.v.r.fwhm      configure -text "?" 
         $this.v.r.pixmax    configure -text "?" 
         $this.v.r.intensite configure -text "?" 
         $this.v.r.sigmafond configure -text "?" 
         $this.v.r.snint     configure -text "?" 
         $this.v.r.snpx      configure -text "?" 

         $this.t.select  configure -relief raised
         return
      } 
      
      $this.t.select  configure -relief raised
      return

   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   #
   # av4l_cdl_avi::mesure_obj
   # Effectue la photometrie et l affiche
   #
   proc mesure_obj { xsm ysm visuNo this delta} {
         
      global color
         
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set err 0
      
      set err [ catch { set valeurs  [::av4l_photom::mesure_obj $xsm $ysm $delta $bufNo] } msg ]

      if {$err>0} { 
         ::console::affiche_erreur $msg
         $this.v.r.position  configure -text "?" -fg $color(blue)
         $this.v.r.delta     configure -text "?" -fg $color(blue)
         $this.v.r.fint      configure -text "?" -fg $color(blue)
         $this.v.r.fwhm      configure -text "?" -fg $color(blue)
         $this.v.r.pixmax    configure -text "?" -fg $color(blue)
         $this.v.r.intensite configure -text "?" -fg $color(blue)
         $this.v.r.sigmafond configure -text "?" -fg $color(blue)
         $this.v.r.snint     configure -text "?" -fg $color(blue)
         $this.v.r.snpx      configure -text "?" -fg $color(blue)
         return
      }
      
      set xsm         [lindex $valeurs 0]
      set ysm         [lindex $valeurs 1]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 3]
      set fwhm        [lindex $valeurs 4]
      set fluxintegre [lindex $valeurs 5]
      set errflux     [lindex $valeurs 6]
      set pixmax      [lindex $valeurs 7]
      set intensite   [lindex $valeurs 8]
      set sigmafond   [lindex $valeurs 9]
      set snint       [lindex $valeurs 10]
      set snpx        [lindex $valeurs 11]
      set delta       [lindex $valeurs 12]

      set visupos       "[format "%4.2f" $xsm] / [format "%4.2f" $ysm]"
      set visudelta     [format "%5.2f" $delta]
      set visufint      [format "%5.2f" $fluxintegre]
      set visufwhm      "[format "%4.2f" $fwhmx] / [format "%4.2f" $fwhmy]"
      set visupixmax    [format "%5.2f" $pixmax]
      set visuintensite [format "%5.2f" $intensite]
      set visusigmafond [format "%5.2f" $sigmafond]
      set visusnint     [format "%5.2f" $snint]
      set visusnpx      [format "%5.2f" $snpx]

      $this.v.r.position     configure -text "$visupos"       -fg $color(blue)
      $this.v.r.fint         configure -text "$visufint"      -fg $color(blue)
      $this.v.r.fwhm         configure -text "$visufwhm"      -fg $color(blue)
      $this.v.r.pixmax       configure -text "$visupixmax"    -fg $color(blue)
      $this.v.r.intensite    configure -text "$visuintensite" -fg $color(blue)
      $this.v.r.sigmafond    configure -text "$visusigmafond" -fg $color(blue)
      $this.v.r.snint        configure -text "$visusnint"     -fg $color(blue)
      $this.v.r.snpx         configure -text "$visusnpx"      -fg $color(blue)
      
      set ::av4l_cdl_avi::obj(x) [format "%4.2f" $xsm]
      set ::av4l_cdl_avi::obj(y) [format "%4.2f" $ysm]
      ::bddimages_cdl::affich_un_rond [expr $xsm + 1] [expr $ysm - 1] green $delta
   }
   







   
   #
   # av4l_cdl_avi::mesure_ref
   # Effectue la photometrie et l affiche
   #
   proc mesure_ref { xsm ysm visuNo this delta} {
         
      global color
         
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set err 0
      
      set err [ catch { set valeurs  [::av4l_photom::mesure_obj $xsm $ysm $delta $bufNo] } msg ]

      if {$err>0} { 
         ::console::affiche_erreur $msg
         $this.v.r.position  configure -text "?" -fg $color(blue)
         $this.v.r.delta     configure -text "?" -fg $color(blue)
         $this.v.r.fint      configure -text "?" -fg $color(blue)
         $this.v.r.fwhm      configure -text "?" -fg $color(blue)
         $this.v.r.pixmax    configure -text "?" -fg $color(blue)
         $this.v.r.intensite configure -text "?" -fg $color(blue)
         $this.v.r.sigmafond configure -text "?" -fg $color(blue)
         $this.v.r.snint     configure -text "?" -fg $color(blue)
         $this.v.r.snpx      configure -text "?" -fg $color(blue)
         return
      }
      
      set xsm         [lindex $valeurs 0]
      set ysm         [lindex $valeurs 1]
      set fwhmx       [lindex $valeurs 2]
      set fwhmy       [lindex $valeurs 3]
      set fwhm        [lindex $valeurs 4]
      set fluxintegre [lindex $valeurs 5]
      set errflux     [lindex $valeurs 6]
      set pixmax      [lindex $valeurs 7]
      set intensite   [lindex $valeurs 8]
      set sigmafond   [lindex $valeurs 9]
      set snint       [lindex $valeurs 10]
      set snpx        [lindex $valeurs 11]
      set delta       [lindex $valeurs 12]

      set visupos       "[format "%4.2f" $xsm] / [format "%4.2f" $ysm]"
      set visudelta     [format "%5.2f" $delta]
      set visufint      [format "%5.2f" $fluxintegre]
      set visufwhm      "[format "%4.2f" $fwhmx] / [format "%4.2f" $fwhmy]"
      set visupixmax    [format "%5.2f" $pixmax]
      set visuintensite [format "%5.2f" $intensite]
      set visusigmafond [format "%5.2f" $sigmafond]
      set visusnint     [format "%5.2f" $snint]
      set visusnpx      [format "%5.2f" $snpx]

      $this.v.r.position     configure -text "$visupos"       -fg $color(blue)
      $this.v.r.fint         configure -text "$visufint"      -fg $color(blue)
      $this.v.r.fwhm         configure -text "$visufwhm"      -fg $color(blue)
      $this.v.r.pixmax       configure -text "$visupixmax"    -fg $color(blue)
      $this.v.r.intensite    configure -text "$visuintensite" -fg $color(blue)
      $this.v.r.sigmafond    configure -text "$visusigmafond" -fg $color(blue)
      $this.v.r.snint        configure -text "$visusnint"     -fg $color(blue)
      $this.v.r.snpx         configure -text "$visusnpx"      -fg $color(blue)
      
      set ::av4l_cdl_avi::ref(x) [format "%4.2f" $xsm]
      set ::av4l_cdl_avi::ref(y) [format "%4.2f" $ysm]
      ::bddimages_cdl::affich_un_rond [expr $xsm + 1] [expr $ysm - 1] blue $delta
   }
   
   
   
   
   
   
   
   
   
   
   proc mesure_obj_avance { frm visuNo } {
      cleanmark

      set delta [ $frm.photom.values.object.v.r.delta get]
      set statebutton [ $frm.photom.values.object.t.select cget -relief]
      if { $statebutton=="sunken" } {
         ::av4l_cdl_avi::mesure_obj $::av4l_cdl_avi::obj(x) $::av4l_cdl_avi::obj(y) $visuNo $frm.photom.values.object $delta
      }
   }
 
 
 





   proc mesure_ref_avance { frm visuNo } {
      cleanmark

      set delta [ $frm.photom.values.reference.v.r.delta get]
      set statebutton [ $frm.photom.values.reference.t.select cget -relief]
      if { $statebutton=="sunken" } {
         ::av4l_cdl_avi::mesure_ref $::av4l_cdl_avi::ref(x) $::av4l_cdl_avi::ref(y) $visuNo $frm.photom.values.reference $delta
      }
   }
 
 
 
 
 
 
   proc avi_stop {  } {
      ::console::affiche_resultat "-- stop \n"
      set ::av4l_cdl_avi::sortie 1
   }   
 
 
 
 
 
 
 
   proc avi_start { visuNo frm } {
 
      set ::av4l_cdl_avi::sortie 0
      set cpt 0
      $frm.action.start configure -image .stop
      $frm.action.start configure -relief sunken     
      $frm.action.start configure -command " ::av4l_cdl_avi::avi_stop" 
      
      while {$::av4l_cdl_avi::sortie == 0} {

         set idframe [::av4l_tools::avi_get_idframe]
         ::console::affiche_resultat "\[$idframe / $::av4l_tools::nb_frames / [expr $::av4l_tools::nb_frames-$idframe] \]\n"
         if {$idframe == $::av4l_tools::nb_frames} {
            set ::av4l_cdl_avi::sortie 1
         }
          
         cleanmark
         
         set statebutton [ $frm.photom.values.object.t.select cget -relief]
         if { $statebutton=="sunken" } {
            set delta [ $frm.photom.values.object.v.r.delta get]
            ::av4l_cdl_avi::mesure_obj $::av4l_cdl_avi::obj(x) $::av4l_cdl_avi::obj(y) $visuNo $frm.photom.values.object $delta
         }
         set statebutton [ $frm.photom.values.reference.t.select cget -relief]
         if { $statebutton=="sunken" } {
            set delta [ $frm.photom.values.reference.v.r.delta get]
            ::av4l_cdl_avi::mesure_ref $::av4l_cdl_avi::ref(x) $::av4l_cdl_avi::ref(y) $visuNo $frm.photom.values.reference $delta
         }
         ::av4l_cdl_avi::get_fullimg $visuNo $frm.photom.values.image
         set ::av4l_cdl_avi::mesure($idframe,mesure_obj) 1


         # mesure objet
         set ::av4l_cdl_avi::mesure($idframe,obj_delta)     [$frm.photom.values.object.v.r.delta     get]
         set ::av4l_cdl_avi::mesure($idframe,obj_fint)      [$frm.photom.values.object.v.r.fint      cget -text]
         set ::av4l_cdl_avi::mesure($idframe,obj_pixmax)    [$frm.photom.values.object.v.r.pixmax    cget -text]
         set ::av4l_cdl_avi::mesure($idframe,obj_intensite) [$frm.photom.values.object.v.r.intensite cget -text]
         set ::av4l_cdl_avi::mesure($idframe,obj_sigmafond) [$frm.photom.values.object.v.r.sigmafond cget -text]
         set ::av4l_cdl_avi::mesure($idframe,obj_snint)     [$frm.photom.values.object.v.r.snint     cget -text]
         set ::av4l_cdl_avi::mesure($idframe,obj_snpx)      [$frm.photom.values.object.v.r.snpx      cget -text]

         set position  [$frm.photom.values.object.v.r.position  cget -text]
         set poslist [split $position "/"]
         set ::av4l_cdl_avi::mesure($idframe,obj_xpos) [lindex $poslist 0]
         set ::av4l_cdl_avi::mesure($idframe,obj_ypos) [lindex $poslist 1]
         if {$::av4l_cdl_avi::mesure($idframe,obj_ypos)==""} { set :::av4l_cdl_avi::mesure($idframe,obj_ypos) "?" }

         set fwhm      [$frm.photom.values.object.v.r.fwhm cget -text]
         set fwhmlist [split $fwhm "/"]
         set ::av4l_cdl_avi::mesure($idframe,obj_xfwhm) [lindex $fwhmlist 0]
         set ::av4l_cdl_avi::mesure($idframe,obj_yfwhm) [lindex $fwhmlist 1]
         if {$::av4l_cdl_avi::mesure($idframe,obj_yfwhm)==""} {set :::av4l_cdl_avi::mesure($idframe,obj_yfwhm) "?" }

         # mesure reference
         set ::av4l_cdl_avi::mesure($idframe,ref_delta)     [$frm.photom.values.reference.v.r.delta     get]
         set ::av4l_cdl_avi::mesure($idframe,ref_fint)      [$frm.photom.values.reference.v.r.fint      cget -text]
         set ::av4l_cdl_avi::mesure($idframe,ref_pixmax)    [$frm.photom.values.reference.v.r.pixmax    cget -text]
         set ::av4l_cdl_avi::mesure($idframe,ref_intensite) [$frm.photom.values.reference.v.r.intensite cget -text]
         set ::av4l_cdl_avi::mesure($idframe,ref_sigmafond) [$frm.photom.values.reference.v.r.sigmafond cget -text]
         set ::av4l_cdl_avi::mesure($idframe,ref_snint)     [$frm.photom.values.reference.v.r.snint     cget -text]
         set ::av4l_cdl_avi::mesure($idframe,ref_snpx)      [$frm.photom.values.reference.v.r.snpx      cget -text]

         set position  [$frm.photom.values.reference.v.r.position  cget -text]
         set poslist [split $position "/"]
         set ::av4l_cdl_avi::mesure($idframe,ref_xpos) [lindex $poslist 0]
         set ::av4l_cdl_avi::mesure($idframe,ref_ypos) [lindex $poslist 1]
         if {$::av4l_cdl_avi::mesure($idframe,ref_ypos)==""} { set :::av4l_cdl_avi::mesure($idframe,ref_ypos) "?" }

         set fwhm      [$frm.photom.values.reference.v.r.fwhm cget -text]
         set fwhmlist [split $fwhm "/"]
         set ::av4l_cdl_avi::mesure($idframe,ref_xfwhm) [lindex $fwhmlist 0]
         set ::av4l_cdl_avi::mesure($idframe,ref_yfwhm) [lindex $fwhmlist 1]
         if {$::av4l_cdl_avi::mesure($idframe,ref_yfwhm)==""} {set :::av4l_cdl_avi::mesure($idframe,ref_yfwhm) "?" }

         # mesure image
         set ::av4l_cdl_avi::mesure($idframe,img_intmin)  [$frm.photom.values.image.v.l.intmin  cget -text]
         set ::av4l_cdl_avi::mesure($idframe,img_intmax)  [$frm.photom.values.image.v.l.intmax  cget -text]
         set ::av4l_cdl_avi::mesure($idframe,img_intmoy)  [$frm.photom.values.image.v.l.intmoy  cget -text]
         set ::av4l_cdl_avi::mesure($idframe,img_sigma)   [$frm.photom.values.image.v.l.sigma   cget -text]

         set fenetre  [$frm.photom.values.image.v.l.fenetre  cget -text]
         set fenetrelist [split $fenetre "x"]
         set ::av4l_cdl_avi::mesure($idframe,img_xsize) [lindex $fenetrelist 0]
         set ::av4l_cdl_avi::mesure($idframe,img_ysize) [lindex $fenetrelist 1]
         if {$::av4l_cdl_avi::mesure($idframe,img_ysize)==""} { set :::av4l_cdl_avi::mesure($idframe,img_ysize) "?" }











         ::av4l_tools::avi_next_image  
       }

      $frm.action.start configure -image .start
      $frm.action.start configure -relief raised     
      $frm.action.start configure -command "::av4l_cdl_avi::avi_start $visuNo $frm" 

   }





 
   proc avi_save { visuNo frm } {
 

      set bufNo [ visu$visuNo buf ]
      set filename [$frm.open.avipath get]
      if { ! [file exists $filename] } {
      ::console::affiche_erreur "Charger une video ...\n"
      } 
      set racinefilename "${filename}."

      set sortie 0
      set idfile 0
      while {$sortie == 0} {
         set idd [format "%05d" $idfile]
         set filename "${racinefilename}${idd}.csv"
         if { [file exists $filename] } {
         #::console::affiche_resultat "existe ${filename} ...\n"
         } else {
         set sortie 1
         }
         incr idfile
      }



      ::console::affiche_resultat "Sauvegarde dans ${filename} ..."
      set f1 [open $filename "w"]
      puts $f1 "# ** AV4L - Audela - Linux  * "
      puts $f1 "#FPS = 25"
      set line "idframe,"
      append line "obj_fint     ,"
      append line "obj_pixmax   ,"
      append line "obj_intensite,"
      append line "obj_sigmafond,"
      append line "obj_snint    ,"
      append line "obj_snpx     ,"
      append line "obj_delta    ,"
      append line "obj_xpos,"
      append line "obj_ypos,"
      append line "obj_xfwhm,"
      append line "obj_yfwhm,"
      append line "ref_fint     ,"
      append line "ref_pixmax   ,"
      append line "ref_intensite,"
      append line "ref_sigmafond,"
      append line "ref_snint    ,"
      append line "ref_snpx     ,"
      append line "ref_delta    ,"
      append line "ref_xpos,"
      append line "ref_ypos,"
      append line "ref_xfwhm,"
      append line "ref_yfwhm,"
      append line "img_intmin ,"
      append line "img_intmax,"
      append line "img_intmoy,"
      append line "img_sigma ,"
      append line "img_xsize,"
      append line "img_ysize,"
      puts $f1 $line


      set sortie 0
      set idframe 0
      set cpt 0
      while {$sortie == 0} {

         if {$idframe == $::av4l_tools::nb_frames} {
            set sortie 1
         }
         
         if { [info exists ::av4l_cdl_avi::mesure($idframe,mesure_obj)] && $::av4l_cdl_avi::mesure($idframe,mesure_obj) == 1 } {
            set reste [expr $::av4l_tools::nb_frames-$idframe]

            #set id [expr $idframe -1]
            set id $idframe
            
            set line "$id,"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_fint)     ,"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_pixmax)   ,"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_intensite),"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_sigmafond),"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_snint)    ,"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_snpx)     ,"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_delta)    ,"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_xpos),"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_ypos),"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_xfwhm),"
            append line "$::av4l_cdl_avi::mesure($idframe,obj_yfwhm),"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_fint)     ,"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_pixmax)   ,"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_intensite),"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_sigmafond),"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_snint)    ,"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_snpx)     ,"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_delta)    ,"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_xpos),"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_ypos),"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_xfwhm),"
            append line "$::av4l_cdl_avi::mesure($idframe,ref_yfwhm),"
            append line "$::av4l_cdl_avi::mesure($idframe,img_intmin) ,"
            append line "$::av4l_cdl_avi::mesure($idframe,img_intmax),"
            append line "$::av4l_cdl_avi::mesure($idframe,img_intmoy),"
            append line "$::av4l_cdl_avi::mesure($idframe,img_sigma) ,"
            append line "$::av4l_cdl_avi::mesure($idframe,img_xsize),"
            append line "$::av4l_cdl_avi::mesure($idframe,img_ysize),"
            
            
            puts $f1 $line
            incr cpt
         }
         
         incr idframe
      }

      close $f1
      ::console::affiche_resultat "nb frame save = $cpt   .. Fin  ..\n"
      

   }

 
   #
   # av4l_cdl_avi::avi_next_image
   # Passe a l image suivante
   #
   proc avi_next_image { frm visuNo } {
         
      cleanmark
      ::av4l_tools::avi_next_image  

      set statebutton [ $frm.photom.values.object.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.object.v.r.delta get]
         ::av4l_cdl_avi::mesure_obj $::av4l_cdl_avi::obj(x) $::av4l_cdl_avi::obj(y) $visuNo $frm.photom.values.object $delta
      }
      set statebutton [ $frm.photom.values.reference.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.reference.v.r.delta get]
         ::av4l_cdl_avi::mesure_ref $::av4l_cdl_avi::ref(x) $::av4l_cdl_avi::ref(y) $visuNo $frm.photom.values.reference $delta
      }
      ::av4l_cdl_avi::get_fullimg $visuNo $frm.photom.values.image
      set idframe [::av4l_tools::avi_get_idframe]
      ::console::affiche_resultat "$idframe\n"
   }
   
   #
   # av4l_cdl_avi::avi_next_image
   # Passe a l image suivante
   #
   proc avi_prev_image { frm visuNo } {
         
      cleanmark
      ::av4l_tools::avi_prev_image  

      set statebutton [ $frm.photom.values.object.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.object.v.r.delta get]
         ::av4l_cdl_avi::mesure_obj $::av4l_cdl_avi::obj(x) $::av4l_cdl_avi::obj(y) $visuNo $frm.photom.values.object $delta
      }
      set statebutton [ $frm.photom.values.reference.t.select cget -relief]
      if { $statebutton=="sunken" } {
         set delta [ $frm.photom.values.reference.v.r.delta get]
         ::av4l_cdl_avi::mesure_ref $::av4l_cdl_avi::ref(x) $::av4l_cdl_avi::ref(y) $visuNo $frm.photom.values.reference $delta
      }
      ::av4l_cdl_avi::get_fullimg $visuNo $frm.photom.values.image
      set idframe [::av4l_tools::avi_get_idframe]
      ::console::affiche_resultat "$idframe\n"
   }
   
   
   

}


#--- Initialisation au demarrage
::av4l_cdl_avi::init
