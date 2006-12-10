#
# Fichier : autoguider.tcl
# Description : Outil d'autoguidage
# Auteur : Michel PUJOL
# Mise a jour $Id: autoguider.tcl,v 1.10 2006-12-10 15:23:58 robertdelmas Exp $
#

package provide autoguider 1.0

#==============================================================
#   Declaration du namespace autoguider
#    intialise le namespace
#==============================================================
namespace eval ::autoguider {
   global audace caption panneau

   source [ file join $audace(rep_plugin) tool autoguider autoguider.cap ]
   source [ file join $audace(rep_plugin) tool autoguider autoguiderconfig.tcl ]
   set panneau(menu_name,autoguider) "$caption(autoguider,menu)"
}

#------------------------------------------------------------
# ::autoguider::Init
#    cree une nouvelle instance de l'outil
# 
#------------------------------------------------------------
proc ::autoguider::Init { { in "" } { visuNo 1 } } {
   variable private
   global audace conf

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
   if { ! [ info exists conf(autoguider,enableDeclinaison)] }    { set conf(autoguider,enableDeclinaison)    "1" }

   set private($visuNo,base)              $in
   set private($visuNo,This)              "$in.autoguider"
   set private($visuNo,hCanvas)           [::confVisu::getCanvas $visuNo]
   set private($visuNo,mode)              "image"

   set private($visuNo,monture_ok)        "0"
   set private($visuNo,suiviState)        "0"
   set private($visuNo,status)            ""
   set private($visuNo,dx)                "0.00"
   set private($visuNo,dy)                "0.00"
   set private($visuNo,delay,alpha)       "0.00"
   set private($visuNo,delay,delta)       "0.00"
   set private($visuNo,originCoord)       "" 
   set private($visuNo,targetCoord)       ""
   set private($visuNo,hTarget)           ""
   set private($visuNo,interval)          ""
   set private($visuNo,previousClock)     "0"
   set private($visuNo,updateAxis)        "0"

   #--- je cree la fenetre d'autoguidage
   createPanel $visuNo

   #--- j'adapte l'affichage des boutons en fonction de la camera selectionnee
   adaptPanel  $visuNo
}

#------------------------------------------------------------
# ::autoguider::createPanel
#    cree la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::autoguider::createPanel { visuNo } {
   variable private
   global audace caption conf panneau

   #---
   set panneau(menu_name,autoguider) "$caption(autoguider,menu)"

   #--- Petit raccourci bien pratique
   set This $private($visuNo,This)

   #--- Cadre de l'outil
   frame $private($visuNo,This) -borderwidth 2 -relief groove

   #--- Cadre du titre de l'outil
   frame $private($visuNo,This).titre -borderwidth 2 -relief groove
      Button $private($visuNo,This).titre.but -borderwidth 1 -text "$caption(autoguider,titre)" \
        -command {
           ::audace::showHelpPlugin tool autoguider autoguider.htm
        }
      pack $private($visuNo,This).titre.but -side top -fill x 
      DynamicHelp::add $private($visuNo,This).titre.but -text "$caption(autoguider,help_titre)"
   pack $private($visuNo,This).titre -side top -fill x -expand true

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

   pack $This.pose -anchor center -fill x -expand 1

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
   pack $This.binning -anchor center -fill x -expand true

   #--- Cadre de l'intervalle
   frame $This.intervalle -borderwidth 2 -relief ridge
      label $This.intervalle.lab1 -text "$caption(autoguider,intervalle)"
      pack $This.intervalle.lab1 -anchor center -side left -padx 5
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.intervalle.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable conf(autoguider,intervalle) \
         -values $list_combobox
      pack $This.intervalle.combo -anchor center -side left -fill x -expand 1
   pack $This.intervalle -anchor center -fill x -expand 1

   #--- Cadre du Status
   frame $This.status -borderwidth 2 -relief ridge
      label $This.status.lab -textvariable ::autoguider::private($visuNo,status) \
         -font $audace(font,arial_10_b) -relief ridge -justify center -width 2
      pack $This.status.lab -side top -fill x -expand true -pady 1
   pack $This.status -anchor center -fill x -expand true

   #--- Cadre du bouton Go/Stop
   frame $This.go_stop -borderwidth 2 -relief ridge
      button $This.go_stop.but -text "$caption(autoguider,GO)" -height 2 \
        -font $audace(font,arial_12_b) -borderwidth 3 -pady 6 -command "::autoguider::startAcquisition $visuNo"
      pack $This.go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $This.go_stop -anchor center -fill x -expand true

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
   pack $This.suivi -anchor center -fill x -expand true 

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private($visuNo,This)

   #--- j'active la mise a jour automatique de l'affichage en fonction de la camera
   ::confVisu::addCameraListener $visuNo "::autoguider::adaptPanel $visuNo"
}

