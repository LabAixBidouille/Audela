# Script light_curve
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

set bufNo $audace(bufNo)

# === Body of script
if {($robobs(planif,mode)=="asteroid_light_curve")&&($robobs(image,ffilenames)!="")} {

   # --- renomme les images en tmp1.fit à tmpn.fit
   ::robobs::log "Light curve : robobs(image,ffilenames)=$robobs(image,ffilenames)"
   set index 0
   foreach fname $robobs(image,ffilenames) {
      incr index
      buf$bufNo load $fname
      set fname "$robobs(conf,folders,rep_images,value)/tmp${index}$robobs(conf,fichier_image,extension,value)"      
      buf$bufNo save $fname
   }
   set ni $index
   ::robobs::log "photrel_wcs2cat tmp $ni append"
   photrel_wcs2cat tmp $ni append
   set objename [lindex [buf$bufNo getkwd OBJENAME] 1]
   set ra [lindex [buf$bufNo getkwd RA] 1]
   set dec [lindex [buf$bufNo getkwd DEC] 1]		
   ::robobs::log "Compute the light curve of $objename."
   photrel_cat2mes tmp $objename $ra $dec C
   # --- Copy the light curve for the web site
   if {$robobsconf(webserver)==1} {
      lassign [visu1 cut] sh sb
      buf$bufNo savejpeg $robobsconf(webserver,htdocs)/robobs_last.jpg 60 $sb $sh
      file mkdir $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)
      file copy -force -- $robobsconf(webserver,htdocs)/$starname.txt $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)/${starname}.txt
   }      
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
