#
# Fichier : celestial_mechanics.tcl
# Description : Outils pour le calcul de coordonnees celestes
# Auteur : Alain KLOTZ
# Mise a jour $Id: celestial_mechanics.tcl,v 1.1 2009-08-31 16:02:54 myrtillelaas Exp $
#

# ------------------------------------------------------------------------------------
#
# proc        : name2coord { }
# Description : Resolveur de noms et retourne les coordonnees J2000.0
# Auteur      : Alain KLOTZ
# Update      : 01 September 2009
#
# ------------------------------------------------------------------------------------

proc name2coord { args } {
   # source audace/celestial_mechanics.tcl ; name2coord dudul
   # name2coord m1 -offset 1
   global audace
   set home $audace(posobs,observateur,gps)
   set date [::audace::date_sys2ut now]
   set name [lindex $args 0]   
   set name0 $name
   set argc [llength $args]
   if { $argc < 1} {
      error "Usage: name2coord name ?-offset flag?"
      return $error;
   }
   set offset 0
   if {$argc > 1} {
      for {set k 1} {$k<[expr $argc-1]} {incr k} {
         set argu [lindex $args $k]
         if {$argu=="-offset"} {
            set offset [lindex $args [expr $k+1]]
         }
      }
   }   
   set found 0
   # --- star names
   if {$found==0} {
   	set f [open "$audace(rep_audela)/audace/etc/catagoto/etoiles_brillantes.txt" r]
   	set lignes [split [read $f] \n]
   	close $f
   	set name0 [string tolower $name0]
   	set ra ""
   	set dec ""
   	foreach ligne $lignes {
   		set found 0
   		set name [string tolower [string trim [string range $ligne 0 20]]]
   		if {$name0==$name} {
   			set found 1
   		}
   		if {$found==0} {
   			set name [string tolower [string trim [string range $ligne 21 35]]]
   			if {$name0==$name} {
   				set found 1
   			}
   		}
   		if {$found==1} {
   			set ra  [string trim [mc_angle2hms "[string tolower [string trim [string range $ligne 36 45]]] h" 360 zero 2 auto string]]
   			set dec [string trim [mc_angle2dms [string tolower [string trim [string range $ligne 50 58]]] 90 zero 1 + string]]
   			break
   		}
   	}
	}
   # --- Messier
   if {$found==0} {
   	set f [open "$audace(rep_audela)/audace/etc/catagoto/cat_messier.txt" r]
   	set lignes [split [read $f] \n]
   	close $f
   	set name0 [string toupper $name0]
   	set ra ""
   	set dec ""
   	foreach ligne $lignes {
   		set found 0
   		set name [string toupper [string trim [lindex $ligne 0]]]
   		if {$name0==$name} {
   			set found 1
   		}
      	#::console::affiche_resultat "$name $name0 $found\n"
   		if {$found==1} {
      		set rah [lindex $ligne 1]
      		set ram [lindex $ligne 2]
      		set decd [lindex $ligne 3]
      		set decm [lindex $ligne 4]
   			set ra  [string trim [mc_angle2hms "${rah}h${ram}m" 360 zero 2 auto string]]
   			set dec [string trim [mc_angle2dms "${decd}d${decm}m" 90 zero 1 + string]]
   			break
   		}
   	}
	}
   # --- NGC
   if {$found==0} {
   	set f [open "$audace(rep_audela)/audace/etc/catagoto/cat_ngc.txt" r]
   	set lignes [split [read $f] \n]
   	close $f
   	set name0 [string toupper $name0]
   	set ra ""
   	set dec ""
   	foreach ligne $lignes {
   		set found 0
   		set name [string toupper [string trim [lindex $ligne 0]]]
   		if {$name0==$name} {
   			set found 1
   		}
   		if {$found==1} {
      		set rah [lindex $ligne 1]
      		set ram [lindex $ligne 2]
      		set decd [lindex $ligne 3]
      		set decm [lindex $ligne 4]
   			set ra  [string trim [mc_angle2hms "${rah}h${ram}m" 360 zero 2 auto string]]
   			set dec [string trim [mc_angle2dms "${decd}d${decm}m" 90 zero 1 + string]]
   			break
   		}
   	}
	}
   # --- IC
   if {$found==0} {
   	set f [open "$audace(rep_audela)/audace/etc/catagoto/cat_ic.txt" r]
   	set lignes [split [read $f] \n]
   	close $f
   	set name0 [string toupper $name0]
   	set ra ""
   	set dec ""
   	foreach ligne $lignes {
   		set found 0
   		set name [string toupper [string trim [lindex $ligne 0]]]
   		if {$name0==$name} {
   			set found 1
   		}
   		if {$found==1} {
      		set rah [lindex $ligne 1]
      		set ram [lindex $ligne 2]
      		set decd [lindex $ligne 3]
      		set decm [lindex $ligne 4]
   			set ra  [string trim [mc_angle2hms "${rah}h${ram}m" 360 zero 2 auto string]]
   			set dec [string trim [mc_angle2dms "${decd}d${decm}m" 90 zero 1 + string]]
   			break
   		}
   	}
	}
	# --- else planete
   if {$found==0} {
      set res [mc_ephem $name0 [list $date] {ra dec} -topo $home] 
      #::console::affiche_resultat "res=$res\n"
      if {[llength $res]==2} {
         set res [lindex $res 0]
         #::console::affiche_resultat "res=$res\n"
      	set ra  [string trim [mc_angle2hms [lindex $res 0] 360 zero 2 auto string]]
      	set dec [string trim [mc_angle2dms [lindex $res 1]  90 zero 1 + string]]
      	set found 1
	  }
	}
	# --- final
	if {$found==1} {
   	set dra 0
   	set ddec 0
   	if {[info exists audace(coords,offset,ra)]==1} {
      	set dra $audace(coords,offset,ra)
   	}
   	if {[info exists audace(coords,offset,dec)]==1} {
      	set ddec $audace(coords,offset,dec)
   	}
   	if {($dra!=0)&&($ddec!=0)&&($offset==1)} {
      	set ra [mc_angle2deg $ra]
      	set dec [mc_angle2deg $dec 90]
         set ra [expr $dra+$ra]
         set dec [expr $ddec+$dec]
      	set ra  [string trim [mc_angle2hms $ra 360 zero 2 auto string]]
      	set dec [string trim [mc_angle2dms $dec  90 zero 1 + string]]         
   	}
		return [list $ra $dec]
	} else {
   	error "No object found"
	}
	
}

