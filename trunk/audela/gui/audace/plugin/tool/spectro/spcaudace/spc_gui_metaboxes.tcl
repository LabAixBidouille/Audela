#*********************************************************************************#
#                                                                                 #
# Bo�tes graphiques TK de saisie des param�tres pour les m�ta-focntions Spcaudace  #
#                                                                                 #
#*********************************************************************************#
# Chargement : source $audace(rep_scripts)/spcaudace/spc_gui_boxes.tcl

# Mise a jour $Id: spc_gui_metaboxes.tcl,v 1.12 2008-03-02 20:03:41 bmauclaire Exp $



source [ file join [file dirname [info script]] spc_gui_metaboxes.cap ]

########################################################################
# PRocedeure verifiant la validite des arguments saisie dans un formulaire graphique
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 10-07-2006
# Date de modification : 10-08-2006
# Utilis�e par : les namespace
# Retourne 1 si arguemntes valides, 0 si non valides (champs vides, fichier inexistants)
########################################################################

proc spc_testguiargs { listeargs } {

    global conf caption

    #--- Les arguments sont supposes etre bien remplis dans le formulaire :
    #--  =0 si existe, =1 si existe pas
    set flag_exist 0
    #--  =1 si vide, =0 si pleine
    set flag_empty 0

    #-- Liste des n� des champs :
    set liste_args_vides ""
    set liste_files_out ""

    #-- Compteur de champ
    set i 0
    #--- Gestion des champs vides et test d'existence des fichiers
    foreach arg $listeargs {
	incr i
	#if { [ string compare $arg "" ] }
	if { $arg == "" } {
	    set flag_empty [ expr $flag_empty | 1 ]
	    #-- Ajoute le nom de l'argument a la liste s'il est vide
	    lappend liste_args_vides $i
	} else {
	    set flag_empty [ expr $flag_empty | 0 ]
	    #--- Test le cas des fichiers inexistants
	    set ext $conf(extension,defaut)
	    #-- regexp a ameliorer
	    #set flag_file [ regexp {.+\$ext} $arg match filename ]
	    #if { $flag_file } {
		#-- Si le fichier n'existe pas :
		#if { [ expr ! [ file exists $arg ] ] } {
		#    set flag_exist [ expr $flag_exist & 1 ]
		    #-- Ajoute le nom de l'argument a la liste si le fichier n'existe pas
		#    lappend liste_files_out $i
		#}
	    #}
	}
    }

    #--- Affiche un message d'erreur en focntion de l'erreur de saisie :
    if { [ expr $flag_empty & $flag_exist ] } {
	tk_messageBox -title $caption(spcaudace,gui,erreur,saisie)  -icon error \
	-message [format $caption(spcaudace,metaboxes,erreur,champ1) $liste_args_vides $liste_files_out ]
	return 0
    } elseif { $flag_empty } {
	tk_messageBox -title $caption(spcaudace,gui,erreur,saisie)  -icon error \
	-message [format $caption(spcaudace,metaboxes,erreur,champ2) $liste_args_vides ]
	return 0
    } elseif { $flag_exist } {
	tk_messageBox -title $caption(spcaudace,gui,erreur,saisie)  -icon error \
	-message [format $caption(spcaudace,metaboxes,erreur,champ3) $liste_file_out ]
	return 0
    } else {
	return 1
    }
}



########################################################################
# Bo�te graphique de saisie de s param�tres pour la calibration avec 2 raies
#
# Auteurs : Alain Klotz, Benjamin Mauclaire
# Date de cr�ation : 07-07-2006
# Date de modification : 07-07-2006
# Utilis�e par : spc_*2calibre (spc_traite2calibre, spc_geom2calibre,...), spc_*2instrum
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

      # === Variables d'environnement
      set audace(param_spc_audace,calibre2,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,calibre2,color,backpad) #F0F0FF
      set audace(param_spc_audace,calibre2,color,backdisp) $color(white)
      set audace(param_spc_audace,calibre2,color,textdisp) #FF0000
      set audace(param_spc_audace,calibre2,font,c12b) [ list {Courier} 10 bold ]
      set audace(param_spc_audace,calibre2,font,c10b) [ list {Courier} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_calibre2 de niveau le plus haut
      toplevel .param_spc_audace_calibre2 -class Toplevel -bg $audace(param_spc_audace,calibre2,color,backpad)
      wm geometry .param_spc_audace_calibre2 300x330+30+30
      wm resizable .param_spc_audace_calibre2 0 0
      wm title .param_spc_audace_calibre2 $caption(spcaudace,metaboxes,calibre2,titre)
      wm protocol .param_spc_audace_calibre2 WM_DELETE_WINDOW "::param_spc_audace_calibre2::stop"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_calibre2.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,calibre2,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibre2,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2,color,textkey)
      pack .param_spc_audace_calibre2.title \
	      -in .param_spc_audace_calibre2 -fill x -side top -pady 5

      # --- Boutons du bas
      frame .param_spc_audace_calibre2.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      button .param_spc_audace_calibre2.return_button  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibre2,return_button)" \
	      -command {::param_spc_audace_calibre2::go}
      pack  .param_spc_audace_calibre2.return_button -in .param_spc_audace_calibre2.buttons -side left -fill none -padx 3
      pack .param_spc_audace_calibre2.buttons -in .param_spc_audace_calibre2 -fill x -pady 3 -padx 3 -anchor s -side bottom

      #--- Label + Entry pour xa1
      frame .param_spc_audace_calibre2.xa1 -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2,color,backpad)
      label .param_spc_audace_calibre2.xa1.label  \
	      -font $audace(param_spc_audace,calibre2,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibre2,config,xa1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,xa2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,lambda1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,type1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,xb1) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,xb2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,lambda2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2,config,type2) " -bg $audace(param_spc_audace,calibre2,color,backpad) \
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
      #::console::affiche_resultat "$caption(spcaudace,metaboxes,calibre2,config,ra): $audace(param_spc_audace,calibre2,config,ra)\n"
      #::console::affiche_resultat "$caption(spcaudace,metaboxes,calibre2,config,dec): $audace(param_spc_audace,calibre2,config,dec)\n"
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
# Bo�te graphique de saisie des param�tres pour la calibration avec 2 raies dedans
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 09-07-2006
# Date de modification : 09-07-2006
# Utilis�e par : spc_calibre2file (n'existe pas encore  : calibration avec 2 raies dans le profil)
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

       # === Variables d'environnement
       set audace(param_spc_audace,calibre2file,color,textkey) $color(blue_pad)
       set audace(param_spc_audace,calibre2file,color,backpad) #F0F0FF
       set audace(param_spc_audace,calibre2file,color,backdisp) $color(white)
       set audace(param_spc_audace,calibre2file,color,textdisp) #FF0000
       set audace(param_spc_audace,calibre2file,font,c12b) [ list {Courier} 10 bold ]
       set audace(param_spc_audace,calibre2file,font,c10b) [ list {Courier} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_calibre2file de niveau le plus haut
      toplevel .param_spc_audace_calibre2file -class Toplevel -bg $audace(param_spc_audace,calibre2file,color,backpad)
      wm geometry .param_spc_audace_calibre2file 300x330+30+30
      wm resizable .param_spc_audace_calibre2file 0 0
      wm title .param_spc_audace_calibre2file $caption(spcaudace,metaboxes,calibre2file,titre)
      wm protocol .param_spc_audace_calibre2file WM_DELETE_WINDOW "::param_spc_audace_calibre2file::stop"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_calibre2file.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,calibre2file,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibre2file,color,backpad) \
	      -fg $audace(param_spc_audace,calibre2file,color,textkey)
      pack .param_spc_audace_calibre2file.title \
	      -in .param_spc_audace_calibre2file -fill x -side top -pady 5

      # --- Boutons du bas
      frame .param_spc_audace_calibre2file.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      button .param_spc_audace_calibre2file.return_button  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibre2file,return_button)" \
	      -command {::param_spc_audace_calibre2file::go}
      pack  .param_spc_audace_calibre2file.return_button -in .param_spc_audace_calibre2file.buttons -side left -fill none -padx 3
      pack .param_spc_audace_calibre2file.buttons -in .param_spc_audace_calibre2file -fill x -pady 3 -padx 3 -anchor s -side bottom

      #--- Label + Entry pour spectre
      frame .param_spc_audace_calibre2file.spectre -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2file,color,backpad)
      label .param_spc_audace_calibre2file.spectre.label  \
	      -font $audace(param_spc_audace,calibre2file,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,spectre) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,xa1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,xa2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,lambda1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,type1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,xb1) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,xb2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,lambda2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
	      -text "$caption(spcaudace,metaboxes,calibre2file,config,type2) " -bg $audace(param_spc_audace,calibre2file,color,backpad) \
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
# Bo�te graphique de saisie des param�tres pour la calibration avec 2 raies dedans
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 09-07-2006
# Date de modification : 09-07-2006
# Utilis�e par : spc_calibre2loifile
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

       # === Variables d'environnement
       set audace(param_spc_audace,calibre2loifile,color,textkey) $color(blue_pad)
       set audace(param_spc_audace,calibre2loifile,color,backpad) #F0F0FF
       set audace(param_spc_audace,calibre2loifile,color,backdisp) $color(white)
       set audace(param_spc_audace,calibre2loifile,color,textdisp) #FF0000
       set audace(param_spc_audace,calibre2loifile,font,c12b) [ list {Courier} 10 bold ]
       set audace(param_spc_audace,calibre2loifile,font,c10b) [ list {Courier} 10 bold ]

       # === Met en place l'interface graphique

       #--- Cree la fenetre .param_spc_audace_calibre2loifile de niveau le plus haut
       toplevel .param_spc_audace_calibre2loifile -class Toplevel -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       wm geometry .param_spc_audace_calibre2loifile 300x330+10+10
       wm resizable .param_spc_audace_calibre2loifile 0 0
       wm title .param_spc_audace_calibre2loifile $caption(spcaudace,metaboxes,calibre2loifile,titre)
       wm protocol .param_spc_audace_calibre2loifile WM_DELETE_WINDOW "::param_spc_audace_calibre2loifile::stop"

       #--- Create the title
       #--- Cree le titre
       label .param_spc_audace_calibre2loifile.title \
	       -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,calibre2loifile,titre2) \
	       -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibre2loifile,color,backpad) \
	       -fg $audace(param_spc_audace,calibre2loifile,color,textkey)
       pack .param_spc_audace_calibre2loifile.title \
	       -in .param_spc_audace_calibre2loifile -fill x -side top -pady 5

       # --- Boutons du bas
       frame .param_spc_audace_calibre2loifile.buttons -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       button .param_spc_audace_calibre2loifile.return_button  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -text "$caption(spcaudace,metaboxes,calibre2loifile,return_button)" \
	       -command {::param_spc_audace_calibre2loifile::go}
       pack  .param_spc_audace_calibre2loifile.return_button -in .param_spc_audace_calibre2loifile.buttons -side left -fill none -padx 3
       pack .param_spc_audace_calibre2loifile.buttons -in .param_spc_audace_calibre2loifile -fill x -pady 3 -padx 3 -anchor s -side bottom

       #--- Label + Entry pour spectre
       frame .param_spc_audace_calibre2loifile.spectre -borderwidth 3 -relief sunken -bg $audace(param_spc_audace,calibre2loifile,color,backpad)
       label .param_spc_audace_calibre2loifile.spectre.label  \
	       -font $audace(param_spc_audace,calibre2loifile,font,c12b) \
	       -text "$caption(spcaudace,metaboxes,calibre2loifile,config,spectre) " -bg $audace(param_spc_audace,calibre2loifile,color,backpad) \
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
	       -text "$caption(spcaudace,metaboxes,calibre2loifile,config,lampe) " -bg $audace(param_spc_audace,calibre2loifile,color,backpad) \
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
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_geom2calibre
# Intitul� : Corrections g�om�triques -> calibration
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 1-08-2006
# Utilis�e par : spc_geom2calibre
# Args : nom_generique_spectres_pretraites nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_d�tection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_geom2calibre {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      set liste_methreg [ list "spc" "reg" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "o" "n" ]
      set liste_smooth [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_geom2calibre.* ] ] != "0" } {
         destroy .param_spc_audace_geom2calibre
      }

      # === Initialisation des variables qui seront chang�es
      set audace(param_spc_audace,geom2calibre,config,methreg) "spc"
      set audace(param_spc_audace,geom2calibre,config,methsel) "serre"
      set audace(param_spc_audace,geom2calibre,config,methsky) "med"
      set audace(param_spc_audace,geom2calibre,config,methbin) "add"
      set audace(param_spc_audace,geom2calibre,config,methinv) "n"
      set audace(param_spc_audace,geom2calibre,config,methcos) "o"
      set audace(param_spc_audace,geom2calibre,config,smooth) "n"
      set audace(param_spc_audace,geom2calibre,config,norma) "n"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,geom2calibre,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,geom2calibre,color,backpad) #ECE9D8
      set audace(param_spc_audace,geom2calibre,color,backdisp) $color(white)
      set audace(param_spc_audace,geom2calibre,color,textdisp) #FF0000
      set audace(param_spc_audace,geom2calibre,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,geom2calibre,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_geom2calibre de niveau le plus haut
      toplevel .param_spc_audace_geom2calibre -class Toplevel -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      wm geometry .param_spc_audace_geom2calibre 450x357+10+10
      wm resizable .param_spc_audace_geom2calibre 1 1
      wm title .param_spc_audace_geom2calibre $caption(spcaudace,metaboxes,geom2calibre,titre)
      wm protocol .param_spc_audace_geom2calibre WM_DELETE_WINDOW "::param_spc_audace_geom2calibre::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_geom2calibre.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,geom2calibre,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey)
      pack .param_spc_audace_geom2calibre.title \
	      -in .param_spc_audace_geom2calibre -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_geom2calibre.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_geom2calibre.stop_button  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,stop_button)" \
	      -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) \
	      -command {::param_spc_audace_geom2calibre::annuler}
      pack  .param_spc_audace_geom2calibre.stop_button -in .param_spc_audace_geom2calibre.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_geom2calibre.return_button  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,return_button)" \
	      -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) \
	      -command {::param_spc_audace_geom2calibre::go}
      pack  .param_spc_audace_geom2calibre.return_button -in .param_spc_audace_geom2calibre.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_geom2calibre.buttons -in .param_spc_audace_geom2calibre -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour spectres
      frame .param_spc_audace_geom2calibre.spectres -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.spectres.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,spectres) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
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
      label .param_spc_audace_geom2calibre.lampe.label -text "$caption(spcaudace,metaboxes,geom2calibre,config,lampe)" -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b)
      pack  .param_spc_audace_geom2calibre.lampe.label -in .param_spc_audace_geom2calibre.lampe -side left -fill none
      button .param_spc_audace_geom2calibre.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -command { set audace(param_spc_audace,geom2calibre,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_geom2calibre.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2calibre.lampe.entry  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2calibre,config,lampe) -bg $audace(param_spc_audace,geom2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2calibre.lampe.entry -in .param_spc_audace_geom2calibre.lampe -side left -fill none
      pack .param_spc_audace_geom2calibre.lampe -in .param_spc_audace_geom2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methreg.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,methreg) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methreg.label -in .param_spc_audace_geom2calibre.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_geom2calibre.methreg.combobox -in .param_spc_audace_geom2calibre.methreg -side right -fill none
      pack .param_spc_audace_geom2calibre.methreg -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methcos.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,methcos) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methcos.label -in .param_spc_audace_geom2calibre.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_geom2calibre.methcos.combobox -in .param_spc_audace_geom2calibre.methcos -side right -fill none
      pack .param_spc_audace_geom2calibre.methcos -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methsel.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,methsel) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methsel.label -in .param_spc_audace_geom2calibre.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_geom2calibre.methsel.combobox -in .param_spc_audace_geom2calibre.methsel -side right -fill none
      pack .param_spc_audace_geom2calibre.methsel -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methsky.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,methsky) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methsky.label -in .param_spc_audace_geom2calibre.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_geom2calibre.methsky.combobox -in .param_spc_audace_geom2calibre.methsky -side right -fill none
      pack .param_spc_audace_geom2calibre.methsky -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methbin.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,methbin) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methbin.label -in .param_spc_audace_geom2calibre.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_geom2calibre.methbin.combobox -in .param_spc_audace_geom2calibre.methbin -side right -fill none
      pack .param_spc_audace_geom2calibre.methbin -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.methinv.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,methinv) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.methinv.label -in .param_spc_audace_geom2calibre.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_geom2calibre.methinv.combobox -in .param_spc_audace_geom2calibre.methinv -side right -fill none
      pack .param_spc_audace_geom2calibre.methinv -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_geom2calibre.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2calibre,color,backpad)
      label .param_spc_audace_geom2calibre.smooth.label  \
	      -font $audace(param_spc_audace,geom2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2calibre,config,smooth) " -bg $audace(param_spc_audace,geom2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,geom2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_geom2calibre.smooth.label -in .param_spc_audace_geom2calibre.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2calibre.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2calibre,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_geom2calibre.smooth.combobox -in .param_spc_audace_geom2calibre.smooth -side right -fill none
      pack .param_spc_audace_geom2calibre.smooth -in .param_spc_audace_geom2calibre -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace
      global caption

      ::param_spc_audace_geom2calibre::recup_conf
      set spectres $audace(param_spc_audace,geom2calibre,config,spectres)
      set lampe $audace(param_spc_audace,geom2calibre,config,lampe)
      set methreg $audace(param_spc_audace,geom2calibre,config,methreg)
      set methcos $audace(param_spc_audace,geom2calibre,config,methcos)
      set methsel $audace(param_spc_audace,geom2calibre,config,methsel)
      set methsky $audace(param_spc_audace,geom2calibre,config,methsky)
      set methbin $audace(param_spc_audace,geom2calibre,config,methbin)
      set methinv $audace(param_spc_audace,geom2calibre,config,methinv)
      set smooth $audace(param_spc_audace,geom2calibre,config,smooth)
      set listeargs [ list $spectres $lampe $methreg $methcos $methsel $methsky $methbin $methinv $smooth ]

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set fileout [ spc_geom2calibre $spectres $lampe $methreg $methcos $methsel $methsky $methinv $methbin $smooth ]
	  destroy .param_spc_audace_geom2calibre
	  return $fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_geom2calibre::recup_conf
      destroy .param_spc_audace_geom2calibre
  }


  proc recup_conf {} {
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


}
#****************************************************************************#



