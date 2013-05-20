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
   #paramList [list port start rate maxstep stepincr motorspeed nbstep]
   if {![info exists conf(usb_focus)]} {
      set conf(usb_focus) [list "" 1 65535 1 4 1 10]
   } elseif {"" in $conf(usb_focus)} {
      #--   specifique au debug
      set conf(usb_focus) [list "" 1 65535 1 4 1 10]
   }

   if {![info exists conf(usb_focus,start)]} {
      set conf(usb_focus,start) "0"
   }

   #--- variables locales
   set private(frm)         ""
   set private(linkNo)      "0"
   set private(temperature) "-"
   set private(tty)         "-"
   set private(mode)        "-"
   set private(tempo)       "200" ; # temporisation du port serie
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

   #--- je copie les donnees de conf(...) dans les variables widget(...)
   lassign $conf(usb_focus) widget(port) widget(rate) widget(maxstep) \
      widget(stepincr) widget(motorspeed) widget(motorsens) widget(nbstep)

   #--- initialise les autres variables provisoires
   set widget(version)  "-"
   set widget(target)   ""
   set widget(position) "-"
   set private(prev,maxstep) $widget(maxstep)

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
      set private(port) ""
   }

   #--- Creation du frame contenant les commandes de usb_focus
   set f [frame $frm.frame1 -borderwidth 0 -relief raised]
   pack $f -side top -fill x

   #--   frame de la com
   labelframe $f.link -borderwidth 2 -text $caption(usb_focus,link)

      #--- Label de la liaison
      label $f.link.labelPort -text "$caption(usb_focus,port)"
      grid $f.link.labelPort -row 0 -column 0 -padx 10 -sticky w

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
         -command {::confLink::run ::usb_focus::widget(port) {"serialport"} $caption(usb_focus,label)}
      grid $f.link.configure -row 0 -column 2 -padx 10 -pady 5 -sticky ew

      #--- Frequence de lecture
      LabelEntry  $f.link.rate -label "$caption(usb_focus,rate)  " \
         -labeljustify left -width 4 -justify right \
         -textvariable ::usb_focus::widget(rate)
      #--   prevoir une proc de controle
      grid  $f.link.rate -row 1 -column 0 -columnspan 2 -padx 10 -pady 5

   grid $f.link -row 0 -column 0 -padx 10 -pady 10 -sticky w

   #--- Version du microcontroleur
   LabelEntry  $f.version -label "$caption(usb_focus,version) " \
      -labeljustify left -width 5 -justify right -font {helvetica 12 bold} \
      -state disabled -textvariable ::usb_focus::widget(version)
   grid  $f.version -row 1 -column 0 -columnspan 2 -padx 10 -pady 5 -sticky w

   #--- Bouton Reset
   button $f.reset -text "$caption(usb_focus,reset)" -relief raised \
         -command { ::usb_focus::reset }
   grid $f.reset -row 1 -column 2 -padx 10 -pady 5 -sticky w

   #--   frame du moteur
   labelframe $f.motor -borderwidth 2 -text $caption(usb_focus,motor)

      #--   constitue les listes
      set stepList [list $caption(usb_focus,halfstep) $caption(usb_focus,fullstep)]
      set speedList [list 2 3 4 5 6 7 8 9]
      set sensList [list $caption(usb_focus,neg) $caption(usb_focus,pos)]

      set width [::tkutil::lgEntryComboBox $stepList]

      #--- Label du nombre de pas
      label $f.motor.labelStep -text "$caption(usb_focus,maxstep)"
      grid $f.motor.labelStep -row 0 -column 0 -padx 10 -pady 5

      #--- Nombre de pas
      entry $f.motor.maxstep -width $width -justify right \
         -textvariable ::usb_focus::widget(maxstep)
      bind $f.motor.maxstep <Leave> [list "::usb_focus::setMaxPos"]
      grid $f.motor.maxstep -row 0 -column 1 -padx 10 -pady 5 -sticky w

      #--- Label de l'increment
      label $f.motor.labelIncrStep -text "$caption(usb_focus,step)"
      grid $f.motor.labelIncrStep -row 1 -column 0 -padx 10 -pady 5 -sticky w

      #--- Choix de l'increment
      set widget(step) [lindex $stepList $widget(stepincr)]
      ComboBox $f.motor.incrStep \
         -width $width \
         -height 2 \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::usb_focus::widget(step) \
         -modifycmd "::usb_focus::setStep $f.motor.incrStep" \
         -values $stepList
      grid $f.motor.incrStep -row 1 -column 1 -padx 10 -pady 5 -sticky w

      #--- Label de la vitesse
      label $f.motor.labelSpeed -text "$caption(usb_focus,motorspeed)"
      grid $f.motor.labelSpeed -row 2 -column 0 -padx 10 -pady 5 -sticky w

      #--- Vitesse de deplacement
      ComboBox $f.motor.speed \
         -width $width \
         -height 8 \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::usb_focus::widget(motorspeed) \
         -modifycmd "::usb_focus::setSpeed" \
         -values $speedList
     grid $f.motor.speed -row 2 -column 1 -padx 10 -pady 10 -sticky w

      #--- Label du sens de rotation
      label $f.motor.labelRot -text "$caption(usb_focus,motorrot)"
      grid $f.motor.labelRot -row 3 -column 0 -padx 10 -pady 5 -sticky w

      #--- Sens de rotation
      set widget(rot) [lindex $sensList $widget(motorsens)]
      ComboBox $f.motor.rot \
         -width [expr { [::tkutil::lgEntryComboBox $sensList]*3/4 }] \
         -height 2 \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::usb_focus::widget(rot) \
         -modifycmd "::usb_focus::setRot $f.motor.rot" \
         -values $sensList
      grid $f.motor.rot -row 3 -column 1 -columnspan 2 -padx 10 -pady 5 -sticky w

   grid $f.motor -row 2 -column 0 -padx 10 -pady 10 -sticky w

   #--   frame de la position
   labelframe $f.pos -borderwidth 2 -text $caption(usb_focus,position)

      #--- Label de la position actuelle
      label $f.pos.labelPosAct -text "$caption(usb_focus,actuelle)"
      grid $f.pos.labelPosAct -row 0 -column 0 -padx 10 -pady 5 -sticky w

      #--- Position actuelle
      entry $f.pos.posact -width 10 -justify right -state disabled \
         -textvariable ::usb_focus::widget(position)
      grid $f.pos.posact -row 0 -column 1 -padx 10 -sticky ew

      #--- Label de la position cible
      label $f.pos.labelTarget -text "$caption(usb_focus,target) "
      grid $f.pos.labelTarget -row 1 -column 0 -padx 10 -sticky w

      #--- Position cible
      entry $f.pos.target -width 6 -justify right \
         -textvariable ::usb_focus::widget(target)
      grid $f.pos.target -row 1 -column 1 -padx 10 -pady 5 -sticky ew

      #--  bouton Goto
      button $f.pos.goto -text "$caption(usb_focus,goto)" -relief raised -width 5
      bind $f.pos.goto <ButtonPress-1> { ::usb_focus::goto }
      grid $f.pos.goto -row 1 -column 2 -padx 10 -pady 5 -sticky ew

      #--  bouton Stop
      button $f.pos.stop -text "$caption(usb_focus,stopmove)" -relief raised -width 5
      bind $f.pos.stop <ButtonPress-1> { ::usb_focus::stopMove }
      grid $f.pos.stop -row 1 -column 3 -padx 10 -sticky ew

      #--- Label des pas
      label $f.pos.labelStep -text "$caption(usb_focus,nbstep) "
      grid $f.pos.labelStep -row 2 -column 0 -padx 10 -pady 5 -sticky w

      #--- nombre de pas
      entry $f.pos.step -width 6 -justify right \
         -textvariable ::usb_focus::widget(nbstep)
      grid $f.pos.step -row 2 -column 1 -padx 10 -sticky w

      #--  bouton -
      button $f.pos.decrease -text "-" -relief raised -width "5"
      bind $f.pos.decrease <ButtonPress-1> { ::usb_focus::move "-" }
      grid $f.pos.decrease -row 2 -column 2 -padx 10 -pady 5 -sticky ew

      #--  bouton +
      button $f.pos.increase -text "+" -relief raised -width "5"
      bind $f.pos.increase <ButtonPress-1> { ::usb_focus::move "+" }
      grid $f.pos.increase -row 2 -column 3 -padx 10 -pady 5 -sticky ew

    grid $f.pos -row 3 -column 0 -columnspan 4 -padx 10 -pady 10 -sticky w

    #--   frame de la temperature
    labelframe $f.temp -borderwidth 2 -text $caption(usb_focus,temperature)

      #--- Label de la temperature
      label $f.temp.labelTemp -text "$caption(usb_focus,actuelle)"
      grid $f.temp.labelTemp -row 0 -column 0 -padx 10 -pady 10 -sticky w

      #--- Temperature
      entry $f.temp.temperature -width 5 -justify right -state disabled \
         -textvariable ::usb_focus::private(temperature)
      grid $f.temp.temperature -row 0 -column 1 -padx 10 -sticky ew

      #--- Label du coefficient
      label $f.temp.labelTempCoef -text "$caption(usb_focus,tempcoef)"
      grid $f.temp.labelTempCoef -row 1 -column 0 -padx 10 -pady 5 -sticky w

      #--- Coefficient
      entry $f.temp.tempCoef -width 5 -justify right \
         -textvariable ::usb_focus::widget(coeftemp)
      grid $f.temp.tempCoef -row 1 -column 1 -padx 10 -sticky w

      #--- Label du coefficient
      label $f.temp.labelTempStep -text "$caption(usb_focus,tempstep)"
      grid $f.temp.labelTempStep -row 2 -column 0 -padx 10 -pady 5 -sticky w

      #--- Coefficient
      entry $f.temp.tempStep -width 5 -justify right \
         -textvariable ::usb_focus::widget(steptemp)
      grid $f.temp.tempStep -row 2 -column 1 -padx 10 -sticky e

   grid $f.temp -row 4 -column 0 -columnspan 4 -padx 10 -pady 10 -sticky w

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

   #--   inhibe toutes les commandes et entrees
   ::usb_focus::setState disabled
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
   set conf(usb_focus) [list $widget(port) $widget(rate) $widget(maxstep) \
      $widget(stepincr) $widget(motorspeed) $widget(motorsens) $widget(nbstep)]
}

#------------------------------------------------------------
#  ::usb_focus::createPlugin
#     demarre le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::createPlugin { } {
   variable widget

   #--   cree le port et initialise les variables memorisees
   ::usb_focus::createPort $widget(port)
}

#------------------------------------------------------------
#  ::usb_focus::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::deletePlugin { } {
   variable widget
   variable private

   ::usb_focus::configurePlugin

   #--- je ferme la liaison du focuser
   ::usb_focus::closePort

   ::confLink::delete $widget(port) "focuser" "USB_Focus"
   set private(linkNo) "0"
}

#------------------------------------------------------------
#  ::usb_focus::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::usb_focus::isReady { } {
   variable private

   if { $private(linkNo) != "0" } {
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

   #-- non implemente
}

#------------------------------------------------------------
#  ::usb_focus::setState
#     incremente la vitesse du focus
#
#  return nothing
#------------------------------------------------------------
proc ::usb_focus::setState { state } {
   variable private

   set childList [list link.rate reset motor.maxstep motor.incrStep \
       motor.speed  motor.rot pos.target pos.goto pos.stop pos.step \
       pos.decrease pos.increase temp.tempCoef temp.tempStep]
   foreach child $childList {
      $private(frm).frame1.$child configure -state $state
   }
}

