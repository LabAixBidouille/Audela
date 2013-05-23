#
# Fichier : usb_focus.tcl
# Description : Gere un focuser sur port serie
# Auteur : Raymond ZACHANTKE
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
#     getPluginProperty : Retourne la propriete du plugin
#     fillConfigPage    : Affiche la fenetre de configuration de ce plugin
#     configurePlugin   : Configure le plugin
#     stopPlugin        : Arrete le plugin et libere les ressources occupees
#     isReady           : Informe de l'etat de fonctionnement du plugin
#
# Procedures specifiques a ce plugin :
#

namespace eval ::usb_focus {
   package provide usb_focus 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] usb_focus.cap ]
   source [ file join [file dirname [info script]] usb_focus_cmd.tcl]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::usb_focus::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::usb_focus::getPluginTitle { } {
   global caption

   return "$caption(usb_focus,label)"
}

#------------------------------------------------------------
#  ::usb_focus::getPluginHelp
#     retourne la documentation du equipement
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::usb_focus::getPluginHelp { } {
   return "usb_focus.htm"
}

#------------------------------------------------------------
#  ::usb_focus::getPluginType
#     retourne le type de plugin
#
#  return "focuser"
#------------------------------------------------------------
proc ::usb_focus::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  ::usb_focus::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::usb_focus::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  ::usb_focus::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::usb_focus::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
   }
}

#------------------------------------------------------------
#  ::usb_focus::initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#------------------------------------------------------------
proc ::usb_focus::initPlugin { } {
   variable private
   global conf

   #--- Cree les variables dans conf(...) si elles n'existent pas
   if {![info exists conf(usb_focus)]} {
      #--   liste du port COM et de step
      set conf(usb_focus) [list "" 10]
   }

   if {[lindex $conf(usb_focus) 1] eq ""} {
      set conf(usb_focus) [lreplace $conf(usb_focus) 1 1 10]
   }

   if {![info exists conf(usb_focus,start)]} {
      set conf(usb_focus,start) "0"
   }

   set private(frm)         ""
}

#------------------------------------------------------------
#  ::usb_focus::getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::usb_focus::getStartFlag { } {
   return $::conf(usb_focus,start)
}

