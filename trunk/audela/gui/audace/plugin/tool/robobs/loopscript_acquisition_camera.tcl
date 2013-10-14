# Script acquisition_camera
# This script will be sourced in the loop
# ---------------------------------------
# Goal of the script :
#
# According to the scene to observe, starts a camera acquisition.
#
# In the case of science image acquisition, the script wait the
# end of exposure and updates the FITS header with the maximum of
# informations.
# 
# ---------------------------------------
# Input variables, other than robobs(conf,*) :
#
# robobs(cam,name) : updated in loopscript_check_camera
# robobs(next_scene,action) : updated in loopscript_next_scene
# robobs(next_scene,ra) : RA to point the center of the FoV of the camera (degrees J2000)
# robobs(next_scene,dec) : DEC to point the center of the FoV of the camera (degrees J2000) 
# robobs(next_scene,dra) : Drift againt the RA coordinates (deg/sec)
# robobs(next_scene,ddec) : Drift againt the DEC coordinates (deg/sec)
#
# ---------------------------------------
# Output variables :
#
# robobs(image,filename) = File name of the last image taken during this script
#
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set robobs(image,filenames) ""

set pi [expr 4*atan(1)]

proc acq_set_fits_header { exposure } {
   global robobs audace
   set camNo $robobs(conf,camera,camno,value)
   set bufNo $audace(bufNo)
   # --- Complete the FITS header
   set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
   set pi [expr 4*atan(1)]
   set ra [mc_angle2deg $robobs(next_scene,ra) ]
   set dec [mc_angle2deg $robobs(next_scene,dec) 90]
   set dra $robobs(next_scene,dra) 
   set ddec $robobs(next_scene,ddec)
	set longitude [lindex $robobs(conf,home,gps,value) 1]
	set sens [lindex $robobs(conf,home,gps,value) 2]
	if {$sens=="W"} {
		set longitude [expr -1.*$longitude]
	}
	set latitude [lindex $robobs(conf,home,gps,value) 3]
	set altitude [lindex $robobs(conf,home,gps,value) 4]
   set mjd [expr [mc_date2jd [lindex [buf$bufNo getkwd DATE-OBS] 1 ]]-2400000.5]
   if {$robobs(cam,name)=="simulation"} {
	   set pixsize1 9
	   set pixsize2 9
   } else {
	   set commande "lindex \[cam$camNo pixdim\] 0"
	   set err1 [catch {eval $commande} msg]
	   set pixsize1 [expr (1e6*$msg)]
	   set commande "lindex \[cam$camNo pixdim\] 1"
	   set err1 [catch {eval $commande} msg]
	   set pixsize2 [expr (1e6*$msg)]
   }
   set foclen $robobs(conf,optic,foclen,value)
   set diamtel $robobs(conf,optic,diam,value)
   set cdelt1 [expr -2*atan($pixsize1*1e-6/$foclen/2.)*180/$pi]
   set cdelt2 [expr  2*atan($pixsize2*1e-6/$foclen/2.)*180/$pi]
   set crota2 0
   set crpix1 [expr $naxis1/2]
   set crpix2 [expr $naxis2/2]
   # --- observing conditions
	set commande "buf$bufNo setkwd \{ \"EXPOSURE\" \"$exposure\" \"string\" \"Total time of exposure\" \"s\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"MJD-OBS\" \"$mjd\" \"double\" \"Start of exposure JD-2400000.5\" \"d\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"TRACKSPA\" \"$dra\" \"double\" \"Tracking for HA\" \"deg/s\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"TRACKSPD\" \"$ddec\" \"double\" \"Tracking for DEC\" \"deg/s\" \}"
	set err1 [catch {eval $commande} msg]
	# --- Observatory location
	set commande "buf$bufNo setkwd \{ \"OBS-LONG\" \"$longitude\" \"float\" \"east-positive observatory longitude\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"OBS-LAT\" \"$latitude\" \"float\" \"geodetic observatory latitude\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"OBS-ELEV\" \"$altitude\" \"float\" \"elevation above sea of observatory\" \"m\" \}"
	set err1 [catch {eval $commande} msg]
	# --- WCS classique
	set commande "buf$bufNo setkwd \{ \"RADESYS\" \"FK5\" \"string\" \"Mean Place IAU 1984 system\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"EQUINOX\" \"2000\" \"string\" \"System of equatorial coordinates\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CTYPE1\" \"RA---TAN\" \"string\" \"Gnomonic projection\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CTYPE2\" \"DEC--TAN\" \"string\" \"Gnomonic projection\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"LONPOLE\" \"180\" \"float\" \"Long. of the celest.NP in native coor.sys\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CUNIT1\" \"deg\" \"string\" \"Angles are degrees always\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CUNIT2\" \"deg\" \"string\" \"Angles are degrees always\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"RADESYS\" \"FK5\" \"string\" \"Mean Place IAU 1984 system\" \"\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CRPIX1\" \"$crpix1\" \"double\" \"X ref pixel\" \"pixel\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CRPIX2\" \"$crpix2\" \"double\" \"Y ref pixel\" \"pixel\" \}"
	set err1 [catch {eval $commande} msg]	
	set commande "buf$bufNo setkwd \{ \"CRVAL1\" \"$ra\" \"double\" \"RA for CRPIX1\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CRVAL2\" \"$dec\" \"double\" \"DEC for CRPIX2\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]	
	set commande "buf$bufNo setkwd \{ \"CDELT1\" \"$cdelt1\" \"double\" \"Scale along axis 1\" \"deg/pix\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CDELT2\" \"$cdelt2\" \"double\" \"Scale along axis 2\" \"deg/pix\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"CROTA2\" \"$crota2\" \"double\" \"Position angle of North\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]
	# --- WCS etendu
	set commande "buf$bufNo setkwd \{ \"RA\" \"$ra\" \"double\" \"Expected RA asked to telescope\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"DEC\" \"$dec\" \"double\" \"Expected DEC asked to telescope\" \"deg\" \}"
	set err1 [catch {eval $commande} msg]	
	set commande "buf$bufNo setkwd \{ \"PIXSIZE1\" \"$pixsize1\" \"float\" \"Pixel size along naxis1\" \"um\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"PIXSIZE2\" \"$pixsize2\" \"float\" \"Pixel size along naxis2\" \"um\" \}"
	set err1 [catch {eval $commande} msg]
	set commande "buf$bufNo setkwd \{ \"FOCLEN\" \"$foclen\" \"double\" \"Focal length\" \"m\" \}"
	set err1 [catch {eval $commande} msg]   
}

