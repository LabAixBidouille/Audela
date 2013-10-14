# Script next_scene
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# According the the slylight and meteo conditions, determines the 
# next scene to observe. In this script, you can defines the scheduling
# strategy of the observations.
#
# If skylight = Day, it is recommended to check if the telescope
# is parked. If not, do that.
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# robobs(private,skylight) : updated in loopscript_check_night
# robobs(private,sunelev) : updated in loopscript_check_night
# robobs(tel,name) : updated in loopscript_check_telescope
#
# ---------------------------------------
# Output variables :
#
# robobs(next_scene,action) = Nothing | Science images | Calibration images (Flats bias darks)
# robobs(next_scene,ra) = RA to point the center of the FoV of the camera (degrees J2000)
# robobs(next_scene,dec) = DEC to point the center of the FoV of the camera (degrees J2000) 
# robobs(next_scene,dra) = Drift againt the RA coordinates (deg/sec)
# robobs(next_scene,ddec) = Drift againt the DEC coordinates (deg/sec)
# robobs(next_scene,images) = Image sequence definition {filename exposure shutter filter comment}
#
# ---------------------------------------

#   set robobs(planif,modes) {personal vttrrlyr meridian}

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set skylight $robobs(private,skylight)
set sunelev $robobs(private,sunelev)
set date [::audace::date_sys2ut]
set jd [mc_date2jd $date]
set home $robobs(conf,home,gps,value)
set diurnal [expr 360./(23*3600+56*60+4)]
set dra $diurnal
set ddec 0

set robobs(next_scene,action) "Nothing"
set robobs(next_scene,images) ""

