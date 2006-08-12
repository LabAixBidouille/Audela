#*****************************************************************************#
#                                                                             #
# Boîtes graphiques TK de saisie des paramètres pour les focntoins Spcaudace  #
#                                                                             #
#*****************************************************************************#
# Chargement : source $audace(rep_scripts)/spcaudace/spc_gui_boxes.tcl



########################################################################
# Boîte graphique de saisie de s paramètres pour la calibration avec 2 raies
#
# Auteurs : Alain Klotz, Benjamin Mauclaire
# Date de création : 07-07-2006
# Date de modification : 07-07-2006
# Utilisée par : spc_*2calibre (spc_traite2calibre, spc_geom2calibre,...), spc_*2instrum
########################################################################

namespace eval ::param_spc_audace_calibre2 {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_calibre2.* ] ] != "0" } {
         destroy .param_spc_audace_calibre2
      }

      # === Initialisation des variables qui seront changées
      # set audace(param_spc_audace,calibre2,config,xa1) ""
      # set audace(param_spc_audace,calibre2,config,xa2) ""
      # set audace(param_spc_audace,calibre2,config,lambda1) ""
      # set audace(param_spc_audace,calibre2,config,type1) ""
      # set audace(param_spc_audace,calibre2,config,xb1) ""
      # set audace(param_spc_audace,calibre2,config,xb2) ""
      # set audace(param_spc_audace,calibre2,config,lambda2) ""
      # set audace(param_spc_audace,calibre2,config,type2) ""
      
      # === Variables d'environnement
      set audace(param_spc_audace,calibre2,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,calibre2,color,backpad) #F0F0FF
      set audace(param_spc_audace,calibre2,color,backdisp) $color(white)
      set audace(param_spc_audace,calibre2,color,textdisp) #FF0000
      set audace(param_spc_audace,calibre2,font,c12b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,calibre2,font,c10b) [ list {Courier} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,calibre2,titre2) "Paramètres des 2 raies"
      set caption(param_spc_audace,calibre2,titre) "Calibration avec 2 raies"
      set caption(param_spc_audace,calibre2,compute_button) "Calculer"
      set caption(param_spc_audace,calibre2,return_button) "OK"
      set caption(param_spc_audace,calibre2,config,xa1) "Raie 1 : x à gauche"
      set caption(param_spc_audace,calibre2,config,xa2) "Raie 1 : x à droite"
      set caption(param_spc_audace,calibre2,config,lambda1) "Raie 1 : lambda"
      set caption(param_spc_audace,calibre2,config,type1) "Raie 1 : type (e/a)"
      set caption(param_spc_audace,calibre2,config,xb1) "Raie 2 : x à gauche"
      set caption(param_spc_audace,calibre2,config,xb2) "Raie 2 : x à droite"
      set caption(param_spc_audace,calibre2,config,lambda2) "Raie 2 : lambda"
      set caption(param_spc_audace,calibre2,config,type2) "Raie 2 : type (e/a)"
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_calibre2 de niveau le plus haut
      toplevel .param_spc_audace_calibre2 -class Toplevel -bg $audace(param_spc_audace,calibre2,color,backpad)
      wm geometry .param_spc_audace_calibre2 300x330+30+30
      wm resizable .param_spc_audace_calibre2 0 0
      wm title .param_spc_audace_calibre2 $caption(param_spc_audace,calibre2,titre)
      wm protocol .param_spc_audace_calibre2 WM_DELETE_WINDOW "::param_spc_audace_calibre2::stop"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_calibre2.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,calibre2,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey)
      pack .param_spc_audace_calibre2.title \
	      -in .param_spc_audace_calibre2 -fill x -side top -pady 5
      
      # --- Boutons du bas
      frame .param_spc_audace_calibre2.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      button .param_spc_audace_calibre2.return_button  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,return_button)" \
	      -command {::param_spc_audace_calibre2::go}
      pack  .param_spc_audace_calibre2.return_button -in .param_spc_audace_calibre2.buttons -side left -fill none -padx 3
      pack .param_spc_audace_calibre2.buttons -in .param_spc_audace_calibre2 -fill x -pady 3 -padx 3 -anchor s -side bottom
      
      #--- Label + Entry pour xa1
      frame .param_spc_audace_calibre2.xa1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.xa1.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,xa1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.xa1.label -in .param_spc_audace_calibre2.xa1 -side left -fill none
      entry  .param_spc_audace_calibre2.xa1.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,xa1) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.xa1.entry -in .param_spc_audace_calibre2.xa1 -side left -fill none
      pack .param_spc_audace_calibre2.xa1 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour xa2
      frame .param_spc_audace_calibre2.xa2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.xa2.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,xa2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.xa2.label -in .param_spc_audace_calibre2.xa2 -side left -fill none
      entry  .param_spc_audace_calibre2.xa2.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,xa2) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.xa2.entry -in .param_spc_audace_calibre2.xa2 -side left -fill none
      pack .param_spc_audace_calibre2.xa2 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lambda1
      frame .param_spc_audace_calibre2.lambda1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.lambda1.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,lambda1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.lambda1.label -in .param_spc_audace_calibre2.lambda1 -side left -fill none
      entry  .param_spc_audace_calibre2.lambda1.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,lambda1) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.lambda1.entry -in .param_spc_audace_calibre2.lambda1 -side left -fill none
      pack .param_spc_audace_calibre2.lambda1 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour type1
      frame .param_spc_audace_calibre2.type1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.type1.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,type1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.type1.label -in .param_spc_audace_calibre2.type1 -side left -fill none
      entry  .param_spc_audace_calibre2.type1.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,type1) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.type1.entry -in .param_spc_audace_calibre2.type1 -side left -fill none
      pack .param_spc_audace_calibre2.type1 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour xb1
      frame .param_spc_audace_calibre2.xb1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.xb1.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,xb1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.xb1.label -in .param_spc_audace_calibre2.xb1 -side left -fill none
      entry  .param_spc_audace_calibre2.xb1.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,xb1) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.xb1.entry -in .param_spc_audace_calibre2.xb1 -side left -fill none
      pack .param_spc_audace_calibre2.xb1 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour xb2
      frame .param_spc_audace_calibre2.xb2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.xb2.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,xb2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.xb2.label -in .param_spc_audace_calibre2.xb2 -side left -fill none
      entry  .param_spc_audace_calibre2.xb2.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,xb2) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.xb2.entry -in .param_spc_audace_calibre2.xb2 -side left -fill none
      pack .param_spc_audace_calibre2.xb2 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lambda2
      frame .param_spc_audace_calibre2.lambda2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.lambda2.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,lambda2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.lambda2.label -in .param_spc_audace_calibre2.lambda2 -side left -fill none
      entry  .param_spc_audace_calibre2.lambda2.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,lambda2) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.lambda2.entry -in .param_spc_audace_calibre2.lambda2 -side left -fill none
      pack .param_spc_audace_calibre2.lambda2 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour type2
      frame .param_spc_audace_calibre2.type2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.type2.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2,config,type2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2.type2.label -in .param_spc_audace_calibre2.type2 -side left -fill none
      entry  .param_spc_audace_calibre2.type2.entry  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2,config,type2) -bg $audace(param_spc_audace,calibre2,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2.type2.entry -in .param_spc_audace_calibre2.type2 -side left -fill none
      pack .param_spc_audace_calibre2.type2 -in .param_spc_audace_calibre2 -fill none -pady 1 -padx 12
      
      
  }
  
  proc stop {  } {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_calibre2 ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_calibre2]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
      
      #--- Supprime la fenetre
      destroy .param_spc_audace_calibre2
      return
  }
  
  proc go {} {
      global audace
      global caption
      #::console::affiche_resultat "SPC_AUDACE Configuration : \n"
      #::console::affiche_resultat "$caption(param_spc_audace,calibre2,config,ra): $audace(param_spc_audace,calibre2,config,ra)\n"
      #::console::affiche_resultat "$caption(param_spc_audace,calibre2,config,dec): $audace(param_spc_audace,calibre2,config,dec)\n"
      ::param_spc_audace_calibre2::stop
  }
  
}

