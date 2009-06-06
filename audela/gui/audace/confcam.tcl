#
# Fichier : confcam.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'camera'
# Mise a jour $Id: confcam.tcl,v 1.130 2009-06-06 10:27:42 michelpujol Exp $
#

namespace eval ::confCam {
}

#------------------------------------------------------------
# init (est lance automatiquement au chargement de ce fichier tcl)
# Initialise les variables conf(...) et caption(...)
# Demarre le plugin selectionne par defaut
#------------------------------------------------------------
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
   if { ! [ info exists conf(camera,geometry) ] }  { set conf(camera,geometry)  "605x440+15+15" }

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

#------------------------------------------------------------
# run
# Cree la fenetre de choix et de configuration des cameras
# private(currentCamItem) = C'est le camItem courant
#------------------------------------------------------------
proc ::confCam::run { } {
   variable private

   createDialog
   selectNotebook $private(currentCamItem)
}

#------------------------------------------------------------
# startPlugin
# Ouvre les cameras
#------------------------------------------------------------
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

#------------------------------------------------------------
# stopPlugin
# Ferme toutes les cameras ouvertes
#------------------------------------------------------------
proc ::confCam::stopPlugin { } {
   ::confCam::stopItem A
   ::confCam::stopItem B
   ::confCam::stopItem C
}

#------------------------------------------------------------
# ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
# la configuration, et fermer la fenetre de reglage de la camera
#------------------------------------------------------------
proc ::confCam::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
# memoriser et appliquer la configuration
#------------------------------------------------------------
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

#------------------------------------------------------------
# afficherAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confCam::afficherAide { } {
   variable private

   set selectedPluginName [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#------------------------------------------------------------
# fermer
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confCam::fermer { } {
   variable private

   ::confCam::recupPosDim
   destroy $private(frm)
}

#------------------------------------------------------------
# recupPosDim
# Permet de recuperer et de sauvegarder la position de la fenetre de configuration de la camera
#------------------------------------------------------------
proc ::confCam::recupPosDim { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set conf(camera,geometry) $private(geometry)
}

#------------------------------------------------------------
# createDialog
# Creation de l'interface graphique
#------------------------------------------------------------
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

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(geometry)
   wm minsize $private(frm) 605 440
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confcam,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW ::confCam::fermer

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
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

   pack $private(frm).cmd -side bottom -fill x

   #--- Je recupere la liste des visu
   set list_visu [list ]
   foreach visuNo [::visu::list] {
      lappend list_visu "visu$visuNo"
   }
   lappend list_visu $caption(confcam,nouvelle_visu)
   set private(list_visu) $list_visu

   #--- Frame des parametres de la camera C
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

   pack $private(frm).startC -side bottom -fill x

   #--- Frame des parametres de la camera B
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

   pack $private(frm).startB -side bottom -fill x

   #--- Frame des parametres de la camera A
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

   pack $private(frm).startA -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $private(pluginNamespaceList) {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title " ]
         ### -raisecmd "::confCam::onRaiseNotebook $namespace"
         ::$namespace\::fillConfigPage $frm $private(currentCamItem)
      }
      pack $notebook -fill both -expand 1 -padx 4 -pady 4

   pack $private(frm).usr -side top -fill both -expand 1

   #--- La fenetre est active
   focus $private(frm)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private(frm) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)
}

#------------------------------------------------------------
# createUrlLabel
# Cree un widget "label" avec une URL du site WEB
#------------------------------------------------------------
proc ::confCam::createUrlLabel { tkparent title url } {
   global color

   label $tkparent.labURL -text "$title" -fg $color(blue)
   if { $url != "" } {
      bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   }
   bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return  $tkparent.labURL
}

#------------------------------------------------------------
# displayConnectCamera
# Affichage d'un message d'alerte pendant la connexion de la camera au demarrage
#------------------------------------------------------------
proc ::confCam::displayConnectCamera { } {
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
   label $audace(base).connectCamera.labURL_1 -text "$caption(confcam,connexion_texte1)" -fg $color(red)
   pack $audace(base).connectCamera.labURL_1 -padx 10 -pady 2
   label $audace(base).connectCamera.labURL_2 -text "$caption(confcam,connexion_texte2)" -fg $color(red)
   pack $audace(base).connectCamera.labURL_2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).connectCamera

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectCamera
}

#------------------------------------------------------------
# selectNotebook
# Selectionne un onglet
#------------------------------------------------------------
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

