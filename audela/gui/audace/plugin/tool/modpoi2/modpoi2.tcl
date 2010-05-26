#
# Fichier : modpoi2.tcl
# Description : Outil de fabrication des fichiers Kit et de deploiement des plugins
# Auteur : Michel Pujol
# Mise à jour $Id: modpoi2.tcl,v 1.2 2010-05-26 06:22:01 robertdelmas Exp $
#

namespace eval ::modpoi2 {
   package provide modpoi2 1.0
   package require audela 1.5.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] modpoi2.cap ]

}

#------------------------------------------------------------
# initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::modpoi2::initPlugin { tkbase } {

}

#------------------------------------------------------------
# getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::modpoi2::getPluginTitle { } {
   global caption

   return "$::caption(modpoi2,title)"
}

#------------------------------------------------------------
# getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::modpoi2::getPluginHelp { } {
   return "modpoi2.htm"
}

#------------------------------------------------------------
# getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::modpoi2::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#     retourne le type de plugin
#------------------------------------------------------------
proc ::modpoi2::getPluginDirectory { } {
   return "modpoi2"
}

#------------------------------------------------------------
# getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::modpoi2::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::modpoi2::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "aiming" }
      subfunction1 { return "" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# createPluginInstance
#     cree une instance l'outil
#
#------------------------------------------------------------
proc ::modpoi2::createPluginInstance { {tkbase ""} { visuNo 1 } } {
   variable private

   #--- je charge les fichier TCL supplementaires
   set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
   source [ file join $dir modpoi_main.tcl ]
   source [ file join $dir modpoi_process.tcl ]
   source [ file join $dir wizard.tcl ]
   source [ file join $dir horizon.tcl ]

   set private(tkbase) $tkbase

}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::modpoi2::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#
#------------------------------------------------------------
proc ::modpoi2::startTool { visuNo } {
   variable private

   #--- j'affiche la fentre principale
   ::modpoi2::main::run $visuNo $private(tkbase)
}

#------------------------------------------------------------
# stopTool
#    masque le panneau de l'outil
#
#------------------------------------------------------------
proc ::modpoi2::stopTool { visuNo } {
   variable private

   #--- rien à faire car ce n'est pas un panneau
}