# Test de l'ihm a son lancement
set flag 0

if { $flag == 1 } {
    set err [ catch {
	::param_spc_audace_calibre2::run
    } msg ]
	if {$err==1} {
	    ::console::affiche_erreur "$msg\n"
	}
    }
    
#*******************************************************************************#
    
    

########################################################################
# Boîte graphique de saisie des paramètres pour la calibration avec 2 raies dedans
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_calibre2file (n'existe pas encore  : calibration avec 2 raies dans le profil)
########################################################################

namespace eval ::param_spc_audace_calibre2file {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_calibre2file.* ] ] != "0" } {
         destroy .param_spc_audace_calibre2file
      }

       # === Initialisation des variables qui seront changées
       # set audace(param_spc_audace,calibre2file,config,spectre) ""
       # set audace(param_spc_audace,calibre2file,config,xa1) ""
       # set audace(param_spc_audace,calibre2file,config,xa2) ""
       # set audace(param_spc_audace,calibre2file,config,lambda1) ""
       # set audace(param_spc_audace,calibre2file,config,type1) ""
       # set audace(param_spc_audace,calibre2file,config,xb1) ""
       # set audace(param_spc_audace,calibre2file,config,xb2) ""
       # set audace(param_spc_audace,calibre2file,config,lambda2) ""
       # set audace(param_spc_audace,calibre2file,config,type2) ""
       
       # === Variables d'environnement
       set audace(param_spc_audace,calibre2file,color,textkey) $color(blue_pad)
       set audace(param_spc_audace,calibre2file,color,backpad) #F0F0FF
       set audace(param_spc_audace,calibre2file,color,backdisp) $color(white)
       set audace(param_spc_audace,calibre2file,color,textdisp) #FF0000
       set audace(param_spc_audace,calibre2file,font,c12b) [ list {Courier} 10 bold ]
       set audace(param_spc_audace,calibre2file,font,c10b) [ list {Courier} 10 bold ]
       
       # === Captions
       set caption(param_spc_audace,calibre2file,titre2) "Calibration avec 2 raies"
       set caption(param_spc_audace,calibre2file,titre) "Calibration avec 2 raies"
       set caption(param_spc_audace,calibre2file,compute_button) "Calculer"
       set caption(param_spc_audace,calibre2file,return_button) "OK"
       set caption(param_spc_audace,calibre2file,config,spectre) "Spectre à calibrer"
       set caption(param_spc_audace,calibre2file,config,xa1) "Raie 1 : x à gauche"
       set caption(param_spc_audace,calibre2file,config,xa2) "Raie 1 : x à droite"
       set caption(param_spc_audace,calibre2file,config,lambda1) "Raie 1 : lambda"
       set caption(param_spc_audace,calibre2file,config,type1) "Raie 1 : type (e/a)"
       set caption(param_spc_audace,calibre2file,config,xb1) "Raie 2 : x à gauche"
       set caption(param_spc_audace,calibre2file,config,xb2) "Raie 2 : x à droite"
       set caption(param_spc_audace,calibre2file,config,lambda2) "Raie 2 : lambda"
       set caption(param_spc_audace,calibre2file,config,type2) "Raie 2 : type (e/a)"

      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_calibre2file de niveau le plus haut
      toplevel .param_spc_audace_calibre2file -class Toplevel -bg $audace(param_spc_audace,calibre2file,color,backpad)
      wm geometry .param_spc_audace_calibre2file 300x330+30+30
      wm resizable .param_spc_audace_calibre2file 0 0
      wm title .param_spc_audace_calibre2file $caption(param_spc_audace,calibre2file,titre)
      wm protocol .param_spc_audace_calibre2file WM_DELETE_WINDOW "::param_spc_audace_calibre2file::stop"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_calibre2file.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,calibre2file,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey)
      pack .param_spc_audace_calibre2file.title \
	      -in .param_spc_audace_calibre2file -fill x -side top -pady 5
      
      # --- Boutons du bas
      frame .param_spc_audace_calibre2file.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      button .param_spc_audace_calibre2file.return_button  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,return_button)" \
	      -command {::param_spc_audace_calibre2file::go}
      pack  .param_spc_audace_calibre2file.return_button -in .param_spc_audace_calibre2file.buttons -side left -fill none -padx 3
      pack .param_spc_audace_calibre2file.buttons -in .param_spc_audace_calibre2file -fill x -pady 3 -padx 3 -anchor s -side bottom
      
      #--- Label + Entry pour spectre
      frame .param_spc_audace_calibre2file.spectre -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.spectre.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,spectre) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.spectre.label -in .param_spc_audace_calibre2file.spectre -side left -fill none
      entry  .param_spc_audace_calibre2file.spectre.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,spectre) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.spectre.entry -in .param_spc_audace_calibre2file.spectre -side left -fill none
      pack .param_spc_audace_calibre2file.spectre -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      
      #--- Label + Entry pour xa1
      frame .param_spc_audace_calibre2file.xa1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.xa1.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,xa1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.xa1.label -in .param_spc_audace_calibre2file.xa1 -side left -fill none
      entry  .param_spc_audace_calibre2file.xa1.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,xa1) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.xa1.entry -in .param_spc_audace_calibre2file.xa1 -side left -fill none
      pack .param_spc_audace_calibre2file.xa1 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour xa2
      frame .param_spc_audace_calibre2file.xa2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.xa2.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,xa2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.xa2.label -in .param_spc_audace_calibre2file.xa2 -side left -fill none
      entry  .param_spc_audace_calibre2file.xa2.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,xa2) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.xa2.entry -in .param_spc_audace_calibre2file.xa2 -side left -fill none
      pack .param_spc_audace_calibre2file.xa2 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lambda1
      frame .param_spc_audace_calibre2file.lambda1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.lambda1.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,lambda1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.lambda1.label -in .param_spc_audace_calibre2file.lambda1 -side left -fill none
      entry  .param_spc_audace_calibre2file.lambda1.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,lambda1) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.lambda1.entry -in .param_spc_audace_calibre2file.lambda1 -side left -fill none
      pack .param_spc_audace_calibre2file.lambda1 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour type1
      frame .param_spc_audace_calibre2file.type1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.type1.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,type1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.type1.label -in .param_spc_audace_calibre2file.type1 -side left -fill none
      entry  .param_spc_audace_calibre2file.type1.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,type1) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.type1.entry -in .param_spc_audace_calibre2file.type1 -side left -fill none
      pack .param_spc_audace_calibre2file.type1 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour xb1
      frame .param_spc_audace_calibre2file.xb1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.xb1.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,xb1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.xb1.label -in .param_spc_audace_calibre2file.xb1 -side left -fill none
      entry  .param_spc_audace_calibre2file.xb1.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,xb1) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.xb1.entry -in .param_spc_audace_calibre2file.xb1 -side left -fill none
      pack .param_spc_audace_calibre2file.xb1 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour xb2
      frame .param_spc_audace_calibre2file.xb2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.xb2.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,xb2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.xb2.label -in .param_spc_audace_calibre2file.xb2 -side left -fill none
      entry  .param_spc_audace_calibre2file.xb2.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,xb2) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.xb2.entry -in .param_spc_audace_calibre2file.xb2 -side left -fill none
      pack .param_spc_audace_calibre2file.xb2 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lambda2
      frame .param_spc_audace_calibre2file.lambda2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.lambda2.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,lambda2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.lambda2.label -in .param_spc_audace_calibre2file.lambda2 -side left -fill none
      entry  .param_spc_audace_calibre2file.lambda2.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,lambda2) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.lambda2.entry -in .param_spc_audace_calibre2file.lambda2 -side left -fill none
      pack .param_spc_audace_calibre2file.lambda2 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour type2
      frame .param_spc_audace_calibre2file.type2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.type2.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(param_spc_audace,calibre2file,config,type2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey) -relief flat
      pack  .param_spc_audace_calibre2file.type2.label -in .param_spc_audace_calibre2file.type2 -side left -fill none
      entry  .param_spc_audace_calibre2file.type2.entry  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -textvariable audace(param_spc_audace,calibre2file,config,type2) -bg $audace(param_spc_audace,calibre2file,color,backdisp) \
	      -fg $audace(param_spc_audace,calibre2file,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_calibre2file.type2.entry -in .param_spc_audace_calibre2file.type2 -side left -fill none
      pack .param_spc_audace_calibre2file.type2 -in .param_spc_audace_calibre2file -fill none -pady 1 -padx 12
      
      
  }
  
  proc stop {  } {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_calibre2file ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_calibre2file]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
      
      #--- Supprime la fenetre
      destroy .param_spc_audace_calibre2file
      return
  }
  
  proc go {} {
      global audace
      global caption
      ::param_spc_audace_calibre2file::stop
  }
  
}
#*******************************************************************************#



