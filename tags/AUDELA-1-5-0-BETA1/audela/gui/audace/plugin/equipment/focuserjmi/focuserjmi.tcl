#
# Fichier : focuserjmi.tcl
# Description : Gere un focuser sur port parallele ou quickremote
# Auteur : Michel PUJOL
# Mise a jour $Id: focuserjmi.tcl,v 1.12 2007-12-04 22:47:30 robertdelmas Exp $
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

namespace eval ::focuserjmi {
   package provide focuserjmi 1.0
   package require audela 1.4.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] focuserjmi.cap ]
}

#==============================================================
# Procedures generiques de configuration des equipements
#==============================================================

#------------------------------------------------------------
#  ::focuserjmi::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::focuserjmi::getPluginTitle { } {
   global caption

   return "$caption(focuserjmi,label)"
}

#------------------------------------------------------------
#  ::focuserjmi::getPluginHelp
#     retourne la documentation du equipement
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::focuserjmi::getPluginHelp { } {
   return "focuserjmi.htm"
}

#------------------------------------------------------------
#  ::focuserjmi::getPluginType
#     retourne le type de plugin
#
#  return "focuser"
#------------------------------------------------------------
proc ::focuserjmi::getPluginType { } {
   return "focuser"
}

#------------------------------------------------------------
#  ::focuserjmi::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::focuserjmi::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  ::focuserjmi::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::focuserjmi::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
   }
}

#------------------------------------------------------------
#  ::focuserjmi::initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#------------------------------------------------------------
proc ::focuserjmi::initPlugin { } {
   variable private
   global conf

   #--- Cree les variables dans conf(...) si elles n'existent pas
   if { ! [ info exists conf(focuserjmi,link) ] }         { set conf(focuserjmi,link)         "" }
   if { ! [ info exists conf(focuserjmi,bitStart) ] }     { set conf(focuserjmi,bitStart)     "4" }
   if { ! [ info exists conf(focuserjmi,bitDirection) ] } { set conf(focuserjmi,bitDirection) "5" }
   if { ! [ info exists conf(focuserjmi,start) ] }        { set conf(focuserjmi,start)        "0" }

   #--- variables locales
   set private(linkNo) "0"
}

#------------------------------------------------------------
#  ::focuserjmi::getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::focuserjmi::getStartFlag { } {
   return $::conf(focuserjmi,start)
}

