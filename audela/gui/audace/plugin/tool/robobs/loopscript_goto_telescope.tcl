# Script goto_telescope
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# Slew the telescope to the target if robobs(next_scene,action) = "Science images"
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# robobs(next_scene,action) : updated in loopscript_next_scene
# robobs(next_scene,ra) : RA to point the center of the FoV of the camera (degrees J2000)
# robobs(next_scene,dec) : DEC to point the center of the FoV of the camera (degrees J2000) 
# robobs(next_scene,dra) : Drift againt the RA coordinates (deg/sec)
# robobs(next_scene,ddec) : Drift againt the DEC coordinates (deg/sec)
#
# ---------------------------------------
# Output variables :
#
# None
#
# ---------------------------------------


# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

set diurnal [expr 360./(23*3600+56*60+4)]

# === Body of script
if {$robobs(next_scene,action)=="Science images"} {
   set ra $robobs(next_scene,ra) 
   set dec $robobs(next_scene,dec) 
   set dra $robobs(next_scene,dra) 
   set ddec $robobs(next_scene,ddec)
   
   # --- set trackspeed
	if {$robobs(tel,name)!="simulation"} {
	   if {([expr abs($dra-$diurnal)/$diurnal]>0.01)||([expr abs($ddec)/$diurnal]>0.01)} {
		   set err [catch {tel1 speedtrack $dra $ddec} msg]
		   if {$err==0} {
			   ::robobs::log "tel1 speedtrack $dra $ddec"
		   }
	   } else {
		   set err [catch {tel1 speedtrack diurnal $ddec} msg]
		   if {$err==0} {
			   ::robobs::log "tel1 speedtrack diurnal $ddec"
		   }
	   }
   }
   
   # --- goto
   ::robobs::log "tel1 radec goto [list $ra $dec] -blocking 1" 3
   set t0 [clock seconds]
   if {$robobs(tel,name)=="simulation"} {
      after 3000
   } else {
      tel1 radec goto [list $ra $dec] -blocking 1
		set sortie 0
		set radec0 ""
		after 1500
		while {$sortie==0} {
			update
			after 1000
			set radec [tel1 radec coord]
			if {$radec==$radec0} {
				set sortie 1
				break
			}
			set radec0 $radec
		}
   }
   set dt [expr [clock seconds]-$t0]
   ::robobs::log "Telescope slew finished in $dt seconds" 3
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
