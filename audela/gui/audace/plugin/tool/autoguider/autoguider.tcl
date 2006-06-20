#
# Fichier : autoguider.tcl
# Description : Outil d'autoguidage
# Auteur : Michel PUJOL
# Mise a jour $Id: autoguider.tcl,v 1.5 2006-06-20 20:49:45 robertdelmas Exp $
#

package provide autoguider 1.0

#==============================================================
#   Declaration du namespace Autoguider
#    intialise le namespace 
#==============================================================
namespace eval ::Autoguider {
   global audace
   global caption
   global panneau

   source [ file join $audace(rep_plugin) tool autoguider autoguider.cap ]
   source [ file join $audace(rep_plugin) tool autoguider agUNIV.tcl ]
   set panneau(menu_name,Autoguider) "$caption(autoguider,menu)"
}

#------------------------------------------------------------
# ::Autoguider::Init
#    cree une nouvelle instance de l'outil
# 
#------------------------------------------------------------
proc ::Autoguider::Init { { in "" } { visuNo 1 } } {
   variable private
   global audace conf

   if { ! [ info exists conf(Autoguider,pose) ] }      { set conf(Autoguider,pose)       "0" }
   if { ! [ info exists conf(Autoguider,binning) ] }   { set conf(Autoguider,binning)    [lindex $audace(list_binning) 1] }
   if { ! [ info exists conf(Autoguider,intervalle)] } { set conf(Autoguider,intervalle) ".5" }

   set private($visuNo,base)    $in
   set private($visuNo,This)    "$in.autoguider"
   set private($visuNo,hCanvas) [::confVisu::getCanvas $visuNo]
   set private($visuNo,mode)    "image"

   set private($visuNo,pose)          $conf(Autoguider,pose)
   set private($visuNo,binning)       $conf(Autoguider,binning)
   set private($visuNo,intervalle)    $conf(Autoguider,intervalle)
   set private($visuNo,monture_ok)    "0"
   set private($visuNo,demande_arret) "0"
   set private($visuNo,status)        ""
   set private($visuNo,go_stop)       "go"
   set private($visuNo,showImage)     "1"
   set private($visuNo,showTarget)    "1"

   set private($visuNo,x0)                 "0.00"
   set private($visuNo,y0)                 "0.00"
   set private($visuNo,x)                  "0.00"
   set private($visuNo,y)                  "0.00"
   set private($visuNo,dx)                 "0.00"
   set private($visuNo,dy)                 "0.00"
   set private($visuNo,originCoordPicture) ""
   set private($visuNo,targetCoordCanvas)  ""
   set private($visuNo,targetCoordPicture) ""
   set private($visuNo,targetBoxPicture)   ""
   set private($visuNo,lineH)              ""
   set private($visuNo,lineV)              ""
   set private($visuNo,targetH)            ""
   set private($visuNo,targetV)            ""
   set private($visuNo,target_box)         ""
   set private($visuNo,hTarget)            ""
   set private($visuNo,interval)           ""
   set private($visuNo,previousClock)      "0"

   createPanel $visuNo
   adaptPanel  $visuNo
}

