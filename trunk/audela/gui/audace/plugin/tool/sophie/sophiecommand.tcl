##------------------------------------------------------------
# @file     sophiecommand.tcl
# @brief    Fichier du namespace ::sophie (suite du fichier sophie.tcl)
# @author   Michel PUJOL et Robert DELMAS
# @version  $Id: sophiecommand.tcl,v 1.34 2009-09-13 15:07:51 michelpujol Exp $
#------------------------------------------------------------

##------------------------------------------------------------
# @brief   commandes de la fenêtre principale de l'outil sophie
#
#------------------------------------------------------------
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

   #--- je recupere l'item de la camera
   set private(camItem) [ ::confVisu::getCamItem $visuNo ]
   set private(camNo)   [ ::confCam::getCamNo $private(camItem) ]

   if { $private(camNo) != 0 } {
      if { [::confCam::getPluginProperty $private(camItem) hasBinning] == "0" } {
        ### $frm.acq.labBinning configure -state disabled
        ### $frm.acq.binning.a configure -state disabled
        ### $frm.acq.binning.e configure -state disabled
         set private(listeBinning) "1x1"
         ###::sophie::setBinning "1x1"
         #--- Je mets a jour le binning en fonction du mode
         ::sophie::setMode
      } else {
        ### $frm.acq.labBinning configure -state normal
        ### $frm.acq.binning.a configure -state normal
        ### $frm.acq.binning.e configure -state normal
         #--- je mets a jour la liste des binning
        ### set private(listeBinning) [::confCam::getPluginProperty $private(camItem) binningList]
        ### $frm.acq.binning configure -values $private(listeBinning) -height [llength $private(listeBinning)]
        ### if { [lsearch $private(listeBinning) $private(widgetBinning)] == -1 } {
        ###    #--- je selectionnele premier binning s'il n'existe pas dans la liste
        ###    set private(widgetBinning) [lindex $private(listeBinning) 0 ]
        ### }
      }
      #--- je recupere la taille du capteur en pixel (en binning 1x1)
      set private(cameraCells) [cam$private(camNo) nbcells]

      #--- je charge sophiecamerathread.tcl dans l'interpreteur de le thread de la camera
      ::camera::loadSource $private(camItem) [file join $::audace(rep_plugin) tool sophie sophiecamerathread.tcl]
   }

   #--- j'adapte les boutons de selection de pose et de binning
   ####if { [::confCam::getPluginProperty $private(camItem) longExposure] == "1" } {
   ####   #--- cameras autre que webcam, ou webcam avec la longue pose
   ####   pack $frm.pose.lab1 -anchor center -side left -padx 5
   ####   pack $frm.pose.combo -anchor center -side left -fill x -expand 1
   ####   pack forget $frm.pose.confwebcam
   ####} else {
   ####   #--- webcam
   ####   pack forget $frm.pose.lab1
   ####   pack forget $frm.pose.combo
   ####   pack $frm.pose.confwebcam -anchor center -side left -fill x -expand 1
   ####   #--- je mets la pose a zero car cette variable est utilisee et doit etre nulle pour les courtes poses
   ####   set ::conf(sophie,exposure) "0"
   ####}
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

##------------------------------------------------------------
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

##------------------------------------------------------------
# showConfigWindow
#    ouvre la fenetre de configuration
#
# @param visuNo       numero de la visu courante
#------------------------------------------------------------
proc ::sophie::showConfigWindow { visuNo } {
   variable private

   ::sophie::config::run $visuNo [winfo toplevel $private(frm)]
}

##------------------------------------------------------------
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

