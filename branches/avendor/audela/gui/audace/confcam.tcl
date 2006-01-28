#
# Fichier : confcam.tcl
# Description : Gere des objets 'camera'
# Date de mise a jour : 13 novembre 2005
#

#--- Initialisation des variables confCam(camera,connect), confCam(audine,connect), confCam(kitty,connect)
#--- confCam(webcam,connect), confCam(ethernaude,connect) et confCam(apn,connect)
global confCam

set confCam(camera,connect)     "0"
set confCam(audine,connect)     "0"
set confCam(kitty,connect)      "0"
set confCam(webcam,connect)     "0"
set confCam(ethernaude,connect) "0"
set confCam(apn,connect)        "0"

namespace eval ::confCam {
   namespace export run
   namespace export ok
   namespace export appliquer
   namespace export fermer
   variable This
   global confCam

   #
   # confCam::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables conf(...) et caption(...) 
   # Demarre le driver selectionne par defaut
   #
   proc init { } {
      global audace   
      global conf
 
      #--- initConf
      if { ! [ info exists conf(camera) ] }          { set conf(camera)          "audine" }
      if { ! [ info exists conf(camera,start) ] }    { set conf(camera,start)    "0" }
      if { ! [ info exists conf(camera,position) ] } { set conf(camera,position) "+25+45" }

      #--- Charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_caption) confcam.cap ]\""

      #--- Charge les fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine obtu_pierre.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine testaudine.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera ethernaude alaudine_nt.tcl ]\""
   }

   #
   # confCam::run
   # Cree la fenetre de choix et de configuration des cameras
   # This = chemin de la fenetre
   # conf(camera) = nom de la camera (audine hisis sbig cb245 starlight kitty webcam audinet ethernaude \
   # th7852a scr1300xtc apn andor)
   #
   proc run { } {
      variable This
      global audace
      global confCam
      global conf

      set This "$audace(base).confCam"
      createDialog
      if { [ info exists conf ] } {
         select $conf(camera)
         if { [ string compare $conf(camera) sbig ] == "0" } {
            ::confCam::SbigDispTemp
         } elseif { [ string compare $conf(camera) kitty ] == "0" } {
            ::confCam::KittyDispTemp
         } elseif { [ string compare $conf(camera) andor ] == "0" } {
            ::confCam::AndorDispTemp
         }
      } else {
         select audine
      }
      catch { tkwait visibility $This }
   }

   #
   # confCam::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
   # la configuration, et fermer la fenetre de reglage de la camera
   #
   proc ok { } {
      variable This

      $This.cmd.ok configure -relief groove -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      appliquer
      fermer
   }

   #
   # confCam::appliquer
   # Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
   # memoriser et appliquer la configuration
   #
   proc appliquer { } {
      variable This

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -relief groove -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      widgetToConf
      configureCamera
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -relief raised -state normal
      $This.cmd.aide configure -state normal
      $This.cmd.fermer configure -state normal
   }

