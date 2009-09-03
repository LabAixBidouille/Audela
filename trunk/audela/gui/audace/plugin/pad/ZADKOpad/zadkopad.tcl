#
# Fichier : zadkopad.tcl
# Description : Raquette virtuelle du LX200
# Auteur : Alain KLOTZ
# Mise a jour $Id: zadkopad.tcl,v 1.5 2009-09-03 16:15:30 myrtillelaas Exp $
#

namespace eval ::zadkopad {
   package provide zadkopad 1.0
   package require audela 1.4.0
   source [ file join [file dirname [info script]] zadkopad.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
	  global port modetelescope
	   
	  set port(adressePCcontrol) 121.200.43.11
	  set port(maj) 30032
	  set port(tel) 30011
	  set modetelescope 0
      #--- Cree les variables dans conf(...) si elles n'existent pas
      initConf
      #--- J'initialise les variables widget(..)
      confToWidget
      
   }
   #------------------------------------------------------------
   #  getPluginProperty
   #     retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete, ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
      }
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le label du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(zadkopad,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "zadkopad.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "pad"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(zadkopad,padsize) ] }  { set conf(zadkopad,padsize)  "0.6" }
      if { ! [ info exists conf(zadkopad,position) ] } { set conf(zadkopad,position) "657+252" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(padsize) $conf(zadkopad,padsize)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #
   #  return rien
   #
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(zadkopad,padsize) $widget(padsize)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Frame de la taille de la raquette
      frame $frm.frame1 -borderwidth 0 -relief raised

         #--- Label de la taille de la raquette
         label $frm.frame1.labSize -text "$caption(zadkopad,pad_size)"
         pack $frm.frame1.labSize -anchor nw -side left -padx 10 -pady 10

         #--- Definition de la taille de la raquette
         set list_combobox [ list 0.5 0.6 0.7 0.8 0.9 1.0 ]
         ComboBox $frm.frame1.taille \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [llength $list_combobox ] \
            -relief sunken           \
            -borderwidth 1           \
            -editable 0              \
            -textvariable ::zadkopad::widget(padsize) \
            -values $list_combobox
         pack $frm.frame1.taille -anchor nw -side left -padx 10 -pady 10

      pack $frm.frame1 -side top -fill both -expand 0

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }

   #------------------------------------------------------------
   #  createPluginInstance
   #     cree une intance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc createPluginInstance { } {
      global conf

      #--- Affiche la raquette
      zadkopad::run $conf(zadkopad,padsize) $conf(zadkopad,position)

      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      global audace conf paramhorloge

      if { [ winfo exists .zadkopad ] } {
         #--- Enregistre la position de la raquette
         set geom [wm geometry .zadkopad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(zadkopad,position) [string range $geom $deb $fin]
      }
	  set paramhorloge(sortie) "1"
	  
	  #--- rend la main a ros
	  #modeZADKO 0
	  
      #--- Supprime la raquette
      destroy .zadkopad

      return
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du plugin
   #
   #  return 0 (ready), 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du plugin
   #==============================================================
   #------------------------------------------------------------
   #  open socket
   #     
   #------------------------------------------------------------
   proc dialoguesocket {adressseIP port texte} {
	   
		set f [socket $adressseIP $port]
		fconfigure $f -blocking 0 -buffering none 
		puts $f "$texte"
		after 1000
		set reponse [read $f]
		close $f
		return $reponse
   }
   #------------------------------------------------------------
   #  change mode du telescope
   #     manuel(1)/auto
   #------------------------------------------------------------
	proc modeZADKO { mode } {
		global port modetelescope
		
		set texte "DO eval "
		append texte  {expr 1+1}
		
     	if {($mode==1)&&($modetelescope==0)} {
	 		#passer en mode manuel du majordome
	 		
	 		set reponse [dialoguesocket $port(adressePCcontrol) $port(maj) $texte]
	 		::console::affiche_resultat "$reponse"
			
	 		if {$reponse!=2} {
		 		# --- le majordome ne repond pas
		 		.zadkopad.func.closedome configure -relief groove -state disabled
		 		.zadkopad.func.opendome configure -relief groove -state disabled
		 		.zadkopad.func.init configure -relief groove -state disabled
		 		.zadkopad.track.trackclose configure -relief groove -state disabled
		 		.zadkopad.track.trackopen configure -relief groove -state disabled
		 		.zadkopad.tel.init configure -relief groove -state disabled
		 		.zadkopad.tel.parking configure -relief groove -state disabled
		 		.zadkopad.petal.petalopen configure -relief groove -state disabled
		 		.zadkopad.petal.petalclose configure -relief groove -state disabled
		 		.zadkopad.foc.enter configure -relief groove -state disabled
		 		.zadkopad.frame1.frame3.f.but1 configure -relief groove -state disabled
		 		update
		 		
		 		set modetelescope 0
		 	} else {
				.zadkopad.mode.manual configure -relief groove -state disabled			
				# ouvrir socket
				#set reponse [dialoguesocket $port(adressePCcontrol) $port(tel) $texte]
				::console::affiche_resultat "$reponse"
					
				# --- passer majordome en mode manuel
				roscommande {majordome DO mysql ModeSysteme MANUAL}
				
				set modetelescope 1
			}
     		
		} elseif {$modetelescope==1} {
			# --- passer majordome en mode auto
			#passer en mode manuel du majordome
	 		set reponse [dialoguesocket $port(adressePCcontrol) $port(maj) $texte]
	 		::console::affiche_resultat "$reponse"
			
	 		if {$reponse!=2} {
			
			}
			#roscommande {majordome DO mysql ModeSysteme AUTO}
		}
	}
   #------------------------------------------------------------
   #    ros commande 
   #     
   #------------------------------------------------------------
	proc roscommande { msg } {
		global port
		
		::console::affiche_resultat "$msg"
		set nameexe [lindex $msg 0]
		
		set ordre [lrange $msg 1 end]
        
		if {([string compare -nocase $nameexe "majordome"] == 0) || ([string compare -nocase $nameexe telescope]==0)} {
			if {$nameexe=="majordome"} {
				set portCom $port(maj)
			} elseif { $nameexe=="telescope"} {
				set portCom $port(tel)
			}
			
			# ouvrir socket
			set reponse [dialoguesocket $port(adressePCcontrol) $portCom $ordre]
			::console::affiche_resultat "$reponse"	
		} 
		return $reponse
	}
   #------------------------------------------------------------
   #  run
   #     cree la fenetre de la raquette
   #------------------------------------------------------------
   proc run { {zoom .5} {positionxy 0+0} } {
      variable widget
      global audace caption color geomlx200 statustel zonelx200 paramhorloge base

      if { [ string length [ info commands .zadkopad.display* ] ] != "0" } {
         destroy .zadkopad
      }

      if { $zoom <= "0" } {
         destroy .zadkopad
         return
      }

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================
	  set zoom 1
      set statustel(speed) "0"

      #--- Definition of colorlx200s
      #--- Definition des couleurs
      set colorlx200(backkey)  $color(gray_pad)
      set colorlx200(backtour) $color(cyan)
      set colorlx200(backpad)  $color(blue_pad)
      #set colorlx200(backdisp) $color(red_pad)
      set colorlx200(textkey)  $color(yellow)
      set colorlx200(textdisp) $color(black)

      #--- Definition des geomlx200etries
      #--- Definition of geometry
      set geomlx200(larg)       [ expr int(900*$zoom) ]
      set geomlx200(long)       [ expr int(810*$zoom+40) ]
      set geomlx200(fontsize25) [ expr int(25*$zoom) ]
      set geomlx200(fontsize20) [ expr int(20*$zoom) ]
      set geomlx200(fontsize16) [ expr int(16*$zoom) ]
      set geomlx200(fontsize14) [ expr int(14*$zoom) ]      
      set geomlx200(10pixels)   [ expr int(10*$zoom) ]
      set geomlx200(15pixels)   [ expr int(15*$zoom) ]
      set geomlx200(16pixels)   [ expr int(16*$zoom) ]
      set geomlx200(20pixels)   [ expr int(20*$zoom) ]
      set geomlx200(21pixels)   [ expr int(21*$zoom) ]
      set geomlx200(30pixels)   [ expr int(30*$zoom) ]
      set geomlx200(430pixels)   [ expr int(430*$zoom) ]
      set geomlx200(haut)       [ expr int(70*$zoom) ]
      set geomlx200(linewidth0) [ expr int(3*$zoom) ]
      set geomlx200(linewidth)  [ expr int($geomlx200(linewidth0)+1) ]

      if { $geomlx200(linewidth0) <= "1" } { set geomlx200(textthick) "" } else { set geomlx200(textthick) "bold" }
      
	#--- Initialisation
	set paramhorloge(sortie)     "0"
	set radec [ roscommande {telescope TEL radec coord}]
	set paramhorloge(ra)         [lindex $radec 0]
	set paramhorloge(dec)        [lindex $radec 1]
	set paramhorloge(home)       $audace(posobs,observateur,gps)
	set paramhorloge(color,back) #123456
	set paramhorloge(color,text) #FFFFAA
	set paramhorloge(font)       {times 30 bold}
	
	set paramhorloge(new,ra)     "$paramhorloge(ra)"
	set paramhorloge(new,dec)    "$paramhorloge(dec)"
	
      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .zadkopad de niveau le plus haut
      toplevel .zadkopad -class Toplevel -bg $colorlx200(backpad)
      wm geometry .zadkopad $geomlx200(larg)x$geomlx200(long)+$positionxy
      wm resizable .zadkopad 0 0
      wm title .zadkopad $caption(zadkopad,titre)
      wm protocol .zadkopad WM_DELETE_WINDOW "::zadkopad::deletePluginInstance"

      #--- Create the title
      label .zadkopad.meade \
         -font [ list {Arial} $geomlx200(fontsize25) $geomlx200(textthick) ] -text "Telescope And Dome Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(backtour)
      pack .zadkopad.meade \
         -in .zadkopad -fill x -side top

      frame .zadkopad.display \
         -borderwidth 4  -relief sunken \
         -bg $colorlx200(backtour)
      pack .zadkopad.display -in .zadkopad \
         -fill x -side top \
         -pady $geomlx200(10pixels) -padx 12

      #--- Create a dummy space
      frame .zadkopad.dum1 \
         -height $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.dum1 \
         -in .zadkopad -side top -fill x
         
#--- Create a frame for change mode
      frame .zadkopad.mode \
         -height $geomlx200(haut) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.mode \
         -in .zadkopad -side top -pady 10
      
	  button .zadkopad.mode.manual -width $geomlx200(20pixels) -relief flat -bg $colorlx200(textdisp) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text MANUAL \
         -borderwidth 0 -relief flat -bg $colorlx200(textdisp) \
         -fg $colorlx200(backtour) -command {::zadkopad::modeZADKO 1}\
         
	  pack  .zadkopad.mode.manual -in .zadkopad.mode -padx [ expr int(11*$zoom) ] -side right

 
#--- Create a frame for the dome control button
      frame .zadkopad.func \
         -height $geomlx200(haut) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.func \
         -in .zadkopad -side top -pady 10
         
      #--- Dome control
      label .zadkopad.func.dome \
         -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Dome Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .zadkopad.func.dome \
         -in .zadkopad.func -side left
     
         
	  button .zadkopad.func.opendome -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OPEN \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)\
         
	  button .zadkopad.func.closedome -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text CLOSE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)\
         
      button .zadkopad.func.init -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text INIT \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)\
         
	  pack  .zadkopad.func.closedome .zadkopad.func.opendome .zadkopad.func.init -in .zadkopad.func -padx [ expr int(11*$zoom) ] -side right

             
