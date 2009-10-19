##------------------------------------------------------------
# @file     sophiecamerathread.tcl
# @brief    Fichier du namespace ::camerathread
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiecamerathread.tcl,v 1.21 2009-10-19 21:07:09 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @brief   procedure d'acquisition et de traitement exécutee dans le thread de la camera
#
#------------------------------------------------------------
namespace eval ::camerathread {

}

##------------------------------------------------------------
# guideSophie lance la boucle d'acquisition continue
#
#------------------------------------------------------------
proc ::camerathread::guideSophie { exptime originCoord targetCoord cameraAngle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse intervalle } {
   variable private

   if { $private(acquisitionState) == 1 } {
      ::camerathread::notify "error" "camera is busy"
      return
   }

   set private(exptime)              $exptime
   set private(originCoord)          $originCoord
   set private(targetCoord)          $targetCoord
   set private(fiberCoord)           $originCoord
   set private(targetBoxSize)        $targetBoxSize
   set private(cameraAngle)          $cameraAngle
   set private(mountEnabled)         $mountEnabled
   set private(alphaSpeed)           $alphaSpeed
   set private(deltaSpeed)           $deltaSpeed
   set private(alphaReverse)         $alphaReverse
   set private(deltaReverse)         $deltaReverse
   set private(intervalle)           $intervalle

   set private(centerDeltaList)      ""
   set private(acquisitionState)     "1"
   set private(previousClock)        "0"

   #--- variables de travail
   set private(simulationCounter)    "1"
   set private(originSumCounter)     0
   set private(diffXCumul)           0
   set private(diffYCumul)           0
   set private(centerDeltaList)      ""
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]
   lappend  private(centerDeltaList) [list $private(targetBoxSize) $private(targetBoxSize)]

   ###::camerathread::disp "::camerathread::processAcquisition \n"
   #--- je parametre la camera
   cam$private(camNo) exptime $private(exptime)
   set private(previousClock) [clock clicks -milliseconds ]
   #--- je lance la bloucle d'acquisition
   ::camerathread::sophieAcquisitionLoop
}

