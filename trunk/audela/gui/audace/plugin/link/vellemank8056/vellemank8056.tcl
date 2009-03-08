#
# Fichier : vellemank8056.tcl
# Description : Interface pour carte Velleman K8056
# Auteurs : Michel PUJOL
# Mise a jour $Id: vellemank8056.tcl,v 1.1 2009-03-08 11:02:11 michelpujol Exp $
#

namespace eval vellemank8056 {
   package provide vellemank8056 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] vellemank8056.cap ]
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::vellemank8056::getPluginProperty { propertyName } {
   switch $propertyName {
      bitList {
         return [list 0 1 2 3 4 5 6 7]
      }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::vellemank8056::getPluginTitle { } {
   global caption

   return "$caption(vellemank8056,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::vellemank8056::getPluginHelp { } {
   return "vellemank8056.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::vellemank8056::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::vellemank8056::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#
#  return namespace
#------------------------------------------------------------
proc ::vellemank8056::initPlugin { } {
   variable private

   #--- Je charge les variables d'environnement
   if { ! [ info exists ::conf(vellemank8056,serialPort) ] } { set ::conf(vellemank8056,serialPort) "COM1" }

   #--- j'initialise les variables privees
   set private(frm) ""
   for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
      set private(bit,$bitNo) "OFF"
   }
   set private(portHandle) ""
   set private(linkNo)     0
   set private(genericName) "K8056"

}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::vellemank8056::isReady { } {
   variable private
   if { $private(linkNo) == 0 } {
      return 0
   } else {
      return 1
   }
}

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::configurePlugin { } {
   variable private

   if { [isReady] == 1 } {
      #--- je supprime la liaison si elle existe deja
      ::vellemank8056::stopPlugin
   }
   set linkLabel "$private(genericName)-$::conf(vellemank8056,serialPort)"
   #--- je cree la liaison K8056
   ::confLink::create $linkLabel "link" $private(genericName) ""

   return
}

#------------------------------------------------------------
#  stopPlugin
#     arrete le plugin
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::stopPlugin { } {
   variable private

   #--- j'arrete la liaison K8056
   set linkLabel "$private(genericName)-$::conf(vellemank8056,serialPort)"
   ::confLink::delete $linkLabel "link" $private(genericName)

   return
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return
#     numero du link
#------------------------------------------------------------
proc ::vellemank8056::createPluginInstance { linkLabel deviceId usage comment } {
   variable private
   global audace


   #--- je recupere l'index
   set linkIndex [getLinkIndex $linkLabel]
   #---
   set linkNo 0

   #-- j'ouvre le port serie
   set catchResult [catch {
      set private(portHandle) [open $::conf(vellemank8056,serialPort) r+]
      #-- je configure la vitesse
      ###fconfigure $private(portHandle) -mode "2400,n,8,1" -blocking 0
      fconfigure $private(portHandle) -mode "2400,n,8,1" -buffering none -blocking 0 -translation binary
      #--- j'ajoute l'utilisation du port serie
      ::serialport::createPluginInstance $::conf(vellemank8056,serialPort) $linkLabel "command" ""

      #--- je cree le lien ::link$linkno  (simule la presence de la librairie dynamique)
      set linkNo [::vellemank8056::simulLibraryCreateLink vellemank8056 $linkIndex ]
      #--- j'ajoute l'utilisation
      ##link$linkNo use add $deviceId $usage $comment
      #--- je stocke le commentaire d'utilisation
      ##set private(serialLink,$linkLabel,$deviceId,$usage) "$comment"
      #--- je rafraichis la liste
      ###::vellemank8056::refreshAvailableList

   } ]

   #--- je traite l'erreur
   if { $catchResult != 0 } {
      ::console::affiche_erreur "::vellemank8056::createPluginInstance \n $::errorInfo\n"
      if { $linkNo != 0 } {
         ::vellemank8056::deletePluginInstance $linkLabel $deviceId $usage
         set linkNo 0
      }
      if { $private(portHandle) != "" } {
         #--- je referme le port
         close $private(portHandle)
         set private(portHandle) ""
      }

   }
   set private(linkNo) $linkNo

   #--- Je configure les boutons de test
   configureConfigPage

   return $linkNo
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::deletePluginInstance { linkLabel deviceId usage } {
   variable private
   global audace

   #--- je ferme le port serie
   if { $private(portHandle) != "" } {
      close $private(portHandle)
      set private(portHandle) ""
   }

   #--- je supprime l'utilisation du port serie
   ::serialport::deletePluginInstance $::conf(vellemank8056,serialPort) $linkLabel "command"

   #--- je supprime le lien ::link$linkno  (simule la presence de la librairie dynamique)
   if { $private(linkNo) != 0 } {
      ::link$private(linkNo) close
   }
   set private(linkNo) 0

   #--- je supprime le commentaire d'utilisation de vellemank8056
   if { [info exists private(serialLink,$linkLabel,$deviceId,$usage)] } {
      unset private(serialLink,$linkLabel,$deviceId,$usage)
   }

   #--- Je configure les boutons de test
   configureConfigPage

   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::fillConfigPage { frm } {
   variable private
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   set widget(serialPort) $::conf(vellemank8056,serialPort)

   for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
      set widget(bit,$bitNo) $private(bit,$bitNo)
   }

   #--- je recupere la liste des ports disponibles
   set linkList [::confLink::getLinkLabels { "serialport" } ]
   #--- Je verifie le contenu de la liste
   if { [ llength $linkList ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $linkList $widget(serialPort) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(serialPort) [ lindex $linkList 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }


   #--- J'affiche la liste des links exclus
   frame $frm.port -borderwidth 0 -relief ridge

      label $frm.port.lab1 -text "$caption(vellemank8056,serialPort)"
      pack $frm.port.lab1  -side left -padx 5 -pady 5

      #--- Choix du port ou de la liaison
      ComboBox $frm.port.list \
         -width 9          \
         -height [ llength $linkList ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable ::vellemank8056::widget(serialPort) \
         -editable 0       \
         -values $linkList
      pack $frm.port.list  -anchor n -side left -padx 10 -pady 10

      #--- Bouton de configuration des ports et liaisons
      button $frm.port.refresh -text "$caption(vellemank8056,refresh)" -relief raised \
         -command "::vellemank8056::refreshSerialPortList"
      pack $frm.port.refresh -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Bouton arreter
      button $frm.port.stop -text "$caption(vellemank8056,stop)" -relief raised \
         -command "::vellemank8056::stopPlugin"
      pack $frm.port.stop -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   pack $frm.port -side top -fill x

   TitleFrame $frm.test -borderwidth 2 -relief ridge -text $::caption(vellemank8056,test)
      for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
         label $frm.test.lab$bitNo -text $bitNo
         grid $frm.test.lab$bitNo -in [$frm.test getframe] -row 0 -column $bitNo
         checkbutton  $frm.test.bit$bitNo -text $widget(bit,$bitNo) -indicatoron false \
            -offvalue "OFF" -onvalue "ON" \
            -variable ::vellemank8056::widget(bit,$bitNo) \
            -command "::vellemank8056::setBit $bitNo "
         grid $frm.test.bit$bitNo -in [$frm.test getframe] -row 1 -column $bitNo
         grid columnconfigure [$frm.test getframe]  $bitNo -minsize 40 -weight 0
      #pack $frm.test.bit1 -in [$frm.test getframe] -side left -fill none
      }


   pack $frm.test -side top -anchor w -fill none

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   configureConfigPage
}

#------------------------------------------------------------
# configureConfigPage
#   autorise/interdit les boutons de test
#
# Parameters:
#
# Return:
#  rien
#
#------------------------------------------------------------
proc ::vellemank8056::configureConfigPage { } {
   variable private

   if { $private(frm) != "" && [winfo exists $private(frm)] } {
      if {  [ ::vellemank8056::isReady ] == 1 } {
         #--- j'active les boutons de test
         for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
            $private(frm).test.lab$bitNo configure -state normal
            $private(frm).test.bit$bitNo configure -state normal
         }
         $private(frm).port.stop configure -state normal
      } else {
         for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
            $private(frm).test.lab$bitNo configure -state disabled
            $private(frm).test.bit$bitNo configure -state disabled
         }
         $private(frm).port.stop configure -state disabled
      }
   }
}

#------------------------------------------------------------
#  refreshSerialPortList
#     rafraichis la liste des port serie
#
#------------------------------------------------------------
proc ::vellemank8056::refreshSerialPortList {  } {
   variable private
   variable widget

   #--- je recupere la liste des port serie disponibles
   ::serialport::Recherche_Ports
   set linkList $::audace(list_com)

   #--- j'ajoute les ports serie occupe
   if { [lsearch -exact $linkList $::conf(vellemank8056,serialPort)] == -1 } {
      lappend linkList $::conf(vellemank8056,serialPort)
      set linkList [lsort $linkList]
   }

   #--- je copie la liste dans la combobox
   $private(frm).port.list configure -values $linkList -height [llength $linkList]
   #--- Je verifie le contenu de la liste
   if { [ llength $linkList ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      set index [ lsearch -exact $linkList $widget(serialPort) ]
      if { $index == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(serialPort) [ lindex $linkList 0 ]
      } else {
         #--- je selectionne la valeur
         $private(frm).port.list setvalue  "@$index"
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }
}


#------------------------------------------------------------
#  setBit
#     change un bit
#
#------------------------------------------------------------
proc ::vellemank8056::setBit { bitNo { bitValue "" } } {
   variable private
   variable widget

   if { [lsearch -exact "1 2 3 4 5 6 7 8" $bitNo ] == -1 } {
      error "Error bitNo=$bitNo Must be between 1 and 8 "
   }
   if { $bitValue == "" } {
      if { $widget(bit,$bitNo) == "ON" } {
         set bitValue 1
      } else {
         set bitValue 0
      }
   }
   ###console::disp "setBit $bitNo $bitValue\n"

   set address "1"  ;   # adresse de la carte  par defaut (s'il y a plusieurs cartes sur le meme port serie)
   if { $bitValue == 1 } {
      set command "S"
   } else {
      set command "C"
   }

   sendCommandK8056 $address $command $bitNo

   if { [winfo exists $private(frm).test.bit$bitNo] } {
      if { $bitValue == 1 } {
         set widget(bit,$bitNo) "ON"
      } else {
         set widget(bit,$bitNo) "OFF"
      }
      #--- je refraichis l'affichage du bouton de test
      $private(frm).test.bit$bitNo configure -text $widget(bit,$bitNo)
   }


}

#------------------------------------------------------------
# sendCommandK8056
#    envoie une commande au module K8056
#
# Parameters:
#  adresse : adresse du K8056 en binaire (1 ... 255)
#  command : commande S = set , C = clear, ... ( nombre en ASCII)
#  value   : valeurs associee � la commande en ASCII pour les commandes S,C,T  et en binaire pour les autres commandes
#
# Return:
#    rien
#
# Commande de la carte Velleman K8056 http://www.velleman.be/fr/en/home/
#
#  Format de la commande ( 5 octets)
#     Byte 1 : chr$(13)
#        d�but de paquet
#     Byte 2 : adresse (0 � 255)
#         numero du p�riph�rique . Indispensable si plusieurs K8056 sont connect�s sur le m�me port
#     Byte 3 : commande
#        E : Emergency stop all cards, regardless of address. Carefull, relays turned on by open collector inputs will not be turned off by this command.
#        D : Display address. All cards show their current address in a binary fashion. (LD1 : MSB, LD8 : LSB)
#        S : Set a relay. S instruction should be followed by relay # 1 to 8  (9 sets all relays at once)
#        C : Clear a relay. C instruction should be followed by a relay # 1 to 8  (9 clears all relays at once)
#        T : Toggle a relay. T instruction should be followed by a relay # 1 to 8.
#        A : Change the current address of a card. A instruction should be followes by the new address (1...255)
#        F : Force all cards to address 1 default.
#        B : Send a byte. Allows to control the status of all relays in one instruction, by sending abyte containing the relay status for each relay (MSB: realy1, LSB: relay8 )
#     Byte 4 : param�tre
#        parm�tre de la commande (voir ci-dessus)
#     Byte 5 : somme de contr�le
#       Compl�ment � deux de la somme des 4 bytes pr�c�dents
#       256 - (Byte1+ Byte2 + Byte3 + Byte4) MOD 256
#------------------------------------------------------------
proc ::vellemank8056::sendCommandK8056 { adresse command { value " " } } {
   variable private
   if { $command == "S" || $command == "C" || $command == "T" } {
      #--- je calcule la checksum pour les commandes dont la valeur est fournie das un caractere ASCII
      set checksum [expr 256 - int(fmod(13 + $adresse + [scan $command %c] + [scan $value %c] , 256)) ]
      #--- je prepare la ligne de commande
      set line [format "\xd%c%s%s%c" $adresse $command $value $checksum]
      ###console::disp "sendCommandK8056 address=$adresse command=$command value=$value checksum=$checksum ==> bytes=13 $adresse [scan $command %c] [scan $value %c] $checksum\n"
   } else {
      #--- je calcule la checksum dont la valeur est en binaire
      set checksum [expr 256 - int(fmod(13 + $adresse + [scan $command %c] + $value , 256)) ]
      #--- je prepare la ligne de commande
      set line [format "\xd%c%s%c%c" $adresse $command $value $checksum]
      ###console::disp "sendCommandK8056 address=$adresse command=$command value=$value checksum=$checksum => bytes=13 $adresse [scan $command %c] $value $checksum\n"
   }
   #--- j'envoie la commande
   puts -nonewline $private(portHandle) $line
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#
#   exemple :
#      getLinkIndex "K8056-COM1"
#   retourne
#      "COM1"
#------------------------------------------------------------
proc ::vellemank8056::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   if { [string first "$private(genericName)-" $linkLabel]  == 0 } {
      scan $linkLabel "$private(genericName)-%s" linkIndex
   }
   return $linkIndex
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des cartes vellemank8056 disponibles
#
#   exemple :
#   getLinkLabels
#   retourne   { "K8056-COM1" "K8056-COM2"}
#------------------------------------------------------------
proc ::vellemank8056::getLinkLabels { } {
   variable private

   set labels [list ]

   foreach comPort $::audace(list_com) {
      lappend labels "K8056-$comPort"
   }

   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "K8056-COM1"
#------------------------------------------------------------
proc ::vellemank8056::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du link
   return "$private(genericName)-$::conf(vellemank8056,serialPort)"
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::widgetToConf { } {
   variable widget
   variable private

   if { [isReady] == 1 } {
      #--- je supprime la liaison si elle existe deja
      ::vellemank8056::stopPlugin
   }
   set ::conf(vellemank8056,serialPort) $widget(serialPort)

   for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
      set private(bit,$bitNo) $widget(bit,$bitNo)
   }
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::selectConfigLink { linkLabel } {
   variable private

   #-- rien a faire car pour l'instant il n'y a qu'un seul velleman

}


#------------------------------------------------------------
#  simulCreateLink
#     cree une liaison purement TCL (sans libriairie dynamique)
#     cette procedure simule la librairie dynamique.
#  return rien
#------------------------------------------------------------
proc ::vellemank8056::simulLibraryCreateLink { libraryName linkIndex } {

   #--- je recherche le premier linkNo disponible
   set linkNo 1
   while { [info command ::link$linkNo ] == "::link$linkNo"  } {
      incr linkNo
   }

   set dollar "$"
   set command ""
   append command "proc ::link$linkNo { arg0 { arg1 \"\" } { arg2 \"\" } { arg3 \"\" }} {\n"
   append command "   switch ${dollar}arg0 {\n"
   append command "   drivername { return $libraryName }\n"
   append command "   close { rename ::link$linkNo \"\" \n" }
   append command "   index { return $linkIndex } \n"
   append command "   use  { ::confLink::simulLibraryUseLink $libraryName $linkNo ${dollar}arg1 ${dollar}arg2 ${dollar}arg3 } \n"
   append command "   char { ::${libraryName}::setChar ${dollar}arg1  } \n"
   append command "   bit  { ::${libraryName}::setBit  ${dollar}arg1 ${dollar}arg2  } \n"
   append command "   default  { error \"link$linkNo choose sub-command among  drivername close use char bit \" } \n"
   append command "   }\n"
   append command "}\n"

   eval $command
   return $linkNo
}

#------------------------------------------------------------
#  simulUseLink
#     ajoute, retourne ou supprime l'usage d'une liaison purement TCL (sans librairie dynamique)
#
#  return
#------------------------------------------------------------
proc ::vellemank8056::simulLibraryUseLink { libraryName linkNo  args } {
   variable private
   switch $command1 {
      add {
         set deviceId [lindex $args 0]
         set usage    [lindex $args 1]
         set comment  [lindex $args 2]
         set private($libraryName,$linkNo,use) $args
      }
      get {
         if { [info exists private($libraryName,$linkNo,use)] } {
            return $private($libraryName,$linkNo,use)
         } else {
            return ""
         }
      }
      remove {
         if { [info exists private($libraryName,$linkNo,use)] } {
            unset private($libraryName,$linkNo,use)
         }
      }
      default {
         error "# Usage: link$linkNo use add|get|remove ?options?"
      }
   }
}




