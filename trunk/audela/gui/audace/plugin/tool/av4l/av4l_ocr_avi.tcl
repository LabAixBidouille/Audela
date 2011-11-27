#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_ocr_avi.tcl
#--------------------------------------------------
#
# Fichier        : av4l_ocr_avi.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : FrÃ©dÃ©ric Vachier
# Mise Ã  jour $Id: av4l_ocr_avi.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::av4l_ocr_avi {

variable obj
variable ref
variable delta
variable sortie
variable mesure
variable file_mesure
variable active_ocr
variable nbverif
variable nbocr
variable nbinterp
variable timing

   #
   # av4l_ocr_avi::init
   # Chargement des captions
   #
   proc init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_ocr_avi.cap ]
   }

   #
   # av4l_ocr_avi::initToConf
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
   # av4l_ocr_avi::confToWidget
   # Charge la configuration dans des variables locales
   #
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_ocr_avi::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_ocr_avi::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_ocr_avi::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_ocr_avi::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_ocr_avi::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)

      set ::av4l_photom::rect_img ""
      set ::av4l_ocr_avi::active_ocr 0
      set ::av4l_ocr_avi::nbverif 0
      set ::av4l_ocr_avi::nbocr 0
      set ::av4l_ocr_avi::nbinterp 0

   }















   #
   # av4l_ocr_avi::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { visuNo } {
      variable parametres
      global panneau

   }















   #
   # av4l_ocr_avi::run 
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc run { visuNo this } {
     global audace panneau


      set panneau(av4l,$visuNo,av4l_ocr_avi) $this
      #::confGenerique::run $visuNo "$panneau(av4l,$visuNo,av4l_ocr_avi)" "::av4l_ocr_avi" -modal 1

      createdialog $this $visuNo   

   }
















   #
   # av4l_ocr_avi::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc apply { visuNo } {
      ::av4l_ocr_avi::widgetToConf $visuNo
   }
















   #
   # av4l_ocr_avi::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_ocr_avi.htm
   }
















   #
   # av4l_ocr_avi::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc closeWindow { this visuNo } {

      ::av4l_ocr_avi::widgetToConf $visuNo
      ::av4l_tools::avi_close
      destroy $this
   }















   #
   # av4l_ocr_avi::getLabel
   # Retourne le nom de la fenetre 
   #
   proc getLabel { } {
      global caption

      return "$caption(av4l_ocr_avi,titre)"
   }
















   #
   # av4l_ocr_avi::chgdir
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
   # av4l_ocr_avi::fillConfigPage
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
      wm title $this $caption(av4l_ocr_avi,bar_title)
      wm protocol $this WM_DELETE_WINDOW "::av4l_ocr_avi::closeWindow $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_ocr_avi::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_ocr_avi
      set frmbbar $this.frm_av4l_ocr_avi_bar


      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "$caption(av4l_ocr_avi,titre)"
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
           -command "::av4l_ocr_avi::avi_open $visuNo $frm"
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
        scale $frm.percent -from 0 -to 1 -length 600 -variable ::av4l_ocr_avi::percent \
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
           -command "::av4l_ocr_avi::avi_quick_prev_image $frm $visuNo"
        pack $frm.qprevimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool av4l img arn.png ]
        button $frm.previmage -image .arn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_ocr_avi::avi_prev_image $frm $visuNo"
        pack $frm.previmage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool av4l img avn.png ]
        button $frm.nextimage -image .avn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_ocr_avi::avi_next_image $frm $visuNo"
        pack $frm.nextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool av4l img avr.png ]
        button $frm.qnextimage -image .avr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_ocr_avi::avi_quick_next_image $frm $visuNo"
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




  #--- infos datation

          #--- Cree un frame 
          frame $frm.tdatation -borderwidth 0 -cursor arrow
          pack $frm.tdatation -in $frm -side top -anchor w

          #---Titre
          label $frm.tdatation.title -font $av4lconf(font,arial_10_b) -text "Datation" 
          pack  $frm.tdatation.title -in $frm.tdatation -side top -anchor w -ipady 10


          #--- Cree un frame 
          frame $frm.datation -borderwidth 1 -relief raised -cursor arrow 
          pack $frm.datation -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Cree un frame 
          frame $frm.datation.values -borderwidth 0 -cursor arrow
          pack $frm.datation.values -in $frm.datation -side top -expand 5







          #--- Cree un frame pour activation/desactivation ocr
          set ocr [frame $frm.datation.values.setup -borderwidth 1]
          pack $ocr -in $frm.datation.values -side top -padx 30 -pady 1

              #--- Cree un frame
              frame $ocr.t -borderwidth 0 -cursor arrow
              pack  $ocr.t -in $ocr -side left -expand 5 -anchor w


              checkbutton $ocr.t.check -highlightthickness 0 -text "OCR" \
                          -variable ::av4l_ocr_avi::active_ocr \
                          -command "::av4l_ocr_avi::select_ocr $visuNo $frm" \
                         
              pack $ocr.t.check -in $ocr.t -side left -padx 5 -pady 0

              #--- Cree un label
              label $ocr.t.typelab -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                    -text "Type d'incrustateur : "
              pack  $ocr.t.typelab -in $ocr.t -side left -anchor w -padx 30

              #--- Cree un spinbox
              spinbox $ocr.t.typespin -font $av4lconf(font,courier_10) -fg $color(blue) \
                    -value [ list "Black Box" "TIM-10" ] -width 10  -state disabled
              pack  $ocr.t.typespin -in $ocr.t -side left -anchor w

              #--- Cree un label
              label $ocr.t.selectboxlab -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                    -text "Champ date :"
              pack  $ocr.t.selectboxlab -in $ocr.t -side left -anchor w -padx 30

              #--- Cree un bouton
              button $ocr.t.selectbox -text "Select" -borderwidth 1 -takefocus 1 \
                    -command "::av4l_ocr_avi::select_time $visuNo $frm"  -state disabled
              pack $ocr.t.selectbox -in $ocr.t -side left -anchor e 

          #--- Cree un frame pour activation/desactivation ocr
          set datetime [frame $frm.datation.values.datetime -borderwidth 1]
          pack $datetime -in $frm.datation.values -side top -padx 30 -pady 1

              #--- Cree un frame
              frame $datetime.y -borderwidth 0 -cursor arrow
              pack  $datetime.y -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.y.lab -text "Y"
                 pack $datetime.y.lab -in $datetime.y -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.y.val -takefocus 0 -justify left -width 5
                 pack $datetime.y.val -in $datetime.y -side top -padx 0 -expand 0


              #--- Cree un frame
              frame $datetime.a1 -borderwidth 0 -cursor arrow
              pack  $datetime.a1 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a1.lab -text ""
                 pack $datetime.a1.lab -in $datetime.a1 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a1.lab2 -text "-"
                 pack $datetime.a1.lab2 -in $datetime.a1 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.m -borderwidth 0 -cursor arrow
              pack  $datetime.m -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.m.lab -text "M"
                 pack $datetime.m.lab -in $datetime.m -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.m.val  -takefocus 0 -justify left -width 3
                 pack $datetime.m.val -in $datetime.m -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a2 -borderwidth 0 -cursor arrow
              pack  $datetime.a2 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a2.lab -text ""
                 pack $datetime.a2.lab -in $datetime.a2 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a2.lab2 -text "-"
                 pack $datetime.a2.lab2 -in $datetime.a2 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.d -borderwidth 0 -cursor arrow
              pack  $datetime.d -in $datetime -side left -expand 0 -anchor w -expand 0

                 #--- Label de l'en-tete FITS
                 label $datetime.d.lab -text "D"
                 pack $datetime.d.lab -in $datetime.d -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.d.val  -takefocus 0 -justify left -width 3
                 pack $datetime.d.val -in $datetime.d -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a3 -borderwidth 0 -cursor arrow
              pack  $datetime.a3 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a3.lab -text ""
                 pack $datetime.a3.lab -in $datetime.a3 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a3.lab2 -text "T"
                 pack $datetime.a3.lab2 -in $datetime.a3 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.h -borderwidth 0 -cursor arrow
              pack  $datetime.h -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.h.lab -text "H"
                 pack $datetime.h.lab -in $datetime.h -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.h.val  -takefocus 0 -justify left -width 3
                 pack $datetime.h.val -in $datetime.h -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a4 -borderwidth 0 -cursor arrow
              pack  $datetime.a4 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a4.lab -text ""
                 pack $datetime.a4.lab -in $datetime.a4 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a4.lab2 -text ":"
                 pack $datetime.a4.lab2 -in $datetime.a4 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.min -borderwidth 0 -cursor arrow
              pack  $datetime.min -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.min.lab -text "m"
                 pack $datetime.min.lab -in $datetime.min -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.min.val  -takefocus 0 -justify left -width 3
                 pack $datetime.min.val -in $datetime.min -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a5 -borderwidth 0 -cursor arrow
              pack  $datetime.a5 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a5.lab -text ""
                 pack $datetime.a5.lab -in $datetime.a5 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a5.lab2 -text ":"
                 pack $datetime.a5.lab2 -in $datetime.a5 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.s -borderwidth 0 -cursor arrow
              pack  $datetime.s -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.s.lab -text "s"
                 pack $datetime.s.lab -in $datetime.s -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.s.val  -takefocus 0 -justify left -width 3
                 pack $datetime.s.val -in $datetime.s -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.a6 -borderwidth 0 -cursor arrow
              pack  $datetime.a6 -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.a6.lab -text ""
                 pack $datetime.a6.lab -in $datetime.a6 -side top -padx 0 -expand 0
                 #--- Label de l'en-tete FITS
                 label $datetime.a6.lab2 -text "."
                 pack $datetime.a6.lab2 -in $datetime.a6 -side top -padx 0 -expand 0

              #--- Cree un frame
              frame $datetime.ms -borderwidth 0 -cursor arrow
              pack  $datetime.ms -in $datetime -side left -expand 0 -anchor w

                 #--- Label de l'en-tete FITS
                 label $datetime.ms.lab -text "ms"
                 pack $datetime.ms.lab -in $datetime.ms -side top -padx 0 -expand 0

                 #--- Label du nom de la configuration de l'en-tete FITS
                 entry $datetime.ms.val  -takefocus 0 -justify left -width 5
                 pack $datetime.ms.val -in $datetime.ms -side top -padx 0 -expand 0






          #--- Cree un frame pour activation/desactivation ocr
          set setunset [frame $frm.datation.values.setunset -borderwidth 1]
          pack $setunset -in $frm.datation.values -side top -padx 30 -pady 1

              #--- Cree un frame
              frame $setunset.t -borderwidth 0 -cursor arrow
              pack  $setunset.t -in $setunset -side left -expand 5 -anchor w

              #--- Cree un bouton
              button $setunset.t.verif -text "Verifié" -borderwidth 1 -takefocus 1 \
                                     -command "::av4l_ocr_avi::verif $visuNo $frm"
              pack $setunset.t.verif -in $setunset.t -side left -anchor e 

              #--- Cree un bouton
              button $setunset.t.ocr -text "OCR" -borderwidth 1 -takefocus 1 \
                                     -command ""
              pack $setunset.t.ocr -in $setunset.t -side left -anchor c 

              #--- Cree un bouton
              button $setunset.t.interpol -text "Interpolé" -borderwidth 1 -takefocus 1 \
                                     -command ""
              pack $setunset.t.interpol -in $setunset.t -side left -anchor w 



   #---
        #--- Cree un frame pour  les boutons d action 
        frame $frm.infofrm -borderwidth 1 -relief raised -cursor arrow
        pack $frm.infofrm -in $frm -side top -expand 0 -fill x -padx 1 -pady 1


          #--- Cree un frame pour afficher les intitules
          set intitle [frame $frm.infofrm.l -borderwidth 0]
          pack $intitle -in $frm.infofrm -side left

            #--- Cree un label pour le status
            label $intitle.nbimage -font $av4lconf(font,courier_10) -text "Nb images"
            pack $intitle.nbimage -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbverif -font $av4lconf(font,courier_10) -text "Nb verif"
            pack $intitle.nbverif -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbocr -font $av4lconf(font,courier_10) -text "Nb ocr"
            pack $intitle.nbocr -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbinterp -font $av4lconf(font,courier_10) -text "Nb interpole"
            pack $intitle.nbinterp -in $intitle -side top -anchor w

          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $frm.infofrm.v -borderwidth 0]
          pack $inparam -in $frm.infofrm -side left -expand 0 -fill x

            #--- Cree un label pour le status
            label $inparam.nbimage -font $av4lconf(font,courier_10) -text "-"
            pack $inparam.nbimage -in $inparam -side top -anchor w

            #--- Cree un label pour le nb d image
            label $inparam.nbverif -font $av4lconf(font,courier_10) -text "-"
            pack $inparam.nbverif -in $inparam -side top -anchor w

            #--- Cree un label pour le nb d image
            label $inparam.nbocr -font $av4lconf(font,courier_10) -text "-"
            pack $inparam.nbocr -in $inparam -side top -anchor w

            #--- Cree un label pour le nb d image
            label $inparam.nbinterp -font $av4lconf(font,courier_10) -text "-"
            pack $inparam.nbinterp -in $inparam -side top -anchor w

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
              -command "::av4l_ocr_avi::avi_start $visuNo $frm"
           pack $frm.action.start \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

           image create photo .save  -format PNG -file [ file join $audace(rep_plugin) tool av4l img save.png ]
           button $frm.action.save -image .save\
              -borderwidth 2 -width 48 -height 48 -compound center \
              -command "::av4l_ocr_avi::avi_save $visuNo $frm"
           pack $frm.action.save \
              -in $frm.action \
              -side left -anchor w \
              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

