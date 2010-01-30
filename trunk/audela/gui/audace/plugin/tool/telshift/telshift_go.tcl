#
# Fichier : telshift_go.tcl
# Description : Outil pour l'acquisition avec deplacement du telescope entre les poses
# Auteur : Christian JASINSKI
# Mise a jour $Id: telshift_go.tcl,v 1.11 2010-01-30 14:23:43 robertdelmas Exp $
#

#============================================================
# Declaration du namespace telshift
#    initialise le namespace
#============================================================
namespace eval ::telshift {
   package provide telshift 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] telshift_go.cap ]
}

#------------------------------------------------------------
# ::telshift::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::telshift::getPluginTitle { } {
   global caption

   return "$caption(telshift_go,telshift)"
}

#------------------------------------------------------------
# ::telshift::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::telshift::getPluginHelp { } {
   return "telshift.htm"
}

#------------------------------------------------------------
# ::telshift::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::telshift::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::telshift::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::telshift::getPluginDirectory { } {
   return "telshift"
}

#------------------------------------------------------------
# ::telshift::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::telshift::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::telshift::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::telshift::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::telshift::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::telshift::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::telshift::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::telshift::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Charge le source de la fenetre Imager & deplacer
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool telshift telshift.tcl ]\""
}

#------------------------------------------------------------
# ::telshift::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::telshift::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::telshift::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::telshift::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::telshift::createPanel
}

#------------------------------------------------------------
# ::telshift::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::telshift::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

