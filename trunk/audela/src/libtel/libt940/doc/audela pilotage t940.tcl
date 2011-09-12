    
# Fichier : pilotage t940.tcl
# Description : CALCULS DES VITESSES INSTANTANEES DES 3 AXES suivi pointage télescope
# Auteur : Alain KLOTZ Pierre THIERRY
# Mise a jour $Id: horloge_astro.tcl,v 1.2 2006/06/21 18:50:49 robertdelmas Exp $
# modifications de mai 2010: utilisation de sensa avec 71 et 72 axe azimutal pour test; limitation demi-tour
# google_earth_home_goto {gps 1.7187 E 43.8740 220}
# modifié le 20 5 2011 autoguidage
# source "audela pilotage t940.tcl"
# modif du 8 juin 2011 supprimé le double check sur les combit raquette (passage en commentaires)

#---
global audace
global caption
global base
global posinibase
global paramaltaz
global etelsimu

#--- Chargement des captions
source [ file join $audace(rep_scripts) horloge_astro horloge_astro.cap ]
set caption(vsa)	"Vitesse siderale azimut"
set caption(vsh)	"Vitesse siderale hauteur"
set caption(vsc)	"Vitesse siderale champ"
set caption(via) 	"Vitesse instantanée azimut"
set caption(vih)	"Vitesse instantanée hauteur"
set caption(vic)	"Vitesse instantanée champ"
set caption(raquette) "raquette vitesse rapide "

#--- Initialisation
set paramaltaz(sortie)     "0"
set paramaltaz(home)       $audace(posobs,observateur,gps)
set paramaltaz(color,back) #123456
set paramaltaz(color,text) #FFFFAA
set paramaltaz(font)       {times 11 bold}
set paramaltaz(font1)       {times 15 bold}
set paramaltaz(rac) 0
set paramaltaz(vrac) 0

if {([info exists paramaltaz(ra)]==1)&&([info exists paramaltaz(dec)]==1)} {
   set paramaltaz(new,ra)     "$paramaltaz(ra)"
   set paramaltaz(new,dec)    "$paramaltaz(dec)"
   set paramaltaz(point,ra)     "$paramaltaz(ra)"
   set paramaltaz(point,dec)    "$paramaltaz(dec)"
} else {
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set tsl [mc_date2lst $now $paramaltaz(home)]
   set paramaltaz(new,ra)     "mettre le telescope sur le meriden"
   set paramaltaz(new,dec)    "et a moins 40 et faire retour park"
   set paramaltaz(point,ra)     "$tsl"
   set paramaltaz(point,dec)    "b b b "
}
set paramaltaz(vsa)     "7000"
set paramaltaz(vsh)    "2900"
set paramaltaz(vsc)     "725"
set paramaltaz(test)     "12"
set paramaltaz(park)  "0"
set paramaltaz(rtpark)  "0"
set paramaltaz(lim) "0"
set paramaltaz(tour)  "0"
set paramaltaz(dra)  "0"
set paramaltaz(posn0) "0"
set paramaltaz(raq)  "0"
set paramaltaz(raqhard)  "0"
set paramaltaz(boucle)  "0" 
set paramaltaz(max)  "0"
set paramaltaz(abs) "0"

#*********init_monture
set paramaltaz(vsam) 	"655050"
set paramaltaz(vsap) 	"655273"
set paramaltaz(xsam)   	"3674614"
set paramaltaz(xsap)   	"3675864"
set paramaltaz(vshm) 	"1298651"
set paramaltaz(vshp) 	"1297414"
set paramaltaz(xshm) 	"7285000"
set paramaltaz(xshp) 	"7275000"
set paramaltaz(vsc) 		"924492"
set paramaltaz(xsc) 		"1728694"
#**********init_monture



#--- literature ETEL pour l'axe 2 (pour les non spécialistes)
# vitesse de pointage X17 se lit et s'ecrit comm suit
# tel1 get_register_s 2 X 17    lecture de la valeur
# tel1 set_register_s 2 X 17 0   5000000   ecriture de le valeur
# tel1 execute_command_x_s  2 26 1 0 0 79  initilise le moteur
# tel1 execute_command_x_s  2 26 1 0 0 69  lance le suivi dans le sens en cours
# tel1 execute_command_x_s  2 26 1 0 0 71	 lance le suivi dans le sens horaire
# tel1 execute_command_x_s  2 26 1 0 0 72  lance le suivi dans le sens antihoraire
# tel1 execute_command_x_s  2 26 1 0 0 73  lance le pointage (le sens est défini par les coordonées d'arrivée et de départ)
# tel1 execute_command_x_s  2 48 2 0 0 2 0 0 6000 sauve les parametres X ou K modifies pendant le script 6000 sert a eviter une "timeout error"
# cette commande est a utiliser en dehors de la boucle calcul : paramaltaz(sortie) "1"
# tel1 execute_command_x_s  2 124 1 0 0 0 arrete le moteur en coupant la tension du moteur PWR OFF
# tel1 execute_command_x_s  2 119 0 arrete la sequence en cours et le moteur 
# seule la commande tel1 execute_command_x_s  2 26 1 0 0 79 fait repartir le moteur
# en fait toutes ces commandes appellent des pointeurs des programmes des contrôleurs des moteurs 
# dérotateur de champ X21 croissant = sens horaire X21 décroissant = sens antihoraire  pas par degrés=1728694.04 (xsc) vitesse sidérale vsc=923.863
# axe azimut X21 croissant = sens horaire X21 décroissant = sens antihoraire  pas par degrés(moyenne)=3681869.1 (xsa) vitesse sidérale vsa=643.4095
# clocher grazac =>	meridien	-54,5°	-200662072 incréments
# clocher grazac =>	equateur	45,87°	337774671 incréments
# puis remonter de 15°			
		

#--- Initialisation moteurs
::console::affiche_resultat "[mc_date2iso8601 now] : init monture en cours...\n"

#---creation monture et choix du mode simulation ou reel
set err [catch {::tel::create etel pci} msg]
if {$err==0} {
   ::console::affiche_resultat "[mc_date2iso8601 now] : Mode réel\n"
   set etelsimu(simulation) 0
	#--- Initialisation combit
	::console::affiche_resultat "[mc_date2iso8601 now] : autorisation combit\n"
	porttalk open all
} else {
   ::console::affiche_resultat "[mc_date2iso8601 now] : Mode simulation\n"
   set etelsimu(simulation) 1
   proc tel1 {args} {
      global etelsimu
      set command [lindex $args 0]
      #::console::affiche_resultat "* $args\n"
      if {$command=="execute_command_x_s"} {
      } elseif {$command=="get_register_s"} {
         set response 1
         set registre [string toupper [lindex $args 2]][lindex $args 3].[lindex $args 1]
         if {[info exists etelsimu(register,$registre)]==1} {
            set response $etelsimu(register,$registre)
         } elseif {$registre=="X22.0"} {
            set response 645
         } elseif {$registre=="X22.1"} { 
            set response 1300
         } elseif {$registre=="X22.2"} { 
            set response 2000
         } elseif {$registre=="X23.0"} { 
            set response 3661000
         } elseif {$registre=="X23.1"} { 
            set response 7285000
         } elseif {$registre=="X23.2"} { 
            set response 14015781
         }
         #::console::affiche_resultat "** $args => $response\n"
         return $response
      } elseif {$command=="set_register_s"} {
         set registre [string toupper [lindex $args 2]][lindex $args 3].[lindex $args 1]
         set etelsimu(register,$registre) [lindex $args 5]
      }
   }
}

#---recuperation des parametres monture
#--- axe azimut=0 
#--- axe hauteur=1 
#--- axe champ=2 

set paramaltaz(vsa)    [tel1 get_register_s 0 X 22]
set paramaltaz(vsh)    [tel1 get_register_s 1 X 22]
set paramaltaz(vsc)    [tel1 get_register_s 2 X 22]
set paramaltaz(xsa)    [tel1 get_register_s 0 X 23]
set paramaltaz(xsh)    [tel1 get_register_s 1 X 23]
set paramaltaz(xsc)    [tel1 get_register_s 2 X 23]

set paramaltaz(vsam)    [tel1 get_register_s 0 X 26]
set paramaltaz(vshm)    [tel1 get_register_s 1 X 26]
set paramaltaz(vscm)    [tel1 get_register_s 2 X 26]

set paramaltaz(vsap)    [tel1 get_register_s 0 X 27]
set paramaltaz(vshp)    [tel1 get_register_s 1 X 27]
set paramaltaz(vscp)    [tel1 get_register_s 2 X 27]

set paramaltaz(xsam)    [tel1 get_register_s 0 X 28]
set paramaltaz(xshm)    [tel1 get_register_s 1 X 28]
set paramaltaz(xscm)    [tel1 get_register_s 2 X 28]

set paramaltaz(xsap)    [tel1 get_register_s 0 X 29]
set paramaltaz(xshp)    [tel1 get_register_s 1 X 29]
set paramaltaz(xscp)    [tel1 get_register_s 2 X 29]

set paramaltaz(new,vsa)    [expr $paramaltaz(vsam)/1.0]
set paramaltaz(new,vsh)    [expr $paramaltaz(vshm)/1.0]
set paramaltaz(new,vsc)    [expr $paramaltaz(vsc)/1.0]

#---  vitesse d'initialisation moteurs
#set vitessea  [tel1 get_register_s 0 X 13]
#::console::affiche_resultat "vitesse azimut=$vitessea\n"
#tel1 set_register_s 0 X 13 0 50000
#set vitesseh  [tel1 get_register_s 1 X 13]
#::console::affiche_resultat "vitesse hauteur=$vitesseh\n"
#tel1 set_register_s 1 X 13 0 50000
#set vitessec  [tel1 get_register_s 2 X 13]
#::console::affiche_resultat "vitesse champ=$vitessec\n"
#tel1 set_register_s 2 X 13 0 50000

######modif mai
set paramaltaz(sensa)  "2"
set paramaltaz(sensh)  "2"
set paramaltaz(sensc)  "2"
#---arret de tous les moteurs
tel1 execute_command_x_s  ! 69  1 0 0 0

#--- Create the toplevel window
set base .horloge_astro
catch { destroy $base}
toplevel $base -class Toplevel
wm geometry $base 640x480+0+0
wm focusmodel $base passive
wm maxsize $base 600 700
wm minsize $base 600 700
#wm overrideredirect $base 0
wm resizable $base 1 1
wm deiconify $base
wm title $base "pilotage telescope azimutal"
#wm protocol $base WM_DELETE_WINDOW fermer
wm protocol $base WM_DELETE_WINDOW { global paramaltaz ; set paramaltaz(action) exit }
bind $base <Destroy> { destroy .horloge_astro }
$base configure -bg $paramaltaz(color,back)
wm withdraw .
focus -force $base

#################################################################################
#### proc etel_grande_boucle
#################################################################################
proc etel_grande_boucle { } {
	global base
	global paramaltaz
   global etelsimu
   global caption
   ::console::affiche_resultat "[mc_date2iso8601 now] : Entree dans la grande boucle\n"
	catch {exec espeak.exe -v fr "démarre boodu congue"}
   while {1==1} {
      # --- mise a jour des widgets
      set now now
      catch {set now [::audace::date_sys2ut now]}
      set tu [mc_date2ymdhms $now ]
      set h [format "%02d" [lindex $tu 3]]
      set m [format "%02d" [lindex $tu 4]]
      set s [format "%02d" [expr int(floor([lindex $tu 5]))]]
      catch {$base.f.lab_tu configure -text "$caption(horloge_astro,tu) ${h}h ${m}mn ${s}s"}
      set tsl [mc_date2lst $now $paramaltaz(home)]
      set h [format "%02d" [lindex $tsl 0]]
      set m [format "%02d" [lindex $tsl 1]]
      set s [format "%02d" [expr int(floor([lindex $tsl 2]))]]
      catch {$base.f.lab_tsl configure -text "$caption(horloge_astro,tsl) ${h}h ${m}mn ${s}s"}
      if {[info exists paramaltaz(ra)]==0} {
         set paramaltaz(ra) $tsl
      }
      if {[info exists paramaltaz(dec)]==0} {
         set paramaltaz(dec) "0 0 0"
      }
      set paramaltaz(ra1) "[ lindex $paramaltaz(ra) 0 ]h[ lindex $paramaltaz(ra) 1 ]m[ lindex $paramaltaz(ra) 2 ]"
      set paramaltaz(dec1) "[ lindex $paramaltaz(dec) 0 ]d[ lindex $paramaltaz(dec) 1 ]m[ lindex $paramaltaz(dec) 2 ]"
      set res [mc_radec2altaz2 "$paramaltaz(ra1)" "$paramaltaz(dec1)" "$paramaltaz(home)" $now]
      set az  [format "%5.2f" [lindex $res 0]]
      set alt [format "%5.2f" [lindex $res 1] ]
      set ha  [lindex $res 2]
      set res [mc_angle2hms $ha]
      set h [format "%02d" [lindex $res 0]]
      set m [format "%02d" [lindex $res 1]]
      set s [format "%02d" [expr int(floor([lindex $res 2]))]]
      catch {
	      $base.f.lab_ha configure -text "$caption(horloge_astro,angle_horaire) ${h}h ${m}mn ${s}s"
	      $base.f.lab_altaz configure -text "$caption(horloge_astro,azimut) ${az}° - $caption(horloge_astro,hauteur) ${alt}°"
      }
      # --- decode l'action a effectuer
      if {[info exists paramaltaz(action)]==0} {
         set paramaltaz(action) "motor_off"
      }
      if {[info exists paramaltaz(action_prev)]==0} {
         set paramaltaz(action_prev) ""
      } else {
         if {$paramaltaz(action_prev)=="exit"} {
            set paramaltaz(action) "motor_off"
         }
      }
      set action $paramaltaz(action)
      set action_prev $paramaltaz(action_prev)
      if {$action!=$action_prev} {
      	::console::affiche_resultat "[mc_date2iso8601 now] : etel_grande_boucle : action = $action (precedente = $action_prev)\n"
   	}
      set paramaltaz(action_prev) $paramaltaz(action)
      if {$action=="motor_off"} {
         ####------------------------------
         #### motor off
         ####------------------------------
         if {$action_prev!="motor_off"} {   
            etel_suivi_arret
         }
         set paramaltaz(last_motor) off
      } elseif {$action=="motor_on"} {
         ####------------------------------
         #### motor on
         ####------------------------------
         etel_suivi_diurne
         set paramaltaz(last_motor) on
      } elseif {$action=="goto"} {
         ####------------------------------
         #### goto bloquant
         ####------------------------------
         etel_goto
         set paramaltaz(action) "motor_on"
      } elseif {$action=="move_n"} {
         ####------------------------------
         #### move_n
         ####------------------------------      
         ::shiftn
      } elseif {$action=="move_s"} {
         ####------------------------------
         #### move_s
         ####------------------------------      
         ::shifts
      } elseif {$action=="move_e"} {
         ####------------------------------
         #### move_e
         ####------------------------------      
         ::shifte
      } elseif {$action=="move_o"} {
         ####------------------------------
         #### move_o
         ####------------------------------      
         ::shifto
      } elseif {$action=="exit"} {
         ####------------------------------
         #### exit
         ####------------------------------      
         ::fermer
         break
      } else {
      	::console::affiche_resultat "[mc_date2iso8601 now] : Action $action non reconnue\n"
      }
      #
   	# mesure de la variable d'état des bits de rappel( utilisation raquette soft)
   	set rappel 0
   	set n "[combit 1 1]"
   	if {$n == 1 }  {
	   	#set n 0
         #after 500
         #set n "[combit 1 1]"
      	#if {$n == 1 }  {
      		set paramaltaz(action) "move_n"
         	set rappel 1
      	#}
   	}
   	set e "[combit 1 8]"
   	after 100
   	set o "[combit 1 6]"
   	set s [expr $o+$e]
   	if {$s == 2 }  {
	   	#set s 0
         ##after 500
         #set e "[combit 1 8]"
      	#after 100
      	#set o "[combit 1 6]"
      	#set s [expr $o+$e]
      	#if {$s == 2 }  {
      		set paramaltaz(action) "move_s"
         	set rappel 1
      	#}
   	}
   	if { $s != "2" } {
   		if {$e == 1 }  {
	   		#set e 0
	   		##after 500
	   		#set e "[combit 1 8]"
	   		#if {$e == 1 }  {
         		set paramaltaz(action) "move_e"
            	set rappel 1
         	#}
   		}
   		if {$o == 1 }  {
	   		#set o 0
	   		##after 500
	   		#set o "[combit 1 6]"
	      		#if {$o == 1 }  {
         		set paramaltaz(action) "move_o"
            	set rappel 1
         	#}
   		}
   	}
   	if {(($paramaltaz(action_prev)=="move_s")||($paramaltaz(action_prev)=="move_n")||($paramaltaz(action_prev)=="move_e")||($paramaltaz(action_prev)=="move_o"))&&($rappel==0)} {
      	# --- on vient de relacher les rappels
      	if {$paramaltaz(last_motor)=="on"} {
         	set paramaltaz(action) "motor_on"
      	} else {
         	set paramaltaz(action) "motor_off"
      	}
   	}
      # --- mise a jour des widgets
      catch {
      	$base.f.vih configure -text "$caption(vih) $paramaltaz(app_vih) ([format %.2f $paramaltaz(app_drift_elev)] arcsec/sec)"
      	$base.f.via configure -text "$caption(via) $paramaltaz(app_via) ([format %.2f $paramaltaz(app_drift_az)] arcsec/sec)"
      	$base.f.vic configure -text "$caption(vic) $paramaltaz(app_vic) ([format %.2f $paramaltaz(app_drift_rot)] arcsec/sec)"
   	}
      update
      #
      after 250
   }
}

#################################################################################
#### proc etel_suivi_arret
#################################################################################
proc etel_suivi_arret { } {
	global base
	global paramaltaz
   global etelsimu
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set app_drift_az   0; # : Vitesse en azimut apparente avec  modèle (arcsec/sec)
   set app_drift_elev 0; # : Vitesse en elevation apparente avec modèle (arcsec/sec)
   set app_drift_rot  0; # : Vitesse en angle parallactique apparent avec modèle (arcsec/sec)
   set coef 15.03
   if {$app_drift_az>0} {
	   set vsa $paramaltaz(vsap)
   } else {
	   set vsa $paramaltaz(vsam)
   }
   set app_via [expr round(-$app_drift_az/$coef*$vsa/1000.)]
   if {$app_drift_elev>0} {
	   set vsh $paramaltaz(vshp)
   } else {
	   set vsh $paramaltaz(vshm)
   }   
   set app_vih [expr round(-$app_drift_elev/$coef*$vsh/1000.)]
   if {$app_drift_rot>0} {
	   set vsc $paramaltaz(vscp)
   } else {
	   set vsc $paramaltaz(vscm)
   }
   set app_vic [expr round(-$app_drift_rot/$coef*$vsc/1000.)]
   #::console::affiche_resultat "AK : $app_drift_az $app_drift_elev $app_drift_HA\n"
   set vic $app_vic
   set vih $app_vih
   set via $app_via
   set vic 0
   set vih 0
   set via 0
   #
   set paramaltaz(app_drift_az) $app_drift_az
   set paramaltaz(app_drift_elev) $app_drift_elev
   set paramaltaz(app_drift_rot) $app_drift_rot
   set paramaltaz(app_vic) $vic
   set paramaltaz(app_vih) $vih
   set paramaltaz(app_via) $via   
   #
   #---arret de tous les moteurs
   #tel1 execute_command_x_s  ! 69  1 0 0 0   
   #
   tel1 set_register_s 0 X 13 0 [expr abs($via)]
   if {$via<0} {
      tel1 execute_command_x_s 0 26 1 0 0 71
   } else {
      tel1 execute_command_x_s 0 26 1 0 0 72
   }
   # 
   tel1 set_register_s 1 X 13 0 [expr abs($vih)]
   if {$vih<0} {
      tel1 execute_command_x_s 1 26 1 0 0 72
   } else {
      tel1 execute_command_x_s 1 26 1 0 0 71
   }
   # 
   tel1 set_register_s 2 X 13 0 [expr abs($vic)]
   if {$vic<0} {
      tel1 execute_command_x_s 2 26 1 0 0 71
   } else {
      tel1 execute_command_x_s 2 26 1 0 0 72
   }
   # --- retient la date,a,h, de l'arret
   set delai 1 ; # pour tenir compte du temps d'arret des moteurs (a calibrer)
   after $delai
   set now now
   catch {set now [::audace::date_sys2ut now]}
   set res [mc_radec2altaz2 "$paramaltaz(ra1)" "$paramaltaz(dec1)" "$paramaltaz(home)" $now]
   set app_HA         [lindex $res 2] ; #: Angle horaire apparente avec modèle (deg)
   set app_az         [lindex $res 0] ; #: Azimut apparente avec  modèle (deg)
   set app_elev       [lindex $res 1] ; #: Elevation apparente avec modèle (deg)   
   set paramaltaz(last_stop,date) $now
   set paramaltaz(last_stop,a) $app_az
   set paramaltaz(last_stop,h) $app_elev
}

