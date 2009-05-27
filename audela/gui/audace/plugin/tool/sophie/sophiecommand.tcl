#
# Fichier : sophiecommand.tcl
# Description : Centralise les commandes de l'outil Sophie
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophiecommand.tcl,v 1.8 2009-05-27 21:54:56 michelpujol Exp $
#

#============================================================
# Declaration du namespace sophie
#    initialise le namespace
#============================================================
namespace eval ::sophie {
}

##------------------------------------------------------------
# adaptPanel
#    adapte l'affichage des boutons en fonction de la camera
#
# @param visuNo       numero de la visu courante
# @param args         valeur fournies par le gestionnaire de listener
#------------------------------------------------------------
proc ::sophie::adaptPanel { visuNo args } {
   variable private

   set frm $private(frm)

console::disp " adaptPanel widgetBinning=$private(widgetBinning)\n"
   #--- je recupere l'item de la camera
   set private(camItem) [ ::confVisu::getCamItem $visuNo ]
   set private(camNo)   [ ::confCam::getCamNo $private(camItem) ]

   if { $private(camNo) != 0 } {
      if { [::confCam::getPluginProperty $private(camItem) hasBinning] == "0" } {
         $frm.acq.labBinning configure -state disabled
         $frm.acq.binning.a configure -state disabled
         $frm.acq.binning.e configure -state disabled
         set private(listeBinning) "1x1"
         ::sophie::setBinning "1x1"
console::disp " adaptPanel 1 widgetBinning=$private(widgetBinning)\n"
      } else {
         $frm.acq.labBinning configure -state normal
         $frm.acq.binning.a configure -state normal
         $frm.acq.binning.e configure -state normal
         #--- je mets a jour la liste des binning
         set private(listeBinning) [::confCam::getPluginProperty $private(camItem) binningList]
         $frm.acq.binning  configure -values $private(listeBinning) -height [llength $private(listeBinning)]
         if { [lsearch $private(listeBinning) $private(widgetBinning)] != -1 } {
            #--- je configure la camera avec le binning courant s'il existe dans la liste
            ###scan $private(binning) "%dx%d" xBinning  yBinning
            ###cam$private(camNo) bin [list $xBinning  $yBinning]
         } else {
            #--- je configure la camera avec le binning courant s'il existe dans la liste
            set private(listeBinning) [lindex $private(listeBinning) 0 ]
         }
      }
   }

   if { $private(camNo) != 0 } {
      set private(cameraCells) [cam$private(camNo) nbcells]
   } else {
      set private(cameraCells) [list 1536 1024 ]
   }

console::disp " adaptPanel 2 widgetBinning=$private(widgetBinning)\n"

### a d'autre a faire. Pour l'instant je retourne immediatement et je ne fais rien
return

   #--- j'adapte les boutons de selection de pose et de binning
   if { [::confCam::getPluginProperty $private(camItem) longExposure] == "1" } {
      #--- cameras autre que webcam, ou webcam avec la longue pose
      pack $frm.pose.lab1 -anchor center -side left -padx 5
      pack $frm.pose.combo -anchor center -side left -fill x -expand 1
      pack forget $frm.pose.confwebcam
   } else {
      #--- webcam
      pack forget $frm.pose.lab1
      pack forget $frm.pose.combo
      pack $frm.pose.confwebcam -anchor center -side left -fill x -expand 1
      #--- je mets la pose a zero car cette variable est utilisee et doit etre nulle pour les courtes poses
      set ::conf(sophie,exposure) "0"
   }

}

##------------------------------------------------------------
# onChangeZoom
#      appele par confVisu quand on change le zoom de la visu
#
# @param visuNo       numero de la visu courante
# @param args         valeur fournies par le gestionnaire de listener
#------------------------------------------------------------
proc ::sophie::onChangeZoom { visuNo args } {
   variable private

   #--- je memorise la nouvelle valeur du zoom
   set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]

   #--- je redessine l'origine
   createOrigin $visuNo
   #--- je redessine la cible
   createTarget $visuNo


}

#------------------------------------------------------------
#  onChangeSubWindow
#     appele par confVisu quand on applique un fenetrage sur la visu
#
# @param visuNo       numero de la visu courante
# @param args         valeur fournies par le gestionnaire de listener
#------------------------------------------------------------
proc ::sophie::onChangeSubWindow { visuNo args } {
   variable private

   #--- je redessine l'origine
   createOrigin $visuNo
   #--- je redessine la cible
   createTarget $visuNo
}

##------------------------------------------------------------
# configureWebcam
#    affiche la fenetre de configuration d'une webcam
# @param visuNo         numero de la visu courante
#------------------------------------------------------------
proc ::sophie::webcamConfigure { visuNo } {
   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $::caption(sophie,titre) -type ok \
                -message $::caption(sophie,selcam) ]
         if { $choix == "ok" } {
             #--- Ouverture de la fenetre de selection des cameras
             ::confCam::run
             tkwait window $::audace(base).confCam
         }
         ::audace::menustate normal
      }
   }
}


#------------------------------------------------------------
# showConfigWindow
#    ouvre la fenetre de configuration
#
# @param visuNo       numero de la visu courante
#------------------------------------------------------------
proc ::sophie::showConfigWindow { visuNo } {
   variable private

   ::sophie::config::run $visuNo [winfo toplevel $private(frm)]
}

#------------------------------------------------------------
# showControlWindow
#    ouvre la fenetre de controle
#
# @param visuNo       numero de la visu courante
#------------------------------------------------------------
proc ::sophie::showControlWindow { visuNo } {
   variable private

   ::sophie::control::run $visuNo [winfo toplevel $private(frm)]
   #--- je mets a jour le mode dans la fenetre de controle
   ::sophie::control::setMode $private(mode)
}

