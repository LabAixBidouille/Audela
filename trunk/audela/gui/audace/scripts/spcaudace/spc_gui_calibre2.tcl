# =================================================================================
# Test d'IHM pour SPC Aud'ACE
# =================================================================================
# Placer ihm.tcl dans gui/audace/scripts
# Appel : source audace/scripts/imh.tcl
#
# Pour utiliser la valeur de RA modifiée:
# set audace(param_spc_audace,prepare,config,ra)
# =================================================================================
# =================================================================================

namespace eval ::param_spc_audace_prepare {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .param_spc_audace_prepare.* ] ] != "0" } {
         destroy .param_spc_audace_prepare
      }

      # === Initialisation des variables qui seront changées
                set audace(param_spc_audace,prepare,config,xa1) ""
		set audace(param_spc_audace,prepare,config,xa2) ""
		set audace(param_spc_audace,prepare,config,lambda1) ""
		set audace(param_spc_audace,prepare,config,type1) ""
		set audace(param_spc_audace,prepare,config,xb1) ""
		set audace(param_spc_audace,prepare,config,xb2) ""
		set audace(param_spc_audace,prepare,config,lambda2) ""
		set audace(param_spc_audace,prepare,config,type2) ""

		# === Variables d'environnement
		set audace(param_spc_audace,prepare,color,textkey) $color(blue_pad)
		set audace(param_spc_audace,prepare,color,backpad) #F0F0FF
		set audace(param_spc_audace,prepare,color,backdisp) $color(white)
		set audace(param_spc_audace,prepare,color,textdisp) #FF0000
		set audace(param_spc_audace,prepare,font,c12b) [ list {Courier} 10 bold ]
		set audace(param_spc_audace,prepare,font,c10b) [ list {Courier} 10 bold ]

		# === Captions
		set caption(param_spc_audace,prepare,titre2) "Paramètres des 2 raies"
		set caption(param_spc_audace,prepare,titre) "Calibration avec 2 raies"
		set caption(param_spc_audace,prepare,compute_button) "Calculer"
		set caption(param_spc_audace,prepare,return_button) "OK"
		set caption(param_spc_audace,prepare,config,xa1) "Raie 1 : x à gauche"
		set caption(param_spc_audace,prepare,config,xa2) "Raie 1 : x à droite"
		set caption(param_spc_audace,prepare,config,lambda1) "Raie 1 : lambda"
		set caption(param_spc_audace,prepare,config,type1) "Raie 1 : type (e/a)"
		set caption(param_spc_audace,prepare,config,xb1) "Raie 2 : x à gauche"
		set caption(param_spc_audace,prepare,config,xb2) "Raie 2 : x à droite"
		set caption(param_spc_audace,prepare,config,lambda2) "Raie 2 : lambda"
		set caption(param_spc_audace,prepare,config,type2) "Raie 2 : type (e/a)"

		# === Met en place l'interface graphique

		#--- Cree la fenetre .param_spc_audace_prepare de niveau le plus haut
		toplevel .param_spc_audace_prepare -class Toplevel -bg $audace(param_spc_audace,prepare,color,backpad)
		wm geometry .param_spc_audace_prepare 300x330+30+30
		wm resizable .param_spc_audace_prepare 0 0
		wm title .param_spc_audace_prepare $caption(param_spc_audace,prepare,titre)
		wm protocol .param_spc_audace_prepare WM_DELETE_WINDOW "::param_spc_audace_prepare::stop"

		#--- Create the title
		#--- Cree le titre
		label .param_spc_audace_prepare.title \
    		-font [ list {Arial} 16 bold ] -text $caption(param_spc_audace,prepare,titre2) \
    		-borderwidth 0 -relief flat -bg $audace(param_spc_audace,prepare,color,backpad) \
    		-fg $audace(param_spc_audace,prepare,color,textkey)
		pack .param_spc_audace_prepare.title \
    		-in .param_spc_audace_prepare -fill x -side top -pady 5

		# --- Boutons du bas
		frame .param_spc_audace_prepare.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			button .param_spc_audace_prepare.return_button  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,return_button)" \
				-command {::param_spc_audace_prepare::go}
			pack  .param_spc_audace_prepare.return_button -in .param_spc_audace_prepare.buttons -side left -fill none -padx 3
		pack .param_spc_audace_prepare.buttons -in .param_spc_audace_prepare -fill x -pady 3 -padx 3 -anchor s -side bottom

		#--- Label + Entry pour xa1
		frame .param_spc_audace_prepare.xa1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.xa1.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,xa1) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.xa1.label -in .param_spc_audace_prepare.xa1 -side left -fill none
			entry  .param_spc_audace_prepare.xa1.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,xa1) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.xa1.entry -in .param_spc_audace_prepare.xa1 -side left -fill none
      pack .param_spc_audace_prepare.xa1 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour xa2
		frame .param_spc_audace_prepare.xa2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.xa2.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,xa2) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.xa2.label -in .param_spc_audace_prepare.xa2 -side left -fill none
			entry  .param_spc_audace_prepare.xa2.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,xa2) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.xa2.entry -in .param_spc_audace_prepare.xa2 -side left -fill none
      pack .param_spc_audace_prepare.xa2 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour lambda1
		frame .param_spc_audace_prepare.lambda1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.lambda1.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,lambda1) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.lambda1.label -in .param_spc_audace_prepare.lambda1 -side left -fill none
			entry  .param_spc_audace_prepare.lambda1.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,lambda1) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.lambda1.entry -in .param_spc_audace_prepare.lambda1 -side left -fill none
      pack .param_spc_audace_prepare.lambda1 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour type1
		frame .param_spc_audace_prepare.type1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.type1.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,type1) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.type1.label -in .param_spc_audace_prepare.type1 -side left -fill none
			entry  .param_spc_audace_prepare.type1.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,type1) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.type1.entry -in .param_spc_audace_prepare.type1 -side left -fill none
      pack .param_spc_audace_prepare.type1 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour xb1
		frame .param_spc_audace_prepare.xb1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.xb1.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,xb1) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.xb1.label -in .param_spc_audace_prepare.xb1 -side left -fill none
			entry  .param_spc_audace_prepare.xb1.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,xb1) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.xb1.entry -in .param_spc_audace_prepare.xb1 -side left -fill none
      pack .param_spc_audace_prepare.xb1 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour xb2
		frame .param_spc_audace_prepare.xb2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.xb2.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,xb2) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.xb2.label -in .param_spc_audace_prepare.xb2 -side left -fill none
			entry  .param_spc_audace_prepare.xb2.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,xb2) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.xb2.entry -in .param_spc_audace_prepare.xb2 -side left -fill none
      pack .param_spc_audace_prepare.xb2 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour lambda2
		frame .param_spc_audace_prepare.lambda2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.lambda2.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,lambda2) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.lambda2.label -in .param_spc_audace_prepare.lambda2 -side left -fill none
			entry  .param_spc_audace_prepare.lambda2.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,lambda2) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.lambda2.entry -in .param_spc_audace_prepare.lambda2 -side left -fill none
      pack .param_spc_audace_prepare.lambda2 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12

		#--- Label + Entry pour type2
		frame .param_spc_audace_prepare.type2 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,prepare,color,backpad)
			label .param_spc_audace_prepare.type2.label  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
				-text "$caption(param_spc_audace,prepare,config,type2) " -bg $audace(param_spc_audace,prepare,color,backpad) \
				-fg $audace(param_spc_audace,prepare,color,textkey) -relief flat
			pack  .param_spc_audace_prepare.type2.label -in .param_spc_audace_prepare.type2 -side left -fill none
			entry  .param_spc_audace_prepare.type2.entry  \
				-font $audace(param_spc_audace,prepare,font,c12b) \
         	-textvariable audace(param_spc_audace,prepare,config,type2) -bg $audace(param_spc_audace,prepare,color,backdisp) \
         	-fg $audace(param_spc_audace,prepare,color,textdisp) -relief flat -width 70
      	pack  .param_spc_audace_prepare.type2.entry -in .param_spc_audace_prepare.type2 -side left -fill none
      pack .param_spc_audace_prepare.type2 -in .param_spc_audace_prepare -fill none -pady 1 -padx 12


   }

   proc stop {  } {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_prepare ] } {
         #--- Enregistre la position de la fenetre
         set geom [wm geometry .param_spc_audace_prepare]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }

      #--- Supprime la fenetre
      destroy .param_spc_audace_prepare
      return
   }

   proc go {} {
      global audace
      global caption
		#::console::affiche_resultat "SPC_AUDACE Configuration : \n"
		#::console::affiche_resultat "$caption(param_spc_audace,prepare,config,ra): $audace(param_spc_audace,prepare,config,ra)\n"
		#::console::affiche_resultat "$caption(param_spc_audace,prepare,config,dec): $audace(param_spc_audace,prepare,config,dec)\n"
		::param_spc_audace_prepare::stop
   }

}

set flag 0

if { $flag == 1 } {
       set err [ catch {
	   ::param_spc_audace_prepare::run
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
   }