proc obsconditions { coords home jd } {
   global robobs
   set ra [lindex $coords 0]
   set dec [lindex $coords 1]   
   set res [mc_radec2altaz $ra $dec $home $jd]
   set az [lindex $res 0]
   set elev [lindex $res 1]
   set ha [lindex $res 2]
   set valid 1
   # --- angle d'elevation limite
   if {$elev<$robobs(conf,security_angles,elev_min,value)} {
      set robobs(next_scene,action) "No observation to do"
      ::robobs::log "Elevation $elev too low (<$robobs(conf,security_angles,elev_min,value))"
      set valid 0
      return [list $valid -50]
   } elseif {$elev>$robobs(conf,security_angles,elev_max,value)} {
      set robobs(next_scene,action) "No observation to do"
      ::robobs::log "Elevation $elev too high (>$robobs(conf,security_angles,elev_min,value))"
      set valid 0
      return [list $valid -50]
   }
   # --- tester les autres angles limites
   # --- ligne d'horizon
   set sequence [list  [list [list ELEV 0] [list AXE_0 now $ra $dec] ] ]
   set echt 60.
   mc_obsconditions $jd $home $sequence [expr $echt/86400] "test.txt" ALTAZ $robobs(conf,local_horizon,altaz,value)
   set f [open "test.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set ligne [lindex $lignes 0]
   set jd0 [lindex $ligne 0]
   set index [expr int(floor(($jd-$jd0)*86400./$echt))]
   set ligne [lindex $lignes $index]
   set skylevel [lindex $ligne 12]
   if {$skylevel<$robobs(conf,skylight,skybrightness,value)} {
      set valid 0
   }
   ::robobs::log "At [mc_date2iso8601 [lindex [lindex $lignes $index] 0]], skylevel=$skylevel, az=[format %.1f $az] elev=[format %.1f $elev] ha=[format %.1f $ha]"
   set skylevel [expr $skylevel-4.]
   return [list $valid $skylevel]
}

if {$skylight=="Night"} {
   
   if {$robobs(planif,mode)=="meridian"} {
      # === MERIDIAN
      set res [mc_altaz2radec 0 80 $home $jd]
      set ra [lindex $res 0]
      set dec [lindex $res 1]   
      set dra $diurnal
      set ddec 0.00
      lappend robobs(next_scene,images) {{name meridian} {exposure 120} {shutter_mode synchro} {filter_name C} {comment "meridian"}}
      set robobs(next_scene,action) "Science images"
      set robobs(next_scene,ra) "$ra"
      set robobs(next_scene,dra) "$dra"
      set robobs(next_scene,dec) "$dec"
      set robobs(next_scene,ddec) "$ddec"

   } elseif {$robobs(planif,mode)=="vttrrlyr"} {
      # === VTT RRLYR
      set object_name rrlyr
      set coords [list 19h25m28s +42d47m05s]
      set exposure 30
      ::robobs::log "Try $object_name"
      set res [obsconditions $coords $home $jd]
      set valid [lindex $res 0]
      #set valid 0 ; # debug
      if {$valid==0} {
	      set object_name ttlyn
	      set coords [list 09h03m07.9s +44d35m08.5s]
	      set exposure 60
	      ::robobs::log "Try $object_name"
	      set res [obsconditions $coords $home $jd]
	      set valid [lindex $res 0]
      }
      if {$valid==0} {
	      set object_name arper
	      set coords [list 04h17m17.2s +47d24m00.6s]
	      set exposure 60
	      ::robobs::log "Try $object_name"
	      set res [obsconditions $coords $home $jd]
	      set valid [lindex $res 0]
      }
      set skylevel [lindex $res 1]
      set ra [string trim [mc_angle2deg [lindex $coords 0]]]
      set dec [string trim [mc_angle2deg [lindex $coords 1] 90]]
      # ---
      if {$valid==1} {
         if {[info exists robobs(next_scene,shutter_synchro)]==0} {
            set robobs(next_scene,shutter_synchro) 0
         }
         incr robobs(next_scene,shutter_synchro)
         if {$robobs(next_scene,shutter_synchro)>5} {
            lappend robobs(next_scene,images) [list [list name dark$object_name] [list exposure $exposure] {shutter_mode closed} {filter_name C} {comment "Dark"} {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] ]
            set robobs(next_scene,shutter_synchro) 0
         } else {
            lappend robobs(next_scene,images) [list [list name $object_name] [list exposure $exposure] {shutter_mode synchro} {filter_name C} [list comment "$object_name $robobs(next_scene,shutter_synchro)"] {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] ]
         }
         set robobs(next_scene,action) "Science images"
         set robobs(next_scene,ra) "$ra"
         set robobs(next_scene,dra) "$dra"
         set robobs(next_scene,dec) "$dec"
         set robobs(next_scene,ddec) "$ddec"
      }
      
   } elseif {$robobs(planif,mode)=="geostat1"} {
      # === Geostat
      set valid 1
		set date [mc_date2jd [::audace::date_sys2ut now]]
      set res [mc_earthshadow $date $home 1.0]
		set pointages [lindex $res 6]
		set ra_w [lindex $pointages 0]
		set ra_e [lindex $pointages 1]
		set dec [lindex $pointages 2]
		set ra  [mc_angle2hms [expr $ra_w-0.0] 360 zero 1 auto string]
		set dec [mc_angle2dms [expr $dec-0.25] 90 zero 0 + string]
      set coords [list $ra $dec]
      set res [obsconditions $coords $home $jd]
      set valid [lindex $res 0]
      set skylevel [lindex $res 1]
      set ra [string trim [mc_angle2deg [lindex $coords 0]]]
      set dec [string trim [mc_angle2deg [lindex $coords 1] 90]]
		set dra 0
		set ddec 0      
      # ---
      if {$valid==1} {
         lappend robobs(next_scene,images) [list {name geo} {exposure 30} {shutter_mode synchro} {filter_name C} [list comment "GEO"] {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] ]
         lappend robobs(next_scene,images) [list {name dark} {exposure 30} {shutter_mode closed} {filter_name C} {comment "Dark"} {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] ]
         set robobs(next_scene,action) "Science images"
         set robobs(next_scene,ra) "$ra"
         set robobs(next_scene,dra) "$dra"
         set robobs(next_scene,dec) "$dec"
         set robobs(next_scene,ddec) "$ddec"
      }
      
   } elseif {$robobs(planif,mode)=="snresearch1"} {
      # === SN searching
      set valid 1
      if {[file exists $robobs(conf_planif,snresearch1,filegals)]==0} {
         # --- traiter le cas d'un fichier sn.txt manquant
      }
      if {[info exists robobs(planif,snresearch1,fields)]==0} {      
         ::robobs::log "Read fields in the file [file tail $robobs(conf_planif,snresearch1,filegals)]"
         set f [open $robobs(conf_planif,snresearch1,filegals) r]
         set lignes [split [read $f] \n]
         close $f
         set robobs(planif,snresearch1,fields) ""
         set k 0
         foreach ligne $lignes {
            if {[llength $ligne]<8} { continue }
            set name [lindex $ligne 0]            
            set ra [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
            set dec [mc_angle2deg [lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s 90]
            set mag [lindex $ligne 7]
            set observed 0
            if {$mag<$robobs(conf_planif,snresearch1,magliminf)} {set observed -1}
            if {$mag>$robobs(conf_planif,snresearch1,maglimsup)} {set observed -1}            
            if {$observed==0} { incr k }
            lappend robobs(planif,snresearch1,fields) [list $name $ra $dec $mag $observed]
         }
         # --- sort by increased RA
         set robobs(planif,snresearch1,fields) [lsort -index 1 $robobs(planif,snresearch1,fields)]
         ::robobs::log "$k fields in the file [file tail $robobs(conf_planif,snresearch1,filegals)]"
      }
      # --- dha
      set ha_set  [expr fmod($robobs(conf,security_angles,ha_set,value)+720,360)]
      set ha_rise [expr fmod($robobs(conf,security_angles,ha_rise,value)+720,360)]
      if {$ha_set>=$ha_rise} {
         set ha_set 179.9
         set ha_rise 180.1
      }
      # --- number of fields to observe
      set nf [llength $robobs(planif,snresearch1,fields)]
      # --- local sideral time
      set ts [mc_date2lst $jd $home -format deg]
      # --- RA for set
      set ha $ha_set
      set ramin [expr fmod($ts-$ha+720,360)]
      # --- kmin = index corresponding to RA for set
      set ra $ramin
      set kdeb 0
      set kfin [expr $nf-1]
      set kmed -1
      set sortie 0
      while {$sortie==0} {
         set kmed [expr ($kdeb+$kfin)/2]
         set ramed [lindex [lindex $robobs(planif,snresearch1,fields) $kmed] 1]
         #::robobs::log "A kdeb=$kdeb kmed=$kmed kfin=$kfin ($ra $ramed)"
         if {$kmed==$kdeb} { set sortie 1 }
         if {$kmed==$kfin} { set sortie 1 }
         if {$ra<$ramed} { 
            set kfin $kmed
         } elseif {$ra>=$ramed} { 
            set kdeb $kmed 
         }
      }
      set kmin $kmed
      if {[info exists robobs(planif,snresearch1,kobs)]==1} {
         set kmin $robobs(planif,snresearch1,kobs)
      }            
      # --- RA for rise
      set ha $ha_rise
      set ramax [expr fmod($ts-$ha+720,360)]
      # --- kmax = index corresponding to RA for rise
      set ra $ramax
      set kdeb 0
      set kfin [expr $nf-1]
      set kmed -1
      set sortie 0
      while {$sortie==0} {
         set kmed [expr ($kdeb+$kfin)/2]
         set ramed [lindex [lindex $robobs(planif,snresearch1,fields) $kmed] 1]
         #::robobs::log "B kdeb=$kdeb kmed=$kmed kfin=$kfin ($ra $ramed)"
         if {$kmed==$kdeb} { set sortie 1 }
         if {$kmed==$kfin} { set sortie 1 }
         if {$ra<$ramed} { 
            set kfin $kmed
         } elseif {$ra>=$ramed} { 
            set kdeb $kmed 
         }
      }
      set kmax $kmed
      ::robobs::log "ramin=$ramin ramax=$ramax"
      ::robobs::log "kmin=$kmin kmax=$kmax"
      # --- Loop over the observable fields
      while {1==1} {
         # --- select the observed==0 field the nearest of the set HA limit
         set kobs -1
         set k1 $kmin
         if {$kmax>=$kmin} { 
            set k2 $kmax 
         } else { 
            set k2 [expr $nf-1] 
         }
         #::robobs::log "=== A k1=$k1 k2=$k2"
         for {set k $k1} {$k<=$k2} {incr k} {
            set observed [lindex [lindex $robobs(planif,snresearch1,fields) $k] 4]
            #::robobs::log "A k=$k observed=$observed"
            if {$observed==0} {
               set kobs $k
               break
            }
         }
         if {($kobs==-1)&&($kmax<$kmin)} {
            set k1 0
            set k2 $kmax
            #::robobs::log "=== B k1=$k1 k2=$k2"
            for {set k $k1} {$k<=$k2} {incr k} {
               set observed [lindex [lindex $robobs(planif,snresearch1,fields) $k] 4]
               #::robobs::log "B k=$k observed=$observed"
               if {$observed==0} {
                  set kobs $k
                  break
               }
            }         
         }
         if {$kobs==-1} {
            # --- pas de galaxies à observer en ce moment
            ::robobs::log "No field observable at this time"
            set valid 0
            break
         }
         # ---
         set robobs(planif,snresearch1,kobs) $kobs
         set field [lindex $robobs(planif,snresearch1,fields) $kobs]
         ::robobs::log "Check observability of $field"
         set name [lindex $field 0]
         set ra   [lindex $field 1]
         set dec  [lindex $field 2]
         set coords [list $ra $dec]
         set res [obsconditions $coords $home $jd]
         set valid [lindex $res 0]
         set skylevel [lindex $res 1]
         #::robobs::log "valid=$valid k=$k kmin=$kmin"
         if {$valid==0} {
            set kmin [expr $k+1]
            continue
         }
         # --- valid==1
         for {set k 1} {$k<=$robobs(conf_planif,snresearch1,nbimages)} {incr k} {         
            lappend robobs(next_scene,images) [list [list name ${robobs(planif,mode)}_$name] [list exposure $robobs(conf_planif,snresearch1,exposure)] [list shutter_mode synchro] {filter_name C} [list comment "$name image $k / $robobs(conf_planif,snresearch1,nbimages)"] {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] [list binx $robobs(conf_planif,snresearch1,binning)] [list biny $robobs(conf_planif,snresearch1,binning)] ]
         }
         set res [lindex $robobs(next_scene,images) end]
         ::robobs::log "[lindex $res 4]"
         set robobs(next_scene,action) "Science images"
         set robobs(next_scene,ra) "$ra"
         set robobs(next_scene,dra) "$dra"
         set robobs(next_scene,dec) "$dec"
         set robobs(next_scene,ddec) "$ddec"
         break
      }
		
   } elseif {$robobs(planif,mode)=="asteroid_light_curve"} {
      # === 3 objects light curve
      set valid 0
      if {[info exists robobs(planif,asteroid_light_curve,index_last_field)]==0} {      
			set robobs(planif,asteroid_light_curve,index_last_field) 1
		}
		#::robobs::log "A robobs(planif,asteroid_light_curve,index_last_field)=$robobs(planif,asteroid_light_curve,index_last_field)" 3
		set kk [expr $robobs(planif,asteroid_light_curve,index_last_field)-1]
		for {set k 1} {$k<=3} {incr k} {
			incr kk
			if {$kk>3} {
				set kk 1
			}
			#::robobs::log "A k=$k kk=$kk" 3
			set name "$robobs(conf_planif,asteroid_light_curve,object_name$kk)"
			set coord "$robobs(conf_planif,asteroid_light_curve,object_coord$kk)"
			# --- resolveur de nom
			set radec ""
			if {$name!=""} {
				set n [llength $coord]
				if {$n==6} {
					set radec "[lindex $coord 0]h[lindex $coord 1]m[lindex $coord 2]s [lindex $coord 3]d[lindex $coord 4]m[lindex $coord 5]s 0 0"
				} elseif {$n==2} {
					set radec "[lindex $coord 0] [lindex $coord 1] 0 0"
				} else {
					set err [catch {name2coord $name -drift} radec]
					if {$err==1} {
						set err [catch {vo_getmpcephem $name $jd $home} res]
						if {$err==0} {
							set res [lindex $res 0]
							set a [lindex $res 0]
							regsub -all \\( $a "" b ; set a $b
							regsub -all \\) $a "" b ; set a $b
							regsub -all " " $a _ b ; set a $b
							set name $a
							set ra [lindex $res 2]
							set dec [lindex $res 3]
							set dra [lindex $res 4]
							set ddec [lindex $res 5]
							set radec [list $ra $dec $dra $ddec]						
						} else {
							::robobs::log "name=$name coordinates not found."
							continue
						}				
					}
				}
				#::robobs::log "radec A = $radec"
				set coords [lrange $radec 0 1]
				set res [obsconditions $coords $home $jd]
				set valid [lindex $res 0]
				set skylevel [lindex $res 1]
				::robobs::log "name=$name kk=$kk $coords valid=$valid skylevel=[format %.2f $skylevel]"
				if {$valid==0} {
					continue
				} else {
					# --- valid==1
					set valid 1
					lassign $radec ra dec dra ddec
					set dra 0
					set ddec 0
					for {set k 1} {$k<=$robobs(conf_planif,asteroid_light_curve,nbimages)} {incr k} {         
						lappend robobs(next_scene,images) [list [list name cdl_$name] [list exposure $robobs(conf_planif,asteroid_light_curve,exposure)] [list shutter_mode synchro] {filter_name C} [list comment "$name image $k / $robobs(conf_planif,asteroid_light_curve,nbimages)"] {simunaxis1 768} {simunaxis2 512} [list skylevel $skylevel] [list binx $robobs(conf_planif,asteroid_light_curve,binning)] [list biny $robobs(conf_planif,asteroid_light_curve,binning)] ]
					}
					set res [lindex $robobs(next_scene,images) end]
					#::robobs::log "[lindex $res 4]"
					set robobs(next_scene,action) "Science images"
					set robobs(next_scene,ra) "$ra"
					set robobs(next_scene,dra) "$dra"
					set robobs(next_scene,dec) "$dec"
					set robobs(next_scene,ddec) "$ddec"
					break
				}				
			}
		}
		set robobs(planif,asteroid_light_curve,index_last_field) $kk
		#::robobs::log "AA robobs(planif,asteroid_light_curve,index_last_field)=$robobs(planif,asteroid_light_curve,index_last_field)" 3		
		if {$valid==0} {
			# --- pas d'objet à observer en ce moment
			::robobs::log "No field observable at this time"
			set valid 0
			break
		}
		
   }
} elseif {$skylight=="Dawn"} {
   set robobs(next_scene,action) "Calibration images (Flats bias darks)"
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