########################################################################
# Boîte graphique de saisie des paramètres pour la calibration avec 2 raies dedans
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_calibre2loifile
########################################################################

namespace eval ::param_spc_audace_calibre2loifile {

   proc run { {positionxy 20+20} } {
       global conf
       global audace
       global caption
       global color
       
       if { [ string length [ info commands .param_spc_audace_calibre2loifile.* ] ] != "0" } {
	   destroy .param_spc_audace_calibre2loifile
       }
       
       # === Initialisation des variables qui seront changées
       # set audace(param_spc_audace,calibre2loifile,config,spectre) ""
       # set audace(param_spc_audace,calibre2loifile,config,lampe) ""
       
       # === Variables d'environnement
       set audace(param_spc_audace,calibre2loifile,color,textkey) $color(blue_pad)
       set audace(param_spc_audace,calibre2loifile,color,backpad) #F0F0FF
       set audace(param_spc_audace,calibre2loifile,color,backdisp) $color(white)
       set audace(param_spc_audace,calibre2loifile,color,textdisp) #FF0000
       set audace(param_spc_audace,calibre2loifile,font,c12b) [ list {Courier} 10 bold ]
       set audace(param_spc_audace,calibre2loifile,font,c10b) [ list {Courier} 10 bold ]
       
       # === Captions
       set caption(param_spc_audace,calibre2loifile,titre2) "Calibration avec une lampe"
       set caption(param_spc_audace,calibre2loifile,titre) "Calibration avec une lampe"
       set caption(param_spc_audace,calibre2loifile,compute_button) "Calculer"
       set caption(param_spc_audace,calibre2loifile,return_button) "OK"
       set caption(param_spc_audace,calibre2loifile,config,spectre) "Spectre à calibrer"
       set caption(param_spc_audace,calibre2loifile,config,lampe) "Lampe à calibrer"

       # === Met en place l'interface graphique
       
       #--- Cree la fenetre .param_spc_audace_calibre2loifile de niveau le plus haut
       toplevel .param_spc_audace_calibre2loifile -class Toplevel -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       wm geometry .param_spc_audace_calibre2loifile 300x330+30+30
       wm resizable .param_spc_audace_calibre2loifile 0 0
       wm title .param_spc_audace_calibre2loifile $caption(param_spc_audace,calibre2loifile,titre)
       wm protocol .param_spc_audace_calibre2loifile WM_DELETE_WINDOW "::param_spc_audace_calibre2loifile::stop"
       
       #--- Create the title
       #--- Cree le titre
       label .param_spc_audace_calibre2loifile.title \
	       -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,calibre2loifile,titre2) \
	       -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibre2loifile,color,backpad) \
	       -fg $audace(param_spc_audace,calibre2loifile,color,textkey)
       pack .param_spc_audace_calibre2loifile.title \
	       -in .param_spc_audace_calibre2loifile -fill x -side top -pady 5
       
       # --- Boutons du bas
       frame .param_spc_audace_calibre2loifile.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       button .param_spc_audace_calibre2loifile.return_button  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -text "$caption(param_spc_audace,calibre2loifile,return_button)" \
	       -command {::param_spc_audace_calibre2loifile::go}
       pack  .param_spc_audace_calibre2loifile.return_button -in .param_spc_audace_calibre2loifile.buttons -side left -fill none -padx 3
       pack .param_spc_audace_calibre2loifile.buttons -in .param_spc_audace_calibre2loifile -fill x -pady 3 -padx 3 -anchor s -side bottom
       
       #--- Label + Entry pour spectre
       frame .param_spc_audace_calibre2loifile.spectre -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       label .param_spc_audace_calibre2loifile.spectre.label  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -text "$caption(param_spc_audace,calibre2loifile,config,spectre) " -bg $audace(param_spc_audace,calibre2loifile,color,backpad) \
	       -fg $audace(param_spc_audace,calibre2loifile,color,textkey) -relief flat
       pack  .param_spc_audace_calibre2loifile.spectre.label -in .param_spc_audace_calibre2loifile.spectre -side left -fill none
       entry  .param_spc_audace_calibre2loifile.spectre.entry  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -textvariable audace(param_spc_audace,calibre2loifile,config,spectre) -bg $audace(param_spc_audace,calibre2loifile,color,backdisp) \
	       -fg $audace(param_spc_audace,calibre2loifile,color,textdisp) -relief flat -width 70
       pack  .param_spc_audace_calibre2loifile.spectre.entry -in .param_spc_audace_calibre2loifile.spectre -side left -fill none
       pack .param_spc_audace_calibre2loifile.spectre -in .param_spc_audace_calibre2loifile -fill none -pady 1 -padx 12
       
       #--- Label + Entry pour lampe
       frame .param_spc_audace_calibre2loifile.lampe -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       label .param_spc_audace_calibre2loifile.lampe.label  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -text "$caption(param_spc_audace,calibre2loifile,config,lampe) " -bg $audace(param_spc_audace,calibre2loifile,color,backpad) \
	       -fg $audace(param_spc_audace,calibre2loifile,color,textkey) -relief flat
       pack  .param_spc_audace_calibre2loifile.lampe.label -in .param_spc_audace_calibre2loifile.lampe -side left -fill none
       entry  .param_spc_audace_calibre2loifile.lampe.entry  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -textvariable audace(param_spc_audace,calibre2loifile,config,lampe) -bg $audace(param_spc_audace,calibre2loifile,color,backdisp) \
	       -fg $audace(param_spc_audace,calibre2loifile,color,textdisp) -relief flat -width 70
       pack  .param_spc_audace_calibre2loifile.lampe.entry -in .param_spc_audace_calibre2loifile.lampe -side left -fill none
       pack .param_spc_audace_calibre2loifile.lampe -in .param_spc_audace_calibre2loifile -fill none -pady 1 -padx 12
       
       
   }
   
   proc stop {  } {
       global conf
       global audace
       
       if { [ winfo exists .param_spc_audace_calibre2loifile ] } {
	   #--- Enregistre la position de la fenetre
	   set geom [wm geometry .param_spc_audace_calibre2loifile]
	   set deb [expr 1+[string first + $geom ]]
	   set fin [string length $geom]
	   set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
       }
       
       #--- Supprime la fenetre
       destroy .param_spc_audace_calibre2loifile
       return
   }
   
   proc go {} {
       global audace
       global caption
       ::param_spc_audace_calibre2loifile::stop
   }
   
}
#*******************************************************************************#



