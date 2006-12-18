
########################################################################
# Boîte graphique de saisie des paramètres pour la metafonction spc_traite2calibre
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 14-08-2006
# Utilisée par : spc_traitecalibre (meta)
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################


namespace eval ::param_spc_audace_traite2calibre {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      set liste_methreg [ list "spc" "reg" "none" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "o" "n" ]
      set liste_smooth [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_traite2calibre.* ] ] != "0" } {
         destroy .param_spc_audace_traite2calibre
      }

      # === Initialisation des variables qui seront changées
      set audace(param_spc_audace,traite2calibre,config,offset) "none"
      set audace(param_spc_audace,traite2calibre,config,methreg) "spc"
      set audace(param_spc_audace,traite2calibre,config,methsel) "large"
      set audace(param_spc_audace,traite2calibre,config,methsky) "med"
      set audace(param_spc_audace,traite2calibre,config,methbin) "rober"
      set audace(param_spc_audace,traite2calibre,config,methinv) "n"
      set audace(param_spc_audace,traite2calibre,config,methcos) "o"
      set audace(param_spc_audace,traite2calibre,config,smooth) "n"
      set audace(param_spc_audace,traite2calibre,config,norma) "n"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,traite2calibre,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traite2calibre,color,backpad) #ECE9D8
      set audace(param_spc_audace,traite2calibre,color,backdisp) $color(white)
      set audace(param_spc_audace,traite2calibre,color,textdisp) #FF0000
      set audace(param_spc_audace,traite2calibre,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,traite2calibre,font,c10b) [ list {Arial} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,traite2calibre,titre2) "Traitement -> calibration"
      set caption(param_spc_audace,traite2calibre,titre) "Réduction de spectres"
      set caption(param_spc_audace,traite2calibre,stop_button) "Annuler"
      set caption(param_spc_audace,traite2calibre,return_button) "OK"
      set caption(param_spc_audace,traite2calibre,config,brut) "Nom générique des spectres bruts"
      set caption(param_spc_audace,traite2calibre,config,noir) "Nom générique des noirs"
      set caption(param_spc_audace,traite2calibre,config,plu) "Nom générique des plu(s)"
      set caption(param_spc_audace,traite2calibre,config,noirplu) "Nom générique des noirs de plu"
      set caption(param_spc_audace,traite2calibre,config,offset) "Nom générique des offset(s)"
      set caption(param_spc_audace,traite2calibre,config,lampe) "Spectre de lampe de calibration"
      set caption(param_spc_audace,traite2calibre,config,methreg) "Méthode d'appariement"
      set caption(param_spc_audace,traite2calibre,config,methcos) "Retrait des cosmics (o/n)"
      set caption(param_spc_audace,traite2calibre,config,methsel) "Méthode de détection du spectre"
      set caption(param_spc_audace,traite2calibre,config,methsky) "Méthode de soustraction du fond de ciel"
      set caption(param_spc_audace,traite2calibre,config,methbin) "Méthode de binning des colonnes"
      set caption(param_spc_audace,traite2calibre,config,methinv) "Inversion gauche-droite des profils de raies (o/n)"
      set caption(param_spc_audace,traite2calibre,config,smooth) "Adoucissement (o/n)"
      
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_traite2calibre de niveau le plus haut
      toplevel .param_spc_audace_traite2calibre -class Toplevel -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      wm geometry .param_spc_audace_traite2calibre 450x285+30+30
      wm resizable .param_spc_audace_traite2calibre 1 1
      wm title .param_spc_audace_traite2calibre $caption(param_spc_audace,traite2calibre,titre)
      wm protocol .param_spc_audace_traite2calibre WM_DELETE_WINDOW "::param_spc_audace_traite2calibre::annuler"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traite2calibre.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,traite2calibre,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey)
      pack .param_spc_audace_traite2calibre.title \
	      -in .param_spc_audace_traite2calibre -fill x -side top -pady 15
      
      # --- Boutons du bas
      frame .param_spc_audace_traite2calibre.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_traite2calibre.stop_button  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,stop_button)" \
	      -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) \
	      -command {::param_spc_audace_traite2calibre::annuler}
      pack  .param_spc_audace_traite2calibre.stop_button -in .param_spc_audace_traite2calibre.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_traite2calibre.return_button  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,return_button)" \
	      -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) \
	      -command {::param_spc_audace_traite2calibre::go}
      pack  .param_spc_audace_traite2calibre.return_button -in .param_spc_audace_traite2calibre.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_traite2calibre.buttons -in .param_spc_audace_traite2calibre -fill x -pady 0 -padx 0 -anchor s -side bottom

      
      #--- Label + Entry pour brut
      frame .param_spc_audace_traite2calibre.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.brut.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,brut) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.brut.label -in .param_spc_audace_traite2calibre.brut -side left -fill none
      entry  .param_spc_audace_traite2calibre.brut.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,brut) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.brut.entry -in .param_spc_audace_traite2calibre.brut -side left -fill none
      pack .param_spc_audace_traite2calibre.brut -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_traite2calibre.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.noir.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,noir) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.noir.label -in .param_spc_audace_traite2calibre.noir -side left -fill none
      entry  .param_spc_audace_traite2calibre.noir.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,noir) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.noir.entry -in .param_spc_audace_traite2calibre.noir -side left -fill none
      pack .param_spc_audace_traite2calibre.noir -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour plu
      frame .param_spc_audace_traite2calibre.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.plu.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,plu) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.plu.label -in .param_spc_audace_traite2calibre.plu -side left -fill none
      entry  .param_spc_audace_traite2calibre.plu.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,plu) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.plu.entry -in .param_spc_audace_traite2calibre.plu -side left -fill none
      pack .param_spc_audace_traite2calibre.plu -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traite2calibre.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.noirplu.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,noirplu) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.noirplu.label -in .param_spc_audace_traite2calibre.noirplu -side left -fill none
      entry  .param_spc_audace_traite2calibre.noirplu.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,noirplu) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.noirplu.entry -in .param_spc_audace_traite2calibre.noirplu -side left -fill none
      pack .param_spc_audace_traite2calibre.noirplu -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      frame .param_spc_audace_traite2calibre.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.offset.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,offset) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.offset.label -in .param_spc_audace_traite2calibre.offset -side left -fill none
      entry  .param_spc_audace_traite2calibre.offset.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,offset) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.offset.entry -in .param_spc_audace_traite2calibre.offset -side left -fill none
      pack .param_spc_audace_traite2calibre.offset -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour lampe
      frame .param_spc_audace_traite2calibre.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.lampe.label -text "$caption(param_spc_audace,traite2calibre,config,lampe)" -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b)
      pack  .param_spc_audace_traite2calibre.lampe.label -in .param_spc_audace_traite2calibre.lampe -side left -fill none
      button .param_spc_audace_traite2calibre.lampe.explore -text "$caption(script,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -command { set audace(param_spc_audace,traite2calibre,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traite2calibre.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2calibre.lampe.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,lampe) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.lampe.entry -in .param_spc_audace_traite2calibre.lampe -side left -fill none
      pack .param_spc_audace_traite2calibre.lampe -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12

      
      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methreg.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methreg) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methreg.label -in .param_spc_audace_traite2calibre.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_traite2calibre.methreg.combobox -in .param_spc_audace_traite2calibre.methreg -side right -fill none
      pack .param_spc_audace_traite2calibre.methreg -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methcos.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methcos) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methcos.label -in .param_spc_audace_traite2calibre.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_traite2calibre.methcos.combobox -in .param_spc_audace_traite2calibre.methcos -side right -fill none
      pack .param_spc_audace_traite2calibre.methcos -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12

      
      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methsel.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methsel) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methsel.label -in .param_spc_audace_traite2calibre.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_traite2calibre.methsel.combobox -in .param_spc_audace_traite2calibre.methsel -side right -fill none
      pack .param_spc_audace_traite2calibre.methsel -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12

      
      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methsky.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methsky) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methsky.label -in .param_spc_audace_traite2calibre.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_traite2calibre.methsky.combobox -in .param_spc_audace_traite2calibre.methsky -side right -fill none
      pack .param_spc_audace_traite2calibre.methsky -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12

      
      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methbin.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methbin) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methbin.label -in .param_spc_audace_traite2calibre.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_traite2calibre.methbin.combobox -in .param_spc_audace_traite2calibre.methbin -side right -fill none
      pack .param_spc_audace_traite2calibre.methbin -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methinv.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methinv) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methinv.label -in .param_spc_audace_traite2calibre.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_traite2calibre.methinv.combobox -in .param_spc_audace_traite2calibre.methinv -side right -fill none
      pack .param_spc_audace_traite2calibre.methinv -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_traite2calibre.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.smooth.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,smooth) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.smooth.label -in .param_spc_audace_traite2calibre.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2calibre.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2calibre,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_traite2calibre.smooth.combobox -in .param_spc_audace_traite2calibre.smooth -side right -fill none
      pack .param_spc_audace_traite2calibre.smooth -in .param_spc_audace_traite2calibre -fill x -pady 1 -padx 12

  }
  
  
  proc go {} {
      global audace
      global caption

      ::param_spc_audace_traite2calibre::recup_conf
      set brut $audace(param_spc_audace,traite2calibre,config,brut)
      set noir $audace(param_spc_audace,traite2calibre,config,noir)
      set plu $audace(param_spc_audace,traite2calibre,config,plu)
      set noirplu $audace(param_spc_audace,traite2calibre,config,noirplu)
      set offset $audace(param_spc_audace,traite2calibre,config,offset)
      set lampe $audace(param_spc_audace,traite2calibre,config,lampe)
      set methreg $audace(param_spc_audace,traite2calibre,config,methreg)
      set methcos $audace(param_spc_audace,traite2calibre,config,methcos)
      set methsel $audace(param_spc_audace,traite2calibre,config,methsel)
      set methsky $audace(param_spc_audace,traite2calibre,config,methsky)
      set methbin $audace(param_spc_audace,traite2calibre,config,methbin)
      set methinv $audace(param_spc_audace,traite2calibre,config,methinv)
      set smooth $audace(param_spc_audace,traite2calibre,config,smooth)
      set listeargs [ list $brut $noir $plu $noirplu $offset $lampe $methreg $methcos $methsel $methsky $methbin $methinv $smooth ]

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set fileout [ spc_traite2calibre $brut $noir $plu $noirplu $offset $lampe $methreg $methcos $methsel $methsky $methinv $methbin $smooth ]
	  destroy .param_spc_audace_traite2calibre
	  return $fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_traite2calibre::recup_conf
      destroy .param_spc_audace_traite2calibre
  }


  proc recup_conf {} {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_traite2calibre ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_traite2calibre]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }

  
}
#****************************************************************************#



