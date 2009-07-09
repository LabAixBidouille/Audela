#
# Fichier : camerathread.tcl
# Description : procedures d'acqusitition et de traitement avec
#         plusieurs cameras simultan�es exploitant le mode multithread
# Auteur : Michel PUJOL
# Mise a jour $Id: camerathread.tcl,v 1.11 2009-07-09 17:24:55 michelpujol Exp $
#

namespace eval ::camerathread {

}

proc ::camerathread::init { camItem camNo mainThreadNo} {
   variable private

   set private(camItem)       $camItem
   set private(camNo)         $camNo
   set private(mainThreadNo)  $mainThreadNo
   set private(bufNo)         [cam$camNo buf]
   set private(acquisitionState)  0
   set private(test)          0

   set private(synchroneParameter) ""
}


#------------------------------------------------------------
# stopAcquisition
#    arrete l'acquisition en cours
#
#------------------------------------------------------------
proc ::camerathread::stopAcquisition { } {
   variable private

   set private(acquisitionState) "0"
   set statusVariableName "::status_cam$private(camNo)"
   if { [set $statusVariableName] == "exp" } {
      cam$private(camNo) stop
   }
}


#------------------------------------------------------------
# acquisition
#    fait une acquisition
#  in    camNo
#  in    visuNo
#  in    bufNo
#  in    private(mode)
#
#------------------------------------------------------------
proc ::camerathread::acquisition { exptime } {
   variable private

   set private(mode)             "acq"
   set private(exptime)          $exptime
   set private(acquisitionState) "1"
   set private(acquisitionResult)     ""
   set private(originCoord)      ""
   set private(targetCoord)      ""
   set private(mountEnabled)     "0"
   set private(intervalle)        "0"
   set private(declinaisonEnabled) 1

   ##::camerathread::disp "::camerathread::acquisition \n"

   #--- je lance une acquisition
   ::camerathread::processAcquisition
}

#------------------------------------------------------------
# centerBrightestStar
#    centre le telescope sur l'etoile la plus brillante dans une zone
#
# Parametres :
#  originCoord    : coordonnees de la destination du centrage
#  targetCoord    : coordonnees du centre de la zone de recherche de l'etoile
#  angle          : angle d'inclinaison de la camera (en degree decimaux)
#  targetBoxSize  : taille de la zone de recherche
#  mountEnabled   :
#  alphaSpeed     : coefficient de rattrapage de la monture en alpha (ms/pixels)
#  deltaSpeed     : coefficient de rattrapage de la monture en delta (ms/pixels)
#  alphaReverse   : sens de rattrapage de la monture en alpha (0=normal ou 1=inverse)
#  deltaReverse   : sens de rattrapage de la monture en delta (0=normal ou 1=inverse)
#  deltaReverse   : sens de rattrapage de la monture en delta (0=normal ou 1=inverse)
#  seuilx         : seuil minimal de rattrapage sur l'axe des x (pixels)
#  seuily         : seuil minimal de rattrapage sur l'axe des y (pixels)
#
# retour :
#  Retourne 0 si le centrage demarre correctement, sinon retourne 1
#  La fin du centrage est notifie par le message "acquisitionResult" contenant les ccordonnes de l'etoile
#
#------------------------------------------------------------

#------------------------------------------------------------
proc ::camerathread::centerBrightestStar { exptime originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily } {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(mode)          "center"
   set private(exptime)       $exptime
   set private(detection)     "PSF"
   set private(originCoord)   $originCoord
   set private(targetCoord)   $targetCoord
   set private(targetBoxSize) $targetBoxSize
   set private(angle)         $angle
   set private(mountEnabled)  $mountEnabled
   set private(alphaSpeed)    $alphaSpeed
   set private(deltaSpeed)    $deltaSpeed
   set private(alphaReverse)  $alphaReverse
   set private(deltaReverse)  $deltaReverse
   set private(seuilx)        $seuilx
   set private(seuily)        $seuily
   set private(intervalle)    0.3
   set private(declinaisonEnabled) 1

   set private(previousAlphaDirection)   "e"
   set private(previousDeltaDirection)   "n"
   set private(acquisitionState) "1"
   set private(acquisitionResult)     ""
   set private(previousClock)    "0"
   set private(centerDeltaList)   ""
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]

   #--- je lance la boucle de centrage
   ::camerathread::processAcquisition
}