########################################################################
# Boîte graphique de saisie de s paramètres pour la metafonction spc_geom2calibre
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_geom2calibre
# Args : nom_generique_spectres_pretraites nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_geom2calibre {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_geom2calibre.* ] ] != "0" } {
         destroy .param_spc_audace_geom2calibre
      }

      # === Initialisation des variables qui seront changées
      # set audace(param_spc_audace,geom2calibre,config,spectres) ""
      # set audace(param_spc_audace,geom2calibre,config,lampe) ""
      # set audace(param_spc_audace,geom2calibre,config,etoile_ref) ""
      # set audace(param_spc_audace,geom2calibre,config,etoile_cat) ""
      # set audace(param_spc_audace,geom2calibre,config,methreg) ""
      # set audace(param_spc_audace,geom2calibre,config,methsel) ""
      # set audace(param_spc_audace,geom2calibre,config,methsky) ""
      # set audace(param_spc_audace,geom2calibre,config,methbin) ""
      # set audace(param_spc_audace,geom2calibre,config,norma) ""
      
      # === Variables d'environnement
      set audace(param_spc_audace,geom2calibre,color,textkey) $color(blue_pad)
      # #F0F0FF
      set audace(param_spc_audace,geom2calibre,color,backpad) #ECE9D8
      set audace(param_spc_audace,geom2calibre,color,backdisp) $color(white)
      set audace(param_spc_audace,geom2calibre,color,textdisp) #FF0000
      # set audace(param_spc_audace,geom2calibre,font,c12b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,geom2calibre,font,c12b) [ list {Arial} 10 bold ]
      # set audace(param_spc_audace,geom2calibre,font,c10b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,geom2calibre,font,c10b) [ list {Arial} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,geom2calibre,titre2) "Géométrie -> calibration"
      set caption(param_spc_audace,geom2calibre,titre) "Traitement de spectres"
      set caption(param_spc_audace,geom2calibre,stop_button) "Annuler"
      set caption(param_spc_audace,geom2calibre,return_button) "OK"
      set caption(param_spc_audace,geom2calibre,config,spectres) "Nom générique des spectres"
      set caption(param_spc_audace,geom2calibre,config,lampe) "Spectre de lampe de calibration"
      set caption(param_spc_audace,geom2calibre,config,etoile_ref) "Spectre d'étoile de référence"
      set caption(param_spc_audace,geom2calibre,config,etoile_cat) "Spectre d'étoile du catalogue"
      set caption(param_spc_audace,geom2calibre,config,methreg) "Méthode d'appariement (reg, spc)            "
      # set caption(param_spc_audace,geom2calibre,config,methsel) "Méthode de détection du spectre (large, serre)"
      set caption(param_spc_audace,geom2calibre,config,methsel) "Détection du spectre (large, serre)"
      # set caption(param_spc_audace,geom2calibre,config,methsky) "Méthode soustraction du fond de ciel (moy, moy2, med, inf, sup, back, none)"
      set caption(param_spc_audace,geom2calibre,config,methsky) "Méthode soustraction du fond de ciel"
      set caption(param_spc_audace,geom2calibre,config,methbin) "Méthode de binning (add, rober, horne)"
      set caption(param_spc_audace,geom2calibre,config,smooth) "Adoucissement (o/n)"
      
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_geom2calibre de niveau le plus haut
      toplevel .param_spc_audace_geom2calibre -class Toplevel -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      wm geometry .param_spc_audace_geom2calibre 450x330+30+30
      wm resizable .param_spc_audace_geom2calibre 0 0
      wm title .param_spc_audace_geom2calibre $caption(param_spc_audace,geom2calibre,titre)
      wm protocol .param_spc_audace_geom2calibre WM_DELETE_WINDOW "::param_spc_audace_geom2calibre::annuler"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_geom2calibre.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,geom2calibre,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey)
      pack .param_spc_audace_geom2calibre.title \
	      -in .param_spc_audace_geom2calibre -fill x -side top -pady 5
      
      # --- Boutons du bas
      frame .param_spc_audace_geom2calibre.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_geom2calibre.stop_button  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,stop_button)" \
	      -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) \
	      -command {::param_spc_audace_geom2calibre::annuler}
      pack  .param_spc_audace_geom2calibre.stop_button -in .param_spc_audace_geom2calibre.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_geom2calibre.return_button  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,return_button)" \
	      -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) \
	      -command {::param_spc_audace_geom2calibre::go}
      pack  .param_spc_audace_geom2calibre.return_button -in .param_spc_audace_geom2calibre.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_geom2calibre.buttons -in .param_spc_audace_geom2calibre -fill x -pady 0 -padx 0 -anchor s -side bottom

      
      #--- Label + Entry pour spectres
      frame .param_spc_audace_geom2calibre.spectres -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.spectres.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,spectres) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.spectres.label -in .param_spc_audace_geom2calibre.spectres -side left -fill none
      entry  .param_spc_audace_geom2calibre.spectres.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,spectres) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.spectres.entry -in .param_spc_audace_geom2calibre.spectres -side left -fill none
      pack .param_spc_audace_geom2calibre.spectres -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lampe
      frame .param_spc_audace_geom2calibre.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.lampe.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,lampe) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.lampe.label -in .param_spc_audace_geom2calibre.lampe -side left -fill none
      entry  .param_spc_audace_geom2calibre.lampe.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,lampe) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.lampe.entry -in .param_spc_audace_geom2calibre.lampe -side left -fill none
      pack .param_spc_audace_geom2calibre.lampe -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour etoile_ref
      frame .param_spc_audace_geom2calibre.etoile_ref -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.etoile_ref.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,etoile_ref) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.etoile_ref.label -in .param_spc_audace_geom2calibre.etoile_ref -side left -fill none
      entry  .param_spc_audace_geom2calibre.etoile_ref.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,etoile_ref) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.etoile_ref.entry -in .param_spc_audace_geom2calibre.etoile_ref -side left -fill none
      pack .param_spc_audace_geom2calibre.etoile_ref -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      
      #--- Label + Entry pour etoile_cat
      frame .param_spc_audace_geom2calibre.etoile_cat -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.etoile_cat.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,etoile_cat) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.etoile_cat.label -in .param_spc_audace_geom2calibre.etoile_cat -side left -fill none
      entry  .param_spc_audace_geom2calibre.etoile_cat.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,etoile_cat) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.etoile_cat.entry -in .param_spc_audace_geom2calibre.etoile_cat -side left -fill none
      pack .param_spc_audace_geom2calibre.etoile_cat -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methreg.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,methreg) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methreg.label -in .param_spc_audace_geom2calibre.methreg -side left -fill none
      #-- Partie Combobox
      set list_combobox [ list "spc" "reg" ]
      ComboBox .param_spc_audace_geom2calibre.methreg.combobox \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methreg) \
         -values $list_combobox
      pack  .param_spc_audace_geom2calibre.methreg.combobox -in .param_spc_audace_geom2calibre.methreg -side right -fill none
      pack .param_spc_audace_geom2calibre.methreg -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12

      
      #--- Label + Entry pour methsel
      frame .param_spc_audace_geom2calibre.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methsel.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,methsel) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methsel.label -in .param_spc_audace_geom2calibre.methsel -side left -fill none
      entry  .param_spc_audace_geom2calibre.methsel.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,methsel) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.methsel.entry -in .param_spc_audace_geom2calibre.methsel -side left -fill none
      pack .param_spc_audace_geom2calibre.methsel -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsky
      frame .param_spc_audace_geom2calibre.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methsky.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,methsky) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methsky.label -in .param_spc_audace_geom2calibre.methsky -side left -fill none
      entry  .param_spc_audace_geom2calibre.methsky.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,methsky) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.methsky.entry -in .param_spc_audace_geom2calibre.methsky -side left -fill none
      pack .param_spc_audace_geom2calibre.methsky -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methbin
      frame .param_spc_audace_geom2calibre.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methbin.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,methbin) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methbin.label -in .param_spc_audace_geom2calibre.methbin -side left -fill none
      entry  .param_spc_audace_geom2calibre.methbin.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,methbin) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.methbin.entry -in .param_spc_audace_geom2calibre.methbin -side left -fill none
      pack .param_spc_audace_geom2calibre.methbin -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour smooth
      frame .param_spc_audace_geom2calibre.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.smooth.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,geom2calibre,config,smooth) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.smooth.label -in .param_spc_audace_geom2calibre.smooth -side left -fill none
      entry  .param_spc_audace_geom2calibre.smooth.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,smooth) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.smooth.entry -in .param_spc_audace_geom2calibre.smooth -side left -fill none
      pack .param_spc_audace_geom2calibre.smooth -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12
      
      
  }
  
  proc recup_conf {  } {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_geom2calibre ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_geom2calibre]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }
  
  proc go {} {
      global audace
      global caption

      ::param_spc_audace_geom2calibre::recup_conf
      set spectres $audace(param_spc_audace,geom2calibre,config,spectres)
      set lampe $audace(param_spc_audace,geom2calibre,config,lampe)
      set etoile_ref $audace(param_spc_audace,geom2calibre,config,etoile_ref)
      set etoile_cat $audace(param_spc_audace,geom2calibre,config,etoile_cat)
      set methreg $audace(param_spc_audace,geom2calibre,config,methreg)
      set methsel $audace(param_spc_audace,geom2calibre,config,methsel)
      set methsky $audace(param_spc_audace,geom2calibre,config,methsky)
      set methbin $audace(param_spc_audace,geom2calibre,config,methbin)
      set smooth $audace(param_spc_audace,geom2calibre,config,smooth)

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { $spectres != "" && $lampe != "" } {
	  # set fileout [ spc_geom2calibre $spectres $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $smooth ]
	  ::console::affiche_resultat "$spectres, $lampe, $etoile_ref\n"
	  destroy .param_spc_audace_geom2calibre
	  return $fileout
	  #-- Sinon afficher message erreur :
      } else {
	  tk_messageBox -title "Erreur de saisie" -icon error -message "Tous les champs ne sont pas renseignés ou variables incompatibles"
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_geom2calibre::recup_conf
      destroy .param_spc_audace_geom2calibre
  }
  
}
#****************************************************************************#



