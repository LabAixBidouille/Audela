#
# Fichier : telshift_go.tcl
# Description : Outil pour l'acquisition avec deplacement du telescope entre les poses
# Auteur : Christian JASINSKI
# Mise a jour $Id: telshift_go.tcl,v 1.5 2007-04-12 20:30:00 robertdelmas Exp $
#

#============================================================
# Declaration du namespace ImagerDeplacer
#    initialise le namespace
#============================================================
namespace eval ::ImagerDeplacer {
   package provide telshift 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] telshift_go.cap ]
}

#------------------------------------------------------------
# ::ImagerDeplacer::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::ImagerDeplacer::getPluginTitle { } {
   global caption

   return "$caption(telshift_go,telshift)"
}

#------------------------------------------------------------
# ::ImagerDeplacer::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::ImagerDeplacer::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::ImagerDeplacer::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::ImagerDeplacer::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
   }
}

#------------------------------------------------------------
# ::ImagerDeplacer::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::ImagerDeplacer::initPlugin{ } {

}

#------------------------------------------------------------
# ::ImagerDeplacer::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Charge le source de la fenetre Imager & deplacer
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool telshift telshift.tcl ]\""
}

#------------------------------------------------------------
# ::ImagerDeplacer::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::ImagerDeplacer::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# ::ImagerDeplacer::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::ImagerDeplacer::createPanel
}

#------------------------------------------------------------
# ::ImagerDeplacer::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::ImagerDeplacer::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

