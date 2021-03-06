#
# Fichier : camera.tcl
# Description : Utilitaires lies aux cameras CCD
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id$
#
# Procedures utilisees par confCam
#   ::camera::create : cree une camera
#   ::camera::delete : detruit une camera
#
# Procedures utilisees par les outils et les scripts des utilisateurs
#   ::camera::acquisition
#       fait une acquition
#   ::camera::centerBrightestStar
#       fait des acquisitions jusqu'a ce que l'etoile la plus brillante soit a la position (x,y) donnee en parametre
#   ::camera::centerRadec
#       fait des acquisitions jusqu'a ce que l'etoile de coordonnee (ra,dec) soit a la position (x,y) donnee en parametre
#   ::camera::guide
#       fait des acquisitions et guide le telescope pour garder l'etoile a la position (x,y)
#   ::camera::stopAcquisition :
#       interrompt les acquisitions
#
#   Pendant les acquisitions, les procedures envoient des messages pour
#   informer le programme appelant de l'avancement des acquisitions.
#   Les messages sont transmis en appelant la procedure dont le nom est passe dans le parametre "callback"
#
#   Liste des messages :
#      targetCoord       : position (x,y) de l'etoile
#      mountInfo         : deplacement de la monture a faire
#      autovisu          : l'image est disponible dans le buffer
#      acquisitionResult : resultat final
#      error             : signale une erreur bloquante
#

namespace eval camera {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) camera.cap ]

   #--- Autorise d'exporter la procedure "::camera::acq" sous nom d'alias "acq"
   namespace export acq
}

#------------------------------------------------------------
# init
#------------------------------------------------------------
proc ::camera::init { } {
   variable private

   #--- Initialisation d'une variable
   set variable(dispTimeAfterId) ""

   bind . "<<cameraEventA>>" "::camera::processCameraEvent A"
   bind . "<<cameraEventB>>" "::camera::processCameraEvent B"
   bind . "<<cameraEventC>>" "::camera::processCameraEvent C"

   #--- Je charge le package Thread si l'option multitread est activive dans le TCL
   if { [info exists ::tcl_platform(threaded)] } {
      if { $::tcl_platform(threaded)==1 } {
         #--- Je charge le package Thread
         #--- La version minimale 2.6.5.1 pour disposer de la commande thread::copycommand
         if { ! [catch {package require Thread 2.6.5.1}]} {
            #--- Je redirige les messages d'erreur vers la procedure ::camera::dispThreadError
            thread::errorproc ::camera::dispThreadError
         } else {
            set ::tcl_platform(threaded) 0
            console::affiche_erreur "Thread 2.6.5.1 not present\n"
         }
      }
   } else {
      set ::tcl_platform(threaded) 0
   }
}

#------------------------------------------------------------
# dispThreadError
#------------------------------------------------------------
proc ::camera::dispThreadError { thread_id errorInfo } {
   ::console::disp "thread_id=$thread_id errorInfo=$errorInfo\n"
}

