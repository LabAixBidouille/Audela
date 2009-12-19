#
# Fichier : snmacros.tcl
# Description : Macros des scripts pour la recherche de supernovae
# Auteur : Alain KLOTZ
# Mise a jour $Id: snmacros.tcl,v 1.12 2009-12-19 16:31:59 robertdelmas Exp $
#

proc globgalsn { args } {
   # idem as glob but don't take d*b* files
   set result ""
   set errnum [catch {glob $args} result]
   if {$errnum==1} {
      return ""
   }
   set len [llength $result]
   if {$len==0} {
      return ""
   }
   set f [lindex $result 0]
   set rep [file dirname $f]
   set mask [ file join ${rep} d*b* ]
   set errnum [catch {glob $mask} resultd]
   if {$errnum==1} {
      set resultd ""
   }
   set res ""
   foreach f $result {
      set k [lsearch -exact $resultd $f]
      if {$k==-1} {
         lappend res "$f"
      }
   }
   return $res
}

proc readobjs { namefile } {
   set input [open "$namefile" r]
   set contents [split [read $input] \n]
   close $input
   return $contents
}

proc selectobjs { objlist {decinf "-15"} {decsup "40"} {localite "GPS 2.33 e 48.8 67"} {maginf -1.5} {magsup 15} } {
   #--- Selectionne uniquement les objets suffisamment loin de la Lune et du Soleil et elimine ceux
   #--- qui sont en dehors des declinaisons pointables, la liste d'objets comprend les colonnes suivantes :
   #--- col 0 : name
   #--- col 1 : rah
   #--- col 2 : ram
   #--- col 3 : ras
   #--- col 4 : decd
   #--- col 5 : decm

   set radecmoon [moon_info_0h $localite]
   set radecsun  [ sun_info_0h $localite]

   set ra_moon [lindex $radecmoon 0]
   set dec_moon [lindex $radecmoon 1]
   set elong_moon [lindex $radecmoon 2]
   set moon_lim [expr 55.*$elong_moon/90.]
   if {$moon_lim>55} {
      set moon_lim 55
   }
   set ra_sun [lindex $radecsun 0]
   set dec_sun [lindex $radecsun 1]
   set sun_lim 45
   catch {unset contents} {}
   set fin [expr [llength $objlist]-1]
   #set finfin [expr [llength $objlist]-10]
   for {set k 0} {$k < $fin} {incr k} {
      #--- h est le RA de l'objet
      set ligne [lindex $objlist $k]
      set h [mc_angle2deg [lindex $ligne 1]h[lindex $ligne 2]m[lindex $ligne 3]s]
      #--- d est la DEC de la galaxie
      set d [mc_angle2deg [lindex $ligne 4]d[lindex $ligne 5]m[lindex $ligne 6]s 90]
      #--- Mag est la magnitude de la galaxie
      set mag [lindex $ligne 7]
      #--- On verifie si la galaxie n'est pas trop pres de la Lune
      set sepangle [mc_anglesep [list $ra_moon $dec_moon $h $d] degrees]
      set sepanglem [lindex $sepangle 0]
      #--- On verifie si la galaxie n'est pas trop pres du Soleil
      set sepangle [mc_anglesep [list $ra_sun $dec_sun $h $d] degrees]
      set sepangles [lindex $sepangle 0]
      #---
      if {($sepanglem>$moon_lim)&&($sepangles>$sun_lim)&&($d<$decsup)&&($d>$decinf)&&($mag<=$magsup)&&($mag>=$maginf)} {
         lappend contents $ligne
      }
   }
   return $contents
}

proc moon_info_0h { {localite "GPS 2.33 e 48.8 67"} } {
   #--- Calcule RA DEC de la lune pour la plus proche date a 0h TU
   set jd [mc_date2jd now]
   set jd0 [mc_date2jd now0]
   set dif [expr $jd-$jd0]
   if {$dif>.5} {
      set jd [mc_date2jd now1]
   } else {
      set jd [mc_date2jd now0]
   }
   set result [lindex [mc_ephem moon [list [mc_date2tt $jd ]] {ra dec elong} -topo $localite] 0]
   return $result
}