########################################################################
# Boîte graphique de saisie de s paramètres pour la metafonction spc_geom2rinstrum
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_geom2rinstrum
# Args : nom_generique_spectres_pretraites nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_geom2rinstrum {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_geom2rinstrum.* ] ] != "0" } {
         destroy .param_spc_audace_geom2rinstrum
      }

      # === Initialisation des variables qui seront changées
      # set audace(param_spc_audace,geom2rinstrum,config,spectres) ""
      # set audace(param_spc_audace,geom2rinstrum,config,lampe) ""
      # set audace(param_spc_audace,geom2rinstrum,config,etoile_ref) ""
      # set audace(param_spc_audace,geom2rinstrum,config,etoile_cat) ""
      # set audace(param_spc_audace,geom2rinstrum,config,methreg) ""
      # set audace(param_spc_audace,geom2rinstrum,config,methsel) ""
      # set audace(param_spc_audace,geom2rinstrum,config,methsky) ""
      # set audace(param_spc_audace,geom2rinstrum,config,methbin) ""
      # set audace(param_spc_audace,geom2rinstrum,config,norma) ""
      
      # === Variables d'environnement
      set audace(param_spc_audace,geom2rinstrum,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,geom2rinstrum,color,backpad) #F0F0FF
      set audace(param_spc_audace,geom2rinstrum,color,backdisp) $color(white)
      set audace(param_spc_audace,geom2rinstrum,color,textdisp) #FF0000
      set audace(param_spc_audace,geom2rinstrum,font,c12b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,geom2rinstrum,font,c10b) [ list {Courier} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,geom2rinstrum,titre2) "Géométrie -> réponse intrumentale"
      set caption(param_spc_audace,geom2rinstrum,titre) "Traitement de spectres"
      set caption(param_spc_audace,geom2rinstrum,compute_button) "Calculer"
      set caption(param_spc_audace,geom2rinstrum,return_button) "OK"
      set caption(param_spc_audace,geom2rinstrum,config,spectres) "Nom générique des spectres"
      set caption(param_spc_audace,geom2rinstrum,config,lampe) "Spectre de lampe de calibration"
      set caption(param_spc_audace,geom2rinstrum,config,etoile_ref) "Spectre d'étoile de référence"
      set caption(param_spc_audace,geom2rinstrum,config,etoile_cat) "Spectre d'étoile du catalogue"
      set caption(param_spc_audace,geom2rinstrum,config,methreg) "Méthode d'appariement (reg, spc)"
      # set caption(param_spc_audace,geom2rinstrum,config,methsel) "Méthode de détection du spectre (large, serre)"
      set caption(param_spc_audace,geom2rinstrum,config,methsel) "Détection du spectre (large, serre)"
      # set caption(param_spc_audace,geom2rinstrum,config,methsky) "Méthode soustraction du fond de ciel (moy, moy2, med, inf, sup, back, none)"
      set caption(param_spc_audace,geom2rinstrum,config,methsky) "Méthode soustraction du fond de ciel"
      set caption(param_spc_audace,geom2rinstrum,config,methbin) "Méthode de binning (add, rober, horne)"
      set caption(param_spc_audace,geom2rinstrum,config,norma) "Normalisation (o/n)"
      
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_geom2rinstrum de niveau le plus haut
      toplevel .param_spc_audace_geom2rinstrum -class Toplevel -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      wm geometry .param_spc_audace_geom2rinstrum 450x370+30+30
      wm resizable .param_spc_audace_geom2rinstrum 0 0
      wm title .param_spc_audace_geom2rinstrum $caption(param_spc_audace,geom2rinstrum,titre)
      wm protocol .param_spc_audace_geom2rinstrum WM_DELETE_WINDOW "::param_spc_audace_geom2rinstrum::stop"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_geom2rinstrum.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,geom2rinstrum,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey)
      pack .param_spc_audace_geom2rinstrum.title \
	      -in .param_spc_audace_geom2rinstrum -fill x -side top -pady 5
      
      # --- Boutons du bas
      frame .param_spc_audace_geom2rinstrum.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      button .param_spc_audace_geom2rinstrum.return_button  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,return_button)" \
	      -command {::param_spc_audace_geom2rinstrum::go}
      pack  .param_spc_audace_geom2rinstrum.return_button -in .param_spc_audace_geom2rinstrum.buttons -side left -fill none -padx 3
      pack .param_spc_audace_geom2rinstrum.buttons -in .param_spc_audace_geom2rinstrum -fill x -pady 3 -padx 3 -anchor s -side bottom
      
      #--- Label + Entry pour spectres
      frame .param_spc_audace_geom2rinstrum.spectres -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.spectres.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,spectres) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.spectres.label -in .param_spc_audace_geom2rinstrum.spectres -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.spectres.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,spectres) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.spectres.entry -in .param_spc_audace_geom2rinstrum.spectres -side left -fill none
      pack .param_spc_audace_geom2rinstrum.spectres -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lampe
      frame .param_spc_audace_geom2rinstrum.lampe -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.lampe.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,lampe) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.lampe.label -in .param_spc_audace_geom2rinstrum.lampe -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.lampe.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,lampe) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.lampe.entry -in .param_spc_audace_geom2rinstrum.lampe -side left -fill none
      pack .param_spc_audace_geom2rinstrum.lampe -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour etoile_ref
      frame .param_spc_audace_geom2rinstrum.etoile_ref -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.etoile_ref.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,etoile_ref) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.etoile_ref.label -in .param_spc_audace_geom2rinstrum.etoile_ref -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.etoile_ref.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,etoile_ref) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.etoile_ref.entry -in .param_spc_audace_geom2rinstrum.etoile_ref -side left -fill none
      pack .param_spc_audace_geom2rinstrum.etoile_ref -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      
      #--- Label + Entry pour etoile_cat
      frame .param_spc_audace_geom2rinstrum.etoile_cat -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.etoile_cat.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,etoile_cat) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.etoile_cat.label -in .param_spc_audace_geom2rinstrum.etoile_cat -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.etoile_cat.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,etoile_cat) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.etoile_cat.entry -in .param_spc_audace_geom2rinstrum.etoile_cat -side left -fill none
      pack .param_spc_audace_geom2rinstrum.etoile_cat -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methreg
      frame .param_spc_audace_geom2rinstrum.methreg -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methreg.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,methreg) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methreg.label -in .param_spc_audace_geom2rinstrum.methreg -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.methreg.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,methreg) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.methreg.entry -in .param_spc_audace_geom2rinstrum.methreg -side left -fill none
      pack .param_spc_audace_geom2rinstrum.methreg -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsel
      frame .param_spc_audace_geom2rinstrum.methsel -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methsel.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,methsel) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methsel.label -in .param_spc_audace_geom2rinstrum.methsel -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.methsel.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,methsel) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.methsel.entry -in .param_spc_audace_geom2rinstrum.methsel -side left -fill none
      pack .param_spc_audace_geom2rinstrum.methsel -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsky
      frame .param_spc_audace_geom2rinstrum.methsky -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methsky.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,methsky) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methsky.label -in .param_spc_audace_geom2rinstrum.methsky -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.methsky.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,methsky) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.methsky.entry -in .param_spc_audace_geom2rinstrum.methsky -side left -fill none
      pack .param_spc_audace_geom2rinstrum.methsky -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methbin
      frame .param_spc_audace_geom2rinstrum.methbin -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methbin.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,methbin) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methbin.label -in .param_spc_audace_geom2rinstrum.methbin -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.methbin.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,methbin) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.methbin.entry -in .param_spc_audace_geom2rinstrum.methbin -side left -fill none
      pack .param_spc_audace_geom2rinstrum.methbin -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour norma
      frame .param_spc_audace_geom2rinstrum.norma -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.norma.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,geom2rinstrum,config,norma) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.norma.label -in .param_spc_audace_geom2rinstrum.norma -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.norma.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,norma) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.norma.entry -in .param_spc_audace_geom2rinstrum.norma -side left -fill none
      pack .param_spc_audace_geom2rinstrum.norma -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12
      
      
  }
  
  proc stop {  } {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_geom2rinstrum ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_geom2rinstrum]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
      
      #--- Supprime la fenetre
      destroy .param_spc_audace_geom2rinstrum
      return
  }
  
  proc go {} {
      global audace
      global caption
      ::param_spc_audace_geom2rinstrum::stop
  }
  
}
#****************************************************************************#



