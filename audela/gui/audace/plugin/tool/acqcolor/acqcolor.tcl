#
# Fichier : acqcolor.tcl
# Description : Outil pour l'acquisition d'images en couleur
# Auteurs : Alain KLOTZ et Pierre THIERRY
# Mise a jour $Id: acqcolor.tcl,v 1.17 2010-01-17 18:17:01 robertdelmas Exp $
#

proc testexit { } {
   global audace

   ::cam::delete 1000
   ::buf::delete 1000
   ::visu::delete 1000
   ::buf::delete 1001
   ::visu::delete 1001
   destroy $audace(base).test
}

#--- Chargement de la librairie
load librgb[info sharedlibextension]

#--- Definition des variables globales (arrays)
global caption
global audace
global confcolor
global conf
global zone
global infos

#--- Definition des chemins
set rep(color) [ file join $audace(rep_plugin) tool acqcolor ]

#--- Chargement des captions
source [ file join $rep(color) acqcolor.cap ]

#--- Initialisation des variables de zone
set zone(image1,naxis1) "0"
set zone(image1,naxis2) "0"
set zone(image2,naxis1) "0"
set zone(image2,naxis2) "0"

#--- Initialisation des variables d'infos
set infos(MouseState) "rien"
set infos(box)        {1 1 1 1}
set infos(type_image) ""
set infos(dir)        ""
catch {
   set infos(dir) $audace(rep_images)
}

#--- Valeurs numeriques a placer sur l'ecran
set confcolor(exptime) "1"
set confcolor(nombre)  "3"
set confcolor(name)    "i"
set confcolor(indice)  "1"
set confcolor(att)     "500"

#--- Choix du nombre et des formats des fenetres scrollables
set dimfenx 1016
set dimfeny 700
if { ! [ info exists conf(color_nb_fenetre) ] } { set conf(color_nb_fenetre) "2" }
if { $conf(color_nb_fenetre) == "0" } {
   set dimx1 1000
   set dimy1 515
} elseif { $conf(color_nb_fenetre) == "1" } {
   set dimx1 500
   set dimy1 515
} elseif { $conf(color_nb_fenetre) == "2" } {
   set dimx1 769
   set dimy1 515
}

#
# Scrolled_Canvas
# Cree un canvas scrollable, ainsi que les deux scrollbars pour le deplacer
# Ref: Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
#
proc color_Scrolled_Canvas { c args } {
   frame $c
   eval {canvas $c.canvas \
      -xscrollcommand [ list $c.xscroll set ] \
      -yscrollcommand [ list $c.yscroll set ] \
      -highlightthickness 0 \
      -borderwidth 0} $args
   scrollbar $c.xscroll -orient horizontal -command [ list $c.canvas xview ]
   scrollbar $c.yscroll -orient vertical -command [ list $c.canvas yview ]
   grid $c.canvas $c.yscroll -sticky news
   grid $c.xscroll -sticky ew
   grid rowconfigure $c 0 -weight 1
   grid columnconfigure $c 0 -weight 1
   return $c.canvas
}

#--- Raz de l'image et de l'en-tete FITS
catch { buf1000 clear }

#--- Cree la fenetre $audace(base).test de niveau le plus haut
if { [ winfo exists $audace(base).test ] } {
   wm withdraw $audace(base).test
   wm deiconify $audace(base).test
   focus $audace(base).test
   return
}

toplevel $audace(base).test -class Toplevel -relief groove -borderwidth 0
wm geometry $audace(base).test ${dimfenx}x${dimfeny}+0+0
wm resizable $audace(base).test 1 1
wm minsize $audace(base).test 600 400
wm maxsize $audace(base).test 1800 1550
wm title $audace(base).test "$caption(acqcolor,main_title) ($audace(acqvisu,ccd_model))"

#--- La nouvelle fenetre est active
focus $audace(base).test

#--- Cree un frame en haut a gauche pour les canvas d'affichage
frame $audace(base).test.frame0 \
   -relief groove -borderwidth 2 -cursor arrow
pack $audace(base).test.frame0 \
   -in $audace(base).test -anchor nw -side top -expand 0 -fill x

#--- Cree le canevas pour l'image 1
Scrolled_Canvas $audace(base).test.frame0.image1 -borderwidth 0 -relief flat \
   -width $dimx1 -height $dimy1 -scrollregion {0 0 0 0} -cursor crosshair
$audace(base).test.frame0.image1.canvas configure -borderwidth 0
$audace(base).test.frame0.image1.canvas configure -relief flat
pack $audace(base).test.frame0.image1 \
   -in $audace(base).test.frame0 -expand 1 -side left -anchor center -fill none -pady 5
set zone(image1) $audace(base).test.frame0.image1.canvas

#--- Cree le canevas pour l'image 2
Scrolled_Canvas $audace(base).test.frame0.image2 -borderwidth 0 -relief flat \
   -width $dimx1 -height $dimy1 -scrollregion {0 0 0 0} -cursor crosshair
$audace(base).test.frame0.image2.canvas configure -borderwidth 0
$audace(base).test.frame0.image2.canvas configure -relief flat
pack $audace(base).test.frame0.image2 \
   -in $audace(base).test.frame0 -expand 1 -side left -anchor center -fill none -pady 5
set zone(image2) $audace(base).test.frame0.image2.canvas

