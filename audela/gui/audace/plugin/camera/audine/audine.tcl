#
# Fichier : audine.tcl
# Description : Configuration de la camera Audine
# Auteur : Robert DELMAS
# Mise a jour $Id: audine.tcl,v 1.2 2007-09-05 21:05:32 robertdelmas Exp $
#

namespace eval ::audine {
   package provide audine 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] audine.cap ]
}

#
# ::audine::getPluginTitle
#    Retourne le label du driver dans la langue de l'utilisateur
#
proc ::audine::getPluginTitle { } {
   global caption

   return "$caption(audine,camera)"
}

#
#  ::audine::getPluginHelp
#     Retourne la documentation du driver
#
proc ::audine::getPluginHelp { } {
   return "audine.htm"
}

#
# ::audine::getPluginType
#    Retourne le type de driver
#
proc ::audine::getPluginType { } {
   return "camera"
}

#
# ::audine::initPlugin
#    Initialise les variables conf(audine,...)
#
proc ::audine::initPlugin { } {
   global caption conf

   #--- Initialise les variables de la camera Audine
   if { ! [ info exists conf(audine,ampli_ccd) ] } { set conf(audine,ampli_ccd) "1" }
   if { ! [ info exists conf(audine,can) ] }       { set conf(audine,can)       "$caption(audine,can_ad976a)" }
   if { ! [ info exists conf(audine,ccd) ] }       { set conf(audine,ccd)       "$caption(audine,kaf400)" }
   if { ! [ info exists conf(audine,foncobtu) ] }  { set conf(audine,foncobtu)  "2" }
   if { ! [ info exists conf(audine,mirh) ] }      { set conf(audine,mirh)      "0" }
   if { ! [ info exists conf(audine,mirv) ] }      { set conf(audine,mirv)      "0" }
   if { ! [ info exists conf(audine,port) ] }      { set conf(audine,port)      "LPT1:" }
   if { ! [ info exists conf(audine,typeobtu) ] }  { set conf(audine,typeobtu)  "$caption(audine,obtu_audine)" }
}

#
# ::audine::confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::audine::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la camera Audine dans le tableau private(...)

}

#
# ::audine::widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::audine::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la camera Audine dans le tableau conf(audine,...)

}

#
# ::audine::fillConfigPage
#    Interface de configuration de la camera Audine
#
proc ::audine::fillConfigPage { frm } {
   variable private
   global audace caption color

}

#
# ::audine::configureCamera
#    Configure la camera Audine en fonction des donnees contenues dans les variables conf(audine,...)
#
proc ::audine::configureCamera { camItem } {
   global caption conf confCam

}

#
# ::audine::getPluginProperty
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
proc ::audine::getPluginProperty { camItem propertyName } {
   switch $propertyName {
      binningList      {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
            "quickaudine"  { return [ list 1x1 2x2 3x3 4x4 ] }
            "audinet"      { return [ list 1x1 2x2 3x3 4x4 ] }
            "ethernaude"   { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
         }
      }
      binningXListScan {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ] }
            "quickaudine"  { return [ list "" ] }
            "audinet"      { return [ list "" ] }
            "ethernaude"   { return [ list 1 2 ] }
         }
      }
      binningYListScan {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ] }
            "quickaudine"  { return [ list "" ] }
            "audinet"      { return [ list "" ] }
            "ethernaude"   { return [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 \
                                               21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 \
                                               41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 \
                                               61 62 63 64 ] }
         }
      }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          {
         switch -exact [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" { return 1 }
            "quickaudine"  { return 0 }
            "audinet"      { return 0 }
            "ethernaude"   { return 1 }
         }
      }
      hasShutter       { return 1 }
      hasVideo         {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "ethernaude" { return 2 }
            default      { return 0 }
         }
      }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      shutterList      {
         switch [ ::confLink::getLinkNamespace $::conf(audine,port) ] {
            "parallelport" {
               #--- O + F + S
               return [ list $::caption(audine,obtu_ouvert) $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
            "quickaudine" {
               #--- F + S
               return [ list $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
            "audinet" {
               #--- O + F + S
               return [ list $::caption(audine,obtu_ouvert) $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
            "ethernaude" {
               #--- F + S
               return [ list $::caption(audine,obtu_ferme) $::caption(audine,obtu_synchro) ]
            }
         }
      }
   }
}

