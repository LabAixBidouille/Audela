# Script light_curve
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

set bufNo $audace(bufNo)

# === Body of script
if {($robobs(planif,mode)=="asteroid_light_curve")&&($robobs(image,ffilenames)!="")} {
	set ffname [lindex $robobs(image,ffilenames) end]
	if {$ffname!=""} {
		loadima $ffname
		set objename [lindex [buf$bufNo getkwd OBJENAME] 1]
		set ra [lindex [buf$bufNo getkwd RA] 1]
		set dec [lindex [buf$bufNo getkwd DEC] 1]		
		### photrel_cat2mes ir $objename $ra $dec C
		::robobs::log "Compute the light curve of $objename."
	}
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
