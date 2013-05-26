#
# Fichier : focus.tcl
# Description : Centralise les commandes du focus du telescope
# Auteur : Michel PUJOL
# Mise à jour $Id$
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
      if { [::focus::possedeControleEtendu $focuserLabel] == 1 } {
         set ::audace(focus,currentFocus) [getPosition $focuserLabel]
      }
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
#     envoie le focaliseur a moteur pas a pas a une position predeterminee (AudeCom + USB_Foc)
#------------------------------------------------------------
proc ::focus::goto { focuserLabel { blocking 0 } { gotoButton "" } } {
   variable private
   if { "$focuserLabel" != "" } {

      #--- Gestion des boutons Goto et Match
      if { $gotoButton != "" } {
         $gotoButton configure -state disabled
         update
      }

      set catchError [catch {
         ::$focuserLabel\::goto $blocking

         if { $blocking == 0 } {
            #--- Boucle tant que le focus n'est pas arretee (si on n'utilise pas le mode bloquant du goto)
            set position [::focus::getPosition $focuserLabel]
            #--- j'attends que le focus commence a bouger
            #--- car sinon la boucle de surveillance va considerer que les
            #--- coordonnees n'ont pas changé et va s'arreter immediatement
            after 500
            set private(gotoIsRunning) 1
            set derniereBoucle [ ::focus::surveille_goto $focuserLabel $position ]
            if { $derniereBoucle == 1 } {
               #--- j'attends que la variable soit remise a zero
               vwait ::focus::private(gotoIsRunning)
            }
         } else {
            displayCurrentPosition $focuserLabel
         }
      }]

      #--- je reactive du bouton
      if { $gotoButton != "" } {
         $gotoButton configure -state normal
         update
      }

      if { $catchError != 0 } {
        error $::errorInfo
     }
   }
}

#------------------------------------------------------------
# surveille_goto
#    Surveille si la fonction goto est active
#
# Parametres :
#    position    : position du focuser
# Return :
#    0 si derniere boucle
#    1 si nouvelle boucle est lancee
#------------------------------------------------------------
proc ::focus::surveille_goto { focuserLabel position } {
   variable private

   set position1 [::focus::getPosition $focuserLabel]
   if { $position1 == "" } {
      #--- j'arrete la boucle de surveillance car les coordonnees n'ont pas pu etre recuperees
      set private(gotoIsRunning) "0"
      return 0
   }
   if { [expr abs($position - $position1) ] > 0.1 } {
      after 500 ::focus::surveille_goto $focuserLabel $position1
      #--- je retourne 1 pour signaler que ce n'est pas pas la derniere boucle
      return 1
   } else {
      #--- j'arrete la surveillance car le GOTO est termine
      set private(gotoIsRunning) "0"
      return 0
   }
}

#------------------------------------------------------------
#  ::focus::displayCurrentPosition
#     affiche la position du moteur pas a pas si elle existe (AudeCom + USB_Foc)
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
#  ::focus::getPosition
#     affiche la position du moteur pas a pas si elle existe
#------------------------------------------------------------
proc ::focus::getPosition { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::getPosition
   }
}

#------------------------------------------------------------
#  ::focus::possedeControleEtendu
#     retourne 1 si le telescope possede un controle etendu du focus (AudeCom + USB_Foc)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focus::possedeControleEtendu { focuserLabel } {
   if { "$focuserLabel" != "" } {
      ::$focuserLabel\::possedeControleEtendu
   }
}

::focus::init

