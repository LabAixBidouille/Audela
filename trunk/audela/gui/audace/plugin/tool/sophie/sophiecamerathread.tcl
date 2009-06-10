#
# Fichier : camerathread.tcl
# Description : procedures d'acqusitition et de traitement avec
#         plusieurs cameras simultanées exploitant le mode multithread
# Auteur : Michel PUJOL
# Mise a jour $Id: sophiecamerathread.tcl,v 1.3 2009-06-10 21:18:12 michelpujol Exp $
#


#------------------------------------------------------------
proc ::camerathread::guideSophie { exptime guidingMode originCoord targetCoord cameraAngle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse intervalle } {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(guidingMode)   $guidingMode
   set private(exptime)       $exptime
   set private(originCoord)   $originCoord
   set private(targetCoord)   $targetCoord
   set private(targetBoxSize) $targetBoxSize
   set private(cameraAngle)   $cameraAngle
   set private(mountEnabled)  $mountEnabled
   set private(alphaSpeed)    $alphaSpeed
   set private(deltaSpeed)    $deltaSpeed
   set private(alphaReverse)  $alphaReverse
   set private(deltaReverse)  $deltaReverse
   set private(intervalle)    $intervalle

   set private(centerDeltaList)  ""
   set private(acquisitionState) "1"
   set private(previousClock)    "0"

   #--- variables de travail
   set private(simulationCounter) "1"
   set private(originSumCounter)  0
   set private(diffXCumul)  0
   set private(diffYCumul)  0
   set private(centerDeltaList)   ""
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]

   ###::camerathread::disp  "::camerathread::processAcquisition \n"

   #--- je parametre la camera
   cam$private(camNo) exptime $private(exptime)
   set private(previousClock) [clock clicks -milliseconds ]
   #--- je lance la bloucle d'acquisition
   ::camerathread::sophieAcquisitionLoop
}