#################################################################################
#### proc etel_goto
#################################################################################
proc etel_goto { } {
	global base
	global paramaltaz
   global etelsimu
   ::pointer
}

#################################################################################
#### proc etel_suivi_diurne
#################################################################################
proc etel_suivi_diurne { } {
	global base
	global paramaltaz
   global etelsimu
   set now now
   catch {set now [::audace::date_sys2ut now]}
   # Calcul des vitesses
   set res [mc_radec2altaz2 "$paramaltaz(ra1)" "$paramaltaz(dec1)" "$paramaltaz(home)" $now]
   set app_HA         [lindex $res 2] ; #: Angle horaire apparente avec modèle (deg)
   set app_az         [lindex $res 0] ; #: Azimut apparente avec  modèle (deg)
   set app_elev       [lindex $res 1] ; #: Elevation apparente avec modèle (deg)
   set app_rot        [lindex $res 3] ; #: Angle parallactique apparent avec modèle (deg) 
   set app_drift_HA   [lindex $res 6] ; # : Vitesse en angle horaire apparente avec modèle (arcsec/sec)
   set app_drift_az   [lindex $res 4] ; # : Vitesse en azimut apparente avec  modèle (arcsec/sec)
   set app_drift_elev [lindex $res 5] ; # : Vitesse en elevation apparente avec modèle (arcsec/sec)
   set app_drift_rot  [lindex $res 7] ; # : Vitesse en angle parallactique apparent avec modèle (arcsec/sec)
   set coef 15.041; #$app_drift_HA
   #pierre
   set paramaltaz(rotchamp)  $app_rot
   #pierre
   if {$app_drift_az>0} {
	   set vsa $paramaltaz(vsap)
   } else {
	   set vsa $paramaltaz(vsam)
   }
   set app_via [expr round(-$app_drift_az/$coef*$vsa/1000.)]
   if {$app_drift_elev>0} {
	   set vsh $paramaltaz(vshp)
   } else {
	   set vsh $paramaltaz(vshm)
   }   
   set app_vih [expr round(-$app_drift_elev/$coef*$vsh/1000.)]
   if {$app_drift_rot>0} {
	   set vsc $paramaltaz(vscp)
   } else {
	   set vsc $paramaltaz(vscm)
   }
   set app_vic [expr round(-$app_drift_rot/$coef*$vsc/1000.)]
   #::console::affiche_resultat "AK : $app_drift_az $app_drift_elev $app_drift_HA\n"
   set vic $app_vic
   set vih $app_vih
   set via $app_via
   #
   set paramaltaz(app_drift_az) $app_drift_az
   set paramaltaz(app_drift_elev) $app_drift_elev
   set paramaltaz(app_drift_rot) $app_drift_rot
   set paramaltaz(app_vic) $vic
   set paramaltaz(app_vih) $vih
   set paramaltaz(app_via) $via   
   #
   tel1 set_register_s 0 X 13 0 [expr abs($via)]
   if {$via<0} {
       tel1 execute_command_x_s 0 26 1 0 0 71
   } else {
       tel1 execute_command_x_s 0 26 1 0 0 72
   }
   set paramaltaz(va) $via
   # 
   tel1 set_register_s 1 X 13 0 [expr abs($vih)]
   if {$vih<0} {
       tel1 execute_command_x_s 1 26 1 0 0 72
   } else {
       tel1 execute_command_x_s 1 26 1 0 0 71
   }
   set paramaltaz(vh) $vih
   if { $paramaltaz(rac)  == 1} {
		set vic 0
	}
   tel1 set_register_s 2 X 13 0 [expr abs($vic)]
   if {$vic<0} {
       tel1 execute_command_x_s 2 26 1 0 0 71
   } else {
       tel1 execute_command_x_s 2 26 1 0 0 72
   }
   set paramaltaz(vc) $vic
}

#################################################################################
#### proc fermer
#################################################################################
proc fermer { } {
	global base
	global paramaltaz
	set paramaltaz(sortie) "1"
	tel1 set_register_s 0 X 22 0 $paramaltaz(vsa)
	tel1 set_register_s 0 X 23 0 $paramaltaz(xsa)
	tel1 set_register_s 0 X 26 0 $paramaltaz(vsam)
	tel1 set_register_s 0 X 27 0 $paramaltaz(vsap)
	tel1 set_register_s 0 X 28 0 $paramaltaz(xsam)
	tel1 set_register_s 0 X 29 0 $paramaltaz(xsap)
	
	tel1 set_register_s 1 X 22 0 $paramaltaz(vsh)
	tel1 set_register_s 1 X 23 0 $paramaltaz(xsh)
	tel1 set_register_s 1 X 26 0 $paramaltaz(vshm)
	tel1 set_register_s 1 X 27 0 $paramaltaz(vshp)
	tel1 set_register_s 1 X 28 0 $paramaltaz(xshm)
	tel1 set_register_s 1 X 29 0 $paramaltaz(xshp)
	
	tel1 set_register_s 2 X 22 0 $paramaltaz(vsc)
	tel1 set_register_s 2 X 23 0 $paramaltaz(xsc)
	tel1 set_register_s 2 X 26 0 $paramaltaz(vscm)
	tel1 set_register_s 2 X 27 0 $paramaltaz(vscp)
	tel1 set_register_s 2 X 28 0 $paramaltaz(xscm)
	tel1 set_register_s 2 X 29 0 $paramaltaz(xscp)
	
	tel1 execute_command_x_s 0 119 0
	tel1 execute_command_x_s 0 48 2 0 0 2 0 0 6000
	after 1000
	tel1 execute_command_x_s 0 79 0
	::console::affiche_resultat " sauvegarde contrôleur azimut ok\n"
	tel1 execute_command_x_s 1 119 0
	tel1 execute_command_x_s 1 48 2 0 0 2 0 0 6000
	after 1000
	tel1 execute_command_x_s 1 79 0
	::console::affiche_resultat " sauvegarde contrôleur hauteur ok\n"
	tel1 execute_command_x_s 2 119 0
	tel1 execute_command_x_s 2 48 2 0 0 2 0 0 6000
	tel1 execute_command_x_s 2 79 0
	::console::affiche_resultat " sauvegarde contrôleur champ ok\n"
	destroy $base
}

#################################################################################
#### proc mc_radec2altaz2
#################################################################################
proc mc_radec2altaz2 { raj2000 decj2000 home date } {
   global paramaltaz
   # modele de pointage
	set modpoi_symbols {IA IE}
	set modpoi_values  {0 0}
   #***************Alain Calcul des vitesses
   # {id mag ra dec equinox epoch mura mudec plx}
   #::console::affiche_resultat "raj2000=$raj2000 => <[string trim [mc_angle2deg "$raj2000"]]>\n"
   set n [llength $raj2000]
   if {$n==3} {
	   set raj2000 [list [lindex $raj2000 0] [lindex $raj2000 1] [lindex $raj2000 2] h]
   }
   set hip [list 1 1 [string trim [mc_angle2deg "$raj2000"]] [string trim [mc_angle2deg "$decj2000" 90]] J2000 J2000 0 0 0]
   #::console::affiche_resultat "hip=$hip\n"
   set res [mc_hip2tel $hip $date "$paramaltaz(home)" 101325 290 $modpoi_symbols $modpoi_values -drift 1]
	set app_RA         [lindex $res 10] ; #: Acsension droite apparente avec modèle (deg)
	set app_DEC        [lindex $res 11] ; #: Déclinaison apparente avec modèle (deg)
	set app_HA         [lindex $res 12] ; #: Angle horaire apparente avec modèle (deg)
	set app_az         [lindex $res 13] ; #: Azimut apparente avec  modèle (deg)
	set app_elev       [lindex $res 14] ; #: Elevation apparente avec modèle (deg)
	set app_rot        [lindex $res 15] ; #: Angle parallactique apparent avec modèle (deg) 
	set app_drift_RA   [lindex $res 16] ; #: Vitesse en acsension droite apparente avec modèle (arcsec/sec)
	set app_drift_DEC  [lindex $res 17] ; # : Vitesse en déclinaison apparente avec modèle (arcsec/sec)
	set app_drift_HA   [lindex $res 18] ; # : Vitesse en angle horaire apparente avec modèle (arcsec/sec)
	set app_drift_az   [lindex $res 19] ; # : Vitesse en azimut apparente avec  modèle (arcsec/sec)
	set app_drift_elev [lindex $res 20] ; # : Vitesse en elevation apparente avec modèle (arcsec/sec)
	set app_drift_rot  [lindex $res 21] ; # : Vitesse en angle parallactique apparent avec modèle (arcsec/sec)
	# ---
	set out [list $app_az $app_elev $app_HA $app_rot $app_drift_az $app_drift_elev $app_drift_HA $app_drift_rot]
	return $out
}

#################################################################################
#### proc met_a_jour
#################################################################################
proc met_a_jour { } {
	global audace
	global caption
	global base
   global paramaltaz
   if {$paramaltaz(park)== 1 } {
   	set paramaltaz(ra)  "$paramaltaz(new,ra)"
   	set paramaltaz(dec) "$paramaltaz(new,dec)"
   	set paramaltaz(vshm) "$paramaltaz(new,vsh)"
   	set paramaltaz(vsam) "$paramaltaz(new,vsa)"
   	set paramaltaz(vsc) "$paramaltaz(new,vsc)"
   	set paramaltaz(vshp) "$paramaltaz(new,vsh)"
   	set paramaltaz(vsap) "$paramaltaz(new,vsa)"
   	::console::affiche_resultat "[mc_date2iso8601 now] : met a jour \n"
   	#::calcul
   }
}

#################################################################################
#### proc pointer
#################################################################################
proc pointer { } {
	global base
	global paramaltaz
   global etelsimu
   global caption
	set paramaltaz(sortie) "1"
	
	#----on calcule les différences d'azimut et hauteur
	set now now
	catch {set now [::audace::date_sys2ut now]}
	set err [catch {decode_radec_entry $paramaltaz(ra) $paramaltaz(dec)} res]
	if {$err==1} {
		tk_messageBox -message "Probleme : $res" -icon error -type ok
		return ""
	}
	set paramaltaz(ra1) [lindex $res 0]
	set paramaltaz(dec1) [lindex $res 1]	
	set date1 $now
	set date2 $now
	for {set kgoto 1} {$kgoto<=2} {incr kgoto} {
		::console::affiche_resultat "[mc_date2iso8601 now] : *** kgoto=$kgoto [mc_date2iso8601 $date1] - [mc_date2iso8601 $date2]\n"
		# ==== Calcul du decalage sur les deux axes
		set res [mc_radec2altaz2 "$paramaltaz(ra1)" "$paramaltaz(dec1)" "$paramaltaz(home)" $date1]
		set az1  [format "%5.2f" [lindex $res 0]]
		set alt1 [format "%5.2f" [lindex $res 1]]
		::console::affiche_resultat "[mc_date2iso8601 now] : Coordonnees initiales az1=$az1 alt1=$alt1\n"
		set err [catch {decode_radec_entry $paramaltaz(point,ra) $paramaltaz(point,dec)} res]
		if {$err==1} {
			tk_messageBox -message "Probleme : $res" -icon error -type ok
			set paramaltaz(point,ra) $paramaltaz(ra) 
			set paramaltaz(point,dec) $paramaltaz(dec)
			#::pointer
			return ""
		}
		set paramaltaz(ra2) [lindex $res 0]
		set paramaltaz(dec2) [lindex $res 1]	
		set paramaltaz(point,ra) [lindex $res 0]
		set paramaltaz(point,dec) [lindex $res 1]	
		#::console::affiche_resultat "mc_radec2altaz2 \"$paramaltaz(ra2)\" \"$paramaltaz(dec2)\" \"$paramaltaz(home)\" \"$now\"\n"
		set res [mc_radec2altaz2 "$paramaltaz(ra2)" "$paramaltaz(dec2)" "$paramaltaz(home)" $date2]
		set az2  [format "%5.2f" [lindex $res 0]]
		set alt2 [format "%5.2f" [lindex $res 1]]
		::console::affiche_resultat "[mc_date2iso8601 now] : Coordonnees a ralier az2=$az2 alt2=$alt2\n"
		set daz [expr $az2-$az1]
		if {$daz >180 } {
			set daz [expr $daz-360 ]
			#::console::affiche_resultat " daz1=$daz \n"
		}
		if {$daz <-180 } {
			set daz [expr $daz+360 ]
			#::console::affiche_resultat " daz2=$daz \n"
		}
		
		# limitation de pointage +2° et +88° en hauteur
		if {$alt2 < 2 } {
			set paramaltaz(lim) "1"
		}
		if {$alt2 > 88 } {
			set paramaltaz(lim) "1"
		}
		#::console::affiche_resultat " limest=$limesth $limestm limouest= $limouest limnord=93 limsud= -29 \n"
		
		set dalt [expr $alt1-$alt2]
		::console::affiche_resultat "[mc_date2iso8601 now] : paramaltaz(lim)=$paramaltaz(lim) daz=$daz dalt=$dalt\n"
		set paramaltaz(test)  "12" 
		if {$paramaltaz(lim) != "1" } {
			# ==== On arrete les moteurs + index au milieu de course
			set radec_jd0 [mc_date2jd now]
			::console::affiche_resultat "[mc_date2iso8601 now] : tel1 execute_command_x_s 0&1 26 1 0 0 77\n"
			tel1 execute_command_x_s 0 26 1 0 0 77 ; # arret moteur + index au milieu
			tel1 execute_command_x_s 1 26 1 0 0 77 ; # arret moteur + index au milieu
			after 500
			::console::affiche_resultat "[mc_date2iso8601 now] : tel1 get_register_s 0&1 M 7\n"
			set posa [tel1 get_register_s 0 M 7]
			set posd [tel1 get_register_s 1 M 7]
			::console::affiche_resultat "posa=$posa  posd=$posd  \n"
			set radec_jd1 [mc_date2jd now]
			# ==== On calcule de decalage en az
			if {$daz>0} {
				set xsa $paramaltaz(xsap)
			} else {
				set xsa $paramaltaz(xsam)
			}
			set dposa [expr $daz]
			set dposa [expr $dposa*$xsa]
			set dposa [expr int ($dposa)]
			::console::affiche_resultat "[mc_date2iso8601 now] : dposa=$dposa  \n"
			set posa  [expr $dposa+$posa ]
			::console::affiche_resultat "[mc_date2iso8601 now] : posa=$posa  \n"
			# ==== On calcule de decalage en hauteur
			if {$dalt>0} {
				set xsh $paramaltaz(xshp)
			} else {
				set xsh $paramaltaz(xshm)
			}
 			set dposd [expr $dalt]
			set dposd [expr $dposd*$xsh]
			set dposd [expr int ($dposd)]
			::console::affiche_resultat "[mc_date2iso8601 now] : dposd=$dposd  \n"
			set posd  [expr $dposd+$posd ]
			::console::affiche_resultat "[mc_date2iso8601 now] : posd=$posd  \n"
			# ==== On lance les goto non bloquants
			::console::affiche_resultat "[mc_date2iso8601 now] : goto non bloquant\n"
			tel1 set_register_s 0 X 21 0 $posa
			tel1 set_register_s 1 X 21 0 $posd
			tel1 execute_command_x_s 0 26 1 0 0 73
			tel1 execute_command_x_s 1 26 1 0 0 73
			after 500
	      if {$etelsimu(simulation)==0} {
	   		::console::affiche_resultat "[mc_date2iso8601 now] : attente pointage\n"
	   		set posaold $posa
	   		set posdold $posd
	   		set t0 [clock seconds]
	   		set sortie_ra  0
	   		set sortie_dec 0
	   		while (1==1) {
	   			set posanew [tel1 get_register_s 0 M 7]
	   			set posdnew [tel1 get_register_s 1 M 7]
	   			set dposa [expr $posanew-$posaold]
	   			set dposd [expr $posdnew-$posdold]
	   			::console::affiche_resultat "[mc_date2iso8601 now] : dposa=$dposa dposd=$dposd\n"
	   			set dposa [expr abs($dposa)]
	   			set dposd [expr abs($dposd)]
	   			if {$dposa<2000.} {
		   			set ra_jd2 [mc_date2jd now]
			   		set sortie_ra 1
	   			}
	   			if {$dposd<2000.} {
		   			set dec_jd2 [mc_date2jd now]
			   		set sortie_dec 1
	   			}
	   			after 250
		   		set dt [expr [clock seconds]-$t0]
		   		if {$dt>120} {
			   		break
		   		}
		   		if {($sortie_ra==1)&&($sortie_dec==1)} {
			   		break
		   		}
   			}
   		}
			::console::affiche_resultat "[mc_date2iso8601 now] : tel1 execute_command_x_s 0&1 26 1 0 0 79\n"
			tel1 execute_command_x_s 0 26 1 0 0 79
			tel1 execute_command_x_s 1 26 1 0 0 79
			set paramaltaz(new,ra)     "$paramaltaz(point,ra)"
			set paramaltaz(new,dec)    "$paramaltaz(point,dec)"
			set paramaltaz(sortie)     "0"		
			set radec_jd3 [mc_date2jd now]
			set radec_jd3_ut [::audace::date_sys2ut now]
			set ra_djd  [expr ($ra_jd2-$radec_jd1)*86400.]
			set dec_djd [expr ($dec_jd2-$radec_jd1)*86400.]
			::console::affiche_resultat "[mc_date2iso8601 now] : pointage termine ra_djd=$ra_djd dec_djd=$dec_djd\n"		
			set paramaltaz(ra1) $paramaltaz(ra2)
			set paramaltaz(dec1) $paramaltaz(dec2)
			set date1 $date2
			set dsec [expr 1.] ; # estimation du pointage au second tour
			set date2 [mc_datescomp $radec_jd3_ut + [expr $dsec/86400.]]
			#::console::affiche_resultat "[mc_date2iso8601 now] : *** kgoto=$kgoto [mc_date2iso8601 $date1] - [mc_date2iso8601 $date2]\n"
		}
		::met_a_jour
   	if {$paramaltaz(abs) == 1 } {
   		set kgoto 3
   	}
	}
	
	if {$paramaltaz(lim) == "1" } {
		::console::affiche_resultat "[mc_date2iso8601 now] : pointage hors limites \n"
	} 
	set paramaltaz(lim) "0"

}


#################################################################################
#### proc raquette
#################################################################################
proc raquette { } {
	global paramaltaz
	set paramaltaz(sortie)     "1"
	tel1 execute_command_x_s 0 26 1 0 0 79 
	tel1 execute_command_x_s 1 26 1 0 0 79
	tel1 execute_command_x_s 2 26 1 0 0 79  
}


