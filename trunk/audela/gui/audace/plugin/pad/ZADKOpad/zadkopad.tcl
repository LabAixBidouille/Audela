#
# Fichier : zadkopad.tcl
# Description : Raquette virtuelle du LX200
# Auteur : Alain KLOTZ
# Mise a jour $Id: zadkopad.tcl,v 1.16 2009-09-16 10:13:32 myrtillelaas Exp $
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
		global port modetelescope stopcalcul paramhorloge telnum
		
		set port(adressePCcontrol) 121.200.43.11
		set port(maj) 30032
		set port(tel) 30011
		set port(gard) 30001
		set modetelescope 0
		set stopcalcul 0
		set paramhorloge(init) 0
		set telnum 1
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
      global audace conf paramhorloge modetelescope

      if { [ winfo exists .zadkopad ] } {
         #--- Enregistre la position de la raquette
         set geom [wm geometry .zadkopad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(zadkopad,position) [string range $geom $deb $fin]
      }
	  set paramhorloge(sortie) "1"
	  set modetelescope 0
	  #--- rend la main a ros
	  modeZADKO 0
	  
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
	   
		catch [ set f [socket $adressseIP $port]]
		if {[string range $f 0 3]=="sock"} {
			fconfigure $f -blocking 0 -buffering none 
			puts $f "$texte"
			after 1500
			set reponse [read $f]
			close $f
			return $reponse
		} else {
			# ne peut pas ouvrir connection
			tk_messageBox -icon error -message "No connection with $adressseIP $port" -type ok
		}
   }
   #------------------------------------------------------------
   #  change mode du telescope
   #     manuel(1)/auto
   #------------------------------------------------------------
	proc modeZADKO { mode } {
		global port modetelescope audela telnum
		
		set texte "DO eval "
		append texte  {expr 1+1}
		
     	if {($mode==1)&&($modetelescope==0)} {
	 		#passer en mode manuel du majordome
	 		
	 		set reponse [::zadkopad::dialoguesocket $port(adressePCcontrol) $port(maj) $texte]
	 		::console::affiche_resultat "$reponse \n"
			
	 		if {$reponse!=2} {
		 		# --- le majordome ne repond pas
		 		.zadkopad.func.closedome configure -relief groove -state disabled
		 		.zadkopad.func.opendome configure -relief groove -state disabled
		 		.zadkopad.tel.init configure -relief groove -state disabled
		 		.zadkopad.tel.parking configure -relief groove -state disabled
		 		.zadkopad.petal.petalopen configure -relief groove -state disabled
		 		.zadkopad.petal.petalclose configure -relief groove -state disabled
		 		.zadkopad.foc.enter configure -relief groove -state disabled		 		
		 		.zadkopad.frame1.frame2.f.but1 configure -relief groove -state disabled
		 		.zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state disabled
		 		update
		 		
		 		set modetelescope 0
		 	} else {
				# ouvrir socket
				#set reponse [dialoguesocket $port(adressePCcontrol) $port(tel) $texte]
	
				# --- passer majordome en mode manuel
				set reponse [::zadkopad::roscommande {majordome DO mysql ModeSysteme MANUAL}]
				::console::affiche_resultat "$reponse \n"
				set reponse [::zadkopad::roscommande {telescope DO eval {tel1 radec motor off}}]
				::console::affiche_resultat "$reponse \n"
				set modetelescope 1
				#--- Tue camera.exe
				package require twapi
				set res [twapi::get_process_ids -glob -name "camera.exe"]
				if {$res!=""} {
					twapi::end_process $res -force
				}
				.zadkopad.mode.manual configure -relief groove -state disabled		
		 		.zadkopad.func.closedome configure -relief groove -state normal
		 		.zadkopad.func.opendome configure -relief groove -state normal
		 		.zadkopad.tel.init configure -relief groove -state normal
		 		.zadkopad.tel.parking configure -relief groove -state normal
		 		.zadkopad.petal.petalopen configure -relief groove -state normal
		 		.zadkopad.petal.petalclose configure -relief groove -state normal
		 		.zadkopad.foc.enter configure -relief groove -state normal
		 		.zadkopad.frame1.frame2.f.but1 configure -relief groove -state normal
		 		.zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state normal
			}
     		
		} elseif {$mode==0} {
			if {$modetelescope==1} {
				#################################
				# pour contrer le bug de DFM
				::zadkopad::stopfocus
				#################################
				set reponse [::zadkopad::roscommande {telescope DO eval {tel1 radec motor off}}]
				::console::affiche_resultat "$reponse \n"
				# --- passer majordome en mode auto
				#passer en mode manuel du majordome
		 		set reponse [::zadkopad::dialoguesocket $port(adressePCcontrol) $port(maj) $texte]
	 	 		::console::affiche_resultat "$reponse \n"
	 			
	 	 		if {$reponse!=2} {
	 			
	 			}
				#set reponse [::zadkopad::roscommande {majordome DO mysql ModeSysteme AUTO}]
				#relancer si reponse pas bonne
			}
		}
	}
   #------------------------------------------------------------
   #    ros commande 
   #     
   #------------------------------------------------------------
	proc roscommande { msg } {
		global port paramhorloge 
		
		::console::affiche_resultat "$msg"
		set nameexe [lindex $msg 0]
		
		set ordre [lrange $msg 1 end]
        
		if {([string compare -nocase $nameexe "majordome"] == 0) || ([string compare -nocase $nameexe telescope]==0)|| ([string compare -nocase $nameexe gardien]==0)} {
			if {$nameexe=="majordome"} {
				set portCom $port(maj)
			} elseif { $nameexe=="telescope"} {
				set portCom $port(tel)
			} elseif { $nameexe=="gardien"} {
				set portCom $port(gard)
			}
			# ouvrir socket
			set reponse [::zadkopad::dialoguesocket $port(adressePCcontrol) $portCom $ordre]
			::console::affiche_resultat "$nameexe ordre: $ordre, reponse: $reponse \n"
			
			if {$paramhorloge(init)=="1"} {
    			.zadkopad.func.closedome configure -relief groove -state disabled
        		.zadkopad.func.opendome configure -relief groove -state disabled
        		.zadkopad.tel.init configure -relief groove -state disabled
        		.zadkopad.tel.parking configure -relief groove -state disabled
        		.zadkopad.petal.petalopen configure -relief groove -state disabled
        		.zadkopad.petal.petalclose configure -relief groove -state disabled
        		.zadkopad.foc.enter configure -relief groove -state disabled		 		
        		.zadkopad.frame1.frame2.f.but1 configure -relief groove -state disabled
        		.zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state disabled
        		update
        		
        		if {[lindex $msg 2]=="roof_open" } {
            		set temps 120000
        		} elseif {[lindex $msg 2]=="roof_close" } {
            		set temps 130000
        		} elseif {[lindex $msg 2]=="init" } {
            		set temps 210000
        		} elseif {[lindex $msg 2]=="park" } {
            		set temps 120000
        		} else {
	        		set temps 0
        		}
        		after [expr int($temps)]
        		
                .zadkopad.func.closedome configure -relief groove -state normal
        		.zadkopad.func.opendome configure -relief groove -state normal
        		.zadkopad.tel.init configure -relief groove -state normal
        		.zadkopad.tel.parking configure -relief groove -state normal
        		.zadkopad.petal.petalopen configure -relief groove -state normal
        		.zadkopad.petal.petalclose configure -relief groove -state normal
        		.zadkopad.foc.enter configure -relief groove -state normal
        		.zadkopad.frame1.frame2.f.but1 configure -relief groove -state normal
        		.zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state normal
    		}
		} 
		return $reponse
	}
   #------------------------------------------------------------
   #    goto new coordinate     
   #------------------------------------------------------------
	proc gotocoord { newra newdec suivira suividec onoff newfocus} {
		global port paramhorloge audace telnum
		
		set paramhorloge(home)       $audace(posobs,observateur,gps)
		
		::console::affiche_resultat "goto $newra $newdec \n"
		set ra [mc_angle2deg $newra]
		set dec [mc_angle2deg $newdec 90]
		
		set now now
		catch {set now [::audace::date_sys2ut now]}
		set tu [mc_date2ymdhms $now ]
		set paramhorloge(ra1) "[ lindex $newra 0 ]h[ lindex $newra 1 ]m[ lindex $newra 2 ]"
		set paramhorloge(dec1) "[ lindex $newdec 0 ]d[ lindex $newdec 1 ]m[ lindex $newdec 2 ]"
	    set res [mc_radec2altaz "$paramhorloge(ra1)" "$paramhorloge(dec1)" "$paramhorloge(home)" $now]
		set az  [format "%5.2f" [lindex $res 0]]
		set alt [format "%5.2f" [lindex $res 1]]
		set ha  [lindex $res 2]
		set tsl [mc_date2lst $now $paramhorloge(home)]
			
		::console::affiche_resultat "goto ra: $ra, dec: $dec, alt: $alt, ha: $ha \n"
		# --- teste si les coordonnees sont pointables
		if {(($ha<[expr 15*15])&&($ha>[expr 8*15]))||($alt<10)||($dec>45)||($dec<-89.5)} {			
			# --- affiche un message d'erreur
			::console::affiche_resultat "tsl: $tsl\n"
			set ts [mc_angle2deg [list $tsl] ]
			set ramin [expr $ts/15 - 8.5]
			set ramax [expr $ts/15 - 16.5*15]
			set decmin 89.5
			set decmax 45
			::console::affiche_resultat "goto erreur ramin: $ramin, ramax: $ramax, ts: $ts \n"
			# ne peut pas ouvrir connection
			tk_messageBox -icon error -message "BAD COORDINATES: must be $ramin<RA<$ramax AND ALT>10 degre AND $decmin<DEC<$decmax" -type ok
			return
		} 
		# --- teste si les vitesses de suivi sont bonnes
		if {($suivira<0)||($suividec<[expr -2*360./86164])||($suivira>[expr 2*360./86164])||($suividec>[expr 2*360./86164])} {				
			tk_messageBox -icon error -message "BAD TRACK VALUES: must be 0<TRACK_RA<0.00835 AND -0.00835<TRACK_DEC<0.00835" -type ok
			return
		} 
		
		# --- teste si le focus est bon
		if {($newfocus<2800)||($newfocus>3600)} {				
			tk_messageBox -icon error -message "BAD FOCUS VALUES: must be 2800<FOCUS<3600" -type ok
			return
		} 
		
		# --- envoie l'ordre de suivi	
		
		#################################
		# pour contrer le bug de DFM
		if 	{$onoff=="off"} {
			stopfocus
		}
		###################################
		
		# --- envoie les valeurs de suivi
		# --- envoie l'ordre de pointage au telescope
		set reponse [::zadkopad::roscommande [list telescope GOTO $newra $newdec -blocking 1]]
		::console::affiche_resultat "$reponse \n"
		if 	{$onoff=="off"} {
			set reponse [::zadkopad::roscommande [list telescope DO speedtrack 0.0 0.0]]
		} else {
		    set reponse [::zadkopad::roscommande [list telescope DO speedtrack $suivira $suividec]]
	    }
		::console::affiche_resultat "$reponse \n"		
		#set reponse [::zadkopad::roscommande [list telescope DO eval tel1 racdec motor $onoff]]
		#::console::affiche_resultat "$reponse \n"	
		
		return $reponse
	}
	
	#------------------------------------------------------------
    #    send focus     
    #------------------------------------------------------------
	proc sendfocus {newfocus} {
		global port paramhorloge audace telnum
		
		# --- teste si le focus est bon
		if {($newfocus<2800)||($newfocus>3600)} {				
			tk_messageBox -icon error -message "BAD FOCUS VALUES: must be 2800<FOCUS<3600" -type ok
			return
		} 
		# --- envoie l'ordre de focus
		set nowfocus [lindex [::zadkopad::roscommande {telescope DO eval {tel1 dfmfocus}}] 0] 
		::console::affiche_resultat "recupere le focus : $nowfocus \n"	
		#if {$nowfocus==""} {
		#		set nowfocus 3330 
		#}
		# --- envoie l'ordre de focus
		set reponse [::zadkopad::roscommande [list telescope DO eval [list tel1 dfmfocus $newfocus]]]
		::console::affiche_resultat "$reponse \n"	
		if {$nowfocus==""} {
				set temps  [expr 800*33*1000/500 + 4000]
		} else {
			  	set temps [expr [expr abs($nowfocus -$newfocus)]*33*1000/500 + 4000]
		}
		.zadkopad.func.closedome configure -relief groove -state disabled
		.zadkopad.func.opendome configure -relief groove -state disabled
		.zadkopad.tel.init configure -relief groove -state disabled
		.zadkopad.tel.parking configure -relief groove -state disabled
		.zadkopad.petal.petalopen configure -relief groove -state disabled
		.zadkopad.petal.petalclose configure -relief groove -state disabled
		.zadkopad.foc.enter configure -relief groove -state disabled		 		
		.zadkopad.frame1.frame2.f.but1 configure -relief groove -state disabled
		.zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state disabled
		update
		
		after [expr int($temps)]
		
        .zadkopad.func.closedome configure -relief groove -state normal
		.zadkopad.func.opendome configure -relief groove -state normal
		.zadkopad.tel.init configure -relief groove -state normal
		.zadkopad.tel.parking configure -relief groove -state normal
		.zadkopad.petal.petalopen configure -relief groove -state normal
		.zadkopad.petal.petalclose configure -relief groove -state normal
		.zadkopad.foc.enter configure -relief groove -state normal
		.zadkopad.frame1.frame2.f.but1 configure -relief groove -state normal
		.zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state normal
		 
		#pierre replace 30*100/500 + 3000 par 33*1000/500 +4000 dans les 2 lignes au dessus et mis un # devant ::zadkopad::stopfocus
		# suite a la correction par dfm via timo des pb du focus
		#::console::affiche_resultat "nowfocus: $nowfocus, newfocus: $newfocus, temps: $temps \n"
		#after [expr int($temps)]
		# ::zadkopad::stopfocus
		
		return $reponse
	}
	#------------------------------------------------------------
   #    send focus     
   #------------------------------------------------------------
	proc stopfocus {} {
		global port paramhorloge audace telnum
		
		set texte {DO eval {tel1 put "#13;\r"}}
		
		catch [ set f [socket $port(adressePCcontrol) $port(tel)]]
		if {[string range $f 0 3]=="sock"} {
			fconfigure $f -blocking 0 -buffering none 
			puts $f "$texte"
			after 1000
			set reponse [read $f]
			close $f
		} else {
			# ne peut pas ouvrir connection
			tk_messageBox -icon error -message "No connection with $adressseIP $port" -type ok
		}
		::console::affiche_resultat "$reponse \n"	
		return $reponse
	}
	#------------------------------------------------------------
	#    met a jour les donnes     
	#------------------------------------------------------------
	proc calculz { } {
	   global caption stopcalcul base paramhorloge 
	   
	    #::console::affiche_resultat "paramhorloge(new,ra):$paramhorloge(new,ra) ,paramhorloge(new,dec): $paramhorloge(new,dec) \n"
		if { $paramhorloge(sortie) != "1" } {
 			if {($paramhorloge(new,ra)=="")&&($paramhorloge(new,dec)=="")} {
				::console::affiche_resultat "calculz probleme with telescope connection, paramhorloge(new,ra):$paramhorloge(new,ra)\n"
				set radec [ ::zadkopad::roscommande {telescope TEL radec coord}]
				#ATTENTION rajout OFFSET de pointage DFM
 				set paramhorloge(ra)         "[lindex $radec 0]"
                set paramhorloge(dec)        "[lindex $radec 1]"
                if {($paramhorloge(ra)!="")&&($paramhorloge(dec)!="")} {
                    set dra [expr 21/60.];       # offset (deg) for hour angle
                    set ddec [expr 8./60.];      # offset (deg) for declination
                    set paramhorloge(ra)        [mc_angle2deg $paramhorloge(ra)]
                    set paramhorloge(dec)       [mc_angle2deg $paramhorloge(dec) 90]
                    set paramhorloge(ra)        [expr $paramhorloge(ra)+$dra]
                    set paramhorloge(dec)       [expr $paramhorloge(dec)+$ddec]
                    set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(ra) 360 zero 2 auto string]]
                    set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(dec  90 zero 1 + string]]  
             }   
 				set paramhorloge(new,ra) 	 $paramhorloge(ra)
 				set paramhorloge(new,dec) 	 $paramhorloge(dec)
 			} else {
				set paramhorloge(ra) $paramhorloge(new,ra)
		    	set paramhorloge(dec) $paramhorloge(new,dec)
  			}
			
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
			if {$stopcalcul==0} {
				#--- An infinite loop to change the language interactively
				after 1000 {::zadkopad::calculz}
			}
		} else {
	      #--- Rien
	   	}
	}
	#------------------------------------------------------------
	#    met a jour les donnes     
	#------------------------------------------------------------
	proc initobservatory { value } {
	   global caption base paramhorloge stopcalcul
	   
	   if {$value=="1"} {		  			
	   		::zadkopad::roscommande {telescope DO init}
   		} else {
	   		::zadkopad::roscommande {telescope DO park}
   		}
 	
	}
	#------------------------------------------------------------
	#    met a jour les donnes     
	#------------------------------------------------------------
	proc refreshcoord { } {
	   global caption base paramhorloge stopcalcul telnum
	    
	    set stopcalcul 1
	    ::console::affiche_resultat "refresh paramhorloge(new,ra):$paramhorloge(new,ra) ,paramhorloge(new,dec): $paramhorloge(new,dec) \n"

 		set radec [ ::zadkopad::roscommande {telescope TEL radec coord}]
		#ATTENTION rajout OFFSET de pointage DFM
		#ATTENTION rajout OFFSET de pointage DFM
	    set paramhorloge(ra)         "[lindex $radec 0]"
        set paramhorloge(dec)        "[lindex $radec 1]"
        if {($paramhorloge(ra)!="")&&($paramhorloge(dec)!="")} {
            set dra [expr 21/60.];       # offset (deg) for hour angle
            set ddec [expr 8./60.];      # offset (deg) for declination
            set paramhorloge(ra)        [mc_angle2deg $paramhorloge(ra)]
            set paramhorloge(dec)       [mc_angle2deg $paramhorloge(dec) 90]
            set paramhorloge(ra)        [expr $paramhorloge(ra)+$dra]
            set paramhorloge(dec)       [expr $paramhorloge(dec)+$ddec]
            set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(ra) 360 zero 2 auto string]]
            set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(dec  90 zero 1 + string]]  
     }     
		set paramhorloge(new,ra) 	 $paramhorloge(ra)
		set paramhorloge(new,dec) 	 $paramhorloge(dec)
 				
 		set paramhorloge(focal_number)	[lindex [::zadkopad::roscommande {telescope DO eval {tel1 dfmfocus}}] 0]
 		set vitessessuivie [::zadkopad::roscommande [list telescope DO speedtrack]]
 		set paramhorloge(suivira)	[lindex $vitessessuivie 0]
 		set paramhorloge(suividec)	[lindex $vitessessuivie 1] 
 		set stopcalcul 0
 		::console::affiche_resultat "refresh radec: $radec, focal_number: $paramhorloge(focal_number), vitessessuivie : $vitessessuivie\n"
 		::zadkopad::calculz
 	
	}
    #------------------------------------------------------------
    #  run
    #     cree la fenetre de la raquette
    #------------------------------------------------------------
    # PIERRE MODIFIE POSITION RAQUETTE
    proc run { {zoom .5} {positionxy 200+50} } {
        variable widget
        global audace caption color geomlx200 statustel zonelx200 paramhorloge base telnum
        
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
        set colorlx200(backdisp) $color(red_pad)
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
        set geomlx200(5pixels)   [ expr int(5*$zoom) ]     
        set geomlx200(10pixels)   [ expr int(10*$zoom) ]
        set geomlx200(15pixels)   [ expr int(15*$zoom) ]
        set geomlx200(16pixels)   [ expr int(16*$zoom) ]
        set geomlx200(20pixels)   [ expr int(20*$zoom) ]
        set geomlx200(21pixels)   [ expr int(28*$zoom) ]
        set geomlx200(30pixels)   [ expr int(30*$zoom) ]
        set geomlx200(430pixels)  [ expr int(430*$zoom)]
        set geomlx200(haut)       [ expr int(70*$zoom) ]
        set geomlx200(linewidth0) [ expr int(3*$zoom) ]
        set geomlx200(linewidth)  [ expr int($geomlx200(linewidth0)+1) ]        
        if { $geomlx200(linewidth0) <= "1" } { set geomlx200(textthick) "" } else { set geomlx200(textthick) "bold" }
      
        #--- Initialisation
        set paramhorloge(sortie)     "0"
        set radec [ roscommande {telescope TEL radec coord}]
        #ATTENTION rajout OFFSET de pointage DFM
		#ATTENTION rajout OFFSET de pointage DFM
        set paramhorloge(ra)         "[lindex $radec 0]"
        set paramhorloge(dec)        "[lindex $radec 1]"
        if {($paramhorloge(ra)!="")&&($paramhorloge(dec)!="")} {
            set dra [expr 21/60.];       # offset (deg) for hour angle
            set ddec [expr 8./60.];      # offset (deg) for declination
            set paramhorloge(ra)        [mc_angle2deg $paramhorloge(ra)]
            set paramhorloge(dec)       [mc_angle2deg $paramhorloge(dec) 90]
            set paramhorloge(ra)        [expr $paramhorloge(ra)+$dra]
            set paramhorloge(dec)       [expr $paramhorloge(dec)+$ddec]
            set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(ra) 360 zero 2 auto string]]
            set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(dec  90 zero 1 + string]]  
        }   
		set paramhorloge(new,ra) 	 "$paramhorloge(ra)"
		set paramhorloge(new,dec) 	 "$paramhorloge(dec)"
        set paramhorloge(home)       $audace(posobs,observateur,gps)
        set paramhorloge(color,back) #123456
        set paramhorloge(color,text) #FFFFAA
        set paramhorloge(font)       {times 30 bold}
        set paramhorloge(suivira)	 "0.00417808"
        set paramhorloge(suividec)   "0.0"
        set paramhorloge(focal_number)	"[lindex [::zadkopad::roscommande {telescope DO eval {tel1 dfmfocus}}] 0]" 

        ::console::affiche_resultat  "init focal_number: $paramhorloge(focal_number), paramhorloge(new,ra):$paramhorloge(new,ra), paramhorloge(new,dec): $paramhorloge(new,dec) \n"
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
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(backtour)
        pack .zadkopad.meade -in .zadkopad -fill x -side top
        
        frame .zadkopad.display -borderwidth 4  -relief sunken -bg $colorlx200(backtour)
        pack .zadkopad.display -in .zadkopad -fill x -side top -pady $geomlx200(10pixels) -padx 12
        
        #--- Create a dummy space
        frame .zadkopad.dum1 -height $geomlx200(20pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.dum1 -in .zadkopad -side top -fill x
             
        #--- Create a frame for change mode
        frame .zadkopad.mode -height $geomlx200(haut) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.mode -in .zadkopad -side top -pady 10
        
        button .zadkopad.mode.manual -width $geomlx200(20pixels) -relief flat -bg $colorlx200(textdisp) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text MANUAL \
         -borderwidth 0 -relief flat -bg $colorlx200(textdisp) -fg $colorlx200(backtour) -command {::zadkopad::modeZADKO 1}   
        pack  .zadkopad.mode.manual -in .zadkopad.mode -padx [ expr int(11*$zoom) ] -side right
        
        #--- Create a frame for the telescope and dome init button
        frame .zadkopad.tel -height $geomlx200(haut) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.tel -in .zadkopad -side top -fill x -pady 10
         
        #--- observatory control
        label .zadkopad.tel.telescope -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Observatory" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack .zadkopad.tel.telescope -in .zadkopad.tel -side left
         
        button .zadkopad.tel.init -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text INIT \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::initobservatory 1}
        button .zadkopad.tel.parking -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text "CLOSE (end of night)" \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::initobservatory 0}
        
        pack .zadkopad.tel.init .zadkopad.tel.parking -in .zadkopad.tel -padx [ expr int(11*$zoom) ] -side left
        
        #--- Create a frame for the dome control button
        frame .zadkopad.func -height $geomlx200(haut) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.func -in .zadkopad -side top -pady 10
         
        #--- Dome control
        label .zadkopad.func.dome -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Dome Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack .zadkopad.func.dome -in .zadkopad.func -side left
        
        
        button .zadkopad.func.opendome -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OPEN \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::roscommande {gardien DO roof_open}}
        button .zadkopad.func.closedome -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text CLOSE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::roscommande {gardien DO roof_close}}
        pack  .zadkopad.func.closedome .zadkopad.func.opendome -in .zadkopad.func -padx [ expr int(11*$zoom) ] -side right
        
            
        #--- Create a frame for the mirror door button
        frame .zadkopad.petal -height $geomlx200(haut) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.petal -in .zadkopad -side top -fill x -pady 10
         
        #--- petal control
        label .zadkopad.petal.telescope -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Mirror Door Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack .zadkopad.petal.telescope -in .zadkopad.petal -side left
         
        button .zadkopad.petal.petalopen -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OPEN \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::roscommande {telescope DO mirrordoors 1}}
        
        button .zadkopad.petal.petalclose -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text CLOSE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::roscommande {telescope DO mirrordoors 0}}
        
        pack  .zadkopad.petal.petalopen .zadkopad.petal.petalclose  -in .zadkopad.petal -padx [ expr int(11*$zoom) ] -side left
        
        #--- Create a dummy space
        frame .zadkopad.vide -height $geomlx200(20pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.vide -in .zadkopad -side top -fill x -pady 10
          
        #--- Create a frame for the focalisation value
        frame .zadkopad.foc -height $geomlx200(haut) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.foc -in .zadkopad -side top -fill x -pady 10
         
        label .zadkopad.foc.telescope -width $geomlx200(21pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Focalisation" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack .zadkopad.foc.telescope -in .zadkopad.foc -side left
         
        entry .zadkopad.foc.ent1 -textvariable paramhorloge(focal_number) -width $geomlx200(10pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
             -bg $colorlx200(backtour)  -fg $colorlx200(backpad) -relief flat
             
        button .zadkopad.foc.enter -width $geomlx200(10pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text SEND \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::sendfocus $paramhorloge(focal_number)}
         
        # button .zadkopad.foc.stop -width $geomlx200(10pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text STOP \
        # -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::stopfocus}
        
        pack  .zadkopad.foc.ent1 .zadkopad.foc.enter -in .zadkopad.foc -padx [ expr int(11*$zoom) ] -side left
        
        #--- Create a frame for Telescope Information
        frame .zadkopad.frame1 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.frame1 -in .zadkopad -side top -fill x -pady 10
         
        frame .zadkopad.frame1.frame2 -borderwidth 5 -relief flat -width $geomlx200(430pixels) -bg $colorlx200(backkey) 
         
        pack .zadkopad.frame1.frame2 -in .zadkopad.frame1 -side right -fill x -expand true -pady 10 -padx 10
        frame .zadkopad.frame1.frame3 -borderwidth 5 -relief flat -width $geomlx200(430pixels) -bg $colorlx200(backkey)
        pack .zadkopad.frame1.frame3 -in .zadkopad.frame1 -side left -fill x -expand true -pady 10 -padx 10
        
        #--- label de droite
        label .zadkopad.frame1.frame2.telescope -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text "Telescope Information" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(backtour)
        pack .zadkopad.frame1.frame2.telescope -in .zadkopad.frame1.frame2 -side top -fill x -expand true
         
        set base ".zadkopad.frame1.frame2"
        frame $base.f -bg $colorlx200(backpad)
        
        label $base.f.lab_tu -bg $colorlx200(backpad) -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
        label $base.f.lab_tsl -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
        pack $base.f.lab_tu -fill none -pady 2
        pack $base.f.lab_tsl -fill none -pady 2
        #---
        frame $base.f.ra -bg $colorlx200(backpad)
          label $base.f.ra.lab1 -text "Right Ascension (h m s):" -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
          entry $base.f.ra.ent1 -textvariable paramhorloge(ra) -width $geomlx200(10pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
                 -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -relief flat
           pack $base.f.ra.lab1 -side left -fill none
           pack $base.f.ra.ent1 -side left -fill none
        pack $base.f.ra -fill none -pady 2
        frame $base.f.dec -bg $colorlx200(backpad)
          label $base.f.dec.lab1 -text "Declination (+/- ° ' ''):" -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
          entry $base.f.dec.ent1 -textvariable paramhorloge(dec) -width $geomlx200(10pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
             -bg $colorlx200(backpad) -fg $colorlx200(textkey) -relief flat
          pack $base.f.dec.lab1 -side left -fill none
          pack $base.f.dec.ent1 -side left -fill none
        pack $base.f.dec -fill none -pady 2
        
        
        #---
        label $base.f.lab_ha -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
        label $base.f.lab_altaz -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
        pack $base.f.lab_ha -fill none -pady 2
        pack $base.f.lab_altaz -fill none -pady 2
        label $base.f.lab_secz -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
        pack $base.f.lab_secz -fill none -pady 2
        
        button $base.f.but1 -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OFF \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -text "Refresh" -command {::zadkopad::refreshcoord}
        pack $base.f.but1 -ipadx 5 -ipady 5 -pady 20
        pack $base.f -fill both
        
        #--- label de gauche
        label .zadkopad.frame1.frame3.telescope -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text "Move Telescope" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(backtour)
        pack .zadkopad.frame1.frame3.telescope -in .zadkopad.frame1.frame3 -side top -fill x -expand true
         	
        set base2 ".zadkopad.frame1.frame3"
        frame $base2.f -bg $colorlx200(backpad)
        #--- Create a dummy space
        frame $base2.f.vid -height 2 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base2.f.vid -in $base2.f -side top -fill x -pady 5
        #---
        frame $base2.f.ra -bg $colorlx200(backpad)
          label $base2.f.ra.lab1 -text "Right Ascension (h m s):" -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
          entry $base2.f.ra.ent1 -textvariable paramhorloge(new,ra) -width 10  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
             -bg $colorlx200(backtour)  -fg $colorlx200(backpad) -relief flat
          pack $base2.f.ra.lab1 -side left -fill none
          pack $base2.f.ra.ent1 -side left -fill none
        pack $base2.f.ra -fill none -pady 2
        frame $base2.f.dec -bg $colorlx200(backpad)
          label $base2.f.dec.lab1 -text "Declination (+/- ° ' ''):" -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
          entry $base2.f.dec.ent1 -textvariable paramhorloge(new,dec) -width 10  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
             -bg $colorlx200(backtour)  -fg $colorlx200(backpad) -relief flat
          pack $base2.f.dec.lab1 -side left -fill none
          pack $base2.f.dec.ent1 -side left -fill none
        pack $base2.f.dec -fill none -pady 2
        #--- Create a dummy space
        frame $base2.f.vide -height 2 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base2.f.vide -in $base2.f -side top -fill x -pady 5
             
        #--- track control
        frame $base2.f.f3 -height 15 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base2.f.f3 -in $base2.f -side top -fill x -pady 10
        label $base2.f.f3.telescope \
         -width $geomlx200(30pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Tracking Control (degre/sec)" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack $base2.f.f3.telescope -in $base2.f.f3 -side top
        
        label $base2.f.f3.focra \
         -width $geomlx200(5pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "RA" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        label $base2.f.f3.focdec \
         -width $geomlx200(5pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "DEC" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        
        entry $base2.f.f3.ent1 -textvariable paramhorloge(suivira) -width $geomlx200(15pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
                 -bg $colorlx200(backtour) -fg $colorlx200(backpad) -relief flat
        entry $base2.f.f3.ent2 -textvariable paramhorloge(suividec) -width $geomlx200(15pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
                 -bg $colorlx200(backtour) -fg $colorlx200(backpad) -relief flat
           
        pack $base2.f.f3.focra $base2.f.f3.ent1 $base2.f.f3.focdec $base2.f.f3.ent2 -side left -fill none
        
        frame $base2.f.f2 -height 15 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base2.f.f2 -in $base2.f -side top -fill x -pady 10
        
        label $base2.f.f2.labelvide -width $geomlx200(10pixels) -borderwidth 0 -bg $colorlx200(backpad)
        pack $base2.f.f2.labelvide -in $base2.f.f2 -side left  
              
        checkbutton $base2.f.f2.trackopen -width $geomlx200(10pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text "Tracking ON" \
         -borderwidth 0 -relief flat -variable paramhorloge(onoff) -onvalue "on" -offvalue "off" 
        
        pack $base2.f.f2.trackopen -in $base2.f.f2 -padx [ expr int(11*$zoom) ] -side top
        
        #--- Create a dummy space
        frame $base2.f.vide2 -height 2 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base2.f.vide2 -in $base2.f -side top -fill x -pady 5
         	   
        label $base2.f.vide2.sendposition -width $geomlx200(15pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack $base2.f.vide2.sendposition -in $base2.f.vide2 -side top -fill x -pady 10
        
        button $base2.f.vide2.sendposition.but1 -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]\
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey)\
         -text "SEND" -command {::zadkopad::gotocoord "$paramhorloge(new,ra)" "$paramhorloge(new,dec)" "$paramhorloge(suivira)" "$paramhorloge(suividec)" "$paramhorloge(onoff)" "$paramhorloge(focal_number)"}
        pack $base2.f.vide2.sendposition.but1 -in $base2.f.vide2.sendposition -side top -ipadx 5 -ipady 5 -pady 10	  
        
        #--- Create a dummy space
        #frame $base2.f.vide2 -height 12 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        #pack $base2.f.vide2 -in $base2.f -side top -fill x -pady 10
        
        pack $base2.f -fill both
        .zadkopad.mode.manual configure -relief groove -state normal		
        .zadkopad.func.closedome configure -relief groove -state disabled
        .zadkopad.func.opendome configure -relief groove -state disabled
        .zadkopad.tel.init configure -relief groove -state disabled
        .zadkopad.tel.parking configure -relief groove -state disabled
        .zadkopad.petal.petalopen configure -relief groove -state disabled
        .zadkopad.petal.petalclose configure -relief groove -state disabled
        .zadkopad.foc.enter configure -relief groove -state disabled
        .zadkopad.frame1.frame2.f.but1 configure -relief groove -state disabled
        .zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state disabled
        update
        #--- La fenetre est active
        focus .zadkopad       
        #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
        bind .zadkopad <Key-F1> { ::console::GiveFocus }
        
        # =======================================
        # === It is the end of the script run ===
        # =======================================
        ::zadkopad::refreshcoord
        ::zadkopad::calculz
        #--- Je passe en mode manuel sur le telescope ZADKO
        ::zadkopad::modeZADKO 1
        set paramhorloge(init) 1
    }
   

# proc met_a_jour { } {
#    global paramhorloge
# 
#    set paramhorloge(ra) "$paramhorloge(new,ra)"
#    set paramhorloge(dec) "$paramhorloge(new,dec)"
# }

}

