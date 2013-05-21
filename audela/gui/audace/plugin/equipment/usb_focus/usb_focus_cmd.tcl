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
#  ::usb_focus::setSeuilTemp
#  ::usb_focus::getConf
#  ::usb_focus::setCoefTemp
#  ::usb_focus::getPosition
#  ::usb_focus::getTemperature
#  ::usb_focus::goto
#  ::usb_focus::move
#  ::usb_focus::getTemperature
#  ::usb_focus::setTempMod
#  ::usb_focus::createPort
#  ::usb_focus::waitAnswer
#  ::usb_focus::readPort
#  ::usb_focus::closePort
#  ::usb_focus::initFromChip
#  ::usb_focus::activeCmd
#  ::usb_focus::stopMove
#  ::usb_focus::trimZero

#  Notes :
#  1) la liaison est asynchrone et geree par fileevent
#  2) ::usb_focus::createPort retourne {0|1} selon l'echec ou la reussite
#  3) ::usb_focus::waitAnswer retourne la valeur lue sur le port serie
#     pour exploitation par les commandes de decodage et d'affichage des valeurs
#  4) les microcommandes SEERAZ, Mnnnnn, SMO00n, SMAnnn, SMSTPF, SMSTPD, SMROTH, SMROTT
#     ne retournent rien; SGETAL est appellee pour rafraichir les valeurs concernees
#  5) les valeurs numeriques transmises au chip ont un format fixe et sont precedees avec des 0
#     ces 0 sont otes poir l'affichage et retablit pour le codage
#  6) les commandes qui prennent un temps appreciable (move, goto, setTempMod)
#     provoquent l'inhibtion des commandes; elles sont liberees a la fin de la proc

#------------------------------------------------------------
#  ::usb_focus::reset
#     Retablit les parametres par defaut du controleur
#     Commade du bouton RESET
#------------------------------------------------------------
proc ::usb_focus::reset { } {
   variable widget
   variable private

   ::usb_focus::writePort "SEERAZ"

   #--   liste des valeurs par defaut du chip, dans l'ordre :
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

   #--   reponse attendue == longueur 28 car
   set answer [::usb_focus::waitAnswer 28]
   regsub -all {[C=-]} $answer " " answer
   set private(values) [string trimleft $answer " "]

   #--   verifie qu'il n'y a pas d'erreur
   package require struct::set
   if {[::usb_focus::isReady] == 0} {
      set private(attendu) $private(values)
   } else {
      if {![::struct::set equal $private(attendu) $private(values)]} {
         #--   message console si une commande n'a pas ete executee
         ::console::affiche_resultat "\nattendu $private(attendu)\nobtenu $private(values)\n"
      } else {
         ::console::affiche_resultat "ok\n"
      }
   }

   lassign $private(values) widget(motorsens) widget(stepincr) widget(motorspeed) \
      coef step widget(version) maxstep

   #--   ote les 0 inutiles
   set widget(step) [::usb_focus::trimZero $step]
   set private(prev,step) $widget(step)

   set widget(maxstep) [::usb_focus::trimZero $maxstep]
   set private(prev,maxstep) $widget(maxstep)

   set coef [::usb_focus::trimZero $coef]
   #--   complete coef avec le sign
   ::usb_focus::writePort FTxxxA

   #--   reponse attendue == "A=x" : longueur 3 car
   regsub -all {[A=]} [::usb_focus::waitAnswer 3] "" sign

   if {$sign == 0} {
      set widget(coef) "-$coef"
   } else {
      set widget(coef) "+$coef"
   }

   if {$widget(coef) == $private(prev,coef)} {
      ::console::affiche_resultat "ok\n"
   }
}

#------------------------------------------------------------
#  ::usb_focus::setCoefTemp
#     Fixe le coefficient de compensation lie a la temperature
#     Commande du bouton SET
#------------------------------------------------------------
proc ::usb_focus::setCoefTemp { } {
   variable widget
   variable private

   if {$widget(coef) < 0} {
      set sign 0
   } else {
      set sign 1
   }

   set n [format "%03d" [expr { abs($widget(coef)) }]]
   ::usb_focus::writePort  FLX$n

   #after 50
   ::usb_focus::writePort FZSIG$sign

   #--   verification
   #after 50
   ::usb_focus::writePort FREADA

   #--   reponse attendue == "A=0xyz" : longueur 9 car
   set coef [string range [::usb_focus::waitAnswer 6] 3 5]
   set coef [string trimleft $coef 0]

   ::usb_focus::writePort FTxxxA

   #--   reponse attendue == "A=x" : longueur 3 car
   regsub -all {[A=]} [::usb_focus::waitAnswer 3] "" sign
   if {$sign ==1} {
      set widget(coef) "+$coef"
   } else {
      set widget(coef) "-$coef"
   }

   if {$widget(coef) == $private(prev,coef)} {
      ::console::affiche_resultat "ok\n"
   }
}

