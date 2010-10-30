#
# Fichier : google_earth.tcl
# Description : Interaction avec Google Earth
# Auteur : Alain KLOTZ
# Mise � jour $Id: google_earth.tcl,v 1.3 2010-10-30 08:52:34 michelpujol Exp $
#

# Procedures qui permettent d'interagir avec Google Earth
# Pour l'instant ca ne marche qu'avec les objets COM de Windows
# Il ne suffit que d'avoir installe Google Earth
#
# source google_earth.tcl
#
# * Pour aller a la position courante de l'observateur avec Google EARTH :
# google_earth_home_goto
# * Pour aller a une position de coordonnee donnee avec Google EARTH :
# google_earth_home_goto {GPS 2 E 45 200}
# * Pour aller a une position du nom de site avec Google EARTH :
# google_earth_home_goto search reims
# * Pour retourner la position pointee avec Google EARTH :
# google_earth_home_coord
# * Pour aller a la position indiquee avec Google SKY :
# google_earth_radec_goto m51
# * Pour aller a la position indiquee avec Google SKY :
# google_earth_radec_goto 12h45m23s +34�12'23"
# * Pour retourner le RA et le DEC de la position pointee avec Google SKY :
# google_earth_radec_coord

#####################################################################################
# Fonctions utilitaires
#####################################################################################

proc google_earth_get_com_methods { {handler ""} } {
   global audace
   if {$handler==""} {
      if {[info exists audace(google_earth,com,handler)]==1} {
         set handler $audace(google_earth,com,handler)
      } else {
         return ""
      }
   }
   # === Affiche toutes les methodes
   set methods [[::tcom::info interface $handler] methods]
   foreach method $methods {
      set a [lindex $method 2]
      set res ""
      if {($a=="Login")||($a=="Logout")} {
      } else {
         catch {set res [$handler $a]}
      }
      ::console::affiche_resultat "$method => $res\n"
   }
   #
   #Rechercher un lieu:
   #set sc [$audace(google_earth,com,handler) SearchController]
   #$sc Search "Paris"
   #[$audace(google_earth,com,handler) SearchController] Search Paris
   #Pour les parametres du lieu
   #google_earth_get_com_methods [$audace(google_earth,com,handler) GetCamera 0]
   #
}

proc google_earth_get_com_properties { {handler ""} } {
   global audace
   if {$handler==""} {
      if {[info exists audace(google_earth,com,handler)]==1} {
         set handler $audace(google_earth,com,handler)
      } else {
         return ""
      }
   }
   # === Affiche toutes les properties
   set properties [[::tcom::info interface $handler] properties]
   foreach propertie $properties {
      set a [lindex $propertie 2]
      set res ""
      catch {set res [$handler $a]}
      ::console::affiche_resultat "$propertie => $res\n"
   }
}

proc google_earth_launch { } {
   global audace
   if { $::tcl_platform(os) == "Windows NT" } {
      # --- verifie si GoogleEarth est deja lanc�
      package require twapi
      set ros_names {googleearth.exe}
      set pids [twapi::get_process_ids]
      set gpids ""
      foreach pid $pids {
         set res [twapi::get_process_info $pid -name]
         set name [lindex $res 1 end]
         #::console::affiche_resultat "name=$name\n"
         set k [lsearch -exact $ros_names $name]
         if {$k>=0} {
            set res [twapi::get_process_info $pid -name -elapsedtime -ioreadops -groups -threadcount -user -workingset -basepriority]
            set k [lsearch -exact $res "-name"]
            set name [lindex $res [expr $k+1]]
            #::console::affiche_resultat "$name PID=$pid\n"
            lappend gpids $pid
         }
      }
      # --- verifie la validite du handler courant
      if {[info exists audace(google_earth,com,handler)]==1} {
         if {($gpids=="")&&($audace(google_earth,com,handler)!="")} {
            # --- quelqu'un a ferme GoogleEarth a la main
            #     on doit fermer le handler
            unset audace(google_earth,com,handler)
         } else {
            return $audace(google_earth,com,handler)
         }
      }
      # --- on lance Google Earth
      if {[info exists audace(google_earth,com,handler)]==0} {
         package require tcom

         set catchError [ catch {
            set audace(google_earth,com,handler) [::tcom::ref createobject "GoogleEarth.ApplicationGE"]
         }]

         if { $catchError != 0 } {
             tk_messageBox -icon info  -message "GoogleEarth.ApplicationGE not found" -title "GoogleEarth" -type ok
             return
         }

         # --- on redonne la main qu'apres l'initialisation
         set t0 [clock seconds]
         set sortie 0
         while {$sortie==0} {
            set dt [expr [clock seconds]-$t0]
            if {$dt<10} {
               after 100
               continue
            }
            set res [$audace(google_earth,com,handler) IsInitialized]
            if {$res==1} {
               set sortie 1
            } else {
               after 500
            }
            if {$dt>15} {
               unset audace(google_earth,com,handler)
               set sortie 1
            }
         }
      }
      if {[info exists audace(google_earth,com,handler)]==1} {
         return $audace(google_earth,com,handler)
      } else {
         return ""
      }
   }
}

