#
# Fichier : audinet.tcl
# Description : Interface de liaison AudiNet
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id$
#

namespace eval audinet {
   package provide audinet 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] audinet.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::audinet::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libaudinet.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audinet::getPluginType]] "audinet" "libaudinet.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(audinet,installNewVersion) $sourceFileName [package version audinet] ]
   }
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::audinet::configurePlugin { } {
   global audace

   #--- Affiche la liaison
  ### ::audinet::run "$audace(base).audinet"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::audinet::confToWidget { } {
   variable widget
   global conf

   set widget(audinet,host)         $conf(audinet,host)
   set widget(audinet,ipsetting)    $conf(audinet,ipsetting)
   set widget(audinet,mac_address)  $conf(audinet,mac_address)
   set widget(audinet,protocole)    $conf(audinet,protocole)
   set widget(audinet,udptempo)     $conf(audinet,udptempo)
   set widget(audinet,debug)        $conf(audinet,debug)
   set widget(audinet,autoflush)    $conf(audinet,autoflush)
   set widget(audinet,focuser_type) $conf(audinet,focuser_type)
   set widget(audinet,focuser_addr) $conf(audinet,focuser_addr)
   set widget(audinet,focuser_bit)  $conf(audinet,focuser_bit)
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::audinet::createPluginInstance { linkLabel deviceId usage comment args } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::audinet::deletePluginInstance { linkLabel deviceId usage } {
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::audinet::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::audinet::getPluginTitle { } {
   global caption

   return "$caption(audinet,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::audinet::getPluginHelp { } {
   return "audinet.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::audinet::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::audinet::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::audinet::fillConfigPage { frm } {
   variable widget
   global caption color

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill both -expand 1

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 1

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill both -expand 1

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -side top -fill both -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -side top -fill both -expand 1

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -side bottom -fill x -pady 2

   #--- Definition du host pour une connexion Ethernet
   label $frm.lab1 -text "$caption(audinet,host_audinet)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10

   entry $frm.host -width 18 -textvariable ::audinet::widget(audinet,host)
   pack $frm.host -in $frm.frame1 -anchor center -side left -padx 10

   #--- Bouton de test de la connexion
   button $frm.ping -text "$caption(audinet,test_audinet)" -relief raised -state normal \
      -command {
         #--- Si l'envoi de l'adresse IP est demande, j'execute setip avant ping
         if { $::audinet::widget(audinet,ipsetting) == "1" } {
            #--- Remarque : Comme setip est une commande specifique a une camera audinet,
            #--- il faut creer temporairement une camera de type audinet pour pouvoir executer la commande
            set camtemp [ cam::create audinet -debug_directory $::audace(rep_log) ]
            set erreur [ catch { cam$camtemp setip $::audinet::widget(audinet,mac_address) $::audinet::widget(audinet,host) } msg ]
            if { $erreur == "1" } {
               tk_messageBox -message "$caption(audinet,erreur_setip)" -icon error
            }
            cam::delete $camtemp
         }
         #--- J'execute la commande ping
         ::audinet::testping $::audinet::widget(audinet,host)
      }
   pack $frm.ping -in $frm.frame1 -anchor center -side top -padx 70 -pady 7 -ipadx 10 -ipady 5 -expand true

   #--- Envoi ou non de l'adresse IP a Audinet
   checkbutton $frm.ipsetting -text "$caption(audinet,envoyer_adresse_aud)" -highlightthickness 0 \
      -variable ::audinet::widget(audinet,ipsetting)
   pack $frm.ipsetting -in $frm.frame2 -anchor center -side left -padx 10 -pady 2

   #--- Definition de l'adresse MAC
   entry $frm.macaddress -width 17 -textvariable ::audinet::widget(audinet,mac_address)
   pack $frm.macaddress -in $frm.frame2 -anchor center -side right -padx 10

   label $frm.labMac -text "$caption(audinet,mac_address)"
   pack $frm.labMac -in $frm.frame2 -anchor center -side right -padx 0

   #--- Definition du protocole
   label $frm.lab3 -text "$caption(audinet,protocole_audinet)"
   pack $frm.lab3 -in $frm.frame3 -anchor center -side left -padx 10 -pady 5

   set list_combobox [ list $caption(audinet,protocole_udp) $caption(audinet,protocole_tcp) ]
   ComboBox $frm.protocole \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::audinet::widget(audinet,protocole) \
      -values $list_combobox
   pack $frm.protocole -in $frm.frame3 -anchor center -side left -padx 10 -pady 5

   #--- Definition de la temporisation
   label $frm.lab4 -text "$caption(audinet,tempo_udp)"
   pack $frm.lab4 -in $frm.frame3 -anchor center -side left -padx 10 -pady 5

   entry $frm.udptempo -width 5 -textvariable ::audinet::widget(audinet,udptempo) -justify center
   pack $frm.udptempo -in $frm.frame3 -anchor center -side left -padx 10 -pady 5

   #--- AudiNet en mode debug ou non
   checkbutton $frm.debug -text "$caption(audinet,debug) (audinet.log)" -highlightthickness 0 \
      -variable ::audinet::widget(audinet,debug)
   pack $frm.debug -in $frm.frame3 -anchor center -side right -padx 10 -pady 2

   #--- Definition du mode de vidage de la communication avec le telescope
   checkbutton $frm.autoflush -text "$caption(audinet,autoflush)" -highlightthickness 0 \
      -variable ::audinet::widget(audinet,autoflush)
   pack $frm.autoflush -in $frm.frame4 -anchor center -side left -padx 10 -pady 2

   #--- Choix du systeme de mise au point (focuser)
   label $frm.lab_focuser_type -text "$caption(audinet,focuser_type)"
   pack $frm.lab_focuser_type -in $frm.frame5 -anchor center -side left -padx 10

   set list_combobox [ list lx200 i2c ]
   ComboBox $frm.combo_focuser_type \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 0       \
      -textvariable ::audinet::widget(audinet,focuser_type) \
      -values $list_combobox \
      -modifycmd {
         #--- Autoriser/masquer l'autre widget en fontion du type de focuser
         if { $::audinet::widget(audinet,focuser_type) == "lx200" } {
            $::audinet::widget(frm).ent_focuser_adr configure -state disabled
         } else {
            $::audinet::widget(frm).ent_focuser_adr configure -state normal
         }
      }
   pack $frm.combo_focuser_type -in $frm.frame5 -anchor center -side left -padx 10

   #--- Label adresse I2C du focuser
   label $frm.lab_focuser_adr -text "$caption(audinet,focuser_i2c_address)"
   pack $frm.lab_focuser_adr -in $frm.frame5 -anchor center -side left -padx 10

   #--- Saisie adresse I2C du focuser
   entry $frm.ent_focuser_adr -width 17 -textvariable ::audinet::widget(audinet,focuser_addr)
   pack $frm.ent_focuser_adr -in $frm.frame5 -anchor center -side left -padx 10

   #--- Autoriser/masquer l'autre widget en fontion du type de focuser
   if { $::audinet::widget(audinet,focuser_type) == "lx200" } {
      $::audinet::widget(frm).ent_focuser_adr configure -state disabled
   } else {
      $::audinet::widget(frm).ent_focuser_adr configure -state normal
   }

   #--- Site web officiel de AudiNet
   label $frm.lab103 -text "$caption(audinet,site_web_ref)"
   pack $frm.lab103 -in $frm.frame6 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(audinet,site_audinet)" -fg $color(blue)
   pack $frm.labURL -in $frm.frame6 -side top -fill x -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(audinet,site_audinet)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      $::audinet::widget(frm).labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      $::audinet::widget(frm).labURL configure -fg $color(blue)
   }
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#------------------------------------------------------------
proc ::audinet::getLinkIndex { linkLabel } {
   variable private

   #--- je recupere linkIndex qui est apres le linkType dans linkLabel
   set linkIndex ""
   if { [string first $private(genericName) $linkLabel] == 0 } {
      scan $linkLabel "$private(genericName)%s" linkIndex
   }
   return $linkIndex
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne l'instance audinet unique
#
#------------------------------------------------------------
proc ::audinet::getLinkLabels { } {
   variable private

   return "$private(genericName)1"
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#------------------------------------------------------------
proc ::audinet::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#
#  return namespace name
#------------------------------------------------------------
proc ::audinet::initPlugin { } {
   variable private

   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "audinet"

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::audinet::initConf { } {
   global conf caption

   if { ! [ info exists conf(audinet,host) ] }         { set conf(audinet,host)         "168.254.216.36" }
   if { ! [ info exists conf(audinet,ipsetting) ] }    { set conf(audinet,ipsetting)    "0" }
   if { ! [ info exists conf(audinet,mac_address) ] }  { set conf(audinet,mac_address)  "00:01:02:03:04:05" }
   if { ! [ info exists conf(audinet,protocole) ] }    { set conf(audinet,protocole)    "$caption(audinet,protocole_udp)" }
   if { ! [ info exists conf(audinet,udptempo) ] }     { set conf(audinet,udptempo)     "0" }
   if { ! [ info exists conf(audinet,debug) ] }        { set conf(audinet,debug)        "0" }
   if { ! [ info exists conf(audinet,autoflush) ] }    { set conf(audinet,autoflush)    "1" }
   if { ! [ info exists conf(audinet,focuser_type) ] } { set conf(audinet,focuser_type) "lx200" }
   if { ! [ info exists conf(audinet,focuser_addr) ] } { set conf(audinet,focuser_addr) "112" }
   if { ! [ info exists conf(audinet,focuser_bit) ] }  { set conf(audinet,focuser_bit)  "0" }

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::audinet::isReady { } {
   return 0
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::audinet::selectConfigLink { linkLabel } {
   variable private

   #--- rien a faire car il n'y qu'un seul link de ce type
}

#------------------------------------------------------------
#  testping
#     teste la connexion d'un appareil
#------------------------------------------------------------
proc ::audinet::testping { ip } {
   global caption

   set res  [ ::audace_ping $ip ]
   set res1 [ lindex $res 0 ]
   set res2 [ lindex $res 1 ]
   if { $res1 == "1" } {
        set tres1 "$caption(audinet,appareil_connecte) $ip"
   } else {
        set tres1 "$caption(audinet,pas_appareil_connecte) $ip"
   }
   set tres2 "$caption(audinet,message_ping)"
   tk_messageBox -message "$tres1.\n$tres2 $res2" -icon info
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::audinet::widgetToConf { } {
   variable widget
   global conf

   set conf(audinet,host)         $widget(audinet,host)
   set conf(audinet,ipsetting)    $widget(audinet,ipsetting)
   set conf(audinet,mac_address)  $widget(audinet,mac_address)
   set conf(audinet,protocole)    $widget(audinet,protocole)
   set conf(audinet,udptempo)     $widget(audinet,udptempo)
   set conf(audinet,debug)        $widget(audinet,debug)
   set conf(audinet,autoflush)    $widget(audinet,autoflush)
   set conf(audinet,focuser_type) $widget(audinet,focuser_type)
   set conf(audinet,focuser_addr) $widget(audinet,focuser_addr)
   set conf(audinet,focuser_bit)  $widget(audinet,focuser_bit)
}

