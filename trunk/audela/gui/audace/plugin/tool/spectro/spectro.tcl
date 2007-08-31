#
# Fichier : spectro.tcl
# Description : Outil de traitement d'images de spectro
# Auteur : Alain Klotz
# Mise a jour $Id: spectro.tcl,v 1.21 2007-08-31 17:34:54 robertdelmas Exp $
#

#============================================================
# Declaration du namespace spectro
#    initialise le namespace
#============================================================
namespace eval ::spectro {
   package provide spectro 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] spectro.cap ]
}

#------------------------------------------------------------
# ::spectro::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::spectro::getPluginTitle { } {
   global caption

   return "$caption(spectro,spc_audace)"
}

#------------------------------------------------------------
#  ::spectro::getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::spectro::getPluginHelp { } {
   return "spectro.htm"
}

#------------------------------------------------------------
# ::spectro::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::spectro::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::spectro::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::spectro::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "spectro" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::spectro::initPlugin
#    initialise le plugin au demarrage de audace
#    eviter de charger trop de choses (penser a ceux qui n'utilisent pas spcaudace)
#------------------------------------------------------------
proc ::spectro::initPlugin { tkbase } {
   global audace

   #--- Chargement des fonctions de spectrographie pour l'utilisation
   #--- depuis la console sans ouvrir la fenetre de spcaudace
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool spectro spcaudace.tcl ]\""
}

#------------------------------------------------------------
# ::spectro::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::spectro::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Charge le source de la fenetre de spcaudace
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool spectro spcaudace spc_gui.tcl ]\""
}

#------------------------------------------------------------
# ::spectro::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::spectro::deletePluginInstance { visuNo } {
   #--- Rien a faire pour l'instant
   #--- Car spcaudace ne peut pas etre supprime de la memoire
}

#------------------------------------------------------------
# ::spectro::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::spectro::startTool { visuNo } {
   #--- J'ouvre la fenetre
   spc_winini
}

#------------------------------------------------------------
# ::spectro::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::spectro::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

