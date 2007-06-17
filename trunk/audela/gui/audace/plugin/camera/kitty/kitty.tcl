#
# Fichier : kitty.tcl
# Description : Configuration de la camera Kitty
# Auteur : Robert DELMAS
# Mise a jour $Id: kitty.tcl,v 1.1 2007-06-17 14:05:40 robertdelmas Exp $
#

namespace eval ::kitty {
   package provide kitty 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] kitty.cap ]
}

#
# ::kitty::getPluginType
#    Retourne le type de driver
#
proc ::kitty::getPluginType { } {
   return "camera"
}

#
# ::kitty::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::kitty::getPluginTitle { } {
   global caption

   return "$caption(kitty,camera)"
}

#
# ::kitty::initPlugin
#    Initialise les variables conf(kitty,...)
#
proc ::kitty::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera Kitty
   if { ! [ info exists conf(kitty,captemp) ] } { set conf(kitty,captemp) "0" }
   if { ! [ info exists conf(kitty,mirh) ] }    { set conf(kitty,mirh)    "0" }
   if { ! [ info exists conf(kitty,mirv) ] }    { set conf(kitty,mirv)    "0" }
   if { ! [ info exists conf(kitty,modele) ] }  { set conf(kitty,modele)  "237" }
   if { ! [ info exists conf(kitty,port) ] }    { set conf(kitty,port)    "LPT1:" }
   if { ! [ info exists conf(kitty,res) ] }     { set conf(kitty,res)     "12 bits" }
   if { ! [ info exists conf(kitty,on_off) ] }  { set conf(kitty,on_off)  "1" }
}

#
# ::kitty::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::kitty::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Kitty dans le tableau private(...)

}

#
# ::kitty::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::kitty::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Kitty dans le tableau conf(kitty,...)

}

#
# ::kitty::fillConfigPage
#    Interface de configuration de la camera Kitty
#
proc ::kitty::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::kitty::configureCamera
#    Configure la camera Kitty en fonction des donnees contenues dans les variables conf(kitty,...)
#
proc ::kitty::configureCamera { camItem } {
   global caption conf confCam

}

#
# ::kitty::getPluginProperty
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
proc ::kitty::getPluginProperty { camItem propertyName } {
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

