#
# Fichier : usb_focus_cmd.tcl
# Description : Gere les commandes du focuser sur port serie
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id$
#

#==============================================================
# ::usb_focus::Procedures specifiques du plugin
#==============================================================

#  ::usb_focus::reset
#  ::usb_focus::setMaxPos
#  ::usb_focus::setSpeed
#  ::usb_focus::setSpeedIncr
#  ::usb_focus::setRot
#  ::usb_focus::getPosition
#  ::usb_focus::goto
#  ::usb_focus::stopMove
#  ::usb_focus::move
#  ::usb_focus::getTemperature
#  ::usb_focus::setTempMod
#  ::usb_focus::setCoefTemp
#  ::usb_focus::setSeuilTemp
#  ::usb_focus::getConf
#  ::usb_focus::createPort
#  ::usb_focus::waitAnswer
#  ::usb_focus::readPort
#  ::usb_focus::closePort
#  ::usb_focus::initValues
#  ::usb_focus::activeCmd

#  Notes :
#  1) la liaison est asynchrone et geree par fileevent
#  2) ::usb_focus::createPort retourne {0|1} selon l'echec ou la reussite
#  3) ::usb_focus::waitAnswer retourne la valeur lue sur le port serie
#     pour exploitation par les commandes de decodage et d'affichage des valeurs
#     ces commandes ne retournent rien
#  4) les microcommandes SEERAZ, Mnnnnn, SMO00n, SMAnnn, SMSTPF, SMSTPD, SMROTH, SMROTT
#     ne retournent rien; SGETAL est appellee pour rafraichir les valeurs concernees
#  5) les valeurs numeriques transmises au chip ont un format fixe et sont precedees avec des 0
#     ces 0 sont otes poir l'affichage et retablit pour le codage

#------------------------------------------------------------
#  ::usb_focus::reset
#     Retablit les parametres par defaut du controleur
#     Commade du bouton RESET
#------------------------------------------------------------
proc ::usb_focus::reset { } {
   variable widget
   variable private

   ::usb_focus::writePort "SEERAZ"

   #--   liste des valeurs par defaut du chip :
   #  motorsens stepincr motorspeed coef step version maxstep
   set private(attendu) [list 0 1 2 015 010 1217 65535]
   ::usb_focus::getConf
}

#------------------------------------------------------------
#  ::usb_focus::setMaxPos
#     Definit la position maximale
#     Commande du bouton SET
#------------------------------------------------------------
proc ::usb_focus::setMaxPos { } {
   variable widget
   variable private

   #--   formate le nombre de pas avec le 0 necessaires
   set formatValue [format "%05d" $widget(maxstep)]
   ::usb_focus::writePort M$formatValue

   set private(attendu) [lreplace $private(attendu) 6 6 $formatValue]
   ::usb_focus::getConf
}

#------------------------------------------------------------
#  ::usb_focus::setSpeed
#     change la vitesse du focus
#     Commande de la combox de selection de la vitesse
#------------------------------------------------------------
proc ::usb_focus::setSpeed { } {
   variable widget
   variable private

   ::usb_focus::writePort "SMO00$widget(motorspeed)"

   set private(attendu) [lreplace $private(attendu) 2 2 $widget(motorspeed)]
   ::usb_focus::getConf
}

#------------------------------------------------------------
#  ::usb_focus::setSpeedIncr
#     Fixe l'increment en half ou full step
#     Commande de la combox de selection de l'increment
#------------------------------------------------------------
proc ::usb_focus::setSpeedIncr { } {
   variable widget
   variable private

   set private(attendu) [lreplace $private(attendu) 1 1 $widget(stepincr)]

   #--   commute les sens et la valeur
   switch -exact $widget(stepincr) {
      0  { set cmd SMSTPF ; # full step
           set widget(stepincr) 1
         }
      1  { set cmd SMSTPD ; # half step
           set widget(stepincr) 0
         }
   }

   ::usb_focus::writePort "$cmd"

   ::usb_focus::getConf
}

#------------------------------------------------------------
#  ::usb_focus::setRot
#     change le sens de rotation du moteur
#     Commande des radiobutton de selection
#------------------------------------------------------------
proc ::usb_focus::setRot { } {
   variable widget
   variable private

   set private(attendu) [lreplace $private(attendu) 0 0 $widget(motorsens)]

   #--   commute les sens et la valeur
   switch -exact $widget(motorsens) {
      0  { set cmd SMROTH ; # clockwise
           set widget(motorsens) 1
         }
      1  { set cmd SMROTT ; # anticlockwise
           set widget(motorsens) 0
         }
   }

   ::usb_focus::writePort "$cmd"

   ::usb_focus::getConf
}

#------------------------------------------------------------
#  ::usb_focus::getPosition
#     Demande la position
#
#------------------------------------------------------------
proc ::usb_focus::getPosition { } {
   variable widget

   ::usb_focus::writePort FPOSRO

   #--   acquit == "P=vwxyz LFCR" ; longueur 9 car
   set answer [::usb_focus::waitAnswer 9]
   regexp -all {.+([0-9]{5}).+} $answer match position
   set widget(position) [string trimleft $position 0]
   if {$widget(position) eq ""} {
      set widget(position) 0
   }
   update
}

