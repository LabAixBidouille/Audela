#--------------------------------------------------------------------------------
# Fichier origine : ohp_t193.tcl
# Description : Interface de pilotage du T193 de l'OHP
# Auteur : Alain KLOTZ
# Mise a jour $Id: ohp_t193.tcl,v 1.2 2009-12-05 10:21:38 ffillion Exp $
#--------------------------------------------------------------------------------
# Modifications pour le télescope T193 :
#-------------------------------------
# juin 2009 : F.FILLION (OHP/CNRS)
#           - utilisation du script comme système des coordonnées du 
#             télescope T193 de l'OHP
#           - permettra la comparaison avec le programme sous LabWindows
#           - pourra être utilisé en urgence si problème avec le HP1000
#
# !WARNING!   un bug subsiste: plantage de AudeLA après 15-20 mn le lancement 
#                              du script, fuite mémoire ?
#________________________________________________________________________________
# Remarque: exemple de connexion à l'automate du télescope 193 de l'OHP :
# --------  commande TCL = "::tel::create deltatau tcp -ip 192.168.128.155"       (provisoire : "set audace(telNo) 1")
#           avec ici l'IP de PMAC (fixe) = 192.168.128.155
#--------------------------------------------------------------------------------
# T193:
#        - latitude  (Nord) : 43d55m54s8
#        - longitude (Est)  : 5d42m56s5
#        - altitude         : 633.9 m
#--------------------------------------------------------------------------------
global audace
global caption
global base
global paramt193
global telPMAC193
global pos_obs
global ippmac
global comm193_name


##------------------------------------------------------------
# @brief   namespace client d'affichage des coordonnées
#
#------------------------------------------------------------
namespace eval ::clientCoord {

}

proc ::clientCoord::run {} {
	### Rappel d'utilisation des sockets en TCL) 
	# socket TCL : set ma_socket [socket "127.0.0.1" 10000]
	# ----------   puts -nonewline $ma_socket "requete"
	#              flush $ma_socket
	#              set nb 256
	#              set reponse [read $ma_socket $nb]
	#              close $ma_socket 
	#              binary scan $reponse ? ??
	#
	# Si connexion coupée =>  if {[tel$audace(telNo) putread "#5P"] != "0"} { reconnexion... }
	###

	#--- Chargement des captions
	source [ file join $audace(rep_scripts) ohp_t193.cap ]

	#--- Initialisation
	set audace(posobs,observateur,gps) "GPS 5.7157 E 43.931892 633.9"
	set paramt193(sortie)     "0"
	set paramt193(ra)         "21 44 11.2"
	set paramt193(dec)        "+09 52 30"
	set paramt193(home)       $audace(posobs,observateur,gps)
	set couleur_blanche       #FFFFFF
	set couleur_noire         #000000
	set couleur_or            #FFAA00
	set couleur_orclair       #FF9900
	set couleur_bleuclair     #00AAFF
	set couleur_bleu          #0000FF
	set couleur_rouge         #FF5500
	set paramt193(color,back) $couleur_bleu
	set paramt193(color,text) $couleur_or
	set paramt193(font)       {tahoma 60 bold}
	set paramt193(font2)      {tahoma 17 normal}
	set paramt193(font3)      {arial  15 bold}
	set paramt193(font4)      {tahoma 22 normal}
	set paramt193(fonttitle)  {arial  75 bold}

	set paramt193(new,ra)     "$paramt193(ra)"
	set paramt193(new,dec)    "$paramt193(dec)"

	set audace(posobs,observateur,gps) "GPS 5.7157 E 43.931892 633.9"
	set ohp_name "OHP"
	set pos_obs  " Latitude: 43°55'54.8''  Longitude: 05°42'56.5''  Altitude: 633.9 m"
	set ippmac "192.168.128.155"
	set comm193_name "DeltaTau-PMAC-T193"


	#--- déconnexion des clients AudeLA de la PMAC
	::clientCoord::deconnecterServeurCoordonnees

	#--- connexion à la PMAC
	::clientCoord::connecterServeurCoordonnees

	#--- Create the toplevel window
	set base .ohp_t193
	toplevel $base -class Toplevel
	wm geometry $base 1600x1600+10+10
	wm focusmodel $base passive
	wm maxsize $base 2000 2000
	wm minsize $base 600 600
	#wm overrideredirect $base 0
	wm resizable $base 1 1
	wm deiconify $base
	wm title $base "$caption(ohp_t193,titre)"
	wm protocol $base WM_DELETE_WINDOW ohp_t193_fermer
	bind $base <Destroy> { destroy .ohp_t193 }
	$base configure -bg $paramt193(color,back)
	wm withdraw .
	focus -force $base

	#---
	set paramt193(ohp_t193,adinit)  ""
	set paramt193(ohp_t193,decinit) ""
	#set paramt193(ohp_t193,adinit)  00h00m00s
	#set paramt193(ohp_t193,decinit) +00°00'00\"
	set paramt193(ohp_t193,fichierlog) codeurs_t193.log

	#--- titre "T193"
	frame $base.f -bg $paramt193(color,back)
	label $base.f.lab_titre \
	  -bg $paramt193(color,back) -fg $couleur_bleuclair \
	  -font $paramt193(fonttitle) -text "$caption(ohp_t193,titre)"
	pack $base.f.lab_titre -anchor c
	
	#--- données GPS OHP - Latitude - Longitude - Altitude
	label $base.f.lab_ohp \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font4) \
	  -text $ohp_name
	pack $base.f.lab_ohp -fill none -pady 2 -anchor w  
	label $base.f.lab_altaz \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font2)
	pack $base.f.lab_altaz -fill none -pady 2 -anchor w
	
	label $base.f.lab_blank01 \
	  -bg $paramt193(color,back) \
	  -text "\n"
	pack $base.f.lab_blank01 -fill none -pady 2
	
	#--- temps
	label $base.f.lab_tu \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font)
	  
	label $base.f.lab_tsl \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font)
	pack $base.f.lab_tu -fill none -pady 2 -anchor w
	pack $base.f.lab_tsl -fill none -pady 2 -anchor w

	#--- coordonnées equatoriales : Alpha et Delta
	label $base.f.lab_ad \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font)
	  
	label $base.f.lab_dec \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font)
	pack $base.f.lab_ad -fill none -pady 2 -anchor w
	pack $base.f.lab_dec -fill none -pady 2 -anchor w

	#--- angle horaire
	label $base.f.lab_ha \
	  -bg $paramt193(color,back) -fg $couleur_bleuclair\
	  -font $paramt193(font)
	pack $base.f.lab_ha -fill none -pady 2 -anchor w

	#---
	label $base.f.lab_blank10 \
	  -bg $paramt193(color,back) \
	  -text "\n\n"
	pack $base.f.lab_blank10 -fill none -pady 2
	
	label $base.f.lab_coord0 \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -font $paramt193(font3)
	pack $base.f.lab_coord0 -fill none -pady 2  -anchor c

	#---
	set modele [tel$audace(telNo) model]
	if {[llength $modele]==0} {
	  set cap $caption(ohp_t193,modelisoff)
	} else {
	  set cap $caption(ohp_t193,modelison)
	}
	
	label $base.f.lab_blank20 \
	  -bg $paramt193(color,back) \
	  -text "\n\n\n\n"
	pack $base.f.lab_blank20 -fill none -pady 2

	#---
	label $base.f.lab_blank30 \
	  -bg $paramt193(color,back) \
	  -text ""
	pack $base.f.lab_blank30 -fill none -pady 2

	label $base.f.lab_model \
	  -bg $paramt193(color,back) -fg $paramt193(color,text) \
	  -text "$caption(ohp_t193,modeldescr)"
	pack $base.f.lab_model -fill none -pady 2

	pack $base.f -fill both
	
	#--- lancement de la boucle de calcul des coordonnées
	::clientCoord::ohp_t193_calcul
}



