# =================================================================================
# =================================================================================
# =================================================================================
# =================================================================================

namespace eval ::photometry_prepare {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .photometry.* ] ] != "0" } {
         destroy .photometry
      }

      set caption(photometry,prepare,titre) "Photometry: Configuration"
      set caption(photometry,prepare,titre2) "Photometry: Configuration"
		set caption(photometry,prepare,compute_button) "Calculer"
		set caption(photometry,prepare,return_button) "OK"

		set caption(photometry,prepare,config,file_cat) "Fichier du catalogue photométrique"
		set caption(photometry,prepare,config,file_out) "Fichier de sortie des résultats"
		set caption(photometry,prepare,config,date_night) "Date de la nuit à préparer"
		set caption(photometry,prepare,config,ra) "R.A. du champ à mesurer"
		set caption(photometry,prepare,config,dec) "Dec. du champ à mesurer"

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      set statustel(speed) "0"

      #--- Definition of colorohps
      #--- Definition des couleurs
      set audace(photometry,prepare,color,backpad)  #F0F0FF
      set audace(photometry,prepare,color,backdisp) $color(white)
      set audace(photometry,prepare,color,textkey)  $color(blue_pad)
      set audace(photometry,prepare,color,textdisp) #FF0000

      set geomohp(larg) 970
      set geomohp(long) 500

		set audace(photometry,prepare,config,file_cat) "[pwd]/audace/etc/cataphotom/loneos_coords.txt"
		set audace(photometry,prepare,config,file_out) "prepare.txt"
		set audace(photometry,prepare,config,date_night) "[mc_date2iso8601 now]"
		set audace(photometry,prepare,config,ra) "12h56m34s"
		set audace(photometry,prepare,config,dec) "+45d23m12s"

		set audace(photometry,prepare,font,c12b) [ list {Courier} 10 bold ]
		set audace(photometry,prepare,font,c10b) [ list {Courier} 10 bold ]

      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .photometry de niveau le plus haut
      toplevel .photometry -class Toplevel -bg $audace(photometry,prepare,color,backpad)
      wm geometry .photometry $geomohp(larg)x$geomohp(long)+$positionxy
      wm resizable .photometry 0 0
      wm title .photometry $caption(photometry,prepare,titre)
      wm protocol .photometry WM_DELETE_WINDOW "::photometry_prepare::stop"

      #--- Create the title
      #--- Cree le titre
      label .photometry.title \
         -font [ list {Arial} 16 bold ] -text "$caption(photometry,prepare,titre2)" \
         -borderwidth 0 -relief flat -bg $audace(photometry,prepare,color,backpad) \
         -fg $audace(photometry,prepare,color,textkey)
      pack .photometry.title \
         -in .photometry -fill x -side top -pady 5

      # --- boutons
	   frame .photometry.buttons -borderwidth 3 -relief sunken -bg $audace(photometry,prepare,color,backpad)
      	button .photometry.compute_button  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,compute_button)" \
         	-command {::photometry_prepare::compute}
      	pack  .photometry.compute_button -in .photometry.buttons -side left -fill none -padx 3
      	button .photometry.return_button  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,return_button)" \
         	-command {::photometry_prepare::go}
      	pack  .photometry.return_button -in .photometry.buttons -side left -fill none -padx 3
      pack .photometry.buttons -in .photometry -fill x -pady 3 -padx 3 -anchor s -side bottom

      #--- IMAGES BRUTES .FITS
      frame .photometry.file_cat -borderwidth 3 -relief sunken -bg $audace(photometry,prepare,color,backpad)
      	label .photometry.file_cat.label  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,config,file_cat) " -bg $audace(photometry,prepare,color,backpad) \
         	-fg $audace(photometry,prepare,color,textkey) -relief flat
      	pack  .photometry.file_cat.label -in .photometry.file_cat -side left -fill none
	      entry  .photometry.file_cat.entry  \
         	-font $audace(photometry,prepare,font,c12b) \
         	-textvariable audace(photometry,prepare,config,file_cat) -bg $audace(photometry,prepare,color,backdisp) \
         	-fg $audace(photometry,prepare,color,textdisp) -relief flat -width 70
      	pack  .photometry.file_cat.entry -in .photometry.file_cat -side left -fill none
      pack .photometry.file_cat -in .photometry -fill none -pady 1 -padx 12

      #--- IMAGES BRUTES
      frame .photometry.file_out -borderwidth 3 -relief sunken -bg $audace(photometry,prepare,color,backpad)
      	label .photometry.file_out.label  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,config,file_out) " -bg $audace(photometry,prepare,color,backpad) \
         	-fg $audace(photometry,prepare,color,textkey) -relief flat
      	pack  .photometry.file_out.label -in .photometry.file_out -side left -fill none
	      entry  .photometry.file_out.entry  \
         	-font $audace(photometry,prepare,font,c12b) \
         	-textvariable audace(photometry,prepare,config,file_out) -bg $audace(photometry,prepare,color,backdisp) \
         	-fg $audace(photometry,prepare,color,textdisp) -relief flat -width 20
      	pack  .photometry.file_out.entry -in .photometry.file_out -side left -fill none
      pack .photometry.file_out -in .photometry -fill none -pady 1 -padx 12

      #--- TELESCOPE
      frame .photometry.date_night -borderwidth 3 -relief sunken -bg $audace(photometry,prepare,color,backpad)
      	label .photometry.date_night.label  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,config,date_night) " -bg $audace(photometry,prepare,color,backpad) \
         	-fg $audace(photometry,prepare,color,textkey) -relief flat
      	pack  .photometry.date_night.label -in .photometry.date_night -side left -fill none
	      entry  .photometry.date_night.entry  \
         	-font $audace(photometry,prepare,font,c12b) \
         	-textvariable audace(photometry,prepare,config,date_night) -bg $audace(photometry,prepare,color,backdisp) \
         	-fg $audace(photometry,prepare,color,textdisp) -relief flat -width 25
      	pack  .photometry.date_night.entry -in .photometry.date_night -side left -fill none
      pack .photometry.date_night -in .photometry -fill none -pady 1 -padx 12

      #--- RA
      frame .photometry.ra -borderwidth 3 -relief sunken -bg $audace(photometry,prepare,color,backpad)
      	label .photometry.ra.label  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,config,ra) " -bg $audace(photometry,prepare,color,backpad) \
         	-fg $audace(photometry,prepare,color,textkey) -relief flat
      	pack  .photometry.ra.label -in .photometry.ra -side left -fill none
	      entry  .photometry.ra.entry  \
         	-font $audace(photometry,prepare,font,c12b) \
         	-textvariable audace(photometry,prepare,config,ra) -bg $audace(photometry,prepare,color,backdisp) \
         	-fg $audace(photometry,prepare,color,textdisp) -relief flat -width 10
      	pack  .photometry.ra.entry -in .photometry.ra -side left -fill none
      pack .photometry.ra -in .photometry -fill none -pady 1 -padx 12

      #--- DEC
      frame .photometry.dec -borderwidth 3 -relief sunken -bg $audace(photometry,prepare,color,backpad)
      	label .photometry.dec.label  \
	         -font $audace(photometry,prepare,font,c12b) \
         	-text "$caption(photometry,prepare,config,dec) " -bg $audace(photometry,prepare,color,backpad) \
         	-fg $audace(photometry,prepare,color,textkey) -relief flat
      	pack  .photometry.dec.label -in .photometry.dec -side left -fill none
	      entry  .photometry.dec.entry  \
         	-font $audace(photometry,prepare,font,c12b) \
         	-textvariable audace(photometry,prepare,config,dec) -bg $audace(photometry,prepare,color,backdisp) \
         	-fg $audace(photometry,prepare,color,textdisp) -relief flat -width 10
      	pack  .photometry.dec.entry -in .photometry.dec -side left -fill none
      pack .photometry.dec -in .photometry -fill none -pady 1 -padx 12

	}

   proc stop {  } {
      global conf
      global audace

      if { [ winfo exists .photometry ] } {
         #--- Enregistre la position de la fenetre
         set geom [wm geometry .photometry]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(photometry,position) "[string range  $geom $deb $fin]"
      }

      #--- Supprime la fenetre
      destroy .photometry
      return
   }

   proc go {} {
      global audace
      global caption
		::console::affiche_resultat "PHOTOMETRY Configuration : \n"
		#::console::affiche_resultat "$caption(photometry,configure,config,ra): $audace(photometry,configure,config,ra)\n"
		::photometry_prepare::stop
   }

   proc compute {} {
      global conf
      global audace
      global caption
		set script [ file join $audace(rep_plugin) tool photometry selecfield.tcl ]
		::console::affiche_resultat "$script\n"
		source $script
		set home [list GPS [mc_angle2deg $audace(photometry,configure,config,longitude)] $audace(photometry,configure,config,sens) [mc_angle2deg $audace(photometry,configure,config,latitude) 90] $audace(photometry,configure,config,altitude)] ; # site (ici en format GPS)
		set name "OBJECT"
		set ra [mc_angle2deg $audace(photometry,prepare,config,ra)]
		set dec [mc_angle2deg $audace(photometry,prepare,config,dec) 90]
		set date1 [expr [mc_date2jd $audace(photometry,prepare,config,date_night)]-1.]
		set date2 [expr [mc_date2jd $audace(photometry,prepare,config,date_night)]+1.]
		set path [file dirname $audace(photometry,prepare,config,file_cat)]
		set fic_loneos_coord [file join ${path} [file tail $audace(photometry,prepare,config,file_cat)]]
		set fic_selecfield [file join $audace(rep_images) $audace(photometry,prepare,config,file_out)]
		set errnum [catch {photom_selectfield $home $name $ra $dec $date1 $date2 $path $fic_loneos_coord $fic_selecfield} msg]
		if {$errnum==1} {
			::console::affiche_erreur "$msg\n"
		} else {
			::console::affiche_resultat "$msg\n"
		}
	}


}

# =================================================================================
# =================================================================================
# =================================================================================
# =================================================================================
# source [pwd]/audace/plugin/tool/photometry/photometry_prepare.tcl

set errphot [ catch {
	::photometry_prepare::run
} msg ]

if {$errphot==1} {
	::console::affiche_erreur "$msg\n"
}