#------------------------------------------------------------
#  ::usb_focus::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::usb_focus::fillConfigPage { frm } {
   variable widget
   variable private
   global caption conf

   set private(frm) $frm

   #--- je copie les donnees de conf(...)
   lassign $conf(usb_focus) widget(port) widget(nbstep)

   #--- Prise en compte des liaisons
   set linkList [::confLink::getLinkLabels { "serialport" } ]

   #--- Je verifie le contenu de la liste
   if {[llength $linkList ] > 0} {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
     if {[lsearch -exact $linkList $widget(port)] == -1} {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(port) [lindex $linkList 0]
      }
   } else {
      #--- si la liste est vide
      #--- je desactive l'option focuser
      set widget(port) ""
   }

   #--- variables locales
   #::usb_focus::initLocalVar

   #--- Creation du frame contenant les commandes de usb_focus
   set f [frame $frm.frame1 -borderwidth 0 -relief raised]
   pack $frm.frame1 -side top -fill x

   #--   frame de la com
   labelframe $f.link -borderwidth 2 -text $caption(usb_focus,link)

      #--- Label de la liaison
      label $f.link.labelPort -text "$caption(usb_focus,port)"
      grid $f.link.labelPort -row 0 -column 0 -padx 5 -sticky w

      #--- Choix de la liaison
      ComboBox $f.link.port \
         -width [::tkutil::lgEntryComboBox $linkList] \
         -height [llength $linkList] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::usb_focus::widget(port) \
         -modifycmd "::usb_focus::onChangeLink" \
         -values $linkList
      grid $f.link.port -row 0 -column 1 -sticky ew

      #--- Bouton de configuration de la liaison
      button $f.link.configure -text "$caption(usb_focus,configure)" -relief raised \
         -command "::confLink::run ::usb_focus::widget(port) {\"serialport\"} \"$caption(usb_focus,label)\""
      grid $f.link.configure -row 0 -column 2 -padx 5 -pady 5 -sticky ew

   grid $f.link -row 0 -column 0 -padx 10 -pady 5 -sticky w

   #--- Version du microcontroleur
   frame $f.chip

      #--- Label N° de version
      label $f.chip.labelVersion -text "$caption(usb_focus,version)"
      grid $f.chip.labelVersion -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- N° de version
      label $f.chip.version -width 5 -justify left \
         -textvariable ::usb_focus::widget(version)
      grid  $f.chip.version -row 0 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton Reset
      button $f.chip.reset -text "$caption(usb_focus,reset)" -relief raised \
            -command "::usb_focus::reset"
      grid $f.chip.reset -row 0 -column 2 -padx 5 -pady 5 -sticky w

   grid $f.chip -row 1 -column 0 -padx 5 -pady 5 -sticky ew

   #--   frame du moteur
   labelframe $f.motor -borderwidth 2 -text $caption(usb_focus,motor)

      #--- Label du nombre de pas
      label $f.motor.labelStep -text "$caption(usb_focus,maxstep)"
      grid $f.motor.labelStep -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- Nombre de pas maxi
      entry $f.motor.maxstep -width 6 -justify right \
         -textvariable ::usb_focus::widget(maxstep)
      grid $f.motor.maxstep -row 0 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton de setmaxi
      button $f.motor.setmax -text "$caption(usb_focus,set)" -relief raised \
         -width 4 -command "::usb_focus::setMaxPos"
      grid $f.motor.setmax -row 0 -column 2 -padx 5 -sticky w

      #--- Label de la vitesse
      label $f.motor.labelSpeed -text "$caption(usb_focus,motorspeed)"
      grid $f.motor.labelSpeed -row 1 -column 0 -padx 5 -pady 5 -sticky w

      #--- Vitesse de deplacement
      ComboBox $f.motor.speed -width 4 -height 8 -relief sunken -borderwidth 1 -editable 0 \
         -textvariable ::usb_focus::widget(motorspeed) \
         -modifycmd "::usb_focus::setSpeed" \
         -values [list 2 3 4 5 6 7 8 9]
      grid $f.motor.speed -row 1 -column 1 -padx 5 -sticky w

      #--- Label de l'increment
      label $f.motor.labelIncrStep -text "$caption(usb_focus,step)"
      grid $f.motor.labelIncrStep -row 2 -column 0 -padx 5 -pady 5 -sticky w

      radiobutton $f.motor.halfstep -text "$caption(usb_focus,halfstep)" \
         -indicatoron 1 -variable ::usb_focus::widget(stepincr) -value 1 \
         -command "::usb_focus::setStepIncr"
      grid $f.motor.halfstep -row 2 -column 1 -padx 5 -sticky w

      radiobutton $f.motor.fullstep -text "$caption(usb_focus,fullstep)" \
         -indicatoron 1 -variable ::usb_focus::widget(stepincr) -value 0 \
         -command "::usb_focus::setStepIncr"
      grid $f.motor.fullstep -row 2 -column 2 -padx 5 -sticky w

      #--- Label du sens de rotation
      label $f.motor.labelRot -text "$caption(usb_focus,motorrot)"
      grid $f.motor.labelRot -row 3 -column 0 -padx 5 -pady 5 -sticky w

      set clockwise [image create photo]
      $clockwise configure -data {R0lGODlhGAAYAIIAMWyRQqDPFMnfebTReYyzQPj69nOqH5ysjCwAAAAAGAAY
         AAIDnVi63P4wSnfAhKIIYMC4y1ABZBB4l1AZAcsGhCVtr2nb8rMRJt/bBELk
         wPIJjkeeYVgbDAgdT1By8AUGhk8BAJ00DRnFIBepwUANsO0AGQicjhqB7YiR
         APSF2gRuYG9kBXstB2EFYzcBeQoHAQI2HQeSHDd9DQSPkAabiVgPT5mJN2OG
         fpg/P0dZElgHbldOAjFaE09Bt1NoChm8EQkAOw==}

      radiobutton $f.motor.clockwise -image $clockwise \
         -indicatoron 1 -variable ::usb_focus::widget(motorsens) -value 0 \
         -command "::usb_focus::setRot"
      grid $f.motor.clockwise -row 3 -column 1 -padx 5 -sticky w

      set anticlockwise [image create photo]
      $anticlockwise configure -data {R0lGODlhGAAYAIIAMWyRQqDPFMnfebTReYyzQPj69nOqH5ysjCwAAAAAGAAY
         AAIDnVi6LOWOyVkGufjSOcwZQjCMAgEMm2KFARG8riAYKLW+eP4OQCQRrJdh
         aNB1JodA0AA4OAFFnMGnmEoPPp7uILEKqZXoC9DFEbgTE2CNXngDbQloNBG3
         UilxJ0vGFw4uOzQKAAQGfgd6FkwnGniJLS8yky6HKQKFMGZmBHiYdjoBfZcH
         UAFFUSZ+CwOlawBjNasKEFAnsxSluLu8qwkAOw==}

      radiobutton $f.motor.anticlockwise -image $anticlockwise \
         -indicatoron 1 -variable ::usb_focus::widget(motorsens) -value 1 \
         -command "::usb_focus::setRot"
      grid $f.motor.anticlockwise -row 3 -column 2 -padx 5 -sticky w

   grid $f.motor -row 2 -column 0 -padx 10 -pady 5 -sticky w

   #--   frame de la temperature
   labelframe $f.temp -borderwidth 2 -text $caption(usb_focus,temperature)

      #--- Label de la temperature
      label $f.temp.labelTemp -text "$caption(usb_focus,actuelle)"
      grid $f.temp.labelTemp -row 0 -column 0 -padx 5 -pady 10 -sticky w

      #--- Temperature
      label $f.temp.temperature  -textvariable ::usb_focus::widget(temperature)
      grid $f.temp.temperature -row 0 -column 1 -padx 5 -sticky e

      checkbutton $f.temp.mode -text "$caption(usb_focus,tempmode)" \
         -indicatoron 1 -onvalue 1 -offvalue 0 \
         -variable ::usb_focus::widget(tempmode) \
         -command "::usb_focus::setTempMod"
      grid $f.temp.mode -row 1 -column 0 -sticky w

      #--- Label du coefficient
      label $f.temp.labelTempCoef -text "$caption(usb_focus,tempcoef)"
      grid $f.temp.labelTempCoef -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- Coefficient
      entry $f.temp.coef -width 5 -justify right \
         -textvariable ::usb_focus::widget(coef)
      grid $f.temp.coef -row 2 -column 1 -padx 5 -sticky e

      #--- Bouton de set coeftemp
      button $f.temp.setcoef -text "$caption(usb_focus,set)" -relief raised \
         -width 4 -command "::usb_focus::setCoefTemp"
      grid $f.temp.setcoef -row 2 -column 2 -padx 5

      #--- Label du coefficient
      label $f.temp.labelTempStep -text "$caption(usb_focus,tempstep)"
      grid $f.temp.labelTempStep -row 3 -column 0 -padx 5 -pady 5 -sticky w

      #--- Coefficient
      entry $f.temp.step -width 5 -justify right \
         -textvariable ::usb_focus::widget(step)
      grid $f.temp.step -row 3 -column 1 -padx 5 -sticky e

      #--- Bouton de set steptemp
      button $f.temp.setstep -text "$caption(usb_focus,set)" -relief raised \
         -width 4 -command "::usb_focus::setSeuilTemp"
      grid $f.temp.setstep -row 3 -column 2 -padx 5

   grid $f.temp -row 2 -column 1 -padx 10 -pady 5 -sticky w

   #--   frame de la position
   labelframe $f.pos -borderwidth 2 -text $caption(usb_focus,position)

      #--- Label de la position actuelle
      label $f.pos.labelPosAct -text "$caption(usb_focus,actuelle)"
      grid $f.pos.labelPosAct -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- Position actuelle
      label $f.pos.posact -textvariable ::usb_focus::widget(position)
      grid $f.pos.posact -row 0 -column 1 -padx 5 -sticky e

      #--- Label de la position cible
      label $f.pos.labelTarget -text "$caption(usb_focus,target) "
      grid $f.pos.labelTarget -row 1 -column 0 -padx 5 -sticky w

      #--- Position cible
      entry $f.pos.target -width 6 -justify right \
         -textvariable ::usb_focus::widget(target)
      grid $f.pos.target -row 1 -column 1 -padx 5 -pady 5 -sticky ew

      #--  bouton Goto
      button $f.pos.goto -text "$caption(usb_focus,goto)" -relief raised -width 5 \
         -command "::usb_focus::goto"
      grid $f.pos.goto -row 1 -column 2 -padx 5 -pady 5 -sticky ew

      #--  bouton Stop
      button $f.pos.stop -text "$caption(usb_focus,stopmove)" -relief raised -width 5 \
         -command "::usb_focus::stopMove"
      grid $f.pos.stop -row 1 -column 3 -padx 5 -sticky ew

      #--- Label des pas
      label $f.pos.labelStep -text "$caption(usb_focus,nbstep) "
      grid $f.pos.labelStep -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- nombre de pas
      entry $f.pos.nbstep -width 6 -justify right \
         -textvariable ::usb_focus::widget(nbstep)
      grid $f.pos.nbstep -row 2 -column 1 -padx 5 -sticky w

      #--  bouton -
      button $f.pos.decrease -text "-" -relief raised -width "5" \
         -command "::usb_focus::move -"
      grid $f.pos.decrease -row 2 -column 2 -padx 5 -pady 5 -sticky ew

      #--  bouton +
      button $f.pos.increase -text "+" -relief raised -width "5" \
         -command "::usb_focus::move +"
      grid $f.pos.increase -row 2 -column 3 -padx 5 -pady 5 -sticky ew

   grid $f.pos -row 3 -column 0 -padx 10 -pady 5 -sticky w

   #--- Frame du site web, du bouton Arreter et du checkbutton creer au demarrage
   frame $frm.frame2 -borderwidth 0 -relief flat

      #--- Site web officiel de USB_FOCUS
      label $frm.frame2.lab -text "$caption(usb_focus,site_web)"
      pack $frm.frame2.lab -side top -fill x -pady 2

      set labelName [ ::confEqt::createUrlLabel $frm.frame2 "$caption(usb_focus,site_web_ref)" \
            "$caption(usb_focus,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Bouton Arreter
      button $frm.frame2.stop -text "$caption(usb_focus,arreter)" -relief raised \
         -command { ::usb_focus::deletePlugin }
      pack $frm.frame2.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

      #--- Checkbutton demarrage automatique
      checkbutton $frm.frame2.chk -text "$caption(usb_focus,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(usb_focus,start)
      pack $frm.frame2.chk -side top -padx 3 -pady 3 -fill x

   pack $frm.frame2 -side bottom -fill x

   #--   filtre l'action si le lien a deja ete cree
   if {![info exists private(linkNo)]} {
      #--- initialise les variables locales
      ::usb_focus::initLocalVar
      #--- inhibe les commandes en attendant la creation du port
      ::usb_focus::setState disabled all
   }

   #--- Mise a jour
   ::usb_focus::onChangeLink

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  ::usb_focus::onChangeLink
#     ne fait rien
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::onChangeLink { } {

}

#------------------------------------------------------------
#  ::usb_focus::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::configurePlugin { } {
   variable widget
   global conf

   #--- copie les variables des widgets dans le tableau conf()
   set conf(usb_focus) [list $widget(port) $widget(nbstep)]
}

