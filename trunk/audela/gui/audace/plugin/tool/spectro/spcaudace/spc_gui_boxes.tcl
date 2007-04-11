#*****************************************************************************#
#                                                                             #
# Boîtes graphiques TK de saisie des paramètres pour les focntoins Spcaudace  #
#                                                                             #
#*****************************************************************************#
# Chargement : source $audace(rep_scripts)/spcaudace/spc_gui_boxes.tcl



########################################################################
# Boîte graphique de saisie des paramètres pour la fonction spc_export2png
# Intitulé : Exportation au format PNG
#
# Auteurs : Benjamin Mauclaire
# Date de création : 05-03-2007
# Date de modification : 05-03-2007
# Utilisée par : spc_export2png
# Args : nom_profil_de_raies_fits 
########################################################################

namespace eval ::param_spc_audace_export2png {

   proc run { args {positionxy 20+20} } {
      global conf
      global audace spcaudace
      global captionspc
      global color

      set audace(param_spc_audace,export2png,config,spectre) [ lindex $args 0 ]
      #set spectre [ lindex $args 0 ]
      set lambdarange [ lindex $args 1 ]
      set ldeb [ lindex $lambdarange 0 ]
      set lfin [ lindex $lambdarange 1 ]
      set listevalmotsclef [ lindex $args 2 ]
      #-- Recupere et isole le premiere elelemnt quie est NOM_OBJET :
      #set len [ llength [
      #set listevalmots [ lrange


      if { [ string length [ info commands .param_spc_audace_export2png.* ] ] != "0" } {
         destroy .param_spc_audace_export2png
      }


      # === Initialisation des variables qui seront changées :
      set i 1
      foreach valmot $listevalmotsclef {
	  if { $valmot != "" } {
	      set valmot [ string trim $valmot " " ]
	      set audace(param_spc_audace,export2png,config,mot$i) $valmot
	  }
	  incr i
      }


      set audace(param_spc_audace,export2png,config,lambda_deb) $ldeb
      set audace(param_spc_audace,export2png,config,lambda_fin) $lfin
      set audace(param_spc_audace,export2png,config,ydeb) "*"
      set audace(param_spc_audace,export2png,config,yfin) "*"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,export2png,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,export2png,color,backpad) #ECE9D8
      set audace(param_spc_audace,export2png,color,backdisp) $color(white)
      set audace(param_spc_audace,export2png,color,textdisp) #FF0000
      set audace(param_spc_audace,export2png,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,export2png,font,c10b) [ list {Arial} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,export2png,titre2) "Création d'un graphique PNG\ndu profil de raies"
      set caption(param_spc_audace,export2png,titre) "Création d'un graphique PNG"
      set caption(param_spc_audace,export2png,stop_button) "Annuler"
      set caption(param_spc_audace,export2png,return_button) "OK"
      #set caption(param_spc_audace,export2png,config,spectre) "Nom du profil de la lampe de calibration"
      set caption(param_spc_audace,export2png,config,mot1) "Nom de l'objet"
      set caption(param_spc_audace,export2png,config,mot2) "Observateur(s)"
      set caption(param_spc_audace,export2png,config,mot3) "Nom de l'observatoire"
      set caption(param_spc_audace,export2png,config,mot4) "Télecscope"
      set caption(param_spc_audace,export2png,config,mot5) "Spectrographe"
      set caption(param_spc_audace,export2png,config,lambda_deb) "Longueur d'onde minimum"
      set caption(param_spc_audace,export2png,config,lambda_fin) "Longueur d'onde maximum"
      set caption(param_spc_audace,export2png,config,ydeb) "Intensité minimum"
      set caption(param_spc_audace,export2png,config,yfin) "Intensite maximum"
      
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_export2png de niveau le plus haut
      toplevel .param_spc_audace_export2png -class Toplevel -bg $audace(param_spc_audace,export2png,color,backpad)
      wm geometry .param_spc_audace_export2png 408x446+10+10
      wm resizable .param_spc_audace_export2png 1 1
      wm title .param_spc_audace_export2png $caption(param_spc_audace,export2png,titre)
      wm protocol .param_spc_audace_export2png WM_DELETE_WINDOW "::param_spc_audace_export2png::annuler"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_export2png.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,export2png,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey)
      pack .param_spc_audace_export2png.title \
	      -in .param_spc_audace_export2png -fill x -side top -pady 15
      
      # --- Boutons du bas
      frame .param_spc_audace_export2png.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,export2png,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_export2png.stop_button  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,stop_button)" \
	      -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) \
	      -command {::param_spc_audace_export2png::annuler}
      pack  .param_spc_audace_export2png.stop_button -in .param_spc_audace_export2png.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_export2png.return_button  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,return_button)" \
	      -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) \
	      -command {::param_spc_audace_export2png::go}
      pack  .param_spc_audace_export2png.return_button -in .param_spc_audace_export2png.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_export2png.buttons -in .param_spc_audace_export2png -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Message sur les caractères non autorisés :
      label .param_spc_audace_export2png.message1 \
	      -font [ list {Arial} 12 bold ] -text "Les caractères \", ' et accentués ne doivent pas\nêtre utilisés dans les champs." \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey)
      pack .param_spc_audace_export2png.message1 \
	      -in .param_spc_audace_export2png -fill x -side top -pady 15


       if { 1== 0 } {
      #--- Label + Entry pour spectre
      frame .param_spc_audace_export2png.spectre -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.spectre.label -text "$caption(param_spc_audace,export2png,config,spectre)" -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,export2png,font,c12b)
      pack  .param_spc_audace_export2png.spectre.label -in .param_spc_audace_export2png.spectre -side left -fill none
      button .param_spc_audace_export2png.spectre.explore -text "$captionspc(parcourir)" -width 1 \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -command { set audace(param_spc_audace,export2png,config,spectre) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_export2png.spectre.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_export2png.spectre.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,spectre) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 100
      pack  .param_spc_audace_export2png.spectre.entry -in .param_spc_audace_export2png.spectre -side left -fill none
      pack .param_spc_audace_export2png.spectre -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      
      #--- Label + Entry pour nom_objet
      frame .param_spc_audace_export2png.nom_objet -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.nom_objet.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,nom_objet) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.nom_objet.label -in .param_spc_audace_export2png.nom_objet -side left -fill none
      entry  .param_spc_audace_export2png.nom_objet.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,nom_objet) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.nom_objet.entry -in .param_spc_audace_export2png.nom_objet -side left -fill none
      pack .param_spc_audace_export2png.nom_objet -in .param_spc_audace_export2png -fill none -pady 1 -padx 12
      }

      #--- Label + Entry pour mot1
      frame .param_spc_audace_export2png.mot1 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot1.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,mot1) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot1.label -in .param_spc_audace_export2png.mot1 -side left -fill none
      entry  .param_spc_audace_export2png.mot1.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot1) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot1.entry -in .param_spc_audace_export2png.mot1 -side left -fill none
      pack .param_spc_audace_export2png.mot1 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour mot2
      frame .param_spc_audace_export2png.mot2 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot2.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,mot2) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot2.label -in .param_spc_audace_export2png.mot2 -side left -fill none
      entry  .param_spc_audace_export2png.mot2.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot2) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot2.entry -in .param_spc_audace_export2png.mot2 -side left -fill none
      pack .param_spc_audace_export2png.mot2 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour mot3
      frame .param_spc_audace_export2png.mot3 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot3.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,mot3) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot3.label -in .param_spc_audace_export2png.mot3 -side left -fill none
      entry  .param_spc_audace_export2png.mot3.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot3) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot3.entry -in .param_spc_audace_export2png.mot3 -side left -fill none
      pack .param_spc_audace_export2png.mot3 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12


      #--- Label + Entry pour mot4
      frame .param_spc_audace_export2png.mot4 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot4.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,mot4) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot4.label -in .param_spc_audace_export2png.mot4 -side left -fill none
      entry  .param_spc_audace_export2png.mot4.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot4) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot4.entry -in .param_spc_audace_export2png.mot4 -side left -fill none
      pack .param_spc_audace_export2png.mot4 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12


      #--- Label + Entry pour mot5
      frame .param_spc_audace_export2png.mot5 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot5.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,mot5) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot5.label -in .param_spc_audace_export2png.mot5 -side left -fill none
      entry  .param_spc_audace_export2png.mot5.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot5) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot5.entry -in .param_spc_audace_export2png.mot5 -side left -fill none
      pack .param_spc_audace_export2png.mot5 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12


      #--- Label + Entry pour lambda_deb
      frame .param_spc_audace_export2png.lambda_deb -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.lambda_deb.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,lambda_deb) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.lambda_deb.label -in .param_spc_audace_export2png.lambda_deb -side left -fill none
      entry  .param_spc_audace_export2png.lambda_deb.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,lambda_deb) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.lambda_deb.entry -in .param_spc_audace_export2png.lambda_deb -side left -fill none
      pack .param_spc_audace_export2png.lambda_deb -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour lambda_fin
      frame .param_spc_audace_export2png.lambda_fin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.lambda_fin.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,lambda_fin) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.lambda_fin.label -in .param_spc_audace_export2png.lambda_fin -side left -fill none
      entry  .param_spc_audace_export2png.lambda_fin.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,lambda_fin) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.lambda_fin.entry -in .param_spc_audace_export2png.lambda_fin -side left -fill none
      pack .param_spc_audace_export2png.lambda_fin -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour ydeb
      frame .param_spc_audace_export2png.ydeb -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.ydeb.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,ydeb) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.ydeb.label -in .param_spc_audace_export2png.ydeb -side left -fill none
      entry  .param_spc_audace_export2png.ydeb.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,ydeb) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.ydeb.entry -in .param_spc_audace_export2png.ydeb -side left -fill none
      pack .param_spc_audace_export2png.ydeb -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour yfin
      frame .param_spc_audace_export2png.yfin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.yfin.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(param_spc_audace,export2png,config,yfin) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.yfin.label -in .param_spc_audace_export2png.yfin -side left -fill none
      entry  .param_spc_audace_export2png.yfin.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,yfin) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.yfin.entry -in .param_spc_audace_export2png.yfin -side left -fill none
      pack .param_spc_audace_export2png.yfin -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

  }
  
  
  proc go {} {
      global audace spcaudace
      global caption
      global nomprofilpng

      ::param_spc_audace_export2png::recup_conf
      set spectre $audace(param_spc_audace,export2png,config,spectre)
      set nom_objet $audace(param_spc_audace,export2png,config,mot1)
      set mot2 $audace(param_spc_audace,export2png,config,mot2)
      set mot3 $audace(param_spc_audace,export2png,config,mot3)
      set mot4 $audace(param_spc_audace,export2png,config,mot4)
      set mot5 $audace(param_spc_audace,export2png,config,mot5)
      set lambda_deb $audace(param_spc_audace,export2png,config,lambda_deb)
      set lambda_fin $audace(param_spc_audace,export2png,config,lambda_fin)
      set ydeb $audace(param_spc_audace,export2png,config,ydeb)
      set yfin $audace(param_spc_audace,export2png,config,yfin)
      set listevalmots [ list $nom_objet $mot2 $mot3 $mot4 $mot5 ]

      #--- Mise à jour des mots clef et création du graphique :
      if { $nom_objet!="" && $mot2!="" && $mot3!="" && $mot4!="" && $mot5!="" && $lambda_deb!="" && $lambda_fin!="" && $ydeb!="" && $yfin!="" } {
	  #-- Mise à jour des mots clef :
	  buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	  foreach valmot $listevalmots mot $spcaudace(motsheader) def $spcaudace(motsheaderdef) {
	      buf$audace(bufNo) setkwd [ list "$mot" "$valmot" string "$def" "" ]
	  }
	  buf$audace(bufNo) bitpix float
	  buf$audace(bufNo) save "$audace(rep_images)/$spectre"
	  buf$audace(bufNo) bitpix short
	  set listeargs [ list $spectre $listevalmots ]

	  #-- Conversion en PNG : 
	  set nomprofilpng [ spc_autofit2png $spectre "$nom_objet" $lambda_deb $lambda_fin $ydeb $yfin ]
	  destroy .param_spc_audace_export2png
	  return $nomprofilpng
      } else {
	  tk_messageBox -title "Erreur de saisie" -icon error -message "Certains champ sont restés vides"
	  return 0
      }
  }

  proc annuler {} {
      global audace
      global caption
      global nomprofilpng

      ::param_spc_audace_export2png::recup_conf
      destroy .param_spc_audace_export2png
      set nomprofilpng ""
      return 0
  }


  proc recup_conf {} {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_export2png ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_export2png]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }

  
}
#****************************************************************************#
