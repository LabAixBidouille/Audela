#
# Fichier : zadkopad.tcl
# Description : Raquette virtuelle du LX200
# Auteur : Alain KLOTZ
# Mise a jour $Id: zadkopad.tcl,v 1.35 2009-10-01 09:17:21 myrtillelaas Exp $
#

namespace eval ::zadkopad {
   package provide zadkopad 1.0
   package require audela 1.4.0
   
   source [ file join [file dirname [info script]] zadkopad.cap ]
   
   #------------------------------------------------------------
   #  Archivage du fichier log
   #     dans zadkopad/zadkopad_date.log
   #------------------------------------------------------------
    proc archive_zadkopad { } {
       global ros

       set logdate [gren_nightdate now]
       set logcurrent "$ros(caption,logfile)/zadkopad.log"
       set logdestin  "$ros(caption,logfile)/zadkopad_$logdate.log"
       set logwww     "$ros(caption,logfilehttpd)/zadkopad_$logdate.log"
       set logcurrentwww     "$ros(caption,logfilehttpd)/zadkopad.log"
       set dirwww     "$ros(caption,logfilehttpd)"
       #zadko_info "logdate: $logdate, logcurrent: $logcurrent; logdestin: $logdestin"
       set error [ catch {
        set res1 [file exists $logdestin]
        set res2 [file exists $logcurrent]
        if {($res2==1)&&($res1==0)} {
                 zadko_info "Archivage du fichier $ros(common,nameofexecutable).log"
                 zadko_info "------------------------------------------------------"
                 file copy -force -- "$logcurrent"  "$logdestin"
                 catch {file delete "$logcurrent" }
          } elseif {($res2==1)&&($res1==1)} {
                zadko_info "Archivage du fichier $ros(common,nameofexecutable).log"
                zadko_info "------------------------------------------------------"
                set fopen [open $logcurrent r]
                set contenu [read $fopen]          
                close $fopen
                set fopen [open $logdestin a]
                puts $fopen $contenu
                close $fopen
                catch {file delete "$logcurrent" }
          }
       } msg ]
    
       if {$error==1} {
          zadko_info "Log Manager Error (log): $msg"
       }
    
        set error [ catch {
        set res1 [file exists $logwww]
        set res2 [file exists $logdestin]
        
        if {($res2==1)&&($res1==0)} {
                zadko_info "Archivage web du fichier zadkopad.log"
                zadko_info "------------------------------------------------------"
                file mkdir $dirwww
                file copy -force -- "$logcurrent"  "$dirwww"
                file copy -force -- "$logdestin"  "$dirwww"
          } elseif {($res2==1)&&($res1==1)} {
                zadko_info "Archivage web du fichier zadkopad.log"
                zadko_info "------------------------------------------------------"
                set fopen [open $logdestin r]
                set contenu2 [read $fopen]           
                close $fopen
                set fopen [open $logwww a]
                puts $fopen $contenu
                puts $fopen $contenu2
                close $fopen
          }
        } msg ]
    
       if {$error==1} {
          zadko_info "Log Manager Error (wwwroot): $msg"
       }   
    }
   #------------------------------------------------------------
   #  Creation du fichier log
   #     dans zadkopad/zadkopad.log
   #------------------------------------------------------------
    proc gren_nightdate { {date now} {deltamidi 0} } {
       global ros
       set longitude [lindex $ros(common,home) 1]
       set sens [lindex $ros(common,home) 2]
       set signe 1.
       if {$sens=="E"} {
          set signe -1.
       }
       set dday [expr 0.5+$signe*$longitude/360.+$deltamidi/24.]
       set logdate [mc_date2iso8601 [mc_datescomp [mc_date2jd $date] - $dday]]
       set logdate "[string range $logdate 0 3][string range $logdate 5 6][string range $logdate 8 9]"
       return $logdate
    }
   #------------------------------------------------------------
   #  Creation du fichier log
   #     dans zadkopad/zadkopad.log
   #------------------------------------------------------------
   proc zadko_info {msg } { 
        global ros
        
        set mesage ""
        ::console::disp "$msg \n"
        
        # --- gestion du fichier log
        set ros(caption,namelogfile) zadkopad.log
        set ros(caption,logfile)    "$ros(root,logs)/logs/zadkopad"
        set ros(caption,logfilehttpd)    "$ros(root,htdocs)/htdocs/ros/logs/zadkopad"
        # --- Retourne la date de l'instant actuel
        set date [mc_date2ymdhms now]
        set date "[format "%04d-%02d-%02d %02d:%02d:%06.3f" [lindex $date 0] [lindex $date 1] [lindex $date 2] [lindex $date 3] [lindex $date 4] [lindex $date 5]]"
        append mesage "$date "
        append mesage $msg  
        
        catch {
            file mkdir $ros(caption,logfile)
            set fid [open "$ros(caption,logfile)/$ros(caption,namelogfile)" "a"]
            puts $fid $mesage
            close $fid
        }
        catch {
            file mkdir $ros(caption,logfilehttpd)
            set fid [open "$ros(caption,logfilehttpd)/$ros(caption,namelogfile)" "a"]
            puts $fid $mesage
            close $fid
        }
        
        # --- historique des 50 dernieres lignes
        if {[info exists ros(common,log,lasts)]==0} {
            set ros(common,log,lasts) "$mesage"
        } else {
            if {[info exists ros(common,log,nlig_lasts)]==0} {
                set ros(common,log,nlig_lasts) 30
            }
            set n [llength $ros(common,log,lasts)]
            set kfin [expr $n-1]
            set kdeb [expr $kfin-$ros(common,log,nlig_lasts)]
            if {$kdeb<0} { set kdeb 0 }
            set ros(common,log,lasts) [lrange $ros(common,log,lasts) $kdeb $kfin]
            lappend ros(common,log,lasts) "$mesage\n"
            set lignes ""
            foreach ligne $ros(common,log,lasts) {
                append lignes "$ligne"
            }
            file mkdir $ros(caption,logfilehttpd)
            set fid [open "$ros(caption,logfilehttpd)/[file rootname [file tail $ros(caption,namelogfile)]]_last[file extension [file tail $ros(caption,namelogfile)]]" "w"]
            puts $fid $lignes
            close $fid
        }
   }
   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
		global port modetelescope stopcalcul paramhorloge telnum ros textloadfile
		