#--- Create a frame for the telescope control button
      frame .zadkopad.tel \
         -height $geomlx200(haut) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.tel \
         -in .zadkopad -side top -fill x -pady 10
         
       #--- Telescope control
      label .zadkopad.tel.telescope \
         -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Telescope Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .zadkopad.tel.telescope \
         -in .zadkopad.tel -side left
         
      button .zadkopad.tel.init -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text INIT \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \
		
	  button .zadkopad.tel.parking -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text PARKING \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \

	  pack .zadkopad.tel.init .zadkopad.tel.parking -in .zadkopad.tel -padx [ expr int(11*$zoom) ] -side left
            
#--- Create a frame for the mirror door button
      frame .zadkopad.petal \
         -height $geomlx200(haut) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.petal \
         -in .zadkopad -side top -fill x -pady 10
         
       #--- petal control
      label .zadkopad.petal.telescope \
         -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Mirror Door Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .zadkopad.petal.telescope \
         -in .zadkopad.petal -side left
         
      button .zadkopad.petal.petalopen -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OPEN \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \

	  button .zadkopad.petal.petalclose -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text CLOSE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \

	  pack  .zadkopad.petal.petalopen .zadkopad.petal.petalclose  -in .zadkopad.petal -padx [ expr int(11*$zoom) ] -side left

             