###Proc: log_coord = log de debug
proc ::clientCoord::log_coord { message } {
	global audace modpoi
	set f [ open [ file join $audace(rep_scripts) log-coord-193 coord-193_2009.log ] a ]
	set texte "$message\n"
	puts -nonewline $f $texte
	close $f
}

### Procédures client du serveur de coordonnées :

proc ::clientCoord::deconnecterServeurCoordonnees {} {
	global audace
	global paramt193
	global telPMAC193 comm193_name
	
	if { [ ::tel::list ] != "" } {
		#on delete toutes les connexions à la PMAC DeltaTau
		::console::affiche_resultat "\nsupression de toutes les connexions à la PMAC du télescope T193\n"
		#log_coord "supression de toutes les connexions"
		foreach telNo [ ::tel::list ] {
		        set tel_name [tel$telNo name]
		        if { $tel_name == $comm193_name} {
		                #log_coord "delete socket tel$telNo $tel_name"
		                set res [::tel::delete $telNo]
		                ::console::affiche_resultat "delete socket tel$telNo $tel_name\n"
		        }
		}
	}
}

proc ::clientCoord::connecterServeurCoordonnees {} {
	global audace
	global paramt193
	global ippmac
	global telPMAC193
	
	::console::affiche_resultat "\nconnexion à la PMAC du télescope T193\n"
	#log_coord "connexion à la PMAC du télescope T193"
	set telPMAC193 [::tel::create deltatau tcp -ip $ippmac]
	set audace(telNo) $telPMAC193
}


proc ::clientCoord::ohp_t193_fermer { } {
   global audace
   global base
   global paramt193

   set paramt193(sortie) "1"
   destroy $base
}

proc ::clientCoord::ohp_t193_init { } {
   global audace
   global base
   global paramt193
   set res [tk_messageBox -type yesno -title "confirmation de l'init" -default no -message "Voulez-vous vraiment initialiser ?" -icon warning]
   if {$res=="yes"} {
      if {([string compare $paramt193(ohp_t193,adinit) ""]==0)||([string compare $paramt193(ohp_t193,decinit) ""]==0)} {
	 tel$audace(telNo) init_default 0
      } else {
	 set res [tel$audace(telNo) radec init [list $paramt193(ohp_t193,adinit) $paramt193(ohp_t193,decinit)]]
      }
   }
}

