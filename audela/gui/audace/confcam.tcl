#
# Fichier : confcam.tcl
# Description : Gere des objets 'camera'
# Mise a jour $Id: confcam.tcl,v 1.26 2006-08-12 21:27:10 robertdelmas Exp $
#

global confCam

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
      global confCam
      global caption

      #--- Charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_caption) confcam.cap ]\""

      #--- initConf
      if { ! [ info exists conf(camera,A,camName) ] } { set conf(camera,A,camName) "" }
      if { ! [ info exists conf(camera,A,start)   ] } { set conf(camera,A,start)   "0" }
      if { ! [ info exists conf(camera,B,camName) ] } { set conf(camera,B,camName) "" }
      if { ! [ info exists conf(camera,B,start)   ] } { set conf(camera,B,start)   "0" }
      if { ! [ info exists conf(camera,C,camName) ] } { set conf(camera,C,camName) "" }
      if { ! [ info exists conf(camera,C,start)   ] } { set conf(camera,C,start)   "0" }
      if { ! [ info exists conf(camera,position)  ] } { set conf(camera,position)  "+25+45" }

      #--- Charge les fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine obtu_pierre.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine testaudine.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera dslr dslr.tcl ]\""

      #--- Intialise les variables de chaque camera

      #--- initConf 1
      if { ! [ info exists conf(audine,ampli_ccd) ] } { set conf(audine,ampli_ccd) "1" }
      if { ! [ info exists conf(audine,can) ] }       { set conf(audine,can)       "$caption(confcam,can_ad976a)" }
      if { ! [ info exists conf(audine,ccd) ] }       { set conf(audine,ccd)       "$caption(confcam,kaf400)" }
      if { ! [ info exists conf(audine,foncobtu) ] }  { set conf(audine,foncobtu)  "2" }
      if { ! [ info exists conf(audine,mirh) ] }      { set conf(audine,mirh)      "0" }
      if { ! [ info exists conf(audine,mirv) ] }      { set conf(audine,mirv)      "0" }
      if { ! [ info exists conf(audine,port) ] }      { set conf(audine,port)      "lpt1" }
      if { ! [ info exists conf(audine,typeobtu) ] }  { set conf(audine,typeobtu)  "$caption(confcam,obtu_audine)" }

      #--- initConf 2
      if { ! [ info exists conf(hisis,delai_a) ] }  { set conf(hisis,delai_a)  "5" }
      if { ! [ info exists conf(hisis,delai_b) ] }  { set conf(hisis,delai_b)  "2" }
      if { ! [ info exists conf(hisis,delai_c) ] }  { set conf(hisis,delai_c)  "7" }
      if { ! [ info exists conf(hisis,foncobtu) ] } { set conf(hisis,foncobtu) "2" }
      if { ! [ info exists conf(hisis,mirh) ] }     { set conf(hisis,mirh)     "0" }
      if { ! [ info exists conf(hisis,mirv) ] }     { set conf(hisis,mirv)     "0" }
      if { ! [ info exists conf(hisis,modele) ] }   { set conf(hisis,modele)   "22" }
      if { ! [ info exists conf(hisis,port) ] }     { set conf(hisis,port)     "lpt1" }
      if { ! [ info exists conf(hisis,res) ] }      { set conf(hisis,res)      "12 bits" }

      #--- initConf 3
      if { ! [ info exists conf(sbig,cool) ] }     { set conf(sbig,cool)     "0" }
      if { ! [ info exists conf(sbig,foncobtu) ] } { set conf(sbig,foncobtu) "2" }
      if { ! [ info exists conf(sbig,host) ] }     { set conf(sbig,host)     "192.168.0.2" }
      if { ! [ info exists conf(sbig,mirh) ] }     { set conf(sbig,mirh)     "0" }
      if { ! [ info exists conf(sbig,mirv) ] }     { set conf(sbig,mirv)     "0" }
      if { ! [ info exists conf(sbig,port) ] }     { set conf(sbig,port)     "lpt1" }
      if { ! [ info exists conf(sbig,temp) ] }     { set conf(sbig,temp)     "0" }

      #--- initConf 4
      if { ! [ info exists conf(cookbook,mirh) ] } { set conf(cookbook,mirh) "0" }
      if { ! [ info exists conf(cookbook,mirv) ] } { set conf(cookbook,mirv) "0" }
      if { ! [ info exists conf(cookbook,port) ] } { set conf(cookbook,port) "lpt1" }

      #--- initConf 5
      if { ! [ info exists conf(starlight,acc) ] }    { set conf(starlight,acc)    "0" }
      if { ! [ info exists conf(starlight,mirh) ] }   { set conf(starlight,mirh)   "0" }
      if { ! [ info exists conf(starlight,mirv) ] }   { set conf(starlight,mirv)   "0" }
      if { ! [ info exists conf(starlight,modele) ] } { set conf(starlight,modele) "MX516" }
      if { ! [ info exists conf(starlight,port) ] }   { set conf(starlight,port)   "lpt1" }

      #--- initConf 6
      if { ! [ info exists conf(kitty,captemp) ] } { set conf(kitty,captemp) "0" }
      if { ! [ info exists conf(kitty,mirh) ] }    { set conf(kitty,mirh)    "0" }
      if { ! [ info exists conf(kitty,mirv) ] }    { set conf(kitty,mirv)    "0" }
      if { ! [ info exists conf(kitty,modele) ] }  { set conf(kitty,modele)  "237" }
      if { ! [ info exists conf(kitty,port) ] }    { set conf(kitty,port)    "lpt1" }
      if { ! [ info exists conf(kitty,res) ] }     { set conf(kitty,res)     "12 bits" }
      if { ! [ info exists conf(kitty,on_off) ] }  { set conf(kitty,on_off)  "1" }

      #--- initConf 7
      if { ! [ info exists conf(webcam,longuepose) ] }           { set conf(webcam,longuepose)           "0" }
      if { ! [ info exists conf(webcam,longueposeport) ] }       { set conf(webcam,longueposeport)       "lpt1" }
      if { ! [ info exists conf(webcam,longueposelinkbit) ] }    { set conf(webcam,longueposelinkbit)    "0" }
      if { ! [ info exists conf(webcam,longueposestartvalue) ] } { set conf(webcam,longueposestartvalue) "0" }
      if { ! [ info exists conf(webcam,longueposestopvalue) ] }  { set conf(webcam,longueposestopvalue)  "1" }
      if { ! [ info exists conf(webcam,mirh) ] }                 { set conf(webcam,mirh)                 "0" }
      if { ! [ info exists conf(webcam,mirv) ] }                 { set conf(webcam,mirv)                 "0" }
      if { ! [ info exists conf(webcam,port) ] }                 { set conf(webcam,port)                 "0" }
      if { ! [ info exists conf(webcam,ccd_N_B) ] }              { set conf(webcam,ccd_N_B)              "0" }
      if { ! [ info exists conf(webcam,dim_ccd_N_B) ] }          { set conf(webcam,dim_ccd_N_B)          "1/4''" }

      #--- initConf 8
      if { ! [ info exists conf(th7852a,coef) ] } { set conf(th7852a,coef) "1.0" }
      if { ! [ info exists conf(th7852a,mirh) ] } { set conf(th7852a,mirh) "0" }
      if { ! [ info exists conf(th7852a,mirv) ] } { set conf(th7852a,mirv) "0" }
      if { ! [ info exists conf(th7852a,port) ] } { set conf(th7852a,port) "lpt1" }

      #--- initConf 9
      if { ! [ info exists conf(scr1300xtc,mirh) ] } { set conf(scr1300xtc,mirh) "0" }
      if { ! [ info exists conf(scr1300xtc,mirv) ] } { set conf(scr1300xtc,mirv) "0" }
      if { ! [ info exists conf(scr1300xtc,port) ] } { set conf(scr1300xtc,port) "lpt1" }

      #--- initConf 10
      if { ! [ info exists conf(dslr,link) ] }                 { set conf(dslr,link)                 "$caption(confcam,dslr_gphoto2)" }
      if { ! [ info exists conf(dslr,longue_pose) ] }          { set conf(dslr,longue_pose)          "0" }
      if { ! [ info exists conf(dslr,link_longue_pose) ] }     { set conf(dslr,link_longue_pose)     "$caption(confcam,dslr_quickremote)" }
      if { ! [ info exists conf(dslr,longueposelinkbit) ] }    { set conf(dslr,longueposelinkbit)    "0" }
      if { ! [ info exists conf(dslr,longueposestartvalue) ] } { set conf(dslr,longueposestartvalue) "1" }
      if { ! [ info exists conf(dslr,longueposestopvalue) ] }  { set conf(dslr,longueposestopvalue)  "0" }
      if { ! [ info exists conf(dslr,statut_service) ] }       { set conf(dslr,statut_service)       "1" }
      if { ! [ info exists conf(dslr,mirh) ] }                 { set conf(dslr,mirh)                 "0" }
      if { ! [ info exists conf(dslr,mirv) ] }                 { set conf(dslr,mirv)                 "0" }
      if { ! [ info exists conf(apn,baud) ] }                  { set conf(apn,baud)                 "115200" }
     ### if { ! [ info exists conf(apn,serial_port) ] }           { set conf(apn,serial_port)          [ lindex "$audace(list_com)" 0 ] }

      #--- initConf 11
      if { ! [ info exists conf(andor,cool) ] }        { set conf(andor,cool)        "0" }
      if { ! [ info exists conf(andor,foncobtu) ] }    { set conf(andor,foncobtu)    "2" }
      if { ! [ info exists conf(andor,config) ] }      { set conf(andor,config)      [ file join $audace(rep_install) bin ] }
      if { ! [ info exists conf(andor,mirh) ] }        { set conf(andor,mirh)        "0" }
      if { ! [ info exists conf(andor,mirv) ] }        { set conf(andor,mirv)        "0" }
      if { ! [ info exists conf(andor,temp) ] }        { set conf(andor,temp)        "-50" }
      if { ! [ info exists conf(andor,ouvert_obtu) ] } { set conf(andor,ouvert_obtu) "0" }
      if { ! [ info exists conf(andor,ferm_obtu) ] }   { set conf(andor,ferm_obtu)   "30" }

      #--- item par defaut
      set confCam(cam_item)          "A"
  
      #--- Initialisation des variables d'echange avec les widgets
      set confCam(camera,A,visuName) "visu1"
      set confCam(camera,B,visuName) $caption(confcam,nouvelle_visu)
      set confCam(camera,C,visuName) $caption(confcam,nouvelle_visu)
      set confCam(camera,A,camNo)    "0"
      set confCam(camera,B,camNo)    "0"
      set confCam(camera,C,camNo)    "0"
      set confCam(camera,A,visuNo)   "0"
      set confCam(camera,B,visuNo)   "0"
      set confCam(camera,C,visuNo)   "0"
      set confCam(camera,A,camName)  ""
      set confCam(camera,B,camName)  ""
      set confCam(camera,C,camName)  ""
      set confCam(camera,position)   $conf(camera,position)
      
      #--- Initalise les listes de cameras
      set confCam(camera,labels) [ list Audine Hi-SIS SBIG CB245 Starlight Kitty WebCam \
            TH7852A SCR1300XTC $caption(confcam,dslr) Andor ]
      set confCam(camera,names) [ list audine hisis sbig cookbook starlight kitty webcam \
            th7852a scr1300xtc dslr andor ]
      
   }

   #
   # confCam::run
   # Cree la fenetre de choix et de configuration des cameras
   # This = chemin de la fenetre
   # confCam(camera,A,camName) = nom de la camera (audine hisis sbig cookbook starlight kitty webcam \
   # th7852a scr1300xtc dslr andor)
   #
   proc run { } {
      variable This
      global audace
      global confCam

      set This "$audace(base).confCam"
      createDialog
      if { $confCam(camera,$confCam(cam_item),camName) != "" } {
         set cam_item $confCam(cam_item)
         select $confCam(camera,$cam_item,camName)
         if { [ string compare $confCam(camera,$cam_item,camName) sbig ] == "0" } {
            ::confCam::SbigDispTemp
         } elseif { [ string compare $confCam(camera,$cam_item,camName) kitty ] == "0" } {
            ::confCam::KittyDispTemp
         } elseif { [ string compare $confCam(camera,$cam_item,camName) andor ] == "0" } {
            ::confCam::AndorDispTemp
         }
      } else {
         select audine
      }
      catch { tkwait visibility $This }
   }


   #
   # confCam::startDriver
   # Ouvre les cameras  
   #
   proc startDriver { } {
      global conf
      global confCam
      
      if { $conf(camera,A,start) == "1" } {
         if { $conf(confLink,start) == "1" } {
            ::confLink::configureDriver
         }
         set confCam(camera,A,camName)  $conf(camera,A,camName)
         ::confCam::configureCamera "A"
      }
      if { $conf(camera,B,start) == "1" } {
         set confCam(camera,B,camName)  $conf(camera,B,camName)
         ::confCam::configureCamera "B"
      }
      if { $conf(camera,C,start) == "1" } {
         set confCam(camera,C,camName)  $conf(camera,C,camName)
         ::confCam::configureCamera "C"
      }
   }

   #
   # confCam::stopDriver
   # Ferme toutes les cameras ouvertes
   #
   proc stopDriver { } {
      global conf
      global confCam

      #---
      ::confCam::stopItem A
      ::confCam::stopItem B
      ::confCam::stopItem C
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
      global confCam
      
      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -relief groove -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled 
      #--- J'arrete la camera
      stopItem $confCam(cam_item)
      #--- je copie les parametres de la nouvelle camera dans conf()
      widgetToConf     $confCam(cam_item)
      configureCamera  $confCam(cam_item)
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
      global confCam

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -relief groove -state disabled
      $This.cmd.fermer configure -state disabled
      set camName [lindex $confCam(camera,names) [expr [Rnotebook:currentIndex $This.usr.book ] -1 ] ]
      ::audace::showHelpPlugin camera $camName "$camName.htm"
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
      variable This
      global caption
      global confCam
      global frmm

      set cam_item $confCam(cam_item)

      if { [ info exists This ] } {
         set frm $frmm(Camera1)
         if { ( [::confCam::getProduct $confCam(camera,$cam_item,camNo)] == "audine" ) && \
            ( $confCam(conf_audine,port) != "$caption(confcam,quicka)" ) && \
            ( $confCam(conf_audine,port) != "$caption(confcam,audinet)" ) && \
            ( $confCam(conf_audine,port) != "$caption(confcam,ethernaude)" ) } {
            #--- Bouton Tests pour la fabrication de la camera actif
            $frm.test configure -state normal
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
      variable This
      global conf
      global confCam
      global frmm

      set cam_item $confCam(cam_item)

      if { [ info exists This ] } {
         set frm $frmm(Camera6)
         if { [ winfo exists $frm.radio_on ] } {
            if { [::confCam::getName $confCam(camera,$cam_item,camNo)] == "KITTYK2" } {
               #--- Boutons de configuration de la Kitty K2 actif
               $frm.radio_on configure -state normal
               $frm.radio_off configure -state normal
               $frm.temp_ccd configure -state normal
               $frm.test configure -state normal
            } else {
               #--- Boutons de configuration de la Kitty K2 inactif
               $frm.radio_on configure -state disabled
               $frm.radio_off configure -state disabled
               $frm.temp_ccd configure -state disabled
               $frm.test configure -state disabled
            }
         }
      }
   }

   #
   # confCam::ConfWebCam
   # Permet d'activer ou de desactiver les boutons de configuration de la WebCam
   #
   proc ConfWebCam { } {
      variable This
      global confCam
      global frmm

      set cam_item $confCam(cam_item)

      if { [ info exists This ] } {
         set frm $frmm(Camera7)
         if { [::confCam::getProduct $confCam(camera,$cam_item,camNo)] == "webcam" } {
            #--- Boutons de configuration de la WebCam actif
            $frm.conf_webcam configure -state normal
            $frm.format_webcam configure -state normal
         } else {
            #--- Boutons de configuration de la WebCam inactif
            $frm.conf_webcam configure -state disabled
            $frm.format_webcam configure -state disabled
         }
         if { $confCam(conf_webcam,ccd_N_B) == "1" } {
            pack $frm.frame14 -in $frm.frame13 -side right -fill x -pady 5
         } else {
            pack forget $frm.frame14
         }
      }
   }

   #
   # confCam::ConfDSLR
   # Permet d'activer ou de desactiver le bouton de configuration des APN (DSLR)
   #
   proc ConfDSLR { } {
      variable This
      global confCam
      global frmm

      set cam_item $confCam(cam_item)

      if { [ info exists This ] } {
         set frm $frmm(Camera10)
         if { [ winfo exists $frm.config_telechargement ] } {
            if { [::confCam::getProduct $confCam(camera,$cam_item,camNo)] == "dslr" } {
               #--- Bouton de configuration des APN (DSLR)
               $frm.config_telechargement configure -state normal
            } else {
               #--- Bouton de configuration des APN (DSLR)
               $frm.config_telechargement configure -state disabled
            }
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

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         select $confCam(camera,$confCam(cam_item),camName)
         focus $This
         return
      }
      #---
      if { [ info exists confCam(camera,geometry) ] } {
         set deb [ expr 1 + [ string first + $confCam(camera,geometry) ] ]
         set fin [ string length $confCam(camera,geometry) ]
         set confCam(camera,position) "+[ string range $confCam(camera,geometry) $deb $fin ]"
      }
      #---
      toplevel $This
      if { $::tcl_platform(os) == "Linux" } {
         wm geometry $This 900x430$confCam(camera,position)
         wm minsize $This 900 430
      } else {
         wm geometry $This 670x430$confCam(camera,position)
         wm minsize $This 670 430
      }
      wm resizable $This 1 0
      wm deiconify $This
      wm title $This "$caption(confcam,config)"
      wm protocol $This WM_DELETE_WINDOW ::confCam::fermer

      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set nn $This.usr.book
         Rnotebook:create $nn -tabs "$confCam(camera,labels)" -borderwidth 1
         fillPage1  $nn
         fillPage2  $nn
         fillPage3  $nn
         fillPage4  $nn
         fillPage5  $nn
         fillPage6  $nn
         fillPage7  $nn
         fillPage8  $nn
         fillPage9 $nn
         fillPage10 $nn
         fillPage11 $nn
         pack $nn -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1

      #--- Je recupere la liste des visu
      set list_visu [list ]
      foreach visuNo [::visu::list] {
         lappend list_visu "visu$visuNo"
      }
      lappend list_visu $caption(confcam,nouvelle_visu)
      set confCam(camera,list_visu) $list_visu

      #--- Parametres de la camera A
      frame $This.startA -borderwidth 1 -relief raised
         radiobutton $This.startA.item -anchor w -highlightthickness 0 \
            -text "A :" -value "A" -variable confCam(cam_item) \
            -command "::confCam::selectCamItem"
         pack $This.startA.item -side left -padx 3 -pady 3 -fill x
         label $This.startA.camNo -textvariable confCam(camera,A,camNo)
         pack $This.startA.camNo -side left -padx 3 -pady 3 -fill x
         label $This.startA.name -textvariable confCam(camera,A,camName)
         pack $This.startA.name -side left -padx 3 -pady 3 -fill x
         
         ComboBox $This.startA.visu \
            -width 8          \
            -height [ llength $confCam(camera,list_visu) ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(camera,A,visuName) \
            -values $confCam(camera,list_visu)
         pack $This.startA.visu -side left -padx 3 -pady 3 -fill x
         button $This.startA.stop -text "$caption(confcam,arreter)" -width 7 -command "::confCam::stopItem A" 
         pack $This.startA.stop -side left -padx 3 -pady 3 -expand true
         checkbutton $This.startA.chk -text "$caption(confcam,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(camera,A,start)
         pack $This.startA.chk -side left -padx 3 -pady 3 -expand true
      pack $This.startA -side top -fill x

      #--- Parametres de la camera B
      frame $This.startB -borderwidth 1 -relief raised
         radiobutton $This.startB.item -anchor w -highlightthickness 0 \
            -text "B :" -value "B" -variable confCam(cam_item) \
            -command "::confCam::selectCamItem" 
         pack $This.startB.item -side left -padx 3 -pady 3 -fill x
         label $This.startB.camNo -textvariable confCam(camera,B,camNo)
         pack $This.startB.camNo -side left -padx 3 -pady 3 -fill x
         label $This.startB.name -textvariable confCam(camera,B,camName)
         pack $This.startB.name -side left -padx 3 -pady 3 -fill x
         
         ComboBox $This.startB.visu \
            -width 8          \
            -height [ llength $confCam(camera,list_visu) ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(camera,B,visuName) \
            -values $confCam(camera,list_visu)
         pack $This.startB.visu -side left -padx 3 -pady 3 -fill x
         button $This.startB.stop -text "$caption(confcam,arreter)" -width 7 -command "::confCam::stopItem B"
         pack $This.startB.stop -side left -padx 3 -pady 3 -expand true
         checkbutton $This.startB.chk -text "$caption(confcam,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(camera,B,start)
         pack $This.startB.chk -side left -padx 3 -pady 3 -expand true
      pack $This.startB -side top -fill x

      #--- Parametres de la camera C
      frame $This.startC -borderwidth 1 -relief raised
         radiobutton $This.startC.item -anchor w -highlightthickness 0 \
            -text "C :" -value "C" -variable confCam(cam_item) \
            -command "::confCam::selectCamItem" 
         pack $This.startC.item -side left -padx 3 -pady 3 -fill x
         label $This.startC.camNo -textvariable confCam(camera,C,camNo)
         pack $This.startC.camNo -side left -padx 3 -pady 3 -fill x
         label $This.startC.name -textvariable confCam(camera,C,camName)
         pack $This.startC.name -side left -padx 3 -pady 3 -fill x
         
         ComboBox $This.startC.visu \
            -width 8          \
            -height [ llength $confCam(camera,list_visu) ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(camera,C,visuName) \
            -values $confCam(camera,list_visu)
         pack $This.startC.visu -side left -padx 3 -pady 3 -fill x
         button $This.startC.stop -text "$caption(confcam,arreter)" -width 7 -command "::confCam::stopItem C"
         pack $This.startC.stop -side left -padx 3 -pady 3 -expand true
         checkbutton $This.startC.chk -text "$caption(confcam,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(camera,C,start)
         pack $This.startC.chk -side left -padx 3 -pady 3 -expand true
      pack $This.startC -side top -fill x

      #--- Frame pour les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(confcam,ok)" -width 7 -command "::confCam::ok"
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(confcam,appliquer)" -width 8 -command "::confCam::appliquer"
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(confcam,fermer)" -width 7 -command "::confCam::fermer"
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(confcam,aide)" -width 7 -command "::confCam::afficherAide"
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

      #--- confToWidget
      set confCam(conf_audine,ampli_ccd) [ lindex "$caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours)" $conf(audine,ampli_ccd) ]
      set confCam(conf_audine,can)       $conf(audine,can)
      set confCam(conf_audine,ccd)       $conf(audine,ccd)
      set confCam(conf_audine,foncobtu)  [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(audine,foncobtu) ]
      set confCam(conf_audine,mirh)      $conf(audine,mirh)
      set confCam(conf_audine,mirv)      $conf(audine,mirv)
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
      label $frm.lab1 -text "$caption(confcam,port_liaison)"
      pack $frm.lab1 -in $frm.frame10 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) $caption(confcam,quicka) \
         $caption(confcam,audinet) $caption(confcam,ethernaude) ]
      ComboBox $frm.port \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,port) \
         -values $list_combobox \
         -modifycmd {
            #--- Ouvre la configuration des liaisons sur le bon onglet
            if { $confCam(conf_audine,port) == "$caption(confcam,lpt1)" } {
               set conf(confLink) "parallelport"
               ::confLink::run
            } elseif { $confCam(conf_audine,port) == "$caption(confcam,lpt2)" } {
               set conf(confLink) "parallelport"
               ::confLink::run
            } elseif { $confCam(conf_audine,port) == "$caption(confcam,quicka)" } {
               set conf(confLink) "quickaudine"
               ::confLink::run
            } elseif { $confCam(conf_audine,port) == "$caption(confcam,audinet)" } {
               set conf(confLink) "audinet"
               ::confLink::run
            } elseif { $confCam(conf_audine,port) == "$caption(confcam,ethernaude)" } {
               set conf(confLink) "ethernaude"
               ::confLink::run
            }
         }
      pack $frm.port -in $frm.frame10 -anchor center -side right -padx 10

      #--- Bouton de configuration des liaisons
      button $frm.configure -text "$caption(confcam,link_configure)" -relief raised -command "::confLink::run"
      pack $frm.configure -in $frm.frame10 -side right -pady 10 -ipadx 10 -ipady 1 -expand true

      #--- Definition du format du CCD
      label $frm.lab2 -text "$caption(confcam,format_ccd)"
      pack $frm.lab2 -in $frm.frame11 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,kaf400) $caption(confcam,kaf1600) $caption(confcam,kaf3200) ]
      ComboBox $frm.ccd \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,ccd) \
         -values $list_combobox
      pack $frm.ccd -in $frm.frame11 -anchor center -side right -padx 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_audine,mirh)
      pack $frm.mirx -in $frm.frame12 -anchor center -side left -padx 20

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_audine,mirv)
      pack $frm.miry -in $frm.frame13 -anchor center -side left -padx 20

      #--- Fonctionnement de l'ampli du CCD
      label $frm.lab3 -text "$caption(confcam,ampli_ccd)"
      pack $frm.lab3 -in $frm.frame14 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours) ]
      ComboBox $frm.ampli_ccd \
         -width 10         \
         -height [ llength $list_combobox ] \
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
         -height [ llength $list_combobox ] \
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
         -height [ llength $list_combobox ] \
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
      set confCam(conf_audine,list_foncobtu) $list_combobox
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_audine,foncobtu) \
         -values $list_combobox
      pack $frm.foncobtu -in $frm.frame17 -anchor center -side right -padx 10

      #--- Bouton de test d'une Audine en fabrication
      button $frm.test -text "$caption(confcam,test_fab_audine)" -relief raised \
         -command "::testAudine::run $audace(base).testAudine"
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

      #--- confToWidget
      set confCam(conf_hisis,delai_a)  $conf(hisis,delai_a)
      set confCam(conf_hisis,delai_b)  $conf(hisis,delai_b)
      set confCam(conf_hisis,delai_c)  $conf(hisis,delai_c)
      set confCam(conf_hisis,foncobtu) [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(hisis,foncobtu) ]
      set confCam(conf_hisis,mirh)     $conf(hisis,mirh)
      set confCam(conf_hisis,mirv)     $conf(hisis,mirv)
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
            if { [ winfo exists $frm.lab0 ] } {
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
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
               -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.delai_a
               destroy $frm.lab4 ; destroy $frm.delai_b
               destroy $frm.lab5 ; destroy $frm.delai_c
            }
            #--- Choix du fonctionnement de l'obturateur
            if { ! [ winfo exists $frm.lab0 ] } {
               label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
               pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 10
               set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
                  $caption(confcam,obtu_synchro) ]
               ComboBox $frm.foncobtu \
                  -width 11         \
                  -height [ llength $list_combobox ] \
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
         -height [ llength $list_combobox ] \
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
            -height [ llength $list_combobox ] \
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
         -variable confCam(conf_hisis,mirh)
      pack $frm.mirx -in $frm.frame10 -anchor w -side top -padx 10 -pady 10
      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_hisis,mirv)
      pack $frm.miry -in $frm.frame10 -anchor w -side bottom -padx 10 -pady 10

      #--- Choix du fonctionnement de l'obturateur
      if { $confCam(conf_hisis,modele) != "0" } {
         label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 8
         set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
            $caption(confcam,obtu_synchro) ]
         ComboBox $frm.foncobtu \
            -width 11         \
            -height [ llength $list_combobox ] \
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

   }

   #
   # Fenetre de configuration des SBIG
   #
   proc fillPage3 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- confToWidget
      set confCam(conf_sbig,cool)     $conf(sbig,cool)
      set confCam(conf_sbig,foncobtu) [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(sbig,foncobtu) ]
      set confCam(conf_sbig,host)     $conf(sbig,host)
      set confCam(conf_sbig,mirh)     $conf(sbig,mirh)
      set confCam(conf_sbig,mirv)     $conf(sbig,mirv)
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
         -height [ llength $list_combobox ] \
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
         -variable confCam(conf_sbig,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_sbig,mirv)
      pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab3 -text "$caption(confcam,fonc_obtu)"
      pack $frm.lab3 -in $frm.frame3 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ] \
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

      #--- confToWidget
      set confCam(conf_cookbook,mirh) $conf(cookbook,mirh)
      set confCam(conf_cookbook,mirv) $conf(cookbook,mirv)
      set confCam(conf_cookbook,port) $conf(cookbook,port)

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
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_cookbook,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_cookbook,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_cookbook,mirv)
      pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      #--- Site web officiel de la CB245
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_cookbook)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_cookbook)"
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

      #--- confToWidget
      set confCam(conf_starlight,acc)    [ lindex "$caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur)" $conf(starlight,acc) ]
      set confCam(conf_starlight,mirh)   $conf(starlight,mirh)
      set confCam(conf_starlight,mirv)   $conf(starlight,mirv)
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
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_starlight,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame7 -anchor n -side left -padx 10 -pady 15

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_starlight,mirh)
      pack $frm.mirx -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_starlight,mirv)
      pack $frm.miry -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      #--- Accelerateur de port parallele
      label $frm.lab2 -text "$caption(confcam,accelerateur)"
      pack $frm.lab2 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

      set list_combobox [ list $caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur) ]
      ComboBox $frm.acc \
         -width 7          \
         -height [ llength $list_combobox ] \
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


      #--- confToWidget
      set confCam(conf_kitty,captemp) [ lindex "$caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5)" $conf(kitty,captemp) ]
      set confCam(conf_kitty,mirh)    $conf(kitty,mirh)
      set confCam(conf_kitty,mirv)    $conf(kitty,mirv)
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
            if { [ winfo exists $frm.lab4 ] } {
               destroy $frm.lab4 ; destroy $frm.radio_on ; destroy $frm.radio_off
               destroy $frm.temp_ccd ; destroy $frm.test
            }
            #--- Definition de la resolution
            if { ! [ winfo exists $frm.lab2 ] } {
               label $frm.lab2 -text "$caption(confcam,can_resolution)"
               pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10
               #---
               set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_8bits) ]
               ComboBox $frm.res \
                  -width 7          \
                  -height [ llength $list_combobox ] \
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
                  -height [ llength $list_combobox ] \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_kitty,captemp) \
                  -values $list_combobox
               pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            }
            #--- Gestion des boutons actif/inactif
            ::confCam::ConfKitty
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio0 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Kitty-255
      radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,kitty_255)" -value 255 -variable confCam(conf_kitty,modele) -state normal -command {
            set frm $frmm(Camera6)
            if { [ winfo exists $frm.lab4 ] } {
               destroy $frm.lab4 ; destroy $frm.radio_on ; destroy $frm.radio_off
               destroy $frm.temp_ccd ; destroy $frm.test
            }
            #--- Definition de la resolution
            if { ! [ winfo exists $frm.lab2 ] } {
               label $frm.lab2 -text "$caption(confcam,can_resolution)"
               pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10
               #---
               set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_8bits) ]
               ComboBox $frm.res \
                  -width 7          \
                  -height [ llength $list_combobox ] \
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
                  -height [ llength $list_combobox ] \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confCam(conf_kitty,captemp) \
                  -values $list_combobox
               pack $frm.captemp -in $frm.frame3 -anchor n -side left -padx 10 -pady 10
            }
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
            if { [ winfo exists $frm.lab2 ] } {
               destroy $frm.lab2 ; destroy $frm.res
               destroy $frm.lab3 ; destroy $frm.captemp
            }
            #--- Definition du refroidissement
            label $frm.lab4 -text "$caption(confcam,refroidissement_2)"
            pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10
            #--- Refroidissement On
            radiobutton $frm.radio_on -anchor w -highlightthickness 0 \
               -text "$caption(confcam,refroidissement_on)" -value 1 \
               -variable confCam(conf_kitty,on_off) -command "cam$confCam(camera,$confCam(cam_item),camNo) cooler on"
            pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
            #--- Refroidissement Off
            radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
               -text "$caption(confcam,refroidissement_off)" -value 0 \
               -variable confCam(conf_kitty,on_off) -command "cam$confCam(camera,$confCam(cam_item),camNo) cooler off"
            pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
            #--- Definition de la temperature du capteur CCD
            label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
            pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
            #--- Bouton de test du microcontrolleur de la carte d'interface
            button $frm.test -text "$caption(confcam,test)" -relief raised \
               -command "cam$confCam(camera,$confCam(cam_item),camNo) sx28test"
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
         -height [ llength $list_combobox ] \
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
            -height [ llength $list_combobox ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(conf_kitty,res) \
            -values $list_combobox
         pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
      }

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_kitty,mirh)
      pack $frm.mirx -in $frm.frame11 -anchor w -side left -padx 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_kitty,mirv)
      pack $frm.miry -in $frm.frame12 -anchor w -side left -padx 10

      #--- Definition du capteur de temperature
      if { $confCam(conf_kitty,modele) != "K2" } {
         label $frm.lab3 -text "$caption(confcam,capteur_temp)"
         pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

         set list_combobox [ list $caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5) ]
         ComboBox $frm.captemp \
            -width 12         \
            -height [ llength $list_combobox ] \
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
            -variable confCam(conf_kitty,on_off) -command "cam$confCam(camera,$confCam(cam_item),camNo) cooler on"
         pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Refroidissement Off
         radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
            -text "$caption(confcam,refroidissement_off)" -value 0 \
            -variable confCam(conf_kitty,on_off) -command "cam$confCam(camera,$confCam(cam_item),camNo) cooler off"
         pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Definition de la temperature du capteur CCD
         label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
         pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
         #--- Bouton de test du microcontrolleur de la carte d'interface
         button $frm.test -text "$caption(confcam,test)" -relief raised \
            -command "cam$confCam(camera,$confCam(cam_item),camNo) sx28test"
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

   }

   #
   # Fenetre de configuration des WebCam
   #
   proc fillPage7 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- confToWidget
      set confCam(conf_webcam,longuepose)           $conf(webcam,longuepose)
      set confCam(conf_webcam,longueposeport)       $conf(webcam,longueposeport)
      set confCam(conf_webcam,longueposelinkbit)    $conf(webcam,longueposelinkbit)
      set confCam(conf_webcam,longueposestartvalue) $conf(webcam,longueposestartvalue)
      set confCam(conf_webcam,longueposestopvalue)  $conf(webcam,longueposestopvalue)
      set confCam(conf_webcam,mirh)                 $conf(webcam,mirh)
      set confCam(conf_webcam,mirv)                 $conf(webcam,mirv)
      set confCam(conf_webcam,port)                 $conf(webcam,port)
      set confCam(conf_webcam,ccd_N_B)              $conf(webcam,ccd_N_B)
      set confCam(conf_webcam,dim_ccd_N_B)          $conf(webcam,dim_ccd_N_B)

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

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame4 -side top -fill x -pady 5

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame13 -side right -fill x -pady 5

      #--- Definition du canal USB
      label $frm.lab1 -text "$caption(confcam,webcam_canal_usb)"
      pack $frm.lab1 -in $frm.frame7 -anchor center -side left -padx 10

      set list_combobox [ list 0 1 2 3 4 5 6 7 8 9 ]
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_webcam,port) \
         -editable 0       \
         -values $list_combobox
      pack $frm.port -in $frm.frame7 -anchor center -side left -padx 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_webcam,mirh)
      pack $frm.mirx -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_webcam,mirv)
      pack $frm.miry -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      #--- Boutons de configuration de la source et du format video
      button $frm.conf_webcam -text "$caption(confcam,conf_webcam)" \
         -command { global confCam ; cam$confCam(camera,$confCam(cam_item),camNo) videosource }
      pack $frm.conf_webcam -in $frm.frame6 -anchor center -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true
      button $frm.format_webcam -text "$caption(confcam,format_webcam)" \
         -command { global confCam ; cam$confCam(camera,$confCam(cam_item),camNo) videoformat }
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

      set list_combobox [ list $caption(confcam,lpt1) $caption(confcam,lpt2) $caption(confcam,quickremote) ]
      ComboBox $frm.lpport \
         -width 13         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_webcam,longueposeport) \
         -values $list_combobox \
         -modifycmd {
            #--- Ouvre la configuration des liaisons sur le bon onglet
            if { $confCam(conf_webcam,longueposeport) == "$caption(confcam,lpt1)" } {
               set confCam(conf_webcam,longueposestartvalue) "0"
               set confCam(conf_webcam,longueposestopvalue)  "1"
               set conf(confLink) "parallelport"
               ::confLink::run
            } elseif { $confCam(conf_webcam,longueposeport) == "$caption(confcam,lpt2)" } {
               set confCam(conf_webcam,longueposestartvalue) "0"
               set confCam(conf_webcam,longueposestopvalue)  "1"
               set conf(confLink) "parallelport"
               ::confLink::run
            } elseif { $confCam(conf_webcam,longueposeport) == "$caption(confcam,quickremote)" } {
               set confCam(conf_webcam,longueposestartvalue) "1"
               set confCam(conf_webcam,longueposestopvalue)  "0"
               set conf(confLink) "quickremote"
               ::confLink::run
            }
         }
      pack $frm.lpport -in $frm.frame10 -anchor center -side right -padx 10 -pady 5

      button $frm.configure -text "$caption(confcam,link_configure)" -relief raised -command "::confLink::run"
      pack $frm.configure -in $frm.frame10 -side right -pady 10 -ipadx 10 -ipady 1 -expand true

      label $frm.lab3 -text "$caption(confcam,webcam_longueposebit)"
      pack $frm.lab3 -in $frm.frame11 -anchor center -side left -padx 3 -pady 5

      set list_combobox [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.longueposelinkbit \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_webcam,longueposelinkbit) \
         -editable 0       \
         -values $list_combobox
      pack $frm.longueposelinkbit -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

      label $frm.lab4 -text "$caption(confcam,webcam_longueposestart)"
      pack $frm.lab4 -in $frm.frame12 -anchor center -side left -padx 3 -pady 5

      entry $frm.longueposestartvalue -width 4 -textvariable confCam(conf_webcam,longueposestartvalue) -justify center
      pack $frm.longueposestartvalue -in $frm.frame12 -anchor center -side right -padx 10 -pady 5

      #--- WebCam modifiee avec un capteur Noir et Blanc
      checkbutton $frm.ccd_N_B -text "$caption(confcam,ccd_N_B)" -highlightthickness 0 \
         -variable confCam(conf_webcam,ccd_N_B) -command { ::confCam::ConfWebCam }
      pack $frm.ccd_N_B -in $frm.frame13 -anchor center -side left -pady 3 -pady 8

      set list_combobox [ list 1/4'' 1/3'' 1/2'' ]
      ComboBox $frm.dim_ccd_N_B \
         -width 6         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_webcam,dim_ccd_N_B) \
         -values $list_combobox
      pack $frm.dim_ccd_N_B -in $frm.frame14 -anchor center -side right -padx 10 -pady 5

      ::confCam::ConfWebCam

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

   }

   #
   # Fenetre de configuration de la TH7852A d'Yves LATIL
   #
   proc fillPage8 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm


      #--- confToWidget
      set confCam(conf_th7852a,coef) $conf(th7852a,coef)
      set confCam(conf_th7852a,mirh) $conf(th7852a,mirh)
      set confCam(conf_th7852a,mirv) $conf(th7852a,mirv)
      set confCam(conf_th7852a,port) $conf(th7852a,port)

      #--- Initialisation
      set frmm(Camera8) [ Rnotebook:frame $nn 8 ]
      set frm $frmm(Camera8)

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
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_th7852a,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame6 -anchor n -side left -padx 10 -pady 14

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_th7852a,mirh)
      pack $frm.mirx -in $frm.frame7 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_th7852a,mirv)
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
         set frm $frmm(Camera8)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
         global frmm
         set frm $frmm(Camera8)
         $frm.labURL configure -fg $color(blue)
      }

   }

   #
   # Fenetre de configuration de la SCR1300XTC
   #
   proc fillPage9 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- confToWidget
      set confCam(conf_scr1300xtc,mirh) $conf(scr1300xtc,mirh)
      set confCam(conf_scr1300xtc,mirv) $conf(scr1300xtc,mirv)
      set confCam(conf_scr1300xtc,port) $conf(scr1300xtc,port)

      #--- Initialisation
      set frmm(Camera9) [ Rnotebook:frame $nn 9 ]
      set frm $frmm(Camera9)

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
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_scr1300xtc,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_scr1300xtc,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_scr1300xtc,mirv)
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
         set frm $frmm(Camera9)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
         global frmm
         set frm $frmm(Camera9)
         $frm.labURL configure -fg $color(blue)
      }

   }

   #
   # Fenetre de configuration des APN (DSLR)
   #
   proc fillPage10 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- confToWidget
      set confCam(conf_dslr,link)                 $conf(dslr,link)
      set confCam(conf_dslr,longue_pose)          $conf(dslr,longue_pose)
      set confCam(conf_dslr,link_longue_pose)     $conf(dslr,link_longue_pose)
      set confCam(conf_dslr,longueposelinkbit)    $conf(dslr,longueposelinkbit)
      set confCam(conf_dslr,longueposestartvalue) $conf(dslr,longueposestartvalue)
      set confCam(conf_dslr,longueposestopvalue)  $conf(dslr,longueposestopvalue)
      set confCam(conf_dslr,statut_service)       $conf(dslr,statut_service)
      set confCam(conf_dslr,mirh)                 $conf(dslr,mirh)
      set confCam(conf_dslr,mirv)                 $conf(dslr,mirv)
      set confCam(conf_apn,baud)                  $conf(apn,baud)
     ### set confCam(conf_apn,serial_port)           $conf(apn,serial_port)

      #--- Initialisation
      set frmm(Camera10) [ Rnotebook:frame $nn 10 ]
      set frm $frmm(Camera10)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
     # pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
     # pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
     # pack $frm.frame4 -side top -fill x

      frame $frm.frame5 -borderwidth 0 -relief raised
     # pack $frm.frame5 -in $frm.frame4 -anchor n -side top -fill x

      frame $frm.frame6 -borderwidth 0 -relief raised
     # pack $frm.frame6 -in $frm.frame4 -anchor n -side left -fill x

      frame $frm.frame7 -borderwidth 0 -relief raised
     # pack $frm.frame7 -in $frm.frame1 -anchor n -side right -fill x

      frame $frm.frame8 -borderwidth 0 -relief raised
     # pack $frm.frame8 -in $frm.frame7 -anchor n -side top -fill x

      frame $frm.frame9 -borderwidth 0 -relief raised
     # pack $frm.frame9 -in $frm.frame7 -anchor n -side top -fill x

      frame $frm.frame10 -borderwidth 0 -relief raised
     # pack $frm.frame10 -in $frm.frame7 -anchor n -side top -fill x

      frame $frm.frame11 -borderwidth 0 -relief raised
     # pack $frm.frame11 -in $frm.frame4 -anchor n -side bottom -fill both -expand true

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -side bottom -fill x -pady 2

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -side bottom -fill x -pady 2

      #--- Label de la liaison
      label $frm.lab1 -text "$caption(confcam,dslr_liaison)"
      pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton de configuration des liaisons
      button $frm.configure -text "$caption(confcam,link_configure)" -relief raised -command "::confLink::run"
      pack $frm.configure -in $frm.frame1 -side left -pady 10 -ipadx 10 -ipady 1

      #--- Selection de la liaison
      set list_combobox [ list $caption(confcam,dslr_photopc) $caption(confcam,dslr_gphoto2) ]
      ComboBox $frm.port \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_dslr,link) \
         -values $list_combobox \
         -modifycmd {
            global frmm
            set frm $frmm(Camera10)
            #--- Ouvre la configuration des liaisons sur le bon onglet
            if { $confCam(conf_dslr,link) == "$caption(confcam,dslr_photopc)" } {
               set conf(confLink) "photopc"
               ::confLink::run
               pack $frm.frame2 -side top -fill x
               pack $frm.frame3 -side top -fill x
               pack forget $frm.frame4
               pack forget $frm.frame5
               pack forget $frm.frame6
               pack forget $frm.frame7
               pack forget $frm.frame8
               pack forget $frm.frame9
               pack forget $frm.frame10
               pack forget $frm.frame11
               pack $frm.frame12 -side bottom -fill x -pady 2
               pack forget $frm.frame13
            } elseif { $confCam(conf_dslr,link) == "$caption(confcam,dslr_gphoto2)" } {
               set conf(confLink) "gphoto2"
               ::confLink::run
               pack forget $frm.frame2
               pack forget $frm.frame3
               pack $frm.frame4 -side top -fill x
               pack $frm.frame5 -in $frm.frame4 -anchor n -side top -fill x
               pack $frm.frame6 -in $frm.frame4 -anchor s -side left -fill x
               pack $frm.frame7 -in $frm.frame1 -anchor n -side right -fill x
               pack $frm.frame8 -in $frm.frame7 -anchor n -side top -fill x
               pack $frm.frame9 -in $frm.frame7 -anchor n -side top -fill x
               pack $frm.frame10 -in $frm.frame7 -anchor n -side top -fill x
               pack $frm.frame11 -in $frm.frame4 -anchor n -side bottom -fill both -expand true
               pack forget $frm.frame12
               pack $frm.frame13 -side bottom -fill x -pady 2
            }
         }
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 20 -pady 5

      #--- Definition du port serie
     ### label $frm.lab2 -text $caption(confcam,apn_port)
     ### pack $frm.lab2 -in $frm.frame2 -anchor e -side left -padx 10 -pady 10

     ### ComboBox $frm.s_port \
     ###    -width 14         \
     ###    -height [ llength $audace(list_com) ]  \
     ###    -relief sunken    \
     ###    -borderwidth 1    \
     ###    -textvariable confCam(conf_apn,serial_port) \
     ###    -editable 0       \
     ###    -values $audace(list_com)
     ### pack $frm.s_port -in $frm.frame2 -anchor e -side left -padx 5 -pady 10

      #--- Definition de la vitesse du port série
      label $frm.lab3 -text $caption(confcam,apn_baud)
      pack $frm.lab3 -in $frm.frame3 -anchor e -side left -padx 10 -pady 10

      set list_combobox [ list 115200 57600 38400 19200 9600 ]
      ComboBox $frm.liste1 \
         -width 14         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_apn,baud) \
         -editable 0       \
         -values $list_combobox
      pack $frm.liste1 -in $frm.frame3 -anchor e -side left -padx 5 -pady 10

      #--- Selection de la liaison pour la longue pose
      set list_combobox [ list $caption(confcam,dslr_quickremote) $caption(confcam,dslr_externe) ]
      ComboBox $frm.moyen_longue_pose \
         -width 13         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(conf_dslr,link_longue_pose) \
         -values $list_combobox \
         -modifycmd {
            #--- Ouvre la configuration des liaisons sur le bon onglet
            if { $confCam(conf_dslr,link_longue_pose) == "$caption(confcam,dslr_quickremote)" } {
               set confCam(conf_dslr,longueposestartvalue) "1"
               set confCam(conf_dslr,longueposestopvalue)  "0"
               set conf(confLink) "quickremote"
               ::confLink::run
            } elseif { $confCam(conf_dslr,link_longue_pose) == "$caption(confcam,dslr_externe)" } {
               set conf(confLink) "external"
               ::confLink::run
            }
         }
      pack $frm.moyen_longue_pose -in $frm.frame8 -anchor center -side right -padx 20

      #--- Bouton de configuration des liaisons pour la longue pose
      button $frm.configure_longue_pose -text "$caption(confcam,link_configure)" -relief raised -command "::confLink::run"
      pack $frm.configure_longue_pose -in $frm.frame8 -side right -pady 10 -ipadx 10 -ipady 1

      #--- Utilisation de la longue pose
      checkbutton $frm.longue_pose -text "$caption(confcam,dslr_longue_pose)" -highlightthickness 0 \
         -variable confCam(conf_dslr,longue_pose)
      pack $frm.longue_pose -in $frm.frame8 -anchor w -side right -padx 10 -pady 10

      #--- Choix du numero du bit pour la commande de la longue pose
      label $frm.lab4 -text "$caption(confcam,dslr_longueposebit)"
      pack $frm.lab4 -in $frm.frame9 -anchor center -side left -padx 3 -pady 5

      set list_combobox [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.longueposelinkbit \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(conf_dslr,longueposelinkbit) \
         -editable 0       \
         -values $list_combobox
      pack $frm.longueposelinkbit -in $frm.frame9 -anchor center -side right -padx 20 -pady 5

      #--- Choix du niveau de depart pour la commande de la longue pose
      label $frm.lab5 -text "$caption(confcam,dslr_longueposestart)"
      pack $frm.lab5 -in $frm.frame10 -anchor center -side left -padx 3 -pady 5

      entry $frm.longueposestartvalue -width 4 -textvariable confCam(conf_dslr,longueposestartvalue) -justify center
      pack $frm.longueposestartvalue -in $frm.frame10 -anchor center -side right -padx 20 -pady 5

      #--- Gestion du Service Windows de detection automatique des APN (DSLR)
      if { $::tcl_platform(platform) == "windows" } {
         checkbutton $frm.detect_service -text "$caption(confcam,dslr_detect_service)" -highlightthickness 0 \
            -variable confCam(conf_dslr,statut_service)
         pack $frm.detect_service -in $frm.frame5 -anchor w -side top -padx 20 -pady 10
      }

      #--- Gestion des 2 types de liaisons suivant les APN (DSLR) utilisés
      if { $confCam(conf_dslr,link) == "$caption(confcam,dslr_photopc)" } {
         pack $frm.frame2 -side top -fill x
         pack $frm.frame3 -side top -fill x
         pack forget $frm.frame4
         pack forget $frm.frame5
         pack forget $frm.frame6
         pack forget $frm.frame7
         pack forget $frm.frame8
         pack forget $frm.frame9
         pack forget $frm.frame10
         pack forget $frm.frame11
         pack $frm.frame12 -side bottom -fill x -pady 2
         pack forget $frm.frame13
      } elseif { $confCam(conf_dslr,link) == "$caption(confcam,dslr_gphoto2)" } {
         pack forget $frm.frame2
         pack forget $frm.frame3
         pack $frm.frame4 -side top -fill x
         pack $frm.frame5 -in $frm.frame4 -anchor n -side top -fill x
         pack $frm.frame6 -in $frm.frame4 -anchor s -side left -fill x
         pack $frm.frame7 -in $frm.frame1 -anchor n -side right -fill x
         pack $frm.frame8 -in $frm.frame7 -anchor n -side top -fill x
         pack $frm.frame9 -in $frm.frame7 -anchor n -side top -fill x
         pack $frm.frame10 -in $frm.frame7 -anchor n -side top -fill x
         pack $frm.frame11 -in $frm.frame4 -anchor n -side bottom -fill both -expand true
         pack forget $frm.frame12
         pack $frm.frame13 -side bottom -fill x -pady 2
      }

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(conf_dslr,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_dslr,mirv)
      pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      #--- Bouton du choix du telechargement de l'image de l'APN
      button $frm.config_telechargement -text $caption(confcam,dslr_telecharger) -state normal \
         -command { ::cameraDSLR::setLoadParameters $confCam(camera,$confCam(cam_item),visuNo) }
      pack $frm.config_telechargement -in $frm.frame11 -side top -pady 10 -ipadx 10 -ipady 5 -expand true

      #--- Gestion du bouton actif/inactif
      ::confCam::ConfDSLR

      #--- Site web officiel de PhotoPC GPhoto2
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame12 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_apn)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame12 -side top -fill x -pady 2

      label $frm.lab104 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab104 -in $frm.frame13 -side top -fill x -pady 2

      label $frm.labURLa -text "$caption(confcam,site_dslr)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURLa -in $frm.frame13 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_apn)"
         ::audace::Lance_Site_htm $filename
      }
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

      bind $frm.labURLa <ButtonPress-1> {
         set filename "$caption(confcam,site_dslr)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURLa <Enter> {
         global frmm
         set frm $frmm(Camera10)
         $frm.labURLa configure -fg $color(purple)
      }
      bind $frm.labURLa <Leave> {
         global frmm
         set frm $frmm(Camera10)
         $frm.labURLa configure -fg $color(blue)
      }

   }

   #
   # Fenetre de configuration de la Andor
   #
   proc fillPage11 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- confToWidget
      set confCam(conf_andor,cool)        $conf(andor,cool)
      set confCam(conf_andor,foncobtu)    [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(andor,foncobtu) ]
      set confCam(conf_andor,config)      $conf(andor,config)
      set confCam(conf_andor,mirh)        $conf(andor,mirh)
      set confCam(conf_andor,mirv)        $conf(andor,mirv)
      set confCam(conf_andor,temp)        $conf(andor,temp)
      set confCam(conf_andor,ouvert_obtu) $conf(andor,ouvert_obtu)
      set confCam(conf_andor,ferm_obtu)   $conf(andor,ferm_obtu)

      #--- Initialisation
      set frmm(Camera11) [ Rnotebook:frame $nn 11 ]
      set frm $frmm(Camera11)

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
         -variable confCam(conf_andor,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(conf_andor,mirv)
      pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab3 -text "$caption(confcam,fonc_obtu)"
      pack $frm.lab3 -in $frm.frame9 -anchor center -side left -padx 10 -pady 5

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ] \
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
         set frm $frmm(Camera11)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
         global frmm
         set frm $frmm(Camera11)
         $frm.labURL configure -fg $color(blue)
      }

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
      pack $audace(base).connectCamera.labURL_1 -padx 10 -pady 2
      label $audace(base).connectCamera.labURL_2 -text "$caption(confcam,connexion_texte2)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      pack $audace(base).connectCamera.labURL_2 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).connectCamera

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).connectCamera
   }

   #----------------------------------------------------------------------------
   # confCam::select
   # Selectionne un onglet en passant le nom (eventuellement) de
   # la camera decrite dans l'onglet
   #----------------------------------------------------------------------------
   proc select { { camName "default" } } {
      variable This
      global confCam

      set nn $This.usr.book
      switch -exact -- $camName {
         audine     { Rnotebook:raise $nn 1 }
         hisis      { Rnotebook:raise $nn 2 }
         sbig       { Rnotebook:raise $nn 3 }
         cookbook   { Rnotebook:raise $nn 4 }
         starlight  { Rnotebook:raise $nn 5 }
         kitty      { Rnotebook:raise $nn 6 }
         webcam     { Rnotebook:raise $nn 7 }
         th7852a    { Rnotebook:raise $nn 8 }
         scr1300xtc { Rnotebook:raise $nn 9 }
         dslr       { Rnotebook:raise $nn 10 }
         andor      { Rnotebook:raise $nn 11 }
      }
   }

   #----------------------------------------------------------------------------
   # confCam::selectCamItem
   # Selectionne un onglet en passant l'item de la camera
   #
   # parametres :
   #    aucun
   #----------------------------------------------------------------------------
   proc selectCamItem { } {
      global confCam

      #--- je recupere l'item courant
      set cam_item $confCam(cam_item)

      #--- je selectionne l'onglet correspondant a la camera de cet item
      ::confCam::select $confCam(camera,$cam_item,camName) 
   }

   #----------------------------------------------------------------------------
   # confCam::stopItem
   # Arrete la camera cam_item
   #----------------------------------------------------------------------------
   proc stopItem { cam_item } {
      global audace
      global conf
      global confCam

      set camNo $confCam(camera,$cam_item,camNo)
      if { $camNo != 0 } {
         #--- Restitue si necessaire l'etat du service WIA sous Windows
         if { ( $::tcl_platform(platform) == "windows" ) && ( $confCam(camera,$cam_item,camName) == "dslr" ) } {
            if { [ cam$camNo systemservice ] != "$conf(dslr,statut_service)" } {
               cam$camNo systemservice $conf(dslr,statut_service)
            }
         }
         #--- Je desassocie la camera de la visu
         if { $confCam(camera,$cam_item,visuNo) != 0 } {
            ::confVisu::setCamera $confCam(camera,$cam_item,visuNo) 0
            set confCam(camera,$cam_item,visuNo) "0"
         }
         
         #--- Supprime la camera
         set result [ catch { cam::delete $camNo } erreur ]
         if { $result == "1" } { console::affiche_erreur "$erreur \n" }
      }      
      
      #--- Raz des parametres de l'item 
      set confCam(camera,$cam_item,camNo) "0"
      if { $cam_item == "A" } {
         set audace(camNo) $confCam(camera,$cam_item,camNo)
      }
      set confCam(camera,$cam_item,camName) ""
   }

   #
   # confCam::isReady
   #    Retourne "1" si la camera est demarree, sinon retourne "0"
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc isReady { camNo } {
      #--- Je verifie si la camera est capable fournir son nom
      set result [ catch { cam$camNo name } ]
      if { $result == 1 } {
         #--- Erreur
         return 0
      } else {
         #--- Camera OK
         return 1
      }
   }

   #
   # confCam::getBinningList
   #    Retourne la liste des binnings possibles de la camera
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc getBinningList { camNo } {
      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } product]
      if { $result == 0 } {
         #---
         switch $product {
            dslr {
               set binningList [cam$camNo quality list]
            }
            default {
               set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 }
            }
         }
      } else {
         set binningList { }
      }
      return $binningList
   }

   #
   # confCam::getBinningList_Scan
   #    Retourne la liste des binnings Audine possibles pour les outils Drift-scan et
   #    Scan rapide en fonction du type de liaison utilisee (parallele, Audinet ou EthernAude)
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc getBinningList_Scan { camNo } {
      global conf

      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } product]
      if { $result == 0 } {
         if { $product == "audine" } {
            #---
            switch $conf(confLink) {
               ethernaude {
                  set binningList_Scan { 1x1 2x2 }
               }
               audinet {
                  #--- A confirmer avec le materiel
                  set binningList_Scan { 1x1 2x2 4x4 }
               }
               parallelport {
                  set binningList_Scan { 1x1 2x2 4x4 }
               }
               default {
                  set binningList_Scan { }
               }
            }
         } else {
            set binningList_Scan { }
         }
      } else {
         set binningList_Scan { }
      }
      return $binningList_Scan
   }

   #
   # confCam::getName
   #    Retourne le nom de la camera si la camera est demarree, sinon retourne "0"
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc getName { camNo } {
      #--- Je verifie si la camera est capable fournir son nom
      set result [ catch { cam$camNo name } camName ]
      #---
      if { $result == 1 } {
         #--- Erreur
         return 0
      } else {
         #--- Camera OK
         return $camName
      }
   }

   #
   # confCam::getProduct
   #    Retourne le nom de la famille de la camera si la camera est demarree, sinon retourne "0"
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc getProduct { camNo } {
      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 1 } {
         #--- Erreur
         return 0
      } else {
         #--- Camera OK
         return $camProduct
      }
   }

   #
   # confCam::hasVideo
   #    Retourne "1" si la camera possede un mode video, sinon retourne "0"
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc hasVideo { camNo } {
      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---  
      if { $result == 0 } {
         switch -exact -- $camProduct {
            webcam     { return 1 }
            default    { return 0 }
         }
      } else {
         return 0
      }
   }

   #
   # confCam::hasScan
   #    Retourne "1" si la camera possede un mode scan, sinon retourne "0"
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc hasScan { camNo } {
      global conf

      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 0 } {
         switch -exact -- $camProduct {
            audine  {
                       if { $conf(confLink) == "parallelport" } {
                          return 1
                       } elseif { $conf(confLink) == "audinet" } {
                          return 1
                       } elseif { $conf(confLink) == "ethernaude" } {
                          return 1
                       } else {
                          return 0
                       }
                    }
            default { return 0 }
         }
      } else {
         return 0
      }
   }

   #
   # confCam::hasShutter
   #    Retourne "1" si la camera possede un obturateur, sinon retourne "0"
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc hasShutter { camNo } {
      global conf

      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 0 } {
         switch -exact -- $camProduct {
            audine  { return 1 }
            hisis   {
                       if { $conf(hisis,modele) == "11" } {
                          return 0
                       } else {
                          return 1
                       }
                    }
            sbig    { return 1 }
            andor   { return 1 }
            default { return 0 }
         }
      } else {
         return 0
      }
   }

   #
   # confCam::getShutterOption
   #    Retourne la liste des options de l'obturateur (O : ouvert, F : ferme, S : synchro)
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc getShutterOption { camNo } {
      global conf
      global caption

      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 0 } {
         switch -exact -- $camProduct {
            audine  {
                       if { $conf(confLink) == "parallelport" } {
                          #--- O + F + S
                          set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                       } elseif { $conf(confLink) == "quickaudine" } {
                          #--- F + S
                          set ShutterOptionList [ list $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                       } elseif { $conf(confLink) == "audinet" } {
                          #--- O + F + S - A confirmer avec le materiel
                          set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                       } elseif { $conf(confLink) == "ethernaude" } {
                          #--- F + S
                          set ShutterOptionList [ list $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                       }
                    }
            hisis   {
                       if { $conf(hisis,modele) == "11" } {
                          set ShutterOptionList { }
                       } else {
                          #--- O + F + S - A confirmer avec le materiel
                          set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                       }
                    }
            sbig    {
               #--- O + F + S - A confirmer avec le materiel
               set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                    }
            andor   {
               #--- O + F + S - A confirmer avec le materiel
               set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                    }
            default {
               set ShutterOptionList { }
            }
         }
      } else {
         set ShutterOptionList { }
      }
      return $ShutterOptionList
   }

   #
   # confCam::setconfLink_Audine
   #    Positionne la liaison sur celle qui vient d'etre selectionnee pour la camera Audine
   #
   proc setconfLink_Audine { } {
      global caption
      global conf
      global confCam
      global frmm

      #--- Initialisation pour l'onglet Audine
      set frm $frmm(Camera1)
      #--- Positionnement en fonction de la liaison selectionnee
      if { $conf(confLink) == "parallelport" } {
         if { $confCam(conf_audine,port) != "$caption(confcam,lpt2)" } {
            set confCam(conf_audine,port) "$caption(confcam,lpt1)"
         }
      } elseif { $conf(confLink) == "quickaudine" } {
         set confCam(conf_audine,port) "$caption(confcam,quicka)"
      } elseif { $conf(confLink) == "audinet" } {
         set confCam(conf_audine,port) "$caption(confcam,audinet)"
      } elseif { $conf(confLink) == "ethernaude" } {
         set confCam(conf_audine,port) "$caption(confcam,ethernaude)"
      }
      $frm.port configure -textvariable confCam(conf_audine,port)
   }

   #
   # confCam::setconfLink_WebCam
   #    Positionne la liaison sur celle qui vient d'etre selectionnee pour la camera WebCam
   #
   proc setconfLink_WebCam { } {
      global caption
      global conf
      global confCam
      global frmm

      #--- Initialisation pour l'onglet WebCam
      set frm $frmm(Camera7)
      #--- Positionnement en fonction de la liaison selectionnee
      if { $conf(confLink) == "parallelport" } {
         if { $confCam(conf_webcam,longueposeport) != "$caption(confcam,lpt2)" } {
            set confCam(conf_webcam,longueposeport) "$caption(confcam,lpt1)"
         }
      } elseif { $conf(confLink) == "quickremote" } {
         set confCam(conf_webcam,longueposeport) "$caption(confcam,quickremote)"
      }
      $frm.lpport configure -textvariable confCam(conf_webcam,longueposeport)
   }

   #
   # confCam::setconfLink_APN
   #    Positionne la liaison sur celle qui vient d'etre selectionnee pour la camera APN
   #
   proc setconfLink_APN { } {
      global caption
      global conf
      global confCam
      global frmm

      #--- Initialisation pour l'onglet APN
      set frm $frmm(Camera10)
      #--- Positionnement en fonction de la liaison selectionnee
      if { $conf(confLink) == "photopc" } {
         set confCam(conf_dslr,link) "$caption(confcam,dslr_photopc)"
         $frm.port configure -textvariable confCam(conf_dslr,link)
      } elseif { $conf(confLink) == "gphoto2" } {
         set confCam(conf_dslr,link) "$caption(confcam,dslr_gphoto2)"
         $frm.port configure -textvariable confCam(conf_dslr,link)
      } elseif { $conf(confLink) == "quickremote" } {
         set confCam(conf_dslr,link_longue_pose) "$caption(confcam,dslr_quickremote)"
         $frm.moyen_longue_pose configure -textvariable confCam(conf_dslr,link_longue_pose)
      } elseif { $conf(confLink) == "external" } {
         set confCam(conf_dslr,link_longue_pose) "$caption(confcam,dslr_externe)"
         $frm.moyen_longue_pose configure -textvariable confCam(conf_dslr,link_longue_pose)
      }
      #--- Gestion des 2 types de liaisons suivant les APN (DSLR) utilisés
      if { $confCam(conf_dslr,link) == "$caption(confcam,dslr_photopc)" } {
         pack $frm.frame2 -side top -fill x
         pack $frm.frame3 -side top -fill x
         pack forget $frm.frame4
         pack forget $frm.frame5
         pack forget $frm.frame6
         pack forget $frm.frame7
         pack forget $frm.frame8
         pack forget $frm.frame9
         pack forget $frm.frame10
         pack forget $frm.frame11
         pack $frm.frame12 -side bottom -fill x -pady 2
         pack forget $frm.frame13
      } elseif { $confCam(conf_dslr,link) == "$caption(confcam,dslr_gphoto2)" } {
         pack forget $frm.frame2
         pack forget $frm.frame3
         pack $frm.frame4 -side top -fill x
         pack $frm.frame5 -in $frm.frame4 -anchor n -side top -fill x
         pack $frm.frame6 -in $frm.frame4 -anchor s -side left -fill x
         pack $frm.frame7 -in $frm.frame1 -anchor n -side right -fill x
         pack $frm.frame8 -in $frm.frame7 -anchor n -side top -fill x
         pack $frm.frame9 -in $frm.frame7 -anchor n -side top -fill x
         pack $frm.frame10 -in $frm.frame7 -anchor n -side top -fill x
         pack $frm.frame11 -in $frm.frame4 -anchor n -side bottom -fill both -expand true
         pack forget $frm.frame12
         pack $frm.frame13 -side bottom -fill x -pady 2
      }
   }

   #
   # confCam::closeCamera
   #  Ferme la camera
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc closeCamera { camNo } {
      global confCam
      
      if { $confCam(camera,A,camNo) == $camNo } {
         stopItem "A"
      }
      if { $confCam(camera,B,camNo) == $camNo } {
         stopItem "B"
      }
      if { $confCam(camera,C,camNo) == $camNo } {
         stopItem "C"
      }
   }

   #
   # confCam::configureCamera
   # Configure la camera en fonction des donnees contenues dans le tableau conf :
   # confCam(camera,A,camName) -> type de camera employe
   # conf(cam,A,...) -> proprietes de ce type de camera
   #
   proc configureCamera { cam_item } {
      variable This
      global audace
      global caption
      global conf
      global confcolor
      global confCam
      global panneau

      # Initialisation de la variable erreur
      set erreur "1"

      #--- Affichage d'un message d'alerte si necessaire
      ::confCam::Connect_Camera

      #--- Inhibe les menus
      ::audace::menustate disabled

      #--- Je recupere le numero de visu associe a la camera
      if { "$confCam(camera,$cam_item,camName)" != "" } {
         if { $confCam(camera,$cam_item,visuName) == $caption(confcam,nouvelle_visu) } {
            set visuNo [::confVisu::create]
            set confCam(camera,$cam_item,visuName) visu$visuNo
         } else {
            scan $confCam(camera,$cam_item,visuName) "visu%d" visuNo
            # je verifie que la visu existe
            if { [lsearch -exact [visu::list] $visuNo] == -1 } {
               #--- si la visu n'existe plus , je la recree
               set visuNo [::confVisu::create]
               set confCam(camera,$cam_item,visuName) visu$visuNo
            }            
         }
         set confCam(camera,$cam_item,visuNo) $visuNo
      } else {
         #--- Si c'est l'ouverture d'une camera au demarrage de Audela
         #--- J'impose la visu :
         if { $cam_item == "A" } { set visuNo 1 }
         if { $cam_item == "B" } { set visuNo [::confVisu::create] }
         if { $cam_item == "C" } { set visuNo [::confVisu::create] }
      }

      #--- Remise a jour de la liste des visu
      set list_visu [list ]
      foreach n [::visu::list] {
         lappend list_visu "visu$n"
      }
      lappend list_visu $caption(confcam,nouvelle_visu)
      set confCam(camera,list_visu) $list_visu

      if { [ info exists This ] } {
         $This.startA.visu configure -height [ llength $confCam(camera,list_visu) ]
         $This.startA.visu configure -values $confCam(camera,list_visu)
         $This.startB.visu configure -height [ llength $confCam(camera,list_visu) ]
         $This.startB.visu configure -values $confCam(camera,list_visu)
         $This.startC.visu configure -height [ llength $confCam(camera,list_visu) ]
         $This.startC.visu configure -values $confCam(camera,list_visu)
      }

      #--- Je recupere le numero buffer associe a la camera
      set bufNo [::confVisu::getBufNo $visuNo]

      switch -exact -- $confCam(camera,$cam_item,camName) {
         hisis {
               if { $conf(hisis,modele) == "11" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS11 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 4096 0
                  }
               } elseif { $conf(hisis,modele) == "22" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS22-[ lindex $conf(hisis,res) 0 ] } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele) ($conf(hisis,res))\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     cam$confCam(camera,$cam_item,camNo) delayloops $conf(hisis,delai_a) $conf(hisis,delai_b) $conf(hisis,delai_c)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "23" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS23 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "24" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS24 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "33" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS33 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "36" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS36 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "39" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS39 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "43" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS43 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "44" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS44 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(hisis,modele) == "48" } {
                  set erreur [ catch { cam::create hisis $conf(hisis,port) -name Hi-SIS48 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                        $caption(confcam,2points) $conf(hisis,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     set foncobtu $conf(hisis,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(hisis,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(hisis,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               }
            }
         sbig {
              ### set conf(sbig,host) [ ::audace::verifip $conf(sbig,host) ]
               set erreur [ catch { cam::create sbig $conf(sbig,port) -ip $conf(sbig,host) } camNo ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$camNo" -icon error
               } else {
                  set confCam(camera,$cam_item,camNo) $camNo
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_sbig) ([ cam$confCam(camera,$cam_item,camNo) name ]) \
                     $caption(confcam,2points) $conf(sbig,port)\n"
                  set foncobtu $conf(sbig,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$confCam(camera,$cam_item,camNo) shutter "opened"
                     }
                     1 {
                        cam$confCam(camera,$cam_item,camNo) shutter "closed"
                     }
                     2 {
                        cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                     }
                  }
                  if { $conf(sbig,cool) == "1" } {
                     cam$confCam(camera,$cam_item,camNo) cooler check $conf(sbig,temp)
                  } else {
                     cam$confCam(camera,$cam_item,camNo) cooler off
                  }
                  cam$confCam(camera,$cam_item,camNo) buf $bufNo
                  cam$confCam(camera,$cam_item,camNo) mirrorh $conf(sbig,mirh)
                  cam$confCam(camera,$cam_item,camNo) mirrorv $conf(sbig,mirv)
                  ::confVisu::visuDynamix $visuNo 65535 0
                  #---
                  if { [ info exists confCam(conf_sbig,aftertemp) ] == "0" } {
                     ::confCam::SbigDispTemp
                  }
               }
            }
         cookbook {
               set erreur [ catch { cam::create cookbook $conf(cookbook,port) -name CB245 } camNo ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$camNo" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_cookbook) $caption(confcam,2points) $conf(cookbook,port)\n"
                  set confCam(camera,$cam_item,camNo) $camNo
                  cam$confCam(camera,$cam_item,camNo) buf $bufNo
                  cam$confCam(camera,$cam_item,camNo) mirrorh $conf(cookbook,mirh)
                  cam$confCam(camera,$cam_item,camNo) mirrorv $conf(cookbook,mirv)
                  ::confVisu::visuDynamix $visuNo 4096 -4096
               }
            }
         starlight {
               set starlight_accelerator $conf(starlight,acc)
               if { $conf(starlight,modele) == "MX516" } {
                  set erreur [ catch { cam::create starlight $conf(starlight,port) -name MX516 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                        $caption(confcam,2points) $conf(starlight,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) accelerator $starlight_accelerator
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(starlight,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(starlight,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(starlight,modele) == "MX916" } {
                  set erreur [ catch { cam::create starlight $conf(starlight,port) -name MX916 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                        $caption(confcam,2points) $conf(starlight,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) accelerator $starlight_accelerator
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(starlight,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(starlight,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(starlight,modele) == "HX516" } {
                  set erreur [ catch { cam::create starlight $conf(starlight,port) -name HX516 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                        $caption(confcam,2points) $conf(starlight,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) accelerator $starlight_accelerator
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(starlight,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(starlight,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               }
            }
         kitty {
               if { $conf(kitty,modele) == "237" } {
                  set erreur [ catch { cam::create kitty $conf(kitty,port) -name KITTY237 \
                     -canbits [ lindex $conf(kitty,res) 0 ] } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele) ($conf(kitty,res))\
                        $caption(confcam,2points) $conf(kitty,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) canbits [ lindex $conf(kitty,res) 0 ]
                     if { $conf(kitty,captemp) == "0" } {
                        cam$confCam(camera,$cam_item,camNo) AD7893 AN2
                     } else {
                        cam$confCam(camera,$cam_item,camNo) AD7893 AN5
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(kitty,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(kitty,mirv)
                     ::confVisu::visuDynamix $visuNo 4096 -4096
                  }
               } elseif { $conf(kitty,modele) == "255" } {
                  set erreur [ catch { cam::create kitty $conf(kitty,port) -name KITTY255 \
                     -canbits [ lindex $conf(kitty,res) 0 ] } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele) ($conf(kitty,res))\
                        $caption(confcam,2points) $conf(kitty,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) canbits [ lindex $conf(kitty,res) 0 ]
                     if { $conf(kitty,captemp) == "0" } {
                        cam$confCam(camera,$cam_item,camNo) AD7893 AN2
                     } else {
                        cam$confCam(camera,$cam_item,camNo) AD7893 AN5
                     }
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(kitty,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(kitty,mirv)
                     ::confVisu::visuDynamix $visuNo 4096 -4096
                  }
               } elseif { $conf(kitty,modele) == "K2" } {
                  set erreur [ catch { cam::create k2 $conf(kitty,port) -name KITTYK2 } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele)\
                        $caption(confcam,2points) $conf(kitty,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(kitty,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(kitty,mirv)
                     #---
                     if { $conf(kitty,on_off) == "1" } {
                        cam$confCam(camera,$cam_item,camNo) cooler on
                     } else {
                        cam$confCam(camera,$cam_item,camNo) cooler off
                     }
                     #---
                     ::confVisu::visuDynamix $visuNo 4096 -4096
                     #---
                     if { [ info exists confCam(conf_kitty,aftertemp) ] == "0" } {
                        ::confCam::KittyDispTemp
                     }
                  }
               }
            }
         webcam {
               set erreur [ catch { cam::create webcam usb -channel $conf(webcam,port) \
                  -lpport $conf(webcam,longueposeport) -name WEBCAM } camNo ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$camNo" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,webcam_canal_usb) ($caption(confcam,webcam))\
                     $caption(confcam,2points) $conf(webcam,port)\n"
                  console::affiche_erreur "$caption(confcam,webcam_longuepose) $caption(confcam,2points)\
                     $conf(webcam,longuepose)\n"
                  set confCam(camera,$cam_item,camNo) $camNo
                  cam$confCam(camera,$cam_item,camNo) buf [visu$visuNo buf]
                  cam$confCam(camera,$cam_item,camNo) longuepose $conf(webcam,longuepose)
                  cam$confCam(camera,$cam_item,camNo) longueposestartvalue $conf(webcam,longueposestartvalue)
                  cam$confCam(camera,$cam_item,camNo) longueposestopvalue $conf(webcam,longueposestopvalue)
                  cam$confCam(camera,$cam_item,camNo) mirrorh $conf(webcam,mirh)
                  cam$confCam(camera,$cam_item,camNo) mirrorv $conf(webcam,mirv)
                  ::confVisu::visuDynamix $visuNo 512 -255
                  #--- Commande pour la Longue Pose
                  if { $conf(webcam,longuepose) == "1" } {
                     if { $conf(webcam,longueposeport) == "$caption(confcam,lpt1)" } {
                        #--- Test Longue Pose via le port parallele lpt1
                        set conf(webcam,longueposelinktype)  "parallelport"
                        set conf(webcam,longueposelinkindex) "1" ; # Numero du port parallele (lpt1 - 1, lpt2 - 2, ...)
                     } elseif { $conf(webcam,longueposeport) == "$caption(confcam,lpt2)" } {
                        #--- Test Longue Pose via le port parallele lpt2
                        set conf(webcam,longueposelinktype)  "parallelport"
                        set conf(webcam,longueposelinkindex) "1" ; # Numero du port parallele (lpt1 - 1, lpt2 - 2, ...)
                     } elseif { $conf(webcam,longueposeport) == "$caption(confcam,quickremote)" } {
                        #--- Test Longue Pose via Quickremote
                        set conf(webcam,longueposelinktype)  "quickremote"
                        set conf(webcam,longueposelinkindex) "0" ; # Numero du QuickRemote (0, 1, ...)
                     }
                     #--- Je cree la liaison
                     set linkno [::link::create $conf(webcam,longueposelinktype) $conf(webcam,longueposelinkindex)]
                     cam$confCam(camera,$cam_item,camNo) longueposelinkno $linkno
                     cam$confCam(camera,$cam_item,camNo) longueposelinkbit $conf(webcam,longueposelinkbit)
                  }
               }
            }
         th7852a {
               set erreur [ catch { cam::create camth $conf(th7852a,port) -name TH7852A } camNo ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$camNo" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_th7852a) $caption(confcam,2points)\
                     $conf(th7852a,port)\n"
                  set confCam(camera,$cam_item,camNo) $camNo
                  cam$confCam(camera,$cam_item,camNo) buf $bufNo
                  cam$confCam(camera,$cam_item,camNo) mirrorh $conf(th7852a,mirh)
                  cam$confCam(camera,$cam_item,camNo) mirrorv $conf(th7852a,mirv)
                  cam$confCam(camera,$cam_item,camNo) timescale $conf(th7852a,coef)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               }
            }
         scr1300xtc {
               set erreur [ catch { cam::create synonyme $conf(scr1300xtc,port) -name SCR1300XTC } camNo ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$camNo" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_scr1300xtc) $caption(confcam,2points)\
                     $conf(scr1300xtc,port)\n"
                  set confCam(camera,$cam_item,camNo) $camNo
                  cam$confCam(camera,$cam_item,camNo) buf $bufNo
                  cam$confCam(camera,$cam_item,camNo) mirrorh $conf(scr1300xtc,mirh)
                  cam$confCam(camera,$cam_item,camNo) mirrorv $conf(scr1300xtc,mirv)
                  ::confVisu::visuDynamix $visuNo 4096 -4096
               }
            }
         dslr {
               if { $conf(dslr,link) == "$caption(confcam,dslr_gphoto2)" } {
                  set erreur [ catch { cam::create digicam -name DSLR } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     set confCam(camera,$cam_item,camNo) $camNo
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,dslr_name) $caption(confcam,2points)\
                        [ cam$confCam(camera,$cam_item,camNo) name ]\n"
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(dslr,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(dslr,mirv)
                     
                     #--- J'arrete le service WIA de Windows
                     cam$confCam(camera,$cam_item,camNo) systemservice 0
                     #--- Parametrage des longues poses 
                     if { $conf(dslr,longue_pose) == "1" } {
                        if { $conf(dslr,link_longue_pose) == "$caption(confcam,dslr_quickremote)" } {
                           cam$confCam(camera,$cam_item,camNo) longuepose 1
                           #--- Liaison par QuickRemote index=0 (je fixe les valeurs en dur en attendant que ce soit saisi dans la boite de configuration)
                           set conf(dslr,longueposelinktype)  "quickremote"
                           set conf(dslr,longueposelinkindex) "0"
                           #--- Je cree la liaison
                           set linkno [::link::create $conf(dslr,longueposelinktype) $conf(dslr,longueposelinkindex)]
                           #---
                           cam$confCam(camera,$cam_item,camNo) longueposelinkno $linkno
                           cam$confCam(camera,$cam_item,camNo) longueposelinkbit $conf(dslr,longueposelinkbit)
                           cam$confCam(camera,$cam_item,camNo) longueposestartvalue $conf(dslr,longueposestartvalue)
                           cam$confCam(camera,$cam_item,camNo) longueposestopvalue  $conf(dslr,longueposestopvalue)
                        } elseif { $conf(dslr,link_longue_pose) == "$caption(confcam,dslr_externe)" } {
                           cam$confCam(camera,$cam_item,camNo) longuepose 2
                        }
                     } else {
                        cam$confCam(camera,$cam_item,camNo) longuepose 0
                     }
                     #--- Parametrage du telechargement des images
                     cam$confCam(camera,$cam_item,camNo) usecf $conf(dslr,utiliser_cf)
                     switch -exact -- $conf(dslr,telecharge_mode) {
                        1  {
                           #--- Ne pas telecharger
                           cam$confCam(camera,$cam_item,camNo) autoload 0
                        }
                        2  {
                           #--- Telechargement immediat
                           cam$confCam(camera,$cam_item,camNo) autoload 1
                        }
                        3  {
                           #--- Telechargement pendant la pose suivante
                           cam$confCam(camera,$cam_item,camNo) autoload 0
                        }
                     }                     
                     #---
                     ::confVisu::visuDynamix $visuNo 512 -255
                  }
               } elseif { $conf(dslr,link) == "$caption(confcam,dslr_photopc)" } {
                  set camNo ""
                  set erreur [ catch { ::AcqAPN::Off ; ::AcqAPN::Query } camNo ]
                  if { $camNo=="" } {
                     set camNo "1" 
                     if { ! [ info exists camNo ] } { set camNo "1" } else { incr camNo "1" }
                     set confCam(camera,$cam_item,camNo) $camNo
                  } else {
                     set erreur "1"
                  }
               }
            }
         andor {
               set erreur [ catch { cam::create andor "$conf(andor,config)" } camNo ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$camNo" -icon error
               } else {
                  set confCam(camera,$cam_item,camNo) $camNo
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(confcam,port_andor) ([ cam$confCam(camera,$cam_item,camNo) name ]) \
                     $caption(confcam,2points) $conf(andor,config)\n"
                  set foncobtu $conf(andor,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$confCam(camera,$cam_item,camNo) shutter "opened"
                     }
                     1 {
                        cam$confCam(camera,$cam_item,camNo) shutter "closed"
                     }
                     2 {
                        cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                     }
                  }
                  if { $conf(andor,cool) == "1" } {
                     cam$confCam(camera,$cam_item,camNo) cooler on
                     cam$confCam(camera,$cam_item,camNo) cooler check $conf(andor,temp)
                  } else {
                     cam$confCam(camera,$cam_item,camNo) cooler off
                  }
                  cam$confCam(camera,$cam_item,camNo) buf $bufNo
                  cam$confCam(camera,$cam_item,camNo) mirrorh $conf(andor,mirh)
                  cam$confCam(camera,$cam_item,camNo) mirrorv $conf(andor,mirv)
                  ::confVisu::visuDynamix $visuNo 65535 0
                  #--- Delais d'ouverture et de fermeture de l'obturateur
                  cam$confCam(camera,$cam_item,camNo) openingtime $conf(andor,ouvert_obtu)
                  cam$confCam(camera,$cam_item,camNo) closingtime $conf(andor,ferm_obtu)
                  #---
                  if { [ info exists confCam(conf_andor,aftertemp) ] == "0" } {
                     ::confCam::AndorDispTemp
                  }
               }
            }
         audine {
               if { [ string range $conf(audine,ccd) 0 4 ] == "kaf16" } {
                  set ccd "kaf1602"
               } elseif { [ string range $conf(audine,ccd) 0 4 ] == "kaf32" } {
                  set ccd "kaf3200"
               } else {
                  set ccd "kaf401"
               }
               if { $conf(audine,port) == "$caption(confcam,quicka)" } {
                  set erreur [ catch { cam::create quicka $conf(audine,port) -ccd $ccd -name Audine } camNo ]
               } elseif { $conf(audine,port) == "$caption(confcam,ethernaude)" } {
###
### Attention : Ajout de 2 fois -debug dans le cam::create
###
                 ### set conf(ethernaude,host) [ ::audace::verifip $conf(ethernaude,host) ]
                  set eth_canspeed "0"
                  set eth_canspeed [ expr round(($conf(ethernaude,canspeed)-7.11)/(39.51-7.11)*30.) ]
                  if { $eth_canspeed < "0" } { set eth_canspeed "0" }
                  if { $eth_canspeed > "100" } { set eth_canspeed "100" }
                  if { $conf(ethernaude,ipsetting) == "1" } {
                     set erreur [ catch { cam::create ethernaude udp -ip $conf(ethernaude,host) \
                        -canspeed $eth_canspeed -name Audine \
                        -ipsetting [ file join $audace(rep_install) bin IPSetting.exe ] -debug } camNo ]
                  } else {
                     set erreur [ catch { cam::create ethernaude udp -ip $conf(ethernaude,host) \
                        -canspeed $eth_canspeed -name Audine -debug } camNo ]
                  }
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     set confCam(camera,$cam_item,camNo) $camNo
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,ethernaude) $caption(confcam,plus)\
                        [ string range [ cam$confCam(camera,$cam_item,camNo) name ] 0 5 ] ([ cam$confCam(camera,$cam_item,camNo) ccd])\n"
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(audine,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(audine,mirv)
                     set foncobtu $conf(audine,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     if { [ string range $conf(audine,typeobtu) 0 5 ] == "audine" } {
                        if { [ string index $conf(audine,typeobtu) 7 ] == "-" } {
                           catch { cam$confCam(camera,$cam_item,camNo) shuttertype audine }
                        } else {
                           catch { cam$confCam(camera,$cam_item,camNo) shuttertype audine reverse }
                        }
                     }
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } elseif { $conf(audine,port) == "$caption(confcam,audinet)" } {
                  set erreur [ catch { cam::create audinet "" -ccd $ccd -name Audine \
                     -host $conf(audinet,host) -protocole $conf(audinet,protocole) -udptempo $conf(audinet,udptempo) \
                     -ipsetting $conf(audinet,ipsetting) -macaddress $conf(audinet,mac_address) } camNo ]
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,audinet) ($conf(audinet,protocole)) $caption(confcam,audine)\
                        ($conf(audine,ccd))\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     cam$confCam(camera,$cam_item,camNo) buf $bufNo
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(audine,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(audine,mirv)
                     set foncobtu $conf(audine,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     if { [ string range $conf(audine,typeobtu) 0 5 ] == $caption(confcam,obtu_audine) } {
                        if { [ string index $conf(audine,typeobtu) 7 ] == "-" } {
                           catch { cam$confCam(camera,$cam_item,camNo) shuttertype audine reverse }
                        } else {
                           catch { cam$confCam(camera,$cam_item,camNo) shuttertype audine }
                        }
                     } elseif { $conf(audine,typeobtu) == $caption(confcam,obtu_thierry) } {
                        catch { cam$confCam(camera,$cam_item,camNo) shuttertype thierry }
                        set confcolor(obtu_pierre) "1"
                        ::Obtu_Pierre::run
                     } elseif { $conf(audine,typeobtu) == $caption(confcam,obtu_i2c) } {
                        cam$confCam(camera,$cam_item,camNo) shuttertype $conf(audine,typeobtu)
                     }
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               } else {
                  set erreur [ catch { cam::create audine $conf(audine,port) -name Audine -ccd $ccd } camNo ]
               }
               if { ( $conf(audine,port) != "$caption(confcam,ethernaude)" ) && ( $conf(audine,port) != "$caption(confcam,audinet)" ) } {
                  if { $erreur == "1" } {
                     tk_messageBox -message "$camNo" -icon error
                  } else {
                     console::affiche_saut "\n"
                     console::affiche_erreur "$caption(confcam,port_audine) ($conf(audine,ccd))\
                        $caption(confcam,2points) $conf(audine,port)\n"
                     set confCam(camera,$cam_item,camNo) $camNo
                     catch { cam$confCam(camera,$cam_item,camNo) cantype $conf(audine,can) }
                     set ampli_ccd $conf(audine,ampli_ccd)
                     switch -exact -- $ampli_ccd {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) ampli "synchro"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) ampli "on"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) ampli "off"
                        }
                     }
                     set foncobtu $conf(audine,foncobtu)
                     switch -exact -- $foncobtu {
                        0 {
                           cam$confCam(camera,$cam_item,camNo) shutter "opened"
                        }
                        1 {
                           cam$confCam(camera,$cam_item,camNo) shutter "closed"
                        }
                        2 {
                           cam$confCam(camera,$cam_item,camNo) shutter "synchro"
                        }
                     }
                     if { [ string range $conf(audine,typeobtu) 0 5 ] == "audine" } {
                        if { [ string index $conf(audine,typeobtu) 7 ] == "-" } {
                           catch { cam$confCam(camera,$cam_item,camNo) shuttertype audine reverse }
                        } else {
                           catch { cam$confCam(camera,$cam_item,camNo) shuttertype audine }
                        }
                     } else {
                        catch { cam$confCam(camera,$cam_item,camNo) shuttertype thierry }
                        set confcolor(obtu_pierre) "1"
                        ::Obtu_Pierre::run
                     }
                     cam$confCam(camera,$cam_item,camNo) buf [visu$visuNo buf]
                     cam$confCam(camera,$cam_item,camNo) mirrorh $conf(audine,mirh)
                     cam$confCam(camera,$cam_item,camNo) mirrorv $conf(audine,mirv)
                     ::confVisu::visuDynamix $visuNo 32767 -32768
                  }
               }
            }
      }
      #--- Gestion du modele de camera connecte
      if { $erreur == "1" } {
         #--- En cas de probleme, je desactive le demarrage automatique
         set conf(camera,$cam_item,start)      "0"
         #--- En cas de probleme, camera par defaut
         set confCam(camera,$cam_item,camName) ""
         set confCam(camera,$cam_item,camNo)   "0"
         set confCam(camera,$cam_item,visuNo)  "0"
      } else {
         #--- Affectation de la visu
         if { $confCam(camera,$cam_item,camName) == "dslr" } {
            if { $conf(dslr,link) == "$caption(confcam,dslr_photopc)" } {
               ::confVisu::setCamera $confCam(camera,$cam_item,visuNo) $confCam(camera,$cam_item,camNo) $conf(apn,model)
            } elseif { $conf(dslr,link) == "$caption(confcam,dslr_gphoto2)" } {
               ::confVisu::setCamera $confCam(camera,$cam_item,visuNo) $confCam(camera,$cam_item,camNo)
            }
         } else {
            ::confVisu::setCamera $confCam(camera,$cam_item,visuNo) $confCam(camera,$cam_item,camNo) 
         }
      }
      
      #--- Pour compatibilite ascendante
      if { $cam_item == "A" } {
         set audace(camNo) $confCam(camera,$cam_item,camNo)
      }

      #--- Gestion des boutons actifs/inactifs
      ::confCam::ConfAudine
      ::confCam::ConfKitty
      ::confCam::ConfWebCam
      ::confCam::ConfDSLR
      if { [ winfo exists "$audace(base).conflink" ] } {
         ::ethernaude::ConfEthernAude
      }

      #--- Cas ou la video est visible dans le canvas
      #set panneau(AcqFC,$confCam(camera,A,visuNo),showvideo) "0"

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectCamera ] {
         destroy $audace(base).connectCamera
      }

      #--- Restaure les menus
      ::audace::menustate normal

      #--- Desactive le blocage pendant l'acquisition (cli/sti)
      catch {
         cam$confCam(camera,$cam_item,camNo) interrupt 0
      }
   }

   #
   # confCam::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { cam_item } {
      variable This
      global conf
      global confCam
      global caption

      set nn $This.usr.book

      set index  [expr [Rnotebook:currentIndex $nn ] - 1 ]
      set confCam(camera,$cam_item,camName) [lindex $confCam(camera,names) $index]
      set conf(camera,$cam_item,camName) [lindex $confCam(camera,names) $index]

      #--- Memorise la configuration de Audine dans le tableau conf(audine,...)
      set frm [ Rnotebook:frame $nn 1 ]
      set conf(audine,ampli_ccd)            [ lsearch "$caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours)" "$confCam(conf_audine,ampli_ccd)" ]
      set conf(audine,can)                  $confCam(conf_audine,can)
      set conf(audine,ccd)                  $confCam(conf_audine,ccd)
      set conf(audine,foncobtu)             [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_audine,foncobtu)" ]
      set conf(audine,mirh)                 $confCam(conf_audine,mirh)
      set conf(audine,mirv)                 $confCam(conf_audine,mirv)
      set conf(audine,port)                 $confCam(conf_audine,port)
      set conf(audine,typeobtu)             $confCam(conf_audine,typeobtu)
      #--- Memorise la configuration des Hi-SIS dans le tableau conf(hisis,...)
      set frm [ Rnotebook:frame $nn 2 ]
      set conf(hisis,delai_a)               $confCam(conf_hisis,delai_a)
      set conf(hisis,delai_b)               $confCam(conf_hisis,delai_b)
      set conf(hisis,delai_c)               $confCam(conf_hisis,delai_c)
      set conf(hisis,foncobtu)              [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_hisis,foncobtu)" ]
      set conf(hisis,mirh)                  $confCam(conf_hisis,mirh)
      set conf(hisis,mirv)                  $confCam(conf_hisis,mirv)
      set conf(hisis,modele)                [ lindex "11 22 23 24 33 36 39 43 44 48" $confCam(conf_hisis,modele) ]
      set conf(hisis,port)                  $confCam(conf_hisis,port)
      set conf(hisis,res)                   $confCam(conf_hisis,res)
      #--- Memorise la configuration de la SBIG dans le tableau conf(sbig,...)
      set frm [ Rnotebook:frame $nn 3 ]
      set conf(sbig,cool)                   $confCam(conf_sbig,cool)
      set conf(sbig,foncobtu)               [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_sbig,foncobtu)" ]
      set conf(sbig,host)                   $confCam(conf_sbig,host)
      set conf(sbig,mirh)                   $confCam(conf_sbig,mirh)
      set conf(sbig,mirv)                   $confCam(conf_sbig,mirv)
      set conf(sbig,port)                   $confCam(conf_sbig,port)
      set conf(sbig,temp)                   $confCam(conf_sbig,temp)
      #--- Memorise la configuration de la CB245 dans le tableau conf(cookbook,...)
      set frm [ Rnotebook:frame $nn 4 ]
      set conf(cookbook,mirh)               $confCam(conf_cookbook,mirh)
      set conf(cookbook,mirv)               $confCam(conf_cookbook,mirv)
      set conf(cookbook,port)               $confCam(conf_cookbook,port)
      #--- Memorise la configuration des Starlight dans le tableau conf(starlight,...)
      set frm [ Rnotebook:frame $nn 5 ]
      set conf(starlight,acc)               [ lsearch "$caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur)" "$confCam(conf_starlight,acc)" ]
      set conf(starlight,mirh)              $confCam(conf_starlight,mirh)
      set conf(starlight,mirv)              $confCam(conf_starlight,mirv)
      set conf(starlight,modele)            [ lindex "MX516 MX916 HX516" $confCam(conf_starlight,modele) ]
      set conf(starlight,port)              $confCam(conf_starlight,port)
      #--- Memorise la configuration des Kitty dans le tableau conf(kitty,...)
      set frm [ Rnotebook:frame $nn 6 ]
      set conf(kitty,captemp)               [ lsearch "$caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5)" "$confCam(conf_kitty,captemp)" ]
      set conf(kitty,mirh)                  $confCam(conf_kitty,mirh)
      set conf(kitty,mirv)                  $confCam(conf_kitty,mirv)
      set conf(kitty,modele)                $confCam(conf_kitty,modele)
      set conf(kitty,port)                  $confCam(conf_kitty,port)
      set conf(kitty,res)                   $confCam(conf_kitty,res)
      set conf(kitty,on_off)                $confCam(conf_kitty,on_off)
      #--- Memorise la configuration de la WebCam dans le tableau conf(webcam,...)
      set frm [ Rnotebook:frame $nn 7 ]
      set conf(webcam,longuepose)           $confCam(conf_webcam,longuepose)
      set conf(webcam,longueposeport)       $confCam(conf_webcam,longueposeport)
      set conf(webcam,longueposelinkbit)    $confCam(conf_webcam,longueposelinkbit)
      set conf(webcam,longueposestartvalue) $confCam(conf_webcam,longueposestartvalue)
      set conf(webcam,longueposestopvalue)  $confCam(conf_webcam,longueposestopvalue)
      set conf(webcam,mirh)                 $confCam(conf_webcam,mirh)
      set conf(webcam,mirv)                 $confCam(conf_webcam,mirv)
      set conf(webcam,port)                 $confCam(conf_webcam,port)
      set conf(webcam,ccd_N_B)              $confCam(conf_webcam,ccd_N_B)
      set conf(webcam,dim_ccd_N_B)          $confCam(conf_webcam,dim_ccd_N_B)
      #--- Memorise la configuration de la TH7852A dans le tableau conf(th7852a,...)
      set frm [ Rnotebook:frame $nn 8 ]
      set conf(th7852a,coef)                $confCam(conf_th7852a,coef)
      set conf(th7852a,mirh)                $confCam(conf_th7852a,mirh)
      set conf(th7852a,mirv)                $confCam(conf_th7852a,mirv)
      set conf(th7852a,port)                $confCam(conf_th7852a,port)
      #--- Memorise la configuration de la SCR1300XTC dans le tableau conf(scr1300xtc,...)
      set frm [ Rnotebook:frame $nn 9 ]
      set conf(scr1300xtc,mirh)             $confCam(conf_scr1300xtc,mirh)
      set conf(scr1300xtc,mirv)             $confCam(conf_scr1300xtc,mirv)
      set conf(scr1300xtc,port)             $confCam(conf_scr1300xtc,port)
      #--- Memorise la configuration de l'APN (DSLR) dans le tableau conf(dslr,...) et conf(apn,...)
      set frm [ Rnotebook:frame $nn 10 ]
      set conf(dslr,link)                   $confCam(conf_dslr,link)
      set conf(dslr,longue_pose)            $confCam(conf_dslr,longue_pose)
      set conf(dslr,link_longue_pose)       $confCam(conf_dslr,link_longue_pose)
      set conf(dslr,longueposelinkbit)      $confCam(conf_dslr,longueposelinkbit)
      set conf(dslr,longueposestartvalue)   $confCam(conf_dslr,longueposestartvalue)
      set conf(dslr,longueposestopvalue)    $confCam(conf_dslr,longueposestopvalue)
      set conf(dslr,statut_service)         $confCam(conf_dslr,statut_service)
      set conf(dslr,mirh)                   $confCam(conf_dslr,mirh)
      set conf(dslr,mirv)                   $confCam(conf_dslr,mirv)
      set conf(apn,baud)                    $confCam(conf_apn,baud)
     ### set conf(apn,serial_port)             $confCam(conf_apn,serial_port)
      if { [ info exists confCam(apn,model) ] } {
         set conf(apn,model)                $confCam(apn,model)
      } else {
         catch { unset conf(apn,model) }
      }
      #--- Memorise la configuration de la Andor dans le tableau conf(andor,...)
      set frm [ Rnotebook:frame $nn 11 ]
      set conf(andor,cool)                  $confCam(conf_andor,cool)
      set conf(andor,foncobtu)              [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(conf_andor,foncobtu)" ]
      set conf(andor,config)                $confCam(conf_andor,config)
      set conf(andor,mirh)                  $confCam(conf_andor,mirh)
      set conf(andor,mirv)                  $confCam(conf_andor,mirv)
      set conf(andor,temp)                  $confCam(conf_andor,temp)
      set conf(andor,ouvert_obtu)           $confCam(conf_andor,ouvert_obtu)
      set conf(andor,ferm_obtu)             $confCam(conf_andor,ferm_obtu)
   }

   proc SbigDispTemp { } {
      variable This
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera3)
         set cam_item $confCam(cam_item)
         if { [ info exists This ] == "1" && [ catch { set tempstatus [ cam$confCam(camera,$cam_item,camNo) infotemp ] } ] == "0" } {
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
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera6)
         set cam_item $confCam(cam_item)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$confCam(camera,$cam_item,camNo) temperature ] } ] == "0" } {
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
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera11)
         set cam_item $confCam(cam_item)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$confCam(camera,$cam_item,camNo) temperature ] } ] == "0" } {
            set temp_ccd [ format "%+5.2f" $temp_ccd ]
            $frm.temp_ccd configure \
               -text "$caption(confcam,temperature_CCD) $temp_ccd $caption(confcam,deg_c)"
            set confCam(conf_andor,aftertemp) [ after 5000 ::confCam::AndorDispTemp ]
         } else {
            catch { unset confCam(conf_andor,aftertemp) }
         }
      }
   }

}

#--- Connexion au demarrage de la camera selectionnee par defaut
::confCam::init

