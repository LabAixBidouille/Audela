#
# Fichier : obj_lune_go.tcl
# Description : Outil pour le lancement d'Objectif Lune
# Auteur : Robert DELMAS
# Mise a jour $Id: obj_lune_go.tcl,v 1.10 2007-05-06 14:56:24 robertdelmas Exp $
#

#============================================================
# Declaration du namespace obj_lune_go
#    initialise le namespace
#============================================================
namespace eval ::obj_lune_go {
   package provide obj_lune 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] obj_lune_go.cap ]
}

#------------------------------------------------------------
# ::obj_lune_go::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::obj_lune_go::getPluginTitle { } {
   global caption

   return "$caption(obj_lune_go,obj_lune)"
}

#------------------------------------------------------------
# ::obj_lune_go::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::obj_lune_go::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::obj_lune_go::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::obj_lune_go::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "moon" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::obj_lune_go::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::obj_lune_go::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::obj_lune_go::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::obj_lune_go::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Img pour visualiser les cartes de la Lune au format jpg
   package require Img 1.3
   #--- Charge le source de la fenetre Objectif Lune
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool obj_lune obj_lune.tcl ]\""
}

#------------------------------------------------------------
# ::obj_lune_go::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::obj_lune_go::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::obj_lune_go::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::obj_lune_go::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::obj_Lune::run
}

#------------------------------------------------------------
# ::obj_lune_go::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::obj_lune_go::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

