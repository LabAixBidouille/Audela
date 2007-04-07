#
# Fichier : autoguider.tcl
# Description : Outil d'autoguidage
# Auteur : Michel PUJOL
# Mise a jour $Id: autoguider.tcl,v 1.15 2007-04-07 00:38:33 robertdelmas Exp $
#

#==============================================================
#   Declaration du namespace autoguider
#    initialise le namespace
#==============================================================
namespace eval ::autoguider {
   package provide autoguider 1.0

   #--- Je charge le fichier caption pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] autoguider.cap ]
}

#------------------------------------------------------------
# ::autoguider::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::autoguider::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "autoguider" }
      multivisu    { return 1 }
   }
}

#------------------------------------------------------------
# ::autoguider::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#
# return "Titre du plugin"
#------------------------------------------------------------
proc ::autoguider::getPluginTitle { } {
   global caption

   return "$caption(autoguider,menu)"
}

#------------------------------------------------------------
# ::autoguider::getPluginType
#    retourne le type de plugin
#
# return "focuser"
#------------------------------------------------------------
proc ::autoguider::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::autoguider::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::autoguider::createPluginInstance { { in "" } { visuNo 1 } } {
   variable private
   global audace caption conf

   source [ file join $audace(rep_plugin) tool autoguider autoguiderconfig.tcl ]
   set ::caption(autguider,darkError) "echec de la soustration du dark "

   if { ! [ info exists conf(autoguider,pose) ] }                { set conf(autoguider,pose)                 "0" }
   if { ! [ info exists conf(autoguider,binning) ] }             { set conf(autoguider,binning)              [lindex $audace(list_binning) 1] }
   if { ! [ info exists conf(autoguider,intervalle)] }           { set conf(autoguider,intervalle)           ".5" }
   if { ! [ info exists conf(autoguider,alphaSpeed)] }           { set conf(autoguider,alphaSpeed)           "10" }
   if { ! [ info exists conf(autoguider,deltaSpeed)] }           { set conf(autoguider,deltaSpeed)           "10" }
   if { ! [ info exists conf(autoguider,seuilx)] }               { set conf(autoguider,seuilx)               "1" }
   if { ! [ info exists conf(autoguider,seuily)] }               { set conf(autoguider,seuily)               "1" }
   if { ! [ info exists conf(autoguider,detection)] }            { set conf(autoguider,detection)            "PSF" }
   if { ! [ info exists conf(autoguider,learn,delay)] }          { set conf(autoguider,learn,delay)          "5" }
   if { ! [ info exists conf(autoguider,angle)] }                { set conf(autoguider,angle)                "0" }
   if { ! [ info exists conf(autoguider,showAlphaDeltaAxis)] }   { set conf(autoguider,showAlphaDeltaAxis)   "1" }
   if { ! [ info exists conf(autoguider,showImage)] }            { set conf(autoguider,showImage)            "1" }
   if { ! [ info exists conf(autoguider,showTarget)] }           { set conf(autoguider,showTarget)           "1" }
   if { ! [ info exists conf(autoguider,targetBoxSize)] }        { set conf(autoguider,targetBoxSize)        "16" }
   if { ! [ info exists conf(autoguider,configWindowPosition)] } { set conf(autoguider,configWindowPosition) "+0+0" }
   if { ! [ info exists conf(autoguider,declinaisonEnabled)] }   { set conf(autoguider,declinaisonEnabled)   "1" }
   if { ! [ info exists conf(autoguider,cumulEnabled)] }         { set conf(autoguider,cumulEnabled)         "0" }
   if { ! [ info exists conf(autoguider,cumulNb)] }              { set conf(autoguider,cumulNb)              "5" }
   if { ! [ info exists conf(autoguider,darkEnabled)] }          { set conf(autoguider,darkEnabled)          "0" }
   if { ! [ info exists conf(autoguider,darkFileName)] }         { set conf(autoguider,darkFileName)         "dark.fit"  }
   if { ! [ info exists conf(autoguider,slitWidth)] }            { set conf(autoguider,slitWidth)            "4"  }
   if { ! [ info exists conf(autoguider,slitRatio)] }            { set conf(autoguider,slitRatio)            "1.0"  }
   if { ! [ info exists conf(autoguider,lipWidth)] }             { set conf(autoguider,lipWidth)             "4"  }
   if { ! [ info exists conf(autoguider,alphaReverse)] }         { set conf(autoguider,alphaReverse)         "0"  }
   if { ! [ info exists conf(autoguider,deltaReverse)] }         { set conf(autoguider,deltaReverse)         "0"  }

   set private($visuNo,base)              $in
   set private($visuNo,This)              "$in.autoguider"
   set private($visuNo,hCanvas)           [::confVisu::getCanvas $visuNo]
   set private($visuNo,mode)              "image"

   set private($visuNo,monture_ok)        "0"
   set private($visuNo,suiviState)        "0"
   set private($visuNo,dx)                "0.00"
   set private($visuNo,dy)                "0.00"
   set private($visuNo,delay,alpha)       "0.00"
   set private($visuNo,delay,delta)       "0.00"
   set private($visuNo,originCoord)       ""
   set private($visuNo,targetCoord)       ""
   set private($visuNo,interval)          ""
   set private($visuNo,previousClock)     "0"
   set private($visuNo,updateAxis)        "0"

   #--- Petit raccourci bien pratique
   set This $private($visuNo,This)

   #--- Cadre de l'outil
   frame $This -borderwidth 2 -relief groove

   #--- Cadre du titre de l'outil
   frame $This.titre -borderwidth 2 -relief groove
      Button $This.titre.but -borderwidth 1 -text "$caption(autoguider,titre)" \
        -command {
           ::audace::showHelpPlugin tool autoguider autoguider.htm
        }
      pack $This.titre.but -side top -fill x
      DynamicHelp::add $This.titre.but -text "$caption(autoguider,help_titre)"
   pack $This.titre -side top -fill x

   #--- Cadre du temps de pose
   frame $This.pose -borderwidth 2 -relief ridge
      label $This.pose.lab1 -text "$caption(autoguider,pose)"
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.pose.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::conf(autoguider,pose) \
         -values $list_combobox
      button $This.pose.confwebcam -text "$caption(autoguider,pose)" \
         -command "::autoguider::webcamConfigure $visuNo"
   pack $This.pose -side top -fill x

   #--- Cadre du binning
   frame $This.binning -borderwidth 2 -relief ridge
      label $This.binning.lab1 -text "$caption(autoguider,binning)"
      set list_combobox $audace(list_binning)
      ComboBox $This.binning.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -textvariable ::conf(autoguider,binning) \
         -values $list_combobox \
         -modifycmd "::autoguider::selectBinning $visuNo"
      button $This.binning.selectBinning -text "$caption(autoguider,binning)" \
         -command "::autoguider::selectBinning $visuNo"
   pack $This.binning -side top -fill x

   #--- Cadre de l'intervalle
   frame $This.intervalle -borderwidth 2 -relief ridge
      label $This.intervalle.lab1 -text "$caption(autoguider,intervalle)"
      pack $This.intervalle.lab1 -anchor center -side left -padx 5
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.intervalle.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -textvariable conf(autoguider,intervalle) \
         -values $list_combobox
      pack $This.intervalle.combo -anchor center -side left -fill x -expand 1
   pack $This.intervalle -side top -fill x

   #--- Cadre du bouton Go/Stop
   frame $This.go_stop -borderwidth 2 -relief ridge
      button $This.go_stop.but -text "$caption(autoguider,GO)" -height 2 \
        -font $audace(font,arial_12_b) -borderwidth 3 -pady 6 -command "::autoguider::startAcquisition $visuNo"
      pack $This.go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $This.go_stop -side top -fill x

   #--- Frame pour l'autoguidage
   frame $This.suivi -borderwidth 2 -relief ridge
       checkbutton $This.suivi.but_autovisu -text "$caption(autoguider,image)" \
          -variable ::conf(autoguider,showImage) \
          -command "::autoguider::changeShowImage $visuNo"
       checkbutton $This.suivi.but_showtarget -text "$caption(autoguider,cible)" \
          -variable ::conf(autoguider,showTarget) \
          -command "::autoguider::changeShowTarget $visuNo"
       checkbutton $This.suivi.but_showaxis -text "$caption(autoguider,axe_AD)" \
          -variable ::conf(autoguider,showAlphaDeltaAxis) \
          -command "::autoguider::changeShowAlphaDeltaAxis $visuNo"
       checkbutton $This.suivi.moteur_ok -padx 0 -pady 0 \
          -text "$caption(autoguider,ctrl_monture)" \
          -variable ::autoguider::private($visuNo,monture_ok) -command "::autoguider::initMount $visuNo"
       label $This.suivi.label_d      -text "$caption(autoguider,ecart_origine_etoile)"
       label $This.suivi.dx           -textvariable ::autoguider::private($visuNo,dx)
       label $This.suivi.dy           -textvariable ::autoguider::private($visuNo,dy)
       label $This.suivi.delay_alpha  -textvariable ::autoguider::private($visuNo,delay,alpha)
       label $This.suivi.delay_delta  -textvariable ::autoguider::private($visuNo,delay,delta)
       label $This.suivi.lab_clock    -textvariable ::autoguider::private($visuNo,interval)
       button $This.suivi.but_config  -text "$caption(autoguider,config_guidage)" \
          -command "::autoguider::config::run $visuNo"

       grid $This.suivi.but_autovisu   -row 0 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.but_showtarget -row 1 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.but_showaxis   -row 2 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.moteur_ok      -row 3 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.label_d        -row 4 -column 0 -sticky w
       grid $This.suivi.dx             -row 4 -column 1 -sticky w
       grid $This.suivi.dy             -row 4 -column 2 -sticky w
       grid $This.suivi.delay_alpha    -row 5 -column 1 -sticky w
       grid $This.suivi.delay_delta    -row 5 -column 2 -sticky w
       grid $This.suivi.lab_clock      -row 6 -column 0 -columnspan 3
       grid $This.suivi.but_config     -row 7 -column 0 -columnspan 3
   pack $This.suivi -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   #--- j'active la mise a jour automatique de l'affichage en fonction de la camera
   ::confVisu::addCameraListener $visuNo "::autoguider::adaptPanel $visuNo"

   #--- j'adapte l'affichage des boutons en fonction de la camera selectionnee
   adaptPanel $visuNo
}

