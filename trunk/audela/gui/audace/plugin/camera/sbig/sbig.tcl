#
# Fichier : sbig.tcl
# Description : Configuration de la camera Andor
# Auteur : Robert DELMAS
# Mise a jour $Id: sbig.tcl,v 1.1 2007-06-17 14:05:40 robertdelmas Exp $
#

namespace eval ::sbig {
   package provide sbig 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] sbig.cap ]
}

#
# ::sbig::getPluginType
#    Retourne le type de driver
#
proc ::sbig::getPluginType { } {
   return "camera"
}

#
# ::sbig::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::sbig::getPluginTitle { } {
   global caption

   return "$caption(sbig,camera)"
}

#
# ::sbig::initPlugin
#    Initialise les variables conf(sbig,...)
#
proc ::sbig::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera Andor
   if { ! [ info exists conf(sbig,cool) ] }     { set conf(sbig,cool)     "0" }
   if { ! [ info exists conf(sbig,foncobtu) ] } { set conf(sbig,foncobtu) "2" }
   if { ! [ info exists conf(sbig,host) ] }     { set conf(sbig,host)     "192.168.0.2" }
   if { ! [ info exists conf(sbig,mirh) ] }     { set conf(sbig,mirh)     "0" }
   if { ! [ info exists conf(sbig,mirv) ] }     { set conf(sbig,mirv)     "0" }
   if { ! [ info exists conf(sbig,port) ] }     { set conf(sbig,port)     "LPT1:" }
   if { ! [ info exists conf(sbig,temp) ] }     { set conf(sbig,temp)     "0" }
}

#
# ::sbig::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::sbig::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Andor dans le tableau private(...)

}

#
# ::sbig::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::sbig::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Andor dans le tableau conf(sbig,...)

}

#
# ::sbig::fillConfigPage
#    Interface de configuration de la camera Andor
#
proc ::sbig::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::sbig::configureCamera
#    Configure la camera Andor en fonction des donnees contenues dans les variables conf(sbig,...)
#
proc ::sbig::configureCamera { camItem } {
   global caption conf confCam

}

#
# ::sbig::getPluginProperty
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
proc ::sbig::getPluginProperty { camItem propertyName } {
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
         #--- O + F + S
         return [ list $::caption(sbig,obtu_ouvert) $::caption(sbig,obtu_ferme) $::caption(sbig,obtu_synchro) ]
      }
   }
}

