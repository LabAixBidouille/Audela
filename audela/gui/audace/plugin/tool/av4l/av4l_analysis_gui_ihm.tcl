   #
   # Creation de l'interface graphique
   #
   proc ::av4l_analysis_gui::createdialog { visuNo this } {

      package require Img

      global caption panneau av4lconf color audace

      ::av4l_analysis_gui::init_faible

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

      wm protocol $this WM_DELETE_WINDOW "::av4l_analysis_gui::closeWindow $this $visuNo"

      #--- Charge la configuration de la vitesse de communication dans une variable locale
      ::av4l_analysis_gui::confToWidget $visuNo

      #--- Retourne l'item de la camera associee a la visu
      set frm $this.frm_av4l_analysis_gui

      #--- Creation des imagettes
      image create photo .calc      -format PNG -file [ file join $audace(rep_plugin) tool av4l img calcul.png ]
      image create photo .stop      -format PNG -file [ file join $audace(rep_plugin) tool av4l img stop2.png ]
      image create photo .p1        -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p1.png ]
      image create photo .p2        -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p2.png ]
      image create photo .p3        -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p3.png ]
      image create photo .p4        -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p4.png ]
      image create photo .p5        -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_p5.png ]
      image create photo .immersion -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_immersion.png ]
      image create photo .emersion  -format PNG -file [ file join $audace(rep_plugin) tool av4l img select_emersion.png ]
      image create photo .reload    -format PNG -file [ file join $audace(rep_plugin) tool av4l img reload.png ]
      image create photo .view      -format PNG -file [ file join $audace(rep_plugin) tool av4l img view.png ]


      #--- Premier FRAME
      frame $frm -borderwidth 0 -cursor arrow -relief groove
      pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $frm.titre -font $av4lconf(font,arial_14_b) \
              -text "Analyse de la Courbe de lumiere"
        pack $frm.titre \
             -in $frm -side top -padx 3 -pady 3

         set onglets [frame $frm.onglets -borderwidth 0 -cursor arrow -relief groove]
         pack $onglets -in $frm -side top -expand 0 -fill x -padx 10 -pady 5

            pack [ttk::notebook $onglets.nb]
            set f0 [frame $onglets.nb.f0]
            set f1 [frame $onglets.nb.f1]
            set f2 [frame $onglets.nb.f2]
            set f3 [frame $onglets.nb.f3]
            set f4 [frame $onglets.nb.f4]
            set f5 [frame $onglets.nb.f5]
            set f6 [frame $onglets.nb.f6]
            set f7 [frame $onglets.nb.f7]
            set f8 [frame $onglets.nb.f8]
            
            $onglets.nb add $f0 -text "Projet"
            $onglets.nb add $f1 -text "Ephemerides"
            $onglets.nb add $f2 -text "Corrections"
            $onglets.nb add $f3 -text "Evenements"
            $onglets.nb add $f4 -text "Parametres"
            $onglets.nb add $f6 -text "Immersion"
            $onglets.nb add $f7 -text "Emersion"
            $onglets.nb add $f8 -text "Rapport"
            $onglets.nb select $f0
            ttk::notebook::enableTraversal $onglets.nb
        
        


#---


#--- ONGLET : Projet


