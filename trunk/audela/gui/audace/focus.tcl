#
# Fichier : focus.tcl
# Description : Centralise les commandes du focus du telescope
# Auteur : Michel PUJOL
# Mise a jour $Id: focus.tcl,v 1.5 2007-02-03 20:22:48 robertdelmas Exp $
#

namespace eval ::focus {

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
#------------------------------------------------------------
proc ::focus::incrementSpeed { focuserLabel} {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::incrementSpeed
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
#  ::focus::possedeControleEtendu
#     retourne 1 si le telescope possede un controle etendu du focus (AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focus::possedeControleEtendu { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::possedeControleEtendu
   }
}