   #
   # confCam::afficherAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficherAide { } {
      variable This
      global audace
      global confCam
      global help

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -relief groove -state disabled
      $This.cmd.fermer configure -state disabled
      ::audace::showHelpPlugin camera $confCam(cam) "$confCam(cam).htm"
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -state normal
      $This.cmd.aide configure -relief raised -state normal
      $This.cmd.fermer configure -state normal
   }

   #
   # confCam::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::confCam::recup_position
      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -relief groove -state disabled
      destroy $This
   }

   #
   # confCam::ConfAudine
   # Permet d'activer ou de desactiver le bouton Tests pour la fabrication de la camera Audine
   #
   proc ConfAudine { } {
      global audace
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera1)
         if { $confCam(audine,connect) == "1" } {
            #--- Bouton Tests pour la fabrication de la camera actif
            $frm.test configure -state normal -command { ::testAudine::run "$audace(base).testAudine" }
         } else {
            #--- Bouton Tests pour la fabrication de la camera inactif
            $frm.test configure -state disabled
         }
      }
   }

   #
   # confCam::ConfKitty
   # Permet d'activer ou de desactiver les boutons de configuration de la Kitty K2
   #
   proc ConfKitty { } {
      global audace
      global conf
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera6)
         if { ( $confCam(kitty,connect) == "1" ) && ( $conf(kitty,modele) == "K2" ) } {
            #--- Boutons de configuration de la Kitty K2 actif
            $frm.radio_on configure -state normal -command { cam$audace(camNo) cooler on }
            $frm.radio_off configure -state normal -command { cam$audace(camNo) cooler off }
            $frm.temp_ccd configure -state normal
            $frm.test configure -state normal -command { cam$audace(camNo) sx28test }
         } else {
            #--- Boutons de configuration de la Kitty K2 inactif
            $frm.radio_on configure -state disabled
            $frm.radio_off configure -state disabled
            $frm.temp_ccd configure -state disabled
            $frm.test configure -state disabled
         }
      }
   }

   #
   # confCam::ConfWebCam
   # Permet d'activer ou de desactiver les boutons de configuration de la WebCam
   #
   proc ConfWebCam { } {
      global audace
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera7)
         if { $confCam(webcam,connect) == "1" } {
            #--- Boutons de configuration de la WebCam actif
            $frm.conf_webcam configure -state normal -command { cam$audace(camNo) videosource }
            $frm.format_webcam configure -state normal -command { cam$audace(camNo) videoformat }
         } else {
            #--- Boutons de configuration de la WebCam inactif
	      $frm.conf_webcam configure -state disabled
            $frm.format_webcam configure -state disabled
         }
      }
   }

   #
   # confCam::ConfEthernAude
   # Permet d'activer ou de desactiver le bouton Alimentation AlAudine NT avec port I2C
   #
   proc ConfEthernAude { } {
      global audace
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera9)
         if { $confCam(ethernaude,connect) == "1" } {
            #--- Bouton Alimentation AlAudine NT avec port I2C actif
            $frm.alaudine_nt configure -state normal -command { ::AlAudine_NT::run "$audace(base).alimAlAudineNT" }
         } else {
            #--- Bouton Alimentation AlAudine NT avec port I2C inactif
            $frm.alaudine_nt configure -state disabled
         }
      }
   }

   #
   # confCam::ConfAPN
   # Permet d'activer ou de desactiver les boutons de configuration de l'APN
   #
   proc ConfAPN { } {
      global audace
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera12)
         if { $confCam(apn,connect) == "1" } {
            #--- Boutons de configuration de la video de l'APN actif
            $frm.video.source configure -state normal -command { cam$audace(camNo) videosource }
            $frm.video.format configure -state normal -command { cam$audace(camNo) videoformat }
         } else {
            #--- Boutons de configuration de la video de l'APN inactif
            $frm.video.source configure -state disabled
            $frm.video.format configure -state disabled
         }
      }
   }

   #
   # confCam::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre de configuration de la camera
   #
   proc recup_position { } {
      variable This
      global conf
      global confCam

      set confCam(camera,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $confCam(camera,geometry) ] ]
      set fin [ string length $confCam(camera,geometry) ]
      set confCam(camera,position) "+[ string range $confCam(camera,geometry) $deb $fin ]"
      #---
      set conf(camera,position) $confCam(camera,position)
   }	

   proc createDialog { } {
      variable This
      global audace
      global conf
      global confCam
      global caption

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         select $conf(camera)
         focus $This
         return
      }
      #---
      set confCam(camera,position) $conf(camera,position)
      #---
      if { [ info exists confCam(camera,geometry) ] } {
         set deb [ expr 1 + [ string first + $confCam(camera,geometry) ] ]
         set fin [ string length $confCam(camera,geometry) ]
         set confCam(camera,position) "+[ string range $confCam(camera,geometry) $deb $fin ]"
      }
      #---
      toplevel $This
      if { $::tcl_platform(os) == "Linux" } {
         wm geometry $This 900x360$confCam(camera,position)
         wm minsize $This 900 360
      } else {
         wm geometry $This 670x360$confCam(camera,position)
         wm minsize $This 670 360
      }
      wm resizable $This 1 0
      wm deiconify $This
      wm title $This "$caption(confcam,config)"
      wm protocol $This WM_DELETE_WINDOW ::confCam::fermer

      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set nn $This.usr.book
         Rnotebook:create $nn -tabs "[ list Audine Hi-SIS SBIG CB245 Starlight Kitty WebCam AudiNet EthernAude \
            TH7852A SCR1300XTC $caption(confcam,apn) Andor DigiCam ]" -borderwidth 1
         fillPage1  $nn
         fillPage2  $nn
         fillPage3  $nn
         fillPage4  $nn
         fillPage5  $nn
         fillPage6  $nn
         fillPage7  $nn
         fillPage8  $nn
         fillPage9  $nn
         fillPage10 $nn
         fillPage11 $nn
         fillPage12 $nn
         fillPage13 $nn
         fillPage14 $nn
         pack $nn -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      frame $This.start -borderwidth 1 -relief raised
         checkbutton $This.start.chk -text "$caption(confcam,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(camera,start)
         pack $This.start.chk -side top -padx 3 -pady 3 -fill x
      pack $This.start -side top -fill x
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(confcam,ok)" -width 7 -command { ::confCam::ok }
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(confcam,appliquer)" -width 8 -command { ::confCam::appliquer }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(confcam,fermer)" -width 7 -command { ::confCam::fermer }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(confcam,aide)" -width 7 -command { ::confCam::afficherAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # Fenetre de configuration de Audine
   #
   proc fillPage1 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(audine,ampli_ccd) ] } { set conf(audine,ampli_ccd) "1" }
      if { ! [ info exists conf(audine,can) ] }       { set conf(audine,can)       "$caption(confcam,can_ad976a)" }
      if { ! [ info exists conf(audine,ccd) ] }       { set conf(audine,ccd)       "$caption(confcam,kaf400)" }
      if { ! [ info exists conf(audine,foncobtu) ] }  { set conf(audine,foncobtu)  "2" }
      if { ! [ info exists conf(audine,mirx) ] }      { set conf(audine,mirx)      "0" }
      if { ! [ info exists conf(audine,miry) ] }      { set conf(audine,miry)      "0" }
      if { ! [ info exists conf(audine,port) ] }      { set conf(audine,port)      "lpt1" }
      if { ! [ info exists conf(audine,typeobtu) ] }  { set conf(audine,typeobtu)  "$caption(confcam,obtu_audine)" }

      #--- confToWidget
      set confCam(conf_audine,ampli_ccd) [ lindex "$caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours)" $conf(audine,ampli_ccd) ]
      set confCam(conf_audine,can)       $conf(audine,can)      
      set confCam(conf_audine,ccd)       $conf(audine,ccd)
      set confCam(conf_audine,foncobtu)  [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(audine,foncobtu) ]
      set confCam(conf_audine,mirx)      $conf(audine,mirx)
      set confCam(conf_audine,miry)      $conf(audine,miry)
      set confCam(conf_audine,port)      $conf(audine,port)
      set confCam(conf_audine,typeobtu)  $conf(audine,typeobtu)

      #--- Initialisation
      set frmm(Camera1) [ Rnotebook:frame $nn 1 ]
      set frm $frmm(Camera1)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame2 -side left -fill both -expand 1 -padx 80

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame5 -side top -fill both -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame5 -side top -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame6 -side top -fill both -expand 1

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame6 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame16 -borderwidth 0 -relief raised
      pack $frm.frame16 -in $frm.frame8 -side top -fill both -expand 1

      frame $frm.frame17 -borderwidth 0 -relief raised
      pack $frm.frame17 -in $frm.frame8 -side top -fill both -expand 1

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame10 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) $caption(confcam,quicka) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame10 -anchor center -side right -padx 10

      #--- Definition du format du CCD
      label $frm.lab2 -text "$caption(confcam,format_ccd)"
	pack $frm.lab2 -in $frm.frame11 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,kaf400) $caption(confcam,kaf1600) $caption(confcam,kaf3200) ]
      ComboBox $frm.ccd \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,ccd) \
         -values $list_combobox
	pack $frm.ccd -in $frm.frame11 -anchor center -side right -padx 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_audine,mirx)
	pack $frm.mirx -in $frm.frame12 -anchor center -side left -padx 20

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_audine,miry)
	pack $frm.miry -in $frm.frame13 -anchor center -side left -padx 20

      #--- Fonctionnement de l'ampli du CCD
      label $frm.lab3 -text "$caption(confcam,ampli_ccd)"
	pack $frm.lab3 -in $frm.frame14 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours) ]
      ComboBox $frm.ampli_ccd \
         -width 10         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,ampli_ccd) \
         -values $list_combobox
 	pack $frm.ampli_ccd -in $frm.frame14 -anchor center -side right -padx 10

      #--- Modele du CAN
      label $frm.lab4 -text "$caption(confcam,modele_can)"
	pack $frm.lab4 -in $frm.frame15 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,can_ad976a) $caption(confcam,can_ltc1605) ]
      ComboBox $frm.can \
         -width 10         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,can) \
         -values $list_combobox
 	pack $frm.can -in $frm.frame15 -anchor center -side right -padx 10

      #--- Definition du type d'obturateur
      label $frm.lab5 -text "$caption(confcam,type_obtu)"
	pack $frm.lab5 -in $frm.frame16 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,obtu_audine) $caption(confcam,obtu_audine-) \
         $caption(confcam,obtu_thierry) ]
      ComboBox $frm.typeobtu \
         -width 11         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,typeobtu) \
         -values $list_combobox
      pack $frm.typeobtu -in $frm.frame16 -anchor center -side right -padx 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab6 -text "$caption(confcam,fonc_obtu)"
	pack $frm.lab6 -in $frm.frame17 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,foncobtu) \
         -values $list_combobox
 	pack $frm.foncobtu -in $frm.frame17 -anchor center -side right -padx 10

      #--- Bouton de test d'une Audine en fabrication
      button $frm.test -text "$caption(confcam,test_fab_audine)" -relief raised \
         -command { ::testAudine::run "$audace(base).testAudine" }
      pack $frm.test -in $frm.frame3 -side top -pady 10 -ipadx 10 -ipady 5 -expand true

      #--- Gestion du bouton actif/inactif
      ::confCam::ConfAudine

      #--- Site web officiel de l'Audine
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_audine)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_audine)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera1)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera1)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 1 ] <Button-1> { global confCam ; set confCam(cam) "audine" }
   }

   #
   # Fenetre de configuration des Hi-SIS
   #
   proc fillPage2 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(hisis,delai_a) ] }  { set conf(hisis,delai_a)  "5" }
      if { ! [ info exists conf(hisis,delai_b) ] }  { set conf(hisis,delai_b)  "2" }
      if { ! [ info exists conf(hisis,delai_c) ] }  { set conf(hisis,delai_c)  "7" }
      if { ! [ info exists conf(hisis,foncobtu) ] } { set conf(hisis,foncobtu) "2" }
      if { ! [ info exists conf(hisis,mirx) ] }     { set conf(hisis,mirx)     "0" }
      if { ! [ info exists conf(hisis,miry) ] }     { set conf(hisis,miry)     "0" }
      if { ! [ info exists conf(hisis,modele) ] }   { set conf(hisis,modele)   "22" }
      if { ! [ info exists conf(hisis,port) ] }     { set conf(hisis,port)     "lpt1" }
      if { ! [ info exists conf(hisis,res) ] }      { set conf(hisis,res)      "12 bits" }

      #--- confToWidget
      set confCam(conf_hisis,delai_a)  $conf(hisis,delai_a)
      set confCam(conf_hisis,delai_b)  $conf(hisis,delai_b)
      set confCam(conf_hisis,delai_c)  $conf(hisis,delai_c)
      set confCam(conf_hisis,foncobtu) [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(hisis,foncobtu) ]
      set confCam(conf_hisis,mirx)     $conf(hisis,mirx)
      set confCam(conf_hisis,miry)     $conf(hisis,miry)
      set confCam(conf_hisis,modele)   [ lsearch "11 22 23 24 33 36 39 43 44 48" "$conf(hisis,modele)" ]
      set confCam(conf_hisis,port)     $conf(hisis,port)
      set confCam(conf_hisis,res)      $conf(hisis,res)

      #--- Initialisation
      set frmm(Camera2) [ Rnotebook:frame $nn 2 ]
      set frm $frmm(Camera2)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x -pady 10

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x -pady 10

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame5 -side top -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame5 -side top -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame7 -side left -fill both -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame7 -side left -fill both -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame9 -side top -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame9 -side top -fill both -expand 1

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame6 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame6 -side top -fill both -expand 1

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame6 -side top -fill both -expand 1

      #--- Bouton radio Hi-SIS11
      radiobutton $frm.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_11)" -value 0 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab0 ; destroy $frm.foncobtu
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio0 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS22
      radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_22)" -value 1 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Resolution
            label $frm.lab2 -text "$caption(confcam,can_resolution)"
	      pack $frm.lab2 -in $frm.frame12 -anchor center -side left -padx 10
            set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_14bits) ]
            ComboBox $frm.res \
               -width 7          \
               -height [ llength $list_combobox ]  \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -textvariable confCam(conf_hisis,res) \
               -values $list_combobox
	      pack $frm.res -in $frm.frame12 -anchor center -side right -padx 20
            #--- Parametrage des delais
            label $frm.lab3 -text "$caption(confcam,delai_a)"
	      pack $frm.lab3 -in $frm.frame13 -anchor center -side left -padx 10
            entry $frm.delai_a -textvariable confCam(conf_hisis,delai_a) -width 3 -justify center
	      pack $frm.delai_a -in $frm.frame13 -anchor center -side left
            label $frm.lab4 -text "$caption(confcam,delai_b)"
	      pack $frm.lab4 -in $frm.frame14 -anchor center -side left -padx 10
            entry $frm.delai_b -textvariable confCam(conf_hisis,delai_b) -width 3 -justify center
	      pack $frm.delai_b -in $frm.frame14 -anchor center -side left
            label $frm.lab5 -text "$caption(confcam,delai_c)"
	      pack $frm.lab5 -in $frm.frame15 -anchor center -side left -padx 10
            entry $frm.delai_c -textvariable confCam(conf_hisis,delai_c) -width 3 -justify center
	      pack $frm.delai_c -in $frm.frame15 -anchor center -side left
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS23
      radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_23)" -value 2 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio2 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS24
      radiobutton $frm.radio3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_24)" -value 3 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio3 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS33
      radiobutton $frm.radio4 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_33)" -value 4 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio4 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS36
      radiobutton $frm.radio5 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_36)" -value 5 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio5 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS39
      radiobutton $frm.radio6 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_39)" -value 6 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio6 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS43
      radiobutton $frm.radio7 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_43)" -value 7 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio7 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS44
      radiobutton $frm.radio8 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_44)" -value 8 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio8 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS48
      radiobutton $frm.radio9 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_48)" -value 9 -variable confCam(conf_hisis,modele) -command {
            set frm $frmm(Camera2)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            catch {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ]  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_hisis,foncobtu) \
                  -values $list_combobox
	         pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio9 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Choix du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame11 -anchor center -side left -padx 10
      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_hisis,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame11 -anchor center -side right -padx 20
      #--- Choix de la resolution et des delais
      if { $confCam(conf_hisis,modele) == "1" } {
         set confCam(conf_hisis,delai_a) $conf(hisis,delai_a)
         set confCam(conf_hisis,delai_b) $conf(hisis,delai_b)
         set confCam(conf_hisis,delai_c) $conf(hisis,delai_c)
         label $frm.lab2 -text "$caption(confcam,can_resolution)"
	   pack $frm.lab2 -in $frm.frame12 -anchor center -side left -padx 10
         set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_14bits) ]
         ComboBox $frm.res \
            -width 7          \
            -height [ llength $list_combobox ]  \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(conf_hisis,res) \
            -values $list_combobox
	   pack $frm.res -in $frm.frame12 -anchor center -side right -padx 20
         label $frm.lab3 -text "$caption(confcam,delai_a)"
	   pack $frm.lab3 -in $frm.frame13 -anchor center -side left -padx 10
         entry $frm.delai_a -textvariable confCam(conf_hisis,delai_a) -width 3 -justify center
	   pack $frm.delai_a -in $frm.frame13 -anchor center -side left -padx 10
         label $frm.lab4 -text "$caption(confcam,delai_b)"
	   pack $frm.lab4 -in $frm.frame14 -anchor center -side left -padx 10
         entry $frm.delai_b -textvariable confCam(conf_hisis,delai_b) -width 3 -justify center
	   pack $frm.delai_b -in $frm.frame14 -anchor center -side left -padx 10
         label $frm.lab5 -text "$caption(confcam,delai_c)"
	   pack $frm.lab5 -in $frm.frame15 -anchor center -side left -padx 10
         entry $frm.delai_c -textvariable confCam(conf_hisis,delai_c) -width 3 -justify center
	   pack $frm.delai_c -in $frm.frame15 -anchor center -side left -padx 10
      } else {
         destroy $frm.lab2
         destroy $frm.res
         destroy $frm.lab3
         destroy $frm.delai_a
         destroy $frm.lab4
         destroy $frm.delai_b
         destroy $frm.lab5
         destroy $frm.delai_c
      }

      #--- Choix des miroir de l'image
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_hisis,mirx)
	pack $frm.mirx -in $frm.frame10 -anchor w -side top -padx 10 -pady 10
      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_hisis,miry)
	pack $frm.miry -in $frm.frame10 -anchor w -side bottom -padx 10 -pady 10

      #--- Choix du fonctionnement de l'obturateur
      if { $confCam(conf_hisis,modele) != "0" } {
         label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
	   pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 8
         set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
            $caption(confcam,obtu_synchro) ]
         ComboBox $frm.foncobtu \
            -width 11         \
            -height [ llength $list_combobox ]  \
            -relief sunken    \
            -borderwidth 1    \
            -textvariable confCam(conf_hisis,foncobtu) \
            -editable 0       \
            -values $list_combobox
	   pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
      } else {
         destroy $frm.lab0
         destroy $frm.foncobtu
      }

      #--- Site web officiel des Hi-SIS
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_hisis)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_hisis)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera2)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera2)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 2 ] <Button-1> { global confCam ; set confCam(cam) "hisis" }
   }

   #
   # Fenetre de configuration de la SBIG
   #
   proc fillPage3 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(sbig,cool) ] }     { set conf(sbig,cool)     "0" }
      if { ! [ info exists conf(sbig,foncobtu) ] } { set conf(sbig,foncobtu) "2" }
      if { ! [ info exists conf(sbig,host) ] }     { set conf(sbig,host)     "192.168.0.2" }
      if { ! [ info exists conf(sbig,mirx) ] }     { set conf(sbig,mirx)     "0" }
      if { ! [ info exists conf(sbig,miry) ] }     { set conf(sbig,miry)     "0" }
      if { ! [ info exists conf(sbig,port) ] }     { set conf(sbig,port)     "lpt1" }
      if { ! [ info exists conf(sbig,temp) ] }     { set conf(sbig,temp)     "0" }

      #--- confToWidget
      set confCam(conf_sbig,cool)     $conf(sbig,cool)
      set confCam(conf_sbig,foncobtu) [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(sbig,foncobtu) ]
      set confCam(conf_sbig,host)     $conf(sbig,host)
      set confCam(conf_sbig,mirx)     $conf(sbig,mirx)
      set confCam(conf_sbig,miry)     $conf(sbig,miry)
      set confCam(conf_sbig,port)     $conf(sbig,port)
      set confCam(conf_sbig,temp)     $conf(sbig,temp)

      #--- Initialisation
      set frmm(Camera3) [ Rnotebook:frame $nn 3 ]
      set frm $frmm(Camera3)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill x -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame2 -side left -fill x -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
	pack $frm.frame7 -in $frm.frame5 -side top -fill x -padx 30

      frame $frm.frame8 -borderwidth 0 -relief raised
	pack $frm.frame8 -in $frm.frame5 -side top -fill x -padx 30

      frame $frm.frame9 -borderwidth 0 -relief raised
	pack $frm.frame9 -in $frm.frame5 -side top -fill x -padx 30

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10

      if { $::tcl_platform(os) == "Linux" } {
         set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) \
            $caption(confcam,lpt3) ]
      } else {
         set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) $caption(confcam,lpt3) \
            $caption(confcam,usb) $caption(confcam,ethernet) ]
      }
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_sbig,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du host pour une connexion Ethernet
      if { $::tcl_platform(os) != "Linux" } {
         entry $frm.host -width 18 -textvariable confCam(conf_sbig,host)
	   pack $frm.host -in $frm.frame1 -anchor center -side right -padx 10

         label $frm.lab2 -text "$caption(confcam,host_sbig)"
	   pack $frm.lab2 -in $frm.frame1 -anchor center -side right -padx 10
      }

      #--- Definition du refroidissement
      checkbutton $frm.cool -text "$caption(confcam,refroidissement)" -highlightthickness 0 \
         -variable confCam(conf_sbig,cool)
      pack $frm.cool -in $frm.frame7 -anchor center -side left -padx 0 -pady 5

      entry $frm.temp -textvariable confCam(conf_sbig,temp) -width 4 -justify center
	pack $frm.temp -in $frm.frame7 -anchor center -side left -padx 5 -pady 5

      label $frm.tempdeg -text "$caption(confcam,deg_c) $caption(confcam,refroidissement_1)"
	pack $frm.tempdeg -in $frm.frame7 -side left -fill x -padx 0 -pady 5

      label $frm.power -text "$caption(confcam,puissance_peltier_-)"
	pack $frm.power -in $frm.frame8 -side left -fill x -padx 20 -pady 5

      label $frm.ccdtemp -text "$caption(confcam,temp_ext)"
	pack $frm.ccdtemp -in $frm.frame9 -side left -fill x -padx 20 -pady 5

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_sbig,mirx)
	pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_sbig,miry)
	pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab3 -text "$caption(confcam,fonc_obtu)"
	pack $frm.lab3 -in $frm.frame3 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_sbig,foncobtu) \
         -values $list_combobox
      pack $frm.foncobtu -in $frm.frame3 -anchor center -side left -padx 10

      #--- Site web officiel de la SBIG
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_sbig)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_sbig)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera3)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera3)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 3 ] <Button-1> { global confCam ; set confCam(cam) "sbig" }
   }

   #
   # Fenetre de configuration de la CB245
   #
   proc fillPage4 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(cb245,mirx) ] } { set conf(cb245,mirx) "0" }
      if { ! [ info exists conf(cb245,miry) ] } { set conf(cb245,miry) "0" }
      if { ! [ info exists conf(cb245,port) ] } { set conf(cb245,port) "lpt1" }

      #--- confToWidget
      set confCam(conf_cb245,mirx) $conf(cb245,mirx)
      set confCam(conf_cb245,miry) $conf(cb245,miry)
      set confCam(conf_cb245,port) $conf(cb245,port)

      #--- Initialisation
      set frmm(Camera4) [ Rnotebook:frame $nn 4 ]
      set frm $frmm(Camera4)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1 -padx 80

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame3 -anchor n -side left -fill x -pady 18

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame3 -anchor n -side left -fill x -pady 15

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_cb245,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_cb245,mirx)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_cb245,miry)
	pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      #--- Site web officiel de la CB245
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_cb245)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_cb245)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera4)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera4)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 4 ] <Button-1> { global confCam ; set confCam(cam) "cb245" }
   }

   #
   # Fenetre de configuration des Starlight
   #
   proc fillPage5 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(starlight,acc) ] }    { set conf(starlight,acc)    "0" }
      if { ! [ info exists conf(starlight,mirx) ] }   { set conf(starlight,mirx)   "0" }
      if { ! [ info exists conf(starlight,miry) ] }   { set conf(starlight,miry)   "0" }
      if { ! [ info exists conf(starlight,modele) ] } { set conf(starlight,modele) "MX516" }
      if { ! [ info exists conf(starlight,port) ] }   { set conf(starlight,port)   "lpt1" }

      #--- confToWidget
      set confCam(conf_starlight,acc)    [ lindex "$caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur)" $conf(starlight,acc) ]
      set confCam(conf_starlight,mirx)   $conf(starlight,mirx)
      set confCam(conf_starlight,miry)   $conf(starlight,miry)
      set confCam(conf_starlight,modele) [ lsearch "MX516 MX916 HX516" "$conf(starlight,modele)" ]
      set confCam(conf_starlight,port)   $conf(starlight,port)

      #--- Initialisation
      set frmm(Camera5) [ Rnotebook:frame $nn 5 ]
      set frm $frmm(Camera5)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame2 -side left -fill both -expand 1 -padx 80

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame5 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame5 -side left -fill both -expand 1

      #--- Bouton radio MX516
      radiobutton $frm.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,starlight_mx5)" -value 0 -variable confCam(conf_starlight,modele)
      pack $frm.radio0 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio MX916
      radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,starlight_mx9)" -value 1 -variable confCam(conf_starlight,modele)
	pack $frm.radio1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio HX516
      radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,starlight_hx5)" -value 2 -variable confCam(conf_starlight,modele)
	pack $frm.radio2 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame7 -anchor n -side left -padx 10 -pady 15

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_starlight,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame7 -anchor n -side left -padx 10 -pady 15

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_starlight,mirx)
      pack $frm.mirx -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_starlight,miry)
	pack $frm.miry -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      #--- Accelerateur de port parallele
      label $frm.lab2 -text "$caption(confcam,accelerateur)"
	pack $frm.lab2 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

      set list_combobox [ list $caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur) ]
      ComboBox $frm.acc \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_starlight,acc) \
         -values $list_combobox
	pack $frm.acc -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

      #--- Site web officiel des Starlight
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_starlight)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_starlight)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera5)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera5)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 5 ] <Button-1> { global confCam ; set confCam(cam) "starlight" }
   }

   #
   # Fenetre de configuration des Kitty
   #
   proc fillPage6 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(kitty,captemp) ] } { set conf(kitty,captemp) "0" }
      if { ! [ info exists conf(kitty,mirx) ] }    { set conf(kitty,mirx)    "0" }
      if { ! [ info exists conf(kitty,miry) ] }    { set conf(kitty,miry)    "0" }
      if { ! [ info exists conf(kitty,modele) ] }  { set conf(kitty,modele)  "237" }
      if { ! [ info exists conf(kitty,port) ] }    { set conf(kitty,port)    "lpt1" }
      if { ! [ info exists conf(kitty,res) ] }     { set conf(kitty,res)     "12 bits" }
      if { ! [ info exists conf(kitty,on_off) ] }  { set conf(kitty,on_off)  "1" }

      #--- confToWidget
      set confCam(conf_kitty,captemp) [ lindex "$caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5)" $conf(kitty,captemp) ]
      set confCam(conf_kitty,mirx)    $conf(kitty,mirx)
      set confCam(conf_kitty,miry)    $conf(kitty,miry)
      set confCam(conf_kitty,modele)  $conf(kitty,modele)
      set confCam(conf_kitty,port)    $conf(kitty,port)
      set confCam(conf_kitty,res)     $conf(kitty,res)
      set confCam(conf_kitty,on_off)  $conf(kitty,on_off)

      #--- Initialisation
      set frmm(Camera6) [ Rnotebook:frame $nn 6 ]
      set frm $frmm(Camera6)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame2 -side left -fill both -expand 1 -padx 80

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame5 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame5 -side left -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame8 -side top -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame8 -side top -fill both -expand 1

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame3 -side top -fill both -expand 1

      #--- Bouton radio Kitty-237
      radiobutton $frm.radio0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,kitty_237)" -value 237 -variable confCam(conf_kitty,modele) -command {
            set frm $frmm(Camera6)
            catch {
               destroy $frm.lab4 ; destroy $frm.radio_on ; destroy $frm.radio_off
               destroy $frm.temp_ccd ; destroy $frm.test
            }
            #--- Definition de la resolution
            label $frm.lab2 -text "$caption(confcam,can_resolution)"
	      pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10
            #---
            set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_8bits) ]
            ComboBox $frm.res \
               -width 7          \
               -height [ llength $list_combobox ]  \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -textvariable confCam(conf_kitty,res) \
               -values $list_combobox
	      pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
            #--- Definition du capteur de temperature
            label $frm.lab3 -text "$caption(confcam,capteur_temp)"
	      pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            #---
            set list_combobox [ list $caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5) ]
            ComboBox $frm.captemp \
               -width 12         \
               -height [ llength $list_combobox ]  \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -textvariable confCam(conf_kitty,captemp) \
               -values $list_combobox
	      pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            #--- Gestion des boutons actif/inactif
            ::confCam::ConfKitty
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio0 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Kitty-255
      radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,kitty_255)" -value 255 -variable confCam(conf_kitty,modele) -state disabled -command {
            set frm $frmm(Camera6)
            catch {
               destroy $frm.lab4 ; destroy $frm.radio_on ; destroy $frm.radio_off
               destroy $frm.temp_ccd ; destroy $frm.test
            }
            #--- Definition de la resolution
            label $frm.lab2 -text "$caption(confcam,can_resolution)"
	      pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10
            #---
            set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_8bits) ]
            ComboBox $frm.res \
               -width 7          \
               -height [ llength $list_combobox ]  \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -textvariable confCam(conf_kitty,res) \
               -values $list_combobox
	      pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
            #--- Definition du capteur de temperature
            label $frm.lab3 -text "$caption(confcam,capteur_temp)"
	      pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            #---
            set list_combobox [ list $caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5) ]
            ComboBox $frm.captemp \
               -width 12         \
               -height [ llength $list_combobox ]  \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -textvariable confCam(conf_kitty,captemp) \
               -values $list_combobox
	      pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            #--- Gestion des boutons actif/inactif
            ::confCam::ConfKitty
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Kitty-2
      radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,kitty_2)" -value K2 -variable confCam(conf_kitty,modele) -command {
            set frm $frmm(Camera6)
            catch {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.captemp
            }
            #--- Definition du refroidissement
            label $frm.lab4 -text "$caption(confcam,refroidissement_2)"
	      pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10
            #--- Refroidissement On
            radiobutton $frm.radio_on -anchor w -highlightthickness 0 \
               -text "$caption(confcam,refroidissement_on)" -value 1 \
               -variable confCam(conf_kitty,on_off) -command { cam$audace(camNo) cooler on }
            pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
            #--- Refroidissement Off
            radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
               -text "$caption(confcam,refroidissement_off)" -value 0 \
               -variable confCam(conf_kitty,on_off) -command { cam$audace(camNo) cooler off }
            pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
            #--- Definition de la temperature du capteur CCD
            label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
	      pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
            #--- Bouton de test du microcontrolleur de la carte d'interface
            button $frm.test -text "$caption(confcam,test)" -relief raised \
               -command { cam$audace(camNo) sx28test }
            pack $frm.test -in $frm.frame14 -side left -padx 10 -pady 0 -ipadx 10 -ipady 5
            #--- Gestion des boutons actif/inactif
            ::confCam::ConfKitty
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
	pack $frm.radio2 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame9 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_kitty,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame9 -anchor center -side right -padx 10

      #--- Definition de la resolution
      if { $confCam(conf_kitty,modele) != "K2" } {
         label $frm.lab2 -text "$caption(confcam,can_resolution)"
	   pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10

         set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_8bits) ]
         ComboBox $frm.res \
            -width 7          \
            -height [ llength $list_combobox ]  \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(conf_kitty,res) \
            -values $list_combobox
	   pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
      }

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_kitty,mirx)
	pack $frm.mirx -in $frm.frame11 -anchor w -side left -padx 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_kitty,miry)
	pack $frm.miry -in $frm.frame12 -anchor w -side left -padx 10

      #--- Definition du capteur de temperature
      if { $confCam(conf_kitty,modele) != "K2" } {
         label $frm.lab3 -text "$caption(confcam,capteur_temp)"
	   pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

         set list_combobox [ list $caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5) ]
         ComboBox $frm.captemp \
            -width 12         \
            -height [ llength $list_combobox ]  \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(conf_kitty,captemp) \
            -values $list_combobox
	   pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
      #--- Definition du refroidissement, de la temperature du CCD et du test
      } else {
         #--- Definition du refroidissement
         label $frm.lab4 -text "$caption(confcam,refroidissement_2)"
	   pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10
         #--- Refroidissement On
         radiobutton $frm.radio_on -anchor w -highlightthickness 0 \
            -text "$caption(confcam,refroidissement_on)" -value 1 \
            -variable confCam(conf_kitty,on_off) -command { cam$audace(camNo) cooler on }
         pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Refroidissement Off
         radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
            -text "$caption(confcam,refroidissement_off)" -value 0 \
            -variable confCam(conf_kitty,on_off) -command { cam$audace(camNo) cooler off }
         pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Definition de la temperature du capteur CCD
         label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
	   pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
         #--- Bouton de test du microcontrolleur de la carte d'interface
         button $frm.test -text "$caption(confcam,test)" -relief raised \
            -command { cam$audace(camNo) sx28test }
         pack $frm.test -in $frm.frame14 -side left -padx 10 -pady 0 -ipadx 10 -ipady 5
      }

      #--- Gestion des boutons actif/inactif
      ::confCam::ConfKitty

      #--- Site web officiel des Kitty
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_kitty)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_kitty)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera6)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera6)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 6 ] <Button-1> { global confCam ; set confCam(cam) "kitty" }
   }

   #
   # Fenetre de configuration de WebCam
   #
   proc fillPage7 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(webcam,longuepose) ] }           { set conf(webcam,longuepose)           "0" }
      if { ! [ info exists conf(webcam,longueposeport) ] }       { set conf(webcam,longueposeport)       "lpt1" }
      if { ! [ info exists conf(webcam,longueposestartvalue) ] } { set conf(webcam,longueposestartvalue) "0" }
      if { ! [ info exists conf(webcam,longueposestopvalue) ] }  { set conf(webcam,longueposestopvalue)  "1" }
      if { ! [ info exists conf(webcam,mirx) ] }                 { set conf(webcam,mirx)                 "0" }
      if { ! [ info exists conf(webcam,miry) ] }                 { set conf(webcam,miry)                 "0" }
      if { ! [ info exists conf(webcam,port) ] }                 { set conf(webcam,port)                 "0" }

      #--- confToWidget
      set confCam(conf_webcam,longuepose)           $conf(webcam,longuepose)
      set confCam(conf_webcam,longueposeport)       $conf(webcam,longueposeport)
      set confCam(conf_webcam,longueposestartvalue) $conf(webcam,longueposestartvalue)
      set confCam(conf_webcam,longueposestopvalue)  $conf(webcam,longueposestopvalue)
      set confCam(conf_webcam,mirx)                 $conf(webcam,mirx)
      set confCam(conf_webcam,miry)                 $conf(webcam,miry)
      set confCam(conf_webcam,port)                 $conf(webcam,port)

      #--- Initialisation
      set frmm(Camera7) [ Rnotebook:frame $nn 7 ]
      set frm $frmm(Camera7)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1

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

      #--- Definition du canal USB
      label $frm.lab1 -text "$caption(confcam,webcam_canal_usb)"
	pack $frm.lab1 -in $frm.frame7 -anchor center -side left -padx 10

      set list_combobox [ list 0 1 2 3 4 5 6 7 8 9 ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_webcam,port) \
         -editable 0       \
         -values $list_combobox
	pack $frm.port -in $frm.frame7 -anchor center -side left -padx 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_webcam,mirx)
      pack $frm.mirx -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_webcam,miry)
	pack $frm.miry -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      #--- Boutons de configuration de la source et du format video
      button $frm.conf_webcam -text "$caption(confcam,conf_webcam)" \
         -command { cam$audace(camNo) videosource }
      pack $frm.conf_webcam -in $frm.frame6 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true
      button $frm.format_webcam -text "$caption(confcam,format_webcam)" \
         -command { cam$audace(camNo) videoformat }
      pack $frm.format_webcam -in $frm.frame5 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

      #--- Gestion des boutons actifs/inactifs
      ::confCam::ConfWebCam

      #--- Option longue pose avec lien au site web de Steve Chambers
      checkbutton $frm.longuepose -highlightthickness 0 -variable confCam(conf_webcam,longuepose)
	pack $frm.longuepose -in $frm.frame9 -anchor center -side left -pady 3

      label $frm.labURL_a -text "$caption(confcam,webcam_longuepose)" -font $audace(font,url) -fg $color(blue)
	pack $frm.labURL_a -in $frm.frame9 -anchor center -side left -pady 3

      label $frm.lab2 -text "$caption(confcam,webcam_longueposeport)"
	pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 3 -pady 5

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.lpport \
         -width 4          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_webcam,longueposeport) \
         -values $list_combobox
	pack $frm.lpport -in $frm.frame10 -anchor center -side right -padx 10 -pady 5

      label $frm.lab3 -text "$caption(confcam,webcam_longueposestart)"
	pack $frm.lab3 -in $frm.frame11 -anchor center -side left -padx 3 -pady 5

      entry $frm.longueposestartvalue -width 4 -textvariable confCam(conf_webcam,longueposestartvalue) -justify center
	pack $frm.longueposestartvalue -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

      label $frm.lab4 -text "$caption(confcam,webcam_longueposestop)"
	pack $frm.lab4 -in $frm.frame12 -anchor center -side left -padx 3 -pady 5

      entry $frm.longueposestopvalue -width 4 -textvariable confCam(conf_webcam,longueposestopvalue) -justify center
	pack $frm.longueposestopvalue -in $frm.frame12 -anchor center -side right -padx 10 -pady 5

      #--- Site web officiel des WebCam
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_webcam)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      #--- Pour le site web de reference
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_webcam)"
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
         set filename "$caption(confcam,site_webcam_chambers)"
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

      bind [ Rnotebook:button $nn 7 ] <Button-1> { global confCam ; set confCam(cam) "webcam" }
   }

   #
   # Fenetre de configuration de AudiNet
   #
   proc fillPage8 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(audinet,ccd) ] }         { set conf(audinet,ccd)         "$caption(confcam,kaf400)" }
      if { ! [ info exists conf(audinet,foncobtu) ] }    { set conf(audinet,foncobtu)    "2" }
      if { ! [ info exists conf(audinet,host) ] }        { set conf(audinet,host)        "168.254.216.36" }
      if { ! [ info exists conf(audinet,ipsetting) ] }   { set conf(audinet,ipsetting)   "0" }
      if { ! [ info exists conf(audinet,mac_address) ] } { set conf(audinet,mac_address) "00:01:02:03:04:05" }
      if { ! [ info exists conf(audinet,mirx) ] }        { set conf(audinet,mirx)        "0" }
      if { ! [ info exists conf(audinet,miry) ] }        { set conf(audinet,miry)        "0" }
      if { ! [ info exists conf(audinet,protocole) ] }   { set conf(audinet,protocole)   "$caption(confcam,protocole_udp)" }
      if { ! [ info exists conf(audinet,typeobtu) ] }    { set conf(audinet,typeobtu)    "$caption(confcam,obtu_audine)" }
      if { ! [ info exists conf(audinet,udptempo) ] }    { set conf(audinet,udptempo)    "0" }

      #--- confToWidget
      set confCam(conf_audinet,ccd)         $conf(audinet,ccd)
      set confCam(conf_audinet,foncobtu)    [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(audinet,foncobtu) ]
      set confCam(conf_audinet,host)        $conf(audinet,host)
      set confCam(conf_audinet,ipsetting)   $conf(audinet,ipsetting)      
      set confCam(conf_audinet,mac_address) $conf(audinet,mac_address)
      set confCam(conf_audinet,mirx)        $conf(audinet,mirx)
      set confCam(conf_audinet,miry)        $conf(audinet,miry)
      set confCam(conf_audinet,protocole)   $conf(audinet,protocole)
      set confCam(conf_audinet,typeobtu)    $conf(audinet,typeobtu)
      set confCam(conf_audinet,udptempo)    $conf(audinet,udptempo)

      #--- Creation des widgets
      set frmm(Camera8) [ Rnotebook:frame $nn 8 ]
      set frm $frmm(Camera8)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame3 -side left -fill both -expand 1 -padx 80

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame6 -side left -fill x

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame6 -side left -fill x

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame10 -side top -fill x

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame10 -side top -fill x

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frameIPSetting -borderwidth 0 -relief raised
      pack $frm.frameIPSetting -in $frm.frame1 -side bottom -fill both -expand 1

      #--- Definition du host pour une connexion Ethernet
      label $frm.lab1 -text "$caption(confcam,host_audinet)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10

      entry $frm.host -width 18 -textvariable confCam(conf_audinet,host)
	pack $frm.host -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton de test de la connexion
      button $frm.ping -text "$caption(confcam,test_audinet)" -relief raised -state normal \
         -command {
            #--- Si l'envoi de l'adresse IP est demande, j'execute setip avant ping
            if { $confCam(conf_audinet,ipsetting) == "1" } {
               #--- Remarque : Comme setip est une commande specifique a une camera audinet,
               #--- il faut creer temporairement une camera de type audinet pour pouvoir executer la commande
               set camtemp [ cam::create audinet ] 
               cam$camtemp setip $confCam(conf_audinet,mac_address) $confCam(conf_audinet,host)
               cam::delete $camtemp
            } 
            #--- J'execute la commande ping   
            ::confCam::testping $confCam(conf_audinet,host)
         }
	pack $frm.ping -in $frm.frame1 -anchor center -side top -pady 7 -ipadx 10 -ipady 5 -expand true

      #--- Envoi ou non de l'adresse IP a Audinet
      checkbutton $frm.ipsetting -text "$caption(confcam,envoyer_adresse_aud)" -highlightthickness 0 \
         -variable confCam(conf_audinet,ipsetting)
	pack $frm.ipsetting -in $frm.frameIPSetting -anchor center -side left -padx 10 -pady 2

      #--- Saisie adresse MAC
      entry $frm.macaddress -width 17 -textvariable confCam(conf_audinet,mac_address)
	pack $frm.macaddress -in $frm.frameIPSetting -anchor center -side right -padx 10

      #--- Label adresse MAC
      label $frm.labMac -text "$caption(confcam,mac_address)"
	pack $frm.labMac -in $frm.frameIPSetting -anchor center -side right -padx 0

      #--- Definition du format du CCD
      label $frm.lab2 -text "$caption(confcam,format_ccd)"
      pack $frm.lab2 -in $frm.frame5 -anchor n -side left -padx 10 -pady 10

      set list_combobox [ list $caption(confcam,kaf400) $caption(confcam,kaf1600) ]
      ComboBox $frm.ccd \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audinet,ccd) \
         -values $list_combobox
	pack $frm.ccd -in $frm.frame5 -anchor n -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_audinet,mirx)
      pack $frm.mirx -in $frm.frame9 -anchor w -side top -padx 10 -pady 3

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_audinet,miry)
	pack $frm.miry -in $frm.frame9 -anchor w -side top -padx 10 -pady 3

      #--- Definition du protocole
      label $frm.lab3 -text "$caption(confcam,protocole_audinet)"
	pack $frm.lab3 -in $frm.frame11 -anchor center -side left -padx 10 -pady 5

      set list_combobox [ list $caption(confcam,protocole_udp) $caption(confcam,protocole_tcp) ]
      ComboBox $frm.protocole \
         -width 4          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audinet,protocole) \
         -values $list_combobox
	pack $frm.protocole -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

      #--- Definition de la temporisation
      label $frm.lab4 -text "$caption(confcam,tempo_udp)"
	pack $frm.lab4 -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

      entry $frm.udptempo -width 5 -textvariable confCam(conf_audinet,udptempo) -justify center
	pack $frm.udptempo -in $frm.frame12 -anchor center -side right -padx 10 -pady 5

      #--- Definition du type de l'obturateur
      label $frm.lab5 -text "$caption(confcam,type_obtu)"
	pack $frm.lab5 -in $frm.frame13 -anchor center -side left -padx 10 -pady 3

      set list_combobox [ list $caption(confcam,obtu_audine) $caption(confcam,obtu_audine-) \
         $caption(confcam,obtu_thierry) $caption(confcam,obtu_i2c) ]
      ComboBox $frm.typeobtu \
         -width 9          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audinet,typeobtu) \
         -values $list_combobox
	pack $frm.typeobtu -in $frm.frame13 -anchor center -side right -padx 10 -pady 3

      #--- Fonctionnement de l'obturateur
      label $frm.lab6 -text "$caption(confcam,fonc_obtu)"
	pack $frm.lab6 -in $frm.frame14 -anchor center -side left -padx 10 -pady 3

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 9          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audinet,foncobtu) \
         -values $list_combobox
	pack $frm.foncobtu -in $frm.frame14 -anchor center -side right -padx 10 -pady 3

      #--- Site web officiel de AudiNet
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_audinet)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_audinet)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera8)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera8)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 8 ] <Button-1> { global confCam ; set confCam(cam) "audinet" }
   }

   #
   # Fenetre de configuration de l'EthernAude
   #
   proc fillPage9 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(ethernaude,canspeed) ] }  { set conf(ethernaude,canspeed)  "7" }
      if { ! [ info exists conf(ethernaude,foncobtu) ] }  { set conf(ethernaude,foncobtu)  "2" }
      if { ! [ info exists conf(ethernaude,host) ] }      { set conf(ethernaude,host)      "192.168.0.123" }
      if { ! [ info exists conf(ethernaude,ipsetting) ] } { set conf(ethernaude,ipsetting) "0" }
      if { ! [ info exists conf(ethernaude,mirx) ] }      { set conf(ethernaude,mirx)      "0" }
      if { ! [ info exists conf(ethernaude,miry) ] }      { set conf(ethernaude,miry)      "0" }
      if { ! [ info exists conf(ethernaude,typeobtu) ] }  { set conf(ethernaude,typeobtu)  "audine" }

      #--- confToWidget
      set confCam(conf_ethernaude,canspeed)  $conf(ethernaude,canspeed)
      set confCam(conf_ethernaude,foncobtu)  [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(ethernaude,foncobtu) ]
      set confCam(conf_ethernaude,host)      $conf(ethernaude,host)
      set confCam(conf_ethernaude,ipsetting) $conf(ethernaude,ipsetting)
      set confCam(conf_ethernaude,mirx)      $conf(ethernaude,mirx)
      set confCam(conf_ethernaude,miry)      $conf(ethernaude,miry)
      set confCam(conf_ethernaude,typeobtu)  $conf(ethernaude,typeobtu)

      #--- Initialisation
      set frmm(Camera9) [ Rnotebook:frame $nn 9 ]
      set frm $frmm(Camera9)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side top -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -side bottom -fill x -pady 2

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame10 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame10 -side top -fill both -expand 1

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame11 -side top -fill both -expand 1

      frame $frm.frame16 -borderwidth 0 -relief raised
      pack $frm.frame16 -in $frm.frame11 -side top -fill both -expand 1

      #--- Definition du host pour une connexion Ethernet
      label $frm.lab1 -text "$caption(confcam,host_ethernaude)"
	pack $frm.lab1 -in $frm.frame6 -anchor center -side left -padx 10 -pady 5

      entry $frm.host -width 18 -textvariable confCam(conf_ethernaude,host)
	pack $frm.host -in $frm.frame6 -anchor center -side left -padx 10 -pady 5

      #--- Bouton de test de la connexion
      button $frm.ping -text "$caption(confcam,test_ethernaude)" -relief raised -state normal \
         -command { ::confCam::testping $confCam(conf_ethernaude,host) }
	pack $frm.ping -in $frm.frame7 -anchor center -side top -padx 70 -pady 7 -ipadx 10 -ipady 5 -expand true

      #--- Envoi ou non de l'adresse IP a l'EthernAude
      checkbutton $frm.ipsetting -text "$caption(confcam,envoyer_adresse_eth)" -highlightthickness 0 \
         -variable confCam(conf_ethernaude,ipsetting)
	pack $frm.ipsetting -in $frm.frame8 -anchor center -side left -padx 10 -pady 2

      #--- Definition de la vitesse de lecture d'un pixel
      label $frm.lab2 -text "$caption(confcam,lecture_pixel)"
	pack $frm.lab2 -in $frm.frame9 -anchor center -side left -padx 10 -pady 2

      entry $frm.lecture_pixel -textvariable confCam(conf_ethernaude,canspeed) -width 3 -justify center
	pack $frm.lecture_pixel -in $frm.frame9 -anchor center -side left -pady 2

      label $frm.lab3 -text "$caption(confcam,micro_sec_bornes)"
	pack $frm.lab3 -in $frm.frame9 -anchor center -side left -padx 2 -pady 2

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_ethernaude,mirx)
      pack $frm.mirx -in $frm.frame13 -anchor center -side left -padx 10 -pady 2

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_ethernaude,miry)
	pack $frm.miry -in $frm.frame14 -anchor center -side left -padx 10 -pady 2

      #--- Definition du type de l'obturateur
      label $frm.lab4 -text "$caption(confcam,type_obtu)"
	pack $frm.lab4 -in $frm.frame15 -anchor center -side left -padx 10 -pady 2

      set list_combobox [ list $caption(confcam,obtu_audine) $caption(confcam,obtu_audine-) ]
      ComboBox $frm.typeobtu \
         -width 9          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_ethernaude,typeobtu) \
         -values $list_combobox
	pack $frm.typeobtu -in $frm.frame15 -anchor center -side right -padx 10 -pady 2

      #--- Definition du fonctionnement de l'obturateur
      label $frm.lab5 -text "$caption(confcam,fonc_obtu)"
	pack $frm.lab5 -in $frm.frame16 -anchor center -side left -padx 10 -pady 2

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 9          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_ethernaude,foncobtu) \
         -values $list_combobox
	pack $frm.foncobtu -in $frm.frame16 -anchor center -side right -padx 10 -pady 2

      #--- Alimentation AlAudine NT avec port I2C
      button $frm.alaudine_nt -text "$caption(confcam,alaudine_nt)" -relief raised -state normal \
         -command { ::AlAudine_NT::run "$audace(base).alimAlAudineNT" }
	pack $frm.alaudine_nt -in $frm.frame12 -anchor center -side left -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

      #--- Lancement de la presentation et du tutorial
      button $frm.tutorial -text "$caption(confcam,tutorial_ethernaude)" -relief raised -state normal \
         -command { catch { source [ file join $audace(rep_plugin) camera ethernaude tutorial tuto.tcl ] } }
	pack $frm.tutorial -in $frm.frame4 -anchor center -side top -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

      #--- Gestion des boutons actifs/inactifs
      ::confCam::ConfEthernAude

      #--- Site web officiel de l'EthernAude
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_ethernaude)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame5 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_ethernaude)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera9)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera9)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 9 ] <Button-1> { global confCam ; set confCam(cam) "ethernaude" }
   }

   #
   # Fenetre de configuration de la TH7852A d'Yves LATIL
   #
   proc fillPage10 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(th7852a,coef) ] } { set conf(th7852a,coef) "1.0" }
      if { ! [ info exists conf(th7852a,mirx) ] } { set conf(th7852a,mirx) "0" }
      if { ! [ info exists conf(th7852a,miry) ] } { set conf(th7852a,miry) "0" }
      if { ! [ info exists conf(th7852a,port) ] } { set conf(th7852a,port) "lpt1" }

      #--- confToWidget
      set confCam(conf_th7852a,coef) $conf(th7852a,coef)
      set confCam(conf_th7852a,mirx) $conf(th7852a,mirx)
      set confCam(conf_th7852a,miry) $conf(th7852a,miry)
      set confCam(conf_th7852a,port) $conf(th7852a,port)

      #--- Initialisation
      set frmm(Camera10) [ Rnotebook:frame $nn 10 ]
      set frm $frmm(Camera10)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1 -padx 80

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame3 -anchor n -side bottom -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame3 -anchor n -side left -fill x

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame3 -anchor n -side left -fill x

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame6 -anchor n -side left -padx 10 -pady 14

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_th7852a,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame6 -anchor n -side left -padx 10 -pady 14

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_th7852a,mirx)
	pack $frm.mirx -in $frm.frame7 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_th7852a,miry)
	pack $frm.miry -in $frm.frame7 -anchor w -side top -padx 10 -pady 10

      #--- Definition du coefficient
      label $frm.lab2 -text "$caption(confcam,coef_th7852a)"
	pack $frm.lab2 -in $frm.frame5 -anchor n -side left -padx 10 -pady 12

      entry $frm.coef -textvariable confCam(conf_th7852a,coef) -width 5 -justify center
	pack $frm.coef -in $frm.frame5 -anchor n -side left -padx 10 -pady 12

      #--- Site web officiel de la TH7852A d'Yves LATIL
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_th7852a)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
     # bind $frm.labURL <ButtonPress-1> {
     #    set filename "$caption(confcam,site_th7852a)"
     #    ::audace::Lance_Site_htm $filename
     # }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera10)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera10)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 10 ] <Button-1> { global confCam ; set confCam(cam) "th7852a" }
   }

   #
   # Fenetre de configuration de la SCR1300XTC
   #
   proc fillPage11 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(scr1300xtc,mirx) ] } { set conf(scr1300xtc,mirx) "0" }
      if { ! [ info exists conf(scr1300xtc,miry) ] } { set conf(scr1300xtc,miry) "0" }
      if { ! [ info exists conf(scr1300xtc,port) ] } { set conf(scr1300xtc,port) "lpt1" }

      #--- confToWidget
      set confCam(conf_scr1300xtc,mirx) $conf(scr1300xtc,mirx)
      set confCam(conf_scr1300xtc,miry) $conf(scr1300xtc,miry)
      set confCam(conf_scr1300xtc,port) $conf(scr1300xtc,port)

      #--- Initialisation
      set frmm(Camera11) [ Rnotebook:frame $nn 11 ]
      set frm $frmm(Camera11)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1 -padx 80

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame3 -anchor n -side left -fill x -pady 18

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame3 -anchor n -side left -fill x -pady 15

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
	pack $frm.lab1 -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_scr1300xtc,port) \
         -values $list_combobox
	pack $frm.port -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_scr1300xtc,mirx)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_scr1300xtc,miry)
	pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      #--- Site web officiel de la SCR1300XTC
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_scr1300xtc)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_scr1300xtc)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera11)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera11)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 11 ] <Button-1> { global confCam ; set confCam(cam) "scr1300xtc" }
   }

   #
   # Fenetre de configuration de l'APN
   #
   proc fillPage12 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(apn,baud) ] }           { set conf(apn,baud)           "115200" }
     ### if { ! [ info exists conf(apn,serial_port) ] }    { set conf(apn,serial_port)    [ lindex "$audace(list_com)" 0 ] }
      if { ! [ info exists conf(apn,type_connexion) ] } { set conf(apn,type_connexion) "1" }
      if { ! [ info exists conf(apn,video_port) ] }     { set conf(apn,video_port)     "0" }

      #--- confToWidget
      set confCam(conf_apn,baud)           $conf(apn,baud)
     ### set confCam(conf_apn,serial_port)    $conf(apn,serial_port)
      set confCam(conf_apn,type_connexion) $conf(apn,type_connexion)
      set confCam(conf_apn,video_port)     $conf(apn,video_port)

      #--- Initialisation
      set frmm(Camera12) [ Rnotebook:frame $nn 12 ]
      set frm $frmm(Camera12)

      #--- Creation des differents frames
      frame $frm.frame0 -borderwidth 0 -relief raised
      pack $frm.frame0 -side top -fill y -expand 1

      #--- Bouton radio Serie uniquement
      radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,apn_serie)" -value 2 -variable confCam(conf_apn,type_connexion) 
		pack $frm.radio1 -in $frm.frame0 -anchor center -side left -padx 10

      #--- Bouton radio Video seulement
      radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,apn_video)" -value 1 -variable confCam(conf_apn,type_connexion)
		pack $frm.radio2 -in $frm.frame0 -anchor center -side left -padx 10

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      #--- Creation des frames des ports de communication
      frame $frm.com -borderwidth 0 -relief raised
      pack $frm.com -in $frm.frame1 -anchor nw -side left -fill y -expand 1
      
      frame $frm.com.serie -borderwidth 0 -relief raised
      pack $frm.com.serie -in $frm.com -anchor ne -side top -fill x
      
      frame $frm.com.baud -borderwidth 0 -relief raised
      pack $frm.com.baud -in $frm.com -anchor ne -side top -fill x
 		
      #--- Creation du frame contenant les réglages video
      frame $frm.video -borderwidth 0 -relief raised
      pack $frm.video -in $frm.frame1 -anchor ne -side right -fill y -expand 1
      
      frame $frm.video.usb -borderwidth 0 -relief raised
      pack $frm.video.usb -in $frm.video -anchor nw -side top -fill x

      #--- Frame contenant les références du site, etc
      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

     # #--- Definition du port serie
     # label $frm.com.serie.lab1 -text $caption(confcam,port_apn_cmd)
     # pack $frm.com.serie.lab1 -in $frm.com.serie -anchor e -side left -padx 10 -pady 10

     # ComboBox $frm.com.serie.s_port \
     #    -width 14         \
     #    -height [ llength $audace(list_com) ]  \
     #    -relief sunken    \
     #    -borderwidth 1    \
     #    -textvariable confCam(conf_apn,serial_port) \
     #    -editable 0       \
     #    -values $audace(list_com)
     # pack $frm.com.serie.s_port -in $frm.com.serie -anchor e -side left -padx 5 -pady 10

      #--- Definition de la vitesse du port série
      label $frm.com.baud.label -text $caption(confcam,apn_baud)
      pack $frm.com.baud.label -in $frm.com.baud -anchor e -side left -padx 10 -pady 10

      set list_combobox [ list 115200 57600 38400 19200 9600 ]
      ComboBox $frm.com.baud.liste \
         -width 14         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_apn,baud) \
         -editable 0       \
         -values $list_combobox
      pack $frm.com.baud.liste -in $frm.com.baud -anchor e -side right -padx 5 -pady 10

      #--- Definition du canal USB pour la video
      set list_combobox [ list 0 1 2 3 4 5 6 7 8 9 ]
      ComboBox $frm.video.usb.liste \
         -width 7         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_apn,video_port) \
         -editable 0       \
         -values $list_combobox
      pack $frm.video.usb.liste -in $frm.video.usb -anchor e -side right -padx 10 -pady 10

      label $frm.video.usb.lab -text $caption(confcam,apn_canal_usb)
      pack $frm.video.usb.lab -in $frm.video.usb -anchor e -side right -padx 10 -pady 10

      #--- Boutons de configuration de la source et du format video
      button $frm.video.source -text $caption(confcam,apn_video_source) -width 30 \
         -command { cam$audace(camNo) videosource }
      pack $frm.video.source -in $frm.video -anchor w -padx 10 -ipadx 10 -ipady 5 -expand true
      button $frm.video.format -text $caption(confcam,apn_video_format) -width 30 \
         -command { cam$audace(camNo) videoformat }
      pack $frm.video.format -in $frm.video -anchor w -padx 10 -ipadx 10 -ipady 5 -expand true

      #--- Gestion des boutons actifs/inactifs
      ::confCam::ConfAPN

      #--- Site web officiel de la commande d'APN
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_apn)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2
      
      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_apn)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera12)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera12)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 12 ] <Button-1> { global confCam ; set confCam(cam) "apn" }
   }

   #
   # Fenetre de configuration de la Andor
   #
   proc fillPage13 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(andor,cool) ] }        { set conf(andor,cool)        "0" }
      if { ! [ info exists conf(andor,foncobtu) ] }    { set conf(andor,foncobtu)    "2" }
      if { ! [ info exists conf(andor,config) ] }      { set conf(andor,config)      [ file join $audace(rep_install) bin ] }
      if { ! [ info exists conf(andor,mirx) ] }        { set conf(andor,mirx)        "0" }
      if { ! [ info exists conf(andor,miry) ] }        { set conf(andor,miry)        "0" }
      if { ! [ info exists conf(andor,temp) ] }        { set conf(andor,temp)        "-50" }
      if { ! [ info exists conf(andor,ouvert_obtu) ] } { set conf(andor,ouvert_obtu) "0" }
      if { ! [ info exists conf(andor,ferm_obtu) ] }   { set conf(andor,ferm_obtu)   "30" }

      #--- confToWidget
      set confCam(conf_andor,cool)        $conf(andor,cool)
      set confCam(conf_andor,foncobtu)    [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(andor,foncobtu) ]
      set confCam(conf_andor,config)      $conf(andor,config)
      set confCam(conf_andor,mirx)        $conf(andor,mirx)
      set confCam(conf_andor,miry)        $conf(andor,miry)
      set confCam(conf_andor,temp)        $conf(andor,temp)
      set confCam(conf_andor,ouvert_obtu) $conf(andor,ouvert_obtu)
      set confCam(conf_andor,ferm_obtu)   $conf(andor,ferm_obtu)

      #--- Initialisation
      set frmm(Camera13) [ Rnotebook:frame $nn 13 ]
      set frm $frmm(Camera13)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side bottom -fill x -pady 2

      frame $frm.frame4 -borderwidth 0 -relief raised
	pack $frm.frame4 -in $frm.frame2 -side bottom -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill x -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame2 -side left -fill x -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
	pack $frm.frame7 -in $frm.frame5 -side top -fill x -padx 30

      frame $frm.frame8 -borderwidth 0 -relief raised
	pack $frm.frame8 -in $frm.frame5 -side top -fill x -padx 30

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame4 -side top -fill x -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame4 -side top -fill x -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame4 -side top -fill x -expand 1

      #--- Definition du host pour une connexion Ethernet
      label $frm.lab2 -text "$caption(confcam,andor_config)"
	pack $frm.lab2 -in $frm.frame1 -anchor center -side left -padx 10

      button $frm.explore -text "$caption(confcam,andor_parcourir)" -width 1 \
         -command {
            set confCam(conf_andor,config) [ tk_chooseDirectory -title "$caption(confcam,andor_dossier)" \
            -initialdir [ file join $audace(rep_install) bin ] -parent $audace(base).confCam ]
         }
      pack $frm.explore -in $frm.frame1 -side left -padx 10 -pady 5 -ipady 5

      entry $frm.host -width 40 -textvariable confCam(conf_andor,config)
      pack $frm.host -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du refroidissement
      checkbutton $frm.cool -text "$caption(confcam,refroidissement)" -highlightthickness 0 \
         -variable confCam(conf_andor,cool)
      pack $frm.cool -in $frm.frame7 -anchor center -side left -padx 0 -pady 5

      entry $frm.temp -textvariable confCam(conf_andor,temp) -width 4 -justify center
	pack $frm.temp -in $frm.frame7 -anchor center -side left -padx 5 -pady 5

      label $frm.tempdeg -text "$caption(confcam,deg_c) $caption(confcam,refroidissement_1)"
	pack $frm.tempdeg -in $frm.frame7 -side left -fill x -padx 0 -pady 5

      #--- Definition de la temperature du capteur CCD
      label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
	pack $frm.temp_ccd -in $frm.frame8 -side left -fill x -padx 20 -pady 5

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_andor,mirx)
	pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_andor,miry)
	pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab3 -text "$caption(confcam,fonc_obtu)"
	pack $frm.lab3 -in $frm.frame9 -anchor center -side left -padx 10 -pady 5

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_andor,foncobtu) \
         -values $list_combobox
      pack $frm.foncobtu -in $frm.frame9 -anchor center -side left -padx 10 -pady 5

      #--- Delai d'ouverture de l'obturateur
      label $frm.lab4 -text "$caption(confcam,andor_ouvert_obtu)"
	pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10 -pady 5

      entry $frm.ouvert_obtu -textvariable confCam(conf_andor,ouvert_obtu) -width 4 -justify center
	pack $frm.ouvert_obtu -in $frm.frame10 -anchor center -side left -padx 5 -pady 5

      label $frm.lab5 -text "$caption(confcam,andor_ms)"
	pack $frm.lab5 -in $frm.frame10 -side left -fill x -padx 0 -pady 5

      #--- Delai de fermeture de l'obturateur
      label $frm.lab6 -text "$caption(confcam,andor_ferm_obtu)"
	pack $frm.lab6 -in $frm.frame11 -anchor center -side left -padx 10 -pady 5

      entry $frm.ferm_obtu -textvariable confCam(conf_andor,ferm_obtu) -width 4 -justify center
	pack $frm.ferm_obtu -in $frm.frame11 -anchor center -side left -padx 5 -pady 5

      label $frm.lab7 -text "$caption(confcam,andor_ms)"
	pack $frm.lab7 -in $frm.frame11 -side left -fill x -padx 0 -pady 5

      #--- Site web officiel de la Andor
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_andor)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame3 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_andor)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera3)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera3)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 13 ] <Button-1> { global confCam ; set confCam(cam) "andor" }
   }

   #
   # Fenetre de configuration des APN DigiCam
   #
   proc fillPage14 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- initConf
      if { ! [ info exists conf(digicam,mirx) ] }        { set conf(digicam,mirx) "0" }
      if { ! [ info exists conf(digicam,miry) ] }        { set conf(digicam,miry) "0" }
      if { ! [ info exists conf(digicam,quickremote) ] } { set conf(digicam,quickremote) "0" }

      #--- confToWidget
      set confCam(conf_digicam,mirx)        $conf(digicam,mirx)
      set confCam(conf_digicam,miry)        $conf(digicam,miry)
      set confCam(conf_digicam,quickremote) $conf(digicam,quickremote)

      #--- Initialisation
      set frmm(Camera14) [ Rnotebook:frame $nn 14 ]
      set frm $frmm(Camera14)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1 -padx 80

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame3 -anchor n -side left -fill x -pady 18

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame3 -anchor n -side left -fill x -pady 15

      #--- Utilisation du QuickRemote
      checkbutton $frm.quickremote -text "$caption(confcam,digicam_quickremote)" -highlightthickness 0 \
         -variable confCam(conf_digicam,quickremote)
      pack $frm.quickremote -in $frm.frame5 -anchor w -side top -padx 20 -pady 10

      #--- Gestion du Service Windows de detection automatique des APN
      if { $::tcl_platform(platform) == "windows" } {
         checkbutton $frm.detect_service -text "$caption(confcam,digicam_detect_service)" -highlightthickness 0 \
            -variable confCam(conf_digicam,detect_service)
         pack $frm.detect_service -in $frm.frame5 -anchor w -side top -padx 20 -pady 10
      }

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_digicam,mirx)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_digicam,miry)
	pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      #--- Site web officiel des APN DigiCam
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_digicam)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_digicam)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Camera14)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Camera14)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 14 ] <Button-1> { global confCam ; set confCam(cam) "digicam" }
   }

   #
   # confCam::Connect_Camera
   # Affichage d'un message d'alerte pendant la connexion de la camera au demarrage
   #
   proc Connect_Camera { } {
      variable This
      global audace
      global caption
      global color

      if [ winfo exists $audace(base).connectCamera ] {
         destroy $audace(base).connectCamera
      }

      toplevel $audace(base).connectCamera
      wm resizable $audace(base).connectCamera 0 0
      wm title $audace(base).connectCamera "$caption(confcam,attention)"
      if { [ info exists This ] } {
         set posx_connectCamera [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
         set posy_connectCamera [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
         wm geometry $audace(base).connectCamera +[ expr $posx_connectCamera + 50 ]+[ expr $posy_connectCamera + 100 ]
         wm transient $audace(base).connectCamera $This
      } else {
         wm geometry $audace(base).connectCamera +200+100
         wm transient $audace(base).connectCamera $audace(base)
      }
      #--- Cree l'affichage du message
      label $audace(base).connectCamera.labURL_1 -text "$caption(confcam,connexion_texte1)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      uplevel #0 { pack $audace(base).connectCamera.labURL_1 -padx 10 -pady 2 }
      label $audace(base).connectCamera.labURL_2 -text "$caption(confcam,connexion_texte2)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      uplevel #0 { pack $audace(base).connectCamera.labURL_2 -padx 10 -pady 2 }

      #--- La nouvelle fenetre est active
      focus $audace(base).connectCamera

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).connectCamera
   }

   #
   # confCam::select [ cam ]
   # Selectionne un onglet en passant le nom (eventuellement) de
   # la camera decrite dans l'onglet
   #
   proc select { { cam default } } {
      variable This
      global confCam

      set nn $This.usr.book
      set confCam(cam) $cam
      switch -exact -- $cam {
         hisis      { Rnotebook:raise $nn 2 }
         sbig       { Rnotebook:raise $nn 3 }
         cb245      { Rnotebook:raise $nn 4 }
         starlight  { Rnotebook:raise $nn 5 }
         kitty      { Rnotebook:raise $nn 6 }
         webcam     { Rnotebook:raise $nn 7 }
         audinet    { Rnotebook:raise $nn 8 }
         ethernaude { Rnotebook:raise $nn 9 }
         th7852a    { Rnotebook:raise $nn 10 }
         scr1300xtc { Rnotebook:raise $nn 11 }
         apn        { Rnotebook:raise $nn 12 }
         andor      { Rnotebook:raise $nn 13 }
         digicam    { Rnotebook:raise $nn 14 }
         default    { Rnotebook:raise $nn 1 }
      }
   }

   #
   # confCam::stopDriver
   # Arrete le plugin camera
   #
   proc stopDriver { } {
      global audace
      global conf
      global confCam

      #--- Restitue si necessaire l'etat du service sous Windows
      if { ( $::tcl_platform(platform) == "windows" ) && ( $conf(camera) == "digicam" ) } {
         if { [ cam$audace(camNo) systemservice ] != "$confCam(conf_digicam,statut_service)" } {
            cam$audace(camNo) systemservice $confCam(conf_digicam,statut_service)
         }
      }
      #--- Supprime la camera
      cam::delete [ cam::list ]
   }

   #
   # confCam::configureCamera
   # Configure la camera en fonction des donnees contenues dans le tableau conf :
   # conf(camera) -> type de camera employe
   # conf(cam,...) -> proprietes de ce type de camera.
   #
   proc configureCamera { } {
      global audace
      global caption
      global conf
      global confcolor
      global confCam
      global panneau

      #--- Affichage d'un message d'alerte si necessaire
      ::confCam::Connect_Camera

      #--- Inhibe les menus
      ::audace::menustate disabled

      switch -exact -- $conf(camera) {
         hisis {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               if { $conf(hisis,modele) == "11" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis11 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 4096 0
                  }
               } elseif { $conf(hisis,modele) == "22" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis22-[ lindex $conf(hisis,res) 0 ] } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele) ($conf(hisis,res))\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     cam$audace(camNo) delayloops $conf(hisis,delai_a) $conf(hisis,delai_b) $conf(hisis,delai_c)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "23" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis23 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "24" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis24 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "33" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis33 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "36" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis36 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "39" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis39 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "43" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis43 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "44" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis44 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "48" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name hisis48 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$audace(camNo) shutter "opened"
                        }
                        1 {
                           cam$audace(camNo) shutter "closed"
                        }
                        2 {
                           cam$audace(camNo) shutter "synchro"
                        }
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               }
            }
         sbig {
              ### set conf(sbig,host) [ ::audace::verifip $conf(sbig,host) ]
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create sbig $conf(sbig,port) -ip $conf(sbig,host) } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_sbig) ([ cam$audace(camNo) name ]) \
                     $caption(confcam,2points) $conf(sbig,port)\n"
                  set foncobtu $conf(sbig,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$audace(camNo) shutter "opened"
                     }
                     1 {
                        cam$audace(camNo) shutter "closed"
                     }
                     2 {
                        cam$audace(camNo) shutter "synchro"
                     }
                  }
                  if { $conf(sbig,cool) == "1" } {
                     cam$audace(camNo) cooler check $conf(sbig,temp)
                  } else {
                     cam$audace(camNo) cooler off
                  }
                  cam$audace(camNo) buf $audace(bufNo)
                  ::audace::visuDynamix 65535 0
                  #---
                  if { [ info exists confCam(conf_sbig,aftertemp) ] == "0" } {
                     ::confCam::SbigDispTemp
                  }
               }
            }
         cb245 {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create cookbook $conf(cb245,port) -name CB245 } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_cb245) $caption(confcam,2points)\
                     $conf(cb245,port)\n"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  cam$audace(camNo) buf $audace(bufNo)
                  ::audace::visuDynamix 4096 -4096
               }
            }
         starlight {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set starlight_accelerator $conf(starlight,acc)
               if { $conf(starlight,modele) == "MX516" } {
                  set erreur [ catch { cam::create starlight $conf(starlight,port) -name MX5 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                        $caption(confcam,2points) $conf(starlight,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) accelerator $starlight_accelerator
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(starlight,modele) == "MX916" } {
                  set erreur [ catch { cam::create starlight $conf(starlight,port) -name MX9 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                        $caption(confcam,2points) $conf(starlight,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) accelerator $starlight_accelerator
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               } elseif { $conf(starlight,modele) == "HX516" } {
                  set erreur [ catch { cam::create starlight $conf(starlight,port) -name HX5 } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "0"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                        $caption(confcam,2points) $conf(starlight,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) accelerator $starlight_accelerator
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 32767 -32768
                  }
               }
            }
         kitty {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               if { $conf(kitty,modele) == "237" } {
                  set erreur [ catch { cam::create kitty $conf(kitty,port) -name Kitty237 \
                     -canbits [ lindex $conf(kitty,res) 0 ] } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "1"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele) ($conf(kitty,res))\
                        $caption(confcam,2points) $conf(kitty,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) canbits [ lindex $conf(kitty,res) 0 ]
                     if { $conf(kitty,captemp) == "0" } {
                        cam$audace(camNo) AD7893 AN2
                     } else {
                        cam$audace(camNo) AD7893 AN5
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 4096 -4096
                  }
               } elseif { $conf(kitty,modele) == "255" } {
                  set erreur [ catch { cam::create kitty $conf(kitty,port) -name Kitty255 \
                     -canbits [ lindex $conf(kitty,res) 0 ] } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "1"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele) ($conf(kitty,res))\
                        $caption(confcam,2points) $conf(kitty,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) canbits [ lindex $conf(kitty,res) 0 ]
                     if { $conf(kitty,captemp) == "0" } {
                        cam$audace(camNo) AD7893 AN2
                     } else {
                        cam$audace(camNo) AD7893 AN5
                     }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 4096 -4096
                  }
               } elseif { $conf(kitty,modele) == "K2" } {
                  set erreur [ catch { cam::create k2 $conf(kitty,port) } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     set confCam(audine,connect)     "0"
                     set confCam(kitty,connect)      "1"
                     set confCam(webcam,connect)     "0"
                     set confCam(ethernaude,connect) "0"
                     set confCam(apn,connect)        "0"
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele)\
                        $caption(confcam,2points) $conf(kitty,port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                     cam$audace(camNo) buf $audace(bufNo)
                     #---
                     if { $conf(kitty,on_off) == "1" } {
                        cam$audace(camNo) cooler on
                     } else {
                        cam$audace(camNo) cooler off
                     }
                     #---
                     ::audace::visuDynamix 4096 -4096
                     #---
                     if { [ info exists confCam(conf_kitty,aftertemp) ] == "0" } {
                        ::confCam::KittyDispTemp
                     }
                  }
               }
            }
         webcam {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create webcam usb -channel $conf(webcam,port) \
                  -lpport $conf(webcam,longueposeport) } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "1"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,webcam_canal_usb) ($caption(confcam,webcam))\
                     $caption(confcam,2points) $conf(webcam,port)\n"
                  console::affiche_erreur "$caption(confcam,webcam_longuepose) $caption(confcam,2points)\
                     $conf(webcam,longuepose)\n"
                  set audace(camNo) $msg
                  cam$audace(camNo) buf $audace(bufNo)
                  cam$audace(camNo) longuepose $conf(webcam,longuepose)
                  cam$audace(camNo) longueposestartvalue $conf(webcam,longueposestartvalue)
                  cam$audace(camNo) longueposestopvalue $conf(webcam,longueposestopvalue)
                  ::audace::visuDynamix 512 -255
               }
            }
         audinet {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               if { [ string range $conf(audinet,ccd) 0 4 ] == "kaf16" } {
                  set ccd "kaf1602"
               } elseif { [ string range $conf(audinet,ccd) 0 4 ] == "kaf32" } {
                  set ccd "kaf3200"
               } else {
                  set ccd "kaf401"
               }
               set erreur [ catch { cam::create audinet "" -ccd $ccd -name audinet \
                  -host $conf(audinet,host) -protocole $conf(audinet,protocole) -udptempo $conf(audinet,udptempo) \
                  -ipsetting $conf(audinet,ipsetting) -macaddress $conf(audinet,mac_address) } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,audinet) ($conf(audinet,protocole)) $caption(confcam,audine)\
                     ($conf(audinet,ccd))\n"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  cam$audace(camNo) buf $audace(bufNo)
                  set foncobtu $conf(audinet,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$audace(camNo) shutter "opened"
                     }
                     1 {
                        cam$audace(camNo) shutter "closed"
                     }
                     2 {
                        cam$audace(camNo) shutter "synchro"
                     }
                  }
                  if { [ string range $conf(audinet,typeobtu) 0 5 ] == $caption(confcam,obtu_audine) } {
                     if { [ string index $conf(audinet,typeobtu) 7 ] == "-" } {
                        catch { cam$audace(camNo) shuttertype audine reverse }
                     } else {
                        catch { cam$audace(camNo) shuttertype audine }
                     }
                  } elseif { $conf(audinet,typeobtu) == $caption(confcam,obtu_thierry) } {
                     catch { cam$audace(camNo) shuttertype thierry }
                     set confcolor(obtu_pierre) "1"
                     ::Obtu_Pierre::run
                  } elseif { $conf(audinet,typeobtu) == $caption(confcam,obtu_i2c) } {
                     cam$audace(camNo) shuttertype $conf(audinet,typeobtu)
                  }
                  ::audace::visuDynamix 32767 -32768
               }
            }
         ethernaude {
###
### Attention : Ajout de 2 fois -debug dans le cam::create
###
              ### set conf(ethernaude,host) [ ::audace::verifip $conf(ethernaude,host) ]
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set eth_shutterinvert "0"
               if { [ string range $conf(ethernaude,typeobtu) 0 5 ] == "audine" } {
                  if { [ string index $conf(ethernaude,typeobtu) 7 ] == "-" } {
                     set eth_shutterinvert "1"
                  }
               }
               set eth_canspeed "0"
               set eth_canspeed [ expr round(($conf(ethernaude,canspeed)-7.11)/(39.51-7.11)*30.) ]
               if { $eth_canspeed < "0" } { set eth_canspeed "0" }
               if { $eth_canspeed > "100" } { set eth_canspeed "100" }
               if { $conf(ethernaude,ipsetting) == "1" } {
                  set erreur [ catch { cam::create ethernaude udp -ip $conf(ethernaude,host) \
                     -shutterinvert $eth_shutterinvert -canspeed $eth_canspeed \
                     -ipsetting [ file join $audace(rep_install) bin IPSetting.exe ] -debug } msg ]
               } else {
                  set erreur [ catch { cam::create ethernaude udp -ip $conf(ethernaude,host) \
                     -shutterinvert $eth_shutterinvert -canspeed $eth_canspeed -debug } msg ]
               }
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "1"
                  set confCam(apn,connect)        "0"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,ethernaude) $caption(confcam,plus)\
                     [ string range [ cam$audace(camNo) name ] 0 5 ] ([ cam$audace(camNo) ccd])\n"
                  cam$audace(camNo) buf $audace(bufNo)
                  set foncobtu $conf(ethernaude,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$audace(camNo) shutter "opened"
                     }
                     1 {
                        cam$audace(camNo) shutter "closed"
                     }
                     2 {
                        cam$audace(camNo) shutter "synchro"
                     }
                  }
                  ::audace::visuDynamix 32767 -32768
               }
            }
         th7852a {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create camth $conf(th7852a,port) } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_th7852a) $caption(confcam,2points)\
                     $conf(th7852a,port)\n"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  cam$audace(camNo) buf $audace(bufNo)
                  cam$audace(camNo) timescale $conf(th7852a,coef)
                  ::audace::visuDynamix 32767 -32768
               }
            }
         scr1300xtc {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create synonyme $conf(scr1300xtc,port) -name SCR1300XTC } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_scr1300xtc) $caption(confcam,2points)\
                     $conf(scr1300xtc,port)\n"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  cam$audace(camNo) buf $audace(bufNo)
                  ::audace::visuDynamix 4096 -4096
               }
            }
         apn {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               if { $conf(apn,type_connexion) == "1" } {
                  set erreur [ catch { cam::create webcam usb -channel $conf(apn,video_port) } msg ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$msg" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,apn_canal_usb) ($caption(confcam,apn)) \
                        $caption(confcam,2points) $conf(apn,video_port)\n"
                     set audace(camNo) $msg
                     set audace(list_binning) { 1x1 }
                     cam$audace(camNo) buf $audace(bufNo)
                     ::audace::visuDynamix 512 -255
                  }
               } elseif { $conf(apn,type_connexion) == "2" } {
                  set msg ""
                  set erreur [ catch { ::AcqAPN::Off ; ::AcqAPN::Query } msg ]
                  if { $msg=="" } {
                     set msg "1" 
                     if { ! [ info exists audace(camNo) ] } { set audace(camNo) "1" } else { incr audace(camNo) "1" }
                  } else {
                     set erreur "1"
                  }
               }           
               if { $erreur == "0" } {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "1"
               }
            }
         andor {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create andor "$conf(andor,config)" } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_andor) ([ cam$audace(camNo) name ]) \
                     $caption(confcam,2points) $conf(andor,config)\n"
                  set foncobtu $conf(andor,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$audace(camNo) shutter "opened"
                     }
                     1 {
                        cam$audace(camNo) shutter "closed"
                     }
                     2 {
                        cam$audace(camNo) shutter "synchro"
                     }
                  }
                  if { $conf(andor,cool) == "1" } {
                     cam$audace(camNo) cooler on
                     cam$audace(camNo) cooler check $conf(andor,temp)
                  } else {
                     cam$audace(camNo) cooler off
                  }
                  cam$audace(camNo) buf $audace(bufNo)
                  ::audace::visuDynamix 65535 0
                  #--- Delais d'ouverture et de fermeture de l'obturateur
                  cam$audace(camNo) openingtime $conf(andor,ouvert_obtu)
                  cam$audace(camNo) closingtime $conf(andor,ferm_obtu)
                  #---
                  if { [ info exists confCam(conf_andor,aftertemp) ] == "0" } {
                     ::confCam::AndorDispTemp
                  }
               }
            }
         digicam {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               set erreur [ catch { cam::create digicam -capture_command $conf(digicam,quickremote) } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "0"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "DigiCam\n"
                  set audace(camNo) $msg
                  set confCam(conf_digicam,statut_service) [ cam$audace(camNo) systemservice ]
                  if { $confCam(conf_digicam,detect_service) == "1" } {
                     cam$audace(camNo) systemservice 0
                  } else {
                     cam$audace(camNo) systemservice 1
                  }
                  set audace(list_binning) { 1x1 }
                  cam$audace(camNo) buf $audace(bufNo)
                  ::audace::visuDynamix 512 -255
               }
            }
         default {
               if { [ llength [ cam::list ] ] == "1" } { ::confCam::stopDriver }
               if { [ string range $conf(audine,ccd) 0 4 ] == "kaf16" } {
                  set ccd "kaf1602"
               } elseif { [ string range $conf(audine,ccd) 0 4 ] == "kaf32" } {
                  set ccd "kaf3200"
               } else {
                  set ccd "kaf401"
               }
               if { $conf(audine,port) == "$caption(confcam,quicka)" } {
                  set erreur [ catch { cam::create quicka $conf(audine,port) -ccd $ccd } msg ]
               } else {
                  set erreur [ catch { cam::create audine $conf(audine,port) -ccd $ccd } msg ]
               }
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error
               } else {
                  set confCam(audine,connect)     "1"
                  set confCam(kitty,connect)      "0"
                  set confCam(webcam,connect)     "0"
                  set confCam(ethernaude,connect) "0"
                  set confCam(apn,connect)        "0"
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_audine) ($conf(audine,ccd))\
                     $caption(confcam,2points) $conf(audine,port)\n"
                  set audace(camNo) $msg
                  set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }
                  catch { cam$audace(camNo) cantype $conf(audine,can) }
                  set ampli_ccd $conf(audine,ampli_ccd)
                  switch -exact -- $ampli_ccd {
                     0 {
                        cam$audace(camNo) ampli "synchro"
                     }
                     1 {
                        cam$audace(camNo) ampli "on"
                     }
                     2 {
                        cam$audace(camNo) ampli "off"
                     }
                  }
                  set foncobtu $conf(audine,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$audace(camNo) shutter "opened"
                     }
                     1 {
                        cam$audace(camNo) shutter "closed"
                     }
                     2 {
                        cam$audace(camNo) shutter "synchro"
                     }
                  }
                  if { [ string range $conf(audine,typeobtu) 0 5 ] == "audine" } {
                     if { [ string index $conf(audine,typeobtu) 7 ] == "-" } {
                        catch { cam$audace(camNo) shuttertype audine reverse }
                     } else {
                        catch { cam$audace(camNo) shuttertype audine }
                     }
                  } else {
                     catch { cam$audace(camNo) shuttertype thierry }
                     set confcolor(obtu_pierre) "1"
                     ::Obtu_Pierre::run
                  }
                  cam$audace(camNo) buf $audace(bufNo)
                  ::audace::visuDynamix 32767 -32768
               }
            }
      }

      #--- Gestion du modele de camera connecte
      if { $erreur == "1" } {
         #--- En cas de probleme, je desactive le demarrage automatique
         set conf(camera,start)  "0"
         #--- En cas de probleme, camera par defaut
         set conf(camera)        "audine"
         set conf(audine,port)   "lpt1"
         set confCam(audine,connect)     "0"
         set confCam(kitty,connect)      "0"
         set confCam(webcam,connect)     "0"
         set confCal(ethernaude,connect) "0"
         set confCam(apn,connect)        "0"
         $audace(base).fra1.labCam_name configure -text "$caption(confcam,tiret)"
      } else {
         if { $conf(camera) == "hisis" } {
            $audace(base).fra1.labCam_name configure -text "$conf(camera)$conf(hisis,modele)"
         } elseif { $conf(camera) == "kitty" } {
            $audace(base).fra1.labCam_name configure -text "$conf(camera)$conf(kitty,modele)"
         } elseif { $conf(camera) == "starlight" } {
            $audace(base).fra1.labCam_name configure -text "$conf(starlight,modele)"
         } elseif { $conf(camera) == "apn" } {
            if { [ info exists conf(apn,model) ] } {
               $audace(base).fra1.labCam_name configure -text "$conf(apn,model)"
            } else {
               $audace(base).fra1.labCam_name configure -text "$conf(camera)"
            }
         } else {
            $audace(base).fra1.labCam_name configure -text "$conf(camera)"
         }
      }

      #--- Gestion des boutons actifs/inactifs
      ::confCam::ConfAudine
      ::confCam::ConfKitty
      ::confCam::ConfWebCam
      ::confCam::ConfEthernAude
      ::confCam::ConfAPN

      #--- Cas ou la video est visible dans le canvas
      set panneau(AcqFC,showvideo) "0"

      #--- Une camera est connectee
      set confCam(camera,connect) "1"

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectCamera ] {
         destroy $audace(base).connectCamera
      }

      #--- Restaure les menus
      ::audace::menustate normal

      #--- Desactive le blocage pendant l'acquisition (cli/sti)
      catch {
         cam$audace(camNo) interrupt 0
      }
   }

   #
   # confCam::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global conf
      global confCam
      global caption

      set nn $This.usr.book
      set conf(camera)                      $confCam(cam)
      #--- Memorise la configuration de Audine dans le tableau conf(audine,...)
      set frm [ Rnotebook:frame $nn 1 ]
      set conf(audine,ampli_ccd)            [ lsearch "$caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours)" "$confCam(conf_audine,ampli_ccd)" ]
      set conf(audine,can)                  $confCam(conf_audine,can)
      set conf(audine,ccd)                  $confCam(conf_audine,ccd)
      set conf(audine,foncobtu)             [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_audine,foncobtu)" ]
      set conf(audine,mirx)                 $confCam(conf_audine,mirx)
      set conf(audine,miry)                 $confCam(conf_audine,miry)
      set conf(audine,port)                 $confCam(conf_audine,port)
      set conf(audine,typeobtu)             $confCam(conf_audine,typeobtu)
      #--- Memorise la configuration des Hi-SIS dans le tableau conf(hisis,...)
      set frm [ Rnotebook:frame $nn 2 ]
      set conf(hisis,delai_a)               $confCam(conf_hisis,delai_a)
      set conf(hisis,delai_b)               $confCam(conf_hisis,delai_b)
      set conf(hisis,delai_c)               $confCam(conf_hisis,delai_c)
      set conf(hisis,foncobtu)              [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_hisis,foncobtu)" ]
      set conf(hisis,mirx)                  $confCam(conf_hisis,mirx)
      set conf(hisis,miry)                  $confCam(conf_hisis,miry)
      set conf(hisis,modele)                [ lindex "11 22 23 24 33 36 39 43 44 48" $confCam(conf_hisis,modele) ]
      set conf(hisis,port)                  $confCam(conf_hisis,port)
      set conf(hisis,res)                   $confCam(conf_hisis,res)
      #--- Memorise la configuration de la SBIG dans le tableau conf(sbig,...)
      set frm [ Rnotebook:frame $nn 3 ]
      set conf(sbig,cool)                   $confCam(conf_sbig,cool)
      set conf(sbig,foncobtu)               [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_sbig,foncobtu)" ]
      set conf(sbig,host)                   $confCam(conf_sbig,host)
      set conf(sbig,mirx)                   $confCam(conf_sbig,mirx)
      set conf(sbig,miry)                   $confCam(conf_sbig,miry)
      set conf(sbig,port)                   $confCam(conf_sbig,port)
      set conf(sbig,temp)                   $confCam(conf_sbig,temp)
      #--- Memorise la configuration de la CB245 dans le tableau conf(cb245,...)
      set frm [ Rnotebook:frame $nn 4 ]
      set conf(cb245,mirx)                  $confCam(conf_cb245,mirx)
      set conf(cb245,miry)                  $confCam(conf_cb245,miry)
      set conf(cb245,port)                  $confCam(conf_cb245,port)
      #--- Memorise la configuration des Starlight dans le tableau conf(starlight,...)
      set frm [ Rnotebook:frame $nn 5 ]
      set conf(starlight,acc)               [ lsearch "$caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur)" "$confCam(conf_starlight,acc)" ]
      set conf(starlight,mirx)              $confCam(conf_starlight,mirx)
      set conf(starlight,miry)              $confCam(conf_starlight,miry)
      set conf(starlight,modele)            [ lindex "MX516 MX916 HX516" $confCam(conf_starlight,modele) ]
      set conf(starlight,port)              $confCam(conf_starlight,port)
      #--- Memorise la configuration des Kitty dans le tableau conf(kitty,...)
      set frm [ Rnotebook:frame $nn 6 ]
      set conf(kitty,captemp)               [ lsearch "$caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5)" "$confCam(conf_kitty,captemp)" ]
      set conf(kitty,mirx)                  $confCam(conf_kitty,mirx)
      set conf(kitty,miry)                  $confCam(conf_kitty,miry)
      set conf(kitty,modele)                $confCam(conf_kitty,modele)
      set conf(kitty,port)                  $confCam(conf_kitty,port)
      set conf(kitty,res)                   $confCam(conf_kitty,res)
      set conf(kitty,on_off)                $confCam(conf_kitty,on_off)
      #--- Memorise la configuration de la WebCam dans le tableau conf(webcam,...)
      set frm [ Rnotebook:frame $nn 7 ]
      set conf(webcam,longuepose)           $confCam(conf_webcam,longuepose)
      set conf(webcam,longueposeport)       $confCam(conf_webcam,longueposeport)
      set conf(webcam,longueposestartvalue) $confCam(conf_webcam,longueposestartvalue)
      set conf(webcam,longueposestopvalue)  $confCam(conf_webcam,longueposestopvalue)
      set conf(webcam,mirx)                 $confCam(conf_webcam,mirx)
      set conf(webcam,miry)                 $confCam(conf_webcam,miry)
      set conf(webcam,port)                 $confCam(conf_webcam,port)
      #--- Memorise la configuration de AudiNet dans le tableau conf(audinet,...)
      set frm [ Rnotebook:frame $nn 8 ]
      set conf(audinet,ccd)                 $confCam(conf_audinet,ccd)
      set conf(audinet,foncobtu)            [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_audinet,foncobtu)" ]
      set conf(audinet,host)                $confCam(conf_audinet,host)
      set conf(audinet,ipsetting)           $confCam(conf_audinet,ipsetting)
      set conf(audinet,mac_address)         $confCam(conf_audinet,mac_address)
      set conf(audinet,mirx)                $confCam(conf_audinet,mirx)
      set conf(audinet,miry)                $confCam(conf_audinet,miry)
      set conf(audinet,protocole)           $confCam(conf_audinet,protocole)
      set conf(audinet,typeobtu)            $confCam(conf_audinet,typeobtu)
      set conf(audinet,udptempo)            $confCam(conf_audinet,udptempo)
      #--- Memorise la configuration de l'EthernAude dans le tableau conf(ethernaude,...)
      set frm [ Rnotebook:frame $nn 9 ]
      set conf(ethernaude,canspeed)         $confCam(conf_ethernaude,canspeed)
      set conf(ethernaude,foncobtu)         [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_ethernaude,foncobtu)" ]
      set conf(ethernaude,host)             $confCam(conf_ethernaude,host)
      set conf(ethernaude,ipsetting)        $confCam(conf_ethernaude,ipsetting)
      set conf(ethernaude,mirx)             $confCam(conf_ethernaude,mirx)
      set conf(ethernaude,miry)             $confCam(conf_ethernaude,miry)
      set conf(ethernaude,typeobtu)         $confCam(conf_ethernaude,typeobtu)
      #--- Memorise la configuration de la TH7852A dans le tableau conf(th7852a,...)
      set frm [ Rnotebook:frame $nn 10 ]
      set conf(th7852a,coef)                $confCam(conf_th7852a,coef)
      set conf(th7852a,mirx)                $confCam(conf_th7852a,mirx)
      set conf(th7852a,miry)                $confCam(conf_th7852a,miry)
      set conf(th7852a,port)                $confCam(conf_th7852a,port)
      #--- Memorise la configuration de la SCR1300XTC dans le tableau conf(scr1300xtc,...)
      set frm [ Rnotebook:frame $nn 11 ]
      set conf(scr1300xtc,mirx)             $confCam(conf_scr1300xtc,mirx)
      set conf(scr1300xtc,miry)             $confCam(conf_scr1300xtc,miry)
      set conf(scr1300xtc,port)             $confCam(conf_scr1300xtc,port)
      #--- Memorise la configuration de l'APN dans le tableau conf(apn,...)
      set frm [ Rnotebook:frame $nn 12 ]
      set conf(apn,baud)                    $confCam(conf_apn,baud)
     ### set conf(apn,serial_port)             $confCam(conf_apn,serial_port)
      set conf(apn,type_connexion)          $confCam(conf_apn,type_connexion)
      set conf(apn,video_port)              $confCam(conf_apn,video_port)
      if { [ info exists confCam(apn,model) ] } {
         set conf(apn,model)                $confCam(apn,model)
      } else {
         catch { unset conf(apn,model) }
      }
      #--- Memorise la configuration de la Andor dans le tableau conf(andor,...)
      set frm [ Rnotebook:frame $nn 13 ]
      set conf(andor,cool)                   $confCam(conf_andor,cool)
      set conf(andor,foncobtu)               [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_andor,foncobtu)" ]
      set conf(andor,config)                 $confCam(conf_andor,config)
      set conf(andor,mirx)                   $confCam(conf_andor,mirx)
      set conf(andor,miry)                   $confCam(conf_andor,miry)
      set conf(andor,temp)                   $confCam(conf_andor,temp)
      set conf(andor,ouvert_obtu)            $confCam(conf_andor,ouvert_obtu)
      set conf(andor,ferm_obtu)              $confCam(conf_andor,ferm_obtu)
      #--- Memorise la configuration des APN DigiCam dans le tableau conf(digicam,...)
      set conf(digicam,mirx)                 $confCam(conf_digicam,mirx)
      set conf(digicam,miry)                 $confCam(conf_digicam,miry)
      set conf(digicam,quickremote)          $confCam(conf_digicam,quickremote)
   }

   proc SbigDispTemp { } {
      variable This
      global audace
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera3)
         if { [ info exists This ] == "1" && [ catch { set tempstatus [ cam$audace(camNo) infotemp ] } ] == "0" } {
            set temp_check [ format "%+5.2f" [ lindex $tempstatus 0 ] ]
            set temp_ccd [ format "%+5.2f" [ lindex $tempstatus 1 ] ]
            set temp_ambiant [ format "%+5.2f" [ lindex $tempstatus 2 ] ]
            set regulation [ lindex $tempstatus 3 ]
            set power [ format "%3.0f" [ expr 100.*[ lindex $tempstatus 4 ]/255. ] ]
            $frm.power configure \
               -text "$caption(confcam,puissance_peltier) $power %"
            $frm.ccdtemp configure \
               -text "$caption(confcam,temp_ext) $temp_ccd $caption(confcam,deg_c) / $temp_ambiant $caption(confcam,deg_c)"
            set confCam(conf_sbig,aftertemp) [ after 5000 ::confCam::SbigDispTemp ]
         } else {
            catch { unset confCam(conf_sbig,aftertemp) }
         }
      }
   }

   proc KittyDispTemp { } {
      variable This
      global audace
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera6)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$audace(camNo) temperature ] } ] == "0" } {
            set temp_ccd [ format "%+5.2f" $temp_ccd ]
            $frm.temp_ccd configure \
               -text "$caption(confcam,temperature_CCD) $temp_ccd $caption(confcam,deg_c)"
            set confCam(conf_kitty,aftertemp) [ after 5000 ::confCam::KittyDispTemp ]
         } else {
            catch { unset confCam(conf_kitty,aftertemp) }
         }
      }
   }

   proc AndorDispTemp { } {
      variable This
      global audace
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera13)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$audace(camNo) temperature ] } ] == "0" } {
            set temp_ccd [ format "%+5.2f" $temp_ccd ]
            $frm.temp_ccd configure \
               -text "$caption(confcam,temperature_CCD) $temp_ccd $caption(confcam,deg_c)"
            set confCam(conf_andor,aftertemp) [ after 5000 ::confCam::AndorDispTemp ]
         } else {
            catch { unset confCam(conf_andor,aftertemp) }
         }
      }
   }

   proc testping { ip } {
      variable This
      global audace
      global caption
      global confCam

      set res  [ ::ping $ip ]
      set res1 [ lindex $res 0 ]
      set res2 [ lindex $res 1 ]
      if { $res1 == "1" } {
	   set tres1 "$caption(confcam,appareil_connecte) $ip"
      } else {
	   set tres1 "$caption(confcam,pas_appareil_connecte) $ip"
      }
      set tres2 "$caption(confcam,message_ping)"
      tk_messageBox -message "$tres1.\n$tres2 $res2" -icon info
   }

}

#--- Connexion au demarrage de la camera selectionnee par defaut
::confCam::init

