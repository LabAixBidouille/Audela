#
# Fichier : collector_dyn.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc                   utilisee par
   # ::collector::updateInfo              testPattern et testNumeric
   # ::collector::computeOptic            updateInfo
   # ::collector::computeCdeltFov         updateInfo, modifyCamera
   # ::collector::computeCenterPixVal     updateInfo, modifyCamera, initPose
   # ::collector::computeTslMoon          updateInfo, refreshSpeed, initLocal
   # ::collector::computeTelCoord         updateInfo et refreshCoordsJ2000
   # ::collector::modifyBand              combobox des filtres
   # ::collector::modifyCamera            combobox du choix de la camera
   # ::collector::modifyPriority          combobox du choix de la priorite, modifyBand, modifyCamera, computeTslMoon, updateInfo et updateEtc
   # ::collector::modifyRep               combobox du choix du catalogue
   # ::collector::refreshNotebook         configTraceRaDec
   # ::collector::refreshCoordsJ2000      initTarget, refreshNotebook, doUnPark et doPark
   # ::collector::refreshMeteo            initAtm
   # ::collector::computeTelSpeed         refreshNotebook

   #---------------------------------------------------------------------------
   #  updateInfo
   #  Met a jour Collector en fonction du parametre modifie
   #  Parametre : nom de la variable modifiee
   #---------------------------------------------------------------------------
   proc updateInfo { child } {
      variable private
      global cameras

      if {$child in [list aptdia fond seeing]} {
         computeOptic
      } elseif {$child in [list tu gps]} {
         computeTslMoon
      } elseif {$child in [list ra dec equinox temperature airpressure]} {
         computeTslMoon
         computeTelCoord
         computeCenterPixVal
      } elseif {$child in [list bin1 bin2 naxis1 naxis2 crota2 photocell1 photocell2]} {
         computeCdeltFov
         computeCenterPixVal
      }

      if {$child in [string map { \{ "" \} "" } $private(etc_variables)]} {
         modifyPriority
      }

      #--   configure les boutons de commandes
      configCmd
   }

   #------------------------------------------------------------
   #  computeOptic
   #  Met a jour les parametres optiques
   #------------------------------------------------------------
   proc computeOptic { } {
      variable private

      lassign [getFonDResolution $private(aptdia) $private(foclen)] \
         private(fond) private(resolution)

      set error 10
      set private(ncfz) [getNewCriticalFocusZone $private(fond) $private(aptdia) $private(seeing) $error]
      set ncfz [getNewCriticalFocusZone $private(fond) $private(aptdia) $private(seeing) $error]
      if {$ncfz ne "-"} {
         set private(ncfz) [format %0.1f $ncfz]
      } else {
         set private(ncfz) $ncfz
      }

      set private(focus_pos) $::audace(focus,currentFocus)
   }

   #------------------------------------------------------------
   #  computeCdeltFov
   #  Met a jour l'echantillonnage et le champ
   #------------------------------------------------------------
   proc computeCdeltFov { } {
      variable private

      #--   raccourcis
      foreach v [list naxis1 naxis2 bin1 bin2 photocell1 photocell2 foclen] \
         {set $v $private($v)}

      set private(pixsize1) [expr { $photocell1 * $bin1 }]
      set private(pixsize2) [expr { $photocell2 * $bin2 }]

      lassign [getCdeltFov $naxis1 $naxis2 $private(pixsize1) $private(pixsize2) $foclen] \
         private(cdelt1) private(cdelt2) private(fov1) private(fov2)
   }

   #------------------------------------------------------------
   #  computeCenterPixVal
   #  Met a jour les coordonnees du centre de l'image
   #------------------------------------------------------------
   proc computeCenterPixVal { } {
      variable private

      set private(crpix1) [expr { $private(naxis1)/2. } ]
      set private(crpix2) [expr { $private(naxis2)/2. } ]

      set private(crval1) [string trim [mc_angle2deg $private(ra)]]
      set private(crval2) [string trim [mc_angle2deg $private(dec)]]
   }

   #------------------------------------------------------------
   #  computeTslMoon
   #  Calcule le temps JD, TSL et la Lune
   #------------------------------------------------------------
   proc computeTslMoon { } {
      variable private

      set private(jd) [mc_date2jd $private(tu)]
      set private(tsl) [getTsl $private(tu) $private(gps)]

      lassign [getMoonAge $private(jd) $private(gps)] \
         private(moonphas) private(moonalt) private(moon_age)

      etc_params_set moon_age $private(moon_age)

      modifyPriority
    }

   #------------------------------------------------------------
   #  computeTelCoord
   #  Calcule et rafraichit les coordonnees courantes du telescope
   #------------------------------------------------------------
   proc computeTelCoord { } {
      variable private

      set tempK [expr { 273.15 + $private(tempair) }]
      set data [list $private(ra) $private(dec) $private(tu) $private(gps) $private(airpress) $tempK]
      if {"-" in $data} {return}

      lassign [getTrueCoordinates $data] private(raTel) private(decTel) \
         private(haTel) private(azTel)  private(elevTel)

      #--   rafaichit secz et airmass de l'onglet Atmosphere
      lassign [getSecz $private(elevTel)] private(secz) private(airmass)
   }

   #----------------- proc associees aux combobox -----------------------------

   #---------------------------------------------------------------------------
   #  modifyBand
   #  Modifie les variables band et associees
   #---------------------------------------------------------------------------
   proc modifyBand { } {
      variable private
      global audace

      set audace(etc,param,object,band) $private(filter)
      etc_modify_band $private(filter)

      modifyPriority
   }

   #---------------------------------------------------------------------------
   #  modifyCamera
   #  Configure l'affichage des parametres de la camera
   #---------------------------------------------------------------------------
   proc modifyCamera { } {
      variable private

      #--   interdit 'Nouvelle camera'
      if {$private(detnam) eq "$::caption(collector,newCam)"} {
         addNewCam
         return
      }

      etc_set_camera $private(detnam)

      #--   recupere les valeurs de etc_tools
      foreach {var key} [list naxis1 naxis1 naxis2 naxis2 bin1 bin1 bin2 bin2 photocell1 photocell1 \
         photocell2 photocell2 eta eta gain G noise N_ro therm C_th ampli Em] {
         if {$var ni [list photocell1 photocell2]} {
            set private($var) $::audace(etc,param,ccd,$key)
         } else {
            #--   affiche la dimension des cellules en um
            set private($var) [expr { $::audace(etc,param,ccd,$key) * 1e6 }]
         }
      }

      computeCdeltFov
      computeCenterPixVal
      modifyPriority
   }

   #---------------------------------------------------------------------------
   #  modifyPriority
   #  Commande associee a la combobox du choix de la priorite
   #---------------------------------------------------------------------------
   proc modifyPriority { } {
      variable private
      global audace caption

      switch -exact [lsearch $caption(collector,prior_combo) $private(prior)] {
        0   {  #--   priorite au temps --> calcule la magnitude et snr
               etc_t2snr_computations
               set private(snr) $audace(etc,compsnr,SNR_obj)
               set private(error) [format %.3f [expr { 1.09 / $private(snr) }] ]
            }
        1   {  #--   priorite la magnitude --> calcule le temps et snr
               etc_snr2m_computations
               set private(error) [format %.3f [expr { 1.09 / $audace(etc,input,constraint,snr) }] ]
            }
        2   {  #--   priorite a snr --> calcule le temps et la magnitude
               etc_snr2t_computations
               set private(error) [format %.3f [expr { 1.09 / $audace(etc,input,constraint,snr) }] ]
            }
      }

      #-- conversion de fwhm (m) en (arcsec)
      set fwhm [expr { $audace(etc,comp1,Fwhm_psf) / $audace(etc,comp1,Foclen) * 180 / 4 / atan(1) * 3600 } ]

      #-- conversion de fwhm (arcsec) en (pixels)
      set private(fwhm) [format %0.2f [expr { $fwhm / $audace(etc,comp1,cdelt1) } ]]
   }

   #------------------------------------------------------------
   #  modifyRep
   #  Met a jour le chemin d'acces du repertoire choisi
   #------------------------------------------------------------
   proc modifyRep {} {
      variable private
      global audace

      switch -exact $private(catname) {
         MICROCAT { set private(catAcc) $audace(rep_userCatalogMicrocat)}
         USNO     { set private(catAcc) $audace(rep_userCatalogUsnoa2)}
      }
   }

   #------------------------------------------------------------
   #  refreshNotebook
   #  Met a jour les parametres et la vitesse du telescope
   #  Lancee par ::collector::configTraceRaDec
   #  pour les telescope qui donnent les coordonnees
   #------------------------------------------------------------
   proc refreshNotebook { args } {
      variable private
      global audace

      if {$private(telInitialise) ==0} {return}

      #--   met a jour les coordonnees visees a partir des coordonnees du telescope
      refreshCoordsJ2000 $audace(telescope,getra) $audace(telescope,getdec) EQUATORIAL

      computeTelSpeed

      if {[winfo exists $private(canvas)] == 1 && $private(german) == 1} {
         refreshMyTel
      }
   }

   #------------------------------------------------------------
   #  refreshCoordsJ2000
   #  Met a jour les coordonnees de la cible et du telescope
   #  Parametres : deux coordonnees et TypeObs
   #  couples :  {ra dec} EQUATORIAL ou {az elev} ALTAZ ou {hour_angle dec} HADEC
   #------------------------------------------------------------
   proc refreshCoordsJ2000 { coord1 coord2 TypeObs } {
      variable private
      global audace

      #--   rafraichit TU et JD
      lassign [getDateTUJD [::audace::date_sys2ut now]] private(tu) private(jd)

      #--   prepare la liste des donnees
      set tempK [expr { 273.15 + $private(tempair) }]
      set record [list $coord1 $coord2 $TypeObs $private(tu) $private(gps) $private(airpress) $tempK]

      #--   coordonnees J2000 du telescope
      lassign [getCoordJ2000 $record] private(ra) private(dec)

      computeTelCoord
      computeCenterPixVal
      computeTslMoon
   }

   #------------------------------------------------------------
   #  refreshMeteo : mise a jour de 'Météo'
   #  Lit les donnees de realtime.txt ou de infodata.txt
   #  Note : la temperature et la pression sont des variables de hip2tel
   #------------------------------------------------------------
   proc refreshMeteo { } {
      variable private

      #--   arrete si incoherence entre le nom du fichier et son chemin
      if {[file tail $private(meteoAcc)] ne "$private(sensname)"} {
         onChangeMeteo stop
         return
      }

      switch -exact $private(sensname) {
         realtime.txt {set result [readCumulus $private(meteoAcc)]}
         infodata.txt {set result [readSentinelFile $private(meteoAcc)]}
      }

      #--   compare les dates jd et arrete si l'ecart est superieur 10 cycles
      #     ou si le nb de donnes est incorrect
      set t1 [lindex $result 0]
      set t2 [mc_date2jd [clock format [clock seconds] -format "%Y %m %d %H %M %S" -timezone :localtime]]
      set delatTime [expr { $t2-$t1 }]
      set seuil [expr { 10.*$private(cycle)/86400 }]
      if {[llength $result] != 7 || $delatTime > $seuil} {
         onChangeMeteo stop
         return
      }

      #--   analyse les valeurs
      #--   elimine les unites
      set entities [list "\{" "" "\}" "" "°C" "" "%" "" "°" "" "m/s" "" "Pa" ""]
      set data [string map $entities [lrange $result 1 end]]

      lassign $data private(tempair) private(hygro) private(temprose) private(windsp) private(winddir) private(airpress)

      #--   note : ne pas oublier de regler le zero de la direction du vent dans Cumulus
      #     pour que le Sud corresponde a 0°

      set cycle [expr { $private(cycle)*1000 }] ; #convertit en ms
      after $cycle ::collector::refreshMeteo
    }

   #------------------------------------------------------------
   #  computeTelSpeed
   #  Met a jour la vitesse du telescope
   #------------------------------------------------------------
   proc computeTelSpeed { } {
      variable private

      #--   recupere les coordonnes actuelles du telescope
      set ra1 $private(raTel)
      set dec1 $private(decTel)
      set t1 $private(jd)

      if {[info exists private(previous)]} {
         lassign $private(previous) ra0 dec0 t0
         set private(previous) [list $ra1 $dec1 $t1]
      } else {
         #--   cas du demarrage
         set private(previous) [list $ra1 $dec1 $t1]
         return
      }

      #--   calcule les ecarts en degres
      set deltaRA [mc_anglescomp $ra1 - $ra0]
      set deltaDEC [mc_anglescomp $dec1 - $dec0]
      set deltaTime [expr { ( $t1 - $t0 ) * 86400 }]

      if {$deltaRA != "0" && $deltaDEC != 0 && $deltaTime != 0} {
         #--   calcule la vitesse de deplacement
         lassign [getMountSpeed $deltaRA $deltaDEC $deltaTime $private(cdelt1) $private(cdelt2) $private(crota2)] \
            vra vdec vxPix vyPix

         set private(vra) [format %0.5f $vra]
         set private(vdec) [format %0.5f $vdec]
         set private(vxPix) [format %0.1f $vxPix]
         set private(vyPix) [format %0.1f $vyPix]

      } else {
         set private(vra) [format %0.5f 0]
         set private(vdec) [format %0.5f 0]
         set private(vxPix) [format %0.1f 0]
         set private(vyPix) [format %0.1f 0]
      }
   }

