#
# Fichier : autoguider.tcl
# Description : Outil d'autoguidage
# Auteur : Michel PUJOL
# Mise a jour $Id: autoguider.tcl,v 1.7 2006-11-10 12:30:13 michelpujol Exp $
#

package provide autoguider 1.0

#==============================================================
#   Declaration du namespace autoguider
#    intialise le namespace 
#==============================================================
namespace eval ::autoguider {
   global audace
   global caption
   global panneau

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

   if { ! [ info exists conf(autoguider,pose) ] }        { set conf(autoguider,pose)       "0" }
   if { ! [ info exists conf(autoguider,binning) ] }     { set conf(autoguider,binning)    [lindex $audace(list_binning) 1] }
   if { ! [ info exists conf(autoguider,intervalle)] }   { set conf(autoguider,intervalle) ".5" }
   if { ! [ info exists conf(autoguider,alphaSpeed)] }   { set conf(autoguider,alphaSpeed) "0.2" }
   if { ! [ info exists conf(autoguider,deltaSpeed)] }   { set conf(autoguider,deltaSpeed) "0.2" }
   if { ! [ info exists conf(autoguider,seuilx)] }       { set conf(autoguider,seuilx) "1" }
   if { ! [ info exists conf(autoguider,seuily)] }       { set conf(autoguider,seuily) "1" }
   if { ! [ info exists conf(autoguider,detection)] }    { set conf(autoguider,detection) "PSF" }
   if { ! [ info exists conf(autoguider,learn,delay)] }  { set conf(autoguider,learn,delay) "2" }
   if { ! [ info exists conf(autoguider,angle)] }        { set conf(autoguider,angle) "0" }
   if { ! [ info exists conf(autoguider,originCoord)] }  { set conf(autoguider,originCoord) "" }
   if { ! [ info exists conf(autoguider,showTarget)] }   { set conf(autoguider,showTarget) "1" }

   set private($visuNo,base)    $in
   set private($visuNo,This)    "$in.autoguider"
   set private($visuNo,hCanvas) [::confVisu::getCanvas $visuNo]
   set private($visuNo,mode)    "image"

   set private($visuNo,pose)          $conf(autoguider,pose)
   set private($visuNo,binning)       $conf(autoguider,binning)
   set private($visuNo,intervalle)    $conf(autoguider,intervalle)
   set private($visuNo,monture_ok)    "0"
   set private($visuNo,suiviState) "0"
   set private($visuNo,status)        ""
   set private($visuNo,showImage)     "1"
   set private($visuNo,showTarget)    "1"
   set private($visuNo,x0)                 "0.00"
   set private($visuNo,y0)                 "0.00"
   set private($visuNo,x)                  "0.00"
   set private($visuNo,y)                  "0.00"
   set private($visuNo,dx)                 "0.00"
   set private($visuNo,dy)                 "0.00"
   set private($visuNo,delay,alpha)        "0.00"
   set private($visuNo,delay,delta)        "0.00"
   set private($visuNo,targetCoordCanvas)  ""
   set private($visuNo,targetCoordPicture) ""
   set private($visuNo,targetBoxPicture)   ""
   set private($visuNo,hTarget)            ""
   set private($visuNo,interval)           ""
   set private($visuNo,previousClock)      "0"
   set private($visuNo,showAlphaDeltaAxis) "1"
   set private($visuNo,deltaAxis)          ""
   set private($visuNo,alphaAxis)          ""
   set private($visuNo,updateAxis)         "0"

   createPanel $visuNo
   adaptPanel  $visuNo
}