#------------------------------------------------------------
# create
#    cree une camera
#
# parametres :
#    camItem : Item de la camera
# return
#    0 si OK , 1 si erreur
#------------------------------------------------------------
proc ::camera::create { camItem } {
   variable private

   if { $::tcl_platform(threaded) == 0 } {
      #--- cas mono thread
      #--- je recupere le numero de la camera
      set private($camItem,camNo)    [::confCam::getCamNo $camItem]
      #--- je cree un interpreteur pour la camera
      set private($camItem,threadNo) [interp create ]
      #--- je duplique les commandes TCL dans l'interpreteur de la camera
      $private($camItem,threadNo) alias "::console::disp" "::console::disp"
      $private($camItem,threadNo) alias ::camera::addCameraEvent ::camera::addCameraEvent
      $private($camItem,threadNo) alias ::telescope::moveTelescope ::telescope::moveTelescope
      $private($camItem,threadNo) alias ttscript2 ttscript2
      $private($camItem,threadNo) alias mc_date2jd mc_date2jd
      $private($camItem,threadNo) alias mc_date2iso8601 mc_date2iso8601
      #--- je copie la commande de la camera dans la thread de la camera
      copycommand $private($camItem,threadNo) "cam$private($camItem,camNo)"
      #--- je copie la commande du buffer dans la thread de la camera
      copycommand $private($camItem,threadNo) "buf[cam$private($camItem,camNo) buf]"
      #--- J'ajoute la commande de liaison longue pose
      if { [::confCam::getPluginProperty $camItem "hasLongExposure"] == 1 } {
         if { [cam$private($camItem,camNo) longueposelinkno] != 0} {
            copycommand $private($camItem,threadNo) "link[cam$private($camItem,camNo) longueposelinkno]"
         }
      }
      #--- je desactive la recuperation des coordonnees du telescope
      cam$private($camItem,camNo) radecfromtel 0
      #--- j'initialise la file d'evenement  pour la communication entre les deux threads
      set private($camItem,eventList) [list]
      #--- je charge  camerathread.tcl dans l'intepreteur esclave de la camera
      interp eval $private($camItem,threadNo) [list uplevel #0 source \"[file join $::audace(rep_gui) audace camerathread.tcl]\"]
      interp eval $private($camItem,threadNo) ::camerathread::init $camItem $private($camItem,camNo) "0"
   } else {
      #--- cas multi thread
      #--- je recupere le numero de la camera
      set private($camItem,camNo)    [::confCam::getCamNo $camItem]
      #--- je recupere l'indentifiant de la thread de la camera
      set private($camItem,threadNo) [ cam$private($camItem,camNo) threadid]

      #--- je duplique les commandes TCL dans la thread de la camera
      ::thread::copycommand $private($camItem,threadNo) "ttscript2"
      ::thread::copycommand $private($camItem,threadNo) "mc_date2jd"
      ::thread::copycommand $private($camItem,threadNo) "mc_date2iso8601"
      ::thread::copycommand $private($camItem,threadNo) "mc_angle2deg"

      #--- J'ajoute la commande de liaison longue pose dans la thread de la camera
      if { [::confCam::getPluginProperty $camItem "hasLongExposure"] == 1 } {
         if { [cam$private($camItem,camNo)  longueposelinkno] != 0} {
            thread::copycommand $private($camItem,threadNo) "link[cam$private($camItem,camNo) longueposelinkno]"
         }
      }
      #--- je desactive la recuperation des coordonnees du telescope
      cam$private($camItem,camNo) radecfromtel 0

      #--- j'initialise la file d'evenement  pour la communication entre les deux threads
      set private($camItem,eventList) [list]

      #--- je charge camerathread.tcl dans l'intepreteur de la thread de la camera
      ::thread::send $private($camItem,threadNo) [list uplevel #0 source \"[file join $::audace(rep_gui) audace camerathread.tcl]\"]
      ::thread::send $private($camItem,threadNo) "::camerathread::init $camItem $private($camItem,camNo) [thread::id]"
      return 0
   }
}

#------------------------------------------------------------
# delete
#    supprime une camera
#
# parametres :
#    camItem : Item de la camera
# return
#    rien
#------------------------------------------------------------
proc ::camera::delete { camItem } {
   variable private

   if { $::tcl_platform(threaded) == 0 } {
      ###interp eval $private($camItem,threadNo) [list ::cam::delete $private($camItem,camNo) ]
   } else {
      return
   }
}

#------------------------------------------------------------
# loadSource
#    charge un fichier source TCL supplementaire dans l'interpreteur de la thread de la camera
#
# @param  camItem          Item de la camera
# @param  sourceFileName   nom complet du fichier source ( avec le repertoire )
# return resultat du chargement execute dans la thread de la camera
#------------------------------------------------------------
proc ::camera::loadSource { camItem sourceFileName } {
   variable private

   if { $::tcl_platform(threaded) == 0 } {
      interp eval $private($camItem,threadNo) [list uplevel #0 source \"$sourceFileName\"]
   } else {
      ::thread::send $private($camItem,threadNo) [list uplevel #0 source \"$sourceFileName\"]
   }
}

#------------------------------------------------------------
# acq exptime binning
#    Declenche l'acquisition et affiche l'image une fois l'acquisition terminee dans la visu 1
#    (procdure conservee pour compatibilite avec les anciennes versions de Audela (pour les scripts perso des utilisateurs)y
#
# Exemple :
#    acq 10 2
#------------------------------------------------------------
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

   #--- Mise a jour du titre
   ::confVisu::setFileName $audace(visuNo) "$caption(camera,image_acquisition) $exptime $caption(camera,sec)"
}

#------------------------------------------------------------
# alarmeSonore exptime
#    Alarme sonore de fin de pose
#------------------------------------------------------------
proc ::camera::alarmeSonore { { exptime } } {
   global audace conf

   #--- Appel de la sonnerie a $conf(acq,bell) secondes de la fin de pose
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
         set delay [ expr $exptime-$conf(acq,bell) ]
         if { $delay <= "0" } {
            set delay "0.1"
         }
      }
      if { $delay > "0" } {
         set audace(after,bell,id) [ after [ expr int($delay*1000) ] bell ]
      }
   }
}

#------------------------------------------------------------
# dispLine t Nb_Line_sec Nb_Line_Total scan_Delai
#    Decompte du nombre de lignes du scan
#------------------------------------------------------------
proc ::camera::dispLine { t Nb_Line_sec Nb_Line_Total scan_Delai } {
   global audace panneau

   set t [ expr $t-1 ]
   set tt [ expr $t*$Nb_Line_sec ]
   if { $panneau(Scan,Stop) == "0" } {
      if { $t > "1" } {
         after 1000 ::camera::dispLine $t $Nb_Line_sec $Nb_Line_Total $scan_Delai
         if { $Nb_Line_Total >= "30" } {
            ::camera::avancementScan $tt $Nb_Line_Total $scan_Delai
         }
      }
   } else {
      destroy $audace(base).progress_scan
   }
}

#------------------------------------------------------------
# avancementScan tt Nb_Line_Total scan_Delai
#    Affichage de la progression en lignes du scan
#------------------------------------------------------------
proc ::camera::avancementScan { tt Nb_Line_Total scan_Delai } {
   global audace caption conf

   #--- Recuperation de la position de la fenetre
   ::camera::recupPositionAvancementScan

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
      label $audace(base).progress_scan.lab_status -text "" -justify center
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
      if { [ winfo exists $audace(base).progress_scan ] } {
         ::confColor::applyColor $audace(base).progress_scan
      }
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

#------------------------------------------------------------
# recupPositionAvancementScan
#    Recuperation de la position de la fenetre de progression du scan
#------------------------------------------------------------
proc ::camera::recupPositionAvancementScan { } {
   global audace conf

   if [ winfo exists $audace(base).progress_scan ] {
      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).progress_scan ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(avancement_scan,position) "+[ string range $geometry $deb $fin ]"
   }
}

#------------------------------------------------------------
# addEvent
#
## parametres :
#------------------------------------------------------------
proc ::camera::addCameraEvent { camItem args } {
   variable private

   ###console::disp "::camera::addCameraEvent camItem=$camItem args=$args arg0=[lindex $args 0] \n"
   if { [lsearch $private($camItem,eventList) [list [lindex $args 0] *]] == -1 } {
      lappend private($camItem,eventList) $args
      event generate . "<<cameraEvent$camItem>>" -when tail
   } else {
      ###console::disp "::camera::addCameraEvent camItem=$camItem [lindex $args 0] already exist\n"
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

   ###console::disp "::camera::processCameraEvent eventList=$private($camItem,eventList)\n"
   if { [llength $private($camItem,eventList)] > 0 } {
      set args [lindex $private($camItem,eventList) 0]
      set private($camItem,eventList) [lrange $private($camItem,eventList) 1 end]
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
proc ::camera::acquisition { camItem callback exptime } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo [list ::camerathread::acquisition $exptime ]]
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::acquisition $exptime ]
   }
}

