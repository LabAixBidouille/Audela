#
# Fichier : collector.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace collector
#    initialise le namespace
#============================================================
namespace eval ::collector {
   package provide collector 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] collector.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(collector,title)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "collector.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "collector"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "analysis" }
         subfunction1 { return "collector" }
         display      { return "window" }
         multivisu    { return 0 }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {

   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      global audace

      package require http
      package require struct::list

      set dirname [file join $audace(rep_plugin) tool]
      source [ file join $dirname collector collector_cam.tcl ]
      source [ file join $dirname collector collector_dss.tcl ]
      source [ file join $dirname collector collector_dyn.tcl ]
      source [ file join $dirname collector collector_german.tcl ]
      source [ file join $dirname collector collector_get.tcl ]
      source [ file join $dirname collector collector_gui.tcl ]
      source [ file join $dirname collector collector_init.tcl ]
      source [ file join $dirname collector collector_park.tcl ]
      source [ file join $dirname collector collector_simul.tcl ]
      source [ file join $dirname collector collector_utils.tcl ]

   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      variable private

      if { [ winfo exists $private(This) ] } {
         #--- Je ferme la fenetre si l'utilsateur ne l'a pas deja fait
         closeMyNoteBook $visuNo $private(This)
      }
   }

   #------------------------------------------------------------
   # startTool : affiche la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable private

      if { ![ winfo exists private(This) ] } {
         initCollector $visuNo
      }
    }

   #------------------------------------------------------------
   # stopTool : masque la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc stopTool { visuNo } {

   }

#--   fin du namespace ::collector
}