#------------------------------------------------------------
# onRaiseNotebook
# Affiche en gras le nom de l'onglet
#------------------------------------------------------------
proc ::confCam::onRaiseNotebook { camName } {
   variable private

   if { [winfo exists $private(frm).usr.onglet.c ] } {
      set font [$private(frm).usr.onglet.c itemcget "$camName:text" -font]
      lappend font "bold"
      #--- remarque : il faut attendre que l'onglet soit redessine avant de changer la police
      after 100 $private(frm).usr.onglet.c itemconfigure "$camName:text" -font [list $font]
   }
}

#----------------------------------------------------------------------------
# setConnection
#    connecte ou deconnecte la camera
#
# parametres :
#    camItem : item de la camera
#    state   : 1 = connecter la camera , 0 = deconnecter la camera
# return
#    rien
#----------------------------------------------------------------------------
proc ::confCam::setConnection { camItem state } {
   variable private

   if { $camItem == "" } {
      #--- je retourne une erreur
      error "No camera"
   }
   if { [namespace which -command ::$private($camItem,camName)::setConnection] == "::$private($camItem,camName)::setConnection" } {
      ::$private($camItem,camName)::setConnection $camItem $state
   }
}

#------------------------------------------------------------
# setTempCCD
# Retourne la temperature de consigne du CCD
# Si la camera n'a pas cette fonctionnalite, retourne une chaine vide
#
# Parametres :
#    camItem : Item de la camera
#------------------------------------------------------------
proc ::confCam::setTempCCD { camItem } {
   global conf

   if { [ ::confCam::getPluginProperty $camItem hasSetTemp ] == "1" } {
      return [ format "%+4.1f" [ ::$conf(camera,$camItem,camName)::setTempCCD ] ]
   } else {
      return ""
   }
}

#------------------------------------------------------------
# setFormat
#  configure le format (ou la qualite) d'image de la camera
#
# Parametres :
#    camItem : item de la camera
#    format  : format de l'image
# Return
#    rien
#------------------------------------------------------------
proc ::confCam::setFormat { camItem format } {
   variable private

   if { $camItem != "" } {
      ::$private($camItem,camName)::setFormat $camItem $format
   }
}

#----------------------------------------------------------------------------
# setMount
# Ajoute la commande tel$telNo dans l'interpreteur de la camera
#
# Parametres :
#    camItem : item de la camera
#    telNo   : numero du telescope
#----------------------------------------------------------------------------
proc ::confCam::setMount { camItem telNo } {
   variable private
   if { $private($camItem,camNo) != 0 && [confTel::isReady]  } {
      if { [ catch { tel$telNo threadid } ] == 0 } {
         #--- le telescope possede un thread  dedie
         cam$private($camItem,camNo) tel $telNo [tel$telNo threadid]
      } else {
         #--- le telescope ne possede pas de thread dedie
         cam$private($camItem,camNo) tel $telNo
      }
   }
}

#----------------------------------------------------------------------------
# setShutter
# Change l'etat de l'obturateur de la camera
#
# Parametres :
#    camItem    : item de la camera
#    shutterState : etat de l'obturateur ( 0 1 2 )
#    mode    :  mode de changement ("increment"=incrementation ou "set"= valeur  )
#----------------------------------------------------------------------------
proc ::confCam::setShutter { camItem shutterState  { mode "increment" } } {
   variable private
   global caption

   #---
   set ShutterOptionList    [ ::confCam::getPluginProperty $camItem shutterList ]
   set lg_ShutterOptionList [ llength $ShutterOptionList ]
   #---
   if { [ ::confCam::getPluginProperty $camItem hasShutter ] } {
      if { $mode == "increment" } {
         incr shutterState
      }
      if { $lg_ShutterOptionList == "3" } {
         if { $shutterState == "3" } {
            set shutterState "0"
         }
      } elseif { $lg_ShutterOptionList == "2" } {
         #--- je force l'etat = 1 si le shutter ne possede pas l'etat 0
         if { $shutterState == "3" } {
            set shutterState "1"
         }
      }
      ::$private($camItem,camName)::setShutter $camItem $shutterState $ShutterOptionList
   }
   return $shutterState
}

#----------------------------------------------------------------------------
# stopItem
# Arrete la camera camItem
#------------------------------------------------------------
proc ::confCam::stopItem { camItem } {
   variable private
   global audace

   if { $camItem == "" } {
      return
   }
   if { $private($camItem,camName) != "" } {
      ::camera::delete $camItem
      #--- Je ferme les ressources specifiques de la camera
      ::$private($camItem,camName)::stop $camItem
   }

   #--- Raz des parametres de l'item
   set private($camItem,camNo) "0"
   #--- Je desassocie la camera de la visu
   if { $private($camItem,visuNo) != 0 } {
      ::confVisu::setCamera $private($camItem,visuNo) ""
      set private($camItem,visuNo) "0"
   }
   #---
   if { $private($camItem,visuNo) == "1" } {
      #--- Mise a jour de la variable audace pour compatibilite
      set audace(camNo) $private($camItem,camNo)
   }
   set private($camItem,camName) ""
}

