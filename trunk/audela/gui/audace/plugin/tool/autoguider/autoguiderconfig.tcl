#
# Fichier : autoguider_config.tcl
# Description : fenetre de configuration de l'autoguidage


################################################################
# namespace ::autoguider::config
#    fenetre de configuration de l'outil autoguider
################################################################

namespace eval ::autoguider::config {

}

#------------------------------------------------------------
# ::autoguider::config::init
#    affiche la fenetre de configuration de l'autoguidage
# 
#------------------------------------------------------------
proc ::autoguider::config::run { visuNo } {
   variable private
   global caption 
   
   set caption(autoguider,inclinaison) "Inclinaison de la camera"
   set caption(autoguider,angle) "angle (°)"
   set caption(autoguider,go)    "GO"
   set caption(autoguider,stop)  "STOP"   
   set caption(autoguider,running)  "Apprentissage en cours"   

   set private($visuNo,learnPendingStop) "2"
   set private($visuNo,learn,stepLabel) ""
   set private($visuNo,fullImage)   0
   set private($visuNo,selectedPoint) ""

   #--- j'affiche la fenetre de configuration
   ::confGenerique::run  "[confVisu::getBase $visuNo].autoguider.config" "::autoguider::config" $visuNo nomodal
}

#------------------------------------------------------------
# ::autoguider::config::fermer
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::autoguider::config::close { visuNo } {
   variable private
   global caption

   if { $private($visuNo,learnPendingStop) != 2 } {
      tk_messageBox -title [getLabel]" -type ok -message $caption(autoguider,running) -icon warning
      return 0
   }
}


#------------------------------------------------------------
# ::autoguider::config::getLabel
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::autoguider::config::getLabel { } {
   global caption

   return "$caption(autoguider,titre) $caption(autoguider,config_guidage)"
}

#------------------------------------------------------------
# ::autoguider::config::showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::autoguider::config::showHelp { } {
   ::audace::showHelpPlugin tool autoguider autoguider.htm
}

#------------------------------------------------------------
# ::autoguider::config::startLearn { }
#   demarre l'apprentissage
#   return rien
#------------------------------------------------------------
proc ::autoguider::config::startLearn { visuNo } {
   variable private
   variable widget 

   ::autoguider::stopSuivi $visuNo
   set private($visuNo,learnPendingStop) 0
   
   #--- j'associe le bouton gauche à la selection de l'etoile
   ::confVisu::createBindCanvas $visuNo <ButtonPress-1> "::autoguider::config::selectStar $visuNo %x %y"

   #--- je configure le bouton STOP
   $private($visuNo,This).apprenti.go configure -text $::caption(autoguider,stop) \
      -command "::autoguider::config::stopLearn $visuNo"
   update
   
   #--- je configure la camera
   set camNo [::confVisu::getCamNo $visuNo ]
   cam$camNo exptime $::autoguider::private($visuNo,pose)
   cam$camNo bin [list [string range $::autoguider::private($visuNo,binning) 0 0] [string range $::autoguider::private($visuNo,binning) 2 2]]
   cam$camNo radecfromtel 0
 
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je marque le point depart
      set step "center"
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
      set widget($visuNo,originCoord) $private($visuNo,learn,coords,$step) 
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers l'est
      set step "est"
      moveTelescope $visuNo e $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je marque le point
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers l'ouest
      moveTelescope $visuNo w "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers l'ouest
      set step "west"
      moveTelescope $visuNo w $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je marque le point 
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers le point de depart
      moveTelescope $visuNo e "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers le sud
      set step "south"
      moveTelescope $visuNo s $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je marque le point 
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }   
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers le point de depart
      moveTelescope $visuNo n "center"
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je deplace le telescope vers le nord
      set step "north"
      moveTelescope $visuNo n $step
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {        
      #--- je marque le point 
      set private($visuNo,learn,coords,$step) [markPosition $visuNo $step]
   }   
   if { $private($visuNo,learnPendingStop) == 0 } {     
      #--- je deplace le telescope vers le point de depart
      moveTelescope $visuNo s "center"
   }   
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je fais une acquisition
      acq $visuNo
   }
   if { $private($visuNo,learnPendingStop) == 0 } {  
      #--- je calcule la vitesse de deplacement sur l'axe alpha
      set dx [expr  [lindex $private($visuNo,learn,coords,west) 0] - [lindex $private($visuNo,learn,coords,est) 0]]
      set dy [expr  [lindex $private($visuNo,learn,coords,west) 1] - [lindex $private($visuNo,learn,coords,est) 1]]
      set dAlpha [expr sqrt($dx*$dx + $dy*$dy) ]
      set penteAlpha [expr $dy / $dx ] 
      set widget($visuNo,alphaSpeed) [expr $dAlpha / $widget($visuNo,learn,delay) / 2  ]
      set widget($visuNo,alphaSpeed) [format "%0.1f" $widget($visuNo,alphaSpeed)]
   
      #--- je calcule la vitesse de deplacement sur l'axe delta
      set dx [expr  [lindex $private($visuNo,learn,coords,north) 0] - [lindex $private($visuNo,learn,coords,south) 0]]
      set dy [expr  [lindex $private($visuNo,learn,coords,north) 1] - [lindex $private($visuNo,learn,coords,south) 1]]
      set dDelta [expr sqrt($dx*$dx + $dy*$dy) ]
      set penteDelta [expr $dy / $dx ] 
      set widget($visuNo,deltaSpeed) [expr $dDelta / $widget($visuNo,learn,delay) / 2   ]
      set widget($visuNo,deltaSpeed) [format "%0.1f" $widget($visuNo,deltaSpeed)]
   
      #--- je calcule l'angle d'inclinaison de la camera
      set angleAlpha [expr 180*atan($penteAlpha)/3.14159265359 ]
      set angleDelta [expr 180*atan($penteDelta)/3.14159265359 ]
      if { $penteDelta >= 0 } {
         set angleDelta2 [expr $angleDelta -90 ]
      } else {
         set angleDelta2 [expr $angleDelta +90 ]
      }
      #--- je calcule la moyenne des 2 angles 
      set widget($visuNo,angle) [expr ($angleAlpha + $angleDelta2)/2]
      set widget($visuNo,angle) [format "%0.1f" $widget($visuNo,angle)]
      ###console::disp "angleAlpha=$angleAlpha angleDelta=$angleDelta angleDelta2=$angleDelta2 angle=$widget($visuNo,angle)\n"  
      #--- j'affiche les axes alpha et delta
      ::autoguider::updateAlphaDeltaAxis $visuNo $widget($visuNo,originCoord) $widget($visuNo,angle)
   }   
      
   #--- j'efface tous les rectangles d'apprentissage
   [::confVisu::getCanvas $visuNo] delete learnrect
   #--- je supprime les variables contenant les coordonnees
   foreach {key value} [array get private $visuNo,learn,rect,* ] {
      unset private($key)
   }
   
   #--- j'efface le dernier message
   displayLearnMessage $visuNo "" 
   #--- je supprime le bind du bouton gauche de la souris
   ::confVisu::createBindCanvas $visuNo <ButtonPress-1> 
   #--- j'affiche le bouton GO
   $private($visuNo,This).apprenti.go configure -text $::caption(autoguider,go) \
       -command "::autoguider::config::startLearn $visuNo"
   
   #-- fin de l'arret de l'apprentissage
   set private($visuNo,learnPendingStop) 2

}