#           image create photo .graph  -format PNG -file [ file join $audace(rep_plugin) tool av4l img cdl.png ]
#           button $frm.action.graph -image .graph\
#              -borderwidth 2 -width 48 -height 48 -compound center \
#              -command ""
#           pack $frm.action.graph \
#              -in $frm.action \
#              -side left -anchor w \
#              -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(av4l_ocr_avi,fermer)" -borderwidth 2 \
              -command "::av4l_ocr_avi::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(av4l_ocr_avi,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool av4l av4l_ocr_avi.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   }
   
   











   proc select_time { visuNo frm } {

      global color

      set statebutton [ $frm.datation.values.setup.t.selectbox cget -relief]

      # desactivation
      if {$statebutton=="sunken"} {
         $frm.datation.values.setup.t.selectbox configure -text "Select" -fg $color(black)
         $frm.datation.values.setup.t.selectbox configure -relief raised
         return
      } 


      # activation
      if {$statebutton=="raised"} {

         # Recuperation du Rectangle de l image
         set rect  [ ::confVisu::getBox $visuNo ]

         # Affichage de la taille de la fenetre
         if {$rect==""} {
            set ::av4l_photom::rect_img ""
         } else {
            set taillex [expr [lindex $rect 2] - [lindex $rect 0] ]
            set tailley [expr [lindex $rect 3] - [lindex $rect 1] ]
            $frm.datation.values.setup.t.selectbox configure -text "${taillex}x${tailley}" -fg $color(blue)
            set ::av4l_photom::rect_img $rect
         }
         $frm.datation.values.setup.t.selectbox  configure -relief sunken
         ::av4l_ocr_avi::workimage $visuNo $frm
         return
      }

   }







   proc select_ocr { visuNo frm } {

      global color

      # desactivation
      if {$::av4l_ocr_avi::active_ocr=="0"} {
         $frm.datation.values.setup.t.typespin  configure -state disabled
         $frm.datation.values.setup.t.selectbox configure -state disabled
         $frm.datation.values.setunset.t.ocr   configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         $frm.datation.values.setunset.t.ocr   configure -state disabled
         return
      } else {
         $frm.datation.values.setup.t.typespin  configure -state normal
         $frm.datation.values.setup.t.selectbox configure -state normal
         $frm.datation.values.setunset.t.ocr    configure -state normal
         ::av4l_ocr_avi::workimage $visuNo $frm
         return
      }

   }











   proc workimage { visuNo frm } {

      global color 


      #set mirrory "?"
      #set mirrorx "?"
      #::console::affiche_resultat "mirrory : $mirrory \n"
      #::console::affiche_resultat "mirrorx : $mirrorx \n"


      set statebutton [ $frm.datation.values.setup.t.selectbox cget -relief]

      # desactivation
      if {$::av4l_ocr_avi::active_ocr=="1" && $statebutton=="sunken"} {

          set box [$frm.datation.values.setup.t.typespin get]
          #::console::affiche_resultat "box : $box \n"



          #set rect [$frm.datation.values.setup.t.selectbox get]
          set rect $::av4l_photom::rect_img
          #::console::affiche_resultat "rect : $rect \n"

          if { [info exists $rect] } {
             return 0
          }

          set bufNo [ visu$visuNo buf ]
          buf$bufNo window $rect
          buf$bufNo mirrory
          # buf1 save ocr.png
          set stat  [buf$bufNo stat]
          #::console::affiche_resultat "stat = $stat \n"

          buf$bufNo savejpeg ocr.jpg 100 [lindex $stat 3] [lindex $stat 0] 

          set err [ catch {set result [exec jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8 ]} msg ]

          #::console::affiche_resultat "err = $err \n"
          #::console::affiche_resultat "err = $err \n"
          #::console::affiche_resultat "msg = $msg \n"


          # avec deux points comme separateur
          #::console::affiche_resultat "** avec deux points comme separateur \n"
          set poslist [split $msg " "]
          #::console::affiche_resultat "   poslist = $poslist \n"
          set hms [lindex $poslist 0]
          #::console::affiche_resultat "   hms = $hms \n"
          set ms  [lindex $poslist 4]
          set poslist [split $hms "_"]
          #::console::affiche_resultat "   poslist = $poslist \n"
          set h   [lindex $poslist 0]
          set min [lindex $poslist 1]
          set s   [lindex $poslist 2]

          set pass "ok"
          if { $h<0 || $h>24 || $h=="" } {set pass "no"}
          if { $min<0 || $min>59 || $min=="" } {set pass "no"}
          if { $s<0 || $s>59 || $s=="" } {set pass "no"}
          if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}
          
          
          # avec des espaces comme separateur
          #::console::affiche_resultat "** avec des espaces comme separateur \n"
          if { $pass == "no" } {
             set poslist [split $msg " "]
             #::console::affiche_resultat "   poslist = $poslist \n"
             set h   [lindex $poslist 0]
             set min [lindex $poslist 1]
             set s   [lindex $poslist 2]
             set ms  [lindex $poslist 6]

             set pass "ok"
             if { $h<0 || $h>24 || $h=="" } {set pass "no"}
             if { $min<0 || $min>59 || $min=="" } {set pass "no"}
             if { $s<0 || $s>59 || $s=="" } {set pass "no"}
             if { $ms<0 || $ms>999 || $ms=="" } {set pass "no"}

          }
          
          
          if { $ms<10 } {
             set ms "00$ms"
          } elseif { $ms<100 } {
             set ms "0$ms"
          }
          if { $h<10 }   {set h "0$h"} 
          if { $min<10 } {set min "0$min"} 
          if { $s<10 }   {set s "0$s"} 
          
          
          set err [ catch {
          
              regexp {[0-9][0-9]} $h matched
              if { $h!=$matched }   {set pass "no"} 
              regexp {[0-9][0-9]} $min matched
              if { $min!=$matched }   {set pass "no"} 
              regexp {[0-9][0-9]} $s matched
              if { $s!=$matched }   {set pass "no"} 
              regexp {[0-9][0-9][0-9]} $ms matched
              if { $ms!=$matched }   {set pass "no"} 
          
          } msg ]
          
          if { $err != 0 } {set pass "no"} 
            
          
          # affichage des resultats
          if { $pass == "ok" } {
             #::console::affiche_resultat "OCR = $h:$min:$s.$ms \n"

             $frm.datation.values.datetime.h.val   delete 0 end
             $frm.datation.values.datetime.h.val   insert 0 $h

             $frm.datation.values.datetime.min.val delete 0 end
             $frm.datation.values.datetime.min.val insert 0 $min

             $frm.datation.values.datetime.s.val   delete 0 end
             $frm.datation.values.datetime.s.val   insert 0 $s

             $frm.datation.values.datetime.ms.val  delete 0 end
             $frm.datation.values.datetime.ms.val  insert 0 $ms

             $frm.datation.values.setunset.t.ocr   configure -bg "#00891b" -fg $color(white)
             return 1

          } else {
             #::console::affiche_resultat "OCR Failed \n"
             $frm.datation.values.datetime.h.val   delete 0 end
             $frm.datation.values.datetime.h.val   insert 0 $h

             $frm.datation.values.datetime.min.val delete 0 end
             $frm.datation.values.datetime.min.val insert 0 $min

             $frm.datation.values.datetime.s.val   delete 0 end
             $frm.datation.values.datetime.s.val   insert 0 $s

             $frm.datation.values.datetime.ms.val  delete 0 end
             $frm.datation.values.datetime.ms.val  insert 0 $ms
             $frm.datation.values.setunset.t.ocr   configure -bg $color(red) -fg $color(white)
             
             return 0
          }
          

#         23_40_50  9_5  925
 

      }
      
   }















   proc getinfofrm { visuNo frm } {
 
    global color
 

          set idframe $::av4l_tools::cur_idframe
          ::console::affiche_resultat "$idframe - "
          ::console::affiche_resultat "$::av4l_ocr_avi::timing($idframe,verif) . "
          ::console::affiche_resultat "$::av4l_ocr_avi::timing($idframe,ocr) . "
          ::console::affiche_resultat "$::av4l_ocr_avi::timing($idframe,interpol) \n"


          $frm.infofrm.v.nbimage configure -text $::av4l_tools::nb_frames

          $frm.infofrm.v.nbverif configure -text $::av4l_ocr_avi::nbverif

          set p [format %2.1f [expr $::av4l_ocr_avi::nbocr/($::av4l_tools::nb_frames*1.0)*100.0]]
          $frm.infofrm.v.nbocr configure -text "$::av4l_ocr_avi::nbocr ($p %)"

          set p [format %2.1f [expr $::av4l_ocr_avi::nbinterp/($::av4l_tools::nb_frames*1.0)*100.0]]
          $frm.infofrm.v.nbinterp configure -text "$::av4l_ocr_avi::nbinterp ($p %)"

          if {$::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,verif) == 1} {
             $frm.datation.values.setunset.t.verif configure -bg "#00891b" -fg $color(white)
             $frm.datation.values.setunset.t.verif configure -relief sunken
          } else {
             $frm.datation.values.setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
             $frm.datation.values.setunset.t.verif configure -relief raised
          }
          if {$::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,interpol) == 1} {
             $frm.datation.values.setunset.t.interpol configure -bg "#00891b" -fg $color(white)
             $frm.datation.values.setunset.t.interpol configure -relief sunken
          } else {
             $frm.datation.values.setunset.t.interpol configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
             $frm.datation.values.setunset.t.interpol configure -relief raised
          }
          
          
          if {$::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,verif) == 1 || $::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,interpol) == 1} {

          set poslist [split $::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,dateiso) "T"]
          #::console::affiche_resultat "   poslist = $poslist \n"
          set ymd [lindex $poslist 0]
          set hms [lindex $poslist 1]
          set poslist [split $ymd "-"]
          #::console::affiche_resultat "   poslist ymd = $poslist \n"
          set y [lindex $poslist 0]
          set m [lindex $poslist 1]
          set d [lindex $poslist 2]
          set poslist [split $hms ":"]
          #::console::affiche_resultat "   poslist hms = $poslist \n"
          set h [lindex $poslist 0]
          set min [lindex $poslist 1]
          set sms [lindex $poslist 2]
          set poslist [split $sms "."]
          #::console::affiche_resultat "   poslist hms = $poslist \n"
          set s [lindex $poslist 0]
          set ms [lindex $poslist 1]
          #::console::affiche_resultat "$y-$m-${d}T$h:$min:$s.$ms\n"
          $frm.datation.values.datetime.y.val   delete 0 end
          $frm.datation.values.datetime.y.val   insert 0 $y

          $frm.datation.values.datetime.m.val delete 0 end
          $frm.datation.values.datetime.m.val insert 0 $m

          $frm.datation.values.datetime.d.val   delete 0 end
          $frm.datation.values.datetime.d.val   insert 0 $d

          $frm.datation.values.datetime.h.val   delete 0 end
          $frm.datation.values.datetime.h.val   insert 0 $h

          $frm.datation.values.datetime.min.val delete 0 end
          $frm.datation.values.datetime.min.val insert 0 $min

          $frm.datation.values.datetime.s.val   delete 0 end
          $frm.datation.values.datetime.s.val   insert 0 $s

          $frm.datation.values.datetime.ms.val  delete 0 end
          $frm.datation.values.datetime.ms.val  insert 0 $ms
             
           }
         
          
   } 








   proc verif_2numdigit { x } {
          set res [ regexp {[0-9]{1,2}} $x matched ]
          if { ! $res } { return 1 } 
          if { $x != $matched } {return 1} 
          return 0
   }
   proc verif_yeardigit { x } {
          set res [ regexp {[1-2][0-9]{3}} $x matched ]
          if { ! $res } { return 1 } 
          if { $x!=$matched } {return 1} 
          return 0
   }
   proc verif_hourdigit { x } {
          set res [ regexp {[0-9]{1,2}} $x matched ]
          if { ! $res } { return 1 } 
          if { $x!=$matched } {return 1}
          if { $x<0 || $x>24 || $x=="" } {return 1}
          return 0
   }
   proc verif_msdigit { x } {
          set res [ regexp {[0-9]{1,3}} $x matched ]
          if { ! $res } { return 1 } 
          if { $x != $matched } {return 1} 
          return 0
   }

   proc return_2digit { x } {
          set res [ regexp {[0-9]{2}} $x matched ]
          if { $res } { return $x } 
          if { $x<10 } {set x "0$x"} 
          return $x
   }
   proc return_3digit { x } {
          set res [ regexp {[0-9]{3}} $x matched ]
          if { $res } { return $x } 
          if { $x<10 } {
             set x "00$x"
          } elseif { $x<100 } {
             set x "0$x"
          }
          return $x
   }






   proc verif { visuNo frm } {
 
      global color
 

      set statebutton [ $frm.datation.values.setunset.t.verif cget -relief]

      # desactivation
      if {$statebutton=="sunken"} {
         $frm.datation.values.setunset.t.verif configure -bg $::audace(color,backColor) -fg $::audace(color,textColor)
         $frm.datation.values.setunset.t.verif configure -relief raised
         incr ::av4l_ocr_avi::nbverif -1
         set ::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,verif) 0
         ::av4l_ocr_avi::workimage $visuNo $frm
         getinfofrm $visuNo $frm
         return
      } 



      set y   [$frm.datation.values.datetime.y.val get]              
      set m   [$frm.datation.values.datetime.m.val get]              
      set d   [$frm.datation.values.datetime.d.val get]              
      set h   [$frm.datation.values.datetime.h.val get]              
      set min [$frm.datation.values.datetime.min.val get]
      set s   [$frm.datation.values.datetime.s.val get]
      set ms  [$frm.datation.values.datetime.ms.val get]

      if { [verif_yeardigit $y] } {
          tk_messageBox -message "Veuillez entrer une année valide\n ex : 2012" -type ok
          return
      }
      if { [verif_2numdigit $m] } {
          tk_messageBox -message "Veuillez entrer un mois valide\n ex : 12" -type ok
          return
      }
      if { [verif_2numdigit $d] } {
          tk_messageBox -message "Veuillez entrer un jour valide\n ex : 12" -type ok
          return
      }
      if { [verif_hourdigit $h] } {
          tk_messageBox -message "Veuillez entrer une heure valide\n ex : 12" -type ok
          return
      }
      if { [verif_2numdigit $min] } {
          tk_messageBox -message "Veuillez entrer une minute valide\n ex : 12" -type ok
          return
      }
      if { [verif_2numdigit $s] } {
          tk_messageBox -message "Veuillez entrer une seconde valide\n ex : 12" -type ok
          return
      }
      if { [verif_msdigit $ms] } {
          tk_messageBox -message "Veuillez entrer une milli-seconde valide\n ex : 012" -type ok
          return
      }
      set m   [return_2digit $m]
      set d   [return_2digit $d]
      set h   [return_2digit $h]
      set min [return_2digit $min]
      set s   [return_2digit $s]
      set ms  [return_3digit $ms]
      
      ::console::affiche_resultat "$y-$m-${d}T$h:$min:$s.$ms\n"
      $frm.datation.values.datetime.y.val   delete 0 end
      $frm.datation.values.datetime.y.val   insert 0 $y

      $frm.datation.values.datetime.m.val delete 0 end
      $frm.datation.values.datetime.m.val insert 0 $m

      $frm.datation.values.datetime.d.val   delete 0 end
      $frm.datation.values.datetime.d.val   insert 0 $d

      $frm.datation.values.datetime.h.val   delete 0 end
      $frm.datation.values.datetime.h.val   insert 0 $h

      $frm.datation.values.datetime.min.val delete 0 end
      $frm.datation.values.datetime.min.val insert 0 $min

      $frm.datation.values.datetime.s.val   delete 0 end
      $frm.datation.values.datetime.s.val   insert 0 $s

      $frm.datation.values.datetime.ms.val  delete 0 end
      $frm.datation.values.datetime.ms.val  insert 0 $ms

      $frm.datation.values.setunset.t.verif configure -bg "#00891b" -fg $color(white)
      $frm.datation.values.setunset.t.verif configure -relief sunken
      
      incr ::av4l_ocr_avi::nbverif
      set ::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,verif) 1
      set ::av4l_ocr_avi::timing($::av4l_tools::cur_idframe,dateiso) "$y-$m-${d}T$h:$min:$s.$ms"
      #tk_messageBox -message "$caption(bddimages_status,consoleErr3) $msg" -type ok
      getinfofrm $visuNo $frm

      }


   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   






   
   
   
   
   
   
   
   
   
   
   
 
 





 
 
 
 
 
 
   proc avi_stop {  } {
      ::console::affiche_resultat "-- stop \n"
      set ::av4l_ocr_avi::sortie 1
   }   
 
 
 
 
 
 
 
   proc avi_open { visuNo frm } {
      ::av4l_tools::avi_open $visuNo $frm
      for  {set x 1} {$x<=$::av4l_tools::nb_frames} {incr x} {
         set ::av4l_ocr_avi::timing($x,verif) 0
         set ::av4l_ocr_avi::timing($x,ocr) 0
         set ::av4l_ocr_avi::timing($x,interpol) 0
         set ::av4l_ocr_avi::timing($x,jd)  ""
         set ::av4l_ocr_avi::timing($x,diff)  ""
         set ::av4l_ocr_avi::timing($x,dateiso) ""
      }

   }







   proc avi_start { visuNo frm } {
 

      set idframedebut [::av4l_tools::avi_get_idframe] 
 
      if { $::av4l_ocr_avi::timing($idframedebut,verif) != 1 } {
          tk_messageBox -message "Veuillez commencer par une image verifiée" -type ok
          return
      }
 
      set ::av4l_ocr_avi::sortie 0
      set cpt 0
      $frm.action.start configure -image .stop
      $frm.action.start configure -relief sunken     
      $frm.action.start configure -command " ::av4l_ocr_avi::avi_stop" 
      
      set ::av4l_ocr_avi::nbocr 0
      set ::av4l_ocr_avi::nbinterp 0
      
      
      while {$::av4l_ocr_avi::sortie == 0} {

         getinfofrm $visuNo $frm
         set idframe [::av4l_tools::avi_get_idframe] 
         #::console::affiche_resultat "\[$idframe / $::av4l_tools::nb_frames / [expr $::av4l_tools::nb_frames-$idframe] \]\n"
         ::console::affiche_resultat "."
         if {$idframe == $::av4l_tools::nb_frames} {
            set ::av4l_ocr_avi::sortie 1
         }
         
         set pass "no"

    
     # Verifié

         if {$::av4l_ocr_avi::timing($idframe,verif) == 1} {

            # calcul jd
            set ::av4l_ocr_avi::timing($idframe,jd) [mc_date2jd $::av4l_ocr_avi::timing($idframe,dateiso)]
            #::console::affiche_resultat "\[$idframe / $::av4l_tools::nb_frames / [expr $::av4l_tools::nb_frames-$idframe] \] V\n"

            ::av4l_tools::avi_next_image  
            set pass "ok"
         }

      # OCR
      
         if {$pass == "no"} {
            set res [::av4l_ocr_avi::workimage $visuNo $frm]
            if {$res==1} {

               # calcul iso

               set y   [$frm.datation.values.datetime.y.val get]              
               set m   [$frm.datation.values.datetime.m.val get]              
               set d   [$frm.datation.values.datetime.d.val get]              
               set h   [$frm.datation.values.datetime.h.val get]              
               set min [$frm.datation.values.datetime.min.val get]
               set s   [$frm.datation.values.datetime.s.val get]
               set ms  [$frm.datation.values.datetime.ms.val get]

               set  pass "ok"
               if { [verif_yeardigit $y] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $m] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $d] } {
                  set  pass "no"
               }
               if { [verif_hourdigit $h] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $min] } {
                  set  pass "no"
               }
               if { [verif_2numdigit $s] } {
                  set  pass "no"
               }
               if { [verif_msdigit $ms] } {
                  set  pass "no"
               }

               if { $pass == "ok" } {
                  set m   [return_2digit $m]
                  set d   [return_2digit $d]
                  set h   [return_2digit $h]
                  set min [return_2digit $min]
                  set s   [return_2digit $s]
                  set ms  [return_3digit $ms]

                  incr ::av4l_ocr_avi::nbocr
                  set ::av4l_ocr_avi::timing($idframe,dateiso) "$y-$m-${d}T$h:$min:$s.$ms"
                  set ::av4l_ocr_avi::timing($idframe,jd) [mc_date2jd $::av4l_ocr_avi::timing($idframe,dateiso)]

                  set ::av4l_ocr_avi::timing($idframe,ocr) 1
                  set ::av4l_ocr_avi::timing($idframe,interpol) 0
                  #::console::affiche_resultat "\[$idframe / $::av4l_tools::nb_frames / [expr $::av4l_tools::nb_frames-$idframe] \] O\n"
                  ::av4l_tools::avi_next_image  
                  set pass "ok"
               }
            }
         }
         
       # interpolation
       
         if {$pass == "no"} {
            set ::av4l_ocr_avi::timing($idframe,interpol) 1
            set ::av4l_ocr_avi::timing($idframe,ocr) 0
            incr ::av4l_ocr_avi::nbinterp
            #::console::affiche_resultat "\[$idframe / $::av4l_tools::nb_frames / [expr $::av4l_tools::nb_frames-$idframe] \] I\n"
            ::av4l_tools::avi_next_image  
         }



       }
       
       set idframefin $idframe 
       #::console::affiche_resultat "Frame de $idframedebut a $idframefin"



