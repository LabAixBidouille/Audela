# =================================================================================
# =================================================================================
# =================================================================================
# =================================================================================

namespace eval ::spectro_configure {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .spectro.* ] ] != "0" } {
         destroy .spectro
      }

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      set statustel(speed) "0"

      #--- Definition of colorohps
      #--- Definition des couleurs
      set audace(spectro,configure,color,backpad)  #F0F0FF
      set audace(spectro,configure,color,backdisp) $color(white)
      set audace(spectro,configure,color,textkey)  $color(blue_pad)
      set audace(spectro,configure,color,textdisp) #FF0000

      set geomohp(larg) 970
      set geomohp(long) 500

      set audace(spectro,configure,config,code_obs) 500
      if {[info exists audace(spectro,configure,config,longitude)]==0} {
	      set audace(spectro,configure,config,longitude) [lindex $audace(posobs,observateur,gps) 1]
      }
      if {[info exists audace(spectro,configure,config,sens)]==0} {
      	set audace(spectro,configure,config,sens) [lindex $audace(posobs,observateur,gps) 2]
      }
      if {[info exists audace(spectro,configure,config,latitude)]==0} {
      	set audace(spectro,configure,config,latitude) [lindex $audace(posobs,observateur,gps) 3]
      }
      if {[info exists audace(spectro,configure,config,altitude)]==0} {
      	set audace(spectro,configure,config,altitude) [lindex $audace(posobs,observateur,gps) 4]
      }
      set audace(spectro,configure,config,desc_camera) "Sbig ST7"
      set audace(spectro,configure,config,desc_telescope) "Celestron 11"
      set audace(spectro,configure,config,desc_location) "Trifouilli les Oies"
		set audace(spectro,configure,config,tel_diam) 0.28
		set audace(spectro,configure,config,tel_fd) 6.1
		set audace(spectro,configure,config,comment) "Pleine Lune"

		set audace(spectro,configure,font,c12b) [ list {Courier} 10 bold ]
		set audace(spectro,configure,font,c10b) [ list {Courier} 10 bold ]

      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .spectro de niveau le plus haut
      toplevel .spectro -class Toplevel -bg $audace(spectro,configure,color,backpad)
      wm geometry .spectro $geomohp(larg)x$geomohp(long)+$positionxy
      wm resizable .spectro 0 0
      wm title .spectro $caption(spectro,configure,titre)
      wm protocol .spectro WM_DELETE_WINDOW "::spectro_configure::stop"

      #--- Create the title
      #--- Cree le titre
      label .spectro.title \
         -font [ list {Arial} 16 bold ] -text "$caption(spectro,configure,titre2)" \
         -borderwidth 0 -relief flat -bg $audace(spectro,configure,color,backpad) \
         -fg $audace(spectro,configure,color,textkey)
      pack .spectro.title \
         -in .spectro -fill x -side top -pady 5

      # --- boutons
	   frame .spectro.buttons -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	button .spectro.load_button  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,load_button)" \
         	-command {::spectro_configure::load}
      	pack  .spectro.load_button -in .spectro.buttons -side left -fill none -padx 3
      	button .spectro.save_button  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,save_button)" \
         	-command {::spectro_configure::save}
      	pack  .spectro.save_button -in .spectro.buttons -side left -fill none -padx 3
      	button .spectro.return_button  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,return_button)" \
         	-command {::spectro_configure::go}
      	pack  .spectro.return_button -in .spectro.buttons -side left -fill none -padx 3
      pack .spectro.buttons -in .spectro -fill x -pady 3 -padx 3 -anchor s -side bottom

      #--- IMAGES BRUTES .FITS
      frame .spectro.namerawfits -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.namerawfits.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,code_obs) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.namerawfits.label -in .spectro.namerawfits -side left -fill none
	      entry  .spectro.namerawfits.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,code_obs) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.namerawfits.entry -in .spectro.namerawfits -side left -fill none
      pack .spectro.namerawfits -in .spectro -fill none -pady 1 -padx 12

      #--- IMAGES BRUTES
      frame .spectro.nameraw -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.nameraw.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,longitude) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.nameraw.label -in .spectro.nameraw -side left -fill none
	      entry  .spectro.nameraw.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,longitude) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.nameraw.entry -in .spectro.nameraw -side left -fill none
      pack .spectro.nameraw -in .spectro -fill none -pady 1 -padx 12

      #--- TELESCOPE
      frame .spectro.telescope -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.telescope.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,sens) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.telescope.label -in .spectro.telescope -side left -fill none
	      entry  .spectro.telescope.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,sens) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 10
      	pack  .spectro.telescope.entry -in .spectro.telescope -side left -fill none
      pack .spectro.telescope -in .spectro -fill none -pady 1 -padx 12

      #--- RA
      frame .spectro.ra -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.ra.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,latitude) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.ra.label -in .spectro.ra -side left -fill none
	      entry  .spectro.ra.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,latitude) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 10
      	pack  .spectro.ra.entry -in .spectro.ra -side left -fill none
      pack .spectro.ra -in .spectro -fill none -pady 1 -padx 12

      #--- DEC
      frame .spectro.dec -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.dec.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,altitude) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.dec.label -in .spectro.dec -side left -fill none
	      entry  .spectro.dec.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,altitude) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 10
      	pack  .spectro.dec.entry -in .spectro.dec -side left -fill none
      pack .spectro.dec -in .spectro -fill none -pady 1 -padx 12

      #--- dark
      frame .spectro.dark -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.dark.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,desc_telescope) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.dark.label -in .spectro.dark -side left -fill none
	      entry  .spectro.dark.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,desc_telescope) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.dark.entry -in .spectro.dark -side left -fill none
      pack .spectro.dark -in .spectro -fill none -pady 1 -padx 12

		#--- flat
      frame .spectro.flat -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.flat.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,desc_location) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.flat.label -in .spectro.flat -side left -fill none
	      entry  .spectro.flat.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,desc_location) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.flat.entry -in .spectro.flat -side left -fill none
      pack .spectro.flat -in .spectro -fill none -pady 1 -padx 12

      #--- pathcat
      frame .spectro.pathcat -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.pathcat.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,desc_camera) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.pathcat.label -in .spectro.pathcat -side left -fill none
	      entry  .spectro.pathcat.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,desc_camera) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.pathcat.entry -in .spectro.pathcat -side left -fill none
      pack .spectro.pathcat -in .spectro -fill none -pady 1 -padx 12

      #--- box
      frame .spectro.box -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.box.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,tel_diam) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.box.label -in .spectro.box -side left -fill none
	      entry  .spectro.box.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,tel_diam) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.box.entry -in .spectro.box -side left -fill none
      pack .spectro.box -in .spectro -fill none -pady 1 -padx 12

      #--- namein
      frame .spectro.namein -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.namein.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,tel_fd) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.namein.label -in .spectro.namein -side left -fill none
	      entry  .spectro.namein.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,tel_fd) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.namein.entry -in .spectro.namein -side left -fill none
      pack .spectro.namein -in .spectro -fill none -pady 1 -padx 12

      #--- nameout
      frame .spectro.nameout -borderwidth 3 -relief sunken -bg $audace(spectro,configure,color,backpad)
      	label .spectro.nameout.label  \
	         -font $audace(spectro,configure,font,c12b) \
         	-text "$caption(spectro,configure,config,comment) " -bg $audace(spectro,configure,color,backpad) \
         	-fg $audace(spectro,configure,color,textkey) -relief flat
      	pack  .spectro.nameout.label -in .spectro.nameout -side left -fill none
	      entry  .spectro.nameout.entry  \
         	-font $audace(spectro,configure,font,c12b) \
         	-textvariable audace(spectro,configure,config,comment) -bg $audace(spectro,configure,color,backdisp) \
         	-fg $audace(spectro,configure,color,textdisp) -relief flat -width 20
      	pack  .spectro.nameout.entry -in .spectro.nameout -side left -fill none
      pack .spectro.nameout -in .spectro -fill none -pady 1 -padx 12

	}

   proc stop {  } {
      global conf
      global audace

      if { [ winfo exists .spectro ] } {
         #--- Enregistre la position de la fenetre
         set geom [wm geometry .spectro]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(spectro,position) "[string range  $geom $deb $fin]"
      }

      #--- Supprime la fenetre
      destroy .spectro
      return
   }

   proc go {} {
      global audace
      global caption
		::console::affiche_resultat "spectro Configuration : \n"
		::console::affiche_resultat "$caption(spectro,configure,config,code_obs): $audace(spectro,configure,config,code_obs)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,longitude): $audace(spectro,configure,config,longitude)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,sens): $audace(spectro,configure,config,sens)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,latitude): $audace(spectro,configure,config,latitude)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,altitude): $audace(spectro,configure,config,altitude)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,desc_camera): $audace(spectro,configure,config,desc_camera)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,desc_telescope): $audace(spectro,configure,config,desc_telescope)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,desc_location): $audace(spectro,configure,config,desc_location)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,tel_diam): $audace(spectro,configure,config,tel_diam)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,tel_fd): $audace(spectro,configure,config,tel_fd)\n"
		::console::affiche_resultat "$caption(spectro,configure,config,comment): $audace(spectro,configure,config,comment)\n"
		::spectro_configure::stop
   }

   proc save {} {
      global conf
      global audace
      global caption
      set vars [array name audace]
      set texte ""
      foreach var $vars {
	      set ident0 "spectro,configure,config,"
	      set ident [string range $var 0 [expr [string length $ident0]-1]]
	      if {[string compare $ident $ident0]==0} {
		      append texte "set audace($var) \"$audace($var)\" \n"
	      }
      }
		#::console::affiche_resultat "$texte"
      set filename [ tk_getSaveFile -title "$caption(spectro,configure,save)" -filetypes {{configuration *.spectro}} -initialdir "$audace(rep_images)" ]
      set n [string length $filename]
      set ext [string range $filename [expr $n-[string length ".spectro"]] end]
      if {[string compare $ext ".spectro"]!=0} {
	      append filename .spectro
      }
      set f [open $filename w]
      puts -nonewline $f $texte
      close $f
   }

   proc load {} {
      global conf
      global audace
      global caption
      set filename [ tk_getOpenFile -title "$caption(spectro,configure,load)" -filetypes {{configuration *.spectro}} -initialdir "$audace(rep_images)" ]
      source $filename
   }


}

# =================================================================================
# =================================================================================
# =================================================================================
# =================================================================================
# source [pwd]/audace/plugin/tool/spectro/spectro_configure.tcl

set errphot [ catch {
	::spectro_configure::run
} msg ]

if {$errphot==1} {
	::console::affiche_erreur "$msg\n"
}
