#
# Fichier : modpoithread.tcl
# Description : Wizard pour calculer un modele de pointage pour telescope
# Auteur : Alain KLOTZ
# Mise a jour $Id: modpoithread.tcl,v 1.1 2009-12-21 22:37:08 michelpujol Exp $
#
# 3) Pour charger un modele de pointage existant
#    source modpoi.tcl
#    modpoi_load "modpoi_res.txt"
#    * Le fichier doit etre du type modpoi_res.txt genere par le wizard.
#    * L'objet telescope effectuera automatiquement les corrections du modele
#      lors des pointages et des lectures des coordonnees.
#
######################################################################################

proc modpoi_cat2tel { radec } {
   global modpoi
   
   #--- Catalog 2 observed
   set dateTu [clock format [clock seconds] -gmt 1 -format "%Y-%m-%dT%H:%M:%S"]
   set listv [modpoi_catalogmean2apparent [lindex $radec 0] [lindex $radec 1] J2000.0 $dateTu]
   #--- Case :
   #--- The telescope mount computes the refraction corrections
   #--- yes = 1 (case of the Meade LX200, Sky Sensor 2000, ...)
   #--- no  = 0 (case of the AudeCom, ...)
   if {$modpoi(corrections,refraction)==0} {
      set listv [modpoi_apparent2observed $listv 101325 290 $dateTu]
   }
   set radec [lrange $listv 0 1]
   #--- Observed 2 telescope
   return [modpoi_passage $radec cat2tel ]
}

proc modpoi_tel2cat { radec } {
   global modpoi
   
   #--- Telescope 2 observed
   set radec [modpoi_passage $radec tel2cat ]
   #--- Observed 2 catalog
   set dateTu [clock format [clock seconds] -gmt 1 -format "%Y-%m-%dT%H:%M:%S"]
   #--- Case :
   #--- The telescope mount computes the refraction corrections
   #--- yes = 1 (case of the Meade LX200, Sky Sensor 2000, ...)
   #--- no  = 0 (case of the AudeCom, ...)
   if {$modpoi(corrections,refraction)==0} {
      set radec [modpoi_observed2apparent [lindex $radec 0] [lindex $radec 1] 101325 290 $dateTu]
   }
   set radec [modpoi_apparent2catalogmean $radec J2000.0 $dateTu]
   set ra [mc_angle2hms [lindex $radec 0] 360 zero 2 auto string]
   set dec [mc_angle2dms [lindex $radec 1] 90 zero 2 + string]
   return [list $ra $dec]
}


proc modpoi_catalogmean2apparent { rae dece equinox date { dra_dan "" } { ddec_dan "" } { epoch "" } } {
#--- Input
#--- rae,dece : coordinates J2000.0 (degrees)
#--- Output
#--- rav,decv : true coordinates (degrees)
#--- Hv : true hour angle (degrees)
#--- hv : true altitude altaz coordinate (degrees)
#--- azv : true azimut altaz coodinate (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Aberration annuelle
   set radec [mc_aberrationradec annual [list $rae $dece] $date ]
   #--- Correction de precession
   set radec [mc_precessradec $radec $equinox $date [list $dra_dan $ddec_dan $epoch]]
   #--- Correction de nutation
   set radec [mc_nutationradec $radec $date]
   #--- Aberration de l'aberration diurne
   set radec [mc_aberrationradec diurnal $radec $date $modpoi(var,home)]
   #--- Calcul de l'angle horaire et de la hauteur vraie
   set rav [lindex $radec 0]
   set decv [lindex $radec 1]
   set dummy [mc_radec2altaz ${rav} ${decv} $modpoi(var,home) $date]
   set azv [lindex $dummy 0]
   set hv [lindex $dummy 1]
   set Hv [lindex $dummy 2]
   #--- Return
   return [list $rav $decv $Hv $hv $azv]
}