#------------------------------------------------------------
# ::autoguider::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::autoguider::deletePluginInstance { visuNo } {
   variable private

   #--- je desactive l'adaptation de l'affichage en focntion de la camera
   ::confVisu::removeCameraListener $visuNo "::autoguider::adaptPanel $visuNo"

   #--- je detruis le panel
   destroy $private($visuNo,This)
}

#------------------------------------------------------------
# ::autoguider::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::autoguider::initPlugin{ } {

}

#------------------------------------------------------------
# ::autoguider::adaptPanel
#    adapte l'affichage des boutons en fonction de la camera
#------------------------------------------------------------
proc ::autoguider::adaptPanel { visuNo { command "" } { varname1 "" } { varname2 "" } } {
   variable private
   global conf

   set This $private($visuNo,This)
   set camNo [::confVisu::getCamNo $visuNo ]

   #--- je verifie que la camera est disponible
   set camNo [ ::confVisu::getCamNo $visuNo ]
   if { $camNo == "0" } {
      #--- La camera n'a pas ete encore selectionnee
      set camProduct ""
   } else {
      set camProduct [ cam$camNo product ]
   }

   #--- j'adapte les boutons de selection de pose et de binning
   if { [confCam::getLongExposure $camNo] == "1" } {
         #--- cameras autre que webcam, ou webcam avec la longue pose
         pack $This.pose.lab1 -anchor center -side left -padx 5
         pack $This.pose.combo -anchor center -side left -fill x -expand 1
         pack $This.binning.lab1 -anchor center -side left -padx 0
         pack $This.binning.combo -anchor center -side left -fill x -expand true
         pack forget $This.pose.confwebcam
         pack forget $This.binning.selectBinning
   } else {
         #--- webcam
         pack forget $This.pose.lab1
         pack forget $This.pose.combo
         pack forget $This.binning.lab1
         pack forget $This.binning.combo
         pack $This.pose.confwebcam -anchor center -side left -fill x -expand 1
         pack $This.binning.selectBinning  -anchor center -side left -fill x -expand 1
      #--- je met la pose a zero car cette varaible n'est utilisee et doit etre nulle
      set ::conf(autoguider,pose) "0"
   }
}