#------------------------------------------------------------
# ::autoguider::createPanel
#    cree la fenetre de la nouvelle instance de l'outil
# 
#------------------------------------------------------------
proc ::autoguider::createPanel { visuNo } {
   variable private
   global caption
   global panneau
   global audace
   global conf

   #---
   set panneau(menu_name,autoguider) "$caption(autoguider,menu)"

   #--- Petit raccourci bien pratique
   set This $private($visuNo,This)

   #--- Cadre de l'outil
   frame $private($visuNo,This) -borderwidth 2 -relief groove

   #--- Cadre du titre de l'outil
   frame $private($visuNo,This).titre -borderwidth 2 -relief groove
      Button $private($visuNo,This).titre.but -borderwidth 1 -text $caption(autoguider,titre) \
        -command {
           ::audace::showHelpPlugin tool autoguider autoguider.htm
        }
      pack $private($visuNo,This).titre.but -side top -fill x 
      DynamicHelp::add $private($visuNo,This).titre.but -text $caption(autoguider,help_titre)
   pack $private($visuNo,This).titre -side top -fill x -expand true

   #--- Cadre du temps de pose
   frame $This.pose -borderwidth 2 -relief ridge
      label $This.pose.lab1 -text "$caption(autoguider,pose)"
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.pose.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::autoguider::private($visuNo,pose) \
         -values $list_combobox
      button $This.pose.confwebcam -text $caption(autoguider,pose) \
         -command "::autoguider::webcamConfigure $visuNo"

   pack $This.pose -anchor center -fill x -expand 1

   #--- Cadre du binning
   frame $This.binning -borderwidth 2 -relief ridge
      label $This.binning.lab1 -text "$caption(autoguider,binning)"
      set list_combobox $audace(list_binning)
      ComboBox $This.binning.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -textvariable ::autoguider::private($visuNo,binning) \
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
         -textvariable ::autoguider::private($visuNo,intervalle) \
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
      button $This.go_stop.but -text $caption(autoguider,GO) -height 2 \
        -font $audace(font,arial_12_b) -borderwidth 3 -pady 6 -command "::autoguider::startSuivi $visuNo"
      pack $This.go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $This.go_stop -anchor center -fill x -expand true

   #--- Frame pour l'autoguidage
   frame $This.suivi -borderwidth 2 -relief ridge 
       checkbutton $This.suivi.but_autovisu -text "image" \
          -variable ::autoguider::private($visuNo,showImage) \
          -command "::autoguider::changeShowImage $visuNo"
       checkbutton $This.suivi.but_showtarget -text "cible" \
          -variable ::autoguider::private($visuNo,showTarget) \
          -command "::autoguider::changeShowTarget $visuNo"
       checkbutton $This.suivi.but_showaxis -text "axes AD" \
          -variable ::autoguider::private($visuNo,showAlphaDeltaAxis) \
          -command "::autoguider::showAlphaDeltaAxis $visuNo"
       checkbutton $This.suivi.moteur_ok -padx 0 -pady 0 \
          -text "$caption(autoguider,ctrl_monture)" \
          -variable ::autoguider::private($visuNo,monture_ok) -command {  }
       label $This.suivi.label_d      -text "$caption(autoguider,ecart_origine_etoile)"
       label $This.suivi.dx           -textvariable ::autoguider::private($visuNo,dx)
       label $This.suivi.dy           -textvariable ::autoguider::private($visuNo,dy)
       label $This.suivi.delay_alpha  -textvariable ::autoguider::private($visuNo,delay,alpha)
       label $This.suivi.delay_delta  -textvariable ::autoguider::private($visuNo,delay,delta)
       label $This.suivi.lab_clock    -textvariable ::autoguider::private($visuNo,interval)
       button $This.suivi.but_config -text "$caption(autoguider,config_guidage)" \
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
#    initialise le namespace visu
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
#    adapte l'affichage en fonction de la camera
# 
#------------------------------------------------------------
proc ::autoguider::adaptPanel { visuNo { command "" } { varname1 "" } { varname2 "" } } {
   variable private
   global conf

   set This $private($visuNo,This)
   set camNo [::confVisu::getCamNo $visuNo ] 
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
         set private($visuNo,pose) "0"
      }
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
   global conf

   #--- j'affiche la fenetre
   pack $private($visuNo,This) -anchor center -expand 0 -fill y -side top -padx 0

   #--- je change le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::autoguider::setOrigin $visuNo %x %y"

   #--- j'affiche la cible si necessaire
   set private($visuNo,showTarget) $conf(autoguider,showTarget)  
   if { $private($visuNo,showTarget) == "1" } {
      changeShowTarget $visuNo
   }
   
   #--- j'affiche les axes si necessaire
   set private($visuNo,showAlphaDeltaAxis) $conf(autoguider,showAlphaDeltaAxis)  
   if { $private($visuNo,showAlphaDeltaAxis) == "1" } {
      showAlphaDeltaAxis $visuNo
   }
}

