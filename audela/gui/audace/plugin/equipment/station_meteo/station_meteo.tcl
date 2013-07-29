#
# Fichier : station_meteo.tcl
# Description : Gere les donnees meteorologique issues de stations meteo
# Auteur : Robert DELMAS & Raymond ZACHANTKE
# Mise à jour $Id$
#

#
# Procedures generiques obligatoires (pour configurer tous les plugins camera, telescope, equipement) :
#     initPlugin      : Initialise le plugin
#     getStartFlag    : Retourne l'indicateur de lancement au demarrage
#     getPluginHelp   : Retourne la documentation htm associee
#     getPluginTitle  : Retourne le titre du plugin dans la langue de l'utilisateur
#     getPluginType   : Retourne le type de plugin
#     getPluginOS     : Retourne les OS sous lesquels le plugin fonctionne
#     fillConfigPage  : Affiche la fenetre de configuration de ce plugin
#     createPlugin    : Cree une instance du plugin
#     deletePlugin    : Arrete une instance du plugin et libere les ressources occupees
#     configurePlugin : Configure le plugin
#     isReady         : Informe de l'etat de fonctionnement du plugin
#

# Procedures specifiques a ce plugin :
#

namespace eval station_meteo {
   package provide station_meteo 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] station_meteo.cap ]
}