# Verification des OCR

          #::console::affiche_resultat "Verification des OCR \n"

       
          set ::av4l_ocr_avi::sortie 0
          
          set idframe $idframedebut
          while {$::av4l_ocr_avi::sortie == 0} {

             #::console::affiche_resultat "."
             if {$idframe == $idframefin} {
                set ::av4l_ocr_avi::sortie 1
             }
             
             if {$::av4l_ocr_avi::timing($idframe,ocr) == 1} {
               
               # OK on interpole !
                 #::console::affiche_resultat "-$idframe-"
               
                 set idfrmav [ get_idfrmav $idframe 2]
                 set idfrmap [ get_idfrmap $idframe 1]
                 #::console::affiche_resultat "$idfrmav < $idfrmap"
                 if { $idfrmav == -1 || $idfrmap == -1 } {
                    set idfrmav [ get_idfrmap 0 1]
                    set idfrmap [ get_idfrmav [expr $::av4l_tools::nb_frames + 1)] 1]
                 }
                 #::console::affiche_resultat "VO : $idframe ($idfrmav<$idfrmap)  "
                 
                 set jdav $::av4l_ocr_avi::timing($idfrmav,jd)
                 set jdap $::av4l_ocr_avi::timing($idfrmap,jd)
                                  
                 set jd [expr $jdav+($jdap-$jdav)/($idfrmap-$idfrmav)*($idframe-$idfrmav)]
                 set jd [ format "%6.10f" $jd]
                 
                 set diff [ expr   abs(($::av4l_ocr_avi::timing($idframe,jd) - $jd ) * 86400.0) ]                            
                 #::console::affiche_resultat "diff = $diff\n"
                 if { $diff > 1.0 } {
                      ::console::affiche_erreur "Warning! ($idframe) $::av4l_ocr_avi::timing($idframe,dateiso)\n"
                      set ::av4l_ocr_avi::timing($idframe,ocr) 0
                      set ::av4l_ocr_avi::timing($idframe,interpol) 1
                 }
                 
             }
             incr idframe
          }