#------------------------------------------------------------
# ::Autoguider::createPanel
#    cree la fenetre de la nouvelle instance de l'outil
# 
#------------------------------------------------------------
proc ::Autoguider::createPanel { visuNo } {
   variable private
   global caption
   global panneau
   global audace

   #---
   set panneau(menu_name,Autoguider) "$caption(autoguider,menu)"

   #--- Petit raccourci bien pratique
   set This $private($visuNo,This)

   #--- Trame de l'outil
   frame $private($visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre de l'outil
   frame $private($visuNo,This).titre -borderwidth 2 -relief groove
      Button $private($visuNo,This).titre.but -borderwidth 1 -text $caption(autoguider,titre) \
        -command {
           ::audace::showHelpPlugin tool autoguider autoguider.htm
        }
      pack $private($visuNo,This).titre.but -side top -fill x 
      DynamicHelp::add $private($visuNo,This).titre.but -text $caption(autoguider,help_titre)
   pack $private($visuNo,This).titre -side top -fill x -expand true

   #--- Trame du temps de pose
   frame $This.pose -borderwidth 2 -relief ridge
      label $This.pose.lab1 -text "$caption(autoguider,pose)"
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.pose.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::Autoguider::private($visuNo,pose) \
         -values $list_combobox

      button $This.pose.confwebcam -text $caption(autoguider,pose) \
         -command "::Autoguider::webcamConfigure $visuNo"

      ###pack $This.pose.lab1 -anchor center -side left -padx 5
      ###pack $This.pose.combo -anchor center -side left -fill x -expand 1
   pack $This.pose -anchor center -fill x -expand 1

   #--- Trame du binning
   frame $This.binning -borderwidth 2 -relief ridge
      label $This.binning.lab1 -text "$caption(autoguider,binning)"
      set list_combobox $audace(list_binning)
      ComboBox $This.binning.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 0 \
         -textvariable ::Autoguider::private($visuNo,binning) \
         -values $list_combobox

      button $This.binning.selectFormat -text "$caption(autoguider,binning)" \
         -command "::Autoguider::webcamSelectFormat $visuNo"

   pack $This.binning -anchor center -fill x -expand true

   #--- Trame de l'intervalle
   frame $This.intervalle -borderwidth 2 -relief ridge
      label $This.intervalle.lab1 -text "$caption(autoguider,intervalle)"
      pack $This.intervalle.lab1 -anchor center -side left -padx 5
      set list_combobox {0 0.1 0.3 0.5 1 2 3 5 10}
      ComboBox $This.intervalle.combo \
         -width 4 -height [ llength $list_combobox ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::Autoguider::private($visuNo,intervalle) \
         -values $list_combobox
      pack $This.intervalle.combo -anchor center -side left -fill x -expand 1
   pack $This.intervalle -anchor center -fill x -expand 1

   #--- Trame du Status
   frame $This.status -borderwidth 2 -relief ridge
      label $This.status.lab -textvariable ::Autoguider::private($visuNo,status) \
         -font $audace(font,arial_10_b) -relief ridge -justify center -width 2
      pack $This.status.lab -side top -fill x -expand true -pady 1
   pack $This.status -anchor center -fill x -expand true

   #--- Trame du bouton Go/Stop
   frame $This.go_stop -borderwidth 2 -relief ridge
      button $This.go_stop.but -text $caption(autoguider,GO) -height 2 \
        -font $audace(font,arial_12_b) -borderwidth 3 -pady 6 -command "::Autoguider::goStop $visuNo"
      pack $This.go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $This.go_stop -anchor center -fill x -expand true

   #--- Frame pour l'autoguidage
   frame $This.suivi -borderwidth 2 -relief ridge 
       button $This.suivi.but_config -text "$caption(autoguider,config_guidage)" \
          -command "run_config_autoguidage $visuNo"
       ####button $This.suivi.but_init -text "$caption(autoguider,init_position)" \
       ####   -command "::autoguider::setOrigin $visuNo %x %y"
       checkbutton $This.suivi.but_autovisu -text "image" \
          -variable ::Autoguider::private($visuNo,showImage) \
          -command "::Autoguider::changeShowImage $visuNo"
       checkbutton $This.suivi.but_showtarget -text "cible" \
          -variable ::Autoguider::private($visuNo,showTarget) \
          -command "::Autoguider::changeShowTarget $visuNo"
       checkbutton $This.suivi.moteur_ok -padx 0 -pady 0 \
          -text "$caption(autoguider,ctrl_monture)" \
          -variable ::Autoguider::private($visuNo,monture_ok) -command {  }
       label $This.suivi.label_x0  -text "$caption(autoguider,coord_origine)"
       label $This.suivi.label_x   -text "$caption(autoguider,coord_etoile)"
       label $This.suivi.label_d   -text "$caption(autoguider,ecart_origine_etoile)"
       label $This.suivi.x0        -textvariable ::Autoguider::private($visuNo,x0)
       label $This.suivi.y0        -textvariable ::Autoguider::private($visuNo,y0)
       label $This.suivi.x         -textvariable ::Autoguider::private($visuNo,x)
       label $This.suivi.y         -textvariable ::Autoguider::private($visuNo,y)
       label $This.suivi.dx        -textvariable ::Autoguider::private($visuNo,dx)
       label $This.suivi.dy        -textvariable ::Autoguider::private($visuNo,dy)
       label $This.suivi.lab_clock -textvariable ::Autoguider::private($visuNo,interval)

       ###grid $This.suivi.but_init  -row 0 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.but_autovisu   -row 0 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.but_showtarget -row 1 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.moteur_ok      -row 2 -column 0 -columnspan 3 -sticky {}
       grid $This.suivi.label_x0       -row 3 -column 0 -sticky w
       grid $This.suivi.x0             -row 3 -column 1 -sticky w
       grid $This.suivi.y0             -row 3 -column 2 -sticky w
       grid $This.suivi.label_x        -row 4 -column 0 -sticky w
       grid $This.suivi.x              -row 4 -column 1 -sticky w
       grid $This.suivi.y              -row 4 -column 2 -sticky w
       grid $This.suivi.label_d        -row 5 -column 0 -sticky w
       grid $This.suivi.dx             -row 5 -column 1 -sticky w
       grid $This.suivi.dy             -row 5 -column 2 -sticky w
       grid $This.suivi.lab_clock      -row 6 -column 0 -columnspan 3
       grid $This.suivi.but_config     -row 7 -column 0 -columnspan 3
   pack $This.suivi -anchor center -fill x -expand true 

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private($visuNo,This)

   #--- j'active la mise ajour automatique de l'affichage en fonction de la camera
   ::confVisu::addCameraListener $visuNo "::Autoguider::adaptPanel $visuNo"
}

#------------------------------------------------------------
# ::Autoguider::deletePanel
#    initialise le namespace visu
# 
#------------------------------------------------------------
proc ::Autoguider::deletePanel { visuNo } {
   variable private


   #--- je desactive l'adaptation de l'affichage
   ::confVisu::removeCameraListener $visuNo "::Autoguider::adaptPanel $visuNo"

   destroy $private($visuNo,This)

}

#------------------------------------------------------------
# ::Autoguider::adaptPanel
#    adapte l'affichage en fonction de la camera
# 
#------------------------------------------------------------
proc ::Autoguider::adaptPanel { visuNo { command "" } { varname1 "" } { varname2 "" } } {
   variable private
   global conf

   set This $private($visuNo,This)
   set camNo [::confVisu::getCamNo $visuNo ] 
   set panelFormat "0"
   
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
      0 {
         pack $This.pose.lab1 -anchor center -side left -padx 5
         pack $This.pose.combo -anchor center -side left -fill x -expand 1
         pack $This.binning.lab1 -anchor center -side left -padx 0
         pack $This.binning.combo -anchor center -side left -fill x -expand true
         pack forget $This.pose.confwebcam
         pack forget $This.binning.selectFormat
      } 
      1 {
         pack forget $This.pose.lab1
         pack forget $This.pose.combo
         pack forget $This.binning.lab1
         pack forget $This.binning.combo
         pack $This.pose.confwebcam -anchor center -side left -fill x -expand 1
         pack $This.binning.selectFormat  -anchor center -side left -fill x -expand 1
      }
   }
   
}

#------------------------------------------------------------
# ::Autoguider::startTool
#    affiche la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::Autoguider::startTool { { visuNo 1 } } {
   variable private
   global conf

   #--- j'affiche la fenetre
   pack $private($visuNo,This) -anchor center -expand 0 -fill y -side top -padx 0

   #--- je change le bind du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "::Autoguider::setOrigin $visuNo %x %y"

   set conf(Autoguider,pose)       $private($visuNo,pose)
   set conf(Autoguider,binning)    $private($visuNo,binning)
   set conf(Autoguider,intervalle) $private($visuNo,intervalle)
}