#------------------------------------------------------------
# ::autoguider::stopTool
#    masque la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::autoguider::stopTool { { visuNo 1 } } {
   variable private
   global conf

   #--- je masque la fenetre
   pack forget $private($visuNo,This)

   #--- j'arrete le suivi
   stopSuivi $visuNo
   
   #--- je masque la cible
   set conf(autoguider,showTarget)  $private($visuNo,showTarget)
   if { $private($visuNo,showTarget) == "1" } {
      set private($visuNo,showTarget) 0
      changeShowTarget $visuNo
   }
   
   #--- je masque les axes
   set conf(autoguider,showAlphaDeltaAxis)  $private($visuNo,showAlphaDeltaAxis)
   if { $private($visuNo,showAlphaDeltaAxis) == "1" } {
      set private($visuNo,showAlphaDeltaAxis) 0
      showAlphaDeltaAxis $visuNo
   }
   
   #--- je restaure le bind par defaut du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "default"

   set conf(autoguider,pose)       $private($visuNo,pose)
   set conf(autoguider,binning)    $private($visuNo,binning)
}

#------------------------------------------------------------
# ::autoguider::startSuivi
#    lance le suivi
#------------------------------------------------------------
proc ::autoguider::startSuivi { visuNo } {
   variable private
   global caption
   global conf

   #--- Petits raccourcis
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
   
   #--- J'affiche le bouton "STOP" et l'associe à la commande d'arret
   $private($visuNo,This).go_stop.but configure \
      -text $caption(autoguider,STOP) \
      -command "::autoguider::stopSuivi $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::autoguider::stopSuivi  $visuNo"

   #--- je remets a zero la valeur du decalage precedent   
   set private(previousAlphaDelay)      "0"     
   set private(previousDeltaDelay)      "0"     
   set private(delay_alpha)       "0"     
   set private(delay_delta)       "0"     

   #--- je parametre le temps de pose
   cam$camNo exptime $private($visuNo,pose)

   #--- je parametre le binning
   cam$camNo bin [list [string range $private($visuNo,binning) 0 0] [string range $private($visuNo,binning) 2 2]]
      
   #--- j'arrete la mise à jour des coordonnees dans les images , pour gagner du temps
   cam$camNo radecfromtel 0
      
   ::telescope::setSpeed 1
   
   while { $private($visuNo,suiviState) == "1" } {
      #--- je faie une acquisition et j'affiche l'image
      cam$camNo acq
      vwait status_cam$camNo
      if { $private($visuNo,showImage) == "1" } {
         ::confVisu::autovisu $visuNo
      }
      #--- je mets a jour l'axes si necessaire
      if { $private($visuNo,updateAxis) == 1 } {
         updateAlphaDeltaAxis $visuNo $conf(autoguider,originCoord) $conf(autoguider,angle)
         set private($visuNo,updateAxis) 0
      }

      #--- je calcule la position de l'etoile guide
      if { $private($visuNo,targetBoxPicture) != "" } {
         set centro [buf$bufNo centro "$private($visuNo,targetBoxPicture)" ]

         set private($visuNo,x) [format "%##0.1f" [lindex $centro 0]]
         set private($visuNo,y) [format "%##0.1f" [lindex $centro 1]]

         #--- je calcule l'ecart de position par rapport à la position origine
         set private($visuNo,dx) [format "%##0.1f" [expr $private($visuNo,x) - $private($visuNo,x0) ]]
         set private($visuNo,dy) [format "%##0.1f" [expr $private($visuNo,y) - $private($visuNo,y0) ]]

         #--- j'affiche le symbole de la cible 
         if { $private($visuNo,showTarget) == "1" } {
            moveTarget $visuNo $centro
         }

         #--- je calcule la position de la boite autour de la nouvelle position
         set size 16
         set x  $private($visuNo,x)
         set y  $private($visuNo,y)
         set x1 [expr int($x) - $size]
         set x2 [expr int($x) + $size]
         set y1 [expr int($y) - $size]
         set y2 [expr int($y) + $size]
         set private($visuNo,targetBoxPicture) [list $x1 $y1 $x2 $y2]

      }
      
      #--- je calcule le temps ecoule entre deux fins de pose
      set nextClock [clock clicks -milliseconds ]
      set private($visuNo,interval) "[expr $nextClock - $private($visuNo,previousClock)] ms"
      set private($visuNo,previousClock) $nextClock 
      update

      if { $private($visuNo,monture_ok) == 1 && $private($visuNo,suiviState) == "1" } {
         set private($visuNo,status) "Maj suivi"
         ::autoguider::updateTelescope $visuNo $private($visuNo,dx) $private($visuNo,dy)
      }

      #--- Appel du timer
      set private($visuNo,status) ""
      if { $conf(autoguider,intervalle) > 0 && $private($visuNo,suiviState) == "1"} {
         after [expr int($conf(autoguider,intervalle) * 1000) ]
      }
   }

   #--- j'arrete le suivi
   set private($visuNo,status) ""
   
   #--- j'active le bouton GO et associe la commande demarrage
   $private($visuNo,This).go_stop.but configure \
      -text $caption(autoguider,GO) \
      -command "::autoguider::startSuivi $visuNo"
   #--- je supprime l'association du bouton escape
   bind all <Key-Escape> ""

   set private($visuNo,suiviState) 0   

}