#------------------------------------------------------------
# setBinning
#  applique le changement de binning
#     - dans la camera ,
#     - position de la cible
# @param  binning   binning x et y  sous la forme 1x1 2x2 ...
# @return rien
#------------------------------------------------------------
proc ::sophie::setBinning { binning } {
   variable private

   if { [lsearch $private(listeBinning) $binning] == -1 } {
      #--- je ne change pas le binning s'il n'esiste pas dans la liste des binning de la camera
      return
   }
   set private(widgetBinning) $binning
   scan $binning "%dx%d" xBinning  yBinning
   set xPreviousBinning $private(xBinning)
   set yPreviousBinning $private(yBinning)
   set private(xBinning) $xBinning
   set private(yBinning) $yBinning

console::disp "setBinning  previousBinning=$xPreviousBinning $yPreviousBinning   binning=$binning\n"

   #--- je change les paramètres dans la thread
   if { $private(acquisitionState) != 0 } {
      set xOriginCoord [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
      set yOriginCoord [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
      set xTargetCoord [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
      set yTargetCoord [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
      set targetBoxSize [ expr int($private(targetBoxSize) / (2.0 * $private(xBinning) ))  ]
      ::camera::setAsynchroneParameter $private(camItem) \
         "originCoord" [list $xOriginCoord $yOriginCoord] \
         "targetCoord" [list $xTargetCoord $yTargetCoord] \
         "targetBoxSize" $targetBoxSize \
         "binning"     [list $private(xBinning) $private(yBinning)]
   } else {
      #--- je change le binning de l'image courante
      if { [buf$private(bufNo) imageready] == 1 } {
         #--- je change le binning de l'image affichee artificiellement
         buf$private(bufNo)  scale [list [ expr double($xPreviousBinning) / $xBinning ] [expr double($xPreviousBinning) / $yBinning ] ]
         confVisu::autovisu $::audace(visuNo)
      }
      createTarget $::audace(visuNo)
      createOrigin $::audace(visuNo)
   }




}

#------------------------------------------------------------
# setExposure
#    applique le changement de duree de pose
# @param  exposure  temps de pose (en seconde)
# @return rien
#------------------------------------------------------------
proc ::sophie::setExposure { { exposure "" } } {
   variable private

   if { $exposure != "" } {
      set ::conf(sophie,exposure) $exposure
   }

   #--- je change les paramètres dans la thread
   if { $private(acquisitionState) != 0 } {
      ::camera::setAsynchroneParameter $private(camItem) "exptime" $::conf(sophie,exposure)
   }
}

#------------------------------------------------------------
# setSubWindow
#  applique le fenetrage de la camera autour de la position courante de la consigne
#     - dans la camera ,
#     - position de la cible
# @param  windowing  "full" ou longueur d'un du carré du fenetrage
# @return rien
#------------------------------------------------------------
proc ::sophie::setWindowing { size { center "" } } {
   variable private

   set width  [lindex $private(cameraCells) 0 ]
   set height [lindex $private(cameraCells) 1 ]

   if { $size == "full" } {
      #--- pas de fenetrage
      set x1 1
      set y1 1
      set x2 $width
      set y2 $height
   } else {
      set size [expr $size / 2 ]
      set x  [lindex $center 0]
      set y  [lindex $center 1]
      if { [ expr ($x - $size) < 1 ]} {
         #--- la fenetre est trop a gauche
         set x [expr $size + 1]
      }
      if { [ expr ($x + $size) > $width ]} {
         #--- la fenetre est trop a droite
         set x [expr $width - $size]
      }
      if { [ expr ($y - $size) < 1 ]} {
         #--- la fenetre est trop en bas
         set y [expr $size + 1]
      }
      if { [ expr ($y + $size) > $height ]} {
         #--- la fenetre est trop haut
         set y [expr $height- $size]
      }

      set x1 [expr int($x - $size)]
      set x2 [expr int($x + $size)]
      set y1 [expr int($y - $size)]
      set y2 [expr int($y + $size)]
   }

   #--- je configure la camera
   if { $private(camNo) != 0 } {
      cam$private(camNo) window  [list $x1 $y1 $x2 $y2 ]
   }
::console::disp "setWindowing cam$private(camNo) window  [list $x1 $y1 $x2 $y2 ] \n"
   #--- je memorise les coordonnee du coin bas gauche du fenetrage
   set private(xWindow) $x1
   set private(yWindow) $y1

   #--- je change les paramètres dans la thread
   if { $private(acquisitionState) != 0 } {
      set xOriginCoord [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
      set yOriginCoord [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
      set xTargetCoord [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
      set yTargetCoord [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
      set targetBoxSize [ expr int($private(targetBoxSize) / (2.0 * $private(xBinning))) ]
      ::camera::setAsynchroneParameter $private(camItem) \
            "originCoord" [list $xOriginCoord $yOriginCoord] \
            "targetCoord" [list $xTargetCoord $yTargetCoord] \
            "targetBoxSize" $targetBoxSize
   }
}

#------------------------------------------------------------
# onChangeBinning
#  cette procedure est apellee par la commbbo de choix du binning
#  pour changer de binning
#------------------------------------------------------------
proc ::sophie::onChangeBinning { visuNo } {
   variable private

   #--- je change le mode d'acquisition
   setBinning $private(widgetBinning)
}

#------------------------------------------------------------
# onChangeExposure
#  cette procedure est apellee par la commbbo de choix du temps de pose
#  pour changer le temps de pose
#------------------------------------------------------------
proc ::sophie::onChangeExposure { visuNo } {
   variable private

   #--- je change le mode d'acquisition
   setExposure $::conf(sophie,exposure)
}


#------------------------------------------------------------
# onChangeMode
#  cette procedure est apellee par les boutons de changement de mode
#  pour changer de mode
#------------------------------------------------------------
proc ::sophie::onChangeMode { } {
   variable private

   #--- je change le mode d'acquisition
   setMode $private(mode)
}

#------------------------------------------------------------
# onCenter
#  cette procedure est apellee quand on clique sur la chekbox de centrage
#  pour lancer ou arreter le centrage
#------------------------------------------------------------
proc ::sophie::onCenter { } {
   variable private

   #--- je change le mode d'acquisition
   if { $private(centerEnabled) == 1 } {
      startCenter
   } else {
      stopCenter
   }
}

#------------------------------------------------------------
# onGuide
#  cette procedure est apellee quand on clique sur la chekbox de guidage
#  pour lancer ou arret le guidage
#------------------------------------------------------------
proc ::sophie::onGuide { } {
   variable private

   #--- je change le mode d'acquisition
   if { $private(guideEnabled) == 1 } {
      startGuide
   } else {
      stopGuide
   }
}


#------------------------------------------------------------
# setMode
#    change le mode d'acquisition
#      - change les paramètres de l'acquisition continue dans la thread de la camera
#      - met à jour l'affichage de la fenetre de contole
# @param mode       mode d'acquisition
#------------------------------------------------------------
proc ::sophie::setMode { { mode "" } } {
   variable private

   #--- je desactive le mode precedent
   $private(frm).mode.centrageStart configure -state disabled
   stopCenter
   stopGuide

   #--- je mets a jour la variable
   if { $mode != "" } {
      set private(mode) $mode
   }
   #--- j'applique le nouveau mode
   switch $private(mode) {
      "centrage" {
         if { $private(acquisitionState) == 1 } {
            #--- j'autorise le bouton de centrage
            $private(frm).mode.centrageStart configure -state normal
         } else {
           #--- j'interdis le bouton de centrage
           $private(frm).mode.centrageStart  configure -state disabled
         }
         #--- j'interdis le bouton de centrage
         $private(frm).mode.guidageStart  configure -state disabled
         #--- je change la taille de d'analyse de la cible
         set private(targetBoxSize) $::conf(sophie,centerWindowSize)
         #--- je mets la thread de la camera en mode centrage
         ::camera::setAsynchroneParameter $private(camItem)  "mode" "guide"
         #--- je change le binning
         setBinning $::conf(sophie,centerBinning)
         #--- je change le fenetrage
         setWindowing "full"
         #--- je change le zoom
         ::confVisu::setZoom $::audace(visuNo) 1
         set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
      }
      "focalisation" {
         #--- j'interdis le bouton de centrage
         $private(frm).mode.centrageStart  configure -state disabled
         #--- j'interdis le bouton de guidage
         $private(frm).mode.guidageStart  configure -state disabled
         #--- je change la taille de d'analyse de la cible
         set private(targetBoxSize) $::conf(sophie,centerWindowSize)
         #--- je mets la thread de la camera en mode centrage
         ::camera::setAsynchroneParameter $private(camItem)  "mode" "guide"
         ###if { $private(targetDetection) == 0 } {
         ###   #--- l'étoile n'est pas detectee
         ###   #--- je change le binning
         ###   setBinning "2x2"
         ###   #--- je supprime le fenetrage
         ###   setWindowing "full"
         ###   #--- j'applique le zoom 1
         ###   ::confVisu::setZoom $::audace(visuNo) 1
         ###   set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
         ###} else {
            #--- l'étoile est detectee
            #--- je change le binning
            setBinning "1x1"
            #--- j'active le fenetrage centrée sur l'étoile
            setWindowing $::conf(sophie,centerWindowSize) $private(targetCoord)
            #--- j'applique le zoom 4
            ::confVisu::setZoom $::audace(visuNo) 4
            set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
         ###}
      }
      "guidage" {
         #--- j'interdis le bouton de centrage
         $private(frm).mode.centrageStart  configure -state disabled
         if { $private(acquisitionState) == 1 } {
            #--- j'autorise le bouton de guidage
            $private(frm).mode.guidageStart configure -state normal
         } else {
           #--- j'interdis le bouton de guidage
           $private(frm).mode.guidageStart  configure -state disabled
         }

         #--- je change la taille de d'analyse de la cible
         set private(targetBoxSize) $::conf(sophie,guidingWindowSize)
         #--- je mets la thread de la camera en mode centrage
         ::camera::setAsynchroneParameter $private(camItem)  "mode" "guide"
         ###if { $private(targetDetection) == 0 } {
         ###   #--- l'étoile n'est pas detectee
         ###   #--- je change le binning
         ###   setBinning "2x2"
         ###   #--- je supprime le fenetrage
         ###   setWindowing "full"
         ###   #--- j'applique le zoom 1
         ###   ::confVisu::setZoom $::audace(visuNo) 1
         ###   set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
         ### } else {
         ###}
            #--- l'étoile est detectee
            #--- je change le binning
            setBinning $::conf(sophie,guideBinning)
            #--- j'active le fenetrage centrée sur la consigne
            setWindowing $::conf(sophie,guidingWindowSize) $private(originCoord)
            #--- je change le zoom
            ::confVisu::setZoom $::audace(visuNo) 4
            set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
      }
   }

   #--- je mets a jour la fenetre de controle
   ::sophie::control::setMode $private(mode)
}

#------------------------------------------------------------
# setGuidingMode
#    ouvre les spinbox pour le pointage d'un objet
#    place la consigne au bon endroit
#------------------------------------------------------------
proc ::sophie::setGuidingMode { visuNo } {
   variable private

   set frm $private(frm)
   switch $::conf(sophie,guidingMode) {
      "FIBER" {
         if { $::conf(sophie,fiberGuigindMode) == "HR" } {
            set private(originCoord)  [list $::conf(sophie,fiberHRX) $::conf(sophie,fiberHRY)]
         } else {
            set private(originCoord)  [list $::conf(sophie,fiberHEX) $::conf(sophie,fiberHEY)]
         }
         set activewidth 2
         #--- je positionne la consigne sur la fibre
         ::sophie::createOrigin $visuNo
      }
      "OBJECT" {
         set private(originCoord) $::conf(sophie,originCoord)
         set activewidth 4
         #--- je positionne la consigne sur l'objet
         ::sophie::createOrigin $visuNo
      }
   }
console::disp "=== setGuidingMode originCoord=$private(originCoord) \n"
   #--- je mets a jour la fenetre de controle
   ::sophie::control::setGuidingMode $::conf(sophie,guidingMode)

      #--- je change les paramètres dans la thread
   if { $private(acquisitionState) != 0 } {
      set xOriginCoord [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
      set yOriginCoord [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
      ::camera::setAsynchroneParameter $private(camItem) \
            "originCoord" [list $xOriginCoord $yOriginCoord]
   }


}

#------------------------------------------------------------
#------------------------------------------------------------
# Gestion des attenuateurs
#------------------------------------------------------------
#------------------------------------------------------------

#------------------------------------------------------------
# adaptIncrement
#    adapte la valeur de l'increment
#------------------------------------------------------------
proc ::sophie::adaptIncrement { } {
   variable private

   set frm $::sophie::control::private(frm)
   set increment [ $frm.guidage.positionconsigne.positionXY.spinboxIncrement get ]
   $frm.guidage.positionconsigne.positionXY.spinboxX configure -increment $increment
   $frm.guidage.positionconsigne.positionXY.spinboxY configure -increment $increment
}

####------------------------------------------------------------
#### decrementAttenuateur
####    decremente les valeurs de l'attenuteur
####------------------------------------------------------------
###proc ::sophie::decrementAttenuateur { } {
###   variable private
###
###   incr private(attenuateur) 1
###   if { $private(attenuateur) >= "100" } {
###      set private(attenuateur) "100"
###      $private(frm).attenuateur.labMax_color_invariant configure -background $::color(red)
###   } else {
###      $private(frm).attenuateur.labMin_color_invariant configure -background $::color(white)
###   }
###}
###

####------------------------------------------------------------
#### incrementAttenuateur
####    incremente les valeurs de l'attenuteur
####------------------------------------------------------------
###proc ::sophie::incrementAttenuateur { } {
###   variable private
###
###   incr private(attenuateur) -1
###   if { $private(attenuateur) <= "100" } {
###      set private(attenuateur) "100"
###      $private(frm).attenuateur.labMin_color_invariant configure -background $::color(red)
###   } else {
###      $private(frm).attenuateur.labMax_color_invariant configure -background $::color(black)
###   }
###
###   if { $private(attenuateur) >= "100" } {
###      set private(attenuateur) "100"
###      $private(frm).attenuateur.labMax_color_invariant configure -background $::color(red)
###   } else {
###      $private(frm).attenuateur.labMin_color_invariant configure -background $::color(white)
###   }
###}


#------------------------------------------------------------
# moveFilter
#  démarre le changement d'attenuation
#  Ne fait rien si le telescope n'est pas connecté
# @param  direction "-"=diminution de l'attenuation , "+" =augmentation de l'atténuation
#
#------------------------------------------------------------
proc ::sophie::moveFilter { direction } {
   variable private

   if { [ ::tel::list ] != "" } {
      set private(filterMaxDelay) [ tel$::audace(telNo) filter max ]
      set private(filterCurrentPercent) [ tel$::audace(telNo) filter coord ]
      set private(filterDirection) $direction
      #--- je demarre le deplacement
      tel$::audace(telNo) filter move $direction
      set private(updateFilterState) 1
      after 0 ::sophie::updateFilterPercent
   }


}

#------------------------------------------------------------
# stopFilter
#  Arrete le changement d'attenuation
#  affiche la fin de cours "min" en vert quand la fin de course est atteinte
#  affiche la fin de cours "max" en rouge quand la fin de course est atteinte
#------------------------------------------------------------
proc ::sophie::stopFilter { } {
   variable private

   if { $::audace(telNo) == 0 } {
      return
   }
   tel$::audace(telNo) filter stop
   #--- je recupere la position et je rafraichis l'affichage
   set private(attenuateur) [ tel$::audace(telNo) filter coord ]

   #--- j'arrete le rafraichissement de l'affichage du taux d'atténuation
   set private(updateFilterState) 0
   if { $private(updateFilterId)!="" } {
      after cancel $private(updateFilterId)
      set private(updateFilterId) ""
   }

   #--- je recupere la nouvelle valeur
   set private(attenuateur) [ tel$::audace(telNo) filter coord ]

   #--- je met a jour la couleur des fin de course
   if { $private(attenuateur) >= "100" } {
      set private(attenuateur) "100"
      $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
      $private(frm).attenuateur.labMax_color_invariant configure -background $::color(red)
   } elseif { $private(attenuateur) <= "0" } {
      $private(frm).attenuateur.labMin_color_invariant configure -background $::color(green)
      $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
   } else {
      $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
      $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
   }
}

#------------------------------------------------------------
# updateFilterPercent
#  met a jour l'affichage du taux d'attenuation en faisnt une estmation a partir de la duree du mouvement
#
#------------------------------------------------------------
proc ::sophie::updateFilterPercent { } {
   variable private

   #--- j'arrete le timer s'il est en cours
   if { $private(updateFilterId)!="" } {
      after cancel $private(updateFilterId)
      set private(updateFilterId) ""
   }

   #--- je met a jour l'affichage avec une estimation de taux d'attenuation
   if { $private(updateFilterState) == 1 } {
      if { $private(filterDirection) == "-" } {
         set private(filterCurrentPercent) [expr $private(filterCurrentPercent) - (0.25 * 100 / $private(filterMaxDelay) ) ]
      } else {
         set private(filterCurrentPercent) [expr $private(filterCurrentPercent) + (0.25 * 100 / $private(filterMaxDelay) ) ]
      }
      if { $private(filterCurrentPercent) < 0 } {
         set private(filterCurrentPercent) 0
      }
      if { $private(filterCurrentPercent) > 100 } {
         set private(filterCurrentPercent) 100
      }
      set private(attenuateur) [expr int($private(filterCurrentPercent))]
      #--- je lance la boucle d'affichage pendant la pose
      set private(updateFilterId) [after 250 ::sophie::updateFilterPercent]
   }
}



#------------------------------------------------------------
# decrementZoom
#    decremente les valeurs du zoom
#------------------------------------------------------------
proc ::sophie::decrementZoom { } {
   variable private

   if { $private(zoom) == "0.125" } {
      set private(zoom) "0.25"
   } elseif { $private(zoom) == "0.25" } {
      set private(zoom) "0.5"
   } elseif { $private(zoom) == "0.5" } {
      set private(zoom) "1"
   } elseif { $private(zoom) == "1" } {
      set private(zoom) "2"
   } elseif { $private(zoom) == "2" } {
      set private(zoom) "4"
   } elseif { $private(zoom) == "4" } {
      set private(zoom) "4"
   }
   ::confVisu::setZoom $::audace(visuNo) $private(zoom)
   set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
}

#------------------------------------------------------------
# incrementZoom
#    incremente les valeurs du zoom
#------------------------------------------------------------
proc ::sophie::incrementZoom { } {
   variable private

   if { $private(zoom) == "4" } {
      set private(zoom) "2"
   } elseif { $private(zoom) == "2" } {
      set private(zoom) "1"
   } elseif { $private(zoom) == "1" } {
      set private(zoom) "0.5"
   } elseif { $private(zoom) == "0.5" } {
      set private(zoom) "0.25"
   } elseif { $private(zoom) == "0.25" } {
      set private(zoom) "0.125"
   } elseif { $private(zoom) == "0.125" } {
      set private(zoom) "0.125"
   }
   ::confVisu::setZoom $::audace(visuNo) $private(zoom)
   set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
}

#------------------------------------------------------------
# saveImage
#  enregistre l'image courante
#  le nom du fichier :  "prefixe-date.exention"
#  avec  prefixe = "centrage" ou "guidage"  suivant le mode courant
#        date    = date courante au format ISO8601  , exemple: 2009-05-13T18:51:30.250
#        extension=.fit
#------------------------------------------------------------
proc ::sophie::saveImage { } {
   variable private

   set catchError [ catch {
      if { [file exists $::conf(sophie,imageDirectory)] == 0 } {
         #--- je signale que le repertoire n'existe pas
         tk_messageBox -title $::caption(sophie,titre) -icon error \
         -message [format $::caption(sophie,directoryNotFound) $::conf(sophie,imageDirectory)]
         return
      }

      #--- je determine le prefixe
      if { $private(mode) == "guidage" } {
         set prefix $::conf(sophie,guidingFileNameprefix)
      } else {
         set prefix $::conf(sophie,centerFileNameprefix)
      }
      #--- je recupere la date UT
      set shortName "$prefix-[mc_date2iso8601 [::audace::date_sys2ut now]].fit"
      #--- je remplace ":" par "-" car ce n'est pas un caractere autorise dasn le nom d'un fichier.
      set shortName [string map { ":" "-" } $shortName]
      #--- j'ajoute le repertoire
      set fileName [file join $::conf(sophie,imageDirectory) $shortName]
      #--- Sauvegarde de l'image
      saveima $fileName $::audace(visuNo)
   } ]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }

}

#------------------------------------------------------------
# showImage
#    affiche une visu pour monter les images enregistrees
#------------------------------------------------------------
proc ::sophie::showImage { } {

   if { [file exists $::conf(sophie,imageDirectory) ] == 1 } {
      #--- j'ouvre une visu
      set visuSophie [ ::confVisu::create ]
      #--- je selectionne l'outil Visionneuse bis
      ::confVisu::selectTool $visuSophie ::visio2
      #--- je selectionne le répertoire
      ::visio2::localTable::init $visuSophie "" $::conf(sophie,imageDirectory)
      #--- j'affiche le contenu du repertoire
      ##::visio2::localTable::fillTable $visuSophie
   } else {
      tk_messageBox -title $::caption(sophie,titre) -icon error -message $::caption(sophie,invalidDirectory)
   }

}

##------------------------------------------------------------
# onOriginCoord
#    initialise la position de la consigne avec la souris
#
# @param visuNo numero de la visu courante
# @param x      abcisse de la souris (referentiel ecran)
# @param y      ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
###proc ::sophie::onOriginCoord { visuNo x y } {
###   variable private
###
###   if { $::conf(sophie,guidingMode) == "FIBER" } {
###      #--- je convertis en coordonnes du referentiel Image
###      set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
###      set coord [::confVisu::canvas2Picture $visuNo $coord]
###
###      scan $private(binning) "%dx%d" xBinning yBinning
###      set x [expr [lindex $coord 0] * $xBinning + $private(xWindow) -1 ]
###      set y [expr [lindex $coord 1] * $yBinning + $private(yWindow) -1 ]
###      set private(originCoord) [list $x $y]
###
###      ###set private(originCoord) $coord
###
###      #--- je dessine les axes sur la nouvelle origine
###      createOrigin $visuNo
###
###      ::camera::setParam $private(camItem) "originCoord" $coord
###   }
###}

#------------------------------------------------------------
# createOrigin
#    affiche la cible autour du point de coordonnees OriginCoord
#
# @param visuNo  numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::createOrigin { visuNo } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteOrigin $visuNo
   #--- j'efface la consigne
   $private(hCanvas) delete "origin"

   #--- je calcule les coordonnees dans l'image
   set x [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
   set y [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]

   switch $::conf(sophie,guidingMode) {
      "OBJECT" {
         set activewidth 4
      }
      default {
         set activewidth 2
      }
   }

   #--- je dessine la consigne
   set vide 4

   set x1  [expr int ($x + $vide) ]
   set y1  [expr int ($y + $vide) ]
   set x2  [expr int ($x + $::conf(sophie,originBoxSize) /2) ]
   set y2  [expr int ($y + $::conf(sophie,originBoxSize) /2) ]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x1 $y1 ] ]
   set x1 [lindex $coords 0]
   set y1 [lindex $coords 1]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x2 $y2 ] ]
   set x2 [lindex $coords 0]
   set y2 [lindex $coords 1]
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tag "origin" -activewidth $activewidth -width 2

   set x1  [expr int ($x + $vide) ]
   set y1  [expr int ($y - $vide) ]
   set x2  [expr int ($x + $::conf(sophie,originBoxSize) /2) ]
   set y2  [expr int ($y - $::conf(sophie,originBoxSize) /2) ]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x1 $y1 ] ]
   set x1 [lindex $coords 0]
   set y1 [lindex $coords 1]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x2 $y2 ] ]
   set x2 [lindex $coords 0]
   set y2 [lindex $coords 1]
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tag "origin" -activewidth $activewidth -width 2

   set x1  [expr int ($x - $vide) ]
   set y1  [expr int ($y + $vide) ]
   set x2  [expr int ($x - $::conf(sophie,originBoxSize) /2) ]
   set y2  [expr int ($y + $::conf(sophie,originBoxSize) /2) ]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x1 $y1 ] ]
   set x1 [lindex $coords 0]
   set y1 [lindex $coords 1]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x2 $y2 ] ]
   set x2 [lindex $coords 0]
   set y2 [lindex $coords 1]
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tag "origin" -activewidth $activewidth -width 2

   set x1  [expr int ($x - $vide) ]
   set y1  [expr int ($y - $vide) ]
   set x2  [expr int ($x - $::conf(sophie,originBoxSize) /2) ]
   set y2  [expr int ($y - $::conf(sophie,originBoxSize) /2) ]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x1 $y1 ] ]
   set x1 [lindex $coords 0]
   set y1 [lindex $coords 1]
   set coords [ ::confVisu::picture2Canvas $visuNo [list  $x2 $y2 ] ]
   set x2 [lindex $coords 0]
   set y2 [lindex $coords 1]
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tag "origin" -activewidth $activewidth -width 2


}

