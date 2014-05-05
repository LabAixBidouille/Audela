# Script correction_cosmetic
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
   ::robobs::log "Corrections cosmetic : robobs(image,ffilenames)=$robobs(image,ffilenames)"
   foreach fname $robobs(image,ffilenames) {
      buf$bufNo load $fname
		# --- cosmetic
      set naxis1 [buf$bufNo getpixelswidth]
      set naxis2 [buf$bufNo getpixelsheight]
      set camera [lindex [buf$bufNo getkwd CAMERA] 1]
      set camera [lrange $camera 0 1]
      if {$camera=="SBIG ST-L-11K"} {
         set x1 1
         set x2 $naxis1
         set y1 2
         set y2 [expr $naxis2-7]
         set box [list $x1 $y1 $x2 $y2]
         ::robobs::log "Corrections cosmetic : fname=$fname window=$box"
         buf$bufNo window $box
      }
      buf$bufNo save $fname
   }
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
