#
# Fichier : sophiecommand.tcl
# Description : Centralise les commandes de l'outil Sophie
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophiecommand.tcl,v 1.6 2009-05-11 18:00:28 robertdelmas Exp $
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

   #--- je recupere l'item de la camera
   set private(camItem) [ ::confVisu::getCamItem $visuNo ]
   set private(camNo)   [ ::confCam::getCamNo $private(camItem) ]

   if { $private(camNo) != 0 } {
      if { [::confCam::getPluginProperty $private(camItem) hasBinning] == "0" } {
         $frm.acq.labBinning configure -state disabled
         $frm.acq.binning.a configure -state disabled
         $frm.acq.binning.e configure -state disabled
      } else {
         $frm.acq.labBinning configure -state normal
         $frm.acq.binning.a configure -state normal
         $frm.acq.binning.e configure -state normal
         #--- je mets a jour la liste des binning
         set private(listeBinning) [::confCam::getPluginProperty $private(camItem) binningList]
         $frm.acq.binning  configure -values $private(listeBinning) -height [llength $private(listeBinning)]
         if { [lsearch $private(listeBinning) $private(binning)] != -1 } {
            #--- je configure la camera avec le binning courant s'il existe dans la liste
            scan $private(binning) "%dx%d" xBinning  yBinning
            cam$private(camNo) bin [list $xBinning  $yBinning]
         }
      }
   }

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
# showControlWindow
#    ouvre la fenetre de controle
#
# @param visuNo       numero de la visu courante
#------------------------------------------------------------
proc ::sophie::showControlWindow { visuNo } {
   variable private

   ::sophie::control::run [winfo toplevel $private(frm)] $visuNo
   #--- je mets a jour le mode dans la fenetre de controle
   ::sophie::control::setMode $private(mode)
}