#------------------------------------------------------------
# isReady
# Retourne "1" si la camera est demarree, sinon retourne "0"
#
# Parametre :
#    camItem : Item de la camera
#------------------------------------------------------------
proc ::confCam::isReady { camItem } {
   variable private

   #--- Je verifie que camItem existe
   if { $camItem == "" } {
      return 0
   }

   #--- Je verifie que la camera est prete
   if { $private($camItem,camName) == "" } {
      set result "0"
   } else {
      set result [ ::$private($camItem,camName)::isReady $camItem ]
   }
   return $result
}

#------------------------------------------------------------
# getPluginProperty
# Retourne la valeur d'une propriete de la camera
#
# Parametres :
#    camItem      : Instance de la camera
#    propertyName : Propriete
#
# Liste des proprietes :
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# dynamic :          Retourne la liste de la dynamique haute et basse
# formatList :       Retourne la liste des formats ou des qualites d'image (fine, normal, raw, ...)
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format ou d'une qualite d'image (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasQuality :       Retourne l'existence d'une qualit� (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasTempSensor :    Retourne l'existence du capteur de temperature (1 : Oui, 0 : Non)
# hasSetTemp :       Retourne l'existence d'une consigne de temperature (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# loadMode :         Retourne le mode de chargement d'une image (1: pas de chargment, 2:chargement immediat, 3: chargement differe)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
# title :            Retourne le titre du plugin
#------------------------------------------------------------
proc ::confCam::getPluginProperty { camItem propertyName } {
   variable private

   #--- je recherche la valeur par defaut de la propriete
   #--- si la valeur par defaut de la propriete n'existe pas , je retourne une chaine vide
   switch $propertyName {
      binningList      { set result [ list "" ] }
      binningXListScan { set result [ list "" ] }
      binningYListScan { set result [ list "" ] }
      dynamic          { set result [ list 32767 -32768 ] }
      formatList       { set result [ list "" ] }
      hasBinning       { set result 0 }
      hasFormat        { set result 0 }
      hasLongExposure  { set result 0 }
      hasQuality       { set result 0 }
      hasScan          { set result 0 }
      hasShutter       { set result 0 }
      hasTempSensor    { set result 0 }
      hasSetTemp       { set result 0 }
      hasVideo         { set result 0 }
      hasWindow        { set result 0 }
      loadMode         { set result 2 }
      longExposure     { set result 1 }
      multiCamera      { set result 0 }
      name             { set result "" }
      product          { set result "" }
      shutterList      { set result [ list "" ] }
      title            { set result "" }
      default          { set result "" }
   }

   #--- si aucune camera n'est selectionnee, je retourne la valeur par defaut
   if { $camItem == "" || $private($camItem,camName)==""} {
      return $result
   }

   #--- si une camera est selectionnee, je recherche la valeur propre a la camera
   if { $propertyName != "title" } {
      set result [ ::$private($camItem,camName)::getPluginProperty $camItem $propertyName ]
   } else {
      set result [ ::$private($camItem,camName)::getPluginTitle]
   }
   return $result
}

#------------------------------------------------------------
# getCamNo
# Retourne le numero de la camera
#
# Parametres :
#    camItem : Item de la camera
#------------------------------------------------------------
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

#------------------------------------------------------------
# getCurrentCamItem
# Retourne le camItem courant
#
# Parametres :
#    aucun
#------------------------------------------------------------
proc ::confCam::getCurrentCamItem { } {
   variable private

   return $private(currentCamItem)
}

#------------------------------------------------------------
# getShutter
# Retourne l'etat de l'obturateur
# Si la camera n'a pas d'obturateur, retourne une chaine vide
#
# Parametres :
#    camItem : Item de la camera
#------------------------------------------------------------
proc ::confCam::getShutter { camItem } {
   variable private
   global conf

   if { [info exists conf($private($camItem,camName),foncobtu) ] } {
      return $conf($private($camItem,camName),foncobtu)
   } else {
      return ""
   }
}

#------------------------------------------------------------
# getTempCCD
# Retourne la temperature du CCD
# Si la camera n'a pas de capteur de temperature, retourne une chaine vide
#
# Parametres :
#    camItem : Item de la camera
#------------------------------------------------------------
proc ::confCam::getTempCCD { camItem } {
   set camNo [ ::confCam::getCamNo $camItem ]
   if { $camNo != 0 } {
      if { [ ::confCam::getPluginProperty $camItem hasTempSensor ] == "1" } {
         return [ format "%+5.2f" [ cam$camNo temperature ] ]
      } else {
         return ""
      }
   }
}

#------------------------------------------------------------
# getVisuNo
# Retourne le numero de la visu associee a la  camera
# Si la camera n'a pas de visu associee, la valeur retournee est ""
#
# Parametres :
#    camItem : Item de la camera
#------------------------------------------------------------
proc ::confCam::getVisuNo { camItem } {
   variable private

   return $private($camItem,visuNo)
}

#------------------------------------------------------------
# configureCamera
# Configure la camera en fonction des donnees contenues dans le tableau conf :
# private($camItem,camName) -> type de camera employe
# conf(cam,A,...) -> proprietes de ce type de camera
#------------------------------------------------------------
proc ::confCam::configureCamera { camItem } {
   variable private
   global audace caption conf

   #--- Initialisation de la variable erreur
   set erreur "1"

   #--- Affichage d'un message d'alerte si necessaire
   ::confCam::displayConnectCamera

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

      #--- Je cree la camera
      ::camera::create $camItem

      if { $private($camItem,visuNo) == "1" } {
         #--- Mise a jour de la variable audace pour compatibilite
         set audace(camNo) $private($camItem,camNo)
      }

      #--- J'associe la camera avec la visu
      ::confVisu::setCamera $private($camItem,visuNo) $camItem

      #--- Desactive le blocage pendant l'acquisition (cli/sti)
      catch {
         cam$private($camItem,camNo) interrupt 0
      }

   } errorMessage ]

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult != "0" } {
      #--- J'affiche le message d'erreur
      switch $::errorCode {
         "NotRoot" {
            #--- message d'erreur si non root sous Linux
            tk_messageBox -title "$caption(confcam,attention)" -icon error \
               -message "$caption(confcam,notroot)"
         }
         "CameraUnique" {
            #--- message d'erreur pour une camera unique
            tk_messageBox -title "$caption(confcam,attention)" -type ok \
               -message "$caption(confcam,connexion_texte3)"
         }
         default {
            #--- message d'erreur pour les autres cas d'erreur
            ::console::affiche_erreur "$::errorInfo\n\n"
            tk_messageBox -title "$caption(confcam,attention)" -icon error \
               -message "$errorMessage\n$caption(confcam,cannotcreatecam)\n$caption(confcam,seeconsole)"
         }
      }

      #--- Je desactive le demarrage automatique
      set conf(camera,$camItem,start) "0"

      #--- Je supprime la camera
      ::camera::delete $camItem

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

#------------------------------------------------------------
# widgetToConf
# Acquisition de la configuration, c'est a dire isolation des
# differentes variables dans le tableau conf(...)
#------------------------------------------------------------
proc ::confCam::widgetToConf { camItem } {
   variable private
   global conf

   set camName                       [ $private(frm).usr.onglet raise ]
   set private($camItem,camName)     $camName
   set conf(camera,$camItem,camName) $camName

   ::$private($camItem,camName)::widgetToConf $camItem
}

#------------------------------------------------------------
# findPlugin
# recherche les plugins de type "camera"
#
# conditions :
#    - le plugin doit avoir une procedure getPluginType qui retourne "camera"
#    - le plugin doit avoir une procedure getPluginTitle
#    - etc.
#
# si le plugin remplit les conditions :
# son label est ajoute dans la liste pluginTitleList et son namespace est ajoute dans pluginNamespaceList
# sinon le fichier tcl est ignore car ce n'est pas un plugin
#
#    return 0 = OK, 1 = error (no plugin found)
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

   #--- je trie les plugins par ordre alphab�tique des libelles
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
# ajoute une procedure a appeler si on change de camera
#
# parametres :
#    camItem : Item de la camera
#    cmd : commande TCL a lancer quand la camera change
#------------------------------------------------------------
proc ::confCam::addCameraListener { camItem cmd } {
   trace add variable "::confCam::private($camItem,camNo)" write $cmd
}

#------------------------------------------------------------
# removeCameraListener
# supprime une procedure a appeler si on change de camera
#
# parametres :
#    camItem : Item de la camera
#    cmd : commande TCL a lancer quand la camera change
#------------------------------------------------------------
proc ::confCam::removeCameraListener { camItem cmd } {
   trace remove variable "::confCam::private($camItem,camNo)" write $cmd
}

#--- Connexion au demarrage de la camera selectionnee par defaut
::confCam::init

