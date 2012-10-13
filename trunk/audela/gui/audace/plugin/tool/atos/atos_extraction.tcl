#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_extraction.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_extraction.tcl
# Description    : Utilitaires d'extraction des images fits a partir de la video
# Auteur         : Frederic Vachier
# Mise à jour $Id$
#

namespace eval ::atos_extraction {






   #
   # Chargement des captions
   #
   proc ::atos_extraction::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_extraction.cap ]
   }





   #
   # Initialisation des variables de configuration
   #
   proc ::atos_extraction::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                           { set ::atos::parametres(atos,$visuNo,messages)                           "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }                      { set ::atos::parametres(atos,$visuNo,save_file_log)                      "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }                   { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)                   "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] }           { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)           "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }              { set ::atos::parametres(atos,$visuNo,verifier_index_depart)              "1" }
   }





   #
   # Charge la configuration dans des variables locales
   #
   proc ::atos_extraction::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::atos_extraction::panneau(atos,$visuNo,messages)                   $::atos::parametres(atos,$visuNo,messages)
      set ::atos_extraction::panneau(atos,$visuNo,save_file_log)              $::atos::parametres(atos,$visuNo,save_file_log)
      set ::atos_extraction::panneau(atos,$visuNo,alarme_fin_serie)           $::atos::parametres(atos,$visuNo,alarme_fin_serie)
      set ::atos_extraction::panneau(atos,$visuNo,verifier_ecraser_fichier)   $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
      set ::atos_extraction::panneau(atos,$visuNo,verifier_index_depart)      $::atos::parametres(atos,$visuNo,verifier_index_depart)

      set ::atos_tools::traitement "avi"

   }





   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_extraction::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }






   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_extraction::run { visuNo this } {

     global audace panneau

      set panneau(atos,$visuNo,atos_extraction) $this
      ::atos_extraction::createdialog $this $visuNo   

   }





   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_extraction::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_extraction.htm
   }






   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_extraction::closeWindow { this visuNo } {

      ::atos_extraction::widgetToConf $visuNo
      destroy $this
   }










   #
   # Creation de l'interface graphique
   #
   proc ::atos_extraction::createdialog { this visuNo } {

      package require Img

      global caption panneau atosconf color audace

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
      wm title $this $caption(atos_extraction,titre)
      wm protocol $this WM_DELETE_WINDOW "::atos_extraction::closeWindow $this $visuNo"


      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::atos_extraction::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_atos_extraction


      #--- Cree un frame pour afficher le status de la base
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $atosconf(font,arial_14_b) \
              -text "$caption(atos_extraction,titre)"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3

        #--- Cree un frame pour 
        frame $frm.open \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.open \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1
        #--- Creation du bouton open
        button $frm.open.but_open \
           -text "$caption(atos_extraction,ouvrir)" -borderwidth 2 \
           -command "::atos_tools::open_flux $visuNo $frm"
        pack $frm.open.but_open \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton select
        button $frm.open.but_select \
           -text "..." -borderwidth 2 -takefocus 1 \
           -command "::atos_tools::select $visuNo $frm"
        pack $frm.open.but_select \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Cree un label pour le chemin de l'AVI
        entry $frm.open.avipath 
        pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

        #--- Creation de la barre de defilement
        scale $frm.scrollbar -from 0 -to 1 -length 600 -variable ::atos_tools::scrollbar \
           -label "" -orient horizontal \
           -state disabled
        pack $frm.scrollbar -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

        #--- Cree un frame pour afficher
        set btnav [frame $frm.btnav -borderwidth 0]
        pack $btnav -in $frm -side top

        #--- Creation du bouton quick prev image
        image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool atos img arr.png ]
        button $frm.qprevimage -image .arr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_tools::quick_prev_image $visuNo"
        pack $frm.qprevimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton prev image
        image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool atos img arn.png ]
        button $frm.previmage -image .arn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_tools::prev_image $visuNo"
        pack $frm.previmage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton next image
        image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool atos img avn.png ]
        button $frm.nextimage -image .avn\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_tools::next_image $visuNo"
        pack $frm.nextimage \
           -in $frm.btnav \
           -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton quick next image
        image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool atos img avr.png ]
        button $frm.qnextimage -image .avr\
           -borderwidth 2 -width 25 -height 25 -compound center \
           -command "::atos_tools::quick_next_image $visuNo"
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
                -text "$caption(atos_extraction,setmin)" -borderwidth 2 \
                -command "::atos_tools::setmin $frm"
             pack $frm.pos.setmin \
                -in $frm.pos \
                -side left -anchor w \
                -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

             #--- Creation du bouton setmax
             button $frm.pos.setmax \
                -text "$caption(atos_extraction,setmax)" -borderwidth 2 \
                -command "::atos_tools::setmax $frm"
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
             label $frm.labnbimg -font $atosconf(font,courier_10) -padx 3 \
                   -text "$caption(atos_extraction,nbimg)"
             pack $frm.labnbimg -in $frm.count -side left -pady 1 -anchor w
             #--- Cree un entry
             entry $frm.imagecount -fg $color(blue) -relief sunken
             pack $frm.imagecount -in $frm.count -side left -pady 1 -anchor w
             #--- Cree un button
             button $frm.doimagecount \
              -text "$caption(atos_extraction,calcul)" -borderwidth 2 \
              -command "::atos_tools_avi::imagecount $frm" 
             pack $frm.doimagecount -in $frm.count -side left -pady 1 -anchor w

          #--- Cree un frame pour 
          frame $frm.status -borderwidth 0 -cursor arrow
          pack $frm.status -in $frm -side top -expand 0

          #--- Cree un frame pour afficher les intitules
          set intitle [frame $frm.status.l -borderwidth 0]
          pack $intitle -in $frm.status -side left

            #--- Cree un label pour le status
            label $intitle.status -font $atosconf(font,courier_10) -text "$caption(atos_extraction,statut)"
            pack $intitle.status -in $intitle -side top -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.nbtotal -font $atosconf(font,courier_10) -text "$caption(atos_extraction,nbtotal)"
            pack $intitle.nbtotal -in $intitle -side top -anchor w


          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $frm.status.v -borderwidth 0]
          pack $inparam -in $frm.status -side left -expand 0 -fill x

            #--- Cree un label pour le 
            label $inparam.status -font $atosconf(font,courier_10) -fg $color(blue) -text "-"
            pack  $inparam.status -in $inparam -side top -anchor w

            #--- Cree un label pour le 
            label $inparam.nbtotal -font $atosconf(font,courier_10) -fg $color(blue) -text "-"
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
            label $intitle.destdir -font $atosconf(font,courier_10) -padx 3 \
                  -text "$caption(atos_extraction,destdir)"
            pack $intitle.destdir -in $intitle -side top -padx 3 -pady 1 -anchor w

            #--- Cree un label pour le nb d image
            label $intitle.prefix -font $atosconf(font,courier_10) \
                  -text "$caption(atos_extraction,prefix)"
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
             -command "::atos_tools::chgdir $inparam.destdir" 
            pack $inbutton.chgdir -in $inbutton -side top -pady 0 -anchor w

            #--- Cree un label pour le nb d image
            label $inbutton.blank -font $atosconf(font,courier_10) \
                  -text ""
            pack $inbutton.blank -in $inbutton -side top -padx 3 -pady 1 -anchor w


   #---
        #--- Cree un frame pour  les boutons d action 
        frame $frm.action \
              -borderwidth 1 -relief raised -cursor arrow
        pack $frm.action \
             -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

           button $frm.action.extract \
              -text "$caption(atos_extraction,extract)" -borderwidth 2 \
              -command " ::atos_extraction::extract $visuNo $frm "
           pack $frm.action.extract -in $frm.action \
              -side left -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton fermer
           button $frm.action.fermer \
              -text "$caption(atos_extraction,fermer)" -borderwidth 2 \
              -command "::atos_extraction::closeWindow $this $visuNo"
           pack $frm.action.fermer -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $frm.action.aide \
              -text "$caption(atos_extraction,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool atos atos.htm"
           pack $frm.action.aide -in $frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0





   }






   proc ::atos_extraction::extract { visuNo frm } {
      global audace caption

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
         set fmax $::atos_tools::nb_open_frames
      }
      #::console::affiche_resultat "fmin=$fmin\n"
      #::console::affiche_resultat "fmax=$fmax\n"


      ::atos_tools_avi::set_frame $fmin
      for {set i $fmin} {$i <= $fmax} {incr i} {
         set ::atos_tools::scrollbar $::atos_tools::cur_idframe
         visu$visuNo disp
         #::console::affiche_resultat "$i / [expr $fmax-$fmin+1]\n"
         ::console::affiche_resultat ""
         
         set path "$destdir/$prefix$cpt"
         #::console::affiche_resultat "path : $path\n"
         buf$bufNo save $path fits
         ::atos_tools_avi::next_image
         incr cpt
      }
      visu$visuNo disp
      tk_messageBox -message "$caption(atos_extraction,extractfin)" -type ok
   }















}


#--- Initialisation au demarrage
::atos_extraction::init
