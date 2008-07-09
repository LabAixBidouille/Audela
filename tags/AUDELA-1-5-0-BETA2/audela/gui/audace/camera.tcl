#
# Fichier : camera.tcl
# Description : Utilitaires lies aux cameras CCD
# Auteur : Robert DELMAS
# Mise a jour $Id: camera.tcl,v 1.20 2008-06-23 17:38:50 robertdelmas Exp $
#

namespace eval camera {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) camera.cap ]

   #--- Autorise d'exporter la procedure acq
   namespace export acq
}

#
# init
#
proc ::camera::init { } {
   variable private

   bind . "<<cameraEventA>>" "::camera::processCameraEvent A"
   bind . "<<cameraEventB>>" "::camera::processCameraEvent B"
   bind . "<<cameraEventC>>" "::camera::processCameraEvent C"

   set private(eventList,A) [list]
   set private(eventList,B) [list]
   set private(eventList,C) [list]
}

#
# acq exptime binning
# Declenche l'acquisition et affiche l'image une fois l'acquisition terminee dans la visu 1
#
# Exemple :
# acq 10 2
#
proc ::camera::acq { exptime binning } {
   global audace caption

   #--- Petit raccourci
   set camera cam$audace(camNo)

   #--- La commande exptime permet de fixer le temps de pose de l'image
   $camera exptime $exptime

   #--- La commande bin permet de fixer le binning
   $camera bin [ list $binning $binning ]

   #--- Declenchement l'acquisition
   $camera acq

   #--- Attente de la fin de la pose
   vwait status_$camera

   #--- Visualisation de l'image
   ::audace::autovisu $audace(visuNo)

   wm title $audace(base) "$caption(camera,image_acquisition) $exptime $caption(camera,sec)"
}

#
# ::camera::alarme_sonore exptime
# Alarme sonore de fin de pose
#
proc ::camera::alarme_sonore { { exptime } } {
   global audace conf

   #--- Appel de la sonnerie a $conf(acq,bell)+1 secondes de la fin de pose
   #--- La sonnerie dure 1 seconde
   #--- Sonnerie immediate pour des temps de pose < $conf(acq,bell) et > 1 seconde
   #--- Pas de sonnerie pour des temps de pose inferieurs a 1 seconde
   #--- $conf(acq,bell) < "0" pour ne pas sonner
   if { [ info exists conf(acq,bell) ] == "0" } {
      set conf(acq,bell) "-1"
   }
   if { ( $conf(acq,bell) >= "0" ) && ( $exptime > "1" ) } {
      if { $conf(acq,bell) >= $exptime } {
         set delay "0.1"
      } else {
         set delay [ expr $exptime-$conf(acq,bell)-1 ]
         if { $delay <= "0" } {
            set delay "0.1"
         }
      }
      if { $delay > "0" } {
         set audace(after,bell,id) [ after [ expr int($delay*1000) ] bell ]
      }
   }
}

#
# ::camera::dispLine t Nb_Line_sec Nb_Line_Total scan_Delai
# Decompte du nombre de lignes du scan
#
proc ::camera::dispLine { t Nb_Line_sec Nb_Line_Total scan_Delai } {
   global audace panneau

   set t [ expr $t-1 ]
   set tt [ expr $t*$Nb_Line_sec ]
   if { $panneau(Scan,Stop) == "0" } {
      if { $t > "1" } {
         after 1000 ::camera::dispLine $t $Nb_Line_sec $Nb_Line_Total $scan_Delai
         if { $Nb_Line_Total >= "30" } {
            ::camera::Avancement_scan $tt $Nb_Line_Total $scan_Delai
         }
      }
   } else {
      destroy $audace(base).progress_scan
   }
}