#------------------------------------------------------------
# deleteOrigin
#    supprime l'affichage de la consigne
#
# @param visuNo      numero de la visu courante
#------------------------------------------------------------
proc ::sophie::deleteOrigin { visuNo } {
   variable private

   #--- je supprime l'ffichage de la cible
   $private(hCanvas) delete "origin"
   $private(hCanvas) dtag "origin"
}

##------------------------------------------------------------
# moveOrigin
# deplace l'affichage de la consigne
#
# @param visuNo         numero de la visu courante
# @param originCoord    coordonnees de la consigne (referentiel Image)
# @return  null
#------------------------------------------------------------
proc ::sophie::moveOrigin { visuNo originCoord } {
   variable private

   #--- je calcule les coordonnees dans le buffer
   set x  [lindex $originCoord 0]
   set y  [lindex $originCoord 1]
   set x1 [expr $x - $::conf(sophie,originBoxSize)]
   set x2 [expr $x + $::conf(sophie,originBoxSize)]
   set y1 [expr $y - $::conf(sophie,originBoxSize)]
   set y2 [expr $y + $::conf(sophie,originBoxSize)]

   #--- je calcule les coordonnees dans le canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set xCan1 [lindex $coord 0]
   set yCan1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set xCan2 [lindex $coord 0]
   set yCan2 [lindex $coord 1]

   #--- je deplace la cible aux nouvelles coordonnees
   $private(hCanvas) coords "origin" [list $xCan1 $yCan1 $xCan2 $yCan2]
}

