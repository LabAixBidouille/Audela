#
# Fichier : webcam.tcl
# Description : Configuration des cameras WebCam
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise a jour $Id: webcam.tcl,v 1.2 2007-02-03 00:49:46 robertdelmas Exp $
#

namespace eval ::webcam {
}

#
# ::webcam::init
#    Initialise les variables conf(webcam,$cam_item,...) et les captions
#
proc ::webcam::init { } {
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) camera webcam webcam.cap ]

   #--- Intialise les variables de la webcams A
   foreach cam_item { A B C } {
      if { ! [ info exists conf(webcam,$cam_item,longuepose) ] }           { set conf(webcam,$cam_item,longuepose)           "0" }
      if { ! [ info exists conf(webcam,$cam_item,longueposeport) ] }       { set conf(webcam,$cam_item,longueposeport)       "LPT1:" }
      if { ! [ info exists conf(webcam,$cam_item,longueposelinkbit) ] }    { set conf(webcam,$cam_item,longueposelinkbit)    "0" }
      if { ! [ info exists conf(webcam,$cam_item,longueposestartvalue) ] } { set conf(webcam,$cam_item,longueposestartvalue) "0" }
      if { ! [ info exists conf(webcam,$cam_item,longueposestopvalue) ] }  { set conf(webcam,$cam_item,longueposestopvalue)  "1" }
      if { ! [ info exists conf(webcam,$cam_item,mirh) ] }                 { set conf(webcam,$cam_item,mirh)                 "0" }
      if { ! [ info exists conf(webcam,$cam_item,mirv) ] }                 { set conf(webcam,$cam_item,mirv)                 "0" }
      if { ! [ info exists conf(webcam,$cam_item,channel) ] }              { set conf(webcam,$cam_item,channel)              "0" }
      if { ! [ info exists conf(webcam,$cam_item,ccd_N_B) ] }              { set conf(webcam,$cam_item,ccd_N_B)              "0" }
      if { ! [ info exists conf(webcam,$cam_item,dim_ccd_N_B) ] }          { set conf(webcam,$cam_item,dim_ccd_N_B)          "1/4''" }
      if { ! [ info exists conf(webcam,$cam_item,ccd) ] }                  { set conf(webcam,$cam_item,ccd)                  "" }
   }
}

#
# ::webcam::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::webcam::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la WebCam dans le tableau private($cam_item,...)
   foreach cam_item { A B C } {
      set private($cam_item,longuepose)           $conf(webcam,$cam_item,longuepose)
      set private($cam_item,longueposeport)       $conf(webcam,$cam_item,longueposeport)
      set private($cam_item,longueposelinkbit)    $conf(webcam,$cam_item,longueposelinkbit)
      set private($cam_item,longueposestartvalue) $conf(webcam,$cam_item,longueposestartvalue)
      set private($cam_item,longueposestopvalue)  $conf(webcam,$cam_item,longueposestopvalue)
      set private($cam_item,mirh)                 $conf(webcam,$cam_item,mirh)
      set private($cam_item,mirv)                 $conf(webcam,$cam_item,mirv)
      set private($cam_item,channel)              $conf(webcam,$cam_item,channel)
      set private($cam_item,ccd_N_B)              $conf(webcam,$cam_item,ccd_N_B)
      set private($cam_item,dim_ccd_N_B)          $conf(webcam,$cam_item,dim_ccd_N_B)
      set private($cam_item,ccd)                  $conf(webcam,$cam_item,ccd)
   }
}

#
# ::webcam::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::webcam::widgetToConf { cam_item } {
   variable private
   global conf

   #--- Memorise la configuration de la WebCam dans le tableau conf(webcam,$cam_item,...)
   set conf(webcam,$cam_item,longuepose)           $private($cam_item,longuepose)
   set conf(webcam,$cam_item,longueposeport)       $private($cam_item,longueposeport)
   set conf(webcam,$cam_item,longueposelinkbit)    $private($cam_item,longueposelinkbit)
   set conf(webcam,$cam_item,longueposestartvalue) $private($cam_item,longueposestartvalue)
   set conf(webcam,$cam_item,longueposestopvalue)  $private($cam_item,longueposestopvalue)
   set conf(webcam,$cam_item,mirh)                 $private($cam_item,mirh)
   set conf(webcam,$cam_item,mirv)                 $private($cam_item,mirv)
   set conf(webcam,$cam_item,channel)              $private($cam_item,channel)
   set conf(webcam,$cam_item,ccd_N_B)              $private($cam_item,ccd_N_B)
   set conf(webcam,$cam_item,dim_ccd_N_B)          $private($cam_item,dim_ccd_N_B)
   set conf(webcam,$cam_item,ccd)                  $private($cam_item,ccd)
}