#------------------------------------------------------------
# sophieAcquisitionLoop
#  boucle d'acquisition continue
# @return rien
#------------------------------------------------------------
proc ::camerathread::sophieAcquisitionLoop { } {
   variable private

   set catchError [ catch {
      set bufNo $private(bufNo)

      if { $private(synchroneParameter) != "" } {
         ::camerathread::updateParameter
         ###::camerathread::disp  "camerathread: originCoord=$private(originCoord)  \n"
      }

      #--- je calcule le temps ecoule entre deux debuts de pose
      set nextClock [clock clicks -milliseconds ]
      set interval "[expr $nextClock - $private(previousClock)]"
      set private(previousClock) $nextClock

      if { $private(simulation) == 0 } {
         #--- je fais une acquisition
         cam$private(camNo) acq -blocking
      } else {
         #--- je simule une acquisition
         after [expr int($private(exptime) * 1000.0)]

         #--- pour simuler la presence d'une camera pendant les tests de debuggage
         set statusVariableName "::status_cam$private(camNo)"
         set $statusVariableName "stand"
         ###::camerathread::disp  "camerathread: private(simulationGenericFileName)=$private(simulationGenericFileName)XX\n"

         set fileName "$private(simulationGenericFileName)$private(simulationCounter).fit"
         buf$bufNo load "$fileName"

         #--- je simule le fenetrage
         set windowing [cam$private(camNo) window]
         set nbcells [cam$private(camNo) nbcells]
         if { $windowing != [list 1 1 [lindex $nbcells 0 ] [lindex $nbcells 1 ]] } {
            buf$bufNo window $windowing
         }
         #--- je simule le binning
         set binning [cam$private(camNo) bin]
         if { "$binning" != "1 1" } {
            set xScale  [expr 1.0 / [lindex $binning 0 ] ]
            set yScale  [expr 1.0 / [lindex $binning 1 ] ]
            ###::camerathread::disp  "camerathread: simulation binning=$binning  buf$bufNo scale $xScale $yScale  \n"
            buf$bufNo scale $xScale $yScale
         }
         #--- j'increment le compteur de fichier de simulation
         incr private(simulationCounter)
         if { [file exists "$private(simulationGenericFileName)$private(simulationCounter).fit" ] == 0 } {
            set private(simulationCounter) 1
         }
      }

      #--- j'affiche l'image et je transmets le temps ecoule entre 2 debuts de pose
      ::camerathread::notify "autovisu"  [expr double($interval) / 1000]

      if { $private(acquisitionState) == 0 } {
         #--- je sors immediatement si une interruption a ete demandee
         ::camerathread::notify "acquisitionResult" "end"
         return
      }

      set targetDetection ""
      set fiberDetection ""
      #--- je calcule les coordonnees de la fenetre d'analyse
      if {  $private(mode) == "GUIDE" } {
         #--- la fenetre correspond à toute l'image
         set x1 1
         set y1 1
         set x2 [buf$bufNo getpixelswidth]
         set y2 [buf$bufNo getpixelsheight]
      } else {
         #--- la fenetre est centree sur l'etoile
         set x  [lindex $private(targetCoord) 0]
         set y  [lindex $private(targetCoord) 1]
         set x1 [expr int($x) - $private(targetBoxSize)]
         set x2 [expr int($x) + $private(targetBoxSize)]
         set y1 [expr int($y) - $private(targetBoxSize)]
         set y2 [expr int($y) + $private(targetBoxSize)]
         }

      #--- je mesure la position de l'etoile et le trou de la fibre
      # buf$bufNo fibercentro
      # Parameters IN:
      # @param     Argv[2]= [list x1 y1 x2 y2 ] fenetre de detection
      # @param     Argv[3]=biasBufNo       numero du buffer du bias
      # @param     Argv[4]=maskBufNo       numero du buffer du masque
      # @param     Argv[5]=sumBufNo        numero du buffer de l'image integree
      # @param     Argv[6]=fiberBufNo      numero du buffer de l'image resultat
      # @param     Argv[7]=maskRadius      rayon du masque
      # @param     Argv[8]=originSumNb     nombre d'acquisition de l'image integree
      # @param     Argv[9]=originSumCounter compteur d'integration de l'image de l'origine
      # @param     Argv[10]=previousFiberX abcisse du centre de la fibre
      # @param     Argv[11]=previousFiberY ordonnee du centre de la fibre
      # @param     Argv[12]=maskFwhm       largeur a mi hauteur de la gaussienne
      # @param     Argv[13]=findFiber      recherche de l'entrée de fibre
      # @param     Argv[14]=pixelMinCount  nombre minimal de pixels pour accepter l'image
      # @param     Argv[15]=maskPercent    pourcentage du niveau du mask
      #
      # @return si TCL_OK
      #            list[0] starStatus      resultat de la recherche de la fibre
      #            list[1] starX           abcisse du centre de la fibre
      #            list[2] starY           ordonnee du centre de la fibre
      #            list[3] fiberStatus     resultat de la recherche de la fibre
      #            list[4] fiberX          abcisse du centre de la fibre
      #            list[5] fiberY          ordonnee du centre de la fibre
      #            list[6] measuredFwhmX   gaussienne mesuree
      #            list[7] measuredFwhmY   gaussienne mesuree
      #            list[8] background      fond du ciel
      #            list[9] maxIntensity    intensite max
      #            list[10] message        message d'information
      #
      #         si TCL_ERREUR
      #            message d'erreur

      if {  $private(mode) == "GUIDE" && $private(guidingMode) == "FIBER" } {
         set findFiber 1
         #--- j'incremente le compteur d'integration de l'origine
         if { $private(originSumCounter) >= $private(originSumNb) } {
            set private(originSumCounter) 0
         }
         incr private(originSumCounter)
      } else {
         set findFiber 0
         set private(originSumCounter) 0
      }

      set result [buf$bufNo fibercentro "[list $x1 $y1 $x2 $y2]" \
         $private(biasBufNo) $private(maskBufNo) $private(sumBufNo) $private(fiberBufNo) \
         $private(maskRadius) \
         $private(originSumNb) $private(originSumCounter)  \
         [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
         $private(maskFwhm) $findFiber $private(pixelMinCount) $private(maskPercent) ]

      set starStatus       [lindex $result 0 ]
      set starX            [lindex $result 1 ]
      set starY            [lindex $result 2 ]
      set fiberStatus      [lindex $result 3 ]
      set fiberX           [lindex $result 4 ]
      set fiberY           [lindex $result 5 ]
      set measuredFwhmX    [lindex $result 6 ]
      set measuredFwhmY    [lindex $result 7 ]
      set background       [lindex $result 8 ]
      set maxIntensity     [lindex $result 9 ]
      set infoMessage      [lindex $result 10 ]

      if { $starStatus == "DETECTED" } {
         #--- coordonnes de la cible
         set private(targetCoord) [list $starX $starY ]
         #--- l'etoile est detectee
         set targetDetection 1
      } else {
         #--- l'etoile n'est pas detectee
         set targetDetection 0
      }

      if {  $private(mode) == "GUIDE" && $private(guidingMode) == "FIBER" } {
         if { $private(originSumCounter) >= $private(originSumNb) } {
            if { $fiberStatus == "DETECTED" } {
               #--- La consigne est detectee
               set fiberDetection  1
               #--- je met a jour les coordonnes de la consigne
               set private(originCoord) [list $fiberX $fiberY ]
            } else {
               #--- la consigne n'est pas detectee, je ne change pas les coordonnes de la consigne
               set fiberDetection  0
            }
         } else {
            #--- pas de changement, on attend la fin de l'integration de l'image
            set fiberDetection  3
         }

      } else {
         #--- la consigne n'a pas besoin  d'etre detectee en mode OBJECT
         set fiberDetection  2
      }

###::camerathread::disp  "camerathread: FIBER= y1=$y1 y2=$y2 detection etoile=$targetDetection [lindex $result 11]\n"

      #--- je calcule l'ecart de position entre la cible et la consigne
      set dx [expr [lindex $private(targetCoord) 0] - [lindex $private(originCoord) 0] ]
      set dy [expr [lindex $private(targetCoord) 1] - [lindex $private(originCoord) 1] ]
      ###::camerathread::disp  "camerathread: etoile dx=[format "%6.1f" $dx] dy=[format "%6.1f" $dy] \n"

      #--- je calcule la correction diffAlpha et diffDelta  en arcsec
      if { $private(mountEnabled) == 1 && $private(acquisitionState) == "1" &&  $starStatus == "DETECTED" } {

         set binning [cam$private(camNo) bin]

         #--- je calcule l'ecart en arcseconde
         set diffAlpha [expr $dx * [lindex $binning 0] * $private(pixelScale) / (cos($private(targetDec) * 3.14159265359/180)) ]
         set diffDelta [expr $dy * [lindex $binning 1] * $private(pixelScale) ]

         if { $private(mode) == "GUIDE" } {
            #--- j'applique le PID pour le guidage

            #--- je calcule le terme integrateur
            set private(diffXCumul) [expr $private(diffXCumul) + $dx]
            set private(diffYCumul) [expr $private(diffYCumul) + $dy]

            #--- J’ecrete le terme integrateur s’il engendre un déplacement superieur au demi cote de la fenetre d’analyse
            if { [expr abs($private(diffXCumul)) - $private(targetBoxSize) ] > 0
             ||  [expr abs($private(diffYCumul)) - $private(targetBoxSize) ] > 0 } {
               set private(diffXCumul) 0
               set private(diffYCumul) 0
            }

            set diffAlphaCumul [expr $private(diffXCumul) * $private(pixelScale) / ( cos($private(targetDec) * 3.14159265359/180)) ]
            set diffDeltaCumul [expr $private(diffYCumul) * $private(pixelScale) ]

            #--- je corrige avec les termes proportionnels et integrateurs
            set diffAlpha [expr $diffAlpha * $private(proportionalGain) + $diffAlphaCumul * $private(integralGain) ]
            set diffDelta [expr $diffDelta * $private(proportionalGain) + $diffDeltaCumul * $private(integralGain) ]
         }

         #--- je verifie si le centrage est fini
         if { $private(mode)=="CENTER" && $private(mountEnabled) == 1} {
            #--- j'ajoute les nouvelles valeurs à la fin de la liste
            lappend private(centerDeltaList) [list $diffAlpha $diffDelta ]
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

            #--- je vérifie si la moyenne est inferieure au seuil
            if { $xmean < $private(centerMaxLimit)  && $ymean < $private(centerMaxLimit) } {
               ::camerathread::notify "acquisitionResult" "CENTER" $private(targetCoord)
               ::camerathread::disp  "camerathread: Le centrage est terminé ([format "%6.1f" $xmean]<$private(centerMaxLimit))  ([format "%6.1f" $ymean]<$private(centerMaxLimit) arsec) \n"
            } else {
               ::camerathread::disp  "camerathread: Le centrage continue : ([format "%6.1f" $xmean]>$private(centerMaxLimit)) ([format "%6.1f" $ymean]>$private(centerMaxLimit) arsec) \n"
            }
         }


         #--- j'inverse le sens des deplacements si necessaire
         if { $private(alphaReverse) == "1" } {
            set diffAlpha [expr -$diffAlpha]
         }
         if { $private(deltaReverse) == "1" } {
            set diffDelta [expr -$diffDelta]
         }

         #--- j'ecrete l'ampleur du deplacement en alpha
         set maxAlpha [expr $private(targetBoxSize) * [lindex $binning 0] * $private(pixelScale) ]
         if { $diffAlpha > 0 } {
            if { $diffAlpha > $maxAlpha } {
               set diffAlpha $maxAlpha
            }
         } else {
            if { $diffAlpha < -$maxAlpha } {
               set diffAlpha [expr - $maxAlpha]
            }
         }

         #--- j'ecrete l'ampleur du deplacement en delta
         set maxDelta [expr $private(targetBoxSize) * [lindex $binning 1] * $private(pixelScale) ]
         if { $diffDelta > 0 } {
            if { $diffDelta >  $maxDelta } {
               set diffDelta $maxDelta
            }
         } else {
            if { $diffDelta <  -$maxDelta } {
               set diffDelta  [expr -$maxDelta]
            }
         }
      } else {
         set diffAlpha 0.0
         set diffDelta 0.0
      }

      ###::camerathread::disp  "camerathread: diffAlpha=$diffAlpha diffDelta=$diffDelta \n"
      #--- j'envoi un compe rendu avant de faire la correction
      ::camerathread::notify "targetCoord" \
         $private(targetCoord) $dx $dy $targetDetection $fiberDetection \
         [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
         $measuredFwhmX $measuredFwhmY $background $maxIntensity  \
         $diffAlpha $diffDelta $infoMessage


      set alphaDelay 0.0
      set deltaDelay 0.0
      set alphaDirection ""
      set deltaDirection ""
      #--- je deplace le telescope
      if { $private(mountEnabled) == 1 && $private(acquisitionState) == "1"  } {
         #--- je calcule la direction alpha
         if { $diffAlpha >= 0 } {
            set alphaDirection "w"
         } else {
            set alphaDirection "e"
         }

         #--- je calcule la direction delta
         if { $diffDelta >= 0 } {
            set deltaDirection "n"
         } else {
            set deltaDirection "s"
         }
         ::camerathread::notify "mountInfo" $alphaDirection [expr abs($diffAlpha)] $deltaDirection [expr abs($diffDelta)]

         #--- je deplace le telescope
         if { $diffAlpha != 0 || $diffDelta != 0 } {
            if { $private(mainThreadNo)==0 } {
               interp eval "" [list ::telescope::moveTelescope $alphaDirection $diffAlpha $deltaDirection $diffDelta  ]
           } else {
               set alphaDelay [expr abs($diffAlpha) / $private(alphaSpeed)  ]
               set deltaDelay [expr abs($diffDelta) / $private(deltaSpeed)  ]
               ###::camerathread::disp  "camerathread: tel1 move [format "%s %7.3fs" $alphaDirection $alphaDelay ] [format "%s %7.3fs" $deltaDirection $deltaDelay ]\n"
               tel1 radec move $alphaDirection 0.1 $alphaDelay
               tel1 radec move $deltaDirection 0.1 $deltaDelay
            }
         }
      }
      ::camerathread::disp  "camerathread: dx,dy=[format "%6.1f" $dx],[format "%6.1f" $dy] pixel dAlpha,ddelta=[format "%6.2f" $diffAlpha],[format "%6.2f" $diffDelta] arsec tel move [format "%s %4.3fs" $alphaDirection $alphaDelay] [format "%s %4.3fs" $deltaDirection $deltaDelay ]\n"


   } catchMessage ]

   if { $catchError == 1 } {
      set  private(acquisitionState)  0
     ::camerathread::notify "error" "$::errorInfo"
   } else {
      if { $private(acquisitionState) ==  1 }  {
         #--- c'est reparti pour un tour ...
         after [expr int($private(intervalle) *1000)] ::camerathread::sophieAcquisitionLoop
      } else {
         ::camerathread::notify "acquisitionResult" "end"
      }
   }
}

#--- j'intialise les variables
::thread::copycommand $::camerathread::private(mainThreadNo) "::camerathread::guideSophie"