# interpolation des dates

          #::console::affiche_resultat "Interpolation \n"

       
          set ::av4l_ocr_avi::sortie 0
          
          set idframe $idframedebut
          while {$::av4l_ocr_avi::sortie == 0} {

             #::console::affiche_resultat "."
             if {$idframe == $idframefin} {
                set ::av4l_ocr_avi::sortie 1
             }
             
             if {$::av4l_ocr_avi::timing($idframe,interpol) == 1} {
               
               # OK on interpole !
                 #::console::affiche_resultat "-$idframe-"
               
                 set idfrmav [ get_idfrmav $idframe 2]
                 set idfrmap [ get_idfrmap $idframe 2]
                 #::console::affiche_resultat "$idfrmav < $idfrmap"
                 if { $idfrmav == -1 } {
                    # il faut interpoler par 2 a droite
                    set idfrmav $idfrmap
                    set idfrmap [ get_idfrmap $idfrmap 2]
                 }
                 if { $idfrmap == -1 } {
                    # il faut interpoler par 2 a gauche
                    set idfrmap $idfrmav
                    set idfrmav [ get_idfrmav $idfrmav 2]
                 }
                 if { $idfrmav == -1 || $idfrmap == -1 } {
                    set idfrmav [ get_idfrmap 0 1]
                    set idfrmap [ get_idfrmav [expr $::av4l_tools::nb_frames + 1)] 1]
                 }
                 #::console::affiche_resultat "I : $idframe ($idfrmav<$idfrmap)  "
                 set jdav $::av4l_ocr_avi::timing($idfrmav,jd)
                 set jdap $::av4l_ocr_avi::timing($idfrmap,jd)
                                  
                 set jd [expr $jdav+($jdap-$jdav)/($idfrmap-$idfrmav)*($idframe-$idfrmav)]
                 set jd [ format "%6.10f" $jd]
                 
                 #::console::affiche_resultat "JD=$jd"
                 set dateiso [mc_date2iso8601 $jd]
                 set ::av4l_ocr_avi::timing($idframe,jd) $jd
                 set ::av4l_ocr_avi::timing($idframe,dateiso) $dateiso
                 
             }
           incr idframe
          }
       





   




