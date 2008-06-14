# Mise a jour $Id: spcaudace.tcl,v 1.2 2008-06-14 21:12:28 robertdelmas Exp $


####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 02-01-2007
# Arguments : nom du fichier du spectre spatial
# Chargement du script : source [ file joint $audace(rep_scripts) spcaudace.tcl ]
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################

# Remarque : il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

global audace
global audela

#--- Fonctions de demarrage du plugin SpcAudace :

#============================================================
# Declaration du namespace spcaudace
#    initialise le namespace
#============================================================
namespace eval ::spcaudace {
   package provide spcaudace 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] spcaudace.cap ]
}

#------------------------------------------------------------
# ::spcaudace::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::spcaudace::getPluginTitle { } {
   global caption

   return "$caption(spcaudace,spc_audace)"
}

#------------------------------------------------------------
# ::spcaudace::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::spcaudace::getPluginHelp { } {
   return "spcaudace.htm"
}

#------------------------------------------------------------
# ::spcaudace::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::spcaudace::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::spcaudace::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::spcaudace::getPluginDirectory { } {
   return "spcaudace"
}

#------------------------------------------------------------
# ::spcaudace::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::spcaudace::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::spcaudace::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::spcaudace::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "spectroscopy" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::spcaudace::initPlugin
#    initialise le plugin au demarrage de audace
#    eviter de charger trop de choses (penser a ceux qui n'utilisent pas spcaudace)
#------------------------------------------------------------
proc ::spcaudace::initPlugin { tkbase } {
   global audace

   #--- Chargement des fonctions de spectrographie pour l'utilisation
   #--- depuis la console sans ouvrir la fenetre de spcaudace
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool spcaudace spcaudace.tcl ]\""
}

#------------------------------------------------------------
# ::spcaudace::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::spcaudace::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace

   #--- Charge le source de la fenetre de spcaudace
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool spcaudace spc_gui.tcl ]\""
}

#------------------------------------------------------------
# ::spcaudace::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::spcaudace::deletePluginInstance { visuNo } {
   #--- Rien a faire pour l'instant
   #--- Car spcaudace ne peut pas etre supprime de la memoire
}

#------------------------------------------------------------
# ::spcaudace::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::spcaudace::startTool { visuNo } {
   #--- J'ouvre la fenetre
   spc_winini
}

#------------------------------------------------------------
# ::spcaudace::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::spcaudace::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}



## Fonctions généralistes

###############################################################################
#
# Description : se met dans le répertoire de travail d'Audace pour éviter de
#  mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date création : 17-12-2005
# Date de mise à jour : 17-12-2005
# Arguments : aucun
###############################################################################

#--- Démarrage de SpcAudace :
if { [regexp {1.3.0} $audela(version) match resu ] } {
    set repspc [ file join $audace(rep_scripts) spcaudace ]
    #--- Chargement de l'éditeur de profil :
    #source [ file join $repspc spc_cap.tcl ]
    source [ file join $repspc spc_gui.tcl ]
} else {
    set repspc [ file join $audace(rep_plugin) tool spcaudace ]
}


#--- Chargement des fonctionnalités :
source [ file join $repspc spc_var.tcl ]
source [ file join $repspc spc_cap.tcl ]
source [ file join $repspc spc_ini.tcl ]
source [ file join $repspc spc_io.tcl ]
source [ file join $repspc spc_profil.tcl ]
source [ file join $repspc spc_calibrage.tcl ]
source [ file join $repspc spc_analyse.tcl ]
source [ file join $repspc spc_operations.tcl ]
source [ file join $repspc spc_geom.tcl ]
source [ file join $repspc spc_astrophys.tcl ]
source [ file join $repspc spc_filters.tcl ]
source [ file join $repspc spc_filter2.tcl ]
source [ file join $repspc spc_numeric.tcl ]
source [ file join $repspc spc_metaf.tcl ]
source [ file join $repspc spc_gui_boxes.tcl ]
source [ file join $repspc spc_gui_metaboxes.tcl ]
source [ file join $repspc spc_gui_runs.tcl ]
source [ file join $repspc spc_external.tcl ]
source [ file join $repspc spc_echelle.tcl ]


#--- Chargement des plugins Spcaudace :
source [ file join $repspc plugins specLhIII specLhIII.tcl ]


#--------- Lancement ---------------#
#extract_profil  $file_spectre_spatial
#spc_trace_profil ${file_spectre_spatial}.dat