#--- Cree un frame en bas a gauche pour les commandes d'acquisition
frame $audace(base).test.frame1 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test.frame1 \
   -in $audace(base).test -anchor nw -side left -expand 0 -fill x -pady 4

   #--- Cree un frame pour les demandes d'acquisition
   frame $audace(base).test.frame1.fra1 \
      -borderwidth 0 -cursor arrow

      #--- Cree le bouton 'Pointage 2x2'
      button $audace(base).test.frame1.fra1.but_pointage \
        -text $caption(acqcolor,pointage) -borderwidth 2 \
        -command { testpointage }
      pack $audace(base).test.frame1.fra1.but_pointage \
         -in $audace(base).test.frame1.fra1 -side left -anchor center \
         -padx 3 -pady 3
      set zone(pointage) $audace(base).test.frame1.fra1.but_pointage

      #--- Cree le bouton 'Acq. fenetre'
      button $audace(base).test.frame1.fra1.but_acqfen \
         -text $caption(acqcolor,acqfen) -borderwidth 2 \
         -command { testacqfen }
      pack $audace(base).test.frame1.fra1.but_acqfen \
         -in $audace(base).test.frame1.fra1 -side left -anchor center \
         -padx 3 -pady 3
      set zone(acqfen) $audace(base).test.frame1.fra1.but_acqfen

      #--- Cree l'entry 'exptime'
      entry $audace(base).test.frame1.fra1.ent_exptime \
         -textvariable confcolor(exptime) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame1.fra1.ent_exptime \
         -in $audace(base).test.frame1.fra1 -side right -anchor center \
         -padx 0 -pady 3
      set zone(exptime) $audace(base).test.frame1.fra1.ent_exptime

      #--- Cree le label 'sec.'
      label $audace(base).test.frame1.fra1.lab_sec \
         -text $caption(acqcolor,sec)
      pack $audace(base).test.frame1.fra1.lab_sec \
         -in $audace(base).test.frame1.fra1 -side right -anchor center \
         -padx 0 -pady 3
      set zone(sec) $audace(base).test.frame1.fra1.lab_sec

   pack $audace(base).test.frame1.fra1 \
      -in $audace(base).test.frame1 -anchor n -side top -expand 0 -fill x

   #--- Cree un frame pour les demandes d'acquisition serie
   frame $audace(base).test.frame1.fra3 \
      -borderwidth 1 -cursor arrow

      #--- Cree le bouton 'Acquisition 1x1'
      button $audace(base).test.frame1.fra3.but_total \
        -text $caption(acqcolor,total) -borderwidth 2 \
        -command { testtotal }
      pack $audace(base).test.frame1.fra3.but_total \
         -in $audace(base).test.frame1.fra3 -side left -anchor center \
         -padx 3 -pady 3
      set zone(total) $audace(base).test.frame1.fra3.but_total

      #--- Cree le bouton 'Acq. serie'
      button $audace(base).test.frame1.fra3.but_acqserie \
         -text $caption(acqcolor,acqserie) -borderwidth 2 \
         -command { acqserie }
      pack $audace(base).test.frame1.fra3.but_acqserie \
         -in $audace(base).test.frame1.fra3 -side left -anchor e \
         -padx 3 -pady 3
      set zone(acqserie) $audace(base).test.frame1.fra3.but_acqserie

      #--- Cree l'entry 'nombre'
      entry $audace(base).test.frame1.fra3.ent_nombre \
         -textvariable confcolor(nombre) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame1.fra3.ent_nombre \
         -in $audace(base).test.frame1.fra3 -side right -anchor center \
         -padx 0 -pady 3
      set zone(nombre) $audace(base).test.frame1.fra3.ent_nombre

      #--- Cree le label 'Nbre image'
      label $audace(base).test.frame1.fra3.lab_nbimage \
         -text $caption(acqcolor,nbimage)
      pack $audace(base).test.frame1.fra3.lab_nbimage \
         -in $audace(base).test.frame1.fra3 -side right -anchor center \
         -padx 0 -pady 3
      set zone(nbimage) $audace(base).test.frame1.fra3.lab_nbimage

   pack $audace(base).test.frame1.fra3 \
      -in $audace(base).test.frame1 -anchor n -side top -expand 0 -fill x

   #--- Cree un frame pour le traitement
   frame $audace(base).test.frame1.fra2 \
      -borderwidth 1 -cursor arrow

      #--- Cree le bouton 'en-tete_fits'
      button $audace(base).test.frame1.fra2.but_en-tete_fits \
         -text $caption(acqcolor,entete_fits) -borderwidth 2 \
         -command { header_color }
       pack $audace(base).test.frame1.fra2.but_en-tete_fits \
         -in $audace(base).test.frame1.fra2 -side left -anchor n \
         -padx 3 -pady 3
       set zone(entete_fits) $audace(base).test.frame1.fra2.but_en-tete_fits

      #--- Cree l'entry 'att'
      entry $audace(base).test.frame1.fra2.ent_att \
         -textvariable confcolor(att) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame1.fra2.ent_att \
         -in $audace(base).test.frame1.fra2 -side right -anchor center \
         -padx 0 -pady 3
       set zone(att) $audace(base).test.frame1.fra2.ent_att

      #--- Cree le label 'Delai'
      label $audace(base).test.frame1.fra2.lab_attente \
         -text $caption(acqcolor,attente)
      pack $audace(base).test.frame1.fra2.lab_attente \
         -in $audace(base).test.frame1.fra2 -side right -anchor center \
         -padx 0 -pady 3
      set zone(attente) $audace(base).test.frame1.fra2.lab_attente

   pack $audace(base).test.frame1.fra2 \
      -in $audace(base).test.frame1 -anchor n -side top -expand 0 -fill x

   #--- Cree un frame pour le traitement (suite)
   frame $audace(base).test.frame1.fra4 \
      -borderwidth 1 -cursor arrow

      #--- Cree le bouton 'smedianrvb'
      button $audace(base).test.frame1.fra4.but_smedianrvb \
         -text $caption(acqcolor,smedianrvb) -borderwidth 2 \
         -command { smedianrvb }
      pack $audace(base).test.frame1.fra4.but_smedianrvb \
         -in $audace(base).test.frame1.fra4 -side left -anchor n \
         -padx 3 -pady 3
      set zone(smedianrvb) $audace(base).test.frame1.fra4.but_smedianrvb

   pack $audace(base).test.frame1.fra4 \
      -in $audace(base).test.frame1 -anchor n -side top -expand 0 -fill x

   #--- Cree un frame pour un intercallaire
   frame $audace(base).test.frame1.fra5 \
      -borderwidth 0 -cursor arrow

      #--- Cree un intercallaire
      label $audace(base).test.frame1.fra5.intercallaire \
         -text ""
      pack $audace(base).test.frame1.fra5.intercallaire \
         -in $audace(base).test.frame1.fra5 -side left -anchor n \
         -padx 3 -pady 3
      set zone(intercallaire) $audace(base).test.frame1.fra5.intercallaire

   pack $audace(base).test.frame1.fra5 \
      -in $audace(base).test.frame1 -anchor n -side top -expand 0 -fill x

#--- Cree un frame au milieu pour y mettre le decompte du temps de pose et les glissieres
frame $audace(base).test.frame2 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test.frame2 \
   -in $audace(base).test -anchor s -side left -expand 0 -fill x

   #--- Cree un frame pour le decompte du temps de pose et le status de la camera
   frame $audace(base).test.frame2.fra0 \
      -borderwidth 0 -cursor arrow
   pack $audace(base).test.frame2.fra0 \
      -in $audace(base).test.frame2 -anchor s -side top -fill x -padx 10

      #--- Cree le label pour le decompte du temps de pose et le status de la camera
      label $audace(base).test.frame2.fra0.labURL_decompte
      pack $audace(base).test.frame2.fra0.labURL_decompte \
         -in $audace(base).test.frame2.fra0 -side left -anchor center \
         -padx 0 -pady 8
      set zone(decompte) $audace(base).test.frame2.fra0.labURL_decompte

      #--- Cree un frame pour y mettre les glissieres
      set smax 100000
     # set smax 255
      set smin 0
      for { set k 1 } { $k <= 3 } { incr k } {
      #--- Selectionne la couleur
      if { $k == 1 } { set c $audace(color,cursor_rgb_red)   ; set cc $audace(color,cursor_rgb_actif) }
      if { $k == 2 } { set c $audace(color,cursor_rgb_green) ; set cc $audace(color,cursor_rgb_actif) }
      if { $k == 3 } { set c $audace(color,cursor_rgb_blue)  ; set cc $audace(color,cursor_rgb_actif) }

      frame $audace(base).test.frame2.fra${k} \
         -borderwidth 0 -cursor arrow
      pack $audace(base).test.frame2.fra${k} \
         -in $audace(base).test.frame2 -anchor s -side left -expand 0 -fill x -padx 10

         frame $audace(base).test.frame2.fra${k}.labs \
            -borderwidth 0 -cursor arrow
         pack $audace(base).test.frame2.fra${k}.labs \
            -in $audace(base).test.frame2.fra${k} -anchor s -side left -expand 0 -fill y

            #--- Cree le label du seuil max
            label $audace(base).test.frame2.fra${k}.labs.labURLmax \
               -borderwidth 0 -cursor arrow -text "$smax" -fg $c
            pack $audace(base).test.frame2.fra${k}.labs.labURLmax \
               -in $audace(base).test.frame2.fra${k}.labs -anchor n -side top -expand 0 -fill x
            set zone(smax$k) $audace(base).test.frame2.fra${k}.labs.labURLmax

            #--- Cree le label du seuil min
            label $audace(base).test.frame2.fra${k}.labs.labURLmin \
               -borderwidth 0 -cursor arrow -text "$smin" -fg $c
            pack $audace(base).test.frame2.fra${k}.labs.labURLmin \
               -in $audace(base).test.frame2.fra${k}.labs -anchor s -side bottom -expand 0 -fill x
            set zone(smin$k) $audace(base).test.frame2.fra${k}.labs.labURLmin

         #--- Cree la glissiere de seuil bas
         scale $audace(base).test.frame2.fra${k}.sca1_$k -orient vertical -from $smin -to $smax -length 115 \
            -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
            -background $c -activebackground $cc \
            -relief raised -command testchangeLoCut$k
         pack $audace(base).test.frame2.fra${k}.sca1_$k \
            -in $audace(base).test.frame2.fra${k} -anchor s -side left -expand 0 -padx 5 -pady 3
         set zone(sb$k) $audace(base).test.frame2.fra${k}.sca1_$k

         #--- Cree la glissiere de seuil haut
         scale $audace(base).test.frame2.fra${k}.sca2_$k -orient vertical -from $smin -to $smax -length 115 \
            -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
            -background $c -activebackground $cc \
            -relief raised -command testchangeHiCut$k
         pack $audace(base).test.frame2.fra${k}.sca2_$k \
            -in $audace(base).test.frame2.fra${k} -anchor s -side left -expand 0 -padx 10 -pady 3
         set zone(sh$k) $audace(base).test.frame2.fra${k}.sca2_$k
      }