proc ::clientCoord::ohp_t193_calcul { } {
    global audace
    global caption
    global base
    global paramt193 pos_obs ohp_name

    if { $paramt193(sortie) != "1" } {

	 #--- test de communication
    if {[tel$audace(telNo) testcom] == 1 } { 
       #log_coord "échec connexion"
       $base.f.lab_ad configure -text   "$caption(ohp_t193,ad)   -"
	   $base.f.lab_dec configure -text "$caption(ohp_t193,dec)   -"
	   $base.f.lab_tu configure    -text "$caption(ohp_t193,tu)   -"
	   $base.f.lab_tsl configure   -text "$caption(ohp_t193,tsl)   -"
	   $base.f.lab_ha configure    -text "$caption(ohp_t193,angle_horaire)   -"
       $base.f.lab_altaz configure -text "$pos_obs\t\t$caption(ohp_t193,azimut) -\t$caption(ohp_t193,hauteur) -"
       tk_messageBox -message "Erreur de connexion à la PMAC." -title "PMAC error" -icon question -type ok
       return
    }

    #---
    set res [tel$audace(telNo) radec coord]
    set paramt193(ra0)  [mc_angle2hms [lindex $res 0] 360 zero 2 auto string]
    set paramt193(dec0) [mc_angle2dms [lindex $res 1] 90 zero 1 + string]
    #--- 
    set res [tel$audace(telNo) radec coord]
    set paramt193(ra)  [mc_angle2hms [lindex $res 0] 360 zero 2 auto string]
    set paramt193(dec) [mc_angle2dms [lindex $res 1] 90 zero 1 + string]
    
    #--- coordonnées brutes (sans correction du modèle de pointage)
    $base.f.lab_coord0 configure -text "$caption(ohp_t193,ad0) $paramt193(ra0)\t$caption(ohp_t193,dec0) $paramt193(dec0)"
    
    #--- coordonnées corrigées avec le modèle de pointage
    if {[llength $modele]==0} {
	   set alpha "n.c."
	   set delta "n.c."
	   $base.f.lab_ad configure -text   "$caption(ohp_t193,ad)   n.c."
	   $base.f.lab_dec configure -text "$caption(ohp_t193,dec)   n.c."
    } else {
	   set alpha "[string range $paramt193(ra) 0 2] [string range $paramt193(ra) 3 5] [string range $paramt193(ra) 6 7].[string range $paramt193(ra) 9 10]s"
	   set delta "[string range $paramt193(dec) 0 2]°  [string range $paramt193(dec) 4 5]'   [string range $paramt193(dec) 7 8].[string range $paramt193(dec) 10 10]0''"
	   $base.f.lab_ad configure -text "$caption(ohp_t193,ad)   $alpha"
	   $base.f.lab_dec configure -text "$caption(ohp_t193,dec) $delta"
    }
    
    #--- Temps TU (temps universel)
    set now now
    catch {set now [::audace::date_sys2ut now]}
    set tu [mc_date2ymdhms $now]
    set tuh    [format "%02d" [lindex $tu 3]]
    set tum    [format "%02d" [lindex $tu 4]]
    set tus    [format "%05.2f" [lindex $tu 5]]
    
    #--- Temps TS (temps sidéral local)
    set tsl [mc_date2lst $now $paramt193(home)]
    set tslh    [format "%02d" [lindex $tsl 0]]
    set tslm    [format "%02d" [lindex $tsl 1]]
    set tsls    [format "%05.2f" [lindex $tsl 2]]

	#--- Angle horaire, Azimut et Hauteur du télescope
    set res [mc_radec2altaz "$paramt193(ra)" "$paramt193(dec)" "$paramt193(home)" $tu]
    set az  [format "%06.2f" [lindex $res 0]]
    set alt [format "%+06.2f" [lindex $res 1]]
    set ha  [lindex $res 2]
    set paramt193(az) [lindex $res 0]
    set paramt193(alt) [lindex $res 1]
    set paramt193(ha) [lindex $res 2]
    set angle_h [mc_angle2hms $ha 360 zero 2 auto string]
    set angle_h "[string range $angle_h 0 2] [string range $angle_h 3 5] [string range $angle_h 6 7].[string range $angle_h 9 10]s"
    
    #--- Affichage temps (TU, TSL) et coordonnées (ALPHA, DELTA, ANGLE HORAIRE, Azimut, hauteur du télescope)
    $base.f.lab_tu configure    -text "$caption(ohp_t193,tu)   ${tuh}h ${tum}m ${tus}s"
    $base.f.lab_tsl configure   -text "$caption(ohp_t193,tsl)   ${tslh}h ${tslm}m ${tsls}s"
    $base.f.lab_ha configure    -text "$caption(ohp_t193,angle_horaire)   $angle_h"
    $base.f.lab_altaz configure -text "$pos_obs\t\t$caption(ohp_t193,azimut) ${az}°\t$caption(ohp_t193,hauteur) ${alt}°"
    
    #--- An infinite loop to change the language interactively
    after 250 ::ohp_t193_calcul
    } else {
       #--- Rien
    }
}

::clientCoord::run