#---

        #--- Cree un frame pour afficher le contenu de l onglet
        set projet [frame $f0.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $projet -in $f0 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5



             #--- Cree un frame pour le chargement d'un fichier
             set titrecontxt [frame $projet.titrecontxt -borderwidth 1 -cursor arrow -relief raised]
             pack $titrecontxt -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 -ipady 5

                  #--- Cree un label
                  label $titrecontxt.l -text "Contexte : " -font $av4lconf(font,courier_10_b)
                  pack  $titrecontxt.l -side left -anchor e 

             #--- Cree un frame pour le chargement d'un fichier
             set object [frame $projet.object -borderwidth 0 -cursor arrow -relief groove]
             pack $object -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $object.l -text "Objet occulteur : "
                  pack  $object.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $object.v -textvariable ::av4l_analysis_gui::occ_obj -width 30
                  pack $object.v -side left -padx 3 -pady 1 -fill x -expand 1

             #--- Cree un frame pour le chargement d'un fichier
             set date [frame $projet.date -borderwidth 0 -cursor arrow -relief groove]
             pack $date -in $projet -anchor s -side top -expand 0 -fill x -padx 30 -pady 5

                  #--- Cree un label
                  label $date.l -text "Date : "
                  pack  $date.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $date.v -textvariable ::av4l_analysis_gui::occ_date -width 30
                  pack $date.v -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set observatoire [frame $projet.observatoire -borderwidth 0 -cursor arrow -relief groove]
             pack $observatoire -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $observatoire.l -text "Position de l'observateur : "
                  pack  $observatoire.l -side left -anchor e 

                  #--- Cree une liste defilante
                  set poscode [list "Code UAI" "LonW LatN Alt"]
                  ComboBox $observatoire.combo \
                      -width 11 -height 2 \
                      -relief raised -borderwidth 1 -editable 0 \
                      -textvariable ::av4l_analysis_gui::occ_pos_type \
                      -values $poscode
                  pack $observatoire.combo -anchor center -side left -fill x -expand 0

                  #--- Cree un label
                  entry $observatoire.v -textvariable ::av4l_analysis_gui::occ_pos -width 30
                  pack $observatoire.v -side left -padx 3 -pady 1 -fill x

             set check [frame $projet.check -borderwidth 0 -cursor arrow -relief groove]
             pack $check -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  button $check.but_miriade -text "Check avec Miriade" -borderwidth 2 \
                        -command "::av4l_analysis_gui::miriade"
                  pack $check.but_miriade -side left -anchor c 

                  #--- Cree un label
                  label $check.l1 -text "RA J2000: " 
                  pack  $check.l1 -side left -anchor c 

                  #--- Cree un label
                  label $check.l2 -textvariable ::av4l_analysis_gui::raj2000  -fg $color(blue)
                  pack  $check.l2 -side left -anchor c 

                  #--- Cree un label
                  label $check.l3 -text "DEC J2000: "
                  pack  $check.l3 -side left -anchor c 

                  #--- Cree un label
                  label $check.l4 -textvariable ::av4l_analysis_gui::decj2000  -fg $color(blue)
                  pack  $check.l4 -side left -anchor c 

                  button $check.but_aladin -text "Aladin" -borderwidth 2 \
                        -command "::av4l_analysis_gui::sendAladinScript"
                  pack $check.but_aladin -side right -anchor c 


             #--- Cree un frame pour le chargement d'un fichier
             set titrecontact [frame $projet.titrecontact -borderwidth 1 -cursor arrow -relief raised]
             pack $titrecontact -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 -ipady 5

                  #--- Cree un label
                  label $titrecontact.l -text "Contacts : " -font $av4lconf(font,courier_10_b)
                  pack  $titrecontact.l -side left -anchor e 
 
             #--- Cree un frame pour le chargement d'un fichier
             set observers [frame $projet.observers -borderwidth 0 -cursor arrow -relief groove]
             pack $observers -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $observers.l -text "Observateurs : "
                  pack  $observers.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $observers.v -textvariable ::av4l_analysis_gui::occ_observers -width 30
                  pack $observers.v -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set reduction [frame $projet.reduction -borderwidth 0 -cursor arrow -relief groove]
             pack $reduction -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $reduction.l -text "Reduction : "
                  pack  $reduction.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $reduction.v -textvariable ::av4l_analysis_gui::prj_reduc -width 30
                  pack $reduction.v -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set mail [frame $projet.mail -borderwidth 0 -cursor arrow -relief groove]
             pack $mail -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $mail.l -text "Mail : "
                  pack  $mail.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $mail.v -textvariable ::av4l_analysis_gui::prj_mail -width 30
                  pack $mail.v -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set titrefich [frame $projet.titrefich -borderwidth 1 -cursor arrow -relief raised]
             pack $titrefich -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 -ipady 5

                  #--- Cree un label
                  label $titrefich.l -text "Fichiers et Répertoires : " -font $av4lconf(font,courier_10_b)
                  pack  $titrefich.l -side left -anchor e 
 
             #--- Cree un frame pour le chargement d'un fichier
             set buttons [frame $projet.buttons -borderwidth 0 -cursor arrow -relief groove]
             pack $buttons -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Creation du bouton open
                  button $buttons.but_gen \
                     -text "Générer" -borderwidth 2 \
                     -command "::av4l_analysis_gui::generer $visuNo"
                  pack $buttons.but_gen \
                     -side right -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Creation du bouton open
                  button $buttons.but_load \
                     -text "Charger" -borderwidth 2 \
                     -command "::av4l_analysis_gui::load_atos_file"
                  pack $buttons.but_load \
                     -side right -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Creation du bouton open
                  button $buttons.but_open \
                     -text "Parcourir" -borderwidth 2 \
                     -command "::av4l_analysis_gui::select_atos_file $visuNo $f0"
                  pack $buttons.but_open \
                     -side right -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

             #--- Cree un frame pour le chargement d'un fichier
             set file [frame $projet.file -borderwidth 0 -cursor arrow -relief groove]
             pack $file -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $file.l -text "Fichier projet : "
                  pack  $file.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $file.v -textvariable ::av4l_analysis_gui::prj_file_short -width 30
                  pack $file.v -side left -padx 3 -pady 1 -fill x -expand 1

             #--- Cree un frame pour le chargement d'un fichier
             set dir [frame $projet.dir -borderwidth 0 -cursor arrow -relief groove]
             pack $dir -in $projet -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $dir.l -text "Repertoire de travail : "
                  pack  $dir.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $dir.v -textvariable ::av4l_analysis_gui::prj_dir -width 10
                  pack $dir.v -side left -padx 3 -pady 1 -fill x -expand 1


#---


#--- ONGLET : Ephemerides


#---

        #--- Cree un frame pour afficher le contenu de l onglet
        set ephem [frame $f1.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $ephem -in $f1 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
             #--- Cree un frame pour le chargement d'un fichier
             set coordtitre [frame $ephem.coordtitre -borderwidth 1 -cursor arrow -relief raised]
             pack $coordtitre -in $ephem -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 -ipady 5

                  #--- Cree un label
                  label $coordtitre.l -text "Coordonnees : " -font $av4lconf(font,courier_10_b)
                  pack  $coordtitre.l -side left -anchor e 
 
             #--- Cree un frame pour le chargement d'un fichier
             set coordval [frame $ephem.coordval -borderwidth 0 -cursor arrow -relief groove]
             pack $coordval -in $ephem -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set coordgauche [frame $coordval.coordgauche -borderwidth 0 -cursor arrow -relief groove]
                  pack $coordgauche -in $coordval -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set raj2000 [frame $coordgauche.raj2000 -borderwidth 0 -cursor arrow -relief groove]
                       pack $raj2000 -in $coordgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $raj2000.l1 -text "RA J2000 (hms) : "
                            pack  $raj2000.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $raj2000.v1 -textvariable ::av4l_analysis_gui::raj2000 -fg $color(blue)
                            pack $raj2000.v1 -side left -padx 3 -pady 1 -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set decj2000 [frame $coordgauche.decj2000 -borderwidth 0 -cursor arrow -relief groove]
                       pack $decj2000 -in $coordgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $decj2000.l2 -text "DEC J2000 (dms) : "
                            pack  $decj2000.l2 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $decj2000.v2 -textvariable ::av4l_analysis_gui::decj2000 -fg $color(blue)
                            pack $decj2000.v2 -side left -padx 3 -pady 1 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set coorddroit [frame $coordval.coorddroit -borderwidth 0 -cursor arrow -relief groove]
                  pack $coorddroit -in $coordval -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set raapparent [frame $coorddroit.raapparent -borderwidth 0 -cursor arrow -relief groove]
                       pack $raapparent -in $coorddroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $raapparent.l1 -text "RA Apparent (hms) : "
                            pack  $raapparent.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $raapparent.v1 -textvariable ::av4l_analysis_gui::rajapp  -fg $color(blue)
                            pack $raapparent.v1 -side left -padx 3 -pady 1   -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set decapparent [frame $coorddroit.decapparent -borderwidth 0 -cursor arrow -relief groove]
                       pack $decapparent -in $coorddroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $decapparent.l2 -text "DEC Apparent (dms) : "
                            pack  $decapparent.l2 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $decapparent.v2 -textvariable ::av4l_analysis_gui::decapp -fg $color(blue)
                            pack $decapparent.v2 -side left  -padx 3 -pady 1  -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set angletitre [frame $ephem.angletitre -borderwidth 1 -cursor arrow -relief raised]
             pack $angletitre -in $ephem -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 -ipady 5

                  #--- Cree un label
                  label $angletitre.l -text "Angles : " -font $av4lconf(font,courier_10_b)
                  pack  $angletitre.l -side left -anchor e 
 

             #--- Cree un frame pour le chargement d'un fichier
             set angleval [frame $ephem.angleval -borderwidth 0 -cursor arrow -relief groove]
             pack $angleval -in $ephem -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set anglegauche [frame $angleval.anglegauche -borderwidth 0 -cursor arrow -relief groove]
                  pack $anglegauche -in $angleval -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set tsl [frame $anglegauche.tsl -borderwidth 0 -cursor arrow -relief groove]
                       pack $tsl -in $anglegauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $tsl.l1 -text "Temps Sideral Local (hms) : "
                            pack  $tsl.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $tsl.v1 -textvariable ::av4l_analysis_gui::tsl  -fg $color(blue)
                            pack $tsl.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set hourangle [frame $anglegauche.hourangle -borderwidth 0 -cursor arrow -relief groove]
                       pack $hourangle -in $anglegauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $hourangle.l1 -text "Angle Horaire (hms) : "
                            pack  $hourangle.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $hourangle.v1 -textvariable ::av4l_analysis_gui::hourangle  -fg $color(blue)
                            pack $hourangle.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set decapp [frame $anglegauche.decapp -borderwidth 0 -cursor arrow -relief groove]
                       pack $decapp -in $anglegauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $decapp.l1 -text "Declinaison (dms) : "
                            pack  $decapp.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $decapp.v1 -textvariable ::av4l_analysis_gui::decapp  -fg $color(blue)
                            pack $decapp.v1 -side left -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set angledroit [frame $angleval.angledroit -borderwidth 0 -cursor arrow -relief groove]
                  pack $angledroit -in $angleval -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set azimuth [frame $angledroit.azimuth -borderwidth 0 -cursor arrow -relief groove]
                       pack $azimuth -in $angledroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $azimuth.l1 -text "Azimuth (dms) : "
                            pack  $azimuth.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $azimuth.v1 -textvariable ::av4l_analysis_gui::azimuth  -fg $color(blue)
                            pack $azimuth.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set hauteur [frame $angledroit.hauteur -borderwidth 0 -cursor arrow -relief groove]
                       pack $hauteur -in $angledroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $hauteur.l1 -text "Hauteur (dms) : "
                            pack  $hauteur.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $hauteur.v1 -textvariable ::av4l_analysis_gui::hauteur  -fg $color(blue)
                            pack $hauteur.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set airmass [frame $angledroit.airmass -borderwidth 0 -cursor arrow -relief groove]
                       pack $airmass -in $angledroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $airmass.l1 -text "Airmass : "
                            pack  $airmass.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $airmass.v1 -textvariable ::av4l_analysis_gui::airmass  -fg $color(blue)
                            pack $airmass.v1 -side left -fill x

 
             #--- Cree un frame pour le chargement d'un fichier
             set paramtitre [frame $ephem.paramtitre -borderwidth 1 -cursor arrow -relief raised]
             pack $paramtitre -in $ephem -anchor s -side top -expand 0 -fill x -padx 10 -pady 5 -ipady 5

                  #--- Cree un label
                  label $paramtitre.l -text "Distances et autres paramètres : " -font $av4lconf(font,courier_10_b)
                  pack  $paramtitre.l -side left -anchor e 
 

             #--- Cree un frame pour le chargement d'un fichier
             set paramval [frame $ephem.paramval -borderwidth 0 -cursor arrow -relief groove]
             pack $paramval -in $ephem -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set paramgauche [frame $paramval.anglegauche -borderwidth 0 -cursor arrow -relief groove]
                  pack $paramgauche -in $paramval -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set dist [frame $paramgauche.dist -borderwidth 0 -cursor arrow -relief groove]
                       pack $dist -in $paramgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $dist.l1 -text "Distance à l'observateur (UA) : "
                            pack  $dist.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $dist.v1 -textvariable ::av4l_analysis_gui::dist  -fg $color(blue)
                            pack $dist.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set dhelio [frame $paramgauche.dhelio -borderwidth 0 -cursor arrow -relief groove]
                       pack $dhelio -in $paramgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $dhelio.l1 -text "Distance Heliocentrique (UA) : "
                            pack  $dhelio.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $dhelio.v1 -textvariable ::av4l_analysis_gui::dhelio  -fg $color(blue)
                            pack $dhelio.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set phase [frame $paramgauche.phase -borderwidth 0 -cursor arrow -relief groove]
                       pack $phase -in $paramgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $phase.l1 -text "Phase (deg) : "
                            pack  $phase.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $phase.v1 -textvariable ::av4l_analysis_gui::phase  -fg $color(blue)
                            pack $phase.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set elong [frame $paramgauche.elong -borderwidth 0 -cursor arrow -relief groove]
                       pack $elong -in $paramgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $elong.l1 -text "Elongation (deg) : "
                            pack  $elong.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $elong.v1 -textvariable ::av4l_analysis_gui::elong  -fg $color(blue)
                            pack $elong.v1 -side left -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set paramdroit [frame $paramval.paramdroit -borderwidth 0 -cursor arrow -relief groove]
                  pack $paramdroit -in $paramval -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set dracosd [frame $paramdroit.dracosd -borderwidth 0 -cursor arrow -relief groove]
                       pack $dracosd -in $paramdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $dracosd.l1 -text "DRa.cos(Dec) ('/h) : "
                            pack  $dracosd.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $dracosd.v1 -textvariable ::av4l_analysis_gui::dracosd  -fg $color(blue)
                            pack $dracosd.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set ddec [frame $paramdroit.ddec -borderwidth 0 -cursor arrow -relief groove]
                       pack $ddec -in $paramdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $ddec.l1 -text "DDec ('/h) : "
                            pack  $ddec.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $ddec.v1 -textvariable ::av4l_analysis_gui::ddec  -fg $color(blue)
                            pack $ddec.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set vn [frame $paramdroit.vn -borderwidth 0 -cursor arrow -relief groove]
                       pack $vn -in $paramdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $vn.l1 -text "Vitesse sur le plan tangent (km/s) : "
                            pack  $vn.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $vn.v1 -textvariable ::av4l_analysis_gui::vn  -fg $color(blue)
                            pack $vn.v1 -side left -fill x

                       #--- Cree un frame pour le chargement d'un fichier
                       set magv [frame $paramdroit.magv -borderwidth 0 -cursor arrow -relief groove]
                       pack $magv -in $paramdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Cree un label
                            label $magv.l1 -text "Magnitude apparente estimée : "
                            pack  $magv.l1 -side left -anchor e 

                            #--- Cree un label pour le chemin de l'AVI
                            label $magv.v1 -textvariable ::av4l_analysis_gui::magv  -fg $color(blue)
                            pack $magv.v1 -side left -fill x

    




#---


#--- ONGLET : Corrections courbe


#---


        #--- Cree un frame pour afficher le contenu de l onglet
        set courbe [frame $f2.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $courbe -in $f2 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        

             #--- Cree un frame pour le chargement d'un fichier
             set charge [frame $courbe.charge -borderwidth 0 -cursor arrow -relief groove]
             pack $charge -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Creation du bouton open
                  button $charge.but_open \
                     -text "ouvrir" -borderwidth 2 \
                     -command "::av4l_analysis_gui::open_raw_file $visuNo $f1"
                  pack $charge.but_open \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Creation du bouton select
                  button $charge.but_select \
                     -text "..." -borderwidth 2 -takefocus 1 \
                     -command "::av4l_analysis_gui::select_raw_data $visuNo $charge"
                  pack $charge.but_select \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Cree un label pour le chemin de l'AVI
                  entry $charge.csvpath -textvariable ::av4l_analysis_gui::raw_filename_short
                  pack $charge.csvpath -side left -padx 3 -pady 1 -expand true -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set info [frame $courbe.info -borderwidth 0 -cursor arrow -relief groove]
             pack $info -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                   #--- Cree un frame
                   frame $info.l1 -borderwidth 0 -cursor arrow
                   pack  $info.l1 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l1.statusl -text "Fichier :"
                        pack  $info.l1.statusl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        set ::av4l_analysis_tools::raw_status_file_gui $info.l1.statusv
                        label $info.l1.statusv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_status_file
                        pack  $info.l1.statusv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank -width 5
                             pack  $info.l1.blank -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbl -text "Nb points :"
                        pack  $info.l1.nbl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_nbframe
                        pack  $info.l1.nbv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank2 -width 5
                             pack  $info.l1.blank2 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureel -text "durée (sec):"
                        pack  $info.l1.dureel -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureev -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_duree
                        pack  $info.l1.dureev -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank3 -width 5
                             pack  $info.l1.blank3 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsl -text "fps :"
                        pack  $info.l1.fpsl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_fps
                        pack  $info.l1.fpsv -in $info.l1 -side left -anchor e 


                   #--- Cree un frame
                   frame $info.l2 -borderwidth 0 -cursor arrow
                   pack  $info.l2 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l2.dbegl -text "Date de début :"
                        pack  $info.l2.dbegl -in $info.l2 -side left -anchor w

                        #--- Cree un label
                        label $info.l2.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_date_begin
                        pack  $info.l2.dbegv -in $info.l2 -side left -anchor e 

                             #--- Cree un label
                             label $info.l2.blank -width 5
                             pack  $info.l2.blank -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendl -text "Date de Fin :"
                        pack  $info.l2.dendl -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::raw_date_end
                        pack  $info.l2.dendv -in $info.l2 -side left -anchor e 



             #--- Cree un frame pour le chargement d'un fichier
             set corr_integ [frame $courbe.corr_integ -borderwidth 0 -cursor arrow -relief groove]
             pack $corr_integ -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $corr_integ.label -text "Correction de l intégration : "
                  pack  $corr_integ.label -side left -anchor w

                  #--- Creation du bouton open
                  button $corr_integ.but_offset -text "offset" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_get_offset $visuNo $corr_integ"
                  pack $corr_integ.but_offset -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $corr_integ.offset -textvariable ::av4l_analysis_gui::raw_integ_offset -width 4
                  pack $corr_integ.offset -side left -padx 3 -pady 1 

                  #--- Creation du bouton open
                  button $corr_integ.but_nb_img -text "nb img" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_get_nb_img $visuNo $corr_integ"
                  pack $corr_integ.but_nb_img -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $corr_integ.nb_img -textvariable ::av4l_analysis_gui::raw_integ_nb_img -width 4
                  pack  $corr_integ.nb_img -side left -padx 3 -pady 1 

                  #--- Creation du bouton open
                  button $corr_integ.but_view -text "view" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_view"
                  pack $corr_integ.but_view -side left -anchor e 

                  #--- Creation du bouton open
                  button $corr_integ.but_apply -text "Appliquer" -borderwidth 2 \
                        -command "::av4l_analysis_gui::corr_integ_apply"
                  pack $corr_integ.but_apply -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set sauver [frame $courbe.sauver -borderwidth 0 -cursor arrow -relief groove]
             pack $sauver -in $courbe -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Creation du bouton open
                  button $sauver.but_save -text "Sauver" -borderwidth 2 \
                        -command "::av4l_analysis_gui::save_corrected_curve"
                  pack $sauver.but_save -side left -anchor e 





#---


#--- ONGLET : Evenements


#---




        #--- Cree un frame pour afficher le contenu de l onglet
        set corrected [frame $f3.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $corrected -in $f3 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        
             #--- Cree un frame pour le chargement d'un fichier
             set charge [frame $corrected.charge -borderwidth 0 -cursor arrow -relief groove]
             pack $charge -in $corrected -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Creation du bouton open
                  button $charge.but_open \
                     -text "ouvrir" -borderwidth 2 \
                     -command "::av4l_analysis_gui::open_corr_file $visuNo $f6"
                  pack $charge.but_open \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Creation du bouton select
                  button $charge.but_select \
                     -text "..." -borderwidth 2 -takefocus 1 \
                     -command "::av4l_analysis_gui::select_corr_data $visuNo $charge"
                  pack $charge.but_select \
                     -side left -anchor e \
                     -padx 3 -pady 3 -ipadx 3 -ipady 3 -expand 0

                  #--- Cree un label pour le chemin de l'AVI
                  entry $charge.csvpath -textvariable ::av4l_analysis_gui::corr_filename_short
                  pack $charge.csvpath -side left -padx 3 -pady 1 -expand true -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set info [frame $corrected.info -borderwidth 0 -cursor arrow -relief groove]
             pack $info -in $corrected -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                   #--- Cree un frame
                   frame $info.l1 -borderwidth 0 -cursor arrow
                   pack  $info.l1 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l1.statusl -text "Fichier :"
                        pack  $info.l1.statusl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        set ::av4l_analysis_tools::corr_status_file_gui $info.l1.statusv
                        label $info.l1.statusv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_status_file
                        pack  $info.l1.statusv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank -width 5
                             pack  $info.l1.blank -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbl -text "Nb points :"
                        pack  $info.l1.nbl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.nbv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_nbframe
                        pack  $info.l1.nbv -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank2 -width 5
                             pack  $info.l1.blank2 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureel -text "durée (sec):"
                        pack  $info.l1.dureel -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.dureev -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_duree
                        pack  $info.l1.dureev -in $info.l1 -side left -anchor e 

                             #--- Cree un label
                             label $info.l1.blank3 -width 5
                             pack  $info.l1.blank3 -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsl -text "fps :"
                        pack  $info.l1.fpsl -in $info.l1 -side left -anchor w 

                        #--- Cree un label
                        label $info.l1.fpsv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_fps
                        pack  $info.l1.fpsv -in $info.l1 -side left -anchor e 

                   #--- Cree un frame
                   frame $info.l2 -borderwidth 0 -cursor arrow
                   pack  $info.l2 -in $info -side top -expand 0 -anchor w

                        #--- Cree un label
                        label $info.l2.dbegl -text "Date de début :"
                        pack  $info.l2.dbegl -in $info.l2 -side left -anchor w

                        #--- Cree un label
                        label $info.l2.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_date_begin
                        pack  $info.l2.dbegv -in $info.l2 -side left -anchor e 

                             #--- Cree un label
                             label $info.l2.blank -width 5
                             pack  $info.l2.blank -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendl -text "Date de Fin :"
                        pack  $info.l2.dendl -in $info.l2 -side left -anchor w 

                        #--- Cree un label
                        label $info.l2.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                     -textvariable ::av4l_analysis_tools::corr_date_end
                        pack  $info.l2.dendv -in $info.l2 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set events [frame $corrected.events -borderwidth 0 -cursor arrow -relief groove]
             pack $events -in $corrected -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Cree un frame
                  frame $events.e1 -borderwidth 0 -cursor arrow
                  pack  $events.e1 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e1.but_select -image .p1 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 1"
                       pack $events.e1.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e1.but_select -text "Selection 1er plateau : Eviter de prendre trop proche de l'immersion !"
                        
                       #--- Cree un label
                       label $events.e1.dbegl -text "Nb img :"
                       pack  $events.e1.dbegl -in $events.e1 -side left -anchor w

                       #--- Cree un label
                       label $events.e1.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p1
                       pack  $events.e1.dbegv -in $events.e1 -side left -anchor e 

                            #--- Cree un label
                            label $events.e1.blank -width 3
                            pack  $events.e1.blank -in  $events.e1 -side left -anchor w 

                       #--- Cree un label
                       label $events.e1.dendl -text "Durée :"
                       pack  $events.e1.dendl -in $events.e1 -side left -anchor w 

                       #--- Cree un label
                       label $events.e1.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e1
                       pack  $events.e1.dendv -in $events.e1 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e2 -borderwidth 0 -cursor arrow
                  pack  $events.e2 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e2.but_select -image .p2 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 2"
                       pack $events.e2.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e2.but_select -text "Immersion : Prendre autant de point d'un coté que de l'autre \n autour de l'immersion. Eviter de prendre trop proche de l'emersion"
                          
                       #--- Cree un label
                       label $events.e2.dbegl -text "Nb img :"
                       pack  $events.e2.dbegl -in $events.e2 -side left -anchor w

                       #--- Cree un label
                       label $events.e2.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p2
                       pack  $events.e2.dbegv -in $events.e2 -side left -anchor e 

                            #--- Cree un label
                            label $events.e2.blank -width 3
                            pack  $events.e2.blank -in  $events.e2 -side left -anchor w 

                       #--- Cree un label
                       label $events.e2.dendl -text "Durée :"
                       pack  $events.e2.dendl -in $events.e2 -side left -anchor w 

                       #--- Cree un label
                       label $events.e2.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e2
                       pack  $events.e2.dendv -in $events.e2 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e3 -borderwidth 0 -cursor arrow
                  pack  $events.e3 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e3.but_select -image .p3 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 3"
                       pack $events.e3.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e3.but_select -text "Occultation : Eviter de prendre trop proche des evenements"
                          
                       #--- Cree un label
                       label $events.e3.dbegl -text "Nb img :"
                       pack  $events.e3.dbegl -in $events.e3 -side left -anchor w

                       #--- Cree un label
                       label $events.e3.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p3
                       pack  $events.e3.dbegv -in $events.e3 -side left -anchor e 

                            #--- Cree un label
                            label $events.e3.blank -width 3
                            pack  $events.e3.blank -in  $events.e3 -side left -anchor w 

                       #--- Cree un label
                       label $events.e3.dendl -text "Durée :"
                       pack  $events.e3.dendl -in $events.e3 -side left -anchor w 

                       #--- Cree un label
                       label $events.e3.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e3
                       pack  $events.e3.dendv -in $events.e3 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e4 -borderwidth 0 -cursor arrow
                  pack  $events.e4 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e4.but_select -image .p4 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 4"
                       pack $events.e4.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e4.but_select -text "Emersion : Prendre autant de point d'un coté que de l'autre \n autour de l'emersion. Eviter de prendre trop proche de l'immersion"
                          
                       #--- Cree un label
                       label $events.e4.dbegl -text "Nb img :"
                       pack  $events.e4.dbegl -in $events.e4 -side left -anchor w

                       #--- Cree un label
                       label $events.e4.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p4
                       pack  $events.e4.dbegv -in $events.e4 -side left -anchor e 

                            #--- Cree un label
                            label $events.e4.blank -width 3
                            pack  $events.e4.blank -in  $events.e4 -side left -anchor w 

                       #--- Cree un label
                       label $events.e4.dendl -text "Durée :"
                       pack  $events.e4.dendl -in $events.e4 -side left -anchor w 

                       #--- Cree un label
                       label $events.e4.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e4
                       pack  $events.e4.dendv -in $events.e4 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e5 -borderwidth 0 -cursor arrow
                  pack  $events.e5 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e5.but_select -image .p5 -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 5"
                       pack $events.e5.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e5.but_select -text "Selection 2eme plateau : Eviter de prendre trop proche de l'emersion !"
                          
                       #--- Cree un label
                       label $events.e5.dbegl -text "Nb img :"
                       pack  $events.e5.dbegl -in $events.e5 -side left -anchor w

                       #--- Cree un label
                       label $events.e5.dbegv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::nb_p5
                       pack  $events.e5.dbegv -in $events.e5 -side left -anchor e 

                            #--- Cree un label
                            label $events.e5.blank -width 3
                            pack  $events.e5.blank -in  $events.e5 -side left -anchor w 

                       #--- Cree un label
                       label $events.e5.dendl -text "Durée :"
                       pack  $events.e5.dendl -in $events.e5 -side left -anchor w 

                       #--- Cree un label
                       label $events.e5.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_tools::corr_duree_e5
                       pack  $events.e5.dendv -in $events.e5 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e6 -borderwidth 0 -cursor arrow
                  pack  $events.e6 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e6.but_select -image .immersion -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 6"
                       pack $events.e6.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e6.but_select -text "Selection de l'immersion : prendre un carré serré autour de l'evenement"
                          
                       #--- Cree un label
                       label $events.e6.dendl -text "Date de l'évènement :"
                       pack  $events.e6.dendl -in $events.e6 -side left -anchor w 

                       #--- Cree un label
                       label $events.e6.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_gui::date_immersion
                       pack  $events.e6.dendv -in $events.e6 -side left -anchor e 
                         
                  #--- Cree un frame
                  frame $events.e7 -borderwidth 0 -cursor arrow
                  pack  $events.e7 -in $events -side top -expand 0 -anchor w
        
                       #--- Creation du bouton select
                       button $events.e7.but_select -image .emersion -compound center \
                          -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::select_event 7"
                       pack $events.e7.but_select -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0
                       DynamicHelp::add  $events.e7.but_select -text "Selection de l'emersion : prendre un carré serré autour de l'evenement"
                          
                       #--- Cree un label
                       label $events.e7.dendl -text "Date de l'évènement :"
                       pack  $events.e7.dendl -in $events.e7 -side left -anchor w 

                       #--- Cree un label
                       label $events.e7.dendv -font $av4lconf(font,courier_10) -font $av4lconf(font,courier_10_b) \
                                    -textvariable ::av4l_analysis_gui::date_emersion
                       pack  $events.e7.dendv -in $events.e7 -side left -anchor e 
                         


                      
#---


#--- ONGLET : Parametres


#---


        #--- Cree un frame pour afficher le contenu de l onglet
        set parametres [frame $f4.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $parametres -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        

             #--- Cree un frame pour le chargement d'un fichier
             set titreobj [frame $parametres.titreobj -borderwidth 1 -cursor arrow -relief raised]
             pack $titreobj -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $titreobj.l -text "Objet occulteur : " -font $av4lconf(font,courier_10_b)
                  pack  $titreobj.l -side left -anchor e 

             #--- Cree un frame pour le chargement d'un fichier
             set distvit [frame $parametres.distvit -borderwidth 0 -cursor arrow -relief groove]
             pack $distvit -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $distvit.l1 -text "Distance (UA) : "
                  pack  $distvit.l1 -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $distvit.v1 -textvariable ::av4l_analysis_gui::dist -width 10
                  pack $distvit.v1 -side left -padx 3 -pady 1 -fill x

                  #--- Cree un label
                  label $distvit.l2 -text "Vitesse tangentielle (km/s) : "
                  pack  $distvit.l2 -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $distvit.v2 -textvariable ::av4l_analysis_gui::vn -width 10
                  pack $distvit.v2 -side left -padx 3 -pady 1 -fill x

                  #--- Cree un label
                  label $distvit.l3 -text "Diametre de la bande (km) : "
                  pack  $distvit.l3 -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $distvit.v3 -textvariable ::av4l_analysis_gui::width -width 10
                  pack $distvit.v3 -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set titreetoile [frame $parametres.titreetoile -borderwidth 1 -cursor arrow -relief raised]
             pack $titreetoile -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $titreetoile.l -text "Etoile : " -font $av4lconf(font,courier_10_b)
                  pack  $titreetoile.l -side left -anchor e 

                  button $titreetoile.but_aladin -text "Aladin" -borderwidth 2 \
                        -command "::av4l_analysis_gui::sendAladinScript"
                  pack $titreetoile.but_aladin -side right -anchor c 

             #--- Cree un frame pour le chargement d'un fichier
             set couleuretoile [frame $parametres.couleuretoile -borderwidth 0 -cursor arrow -relief groove]
             pack $couleuretoile -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $couleuretoile.l1 -text "Mag B : "
                  pack  $couleuretoile.l1 -side left -anchor e 

                  #--- Cree un entry
                  entry $couleuretoile.v1 -textvariable ::av4l_analysis_gui::occ_star_B -width 10
                  pack $couleuretoile.v1 -side left -padx 3 -pady 1 -fill x

                  #--- Cree un label
                  label $couleuretoile.l2 -text "Mag V : "
                  pack  $couleuretoile.l2 -side left -anchor e 

                  #--- Cree un entry
                  entry $couleuretoile.v2 -textvariable ::av4l_analysis_gui::occ_star_V -width 10
                  pack $couleuretoile.v2 -side left -padx 3 -pady 1 -fill x

                  #--- Cree un label
                  label $couleuretoile.l3 -text "Mag K : "
                  pack  $couleuretoile.l3 -side left -anchor e 

                  #--- Cree un entry
                  entry $couleuretoile.v3 -textvariable ::av4l_analysis_gui::occ_star_K -width 10
                  pack $couleuretoile.v3 -side left -padx 3 -pady 1 -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set tailleetoile [frame $parametres.tailleetoile -borderwidth 0 -cursor arrow -relief groove]
             pack $tailleetoile -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  button $tailleetoile.but_reload -image .reload -borderwidth 2 \
                        -command "::av4l_analysis_gui::calcul_taille_etoile $tailleetoile"
                  pack $tailleetoile.but_reload -side left -anchor c 
                  
                  #--- Cree un label
                  label $tailleetoile.l1 -text "Taille (mas) : "
                  pack  $tailleetoile.l1 -side left -anchor e 

                  #--- Cree un entry
                  entry $tailleetoile.v1 -textvariable ::av4l_analysis_gui::occ_star_size_mas -width 10
                  pack $tailleetoile.v1 -side left -padx 3 -pady 1 -fill x
                  
                  #--- Cree un label
                  label $tailleetoile.l2 -text "Taille (km) : "
                  pack  $tailleetoile.l2 -side left -anchor e 

                  #--- Cree un entry
                  entry $tailleetoile.v2 -textvariable ::av4l_analysis_gui::occ_star_size_km -width 10
                  pack $tailleetoile.v2 -side left -padx 3 -pady 1 -fill x
                  
             #--- Cree un frame pour le chargement d'un fichier
             set titrecapteur [frame $parametres.titrecapteur -borderwidth 1 -cursor arrow -relief raised] 
             pack $titrecapteur -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 10 -ipady 5

                  #--- Cree un label
                  label $titrecapteur.l -text "Capteur : " -font $av4lconf(font,courier_10_b)
                  pack  $titrecapteur.l -side left -anchor e 

             #--- Cree un frame pour le chargement d'un fichier
             set wvlngth [frame $parametres.wvlngth -borderwidth 0 -cursor arrow -relief groove]
             pack $wvlngth -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $wvlngth.l -text "Longueur d'onde (microns) : "
                  pack  $wvlngth.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $wvlngth.v -textvariable ::av4l_analysis_gui::wvlngth -width 10
                  pack $wvlngth.v -side left -padx 3 -pady 1 -fill x

             #--- Cree un frame pour le chargement d'un fichier
             set dlambda [frame $parametres.dlambda -borderwidth 0 -cursor arrow -relief groove]
             pack $dlambda -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label
                  label $dlambda.l -text "Bande passante (microns) : "
                  pack  $dlambda.l -side left -anchor e 

                  #--- Cree un label pour le chemin de l'AVI
                  entry $dlambda.v -textvariable ::av4l_analysis_gui::dlambda -width 10
                  pack $dlambda.v -side left -padx 3 -pady 1 -fill x


             #--- Cree un frame pour le chargement d'un fichier
             set irep [frame $parametres.irep -borderwidth 0 -cursor arrow -relief groove]
             pack $irep -in $parametres -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un label pour le chemin de l'AVI
                  checkbutton $irep.v -variable ::av4l_analysis_tools::irep -text "Réponse instrumentale"
                  pack $irep.v -side left -padx 3 -pady 1 -fill x



#---


#--- ONGLET : Immersion


#---

        #--- Cree un frame pour afficher le contenu de l onglet
        set immersion [frame $f6.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $immersion -in $f6 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        
             #--- Cree un frame pour le chargement d'un fichier
             set frmgauche [frame $immersion.frmgauche -borderwidth 0 -cursor arrow -relief groove]
             pack $frmgauche -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Cree un frame pour le chargement d'un fichier
                  set exposure [frame $frmgauche.exposure -borderwidth 0 -cursor arrow -relief groove]
                  pack $exposure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $exposure.l -text "Temps de pose (sans temps morts) (sec) : "
                       pack  $exposure.l -side left -anchor e 
                       #--- Cree un entry ( == ::av4l_analysis_tools::duree)
                       entry $exposure.v -textvariable ::av4l_analysis_tools::corr_exposure -width 10
                       pack $exposure.v -side left -padx 3 -pady 0 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set duree [frame $frmgauche.duree -borderwidth 0 -cursor arrow -relief groove]
                  pack $duree -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- 
                       label $duree.l -text "Nombre de points mesurés autour l'évenement : "
                       pack  $duree.l -side left -anchor e 
                       #---  
                       label $duree.v -textvariable ::av4l_analysis_tools::nb_p2
                       pack $duree.v -side left -padx 3 -pady 0 -fill x
                       #--- 
                       label $duree.l2 -text "("
                       pack  $duree.l2 -side left -anchor e 
                       #--- 
                       label $duree.v2 -textvariable ::av4l_analysis_gui::duree_max_immersion_search 
                       pack $duree.v2 -side left -padx 3 -pady 0 -fill x
                       #--- 
                       label $duree.l3 -text "sec)"
                       pack  $duree.l3 -side left -anchor e 



                  #--- Cree un frame pour le chargement d'un fichier
                  set dureemax [frame $frmgauche.dureemax -borderwidth 0 -cursor arrow -relief groove]
                  pack $dureemax -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $dureemax.l -text "Durée maxi estimée de l'évenement : "
                       pack  $dureemax.l -side left -anchor e 

                       #--- Cree un entry ( == ::av4l_analysis_tools::duree)
                       label $dureemax.v -textvariable ::av4l_analysis_gui::duree_max_immersion_evnmt 
                       pack $dureemax.v -side left -padx 3 -pady 0 -fill x

                       #--- Cree un label
                       label $dureemax.l2 -text " sec"
                       pack  $dureemax.l2 -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set t0_ref [frame $frmgauche.t0_ref -borderwidth 0 -cursor arrow -relief groove]
                  pack $t0_ref -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $t0_ref.l -text "Heure de reference (sec TU) : "
                       pack  $t0_ref.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $t0_ref.v -textvariable ::av4l_analysis_gui::date_immersion -width 30
                       pack $t0_ref.v -side left -padx 3 -pady 0 -fill x


                  #--- Cree un frame pour le chargement d'un fichier
                  set nheure [frame $frmgauche.nheure -borderwidth 0 -cursor arrow -relief groove]
                  pack $nheure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $nheure.l -text "Nombre d'instant a explorer autour de la reference (points) : "
                       pack  $nheure.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $nheure.v -textvariable ::av4l_analysis_gui::nheure -width 10
                       pack $nheure.v -side left -padx 0 -pady 0 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set pas_heure [frame $frmgauche.pas_heure -borderwidth 0 -cursor arrow -relief groove]
                  pack $pas_heure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $pas_heure.l -text "Pas de recherche de l'instant de l'evenement (sec): "
                       pack  $pas_heure.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $pas_heure.v -textvariable ::av4l_analysis_gui::pas_heure -width 10
                       pack $pas_heure.v -side left -padx 0 -pady 0 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set dureesearch [frame $frmgauche.dureesearch -borderwidth 0 -cursor arrow -relief groove]
                  pack $dureesearch -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $dureesearch.l -text "Durée de recherche autour de l'evenement : "
                       pack  $dureesearch.l -side left -anchor e 

                       #--- Creation du bouton calcul
                       button $dureesearch.but_reload -image .reload -borderwidth 2 \
                             -command "::av4l_analysis_gui::calcul_dureesearch $dureesearch $::av4l_analysis_gui::duree_max_immersion_search $::av4l_analysis_gui::duree_max_immersion_evnmt"
                       pack $dureesearch.but_reload -side left -anchor c 

                       #--- Cree un label pour le chemin de l'AVI
                       label $dureesearch.v -textvariable ::av4l_analysis_gui::dureesearch
                       pack $dureesearch.v -side left -padx 0 -pady 0 -fill x

                       #--- Cree un label
                       label $dureesearch.l2 -text "sec"
                       pack  $dureesearch.l2 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set im_calcul [frame $immersion.calcul -borderwidth 0 -cursor arrow -relief groove]
             pack $im_calcul -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  set blockcentre [frame $im_calcul.blockcentre]
                  pack $blockcentre -in $im_calcul -side top -anchor c 

                       #--- Creation du bouton open
                       button $blockcentre.but_calc -image .calc -borderwidth 2 \
                             -command "::av4l_analysis_gui::calcul_evenement -1"
                       pack $blockcentre.but_calc -side left -anchor c 

                       #--- Cree un label
                       label $blockcentre.l -text "Evolution : "
                       pack  $blockcentre.l -side left -anchor e 

                       #--- Cree un label
                       label $blockcentre.v -textvariable ::av4l_analysis_tools::percent
                       pack  $blockcentre.v -side left -anchor e 

             #--- Cree un frame pour le chargement d'un fichier
             set results [frame $immersion.results -borderwidth 1 -cursor arrow -relief raised]
             pack $results -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set frmgauche [frame $results.frmgauche -borderwidth 0 -cursor arrow -relief groove]
                  pack $frmgauche -in $results -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set date_immersion_sol [frame $frmgauche.date_immersion_sol -borderwidth 0 -cursor arrow -relief groove]
                       pack $date_immersion_sol -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $date_immersion_sol.l -text "Date de l'immersion : "
                            pack  $date_immersion_sol.l -side left -anchor e 

                            #--- Cree un label
                            label $date_immersion_sol.v -textvariable ::av4l_analysis_gui::date_immersion_sol
                            pack  $date_immersion_sol.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set chi2_min [frame $frmgauche.chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $chi2_min.l -text "Chi2 : "
                            pack  $chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $chi2_min.v -textvariable ::av4l_analysis_gui::im_chi2_min
                            pack  $chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set nfit_chi2_min [frame $frmgauche.nfit_chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $nfit_chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $nfit_chi2_min.l -text "Nombre de points utilisés pour l'ajustement : "
                            pack  $nfit_chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $nfit_chi2_min.v -textvariable ::av4l_analysis_gui::im_nfit_chi2_min
                            pack  $nfit_chi2_min.v -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set frmdroit [frame $results.frmdroit -borderwidth 0 -cursor arrow -relief groove]
                  pack $frmdroit -in $results -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set t0_chi2_min [frame $frmdroit.t0_chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $t0_chi2_min -in $frmdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $t0_chi2_min.l -text "t0 normalisé : "
                            pack  $t0_chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $t0_chi2_min.v -textvariable ::av4l_analysis_gui::im_t0_chi2_min
                            pack  $t0_chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set tps_dchi2 [frame $frmdroit.tps_dchi2 -borderwidth 0 -cursor arrow -relief groove]
                       pack $tps_dchi2 -in $frmdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $tps_dchi2.l1 -text "Intervalle 1 \u03C3 : "
                            pack  $tps_dchi2.l1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v1 -textvariable ::av4l_analysis_gui::im_t_inf
                            pack  $tps_dchi2.v1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l2 -text "<=>"
                            pack  $tps_dchi2.l2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v2 -textvariable ::av4l_analysis_gui::im_t_sup
                            pack  $tps_dchi2.v2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l3 -text "  ("
                            pack  $tps_dchi2.l3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v3 -textvariable ::av4l_analysis_gui::im_t_diff
                            pack  $tps_dchi2.v3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l4 -text " sec)"
                            pack  $tps_dchi2.l4 -side left -anchor e 


                       #--- Cree un frame pour le chargement d'un fichier
                       set tps_dchi2 [frame $frmdroit.tps_dchi2_3s -borderwidth 0 -cursor arrow -relief groove]
                       pack $tps_dchi2 -in $frmdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $tps_dchi2.l1 -text "Intervalle 3 \u03C3 : "
                            pack  $tps_dchi2.l1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v1 -textvariable ::av4l_analysis_gui::im_t_inf_3s
                            pack  $tps_dchi2.v1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l2 -text "<=>"
                            pack  $tps_dchi2.l2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v2 -textvariable ::av4l_analysis_gui::im_t_sup_3s
                            pack  $tps_dchi2.v2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l3 -text "  ("
                            pack  $tps_dchi2.l3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v3 -textvariable ::av4l_analysis_gui::im_t_diff_3s
                            pack  $tps_dchi2.v3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l4 -text " sec)"
                            pack  $tps_dchi2.l4 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set graphe [frame $immersion.graphe -borderwidth 0 -cursor arrow -relief groove]
             pack $graphe -in $immersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set graphel [frame $graphe.l -borderwidth 0 -cursor arrow -relief groove]
                  pack $graphel -in $graphe -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe1 [frame $graphel.1 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe1 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                      #--- Creation du bouton select
                            button $graphe1.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 1"
                            pack $graphe1.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe1.lab -text "Signal photométrique" -font $av4lconf(font,courier_10_b)
                            pack  $graphe1.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe3 [frame $graphel.3 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe3 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe3.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 3"
                            pack $graphe3.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe3.lab -text "Evenements"
                            pack  $graphe3.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe2 [frame $graphel.2 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe2 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe2.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 2"
                            pack $graphe2.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe2.lab -text "Polynome"
                            pack  $graphe2.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe24 [frame $graphel.24 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe24 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe24.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 24"
                            pack $graphe24.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe24.lab -text "Chi2" -font $av4lconf(font,courier_10_b)
                            pack  $graphe24.lab -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set grapher [frame $graphe.r -borderwidth 0 -cursor arrow -relief groove]
                  pack $grapher -in $graphe -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe23 [frame $grapher.23 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe23 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe23.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 23"
                            pack $graphe23.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe23.lab -text "Ombre interpolée sur les points d'observation" -font $av4lconf(font,courier_10_b)
                            pack  $graphe23.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe20 [frame $grapher.20 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe20 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe20.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 20"
                            pack $graphe20.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe20.lab -text "Ombre géométrique"
                            pack  $graphe20.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe21 [frame $grapher.21 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe21 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe21.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 21"
                            pack $graphe21.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe21.lab -text "Ombre avec diffraction"
                            pack  $graphe21.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe22 [frame $grapher.22 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe22 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe22.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 22"
                            pack $graphe22.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe22.lab -text "Ombre lissee par la reponse instrumentale"
                            pack  $graphe22.lab -side left -anchor e 



#---


#--- ONGLET : Emersion


#---

        #--- Cree un frame pour afficher le contenu de l onglet
        set emersion [frame $f7.frm -borderwidth 0 -cursor arrow -relief groove]
        pack $emersion -in $f7 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5
        
        
             #--- Cree un frame pour le chargement d'un fichier
             set frmgauche [frame $emersion.frmgauche -borderwidth 0 -cursor arrow -relief groove]
             pack $frmgauche -in $emersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  #--- Cree un frame pour le chargement d'un fichier
                  set exposure [frame $frmgauche.exposure -borderwidth 0 -cursor arrow -relief groove]
                  pack $exposure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $exposure.l -text "Temps de pose (sans temps morts) (sec) : "
                       pack  $exposure.l -side left -anchor e 
                       #--- Cree un entry ( == ::av4l_analysis_tools::duree)
                       entry $exposure.v -textvariable ::av4l_analysis_tools::corr_exposure -width 10
                       pack $exposure.v -side left -padx 3 -pady 0 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set duree [frame $frmgauche.duree -borderwidth 0 -cursor arrow -relief groove]
                  pack $duree -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- 
                       label $duree.l -text "Nombre de points mesurés autour l'évenement : "
                       pack  $duree.l -side left -anchor e 
                       #---  
                       label $duree.v -textvariable ::av4l_analysis_tools::nb_p4
                       pack $duree.v -side left -padx 3 -pady 0 -fill x
                       #--- 
                       label $duree.l2 -text "("
                       pack  $duree.l2 -side left -anchor e 
                       #--- 
                       label $duree.v2 -textvariable ::av4l_analysis_gui::duree_max_emersion_search 
                       pack $duree.v2 -side left -padx 3 -pady 0 -fill x
                       #--- 
                       label $duree.l3 -text "sec)"
                       pack  $duree.l3 -side left -anchor e 



                  #--- Cree un frame pour le chargement d'un fichier
                  set dureemax [frame $frmgauche.dureemax -borderwidth 0 -cursor arrow -relief groove]
                  pack $dureemax -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $dureemax.l -text "Durée maxi estimée de l'évenement : "
                       pack  $dureemax.l -side left -anchor e 

                       #--- Cree un entry ( == ::av4l_analysis_tools::duree)
                       label $dureemax.v -textvariable ::av4l_analysis_gui::duree_max_emersion_evnmt 
                       pack $dureemax.v -side left -padx 3 -pady 0 -fill x

                       #--- Cree un label
                       label $dureemax.l2 -text " sec"
                       pack  $dureemax.l2 -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set t0_ref [frame $frmgauche.t0_ref -borderwidth 0 -cursor arrow -relief groove]
                  pack $t0_ref -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $t0_ref.l -text "Heure de reference (sec TU) : "
                       pack  $t0_ref.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $t0_ref.v -textvariable ::av4l_analysis_gui::date_emersion -width 30
                       pack $t0_ref.v -side left -padx 3 -pady 0 -fill x


                  #--- Cree un frame pour le chargement d'un fichier
                  set nheure [frame $frmgauche.nheure -borderwidth 0 -cursor arrow -relief groove]
                  pack $nheure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $nheure.l -text "Nombre d'instant a explorer autour de la reference (points) : "
                       pack  $nheure.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $nheure.v -textvariable ::av4l_analysis_gui::nheure -width 10
                       pack $nheure.v -side left -padx 0 -pady 0 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set pas_heure [frame $frmgauche.pas_heure -borderwidth 0 -cursor arrow -relief groove]
                  pack $pas_heure -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                       #--- Cree un label
                       label $pas_heure.l -text "Pas de recherche de l'instant de l'evenement (sec): "
                       pack  $pas_heure.l -side left -anchor e 

                       #--- Cree un label pour le chemin de l'AVI
                       entry $pas_heure.v -textvariable ::av4l_analysis_gui::pas_heure -width 10
                       pack $pas_heure.v -side left -padx 0 -pady 0 -fill x

                  #--- Cree un frame pour le chargement d'un fichier
                  set dureesearch [frame $frmgauche.dureesearch -borderwidth 0 -cursor arrow -relief groove]
                  pack $dureesearch -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un label
                       label $dureesearch.l -text "Durée de recherche autour de l'evenement : "
                       pack  $dureesearch.l -side left -anchor e 

                       #--- Creation du bouton calcul
                       button $dureesearch.but_reload -image .reload -borderwidth 2 \
                             -command "::av4l_analysis_gui::calcul_dureesearch $dureesearch $::av4l_analysis_gui::duree_max_emersion_search $::av4l_analysis_gui::duree_max_emersion_evnmt"
                       pack $dureesearch.but_reload -side left -anchor c 

                       #--- Cree un label pour le chemin de l'AVI
                       label $dureesearch.v -textvariable ::av4l_analysis_gui::dureesearch
                       pack $dureesearch.v -side left -padx 0 -pady 0 -fill x

                       #--- Cree un label
                       label $dureesearch.l2 -text "sec"
                       pack  $dureesearch.l2 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set em_calcul [frame $emersion.calcul -borderwidth 0 -cursor arrow -relief groove]
             pack $em_calcul -in $emersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5


                  set blockcentre [frame $em_calcul.blockcentre]
                  pack $blockcentre -in $em_calcul -side top -anchor c 

                       #--- Creation du bouton open
                       button $blockcentre.but_calc -image .calc -borderwidth 2 \
                             -command "::av4l_analysis_gui::calcul_evenement 1"
                       pack $blockcentre.but_calc -side left -anchor c 

                       #--- Cree un label
                       label $blockcentre.l -text "Evolution : "
                       pack  $blockcentre.l -side left -anchor e 

                       #--- Cree un label
                       label $blockcentre.v -textvariable ::av4l_analysis_tools::percent
                       pack  $blockcentre.v -side left -anchor e 

             #--- Cree un frame pour le chargement d'un fichier
             set results [frame $emersion.results -borderwidth 1 -cursor arrow -relief raised]
             pack $results -in $emersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                  #--- Cree un frame pour le chargement d'un fichier
                  set frmgauche [frame $results.frmgauche -borderwidth 0 -cursor arrow -relief groove]
                  pack $frmgauche -in $results -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set date_emersion_sol [frame $frmgauche.date_emersion_sol -borderwidth 0 -cursor arrow -relief groove]
                       pack $date_emersion_sol -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $date_emersion_sol.l -text "Date de l'emersion : "
                            pack  $date_emersion_sol.l -side left -anchor e 

                            #--- Cree un label
                            label $date_emersion_sol.v -textvariable ::av4l_analysis_gui::date_emersion_sol
                            pack  $date_emersion_sol.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set chi2_min [frame $frmgauche.chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $chi2_min.l -text "Chi2 : "
                            pack  $chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $chi2_min.v -textvariable ::av4l_analysis_gui::em_chi2_min
                            pack  $chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set nfit_chi2_min [frame $frmgauche.nfit_chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $nfit_chi2_min -in $frmgauche -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $nfit_chi2_min.l -text "Nombre de points utilisés pour l'ajustement : "
                            pack  $nfit_chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $nfit_chi2_min.v -textvariable ::av4l_analysis_gui::em_nfit_chi2_min
                            pack  $nfit_chi2_min.v -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set frmdroit [frame $results.frmdroit -borderwidth 0 -cursor arrow -relief groove]
                  pack $frmdroit -in $results -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set t0_chi2_min [frame $frmdroit.t0_chi2_min -borderwidth 0 -cursor arrow -relief groove]
                       pack $t0_chi2_min -in $frmdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $t0_chi2_min.l -text "t0 normalisé : "
                            pack  $t0_chi2_min.l -side left -anchor e 

                            #--- Cree un label
                            label $t0_chi2_min.v -textvariable ::av4l_analysis_gui::em_t0_chi2_min
                            pack  $t0_chi2_min.v -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set tps_dchi2 [frame $frmdroit.tps_dchi2 -borderwidth 0 -cursor arrow -relief groove]
                       pack $tps_dchi2 -in $frmdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $tps_dchi2.l1 -text "Intervalle 1 \u03C3 : "
                            pack  $tps_dchi2.l1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v1 -textvariable ::av4l_analysis_gui::em_t_inf
                            pack  $tps_dchi2.v1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l2 -text "<=>"
                            pack  $tps_dchi2.l2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v2 -textvariable ::av4l_analysis_gui::em_t_sup
                            pack  $tps_dchi2.v2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l3 -text "  ("
                            pack  $tps_dchi2.l3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v3 -textvariable ::av4l_analysis_gui::em_t_diff
                            pack  $tps_dchi2.v3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l4 -text " sec)"
                            pack  $tps_dchi2.l4 -side left -anchor e 


                       #--- Cree un frame pour le chargement d'un fichier
                       set tps_dchi2 [frame $frmdroit.tps_dchi2_3s -borderwidth 0 -cursor arrow -relief groove]
                       pack $tps_dchi2 -in $frmdroit -anchor s -side top -expand 0 -fill x -padx 10 -pady 0

                            #--- Cree un label
                            label $tps_dchi2.l1 -text "Intervalle 3 \u03C3 : "
                            pack  $tps_dchi2.l1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v1 -textvariable ::av4l_analysis_gui::em_t_inf_3s
                            pack  $tps_dchi2.v1 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l2 -text "<=>"
                            pack  $tps_dchi2.l2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v2 -textvariable ::av4l_analysis_gui::em_t_sup_3s
                            pack  $tps_dchi2.v2 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l3 -text "  ("
                            pack  $tps_dchi2.l3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.v3 -textvariable ::av4l_analysis_gui::em_t_diff_3s
                            pack  $tps_dchi2.v3 -side left -anchor e 

                            #--- Cree un label
                            label $tps_dchi2.l4 -text " sec)"
                            pack  $tps_dchi2.l4 -side left -anchor e 


             #--- Cree un frame pour le chargement d'un fichier
             set graphe [frame $emersion.graphe -borderwidth 0 -cursor arrow -relief groove]
             pack $graphe -in $emersion -anchor s -side top -expand 0 -fill x -padx 10 -pady 5



                  
                  #--- Cree un frame pour le chargement d'un fichier
                  set graphel [frame $graphe.l -borderwidth 0 -cursor arrow -relief groove]
                  pack $graphel -in $graphe -anchor s -side left -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe1 [frame $graphel.1 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe1 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                      #--- Creation du bouton select
                            button $graphe1.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 1"
                            pack $graphe1.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe1.lab -text "Signal photométrique" -font $av4lconf(font,courier_10_b)
                            pack  $graphe1.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe3 [frame $graphel.3 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe3 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe3.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 3"
                            pack $graphe3.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe3.lab -text "Evenements"
                            pack  $graphe3.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe2 [frame $graphel.2 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe2 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe2.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 2"
                            pack $graphe2.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe2.lab -text "Polynome"
                            pack  $graphe2.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe24 [frame $graphel.24 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe24 -in $graphel -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe24.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe l 24"
                            pack $graphe24.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe24.lab -text "Chi2" -font $av4lconf(font,courier_10_b)
                            pack  $graphe24.lab -side left -anchor e 

                  #--- Cree un frame pour le chargement d'un fichier
                  set grapher [frame $graphe.r -borderwidth 0 -cursor arrow -relief groove]
                  pack $grapher -in $graphe -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe23 [frame $grapher.23 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe23 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe23.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 23"
                            pack $graphe23.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe23.lab -text "Ombre interpolée sur les points d'observation" -font $av4lconf(font,courier_10_b)
                            pack  $graphe23.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe20 [frame $grapher.20 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe20 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe20.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 20"
                            pack $graphe20.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe20.lab -text "Ombre géométrique"
                            pack  $graphe20.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe21 [frame $grapher.21 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe21 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe21.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 21"
                            pack $graphe21.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe21.lab -text "Ombre avec diffraction"
                            pack  $graphe21.lab -side left -anchor e 

                       #--- Cree un frame pour le chargement d'un fichier
                       set graphe22 [frame $grapher.22 -borderwidth 0 -cursor arrow -relief groove]
                       pack $graphe22 -in $grapher -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                            #--- Creation du bouton select
                            button $graphe22.view -image .view -compound center \
                               -borderwidth 2 -takefocus 1 -command "::av4l_analysis_gui::active_graphe $graphe r 22"
                            pack $graphe22.view -side left -anchor e -padx 0 -pady 0 -ipadx 0 -ipady 0 -expand 0

                            #--- Cree un label
                            label $graphe22.lab -text "Ombre lissee par la reponse instrumentale"
                            pack  $graphe22.lab -side left -anchor e 





#---


#--- Boutons Pied


#---

         set buttons [frame $frm.buttons -borderwidth 0 -cursor arrow -relief groove]
         pack $buttons -in $frm -side top -expand 0 -fill x -padx 10 -pady 5


              #--- Creation du bouton open
              button $buttons.but_save_project -text "Sauver" -borderwidth 2 \
                    -command "::av4l_analysis_gui::save_project"
              pack $buttons.but_save_project -side left -anchor e 

              #--- Creation du bouton open
              button $buttons.but_fermer -text "Fermer" -borderwidth 2 \
                    -command "::av4l_analysis_gui::closeWindow $this $visuNo"
              pack $buttons.but_fermer -side right -anchor e 


   # Fin proc ::av4l_analysis_gui::createdialog 
   }