#--- Cree un frame en bas a droite pour les commandes d'enregistrement, d'ouverture
#--- et d'enregistrement sous le format jpeg
frame $audace(base).test.frame3 \
   -borderwidth 0 -cursor arrow
pack $audace(base).test.frame3 \
   -in $audace(base).test -anchor se -side right -expand 0 -fill x

   #--- Cree un frame pour les enregistrements et chargement d'images
   frame $audace(base).test.frame3.fra1 \
      -borderwidth 0 -cursor arrow

      #--- Cree l'entry 'name'
      entry $audace(base).test.frame3.fra1.ent_name \
         -textvariable confcolor(name) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame3.fra1.ent_name \
         -in $audace(base).test.frame3.fra1 -side left -anchor center \
         -padx 3 -pady 3
      set zone(name) $audace(base).test.frame3.fra1.ent_name

      #--- Cree l'entry 'indice'
      entry $audace(base).test.frame3.fra1.ent_indice \
         -textvariable confcolor(indice) -width 4 \
         -relief groove -justify center
      pack $audace(base).test.frame3.fra1.ent_indice \
         -in $audace(base).test.frame3.fra1 -side left -anchor center \
         -padx 3 -pady 3
      set zone(name) $audace(base).test.frame3.fra1.ent_name

      #--- Cree le bouton 'Save auto'
      button $audace(base).test.frame3.fra1.but_saveauto \
         -text $caption(acqcolor,saveauto) -borderwidth 2 \
         -command { testsaveauto }
      pack $audace(base).test.frame3.fra1.but_saveauto \
         -in $audace(base).test.frame3.fra1 -side top -anchor center \
         -padx 3 -pady 3
      set zone(saveauto) $audace(base).test.frame3.fra1.but_saveauto

      #--- Cree le bouton 'Sauve Jpeg'
      button $audace(base).test.frame3.but_jpeg \
         -text $caption(acqcolor,jpeg) -borderwidth 2 \
         -command { testjpeg }
      pack $audace(base).test.frame3.but_jpeg \
         -in $audace(base).test.frame3 -side bottom -anchor center \
         -padx 3 -pady 3
      set zone(jpeg) $audace(base).test.frame3.but_jpeg

      #--- Cree le bouton 'Load'
      button $audace(base).test.frame3.but_load \
         -text $caption(acqcolor,load) -borderwidth 2 \
         -command { testload }
      pack $audace(base).test.frame3.but_load \
         -in $audace(base).test.frame3 -side bottom -anchor center \
         -padx 3 -pady 3
      set zone(load) $audace(base).test.frame3.but_load

      #--- Cree le bouton 'Save'
      button $audace(base).test.frame3.but_save \
         -text $caption(acqcolor,save) -borderwidth 2 \
         -command { testsave }
      pack $audace(base).test.frame3.but_save \
         -in $audace(base).test.frame3 -side bottom -anchor center \
         -padx 3 -pady 3
      set zone(save) $audace(base).test.frame3.but_save

   pack $audace(base).test.frame3.fra1 \
      -in $audace(base).test.frame3 -anchor center -side top -expand 0 -fill x

#--- Cree un frame en bas a droite pour les reglages de l'obturateur et de la luminosite
frame $audace(base).test.frame2b \
   -borderwidth 0 -cursor arrow
pack $audace(base).test.frame2b \
   -in $audace(base).test -anchor center -side right -expand 0 -fill x

   #--- Cree un frame pour le choix du nombre et du format des fenetres scrollables
   frame $audace(base).test.frame2b.frame_rad \
      -borderwidth 0 -cursor arrow
   pack $audace(base).test.frame2b.frame_rad \
      -in $audace(base).test.frame2b -anchor center -side top -expand 0 -fill x

      #--- Bouton radio 1 fenetre
      radiobutton $audace(base).test.frame2b.frame_rad.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(acqcolor,1_fenetre)" -value 0 -variable conf(color_nb_fenetre) \
         -command { color_nb_fenetre }
      pack $audace(base).test.frame2b.frame_rad.rad0 \
         -in $audace(base).test.frame2b.frame_rad -side left -anchor center \
         -padx 3 -pady 3
      #--- Bouton radio 2 fenetres
      radiobutton $audace(base).test.frame2b.frame_rad.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(acqcolor,2_fenetre)" -value 1 -variable conf(color_nb_fenetre) \
         -command { color_nb_fenetre }
      pack $audace(base).test.frame2b.frame_rad.rad1 \
         -in $audace(base).test.frame2b.frame_rad -side left -anchor center \
         -padx 3 -pady 3
      #--- Bouton radio 2 fenetres (special Pierre Thierry)
      radiobutton $audace(base).test.frame2b.frame_rad.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(acqcolor,2_fenetre_pth)" -value 2 -variable conf(color_nb_fenetre) \
         -command { color_nb_fenetre }
      pack $audace(base).test.frame2b.frame_rad.rad2 \
         -in $audace(base).test.frame2b.frame_rad -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree le bouton 'Obturateur'
      button $audace(base).test.frame2b.but_obtu \
         -text $caption(acqcolor,obtu) -borderwidth 2 \
         -command { set confcolor(obtu_pierre) "0" ; ::Obtu_Pierre::run 1000 }
      pack $audace(base).test.frame2b.but_obtu \
         -in $audace(base).test.frame2b -side top -anchor center \
         -padx 3 -pady 3
      set zone(obtu) $audace(base).test.frame2b.but_obtu

      #--- Cree le bouton 'luminosite'
      button $audace(base).test.frame2b.but_luminosite \
         -text $caption(acqcolor,luminosite) -borderwidth 2 \
         -command { luminosite }
      pack $audace(base).test.frame2b.but_luminosite \
         -in $audace(base).test.frame2b -side top -anchor center \
         -padx 3 -pady 3
      set zone(luminosite) $audace(base).test.frame2b.but_luminosite

      #--- Cree l'entry 'niveauhaut'
      entry $audace(base).test.frame2b.ent_niveauhaut \
         -textvariable confcolor(niveauhaut) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame2b.ent_niveauhaut \
         -in $audace(base).test.frame2b -side left -anchor center \
         -padx 3 -pady 3
     set zone(niveauhaut) $audace(base).test.frame2b.ent_niveauhaut

      #--- Cree l'entry 'niveaubas'
      entry $audace(base).test.frame2b.ent_niveaubas \
         -textvariable confcolor(niveaubas) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame2b.ent_niveaubas \
         -in $audace(base).test.frame2b -side left -anchor center \
         -padx 3 -pady 3
      set zone(niveaubas) $audace(base).test.frame2b.ent_niveaubas

      #--- Cree l'entry 'cfv'
      entry $audace(base).test.frame2b.ent_cfv \
         -textvariable confcolor(cfv) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame2b.ent_cfv \
         -in $audace(base).test.frame2b -side left -anchor center \
         -padx 3 -pady 3
      set zone(cfv) $audace(base).test.frame2b.ent_cfv

      #--- Cree le label 'vert'
      label $audace(base).test.frame2b.lab_vert \
         -text $caption(acqcolor,vert)
      pack $audace(base).test.frame2b.lab_vert \
         -in $audace(base).test.frame2b -side left -anchor center \
         -padx 3 -pady 3
      set zone(vert) $audace(base).test.frame2b.lab_vert

      #--- Cree l'entry 'cfb'
      entry $audace(base).test.frame2b.ent_cfb \
         -textvariable confcolor(cfb) -width 5 \
         -relief groove -justify center
      pack $audace(base).test.frame2b.ent_cfb \
         -in $audace(base).test.frame2b -side left -anchor center \
         -padx 3 -pady 3
      set zone(cfb) $audace(base).test.frame2b.ent_cfb

      #--- Cree le label 'bleu'
      label $audace(base).test.frame2b.lab_bleu \
         -text $caption(acqcolor,bleu)
      pack $audace(base).test.frame2b.lab_bleu \
         -in $audace(base).test.frame2b -side left -anchor center \
         -padx 3 -pady 3
      set zone(bleu) $audace(base).test.frame2b.lab_bleu

#--- Mise a jour dynamique des couleurs
::confColor::applyColor $audace(base).test

#--- Detruit la fenetre principale avec la croix en haut a droite
bind $audace(base).test <Destroy> { testexit }

