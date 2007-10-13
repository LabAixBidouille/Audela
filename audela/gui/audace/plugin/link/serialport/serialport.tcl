#
# Fichier : serialport.tcl
# Description : Interface de liaison Port Serie
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: serialport.tcl,v 1.18 2007-10-13 08:34:18 robertdelmas Exp $
#

namespace eval serialport {
   package provide serialport 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] serialport.cap ]
}

#==============================================================
# Procedures generiques de configuration des drivers
#==============================================================

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::serialport::getPluginProperty { propertyName } {
   switch $propertyName {

   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du driver dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::serialport::getPluginTitle { } {
   global caption

   return "$caption(serialport,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::serialport::getPluginHelp { } {
   return "serialport.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de driver
#------------------------------------------------------------
proc ::serialport::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::serialport::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#
#  return namespace
#------------------------------------------------------------
proc ::serialport::initPlugin { } {
   variable private

   #--- Je charge les variables d'environnement
   initConf

   #--- Initialisation
   set private(frm) ""

   #--- je fixe le nom generique de la liaison
   if {  $::tcl_platform(os) == "Linux" } {
      set private(genericName) "/dev/tty"
   } else {
      set private(genericName) "COM"
   }

   #--- Recherche des ports com
   Recherche_Ports

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return rien
#------------------------------------------------------------
proc ::serialport::configureDriver { } {
   global audace

   #--- Affiche la liaison
  ### serialport::run "$audace(base).serialport"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::serialport::confToWidget { } {
   variable widget
   global conf

   set widget(serial,port_exclus) "$conf(serial,port_exclus)"
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return rien
#------------------------------------------------------------
proc ::serialport::createPluginInstance { linkLabel deviceId usage comment } {
   variable private
   global audace

   #--- pour l'instant, la liaison est cree par la librairie du peripherique

   #--- je stocke le commentaire d'utilisation
   set private(serialLink,$linkLabel,$deviceId,$usage) "$comment"
   #--- je rafraichis la liste
   ::serialport::refreshAvailableList
   #--- je selectionne le link
   ::serialport::selectConfigLink $linkLabel
   #---
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::serialport::deletePluginInstance { linkLabel deviceId usage } {
   variable private
   global audace

   #--- pour l'instant, la liaison est arretee par le pilote du peripherique

   #--- je supprime le commentaire d'utilisation
   if { [info exists private(serialLink,$linkLabel,$deviceId,$usage)] } {
      unset private(serialLink,$linkLabel,$deviceId,$usage)
   }
   #--- je rafraichis la liste
   ::serialport::refreshAvailableList
   #---
   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return rien
#------------------------------------------------------------
proc ::serialport::fillConfigPage { frm } {
   variable private
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- J'afffiche la liste des links exclus
   frame $private(frm).port_exclus -borderwidth 0 -relief ridge

      label $private(frm).port_exclus_lab -text "$caption(serialport,port_exclus)"
      pack $private(frm).port_exclus_lab -in $private(frm).port_exclus -side left -padx 5 -pady 5

      entry $private(frm).port_exclus_ent -textvariable serialport::widget(serial,port_exclus) -width 25
      pack $private(frm).port_exclus_ent -in $private(frm).port_exclus -side left

   pack $private(frm).port_exclus -side top -fill x

   #--- J'afffiche la liste des links disponibles et utilis�s
   TitleFrame $private(frm).available -borderwidth 2 -relief ridge -text $caption(serialport,available)
      listbox $private(frm).available.list
      pack $private(frm).available.list -in [$private(frm).available getframe] \
         -side left -fill both -expand true
   pack $private(frm).available -side left -fill both -expand true

   #--- J'afffiche le bouton de rafraichissement
   Button $private(frm).refresh -highlightthickness 0 -padx 10 -pady 3 -state normal \
      -text "$caption(serialport,refresh)" -command { ::serialport::refreshAvailableList }
   pack $private(frm).refresh -side left

   #--- Je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::serialport::initConf { } {
   global conf

   if { ! [ info exists conf(serial,port_exclus) ] } { set conf(serial,port_exclus) "COM3" }

   return
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#
#   exemple :
#   getLinkIndex "COM1"
#     1
#------------------------------------------------------------
proc ::serialport::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   if { [string first $private(genericName) $linkLabel]  == 0 } {
      scan $linkLabel "$private(genericName)%s" linkIndex
   }
   return $linkIndex
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des ports series disponibles
#
#   exemple :
#   getLinkLabels
#     { "COM1" "COM2" }
#------------------------------------------------------------
proc ::serialport::getLinkLabels { } {
   variable private

   set labels [list]

   if { $::tcl_platform(os) == "Linux" } {
      #--- je recherche les index des ports disponibles
      foreach port $::audace(list_com) {
         lappend labels "$port"
      }
   } else {
      foreach port $::audace(list_com) {
         set linkIndex ""
         lappend labels "$port"
      }
   }
   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "COM1"
#------------------------------------------------------------
proc ::serialport::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne)
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::serialport::refreshAvailableList { } {
   variable private
   global audace

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

   #--- j'efface le contenu de la liste des ports disponibles
   $private(frm).available.list delete 0 [ $private(frm).available.list size]

   #--- je tiens compte des ports com exclus
   widgetToConf

   #--- je recherche les ports com
   Recherche_Ports

   #--- je remplis la liste des ports disponibles
   foreach linkLabel [::serialport::getLinkLabels] {
      $private(frm).available.list insert end $linkLabel
   }

   #--- je recherche si ce link est ouvert
   foreach { key value } [array get ::serialport::private serialLink,*] {
      set linklabel [lindex [split $key ","] 1]
      set deviceId  [lindex [split $key ","] 2]
      set usage     [lindex [split $key ","] 3]
      set comment   $value
      set linkText "$linklabel { $deviceId $usage $comment }"
      #--- je renseigne la liste les ports deja utilises
      $private(frm).available.list insert end $linkText
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel

   return
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::serialport::selectConfigLink { linkLabel } {
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
proc ::serialport::widgetToConf { } {
   variable widget
   global conf

   set conf(serial,port_exclus) $widget(serial,port_exclus)
}

#------------------------------------------------------------
#  Recherche_Ports
#     recherche les ports com disponible sur le PC
#
#  return rien
#------------------------------------------------------------
proc ::serialport::Recherche_Ports { } {
   global audace conf

   #--- Recherche le ou les ports COM exclus
   set kd ""
   set port_exclus $conf(serial,port_exclus)
   set nbr_port_exclus [ llength $port_exclus ]
   if { $nbr_port_exclus == "1" } {
      set kd [string index $port_exclus [expr [string length $port_exclus]-1]]
   } else {
      for { set i 0 } { $i < $nbr_port_exclus } { incr i } {
         set a [ lindex $port_exclus $i ]
         set kdd [string index $a [expr [string length $a]-1]]
         lappend kd $kdd
         set kd [ lsort $kd ]
      }
   }

   #--- Suivant l'OS
   if { $::tcl_platform(os) == "Linux" } {
      set port_com     "/dev/ttyS"
      set port_com_usb "/dev/ttyUSB"
      set kk  "0"
      set kkt "20"
   } else {
      set port_com "COM"
      set kk  "1"
      set kkt "20"
   }

   #--- Recherche des ports com
   set comlist              ""
   set comlist_usb          ""
   set audace(list_com)     ""

   set i "0"
   for { set k $kk } { $k < $kkt } { incr k } {
      if { $k != "[ lindex $kd $i]" } {
         set errnum [ catch { open $port_com$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist $k
            close $msg
         }
      } else {
         incr i
      }
   }
   set long_com [ llength $comlist ]

   for { set k 0 } { $k < $long_com } { incr k } {
      lappend audace(list_com) "$port_com[ lindex $comlist $k ]"
   }

   if { $::tcl_platform(os) == "Linux" } {
      for { set k $kk } { $k < 20 } { incr k } {
         set errnum [ catch { open $port_com_usb$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist_usb $k
            close $msg
         }
      }
      set long_com_usb [ llength $comlist_usb ]

      for { set k 0 } { $k < $long_com_usb } { incr k } {
         lappend audace(list_com) "$port_com_usb[ lindex $comlist_usb $k ]"
      }
   }
}