proc google_earth_dec { decimal } {
   global audace
   # --- identifie le separateur decimal
   package require registry
   set sep [::registry get "HKEY_USERS\\.default\\Control Panel\\International" sDecimal]
   if {$sep!="."} {
      regsub -all {\.} $decimal $sep res
   } else {
      set res $decimal
   }
   return $res
}

#####################################################################################
# Fonctions pour les utilisateurs
#####################################################################################

proc google_earth_home_goto { {home ""} {param1 ""} {param2 ""} } {
   global audace
   #::console::affiche_resultat "home=$home param1=$param1 param2=$param2\n"
   if {$home=="search"} {
      set h [google_earth_launch]
      if {$h==""} { return "" }
      [$audace(google_earth,com,handler) SearchController] Search $param1
      set sortie 0
      set longitude0 0
      set latitude0 100
      set t0 [clock seconds]
      while {$sortie==0} {
         set dt [expr [clock seconds]-$t0]
         set subh [$audace(google_earth,com,handler) GetCamera 0]
         set longitude [$subh FocusPointLongitude]
         set latitude [$subh FocusPointLatitude]
         if {($longitude==$longitude0)&&($latitude==$latitude0)} {
            set sortie 1
         }
         if {$dt>15} {
            set sortie 1
         }
      }
      set param1 $param2
   } else {
      if {$home==""} {
         set home $audace(posobs,observateur,gps)
      } else {
         set home [mc_home2gps $home]
      }
      set longitude [lindex $home 1]
      set sense     [lindex $home 2]
      if {[string toupper $sense]=="W"} {
         set longitude [expr -1*$longitude]
      }
      set latitude  [lindex $home 3]
      set altitude  [lindex $home 4]
      set h [google_earth_launch]
      if {$h==""} { return "" }
   }
   if {$param1=="moon"} {
      set alt 150000
      set range $alt
   } else {
      set alt 200
      set range 0
   }
   # SetCameraParams <latitude> <longitude> <altitude> <altMode> <range> <tilt> <azimuth> <speed>
   #
   # <latitude>  Latitude en degr�s. Entre -90 et 90.
   # <longitude> Longitude in degr�s. Entre -180 et 180.
   # <altitude>  Altitude en m�tres
   # <altMode>   Le mode d'altitude qui d�fini le point de r�f�rence de celle-ci (1=au sol, 2=absolu)
   # <range>     Distance entre le point focal et la cam�ra en m�tres
   #             If !=0 camera will move backward from range meters along the camera axis
   # <tilt>      Angle d'inclinaison en degr�s. Entre 0 et 90. Vers l'horizon=90, vers le centre de la Terre=0
   # <azimuth>   Azimuth en degr�s. Vers le Nord=0, Est=90, Sud=180, Ouest=270
   # <speed>     Vitesse. Doit �tre >= 0, Si >=5.0 mode t�l�portation
   $audace(google_earth,com,handler) SetCameraParams [google_earth_dec $latitude] [google_earth_dec $longitude] $alt 1 $range 0 0 1
}