		# --- Initialisation des variables ros du telescope
		set ros(common,nameofexecutable) "telescope"
		set port(adressePCcontrol) 121.200.43.11
		set port(maj) 30032
		set port(tel) 30011
		set port(gard) 30001
		set modetelescope 0
		set stopcalcul 0
		set paramhorloge(init) 0
		set telnum 1
		
		# hostname and IP number sorted from routables to non routables
        set res [hostaddress]
        set res [lrange $res 0 [expr [llength $res]-2]]
        set non_routables {10.0 172.16 192.168 169.254}
        set ip0s ""
        set ip1s ""
        foreach re $res {
        	set ip [lindex $re 0].[lindex $re 1]
        	if {[lsearch $non_routables $ip]>=0} {
        		lappend ip1s $re
        	} else {
        		lappend ip0s $re
        	}
        }
        set ips ""
        foreach ip0 $ip0s {
        	lappend ips $ip0
        }
        foreach ip1 $ip1s {
        	lappend ips $ip1
        }
        # IP number is preferable that is routable
        set ip0 [lindex $ips 0]
        set ros(common,hostname) [lindex [hostaddress] end]
        set ros(common,ip) [lindex $ip0 0].[lindex $ip0 1].[lindex $ip0 2].[lindex $ip0 3]
        set ros(common,ip2) [lindex $ip0 0].[lindex $ip0 1].[lindex $ip0 2]
        set ros(common,ip3) [lindex $ip0 0].[lindex $ip0 1]
		### pour test ###
		#set ros(common,hostname) ikon
        #set ros(common,ip) 121.200.43.5 
		###
		set textloadfile ""
        set err [catch {source "[pwd]/../ros/root.tcl"}]
        if {$err==1} {
            append textloadfile "load problem of file root.tcl"
        }   
        set err [catch {source "$ros(root,ros)/src/common/macros.tcl"}]
        if {$err==1} {
            append textloadfile "load problem of file macros.tcl"
        }
        set err [catch {source "$ros(root,conf)/conf/src/common/variables_sites.tcl"}]
        if {($err!=1)&&($ros(common,mode)=="zadko_australia_pcwincam")} {
            set paramhorloge(dra) $ros(telescope,private,dra);               # offset (deg) for hour angle
            set paramhorloge(ddec) $ros(telescope,private,ddec);             # offset (deg) for declination
            set paramhorloge(focus) $ros(telescope,private,focuscam1) ;      # valeur du bon focus
            set paramhorloge(speedra) $ros(telescope,speedtrack,mult,ra) ;   # coef multiplicateur du speedtrack
            #set paramhorloge(speeddec) $ros(telescope,speedtrack,mult,dec); # coef multiplicateur du speedtrack
        } else {
            append textloadfile "no offset values defined in variables_sites.tcl"
            set paramhorloge(dra) 0;            # offset (deg) for hour angle
            set paramhorloge(ddec) 0;           # offset (deg) for declination
            set paramhorloge(focus) 0;          # valeur du bon focus
            set paramhorloge(speedra) 0;        # coef multiplicateur du speedtrack
            #set paramhorloge(speeddec) 0;      # coef multiplicateur du speedtrack  
       }
       
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
      global audace conf paramhorloge modetelescope port ros