#------------------------------------------------------------
# ::autoguider::deletePanel
#    supprime la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::autoguider::deletePanel { visuNo } {
   variable private

   #--- je desactive l'adaptation de l'affichage en focntion de la camera
   ::confVisu::removeCameraListener $visuNo "::autoguider::adaptPanel $visuNo"

   #--- je detruis le panel
   destroy $private($visuNo,This)
}

#------------------------------------------------------------
# ::autoguider::adaptPanel
#    adapte l'affichage des boutons en fonction de la camera
# 
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

   #--- je calcule format des boutons
   if { "$camProduct" == "webcam" } {
      if { $conf(webcam,longuepose) == "0" } {
         set panelFormat "1"
         set ::conf(autoguider,pose) "0"
      }
   } else {
      set panelFormat "0"
   }

   #--- j'adapte les boutons de selection de pose et de binning
   switch $panelFormat {
      0 {
         #--- cameras autre que webcam
         pack $This.pose.lab1 -anchor center -side left -padx 5
         pack $This.pose.combo -anchor center -side left -fill x -expand 1
         pack $This.binning.lab1 -anchor center -side left -padx 0
         pack $This.binning.combo -anchor center -side left -fill x -expand true
         pack forget $This.pose.confwebcam
         pack forget $This.binning.selectBinning
      }
      1 {
         #--- webcam
         pack forget $This.pose.lab1
         pack forget $This.pose.combo
         pack forget $This.binning.lab1
         pack forget $This.binning.combo
         pack $This.pose.confwebcam -anchor center -side left -fill x -expand 1
         pack $This.binning.selectBinning  -anchor center -side left -fill x -expand 1
      }
   }
}

#------------------------------------------------------------
# ::autoguider::startTool
#    affiche la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::autoguider::startTool { { visuNo 1 } } {
   variable private

   #--- j'affiche la fenetre de l'outil d'autoguidage
   pack $private($visuNo,This) -anchor center -expand 0 -fill y -side top -padx 0

   #--- je change le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::autoguider::setOrigin $visuNo %x %y"

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
# 
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
}

#------------------------------------------------------------
# ::autoguider::startAcquisition
#  execute les acquisitions en boucle tant que private($visuNo,suiviState)==1
#  si private($visuNo,suiviState)== 0 , ne pas demarrer la boucle
#  si private($visuNo,suiviState)== 1 , faire les acquisitions en boucle
#  si private($visuNo,suiviState)== 2 , arreter les acquisitions a la fin de la boucle en cours

