#
# Fichier : ascom.tcl
# Description : Configuration de la monture ASCOM
# Auteur : Robert DELMAS
# Mise a jour $Id: ascom.tcl,v 1.2 2007-09-06 17:06:54 robertdelmas Exp $
#

namespace eval ::ascom {
   package provide ascom 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ascom.cap ]
}

#
# ::ascom::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::ascom::getPluginTitle { } {
   global caption

   return "$caption(ascom,monture)"
}

#
#  ::ascom::getPluginHelp
#     Retourne la documentation du driver
#
proc ::ascom::getPluginHelp { } {
   return "ascom.htm"
}

#
# ::ascom::getPluginType
#    Retourne le type de driver
#
proc ::ascom::getPluginType { } {
   return "mount"
}

#
# ::ascom::initPlugin
#    Initialise les variables conf(ascom,...)
#
proc ::ascom::initPlugin { } {
   global conf confTel

   #--- Drivers ASCOM installes sur le PC
   set confTel(ascom_drivers) ""
   if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
      set erreur [ catch { ::registry keys "HKEY_LOCAL_MACHINE\\SOFTWARE\\ASCOM\\Telescope Drivers" } msg ]
      if { $erreur == "0" } {
         foreach key [ ::registry keys "HKEY_LOCAL_MACHINE\\SOFTWARE\\ASCOM\\Telescope Drivers" ] {
            if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\SOFTWARE\\ASCOM\\Telescope Drivers\\$key" "" } r ] == 0 } {
               lappend confTel(ascom_drivers) [list $r $key]
            }
         }
      } else {
         set erreur [ catch { ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers" } msg ]
         if { $erreur == "0" } {
            foreach key [ ::registry keys "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers" ] {
               if { [ catch { ::registry get "HKEY_LOCAL_MACHINE\\Software\\ASCOM\\Telescope Drivers\\$key" "" } r ] == 0 } {
                  lappend confTel(ascom_drivers) [list $r $key]
               }
            }
         }
      }
   }

   #--- Initialise les variables de la monture ASCOM
   if { ! [ info exists conf(ascom,driver) ] } { set conf(ascom,driver) [ lindex $confTel(ascom_drivers) 0 ] }
}

#
# ::ascom::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ascom::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture ASCOM dans le tableau private(...)

}

#
# ::ascom::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ascom::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture ASCOM dans le tableau conf(ascom,...)

}

#
# ::ascom::fillConfigPage
#    Interface de configuration de la monture ASCOM
#
proc ::ascom::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::ascom::configureTelescope
#    Configure la monture ASCOM en fonction des donnees contenues dans les variables conf(ascom,...)
#
proc ::ascom::configureTelescope { telItem } {
   global caption conf confCam

}