#------------------------------------------------------------
#  ::usb_focus::createPlugin
#     demarre le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::createPlugin { } {
   variable widget
   variable private

   #--   empeche la tentative d'ouvrir le port deja ouvert
   if {$private(linkNo) != 0} { return }

   #--   cree le port et initialise les variables en cas de reussite
   if {[::usb_focus::createPort $widget(port)]} {

      #--- cree la liaison du focuser
      #   (ne sert qu'a afficher l'utilisation de cette liaison par l'equipement)
      #     indispensable pour les tests isReady
      set private(linkNo) [::confLink::create $widget(port) "focuser" "USB_Focus" "" -noopen]
   }
}

#------------------------------------------------------------
#  ::usb_focus::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::deletePlugin { } {
   variable widget

   ::usb_focus::configurePlugin
   ::confLink::delete $widget(port) "focuser" "USB_Focus"

   #--   ferme le port serie
   ::usb_focus::closePort

   #--   reinitialise les variable private et widget
   ::usb_focus::initLocalVar

   #--   inhibe les commandes
   ::usb_focus::setState disabled all
}

#------------------------------------------------------------
#  ::usb_focus::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::usb_focus::isReady { } {
   variable private

   if {[info exists private(linkNo)] && $private(linkNo) != "0" } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  ::usb_focus::possedeControleEtendu