##------------------------------------------------------------
# onTargetCoord
#    initialise les coordonnees de la cible avec la souris
#
# @param visuNo  numero de la visu courante
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::sophie::onTargetCoord { visuNo x y } {
   variable private

   #--- je verifie qu'une image est presente dasn le buffer
   if { [buf[visu$visuNo buf] imageready] == 0 } {
      return
   }

   #--- je calcule les coordonnees de l'etoile dans l'image
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]

   set x [expr [lindex $coord 0] * $private(xBinning) + $private(xWindow) -1 ]
   set y [expr [lindex $coord 1] * $private(yBinning) + $private(yWindow) -1 ]
   set private(targetCoord) [list $x $y]
   #--- je positionne la cible sur les nouvelles coordonnees
   moveTarget $visuNo $private(targetCoord)


   #--- je transmet les coordonnees a l'interperteur de la camera
   ::camera::setAsynchroneParameter  $private(camItem) "targetCoord" $coord
}

##------------------------------------------------------------
# createTarget
#    affiche la cible autour du point de coordonnees targetCoord
#
#           PSF
#       *----------* y1=y0+w
#       |          |
#       |          |
#     ..|..........|..........
#       |          |
#       |          |
#       *----------* y1=y0-w
#       x1         x2
# @param visuNo  numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::createTarget { visuNo } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteTarget $visuNo

   #--- je calcule les coordonnees dans l'image
   set x [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
   set y [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]

   set x1 [expr $x - ($private(targetBoxSize) / (2.0 * $private(xBinning) ))]
   set x2 [expr $x + ($private(targetBoxSize) / (2.0 * $private(yBinning) ))]
   set y1 [expr $y - ($private(targetBoxSize) / (2.0 * $private(xBinning) ))]
   set y2 [expr $y + ($private(targetBoxSize) / (2.0 * $private(yBinning) ))]

   #--- je calcule les coordonnees dans le canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set x1 [lindex $coord 0]
   set y1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set x2 [lindex $coord 0]
   set y2 [lindex $coord 1]

   #--- je cree les items graphiques dans le canvas
   $private(hCanvas) create rect $x1 $y1 $x2 $y2 -outline red -offset center -tag target
}