#--- Create a frame for the tracking buttons
      frame .zadkopad.track \
         -height $geomlx200(haut) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.track \
         -in .zadkopad -side top -fill x -pady 10
         
       #--- track control
      label .zadkopad.track.telescope \
         -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Tracking Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .zadkopad.track.telescope \
         -in .zadkopad.track -side left
         
      button .zadkopad.track.trackopen -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text ON \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \

	  button .zadkopad.track.trackclose -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OFF \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \

	  pack .zadkopad.track.trackopen .zadkopad.track.trackclose -in .zadkopad.track -padx [ expr int(11*$zoom) ] -side left

		.zadkopad.track.trackclose configure -relief groove -state disabled
         update
     
#--- Create a dummy space
      frame .zadkopad.vide \
         -height $geomlx200(20pixels) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.vide \
         -in .zadkopad -side top -fill x -pady 10
          
#--- Create a frame for the focalisation value
      frame .zadkopad.foc \
         -height $geomlx200(haut) \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.foc \
         -in .zadkopad -side top -fill x -pady 10
         
      label .zadkopad.foc.telescope \
         -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Focalisation" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(textkey)
      pack .zadkopad.foc.telescope \
         -in .zadkopad.foc -side left
         
      entry .zadkopad.foc.ent1 -textvariable focal_number \
	         -width $geomlx200(16pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
	         -bg $colorlx200(backtour)  -fg $colorlx200(backpad) \
	         -relief flat
	         
	  button .zadkopad.foc.enter -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text SEND \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey) \

         
	  pack  .zadkopad.foc.ent1 .zadkopad.foc.enter -in .zadkopad.foc -padx [ expr int(11*$zoom) ] -side left