proc sun_info_0h { {localite "GPS 2.33 e 48.8 67"} } {
   #--- Calcule RA DEC du Soleil pour la plus proche date a 0h TU
   set jd [mc_date2jd now]
   set jd0 [mc_date2jd now0]
   set dif [expr $jd-$jd0]
   if {$dif>.5} {
      set jd [mc_date2jd now1]
   } else {
      set jd [mc_date2jd now0]
   }
   set result [lindex [mc_ephem sun [list [mc_date2tt $jd ]] {ra dec} -topo $localite] 0]
   return $result
}

proc sunset { {hauteurlim "0"} {localite "GPS 2.33 e 48.8 67"} } {
   #--- Calcule le jour julien correspondant au prochain commencement de nuit
   #--- (fixee ici lorsque le soleil est a hauteur deg)
   set now [::audace::date_sys2ut now]
   set jd_deb [mc_date2jd $now]
   set k 0
   for {set jj [expr $jd_deb]} {$jj < [expr $jd_deb+1.]} {set jj [expr $jj+0.0005]} {
      set hauteur [lindex [mc_ephem sun [list [mc_date2tt $jj ]] {altitude} -topo $localite] 0]
      if {$k>0} {
         set dh [expr $hauteur-$hauteurlim]
         if {$k>1} {
            set signe [expr $dh*$dh0]
            #set result "[mc_date2ymdhms $jj] $hauteur $signe"
            #console::affiche_erreur "$result\n"
            if {$signe<=0} {
               if {$dh<0} {
                  break;
               }
            }
         }
         set dh0 $dh
      }
      incr k
      set hauteur0 $hauteur
   }
   return $jj
}

proc sunrise { {hauteurlim "0"} {localite "GPS 2.33 e 48.8 67"} } {
   #--- Calcule le jour julien correspondant a la prochaine fin de nuit
   #--- (fixee ici lorsque le soleil est a hauteur deg)
   set now [::audace::date_sys2ut now]
   set jd_deb [mc_date2jd $now]
   set k 0
   for {set jj [expr $jd_deb]} {$jj < [expr $jd_deb+1.]} {set jj [expr $jj+0.0005]} {
      set hauteur [lindex [mc_ephem sun [list [mc_date2tt $jj ]] {altitude} -topo $localite] 0]
      if {$k>0} {
         set dh [expr $hauteur-$hauteurlim]
         if {$k>1} {
            set signe [expr $dh*$dh0]
            #set result "[mc_date2ymdhms $jj] $hauteur $signe"
            #console::affiche_erreur "$result\n"
            if {$signe<=0} {
               if {$dh>0} {
                  break;
               }
            }
         }
         set dh0 $dh
      }
      incr k
      set hauteur0 $hauteur
   }
   return $jj
}

# ==========================================================================================
proc snconfacq_verif { } {
   global conf snconf

   if { [info exists snconf(position)] == "0" } {
      set snconf(position) "+80+40"
   }
   if { [info exists snconf(dossier)] == "0" } {
      set snconf(dossier) "."
   }
   if { [info exists snconf(haurore)] == "0" } {
      set snconf(haurore) "-10"
   }
   if { [info exists snconf(unsmearing)] == "0" } {
      set snconf(unsmearing) "0.0005"
   }
   if { [info exists snconf(localite)] == "0" } {
      set snconf(localite) "gps 2 e 43.6 148"
   }
   if { [info exists snconf(decinf)] == "0" } {
      set snconf(decinf) "-15"
   }
   if { [info exists snconf(decsup)] == "0" } {
      set snconf(decsup) "50"
   }
   if { [info exists snconf(hest)] == "0" } {
      set snconf(hest) "300."
   }
   if { [info exists snconf(houest)] == "0" } {
      set snconf(houest) "30."
   }
   if { [info exists snconf(exptime)] == "0" } {
      set snconf(exptime) "60"
   }
   if { [info exists snconf(binning)] == "0" } {
      set snconf(binning) "2"
   }
   if { [info exists snconf(nbimages)] == "0" } {
      set snconf(nbimages) "1"
   }
   if { [info exists snconf(fichier_sn)] == "0" } {
      set snconf(fichier_sn) "sn.txt"
   }
   if { [info exists snconf(magsup)] == "0" } {
      set snconf(magsup) "13.5"
   }
   if { [info exists snconf(maginf)] == "0" } {
      set snconf(maginf) "-1.5"
   }
   if { [info exists snconf(foclen)] == "0" } {
      set snconf(foclen) "1.2"
   }
   if { [info exists snconf(fits,OBSERVER)] == "0" } {
      set snconf(fits,OBSERVER) "$conf(posobs,nom_observateur)"
   }
}
# ==========================================================================================