#------------------------------------------------------------
#  initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::station_meteo::initPlugin { } {
   global audace conf

   #--- Cree les variables dans conf(...) si elles n'existent pas
   #if { ! [ info exists conf(station_meteo,pressure) ] }    { set conf(station_meteo,pressure)    "101325" }
   #if { ! [ info exists conf(station_meteo,temperature) ] } { set conf(station_meteo,temperature) "290" }

   #--   Initialise le chemin d'acces complet au fichier des donnees meteo
   if { ! [ info exists conf(station_meteo,meteoFileAccess) ] }  { set conf(station_meteo,meteoFileAccess)  "" }

   #--   Initialise l'intervalle de rafraichissement de la lecture des donnees meteo
   if { ! [ info exists conf(station_meteo,cycle) ] }       { set conf(station_meteo,cycle)       "1" }

   #--- Initialisation des variables audace
   set audace(meteo,obs,pressure)    "101325"
   set audace(meteo,obs,temperature) "290"

}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::station_meteo::getPluginTitle { } {
   global caption

   return "$caption(station_meteo,label)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::station_meteo::getPluginHelp { } {
   return "station_meteo.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#
#  return "equipment"
#------------------------------------------------------------
proc ::station_meteo::getPluginType { } {
   return "equipment"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::station_meteo::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::station_meteo::getStartFlag { } {
   return $::conf(station_meteo,start)
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::fillConfigPage { frm } {
   variable widget
   global audace caption conf

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Copie de conf(...) dans la variable widget
   #set widget(pressure)    $conf(station_meteo,pressure)
   #set widget(temperature) $conf(station_meteo,temperature)
   set widget(pressure)    $audace(meteo,obs,pressure)
   set widget(temperature) [expr { $audace(meteo,obs,pressure)-273.15 }]

   set widget(meteoFileAccess) $conf(station_meteo,meteoFileAccess)

   set fileName [file tail $widget(meteoFileAccess)]
   if {$fileName ne ""} {
      set widget(sensorName) $fileName
   } else {
      #--   Premier de la liste
      set widget(sensorName) [lindex "$caption(station_meteo,sensor)" 0]
   }
   set widget(cycle) $conf(station_meteo,cycle)
   set widget(meteo) 0

   #--- Frame pour le choix de la liaison et de la combinaison
   frame $frm.frame1 -borderwidth 0 -relief raised

   pack $frm.frame1 -side top -fill x

   #--- Frame des boutons de commande
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Label du nom du fichier de donnees meteo
      label $frm.frame2.labelSensorname -text "$caption(station_meteo,sensname)"
      grid $frm.frame2.labelSensorname -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--- Choix de la liaison
      set sensorList "$caption(station_meteo,sensor)"
      ComboBox $frm.frame2.sensorname \
         -width [::tkutil::lgEntryComboBox "$sensorList"] \
         -height [llength $sensorList] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::station_meteo::widget(sensorName) \
         -modifycmd "" \
         -values $sensorList
      grid $frm.frame2.sensorname -row 0 -column 1 -sticky ew

      #--- Label du nom du fichier de donnees meteo
      label $frm.frame2.labelAccess -text "$caption(station_meteo,meteoAcc)"
      grid $frm.frame2.labelAccess -row 1 -column 0 -padx 5 -pady 5 -sticky w

      #--  Chemin du fichier
      entry $frm.frame2.access -width 30 -justify right -state disabled\
         -textvariable ::station_meteo::widget(meteoFileAccess)
      grid  $frm.frame2.access -row 1 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton pour definir le chemin d'acces au fichier meteo
      button $frm.frame2.search -text "$caption(station_meteo,search)" -relief raised \
         -command "::station_meteo::configDirname $frm.frame2.search"
      grid $frm.frame2.search -row 1 -column 2 -padx 5 -pady 5 -sticky ew

      #--- Checkbutton d'activation de la lecture du fichier
      checkbutton $frm.frame2.readfile -text "$caption(station_meteo,meteo)" \
         -variable ::station_meteo::widget(meteo) -onvalue 1 -offvalue 0 \
         -command "::station_meteo::onChangeMeteo"
      grid $frm.frame2.readfile -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- Saisie de la frequence de lecture
      entry $frm.frame2.cycle -width 5 -justify center \
         -textvariable ::station_meteo::widget(cycle) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 300 }
      grid $frm.frame2.cycle -row 2 -column 1 -padx 5 -pady 5 -sticky w

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame pour le site web et le checkbutton creer au demarrage
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Site web officiel des stations meteo supportees
      label $frm.frame3.lab103 -text "$caption(station_meteo,site_web)"
      pack $frm.frame3.lab103 -side top -fill x -pady 2

      set labelName [ ::confEqt::createUrlLabel $frm.frame3 "$caption(station_meteo,site_web_ref)" \
         "$caption(station_meteo,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Frame du bouton Arreter et du checkbutton creer au demarrage
      frame $frm.frame3.start -borderwidth 0 -relief flat

         #--- Bouton Arreter
         button $frm.frame3.start.stop -text "$caption(station_meteo,arreter)" -relief raised \
            -command { ::station_meteo::deletePlugin }
         pack $frm.frame3.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

         #--- Checkbutton demarrage automatique
         checkbutton $frm.frame3.start.chk -text "$caption(station_meteo,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(station_meteo,start)
         pack $frm.frame3.start.chk -side top -padx 10 -pady 3 -expand 1

      pack $frm.frame3.start -side left -expand 1

   pack $frm.frame3 -side bottom -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::configurePlugin { } {
   variable widget
   global audace conf

   #--- Memorise la configuration dans le tableau conf(station_meteo,...)
   #set conf(station_meteo,pressure)        $widget(pressure)
   set conf(station_meteo,pressure)        $audace(meteo,obs,pressure)
   #set conf(station_meteo,temperature)     $widget(temperature)
   set conf(station_meteo,temperature)     $audace(meteo,obs,temperature)
   set conf(station_meteo,meteoFileAccess) $widget(meteoFileAccess)
   set conf(station_meteo,cycle)           $widget(cycle)

   #--- Mise a jour des variables audace
   #set audace(meteo,obs,pressure)    $conf(station_meteo,pressure)
   #set audace(meteo,obs,temperature) $conf(station_meteo,temperature)
}

#------------------------------------------------------------
#  createPlugin
#
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::createPlugin { } {
   ::station_meteo::onChangeMeteo refresh
}

#------------------------------------------------------------
#  deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::station_meteo::deletePlugin { } {
   ::station_meteo::onChangeMeteo stop
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::station_meteo::isReady { } {
   variable widget

   if {$widget(meteo) == 0} {
      return "1"
   } else {
      return "0"
   }
}

#==============================================================
# Procedures specifiques du plugin
#==============================================================

   #------------------------------------------------------------
   #  refreshMeteo : mise a jour de 'Météo'
   #  Lit les donnees de realtime.txt ou de infodata.txt
   #  Note : la temperature et la pression sont des variables de hip2tel
   #------------------------------------------------------------
   proc ::station_meteo::refreshMeteo { } {
      variable widget

      #--   arrete si incoherence entre le nom du fichier et son chemin
      if {$widget(meteo) == 0 || [file exists $widget(meteoFileAccess)] == 0} {
         onChangeMeteo stop
         return
      }

      switch -exact $widget(sensorName) {
         realtime.txt {set result [readCumulus $widget(meteoFileAccess)]}
         infodata.txt {set result [readSentinelFile $widget(meteoFileAccess)]}
      }

      #--   compare les dates jd et arrete si l'ecart est superieur a 50 cycles
      #     ou si le nb de donnes est incorrect
      set t1 [lindex $result 0]
      set t2 [mc_date2jd [clock format [clock seconds] -format "%Y %m %d %H %M %S" -timezone :localtime]]
      set deltaTime [expr { $t2-$t1 }]
      set seuil [expr { 50.*$widget(cycle)/86400 }]
      if {[llength $result] != 7 || $deltaTime > $seuil} {
         onChangeMeteo stop
         return
      }

      #--   analyse les valeurs
      #--   elimine les unites
      set entities [list "\{" "" "\}" "" "°C" "" "%" "" "°" "" "m/s" "" "Pa" ""]
      set data [string map $entities [lrange $result 1 end]]

      ::station_meteo::getValues $data

      #--   note : ne pas oublier de regler le zero de la direction du vent dans Cumulus
      #     pour que le Sud corresponde a 0°

      set cycle [expr { $widget(cycle)*1000 }] ; #convertit en ms
      set widget(afterID) [after $cycle ::station_meteo::refreshMeteo]
   }

   #------------------------------------------------------------
   #  onChangeMeteo  :
   #  si toutes les conditions sont reunies
   #  sinon desactive
   #------------------------------------------------------------
   proc ::station_meteo::onChangeMeteo { {do ""} } {
      variable widget
      global audace

      if {$do eq "refresh"} {

         set cycle [expr { $widget(cycle)*1000 }] ; #convertit en ms
         set widget(afterID) [after $cycle ::station_meteo::refreshMeteo]

         #--   Indicateur de la checkbox
         set widget(meteo) 1
         update

         #--   Demarre la mise a jour
         refreshMeteo

      } elseif {$do eq "stop"} {

         #--   Arrete la lecture
         if {[info exists widget(afterID)]} {
            after cancel ::station_meteo::refreshMeteo
            unset widget(afterID)
         }

         #--   Initialise par defaut
         ::station_meteo::getValues [list 16.85 - - - - 101325]

         #--   Decoche la checkbox
         set widget(meteo) 0
         update

      }
   }

   #---------------------------------------------------------------------------
   #  getValues
   #     affecte les valeurs aux variables
   #---------------------------------------------------------------------------
   proc ::station_meteo::getValues { data } {
      variable widget
      global audace

      lassign $data widget(temperature) widget(hygro) widget(temprose) widget(windsp) widget(winddir) widget(pressure)
      set audace(meteo,obs,temperature) [expr { $widget(temperature)+273.15 }]
      set audace(meteo,obs,pressure) $widget(pressure)

      #--   Debug
      ::console::disp "$widget(temperature) $widget(pressure)\n$audace(meteo,obs,temperature) $audace(meteo,obs,pressure)\n"
   }

   #---------------------------------------------------------------------------
   #  configDirname
   #  Commande du bouton '...'
   #---------------------------------------------------------------------------
   proc ::station_meteo::configDirname { this } {
      variable widget
      global caption

      set dirname [tk_chooseDirectory -title "$caption(station_meteo,meteoAcc)" \
         -initialdir "C:/" -parent $this]

      #--   verifie la presence du fichier
      set file [file join $dirname $widget(sensorName)]
      if {[file exists $file]} {
         set widget(meteoFileAccess) "$file"
      }
   }