proc google_earth_home_coord { } {
   global audace
   set h [google_earth_launch]
   if {$h==""} { return "" }
   set subh [$audace(google_earth,com,handler) GetCamera 0]
   set longitude [$subh FocusPointLongitude]
   if {$longitude<0} {
      set longitude [expr -1*$longitude]
      set sense W
   } else {
      set sense E
   }
   set latitude [$subh FocusPointLatitude]
   set altitude  0
   set home [list GPS $longitude $sense $latitude $altitude]
   return $home
}

proc google_earth_radec_goto { ra {dec 0} } {
   global audace
   set home $audace(posobs,observateur,gps)
   set longitude [lindex $home 1]
   set sense     [lindex $home 2]
   if {[string toupper $sense]=="W"} {
      set longitude [expr -1*$longitude]
   }
   set latitude  [lindex $home 3]
   set altitude  [lindex $home 4]
   set name $ra
   set err [catch {name2coord $name} radec]
   if {$err==1} {
      set ra  [string trim [mc_angle2deg $ra]]
      set dec [string trim [mc_angle2deg $dec 90]]
   } else {
      set ra  [string trim [mc_angle2deg [lindex $radec 0]]]
      set dec [string trim [mc_angle2deg [lindex $radec 1] 90]]
   }
   set ra [expr $ra+180]
   if {$ra>360} {
      set ra [expr $ra-360]
   }
   if {$ra>180} {
      set ra [expr $ra-360]
   }
   set alt 200
   set range 10000
   # SetCameraParams <latitude> <longitude> <altitude> <altMode> <range> <tilt> <azimuth> <speed>
   #
   # <latitude>  Latitude en degr�s. Entre -90 et 90.
   # <longitude> Longitude in degr�s. Entre -180 et 180.
   # <altitude>  Altitude en m�tres
   # <altMode>   Le mode d'altitude qui d�fini le point de r�f�rence de celle-ci (1=au sol, 2=absolu)
   # <range>     Distance entre le point focal et la cam�ra en m�tres
   #             If !=0 camera will move backward from range meters along the camera axis
   # <tilt>      Angle d'inclinaison en degr�s. Entre 0 et 90. Vers l'horizon=90, vers le centre de la Terre=0
   # <azimuth>   Azimuth en degr�s. Vers le Nord=0, Est=90, Sud=180, Ouest=270
   # <speed>     Vitesse. Doit �tre >= 0, Si >=5.0 mode t�l�portation
   set h [google_earth_launch]
   if {$h==""} { return "" }
   #::console::affiche_resultat "\$audace(google_earth,com,handler) SetCameraParams [google_earth_dec $dec] [google_earth_dec $ra] 2 1 1 0 0 1\n"
   $audace(google_earth,com,handler) SetCameraParams [google_earth_dec $dec] [google_earth_dec $ra] $alt 1 $range 0 0 1
}

proc google_earth_radec_coord { } {
   global audace
   set h [google_earth_launch]
   if {$h==""} { return "" }
   set subh [$audace(google_earth,com,handler) GetCamera 0]
   set ra [$subh FocusPointLongitude]
   set ra [expr $ra+180]
   if {$ra>360} {
      set ra [expr $ra-360]
   }
   set dec [$subh FocusPointLatitude]
   return [list $ra $dec]
}

proc google_earth_moon_coord { } {
   return [google_earth_home_coord]
}

proc google_earth_moon_goto { {home ""} {param1 ""} {param2 ""} } {
   global audace
   set command google_earth_home_goto
   if {$home==""} {
      append command " \{$audace(posobs,observateur,gps) moon]\}"
   } else {
      append command " \"$home\""
   }
   if {$param1!=""} {
      append command " \"$param1\""
   }
   if {$param2!=""} {
      append command " \"$param2\""
   }
   append command " moon"
   #::console::affiche_resultat "command=$command\n"
   set res [eval $command]
   return $res
}

