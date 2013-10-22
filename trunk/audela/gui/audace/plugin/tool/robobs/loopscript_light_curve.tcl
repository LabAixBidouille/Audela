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
   # --- display results
   set f [open "$robobs(conf,folders,rep_images,value)/$objename.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set jds ""
   set mags ""
   set errmags ""
   foreach ligne $lignes {
      set car [string index $ligne 0]
      set err [catch {expr $car+1} msg]
      if {($err==1)||([llength $ligne]<4)} {
         continue
      }
      lappend jds [lindex $ligne 0]
      lappend mags [lindex $ligne 1]
      lappend errmags  [lindex $ligne 2]
   }
   # --- Graphics
   if {[llength $jds]>1} {
      ::plotxy::figure 1
      ::plotxy::clf
      ::plotxy::caption "$objename"
      ::plotxy::plot $jds $mags or
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::ydir reverse
      ::plotxy::bgcolor #FFFFFF
      ::plotxy::ylabel "relative mag"
      ::plotxy::xlabel "JD UT"
      ::plotxy::title "$objename Light-curve"
      ::plotxy::writegif "$robobs(conf,folders,rep_images,value)/${objename}.gif"
   }
   
   # --- Copy the light curve for the web site
   if {$robobsconf(webserver)==1} {
      file mkdir $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)
      file copy -force -- $robobs(conf,folders,rep_images,value)/${objename}.txt $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)/${objename}.txt
      file copy -force -- $robobs(conf,folders,rep_images,value)/${objename}.gif $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)/${objename}.gif
   }      
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