##------------------------------------------------------------
# setBinningAndWindow
#  applique le changement de binning
#
# @param  binning   binning x et y  sous la forme 1x1 2x2 ...
# @return rien
#------------------------------------------------------------
proc ::sophie::setBinningAndWindow { binning { windowSize ""} { centerCoords "" } } {
   variable private

   if { [lsearch $private(listeBinning) $binning] == -1 } {
      #--- je ne change pas le binning s'il n'existe pas dans la liste des binnings de la camera
      return
   }
   set private(widgetBinning) $binning
   scan $binning "%dx%d" xBinning yBinning
   set private(xBinning) $xBinning
   set private(yBinning) $yBinning

   set width  [lindex $private(cameraCells) 0 ]
   set height [lindex $private(cameraCells) 1 ]

   if { $windowSize == "" } {
      set windowSize $private(windowSize)
   }

   if { $centerCoords == "" } {
      set centerCoords $private(centerCoords)
   }

   if { $windowSize == "full" } {
      #--- pas de fenetrage
      set x1 1
      set y1 1
      set x2 $width
      set y2 $height
      #--- je memorise les coordonnee du coin bas gauche du fenetrage
      set private(xWindow) $x1
      set private(yWindow) $y1
   } else {
      set size [expr $windowSize / 2 ]
      set x  [lindex $centerCoords 0]
      set y  [lindex $centerCoords 1]
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
      #--- je memorise les coordonnee du coin bas gauche du fenetrage
      set private(xWindow) $x1
      set private(yWindow) $y1
   }
   #--- je memorise la taille du fenetrage
   set private(windowSize) $windowSize
   set private(centerCoords) $centerCoords

   set xOriginCoord [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
   set yOriginCoord [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
   set xTargetCoord [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
   set yTargetCoord [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]

   #--- je charge le bias correspondant au binning et j'applique le fentrage
   if { $windowSize == "full" } {
      loadBias "full"
   } else {
      set x1b [expr $x1 / $private(xBinning)]
      set y1b [expr $y1 / $private(yBinning)]
      set x2b [expr $x2 / $private(xBinning)]
      set y2b [expr $y2 / $private(yBinning)]
      loadBias [list $x1b $y1b $x2b $y2b]
   }
   #--- je change les paramètres dans le thread
   if { $private(acquisitionState) != 0 } {
      set targetBoxSize [ expr int($private(targetBoxSize) / (2.0 * $private(xBinning))) ]
      set private(AsynchroneParameter) 1
      ::camera::setAsynchroneParameter $private(camItem) \
         "binning"      [list $private(xBinning) $private(yBinning)] \
         "window"       [list $x1 $y1 $x2 $y2 ] \
         "originCoord"  [list $xOriginCoord $yOriginCoord] \
         "targetCoord"  [list $xTargetCoord $yTargetCoord] \
         "maskRadius"   [expr $::conf(sophie,maskRadius) / $private(xBinning)]  \
         "maskFwhm"     [expr $::conf(sophie,maskFwhm)   / $private(xBinning)]   \
         "targetBoxSize" $targetBoxSize \
         "biasValue"    $private(biasValue)
   }
}

##------------------------------------------------------------
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

   #--- je change les paramètres dans le thread
   if { $private(acquisitionState) != 0 } {
      set private(AsynchroneParameter) 1
      ::camera::setAsynchroneParameter $private(camItem) "exptime" $::conf(sophie,exposure)
   }
}

##------------------------------------------------------------
# onChangeBinning
#  cette procedure est appellee par la combobox de choix du binning
#  pour changer de binning
#------------------------------------------------------------
proc ::sophie::onChangeBinning { visuNo } {
   variable private

   #--- je change le binning
   ###setBinning $private(widgetBinning)
   setBinningAndWindow $private(widgetBinning)
}

##------------------------------------------------------------
# onChangeExposure
#  cette procedure est appellee par la commbbo de choix du temps de pose
#  pour changer le temps de pose
#------------------------------------------------------------
proc ::sophie::onChangeExposure { visuNo } {
   variable private

   #--- je choisis une valeur non disponible dans la liste
   if { $::conf(sophie,exposure) == "new" } {
      ::sophie::getNewExposure
   }

   #--- je change le mode d'acquisition
   setExposure $::conf(sophie,exposure)
}

#------------------------------------------------------------
# getNewExposure
#  affiche une fenetre pour saisir un nouveau temps de pose
#  dans la liste
#------------------------------------------------------------
proc ::sophie::getNewExposure { } {
   variable private

   #--- Toplevel
   set private(base) $::audace(base).newExposure
   toplevel $private(base) -class Toplevel
   wm title $private(base) $::caption(sophie,newExposure)
   wm transient $private(base) $::audace(base)
   set posx [ lindex [ split [ wm geometry $::audace(base) ] "+" ] 1 ]
   set posy [ lindex [ split [ wm geometry $::audace(base) ] "+" ] 2 ]
   wm geometry $private(base) +[ expr $posx + 160 ]+[ expr $posy + 105 ]
   wm resizable $private(base) 0 0
   wm protocol $private(base) WM_DELETE_WINDOW {
      set ::conf(sophie,exposure) "0.5"
      destroy $::sophie::private(base)
   }
   #--- Label et entry
   frame $private(base).newExposure -borderwidth 2 -relief raised
      label $private(base).newExposure.lab1 -text "$::caption(sophie,newValue)"
      pack $private(base).newExposure.lab1 -side left -anchor se -padx 5 -pady 5 -expand 0
      entry $private(base).newExposure.ent1 -textvariable ::sophie::private(newExposure) -width 7 \
         -relief groove -justify center
      pack $private(base).newExposure.ent1 -side left -anchor se -padx 5 -pady 5 -expand 0
   pack $private(base).newExposure -side top -fill x -expand 0
   #--- Boutons
   frame $private(base).button -borderwidth 2 -relief raised
      #--- Button OK
      button $private(base).button.ok -text $::caption(sophie,ok) -borderwidth 2 \
         -command {
            if { $::sophie::private(newExposure) != "" } {
               set ::conf(sophie,exposure) $::sophie::private(newExposure)
               destroy $::sophie::private(base)
            }
         }
      pack $private(base).button.ok -side left -anchor center -padx 10 -pady 5 \
         -ipadx 10 -ipady 5 -expand 0
      #--- Button Annuler
      button $private(base).button.annuler -text $::caption(sophie,annuler) -borderwidth 2 \
         -command {
            set ::conf(sophie,exposure) "0.5"
            destroy $::sophie::private(base)
         }
      pack $private(base).button.annuler -side right -anchor center -padx 10 -pady 5 \
         -ipadx 10 -ipady 5 -expand 0
   pack $private(base).button -side top -anchor center -fill x -expand 0
}

#------------------------------------------------------------
# getVisuNo
#  retourne le numero de la visu dans laquelle est affiche l'outil sophie
#------------------------------------------------------------
proc ::sophie::getVisuNo { } {
   variable private

   return $private(visuNo)
}

##------------------------------------------------------------
# onChangeMode
#  cette procedure est appellee par les boutons de changement de mode
#  pour changer de mode. Elle appelle setMode pour appliquer le nouveau mode.
#
#------------------------------------------------------------
proc ::sophie::onChangeMode { } {
   variable private

   #--- je change le mode d'acquisition
   setMode $private(mode)
}

##------------------------------------------------------------
# onFiberDetection
#  cette procedure est appellee par le bouton de changement de detection de fibre
#
#------------------------------------------------------------
proc ::sophie::onFiberDetection { } {
   variable private

   setFiberDetection $private(findFiber)
}

##------------------------------------------------------------
# onCenter
#  cette procedure est appellee quand on clique sur la chekbox de centrage
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

##------------------------------------------------------------
# onGuide
#  cette procedure est appellee quand on clique sur la chekbox de guidage
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

##------------------------------------------------------------
# setMode
#    change le mode d'acquisition
#      - change les paramètres de l'acquisition continue dans le thread de la camera
#      - met à jour l'affichage de la fenetre de contole
#
# @param mode mode d'acquisition CENTER FOCUS GUIDE ou "".
#     Si le mode est vide, c'est le mode qui a ete choisi dans la fenetre
#     principale qui est applique.
#------------------------------------------------------------
proc ::sophie::setMode { { mode "" } } {
   variable private

   #--- je desactive le mode precedent
   $private(frm).mode.centrageStart configure -state disabled

   #--- je mets a jour la variable
   if { $mode != "" } {
      set private(mode) $mode
   }
   #--- j'applique le nouveau mode
   switch $private(mode) {
      "CENTER" {
         #--- j'arrete le guidage
         if { $private(guideEnabled) == 1 } {
            stopGuide
         }
         #--- j'autorise le bouton de centrage
         $private(frm).mode.centrageStart configure -state normal
         #--- j'interdis le bouton de guidage
         $private(frm).mode.guidageStart  configure -state disabled
         #--- j'interdis le bouton de detection de la fibre
         $private(frm).mode.findFiber  configure -state disabled
         set private(findFiber) 0
         #--- je change la taille de la cible
         set private(targetBoxSize) $::conf(sophie,centerWindowSize)
         #--- je mets le thread de la camera en mode centrage et je desactive la detection de la fibre
         ::camera::setAsynchroneParameter $private(camItem) \
            "mode" "CENTER" \
            "findFiber" $private(findFiber)
         #--- je change le binning et je supprime le fentrage
         setBinningAndWindow $::conf(sophie,centerBinning) "full"
         #--- je change le zoom
         set private(pendingZoom) 1
      }
      "FOCUS" {
         #--- j'arrete le centrage
         if { $private(centerEnabled) == 1 } {
            stopCenter
         }
         #--- j'arrete le guidage
         if { $private(guideEnabled) == 1 } {
            stopGuide
         }
         #--- j'interdis le bouton de centrage
         $private(frm).mode.centrageStart  configure -state disabled
         #--- j'interdis le bouton de guidage
         $private(frm).mode.guidageStart  configure -state disabled
         #--- j'interdis le bouton de detection de la fibre
         $private(frm).mode.findFiber  configure -state disabled
         set private(findFiber) 0
         #--- je change la taille de d'analyse de la cible
         set private(targetBoxSize) $::conf(sophie,centerWindowSize)
         #--- je mets le thread de la camera en mode centrage et je desactive la detection de la fibre
         ::camera::setAsynchroneParameter $private(camItem) \
            "mode" "CENTER" \
            "findFiber" $private(findFiber)
         #--- je change le binning et je cree une fenetre centree sur l'étoile
         setBinningAndWindow $::conf(sophie,focuseBinning) $private(targetBoxSize) $private(targetCoord)
         #--- j'applique le zoom 4
         set private(pendingZoom) 4
      }
      "GUIDE" {
         #--- j'arrete le centrage
         if { $private(centerEnabled) == 1 } {
            stopCenter
         }
         #--- j'interdis le bouton de centrage
         $private(frm).mode.centrageStart  configure -state disabled
         if { $private(acquisitionState) == 1 } {
            #--- j'autorise le bouton de guidage
            $private(frm).mode.guidageStart configure -state normal
         } else {
           #--- j'interdis le bouton de guidage
           $private(frm).mode.guidageStart  configure -state disabled
         }
         #--- j'interdis le bouton de detection de la fibre si on est en guidage sur fibre
         if { $::conf(sophie,guidingMode) != "OBJECT" } {
            $private(frm).mode.findFiber  configure -state normal
         } else {
            $private(frm).mode.findFiber  configure -state disabled
            set private(findFiber) 0
         }

         buf$private(maskBufNo)  clear
         buf$private(sumBufNo)   clear
         buf$private(fiberBufNo) clear
         #--- je memorise les coordonnes de l'origine 
         set private(originCoordGuide) $private(originCoord)
         #--- je change la taille de d'analyse de la cible
         set private(targetBoxSize) $::conf(sophie,guidingWindowSize)
         #--- je mets le thread de la camera en mode centrage
         ::camera::setAsynchroneParameter $private(camItem) \
            "mode" "GUIDE" \
            "findFiber" $private(findFiber)
         #--- je change le binning et je cree une fenetre centree sur la consigne
         setBinningAndWindow $::conf(sophie,guideBinning) $::conf(sophie,guidingWindowSize) $private(originCoord)
         #--- je change le zoom
         set private(pendingZoom) 4
      }
   }

   #--- je mets a jour la fenetre de controle
   ::sophie::control::setMode $private(mode)
}

##------------------------------------------------------------
# setGuidingMode
#    change la position de la consigne en fonction de la variable ::conf(sophie,guidingMode)
#    met à jour l'affichage de la fentre de controle
#    et met à jour le thread de la camera si l'acquisition est en cours
# @param  ::sophie::private(originCoord)
#------------------------------------------------------------
proc ::sophie::setGuidingMode { visuNo } {
   variable private

   set frm $private(frm)
   switch $::conf(sophie,guidingMode) {
      "FIBER_HR" {
         set private(originCoord)  [list $::conf(sophie,fiberHRX) $::conf(sophie,fiberHRY)]
         if { $private(mode) == "GUIDE" } {
            #--- j'affiche le choix de la detection de la fibre
            $frm.mode.findFiber configure -state normal
         } else {
            $private(frm).mode.findFiber  configure -state disabled
            set private(findFiber) 0
         }
         #--- je positionne la consigne sur la fibre
         ::sophie::createOrigin $visuNo
      }
      "FIBER_HE" {
         set private(originCoord)  [list $::conf(sophie,fiberHEX) $::conf(sophie,fiberHEY)]
         if { $private(mode) == "GUIDE" } {
            #--- j'affiche le choix de la detection de la fibre
            $frm.mode.findFiber configure -state normal
         } else {
            $private(frm).mode.findFiber  configure -state disabled
            set private(findFiber) 0
         }
         #--- je positionne la consigne sur la fibre
         ::sophie::createOrigin $visuNo
      }
      "OBJECT" {
         set private(originCoord) $::conf(sophie,objectCoord)
         #--- je desactive la detection de la fibre
         set private(findFiber) 0
         #--- j'affiche le choix de la detection de la fibre
         $frm.mode.findFiber configure -state disabled
         #--- je positionne la consigne sur l'objet
         ::sophie::createOrigin $visuNo
      }
   }
   #--- je mets a jour la fenetre de controle
   ::sophie::control::setOriginCoords [lindex $private(originCoord) 0] [lindex $private(originCoord) 1]
   ::sophie::control::setGuidingMode $::conf(sophie,guidingMode)

   #--- je change les paramètres dans le thread de la camera
   if { $private(acquisitionState) != 0 } {
      set xOriginCoord [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
      set yOriginCoord [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
      set private(AsynchroneParameter) 1
      ::camera::setAsynchroneParameter $private(camItem) \
            "guidingMode" $::conf(sophie,guidingMode) \
            "originCoord" [list $xOriginCoord $yOriginCoord] \
            "findFiber" $private(findFiber)
   }
}

##------------------------------------------------------------
# setFiberDetection
#   active/desactive la destection automatique de la fibre
#    place la consigne au bon endroit
#------------------------------------------------------------
proc ::sophie::setFiberDetection { findFiber  } {
   variable private

   ###setGuidingMode $private(visuNo)
   set private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter $private(camItem) \
      "findFiber" $private(findFiber)
}

#------------------------------------------------------------
#------------------------------------------------------------
# Gestion des attenuateurs
#------------------------------------------------------------
#------------------------------------------------------------

##------------------------------------------------------------
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

##------------------------------------------------------------
# startMoveFilter
#  démarre le changement d'attenuation
#  Ne fait rien si le telescope n'est pas connecté
# @param  direction "-" =diminution de l'attenuation , "+" =augmentation de l'atténuation
#
#------------------------------------------------------------
proc ::sophie::startMoveFilter { direction } {
   variable private

   if {  $::audace(telNo) != 0  } {
      if { [tel$::audace(telNo) name] == "T193" } {
         set private(filterMaxDelay)       [ tel$::audace(telNo) filter max ]
         set private(filterDirection)      $direction
         #--- je demarre le deplacement
         tel$::audace(telNo) filter move $direction
         set private(updateFilterState) 1
         after 0 ::sophie::updateFilterPercent
      }
   }
}

##------------------------------------------------------------
# stopMoveFilter
#  Arrete le changement d'attenuation
#  affiche la fin de cours "min" en vert quand la fin de course est atteinte
#  affiche la fin de cours "max" en rouge quand la fin de course est atteinte
#------------------------------------------------------------
proc ::sophie::stopMoveFilter { } {
   variable private

   if {  $::audace(telNo) != 0  } {
      if { [tel$::audace(telNo) name] == "T193" } {
         tel$::audace(telNo) filter stop
         #--- je recupere la position et je rafraichis l'affichage
         set private(attenuateur) [ tel$::audace(telNo) filter coord ]
         #--- je recupere l'etat de butees
         set extremity [ tel$::audace(telNo) filter extremity ]

         #--- j'arrete le rafraichissement de l'affichage du taux d'atténuation
         set private(updateFilterState) 0
         if { $private(updateFilterId)!="" } {
            after cancel $private(updateFilterId)
            set private(updateFilterId) ""
         }

         #--- je recupere la nouvelle valeur
         set private(attenuateur) [ tel$::audace(telNo) filter coord ]

         #--- je mets a jour la couleur des fin de course
         switch $extremity {
            "MAX" {
               set private(attenuateur) 10.0
               $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
               $private(frm).attenuateur.labMax_color_invariant configure -background $::color(red)
            }
            "MIN" {
               set private(attenuateur) 0
               $private(frm).attenuateur.labMin_color_invariant configure -background $::color(green)
               $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
            }
            default  {
               $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
               $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
            }
         }
      }
   }
}

##------------------------------------------------------------
# updateFilterPercent
#  met a jour l'affichage du taux d'attenuation en faisant une estmation a partir de la duree du mouvement
#
#
#------------------------------------------------------------
proc ::sophie::updateFilterPercent { } {
   variable private

   #--- j'arrete le timer s'il est en cours
   if { $private(updateFilterId)!="" } {
      after cancel $private(updateFilterId)
      set private(updateFilterId) ""
   }

   if { $private(updateFilterState) == 1 } {
      #--- je recupere la position courante du filtre attenuateur
      set private(attenuateur) [ tel$::audace(telNo) filter coord ]

      #--- je recupere l'etat des extremites
      set extremity [ tel$::audace(telNo) filter extremity ]
      #--- je mets a jour la couleur des fin de course
      switch $extremity {
         "MAX" {
            $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
            $private(frm).attenuateur.labMax_color_invariant configure -background $::color(red)
         }
         "MIN" {
            $private(frm).attenuateur.labMin_color_invariant configure -background $::color(green)
            $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
         }
         default  {
            $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
            $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
         }
      }
      #--- je lance la boucle d'affichage pendant le mouvement
      set private(updateFilterId) [after 250 ::sophie::updateFilterPercent]
   }
}

##------------------------------------------------------------
# initFilter
#  demarrage un mouvement "-" de l'attenuateur pour initialiser
#  la position des attenuateurs sur l'extremitee MIN
#  la duree de recherche est limitee à 1.5 * private(filterMaxDelay)
# @return rien
#------------------------------------------------------------
proc ::sophie::initFilter {  } {
   variable private

   #--- je demarre la boucle de detection de la butee min
   if { [ ::tel::list ] != "" && [ tel$::audace(telNo) name ] == "T193" } {
      set private(filterMaxDelay)       [ tel$::audace(telNo) filter max ]
      set private(filterCurrentPercent) [ tel$::audace(telNo) filter coord ]
      set private(filterDirection)      "-"
      #--- j'active les boutons de commande du filtre attenuateur pendant las
      $private(frm).attenuateur.butMin configure -state disabled
      $private(frm).attenuateur.butMax configure -state disabled
      bind $private(frm).attenuateur.butMin <ButtonPress-1>   ""
      bind $private(frm).attenuateur.butMin <ButtonRelease-1> ""
      bind $private(frm).attenuateur.butMax <ButtonPress-1>   ""
      bind $private(frm).attenuateur.butMax <ButtonRelease-1> ""
      #--- je demarre le deplacement
      tel$::audace(telNo) filter move $private(filterDirection)
      set private(initFilterDuration) [expr $private(filterMaxDelay) * 1.5 ]
      after 0 ::sophie::initFilterLoop
   }
}

##------------------------------------------------------------
# initFilterLoop
#  continue le mouvement "-" de l'attenuateur jusqu'à ce que
#  l' extremite MIN soit atteinte
# @return rien
#------------------------------------------------------------
proc ::sophie::initFilterLoop {  } {
   variable private

   #--- j'arrete le timer s'il est en cours
   if { $private(updateFilterId) != "" } {
      after cancel $private(updateFilterId)
      set private(updateFilterId) ""
   }

   #--- je verifie que le telescope est toujours connecte
   if { [ ::tel::list ] == "" } {
      return
   }

   #--- je mets a jour l'affichage avec une estimation de taux d'attenuation
   if { $private(initFilterDuration) >= 0 } {
      set private(attenuateur) "init..."

      #--- je mets a jour la couleur des fin de course
      set extremity [ tel$::audace(telNo) filter extremity ]
      if { $extremity == "MIN"  } {
         #--- l'extremitee MIN est atteinte
         set private(attenuateur) [ tel$::audace(telNo) filter coord ]
         #--- j'arrete le mouvement
         tel$::audace(telNo) filter stop

         #--- j'active les boutons de commande du filtre attenuateur
         $private(frm).attenuateur.labMin_color_invariant configure -background $::color(green)
         $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
         $private(frm).attenuateur.butMin configure -state normal
         $private(frm).attenuateur.butMax configure -state normal
         bind $private(frm).attenuateur.butMin <ButtonPress-1>   "::sophie::startMoveFilter -"
         bind $private(frm).attenuateur.butMin <ButtonRelease-1> "::sophie::stopMoveFilter"
         bind $private(frm).attenuateur.butMax <ButtonPress-1>   "::sophie::startMoveFilter +"
         bind $private(frm).attenuateur.butMax <ButtonRelease-1> "::sophie::stopMoveFilter"
      } else {
         #--- l'extremite MIN n'est pas atteinte
         $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
         $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
         #--- je continue le mouvement pendant 0.250 seconde
         set private(initFilterDuration) [expr $private(initFilterDuration)  - 0.250 ]
         set private(updateFilterId) [after 250 ::sophie::initFilterLoop]
      }
   } else {
      #--- la duree max de recherche est depassee sans avoir trouve l'extremite MIN
      set private(attenuateur) "?"
      #--- j'arrete le mouvement
      tel$::audace(telNo) filter stop
      #--- j'active les boutons de commande
      $private(frm).attenuateur.labMin_color_invariant configure -background $::audace(color,backColor)
      $private(frm).attenuateur.labMax_color_invariant configure -background $::audace(color,backColor)
      $private(frm).attenuateur.butMin configure -state normal
      $private(frm).attenuateur.butMax configure -state normal
      bind $private(frm).attenuateur.butMin <ButtonPress-1>   "::sophie::startMoveFilter -"
      bind $private(frm).attenuateur.butMin <ButtonRelease-1> "::sophie::stopMoveFilter"
      bind $private(frm).attenuateur.butMax <ButtonPress-1>   "::sophie::startMoveFilter +"
      bind $private(frm).attenuateur.butMax <ButtonRelease-1> "::sophie::stopMoveFilter"
   }
}

##------------------------------------------------------------
# loadBias
#  charge le bias dans le buffer biasBufNo
#  met a jour l'affichage de la fenetre de controle
#
# @param biasWindow  fenetrage du bias (full ou [list x1 y1 x2 y2]
#------------------------------------------------------------
proc ::sophie::loadBias { biasWindow } {
   variable private

   #--- je recupere le mode de la camera
   set product [::confCam::getPluginProperty $private(camItem) product]
   if { $product == "fingerlakes" } {
      switch [::fingerlakes::getReadSpeed ] {
         "1.0 MHz" { set cameraMode slow }
         "3.5 Mhz" { set cameraMode fast }
         default   { set cameraMode fast }
      }
   } else {
      set cameraMode fast
   }

   #--- je recupere le nom du fichier Bias en fonction du binning et du mode d'acquisition
   if { $private(xBinning) == 1 || $private(xBinning) == 2 || $private(xBinning) == 3 } {
      ###set biasFileName $::conf(sophie,biasFileName,$private(xBinning),$cameraMode)
      set private(biasValue) $::conf(sophie,biasFileName,$private(xBinning),$cameraMode)
   } else {
      ###set biasFileName ""
      set private(biasValue) 0
   }

   #--- je charge bias
   set catchError [ catch {
      ###if { $biasFileName != "" } {
      ###   #--- je charge le fichier dans le buffer
      ###   if { $biasFileName != $private(biasFileName) || $private(biasWindow) != $biasWindow } {
      ###      buf$private(biasBufNo) load $biasFileName
      ###      set private(biasFileName) $biasFileName
      ###      set private(biasWindow) ""
      ###      ###console::disp "loadBias $private(biasFileName) private(biasWindow)=$private(biasWindow) biasWindow=$biasWindow\n"
      ###   }
      ###   #--- j'applique le fenetrage si nessaire
      ###   if { $biasWindow != "full" && $private(biasWindow) != $biasWindow } {
      ###      buf$private(biasBufNo) window $biasWindow
      ###      set private(biasWindow) $biasWindow
      ###      ###console::disp "loadBias subwindow $biasWindow \n"
      ###   }
      ###   set biasState "OK"
      ###   set biasMessage $private(biasFileName)
      ###} else {
      ###   #--- il n'y a pas de Bias
      ###   buf$private(biasBufNo) clear
      ###   set biasState "NONE"
      ###   set biasMessage ""
      ###}
   }]

   if { $catchError != 0 } {
      #--- je vide le buffer
      buf$private(biasBufNo) clear
      set biasState "ERROR"
      set biasMessage $::errorInfo
   }

   #--- je mets a jour l'affichage de la fenetre de controle
   ###::sophie::control::setBias $biasState $biasMessage
   ::sophie::control::setBias "OK" "$private(biasValue) (Binning=$private(xBinning) Mode=$cameraMode)"

}

##------------------------------------------------------------
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
      set private(zoom) "8"
   } elseif { $private(zoom) == "8" } {
      set private(zoom) "8"
   }
   ::confVisu::setZoom $::audace(visuNo) $private(zoom)
   set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
}

##------------------------------------------------------------
# incrementZoom
#    incremente les valeurs du zoom
#------------------------------------------------------------
proc ::sophie::incrementZoom { } {
   variable private

   if { $private(zoom) == "8" } {
      set private(zoom) "4"
   } elseif { $private(zoom) == "4" } {
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

##------------------------------------------------------------
# saveImage
#  enregistre l'image courante
#     nom du fichier :  "prefixe-date.fit"
#
#  avec  prefixe = "centrage" ou "guidage"  suivant le mode courant
#        date    = date courante au format ISO8601  , exemple: 2009-05-13T18:51:30.250
#  Mots cles enregistre dans le fichier :
#   - BIN1     binning horizontal
#   - BIN2     binning vertical
#   - DATE-OBS  date de debut de pose
#   - DATE-END  date de fin de pose
#   - EXPOSURE  temps de pose
#   - NAXIS1   largeur de l'image en pixel
#   - NAXIS2   hauteur de l'image en pixel
#   -
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
      if { $private(mode) == "GUIDE" } {
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
      #--- je sauvegarde une image avec une trace dans le fichier de log
      saveima $fileName $::audace(visuNo)
      set heure $::audace(tu,format,hmsint)
      ::sophie::log::writeLogFile $::audace(visuNo) log $::caption(sophie,enrim) $heure $fileName
   } ]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }

}

##------------------------------------------------------------
# showImage
#    affiche une nouvelle visu pour afficher les images enregistrees
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

#####------------------------------------------------------------
#### onOriginCoord
####    initialise la position de la consigne avec la souris
####
#### @param visuNo numero de la visu courante
#### @param x      abcisse de la souris (referentiel ecran)
#### @param y      ordonnee de la souris (referentiel ecran)
#### @return  null
####------------------------------------------------------------
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

##------------------------------------------------------------
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
   set x [ expr ( double([lindex $private(originCoord) 0]) - $private(xWindow) + 1 ) / $private(xBinning)  ]
   set y [ expr ( double([lindex $private(originCoord) 1]) - $private(yWindow) + 1 ) / $private(yBinning)  ]

    ###switch $::conf(sophie,guidingMode) {
    ###   "OBJECT" {
    ###      set activewidth 4
    ###   }
    ###   default {
    ###      set activewidth 2
    ###   }
    ###}
   set activewidth 4

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
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tags "::sophie origin" -activewidth $activewidth -width 2

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
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tags "::sophie origin" -activewidth $activewidth -width 2

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
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tags "::sophie origin" -activewidth $activewidth -width 2

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
   $private(hCanvas) create line $x1 $y1 $x2 $y2 -fill red -tags "::sophie origin" -activewidth $activewidth -width 2
}