# ==========================================================================================
proc snconfacq_save { } {
   global conf snconf

   set result ""
   # === Basic parameters ===
   #--- Position
   set conf(snconfacq,position)      $snconf(position)
   #--- Folder of images
   set conf(snconfacq,dossier)       $snconf(dossier)
   #--- Sun altitude under that SNAcq is on (degrees)
   set conf(snconfacq,haurore)       $snconf(haurore)
   #--- Smearing factor (0 if camera as a shutter)
   set conf(snconfacq,unsmearing)    $snconf(unsmearing)
   #--- Site (GPS long(degrees) E/W lat(degrees) alt(meters))
   set conf(snconfacq,localite)      $snconf(localite)
   #--- Degrees : Lower declination limit
   set conf(snconfacq,decinf)        $snconf(decinf)
   #--- Degrees : Upper declination limit
   set conf(snconfacq,decsup)        $snconf(decsup)
   #--- Degrees : Hour angle limit toward eastern horizon
   set conf(snconfacq,hest)          $snconf(hest)
   #--- Degrees : Hour angle limit toward western horizon
   set conf(snconfacq,houest)        $snconf(houest)
   #--- Exposure time for CCD (seconds)
   set conf(snconfacq,exptime)       $snconf(exptime)
   #--- Binning factor (1, 2, 4)
   set conf(snconfacq,binning)       $snconf(binning)
   #--- Number image to record on the same field (1, 2,...)
   set conf(snconfacq,nbimages)      $snconf(nbimages)
   #--- Filename of the database
   set conf(snconfacq,fichier_sn)    $snconf(fichier_sn)
   #--- Upper limit magnitude to select galaxies from database
   set conf(snconfacq,magsup)        $snconf(magsup)
   #--- Lower limit magnitude to select galaxies from database
   set conf(snconfacq,maginf)        $snconf(maginf)
   #--- Optical focal length (meters)
   set conf(snconfacq,foclen)        $snconf(foclen)
   #--- Telescope type
   set conf(snconfacq,telescope)     $snconf(telescope)
   #--- FITS Keywords
   set conf(snconfacq,fits,OBSERVER) $snconf(fits,OBSERVER)
}
# ==========================================================================================