#------------------------------------------------------------
# ::Autoguider::stopTool
#    masque la fenetre de l'outil
# 
#------------------------------------------------------------
proc ::Autoguider::stopTool { { visuNo 1 } } {
   variable private

   #--- je masque la fenetre
   pack forget $private($visuNo,This)

   #--- je restaure le bind par defaut du bouton droit de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-3> "default"

}

#------------------------------------------------------------
# ::Autoguider::goStop
#    lance/arrete les acquisitions
# 
#------------------------------------------------------------
proc ::Autoguider::goStop { visuNo } {
   variable private 
   global audace

   if { $private($visuNo,demande_arret)  == 0 } {
      switch $private($visuNo,go_stop) {
         go {
            set camNo [::confVisu::getCamNo $visuNo ]
            if { $camNo == 0 } {
               ::confCam::run
               tkwait window $audace(base).confCam
               return
            }

            set private($visuNo,go_stop) "stop"
            bind all <Key-Escape> "::Autoguider::goStop $visuNo"
            #--- je lance les acquisitions
            ::Autoguider::acq $visuNo
         }
         stop {
            set private($visuNo,demande_arret) 1
            set private($visuNo,go_stop) "go"
            bind all <Key-Escape> ""
         }
      }
   }
}

#------------------------------------------------------------
# ::Autoguider::goStop
#    lance/arrete les acquisitions
# 
#------------------------------------------------------------
proc ::Autoguider::acq { visuNo } {
   variable private
   global caption
   global conf

   #--- Petits raccourcis
   set camNo [::confVisu::getCamNo $visuNo ]
   set bufNo [::confVisu::getBufNo $visuNo ]
   set camName [::confVisu::getCamera $visuNo ]

   #--- J'autorise le bouton "STOP"
   $private($visuNo,This).go_stop.but configure -state normal -text $caption(autoguider,STOP)

   #---
   #set private($visuNo,x0) 
   #set private($visuNo,y0)

      #--- La commande exptime permet de fixer le temps de pose de l'image
      cam$camNo exptime $private($visuNo,pose)

      #--- La commande bin permet de fixer le binning
      cam$camNo bin [list [string range $private($visuNo,binning) 0 0] [string range $private($visuNo,binning) 2 2]]
      
   while { $private($visuNo,demande_arret) == "0" } {

      #--- Declenchement l'acquisition
      cam$camNo acq

      #--- Attente de la fin de la pose
      vwait status_cam$camNo

      #--- j'affiche l'image
      if { $private($visuNo,showImage) == "1" } {
         ::confVisu::autovisu $visuNo
      }

      #--- je calcule la poisition de l'etoile guide
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
      set nextClock [clock clicks -milliseconds ]
      set private($visuNo,interval) "[expr $nextClock - $private($visuNo,previousClock)] ms"
      set private($visuNo,previousClock) $nextClock 
      update

      if { $private($visuNo,monture_ok) == 1 } {
         set private($visuNo,status) "Maj suivi"
         ::agUNIV::suivi $private($visuNo,dx) $private($visuNo,dy)
      }
      
      #--- Appel du timer
      set private($visuNo,status) ""
      if { $private($visuNo,intervalle) > 0 } {
         after [expr int($private($visuNo,intervalle) * 1000) ]
      }

   }

   #--- je traite la demande d'arret
   set private($visuNo,status) ""
   set private($visuNo,demande_arret) 0

   #--- j'active le bouton GO
   $private($visuNo,This).go_stop.but configure -state normal -text $caption(autoguider,GO)
}

