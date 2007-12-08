#
# Fichier : audecom.tcl
# Description : Parametrage et pilotage de la carte AudeCom (Ex-Kauffmann)
# Auteur : Robert DELMAS
# Mise a jour $Id: audecom.tcl,v 1.11 2007-12-08 22:55:14 robertdelmas Exp $
#

namespace eval ::audecom {
   package provide audecom 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] audecom.cap ]
}

#
# ::audecom::getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::audecom::getPluginTitle { } {
   global caption

   return "$caption(audecom,monture)"
}

#
#  ::audecom::getPluginHelp
#     Retourne la documentation du plugin
#
proc ::audecom::getPluginHelp { } {
   return "audecom.htm"
}

#
# ::audecom::getPluginType
#    Retourne le type du plugin
#
proc ::audecom::getPluginType { } {
   return "mount"
}

#
# ::audecom::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::audecom::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::audecom::initPlugin
#    Initialise les variables conf(audecom,...)
#
proc ::audecom::initPlugin { } {
   global conf

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]

   #--- Initialise les variables de la monture AudeCom
   if { ! [ info exists conf(audecom,port) ] }         { set conf(audecom,port)         [ lindex $list_connexion 0 ] }
   if { ! [ info exists conf(audecom,ad) ] }           { set conf(audecom,ad)           "999999" }
   if { ! [ info exists conf(audecom,dec) ] }          { set conf(audecom,dec)          "999999" }
   if { ! [ info exists conf(audecom,dep_val) ] }      { set conf(audecom,dep_val)      "250" }
   if { ! [ info exists conf(audecom,german) ] }       { set conf(audecom,german)       "0" }
   if { ! [ info exists conf(audecom,intra_extra) ] }  { set conf(audecom,intra_extra)  "0" }
   if { ! [ info exists conf(audecom,inv_rot) ] }      { set conf(audecom,inv_rot)      "0" }
   if { ! [ info exists conf(audecom,gotopluslong) ] } { set conf(audecom,gotopluslong) "0" }
   if { ! [ info exists conf(audecom,king) ] }         { set conf(audecom,king)         "1" }
   if { ! [ info exists conf(audecom,limp) ] }         { set conf(audecom,limp)         "50" }
   if { ! [ info exists conf(audecom,maxad) ] }        { set conf(audecom,maxad)        "16" }
   if { ! [ info exists conf(audecom,maxdec) ] }       { set conf(audecom,maxdec)       "16" }
   if { ! [ info exists conf(audecom,mobile) ] }       { set conf(audecom,mobile)       "0" }
   if { ! [ info exists conf(audecom,pec) ] }          { set conf(audecom,pec)          "1" }
   if { ! [ info exists conf(audecom,rat_ad) ] }       { set conf(audecom,rat_ad)       "0.5" }
   if { ! [ info exists conf(audecom,rat_dec) ] }      { set conf(audecom,rat_dec)      "0.5" }
   if { ! [ info exists conf(audecom,rpec) ] }         { set conf(audecom,rpec)         "6" }
   if { ! [ info exists conf(audecom,type) ] }         { set conf(audecom,type)         "2" }
   if { ! [ info exists conf(audecom,t0) ] }           { set conf(audecom,t0)           "192" }
   if { ! [ info exists conf(audecom,t1) ] }           { set conf(audecom,t1)           "192" }
   if { ! [ info exists conf(audecom,t2) ] }           { set conf(audecom,t2)           "192" }
   if { ! [ info exists conf(audecom,t3) ] }           { set conf(audecom,t3)           "192" }
   if { ! [ info exists conf(audecom,t4) ] }           { set conf(audecom,t4)           "192" }
   if { ! [ info exists conf(audecom,t5) ] }           { set conf(audecom,t5)           "192" }
   if { ! [ info exists conf(audecom,t6) ] }           { set conf(audecom,t6)           "192" }
   if { ! [ info exists conf(audecom,t7) ] }           { set conf(audecom,t7)           "192" }
   if { ! [ info exists conf(audecom,t8) ] }           { set conf(audecom,t8)           "192" }
   if { ! [ info exists conf(audecom,t9) ] }           { set conf(audecom,t9)           "192" }
   if { ! [ info exists conf(audecom,t10) ] }          { set conf(audecom,t10)          "192" }
   if { ! [ info exists conf(audecom,t11) ] }          { set conf(audecom,t11)          "192" }
   if { ! [ info exists conf(audecom,t12) ] }          { set conf(audecom,t12)          "192" }
   if { ! [ info exists conf(audecom,t13) ] }          { set conf(audecom,t13)          "192" }
   if { ! [ info exists conf(audecom,t14) ] }          { set conf(audecom,t14)          "192" }
   if { ! [ info exists conf(audecom,t15) ] }          { set conf(audecom,t15)          "192" }
   if { ! [ info exists conf(audecom,t16) ] }          { set conf(audecom,t16)          "192" }
   if { ! [ info exists conf(audecom,t17) ] }          { set conf(audecom,t17)          "192" }
   if { ! [ info exists conf(audecom,t18) ] }          { set conf(audecom,t18)          "192" }
   if { ! [ info exists conf(audecom,t19) ] }          { set conf(audecom,t19)          "192" }
   if { ! [ info exists conf(audecom,vitesse) ] }      { set conf(audecom,vitesse)      "30" }

   #--- Initialisation des parametres de la monture lies a la reduction des axes AD et Dec. (par editeur de texte)
   if { ! [ info exists conf(audecom,dlimp) ] }        { set conf(audecom,dlimp)        "100" }
   if { ! [ info exists conf(audecom,dlimpmax) ] }     { set conf(audecom,dlimpmax)     "255" }
   if { ! [ info exists conf(audecom,dlimpmin) ] }     { set conf(audecom,dlimpmin)     "0" }
   if { ! [ info exists conf(audecom,dlimprecouv) ] }  { set conf(audecom,dlimprecouv)  "192" }
   if { ! [ info exists conf(audecom,dmaxad) ] }       { set conf(audecom,dmaxad)       "16" }
   if { ! [ info exists conf(audecom,dmaxadmax) ] }    { set conf(audecom,dmaxadmax)    "16" }
   if { ! [ info exists conf(audecom,dmaxadmin) ] }    { set conf(audecom,dmaxadmin)    "4" }
   if { ! [ info exists conf(audecom,dmaxdec) ] }      { set conf(audecom,dmaxdec)      "16" }
   if { ! [ info exists conf(audecom,dmaxdecmax) ] }   { set conf(audecom,dmaxdecmax)   "16" }
   if { ! [ info exists conf(audecom,dmaxdecmin) ] }   { set conf(audecom,dmaxdecmin)   "4" }
   if { ! [ info exists conf(audecom,dsuividelta) ] }  { set conf(audecom,dsuividelta)  "192" }
   if { ! [ info exists conf(audecom,dsuivinom) ] }    { set conf(audecom,dsuivinom)    "192" }
   if { ! [ info exists conf(audecom,dsuivinommax) ] } { set conf(audecom,dsuivinommax) "255" }
   if { ! [ info exists conf(audecom,dsuivinommin) ] } { set conf(audecom,dsuivinommin) "130" }
   if { ! [ info exists conf(audecom,dsuivinomxt0) ] } { set conf(audecom,dsuivinomxt0) "37.9159872" }
   if { ! [ info exists conf(audecom,internom) ] }     { set conf(audecom,internom)     "197.4791" }
}

#
# ::audecom::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::audecom::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture AudeCom dans le tableau private(...)

}

#
# ::audecom::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::audecom::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture AudeCom dans le tableau conf(audecom,...)

}

#
# ::audecom::fillConfigPage
#    Interface de configuration de la monture AudeCom
#
proc ::audecom::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::audecom::configureTelescope
#    Configure la monture AudeCom en fonction des donnees contenues dans les variables conf(audecom,...)
#
proc ::audecom::configureTelescope { telItem } {
   global caption conf

}