##------------------------------------------------------------
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

###------------------------------------------------------------
## moveOrigin
## deplace l'affichage de la consigne
##
## @param visuNo         numero de la visu courante
## @param originCoord    coordonnees de la consigne (referentiel Image)
## @return  null
##------------------------------------------------------------
#proc ::sophie::moveOrigin { visuNo originCoord } {
#   variable private
#
#   #--- je calcule les coordonnees dans le buffer
#   set x  [lindex $originCoord 0]
#   set y  [lindex $originCoord 1]
#   set x1 [expr $x - $::conf(sophie,originBoxSize)]
#   set x2 [expr $x + $::conf(sophie,originBoxSize)]
#   set y1 [expr $y - $::conf(sophie,originBoxSize)]
#   set y2 [expr $y + $::conf(sophie,originBoxSize)]
#
#   #--- je calcule les coordonnees dans le canvas
#   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
#   set xCan1 [lindex $coord 0]
#   set yCan1 [lindex $coord 1]
#   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
#   set xCan2 [lindex $coord 0]
#   set yCan2 [lindex $coord 1]
#
#   #--- je deplace la cible aux nouvelles coordonnees
#   $private(hCanvas) coords "origin" [list $xCan1 $yCan1 $xCan2 $yCan2]
#}

##------------------------------------------------------------
# onMousePressButton1
#   clique sur l'origine avec la souris
#
# @param visuNo  numero de la visu courante
# @param w       handle du canvas
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::sophie::onMousePressButton1 { visuNo w x y } {
   variable private

   #--- je verifie qu'une image est presente dans le buffer
   if { [buf$private(bufNo) imageready] == 0 } {
      return
   }

   set tags [$w itemcget current -tags]
   #--- je recupere le type de l'item (deuxieme tag)
   set typeItem [lindex $tags 1]

   #--- je vérifie que le guidage est sur OBJECT
   #---- (il ne faut pas pouvoir déplacer la consigne si on est en mode FIBER)
   ###if { $typeItem == "origin" && $::conf(sophie,guidingMode) != "OBJECT" } {
   ###   return
   ###}

   switch $typeItem  {
      "origin" {
         #--- je desactive le positionnement automatique de la consigne par le thread de la camera
         set private(originMove) "MANUAL"
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set private(currentx)       $x
         set private(currenty)       $y
         ###set private(currentMouseItem) [$w find withtag current]
         set private(currentMouseItem) $typeItem
      }
     "target" {
         #--- je desactive le positionnement automatique de la cible
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set private(currentx)       $x
         set private(currenty)       $y
         ###set private(currentMouseItem) [$w find withtag current]
         set private(currentMouseItem) $typeItem
     }
     "fiberB" {
         #--- je desactive le positionnement automatique de la cible
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set private(currentx)       $x
         set private(currenty)       $y
         ###set private(currentMouseItem) [$w find withtag current]
         set private(currentMouseItem) $typeItem
     }
     "default" {
        set private(currentMouseItem) ""
        #--- j'appique le traitement par defaut
        ::confVisu::onPressButton1 $visuNo $x $y
     }
   }
}