#################################################################################
#### proc park
#################################################################################
proc park { } {
	global audace
	global caption
	global base
	global paramaltaz
	
	if {$paramaltaz(park)== 1 } {
		
   	set paramaltaz(sortie)  "1" 
   	set now now
   	catch {set now [::audace::date_sys2ut now]}
   	set tu [mc_date2ymdhms $now ]
   	set h [format "%2d" [lindex $tu 3]]
   	set m [format "%2d" [lindex $tu 4]]
   	set s [format "%2d" [expr int(floor([lindex $tu 5]))]]
   	$base.f.lab_tu configure -text "$caption(horloge_astro,tu) ${h}h ${m}mn ${s}s"
   	set tsl [mc_date2lst $now $paramaltaz(home)]
   	set h [format "%2d" [lindex $tsl 0]]
   	set m [format "%2d" [lindex $tsl 1]]
   	set s [format "%5.2f" [expr int(floor([lindex $tsl 2]))]]
   	set h [expr $h]
   	if {$h<0} {
   		set h  [expr $h+24] 
   	}
   	set paramaltaz(point,ra) "$h $m $s"
   	set paramaltaz(point,dec)        "-40 00 00"
   	::console::affiche_resultat "$paramaltaz(point,ra) \n"  
   	set paramaltaz(abs) 0
      ::pointer 
   	::fermer 
   }

}


#################################################################################
#### proc retourpark
#################################################################################
proc  retourpark { } {
	global audace
	global caption
	global base
	global paramaltaz
   ::console::affiche_resultat "Retour PARK 1\n"  
	catch {wm forget .posini }
	update
   ::console::affiche_resultat "Retour PARK 2\n"  
	set paramaltaz(park)  "1"
	set paramaltaz(sortie)  "0" 
	set now now
	catch {set now [::audace::date_sys2ut now]}
	set tu [mc_date2ymdhms $now ]
	set h [format "%2d" [lindex $tu 3]]
	set m [format "%2d" [lindex $tu 4]]
	set s [format "%2d" [expr int(floor([lindex $tu 5]))]]
	$base.f.lab_tu configure -text "$caption(horloge_astro,tu) ${h}h ${m}mn ${s}s"
	set tsl [mc_date2lst $now $paramaltaz(home)]
	set h [format "%2d" [lindex $tsl 0]]
	set m [format "%2d" [lindex $tsl 1]]
	set s [format "%5.2f" [expr int(floor([lindex $tsl 2]))]]
	set h [expr $h]
	if {$h<0} {
		set h  [expr $h+24] 
	}
	set paramaltaz(new,ra)   "$h $m $s"
	set paramaltaz(new,dec)  "-40 00 00"
	set paramaltaz(point,ra) "$h $m $s"
	set paramaltaz(ra)       "$h $m $s"
	set paramaltaz(dec)        "-40 00 00"
	set paramaltaz(point,dec) "-40 00 00"
	::console::affiche_resultat "$paramaltaz(point,ra) \n" 
	global paramaltaz ; met_a_jour ; set paramaltaz(action) motor_on
	#::met_a_jour

  	::etel_grande_boucle
   ::etel_suivi_diurne
	#::pointer 
}

#################################################################################
#### proc tourisme
#################################################################################
proc  tourisme { } {
	# effectue le pointage séquentiel d'une liste d'objet contenue dans le fichier tourisme
	global caption
	global base
	global paramaltaz
   global etelsimu
   if {$paramaltaz(park)== 1 } {
   	#set paramaltaz(sortie)  "0" 
   	set paramaltaz(tour)  "1"
   	global audace
   	#::console::affiche_resultat "passage 1"
   	cd $audace(rep_images)
   	#--- Definition des couleurs
   	set color(back)       #56789A
   	set color(text)       #FFFFFF
   	set color(back_image) #123456
   	set color(red)        #FF0000
   	set color(green)      #00FF00
   	set color(blue)       #0000FF
   	set color(rectangle)  #0000EF
   	set color(scroll)     #BBBBBB
   	
   	set caption(acqcolor,fonc_titre3)	"Pointge d'une série d'objets a partir d'un fichier liste"
   	set caption(acqcolor,fonc_comment5)	"avant de lancer ce script vérifier quele fichier est dans le répetoire images"
   	set caption(acqcolor,fonc_decallage_images)	"fichier à lire"
   	set caption(acqcolor,fonc_focale_guide)	"AD mini"
   	set caption(acqcolor,fonc_focale_imagerie)	"AD maxi"
   	set caption(acqcolor,fonc_distance_equat)	"DEC mini"
   	set caption(acqcolor,fonc_rappels_delta)	"DEC maxi"
   	set caption(acqcolor,fonc_tolerance)	"fichiers existants"
   	set caption(acqcolor,fonc_executer)	"Exécuter"
   	set caption(acqcolor,fonc_libre)		"accelaration raquette"
   	
   	
   	#--- Initialisation des variables
   	set paramaltaz(imagename) 	"toursud2000.txtetoilessud.txt"
   	set paramaltaz(minalpha) 	"19 30"
   	set paramaltaz(maxalpha)   	"21 30"
   	set paramaltaz(mindelta)   	"-20 0"
   	set paramaltaz(maxdelta) 	"35 0"
   	set paramaltaz(imagename5) 	"toursud2000.txt etoilesnord.txt etoilessud.txt"
   	set paramaltaz(libre)		"2000"
   	set infos(portHandle)         ""
   	set infos(encours)          	""
   	set paramaltaz(stoptr) 	"0"

   	
   	#::console::affiche_resultat "passage 2"
   	#=========================================================
   	# fenetre tourisme
   	#   
   	#=========================================================
   
   	#--- Cree la fenetre .test5 de niveau le plus haut
   	if [ winfo exists .test5 ] {
   	   wm withdraw .test5
   	   wm deiconify .test5
   	   focus .test5
   	   return
   	}
   	toplevel .test5 -class Toplevel -bg $color(back)
   	wm geometry .test5 480x260+240+190
   	wm title .test5 $caption(acqcolor,fonc_titre3)
   	
   	#--- La nouvelle fenetre est active
   	focus .test5
   	
   	#--- Cree un frame en haut a gauche pour les canvas d'affichage
   	frame .test5.frame0 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame0 \
   	   -in .test5 -anchor nw -side top -expand 0 -fill x
   	
   	   #--- Cree le label 'titre'
   	   label .test5.frame0.lab \
   	      -text "$caption(acqcolor,fonc_comment5)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame0.lab \
   	      -in .test5.frame0 -side top -anchor center \
   	      -padx 3 -pady 3
   	
   	#--- Cree un frame
   	frame .test5.frame1 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame1 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame1.lab \
   	      -text "$caption(acqcolor,fonc_decallage_images)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame1.lab \
   	      -in .test5.frame1 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame1.ent \
   	      -textvariable paramaltaz(imagename) -width 10
   	   pack .test5.frame1.ent \
   	      -in .test5.frame1 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	
   	#--- Cree un frame
   	frame .test5.frame2 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame2 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame2.lab \
   	      -text "$caption(acqcolor,fonc_focale_guide)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame2.lab \
   	      -in .test5.frame2 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame2.ent \
   	      -textvariable paramaltaz(minalpha)  -width 10
   	   pack .test5.frame2.ent \
   	      -in .test5.frame2 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	
   	#--- Cree un frame
   	frame .test5.frame3 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame3 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame3.lab \
   	      -text "$caption(acqcolor,fonc_focale_imagerie)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame3.lab \
   	      -in .test5.frame3 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame3.ent \
   	      -textvariable paramaltaz(maxalpha) -width 10
   	   pack .test5.frame3.ent \
   	      -in .test5.frame3 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	
   	#--- Cree un frame
   	frame .test5.frame4 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame4 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame4.lab \
   	      -text "$caption(acqcolor,fonc_distance_equat)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame4.lab \
   	      -in .test5.frame4 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame4.ent \
   	      -textvariable paramaltaz(mindelta) -width 10
   	   pack .test5.frame4.ent \
   	      -in .test5.frame4 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	
   	#--- Cree un frame
   	frame .test5.frame5 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame5 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame5.lab \
   	      -text "$caption(acqcolor,fonc_rappels_delta)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame5.lab \
   	      -in .test5.frame5 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame5.ent \
   	      -textvariable paramaltaz(maxdelta) -width 10
   	   pack .test5.frame5.ent \
   	      -in .test5.frame5 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	##############
   	#--- Cree un frame
   	frame .test5.frame6 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame6 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame6.lab \
   	      -text "$caption(acqcolor,fonc_tolerance)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame6.lab \
   	      -in .test5.frame6 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame6.ent \
   	      -textvariable paramaltaz(imagename5) -width 10
   	   pack .test5.frame6.ent \
   	      -in .test5.frame6 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	
   	#--- Cree un frame
   	frame .test5.frame7 \
   	   -borderwidth 0 -cursor arrow -bg $color(back)
   	pack .test5.frame7 \
   	   -in .test5 -anchor center -side top -expand 0 -fill x
   	
   	   #--- Cree le label
   	   label .test5.frame7.lab \
   	      -text "$caption(acqcolor,fonc_libre)" -bg $color(back) -fg $color(text)
   	   pack .test5.frame7.lab \
   	      -in .test5.frame7 -side left -anchor center \
   	      -padx 3 -pady 3
   	
   	   #--- Cree l'entry
   	   entry .test5.frame7.ent \
   	      -textvariable paramaltaz(libre) -width 10
   	   pack .test5.frame7.ent \
   	      -in .test5.frame7 -side left -anchor center -expand 1 -fill x \
   	      -padx 10 -pady 3
   	
   	
   	#--- Cree le bouton 'Validation'
   	button .test5.but_valid \
   	   -text "$caption(acqcolor,fonc_executer)" -borderwidth 4 \
   	   -command ::pointageauto
   	
   	
   	pack .test5.but_valid \
   	   -in .test5 -side bottom -anchor center \
   	   -padx 3 -pady 3
   	#::console::affiche_resultat "passage 3"
   	#--- Detruit la fenetre avec la croix en haut a droite
   	bind .test5 <Destroy> {
   	   fermerTout
   	}
   
   	#################################################################################
   	#### proc tourisme.pointageauto
   	#################################################################################
   	proc  pointageauto { } {
   		
   		#::console::affiche_resultat "passage 4"
   		# effectue le pointage séquentiel d'une liste d'objet contenue dans le fichier tourisme
   		global caption
   		global base
   		global paramaltaz
   		global etelsimu
   		#set paramaltaz(sortie)  "0" 
   		global audace
   		
   		# je change le texte du bouton executer
   		
   		.test5.but_valid  configure -text "FIN" -command ::stoptour
   
   		tel1 set_register_s 0 X 24 0 [expr $paramaltaz(libre)/2]
   		tel1 set_register_s 1 X 24 0 $paramaltaz(libre)
   			
   		cd $audace(rep_images)
   		
   		# j'ajoute le repertoire image en préfixe au nom du fichier
   		set fichcord "$audace(rep_images)/$paramaltaz(imagename)"
   		
   		# je nomme le fichier de liste des coordonnées 
   		set filebrut  "[file rootname $fichcord]"
   		
   		# j'ouvre le fichier de coordonnees obljets a observer
   		set fbrut [open "$fichcord" r]
   		
   		# je traite le fichier de ccordonnes brutes
   		while {-1 != [gets $fbrut line1]} {   
      		
      		# je decoupe la ligne en une liste de champs
      		set line2 [split [regsub -all {[ \t\n]+} $line1 { }]]
      		
      		# je copie chaque champ dans une variable distincte
      		set paramaltaz(nom)	[lindex $line2 0]
      		set h      		[lindex $line2 1]
      		set hm      		[lindex $line2 2]
      		set hs      		[lindex $line2 3]
      		set d      		[lindex $line2 4]
      		set dm      		[lindex $line2 5]
      		set ds      		[lindex $line2 6]
      		set blabla      	[lindex $line2 7]
      		#::console::affiche_resultat "passage 5"
      		set hmin 	[ lindex $paramaltaz(minalpha) 0 ]
      		set hmmin 	[ lindex $paramaltaz(minalpha) 1 ]
      		set hmax 	[ lindex $paramaltaz(maxalpha) 0 ]
      		set hmmax 	[ lindex $paramaltaz(maxalpha) 1 ]
      		set dmin 	[ lindex $paramaltaz(mindelta) 0 ]
      		set dmax 	[ lindex $paramaltaz(maxdelta) 0 ]
      			if { $paramaltaz(stoptr) ==1 } {
      		set hmax 	[ lindex $paramaltaz(minalpha) 0 ]
      		set hmax  [expr $hmax-1]
      		if { $hmax < 0 } {
	      		set hmax 23
      		}
      		}
      		# je passe outre les lignes hors du cadre retenu
      		if { $h<$hmin } {
      			continue
      		}
      		if { $h==$hmin } {
      			if { $hm<$hmmin } {
      				continue
      			}
      		}
      		if { $h>$hmax } {
      			continue
      		}
      		if { $h==$hmax } {
      			if { $hm>$hmmax } {
      				continue
      			}
      		}
      		if { $d<$dmin } {
      			continue
      		}		
      		
      		if { $d>$dmax } {
      			continue
      		}
      		#  #je passe outre les lignes vides
      		if { $paramaltaz(nom) == ""} {
      			continue
      		}
      		#::console::affiche_resultat "passage 6"
      		# je reconstitue les coordonnées
      		set paramaltaz(point,ra) "$h $hm $hs"
      		set paramaltaz(point,dec) "$d $dm $ds"
      		::console::affiche_resultat "$paramaltaz(nom) = ad $paramaltaz(point,ra) dec = $paramaltaz(point,dec) coment=$blabla \n"
      		catch {exec espeak.exe -v fr "Je pointe $paramaltaz(nom)"}
      		::pointer
      		::met_a_jour 
      		catch {exec espeak.exe -v fr "$paramaltaz(nom) a été pointée"}
      		after 500
      		# +++++++++++++++++++++++++++je relance le suivi en effectuant 2 fois la boucle calcul
      		set paramaltaz(sortie)  "0" 
      		set paramaltaz(boucle)  "0" 
      		#::calcul
      		::etel_suivi_diurne
      		after 500
      		catch {exec espeak.exe -v fr "suivi en cours"}
      		::etel_suivi_diurne
      		after 500
      		#::calcul		
      		set choixmsg [expr round(rand()*5)]
      		if {$choixmsg==0} {
      			catch {exec espeak.exe -v fr "Appuie sur le bouton du haut pour passer à l'objet suivant."}			
         	} elseif {$choixmsg==1} {
      			catch {exec espeak.exe -v fr "Je passe à l'objet suivant si tu appuies sur le bouton du haut."}			
         	} elseif {$choixmsg==2} {
      			catch {exec espeak.exe -v fr "Pour passer à l'objet suivant, tu appuie sur le bouton du haut."}			
         	} elseif {$choixmsg==3} {
      			catch {exec espeak.exe -v fr "Si c'est l'heure de l'apéro, alors appuie sur le bouton du haut."}			
         	} elseif {$choixmsg==4} {
      			catch {exec espeak.exe -v fr "Si tu es fatigué, passe au suivant et prend un jaune. Appuie alors sur le bouton du haut."}			
         	} else {
      			catch {exec espeak.exe -v fr "Appuie sur le bouton pour boire un coup. Ah non, excuse-moi, c'est pour passer à l'objet suivant."}
         	}
      		
      		after 500
      		# boucle d'attente observateur
      		set w 0
      		while {1==1} {
      			
               # je redonne la main a la raquette soft
       			set n "[combit 1 1]"
      			if {$n == 1 }  {
      				#set n 0
      				#after 500
      				#set n "[combit 1 1]"
         			#if {$n == 1 }  {
          				::shiftn
         			#}
       			}
       			set e "[combit 1 8]"
      			after 100
      			set o "[combit 1 6]"
       			set s [expr $o+$e]
       			if {$s == 2 }  {
      	 			#set s 0
      	 			#after 500
         	 		#set e "[combit 1 8]"
         			#after 100
         			#set o "[combit 1 6]"
          			#set s [expr $o+$e]
          			#if {$s == 2 }  {
         				::shifts
         			#}
      			}
      			if { $s != "2" } {
      				if {$e == 1 }  {
      					#set e 0
      					#after 500
      	 				#set e "[combit 1 8]"
         				#if {$e == 1 }  {
          					::shifte
         				#}
         			}
      				if {$o == 1 }  {
      					#set o 0
      					#after 500
      	 				#set o "[combit 1 6]"
         				#if {$o == 1 }  {
       					::shifto
      					#}
       				}
      		   }
      			::etel_suivi_diurne
      			update
      			set w "[combit 1 9]"
      			after 500
      	   	# catch {exec espeak.exe -v fr "Appuie sur bouton noir pour passer à l'objet suivant. w=$w"}
      			if {$w == 1 }  {
      			   #set w 0
      				#after 500
      				#set w "[combit 1 9]"
         			#if {$w == 1 }  {
         				break
         			#}
      			}
      		}
      	
      		after 500
      		set choixmsg [expr round(rand()*5)]
      		if {$choixmsg==0} {
      	   	catch {exec espeak.exe -v fr "On passe à l'objet suivant."}
         	} elseif {$choixmsg==1} {
      	   	catch {exec espeak.exe -v fr "Je vais passer à la suite."}
         	} elseif {$choixmsg==2} {
      	   	catch {exec espeak.exe -v fr "Allez, j'y vais vite fait."}
         	} elseif {$choixmsg==3} {
      	   	catch {exec espeak.exe -v fr "Je continue avec le suivant monsieur l'astronome."}
         	} elseif {$choixmsg==4} {
      	   	catch {exec espeak.exe -v fr "C'est parti pour le prochain objet. Youpi."}
         	} else {
      	   	catch {exec espeak.exe -v fr "On va changer d'objet mon ami."}
         	}
         	after 500
         }
      
      	#je ferme le fichier de coordonnees brute
      	close $fbrut
      	after 1000
      	catch {exec espeak.exe -v fr "C'est fini"}
      	after 1000
      	catch {exec espeak.exe -v fr "C'est fini"}	
      
      }
   	
   }

   #=========================================================
   # fermerTout
   #   cette procedure ferme  la fenetre tourisme
   #=========================================================
   proc fermerTout { } {
   	set paramaltaz(tour)  "0"
   	
	   #--- je ferme la fenetre
	   destroy .test5
	   #::calcul
   }
   
	after 2000
	   proc stoptour { } {
   	global caption
   	global base
   	global infos
   	global audace
      global paramaltaz
      global daquin
      set ::infos(encours) "0"
      set infos(sortie) 1
     	set paramaltaz(stoptr) "1"
      set paramaltaz(sortie) "0"
   }
	
}

#################################################################################
#### fermerTout
####   cette procedure ferme  la fenetre tourisme
#################################################################################
proc fermerTout { } {
   set paramaltaz(tour)  "0"   
   #--- je ferme la fenetre
   destroy .test5
}


