# Script check_security
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script

# --- Read the meteo sensor handler name
source "$audace(rep_install)/gui/audace/meteosensor_tools.tcl"
if {[info exists robobs(meteo,meteosensor,name)]==1} {
	set name $robobs(meteo,meteosensor,name)
} else {
	set name robobs1
}

# --- Open meteo sensor connection if needed
if {[info exists robobs(meteo,meteosensor,name)]==0} {
	catch { meteosensor_close $name }
	set err [catch {meteosensor_open $robobs(conf,meteostation,type,value) $robobs(conf,meteostation,port,value) $name $robobs(conf,meteostation,params,value)} msg ]
	if {$err==0} {
		set robobs(meteo,meteosensor,name) $name
	} else {
		::robobs::log "RobObs [info script] problem concerning meteosensor_open: $msg" 10
	}
}

# --- Read meteo sensor values
if {[info exists robobs(meteo,meteosensor,jdlastpb)]==0} {
	set robobs(meteo,meteosensor,jdlastpb) [expr [mc_date2jd [::audace::date_sys2ut]]-($robobs(conf,meteostation,delay_security,value)+1)/86400.]
}
#if {[info exists robobs(meteo,global_check)]==0} {
#	set robobs(meteo,global_comment) ""
#	set robobs(meteo,global_check) OK
#}
set robobs(meteo,global_check) OK
set robobs(meteo,global_comment) ""
set type ""
set resmeteos ""
if {[info exists robobs(meteo,meteosensor,name)]==1} {
	set type [meteosensor_type $robobs(meteo,meteosensor,name)]
	set res [meteosensor_getstandard $robobs(meteo,meteosensor,name)]
	set resmeteos $res
	set keys ""
	foreach re $res {
		lappend keys [lindex $re 0]
	}
	# --- 
	set key Humidity
	set value_limit_max $robobs(conf,meteostation,humidity_limit_max,value)
	set k [lsearch -exact $keys $key]
	set value [lindex [lindex $res $k] 1]
	if {$value>=$value_limit_max} { 
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key}: $value >= $value_limit_max)"
	}
	# --- 
	set key SkyCover
	set value_limit_max $robobs(conf,meteostation,cloud_limit_max,value)
	set k [lsearch -exact $keys $key]
	set value [lindex [lindex $res $k] 1]
	if {($value_limit_max=="VeryCloudy")&&($value=="VeryCloudy")} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key} = $value)"
	} elseif {($value_limit_max=="Cloudy")&&(($value=="VeryCloudy")||(($value=="Cloudy")))} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key} = $value)"
	} elseif {($value_limit_max=="Clear")} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key} = $value)"
	}
	# --- 
	set key WindSpeed
	set value_limit_max $robobs(conf,meteostation,wind_limit_max,value)
	set k [lsearch -exact $keys $key]
	set value [lindex [lindex $res $k] 1]
	if {$value>=$value_limit_max} { 
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key}: $value >= $value_limit_max)"
	}
	# --- 
	set key Water
	set value_limit_max $robobs(conf,meteostation,water_limit_max,value)
	set k [lsearch -exact $keys $key]
	set value [lindex [lindex $res $k] 1]
	if {($value_limit_max=="Rain")&&($value=="Rain")} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key} = $value)"
	} elseif {($value_limit_max=="Wet")&&(($value=="Rain")||(($value=="Wet")))} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key} = $value)"
	} elseif {($value_limit_max=="Dry")} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (${key} = $value)"
	}
}
#::robobs::log "meteo check A is $robobs(meteo,global_check) $robobs(meteo,global_comment)" 3
if {$robobs(meteo,global_check)=="PB"} {
	set robobs(meteo,meteosensor,jdlastpb) [mc_date2jd [::audace::date_sys2ut]]
} else {
	set dsec [expr int(86400*([mc_date2jd [::audace::date_sys2ut]]-$robobs(meteo,meteosensor,jdlastpb)))]
	if {$dsec<$robobs(conf,meteostation,delay_security,value)} {
		set robobs(meteo,global_check) PB
		append robobs(meteo,global_comment) " (Only $dsec seconds since the good conditions appeared)"
	}
}
set textes ""
foreach resmeteo $resmeteos {
	set key [lindex $resmeteo 0]
	set val [lindex $resmeteo 1]
	set unit [lindex $resmeteo 2]
	if {$unit=="text"} { set unit "" }
	if {$val=="undefined"} { continue }
	append textes " ${key}=${val} ${unit}."
}
::robobs::log "meteo from $type: $textes" 3
::robobs::log "meteo check is $robobs(meteo,global_check) $robobs(meteo,global_comment)" 3

