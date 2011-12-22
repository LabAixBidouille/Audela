#--------------------------------------------------
# source audace/plugin/tool/av4l/av4l_extraction.tcl
#--------------------------------------------------
#
# Fichier        : av4l_extraction.tcl
# Description    : Affiche le status de la base de donnees
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#

namespace eval ::av4l_extraction {






   #
   # Chargement des captions
   #
   proc ::av4l_extraction::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_extraction.cap ]
   }





   #
   # Initialisation des variables de configuration
   #
   proc ::av4l_extraction::initToConf { visuNo } {
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
   proc ::av4l_extraction::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::av4l_extraction::panneau(av4l,$visuNo,messages)                   $::av4l::parametres(av4l,$visuNo,messages)
      set ::av4l_extraction::panneau(av4l,$visuNo,save_file_log)              $::av4l::parametres(av4l,$visuNo,save_file_log)
      set ::av4l_extraction::panneau(av4l,$visuNo,alarme_fin_serie)           $::av4l::parametres(av4l,$visuNo,alarme_fin_serie)
      set ::av4l_extraction::panneau(av4l,$visuNo,verifier_ecraser_fichier)   $::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
      set ::av4l_extraction::panneau(av4l,$visuNo,verifier_index_depart)      $::av4l::parametres(av4l,$visuNo,verifier_index_depart)

      set ::av4l_tools::traitement "avi"

   }





   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::av4l_extraction::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }






   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::av4l_extraction::run { visuNo this } {

     global audace panneau

      set panneau(av4l,$visuNo,av4l_extraction) $this
      ::av4l_extraction::createdialog $this $visuNo   

   }





   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::av4l_extraction::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_extraction.htm
   }






   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::av4l_extraction::closeWindow { this visuNo } {

      ::av4l_extraction::widgetToConf $visuNo
      destroy $this
   }










   #
   # Creation de l'interface graphique
   #
   proc ::av4l_extraction::createdialog { this visuNo } {

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
      wm title $this $caption(av4l_extraction,titre)
      wm protocol $this WM_DELETE_WINDOW "::av4l_extraction::closeWindow $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_extraction::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_extraction


      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

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
           -command "::av4l_tools::open_flux $visuNo $frm"
        pack $frm.open.but_open \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton select
        button $frm.open.but_select \
           -text "..." -borderwidth 2 -takefocus 1 \
           -command "::av4l_tools::select $visuNo $frm"
        pack $frm.open.but_select \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un label pour le chemin de l'AVI
        entry $frm.open.avipath 
        pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

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
           -command "::av4l_tools::quick_prev_image $visuNo"
        pack $frm.qprevimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool av4l img arn.png ]
        button $frm.previmage -image .arn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_tools::prev_image $visuNo"
        pack $frm.previmage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool av4l img avn.png ]
        button $frm.nextimage -image .avn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_tools::next_image $visuNo"
        pack $frm.nextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool av4l img avr.png ]
        button $frm.qnextimage -image .avr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::av4l_tools::quick_next_image $visuNo"
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





          #--- Cree un frame pour afficher
          frame $frm.count -borderwidth 0
          pack $frm.count -in $frm -side top

             #--- Cree un label
             label $frm.labnbimg -font $av4lconf(font,courier_10) -padx 3 \
                   -text "Nombre d'images a extraire : "
             pack $frm.labnbimg -in $frm.count -side left -pady 1 -anchor w
             #--- Cree un entry
             entry $frm.imagecount -fg $color(blue) -relief sunken
             pack $frm.imagecount -in $frm.count -side left -pady 1 -anchor w
             #--- Cree un button
             button $frm.doimagecount \
              -text "calcul" -borderwidth 2 \
              -command "::av4l_tools_avi::imagecount $frm" 
             pack $frm.doimagecount -in $frm.count -side left -pady 1 -anchor w

          #--- Cree un frame pour 
          frame $frm.status -borderwidth 0 -cursor arrow
          pack $frm.status -in $frm -side top -expand 0

          #--- Cree un frame pour afficher les intitules
          set intitle [frame $frm.status.l -borderwidth 0]
          pack $intitle -in $frm.status -side left

            #--- Cree un label pour le status
            label $intitle.status -font $av4lconf(font,courier_10) -text "Status"
            pack $intitle.status -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbtotal -font $av4lconf(font,courier_10) -text "Nb total d'images"
            pack $intitle.nbtotal -in $intitle -side top -anchor w


          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $frm.status.v -borderwidth 0]
          pack $inparam -in $frm.status -side left -expand 0 -fill x

            #--- Cree un label pour le 
            label $inparam.status -font $av4lconf(font,courier_10) -fg $color(blue) -text "-"
            pack  $inparam.status -in $inparam -side top -anchor w

            #--- Cree un label pour le 
            label $inparam.nbtotal -font $av4lconf(font,courier_10) -fg $color(blue) -text "-"
            pack  $inparam.nbtotal -in $inparam -side top -anchor w





        #--- Cree un frame pour 
        frame $frm.form \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.form \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Cree un frame pour afficher les intitules
          set intitle [frame $frm.form.l -borderwidth 0]
          pack $intitle -in $frm.form -side left

            #--- Cree un label pour le status
            label $intitle.destdir -font $av4lconf(font,courier_10) -padx 3 \
                  -text "repertoire destination"
            pack $intitle.destdir -in $intitle -side top -padx 3 -pady 1 -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.prefix -font $av4lconf(font,courier_10) \
                  -text "prefixe des fichiers"
            pack $intitle.prefix -in $intitle -side top -padx 3 -pady 1 -anchor w


          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $frm.form.v -borderwidth 0]
          pack $inparam -in $frm.form -side left -expand 0 -fill x

            #--- Cree un label pour le repetoire destination
            entry $inparam.destdir -fg $color(blue)
            pack $inparam.destdir -in $inparam -side top -pady 1 -anchor w

            #--- Cree un label pour le prefixe
            entry $inparam.prefix  -fg $color(blue)
            pack $inparam.prefix -in $inparam -side top -pady 1 -anchor w

          #--- Cree un frame pour afficher les extras
          set inbutton [frame $frm.form.e -borderwidth 0]
          pack $inbutton -in $frm.form -side left -expand 0 -fill x

            #--- Cree un button
            button $inbutton.chgdir \
             -text "..." -borderwidth 2 \
             -command "::av4l_tools::chgdir $inparam.destdir" 
            pack $inbutton.chgdir -in $inbutton -side top -pady 0 -anchor w

            #--- Cree un label pour le nb d image
            label $inbutton.blank -font $av4lconf(font,courier_10) \
                  -text ""
            pack $inbutton.blank -in $inbutton -side top -padx 3 -pady 1 -anchor w


   #---
        #--- Cree un frame pour  les boutons d action 
        frame $frm.action \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           button $frm.action.extract \
              -text "Extraction" -borderwidth 2 \
              -command " ::av4l_extraction::extract $visuNo $frm "
           pack $frm.action.extract -in $frm.action \
              -side left -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(av4l_extraction,fermer)" -borderwidth 2 \
              -command "::av4l_extraction::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(av4l_extraction,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool av4l av4l_extraction.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0





   }






   proc ::av4l_extraction::extract { visuNo frm } {
      global audace

      set bufNo [ visu$visuNo buf ]

      set fmin    [ $frm.posmin get ]
      set fmax    [ $frm.posmax get ]
      set destdir [ $frm.form.v.destdir get ]
      set prefix  [ $frm.form.v.prefix get ]
      set i 0
      set cpt 1
      if { $fmin == "" } {
         set fmin 1
      }
      if { $fmax == "" } {
         set fmax $::av4l_tools::nb_open_frames
      }
      #::console::affiche_resultat "fmin=$fmin\n"
      #::console::affiche_resultat "fmax=$fmax\n"


      ::av4l_tools_avi::set_frame $fmin
      for {set i $fmin} {$i <= $fmax} {incr i} {
         set ::av4l_tools::scrollbar $::av4l_tools::cur_idframe
         visu$visuNo disp
         #::console::affiche_resultat "$i / [expr $fmax-$fmin+1]\n"
         ::console::affiche_resultat ""
         
         set path "$destdir/$prefix$cpt"
         #::console::affiche_resultat "path : $path\n"
         buf$bufNo save $path fits
         ::av4l_tools_avi::next_image
         incr cpt
      }
      visu$visuNo disp
      tk_messageBox -message "Extraction Terminee" -type ok
   }















}


#--- Initialisation au demarrage
::av4l_extraction::init
