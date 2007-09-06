#
# Fichier : lx200.tcl
# Description : Configuration de la monture LX200
# Auteur : Robert DELMAS
# Mise a jour $Id: lx200.tcl,v 1.2 2007-09-06 17:07:41 robertdelmas Exp $
#

namespace eval ::lx200 {
   package provide lx200 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] lx200.cap ]
}

#
# ::lx200::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::lx200::getPluginTitle { } {
   global caption

   return "$caption(lx200,monture)"
}

#
#  ::lx200::getPluginHelp
#     Retourne la documentation du driver
#
proc ::lx200::getPluginHelp { } {
   return "lx200.htm"
}

#
# ::lx200::getPluginType
#    Retourne le type de driver
#
proc ::lx200::getPluginType { } {
   return "mount"
}

#
# ::lx200::initPlugin
#    Initialise les variables conf(lx200,...)
#
proc ::lx200::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [::confLink::getLinkLabels { "serialport" "audinet" } ]

   #--- Initialise les variables de la monture LX200
   if { ! [ info exists conf(lx200,port) ] }            { set conf(lx200,port)            [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(lx200,modele) ] }          { set conf(lx200,modele)          "LX200" }
   if { ! [ info exists conf(lx200,format) ] }          { set conf(lx200,format)          "1" }
   if { ! [ info exists conf(lx200,ite-lente_tempo) ] } { set conf(lx200,ite-lente_tempo) "300" }
}

#
# ::lx200::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::lx200::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture LX200 dans le tableau private(...)

}

#
# ::lx200::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::lx200::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture LX200 dans le tableau conf(lx200,...)

}

#
# ::lx200::fillConfigPage
#    Interface de configuration de la monture LX200
#
proc ::lx200::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::lx200::configureTelescope
#    Configure la monture LX200 en fonction des donnees contenues dans les variables conf(lx200,...)
#
proc ::lx200::configureTelescope { telItem } {
   global caption conf confCam

}

