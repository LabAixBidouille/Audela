#
# Fichier : ethernaude.tcl
# Description : Interface de liaison EthernAude
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: ethernaude.tcl,v 1.14 2007-04-10 21:14:57 robertdelmas Exp $
#

namespace eval ethernaude {
   package provide ethernaude 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] ethernaude.cap ]
}

#------------------------------------------------------------
#  ConfEthernAude
#     Permet d'activer ou de desactiver les boutons
#------------------------------------------------------------
proc ::ethernaude::ConfEthernAude { } {
   variable widget
   variable private
   global confCam

   if { [info exists widget(frm) ] } {
      set frm $widget(frm)

      if { [winfo exist $frm.coord_gps] } {
         if { $private(started) == "1" } {
            #--- Boutons actifs
            $frm.coord_gps configure -state normal
            $frm.alaudine_nt configure -state normal
         } else {
            #--- Boutons inactifs
            $frm.coord_gps configure -state disabled
            $frm.alaudine_nt configure -state disabled
         }
      }
   }
}

#------------------------------------------------------------
#  configureDriver
#     configure le driver
#
#  return nothing
#------------------------------------------------------------
proc ::ethernaude::configureDriver { } {
   global audace

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::ethernaude::confToWidget { } {
   variable widget
   global conf

   set widget(ethernaude,host)      $conf(ethernaude,host)
   set widget(ethernaude,ipsetting) $conf(ethernaude,ipsetting)
   set widget(ethernaude,debug)     $conf(ethernaude,debug)
   set widget(ethernaude,canspeed)  $conf(ethernaude,canspeed)
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::ethernaude::createPluginInstance { linkLabel deviceId usage comment } {
   #--- pour l'instant, la liaison ethernaude est demarree par le pilote de la camera
   variable private

   set private(started) "1"
   ConfEthernAude
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::ethernaude::deletePluginInstance { linkLabel deviceId usage } {
   #--- pour l'instant, la liaison ethernaude est arretee par le pilote de la camera
   variable private

   set private(started) "0"
   ConfEthernAude
   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du driver
#
#  return nothing
#------------------------------------------------------------
proc ::ethernaude::fillConfigPage { frm } {
   variable widget
   global audace
   global caption
   global color

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
   label $frm.lab1 -text "$caption(ethernaude,host_ethernaude)"
   pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

   entry $frm.host -width 18 -textvariable ::ethernaude::widget(ethernaude,host)
   pack $frm.host -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

   #--- Bouton de test de la connexion
   button $frm.ping -text "$caption(ethernaude,test_ethernaude)" -relief raised -state normal \
      -command { ::ethernaude::testping $::ethernaude::widget(ethernaude,host) }
   pack $frm.ping -in $frm.frame1 -anchor center -side top -padx 70 -pady 7 -ipadx 10 -ipady 5 -expand true

   #--- Envoi ou non de l'adresse IP a l'EthernAude
   checkbutton $frm.ipsetting -text "$caption(ethernaude,envoyer_adresse_eth)" -highlightthickness 0 \
      -variable ::ethernaude::widget(ethernaude,ipsetting)
   pack $frm.ipsetting -in $frm.frame2 -anchor center -side left -padx 10 -pady 2

   #--- EthernAude en mode debug ou non
   checkbutton $frm.debug -text "$caption(ethernaude,debug)" -highlightthickness 0 \
      -variable ::ethernaude::widget(ethernaude,debug)
   pack $frm.debug -in $frm.frame2 -anchor center -side right -padx 10 -pady 2

   #--- Definition de la vitesse de lecture d'un pixel
   label $frm.lab2 -text "$caption(ethernaude,lecture_pixel)"
   pack $frm.lab2 -in $frm.frame3 -anchor center -side left -padx 10 -pady 2

   scale $frm.lecture_pixel_variant -from "5.0" -to "15.0" -length 300 \
      -orient horizontal -showvalue true -tickinterval 1 -resolution 1 \
      -borderwidth 2 -relief groove -variable ::ethernaude::widget(ethernaude,canspeed) -width 10
   pack $frm.lecture_pixel_variant -in $frm.frame3 -anchor center -side left -pady 0

   label $frm.lab3 -text "$caption(ethernaude,micro_sec)"
   pack $frm.lab3 -in $frm.frame3 -anchor center -side left -padx 2 -pady 2

   #--- Coordonnees GPS de l'observateur
   button $frm.coord_gps -text "$caption(ethernaude,coord_gps)" -relief raised -state normal \
      -command "::eventAude_GPS::run $audace(base).eventAude_GPS"
   pack $frm.coord_gps -in $frm.frame4 -anchor center -side left -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

   #--- Alimentation AlAudine NT avec port I2C
   button $frm.alaudine_nt -text "$caption(ethernaude,alaudine_nt)" -relief raised -state normal \
      -command "::AlAudine_NT::run $audace(base).alimAlAudineNT"
   pack $frm.alaudine_nt -in $frm.frame4 -anchor center -side left -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

   #--- Lancement de la presentation et du tutorial
   button $frm.tutorial -text "$caption(ethernaude,tutorial_ethernaude)" -relief raised -state normal \
      -command "source [ file join $audace(rep_plugin) link ethernaude tutorial tuto.tcl ]"
   pack $frm.tutorial -in $frm.frame5 -anchor center -side top -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

   #--- Gestion des boutons actifs/inactifs
   ::ethernaude::ConfEthernAude

   #--- Site web officiel de l'EthernAude
   label $frm.lab103 -text "$caption(ethernaude,site_web_ref)"
   pack $frm.lab103 -in $frm.frame6 -side top -fill x -pady 2

   label $frm.labURL -text "$caption(ethernaude,site_ethernaude)" -font $audace(font,url) -fg $color(blue)
   pack $frm.labURL -in $frm.frame6 -side top -fill x -pady 2

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.labURL <ButtonPress-1> {
      set filename "$caption(ethernaude,site_ethernaude)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.labURL <Enter> {
      $::ethernaude::widget(frm).labURL configure -fg $color(purple)
   }
   bind $frm.labURL <Leave> {
      $::ethernaude::widget(frm).labURL configure -fg $color(blue)
   }
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::ethernaude::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getHelp
#     retourne la documentation du driver
#
#  return "nom_driver.htm"
#------------------------------------------------------------
proc ::ethernaude::getHelp { } {
   return "ethernaude.htm"
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::ethernaude::getPluginProperty { propertyName } {
   switch $propertyName {
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du driver dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::ethernaude::getPluginTitle { } {
   global caption

   return "$caption(ethernaude,titre)"
}

#------------------------------------------------------------
#  getLinkIndex
#     retourne l'index du link
#
#  retourne une chaine vide si le link n'existe pas
#------------------------------------------------------------
proc ::ethernaude::getLinkIndex { linkLabel } {
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
#     retourne la seule instance ethernaude
#
#------------------------------------------------------------
proc ::ethernaude::getLinkLabels { } {
   variable private

   return "$private(genericName)1"
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#------------------------------------------------------------
proc ::ethernaude::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le driver
#------------------------------------------------------------
proc ::ethernaude::initPlugin  { } {
   global audace
   variable private

   #--- Je fixe le nom generique de la liaison identique au namespace
   set private(genericName) "ethernaude"
   set private(started) "0"

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   #--- Charge les fichiers auxiliaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) link ethernaude alaudine_nt.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) link ethernaude eventaude_gps.tcl ]\""

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::ethernaude::initConf { } {
   global conf

   if { ! [ info exists conf(ethernaude,host) ] }      { set conf(ethernaude,host)       "169.254.164.70" }
   if { ! [ info exists conf(ethernaude,ipsetting) ] } { set conf(ethernaude,ipsetting)  "0" }
   if { ! [ info exists conf(ethernaude,debug) ] }     { set conf(ethernaude,debug)      "0" }
   if { ! [ info exists conf(ethernaude,canspeed) ] }  { set conf(ethernaude,canspeed)   "7" }

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du driver
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::ethernaude::isReady { } {
   return 0
}

#------------------------------------------------------------
#  selectConfigItem
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::ethernaude::selectConfigLink { linkLabel } {
   variable private

   #--- rien a faire car il n'y qu'un seul link de ce type
}

#------------------------------------------------------------
#  testping ip
#     teste la connexion d'un appareil
#------------------------------------------------------------
proc ::ethernaude::testping { ip } {
   global caption

   set res  [ ::ping $ip ]
   set res1 [ lindex $res 0 ]
   set res2 [ lindex $res 1 ]
   if { $res1 == "1" } {
        set tres1 "$caption(ethernaude,appareil_connecte) $ip"
   } else {
        set tres1 "$caption(ethernaude,pas_appareil_connecte) $ip"
   }
   set tres2 "$caption(ethernaude,message_ping)"
   tk_messageBox -message "$tres1.\n$tres2 $res2" -icon info
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::ethernaude::widgetToConf { } {
   variable widget
   global conf

   set conf(ethernaude,host)      $widget(ethernaude,host)
   set conf(ethernaude,ipsetting) $widget(ethernaude,ipsetting)
   set conf(ethernaude,debug)     $widget(ethernaude,debug)
   set conf(ethernaude,canspeed)  $widget(ethernaude,canspeed)
}