#################################################################################
#### script Tk de la grande fenetre principale
#################################################################################
frame $base.f -bg $paramaltaz(color,back)
   label $base.f.lab_titre \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font) -text "pilotage telescope azimutal"
   pack $base.f.lab_titre
   #---
   label $base.f.lab_tu \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   label $base.f.lab_tsl \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   pack $base.f.lab_tu -fill none -pady 2
   pack $base.f.lab_tsl -fill none -pady 2
   #---
   frame $base.f.ca -bg $paramaltaz(color,back)
      label $base.f.ca.lab1 -text "******************************************" \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
           pack $base.f.ca.lab1 -side left -fill none
   		pack $base.f.ca -fill none -pady 2

   #---
   frame $base.f.ra -bg $paramaltaz(color,back)
      label $base.f.ra.lab1 -text "$caption(horloge_astro,ad) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.ra.ent1 -textvariable paramaltaz(new,ra) \
         -width 30  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -relief flat
      pack $base.f.ra.lab1 -side left -fill none
      pack $base.f.ra.ent1 -side left -fill none
   pack $base.f.ra -fill none -pady 2
   frame $base.f.dec -bg $paramaltaz(color,back)
      label $base.f.dec.lab1 -text "$caption(horloge_astro,dec) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.dec.ent1 -textvariable paramaltaz(new,dec) \
         -width 30  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) \
         -fg $paramaltaz(color,text) -relief flat
      pack $base.f.dec.lab1 -side left -fill none
      pack $base.f.dec.ent1 -side left -fill none
   pack $base.f.dec -fill none -pady 2
   
   #***************PIERRE
   frame $base.f.vsa -bg $paramaltaz(color,back)
      label $base.f.vsa.lab1 -text "$caption(vsa) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.vsa.ent1 -textvariable paramaltaz(new,vsa) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -relief flat
      pack $base.f.vsa.lab1 -side left -fill none
      pack $base.f.vsa.ent1 -side left -fill none
   pack $base.f.vsa -fill none -pady 2
   frame $base.f.vsh -bg $paramaltaz(color,back)
      label $base.f.vsh.lab1 -text "$caption(vsh) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.vsh.ent1 -textvariable paramaltaz(new,vsh) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) \
         -fg $paramaltaz(color,text) -relief flat
      pack $base.f.vsh.lab1 -side left -fill none
      pack $base.f.vsh.ent1 -side left -fill none
   pack $base.f.vsh -fill none -pady 2
      frame $base.f.vsc -bg $paramaltaz(color,back)
      label $base.f.vsc.lab1 -text "$caption(vsc) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.vsc.ent1 -textvariable paramaltaz(new,vsc) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) \
         -fg $paramaltaz(color,text) -relief flat
      pack $base.f.vsc.lab1 -side left -fill none
      pack $base.f.vsc.ent1 -side left -fill none
   pack $base.f.vsc -fill none -pady 2
   # ---
   button $base.f.but1 -text "$caption(horloge_astro,valider)" -command { global paramaltaz ; met_a_jour ; set paramaltaz(action) motor_on }
   pack $base.f.but1 -ipadx 5 -ipady 2
   
   #---
   label $base.f.lab_ha \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   label $base.f.lab_altaz \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   pack $base.f.lab_ha -fill none -pady 2
   pack $base.f.lab_altaz -fill none -pady 2

    #***************PIERRE
   label $base.f.via \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   label $base.f.vih \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   label $base.f.vic \
      -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
      -font $paramaltaz(font)
   pack $base.f.via -fill none -pady 2
   pack $base.f.vih -fill none -pady 2
   pack $base.f.vic -fill none -pady 2
    
   #+++++++++POINTAGE
   frame $base.f.cadr -bg $paramaltaz(color,back)
      label $base.f.cadr.lab1 -text "**************************************** " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
         pack $base.f.cadr.lab1 -side left -fill none
   pack $base.f.cadr -fill none -pady 2

   frame $base.f.rapc -bg $paramaltaz(color,back)
      label $base.f.rapc.lab1 -text "coefficent pointage azimut " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.rapc.ent1 -textvariable paramaltaz(xsam) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -relief flat
      pack $base.f.rapc.lab1 -side left -fill none
      pack $base.f.rapc.ent1 -side left -fill none
   pack $base.f.rapc -fill none -pady 2
   frame $base.f.decpc -bg $paramaltaz(color,back)
      label $base.f.decpc.lab1 -text "coefficent pointage hauteur " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.decpc.ent1 -textvariable paramaltaz(xshm) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) \
         -fg $paramaltaz(color,text) -relief flat
      pack $base.f.decpc.lab1 -side left -fill none
      pack $base.f.decpc.ent1 -side left -fill none
	pack $base.f.decpc -fill none -pady 2

   frame $base.f.rap -bg $paramaltaz(color,back)
      label $base.f.rap.lab1 -text "$caption(horloge_astro,ad) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.rap.ent1 -textvariable paramaltaz(point,ra) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -relief flat
      pack $base.f.rap.lab1 -side left -fill none
      pack $base.f.rap.ent1 -side left -fill none
   pack $base.f.rap -fill none -pady 2
   frame $base.f.decp -bg $paramaltaz(color,back)
      label $base.f.decp.lab1 -text "$caption(horloge_astro,dec) " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font)
      entry $base.f.decp.ent1 -textvariable paramaltaz(point,dec) \
         -width 10  -font $paramaltaz(font) \
         -bg $paramaltaz(color,back) \
         -fg $paramaltaz(color,text) -relief flat
      pack $base.f.decp.lab1 -side left -fill none
      pack $base.f.decp.ent1 -side left -fill none
   pack $base.f.decp -fill none -pady 2

   frame $base.f.tour -bg $paramaltaz(color,back)
      label $base.f.tour.lab1 -text "objet " \
         -bg $paramaltaz(color,back) -fg $paramaltaz(color,text) \
         -font $paramaltaz(font1)
      entry $base.f.tour.ent1 -textvariable paramaltaz(nom) \
         -width 10  -font $paramaltaz(font1) \
         -bg $paramaltaz(color,back) \
         -fg $paramaltaz(color,text) -relief flat
      pack $base.f.tour.lab1 -side left -fill none
      pack $base.f.tour.ent1 -side left -fill none
   pack $base.f.tour -fill none -pady 2

   frame $base.f.b1 -bg $paramaltaz(color,back)
	   button $base.f.b1.but2 -text "POINTER" -command { global paramaltaz ; set paramaltaz(action) goto }
	   pack $base.f.b1.but2 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
	
		button $base.f.b1.but3 -text "PARK" -command { park }
	   pack $base.f.b1.but3 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
	
		button $base.f.b1.but4 -text "retour PARK" -command { retourpark }
	   pack $base.f.b1.but4 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
   pack $base.f.b1 -fill none -pady 2

   frame $base.f.b2 -bg $paramaltaz(color,back)   
		button $base.f.b2.but5 -text "tourisme" -command { tourisme }
	   pack $base.f.b2.but5 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
	   
	   #********autoguid
		button $base.f.b2.but6 -text "autoguidage" -command {autoguid}
	   pack $base.f.b2.but6 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
	   
	   #********RAQUETTE rapide
		button $base.f.b2.but7 -text "accelerer raquette" -command {paramraq}
	   pack $base.f.b2.but7 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
   	pack $base.f.b2 -fill none -pady 2
   	   #********RAQUETTE lente
		button $base.f.b2.but8 -text "ralentir raquette" -command {paramraq1}
	   pack $base.f.b2.but8 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
   	pack $base.f.b2 -fill none -pady 2
    #********initialisation monture
    	button $base.f.b2.but9 -text "initialisation monture" -command {init_monture1}
	   pack $base.f.b2.but9 -ipadx 5 -ipady 2 -side left -anchor center -padx 3 -pady 3
   	pack $base.f.b2 -fill none -pady 2
    
   
pack $base.f -fill both

#--- j'ouvre le port serie
set ::infos(portnum) 1
set portName "COM$infos(portnum)"
if {$etelsimu(simulation)==0} {
   #--- je charge la librairie combit
   load [file join $audela_start_dir libcombit.dll]
   set ::infos(portHandle) [open $portName "RDWR"]
   fconfigure $::infos(portHandle) -mode "9600,n,8,1" -buffering none -blocking 0
} else {
   proc combit { args } {
      return 0
   }
   set ::infos(portHandle) simu
}

#combit $infos(portnum) 3 0
#combit $infos(portnum) 4 0
#combit $infos(portnum) 7 0


    
#################################################################################
#### proc shiftn
#################################################################################
proc shiftn  { } {
	global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	global daquin
	
	if { $paramaltaz(vrac) == 0 }  {
		::console::affiche_resultat "   shiftn1  \n"
		tel1 execute_command_x_s 1 26 1 0 0 79
		after 100
		set pos0 [tel1 get_register_s 1 M 7]
		set paramaltaz(sortie) "1"
		tel1 execute_command_x_s 1 26 1 0 0 76
		::console::affiche_resultat "   shiftn2 \n"
		after 50	           
		for {set k 1} {$k<100000} {incr k} {
			# mesure de la variable d'état des bits  
			set n "[combit 1 1]"
			after 50
			if {$n == 0 }  {
				set k  100000
				::console::affiche_resultat "   shiftn3 \n"
			}
		}
		tel1 execute_command_x_s 1 26 1 0 0 79
		set paramaltaz(sortie) "0"
		#after 1500
	}
	if { $paramaltaz(vrac) == 1 }  {
		#copie
		#création d'une vitesse de rappel lente
		set vrh  [tel1 get_register_s 1 X 41]
		#récupération de la vitesse actuelle de suivi
		set vh  [tel1 get_register_s 1 X 13]
		#vitesse rappel lent plus
	   set vhr [expr $vh+$vrh]
	   #vitesse rappel lent moins
	   set vhl [expr $vh-$vrh]
	   #enregistrement vitesses
	   tel1 set_register_s 1 X 42 0 [expr abs($vhr) ]
	   tel1 set_register_s 1 X 43 0 [expr abs($vhl) ] 
	   ::console::affiche_resultat "  $vrh $vh $ $vhr $vhl \n"
	   #récupération du sens actuel de rotation
		set sens [tel1 get_register_s 1 X 40]
		::console::affiche_resultat "  $vrh $vh $ $vhr $vhl sens=$sens 1=82 $vhr \n"
	   #mouvement télescope
		if { $sens == 1  } {
			tel1 execute_command_x_s 1 26 1 0 0 82	
		}
		if { $sens == 0  } {
	     	if { $vhl < 0  } {
				tel1 execute_command_x_s 1 26 1 0 0 85	
				::console::affiche_resultat "  85 $vhl \n"
			}
			if { $vhl >= 0  } {
				tel1 execute_command_x_s 1 26 1 0 0 83
				::console::affiche_resultat " 83 $vhl \n"
			}
		}
		set e 0
		set o 0
		for {set k 1} {$k<100000} {incr k} {
			# mesure de la variable d'état des bits  
			set n "[combit 1 1]"
			after 50
			if {$n == 0 }  {
				set k  100000
				::console::affiche_resultat "   shiftn5 \n"
			}
		}
    	#pierre pierre
	 	#tel1 execute_command_x_s 1 26 1 0 0 79
	 	::::etel_suivi_diurne
		set paramaltaz(sortie) "0"
   }

}


#################################################################################
#### proc shifts
#################################################################################

########################il conviendrait de créer une procédure (comme parraq) complète comprenant les X40 41 42 ET LES SEQUENCES 82 83 84 85 ET DE L'APPELER dans tous les shift et les move-e o n s et l'autoguidage
proc shifts  { } {
	global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	global daquin
	
	if { $paramaltaz(vrac) == 0 }  {
	::console::affiche_resultat "   shifts1 \n"
	tel1 execute_command_x_s 1 26 1 0 0 79
	after 100
	set pos0 [tel1 get_register_s 1 M 7]
	set paramaltaz(sortie) "1"
	tel1 execute_command_x_s 1 26 1 0 0 75
	::console::affiche_resultat "   shifts2 \n"
	set e 0
	set o 0
	after 50	           
	for {set k 1} {$k<100000} {incr k} {
		# mesure de la variable d'état des bits  
		set e "[combit 1 8]"
		after 50
		set o "[combit 1 6]"
		set s [expr $o+$e]
		if {$s != "2"  }  {
			set k  100000
			::console::affiche_resultat "   shifts3 \n"
		}
	}
	tel1 execute_command_x_s 1 26 1 0 0 79
	set paramaltaz(sortie) "0"
	#after 1500
	}
			if { $paramaltaz(vrac) == 1 }  {
		::console::affiche_resultat "   shiftn4  \n"
		#création d'une vitesse de rappel lente
		set vrh  [tel1 get_register_s 1 X 41]
		#récupération de la vitesse actuelle de suivi
		set vh  [tel1 get_register_s 1 X 13]
		#vitesse rappel lent plus
	   set vhr [expr $vh+$vrh]
	   #vitesse rappel lent moins
	   set vhl [expr $vh-$vrh]
	   #enregistrement vitesses
	   tel1 set_register_s 1 X 42 0 [expr abs($vhr)]
	   tel1 set_register_s 1 X 43 0 [expr abs($vhl)] 
	   #tel1 set_register_s 1 X 13 0 [expr abs($vih)]
	   ::console::affiche_resultat "  $vrh $vh $ $vhr $vhl \n"
	   #récupération du sens actuel de rotation
		set sens [tel1 get_register_s 1 X 40]
		::console::affiche_resultat "  $vrh $vh $ $vhr $vhl sens=$sens 0=84 $vhr \n"
	   #mouvement télescope	   
		if { $sens == 0  } {
			tel1 execute_command_x_s 1 26 1 0 0 84	
		}
		if { $sens == 1  } {
			if { $vhl < 0  } {
				tel1 execute_command_x_s 1 26 1 0 0 85	
				::console::affiche_resultat " 85 $vhl \n"
			}
			if { $vhl >= 0  } {
				tel1 execute_command_x_s 1 26 1 0 0 83	
				::console::affiche_resultat " 83 $vhl \n"
			}
		}
	for {set k 1} {$k<100000} {incr k} {
		# mesure de la variable d'état des bits  
		set e "[combit 1 8]"
		after 50
		set o "[combit 1 6]"
		set s [expr $o+$e]
		if {$s != "2"  }  {
			set k  100000
			::console::affiche_resultat "   shifts5 \n"
		}
	}
    #pierre pierre
	 #tel1 execute_command_x_s 1 26 1 0 0 79
	 ::::etel_suivi_diurne
		set paramaltaz(sortie) "0"
	
	} 

}

#################################################################################
#### proc shifte
#################################################################################
proc shifte  { } {
	global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	global daquin
	
	if { $paramaltaz(vrac) == 0 }  {
	::console::affiche_resultat "   shifte1 \n"
	set pos0 [tel1 get_register_s 0 M 7]

		tel1 execute_command_x_s 0 26 1 0 0 75
		::console::affiche_resultat "   shifte2 \n"
	
	after 50	           
	for {set k 1} {$k<100000} {incr k} {
		# mesure de la variable d'état des bits  
		set e "[combit 1 8]"
		after 50
		if {$e == 0 }  {
			set k  100000
			::console::affiche_resultat "   shifte3 \n"
		}
	}
	tel1 execute_command_x_s 0 26 1 0 0 79
	##::console::affiche_resultat " pos0=$pos0 \n"
	set paramaltaz(sortie) "0"
	
}
	if { $paramaltaz(vrac) == 1 }  {
	
	#création d'une vitesse de rappel lente
	set vra  [tel1 get_register_s 0 X 41]
	#récupération de la vitesse actuelle de suivi
	set va  [tel1 get_register_s 0 X 13]
	#vitesse rappel lent plus
   set var [expr $va+$vra]
   #vitesse rappel lent moins
   set val [expr $va-$vra]
   #enregistrement vitesses
   tel1 set_register_s 0 X 42 0 [expr abs($var) ]
   tel1 set_register_s 0 X 43 0 [expr abs($val) ] 
   #récupération du sens actuel de rotation
	set sens [tel1 get_register_s 0 X 40]
	::console::affiche_resultat "  $vra $va $ $var $val $sens 1=82 $var \n"
   #mouvement télescope
			  if { $sens == 1  } {
				  tel1 execute_command_x_s 0 26 1 0 0 82
				  	
			  }
					  if { $sens == 0  } {
						     	if { $val < 0  } {
								tel1 execute_command_x_s 0 26 1 0 0 83	
								::console::affiche_resultat "  83 $val \n"
			   				}
			   					if { $val >= 0  } {
								tel1 execute_command_x_s 0 26 1 0 0 85
								::console::affiche_resultat "  85 $val \n"
			   				}
					  }
	for {set k 1} {$k<100000} {incr k} {
		# mesure de la variable d'état des bits  
		set e "[combit 1 8]"
		after 50
		if {$e == 0 }  {
			set k  100000
			::console::affiche_resultat "   shifte3 \n"
		}

	}
    #pierre pierre
	 #tel1 execute_command_x_s 1 26 1 0 0 79
	 ::::etel_suivi_diurne
	set paramaltaz(sortie) "0"

   	} 
		#if {$daquin(w) == 1 }  {
				#::etel_suivi_diurne
				
		#}
}
#################################################################################
#### proc shifto
#################################################################################
proc shifto  { } {
		global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	global daquin
	
	set e "[combit 1 8]"
		after 50
		set o "[combit 1 6]"
		set s [expr $o+$e]
		if {$s != "2"  }  {
			if { $paramaltaz(vrac) == 0 }  {
			::console::affiche_resultat "   shifto1 \n"
		
				tel1 execute_command_x_s 0 26 1 0 0 76
				::console::affiche_resultat "   shifto2 \n"
			
			after 50	           
				for {set k 1} {$k<100000} {incr k} {
				# mesure de la variable d'état des bits  
				set o "[combit 1 6]"
				after 50
					if {$o == 0  }  {
						set k  100000
						::console::affiche_resultat "   shifto3 \n"
					}
				}	
			tel1 execute_command_x_s 0 26 1 0 0 79
			##::console::affiche_resultat " pos0=$pos0 \n"
			set paramaltaz(sortie) "0"
			}
				if { $paramaltaz(vrac) == 1 }  {
				
				#création d'une vitesse de rappel lente
				set vra  [tel1 get_register_s 0 X 41]
				#récupération de la vitesse actuelle de suivi
				set va  [tel1 get_register_s 0 X 13]
				#vitesse rappel lent plus
			   set var [expr $va+$vra]
			   #vitesse rappel lent moins
			   set val [expr $va-$vra]
			   #enregistrement vitesses
			   tel1 set_register_s 0 X 42 0 [expr abs($var) ]
			   tel1 set_register_s 0 X 43 0 [expr abs($val) ] 
			   
			   #récupération du sens actuel de rotation
				set sens [tel1 get_register_s 0 X 40]
				::console::affiche_resultat "  $vra $va $ $var $val $sens 0=84 $var \n"
			   #mouvement télescope
						  if { $sens == 0  } {
							  tel1 execute_command_x_s 0 26 1 0 0 84	
						  }
								  if { $sens == 1  } {
									     	if { $val < 0  } {
											tel1 execute_command_x_s 0 26 1 0 0 85	
											::console::affiche_resultat "  85 $val \n"
						   				}
						   					if { $val >= 0  } {
											tel1 execute_command_x_s 0 26 1 0 0 83	
											::console::affiche_resultat "  83 $val \n"
						   				}
								  }
										for {set k 1} {$k<100000} {incr k} {
										# mesure de la variable d'état des bits  
										set o "[combit 1 6]"
										after 50
											if {$o == 0  }  {
												set k  100000
												::console::affiche_resultat "   shifto3 \n"
											}
										}
    #pierre pierre
	 #tel1 execute_command_x_s 1 26 1 0 0 79
	 ::::etel_suivi_diurne
				set paramaltaz(sortie) "0"
			
			   }
  } 
  	#if {$daquin(w) == 1 }  {
		#::etel_suivi_diurne
		
	#}

}

#################################################################################
#### proc decode_radec_entry
#################################################################################
proc decode_radec_entry { ra dec } {
	global paramaltaz
	set n [llength $ra]
	set car [string index $ra 0]
	if {$n==3} {
		set xra "[ lindex $ra 0 ]h[ lindex $ra 1 ]m[ lindex $ra 2 ]"		
		set xdec "[ lindex $dec 0 ]d[ lindex $dec 1 ]m[ lindex $dec 2 ]"
	} elseif {$car=="*"} {
		set name [string range $ra 1 end]
		set err [catch {name2coord $name} coords]
		if {$err==1} {
			error $coords
		} else {
			set xra [lindex $coords 0]
			set xdec [lindex $coords 1]
		}
	} else {
		set xra  [string trim [mc_angle2deg $ra]]
		set xdec [string trim [mc_angle2deg $dec 90]]
	}
	set xra [mc_angle2hms $xra]
	set xra [list [lindex $xra 0] [lindex $xra 1] [format %.2f [lindex $xra 2]]]
	set xdec [mc_angle2dms $xdec 90]
	set xdec [list [lindex $xdec 0] [lindex $xdec 1] [format %.1f [lindex $xdec 2]]]
	return [list $xra $xdec]
}