########################################################################
# Boîte graphique de saisie de s paramètres pour la metafonction spc_traite2calibre
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traitecalibre (meta)
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_traite2calibre {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_traite2calibre.* ] ] != "0" } {
         destroy .param_spc_audace_traite2calibre
      }

      # === Initialisation des variables qui seront changées
      # set audace(param_spc_audace,traite2calibre,config,brut) ""
      # set audace(param_spc_audace,traite2calibre,config,noir) ""
      # set audace(param_spc_audace,traite2calibre,config,plu) ""
      # set audace(param_spc_audace,traite2calibre,config,noirplu) ""
      # set audace(param_spc_audace,traite2calibre,config,lampe) ""
      # set audace(param_spc_audace,traite2calibre,config,methreg) ""
      # set audace(param_spc_audace,traite2calibre,config,methsel) ""
      # set audace(param_spc_audace,traite2calibre,config,methsky) ""
      # set audace(param_spc_audace,traite2calibre,config,methbin) ""
      # set audace(param_spc_audace,traite2calibre,config,smooth) ""
      
      # === Variables d'environnement
      set audace(param_spc_audace,traite2calibre,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traite2calibre,color,backpad) #F0F0FF
      set audace(param_spc_audace,traite2calibre,color,backdisp) $color(white)
      set audace(param_spc_audace,traite2calibre,color,textdisp) #FF0000
      set audace(param_spc_audace,traite2calibre,font,c12b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,traite2calibre,font,c10b) [ list {Courier} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,traite2calibre,titre2) "Prétraitement -> calibration"
      set caption(param_spc_audace,traite2calibre,titre) "Traitement de spectres"
      set caption(param_spc_audace,traite2calibre,compute_button) "Calculer"
      set caption(param_spc_audace,traite2calibre,return_button) "OK"
      set caption(param_spc_audace,traite2calibre,config,brut) "Nom générique brut"
      set caption(param_spc_audace,traite2calibre,config,noir) "Nom générique noir"
      set caption(param_spc_audace,traite2calibre,config,plu) "Nom générique plu"
      set caption(param_spc_audace,traite2calibre,config,noirplu) "Nom générique noir de plu"
      set caption(param_spc_audace,traite2calibre,config,lampe) "Nom spectre lampe"
      set caption(param_spc_audace,traite2calibre,config,methreg) "Méthode d'appariement (reg, spc)"
      # set caption(param_spc_audace,traite2calibre,config,methsel) "Méthode de détection du spectre (large, serre)"
      set caption(param_spc_audace,traite2calibre,config,methsel) "Détection du spectre (large, serre)"
      # set caption(param_spc_audace,traite2calibre,config,methsky) "Méthode soustraction du fond de ciel (moy, moy2, med, inf, sup, back, none)"
      set caption(param_spc_audace,traite2calibre,config,methsky) "Méthode soustraction du fond de ciel"
      set caption(param_spc_audace,traite2calibre,config,methbin) "Méthode de binning (add, rober, horne)"
      set caption(param_spc_audace,traite2calibre,config,smooth) "Adoucissement (o/n)"
      
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_traite2calibre de niveau le plus haut
      toplevel .param_spc_audace_traite2calibre -class Toplevel -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      wm geometry .param_spc_audace_traite2calibre 450x405+30+30
      wm resizable .param_spc_audace_traite2calibre 0 0
      wm title .param_spc_audace_traite2calibre $caption(param_spc_audace,traite2calibre,titre)
      wm protocol .param_spc_audace_traite2calibre WM_DELETE_WINDOW "::param_spc_audace_traite2calibre::stop"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traite2calibre.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,traite2calibre,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey)
      pack .param_spc_audace_traite2calibre.title \
	      -in .param_spc_audace_traite2calibre -fill x -side top -pady 5
      
      # --- Boutons du bas
      frame .param_spc_audace_traite2calibre.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      button .param_spc_audace_traite2calibre.return_button  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,return_button)" \
	      -command {::param_spc_audace_traite2calibre::go}
      pack  .param_spc_audace_traite2calibre.return_button -in .param_spc_audace_traite2calibre.buttons -side left -fill none -padx 3
      pack .param_spc_audace_traite2calibre.buttons -in .param_spc_audace_traite2calibre -fill x -pady 3 -padx 3 -anchor s -side bottom
      
      #--- Label + Entry pour xa1
      frame .param_spc_audace_traite2calibre.brut -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
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
      frame .param_spc_audace_traite2calibre.noir -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
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
      frame .param_spc_audace_traite2calibre.plu -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
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
      frame .param_spc_audace_traite2calibre.noirplu -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
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
      
      #--- Label + Entry pour lampe
      frame .param_spc_audace_traite2calibre.lampe -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.lampe.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,lampe) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.lampe.label -in .param_spc_audace_traite2calibre.lampe -side left -fill none
      entry  .param_spc_audace_traite2calibre.lampe.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,lampe) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.lampe.entry -in .param_spc_audace_traite2calibre.lampe -side left -fill none
      pack .param_spc_audace_traite2calibre.lampe -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methreg
      frame .param_spc_audace_traite2calibre.methreg -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methreg.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methreg) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methreg.label -in .param_spc_audace_traite2calibre.methreg -side left -fill none
      entry  .param_spc_audace_traite2calibre.methreg.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,methreg) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.methreg.entry -in .param_spc_audace_traite2calibre.methreg -side left -fill none
      pack .param_spc_audace_traite2calibre.methreg -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsel
      frame .param_spc_audace_traite2calibre.methsel -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methsel.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methsel) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methsel.label -in .param_spc_audace_traite2calibre.methsel -side left -fill none
      entry  .param_spc_audace_traite2calibre.methsel.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,methsel) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.methsel.entry -in .param_spc_audace_traite2calibre.methsel -side left -fill none
      pack .param_spc_audace_traite2calibre.methsel -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsky
      frame .param_spc_audace_traite2calibre.methsky -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methsky.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methsky) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methsky.label -in .param_spc_audace_traite2calibre.methsky -side left -fill none
      entry  .param_spc_audace_traite2calibre.methsky.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,methsky) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.methsky.entry -in .param_spc_audace_traite2calibre.methsky -side left -fill none
      pack .param_spc_audace_traite2calibre.methsky -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methbin
      frame .param_spc_audace_traite2calibre.methbin -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.methbin.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,methbin) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.methbin.label -in .param_spc_audace_traite2calibre.methbin -side left -fill none
      entry  .param_spc_audace_traite2calibre.methbin.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,methbin) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.methbin.entry -in .param_spc_audace_traite2calibre.methbin -side left -fill none
      pack .param_spc_audace_traite2calibre.methbin -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour smooth
      frame .param_spc_audace_traite2calibre.smooth -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2calibre,color,backpad)
      label .param_spc_audace_traite2calibre.smooth.label  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -text "$caption(param_spc_audace,traite2calibre,config,smooth) " -bg $audace(param_spc_audace,traite2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2calibre.smooth.label -in .param_spc_audace_traite2calibre.smooth -side left -fill none
      entry  .param_spc_audace_traite2calibre.smooth.entry  \
	      -font $audace(param_spc_audace,traite2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2calibre,config,smooth) -bg $audace(param_spc_audace,traite2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2calibre.smooth.entry -in .param_spc_audace_traite2calibre.smooth -side left -fill none
      pack .param_spc_audace_traite2calibre.smooth -in .param_spc_audace_traite2calibre -fill none -pady 1 -padx 12
      
      
  }
  
  proc stop {  } {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_traite2calibre ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_traite2calibre]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
      
      #--- Supprime la fenetre
      destroy .param_spc_audace_traite2calibre
      return
  }
  
  proc go {} {
      global audace
      global caption
      ::param_spc_audace_traite2calibre::stop
  }
  
}
#****************************************************************************#



