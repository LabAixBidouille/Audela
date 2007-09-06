#
# Fichier : ouranos.tcl
# Description : Configuration de la monture Ouranos
# Auteur : Robert DELMAS
# Mise a jour $Id: ouranos.tcl,v 1.2 2007-09-06 17:07:54 robertdelmas Exp $
#

namespace eval ::ouranos {
   package provide ouranos 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ouranos.cap ]
}

#
# ::ouranos::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::ouranos::getPluginTitle { } {
   global caption

   return "$caption(ouranos,monture)"
}

#
#  ::ouranos::getPluginHelp
#     Retourne la documentation du driver
#
proc ::ouranos::getPluginHelp { } {
   return "ouranos.htm"
}

#
# ::ouranos::getPluginType
#    Retourne le type de driver
#
proc ::ouranos::getPluginType { } {
   return "mount"
}

#
# ::ouranos::initPlugin
#    Initialise les variables conf(ouranos,...)
#
proc ::ouranos::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture Ouranos
   if { ! [ info exists conf(ouranos,port) ] }        { set conf(ouranos,port)        [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(ouranos,cod_ra) ] }      { set conf(ouranos,cod_ra)      "32768" }
   if { ! [ info exists conf(ouranos,cod_dec) ] }     { set conf(ouranos,cod_dec)     "32768" }
   if { ! [ info exists conf(ouranos,freq) ] }        { set conf(ouranos,freq)        "1" }
   if { ! [ info exists conf(ouranos,init) ] }        { set conf(ouranos,init)        "0" }
   if { ! [ info exists conf(ouranos,inv_ra) ] }      { set conf(ouranos,inv_ra)      "1" }
   if { ! [ info exists conf(ouranos,inv_dec) ] }     { set conf(ouranos,inv_dec)     "1" }
   if { ! [ info exists conf(ouranos,show_coord) ] }  { set conf(ouranos,show_coord)  "1" }
   if { ! [ info exists conf(ouranos,tjrsvisible) ] } { set conf(ouranos,tjrsvisible) "0" }

   #--- Initialisation des fenetres d'affichage des coordonnees AD et Dec.
   if { ! [ info exists conf(ouranos,wmgeometry) ] }     { set conf(ouranos,wmgeometry)     "200x70+640+268" }
   if { ! [ info exists conf(ouranos,x10,wmgeometry) ] } { set conf(ouranos,x10,wmgeometry) "850x500+0+0" }
}

#
# ::ouranos::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::ouranos::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture Ouranos dans le tableau private(...)

}

#
# ::ouranos::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::ouranos::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture Ouranos dans le tableau conf(ouranos,...)

}

#
# ::ouranos::fillConfigPage
#    Interface de configuration de la monture Ouranos
#
proc ::ouranos::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::ouranos::configureTelescope
#    Configure la monture Ouranos en fonction des donnees contenues dans les variables conf(ouranos,...)
#
proc ::ouranos::configureTelescope { telItem } {
   global caption conf confCam

}

