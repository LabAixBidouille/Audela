#
# Fichier : confcam.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'camera'
# Mise a jour $Id: confcam.tcl,v 1.97 2007-10-22 21:18:23 robertdelmas Exp $
#

namespace eval ::confCam {

   #
   # confCam::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables conf(...) et caption(...)
   # Demarre le plugin selectionne par defaut
   #
   proc init { } {
      global audace caption conf confCam

      #--- Charge le fichier caption
      source [ file join $audace(rep_caption) confcam.cap ]

      #--- initConf
      if { ! [ info exists conf(camera,A,camName) ] } { set conf(camera,A,camName) "" }
      if { ! [ info exists conf(camera,A,start) ] }   { set conf(camera,A,start)   "0" }
      if { ! [ info exists conf(camera,B,camName) ] } { set conf(camera,B,camName) "" }
      if { ! [ info exists conf(camera,B,start) ] }   { set conf(camera,B,start)   "0" }
      if { ! [ info exists conf(camera,C,camName) ] } { set conf(camera,C,camName) "" }
      if { ! [ info exists conf(camera,C,start) ] }   { set conf(camera,C,start)   "0" }
      if { ! [ info exists conf(camera,geometry) ] }  { set conf(camera,geometry)  "670x430+25+45" }

      #--- Charge les plugins des cameras
      source [ file join $audace(rep_plugin) camera audine audine.tcl ]
      source [ file join $audace(rep_plugin) camera hisis hisis.tcl ]
      source [ file join $audace(rep_plugin) camera sbig sbig.tcl ]
      source [ file join $audace(rep_plugin) camera cookbook cookbook.tcl ]
      source [ file join $audace(rep_plugin) camera starlight starlight.tcl ]
      source [ file join $audace(rep_plugin) camera kitty kitty.tcl ]
      source [ file join $audace(rep_plugin) camera webcam webcam.tcl ]
      source [ file join $audace(rep_plugin) camera th7852a th7852a.tcl ]
      source [ file join $audace(rep_plugin) camera scr1300xtc scr1300xtc.tcl ]
      source [ file join $audace(rep_plugin) camera dslr dslr.tcl ]
      source [ file join $audace(rep_plugin) camera andor andor.tcl ]
      source [ file join $audace(rep_plugin) camera fingerlakes fingerlakes.tcl ]
      source [ file join $audace(rep_plugin) camera cemes cemes.tcl ]
      source [ file join $audace(rep_plugin) camera coolpix coolpix.tcl ]

      #--- Je charge le package Thread si l'option multitread est activive dans le TCL
      if { [info exists ::tcl_platform(threaded)] } {
         if { $::tcl_platform(threaded)==1 } {
            #--- Je charge le package Thread
            #--- La version minimale 2.6.3 pour disposer de la commande thread::copycommand
            if { ! [catch {package require Thread 2.6.3}]} {
               #--- Je redirige les messages d'erreur vers la procedure ::confCam::dispThreadError
               thread::errorproc ::confCam::dispThreadError
            } else {
               set ::tcl_platform(threaded) 0
            }
         }
      } else {
         set ::tcl_platform(threaded) 0
      }

      #--- Initalise le numero de camera a nul
      set audace(camNo) "0"

      #--- Initalise les listes de cameras
      set confCam(labels) [ list Audine Hi-SIS SBIG CB245 Starlight Kitty WebCam \
         TH7852A SCR1300XTC $caption(dslr,camera) Andor FLI Cemes $caption(coolpix,camera) ]
      set confCam(names) [ list audine hisis sbig cookbook starlight kitty webcam \
         th7852a scr1300xtc dslr andor fingerlakes cemes coolpix ]

      #--- Intialise les variables de chaque camera
      for { set i 0 } { $i < [ llength $confCam(names) ] } { incr i } {
         ::[ lindex $confCam(names) $i ]::initPlugin
      }

      #--- Item par defaut
      set confCam(currentCamItem) "A"

      #--- Initialisation des variables d'echange avec les widgets
      set confCam(geometry)     "$conf(camera,geometry)"
      set confCam(A,visuName)   "visu1"
      set confCam(B,visuName)   "$caption(confcam,nouvelle_visu)"
      set confCam(C,visuName)   "$caption(confcam,nouvelle_visu)"
      set confCam(A,camNo)      "0"
      set confCam(B,camNo)      "0"
      set confCam(C,camNo)      "0"
      set confCam(A,visuNo)     "0"
      set confCam(B,visuNo)     "0"
      set confCam(C,visuNo)     "0"
      set confCam(A,camName)    ""
      set confCam(B,camName)    ""
      set confCam(C,camName)    ""
      set confCam(A,threadNo)   "0"
      set confCam(B,threadNo)   "0"
      set confCam(C,threadNo)   "0"
      set confCam(A,product)    ""
      set confCam(B,product)    ""
      set confCam(C,product)    ""
      set confCam(list_product) ""
   }

