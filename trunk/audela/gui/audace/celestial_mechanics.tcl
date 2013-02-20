#
# Fichier : celestial_mechanics.tcl
# Description : Outils pour le calcul de coordonnees celestes
# Auteur : Alain KLOTZ
# Mise à jour $Id$
#

# ------------------------------------------------------------------------------------
#
# proc        : name2coord { }
# Description : Resolveur de noms et retourne les coordonnees J2000.0
# Auteur      : Alain KLOTZ
# Update      : 06 February 2013
#
# ------------------------------------------------------------------------------------

proc name2coord { args } {
   # source $audace(rep_install)/gui/audace/celestial_mechanics.tcl ; name2coord dudul
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
   # --- special names
   if {$found==0} {
      set name0 [string tolower $name0]
      set ra ""
      set dec ""
      if {$name0=="dztau"} { set ra 05h42m38.56s ; set dec +22d01m19.7s}
      if {$name0=="crab"} { set ra 05h34m31.94s ; set dec +22d00m52.2s}
      console::affiche_resultat "ra=$ra dec=$dec\n"
      if {$ra!=""} {
         set ra  [string trim [mc_angle2hms $ra 360 zero 2 auto string]]
         set dec [string trim [mc_angle2dms $dec 90 zero 1 + string]]
         set found 1
      }      
   }
   # --- star names
   if {$found==0} {
      set f [open [file join $audace(rep_gui) audace catalogues catagoto etoiles_brillantes.txt] r]
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
   # --- Be star names
   if {$found==0} {
      set f [open [file join $audace(rep_gui) audace catalogues catagoto etoiles_Be.txt] r]
      set lignes [split [read $f] \n]
      close $f
      set name0 [string tolower $name0]
      set ra ""
      set dec ""
      foreach ligne $lignes {
         set found 0
         set name [string tolower [string trim [string range $ligne 0 14]]]
         if {$name0==$name} {
            set found 1
         }
         if {$found==0} {
            set name [string tolower [string trim [string range $ligne 15 22]]]
            if {$name0==$name} {
               set found 1
            }
         }
         if {$found==1} {
            set ra  [string trim [mc_angle2hms "[string tolower [string trim [string range $ligne 23 33]]] h" 360 zero 2 auto string]]
            set dec [string trim [mc_angle2dms [string tolower [string trim [string range $ligne 37 47]]] 90 zero 1 + string]]
            break
         }
      }
   }
   # --- Messier
   if {$found==0} {
      set f [open [file join $audace(rep_gui) audace catalogues catagoto cat_messier.txt] r]
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
      set f [open [file join $audace(rep_gui) audace catalogues catagoto cat_ngc.txt] r]
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
      set f [open [file join $audace(rep_gui) audace catalogues catagoto cat_ic.txt] r]
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
   # --- else satellite
   if {$found==0} {
      set err [catch {satel_coords "$name0" $date} res]
      if {$err==0} {
         #::console::affiche_resultat "res=$res\n"
         set ra  [string trim [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]]
         set dec [string trim [mc_angle2dms [lindex $res 2]  90 zero 1 + string]]
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

# ------------------------------------------------------------------------------------
#
# proc        : meteores_zhr { }
# Description : Calcule le ZHR d'un essaim de meteores a partir d'observations visuelles
# Auteur      : Alain KLOTZ
# Update      : 12 Aout 2010
#
# ------ Examples :
# meteores_zhr 2010-08-07T20:37 2010-08-07T22:00 PER 5.4 11 1
# meteores_zhr 2010-08-08T20:52 2010-08-08T23:33 PER 5.4 13 1
# meteores_zhr 2010-08-10T20:40 2010-08-10T21:47 PER 5.0 3.5 0.9
#
# On lit le fichier "$audace(rep_catalogues)/essaims_meteores.txt"
# qui contient la position du radian et le parametre r des essaims connus
#
# ------------------------------------------------------------------------------------

proc meteores_zhr { date_beg date_end stream_id maglim nb_meteors sky_efficiency {home ""} } {
   set MgLim $maglim
   set NbMeteor $nb_meteors
   set Ciel [expr 100.*$sky_efficiency]
   set DureeObs [expr 1440.*([mc_date2jd $date_end]-[mc_date2jd $date_beg])]
   if {$home==""} {
      set home "$::audace(posobs,observateur,gps)"
   }
   #
   set jd [expr .5*([mc_date2jd $date_end]+[mc_date2jd $date_beg])]
   set year [lindex [mc_date2ymdhms $jd] 0]
   set valid 0
   set streams [meteore_streams $year]
   foreach stream $streams {
      set stream_id0 [lindex $stream 0]
      if {$stream_id0==$stream_id} {
         set stream_name [lindex $stream 1]
         set stream_index [lindex $stream 2]
         set stream_max [lindex $stream 3]
         set stream_radian_ra [lindex $stream 4]
         set stream_radian_dec [lindex $stream 5]
         set stream_drift_ra [lindex $stream 6]
         set stream_drift_dec [lindex $stream 7]
         set valid 1
         break
      }
   }
   if {$valid==0} {
      set stream_ids "stream_id must be amongst "
      foreach stream $streams {
         append stream_ids "[lindex $stream 0] "
      }
      error $stream_ids
   }
   set Indice $stream_index
   set djd [expr $jd-[mc_date2jd $stream_max]]
   set ra  [expr $stream_radian_ra +$stream_drift_ra*$djd]
   set dec [expr $stream_radian_dec+$stream_drift_dec*$djd]
   set res [mc_radec2altaz $ra $dec $home $jd]
   set AltRadiant [lindex $res 1]
   # --- calculs
   set radian [expr 180./4/atan(1)]
   set NbMeteors ""
   set nm [expr $NbMeteor-sqrt($NbMeteor)]
   lappend NbMeteors $nm
   set nm [expr $NbMeteor]
   lappend NbMeteors $nm
   set nm [expr $NbMeteor+sqrt($NbMeteor)]
   lappend NbMeteors $nm
   set ZHRs ""
   foreach n $NbMeteors {
      if {$MgLim < 6.5} {
         set exposant [expr 6.5 - $MgLim]
      } else {
         set exposant [expr 1 - ($MgLim - 6.5)]
      }
      set Expo [expr pow($Indice,$exposant)]
      set Angle [expr sin($AltRadiant / $radian)]
      set ZHR [expr (1.*$n / $DureeObs * 60) * $Expo / $Angle]
      if {$Ciel != 100} {
         set ZHR [expr $ZHR * 100 / $Ciel]
      }
      lappend ZHRs $ZHR
   }
   set ZHR [lindex $ZHRs 1]
   set ZHRmin [lindex $ZHRs 0]
   set ZHRmax [lindex $ZHRs 2]
   set longisun [lindex [lindex [mc_astrology $jd $home] 0] 2]
   # --- sorties
   set texte "\n"
   append texte "======================================\n"
   append texte "Stream = $stream_name ($stream_id)\n"
   append texte "--------------------------------------\n"
   append texte "Date_beg = [mc_date2iso8601 $date_beg]\n"
   append texte "Date_end = [mc_date2iso8601 $date_end]\n"
   append texte "Limiting magnitude = $MgLim\n"
   append texte "Nb meteors = $NbMeteor\n"
   append texte "Sky efficiency = $Ciel %\n"
   append texte "Observation location = $home\n"
   append texte "--------------------------------------\n"
   append texte "Stream index = $Indice\n"
   append texte "Stream RA = [format %.2f $ra] deg\n"
   append texte "Stream DEC = [format %+.1f $dec] deg\n"
   append texte "Stream elevation = [format %.1f $AltRadiant] deg\n"
   append texte "Observation duration = [format %.1f $DureeObs] min\n"
   append texte "Sun longitude = [format %.2f $longisun]\n"
   append texte "--------------------------------------\n"
   append texte "ZHR = [format %.1f $ZHR] ([format %.1f $ZHRmin] - [format %.1f $ZHRmax])\n"
   ::console::affiche_resultat "$texte\n"
   return $ZHR
}

proc meteore_months { month } {
   set month [string toupper $month]
   if {$month=="JAN"} { return 1; }
   if {$month=="FEB"} { return 2; }
   if {$month=="MAR"} { return 3; }
   if {$month=="APR"} { return 4; }
   if {$month=="MAY"} { return 5; }
   if {$month=="JUN"} { return 6; }
   if {$month=="JUL"} { return 7; }
   if {$month=="AUG"} { return 8; }
   if {$month=="SEP"} { return 9; }
   if {$month=="OCT"} { return 10; }
   if {$month=="NOV"} { return 11; }
   if {$month=="DEC"} { return 12; }
   return 0;
}

proc meteore_streams { {year ""} } {
   global audace meteores
   set fname "$audace(rep_catalogues)/essaims_meteores.txt"
   set meteores(stream,fname) $fname
   set res [file exists $fname]
   if {$res==1} {
      set f [open $fname r]
      set lignes [split [read $f] \n]
      close $f
      set lignes [lrange $lignes 0 end-1]
   }
   if {$year==""} {
      set year [lindex [mc_date2ymdhms [::audace::date_sys2ut now]] 0]
   }
   set kl 0
   set meteores(streams) ""
   set nl [llength $lignes]
   for {set kl 0} {$kl<$nl} {incr kl} {
      set ligne [lindex $lignes $kl]
      set key "Active:"
      set k1 [string first $key $ligne]
      if {$k1>20} {
         set key " ("
         set k1 [string first $key $ligne]
         set stream_name [string trim [string range $ligne 0 $k1]]
         #
         set k1 [expr $k1+[string length $key]]
         set key ") "
         set k2 [expr [string first $key $ligne]-1]
         set lig [string range $ligne $k1 $k2]
         set stream_id [string trim $lig]
         #
         set key "Max:"
         set k1 [string first $key $ligne]
         set k1 [expr $k1+[string length $key]]
         set lig [string range $ligne $k1 end]
         set month [lindex $lig 0]
         set day [string trimleft [lindex $lig 1] 0]
         if {$month=="several"} {
            set month May
            set day 19
         }
         set date [list $year [meteore_months $month] $day]
         #::console::affiche_resultat "date=$date\n"
         set stream_max [mc_date2iso8601 $date]
         #
         incr kl
         set ligne [lindex $lignes $kl]
         #
         set key "Radiant:"
         set k1 [string first $key $ligne]
         set k1 [expr $k1+[string length $key]]
         set lig [string range $ligne $k1 end]
         set stream_radian_ra  [lindex $lig 0]
         set stream_radian_dec [lindex $lig 1]
         #
         set key "Drift:"
         set k1 [string first $key $ligne]
         set k1 [expr $k1+[string length $key]]
         set lig [string range $ligne $k1 end]
         set stream_drift_ra  [lindex $lig 0]
         set stream_drift_dec [lindex $lig 1]
         if {$stream_drift_ra=="?"} {
            set stream_drift_ra  0
            set stream_drift_dec 0
         }
         #
         incr kl
         set ligne [lindex $lignes $kl]
         #
         set key "Population Index:"
         set k1 [string first $key $ligne]
         set k1 [expr $k1+[string length $key]]
         set lig [string range $ligne $k1 end]
         set stream_index [lindex $lig 0]
         #
         set stream [list $stream_id $stream_name $stream_index $stream_max $stream_radian_ra $stream_radian_dec $stream_drift_ra $stream_drift_dec]
         lappend meteores(streams) $stream
         #::console::affiche_resultat "$stream\n"
      }
   }
   return $meteores(streams)
}