##------------------------------------------------------------
# onMouseMoveButton1
#   deplace le cusrseur la souris
#
# @param visuNo  numero de la visu courante
# @param w       handle du canvas
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::sophie::onMouseMoveButton1 { visuNo w x y } {
   variable private

   switch $private(currentMouseItem) {
      "origin" {
         #--- la consigne est selectionnee
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set dx [expr {$x - $private(currentx)}]
         set dy [expr {$y - $private(currenty)}]
         set private(currentx) $x
         set private(currenty) $y
         $w move "origin" $dx $dy
      }
      "target" {
         #--- la consigne est selectionnee
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set dx [expr {$x - $private(currentx)}]
         set dy [expr {$y - $private(currenty)}]
         set private(currentx) $x
         set private(currenty) $y
         $w move "target" $dx $dy
      }
      "fiberB" {
         #--- la consigne est selectionnee
         set x [$w canvasx $x]
         set y [$w canvasy $y]
         set dx [expr {$x - $private(currentx)}]
         set dy [expr {$y - $private(currenty)}]
         set private(currentx) $x
         set private(currenty) $y
         $w move "fiberB" $dx $dy
      }
      default {
         #--- la consigne n'est pas selectionnee
         ::confVisu::onMotionButton1 $visuNo $x $y
         return
         ###continue
      }
   }
}