#------------------------------------------------------------
proc ::camerathread::centerRadec { exptime originCoord radec angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily foclen detection catalogue kappa threshin fwhm radius threshold maxMagnitude delta epsilon catalogueName cataloguePath } {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(mode)          "center"
   set private(exptime)       $exptime
   set private(detection)     "CALIBRE"
   set private(radec)         $radec
   set private(catalogueName) $catalogueName
   set private(cataloguePath) $cataloguePath

   set private(originCoord)   $originCoord
   set private(targetCoord)   $originCoord
   set private(targetBoxSize) $targetBoxSize
   set private(angle)         $angle
   set private(mountEnabled)  $mountEnabled
   set private(alphaSpeed)    $alphaSpeed
   set private(deltaSpeed)    $deltaSpeed
   set private(alphaReverse)  $alphaReverse
   set private(deltaReverse)  $deltaReverse
   set private(seuilx)        $seuilx
   set private(seuily)        $seuily
   set private(intervalle)    0
   set private(declinaisonEnabled) 1

   set private(foclen)        $foclen
   set private(detection)     $detection
   set private(catalogue)     $catalogue
   set private(kappa)         $kappa
   set private(threshin)      $threshin
   set private(fwhm)          $fwhm
   set private(radius)        $radius
   set private(threshold)     $threshold
   set private(maxMagnitude)  $maxMagnitude
   set private(delta)         $delta
   set private(epsilon)       $epsilon

   set private(previousAlphaDirection)   "e"
   set private(previousDeltaDirection)   "n"
   set private(centerDeltaList)        ""
   set private(acquisitionState) "1"
   set private(acquisitionResult)     ""
   set private(previousClock)    "0"

   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]

   #--- je lance la boucle de centrage
   ::camerathread::processAcquisition
}

#------------------------------------------------------------
proc ::camerathread::guide { exptime detection originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily slitWidth slitRatio intervalle declinaisonEnabled} {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(mode)          "guide"
   set private(detection)     $detection
   set private(exptime)       $exptime
   set private(originCoord)   $originCoord
   set private(targetCoord)   $targetCoord
   set private(targetBoxSize) $targetBoxSize
   set private(angle)         $angle
   set private(mountEnabled)  $mountEnabled
   set private(alphaSpeed)    $alphaSpeed
   set private(deltaSpeed)    $deltaSpeed
   set private(alphaReverse)  $alphaReverse
   set private(deltaReverse)  $deltaReverse
   set private(seuilx)        $seuilx
   set private(seuily)        $seuily
   set private(slitWidth)     $slitWidth
   set private(slitRatio)     $slitRatio
   set private(intervalle)    $intervalle
   set private(declinaisonEnabled) $declinaisonEnabled

   set private(previousAlphaDirection)   "e"
   set private(previousDeltaDirection)   "n"
   set private(centerDeltaList)        ""
   set private(acquisitionState) "1"
   set private(previousClock)    "0"
   set private(dynamicDectection) "SLIT"

   ##::camerathread::disp  "::camerathread::guide private(detection)=$private(detection)\n"

   #--- je lance la boucle de guidage
   ::camerathread::processAcquisition
}


#------------------------------------------------------------
proc ::camerathread::searchBrightestStar { exptime originCoord targetBoxSize threshin fwhm radius threshold } {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(mode)             "search"
   set private(detection)        "PSF"
   set private(exptime)          $exptime
   set private(originCoord)      $originCoord
   set private(targetCoord)      ""
   set private(targetBoxSize)    $targetBoxSize
   set private(mountEnabled)     "0"
   set private(threshin)         $threshin
   set private(fwhm)             $fwhm
   set private(radius)           $radius
   set private(threshold)        $threshold
   set private(intervalle)       0
   set private(declinaisonEnabled) 1

   set private(previousAlphaDirection)   "e"
   set private(previousDeltaDirection)   "n"
   set private(centerDeltaList)           ""
   set private(acquisitionState) "1"
   set private(previousClock)    "0"


   #--- je lance une recherche
   ::camerathread::processAcquisition
}

proc ::camerathread::processAcquisition { } {
   variable private

   ###::camerathread::disp  "::camerathread::processAcquisition \n"

   if {  $private(intervalle) < 0.1 } {
      set private(intervalle)  0.1
   }

   #--- je parametre la camera
   cam$private(camNo) exptime $private(exptime)
   set private(previousClock) [clock clicks -milliseconds ]

   ::camerathread::processAcquisitionLoop
}