########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_geom2rinstrum
# Intitul� : Corrections g�om�triques -> r�ponse instrumentale
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 13-08-2006
# Utilis�e par : spc_geom2rinstrum
# Args : nom_g�n�rique_spectres_pr�trait�s (sans extension) spectre_2D_lampe m�thode_reg (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre)  m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_bining (add, rober, horne) adoucissment (o/n) normalisation (o/n)
########################################################################

namespace eval ::param_spc_audace_geom2rinstrum {

   proc run { {positionxy 20+20} } {
      global conf
      global audace spcaudace
      global caption
      global color

      set liste_methreg [ list "spc" "reg" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "o" "n" ]
      set liste_smooth [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_geom2rinstrum.* ] ] != "0" } {
         destroy .param_spc_audace_geom2rinstrum
      }

      # === Initialisation des variables qui seront chang�es
      set audace(param_spc_audace,geom2rinstrum,config,methreg) "spc"
      set audace(param_spc_audace,geom2rinstrum,config,methsel) "serre"
      set audace(param_spc_audace,geom2rinstrum,config,methsky) "med"
      set audace(param_spc_audace,geom2rinstrum,config,methbin) "add"
      set audace(param_spc_audace,geom2rinstrum,config,methinv) "n"
      set audace(param_spc_audace,geom2rinstrum,config,methcos) "o"
      set audace(param_spc_audace,geom2rinstrum,config,smooth) "n"
      set audace(param_spc_audace,geom2rinstrum,config,norma) "n"

      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,geom2rinstrum,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,geom2rinstrum,color,backpad) #ECE9D8
      set audace(param_spc_audace,geom2rinstrum,color,backdisp) $color(white)
      set audace(param_spc_audace,geom2rinstrum,color,textdisp) #FF0000
      set audace(param_spc_audace,geom2rinstrum,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,geom2rinstrum,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_geom2rinstrum de niveau le plus haut
      toplevel .param_spc_audace_geom2rinstrum -class Toplevel -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      wm geometry .param_spc_audace_geom2rinstrum 450x462+10+10
      wm resizable .param_spc_audace_geom2rinstrum 1 1
      wm title .param_spc_audace_geom2rinstrum $caption(spcaudace,metaboxes,geom2rinstrum,titre)
      wm protocol .param_spc_audace_geom2rinstrum WM_DELETE_WINDOW "::param_spc_audace_geom2rinstrum::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_geom2rinstrum.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,geom2rinstrum,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey)
      pack .param_spc_audace_geom2rinstrum.title \
	      -in .param_spc_audace_geom2rinstrum -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_geom2rinstrum.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_geom2rinstrum.stop_button  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,stop_button)" \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) \
	      -command {::param_spc_audace_geom2rinstrum::annuler}
      pack  .param_spc_audace_geom2rinstrum.stop_button -in .param_spc_audace_geom2rinstrum.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_geom2rinstrum.return_button  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,return_button)" \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) \
	      -command {::param_spc_audace_geom2rinstrum::go}
      pack  .param_spc_audace_geom2rinstrum.return_button -in .param_spc_audace_geom2rinstrum.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_geom2rinstrum.buttons -in .param_spc_audace_geom2rinstrum -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour spectres
      frame .param_spc_audace_geom2rinstrum.spectres -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.spectres.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,spectres) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.spectres.label -in .param_spc_audace_geom2rinstrum.spectres -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.spectres.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,spectres) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.spectres.entry -in .param_spc_audace_geom2rinstrum.spectres -side left -fill none
      pack .param_spc_audace_geom2rinstrum.spectres -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12

      #--- Label + Entry pour lampe
      frame .param_spc_audace_geom2rinstrum.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.lampe.label -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,lampe)" -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b)
      pack  .param_spc_audace_geom2rinstrum.lampe.label -in .param_spc_audace_geom2rinstrum.lampe -side left -fill none
      button .param_spc_audace_geom2rinstrum.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,geom2rinstrum,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_geom2rinstrum.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2rinstrum.lampe.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,lampe) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.lampe.entry -in .param_spc_audace_geom2rinstrum.lampe -side left -fill none
      pack .param_spc_audace_geom2rinstrum.lampe -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour etoile_ref
      frame .param_spc_audace_geom2rinstrum.etoile_ref -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.etoile_ref.label -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,etoile_ref)" -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b)
      pack  .param_spc_audace_geom2rinstrum.etoile_ref.label -in .param_spc_audace_geom2rinstrum.etoile_ref -side left -fill none
      button .param_spc_audace_geom2rinstrum.etoile_ref.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,geom2rinstrum,config,etoile_ref) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_geom2rinstrum.etoile_ref.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2rinstrum.etoile_ref.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,etoile_ref) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.etoile_ref.entry -in .param_spc_audace_geom2rinstrum.etoile_ref -side left -fill none
      pack .param_spc_audace_geom2rinstrum.etoile_ref -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour etoile_cat
      frame .param_spc_audace_geom2rinstrum.etoile_cat -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.etoile_cat.label -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,etoile_cat)" -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b)
      pack  .param_spc_audace_geom2rinstrum.etoile_cat.label -in .param_spc_audace_geom2rinstrum.etoile_cat -side left -fill none
      button .param_spc_audace_geom2rinstrum.etoile_cat.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,geom2rinstrum,config,etoile_cat) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $spcaudace(rep_spcbib) ] ] }
      pack .param_spc_audace_geom2rinstrum.etoile_cat.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2rinstrum.etoile_cat.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,etoile_cat) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.etoile_cat.entry -in .param_spc_audace_geom2rinstrum.etoile_cat -side left -fill none
      pack .param_spc_audace_geom2rinstrum.etoile_cat -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12



      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methreg.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methreg) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methreg.label -in .param_spc_audace_geom2rinstrum.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_geom2rinstrum.methreg.combobox -in .param_spc_audace_geom2rinstrum.methreg -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methreg -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methcos.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methcos) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methcos.label -in .param_spc_audace_geom2rinstrum.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_geom2rinstrum.methcos.combobox -in .param_spc_audace_geom2rinstrum.methcos -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methcos -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methsel.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methsel) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methsel.label -in .param_spc_audace_geom2rinstrum.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_geom2rinstrum.methsel.combobox -in .param_spc_audace_geom2rinstrum.methsel -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methsel -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methsky.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methsky) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methsky.label -in .param_spc_audace_geom2rinstrum.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_geom2rinstrum.methsky.combobox -in .param_spc_audace_geom2rinstrum.methsky -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methsky -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methbin.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methbin) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methbin.label -in .param_spc_audace_geom2rinstrum.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_geom2rinstrum.methbin.combobox -in .param_spc_audace_geom2rinstrum.methbin -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methbin -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methinv.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methinv) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methinv.label -in .param_spc_audace_geom2rinstrum.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_geom2rinstrum.methinv.combobox -in .param_spc_audace_geom2rinstrum.methinv -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methinv -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour norma
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.norma -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.norma.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,norma) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.norma.label -in .param_spc_audace_geom2rinstrum.norma -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.norma.combobox \
         -width 7          \
         -height [ llength $liste_norma ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,norma) \
         -values $liste_norma
      pack  .param_spc_audace_geom2rinstrum.norma.combobox -in .param_spc_audace_geom2rinstrum.norma -side right -fill none
      pack .param_spc_audace_geom2rinstrum.norma -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.smooth.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,smooth) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.smooth.label -in .param_spc_audace_geom2rinstrum.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_geom2rinstrum.smooth.combobox -in .param_spc_audace_geom2rinstrum.smooth -side right -fill none
      pack .param_spc_audace_geom2rinstrum.smooth -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace
      global caption

      ::param_spc_audace_geom2rinstrum::recup_conf
      set spectres $audace(param_spc_audace,geom2rinstrum,config,spectres)
      set lampe $audace(param_spc_audace,geom2rinstrum,config,lampe)
      set etoile_ref $audace(param_spc_audace,geom2rinstrum,config,etoile_ref)
      set etoile_cat $audace(param_spc_audace,geom2rinstrum,config,etoile_cat)
      set methreg $audace(param_spc_audace,geom2rinstrum,config,methreg)
      set methcos $audace(param_spc_audace,geom2rinstrum,config,methcos)
      set methsel $audace(param_spc_audace,geom2rinstrum,config,methsel)
      set methsky $audace(param_spc_audace,geom2rinstrum,config,methsky)
      set methbin $audace(param_spc_audace,geom2rinstrum,config,methbin)
      set methinv $audace(param_spc_audace,geom2rinstrum,config,methinv)
      set norma $audace(param_spc_audace,geom2rinstrum,config,norma)
      set smooth $audace(param_spc_audace,geom2rinstrum,config,smooth)
      set listeargs [ list $spectres $lampe $etoile_ref $etoile_cat $methreg $methcos $methsel $methsky $methinv $methbin $norma $smooth ]

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set fileout [ spc_geom2rinstrum $spectres $lampe $etoile_ref $etoile_cat $methreg $methcos $methsel $methsky $methinv $methbin $norma $smooth ]
	  destroy .param_spc_audace_geom2rinstrum
	  return $fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_geom2rinstrum::recup_conf
      destroy .param_spc_audace_geom2rinstrum
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_geom2rinstrum ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_geom2rinstrum]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#







########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_geom2rinstrum
# Intitul� : Corrections g�om�triques -> r�ponse instrumentale
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 13-08-2006
# Utilis�e par : spc_geom2rinstrum
# Args : nom_g�n�rique_spectres_pr�trait�s (sans extension) spectre_2D_lampe m�thode_reg (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre)  m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_bining (add, rober, horne) adoucissment (o/n) normalisation (o/n)
########################################################################

namespace eval ::param_spc_audace_geom2rinstrum {

   proc run { {positionxy 20+20} } {
      global conf
      global audace spcaudace
      global caption
      global color

      set liste_methreg [ list "spc" "reg" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "e" "a" "n" ]
      set liste_smooth [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_geom2rinstrum.* ] ] != "0" } {
         destroy .param_spc_audace_geom2rinstrum
      }

      # === Initialisation des variables qui seront chang�es
      set audace(param_spc_audace,geom2rinstrum,config,methreg) "spc"
      set audace(param_spc_audace,geom2rinstrum,config,methsel) "serre"
      set audace(param_spc_audace,geom2rinstrum,config,methsky) "med"
      set audace(param_spc_audace,geom2rinstrum,config,methbin) "add"
      set audace(param_spc_audace,geom2rinstrum,config,methinv) "n"
      set audace(param_spc_audace,geom2rinstrum,config,methcos) "o"
      set audace(param_spc_audace,geom2rinstrum,config,smooth) "n"
      set audace(param_spc_audace,geom2rinstrum,config,norma) "n"

      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,geom2rinstrum,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,geom2rinstrum,color,backpad) #ECE9D8
      set audace(param_spc_audace,geom2rinstrum,color,backdisp) $color(white)
      set audace(param_spc_audace,geom2rinstrum,color,textdisp) #FF0000
      set audace(param_spc_audace,geom2rinstrum,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,geom2rinstrum,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_geom2rinstrum de niveau le plus haut
      toplevel .param_spc_audace_geom2rinstrum -class Toplevel -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      wm geometry .param_spc_audace_geom2rinstrum 450x490+10+10
      wm resizable .param_spc_audace_geom2rinstrum 1 1
      wm title .param_spc_audace_geom2rinstrum $caption(spcaudace,metaboxes,geom2rinstrum,titre)
      wm protocol .param_spc_audace_geom2rinstrum WM_DELETE_WINDOW "::param_spc_audace_geom2rinstrum::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_geom2rinstrum.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,geom2rinstrum,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey)
      pack .param_spc_audace_geom2rinstrum.title \
	      -in .param_spc_audace_geom2rinstrum -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_geom2rinstrum.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_geom2rinstrum.stop_button  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,stop_button)" \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) \
	      -command {::param_spc_audace_geom2rinstrum::annuler}
      pack  .param_spc_audace_geom2rinstrum.stop_button -in .param_spc_audace_geom2rinstrum.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_geom2rinstrum.return_button  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,return_button)" \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) \
	      -command {::param_spc_audace_geom2rinstrum::go}
      pack  .param_spc_audace_geom2rinstrum.return_button -in .param_spc_audace_geom2rinstrum.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_geom2rinstrum.buttons -in .param_spc_audace_geom2rinstrum -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour spectres
      frame .param_spc_audace_geom2rinstrum.spectres -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.spectres.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,spectres) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.spectres.label -in .param_spc_audace_geom2rinstrum.spectres -side left -fill none
      entry  .param_spc_audace_geom2rinstrum.spectres.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,spectres) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.spectres.entry -in .param_spc_audace_geom2rinstrum.spectres -side left -fill none
      pack .param_spc_audace_geom2rinstrum.spectres -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12

      #--- Label + Entry pour lampe
      frame .param_spc_audace_geom2rinstrum.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.lampe.label -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,lampe)" -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b)
      pack  .param_spc_audace_geom2rinstrum.lampe.label -in .param_spc_audace_geom2rinstrum.lampe -side left -fill none
      button .param_spc_audace_geom2rinstrum.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,geom2rinstrum,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_geom2rinstrum.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2rinstrum.lampe.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,lampe) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.lampe.entry -in .param_spc_audace_geom2rinstrum.lampe -side left -fill none
      pack .param_spc_audace_geom2rinstrum.lampe -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour etoile_ref
      frame .param_spc_audace_geom2rinstrum.etoile_ref -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.etoile_ref.label -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,etoile_ref)" -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b)
      pack  .param_spc_audace_geom2rinstrum.etoile_ref.label -in .param_spc_audace_geom2rinstrum.etoile_ref -side left -fill none
      button .param_spc_audace_geom2rinstrum.etoile_ref.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,geom2rinstrum,config,etoile_ref) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_geom2rinstrum.etoile_ref.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2rinstrum.etoile_ref.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,etoile_ref) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.etoile_ref.entry -in .param_spc_audace_geom2rinstrum.etoile_ref -side left -fill none
      pack .param_spc_audace_geom2rinstrum.etoile_ref -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour etoile_cat
      frame .param_spc_audace_geom2rinstrum.etoile_cat -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.etoile_cat.label -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,etoile_cat)" -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b)
      pack  .param_spc_audace_geom2rinstrum.etoile_cat.label -in .param_spc_audace_geom2rinstrum.etoile_cat -side left -fill none
      button .param_spc_audace_geom2rinstrum.etoile_cat.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,geom2rinstrum,config,etoile_cat) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $spcaudace(rep_spcbib) ] ] }
      pack .param_spc_audace_geom2rinstrum.etoile_cat.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_geom2rinstrum.etoile_cat.entry  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,geom2rinstrum,config,etoile_cat) -bg $audace(param_spc_audace,geom2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_geom2rinstrum.etoile_cat.entry -in .param_spc_audace_geom2rinstrum.etoile_cat -side left -fill none
      pack .param_spc_audace_geom2rinstrum.etoile_cat -in .param_spc_audace_geom2rinstrum -fill none -pady 1 -padx 12



      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methreg.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methreg) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methreg.label -in .param_spc_audace_geom2rinstrum.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_geom2rinstrum.methreg.combobox -in .param_spc_audace_geom2rinstrum.methreg -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methreg -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methcos.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methcos) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methcos.label -in .param_spc_audace_geom2rinstrum.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_geom2rinstrum.methcos.combobox -in .param_spc_audace_geom2rinstrum.methcos -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methcos -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methsel.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methsel) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methsel.label -in .param_spc_audace_geom2rinstrum.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_geom2rinstrum.methsel.combobox -in .param_spc_audace_geom2rinstrum.methsel -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methsel -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methsky.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methsky) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methsky.label -in .param_spc_audace_geom2rinstrum.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_geom2rinstrum.methsky.combobox -in .param_spc_audace_geom2rinstrum.methsky -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methsky -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methbin.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methbin) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methbin.label -in .param_spc_audace_geom2rinstrum.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_geom2rinstrum.methbin.combobox -in .param_spc_audace_geom2rinstrum.methbin -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methbin -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.methinv.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,methinv) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.methinv.label -in .param_spc_audace_geom2rinstrum.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_geom2rinstrum.methinv.combobox -in .param_spc_audace_geom2rinstrum.methinv -side right -fill none
      pack .param_spc_audace_geom2rinstrum.methinv -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour norma
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.norma -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.norma.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,norma) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.norma.label -in .param_spc_audace_geom2rinstrum.norma -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.norma.combobox \
         -width 7          \
         -height [ llength $liste_norma ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,norma) \
         -values $liste_norma
      pack  .param_spc_audace_geom2rinstrum.norma.combobox -in .param_spc_audace_geom2rinstrum.norma -side right -fill none
      pack .param_spc_audace_geom2rinstrum.norma -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_geom2rinstrum.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,geom2rinstrum,color,backpad)
      label .param_spc_audace_geom2rinstrum.smooth.label  \
	      -font $audace(param_spc_audace,geom2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,geom2rinstrum,config,smooth) " -bg $audace(param_spc_audace,geom2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,geom2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_geom2rinstrum.smooth.label -in .param_spc_audace_geom2rinstrum.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_geom2rinstrum.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,geom2rinstrum,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_geom2rinstrum.smooth.combobox -in .param_spc_audace_geom2rinstrum.smooth -side right -fill none
      pack .param_spc_audace_geom2rinstrum.smooth -in .param_spc_audace_geom2rinstrum -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace
      global caption

      ::param_spc_audace_geom2rinstrum::recup_conf
      set spectres $audace(param_spc_audace,geom2rinstrum,config,spectres)
      set lampe $audace(param_spc_audace,geom2rinstrum,config,lampe)
      set etoile_ref $audace(param_spc_audace,geom2rinstrum,config,etoile_ref)
      set etoile_cat $audace(param_spc_audace,geom2rinstrum,config,etoile_cat)
      set methreg $audace(param_spc_audace,geom2rinstrum,config,methreg)
      set methcos $audace(param_spc_audace,geom2rinstrum,config,methcos)
      set methsel $audace(param_spc_audace,geom2rinstrum,config,methsel)
      set methsky $audace(param_spc_audace,geom2rinstrum,config,methsky)
      set methbin $audace(param_spc_audace,geom2rinstrum,config,methbin)
      set methinv $audace(param_spc_audace,geom2rinstrum,config,methinv)
      set norma $audace(param_spc_audace,geom2rinstrum,config,norma)
      set smooth $audace(param_spc_audace,geom2rinstrum,config,smooth)
      set listeargs [ list $spectres $lampe $etoile_ref $etoile_cat $methreg $methcos $methsel $methsky $methinv $methbin $norma $smooth ]

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set fileout [ spc_geom2rinstrum $spectres $lampe $etoile_ref $etoile_cat $methreg $methcos $methsel $methsky $methinv $methbin $norma $smooth ]
	  destroy .param_spc_audace_geom2rinstrum
	  return $fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_geom2rinstrum::recup_conf
      destroy .param_spc_audace_geom2rinstrum
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_geom2rinstrum ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_geom2rinstrum]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#