#--- Declare un buffer pour placer les images en mémoire
global conf

buf::create 1000
buf1000 extension "$conf(extension,defaut)"
buf::create 1001
buf1001 extension "$conf(extension,defaut)"

#--- Re-affiche l'image si on relache les curseurs des glissieres
for { set k 1 } { $k <= 3 } { incr k } {
   bind $zone(sh$k) <ButtonRelease> { testrevisu }
   bind $zone(sb$k) <ButtonRelease> { testrevisu }
}

#--- Debut de cadre
bind $zone(image1) <ButtonPress-1> {
   global infos

   if { [ string compare $infos(MouseState) rien ] == "0" } {
      set liste [ testscreen2Canvas [ list %x %y ] ]
      if { [ info exists zone(image1,naxis1) ] == "1" } {
         if { [ lindex $liste 0 ] < $zone(image1,naxis1) && [ lindex $liste 1 ] < $zone(image1,naxis2) } {
            testboxBegin [ list %x %y ]
            set infos(MouseState) dragging
         }
      }
   } else {
      if { [ string compare $infos(MouseState) context ] == "0" } {
         set infos(MouseState) rien
      }
   }
}

#--- Elargissement de cadre
bind $zone(image1) <B1-Motion> {
   global infos

   if { [ string compare $infos(MouseState) dragging ] == "0" } {
      #--- On n'oublie pas de dragger eventuellement la fenetre
      testboxDrag [ list %x %y ]
   }
}

#--- Fin de cadre
bind $zone(image1) <ButtonRelease-1> {
   global infos

   if { [ string compare $infos(MouseState) dragging ] == "0" } {
      set infos(MouseState) rien
      catch { testboxEnd [ list %x %y ] }
   }
}

#--- Copie vers la zone d'affichage numero 2
bind $zone(image2) <ButtonPress-1> {
   bell
   testcopy1to2
}
bind $audace(base).test <Key-Escape> {
   bell
   testcopy1to2
}

#--- Acquisition fenetre suivante
bind $audace(base).test <Key-space> {
   bell
   testacqfen
}

#--- Revisu des seuils auto
bind $audace(base).test <Key-F1> {
   buf1000 stat
   buf1001 stat
   testvisu
}

#--- Sauve automatiquement
bind $audace(base).test <Key-Return> {
   bell
   testsaveauto
}

#--- Modifie les limites des barres de seuil
bind $zone(smax1) <ButtonPress-1> { testmodifseuillimites 1000 1 + }
bind $zone(smin1) <ButtonPress-1> { testmodifseuillimites 1000 1 - }
bind $zone(smax2) <ButtonPress-1> { testmodifseuillimites 1000 2 + }
bind $zone(smin2) <ButtonPress-1> { testmodifseuillimites 1000 2 - }
bind $zone(smax3) <ButtonPress-1> { testmodifseuillimites 1000 3 + }
bind $zone(smin3) <ButtonPress-1> { testmodifseuillimites 1000 3 - }

#--- Affiche la valeur du pixel pointe dans l'image
bind $zone(image1) <Motion> {
   global audace
   global zone
   global caption

   #--- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
   set xy [ testscreen2Canvas [ list %x %y ] ]
   #--- Transforme les coordonnees canvas (x,y) en coordonnees image (xi,yi)
   set xyi [ testcanvas2Picture $xy ]
   set xi [ lindex $xyi 0 ]
   set yi [ lindex $xyi 1 ]
   #--- Intens contiendra l'intensite du pixel pointe
   set intens -
   if { $infos(type_image) == "couleur" } {
      catch {
         set intens1 [ lindex [ buf1000 getpix [ list $xi $yi ] ] 1 ]
         set intens2 [ lindex [ buf1000 getpix [ list $xi $yi ] ] 2 ]
         set intens3 [ lindex [ buf1000 getpix [ list $xi $yi ] ] 3 ]
         set intens1 [ expr round($intens1) ]
         set intens2 [ expr round($intens2) ]
         set intens3 [ expr round($intens3) ]
         set intens "$intens1 $intens2 $intens3"
      }
   } elseif { $infos(type_image) == "noiretblanc" } {
      catch {
         set intens [ lindex [ buf1000 getpix [ list $xi $yi ] ] 1 ]
         set intens [ expr round($intens) ]
         set intens "$intens"
      }
   }
   #--- Affichage des coordonnees
   wm title $audace(base).test "$caption(acqcolor,main_title) ($audace(acqvisu,ccd_model)) ($xi,$yi) = $intens   "
}

#--- Declare une connexion avec une camera Audine couleur sur LPT1
if {$audace(acqvisu,ccd)=="kac1310"} {
   #---
   if { ! [ info exists conf(scr1300xtc,port) ] } { set conf(scr1300xtc,port) "lpt1" }
   #---
   cam::create synonyme $conf(scr1300xtc,port) -num 1000
   cam1000 interrupt 0
   cam1000 buf 1000
} elseif { $audace(acqvisu,ccd) == "kaf1600" } {
   #---
   if { ! [ info exists conf(audine,port) ] } { set conf(audine,port) "lpt1" }
   #---
   cam::create audine $conf(audine,port) -num 1000 -ccd kaf1602
   cam1000 buf 1000
   cam1000 shutter synchro
   cam1000 shuttertype "audine"
} else {
   #---
   if { ! [ info exists conf(audine,port) ] } { set conf(audine,port) "lpt1" }
   #---
   cam::create audine $conf(audine,port) -num 1000 -ccd kaf401
   cam1000 buf 1000
   cam1000 shutter synchro
   cam1000 shuttertype "thierry"
}

#--- Declare un nouvel objet de visualisation pour afficher le contenu du buffer
::visu::create 1000 1000 1000
::visu::create 1000 1001 1001

#--- Cree un widget image dans un canvas pour afficher l'objet de visualisation
catch {
   $zone(image1) create image 0 0 -image image1000 -anchor nw -tag img1
   image delete image1000
}

#--- Cree un widget image dans un canvas pour afficher l'objet de visualisation
catch {
   $zone(image2) create image 0 0 -image image1001 -anchor nw -tag img1
   image delete image1001
}

proc testcopy1to2 { } {
   global zone
   global infos

   #--- Initialisation de l'ecran zone(image2)
   image create photo image1001

   if { $infos(type_image) == "couleur" } {
      catch {
         #--- Ajuste les scrollbars
         set zone(image2,naxis1) [ lindex [buf1000 getkwd NAXIS1] 1 ]
         set zone(image2,naxis2) [ lindex [buf1000 getkwd NAXIS2] 1 ]
         $zone(image2) configure -scrollregion [ list 0 0 $zone(image2,naxis1) $zone(image2,naxis2) ]
         visu1001 disp [ lindex $infos(rgbcuts) 0 ] [ lindex $infos(rgbcuts) 1 ] [ lindex $infos(rgbcuts) 2 ]
      }
   } elseif { $infos(type_image) == "noiretblanc" } {
      catch {
         visu1001 cut [ visu1000 cut ]
         #--- Ajuste les scrollbars
         set zone(image2,naxis1) [ lindex [ buf1000 getkwd NAXIS1 ] 1 ]
         set zone(image2,naxis2) [ lindex [ buf1000 getkwd NAXIS2 ] 1 ]
         $zone(image2) configure -scrollregion [ list 0 0 $zone(image2,naxis1) $zone(image2,naxis2) ]
         visu1001 disp
      }
   }
}

proc telshift { } {
   global conf
   global confcolor

   bell
   catch {
      combit [ string range $conf(telcom,port) 3 3 ] 3 1
      combit [ string range $conf(telcom,port) 3 3 ] 7 1
      after $confcolor(att)
      combit [ string range $conf(telcom,port) 3 3 ] 3 0
      combit [ string range $conf(telcom,port) 3 3 ] 7 0
   }
   bell
}