#------------------------------------------------------------
# ::Autoguider::setOrigin
#    initialise le point origine x0, y0
# 
#------------------------------------------------------------
proc ::Autoguider::setOrigin { visuNo x y } {
   variable private
   global audace

   #--- petits raccourcis pour se simplier le codage
   set zoom [visu$visuNo zoom]
   set bufNo [visu$visuNo buf]
   set width  [lindex [buf$bufNo getkwd NAXIS1] 1]
   set height [lindex [buf$bufNo getkwd NAXIS1] 1]

   #--- je supprime l'affichage precedent de la cible
   if { $private($visuNo,lineH) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,lineH)
      set private($visuNo,lineH) ""
   }
   if { $private($visuNo,lineV) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,lineV)
      set private($visuNo,lineV) ""
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
   set private($visuNo,originCoordPicture) $centro

   #--- je calcule la position du la nouvelle zone de recherche centree sur l'etoile
   set x  [lindex $centro 0]
   set y  [lindex $centro 1]
   set x1 [expr int($x) - $size]
   set x2 [expr int($x) + $size]
   set y1 [expr int($y) - $size]
   set y2 [expr int($y) + $size]
   set private($visuNo,targetBoxPicture) [list $x1 $y1 $x2 $y2]

   #--- je dessine la boite autour de l'étoile
   set coord [::confVisu::picture2Canvas $visuNo [list $x $y ]]
   set x  [lindex $coord 0]
   set y  [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x1 $y1 ]]
   set x1 [lindex $coord 0]
   set y1 [lindex $coord 1]
   set coord [::confVisu::picture2Canvas $visuNo [list $x2 $y2 ]]
   set x2 [lindex $coord 0]
   set y2 [lindex $coord 1]

   set private($visuNo,lineH) [$private($visuNo,hCanvas) create line  $x1 $y  $x2 $y  -fill $audace(color,drag_rectangle) -tag lineH]
   set private($visuNo,lineV) [$private($visuNo,hCanvas) create line  $x  $y1 $x  $y2 -fill $audace(color,drag_rectangle) -tag lineV]

}