########################################################################
# Bo�te graphique de saisie des param�tres pour la metafonction spc_calibrelampe
# Intitul� : Calibration en longueur d'onde d'un spectre
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 1-08-2006
# Utilis�e par : spc_calibrelampe
# Args : nom_generique_spectres_pretraites nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_d�tection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_calibreprofil {

   proc run { args {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      set audace(param_spc_audace,calibreprofil,config,lampe) [ lindex $args 0 ]
      #- listeabscisses_i : { {x1 I1} {x2 I2}..}
      #set listeabscisses_i [ lsort -increasing -real -index 0 [ lindex $args 1 ] ]
      set listeabscisses_i [ lindex $args 1 ]
      lappend listeabscisses ""
      set listelambdaschem [ lindex $args 2 ]

      if { [ string length [ info commands .param_spc_audace_calibreprofil.* ] ] != "0" } {
         destroy .param_spc_audace_calibreprofil
      }

      #::console::affiche_resultat "Abscisses : $listeabscisses\n"
      #::console::affiche_resultat "Lambdas : $listelambdaschem\n"
      # === Initialisation des variables qui seront chang�es
      set i 1
      foreach raie $listeabscisses_i {
	  set intensite [ lindex $raie 1 ]
	  if { $intensite != 0.0 } {
	      set audace(param_spc_audace,calibreprofil,config,x$i) [ lindex $raie 0 ]
	  } else {
	      set audace(param_spc_audace,calibreprofil,config,x$i) ""
	  }
	  incr i
      }
      #set audace(param_spc_audace,calibreprofil,config,x1) [ lindex $listeabscisses 0 ]
      #set audace(param_spc_audace,calibreprofil,config,x2) [ lindex $listeabscisses 1 ]
      #set audace(param_spc_audace,calibreprofil,config,x3) [ lindex $listeabscisses 2 ]
      #set audace(param_spc_audace,calibreprofil,config,x4) [ lindex $listeabscisses 3 ]
      #set audace(param_spc_audace,calibreprofil,config,x5) [ lindex $listeabscisses 4 ]
      #set audace(param_spc_audace,calibreprofil,config,x6) [ lindex $listeabscisses 5 ]

      #set audace(param_spc_audace,calibreprofil,config,lambda1) ""
      #set audace(param_spc_audace,calibreprofil,config,lambda2) ""
      #set audace(param_spc_audace,calibreprofil,config,lambda3) ""
      #set audace(param_spc_audace,calibreprofil,config,lambda4) ""
      #set audace(param_spc_audace,calibreprofil,config,lambda5) ""
      #set audace(param_spc_audace,calibreprofil,config,lambda6) ""

      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,calibreprofil,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,calibreprofil,color,backpad) #ECE9D8
      set audace(param_spc_audace,calibreprofil,color,backdisp) $color(white)
      set audace(param_spc_audace,calibreprofil,color,textdisp) #FF0000
      set audace(param_spc_audace,calibreprofil,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,calibreprofil,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_calibreprofil de niveau le plus haut
      toplevel .param_spc_audace_calibreprofil -class Toplevel -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      # wm geometry .param_spc_audace_calibreprofil 460x450+10+10
      wm geometry .param_spc_audace_calibreprofil 460x450-23-14
      wm resizable .param_spc_audace_calibreprofil 1 1
      wm title .param_spc_audace_calibreprofil $caption(spcaudace,metaboxes,calibreprofil,titre)
      wm protocol .param_spc_audace_calibreprofil WM_DELETE_WINDOW "::param_spc_audace_calibreprofil::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_calibreprofil.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,calibreprofil,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey)
      pack .param_spc_audace_calibreprofil.title \
	      -in .param_spc_audace_calibreprofil -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_calibreprofil.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_calibreprofil.stop_button  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,stop_button)" \
	      -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) \
	      -command {::param_spc_audace_calibreprofil::annuler}
      pack  .param_spc_audace_calibreprofil.stop_button -in .param_spc_audace_calibreprofil.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_calibreprofil.return_button  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,return_button)" \
	      -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) \
	      -command {::param_spc_audace_calibreprofil::go}
      pack  .param_spc_audace_calibreprofil.return_button -in .param_spc_audace_calibreprofil.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_calibreprofil.buttons -in .param_spc_audace_calibreprofil -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour lampe
      frame .param_spc_audace_calibreprofil.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lampe.label -text "$caption(spcaudace,metaboxes,calibreprofil,config,lampe)" -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b)
      pack  .param_spc_audace_calibreprofil.lampe.label -in .param_spc_audace_calibreprofil.lampe -side left -fill none
      button .param_spc_audace_calibreprofil.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -command { set audace(param_spc_audace,calibreprofil,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_calibreprofil.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_calibreprofil.lampe.entry  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -textvariable audace(param_spc_audace,calibreprofil,config,lampe) -bg $audace(param_spc_audace,calibreprofil,color,backdisp) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textdisp) -relief flat -width 100
      pack  .param_spc_audace_calibreprofil.lampe.entry -in .param_spc_audace_calibreprofil.lampe -side left -fill none
      pack .param_spc_audace_calibreprofil.lampe -in .param_spc_audace_calibreprofil -fill none -pady 1 -padx 12


       if { 1==0 } {
      #--- Message sur les raies :
      label .param_spc_audace_calibreprofil.message1 \
	      -font [ list {Arial} 12 bold ] -text $caption(spcaudace,metaboxes,calibreprofil,message1) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey)
      pack .param_spc_audace_calibreprofil.message1 \
	      -in .param_spc_audace_calibreprofil -fill x -side top -pady 15
  }

      #--- Label + Entry pour X1
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.x1 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.x1.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,x1) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.x1.label -in .param_spc_audace_calibreprofil.x1 -side left -fill none
      #-- Partie Combobox
       #-height [ llength $listeabscisses ]
      ComboBox .param_spc_audace_calibreprofil.x1.combobox \
         -width 12          \
         -height 4  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,x1) \
         -values $listeabscisses
      pack  .param_spc_audace_calibreprofil.x1.combobox -in .param_spc_audace_calibreprofil.x1 -side right -fill none
      pack .param_spc_audace_calibreprofil.x1 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


     #--- Label + Entry pour lambda1

      #--- Cree l'affichage des sites lunaires du type choisi
      #scrollbar $frm.frame3.scrollbar -orient vertical -command [list $frm.frame3.lb1 yview] -takefocus 1 -borderwidth 1
      #pack $frm.frame3.scrollbar -side right -anchor ne -fill both
      #listbox $frm.frame3.lb1 -width 24 -height 40 -borderwidth 2 -relief sunken \
      #   -font $audace(font,listbox) -yscrollcommand [list $frm.frame3.scrollbar set]
      #pack $frm.frame3.lb1 -side right -anchor ne -fill both
      #set zone(list_site) $frm.frame3.lb1
      # obj_Lune_2::LitCataChoisi :
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.lambda1 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lambda1.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,lambda1) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.lambda1.label -in .param_spc_audace_calibreprofil.lambda1 -side left -fill none
      #-- Partie Combobox
       #-height [ llength $listelambdaschem ]
       #- On limite l'affichage de 30 longueurs d'onde, docn cr�ation automatique d'un ascenseur :
      ComboBox .param_spc_audace_calibreprofil.lambda1.combobox \
         -width 12          \
         -height 6  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,lambda1) \
         -values $listelambdaschem
      pack  .param_spc_audace_calibreprofil.lambda1.combobox -in .param_spc_audace_calibreprofil.lambda1 -side right -fill none
      pack .param_spc_audace_calibreprofil.lambda1 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


      #--- Label + Entry pour X2
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.x2 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.x2.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,x2) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.x2.label -in .param_spc_audace_calibreprofil.x2 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.x2.combobox \
         -width 12          \
         -height 4  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,x2) \
         -values $listeabscisses
      pack  .param_spc_audace_calibreprofil.x2.combobox -in .param_spc_audace_calibreprofil.x2 -side right -fill none
      pack .param_spc_audace_calibreprofil.x2 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12

      #--- Label + Entry pour lambda2
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.lambda2 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lambda2.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,lambda2) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.lambda2.label -in .param_spc_audace_calibreprofil.lambda2 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.lambda2.combobox \
         -width 12          \
         -height 6  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,lambda2) \
         -values $listelambdaschem
      pack  .param_spc_audace_calibreprofil.lambda2.combobox -in .param_spc_audace_calibreprofil.lambda2 -side right -fill none
      pack .param_spc_audace_calibreprofil.lambda2 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


      #--- Label + Entry pour X3
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.x3 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.x3.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,x3) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.x3.label -in .param_spc_audace_calibreprofil.x3 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.x3.combobox \
         -width 12          \
         -height 4  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,x3) \
         -values $listeabscisses
      pack  .param_spc_audace_calibreprofil.x3.combobox -in .param_spc_audace_calibreprofil.x3 -side right -fill none
      pack .param_spc_audace_calibreprofil.x3 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12

      #--- Label + Entry pour lambda3
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.lambda3 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lambda3.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,lambda3) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.lambda3.label -in .param_spc_audace_calibreprofil.lambda3 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.lambda3.combobox \
         -width 12          \
         -height 6  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,lambda3) \
         -values $listelambdaschem
      pack  .param_spc_audace_calibreprofil.lambda3.combobox -in .param_spc_audace_calibreprofil.lambda3 -side right -fill none
      pack .param_spc_audace_calibreprofil.lambda3 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


      #--- Label + Entry pour X4
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.x4 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.x4.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,x4) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.x4.label -in .param_spc_audace_calibreprofil.x4 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.x4.combobox \
         -width 12          \
         -height 4  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,x4) \
         -values $listeabscisses
      pack  .param_spc_audace_calibreprofil.x4.combobox -in .param_spc_audace_calibreprofil.x4 -side right -fill none
      pack .param_spc_audace_calibreprofil.x4 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12

      #--- Label + Entry pour lambda4
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.lambda4 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lambda4.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,lambda4) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.lambda4.label -in .param_spc_audace_calibreprofil.lambda4 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.lambda4.combobox \
         -width 12          \
         -height 6  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,lambda4) \
         -values $listelambdaschem
      pack  .param_spc_audace_calibreprofil.lambda4.combobox -in .param_spc_audace_calibreprofil.lambda4 -side right -fill none
      pack .param_spc_audace_calibreprofil.lambda4 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


      #--- Label + Entry pour X5
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.x5 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.x5.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,x5) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.x5.label -in .param_spc_audace_calibreprofil.x5 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.x5.combobox \
         -width 12          \
         -height 4  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,x5) \
         -values $listeabscisses
      pack  .param_spc_audace_calibreprofil.x5.combobox -in .param_spc_audace_calibreprofil.x5 -side right -fill none
      pack .param_spc_audace_calibreprofil.x5 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12

      #--- Label + Entry pour lambda5
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.lambda5 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lambda5.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,lambda5) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.lambda5.label -in .param_spc_audace_calibreprofil.lambda5 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.lambda5.combobox \
         -width 12          \
         -height 6  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,lambda5) \
         -values $listelambdaschem
      pack  .param_spc_audace_calibreprofil.lambda5.combobox -in .param_spc_audace_calibreprofil.lambda5 -side right -fill none
      pack .param_spc_audace_calibreprofil.lambda5 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


      #--- Label + Entry pour X6
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.x6 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.x6.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,x6) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.x6.label -in .param_spc_audace_calibreprofil.x6 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.x6.combobox \
         -width 12          \
         -height 4  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,x6) \
         -values $listeabscisses
      pack  .param_spc_audace_calibreprofil.x6.combobox -in .param_spc_audace_calibreprofil.x6 -side right -fill none
      pack .param_spc_audace_calibreprofil.x6 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12

      #--- Label + Entry pour lambda6
      #-- Partie Label
      frame .param_spc_audace_calibreprofil.lambda6 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,calibreprofil,color,backpad)
      label .param_spc_audace_calibreprofil.lambda6.label  \
	      -font $audace(param_spc_audace,calibreprofil,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,calibreprofil,config,lambda6) " -bg $audace(param_spc_audace,calibreprofil,color,backpad) \
	      -fg $audace(param_spc_audace,calibreprofil,color,textkey) -relief flat
      pack  .param_spc_audace_calibreprofil.lambda6.label -in .param_spc_audace_calibreprofil.lambda6 -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_calibreprofil.lambda6.combobox \
         -width 12          \
         -height 6  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -textvariable audace(param_spc_audace,calibreprofil,config,lambda6) \
         -values $listelambdaschem
      pack  .param_spc_audace_calibreprofil.lambda6.combobox -in .param_spc_audace_calibreprofil.lambda6 -side right -fill none
      pack .param_spc_audace_calibreprofil.lambda6 -in .param_spc_audace_calibreprofil -fill x -pady 1 -padx 12


  }


  proc go {} {
      global audace
      global caption
      global spcalibre

      ::param_spc_audace_calibreprofil::recup_conf
      #set spectre $audace(param_spc_audace,calibreprofil,config,spectre)
      set lampe $audace(param_spc_audace,calibreprofil,config,lampe)
      set x1 $audace(param_spc_audace,calibreprofil,config,x1)
      set lambda1 $audace(param_spc_audace,calibreprofil,config,lambda1)
      set x2 $audace(param_spc_audace,calibreprofil,config,x2)
      set lambda2 $audace(param_spc_audace,calibreprofil,config,lambda2)
      set x3 $audace(param_spc_audace,calibreprofil,config,x3)
      set lambda3 $audace(param_spc_audace,calibreprofil,config,lambda3)
      set x4 $audace(param_spc_audace,calibreprofil,config,x4)
      set lambda4 $audace(param_spc_audace,calibreprofil,config,lambda4)
      set x5 $audace(param_spc_audace,calibreprofil,config,x5)
      set lambda5 $audace(param_spc_audace,calibreprofil,config,lambda5)
      set x6 $audace(param_spc_audace,calibreprofil,config,x6)
      set lambda6 $audace(param_spc_audace,calibreprofil,config,lambda6)
      set listeargs [ list $lampe $x1 $lambda1 $x2 $lambda2 ]

      #--- Validation du format des longueurs d'onde :
      set listel [ list $lambda1 $lambda2 $lambda3 $lambda4 $lambda5 $lambda6 ]
      foreach lamb $listel {
	  if { [ llength $lamb ] < 2 } {
	      set lamb [ linsert $lamb 0 "l" ]
	  }
      }

      #--- Mise � vide des abscisses dont les lambda sont vides :
      set i 0
      set listex [ list $x1 $x2 $x3 $x4 $x5 $x6 ]

      #--- Tri des deux listes x et Lmabda et reaffectation :
      #-- Cr�ation de la liste contenant les couples (x,Lambda) :
      set doubleliste [ list ]
      foreach x $listex lamb $listel {
	  if { $lamb == "" } {
	      set x ""
	      lappend doubleliste [ list $x $lamb ]
	  } else {
	      set doubleliste [ linsert $doubleliste 0 [ list $x $lamb ] ]
	  }
      }

      #-- R�affectation et initialisation � "" des abscisses Xi non utilis�es :
      set i 1
      foreach couple $doubleliste {
	  set lambdaread [ lindex $couple 1 ]
	  if { $lambdaread != "" } {
	      set x$i [ lindex $couple 0 ]
	      set lambda$i $lambdaread
	  } else {
	      set x$i ""
	  }
	  incr i
      }


      #--- Extrait les longueurs d'onde de la ch�ne de caract�re :
      set i 1
      set lambdas [ list $lambda1 $lambda2 $lambda3 $lambda4 $lambda5 $lambda6 ]
      foreach lambda $lambdas {
	  set elements_lambda [ split $lambda ":" ]
	  if { [ llength $elements_lambda ] == 2 } {
	      set lambda$i [ lindex $elements_lambda 1 ]
	  } elseif { [ llength $elements_lambda ] == 0 } {
	      set lambda$i ""
	  } elseif { [ llength $elements_lambda ] == 1 } {
	      set lambda$i [ lindex $elements_lambda 0 ]
	  }
	  incr i
      }

      #--- Calibration associ�e au nombre de raies donn�es :
      if { $x1!="" && $x2!="" && $x3=="" } {
	  set spcalibre [ spc_calibre2 $lampe $x1 $lambda1 $x2 $lambda2 ]
	  destroy .param_spc_audace_calibreprofil
	  return $spcalibre
      } elseif { $x1!="" && $x2!="" && $x3!="" && $x4=="" } {
	  set spcalibre [ spc_calibren $lampe $x1 $lambda1 $x2 $lambda2 $x3 $lambda3 ]
	  destroy .param_spc_audace_calibreprofil
	  return $spcalibre
      } elseif { $x1!="" && $x2!="" && $x3!="" && $x4!="" && $x5=="" } {
	  set spcalibre [ spc_calibren $lampe $x1 $lambda1 $x2 $lambda2 $x3 $lambda3 $x4 $lambda4 ]
	  destroy .param_spc_audace_calibreprofil
	  return $spcalibre
      } elseif { $x1!="" && $x2!="" && $x3!="" && $x4!="" && $x5!="" && $x6=="" } {
	  set spcalibre [ spc_calibren $lampe $x1 $lambda1 $x2 $lambda2 $x3 $lambda3 $x4 $lambda4 $x5 $lambda5 ]
	  destroy .param_spc_audace_calibreprofil
	  return $spcalibre
      } elseif { $x1!="" && $x2!="" && $x3!="" && $x4!=""&& $x5!="" && $x6!=""  } {
	  set spcalibre [ spc_calibren $lampe $x1 $lambda1 $x2 $lambda2 $x3 $lambda3 $x4 $lambda4 $x5 $lambda5 $x6 $lambda6  ]
	  destroy .param_spc_audace_calibreprofil
	  return $spcalibre
      } else {
	  tk_messageBox -title $caption(spcaudace,gui,erreur,saisie) -icon error -message "Nombre de raies insufisant pour effectuer une calibration"
	  return 0
      }
  }

  proc annuler {} {
      global audace
      global caption
      global spcalibre
      ::param_spc_audace_calibreprofil::recup_conf
      destroy .param_spc_audace_calibreprofil
      set spcalibre ""
      return ""
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_calibreprofil ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_calibreprofil]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#