proc modpoi_apparent2catalogmean { listv equinox date } {
#--- Input
#--- listv
#---   rav,decv : true coordinates (degrees)
#---   etc.
#--- equinox : J2000.0
#--- date
#--- Output
#--- rae,dece : coordinates J2000.0 (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Extract angles from the listvd
   set rav [lindex $listv 0]
   set decv [lindex $listv 1]
   #--- Aberration de l'aberration diurne
   set radec [mc_aberrationradec diurnal [list $rav $decv] $date $modpoi(var,home) -reverse]
   #--- Correction de nutation
   set radec [mc_nutationradec $radec $date -reverse]
   #--- Correction de precession
   set radec [mc_precessradec $radec $date $equinox]
   #--- Aberration annuelle
   set radec [mc_aberrationradec annual $radec $date -reverse]
   #--- Return
   return $radec
}

proc modpoi_apparent2observed { listvdt { pressure 101325 } { temperature 290 } { date now } } {
#--- Input
#--- listvdt : true coodinates list from modpoi_catalogmean2apparent (degrees)
#--- Output
#--- raadt,decadt : observed coordinates (degrees)
#--- Hadt : observed hour angle (degrees)
#--- hadt : observed altitude altaz coordinate (degrees)
#--- azadt : observed azimut altaz coordinate (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Extract angles from the listvd
   set ravdt [lindex $listvdt 0]
   set decvdt [lindex $listvdt 1]
   set Hvdt [lindex $listvdt 2]
   set hvdt [lindex $listvdt 3]
   set azvdt [lindex $listvdt 4]
   #--- Refraction correction
   set azadt $azvdt
   if {$hvdt>-1.} {
      set refraction [mc_refraction $hvdt out2in $temperature $pressure]
   } else {
      set refraction 0.
   }
   set hadt [expr $hvdt+$refraction]
   set res [mc_altaz2radec $azvdt $hadt $modpoi(var,home) $date]
   set raadt [lindex $res 0]
   set decadt [lindex $res 1]
   set res [mc_altaz2hadec $azvdt $hadt $modpoi(var,home) $date]
   set Hadt [lindex $res 0]
   return [list $raadt $decadt $Hadt $hadt $azadt]
}

proc modpoi_observed2apparent { rao deco { pressure 101325 } { temperature 290 } { date now } } {
#--- Input
#--- rao : observed (topocentric refracted) ra
#--- deco : observed (topocentric refracted) dec
#--- Output
#--- rav,decv : true coordinates (degrees)
#--- Hv : true hour angle (degrees)
#--- hv : true altitude altaz coordinate (degrees)
#--- azv : true azimut altaz coodinate (degrees)
   global modpoi

   set pi $modpoi(pi)
   set deg2rad $modpoi(deg2rad)
   set rad2deg $modpoi(rad2deg)
   #--- Refraction correction inverse
   set res [mc_radec2altaz $rao $deco $modpoi(var,home) $date]
   set azo [lindex $res 0]
   set ho [lindex $res 1]
   if {$ho>0} {
      set refraction [mc_refraction $ho out2in $temperature $pressure]
   } else {
      set refraction 0.
   }
   set azv $azo
   set hv [expr $ho-$refraction]
   set res [mc_altaz2radec $azv $hv $modpoi(var,home) $date]
   set rav [lindex $res 0]
   set decv [lindex $res 1]
   set res [mc_altaz2hadec $azv $hv $modpoi(var,home) $date]
   set Hv [lindex $res 0]
   return [list $rav $decv $Hv $hv $azv]
}