proc testpointage { } {
   global audace
   global confcolor
   global caption
   global infos
   global zone
   global color

   catch { $zone(image1) delete $infos(hBox) }
   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra1.but_pointage configure -relief groove -state disabled
   #--- Affichage du status
   $audace(base).test.frame2.fra0.labURL_decompte configure -text $caption(acqcolor,raz) -fg $color(red)
   update
   #--- Acquisition de l'image
   cam1000 exptime $confcolor(exptime)
   cam1000 bin {2 2}
   set dimxy [ cam1000 nbcells ]
   cam1000 window [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
   if { $confcolor(exptime) <= "1" } {
      $audace(base).test.frame2.fra0.labURL_decompte configure -text $caption(acqcolor,lecture) -fg $color(red)
      update
   }
   cam1000 acq
   #--- Alarme sonore de fin de pose
   ::camera::alarmeSonore $confcolor(exptime)
   #--- Appel du timer
   if { $confcolor(exptime) > "2" } {
      dispTime $audace(base).test.frame2.fra0.labURL_decompte $color(red)
   }
   #--- Attend la fin de la pose
   vwait status_cam1000
   set infos(type_image) "noiretblanc"
   testvisu
   #--- Affichage du status
   $audace(base).test.frame2.fra0.labURL_decompte configure -text ""
   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra1.but_pointage configure -relief raised -state normal
   update
}

proc testacqfen { } {
   global confcolor
   global infos
   global zone
   global audace
   global caption
   global conf
   global color

   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra1.but_acqfen configure -relief groove -state disabled
   #--- Affichage du status
   $audace(base).test.frame2.fra0.labURL_decompte configure -text $caption(acqcolor,raz) -fg $color(red)
   update
   #--- Preparation de la fenetre
   if { [ info exists infos(box) ] == "0" } {
      set infos(box) {}
   }
   if { [ llength $infos(box) ] == "4" } {
      set x1 [ expr [ lindex $infos(box) 0 ]*2-1 ]
      set y1 [ expr [ lindex $infos(box) 1 ]*2-1 ]
      set x2 [ expr [ lindex $infos(box) 2 ]*2-1 ]
      set y2 [ expr [ lindex $infos(box) 3 ]*2-1 ]
   } else {
      set dimxy [ cam1000 nbcells ]
      set x1 1
      set y1 [ expr [ lindex $dimxy 0 ]/2 ]
      set x2 1
      set y2 [ expr [ lindex $dimxy 1 ]/2 ]
   }
   set box [ list $x1 $y1 $x2 $y2 ]
   catch { $zone(image1) delete $infos(hBox) }
   #--- Acquisition de l'image
   cam1000 exptime $confcolor(exptime)
   cam1000 bin {1 1}
   cam1000 window $box
   if { $confcolor(exptime) <= "1" } {
      $audace(base).test.frame2.fra0.labURL_decompte configure -text $caption(acqcolor,lecture) -fg $color(red)
      update
   }
   cam1000 acq
   #--- Alarme sonore de fin de pose
   ::camera::alarmeSonore $confcolor(exptime)
   #--- Appel du timer
   if { $confcolor(exptime) > "2" } {
      dispTime $audace(base).test.frame2.fra0.labURL_decompte $color(red)
   }
   #--- Attend la fin de la pose
   vwait status_cam1000
   set infos(type_image) "couleur"
   if { $audace(acqvisu,ccd)== "kac1310" } {
      rgb_split 1000 -rgb cmy
   } else {
      rgb_split 1000 -rgb cfa
   }
   buf1000 extension "$conf(extension,defaut)"
   testvisu
   #--- Affichage du status
   $audace(base).test.frame2.fra0.labURL_decompte configure -text ""
   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra1.but_acqfen configure -relief raised -state normal
   update
}

proc testtotal { } {
   global audace
   global confcolor
   global caption
   global infos
   global zone
   global color

   catch { $zone(image1) delete $infos(hBox) }
   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra3.but_total configure -relief groove -state disabled
   #--- Affichage du status
   $audace(base).test.frame2.fra0.labURL_decompte configure -text $caption(acqcolor,raz) -fg $color(red)
   update
   #--- Acquisition de l'image
   cam1000 exptime $confcolor(exptime)
   cam1000 bin {1 1}
   cam1000 window [ list 1 1 [ lindex [ cam1000 nbcells ] 0 ] [ lindex [ cam1000 nbcells ] 1 ] ]
   if { $confcolor(exptime) <= "1" } {
      $audace(base).test.frame2.fra0.labURL_decompte configure -text $caption(acqcolor,lecture) -fg $color(red)
      update
   }
   cam1000 acq
   #--- Alarme sonore de fin de pose
   ::camera::alarmeSonore $confcolor(exptime)
   #--- Appel du timer
   if { $confcolor(exptime) > "2" } {
      dispTime $audace(base).test.frame2.fra0.labURL_decompte $color(red)
   }
   #--- Attend la fin de la pose
   vwait status_cam1000
   set infos(type_image) "couleur"
   rgb_split 1000
   testvisu
   #--- Affichage du status
   $audace(base).test.frame2.fra0.labURL_decompte configure -text ""
   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra3.but_total configure -relief raised -state normal
   update
}

proc acqserie { } {
   global confcolor
   global audace
   global conf

   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra3.but_acqserie configure -relief groove -state disabled
   #--- Serie d'acquisition
   for { set k 1 } { $k <= $confcolor(nombre) } { incr k } {
      testtotal
      telshift
      after 2000
      testsaveauto
   }
   #--- Gestion graphique du bouton
   $audace(base).test.frame1.fra3.but_acqserie configure -relief raised -state normal
   update
}

proc dispTime { labelTime colorLabel } {
   global caption

   set t [ cam1000 timer -1 ]

   if { $t > "1" } {
      $labelTime configure -text "[ expr $t-1 ] / [ format "%d" [ expr int([ cam1000 exptime ]) ] ]" \
         -fg $colorLabel
      update
      after 1000 dispTime $labelTime $colorLabel
   } else {
      $labelTime configure -text "$caption(acqcolor,lecture)" -fg $colorLabel
      update
   }
}

proc seprvb { } {
   global audace

   catch {
      source [ file join $audace(rep_plugin) tool acqcolor seprvb.tcl ]
   }
}

proc trichro { } {
   global audace

   catch {
      source [ file join $audace(rep_plugin) tool acqcolor trichro.tcl ]
   }
}

proc smedianrvb { } {
   global audace

   catch {
      source [ file join $audace(rep_plugin) tool acqcolor smedianrvb.tcl ]
   }
}

proc testrevisu { } {
   global infos

   if { $infos(type_image) == "couleur" } {
      visu1000 disp [ lindex $infos(rgbcuts) 0 ] [ lindex $infos(rgbcuts) 1 ] [ lindex $infos(rgbcuts) 2 ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      catch { visu1000 disp }
   }
}

proc testvisu { } {
   global zone
   global infos

   #--- Initialisation de l'ecran zone(image1)
   image create photo image1000

   if { $infos(type_image) == "couleur" } {
      set zone(image1,naxis1) [ lindex [ buf1000 getkwd NAXIS1 ] 1 ]
      set zone(image1,naxis2) [ lindex [ buf1000 getkwd NAXIS2 ] 1 ]
      #--- Statistiques pour calculer les seuils de visu
      set mycuts1 [ testgetseuils 1000 ]
      set mycuts2 [ testgetseuils 1000 ]
      set mycuts3 [ testgetseuils 1000 ]
      set infos(rgbcuts) [ list $mycuts1 $mycuts2 $mycuts3 ]
      #--- Definit les limites de seuils bas et haut et place les
      #--- curseurs des barres de seuil au bon endroit
      set lohi [ testseuillimites 1000 1 ]
      testsetscales $lohi 1
      set lohi [ testseuillimites 1000 2 ]
      testsetscales $lohi 2
      set lohi [ testseuillimites 1000 3 ]
      testsetscales $lohi 3
      #--- Ajuste les scrollbars
      $zone(image1) configure -scrollregion [ list 0 0 $zone(image1,naxis1) $zone(image1,naxis2) ]
      #--- Affiche l'image
      visu1000 disp $mycuts1 $mycuts2 $mycuts3
   } elseif { $infos(type_image) == "noiretblanc" } {
      set zone(image1,naxis1) [ lindex [ buf1000 getkwd NAXIS1 ] 1 ]
      set zone(image1,naxis2) [ lindex [ buf1000 getkwd NAXIS2 ] 1 ]
      #--- Statistiques pour calculer les seuils de visu
      set mycuts [ testgetseuils 1000 ]
      visu1000 cut $mycuts
      #--- Definit les limites de seuils bas et haut
      set lohi [ testseuillimites 1000 1 ]
      #--- Place les curseurs des barres de seuil au bon endroit
      testsetscales $lohi 1
      #--- Ajuste les scrollbars
      $zone(image1) configure -scrollregion [ list 0 0 $zone(image1,naxis1) $zone(image1,naxis2) ]
      #--- Affiche l'image
      visu1000 disp
   }
}

proc luminosite { } {
   global confcolor
   global infos

   catch {
      set vh1 "$confcolor(niveauhaut)"
      set vb1 "$confcolor(niveaubas)"
      set kv  "$confcolor(cfv)"
      set kb  "$confcolor(cfb)"
      set vh [ expr $vh1/$kv ]
      set vb [ expr $vb1/$kv ]
      set bh [ expr $vh1/$kb ]
      set bb [ expr $vb1/$kb ]
      set mycuts1 "$confcolor(niveauhaut) $confcolor(niveaubas)"
      set mycuts2 "$vh $vb"
      set mycuts3 "$bh $bb"
      set infos(rgbcuts) [ list $mycuts1 $mycuts2 $mycuts3 ]
      #--- Affiche l'image
      visu1000 disp $mycuts1 $mycuts2 $mycuts3
   }
}

proc testsetscales { lohi numzone } {
   global zone

   set lo [ lindex $lohi 0 ]
   set hi [ lindex $lohi 1 ]
   set mini [ $zone(sb$numzone) cget -from ]
   set maxi [ $zone(sb$numzone) cget -to ]
   #--- Place les curseurs des barres de seuil au bon endroit
   set lo [ lindex $lo 1 ]
   set s [ expr 1.*($lo-$mini)/($maxi-$mini) ]
   set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
   $zone(sb$numzone) set $s
   set hi [ lindex $hi 1 ]
   set s [ expr 1.*($hi-$mini)/($maxi-$mini) ]
   set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
   $zone(sh$numzone) set $s
}

proc testseuillimites { numbuf numzone } {
   global zone

   set hi [ buf$numbuf getkwd MIPS-HI ]
   set lo [ buf$numbuf getkwd MIPS-LO ]
   set maxi [ lindex [ buf$numbuf getkwd DATAMAX ] 1 ]
   set mini [ lindex [ buf$numbuf getkwd DATAMIN ] 1 ]
   if { $maxi == "" } {
      buf$numbuf stat
      set maxi [ lindex [ buf$numbuf getkwd DATAMAX ] 1 ]
      set mini [ lindex [ buf$numbuf getkwd DATAMIN ] 1 ]
   }
   set range [ expr $maxi-$mini ]
   if { [ expr $range ] == "0.0" } {
      set range 10000
   }
   set mini [ expr $mini-$range ]
   set maxi [ expr $maxi+$range ]
   $zone(sb$numzone) configure -from $mini -to $maxi
   $zone(sh$numzone) configure -from $mini -to $maxi
   $zone(smax$numzone) configure -text $maxi
   $zone(smin$numzone) configure -text $mini
   if { [ lindex $hi 1 ] != "" } { buf$numbuf setkwd $hi }
   if { [ lindex $lo 1 ] != "" } { buf$numbuf setkwd $lo }
   return [ list $lo $hi ]
}

proc testmodifseuillimites { numbuf numzone plusmoins } {
   global zone

   set hi [ lindex [ buf$numbuf getkwd MIPS-HI ] 1 ]
   set lo [ lindex [ buf$numbuf getkwd MIPS-LO ] 1 ]
   if { $hi > $lo } {
      set smax $hi
      set smin $lo
   } else {
      set smax $lo
      set smin $hi
   }
   set maxi [ $zone(sb$numzone) cget -to ]
   set mini [ $zone(sb$numzone) cget -from ]
   set rangemax [ expr $maxi-$smax ]
   set rangemin [ expr $smin-$mini ]
   if { $plusmoins == "+" } {
      set mini [ expr int($smin-2*$rangemin) ]
      set maxi [ expr int($smax+2*$rangemax) ]
   } else {
      set mini [ expr int($smin-$rangemin/2) ]
      set maxi [ expr int($smax+$rangemax/2) ]
   }
   $zone(sb$numzone) configure -from $mini -to $maxi
   $zone(sh$numzone) configure -from $mini -to $maxi
   $zone(smax$numzone) configure -text $maxi
   $zone(smin$numzone) configure -text $mini
   set lo [ list "rien" $lo ]
   set hi [ list "rien" $hi ]
   testsetscales [ list $lo $hi ] $numzone
}

proc testload { } {
   global audace
   global infos
   global zone

   #--- Fenetre parent
   set fenetre "$audace(base).test"
   #--- Buffer couleur
   set n_buffer_couleur "1000"
   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_load $fenetre $infos(dir) $n_buffer_couleur "1" ]
   if { $filename != "" } {
      catch { $zone(image1) delete $infos(hBox) }
      catch { set infos(dir) [ file dirname $filename ] }
      if { $infos(dir) == "" } {
         set infos(dir) "./"
      } else {
         append infos(dir) "/"
      }
      buf1000 load $filename
      if { [ buf1000 getnaxis ] == "3" } {
         set infos(type_image) "couleur"
      } else {
         set infos(type_image) "noiretblanc"
      }
      testvisu
   }
}

proc testsave { } {
   global audace
   global infos

   #--- Fenetre parent
   set fenetre "$audace(base).test"
   #--- Buffer couleur
   set n_buffer_couleur "1000"
   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_save $fenetre $infos(dir) $n_buffer_couleur "1" ]
   if { $filename != "" } {
      catch { set infos(dir) [ file dirname $filename ] }
      if { $infos(dir) == "" } {
          set infos(dir) "./"
      } else {
         append infos(dir) "/"
      }
      if { $infos(type_image) == "couleur" } {
         for { set k 1 } { $k <= 3 } { incr k } {
            set kk [ expr $k-1 ]
            set hi [ buf100$k getkwd MIPS-HI ]
            buf100$k setkwd [ lreplace $hi 1 1 [ lindex [ lindex $infos(rgbcuts) $kk ] 0 ] ]
            set lo [ buf100$k getkwd MIPS-LO ]
            buf100$k setkwd [ lreplace $lo 1 1 [ lindex [ lindex $infos(rgbcuts) $kk ] 1 ] ]
         }
         rgb_save $filename
      } elseif { $infos(type_image) == "noiretblanc" } {
         buf1000 save $filename
      }
   }
}

