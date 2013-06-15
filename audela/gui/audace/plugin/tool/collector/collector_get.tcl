#
# Fichier : collector_get.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   # nom proc                    onglet      utilisee par
   # ::collector::getImgData        Cible       initTarget
   # ::collector::getTelPosition    Local       initLocal
   # ::collector::getDateExposure   Local       initLocal
   # ::collector::getTPW            Atmosphere  initAtm
   # ::collector::getKwdOptic       Optique     onChangeOptique
   # ::collector::getCamName        Camera      onChangeCam
   # ::collector::getObserv         Mots cles   onChangeObserver
   # ::collector::getObject         Mots cles   onChangeObjName

   # ::collector::getCoordJ2000     Cible       initTarget
   # ::collector::getTrueCoordinates Cible      computeCoordNow
   # ::collector::getCdeltFov       Vue         computeCdeltFov
   # ::collector::getImgCenterRaDec Vue         getImgData
   # ::collector::getMatchWCS       Vue         initPose
   # ::collector::getDateTUJD       Local       initLocal
   # ::collector::getTsl            Local       computeTslMoon
   # ::collector::getMoonAge        Local       computeTslMoon
   # ::collector::getSecz           Atmosphere  computeCoordApp
   # ::collector::getFonDResolution Optique     computeOptic
   # ::collector::getCamSpec        Camera      onChangeCam
   # ::collector::getTelConnexion   Monture     onChangeTelescop
   # ::collector::getSpeed          Monture     refreshSpeed
   # ::collector::getCD                         getSpeed, getImgCenterRaDec et createKeywords
   # ::collector::obsCoord2SiteCoord            magic
   # ::collector::getHrzDec         Allemande   refreshMyTel
   # ::collector::getNewCriticalFocusZone

   #--------------------- proc exploitant les mots cles -----------------------

   #---------------------------------------------------------------------------
   #  getImgData
   #  Retourne ra dec equinox naxis1 naxis2 bin1 bin2 xpixsz ypixsz \
   #     crota2 crval1 crval2 crpix1 crpix2 pixsize1 pixsize2
   #     ou des valeurs par defaut
   #  a partir des mots clés
   #---------------------------------------------------------------------------
   proc getImgData { bufNo } {

      set naxis1 [expr {[lindex [buf$bufNo getkwd NAXIS1] 1]}]
      if {$naxis1 eq ""} {set naxis1 1}

      set naxis2 [expr {[lindex [buf$bufNo getkwd NAXIS2] 1]}]
      if {$naxis2 eq ""} {set naxis2 1}

      set crota2 [expr {[lindex [buf$bufNo getkwd CROTA2] 1]}]
      if {$crota2 eq ""} {
         set crota2 0
         buf$bufNo setkwd [list CROTA2 $crota2 double "\[deg\] position angle of North" deg]
      }

      set cdelt1 [expr {[lindex [buf$bufNo getkwd CDELT1] 1]}]
      if {$cdelt1 eq ""} {set cdelt1 "-"}

      set cdelt2 [expr {[lindex [buf$bufNo getkwd CDELT2] 1]}]
      if {$cdelt2 eq ""} {set cdelt2 "-"}

      set crpix1 [expr {[lindex [buf$bufNo getkwd CRPIX1] 1]}]
      if {$crpix1 eq ""} {set crpix1 "-"}

      set crpix2 [expr {[lindex [buf$bufNo getkwd CRPIX2] 1]}]
      if {$crpix2 eq ""} {set crpix2 "-"}

      set crval1 [expr {[lindex [buf$bufNo getkwd CRVAL1] 1]}]
      if {$crval1 eq ""} {set crval1 "-"}

      set crval2 [expr {[lindex [buf$bufNo getkwd CRVAL2] 1]}]
      if {$crval2 eq ""} {set crval2 "-"}

      set bin1 [expr {[lindex [buf$bufNo getkwd BIN1] 1]}]
      if {$bin1 eq ""} {set bin1 1}

      set bin2 [expr {[lindex [buf$bufNo getkwd BIN2] 1]}]
      if {$bin2 eq ""} {set bin2 1}

      set equinox [expr {[lindex [buf$bufNo getkwd EQUINOX] 1]}]
      if {$equinox eq ""} {set equinox "J2000.0"}

      set xpixsz [expr {[lindex [buf$bufNo getkwd XPIXSZ] 1]}]
      if {$xpixsz eq ""} {set xpixsz "-"}

      set ypixsz [expr {[lindex [buf$bufNo getkwd YPIXSZ] 1]}]
      if {$ypixsz eq ""} {set ypixsz "-"}

      set pixsize1 [expr {[lindex [buf$bufNo getkwd PIXSIZE1] 1]}]
      if {$pixsize1 eq ""} {
         if {$bin1 ne "" && $xpixsz ne "-"} {
            set pixsize1 [expr { $xpixsz * $bin1 }]
         } else {
            set pixsize1 "-"
         }
      }

      set pixsize2 [expr {[lindex [buf$bufNo getkwd PIXSIZE2] 1]}]
      if {$pixsize2 eq ""} {
         if {$bin2 ne "" && $ypixsz ne "-"} {
            set pixsize2 [expr { $ypixsz * $bin2 }]
         } else {
            set pixsize2 "-"
         }
      }

      set ra [expr {[lindex [buf$bufNo getkwd RA] 1]}]
      if {$ra eq ""} {set ra "-"}

      set dec [expr {[lindex [buf$bufNo getkwd DEC] 1]}]
      if {$dec eq ""} {set dec "-"}

      #--   recalcule les coordonnees au centre de l'immage
      set result [getImgCenterRaDec $naxis1 $naxis2 $crota2 $cdelt1 $cdelt2 $crpix1 $crpix2 $ra $dec]
      lassign $result crpix1 crpix2 crval1 crval2

      set ra [mc_angle2hms $crval1 360 zero 2 auto string]
      set dec [mc_angle2dms $crval2 90 zero 2 + string]

      set result [list $ra $dec $equinox $naxis1 $naxis2 $bin1 $bin2 $xpixsz $ypixsz \
         $crota2 $crval1 $crval2 $crpix1 $crpix2 $pixsize1 $pixsize2]

      return $result
   }

   #---------------------------------------------------------------------------
   #  getTelPosition
   #  Retourne la position GPS au format home lors de la prise de vue avec
   #  "OBS-ELEV" "OBS-LAT" "OBS-LONG" ou SITEELEV SITELAT SITELONG
   #---------------------------------------------------------------------------
   proc getTelPosition { bufNo } {

      set tel_gps "-"

      set obs_elev [expr {[lindex [buf$bufNo getkwd OBS-ELEV] 1]}]
      set obs_lat [expr {[lindex [buf$bufNo getkwd OBS-LAT] 1]}]
      set obs_long [expr {[lindex [buf$bufNo getkwd OBS-LONG] 1]}]

      if {$obs_elev ne "" && $obs_lat ne "" && $obs_long ne "" } {

         if {$obs_long > 0} {
            set sens E
         }  else {
            set obs_long [expr {-1.*$obs_long}]
            set sens W
         }
         set tel_gps "GPS $obs_long $sens $obs_lat $obs_elev"

      } else {

         set siteelev [lindex [buf$bufNo getkwd SITEELEV] 1]
         set sitelat [lindex [buf$bufNo getkwd SITELAT] 1]
         set sitelong [lindex [buf$bufNo getkwd SITELONG] 1]

         if {$siteelev ne "" && $sitelat ne "" && $sitelong ne ""} {
            #--   extrait E ou W
            set sens [string index $sitelong 0]
            #--   transforme la longitude en angle
            set sitelong [string range $sitelong 1 end]
            set longitude [string trim [mc_angle2deg $sitelong] ]
            #--   transforme la latitude en angle
            set sitelat [string range $sitelat 1 end]
            set latitude [string trim [mc_angle2deg $sitelat]]
            set tel_gps "GPS $longitude $sens $latitude $siteelev"
         }
      }

      return $tel_gps
   }

   #---------------------------------------------------------------------------
   #  getDateExposure
   #  Retourne la duree d'exposition et la date (temps julien) du milieu de la pose
   #  exposure vaut 1 si pas defini ou =0
   #  datejd = "" si pas DATE-OBS
   #  S'applique aux images Tarot et aux autres
   #---------------------------------------------------------------------------
   proc getDateExposure { bufNo } {

      set exposure [lindex [buf$bufNo getkwd EXPOSURE] 1]
      if {$exposure eq ""} {
         set exposure [lindex [buf$bufNo getkwd EXPTIME] 1]
         if {$exposure eq ""} {
            set exposure 1
         }
      }

      set date-obs [lindex [buf$bufNo getkwd DATE-OBS] 1]
      if { ${date-obs} ne "" } {
         set datejd [mc_datescomp ${date-obs} + [expr $exposure/2./86400.]]
      } else {
         set date-obs "-"
         set datejd "-"
      }

      return [list $exposure ${date-obs} $datejd ]
   }

   #---------------------------------------------------------------------------
   #  getTPW
   #  Retourne : temperature °C, temperature de rosee °C, hygrometrie %,
   #     direction (degres) et vitesse du vent (m/s), pression atmosphrique Pa
   #---------------------------------------------------------------------------
   proc getTPW { bufNo } {

      set tempair [lindex [buf$bufNo getkwd TEMPAIR] 1]
      if {$tempair eq ""} {set tempair [expr {290-273.15}]}
      set tempair [format %0.2f $tempair]

      set temprose [lindex [buf$bufNo getkwd TEMPROSE] 1]
      if {$temprose eq ""} {set temprose "-"}

      set hygro [lindex [buf$bufNo getkwd HYGRO] 1]
      if {$hygro eq ""} {
         set hydro [lindex [buf$bufNo getkwd HYDRO] 1]
         if {$hygro ne ""} {
            set hygro $hydro
         } else {
            set hygro "-"
         }
      }

       set winddir [lindex [buf$bufNo getkwd WINDDIR] 1]
      if {$winddir eq ""} {set winddir "-"}

      set windsp [lindex [buf$bufNo getkwd WINDSP] 1]
      if {$windsp eq ""} {set windsp "-"}

      set windsp [lindex [buf$bufNo getkwd TEMPROSE] 1]
      if {$windsp eq ""} {set windsp "-"}

      set airpress [lindex [buf$bufNo getkwd AIRPRESS] 1]
      if {$airpress eq ""} {
         set airpress 101325
      } else {
          set unit [string trim [lindex [buf$bufNo getkwd AIRPRESS] 4]]
           if {$unit eq "hPa"} {
            set airpress [expr {$airpress*100}]
         }
      }

      return [list $tempair $temprose $hygro $windsp $winddir $airpress]
   }

   #---------------------------------------------------------------------------
   #  getKwdOptic
   #  Retourne : nom du telescope, diametre, longueur focale, F/D et filtre
   #---------------------------------------------------------------------------
   proc getKwdOptic { bufNo } {

      set aptdia [lindex [buf$bufNo getkwd APTDIA] 1]
      if {$aptdia eq ""} {set aptdia "-"}

      set filter [string trim [lindex [buf$bufNo getkwd FILTER] 1]]
      if {$filter eq ""} {set filter "C"}

      set foclen [lindex [buf$bufNo getkwd FOCLEN] 1]
      if {$foclen eq ""} {
         set foclen "-"
      } else {
         set foclen [format %0.3f $foclen]
      }

      set telescop [lindex [buf$bufNo getkwd TELESCOP] 1]
      if {$telescop eq ""} {set telescop "-"}

      #--   definition de APTDIA pour les telescopes Tarot
      if {$aptdia eq "-" && ($telescop eq "TAROT CALERN" || $telescop eq "TAROT CHILI")} {
         set aptdia 0.250
      }
      if {$aptdia ne "-"} {set aptdia [format %0.3f $aptdia]}

      return [list $telescop $aptdia $foclen $filter]
   }

   #---------------------------------------------------------------------------
   #  getCamName
   #  Retourne le nom de la cam a partir de CAMERA, DETNAM ou INSTRUME ou un tiret
   #  S'applique aux images Tarot et aux autres
   #---------------------------------------------------------------------------
   proc getCamName { bufNo } {

      set cam "-"

      foreach kwd [list CAMERA DETNAM INSTRUME] {
         set data [buf$bufNo getkwd $kwd]
         if {[lindex $data 0] ne ""} {
               #--   des fois que le nom soit un string avec des espaces
               set detnam [string trimleft [lindex $data 1] " "]
               set detnam [string trimright $detnam " "]
               if {$detnam ne ""} {
                  set cam $detnam
                  break
               }
         }
      }

      if {$cam ne "-"} {
         if {$cam in [etc_set_camera]} {
            #--
         } else {
            if {[string first DV436 $cam] ne "-1"} {
               set cam  "Andor DW436"
            }
         }
      }

      set xpixsz [lindex [buf$bufNo getkwd XPIXSZ] 1]
      set ypixsz [lindex [buf$bufNo getkwd YPIXSZ] 1]
      if {$xpixsz eq ""} {set xpixsz "-"}
      if {$ypixsz eq ""} {set ypixsz "-"}

      return [list $cam $xpixsz $ypixsz]
   }

   #---------------------------------------------------------------------------
   #  getObserv
   #  Retourne le nom de l'observateur et le nom du site
   #---------------------------------------------------------------------------
   proc getObserv { bufNo } {

      set observer [lindex [buf$bufNo getkwd OBSERVER] 1]
      if {$observer eq ""} {set observer "-"}
      set sitename [lindex [buf$bufNo getkwd SITENAME] 1]
      if {$sitename eq ""} {set sitename "-"}

      return [list $observer $sitename]
   }

   #---------------------------------------------------------------------------
   #  getObject
   #  Retourne le type d'image et le nom de l'objet
   #---------------------------------------------------------------------------
   proc getObject { bufNo } {

      set imagetyp [lindex [buf$bufNo getkwd IMAGETYP] 1]
      if {$imagetyp eq ""} {set imagetyp "-"}
      set objname [lindex [buf$bufNo getkwd OBJNAME] 1]
      if {$objname eq ""} {set objname "-"}

      return [list $imagetyp $objname]
   }

   #--------------------- proc de calcul --------------------------------------

   #---------------------------------------------------------------------------
   #  getCoordJ2000
   #  Retourne        : Ra et Dec (equinoxe J2000.0) formatees
   #  Parametres (une seule liste)
   #      deux coordonnees et TypeObs, couples :  {ra dec} EQUATORIAL ou {az elev} ALTAZ ou {hour_angle dec} HADEC
   #      datejd      : date JD
   #      home        : gps
   #      airpress    : atmospheric pressure (Pa)
   #      temperature : °K
   #---------------------------------------------------------------------------
   proc getCoordJ2000 { record } {

      lassign $record angle1 angle2 TypeObs dateTu home airpress tempair

      set symbols  { IH ID NP CH ME MA FO HF DAF TF }
      set nulCoeff [list 0 0 0 0 0 0 0 0 0 0]

      #--   pm avec les options -model_only 1 -refraction 1, les coordonnees sont corrigées de
      #  la nutation, de l'aberration diurne, de la precession, de l'aberration annuelle et de le refraction
      lassign [mc_tel2cat [list $angle1 $angle2] $TypeObs $dateTu $home $airpress $tempair $symbols $nulCoeff -model_only 1 -refraction 1] \
         raDeg decDeg

      set ra2000 [mc_angle2hms $raDeg 360 zero 2 auto string]
      set dec2000 [mc_angle2dms $decDeg 90 zero 2 + string]

      return [list $ra2000 $dec2000]
   }

   #---------------------------------------------------------------------------
   #  getTrueCoordinates
   #  Retourne azimuth, elevation et angle horaire
   #     Input :
   #       ra_hms,dec_dms : coordinates J2000.0
   #       datetu   : date TU
   #       home     : gps
   #       airpress : atmospheric pressure (Pa)
   #       temperature : °K
   #  Derive de viseur_polaire_taka.tcl/viseurPolaireTaka::HA_Polaire
   #     Output :
   #         rav,decv : true coordinates ((hms,dms))
   #         ha  : true hour angle (hms)
   #         az : true azimut (degrees)
   #         elev : true altitude (degrees)
   #---------------------------------------------------------------------------
   proc getTrueCoordinates { data } {

      lassign $data ra_hms dec_dms datetu home airpress temperature

      set symbols  { IH ID NP CH ME MA FO HF DAF TF }
      set nulCoeff [list 0 0 0 0 0 0 0 0 0 0]

      set hipRecord    [list 1 1 [mc_angle2deg $ra_hms] [mc_angle2deg $dec_dms 90] J2000.0 J2000.0 0 0 0]
      set result [mc_hip2tel $hipRecord $datetu $home $airpress $temperature $symbols $nulCoeff -model_only 1 -refraction 1]

      #--   pm prend les valeurs avec modele
      lassign [lrange $result 10 14] ra_angle dec_angle ha az elev

      #--- formate les resultats
      set raTel [mc_angle2hms $ra_angle 360 zero 2 auto string]
      set decTel [mc_angle2dms $dec_angle 90 zero 2 + string]
      lassign [mc_angle2hms $ha 360] h m s
      set haTel [format "%02dh%02dm%02ds" $h $m [expr { int($s) }]]

      #--   si l'elevation est tres proche de 90 --> zenith
      if {$elev > 89.99} {set az 0.0}
      set azTel [format %.2f $az]
      set elevTel [format %.2f $elev]

      return [list $raTel $decTel $haTel $azTel $elevTel]
   }

   #---------------------------------------------------------------------------
   #  getCdeltFov
   #  Retourne les cdelt en arcsec/pixel et les fov en degres
   #  Parametres : dimension des pixels (avec bining) en um,
   #     nombre de pixels dans l'image, longueur focale en m
   #  Derive de surchaud.tcl/simulimage
   #---------------------------------------------------------------------------
   proc getCdeltFov { naxis1 naxis2 pixsize1 pixsize2 foclen } {

      #--   test OR
      if {"-" in [list $naxis1 $naxis2 $pixsize1 $pixsize2 $foclen]} {
         return [lrepeat 4 -]
      }

      set factor [expr { 360. / (4*atan(1.)) }]

      set tgx [expr { $pixsize1 * 1e-6 / $foclen / 2. }]
      set tgy [expr { $pixsize2 * 1e-6 / $foclen / 2. }]

      set cdeltx [expr { -atan ($tgx) * $factor * 3600. }]
      set cdelty [expr { atan ($tgy) * $factor * 3600. }]

      set fovx [expr { atan ( $naxis1 * $tgx ) * $factor }]
      set fovy [expr { atan ( $naxis2 * $tgy ) * $factor }]

      return [list $cdeltx $cdelty $fovx $fovy]
   }

   #------------------------------------------------------------
   #  getImgCenterRaDec
   #  Retourne la liste des coordonnees RaDec du centre de l'image
   #  Parametres : naxis1 naxis2 crota2 cdelt1 cdelt2 crpix1 crpix2 ra dec
   #  issus des mot cles d'une image (les valeurs angulaires sont en degres)
   #  Derive de sn_tarot_macros.tcl/getImgCenterRaDec
   #------------------------------------------------------------
   proc getImgCenterRaDec { naxis1 naxis2 crota2 cdelt1 cdelt2 crpix1 crpix2 ra dec } {

      #--   test OR
      if {"-" in [list $naxis1 $naxis2 $crota2 $cdelt1 $cdelt2 $crpix1 $crpix2 $ra $dec]} {
         return [lrepeat 4 -]
      }

      set crval1 [string trim [mc_angle2deg $ra]]
      set crval2 [string trim [mc_angle2deg $dec]]

      set pi [ expr { 4 * atan(1) } ]

      set center_x [ expr { $naxis1 / 2. }]
      set center_y [ expr { $naxis2 / 2. }]

      lassign [getCD $cdelt1 $cdelt2 $crota2] cd1_1 cd1_2 cd2_1 cd2_2
      set dra  [expr { $cd1_1 * ($center_x - ($crpix1-0.5)) + $cd1_2 * ($center_y - ($crpix2-0.5)) }]
      set ddec [expr { $cd2_1 * ($center_x - ($crpix1-0.5)) + $cd2_2 * ($center_y - ($crpix2-0.5)) }]

      set coscrval2 [expr { cos( $crval2 * $pi / 180. ) }]
      set sincrval2 [expr { sin( $crval2 * $pi / 180. ) }]

      set delta [expr { $coscrval2 - $ddec * $sincrval2 }]
      set gamma [expr { hypot($dra,$delta) }]

      set ra [expr { $crval1 + 180./ $pi * atan( $dra / $delta ) }]
      set dec [expr { 180. / $pi * atan( ( $sincrval2 + $ddec* $coscrval2 ) / $gamma ) }]

      return [list $center_x $center_y $ra $dec]
   }

   #------------------------------------------------------------
   #  getMatchWCS
   #  Retourne le code et les valeurs pour simulimage
   #  Parametres : ra dec pixsize1 pixsize2 foclen cdelt1 cdelt2 \
   #  crpix1 crpix2 crval1 crval2
   #  Derive de surchaud.tcl/simulimage
   #------------------------------------------------------------
   proc getMatchWCS { ra dec pixsize1 pixsize2 foclen cdelt1 cdelt2 crpix1 crpix2 crval1 crval2 } {

      set  match_wcs 0

      if {$foclen ne ""} {
         if {"-" ni [list $cdelt1 $cdelt2 $crpix1 $crpix2 $crval1 $crval2]} {
            #--   contient tous les mots cles WCS pour simulimage * * * * *
            set  match_wcs [list 2 * * * * * ]
         } else {
            if {"-" ni [list $ra $dec $pixsize1 $pixsize2]} {
               #--   peut etre traite par simulimage mais il faut passer les parametres
               set match_wcs [list 1 $ra $dec $pixsize1 $pixsize2 $foclen]
            }
         }
      }

      return $match_wcs
   }

   #------------------------------------------------------------
   #  getDateTUJD
   #  Retourne : date TU et JD correctement formates
   #  Parametre : date
   #------------------------------------------------------------
   proc getDateTUJD { date } {

      set tu [mc_date2iso8601 $date]
      set jd [mc_date2jd $tu]

      return [list $tu $jd]
   }

   #---------------------------------------------------------------------------
   #  getTsl
   #  Retourne TSL formate
   #  Parametres : date TU et coordonnees GPS
   #---------------------------------------------------------------------------
   proc getTsl { datetu home } {

      set tsl "-"

      if {"-" ni [list $datetu $home]} {
         lassign [mc_date2lst $datetu $home] h m s
         set tsl [format "%02dh%02dm%02ds" $h $m [expr {int($s)}]]
      }

      return $tsl
   }

   #---------------------------------------------------------------------------
   #  getMoonAge
   #  Retourne : age de la Lune en fonction du lieu et de la date de prise de vue
   #  Parametres : date JD et position GPS
   #---------------------------------------------------------------------------
   proc getMoonAge { datejd home } {

      if {"-" in [list $datejd $home]} {return [list - - 0]}

      #--   calcule l'ephemeride de la Lune
      lassign [lindex [mc_ephem moon $datejd {PHASE ALTITUDE} -topo $home] 0] phase elev

      #--   calcule l'age de la lune
      set moon_age 0
      if {$elev > 0} {
         set moon_age [expr {(180-$phase)/180.*14.}]
      }
      foreach v [list phase elev moon_age] {
         set $v [format %.2f [set $v]]
      }

      return [list $phase $elev $moon_age]
   }

   #---------------------------------------------------------------------------
   #  getSecz
   #  Retourne : secz et airmass
   #  Parametre : elevation du telescope (corrige de le refraction, etc.)
   #---------------------------------------------------------------------------
   proc getSecz { elev } {

      lassign [list -1 -1] secz airmass

      set elev_deg [mc_angle2deg $elev]

      if {$elev_deg > 0} {
         set z [expr {90.-$elev_deg}]
         set secz [expr {1./cos($z)}]
         set airmass [expr { $secz-0.0018167*$secz+0.02875*$secz*$secz+0.0008083*$secz*$secz*$secz }]
         set secz [format %0.3f $secz]
         set airmass [format %0.3f $airmass]
      }

      return [list $secz $airmass]
   }

   #---------------------------------------------------------------------------
   #  getFonDResolution
   #  Retourne F/D et la resolution ou un tiret pour une valeur vide
   #  Parametres : diametre et longueur focale en m
   #  Inspire de confoptic.tcl/Calculette
   #---------------------------------------------------------------------------
   proc getFonDResolution { aptdia foclen } {

      if {$aptdia > 0 && $foclen > 0} {
         set fond [format %.2f [expr {$foclen*1./$aptdia}]]
         set resolution [format %.3f [expr {0.120/$aptdia}]]
      } else {
         #--   valeurs par defaut
         lassign [list - -] fond resolution
      }

      return [list $fond $resolution]
   }

   #---------------------------------------------------------------------------
   #  getCamSpec
   #  Retourne le nom de la cam et les dimensions des pixels d'une cam connectee
   #---------------------------------------------------------------------------
   proc getCamSpec { {visuNo 1} } {

      set camItem [::confVisu::getCamItem $visuNo]
      set camNo  [::confCam::getCamNo $camItem]
      if {$camNo == 0} {return [lrepeat 5 -]}

      lassign [cam$camNo info] -> camName detector
      lassign [cam$camNo nbpix] naxis1 naxis2
      lassign [cam$camNo celldim] celldim1 celldim2
      set photocell1 [expr { $celldim1 * 1e6 }]
      set photocell2 [expr { $celldim2 * 1e6 }]

      return [list $camName $camItem $naxis1 $naxis2 $photocell1 $photocell2]
   }

   #------------------------------------------------------------
   #  getTelConnexion
   #  Retourne le nom de la monture, le modele,
   #  les proprietes hasCoordinates et hasControlSuivi
   #------------------------------------------------------------
   proc getTelConnexion { {telNo 1} } {
      global conf caption

      lassign [list - - 0 0 0] product name hasCoordinates hasControlSuivi

      #--   passe en minuscules
      set product [string tolower [tel$telNo product]]
      #--   supprime les espaces dans 'delta tau'
      set product [string map -nocase [list " " ""] $product]

      foreach propertyName [list name hasCoordinates hasControlSuivi] {
         set $propertyName [::${product}::getPluginProperty $propertyName]
      }

      if {[::${product}::getPluginProperty hasModel] == 1} {
         switch -exact $name {
            ASCOM {  set model [lindex $conf(ascom,modele) 1 ]}
            LX200 {  set model $conf(lx200,modele)}
            Temma {  set modelNo $conf(temma,modele)
                     incr modelNo
                     set model $caption(temma,modele_$modelNo)
                  }
         }
         append name " ($model)"
      }

      return [list $product "$name" $hasCoordinates $hasControlSuivi]
   }

   #------------------------------------------------------------
   #  getMountSpeed
   #  Retourne les vitesses de deplacement en deg/sec et en pix/sec
   #  Parametres : cdelt en arcsec/pix
   #------------------------------------------------------------
   proc getMountSpeed { deltaRA deltaDEC deltaTime cdelt1 cdelt2 crota2 } {

      set vra [expr { $deltaRA/$deltaTime }]
      set vdec [expr { $deltaDEC/$deltaTime }]

       #--   initialisation
      lassign [list 0 0] vxPix vyPix

      if {"-" ni [list $cdelt1 $cdelt2 $crota2]} {
         #--   repasse en degres
         set cdelt1 [expr { $cdelt1 / 3600. }]
         set cdelt2 [expr { $cdelt2 / 3600. }]
         lassign [getCD $cdelt1 $cdelt2 $crota2] cd1_1 cd1_2 cd2_1 cd2_2
         if {$cd1_1 !=0} {set vxPix [expr { $vxPix + ($vra / $cd1_1) }]}
         if {$cd1_2 !=0} {set vxPix [expr { $vxPix + ($vdec / $cd1_2) }]}
         if {$cd2_1 !=0} {set vyPix [expr { $vyPix + ($vra / $cd2_1) }]}
         if {$cd2_2 !=0} {set vyPix [expr { $vyPix + ($vdec / $cd2_2) }]}
      }

      return [list $vra $vdec $vxPix $vyPix]
   }

   #------------------------------------------------------------
   #  getCD
   #  Retourne les coefficients CD en degre/pixel
   #  Parametres : crota2 (degres), cdelt1 et cdelt2 (degres/pixel)
   #  Derive de sn_tarot_macros.tcl/getImgCenterRaDec
   #------------------------------------------------------------
   proc getCD { cdelt1 cdelt2 crota2 } {

      set factor [expr { 4 * atan(1) / 180. } ]
      set coscrota2 [expr { cos($crota2 * $factor ) }]
      set sincrota2 [expr { sin($crota2 * $factor ) }]

      set cd1_1 [expr { $cdelt1 * $coscrota2 }]
      set cd1_2 [expr { abs($cdelt2) * $cdelt1 / abs($cdelt1) * $sincrota2 }]
      set cd2_1 [expr { -abs($cdelt1) * $cdelt2 / abs($cdelt2) * $sincrota2 }]
      set cd2_2 [expr { $cdelt2 * $coscrota2 }]

      return [list $cd1_1 $cd1_2 $cd2_1 $cd2_2]
   }

   #------------------------------------------------------------
   #  obsCoord2SiteCoord
   #  Retourne les valeurs des mots cles SITExxxx
   #  Parametre : position GPS
   #------------------------------------------------------------
   proc obsCoord2SiteCoord { home } {

      lassign $home -> obs-long sens obs-lat siteelev

      set sitelong [mc_angle2dms ${obs-long} 180 zero 2 auto string]
      set sitelong $sens$sitelong

      set sitelat [mc_angle2dms ${obs-lat} 90 zero 2 auto string]
      if {${obs-lat} >0} {
         set sitelat "N${sitelat}"
      } else {
         set sitelat [expr {-1*${obs-lat}}]
         set sitelat [mc_angle2dms ${obs-lat} 90 zero 2 auto string]
         set sitelat "S$sitelat"
      }

      return [list $sitelong $sitelat $siteelev]
   }

   #------------------------------------------------------------
   #  getHrzDec
   #  Retourne la valeur de la declinaison (en degres) de l'horizon
   #  Parametres : latitude en degres et angle horaire (en hms)
   #------------------------------------------------------------
   proc getHrzDec { latitude ha } {

      set lat_rad [mc_angle2rad $latitude]
      set ha_rad [mc_angle2rad $ha]
      set tanHrz [expr { -cos($ha_rad) / tan($lat_rad) }]
      set decHrz [expr { atan($tanHrz) * 180/(4*atan(1.)) }]

      return $decHrz
   }

   #---------------------------------------------------------------------------
   #  getNewCriticalFocusZone
   #  Retourne la zone (um) de mise au point
   #  Parametres : F/D , diametre (m), total seeing (arcsec) et error (%seeing)
   #---------------------------------------------------------------------------
   proc getNewCriticalFocusZone { fond aptdia seeing error } {

      set ncfz "-"
      if {[info exists $fond] && [info exists $aptdia]} {

         set constante 0.00225 ; # micrometers/arc second/millimeter
         set ncfz [format %0.1f [expr { $constante*$seeing*sqrt($error)*$fond*$fond*$aptdia*1000 } ]] ;#-- microns
      }

      return $ncfz
   }