#------------------------------------------------------------
proc ::autoguider::startAcquisition { visuNo } {
   variable private
   global caption conf

   #--- Petits raccourcis bien pratiques
   set camNo [::confVisu::getCamNo $visuNo ]
   set bufNo [::confVisu::getBufNo $visuNo ]
   set camName [::confVisu::getCamera $visuNo ]

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

   #--- je remets a zero la valeur du decalage precedent
   set private(previousAlphaDelay) "0"
   set private(previousDeltaDelay) "0"
   set private(delay_alpha)        "0"
   set private(delay_delta)        "0"

   #--- je parametre le binning
   cam$camNo bin [list [string range $::conf(autoguider,binning) 0 0] [string range $::conf(autoguider,binning) 2 2]]

   #--- j'arrete la mise a jour des coordonnees dans les images , pour gagner du temps
   cam$camNo radecfromtel 0

   #--- j'active l'envoi des commandes a la monture si c'est demande
   if { $private($visuNo,monture_ok) == 1 } {
      initMount $visuNo
   }

   while { $private($visuNo,suiviState) == "1" } {
      #--- je parametre le temps de pose
      cam$camNo exptime $::conf(autoguider,pose)

      #--- je fais une acquisition
      cam$camNo acq
      vwait status_cam$camNo

      #--- j'affiche l'image si c'est autorise
      if { $::conf(autoguider,showImage) == "1" } {
         ::confVisu::autovisu $visuNo
      }

      #--- je prends le centre de l'image pour origine si elle n'est deja fixee
      if { $private($visuNo,targetCoord) == "" } {
         if { $private($visuNo,originCoord) == "" } {
            set private($visuNo,originCoord) [list [expr [buf$bufNo getpixelswidth]/2] [expr [buf$bufNo getpixelsheight]/2] ] 
            set private($visuNo,updateAxis) 1
         }
         set private($visuNo,targetCoord) $private($visuNo,originCoord)
      }

      #--- je mets a jour les axes si c'est necessaire
      if { $private($visuNo,updateAxis) == 1 } {
         createAlphaDeltaAxis $visuNo $private($visuNo,originCoord) $::conf(autoguider,angle)
         set private($visuNo,updateAxis) 0
      }

      #--- je calcule la position de la zone cible autour de l'etoile
      set x  [lindex $private($visuNo,targetCoord) 0]
      set y  [lindex $private($visuNo,targetCoord) 1]
      set x1 [expr int($x) - $::conf(autoguider,targetBoxSize)]
      set x2 [expr int($x) + $::conf(autoguider,targetBoxSize)]
      set y1 [expr int($y) - $::conf(autoguider,targetBoxSize)]
      set y2 [expr int($y) + $::conf(autoguider,targetBoxSize)]
      set targetBoxPicture [list $x1 $y1 $x2 $y2]

      #--- je calcule la position de l'etoile guide dasn la zone cible
      set private($visuNo,targetCoord) [buf$bufNo centro "$targetBoxPicture"]

      #--- je calcule l'ecart de position par rapport a la position origine
      set private($visuNo,dx) [format "%##0.1f" [expr [lindex $private($visuNo,targetCoord) 0] - [lindex $private($visuNo,originCoord) 0] ]]
      set private($visuNo,dy) [format "%##0.1f" [expr [lindex $private($visuNo,targetCoord) 1] - [lindex $private($visuNo,originCoord) 1] ]]

      #--- j'affiche le symbole de la cible si c'est autorise
      if { $::conf(autoguider,showTarget) == "1" } {
         moveTarget $visuNo $private($visuNo,targetCoord)
      }

      #--- je calcule le temps ecoule entre deux fins de pose
      set nextClock [clock clicks -milliseconds ]
      set private($visuNo,interval) "[expr $nextClock - $private($visuNo,previousClock)] ms"
      set private($visuNo,previousClock) $nextClock 
      #--- je permets le refraichissement de l'affichage des nouvelles valeurs
      update

      #--- je deplace le telescope si c'est autorise
      if { $private($visuNo,monture_ok) == 1 && $private($visuNo,suiviState) == "1" } {
         set private($visuNo,status) "Maj suivi"
         ::autoguider::updateTelescope $visuNo $private($visuNo,dx) $private($visuNo,dy)
      }

      #--- je vide l'affichage du status
      set private($visuNo,status) ""

      #--- j'execute le delai d'attente entre deux poses si c'est autorise
      if { $conf(autoguider,intervalle) > 0 && $private($visuNo,suiviState) == "1"} {
         after [expr int($conf(autoguider,intervalle) * 1000) ]
      }
   }

   #--- j'arrete le suivi
   set private($visuNo,status) ""

   #--- j'active le bouton GO et associe la commande demarrage
   $private($visuNo,This).go_stop.but configure \
      -text "$caption(autoguider,GO)" \
      -command "::autoguider::startAcquisition $visuNo"
   #--- je supprime l'association du bouton escape
   bind all <Key-Escape> ""

   set private($visuNo,suiviState) 0
}

#------------------------------------------------------------
# ::autoguider::stopAcquisition
#    arrete les acquisitions en boucle
# 
#------------------------------------------------------------
proc ::autoguider::stopAcquisition { visuNo } {
   variable private 

   #--- si le suivi est en cours , je demande l'arret
   if { $private($visuNo,suiviState) == 1 } {
      set private($visuNo,suiviState) 2
   }
}

#------------------------------------------------------------
# ::autoguider::initMount
#    initialise les parametres de la monture : selectionne la plus petite vitesse)
#      
# parametres :
#   visuNo    : numero de la visu courante
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
#   initialise le point origine x0, y0
# 
# parametres :
#   visuNo    : numero de la visu courante
#   x,y       : coordonnees de l'origine des axes (referentiel ecran)
#------------------------------------------------------------
proc ::autoguider::setOrigin { visuNo x y } {
   variable private
   global conf

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
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set x1 [expr $x - $::conf(autoguider,targetBoxSize)]
   set x2 [expr $x + $::conf(autoguider,targetBoxSize)]
   set y1 [expr $y - $::conf(autoguider,targetBoxSize)]
   set y2 [expr $y + $::conf(autoguider,targetBoxSize)]
   set centro [buf$bufNo centro [list $x1 $y1 $x2 $y2] ]
   set private($visuNo,originCoord) $centro
   set private($visuNo,targetCoord) $centro

   #--- je dessine les axes sur la nouvelle origine
   changeShowAlphaDeltaAxis $visuNo
}

