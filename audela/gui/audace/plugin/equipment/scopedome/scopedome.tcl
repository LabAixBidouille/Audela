#
# Fichier : scopedome.tcl
# Description : Gere un dome ASCOM
# Auteur : Raymond ZACHANTKE
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

# Procedures specifiques a ce plugin : cf scopedome_driver.tcl

namespace eval scopedome {

   package provide scopedome 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] scopedome.cap ]
   source [ file join [file dirname [info script]] scopedome_driver.tcl ]

}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::scopedome::getPluginTitle { } {
   global caption

   return "$caption(scopedome,label)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::scopedome::getPluginHelp { } {
   return "scopedome.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#
#  return "equipment"
#------------------------------------------------------------
proc ::scopedome::getPluginType { } {
   return "equipment"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::scopedome::getPluginOS { } {
   return [ list Windows ]
}

#------------------------------------------------------------
#  getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::scopedome::getStartFlag { } {
   return $::conf(scopedome,start)
}

#------------------------------------------------------------
# getDomNo
#    Retourne le numero du dome
#------------------------------------------------------------
proc ::scopedome::getDomNo { } {
   variable widget

   return $widget(domNo)
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::scopedome::isReady { } {
   variable widget

   #--- Dome KO
   set result 0
   if {[info exists widget(domNo)] ==1 && $widget(domNo) == "1" } {
      #--- Dome OK
      set result 1
   }
   return $result
}

#------------------------------------------------------------
#  initPlugin
#     initialise le plugin
#------------------------------------------------------------
proc ::scopedome::initPlugin { } {
   variable widget
   global conf

   #--- Initialise les variables conf
   if { ! [ info exists conf(scopedome,fileName) ] }   { set conf(scopedome,fileName)   "ASCOM.ScopeDomeUSBDome.exe" }
   if { ! [ info exists conf(scopedome,fileAccess) ] } { set conf(scopedome,fileAccess) "" }
   if { ! [ info exists conf(scopedome,start) ] }      { set conf(scopedome,start)      "0" }
}

#------------------------------------------------------------
#  confToWidget
#     recupere la configuration
#------------------------------------------------------------
proc ::scopedome::confToWidget { } {
   variable widget
   global conf

   #--- Recupere la configuration du driver
   set widget(fileName)   $conf(scopedome,fileName)
   set widget(fileAccess) $conf(scopedome,fileAccess)
   set widget(filesystem) "C:/ScopeDome/ScopeDomeCurrentTelescopeStatus.txt"
   set widget(windowName) "ScopeDome LS" ; # nom de l'interface

   set widget(connectScope) 0
   #set widget(domNo)        0

   set widget(driverversion) ""

   #--   Properties list
   set widget(propertyList)   [list Azimuth AtHome AtPark Connected ShutterStatus \
                              Slaved Slewing Dome_Scope_Is_Connected \
                              Dome_Scope_Ra Dome_Scope_Dec Dome_Scope_Alt Dome_Scope_Az \
                              Temperature_In_Dome Temperature_Outside_Dome \
                              Temperature_Humidity_Sensor Humidity_Humidity_Sensor \
                              Pressure Dew_Point Wind_Speed Wind_Direction \
                              Temperature_In_From_Weather_Station \
                              Temperature_Out_From_Weather_Station \
                              Cloud_Sensor_Day_Night Cloud_Sensor_Clear_Cloudy Cloud_Sensor_Rain \
                              Shutter_Link_Strength Internal_Sensor_Observatory_Safe \
                              Internal_Sensor_Clouds Internal_Sensor_Rain \
                              Internal_Sensor_Power_Failure Internal_Sensor_Free_Input \
                              Internal_Sensor_Scope_At_Home Dome_Error \
                              Analog_Input_Shutter Analog_Input_Main]

   #--   Ascom command list with boolean parameter (True|False)
   #--   suppression de Slaved (doublon avec Scope_Sync)
   set widget(switchList)      [list Scope_Sync Wind_Sync Sky_Sync Weather_Protect]
   set widget(switchValueList) {On Off Toggle}
   set widget(switch)          [lindex $widget(switchValueList) 0]

   #--   Ascom command list with numerical parameter
   #--   suppression de SlewToAzimuth (doublon avec GoTo)
   set widget(cmdList)    [list SyncToAzimuth GoTo Enc_GoTo]

   #--   Ascom + Action list excluding :
   #--   Excluding configuration command : SetUpDialog SetPark Dispose FindHome CloseShutter OpenShutter
   #  Dome_Find_Home Calibrate_Dome_Az_Encoder Calibrate_Dome_Inertia Reset_Dome_Az_Encoder Restore_Default
   set widget(actionList)    [list AbortSlew Park Stop\
                                 Rel_Scope_On Rel_Scope_Off Rel_CCD_On Rel_CCD_Off \
                                 Rel_Light_On Rel_Light_Off Rel_Fan_On Rel_Fan_Off \
                                 Rel_1_On Rel_1_Off Rel_2_On Rel_2_Off \
                                 Rel_3_On Rel_3_Off Rel_4_On Rel_4_Off \
                                 Switch_All_On Switch_All_Off \
                                 Dome_Scope_Connect Dome_Scope_DisConnect \
                                 Shutter_1_Open Shutter_1_Close \
                                 Shutter_2_Open Shutter_2_Close \
                                 Dome_Wait_1000ms Reset_Dome_Rotate_Encoder]

   #--   Selectionne le premier de la liste
   foreach f [list property switch cmd action] {
      set widget(${f}) [lindex $widget(${f}List) 0]
   }
}


#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::scopedome::fillConfigPage { frm } {
   variable widget
   global audace caption

   package require twapi 2.0

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   ::scopedome::confToWidget

   set pid [twapi::get_process_ids -name $widget(fileName)]
   if {$pid ne ""} {
      set state normal
   } else {
      set state disabled
   }

   #--- Frame des boutons de commande
   frame $frm.frame2 -borderwidth 0 -relief raised

      #--- Label du nom du fichier
      label $frm.frame2.labelFile -text "$caption(scopedome,fileName)"
      grid $frm.frame2.labelFile -row 0 -column 0 -padx 5 -pady 5 -sticky w

      #--  Nom du fichier
      entry $frm.frame2.file -width 40 -justify right -state normal \
         -textvariable ::scopedome::widget(fileName)
      grid  $frm.frame2.file -row 0 -column 1 -padx 5 -pady 5 -sticky w

      #--- Label du chemin du driver
      label $frm.frame2.labelAccess -text "$caption(scopedome,fileAccess)"
      grid $frm.frame2.labelAccess -row 1 -column 0 -padx 5 -pady 5 -sticky w

      #--  Chemin complet du driver
      entry $frm.frame2.access -width 40 -justify right -state normal \
         -textvariable ::scopedome::widget(fileAccess)
      grid  $frm.frame2.access -row 1 -column 1 -padx 5 -pady 5 -sticky w

      #--- Bouton pour definir chemin
      button $frm.frame2.search -text "$caption(scopedome,search)" -relief raised \
         -command "::scopedome::configDirname $frm.frame2.search"
      grid $frm.frame2.search -row 1 -column 2 -padx 5 -pady 5 -sticky ew

      #--   Label d'Info sur le driver connecte
      label $frm.frame2.labelVersion -text "$caption(scopedome,version)"
      grid $frm.frame2.labelVersion -row 2 -column 0 -padx 5 -pady 5 -sticky w

      #--- N° de version
      label $frm.frame2.version -justify left \
         -textvariable ::scopedome::widget(driverversion)
      grid  $frm.frame2.version -row 2 -column 1 -padx 5 -pady 5 -sticky w

      #--- Checkbutton pour le transfert des coordonnees du telescope
      checkbutton $frm.frame2.connect -text "$caption(scopedome,connectScope)" \
            -highlightthickness 0 -variable ::scopedome::widget(connectScope)
      grid $frm.frame2.connect -row 3 -column 0 -columnspan 2 -padx 5 -pady 5 -sticky w

      #--- Label des proprietes
      label $frm.frame2.labelProperty -text "$caption(scopedome,sensor) "
      grid  $frm.frame2.labelProperty -row 4 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox property 4 $state
      #--- Label du resultat
      label $frm.frame2.labelPropertyResult -textvariable ::scopedome::widget(propertyResult)
      grid  $frm.frame2.labelPropertyResult -row 4 -column 2 -padx 5 -pady 5 -sticky w

      #--- Label des commandes ascom avec boolen
      label $frm.frame2.labelSwitch -text "$caption(scopedome,cmdswitch)"
      grid  $frm.frame2.labelSwitch -row 5 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox switch 5 $state
      ComboBox $frm.frame2.switchvalue -width 5 -height 2 -relief sunken \
         -borderwidth 1 -editable 0 -state $state -values $widget(switchValueList) \
         -textvariable ::scopedome::widget(switchValue)
      grid  $frm.frame2.switchvalue -row 5 -column 2 -padx 5 -pady 5 -sticky w

      #--- Label des commandes ascom avec 1 parametre
      label $frm.frame2.labelCmd -text "$caption(scopedome,cmddbl)"
      grid  $frm.frame2.labelCmd -row 6 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox cmd 6 $state
      entry $frm.frame2.cmdvalue -width 5 -justify right -state $state \
         -textvariable ::scopedome::widget(cmdValue)
      grid  $frm.frame2.cmdvalue -row 6 -column 2 -padx 5 -pady 5 -sticky w

      #--- Label des commandes avec Action
      label $frm.frame2.labelAction -text "$caption(scopedome,action)"
      grid  $frm.frame2.labelAction -row 7 -column 0 -padx 5 -pady 5 -sticky w
      ::scopedome::buildComboBox action 7 $state

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame pour le site web et le checkbutton creer au demarrage
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Site web officiel de scopedome
      label $frm.frame3.lab103 -text "$caption(scopedome,site_web)"
      pack $frm.frame3.lab103 -side top -fill x -pady 2

      set widget(site_web_ref) "$caption(scopedome,site_web_scopedome)"
      set labelName [ ::confEqt::createUrlLabel $frm.frame3 "$widget(site_web_ref)" \
         "$widget(site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Frame du bouton Arreter et du checkbutton creer au demarrage
      frame $frm.frame3.start -borderwidth 0 -relief flat

         #--- Bouton Arreter
         button $frm.frame3.start.stop -text "$caption(scopedome,arreter)" -relief raised \
            -command { ::scopedome::deletePlugin }
         pack $frm.frame3.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

         #--- Checkbutton demarrage automatique
         checkbutton $frm.frame3.start.chk -text "$caption(scopedome,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(scopedome,start)
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
proc ::scopedome::configurePlugin { } {
   variable widget
   global conf

   #--- Memorise le chemin du driver
   set conf(scopedome,fileAccess) $widget(fileAccess)
   set conf(scopedome,fileName) $widget(fileName)
}

#------------------------------------------------------------
#  createPlugin
#     demarre le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::scopedome::createPlugin { } {
   variable widget
   global conf caption

   #--   Initialise les variables widgets necessaires au lancement automatique
   if {$conf(scopedome,start) ==1} {
      ::scopedome::confToWidget
      set widget(frm) ".audace.confeqt.usr.onglet.fscopedome"
   }

   if {[info exists widget(domNo)] ==0 || $widget(domNo) == 0} {

      lassign [::scopedome::createProcess "$widget(fileAccess)" "$widget(windowName)"] \
         widget(comobj) widget(domNo)

      if {$widget(comobj) ne ""} {

         #--  Recupere les infos sur le driver
         set widget(driverversion) [$widget(comobj) DriverInfo]

         #--   Libere les combobox
         ::scopedome::configStateComboBox normal

         #--   Lance le transfert des cordonnees du telescope
         if {$widget(connectScope) ==1} {
            ::scopedome::onChangeScope refresh
         } else {
            ::scopedome::onChangeScope stop
         }
      }
   }
}

#------------------------------------------------------------
#  deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::scopedome::deletePlugin { } {
   variable widget

   if {$widget(domNo) ==1} {

      ::scopedome::killCom

      #--   Remet a 0 l'indicateur
      set widget(domNo) 0

      #--   Arrete le transfert des coordonnees du telescope
      ::scopedome::onChangeScope stop

      #--   Reinitialise les variables
      ::scopedome::confToWidget

      #--   Inhibe les combobox
      ::scopedome::configStateComboBox disabled
   }
}

#==============================================================
# Procedures utilitaires
#==============================================================

#---------------------------------------------------------------------------
#  configDirname
#     commande du bouton '...'
#  parameter : name of frame to modify
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::configDirname { this } {
   variable widget
   global caption

   set dirname [tk_chooseDirectory -title "$caption(scopedome,fileAccess)" \
      -initialdir "C:/" -parent $this]

   #--   verifie la presence du fichier
   set file [file join $dirname $widget(fileName)]

   if {[file exists $file]} {
      set widget(fileAccess) "$file"
   } else {
      set widget(fileAccess) ""
      ::scopedome::errorBox error
   }
}

#---------------------------------------------------------------------------
#  buildComboBox
#     construit une combobox
#  parameter : name, row and state
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::buildComboBox { type row {state disabled} } {
   variable widget

   set frame $widget(frm).frame2.$type

   set height [llength $widget(${type}List)]
   #set widget(${type}) [lindex $widget(${type}List) 0]
   ComboBox $frame \
        -width 40 \
         -height $height \
         -relief sunken \
         -borderwidth 1 \
         -editable 0 \
         -state $state \
         -textvariable ::scopedome::widget(${type}) \
         -values [lsort -dictionary $widget(${type}List)] \
         -modifycmd "::scopedome::cmd $type"
   grid $frame -row $row -column 1 -padx 5 -pady 5 -sticky w
}

#---------------------------------------------------------------------------
#  configStateComboBox
#     configure Combobox state
#  parameter : none
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::configStateComboBox { state } {
   variable widget

   #--   Disable les combobox
   foreach child [list property switch cmd action] {
      if {[winfo exists $widget(frm).frame2.$child] ==1} {
         $widget(frm).frame2.$child configure -state $state
      }
   }
   if {[winfo exists $widget(frm).frame2.switchvalue] ==1} {
      $widget(frm).frame2.switchvalue configure -state $state
   }
   if {[winfo exists $widget(frm).frame2.cmdvalue] ==1} {
      $widget(frm).frame2.cmdvalue configure -state $state
   }
}

#---------------------------------------------------------------------------
#  errorBox
#     affiche un fenetre d'erreur
#  parameter : none
#  return nothing
#---------------------------------------------------------------------------
proc ::scopedome::errorBox { error } {
   variable widget
   global caption

   tk_messageBox -parent $widget(frm).frame2 -title $caption(scopedome,warning) \
      -message "$caption(scopedome,$error)" -type ok -icon warning
}