# ==========================================================================================
proc snconfacq_load { } {
   global conf snconf

   set result ""
   # === Basic parameters ===
   #--- Position
   set snconf(position)      $conf(snconfacq,position)
   #--- Folder of images
   set snconf(dossier)       $conf(snconfacq,dossier)
   #--- Sun altitude under that SNAcq is on (degrees)
   set snconf(haurore)       $conf(snconfacq,haurore)
   #--- Smearing factor (0 if camera as a shutter)
   set snconf(unsmearing)    $conf(snconfacq,unsmearing)
   #--- Site (GPS long(degrees) E/W lat(degrees) alt(meters))
   set snconf(localite)      $conf(snconfacq,localite)
   #--- Degrees : Lower declination limit
   set snconf(decinf)        $conf(snconfacq,decinf)
   #--- Degrees : Upper declination limit
   set snconf(decsup)        $conf(snconfacq,decsup)
   #--- Degrees : Hour angle limit toward eastern horizon
   set snconf(hest)          $conf(snconfacq,hest)
   #--- Degrees : Hour angle limit toward western horizon
   set snconf(houest)        $conf(snconfacq,houest)
   #--- Exposure time for CCD (seconds)
   set snconf(exptime)       $conf(snconfacq,exptime)
   #--- Binning factor (1, 2, 4)
   set snconf(binning)       $conf(snconfacq,binning)
   #--- Number image to record on the same field (1, 2,...)
   set snconf(nbimages)      $conf(snconfacq,nbimages)
   #--- Filename of the database
   set snconf(fichier_sn)    $conf(snconfacq,fichier_sn)
   #--- Upper limit magnitude to select galaxies from database
   set snconf(magsup)        $conf(snconfacq,magsup)
   #--- Lower limit magnitude to select galaxies from database
   set snconf(maginf)        $conf(snconfacq,maginf)
   #--- Optical focal length (meters)
   set snconf(foclen)        $conf(snconfacq,foclen)
   #--- Telescope type
   set snconf(telescope)     $conf(snconfacq,telescope)
   #--- FITS Keywords
   set snconf(fits,OBSERVER) $conf(snconfacq,fits,OBSERVER)
}
# ==========================================================================================

# ==========================================================================================
proc sninfo { {result ""} } {
   global sn zone

   if { $sn(exit) != "1" } {
      $zone(status_list) insert end "$result\n"
      $zone(status_list) yview moveto 1.0
      update
   }
}
# ==========================================================================================

# ==========================================================================================
proc makebias {} {
   global audace caption sn snconf

   set sn(stop) "0"

   if {[::cam::list]==""} {
      bell
      return
   }

   $audace(base).snacq.frame2.but_gobias configure -relief groove -state disabled
   $audace(base).snacq.frame2.but_godark configure -relief raised -state disabled
   update

   set nbdarks 20;
   set expt 0;
   set bin $snconf(binning);

   #--- Fermeture de l'obturateur pour la pose
   set shutter_mode [cam$audace(camNo) shutter]
   cam$audace(camNo) shutter closed

   sninfo "$caption(snmacros,obscurite)"
   sninfo ""
   sninfo "[ format $caption(snmacros,acqde1) $nbdarks ]"
   sninfo ""

   for {set k 1} {$k <= $nbdarks} {incr k} {
      set sn(exit_visu) "1"
      sninfo "$caption(snmacros,acqbias) $k"
      #--- Sortie de la boucle si appui sur le bouton Quitter
      if { $sn(exit) == "1" } {
         set sn(stop) "1"
         break
      }
      #--- Sortie de la boucle si appui sur le bouton Stop
      if { $sn(stop) == "1" } {
         break
      }
      #--- Utilisation de la primitive aud'ace "acq"
      acq $expt $bin
      #--- Enregistrement de l'image
      set name d$expt-$k;
      saveima $name
   }

   if { $sn(stop) == "0" } {
      #--- Commentaire
      sninfo ""
      sninfo "$caption(snmacros,synthesebias)\n"
      #--- Synthèse de l'offset final
      smedian d$expt- d${expt}b${bin} $nbdarks
      #--- Ménage
      delete2 d$expt- $nbdarks
      #--- Calcule les stats sur l'offset médian (stockées dans l'entête)
      set extname "[buf$audace(bufNo) extension]"
      ttscript2 "IMA/STAT \"$snconf(dossier)\" \"d${expt}b${bin}\" . . \"$extname\" \"$snconf(dossier)\" \"d${expt}b${bin}\" . \"$extname\" STAT"
      loadima d${expt}b${bin}
      #--- Commentaire
      after 2500
      sninfo "$caption(snmacros,synthesebiasfini)\n"
   } elseif { $sn(stop) == "1" } {
      #--- Ménage
      delete2 d$expt- $k
      #--- Commentaire
      sninfo ""
      sninfo "$caption(snmacros,acqbias_stop)\n"
   }

   #--- Restauration du mode obturateur
   cam$audace(camNo) shutter $shutter_mode

   $audace(base).snacq.frame2.but_gobias configure -relief raised -state normal
   $audace(base).snacq.frame2.but_godark configure -relief raised -state normal
   update

   #--- Cas d'une action sur le bouton Quitter
   set sn(exit_visu) "0"
   if { $sn(exit) == "1" } {
      destroy $audace(base).snacq
      if [winfo exists $audace(base).outSnAcq] {
         destroy $audace(base).outSnAcq
      }
   }
   #--- Cas d'une action sur le bouton Stop
   set sn(exit_visu) "0"
   if { $sn(stop) == "1" } {
      if [winfo exists $audace(base).out_SnAcq] {
         destroy $audace(base).out_SnAcq
         $audace(base).snacq.frame2.but_stop configure -relief raised
      }
   }
}
# ==========================================================================================