proc ::camerathread::processAcquisitionLoop { } {
   variable private

   set catchError [ catch {

      #--- je fais une acquisition
      if { $private(test) == 0 } {
         ###cam$private(camNo) acq
         ###set statusVariableName "::status_cam$private(camNo)"
         ###if { [set $statusVariableName] == "exp" } {
         ###   vwait ::status_cam$private(camNo)
         ###}
         cam$private(camNo) acq -blocking
      } else {
         #--- pour simuler la presence d'une camera pendant les tests de debuggage
         set statusVariableName "::status_cam$private(camNo)"
         set $statusVariableName "stand"
      }


      set bufNo $private(bufNo)
      #--- je calcule le temps ecoule entre deux fins de pose
      set nextClock [clock clicks -milliseconds ]
      set interval "[expr $nextClock - $private(previousClock)]"
      set private(previousClock) $nextClock

      #--- j'affiche l'image
      ::camerathread::notify "autovisu" $interval

      if { $private(acquisitionState) != "1" } {
         #--- je sors immediatement si une interruption a ete demandee
         ::camerathread::notify "acquisitionResult" ""
         return
      }

      set istar ""
      set cstar ""
      set astar ""
      #--- je calcule l'ecart dx,dy entre la cible et l'origine
      if { ($private(mode) == "guide" || $private(mode) == "center")  } {
         if { $private(detection) == "PSF" } {
            #--- je calcule les coordonnees de la cible autour de l'etoile
            set x  [lindex $private(targetCoord) 0]
            set y  [lindex $private(targetCoord) 1]
            set x1 [expr int($x) - $private(targetBoxSize)]
            set x2 [expr int($x) + $private(targetBoxSize)]
            set y1 [expr int($y) - $private(targetBoxSize)]
            set y2 [expr int($y) + $private(targetBoxSize)]
            ###set centro [buf$bufNo centro "[list $x1 $y1 $x2 $y2]"]
            ###set private(targetCoord) [lrange $centro 0 1]
            set centro [buf$bufNo fitgauss "[list $x1 $y1 $x2 $y2]"]
            set private(targetCoord) [list [lindex $centro 1] [lindex $centro 5]]
###::camerathread::disp  "PSF= y1=$y1 y2=$y2 $centro \n"
         } elseif { $private(detection)=="SLIT" } {
            #--- SLIT : je cherche l'etoile dans la zone cible proche de la fente du psectroscope
            set ydelta [expr abs([lindex $private(originCoord) 1] - [lindex $private(targetCoord) 1]) ]
            set yslit [expr $private(slitWidth) ]
            if { $private(dynamicDectection) == "SLIT" } {
                #--- l'etoile �tait proche de la fente dans l'image pr�c�dente
                set x  [lindex $private(targetCoord) 0]
                set y  [lindex $private(targetCoord) 1]
                set x1 [expr int($x) - $private(targetBoxSize)]
                set x2 [expr int($x) + $private(targetBoxSize)]
                set y1 [expr int($y) - $private(targetBoxSize)]
                set y2 [expr int($y) + $private(targetBoxSize)]
                set centro [buf$bufNo slitcentro "[list $x1 $y1 $x2 $y2]" $private(slitWidth) $private(slitRatio) ]
                set private(targetCoord) [lrange $centro 0 1]
###::camerathread::disp  "SLIT= y1=$y1 y2=$y2 $centro \n"
            } else {
                #--- l'etoile �tait loin de la fente dans l'image pr�c�dente
                set x  [lindex $private(targetCoord) 0]
                set y  [lindex $private(targetCoord) 1]
                set x1 [expr int($x) - $private(targetBoxSize)]
                set x2 [expr int($x) + $private(targetBoxSize)]
                set y1 [expr int($y) - $private(targetBoxSize)]
                set y2 [expr int($y) + $private(targetBoxSize)]
                ##set centro [buf$bufNo centro "[list $x1 $y1 $x2 $y2]" ]
                ##set private(targetCoord) [lrange $centro 0 1]
                set centro [buf$bufNo fitgauss "[list $x1 $y1 $x2 $y2]"]
                set private(targetCoord) [list [lindex $centro 1] [lindex $centro 5]]
                ##::camerathread::disp  "PSF=$centro \n"
###::camerathread::disp  "PSF-SLIT= y1=$y1 y2=$y2 $centro \n"
            }
         } elseif { $private(detection) == "STAT" || $private(detection)=="BOGUMIL" } {
            set tempPath "."
            set fileName "dummy"
            set crval1     [lindex $private(radec) 0]
            set crval2     [lindex $private(radec) 1]
            set crpix1     [lindex $private(originCoord) 0 ]
            set crpix2     [lindex $private(originCoord) 1 ]
            set pixsize1   [expr [lindex [cam$private(camNo) celldim] 0] * 1000000]
            set pixsize2   [expr [lindex [cam$private(camNo) celldim] 1] * 1000000]

            calibre $bufNo $tempPath $fileName $private(detection) \
               $private(catalogueName) $private(cataloguePath) \
               $crval1 $crval2 $crpix1 $crpix2 \
               $pixsize1 $pixsize2 \
               $private(foclen) $private(angle) \
               $private(kappa) \
               $private(threshin)  $private(fwhm)   $private(radius) $private(threshold) \
               $private(maxMagnitude) \
               $private(delta) $private(epsilon)

            #--- je charge l'image avec les nouveaux mots cle
            buf$bufNo load [file join $tempPath $fileName]
            #--- je calcule les coordonnees (x,y) correspondant au (ra,dec) cible
            set private(targetCoord)  [buf$bufNo radec2xy $private(radec) 1]
            # j'ouvre le fichier des �toiles de l'image (obs.lst)
            set fcom [open "obs.lst" r]
            set istar ""
            # j'affiche les etoiles
            while {-1 != [gets $fcom line1]} {
               set xpic   [expr [lindex $line1 0] + 1]
               set ypic   [expr [lindex $line1 1] + 1]
               lappend istar [list $xpic $ypic]
            }
            close $fcom

            # j'ouvre le fichier des �toiles du catalogue (usno.lst)
            set fcom [open "usno.lst" r]
            set cstar ""
            # j'affiche les etoiles
            while {-1 != [gets $fcom line1]} {
               set xpic   [expr [lindex $line1 1] + 1]
               set ypic   [expr [lindex $line1 2] + 1]
               lappend cstar [list $xpic $ypic]
            }
            close $fcom

            # j'ouvre le fichier resultat des �toiles appareill�es
            set fcom [open "com.lst" r]
            set astar ""
            while {-1 != [gets $fcom line1]} {
               #--- je convertis en coordonnes picture
               set ximapic   [expr [lindex $line1 0] + 1]
               set yimapic   [expr [lindex $line1 1] + 1]
               set xobspic   [expr [lindex $line1 3] + 1]
               set yobspic   [expr [lindex $line1 4] + 1]
               lappend astar [list $ximapic $yimapic $xobspic $yobspic]
            }
            close $fcom
         }

         #--- je calcule l'ecart de position par rapport a la position d'origine
         set dx [expr [lindex $private(targetCoord) 0] - [lindex $private(originCoord) 0] ]
         set dy [expr [lindex $private(targetCoord) 1] - [lindex $private(originCoord) 1] ]

         #--- je diminue les valeurs de dx et dy si elles depassent la taille de la zone de detection de l'etoile
         if { $dx > $private(targetBoxSize) } {
            set dx $private(targetBoxSize)
         } elseif { $dx <  -$private(targetBoxSize) } {
            set dx [expr -$private(targetBoxSize) ]
         }

         if { $dy > $private(targetBoxSize) } {
            set dy $private(targetBoxSize)
         } elseif { $dy <  -$private(targetBoxSize) } {
            set dy [expr -$private(targetBoxSize) ]
         }

         if { $private(detection)=="SLIT" } {
            #--- je calcule la methode de detection pour la prochaine image
            if { $private(dynamicDectection) == "PSF" } {
                if {  [expr abs($dy) < ($yslit * 0.7)] } {
                    set private(dynamicDectection) "SLIT"
                }
            } else {
                if { [expr abs($dy) > ($yslit * 1) ] } {
                    set private(dynamicDectection) "PSF"
                }
            }
         }

         ::camerathread::notify "targetCoord" $private(targetCoord) $dx $dy $istar $cstar $astar

         #--- je deplace le telescope
         if { $private(mountEnabled) == 1 && $private(acquisitionState) == "1" } {
            #--- je convertis l'angle en radian
            set angle [expr $private(angle)* 3.14159265359/180 ]

            #--- je calcule les delais de deplacement alpha et delta (en millisecondes)
            set alphaDelay [expr int((cos($angle) * $dx - sin($angle) *$dy) * $private(alphaSpeed))]
            set deltaDelay [expr int((sin($angle) * $dx + cos($angle) *$dy) * $private(deltaSpeed))]
            #--- calcul des seuils minimaux de deplacement alpha et delta (en millisecondes)
            set seuilAlpha [expr $private(seuilx) * $private(alphaSpeed)]
            set seuilDelta [expr $private(seuily) * $private(deltaSpeed)]

            #--- j'inverse le sens des deplacements si necessaire
            if { $private(alphaReverse) == "1" } {
               set alphaDelay [expr -$alphaDelay]
            }
            if { $private(deltaReverse) == "1" } {
               set deltaDelay [expr -$deltaDelay]
            }

            #--- je calcule la direction alpha
            if { $alphaDelay >= 0 } {
               set alphaDirection "w"
            } else {
               set alphaDirection "e"
               set alphaDelay [expr -$alphaDelay]
            }

            #--- test anti-turbulence en alpha
            if { $alphaDirection != $private(previousAlphaDirection) } {
               set alphaDelay 0
            }
            if { $alphaDelay < $seuilAlpha } {
               set alphaDelay 0
            }
            set private(previousAlphaDirection) $alphaDirection

            if { $private(declinaisonEnabled) == 1 } {
               #--- je calcule la direction delta
               if { $deltaDelay >= 0 } {
                  set deltaDirection "n"
               } else {
                  set deltaDirection "s"
                  set deltaDelay [expr -$deltaDelay]
               }
               #--- test anti-turbulence en delta
               if { $deltaDirection != $private(previousDeltaDirection) } {
                 set deltaDelay 0
               }
               if { $deltaDelay < $seuilDelta } {
                 set deltaDelay 0
               }
            } else {
               set deltaDelay 0
            }
            set private(previousDeltaDirection) $deltaDirection

            ::camerathread::notify "mountInfo" $alphaDirection $alphaDelay $deltaDirection $deltaDelay

            #--- je deplace le telescope
            if { $alphaDelay != 0 || $deltaDelay != 0 } {
               if { $private(mainThreadNo)==0 } {
                  interp eval "" [list ::telescope::moveTelescope $alphaDirection $alphaDelay $deltaDirection $deltaDelay  ]
               } else {
                  set alphaDelay [expr $alphaDelay / 1000.0]
                  set deltaDelay [expr $deltaDelay / 1000.0]
                  ::thread::send $private(mainThreadNo) [list ::telescope::moveTelescope $alphaDirection $alphaDelay $deltaDirection $deltaDelay  ]
               }
            }
         }

         if { $private(mode)  == "center" } {
            #--- j'ajoute les nouvelles valeurs � la fin de la liste
            lappend private(centerDeltaList) [list $dx $dy]
            #--- je supprime le premier element
            set private(centerDeltaList) [lrange $private(centerDeltaList) 1 end ]
            set xmean "0"
            set ymean "0"
            #--- je calcule la somme des ecarts
            foreach delta  $private(centerDeltaList) {
               set xmean [expr $xmean + abs( [lindex $delta 0 ] ) ]
               set ymean [expr $ymean + abs( [lindex $delta 1 ] ) ]
            }
            #--- je calcule la moyenne des ecarts
            set xmean [expr $xmean / [llength $private(centerDeltaList)]]
            set ymean [expr $ymean / [llength $private(centerDeltaList)]]
            #--- je v�rifie si la moyenne est inferieure au seuil
            if { $xmean < $private(seuilx)  && $ymean < $private(seuily) } {
               ::camerathread::notify "acquisitionResult" $private(targetCoord)
               #--- j'arrete le centrage
               set  private(acquisitionState)  0
            }
         }
      } elseif { $private(mode) == "search" } {
         #--- mode=search
         ##::camerathread::notify autovisu $interval

         set x  [lindex $private(originCoord) 0]
         set y  [lindex $private(originCoord) 1]
         if { $private(targetBoxSize) != 0 } {
            set x1 [expr int($x) - $private(targetBoxSize)]
            set x2 [expr int($x) + $private(targetBoxSize)]
            set y1 [expr int($y) - $private(targetBoxSize)]
            set y2 [expr int($y) + $private(targetBoxSize)]
         } else {
            set x1 1
            set x2 [buf$bufNo getpixelswidth]
            set y1 1
            set y2 [buf$bufNo getpixelsheight]
         }
         set acquisitionResult [::camerathread::searchStar [list $x1 $y1 $x2 $y2] $private(threshin) $private(fwhm) $private(radius) $private(threshold) ]
         #--- je retourne le resultat
         ::camerathread::notify "acquisitionResult" $acquisitionResult
         #--- j'arrete la recherche
         set  private(acquisitionState)  0
      } elseif { $private(mode) == "acq" } {
         #--- je notifie la fin de l'acquisition
         ::camerathread::notify "acquisitionResult" "0"
         #--- j'arrete l'acquisition
         set  private(acquisitionState)  0
      }
   } catchMessage ]

   if { $catchError == 1 } {
      set  private(acquisitionState)  0
     ::camerathread::notify "error" "$::errorInfo"
   } else {
      if { $private(acquisitionState) == "1" }  {
         #--- c'est reparti pour un tour ...
         after [expr int($private(intervalle) *1000)] ::camerathread::processAcquisitionLoop
      }
   }
}

