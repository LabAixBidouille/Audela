# Script calibration_astrometry
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,afilenames) ""
set bufNo $audace(bufNo)

if {$robobs(planif,mode)=="vttrrlyr"} {
   
   foreach fname $robobs(image,dfilenames) {
		# --- WCS calibration
		set cdpath $robobs(conf,astrometry,cat_folder,value)
		set cattype $robobs(conf,astrometry,cat_name,value)
		set catastar [calibwcs * * * * * $cattype $cdpath]
		::robobs::log "WCS calibration : $catastar stars matched."
      saveima $fname
      lappend robobs(image,afilenames) "$fname"
	}

}

if {$robobs(planif,mode)=="meridian"} {
   
   foreach fname $robobs(image,filenames) {
		# --- WCS calibration
		set cdpath $robobs(conf,astrometry,cat_folder,value)
		set cattype $robobs(conf,astrometry,cat_name,value)
		set catastar [calibwcs * * * * * $cattype $cdpath]
		::robobs::log "WCS calibration : $catastar stars matched."
      saveima $fname
      lappend robobs(image,afilenames) "$fname"
	}

}

if {$robobs(planif,mode)=="geostat1"} {
   
   set fname $robobs(image,dfilenames)
	# --- cosmetique
	#uncosmic 0
	#convgauss 1
	subsky 50 0.4	
	
	# --- Orientation du nord et de l'est
 	buf$bufNo imaseries "INVERT xy"
	buf$bufNo imaseries "INVERT flip"
	saveima i
	
	# --- Filtrage special pour la calibration des images trainees
	set res [buf$bufNo stat]
	set sigma_ciel [lindex $res 7]
	set signal_ciel [lindex $res 6]
	set binmax [expr $signal_ciel+10*$sigma_ciel]
	buf$bufNo clipmax $binmax
	set binmin [expr $binmax-1]
	buf$bufNo clipmin $binmin
	gren_info " Filtrage special pour la calibration des images trainees : clipmax=$binmax et clipmin=$binmin\n"
	buf$bufNo imaseries "CONV sigma=7 kernel_type=gaussian"
	buf$bufNo bitpix float
   buf$bufNo imaseries "FILTER kernel_type=gradleft kernel_width=7"
   buf$bufNo clipmin 0.2
	buf$bufNo mult 10
	buf$bufNo bitpix float			
	saveima j
   
	set cdpath $robobs(conf,astrometry,cat_folder,value)
	set cattype $robobs(conf,astrometry,cat_name,value)
	set catastar [calibwcs * * * * * $cattype $cdpath]
	::robobs::log "WCS calibration : $catastar stars matched."
	
	set tmpkeyws [buf$bufNo getkwds]
	set tmpkeys ""
	foreach keyw $tmpkeyws {
		lappend tmpkeys [buf$bufNo getkwd $keyw]
   }
   
   # --- Recopie les mots clé WCS dans l'image trainée
	loadima prt1
	foreach key $tmpkeys {
		buf$bufNo setkwd $key
   }
   set list_keys [buf$bufNo getkwds]
	
   saveima $fname	
   lappend robobs(image,afilenames) "$fname"

}

if {($robobs(planif,mode)=="snresearch1")&&($robobs(image,dfilenames)!="")} {
   
	# --- WCS calibration
   set fname $robobs(image,ffilenames)
	set cdpath $robobs(conf,astrometry,cat_folder,value)
	set cattype $robobs(conf,astrometry,cat_name,value)
	set catastar [calibwcs * * * * * $cattype $cdpath]
	::robobs::log "WCS calibration : $catastar stars matched."
   saveima $fname
   lappend robobs(image,afilenames) "$fname"

}

if {($robobs(planif,mode)=="asteroid_light_curve")&&($robobs(image,ffilenames)!="")} {
   
   ::robobs::log "WCS calibration : robobs(image,ffilenames)=$robobs(image,ffilenames)"
   foreach fname $robobs(image,ffilenames) {
      ::robobs::log "WCS calibration : fname=$fname"
		# --- WCS calibration
		set cdpath $robobs(conf,astrometry,cat_folder,value)
		set cattype $robobs(conf,astrometry,cat_name,value)
      set err [catch {calibwcs * * * * * $cattype $cdpath} catastar]
      if {$err==0} {
         ::robobs::log "WCS calibration : $catastar stars matched."
      } else {
         ::robobs::log "WCS calibration : calibwcs * * * * * $cattype $cdpath"
         ::robobs::log "WCS calibration : Error = $catastar"
      }
      saveima $fname      
      lappend robobs(image,afilenames) "$fname"
      # --- save a Jpeg for the web site
      if {$robobsconf(webserver)==1} {
         lassign [visu1 cut] sh sb
         buf$bufNo savejpeg $robobsconf(webserver,htdocs)/robobs_last.jpg 60 $sb $sh
      }      
	}

}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