# ==========================================================================================
proc makedark {} {
   global audace caption sn snconf

   set sn(stop) "0"

   if {[::cam::list]==""} {
      bell
      return
   }

   $audace(base).snacq.frame2.but_godark configure -relief groove -state disabled
   $audace(base).snacq.frame2.but_gobias configure -relief raised -state disabled
   update

   set nbdarks 15;
   set expt $snconf(exptime);
   set bin $snconf(binning);

   #--- Fermeture de l'obturateur pour la pose
   set shutter_mode [cam$audace(camNo) shutter]
   cam$audace(camNo) shutter closed

   sninfo "$caption(snmacros,obscurite)"
   sninfo ""
   sninfo "[ format $caption(snmacros,acqde2) $nbdarks $expt ]"
   sninfo ""

   for {set k 1} {$k <= $nbdarks} {incr k} {
      set sn(exit_visu) "1"
      sninfo "$caption(snmacros,acqdark) $k"
      #--- Sortie de la boucle si appui sur le bouton Quitter
      if { $sn(exit) == "1" } {
         set sn(stop) "1"
         break
      }
      #--- Sortie de la boucle si appui sur le bouton Stop
      if { $sn(stop) == "1" } {
         break
      }
      #--- Utilisation de la primitive aud'ace "acq"
      acq $expt $bin
      #--- Enregistrement de l'image
      set name d$expt-$k;
      saveima $name
   }

   if { $sn(stop) == "0" } {
      #--- Commentaire
      sninfo ""
      sninfo "$caption(snmacros,synthesedark)\n"
      #--- Synthèse du noir final
      smedian d$expt- d${expt}b${bin} $nbdarks
      #--- Ménage
      delete2 d$expt- $nbdarks
      #--- Calcule les stats sur le noir médian (stockées dans l'entête)
      set extname "[buf$audace(bufNo) extension]"
      ttscript2 "IMA/STAT \"$snconf(dossier)\" \"d${expt}b${bin}\" . . \"$extname\" \"$snconf(dossier)\" \"d${expt}b${bin}\" . \"$extname\" STAT"
      loadima d${expt}b${bin}
      #--- Commentaire
      after 2500
      sninfo "$caption(snmacros,synthesedarkfini)\n"
   } elseif { $sn(stop) == "1" } {
      #--- Ménage
      delete2 d$expt- $k
      #--- Commentaire
      sninfo ""
      sninfo "$caption(snmacros,acqdark_stop)\n"
   }

   #--- Restauration du mode obturateur
   cam$audace(camNo) shutter $shutter_mode

   $audace(base).snacq.frame2.but_godark configure -relief raised -state normal
   $audace(base).snacq.frame2.but_gobias configure -relief raised -state normal
   update

   #--- Cas d'une action sur le bouton Quitter
   set sn(exit_visu) "0"
   if { $sn(exit) == "1" } {
      destroy $audace(base).snacq
      if [winfo exists $audace(base).outSnAcq] {
         destroy $audace(base).outSnAcq
      }
   }
   #--- Cas d'une action sur le bouton Stop
   set sn(exit_visu) "0"
   if { $sn(stop) == "1" } {
      if [winfo exists $audace(base).out_SnAcq] {
         destroy $audace(base).out_SnAcq
         $audace(base).snacq.frame2.but_stop configure -relief raised
      }
   }
}
# ==========================================================================================

