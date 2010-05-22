# Mise a jour $Id: spcaudace.tcl,v 1.20 2010-05-22 23:38:40 bmauclaire Exp $


####################################################################################
#
# SpcAudACE: tools for processing spectra with pipelines and doing astrophysic analysis
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 06-08-2008
#
#####################################################################################

#--- License:
# /* SpcAudACE plugin for AudeLA:
# *
# * This file is part of the AudeLA project: <http://www.audela.org>
# * Copyright (C) 2004-2009 B. Mauclaire
# *
# * Initial author : Benjamin MAUCLAIRE <bmauclaire@gmail.com>
# *
# * This program is free software; you can redistribute it and/or modify
# * it under the terms of the GNU General Public License as published by
# * the Free Software Foundation; either version 2 of the License, or (at
# * your option) any later version.
# *
# * This program is distributed in the hope that it will be useful, but
# * WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# * General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License
# * along with this program; if not, write to the Free Software
# * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# */



# Remarque : il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

###global audace
###global audela



#============================================================
# Declaration du namespace spcaudace
#    initialise le namespace
#============================================================
namespace eval ::spcaudace {
   global caption
   package provide spcaudace 1.6.1

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [ file dirname [info script] ] spcaudace.cap ]
}


#------------------------------------------------------------
# ::spcaudace::initPlugin
#    initialise le plugin au demarrage de audace
#    eviter de charger trop de choses (penser a ceux qui n'utilisent pas spcaudace)
#------------------------------------------------------------
proc ::spcaudace::initPlugin { tkbase } {
   global audace audela caption
   global colorspc profilspc

   variable spcaudace

   #--- Définition du repertoire d'SpcAudAce (spc_var pas encore charge) :
   if { [regexp {1.3.0} $audela(version) match resu ] } {
       set spcaudace(rep_spc) [ file join $audace(rep_scripts) spcaudace ]
       #source [ file join $repspc spc_cap.tcl ]
       source [ file join $spcaudace(rep_spc) spc_gui.tcl ]
   } else {
       set spcaudace(rep_spc) [ file join $audace(rep_plugin) tool spcaudace ]
   }

   #--- Chargement des fonctions de spectrographie pour l'utilisation
   #--- depuis la console sans ouvrir la fenetre de spcaudace
   # uplevel #0 "source \"[ file join $audace(rep_plugin) tool spcaudace spcaudace.tcl ]\""
   ##### cette ligne est inutile et dangereuse (risque de boucle infini du fichier qui se charge lui meme)
   #####uplevel #0 "source \"[ file join $rep_spcaudace spcaudace.tcl ]\""

   #--- Chargement de la lib BLT   (spc_ini.tcl a besoin de BLT)
   #-- A DEPLACER DANS CREATE_PLUGININSTANCE ?
   package require BLT

   #-- Chargement des fonctionnalités :
   #--- Attention : il faut mettre uplevel devant la commande source
   #--- car les fichiers contiennent des procedures globales (qui ne sont pas dans le namespace)
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_ini.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_var.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_cap.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_io.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_profil.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_calibrage.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_analyse.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_operations.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_geom.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_astrophys.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_filters.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_filter2.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_numeric.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_metaf.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_external.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_echelle.tcl ]\""
   #-- Chargement des plugins de Spcaudace :
   #source [ file join $spcaudace(rep_spc) plugins specLhIII specLhIII.tcl ]
}

#------------------------------------------------------------
# ::spcaudace::createPluginInstance
#    cree une nouvelle instance de l'outil et charge les fichiers GUI
#------------------------------------------------------------
proc ::spcaudace::createPluginInstance { { in "" } { visuNo 1 } } {
   global audace
   variable spcaudace

   #--- Attention : il faut mettre uplevel devant la commande source
   #--- car les fichiers contiennent des procedures globales (qui ne sont pas dans le namespace)
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_gui_boxes.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_gui_metaboxes.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_gui_runs.tcl ]\""
   uplevel #0 "source \"[ file join $spcaudace(rep_spc) spc_gui.tcl ]\""

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
   #- menu         { return "analysis" } : a ajouter dans le switch pour fonctionner avec Audela <= 1.5.20100201 :
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "spectroscopy" }
      display      { return "window" }
   }
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


