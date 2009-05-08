#
# Fichier : sophiecommand.tcl
# Description : Centralise les commandes de l'outil Sophie
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: sophiecommand.tcl,v 1.1 2009-05-08 10:44:49 michelpujol Exp $
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
   global conf

   set frm $private(frm)

   #--- je recupere l'item de la camera
   set private(camItem) [ ::confVisu::getCamItem $visuNo ]
   set private(camNo)   [::confVisu::getCamItem $visuNo]

### a d'autre a faire. Pour l'instant je retourne immediatement et je ne fais rien
return

   #--- j'adapte les boutons de selection de pose et de binning
   if { [::confCam::getPluginProperty $camItem longExposure] == "1" } {
      #--- cameras autre que webcam, ou webcam avec la longue pose
      pack $frm.pose.lab1 -anchor center -side left -padx 5
      pack $frm.pose.combo -anchor center -side left -fill x -expand 1
      pack forget $frm.pose.confwebcam
   } else {
      #--- webcam
      pack forget $frm.pose.lab1
      pack forget $frm.pose.combo
      pack $frm.pose.confwebcam -anchor center -side left -fill x -expand 1
      #--- je met la pose a zero car cette variable est utilisee et doit etre nulle pour les courtes poses
      set ::conf(sophie,exposure) "0"
   }

   if { [::confCam::getPluginProperty $camItem hasBinning] == "0" } {
     grid remove $frm.binning
   } else {
     set list_binning [::confCam::getPluginProperty $camItem binningList]
     $frm.binning.combo configure -values $list_binning -height [ llength $list_binning]
     grid $frm.binning
   }

   #--- je calcule la position de l'orgine si elle est hors de l'image de la camera
   if { [::confCam::isReady $camItem] != 0 } {
      set camNo [::confCam::getCamNo $camItem ]
      set camSize [cam$camNo nbpix]
      if { [lindex $::conf(sophie,originCoord) 0 ] >=  [lindex $camSize 0]
        || [lindex $::conf(sophie,originCoord) 1 ] >=  [lindex $camSize 1] } {
         set ::conf(sophie,originCoord) [list [expr [lindex $camSize 0]/2] [expr [lindex $camSize 1]/2] ]
      }
   }

   #--- si la cible n'est pas deja fixee, je prends les coordonnees de l'origine
   if { [llength $private(targetCoord)] != 2 } {
      set private(targetCoord) $::conf(sophie,originCoord)
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
   global caption

   set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
   if { $result == "1" } {
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(sophie,pb) -type ok \
                -message $caption(sophie,selcam) ]
         if { $choix == "ok" } {
             #--- Ouverture de la fenetre de selection des cameras
             ::confCam::run
             tkwait window $audace(base).confCam
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
   global audace

   ::sophie::control::run [winfo toplevel $private(frm)] $visuNo
   #--- je mets à jour le mode
   ::sophie::control::setMode $private(mode)
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
# setMode
#    change le mode d'acquisition
#      - change les paramètres de l'acquisition continue dans la thread de la camera
#      - met à jour l'affichage de la fenetre de contole
# @param mode       mode d'acquisition
#------------------------------------------------------------
proc ::sophie::setMode { mode } {
   variable private

   set private(mode) $mode

   #--- je mets a jout la thread de la camera
   switch { $mode } {
      "centrage" {
         if { $private(centerEnabled) == 1 }  {
            #--- je mets la thread de la camera en mode centrage
            ### ::camera::setParam $private(camItem) "mode" "center"
         } else {
            #--- je mets la thread de la camera en mode acquisition
            ### ::camera::setParam $private(camItem)  "mode" "acquisition"
         }
      }
      "focalisation" {
         #--- je mets la thread de la camera en mode acquisition
         ### ::camera::setParam $private(camItem)  "mode" "acquisition"
      }
      "guidage" {
         #--- je mets la thread de la camera en mode centrage
         ### ::camera::setParam $private(camItem)  "mode" "guide"
      }
   }

   #--- je mets a jour la fenetre de controle
   ::sophie::control::setMode $mode
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
   global color

   incr private(attenuateur) 1
   if { $private(attenuateur) >= "100" } {
      set private(attenuateur) "100"
      $private(frm).attenuateur.labNoir_color_invariant configure -background $color(red)
   } else {
      $private(frm).attenuateur.labBlanc_color_invariant configure -background $color(white)
   }
}

#------------------------------------------------------------
# incrementAttenuateur
#    incremente les valeurs de l'attenuteur
#------------------------------------------------------------
proc ::sophie::incrementAttenuateur { } {
   variable private
   global color

   incr private(attenuateur) -1
   if { $private(attenuateur) <= "1" } {
      set private(attenuateur) "1"
      $private(frm).attenuateur.labBlanc_color_invariant configure -background $color(red)
   } else {
      $private(frm).attenuateur.labNoir_color_invariant configure -background $color(black)
   }
}

#------------------------------------------------------------
# decrementZoom
#    decremente les valeurs du zoom
#------------------------------------------------------------
proc ::sophie::decrementZoom { } {
   variable private
   global color

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
}

#------------------------------------------------------------
# incrementZoom
#    incremente les valeurs du zoom
#------------------------------------------------------------
proc ::sophie::incrementZoom { } {
   variable private
   global color

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
}

#------------------------------------------------------------
# showImage
#    affiche une visu pour afficher une image
#------------------------------------------------------------
proc ::sophie::showImage { } {
   #--- j'ouvre une visu
   set visuSophie [ ::confVisu::create ]
   #--- je selectionne l'outil Visionneuse bis
   ::confVisu::selectTool $visuSophie ::visio2
   #--- j'affiche le contenu du repertoire
   ::visio2::localTable::fillTable $visuSophie
}

##------------------------------------------------------------
# setOriginCoord
#    initialise la position de la consigne
#
# @param visuNo numero de la visu courante
# @param x      abcisse de la consigne (referentiel ecran)
# @param y      ordonnee de la consigne (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::sophie::setOriginCoord { visuNo x y } {
   variable private

   #--- je convertis en coordonnes du referentiel buffer
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]

   set ::conf(sophie,originCoord) $coord

   #--- je dessine les axes sur la nouvelle origine
   createOrigin $visuNo

   ::camera::setParam $private(camItem) "originCoord" $::conf(sophie,originCoord)
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

   #--- je fixe les coordonnees et le parametre  activewidth" en fonction du mode de consigne
   switch $::conf(sophie,guidingMode) {
      "FIBER" {
         if { $::conf(sophie,fiberGuigindMode) == "HR" } {
            set x $::conf(sophie,xfibreAHR)
            set y $::conf(sophie,yfibreAHR)
         } else {
            set x $::conf(sophie,xfibreAHE)
            set y $::conf(sophie,yfibreAHE)
         }
         set ::conf(sophie,originCoord)  [list $x $y]
         set activewidth 2
      }
      "OBJECT" {
         set x [lindex $::conf(sophie,originCoord) 0]
         set y [lindex $::conf(sophie,originCoord) 1]
         set activewidth 4
      }
   }

   #--- j'efface la consigne
   $private(hCanvas) delete "consigne"

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
# @param originCoord    coordonnees de la consigne (referentiel buffer)
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
# setTargetCoord
#    initialise les coordonnees de la cible
#
# @param visuNo  numero de la visu courante
# @param x       abcisse de la cible (referentiel ecran)
# @param y       ordonnee de la cible (referentiel ecran)
# @return  null
#------------------------------------------------------------
proc ::sophie::setTargetCoord { visuNo x y } {
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

   #--- je calcule les coordonnees dans l'image
   set x  [lindex $private(targetCoord) 0]
   set y  [lindex $private(targetCoord) 1]
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
# @param targetCoord    coordonnees de la cible (referentiel buffer)
# @return  null
#------------------------------------------------------------
proc ::sophie::moveTarget { visuNo targetCoord } {
   variable private

   #--- je calcule les coordonnees dans le buffer
   set x  [lindex $targetCoord 0]
   set y  [lindex $targetCoord 1]
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

   #--- Petits raccourcis bien pratiques
   set camItem [::confVisu::getCamItem $visuNo ]

   #--- je verifie la presence la camera
   if { [::confCam::isReady $camItem] == 0 } {
      ::confCam::run
      return 1
   }

   #--- je transforme le bouton GO en bouton STOP
   $private(frm).acq.goAcq configure -text $::caption(sophie,stopAcq) \
      -command "::sophie::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::sophie::stopAcquisition $visuNo"

   #--- j'initialise les valeurs affichees
   set private(acquisitionState)  1
   #--- je met a jour la fenetre de controle
   ::sophie::control::setAcquisitionState  $private(acquisitionState)

   #--- je potionne la vitesse "guidage" de la monture si l'envoi des rappels est actif
   if { $private(mountEnabled) == 1 } {
      ::telescope::setSpeed 1
   }

   set slitWidth 0
   set slitRatio 0
   ::camera::setParam $private(camItem) "targetDetectionThresold" $::conf(sophie,targetDetectionThresold)

   #--- je fais l'acquisition
   ::camera::guide $camItem "::sophie::callbackAcquisition $visuNo" \
      $::conf(sophie,exposure)     \
      "FIBER"    \
      $::conf(sophie,originCoord)   \
      $private(targetCoord)    \
      $::conf(sophie,angle)        \
      $::conf(sophie,targetBoxSize) \
      $private(mountEnabled)   \
      $::conf(sophie,alphaSpeed)   \
      $::conf(sophie,deltaSpeed)   \
      $::conf(sophie,alphaReverse) \
      $::conf(sophie,deltaReverse) \
      $::conf(sophie,seuilx)       \
      $::conf(sophie,seuily)       \
      $slitWidth    \
      $slitRatio    \
      $::conf(sophie,intervalle)   \
      $::conf(sophie,declinaisonEnabled)
}


#------------------------------------------------------------
# stopAcquisition
#    Demande l'arret des acquisitions . L'arret sera effectif apres la fin
#    de l'acquisition en cours
#------------------------------------------------------------
proc ::sophie::stopAcquisition { visuNo } {
   variable private
   global caption

   if { $private(acquisitionState) == 1 } {
      set camItem [ ::confVisu::getCamItem $visuNo ]
      #--- je demande l'arret des acquisitions
      if { $camItem != "" } {
         ::camera::stopAcquisition $camItem
      }
      #--- je transforme le bouton STOP en bouton GO
      $private(frm).acq.goAcq configure -text $::caption(sophie,goAcq) \
         -command "::sophie::startAcquisition $visuNo"

      #--- je supprime l'association du bouton escape
      bind all <Key-Escape> ""
      #--- j'efface le fichier de cumul
      ###file delete -force [file join $::audace(rep_images) $private($visuNo,cumulFileName)]]
      #--- je met a jour l'indicateur d'acquisition
      set private(acquisitionState) 0
      #--- je met a jour la fenetre de controle
      ::sophie::control::setAcquisitionState  $private(acquisitionState)
   }
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
      console::disp "callbackAcquisition visu=$visuNo command=$command args=$args\n"
      switch $command  {
         "autovisu" {
            #--- j'affiche l'image
            ::confVisu::autovisu $visuNo
            #--- j'affiche le symbole de l'origine si ce n'est pas deja fait
            if {  [$private(hCanvas) gettags "origin" ] == "" } {
               createOrigin $visuNo
            }
        }
         "error" {
            ###console::disp "callbackGuide visu=$visuNo command=$command $args\n"
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
            # args 5 = fwhmX, fwhmY, backgroundX, backgroundY, intensityX, intensityY, flow

            #--- je recupere les informations
            set private(targetCoord) [lindex $args 0]
            set starDx           [lindex $args 1]
            set starDy           [lindex $args 2]
            set targetDetection  [lindex $args 3]
            set originDetection  [lindex $args 4]
            set params           [lindex $args 5]

            set originX [lindex $::conf(sophie,originCoord) 0]
            set originY [lindex $::conf(sophie,originCoord) 1]
            set starX [lindex $private(targetCoord) 0]
            set starY [lindex $private(targetCoord) 1]
            set fwhmX         [lindex $params 0]
            set fwhmY         [lindex $params 1]
            set background    [expr ([lindex $params 2] + [lindex $params 3]) /2 ]
            set maxIntensity  [expr ([lindex $params 4] + [lindex $params 5]) /2 ]
            set flow          [lindex $params 6]
            set alphaCorrection  0 ; #  à faire ...
            set deltaCorrection  0 ; #  à faire ...

            #--- je deplace la cible sur les nouvelles corrdonnees
            ::sophie::moveTarget $visuNo $private(targetCoord)

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



