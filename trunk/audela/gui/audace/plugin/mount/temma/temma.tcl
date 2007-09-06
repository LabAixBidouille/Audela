#
# Fichier : temma.tcl
# Description : Fenetre de configuration pour le parametrage du suivi d'objets mobiles pour le telescope Temma
# Auteur : Robert DELMAS
# Mise a jour $Id: temma.tcl,v 1.9 2007-09-06 17:08:10 robertdelmas Exp $
#

namespace eval ::temma {
   package provide temma 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] temma.cap ]
}

#
# ::temma::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::temma::getPluginTitle { } {
   global caption

   return "$caption(temma,monture)"
}

#
#  ::temma::getPluginHelp
#     Retourne la documentation du driver
#
proc ::temma::getPluginHelp { } {
   return "temma.htm"
}

#
# ::temma::getPluginType
#    Retourne le type de driver
#
proc ::temma::getPluginType { } {
   return "mount"
}

#
# ::temma::initPlugin
#    Initialise les variables conf(temma,...)
#
proc ::temma::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Temma
   if { ! [ info exists conf(temma,port) ] }       { set conf(temma,port)       [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(temma,correc_AD) ] }  { set conf(temma,correc_AD)  "50" }
   if { ! [ info exists conf(temma,correc_Dec) ] } { set conf(temma,correc_Dec) "50" }
   if { ! [ info exists conf(temma,liaison) ] }    { set conf(temma,liaison)    "1" }
   if { ! [ info exists conf(temma,modele) ] }     { set conf(temma,modele)     "0" }
   if { ! [ info exists conf(temma,suivi_ad) ] }   { set conf(temma,suivi_ad)   "0" }
   if { ! [ info exists conf(temma,suivi_dec) ] }  { set conf(temma,suivi_dec)  "0" }
   if { ! [ info exists conf(temma,type) ] }       { set conf(temma,type)       "0" }
}

#
# ::temma::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::temma::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Temma dans le tableau private(...)

}

#
# ::temma::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::temma::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Temma dans le tableau conf(temma,...)

}

#
# ::temma::fillConfigPage
#    Interface de configuration de la monture Temma
#
proc ::temma::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::temma::configureTelescope
#    Configure la monture Temma en fonction des donnees contenues dans les variables conf(temma,...)
#
proc ::temma::configureTelescope { telItem } {
   global caption conf confCam

}

