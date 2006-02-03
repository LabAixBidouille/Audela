#
# Fichier : ethernaude.tcl
# Description : Interface de liaison EthernAude
# Auteurs : Robert DELMAS et Michel PUJOL
# Date de mise a jour : 01 fevrier 2006
#

package provide ethernaude 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init              : initialise le namespace (appelee pendant le chargement de ce source)
#     getDriverName     : retourne le nom du driver
#     getLabel          : retourne le nom affichable du driver 
#     getHelp           : retourne la documentation htm associee
#     getDriverType     : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf          : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()
#     fillConfigPage    : affiche la fenetre de configuration de ce driver 
#     confToWidget      : copie le tableau conf() dans les variables des widgets
#     widgetToConf      : copie les variables des widgets dans le tableau conf()
#     configureDriver   : configure le driver 
#     stopDriver        : arrete le driver et libere les ressources occupees
#     isReady           : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :
#     testping          : teste la connexion d'un appareil
#     ConfEthernAude    : gestion des boutons
#.....coord_GPS         : coordonnees GPS de l'observateur
#.....

namespace eval ethernaude {
   variable This
   global ethernaude

   #==============================================================
   # Procedures generiques de configuration des drivers
   #==============================================================

   #------------------------------------------------------------
   #  init (est lance automatiquement au chargement de ce fichier tcl)
   #     initialise le driver
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- Charge le fichier caption
      uplevel #0  "source \"[ file join $audace(rep_plugin) link ethernaude ethernaude.cap ]\""

      #--- Cree les variables dans conf(...) si elles n'existent pas
      initConf

      #--- Charge les fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) link ethernaude alaudine_nt.tcl ]\""

      #--- J'initialise les variables widget(..)
      confToWidget

