#
# Fichier : usb_focus_cmd.tcl
# Description : Gere les commandes du focuser sur port serie
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id$
#

#==============================================================
# ::usb_focus::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::usb_focus::goto
#     envoie le focaliseur a moteur pas a pas a une position predeterminee
#------------------------------------------------------------
proc ::usb_focus::goto { } {
   variable widget
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   set targetValue $widget(target)

   #--   arrete si erreur de saisie
   if {[::usb_focus::Cntrl $widget(target) 65535]} {
      return
   }

   #--   calcule l'ecart
   set dif [expr { $widget(target)-$widget(position) }]

   ::console::affiche_resultat "goto $widget(target) $widget(position) $dif\n"


   #--   definit le sens
   if {$dif > 0} {
      set cmd moveIn
   } else {
      set cmd moveOut
   }

   #--   formate le nombre de pas
   set steps [format "%05d" [expr {abs($dif) }]]

   ::console::affiche_resultat "goto cmd $cmd steps $steps\n"

   ::usb_focus::activeCmd $cmd $steps

   ::usb_focus::getPosition
}

#------------------------------------------------------------
#  ::usb_focus::StopMove
#     Arrete le mouvement
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::stopMove { } {
   variable private

   puts -nonewline $private(tty) QUITx
   after $private(tempo)
   gets $private(tty) answer
   after $private(tempo)
   ::usb_focus::getPosition
}

#------------------------------------------------------------
#  ::usb_focus::move
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#------------------------------------------------------------
proc ::usb_focus::move { command } {
   variable widget

   if { ![isReady] == 1 || $command ni [list + -]} { return }

   if {$command eq "+"} {
      set c I ; #
   } else {
      set c O ; #
   }

   ::usb_focus::activeCmd  $c $widget(nbstep)
}


#------------------------------------------------------------
#  ::usb_focus::setMaxPos
#
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::setMaxPos { } {
   variable widget
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   set answer ""
   set newValue $widget(maxstep)

   if {[::usb_focus::Cntrl $newValue 65535] != 0} {

      #--   memorise la nouvelle valeur
      set private(prev,maxstep) $newValue

      if {[isReady] == 1} {
         puts -nonewline  $private(tty) "M$widget(maxstep)"
         after $private(tempo)
         set answer [read $private(tty) 3]
      }

   } else {

      #--   retablit l'ancienne valeur
      set widget(maxstep) $private(prev,maxstep)
   }

   ::usb_focus::getConf $private(tty)

   ::console::affiche_resultat "$$newValue $widget(maxstep) $answer\n"

   return $answer
}

#------------------------------------------------------------
#  ::usb_focus::setSpeed
#     change la vitesse du focus
#     Commande de la combox de selection de la vitesse
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::setSpeed { } {
   variable widget
   variable private

   set answer ""

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   puts -nonewline  $private(tty) "SMO00$widget(motorspeed)"
   after $private(tempo)

   ::usb_focus::getConf $private(tty)

   return $answer
}

#------------------------------------------------------------
#  ::usb_focus::setRot
#     change le sens de rotation du moteur
#     Commande de la combox de selection du sens de rotation
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::setRot { w } {
   variable widget
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   set widget(motorsens) [lsearch [$w cget -values] $widget(rot)]

   #--   selectionne la commande
   switch -exact $widget(motorsens) {
      0  { set cmd SMROTT }
      1  { set cmd SMROTH }
   }

   puts -nonewline $private(tty) $cmd

   ::usb_focus::getConf $private(tty)
}

#------------------------------------------------------------
#  ::usb_focus::setStep
#     Fixe l'increment en half ou full step
#     Commande de la combox de selection de l'increment
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::setStep { w } {
   variable widget
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   set widget(stepincr) [lsearch [$w cget -values] $widget(step)]

   #--   selectionne la commande
   switch -exact $widget(stepincr) {
      0  { set cmd SMSTPD }
      1  { set cmd SMSTPF }
   }

   puts -nonewline  $private(tty) $cmd

   ::usb_focus::getConf $private(tty)
}

#------------------------------------------------------------
#  ::usb_focus::getPosition
#     Demande la position
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::getPosition { } {
   variable widget
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   puts -nonewline  $private(tty) "FPOSRO"
   after $private(tempo)
   set res [read $private(tty) 9]

   regexp -all {.+([0-9]{5}).+} $res match widget(position)
   update
}