#------------------------------------------------------------
# setBinning
#  applique le changement de binning
#     - dans la camera ,
#     - position de la cible
# @param  binning   binning x et y  sous la forme 1x1 , 2x2 ...
# @return rien
#------------------------------------------------------------
proc ::sophie::setBinning { binning } {
   variable private

   #--- je change le binning de la camera
   scan $private(binning) "%dx%d" xBinning  yBinning
   if { $private(camNo) != 0 } {
      cam$private(camNo) bin [list $xBinning  $yBinning]
   }
   #--- je change les paramètres dans la thread
   if { $private(acquisitionState) != 0 } {
      set xOriginCoord [ expr [lindex $private(originCoord) 0] / $xBinning  ]
      set yOriginCoord [ expr [lindex $private(originCoord) 1] / $yBinning  ]
      ::camera::setParam $private(camItem) "originCoord" [list $xOriginCoord $yOriginCoord]

      set xTargetCoord [ expr [lindex $private(targetCoord) 0] / $xBinning  ]
      set yTargetCoord [ expr [lindex $private(targetCoord) 1] / $yBinning  ]
      ::camera::setParam $private(camItem) "targetCoord" [list $xTargetCoord $yTargetCoord]

      set targetBoxSize [ expr $::conf(sophie,targetBoxSize) / $xBinning  ]
      ::camera::setParam $private(camItem) "targetBoxSize" $targetBoxSize
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
   setBinning $private(binning)
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
#  pour lancer ou arret le centrage
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
# setMode
#    change le mode d'acquisition
#      - change les paramètres de l'acquisition continue dans la thread de la camera
#      - met à jour l'affichage de la fenetre de contole
# @param mode       mode d'acquisition
#------------------------------------------------------------
proc ::sophie::setMode { mode } {
   variable private

   #--- je desactive le mode precedent
   $private(frm).mode.centrageStart configure -state disabled
   stopCenter

   #--- je mets a jour la variable
   set private(mode) $mode

   #--- j'applique le nouveau mode
   switch $mode {
      "centrage" {
         $private(frm).mode.centrageStart configure -state normal
         if { $private(centerEnabled) == 1 } {
            #--- je mets la thread de la camera en mode centrage
            ### ::camera::setParam $private(camItem) "mode" "center"
         } else {
            #--- je mets la thread de la camera en mode acquisition
            ### ::camera::setParam $private(camItem)  "mode" "acquisition"
         }
      }
      "focalisation" {
         $private(frm).mode.centrageStart  configure -state disabled
         #--- je mets la thread de la camera en mode acquisition
         ### ::camera::setParam $private(camItem)  "mode" "acquisition"
      }
      "guidage" {
         $private(frm).mode.centrageStart  configure -state disabled
         #--- je mets la thread de la camera en mode centrage
         ### ::camera::setParam $private(camItem)  "mode" "guide"
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

   #--- je mets a jour la fenetre de controle
   ::sophie::control::setGuidingMode $::conf(sophie,guidingMode)

}

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

#------------------------------------------------------------
# decrementAttenuateur
#    decremente les valeurs de l'attenuteur
#------------------------------------------------------------
proc ::sophie::decrementAttenuateur { } {
   variable private

   incr private(attenuateur) 1
   if { $private(attenuateur) >= "100" } {
      set private(attenuateur) "100"
      $private(frm).attenuateur.labNoir_color_invariant configure -background $::color(red)
   } else {
      $private(frm).attenuateur.labBlanc_color_invariant configure -background $::color(white)
   }
}

#------------------------------------------------------------
# incrementAttenuateur
#    incremente les valeurs de l'attenuteur
#------------------------------------------------------------
proc ::sophie::incrementAttenuateur { } {
   variable private

   incr private(attenuateur) -1
   if { $private(attenuateur) <= "1" } {
      set private(attenuateur) "1"
      $private(frm).attenuateur.labBlanc_color_invariant configure -background $::color(red)
   } else {
      $private(frm).attenuateur.labNoir_color_invariant configure -background $::color(black)
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
#    enregistre l'image courante
#------------------------------------------------------------
proc ::sophie::saveImage { } {

   tk_messageBox -title $::caption(sophie,titre) -icon error -message "Cette fonction n'est pas encore implémentée."
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
proc ::sophie::onOriginCoord { visuNo x y } {
   variable private

   #--- je convertis en coordonnes du referentiel Image
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]

   set private(originCoord) $coord

   #--- je dessine les axes sur la nouvelle origine
   createOrigin $visuNo

   ::camera::setParam $private(camItem) "originCoord" $private(originCoord)
}

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

   #--- je prendre en compte le binning de la camera
   scan $private(binning) "%dx%d" xBinning  yBinning

   #--- je calcule les coordonnees dans l'image
   set x  [expr [lindex $private(originCoord) 0]  / $xBinning ]
   set y  [expr [lindex $private(originCoord) 1]  / $yBinning ]

   ###set x [lindex $private(originCoord) 0]
   ###set y [lindex $private(originCoord) 1]

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
   set x1 [expr int($x) - $::conf(sophie,originBoxSize)]
   set x2 [expr int($x) + $::conf(sophie,originBoxSize)]
   set y1 [expr int($y) - $::conf(sophie,originBoxSize)]
   set y2 [expr int($y) + $::conf(sophie,originBoxSize)]

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
   set private(targetCoord) $coord

   #--- je positionne la cible sur les nouvelles coordonnees
   moveTarget $visuNo $private(targetCoord)

   #--- je transmet les coordonnees a l'interperteur de la camera
   ::camera::setParam $private(camItem) "targetCoord" $private(targetCoord)
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

   #--- je prendre en compte le binning de la camera
   scan $private(binning) "%dx%d" xBinning  yBinning

   #--- je calcule les coordonnees dans l'image
   set x  [expr [lindex $private(targetCoord) 0]  / $xBinning ]
   set y  [expr [lindex $private(targetCoord) 1]  / $yBinning ]
   set x1 [expr int($x) - $::conf(sophie,targetBoxSize)]
   set x2 [expr int($x) + $::conf(sophie,targetBoxSize)]
   set y1 [expr int($y) - $::conf(sophie,targetBoxSize)]
   set y2 [expr int($y) + $::conf(sophie,targetBoxSize)]

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

   #--- je prendre en compte le binning de la camera
   scan $private(binning) "%dx%d" xBinning  yBinning

   #--- je calcule les coordonnees dans l'image
   ##set x  [lindex $targetCoord 0]
   ##set y  [lindex $targetCoord 1]
   set x  [expr [lindex $private(targetCoord) 0]  / $xBinning ]
   set y  [expr [lindex $private(targetCoord) 1]  / $yBinning ]
   set x1 [expr int($x) - $::conf(sophie,targetBoxSize)]
   set x2 [expr int($x) + $::conf(sophie,targetBoxSize)]
   set y1 [expr int($y) - $::conf(sophie,targetBoxSize)]
   set y2 [expr int($y) + $::conf(sophie,targetBoxSize)]

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
   ::camera::setParam $private(camItem) "mountEnabled" $private(mountEnabled)
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

   #--- je transforme le bouton GO en bouton STOP
   $private(frm).acq.goAcq configure -text $::caption(sophie,stopAcq) \
      -command "::sophie::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::sophie::stopAcquisition $visuNo"

   #--- j'initialise les valeurs affichees
   set private(acquisitionState)  1
   #--- je mets a jour la fenetre de controle
   ::sophie::control::setAcquisitionState  $private(acquisitionState)

   #--- je potionne la vitesse "guidage" de la monture si l'envoi des rappels est actif
   if { $private(mountEnabled) == 1 } {
      ::telescope::setSpeed 1
   }

   if { $::conf(sophie,simulation) == 1 } {
      ::camera::setParam $private(camItem) "simulation" 1
      ::camera::setParam $private(camItem) "simulationGenericFileName" $::conf(sophie,simulationGenericFileName)
   }

   scan $private(binning) "%dx%d" xBinning  yBinning

   set slitWidth  0.0   ; #--- largeur de la fente
   set slitRatio  0.0   ; #--- ceofficient
   set intervalle 0.0  ; #--- intervalle de temps entre de 2 acquisitions
   set seuilx     50.0  ; #--- seuil minimum de correction sur l'axe x
   set seuily     50.0  ; #--- seuil minimum de correction sur l'axe y
   set cameraAngle 0.0 ; #angle de la camera
   set declinaisonEnabled 1 ; #--- correction en declinaison activee
   set alphaSpeed 1.0
   set deltaSpeed 1.0
   ::camera::setParam $private(camItem) "targetDetectionThresold" $::conf(sophie,targetDetectionThresold)
   ::camera::setParam $private(camItem) "pixelScale"              $::conf(sophie,pixelScale)
   ::camera::setParam $private(camItem) "targetDec"               [ mc_angle2deg $private(targetDec) 90 ]
   ::camera::setParam $private(camItem) "proportionalGain"        $::conf(sophie,proportionalGain)
   ::camera::setParam $private(camItem) "integralGain"            $::conf(sophie,integralGain)

   set xOriginCoord [ expr [lindex $private(originCoord) 0] / $xBinning  ]
   set yOriginCoord [ expr [lindex $private(originCoord) 1] / $yBinning  ]

   set xTargetCoord [ expr [lindex $private(targetCoord) 0] / $xBinning  ]
   set yTargetCoord [ expr [lindex $private(targetCoord) 1] / $yBinning  ]

   set targetBoxSize [ expr $::conf(sophie,targetBoxSize) / $xBinning  ]

   #--- je fais l'acquisition
   ::camera::guide $private(camItem) "::sophie::callbackAcquisition $visuNo" \
      $::conf(sophie,exposure)           \
      "FIBER"                            \
      [list $xOriginCoord $yOriginCoord] \
      [list $xTargetCoord $yTargetCoord] \
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
      #--- j'efface le fichier de cumul
      ###file delete -force [file join $::audace(rep_images) $private($visuNo,cumulFileName)]]

      #--- je mets a jour l'indicateur d'acquisition
      set private(acquisitionState) 0
      #--- je mets a jour la fenetre de controle
      ::sophie::control::setAcquisitionState  $private(acquisitionState)

      #--- j'arrete le centrage s'il était en cours
      stopCenter

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
   ::camera::setParam $private(camItem) "seuilx" "50"
   ::camera::setParam $private(camItem) "seuily" "50"
   ::camera::setParam $private(camItem) "mode" "center"
   ::camera::setParam $private(camItem) "mountEnabled" "1"

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
   ::camera::setParam $private(camItem) "mode" "guide"
   ::camera::setParam $private(camItem) "mountEnabled" "0"

   #--- je mets a jour le voyant dans la fenetre de controle
   ::sophie::control::setCenterState $private(centerEnabled)

}

##------------------------------------------------------------
# callbackAcquisition
# cette boucle est appele par la thread de la camera pednant les acquisitions
# @param visuNo numero de la visu courante
# @return  null
#------------------------------------------------------------
proc ::sophie::callbackAcquisition { visuNo command args } {
   variable private

   set catchError [ catch {
      ###console::disp "callbackAcquisition visu=$visuNo command=$command args=$args\n"
      switch $command  {
         "autovisu" {
            #--- j'affiche l'image
            ::confVisu::autovisu $visuNo
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
            # args 5 = originX, originY, fwhmX, fwhmY, backgroundX, backgroundY, intensityX, intensityY, flow

            scan $private(binning) "%dx%d" xBinning yBinning

            #--- je recupere les informations
            set starX                [expr [lindex [lindex $args 0] 0] * $xBinning ]
            set starY                [expr [lindex [lindex $args 0] 1] * $yBinning ]
            set private(targetCoord) [list $starX $starY]
            set starDx               [lindex $args 1]
            set starDy               [lindex $args 2]
            set targetDetection      [lindex $args 3]
            set originDetection      [lindex $args 4]
            set params               [lindex $args 5]

            set originX              [lindex $params 0]
            set originY              [lindex $params 1]
            set fwhmX                [lindex $params 2]
            set fwhmY                [lindex $params 3]
            set background           [lindex $params 4]
            set maxIntensity         [lindex $params 5]
            set flow                 [lindex $params 6]
            set alphaCorrection      0 ; #  à faire ...
            set deltaCorrection      0 ; #  à faire ...
console::disp "callbackAcquisition targetCoord=$private(targetCoord)\n"
            #--- je deplace la cible sur les nouvelles corrdonnees
            ::sophie::moveTarget $visuNo $private(targetCoord)

            #--- j'affiche le symbole de l'origine
            ::sophie::createOrigin $visuNo

            #--- j'affiche les informations dans la fenetre de controle
            switch $private(mode) {
               "centrage" {
                  ::sophie::control::setCenterInformation $targetDetection $originDetection $originX $originY $starX $starY $fwhmX $fwhmY $background $flow
               }
               "focalisation" {
                  ::sophie::control::setFocusInformation $targetDetection $originDetection $originX $originY $starX $starY $fwhmX $fwhmY $background $flow $maxIntensity
               }
               "guidage" {
                  ::sophie::control::setGuideInformation $targetDetection $originDetection $originX $originY $starX $starY $starDx $starDy $alphaCorrection $deltaCorrection
               }
            }
         }
         "acquisitionResult" {
            #--- j'affiche les informations dans la fenetre de controle
            switch $private(mode) {
               "centrage" {
                  #--- fin du centrage
                  #--- j'affiche les
                  stopCenter

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