#################################################################################
#### proc vitesse raquette
#################################################################################
proc paramraq	{ } {
	global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	

		set paramaltaz(vrac) 0

}

proc paramraq1	{ } {
	global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	
	# passage vitesse normale vitesse lente


		set paramaltaz(vrac) 1

}
#################################################################################
#### proc position initiale
#################################################################################
proc posini { } {
   global audace
	global caption
	global base
	global posinibase
	global paramaltaz
	global daquin
	         
   if {$paramaltaz(park) == 0 }  {
   	set daquin(w) 0
   	catch {exec espeak.exe -v fr "raquette active positionnez le télescope a moins 40 et sur le méridien "}   	

		while {1==1} {
			set n 0
			set s 0
			set o 0
			set e 0
      	# je redonne la main a la raquette soft
 			set n "[combit 1 1]"
			if {$n == 1 }  {
# 				set n 0
# 				after 500
# 				set n "[combit 1 1]"
# 			if {$n == 1 }  {
 				::shiftn
# 				}
			set n 0
 			}
 			set e "[combit 1 8]"
			after 200
			set o "[combit 1 6]"
			after 100
 			set s [expr $o+$e]
 			if {$s == 2 }  {
# 	 			set s 0
# 	 			after 500
#    	 		set e "[combit 1 8]"
#    			after 100
#    			set o "[combit 1 6]"
#    			after 100
#     			set s [expr $o+$e]
#     			if {$s == 2 }  {
   				::shifts
#    			}
	
			}
			if { $s != "2" } {
			set e 0	
			set o 0
		 	set e "[combit 1 8]"
			after 200
			set o "[combit 1 6]"
			after 100
 			set s [expr $o+$e]		
				if { $s != "2" } {	
					
					if {$e == 1 }  {
	# 					set e 0
	# 					after 500
	# 	 				set e "[combit 1 8]"
	#    				if {$e == 1 }  {
	    					::shifte
	#    				}
					set e 0
	   			}
					if {$o == 1 }  {
	# 					set o 0
	# 					after 500
	# 	 				set o "[combit 1 6]"
	#    				if {$o == 1 }  {
	    					::shifto    					
	#     				}
					set o 0
			      }
		      }
	      }
			
			set daquin(w) "[combit 1 9]"			
			update
			if {$daquin(w) == 1 }  {
				$posinibase.fra.but1 configure -command { retourpark }
  				break
			}
		}
		#after 500
	   catch {exec espeak.exe -v fr "raquette innactive"}
	   #catch {exec espeak.exe -v fr "cliquez sur retour park "}
	   #catch {exec espeak.exe -v fr "  retour park "}
   }
}

#################################################################################
#### proc proc init_monture pointage pour t 940 
#################################################################################
proc init_monture1 { } {
   global caption
   global base
   global paramaltaz
   set paramaltaz(sortie)  "0" 
   set paramaltaz(tour)  "1"
   global audace
   #cd $audace(rep_images)
   #--- Definition des couleurs
   set color(back)       #56789A
   set color(text)       #FFFFFF
   set color(back_image) #123456
   set color(red)        #FF0000
   set color(green)      #00FF00
   set color(blue)       #0000FF
   set color(rectangle)  #0000EF
   set color(scroll)     #BBBBBB
   
   set caption(acqcolor,fonc_titre3)	"reglage des parametres de la monture "
   set caption(acqcolor,fonc_comment5)	" "
   set caption(fonc_vsam)	"vitesse azimutale sens horaire......$paramaltaz(vsam)."
   set caption(fonc_vsap)	"vitesse azimutale sens anti-horaire $paramaltaz(vsap)."
   set caption(fonc_xsam)	"degré azimutal sens horaire.........$paramaltaz(xsam)."
   set caption(fonc_xsap)	"degré azimutal sens anti-horaire....$paramaltaz(xsap)."
   set caption(fonc_vshm)	"vitesse hauteur sens horaire........$paramaltaz(vshm)."
   set caption(fonc_vshp)	"vitesse hauteur sens anti-horaire...$paramaltaz(vshp)."
   set caption(fonc_xshm)	"degré hauteur sens horaire..........$paramaltaz(xshm)."
   set caption(fonc_xshp)	"degré hauteur sens anti-horaire.....$paramaltaz(xshp)."
   set caption(fonc_vsc)	"vitesse champ tous sens.............$paramaltaz(vscm)."
   set caption(fonc_xsc)	"degré champ tous sens...............$paramaltaz(xscp)." 
   set caption(acqcolor,fonc_executer)	"enregistrer les paramètres que vous avez changé"

   #--- valeurs initiales des variables
#    set paramaltaz(vsam) 	"655050"
#    set paramaltaz(vsap) 	"655273"
#    set paramaltaz(xsam)  "3674614"
#    set paramaltaz(xsap)  "3675864"
#    set paramaltaz(vshm) 	"1298651"
#    set paramaltaz(vshp) 	"1297414"
#    set paramaltaz(xshm) 	"7285000"
#    set paramaltaz(xshp) 	"7278061"
#    set paramaltaz(vsc) 	"924492"
#    set paramaltaz(xsc) 	"1728694"
#    set infos(portHandle)         ""
#    set infos(encours)          	""
   
set paramaltaz(n-vsa)    [tel1 get_register_s 0 X 22]
set paramaltaz(n-vsh)    [tel1 get_register_s 1 X 22]
set paramaltaz(n-vsc)    [tel1 get_register_s 2 X 22]
set paramaltaz(n-xsa)    [tel1 get_register_s 0 X 23]
set paramaltaz(n-xsh)    [tel1 get_register_s 1 X 23]
set paramaltaz(n-xsc)    [tel1 get_register_s 2 X 23]

set paramaltaz(n-vsam)    [tel1 get_register_s 0 X 26]
set paramaltaz(n-vshm)    [tel1 get_register_s 1 X 26]
set paramaltaz(n-vscm)    [tel1 get_register_s 2 X 26]

set paramaltaz(n-vsap)    [tel1 get_register_s 0 X 27]
set paramaltaz(n-vshp)    [tel1 get_register_s 1 X 27]
set paramaltaz(n-vscp)    [tel1 get_register_s 2 X 27]

set paramaltaz(n-xsam)    [tel1 get_register_s 0 X 28]
set paramaltaz(n-xshm)    [tel1 get_register_s 1 X 28]
set paramaltaz(n-xscm)    [tel1 get_register_s 2 X 28]

set paramaltaz(n-xsap)    [tel1 get_register_s 0 X 29]
set paramaltaz(n-xshp)    [tel1 get_register_s 1 X 29]
set paramaltaz(n-xscp)    [tel1 get_register_s 2 X 29]

   #=========================================================
   # fenetre init_monture
   #   
   #=========================================================

   #--- Cree la fenetre .init_monture1 de niveau le plus haut
   if [ winfo exists .init_monture1 ] {
      wm withdraw .init_monture1
      wm deiconify .init_monture1
      focus .init_monture1
      return
   }
   toplevel .init_monture1 -class Toplevel -bg $color(back)
   wm geometry .init_monture1 400x400+600+50
   wm title .init_monture1 $caption(acqcolor,fonc_titre3)
   
   #--- La nouvelle fenetre est active
   focus .init_monture1
   
   #--- Cree un frame en haut a gauche pour les canvas d'affichage
   frame .init_monture1.frame0 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame0 \
      -in .init_monture1 -anchor nw -side top -expand 0 -fill x

   #--- Cree le label 'titre'
   label .init_monture1.frame0.lab \
      -text "$caption(acqcolor,fonc_comment5)" -bg $color(back) -fg $color(text)
   pack .init_monture1.frame0.lab \
      -in .init_monture1.frame0 -side top -anchor center \
      -padx 3 -pady 3

   #--- Cree un frame
   frame .init_monture1.frame1 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame1 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame1.lab \
         -text "$caption(fonc_vsam)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame1.lab \
         -in .init_monture1.frame1 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame1.ent \
         -textvariable paramaltaz(n-vsam) -width 10
      pack .init_monture1.frame1.ent \
         -in .init_monture1.frame1 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame .init_monture1.frame2 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame2 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame2.lab \
         -text "$caption(fonc_vsap)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame2.lab \
         -in .init_monture1.frame2 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame2.ent \
         -textvariable paramaltaz(n-vsap)  -width 10
      pack .init_monture1.frame2.ent \
         -in .init_monture1.frame2 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame .init_monture1.frame3 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame3 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame3.lab \
         -text "$caption(fonc_xsam)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame3.lab \
         -in .init_monture1.frame3 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame3.ent \
         -textvariable paramaltaz(n-xsam) -width 10
      pack .init_monture1.frame3.ent \
         -in .init_monture1.frame3 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .init_monture1.frame4 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame4 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame4.lab \
         -text "$caption(fonc_xsap)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame4.lab \
         -in .init_monture1.frame4 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame4.ent \
         -textvariable paramaltaz(n-xsap) -width 10
      pack .init_monture1.frame4.ent \
         -in .init_monture1.frame4 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .init_monture1.frame5 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame5 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame5.lab \
         -text "$caption(fonc_vshm)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame5.lab \
         -in .init_monture1.frame5 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame5.ent \
         -textvariable paramaltaz(n-vshm) -width 10
      pack .init_monture1.frame5.ent \
         -in .init_monture1.frame5 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .init_monture1.frame6 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame6 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame6.lab \
         -text "$caption(fonc_vshp)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame6.lab \
         -in .init_monture1.frame6 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame6.ent \
         -textvariable paramaltaz(n-vshp) -width 10
      pack .init_monture1.frame6.ent \
         -in .init_monture1.frame6 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   frame .init_monture1.frame7 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame7 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame7.lab \
         -text "$caption(fonc_xshm)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame7.lab \
         -in .init_monture1.frame7 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame7.ent \
         -textvariable paramaltaz(n-xshm) -width 10
      pack .init_monture1.frame7.ent \
         -in .init_monture1.frame7 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame .init_monture1.frame8 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame8 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame8.lab \
         -text "$caption(fonc_xshp)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame8.lab \
         -in .init_monture1.frame8 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame8.ent \
         -textvariable paramaltaz(n-xshp) -width 10
      pack .init_monture1.frame8.ent \
         -in .init_monture1.frame8 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
   #--- Cree un frame
   frame .init_monture1.frame9 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame9 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame9.lab \
         -text "$caption(fonc_vsc)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame9.lab \
         -in .init_monture1.frame9 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame9.ent \
         -textvariable paramaltaz(n-vsc) -width 10
      pack .init_monture1.frame9.ent \
         -in .init_monture1.frame9 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
   #--- Cree un frame
   frame .init_monture1.frame10 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .init_monture1.frame10 \
      -in .init_monture1 -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .init_monture1.frame10.lab \
         -text "$caption(fonc_xsc)" -bg $color(back) -fg $color(text)
      pack .init_monture1.frame10.lab \
         -in .init_monture1.frame10 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .init_monture1.frame10.ent \
         -textvariable paramaltaz(n-xsc) -width 10
      pack .init_monture1.frame10.ent \
         -in .init_monture1.frame10 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree le bouton 'Validation'
   button .init_monture1.but_valid \
      -text "$caption(acqcolor,fonc_executer)" -borderwidth 4 \
      -command {modif_paraminit}
   pack .init_monture1.but_valid \
      -in .init_monture1 -side bottom -anchor center \
      -padx 3 -pady 3
      
   #--- Detruit la fenetre avec la croix en haut a droite
   bind .init_monture1 <Destroy> {
      fermerinit_monture
   }
   
   # procédure changement des paramètres
			proc modif_paraminit { } {
			   global caption
			   global base
			   global paramaltaz
			   set paramaltaz(sortie)  "0" 
			   set paramaltaz(tour)  "1"
			   global audace
			   
			set paramaltaz(vsa)    	$paramaltaz(n-vsa)
			set paramaltaz(vsh)     $paramaltaz(n-vsh)
			set paramaltaz(vsc)     $paramaltaz(n-vsc)
			set paramaltaz(xsa)     $paramaltaz(n-xsa)
			set paramaltaz(xsh)     $paramaltaz(n-xsh)
			set paramaltaz(xsc)     $paramaltaz(n-xsc)
			
			set paramaltaz(vsam)    $paramaltaz(n-vsam)
			set paramaltaz(vshm)    $paramaltaz(n-vshm)
			set paramaltaz(vscm)    $paramaltaz(n-vscm)
			
			set paramaltaz(vsap)    $paramaltaz(n-vsap)
			set paramaltaz(vshp)    $paramaltaz(n-vshp)
			set paramaltaz(vscp)    $paramaltaz(n-vscp)
			
			set paramaltaz(xsam)    $paramaltaz(n-xsam)
			set paramaltaz(xshm)    $paramaltaz(n-xshm)
			set paramaltaz(xscm)    $paramaltaz(n-xscm)
			set paramaltaz(xsap)    $paramaltaz(n-xsap)
			set paramaltaz(xshp)    $paramaltaz(n-xshp)
			set paramaltaz(xscp)    $paramaltaz(n-xscp)
			   
			}
   #=========================================================
   # fermerinit_monture
   #   cette procedure ferme  la fenetre tourisme
   #=========================================================
	proc fermerinit_monture { } {
      #--- je ferme la fenetre
      destroy .init_monture1
	}

}