if {$robobs(next_scene,action)=="Science images"} {

   set camNo $robobs(conf,camera,camno,value)
   set bufNo $audace(bufNo)
      
   # --- Loop over the images of this scene
   ::robobs::log "[llength $robobs(next_scene,images)] scenes to observe"
   foreach imagedefs $robobs(next_scene,images) {
   
      # --- default values
      set binx 1         
      set biny 1
      set shutter synchro
      set exposure 120
      set object_name not_defined
      set comment ""
      set simunaxis1 400
      set simunaxis2 300
      set skylevel 17
      set filter_name C
         
      # --- specified values
      foreach imagedef $imagedefs {
         
         set key [lindex $imagedef 0]
         set val [lindex $imagedef 1]
         
         if {$key=="name"} { set object_name $val }
         if {$key=="exposure"} { set exposure $val }
         if {$key=="shutter_mode"} { set shutter $val }
         if {$key=="filter"} { set filter_name $val }
         if {$key=="binx"} { set binx $val }
         if {$key=="biny"} { set biny $val }
         if {$key=="comment"} { set comment $val }
         if {$key=="simunaxis1"} { set simunaxis1 $val }
         if {$key=="simunaxis2"} { set simunaxis2 $val }
         if {$key=="skylevel"} { set skylevel $val }
         
      }
      ::robobs::log "Scene $object_name"

      # --- Stop the current image 
      set command "cam$camNo stop"
      ::robobs::log "$command" 3
      if {$robobs(cam,name)!="simulation"} {
         set err [catch {uplevel #0 "$command"} msg]
         if {$err==1} {
            ::robobs::log "$step ERROR $msg" 3
            error $msg
         }
      }
      
      # --- Set the binning   
      set command "cam$camNo bin \[list $binx $biny\]"
      ::robobs::log "$command" 3
      if {$robobs(cam,name)!="simulation"} {
         set err [catch {uplevel #0 "$command"} msg]
         if {$err==1} {
            ::robobs::log "$step ERROR $msg" 3
            error $msg
         }
      }
      
      # --- Set the exposure time
      set command "cam$camNo exptime $exposure"
      ::robobs::log "$command" 3
      if {$robobs(cam,name)!="simulation"} {
         set err [catch {uplevel #0 "$command"} msg]
         if {$err==1} {
            ::robobs::log "$step ERROR $msg" 3
            error $msg
         }
      }
      
      # --- Select the shutter mode
      set command "cam$camNo shutter $shutter"
      ::robobs::log "$command" 3
      if {$robobs(cam,name)!="simulation"} {
         set err [catch {uplevel #0 "$command"} msg]
         if {$err==1} {
            ::robobs::log "$step ERROR $msg" 3
            error $msg
         }
      }
    
      # --- Start the exposure
      set dateobs [mc_date2iso8601 [::audace::date_sys2ut]]
      set command "cam$camNo acq"
      ::robobs::log "$command" 3
      if {$robobs(cam,name)!="simulation"} {
         set err [catch {uplevel #0 "$command"} msg]
	      ::robobs::log "acquisition launched $msg"
         if {$err==1} {
            ::robobs::log "$step ERROR $msg" 3
            error $msg
         }
      }
   
      # --- Wait the end of the exposure
   	set t0 [clock seconds]
   	set timeout [expr $exposure+30.] ; # TODO replace 30 by readouttime+delay
   	set sortie 0
   	while {$sortie==0} {
   		set dt [expr [clock seconds]-$t0]
         if {$robobs(cam,name)=="simulation"} {
   		   set ti [expr $exposure-$dt]
   	   } else {
   	   	set ti [cam$camNo timer]
   	   }
         ::robobs_acquisition::state_loop "$step ($dt seconds)"
   	   ::robobs::log "timer=$ti [format %.0f [expr abs($dt)]] sec. (timeout=$timeout sec.)" 40
			update
   	   after 1000
         # --- Check for a normal end of acquisition
   		if {$ti==-1} {
   			set sortie 1
   		}
         # --- Check for a timeout
   		if {$dt>$timeout} {
   			set sortie 1
   		}
         # --- Check for a premature signal to exit the steps
         if {[::robobs_acquisition::signal_loop]==1} {
            ::robobs::log "$step EXIT_LOOP signal" 3
            return ""
         }
         update
   		
   	}
      ::robobs::log "Acquisition complete in [format %.1f $dt] sec. Exposure asked : $exposure" 3
   
      # --- Simulation of the image if needed
      if {$robobs(cam,name)=="simulation"} {
         buf$bufNo new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
      	set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
      	set err1 [catch {eval $commande} msg]
      	set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]
      }
      
      # --- Complete the FITS header
      acq_set_fits_header $exposure
   	if {$comment!=""} {
      	set commande "buf$bufNo setkwd \{ \"COMMENT\" \"$comment\" \"string\" \"\" \"\" \}"
      	set err1 [catch {eval $commande} msg]   
   	}
   	set commande "buf$bufNo setkwd \{ \"OBJENAME\" \"$object_name\" \"string\" \"\" \"\" \}"
   	set err1 [catch {eval $commande} msg]   	
   	set commande "buf$bufNo setkwd \{ \"FILTER\" \"$filter_name\" \"string\" \"Filter symbol\" \"\" \}"
   	set err1 [catch {eval $commande} msg]
   	set commande "buf$bufNo setkwd \{ \"SHUTTER\" \"$shutter\" \"string\" \"Shutter action\" \"\" \}"
   	set err1 [catch {eval $commande} msg]	   
      
      # --- Simulation of the image if needed
      set diamtel $robobs(conf,optic,diam,value)
      if {$robobs(cam,name)=="simulation"} {
         ::robobs::log "Simulate the image" 3
         set shut 1
         if {$shutter=="closed"} { set shut 0 }
         set newstar ""
			if {($robobs(planif,mode)=="vttrrlyr")&&($shutter!="closed")} {
				if {$object_name=="rrlyr"} {
					# hjdmax = 2442923.49+0.56683500*$e-1e-10*$e*$e
					set ra0 291.365878 ; set dec0 42.783933
					set hjd [lindex [mc_dates_ut2bary $dateobs $ra0 $dec0 J2000] 0]
					set a -1e-10 ; set b 0.56683500 ; set c [expr 2442923.49-$hjd]
					set d [expr $b*$b-4.*$a*$c]
					set e [expr (-$b + sqrt($d) ) / (2.*$a)]
					set phase [expr $e-floor($e)]
					set four_c 7.55
					set four_a(1) -0.098 ; set four_b(1)  0.168
					set four_a(2)  0.099 ; set four_b(2) -0.008
					set four_a(3) -0.050 ; set four_b(3) -0.035
					set four_a(4)  0.011 ; set four_b(4)  0.032
					set four_a(5)  0.001 ; set four_b(5) -0.019
	            set mag $four_c
	            set phase0 [expr $phase-0.29]
	            for {set kk 1} {$kk<=5} {incr kk} {
	               set mag [expr $mag + 1.7*($four_a($kk)*cos(2*$pi*$kk*$phase0) + $four_b($kk)*sin(2*$pi*$kk*$phase0))]
	            }				
					set newstar " REPLACE $ra0 $dec0 $mag"
				} else {
					# --- for other rrlyr stars
				   set ra0 [mc_angle2deg $robobs(next_scene,ra) ]
				   set dec0 [mc_angle2deg $robobs(next_scene,dec) 90]
					set hjd [lindex [mc_dates_ut2bary $dateobs $ra0 $dec0 J2000] 0]
					set a -1e-10 ; set b 0.56683500 ; set c [expr 2442923.49+$b/2.-$hjd]
					set d [expr $b*$b-4.*$a*$c]
					set e [expr (-$b + sqrt($d) ) / (2.*$a)]
					set phase [expr $e-floor($e)]
					set four_c 9.55
					set four_a(1) -0.098 ; set four_b(1)  0.168
					set four_a(2)  0.099 ; set four_b(2) -0.008
					set four_a(3) -0.050 ; set four_b(3) -0.035
					set four_a(4)  0.011 ; set four_b(4)  0.032
					set four_a(5)  0.001 ; set four_b(5) -0.019
	            set mag $four_c
	            set phase0 [expr $phase-0.29]
	            for {set kk 1} {$kk<=5} {incr kk} {
	               set mag [expr $mag + 1.7*($four_a($kk)*cos(2*$pi*$kk*$phase0) + $four_b($kk)*sin(2*$pi*$kk*$phase0))]
	            }				
					set newstar " REPLACE $ra0 $dec0 $mag"
				}
			}
         set toeval "simulimage * * * * * \"$robobs(conf,astrometry,cat_name,value)\" \"$robobs(conf,astrometry,cat_folder,value)\" $exposure 3.5 $diamtel R $skylevel 0.07 2.5 12 $shut 1000 0.5 0.6 0.85 1 1 $newstar"
         eval $toeval
      } else {
			::audace::autovisu $::audace(visuNo)
      }
      
      # --- Save the FITS file
      set date [mc_date2iso8601 [::audace::date_sys2ut]]
      set name IM_[string range $date 0 3][string range $date 5 6][string range $date 8 9]_[string range $date 11 12][string range $date 14 15][string range $date 17 18]_$object_name
      ::robobs::log "Save image $name" 3
      saveima $name
      lappend robobs(image,filenames) $name
      
      # --- Update file list of observations
      if {$robobs(planif,mode)=="snresearch1"} {
         set kobs $robobs(planif,snresearch1,kobs)
         set field [lindex $robobs(planif,snresearch1,fields) $kobs]
         set field [lreplace $field 4 4 1]
         set robobs(planif,snresearch1,fields) [lreplace $robobs(planif,snresearch1,fields) $kobs $kobs $field]         
      }		
      
   }
	
	if {$robobs(planif,mode)=="asteroid_light_curve"} {
		incr robobs(planif,asteroid_light_curve,index_last_field)
		if {$robobs(planif,asteroid_light_curve,index_last_field)>3} {
			set robobs(planif,asteroid_light_curve,index_last_field) 1
		}
		#::robobs::log "B robobs(planif,asteroid_light_curve,index_last_field)=$robobs(planif,asteroid_light_curve,index_last_field)" 3
	}
   
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