proc robobs_tel_park {} {
	global robobs
	if {$robobs(planif,mode)=="vttrrlyr"} {
		set hapark [mc_angle2deg 18h]
		set decpark [mc_angle2deg 90d]
	   set hadec [tel1 hadec coord]
	   set ha [lindex $hadec 0]
	   set dec [lindex $hadec 1]
	   set sepangle [lindex [mc_anglesep [list $ha $dec $hapark $decpark]] 0]
	   if {$sepangle>2} {	   
		   ::robobs::log "Separation from park is $sepangle degrees." 3
		   # --- goto hadec park
		   ::robobs::log "tel1 hadec goto [list 18h 90d] -blocking 1" 3
		   set t0 [clock seconds]
		   if {$robobs(tel,name)=="simulation"} {
		      after 3000
		   } else {
		      tel1 hadec goto [list $hapark $decpark] -blocking 1
		   }
		   set dt [expr [clock seconds]-$t0]
		   ::robobs::log "Telescope slew park finished in $dt seconds" 3
	   }		
	}
	if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
		telpark
		::robobs::log "Start park the telescope" 3
		after 5000
	}
}

proc robobs_dome_open {} {
	global robobs
	if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
		set err [ catch {
			set f [open com6 w+] ; # Arduino Mega 2560
			fconfigure $f -mode 38400,n,8,1 -buffering none -blocking 0
			after 1000
			puts -nonewline $f "open\n"
			after 100
			set res [read -nonewline $f]
			close $f
		} msg ]
		::robobs::log "Open the rolling roof." 3
		if {$err==1} {
			::robobs::log "Problem when opening the rolling roof: $msg" 3
		}
		after 1000
	}
}

proc robobs_dome_close {} {
	global robobs
	if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
		set err [ catch {
			set f [open com6 w+] ; # Arduino Mega 2560
			fconfigure $f -mode 38400,n,8,1 -buffering none -blocking 0
			after 1000
			puts -nonewline $f "close\n"
			after 100
			set res [read -nonewline $f]
			close $f
		} msg ]
		::robobs::log "Close the rolling roof." 3
		if {$err==1} {
			::robobs::log "Problem when closing the rolling roof: $msg" 3
		}
		after 1000
	}
}

# --- Check sensors according the skylight (is the dome is opened/closed, the telescope parked, etc.)
if {$skylight=="Night"} {
   if {$robobs(meteo,global_check)=="OK"} {
      # --- Check the dome is opened
		robobs_dome_open
   } else {
      # --- Check the dome is closed
	   robobs_tel_park
		robobs_dome_close
   }
} elseif {$skylight=="Dusk"} {
   if {$robobs(meteo,global_check)=="OK"} {
      # --- Check the dome is closed
	   robobs_tel_park
		robobs_dome_close
   } else {
      # --- Check the dome is closed
	   robobs_tel_park
		robobs_dome_close
   }
} elseif {$skylight=="Dawn"} {
   if {$robobs(meteo,global_check)=="OK"} {
      # --- Check the dome is opened
		robobs_dome_open
   } else {
      # --- Check the dome is closed
	   robobs_tel_park
		robobs_dome_close
   }
} elseif {$skylight=="Day"} {
   # --- Check the dome is closed in any case
	robobs_tel_park
	robobs_dome_close
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