##------------------------------------------------------------
# deleteTarget
#    supprime l'affichage de la cible
#
# @param visuNo      numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::deleteTarget { visuNo } {
   variable private

   #--- je supprime l'ffichage de la cible
   $private(hCanvas) delete "target"
   $private(hCanvas) dtag "target"
}

##------------------------------------------------------------
# moveTarget
#    deplace l'affichage de la cible
#
# @param visuNo         numero de la visu courante
# @param targetCoord    coordonnees de la cible (referentiel Image)
# @return  null
#------------------------------------------------------------
proc ::sophie::moveTarget { visuNo targetCoord } {
   variable private

   #--- je calcule les coordonnees dans l'image
   set x  [lindex $targetCoord 0]
   set y  [lindex $targetCoord 1]
   set x [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
   set y [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]

   set x1 [expr $x - ($private(targetBoxSize) / (2.0 * $private(xBinning) ))]
   set x2 [expr $x + ($private(targetBoxSize) / (2.0 * $private(yBinning) ))]
   set y1 [expr $y - ($private(targetBoxSize) / (2.0 * $private(xBinning) ))]
   set y2 [expr $y + ($private(targetBoxSize) / (2.0 * $private(yBinning) ))]

   #--- je calcule les coordonnees dans le canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set xCan1 [lindex $coord 0]
   set yCan1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set xCan2 [lindex $coord 0]
   set yCan2 [lindex $coord 1]

   #--- je deplace la cible aux nouvelles coordonnees
   $private(hCanvas) coords "target" [list $xCan1 $yCan1 $xCan2 $yCan2]
}

#------------------------------------------------------------
#  setMountEnabled
#     active ou descative l'envoi des commandes de guidage a la monture
#     si state = 1 , les commandes sont envoyees
#     si state = 0 , les commandes ne sont pas envoyees
#
# @param visuNo      numero de la visu courante
# @param state       activation/desactivation de l'envoi des commandes à la monture
# @return  null
#------------------------------------------------------------
proc ::sophie::setMountEnabled { visuNo state } {
   variable private

   if { $state != "" } {
      set private(mountEnabled) $state
   }

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private(mountEnabled) == 1 } {
      #--- je configure la monture avec la vitesse la plus lente
      ::telescope::setSpeed 1
   }

   set private(delay,alpha)      "0.00"
   set private(delay,delta)      "0.00"
   #--- je notifie l'interperteur de la camera
   ::camera::setAsynchroneParameter  $private(camItem) "mountEnabled" $private(mountEnabled)
}