#
# ::webcam::fillConfigPage
#    Interface de configuration de la WebCam
#
proc ::webcam::fillConfigPage { frm cam_item } {
   variable private
   global audace caption color confCam

   #--- confToWidget
   ::webcam::confToWidget

   #--- Supprime tous les widgets de l'onglet
   foreach i [ winfo children $frm ] {
      destroy $i
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side bottom -fill x -pady 2

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame3a -borderwidth 0 -relief raised
   pack $frm.frame3a -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame4 -borderwidth 1 -relief solid
   pack $frm.frame4 -in $frm.frame3a -side top -fill x

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -in $frm.frame3 -side bottom -fill x -pady 5

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame3 -side bottom -fill x -pady 5

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame3 -side left -fill x -pady 5

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame3 -side left -fill x -pady 5

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame4 -side top -fill x -pady 5

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame4 -side top -fill x -pady 5

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame4 -side top -fill x -pady 5

   frame $frm.frame12 -borderwidth 0 -relief raised
   pack $frm.frame12 -in $frm.frame4 -side top -fill x -pady 5

   frame $frm.frame13 -borderwidth 0 -relief raised
   pack $frm.frame13 -in $frm.frame3a -side bottom -fill x -pady 5

   frame $frm.frame14 -borderwidth 0 -relief raised
   pack $frm.frame14 -in $frm.frame13 -side right -fill x -pady 5

   #--- Definition du canal USB
   label $frm.lab1 -text "$caption(webcam,canal_usb)"
   pack $frm.lab1 -in $frm.frame7 -anchor center -side left -padx 10

   #--- Je constitue la liste des canaux USB
   set list_combobox [ list 0 1 2 3 4 5 6 7 8 9 ]

   #--- Choix du canal USB
   ComboBox $frm.port \
      -width 7          \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::webcam::private($cam_item,channel) \
      -editable 0       \
      -values $list_combobox
   pack $frm.port -in $frm.frame7 -anchor center -side left -padx 10

   #--- Miroir en x et en y
   checkbutton $frm.mirx -text "$caption(webcam,miroir_x)" -highlightthickness 0 \
      -variable ::webcam::private($cam_item,mirh)
   pack $frm.mirx -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

   checkbutton $frm.miry -text "$caption(webcam,miroir_y)" -highlightthickness 0 \
      -variable ::webcam::private($cam_item,mirv)
   pack $frm.miry -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

   #--- Boutons de configuration de la source et du format video
   button $frm.conf_webcam -text "$caption(webcam,conf_source)"
   pack $frm.conf_webcam -in $frm.frame6 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true
   button $frm.format_webcam -text "$caption(webcam,format_video)"
   pack $frm.format_webcam -in $frm.frame5 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

   #--- Option longue pose avec lien au site web de Steve Chambers
   checkbutton $frm.longuepose -highlightthickness 0 -variable ::webcam::private($cam_item,longuepose) \
      -command "::webcam::checkConfigLonguePose $cam_item"
   pack $frm.longuepose -in $frm.frame9 -anchor center -side left -pady 3

   label $frm.labURL_a -text "$caption(webcam,longuepose)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL_a -in $frm.frame9 -anchor center -side left -pady 3

   label $frm.lab2 -text "$caption(webcam,longueposeport)"
   pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 3 -pady 5

   #--- Je constitue la liste des liaisons pour la longuepose
   set list_combobox [ ::confLink::getLinkLabels { "parallelport" "quickremote" } ]

   #--- Je verifie le contenu de la liste
   if { [ llength $list_combobox ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- Je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_combobox $private($cam_item,longueposeport) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- Je la remplace par le premier item de la liste
         set private($cam_item,longueposeport) [ lindex $list_combobox 0 ]
      }
   } else {
      #--- Si la liste est vide
      #--- Je desactive l'option longue pose
      set private($cam_item,longueposeport) ""
      set private($cam_item,longuepose) 0
      #--- J'empeche de selectionner l'option longue
      $frm.longuepose configure -state disable
   }

   #--- Choix du port ou de la liaison
   ComboBox $frm.lpport \
      -width 13         \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::webcam::private($cam_item,longueposeport) \
      -values $list_combobox \
      -modifycmd "::webcam::configureLinkLonguePose $cam_item"
   pack $frm.lpport -in $frm.frame10 -anchor center -side right -padx 10 -pady 5

   #--- Bouton de configuration des liaisons
   button $frm.configure -text "$caption(webcam,configurer)" -relief raised \
      -command "::webcam::configureLinkLonguePose $cam_item ; \
         ::confLink::run ::webcam::private($cam_item,longueposeport) \
         { parallelport quickremote } \"- $caption(webcam,longuepose1) - $caption(webcam,camera)\""
   pack $frm.configure -in $frm.frame10 -side right -pady 10 -ipadx 10 -ipady 1 -expand true

   label $frm.lab3 -text "$caption(webcam,longueposebit)"
   pack $frm.lab3 -in $frm.frame11 -anchor center -side left -padx 3 -pady 5

   set list_combobox [ list 0 1 2 3 4 5 6 7 ]
   ComboBox $frm.longueposelinkbit \
      -width 7          \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::webcam::private($cam_item,longueposelinkbit) \
      -editable 0       \
      -values $list_combobox
   pack $frm.longueposelinkbit -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

   label $frm.lab4 -text "$caption(webcam,longueposestart)"
   pack $frm.lab4 -in $frm.frame12 -anchor center -side left -padx 3 -pady 5

   entry $frm.longueposestartvalue -width 4 -textvariable ::webcam::private($cam_item,longueposestartvalue) -justify center
   pack $frm.longueposestartvalue -in $frm.frame12 -anchor center -side right -padx 10 -pady 5

   #--- WebCam modifiee avec un capteur Noir et Blanc
   checkbutton $frm.ccd_N_B -text "$caption(webcam,ccd_N_B)" -highlightthickness 0 \
      -variable ::webcam::private($cam_item,ccd_N_B) -command "::webcam::checkConfigCCDN&B $cam_item"
   pack $frm.ccd_N_B -in $frm.frame13 -anchor center -side left -pady 3 -pady 8

   set list_combobox [ list 1/4'' 1/3'' 1/2'' ]
   ComboBox $frm.dim_ccd_N_B \
      -width 6         \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::webcam::private($cam_item,dim_ccd_N_B) \
      -modifycmd "::webcam::checkConfigCCDN&B $cam_item" \
      -values $list_combobox
   pack $frm.dim_ccd_N_B -in $frm.frame14 -anchor center -side right -padx 10 -pady 5

   #--- Gestion des widgets actifs/inactifs
   ::webcam::ConfigWebCam $cam_item

   #--- Site web officiel des WebCam
   label $frm.lab103 -text "$caption(webcam,titre_site_web)"
   pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(webcam,site_web_ref)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   #--- Pour le site web de reference
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(webcam,site_web_ref)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      global frmm
      set frm $frmm(Camera7)
      $frm.labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      global frmm
      set frm $frmm(Camera7)
      $frm.labURL configure -fg $color(blue)
   }
   #--- Pour le site web de Steve Chambers
   bind $frm.labURL_a <ButtonPress-1> {
      set filename "$caption(webcam,site_web_chambers)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL_a <Enter> {
      global frmm
      set frm $frmm(Camera7)
      $frm.labURL_a configure -fg $color(purple)
   }
   bind $frm.labURL_a <Leave> {
      global frmm
      set frm $frmm(Camera7)
      $frm.labURL_a configure -fg $color(blue)
   }
}