#------------------------------------------------------------
# centerBrightestStar
#   centre sur l'etoile la plus brillante
#
# parametres :
#------------------------------------------------------------
proc ::camera::centerBrightestStar { camItem callback exptime originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ###console::disp "::camera::centerBrightestStar targetCoord=$targetCoord targetBoxSize=$targetBoxSize\n"
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo [list ::camerathread::centerBrightestStar $exptime $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily]]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::centerBrightestStar $exptime $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily]
   }
}

#------------------------------------------------------------
# centerRaDec
#    centre les coordonnees
#
# parametres :
#------------------------------------------------------------
proc ::camera::centerRadec { camItem callback exptime originCoord raDec angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily foclen detection catalogue kappa threshin fwhm radius threshold maxMagnitude delta epsilon  catalogueName cataloguePath } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   ###console::disp "::camera::centerRadec raDec=$raDec targetBoxSize=$targetBoxSize\n"
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo [list ::camerathread::centerRadec $exptime $originCoord $raDec $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $foclen $detection $catalogue $kappa $threshin $fwhm $radius $threshold $maxMagnitude $delta $epsilon $catalogueName $cataloguePath]]
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::centerRadec $exptime $originCoord $raDec $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $foclen $detection $catalogue $kappa $threshin $fwhm $radius $threshold $maxMagnitude $delta $epsilon $catalogueName $cataloguePath]
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
proc ::camera::guide { camItem callback exptime detection originCoord targetCoord angle targetBoxSize mountEnabled alphaSpeed deltaSpeed alphaReverse deltaReverse seuilx seuily slitWidth slitRatio intervalle declinaisonEnabled } {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo [list ::camerathread::guide $exptime $detection $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $slitWidth $slitRatio $intervalle $declinaisonEnabled]]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::guide $exptime $detection $originCoord $targetCoord $angle $targetBoxSize $mountEnabled $alphaSpeed $deltaSpeed $alphaReverse $deltaReverse $seuilx $seuily $slitWidth $slitRatio $intervalle $declinaisonEnabled ]
   }
}