#------------------------------------------------------------
# ::Autoguider::createTarget
#    
#  
#   targetCoord : coordonnées de la cible dans l'image
#------------------------------------------------------------
proc ::Autoguider::createTarget { visuNo targetCoord } {
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
# ::Autoguider::deleteTarget
#  
#  
#   targetCoord : coordonnées de la cible dans l'image
#------------------------------------------------------------
proc ::Autoguider::deleteTarget { visuNo } {
   variable private

   #--- je supprime la cible
   if { $private($visuNo,hTarget) != "" } {
      $private($visuNo,hCanvas) delete $private($visuNo,hTarget)
      set private($visuNo,hTarget) ""
      $private($visuNo,hCanvas) dtag target
   }
}

#------------------------------------------------------------
# ::Autoguider::moveTarget
#    
#   targetCoord : coordonnées de la cible dans l'image
#------------------------------------------------------------
proc ::Autoguider::moveTarget { visuNo targetCoord } {
   variable private

   #--- je cree la cible si elle n'existe pas
   if { $private($visuNo,hTarget) == "" } {
      createTarget $visuNo $targetCoord
   }

   #--- je calcule les coordonnees dans l'image
      
   #--- je convertis les coordonnes image en coordonnées canvas
   #set coord [::confVisu::picture2Canvas $visuNo $targetCoord ]
   set coord [::confVisu::picture2Canvas $visuNo [list $private($visuNo,x) $private($visuNo,y)] ] 

   #--- je calcule le deplacement dans le canvas
   #set private($visuNo,dx) [expr [lindex $coord 0] - [lindex $private($visuNo,targetCoordCanvas) 0]]
   #set private($visuNo,dy) [expr [lindex $coord 1] - [lindex $private($visuNo,targetCoordCanvas) 1]]

   set dx [expr [lindex $coord 0] - [lindex $private($visuNo,targetCoordCanvas) 0]]
   set dy [expr [lindex $coord 1] - [lindex $private($visuNo,targetCoordCanvas) 1]]

   #--- je deplace la cible le deplacement en coordonnées dans le canvas
   $private($visuNo,hCanvas) move target $dx $dy

   #--- je memorise les coordonnees de la cible dans le canvas
   set private($visuNo,targetCoordCanvas) $coord

}

#------------------------------------------------------------
# ::Autoguider::moveTelescope
#    lance/arrete les acquisitions
# 
#------------------------------------------------------------
proc ::Autoguider::moveTelescope { visuNo } {





}

#------------------------------------------------------------
# ::Autoguider::changeShowImage
#    efface l'image a l'ecran si autovisu==0
# 
#------------------------------------------------------------
proc ::Autoguider::changeShowImage { visuNo } {
   variable private

   if { $private($visuNo,showImage) == "0" } {
      #--- je met tous les pixels a zero
      set bufNo [::confVisu::getBufNo $visuNo]
      buf$bufNo mult 0
      visu$visuNo cut {32 1}
      visu$visuNo disp
   }
}

#------------------------------------------------------------
# ::Autoguider::changeShowTarget
#    efface le symbole de la cible si showImage==0
# 
#------------------------------------------------------------
proc ::Autoguider::changeShowTarget { visuNo } {
   variable private

   if { $private($visuNo,showTarget) == "0" } {
      deleteTarget $visuNo
   }
}

#------------------------------------------------------------
# ::Autoguider::run_config_autoguidage
#    affiche la fenetre de configuration de l'autoguidage
# 
#------------------------------------------------------------
proc ::Autoguider::run_config_autoguidage { visuNo } {



}

#------------------------------------------------------------
# ::Autoguider::configureWebcam
#    affiche la fenetre de configuration d'une webcam
# 
#------------------------------------------------------------
proc ::Autoguider::webcamConfigure { visuNo } {
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
# ::Autoguider::webcamSelectFormat
#    affiche la fenetre de selection du format d'image d'une webcam
# 
#------------------------------------------------------------

proc ::Autoguider::webcamSelectFormat { visuNo } {
   variable private
   global caption 

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

::Autoguider::Init $audace(base)

