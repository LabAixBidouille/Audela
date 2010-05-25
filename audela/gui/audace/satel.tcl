#
# Fichier : satel.tcl
# Description : Outil pour calculer les positions precises de satellites avec les TLE
# Auteur : Alain KLOTZ
# Mise à jour $Id: satel.tcl,v 1.2 2010-05-25 07:40:12 robertdelmas Exp $
#
# source satel.tcl
# utiliser le temps UTC
# utiliser audace(rep_userCatalog)
#
# --- Pour telecharger les TLEs
# satel_update
# --- Pour cacluler une position d'un satellite
# satel_coords "jason 2" 2010-05-23T20:12:31
# --- Pour rechercher un satellite au voisinage d'une position
# satel_nearest_radec 22h07m34s25 +60d17m33s0 2010-05-23T20:12:31
#
# source satel.tcl ; satel_coords "iridium 82" 2010-05-23T20:01:07
# "JASON 2 (OSTM)" 22h07m34s25 +60d17m33s0 J2000 1.0000 20.47 +20.45
# source satel.tcl ; satel_nearest_radec 22h07m34s25 +60d17m33s0 2010-05-23T20:12:31

proc satel_nearest_radec { ra dec {date now} {home ""} } {
   set sepanglemin 360
   set satelnames [satel_names]
   set ra [mc_angle2deg $ra]
   set dec [mc_angle2deg $dec 90]
   set nsat [llength $satelnames]
   set k 0
   set ksat 0
   foreach satelname $satelnames {
      if {$k==10} {
         if {[info exists resmin]==0} {
            catch {::console::affiche_resultat "$ksat / $nsat\n"}
         } else {
            catch {::console::affiche_resultat "$ksat / $nsat sepmin=$sepanglemin [string trim [lindex [lindex $resmin 0] 0]]\n"}
         }
         set k 0
      }
      incr k
      incr ksat
      set satname [lindex $satelname 0]
      set ficname [lindex $satelname 1]
      #::console::affiche_resultat "$ksat, satel_ephem \"$satname\" $date $home\n"
      set err [catch {satel_ephem \"$satname\" $date $home} res]
      #::console::affiche_resultat "$ksat, err=$err res=$res\n"
      if {$err==1} {
         continue
      }
      if {$res==""} {
         continue
      }
      set res [lindex $res 0]
      if {[info exists resmin]==0} {
         set resmin $res
      }
      set name [string trim [lindex [lindex $res 0] 0]]
      set rasat [lindex $res 1]
      set decsat [lindex $res 2]
      set ill [lindex $res 6]
      set azim [lindex $res 8]
      set gise [expr $azim+180]
      if {$gise>360} {
         set gise [expr $gise-360]
      }
      set elev [lindex $res 9]
      set err [catch {mc_sepangle $ra $dec $rasat $decsat} resang]
      if {$err==1} {
         continue
      }
      set sepangle [lindex $resang 0]
      #::console::affiche_resultat "       sepangle=$sepangle sepanglemin=$sepanglemin\n"
      if {$sepangle<$sepanglemin} {
         set resmin $res
         set sepanglemin $sepangle
      }
   }
   set name [string trim [lindex [lindex $resmin 0] 0]]
   set rasat [mc_angle2hms [lindex $resmin 1] 360 zero 2 auto string]
   set decsat [mc_angle2dms [lindex $resmin 2] 90 zero 1 + string]
   set ill [lindex $resmin 6]
   set azim [lindex $resmin 8]
   set gise [expr $azim+180]
   if {$gise>360} {
      set gise [expr $gise-360]
   }
   set elev [lindex $resmin 9]
   set res "$sepanglemin \"$name\" $ra $dec J2000 $ill [format %.5f $gise] [format %+.5f $elev]\n"
   return $res
}

proc satel_coords { {satelname "ISS"} {date now} {home ""} } {
   set res [satel_ephem $satelname $date $home]
   if {$res==""} {
      error "$res"
   }
   set res [lindex $res 0]
   set name [string trim [lindex [lindex $res 0] 0]]
   set ra [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]
   set dec [mc_angle2dms [lindex $res 2] 90 zero 1 + string]
   set ill [lindex $res 6]
   set azim [lindex $res 8]
   set gise [expr $azim+180]
   if {$gise>360} {
      set gise [expr $gise-360]
   }
   set elev [lindex $res 9]
   set res "\"$name\" $ra $dec J2000 $ill [format %.5f $gise] [format %+.5f $elev]\n"
   return $res
}

proc satel_ephem { {satelname "ISS"} {date now} {home ""} } {
   global audace
   set res [lindex [satel_names \"$satelname\" 1] 0]
   if {$res==""} {
      error "Satellite \"$satelname\" not found in current TLEs"
   }
   set satname [lindex $res 0]
   set satfile "[pwd]/tle/[lindex $res 1]"
   set datfile [file mtime "[pwd]/tle/[lindex $res 1]"]
   set dt [expr ([clock seconds]-$datfile)*86400]
   #::console::affiche_resultat "date de mise a jour = $dt jours\n"
   if {$home==""} {
      set home $audace(posobs,observateur,gps)
   }
   #::console::affiche_resultat "mc_tle2ephem $date \"$satfile\" $home -name \"$satname\" -sgp 4\n"
   set res [mc_tle2ephem $date $satfile $home -name $satname -sgp 4 ] ; # -coord {ra dec}
   return $res
}

# Return the list of NAMES+FILE for a given satelname
proc satel_names { {satelname ""} {nbmax ""} } {
   set tlefiles [glob -nocomplain [pwd]/tle/*.txt]
   set texte ""
   set nsat 0
   if {$nbmax==""} {
      set nbmax 100000
   }
   set satelname [string trim [string trim [string toupper $satelname] \"]]
   foreach tlefile $tlefiles {
      set f [open $tlefile r]
      set lignes [split [read $f] \n]
      close $f
      set k 0
      foreach ligne $lignes {
         if {[string length $ligne]>2} {
            if {$k==0} {
               set name [string trim $ligne]
               if {$satelname!=""} {
                  set k [string first $satelname $name]
                  #::console::affiche_resultat "k=$k\n"
                  #dddd
               } else {
                  set k 0
               }
               if {($k>=0)&&($nsat<=$nbmax)} {
                  lappend texte [list $name [file tail $tlefile]]
                  incr nsat
               }
            }
            incr k
            if {$k==3} {
               set k 0
            }
         }
      }
   }
   return $texte
}

# Return all TLE filenames stored in AudeLA
proc satel_tlefiles { } {
   set tlefiles [glob -nocomplain [pwd]/tle/*.txt]
   set texte ""
   foreach tlefile $tlefiles {
      append texte "[file tail $tlefile] "
   }
   return $texte
}

# Update TLE files in AudeLA
proc satel_update { {server celestrack} } {
   set t0 [clock seconds]
   if {$server=="celestrack"} {
      set elemfiles {amateur.txt classfd.txt cubesat.txt dmc.txt education.txt engineering.txt geo.txt geodetic.txt glo-ops.txt globalstar.txt goes.txt gorizont.txt gps-ops.txt intelsat.txt iridium.txt military.txt molniya.txt musson.txt nnss.txt noaa.txt orbcomm.txt other-comm.txt other.txt radar.txt raduga.txt resource.txt sarsat.txt science.txt stations.txt tdrss.txt tle-new.txt visual.txt weather.txt x-comm.txt        }
      #set elemfiles {amateur.txt classfd.txt }
      set ntot 0
      foreach elemfile $elemfiles {
         set url "http://celestrak.com/NORAD/elements/$elemfile"
         catch {::console::affiche_resultat "Download $url\n"}
         set err [catch {satel_download $url} msg]
         if {$err==1} {
            catch {::console::affiche_resultat " Problem : $msg\n"}
         } else {
            set texte ""
            set n 0
            set lignes [split $msg \n]
            foreach ligne $lignes {
               if {[string length $ligne]>2} {
                  append texte "$ligne\n"
               }
               incr n
            }
            set n [expr $n/3]
            incr ntot $n
            file mkdir [pwd]/tle
            set err [catch {
               set fic "[pwd]/tle/$elemfile"
               set f [open $fic w]
               puts -nonewline $f $texte
               close $f
            } msg]
            if {$err==1} {
               catch {::console::affiche_resultat " Problem : $msg\n"}
            } else {
               catch {::console::affiche_resultat " $n satellites in $elemfile\n"}
            }
         }
      }
      catch {::console::affiche_resultat "A total of $ntot satellite elements are downloaded in [pwd]/tle\n"}
   } else {
      error "server not known. Servers are : celestrack."
   }
   set dt [expr [clock seconds]-$t0]
   catch {::console::affiche_resultat "Done in $dt seconds\n"}
   return $ntot
}

# Download one TLE file and return the contents
proc satel_download { {url http://celestrak.com/NORAD/elements/stations.txt} } {
   set err [catch {
      package require http
      set token [::http::geturl $url]
      upvar #0 $token state
      set html_text $state(body)
   } msg]
   if {$err==0} {
      if {[string first "<!DOCTYPE" $html_text]<0} {
         return $html_text
      } else {
         error "File not found in server"
      }
   } else {
      error $msg
   }
}