##------------------------------------------------------------
# onMouseReleaseButton1
#   deplace le cusrseur la souris
#
# @param visuNo  numero de la visu courante
# @param w       handle du canvas
# @param x       abcisse de la souris (referentiel ecran)
# @param y       ordonnee de la souris (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::sophie::onMouseReleaseButton1 { visuNo w x y } {
   variable private

   switch $private(currentMouseItem) {
      "origin" {
         #--- la consigne est selectionnee

         #--- je recupere les coordonnees de l'origine (coordonnees canvas  du premier tag qui compose l'origine)
         set coord [$w coords "origin" ]
         set vide 4
         #--- je calcule les coordonnees du centre de l'origine dans l'image
         set coord [::confVisu::canvas2Picture $visuNo $coord]
         set coord [list [expr [lindex $coord 0] - $vide ] [expr [lindex $coord 1] - $vide ] ]
         #--- je passe dans le repere binning 1x1 , sans fenetrage
         set x [expr [lindex $coord 0] * $private(xBinning) + $private(xWindow) -1 ]
         set y [expr [lindex $coord 1] * $private(yBinning) + $private(yWindow) -1 ]
         #--- je met a jour la position courante de la consigne
         set private(originCoord) [list $x $y]
         #--- je met a jour la consigne "OBJET" si on est en mode OBJET
         if { $::conf(sophie,guidingMode) == "OBJECT" } {
            set ::conf(sophie,objectCoord) $private(originCoord)
         }

         #--- je mets a jour la fenetre de controle
         ::sophie::control::setOriginCoords [lindex $private(originCoord) 0] [lindex $private(originCoord) 1]
         #--- je mets a jour le thread de la camera
         if { $private(acquisitionState) != 0 } {
            set xOriginCoord [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning)  ]
            set yOriginCoord [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning)  ]
            set private(AsynchroneParameter) 1
            ::camera::setAsynchroneParameter $private(camItem) \
               "originCoord" [list $xOriginCoord $yOriginCoord] \
         }
         #--- je libere le mouvement manuel du widget
         set private(currentMouseItem) ""
         #--- j'active le positionnement automatique de la consigne par le thread de la camera
         set private(originMove) "AUTO"
      }
      "target" {
         #--- la cible est selectionnee

         #--- je recupere les coordonnees de la cible (coordonnees canvas)
         set coord [$w coords "target" ]
         set x [expr ([lindex $coord 2] + [lindex $coord 0]) /2 ]
         set y [expr ([lindex $coord 3] + [lindex $coord 1]) /2 ]

         #--- je calcule les coordonnees de la cible dans l'image
         set coord [::confVisu::canvas2Picture $visuNo [list $x $y]]
         set x [expr [lindex $coord 0] * $private(xBinning) + $private(xWindow) -1 ]
         set y [expr [lindex $coord 1] * $private(yBinning) + $private(yWindow) -1 ]
         set private(targetCoord) [list $x $y]

         #--- je met a jour le thread de la camera
         set private(AsynchroneParameter) 1
         ::camera::setAsynchroneParameter  $private(camItem) "targetCoord" $coord
         #--- je met a jour la fenetre de controle
         ::sophie::control::setTargetCoords $x $y
         set private(currentMouseItem) ""
         #--- j'active le positionnement automatique de la cible
         set private(targetMove) "AUTO"
      }
      "fiberB" {
         #--- la fiber B est selectionnee

         #--- je recupere les coordonnees (coordonnees canvas)
         set coord [$w coords "fiberB" ]
         set x [expr ([lindex $coord 2] + [lindex $coord 0]) /2 ]
         set y [expr ([lindex $coord 3] + [lindex $coord 1]) /2 ]

         #--- je calcule les coordonneesdans l'image
         set coord [::confVisu::canvas2Picture $visuNo [list $x $y]]
         set x [expr [lindex $coord 0] * $private(xBinning) + $private(xWindow) -1 ]
         set y [expr [lindex $coord 1] * $private(yBinning) + $private(yWindow) -1 ]
         set private(fiberBCoord) [list $x $y]
         
         set private(currentMouseItem) ""
      }      
      default {
         #--- la consigne n'est pas selectionnee, j'appelle le traitement par defaut
         ::confVisu::onReleaseButton1 $visuNo $x $y
         return
      }
   }
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
   if { [buf$private(bufNo) imageready] == 0 } {
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

   #--- je transmet les coordonnees au thread de la camera
   set private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter  $private(camItem) "targetCoord" $coord
   #--- je met a jour la fenetre de controle
   ::sophie::control::setTargetCoords $x $y

}

