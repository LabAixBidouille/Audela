# =================================================================================
# =================================================================================
# =================================================================================
# =================================================================================

namespace eval ::photometry_configure {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .photometry.* ] ] != "0" } {
         destroy .photometry
      }

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      set statustel(speed) "0"

      #--- Definition of colorohps
      #--- Definition des couleurs
      set audace(photometry,configure,color,backpad)  #F0F0FF
      set audace(photometry,configure,color,backdisp) $color(white)
      set audace(photometry,configure,color,textkey)  $color(blue_pad)
      set audace(photometry,configure,color,textdisp) #FF0000

      set geomohp(larg) 970
      set geomohp(long) 500

      set audace(photometry,configure,config,code_obs) LLA
      if {[info exists audace(photometry,configure,config,longitude)]==0} {
	      set audace(photometry,configure,config,longitude) [lindex $audace(posobs,observateur,gps) 1]
      }
      if {[info exists audace(photometry,configure,config,sens)]==0} {
      	set audace(photometry,configure,config,sens) [lindex $audace(posobs,observateur,gps) 2]
      }
      if {[info exists audace(photometry,configure,config,latitude)]==0} {
      	set audace(photometry,configure,config,latitude) [lindex $audace(posobs,observateur,gps) 3]
      }
      if {[info exists audace(photometry,configure,config,altitude)]==0} {
      	set audace(photometry,configure,config,altitude) [lindex $audace(posobs,observateur,gps) 4]
      }
      set audace(photometry,configure,config,desc_camera) "Sbig ST7"
      set audace(photometry,configure,config,desc_telescope) "Celestron 11"
      set audace(photometry,configure,config,desc_location) "Perpignan"
		set audace(photometry,configure,config,tel_diam) 0.28
		set audace(photometry,configure,config,tel_fd) 6.1
		set audace(photometry,configure,config,comment) ""

		set audace(photometry,configure,font,c12b) [ list {Courier} 10 bold ]
		set audace(photometry,configure,font,c10b) [ list {Courier} 10 bold ]

      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .photometry de niveau le plus haut
      toplevel .photometry -class Toplevel -bg $audace(photometry,configure,color,backpad)
      wm geometry .photometry $geomohp(larg)x$geomohp(long)+$positionxy
      wm resizable .photometry 0 0
      wm title .photometry $caption(photometry,configure,titre)
      wm protocol .photometry WM_DELETE_WINDOW "::photometry_configure::stop"

      #--- Create the title
      #--- Cree le titre
      label .photometry.title \
         -font [ list {Arial} 16 bold ] -text "$caption(photometry,configure,titre2)" \
         -borderwidth 0 -relief flat -bg $audace(photometry,configure,color,backpad) \
         -fg $audace(photometry,configure,color,textkey)
      pack .photometry.title \
         -in .photometry -fill x -side top -pady 5

      # --- boutons
	   frame .photometry.buttons -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	button .photometry.load_button  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,load_button)" \
         	-command {::photometry_configure::load}
      	pack  .photometry.load_button -in .photometry.buttons -side left -fill none -padx 3
      	button .photometry.save_button  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,save_button)" \
         	-command {::photometry_configure::save}
      	pack  .photometry.save_button -in .photometry.buttons -side left -fill none -padx 3
      	button .photometry.return_button  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,return_button)" \
         	-command {::photometry_configure::go}
      	pack  .photometry.return_button -in .photometry.buttons -side left -fill none -padx 3
      pack .photometry.buttons -in .photometry -fill x -pady 3 -padx 3 -anchor s -side bottom

      #--- IMAGES BRUTES .FITS
      frame .photometry.namerawfits -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.namerawfits.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,code_obs) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.namerawfits.label -in .photometry.namerawfits -side left -fill none
	      entry  .photometry.namerawfits.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,code_obs) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.namerawfits.entry -in .photometry.namerawfits -side left -fill none
      pack .photometry.namerawfits -in .photometry -fill none -pady 1 -padx 12

      #--- IMAGES BRUTES
      frame .photometry.nameraw -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.nameraw.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,longitude) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.nameraw.label -in .photometry.nameraw -side left -fill none
	      entry  .photometry.nameraw.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,longitude) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.nameraw.entry -in .photometry.nameraw -side left -fill none
      pack .photometry.nameraw -in .photometry -fill none -pady 1 -padx 12

      #--- TELESCOPE
      frame .photometry.telescope -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.telescope.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,sens) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.telescope.label -in .photometry.telescope -side left -fill none
	      entry  .photometry.telescope.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,sens) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 10
      	pack  .photometry.telescope.entry -in .photometry.telescope -side left -fill none
      pack .photometry.telescope -in .photometry -fill none -pady 1 -padx 12

      #--- RA
      frame .photometry.ra -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.ra.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,latitude) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.ra.label -in .photometry.ra -side left -fill none
	      entry  .photometry.ra.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,latitude) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 10
      	pack  .photometry.ra.entry -in .photometry.ra -side left -fill none
      pack .photometry.ra -in .photometry -fill none -pady 1 -padx 12

      #--- DEC
      frame .photometry.dec -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.dec.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,altitude) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.dec.label -in .photometry.dec -side left -fill none
	      entry  .photometry.dec.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,altitude) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 10
      	pack  .photometry.dec.entry -in .photometry.dec -side left -fill none
      pack .photometry.dec -in .photometry -fill none -pady 1 -padx 12

      #--- dark
      frame .photometry.dark -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.dark.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,desc_telescope) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.dark.label -in .photometry.dark -side left -fill none
	      entry  .photometry.dark.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,desc_telescope) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.dark.entry -in .photometry.dark -side left -fill none
      pack .photometry.dark -in .photometry -fill none -pady 1 -padx 12

		#--- flat
      frame .photometry.flat -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.flat.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,desc_location) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.flat.label -in .photometry.flat -side left -fill none
	      entry  .photometry.flat.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,desc_location) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.flat.entry -in .photometry.flat -side left -fill none
      pack .photometry.flat -in .photometry -fill none -pady 1 -padx 12

      #--- pathcat
      frame .photometry.pathcat -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.pathcat.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,desc_camera) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.pathcat.label -in .photometry.pathcat -side left -fill none
	      entry  .photometry.pathcat.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,desc_camera) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.pathcat.entry -in .photometry.pathcat -side left -fill none
      pack .photometry.pathcat -in .photometry -fill none -pady 1 -padx 12

      #--- box
      frame .photometry.box -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.box.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,tel_diam) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.box.label -in .photometry.box -side left -fill none
	      entry  .photometry.box.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,tel_diam) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.box.entry -in .photometry.box -side left -fill none
      pack .photometry.box -in .photometry -fill none -pady 1 -padx 12

      #--- namein
      frame .photometry.namein -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.namein.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,tel_fd) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.namein.label -in .photometry.namein -side left -fill none
	      entry  .photometry.namein.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,tel_fd) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.namein.entry -in .photometry.namein -side left -fill none
      pack .photometry.namein -in .photometry -fill none -pady 1 -padx 12

      #--- nameout
      frame .photometry.nameout -borderwidth 3 -relief sunken -bg $audace(photometry,configure,color,backpad)
      	label .photometry.nameout.label  \
	         -font $audace(photometry,configure,font,c12b) \
         	-text "$caption(photometry,configure,config,comment) " -bg $audace(photometry,configure,color,backpad) \
         	-fg $audace(photometry,configure,color,textkey) -relief flat
      	pack  .photometry.nameout.label -in .photometry.nameout -side left -fill none
	      entry  .photometry.nameout.entry  \
         	-font $audace(photometry,configure,font,c12b) \
         	-textvariable audace(photometry,configure,config,comment) -bg $audace(photometry,configure,color,backdisp) \
         	-fg $audace(photometry,configure,color,textdisp) -relief flat -width 20
      	pack  .photometry.nameout.entry -in .photometry.nameout -side left -fill none
      pack .photometry.nameout -in .photometry -fill none -pady 1 -padx 12

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
		::console::affiche_resultat "$caption(photometry,configure,config,code_obs): $audace(photometry,configure,config,code_obs)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,longitude): $audace(photometry,configure,config,longitude)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,sens): $audace(photometry,configure,config,sens)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,latitude): $audace(photometry,configure,config,latitude)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,altitude): $audace(photometry,configure,config,altitude)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,desc_camera): $audace(photometry,configure,config,desc_camera)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,desc_telescope): $audace(photometry,configure,config,desc_telescope)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,desc_location): $audace(photometry,configure,config,desc_location)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,tel_diam): $audace(photometry,configure,config,tel_diam)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,tel_fd): $audace(photometry,configure,config,tel_fd)\n"
		::console::affiche_resultat "$caption(photometry,configure,config,comment): $audace(photometry,configure,config,comment)\n"
		::photometry_configure::stop
   }

   proc save {} {
      global conf
      global audace
      global caption
      set vars [array name audace]
      set texte ""
      foreach var $vars {
	      set ident0 "photometry,configure,config,"
	      set ident [string range $var 0 [expr [string length $ident0]-1]]
	      if {[string compare $ident $ident0]==0} {
		      append texte "set audace($var) \"$audace($var)\" \n"
	      }
      }
		#::console::affiche_resultat "$texte"
      set filename [ tk_getSaveFile -title "$caption(photometry,configure,save)" -filetypes {{configuration *.photom}} -initialdir "$audace(rep_images)" ]
      set n [string length $filename]
      set ext [string range $filename [expr $n-[string length ".photom"]] end]
      if {[string compare $ext ".photom"]!=0} {
	      append filename .photom
      }
      set f [open $filename w]
      puts -nonewline $f $texte
      close $f
   }

   proc load {} {
      global conf
      global audace
      global caption
      set filename [ tk_getOpenFile -title "$caption(photometry,configure,load)" -filetypes {{configuration *.photom}} -initialdir "$audace(rep_images)" ]
      source $filename
   }


}

# =================================================================================
# =================================================================================
# =================================================================================
# =================================================================================
# source [pwd]/audace/plugin/tool/photometry/photometry_configure.tcl

set errphot [ catch {
	::photometry_configure::run
} msg ]

if {$errphot==1} {
	::console::affiche_erreur "$msg\n"
}