   proc dispThreadError { thread_id errorInfo} {
      ::console::disp "thread_id=$thread_id errorInfo=$errorInfo\n"
   }

   #
   # confCam::run
   # Cree la fenetre de choix et de configuration des cameras
   # This = chemin de la fenetre
   # confCam($camItem,camName) = nom de la camera
   #
   proc run { } {
      variable This
      global audace confCam

      set This "$audace(base).confCam"
      createDialog
      set camItem $confCam(currentCamItem)
      if { $confCam($camItem,camName) != "" } {
         select $camItem $confCam($camItem,camName)
         if { [ string compare $confCam($camItem,camName) sbig ] == "0" } {
            ::sbig::SbigDispTemp
         } elseif { [ string compare $confCam($camItem,camName) kitty ] == "0" } {
            ::kitty::KittyDispTemp
         } elseif { [ string compare $confCam($camItem,camName) andor ] == "0" } {
            ::andor::AndorDispTemp
         } elseif { [ string compare $confCam($camItem,camName) fingerlakes ] == "0" } {
            ::fingerlakes::FLIDispTemp
         } elseif { [ string compare $confCam($camItem,camName) cemes ] == "0" } {
            ::cemes::CemesDispTemp
         }
      } else {
         select $camItem audine
      }
   }

   #
   # confCam::startDriver
   # Ouvre les cameras
   #
   proc startDriver { } {
      global conf confCam

      if { $conf(camera,A,start) == "1" } {
         set confCam(A,camName) $conf(camera,A,camName)
         ::confCam::configureCamera "A"
      }
      if { $conf(camera,B,start) == "1" } {
         set confCam(B,camName) $conf(camera,B,camName)
         ::confCam::configureCamera "B"
      }
      if { $conf(camera,C,start) == "1" } {
         set confCam(C,camName) $conf(camera,C,camName)
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
      set selectedPluginName [ $This.usr.onglet raise ]
      set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
      set pluginHelp [ $selectedPluginName\::getPluginHelp ]
      ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
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

      ::confCam::recupPosDim
      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -relief groove -state disabled
      destroy $This
   }

   #
   # confCam::recupPosDim
   # Permet de recuperer et de sauvegarder la position de la fenetre de configuration de la camera
   #
   proc recupPosDim { } {
      variable This
      global conf confCam

      set confCam(geometry) [ wm geometry $This ]
      set conf(camera,geometry) $confCam(geometry)
   }

   proc createDialog { } {
      variable This
      global audace caption conf confCam

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         select $confCam(currentCamItem) $confCam($confCam(currentCamItem),camName)
         focus $This
         return
      }
      #---
      toplevel $This
      wm geometry $This $confCam(geometry)
      wm minsize $This 670 430
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(confcam,config)"
      wm protocol $This WM_DELETE_WINDOW ::confCam::fermer

      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set notebook [ NoteBook $This.usr.onglet ]
         for { set i 0 } { $i < [ llength $confCam(names) ] } { incr i } {
            set pluginInfo(os) [ ::[ lindex $confCam(names) $i ]::getPluginOS ]
            foreach os $pluginInfo(os) {
               if { $os == [ lindex $::tcl_platform(os) 0 ] } {
                  fillPage[ lindex $confCam(names) $i ] [$notebook insert end [ lindex $confCam(names) $i ] \
                     -text [ lindex $confCam(labels) $i ] ]
               }
            }
         }
         pack $notebook -fill both -expand 1
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
   #--- Cree une thread dediee a la camera
   #--- Retourne le numero de la thread placee dans la variable confCam(camItem,threadNo)
   #
   proc createThread { camNo bufNo visuNo } {
      global confCam

      #--- Je cree la thread de la camera, si l'option multithread est activee dans le TCL
      if { $::tcl_platform(threaded)==1 } {
         #--- creation dun nouvelle thread
         set threadNo [thread::create ]
         #--- declaration de la variable globale mainThreadNo dans la thread de la camera
         thread::send $threadNo "set mainThreadNo [thread::id]"
         #--- je copie la commande de la camera dans la thread de la camera
         thread::copycommand $threadNo "cam$camNo"
         #--- declaration de la variable globale camNo dans la thread de la camera
         thread::send $threadNo "set camNo $camNo"
         #--- je copie la commande du buffer dans la thread de la camera
         thread::copycommand $threadNo buf$bufNo
      } else {
         set threadNo "0"
      }
      return $threadNo
   }

   #
   # Cree un widget "label" avec une URL du site WEB
   #
   proc createUrlLabel { tkparent title url } {
      global audace color

      label $tkparent.labURL -text "$title" -font $audace(font,url) -fg $color(blue)
      if { $url != "" } {
         bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
      }
      bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
      bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
      return  $tkparent.labURL
   }

   #
   # Fenetre de configuration de Audine
   #
   proc fillPageaudine { frm } {
      #--- Construction de l'interface graphique
      ::audine::fillConfigPage $frm
   }

   #
   # Fenetre de configuration des Hi-SIS
   #
   proc fillPagehisis { frm } {
      #--- Construction de l'interface graphique
      ::hisis::fillConfigPage $frm
   }

   #
   # Fenetre de configuration des SBIG
   #
   proc fillPagesbig { frm } {
      #--- Construction de l'interface graphique
      ::sbig::fillConfigPage $frm
   }

   #
   # Fenetre de configuration de la CB245
   #
   proc fillPagecookbook { frm } {
      #--- Construction de l'interface graphique
      ::cookbook::fillConfigPage $frm
   }

   #
   # Fenetre de configuration des Starlight
   #
   proc fillPagestarlight { frm } {
      #--- Construction de l'interface graphique
      ::starlight::fillConfigPage $frm
   }

   #
   # Fenetre de configuration des Kitty
   #
   proc fillPagekitty { frm } {
      #--- Construction de l'interface graphique
      ::kitty::fillConfigPage $frm
   }

   #
   # Fenetre de configuration des WebCam
   #
   proc fillPagewebcam { frm } {
      global confCam

      #--- Construction de l'interface graphique
      ::webcam::fillConfigPage $frm $confCam(currentCamItem)
   }

   #
   # Fenetre de configuration de la TH7852A d'Yves LATIL
   #
   proc fillPageth7852a { frm } {
      #--- Construction de l'interface graphique
      ::th7852a::fillConfigPage $frm
   }

   #
   # Fenetre de configuration de la SCR1300XTC
   #
   proc fillPagescr1300xtc { frm } {
      #--- Construction de l'interface graphique
      ::scr1300xtc::fillConfigPage $frm
   }

   #
   # Fenetre de configuration des APN (DSLR)
   #
   proc fillPagedslr { frm } {
      #--- Construction de l'interface graphique
      ::dslr::fillConfigPage $frm
   }

   #
   # Fenetre de configuration de la Andor
   #
   proc fillPageandor { frm } {
      #--- Construction de l'interface graphique
      ::andor::fillConfigPage $frm
   }

   #
   # Fenetre de configuration de la FLI (Finger Lakes Instrumentation)
   #
   proc fillPagefingerlakes { frm } {
      #--- Construction de l'interface graphique
      ::fingerlakes::fillConfigPage $frm
   }

   #
   # Fenetre de configuration de la Cemes
   #
   proc fillPagecemes { frm } {
      #--- Construction de l'interface graphique
      ::cemes::fillConfigPage $frm
   }

   #
   # Fenetre de configuration de la Nikon CoolPix
   #
   proc fillPagecoolpix { frm } {
      #--- Construction de l'interface graphique
      ::coolpix::fillConfigPage $frm
   }

   #
   # confCam::connectCamera
   # Affichage d'un message d'alerte pendant la connexion de la camera au demarrage
   #
   proc connectCamera { } {
      variable This
      global audace caption color

      if [ winfo exists $audace(base).connectCamera ] {
         destroy $audace(base).connectCamera
      }

      toplevel $audace(base).connectCamera
      wm resizable $audace(base).connectCamera 0 0
      wm title $audace(base).connectCamera "$caption(confcam,attention)"
      if { [ info exists This ] } {
         if { [ winfo exists $This ] } {
            set posx_connectCamera [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
            set posy_connectCamera [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
            wm geometry $audace(base).connectCamera +[ expr $posx_connectCamera + 50 ]+[ expr $posy_connectCamera + 100 ]
            wm transient $audace(base).connectCamera $This
         }
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

      $This.usr.onglet raise $camName
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

      #--- je selectionne l'onglet correspondant a la camera de cet item
      ::confCam::select $camItem [ $This.usr.onglet raise ]
   }

   #----------------------------------------------------------------------------
   # confCam::setShutter
   # Procedure de changement de l'obturateur de la camera
   #----------------------------------------------------------------------------
   proc setShutter { camNo shutterState } {
      variable private
      global caption conf confCam

      #---
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
      set ShutterOptionList [ ::confCam::getPluginProperty $camItem shutterList ]
      set lg_ShutterOptionList [ llength $ShutterOptionList ]
      #---
      set camProduct [ cam$camNo product ]
      if { "$camProduct" != "" } {
         if { [ ::confCam::getPluginProperty $camItem hasShutter ] } {
            incr shutterState
            if { $lg_ShutterOptionList == "3" } {
               if { $shutterState == "3" } {
                  set shutterState "0"
               }
            } elseif { $lg_ShutterOptionList == "2" } {
               if { $shutterState == "3" } {
                  set shutterState "1"
               }
            }
            if { "$camProduct" == "audine" } {
               ::audine::setShutter $camNo $shutterState $ShutterOptionList
            } elseif { "$camProduct" == "hisis" } {
               ::hisis::setShutter $camNo $shutterState $ShutterOptionList
            } elseif { "$camProduct" == "sbig" } {
               ::sbig::setShutter $camNo $shutterState $ShutterOptionList
            } elseif { "$camProduct" == "andor" } {
               ::andor::setShutter $camNo $shutterState $ShutterOptionList
            } elseif { "$camProduct" == "fingerlakes" } {
               ::fingerlakes::setShutter $camNo $shutterState $ShutterOptionList
            } elseif { "$camProduct" == "cemes" } {
               ::cemes::setShutter $camNo $shutterState $ShutterOptionList
            }
         } else {
            tk_messageBox -title $caption(confcam,pb) -type ok \
               -message $caption(confcam,onlycam+obt)
            return -1
         }
      } else {
         return -1
      }
      return $shutterState
   }

   #----------------------------------------------------------------------------
   # confCam::stopItem
   # Arrete la camera camItem
   #----------------------------------------------------------------------------
   proc stopItem { camItem } {
      global audace caption conf confCam

      if { $confCam($camItem,camName) != "" } {
         set camNo $confCam($camItem,camNo)

         #--- Je supprime la thread de la camera si elle existe
         if { $confCam($camItem,threadNo)!=0 } {
            #--- Je supprime la thread
            thread::release $confCam($camItem,threadNo)
            set confCam($camItem,threadNo) "0"
         }

         #--- Je ferme les ressources specifiques de la camera
         switch -exact -- $confCam($camItem,camName) {
            audine {
               ::audine::stop $camItem
            }
            hisis {
               ::hisis::stop $camItem
            }
            sbig {
               ::sbig::stop $camItem
            }
            cookbook {
               ::cookbook::stop $camItem
            }
            starlight {
               ::starlight::stop $camItem
            }
            kitty {
               ::kitty::stop $camItem
            }
            webcam {
               ::webcam::stop $camItem
            }
            th7852a {
               ::th7852a::stop $camItem
            }
            scr1300xtc {
               ::scr1300xtc::stop $camItem
            }
            dslr {
               ::dslr::stop $camItem
            }
            andor {
               ::andor::stop $camItem
            }
            fingerlakes {
               ::fingerlakes::stop $camItem
            }
            cemes {
               ::cemes::stop $camItem
            }
            coolpix {
               ::coolpix::stop $camItem
            }
            default {
               #--- Supprime la camera
               set result [ catch { cam::delete $camNo } erreur ]
               if { $result == "1" } { console::affiche_erreur "$erreur \n" }
            }
         }
      }

      #--- Raz des parametres de l'item
      set confCam($camItem,camNo) "0"
      #--- Je desassocie la camera de la visu
      if { $confCam($camItem,visuNo) != 0 } {
         ::confVisu::setCamera $confCam($camItem,visuNo) "" 0
         set confCam($camItem,visuNo) "0"
      }
      #---
      if { $confCam($camItem,visuNo) == "1" } {
         #--- Mise a jour de la variable audace pour compatibilite
         set audace(camNo) $confCam($camItem,camNo)
      }
      set confCam($camItem,camName) ""
      set confCam($camItem,product) ""
      #--- Je mets a jour la liste des "cam$camNo product" des cameras connectees
      set confCam(list_product) [ list $confCam(A,product) $confCam(B,product) $confCam(C,product) ]
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
   # confCam::getPluginProperty
   #    Retourne la valeur d'une propriete de la camera
   #
   #  Parametres :
   #     camItem      : Instance de la camera
   #     propertyName : Propriete
   #
   proc getPluginProperty { camItem propertyName } {
      global caption conf confCam

      # binningList :      Retourne la liste des binnings disponibles
      # binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
      # binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
      # hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
      # hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
      # hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
      # hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
      # hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
      # hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
      # hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
      # longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
      # multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
      # shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)

      #--- je recherche la valeur par defaut de la propriete
      #--- si la valeur par defaut de la propriete n'existe pas , je retourne une chaine vide
      switch $propertyName {
         binningList      { set result [ list "" ] }
         binningXListScan { set result [ list "" ] }
         binningYListScan { set result [ list "" ] }
         hasBinning       { set result 0 }
         hasFormat        { set result 0 }
         hasLongExposure  { set result 0 }
         hasScan          { set result 0 }
         hasShutter       { set result 0 }
         hasVideo         { set result 0 }
         hasWindow        { set result 0 }
         longExposure     { set result 1 }
         multiCamera      { set result 0 }
         shutterList      { set result [ list "" ] }
         default          { set result "" }
      }

      #--- si aucune camera n'est selectionnee, je retourne la valeur par defaut
      if { $camItem == "" || $confCam($camItem,camName)==""} {
         return $result
      }

      #--- si une camera est selectionnee, je recherche la valeur propre a la camera
      set camNo $confCam($camItem,camNo)
      set result [ ::$confCam($camItem,camName)::getPluginProperty $camItem $propertyName ]
      return $result
   }

   #
   # confCam::getCamNo
   #    Retourne le numero de la camera
   #
   #  Parametres :
   #     camItem : intance de la camera
   #
   proc getCamNo { camItem } {
      global confCam

      #--- si aucune camera n'est selectionnee, je retourne la valeur par defaut
      if { $camItem == "" || $confCam($camItem,camName)==""} {
         set result "0"
      } else {
         set result $confCam($camItem,camNo)
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
   # confCam::getShutter
   #    Retourne l'etat de l'obturateur
   #    Si la camera n'a pas d'obturateur, retourne une chaine vide
   #  Parametres :
   #     camItem : Instance de la camera
   #
   proc getShutter { camItem  } {
      global conf confCam

      if { [info exists conf($confCam($camItem,camName),foncobtu) ] } {
         return $conf($confCam($camItem,camName),foncobtu)
      } else {
         return ""
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
   # confCam($camItem,camName) -> type de camera employe
   # conf(cam,A,...) -> proprietes de ce type de camera
   #
   proc configureCamera { camItem } {
      variable This
      global audace caption conf confCam confcolor

      #--- Initialisation de la variable erreur
      set erreur "1"

      #--- Je regarde si la camera selectionnee est a connexion multiple, sinon je sors de la procedure
      for { set i 0 } { $i < [ llength $confCam(list_product) ] } { incr i } {
         set product [ lindex $confCam(list_product) $i ]
         if { $product != ""} {
            if { [ winfo exists $audace(base).confCam ] } {
               if { [ string compare $product [ $This.usr.onglet raise ] ] == "0" } {
                  if { $product != "webcam" } {
                     set confCam($camItem,camNo)   "0"
                     set confCam($camItem,camName) ""
                     tk_messageBox -title "$caption(confcam,attention)" -type ok \
                        -message "$caption(confcam,connexion_texte3)"
                     return
                  }
               }
            }
         }
      }

      #--- Affichage d'un message d'alerte si necessaire
      ::confCam::connectCamera

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
         if { [ winfo exists $This ] } {
            $This.startA.visu configure -height [ llength $confCam(list_visu) ]
            $This.startA.visu configure -values $confCam(list_visu)
            $This.startB.visu configure -height [ llength $confCam(list_visu) ]
            $This.startB.visu configure -values $confCam(list_visu)
            $This.startC.visu configure -height [ llength $confCam(list_visu) ]
            $This.startC.visu configure -values $confCam(list_visu)
         }
      }

      #--- Je recupere le numero buffer de la visu associee a la camera
      set bufNo [::confVisu::getBufNo $visuNo]

      set catchResult [ catch {
         switch -exact -- $confCam($camItem,camName) {
            hisis {
               ::hisis::configureCamera $camItem
            }
            sbig {
               ::sbig::configureCamera $camItem
            }
            cookbook {
               ::cookbook::configureCamera $camItem
            }
            starlight {
               ::starlight::configureCamera $camItem
            }
            kitty {
               ::kitty::configureCamera $camItem
            }
            webcam {
               ::webcam::configureCamera $camItem
            }
            th7852a {
               ::th7852a::configureCamera $camItem
            }
            scr1300xtc {
               ::scr1300xtc::configureCamera $camItem
            }
            dslr {
               ::dslr::configureCamera $camItem
            }
            andor {
               ::andor::configureCamera $camItem
            }
            fingerlakes {
               ::fingerlakes::configureCamera $camItem
            }
            cemes {
               ::cemes::configureCamera $camItem
            }
            coolpix {
               ::coolpix::configureCamera $camItem
            }
            audine {
               ::audine::configureCamera $camItem
            }
         }
         #--- <= fin du switch sur les cameras

         #--- Je mets a jour la liste des "cam$camNo product" des cameras connectees
         #--- En prenant en compte le cas particulier des APN Nikon CoolPix qui n'ont pas de librairie
         if { $confCam($camItem,camName) != "coolpix" && $confCam($camItem,camName) != "" } {
            if { $confCam(A,camNo) == $confCam($camItem,camNo) } {
               set camItem "A"
               set confCam(A,product) [ cam$confCam(A,camNo) product ]
            } elseif { $confCam(B,camNo) == $confCam($camItem,camNo) } {
               set camItem "B"
               set confCam(B,product) [ cam$confCam(B,camNo) product ]
            } elseif { $confCam(C,camNo) == $confCam($camItem,camNo) } {
               set camItem "C"
               set confCam(C,product) [ cam$confCam(C,camNo) product ]
            }
         } elseif { $confCam($camItem,camName) == "coolpix" } {
            if { $confCam(A,camNo) == $confCam($camItem,camNo) } {
               set camItem "A"
               set confCam(A,product) "coolpix"
            } elseif { $confCam(B,camNo) == $confCam($camItem,camNo) } {
               set camItem "B"
               set confCam(B,product) "coolpix"
            } elseif { $confCam(C,camNo) == $confCam($camItem,camNo) } {
               set camItem "C"
               set confCam(C,product) "coolpix"
            }
         }
         set confCam(list_product) [ list $confCam(A,product) $confCam(B,product) $confCam(C,product) ]

         #--- J'associe la camera avec la visu
         ::confVisu::setCamera $confCam($camItem,visuNo) $camItem $confCam($camItem,camNo)

      } errorMessage ]
      #--- <= fin du catch

      #--- Traitement des erreurs detectees par le catch
      if { $catchResult == "1" } {
         ::console::affiche_erreur "$::errorInfo\n\n"
         tk_messageBox -message "$errorMessage. See console" -icon error
         #--- Je desactive le demarrage automatique
         set conf(camera,$camItem,start) "0"
         #--- Je supprime la thread de la camera si elle existe
         if { $confCam($camItem,threadNo)!=0 } {
            #--- Je supprime la thread
            thread::release $confCam($camItem,threadNo)
            set confCam($camItem,threadNo) "0"
         }

         #--- En cas de probleme, camera par defaut
         set confCam($camItem,camName) ""
         set confCam($camItem,camNo)   "0"
         set confCam($camItem,visuNo)  "0"
      }

      if { $confCam($camItem,visuNo) == "1" } {
         #--- Mise a jour de la variable audace pour compatibilite
         set audace(camNo) $confCam($camItem,camNo)
      }

      #--- Creation d'une variable qui se met a jour a la fin de la procedure configureCamera
      #--- Sert au Listener de surveillance de la configuration optique
      set confCam($camItem,super_camNo) $confCam($camItem,camNo)

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectCamera ] {
         destroy $audace(base).connectCamera
      }

      #--- Desactive le blocage pendant l'acquisition (cli/sti)
      catch {
         cam$confCam($camItem,camNo) interrupt 0
      }

   }

   #
   # confCam::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { camItem } {
      variable This
      global caption conf confCam

      set camName                       [ $This.usr.onglet raise ]
      set confCam($camItem,camName)     $camName
      set conf(camera,$camItem,camName) $camName

      switch $conf(camera,$camItem,camName) {
         audine {
            #--- Memorise la configuration de Audine dans le tableau conf(audine,...)
            ::audine::widgetToConf
         }
         hisis {
            #--- Memorise la configuration des Hi-SIS dans le tableau conf(hisis,...)
            ::hisis::widgetToConf
         }
         sbig {
            #--- Memorise la configuration de la SBIG dans le tableau conf(sbig,...)
            ::sbig::widgetToConf
         }
         cookbook {
            #--- Memorise la configuration de la CB245 dans le tableau conf(cookbook,...)
            ::cookbook::widgetToConf
         }
         starlight {
            #--- Memorise la configuration des Starlight dans le tableau conf(starlight,...)
            ::starlight::widgetToConf
         }
         kitty {
            #--- Memorise la configuration des Kitty dans le tableau conf(kitty,...)
            ::kitty::widgetToConf
         }
         webcam {
            #--- Memorise la configuration de la WebCam dans le tableau conf(webcam,$camItem,...)
            ::webcam::widgetToConf $camItem
         }
         th7852a {
            #--- Memorise la configuration de la TH7852A dans le tableau conf(th7852a,...)
            ::th7852a::widgetToConf
         }
         scr1300xtc {
            #--- Memorise la configuration de la SCR1300XTC dans le tableau conf(scr1300xtc,...)
            ::scr1300xtc::widgetToConf
         }
         dslr {
            #--- Memorise la configuration de l'APN (DSLR) dans le tableau conf(dslr,...)
            ::dslr::widgetToConf
         }
         andor {
            #--- Memorise la configuration de la Andor dans le tableau conf(andor,...)
            ::andor::widgetToConf
         }
         fingerlakes {
            #--- Memorise la configuration de la FLI dans le tableau conf(fingerlakes,...)
            ::fingerlakes::widgetToConf
         }
         cemes {
            #--- Memorise la configuration de la Cemes dans le tableau conf(cemes,...)
            ::cemes::widgetToConf
         }
         coolpix {
            #--- Memorise la configuration de la Cemes dans le tableau conf(coolpix,...)
            ::coolpix::widgetToConf
         }
      }
   }

}

#--- Connexion au demarrage de la camera selectionnee par defaut
::confCam::init