# ==========================================================================================
proc snprism { } {
   global audace caption snconf

   set date_obs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
   set exposure [lindex [buf$audace(bufNo) getkwd EXPOSURE] 1]
   set jdeb [mc_date2jd $date_obs]
   set jfin [expr $jdeb+$exposure/86400.]
   set jmil [expr ($jdeb+$jfin)/2.]
   set df [mc_date2ymdhms $jfin]
   set ra [lindex [buf$audace(bufNo) getkwd RA] 1]
   set dec [lindex [buf$audace(bufNo) getkwd DEC] 1]
   set focmm [expr $snconf(foclen)*1000.]
   set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
   #---
   set ut [string range $date_obs [expr 1+[string first T $date_obs]] end]
   set ut_start $ut
   set ut_end [format "%02.0f:%02.0f:%05.2f" [lindex $df 3] [lindex $df 4] [lindex $df 5]]
   set jday [mc_date2jd $jmil]
   set xpixelsz [ lindex [ buf$audace(bufNo) getkwd XPIXSZ ] 1 ]
   set ypixelsz [ lindex [ buf$audace(bufNo) getkwd YPIXSZ ] 1 ]
   set cdeltm1 [ expr $xpixelsz / 1000. ]
   set cdeltm2 [ expr $ypixelsz / 1000. ]
   set binx $snconf(binning)
   set biny $snconf(binning)
   set crval1 $ra
   set crval2 $dec
   set cdelt1 [expr atan($cdeltm1/$focmm)]
   set cdelt2 [expr atan($cdeltm2/$focmm)]
   set focal $focmm
   set x1 1
   set y1 1
   set x2 $naxis1
   set y2 $naxis2
   #---
   buf$audace(bufNo) setkwd [list UT       $ut                    string "UT time of observation"       ""]
   buf$audace(bufNo) setkwd [list UT-START $ut_start              string "UT start"                     ""]
   buf$audace(bufNo) setkwd [list UT-END   $ut_end                string "UT end"                       ""]
   buf$audace(bufNo) setkwd [list JDAY     $jday                  float  "julian day of observation"    ""]
   buf$audace(bufNo) setkwd [list XPIXELSZ $xpixelsz              float  "X pixel size microns"         "um"]
   buf$audace(bufNo) setkwd [list YPIXELSZ $ypixelsz              float  "Y pixel size microns"         "um"]
   buf$audace(bufNo) setkwd [list CDELTM1  $cdeltm1               float  "size of a pixel (x) in mm"    "mm"]
   buf$audace(bufNo) setkwd [list CDELTM2  $cdeltm2               float  "size of a pixel (y) in mm"    "mm"]
   buf$audace(bufNo) setkwd [list OBSERVER $snconf(fits,OBSERVER) string "Observer name"                ""]
   buf$audace(bufNo) setkwd [list BINX     $binx                  int    "X binning"                    ""]
   buf$audace(bufNo) setkwd [list BINY     $biny                  int    "Y binning"                    ""]
   buf$audace(bufNo) setkwd [list CRVAL1   $crval1                float  "Approx.centre coord. in R.A." "deg"]
   buf$audace(bufNo) setkwd [list CRVAL2   $crval2                float  "Approx.centre coord. in DECL" "deg"]
   buf$audace(bufNo) setkwd [list CDELT1   $cdelt1                float  "scaleX in rad/pix"            "rad"]
   buf$audace(bufNo) setkwd [list CDELT2   $cdelt2                float  "scaleY in rad/pix"            "rad"]
   buf$audace(bufNo) setkwd [list FOCAL    $focal                 float  "Focal length in mm"           "mm"]
   buf$audace(bufNo) setkwd [list X1       $x1                    int    "X1 image windowing"           ""]
   buf$audace(bufNo) setkwd [list Y1       $y1                    int    "Y1 image windowing"           ""]
   buf$audace(bufNo) setkwd [list X2       $x2                    int    "X2 image windowing"           ""]
   buf$audace(bufNo) setkwd [list Y2       $y2                    int    "Y2 image windowing"           ""]
}
# ==========================================================================================