########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_traite2scalibre
# Intitul� : Traitement -> calibration (application � d'autres spectres)
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 23-09-06
# Utilis�e par : spc_traite2scalibre
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_profil_lampe methode_reg (reg, spc) methode_d�tection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_traite2scalibre {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      # global rep_spc_bib "$audace(rep_scripts)/spcaudace/data/bibliotheque_spectrale"

      set liste_methreg [ list "spc" "reg" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "e" "a" "n" ]
      set liste_smooth [ list "o" "n" ]
      set liste_on [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_traite2scalibre.* ] ] != "0" } {
         destroy .param_spc_audace_traite2scalibre
      }

      # === Initialisation des variables qui seront chang�es
      set audace(param_spc_audace,traite2scalibre,config,methreg) "spc"
      set audace(param_spc_audace,traite2scalibre,config,methsel) "large"
      set audace(param_spc_audace,traite2scalibre,config,methsky) "med"
      set audace(param_spc_audace,traite2scalibre,config,methbin) "rober"
      set audace(param_spc_audace,traite2scalibre,config,methinv) "o"
      set audace(param_spc_audace,traite2scalibre,config,methcos) "o"
      set audace(param_spc_audace,traite2scalibre,config,smooth) "n"
      set audace(param_spc_audace,traite2scalibre,config,norma) "n"
      set audace(param_spc_audace,traite2scalibre,config,offset) "none"
      set audace(param_spc_audace,traite2scalibre,config,ejbad) "o"
      set audace(param_spc_audace,traite2scalibre,config,ejtilt) "n"

      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,traite2scalibre,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traite2scalibre,color,backpad) #ECE9D8
      set audace(param_spc_audace,traite2scalibre,color,backdisp) $color(white)
      set audace(param_spc_audace,traite2scalibre,color,textdisp) #FF0000
      set audace(param_spc_audace,traite2scalibre,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,traite2scalibre,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_traite2scalibre de niveau le plus haut
      toplevel .param_spc_audace_traite2scalibre -class Toplevel -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      wm geometry .param_spc_audace_traite2scalibre 450x563+224-50
      wm resizable .param_spc_audace_traite2scalibre 1 1
      wm title .param_spc_audace_traite2scalibre $caption(spcaudace,metaboxes,traite2scalibre,titre)
      wm protocol .param_spc_audace_traite2scalibre WM_DELETE_WINDOW "::param_spc_audace_traite2scalibre::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traite2scalibre.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,traite2scalibre,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey)
      pack .param_spc_audace_traite2scalibre.title \
	      -in .param_spc_audace_traite2scalibre -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_traite2scalibre.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_traite2scalibre.stop_button  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,stop_button)" \
	      -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) \
	      -command {::param_spc_audace_traite2scalibre::annuler}
      pack  .param_spc_audace_traite2scalibre.stop_button -in .param_spc_audace_traite2scalibre.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_traite2scalibre.return_button  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,return_button)" \
	      -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) \
	      -command {::param_spc_audace_traite2scalibre::go}
      pack  .param_spc_audace_traite2scalibre.return_button -in .param_spc_audace_traite2scalibre.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_traite2scalibre.buttons -in .param_spc_audace_traite2scalibre -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour brut
      frame .param_spc_audace_traite2scalibre.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.brut.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,brut) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.brut.label -in .param_spc_audace_traite2scalibre.brut -side left -fill none
      entry  .param_spc_audace_traite2scalibre.brut.entry  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2scalibre,config,brut) -bg $audace(param_spc_audace,traite2scalibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2scalibre.brut.entry -in .param_spc_audace_traite2scalibre.brut -side left -fill none
      pack .param_spc_audace_traite2scalibre.brut -in .param_spc_audace_traite2scalibre -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_traite2scalibre.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.noir.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,noir) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.noir.label -in .param_spc_audace_traite2scalibre.noir -side left -fill none
      entry  .param_spc_audace_traite2scalibre.noir.entry  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2scalibre,config,noir) -bg $audace(param_spc_audace,traite2scalibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2scalibre.noir.entry -in .param_spc_audace_traite2scalibre.noir -side left -fill none
      pack .param_spc_audace_traite2scalibre.noir -in .param_spc_audace_traite2scalibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour plu
      frame .param_spc_audace_traite2scalibre.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.plu.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,plu) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.plu.label -in .param_spc_audace_traite2scalibre.plu -side left -fill none
      entry  .param_spc_audace_traite2scalibre.plu.entry  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2scalibre,config,plu) -bg $audace(param_spc_audace,traite2scalibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2scalibre.plu.entry -in .param_spc_audace_traite2scalibre.plu -side left -fill none
      pack .param_spc_audace_traite2scalibre.plu -in .param_spc_audace_traite2scalibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traite2scalibre.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.noirplu.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,noirplu) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.noirplu.label -in .param_spc_audace_traite2scalibre.noirplu -side left -fill none
      entry  .param_spc_audace_traite2scalibre.noirplu.entry  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2scalibre,config,noirplu) -bg $audace(param_spc_audace,traite2scalibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2scalibre.noirplu.entry -in .param_spc_audace_traite2scalibre.noirplu -side left -fill none
      pack .param_spc_audace_traite2scalibre.noirplu -in .param_spc_audace_traite2scalibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      frame .param_spc_audace_traite2scalibre.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.offset.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,offset) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.offset.label -in .param_spc_audace_traite2scalibre.offset -side left -fill none
      entry  .param_spc_audace_traite2scalibre.offset.entry  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2scalibre,config,offset) -bg $audace(param_spc_audace,traite2scalibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2scalibre.offset.entry -in .param_spc_audace_traite2scalibre.offset -side left -fill none
      pack .param_spc_audace_traite2scalibre.offset -in .param_spc_audace_traite2scalibre -fill none -pady 1 -padx 12

      #--- Label + Entry pour lampe
      frame .param_spc_audace_traite2scalibre.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.lampe.label -text "$caption(spcaudace,metaboxes,traite2scalibre,config,lampe)" -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b)
      pack  .param_spc_audace_traite2scalibre.lampe.label -in .param_spc_audace_traite2scalibre.lampe -side left -fill none
      button .param_spc_audace_traite2scalibre.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -command { set audace(param_spc_audace,traite2scalibre,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traite2scalibre.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2scalibre.lampe.entry  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2scalibre,config,lampe) -bg $audace(param_spc_audace,traite2scalibre,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2scalibre.lampe.entry -in .param_spc_audace_traite2scalibre.lampe -side left -fill none
      pack .param_spc_audace_traite2scalibre.lampe -in .param_spc_audace_traite2scalibre -fill none -pady 1 -padx 12



      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.methreg.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,methreg) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.methreg.label -in .param_spc_audace_traite2scalibre.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_traite2scalibre.methreg.combobox -in .param_spc_audace_traite2scalibre.methreg -side right -fill none
      pack .param_spc_audace_traite2scalibre.methreg -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.methcos.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,methcos) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.methcos.label -in .param_spc_audace_traite2scalibre.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_traite2scalibre.methcos.combobox -in .param_spc_audace_traite2scalibre.methcos -side right -fill none
      pack .param_spc_audace_traite2scalibre.methcos -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.methsel.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,methsel) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.methsel.label -in .param_spc_audace_traite2scalibre.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_traite2scalibre.methsel.combobox -in .param_spc_audace_traite2scalibre.methsel -side right -fill none
      pack .param_spc_audace_traite2scalibre.methsel -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.methsky.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,methsky) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.methsky.label -in .param_spc_audace_traite2scalibre.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_traite2scalibre.methsky.combobox -in .param_spc_audace_traite2scalibre.methsky -side right -fill none
      pack .param_spc_audace_traite2scalibre.methsky -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.methbin.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,methbin) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.methbin.label -in .param_spc_audace_traite2scalibre.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_traite2scalibre.methbin.combobox -in .param_spc_audace_traite2scalibre.methbin -side right -fill none
      pack .param_spc_audace_traite2scalibre.methbin -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.methinv.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,methinv) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.methinv.label -in .param_spc_audace_traite2scalibre.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_traite2scalibre.methinv.combobox -in .param_spc_audace_traite2scalibre.methinv -side right -fill none
      pack .param_spc_audace_traite2scalibre.methinv -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour norma
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.norma -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.norma.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,norma) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.norma.label -in .param_spc_audace_traite2scalibre.norma -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.norma.combobox \
         -width 7          \
         -height [ llength $liste_norma ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,norma) \
         -values $liste_norma
      pack  .param_spc_audace_traite2scalibre.norma.combobox -in .param_spc_audace_traite2scalibre.norma -side right -fill none
      pack .param_spc_audace_traite2scalibre.norma -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.smooth.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,smooth) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.smooth.label -in .param_spc_audace_traite2scalibre.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_traite2scalibre.smooth.combobox -in .param_spc_audace_traite2scalibre.smooth -side right -fill none
      pack .param_spc_audace_traite2scalibre.smooth -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour ejbad
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.ejbad -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.ejbad.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,ejbad) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.ejbad.label -in .param_spc_audace_traite2scalibre.ejbad -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.ejbad.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,ejbad) \
         -values $liste_on
      pack  .param_spc_audace_traite2scalibre.ejbad.combobox -in .param_spc_audace_traite2scalibre.ejbad -side right -fill none
      pack .param_spc_audace_traite2scalibre.ejbad -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12

      #--- Label + Entry pour ejtilt
      #-- Partie Label
      frame .param_spc_audace_traite2scalibre.ejtilt -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2scalibre,color,backpad)
      label .param_spc_audace_traite2scalibre.ejtilt.label  \
	      -font $audace(param_spc_audace,traite2scalibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2scalibre,config,ejtilt) " -bg $audace(param_spc_audace,traite2scalibre,color,backpad) \
	      -fg $audace(param_spc_audace,traite2scalibre,color,textkey) -relief flat
      pack  .param_spc_audace_traite2scalibre.ejtilt.label -in .param_spc_audace_traite2scalibre.ejtilt -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2scalibre.ejtilt.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2scalibre,config,ejtilt) \
         -values $liste_on
      pack  .param_spc_audace_traite2scalibre.ejtilt.combobox -in .param_spc_audace_traite2scalibre.ejtilt -side right -fill none
      pack .param_spc_audace_traite2scalibre.ejtilt -in .param_spc_audace_traite2scalibre -fill x -pady 1 -padx 12


  }


  proc go {} {
      global audace
      global caption

      ::param_spc_audace_traite2scalibre::recup_conf
      set brut $audace(param_spc_audace,traite2scalibre,config,brut)
      set noir $audace(param_spc_audace,traite2scalibre,config,noir)
      set plu $audace(param_spc_audace,traite2scalibre,config,plu)
      set noirplu $audace(param_spc_audace,traite2scalibre,config,noirplu)
      set offset $audace(param_spc_audace,traite2scalibre,config,offset)
      set lampe $audace(param_spc_audace,traite2scalibre,config,lampe)
      set methreg $audace(param_spc_audace,traite2scalibre,config,methreg)
      set methcos $audace(param_spc_audace,traite2scalibre,config,methcos)
      set methsel $audace(param_spc_audace,traite2scalibre,config,methsel)
      set methsky $audace(param_spc_audace,traite2scalibre,config,methsky)
      set methbin $audace(param_spc_audace,traite2scalibre,config,methbin)
      set methinv $audace(param_spc_audace,traite2scalibre,config,methinv)
      set methnorma $audace(param_spc_audace,traite2scalibre,config,norma)
      set methsmo $audace(param_spc_audace,traite2scalibre,config,smooth)
      set ejbad $audace(param_spc_audace,traite2scalibre,config,ejbad)
      set ejtilt $audace(param_spc_audace,traite2scalibre,config,ejtilt)
      set listeargs [ list $brut $noir $plu $noirplu $offset $lampe $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt ]

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set fileout [ spc_traite2scalibre $brut $noir $plu $noirplu $offset $lampe $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt ]
	  destroy .param_spc_audace_traite2scalibre
	  return $fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_traite2scalibre::recup_conf
      destroy .param_spc_audace_traite2scalibre
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_traite2scalibre ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_traite2scalibre]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#




########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_traite2calibre
# Intitul� : Pr�traitement -> calibration
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 28-02-2007
# Date de modification : 28-02-2002
# Utilis�e par : spc_traite2calibre
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu offset nom_spectre_lampe methode_d�tection_spectre (large, serre) methode_binning (add, rober, horne) methmasters (o/n)
#        $brut $noir $plu $noirplu $offset $lampe $methcos $methsel $methinv $methbin $methraie
########################################################################

namespace eval ::param_spc_audace_lampe2calibre {