      if { [ winfo exists .zadkopad ] } {
         #--- Enregistre la position de la raquette
         set geom [wm geometry .zadkopad]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(zadkopad,position) [string range $geom $deb $fin]
      }
	  set paramhorloge(sortie) "1"
	  set modetelescope 0
	  if {$ros(common,mode)=="zadko_australia_pcwincam"} {
    	  #--- rend la main a ros
    	  modeZADKO 0
	  }
	  set paramhorloge(init) 0
	  #--- archive le fichier log
	  archive_zadkopad
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
			if {$reponse==""} {
    			after 1000
			    set reponse [read $f]
			    if {($reponse=="")&&([lindex $texte 1]=="speedtrack")} {
    			    after 500
			        set reponse [read $f]
			    } elseif {($reponse=="")&&([lindex $texte 0]=="GOTO")} {
    			    for {set k 1} {$k<130} {incr k} {
    			        after [expr $k*1000]
		                set reponse [read $f]
		                if {$reponse!=""} {
    		                set k [expr $k + 2.5]
    		                break
		                }
		                zadko_info "move telescope : $k"
        			}
			    }
			}
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
	 		zadko_info "$texte reponse: $reponse"
			
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
				set reponse [::zadkopad::roscommande [list telescope DO eval tel$telnum radec motor off]]
				
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
				#::zadkopad::stopfocus
				#################################
				set reponse [::zadkopad::roscommande [list telescope DO eval tel$telnum radec motor off]]
				# --- passer majordome en mode auto
				#passer en mode manuel du majordome
		 		set reponse [::zadkopad::dialoguesocket $port(adressePCcontrol) $port(maj) $texte]
	 			
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
		
		zadko_info "$msg"
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
			zadko_info "$nameexe ordre: $ordre, reponse: $reponse"
			if {($reponse=="")&&([lindex $msg 2]=="speedtrack")} {
    			set reponse [::zadkopad::dialoguesocket $port(adressePCcontrol) $portCom $ordre]
			    zadko_info "$nameexe ordre2: $ordre, reponse: $reponse"
    			
			}
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
            		set temps 100000
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
		global port paramhorloge audace ros telnum color
		
		set paramhorloge(home)       $audace(posobs,observateur,gps)
		.zadkopad.foc.ent1 configure -fg $color(blue_pad)
		.zadkopad.frame1.frame2.f.lab_ha configure -fg $color(yellow)
        .zadkopad.frame1.frame2.f.lab_altaz configure -fg $color(yellow)
        .zadkopad.frame1.frame3.f.f3.ent1 configure -fg $color(blue_pad)
		.zadkopad.frame1.frame3.f.f3.ent2 configure -fg $color(blue_pad)
            
		zadko_info "goto $newra $newdec"
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
			
		#zadko_info "goto ra: $ra, dec: $dec, alt: $alt, ha: $ha"
		# --- teste si les coordonnees sont pointables
		if {(($ha<[expr 15*15])&&($ha>[expr 8*15]))||($alt<10)||($dec>45)||($dec<-89.5)} {			
			# --- affiche un message d'erreur
			zadko_info "tsl: $tsl"
			set ts [mc_angle2deg [list $tsl] ]
			set ramin [expr $ts/15 - 8.5]
			set ramax [expr $ts/15 - 16.5*15]
			set decmin 89.5
			set decmax 45
			zadko_info "goto erreur ramin: $ramin, ramax: $ramax, ts: $ts"
			# ne peut pas ouvrir connection
			tk_messageBox -icon error -message "BAD COORDINATES: must be $ramin<RA<$ramax AND ALT>10 degre AND $decmin<DEC<$decmax" -type ok
			.zadkopad.frame1.frame2.f.lab_ha configure -fg red
            .zadkopad.frame1.frame2.f.lab_altaz configure -fg red
			return
		} 
		# --- teste si les vitesses de suivi sont bonnes
		if {($suivira<0)||($suividec<[expr -2*360./86164])||($suivira>[expr 2*360./86164])||($suividec>[expr 2*360./86164])} {				
			tk_messageBox -icon error -message "BAD TRACK VALUES: must be 0<TRACK_RA<0.00835 AND -0.00835<TRACK_DEC<0.00835" -type ok
			.zadkopad.frame1.frame3.f.f3.ent1 configure -fg red
			.zadkopad.frame1.frame3.f.f3.ent2 configure -fg red
			return
		} 
		
		# --- teste si le focus est bon
		if {($newfocus<2800)||($newfocus>3600)} {				
			tk_messageBox -icon error -message "BAD FOCUS VALUES: must be 2800<FOCUS<3600" -type ok
			.zadkopad.foc.ent1 configure -fg red
			return
		} 
		
		# --- envoie l'ordre de suivi	
		