#################################################################################
#### procedure autoguidage
#################################################################################
proc autoguid { } {
   # Fichier : agETELT400.tcl
   # Description : Panneau pour executer l'autoguidage d'un telescope
   # Auteur : Pierre THIERRY
   # Date de MAJ : OCTOBRE 2010
   
   #set t0 [clock seconds]set dt [expr [clock seconds]-$t0]
   # Fichier : agETELT400.tcl
   # Description : Panneau pour executer l'autoguidage d'un telescope
   # Auteur : Pierre THIERRY
   # Date de MAJ : OCTOBRE 2010

   global conf
   global audace
   global caption
   global color
   global infos
   global paramaltaz
	global base
	global etelsimu
	global daquin
   set caption(acqcolor,interro)		"?"
   

   #--- Definition des couleurs
   set color(back)       #56789A
   set color(text)       #FFFFFF
   set color(back_image) #123456
   set color(red)        #FF0000
   set color(green)      #00FF00
   set color(blue)       #0000FF
   set color(rectangle)  #0000EF
   set color(scroll)     #BBBBBB

   set caption(guid_titre)	"AUTOGUIDAGE BINNING 2x2 1 image/sec GUID T940"
   set caption(guid_comment)	"avant de lancer ce script acquérir une image bin 2x2 "
   set caption(guid_comment1)	" et tracer un large cadre autour de l'etoile guide"
   set caption(guid_focale_guide)	"faire tourner le champ en degres ex +90 -40"
   set caption(guid_focale_imagerie)	"Focale d'imagerie 200 1000 1600"
   set caption(guid_distance_equateur)	"Multiplicateur des rappels en alpha base 6 10 14 20 "
   set caption(guid_rappels_delta)	"Multiplicateur des rappels en delta base 5 7 9 11 "
   set caption(guid_pos_init_x)	"position initiale X"
   set caption(guid_pos_init_y)	"position initiale Y"
   set caption(guid_fonc_libre)	"libre"
   set caption(guid_fonc_decallage_images)	"nombre de pixels de décallage images finales "
   set caption(guid_fonc_tolérance)	"nombre de pixels de tolérance de guidage =+/- "
   set caption(guid_fonc_executer)	"Exécuter"
   #--- Initialisation des variables
   set infos(decallage)		"3"
   set infos(focale_guide)		"4000"
   set infos(rot_poc)		"0"
   set infos(rot_pos)		"0"
   set infos(focale_acq)   	"4000"
   set infos(asc_droite)   	"3"
   set infos(declinaison) 		"5"
   set infos(tolérance) 		"1"
   set infos(x0) 			"127"
   set infos(y0) 			"120"
   set infos(e5)			"150"
   set infos(portHandle)          ""
   set infos(encours)          	""
   set infos(sortie)  "0"
   set infos(fin) "0"
   set infos(stop) "1"
   set infos(objet) "la conjecture de pointcarré"
   set infos(raz)	"0"
   set infos(rah) "1"
   
   set paramaltaz(rac)  "0"
   set paramaltaz(va)  "a"
   set paramaltaz(vh)  "h"
   set paramaltaz(vc)  "c"
   
   #tel1 set_register_s 0 X 14 0 [expr abs($infos(raz))]
   
   #tel1 set_register_s 0 X 14 0 [expr abs($infos(rah))]
   
   #--- je change le nom et la focntion du bouton autoguidage 
   #.guid.but_valid configure -text "STOP" -command ::arreter
   #.guid.but3 configure -text "FIN" -command ::arreter
   # base.f.but8 configure -text "fin autoguid" -command {raquette}
     # pack $base.f.but8 -ipadx 5 -ipady 2
   
   #--- je charge la librairie combit
   #load [file join $audela_start_dir libcombit.dll]
   ::console::affiche_resultat "[mc_date2iso8601 now] : init monture en cours...\n"
 	::console::affiche_resultat "[::audace::date_sys2ut now] \n"   
  	# OUVERTURE FICHIER DES RESULTATS
	cd $audace(rep_images)
	# je nomme le fichier 
	set filetraite  "[file rootname [::audace::date_sys2ut now]]_GUID.txt"
	# j'ouvre le fichier des resultats
	set infos(ftraite) [open "$filetraite" w]
	set ::infos(fich) "1"

   # Initialisation de la monture Etel
   #::tel::create etel pci
   after 2000
   # 11 04 13 tel1 execute_command_x_s 0 26 1 0 0 79
   after 1000
   tel1 execute_command_x_s 0 26 1 0 0 70
   after 1000
   tel1 execute_command_x_s 1 26 1 0 0 79
   after 1000
   tel1 execute_command_x_s 1 26 1 0 0 70

   #--- Initialisation des variables

   #=========================================================
   # autoguider
   #   cette procedure est lancee en cliquant sur le bouton "valider"
   #=========================================================
   proc ::autoguider { } {
      global conf
      global caption
      global color
      global infos
      global paramaltaz
      global audace
      global daquin
      
      set ::infos(encours)  "1" 
      set paramaltaz(sortie) "0"
      
#################################################################################
#### proc parametres raquette
#################################################################################
proc parraq	{ } {
	global audace
	global caption
	global base
	global paramaltaz
	global etelsimu
	global daquin
	global conf
   global color
   global infos
	#shift nord

		#création d'une vitesse de rappel lente
		set vrh  [tel1 get_register_s 1 X 41]
		#récupération de la vitesse actuelle de suivi
		set vh  [tel1 get_register_s 1 X 13]
		#vitesse rappel lent plus
	   set vhr [expr $vh+$vrh]
	   #vitesse rappel lent moins
	   set vhl [expr $vh-$vrh]
	   #enregistrement vitesses
	   tel1 set_register_s 1 X 42 0 [expr abs($vhr) ]
	   tel1 set_register_s 1 X 43 0 [expr abs($vhl) ] 
	   ::console::affiche_resultat "  $vrh $vh $ $vhr $vhl \n"
	   #récupération du sens actuel de rotation
		set sens [tel1 get_register_s 1 X 40]
		::console::affiche_resultat "  $vrh $vh $ $vhr $vhl sens=$sens 1=82 $vhr \n"
	   #mouvement télescope
			  if { $sens == 1  } {
				  #tel1 execute_command_x_s 1 26 1 0 0 82
				  set daquin(snr) 82	
			  }
					  if { $sens == 0  } {
						     	if { $vhl < 0  } {
								#tel1 execute_command_x_s 1 26 1 0 0 85
								set daquin(snr) 85	
								::console::affiche_resultat "  85 $vhl \n"
			   				}
			   					if { $vhl >= 0  } {
								#tel1 execute_command_x_s 1 26 1 0 0 83
								set daquin(snr) 83
								::console::affiche_resultat " 83 $vhl \n"
			   				}
					  }

# shift sud

		
		#création d'une vitesse de rappel lente
		set vrh  [tel1 get_register_s 1 X 41]
		#récupération de la vitesse actuelle de suivi
		set vh  [tel1 get_register_s 1 X 13]
		#vitesse rappel lent plus
	   set vhr [expr $vh+$vrh]
	   #vitesse rappel lent moins
	   set vhl [expr $vh-$vrh]
	   #enregistrement vitesses
	   tel1 set_register_s 1 X 42 0 [expr abs($vhr)]
	   tel1 set_register_s 1 X 43 0 [expr abs($vhl)] 
	   #tel1 set_register_s 1 X 13 0 [expr abs($vih)]
	   ::console::affiche_resultat "  $vrh $vh $ $vhr $vhl \n"
	   #récupération du sens actuel de rotation
		set sens [tel1 get_register_s 1 X 40]
		::console::affiche_resultat "  $vrh $vh $ $vhr $vhl sens=$sens 0=84 $vhr \n"
	   #mouvement télescope	   
		if { $sens == 0  } {
			#tel1 execute_command_x_s 1 26 1 0 0 84
			set daquin(ssr) 84		
		}
		if { $sens == 1  } {
			if { $vhl < 0  } {
				#tel1 execute_command_x_s 1 26 1 0 0 85
				set daquin(ssr) 85		
				::console::affiche_resultat " 85 $vhl \n"
			}
			if { $vhl >= 0  } {
				#tel1 execute_command_x_s 1 26 1 0 0 83
				set daquin(ssr) 83	
				::console::affiche_resultat " 83 $vhl \n"
			}
		}

# shift est
	
	#création d'une vitesse de rappel lente
	set vra  [tel1 get_register_s 0 X 41]
	#récupération de la vitesse actuelle de suivi
	set va  [tel1 get_register_s 0 X 13]
	#vitesse rappel lent plus
   set var [expr $va+$va+$vra]
   #vitesse rappel lent moins
   set val [expr $vra]
   #enregistrement vitesses
   tel1 set_register_s 0 X 42 0 [expr abs($var) ]
   tel1 set_register_s 0 X 43 0 [expr abs($val) ] 
   #récupération du sens actuel de rotation
	set sens [tel1 get_register_s 0 X 40]
	::console::affiche_resultat "  $vra $va $ $var $val $sens 1=82 $var \n"
   #mouvement télescope
			  if { $sens == 1  } {
				  # tel1 execute_command_x_s 0 26 1 0 0 82
				  	set daquin(ser) 82	
			  }
					  if { $sens == 0  } {
						     	#if { $val < 0  } {
								#tel1 execute_command_x_s 0 26 1 0 0 83
									set daquin(ser) 83	
								::console::affiche_resultat "  83 $val \n"
# 			   				}
# 			   					if { $val >= 0  } {
# 								#tel1 execute_command_x_s 0 26 1 0 0 85
# 								set daquin(ser) 85	
# 								::console::affiche_resultat "  85 $val \n"
# 			   				}
					  }

# shift ouest
				
				#création d'une vitesse de rappel lente
				set vra  [tel1 get_register_s 0 X 41]
				#récupération de la vitesse actuelle de suivi
				set va  [tel1 get_register_s 0 X 13]
				#vitesse rappel lent plus
			   set var [expr $va+$va+$vra]
			   #vitesse rappel lent moins
			   set val [expr $vra]
			   #enregistrement vitesses
			   tel1 set_register_s 0 X 42 0 [expr abs($var) ]
			   tel1 set_register_s 0 X 43 0 [expr abs($val) ] 
			   
			   #récupération du sens actuel de rotation
				set sens [tel1 get_register_s 0 X 40]
				::console::affiche_resultat "  $vra $va $ $var $val $sens 0=84 $var \n"
			   #mouvement télescope
						  if { $sens == 0  } {
							 # tel1 execute_command_x_s 0 26 1 0 0 84	
							 set daquin(sor) 84	
						  }
								  if { $sens == 1  } {
									     	#if { $val < 0  } {
											#tel1 execute_command_x_s 0 26 1 0 0 85
											set daquin(sor) 85	
											::console::affiche_resultat "  85 $val \n"
# 						   				}
# 						   					if { $val >= 0  } {
# 											#tel1 execute_command_x_s 0 26 1 0 0 83	
# 											set daquin(sor) 83
# 											::console::affiche_resultat "  83 $val \n"
# 						   				}
								  }

}
      # Initialisation de la monture Etel
      
      #Pour le centroid dans une boite draguee sur l'ecran :
      #-----------------------------------------------------
      #set res [buf$bufNo centro [::confVisu::getBox 1]]
      #298.55 384.53 0.65
      
      #Pour recuperer x et y :
      #-----------------------
      #set x [lindex $res 0]
      #set y [lindex $res 1]
      
      #---- j'utilise la visu numero 1 dasn tout ce qui suit
      set infos(visuNo) 1
      
      
      #--- je verifie que l'outil d'acquisition est ouvert
      set toolName [::confVisu::getTool $infos(visuNo)]
      if { $toolName != "acqfc" } {
         #--- j'ouvre l'outil d'acquisition s'il n'est pas ouvert
         ::confVisu::selectTool $infos(visuNo) "::acqfc"
      }
      
      # la variable box contient les coord. de la boite draguee
      set infos(box) [::confVisu::getBox $infos(visuNo)]
      console::disp "box=$infos(box) \n"
      
      #--- je change le nom et la focntion du bouton
      #.guid.but_valid configure -text "STOP" -command ::arreter
      .guid.but3 configure -text "FIN" -command ::arreter
      
      # --- position initiale
      # set res [buf1 centro $infos(box)]
      # set x0 [lindex $res 0]
      # set y0 [lindex $res 1]
      # set x0 160
      # set y0 120
      
      # je calcule le décallage sur l'instument guide pour obtenir le décallage de l'image
      #set n0 [expr $infos(decallage)*$infos(focale_guide)/$infos(focale_acq)]
      set n0 [expr $infos(decallage)*1]
      # je calcule la correction des rappels en fonction de la déclimaison (monture équatoriale)
      #set res1  [format "%5.2f" [lindex $paramaltaz(dec) 0]]
      #set p $infos(asc_droite)
      #		::console::disp  "$res1\n"
      #		set lar       [mc_angle2rad $res1 ]
      #		set cla       [expr cos($lar)]
      #set p [expr round($p/$cla) ]
      
      # je calcule la correction des rappels en fonction de la hauteur (monture azimutale)
# 		set now now
# 		catch {set now [::audace::date_sys2ut now]}
#       set res [mc_radec2altaz2 "$paramaltaz(ra1)" "$paramaltaz(dec1)" "$paramaltaz(home)" $now]
#       set az  [format "%5.2f" [lindex $res 0]]
#       set alt [format "%5.2f" [lindex $res 1] ]
      set p $infos(asc_droite)
# 		::console::disp  "$alt\n"
# 		set lar       [mc_angle2rad $alt ]
# 		set cla       [expr cos($lar)]
# 		set p [expr round($p/$cla) ]
		
      #::console::affiche_resultat "x0=$x0 y0=$y0"
      ::console::disp "autoguidage images au T400 Guidage T180 \n"
      ::console::disp "Focale_guide=$infos(focale_guide)  Focale_image=$infos(focale_acq)  Décallage=$n0 coef_ad=$p coef_dec=$infos(declinaison) tolérance=$infos(tolérance) \n"
      ::console::disp "x0=$infos(x0) y0=$infos(y0) n0=$n0 \n"
      ::console::disp "Temps_pose=$::panneau(acqfc,$infos(visuNo),pose)\n"
      puts $infos(ftraite) "Focale_guide;Focale_image;Décallage;coef_ad;coef_ad_corrigé;coef_dec;tolérance;objet_observé" 
      puts $infos(ftraite) "$infos(focale_guide);$infos(focale_acq);$n0;$infos(asc_droite);$p;$infos(declinaison);$infos(tolérance);$infos(objet)" 
      puts $infos(ftraite) "position initiale; x0=$infos(x0); y0=$infos(y0)" 
      #puts $infos(ftraite) "dx;dy;dp;dpp;dm;dmm" 
      # variables de décallage des poses
      
      # a nombre de poses lancées par le pc acq
      # b acteur de changement de sens
      # c valeur du prochain chagement de sens en alpha
      # d valeur duprochain changement de sens en delta
      # w valeur du bit combit 1.6 du pc autoguidage en debut de correction
      # w1 valeur du bit combit 1.6 du pc autoguidage en millieu de correction
      # w2 variable de changement d'état du bit combit 1.6 du pc autoguidage
      # u et v  valeurs n0  ou -n0 à ajouter à x0 et y0 pour décaller les poses entre chaque prise de vue.
      # n nombre de pixels de décallage du guidage en fonction de la focale de prise de vue,
      		#de la focale de guidage,et dunombre de pixels sur l'image finale
      # k1 variable d'arrêt du script si aucune pose d'acquisition n'est lancée au bout de 30 secondes
      # m coefficient multiplicateur de durées de rappel delta
      # m1 m2 m3 durée des rappels en delta
      # P coefficient multiplicateur de durées de rappel alpha
      	#en fonction de la déclinaison  la loi theorique est la suivante: de 0 (equateur) à 30° P=1 de 31 à 50 P=1.3 de 51 à 65 P=2
      	# de 66 à 75 p=3 de 76 à 81 P=6 de 82 à 84 P=8 de 85 à 87 P=15 88 et plus P=30
      # p1 p2 p3 durée des rappels en alpha
      # e demi tolérance de guidage
      # e1 e2 e3 demi tolérance des rappels
      # e1 = e * foc guid/foc acq/fact bining
      # infos(x1) abcisse de chaque pose
      # infos(y1) ordonnée de chaque pose
      
      # initialisation des variables
      set a 1
      set b 1
      set c 2
      set d 3
      set e $infos(tolérance)
      #set e1 [expr $infos(tolérance)*$infos(focale_guide)/$infos(focale_acq)/2.0]
      set e1 [expr $infos(tolérance)/2.0]
      set e2 [expr $e1*2]
      set e3 [expr $e1*3]
      set e4 [expr $e1*4]
      set u $n0
      set v -$n0
      set infos(x1) $infos(x0)
      set infos(y1) $infos(y0)
      set w 0
      set w1 0
      set k1 100000
      set m $infos(declinaison)
      set m1 [expr 5*$m]
      set m2 [expr 7*$m]
      set m3 [expr 9*$m]
      set m4 [expr 11*$m]
      
      set mm1 [expr 5*$m]
      set mm2 [expr 7*$m]
      set mm3 [expr 9*$m]
      set mm4 [expr 11*$m]
      
      #if {$infos(dec)<71}  {
      
      #}
      #attention de 0 à 70° c'est le nombre "$infos(dec)" qui est pris comme coefficient
      #if {70<$infos(dec)<81}  {
      #set p 3
      #}
      #if {80<$infos(dec)<84}  {
      #set p 4
      #}
      #if {83<$infos(dec)<87}  {
      #set p 6
      #}
      #if {86<$infos(dec)<89}  {
      #set p 12
      #}*******************$paramaltaz(dec)**************************** 
      
      
      
      set p1 [expr 6*$p]
      set p2 [expr 10*$p]
      set p3 [expr 14*$p]
      set p4 [expr 20*$p]
      set infos(dm) 0
      set infos(dp) 0
      set infos(dmm) 0
      set infos(dpp) 0
      set infos(dt) 0
      set pp1 [expr 6*$p]
      set pp2 [expr 10*$p]
      set pp3 [expr 14*$p]
      set pp4 [expr 20*$p]
      set saz 20
      puts $infos(ftraite) "$e1;$e2;$e3;$e4;$e1;$e2;$e3;$e4"
      puts $infos(ftraite) "$p1;$p2;$p3;$p4;$pp1;$pp2;$pp3;$pp4" 
      puts $infos(ftraite) "$m1;$m2;$m3;$m4;$mm1;$mm2;$mm3;$mm4" 
      puts $infos(ftraite) "dx;dy;rappel x(+);rappel x(-);rappel y(+);rappel y(-);duree pose;$infos(e5)" 
      
      ::console::disp  "base $p $m rappels$p1 $p2 $p3 $p4    $pp1 $pp2 $pp3 $pp4    $m1 $m2 $m3 $m4 $mm1 $mm2 $mm3 $mm4\n"
      ::console::disp " $e1;$e2;$e3;$e4;"
      
      ##########################
      # boucle d'autoguidage
      ##########################
      set cb 0
#       if {$infos(raz)==0}  {
#       	set sra1  20
#       	set sra2  30
#       }
#       if {$infos(raz)==1}  {
#       	set sra1  30
#       	set sra2  20
#       }
#       
#       if {$infos(rah)==0}  {
#       	set srh1  20
#       	set srh2	 30
#       }
#       if {$infos(rah)==1}  {
#       	set srh1  30
#       	set srh2  20
#       }
      #tel1 set_register_s 0 X 14 0 [expr abs($infos(raz))]
      
      #tel1 set_register_s 1 X 14 0 [expr abs($infos(rah))]
                ::etel_suivi_diurne
         set rot0 $paramaltaz(rotchamp)
     

      for {set k 1} {$k<100000 &&  $::infos(encours)==1 } {incr k} {
         # acq .3 2
       ::console::disp  "1 \n"
         ::etel_suivi_diurne
         set rot $paramaltaz(rotchamp)
         set drot [expr $rot-$rot0+$infos(rot_pos)]
     		set drot       [mc_angle2rad $drot ]
      	set crot       [expr cos($drot)]
      	set srot       [expr sin($drot)]
      	::console::disp  "2 \n"
         ::parraq
         set t0 [clock seconds]
         ::console::disp  "3 \n"
         acq $::panneau(acqfc,$infos(visuNo),pose) 2
         # sub n3 15
         #visu$audace(visuNo) disp [list 60 -4]
         #incrémentation compteur de boucles
         set cb [expr $cb+1]
			::console::disp  "4 \n"
         #creation d'une vitesse de rappel egale a la vitesse de suivi
     
       if {$infos(raz)==0}  {
       	set  sra1 $daquin(sor)
         set  sra2 $daquin(ser)
       }
       if {$infos(raz)==1}  {
       	set  sra2 $daquin(sor)
         set  sra1 $daquin(ser)
       }
       
       if {$infos(rah)==0}  {
       	set  srh1 $daquin(snr) 
         set  srh2 $daquin(ssr)
       }
       if {$infos(rah)==1}  {
       	set  srh2 $daquin(snr) 
         set  srh1 $daquin(ssr)
       }
#          set va  [tel1 get_register_s 0 X 13]
#          set va [expr $va-2]
#          if {$va < 100}  {
#          	set va 100 
#          }
#          tel1 set_register_s 0 X 14 0 [expr abs($va) ]
#          after 1000
#          set vh  [tel1 get_register_s 1 X 13]
#          set vh [expr $vh-2]
#       
#       	if {$vh< 100}  {
#       	set vh 100
#       	}
#          tel1 set_register_s 1 X 14 0 [expr abs($vh) ]
      
         # mesure de la variable d'état du bit 1 6
         set w "[combit $infos(portnum) 6]"
         set w2 [expr $w1-$w]
         #  0-0=0 rien......0-1=-1debut de pose ....1-1=0 pose.....1-0=1 fin de pose
         
         # Incrémentation du compteur de pose et décallage de la pose
         if {$w2==1}  {
            set a [expr $a+1]
            set k1 $k
            set infos(x1) [expr $infos(x1)+$u]
            set infos(y1) [expr $infos(y1)+$v]
            ::console::affiche_resultat "infos(x1)=$infos(x1) infos(y1)=$infos(y1)"
            puts $infos(ftraite) "$a;x1=$infos(x1); y1=$infos(y1)"
            #::console::disp "infos(x1)=$infos(x1) infos(y1)=$infos(y1) =$u  v=$v "
            set infos(dt) -10
            #compteur de boucle
            set cb -10
         }
         # procédure d'arrêt  au bout  de 30 secondes sans nouvelle pose
      
         if {$w2==-1}  {
            set k1 100000
            set infos(fin) 1
            set infos(dt) 0
         }
         
         if {[expr $k-$k1]>80}  {
            set k  100000
         }
         # Calcul des nouvelles positions des poses en spirale ( illimité)
         
         if {$a==$c}  {
            set u -$u
            set  c [expr $c+2*$b]
         }
         if {$a==$d}  {
            set v -$v
            set  d [expr $d+2*$b+1]
            set b [expr $b+1]
         }
      
         set bufNo [::confVisu::getBufNo $infos(visuNo) ]
         set res [buf$bufNo centro $infos(box)]
         set x [lindex $res 0]
         set y [lindex $res 1]
         set dx [expr $x-$infos(x1)]
         set dy [expr $y-$infos(y1)]
         set du $dx
         set dt $dy
   
         #correction rotation de champ
                  if { $paramaltaz(rac)  == 0} {
	                  set cosx [expr $dx*$crot]
	                  set sinx [expr $dx*$srot]
	                  set cosy [expr $dy*$crot]
	                  set siny [expr $dy*$srot]
	                  set dx [expr -$siny+$cosx]
	                  set dy [expr $cosy+$sinx]
	      ::console::affiche_resultat "dxccd=$du dxtel=$dx dyccd=$dt dytel=$dy  "  
	               	 	} 
	   
         set dx [format "%5.2f" $dx ]
         set dy [format "%5.2f" $dy ]
         
         
         # j'enregistre le resultat dans le fichier de sortie
         set infos(dx) [expr $x-$infos(x1)]
         set infos(dy) [expr $y-$infos(y1)]
         set infos(dx) [format "%5.2f" $infos(dx)]
         set infos(dy) [format "%5.2f" $infos(dy)]
         if { $dx > $infos(e5) } {
            set dx 0
            set dy 0
            set infos(dm) 0
            set infos(dp) 0
            set infos(dmm) 0
            set infos(dpp) 0
            #::console::disp  "$p4  \n"
         }

         if { $dy > $infos(e5) } {
         	set dx 0
            set dy 0
            set infos(dm) 0
            set infos(dp) 0
            set infos(dmm) 0
            set infos(dpp) 0
            #::console::disp  "$p4  \n"
         }
         
         if { $dx == 0 } {
            set infos(dp) 0
            set infos(dpp) 0
         }
         if { $dy == 0 } {
            set infos(dm) 0
            set infos(dmm) 0
         }
         
         if { $dx > 0 } {
            if { $dx < $e1 } {
               set infos(dp) 0
               set infos(dpp) 0
               set dx 0
            }
            if { $dx > $e4 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra1	           
               after $p4
           		#tel1 execute_command_x_s 0 26 1 0 0 70
           		::etel_suivi_diurne
               set infos(dp) $p4
               set infos(dpp) 0
            	set dx 0
               #::console::disp  "$p4  \n"
            }
         
            if { $dx > $e3 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra1	           
               after $p3
           		#tel1 execute_command_x_s 0 26 1 0 0 70
           		::etel_suivi_diurne
         	   set dx 0
               #::console::disp  " $p3  \n"
               set infos(dp) $p3
               set infos(dpp) 0
            }
         
            if { $dx > $e2 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra1	           
               after $p2
           		#tel1 execute_command_x_s 0 26 1 0 0 70
           		::etel_suivi_diurne
            	set dx 0
               #::console::disp  " $p2 \n"
               set infos(dp) $p2
               set infos(dpp) 0
            }
         
            if { $dx > $e1 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra1	           
               after $p1
           		#tel1 execute_command_x_s 0 26 1 0 0 70
           		::etel_suivi_diurne
               #::console::disp  " $p1 \n"
               set dx 0
               set infos(dp) $p1
               set infos(dpp) 0
            }
         
         }
      
         if { $dy > 0 } {
            if { $dy < $e1 } {
               set infos(dm) 0
               set infos(dmm) 0
               set dy 0
            }
         	
            if { $dy > $e4 } {
         	   tel1 execute_command_x_s 1 26 1 0 0 $srh1           
               after $m4
           		#tel1 execute_command_x_s 1 26 1 0 0 70
           		::etel_suivi_diurne
            	set dy 0
               #::console::disp  " $m4 \n"
               set infos(dm) $m4
               set infos(dmm) 0
            }
         
            if { $dy > $e3 } {
               tel1 execute_command_x_s 1 26 1 0 0 $srh1          
               after $m3
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
            	set dy 0
               #::console::disp  "  $m3 \n"
               set infos(dm) $m3
               set infos(dmm) 0
            }
         
            if { $dy > $e2 } {
               tel1 execute_command_x_s 1 26 1 0 0 $srh1          
               after $m2
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
               set dy 0
               #::console::disp  "  $m2 \n"
               set infos(dm) $m2
               set infos(dmm) 0
            }
            
            if { $dy > $e1 } {
               tel1 execute_command_x_s 1 26 1 0 0 $srh1          
               after $m1
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
               #::console::disp  "  $m1 \n"
               set infos(dm) $m1
               set dy 0
               set infos(dmm) 0
            }
         
         }
         
         # mesure de la variable d'état du bit 1 6 a mi rappel
         set w1 "[combit $infos(portnum) 6]"
         set w2 [expr $w-$w1]
         #  0-0=0 rien......0-1=-1debut de pose ....1-1=0 pose.....1-0=1 fin de pose
      
         # Incrémentation du compteur de pose et décallage de la pose
         if {$w2==1}  {
            set a [expr $a+1]
            set k1 $k
            set infos(x1) [expr $infos(x1)+$u]
            set infos(y1) [expr $infos(y1)+$v]
            ::console::affiche_resultat "infos(x1)=$infos(x1) infos(y1)=$infos(y1)"
            puts $infos(ftraite) "$a;x1=$infos(x1); y1=$infos(y1)"
            #::console::disp "infos(x1)=$infos(x1) infos(y1)=$infos(y1) u=$u  v=$v "
            set infos(dx) [expr $x-$infos(x1)]
            set infos(dy) [expr $y-$infos(y1)]
            set infos(dx) [format "%5.2f" $infos(dx)]
            set infos(dy) [format "%5.2f" $infos(dy)]
            set infos(dt) -10
            #compteur de boucle
            set cb -10
         }
         
         # procédure d'arrêt  au bout  de 30 secondes sans nouvelle pose
         if {$w2==-1}  {
            set k1 100000
            set infos(fin) 1
            set infos(dt) 0
         }
      
         if {[expr $k-$k1]>80}  {
            set k  100000
         }
         # Calcul des nouvelles positions des poses en spirale ( illimité)
      
         if {$a==$c}  {
            set u -$u
            set  c [expr $c+2*$b]
         }
         
         if {$a==$d}  {
            set v -$v
            set  d [expr $d+2*$b+1]
            set b [expr $b+1]
         }
      
         if { -$dx > $infos(e5) } {
            set dx 0
            #set dy 0
            #::console::disp  "$p4  \n"
            set infos(dm) 0
            set infos(dp) 0
            set infos(dmm) 0
            set infos(dpp) 0
         }
         
         if { -$dy > $infos(e5) } {
            set dx 0
            set dy 0
            #::console::disp  "$p4  \n"
            set infos(dm) 0
            set infos(dp) 0
            set infos(dmm) 0
            set infos(dpp) 0
         }
         
         if { $dx != "0"} {
         	
         	if { -$dx < $e1 } {
               set infos(dp) 0
               set infos(dpp) 0
               set dx 0
            }
            if { -$dx > $e4 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra2           
               after $pp4
           		#tel1 execute_command_x_s 0 26 1 0 0 70
           		::etel_suivi_diurne
               set dx 0
               #::console::disp  " $pp4  \n"
               set infos(dpp) $pp4
               set infos(dp) 0
            }
         
            if { -$dx > $e3 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra2           
               after $pp3
           		#tel1 execute_command_x_s 0 26 1 0 0 70
           		::etel_suivi_diurne
            	set dx 0
               #::console::disp  "  $pp3 \n"
               set infos(dpp) $pp3
               set infos(dp) 0
            }
         
            if { -$dx > $e2 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra2       
               after $pp2
              	#tel1 execute_command_x_s 0 26 1 0 0 70
              	::etel_suivi_diurne
            	set dx 0
               #::console::disp  "  $pp2   \n"
               set infos(dpp) $pp2
               set infos(dp) 0
            }
         
            if { -$dx > $e1 } {
               tel1 execute_command_x_s 0 26 1 0 0 $sra2
               ::etel_suivi_diurne	           
               after $pp1
               #tel1 execute_command_x_s 0 26 1 0 0 70
               ::etel_suivi_diurne
               #::console::disp  "  $pp1 \n"
               set dx 0
               set infos(dpp) $pp1
               set infos(dp) 0
            }
         
         }
      
         if { $dy != "0" } {
            
      		if { -$dy < $e1 } {
               set infos(dm) 0
               set infos(dmm) 0
               set dy 0
            }
            if { -$dy > $e4 } {
      		   tel1 execute_command_x_s 1 26 1 0 0 $srh2           
               after $mm4
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
               set dy 0
               #::console::disp  " $m4 \n"
               set infos(dmm) $mm4
               set infos(dm) 0
            }
      
            if { -$dy > $e3 } {
               tel1 execute_command_x_s 1 26 1 0 0 $srh2          
               after $mm3
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
               set dy 0
               #::console::disp  " $m3 \n"
               set infos(dmm) $mm3
               set infos(dm) 0
            }
      
            if { -$dy > $e2 } {
               tel1 execute_command_x_s 1 26 1 0 0 $srh2           
               after $mm2
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
               set dy 0
               #::console::disp  "  $m2 \n"
               set infos(dmm) $mm2
               set infos(dm) 0
            }
      
            if { -$dy > $e1 } {
               tel1 execute_command_x_s 1 26 1 0 0 $srh2         
               after $mm1
               #tel1 execute_command_x_s 1 26 1 0 0 70
               ::etel_suivi_diurne
               #::console::disp  " $m1 \n"
               set infos(dmm) $mm1
               set infos(dm) 0
               set dy 0
            }
      
         }
         
         set paramaltaz(max)  0
         if {$infos(sortie) == 0 } {
            
            ::console::affiche_resultat "e"
            set dt [expr [clock seconds]-$t0]
            set dt [format "%5.2f" $dt]
            set infos(dt) [expr $infos(dt)+ $dt]
            ::console::affiche_resultat "dx=$infos(dx) dy=$infos(dy)  ...$infos(dp) ...$infos(dpp) ...$infos(dm) ...$infos(dmm)...$infos(dt) $paramaltaz(va) $paramaltaz(vh) $paramaltaz(vc) \n"
            
            if {$infos(fich) == 1  } {
               puts $infos(ftraite) "$infos(dx);$infos(dy);$infos(dp);$infos(dpp);$infos(dm);$infos(dmm);$infos(dt)"
            }
            if { $cb == 30 } {
               catch {exec espeak.exe -v fr "pose $a  $infos(dt) segondes"}
            } 
            if { $cb == 60 } {
               catch {exec espeak.exe -v fr "pose $a   $infos(dt) segondes"}
            }
            if { $cb == 90 } {
               catch {exec espeak.exe -v fr "pose $a   $infos(dt) segondes"}
            }
            if { $cb == 120 } {
               catch {exec espeak.exe -v fr "pose $a   $infos(dt) segondes"}
            }
            if { $cb == 150 } {
               catch {exec espeak.exe -v fr "pose $a   $infos(dt) segondes"}
            }
            if { $cb == 180 } {
               catch {exec espeak.exe -v fr "pose $a   $infos(dt) segondes"}
            }
      
         }
      	#--- fin de la condition raquette
      	
      } ; #--- fin de la boucle for
   
      if {$infos(fin) ==1 } {
         ::console::affiche_resultat "d"
         if {$infos(stop) ==1 } {
            ::stopmot
         }
         ::arreter
         set k  100000
         #::fermerTout
         ::console::affiche_resultat "d"
      }
   }
   
   #################################################################################
   #### proc raquette
   #################################################################################
   proc raquettea { } {
      global conf
      global caption
      global color
      global infos
      global paramaltaz
      global audace
      ::console::affiche_resultat "1"
      set ::infos(encours) "0"
      
      tel1 execute_command_x_s 0 0 0
      after 250
      tel1 execute_command_x_s ! 26 1 0 0 79 
      after 250
      tel1 execute_command_x_s 0 26 1 0 0 70
      after 250
      tel1 execute_command_x_s 1 26 1 0 0 7
      catch {exec espeak.exe -v fr "raquette guidon active "}
      #pierre ajout boucle d'attente
      # boucle d'attente observateur a reutiliser avec raquette hard
      ::console::affiche_resultat "2"
      set w 0
      
      for {set u 1} {$u<100000} {incr u} {
         # mesure de la variable d'état du bit 1 9
         set w "[combit 1 9]"
         # acq $::panneau(acqfc,$infos(visuNo),pose) 1
         after 500
         set w 0
         set w "[combit 1 9]"
         ::console::affiche_resultat "3"
         if {$w == 1 }  {
            set u  100000
            bell
            bell
            bell
         }
         ::console::affiche_resultat "boucle attente"
      }
   
      acq $::panneau(acqfc,$infos(visuNo),pose) 1
      set bufNo [::confVisu::getBufNo $infos(visuNo) ]
      set res [buf$bufNo centro $infos(box)]
      ::console::affiche_resultat "acquisition"
      set infos(x1) [lindex $res 0]
      set infos(y1) [lindex $res 1]
      set infos(x0) [lindex $res 0]
      set infos(y0) [lindex $res 1]
      puts $infos(ftraite) "$infos(x1);$infos(y1)"
      catch {exec espeak.exe -v fr "sortie raquette guide"}
      ::console::affiche_resultat "enregistrement fichier"
      set ::infos(encours) "1"
      ::console::affiche_resultat "sortie raquette"
      
   }
   
   #################################################################################
   #### proc Mise a jour données
   #################################################################################
   proc action { } {
      global caption
      global base
      global infos
      global audace
      global paramaltaz
      set ::infos(encours) "0" 
      puts $infos(ftraite) "$infos(dx);$infos(dy);$infos(e5)"
      .guid.but3 configure -text "RELANCER" -command ::autoguider
   }
   
   #################################################################################
   #### proc Rotation du porte occulaire
   #################################################################################
   proc rot_port_occ { } {
      global caption
      global base
      global infos
      global audace
      global paramaltaz
      catch {exec espeak.exe -v fr "le porte occulaire va tourner attention aux câbles"}
      tel1 execute_command_x_s 2 26 1 0 0 77
      after 2000
      set rotini [tel1 get_register_s 2 M 7]
		set rotmulth [tel1 get_register_s 2 X 28]
		set rotmultah [tel1 get_register_s 2 X 29]
				if {$infos(rot_poc) > 0 } {
           	set rotmove  [expr $infos(rot_poc)*$rotmulth]
           	
         	}
	         	if {$infos(rot_poc) < 0 } {
	           	set rotmove  [expr $infos(rot_poc)*$rotmultah]
	         	}
	   set infos(rot_pos) [expr $infos(rot_pos)+ $infos(rot_poc)]
		   if {$infos(rot_pos) < 0 } {
		           	set infos(rot_pos)  [expr 360 + $infos(rot_pos)]
		         	}
	   set rotfin [expr $rotini+$rotmove]
		tel1 set_register_s 2 X 21 0 [expr abs($rotfin) ]
		tel1 execute_command_x_s  2 26 1 0 0 73
		after 10000
		::console::affiche_resultat "$infos(rot_pos),  $rotini,   $rotfin /n"
		catch {exec espeak.exe -v fr "ça y est c'est tout enmêlé"}
			
      #puts $infos(ftraite) "$infos(dx);$infos(dy);$infos(e5)"
      .guid.but3 configure -text "RELANCER" -command ::autoguider
   }
   
   #################################################################################
   #### proc fermer fichier
   #################################################################################
   proc fermefich { } {
      global caption
      global base
      global infos
      global audace
      global paramaltaz
      close $infos(ftraite)
      set ::infos(encours) "0"
      set ::infos(fich) "0"
   }
   #################################################################################
   #### proc stop moteurs
   #################################################################################
   proc stopmot { } {
      global caption
      global base
      global infos
      global audace
      global paramaltaz
      tel1 execute_command_x_s  0 124 1 0 0 0
      after 1000
      tel1 execute_command_x_s  1 124 1 0 0 0
   }
   
   #################################################################################
   #### proc fermerTout
   #### cette procedure ferme le port serie et la fenetre
   #################################################################################
   proc fermerTout { } {	
      #--- je ferme le port serie s'il est encore ouvert
      if { $::infos(portHandle) != "" } {
         close $::infos(portHandle)
      }
      set ::infos(portHandle) ""
      set ::infos(encours) "0"
      #--- je ferme la fenetre
      destroy .guid
      set infos(fin) 0
   }
   
   
   #################################################################################
   #### proc arreter
   #### cette procedure arrete la boucle principale
   #################################################################################
   proc arreter { } {
   	global caption
   	global base
   	global infos
   	global audace
      global paramaltaz
      set ::infos(encours) "0"
      set infos(sortie) 1
      ::console::affiche_resultat "a"
      after 1000
      ::fermefich 
      ::console::affiche_resultat "b"
      ::fermerTout
      ::console::affiche_resultat "c"
      set paramaltaz(sortie) "0"
   }
   
   
   #################################################################################
   #################################################################################
   #### Fenêtre d'autoguidage
   #################################################################################
   #################################################################################
   
   #--- Cree la fenetre .guid de niveau le plus haut
   if [ winfo exists .guid ] {
      wm withdraw .guid
      wm deiconify .guid
      focus .guid
      return
   }
   toplevel .guid -class Toplevel -bg $color(back)
   wm geometry .guid 300x520+240+190
   wm title .guid $caption(guid_titre)
   
   #--- La nouvelle fenetre est active
   focus .guid
   
   #--- Cree un frame en haut a gauche pour les canvas d'affichage
   frame .guid.frame0 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame0 \
      -in .guid -anchor nw -side top -expand 0 -fill x
   
      #--- Cree le label 'titre'
      label .guid.frame0.lab \
         -text "$caption(guid_comment)" -bg $color(back) -fg $color(text)
      pack .guid.frame0.lab \
         -in .guid.frame0 -side top -anchor center \
         -padx 3 -pady 3
         
   #--- Cree un frame en haut a gauche pour les canvas d'affichage
   frame .guid.frame1 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame1 \
      -in .guid -anchor nw -side top -expand 0 -fill x
   
      #--- Cree le label 'titre'
      label .guid.frame1.lab \
         -text "$caption(guid_comment1)" -bg $color(back) -fg $color(text)
      pack .guid.frame1.lab \
         -in .guid.frame1 -side top -anchor center \
         -padx 3 -pady 3
   
   #--- Cree un frame
   frame .guid.frame2 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame2 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame2.lab \
         -text "$caption(guid_fonc_decallage_images)" -bg $color(back) -fg $color(text)
      pack .guid.frame2.lab \
         -in .guid.frame2 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame2.ent \
         -textvariable infos(decallage) -width 10
      pack .guid.frame2.ent \
         -in .guid.frame2 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .guid.frame3 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame3 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame3.lab \
         -text "$caption(guid_focale_guide)" -bg $color(back) -fg $color(text)
      pack .guid.frame3.lab \
         -in .guid.frame3 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame3.ent \
         -textvariable infos(rot_poc) -width 10
      pack .guid.frame3.ent \
         -in .guid.frame3 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .guid.frame4 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame4 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame4.lab \
         -text "$caption(guid_focale_imagerie)" -bg $color(back) -fg $color(text)
      pack .guid.frame4.lab \
         -in .guid.frame4 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame4.ent \
         -textvariable infos(focale_acq) -width 10
      pack .guid.frame4.ent \
         -in .guid.frame4 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .guid.frame5 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame5 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame5.lab \
         -text "$caption(guid_distance_equateur)" -bg $color(back) -fg $color(text)
      pack .guid.frame5.lab \
         -in .guid.frame5 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame5.ent \
         -textvariable infos(asc_droite) -width 10
      pack .guid.frame5.ent \
         -in .guid.frame5 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .guid.frame6 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame6 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame6.lab \
         -text "$caption(guid_rappels_delta)" -bg $color(back) -fg $color(text)
      pack .guid.frame6.lab \
         -in .guid.frame6 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame6.ent \
         -textvariable infos(declinaison) -width 10
      pack .guid.frame6.ent \
         -in .guid.frame6 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .guid.frame7 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame7 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame7.lab \
         -text "$caption(guid_fonc_tolérance)" -bg $color(back) -fg $color(text)
      pack .guid.frame7.lab \
         -in .guid.frame7 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame7.ent \
         -textvariable infos(tolérance) -width 10
      pack .guid.frame7.ent \
         -in .guid.frame7 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
   #--- Cree un frame
   frame .guid.frame8 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame8 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame8.lab \
         -text "$caption(guid_pos_init_x)" -bg $color(back) -fg $color(text)
      pack .guid.frame8.lab \
         -in .guid.frame8 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame8.ent \
         -textvariable infos(x0) -width 10
      pack .guid.frame8.ent \
         -in .guid.frame8 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
   #--- Cree un frame
   frame .guid.frame9 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame9 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame9.lab \
         -text "$caption(guid_pos_init_y)" -bg $color(back) -fg $color(text)
      pack .guid.frame9.lab \
         -in .guid.frame9 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame9.ent \
         -textvariable infos(y0) -width 10
      pack .guid.frame9.ent \
         -in .guid.frame9 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
   #--- Cree un frame
   frame .guid.frame10 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame10 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame10.lab \
         -text "rayon d'action" -bg $color(back) -fg $color(text)
      pack .guid.frame10.lab \
         -in .guid.frame10 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame10.ent \
         -textvariable infos(e5) -width 10
      pack .guid.frame10.ent \
         -in .guid.frame10 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- Cree un frame
   frame .guid.frame11 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame11 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame11.lab \
         -text "arret moteurs après dernière pose" -bg $color(back) -fg $color(text)
      pack .guid.frame11.lab \
         -in .guid.frame11 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame11.ent \
         -textvariable infos(stop) -width 10
      pack .guid.frame11.ent \
         -in .guid.frame11 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
         #--- Cree un frame
   frame .guid.frame12 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame12 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame12.lab \
         -text "OBJET OBSERVE" -bg $color(back) -fg $color(text)
      pack .guid.frame12.lab \
         -in .guid.frame12 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame12.ent \
         -textvariable infos(objet) -width 10
      pack .guid.frame12.ent \
         -in .guid.frame12 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
               #--- Cree un frame
   frame .guid.frame13 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame13 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame13.lab \
         -text "SENS RAPPELS AZIMUT 0 ou 1" -bg $color(back) -fg $color(text)
      pack .guid.frame13.lab \
         -in .guid.frame13 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame13.ent \
         -textvariable infos(raz) -width 10
      pack .guid.frame13.ent \
         -in .guid.frame13 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
               #--- Cree un frame
   frame .guid.frame14 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame14 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame14.lab \
         -text "SENS RAPPELS HAUTEUR 0 ou 1" -bg $color(back) -fg $color(text)
      pack .guid.frame14.lab \
         -in .guid.frame14 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame14.ent \
         -textvariable infos(rah) -width 10
      pack .guid.frame14.ent \
         -in .guid.frame14 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
         
               #--- Cree un frame
   frame .guid.frame15 \
      -borderwidth 0 -cursor arrow -bg $color(back)
   pack .guid.frame15 \
      -in .guid -anchor center -side top -expand 0 -fill x
   
      #--- Cree le label
      label .guid.frame15.lab \
         -text "ARRET ROTATION CHAMP 0 rotation 1 pasde rotation " -bg $color(back) -fg $color(text)
      pack .guid.frame15.lab \
         -in .guid.frame15 -side left -anchor center \
         -padx 3 -pady 3
   
      #--- Cree l'entry
      entry .guid.frame15.ent \
         -textvariable paramaltaz(rac) -width 10
      pack .guid.frame15.ent \
         -in .guid.frame15 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
   
   #--- button position a la raquette    
    button .guid.but1 -text "position raquette " -command  {raquettea}
   	pack .guid.but1 -ipadx 5 -ipady 2  
   
   #--- button Rayon d'action   
    button .guid.but2 -text "MODIF DONNEES" -command  {action}
   	pack .guid.but2 -ipadx 5 -ipady 2  
   	
   #--- button executer
   button .guid.but3 -text "$caption(guid_fonc_executer)" -command {autoguider }
      pack .guid.but3 -ipadx 5 -ipady 2
      
   #--- button tourner le porte occulaire
   button .guid.but4 -text "tourner le porte occulaire" -command {rot_port_occ }
      pack .guid.but4 -ipadx 5 -ipady 2
   
   #--- Detruit la fenetre avec la croix en haut a droite
   bind .guid <Destroy> {
      fermerTout
   }
   
   #--- j'ouvre le port serie
   #set ::infos(portnum) 1
   #set portName "COM$infos(portnum)"
   #set ::infos(portHandle) [open $portName "RDWR"]
   #fconfigure $::infos(portHandle) -mode "9600,n,8,1" -buffering none -blocking 0
   	
   combit $infos(portnum) 3 0
   combit $infos(portnum) 4 0
   combit $infos(portnum) 7 0
   
   ###########################
   ##-------procedure autoguidage fin
   ###############################
}