#
# ::camera::Avancement_scan tt Nb_Line_Total scan_Delai
# Affichage de la progression en lignes du scan
#
proc ::camera::Avancement_scan { tt Nb_Line_Total scan_Delai } {
   global audace caption conf

   #--- Recuperation de la position de la fenetre
   ::camera::recup_position_Avancement_Scan

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(avancement_scan,position) ] } { set conf(avancement_scan,position) "+120+315" }

   #---
   if { [ winfo exists $audace(base).progress_scan ] != "1" } {
      #---
      toplevel $audace(base).progress_scan
      wm transient $audace(base).progress_scan $audace(base)
      wm resizable $audace(base).progress_scan 0 0
      wm title $audace(base).progress_scan "$caption(camera,en_cours)"
      wm geometry $audace(base).progress_scan 250x30$conf(avancement_scan,position)

      #--- Cree le widget et le label du temps ecoule
      label $audace(base).progress_scan.lab_status -text "" -font $audace(font,arial_12_b) -justify center
      pack $audace(base).progress_scan.lab_status -side top -fill x -expand true -pady 5
      if { $tt == "-10" } {
         if { $scan_Delai > "1" } {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,secondes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,seconde)"
         }
      } else {
         if { [ expr int($tt) ] >= "2" } {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,lignes) \
               / $Nb_Line_Total $caption(camera,lignes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,ligne) \
               / $Nb_Line_Total $caption(camera,lignes)"
         }
      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).progress_scan
   } else {
      if { $tt == "-10" } {
         if { $scan_Delai > "1" } {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,secondes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "$caption(camera,attente) $scan_Delai \
               $caption(camera,seconde)"
         }
      } else {
         if { [ expr int($tt) ] >= "2" } {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,lignes) \
               / $Nb_Line_Total $caption(camera,lignes)"
         } else {
            $audace(base).progress_scan.lab_status configure -text "[ expr int($tt) ] $caption(camera,ligne) \
               / $Nb_Line_Total $caption(camera,lignes)"
         }
      }
   }
}

#
# ::camera::recup_position_Avancement_Scan
# Recuperation de la position de la fenetre de progression du scan
#
proc ::camera::recup_position_Avancement_Scan { } {
   global audace conf

   if [ winfo exists $audace(base).progress_scan ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).progress_scan ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(avancement_scan,position) "+[ string range $geometry $deb $fin ]"
   }
}

#
# ::camera::dispTime CameraName Label_Time Color_Label Proc_Avancement_pose
# Decompte du temps d'exposition
# Utilisation dans les scripts : acqcolor.tcl + cmaude.tcl + remotectrl.tcl + telshift.tcl
#
proc ::camera::dispTime { CameraName Label_Time { Color_Label "#FF0000" } { Proc_Avancement_pose "" } } {
   global caption

   set t "[ $CameraName timer -1 ]"

   if { $t > "1" } {
      $Label_Time configure -text "[ expr $t-1 ] / [ format "%d" [ expr int([ $CameraName exptime ]) ] ]" \
         -fg $Color_Label
      update
      after 1000 ::camera::dispTime $CameraName $Label_Time $Color_Label $Proc_Avancement_pose
   } else {
      $Label_Time configure -text "$caption(camera,numerisation)" -fg $Color_Label
      update
   }

   if { $Proc_Avancement_pose != "" } {
      $Proc_Avancement_pose $t
   }
}

#
# ::camera::gestionPose Exposure GO_Stop CameraName BufferName
# Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
#
proc ::camera::gestionPose { Exposure GO_Stop { CameraName "" } { BufferName "" } } {
   global audace

   #--- Correspond a un demarrage de la pose
   if { $GO_Stop == "1" } {

      #--- Appel du timer
      if { $Exposure >= "2" } {
         ::camera::dispTime_1 $CameraName "::camera::Avancement_pose"
      }

      #--- Attente de la fin de la pose
      vwait status_$CameraName

      #--- Effacement de la fenetre de progression
      if [ winfo exists $audace(base).progress_pose ] {
         destroy $audace(base).progress_pose
      }

   #--- Correspond a un arret anticipe de la pose
   } elseif { $GO_Stop == "0" } {

      #--- Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      ::camera::Avancement_pose "1"

   }
}

