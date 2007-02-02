#
# Fichier : focuser.tcl
# Description : Gere un focuser sur port parallele ou quickremote
# Auteur : Michel PUJOL
# Mise a jour $Id: focuserlx200.tcl,v 1.2 2007-02-02 19:00:38 robertdelmas Exp $
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

namespace eval ::focuserlx200 {

}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::focuserlx200::init
#     initialise le equipement
#
#  return namespace name
#------------------------------------------------------------
proc ::focuserlx200::init { } {
   global audace
   global conf
   global caption
   variable private

   package provide focuserlx200 1.0

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) equipment focuserlx200 focuserlx200.cap ]

   #--- Cree les variables dans conf(...) si elles n'existent pas
   #--- pas de variable conf() pour ce focuser

   return [namespace current]
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
#  ::focuserlx200::getLabel
#     retourne le label du plugin
#
#  return "Titre de l'onglet (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::focuserlx200::getLabel { } {
   global caption
   return "$caption(focuserlx200,label)"
}

#------------------------------------------------------------
#  ::focuserlx200::getHelp
#     retourne la documentation du equipement
#
#  return "nom_equipement.htm"
#------------------------------------------------------------
proc ::focuserlx200::getHelp { } {
   return "focuserlx200.htm"
}

#------------------------------------------------------------
#  ::focuserlx200::getStartFlag
#     retourne l'indicateur de lancement au démarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::focuserlx200::getStartFlag { } {
   #--- le focuser lx200 est demarre automatique a la creation du telescope
   return 0
}

#------------------------------------------------------------
#  ::focuserlx200::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::focuserlx200::fillConfigPage { frm } {
   variable widget
   global conf
   global caption

   #--- je copie les donnees de conf(...) dans les variables widget(...)

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   label $frm.frame1.labelLink -text "$caption(focuserlx200,link)"
   grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns
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
#     demarrerle plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuserlx200::createPlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison du
   #--- telescope lx200
   return
}

#------------------------------------------------------------
#  ::focuserlx200::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::focuserlx200::deletePlugin { } {
   #--- il n'y a rien a faire pour ce focuser car il utilise la liaison du
   #--- telescope lx200
   return
}

#------------------------------------------------------------
#  ::focuserlx200::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::focuserlx200::isReady { } {
   global audace

   set result "0"
   #--- le focuser est ready si le telescope lx200 est deja cree
   if { [ ::tel::list ] != "" } {
      if { [tel$audace(telNo) name] == "LX200" } {
         set result "1"
      }
   }
   return 1
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
#  ::focuserlx200::goto
#     envoie le focus a la position audace(focus,nbpas2)
#     et met la nouvelle valeur de la position dans la variable audace(focus,nbpas1)
#------------------------------------------------------------
proc ::focuserlx200::goto { } {
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
#  ::focuserlx200::incrementSpeed
#     incremente la vitesse du focus et appelle la procedure setSpeed
#------------------------------------------------------------
proc ::focuserlx200::incrementSpeed { } {
   global conf
   global audace

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         if { $audace(focus,speed) == "0" } {
            ::focuserlx200::setSpeed "1"
         } elseif { $audace(focus,speed) == "1" } {
            ::focuserlx200::setSpeed "0"
         } else {
            ::focuserlx200::setSpeed "1"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $audace(focus,speed) == "0" } {
            ::focuserlx200::setSpeed "1"
         } else {
            ::focuserlx200::setSpeed "0"
         }
      } else {
         #--- Inactif pour autres telescopes
         ::focuserlx200::setSpeed "0"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuserlx200::setSpeed
#     change la vitesse du focus
#     met a jour les variables audace(focus,speed), audace(focus,labelspeed)
#     change la vitesse de mouvement du telescope
#------------------------------------------------------------
proc ::focuserlx200::setSpeed { { value "0" } } {
   global conf
   global audace
   global caption

   if { [ ::tel::list ] != "" } {
      if { $conf(telescope) == "audecom" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "$caption(focuserlx200,x5)"
            ::telescope::setSpeed "2"
         } else {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "$caption(focuserlx200,x1)"
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
         set audace(focus,labelspeed) "$caption(focuserlx200,interro)"
      }
   } else {
      ::confTel::run
      tkwait window $audace(base).confTel
      set audace(focus,speed) "0"
   }
}

#------------------------------------------------------------
#  ::focuserlx200::possedeControleEtendu
#     retourne 1 si le telescope possede un controle etendu du focus (AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focuserlx200::possedeControleEtendu { } {
   global conf

   if { $conf(telescope) == "audecom"  } {
      set result "1"
   } else {
      set result "0"
   }
}

::focuserlx200::init