#******init_monture
#################################################################################
#### proc raqsoft => obsolete
#################################################################################
proc raqsoft { } {

	global caption
	global base
	global paramaltaz
	if { $paramaltaz(raq) != "1" } {
		set now now
		catch {set now [::audace::date_sys2ut now]}
		set tu [mc_date2ymdhms $now ]
		set h [format "%02d" [lindex $tu 3]]
		set m [format "%02d" [lindex $tu 4]]
		set s [format "%02d" [expr int(floor([lindex $tu 5]))]]
		$base.f.lab_tu configure -text "$caption(horloge_astro,tu) ${h}h ${m}mn ${s}s"
		set tsl [mc_date2lst $now $paramaltaz(home)]
		set h [format "%2d" [lindex $tsl 0]]
		set m [format "%2d" [lindex $tsl 1]]
		set s [format "%2d" [expr int(floor([lindex $tsl 2]))]]
		$base.f.lab_tsl configure -text "$caption(horloge_astro,tsl) ${h}h ${m}mn ${s}s"
		#****recuperation temps sideral heures et minutes
		set paramaltaz(hts) $h
		set paramaltaz(mts) $m 
		
		set paramaltaz(ra1) "[ lindex $paramaltaz(ra) 0 ]h[ lindex $paramaltaz(ra) 1 ]m[ lindex $paramaltaz(ra) 2 ]"
		set paramaltaz(dec1) "[ lindex $paramaltaz(dec) 0 ]d[ lindex $paramaltaz(dec) 1 ]m[ lindex $paramaltaz(dec) 2 ]"
		set res [mc_radec2altaz2 "$paramaltaz(ra1)" "$paramaltaz(dec1)" "$paramaltaz(home)" $now]
		set az  [format "%5.2f" [lindex $res 0]]
		set alt [format "%5.2f" [lindex $res 1] ]
		set ha  [lindex $res 2]
		set res [mc_angle2hms $ha]
		set h [format "%02d" [lindex $res 0]]
		set m [format "%02d" [lindex $res 1]]
		set s [format "%02d" [expr int(floor([lindex $res 2]))]]
		$base.f.lab_ha configure -text "$caption(horloge_astro,angle_horaire) ${h}h ${m}mn ${s}s"
		$base.f.lab_altaz configure -text "$caption(horloge_astro,azimut) ${az}° - $caption(horloge_astro,hauteur) ${alt}°"
		
		#calcul des coordonnées angulaires
		set paramaltaz(radeg) [expr [lindex $paramaltaz(ra) 0 ]*15 +[ lindex $paramaltaz(ra) 1 ]/4+[ lindex $paramaltaz(ra) 2 ]/240]
		set dda [format "%2.3f" [expr [lindex $paramaltaz(dec) 0]  * 3600]]
		set dma [format "%2.3f" [expr [lindex $paramaltaz(dec) 1]  * 60]]
		set dsa [format "%2.3f" [lindex $paramaltaz(dec) 2] ]
		set paramaltaz(decdeg) [expr [expr $dda + $dma  + $dsa] / 3600]
		if {$dda < 0 } {
			set paramaltaz(decdeg) [expr [expr $dda - $dma  - $dsa] / 3600]
		}
		set n "[combit 1 1]"
		if {$n == 1 }  {
			set n 0
			after 500
			set n "[combit 1 1]"
			if {$n == 1 }  {
			::shiftn
		}
		}
		set e "[combit 1 8]"
		after 100
		set o "[combit 1 6]"
		set s [expr $o+$e]
		if {$s == 2 }  {
			::shifts
		}
		if { $s != "2" } {
			if {$e == 1 }  {
				::shifte
			}
			if {$o == 1 }  {
				::shifto
			}
		}
		# mesure de la variable d'état du bit 1 9
		set w "[combit 1 9]"
		after 500
			if {$w == 1 }  {
			set w 0
			after 500
			set w "[combit 1 9]"
			if {$w == 1 }  {
			set paramaltaz(raq) 1
			}
		}
		::raqsoft
	}
	set paramaltaz(raq) 0
}