#------------------------------------------------------------
#  ::usb_focus::goto
#     envoie le focaliseur a moteur pas a pas a une position predeterminee
#     Commande du bouton GOTO
#------------------------------------------------------------
proc ::usb_focus::goto { } {
   variable widget

   #--   calcule l'ecart
   set dif [expr { $widget(target)-$widget(position) }]

   #--   formate le nombre de pas
   set n [format "%05d" [expr {abs($dif) }]]

   #--   definit le sens
   if {$dif > 0} {
      set cmd I$n
   } else {
      set cmd O$n
   }

   ::usb_focus::writePort $cmd

   #--   acquit == "*LFCR" ; longueur 3 car
   set answer [::usb_focus::waitAnswer 3]
   ::usb_focus::getPosition
}

#------------------------------------------------------------
#  ::usb_focus::stopMove
#     Arrete le mouvement
#     Commande du bouton STOP
#------------------------------------------------------------
proc ::usb_focus::stopMove { } {

   ::usb_focus::writePort QUITx

   #--   acquit *LFCR
   #::usb_focus::readPort 3

   ::usb_focus::getPosition
}

#------------------------------------------------------------
#  ::usb_focus::move
#     Commande des boutons + -
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#------------------------------------------------------------
proc ::usb_focus::move { command } {
   variable widget

   #--   formate n a la longueur voulue
   set n [format "%05d" $widget(nbstep)]

   if {$command eq "+"} {
      set cmd O$n
   } else {
      set cmd I$n
   }

   ::usb_focus::writePort $cmd

   #--   acquit *LFCR
   set answer [::usb_focus::waitAnswer 3]

   ::usb_focus::getPosition
}

#------------------------------------------------------------
#  ::usb_focus::getTemperature
#     Demande la temperature
#
#------------------------------------------------------------
proc ::usb_focus::getTemperature { } {
   variable widget

   ::usb_focus::writePort FTMPRO

   #--   acquit == "T=+/-xy.z LFCR" ; longueur 9 car
   set answer [::usb_focus::waitAnswer 9]
   regexp -all {.+([\+.0-9]{4}).+} $answer match widget(temperature)
   update
}

#------------------------------------------------------------
#  ::usb_focus::setTempMod
#     Commande du radiobutton de selection du mode automatique
#
#------------------------------------------------------------
proc ::usb_focus::setTempMod { } {
   variable widget

   ::console::affiche_resultat "setTempMod $widget(tempmode)\n"

   #--   selectionne la commande
   switch -exact $widget(tempmode) {
      0  {  ::usb_focus::writePort FMANUA ; # stoppe le mode auto
            #--   acquit == "!LFCR" ; longueur 3 car
            set answer [::usb_focus::waitAnswer 3]
         }
      1  {  ::usb_focus::writePort FAUTOM ; # demarre le mode de compensation automatique
            #--   acquit == "P=wxyz LFCR + T=+/-xy.z LFCR"
            set answer [::usb_focus::waitAnswer 19]
         }
   }
}

#------------------------------------------------------------
#  ::usb_focus::setCoefTemp
#     Fixe le coefficient de compensation lie a la temperature
#     Commande du bouton SET
#------------------------------------------------------------
proc ::usb_focus::setCoefTemp { } {
   variable widget

   set toSet $widget(coef)

   if {$toSet < 0} {
      set sign 0
   } else {
      set sign 1
   }

   set n [format "%03d" [expr { abs($toSet) }]]
   ::usb_focus::writePort  FLX$n

   after 50
   ::usb_focus::writePort FZSIG$sign

   #--   verification
   after 50
   ::usb_focus::writePort FREADA

   #--   acquit == "A=0xyz" : longueur 9 car
   set answer [::usb_focus::waitAnswer 6]
   set coef [string range $answer 3 5]
   set coef [string trimleft $coef 0]

   ::usb_focus::writePort FTxxxA

   #--   acquit == "A=x" : longueur 3 car
   set answer [::usb_focus::waitAnswer 3]

   set sign [string index $answer 2]
   if {$sign ==1} {
      set widget(coef) "+$coef"
   } else {
      set widget(coef) "-$coef"
   }

   if {$toSet == $widget(coef)} {
      ::console::affiche_resultat "ok\n"
   }
}

#------------------------------------------------------------
#  ::usb_focus::setSeuilTemp
#     Fixe le seuil min de compensation
#
#------------------------------------------------------------
proc ::usb_focus::setSeuilTemp { } {
   variable widget
   variable private

   set n [format "%03d" $widget(step)]
   ::usb_focus::writePort SMA$n

   set private(attendu) [lreplace $private(attendu) 4 4 $n]
   ::usb_focus::getConf
}