#------------------------------------------------------------
#  ::usb_focus::getTemperature
#     Demande la temperature
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::getTemperature { } {
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   puts -nonewline $private(tty) "FTMPRO"
   after $private(tempo)
   set res [read $private(tty) 9]
   regexp -all {.+([\+.0-9]{4}).+} $res match private(temperature)
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

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   #--   teste n
   if {$n ne ""} {
      #--   fixe la limite superieure de n
      if {$cmd in [list setMax moveIn moveIn]} {
         set limit "65535"
      }  elseif {$cmd eq "x"} {
        set limit "999"
      }
      #--   verifie la validite de n
      if {[::usb_focus::Cntrl $n $limit]} {
         return
      }
   }

   switch -exact $cmd {
      mmode       {set c "FMMODE" ; # demarre le mode de compensation automatique de la temperature}
      automode    {set c "FAMODE" ; # stoppe le mode de compensation automatique de la temperature}
      compmanual  {set c "FMANUA" ; # stoppe le mode automatique}
      compaut     {set c "FAUTOM" ; # stoppe le mode automatique}
      moveIn      {set c "I$n"    ; # Deplace de n pas vers l'interieur}
      moveOut     {set c "O$n"    ; # Deplace de n pas vers l'exterieur}
      setMax      {set c "M$n"    ; # fixation du nb maximum }
      x           {set c "FLX$n"  ; #fixation du nb minimum }
   }

   puts -nonewline $private(tty) $c
   after $private(tempo)
   gets $private(tty) answer

   set private(mode) $answer

   ::console::affiche_resultat "activeCmd $c $private(mode)\n"

   return $answer
}

#------------------------------------------------------------
#  ::usb_focus::getConf
#     Demande les parametres de configuration
#
#  return value
#------------------------------------------------------------
proc ::usb_focus::getConf { tty } {
   variable widget
   variable private

   set fr "$private(frm).frame1.motor"
   set result ""

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   puts -nonewline $tty "SGETAL"
   while {[llength $result] == 0} {
      after $private(tempo)
      gets $tty result
   }

   #--   transforme en liste
   regsub -all {[C=-]} $result " " private(values)

   ::console::affiche_resultat "getConf $private(values)\n"

   if {[llength $private(values)] == 7} {

      lassign $private(values) widget(motorsens) widget(stepincr) widget(motorspeed) \
         widget(coeftemp) widget(steptemp) widget(version) widget(maxstep)

      #--   met a jour la combobox du sens de rotation
      set widget(rot) [lindex [$fr.rot cget -values] $widget(motorsens)]

      #--   met a jour la combobox de l'increment de deplacement
      set widget(step) [lindex [$fr.incrStep cget -values] $widget(stepincr)]

      update
   }
}

#------------------------------------------------------------
#  ::usb_focus::reset
#     Retablit les parametres par defau du controleur
#     Commade du bouton Reset
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::reset { } {
   variable widget
   variable private

   #--   inhibe la commande si pas de connexion
   if {[isReady] == 0} { return }

   set values [list]
   foreach param [list motorsens stepincr motorspeed coeftemp steptemp version maxstep] {
      lappend values $widget($param)
   }

   puts -nonewline $private(tty) SEERAZ
   after $private(tempo)
   gets $private(tty) answer

   #--   rafraichit l'affichage des valeurs memorisees
   ::usb_focus::getConf $private(tty)
}

#------------------------------------------------------------
#  ::usb_focus::Cntrl
#     Verifie une valeur numerique et sa limite
#
#  return {0 no error | 1 error}
#------------------------------------------------------------
proc ::usb_focus::Cntrl { value limit } {
   global caption

   set err 0
   #--   detection d'un non-numerique
   if {[catch {set value [expr { $value }]} errmsg]} {
      set err 1
   } elseif {$value > $limit || $value < 0} {
      set err 1
   }
   if {$err == 1} {
      if {$limit == 65535} {
         set msg $caption(sb_focus,limit1)
      }  elseif {$limit == 999} {
         set msg $caption(sb_focus,limit2)
      }
      tk_messageBox -title $caption(sb_focus,attention)\
         -icon error -type ok -message $msg
   }

   return $err
}

#------------------------------------------------------------
#  ::usb_focus::createPort
#     Etablit la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::createPort { port } {
   variable widget
   variable private

   if { $::tcl_platform(platform) == "unix" } {
      set port [ string tolower [ string trim $port ] ]
      set num [ expr [ string index $port 3 ] - 1 ]
      set port /dev/ttyS$num
   }

   set private(tty) [open $port r+]
   after $private(tempo)
   fconfigure $private(tty) -mode "19200,n,8,1" \
      -blocking 0 -buffering none -translation auto
      #-eofchar [list "" "lfcr"]

   #--- je cree la liaison du focuser
   #   (ne sert qu'a afficher l'utilisation de cette liaison par l'equipement)
   #     indispensable pour les tests isReady
   set private(linkNo) [::confLink::create $port "focuser" "USB_Focus" "" -noopen]

   #--   desinhibe les commandes
   ::usb_focus::setState normal
   update

   #--   initialise le mode
   ::usb_focus::activeCmd mmode

   #--   lit les parametres de conf de usb_focus
   ::usb_focus::getConf $private(tty)

   #--   affiche la position et la temperature
   ::usb_focus::getPosition
   ::usb_focus::getTemperature
}

#------------------------------------------------------------
#  ::usb_focus::close
#     Ferme la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::closePort { } {
   variable private

   if {$private(tty) ne "-"} {

      close $private(tty)

      set private(tty) "-"

      #--- annule la version
      set widget(version) "-"
   }
}