#
# ::webcam::configureCamera
#    Configure la WebCam en fonction des donnees contenues dans les variables conf(webcam,$cam_item,...)
#
proc ::webcam::configureCamera { cam_item } {
   global caption conf confCam

   set camNo [ cam::create webcam USB -channel $conf(webcam,$cam_item,channel) \
      -lpport $conf(webcam,$cam_item,longueposeport) -name WEBCAM -ccd $conf(webcam,$cam_item,ccd) ]
   console::affiche_erreur "$caption(webcam,canal_usb) ($caption(webcam,camera))\
      $caption(webcam,2points) $conf(webcam,$cam_item,channel)\n"
   console::affiche_erreur "$caption(webcam,longuepose) $caption(webcam,2points)\
      $conf(webcam,$cam_item,longuepose)\n"
   console::affiche_saut "\n"
   set confCam($cam_item,camNo) $camNo
   cam$camNo buf [ visu$confCam($cam_item,visuNo) buf ]
   cam$camNo mirrorh $conf(webcam,$cam_item,mirh)
   cam$camNo mirrorv $conf(webcam,$cam_item,mirv)
   #--- Parametrage des longues poses
   if { $conf(webcam,$cam_item,longuepose) == "1" } {
      switch [ ::confLink::getLinkNamespace $conf(webcam,$cam_item,longueposeport) ] {
         parallelport {
            #--- Je cree la liaison longue pose
            set linkNo [ ::confLink::create $conf(webcam,$cam_item,longueposeport) "cam$camNo" "longuepose" "bit $conf(webcam,$cam_item,longueposelinkbit)" ]
            #---
            cam$camNo longuepose 1
            cam$camNo longueposelinkno $linkNo
            cam$camNo longueposelinkbit $conf(webcam,$cam_item,longueposelinkbit)
            cam$camNo longueposestartvalue $conf(webcam,$cam_item,longueposestartvalue)
            cam$camNo longueposestopvalue $conf(webcam,$cam_item,longueposestopvalue)
         }
         quickremote {
            #--- Je cree la liaison longue pose
            set linkNo [ ::confLink::create $conf(webcam,$cam_item,longueposeport) "cam$camNo" "longuepose" "bit $conf(webcam,$cam_item,longueposelinkbit)" ]
            #---
            cam$camNo longuepose 1
            cam$camNo longueposelinkno $linkNo
            cam$camNo longueposelinkbit $conf(webcam,$cam_item,longueposelinkbit)
            cam$camNo longueposestartvalue $conf(webcam,$cam_item,longueposestartvalue)
            cam$camNo longueposestopvalue $conf(webcam,$cam_item,longueposestopvalue)
         }
      }
   } else {
      #--- Pas de liaison longue pose
      cam$camNo longuepose 0
   }
   #---
   ::confVisu::visuDynamix $confCam($cam_item,visuNo) 255 -255
}