##------------------------------------------------------------
# startAcquisition
#    lance les acquisitions continues
# @param visuNo numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::startAcquisition { visuNo } {
   variable private

   if { $private(acquisitionState) == 1 } {
      return ""
   }

   #--- je verifie la presence d'une camera
   if { [::confCam::isReady $private(camItem)] == 0 } {
      ::confCam::run
      return 1
   }

   #--- je verifie la presence d'une monture
   if { [::confTel::isReady] == 0 } {
      ::confTel::run
      return 1
   }

   set catchError [ catch {
      #--- je transforme le bouton GO en bouton STOP
      $private(frm).acq.goAcq configure -text $::caption(sophie,stopAcq) \
         -command "::sophie::stopAcquisition $visuNo"
      #--- J'associe la commande d'arret a la touche ESCAPE
      bind all <Key-Escape> "::sophie::stopAcquisition $visuNo"

      if { $private(mode)== "centrage" } {
         #--- j'autorise le bouton de centrage
         $private(frm).mode.centrageStart configure -state normal
      } else {
        #--- j'interdis le bouton de centrage
        $private(frm).mode.centrageStart  configure -state disabled
      }

      if { $private(mode)== "guidage" } {
         #--- j'autorise le bouton de guidage
         $private(frm).mode.guidageStart configure -state normal
      } else {
        #--- j'interdis le bouton de guidage
        $private(frm).mode.guidageStart  configure -state disabled
      }

      #--- j'initialise les valeurs affichees
      set private(acquisitionState)  1
      #--- je mets a jour la fenetre de controle
      ::sophie::control::setAcquisitionState  $private(acquisitionState)
      #--- je postionne les parametres du mode courant
      setMode

      #--- je potionne la vitesse "guidage" de la monture si l'envoi des rappels est actif
      if { $private(mountEnabled) == 1 } {
         ::telescope::setSpeed 1
      }

      if { $::conf(sophie,simulation) == 1 } {
         ::camera::setParam $private(camItem) "simulation" 1
         ::camera::setParam $private(camItem) "simulationGenericFileName" $::conf(sophie,simulationGenericFileName)
      } else {
         ::camera::setParam $private(camItem) "simulation" 0
      }

      set guidingSpeed  [::confTel::getPluginProperty "guidingSpeed"]

      #--- j'ouvre l'obturateur de la camera
      cam$private(camNo) shutter opened
      ###cam$private(camNo) shutter synchro
      ###::confCam::setShutter $private(camItem) [::confCam::getShutter $private(camItem)] "set"

      set slitWidth  0.0   ; #--- largeur de la fente
      set slitRatio  0.0   ; #--- coefficient
      set intervalle 0.0  ; #--- intervalle de temps entre de 2 acquisitions
      set seuilx $::conf(sophie,thresold)  ; #--- seuil minimum de correction sur l'axe x en arcsec
      set seuily $::conf(sophie,thresold)  ; #--- seuil minimum de correction sur l'axe y
      set cameraAngle 0.0 ;                  #angle de la camera
      set declinaisonEnabled 1 ;                #--- correction en declinaison activee
      set alphaSpeed [lindex $guidingSpeed 1 ]
      set deltaSpeed [lindex $guidingSpeed 1 ]

      ::camera::setAsynchroneParameter $private(camItem) \
         "targetDetectionThresold" $::conf(sophie,targetDetectionThresold) \
         "pixelScale"              $::conf(sophie,pixelScale) \
         "targetDec"               [ mc_angle2deg $::audace(telescope,getdec) 90 ] \
         "proportionalGain"        $::conf(sophie,proportionalGain) \
         "integralGain"            $::conf(sophie,integralGain) \
         "binning"                 [list $private(xBinning) $private(yBinning)]

      #set xOriginCoord [ expr  [lindex $private(originCoord) 0] / $private(xBinning) ]
      #set yOriginCoord [ expr  [lindex $private(originCoord) 1] / $private(yBinning) ]
      #set xTargetCoord [ expr  [lindex $private(targetCoord) 0] / $private(xBinning) ]
      #set yTargetCoord [ expr  [lindex $private(targetCoord) 1] / $private(yBinning) ]

        #--- je calcule les coordonnees dans l'image
      set originX [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
      set originY [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]
      set targetX [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
      set targetY [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]
      set targetBoxSize [ expr int( $private(targetBoxSize) / (2.0 * $private(xBinning) )) ]

console::disp "startAcquisition originX=[lindex $private(originCoord) 0] originY=[lindex $private(originCoord) 1] \n"

      #--- je fais l'acquisition
      ::camera::guide $private(camItem) "::sophie::callbackAcquisition $visuNo" \
         $::conf(sophie,exposure)           \
         "FIBER"                            \
         [list $originX $originY]           \
         [list $targetX $targetY] \
         $cameraAngle                       \
         $targetBoxSize                     \
         $private(mountEnabled)             \
         $alphaSpeed                        \
         $deltaSpeed                        \
         $::conf(sophie,alphaReverse)       \
         $::conf(sophie,deltaReverse)       \
         $seuilx                            \
         $seuily                            \
         $slitWidth                         \
         $slitRatio                         \
         $intervalle                        \
         $declinaisonEnabled

   } ] ;#--- fin du catch

   #--- je traite les erreur imprevues
   if { $catchError != 0 } {
      #--- J'arrete les acquisitions
      stopAcquisition $visuNo
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }

}

#------------------------------------------------------------
# stopAcquisition
#    Demande l'arret des acquisitions . L'arret sera effectif apres la fin
#    de l'acquisition en cours
#------------------------------------------------------------
proc ::sophie::stopAcquisition { visuNo } {
   variable private

   if { $private(acquisitionState) == 1 } {
      #--- je demande l'arret des acquisitions
      if { $private(camItem) != "" } {
         ::camera::stopAcquisition $private(camItem)
      }
      #--- je transforme le bouton STOP en bouton GO
      $private(frm).acq.goAcq configure -text $::caption(sophie,goAcq) \
         -command "::sophie::startAcquisition $visuNo"
      #--- je supprime l'association du bouton escape
      bind all <Key-Escape> ""

      #--- je mets a jour l'indicateur d'acquisition
      set private(acquisitionState) 0
      #--- je mets a jour la fenetre de controle
      ::sophie::control::setAcquisitionState  $private(acquisitionState)

      #--- j'arrete le centrage s'il était en cours
      stopCenter

      #--- je ferme lobturateur de la camera
      #cam$private(camNo) shutter closed

   }
}

##------------------------------------------------------------
# startCenter
#    lance le centrage (centrage en cours)
#
# @return  null
#------------------------------------------------------------
proc ::sophie::startCenter { } {
   variable private

   #--- je verifie que les acqusitions sont lancees
   if { $private(acquisitionState) == 0 } {
      tk_messageBox -title $::caption(sophie,titre) -icon error -message $::caption(sophie,noAcquisition)
      set private(centerEnabled) 0
      return
   }

   set private(centerEnabled) 1
   #--- j'active le centrage dans la thread de la camera
   ::camera::setAsynchroneParameter $private(camItem) \
         "seuilx" $::conf(sophie,thresold) \
         "seuily" $::conf(sophie,thresold) \
         "mode" "center" \
         "mountEnabled" "1"

   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setCenterState $private(centerEnabled)
}

##------------------------------------------------------------
# stopCenter
#    arrete le centrage (centrage termine)
# @return  null
#------------------------------------------------------------
proc ::sophie::stopCenter { } {
   variable private

   set private(centerEnabled) 0
   #--- j'arrete le centrage dans la thread de la camera

   ::telescope::stop ""
   ::camera::setAsynchroneParameter $private(camItem) \
         "mode" "guide" \
         "mountEnabled" "0"
   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setCenterState $private(centerEnabled)
}

##------------------------------------------------------------
# startGuide
#    lance le guidage
#
# @return  null
#------------------------------------------------------------
proc ::sophie::startGuide { } {
   variable private

   #--- je verifie que les acqusitions sont lancees
   if { $private(acquisitionState) == 0 } {
      tk_messageBox -title $::caption(sophie,titre) -icon error -message $::caption(sophie,noAcquisition)
      set private(guideEnabled) 0
      return
   }

   set private(guideEnabled) 1
   #--- j'active le centrage dans la thread de la camera
   #--- j'active le centrage dans la thread de la camera
   ::camera::setAsynchroneParameter $private(camItem) \
         "mode" "guide" \
         "mountEnabled" "1"

   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setGuideState $private(guideEnabled)
}

##------------------------------------------------------------
# stopGuide
#    arrete le guidage
# @return  null
#------------------------------------------------------------
proc ::sophie::stopGuide { } {
   variable private

   set private(guideEnabled) 0
   #--- j'arrete le centrage dans la thread de la camera
   ::telescope::stop ""
   ::camera::setAsynchroneParameter $private(camItem) \
         "mode" "guide" \
         "mountEnabled" "0"

   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setGuideState $private(guideEnabled)

}

##------------------------------------------------------------
# callbackAcquisition
# cette procedure est appele par la thread de la camera pednant les acquisitions
# @param visuNo numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::callbackAcquisition { visuNo command args } {
   variable private

   if { [winfo exists $private(frm)] == 0 } {
      return
   }

   set catchError [ catch {
      ###console::disp "callbackAcquisition visu=$visuNo command=$command args=$args\n"
      switch $command  {
         "autovisu" {
            #--- j'affiche l'image
            ::confVisu::autovisu $visuNo
            #--- j'affiche le delay entre 2 poses
            ::sophie::control::setRealDelay [lindex [lindex $args 0] 0]
            ###visu$visuNo disp

        }
         "error" {
            console::affiche_erreur "callbackGuide visu=$visuNo command=$command $args\n"
            #--- j'arrete les acquisitions continues en cas d'erreur
            ::sophie::stopAcquisition $visuNo
         }
         "targetCoord" {
            # descriptionde s parametres
            # args 0 = coordonnees de l'étoile, ou coordonnees du centre de la zone de recherche si l'étoile n'a pas ete trouvee
            # args 1 = dx
            # args 2 = dy
            # args 3 = nombre d'étoiles detectees dans l'image
            # args 4 = nombre de trous detectes dans l'image
            # args 5 = 0 originX, 1 originY,
            #          2 fwhmX,   3  fwhmY,
            #          4 background, 5 maxIntensity,
            #          6 flow,
            #          7 alphaDiff, 8 deltaDiff

            set previousTargetDetection $private(targetDetection)

            #--- je recupere les informations
            set starX                [expr [lindex [lindex $args 0] 0] * $private(xBinning)+ $private(xWindow) -1 ]
            set starY                [expr [lindex [lindex $args 0] 1] * $private(yBinning) + $private(yWindow) -1 ]
            set private(targetCoord) [list $starX $starY]
            set starDx               [lindex $args 1]
            set starDy               [lindex $args 2]
            set private(targetDetection)  [lindex $args 3]
            set originDetection      [lindex $args 4]
            set params               [lindex $args 5]

            set originX              [expr [lindex $params 0] * $private(xBinning) + $private(xWindow) -1 ]
            set originY              [expr [lindex $params 1] * $private(yBinning) + $private(yWindow) -1 ]
            set originDx             0.0
            set originDy             0.0
            set fwhmX                [lindex $params 2]
            set fwhmY                [lindex $params 3]
            set background           [lindex $params 4]
            set maxIntensity         [lindex $params 5]
            set flow                 [lindex $params 6]
            set alphaCorrection      [lindex $params 7]
            set deltaCorrection      [lindex $params 8]
            #--- je deplace la cible sur les nouvelles corrdonnees
            ::sophie::moveTarget $visuNo $private(targetCoord)

            #--- j'affiche le symbole de l'origine
            ::sophie::createOrigin $visuNo

            #--- j'affiche les informations dans la fenetre de controle
            switch $private(mode) {
               "centrage" {
                  ::sophie::control::setCenterInformation $private(targetDetection) $originDetection $originX $originY $starX $starY $fwhmX $fwhmY $background $maxIntensity
               }
               "focalisation" {
                  ::sophie::control::setFocusInformation $private(targetDetection) $originDetection $originX $originY $starX $starY $fwhmX $fwhmY $background $flow $maxIntensity
                  #--- je change le mode d'affichage si la detection de l'etoile a change
                  ##if { $previousTargetDetection != $private(targetDetection)  } {
                  ##   sophie::setMode $private(mode)
                  ##}
               }
               "guidage" {
                  ::sophie::control::setGuideInformation $private(targetDetection) $originDetection $originX $originY $starX $starY $starDx $starDy $alphaCorrection $deltaCorrection $originDx $originDy
                  #--- je change le mode d'affichage si la detection de l'etoile a change
                  ##if { $previousTargetDetection != $private(targetDetection)  } {
                  ##   sophie::setMode $private(mode)
                  ##}
               }
            }
         }
         "acquisitionResult" {
            #--- j'affiche les informations dans la fenetre de controle
###console::disp "callbackAcquisition acquisitionResult $args\n"
            switch [lindex [lindex $args 0] 0] {
               "center" {
                  #--- fin du centrage
                  #--- j'arrrete le centrage
                  stopCenter

               }
               "end" {
                  cam$private(camNo) shutter closed
               }
            }
         }
      }
   } ]

   #--- je traite les erreur imprevues
   if { $catchError != 0 } {
      #--- J'arrete les acquisitions
      stopAcquisition $visuNo
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }
}