#------------------------------------------------------------
# searchBrightestStar
#    lance une session guidage
#
# parametres :
#------------------------------------------------------------
proc ::camera::searchBrightestStar { camItem callback exptime originCoord targetBoxSize searchThreshin searchFwhm searchRadius searchThreshold} {
   variable private

   #--- je connecte la camera
   ###::confCam::setConnection $camItem 1
   #--- je renseigne la procedure de retour
   set private($camItem,callback) $callback
   set camThreadNo $private($camItem,threadNo)
   if { $::tcl_platform(threaded) == 0 } {
      after 10 [list interp eval $camThreadNo [list ::camerathread::searchBrightestStar $exptime $originCoord $targetBoxSize $searchThreshin $searchFwhm $searchRadius $searchThreshold]]
   } else {
     ::thread::send -async $camThreadNo [list ::camerathread::searchBrightestStar $exptime $originCoord $targetBoxSize $searchThreshin $searchFwhm $searchRadius $searchThreshold]
   }
}

#------------------------------------------------------------
# setParam
#    modifie un parametre
#
# @param camItem item de la camera
# @param paramName  nom du prarametre
# @param paramValue valeur du parametre
# @return rien
#------------------------------------------------------------
proc ::camera::setParam { camItem  paramName paramValue } {
   variable private

   if { $camItem == "" } {
      return
   }
   set camThreadNo $private($camItem,threadNo)
   #--- je notifie la camera
   if { $::tcl_platform(threaded) == 0 } {
      interp eval $camThreadNo [list ::camerathread::setParam $paramName $paramValue]
      update
   } else {
      ::thread::send -async -head $camThreadNo [list ::camerathread::setParam $paramName $paramValue]
      ###::thread::send $camThreadNo [list ::camerathread::setParam $paramName $paramValue]
   }
}

#------------------------------------------------------------
# setAsynchroneParameter
#    modifie plusieurs parametres en mode asynchrone
#
# @param camItem item de la camera
# @param args liste de couples (nom parametre, valeur parametre)
# @return rien
#------------------------------------------------------------
proc ::camera::setAsynchroneParameter { camItem  args } {
   variable private

   if { $camItem == "" } {
      return
   }
   set camThreadNo $private($camItem,threadNo)
   #--- je notifie la camera
   if { $::tcl_platform(threaded) == 0  } {
      interp eval $camThreadNo [list ::camerathread::setAsynchroneParameter $args]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::setAsynchroneParameter $args]
      ###::thread::send $camThreadNo [list ::camerathread::setAsynchroneParameter $args]
   }
}

#------------------------------------------------------------
# stopAcquisition
#    arrete une acquisition en cours
#
# parametres :
#    camItem : Item de la camera
# return
#    rien
#------------------------------------------------------------
proc ::camera::stopAcquisition { camItem } {
   variable private

   set camThreadNo $private($camItem,threadNo)
   if { $::tcl_platform(threaded) == 0  } {
      interp eval $camThreadNo [list ::camerathread::stopAcquisition ]
      update
   } else {
      ::thread::send -async $camThreadNo [list ::camerathread::stopAcquisition ]
   }
}

#--- Importe la procedure acq dans le namespace global
###rename cam::create cam::create_old
###rename cam::delete cam::delete_old
###interp alias "" cam::create "" ::camera::create
###interp alias "" cam::delete "" ::camera::delete

###proc ::cam::create { args } {
###   ::thread::send -async $camThreadNo [list ::camerathread::stopAcquisition ]
###}

#--- import de acq dan le namespace principal pour compatibilite avec les anciens scripts
namespace import ::camera::acq

::camera::init