#   #  Calcul des moyennes
#
#          ::console::affiche_resultat "Calcul des moyennes : "
#
#          set x_avg 0
#          set y_avg 0
#          set cpt 0
#          set ::av4l_ocr_avi::sortie 0
#          set idframe $idframedebut
#          while {$::av4l_ocr_avi::sortie == 0} {
#             if {$idframe == $idframefin} {
#                set ::av4l_ocr_avi::sortie 1
#             }
#             if {$::av4l_ocr_avi::timing($idframe,verif) == 1 || $::av4l_ocr_avi::timing($idframe,ocr) == 1} {
#                set x_avg [expr $x_avg+$idframe]
#                set y_avg [expr $y_avg+$::av4l_ocr_avi::timing($idframe,jd)]
#                incr cpt
#             }
#             incr idframe
#          }
#          set x_avg [expr $x_avg/($cpt*1.0)]
#          set y_avg [expr $y_avg/($cpt*1.0)]
#          ::console::affiche_resultat "x_avg $x_avg y_avg $y_avg\n"
#
#   #  Calcul des coefficients lineaires
#   
#          ::console::affiche_resultat "Calcul des coefficients lineaires : "
#
#          set sum1 0
#          set sum2 0
#          set cpt 0
#          set ::av4l_ocr_avi::sortie 0
#          set idframe $idframedebut
#          while {$::av4l_ocr_avi::sortie == 0} {
#             if {$idframe == $idframefin} {
#                set ::av4l_ocr_avi::sortie 1
#             }
#             if {$::av4l_ocr_avi::timing($idframe,verif) == 1 || $::av4l_ocr_avi::timing($idframe,ocr) == 1} {
#                set sum1 [expr $sum1 + ($idframe-$x_avg)*($::av4l_ocr_avi::timing($idframe,jd)-$y_avg)]
#                set sum2 [expr $sum2 + pow(($idframe-$x_avg),2)]
#                incr cpt
#             }
#             incr idframe
#          }
#          set b1 [expr $sum1/$sum2]
#          set b0 [expr $y_avg - $b1 * $x_avg]
#          ::console::affiche_resultat "b1 $b1 b0 $b0\n"
#
#   #  comparaison
#   
#   
#          ::console::affiche_resultat "Comparaison\n"
#
#          set ::av4l_ocr_avi::sortie 0
#          set idframe $idframedebut
#          while {$::av4l_ocr_avi::sortie == 0} {
#             if {$idframe == $idframefin} {
#                set ::av4l_ocr_avi::sortie 1
#             }
#             set y [ expr $b1 * $idframe + $b0 ]
#             set diff [expr ($::av4l_ocr_avi::timing($idframe,jd)-$y)*86400.0]
#             set ::av4l_ocr_avi::timing($idframe,diff) $diff
#             if { $diff > 1.0 } {
#                if {$::av4l_ocr_avi::timing($idframe,ocr) == 1} {
#                    set ::av4l_ocr_avi::timing($idframe,ocr) 0
#                    set ::av4l_ocr_avi::timing($idframe,interpol) 1
#                    incr ::av4l_ocr_avi::nbinterp
#                    incr ::av4l_ocr_avi::nbocr -1
#                   ::console::affiche_resultat "REJECTED ($idframe) $::av4l_ocr_avi::timing($idframe,dateiso)\n"
#                    
#                }
#                if {$::av4l_ocr_avi::timing($idframe,ocr) == 1} {
#                   ::console::affiche_erreur "***\n"
#                   ::console::affiche_erreur "Attention une erreur de datation risque de flinguer le pocessus\n"
#                   ::console::affiche_erreur "IDFRAME = $idframe\n"
#                   ::console::affiche_erreur "DATEVERIF = $::av4l_ocr_avi::timing($idframe,dateiso)\n"
#                   ::console::affiche_erreur "DIFF = $diff\n"
#                   ::console::affiche_erreur "***\n"
#                }
#             }
#
#             incr idframe
#          }


      $frm.action.start configure -image .start
      $frm.action.start configure -relief raised     
      $frm.action.start configure -command "::av4l_ocr_avi::avi_start $visuNo $frm" 
      ::console::affiche_resultat "Fin\n"

   }



   proc get_idfrmav { idframe gtype } {

       set stop 0
       set id $idframe
       while {$stop == 0} {
          incr id -1
          if {$id == 0} { return -1 }
          if { $gtype == 1 } {
             if {$::av4l_ocr_avi::timing($id,verif) == 1} {
                return $id
             }
          }
          if { $gtype == 2 } {
             if {$::av4l_ocr_avi::timing($id,verif) == 1 || $::av4l_ocr_avi::timing($id,ocr) == 1 } {
                return $id
             }
          }
       }
       return -1
   }
   
   proc get_idfrmap { idframe gtype } {

       set stop 0
       set id $idframe
       while {$stop == 0} {
          incr id 
          if {$id > $::av4l_tools::nb_frames} { break }
          if { $gtype == 1 } {
             if {$::av4l_ocr_avi::timing($id,verif) == 1} {
                return $id
             }
          }
          if { $gtype == 2 } {
             if {$::av4l_ocr_avi::timing($id,verif) == 1 || $::av4l_ocr_avi::timing($id,ocr) == 1 } {
                return $id
             }
          }
       }
       return -1
   }


 
   proc avi_save { visuNo frm } {
 

      set bufNo [ visu$visuNo buf ]
      set filename [$frm.open.avipath get]
      if { ! [file exists $filename] } {
      ::console::affiche_erreur "Charger une video ...\n"
      } 
      set racinefilename "${filename}."

      set filename "${racinefilename}time"

      ::console::affiche_resultat "Sauvegarde dans ${filename} ..."
      set f1 [open $filename "w"]
      puts $f1 "# ** AV4L - Audela - Linux  * "
      puts $f1 "#FPS = 25"
      set line "idframe, jd, dateiso, verif, ocr, interpol"
      puts $f1 $line

      set sortie 0
      set idframe 0
      set cpt 0
      while {$sortie == 0} {

         incr idframe

         if {$idframe == $::av4l_tools::nb_frames} {
            set sortie 1
         }
         
         set line "$idframe,"
         
         if { ! [info exists ::av4l_ocr_avi::timing($idframe,jd)] ||  $::av4l_ocr_avi::timing($idframe,jd) == ""} { continue }
         
         append line [ format %6.10f $::av4l_ocr_avi::timing($idframe,jd)] "  ,"
#         append line "$::av4l_ocr_avi::timing($idframe,diff)     ,"


         append line "$::av4l_ocr_avi::timing($idframe,dateiso)     ,"
         append line "$::av4l_ocr_avi::timing($idframe,verif)     ,"
         append line "$::av4l_ocr_avi::timing($idframe,ocr)     ,"
         append line "$::av4l_ocr_avi::timing($idframe,interpol)"

         puts $f1 $line
      }

      close $f1
      ::console::affiche_resultat "nb frame save = $idframe   .. Fin  ..\n"
      

   }

 
   #
   # av4l_ocr_avi::avi_next_image
   # Passe a l image suivante
   #
   proc avi_next_image { frm visuNo } {
         
      cleanmark
      ::av4l_tools::avi_next_image  
      ::av4l_ocr_avi::workimage $visuNo $frm
      ::av4l_ocr_avi::getinfofrm $visuNo $frm
   }
   
   #
   # av4l_ocr_avi::avi_next_image
   # Passe a l image suivante
   #
   proc avi_prev_image { frm visuNo } {
         
      ::av4l_tools::avi_prev_image  
      ::av4l_ocr_avi::workimage $visuNo $frm
      ::av4l_ocr_avi::getinfofrm $visuNo $frm
   }
   

   #
   # av4l_ocr_avi::avi_next_image
   # Passe a l image suivante
   #
   proc avi_quick_next_image { frm visuNo } {
         
      ::av4l_tools::avi_quick_next_image  
      ::av4l_ocr_avi::workimage $visuNo $frm
      ::av4l_ocr_avi::getinfofrm $visuNo $frm
   }
   
   #
   # av4l_ocr_avi::avi_next_image
   # Passe a l image suivante
   #
   proc avi_quick_prev_image { frm visuNo } {
         
      ::av4l_tools::avi_quick_prev_image  
      ::av4l_ocr_avi::workimage $visuNo $frm
      ::av4l_ocr_avi::getinfofrm $visuNo $frm
   }
   














   
   

}


#--- Initialisation au demarrage
::av4l_ocr_avi::init