#------------------------------------------------------------
# ::autoguider::createTarget
#  affiche la cible autour du point de coordonnees targetCoord
#  
# parametres :
#   visuNo    : numero de la visu courante
#   targetCoord : coordonnees de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::createTarget { visuNo targetCoord } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteTarget $visuNo

   #--- je calcule les coordonnees dans l'image
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

   #--- j'affiche la cible
   set private($visuNo,hTarget) [eval {$private($visuNo,hCanvas) create rect} $x1 $y1 $x2 $y2 -outline red -offset center -tag target]
}

#------------------------------------------------------------
# ::autoguider::createAlphaDeltaAxis
#    dessine les axes alpha et delta
# 
# parametres :
#   visuNo    : numero de la visu courante
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
#  arrete l'affichage des axes alpha et delta
#  
# parametres :
#   visuNo    : numero de la visu courante
#   
#------------------------------------------------------------
proc ::autoguider::deleteAlphaDeltaAxis { visuNo } {
   variable private

   #--- je supprime les axes qui existent deja
   $private($visuNo,hCanvas) delete axis
}

#------------------------------------------------------------
# ::autoguider::deleteTarget
#  arrete l'affichage de la cible  
#  
# parametres :
#   visuNo    : numero de la visu courante
#   
#------------------------------------------------------------
proc ::autoguider::deleteTarget { visuNo } {
   variable private

   #--- je supprime l'ffichage de la cible
   if { $private($visuNo,hTarget) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,hTarget)
      set private($visuNo,hTarget) ""
      $private($visuNo,hCanvas) dtag target
   }
}

#------------------------------------------------------------
# ::autoguider::moveTarget
#   deplace l'affichage de la cible
#
# parametres :
#   visuNo      : numero de la visu courante
#   targetCoord : coordonnees de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::moveTarget { visuNo targetCoord } {
   variable private

   #--- je cree la cible si elle n'existe pas
   if { $private($visuNo,hTarget) == "" } {
      createTarget $visuNo $targetCoord
   } else {
      #--- je calcule les coordonnees dans l'image
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
   }
}

#------------------------------------------------------------
# ::autoguider::drawAxis
#    trace un axe avec un libelle a chaque extremite
# 
# parametres :
#   visuNo    : numero de la visu courante
#   coord     : coordonnees de l'origine des axes (referentiel buffer)
#   angle     : angle d'inclinaison des axes (en degres)
#   label1    : libelle de l'extremite negative de l'axe
#   label2    : libllle de l'extremite positive de l'axe
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
# 
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
# 
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
      createTarget $visuNo $private($visuNo,targetCoord)
   }
}