#------------------------------------------------------------
# ::autoguider::stopSuivi
#    lance les acquisitions
# 
#------------------------------------------------------------
proc ::autoguider::stopSuivi { visuNo } {
   variable private 

   #--- si le suivi est en cours , je demande l'arret
   if { $private($visuNo,suiviState)  == 1 } {
      set private($visuNo,suiviState) 2
   }
}


#------------------------------------------------------------
# ::autoguider::setOrigin
#    initialise le point origine x0, y0
# 
#------------------------------------------------------------
proc ::autoguider::setOrigin { visuNo x y } {
   variable private
   global audace
   global conf

   #--- petits raccourcis pour se simplier le codage
   set zoom [visu$visuNo zoom]
   set bufNo [visu$visuNo buf]

   #--- 
   if { [buf$bufNo imageready] == 0 } {
      return
   }
   
   set width  [buf$bufNo getpixelswidth]
   set height [buf$bufNo getpixelsheight]

   #--- je supprime l'affichage precedent de la cible
   if { $private($visuNo,alphaAxis) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,alphaAxis)
      set private($visuNo,alphaAxis) ""
   }
   if { $private($visuNo,deltaAxis) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,deltaAxis)
      set private($visuNo,deltaAxis) ""
   }

   #--- je calcule les coordonnées de la zone de recherche de l'etoile
   set coord [::confVisu::screen2Canvas $visuNo [list $x $y]]
   set coord [::confVisu::canvas2Picture $visuNo $coord]
   
   #--- je recherche la nouvelle position de l'etoile dans la zone
   set size 16
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set x1 [expr $x - $size]
   set x2 [expr $x + $size]
   set y1 [expr $y - $size]
   set y2 [expr $y + $size]
   set centro [buf$bufNo centro [list $x1 $y1 $x2 $y2] ]
   set private($visuNo,x0) [lindex $centro 0]
   set private($visuNo,y0) [lindex $centro 1]
   set conf(autoguider,originCoord) $centro

   #--- je calcule la position du la nouvelle zone cible centrée sur l'etoile
   set x  [lindex $centro 0]
   set y  [lindex $centro 1]
   set x1 [expr int($x) - $size]
   set x2 [expr int($x) + $size]
   set y1 [expr int($y) - $size]
   set y2 [expr int($y) + $size]
   set private($visuNo,targetBoxPicture) [list $x1 $y1 $x2 $y2]

   #--- je dessine la boite autour de l'étoile
   updateAlphaDeltaAxis $visuNo $conf(autoguider,originCoord) $conf(autoguider,angle)

}