# ==========================================================================================
proc snconfvisu_verif { } {
   global snconfvisu

   if { [ info exists snconfvisu(rep1) ] == "0" } {
      set snconfvisu(rep1) ""
   }
   if { [ info exists snconfvisu(rep2) ] == "0" } {
      set snconfvisu(rep2) ""
   }
   if { [ info exists snconfvisu(rep3) ] == "0" } {
      set snconfvisu(rep3) ""
   }
   if { [ info exists snconfvisu(cuts_change) ] == "0" } {
      set snconfvisu(cuts_change) "motion"
   }
   if { [ info exists snconfvisu(delai_blink) ] == "0" } {
      set snconfvisu(delai_blink) "250"
   }
   if { [ info exists snconfvisu(nb_blink) ] == "0" } {
      set snconfvisu(nb_blink) "5"
   }
   if { [ info exists snconfvisu(auto_blink) ] == "0" } {
      set snconfvisu(auto_blink) "0"
   }
   if { [ info exists snconfvisu(scrollbars) ] == "0" } {
      set snconfvisu(scrollbars) "on"
   }
   if { [ info exists snconfvisu(gzip) ] == "0" } {
      set snconfvisu(gzip) "no"
   }
   if { [ info exists snconfvisu(dss_dvd) ] == "0" } {
      set snconfvisu(dss_dvd) "0"
   }
   if { [ info exists snconfvisu(rep_dss_dvd) ] == "0" } {
      set snconfvisu(rep_dss_dvd) "d:/"
   }
   if { [ info exists snconfvisu(priorite_dvd) ] == "0" } {
      set snconfvisu(priorite_dvd) "0"
   }
   if { [ info exists snconfvisu(zoom_normal) ] == "0" } {
      set snconfvisu(zoom_normal) "1"
   }
}
# ==========================================================================================

# ==========================================================================================
proc snconfvisu_load { } {
   global conf snconfvisu

   set result ""
   #--- Folder of night images
   set snconfvisu(rep1)              "$conf(snconfvisu,rep1)"
   #--- Folder of reference images (Personnal)
   set snconfvisu(rep2)              "$conf(snconfvisu,rep2)"
   #--- Folder of reference images (DSS)
   set snconfvisu(rep3)              "$conf(snconfvisu,rep3)"
   #--- Cuts change by motion or release
   set snconfvisu(cuts_change)       "$conf(snconfvisu,cuts_change)"
   #--- Choise blink delay
   set snconfvisu(delai_blink)       "$conf(snconfvisu,delai_blink)"
   #--- Choise blink number
   set snconfvisu(nb_blink)          "$conf(snconfvisu,nb_blink)"
   #--- Choise auto blink
   set snconfvisu(auto_blink)        "$conf(snconfvisu,auto_blink)"
   #--- Displaying scrollbars
   set snconfvisu(scrollbars)        "$conf(snconfvisu,scrollbars)"
   #--- Choise to save reference images compressed by gzip
   set snconfvisu(gzip)              "$conf(snconfvisu,gzip)"
   #--- Reference images on hard disk or on DVD
   set snconfvisu(dss_dvd)           "$conf(snconfvisu,dss_dvd)"
   #--- Folder of DVD
   set snconfvisu(rep_dss_dvd)       "$conf(snconfvisu,rep_dss_dvd)"
   #--- Reference images (DSS) - DVD priority
   set snconfvisu(priorite_dvd)      "$conf(snconfvisu,priorite_dvd)"
   #--- Zoom
   set snconfvisu(zoom_normal)       "$conf(snconfvisu,zoom_normal)"
}
# ==========================================================================================

# ==========================================================================================
proc snconfvisu_save { } {
   global conf snconfvisu

   set result ""
   #--- Folder of night images
   set conf(snconfvisu,rep1)         "$snconfvisu(rep1)"
   #--- Folder of reference images (Personnal)
   set conf(snconfvisu,rep2)         "$snconfvisu(rep2)"
   #--- Folder of reference images (DSS)
   set conf(snconfvisu,rep3)         "$snconfvisu(rep3)"
}
# ==========================================================================================