#------------------------------------------------------------
# searchStar
#    recherche les coordonnees des etoiles
#
# parametres :
#    searchBox : zone de recherche de l'�toile
# return
#    coordonnes de l'etoile la plus brillante
#    ou "" si l'toile n'est pas trouvee
#
#------------------------------------------------------------
proc ::camerathread::searchStar { searchBox threshin fwhm radius threshold } {
   variable private

   set bufNo $private(bufNo)

   #--- A_starlist - returns number of stars on image and save stars-list to file
   #
   #Parameters:
   #
   #threshin - pixels above threshin are taken by gauss filter,
   #   suggested  threshin = (total average on the image) + 3*(total standard deviation of the image)
   #filename - where save the star list - ?optional?
   #after_gauss - ?optional?, copy to buffer image after gauss filter, y or n - default n
   #fwhm - ?optional?, default 3.0, best betwen 2.0 and 4.0
   #radius - ?optional?, default 4, "radius" of gauss matrix  - size is (2*radius+1) x (2*radius+1)
   #border - ?optional?, default 20, should be set to more or equal to radius
   #threshold - ?optional?, default 40.0, best betwen 30.0 and 50.0, is used after gauss filter
   #           when procerure is looking for stars, pixels below threshold are not taken


   #--- je cherche les �toiles
   set resultFile "[pwd]/searchStar.txt"
   set searchBorder [expr $radius + 2]
   set result [buf$bufNo A_starlist $threshin $resultFile n $fwhm $radius $searchBorder $threshold $searchBox 1]
   # j'ouvre le fichier resultat
   set fresult [open "$resultFile" r]
   set points [list ]
   set starList ""
   set maxLight  0

   # je traite le fichier de coordonnes
   while {-1 != [gets $fresult line1]} {
      # je decoupe la ligne en une liste de champs
      set line2 [split [regsub -all {[ \t\n]+} $line1 { }]]

      # je copie chaque champ dans une variable distincte
      set numero [lindex $line2 0]

      # je passe outre les lignes qui ne commencent pas par un numero
      if { [ string is integer $numero ] == 0 } {
         continue
      }
      # je passe outre les lignes vides
      if { $numero == ""} {
         continue
      }

      #--- je convertis en coordonnes picture
      if { $searchBox == "" } {
         set x      [expr [lindex $line2 1]]
         set y      [expr [lindex $line2 2]]
      } else {
         set x      [expr [lindex $line2 1] + [lindex $searchBox 0]]
         set y      [expr [lindex $line2 2] + [lindex $searchBox 1]]
      }
      set light    [lindex $line2 4]

      # je calcule le centre de l'etoile
      set x1  [expr $x -10]
      set y1  [expr $y -10]
      set x2  [expr $x +10]
      set y2  [expr $y +10]
      set box [list $x1 $y1 $x2 $y2]
      ##set resultat [buf$bufNo fitgauss $box ]
      ##set xintensity [lindex $resultat 0]
      ##set xposition  [lindex $resultat 1]
      ##set xfwhm      [lindex $resultat 2]
      ##set xfond      [lindex $resultat 3]
      ##set yintensity [lindex $resultat 4]
      ##set yposition  [lindex $resultat 5]
      ##set yfwhm      [lindex $resultat 6]
      ##set yfond      [lindex $resultat 7]
      set resultat [buf$bufNo flux $box ]
      set flux       [expr int([lindex $resultat 0])]

      # je passe outre les points chaud
      ##if { $xfwhm < 1.1 && $yfwhm <1.1} {
      ##   continue
      ##}

      #-- j'enregistre les etoiles
      lappend points "$flux $x $y"
   }

   #--- je recupere les 100 etoiles les plus lumineuses
   if { [llength $points] > 0 } {
      #--- je trie les etoiles par ordre decroissant
      set starList [lsort -integer -index 0 -decreasing $points ]

      if { [llength $starList ] > 100 } {
          set starList [lrange $starList 0 99]
      }
   } else {
      set starList ""
   }

   # je ferme et supprime le fichier de coordonnees
   close $fresult
   file delete -force $resultFile

   return $starList
}