###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  14-07-2006
# Date de mise à jour : 14-07-2006
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_étoile_référence profil_étoile_catalogue méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)
###############################################################################

proc spc_traite2rinstrum { args } {

   global audace
   global conf

   if { [llength $args] == 16 } {
       set img [ lindex $args 0 ]
       set dark [ lindex $args 1 ]
       set flat [ lindex $args 2 ]
       set dflat [ lindex $args 3 ]
       set offset [ lindex $args 4 ]
       set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
       set etoile_ref [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set etoile_cat [ lindex $args 7 ]
       set methreg [ lindex $args 8 ]
       set methcos [ lindex $args 9 ]
       set methsel [ lindex $args 10 ]
       set methsky [ lindex $args 11 ]
       set methinv [ lindex $args 12 ]
       set methbin [ lindex $args 13 ]
       set methnorma [ lindex $args 14 ]
       set methsmo [ lindex $args 15 ]

       #--- Eliminatoin des mauvaise images :
       ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
       spc_reject $img
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ bm_pretrait $img $dark $flat $dflat ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       set fsmilex [ spc_smilex2imgs $lampe $fpretrait ]
       delete2 $fpretrait $nbimg

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       set ftilt [ spc_tiltautoimgs $fsmilex ]
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   #-- Mirrorx du spectre prétraité :
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
	   #-- Mirrorx du spectre de la lampe de calibration :
	   buf$audace(bufNo) load "$audace(rep_images)/${lampe}_slx"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}_slx"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fsadd $methsky $methsel $methbin ]

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       spc_loadfit ${lampe}_slx
       loadima ${lampe}_slx
       #-- Boîte de dialogue pour saisir les paramètres de calibration :
       # tk.message "Selectionnez les corrdonnées x de cahque bords de 2 raies"
       # tk.boite1 xa1 xa2 xb1 xb2
       # tk.message "Donner la longueur d'onde et le type (a/e) des 2 raies"
       # tk.boite2 type1 lammbda1 type2 lambda2
       set err [ catch {
	   ::param_spc_audace_calibre2::run
	   tkwait window .param_spc_audace_calibre2
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       set audace(param_spc_audace,calibre2,config,xa1)
       set audace(param_spc_audace,calibre2,config,xa2)
       set audace(param_spc_audace,calibre2,config,xb1)
       set audace(param_spc_audace,calibre2,config,xb2)
       set audace(param_spc_audace,calibre2,config,type1)
       set audace(param_spc_audace,calibre2,config,type2)
       set audace(param_spc_audace,calibre2,config,lambda1)
       set audace(param_spc_audace,calibre2,config,lambda2)

       set xa1 $audace(param_spc_audace,calibre2,config,xa1)
       set xa2 $audace(param_spc_audace,calibre2,config,xa2)
       set xb1 $audace(param_spc_audace,calibre2,config,xb1)
       set xb2 $audace(param_spc_audace,calibre2,config,xb2)
       set type1 $audace(param_spc_audace,calibre2,config,type1)
       set type2 $audace(param_spc_audace,calibre2,config,type2)
       set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
       set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
       #-- Effectue la calibration du spectre 2D de la lampe spectrale : 
       set lampecalibree [ spc_calibre2sauto ${lampe}_slx $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]

       #--- Correction de la réponse intrumentale :
       ::console::affiche_resultat "\n\n**** Correction de la réponse intrumentale ****\n\n"
       file copy "$etoile_cat" "$audace(rep_images)"
       set fricorr [ spc_rinstrumcorr $fcal $etoile_ref $etoile_cat ]
       file rename -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${fcal}_ricorr$conf(extension,defaut)"
       set fricorr "${fcal}_ricorr"

       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsnorma\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_traite2rinstrum nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_étoile_référence profil_étoile_catalogue méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)\n\n"
   }
}
#**********************************************************************************#

