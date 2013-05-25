#
# Fichier : focuserlx200.tcl
# Description : Gere le focuser associe a la monture LX200
# Auteur : Michel PUJOL
# Mise à jour $Id$
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

namespace eval ::focuserlx200 {
   package provide focuserlx200 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] focuserlx200.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::focuserlx200::initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::focuserlx200::initPlugin { } {
   #--- Cree les variables dans conf(...) si elles n'existent pas
   #--- pas de variable conf() pour ce focuser
}

#------------------------------------------------------------
#  ::focuserlx200::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::focuserlx200::getPluginTitle { } {
   global caption

   return "$caption(focuserlx200,label)"
}

#------------------------------------------------------------
#  ::focuserlx200::getPluginHelp
#     retourne la documentation du equipement
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::focuserlx200::getPluginHelp { } {
   return "focuserlx200.htm"
}

#------------------------------------------------------------
#  ::focuserlx200::getPluginType
#     retourne le type de plugin
#
#  return "focuser"
#------------------------------------------------------------
proc ::focuserlx200::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  ::focuserlx200::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::focuserlx200::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  ::focuserlx200::getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::focuserlx200::getStartFlag { } {
   #--- le focuser LX200 est demarre automatiquement a la creation de la monture
   return 0
}

#------------------------------------------------------------
#  ::focuserlx200::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::focuserlx200::fillConfigPage { frm } {
   global caption

   #--- Frame pour le label
   frame $frm.frame1 -borderwidth 0 -relief raised

      label $frm.frame1.labelLink -text "$caption(focuserlx200,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

   pack $frm.frame1 -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  ::focuserlx200::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuserlx200::configurePlugin { } {
   #--- copie les variables des widgets dans le tableau conf()
}

#------------------------------------------------------------
#  ::focuserlx200::createPlugin
#     demarre le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuserlx200::createPlugin { } {
   global audace

   if { [ info exists audace(focus,speed) ] == "0" } {
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuserlx200::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::focuserlx200::deletePlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison serie
   #--- de la monture LX200
   return
}

#------------------------------------------------------------
#  ::focuserlx200::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::focuserlx200::isReady { } {
   set result "0"
   #--- le focuser est ready si la monture LX200 est deja cree
   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "name" ] == "LX200" } {
         set result "1"
      }
   }
   return $result
}

#==============================================================
# ::focuserlx200::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::focuserlx200::move
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#     si command = "stop" , arrete le mouvement
#------------------------------------------------------------
proc ::focuserlx200::move { command } {
   global audace

   if { [ ::tel::list ] != "" } {
      if { $audace(focus,labelspeed) != "?" } {
         if { $command == "-" } {
           tel$audace(telNo) focus move - $audace(focus,speed)
         } elseif { $command == "+" } {
           tel$audace(telNo) focus move + $audace(focus,speed)
         } elseif { $command == "stop" } {
           tel$audace(telNo) focus stop
         }
      }
   } else {
      if { $command != "stop" } {
         ::confTel::run
      }
   }
}

#------------------------------------------------------------
#  ::focuserlx200::goto
#     envoie le focaliseur a moteur pas a pas a une position predeterminee (AudeCom)
#------------------------------------------------------------
proc ::focuserlx200::goto { blocking } {
   # non supportee
}

#------------------------------------------------------------
#  ::focuserlx200::incrementSpeed
#     incremente la vitesse du focus et appelle la procedure setSpeed
#------------------------------------------------------------
proc ::focuserlx200::incrementSpeed { origin } {
   global audace caption

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "product" ] == "lx200" } {
         if { $audace(focus,speed) == "0" } {
            ::focuserlx200::setSpeed "1"
         } elseif { $audace(focus,speed) == "1" } {
            ::focuserlx200::setSpeed "0"
         } else {
            ::focuserlx200::setSpeed "1"
         }
      } elseif { [ ::confTel::getPluginProperty "product" ] == "audecom" } {
         #--- Inactif pour autres montures
         ::focuserlx200::setSpeed "0"
         set origine [ lindex $origin 0 ]
         if { $origine == "pad" } {
            #--- Message d'alerte venant d'une raquette
            tk_messageBox -title $caption(focuserlx200,attention) -type ok -icon error \
               -message "$caption(focuserlx200,msg1)\n$caption(focuserlx200,msg2)"
            ::confPad::run
         } elseif { $origine == "tool" } {
            #--- Message d'alerte venant d'un outil
            tk_messageBox -title $caption(focuserlx200,attention) -type ok -icon error \
               -message "$caption(focuserlx200,msg3)\n$caption(focuserlx200,msg2)"
            ::confEqt::run ::panneau([ lindex $origin 1 ],focuser) focuser
         }
      } else {
         #--- Inactif pour autres montures
         ::focuserlx200::setSpeed "0"
      }
   } else {
      ::confTel::run
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuserlx200::setSpeed
#     change la vitesse du focus
#     met a jour les variables audace(focus,speed), audace(focus,labelspeed)
#     change la vitesse de mouvement de la monture
#------------------------------------------------------------
proc ::focuserlx200::setSpeed { { value "0" } } {
   global audace caption

   if { [ ::tel::list ] != "" } {
      if { [ ::confTel::getPluginProperty "product" ] == "lx200" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "2"
            ::telescope::setSpeed "2"
         } elseif { $value == "0" } {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "1"
            ::telescope::setSpeed "1"
         }
      } else {
         set audace(focus,speed) "0"
         set audace(focus,labelspeed) "$caption(focuserlx200,interro)"
      }
   } else {
      ::confTel::run
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuserlx200::possedeControleEtendu
#     retourne 1 si la monture possede un controle etendu du focus (LX200 modele AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focuserlx200::possedeControleEtendu { } {
   global conf

   if { $conf(telescope) == "lx200" && $conf(lx200,modele) == "AudeCom" } {
      set result "1"
   } else {
      set result "0"
   }
}

#------------------------------------------------------------
#  getPosition
#     retourne la position courante du focuser
#------------------------------------------------------------
proc ::focuserlx200::getPosition { } {
   if { [ ::tel::list ] != "" } {
      return [tel$::audace(telNo) focus coord]
   } else {
      ::confTel::run
   }
}