      return [namespace current]
   }

   #------------------------------------------------------------
   #  getDriverType 
   #     retourne le type de driver
   #  
   #  return "link"
   #------------------------------------------------------------
   proc getDriverType { } {
      return "link"
   }

   #------------------------------------------------------------
   #  getLabel
   #     retourne le label du driver
   #  
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(ethernaude,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #  
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {

      return "ethernaude.htm"
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(ethernaude,host) ] }       { set conf(ethernaude,host)       "192.168.0.123" }
      if { ! [ info exists conf(ethernaude,ipsetting) ] }  { set conf(ethernaude,ipsetting)  "0" }
      if { ! [ info exists conf(ethernaude,canspeed) ] }   { set conf(ethernaude,canspeed)   "7" }

      return
   }

   #------------------------------------------------------------
   #  confToWidget 
   #     copie les parametres du tableau conf() dans les variables des widgets
   #  
   #  return rien
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(conf_ethernaude,host)      $conf(ethernaude,host)
      set widget(conf_ethernaude,ipsetting) $conf(ethernaude,ipsetting)
      set widget(conf_ethernaude,canspeed)  $conf(ethernaude,canspeed)
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variables des widgets dans le tableau conf()
   #  
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf
      
      set conf(ethernaude,host)             $widget(conf_ethernaude,host)
      set conf(ethernaude,ipsetting)        $widget(conf_ethernaude,ipsetting)
      set conf(ethernaude,canspeed)         $widget(conf_ethernaude,canspeed)
   }

   #------------------------------------------------------------
   #  fillConfigPage 
   #     fenetre de configuration du driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
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

      entry $frm.host -width 18 -textvariable ::ethernaude::widget(conf_ethernaude,host)
      pack $frm.host -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

      #--- Bouton de test de la connexion
      button $frm.ping -text "$caption(ethernaude,test_ethernaude)" -relief raised -state normal \
         -command "::ethernaude::testping $::ethernaude::widget(conf_ethernaude,host)"
      pack $frm.ping -in $frm.frame1 -anchor center -side top -padx 70 -pady 7 -ipadx 10 -ipady 5 -expand true

      #--- Envoi ou non de l'adresse IP a l'EthernAude
      checkbutton $frm.ipsetting -text "$caption(ethernaude,envoyer_adresse_eth)" -highlightthickness 0 \
         -variable ::ethernaude::widget(conf_ethernaude,ipsetting)
      pack $frm.ipsetting -in $frm.frame2 -anchor center -side left -padx 10 -pady 2

      #--- Definition de la vitesse de lecture d'un pixel
      label $frm.lab2 -text "$caption(ethernaude,lecture_pixel)"
      pack $frm.lab2 -in $frm.frame3 -anchor center -side left -padx 10 -pady 2

      entry $frm.lecture_pixel -textvariable ::ethernaude::widget(conf_ethernaude,canspeed) -width 3 -justify center
      pack $frm.lecture_pixel -in $frm.frame3 -anchor center -side left -pady 2

      label $frm.lab3 -text "$caption(ethernaude,micro_sec_bornes)"
      pack $frm.lab3 -in $frm.frame3 -anchor center -side left -padx 2 -pady 2

      #--- Coordonnees GPS de l'observateur
      button $frm.coord_gps -text "$caption(ethernaude,coord_gps)" -relief raised -state normal \
         -command "::ethernaude::coord_GPS"
      pack $frm.coord_gps -in $frm.frame4 -anchor center -side left -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

      #--- Alimentation AlAudine NT avec port I2C
      button $frm.alaudine_nt -text "$caption(ethernaude,alaudine_nt)" -relief raised -state normal \
         -command "::AlAudine_NT::run $audace(base).alimAlAudineNT"
      pack $frm.alaudine_nt -in $frm.frame4 -anchor center -side left -padx 10 -pady 2 -ipadx 10 -ipady 5 -expand true

      #--- Lancement de la presentation et du tutorial
      button $frm.tutorial -text "$caption(ethernaude,tutorial_ethernaude)" -relief raised -state normal \
         -command "catch { source [ file join $audace(rep_plugin) link ethernaude tutorial tuto.tcl ] }"
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
   #  configureDriver
   #     configure le driver
   #  
   #  return nothing
   #------------------------------------------------------------
   proc configureDriver { } {
      global audace

      #--- Affiche la liaison
      ::ethernaude::run "$audace(base).ethernaude"

      #--- Gestion des boutons actifs/inactifs
      ::ethernaude::ConfEthernAude

      return
   }

   #------------------------------------------------------------
   #  stopDriver
   #     arrete le driver et libere les ressources occupees
   #  
   #  return nothing
   #------------------------------------------------------------
   proc stopDriver { } {

      #--- Ferme la liaison
      fermer
      return
   }

   #------------------------------------------------------------
   #  isReady 
   #     informe de l'etat de fonctionnement du driver
   #  
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {

      return 0
   }

   #==============================================================
   # Procedures specifiques du driver 
   #==============================================================

   #------------------------------------------------------------
   #  testping ip 
   #     teste la connexion d'un appareil
   #------------------------------------------------------------
   proc testping { ip } {
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
   # ConfEthernAude
   #    Permet d'activer ou de desactiver les boutons
   #------------------------------------------------------------
   proc ConfEthernAude { } {
      variable widget
      global caption
      global conf
      global confCam

      set frm $widget(frm)
      set cam_item $confCam(cam_item)

      if { ( [ ::confCam::getProduct $confCam(camera,$cam_item,camNo) ] == "audine" ) && \
         ( $conf(audine,port) == "$caption(confcam,ethernaude)" ) } {
         #--- Boutons actifs
         $frm.coord_gps configure -state normal
         $frm.alaudine_nt configure -state normal
      } else {
         #--- Boutons inactifs
         $frm.coord_gps configure -state disabled
         $frm.alaudine_nt configure -state disabled
      }
   }

   #------------------------------------------------------------
   # coord_GPS
   #    Permet d'obtenir les coordonnees GPS de l'observateur
   #------------------------------------------------------------
   proc coord_GPS { } {
      global confCam
      global caption

      catch {
         set coord_GPS_Observateur [ cam$confCam(camera,$confCam(cam_item),camNo) gps ]
         ::console::disp "$coord_GPS_Observateur \n\n"
         set long_GPS_Observateur [ mc_angle2dms [ lindex $coord_GPS_Observateur 1 ] 180 ]
         ::console::disp "$caption(ethernaude,longitude) [ lindex $coord_GPS_Observateur 2 ] [ format "%2d° %2d' %4.2f''" [ lindex $long_GPS_Observateur 0 ] [ lindex $long_GPS_Observateur 1 ] [ lindex $long_GPS_Observateur 2 ] ] \n"
         set lat_GPS_Observateur [ mc_angle2dms [ lindex $coord_GPS_Observateur 3 ] 90 ]
         ::console::disp "$caption(ethernaude,latitude) [ format "%2d° %2d' %4.2f''" [ lindex $lat_GPS_Observateur 0 ] [ lindex $lat_GPS_Observateur 1 ] [ lindex $lat_GPS_Observateur 2 ] ] \n"
         ::console::disp "$caption(ethernaude,altitude) [ format "%5.0f m" [ lindex $coord_GPS_Observateur 4 ] ] \n\n"
      }
   }

}

::ethernaude::init