#------------------------------------------------------------
#  calibre
#   calibration astrometrique de l'image
#------------------------------------------------------------

proc ::camerathread::calibre { bufNo tempPath fileName detection catalogueName cataloguePath crval1 crval2 crpix1 crpix2 pixsize1 pixsize2 foclen crota2 kappa threshin fwhm radius threshold maxMagnitude delta epsilon } {
   variable private
   global conf

   set ext [buf$bufNo extension]
   file delete -force "${tempPath}/$fileName$ext"
   file delete -force "${tempPath}/i$fileName$ext"
   file delete -force "${tempPath}/c$fileName$ext"

   #--- je verifie la presence d'une image dans le buffer
   set naxis [lindex [buf$bufNo getkwd NAXIS] 1]
   if { $naxis != 2 && $naxis != 3} {
      error "no 2D or 3D image "
   }

   #--- je cree les mots cles necessaires a la calibration
   buf$bufNo setkwd [list "PIXSIZE1"   $pixsize1   float {[um] Pixel size along naxis1} "um" ]
   buf$bufNo setkwd [list "PIXSIZE2"   $pixsize2   float {[um] Pixel size along naxis2} "um" ]
   buf$bufNo setkwd [list "CRPIX1"     $crpix1     float {[pixel] reference pixel for naxis1} "pixel" ]
   buf$bufNo setkwd [list "CRPIX2"     $crpix2     float {[pixel] reference pixel for naxis2} "pixel" ]
   buf$bufNo setkwd [list "CRVAL1"     $crval1     float {[pixel] reference pixel for naxis1} "pixel" ]
   buf$bufNo setkwd [list "CRVAL2"     $crval2     float {[pixel] reference pixel for naxis2} "pixel" ]
   buf$bufNo setkwd [list "FOCLEN"     $foclen     double "Focal length" "m"]
   buf$bufNo setkwd [list "CROTA2"     $crota2     double "position angle" "deg"]
   buf$bufNo setkwd [list "CTYPE1"     "RA---TAN" string "Gnomonic projection" "" ]
   buf$bufNo setkwd [list "CTYPE2"     "DEC--TAN" string "Gnomonic projection" "" ]
   buf$bufNo setkwd [list "CUNIT1"     "deg" string "Angles are degrees always" "" ]
   buf$bufNo setkwd [list "CUNIT2"     "deg" string "Angles are degrees always" "" ]
   buf$bufNo setkwd [list "EQUINOX"    "2000" string "System of equatorial coordinates" "" ]


   #---- recherche des �toiles dans l'image
   #  input :
   #     dummy0.fit
   #  output
   #     dummy.fit avec les nouveaux mots cles
   #           D_FWHM = 1.270173825213 [pixels] dispersion in FWHM pixels
   #           FWHM = 2.56734827086407 [pixels] Full Width at Half Maximum pixels
   #           NBSTARS = 5 Number stars detected
   #           OBJEFILE = D:/images/idummy.fit Filename of objects list
   #           OBJEKEY = 2007-11-15T10:47:28:24901 Link key for objefile
   #           TT1 = IMA/SERIES STAT TT History
   #     idummy.fit  contenant la table des etoiles trouv�es dans l'image
   set resultFile "${tempPath}/i$fileName$ext"
   if { $detection=="STAT" } {
      buf$bufNo save "${tempPath}/${fileName}$ext"
      ttscript2 "IMA/SERIES \"$tempPath\" \"$fileName\" . . \"$ext\" \"$tempPath\" \"$fileName\" . \"$ext\" STAT \"objefile=$resultFile\" detect_kappa=$kappa"
   } elseif { $detection=="BOGUMIL" } {
      set searchBox [list 1 1 [buf$bufNo getpixelswidth] [buf$bufNo getpixelsheight]]
      set searchBorder [expr $radius + 2]
      #--- j'ajoute les mots cle necessaire a l'astrometrie
      buf$bufNo setkwd [list "OBJEFILE" "$resultFile" string "" "" ]
      buf$bufNo setkwd [list "OBJEKEY" "test" string "" "" ]
      buf$bufNo setkwd [list "TTNAME" "OBJELIST" string "Table name" "" ]
      buf$bufNo A_starlist $threshin $resultFile n $fwhm $radius $searchBorder $threshold $searchBox 2
      buf$bufNo save "${tempPath}/${fileName}$ext"
   } else {
      error "detection unknown : $detection"
   }

   #---- recherche des �toiles dans le catalogue
   #  input :
   #     dummy.fit
   #  output
   #     dummy.fit    avec les nouveaux mots cles
   #     cdummy.fit   contenant la table des etoiles trouv�es dans le catalogue
   #     cdummy.jpg  ( superposition des �toiles du catalogue sur l'image de d�part
   #     usno.lst
   ttscript2 "IMA/SERIES \"$tempPath\" \"$fileName\" . . \"$ext\" \"$tempPath\" \"$fileName\" . \"$ext\" CATCHART \"path_astromcatalog=$cataloguePath\" astromcatalog=$catalogueName \"catafile=${tempPath}/c$fileName$ext\" \"magrlim=$maxMagnitude\" \"magblim=$maxMagnitude\""


   #---- appariement du catalogue
   #  input :
   #     dummy.fit
   #  output
   #     dummy.fit
   #     obs.lst
   #     com.lst
   #     dif.lst
   #     eq.lst
   #     pointzero.lst
   #     usno.lst
   #     xy.lst

   ttscript2 "IMA/SERIES \"$tempPath\" \"$fileName\" . . \"$ext\" \"$tempPath\" \"$fileName\" . \"$ext\" ASTROMETRY delta=$delta epsilon=$epsilon"
}



