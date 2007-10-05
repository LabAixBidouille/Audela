#
# Fichier : obj_lune_go.tcl
# Description : Outil pour le lancement d'Objectif Lune
# Auteur : Robert DELMAS
# Mise a jour $Id: obj_lune_go.tcl,v 1.12 2007-10-05 16:57:26 robertdelmas Exp $
#

#============================================================
# Declaration du namespace obj_lune
#    initialise le namespace
#============================================================
namespace eval ::obj_lune {
   package provide obj_lune 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] obj_lune_go.cap ]
}

#------------------------------------------------------------
# ::obj_lune::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::obj_lune::getPluginTitle { } {
   global caption

   return "$caption(obj_lune_go,obj_lune)"
}

#------------------------------------------------------------
# ::obj_lune::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::obj_lune::getPluginHelp { } {
   return "obj_lune.htm"
}

#------------------------------------------------------------
# ::obj_lune::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::obj_lune::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::obj_lune::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::obj_lune::getPluginDirectory { } {
   return "obj_lune"
}

#------------------------------------------------------------
# ::obj_lune::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::obj_lune::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::obj_lune::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::obj_lune::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "moon" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::obj_lune::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::obj_lune::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::obj_lune::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::obj_lune::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Img pour visualiser les cartes de la Lune au format jpg
   package require Img 1.3
   #--- Charge le source de la fenetre Objectif Lune
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool obj_lune obj_lune.tcl ]\""
}

#------------------------------------------------------------
# ::obj_lune::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::obj_lune::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::obj_lune::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::obj_lune::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::obj_lune::run
}

#------------------------------------------------------------
# ::obj_lune::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::obj_lune::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