#------------------------------------------------------------
# ::autoguider::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::autoguider::startTool { { visuNo 1 } } {
   variable private

   #--- j'affiche la fenetre de l'outil d'autoguidage
   pack $private($visuNo,This) -anchor center -expand 1 -fill y -side top -padx 0

   #--- je change le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::autoguider::setOrigin $visuNo %x %y"
   #--- je change le bind du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "::autoguider::setTargetCoord $visuNo %x %y"

   #--- j'affiche la cible si necessaire
   if { $::conf(autoguider,showTarget) == "1" } {
      changeShowTarget $visuNo
   }

   #--- j'affiche les axes si necessaire
   if { $::conf(autoguider,showAlphaDeltaAxis) == "1" } {
      changeShowAlphaDeltaAxis $visuNo
   }
}

#------------------------------------------------------------
# ::autoguider::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::autoguider::stopTool { { visuNo 1 } } {
   variable private

   #--- je masque la fenetre
   pack forget $private($visuNo,This)

   #--- j'arrete le suivi
   stopAcquisition $visuNo

   #--- je supprime la cible
   ::autoguider::deleteTarget $visuNo

   #--- je masque les axes
   ::autoguider::deleteAlphaDeltaAxis $visuNo

   #--- je restaure le bind par defaut du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "default"
   #--- je restaure le bind par defaut du double-clic du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <Double-1> "default"
}

#------------------------------------------------------------
# ::autoguider::startAcquisition
#    execute les acquisitions en boucle tant que private($visuNo,suiviState)==1
#    si private($visuNo,suiviState)== 0 , ne pas demarrer la boucle
#    si private($visuNo,suiviState)== 1 , faire les acquisitions en boucle
#    si private($visuNo,suiviState)== 2 , arreter les acquisitions a la fin de la boucle en cours
#------------------------------------------------------------
proc ::autoguider::startAcquisition { visuNo } {
   variable private
   global caption conf

   #--- Petits raccourcis bien pratiques
   set camNo [::confVisu::getCamNo $visuNo ]
   set private($visuNo,bufNo)  [::confVisu::getBufNo $visuNo ]
   set private($visuNo,camThreadNo) [::confCam::getThreadNo $camNo ]

   if { $private($visuNo,suiviState) != 0 } {
      #--- je ne fais rien si une demande d'arret est en cours
      return
   }

   #--- je verifie la presence la camera
   if { $camNo == 0 } {
      ::confCam::run
      return
   }

   #--- j'indique que le suivi est en cours
   set private($visuNo,suiviState) 1

   #--- J'affiche le bouton "STOP" et l'associe a la commande d'arret
   $private($visuNo,This).go_stop.but configure \
      -text "$caption(autoguider,STOP)" \
      -command "::autoguider::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::autoguider::stopAcquisition $visuNo"

   #--- je remets a zero les valeurs de l'iteration precedente
   set private(previousAlphaDirection) ""
   set private(previousDeltaDirection) ""
   set private($visuNo,interval)       "0 ms"
   set private($visuNo,previousClock)  [clock clicks -milliseconds ]

   #--- je parametre le binning
   cam$camNo bin [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]

   #--- j'arrete la mise a jour des coordonnees dans les images , pour gagner du temps
   cam$camNo radecfromtel 0

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private($visuNo,monture_ok) == 1 } {
      initMount $visuNo
   }

   doAcquisition $visuNo $camNo
 }

