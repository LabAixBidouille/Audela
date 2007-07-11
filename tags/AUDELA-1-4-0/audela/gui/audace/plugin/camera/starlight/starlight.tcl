#
# Fichier : starlight.tcl
# Description : Configuration de la camera Starlight
# Auteur : Robert DELMAS
# Mise a jour $Id: starlight.tcl,v 1.1 2007-06-17 14:05:41 robertdelmas Exp $
#

namespace eval ::starlight {
   package provide starlight 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] starlight.cap ]
}

#
# ::starlight::getPluginType
#    Retourne le type de driver
#
proc ::starlight::getPluginType { } {
   return "camera"
}

#
# ::starlight::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::starlight::getPluginTitle { } {
   global caption

   return "$caption(starlight,camera)"
}

#
# ::starlight::initPlugin
#    Initialise les variables conf(starlight,...)
#
proc ::starlight::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera Starlight
   if { ! [ info exists conf(starlight,acc) ] }    { set conf(starlight,acc)    "0" }
   if { ! [ info exists conf(starlight,mirh) ] }   { set conf(starlight,mirh)   "0" }
   if { ! [ info exists conf(starlight,mirv) ] }   { set conf(starlight,mirv)   "0" }
   if { ! [ info exists conf(starlight,modele) ] } { set conf(starlight,modele) "MX516" }
   if { ! [ info exists conf(starlight,port) ] }   { set conf(starlight,port)   "LPT1:" }
}

#
# ::starlight::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::starlight::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Starlight dans le tableau private(...)

}

#
# ::starlight::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::starlight::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Starlight dans le tableau conf(starlight,...)

}

#
# ::starlight::fillConfigPage
#    Interface de configuration de la camera Starlight
#
proc ::starlight::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::starlight::configureCamera
#    Configure la camera Starlight en fonction des donnees contenues dans les variables conf(starlight,...)
#
proc ::starlight::configureCamera { camItem } {
   global caption conf confCam

}

#
# ::starlight::getPluginProperty
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
proc ::starlight::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 0 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList      { return [ list "" ] }
   }
}