#--- Create a frame for Telescope Information
      frame .zadkopad.frame1 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack .zadkopad.frame1 \
         -in .zadkopad -side top -fill x -pady 10
         
      frame .zadkopad.frame1.frame2 \
         -borderwidth 5 -relief flat -width $geomlx200(430pixels) -bg $colorlx200(backkey) 
         
      pack .zadkopad.frame1.frame2 \
         -in .zadkopad.frame1 -side right -fill x -expand true -pady 10 -padx 10
      frame .zadkopad.frame1.frame3 \
         -borderwidth 5 -relief flat -width $geomlx200(430pixels) -bg $colorlx200(backkey)
      pack .zadkopad.frame1.frame3 \
         -in .zadkopad.frame1 -side left -fill x -expand true -pady 10 -padx 10

 	#--- label de droite
      label .zadkopad.frame1.frame2.telescope \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text "Telescope Information" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(backtour)
      pack .zadkopad.frame1.frame2.telescope \
         -in .zadkopad.frame1.frame2 -side top -fill x -expand true
         
      set base ".zadkopad.frame1.frame2"
	  frame $base.f -bg $colorlx200(backpad)
	   
	  label $base.f.lab_tu \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	  label $base.f.lab_tsl \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	  pack $base.f.lab_tu -fill none -pady 2
	  pack $base.f.lab_tsl -fill none -pady 2
	   #---
	  frame $base.f.ra -bg $colorlx200(backpad)
		  label $base.f.ra.lab1 -text "Right Ascension (h m s):" \
		         -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
		         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
		  entry $base.f.ra.ent1 -textvariable paramhorloge(ra) \
		         -width $geomlx200(10pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
		         -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
		         -relief flat
		   pack $base.f.ra.lab1 -side left -fill none
		   pack $base.f.ra.ent1 -side left -fill none
	   pack $base.f.ra -fill none -pady 2
	   frame $base.f.dec -bg $colorlx200(backpad)
	      label $base.f.dec.lab1 -text "Declination (+/- ° ' ''):" \
	         -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	      entry $base.f.dec.ent1 -textvariable paramhorloge(dec) \
	         -width $geomlx200(10pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
	         -bg $colorlx200(backpad) \
	          -fg $colorlx200(textkey) -relief flat
	      pack $base.f.dec.lab1 -side left -fill none
	      pack $base.f.dec.ent1 -side left -fill none
	   pack $base.f.dec -fill none -pady 2
	   
	   
	   #---
	   label $base.f.lab_ha \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	   label $base.f.lab_altaz \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	   pack $base.f.lab_ha -fill none -pady 2
	   pack $base.f.lab_altaz -fill none -pady 2
	   label $base.f.lab_secz \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	   pack $base.f.lab_secz -fill none -pady 2
	   
	   button $base.f.but1 -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OFF \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)\
         -text "Refresh" -command {::zadkopad::calculz}
	   pack $base.f.but1 -ipadx 5 -ipady 5 -pady 20
	pack $base.f -fill both
	
	#bind $base.f.ra.ent1 <Enter> { met_a_jour }
	#bind $base.f.dec.ent1 <Enter> { met_a_jour }
	
         
         
     #--- label de gauche
     label .zadkopad.frame1.frame3.telescope \
         -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text "Move Telescope" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) \
         -fg $colorlx200(backtour)
     pack .zadkopad.frame1.frame3.telescope \
         -in .zadkopad.frame1.frame3 -side top -fill x -expand true
         
		
	  set base2 ".zadkopad.frame1.frame3"
	  frame $base2.f -bg $colorlx200(backpad)
	  #---
	  frame $base2.f.vid \
         -height 12 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
      pack $base2.f.vid \
         -in $base2.f -side top -fill x -pady 10
         
	  label $base2.f.lab_tu \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	  label $base2.f.lab_tsl \
	      -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	      -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	  pack $base2.f.lab_tu -fill none -pady 2
	  pack $base2.f.lab_tsl -fill none -pady 2
	  #---
	  frame $base2.f.ra -bg $colorlx200(backpad)
	      label $base2.f.ra.lab1 -text "Right Ascension (h m s):" \
	         -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	      entry $base2.f.ra.ent1 -textvariable paramhorloge(new,ra) \
	         -width 10  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
	         -bg $colorlx200(backtour)  -fg $colorlx200(backpad) \
	         -relief flat
	      pack $base2.f.ra.lab1 -side left -fill none
	      pack $base2.f.ra.ent1 -side left -fill none
	  pack $base2.f.ra -fill none -pady 2
	  frame $base2.f.dec -bg $colorlx200(backpad)
	      label $base2.f.dec.lab1 -text "Declination (+/- ° ' ''):" \
	         -bg $colorlx200(backpad)  -fg $colorlx200(textkey) \
	         -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
	      entry $base2.f.dec.ent1 -textvariable paramhorloge(new,dec)\
	         -width 10  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
	         -bg $colorlx200(backtour)  -fg $colorlx200(backpad) \
	          -relief flat
	      pack $base2.f.dec.lab1 -side left -fill none
	      pack $base2.f.dec.ent1 -side left -fill none
	  pack $base2.f.dec -fill none -pady 2
	  #--- Create a dummy space
	   frame $base2.f.vide \
         -height 11 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
       pack $base2.f.vide \
         -in $base2.f -side top -fill x -pady 10
         
	   button $base2.f.but1 -width $geomlx200(15pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OFF \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) \
         -fg $colorlx200(textkey)\
         -text "SEND" 
	   pack $base2.f.but1 -ipadx 5 -ipady 5 -pady 20	   
	   #--- Create a dummy space
	   frame $base2.f.vide2 \
         -height 12 \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad)
       pack $base2.f.vide2 \
         -in $base2.f -side top -fill x -pady 10
	   
	pack $base2.f -fill both
 	