# ==========================================================================================
proc snvisuconfiguration_save { } {
   global conf snconfvisu

   set result ""
   #--- Cuts change by motion or release
   set conf(snconfvisu,cuts_change)  "$snconfvisu(cuts_change)"
   #--- Choise blink delay
   set conf(snconfvisu,delai_blink)  "$snconfvisu(delai_blink)"
   #--- Choise blink number
   set conf(snconfvisu,nb_blink)     "$snconfvisu(nb_blink)"
   #--- Choise auto blink
   set conf(snconfvisu,auto_blink)   "$snconfvisu(auto_blink)"
   #--- Displaying scrollbars
   set conf(snconfvisu,scrollbars)   "$snconfvisu(scrollbars)"
   #--- Choise to save reference images compressed by gzip
   set conf(snconfvisu,gzip)         "$snconfvisu(gzip)"
   #--- Reference images on hard disk or on DVD
   set conf(snconfvisu,dss_dvd)      "$snconfvisu(dss_dvd)"
   #--- Folder of DVD
   set conf(snconfvisu,rep_dss_dvd)  "$snconfvisu(rep_dss_dvd)"
   #--- Reference images (DSS) - DVD priority
   set conf(snconfvisu,priorite_dvd) "$snconfvisu(priorite_dvd)"
   #--- Zoom
   set conf(snconfvisu,zoom_normal)  "$snconfvisu(zoom_normal)"
}
# ==========================================================================================

# ==========================================================================================
proc sn_verif_wcs { bufNo } {
   set calib 1
   if { [string compare [lindex [buf$bufNo getkwd CRPIX1] 0] ""] == 0 } {
      set calib 0
   }
   if { [string compare [lindex [buf$bufNo getkwd CRPIX2] 0] ""] == 0 } {
      set calib 0
   }
   if { [string compare [lindex [buf$bufNo getkwd CRVAL1] 0] ""] == 0 } {
      set calib 0
   }
   if { [string compare [lindex [buf$bufNo getkwd CRVAL2] 0] ""] == 0 } {
      set calib 0
   }
   set classic 0
   set nouveau 0
   if { [string compare [lindex [buf$bufNo getkwd CD1_1] 0] ""] != 0 } {
      incr nouveau
   }
   if { [string compare [lindex [buf$bufNo getkwd CD1_2] 0] ""] != 0 } {
      incr nouveau
   }
   if { [string compare [lindex [buf$bufNo getkwd CD2_1] 0] ""] != 0 } {
      incr nouveau
   }
   if { [string compare [lindex [buf$bufNo getkwd CD2_2] 0] ""] != 0 } {
      incr nouveau
   }
   if { [string compare [lindex [buf$bufNo getkwd CDELT1] 0] ""] != 0 } {
      incr classic
   }
   if { [string compare [lindex [buf$bufNo getkwd CDELT2] 0] ""] != 0 } {
      incr classic
   }
   if { [string compare [lindex [buf$bufNo getkwd CROTA1] 0] ""] != 0 } {
      incr classic
   }
   if { [string compare [lindex [buf$bufNo getkwd CROTA2] 0] ""] != 0 } {
      incr classic
   }
   if {(($calib == 1)&&($nouveau==4))||(($calib == 1)&&($classic>=3))} {
      return 1
   } else {
      return 0
   }
}
# ==========================================================================================

# ==========================================================================================
proc sn_center_radec { bufNo } {
   set res [sn_verif_wcs $bufNo]
   if {$res==0} {
      return ""
   }
   set x [expr [buf$bufNo getpixelswidth]/2.]
   set y [expr [buf$bufNo getpixelsheight]/2.]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 2 auto list]
   set dec [mc_angle2dms $dec 90 zero 1 + list]
   return "{ $ra $dec }"
}
# ==========================================================================================