########################################################################
# Boîte graphique de saisie de s paramètres pour la metafonction spc_traite2rinstrum
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_traite2rinstrum
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_traite2rinstrum {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_traite2rinstrum.* ] ] != "0" } {
         destroy .param_spc_audace_traite2rinstrum
      }

      # === Initialisation des variables qui seront changées
      # set audace(param_spc_audace,traite2rinstrum,config,brut) ""
      # set audace(param_spc_audace,traite2rinstrum,config,noir) ""
      # set audace(param_spc_audace,traite2rinstrum,config,plu) ""
      # set audace(param_spc_audace,traite2rinstrum,config,noirplu) ""
      # set audace(param_spc_audace,traite2rinstrum,config,lampe) ""
      # set audace(param_spc_audace,traite2rinstrum,config,etoile_ref) ""
      # set audace(param_spc_audace,traite2rinstrum,config,etoile_cat) ""
      # set audace(param_spc_audace,traite2rinstrum,config,methreg) ""
      # set audace(param_spc_audace,traite2rinstrum,config,methsel) ""
      # set audace(param_spc_audace,traite2rinstrum,config,methsky) ""
      # set audace(param_spc_audace,traite2rinstrum,config,methbin) ""
      # set audace(param_spc_audace,traite2rinstrum,config,norma) ""
      
      # === Variables d'environnement
      set audace(param_spc_audace,traite2rinstrum,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traite2rinstrum,color,backpad) #F0F0FF
      set audace(param_spc_audace,traite2rinstrum,color,backdisp) $color(white)
      set audace(param_spc_audace,traite2rinstrum,color,textdisp) #FF0000
      set audace(param_spc_audace,traite2rinstrum,font,c12b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,traite2rinstrum,font,c10b) [ list {Courier} 10 bold ]
      
      # === Captions
      set caption(param_spc_audace,traite2rinstrum,titre2) "Prétraitement -> correction instrumentale"
      set caption(param_spc_audace,traite2rinstrum,titre) "Traitement de spectres"
      set caption(param_spc_audace,traite2rinstrum,compute_button) "Calculer"
      set caption(param_spc_audace,traite2rinstrum,return_button) "OK"
      set caption(param_spc_audace,traite2rinstrum,config,brut) "Nom générique brut"
      set caption(param_spc_audace,traite2rinstrum,config,noir) "Nom générique noir"
      set caption(param_spc_audace,traite2rinstrum,config,plu) "Nom générique plu"
      set caption(param_spc_audace,traite2rinstrum,config,noirplu) "Nom générique noir de plu"
      set caption(param_spc_audace,traite2rinstrum,config,lampe) "Spectre de lampe de calibration"
      set caption(param_spc_audace,traite2rinstrum,config,etoile_ref) "Spectre d'étoile de référence"
      set caption(param_spc_audace,traite2rinstrum,config,etoile_cat) "Spectre d'étoile du catalogue"
      set caption(param_spc_audace,traite2rinstrum,config,methreg) "Méthode d'appariement (reg, spc)"
      # set caption(param_spc_audace,traite2rinstrum,config,methsel) "Méthode de détection du spectre (large, serre)"
      set caption(param_spc_audace,traite2rinstrum,config,methsel) "Détection du spectre (large, serre)"
      # set caption(param_spc_audace,traite2rinstrum,config,methsky) "Méthode soustraction du fond de ciel (moy, moy2, med, inf, sup, back, none)"
      set caption(param_spc_audace,traite2rinstrum,config,methsky) "Méthode soustraction du fond de ciel"
      set caption(param_spc_audace,traite2rinstrum,config,methbin) "Méthode de binning (add, rober, horne)"
      set caption(param_spc_audace,traite2rinstrum,config,norma) "Normalisation (o/n)"
      
      
      # === Met en place l'interface graphique
      
      #--- Cree la fenetre .param_spc_audace_traite2rinstrum de niveau le plus haut
      toplevel .param_spc_audace_traite2rinstrum -class Toplevel -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      wm geometry .param_spc_audace_traite2rinstrum 450x465+30+30
      wm resizable .param_spc_audace_traite2rinstrum 0 0
      wm title .param_spc_audace_traite2rinstrum $caption(param_spc_audace,traite2rinstrum,titre)
      wm protocol .param_spc_audace_traite2rinstrum WM_DELETE_WINDOW "::param_spc_audace_traite2rinstrum::stop"
      
      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traite2rinstrum.title \
	      -font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,traite2rinstrum,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey)
      pack .param_spc_audace_traite2rinstrum.title \
	      -in .param_spc_audace_traite2rinstrum -fill x -side top -pady 5
      
      # --- Boutons du bas
      frame .param_spc_audace_traite2rinstrum.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      button .param_spc_audace_traite2rinstrum.return_button  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,return_button)" \
	      -command {::param_spc_audace_traite2rinstrum::go}
      pack  .param_spc_audace_traite2rinstrum.return_button -in .param_spc_audace_traite2rinstrum.buttons -side left -fill none -padx 3
      pack .param_spc_audace_traite2rinstrum.buttons -in .param_spc_audace_traite2rinstrum -fill x -pady 3 -padx 3 -anchor s -side bottom
      
      #--- Label + Entry pour brut
      frame .param_spc_audace_traite2rinstrum.brut -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.brut.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,brut) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.brut.label -in .param_spc_audace_traite2rinstrum.brut -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.brut.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,brut) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.brut.entry -in .param_spc_audace_traite2rinstrum.brut -side left -fill none
      pack .param_spc_audace_traite2rinstrum.brut -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour noir
      frame .param_spc_audace_traite2rinstrum.noir -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.noir.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,noir) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.noir.label -in .param_spc_audace_traite2rinstrum.noir -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.noir.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,noir) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.noir.entry -in .param_spc_audace_traite2rinstrum.noir -side left -fill none
      pack .param_spc_audace_traite2rinstrum.noir -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour plu
      frame .param_spc_audace_traite2rinstrum.plu -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.plu.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,plu) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.plu.label -in .param_spc_audace_traite2rinstrum.plu -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.plu.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,plu) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.plu.entry -in .param_spc_audace_traite2rinstrum.plu -side left -fill none
      pack .param_spc_audace_traite2rinstrum.plu -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traite2rinstrum.noirplu -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.noirplu.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,noirplu) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.noirplu.label -in .param_spc_audace_traite2rinstrum.noirplu -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.noirplu.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,noirplu) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.noirplu.entry -in .param_spc_audace_traite2rinstrum.noirplu -side left -fill none
      pack .param_spc_audace_traite2rinstrum.noirplu -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour lampe
      frame .param_spc_audace_traite2rinstrum.lampe -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.lampe.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,lampe) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.lampe.label -in .param_spc_audace_traite2rinstrum.lampe -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.lampe.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,lampe) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.lampe.entry -in .param_spc_audace_traite2rinstrum.lampe -side left -fill none
      pack .param_spc_audace_traite2rinstrum.lampe -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour etoile_ref
      frame .param_spc_audace_traite2rinstrum.etoile_ref -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.etoile_ref.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,etoile_ref) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.etoile_ref.label -in .param_spc_audace_traite2rinstrum.etoile_ref -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.etoile_ref.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,etoile_ref) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.etoile_ref.entry -in .param_spc_audace_traite2rinstrum.etoile_ref -side left -fill none
      pack .param_spc_audace_traite2rinstrum.etoile_ref -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      
      #--- Label + Entry pour etoile_cat
      frame .param_spc_audace_traite2rinstrum.etoile_cat -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.etoile_cat.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,etoile_cat) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.etoile_cat.label -in .param_spc_audace_traite2rinstrum.etoile_cat -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.etoile_cat.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,etoile_cat) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.etoile_cat.entry -in .param_spc_audace_traite2rinstrum.etoile_cat -side left -fill none
      pack .param_spc_audace_traite2rinstrum.etoile_cat -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methreg
      frame .param_spc_audace_traite2rinstrum.methreg -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methreg.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,methreg) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methreg.label -in .param_spc_audace_traite2rinstrum.methreg -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.methreg.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,methreg) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.methreg.entry -in .param_spc_audace_traite2rinstrum.methreg -side left -fill none
      pack .param_spc_audace_traite2rinstrum.methreg -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsel
      frame .param_spc_audace_traite2rinstrum.methsel -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methsel.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,methsel) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methsel.label -in .param_spc_audace_traite2rinstrum.methsel -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.methsel.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,methsel) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.methsel.entry -in .param_spc_audace_traite2rinstrum.methsel -side left -fill none
      pack .param_spc_audace_traite2rinstrum.methsel -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methsky
      frame .param_spc_audace_traite2rinstrum.methsky -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methsky.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,methsky) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methsky.label -in .param_spc_audace_traite2rinstrum.methsky -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.methsky.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,methsky) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.methsky.entry -in .param_spc_audace_traite2rinstrum.methsky -side left -fill none
      pack .param_spc_audace_traite2rinstrum.methsky -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour methbin
      frame .param_spc_audace_traite2rinstrum.methbin -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methbin.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,methbin) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methbin.label -in .param_spc_audace_traite2rinstrum.methbin -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.methbin.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,methbin) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.methbin.entry -in .param_spc_audace_traite2rinstrum.methbin -side left -fill none
      pack .param_spc_audace_traite2rinstrum.methbin -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      #--- Label + Entry pour norma
      frame .param_spc_audace_traite2rinstrum.norma -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.norma.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(param_spc_audace,traite2rinstrum,config,norma) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.norma.label -in .param_spc_audace_traite2rinstrum.norma -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.norma.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,norma) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.norma.entry -in .param_spc_audace_traite2rinstrum.norma -side left -fill none
      pack .param_spc_audace_traite2rinstrum.norma -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
      
      
  }
  
  proc stop {  } {
      global conf
      global audace
      
      if { [ winfo exists .param_spc_audace_traite2rinstrum ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_traite2rinstrum]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
      
      #--- Supprime la fenetre
      destroy .param_spc_audace_traite2rinstrum
      return
  }
  
  proc go {} {
      global audace
      global caption
      ::param_spc_audace_traite2rinstrum::stop
  }
  
}
#****************************************************************************#


