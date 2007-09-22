#
# Fichier : andor.tcl
# Description : Configuration de la camera Andor
# Auteur : Robert DELMAS
# Mise a jour $Id: andor.tcl,v 1.3 2007-09-22 06:38:24 robertdelmas Exp $
#

namespace eval ::andor {
   package provide andor 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] andor.cap ]
}

#
# ::andor::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::andor::getPluginTitle { } {
   global caption

   return "$caption(andor,camera)"
}

#
#  ::andor::getPluginHelp
#     Retourne la documentation du driver
#
proc ::andor::getPluginHelp { } {
   return "andor.htm"
}

#
# ::andor::getPluginType
#    Retourne le type de driver
#
proc ::andor::getPluginType { } {
   return "camera"
}

#
# ::andor::getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::andor::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# ::andor::initPlugin
#    Initialise les variables conf(andor,...)
#
proc ::andor::initPlugin { } {
   global audace conf

   #--- Initialise les variables de la camera Andor
   if { ! [ info exists conf(andor,cool) ] }        { set conf(andor,cool)        "0" }
   if { ! [ info exists conf(andor,foncobtu) ] }    { set conf(andor,foncobtu)    "2" }
   if { ! [ info exists conf(andor,config) ] }      { set conf(andor,config)      [ file join $audace(rep_install) bin ] }
   if { ! [ info exists conf(andor,mirh) ] }        { set conf(andor,mirh)        "0" }
   if { ! [ info exists conf(andor,mirv) ] }        { set conf(andor,mirv)        "0" }
   if { ! [ info exists conf(andor,temp) ] }        { set conf(andor,temp)        "-50" }
   if { ! [ info exists conf(andor,ouvert_obtu) ] } { set conf(andor,ouvert_obtu) "0" }
   if { ! [ info exists conf(andor,ferm_obtu) ] }   { set conf(andor,ferm_obtu)   "30" }
}

#
# ::andor::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::andor::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Andor dans le tableau private(...)

}

#
# ::andor::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::andor::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Andor dans le tableau conf(andor,...)

}

#
# ::andor::fillConfigPage
#    Interface de configuration de la camera Andor
#
proc ::andor::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::andor::configureCamera
#    Configure la camera Andor en fonction des donnees contenues dans les variables conf(andor,...)
#
proc ::andor::configureCamera { camItem } {
   global caption conf confCam

}

#
# ::andor::getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasShutter :       Retourne l'existence d'un obturateur (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# shutterList :      Retourne l'etat de l'obturateur (O : Ouvert, F : Ferme, S : Synchro)
#
proc ::andor::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList     {
         #--- O + F + S - A confirmer avec le materiel
         return [ list $::caption(andor,obtu_ouvert) $::caption(andor,obtu_ferme) $::caption(andor,obtu_synchro) ]
      }
   }
}