#------------------------------------------------------------
# ::autoguider::doAcquisition
#    fait une acquisition (utilise le mutithread s'il est disponible)
#------------------------------------------------------------
proc ::autoguider::doAcquisition { visuNo camNo} {
   variable private
   global conf

   cam$camNo exptime $::conf(autoguider,pose)

   if { $private($visuNo,camThreadNo) == 0 } {
      #--- je fais une acquisition (mono thread)
      cam$camNo acq
      set statusVariableName "::status_cam$camNo"
      if { [set $statusVariableName] == "exp" } {
         vwait ::status_cam$camNo
      }
      ::autoguider::processAcquisition $visuNo $camNo
   } else {
      #--- je fais une acquisition avec la thread de la camera
      thread::send -async $private($visuNo,camThreadNo) "set visuNo $visuNo"
      thread::send -async $private($visuNo,camThreadNo) {
         cam$camNo acq
         set statusVariableName "::status_cam$camNo"
         if { [set $statusVariableName] == "exp" } {
            vwait ::status_cam$camNo
         }
         thread::send -async $mainThreadNo  "::autoguider::processAcquisition $visuNo $camNo"
      }
   }
}

#------------------------------------------------------------
# ::autoguider::processAcquisition
#    traite une acquisition
#------------------------------------------------------------
proc ::autoguider::processAcquisition { visuNo camNo} {
   variable private
   global conf
   global caption

   set bufNo $private($visuNo,bufNo)

   #--- je place un catch pour intercepter les erreurs d'acces aux péripehriques
   #--- et arreter proprement en cas d'erreur
   set catchError [ catch {
      #--- je soutrais le dark
      if { $::conf(autoguider,darkEnabled) == "1" } {
            buf$bufNo sub [file join $::audace(rep_images) $::conf(autoguider,darkFileName)] 0
      }

      #--- si l'origine n'est pas deja fixee, je prends le centre de l'image pour origine
      if { $private($visuNo,targetCoord) == "" } {
         if { $private($visuNo,originCoord) == "" } {
            set private($visuNo,originCoord) [list [expr [buf$bufNo getpixelswidth]/2] [expr [buf$bufNo getpixelsheight]/2] ]
            set private($visuNo,updateAxis) 1
         }
         set private($visuNo,targetCoord) $private($visuNo,originCoord)
      }

      #--- je calcule la position de l'etoile guide dans la zone cible
      if { $::conf(autoguider,detection)=="PSF" } {
         #--- je calcule les coordonnees de la cible autour de l'etoile
         set x  [lindex $private($visuNo,targetCoord) 0]
         set y  [lindex $private($visuNo,targetCoord) 1]
         set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
         set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
         set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
         set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
         set private($visuNo,targetCoord) [buf$bufNo centro "[list $x1 $y1 $x2 $y2]"]
         #console::disp "result0=$private($visuNo,targetCoord) \n"
      } else {
         set ydelta [expr abs([lindex $private($visuNo,originCoord) 1] - [lindex $private($visuNo,targetCoord) 1]) ]
         set yslit [expr $::conf(autoguider,lipWidth) + $::conf(autoguider,slitWidth)/2 ]
         if { $ydelta <= $yslit } {
             #--- l'etoile est une levre
             set x  [lindex $private($visuNo,targetCoord) 0]
             set y  [lindex $private($visuNo,originCoord) 1]
             set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
             set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
             set y1 [expr int($y) - $yslit]
             set y2 [expr int($y) + $yslit]
             set result [buf$bufNo slitcentro "[list $x1 $y1 $x2 $y2]" $::conf(autoguider,slitWidth) $::conf(autoguider,slitRatio) ]
             set private($visuNo,targetCoord) [lrange $result 0 1]
             #console::disp "slit=$result \n"
         } else {
             #--- l'etoile n'est pas sur une levre
             set x  [lindex $private($visuNo,targetCoord) 0]
             set y  [lindex $private($visuNo,targetCoord) 1]
             set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
             set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
             set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
             set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
             set result [buf$bufNo centro "[list $x1 $y1 $x2 $y2]" ]
             set private($visuNo,targetCoord) [lrange $result 0 1]
             #console::disp "centro=$result \n"
         }
      }

      #--- je calcule l'ecart de position par rapport a la position d'origine
      set dx [expr [lindex $private($visuNo,targetCoord) 0] - [lindex $private($visuNo,originCoord) 0] ]
      set dy [expr [lindex $private($visuNo,targetCoord) 1] - [lindex $private($visuNo,originCoord) 1] ]

      #--- je diminue les valeurs de dx et dy si elles depassent la taille de la zone de detection de l'etoile
      if { $dx > $conf(autoguider,targetBoxSize) } {
         set dx $conf(autoguider,targetBoxSize)
      } elseif { $dx <  -$conf(autoguider,targetBoxSize) } {
         set dx [expr -$conf(autoguider,targetBoxSize) ]
      }

      if { $dy > $conf(autoguider,targetBoxSize) } {
         set dy $conf(autoguider,targetBoxSize)
      } elseif { $private($visuNo,dy) <  -$conf(autoguider,targetBoxSize) } {
         set dy [expr -$conf(autoguider,targetBoxSize) ]
      }
      set private($visuNo,dx) [format "%##0.1f" $dx]
      set private($visuNo,dy) [format "%##0.1f" $dy]

      #--- j'affiche l'image si c'est autorise
      if { $::conf(autoguider,showImage) == "1" } {
         ::confVisu::autovisu $visuNo
      }

      #--- je mets a jour l'affichage des axes si c'est necessaire
      if { $private($visuNo,updateAxis) == 1 } {
         createAlphaDeltaAxis $visuNo $private($visuNo,originCoord) $::conf(autoguider,angle)
         set private($visuNo,updateAxis) 0
      }

      #--- j'affiche le symbole de la cible si c'est autorise
      if { $::conf(autoguider,showTarget) == "1" } {
         moveTarget $visuNo $private($visuNo,targetCoord)
      }

      #--- je calcule le temps ecoule entre deux fins de pose
      set nextClock [clock clicks -milliseconds ]
      set private($visuNo,interval) "[expr $nextClock - $private($visuNo,previousClock)] ms"
      set private($visuNo,previousClock) $nextClock

      #--- je deplace le telescope si c'est autorise
      if { $private($visuNo,monture_ok) == 1 && $private($visuNo,suiviState) == "1" } {

         #--- je convertis l'angle en radian
         set angle [expr $conf(autoguider,angle)* 3.14159265359/180 ]

         #--- je calcule les delais de deplacement alpha et delta (en millisecondes)
         set alphaDelay [expr int((cos($angle) * $private($visuNo,dx) - sin($angle) *$private($visuNo,dy)) * 1000.0 / $conf(autoguider,alphaSpeed))]
         set deltaDelay [expr int((sin($angle) * $private($visuNo,dx) + cos($angle) *$private($visuNo,dy)) * 1000.0 / $conf(autoguider,deltaSpeed))]

         #--- calcul des seuils minimaux de deplacement alpha et delta (en millisecondes)
         set seuilAlpha [expr $conf(autoguider,seuilx) * 1000.0 / $conf(autoguider,alphaSpeed)]
         set seuilDelta [expr $conf(autoguider,seuily) * 1000.0 / $conf(autoguider,deltaSpeed)]

         #--- j'inverse le sens des deplacements si necessaire
         if { $conf(autoguider,alphaReverse) == "1" } {
            set alphaDelay [expr -$alphaDelay]
         }
         if { $conf(autoguider,deltaReverse) == "1" } {
            set deltaDelay [expr -$deltaDelay]
         }

         #--- je calcule la direction alpha
         if { $alphaDelay >= 0 } {
            set alphaDirection "w"
         } else {
            set alphaDirection "e"
            set alphaDelay [expr -$alphaDelay]
         }

         #--- test anti-turbulence
         if { $alphaDirection != $private(previousAlphaDirection) } {
            set alphaDelay 0
         }
         if { $alphaDelay < $seuilAlpha } {
            set alphaDelay 0
         }
         set private(previousAlphaDirection) $alphaDirection

         #--- je calcule la direction delta
         if { $conf(autoguider,declinaisonEnabled) == 1 } {
            if { $deltaDelay >= 0 } {
               set deltaDirection "n"
            } else {
               set deltaDirection "s"
               set deltaDelay [expr -$deltaDelay]
            }
            #--- test anti-turbulence
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
         set private($visuNo,delay,alpha) "$alphaDelay $alphaDirection"
         set private($visuNo,delay,delta) "$deltaDelay $deltaDirection"

         #--- je refraichis l'affichage des nouvelles valeurs
         #--- avant le deplacement du telescope
         update

         #--- je deplace le telescope
         if { $alphaDelay != 0 } {
            ::autoguider::moveTelescope $visuNo $alphaDirection $alphaDelay
         }
         if { $deltaDelay != 0 } {
            ::autoguider::moveTelescope $visuNo $deltaDirection $deltaDelay
         }
      } else {
         set private($visuNo,delay,alpha) "0"
         set private($visuNo,delay,delta) "0"
         update
      }
   #--- fin du catch
   } catchMessage ]

   if { $catchError == 1 } {
      #--- j'arrete le suivi
      ::autoguider::stopAcquisition $visuNo
      #--- j'affiche un message d'erreur
      tk_messageBox -message "$catchMessage. See console." -title "$caption(autoguider,titre)" -icon error
      console::affiche_erreur "::autoguider::processAcquisition $::errorInfo \n"
   }

   if { $private($visuNo,suiviState) == "1" } {
      if { [string is double $conf(autoguider,intervalle)] } {
         after [expr int($conf(autoguider,intervalle) * 1000) ]
      }
      #--- je fais une nouvelle acquisition
      ::autoguider::doAcquisition $visuNo $camNo
      #--- c'est reparti pour un tour ...
   } else {
      #--- la fin des acquistions a ete demandee
      #--- j'active le bouton GO
      $private($visuNo,This).go_stop.but configure \
         -text "$caption(autoguider,GO)" \
         -command "::autoguider::startAcquisition $visuNo"
      #--- je supprime l'association du bouton escape
      bind all <Key-Escape> ""
      set private($visuNo,suiviState) 0
   }
}

#------------------------------------------------------------
# ::autoguider::stopAcquisition
#    Demande l'arret des acquisitions . L'arret sera effectif apres la fin
#    de l'acquisition en cours
#------------------------------------------------------------
proc ::autoguider::stopAcquisition { visuNo } {
   variable private

   #--- je demande l'arret du suivi s'il est en cours
   if { $private($visuNo,suiviState) == 1 } {
      set private($visuNo,suiviState) 2
   }
}

#------------------------------------------------------------
# ::autoguider::initMount
#    initialise les parametres de la monture
#    selectionne la plus petite vitesse
#
# parametres :
#    visuNo    : numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::initMount { visuNo } {
   variable private

   if { $private($visuNo,monture_ok) == 1 } {
      #--- je configure la monture avec la plus petite vitesse
      ::telescope::setSpeed 1
   } else {
      #--- je mets a zero les durees affichees
      set private($visuNo,delay,alpha) 0
      set private($visuNo,delay,delta) 0
   }
}