   proc run { {positionxy 20+20} } {
      global conf
      global audace spcaudace
      global caption
      global color


      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_on [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_lampe2calibre.* ] ] != "0" } {
         destroy .param_spc_audace_lampe2calibre
      }

      # === Initialisation des variables qui seront chang�es
      set audace(param_spc_audace,lampe2calibre,config,methsel) "serre"
      set audace(param_spc_audace,lampe2calibre,config,methsky) "med"
      set audace(param_spc_audace,lampe2calibre,config,methbin) "rober"
      set audace(param_spc_audace,lampe2calibre,config,methinv) "n"
      set audace(param_spc_audace,lampe2calibre,config,methcos) "n"
      set audace(param_spc_audace,lampe2calibre,config,offset) "none"
      set audace(param_spc_audace,lampe2calibre,config,methraie) "n"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,lampe2calibre,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,lampe2calibre,color,backpad) #ECE9D8
      set audace(param_spc_audace,lampe2calibre,color,backdisp) $color(white)
      set audace(param_spc_audace,lampe2calibre,color,textdisp) #FF0000
      set audace(param_spc_audace,lampe2calibre,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,lampe2calibre,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_lampe2calibre de niveau le plus haut
      toplevel .param_spc_audace_lampe2calibre -class Toplevel -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      # wm geometry .param_spc_audace_lampe2calibre 450x630+10+10
      # wm geometry .param_spc_audace_lampe2calibre 450x276+10+10
      wm geometry .param_spc_audace_lampe2calibre 450x276+65-3
      wm resizable .param_spc_audace_lampe2calibre 1 1
      wm title .param_spc_audace_lampe2calibre $caption(spcaudace,metaboxes,lampe2calibre,titre)
      wm protocol .param_spc_audace_lampe2calibre WM_DELETE_WINDOW "::param_spc_audace_lampe2calibre::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_lampe2calibre.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,lampe2calibre,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey)
      pack .param_spc_audace_lampe2calibre.title \
	      -in .param_spc_audace_lampe2calibre -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_lampe2calibre.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_lampe2calibre.stop_button  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,stop_button)" \
	      -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) \
	      -command {::param_spc_audace_lampe2calibre::annuler}
      pack  .param_spc_audace_lampe2calibre.stop_button -in .param_spc_audace_lampe2calibre.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_lampe2calibre.return_button  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,return_button)" \
	      -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) \
	      -command {::param_spc_audace_lampe2calibre::go}
      pack  .param_spc_audace_lampe2calibre.return_button -in .param_spc_audace_lampe2calibre.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_lampe2calibre.buttons -in .param_spc_audace_lampe2calibre -fill x -pady 0 -padx 0 -anchor s -side bottom



      #--- Label + Entry pour lampe
      frame .param_spc_audace_lampe2calibre.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.lampe.label -text "$caption(spcaudace,metaboxes,lampe2calibre,config,lampe)" -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b)
      pack  .param_spc_audace_lampe2calibre.lampe.label -in .param_spc_audace_lampe2calibre.lampe -side left -fill none
      button .param_spc_audace_lampe2calibre.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -command { set audace(param_spc_audace,lampe2calibre,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_lampe2calibre.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_lampe2calibre.lampe.entry  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,lampe2calibre,config,lampe) -bg $audace(param_spc_audace,lampe2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_lampe2calibre.lampe.entry -in .param_spc_audace_lampe2calibre.lampe -side left -fill none
      pack .param_spc_audace_lampe2calibre.lampe -in .param_spc_audace_lampe2calibre -fill none -pady 1 -padx 12



      #--- Label + Entry pour brut
      frame .param_spc_audace_lampe2calibre.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.brut.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,brut) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.brut.label -in .param_spc_audace_lampe2calibre.brut -side left -fill none
      entry  .param_spc_audace_lampe2calibre.brut.entry  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,lampe2calibre,config,brut) -bg $audace(param_spc_audace,lampe2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_lampe2calibre.brut.entry -in .param_spc_audace_lampe2calibre.brut -side left -fill none
      pack .param_spc_audace_lampe2calibre.brut -in .param_spc_audace_lampe2calibre -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_lampe2calibre.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.noir.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,noir) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.noir.label -in .param_spc_audace_lampe2calibre.noir -side left -fill none
      entry  .param_spc_audace_lampe2calibre.noir.entry  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,lampe2calibre,config,noir) -bg $audace(param_spc_audace,lampe2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_lampe2calibre.noir.entry -in .param_spc_audace_lampe2calibre.noir -side left -fill none
      pack .param_spc_audace_lampe2calibre.noir -in .param_spc_audace_lampe2calibre -fill none -pady 1 -padx 12


if { 1==0 } {
      #--- Label + Entry pour plu
      frame .param_spc_audace_lampe2calibre.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.plu.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,plu) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.plu.label -in .param_spc_audace_lampe2calibre.plu -side left -fill none
      entry  .param_spc_audace_lampe2calibre.plu.entry  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,lampe2calibre,config,plu) -bg $audace(param_spc_audace,lampe2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_lampe2calibre.plu.entry -in .param_spc_audace_lampe2calibre.plu -side left -fill none
      pack .param_spc_audace_lampe2calibre.plu -in .param_spc_audace_lampe2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_lampe2calibre.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.noirplu.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,noirplu) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.noirplu.label -in .param_spc_audace_lampe2calibre.noirplu -side left -fill none
      entry  .param_spc_audace_lampe2calibre.noirplu.entry  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,lampe2calibre,config,noirplu) -bg $audace(param_spc_audace,lampe2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_lampe2calibre.noirplu.entry -in .param_spc_audace_lampe2calibre.noirplu -side left -fill none
      pack .param_spc_audace_lampe2calibre.noirplu -in .param_spc_audace_lampe2calibre -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      if { 0==1 } {
      frame .param_spc_audace_lampe2calibre.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.offset.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,offset) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.offset.label -in .param_spc_audace_lampe2calibre.offset -side left -fill none
      entry  .param_spc_audace_lampe2calibre.offset.entry  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -textvariable audace(param_spc_audace,lampe2calibre,config,offset) -bg $audace(param_spc_audace,lampe2calibre,color,backdisp) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_lampe2calibre.offset.entry -in .param_spc_audace_lampe2calibre.offset -side left -fill none
      pack .param_spc_audace_lampe2calibre.offset -in .param_spc_audace_lampe2calibre -fill none -pady 1 -padx 12
       }
}

      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_lampe2calibre.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.methcos.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,methcos) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.methcos.label -in .param_spc_audace_lampe2calibre.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_lampe2calibre.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,lampe2calibre,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_lampe2calibre.methcos.combobox -in .param_spc_audace_lampe2calibre.methcos -side right -fill none
      pack .param_spc_audace_lampe2calibre.methcos -in .param_spc_audace_lampe2calibre -fill x -pady 1 -padx 12


       if { 1==0 } {
      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_lampe2calibre.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.methsel.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,methsel) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.methsel.label -in .param_spc_audace_lampe2calibre.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_lampe2calibre.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,lampe2calibre,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_lampe2calibre.methsel.combobox -in .param_spc_audace_lampe2calibre.methsel -side right -fill none
      pack .param_spc_audace_lampe2calibre.methsel -in .param_spc_audace_lampe2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_lampe2calibre.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.methbin.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,methbin) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.methbin.label -in .param_spc_audace_lampe2calibre.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_lampe2calibre.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,lampe2calibre,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_lampe2calibre.methbin.combobox -in .param_spc_audace_lampe2calibre.methbin -side right -fill none
      pack .param_spc_audace_lampe2calibre.methbin -in .param_spc_audace_lampe2calibre -fill x -pady 1 -padx 12
      }


      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_lampe2calibre.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.methinv.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,methinv) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.methinv.label -in .param_spc_audace_lampe2calibre.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_lampe2calibre.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,lampe2calibre,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_lampe2calibre.methinv.combobox -in .param_spc_audace_lampe2calibre.methinv -side right -fill none
      pack .param_spc_audace_lampe2calibre.methinv -in .param_spc_audace_lampe2calibre -fill x -pady 1 -padx 12


      #--- Label + Entry pour methraie
      #-- Partie Label
      frame .param_spc_audace_lampe2calibre.methraie -borderwidth 0 -relief flat -bg $audace(param_spc_audace,lampe2calibre,color,backpad)
      label .param_spc_audace_lampe2calibre.methraie.label  \
	      -font $audace(param_spc_audace,lampe2calibre,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,lampe2calibre,config,methraie) " -bg $audace(param_spc_audace,lampe2calibre,color,backpad) \
	      -fg $audace(param_spc_audace,lampe2calibre,color,textkey) -relief flat
      pack  .param_spc_audace_lampe2calibre.methraie.label -in .param_spc_audace_lampe2calibre.methraie -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_lampe2calibre.methraie.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,lampe2calibre,config,methraie) \
         -values $liste_on
      pack  .param_spc_audace_lampe2calibre.methraie.combobox -in .param_spc_audace_lampe2calibre.methraie -side right -fill none
      pack .param_spc_audace_lampe2calibre.methraie -in .param_spc_audace_lampe2calibre -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace
      global caption

      ::param_spc_audace_lampe2calibre::recup_conf
      set lampe $audace(param_spc_audace,lampe2calibre,config,lampe)
      set brut $audace(param_spc_audace,lampe2calibre,config,brut)
      set noir $audace(param_spc_audace,lampe2calibre,config,noir)
      #set plu $audace(param_spc_audace,lampe2calibre,config,plu)
      #set noirplu $audace(param_spc_audace,lampe2calibre,config,noirplu)
      #set offset $audace(param_spc_audace,lampe2calibre,config,offset)
      set methcos $audace(param_spc_audace,lampe2calibre,config,methcos)
      set methsel $audace(param_spc_audace,lampe2calibre,config,methsel)
      set methbin $audace(param_spc_audace,lampe2calibre,config,methbin)
      set methinv $audace(param_spc_audace,lampe2calibre,config,methinv)
      set methraie $audace(param_spc_audace,lampe2calibre,config,methraie)
      set listeargs [ list $brut $noir $lampe $methcos $methsel $methinv $methbin $methraie ]

      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont != "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set lampe2calibre_fileout [ spc_lampe2calibre $lampe $brut $noir $methcos $methsel $methinv $methbin $methraie ]
	  destroy .param_spc_audace_lampe2calibre
	  return $lampe2calibre_fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_lampe2calibre::recup_conf
      destroy .param_spc_audace_lampe2calibre
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_lampe2calibre ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_lampe2calibre]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#