proc coord2offset { coordo {coordc ""} } {
   global audace
   # --- calcul de l'offset
   # coord2offset {18h38m20s -24d05m18s} {18h49m46s -24d21m00s}
   
   set res [lindex $coordo]
   if {$res=="reset"} {
      unset audace(coords,offset,ra)
      unset audace(coords,offset,dec)
      return "0 0"
   }
   
   set rao [lindex $coordo 0]
   set rao [mc_angle2deg $rao]
   set deco [lindex $coordo 1]
   set deco [mc_angle2deg $deco 90]

   if {$coordc==""} {
      set coordc $coordo
   }   
   set rac [lindex $coordc 0]
   set rac [mc_angle2deg $rac]
   set decc [lindex $coordc 1]
   set decc [mc_angle2deg $decc 90]
   
   set dra [expr $rao-$rac]
   set ddec [expr $deco-$decc]
   set audace(coords,offset,ra) $dra
   set audace(coords,offset,dec) $ddec
   
   return [list $dra $ddec]
}

# return RA DEC of zenith
proc coordofzenith { args } {
   # source audace/celestial_mechanics.tcl ; coordofzenith
   global audace
   set home $audace(posobs,observateur,gps)
   set latitude [lindex $home 3] 
   set date [::audace::date_sys2ut now]
   set ra  [string trim [mc_angle2hms "[mc_date2lst $date $home] h" 360 zero 2 auto string]]
   set dec [string trim [mc_angle2dms $latitude 90 zero 1 + string]]         
   return [list $ra $dec]
}

# return RA DEC of zenith
proc coordfiducial { args } {
   # source ../../gui/audace/celestial_mechanics.tcl ; coordfiducial
   global audace
   set home $audace(posobs,observateur,gps)
   set latitude [lindex $home 3] 
   set date [::audace::date_sys2ut now]
   set ha [expr 360.-[mc_angle2deg 00h30m25s]]
   set tsl [mc_angle2deg "[mc_date2lst $date $home] h"]
   set ra [expr $tsl-$ha]
   set ra  [string trim [mc_angle2hms "$ra" 360 zero 2 auto string]]
   set decf [mc_angle2deg -31d20m22s]
   set dec [string trim [mc_angle2dms $latitude 90 zero 1 + string]]         
   return [list $ra $dec]
}