#------------------------------------------------------------
# notify
#    envoi un message a la thread principale
#
# parametres :
#    args : liste des valeurs
# return
#    rien
#------------------------------------------------------------
proc ::camerathread::notify { args } {
   variable private

   ###::camerathread::disp "::camerathread::notify $args\n"
   if { $private(mainThreadNo)==0 } {
      interp eval "" [list after 10 ::camera::addCameraEvent $private(camItem) $args]
   } else {
      ::thread::send -async $private(mainThreadNo) [list after 10 ::camera::addCameraEvent $private(camItem) $args ]
   }
}

#------------------------------------------------------------
# disp
#    affiche un message dans la console
#
#
# parametres :
#    message : chaine de carracteres du message
# return
#    rien
#------------------------------------------------------------
proc ::camerathread::disp { message } {
   variable private

   if { $private(mainThreadNo)==0 } {
      interp eval "" [list ::console::disp "$message"]
   } else {
      ::thread::send -async $private(mainThreadNo) [list ::console::disp "$message" ]
   }

}

#------------------------------------------------------------
# setParam
#    modifie un parametre
#
# parametres :
#    paramName  : nom du parametre
#    paramValue : valeur du parametre
# return
#    rien
#------------------------------------------------------------
proc ::camerathread::setParam { paramName paramValue } {
   variable private

   if { $private(mainThreadNo)==0 } {
      interp eval "" "set private($paramName) { $paramValue }"
   } else {
      #--- thread::eval utilise un mutex interne a la thread
      thread::eval "set private($paramName) {$paramValue}"
   }
}

