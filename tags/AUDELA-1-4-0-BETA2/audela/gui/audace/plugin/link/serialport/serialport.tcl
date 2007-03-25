#
# Fichier : serialport.tcl
# Description : Interface de liaison Port Serie
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: serialport.tcl,v 1.11 2007-01-27 15:25:34 robertdelmas Exp $
#

package provide serialport 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init              : initialise le namespace (appelee pendant le chargement de ce source)
#     getDriverName     : retourne le nom du driver
#     getLabel          : retourne le nom affichable du driver
#     getHelp           : retourne la documentation htm associee
#     getDriverType     : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf          : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()
#     fillConfigPage    : affiche la fenetre de configuration de ce driver
#     confToWidget      : copie le tableau conf() dans les variables des widgets
#     widgetToConf      : copie les variables des widgets dans le tableau conf()
#     configureDriver   : configure le driver
#     stopDriver        : arrete le driver et libere les ressources occupees
#     isReady           : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :
#

namespace eval serialport {
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
proc ::serialport::configureDriver { } {
   global audace

   #--- Affiche la liaison
   ###serialport::run "$audace(base).serialport"

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
#  create
#     demarre la liaison
#
#  return rien
#------------------------------------------------------------
proc ::serialport::create { linkLabel deviceId usage comment } {
   variable private
   global audace

   #--- pour l'instant, la liaison est cree par la librairie du peripherique

   #--- je stocke le commentaire d'utilisation
   set private($linkLabel,$deviceId,$usage) "$comment"
   #--- je rafraichis la liste
   if { [ winfo exists $audace(base).confLink ] } {
      ::serialport::refreshAvailableList
   }
   #--- je selectionne le link
   if { [ winfo exists $audace(base).confLink ] } {
      ::serialport::selectConfigLink $linkLabel
   }
   #---
   return
}

#------------------------------------------------------------
#  delete
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::serialport::delete { linkLabel deviceId usage } {
   global audace

   #--- pour l'instant, la liaison est arretee par le pilote du peripherique

   #--- je supprime le commentaire d'utilisation
   if { [info exists private($linklabel,$deviceId,$usage) } {
      unset private($linklabel,$deviceId,$usage)
   }
   #--- je rafraichis la liste
   if { [ winfo exists $audace(base).confLink ] } {
      ::serialport::refreshAvailableList
   }
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

   #---  j'afffiche la liste des link
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(serialport,available)
      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true
      Button  $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(serialport,refresh)" -command { ::serialport::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left
   pack $frm.available -side top -fill both -expand true

   frame $frm.port_exclus -borderwidth 0 -relief ridge
      label $frm.port_exclus_lab -text "$caption(serialport,port_exclus)"
      pack $frm.port_exclus_lab -in $frm.port_exclus -side left -padx 5 -pady 5
      entry $frm.port_exclus_ent -textvariable serialport::widget(serial,port_exclus) -width 25
      pack $frm.port_exclus_ent -in $frm.port_exclus -side left
   pack $frm.port_exclus -side top -fill x

   #--- je mets a jour la liste
   refreshAvailableList

   ::confColor::applyColor $private(frm)
}

#------------------------------------------------------------
#  getDriverType
#     retourne le type de driver
#
#  return "link"
#------------------------------------------------------------
proc ::serialport::getDriverType { } {
   return "link"
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::serialport::getHelp { } {
   return "serialport.htm"
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
#  getLabel
#     retourne le label du driver
#
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::serialport::getLabel { } {
   global caption

   return "$caption(serialport,titre)"
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
   #--- je retourne le label du link (premier mot de la ligne )
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  init (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#
#  return namespace
#------------------------------------------------------------
proc ::serialport::init { } {
   variable private

   #--- Charge le fichier caption
   source [ file join $::audace(rep_plugin) link serialport serialport.cap ]

   #--- Je charge les variables d'environnement
   initConf

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

   return [namespace current]
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::serialport::refreshAvailableList { } {
   variable private

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

   #--- je tiens compte des ports com exclus
   widgetToConf

   #--- je recherche les ports com
   Recherche_Ports

   #--- je remplis la liste
   foreach linkLabel [::serialport::getLinkLabels] {
      set linkText ""
      #--- si le link est ferme , j'affiche son label seulement
      if { $linkText == "" } {
         set linkText "$linkLabel"
      }
      #--- je recherche si ce link est ouvert
      foreach { key value } [array get ::serialport::private $linkLabel,*] {
          set deviceId [lindex [split $key ","] 1]
          set usage    [lindex [split $key ","] 2]
          set comment  $value
          append linkText " { $deviceId $usage $comment } "
      }

      $private(frm).available.list insert end $linkText
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel

   return
}

#------------------------------------------------------------
#  selectConfigItem
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::serialport::selectConfigLink { linkLabel } {
   variable private

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
      global audace
      global conf

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

::serialport::init

