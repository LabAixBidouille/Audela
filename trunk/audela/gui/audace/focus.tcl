#
# Fichier : focus.tcl
# Description : Centralise les commandes du focus du telescope
# Auteur : Michel PUJOL
# Mise à jour $Id: focus.tcl,v 1.9 2010-07-15 15:44:30 robertdelmas Exp $
#

namespace eval ::focus {

}

#------------------------------------------------------------
# init
#    Initialisation de variables
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::focus::init { } {
   global audace

   #--- Initialisation
   set audace(focus,currentFocus) "0"
   set audace(focus,targetFocus)  ""
}

#------------------------------------------------------------
# ::focus::move
#   demarre/arrete le mouvement du focuseur
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#     si command = "stop" , arrete le mouvement
# Exemple :
#    ::focus::move "focuserquickr" "+"
#    ::focus::move "focuserquickr" "-"
#    ::focus::move "focuserquickr" "stop"
#------------------------------------------------------------
proc ::focus::move { focuserLabel command } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::move $command
   }
}

#------------------------------------------------------------
#  ::focus::incrementSpeed
#     incremente la vitesse du focus et appelle la procedure setSpeed
#     origin : origine de l'action (pad ou tool)
#------------------------------------------------------------
proc ::focus::incrementSpeed { focuserLabel origin } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::incrementSpeed $origin
   }
}

#------------------------------------------------------------
#  ::focus::setSpeed
#     change la vitesse du focus
#------------------------------------------------------------
proc ::focus::setSpeed { focuserLabel { value "0" } } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::setSpeed $value
   }
}

#------------------------------------------------------------
#  ::focus::goto
#     envoie le focaliseur a moteur pas a pas a une position predeterminee (AudeCom)
#------------------------------------------------------------
proc ::focus::goto { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::goto
   }
}

#------------------------------------------------------------
#  ::focus::displayCurrentPosition
#     affiche la position du moteur pas a pas si elle existe (AudeCom)
#------------------------------------------------------------
proc ::focus::displayCurrentPosition { focuserLabel } {
   if { "$focuserLabel" != "" } {
      if { [ info command ::$focuserLabel\::displayCurrentPosition ] != "" } {
         ::$focuserLabel\::displayCurrentPosition
      }
   }
}

#------------------------------------------------------------
#  ::focus::initPosition
#     initialise la position du focuser a 0
#------------------------------------------------------------
proc ::focus::initPosition { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::initPosition
   }
}

#------------------------------------------------------------
#  ::focus::possedeControleEtendu
#     retourne 1 si le telescope possede un controle etendu du focus (AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focus::possedeControleEtendu { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::possedeControleEtendu
   }
}

::focus::init