#------------------------------------------------------------
# ::autoguider::configureWebcam
#    affiche la fenetre de configuration d'une webcam
# 
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
# 
#------------------------------------------------------------
proc ::autoguider::selectBinning { visuNo } {
   variable private
   global caption conf

   set panelFormat "0"
   #--- je verifie que la camera est disponible
   set camNo [ ::confVisu::getCamNo $visuNo ]
   if { $camNo == "0" } {
      #--- La camera n'a pas ete encore selectionnee
      set camProduct ""
   } else {
      set camProduct [ cam$camNo product ]
   }

   if { "$camProduct" == "webcam" } {
      if { $conf(webcam,longuepose) == "0" } {
         set panelFormat "1"
      }
   }

   switch $panelFormat {
     "0" {
         #--- j'affiche le bouton de choix de binning par defaut
     }
     "1" {
         #--- j'affiche le bouton de choix de binning de la webcam
         set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] videoformat } ]
         if { $result == "1" } {
            if { [ ::confVisu::getCamera $visuNo ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $caption(autoguider,pb) -type ok \
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
   }

   #--- je position l'indicateur qui doit mettre a jour les axes
   #--- a la prochaine acquisition
   set private($visuNo,updateAxis) "1"
}

#------------------------------------------------------------
# ::autoguider::updateTelescope
#   Calcule la duree de deplacement (alpha,delta) du telescope correspondant
#   au deplacement (dx,dy) sur l'image.
#   Puis execute le deplacement du telescope
# parametres :
#   visuNo    : numero de la visu courante
#   dx        : nombre de pixels sur l'axe x de l'image (referentiel buffer)
#   dy        : nombre de pixels sur l'axe y de l'image (referentiel buffer)
# return
#  rien
#------------------------------------------------------------
proc ::autoguider::updateTelescope { visuNo dx dy } {
   variable private
   global conf

   #--- je diminue les valeurs de dx et dy si elles depassent la taille de la zone de detection de l'etoile
   if { $dx > $conf(autoguider,targetBoxSize) } {
      set dx $conf(autoguider,targetBoxSize)
   } elseif { $dx <  -$conf(autoguider,targetBoxSize) } {
      set dx [expr -$conf(autoguider,targetBoxSize) ]
   }
   if { $dy > $conf(autoguider,targetBoxSize) } {
      set dy $conf(autoguider,targetBoxSize)
   } elseif { $dy <  -$conf(autoguider,targetBoxSize) } {
      set dy [expr -$conf(autoguider,targetBoxSize) ]
   }

   #--- j'affiche les valeurs dx et dy
   $private($visuNo,This).suivi.dx configure -text $dx
   $private($visuNo,This).suivi.dx configure -text $dy

   #--- je convertis l'angle en radian
   set angle [expr $conf(autoguider,angle)* 3.14159265359/180 ]

   #--- je calcule les delais de deplacement alpha et delta (en millisecondes)
   set alphaDelay [expr int((cos($angle) * $dx - sin($angle) *$dy) * 1000.0 / $conf(autoguider,alphaSpeed))]
   set delayDelta [expr int((sin($angle) * $dx + cos($angle) *$dy) * 1000.0 / $conf(autoguider,deltaSpeed))]

   #--- calcul des durees minimales de deplacement alpha et delta (en millisecondes)
   set seuilAlpha [expr $conf(autoguider,seuilx) * 1000.0 / $conf(autoguider,alphaSpeed)]
   set seuilDelta [expr $conf(autoguider,seuily) * 1000.0 / $conf(autoguider,deltaSpeed)]

   #--- j'execute le deplacement alpha
   if { $alphaDelay >= 0 && $private(previousAlphaDelay) > 0 } {
      if { $alphaDelay > $seuilAlpha } {
         set private($visuNo,delay,alpha) $alphaDelay
         ::autoguider::moveTelescope $visuNo w $alphaDelay
      } else {
         set private($visuNo,delay,alpha) 0
      }
   } elseif { $alphaDelay < 0 && $private(previousAlphaDelay) < 0 } {
      if { -$alphaDelay > $seuilAlpha } {
         set private($visuNo,delay,alpha) $alphaDelay
         ::autoguider::moveTelescope $visuNo e [expr -$alphaDelay]
      } else {
         set private($visuNo,delay,alpha) 0
      }
   }
   set private(previousAlphaDelay) $alphaDelay

   #--- j'execute le deplacement delta
   if { $conf(autoguider,enableDeclinaison) == 1 } {
      if { $delayDelta >= 0 && $private(previousDeltaDelay) > 0 } {
         if { $delayDelta > $seuilDelta } {
            set private($visuNo,delay,delta) $delayDelta
            ::autoguider::moveTelescope $visuNo n [expr $delayDelta]
         } else {
            set private($visuNo,delay,delta) 0
         }
      } elseif { $delayDelta < 0 && $private(previousDeltaDelay) < 0 } {
         if { -$delayDelta > $seuilDelta } {
            set private($visuNo,delay,delta) $delayDelta
            ::autoguider::moveTelescope $visuNo s [expr -$delayDelta]
         } else {
            set private($visuNo,delay,delta) 0
         }
      }
   } else {
      set private($visuNo,delay,delta) 0
   }

   set private(previousDeltaDelay) $delayDelta
   update
}

#------------------------------------------------------------
# ::autoguider::moveTelescope { }
#   Deplace le telescope pendant un dduree determinee
#   Le deplacement est interrompu si private($visuNo,suiviState)!=0
#
# parametres :
#   visuNo    : numero de la visu courante
#   direction : e w n s
#   delay     : duree du deplacement en milliseconde (nombre entier)
# return
#   rien
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

::autoguider::Init $audace(base)

