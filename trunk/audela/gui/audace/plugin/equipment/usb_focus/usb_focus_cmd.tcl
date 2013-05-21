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
#  ::usb_focus::refreshAll
#  ::usb_focus::setCoefTemp
#  ::usb_focus::getPosition
#  ::usb_focus::getTemperature
#  ::usb_focus::goto
#  ::usb_focus::move
#  ::usb_focus::stopMove
#  ::usb_focus::getTemperature
#  ::usb_focus::setTempMod
#  ::usb_focus::createPort
#  ::usb_focus::waitAnswer
#  ::usb_focus::readPort
#  ::usb_focus::closePort
#  ::usb_focus::initFromChip
#  ::usb_focus::trimZero

#  Notes :
#  1) la liaison est asynchrone et geree par fileevent
#  2) ::usb_focus::createPort retourne {0|1} selon l'echec ou la reussite
#  3) ::usb_focus::waitAnswer retourne la valeur lue sur le port serie
#     pour exploitation par les commandes de decodage et d'affichage des valeurs
#  4) les microcommandes SEERAZ, Mnnnnn, SMO00n, SMAnnn, SMSTPF, SMSTPD, SMROTH, SMROTT
#     ne retournent rien; SGETAL est appellee pour rafraichir les valeurs concernees
#  5) les valeurs numeriques transmises au chip ont un format fixe et sont precedees avec des 0
#     ces 0 sont otes pour l'affichage et retablis pour le codage
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

   #--   liste des valeurs par defaut du chip, dans l'ordre :
   #  motorsens stepincr motorspeed coef step version maxstep
   set private(attendu) [list 0 1 2 015 010 1217 65535]

   set private(command) "SEERAZ"
   ::usb_focus::writeControl1
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

   set private(attendu) [lreplace $private(attendu) 6 6 $formatValue]

   set private(command) "M$formatValue"
   ::usb_focus::writeControl1
}

