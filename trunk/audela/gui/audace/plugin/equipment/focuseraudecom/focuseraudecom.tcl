#
# Fichier : focuseraudecom.tcl
# Description : Gere un focuser sur port parallele ou quickremote
# Auteur : Michel PUJOL
# Mise a jour $Id: focuseraudecom.tcl,v 1.1 2007-02-07 20:38:38 robertdelmas Exp $
#

#
# Procedures generiques obligatoires (pour configurer tous les plugins camera, telescope, equipement) :
#     init              : Initialise le namespace (appelee pendant le chargement de ce source)
#     getLabel          : Retourne le nom affichable du plugin
#     getHelp           : Retourne la documentation htm associee
#     getPluginType     : Retourne le type de plugin (pour classer le plugin dans le menu principal)
#     fillConfigPage    : Affiche la fenetre de configuration de ce plugin
#     configurePlugin   : Configure le plugin
#     stopPlugin        : Arrete le plugin et libere les ressources occupees
#     isReady           : Informe de l'etat de fonctionnement du plugin
#
# Procedures specifiques a ce plugin :
#

namespace eval ::focuseraudecom {

}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::focuseraudecom::init
#     initialise le equipement
#
#  return namespace name
#------------------------------------------------------------
proc ::focuseraudecom::init { } {
   global audace

   package provide focuseraudecom 1.0

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) equipment focuseraudecom focuseraudecom.cap ]

   #--- Cree les variables dans conf(...) si elles n'existent pas
   #--- pas de variable conf() pour ce focuser

   return [namespace current]
}

#------------------------------------------------------------
#  ::focuseraudecom::getPluginType
#     retourne le type de plugin
#
#  return "focuser"
#------------------------------------------------------------
proc ::focuseraudecom::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  ::focuseraudecom::getLabel
#     retourne le label du plugin
#
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::focuseraudecom::getLabel { } {
   global caption

   return "$caption(focuseraudecom,label)"
}

#------------------------------------------------------------
#  ::focuseraudecom::getHelp
#     retourne la documentation du equipement
#
#  return "nom_equipement.htm"
#------------------------------------------------------------
proc ::focuseraudecom::getHelp { } {
   return "focuseraudecom.htm"
}

#------------------------------------------------------------
#  ::focuseraudecom::getStartFlag
#     retourne l'indicateur de lancement au démarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::focuseraudecom::getStartFlag { } {
   #--- le focuser AudeCom est demarre automatiquement a la creation du telescope
   return 0
}

#------------------------------------------------------------
#  ::focuseraudecom::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::focuseraudecom::fillConfigPage { frm } {
   global caption

   #--- je copie les donnees de conf(...) dans les variables widget(...)

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   label $frm.frame1.labelLink -text "$caption(focuseraudecom,link)"
   grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns
}

#------------------------------------------------------------
#  ::focuseraudecom::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuseraudecom::configurePlugin { } {

   #--- copie les variables des widgets dans le tableau conf()

}

#------------------------------------------------------------
#  ::focuseraudecom::createPlugin
#     demarrerle plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuseraudecom::createPlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison du
   #--- telescope AudeCom
   return
}

#------------------------------------------------------------
#  ::focuseraudecom::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::focuseraudecom::deletePlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison du
   #--- telescope AudeCom
   return
}

#------------------------------------------------------------
#  ::focuseraudecom::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::focuseraudecom::isReady { } {
   global audace

   set result "0"
   #--- le focuser est ready si le telescope AudeCom est deja cree
   if { [ ::tel::list ] != "" } {
      if { [tel$audace(telNo) name] == "AudeCom" } {
         set result "1"
      }
   }
   return 1
}