#------------------------------------------------------------
# ::autoguider::setOrigin
#    initialise le point origine dans private(visuNo,originCoord)
#
# parametres :
#    visuNo    : numero de la visu courante
#    x,y       : coordonnees de l'origine des axes (referentiel ecran)
#------------------------------------------------------------
proc ::autoguider::setOrigin { visuNo x y } {
   variable private

   ::autoguider::setTargetCoord $visuNo $x $y
   set private($visuNo,originCoord) $private($visuNo,targetCoord)

   #--- je dessine les axes sur la nouvelle origine
   changeShowAlphaDeltaAxis $visuNo

}

#------------------------------------------------------------
# ::autoguider::setTargetCoord
#    initialise les cooredonnees de la cible dans private(visuNo,targetCoord)
#
# parametres :
#    visuNo    : numero de la visu courante
#    x,y       : coordonnees de l'origine des axes (referentiel ecran)
#------------------------------------------------------------
proc ::autoguider::setTargetCoord { visuNo x y } {
   variable private

   #--- petits raccourcis pour se simplier le codage
   set zoom [visu$visuNo zoom]
   set bufNo [visu$visuNo buf]

   #---
   if { [buf$bufNo imageready] == 0 } {
      return
   }

   #--- je calcule les coordonnees de la zone de recherche de l'etoile
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]

   #--- je recherche la nouvelle position de l'etoile dans la zone cible
   if { $::conf(autoguider,detection)=="PSF"} {
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      set x1 [expr $x - $::conf(autoguider,targetBoxSize)]
      set x2 [expr $x + $::conf(autoguider,targetBoxSize)]
      set y1 [expr $y - $::conf(autoguider,targetBoxSize)]
      set y2 [expr $y + $::conf(autoguider,targetBoxSize)]
      set centro [buf$bufNo centro [list $x1 $y1 $x2 $y2] ]
      set private($visuNo,targetCoord) $centro
   } else {
      set private($visuNo,targetCoord) $coord
   }
   #--- je dessine la cible aux nouvelle coordonneessur la nouvelle origine
   moveTarget $visuNo $private($visuNo,targetCoord)
}
#------------------------------------------------------------
# ::autoguider::createTarget
#    affiche la cible autour du point de coordonnees targetCoord
#
#           PSF                     SLIT
#       *----------* y1=y0+w   *----------*  y2=y0+w
#       |          |           |          |
#       |          |           *----------*  s2=y0+slitWidth/2
#     ..|..........|...........|..........|
#       |          |           *----------*  s1=y0-slitWidth/2
#       |          |           |          |
#       *----------* y1=y0-w   *----------*  y1=y0-w
#       x1         x2          x1         x2
# parametres :
#    visuNo      : numero de la visu courante
#    targetCoord : coordonnees de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::createTarget { visuNo } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteTarget $visuNo

   if { $::conf(autoguider,detection) == "PSF" } {
      #--- je calcule les coordonnees dans l'image
      set x  [lindex $private($visuNo,targetCoord) 0]
      set y  [lindex $private($visuNo,targetCoord) 1]
      set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]

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

      #--- j'affiche la cible
      $private($visuNo,hCanvas) create rect $x1 $y1 $x2 $y2 -outline red -offset center -tag target
   } else {
      #--- je calcule les coordonnees dans l'image
      set x  [lindex $private($visuNo,targetCoord) 0]
      set y  [lindex $private($visuNo,targetCoord) 1]
      set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
      set s1 [expr int($y) - $::conf(autoguider,slitWidth)/2]
      set s2 [expr int($y) + $::conf(autoguider,slitWidth)/2]

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
      set coord [::confVisu::picture2Canvas $visuNo [list $x1 $s1 ]]
      set x1 [lindex $coord 0]
      set s1 [lindex $coord 1]
      set coord [::confVisu::picture2Canvas $visuNo [list $x2 $s2 ]]
      set x2 [lindex $coord 0]
      set s2 [lindex $coord 1]

      #--- j'affiche la cible
      $private($visuNo,hCanvas) create rect $x1 $y1 $x2 $s1 -outline red -offset center -tag target1
      $private($visuNo,hCanvas) create rect $x1 $s2 $x2 $y2 -outline red -offset center -tag target2
   }
}