#------------------------------------------------------------
#  ::usb_focus::setSpeed
#     change la vitesse du focus
#     Commande de la combox de selection de la vitesse
#------------------------------------------------------------
proc ::usb_focus::setSpeed { } {
   variable widget
   variable private

   set private(attendu) [lreplace $private(attendu) 2 2 $widget(motorspeed)]

   set private(command) "SMO00$widget(motorspeed)"
   ::usb_focus::writeControl1
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
      0  { set private(command) "SMSTPD" ; # half step }
      1  { set private(command) "SMSTPF" ; # full step }
   }
   ::usb_focus::writeControl1
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
      0  { set private(command) "SMROTH" ; # clockwise }
      1  { set private(command) "SMROTT" ; # anticlockwise }
   }
   ::usb_focus::writeControl1
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
   set private(attendu) [lreplace $private(attendu) 4 4 $n]
   set private(command) "SMA$n"
   ::usb_focus::writeControl1
}

#------------------------------------------------------------
#  ::usb_focus::refreshAll
#     Demande les parametres de configuration
#
#------------------------------------------------------------
proc ::usb_focus::refreshAll { } {
   variable widget
   variable private

   set private(command) "SGETAL"
   ::usb_focus::writePort

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

   #--   formate les valeurs
   lassign $private(values) widget(motorsens) widget(stepincr) widget(motorspeed) \
      coef step widget(version) maxstep

   #--   ote les 0 inutiles
   set widget(step) [::usb_focus::trimZero $step]
   set private(prev,step) $widget(step)

   set widget(maxstep) [::usb_focus::trimZero $maxstep]
   set private(prev,maxstep) $widget(maxstep)

   set coef [::usb_focus::trimZero $coef]
   #--   complete coef avec le sign
    set private(command) "FTxxxA"
   ::usb_focus::writePort

   #--   reponse attendue == "A=x" : longueur 3 car
   regsub -all {[A=]} [::usb_focus::waitAnswer 3] "" sign

   if {$sign == 0} {
      set widget(coef) "-$coef"
   } else {
      set widget(coef) "+$coef"
   }

   #--   affiche la position et la temperature
   ::usb_focus::getPosition
   ::usb_focus::getTemperature
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
   set private(command) "FLX$n"
   ::usb_focus::writePort

   after 50
   set private(command) "FZSIG$sign"
   ::usb_focus::writePort

   after 50
   #--   verification
   set private(command) "FREADA"
   ::usb_focus::writePort

   after 50

   #--   reponse attendue == "A=0xyz" : longueur 6 car
   set coef [string trimleft [::usb_focus::waitAnswer 6] 0]

   set private(command) "FTxxxA"
   ::usb_focus::writePort

   #--   reponse attendue == "A=x" : longueur 3 car
   if {[::usb_focus::waitAnswer 3] == 1} {
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
#     Envoie le focaliseur a moteur pas a pas a une position predeterminee
#     Commande du bouton GOTO
#------------------------------------------------------------
proc ::usb_focus::goto { } {
   variable widget
   variable private

   #--   calcule l'ecart
   set dif [expr { $widget(target)-[string trimleft $widget(position) 0] }]

   #--   formate le nombre de pas
   set n [format "%05d" [expr {abs($dif) }]]

   #--   definit le sens
   if {$dif < 0} {
      set private(command) I$n
   } else {
      set private(command) O$n
   }
   ::usb_focus::writeControl2
}

#------------------------------------------------------------
#  ::usb_focus::move
#     Commande des boutons + -
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#------------------------------------------------------------
proc ::usb_focus::move { command } {
   variable widget
   variable private

   #--   formate n a la longueur voulue
   set n [format "%05d" $widget(nbstep)]

   if {$command eq "+"} {
      set private(command) O$n
   } else {
      set private(command) I$n
   }
   ::usb_focus::writeControl2
}

#------------------------------------------------------------
#  ::usb_focus::stopMove
#     Arrete le mouvement
#     Commande du bouton STOP
#------------------------------------------------------------
proc ::usb_focus::stopMove { } {
   variable private

   #--   delai d'attente avant de prendre la position ????
   set private(command) "FQUITx"
   ::usb_focus::writeControl2
}

#------------------------------------------------------------
#  ::usb_focus::getPosition
#     Demande la position
#
#------------------------------------------------------------
proc ::usb_focus::getPosition { } {
   variable widget
   variable private

   set private(command) "FPOSRO"
   ::usb_focus::writePort

   #--   reponse attendue == "P=vwxyz LFCR" ; longueur 9 car
   set widget(position) [::usb_focus::waitAnswer 9]
}

#------------------------------------------------------------
#  ::usb_focus::getTemperature
#     Demande la temperature
#
#------------------------------------------------------------
proc ::usb_focus::getTemperature { } {
   variable widget
   variable private

   set private(command) "FTMPRO"
   ::usb_focus::writePort

   #--   reponse attendue == "T=+/-xy.z LFCR" ; longueur 9 car
   set widget(temperature) "[::usb_focus::waitAnswer 9] °C"
}

#------------------------------------------------------------
#  ::usb_focus::setTempMod
#     Commande du radiobutton de selection du mode automatique
#
#------------------------------------------------------------
proc ::usb_focus::setTempMod { } {
   variable widget
   variable private

   #--   selectionne la commande
   switch -exact $widget(tempmode) {
      0  {  set private(command) "FMANUA" ; # stoppe le mode auto
            ::usb_focus::writePort

            #--   reponse attendue == "!LFCR" ; longueur 3 car
            set answer [::usb_focus::waitAnswer 3]
         }
      1  {  set private(command) "FAUTOM" ; # demarre le mode de compensation automatique
            ::usb_focus::writePort

            #--   inhibe les commandes
            #::usb_focus::setState disabled 1

            #--   reponse attendue == "A..P=wxyz LFCR + T=+/-xy.z LFCR"
            regsub -all {[APT=]} [::usb_focus::waitAnswer 21] " " answer
            lassign $answer widget(position) widget(temperature)

            #--   libere les commandes
            #::usb_focus::setState normal 1
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
proc ::usb_focus::writePort { } {
   variable private

   chan puts -nonewline $private(tty) $private(command)
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
   variable private
   global usb_focus_answer

   set entities [list "\n" "" "\r" "" A "" T "" P "" = "" " " ""]

   chan configure $tty -blocking 1
   #--   ote les LF et CR dans l'ensemble du message
   set answer [chan read $tty $nbcar]
   chan configure $tty -blocking 0
   #regsub -all {[\n\r]} $answer "" usb_focus_answer
   set usb_focus_answer [string map $entities $answer]

   #--   debug
   ::console::affiche_resultat "$private(command) --> $usb_focus_answer [string length $answer] [string length $usb_focus_answer]\n"
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
#     en mode manuel
#     Lancee par ::usb_focus::createPort
#------------------------------------------------------------
proc ::usb_focus::initFromChip {} {
   variable private

   #--   initialise le mode
   set private(command) "FMANUA"

   ::usb_focus::writePort

   #--   reponse attendue == "!LFCR" ; longueur 3 car
   set answer [::usb_focus::waitAnswer 3]

   #--   lit les parametres de conf de usb_focus
   ::usb_focus::refreshAll

   #--   desinhibe les commandes
   ::usb_focus::setState normal
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

#------------------------------------------------------------
#  ::usb_focus::writeControl1
#   Controle avec les parametres de conf de usb_focus et la position
#------------------------------------------------------------
proc ::usb_focus::writeControl1 { } {
   ::usb_focus::writePort
   ::usb_focus::refreshAll
}

#------------------------------------------------------------
#  ::usb_focus::writeControl2
#   Controle  avec le retour
#------------------------------------------------------------
proc ::usb_focus::writeControl2 { } {

   #--   inhibe les commandes
   ::usb_focus::setState disabled 1

   ::usb_focus::writePort

   #--   reponse attendue "*LFCR" ou "!LFCR" ; longueur 3 car
   if {[::usb_focus::waitAnswer 3] in [list "*" "!"]} {
      ::usb_focus::getPosition
      #--   libere les commandes
      ::usb_focus::setState normal 1
   }
}