#     retourne 1 si la monture possede un controle etendu du focus (AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::usb_focus::possedeControleEtendu { } {
   global conf

   if { $conf(telescope) == "audecom" } {
      set result "1"
   } else {
      set result "0"
   }
}

#------------------------------------------------------------
#  ::usb_focus::incrementSpeed
#     incremente la vitesse du focus
#------------------------------------------------------------
proc ::usb_focus::incrementSpeed { } {

   #-- non implemente du fait du selecteur de vitesses
   #   et sa proc ::usb_focus::setSpeed
}

#------------------------------------------------------------
#  ::usb_focus::setState
#     Inhibe les commandes lors de la creation du widget et de l'arret
#     Desinhibe les commandes lors de la creation du port
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::setState { state {limited 0} } {
   variable private

   set w $private(frm).frame1

   #--   traite les saisies
   set entryList [list "motor.maxstep" "pos.target" "pos.nbstep" \
      "temp.coef" "temp.step"]
   foreach entr $entryList {
      if {[winfo exists $w.$entr]}  {
         if {$state eq "normal"} {
            lassign [split $entr "."] -> param
            #--   cree les binding
            bind $w.$entr <Leave> [list ::usb_focus::verifValue $param]
          } else {
            #--   supprime les binding
            bind $w.$entr <Leave> ""
         }
         $w.$entr configure -state $state
      }
   }

   #--   traite tous les boutons
   set buttonList [list chip.reset motor.setmax motor.speed \
      motor.halfstep motor.fullstep pos.goto pos.stop \
      motor.clockwise motor.anticlockwise pos.decrease \
      pos.increase temp.mode temp.setcoef temp.setstep]
   foreach but $buttonList {
      if {[winfo exists $w.$but]} {
         $w.$but configure -state $state
      }
   }

   #--   gere les exceptions
   switch -exact  $limited {
      manual {  #--   inhibe le bouton STOP
                $w.pos.stop configure -state disabled
             }
      auto   {  #--   desinhibe le radiobutton du Mode
                $w.temp.mode configure -state normal
             }
      stop   {  #--   desinhibe le bouton STOP
                $w.pos.stop configure -state normal
             }
      all    {  #--   ne fait aucune correction
             }
   }

   update
}