#
# ::camera::dispTime_1 CameraName Proc_Avancement_pose
# Decompte du temps d'exposition
# Utilisation dans les scripts : acqfen.tcl + foc.tcl + snacq.tcl
#
proc ::camera::dispTime_1 { CameraName { Proc_Avancement_pose "" } } {

   set t "[ $CameraName timer -1 ]"

   if { $t > "1" } {
      after 1000 ::camera::dispTime_1 $CameraName $Proc_Avancement_pose
   }

   if { $Proc_Avancement_pose != "" } {
      $Proc_Avancement_pose $t
   }
}

#
# ::camera::Avancement_pose t
# Affichage d'une barre de progression qui simule l'avancement de la pose dans la visu 1
#
proc ::camera::Avancement_pose { { t } } {
   global audace caption color conf

   #--- Recuperation de la position de la fenetre
   ::camera::recup_position_Avancement_Pose

   #--- Initialisation de la barre de progression
   set cpt             "100"
   set dureeExposition [ cam$audace(camNo) exptime ]

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(avancement_pose,position) ] } { set conf(avancement_pose,position) "+120+315" }

   #---
   if { [ winfo exists $audace(base).progress_pose ] != "1" } {
      #---
      toplevel $audace(base).progress_pose
      wm transient $audace(base).progress_pose $audace(base)
      wm resizable $audace(base).progress_pose 0 0
      wm title $audace(base).progress_pose "$caption(camera,en_cours)"
      wm geometry $audace(base).progress_pose $conf(avancement_pose,position)

      #--- Cree le widget et le label du temps ecoule
      label $audace(base).progress_pose.lab_status -text "" -font $audace(font,arial_12_b) -justify center
      pack $audace(base).progress_pose.lab_status -side top -fill x -expand true -pady 5

      #--- t est un nombre entier
      if { $t <= "0" } {
         destroy $audace(base).progress_pose
      } elseif { $t > "1" } {
         $audace(base).progress_pose.lab_status configure -text "[ expr $t-1 ] $caption(camera,sec) / \
            [ format "%d" [ expr int( $dureeExposition ) ] ] $caption(camera,sec)"
         set cpt [ expr ( $t-1 ) * 100 / [ expr int( $dureeExposition ) ] ]
         set cpt [ expr 100 - $cpt ]
      } else {
         $audace(base).progress_pose.lab_status configure -text "$caption(camera,numerisation)"
      }
      #---
      catch {
         #--- Cree le widget pour la barre de progression
         frame $audace(base).progress_pose.cadre -width 200 -height 30 -borderwidth 2 -relief groove
         pack $audace(base).progress_pose.cadre -in $audace(base).progress_pose -side top \
            -anchor center -fill x -expand true -padx 8 -pady 8

         #--- Affiche de la barre de progression
         frame $audace(base).progress_pose.cadre.barre_color_invariant -height 26 -bg $color(blue)
         place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
            -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
         update
      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).progress_pose
   } else {
      #--- t est un nombre entier
      if { $t <= "0" } {
         destroy $audace(base).progress_pose
      } elseif { $t > "1" } {
         $audace(base).progress_pose.lab_status configure -text "[ expr $t-1 ] $caption(camera,sec) / \
            [ format "%d" [ expr int( $dureeExposition ) ] ] $caption(camera,sec)"
         set cpt [ expr ( $t-1 ) * 100 / [ expr int( $dureeExposition ) ] ]
         set cpt [ expr 100 - $cpt ]
      } else {
         $audace(base).progress_pose.lab_status configure -text "$caption(camera,numerisation)"
      }
      catch {
         #--- Affiche de la barre de progression
         place $audace(base).progress_pose.cadre.barre_color_invariant -in $audace(base).progress_pose.cadre \
            -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
         update
      }
   }
}

#
# ::camera::recup_position_Avancement_Pose
# Recuperation de la position de la fenetre de progression de la pose
#
proc ::camera::recup_position_Avancement_Pose { } {
   global audace conf

   if [ winfo exists $audace(base).progress_pose ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).progress_pose ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(avancement_pose,position) "+[ string range $geometry $deb $fin ]"
   }
}