#------------------------------------------------------------
# ::autoguider::createTarget
#    
#  
#   targetCoord : coordonnées de la cible dans l'image
#------------------------------------------------------------
proc ::autoguider::createTarget { visuNo targetCoord } {
   variable private

   #--- je supprime l'affichage precedent de la cible
   deleteTarget $visuNo
   set private($visuNo,targetCoordPicture) $targetCoord

   #--- je calcule les coordonnees dans l'image
   set size 16
   set x  [lindex $targetCoord 0]
   set y  [lindex $targetCoord 1]
   set x1 [expr int($x) - $size]
   set x2 [expr int($x) + $size]
   set y1 [expr int($y) - $size]
   set y2 [expr int($y) + $size]
   set private($visuNo,targetBoxPicture) [list $x1 $y1 $x2 $y2]

   #--- je calcule les coordonnées dans le canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set x1 [lindex $coord 0]
   set y1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set x2 [lindex $coord 0]
   set y2 [lindex $coord 1]

   set private($visuNo,hTarget) [eval {$private($visuNo,hCanvas) create rect} $x1 $y1 $x2 $y2 -outline red -offset center -tag target]

   #--- je memorise les coordonnees de la cible dans le canvas
   set private($visuNo,targetCoordCanvas) [list $x $y]
}

#------------------------------------------------------------
# ::autoguider::deleteTarget
#  
#  
#   targetCoord : coordonnées de la cible dans l'image
#------------------------------------------------------------
proc ::autoguider::deleteTarget { visuNo } {
   variable private

   #--- je supprime la cible
   if { $private($visuNo,hTarget) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,hTarget)
      set private($visuNo,hTarget) ""
      $private($visuNo,hCanvas) dtag target
   }
}

#------------------------------------------------------------
# ::autoguider::moveTarget
#    
#   targetCoord : coordonnées de la cible (referentiel buffer)
#------------------------------------------------------------
proc ::autoguider::moveTarget { visuNo targetCoord } {
   variable private

   #--- je cree la cible si elle n'existe pas
   if { $private($visuNo,hTarget) == "" } {
      createTarget $visuNo $targetCoord
   }

   #--- je convertis les coordonnes image en coordonnées canvas
   set coord [::confVisu::picture2Canvas $visuNo [list $private($visuNo,x) $private($visuNo,y)] ] 

   #--- je calcule le deplacement dans le canvas
   set dx [expr [lindex $coord 0] - [lindex $private($visuNo,targetCoordCanvas) 0]]
   set dy [expr [lindex $coord 1] - [lindex $private($visuNo,targetCoordCanvas) 1]]

   #--- je deplace la cible le deplacement en coordonnées dans le canvas
   $private($visuNo,hCanvas) move target $dx $dy

   #--- je memorise les coordonnees de la cible dans le canvas
   set private($visuNo,targetCoordCanvas) $coord

}

#------------------------------------------------------------
# ::autoguider::updateAlphaDeltaAxis
#    dessine les axes alpha et delta 
# 
#------------------------------------------------------------
proc ::autoguider::updateAlphaDeltaAxis { visuNo coord angle} {
   variable private

   #--- je supprime les axes qui existent deja
   $private($visuNo,hCanvas) delete axis

   #--- je dessine l'axe alpha
   drawAxis $visuNo $coord $angle "Est" "West"
   #--- je dessine l'axe delta
   drawAxis $visuNo $coord [expr $angle+90] "South" "North"
}

#------------------------------------------------------------
# ::autoguider::drawAxis
#    dessine un axe
# 
#------------------------------------------------------------
proc ::autoguider::drawAxis { visuNo coord angle label1 label2} {
   variable private 

   if { $private($visuNo,showAlphaDeltaAxis) == "0" } {
      set state "hidden"
   } else {
      set state "normal"
   }

   set bufNo [::confVisu::getBufNo $visuNo ]
   
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
   #--- je trace l'axe et les nom des extremités
   set private($visuNo,deltaAxis) [$private($visuNo,hCanvas) create line [lindex $coord1 0] [lindex $coord1 1] [lindex $coord2 0] [lindex $coord2 1] -fill $::audace(color,drag_rectangle) -tag axis -state $state]
   $private($visuNo,hCanvas) create text [lindex $coord1 0] [lindex $coord1 1] -text $label1 -tag axis  -state $state -fill $::audace(color,drag_rectangle)
   $private($visuNo,hCanvas) create text [lindex $coord2 0] [lindex $coord2 1] -text $label2 -tag axis  -state $state -fill $::audace(color,drag_rectangle)
}