#------------------------------------------------------------
#  ::usb_focus::initLocalVar
#     Initialise quelques variables lors du lancement
#     et lors de la fermeture du port
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::initLocalVar {} {
   variable widget
   variable private
   global conf

   set private(tty)           ""
   set private(linkNo)        0
   set private(prev,maxstep)  ""
   set private(prev,target)   ""
   set private(prev,nbstep)   [lindex $conf(usb_focus) 1]
   set private(prev,coef)     ""
   set private(prev,step)     ""
   set widget(version)        ""
   set widget(motorspeed)     ""
   set widget(stepincr)       1
   set widget(motorsens)      0
   set widget(maxstep)        ""
   set widget(position)       ""
   set widget(target)         "0"
   set widget(nbstep)         $private(prev,nbstep)
   set widget(temperature)    ""
   set widget(mode)           0
   set widget(coef)           ""
   set widget(step)           ""
}

#------------------------------------------------------------
#  ::usb_focus::verifValueValue
#     Verifie une valeur numerique et sa limite
#     +Message d'alerte si erreur+Retablit l'ancienne valeur
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::verifValue { v } {
   variable widget
   variable private
   global caption

   set err 0

   #--   toutes les valeurs (a l'exception de coef) doivent etre positives
   if { $v in [list maxstep target nbstep step] && $widget($v) < 0} {
      set err 1
   }

   #--   definit la limite superieure
   switch -exact $v {
      maxstep  { set limite 65535 ; # steps }
      target   { set limite $widget(maxstep) ; # steps }
      nbstep   { set limite $widget(maxstep) ; # steps }
      coef     { set limite 999 ; # steps/°C }
      step     { set limite 999 ; # steps }
   }

   #--   toutes les valeurs absolues doivent etre <= limite
   if {[expr { abs($widget($v)) }] > $limite} {
      set err 1
   }

   if {$err == 0 } {
      #--   memorise la nouvelle valeur
      set private(prev,$v) $widget($v)
   } else {
      tk_messageBox -title $caption(usb_focus,attention)\
         -icon error -type ok -message "[format $caption(usb_focus,limit) $limite]"
      #--   retablit l'ancienne valeur en cas d'erreur
      set widget($v) $private(prev,$v)
   }
}