#
# ::camera::dispTime_2 CameraName Label_Time Proc_Avancement_pose
# Decompte du temps d'exposition
# Utilisation dans les scripts : acqfc.tcl
#
proc ::camera::dispTime_2 { CameraName Label_Time { Proc_Avancement_pose "" } { visuNo "" } } {
   global caption

   set t "[ $CameraName timer -1 ]"

   if { $t > "1" } {
      $Label_Time configure -text "[ expr $t-1 ] / [ format "%d" [ expr int([ $CameraName exptime ]) ] ]"
      update
      #--- j'attends une seconde
      if { $Proc_Avancement_pose != "" } {
         $Proc_Avancement_pose $visuNo $t
      }
      #--- je lance l'iteration suivante avec l'option idle
      #--- (mode asynchone pour eviter l'enpilement des appels recursifs)
      after 1000 "::camera::dispTime_2 $CameraName $Label_Time $Proc_Avancement_pose $visuNo"
   } else {
      $Label_Time configure -text "$caption(camera,numerisation)"
      if { $Proc_Avancement_pose != "" } {
         $Proc_Avancement_pose $visuNo $t
      }
      update
   }
}

#------------------------------------------------------------
# addEvent
#
#
# parametres :
#------------------------------------------------------------
proc ::camera::addCameraEvent { camItem args } {
   variable private

   ###console::disp "::camera::addCameraEvent camItem=$camItem args=$args arg0=[lindex $args 0] \n"
   if { [lsearch $private(eventList,$camItem) [list [lindex $args 0] *]] == -1 } {
      lappend private(eventList,$camItem) $args
      event generate . "<<cameraEvent$camItem>>" -when tail
   } else {
      ##console::disp "::camera::addCameraEvent camItem=$camItem  [lindex $args 0] already exist\n"
   }
}

#------------------------------------------------------------
# processCameraEvent
#    traite un evenemet Tk
#
# parametres :
#------------------------------------------------------------
proc ::camera::processCameraEvent { camItem } {
   variable private

   ###console::disp "::camera::processCameraEvent eventList=$private(eventList,$camItem)\n"
   if { [llength $private(eventList,$camItem)] > 0 } {
      set args [lindex $private(eventList,$camItem) 0]
      set private(eventList,$camItem) [lrange $private(eventList,$camItem) 1 end]
      eval $private($camItem,callback) $args
   }
}

#------------------------------------------------------------
# acquisition
#    lance une session d'aquisitions
#
# parametres :
#    visuNo    : numero de la visu courante
#    direction : e w n s
#    delay     : duree du deplacement en milliseconde (nombre entier)
#     originCoord  originCoord $private(angle)
#     autovisu
#     searchResult
#     dx
#     dy
#     targetCoord
#     alphaDelay
#     deltaDelay
#     centerResult
#     stop
# return
#    rien
#------------------------------------------------------------
proc ::camera::acquisition { camItem callback exptime binning } {
   variable private

   #--- je connecte la camera
   ::confCam::setConnection  $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo [::confCam::getThreadNo $camItem ]
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo   [list ::camerathread::acquisition $exptime $binning]]
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::acquisition $exptime $binning]
   }
}

#------------------------------------------------------------
# centerBrightestStar
#   centre sur l'etoile la plus brillante
#
# parametres :
#------------------------------------------------------------
proc ::camera::centerBrightestStar { camItem callback exptime binning originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily } {
   variable private

   #--- je connecte la camera
   ::confCam::setConnection  $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo [::confCam::getThreadNo $camItem ]
   ###console::disp "::camera::centerBrightestStar targetCoord=$targetCoord targetBoxSize=$targetBoxSize\n"
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo           [list ::camerathread::centerBrightestStar $exptime $binning $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily]]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::centerBrightestStar $exptime $binning $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily]
   }
}

