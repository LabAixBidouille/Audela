#
# Fichier : hisis.tcl
# Description : Configuration de la camera Hi-SIS
# Auteur : Robert DELMAS
# Mise a jour $Id: hisis.tcl,v 1.1 2007-06-17 14:05:39 robertdelmas Exp $
#

namespace eval ::hisis {
   package provide hisis 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] hisis.cap ]
}

#
# ::hisis::getPluginType
#    Retourne le type de driver
#
proc ::hisis::getPluginType { } {
   return "camera"
}

#
# ::hisis::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::hisis::getPluginTitle { } {
   global caption

   return "$caption(hisis,camera)"
}

#
# ::hisis::initPlugin
#    Initialise les variables conf(hisis,...)
#
proc ::hisis::initPlugin { } {
   global conf

   #--- Initialise les variables de la camera Hi-SIS
   if { ! [ info exists conf(hisis,delai_a) ] }  { set conf(hisis,delai_a)  "5" }
   if { ! [ info exists conf(hisis,delai_b) ] }  { set conf(hisis,delai_b)  "2" }
   if { ! [ info exists conf(hisis,delai_c) ] }  { set conf(hisis,delai_c)  "7" }
   if { ! [ info exists conf(hisis,foncobtu) ] } { set conf(hisis,foncobtu) "2" }
   if { ! [ info exists conf(hisis,mirh) ] }     { set conf(hisis,mirh)     "0" }
   if { ! [ info exists conf(hisis,mirv) ] }     { set conf(hisis,mirv)     "0" }
   if { ! [ info exists conf(hisis,modele) ] }   { set conf(hisis,modele)   "22" }
   if { ! [ info exists conf(hisis,port) ] }     { set conf(hisis,port)     "LPT1:" }
   if { ! [ info exists conf(hisis,res) ] }      { set conf(hisis,res)      "12 bits" }
}

#
# ::hisis::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::hisis::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Hi-SIS dans le tableau private(...)

}

#
# ::hisis::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::hisis::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Hi-SIS dans le tableau conf(hisis,...)

}

#
# ::hisis::fillConfigPage
#    Interface de configuration de la camera Hi-SIS
#
proc ::hisis::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::hisis::configureCamera
#    Configure la camera Hi-SIS en fonction des donnees contenues dans les variables conf(hisis,...)
#
proc ::hisis::configureCamera { camItem } {
   global caption conf confCam

}

#
# ::hisis::getPluginProperty
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
proc ::hisis::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       {
         if { $::conf(hisis,modele) == "11" } {
            return 0
         } else {
            return 1
         }
      }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList      {
         if { $::conf(hisis,modele) == "11" } {
            return 0
         } else {
            #--- O + F + S - A confirmer avec le materiel
            return [ list $::caption(hisis,obtu_ouvert) $::caption(hisis,obtu_ferme) $::caption(hisis,obtu_synchro) ]
         }
      }
   }
}

