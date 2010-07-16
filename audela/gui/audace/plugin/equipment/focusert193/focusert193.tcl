#
# Fichier : focusert193.tcl
# Description : Gere le focuser associe a la monture T193
# Auteur : Robert DELMAS
# Mise à jour $Id: focusert193.tcl,v 1.1 2010-07-16 16:26:23 robertdelmas Exp $
#

#
# Procedures generiques obligatoires (pour configurer tous les plugins camera, monture, equipement) :
#     initPlugin        : Initialise le namespace (appelee pendant le chargement de ce source)
#     getStartFlag      : Retourne l'indicateur de lancement au demarrage
#     getPluginHelp     : Retourne la documentation htm associee
#     getPluginTitle    : Retourne le titre du plugin dans la langue de l'utilisateur
#     getPluginType     : Retourne le type de plugin
#     getPluginOS       : Retourne les OS sous lesquels le plugin fonctionne
#     fillConfigPage    : Affiche la fenetre de configuration de ce plugin
#     configurePlugin   : Configure le plugin
#     stopPlugin        : Arrete le plugin et libere les ressources occupees
#     isReady           : Informe de l'etat de fonctionnement du plugin
#
# Procedures specifiques a ce plugin :
#

namespace eval ::focusert193 {
   package provide focusert193 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] focusert193.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::focusert193::initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::focusert193::initPlugin { } {
   #--- Cree les variables dans conf(...) si elles n'existent pas
   #--- pas de variable conf() pour ce focuser
}

#------------------------------------------------------------
#  ::focusert193::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::focusert193::getPluginTitle { } {
   global caption

   return "$caption(focusert193,label)"
}

#------------------------------------------------------------
#  ::focusert193::getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::focusert193::getPluginHelp { } {
   return "focusert193.htm"
}

#------------------------------------------------------------
#  ::focusert193::getPluginType
#     retourne le type de plugin
#
#  return "focuser"
#------------------------------------------------------------
proc ::focusert193::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  ::focusert193::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::focusert193::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  ::focusert193::getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::focusert193::getStartFlag { } {
   #--- le focuser T193 est demarre automatiquement a la creation de la monture
   return 0
}

#------------------------------------------------------------
#  ::focusert193::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::focusert193::fillConfigPage { frm } {
   global caption

   #--- Frame pour le label
   frame $frm.frame1 -borderwidth 0 -relief raised

      label $frm.frame1.labelLink -text "$caption(focusert193,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

   pack $frm.frame1 -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  ::focusert193::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focusert193::configurePlugin { } {
   #--- copie les variables des widgets dans le tableau conf()
}

#------------------------------------------------------------
#  ::focusert193::createPlugin
#     demarre le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focusert193::createPlugin { } {
   global audace

   if { [ info exists audace(focus,speed) ] == "0" } {
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focusert193::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::focusert193::deletePlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison
   #--- de la monture T193
   return
}

#------------------------------------------------------------
#  ::focusert193::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::focusert193::isReady { } {
   set result "0"
   #--- le focuser est ready si la monture T193 est deja creee
   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "name" ] == "T193" } {
         set result "1"
      }
   }
   return $result
}

#==============================================================
# ::focusert193::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::focusert193::move
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#     si command = "stop" , arrete le mouvement
#------------------------------------------------------------
proc ::focusert193::move { command } {
   global audace conf

   if { [ ::tel::list ] != "" } {
      if { $audace(focus,labelspeed) != "?" } {
         if { $command == "-" } {
           tel$audace(telNo) focus move - $audace(focus,speed)
         } elseif { $command == "+" } {
           tel$audace(telNo) focus move + $audace(focus,speed)
         } elseif { $command == "stop" } {
           tel$audace(telNo) focus stop
           ::focusert193::displayCurrentPosition
         }
      }
   } else {
      if { $command != "stop" } {
         ::confTel::run
      }
   }
}

#------------------------------------------------------------
#  ::focusert193::goto
#     envoie le focus a la position audace(focus,targetFocus)
#     et met la nouvelle valeur de la position dans la variable audace(focus,currentFocus)
#------------------------------------------------------------
proc ::focusert193::goto { } {
   global audace

   #--- Lance le GOTO du focuser
   #--- Format de la commande : tel1 focus goto number ?-rate value? ?-blocking boolean?
   tel$audace(telNo) focus goto $audace(focus,targetFocus) -blocking 0
   #--- Boucle tant que la foc n'est pas arretee
   ::focusert193::displayCurrentPosition
}

#------------------------------------------------------------
#  ::focusert193::displayCurrentPosition
#     affiche la position courante du focaliseur a moteur pas a pas audace(focus,currentFocus)
#------------------------------------------------------------
proc ::focusert193::displayCurrentPosition { } {
   global audace

   #--- Boucle tant que la foc n'est pas arretee
   set foc0 [ tel$audace(telNo) focus coord ]
   after 500
   set foc1 [ tel$audace(telNo) focus coord ]
   while { $foc0 != "$foc1" } {
      set foc0 $foc1
      after 500
      set foc1 [ tel$audace(telNo) focus coord ]
   }
   set currentPosition $foc1
   split $currentPosition "\n"
   set audace(focus,currentFocus) [ string trimleft [ lindex $currentPosition 0 ] 0 ]
   if { $audace(focus,currentFocus) == "" } {
      set audace(focus,currentFocus) "0"
   }
}

#------------------------------------------------------------
#  ::focusert193::possedeControleEtendu
#     retourne 1 si la monture possede un controle etendu du focus (T193)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focusert193::possedeControleEtendu { } {
   global conf

   if { $conf(telescope) == "t193" } {
      set result "1"
   } else {
      set result "0"
   }
}