#------------------------------------------------------------
#  ::focuserjmi::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::focuserjmi::fillConfigPage { frm } {
   variable widget
   global caption conf

   #--- je copie les donnees de conf(...) dans les variables widget(...)
   set widget(link)         $conf(focuserjmi,link)
   set widget(bitStart)     $conf(focuserjmi,bitStart)
   set widget(bitDirection) $conf(focuserjmi,bitDirection)

   #--- Je constitue la liste des liaisons pour le focuser
   set linkList [ ::confLink::getLinkLabels {"parallelport" "quickremote"} ]

   #--- Je verifie le contenu de la liste
   if { [llength $linkList ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [lsearch -exact $linkList $widget(link)] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(link) [lindex $linkList 0]
      }
   } else {
      #--- si la liste est vide
      #--- je desactive l'option focuser
      set widget(link) ""
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Label de la liaison
      label $frm.frame1.labelLink -text "$caption(focuserjmi,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix de la liaison
      ComboBox $frm.frame1.link \
         -width 13              \
         -height [ llength $linkList ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::focuserjmi::widget(link) \
         -values $linkList
      grid $frm.frame1.link -row 0 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Bouton de configuration de la liaison
      button $frm.frame1.configure -text "$caption(focuserjmi,configure)" -relief raised \
         -command {
            ::confLink::run ::focuserjmi::widget(link) {"parallelport" "quickremote"} $caption(focuserjmi,label)
         }
      grid $frm.frame1.configure -row 0 -column 2 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix du numero du bit pour le demarrage du moteur
      label $frm.frame1.bitDecrLabel -text "$caption(focuserjmi,bitStart)"
      grid $frm.frame1.bitDecrLabel -row 1 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

     set bitList [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.frame1.bitStart \
         -width 7                   \
         -height [ llength $bitList ] \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::focuserjmi::widget(bitStart) \
         -editable 0                \
         -values $bitList
      grid $frm.frame1.bitStart -row 1 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix du numero du bit pour le sens de rotation du moteur
      label $frm.frame1.bitIncrLabel -text "$caption(focuserjmi,bitDirection)"
      grid $frm.frame1.bitIncrLabel -row 2 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

      set bitList [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.frame1.bitDirection \
         -width 7                       \
         -height [ llength $bitList ]   \
         -relief sunken                 \
         -borderwidth 1                 \
         -textvariable ::focuserjmi::widget(bitDirection) \
         -editable 0                    \
         -values $bitList
      grid $frm.frame1.bitDirection -row 2 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

   pack $frm.frame1 -side top -fill x

   #--- Frame du bouton Arreter et du checkbutton creer au demarrage
   frame $frm.start -borderwidth 0 -relief flat

      #--- Bouton Arreter
      button $frm.start.stop -text "$caption(focuserjmi,arreter)" -relief raised \
         -command { ::focuserjmi::deletePlugin }
      pack $frm.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

      #--- Checkbutton démarrage automatique
      checkbutton $frm.start.chk -text "$caption(focuserjmi,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(focuserjmi,start)
      pack $frm.start.chk -side top -padx 3 -pady 3 -fill x

   pack $frm.start -side bottom -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  ::focuserjmi::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuserjmi::configurePlugin { } {
   variable widget
   global conf

   #--- copie les variables des widgets dans le tableau conf()
   set conf(focuserjmi,link)         $widget(link)
   set conf(focuserjmi,bitStart)     $widget(bitStart)
   set conf(focuserjmi,bitDirection) $widget(bitDirection)
}

#------------------------------------------------------------
#  ::focuserjmi::createPlugin
#     demarrerle plugin
#
#  return nothing
#------------------------------------------------------------
proc ::focuserjmi::createPlugin { } {
   variable private
   global conf

   #--- je cree la liaison du focuser
   set private(linkNo) [::confLink::create $conf(focuserjmi,link) "focuser" \
     "jmi" "bits $conf(focuserjmi,bitStart),$conf(focuserjmi,bitDirection)"]
}

#------------------------------------------------------------
#  ::focuserjmi::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::focuserjmi::deletePlugin { } {
   variable private
   global conf

   #--- je ferme la liaison du focuser
   ::confLink::delete $conf(focuserjmi,link) "focuser" "jmi"
   set private(linkNo) "0"
   return
}

#------------------------------------------------------------
#  ::focuserjmi::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::focuserjmi::isReady { } {
   variable private

   if { $private(linkNo) != "0" } {
      return 1
   } else {
      return 0
   }
}

#==============================================================
# ::focuserjmi::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::focuserjmi::move
#     si command = "-" , demarre le mouvement du focus en intra focale
#     si command = "+" , demarre le mouvement du focus en extra focale
#     si command = "stop" , arrete le mouvement
#------------------------------------------------------------
proc ::focuserjmi::move { command } {
   variable private
   global conf

   if { [isReady] == 0 } {
      return
   }
   set linkNo $private(linkNo)

   if { "$command" == "-" } {
      link$linkNo bit $conf(focuserjmi,bitDirection) "0"
      link$linkNo bit $conf(focuserjmi,bitStart) "1"
   } elseif { "$command" == "+" } {
      link$linkNo bit $conf(focuserjmi,bitDirection) "1"
      link$linkNo bit $conf(focuserjmi,bitStart) "1"
   } elseif { "$command" == "stop" } {
      link$linkNo bit $conf(focuserjmi,bitDirection) "0"
      link$linkNo bit $conf(focuserjmi,bitStart) "0"
   }
}

#------------------------------------------------------------
#  ::focuserjmi::goto
#     envoie le focaliseur a moteur pas a pas a une position predeterminee (AudeCom)
#------------------------------------------------------------
proc ::focuserjmi::goto { } {
   # non supportee
}

#------------------------------------------------------------
#  ::focuserjmi::incrementSpeed
#     incremente la vitesse du focus et appelle la procedure setSpeed
#------------------------------------------------------------
proc ::focuserjmi::incrementSpeed { origin } {
   # non supportee
}

#------------------------------------------------------------
#  ::focuserjmi::setSpeed
#     change la vitesse du focus
#------------------------------------------------------------
proc ::focuserjmi::setSpeed { { value "0" } } {
   # non supportee
}

#------------------------------------------------------------
#  ::focuserjmi::possedeControleEtendu
#     retourne 1 si la monture possede un controle etendu du focus (AudeCom)
#     retourne 0 sinon
#------------------------------------------------------------
proc ::focuserjmi::possedeControleEtendu { } {
   global conf

   if { $conf(telescope) == "audecom" } {
      set result "1"
   } else {
      set result "0"
   }
}