proc modpoi_passage { radec sens } {
   global modpoi

   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   if {$sens=="cat2tel"} {
      set signe +
   } else {
      set signe -
   }
   #--- Met en forme les valeurs
   set deltah 0
   set deltad 0
   ###set now now
   ###catch {set now [::audace::date_sys2ut now]}
   set now [clock format [clock seconds] -gmt 1 -format "%Y-%m-%dT%H:%M:%S"]   
   set phi [lindex $modpoi(var,home) 3]
   set ra0 $ra
   set dec0 $dec
   #--- Calcule l'angle horaire
   set dummy [mc_radec2altaz $ra $dec $modpoi(var,home) $now]
   set h [lindex $dummy 2]
   #--- Ajoute deux lignes à la matrice
   set vecY ""
   set matX ""
   set vecW ""
   set res [modpoi_addobs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $h $phi]
   set matX [lindex $res 1]
   #--- Calcul direct
   set res [gsl_mmult $matX $modpoi(vec)]
   set dra_c [expr [lindex $res 0]/60.]
   set ddec_c [expr [lindex $res 1]/60.]
   set ra [mc_angle2hms [mc_anglescomp $ra0 $signe $dra_c] 360 nozero 1 auto string]
   set dec [mc_angle2dms [mc_anglescomp $dec0 $signe $ddec_c] 90 nozero 0 + string]
   if {$sens=="tel2cat"} {
      #--- On itere dans le sens inverse pour gagner la precision de
      #--- la derive lors de la difference tel-cat.
      #--- Calcule l'angle horaire
      set dummy [mc_radec2altaz $ra $dec $modpoi(var,home) $now]
      set h [lindex $dummy 2]
      #--- Ajoute deux lignes à la matrice
      set vecY ""
      set matX ""
      set vecW ""
      set res [modpoi_addobs "$vecY" "$matX" "$vecW" $deltah $deltad $dec $h $phi]
      set matX [lindex $res 1]
      #--- Calcul direct
      set res [gsl_mmult $matX $modpoi(vec)]
      set dra_c [expr [lindex $res 0]/60.]
      set ddec_c [expr [lindex $res 1]/60.]
      set ra [mc_angle2hms [mc_anglescomp $ra0 $signe $dra_c] 360 nozero 1 auto string]
      set dec [mc_angle2dms [mc_anglescomp $dec0 $signe $ddec_c] 90 nozero 0 + string]
   }
   set ratel $ra
   set dectel $dec
   return [list $ratel $dectel]
}

proc modpoi_addobs { vecY matX vecW deltah deltad dec h phi } {
   set tand [expr tan([mc_angle2rad $dec]) ]
   set cosh [expr cos([mc_angle2rad $h]) ]
   set sinh [expr sin([mc_angle2rad $h]) ]
   set cosd [expr cos([mc_angle2rad $dec]) ]
   set sind [expr sin([mc_angle2rad $dec]) ]
   set secd [expr 1./cos([mc_angle2rad $dec]) ]
   set sinphi [expr sin([mc_angle2rad $phi]) ]
   set cosphi [expr cos([mc_angle2rad $phi]) ]
   #---
   #--- dh
   set res ""
   lappend res 1
   lappend res 0
   lappend res $tand
   lappend res $secd
   lappend res [expr $sinh*$tand]
   lappend res [expr -1.*$cosh*$tand]
   lappend res 0
   lappend res [expr -1.*$sinh*$secd]                         ; #--- MT : Mount Flexure
   lappend res [expr -1.*$cosphi*$cosh-1.*$sinphi*$tand]      ; #--- DAF : Delta Axis Flexure
   lappend res [expr $cosphi*$sinh*$secd]                     ; #--- TF : Tube Flexure
   #---
   lappend matX $res
   lappend vecY $deltah
   lappend vecW 0.5
   #--- ddec
   set res ""
   lappend res 0
   lappend res 1
   lappend res 0
   lappend res 0
   lappend res $cosh
   lappend res $sinh
   lappend res $cosh                                          ; #--- Fo : Fork Flexure
   lappend res 0
   lappend res 0
   lappend res [expr $cosphi*$cosh*$sind-$sinphi*$cosd]
   #---
   lappend matX $res
   lappend vecY $deltad
   lappend vecW [expr 1.+.00000005]
   #---
   return [list $vecY $matX $vecW]
}


