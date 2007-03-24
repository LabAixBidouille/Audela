#
# Fichier : confcam.tcl
# Description : Gere des objets 'camera'
# Mise a jour $Id: confcam.tcl,v 1.64 2007-03-24 01:36:54 robertdelmas Exp $
#

namespace eval ::confCam {

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
      source [ file join $audace(rep_caption) confcam.cap ]

      #--- initConf
      if { ! [ info exists conf(camera,A,camName) ] } { set conf(camera,A,camName) "" }
      if { ! [ info exists conf(camera,A,start) ] }   { set conf(camera,A,start)   "0" }
      if { ! [ info exists conf(camera,B,camName) ] } { set conf(camera,B,camName) "" }
      if { ! [ info exists conf(camera,B,start) ] }   { set conf(camera,B,start)   "0" }
      if { ! [ info exists conf(camera,C,camName) ] } { set conf(camera,C,camName) "" }
      if { ! [ info exists conf(camera,C,start) ] }   { set conf(camera,C,start)   "0" }
      if { ! [ info exists conf(camera,position) ] }  { set conf(camera,position)  "+25+45" }

      #--- Charge les plugins des cameras
      source [ file join $audace(rep_plugin) camera webcam webcam.tcl ]
      source [ file join $audace(rep_plugin) camera cemes cemes.tcl ]

      #--- Charge les fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine obtu_pierre.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera audine testaudine.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) camera dslr dslr.tcl ]\""

      #--- Je charge le package Thread  si l'option multitread est activive dans le TCL
      if { [info exists ::tcl_platform(threaded)] } {
         if { $::tcl_platform(threaded)==1 } {
            if { ! [catch {package require Thread}]} {
               thread::errorproc ::confCam::dispThreadError
               set audace(updateMutex) [thread::mutex create]
            } else {
               set ::tcl_platform(threaded) 0
               set audace(updateMutex) ""
            }
         }
      } else {
         set ::tcl_platform(threaded) 0
         set audace(updateMutex) ""
      }

      #--- Intialise les variables de chaque camera

      #--- initConf 1
      if { ! [ info exists conf(audine,ampli_ccd) ] } { set conf(audine,ampli_ccd) "1" }
      if { ! [ info exists conf(audine,can) ] }       { set conf(audine,can)       "$caption(confcam,can_ad976a)" }
      if { ! [ info exists conf(audine,ccd) ] }       { set conf(audine,ccd)       "$caption(confcam,kaf400)" }
      if { ! [ info exists conf(audine,foncobtu) ] }  { set conf(audine,foncobtu)  "2" }
      if { ! [ info exists conf(audine,mirh) ] }      { set conf(audine,mirh)      "0" }
      if { ! [ info exists conf(audine,mirv) ] }      { set conf(audine,mirv)      "0" }
      if { ! [ info exists conf(audine,port) ] }      { set conf(audine,port)      "LPT1:" }
      if { ! [ info exists conf(audine,typeobtu) ] }  { set conf(audine,typeobtu)  "$caption(confcam,obtu_audine)" }

      #--- initConf 2
      if { ! [ info exists conf(hisis,delai_a) ] }  { set conf(hisis,delai_a)  "5" }
      if { ! [ info exists conf(hisis,delai_b) ] }  { set conf(hisis,delai_b)  "2" }
      if { ! [ info exists conf(hisis,delai_c) ] }  { set conf(hisis,delai_c)  "7" }
      if { ! [ info exists conf(hisis,foncobtu) ] } { set conf(hisis,foncobtu) "2" }
      if { ! [ info exists conf(hisis,mirh) ] }     { set conf(hisis,mirh)     "0" }
      if { ! [ info exists conf(hisis,mirv) ] }     { set conf(hisis,mirv)     "0" }
      if { ! [ info exists conf(hisis,modele) ] }   { set conf(hisis,modele)   "22" }
      if { ! [ info exists conf(hisis,port) ] }     { set conf(hisis,port)     "LPT1:" }
      if { ! [ info exists conf(hisis,res) ] }      { set conf(hisis,res)      "12 bits" }

      #--- initConf 3
      if { ! [ info exists conf(sbig,cool) ] }     { set conf(sbig,cool)     "0" }
      if { ! [ info exists conf(sbig,foncobtu) ] } { set conf(sbig,foncobtu) "2" }
      if { ! [ info exists conf(sbig,host) ] }     { set conf(sbig,host)     "192.168.0.2" }
      if { ! [ info exists conf(sbig,mirh) ] }     { set conf(sbig,mirh)     "0" }
      if { ! [ info exists conf(sbig,mirv) ] }     { set conf(sbig,mirv)     "0" }
      if { ! [ info exists conf(sbig,port) ] }     { set conf(sbig,port)     "LPT1:" }
      if { ! [ info exists conf(sbig,temp) ] }     { set conf(sbig,temp)     "0" }

      #--- initConf 4
      if { ! [ info exists conf(cookbook,mirh) ] } { set conf(cookbook,mirh) "0" }
      if { ! [ info exists conf(cookbook,mirv) ] } { set conf(cookbook,mirv) "0" }
      if { ! [ info exists conf(cookbook,port) ] } { set conf(cookbook,port) "LPT1:" }

      #--- initConf 5
      if { ! [ info exists conf(starlight,acc) ] }    { set conf(starlight,acc)    "0" }
      if { ! [ info exists conf(starlight,mirh) ] }   { set conf(starlight,mirh)   "0" }
      if { ! [ info exists conf(starlight,mirv) ] }   { set conf(starlight,mirv)   "0" }
      if { ! [ info exists conf(starlight,modele) ] } { set conf(starlight,modele) "MX516" }
      if { ! [ info exists conf(starlight,port) ] }   { set conf(starlight,port)   "LPT1:" }

      #--- initConf 6
      if { ! [ info exists conf(kitty,captemp) ] } { set conf(kitty,captemp) "0" }
      if { ! [ info exists conf(kitty,mirh) ] }    { set conf(kitty,mirh)    "0" }
      if { ! [ info exists conf(kitty,mirv) ] }    { set conf(kitty,mirv)    "0" }
      if { ! [ info exists conf(kitty,modele) ] }  { set conf(kitty,modele)  "237" }
      if { ! [ info exists conf(kitty,port) ] }    { set conf(kitty,port)    "LPT1:" }
      if { ! [ info exists conf(kitty,res) ] }     { set conf(kitty,res)     "12 bits" }
      if { ! [ info exists conf(kitty,on_off) ] }  { set conf(kitty,on_off)  "1" }

      #--- initConf 7
      ::webcam::init

      #--- initConf 8
      if { ! [ info exists conf(th7852a,coef) ] } { set conf(th7852a,coef) "1.0" }
      if { ! [ info exists conf(th7852a,mirh) ] } { set conf(th7852a,mirh) "0" }
      if { ! [ info exists conf(th7852a,mirv) ] } { set conf(th7852a,mirv) "0" }

      #--- initConf 9
      if { ! [ info exists conf(scr1300xtc,mirh) ] } { set conf(scr1300xtc,mirh) "0" }
      if { ! [ info exists conf(scr1300xtc,mirv) ] } { set conf(scr1300xtc,mirv) "0" }
      if { ! [ info exists conf(scr1300xtc,port) ] } { set conf(scr1300xtc,port) "LPT1:" }

      #--- initConf 10
      if { ! [ info exists conf(dslr,port) ] }                 { set conf(dslr,port)                 "gphoto2" }
      if { ! [ info exists conf(dslr,longuepose) ] }           { set conf(dslr,longuepose)           "0" }
      if { ! [ info exists conf(dslr,longueposeport) ] }       { set conf(dslr,longueposeport)       "LPT1:" }
      if { ! [ info exists conf(dslr,longueposelinkbit) ] }    { set conf(dslr,longueposelinkbit)    "0" }
      if { ! [ info exists conf(dslr,longueposestartvalue) ] } { set conf(dslr,longueposestartvalue) "1" }
      if { ! [ info exists conf(dslr,longueposestopvalue) ] }  { set conf(dslr,longueposestopvalue)  "0" }
      if { ! [ info exists conf(dslr,statut_service) ] }       { set conf(dslr,statut_service)       "1" }
      if { ! [ info exists conf(dslr,mirh) ] }                 { set conf(dslr,mirh)                 "0" }
      if { ! [ info exists conf(dslr,mirv) ] }                 { set conf(dslr,mirv)                 "0" }
      if { ! [ info exists conf(apn,baud) ] }                  { set conf(apn,baud)                  "115200" }
     ### if { ! [ info exists conf(apn,serial_port) ] }           { set conf(apn,serial_port)           [ lindex "$audace(list_com)" 0 ] }

      #--- initConf 11
      if { ! [ info exists conf(andor,cool) ] }        { set conf(andor,cool)        "0" }
      if { ! [ info exists conf(andor,foncobtu) ] }    { set conf(andor,foncobtu)    "2" }
      if { ! [ info exists conf(andor,config) ] }      { set conf(andor,config)      [ file join $audace(rep_install) bin ] }
      if { ! [ info exists conf(andor,mirh) ] }        { set conf(andor,mirh)        "0" }
      if { ! [ info exists conf(andor,mirv) ] }        { set conf(andor,mirv)        "0" }
      if { ! [ info exists conf(andor,temp) ] }        { set conf(andor,temp)        "-50" }
      if { ! [ info exists conf(andor,ouvert_obtu) ] } { set conf(andor,ouvert_obtu) "0" }
      if { ! [ info exists conf(andor,ferm_obtu) ] }   { set conf(andor,ferm_obtu)   "30" }

      #--- initConf 12
      if { ! [ info exists conf(fingerlakes,cool) ] }     { set conf(fingerlakes,cool)     "0" }
      if { ! [ info exists conf(fingerlakes,foncobtu) ] } { set conf(fingerlakes,foncobtu) "2" }
      if { ! [ info exists conf(fingerlakes,mirh) ] }     { set conf(fingerlakes,mirh)     "0" }
      if { ! [ info exists conf(fingerlakes,mirv) ] }     { set conf(fingerlakes,mirv)     "0" }
      if { ! [ info exists conf(fingerlakes,temp) ] }     { set conf(fingerlakes,temp)     "-50" }

      #--- initConf 13
      ::cemes::init

      #--- item par defaut
      set confCam(currentCamItem)   "A"

      #--- Initialisation des variables d'echange avec les widgets
      set confCam(A,visuName) "visu1"
      set confCam(B,visuName) $caption(confcam,nouvelle_visu)
      set confCam(C,visuName) $caption(confcam,nouvelle_visu)
      set confCam(A,camNo)    "0"
      set confCam(B,camNo)    "0"
      set confCam(C,camNo)    "0"
      set confCam(A,visuNo)   "0"
      set confCam(B,visuNo)   "0"
      set confCam(C,visuNo)   "0"
      set confCam(A,camName)  ""
      set confCam(B,camName)  ""
      set confCam(C,camName)  ""
      set confCam(position)   $conf(camera,position)
      set confCam(A,threadNo)  "0"
      set confCam(B,threadNo)  "0"
      set confCam(C,threadNo)  "0"