#==============================================================
# ::focuseraudecom::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::focuseraudecom::move
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#     si command = "stop" , arrete le mouvement
#------------------------------------------------------------
proc ::focuseraudecom::move { command } {
   global conf
   global audace

   if { [ ::tel::list ] != "" } {
      if { $audace(focus,labelspeed) != "?" } {
         if { $conf(audecom,inv_rot) == "0" } {
            if { $command == "-" } {
              tel$audace(telNo) focus move - $audace(focus,speed)
            } elseif { $command == "+" } {
              tel$audace(telNo) focus move + $audace(focus,speed)
            } elseif { $command == "stop" } {
              tel$audace(telNo) focus stop
            }
         } else {
            if { $command == "-" } {
              tel$audace(telNo) focus move + $audace(focus,speed)
            } elseif { $command == "+" } {
              tel$audace(telNo) focus move - $audace(focus,speed)
            } elseif { $command == "stop" } {
              tel$audace(telNo) focus stop
            }
         }
      }
   } else {
      if { $command != "stop" } {
         ::confTel::run
        # tkwait window $audace(base).confTel
      }
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::goto
#     envoie le focus a la position audace(focus,nbpas2)
#     et met la nouvelle valeur de la position dans la variable audace(focus,nbpas1)
#------------------------------------------------------------
proc ::focuseraudecom::goto { } {
   global conf
   global audace

   #--- Direction de focalisation prioritaire : extrafocale
   if { $conf(audecom,intra_extra) == "1" } {
      if { $audace(focus,nbpas2) > "$audace(focus,nbpas1)" } {
         #--- Envoie la foc a la consigne
         tel$audace(telNo) focus goto $audace(focus,nbpas2)
      } else {
         #--- Depasse la consigne de $conf(audecom,dep_val) pas pour le rattrapage des jeux
         #--- 250 pas correspondent a 1/2 tour du moteur de focalisation
         set nbpas3 [ expr $audace(focus,nbpas2)-$conf(audecom,dep_val) ]
         if { $nbpas3 < "-32767" } {
            set nbpas3 "-32767"
         }
         tel$audace(telNo) focus goto $nbpas3
         #--- Envoie la foc a la consigne
         tel$audace(telNo) focus goto $audace(focus,nbpas2)
      }
   #--- Direction de focalisation prioritaire : intrafocale
   } else {
      if { $audace(focus,nbpas2) < "$audace(focus,nbpas1)" } {
         #--- Envoie la foc a la consigne
         tel$audace(telNo) focus goto $audace(focus,nbpas2)
      } else {
         #--- Depasse la consigne de $conf(audecom,dep_val) pas pour le rattrapage des jeux
         #--- 250 pas correspondent a 1/2 tour du moteur de focalisation
         set nbpas3 [ expr $audace(focus,nbpas2) + $conf(audecom,dep_val) ]
         if { $nbpas3 > "32767" } {
            set nbpas3 "32767"
         }
         tel$audace(telNo) focus goto $nbpas3
         #--- Envoie la foc a la consigne
         tel$audace(telNo) focus goto $audace(focus,nbpas2)
      }
   }
   #--- Boucle tant que la foc n'est pas arretee
   set foc0 [ tel$audace(telNo) focus coord ]
   after 500
   set foc1 [ tel$audace(telNo) focus coord ]
   while { $foc0 != "$foc1" } {
      set foc0 $foc1
      after 500
      set foc1 [ tel$audace(telNo) focus coord ]
   }
   set audace(focus,nbpas1) $foc1
   split $audace(focus,nbpas1) "\n"
   set audace(focus,nbpas1) [ lindex $audace(focus,nbpas1) 0 ]
}

#------------------------------------------------------------
#  ::focuseraudecom::incrementSpeed
#     incremente la vitesse du focus et appelle la procedure setSpeed
#------------------------------------------------------------
proc ::focuseraudecom::incrementSpeed { } {
   global conf
   global audace

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         if { $audace(focus,speed) == "0" } {
            ::focuseraudecom::setSpeed "1"
         } elseif { $audace(focus,speed) == "1" } {
            ::focuseraudecom::setSpeed "0"
         } else {
            ::focuseraudecom::setSpeed "1"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $audace(focus,speed) == "0" } {
            ::focuseraudecom::setSpeed "1"
         } else {
            ::focuseraudecom::setSpeed "0"
         }
      } else {
         #--- Inactif pour autres telescopes
         ::focuseraudecom::setSpeed "0"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::setSpeed
#     change la vitesse du focus
#     met a jour les variables audace(focus,speed), audace(focus,labelspeed)
#     change la vitesse de mouvement du telescope
#------------------------------------------------------------
proc ::focuseraudecom::setSpeed { { value "0" } } {
   global conf
   global audace
   global caption

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "$caption(focuseraudecom,x5)"
            ::telescope::setSpeed "2"
         } else {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "$caption(focuseraudecom,x1)"
            ::telescope::setSpeed "1"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "2"
            ::telescope::setSpeed "3"
         } elseif { $value == "0" } {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "1"
            ::telescope::setSpeed "2"
         }
      } else {
         set audace(focus,speed) "0"
         set audace(focus,labelspeed) "$caption(focuseraudecom,interro)"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuseraudecom::possedeControleEtendu
#     retourne 1 si le telescope possede un controle etendu du focus (AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focuseraudecom::possedeControleEtendu { } {
   global conf

   if { $conf(telescope) == "audecom"  } {
      set result "1"
   } else {
      set result "0"
   }
}

::focuseraudecom::init