##------------------------------------------------------------
# sophieAcquisitionLoop
#  boucle d'acquisition continue
# @return rien
#------------------------------------------------------------
proc ::camerathread::sophieAcquisitionLoop { } {
   variable private

   #--- debut du catch pour intercepter les erreurs
   #--- ATTENTION: il ne faut pas d'instruction return dans un cath !!!
   set catchError [ catch {
      set bufNo $private(bufNo)

      #--- je prends en compte les modifications des parametres synchrone et asynchrone
      ::camerathread::updateParameter

      if { $private(acquisitionState) == 1 } {
         #--- je calcule le temps ecoule entre deux debuts de pose
         set nextClock [clock clicks -milliseconds ]
         set interval "[expr $nextClock - $private(previousClock)]"
         set private(previousClock) $nextClock

         if { $private(simulation) == 0 } {
            #--- je fais une acquisition
            cam$private(camNo) acq -blocking
         } else {
            #--- je simule la duree de l'acquisition
            after [expr int($private(exptime) * 1000.0)]
            #--- je charge l'image à la place de celle de la camer
            set extension [buf$bufNo extension]
            set fileName "$private(simulationGenericFileName)$private(simulationCounter)$extension"
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
               buf$bufNo scale [list $xScale $yScale ] 1.0
            }
            #--- j'increment le compteur de fichier de simulation
            incr private(simulationCounter)
            if { [file exists "$private(simulationGenericFileName)$private(simulationCounter)$extension" ] == 0 } {
               set private(simulationCounter) 1
            }
         }
      }

      if { $private(acquisitionState) == 1 } {

         #--- je prends en compte les modifications des parametres synchrones
         update

         set targetDetection ""
         #--- je calcule les coordonnees de la fenetre d'analyse
         if {  $private(mode) == "GUIDE" } {
            if { $private(guidingMode) == "OBJECT" } {
               #--- la fenetre est centree sur la consigne
               set x  [lindex $private(originCoord) 0]
               set y  [lindex $private(originCoord) 1]
               set x1 [expr round($x - $private(targetBoxSize))]
               set x2 [expr $x1 + 2 * $private(targetBoxSize)]
               set y1 [expr round($y - $private(targetBoxSize))]
               set y2 [expr $y1 + 2 * $private(targetBoxSize)]
               set starDetectionMode 2
               set integratedImage 2
               set previousFiberX [lindex $private(fiberCoord) 0]
               set previousFiberY [lindex $private(fiberCoord) 1]
            } else {
               #--- la fenetre correspond à toute l'image qui est centree sur la consigne
               set x1 1
               set y1 1
               set x2 [buf$bufNo getpixelswidth]
               set y2 [buf$bufNo getpixelsheight]
               set starDetectionMode 1
               set integratedImage 1
               set previousFiberX [lindex $private(originCoord) 0]
               set previousFiberY [lindex $private(originCoord) 1]
            }
         } else {
            #--- la fenetre est centree sur l'etoile en mode centrage et en mode focalisaiton
            set x  [lindex $private(targetCoord) 0]
            set y  [lindex $private(targetCoord) 1]
            set x1 [expr round($x - $private(targetBoxSize))]
            set x2 [expr $x1 + 2 * $private(targetBoxSize)]
            set y1 [expr round($y - $private(targetBoxSize))]
            set y2 [expr $y1 + 2 * $private(targetBoxSize)]
            set starDetectionMode 1
            set integratedImage 0
            set previousFiberX [lindex $private(originCoord) 0]
            set previousFiberY [lindex $private(originCoord) 1]
            ###::camerathread::disp  "targetCoord=[format "%.2f" [lindex $private(targetCoord) 0]]  x=$x  x1=$x1 x2=$x2\n"
         }

         #--- j'affiche l'image et je transmets le temps ecoule entre 2 debuts de pose
         ::camerathread::notify "autovisu"  [expr double($interval) / 1000] $private(mode) $private(guidingMode) [list $x1 $y1 $x2 $y2] $private(zoom)

         #--- j'incremente le compteur des images integrees
         if { $integratedImage != 0 } {
            incr private(originSumCounter)
         }

         #--- je mesure la position de l'etoile et le trou de la fibre
         # buf$bufNo fibercentro
         # Parameters IN:
         # @param     Argv[2]= [list x1 y1 x2 y2 ] fenetre de detection de l'etoile
         # @param     Argv[3]=starDetectionMode    1=fit de gaussienne  2=barycentre
         # @param     Argv[4]=integratedImage      0=pas d'image integree, 1=image integree centree la fenetre, 2=image integree centree sur la consigne
         # @param     Argv[5]=findFiber            1=recherche de l'entrée de fibre , 0= ne pas rechercher
         # @param     Argv[6]=maskBufNo            numero du buffer du masque
         # @param     Argv[7]=sumBufNo             numero du buffer de l'image integree
         # @param     Argv[8]=fiberBufNo           numero du buffer de l'image resultat
         # @param     Argv[9]=originSumMinCounter  nombre d'acquisition de l'image integree
         # @param     Argv[10]=originSumCounter    compteur d'integration de l'image de l'origine
         # @param     Argv[11]=previousFiberX      abcisse du centre de la fibre
         # @param     Argv[12]=previousFiberY      ordonnee du centre de la fibre
         # @param     Argv[13]=maskRadius          rayon du masque
         # @param     Argv[14]=maskFwhm            largeur a mi hauteur de la gaussienne
         # @param     Argv[15]=pixelMinCount       nombre minimal de pixels pour accepter l'image
         # @param     Argv[16]=maskPercent         pourcentage du niveau du masque
         # @param     Argv[17]=biasValue           valeur du bias
         #
         # @return si TCL_OK
         #            list[0] starStatus           resultat de la recherche de la fibre (DETECTED NO_SIGNAL)
         #            list[1] starX                abcisse du centre de la fibre   (pixel binné)
         #            list[2] starY                ordonnee du centre de la fibre  (pixel binné
         #            list[3] fiberStatus          resultat de la recherche de la fibre (DETECTED NO_SIGNAL)
         #            list[4] fiberX               abcisse du centre de la fibre  (pixel binné)
         #            list[5] fiberY               ordonnee du centre de la fibre (pixel binné)
         #            list[6] measuredFwhmX        gaussienne mesuree (pixel binné)
         #            list[7] measuredFwhmY        gaussienne mesuree (pixel binné)
         #            list[8] background           fond du ciel (ADU)
         #            list[9] maxIntensity         intensite max (ADU)
         #            list[10] message             message d'information
         #
         #         si TCL_ERREUR
         #            message d'erreur

         set result [buf$bufNo fibercentro "[list $x1 $y1 $x2 $y2]" \
            $starDetectionMode $integratedImage  $private(findFiber) \
            $private(maskBufNo) $private(sumBufNo) $private(fiberBufNo) \
            $private(originSumMinCounter) $private(originSumCounter) \
            $previousFiberX $previousFiberY \
            $private(maskRadius) $private(maskFwhm) $private(pixelMinCount) $private(maskPercent) \
            $private(biasValue)]

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

         ###::camerathread::disp  "windowCoord=$x1 $y1 $x2 $y2 targetCoord=$private(targetCoord) originCoord=$private(originCoord)\n"
         ###::camerathread::disp  "starStatus=$starStatus starX,starY=$starX $starY fiberStatus=$fiberStatus fiberX,fiberY=$fiberX $fiberY infoMessage=$infoMessage\n"

         if { $starStatus == "DETECTED" } {
            #--- l'etoile est detectee
            set targetDetection 1
            #--- je memorise les nouvelles coordonnees de la cible
            set private(targetCoord) [list $starX $starY ]
         } else {
            #--- l'etoile n'est pas detectee
            set targetDetection 0
         }

         switch $fiberStatus {
            "DETECTED" {
               #--- je memorise les coordonnes de la consigne
               set private(originCoord) [list $fiberX $fiberY ]
            }
            "INTEGRATING" -
            "TOO_FAR" -
            "LOW_SIGNAL" -
            "NO_SIGNAL" -
            "DISABLED" -
            "OUTSIDE" -
            default {
               #--- rien a faire, je transmet le status de la fibre tel quel
            }
         }

         ###::camerathread::disp  "camerathread: private(targetCoord)=$private(targetCoord) private(originCoord)=$private(originCoord)\n"
         ###::camerathread::disp  "camerathread: FIBER= y1=$y1 y2=$y2 fiberStatus=$fiberStatus\n"

         set binning [cam$private(camNo) bin]
         #--- je calcule l'ecart de position entre la cible et la consigne (en pixels ramene au binning 1x1)
         set dx [expr (double([lindex $private(targetCoord) 0]) - [lindex $private(originCoord) 0]) * [lindex $binning 0] ]
         set dy [expr (double([lindex $private(targetCoord) 1]) - [lindex $private(originCoord) 1]) * [lindex $binning 1] ]
         ###::camerathread::disp  "camerathread: etoile dx=[format "%6.1f" $dx] dy=[format "%6.1f" $dy] \n"

        #--- je pondere la position si on est en mode GUIDE avec detection de la fibre
         if { $private(mode) == "GUIDE" && $private(findFiber) == 1 } {
            set cgx $dx
            if { [expr abs($dx) * [lindex $binning 0] ] < 16 } {
               #--- le denominateur est toujours non nul parce que dx > 1.7/0.04)
               set dx [expr $dx / (1.7 - abs($dx) * 0.04)]
            }
            set cgy $dy
            if { [expr abs($dy) * [lindex $binning 1] ] < 16 } {
               set dy [expr $dy / (1.7 - abs($dy) * 0.04)]
            }
            ###::camerathread::disp  "correction cgx [format "%6.1f" $cgx] => [format "%6.1f" $dx] cgy: [format "%6.1f" $cgy] => [format "%6.1f" $dy (pixel)] \n"
         }

         #--- je calcule l'ecart de position (en arcseconde)
         ###set alphaDiff [expr $dx * $private(pixelScale) / (cos($private(targetDec) * 3.14159265359/180)) ]
         set alphaDiff [expr $dx * $private(pixelScale) ]
         set deltaDiff [expr $dy * $private(pixelScale) ]

         #--- je calcule la correction alphaCorrection et deltaCorrection  en arcsec
         if { $private(mountEnabled) == 1 && $starStatus == "DETECTED" } {
            if { $private(mode) == "GUIDE" } {
               #--- j'applique le PID pour le guidage si on est en mode GUIDE

               #--- je calcule le terme integrateur
               set private(diffXCumul) [expr $private(diffXCumul) + $dx]
               set private(diffYCumul) [expr $private(diffYCumul) + $dy]

               #--- J’ecrete le terme integrateur s’il engendre un déplacement superieur au demi cote de la fenetre d’analyse
               if { [expr abs($private(diffXCumul)) - $private(targetBoxSize) ] > 0
                ||  [expr abs($private(diffYCumul)) - $private(targetBoxSize) ] > 0 } {
                  set private(diffXCumul) 0
                  set private(diffYCumul) 0
               }

               set alphaDiffCumul [expr $private(diffXCumul) * $private(pixelScale) ]
               set deltaDiffCumul [expr $private(diffYCumul) * $private(pixelScale) ]

               #--- je corrige avec les termes proportionnels et integrateurs
               set alphaCorrection [expr $alphaDiff * $private(alphaProportionalGain) + $alphaDiffCumul * $private(alphaIntegralGain) ]
               set deltaCorrection [expr $deltaDiff * $private(deltaProportionalGain) + $deltaDiffCumul * $private(deltaIntegralGain) ]
            } else {
               set alphaCorrection [expr $alphaDiff * 0.9]
               set deltaCorrection [expr $deltaDiff * 0.9]
               ###::camerathread::disp  "CENTER alphaDiff=[format "%6.2f" $alphaDiff]  deltaDiff=[format "%6.2f" $deltaDiff] (arsec) "
            }

            #--- je verifie si le centrage est fini
            if { $private(mode)=="CENTER" && $private(mountEnabled) == 1} {
               #--- j'ajoute les nouvelles valeurs à la fin de la liste
               lappend private(centerDeltaList) [list $alphaCorrection $deltaCorrection ]
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
                  ###::camerathread::disp  "camerathread: Le centrage est terminé ([format "%6.1f" $xmean]<$private(centerMaxLimit))  ([format "%6.1f" $ymean]<$private(centerMaxLimit) arsec) \n"
               } else {
                  ###::camerathread::disp  "camerathread: Le centrage continue : ([format "%6.1f" $xmean]>$private(centerMaxLimit)) ([format "%6.1f" $ymean]>$private(centerMaxLimit) arsec) \n"
               }
            }

            #--- j'inverse le sens des deplacements si necessaire
            if { $private(alphaReverse) == "1" } {
               set alphaCorrection [expr -$alphaCorrection]
            }
            if { $private(deltaReverse) == "1" } {
               set deltaCorrection [expr -$deltaCorrection]
            }

            #--- je prends en compte la declinaison dans le calcul de la correction de alpha
            set alphaCorrection [expr $alphaCorrection / (cos($private(targetDec) * 3.14159265359/180)) ]

            #--- j'ecrete l'ampleur du deplacement en alpha
            set maxAlpha [expr $private(targetBoxSize) * [lindex $binning 0] * $private(pixelScale) ]
            if { $alphaCorrection > 0 } {
               if { $alphaCorrection > $maxAlpha } {
                  set alphaCorrection $maxAlpha
               }
            } else {
               if { $alphaCorrection < -$maxAlpha } {
                  set alphaCorrection [expr - $maxAlpha]
               }
            }

            #--- j'ecrete l'ampleur du deplacement en delta
            set maxDelta [expr $private(targetBoxSize) * [lindex $binning 1] * $private(pixelScale) ]
            if { $deltaCorrection > 0 } {
               if { $deltaCorrection > $maxDelta } {
                  set deltaCorrection $maxDelta
               }
            } else {
               if { $deltaCorrection <  -$maxDelta } {
                  set deltaCorrection  [expr -$maxDelta]
               }
            }
         } else {
            set alphaCorrection 0.0
            set deltaCorrection 0.0
         }
         update
         #--- j'envoi une notification pour mettre a jour l'affichage de la fenetre principale
         ::camerathread::notify "targetCoord" \
            $private(targetCoord) $dx $dy $targetDetection $fiberStatus \
            [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
            $measuredFwhmX $measuredFwhmY $background $maxIntensity  \
            $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection $infoMessage
      }

      ###::camerathread::disp  "camerathread: alphaCorrection=$alphaCorrection deltaCorrection=$deltaCorrection \n"
      if { $private(acquisitionState) == "1" } {

         #--- je prends en compte les modifications des parametres synchones et assynchones
         ::camerathread::updateParameter

         set alphaDelay 0.0
         set deltaDelay 0.0
         set alphaDirection ""
         set deltaDirection ""
         #--- je deplace le telescope
         if { $private(mountEnabled) == 1 && $private(acquisitionState) == "1"  } {
            #--- je calcule la direction alpha
            if { $alphaCorrection >= 0 } {
               set alphaDirection "w"
            } else {
               set alphaDirection "e"
            }

            #--- je calcule la direction delta
            if { $deltaCorrection >= 0 } {
               set deltaDirection "n"
            } else {
               set deltaDirection "s"
            }
            ::camerathread::notify "mountInfo" $alphaDirection [expr abs($alphaCorrection)] $deltaDirection [expr abs($deltaCorrection)]

            #--- je deplace le telescope
            if { $alphaCorrection != 0 || $deltaCorrection != 0 } {
               if { $private(mainThreadNo)==0 } {
                  interp eval "" [list ::telescope::moveTelescope $alphaDirection $alphaCorrection $deltaDirection $deltaCorrection  ]
              } else {
                  set alphaDelay [expr abs($alphaCorrection) / $private(alphaSpeed)  ]
                  set deltaDelay [expr abs($deltaCorrection) / $private(deltaSpeed)  ]
                  ###::camerathread::disp  "camerathread: telescope move [format "%s %.3fs" $alphaDirection $alphaDelay ]   [format "%s %.3fs" $deltaDirection $deltaDelay ]\n"
                  #--- tel1 radec move n|s|e|w ?rate? ?delay (ms)?
                  tel1 radec move $alphaDirection 0.1 $alphaDelay
                  tel1 radec move $deltaDirection 0.1 $deltaDelay
               }
            }
         }
         ###::camerathread::disp  "camerathread: dx,dy=[format "%6.1f" $dx],[format "%6.1f" $dy]pixel dAlpha,ddelta=[format "%6.2f" $alphaDiff],[format "%6.2f" $deltaDiff] arsec correction=[format "%6.2f" $alphaCorrection],[format "%6.2f" $deltaCorrection]arsec tel move [format "%s %4.3fs" $alphaDirection $alphaDelay] [format "%s %4.3fs" $deltaDirection $deltaDelay ]\n"
      }
   } catchMessage ]

   if { $catchError == 1 } {
      set  private(acquisitionState)  0
      ::camerathread::notify "error" "$::errorInfo"
   } else {
      if { $private(acquisitionState) ==  1 }  {
         #--- c'est reparti pour un tour ...
         after [expr int($private(intervalle) *1000)] ::camerathread::sophieAcquisitionLoop
      } else {
         ::camerathread::notify "acquisitionResult" "END"
      }
   }
}

#--- j'intialise les variables
::thread::copycommand $::camerathread::private(mainThreadNo) "::camerathread::guideSophie"

