# Script correction_flat
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,ffilenames) ""

set bufNo $audace(bufNo)
set dateobs [mc_date2iso8601 [::audace::date_sys2ut]]

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,dfilenames)!="")} {
   set fflat $robobs(conf_planif,snresearch1,fileflat)
   if {$robobs(cam,name)=="simulation"} {
      if {[file exists $fflat]==0} {
         buf$bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      	set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      	set err1 [catch {eval $commande} msg]
      	set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]
         # --- Complete the FITS header
         set exposure 120
         acq_set_fits_header $exposure
         set comment "Simulated bias"
      	set commande "buf$bufNo setkwd \{ \"COMMENT\" \"$comment\" \"string\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]   
      	set shutter synchro
      	set commande "buf$bufNo setkwd \{ \"SHUTTER\" \"$shutter\" \"string\" \"Shutter action\" \"\" \}"
      	set err1 [catch {eval $commande} msg]	   
         ::robobs::log "Simulate the dark image" 3
         set shut 3
         simulimage * * * * * $robobs(conf,astrometry,cat_name,value) $robobs(conf,astrometry,cat_folder,value) $exposure 3.5 $diamtel R $skylevel 0.07 2.5 12 $shut 0 0 1
         # --- Save the FITS file
         set date [mc_date2iso8601 [::audace::date_sys2ut]]
         set name $fflat
         ::robobs::log "Save image $name" 3
         saveima $name
      }
   }   
   if {[file exists $fflat]==1} {
      buf$bufNo load $fflat
      set mean [lindex [stat] 4]
      buf$bufNo load $robobs(image,dfilenames)
   	set commande "div $fflat $mean"
   	set err1 [catch {eval $commande} msg]
      ::robobs::log "FLAT division ($mean)"
   }
   if {$robobs(conf_planif,snresearch1,smearing)>0} {
   	set commande "unsmear $robobs(conf_planif,snresearch1,smearing)"
   	set err1 [catch {eval $commande} msg]
      ::robobs::log "$commande"
   }
   lappend robobs(image,ffilenames) "$robobs(conf,folders,rep_images,value)/tmp$robobs(conf,fichier_image,extension,value)"
   saveima $robobs(image,ffilenames)
}

if {($robobs(planif,mode)=="asteroid_light_curve")&&($robobs(image,dfilenames)!="")} {
   set robobs(image,ffilenames) ""
   set fbias $robobs(conf_planif,asteroid_light_curve,filebias)
   set fdark $robobs(conf_planif,asteroid_light_curve,filedark)
   set fflat $robobs(conf_planif,asteroid_light_curve,fileflat)
	set valid 1
	if {($fflat=="")} {
		set valid 0
	} else {
		if {[file exists $fflat]==0} {
			set valid 0
		}
	}
	if {$valid==1} {
		foreach dfname $robobs(image,dfilenames) {
			loadima $dfname
			set commande "div $fflat 10000"
			set err1 [catch {eval $commande} msg]
			::robobs::log "FLAT division $dfname by the flat frame $fflat"
			set ffname "$robobs(conf,folders,rep_images,value)/tmp$robobs(conf,fichier_image,extension,value)"
			saveima $ffname
			lappend robobs(image,ffilenames) $ffname
		}
	} else {
		foreach dfname $robobs(image,dfilenames) {
			lappend robobs(image,ffilenames) $robobs(image,dfilenames)
		}
      ::robobs::log "robobs(image,ffilenames)=$robobs(image,ffilenames)"
	}
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