      #--- Initalise les listes de cameras
      set confCam(labels) [ list Audine Hi-SIS SBIG CB245 Starlight Kitty WebCam \
            TH7852A SCR1300XTC $caption(confcam,dslr) Andor FLI Cemes ]
      set confCam(names) [ list audine hisis sbig cookbook starlight kitty webcam \
            th7852a scr1300xtc dslr andor fingerlakes cemes ]

   }

   proc dispThreadError { thread_id errorInfo} {
   ::console::disp "thread_id=$thread_id errorInfo=$errorInfo\n"

   }

   #
   # confCam::run
   # Cree la fenetre de choix et de configuration des cameras
   # This = chemin de la fenetre
   # confCam(A,camName) = nom de la camera
   #
   proc run { } {
      variable This
      global audace
      global confCam

      set This "$audace(base).confCam"
      createDialog
      set camItem $confCam(currentCamItem)
      if { $confCam($camItem,camName) != "" } {
         select $camItem $confCam($camItem,camName)
         if { [ string compare $confCam($camItem,camName) sbig ] == "0" } {
            ::confCam::SbigDispTemp
         } elseif { [ string compare $confCam($camItem,camName) kitty ] == "0" } {
            ::confCam::KittyDispTemp
         } elseif { [ string compare $confCam($camItem,camName) andor ] == "0" } {
            ::confCam::AndorDispTemp
         } elseif { [ string compare $confCam($camItem,camName) fingerlakes ] == "0" } {
            ::confCam::FLIDispTemp
         } elseif { [ string compare $confCam($camItem,camName) cemes ] == "0" } {
            ::cemes::CemesDispTemp
         }
      } else {
         select $camItem audine
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
         set confCam(A,camName)  $conf(camera,A,camName)
         ::confCam::configureCamera "A"
      }
      if { $conf(camera,B,start) == "1" } {
         set confCam(B,camName)  $conf(camera,B,camName)
         ::confCam::configureCamera "B"
      }
      if { $conf(camera,C,start) == "1" } {
         set confCam(C,camName)  $conf(camera,C,camName)
         ::confCam::configureCamera "C"
      }
   }

   #
   # confCam::stopDriver
   # Ferme toutes les cameras ouvertes
   #
   proc stopDriver { } {
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
      stopItem $confCam(currentCamItem)
      #--- je copie les parametres de la nouvelle camera dans conf()
      widgetToConf     $confCam(currentCamItem)
      configureCamera  $confCam(currentCamItem)
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
      set camName [lindex $confCam(names) [expr [Rnotebook:currentIndex $This.usr.book ] -1 ] ]
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
      global audace
      global caption
      global confCam
      global frmm

      set camItem $confCam(currentCamItem)

      #--- Si la fenetre Test pour la fabrication de la camera est affichee, je la ferme
      if { [ winfo exists $audace(base).testAudine ] } {
         ::testAudine::fermer
      }

      if { [ winfo exists $audace(base).confCam ] } {
         set frm $frmm(Camera1)
         if { [ ::confCam::getProduct $confCam($camItem,camNo) ] == "audine" && \
            [ ::confLink::getLinkNamespace $confCam(audine,port) ] == "parallelport" } {
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
      global audace
      global confCam
      global frmm

      set camItem $confCam(currentCamItem)

      if { [ winfo exists $audace(base).confCam ] } {
         set frm $frmm(Camera6)
         if { [ winfo exists $frm.radio_on ] } {
            if { [::confCam::getName $confCam($camItem,camNo)] == "KITTYK2" } {
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
   # confCam::ConfDSLR
   # Permet d'activer ou de desactiver le bouton de configuration des APN (DSLR)
   #
   proc ConfDSLR { } {
      global audace
      global confCam
      global frmm

      set camItem $confCam(currentCamItem)

      #--- Si la fenetre Telecharger l'image pour la fabrication de la camera est affichee, je la ferme
      if { [ winfo exists $audace(base).telecharge_image ] } {
         destroy $audace(base).telecharge_image
      }

      if { [ winfo exists $audace(base).confCam ] } {
         set frm $frmm(Camera10)
         if { [ winfo exists $frm.config_telechargement ] } {
            if { [::confCam::getProduct $confCam($camItem,camNo)] == "dslr" } {
               #--- Bouton de configuration des APN (DSLR)
               $frm.config_telechargement configure -state normal
            } else {
               #--- Bouton de configuration des APN (DSLR)
               $frm.config_telechargement configure -state disabled
            }
         }
         if { $confCam(dslr,longuepose) == "1" } {
            #--- Widgets de configuration de la longue pose actifs
            $frm.configure_longuepose configure -state normal
            $frm.moyen_longuepose configure -state normal
            $frm.longueposelinkbit configure -state normal
            $frm.longueposestartvalue configure -state normal
         } else {
            #--- Widgets de configuration de la longue pose inactifs
            $frm.configure_longuepose configure -state disabled
            $frm.moyen_longuepose configure -state disabled
            $frm.longueposelinkbit configure -state disabled
            $frm.longueposestartvalue configure -state disabled
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

      set confCam(geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $confCam(geometry) ] ]
      set fin [ string length $confCam(geometry) ]
      set confCam(position) "+[ string range $confCam(geometry) $deb $fin ]"
      #---
      set conf(camera,position) $confCam(position)
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
         select $confCam(currentCamItem) $confCam($confCam(currentCamItem),camName)
         focus $This
         return
      }
      #---
      if { [ info exists confCam(geometry) ] } {
         set deb [ expr 1 + [ string first + $confCam(geometry) ] ]
         set fin [ string length $confCam(geometry) ]
         set confCam(position) "+[ string range $confCam(geometry) $deb $fin ]"
      }
      #---
      toplevel $This
      if { $::tcl_platform(os) == "Linux" } {
         wm geometry $This 900x430$confCam(position)
         wm minsize $This 900 430
      } else {
         wm geometry $This 670x430$confCam(position)
         wm minsize $This 670 430
      }
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(confcam,config)"
      wm protocol $This WM_DELETE_WINDOW ::confCam::fermer

      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set nn $This.usr.book
         Rnotebook:create $nn -tabs "$confCam(labels)" -borderwidth 1
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
         fillPage12 $nn
         fillPage13 $nn
         pack $nn -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1

      #--- Je recupere la liste des visu
      set list_visu [list ]
      foreach visuNo [::visu::list] {
         lappend list_visu "visu$visuNo"
      }
      lappend list_visu $caption(confcam,nouvelle_visu)
      set confCam(list_visu) $list_visu

      #--- Parametres de la camera A
      frame $This.startA -borderwidth 1 -relief raised
         radiobutton $This.startA.item -anchor w -highlightthickness 0 \
            -text "A :" -value "A" -variable confCam(currentCamItem) \
            -command "::confCam::selectCamItem"
         pack $This.startA.item -side left -padx 3 -pady 3 -fill x
         label $This.startA.camNo -textvariable confCam(A,camNo)
         pack $This.startA.camNo -side left -padx 3 -pady 3 -fill x
         label $This.startA.name -textvariable confCam(A,camName)
         pack $This.startA.name -side left -padx 3 -pady 3 -fill x

         ComboBox $This.startA.visu \
            -width 8          \
            -height [ llength $confCam(list_visu) ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(A,visuName) \
            -values $confCam(list_visu)
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
            -text "B :" -value "B" -variable confCam(currentCamItem) \
            -command "::confCam::selectCamItem"
         pack $This.startB.item -side left -padx 3 -pady 3 -fill x
         label $This.startB.camNo -textvariable confCam(B,camNo)
         pack $This.startB.camNo -side left -padx 3 -pady 3 -fill x
         label $This.startB.name -textvariable confCam(B,camName)
         pack $This.startB.name -side left -padx 3 -pady 3 -fill x

         ComboBox $This.startB.visu \
            -width 8          \
            -height [ llength $confCam(list_visu) ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(B,visuName) \
            -values $confCam(list_visu)
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
            -text "C :" -value "C" -variable confCam(currentCamItem) \
            -command "::confCam::selectCamItem"
         pack $This.startC.item -side left -padx 3 -pady 3 -fill x
         label $This.startC.camNo -textvariable confCam(C,camNo)
         pack $This.startC.camNo -side left -padx 3 -pady 3 -fill x
         label $This.startC.name -textvariable confCam(C,camName)
         pack $This.startC.name -side left -padx 3 -pady 3 -fill x

         ComboBox $This.startC.visu \
            -width 8          \
            -height [ llength $confCam(list_visu) ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(C,visuName) \
            -values $confCam(list_visu)
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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # cree une thread dediee a la camera
   # retourne le numero de la thread place dans la variable confCam(camItem,threadNo)
   #
   proc createThread { camNo bufNo visuNo} {
      global confCam

      #--- Je cree la thread de la camera , si l'option multithread est activee dans le TCL
      if { $::tcl_platform(threaded)==1 } {
         #--- creation dun nouvelle thread
         set threadNo [thread::create ]
         #--- declaration de la variable globale mainThreadNo dans la thread de la camera
         thread::send $threadNo "set mainThreadNo [thread::id]"
         #--- je copie la commande de la camera dans la thread de la camera
         thread::copycommand $threadNo) "cam$camNo"
         #--- declaration de la variable globale camNo dans la thread de la camera
         thread::send $threadNo "set camNo $camNo"
         #--- je copie la commande du buffer dans la thread de la camera
         thread::copycommand $threadNo) buf$bufNo
      } else {
         set threadNo "0"
      }
      return $threadNo
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
      set confCam(audine,ampli_ccd) [ lindex "$caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours)" $conf(audine,ampli_ccd) ]
      set confCam(audine,can)       $conf(audine,can)
      set confCam(audine,ccd)       $conf(audine,ccd)
      set confCam(audine,foncobtu)  [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(audine,foncobtu) ]
      set confCam(audine,mirh)      $conf(audine,mirh)
      set confCam(audine,mirv)      $conf(audine,mirv)
      set confCam(audine,port)      $conf(audine,port)
      set confCam(audine,typeobtu)  $conf(audine,typeobtu)

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

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" "quickaudine" "ethernaude" "audinet" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(audine,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(audine,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(audine,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame10 -anchor center -side right -padx 10

      #--- Bouton de configuration des liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(audine,port) \
               { parallelport ethernaude quickaudine audinet } \
               "- $caption(confcam,acquisition) - $caption(confcam,audine)"
         }
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
         -textvariable confCam(audine,ccd) \
         -values $list_combobox
      pack $frm.ccd -in $frm.frame11 -anchor center -side right -padx 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(audine,mirh)
      pack $frm.mirx -in $frm.frame12 -anchor center -side left -padx 20

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(audine,mirv)
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
         -textvariable confCam(audine,ampli_ccd) \
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
         -textvariable confCam(audine,can) \
         -values $list_combobox
      pack $frm.can -in $frm.frame15 -anchor center -side right -padx 10

      #--- Definition du type d'obturateur
      label $frm.lab5 -text "$caption(confcam,type_obtu)"
      pack $frm.lab5 -in $frm.frame16 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,obtu_audine) $caption(confcam,obtu_audine-) \
         $caption(confcam,obtu_i2c) $caption(confcam,obtu_thierry) ]
      ComboBox $frm.typeobtu \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(audine,typeobtu) \
         -values $list_combobox
      pack $frm.typeobtu -in $frm.frame16 -anchor center -side right -padx 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab6 -text "$caption(confcam,fonc_obtu)"
      pack $frm.lab6 -in $frm.frame17 -anchor center -side left -padx 10

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      set confCam(audine,list_foncobtu) $list_combobox
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(audine,foncobtu) \
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
      set confCam(hisis,delai_a)  $conf(hisis,delai_a)
      set confCam(hisis,delai_b)  $conf(hisis,delai_b)
      set confCam(hisis,delai_c)  $conf(hisis,delai_c)
      set confCam(hisis,foncobtu) [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(hisis,foncobtu) ]
      set confCam(hisis,mirh)     $conf(hisis,mirh)
      set confCam(hisis,mirv)     $conf(hisis,mirv)
      set confCam(hisis,modele)   [ lsearch "11 22 23 24 33 36 39 43 44 48" "$conf(hisis,modele)" ]
      set confCam(hisis,port)     $conf(hisis,port)
      set confCam(hisis,res)      $conf(hisis,res)

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
         -text "$caption(confcam,hisis_11)" -value 0 -variable confCam(hisis,modele) -command {
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
         -text "$caption(confcam,hisis_22)" -value 1 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
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
               -textvariable confCam(hisis,res) \
               -values $list_combobox
            pack $frm.res -in $frm.frame12 -anchor center -side right -padx 20
            #--- Parametrage des delais
            label $frm.lab3 -text "$caption(confcam,delai_a)"
            pack $frm.lab3 -in $frm.frame13 -anchor center -side left -padx 10
            entry $frm.delai_a -textvariable confCam(hisis,delai_a) -width 3 -justify center
            pack $frm.delai_a -in $frm.frame13 -anchor center -side left
            label $frm.lab4 -text "$caption(confcam,delai_b)"
            pack $frm.lab4 -in $frm.frame14 -anchor center -side left -padx 10
            entry $frm.delai_b -textvariable confCam(hisis,delai_b) -width 3 -justify center
            pack $frm.delai_b -in $frm.frame14 -anchor center -side left
            label $frm.lab5 -text "$caption(confcam,delai_c)"
            pack $frm.lab5 -in $frm.frame15 -anchor center -side left -padx 10
            entry $frm.delai_c -textvariable confCam(hisis,delai_c) -width 3 -justify center
            pack $frm.delai_c -in $frm.frame15 -anchor center -side left
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS23
      radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_23)" -value 2 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
            pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio2 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS24
      radiobutton $frm.radio3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_24)" -value 3 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
               pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio3 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS33
      radiobutton $frm.radio4 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_33)" -value 4 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
               pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio4 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS36
      radiobutton $frm.radio5 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_36)" -value 5 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
            pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio5 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS39
      radiobutton $frm.radio6 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_39)" -value 6 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
               pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio6 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS43
      radiobutton $frm.radio7 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_43)" -value 7 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
               pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio7 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS44
      radiobutton $frm.radio8 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_44)" -value 8 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
               pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio8 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Bouton radio Hi-SIS48
      radiobutton $frm.radio9 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,hisis_48)" -value 9 -variable confCam(hisis,modele) -command {
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
                  -textvariable confCam(hisis,foncobtu) \
                  -values $list_combobox
               pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10
            }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         }
         pack $frm.radio9 -in $frm.frame2 -anchor center -side left -padx 10

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
      pack $frm.lab1 -in $frm.frame11 -anchor center -side left -padx 10

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(hisis,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(hisis,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(hisis,port) { parallelport } \
               "- $caption(confcam,acquisition) - $caption(confcam,hisis)"
         }
      pack $frm.configure -in $frm.frame11 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(hisis,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame11 -anchor center -side left -padx 20

      #--- Choix de la resolution et des delais
      if { $confCam(hisis,modele) == "1" } {
         set confCam(hisis,delai_a) $conf(hisis,delai_a)
         set confCam(hisis,delai_b) $conf(hisis,delai_b)
         set confCam(hisis,delai_c) $conf(hisis,delai_c)
         label $frm.lab2 -text "$caption(confcam,can_resolution)"
         pack $frm.lab2 -in $frm.frame12 -anchor center -side left -padx 10
         set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_14bits) ]
         ComboBox $frm.res \
            -width 7          \
            -height [ llength $list_combobox ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(hisis,res) \
            -values $list_combobox
         pack $frm.res -in $frm.frame12 -anchor center -side right -padx 20
         label $frm.lab3 -text "$caption(confcam,delai_a)"
         pack $frm.lab3 -in $frm.frame13 -anchor center -side left -padx 10
         entry $frm.delai_a -textvariable confCam(hisis,delai_a) -width 3 -justify center
         pack $frm.delai_a -in $frm.frame13 -anchor center -side left -padx 10
         label $frm.lab4 -text "$caption(confcam,delai_b)"
         pack $frm.lab4 -in $frm.frame14 -anchor center -side left -padx 10
         entry $frm.delai_b -textvariable confCam(hisis,delai_b) -width 3 -justify center
         pack $frm.delai_b -in $frm.frame14 -anchor center -side left -padx 10
         label $frm.lab5 -text "$caption(confcam,delai_c)"
         pack $frm.lab5 -in $frm.frame15 -anchor center -side left -padx 10
         entry $frm.delai_c -textvariable confCam(hisis,delai_c) -width 3 -justify center
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
         -variable confCam(hisis,mirh)
      pack $frm.mirx -in $frm.frame10 -anchor w -side top -padx 10 -pady 10
      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(hisis,mirv)
      pack $frm.miry -in $frm.frame10 -anchor w -side bottom -padx 10 -pady 10

      #--- Choix du fonctionnement de l'obturateur
      if { $confCam(hisis,modele) != "0" } {
         label $frm.lab0 -text "$caption(confcam,fonc_obtu)"
         pack $frm.lab0 -in $frm.frame8 -anchor center -side left -padx 8
         set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
            $caption(confcam,obtu_synchro) ]
         ComboBox $frm.foncobtu \
            -width 11         \
            -height [ llength $list_combobox ] \
            -relief sunken    \
            -borderwidth 1    \
            -textvariable confCam(hisis,foncobtu) \
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
      set confCam(sbig,cool)     $conf(sbig,cool)
      set confCam(sbig,foncobtu) [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(sbig,foncobtu) ]
      set confCam(sbig,host)     $conf(sbig,host)
      set confCam(sbig,mirh)     $conf(sbig,mirh)
      set confCam(sbig,mirv)     $conf(sbig,mirv)
      set confCam(sbig,port)     $conf(sbig,port)
      set confCam(sbig,temp)     $conf(sbig,temp)

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

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      if { $::tcl_platform(os) == "Linux" } {
         set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]
      } else {
         set list_combobox "[ ::confLink::getLinkLabels { "parallelport" } ] \
            $caption(confcam,usb) $caption(confcam,ethernet)"
      }

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(sbig,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(sbig,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(sbig,port) { parallelport } \
               "- $caption(confcam,acquisition) - $caption(confcam,sbig)"
         }
      pack $frm.configure -in $frm.frame1 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(sbig,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du host pour une connexion Ethernet
      if { $::tcl_platform(os) != "Linux" } {
         entry $frm.host -width 18 -textvariable confCam(sbig,host)
         pack $frm.host -in $frm.frame1 -anchor center -side right -padx 10

         label $frm.lab2 -text "$caption(confcam,host_sbig)"
         pack $frm.lab2 -in $frm.frame1 -anchor center -side right -padx 10
      }

      #--- Definition du refroidissement
      checkbutton $frm.cool -text "$caption(confcam,refroidissement)" -highlightthickness 0 \
         -variable confCam(sbig,cool)
      pack $frm.cool -in $frm.frame7 -anchor center -side left -padx 0 -pady 5

      entry $frm.temp -textvariable confCam(sbig,temp) -width 4 -justify center
      pack $frm.temp -in $frm.frame7 -anchor center -side left -padx 5 -pady 5

      label $frm.tempdeg -text "$caption(confcam,deg_c) $caption(confcam,refroidissement_1)"
      pack $frm.tempdeg -in $frm.frame7 -side left -fill x -padx 0 -pady 5

      label $frm.power -text "$caption(confcam,puissance_peltier_-)"
      pack $frm.power -in $frm.frame8 -side left -fill x -padx 20 -pady 5

      label $frm.ccdtemp -text "$caption(confcam,temp_ext)"
      pack $frm.ccdtemp -in $frm.frame9 -side left -fill x -padx 20 -pady 5

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(sbig,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(sbig,mirv)
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
         -textvariable confCam(sbig,foncobtu) \
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
      set confCam(cookbook,mirh) $conf(cookbook,mirh)
      set confCam(cookbook,mirv) $conf(cookbook,mirv)
      set confCam(cookbook,port) $conf(cookbook,port)

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

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(cookbook,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(cookbook,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(cookbook,port) { parallelport } \
               "- $caption(confcam,acquisition) - $caption(confcam,cookbook)"
         }
      pack $frm.configure -in $frm.frame5 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(cookbook,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(cookbook,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(cookbook,mirv)
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
      set confCam(starlight,acc)    [ lindex "$caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur)" $conf(starlight,acc) ]
      set confCam(starlight,mirh)   $conf(starlight,mirh)
      set confCam(starlight,mirv)   $conf(starlight,mirv)
      set confCam(starlight,modele) [ lsearch "MX516 MX916 HX516" "$conf(starlight,modele)" ]
      set confCam(starlight,port)   $conf(starlight,port)

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
         -text "$caption(confcam,starlight_mx5)" -value 0 -variable confCam(starlight,modele)
      pack $frm.radio0 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio MX916
      radiobutton $frm.radio1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,starlight_mx9)" -value 1 -variable confCam(starlight,modele)
      pack $frm.radio1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Bouton radio HX516
      radiobutton $frm.radio2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confcam,starlight_hx5)" -value 2 -variable confCam(starlight,modele)
      pack $frm.radio2 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du port
      label $frm.lab1 -text "$caption(confcam,port)"
      pack $frm.lab1 -in $frm.frame7 -anchor n -side left -padx 10 -pady 15

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(starlight,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(starlight,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(starlight,port) { parallelport } \
               "- $caption(confcam,acquisition) - $caption(confcam,starlight)"
         }
      pack $frm.configure -in $frm.frame7 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(starlight,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame7 -anchor n -side left -padx 10 -pady 15

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(starlight,mirh)
      pack $frm.mirx -in $frm.frame8 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(starlight,mirv)
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
         -textvariable confCam(starlight,acc) \
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
      set confCam(kitty,captemp) [ lindex "$caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5)" $conf(kitty,captemp) ]
      set confCam(kitty,mirh)    $conf(kitty,mirh)
      set confCam(kitty,mirv)    $conf(kitty,mirv)
      set confCam(kitty,modele)  $conf(kitty,modele)
      set confCam(kitty,port)    $conf(kitty,port)
      set confCam(kitty,res)     $conf(kitty,res)
      set confCam(kitty,on_off)  $conf(kitty,on_off)

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
         -text "$caption(confcam,kitty_237)" -value 237 -variable confCam(kitty,modele) -command {
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
                  -textvariable confCam(kitty,res) \
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
                  -textvariable confCam(kitty,captemp) \
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
         -text "$caption(confcam,kitty_255)" -value 255 -variable confCam(kitty,modele) -state normal -command {
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
                  -textvariable confCam(kitty,res) \
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
                  -textvariable confCam(kitty,captemp) \
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
         -text "$caption(confcam,kitty_2)" -value K2 -variable confCam(kitty,modele) -command {
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
               -variable confCam(kitty,on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler on }
            pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
            #--- Refroidissement Off
            radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
               -text "$caption(confcam,refroidissement_off)" -value 0 \
               -variable confCam(kitty,on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler off }
            pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
            #--- Definition de la temperature du capteur CCD
            label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
            pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
            #--- Bouton de test du microcontrolleur de la carte d'interface
            button $frm.test -text "$caption(confcam,test)" -relief raised \
               -command { cam$confCam($confCam(currentCamItem),camNo) sx28test }
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

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(kitty,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(kitty,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(kitty,port) { parallelport } \
               "- $caption(confcam,acquisition) - $caption(confcam,kitty)"
         }
      pack $frm.configure -in $frm.frame9 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(kitty,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame9 -anchor center -side right -padx 10

      #--- Definition de la resolution
      if { $confCam(kitty,modele) != "K2" } {
         label $frm.lab2 -text "$caption(confcam,can_resolution)"
         pack $frm.lab2 -in $frm.frame10 -anchor center -side left -padx 10

         set list_combobox [ list $caption(confcam,can_12bits) $caption(confcam,can_8bits) ]
         ComboBox $frm.res \
            -width 7          \
            -height [ llength $list_combobox ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(kitty,res) \
            -values $list_combobox
         pack $frm.res -in $frm.frame10 -anchor center -side right -padx 10
      }

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(kitty,mirh)
      pack $frm.mirx -in $frm.frame11 -anchor w -side left -padx 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(kitty,mirv)
      pack $frm.miry -in $frm.frame12 -anchor w -side left -padx 10

      #--- Definition du capteur de temperature
      if { $confCam(kitty,modele) != "K2" } {
         label $frm.lab3 -text "$caption(confcam,capteur_temp)"
         pack $frm.lab3 -in $frm.frame3 -anchor n -side left -padx 10 -pady 10

         set list_combobox [ list $caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5) ]
         ComboBox $frm.captemp \
            -width 12         \
            -height [ llength $list_combobox ] \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable confCam(kitty,captemp) \
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
            -variable confCam(kitty,on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler on }
         pack $frm.radio_on -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Refroidissement Off
         radiobutton $frm.radio_off -anchor w -highlightthickness 0 \
            -text "$caption(confcam,refroidissement_off)" -value 0 \
            -variable confCam(kitty,on_off) -command { cam$confCam($confCam(currentCamItem),camNo) cooler off }
         pack $frm.radio_off -in $frm.frame10 -side left -padx 5 -pady 5 -ipady 0
         #--- Definition de la temperature du capteur CCD
         label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
         pack $frm.temp_ccd -in $frm.frame13 -side left -fill x -padx 10 -pady 0
         #--- Bouton de test du microcontrolleur de la carte d'interface
         button $frm.test -text "$caption(confcam,test)" -relief raised \
            -command { cam$confCam($confCam(currentCamItem),camNo) sx28test }
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
      global confCam frmm

      #--- Initialisation
      set frmm(Camera7) [ Rnotebook:frame $nn 7 ]
      set frm $frmm(Camera7)

      #--- Construction de l'interface graphique
      ::webcam::fillConfigPage $frm $confCam(currentCamItem)
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
      set confCam(th7852a,coef) $conf(th7852a,coef)
      set confCam(th7852a,mirh) $conf(th7852a,mirh)
      set confCam(th7852a,mirv) $conf(th7852a,mirv)

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

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(th7852a,mirh)
      pack $frm.mirx -in $frm.frame7 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(th7852a,mirv)
      pack $frm.miry -in $frm.frame7 -anchor w -side top -padx 10 -pady 10

      #--- Definition du coefficient
      label $frm.lab2 -text "$caption(confcam,th7852a_coef)"
      pack $frm.lab2 -in $frm.frame5 -anchor n -side left -padx 10 -pady 12

      entry $frm.coef -textvariable confCam(th7852a,coef) -width 5 -justify center
      pack $frm.coef -in $frm.frame5 -anchor n -side left -padx 10 -pady 12

      #--- Site web officiel de la TH7852A d'Yves LATIL
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_th7852a)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
     ### bind $frm.labURL <ButtonPress-1> {
     ###    set filename "$caption(confcam,site_th7852a)"
     ###    ::audace::Lance_Site_htm $filename
     ### }
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
      set confCam(scr1300xtc,mirh) $conf(scr1300xtc,mirh)
      set confCam(scr1300xtc,mirv) $conf(scr1300xtc,mirv)
      set confCam(scr1300xtc,port) $conf(scr1300xtc,port)

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

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(scr1300xtc,port)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(scr1300xtc,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confLink::run ::confCam(scr1300xtc,port) { parallelport } \
               "- $caption(confcam,acquisition) - $caption(confcam,scr1300xtc)"
         }
      pack $frm.configure -in $frm.frame5 -anchor center -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(scr1300xtc,port) \
         -values $list_combobox
      pack $frm.port -in $frm.frame5 -anchor center -side left -padx 10 -pady 10

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(scr1300xtc,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(scr1300xtc,mirv)
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
      set confCam(dslr,port)                 $conf(dslr,port)
      set confCam(dslr,longuepose)           $conf(dslr,longuepose)
      set confCam(dslr,longueposeport)       $conf(dslr,longueposeport)
      set confCam(dslr,longueposelinkbit)    $conf(dslr,longueposelinkbit)
      set confCam(dslr,longueposestartvalue) $conf(dslr,longueposestartvalue)
      set confCam(dslr,longueposestopvalue)  $conf(dslr,longueposestopvalue)
      set confCam(dslr,statut_service)       $conf(dslr,statut_service)
      set confCam(dslr,mirh)                 $conf(dslr,mirh)
      set confCam(dslr,mirv)                 $conf(dslr,mirv)
      set confCam(apn,baud)                  $conf(apn,baud)
     ### set confCam(apn,serial_port)           $conf(apn,serial_port)

      #--- Initialisation
      set frmm(Camera10) [ Rnotebook:frame $nn 10 ]
      set frm $frmm(Camera10)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side top -fill x

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame4 -anchor n -side top -fill x

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame4 -anchor n -side left -fill x

      frame $frm.frame7 -borderwidth 1 -relief solid
      pack $frm.frame7 -in $frm.frame1 -anchor n -side right -fill x

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame7 -anchor n -side top -fill x

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame7 -anchor n -side top -fill x

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame7 -anchor n -side top -fill x

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame4 -anchor n -side bottom -fill both -expand true

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -side bottom -fill x -pady 2

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -side bottom -fill x -pady 2

      #--- Label de la liaison
      label $frm.lab1 -text "$caption(confcam,dslr_liaison)"
      pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10

      #--- Je constitue la liste des liaisons pour l'acquisition des images
      set list_combobox [ ::confLink::getLinkLabels { "gphoto2" "photopc" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- Si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(dslr,port)] == -1 } {
            #--- Si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(dslr,port) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des liaisons
      button $frm.configure -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confCam::configureApnLink
            ::confCam::ConfDSLR
            ::confLink::run ::confCam(dslr,port) { gphoto2 photopc } \
               "- $caption(confcam,acquisition) - $caption(confcam,dslr)"
         }
      pack $frm.configure -in $frm.frame1 -side left -pady 10 -ipadx 10 -ipady 1

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(dslr,port) \
         -values $list_combobox \
         -modifycmd {
            ::confCam::configureApnLink
            ::confCam::ConfDSLR
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
     ###    -textvariable confCam(apn,serial_port) \
     ###    -editable 0       \
     ###    -values $audace(list_com)
     ### pack $frm.s_port -in $frm.frame2 -anchor e -side left -padx 5 -pady 10

      #--- Definition de la vitesse du port serie
      label $frm.lab3 -text $caption(confcam,apn_baud)
      pack $frm.lab3 -in $frm.frame3 -anchor e -side left -padx 10 -pady 10

      set list_combobox [ list 115200 57600 38400 19200 9600 ]
      ComboBox $frm.liste1 \
         -width 14         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(apn,baud) \
         -editable 0       \
         -values $list_combobox
      pack $frm.liste1 -in $frm.frame3 -anchor e -side left -padx 5 -pady 10

      #--- Je constitue la liste des liaisons pour la longuepose
      set list_combobox [ ::confLink::getLinkLabels { "parallelport" "quickremote" "external" } ]

      #--- Je verifie le contenu de la liste
      if { [llength $list_combobox ] > 0 } {
         #--- si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $list_combobox $confCam(dslr,longueposeport)] == -1 } {
            #--- si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set confCam(dslr,longueposeport) [lindex $list_combobox 0]
         }
      } else {
         #--- si la liste est vide
         #--- je desactive l'option longue pose
         set confCam(dslr,longueposeport) ""
         set confCam(dslr,longuepose) 0
         #--- j'empeche de selectionner l'option longue
         $frm.longuepose configure -state disable
      }

      #--- Utilisation de la longue pose
      checkbutton $frm.longuepose -text "$caption(confcam,dslr_longuepose)" -highlightthickness 0 \
         -variable confCam(dslr,longuepose) -command { ::confCam::ConfDSLR }
      pack $frm.longuepose -in $frm.frame8 -anchor w -side left -padx 10 -pady 10

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure_longuepose -text "$caption(confcam,configurer)" -relief raised \
         -command {
            ::confCam::configureAPNLinkLonguePose
            ::confLink::run ::confCam(dslr,longueposeport) { parallelport quickremote external } \
               "- $caption(confcam,dslr_longuepose) - $caption(confcam,dslr)"
         }
      pack $frm.configure_longuepose -in $frm.frame8 -side left -pady 10 -ipadx 10 -ipady 1

      #--- Choix du port ou de la liaison
      ComboBox $frm.moyen_longuepose \
         -width 13         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(dslr,longueposeport) \
         -values $list_combobox \
         -modifycmd {
            ::confCam::configureAPNLinkLonguePose
         }
      pack $frm.moyen_longuepose -in $frm.frame8 -anchor center -side left -padx 20

      #--- Choix du numero du bit pour la commande de la longue pose
      label $frm.lab4 -text "$caption(confcam,dslr_longueposebit)"
      pack $frm.lab4 -in $frm.frame9 -anchor center -side left -padx 3 -pady 5

      set list_combobox [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.longueposelinkbit \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confCam(dslr,longueposelinkbit) \
         -editable 0       \
         -values $list_combobox
      pack $frm.longueposelinkbit -in $frm.frame9 -anchor center -side right -padx 20 -pady 5

      #--- Choix du niveau de depart pour la commande de la longue pose
      label $frm.lab5 -text "$caption(confcam,dslr_longueposestart)"
      pack $frm.lab5 -in $frm.frame10 -anchor center -side left -padx 3 -pady 5

      entry $frm.longueposestartvalue -width 4 -textvariable confCam(dslr,longueposestartvalue) -justify center
      pack $frm.longueposestartvalue -in $frm.frame10 -anchor center -side right -padx 20 -pady 5

      #--- Gestion du Service Windows de detection automatique des APN (DSLR)
      if { $::tcl_platform(platform) == "windows" } {
         checkbutton $frm.detect_service -text "$caption(confcam,dslr_detect_service)" -highlightthickness 0 \
            -variable confCam(dslr,statut_service)
         pack $frm.detect_service -in $frm.frame5 -anchor w -side top -padx 20 -pady 10
      }

      #--- Gestion des 2 types de liaison suivant les APN (DSLR) utilises
      if { [ ::confLink::getLinkNamespace $confCam(dslr,port) ] == "photopc" } {
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
      } elseif { [ ::confLink::getLinkNamespace $confCam(dslr,port) ] == "gphoto2" } {
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
         -variable confCam(dslr,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(dslr,mirv)
      pack $frm.miry -in $frm.frame6 -anchor w -side top -padx 20 -pady 10

      #--- Bouton du choix du telechargement de l'image de l'APN
      button $frm.config_telechargement -text $caption(confcam,dslr_telecharger) -state normal \
         -command { ::dslr::setLoadParameters $confCam($confCam(currentCamItem),visuNo) }
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
      set confCam(andor,cool)        $conf(andor,cool)
      set confCam(andor,foncobtu)    [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(andor,foncobtu) ]
      set confCam(andor,config)      $conf(andor,config)
      set confCam(andor,mirh)        $conf(andor,mirh)
      set confCam(andor,mirv)        $conf(andor,mirv)
      set confCam(andor,temp)        $conf(andor,temp)
      set confCam(andor,ouvert_obtu) $conf(andor,ouvert_obtu)
      set confCam(andor,ferm_obtu)   $conf(andor,ferm_obtu)

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
            set confCam(andor,config) [ tk_chooseDirectory -title "$caption(confcam,andor_dossier)" \
            -initialdir [ file join $audace(rep_install) bin ] -parent $audace(base).confCam ]
         }
      pack $frm.explore -in $frm.frame1 -side left -padx 10 -pady 5 -ipady 5

      entry $frm.host -width 40 -textvariable confCam(andor,config)
      pack $frm.host -in $frm.frame1 -anchor center -side left -padx 10

      #--- Definition du refroidissement
      checkbutton $frm.cool -text "$caption(confcam,refroidissement)" -highlightthickness 0 \
         -variable confCam(andor,cool)
      pack $frm.cool -in $frm.frame7 -anchor center -side left -padx 0 -pady 5

      entry $frm.temp -textvariable confCam(andor,temp) -width 4 -justify center
      pack $frm.temp -in $frm.frame7 -anchor center -side left -padx 5 -pady 5

      label $frm.tempdeg -text "$caption(confcam,deg_c) $caption(confcam,refroidissement_1)"
      pack $frm.tempdeg -in $frm.frame7 -side left -fill x -padx 0 -pady 5

      #--- Definition de la temperature du capteur CCD
      label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
      pack $frm.temp_ccd -in $frm.frame8 -side left -fill x -padx 20 -pady 5

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(andor,mirh)
      pack $frm.mirx -in $frm.frame6 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(andor,mirv)
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
         -textvariable confCam(andor,foncobtu) \
         -values $list_combobox
      pack $frm.foncobtu -in $frm.frame9 -anchor center -side left -padx 10 -pady 5

      #--- Delai d'ouverture de l'obturateur
      label $frm.lab4 -text "$caption(confcam,andor_ouvert_obtu)"
      pack $frm.lab4 -in $frm.frame10 -anchor center -side left -padx 10 -pady 5

      entry $frm.ouvert_obtu -textvariable confCam(andor,ouvert_obtu) -width 4 -justify center
      pack $frm.ouvert_obtu -in $frm.frame10 -anchor center -side left -padx 5 -pady 5

      label $frm.lab5 -text "$caption(confcam,andor_ms)"
      pack $frm.lab5 -in $frm.frame10 -side left -fill x -padx 0 -pady 5

      #--- Delai de fermeture de l'obturateur
      label $frm.lab6 -text "$caption(confcam,andor_ferm_obtu)"
      pack $frm.lab6 -in $frm.frame11 -anchor center -side left -padx 10 -pady 5

      entry $frm.ferm_obtu -textvariable confCam(andor,ferm_obtu) -width 4 -justify center
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
   # Fenetre de configuration de la FLI (Finger Lakes Instrumentation)
   #
   proc fillPage12 { nn } {
      global audace
      global confCam
      global conf
      global caption
      global color
      global frmm

      #--- confToWidget
      set confCam(fingerlakes,cool)        $conf(fingerlakes,cool)
      set confCam(fingerlakes,foncobtu)    [ lindex "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" $conf(fingerlakes,foncobtu) ]
      set confCam(fingerlakes,mirh)        $conf(fingerlakes,mirh)
      set confCam(fingerlakes,mirv)        $conf(fingerlakes,mirv)
      set confCam(fingerlakes,temp)        $conf(fingerlakes,temp)

      #--- Initialisation
      set frmm(Camera12) [ Rnotebook:frame $nn 12 ]
      set frm $frmm(Camera12)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side bottom -fill x -pady 2

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -in $frm.frame1 -side bottom -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill x -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame1 -side left -fill x -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame4 -side top -fill x -padx 30

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame4 -side top -fill x -padx 30

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame3 -side top -fill x

      #--- Definition du refroidissement
      checkbutton $frm.cool -text "$caption(confcam,refroidissement)" -highlightthickness 0 \
         -variable confCam(fingerlakes,cool)
      pack $frm.cool -in $frm.frame6 -anchor center -side left -padx 0 -pady 5

      entry $frm.temp -textvariable confCam(fingerlakes,temp) -width 4 -justify center
      pack $frm.temp -in $frm.frame6 -anchor center -side left -padx 5 -pady 5

      label $frm.tempdeg -text "$caption(confcam,deg_c) $caption(confcam,refroidissement_1)"
      pack $frm.tempdeg -in $frm.frame6 -side left -fill x -padx 0 -pady 5

      #--- Definition de la temperature du capteur CCD
      label $frm.temp_ccd -text "$caption(confcam,temperature_CCD)"
      pack $frm.temp_ccd -in $frm.frame7 -side left -fill x -padx 20 -pady 5

      #--- Miroir en x et en y
      checkbutton $frm.mirx -text "$caption(confcam,miroir_x)" -highlightthickness 0 \
         -variable confCam(fingerlakes,mirh)
      pack $frm.mirx -in $frm.frame5 -anchor w -side top -padx 10 -pady 10

      checkbutton $frm.miry -text "$caption(confcam,miroir_y)" -highlightthickness 0 \
         -variable confCam(fingerlakes,mirv)
      pack $frm.miry -in $frm.frame5 -anchor w -side top -padx 10 -pady 10

      #--- Fonctionnement de l'obturateur
      label $frm.lab3 -text "$caption(confcam,fonc_obtu)"
      pack $frm.lab3 -in $frm.frame8 -anchor center -side left -padx 10 -pady 5

      set list_combobox [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) \
         $caption(confcam,obtu_synchro) ]
      ComboBox $frm.foncobtu \
         -width 11         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confCam(fingerlakes,foncobtu) \
         -values $list_combobox
      pack $frm.foncobtu -in $frm.frame8 -anchor center -side left -padx 10 -pady 5

      #--- Site web officiel de la FLI
      label $frm.lab103 -text "$caption(confcam,site_web_ref)"
      pack $frm.lab103 -in $frm.frame2 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(confcam,site_fingerlakes)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame2 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(confcam,site_fingerlakes)"
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
   }

   #
   # Fenetre de configuration de la Cemes
   #
   proc fillPage13 { nn } {
      global confCam frmm

      #--- Initialisation
      set frmm(Camera13) [ Rnotebook:frame $nn 13 ]
      set frm $frmm(Camera13)

      #--- Construction de l'interface graphique
      ::cemes::fillConfigPage $frm
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
   proc select { camItem { camName "audine" } } {
      variable This
      global frmm

      set nn $This.usr.book
      switch -exact -- $camName {
         audine      { Rnotebook:raise $nn 1 }
         hisis       { Rnotebook:raise $nn 2 }
         sbig        { Rnotebook:raise $nn 3 }
         cookbook    { Rnotebook:raise $nn 4 }
         starlight   { Rnotebook:raise $nn 5 }
         kitty       { Rnotebook:raise $nn 6 }
         webcam      {
            ::webcam::fillConfigPage $frmm(Camera7) $camItem
            Rnotebook:raise $nn 7
         }
         th7852a     { Rnotebook:raise $nn 8 }
         scr1300xtc  { Rnotebook:raise $nn 9 }
         dslr        { Rnotebook:raise $nn 10 }
         andor       { Rnotebook:raise $nn 11 }
         fingerlakes { Rnotebook:raise $nn 12 }
         cemes       {
            ::cemes::fillConfigPage $frmm(Camera13) $camItem
            Rnotebook:raise $nn 13
         }
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
      variable This
      global confCam

      #--- je recupere l'item courant
      set camItem $confCam(currentCamItem)

      #--- je recupere le nom de la camera a partir de l'onglet courant
      set index [expr [Rnotebook:currentIndex $This.usr.book ] - 1 ]

      #--- je selectionne l'onglet correspondant a la camera de cet item
      ::confCam::select $camItem [lindex $confCam(names) $index]
   }

   #----------------------------------------------------------------------------
   # confCam::stopItem
   # Arrete la camera camItem
   #----------------------------------------------------------------------------
   proc stopItem { camItem } {
      global audace
      global caption
      global conf
      global confCam

      set camNo $confCam($camItem,camNo)
      if { $camNo != 0 } {
         #--- Je desassocie la camera de la visu
         if { $confCam($camItem,visuNo) != 0 } {
            ::confVisu::setCamera $confCam($camItem,visuNo) 0
            set confCam($camItem,visuNo) "0"
         }

         #--- Je supprime la thread de la camera si elle existe
         if { $confCam($camItem,threadNo)!=0 } {
            #--- Je supprime la thread
            thread::release $confCam($camItem,threadNo)
            set confCam($camItem,threadNo)   "0"
         }

         #--- Je ferme les ressources specifiques de la camera
         switch -exact -- $confCam($camItem,camName) {
            audine {
               #--- Je ferme la liaison d'acquisition de la camera
               ::confLink::delete $conf(audine,port) "cam$camNo" "acquisition"
               #--- Si la fenetre Test pour la fabrication de la camera est affichee, je la ferme
               if { [ winfo exists $audace(base).testAudine ] } {
                  ::testAudine::fermer
               }
               ::confCam::ConfAudine
            }
            kitty {
               ::confCam::ConfKitty
            }
            webcam {
               ::webcam::stop $camNo $camItem
            }
            dslr {
               #--- Si la fenetre Telechargement d'images est affichee, je la ferme
               if { [ winfo exists $audace(base).telecharge_image ] } {
                  destroy $audace(base).telecharge_image
               }
               ::confCam::ConfDSLR
               #--- Je ferme la liaison longuepose
               if { $conf(dslr,longuepose) == 1 } {
                  ::confLink::delete $conf(dslr,longueposeport) "cam$camNo" "longuepose"
               }
               #--- Restitue si necessaire l'etat du service WIA sous Windows
               if {  $::tcl_platform(platform) == "windows" } {
                   if { [ cam$camNo systemservice ] != "$conf(dslr,statut_service)" } {
                      cam$camNo systemservice $conf(dslr,statut_service)
                   }
               }
            }
         }

         #--- Supprime la camera
         set result [ catch { cam::delete $camNo } erreur ]
         if { $result == "1" } { console::affiche_erreur "$erreur \n" }
      }


      #--- Raz des parametres de l'item
      set confCam($camItem,camNo) "0"
      if { $camItem == "A" } {
         #--- mise a jour de la variable audace pour compatibilite
         set audace(camNo) $confCam($camItem,camNo)
      }
      set confCam($camItem,camName) ""
      #--- Sert a la surveillance du Listener de la configuration optique
      set confCam($camItem,super_camNo) $confCam($camItem,camNo)
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
      global conf

      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } product]
      if { $result == 0 } {
         #---
         switch $product {
            audine  {
               switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
                  "parallelport" { set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 } }
                  "quickaudine"  { set binningList { 1x1 2x2 3x3 4x4 } }
                  "audinet"      { set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 } }
                  "ethernaude"   { set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 } }
               }
            }
            webcam  { set binningList [ ::webcam::getBinningList ] }
            dslr    { set binningList [ cam$camNo quality list ] }
            cemes   { set binningList [ ::cemes::getBinningList ] }
            default { set binningList { 1x1 2x2 3x3 4x4 5x5 6x6 } }
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
         #---
         switch $product {
            audine  {
               switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
                  "parallelport" { set binningList_Scan { 1x1 2x2 4x4 } }
                  "quickaudine"  { set binningList_Scan { } }
                  "audinet"      { set binningList_Scan { 1x1 2x2 4x4 } }
                  "ethernaude"   { set binningList_Scan { 1x1 2x2 } }
               }
            }
            webcam  { set binningList_Scan [ ::webcam::getBinningListScan ] }
            cemes   { set binningList_Scan [ ::cemes::getBinningListScan ] }
            default { set binningList_Scan { } }
         }
      } else {
         set binningList_Scan { }
      }
      return $binningList_Scan
   }

   #
   # confCam::getLongExposure
   #    Retourne 1 si le mode longue pose est active   #    Retourne 0 sinon
   #  Parametres :
   #    camNo : Numero de la camera
   #
   proc getLongExposure { camNo } {
      global confCam

      set result 1
      #--- Je recupere le nom de la camera
      if { $camNo != 0 } {
         set camProduct [cam$camNo product]
         if { [hasLongExposure $camNo] == 1 } {
            #--- Je determine camItem
            if { $confCam(A,camNo) == $camNo } {
               set camItem "A"
            } elseif { $confCam(B,camNo) == $camNo } {
               set camItem "B"
            } elseif { $confCam(C,camNo) == $camNo } {
               set camItem "C"
            } else {
               set camItem ""
            }
            #---
            if { $camItem != "" } {
               switch $camProduct {
                  webcam {
                     set result [ ::$camProduct\::getLongExposure $camItem ]
                  }
                  cemes {
                     set result [ ::$camProduct\::getLongExposure ]
                  }
                  default {
                     #--- Toutes les cameras sont en longue pose par defaut
                     set result 1
                  }
               }
            }
         }
      }
      return $result
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
   # confCam::getThreadNo
   #    Retourne le numero de la thread de la camera
   #    Si la camera n'a pas de thread associee, la valeur retournee est "0"
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc getThreadNo { camNo } {
      global confCam
      if { $confCam(A,camNo) == $camNo } {
         set camItem "A"
      } elseif { $confCam(B,camNo) == $camNo } {
         set camItem "B"
      } elseif { $confCam(C,camNo) == $camNo } {
         set camItem "C"
      }
      return $confCam($camItem,threadNo)
   }

   #
   # confCam::hasCapability
   #    Retourne "la valeur de la propriete"
   #
   #  Parametres :
   #     camNo      : Numero de la camera
   #     capability : Fonctionnalite de la camera
   #
   proc hasCapability { camNo capability } {
      #--- Je verifie si la camera est capable de fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 0 } {
         switch $camProduct {
            dslr    { return [ ::dslr::hasCapability $camNo $capability ] }
            webcam  { return [ ::webcam::hasCapability $camNo $capability ] }
            default { return 1 }
         }
      } else {
         return 0
      }
   }

   #
   # confCam::hasLongExposure
   #    Retourne "1" si la camera possede un mode longue pose
   #    Retourne "0" sinon
   #
   #  Parametres :
   #     camNo : Numero de la camera
   #
   proc hasLongExposure { camNo } {
      #--- Je verifie si la camera est capable de fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 0 } {
         switch $camProduct {
            webcam  { return [ ::webcam::hasLongExposure ] }
            cemes   { return [ ::cemes::hasLongExposure ] }
            default { return 0 }
         }
      } else {
         return 0
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
      global conf

      #--- Je verifie si la camera est capable fournir son nom de famille
      set result [ catch { cam$camNo product } camProduct ]
      #---
      if { $result == 0 } {
         switch -exact -- $camProduct {
            audine  {
               switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
                  "ethernaude"   { return 2 }
                  default        { return 0 }
               }
            }
            webcam  { return [ ::webcam::hasVideo ] }
            cemes   { return [ ::cemes::hasVideo ] }
            default { return 0 }
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
               switch -exact [ ::confLink::getLinkNamespace $conf(audine,port) ] {
                  "parallelport" { return 1 }
                  "quickaudine"  { return 0 }
                  "audinet"      { return 1 }
                  "ethernaude"   { return 1 }
               }
            }
            webcam  { return [ ::webcam::hasScan ] }
            cemes   { return [ ::cemes::hasScan ] }
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
            audine      { return 1 }
            hisis       {
                           if { $conf(hisis,modele) == "11" } {
                              return 0
                           } else {
                              return 1
                           }
                        }
            sbig        { return 1 }
            webcam      { return [ ::webcam::hasShutter ] }
            andor       { return 1 }
            fingerlakes { return 1 }
            cemes       { return [ ::cemes::hasShutter ] }
            default     { return 0 }
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
         switch $camProduct {
            audine {
               switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
                  "parallelport" {
                     #--- O + F + S
                     set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                  }
                  "quickaudine" {
                     #--- F + S
                     set ShutterOptionList [ list $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                  }
                  "audinet" {
                     #--- O + F + S
                     set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                  }
                  "ethernaude" {
                     #--- F + S
                     set ShutterOptionList [ list $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
                  }
               }
            }
            hisis {
               if { $conf(hisis,modele) == "11" } {
                  set ShutterOptionList { }
               } else {
                  #--- O + F + S - A confirmer avec le materiel
                  set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
               }
            }
            sbig {
               #--- O + F + S - A confirmer avec le materiel
               set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
            }
            webcam {
               set ShutterOptionList [ ::webcam::getShutterOption ]
            }
            andor {
               #--- O + F + S - A confirmer avec le materiel
               set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
            }
            fingerlakes {
               #--- O + F + S - A confirmer avec le materiel
               set ShutterOptionList [ list $caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro) ]
            }
            cemes {
               #--- O + F + S
               set ShutterOptionList [ ::cemes::getShutterOption ]
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
   # confCam::configureApnLink
   #    Positionne la liaison sur celle qui vient d'etre selectionnee pour la camera APN
   #
   proc configureApnLink { } {
      global confCam
      global frmm

      #--- Initialisation pour l'onglet APN
      set frm $frmm(Camera10)
      #--- Gestion des 2 types de liaison suivant les APN (DSLR) utilises
      if { [ ::confLink::getLinkNamespace $confCam(dslr,port) ] == "photopc" } {
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
      } elseif { [ ::confLink::getLinkNamespace $confCam(dslr,port) ] == "gphoto2" } {
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
   # confCam::configureAPNLinkLonguePose
   #    Positionne la liaison sur celle qui vient d'etre selectionnee pour
   #    la longue pose de la camera APN
   #
   proc configureAPNLinkLonguePose { } {
      global confCam

      #--- Je positionne startvalue par defaut en fonction du type de liaison
      if { [ ::confLink::getLinkNamespace $confCam(dslr,longueposeport) ] == "parallelport" } {
         set confCam(dslr,longueposestartvalue) "0"
         set confCam(dslr,longueposestopvalue)  "1"
      } elseif { [ ::confLink::getLinkNamespace $confCam(dslr,longueposeport) ] == "quickremote" } {
         set confCam(dslr,longueposestartvalue) "1"
         set confCam(dslr,longueposestopvalue)  "0"
      } else {
         set confCam(dslr,longueposestartvalue) "0"
         set confCam(dslr,longueposestopvalue)  "1"
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

      if { $confCam(A,camNo) == $camNo } {
         stopItem "A"
      }
      if { $confCam(B,camNo) == $camNo } {
         stopItem "B"
      }
      if { $confCam(C,camNo) == $camNo } {
         stopItem "C"
      }
   }

   #
   # confCam::configureCamera
   # Configure la camera en fonction des donnees contenues dans le tableau conf :
   # confCam(A,camName) -> type de camera employe
   # conf(cam,A,...) -> proprietes de ce type de camera
   #
   proc configureCamera { camItem } {
      variable This
      global audace
      global caption
      global conf
      global confcolor
      global confCam

      # Initialisation de la variable erreur
      set erreur "1"

      #--- Affichage d'un message d'alerte si necessaire
      ::confCam::Connect_Camera

      #--- J'enregistre le numero de la visu associee a la camera
      if { "$confCam($camItem,camName)" != "" } {
         if { $confCam($camItem,visuName) == $caption(confcam,nouvelle_visu) } {
            set visuNo [::confVisu::create]
         } else {
            #--- je recupere le numera de la visu
            scan $confCam($camItem,visuName) "visu%d" visuNo
            #--- je verifie que la visu existe
            if { [lsearch -exact [visu::list] $visuNo] == -1 } {
               #--- si la visu n'existe plus , je la recree
               set visuNo [::confVisu::create]
            }
         }
      } else {
         #--- Si c'est l'ouverture d'une camera au demarrage de Audela
         #--- J'impose la visu :
         if { $camItem == "A" } { set visuNo 1 }
         if { $camItem == "B" } { set visuNo [::confVisu::create] }
         if { $camItem == "C" } { set visuNo [::confVisu::create] }
      }
      set confCam($camItem,visuNo)   $visuNo
      set confCam($camItem,visuName) visu$visuNo

      #--- Remise a jour de la liste des visu
      set list_visu [list ]
      #--- je recherche les visu existantes
      foreach n [::visu::list] {
         lappend list_visu "visu$n"
      }
      #--- j'ajoute la visu "nouvelle"
      lappend list_visu $caption(confcam,nouvelle_visu)
      set confCam(list_visu) $list_visu

      if { [ info exists This ] } {
         $This.startA.visu configure -height [ llength $confCam(list_visu) ]
         $This.startA.visu configure -values $confCam(list_visu)
         $This.startB.visu configure -height [ llength $confCam(list_visu) ]
         $This.startB.visu configure -values $confCam(list_visu)
         $This.startC.visu configure -height [ llength $confCam(list_visu) ]
         $This.startC.visu configure -values $confCam(list_visu)
      }

      #--- Je recupere le numero buffer de la visu associee a la camera
      set bufNo [::confVisu::getBufNo $visuNo]

      set catchResult [ catch {
         switch -exact -- $confCam($camItem,camName) {
            hisis {
               if { $conf(hisis,modele) == "11" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS11 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 4096 0
               } elseif { $conf(hisis,modele) == "22" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS22-[ lindex $conf(hisis,res) 0 ] ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele) ($conf(hisis,res))\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  cam$camNo delayloops $conf(hisis,delai_a) $conf(hisis,delai_b) $conf(hisis,delai_c)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "23" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS23 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "24" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS24 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "33" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS33 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "36" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS36 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "39" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS39 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "43" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS43 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "44" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS44 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(hisis,modele) == "48" } {
                  set camNo [ cam::create hisis $conf(hisis,port) -name Hi-SIS48 ]
                  console::affiche_erreur "$caption(confcam,port_hisis) $conf(hisis,modele)\
                     $caption(confcam,2points) $conf(hisis,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  set foncobtu $conf(hisis,foncobtu)
                  switch -exact -- $foncobtu {
                     0 {
                        cam$camNo shutter "opened"
                     }
                     1 {
                        cam$camNo shutter "closed"
                     }
                     2 {
                        cam$camNo shutter "synchro"
                     }
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(hisis,mirh)
                  cam$camNo mirrorv $conf(hisis,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               }
            }
            sbig {
              ### set conf(sbig,host) [ ::audace::verifip $conf(sbig,host) ]
               set camNo [ cam::create sbig $conf(sbig,port) -ip $conf(sbig,host) ]
               set confCam($camItem,camNo) $camNo
               console::affiche_erreur "$caption(confcam,port_sbig) ([ cam$camNo name ]) \
                  $caption(confcam,2points) $conf(sbig,port)\n"
               console::affiche_saut "\n"
               set foncobtu $conf(sbig,foncobtu)
               switch -exact -- $foncobtu {
                  0 {
                     cam$camNo shutter "opened"
                  }
                  1 {
                     cam$camNo shutter "closed"
                  }
                  2 {
                     cam$camNo shutter "synchro"
                  }
               }
               if { $conf(sbig,cool) == "1" } {
                  cam$camNo cooler check $conf(sbig,temp)
               } else {
                  cam$camNo cooler off
               }
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(sbig,mirh)
               cam$camNo mirrorv $conf(sbig,mirv)
               ::confVisu::visuDynamix $visuNo 65535 0
               #---
               if { [ info exists confCam(sbig,aftertemp) ] == "0" } {
                  ::confCam::SbigDispTemp
               }
            }
            cookbook {
               set camNo [ cam::create cookbook $conf(cookbook,port) -name CB245 ]
               console::affiche_erreur "$caption(confcam,port_cookbook) $caption(confcam,2points) $conf(cookbook,port)\n"
               console::affiche_saut "\n"
               set confCam($camItem,camNo) $camNo
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(cookbook,mirh)
               cam$camNo mirrorv $conf(cookbook,mirv)
               ::confVisu::visuDynamix $visuNo 4096 -4096
            }
            starlight {
               set starlight_accelerator $conf(starlight,acc)
               if { $conf(starlight,modele) == "MX516" } {
                  set camNo [ cam::create starlight $conf(starlight,port) -name MX516 ]
                  console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                     $caption(confcam,2points) $conf(starlight,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo accelerator $starlight_accelerator
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(starlight,mirh)
                  cam$camNo mirrorv $conf(starlight,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(starlight,modele) == "MX916" } {
                  set camNo [ cam::create starlight $conf(starlight,port) -name MX916 ]
                  console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                     $caption(confcam,2points) $conf(starlight,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo accelerator $starlight_accelerator
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(starlight,mirh)
                  cam$camNo mirrorv $conf(starlight,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               } elseif { $conf(starlight,modele) == "HX516" } {
                  set camNo [ cam::create starlight $conf(starlight,port) -name HX516 ]
                  console::affiche_erreur "$caption(confcam,port_starlight) $conf(starlight,modele)\
                     $caption(confcam,2points) $conf(starlight,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo accelerator $starlight_accelerator
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(starlight,mirh)
                  cam$camNo mirrorv $conf(starlight,mirv)
                  ::confVisu::visuDynamix $visuNo 32767 -32768
               }
            }
            kitty {
               if { $conf(kitty,modele) == "237" } {
                  set camNo [ cam::create kitty $conf(kitty,port) -name KITTY237 \
                     -canbits [ lindex $conf(kitty,res) 0 ] ]
                  console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele) ($conf(kitty,res))\
                     $caption(confcam,2points) $conf(kitty,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo canbits [ lindex $conf(kitty,res) 0 ]
                  if { $conf(kitty,captemp) == "0" } {
                     cam$camNo AD7893 AN2
                  } else {
                     cam$camNo AD7893 AN5
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(kitty,mirh)
                  cam$camNo mirrorv $conf(kitty,mirv)
                  ::confVisu::visuDynamix $visuNo 4096 -4096
               } elseif { $conf(kitty,modele) == "255" } {
                  set camNo [ cam::create kitty $conf(kitty,port) -name KITTY255 \
                     -canbits [ lindex $conf(kitty,res) 0 ] ]
                  console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele) ($conf(kitty,res))\
                     $caption(confcam,2points) $conf(kitty,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo canbits [ lindex $conf(kitty,res) 0 ]
                  if { $conf(kitty,captemp) == "0" } {
                     cam$camNo AD7893 AN2
                  } else {
                     cam$camNo AD7893 AN5
                  }
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(kitty,mirh)
                  cam$camNo mirrorv $conf(kitty,mirv)
                  ::confVisu::visuDynamix $visuNo 4096 -4096
               } elseif { $conf(kitty,modele) == "K2" } {
                  set camNo [ cam::create k2 $conf(kitty,port) -name KITTYK2 ]
                  console::affiche_erreur "$caption(confcam,port_kitty) $conf(kitty,modele)\
                     $caption(confcam,2points) $conf(kitty,port)\n"
                  console::affiche_saut "\n"
                  set confCam($camItem,camNo) $camNo
                  cam$camNo buf $bufNo
                  cam$camNo mirrorh $conf(kitty,mirh)
                  cam$camNo mirrorv $conf(kitty,mirv)
                  #---
                  if { $conf(kitty,on_off) == "1" } {
                     cam$camNo cooler on
                  } else {
                     cam$camNo cooler off
                  }
                  #---
                  ::confVisu::visuDynamix $visuNo 4096 -4096
                  #---
                  if { [ info exists confCam(kitty,aftertemp) ] == "0" } {
                     ::confCam::KittyDispTemp
                  }
               }
            }
            webcam {
               ::webcam::configureCamera $camItem
            }
            th7852a {
               set camNo [ cam::create camth "unknown" -name TH7852A ]
               console::affiche_erreur "$caption(confcam,port_th7852a) $caption(confcam,2points)\
                  $caption(confcam,th7852a_ISA)\n"
               console::affiche_saut "\n"
               set confCam($camItem,camNo) $camNo
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(th7852a,mirh)
               cam$camNo mirrorv $conf(th7852a,mirv)
               cam$camNo timescale $conf(th7852a,coef)
               ::confVisu::visuDynamix $visuNo 32767 -32768
            }
            scr1300xtc {
               set camNo [ cam::create synonyme $conf(scr1300xtc,port) -name SCR1300XTC ]
               console::affiche_erreur "$caption(confcam,port_scr1300xtc) $caption(confcam,2points)\
                  $conf(scr1300xtc,port)\n"
               console::affiche_saut "\n"
               set confCam($camItem,camNo) $camNo
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(scr1300xtc,mirh)
               cam$camNo mirrorv $conf(scr1300xtc,mirv)
               ::confVisu::visuDynamix $visuNo 4096 -4096
            }
            dslr {
               switch [ ::confLink::getLinkNamespace $conf(dslr,port) ] {
                  gphoto2 {
                     #--- Je cree la camera
                     #--- Je mets audela_start_dir entre guillemets pour le cas ou le nom du repertoire contient des espaces
                     set camNo [ cam::create digicam USB -name DSLR -debug_cam $conf(dslr,debug) -gphoto2_win_dll_dir \"$::audela_start_dir\" ]
                     set confCam($camItem,camNo) $camNo
                     console::affiche_erreur "$caption(confcam,dslr_name) $caption(confcam,2points)\
                        [ cam$camNo name ]\n"
                     console::affiche_saut "\n"
                     cam$camNo buf $bufNo
                     cam$camNo mirrorh $conf(dslr,mirh)
                     cam$camNo mirrorv $conf(dslr,mirv)
                     #--- J'arrete le service WIA de Windows
                     cam$camNo systemservice 0
                     #--- je cree la thread dediee a la camera
                     set confCam($camItem,threadNo) [::confCam::createThread $camNo $bufNo $confCam($camItem,visuNo)]

                     #--- Parametrage des longues poses
                     if { $conf(dslr,longuepose) == "1" } {
                        switch [ ::confLink::getLinkNamespace $conf(dslr,longueposeport) ] {
                           parallelport {
                              #--- Je cree la liaison longue pose
                              set linkNo [ ::confLink::create $conf(dslr,longueposeport) "cam$camNo" "longuepose" "bit $conf(dslr,longueposelinkbit)" ]
                              #---
                              cam$camNo longuepose 1
                              cam$camNo longueposelinkno $linkNo
                              cam$camNo longueposelinkbit $conf(dslr,longueposelinkbit)
                              cam$camNo longueposestartvalue $conf(dslr,longueposestartvalue)
                              cam$camNo longueposestopvalue  $conf(dslr,longueposestopvalue)
                           }
                           quickremote {
                              #--- Je cree la liaison longue pose
                              set linkNo [ ::confLink::create $conf(dslr,longueposeport) "cam$camNo" "longuepose" "bit $conf(dslr,longueposelinkbit)" ]
                              #---
                              cam$camNo longuepose 1
                              cam$camNo longueposelinkno $linkNo
                              cam$camNo longueposelinkbit $conf(dslr,longueposelinkbit)
                              cam$camNo longueposestartvalue $conf(dslr,longueposestartvalue)
                              cam$camNo longueposestopvalue  $conf(dslr,longueposestopvalue)
                           }
                           external {
                              cam$camNo longuepose 2
                           }
                        }
                        #--- j'ajoute la commande de liaison longue pose dans la thread de la camera
                        if { $confCam($camItem,threadNo) != 0 &&  [cam$camNo longueposelinkno] != 0} {
                           thread::copycommand $confCam($camItem,threadNo) "link[cam$camNo longueposelinkno]"
                        }

                     } else {
                        #--- Pas de liaison longue pose
                        cam$camNo longuepose 0
                     }
                     #--- Parametrage du telechargement des images
                     cam$camNo usecf $conf(dslr,utiliser_cf)
                     switch -exact -- $conf(dslr,telecharge_mode) {
                        1  {
                           #--- Ne pas telecharger
                           cam$camNo autoload 0
                        }
                        2  {
                           #--- Telechargement immediat
                           cam$camNo autoload 1
                        }
                        3  {
                           #--- Telechargement pendant la pose suivante
                           cam$camNo autoload 0
                        }
                     }
                     #---
                     ::confVisu::visuDynamix $visuNo 4096 -4096
                  }
                  photopc {
                     set camNo ""
                     set erreur [ catch { ::AcqAPN::Off ; ::AcqAPN::Query } camNo ]
                     if { $camNo=="" } {
                        set camNo "1"
                        if { ! [ info exists camNo ] } { set camNo "1" } else { incr camNo "1" }
                        set confCam($camItem,camNo) $camNo
                     } else {
                        set erreur "1"
                     }
                  }
               }
            }
            andor {
               if {$conf(andor,config)=="cemes"} {
                  set camNo [ cam::create cemes PCI ]
               } else {
                  #--- Je mets conf(andor,config) entre guillemets pour le cas ou
                  #--- le nom du repertoire contient des espaces
                  set camNo [ cam::create andor PCI \"$conf(andor,config)\" ]
               }
               set confCam($camItem,camNo) $camNo
               console::affiche_erreur "$caption(confcam,port_andor) ([ cam$camNo name ]) \
                  $caption(confcam,2points) $conf(andor,config)\n"
               console::affiche_saut "\n"
               set foncobtu $conf(andor,foncobtu)
               switch -exact -- $foncobtu {
                  0 {
                     cam$camNo shutter "opened"
                  }
                  1 {
                     cam$camNo shutter "closed"
                  }
                  2 {
                     cam$camNo shutter "synchro"
                  }
               }
               if { $conf(andor,cool) == "1" } {
                  cam$camNo cooler on
                  cam$camNo cooler check $conf(andor,temp)
               } else {
                  cam$camNo cooler off
               }
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(andor,mirh)
               cam$camNo mirrorv $conf(andor,mirv)
               ::confVisu::visuDynamix $visuNo 65535 0
               #--- Delais d'ouverture et de fermeture de l'obturateur
               if {$conf(andor,config)!="cemes"} {
                  cam$camNo openingtime $conf(andor,ouvert_obtu)
                  cam$camNo closingtime $conf(andor,ferm_obtu)
               }
               #---
               if { [ info exists confCam(andor,aftertemp) ] == "0" } {
                  ::confCam::AndorDispTemp
               }
            }
            fingerlakes {
               set camNo [ cam::create fingerlakes USB ]
               set confCam($camItem,camNo) $camNo
               console::affiche_erreur "$caption(confcam,port_fingerlakes) ([ cam$camNo name ]) \
                  $caption(confcam,2points) USB\n"
               console::affiche_saut "\n"
               set foncobtu $conf(fingerlakes,foncobtu)
               switch -exact -- $foncobtu {
                  0 {
                     cam$camNo shutter "opened"
                  }
                  1 {
                     cam$camNo shutter "closed"
                  }
                  2 {
                     cam$camNo shutter "synchro"
                  }
               }
               if { $conf(fingerlakes,cool) == "1" } {
                  cam$camNo cooler on
                  cam$camNo cooler check $conf(fingerlakes,temp)
               } else {
                  cam$camNo cooler off
               }
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(fingerlakes,mirh)
               cam$camNo mirrorv $conf(fingerlakes,mirv)
               ::confVisu::visuDynamix $visuNo 65535 0
               #---
               if { [ info exists confCam(fingerlakes,aftertemp) ] == "0" } {
                  ::confCam::FLIDispTemp
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
               #--- je cree la camera en fonction de la liaison choisie
               #--- A MODIFER: creer d'abord la liaison, puis la camera audine
               switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
                  parallelport {
                     set camNo [cam::create audine $conf(audine,port) -name Audine -ccd $ccd ]
                     cam$camNo cantype $conf(audine,can)
                     #--- je cree la liaison utilisee par la camera pour l'acquisition
                     set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "bits 1 to 8" ]
                  }
                  quickaudine {
                     set camNo [cam::create quicka $conf(audine,port) -name Audine -ccd $ccd ]
                     #--- je cree la liaison utilisee par la camera pour l'acquisition
                     set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "" ]
                  }
                  ethernaude {
                     ### set conf(ethernaude,host) [ ::audace::verifip $conf(ethernaude,host) ]
                     set eth_canspeed "0"
                     set eth_canspeed [ expr round(($conf(ethernaude,canspeed)-7.11)/(39.51-7.11)*30.) ]
                     if { $eth_canspeed < "0" } { set eth_canspeed "0" }
                     if { $eth_canspeed > "100" } { set eth_canspeed "100" }
                     if { [ string range $conf(audine,typeobtu) 0 5 ] == "audine" } {
                        #--- L'EthernAude inverse le fonctionnement de l'obturateur par rapport au
                        #--- port parallele, on retablit donc ici le meme fonctionnement
                        if { [ string index $conf(audine,typeobtu) 7 ] == "-" } {
                           set shutterinvert "0"
                        } else {
                           set shutterinvert "1"
                        }
                     }
                     #--- Gestion du mode debug ou non de l'EthernAude
                     if { $conf(ethernaude,debug) == "0" } {
                        if { $conf(ethernaude,ipsetting) == "1" } {
                           #--- Je mets le nom du fichier entre guillemets pour le cas ou le nom du
                           #--- repertoire contient des espaces
                           set camNo [cam::create ethernaude $conf(audine,port) -ip $conf(ethernaude,host) \
                              -canspeed $eth_canspeed -name Audine -shutterinvert $shutterinvert \
                              -ipsetting \"[ file join $audace(rep_install) bin IPSetting.exe ]\" ]
                        } else {
                           set camNo [ cam::create ethernaude $conf(audine,port) -ip $conf(ethernaude,host) \
                              -canspeed $eth_canspeed -name Audine -shutterinvert $shutterinvert ]
                        }
                     } else {
                        if { $conf(ethernaude,ipsetting) == "1" } {
                           #--- Je mets le nom du fichier entre guillemets pour le cas ou le nom du
                           #--- repertoire contient des espaces
                           set camNo [cam::create ethernaude $conf(audine,port) -ip $conf(ethernaude,host) \
                              -canspeed $eth_canspeed -name Audine -shutterinvert $shutterinvert \
                              -ipsetting \"[ file join $audace(rep_install) bin IPSetting.exe ]\" -debug_eth ]
                        } else {
                           set camNo [ cam::create ethernaude $conf(audine,port) -ip $conf(ethernaude,host) \
                              -canspeed $eth_canspeed -name Audine -shutterinvert $shutterinvert -debug_eth ]
                        }
                     }
                     #--- je cree la liaison utilisee par la camera pour l'acquisition
                     set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "" ]
                  }
                  audinet {
                     set camNo [cam::create audinet $conf(audine,port) -ccd $ccd -name Audine \
                        -host $conf(audinet,host) -protocole $conf(audinet,protocole) -udptempo $conf(audinet,udptempo) \
                        -ipsetting $conf(audinet,ipsetting) -macaddress $conf(audinet,mac_address) \
                        -debug_cam $conf(audinet,debug) ]
                     #--- je cree la liaison utilisee par la camera pour l'acquisition
                     set linkNo [ ::confLink::create $conf(audine,port) "cam$camNo" "acquisition" "" ]
                  }
               }
               #--- fin switch conf(audine,port)

               #--- je parametre la camera
               set confCam($camItem,camNo) $camNo
               cam$camNo buf $bufNo
               cam$camNo mirrorh $conf(audine,mirh)
               cam$camNo mirrorv $conf(audine,mirv)

               #--- je cree la thread dediee a la camera
               set confCam($camItem,threadNo) [::confCam::createThread $camNo $bufNo $confCam($camItem,visuNo)]

               #--- je parametre le mode de fonctionnement de l'obturateur
               switch -exact -- $conf(audine,foncobtu) {
                  0 { cam$camNo shutter "opened" }
                  1 { cam$camNo shutter "closed" }
                  2 { cam$camNo shutter "synchro" }
               }

               #--- je parametre le type de l'obturateur
               #--- (sauf pour l'EthernAude qui est commande par l'option -shutterinvert)
               if { [ ::confLink::getLinkNamespace $conf(audine,port) ] != "ethernaude" } {
                  if { $conf(audine,typeobtu) == "$caption(confcam,obtu_audine-)" } {
                     cam$camNo shuttertype audine reverse
                  } elseif { $conf(audine,typeobtu) == "$caption(confcam,obtu_audine)" } {
                     cam$camNo shuttertype audine
                  } elseif { $conf(audine,typeobtu) == "$caption(confcam,obtu_i2c)" } {
                     cam$camNo shuttertype audine
                  } elseif { $conf(audine,typeobtu) == "$caption(confcam,obtu_thierry)" } {
                     set confcolor(obtu_pierre) "1"
                     ::Obtu_Pierre::run
                     cam$camNo shuttertype thierry
                  }
               }

               #--- je parametre le fonctionnement de l'ampli du CCD
               #--- (sans effet sur l'EthernAude et l'AudiNet)
               if { [ ::confLink::getLinkNamespace $conf(audine,port) ] == "parallelport" } {
                  switch -exact -- $conf(audine,ampli_ccd) {
                     0 { cam$camNo ampli "synchro" }
                     1 { cam$camNo ampli "on" }
                     2 { cam$camNo ampli "off" }
                  }
               }

               #--- je configure la visu utilisee par la camera
               ::confVisu::visuDynamix $visuNo 32767 -32768

               #--- j'affiche un message d'information
               console::affiche_erreur "$caption(confcam,camera) [ cam$camNo name ] ([ cam$camNo ccd ])\n"
               console::affiche_erreur "$caption(confcam,port_liaison)\
                  ([ ::[ ::confLink::getLinkNamespace $conf(audine,port) ]::getLabel ])\
                  $caption(confcam,2points) $conf(audine,port)\n"
               console::affiche_saut "\n"
            }
            cemes {
               ::cemes::configureCamera $camItem
            }
         }
         #--- <= fin du switch sur les cameras

         #--- J'associe la camera avec la visu
         ::confVisu::setCamera $confCam($camItem,visuNo) $confCam($camItem,camNo)

      } errorMessage ]
      #--- <= fin du catch

      #--- Traitement des erreurs detectees par le catch
      if { $catchResult == "1" } {
         ::console::affiche_erreur "$::errorInfo\n"
         tk_messageBox -message "$errorMessage. See console" -icon error
         #--- Je desactive le demarrage automatique
         set conf(camera,$camItem,start) "0"
         #--- Je supprime la thread de la camera si elle existe
         if { $confCam($camItem,threadNo)!=0 } {
            #--- Je supprime la thread
            thread::release $confCam($camItem,threadNo)
            set confCam($camItem,threadNo)  "0"
         }

         #--- En cas de probleme, camera par defaut
         set confCam($camItem,camName)   ""
         set confCam($camItem,camNo)     "0"
         set confCam($camItem,visuNo)    "0"
      }

      if { $camItem == "A" } {
         #--- Mise a jour de la variable audace pour compatibilite
         set ::audace(camNo) $confCam($camItem,camNo)
      }

      #--- Creation d'une variable qui se met a jour a la fin de la procedure configureCamera
      #--- Sert au Listener de surveillance de la configuration optique
      set confCam($camItem,super_camNo) $confCam($camItem,camNo)

      #--- Gestion des boutons actifs/inactifs
      ::confCam::ConfAudine
      ::confCam::ConfKitty
      ::webcam::ConfigWebCam $camItem
      ::confCam::ConfDSLR
      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectCamera ] {
         destroy $audace(base).connectCamera
      }

      #--- Desactive le blocage pendant l'acquisition (cli/sti)
      catch {
         cam$camNo interrupt 0
      }

   }

   #
   # confCam::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { camItem } {
      variable This
      global conf
      global confCam
      global caption

      set nn $This.usr.book

      set index                             [ expr [ Rnotebook:currentIndex $nn ] - 1 ]
      set confCam($camItem,camName)         [ lindex $confCam(names) $index ]
      set conf(camera,$camItem,camName)     [ lindex $confCam(names) $index ]

      switch $conf(camera,$camItem,camName) {
         audine {
            #--- Memorise la configuration de Audine dans le tableau conf(audine,...)
            set conf(audine,ampli_ccd)            [ lsearch "$caption(confcam,ampli_synchro) $caption(confcam,ampli_toujours)" "$confCam(audine,ampli_ccd)" ]
            set conf(audine,can)                  $confCam(audine,can)
            set conf(audine,ccd)                  $confCam(audine,ccd)
            set conf(audine,foncobtu)             [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(audine,foncobtu)" ]
            set conf(audine,mirh)                 $confCam(audine,mirh)
            set conf(audine,mirv)                 $confCam(audine,mirv)
            set conf(audine,port)                 $confCam(audine,port)
            set conf(audine,typeobtu)             $confCam(audine,typeobtu)
         }
         hisis {
            #--- Memorise la configuration des Hi-SIS dans le tableau conf(hisis,...)
            set conf(hisis,delai_a)               $confCam(hisis,delai_a)
            set conf(hisis,delai_b)               $confCam(hisis,delai_b)
            set conf(hisis,delai_c)               $confCam(hisis,delai_c)
            set conf(hisis,foncobtu)              [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(hisis,foncobtu)" ]
            set conf(hisis,mirh)                  $confCam(hisis,mirh)
            set conf(hisis,mirv)                  $confCam(hisis,mirv)
            set conf(hisis,modele)                [ lindex "11 22 23 24 33 36 39 43 44 48" $confCam(hisis,modele) ]
            set conf(hisis,port)                  $confCam(hisis,port)
            set conf(hisis,res)                   $confCam(hisis,res)
         }
         sbig {
            #--- Memorise la configuration de la SBIG dans le tableau conf(sbig,...)
            set conf(sbig,cool)                   $confCam(sbig,cool)
            set conf(sbig,foncobtu)               [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(sbig,foncobtu)" ]
            set conf(sbig,host)                   $confCam(sbig,host)
            set conf(sbig,mirh)                   $confCam(sbig,mirh)
            set conf(sbig,mirv)                   $confCam(sbig,mirv)
            set conf(sbig,port)                   $confCam(sbig,port)
            set conf(sbig,temp)                   $confCam(sbig,temp)
         }
         cookbook {
            #--- Memorise la configuration de la CB245 dans le tableau conf(cookbook,...)
            set conf(cookbook,mirh)               $confCam(cookbook,mirh)
            set conf(cookbook,mirv)               $confCam(cookbook,mirv)
            set conf(cookbook,port)               $confCam(cookbook,port)
         }
         starlight {
            #--- Memorise la configuration des Starlight dans le tableau conf(starlight,...)
            set conf(starlight,acc)               [ lsearch "$caption(confcam,sans_accelerateur) $caption(confcam,avec_accelerateur)" "$confCam(starlight,acc)" ]
            set conf(starlight,mirh)              $confCam(starlight,mirh)
            set conf(starlight,mirv)              $confCam(starlight,mirv)
            set conf(starlight,modele)            [ lindex "MX516 MX916 HX516" $confCam(starlight,modele) ]
            set conf(starlight,port)              $confCam(starlight,port)
         }
         kitty {
            #--- Memorise la configuration des Kitty dans le tableau conf(kitty,...)
            set conf(kitty,captemp)               [ lsearch "$caption(confcam,capteur_temp_ad7893an2) $caption(confcam,capteur_temp_ad7893an5)" "$confCam(kitty,captemp)" ]
            set conf(kitty,mirh)                  $confCam(kitty,mirh)
            set conf(kitty,mirv)                  $confCam(kitty,mirv)
            set conf(kitty,modele)                $confCam(kitty,modele)
            set conf(kitty,port)                  $confCam(kitty,port)
            set conf(kitty,res)                   $confCam(kitty,res)
            set conf(kitty,on_off)                $confCam(kitty,on_off)
         }
         webcam {
            #--- Memorise la configuration de la WebCam dans le tableau conf(webcam,$camItem,...)
            ::webcam::widgetToConf $camItem
         }
         th7852a {
            #--- Memorise la configuration de la TH7852A dans le tableau conf(th7852a,...)
            set conf(th7852a,coef)                $confCam(th7852a,coef)
            set conf(th7852a,mirh)                $confCam(th7852a,mirh)
            set conf(th7852a,mirv)                $confCam(th7852a,mirv)
         }
         scr1300xtc {
            #--- Memorise la configuration de la SCR1300XTC dans le tableau conf(scr1300xtc,...)
            set conf(scr1300xtc,mirh)             $confCam(scr1300xtc,mirh)
            set conf(scr1300xtc,mirv)             $confCam(scr1300xtc,mirv)
            set conf(scr1300xtc,port)             $confCam(scr1300xtc,port)
         }
         dslr {
            #--- Memorise la configuration de l'APN (DSLR) dans le tableau conf(dslr,...) et conf(apn,...)
            set conf(dslr,port)                   $confCam(dslr,port)
            set conf(dslr,longuepose)             $confCam(dslr,longuepose)
            set conf(dslr,longueposeport)         $confCam(dslr,longueposeport)
            set conf(dslr,longueposelinkbit)      $confCam(dslr,longueposelinkbit)
            set conf(dslr,longueposestartvalue)   $confCam(dslr,longueposestartvalue)
            set conf(dslr,longueposestopvalue)    $confCam(dslr,longueposestopvalue)
            set conf(dslr,statut_service)         $confCam(dslr,statut_service)
            set conf(dslr,mirh)                   $confCam(dslr,mirh)
            set conf(dslr,mirv)                   $confCam(dslr,mirv)
            set conf(apn,baud)                    $confCam(apn,baud)
           ### set conf(apn,serial_port)             $confCam(apn,serial_port)
            if { [ info exists confCam(apn,model) ] } {
               set conf(apn,model)                $confCam(apn,model)
            } else {
               catch { unset conf(apn,model) }
            }
         }
         andor {
            #--- Memorise la configuration de la Andor dans le tableau conf(andor,...)
            set conf(andor,cool)                  $confCam(andor,cool)
            set conf(andor,foncobtu)              [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(andor,foncobtu)" ]
            set conf(andor,config)                $confCam(andor,config)
            set conf(andor,mirh)                  $confCam(andor,mirh)
            set conf(andor,mirv)                  $confCam(andor,mirv)
            set conf(andor,temp)                  $confCam(andor,temp)
            set conf(andor,ouvert_obtu)           $confCam(andor,ouvert_obtu)
            set conf(andor,ferm_obtu)             $confCam(andor,ferm_obtu)
         }
         fingerlakes {
            #--- Memorise la configuration de la FLI dans le tableau conf(fingerlakes,...)
            set conf(fingerlakes,cool)            $confCam(fingerlakes,cool)
            set conf(fingerlakes,foncobtu)        [ lsearch "$caption(confcam,obtu_ouvert) $caption(confcam,obtu_ferme) $caption(confcam,obtu_synchro)" "$confCam(fingerlakes,foncobtu)" ]
            set conf(fingerlakes,mirh)            $confCam(fingerlakes,mirh)
            set conf(fingerlakes,mirv)            $confCam(fingerlakes,mirv)
            set conf(fingerlakes,temp)            $confCam(fingerlakes,temp)
         }
         cemes {
            #--- Memorise la configuration de la Cemes dans le tableau conf(cemes,...)
            ::cemes::widgetToConf
         }
      }
   }

   proc SbigDispTemp { } {
      variable This
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera3)
         set camItem $confCam(currentCamItem)
         if { [ info exists This ] == "1" && [ catch { set tempstatus [ cam$confCam($camItem,camNo) infotemp ] } ] == "0" } {
            set temp_check [ format "%+5.2f" [ lindex $tempstatus 0 ] ]
            set temp_ccd [ format "%+5.2f" [ lindex $tempstatus 1 ] ]
            set temp_ambiant [ format "%+5.2f" [ lindex $tempstatus 2 ] ]
            set regulation [ lindex $tempstatus 3 ]
            set power [ format "%3.0f" [ expr 100.*[ lindex $tempstatus 4 ]/255. ] ]
            $frm.power configure \
               -text "$caption(confcam,puissance_peltier) $power %"
            $frm.ccdtemp configure \
               -text "$caption(confcam,temp_ext) $temp_ccd $caption(confcam,deg_c) / $temp_ambiant $caption(confcam,deg_c)"
            set confCam(sbig,aftertemp) [ after 5000 ::confCam::SbigDispTemp ]
         } else {
            catch { unset confCam(sbig,aftertemp) }
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
         set camItem $confCam(currentCamItem)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
            set temp_ccd [ format "%+5.2f" $temp_ccd ]
            $frm.temp_ccd configure \
               -text "$caption(confcam,temperature_CCD) $temp_ccd $caption(confcam,deg_c)"
            set confCam(kitty,aftertemp) [ after 5000 ::confCam::KittyDispTemp ]
         } else {
            catch { unset confCam(kitty,aftertemp) }
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
         set camItem $confCam(currentCamItem)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
            set temp_ccd [ format "%+5.2f" $temp_ccd ]
            $frm.temp_ccd configure \
               -text "$caption(confcam,temperature_CCD) $temp_ccd $caption(confcam,deg_c)"
            set confCam(andor,aftertemp) [ after 5000 ::confCam::AndorDispTemp ]
         } else {
            catch { unset confCam(andor,aftertemp) }
         }
      }
   }

   proc FLIDispTemp { } {
      variable This
      global caption
      global confCam
      global frmm

      catch {
         set frm $frmm(Camera12)
         set camItem $confCam(currentCamItem)
         if { [ info exists This ] == "1" && [ catch { set temp_ccd [ cam$confCam($camItem,camNo) temperature ] } ] == "0" } {
            set temp_ccd [ format "%+5.2f" $temp_ccd ]
            $frm.temp_ccd configure \
               -text "$caption(confcam,temperature_CCD) $temp_ccd $caption(confcam,deg_c)"
            set confCam(fingerlakes,aftertemp) [ after 5000 ::confCam::FLIDispTemp ]
         } else {
            catch { unset confCam(fingerlakes,aftertemp) }
         }
      }
   }

}

#--- Connexion au demarrage de la camera selectionnee par defaut
::confCam::init

