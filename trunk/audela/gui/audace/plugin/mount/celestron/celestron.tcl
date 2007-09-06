#
# Fichier : celestron.tcl
# Description : Configuration de la monture Celestron
# Auteur : Robert DELMAS
# Mise a jour $Id: celestron.tcl,v 1.2 2007-09-06 17:07:22 robertdelmas Exp $
#

namespace eval ::celestron {
   package provide celestron 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] celestron.cap ]
}

#
# ::celestron::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::celestron::getPluginTitle { } {
   global caption

   return "$caption(celestron,monture)"
}

#
#  ::celestron::getPluginHelp
#     Retourne la documentation du driver
#
proc ::celestron::getPluginHelp { } {
   return "celestron.htm"
}

#
# ::celestron::getPluginType
#    Retourne le type de driver
#
proc ::celestron::getPluginType { } {
   return "mount"
}

#
# ::celestron::initPlugin
#    Initialise les variables conf(celestron,...)
#
proc ::celestron::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Celestron
   if { ! [ info exists conf(celestron,port) ] }   { set conf(celestron,port)   [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(celestron,format) ] } { set conf(celestron,format) "1" }
}

#
# ::celestron::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::celestron::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Celestron dans le tableau private(...)

}

#
# ::celestron::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::celestron::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Celestron dans le tableau conf(celestron,...)

}

#
# ::celestron::fillConfigPage
#    Interface de configuration de la monture Celestron
#
proc ::celestron::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::celestron::configureTelescope
#    Configure la monture Celestron en fonction des donnees contenues dans les variables conf(celestron,...)
#
proc ::celestron::configureTelescope { telItem } {
   global caption conf confCam

}

