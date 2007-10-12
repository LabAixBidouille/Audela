#
# Fichier : quickaudine.tcl
# Description : Interface de liaison QuickAudine
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: quickaudine.tcl,v 1.19 2007-10-12 21:59:10 robertdelmas Exp $
#

namespace eval quickaudine {
   package provide quickaudine 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] quickaudine.cap ]
}

#==============================================================
# Procedures generiques de configuration des drivers
#==============================================================

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::configureDriver { } {
   global audace

   #--- Affiche la liaison
  ### quickaudine::run "$audace(base).quickaudine"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::confToWidget { } {
   variable widget
   global conf

   set widget(quickaudine,delayshutter) $conf(quickaudine,delayshutter)
   set widget(quickaudine,canspeed)     $conf(quickaudine,canspeed)
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::createPluginInstance { linkLabel deviceId usage comment } {
   global audace

   #--- je rafraichis la liste
   ::quickaudine::refreshAvailableList
   #--- je selectionne le link
   ::quickaudine::selectConfigLink $linkLabel
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::deletePluginInstance { linkLabel deviceId usage } {
   global audace

   #--- je rafraichis la liste
   ::quickaudine::refreshAvailableList
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::quickaudine::getPluginProperty { propertyName } {
   switch $propertyName {

   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du driver dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::quickaudine::getPluginTitle { } {
   global caption

   return "$caption(quickaudine,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::quickaudine::getPluginHelp { } {
   return "quickaudine.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de driver
#------------------------------------------------------------
proc ::quickaudine::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::quickaudine::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- j'afffiche la liste des link
   TitleFrame $private(frm).available -borderwidth 2 -relief ridge -text $caption(quickaudine,available)
      listbox $private(frm).available.list -height 4
      pack $private(frm).available.list -in [$private(frm).available getframe] -side left -fill both -expand true
      Button $private(frm).available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(quickaudine,refresh)" -command { ::quickaudine::refreshAvailableList }
      pack $private(frm).available.refresh -in [$private(frm).available getframe] -side left
   pack $private(frm).available -side top -fill both -expand true

   #--- label et entry pour le delai avant la lecture du CCD
   frame $private(frm).delayshutter -borderwidth 0 -relief raised
      label $private(frm).delayshutter.lab1 -text "$caption(quickaudine,delayshutter)"
      pack $private(frm).delayshutter.lab1 -in $private(frm).delayshutter -anchor center -side left -padx 10 -pady 10
      entry $private(frm).delayshutter.entry -width 5 -textvariable ::quickaudine::widget(quickaudine,delayshutter) \
         -justify center
      pack $private(frm).delayshutter.entry -in $private(frm).delayshutter -anchor center -side left -pady 10
      label $private(frm).delayshutter.lab2 -text "$caption(quickaudine,unite)"
      pack $private(frm).delayshutter.lab2 -in $private(frm).delayshutter -anchor center -side left -padx 2 -pady 10
   pack $private(frm).delayshutter -side top -fill x

   #--- label et scale pour la vitesse de lecture de chaque pixel
   frame $private(frm).speed -borderwidth 0 -relief raised
      label $private(frm).speed.lab3 -text "$caption(quickaudine,lecture_pixel)"
      pack $private(frm).speed.lab3 -in $private(frm).speed -anchor center -side left -padx 10 -pady 2
      scale $private(frm).speed.lecture_pixel_variant -from "1.0" -to "15.0" -length 300 \
         -orient horizontal -showvalue true -tickinterval 1 -resolution 1 \
         -borderwidth 2 -relief groove -variable ::quickaudine::widget(quickaudine,canspeed) -width 10
      pack $private(frm).speed.lecture_pixel_variant -in $private(frm).speed -anchor center -side left -pady 0
      label $private(frm).speed.lab4 -text "$caption(quickaudine,micro_sec)"
      pack $private(frm).speed.lab4 -in $private(frm).speed -anchor center -side left -padx 2 -pady 2
   pack $private(frm).speed -side top -fill x

   #--- j'affiche l'eventuel message d'erreur
   frame $private(frm).statusMessage -borderwidth 2 -relief ridge
      label $private(frm).statusMessage.statusMessage_lab -text "$caption(quickaudine,error)"
      pack $private(frm).statusMessage.statusMessage_lab -in $private(frm).statusMessage -side top \
         -anchor nw -padx 5 -pady 2
      Label $private(frm).statusMessage.status -textvariable ::quickaudine::private(statusMessage) -height 4 \
         -wraplength 400 -justify left
      pack $private(frm).statusMessage.status -in $private(frm).statusMessage -side top -anchor nw -padx 20
   pack $private(frm).statusMessage -side top -fill both

   #--- je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#
#   exemple :
#   getLinkIndex "quickaudine1"
#     1
#------------------------------------------------------------
proc ::quickaudine::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   scan $linkLabel "$private(genericName)%s" linkIndex
   return $linkIndex
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des quickaudine disponibles
#
#   exemple :
#   getLinkLabels
#     { "quickaudine0" "quickaudine1" }
#------------------------------------------------------------
proc ::quickaudine::getLinkLabels { } {
   variable private

   #--- j'initialise une liste vide
   set labels [list]
   catch {
      foreach instance [link::available quickremote ] {
         lappend labels "$private(genericName)[lindex $instance 0]"
      }
   } catchError
   set private(statusMessage) $catchError

   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "quickaudine0"
#------------------------------------------------------------
proc ::quickaudine::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne )
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#------------------------------------------------------------
proc ::quickaudine::initPlugin { } {
   variable private

   #--- Initialisation
   set private(frm) ""

   #--- je fixe le nom generique de la liaison
   set private(genericName)   "quickaudine"
   set private(statusMessage) ""

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::initConf { } {
   global conf

   if { ! [ info exists conf(quickaudine,delayshutter) ] } { set conf(quickaudine,delayshutter) "0" }
   if { ! [ info exists conf(quickaudine,canspeed) ] }     { set conf(quickaudine,canspeed)     "2" }

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::quickaudine::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::refreshAvailableList { } {
   variable private

   #--- je verifie que la liste existe
   if { [ winfo exists $private(frm).available.list ] == "0" } {
      return
   }

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   set selectedLinkLabel [getSelectedLinkLabel]

   #--- j'efface le contenu de la liste
   $private(frm).available.list delete 0 [ $private(frm).available.list size]

   #--- je recupere les linkNo ouverts
   set linkNoList [link::list]

   #--- je remplis la liste
   foreach linkLabel [getLinkLabels] {
      set linkText ""
      #--- je recherche si ce link est ouvert
      foreach linkNo $linkNoList {
         if { "[link$linkNo index]" == [getLinkIndex $linkLabel] } {
            #--- si le link est ouvert, j'affiche son label, linkNo et les utilisations
            set linkText "$linkLabel link$linkNo [link$linkNo use get]"
         }
      }
      #--- si le link est ferme, j'affiche son label seulement
      if { $linkText == "" } {
         set linkText "$linkLabel"
      }
      $private(frm).available.list insert end $linkText
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::selectConfigLink { linkLabel } {
   variable private

   #--- je verifie que la liste existe
   if { [ winfo exists $private(frm).available.list ] == "0" } {
      return
   }

   $private(frm).available.list selection clear 0 end

   #--- je recherche linkLabel dans la listbox  (linkLabel est le premier element de chaque ligne)
   for {set i 0} {$i<[$private(frm).available.list size]} {incr i} {
      if { [lindex [$private(frm).available.list get $i] 0] == $linkLabel } {
         $private(frm).available.list selection set $i
         return
      }
   }
   if { [$private(frm).available.list size] > 0 } {
      #--- sinon je selectionne le premier linkLabel
      $private(frm).available.list selection set 0
   }
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::widgetToConf { } {
   variable widget
   global conf

   set conf(quickaudine,delayshutter) $widget(quickaudine,delayshutter)
   set conf(quickaudine,canspeed)     $widget(quickaudine,canspeed)
}