#
# ::webcam::stop
#    Arrete la WebCam
#
proc ::webcam::stop { camNo cam_item } {
   global conf

   #--- Gestion des widgets actifs/inactifs
   ::webcam::ConfigWebCam $cam_item
   #--- Je ferme la liaison longuepose
   if { $conf(webcam,$cam_item,longuepose) == 1 } {
      ::confLink::delete $conf(webcam,$cam_item,longueposeport) "cam$camNo" "longuepose"
   }
}

#
# ::webcam::ConfigWebCam
#    Configure les widgets de configuration de la WebCam
#
proc ::webcam::ConfigWebCam { cam_item } {
   global audace conf confCam frmm

   if { [ winfo exists $audace(base).confCam ] } {
      set frm $frmm(Camera7)
      if { [ ::confCam::getProduct $confCam($cam_item,camNo) ] == "webcam" } {
         #--- Boutons de configuration de la WebCam actif
         $frm.conf_webcam configure -state normal -command "cam$confCam($cam_item,camNo) videosource"
         $frm.format_webcam configure -state normal -command "cam$confCam($cam_item,camNo) videoformat"
         #--- Configure les widgets associes a la longue pose
         ::webcam::checkConfigLonguePose $cam_item
         #--- Configure les widgets associes au choix du CCD
         ::webcam::checkConfigCCDN&B $cam_item
      } else {
         #--- Boutons de configuration de la WebCam inactif
         $frm.conf_webcam configure -state disabled
         $frm.format_webcam configure -state disabled
         #--- Configure les widgets associes a la longue pose
         $frm.lpport configure -state disabled
         $frm.configure configure -state disabled
         $frm.longueposelinkbit configure -state disabled
         $frm.longueposestartvalue configure -state disabled
         #--- Configure les widgets associes au choix du CCD
         pack forget $frm.frame14
      }
   }
}