proc testsaveauto { } {
   global confcolor
   global infos

   set filename [ file join $infos(dir) $confcolor(name)$confcolor(indice) ]
   if { $filename != "" } {
      if { $infos(type_image) == "couleur" } {
         for { set k 1 } { $k <= 3 } { incr k } {
            set kk [ expr $k-1 ]
            set hi [ buf100$k getkwd MIPS-HI ]
            buf100$k setkwd [ lreplace $hi 1 1 [ lindex [ lindex $infos(rgbcuts) $kk ] 0 ] ]
            set lo [ buf100$k getkwd MIPS-LO ]
            buf100$k setkwd [ lreplace $lo 1 1 [ lindex [ lindex $infos(rgbcuts) $kk ] 1 ] ]
         }
         rgb_save $filename
      } elseif { $infos(type_image) == "noiretblanc" } {
         buf1000 save $filename
      }
   }
   incr confcolor(indice)
   update
}

#
# Retourne un liste contenant le seuil haut et bas de l'image
#
proc testgetseuils { bufnum } {
   #--- On recherche la valeur du mot cle MIPS-HI
   set hi [ lindex [ buf$bufnum getkwd MIPS-HI ] 1 ]
   if { $hi == "" } {
      #--- Sinon on recherche la valeur du mot cle DATAMAX
      set hi [ lindex [ buf$bufnum getkwd DATAMAX ] 1 ]
   }
   if { $hi == "" } {
      #--- Sinon on fait un stat sur l'image
      buf$bufnum stat
      set hi [ lindex [ buf$bufnum getkwd MIPS-HI ] 1 ]
      set lo [ lindex [ buf$bufnum getkwd MIPS-LO ] 1 ]
   }
   #--- On recherche la valeur du mot cle MIPS-LO
   set lo [ lindex [ buf$bufnum getkwd MIPS-LO ] 1 ]
   if { $lo == "" } {
      #--- Sinon on recherche la valeur du mot cle DATAMIN
      set lo [ lindex [ buf$bufnum getkwd DATAMIN ] 1 ]
   }
   if { $lo == "" } {
      set lo 0
   }
   return [ list $hi $lo ]
}

