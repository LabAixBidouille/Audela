#
# Fichier : confcam.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'camera'
# Mise a jour $Id: confcam.tcl,v 1.104 2007-12-07 22:48:43 robertdelmas Exp $
#

namespace eval ::confCam {
}

#
# confCam::init (est lance automatiquement au chargement de ce fichier tcl)
# Initialise les variables conf(...) et caption(...)
# Demarre le plugin selectionne par defaut
#
proc ::confCam::init { } {
   variable private
   global audace caption conf

   #--- Charge le fichier caption
   source [ file join "$audace(rep_caption)" confcam.cap ]

   #--- initConf
   if { ! [ info exists conf(camera,A,camName) ] } { set conf(camera,A,camName) "" }
   if { ! [ info exists conf(camera,A,start) ] }   { set conf(camera,A,start)   "0" }
   if { ! [ info exists conf(camera,B,camName) ] } { set conf(camera,B,camName) "" }
   if { ! [ info exists conf(camera,B,start) ] }   { set conf(camera,B,start)   "0" }
   if { ! [ info exists conf(camera,C,camName) ] } { set conf(camera,C,camName) "" }
   if { ! [ info exists conf(camera,C,start) ] }   { set conf(camera,C,start)   "0" }
   if { ! [ info exists conf(camera,geometry) ] }  { set conf(camera,geometry)  "670x430+25+45" }

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

   #--- Item par defaut
   set private(currentCamItem) "A"

   #--- Initialisation des variables d'echange avec les widgets
   set private(geometry)     "$conf(camera,geometry)"
   set private(A,visuName)   "visu1"
   set private(B,visuName)   "$caption(confcam,nouvelle_visu)"
   set private(C,visuName)   "$caption(confcam,nouvelle_visu)"
   set private(A,camNo)      "0"
   set private(B,camNo)      "0"
   set private(C,camNo)      "0"
   set private(A,visuNo)     "0"
   set private(B,visuNo)     "0"
   set private(C,visuNo)     "0"
   set private(A,camName)    ""
   set private(B,camName)    ""
   set private(C,camName)    ""
   set private(A,threadNo)   "0"
   set private(B,threadNo)   "0"
   set private(C,threadNo)   "0"

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confCam"

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" camera]
   #--- je recherche les plugin presents
   findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(camera,A,camName)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(camera,A,camName) ""
   }
   if { [lsearch $private(pluginNamespaceList) $conf(camera,B,camName)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(camera,B,camName) ""
   }
   if { [lsearch $private(pluginNamespaceList) $conf(camera,C,camName)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(camera,C,camName) ""
   }
}

proc ::confCam::dispThreadError { thread_id ErrorInfo } {
   ::console::disp "thread_id=$thread_id errorInfo=$errorInfo\n"
}

#
# confCam::run
# Cree la fenetre de choix et de configuration des cameras
# private(frm) = chemin de la fenetre
# private($camItem,camName) = nom de la camera
#
proc ::confCam::run { } {
   variable private

   createDialog
   selectNotebook $private(currentCamItem)
}

#
# confCam::startPlugin
# Ouvre les cameras
#
proc ::confCam::startPlugin { } {
   variable private
   global conf

   if { $conf(camera,A,start) == "1" } {
      set private(A,camName) $conf(camera,A,camName)
      if { $private(A,camName) != "" } {
         ::confCam::configureCamera "A"
      }
   }
   if { $conf(camera,B,start) == "1" } {
      set private(B,camName) $conf(camera,B,camName)
      if { $private(B,camName) != "" } {
         ::confCam::configureCamera "B"
      }
   }
   if { $conf(camera,C,start) == "1" } {
      set private(C,camName) $conf(camera,C,camName)
      if { $private(C,camName) != "" } {
         ::confCam::configureCamera "C"
      }
   }
}

#
# confCam::stopPlugin
# Ferme toutes les cameras ouvertes
#
proc ::confCam::stopPlugin { } {
   ::confCam::stopItem A
   ::confCam::stopItem B
   ::confCam::stopItem C
}

#
# confCam::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
# la configuration, et fermer la fenetre de reglage de la camera
#
proc ::confCam::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#
# confCam::appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
# memoriser et appliquer la configuration
#
proc ::confCam::appliquer { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled
   #--- J'arrete la camera
   stopItem $private(currentCamItem)
   #--- je copie les parametres de la nouvelle camera dans conf()
   widgetToConf    $private(currentCamItem)
   configureCamera $private(currentCamItem)
   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#
# confCam::afficherAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#
proc ::confCam::afficherAide { } {
   variable private

   set selectedPluginName [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#
# confCam::fermer
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
#
proc ::confCam::fermer { } {
   variable private

   ::confCam::recupPosDim
   destroy $private(frm)
}

#
# confCam::recupPosDim
# Permet de recuperer et de sauvegarder la position de la fenetre de configuration de la camera
#
proc ::confCam::recupPosDim { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set conf(camera,geometry) $private(geometry)
}

proc ::confCam::createDialog { } {
   variable private
   global caption conf

   #---
   if { [ winfo exists $private(frm) ] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      selectNotebook $private(currentCamItem)
      focus $private(frm)
      return
   }
   #---
   toplevel $private(frm)
   wm geometry $private(frm) $private(geometry)
   wm minsize $private(frm) 670 430
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confcam,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW ::confCam::fermer

   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      for { set i 0 } { $i < [ llength $private(pluginNamespaceList) ] } { incr i } {
         set namespace [ lindex $private(pluginNamespaceList) $i ]
         set title     [ lindex $private(pluginLabelList) $i ]
         set frm       [ $notebook insert end $namespace -text "$title " -raisecmd "::confCam::onRaiseNotebook $namespace" ]
         ::$namespace\::fillConfigPage $frm $private(currentCamItem)
      }
      pack $notebook -fill both -expand 1 -padx 4 -pady 4

   pack $private(frm).usr -side top -fill both -expand 1

   #--- Je recupere la liste des visu
   set list_visu [list ]
   foreach visuNo [::visu::list] {
      lappend list_visu "visu$visuNo"
   }
   lappend list_visu $caption(confcam,nouvelle_visu)
   set private(list_visu) $list_visu

   #--- Parametres de la camera A
   frame $private(frm).startA -borderwidth 1 -relief raised
      radiobutton $private(frm).startA.item -anchor w -highlightthickness 0 \
         -text "A :" -value "A" -variable ::confCam::private(currentCamItem) \
         -command "::confCam::selectNotebook A"
      pack $private(frm).startA.item -side left -padx 3 -pady 3 -fill x
      label $private(frm).startA.camNo -textvariable ::confCam::private(A,camNo)
      pack $private(frm).startA.camNo -side left -padx 3 -pady 3 -fill x
      label $private(frm).startA.name -textvariable ::confCam::private(A,camName)
      pack $private(frm).startA.name -side left -padx 3 -pady 3 -fill x

      ComboBox $private(frm).startA.visu \
         -width 8          \
         -height [ llength $private(list_visu) ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::confCam::private(A,visuName) \
         -values $private(list_visu)
      pack $private(frm).startA.visu -side left -padx 3 -pady 3 -fill x
      button $private(frm).startA.stop -text "$caption(confcam,arreter)" -width 7 -command "::confCam::stopItem A"
      pack $private(frm).startA.stop -side left -padx 3 -pady 3 -expand true
      checkbutton $private(frm).startA.chk -text "$caption(confcam,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(camera,A,start)
      pack $private(frm).startA.chk -side left -padx 3 -pady 3 -expand true
   pack $private(frm).startA -side top -fill x

   #--- Parametres de la camera B
   frame $private(frm).startB -borderwidth 1 -relief raised
      radiobutton $private(frm).startB.item -anchor w -highlightthickness 0 \
         -text "B :" -value "B" -variable ::confCam::private(currentCamItem) \
         -command "::confCam::selectNotebook B"
      pack $private(frm).startB.item -side left -padx 3 -pady 3 -fill x
      label $private(frm).startB.camNo -textvariable ::confCam::private(B,camNo)
      pack $private(frm).startB.camNo -side left -padx 3 -pady 3 -fill x
      label $private(frm).startB.name -textvariable ::confCam::private(B,camName)
      pack $private(frm).startB.name -side left -padx 3 -pady 3 -fill x

      ComboBox $private(frm).startB.visu \
         -width 8          \
         -height [ llength $private(list_visu) ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::confCam::private(B,visuName) \
         -values $private(list_visu)
      pack $private(frm).startB.visu -side left -padx 3 -pady 3 -fill x
      button $private(frm).startB.stop -text "$caption(confcam,arreter)" -width 7 -command "::confCam::stopItem B"
      pack $private(frm).startB.stop -side left -padx 3 -pady 3 -expand true
      checkbutton $private(frm).startB.chk -text "$caption(confcam,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(camera,B,start)
      pack $private(frm).startB.chk -side left -padx 3 -pady 3 -expand true
   pack $private(frm).startB -side top -fill x

   #--- Parametres de la camera C
   frame $private(frm).startC -borderwidth 1 -relief raised
      radiobutton $private(frm).startC.item -anchor w -highlightthickness 0 \
         -text "C :" -value "C" -variable ::confCam::private(currentCamItem) \
         -command "::confCam::selectNotebook C"
      pack $private(frm).startC.item -side left -padx 3 -pady 3 -fill x
      label $private(frm).startC.camNo -textvariable ::confCam::private(C,camNo)
      pack $private(frm).startC.camNo -side left -padx 3 -pady 3 -fill x
      label $private(frm).startC.name -textvariable ::confCam::private(C,camName)
      pack $private(frm).startC.name -side left -padx 3 -pady 3 -fill x

      ComboBox $private(frm).startC.visu \
         -width 8          \
         -height [ llength $private(list_visu) ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable ::confCam::private(C,visuName) \
         -values $private(list_visu)
      pack $private(frm).startC.visu -side left -padx 3 -pady 3 -fill x
      button $private(frm).startC.stop -text "$caption(confcam,arreter)" -width 7 -command "::confCam::stopItem C"
      pack $private(frm).startC.stop -side left -padx 3 -pady 3 -expand true
      checkbutton $private(frm).startC.chk -text "$caption(confcam,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(camera,C,start)
      pack $private(frm).startC.chk -side left -padx 3 -pady 3 -expand true
   pack $private(frm).startC -side top -fill x

   #--- Frame pour les boutons
   frame $private(frm).cmd -borderwidth 1 -relief raised
      button $private(frm).cmd.ok -text "$caption(confcam,ok)" -width 7 -command "::confCam::ok"
      if { $conf(ok+appliquer) == "1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }
      button $private(frm).cmd.appliquer -text "$caption(confcam,appliquer)" -width 8 -command "::confCam::appliquer"
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
      button $private(frm).cmd.fermer -text "$caption(confcam,fermer)" -width 7 -command "::confCam::fermer"
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
      button $private(frm).cmd.aide -text "$caption(confcam,aide)" -width 7 -command "::confCam::afficherAide"
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
   pack $private(frm).cmd -side top -fill x

   #---
   focus $private(frm)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private(frm) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)
}

#
#--- Cree une thread dediee a la camera
#--- et retourne le numero de la thread
#
proc ::confCam::createThread { camItem bufNo } {
   variable private

   #--- Je cree la thread de la camera, si l'option multithread est activee dans le TCL
   if { $::tcl_platform(threaded)==1 } {
      set camNo $private($camItem,camNo)

      if { [info commands "cam$camNo"] == "cam$camNo" } {
         #--- creation dun nouvelle thread
         set threadNo [thread::create ]
         #--- declaration de la variable globale mainThreadNo dans la thread de la camera
         thread::send $threadNo "set mainThreadNo [thread::id]"
         #--- je copie la commande de la camera dans la thread de la camera
         thread::copycommand $threadNo "cam$camNo"
         #--- declaration de la variable globale camNo dans la thread de la camera
         thread::send $threadNo "set camNo $camNo"
         #--- je copie la commande du buffer dans la thread de la camera
         thread::copycommand $threadNo "buf$bufNo"
         #--- J'ajoute la commande de liaison longue pose dans la thread de la camera
         if { [getPluginProperty $camItem "hasLongExposure"] == 1 } {
            if { [cam$camNo longueposelinkno] != 0} {
               thread::copycommand $threadNo "link[cam$camNo longueposelinkno]"
            }
         }
      } else {
         #--- si la commande cam$camNo n'existe pas alors il n'est pas necessaire de creer la thread
         set threadNo "0"
      }
   } else {
      set threadNo "0"
   }
   return $threadNo
}

#
# Cree un widget "label" avec une URL du site WEB
#
proc ::confCam::createUrlLabel { tkparent title url } {
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
# confCam::connectCamera
# Affichage d'un message d'alerte pendant la connexion de la camera au demarrage
#
proc ::confCam::connectCamera { } {
   variable private
   global audace caption color

   if [ winfo exists $audace(base).connectCamera ] {
      destroy $audace(base).connectCamera
   }

   toplevel $audace(base).connectCamera
   wm resizable $audace(base).connectCamera 0 0
   wm title $audace(base).connectCamera "$caption(confcam,attention)"
   if { [ info exists private(frm) ] } {
      if { [ winfo exists $private(frm) ] } {
         set posx_connectCamera [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
         set posy_connectCamera [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
         wm geometry $audace(base).connectCamera +[ expr $posx_connectCamera + 50 ]+[ expr $posy_connectCamera + 100 ]
         wm transient $audace(base).connectCamera $private(frm)
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
# confCam::selectNotebook
# Selectionne un onglet
#----------------------------------------------------------------------------
proc ::confCam::selectNotebook { camItem { camName "" } } {
   variable private
   global conf

   #--- je recupere l'item courant
   if { $camName == "" } {
      set camName $conf(camera,$camItem,camName)
   }

   if { $camName != "" } {
      set frm [ $private(frm).usr.onglet getframe $camName ]
      ::$camName\::fillConfigPage $frm $camItem
      $private(frm).usr.onglet raise $camName
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#----------------------------------------------------------------------------
# confCam::onRaiseNotebook
# affiche en gras le nom de l'onglet
#----------------------------------------------------------------------------
proc ::confCam::onRaiseNotebook { camName } {
   variable private

   set font [$private(frm).usr.onglet.c itemcget "$camName:text" -font]
   lappend font "bold"
   #--- remarque : il faut attendre que l'onglet soit redessine avant de changer la police
   after 200 $private(frm).usr.onglet.c itemconfigure "$camName:text" -font [list $font]
}

#----------------------------------------------------------------------------
# confCam::setShutter
# Procedure de changement de l'obturateur de la camera
#----------------------------------------------------------------------------
proc ::confCam::setShutter { camItem shutterState } {
   variable private
   global caption

   #---
   set ShutterOptionList    [ ::confCam::getPluginProperty $camItem shutterList ]
   set lg_ShutterOptionList [ llength $ShutterOptionList ]
   #---
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
      ::$private($camItem,camName)::setShutter $camItem $shutterState $ShutterOptionList
   } else {
      tk_messageBox -title $caption(confcam,pb) -type ok \
         -message $caption(confcam,onlycam+obt)
      return -1
   }
   return $shutterState
}

#----------------------------------------------------------------------------
# confCam::stopItem
# Arrete la camera camItem
#----------------------------------------------------------------------------
proc ::confCam::stopItem { camItem } {
   variable private
   global audace

   if { $camItem == "" } {
      return
   }
   if { $private($camItem,camName) != "" } {
      set camNo $private($camItem,camNo)

      #--- Je supprime la thread de la camera si elle existe
      if { $private($camItem,threadNo)!=0 } {
         #--- Je supprime la thread
         thread::release $private($camItem,threadNo)
         set private($camItem,threadNo) "0"
      }

      #--- Je ferme les ressources specifiques de la camera
      ::$private($camItem,camName)::stop $camItem
   }

   #--- Raz des parametres de l'item
   set private($camItem,camNo) "0"
   #--- Je desassocie la camera de la visu
   if { $private($camItem,visuNo) != 0 } {
      ::confVisu::setCamera $private($camItem,visuNo) "" 0
      set private($camItem,visuNo) "0"
   }
   #---
   if { $private($camItem,visuNo) == "1" } {
      #--- Mise a jour de la variable audace pour compatibilite
      set audace(camNo) $private($camItem,camNo)
   }
   set private($camItem,camName) ""
}

#
# confCam::isReady
#    Retourne "1" si la camera est demarree, sinon retourne "0"
#
#  Parametres :
#     camNo : Numero de la camera
#
proc ::confCam::isReady { camItem } {
   #--- Je verifie si la camera est capable fournir son nom
   if { [getPluginProperty $camItem "name"] == "" } {
      #--- camera KO
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
proc ::confCam::getPluginProperty { camItem propertyName } {
   variable private

   # binningList :      Retourne la liste des binnings disponibles
   # binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
   # binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
   # dynamic :          Retourne la liste de la dynamique haute et basse
   # hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
   # hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
   # hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
   # hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
   # hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
   # hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
   # hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
   # longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
   # multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
   # name :             Retourne le modele de la camera
   # product :          Retourne le nom du produit
   # shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)

   #--- je recherche la valeur par defaut de la propriete
   #--- si la valeur par defaut de la propriete n'existe pas , je retourne une chaine vide
   switch $propertyName {
      binningList      { set result [ list "" ] }
      binningXListScan { set result [ list "" ] }
      binningYListScan { set result [ list "" ] }
      dynamic          { set result [ list 32767 -32768 ] }
      hasBinning       { set result 0 }
      hasFormat        { set result 0 }
      hasLongExposure  { set result 0 }
      hasScan          { set result 0 }
      hasShutter       { set result 0 }
      hasVideo         { set result 0 }
      hasWindow        { set result 0 }
      longExposure     { set result 1 }
      multiCamera      { set result 0 }
      name             { set result "" }
      product          { set result "" }
      shutterList      { set result [ list "" ] }
      default          { set result "" }
   }

   #--- si aucune camera n'est selectionnee, je retourne la valeur par defaut
   if { $camItem == "" || $private($camItem,camName)==""} {
      return $result
   }

   #--- si une camera est selectionnee, je recherche la valeur propre a la camera
   set result [ ::$private($camItem,camName)::getPluginProperty $camItem $propertyName ]
   return $result
}

#
# confCam::getCamNo
#    Retourne le numero de la camera
#
#  Parametres :
#     camItem : intance de la camera
#
proc ::confCam::getCamNo { camItem } {
   variable private

   #--- si aucune camera n'est selectionnee, je retourne la valeur par defaut
   if { $camItem == "" || $private($camItem,camName)==""} {
      set result "0"
   } else {
      set result $private($camItem,camNo)
   }

   return $result
}

#
# confCam::getCurrentCamItem
#    Retourne le camItem courant
#
#  Parametres :
#     aucun
#
proc ::confCam::getCurrentCamItem { } {
   variable private

   return $private(currentCamItem)
}

#
# confCam::getShutter
#    Retourne l'etat de l'obturateur
#    Si la camera n'a pas d'obturateur, retourne une chaine vide
#  Parametres :
#     camItem : Instance de la camera
#
proc ::confCam::getShutter { camItem } {
   variable private
   global conf

   if { [info exists conf($private($camItem,camName),foncobtu) ] } {
      return $conf($private($camItem,camName),foncobtu)
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
proc ::confCam::getThreadNo { camItem } {
   variable private

   return $private($camItem,threadNo)
}

#
# getVisuNo
#    Retourne le numero de la visu associee a la  camera
#    Si la camera n'a pas de visu associee, la valeur retournee est ""
#  Parametres :
#     camItem : Numero de la camera
#
proc ::confCam::getVisuNo { camItem } {
   variable private

   return $private($camItem,visuNo)
}

#
# confCam::closeCamera
#  Ferme la camera
#
#  Parametres :
#     camNo : Numero de la camera
#
proc ::confCam::closeCamera { camNo } {
   variable private

   if { $private(A,camNo) == $camNo } {
      stopItem "A"
   }
   if { $private(B,camNo) == $camNo } {
      stopItem "B"
   }
   if { $private(C,camNo) == $camNo } {
      stopItem "C"
   }
}

#
# confCam::configureCamera
# Configure la camera en fonction des donnees contenues dans le tableau conf :
# private($camItem,camName) -> type de camera employe
# conf(cam,A,...) -> proprietes de ce type de camera
#
proc ::confCam::configureCamera { camItem } {
   variable private
   global audace caption conf

   #--- Initialisation de la variable erreur
   set erreur "1"

   #--- Affichage d'un message d'alerte si necessaire
   ::confCam::connectCamera

   #--- J'enregistre le numero de la visu associee a la camera
   if { "$private($camItem,camName)" != "" } {
      if { $private($camItem,visuName) == $caption(confcam,nouvelle_visu) } {
         set visuNo [::confVisu::create]
      } else {
         #--- je recupere le numera de la visu
         scan $private($camItem,visuName) "visu%d" visuNo
         #--- je verifie que la visu existe
         if { [lsearch -exact [visu::list] $visuNo] == -1 } {
            #--- si la visu n'existe plus , je la recree
            set visuNo [::confVisu::create]
         }
      }
   } else {
      #--- Si c'est l'ouverture d'une camera au demarrage de Audela
      #--- J'impose la visu
      if { $camItem == "A" } { set visuNo 1 }
      if { $camItem == "B" } { set visuNo [::confVisu::create] }
      if { $camItem == "C" } { set visuNo [::confVisu::create] }
   }
   set private($camItem,visuNo)   $visuNo
   set private($camItem,visuName) visu$visuNo

   #--- Remise a jour de la liste des visu
   set list_visu [list ]
   #--- je recherche les visu existantes
   foreach n [::visu::list] {
      lappend list_visu "visu$n"
   }
   #--- j'ajoute la visu "nouvelle"
   lappend list_visu $caption(confcam,nouvelle_visu)
   set private(list_visu) $list_visu

   if { [ info exists private(frm) ] } {
      if { [ winfo exists $private(frm) ] } {
         $private(frm).startA.visu configure -height [ llength $private(list_visu) ]
         $private(frm).startA.visu configure -values $private(list_visu)
         $private(frm).startB.visu configure -height [ llength $private(list_visu) ]
         $private(frm).startB.visu configure -values $private(list_visu)
         $private(frm).startC.visu configure -height [ llength $private(list_visu) ]
         $private(frm).startC.visu configure -values $private(list_visu)
      }
   }

   #--- Je recupere le numero buffer de la visu associee a la camera
   set bufNo [::confVisu::getBufNo $visuNo]

   set catchResult [ catch {
      #--- je configure la camera
      ::$private($camItem,camName)::configureCamera $camItem $bufNo

      #--- je recupere camNo
      set private($camItem,camNo) [ ::$private($camItem,camName)::getCamNo $camItem ]

      #--- Je cree la thread dediee a la camera
      set private($camItem,threadNo) [ ::confCam::createThread $camItem $bufNo]

      if { $private($camItem,visuNo) == "1" } {
         #--- Mise a jour de la variable audace pour compatibilite
         set audace(camNo) $private($camItem,camNo)
      }

      #--- J'associe la camera avec la visu
      ::confVisu::setCamera $private($camItem,visuNo) $camItem $private($camItem,camNo)

      #--- Desactive le blocage pendant l'acquisition (cli/sti)
      catch {
         cam$private($camItem,camNo) interrupt 0
      }

   } errorMessage ]
   #--- <= fin du catch

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult != "0" } {
      #--- j'affiche le message d'erreur
      switch $errorMessage {
         "CameraUnique" {
            #--- message d'erreur pour une camera unique
            tk_messageBox -title "$caption(confcam,attention)" -type ok \
               -message "$caption(confcam,connexion_texte3)"
         }
         default {
            #--- message d'erreur pour les autres cas d'erreur
            ::console::affiche_erreur "$::errorInfo\n\n"
            tk_messageBox -message "$errorMessage. See console" -icon error
         }
      }
      #--- Je desactive le demarrage automatique
      set conf(camera,$camItem,start) "0"
      #--- Je supprime la thread de la camera si elle existe
      if { $private($camItem,threadNo)!=0 } {
        #--- Je supprime la thread
         thread::release $private($camItem,threadNo)
         set private($camItem,threadNo) "0"
      }

      #--- En cas de probleme, camera par defaut
      set private($camItem,camName) ""
      set private($camItem,camNo)   "0"
      set private($camItem,visuNo)  "0"
   }

   #--- Effacement du message d'alerte s'il existe
   if [ winfo exists $audace(base).connectCamera ] {
      destroy $audace(base).connectCamera
   }
}

#
# confCam::widgetToConf
# Acquisition de la configuration, c'est a dire isolation des
# differentes variables dans le tableau conf(...)
#
proc ::confCam::widgetToConf { camItem } {
   variable private
   global conf

   set camName                       [ $private(frm).usr.onglet raise ]
   set private($camItem,camName)     $camName
   set conf(camera,$camItem,camName) $camName

   ::$private($camItem,camName)::widgetToConf $camItem
}


#------------------------------------------------------------
# ::confCam::findPlugin
# recherche les plugins de type "camera"
#
# conditions :
#   - le plugin doit avoir une procedure getPluginType qui retourne "camera"
#   - le plugin doit avoir une procedure getPluginTitle
#   - etc.
#
# si le plugin remplit les conditions :
# son label est ajoute dans la liste pluginTitleList et son namespace est ajoute dans pluginNamespaceList
# sinon le fichier tcl est ignore car ce n'est pas un plugin
#
# return 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confCam::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers camera/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" camera * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "camera" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(confcam,camera) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading camera $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confCam::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphabétique des libelles
   set pluginList ""
   for { set i 0} {$i< [llength $private(pluginLabelList)] } {incr i } {
      lappend pluginList [list [lindex $private(pluginLabelList) $i] [lindex $private(pluginNamespaceList) $i] ]
   }
   set pluginList [lsort -dictionary -index 0 $pluginList]
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   foreach plugin $pluginList {
      lappend private(pluginLabelList)     [lindex $plugin 0]
      lappend private(pluginNamespaceList) [lindex $plugin 1]
   }

   ::console::affiche_prompt "\n"

   if { [llength $private(pluginNamespaceList)] < 1 } {
      #--- aucun plugin correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#------------------------------------------------------------
# addCameraListener
#    ajoute une procedure a appeler si on change de camera
#  parametres :
#    camItem: numero de la visu
#    cmd : commande TCL a lancer quand la camera change
#------------------------------------------------------------
proc ::confCam::addCameraListener { camItem cmd } {
   trace add variable "::confCam::private($camItem,camNo)" write $cmd
}

#------------------------------------------------------------
# removeCameraListener
#    supprime une procedure a appeler si on change de camera
#  parametres :
#    visuNo: numero de la visu
#    cmd : commande TCL a lancer quand la camera change
#------------------------------------------------------------
proc ::confCam::removeCameraListener { camItem cmd } {
   trace remove variable "::confCam::private($camItem,camNo)" write $cmd
}

#--- Connexion au demarrage de la camera selectionnee par defaut
::confCam::init