#
# ::webcam::checkConfigLonguePose
#    Configure les widgets de configuration de la longue pose
#
proc ::webcam::checkConfigLonguePose { cam_item } {
   variable private
   global audace frmm

   if { [ winfo exists $audace(base).confCam ] } {
      set frm $frmm(Camera7)
      if { $private($cam_item,longuepose) == "1" } {
         #--- Widgets de configuration de la longue pose actifs
         $frm.lpport configure -state normal
         $frm.configure configure -state normal
         $frm.longueposelinkbit configure -state normal
         $frm.longueposestartvalue configure -state normal
      } else {
         #--- Widgets de configuration de la longue pose inactifs
         $frm.lpport configure -state disabled
         $frm.configure configure -state disabled
         $frm.longueposelinkbit configure -state disabled
         $frm.longueposestartvalue configure -state disabled
      }
   }
}

#
# ::webcam::checkConfigCCDN&B
#    Configure les widgets de configuration du choix du CCD
#
proc ::webcam::checkConfigCCDN&B { cam_item } {
   variable private
   global audace confCam frmm

   if { [ winfo exists $audace(base).confCam ] } {
      set frm $frmm(Camera7)
      if { $::webcam::private($cam_item,ccd_N_B) == "1" } {
         if { $::webcam::private($cam_item,dim_ccd_N_B) == "1/4''" } {
            set ::webcam::private($cam_item,ccd) "ICX098BL-6"
         } elseif { $::webcam::private($cam_item,dim_ccd_N_B) == "1/3''" } {
            set ::webcam::private($cam_item,ccd) "ICX424AL-6"
         } elseif { $::webcam::private($cam_item,dim_ccd_N_B) == "1/2''" } {
            set ::webcam::private($cam_item,ccd) "ICX414AL-6"
         }
         pack $frm.frame14 -in $frm.frame13 -side right -fill x -pady 5
      } else {
         set ::webcam::private($cam_item,ccd) "ICX098BQ-A"
         pack forget $frm.frame14
      }
   }
}

#
# ::webcam::configureLinkLonguePose
#    Positionne la liaison sur celle qui vient d'etre selectionnee pour la longue pose
#
proc ::webcam::configureLinkLonguePose { cam_item } {
   variable private

   #--- Je positionne startvalue par defaut en fonction du type de liaison
   if { [ ::confLink::getLinkNamespace $private($cam_item,longueposeport) ] == "parallelport" } {
      set private($cam_item,longueposestartvalue) "0"
      set private($cam_item,longueposestopvalue)  "1"
   } elseif { [ ::confLink::getLinkNamespace $private($cam_item,longueposeport) ] == "quickremote" } {
      set private($cam_item,longueposestartvalue) "1"
      set private($cam_item,longueposestopvalue)  "0"
   }
}

#
# ::webcam::getBinningList
#    Retourne la liste des binnings disponibles de la camera
#
proc ::webcam::getBinningList { } {
   set binningList { 1x1 }
   return $binningList
}

#
# ::webcam::getBinningListScan
#    Retourne la liste des binnings disponibles pour les scans de la camera
#
proc ::webcam::getBinningListScan { } {
   set binningListScan { }
   return $binningListScan
}

#
# ::webcam::hasLongExposure
#    Retourne le mode longue pose de la camera (1 : oui , 0 : non)
#
proc ::webcam::hasLongExposure { } {
   return 1
}

#
# ::webcam::getLongExposure
#    Retourne 1 si le mode longue pose est activé
#    Sinon retourne 0
#
proc ::webcam::getLongExposure { cam_item } {
   return $::conf(webcam,$cam_item,longuepose)
}

#
# ::webcam::hasVideo
#    Retourne le mode video de la camera (1 : oui , 0 : non)
#
proc ::webcam::hasVideo { } {
   return 1
}

#
# ::webcam::hasScan
#    Retourne le mode scan de la camera (1 : Oui , 0 : Non)
#
proc ::webcam::hasScan { } {
   return 0
}

#
# ::webcam::hasShutter
#    Retourne la presence d'un obturateur (1 : Oui , 0 : Non)
#
proc ::webcam::hasShutter { } {
   return 0
}

#
# ::webcam::getShutterOption
#    Retourne le mode de fonctionnement de l'obturateur (O : Ouvert , F : Ferme , S : Synchro)
#
proc ::webcam::getShutterOption { } {
   set ShutterOptionList { }
   return $ShutterOptionList
}