########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_traite2rinstrum
# Intitul� : Traitement -> r�ponse instrumentale
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 14-08-2006
# Utilis�e par : spc_traite2rinstrum
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_d�tection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_traite2rinstrum {

   proc run { {positionxy 20+20} } {
      global conf
      global audace spcaudace
      global caption
      global color


      set liste_methreg [ list "spc" "reg" "n" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "e" "a" "n" ]
      set liste_smooth [ list "o" "n" ]
      set liste_on [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_traite2rinstrum.* ] ] != "0" } {
         destroy .param_spc_audace_traite2rinstrum
      }

      # === Initialisation des variables qui seront chang�es
      set audace(param_spc_audace,traite2rinstrum,config,offset) "none"
      set audace(param_spc_audace,traite2rinstrum,config,methreg) "spc"
      set audace(param_spc_audace,traite2rinstrum,config,methsel) "serre"
      set audace(param_spc_audace,traite2rinstrum,config,methsky) "med"
      set audace(param_spc_audace,traite2rinstrum,config,methbin) "rober"
      set audace(param_spc_audace,traite2rinstrum,config,methinv) "n"
      set audace(param_spc_audace,traite2rinstrum,config,methcos) "n"
      set audace(param_spc_audace,traite2rinstrum,config,smooth) "n"
      set audace(param_spc_audace,traite2rinstrum,config,norma) "n"
      set audace(param_spc_audace,traite2rinstrum,config,ejbad) "n"
      set audace(param_spc_audace,traite2rinstrum,config,ejtilt) "n"
      set audace(param_spc_audace,traite2rinstrum,config,methraie) "n"
      set audace(param_spc_audace,traite2rinstrum,config,methmasters) "o"
      set audace(param_spc_audace,traite2rinstrum,config,methcalo) "o"

      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,traite2rinstrum,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traite2rinstrum,color,backpad) #ECE9D8
      set audace(param_spc_audace,traite2rinstrum,color,backdisp) $color(white)
      set audace(param_spc_audace,traite2rinstrum,color,textdisp) #FF0000
      set audace(param_spc_audace,traite2rinstrum,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,traite2rinstrum,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_traite2rinstrum de niveau le plus haut
      toplevel .param_spc_audace_traite2rinstrum -class Toplevel -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      # wm geometry .param_spc_audace_traite2rinstrum 450x586+144-5
      wm geometry .param_spc_audace_traite2rinstrum 450x643+150-20
      wm resizable .param_spc_audace_traite2rinstrum 1 1
      wm title .param_spc_audace_traite2rinstrum $caption(spcaudace,metaboxes,traite2rinstrum,titre)
      wm protocol .param_spc_audace_traite2rinstrum WM_DELETE_WINDOW "::param_spc_audace_traite2rinstrum::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traite2rinstrum.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,traite2rinstrum,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey)
      pack .param_spc_audace_traite2rinstrum.title \
	      -in .param_spc_audace_traite2rinstrum -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_traite2rinstrum.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_traite2rinstrum.stop_button  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,stop_button)" \
	      -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) \
	      -command {::param_spc_audace_traite2rinstrum::annuler}
      pack  .param_spc_audace_traite2rinstrum.stop_button -in .param_spc_audace_traite2rinstrum.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_traite2rinstrum.return_button  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,return_button)" \
	      -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) \
	      -command {::param_spc_audace_traite2rinstrum::go}
      pack  .param_spc_audace_traite2rinstrum.return_button -in .param_spc_audace_traite2rinstrum.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_traite2rinstrum.buttons -in .param_spc_audace_traite2rinstrum -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour brut
      frame .param_spc_audace_traite2rinstrum.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.brut.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,brut) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.brut.label -in .param_spc_audace_traite2rinstrum.brut -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.brut.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,brut) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.brut.entry -in .param_spc_audace_traite2rinstrum.brut -side left -fill none
      pack .param_spc_audace_traite2rinstrum.brut -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_traite2rinstrum.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.noir.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,noir) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.noir.label -in .param_spc_audace_traite2rinstrum.noir -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.noir.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,noir) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.noir.entry -in .param_spc_audace_traite2rinstrum.noir -side left -fill none
      pack .param_spc_audace_traite2rinstrum.noir -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour plu
      frame .param_spc_audace_traite2rinstrum.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.plu.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,plu) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.plu.label -in .param_spc_audace_traite2rinstrum.plu -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.plu.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,plu) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.plu.entry -in .param_spc_audace_traite2rinstrum.plu -side left -fill none
      pack .param_spc_audace_traite2rinstrum.plu -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traite2rinstrum.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.noirplu.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,noirplu) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.noirplu.label -in .param_spc_audace_traite2rinstrum.noirplu -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.noirplu.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,noirplu) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.noirplu.entry -in .param_spc_audace_traite2rinstrum.noirplu -side left -fill none
      pack .param_spc_audace_traite2rinstrum.noirplu -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      frame .param_spc_audace_traite2rinstrum.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.offset.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,offset) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.offset.label -in .param_spc_audace_traite2rinstrum.offset -side left -fill none
      entry  .param_spc_audace_traite2rinstrum.offset.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,offset) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.offset.entry -in .param_spc_audace_traite2rinstrum.offset -side left -fill none
      pack .param_spc_audace_traite2rinstrum.offset -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour lampe
      frame .param_spc_audace_traite2rinstrum.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.lampe.label -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,lampe)" -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b)
      pack  .param_spc_audace_traite2rinstrum.lampe.label -in .param_spc_audace_traite2rinstrum.lampe -side left -fill none
      button .param_spc_audace_traite2rinstrum.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,traite2rinstrum,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traite2rinstrum.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2rinstrum.lampe.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,lampe) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.lampe.entry -in .param_spc_audace_traite2rinstrum.lampe -side left -fill none
      pack .param_spc_audace_traite2rinstrum.lampe -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12

   set flag 0
   if { $flag==1 } {
      #--- Label + Entry pour etoile_ref
      frame .param_spc_audace_traite2rinstrum.etoile_ref -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.etoile_ref.label -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,etoile_ref)" -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b)
      pack  .param_spc_audace_traite2rinstrum.etoile_ref.label -in .param_spc_audace_traite2rinstrum.etoile_ref -side left -fill none
      button .param_spc_audace_traite2rinstrum.etoile_ref.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,traite2rinstrum,config,etoile_ref) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traite2rinstrum.etoile_ref.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2rinstrum.etoile_ref.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,etoile_ref) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.etoile_ref.entry -in .param_spc_audace_traite2rinstrum.etoile_ref -side left -fill none
      pack .param_spc_audace_traite2rinstrum.etoile_ref -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12
  }

      #--- Label + Entry pour etoile_cat
      frame .param_spc_audace_traite2rinstrum.etoile_cat -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.etoile_cat.label -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,etoile_cat)" -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b)
      pack  .param_spc_audace_traite2rinstrum.etoile_cat.label -in .param_spc_audace_traite2rinstrum.etoile_cat -side left -fill none
      button .param_spc_audace_traite2rinstrum.etoile_cat.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,traite2rinstrum,config,etoile_cat) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $spcaudace(rep_spcbib) ] ] }
      pack .param_spc_audace_traite2rinstrum.etoile_cat.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2rinstrum.etoile_cat.entry  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2rinstrum,config,etoile_cat) -bg $audace(param_spc_audace,traite2rinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2rinstrum.etoile_cat.entry -in .param_spc_audace_traite2rinstrum.etoile_cat -side left -fill none
      pack .param_spc_audace_traite2rinstrum.etoile_cat -in .param_spc_audace_traite2rinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour methmasters
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methmasters -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methmasters.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methmasters) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methmasters.label -in .param_spc_audace_traite2rinstrum.methmasters -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methmasters.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methmasters) \
         -values $liste_on
      pack  .param_spc_audace_traite2rinstrum.methmasters.combobox -in .param_spc_audace_traite2rinstrum.methmasters -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methmasters -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methinv.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methinv) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methinv.label -in .param_spc_audace_traite2rinstrum.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_traite2rinstrum.methinv.combobox -in .param_spc_audace_traite2rinstrum.methinv -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methinv -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcalo
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methcalo -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methcalo.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methcalo) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methcalo.label -in .param_spc_audace_traite2rinstrum.methcalo -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methcalo.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methcalo) \
         -values $liste_on
      pack  .param_spc_audace_traite2rinstrum.methcalo.combobox -in .param_spc_audace_traite2rinstrum.methcalo -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methcalo -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methreg.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methreg) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methreg.label -in .param_spc_audace_traite2rinstrum.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_traite2rinstrum.methreg.combobox -in .param_spc_audace_traite2rinstrum.methreg -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methreg -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methcos.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methcos) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methcos.label -in .param_spc_audace_traite2rinstrum.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_traite2rinstrum.methcos.combobox -in .param_spc_audace_traite2rinstrum.methcos -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methcos -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methsel.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methsel) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methsel.label -in .param_spc_audace_traite2rinstrum.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_traite2rinstrum.methsel.combobox -in .param_spc_audace_traite2rinstrum.methsel -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methsel -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methsky.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methsky) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methsky.label -in .param_spc_audace_traite2rinstrum.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_traite2rinstrum.methsky.combobox -in .param_spc_audace_traite2rinstrum.methsky -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methsky -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methbin.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methbin) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methbin.label -in .param_spc_audace_traite2rinstrum.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_traite2rinstrum.methbin.combobox -in .param_spc_audace_traite2rinstrum.methbin -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methbin -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12





      #--- Label + Entry pour ejbad
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.ejbad -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.ejbad.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,ejbad) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.ejbad.label -in .param_spc_audace_traite2rinstrum.ejbad -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.ejbad.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,ejbad) \
         -values $liste_on
      pack  .param_spc_audace_traite2rinstrum.ejbad.combobox -in .param_spc_audace_traite2rinstrum.ejbad -side right -fill none
      pack .param_spc_audace_traite2rinstrum.ejbad -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12

       if { 1==0 } {
      #--- Label + Entry pour ejtilt
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.ejtilt -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.ejtilt.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,ejtilt) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.ejtilt.label -in .param_spc_audace_traite2rinstrum.ejtilt -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.ejtilt.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,ejtilt) \
         -values $liste_on
      pack  .param_spc_audace_traite2rinstrum.ejtilt.combobox -in .param_spc_audace_traite2rinstrum.ejtilt -side right -fill none
      pack .param_spc_audace_traite2rinstrum.ejtilt -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12
   }


      #--- Label + Entry pour methraie
      #-- Partie Label
      frame .param_spc_audace_traite2rinstrum.methraie -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad)
      label .param_spc_audace_traite2rinstrum.methraie.label  \
	      -font $audace(param_spc_audace,traite2rinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2rinstrum,config,methraie) " -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2rinstrum.methraie.label -in .param_spc_audace_traite2rinstrum.methraie -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2rinstrum.methraie.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2rinstrum,config,methraie) \
         -values $liste_on
      pack  .param_spc_audace_traite2rinstrum.methraie.combobox -in .param_spc_audace_traite2rinstrum.methraie -side right -fill none
      pack .param_spc_audace_traite2rinstrum.methraie -in .param_spc_audace_traite2rinstrum -fill x -pady 1 -padx 12


      #--- Message sur les r�ponses intrumentales :
      label .param_spc_audace_traite2rinstrum.message1 \
	      -font [ list {Arial} 12 bold ] -text "$caption(spcaudace,metaboxes,traite2rinstrum,desc_results) " \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2rinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2rinstrum,color,textkey)
      pack .param_spc_audace_traite2rinstrum.message1 \
	      -in .param_spc_audace_traite2rinstrum -fill x -side top -pady 15



  }


  proc go {} {
      global audace
      global caption

      ::param_spc_audace_traite2rinstrum::recup_conf
      set brut $audace(param_spc_audace,traite2rinstrum,config,brut)
      set noir $audace(param_spc_audace,traite2rinstrum,config,noir)
      set plu $audace(param_spc_audace,traite2rinstrum,config,plu)
      set noirplu $audace(param_spc_audace,traite2rinstrum,config,noirplu)
      set offset $audace(param_spc_audace,traite2rinstrum,config,offset)
      set lampe $audace(param_spc_audace,traite2rinstrum,config,lampe)
      # set etoile_ref $audace(param_spc_audace,traite2rinstrum,config,etoile_ref)
      set etoile_cat $audace(param_spc_audace,traite2rinstrum,config,etoile_cat)
      set methreg $audace(param_spc_audace,traite2rinstrum,config,methreg)
      set methcos $audace(param_spc_audace,traite2rinstrum,config,methcos)
      set methsel $audace(param_spc_audace,traite2rinstrum,config,methsel)
      set methsky $audace(param_spc_audace,traite2rinstrum,config,methsky)
      set methbin $audace(param_spc_audace,traite2rinstrum,config,methbin)
      set methinv $audace(param_spc_audace,traite2rinstrum,config,methinv)
      set methcalo $audace(param_spc_audace,traite2rinstrum,config,methcalo)
      set methnorma $audace(param_spc_audace,traite2rinstrum,config,norma)
      set methsmo $audace(param_spc_audace,traite2rinstrum,config,smooth)
      set methejbad $audace(param_spc_audace,traite2rinstrum,config,ejbad)
      set methejtilt $audace(param_spc_audace,traite2rinstrum,config,ejtilt)
      set methraie $audace(param_spc_audace,traite2rinstrum,config,methraie)
      set methmasters $audace(param_spc_audace,traite2rinstrum,config,methmasters)
      set listeargs [ list $brut $noir $plu $noirplu $offset $lampe $etoile_cat $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $methejbad $methejtilt $methraie $methmasters $methcalo ]



      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont != "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  #-- Test si le fichier "lampe" est bien calibr� :
	  set flag_calibration [ spc_testcalibre "$lampe" ]
	  if { $flag_calibration != -1 } {
	      set fileout [ spc_traite2rinstrum $brut $noir $plu $noirplu $offset $lampe $etoile_cat $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $methejbad $methejtilt $methraie $methmasters $flag_calibration $methcalo ]
	      destroy .param_spc_audace_traite2rinstrum
	      return $fileout
	  }
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_traite2rinstrum::recup_conf
      destroy .param_spc_audace_traite2rinstrum
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_traite2rinstrum ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_traite2rinstrum]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#




########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_traite2srinstrum
# Intitul� : Traitement -> correction r�ponse instrumentale (application � d'autres spectres)
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 14-07-2006
# Date de modification : 28-08-2006/23-09-06
# Utilis�e par : spc_traite2rinstrum
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe reponse_instrumentale methode_reg (reg, spc) methode_d�tection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

namespace eval ::param_spc_audace_traite2srinstrum {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      set liste_methreg [ list "spc" "reg" "n" ]
      set liste_methcos [ list "o" "n" ]
      set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "o" "e" "a" "n" ]
      set liste_smooth [ list "o" "n" ]
      set liste_on [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_traite2srinstrum.* ] ] != "0" } {
         destroy .param_spc_audace_traite2srinstrum
      }

      # === Initialisation des variables qui seront chang�es
      #- set audace(param_spc_audace,traite2srinstrum,config,rinstrum) "none"
      set audace(param_spc_audace,traite2srinstrum,config,offset) "none"
      set audace(param_spc_audace,traite2srinstrum,config,methreg) "spc"
      set audace(param_spc_audace,traite2srinstrum,config,methsel) "serre"
      set audace(param_spc_audace,traite2srinstrum,config,methsky) "med"
      set audace(param_spc_audace,traite2srinstrum,config,methbin) "rober"
      set audace(param_spc_audace,traite2srinstrum,config,methinv) "n"
      set audace(param_spc_audace,traite2srinstrum,config,methcos) "n"
      set audace(param_spc_audace,traite2srinstrum,config,smooth) "n"
      set audace(param_spc_audace,traite2srinstrum,config,norma) "n"
      set audace(param_spc_audace,traite2srinstrum,config,ejbad) "n"
      set audace(param_spc_audace,traite2srinstrum,config,ejtilt) "n"
      set audace(param_spc_audace,traite2srinstrum,config,methmasters) "o"
      set audace(param_spc_audace,traite2srinstrum,config,export_png) "n"

      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,traite2srinstrum,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traite2srinstrum,color,backpad) #ECE9D8
      set audace(param_spc_audace,traite2srinstrum,color,backdisp) $color(white)
      set audace(param_spc_audace,traite2srinstrum,color,textdisp) #FF0000
      set audace(param_spc_audace,traite2srinstrum,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,traite2srinstrum,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_traite2srinstrum de niveau le plus haut
      toplevel .param_spc_audace_traite2srinstrum -class Toplevel -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      wm geometry .param_spc_audace_traite2srinstrum 450x592+150-15
      wm resizable .param_spc_audace_traite2srinstrum 1 1
      wm title .param_spc_audace_traite2srinstrum $caption(spcaudace,metaboxes,traite2srinstrum,titre)
      wm protocol .param_spc_audace_traite2srinstrum WM_DELETE_WINDOW "::param_spc_audace_traite2srinstrum::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traite2srinstrum.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,traite2srinstrum,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey)
      pack .param_spc_audace_traite2srinstrum.title \
	      -in .param_spc_audace_traite2srinstrum -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_traite2srinstrum.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_traite2srinstrum.stop_button  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,stop_button)" \
	      -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) \
	      -command {::param_spc_audace_traite2srinstrum::annuler}
      pack  .param_spc_audace_traite2srinstrum.stop_button -in .param_spc_audace_traite2srinstrum.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_traite2srinstrum.return_button  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,return_button)" \
	      -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) \
	      -command {::param_spc_audace_traite2srinstrum::go}
      pack  .param_spc_audace_traite2srinstrum.return_button -in .param_spc_audace_traite2srinstrum.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_traite2srinstrum.buttons -in .param_spc_audace_traite2srinstrum -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Label + Entry pour brut
      frame .param_spc_audace_traite2srinstrum.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.brut.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,brut) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.brut.label -in .param_spc_audace_traite2srinstrum.brut -side left -fill none
      entry  .param_spc_audace_traite2srinstrum.brut.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,brut) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.brut.entry -in .param_spc_audace_traite2srinstrum.brut -side left -fill none
      pack .param_spc_audace_traite2srinstrum.brut -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_traite2srinstrum.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.noir.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,noir) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.noir.label -in .param_spc_audace_traite2srinstrum.noir -side left -fill none
      entry  .param_spc_audace_traite2srinstrum.noir.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,noir) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.noir.entry -in .param_spc_audace_traite2srinstrum.noir -side left -fill none
      pack .param_spc_audace_traite2srinstrum.noir -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour plu
      frame .param_spc_audace_traite2srinstrum.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.plu.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,plu) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.plu.label -in .param_spc_audace_traite2srinstrum.plu -side left -fill none
      entry  .param_spc_audace_traite2srinstrum.plu.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,plu) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.plu.entry -in .param_spc_audace_traite2srinstrum.plu -side left -fill none
      pack .param_spc_audace_traite2srinstrum.plu -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traite2srinstrum.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.noirplu.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,noirplu) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.noirplu.label -in .param_spc_audace_traite2srinstrum.noirplu -side left -fill none
      entry  .param_spc_audace_traite2srinstrum.noirplu.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,noirplu) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.noirplu.entry -in .param_spc_audace_traite2srinstrum.noirplu -side left -fill none
      pack .param_spc_audace_traite2srinstrum.noirplu -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      frame .param_spc_audace_traite2srinstrum.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.offset.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,offset) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.offset.label -in .param_spc_audace_traite2srinstrum.offset -side left -fill none
      entry  .param_spc_audace_traite2srinstrum.offset.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,offset) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.offset.entry -in .param_spc_audace_traite2srinstrum.offset -side left -fill none
      pack .param_spc_audace_traite2srinstrum.offset -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour lampe
      frame .param_spc_audace_traite2srinstrum.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.lampe.label -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,lampe)" -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b)
      pack  .param_spc_audace_traite2srinstrum.lampe.label -in .param_spc_audace_traite2srinstrum.lampe -side left -fill none
      button .param_spc_audace_traite2srinstrum.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,traite2srinstrum,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traite2srinstrum.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2srinstrum.lampe.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,lampe) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.lampe.entry -in .param_spc_audace_traite2srinstrum.lampe -side left -fill none
      pack .param_spc_audace_traite2srinstrum.lampe -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour rinstrum
      frame .param_spc_audace_traite2srinstrum.rinstrum -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.rinstrum.label -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,rinstrum)" -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b)
      pack  .param_spc_audace_traite2srinstrum.rinstrum.label -in .param_spc_audace_traite2srinstrum.rinstrum -side left -fill none
      button .param_spc_audace_traite2srinstrum.rinstrum.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -command { set audace(param_spc_audace,traite2srinstrum,config,rinstrum) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traite2srinstrum.rinstrum.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traite2srinstrum.rinstrum.entry  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -textvariable audace(param_spc_audace,traite2srinstrum,config,rinstrum) -bg $audace(param_spc_audace,traite2srinstrum,color,backdisp) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traite2srinstrum.rinstrum.entry -in .param_spc_audace_traite2srinstrum.rinstrum -side left -fill none
      pack .param_spc_audace_traite2srinstrum.rinstrum -in .param_spc_audace_traite2srinstrum -fill none -pady 1 -padx 12


      #--- Label + Entry pour methmasters
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methmasters -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methmasters.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methmasters) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methmasters.label -in .param_spc_audace_traite2srinstrum.methmasters -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methmasters.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methmasters) \
         -values $liste_on
      pack  .param_spc_audace_traite2srinstrum.methmasters.combobox -in .param_spc_audace_traite2srinstrum.methmasters -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methmasters -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methinv.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methinv) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methinv.label -in .param_spc_audace_traite2srinstrum.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_traite2srinstrum.methinv.combobox -in .param_spc_audace_traite2srinstrum.methinv -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methinv -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12



      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methreg.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methreg) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methreg.label -in .param_spc_audace_traite2srinstrum.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_traite2srinstrum.methreg.combobox -in .param_spc_audace_traite2srinstrum.methreg -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methreg -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methcos.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methcos) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methcos.label -in .param_spc_audace_traite2srinstrum.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_traite2srinstrum.methcos.combobox -in .param_spc_audace_traite2srinstrum.methcos -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methcos -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsel
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methsel -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methsel.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methsel) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methsel.label -in .param_spc_audace_traite2srinstrum.methsel -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methsel.combobox \
         -width 7          \
         -height [ llength $liste_methsel ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methsel) \
         -values $liste_methsel
      pack  .param_spc_audace_traite2srinstrum.methsel.combobox -in .param_spc_audace_traite2srinstrum.methsel -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methsel -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methsky.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methsky) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methsky.label -in .param_spc_audace_traite2srinstrum.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_traite2srinstrum.methsky.combobox -in .param_spc_audace_traite2srinstrum.methsky -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methsky -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.methbin.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,methbin) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.methbin.label -in .param_spc_audace_traite2srinstrum.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_traite2srinstrum.methbin.combobox -in .param_spc_audace_traite2srinstrum.methbin -side right -fill none
      pack .param_spc_audace_traite2srinstrum.methbin -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12



      #--- Label + Entry pour norma
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.norma -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.norma.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,norma) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.norma.label -in .param_spc_audace_traite2srinstrum.norma -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.norma.combobox \
         -width 7          \
         -height [ llength $liste_norma ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,norma) \
         -values $liste_norma
      pack  .param_spc_audace_traite2srinstrum.norma.combobox -in .param_spc_audace_traite2srinstrum.norma -side right -fill none
      pack .param_spc_audace_traite2srinstrum.norma -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.smooth.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,smooth) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.smooth.label -in .param_spc_audace_traite2srinstrum.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_traite2srinstrum.smooth.combobox -in .param_spc_audace_traite2srinstrum.smooth -side right -fill none
      pack .param_spc_audace_traite2srinstrum.smooth -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12


      #--- Label + Entry pour ejbad
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.ejbad -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.ejbad.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,ejbad) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.ejbad.label -in .param_spc_audace_traite2srinstrum.ejbad -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.ejbad.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,ejbad) \
         -values $liste_on
      pack  .param_spc_audace_traite2srinstrum.ejbad.combobox -in .param_spc_audace_traite2srinstrum.ejbad -side right -fill none
      pack .param_spc_audace_traite2srinstrum.ejbad -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12

       if { 1==0 } {
      #--- Label + Entry pour ejtilt
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.ejtilt -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.ejtilt.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,ejtilt) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.ejtilt.label -in .param_spc_audace_traite2srinstrum.ejtilt -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.ejtilt.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,ejtilt) \
         -values $liste_on
      pack  .param_spc_audace_traite2srinstrum.ejtilt.combobox -in .param_spc_audace_traite2srinstrum.ejtilt -side right -fill none
      pack .param_spc_audace_traite2srinstrum.ejtilt -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12
   }


      #--- Label + Entry pour export_png
      #-- Partie Label
      frame .param_spc_audace_traite2srinstrum.export_png -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traite2srinstrum,color,backpad)
      label .param_spc_audace_traite2srinstrum.export_png.label  \
	      -font $audace(param_spc_audace,traite2srinstrum,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traite2srinstrum,config,export_png) " -bg $audace(param_spc_audace,traite2srinstrum,color,backpad) \
	      -fg $audace(param_spc_audace,traite2srinstrum,color,textkey) -relief flat
      pack  .param_spc_audace_traite2srinstrum.export_png.label -in .param_spc_audace_traite2srinstrum.export_png -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traite2srinstrum.export_png.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traite2srinstrum,config,export_png) \
         -values $liste_on
      pack  .param_spc_audace_traite2srinstrum.export_png.combobox -in .param_spc_audace_traite2srinstrum.export_png -side right -fill none
      pack .param_spc_audace_traite2srinstrum.export_png -in .param_spc_audace_traite2srinstrum -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace conf
      global caption
      global lampe2calibre_fileout

      ::param_spc_audace_traite2srinstrum::recup_conf
      set brut $audace(param_spc_audace,traite2srinstrum,config,brut)
      set noir $audace(param_spc_audace,traite2srinstrum,config,noir)
      set plu $audace(param_spc_audace,traite2srinstrum,config,plu)
      set noirplu $audace(param_spc_audace,traite2srinstrum,config,noirplu)
      set offset $audace(param_spc_audace,traite2srinstrum,config,offset)
      set lampe $audace(param_spc_audace,traite2srinstrum,config,lampe)
      set rinstrum $audace(param_spc_audace,traite2srinstrum,config,rinstrum)
      set methreg $audace(param_spc_audace,traite2srinstrum,config,methreg)
      set methcos $audace(param_spc_audace,traite2srinstrum,config,methcos)
      set methsel $audace(param_spc_audace,traite2srinstrum,config,methsel)
      set methsky $audace(param_spc_audace,traite2srinstrum,config,methsky)
      set methbin $audace(param_spc_audace,traite2srinstrum,config,methbin)
      set methinv $audace(param_spc_audace,traite2srinstrum,config,methinv)
      set methnorma $audace(param_spc_audace,traite2srinstrum,config,norma)
      set methsmo $audace(param_spc_audace,traite2srinstrum,config,smooth)
      set ejbad $audace(param_spc_audace,traite2srinstrum,config,ejbad)
      set ejtilt $audace(param_spc_audace,traite2srinstrum,config,ejtilt)
      set methmasters $audace(param_spc_audace,traite2srinstrum,config,methmasters)
      set export_png $audace(param_spc_audace,traite2srinstrum,config,export_png)
      set listeargs [ list $brut $noir $plu $noirplu $offset $lampe $rinstrum $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $methmasters $export_png]
      if { $rinstrum=="" } {
	  set rinstrum "none"
      }
      if { $offset=="" } {
	  set offset "none"
      }


      #--- Test si le fichier "lampe" est bien calibr� :
      buf$audace(bufNo) load "$audace(rep_images)/$lampe"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "NAXIS2" ] ==-1 } {
	  set naxis2 1
      } else {
	  set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] ==-1 } {
	  set crval1 1
      } else {
	  set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      }
      if { $naxis2>=2 } {
	  ::console::affiche_resultat [format $caption(spcaudace,metaboxes,traite2srinstrum,message1) $conf(extension,defaut)]
	  tk_messageBox -title "Erreur de saisie" -icon error -message [format $caption(spcaudace,metaboxes,traite2srinstrum,message1) $conf(extension,defaut)]
	  #-- Bo�te de dialogue pour cr�er le profil calibr� de la lampe :
	  set err [ catch {
	      set lampe [ ::param_spc_audace_lampe2calibre::run ]
	      tkwait window .param_spc_audace_lampe2calibre
	  } msg ]
	  if {$err==1} {
	      ::console::affiche_erreur "$msg\n"
	  }
	  set lampe $lampe2calibre_fileout
      } elseif { $crval1==1 && $naxis2==1 } {
	  ::console::affiche_resultat [format $caption(spcaudace,metaboxes,traite2srinstrum,message2) $conf(extension,defaut)]
	  tk_messageBox -title "Erreur de saisie" -icon error -message [format $caption(spcaudace,metaboxes,traite2srinstrum,message2) $conf(extension,defaut)]
	  #-- Bo�te de dialogue pour calibrer la lampe :
	  #- Attention : suppose que le profil de la lampe est corrig� g�om�triquement et invers� si n�cessaire.
	  set lampe [ spc_calibre $lampe ]
      }



      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  set fileout [ spc_traite2srinstrum $brut $noir $plu $noirplu $offset $lampe $rinstrum $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $methmasters $export_png ]
	  destroy .param_spc_audace_traite2srinstrum
	  return $fileout
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_traite2srinstrum::recup_conf
      destroy .param_spc_audace_traite2srinstrum
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_traite2srinstrum ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_traite2srinstrum]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#