#------------------------------------------------------------
# ::autoguider::showAlphaDeltaAxis
#    affiche/cache les axes alpha et delta centrés sur l'origine
# 
#------------------------------------------------------------
proc ::autoguider::showAlphaDeltaAxis { visuNo } {
   variable private

   #--- toggle display
   if { $private($visuNo,showAlphaDeltaAxis) == "1" } {
      #--- show axis         
      $private($visuNo,hCanvas) itemconfigure axis -state normal
   } else {
      #--- show axis         
      $private($visuNo,hCanvas) itemconfigure axis -state hidden
   }
}
#------------------------------------------------------------
# ::autoguider::changeShowImage
#    si showImage==0 , efface l'image
#    si showImage==0 , ne fait rien , l'image sera affiche apres la prochaine acquisition
# 
#------------------------------------------------------------
proc ::autoguider::changeShowImage { visuNo } {
   variable private

   if { $private($visuNo,showImage) == "0" } {
      #--- je met tous les pixels a zero
      ###set bufNo [::confVisu::getBufNo $visuNo]
      ###if { [buf$bufNo imageready] == 1 } {
      ####   buf$bufNo mult 0
      ###   visu$visuNo cut {32 1}
      ###   visu$visuNo disp
      ###}
      visu$visuNo clear
   }
}

#------------------------------------------------------------
# ::autoguider::changeShowTarget
#    si showTarget==0 , efface le symbole de la cible 
#    si showTarget==1 , ne fait rien , la cible sera affichee apres la prochaine acquistion
#------------------------------------------------------------
proc ::autoguider::changeShowTarget { visuNo } {
   variable private

   if { $private($visuNo,showTarget) == "0" } {
      deleteTarget $visuNo
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
   global caption 

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
         
     }
     "1" {
         set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] videoformat } ]
         if { $result == "1" } {
            if { [ ::confVisu::getCamera $visuNo ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                     -message $caption(acqfc,selcam) ]
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
   
   #--- je position l'indicateur qui doit mettre à jour les axes 
   #--- a la prochaine acquisition
   set private($visuNo,updateAxis) "1"
}

#------------------------------------------------------------
# ::autoguider::updateTelescope
#    deplace le telescope
#   de
#------------------------------------------------------------
proc ::autoguider::updateTelescope { visuNo dx dy } {
   variable private 
   global conf

   $private($visuNo,This).suivi.dx configure -text $dx
   $private($visuNo,This).suivi.dx configure -text $dy

   set angle [expr $conf(autoguider,angle)* 3.14159265359/180 ]
   #--- je calcule les delais en milliseconde
   set alphaDelay [expr int((cos($angle) * $dx - sin($angle) *$dy) * 1000.0 / $conf(autoguider,alphaSpeed))]
   set delayDelta [expr int((sin($angle) * $dx + cos($angle) *$dy) * 1000.0 / $conf(autoguider,deltaSpeed))]
   #set alphaDelay [expr int($dx * 1000.0 / $conf(autoguider,alphaSpeed))]
   #set delayDelta [expr int($dy * 1000.0 / $conf(autoguider,deltaSpeed))]
   
   set seuilAlpha [expr $conf(autoguider,seuilx) * 1000.0 / $conf(autoguider,alphaSpeed)]
   set seuilDelta [expr $conf(autoguider,seuily) * 1000.0 / $conf(autoguider,deltaSpeed)]

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
   set private(previousDeltaDelay) $delayDelta
   update   
}

#------------------------------------------------------------
# ::autoguider::moveTelescope { }
#   deplace le telescope 
# parametres : 
#   visuNo    : numero de la visu courante
#   direction : e w n s
#   delay     : duree du deplacement en milliseconde , nombre entier
# return 
#------------------------------------------------------------
proc ::autoguider::moveTelescope { visuNo direction delay} {
   variable private

   #--- laisse la main pour traiter une eventuelle demande d'arret 
   update

   #--- je demarre le deplacement
   ##::telescope::move $direction 
   tel$::audace(telNo) radec move $direction

   #--- j'attend l'expiration du delai par tranche de 1 seconde 
   while { $delay  > 0 } {
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