		#################################
		# pour contrer le bug de DFM
		#if 	{$onoff=="off"} {
		#	stopfocus
		#}
		###################################
		# --- envoie les valeurs de suivi
		# --- envoie l'ordre de pointage au telescope
		set reponse [::zadkopad::roscommande [list telescope GOTO $newra $newdec -blocking 1]]
		#zadko_info "$reponse"
		if 	{$onoff=="off"} {
			set reponse [::zadkopad::roscommande [list telescope DO speedtrack 0.0 0.0]]
		} else {   		
		    set reponse [::zadkopad::roscommande [list telescope DO speedtrack $suivira $suividec]]
	    }
		#zadko_info "$reponse"		
		#set reponse [::zadkopad::roscommande [list telescope DO eval tel$telnum racdec motor $onoff]]
		#zadko_info "$reponse"	
		
		return 
	}
	
	#------------------------------------------------------------
    #    send focus     
    #------------------------------------------------------------
	proc sendfocus {newfocus} {
		global port paramhorloge audace ros telnum color

		.zadkopad.foc.ent1 configure -fg $color(blue_pad)
		# --- teste si le focus est bon
		if {($newfocus<2800)||($newfocus>3600)} {				
			tk_messageBox -icon error -message "BAD FOCUS VALUES: must be 2800<FOCUS<3600" -type ok
			.zadkopad.foc.ent1 configure -fg red
			return
		} 
		# --- envoie l'ordre de focus
		set nowfocus [lindex [::zadkopad::roscommande [list telescope DO eval tel$telnum dfmfocus]] 0] 
		zadko_info "recupere le focus : $nowfocus"	
		if {$nowfocus==""} {
    		    set nowfocus [lindex [::zadkopad::roscommande [list telescope DO eval tel$telnum dfmfocus]] 0] 
    		    if {$nowfocus==""} {
				    set nowfocus $paramhorloge(focus)
			    }
		}
		# --- envoie l'ordre de focus
		set reponse [::zadkopad::roscommande [list telescope DO eval [list tel$telnum dfmfocus $newfocus]]]
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
		#zadko_info "nowfocus: $nowfocus, newfocus: $newfocus, temps: $temps"
		#after [expr int($temps)]
		# ::zadkopad::stopfocus
		
		return $reponse
	}
	#------------------------------------------------------------
   #    send focus     
   #------------------------------------------------------------
	proc stopfocus {} {
		global port paramhorloge audace telnum
		
		set texte [list DO eval tel$telnum put "#13;\r"]
		
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
		zadko_info "$reponse"	
		return $reponse
	}
	#------------------------------------------------------------
	#    met a jour les donnes     
	#------------------------------------------------------------
	proc calculz { } {
	   global caption stopcalcul base paramhorloge ros color
	   
	    #zadko_info "paramhorloge(new,ra):$paramhorloge(new,ra) ,paramhorloge(new,dec): $paramhorloge(new,dec)"
		if { $paramhorloge(sortie) != "1" } {
 			if {($paramhorloge(new,ra)=="")&&($paramhorloge(new,dec)=="")} {
				zadko_info "proc calculz : problem with telescope connection, paramhorloge(new,ra):$paramhorloge(new,ra)"
				set radec [ ::zadkopad::roscommande {telescope TEL radec coord}]
				#ATTENTION rajout OFFSET de pointage DFM
 				set paramhorloge(ra)         "[lindex $radec 0]"
                set paramhorloge(dec)        "[lindex $radec 1]"
                if {($paramhorloge(ra)!="")&&($paramhorloge(dec)!="")} {                   
                    set paramhorloge(ra)        [mc_angle2deg $paramhorloge(ra)]
                    set paramhorloge(dec)       [mc_angle2deg $paramhorloge(dec) 90]
                    set paramhorloge(ra)        [expr $paramhorloge(ra)-$paramhorloge(dra)]
                    set paramhorloge(dec)       [expr $paramhorloge(dec)-$paramhorloge(ddec)]
                    set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(ra) 360 zero 2 auto string]]
                    set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(dec)  90 zero 1 + string]]  
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
			
			# --- test the coordinates
			set dec [mc_angle2deg $paramhorloge(dec) 90]
			if {(($ha<[expr 15*15])&&($ha>[expr 8*15]))||($alt<10)||($dec>45)||($dec<-89.5)} {			
    			.zadkopad.frame1.frame2.f.lab_ha configure -fg red
                .zadkopad.frame1.frame2.f.lab_altaz configure -fg red
               
		    } else {
    		    .zadkopad.frame1.frame2.f.lab_ha configure -fg $color(yellow)
                .zadkopad.frame1.frame2.f.lab_altaz configure -fg $color(yellow)
		    }
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
	   global caption base paramhorloge stopcalcul ros telnum color
	    
	    set stopcalcul 1
	    zadko_info "proc refresh : paramhorloge(new,ra):$paramhorloge(new,ra) ,paramhorloge(new,dec): $paramhorloge(new,dec)"

 		set radec [ ::zadkopad::roscommande {telescope TEL radec coord}]
		#ATTENTION rajout OFFSET de pointage DFM
		#ATTENTION rajout OFFSET de pointage DFM
	    set paramhorloge(ra)         "[lindex $radec 0]"
        set paramhorloge(dec)        "[lindex $radec 1]"
        if {($paramhorloge(ra)!="")&&($paramhorloge(dec)!="")} {
            set paramhorloge(ra)        [mc_angle2deg $paramhorloge(ra)]
            set paramhorloge(dec)       [mc_angle2deg $paramhorloge(dec) 90]
            set paramhorloge(ra)        [expr $paramhorloge(ra)-$paramhorloge(dra)]
            set paramhorloge(dec)       [expr $paramhorloge(dec)-$paramhorloge(ddec)]
            set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(ra) 360 zero 2 auto string]]
            set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(dec)  90 zero 1 + string]]  
     }     
		set paramhorloge(new,ra) 	 $paramhorloge(ra)
		set paramhorloge(new,dec) 	 $paramhorloge(dec)
 				
 		set paramhorloge(focal_number)	[lindex [::zadkopad::roscommande [list telescope DO eval tel$telnum dfmfocus]] 0]
 		set vitessessuivie [::zadkopad::roscommande [list telescope DO speedtrack]]
 		if {$vitessessuivie!=""} {
     		set paramhorloge(suivira)	[expr [lindex $vitessessuivie 0]/$paramhorloge(speedra)]
     		#set paramhorloge(suivira)	[lindex $vitessessuivie 0]
     		set paramhorloge(suividec)	[lindex $vitessessuivie 1] 
 		}
 		set stopcalcul 0
 		zadko_info "proc refresh end : radec: $radec, focal_number: $paramhorloge(focal_number), vitessessuivie : $vitessessuivie"
 		.zadkopad.foc.ent1 configure -fg $color(blue_pad)
		.zadkopad.frame1.frame2.f.lab_ha configure -fg $color(yellow)
        .zadkopad.frame1.frame2.f.lab_altaz configure -fg $color(yellow)
        .zadkopad.frame1.frame3.f.f3.ent1 configure -fg $color(blue_pad)
		.zadkopad.frame1.frame3.f.f3.ent2 configure -fg $color(blue_pad)
 		::zadkopad::calculz
 	
	}
	#------------------------------------------------------------
	#    coordinates calculation     
	#------------------------------------------------------------
	proc findcoordinate {name } {
    	global paramhorloge audace
    	
    	set paramhorloge(soapra) ""
    	set paramhorloge(soapdec) ""
    	set paramhorloge(soappos) ""
     
        .zadkopad.frame4.frame1.f2.ent3 configure -state disabled 
        
        zadko_info "findcoordinate $name"
        
	    package require SOAP
            
        set name "$name"
        set resultType "xp"
        set server "http://cdsws.u-strasbg.fr/axis/services/Sesame"
        SOAP::create sesame -uri $server -proxy $server -action "urn:sesame" -params { "name" "string"  "resultType" "string" }
        set xml_text [sesame $name $resultType] 
        #::console::disp "xml_text: $xml_text \n"  
        if {([string first jradeg $xml_text]>0)&&([string first jdedeg $xml_text]>0)} {        
              set radebut [expr [string first jradeg $xml_text] + 7]
              set rafin [expr [string first "</" $xml_text $radebut]-1]
              set paramhorloge(soapra) [string range $xml_text $radebut $rafin]
              
              set decdebut [expr [string first jdedeg $xml_text] + 7]
              set decfin [expr [string first "</" $xml_text $decdebut]-1]
              set paramhorloge(soapdec) [string range $xml_text $decdebut $decfin]
              
              set posdebut [expr [string first jpos $xml_text] + 5]
              set posfin [expr [string first "</" $xml_text $posdebut]-1]
              set paramhorloge(soappos) [string range $xml_text $posdebut $posfin]
              ::console::disp "$name $paramhorloge(soappos)\n"
              
              .zadkopad.frame4.frame1.f2.ent3 configure -state normal
              .zadkopad.frame4.frame1.f2.but1 configure -state normal  
        } else {
        # message de pb sur les coordonnées
              zadko_info "Problem with $name"
              tk_messageBox -icon error -message "The name: $name is not correct" -type ok
        }
 	}
 	#------------------------------------------------------------
	#    coordinates calculation     
	#------------------------------------------------------------
	proc applycoordinate { } {
    	global paramhorloge audace
    	
    	if {($paramhorloge(soapra)!="")&&($paramhorloge(soapdec)!="")} {
        	set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(soapra) 360 zero 2 auto string]]
            set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(soapdec)  90 zero 1 + string]]  
        	set paramhorloge(new,ra) 	 "$paramhorloge(ra)"
    	    set paramhorloge(new,dec) 	 "$paramhorloge(dec)"
    	}
    	   
	}
 	
    #------------------------------------------------------------
    #  run
    #     cree la fenetre de la raquette
    #------------------------------------------------------------
    proc run { {zoom .5} {positionxy 200+10} } {
        variable widget
        global audace caption color geomlx200 statustel zonelx200 paramhorloge base port ros telnum textloadfile 
        
        if { [ string length [ info commands .zadkopad.display* ] ] != "0" } {
         destroy .zadkopad
        }
        if { $zoom <= "0" } {
         destroy .zadkopad
         return
        }
        zadko_info "###########################################"
        zadko_info "         ZADKO MANUAL INTERFACE            "
        zadko_info "###########################################"
        zadko_info "My hostname is: $ros(common,hostname) "
        zadko_info "My IP is: $ros(common,ip) "
        zadko_info "ROS mode is: $ros(common,mode) "
        zadko_info ""
        if {$textloadfile!=""} {
            zadko_info "$textloadfile"
            zadko_info ""
            set textloadfile ""
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
        set geomlx200(long)       [ expr int(950*$zoom) ]
        set geomlx200(fontsize25) [ expr int(25*$zoom) ]
        set geomlx200(fontsize20) [ expr int(20*$zoom) ]
        set geomlx200(fontsize16) [ expr int(16*$zoom) ]
        set geomlx200(fontsize14) [ expr int(14*$zoom) ] 
        set geomlx200(5pixels)   [ expr int(5*$zoom) ]     
        set geomlx200(7pixels)   [ expr int(7*$zoom) ]     
        set geomlx200(10pixels)   [ expr int(10*$zoom) ]
        set geomlx200(15pixels)   [ expr int(15*$zoom) ]
        set geomlx200(16pixels)   [ expr int(16*$zoom) ]
        set geomlx200(20pixels)   [ expr int(20*$zoom) ]
        set geomlx200(26pixels)   [ expr int(26*$zoom) ]
        set geomlx200(28pixels)   [ expr int(28*$zoom) ]
        set geomlx200(30pixels)   [ expr int(30*$zoom) ]
        set geomlx200(40pixels)   [ expr int(40*$zoom) ]
        set geomlx200(430pixels)  [ expr int(430*$zoom)]
        set geomlx200(haut)       [ expr int(70*$zoom) ]
        set geomlx200(linewidth0) [ expr int(3*$zoom) ]
        set geomlx200(linewidth)  [ expr int($geomlx200(linewidth0)+1) ]        
        if { $geomlx200(linewidth0) <= "1" } { set geomlx200(textthick) "" } else { set geomlx200(textthick) "bold" }
      
        #--- Initialisation
        set paramhorloge(sortie)     "0"
        if {$ros(common,mode)=="zadko_australia_pcwincam"} {
            set radec [ roscommande {telescope TEL radec coord}]
            #ATTENTION rajout OFFSET de pointage DFM
            set paramhorloge(ra)         "[lindex $radec 0]"
            set paramhorloge(dec)        "[lindex $radec 1]"
            if {($paramhorloge(ra)!="")&&($paramhorloge(dec)!="")} {
	            #zadko_info  "paramhorloge(dra): ; ros(telescope,private,dra): $ros(telescope,private,dra)"
                set paramhorloge(ra)        [mc_angle2deg $paramhorloge(ra)]
                set paramhorloge(dec)       [mc_angle2deg $paramhorloge(dec) 90]
                set paramhorloge(ra)        [expr $paramhorloge(ra)-$paramhorloge(dra)]
                set paramhorloge(dec)       [expr $paramhorloge(dec)-$paramhorloge(ddec)]
                set paramhorloge(ra)        [string trim [mc_angle2hms $paramhorloge(ra) 360 zero 2 auto string]]
                set paramhorloge(dec)       [string trim [mc_angle2dms $paramhorloge(dec)  90 zero 1 + string]]  
            }              
            set paramhorloge(focal_number)	"[lindex [::zadkopad::roscommande [list telescope DO eval tel$telnum dfmfocus]] 0]" 
        } else {
            set paramhorloge(ra)         ""
            set paramhorloge(dec)        ""
            set paramhorloge(focal_number)  ""
        }
        set paramhorloge(new,ra) 	 "$paramhorloge(ra)"
    	set paramhorloge(new,dec) 	 "$paramhorloge(dec)"
    	set paramhorloge(home)       $audace(posobs,observateur,gps)
        set paramhorloge(color,back) #123456
        set paramhorloge(color,text) #FFFFAA
        set paramhorloge(font)       {times 30 bold}
        set paramhorloge(suivira)	 "0.00417808"
        set paramhorloge(suividec)   "0.0"
        set objectname "M51"
        zadko_info  "proc run: init focal_number: $paramhorloge(focal_number), paramhorloge(new,ra):$paramhorloge(new,ra), paramhorloge(new,dec): $paramhorloge(new,dec)"

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
        frame .zadkopad.dum1 -height $geomlx200(10pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
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
        label .zadkopad.tel.telescope -width $geomlx200(28pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Observatory" \
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
        label .zadkopad.func.dome -width $geomlx200(28pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Dome Control" \
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
        label .zadkopad.petal.telescope -width $geomlx200(28pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Mirror Door Control" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack .zadkopad.petal.telescope -in .zadkopad.petal -side left
         
        button .zadkopad.petal.petalopen -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text OPEN \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::roscommande {telescope DO mirrordoors 1}}
        
        button .zadkopad.petal.petalclose -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text CLOSE \
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey) -command {::zadkopad::roscommande {telescope DO mirrordoors 0}}
        
        pack  .zadkopad.petal.petalopen .zadkopad.petal.petalclose  -in .zadkopad.petal -padx [ expr int(11*$zoom) ] -side left
        
        #--- Create a dummy space
        frame .zadkopad.vide -height $geomlx200(5pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.vide -in .zadkopad -side top -fill x -pady 10
          
        #--- Create a frame for the focalisation value
        frame .zadkopad.foc -height $geomlx200(haut) -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack .zadkopad.foc -in .zadkopad -side top -fill x -pady 10
         
        label .zadkopad.foc.telescope -width $geomlx200(28pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Focalisation" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack .zadkopad.foc.telescope -in .zadkopad.foc -side left
         
        entry .zadkopad.foc.ent1 -textvariable paramhorloge(focal_number) -width $geomlx200(10pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
             -bg $colorlx200(backtour)  -fg $colorlx200(backpad) -relief flat
             
        button .zadkopad.foc.enter -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] -text "SEND FOCUS" \
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
        
        #--- Create a dummy space
        frame $base.f.vide -height 2 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base.f.vide -in $base.f -side top -fill x -pady 4
        
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
          entry $base2.f.ra.ent1 -textvariable paramhorloge(new,ra) -width 15  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
             -bg $colorlx200(backtour)  -fg $colorlx200(backpad) -relief flat
          pack $base2.f.ra.lab1 -side left -fill none
          pack $base2.f.ra.ent1 -side left -fill none
        pack $base2.f.ra -fill none -pady 2
        frame $base2.f.dec -bg $colorlx200(backpad)
          label $base2.f.dec.lab1 -text "Declination (+/- ° ' ''):" -bg $colorlx200(backpad)  -fg $colorlx200(textkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]
          entry $base2.f.dec.ent1 -textvariable paramhorloge(new,dec) -width 15  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
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
         label $base2.f.f3.sideral \
         -width $geomlx200(40pixels) -font [ list {Arial} $geomlx200(10pixels) $geomlx200(textthick) ] -text "Sideral tracking RA 0.00417808 & DEC 0.0" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack $base2.f.f3.sideral -in $base2.f.f3 -side top
        
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
        pack $base2.f.vide2 -in $base2.f -side top -fill x -pady 4
         	   
        label $base2.f.vide2.sendposition -width $geomlx200(15pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        pack $base2.f.vide2.sendposition -in $base2.f.vide2 -side top -fill x -pady 8
        
        button $base2.f.vide2.sendposition.but1 -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]\
         -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey)\
         -text "MOVE TELESCOPE" -command {::zadkopad::gotocoord "$paramhorloge(new,ra)" "$paramhorloge(new,dec)" "$paramhorloge(suivira)" "$paramhorloge(suividec)" "$paramhorloge(onoff)" "$paramhorloge(focal_number)"}
        pack $base2.f.vide2.sendposition.but1 -in $base2.f.vide2.sendposition -side top -ipadx 5 -ipady 5 -pady 10	  
        
        #--- Create a dummy space
        #frame $base2.f.vide2 -height 12 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        #pack $base2.f.vide2 -in $base2.f -side top -fill x -pady 10
        
        pack $base2.f -fill both
        
        #--- Create a frame for Find Coordinates
  
        frame .zadkopad.frame4 -borderwidth 0 -relief flat -width $geomlx200(430pixels) -bg $colorlx200(backpad)
        pack .zadkopad.frame4 -in .zadkopad -side top -fill x -pady 10
        
         frame .zadkopad.frame4.frame1 -borderwidth 5 -relief flat -width $geomlx200(430pixels) -bg $colorlx200(backkey)   
        pack .zadkopad.frame4.frame1 -in .zadkopad.frame4 -side right -fill x -expand true -pady 10 -padx 10
        
        label .zadkopad.frame4.frame1.texte -font [ list {Arial} $geomlx200(fontsize20) $geomlx200(textthick) ] -text "Find Coordinates" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(backtour)
        pack .zadkopad.frame4.frame1.texte -in .zadkopad.frame4.frame1 -side top -fill x -expand true
         	
        set base3 ".zadkopad.frame4.frame1"
        
        frame $base3.f -bg $colorlx200(backpad)
        #--- Create a dummy space
        frame $base3.f.vid -height 2 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base3.f.vid -in $base3.f -side top -fill x -pady 5
        #---
        label $base3.f.name \
           -width $geomlx200(26pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "Object Name e.g.: M51" \
           -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        entry $base3.f.ent3 -textvariable paramhorloge(objectname) -width $geomlx200(20pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
                 -bg $colorlx200(backtour) -fg $colorlx200(backpad) -relief flat
        button $base3.f.but1 -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]\
             -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey)\
             -text "FIND COORDINATES" -command {::zadkopad::findcoordinate "$paramhorloge(objectname)"}   
        frame $base3.f.vid2 -height 2 -width $geomlx200(20pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad)    
        pack $base3.f.name $base3.f.ent3 -in $base3.f -side left
        pack $base3.f.vid2 $base3.f.but1 -in $base3.f -side right
        pack $base3.f -fill both
        
        frame $base3.f2 -bg $colorlx200(backpad) -height 20
        #--- Create a dummy space
        frame $base3.f2.vid3 -height 2 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base3.f2.vid3 -in $base3.f2 -side top -fill x -pady 5
        frame $base3.f2.vid5 -height 2 -width 100 -borderwidth 0 -relief flat -bg $colorlx200(backpad)   

        label $base3.f2.pos \
         -width $geomlx200(26pixels) -font [ list {Arial} $geomlx200(fontsize16) $geomlx200(textthick) ] -text "POSITION RA DEC" \
         -borderwidth 0 -relief flat -bg $colorlx200(backpad) -fg $colorlx200(textkey)
        
        entry $base3.f2.ent3 -textvariable paramhorloge(soappos) -width $geomlx200(20pixels)  -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ] \
                 -bg $colorlx200(backtour) -fg $colorlx200(backpad) -relief flat
        button $base3.f2.but1 -width $geomlx200(20pixels) -relief flat -bg $colorlx200(backkey) -font [ list {Arial} $geomlx200(fontsize14) $geomlx200(textthick) ]\
             -borderwidth 0 -relief flat -bg $colorlx200(backkey) -fg $colorlx200(textkey)\
             -text "APPLY COORDINATES" -command {::zadkopad::applycoordinate}   
        frame $base3.f2.vid2 -height 2 -width $geomlx200(20pixels) -borderwidth 0 -relief flat -bg $colorlx200(backpad)  
        pack  $base3.f2.pos $base3.f2.ent3  -side left -fill none
        pack  $base3.f2.vid2 $base3.f2.but1 -in $base3.f2 -side right
        #--- Create a dummy space
        pack $base3.f2 -fill both
        
        frame $base3.vid4 -height 10 -borderwidth 0 -relief flat -bg $colorlx200(backpad)
        pack $base3.vid4 -in $base3 -side top -fill both
        
        .zadkopad.func.closedome configure -relief groove -state disabled
        .zadkopad.func.opendome configure -relief groove -state disabled
        .zadkopad.tel.init configure -relief groove -state disabled
        .zadkopad.tel.parking configure -relief groove -state disabled
        .zadkopad.petal.petalopen configure -relief groove -state disabled
        .zadkopad.petal.petalclose configure -relief groove -state disabled
        .zadkopad.foc.enter configure -relief groove -state disabled
        .zadkopad.frame1.frame2.f.but1 configure -relief groove -state disabled
        .zadkopad.frame1.frame3.f.vide2.sendposition.but1 configure -relief groove -state disabled
        .zadkopad.frame4.frame1.f2.ent3 configure -state disabled
        .zadkopad.frame4.frame1.f2.but1 configure -relief groove -state disabled
        update
        #--- La fenetre est active
        focus .zadkopad       
        #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
        bind .zadkopad <Key-F1> { ::console::GiveFocus }
        
        if {$ros(common,mode)=="zadko_australia_pcwincam"} {
            #::zadkopad::refreshcoord
            ::zadkopad::calculz
            #--- Je passe en mode manuel sur le telescope ZADKO
            ::zadkopad::modeZADKO 1
            set paramhorloge(init) 1
            #.zadkopad.mode.manual configure -relief groove -state normal		
        } 
        # =======================================
        # === It is the end of the script run ===
        # =======================================        
    }
   

# proc met_a_jour { } {
#    global paramhorloge
# 
#    set paramhorloge(ra) "$paramhorloge(new,ra)"
#    set paramhorloge(dec) "$paramhorloge(new,dec)"
# }

}