#------------------------------------------------------------
# ::autoguider::config::stopLearn { }
#   demande l'arret de l'apprentissage
# return 
#    
#------------------------------------------------------------
proc ::autoguider::config::stopLearn { visuNo } {
   variable private

   set private($visuNo,learnPendingStop) 1

   #--- je debloque l'attente sur selectStar au cas ou on serait en attente
   set private($visuNo,selectedPoint) [list 1 1]
   update

}

#------------------------------------------------------------
# ::autoguider::config::acq { }
#   fait une acquisition et affiche l'image
# return 
#------------------------------------------------------------
proc ::autoguider::config::acq { visuNo } {
   variable private

   if { $private($visuNo,learnPendingStop) == 0 } {  
      set camNo [::confVisu::getCamNo $visuNo ]
      cam$camNo acq
      if { [set ::status_cam$camNo] == "exp" } {
         vwait ::status_cam$camNo
      }
      ::confVisu::autovisu $visuNo
   }
}

#------------------------------------------------------------
# ::autoguider::config::moveTelescope { }
# return 
#------------------------------------------------------------
proc ::autoguider::config::moveTelescope { visuNo direction label} {
   variable private
   variable widget

   displayLearnMessage $visuNo "move to $label" 

   #--- je demarre le deplacement
   ::telescope::move $direction 

   #--- j'attend l'expiration du delai par tranche de 1 seconde 
   set delay [expr int( $widget($visuNo,learn,delay) * 1000)] 
   while { $delay  > 0 } {
      if { $private($visuNo,learnPendingStop) == 0 } {  
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
      #--- laisse la main pour traiter une eventuelle demande d'arret 
      update
   }
   
   #--- j'arrete le deplacement
   ::telescope::stop $direction
}


#------------------------------------------------------------
# ::autoguider::config::markStarPosition { }
#   marque la position de l'etoile
# return 
#    retourne une liste contenant les coordonnes de l'etoile ( referentiel buffer) 
#------------------------------------------------------------
proc ::autoguider::config::markPosition { visuNo step} {
   variable private
   variable widget 

   set bufNo [::confVisu::getBufNo $visuNo ]
   if  { $private($visuNo,fullImage) == 1 } {
      set box [list 10 10 [expr [buf$bufNo getpixelswidth] -10] [expr [buf$bufNo getpixelsheight] -10] ]
      set starCoords [lrange [buf$bufNo centro $box ] 0 1]
   } else {
      #--- j'affiche le message invitant a cliquer sur l'etoile
      displayLearnMessage $visuNo "cliquer sur l'étoile $step"               
      #--- j'attends que l'etoile soit selectionnee avec la souris
      vwait ::autoguider::config::private($visuNo,selectedPoint)
      #--- je convertis les coordonnees du referentiel ecran en coordonnes referentiel canvas
      set coord [::confVisu::screen2Canvas $visuNo $private($visuNo,selectedPoint) ]
      #--- je convertis les coordonnees du referentiel canvas en coordonnes referentiel image
      set coord [::confVisu::canvas2Picture $visuNo $coord]
      set size 16
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      set x1 [expr $x - $size]
      set x2 [expr $x + $size]
      set y1 [expr $y - $size]
      set y2 [expr $y + $size]
      set zone1 [list $x1 $y1 $x2 $y2 ]
      #--- je recupere les coordonnees de l'etoile la plus brillante dans zone1
      set starCoords [lrange [buf$bufNo centro $zone1 ] 0 1]
   }
    
   #--- je dessine un rectangle autour de l'etoile
   set size 8
   set x  [lindex $starCoords 0]
   set y  [lindex $starCoords 1]
   set x1 [expr $x - $size]
   set x2 [expr $x + $size]
   set y1 [expr $y - $size]
   set y2 [expr $y + $size]
   #--- je convertis les coordonnées "immage" en coordonnees "canvas"
   set coord1 [::confVisu::picture2Canvas $visuNo [list $x1 $y1]]
   set coord2 [::confVisu::picture2Canvas $visuNo [list $x2 $y2]]
   #--- je dessine le rectangle
   [::confVisu::getCanvas $visuNo] create rect [lindex $coord1 0] [lindex $coord1 1] [lindex $coord2 0] [lindex $coord2 1] -outline red -offset center -tag learnrect
      
   return $starCoords
}

#------------------------------------------------------------
# ::autoguider::config::selectStar
#   enregistre les coordonnees de l'etoile selectionnee avec la souris
#   dans private(visuNo,selectedPoint) 
# parameters : 
#   visuNo : numero de la visu courante
#   x y    : coordonnees du pointeur de la souris dans la fenetre
# return 
#   rien
#------------------------------------------------------------
proc ::autoguider::config::selectStar { visuNo x y  } {
   variable private

   set private($visuNo,selectedPoint) [list $x $y]
}

#------------------------------------------------------------
# ::autoguider::config::displayLearnMessage { }
#   affiche un message d'invite pour selectionner une etoile
# return 
#   rien
#------------------------------------------------------------
proc ::autoguider::config::displayLearnMessage { visuNo message} {
   variable private
   set private($visuNo,learn,stepLabel) $message 
   update
}

#------------------------------------------------------------
# ::autoguider::config::confToWidget 
#   copie les parametres du tableau conf() dans les variables des widgets
#------------------------------------------------------------
proc ::autoguider::config::confToWidget { visuNo } {
   variable widget  
   global conf

   #--- j'initialise les variables utilisees par le widgets      
   set widget($visuNo,seuilx)      $conf(autoguider,seuilx)
   set widget($visuNo,seuily)      $conf(autoguider,seuily)
   set widget($visuNo,detection)   $conf(autoguider,detection)
   set widget($visuNo,alphaSpeed)  $conf(autoguider,alphaSpeed)
   set widget($visuNo,deltaSpeed)  $conf(autoguider,deltaSpeed)
   set widget($visuNo,learn,delay) $conf(autoguider,learn,delay) 
   set widget($visuNo,angle)       $conf(autoguider,angle) 
   set widget($visuNo,originCoord) $conf(autoguider,originCoord)
}

#------------------------------------------------------------
# ::autoguider::config::appliquer { }
#   copie les variable des widgets dans le tableau conf()
#------------------------------------------------------------
proc ::autoguider::config::apply { visuNo } {
   variable widget 
   global conf

   set conf(autoguider,seuilx)      $widget($visuNo,seuilx)
   set conf(autoguider,seuily)      $widget($visuNo,seuily)
   set conf(autoguider,detection)   $widget($visuNo,detection)
   set conf(autoguider,alphaSpeed)  $widget($visuNo,alphaSpeed)
   set conf(autoguider,deltaSpeed)  $widget($visuNo,deltaSpeed)
   set conf(autoguider,learn,delay) $widget($visuNo,learn,delay)
   set conf(autoguider,angle)       $widget($visuNo,angle)
   set conf(autoguider,originCoord) $widget($visuNo,originCoord)

   autoguider::updateAlphaDeltaAxis $visuNo $conf(autoguider,originCoord) $conf(autoguider,angle)
}

#------------------------------------------------------------
# ::autoguider::config::fillConfigPage { }
#   fenetre de configuration du panneau
#   return rien
#------------------------------------------------------------
proc ::autoguider::config::fillConfigPage { frm visuNo } {
   variable widget 
   variable private
   global caption

   set private($visuNo,This) $frm
   #--- j'initialise les variables des widgets
   confToWidget $visuNo
   
   #--- Frame Detection etoile 
   TitleFrame $frm.detection -borderwidth 2 -relief ridge -text $caption(autoguider,detection)
      radiobutton $frm.detection.psf -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(autoguider,detection_psf)" -value "PSF" \
                  -variable ::autoguider::config::widget($visuNo,detection)
      pack $frm.detection.psf -in [$frm.detection getframe] -side left -padx 10 -pady 5
      radiobutton $frm.detection.fente -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(autoguider,detection_fente)" -value "FENTE" \
                  -variable ::autoguider::config::widget($visuNo,detection)
      pack $frm.detection.fente -in [$frm.detection getframe] -side left -padx 10 -pady 5      
   grid $frm.detection  -row 0 -column 0 -columnspan 1 -sticky ew

   #--- Frame Apprentissage 
   TitleFrame $frm.apprenti -borderwidth 2 -relief ridge -text $caption(autoguider,apprenti)
      Button $frm.apprenti.go  -text $caption(autoguider,go) -width 10 -command "::autoguider::config::startLearn $visuNo"
      pack $frm.apprenti.go -in [$frm.apprenti getframe] -anchor w -side top -fill none -expand 0
      LabelEntry $frm.apprenti.delay  -label "delai" \
            -labeljustify left -labelwidth 10 -width 5 -justify right \
            -textvariable ::autoguider::config::widget($visuNo,learn,delay)
      pack $frm.apprenti.delay -in [$frm.apprenti getframe] -anchor w -side top -fill x -expand 1
      Label $frm.apprenti.step  -justify right \
                 -textvariable ::autoguider::config::private($visuNo,learn,stepLabel)
      pack $frm.apprenti.step -in [$frm.apprenti getframe] -anchor w -side top -fill x -expand 1
      
   grid $frm.apprenti -row 0 -column 1 -columnspan 1 -sticky ew

   #--- Frame ascension droite 
   TitleFrame $frm.alpha -borderwidth 2 -relief ridge -text "Ascension droite"
      LabelEntry $frm.alpha.gainprop  -label "$caption(autoguider,vitesse)" \
            -labeljustify left -labelwidth 14 -width 5 -justify right \
            -textvariable ::autoguider::config::widget($visuNo,alphaSpeed)
      pack $frm.alpha.gainprop -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.alpha.seuil  -label "$caption(autoguider,seuil)" \
            -labeljustify left -labelwidth 14 -width 5 -justify right \
            -textvariable ::autoguider::config::widget($visuNo,seuilx)
      pack $frm.alpha.seuil -in [$frm.alpha getframe] -anchor w -side top -fill x -expand 0
   grid $frm.alpha   -row 1 -column 0 -columnspan 1 -sticky ew

   TitleFrame $frm.delta -borderwidth 2 -text "Declinaison"
      LabelEntry $frm.delta.gainprop  -label "$caption(autoguider,vitesse)" \
            -labeljustify left -labelwidth 14 -width 5 -justify right \
            -textvariable ::autoguider::config::widget($visuNo,deltaSpeed)
      pack $frm.delta.gainprop -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
      LabelEntry $frm.delta.seuil  -label "$caption(autoguider,seuil)" \
            -labeljustify left -labelwidth 14 -width 5 -justify right \
            -textvariable ::autoguider::config::widget($visuNo,seuily)
      pack $frm.delta.seuil -in [$frm.delta getframe] -anchor w -side top -fill x -expand 0
   grid $frm.delta  -row 1 -column 1 -columnspan 1 -sticky ew

   TitleFrame $frm.orientation -borderwidth 2 -text $caption(autoguider,inclinaison)
      LabelEntry $frm.orientation.angle  -label "$caption(autoguider,angle)" \
            -labeljustify left -labelwidth 14 -width 5 -justify right \
            -textvariable ::autoguider::config::widget($visuNo,angle)
      pack $frm.orientation.angle -in [$frm.orientation getframe] -anchor w -side top -fill x -expand 0
   grid $frm.orientation -row 2 -column 0 -columnspan 2 -sticky ew

   grid columnconfigure  $frm 0 -weight 1
   grid columnconfigure  $frm 1 -weight 1

   pack $frm -fill x -expand 1

      
}