#
# Nouvelle valeur de seuil haut
#
proc testchangeHiCut1 { foo } {
   global zone
   global infos

   if { $infos(type_image) == "couleur" } {
      set sbh1 [ lindex $infos(rgbcuts) 0 ]
      set sbh2 [ lindex $infos(rgbcuts) 1 ]
      set sbh3 [ lindex $infos(rgbcuts) 2 ]
      set mini [ $zone(sh1) cget -from ]
      set maxi [ $zone(sh1) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      set sbh1 [ list $s [ lindex $sbh1 1 ] ]
      set infos(rgbcuts) [ list $sbh1 $sbh2 $sbh3 ]
      set seuils_rgb [ visu1000 cut ]
      visu1000 cut [ lreplace $seuils_rgb 0 0 $s ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      set sbh [ visu1000 cut ]
      set mini [ $zone(sh1) cget -from ]
      set maxi [ $zone(sh1) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      visu1000 cut [ list $s [ lindex $sbh 1 ] ]
   }
}

proc testchangeHiCut2 { foo } {
   global zone
   global infos

   if { $infos(type_image) == "couleur" } {
      set sbh1 [ lindex $infos(rgbcuts) 0 ]
      set sbh2 [ lindex $infos(rgbcuts) 1 ]
      set sbh3 [ lindex $infos(rgbcuts) 2 ]
      set mini [ $zone(sh2) cget -from ]
      set maxi [ $zone(sh2) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      set sbh2 [ list $s [ lindex $sbh2 1 ] ]
      set infos(rgbcuts) [ list $sbh1 $sbh2 $sbh3 ]
      set seuils_rgb [ visu1000 cut ]
      visu1000 cut [ lreplace $seuils_rgb 2 2 $s ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      set sbh [ visu1000 cut ]
      set mini [ $zone(sh2) cget -from ]
      set maxi [ $zone(sh2) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      visu1000 cut [ list $s [ lindex $sbh 1 ] ]
   }
}

proc testchangeHiCut3 { foo } {
   global zone
   global infos

   if { $infos(type_image) == "couleur" } {
      set sbh1 [ lindex $infos(rgbcuts) 0 ]
      set sbh2 [ lindex $infos(rgbcuts) 1 ]
      set sbh3 [ lindex $infos(rgbcuts) 2 ]
      set mini [ $zone(sh3) cget -from ]
      set maxi [ $zone(sh3) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      set sbh3 [ list $s [ lindex $sbh3 1 ] ]
      set infos(rgbcuts) [ list $sbh1 $sbh2 $sbh3 ]
      set seuils_rgb [ visu1000 cut ]
      visu1000 cut [ lreplace $seuils_rgb 4 4 $s ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      set sbh [ visu1000 cut ]
      set mini [ $zone(sh3) cget -from ]
      set maxi [ $zone(sh3) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      visu1000 cut [ list $s [ lindex $sbh 1 ] ]
   }
}

#
# Nouvelle valeur de seuil bas
#
proc testchangeLoCut1 { foo } {
   global zone
   global infos

   if { $infos(type_image) == "couleur" } {
      set sbh1 [ lindex $infos(rgbcuts) 0 ]
      set sbh2 [ lindex $infos(rgbcuts) 1 ]
      set sbh3 [ lindex $infos(rgbcuts) 2 ]
      set mini [ $zone(sb1) cget -from ]
      set maxi [ $zone(sb1) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      set sbh1 [ list [ lindex $sbh1 0 ] $s ]
      set infos(rgbcuts) [ list $sbh1 $sbh2 $sbh3 ]
      set seuils_rgb [ visu1000 cut ]
      visu1000 cut [ lreplace $seuils_rgb 1 1 $s ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      set sbh [ visu1000 cut ]
      set mini [ $zone(sb1) cget -from ]
      set maxi [ $zone(sb1) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      visu1000 cut [ list [ lindex $sbh 0 ] $s ]
   }
}

proc testchangeLoCut2 { foo } {
   global zone
   global infos

   if { $infos(type_image) == "couleur" } {
      set sbh1 [ lindex $infos(rgbcuts) 0 ]
      set sbh2 [ lindex $infos(rgbcuts) 1 ]
      set sbh3 [ lindex $infos(rgbcuts) 2 ]
      set mini [ $zone(sb2) cget -from ]
      set maxi [ $zone(sb2) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      set sbh2 [ list [ lindex $sbh2 0 ] $s ]
      set infos(rgbcuts) [ list $sbh1 $sbh2 $sbh3 ]
      set seuils_rgb [ visu1000 cut ]
      visu1000 cut [ lreplace $seuils_rgb 3 3 $s ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      set sbh [ visu1000 cut ]
      set mini [ $zone(sb2) cget -from ]
      set maxi [ $zone(sb2) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      visu1000 cut [ list [ lindex $sbh 0 ] $s ]
   }
}

proc testchangeLoCut3 { foo } {
   global zone
   global infos

   if { $infos(type_image) == "couleur" } {
      set sbh1 [ lindex $infos(rgbcuts) 0 ]
      set sbh2 [ lindex $infos(rgbcuts) 1 ]
      set sbh3 [ lindex $infos(rgbcuts) 2 ]
      set mini [ $zone(sb3) cget -from ]
      set maxi [ $zone(sb3) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      set sbh3 [ list [ lindex $sbh3 0 ] $s ]
      set infos(rgbcuts) [ list $sbh1 $sbh2 $sbh3 ]
      set seuils_rgb [ visu1000 cut ]
      visu1000 cut [ lreplace $seuils_rgb 5 5 $s ]
   } elseif { $infos(type_image) == "noiretblanc" } {
      set sbh [ visu1000 cut ]
      set mini [ $zone(sb3) cget -from ]
      set maxi [ $zone(sb3) cget -to ]
      set s [ expr 1.*($foo-$mini)/($maxi-$mini) ]
      set s [ expr (1.-$s)*($maxi-$mini)+$mini ]
      visu1000 cut [ list [ lindex $sbh 0 ] $s ]
   }
}

#
# Les coordonnees coord sont des coordonnees canvas et non ecran
#
proc testboxBegin { coord } {
   global infos

   catch { unset infos(box) }
   set infos(box,1) [ testscreen2Canvas $coord ]
}

#
# Les coordonnees x et y sont des coordonnees canvas et non ecran
#
proc testboxDrag { coord } {
   global audace
   global infos
   global zone

   catch { $zone(image1) delete $infos(hBox) }
   set x [ lindex $coord 0 ]
   if { $x < "0" } { set coord [ lreplace $coord 0 0 0 ] }
   if { $x >= $zone(image1,naxis1) } {
      set coord [ lreplace $coord 0 0 [ expr $zone(image1,naxis1)-1 ] ]
   }
   set y [ lindex $coord 1 ]
   if { $y < "0" } { set coord [ lreplace $coord 1 1 0 ] }
   if { $y >= $zone(image1,naxis2) } {
      set coord [ lreplace $coord 1 1 [ expr $zone(image1,naxis2)-1 ] ]
   }
   set infos(box,2) [ testscreen2Canvas $coord ]
   set infos(hBox) [ eval {$zone(image1) create rect} $infos(box,1) $infos(box,2) \
      -outline $audace(color,drag_rectangle) -tag selBox ]
}

#
# Les coordonnees x et y sont des coordonnees canvas et non ecran
#
proc testboxEnd { coord } {
   global infos
   global zone

   testboxDrag $coord
   if { $infos(box,1) == $infos(box,2) } {
      catch { unset infos(box) }
      $zone(image1) delete $infos(hBox)
   } else {
      set coord1 [ testcanvas2Picture $infos(box,1) ]
      set coord2 [ testcanvas2Picture $infos(box,2) ]
      set x1 [ lindex $coord1 0 ]
      set y1 [ lindex $coord1 1 ]
      set x2 [ lindex $coord2 0 ]
      set y2 [ lindex $coord2 1 ]
      if { $x1 > $x2 } {
         set a $x1
         set x1 $x2
         set x2 $a
      }
      if { $y1 > $y2 } {
         set a $y1
         set y1 $y2
         set y2 $a
      }
      catch { unset infos(box) }
      set infos(box) [ list $x1 $y1 $x2 $y2 ]
   }
}

#
# Transforme des coordonnees ecran en coordonnees canvas. L'argument est une
# liste de deux entiers, et retourne également une liste de deux entiers
#
proc testscreen2Canvas { coord } {
   global zone

   scan [$zone(image1) canvasx [lindex $coord 0]] "%d" xx
   scan [$zone(image1) canvasy [lindex $coord 1]] "%d" yy
   return [ list $xx $yy ]
}

#
# Transforme des coordonnees canvas en coordonnees image. L'argument est une
# liste de deux entiers, et retourne également une liste de deux entiers
#
proc testcanvas2Picture { coord } {
   global zone

   set xx [ expr [ lindex $coord 0 ] + 1 ]
   set point [ string first . $xx ]
   if { $point != "-1" } {
      set xx [ string range $xx 0 [ incr point -1 ] ]
   }
   set yy [ expr $zone(image1,naxis2) - [ lindex $coord 1 ] ]
   set point [ string first . $yy ]
   if { $point != "-1" } {
      set yy [ string range $yy 0 [ incr point -1 ] ]
   }
   return [ list $xx $yy ]
}

proc testjpeg { } {
   global audace
   global caption
   global infos

   #--- Fenetre parent
   set fenetre "$audace(base).test"
   #--- Buffer couleur
   set n_buffer_couleur "1000"
   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_save $fenetre $infos(dir) $n_buffer_couleur "2" ]
   if { $filename != "" } {
      catch { set infos(dir) [ file dirname $filename ] }
      if { $infos(dir) == "" } {
         set infos(dir) "./"
      } else {
         append infos(dir) "/"
      }
      if { $infos(type_image) == "couleur" } {
         buf1000 save [ file join $infos(dir) rgbdummy ]
         for { set k 1 } { $k <= 3 } { incr k } {
            set kk [ expr $k-1 ]
            buf1001 load3d "[ file join $infos(dir) rgbdummy ][ buf1000 extension ]" $k
            set hi [ buf1001 getkwd MIPS-HI ]
            buf1001 setkwd [ lreplace $hi 1 1 [ lindex [ lindex $infos(rgbcuts) $kk ] 0 ] ]
            set lo [ buf1001 getkwd MIPS-LO ]
            buf1001 setkwd [ lreplace $lo 1 1 [ lindex [ lindex $infos(rgbcuts) $kk ] 1 ] ]
            buf1001 setkwd [ list NAXIS 2 int {} {} ]
            buf1001 save [ file join $infos(dir) rgbdummy$k ]
         }
         fits2colorjpeg "[ file join $infos(dir) rgbdummy1 ][ buf1001 extension ]" "[ file join $infos(dir) rgbdummy2 ][ buf1001 extension ]" "[ file join $infos(dir) rgbdummy3 ][ buf1001 extension ]" $filename 80
         catch { file delete [ file join $infos(dir) rgbdummy ][ buf1000 extension ] }
         catch { file delete [ file join $infos(dir) rgbdummy1 ][ buf1001 extension ] }
         catch { file delete [ file join $infos(dir) rgbdummy2 ][ buf1001 extension ] }
         catch { file delete [ file join $infos(dir) rgbdummy3 ][ buf1001 extension ] }
      } elseif { $infos(type_image) == "noiretblanc" } {
         buf1000 sauve_jpeg $filename
      }
   }
}

proc header_color { } {
   global audace
   global caption
   global color

   if [winfo exists $audace(base).header_color] {
      destroy $audace(base).header_color
   }
   toplevel $audace(base).header_color
   wm transient $audace(base).header_color $audace(base).test
   if { [ buf1000 imageready ] == "1" } {
      wm minsize $audace(base).header_color 632 380
   }
   wm resizable $audace(base).header_color 1 1
   if { [ buf1000 imageready ] == "1" } {
      set rgbfiltr [ string trimright [ lindex [ buf1000 getkwd RGBFILTR ] 1 ] " " ]
   } else {
      set rgbfiltr ""
   }
   if { $rgbfiltr == "B" } {
      wm title $audace(base).header_color "$caption(acqcolor,entete_fits_B)"
   } elseif { $rgbfiltr == "G" } {
      wm title $audace(base).header_color "$caption(acqcolor,entete_fits_V)"
   } elseif { $rgbfiltr == "R" } {
      wm title $audace(base).header_color "$caption(acqcolor,entete_fits_R)"
   } else {
      wm title $audace(base).header_color "$caption(acqcolor,entete_fits)"
   }
   wm geometry $audace(base).header_color 632x380+3+75

   Scrolled_Text $audace(base).header_color.slb -width 150 -height 20
   pack $audace(base).header_color.slb -fill y -expand true

   if { [ buf1000 imageready ] == "1" } {
      $audace(base).header_color.slb.list tag configure keyw -foreground $color(blue)
      $audace(base).header_color.slb.list tag configure egal -foreground $color(black)
      $audace(base).header_color.slb.list tag configure valu -foreground $color(red)
      $audace(base).header_color.slb.list tag configure comm -foreground $color(green1)
      $audace(base).header_color.slb.list tag configure unit -foreground $color(orange)
      foreach kwd [lsort -dictionary [buf1000 getkwds]] {
         set liste [buf1000 getkwd $kwd]
         set koff 0
         if {[llength $liste]>5} {
            #--- Detourne un bug eventuel des mots longs (ne devrait jamais arriver !)
            set koff [expr [llength $liste]-5]
         }
         set keyword "$kwd"
         if {[string length $keyword]<=8} {
            set keyword "[format "%8s" $keyword]"
         }
         $audace(base).header_color.slb.list insert end "$keyword " keyw
         $audace(base).header_color.slb.list insert end "= " egal
         $audace(base).header_color.slb.list insert end "[lindex $liste [expr $koff+1]] " valu
         $audace(base).header_color.slb.list insert end "[lindex $liste [expr $koff+3]] " comm
         $audace(base).header_color.slb.list insert end "[lindex $liste [expr $koff+4]]\n" unit
      }
   } else {
      $audace(base).header_color.slb.list insert end "$caption(acqcolor,entete_fits_noimage)"
   }

   #--- La nouvelle fenetre est active
   focus $audace(base).header_color

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).header_color
}

proc color_nb_fenetre { } {
   global audace
   global conf
   global zone

   #--- Choix du nombre et des formats des fenetres scrollables
   if { $conf(color_nb_fenetre) == "0" } {
      set dimx1 1000
      set dimy1 515
   } elseif { $conf(color_nb_fenetre) == "1" } {
      set dimx1 500
      set dimy1 515
   } elseif { $conf(color_nb_fenetre) == "2" } {
      set dimx1 769
      set dimy1 515
   }
   #--- Configuration des canvas scrollables
   $zone(image1) configure -width $dimx1 -height $dimy1 -scrollregion {0 0 0 0} -cursor crosshair
   $zone(image2) configure -width $dimx1 -height $dimy1 -scrollregion {0 0 0 0} -cursor crosshair
   #--- Ajuste les scrollbars
   if { [ buf1000 imageready ] == "1" } {
      set zone(image1,naxis1) [ lindex [buf1000 getkwd NAXIS1] 1 ]
      set zone(image1,naxis2) [ lindex [buf1000 getkwd NAXIS2] 1 ]
      $zone(image1) configure -scrollregion [ list 0 0 $zone(image1,naxis1) $zone(image1,naxis2) ]
   }
   if { [ buf1000 imageready ] == "1" } {
      set zone(image2,naxis1) [ lindex [buf1000 getkwd NAXIS1] 1 ]
      set zone(image2,naxis2) [ lindex [buf1000 getkwd NAXIS2] 1 ]
      $zone(image2) configure -scrollregion [ list 0 0 $zone(image2,naxis1) $zone(image2,naxis2) ]
   }
}