#------------------------------------------------------------
#  ::usb_focus::getConf
#     Demande les parametres de configuration
#
#------------------------------------------------------------
proc ::usb_focus::getConf { } {
   variable widget
   variable private

   ::usb_focus::writePort SGETAL

   #--   acquit == longueur 28 car
   set answer [::usb_focus::waitAnswer 28]
   regsub -all {[C=-]} $answer " " answer
   set private(values) [string trimleft $answer " "]

   #--   verifie qu'il n'y a pas d'erreur
   package require struct::set
   if {[::usb_focus::isReady] == 0} {
      set private(attendu) $private(values)
   } else {
      if {![::struct::set equal $private(attendu) $private(values)]} {
         ::console::affiche_resultat "\nattendu $private(attendu)\nobtenu $private(values)\n"
      } else {
         ::console::affiche_resultat "ok\n"
      }
   }

   lassign $private(values) widget(motorsens) widget(stepincr) widget(motorspeed) \
      coef step widget(version) maxstep

   #--   ote les 0 inutiles
   if {$step < 0} {
      set widget(coef) "-[string trimleft $coef 0]"
   } else {
      set widget(coef) "+[string trimleft $coef 0]"
   }
   set private(prev,coef) $widget(coef)
   set widget(step) "[string trimleft $step 0]"
   set private(prev,step) $widget(step)
   set widget(maxstep) "[string trimleft $maxstep 0]"
   set private(prev,maxstep)  $widget(maxstep)

   update
}

#------------------------------------------------------------
#  ::usb_focus::createPort
#     Etablit la liaison
#
#  return answer { 0 == echec | 1 == ok}
#------------------------------------------------------------
proc ::usb_focus::createPort { port } {
   variable widget
   variable private

   if { $::tcl_platform(platform) == "unix" } {
      set port [ string tolower [ string trim $port ] ]
      set num [ expr [ string index $port 3 ] - 1 ]
      set port /dev/ttyS$num
   }

  if {[catch {
      set tty [open $port r+]
      set private(tty) $tty
      after 10
      chan configure $tty -mode "19200,n,8,1" \
         -blocking 0 -buffering none
      } errmsg]} {
      ::console::affiche_resultat "err $errmsg\n"
      return 0
  } else {
      return 1
  }
}

#------------------------------------------------------------
#  ::usb_focus::writePort
#     envoie une commande sur le port serie
#
#------------------------------------------------------------
proc ::usb_focus::writePort { command } {
   variable private

   chan puts -nonewline $private(tty) $command
   #--   force la sortie
   chan flush $private(tty)
}

#------------------------------------------------------------
#  ::usb_focus::waitAnswer
#     lit n caracteres sur le port serie de maniere asynchrone
#     appellee par toutes les commandes qui demandent reponse
#  return usb_focus_answer
#------------------------------------------------------------
proc ::usb_focus::waitAnswer { car } {
   variable private
   global usb_focus_answer

   set usb_focus_answer ""
   fileevent $private(tty) readable "::usb_focus::readPort $private(tty) $car"
   vwait usb_focus_answer
   return $usb_focus_answer
}

#------------------------------------------------------------
#  ::usb_focus::readPort
#     lit n caracteres sur le port serie
#     proc de fileevent de waitAnswer
#------------------------------------------------------------
proc ::usb_focus::readPort { tty nbcar } {
   global usb_focus_answer

   chan configure $tty -blocking 1
   set usb_focus_answer [chan read $tty $nbcar]
   #::console::affiche_resultat "readPort $usb_focus_answer [string length $usb_focus_answer]\n"
   chan configure $tty -blocking 0
}

#------------------------------------------------------------
#  ::usb_focus::closePort
#     Ferme la liaison
#
#------------------------------------------------------------
proc ::usb_focus::closePort { } {
   variable private

   if {$private(tty) ne ""} {
      chan close $private(tty)
      ::usb_focus::initVar
      #--   inhibe les commandes
      ::usb_focus::setState disabled
   }
}

#------------------------------------------------------------
#  ::usb_focus::initValues
#     Met a jour la fenetre avec les valeurs lues dans le chip
#     Lancee par ::usb_focus::createPort
#------------------------------------------------------------
proc ::usb_focus::initValues {} {
   variable private

   #--   initialise le mode
  ::usb_focus::writePort FMMODE

   #--   acquit == "!LFCR" ; longueur 3 car
   set answer [::usb_focus::waitAnswer 3]

   #--   lit les parametres de conf de usb_focus
   ::usb_focus::getConf

   #--   affiche la position et la temperature
   ::usb_focus::getPosition
   ::usb_focus::getTemperature

   #--   desinhibe les commandes
   #--   (si aucune erreur)
   ::usb_focus::setState normal
   update
}

#------------------------------------------------------------
#  ::usb_focus::activeCmd
#     Transmet l'orde et attend l'acquit
#
#  return answer {!|*} ; ! pour le mode, * acquit
#------------------------------------------------------------
proc ::usb_focus::activeCmd { cmd {n ""} } {
   variable private

   ::usb_focus::writePort FAMODE

   #--   acquit == ALFCR
   set answer [::usb_focus::readPort 3]
   ::console::affiche_resultat "activeCmd $answer\n"
}