#------------------------------------------------------------
# ::autoguider::createAlphaDeltaAxis
#    dessine les axes alpha et delta centres sur l'origine
#
# parametres :
#    visuNo    : numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::createAlphaDeltaAxis { visuNo originCoord angle } {
   #--- je supprime les axes s'ils existent deja
   deleteAlphaDeltaAxis $visuNo
   #--- je dessine l'axe alpha
   drawAxis $visuNo $originCoord $angle "Est" "West"
   #--- je dessine l'axe delta
   drawAxis $visuNo $originCoord [expr $angle+90] "South" "North"
}

#------------------------------------------------------------
# ::autoguider::deleteAlphaDeltaAxis
#    arrete l'affichage des axes alpha et delta
#
# parametres :
#    visuNo    : numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::deleteAlphaDeltaAxis { visuNo } {
   variable private

   #--- je supprime les axes qui existent deja
   $private($visuNo,hCanvas) delete axis
}

#------------------------------------------------------------
# ::autoguider::deleteTarget
#    supprime l'affichage de la cible
#
# parametres :
#    visuNo    : numero de la visu courante
#------------------------------------------------------------
proc ::autoguider::deleteTarget { visuNo } {
   variable private

   #--- je supprime l'ffichage de la cible
   $private($visuNo,hCanvas) delete "target" "target1" "target2"
   $private($visuNo,hCanvas) dtag "target"
   $private($visuNo,hCanvas) dtag "target1"
   $private($visuNo,hCanvas) dtag "target2"
}