########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_traitestellaire
# Intitul� : R�duction spectrale de spectres stellaires
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 15-07-2007
# Date de modification : 15-07-2007
# Utilis�e par : spc_traitestellaire
# Args :
########################################################################

namespace eval ::param_spc_audace_traitestellaire {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      set liste_methcos [ list "o" "n" ]
      set liste_methinv [ list "o" "n" ]
      set liste_norma [ list "o" "e" "a" "n" ]
      set liste_on [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_traitestellaire.* ] ] != "0" } {
         destroy .param_spc_audace_traitestellaire
      }

       #-- Options pr�d�finies (d�clar�es dans proc�dure GO) :
       #set methreg "spc"
       #set methsky "med"
       #set methsel "serre"
       #set methbin "rober"
       #set methsmo "n"
       #set methejbad "n"
       #set methejtilt "n"
       #set rmfpretrait "o"


      # === Initialisation des variables qui seront chang�es
      #- set audace(param_spc_audace,traitestellaire,config,rinstrum) "none"
      set audace(param_spc_audace,traitestellaire,config,methinv) "n"
      set audace(param_spc_audace,traitestellaire,config,methraie) "n"
      set audace(param_spc_audace,traitestellaire,config,methcos) "n"
      set audace(param_spc_audace,traitestellaire,config,norma) "n"
      set audace(param_spc_audace,traitestellaire,config,offset) "none"
      set audace(param_spc_audace,traitestellaire,config,cal_eau) "n"
      set audace(param_spc_audace,traitestellaire,config,export_png) "n"
      set audace(param_spc_audace,traitestellaire,config,export_bess) "n"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,traitestellaire,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traitestellaire,color,backpad) #ECE9D8
      set audace(param_spc_audace,traitestellaire,color,backdisp) $color(white)
      set audace(param_spc_audace,traitestellaire,color,textdisp) #FF0000
      set audace(param_spc_audace,traitestellaire,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,traitestellaire,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_traitestellaire de niveau le plus haut
      toplevel .param_spc_audace_traitestellaire -class Toplevel -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      #wm geometry .param_spc_audace_traitestellaire 450x558+10+10
      wm geometry .param_spc_audace_traitestellaire 486x485+146-25
      wm resizable .param_spc_audace_traitestellaire 1 1
      wm title .param_spc_audace_traitestellaire $caption(spcaudace,metaboxes,traitestellaire,titre)
      wm protocol .param_spc_audace_traitestellaire WM_DELETE_WINDOW "::param_spc_audace_traitestellaire::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traitestellaire.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,traitestellaire,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey)
      pack .param_spc_audace_traitestellaire.title \
	      -in .param_spc_audace_traitestellaire -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_traitestellaire.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_traitestellaire.stop_button  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,stop_button)" \
	      -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) \
	      -command {::param_spc_audace_traitestellaire::annuler}
      pack  .param_spc_audace_traitestellaire.stop_button -in .param_spc_audace_traitestellaire.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_traitestellaire.return_button  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,return_button)" \
	      -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) \
	      -command {::param_spc_audace_traitestellaire::go}
      pack  .param_spc_audace_traitestellaire.return_button -in .param_spc_audace_traitestellaire.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_traitestellaire.buttons -in .param_spc_audace_traitestellaire -fill x -pady 0 -padx 0 -anchor s -side bottom

      #--- Label + Entry pour lampe
      frame .param_spc_audace_traitestellaire.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.lampe.label -text "$caption(spcaudace,metaboxes,traitestellaire,config,lampe)" -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b)
      pack  .param_spc_audace_traitestellaire.lampe.label -in .param_spc_audace_traitestellaire.lampe -side left -fill none
      button .param_spc_audace_traitestellaire.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -command { set audace(param_spc_audace,traitestellaire,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traitestellaire.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traitestellaire.lampe.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,lampe) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.lampe.entry -in .param_spc_audace_traitestellaire.lampe -side left -fill none
      pack .param_spc_audace_traitestellaire.lampe -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12


      #--- Label + Entry pour brut
      frame .param_spc_audace_traitestellaire.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.brut.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,brut) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.brut.label -in .param_spc_audace_traitestellaire.brut -side left -fill none
      entry  .param_spc_audace_traitestellaire.brut.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,brut) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.brut.entry -in .param_spc_audace_traitestellaire.brut -side left -fill none
      pack .param_spc_audace_traitestellaire.brut -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_traitestellaire.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.noir.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,noir) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.noir.label -in .param_spc_audace_traitestellaire.noir -side left -fill none
      entry  .param_spc_audace_traitestellaire.noir.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,noir) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.noir.entry -in .param_spc_audace_traitestellaire.noir -side left -fill none
      pack .param_spc_audace_traitestellaire.noir -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12


      #--- Label + Entry pour plu
      frame .param_spc_audace_traitestellaire.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.plu.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,plu) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.plu.label -in .param_spc_audace_traitestellaire.plu -side left -fill none
      entry  .param_spc_audace_traitestellaire.plu.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,plu) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.plu.entry -in .param_spc_audace_traitestellaire.plu -side left -fill none
      pack .param_spc_audace_traitestellaire.plu -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traitestellaire.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.noirplu.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,noirplu) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.noirplu.label -in .param_spc_audace_traitestellaire.noirplu -side left -fill none
      entry  .param_spc_audace_traitestellaire.noirplu.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,noirplu) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.noirplu.entry -in .param_spc_audace_traitestellaire.noirplu -side left -fill none
      pack .param_spc_audace_traitestellaire.noirplu -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      frame .param_spc_audace_traitestellaire.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.offset.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,offset) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.offset.label -in .param_spc_audace_traitestellaire.offset -side left -fill none
      entry  .param_spc_audace_traitestellaire.offset.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,offset) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.offset.entry -in .param_spc_audace_traitestellaire.offset -side left -fill none
      pack .param_spc_audace_traitestellaire.offset -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12



      #--- Label + Entry pour rinstrum
      frame .param_spc_audace_traitestellaire.rinstrum -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.rinstrum.label -text "$caption(spcaudace,metaboxes,traitestellaire,config,rinstrum)" -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b)
      pack  .param_spc_audace_traitestellaire.rinstrum.label -in .param_spc_audace_traitestellaire.rinstrum -side left -fill none
      button .param_spc_audace_traitestellaire.rinstrum.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -command { set audace(param_spc_audace,traitestellaire,config,rinstrum) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traitestellaire.rinstrum.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traitestellaire.rinstrum.entry  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -textvariable audace(param_spc_audace,traitestellaire,config,rinstrum) -bg $audace(param_spc_audace,traitestellaire,color,backdisp) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitestellaire.rinstrum.entry -in .param_spc_audace_traitestellaire.rinstrum -side left -fill none
      pack .param_spc_audace_traitestellaire.rinstrum -in .param_spc_audace_traitestellaire -fill none -pady 1 -padx 12



      #--- Label + Entry pour methraie
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.methraie -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.methraie.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,methraie) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.methraie.label -in .param_spc_audace_traitestellaire.methraie -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.methraie.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,methraie) \
         -values $liste_on
      pack  .param_spc_audace_traitestellaire.methraie.combobox -in .param_spc_audace_traitestellaire.methraie -side right -fill none
      pack .param_spc_audace_traitestellaire.methraie -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.methinv.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,methinv) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.methinv.label -in .param_spc_audace_traitestellaire.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_traitestellaire.methinv.combobox -in .param_spc_audace_traitestellaire.methinv -side right -fill none
      pack .param_spc_audace_traitestellaire.methinv -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12




      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.methcos.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,methcos) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.methcos.label -in .param_spc_audace_traitestellaire.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_traitestellaire.methcos.combobox -in .param_spc_audace_traitestellaire.methcos -side right -fill none
      pack .param_spc_audace_traitestellaire.methcos -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12



      #--- Label + Entry pour norma
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.norma -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.norma.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,norma) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.norma.label -in .param_spc_audace_traitestellaire.norma -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.norma.combobox \
         -width 7          \
         -height [ llength $liste_norma ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,norma) \
         -values $liste_norma
      pack  .param_spc_audace_traitestellaire.norma.combobox -in .param_spc_audace_traitestellaire.norma -side right -fill none
      pack .param_spc_audace_traitestellaire.norma -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12


      #--- Label + Entry pour cal_eau
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.cal_eau -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.cal_eau.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,cal_eau) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.cal_eau.label -in .param_spc_audace_traitestellaire.cal_eau -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.cal_eau.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,cal_eau) \
         -values $liste_on
      pack  .param_spc_audace_traitestellaire.cal_eau.combobox -in .param_spc_audace_traitestellaire.cal_eau -side right -fill none
      pack .param_spc_audace_traitestellaire.cal_eau -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12


      #--- Label + Entry pour export_bess
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.export_bess -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.export_bess.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,export_bess) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.export_bess.label -in .param_spc_audace_traitestellaire.export_bess -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.export_bess.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,export_bess) \
         -values $liste_on
      pack  .param_spc_audace_traitestellaire.export_bess.combobox -in .param_spc_audace_traitestellaire.export_bess -side right -fill none
      pack .param_spc_audace_traitestellaire.export_bess -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12



      #--- Label + Entry pour export_png
      #-- Partie Label
      frame .param_spc_audace_traitestellaire.export_png -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitestellaire,color,backpad)
      label .param_spc_audace_traitestellaire.export_png.label  \
	      -font $audace(param_spc_audace,traitestellaire,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitestellaire,config,export_png) " -bg $audace(param_spc_audace,traitestellaire,color,backpad) \
	      -fg $audace(param_spc_audace,traitestellaire,color,textkey) -relief flat
      pack  .param_spc_audace_traitestellaire.export_png.label -in .param_spc_audace_traitestellaire.export_png -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitestellaire.export_png.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitestellaire,config,export_png) \
         -values $liste_on
      pack  .param_spc_audace_traitestellaire.export_png.combobox -in .param_spc_audace_traitestellaire.export_png -side right -fill none
      pack .param_spc_audace_traitestellaire.export_png -in .param_spc_audace_traitestellaire -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace conf
      global caption
      global lampe2calibre_fileout

      #-- Options pr�d�finies :
      set methreg "spc"
      set methsel "serre"
      set methsky "med"
      set methbin "rober"
      set methsmo "n"
      set ejbad "n"
      set ejtilt "n"
      set rmfpretrait "o"

      ::param_spc_audace_traitestellaire::recup_conf
      set lampe $audace(param_spc_audace,traitestellaire,config,lampe)
      set brut $audace(param_spc_audace,traitestellaire,config,brut)
      set noir $audace(param_spc_audace,traitestellaire,config,noir)
      set plu $audace(param_spc_audace,traitestellaire,config,plu)
      set noirplu $audace(param_spc_audace,traitestellaire,config,noirplu)
      set offset $audace(param_spc_audace,traitestellaire,config,offset)
      set rinstrum $audace(param_spc_audace,traitestellaire,config,rinstrum)
      set methraie $audace(param_spc_audace,traitestellaire,config,methraie)
      set methcos $audace(param_spc_audace,traitestellaire,config,methcos)
      set methinv $audace(param_spc_audace,traitestellaire,config,methinv)
      set methnorma $audace(param_spc_audace,traitestellaire,config,norma)
      set cal_eau $audace(param_spc_audace,traitestellaire,config,cal_eau)
      set export_png $audace(param_spc_audace,traitestellaire,config,export_png)
      set export_bess $audace(param_spc_audace,traitestellaire,config,export_bess)
      if { $rinstrum=="" } {
	  set rinstrum "none"
      }
      if { $offset=="" } {
	  set offset "none"
      }
      set listeargs [ list $lampe $brut $noir $plu $noirplu $offset $rinstrum $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $rmfpretrait $cal_eau $export_png $export_bess ]



      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  #-- Test si le fichier "lampe" est bien calibr� :
	  set flag_calibration [ spc_testcalibre "$lampe" ]
	  if { $flag_calibration != -1 } {
	      set fileout [ spc_traitestellaire $lampe $brut $noir $plu $noirplu $offset $rinstrum $methraie $methcos $methinv $methnorma $cal_eau $export_png $export_bess $methreg $methsel $methsky $methbin $methsmo $ejbad $ejtilt $rmfpretrait $flag_calibration ]
	      destroy .param_spc_audace_traitestellaire
	      return $fileout
	  }
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_traitestellaire::recup_conf
      destroy .param_spc_audace_traitestellaire
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_traitestellaire ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [ wm geometry .param_spc_audace_traitestellaire ]
	  set deb [ expr 1+[string first + $geom ] ]
	  set fin [ string length $geom ]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#