#------------------------------------------------------------
#  ::usb_focus::goto
#     envoie le focaliseur a moteur pas a pas a une position predeterminee
#     Commande du bouton GOTO
#------------------------------------------------------------
proc ::usb_focus::goto { } {
   variable widget

   #--   inhibe les commandes
   ::usb_focus::setState disabled

   #--   calcule l'ecart
   set dif [expr { $widget(target)-[string trimleft $widget(position) 0] }]

   #--   formate le nombre de pas
   set n [format "%05d" [expr {abs($dif) }]]

   #--   definit le sens
   if {$dif < 0} {
      set cmd I$n
   } else {
      set cmd O$n
   }

   ::usb_focus::writePort $cmd

   #--   reponse attendue == "*LFCR" ; longueur 3 car
   set answer [::usb_focus::waitAnswer 3]
   ::usb_focus::getPosition

   #--   libere les commandes
   ::usb_focus::setState normal
}

#------------------------------------------------------------
#  ::usb_focus::move
#     Commande des boutons + -
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#------------------------------------------------------------
proc ::usb_focus::move { command } {
   variable widget

   #--   inhibe les commandes
   ::usb_focus::setState disabled

   #--   formate n a la longueur voulue
   set n [format "%05d" $widget(nbstep)]

   if {$command eq "+"} {
      set cmd O$n
   } else {
      set cmd I$n
   }

   ::usb_focus::writePort $cmd

   #--   reponse attendue *LFCR
   set answer [::usb_focus::waitAnswer 3]

   ::usb_focus::getPosition

   #--   libere les commandes
   ::usb_focus::setState normal
}

#------------------------------------------------------------
#  ::usb_focus::getPosition
#     Demande la position
#
#------------------------------------------------------------
proc ::usb_focus::getPosition { } {
   variable widget

   ::usb_focus::writePort FPOSRO

   #--   reponse attendue == "P=vwxyz LFCR" ; longueur 9 car
   regsub -all {[P=]} [::usb_focus::waitAnswer 9] "" widget(position)
}

#------------------------------------------------------------
#  ::usb_focus::getTemperature
#     Demande la temperature
#
#------------------------------------------------------------
proc ::usb_focus::getTemperature { } {
   variable widget

   ::usb_focus::writePort FTMPRO

   #--   reponse attendue == "T=+/-xy.z LFCR" ; longueur 9 car
   regsub -all {[T=]} [::usb_focus::waitAnswer 9] "" temperature
   set widget(temperature) "$temperature °C"
}

#------------------------------------------------------------
#  ::usb_focus::setTempMod
#     Commande du radiobutton de selection du mode automatique
#
#------------------------------------------------------------
proc ::usb_focus::setTempMod { } {
   variable widget

   #--   selectionne la commande
   switch -exact $widget(tempmode) {
      0  {  ::usb_focus::writePort FMANUA ; # stoppe le mode auto

            #--   reponse attendue == "!LFCR" ; longueur 3 car
            set answer [::usb_focus::waitAnswer 3]
         }
      1  {  ::usb_focus::writePort FAUTOM ; # demarre le mode de compensation automatique

            #--   inhibe les commandes
            #::usb_focus::setState disabled

            #--   reponse attendue == "A..P=wxyz LFCR + T=+/-xy.z LFCR"
            regsub -all {[APT=]} [::usb_focus::waitAnswer 21] " " answer
            lassign $answer widget(position) widget(temperature)

            #--   libere les commandes
            #::usb_focus::setState normal
         }
   }
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

      #--   message d'erreur
      ::console::affiche_resultat "error : $errmsg\n"

      return 0
  } else {
      ::usb_focus::initFromChip
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

   #--   ote les LF et CR dans l'ensemble du message
   regsub -all {[\n\r]} [chan read $tty $nbcar] "" usb_focus_answer

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
   }
}

#------------------------------------------------------------
#  ::usb_focus::initFromChip
#     Met a jour la fenetre avec les valeurs lues dans le chip
#     Lancee par ::usb_focus::createPort
#------------------------------------------------------------
proc ::usb_focus::initFromChip {} {
   variable private

   #--   initialise le mode
   ::usb_focus::writePort FMMODE

   #--   reponse attendue == "!LFCR" ; longueur 3 car
   set answer [::usb_focus::waitAnswer 3]

   #--   lit les parametres de conf de usb_focus
   ::usb_focus::getConf

   #--   affiche la position et la temperature
   ::usb_focus::getPosition
   ::usb_focus::getTemperature

   #--   desinhibe les commandes (si aucune erreur)
   ::usb_focus::setState normal
   update
}

#------------------  a verifier -----------------------------

#------------------------------------------------------------
#  ::usb_focus::activeCmd
#     Transmet l'orde et attend l'reponse attendue
#
#  return answer {!|*} ; ! pour le mode, * reponse attendue
#------------------------------------------------------------
proc ::usb_focus::activeCmd { cmd {n ""} } {
   variable private

   ::usb_focus::writePort FAMODE

   #--   reponse attendue == ALFCR
   set answer [::usb_focus::readPort 3]
   ::console::affiche_resultat "activeCmd $answer\n"
}

#------------------------------------------------------------
#  ::usb_focus::stopMove
#     Arrete le mouvement
#     Commande du bouton STOP
#------------------------------------------------------------
proc ::usb_focus::stopMove { } {

   ::usb_focus::writePort QUITx

   #--   reponse attendue *LFCR
   set answer [::usb_focus::readPort 3]

   ::usb_focus::getPosition
}

#------------------------------------------------------------
#  ::usb_focus::trimZero
#     ote les zeo inutiles
#------------------------------------------------------------
proc ::usb_focus::trimZero { val } {

   set val "[string trimleft $val 0]"
   if {[llength $val ] ==0} {
      set $val  0
   }

   return $val
}