#------------------------------------------------------------
# ::autoguider::moveTarget
#    deplace l'affichage de la cible
#
# parametres :
#    visuNo      : numero de la visu courante
#    targetCoord : coordonnees de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::moveTarget { visuNo targetCoord } {
   variable private

   #--- je cree la cible si elle n'existe pas
   if { [$private($visuNo,hCanvas) gettags target] == ""
     && [$private($visuNo,hCanvas) gettags target1] == ""} {
      createTarget $visuNo
   } else {
      if { $::conf(autoguider,detection) == "PSF" } {

         #--- je calcule les coordonnees dans le buffer
         set x  [lindex $targetCoord 0]
         set y  [lindex $targetCoord 1]
         set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
         set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
         set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
         set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]

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

         #--- je convertis les coordonnes image en coordonnees canvas
         $private($visuNo,hCanvas) coords "target" [list $x1 $y1 $x2 $y2]

      } else {

         #--- je calcule les coordonnees dans l'image
         set x  [lindex $targetCoord 0]
         set y  [lindex $targetCoord 1]
         set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
         set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
         set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
         set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
         set s1 [expr int($y) - $::conf(autoguider,slitWidth)/2]
         set s2 [expr int($y) + $::conf(autoguider,slitWidth)/2]

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
         set coord [::confVisu::picture2Canvas $visuNo [list $x1 $s1 ]]
         set x1 [lindex $coord 0]
         set s1 [lindex $coord 1]
         set coord [::confVisu::picture2Canvas $visuNo [list $x2 $s2 ]]
         set x2 [lindex $coord 0]
         set s2 [lindex $coord 1]

         #--- j'affiche la cible
         $private($visuNo,hCanvas) coords "target1" [list $x1 $y1 $x2 $s1]
         $private($visuNo,hCanvas) coords "target2" [list $x1 $s2 $x2 $y2]
      }
   }
}

#------------------------------------------------------------
# ::autoguider::drawAxis
#    trace un axe avec un libelle a chaque extremite
#
# parametres :
#    visuNo    : numero de la visu courante
#    coord     : coordonnees de l'origine des axes (referentiel buffer)
#    angle     : angle d'inclinaison des axes (en degres)
#    label1    : libelle de l'extremite negative de l'axe
#    label2    : libelle de l'extremite positive de l'axe
#------------------------------------------------------------
proc ::autoguider::drawAxis { visuNo coord angle label1 label2} {
   variable private
   global audace

   set bufNo [::confVisu::getBufNo $visuNo ]

   if { [buf$bufNo imageready] == 0 } {
      return
   }

   set margin 8
   set xmin $margin
   set xmax [expr [buf$bufNo getpixelswidth] - $margin]
   set ymin $margin
   set ymax [expr [buf$bufNo getpixelsheight] - $margin]

   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set a  [expr tan($angle*3.14159265359/180)]
   set b  [expr $y - $a * $x]

   #--- je calcule les coordonnees des extremites de l'axe
   if { $a > 1000000 || $a < -1000000 } {
      #--- l'axe est vertical
      if { [expr sin($angle*3.14159265359/180)] >= 0 } {
         set y1 $ymin
         set y2 $ymax
      } else {
         set y1 $ymax
         set y2 $ymin
      }
      set x1 $x
      set x2 $x
   } elseif { $a > 0.00000001 || $a < -0.00000001 } {
      #--- l'axe n'est ni vertical ni horizontal
      if { [expr sin($angle*3.14159265359/180)] >= 0 } {
         set y1 $ymin
         set y2 $ymax
      } else {
         set y1 $ymax
         set y2 $ymin
      }
      set x1 [expr ($y1 - $b) / $a ]
      if { $x1 < $xmin } {
         set x1 $xmin
         set y1 [expr $a * $x1 + $b]
      } elseif { $x1 > $xmax } {
         set x1 $xmax
         set y1 [expr $a * $x1 + $b]
      }
      set x2 [expr ($y2 - $b) / $a ]
      if { $x2 < $xmin } {
         set x2 $xmin
         set y2 [expr $a * $x2 + $b]
      } elseif { $x2 > $xmax } {
         set x2 $xmax
         set y2 [expr $a * $x2 + $b]
      }
   } else {
      #--- l'axe est horizontal
      if { [expr cos($angle*3.14159265359/180)] >= 0 } {
         set x1 $xmin
         set x2 $xmax
      } else {
         set x1 $xmax
         set x2 $xmin
      }
      set y1 $y
      set y2 $y
   }

   #--- je transforme les coordonnees dans le repere canvas
   set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1]]
   set coord2 [::confVisu::picture2Canvas $visuNo [list $x2 $y2]]
   #--- je trace l'axe et les libelles des extremites
   $private($visuNo,hCanvas) create line [lindex $coord1 0] [lindex $coord1 1] [lindex $coord2 0] [lindex $coord2 1] -fill $::audace(color,drag_rectangle) -tag axis -state normal
   $private($visuNo,hCanvas) create text [lindex $coord1 0] [lindex $coord1 1] -text $label1 -tag axis  -state normal -fill $::audace(color,drag_rectangle)
   $private($visuNo,hCanvas) create text [lindex $coord2 0] [lindex $coord2 1] -text $label2 -tag axis  -state normal -fill $::audace(color,drag_rectangle)
}