#------------------------------------------------------------
# setAsynchroneParameter
#    modifie plusieurs parametres en mode asynchrone
#
# @param args liste de couples (nom parametrea, valeur parametre)
# @return rien
#------------------------------------------------------------
proc ::camerathread::setAsynchroneParameter { args } {
   variable private

   if { $private(mainThreadNo)==0 } {
      interp eval "" "set private($paramName) $args"
   } else {
      #--- thread::eval utilise un mutex interne du thread de la camera
      thread::eval "append private(synchroneParameter) \" \";append private(synchroneParameter) $args"
      if { $private(acquisitionState) == 0 } {
         updateParameter
      }

   }
}

#------------------------------------------------------------
# updateParameter
#    modifie plusieurs parametres en mode asynchrone
#
# @param
# @return rien
#------------------------------------------------------------
proc ::camerathread::updateParameter { } {
   variable private
   set paramList $private(synchroneParameter)
   set private(synchroneParameter)  ""
   foreach { paramName paramValue } $paramList {
      set private($paramName) $paramValue
      ###::camerathread::disp  "camerathread: $paramName=$private($paramName)XXX\n"

      switch $paramName {
        "binning" {
            cam$private(camNo) bin $private(binning)
         }
        "exptime" {
            cam$private(camNo) exptime $private(exptime)
         }
        "window" {
            cam$private(camNo) window $private(window)
         }
      }
   }
}

