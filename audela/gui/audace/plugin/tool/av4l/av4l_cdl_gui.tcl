#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_cdl_gui.tcl
#--------------------------------------------------
#
# Fichier        : av4l_cdl_gui.tcl
# Description    : GUI de l outil Courbe de lumiere
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#

namespace eval ::av4l_cdl_gui {


   #
   # Chargement des captions
   #
   proc ::av4l_cdl_gui::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_cdl_gui.cap ]
   }







   #
   # Initialisation des variables de configuration
   #
   proc ::av4l_cdl_gui::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,messages) ] }                           { set ::av4l::parametres(av4l,$visuNo,messages)                           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,save_file_log) ] }                      { set ::av4l::parametres(av4l,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,alarme_fin_serie) ] }                   { set ::av4l::parametres(av4l,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier) ] }           { set ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_index_depart) ] }              { set ::av4l::parametres(av4l,$visuNo,verifier_index_depart)              "1" }

   }












   #
   # Charge la configuration dans des variables locales
   #
   proc ::av4l_cdl_gui::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_cdl_gui::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_cdl_gui::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_cdl_gui::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_cdl_gui::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_cdl_gui::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)


   }















   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::av4l_cdl_gui::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }















   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::av4l_cdl_gui::run { visuNo frm } {

      global audace panneau

      set panneau(av4l,$visuNo,av4l_cdl_gui) $frm

      createdialog $visuNo $frm

   }















   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::av4l_cdl_gui::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_cdl_gui.htm
   }
















   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::av4l_cdl_gui::closeWindow { this visuNo } {

      ::av4l_cdl_gui::widgetToConf $visuNo

      destroy $this
   }














   #
   # Creation de l'interface graphique
   #
   proc ::av4l_cdl_gui::createdialog { visuNo this } {

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
      if { $::av4l_tools::traitement=="fits" } { wm title $this $caption(av4l_cdl_gui,bar_title_fits) }
      if { $::av4l_tools::traitement=="avi" }  { wm title $this $caption(av4l_cdl_gui,bar_title_avi) }
      wm protocol $this WM_DELETE_WINDOW "::av4l_cdl_gui::closeWindow $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_cdl_gui::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_cdl_gui
      set frmbbar $this.frm_av4l_cdl_gui_bar

      if { $::av4l_tools::traitement=="fits" } { set titre $caption(av4l_cdl_gui,titre_fits) }
      if { $::av4l_tools::traitement=="avi" }  { set titre $caption(av4l_cdl_gui,titre_avi) }



      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "$titre"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3



        if { $::av4l_tools::traitement=="fits" } { 
        
        
             #--- Cree un frame pour la gestion de fichier
             frame $frm.form \
                   -borderwidth 1 -relief raised -cursor arrow
             pack $frm.form \
                  -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

               #--- Cree un frame pour la gestion de fichier
               frame $frm.form.butopen \
                     -borderwidth 1 -cursor arrow
               pack $frm.form.butopen \
                    -in $frm.form -side left -expand 0 -fill x -padx 1 -pady 1

                    #--- Creation du bouton open
                    button $frm.form.butopen.open \
                       -text "open" -borderwidth 2 \
                       -command "::av4l_cdl_tools::open_flux $visuNo $frm"
                    pack $frm.form.butopen.open \
                       -in $frm.form.butopen -side left -anchor e \
                       -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

               #--- Cree un frame pour la gestion de fichier
               frame $frm.form.field \
                     -borderwidth 1 -cursor arrow
               pack $frm.form.field \
                    -in $frm.form -side left -expand 0 -fill x -padx 1 -pady 1

                    #--- Cree un frame pour afficher les intitules
                    set intitle [frame $frm.form.field.l -borderwidth 0]
                    pack $intitle -in $frm.form.field -side left

                      #--- Cree un label pour
                      label $intitle.destdir -font $av4lconf(font,courier_10) -padx 3 \
                            -text "repertoire destination"
                      pack $intitle.destdir -in $intitle -side top -padx 3 -pady 1 -anchor w

                      #--- Cree un label pour
                      label $intitle.prefix -font $av4lconf(font,courier_10) \
                            -text "Prefixe du fichier"
                      pack $intitle.prefix -in $intitle -side top -padx 3 -pady 1 -anchor w


                    #--- Cree un frame pour afficher les valeurs
                    set inparam [frame $frm.form.field.v -borderwidth 0]
                    pack $inparam -in $frm.form.field -side left -expand 0 -fill x

                      #--- Cree un label pour le repetoire destination
                      entry $inparam.destdir -fg $color(blue) -width 40
                      pack $inparam.destdir -in $inparam -side top -pady 1 -anchor w

                      #--- Cree un label pour le prefixe
                      entry $inparam.prefix  -fg $color(blue)
                      pack $inparam.prefix -in $inparam -side top -pady 1 -anchor w

                    #--- Cree un frame pour afficher les extras
                    set inbutton [frame $frm.form.field.e -borderwidth 0]
                    pack $inbutton -in $frm.form.field -side left -expand 0 -fill x

                      #--- Cree un button
                      button $inbutton.chgdir \
                       -text "..." -borderwidth 2 \
                       -command "::av4l_tools::chgdir $inparam.destdir" 
                      pack $inbutton.chgdir -in $inbutton -side top -pady 0 -anchor w

                      #--- Cree un label pour le nb d image
                      label $inbutton.blank -font $av4lconf(font,courier_10) \
                            -text ""
                      pack $inbutton.blank -in $inbutton -side top -padx 3 -pady 1 -anchor w

        
        
        }





        if { $::av4l_tools::traitement=="avi" }  { 

             #--- Cree un frame pour 
             frame $frm.open \
                   -borderwidth 1 -relief raised -cursor arrow
             pack $frm.open \
                  -in $frm -side top -expand 0 -fill x -padx 1 -pady 1


             #--- Creation du bouton open
             button $frm.open.but_open \
                -text "open" -borderwidth 2 \
                -command "::av4l_cdl_tools::open_flux $visuNo $frm"
             pack $frm.open.but_open \
                -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton select
             button $frm.open.but_select \
                -text "..." -borderwidth 2 -takefocus 1 \
                -command "::av4l_cdl_tools::select $visuNo $frm"
             pack $frm.open.but_select \
                -side left -anchor e \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


             #--- Cree un label pour le chemin de l'AVI
             entry $frm.open.avipath 
             pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

        }













        #--- Creation de la barre de defilement
        scale $frm.scrollbar -from 0 -to 1 -length 600 -variable ::av4l_tools::scrollbar \
           -label "" -orient horizontal \
           -state disabled
        pack $frm.scrollbar -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

        #--- Cree un frame pour afficher
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

        #--- Creation du bouton quick prev image
        image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool av4l img arr.png ]
        button $frm.qprevimage -image .arr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_cdl_tools::quick_prev_image $visuNo $frm"
        pack $frm.qprevimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool av4l img arn.png ]
        button $frm.previmage -image .arn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_cdl_tools::prev_image $visuNo $frm"
        pack $frm.previmage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool av4l img avn.png ]
        button $frm.nextimage -image .avn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_cdl_tools::next_image $visuNo $frm"
        pack $frm.nextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool av4l img avr.png ]
        button $frm.qnextimage -image .avr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_cdl_tools::quick_next_image $visuNo $frm"
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
                -command "::av4l_tools::setmin $frm"
             pack $frm.pos.setmin \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.setmax \
                -text "setmax" -borderwidth 2 \
                -command "::av4l_tools::setmax $frm"
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
                -command "::av4l_tools::crop $visuNo $frm"
             pack $frm.pos.crop \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.uncrop \
                -text "uncrop" -borderwidth 2 \
                -command "::av4l_tools::uncrop $visuNo $frm"
             pack $frm.pos.uncrop \
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
                                     -command "::av4l_cdl_tools::select_fullimg $visuNo $image"
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
                                     -command "::av4l_cdl_tools::select_obj $visuNo $object"
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
                    -command "::av4l_cdl_tools::mesure_obj_avance $visuNo $frm" -width 5 
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
                                     -command "::av4l_cdl_tools::select_ref $visuNo $reference"
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
                    -command "::av4l_cdl_tools::mesure_ref_avance $visuNo $frm" -width 5 
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
              -command "::av4l_cdl_tools::start $visuNo $frm"
           pack $frm.action.start \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

           image create photo .save  -format PNG -file [ file join $audace(rep_plugin) tool av4l img save.png ]
           button $frm.action.save -image .save\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::av4l_cdl_tools::save $visuNo $frm"
           pack $frm.action.save \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(av4l_cdl_gui,fermer)" -borderwidth 2 \
              -command "::av4l_cdl_gui::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(av4l_cdl_gui,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool av4l av4l_cdl_gui.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }




}


#--- Initialisation au demarrage
::av4l_cdl_gui::init
