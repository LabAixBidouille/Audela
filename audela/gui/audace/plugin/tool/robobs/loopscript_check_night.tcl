# Script check_night
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# Read the current date from the computer and the observatory location
# from the configuration variables and computes the following dates to 
# define the skylight condition :
#
# sun-previous-rise < sun-meridian < sun-set < sun-dusk < sun-dawn < sun-next-rise
#
# Then, skylight conditions (Day | Dusk | Night | Dawn) are determined
# comparing the current date to these ones.
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# None
#
# ---------------------------------------
# Output variables :
#
# robobs(private,skylight) = Day | Dusk | Night | Dawn
# robobs(private,sunelev) = elevation of the sun (degrees)
#
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script

# --- Skylight computation
set date [::audace::date_sys2ut]
set jd [mc_date2jd $date]
set home $robobs(conf,home,gps,value)
set elev_sun_set $robobs(conf,skylight,elevsun,value)
set elev_sun_twilight $robobs(conf,skylight,elevsun,value)
set res [mc_nextnight $date $home $elev_sun_set $elev_sun_twilight]
set mer2mer [lindex $res 0]
set rise2rise [lindex $res 1]
set prev_sun_rise [lindex $rise2rise 0]
set mer [lindex $rise2rise 1]
set sun_set [lindex $rise2rise 2]
set dusk [lindex $rise2rise 3]
set dawn [lindex $rise2rise 4]
set next_sun_rise [lindex $rise2rise 5]
if {$jd<$sun_set} {
   set skylight Day
} elseif {$jd<$dusk} {
   set skylight Dusk
} elseif {$jd<$dawn} {
   set skylight Night
} else {
   set skylight Dawn
}
set sunelev [format %.4f [lindex [mc_ephem sun [list $jd] {ALTITUDE} -topo $home] 0]]
set robobs(private,skylight) $skylight
set robobs(private,sunelev) $sunelev
set robobs(private,prev_sun_rise) $prev_sun_rise
set robobs(private,next_sun_rise) $next_sun_rise
set robobs(private,sun_set) $sun_set
if {[expr abs($mer+0.5-round($mer+0.5))]<0.1} {
   set mersecure [expr $mer-0.1]
} else {
   set mersecure $mer
}
set d [mc_date2iso8601 $mersecure]
set robobs(private,nightdate) [string range $d 0 3][string range $d 5 6][string range $d 8 9]

::robobs::log "$step : skylight=$skylight sunelev=$sunelev ($robobs(private,nightdate))" 0

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
