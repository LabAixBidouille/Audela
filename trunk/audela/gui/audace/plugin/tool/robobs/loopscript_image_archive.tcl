# Script image_archive
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,xfilenames) ""
set bufNo $audace(bufNo)

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,afilenames)!="")} {
   
   set catastar [lindex [buf$bufNo getkwd CATASTAR] 1]
   if {$catastar>=3} {
      set objename [string trim [lindex [buf$bufNo getkwd OBJENAME] 1]]
   	file mkdir "$robobs(conf,folders,rep_images,value)/galtocheck"
      lappend robobs(image,xfilenames) "$robobs(conf,folders,rep_images,value)/galtocheck/${objename}$robobs(conf,fichier_image,extension,value)"
   	::robobs::log "Archive $robobs(image,xfilenames)"
      saveima $robobs(image,xfilenames)
	}

}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
