#
# Fichier : obj_lune_go.tcl
# Description : Outil pour le lancement d'Objectif Lune
# Auteur : Robert DELMAS
# Mise a jour $Id: obj_lune_go.tcl,v 1.9 2007-04-14 08:32:26 robertdelmas Exp $
#

#============================================================
# Declaration du namespace Obj_Lune_Go
#    initialise le namespace
#============================================================
namespace eval ::Obj_Lune_Go {
   package provide obj_lune 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] obj_lune_go.cap ]
}

#------------------------------------------------------------
# ::Obj_Lune_Go::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::Obj_Lune_Go::getPluginTitle { } {
   global caption

   return "$caption(obj_lune_go,obj_lune)"
}

#------------------------------------------------------------
# ::Obj_Lune_Go::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::Obj_Lune_Go::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::Obj_Lune_Go::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::Obj_Lune_Go::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "moon" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::Obj_Lune_Go::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::Obj_Lune_Go::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::Obj_Lune_Go::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Chargement du package Img pour visualiser les cartes de la Lune au format jpg
   package require Img 1.3
   #--- Charge le source de la fenetre Objectif Lune
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool obj_lune obj_lune.tcl ]\""
}

#------------------------------------------------------------
# ::Obj_Lune_Go::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::Obj_Lune_Go::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::Obj_Lune_Go::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::obj_Lune::run
}

#------------------------------------------------------------
# ::Obj_Lune_Go::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::Obj_Lune_Go::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