########################################################################
# Bo�te graphique de saisie de s param�tres pour la metafonction spc_traitestellaire
# Intitul� : R�duction spectrale de spectres non stellaires
#
# Auteurs : Benjamin Mauclaire
# Date de cr�ation : 15-07-2007
# Date de modification : 15-07-2007
# Utilis�e par : spc_traitenebula
# Args :
########################################################################

namespace eval ::param_spc_audace_traitenebula {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      set liste_methreg [ list "spc" "reg" "n" ]
      set liste_methcos [ list "o" "n" ]
      #- Non dispo : set liste_methsel [ list "large" "serre" ]
      set liste_methsky [ list "med" "moy" "moy2" "sup" "inf" "back" "none" ]
      set liste_methinv [ list "o" "n" ]
      set liste_methbin [ list "add" "rober" "horne" ]
      set liste_norma [ list "o" "e" "a" "n" ]
      set liste_smooth [ list "o" "n" ]
      set liste_on [ list "o" "n" ]

      if { [ string length [ info commands .param_spc_audace_traitenebula.* ] ] != "0" } {
         destroy .param_spc_audace_traitenebula
      }

       #-- Options pr�d�finies (d�clar�es dans proc�dure GO) :
       #set methejbad "n"
       #set methejtilt "n"


      # === Initialisation des variables qui seront chang�es
      #- set audace(param_spc_audace,traitenebula,config,rinstrum) "none"
      set audace(param_spc_audace,traitenebula,config,methinv) "n"
      set audace(param_spc_audace,traitenebula,config,methraie) "o"
      set audace(param_spc_audace,traitenebula,config,methcos) "n"
      set audace(param_spc_audace,traitenebula,config,norma) "n"
      set audace(param_spc_audace,traitenebula,config,offset) "none"
      set audace(param_spc_audace,traitenebula,config,export_png) "n"
      set audace(param_spc_audace,traitenebula,config,methreg) "n"
      set audace(param_spc_audace,traitenebula,config,methsky) "med"
      set audace(param_spc_audace,traitenebula,config,methbin) "rober"
      set audace(param_spc_audace,traitenebula,config,smooth) "n"
      set audace(param_spc_audace,traitenebula,config,methmasters) "o"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,traitenebula,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,traitenebula,color,backpad) #ECE9D8
      set audace(param_spc_audace,traitenebula,color,backdisp) $color(white)
      set audace(param_spc_audace,traitenebula,color,textdisp) #FF0000
      set audace(param_spc_audace,traitenebula,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,traitenebula,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_traitenebula de niveau le plus haut
      toplevel .param_spc_audace_traitenebula -class Toplevel -bg $audace(param_spc_audace,traitenebula,color,backpad)
      #wm geometry .param_spc_audace_traitenebula 450x558+10+10
      wm geometry .param_spc_audace_traitenebula 486x562+191-20
      wm resizable .param_spc_audace_traitenebula 1 1
      wm title .param_spc_audace_traitenebula $caption(spcaudace,metaboxes,traitenebula,titre)
      wm protocol .param_spc_audace_traitenebula WM_DELETE_WINDOW "::param_spc_audace_traitenebula::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_traitenebula.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,metaboxes,traitenebula,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey)
      pack .param_spc_audace_traitenebula.title \
	      -in .param_spc_audace_traitenebula -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_traitenebula.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,traitenebula,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_traitenebula.stop_button  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,stop_button)" \
	      -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) \
	      -command {::param_spc_audace_traitenebula::annuler}
      pack  .param_spc_audace_traitenebula.stop_button -in .param_spc_audace_traitenebula.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_traitenebula.return_button  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,return_button)" \
	      -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) \
	      -command {::param_spc_audace_traitenebula::go}
      pack  .param_spc_audace_traitenebula.return_button -in .param_spc_audace_traitenebula.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_traitenebula.buttons -in .param_spc_audace_traitenebula -fill x -pady 0 -padx 0 -anchor s -side bottom

      #--- Label + Entry pour lampe
      frame .param_spc_audace_traitenebula.lampe -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.lampe.label -text "$caption(spcaudace,metaboxes,traitenebula,config,lampe)" -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traitenebula,font,c12b)
      pack  .param_spc_audace_traitenebula.lampe.label -in .param_spc_audace_traitenebula.lampe -side left -fill none
      button .param_spc_audace_traitenebula.lampe.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -command { set audace(param_spc_audace,traitenebula,config,lampe) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traitenebula.lampe.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traitenebula.lampe.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,lampe) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.lampe.entry -in .param_spc_audace_traitenebula.lampe -side left -fill none
      pack .param_spc_audace_traitenebula.lampe -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12


      #--- Label + Entry pour brut
      frame .param_spc_audace_traitenebula.brut -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.brut.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,brut) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.brut.label -in .param_spc_audace_traitenebula.brut -side left -fill none
      entry  .param_spc_audace_traitenebula.brut.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,brut) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.brut.entry -in .param_spc_audace_traitenebula.brut -side left -fill none
      pack .param_spc_audace_traitenebula.brut -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12

      #--- Label + Entry pour noir
      frame .param_spc_audace_traitenebula.noir -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.noir.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,noir) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.noir.label -in .param_spc_audace_traitenebula.noir -side left -fill none
      entry  .param_spc_audace_traitenebula.noir.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,noir) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.noir.entry -in .param_spc_audace_traitenebula.noir -side left -fill none
      pack .param_spc_audace_traitenebula.noir -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12


      #--- Label + Entry pour plu
      frame .param_spc_audace_traitenebula.plu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.plu.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,plu) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.plu.label -in .param_spc_audace_traitenebula.plu -side left -fill none
      entry  .param_spc_audace_traitenebula.plu.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,plu) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.plu.entry -in .param_spc_audace_traitenebula.plu -side left -fill none
      pack .param_spc_audace_traitenebula.plu -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12


      #--- Label + Entry pour noirplu
      frame .param_spc_audace_traitenebula.noirplu -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.noirplu.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,noirplu) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.noirplu.label -in .param_spc_audace_traitenebula.noirplu -side left -fill none
      entry  .param_spc_audace_traitenebula.noirplu.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,noirplu) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.noirplu.entry -in .param_spc_audace_traitenebula.noirplu -side left -fill none
      pack .param_spc_audace_traitenebula.noirplu -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12


      #--- Label + Entry pour offset
      frame .param_spc_audace_traitenebula.offset -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.offset.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,offset) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.offset.label -in .param_spc_audace_traitenebula.offset -side left -fill none
      entry  .param_spc_audace_traitenebula.offset.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,offset) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.offset.entry -in .param_spc_audace_traitenebula.offset -side left -fill none
      pack .param_spc_audace_traitenebula.offset -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12



      #--- Label + Entry pour rinstrum
      frame .param_spc_audace_traitenebula.rinstrum -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.rinstrum.label -text "$caption(spcaudace,metaboxes,traitenebula,config,rinstrum)" -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,traitenebula,font,c12b)
      pack  .param_spc_audace_traitenebula.rinstrum.label -in .param_spc_audace_traitenebula.rinstrum -side left -fill none
      button .param_spc_audace_traitenebula.rinstrum.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -command { set audace(param_spc_audace,traitenebula,config,rinstrum) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_traitenebula.rinstrum.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_traitenebula.rinstrum.entry  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -textvariable audace(param_spc_audace,traitenebula,config,rinstrum) -bg $audace(param_spc_audace,traitenebula,color,backdisp) \
	      -fg $audace(param_spc_audace,traitenebula,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_traitenebula.rinstrum.entry -in .param_spc_audace_traitenebula.rinstrum -side left -fill none
      pack .param_spc_audace_traitenebula.rinstrum -in .param_spc_audace_traitenebula -fill none -pady 1 -padx 12



      #--- Label + Entry pour methraie
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methraie -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methraie.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methraie) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methraie.label -in .param_spc_audace_traitenebula.methraie -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methraie.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methraie) \
         -values $liste_on
      pack  .param_spc_audace_traitenebula.methraie.combobox -in .param_spc_audace_traitenebula.methraie -side right -fill none
      pack .param_spc_audace_traitenebula.methraie -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12



      #--- Label + Entry pour methinv
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methinv -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methinv.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methinv) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methinv.label -in .param_spc_audace_traitenebula.methinv -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methinv.combobox \
         -width 7          \
         -height [ llength $liste_methinv ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methinv) \
         -values $liste_methinv
      pack  .param_spc_audace_traitenebula.methinv.combobox -in .param_spc_audace_traitenebula.methinv -side right -fill none
      pack .param_spc_audace_traitenebula.methinv -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12




      #--- Label + Entry pour methcos
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methcos -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methcos.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methcos) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methcos.label -in .param_spc_audace_traitenebula.methcos -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methcos.combobox \
         -width 7          \
         -height [ llength $liste_methcos ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methcos) \
         -values $liste_methcos
      pack  .param_spc_audace_traitenebula.methcos.combobox -in .param_spc_audace_traitenebula.methcos -side right -fill none
      pack .param_spc_audace_traitenebula.methcos -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12



      #--- Label + Entry pour norma
      #-- Partie Label
      frame .param_spc_audace_traitenebula.norma -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.norma.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,norma) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.norma.label -in .param_spc_audace_traitenebula.norma -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.norma.combobox \
         -width 7          \
         -height [ llength $liste_norma ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,norma) \
         -values $liste_norma
      pack  .param_spc_audace_traitenebula.norma.combobox -in .param_spc_audace_traitenebula.norma -side right -fill none
      pack .param_spc_audace_traitenebula.norma -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12




      #--- Label + Entry pour export_png
      #-- Partie Label
      frame .param_spc_audace_traitenebula.export_png -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.export_png.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,export_png) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.export_png.label -in .param_spc_audace_traitenebula.export_png -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.export_png.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,export_png) \
         -values $liste_on
      pack  .param_spc_audace_traitenebula.export_png.combobox -in .param_spc_audace_traitenebula.export_png -side right -fill none
      pack .param_spc_audace_traitenebula.export_png -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12


      #--- Label + Entry pour methreg
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methreg -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methreg.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methreg) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methreg.label -in .param_spc_audace_traitenebula.methreg -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methreg.combobox \
         -width 7          \
         -height [ llength $liste_methreg ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methreg) \
         -values $liste_methreg
      pack  .param_spc_audace_traitenebula.methreg.combobox -in .param_spc_audace_traitenebula.methreg -side right -fill none
      pack .param_spc_audace_traitenebula.methreg -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12

      #--- Label + Entry pour methsky
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methsky -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methsky.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methsky) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methsky.label -in .param_spc_audace_traitenebula.methsky -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methsky.combobox \
         -width 7          \
         -height [ llength $liste_methsky ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methsky) \
         -values $liste_methsky
      pack  .param_spc_audace_traitenebula.methsky.combobox -in .param_spc_audace_traitenebula.methsky -side right -fill none
      pack .param_spc_audace_traitenebula.methsky -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12


      #--- Label + Entry pour methbin
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methbin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methbin.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methbin) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methbin.label -in .param_spc_audace_traitenebula.methbin -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methbin.combobox \
         -width 7          \
         -height [ llength $liste_methbin ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methbin) \
         -values $liste_methbin
      pack  .param_spc_audace_traitenebula.methbin.combobox -in .param_spc_audace_traitenebula.methbin -side right -fill none
      pack .param_spc_audace_traitenebula.methbin -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12


      #--- Label + Entry pour smooth
      #-- Partie Label
      frame .param_spc_audace_traitenebula.smooth -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.smooth.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,smooth) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.smooth.label -in .param_spc_audace_traitenebula.smooth -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.smooth.combobox \
         -width 7          \
         -height [ llength $liste_smooth ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,smooth) \
         -values $liste_smooth
      pack  .param_spc_audace_traitenebula.smooth.combobox -in .param_spc_audace_traitenebula.smooth -side right -fill none
      pack .param_spc_audace_traitenebula.smooth -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12


      #--- Label + Entry pour methmasters
      #-- Partie Label
      frame .param_spc_audace_traitenebula.methmasters -borderwidth 0 -relief flat -bg $audace(param_spc_audace,traitenebula,color,backpad)
      label .param_spc_audace_traitenebula.methmasters.label  \
	      -font $audace(param_spc_audace,traitenebula,font,c12b) \
	      -text "$caption(spcaudace,metaboxes,traitenebula,config,methmasters) " -bg $audace(param_spc_audace,traitenebula,color,backpad) \
	      -fg $audace(param_spc_audace,traitenebula,color,textkey) -relief flat
      pack  .param_spc_audace_traitenebula.methmasters.label -in .param_spc_audace_traitenebula.methmasters -side left -fill none
      #-- Partie Combobox
      ComboBox .param_spc_audace_traitenebula.methmasters.combobox \
         -width 7          \
         -height [ llength $liste_on ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable audace(param_spc_audace,traitenebula,config,methmasters) \
         -values $liste_on
      pack  .param_spc_audace_traitenebula.methmasters.combobox -in .param_spc_audace_traitenebula.methmasters -side right -fill none
      pack .param_spc_audace_traitenebula.methmasters -in .param_spc_audace_traitenebula -fill x -pady 1 -padx 12

  }


  proc go {} {
      global audace conf
      global caption
      global lampe2calibre_fileout spc_windowcoords

      #-- Options pr�d�finies :
      set methreg "n"

      ::param_spc_audace_traitenebula::recup_conf
      set lampe $audace(param_spc_audace,traitenebula,config,lampe)
      set brut $audace(param_spc_audace,traitenebula,config,brut)
      set noir $audace(param_spc_audace,traitenebula,config,noir)
      set plu $audace(param_spc_audace,traitenebula,config,plu)
      set noirplu $audace(param_spc_audace,traitenebula,config,noirplu)
      set offset $audace(param_spc_audace,traitenebula,config,offset)
      set rinstrum $audace(param_spc_audace,traitenebula,config,rinstrum)
      set methraie $audace(param_spc_audace,traitenebula,config,methraie)
      set methcos $audace(param_spc_audace,traitenebula,config,methcos)
      set methinv $audace(param_spc_audace,traitenebula,config,methinv)
      set methnorma $audace(param_spc_audace,traitenebula,config,norma)
      set export_png $audace(param_spc_audace,traitenebula,config,export_png)
      set methreg $audace(param_spc_audace,traitenebula,config,methreg)
      set methsky $audace(param_spc_audace,traitenebula,config,methsky)
      set methbin $audace(param_spc_audace,traitenebula,config,methbin)
      set methsmo $audace(param_spc_audace,traitenebula,config,smooth)
      set rmfpretrait $audace(param_spc_audace,traitenebula,config,methmasters)
      if { $rinstrum=="" } {
	  set rinstrum "none"
      }
      if { $offset=="" } {
	  set offset "none"
      }
      set listeargs [ list $lampe $brut $noir $plu $noirplu $offset $rinstrum $methraie $methcos $methinv $methnorma $export_png $methreg $methsky $methbin $methsmo $rmfpretrait ]



      #--- Lancement de la fonction spcaudace :
      #-- Si tous les champs sont /= "" on execute le calcul :
      if { [ spc_testguiargs $listeargs ] == 1 } {
	  #-- Test si le fichier "lampe" est bien calibr� :
	  set flag_calibration [ spc_testcalibre "$lampe" ]
	  if { $flag_calibration != -1 } {
	      set fileout [ spc_traitenebula $lampe $brut $noir $plu $noirplu $offset $rinstrum $methraie $methcos $methinv $methnorma $export_png $methreg $methsky $methbin $methsmo $rmfpretrait $flag_calibration ]
	      destroy .param_spc_audace_traitenebula
	      return $fileout
	  }
      }
  }

  proc annuler {} {
      global audace
      global caption
      ::param_spc_audace_traitenebula::recup_conf
      destroy .param_spc_audace_traitenebula
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_traitenebula ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [ wm geometry .param_spc_audace_traitenebula ]
	  set deb [ expr 1+[string first + $geom ] ]
	  set fin [ string length $geom ]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#