#------------------------------------------------------------
# setCumul { }
#    active ou desactive le cumul des images
#
#
# parametres :
#    visuNo    : numero de la visu courante
#    cumulState : 0 ou 1
# return
#    rien
#------------------------------------------------------------
proc ::camerathread::setCumul { visuNo cumulState } {
   variable private

   set camItem [::confVisu::getCamItem $visuNo]
   set camNo   [::confCam::getCamNo $camItem ]

   if { $cumulState == 1 } {
      #--- je cree un nouveau buffer
      set private($visuNo,camBufNo) [buf::create]
      #--- je change le buffer de la camera
      cam$camNo buf $private($visuNo,camBufNo)
      #--- je copie la commande du buffer dans la thread de la camera
      thread::copycommand $private($visuNo,camThreadNo) buf$private($visuNo,camBufNo)
      #--- j'initalise le compteur
      set private($visuNo,cumulCounter) "0"
   } else {
      if { $private($visuNo,camBufNo) != [::confVisu::getBufNo $visuNo ]
      && $private($visuNo,camBufNo) != 0 } {
         #--- je detruis le buffer du cumul
         buf::delete $private($visuNo,camBufNo)
         #--- je change le buffer de la camera
         cam$camNo buf [::confVisu::getBufNo $visuNo ]
      }
      set private($visuNo,camBufNo) [::confVisu::getBufNo $visuNo ]
   }

}