#------------------------------------------------------------
# centerRaDec
#   centre les coordonnees
#
# parametres :
#------------------------------------------------------------
proc ::camera::centerRadec { camItem callback exptime binning originCoord raDec angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily foclen detection catalogue kappa threshin fwhm radius threshold maxMagnitude delta epsilon  catalogueName cataloguePath } {
   variable private

   #--- je connecte la camera
   ::confCam::setConnection  $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo [::confCam::getThreadNo $camItem ]
   ###console::disp "::camera::centerRadec raDec=$raDec targetBoxSize=$targetBoxSize\n"
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo           [list ::camerathread::centerRadec $exptime $binning $originCoord $raDec $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $foclen $detection $catalogue $kappa $threshin $fwhm $radius $threshold $maxMagnitude $delta $epsilon $catalogueName $cataloguePath]]
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::centerRadec $exptime $binning $originCoord $raDec $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $foclen $detection $catalogue $kappa $threshin $fwhm $radius $threshold $maxMagnitude $delta $epsilon $catalogueName $cataloguePath]
   }
}

#------------------------------------------------------------
# guide
#    lance une session guidage
#
# parametres :
#    visuNo    : numero de la visu courante
#    direction : e w n s
#    delay     : duree du deplacement en milliseconde (nombre entier)
#     originCoord  originCoord $private(angle)
#     autovisu
#     searchResult
#     dx
#     dy
#     targetCoord
#     alphaDelay
#     deltaDelay
#     centerResult
#     stop
# return
#    rien
#------------------------------------------------------------
proc ::camera::guide { camItem callback exptime binning detection originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily slitWidth slitRatio intervalle } {
   variable private

   #--- je connecte la camera
   ::confCam::setConnection  $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo [::confCam::getThreadNo $camItem ]
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo   [list ::camerathread::guide $exptime $binning $detection $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $slitWidth $slitRatio $intervalle]]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::guide $exptime $binning $detection $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $slitWidth $slitRatio $intervalle]
   }
}

#------------------------------------------------------------
# searchBrightestStar
#    lance une session guidage
#
# parametres :
#------------------------------------------------------------
proc ::camera::searchBrightestStar { camItem callback exptime binning originCoord targetBoxSize searchThreshin searchFwmh searchRadius searchThreshold} {
   variable private

   #--- je connecte la camera
   ::confCam::setConnection  $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo [::confCam::getThreadNo $camItem ]
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo  [list ::camerathread::searchBrightestStar $exptime $binning $originCoord $targetBoxSize $searchThreshin $searchFwmh $searchRadius $searchThreshold]]
   } else {
     ::thread::send -async $camThreadNo [list ::camerathread::searchBrightestStar $exptime $binning $originCoord $targetBoxSize $searchThreshin $searchFwmh $searchRadius $searchThreshold]
   }
}

#------------------------------------------------------------
# setParam
#    modifie un parametre de la camera
#
# parametres :
#    direction : e w n s
# return
#    rien
#------------------------------------------------------------
proc ::camera::setParam { camItem  paramName paramValue } {
   if { $camItem == "" } {
      return
   }
   set camThreadNo [::confCam::getThreadNo $camItem ]
   #--- je notifie la camera
   if { $::tcl_platform(threaded) == 0  } {
      interp eval $camThreadNo  [list ::camerathread::setParam $paramName $paramValue]
     update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::setParam $paramName $paramValue]
   }
}

#------------------------------------------------------------
# setParam
#    modifie un parametre de la camera
#
# parametres :
#    direction : e w n s
# return
#    rien
#------------------------------------------------------------
proc ::camera::stopAcquisition { camItem } {
   set camThreadNo [::confCam::getThreadNo $camItem ]
   if { $::tcl_platform(threaded) == 0  } {
      interp eval $camThreadNo  [list ::camerathread::stopAcquisition ]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::stopAcquisition ]
   }
}

#--- Importe la procedure acq dans le namespace global
namespace import ::camera::acq

::camera::init