::console::affiche_resultat "   initialisation \n"
#---
#::calcul
#::etel_grande_boucle
if {1==1} {
   #--- Create a toplevel window
   set posinibase .posini
   catch { destroy $posinibase}
   toplevel $posinibase -class Toplevel
   wm geometry $posinibase 700x220+100+200
   wm focusmodel $posinibase passive
   wm resizable $posinibase 0 0
   wm deiconify $posinibase
   wm title $posinibase "Alignement initial du T940"
   wm protocol $posinibase WM_DELETE_WINDOW { }
   #bind $base <Destroy> { destroy .posini }
   $posinibase configure -bg #FF0000
   wm withdraw .
   focus -force $posinibase
   
   #--- Cree le label
   set texte ""
   append texte "Placer le télescope au méridien et à la déclinaison -40°.\n\n"
   append texte "Cela revient à aligner le petit laser sur la croix dessinée au mur.\n\n"
   append texte "A la fin, appuyer physiquement sur le bouton en haut au milieu de raquette\n"
   append texte "puis sur le bouton \"OUI j'ai terminé l'alignement du télescope\".\n" 
   label $posinibase.lab1 \
      -text $texte -fg #FFFFFF -font [ list {Arial} 14 bold ] -bg #FF0000
   pack $posinibase.lab1 \
      -in $posinibase -side top -anchor center -padx 3 -pady 3
      
   #--- Cree un frame
   frame $posinibase.fra \
      -borderwidth 0 -cursor arrow -bg #FF0000
   pack $posinibase.fra \
      -in $posinibase -anchor center -side top -expand 0 -fill x
   
   #--- Cree le bouton 'Validation'
   button $posinibase.fra.but1 \
      -text "OUI j'ai terminé l'alignement du télescope" -borderwidth 4 \
      -command { }
   pack $posinibase.fra.but1 \
      -in $posinibase.fra -side right -anchor center \
      -padx 30 -pady 3
   #--- Cree le bouton 'Abandon'
   button $posinibase.fra.but2 \
      -text "NON je n'y arrive pas" -borderwidth 4 \
      -command { exit }
   pack $posinibase.fra.but2 \
      -in $posinibase.fra -side left -anchor center \
      -padx 30 -pady 3
   update   
}
::console::affiche_resultat "   posini \n"
::posini


#------------------------------------------------------------
#  createDialog
#     creation de l'interface graphique
#------------------------------------------------------------
proc createDialog { } {
   
   variable This
   set
   global audace
   global conf
   global caption
   

   if { [ winfo exists $This ] } {
      destroy $This
   }

   #--- Cree la fenetre $This de niveau le plus haut 
   toplevel $This -class Toplevel
   wm title $This $caption(telpad,titre)
   if { [ info exists conf(telpad,wmgeometry) ] == "1" } {
      wm geometry $This $conf(telpad,wmgeometry)
   } else {
      wm geometry $This 157x221+657+252
   }
   wm resizable $This 1 1
   wm protocol $This WM_DELETE_WINDOW ::telpad::fermer

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame2 -borderwidth 1 -relief groove
   pack $This.frame2 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame3 -borderwidth 1 -relief groove
   pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame4 -borderwidth 1 -relief groove
   pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

   #--- Label pour RA
   label $This.frame2.ent1 -font [ list {Arial} 10 bold ] -textvariable audace(telescope,getra)
   pack $This.frame2.ent1 -in $This.frame2 -anchor center -fill none -pady 1

   #--- Label pour DEC
   label $This.frame2.ent2 -font [ list {Arial} 10 bold ] -textvariable audace(telescope,getdec)
   pack $This.frame2.ent2 -in $This.frame2 -anchor center -fill none -pady 1

   set zone(radec) $This.frame2
   bind $zone(radec) <ButtonPress-1>      { ::telescope::afficheCoord }
   bind $zone(radec).ent1 <ButtonPress-1> { ::telescope::afficheCoord }
   bind $zone(radec).ent2 <ButtonPress-1> { ::telescope::afficheCoord }

   #--- Frame des boutons manuels
   #--- Create the button 'N'
   frame $This.frame3.n \
      -width 27 -borderwidth 0 -relief flat
   pack $This.frame3.n \
      -in $This.frame3 -side top -fill x

   #--- Button-design
   canvas $This.frame3.n.canv1 \
      -width 27 -height 27 \
      -borderwidth 0 -relief flat -bg $audace(color,backColor) \
      -highlightbackground $audace(color,backColor)
   $This.frame3.n.canv1 create line 3 3 3 25 25 25 25 3 3 3  \
      -fill $audace(color,entryTextColor) -width 3
   pack $This.frame3.n.canv1 \
      -in $This.frame3.n -expand 1

   #--- Write the label
   label $This.frame3.n.canv1.lab \
      -font [ list {Arial} 10 bold ] -text "$caption(telpad,nord)" \
      -borderwidth 0 -relief flat
   place $This.frame3.n.canv1.lab \
      -in $This.frame3.n.canv1 -x 9 -y 6

   #--- Create the buttons 'W E'
   frame $This.frame3.we \
      -width 27 \
      -borderwidth 0 -relief flat
   pack $This.frame3.we \
      -in $This.frame3 -side top -fill x

   #--- Button-design
   canvas $This.frame3.we.canv1 \
      -width 27 -height 27 \
      -borderwidth 0 -relief flat -bg $audace(color,backColor) \
      -highlightbackground $audace(color,backColor)
   $This.frame3.we.canv1 create line 3 3 3 25 25 25 25 3 3 3  \
      -fill $audace(color,entryTextColor) -width 3
   pack $This.frame3.we.canv1 \
      -in $This.frame3.we -expand 1 -side left

   #--- Write the label
   label $This.frame3.we.canv1.lab \
      -font [ list {Arial} 10 bold ] -text "$caption(telpad,est)" \
      -borderwidth 0 -relief flat
   place $This.frame3.we.canv1.lab \
      -in $This.frame3.we.canv1 -x 9 -y 6

   #--- Write the label of speed
   label $This.frame3.we.lab \
      -font [ list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
      -borderwidth 0 -relief flat
   pack $This.frame3.we.lab \
      -in $This.frame3.we -expand 1 -side left

   #--- Button-design
   canvas $This.frame3.we.canv2 \
      -width 27 -height 27 \
      -borderwidth 0 -relief flat -bg $audace(color,backColor) \
      -highlightbackground $audace(color,backColor)
   $This.frame3.we.canv2 create line 3 3 3 25 25 25 25 3 3 3  \
      -fill $audace(color,entryTextColor) -width 3
   pack $This.frame3.we.canv2 \
      -in $This.frame3.we -expand 1 -side right

   #--- Write the label
   label $This.frame3.we.canv2.lab \
      -font [ list {Arial} 10 bold ] -text "$caption(telpad,ouest)" \
      -borderwidth 0 -relief flat
   place $This.frame3.we.canv2.lab \
      -in $This.frame3.we.canv2 -x 7 -y 6

   #--- Create the button 'S'
   frame $This.frame3.s \
      -width 27 \
      -borderwidth 0 -relief flat
   pack $This.frame3.s \
      -in $This.frame3 -side top -fill x

   #--- Button-design
   canvas $This.frame3.s.canv1 \
      -width 27 -height 27 \
      -borderwidth 0 -relief flat -bg $audace(color,backColor) \
      -highlightbackground $audace(color,backColor)
   $This.frame3.s.canv1 create line 3 3 3 25 25 25 25 3 3 3  \
      -fill $audace(color,entryTextColor) -width 3
   pack $This.frame3.s.canv1 \
      -in $This.frame3.s -expand 1

   #--- Write the label
   label $This.frame3.s.canv1.lab \
      -font [ list {Arial} 10 bold ] -text "$caption(telpad,sud)" \
      -borderwidth 0 -relief flat
   place $This.frame3.s.canv1.lab \
      -in $This.frame3.s.canv1 -x 9 -y 6

   set zone(n) $This.frame3.n.canv1
   set zone(e) $This.frame3.we.canv1
   set zone(w) $This.frame3.we.canv2
   set zone(s) $This.frame3.s.canv1

   #--- Ecrit l'etiquette du controle du suivi : Suivi on ou off
   if { [::telescope::possedeControleSuivi] == "1" } {
      label $This.frame3.s.lab1 \
         -font [ list {Arial} 10 bold ] -textvariable audace(telescope,controle) \
         -borderwidth 0 -relief flat
      pack $This.frame3.s.lab1 -in $This.frame3.s -expand 1 -side left
      bind $This.frame3.s.lab1 <ButtonPress-1> { ::telescope::controleSuivi }
   }

   #--- Binding de la vitesse du telescope
   bind $This.frame3.we.lab <ButtonPress-1> { ::telescope::incrementSpeed }

   #--- Cardinal moves
   bind $zone(e) <ButtonPress-1> { catch { ::move e } }
   bind $zone(e).lab <ButtonPress-1> { catch { ::move e } }
   bind $zone(e) <ButtonRelease-1> { ::etel_suivi_diurne}
   bind $zone(e).lab <ButtonRelease-1> { ::etel_suivi_diurne}
   bind $zone(w) <ButtonPress-1> { catch { ::move w  } }
   bind $zone(w).lab <ButtonPress-1> { catch { ::move w } }
   bind $zone(w) <ButtonRelease-1> { ::etel_suivi_diurne }
   bind $zone(w).lab <ButtonRelease-1> { ::etel_suivi_diurne }
   bind $zone(s) <ButtonPress-1> { catch { ::telescope::move s  } }
   bind $zone(s).lab <ButtonPress-1> { catch { ::telescope::move s } }
   bind $zone(s) <ButtonRelease-1> { ::etel_suivi_diurne }
   bind $zone(s).lab <ButtonRelease-1> { ::etel_suivi_diurne }
   bind $zone(n) <ButtonPress-1> { catch { ::telescope::move n } }
   bind $zone(n).lab <ButtonPress-1> { catch { ::telescope::move n } }
   bind $zone(n) <ButtonRelease-1> { ::etel_suivi_diurne }
   bind $zone(n).lab <ButtonRelease-1> { ::etel_suivi_diurne }

   #--- Label pour moteur focus
   label $This.frame4.lab1 -text $caption(telpad,moteur_foc) -relief flat
   pack $This.frame4.lab1 -in $This.frame4 -anchor center -fill none -padx 4 -pady 1

   #--- Create the buttons '- +'
   frame $This.frame4.we -width 27 -borderwidth 0 -relief flat
   pack $This.frame4.we -in $This.frame4 -side top -fill x

   #--- Button-design
   canvas $This.frame4.we.canv1 -borderwidth 0 -height 27 -width 27 -relief flat -bg $audace(color,backColor) \
      -highlightbackground $audace(color,backColor)
   $This.frame4.we.canv1 create line 3 3 3 25 25 25 25 3 3 3 -fill $audace(color,entryTextColor) -width 3
   $This.frame4.we.canv1 create line 9 14 19 14 -fill $audace(color,entryTextColor) -width 3
   pack $This.frame4.we.canv1 -in $This.frame4.we -expand 1 -side left

   #--- Write the label of speed
   label $This.frame4.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(focus,labelspeed) \
      -borderwidth 0 -relief flat
   pack $This.frame4.we.lab -in $This.frame4.we -expand 1 -side left

   #--- Button-design
   canvas $This.frame4.we.canv2 -borderwidth 0 -height 27 -width 27 -relief flat -bg $audace(color,backColor) \
      -highlightbackground $audace(color,backColor)
   $This.frame4.we.canv2 create line 3 3 3 25 25 25 25 3 3 3 -fill $audace(color,entryTextColor) -width 3
   $This.frame4.we.canv2 create line 9 14 19 14 -fill $audace(color,entryTextColor) -width 3
   $This.frame4.we.canv2 create line 14 9 14 19 -fill $audace(color,entryTextColor) -width 3
   pack $This.frame4.we.canv2 -in $This.frame4.we -expand 1 -side right
 
   set zone(moins) $This.frame4.we.canv1
   set zone(plus)  $This.frame4.we.canv2

   #--- Binding de la vitesse du moteur de focalisation
   bind $This.frame4.we.lab <ButtonPress-1> { ::focus::incrementSpeed }

   #--- Cardinal moves
   bind $zone(moins) <ButtonPress-1> { catch { ::focus::move - } }
   bind $zone(moins) <ButtonRelease-1> { ::focus::move stop }
   bind $zone(plus) <ButtonPress-1> { catch { ::focus::move + } }
   bind $zone(plus) <ButtonRelease-1> { ::focus::move stop }

   #--- La fenetre est active
   focus $This

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
   
   ::etel_suivi_diurne
   after 100

   #creation d'une vitesse de rappel egale a la vitesse de suivi

   set va  [tel1 get_register_s 0 X 13]
   set va [expr $va-2]
   tel1 set_register_s 0 X 14 0 [expr abs($va) ]
   after 1000
   set vh  [tel1 get_register_s 1 X 13]
   set vh [expr $va-2]
   tel1 set_register_s 1 X 14 0 [expr abs($vh) ]
   
   #------------------------------------------------------------
   #    RAPPEL AZIMUT PLUS
   #------------------------------------------------------------
   proc move e{ } {
   	global audace
   	global caption
   	global base
      global paramaltaz
      tel1 execute_command_x_s 0 26 1 0 0 30	           
   }
   
   #------------------------------------------------------------
   #    RAPPEL AZIMUT MOINS
   #------------------------------------------------------------
   proc move e{ } {
   	global audace
   	global caption
   	global base
      global paramaltaz
      tel1 execute_command_x_s 0 26 1 0 0 20	           
   }
   
   #------------------------------------------------------------
   #    RAPPEL HAUT
   #------------------------------------------------------------
   proc move e{ } {
   	global audace
   	global caption
   	global base
      global paramaltaz
      tel1 execute_command_x_s 0 26 1 0 0 30	           
   }
   
   #------------------------------------------------------------
   #    RAPPEL BAS
   #------------------------------------------------------------
   proc move e{ } {
   	global audace
   	global caption
   	global base
      global paramaltaz
      tel1 execute_command_x_s 0 26 1 0 0 20	           
   }
   
   ::etel_suivi_diurne
	
}