#------------------------------------------------------------
# ::autoguider::showAlphaDeltaAxis
#    affiche/cache les axes alpha et delta centres sur l'origine
#    si showAlphaDeltaAxis==0 , efface l'image
#    si showAlphaDeltaAxis==1 , ne fait rien , l'image sera affiche apres la prochaine acquisition
#------------------------------------------------------------
proc ::autoguider::changeShowAlphaDeltaAxis { visuNo } {
   variable private

   if { $::conf(autoguider,showAlphaDeltaAxis) == "0" } {
      #--- delete axis
      deleteAlphaDeltaAxis $visuNo
   } else {
      #--- create axis
      createAlphaDeltaAxis $visuNo $private($visuNo,originCoord) $::conf(autoguider,angle)
   }
}

#------------------------------------------------------------
# ::autoguider::changeShowImage
#    si showImage==0 , efface l'image
#    si showImage==1 , ne fait rien , l'image sera affiche apres la prochaine acquisition
#------------------------------------------------------------
proc ::autoguider::changeShowImage { visuNo } {
   if { $::conf(autoguider,showImage) == "0" } {
      #--- j'efface l'image
      visu$visuNo clear
   } else {
      #--- j'affiche l'image
      # rien a faire ici car l'image sera affichee apres la prochaine acquisition
   }
}

#------------------------------------------------------------
# ::autoguider::changeShowTarget
#    si showTarget==0 , efface la zone cible
#    si showTarget==1 , ne fait rien , la cible sera affichee apres la prochaine acquistion
#------------------------------------------------------------
proc ::autoguider::changeShowTarget { visuNo } {
   variable private

   if { $::conf(autoguider,showTarget) == "0" } {
      deleteTarget $visuNo
   } else {
      if { $private($visuNo,targetCoord) == "" } {
         if { $private($visuNo,originCoord) == "" } {
            set bufNo [::confVisu::getBufNo $visuNo ]
            if { [buf$bufNo imageready] == 1  } {
               set private($visuNo,originCoord) [list [expr [buf$bufNo getpixelswidth]/2] [expr [buf$bufNo getpixelsheight]/2] ]
            } else {
               #--- impossible de calculer la position de la zone cible car il n'y a pas d'image
               return
            }
         }
         set private($visuNo,targetCoord) $private($visuNo,originCoord)
      }

##console::disp "private($visuNo,targetCoord)=$private($visuNo,targetCoord)\n"
      #--- j'affiche la zone cible
      createTarget $visuNo
   }
}

#------------------------------------------------------------
# ::autoguider::configureWebcam
#    affiche la fenetre de configuration d'une webcam
#------------------------------------------------------------
proc ::autoguider::webcamConfigure { visuNo } {
   global caption

   set result [ catch { after 10 "cam[::confVisu::getCamNo $visuNo] videosource" } ]
   if { $result == "1" } {
      if { [ ::confVisu::getCamera $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(autoguider,pb) -type ok \
                -message $caption(autoguider,selcam) ]
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
# ::autoguider::selectBinning
#    affiche la fenetre de selection du format d'image d'une webcam
#------------------------------------------------------------
proc ::autoguider::selectBinning { visuNo } {
   variable private

   set camNo [::confVisu::getCamNo $visuNo ]

   if { [confCam::getLongExposure $camNo] == "0" } {
         #--- j'affiche la fentre de choix de binning de la webcam
         set result [ catch { cam$camNo videoformat } ]
         if { $result == "1" } {
            if { [ ::confVisu::getCamera $visuNo ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $::caption(autoguider,pb) -type ok \
                     -message $caption(autoguider,selcam) ]
               set integre non
               if { $choix == "ok" } {
                  #--- Ouverture de la fenetre de selection des cameras
                  ::confCam::run
                  tkwait window $audace(base).confCam
               }
               ::audace::menustate normal
            }
         }
         if { $private($visuNo,mode) == "video" } {
            #--- En mode video, il faut redimmensionner le canvas immediatement
            #--- j'arrete et relance le mode video
            ::confVisu::setVideo $visuNo "0"
            ::confVisu::setVideo $visuNo "1"
         }
   }

   #--- je position l'indicateur qui doit mettre a jour les axes
   #--- a la prochaine acquisition
   set private($visuNo,updateAxis) "1"
}

#------------------------------------------------------------
# ::autoguider::moveTelescope { }
#    Deplace le telescope pendant un duree determinee
#    Le deplacement est interrompu si private($visuNo,suiviState)!=0
#
# parametres :
#    visuNo    : numero de la visu courante
#    direction : e w n s
#    delay     : duree du deplacement en milliseconde (nombre entier)
# return
#    rien
#------------------------------------------------------------
proc ::autoguider::moveTelescope { visuNo direction delay} {
   variable private

   #--- laisse la main pour traiter une eventuelle demande d'arret
   update

   #--- je demarre le deplacement
   ##::telescope::move $direction
   tel$::audace(telNo) radec move $direction

   #--- j'attend l'expiration du delai par tranche de 1 seconde
   while { $delay > 0 } {
      if { $private($visuNo,suiviState) == 1 } {
         if { $delay > 1000 } {
            after 999
            set delay [expr $delay - 1000 ]
         } else {
            after $delay
            set delay 0
         }
      } else {
         #--- j'interromp l'attente s'il y a une demande d'arret
         set delay 0
      }
   }

   #--- j'arrete le deplacement
   ##::telescope::stop $direction
   tel$::audace(telNo) radec stop $direction
}