##------------------------------------------------------------
# createTarget
#    affiche la cible autour du point de coordonnees targetCoord
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
   $private(hCanvas) create rect $x1 $y1 $x2 $y2 -outline red -offset center -tags "::sophie target" -activewidth 2
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

##------------------------------------------------------------
# createFiberB
#    affiche le symbole de la fibre 
#
# @param visuNo         numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::createFiberB { visuNo } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   $private(hCanvas) delete "fiberB"
   #--- je calcule les coordonnees dans l'image
   set x [ expr ( [lindex $private(fiberBCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
   set y [ expr ( [lindex $private(fiberBCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]

   set x1 [expr $x - $::conf(sophie,fiberBRadius) /  $private(xBinning) ]
   set x2 [expr $x + $::conf(sophie,fiberBRadius) /  $private(yBinning) ]
   set y1 [expr $y - $::conf(sophie,fiberBRadius) /  $private(xBinning) ]
   set y2 [expr $y + $::conf(sophie,fiberBRadius) /  $private(yBinning) ]

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
   $private(hCanvas) create oval $x1 $y1 $x2 $y2 -outline red -offset center -tags "::sophie fiberB" -width 2 -activewidth 4
}


##------------------------------------------------------------
#  setMountEnabled
#   active ou descative l'envoi des commandes de guidage a la monture.
#
# @param visuNo      numero de la visu courante
# @param state       activation/desactivation de l'envoi des commandes à la monture
#   -  si state = 1 , les commandes sont envoyees
#   -  si state = 0 , les commandes ne sont pas envoyees
#
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

   #--- je notifie l'interperteur de la camera
   set private(AsynchroneParameter) 1
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

      if { $private(mode)== "CENTER" } {
         #--- j'autorise le bouton de centrage
         $private(frm).mode.centrageStart configure -state normal
      } else {
        #--- j'interdis le bouton de centrage
        $private(frm).mode.centrageStart  configure -state disabled
      }

      if { $private(mode)== "GUIDE" } {
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
      #--- je positionne les parametres du mode courant
      setMode $private(mode)

      #--- je positionne la vitesse "guidage" de la monture si l'envoi des rappels est actif
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
      ##cam$private(camNo) shutter opened

      set intervalle 0.0  ; #--- intervalle de temps entre de 2 acquisitions
      set cameraAngle 0.0                       ; #--- angle de la camera
      set alphaSpeed [lindex $guidingSpeed 1 ]
      set deltaSpeed [lindex $guidingSpeed 1 ]

      set private(AsynchroneParameter) 1
      ::camera::setAsynchroneParameter $private(camItem) \
         "guidingMode"              $::conf(sophie,guidingMode) \
         "targetDetectionThresold"  $::conf(sophie,targetDetectionThresold) \
         "pixelScale"               $::conf(sophie,pixelScale) \
         "targetDec"                [ mc_angle2deg $::audace(telescope,getdec) 90 ] \
         "alphaProportionalGain"    $::conf(sophie,alphaProportionalGain) \
         "deltaProportionalGain"    $::conf(sophie,deltaProportionalGain) \
         "alphaIntegralGain"        $::conf(sophie,alphaIntegralGain) \
         "deltaIntegralGain"        $::conf(sophie,deltaIntegralGain) \
         "binning"                  [list $private(xBinning) $private(yBinning)] \
         "shutter"                  "opened" \
         "maskBufNo"                $private(maskBufNo)     \
         "sumBufNo"                 $private(sumBufNo)      \
         "fiberBufNo"               $private(fiberBufNo)    \
         "biasBufNo"                $private(biasBufNo)     \
         "biasValue"                $private(biasValue)     \
         "maskRadius"               [expr $::conf(sophie,maskRadius) / $private(xBinning)] \
         "maskFwhm"                 [expr $::conf(sophie,maskFwhm) / $private(xBinning)] \
         "maskPercent"              $::conf(sophie,maskPercent) \
         "originSumMinCounter"      $::conf(sophie,originSumMinCounter) \
         "originSumCounter"         0 \
         "pixelMinCount"            $::conf(sophie,pixelMinCount) \
         "centerMaxLimit"           $::conf(sophie,centerMaxLimit) \
         "findFiber"                $private(findFiber)

      #--- je calcule les coordonnees dans l'image
      set originX [ expr ( [lindex $private(originCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
      set originY [ expr ( [lindex $private(originCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]
      set targetX [ expr ( [lindex $private(targetCoord) 0] - $private(xWindow) + 1 ) / $private(xBinning) ]
      set targetY [ expr ( [lindex $private(targetCoord) 1] - $private(yWindow) + 1 ) / $private(yBinning) ]
      set targetBoxSize [ expr int( $private(targetBoxSize) / (2.0 * $private(xBinning) )) ]

      #--- je fais l'acquisition
      ::camera::guideSophie $private(camItem) "::sophie::callbackAcquisition $visuNo" \
         $::conf(sophie,exposure)           \
         [list $originX $originY]           \
         [list $targetX $targetY]           \
         $cameraAngle                       \
         $targetBoxSize                     \
         $private(mountEnabled)             \
         $alphaSpeed                        \
         $deltaSpeed                        \
         $::conf(sophie,alphaReverse)       \
         $::conf(sophie,deltaReverse)       \
         $intervalle

   } ] ;#--- fin du catch

   #--- je traite les erreur imprevues
   if { $catchError != 0 } {
      #--- J'arrete les acquisitions
      stopAcquisition $visuNo
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,titre)
   }

}

##------------------------------------------------------------
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
      $private(frm).acq.goAcq configure \
         -text $::caption(sophie,goAcq) \
         -command "::sophie::startAcquisition $visuNo"
      #--- je supprime l'association du bouton escape
      bind all <Key-Escape> ""

      #--- je mets a jour l'indicateur d'acquisition
      set private(acquisitionState) 0
      #--- je mets a jour la fenetre de controle
      ::sophie::control::setAcquisitionState  $private(acquisitionState)

      #--- j'arrete le centrage s'il était en cours
      stopCenter
      #--- j'arrete le guidage s'il était en cours
      stopGuide

      #--- l'obturateur de la camera est ferme a la fin de la derniere acquisition pour ne pas la perturber.
      #cam$private(camNo) shutter closed

   }
}

##------------------------------------------------------------
# startCenter lance le centrage.
#  Le centrage est arrete soit manuellement (voir stopCenter),
#  soit automatiquement quand l'ecart entre l'etoile et la consigne
#  est inferieur a valeur choisie dans la fenetre de configuration.
#
# @return  null
#------------------------------------------------------------
proc ::sophie::startCenter { } {
   variable private

   #--- je verifie que les acqusitions sont lancees
   if { $private(acquisitionState) == 0 } {
      ##tk_messageBox -title $::caption(sophie,titre) -icon error -message $::caption(sophie,noAcquisition)
      ##set private(centerEnabled) 0
      ##return
      startAcquisition $::audace(visuNo)
   }

   #--- je configure le telescope avec la vitesse de guidage
   ::telescope::setSpeed 1

   set private(centerEnabled) 1
   #--- j'active le centrage dans le thread de la camera
   set private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter $private(camItem) \
         "centerMaxLimit" $::conf(sophie,centerMaxLimit) \
         "mode" "CENTER" \
         "mountEnabled"   $private(centerEnabled)

   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setCenterState $private(centerEnabled)
}

##------------------------------------------------------------
# stopCenter
#    arrete le centrage.
# @return  null
#------------------------------------------------------------
proc ::sophie::stopCenter { } {
   variable private

   set private(centerEnabled) 0
   #--- j'arrete le centrage dans le thread de la camera

   set private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter $private(camItem) \
         "mountEnabled" 0
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

   #--- je lance l'acquisition continue si elle n'est pas deja lancee
   if { $private(acquisitionState) == 0 } {
      startAcquisition $::audace(visuNo)
   }

   set private(guideEnabled) 1
   #--- je configure le telescope avec la vitesse de guidage
   ::telescope::setSpeed 1

   #--- j'active le guidage dans le thread de la camera
   set private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter $private(camItem) \
         "mode" "GUIDE" \
         "mountEnabled" $private(guideEnabled)

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
   #--- j'arrete le centrage dans le thread de la camera
   ###::telescope::stop ""
   set private(AsynchroneParameter) 1
   ::camera::setAsynchroneParameter $private(camItem) \
         "mountEnabled" 0

   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setGuideState $private(guideEnabled)

}

##------------------------------------------------------------
# callbackAcquisition
# cette procedure est appele par le thread de la camera pednant les acquisitions
# @param visuNo  numero de la visu courante
# @param command commande retournee par le thread de la camera :
#     - autovisu : l'image est prete dans le buffer
#     - error    : le thread de la camera a rencontre une erreur. L'acqusition continue est interrompue
#     - targetCoord : les nouvelles coordonnees de l'etoile detecte dans l'image
#     - acquisitionResult : fin du centrage.
# @param args    liste variable de parametres associes a la commande
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
            if { $private(pendingZoom) != ""  } {
               visu$::audace(visuNo) clear
               ##buf[ visu$::audace(visuNo) buf] clear
               ::confVisu::setZoom $::audace(visuNo) $private(pendingZoom)
               set private(zoom) [ ::confVisu::getZoom $::audace(visuNo) ]
               set private(pendingZoom) ""
            }
            #--- j'affiche l'image
            ::confVisu::autovisu $visuNo

            #--- j'affiche le delay entre 2 poses
            ::sophie::control::setRealDelay [lindex [lindex $args 0] 0]
        }
         "error" {
            console::affiche_erreur "callbackGuide visu=$visuNo command=$command $args\n"
            #--- j'arrete les acquisitions continues en cas d'erreur
            ::sophie::stopAcquisition $visuNo
         }
         "targetCoord" {
            # description des parametres recus
            # args 0 = coordonnees de l'étoile, ou coordonnees du centre de la zone de recherche si l'étoile n'a pas ete trouvee
            # args 1 = dx   (ramené au binning 1x1)
            # args 2 = dy   (ramené au binning 1x1)
            # args 3 = targetDetection
            # args 4 = fiberStatus  (=DETECTED NO_SIGNAL UNCHANGED DISABLED )
            # args 5 = fiberX
            # args 6 = fiberY
            # args 7 = measuredFwhmX
            # args 8 = measuredFwhmY
            # args 9 = background
            # args 10= maxIntensity
            # args 11= diffAlpha        ecart etoile/consigne en alpha (en arcsec)
            # args 12= diffDelta        ecart etoile/consigne en delta (en arcsec)
            # args 13= alphaCorrection  correction alpha du telescope (en arcsec)
            # args 14= deltaCorrection  correction alpha du telescope (en arcsec)
            # args 15= infoMessage

            if { $private(AsynchroneParameter) == 0 } {
               set previousTargetDetection $private(targetDetection)

               #--- je recupere les informations
               set starX                [expr [lindex [lindex $args 0] 0] * $private(xBinning)+ $private(xWindow) -1 ]
               set starY                [expr [lindex [lindex $args 0] 1] * $private(yBinning) + $private(yWindow) -1 ]
               set private(targetCoord) [list $starX $starY]
               set starDx               [lindex $args 1]
               set starDy               [lindex $args 2]
               set private(targetDetection)  [lindex $args 3]
               set fiberStatus          [lindex $args 4]
               set originX              [expr [lindex $args 5] * $private(xBinning) + $private(xWindow) -1 ]
               set originY              [expr [lindex $args 6] * $private(yBinning) + $private(yWindow) -1 ]
               set fwhmX                [expr [lindex $args 7] * $private(xBinning) * $::conf(sophie,pixelScale)]
               set fwhmY                [expr [lindex $args 8] * $private(yBinning) * $::conf(sophie,pixelScale)]
               set background           [lindex $args 9]
               set maxIntensity         [lindex $args 10]
               set alphaDiff            [lindex $args 11]
               set deltaDiff            [lindex $args 12]
               set alphaCorrection      [lindex $args 13]
               set deltaCorrection      [lindex $args 14]
               set infoMessage          [lindex $args 15]
               ###::console::disp "::sophie::callbackAcquisition alphaDiff=$alphaDiff deltaDiff=$deltaDiff \n"

               #--- je modifie la position du carre de la cible
               if { $private(targetMove) == "AUTO" } {
                  ::sophie::moveTarget $visuNo $private(targetCoord)
               }
               if { ($fiberStatus == "DETECTED" && $private(originMove) == "AUTO") || $fiberStatus == "DISABLED" } {
                  #--- je calcule la correction de la nouvelle position de la consigne
                  switch $::conf(sophie,guidingMode)  {
                     "FIBER_HR" {
                        set private(originCoord) [list $originX $originY]
                        #--- je calcule l'écart par rapport à la position de depart
                        set originDx  [expr [lindex $private(originCoord) 0] - [lindex $private(originCoordGuide) 0] ]
                        set originDy  [expr [lindex $private(originCoord) 1] - [lindex $private(originCoordGuide) 1] ]
                     }
                     "FIBER_HE" {
                        set private(originCoord) [list $originX $originY]
                        #--- je calcule l'écart par rapport à la position de depart
                        set originDx  [expr [lindex $private(originCoord) 0] - [lindex $private(originCoordGuide) 0] ]
                        set originDy  [expr [lindex $private(originCoord) 1] - [lindex $private(originCoordGuide) 1] ]
                     }
                     "OBJECT" {
                        #--- l'ecart de la consigne est nul
                        set originDx 0.0
                        set originDy 0.0
                        set originDx  [expr [lindex $private(originCoord) 0] - [lindex $private(originCoordGuide) 0] ]
                        set originDy  [expr [lindex $private(originCoord) 1] - [lindex $private(originCoordGuide) 1] ]                  
                     }
                  }
               } else {
                  #--- l'ecart n'est pas calcule
                  set originDx 0.0
                  set originDy 0.0
               }
               #--- j'affiche le symbole de l'origine
               if { $private(originMove) == "AUTO" } {
                  ::sophie::createOrigin $visuNo
               }
               
               #--- j'affiche le symbole de la fibre B
               ::sophie::createFiberB $visuNo
               
               ##console::disp "callbackAcquisition origin= $private(originCoord) detail=$infoMessage\n"

               #--- j'affiche les informations dans la fenetre de controle
               switch $private(mode) {
                  "CENTER" {
                     ::sophie::control::setCenterInformation $private(targetDetection) $fiberStatus \
                        [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
                        $starX $starY $fwhmX $fwhmY $background $maxIntensity \
                        $starDx $starDy $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection
                  }
                  "FOCUS" {
                     ::sophie::control::setFocusInformation $private(targetDetection) $fiberStatus \
                        [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
                        $starX $starY $fwhmX $fwhmY $alphaDiff $deltaDiff $background $maxIntensity
                  }
                  "GUIDE" {
                     #--- je mets a jour les statistiques pour le PC Sophie
                     ::sophie::spectro::updateStatistics $alphaDiff $deltaDiff
                     #--- je mets a jour la fenetre de controle
                     ::sophie::control::setGuideInformation $private(targetDetection) $fiberStatus \
                        [lindex $private(originCoord) 0] [lindex $private(originCoord) 1] \
                        $starX $starY $alphaDiff $deltaDiff $alphaCorrection $deltaCorrection \
                        $originDx $originDy $background $maxIntensity
                  }
               }
            } else {
               set private(AsynchroneParameter) 0
            }

           #--- variable utilisee par le listener addAcquisitionListener
            set private(newAcquisition)  "1"
         }
         "acquisitionResult" {
            #--- j'affiche les informations dans la fenetre de controle
            switch [lindex [lindex $args 0] 0] {
               "CENTER" {
                  #--- fin du centrage
                  #--- j'arrrete le centrage
                  stopCenter
               }
               "END" {
                  ###cam$private(camNo) shutter closed
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

##------------------------------------------------------------
# getBufNo
#  retourne le numero de buffer
#
# @param bufName  nom du buffer ( biasBufNo maskBufNo sumBufNo fiberBufNo)
# @return numero du buffer
#------------------------------------------------------------
proc ::sophie::getBufNo { bufName } {
   variable private

   return $private($bufName)
}

##------------------------------------------------------------
# addAcquisitionListener
#    ajoute une procedure a appeler pour chaque nouvelle acquisition
#
#  @param visuNo numero de la visu
#  @param cmd  commande TCL a lancer quand la camera associee a la visu change
#------------------------------------------------------------
proc ::sophie::addAcquisitionListener { visuNo cmd } {
   trace add variable ::sophie::private(newAcquisition) write $cmd
}

##------------------------------------------------------------
# removeAcquisitionListener
#    supprime une procedure a appeler pour chaque nouvelle acquisition
#
#  @param visuNo numero de la visu
#  @param cmd : commande TCL a lancer quand la camera associee a la visu change
#------------------------------------------------------------
proc ::sophie::removeAcquisitionListener { visuNo cmd } {
   trace remove variable ::sophie::private(newAcquisition) write $cmd
}

##------------------------------------------------------------
# guideSophie
#    lance une session de guidage
#    Cette procedure transmet la commande de demarrage de la session
#    de guidage au thread de la camera de guidage
# parametres :
# @param camItem   item de la camera
# @param callback  procedure callback pour traiter les messages retournes
# @param originCoord coordonnes de la consigne
# @param targetCoord coordonnes de l'etoile
# @param cameraAngle angle de la camera
# @param targetBoxSize taille de la zone de recherche de l'etoile
# @param mountEnabled  1=envoyer les corrections a la monture. 0=ne pas envoyer les corrections
# @param alphaSpeed    vitesse de correction alpha de la monture en arcsec/seconde de temps
# @param deltaSpeed    vitesse de correction delta de la monture en arcsec/seconde de temps
# @param alphaReverse  1=inverser le sens des correction en alpha. 0=ne pas inverser le sens des corrections
# @param deltaReverse  1=inverser le sens des correction en delta. 0=ne pas inverser le sens des corrections
# @param intervalle    intervalle de temps d'attente entre 2 poses (en seconde)
# @return rien
#------------------------------------------------------------
proc ::camera::guideSophie { camItem callback exptime originCoord targetCoord cameraAngle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse intervalle } {
   variable private

   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ::thread::send -async $camThreadNo [list ::camerathread::guideSophie $exptime $originCoord $targetCoord $cameraAngle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $intervalle ]
}