#	bind $base2.f2.ra2.ent2 <Enter> { ::zadkopad::met_a_jour }
#	bind $base2.f2.dec2.ent2 <Enter> { ::zadkopad::met_a_jour }

	#---

      #--- La fenetre est active
      focus .zadkopad

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind .zadkopad <Key-F1> { ::console::GiveFocus }

      # =======================================
      # === It is the end of the script run ===
      # =======================================
      ::zadkopad::calculz
      #--- Je passe en mode manuel sur le telescope ZADKO
      ::zadkopad::modeZADKO 1
   }
   
proc calculz { } {
   global caption
   global base
   global paramhorloge

   if { $paramhorloge(sortie) != "1" } {
	set paramhorloge(ra) "$paramhorloge(new,ra)"
   set paramhorloge(dec) "$paramhorloge(new,dec)"
      set now now
      catch {set now [::audace::date_sys2ut now]}
      set tu [mc_date2ymdhms $now ]
      set h [format "%02d" [lindex $tu 3]]
      set m [format "%02d" [lindex $tu 4]]
      set s [format "%02d" [expr int(floor([lindex $tu 5]))]]
      $base.f.lab_tu configure -text "Universal Time: ${h}h ${m}mn ${s}s"
      set tsl [mc_date2lst $now $paramhorloge(home)]
      set h [format "%02d" [lindex $tsl 0]]
      set m [format "%02d" [lindex $tsl 1]]
      set s [format "%02d" [expr int(floor([lindex $tsl 2]))]]
      $base.f.lab_tsl configure -text "Local Sidereal Time: ${h}h ${m}mn ${s}s"
      set paramhorloge(ra1) "[ lindex $paramhorloge(ra) 0 ]h[ lindex $paramhorloge(ra) 1 ]m[ lindex $paramhorloge(ra) 2 ]"
      set paramhorloge(dec1) "[ lindex $paramhorloge(dec) 0 ]d[ lindex $paramhorloge(dec) 1 ]m[ lindex $paramhorloge(dec) 2 ]"
      set res [mc_radec2altaz "$paramhorloge(ra1)" "$paramhorloge(dec1)" "$paramhorloge(home)" $now]
      set az  [format "%5.2f" [lindex $res 0]]
      set alt [format "%5.2f" [lindex $res 1]]
      set ha  [lindex $res 2]
      set res [mc_angle2hms $ha]
      set h [format "%02d" [lindex $res 0]]
      set m [format "%02d" [lindex $res 1]]
      set s [format "%02d" [expr int(floor([lindex $res 2]))]]
      $base.f.lab_ha configure -text "Hour Angle: ${h}h ${m}mn ${s}s"
      $base.f.lab_altaz configure -text "Azimuth: ${az}° - Elevation: ${alt}°"
      if { $alt >= "0" } {
         set distanceZenithale [ expr 90.0 - $alt ]
         set distanceZenithale [ mc_angle2rad $distanceZenithale ]
         set secz [format "%5.2f" [ expr 1. / cos($distanceZenithale) ] ]
      } else {
         set secz "The target is below the horizon."
      }
      $base.f.lab_secz configure -text "sec z: ${secz}"
      update
      #--- An infinite loop to change the language interactively
      after 1000 {::zadkopad::calculz}
   } else {
      #--- Rien
   }
}

# proc met_a_jour { } {
#    global paramhorloge
# 
#    set paramhorloge(ra) "$paramhorloge(new,ra)"
#    set paramhorloge(dec) "$paramhorloge(new,dec)"
# }

}

