#
# Fichier : eventaude_gps.tcl
# Description : Permet de controler l'alimentation AlAudine NT avec port I2C
# Auteur : Robert DELMAS
# Mise a jour $Id: eventaude_gps.tcl,v 1.6 2006-09-28 19:50:09 michelpujol Exp $
#

namespace eval eventAude_GPS {
   variable This
   global eventAude_GPS

   #
   # eventAude_GPS::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # eventAude_GPS::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK'
   #
   proc ok { } {
      variable This

      ::eventAude_GPS::appliquer
      ::eventAude_GPS::recup_position
      destroy $This
   }

   #
   # eventAude_GPS::appliquer
   # Fonction appellee lors de l'appui sur le bouton 'Appliquer'
   #
   proc appliquer { } {
      ::eventAude_GPS::widgetToConf
   }

   #
   # eventAude_GPS::afficherAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficherAide { } {
      ::audace::showHelpPlugin link ethernaude "eventaude.htm"
   }

   #
   # eventAude_GPS::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      ::eventAude_GPS::recup_position
      destroy $This
   }

   #
   # eventAude_GPS::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre de configuration de l'alimentation
   #
   proc recup_position { } {
      variable This
      global conf
      global confCam

      set confCam(eventaude_gps,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $confCam(eventaude_gps,geometry) ] ]
      set fin [ string length $confCam(eventaude_gps,geometry) ]
      set confCam(eventaude_gps,position) "+[ string range $confCam(eventaude_gps,geometry) $deb $fin ]"
      #---
      set conf(eventaude_gps,position) $confCam(eventaude_gps,position)
   }

   proc createDialog { } {
      variable This
      global audace
      global caption
      global color
      global conf
      global confCam

      #--- initConf
      if { ! [ info exists conf(eventaude_gps,position) ] } { set conf(eventaude_gps,position) "+600+490" }

      #--- Initialisation de variables
      set confCam(coord_GPS_Observateur) ""
      set confCam(longi_GPS_Observateur) ""
      set confCam(lati_GPS_Observateur)  ""
      set confCam(alti_GPS_Observateur)  ""

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         ::eventAude_GPS::coord_GPS
         return
      }

      #---
      set confCam(eventaude_gps,position) $conf(eventaude_gps,position)
      #---
      if { [ info exists confCam(eventaude_gps,geometry) ] } {
         set deb [ expr 1 + [ string first + $confCam(eventaude_gps,geometry) ] ]
         set fin [ string length $confCam(eventaude_gps,geometry) ]
         set confCam(eventaude_gps,position) "+[ string range $confCam(eventaude_gps,geometry) $deb $fin ]"
      }

      #--- Chargement des captions
      uplevel #0 "source \"[ file join $audace(rep_plugin) link ethernaude eventaude_gps.cap ]\""

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm title $This $caption(eventaude_gps,titre)
      wm geometry $This $confCam(eventaude_gps,position)
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW ::eventAude_GPS::fermer

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame1 -side top -fill both -expand 1

      #--- Rafraichissement des coordonnes GPS
      button $This.rafraichir -text "$caption(eventaude_gps,rafraichir)" -command { ::eventAude_GPS::coord_GPS }
      pack $This.rafraichir -in $This.frame3 -side top -padx 3 -pady 3 -ipadx 5 -ipady 5

      #--- Coordonnees du lieu au format GPS
      label $This.lab1 -text "$caption(eventaude_gps,position_gps)"
      pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 5 -pady 5
      label $This.lab2 -textvariable "confCam(coord_GPS_Observateur)"
      pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

      #--- Longitude
      label $This.lab3 -text "$caption(eventaude_gps,longitude)"
      pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5
      label $This.lab4 -textvariable "confCam(longi_GPS_Observateur)"
      pack $This.lab4 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

      #--- Latitude
      label $This.lab5 -text "$caption(eventaude_gps,latitude)"
      pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 5 -pady 5
      label $This.lab6 -textvariable "confCam(lati_GPS_Observateur)"
      pack $This.lab6 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

      #--- Altitude
      label $This.lab7 -text "$caption(eventaude_gps,altitude)"
      pack $This.lab7 -in $This.frame6 -anchor center -side left -padx 5 -pady 5
      label $This.lab8 -textvariable "confCam(alti_GPS_Observateur)"
      pack $This.lab8 -in $This.frame6 -anchor center -side left -padx 5 -pady 5

      #--- Mise a jour de la longitude et de la latitude
      button $This.maj_long_lat -text "$caption(eventaude_gps,maj_long+lat)" \
         -command { ::eventAude_GPS::confirm_save_long_lat }
      pack $This.maj_long_lat -in $This.frame7 -side top -padx 3 -pady 3 -ipadx 5 -ipady 5

      #--- Mise a jour de l'altitude
      button $This.maj_alt -text "$caption(eventaude_gps,maj_alt)" \
         -command { ::eventAude_GPS::confirm_save_alt }
      pack $This.maj_alt -in $This.frame7 -side top -padx 3 -pady 3 -ipadx 5 -ipady 5

      #--- Recuperation des coordonnees GPS par l'EventAude
      ::eventAude_GPS::coord_GPS

      #--- Site web officiel de l'EventAude
      label $This.lab103 -text "$caption(eventaude_gps,site_web_ref)"
      pack $This.lab103 -in $This.frame8 -side top -fill x -pady 2

      label $This.labURL -text "$caption(eventaude_gps,site_eventaude)" -font $audace(font,url) -fg $color(blue)
      pack $This.labURL -in $This.frame8 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $This.labURL <ButtonPress-1> {
         set filename "$caption(eventaude_gps,site_eventaude)"
         ::audace::Lance_Site_htm $filename
      }
      bind $This.labURL <Enter> {
         $::eventAude_GPS::This.labURL configure -fg $color(purple)
      }
      bind $This.labURL <Leave> {
         $::eventAude_GPS::This.labURL configure -fg $color(blue)
      }

      #--- Cree le bouton 'OK'
      button $This.frame2.ok -text "$caption(eventaude_gps,ok)" -width 7 -command { ::eventAude_GPS::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.frame2.ok -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      #--- Cree le bouton 'Appliquer'
      button $This.frame2.appliquer -text "$caption(eventaude_gps,appliquer)" -width 8 -command { ::eventAude_GPS::appliquer }
      pack $This.frame2.appliquer -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x

      #--- Cree le bouton 'Fermer'
      button $This.frame2.fermer -text "$caption(eventaude_gps,fermer)" -width 7 -command { ::eventAude_GPS::fermer }
      pack $This.frame2.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      #--- Cree le bouton 'Aide'
      button $This.frame2.aide -text "$caption(eventaude_gps,aide)" -width 7 -command { ::eventAude_GPS::afficherAide }
      pack $This.frame2.aide -in $This.frame2 -side right -padx 3 -pady 3 -ipady 5 -fill x

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # eventAude_GPS::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des
   # differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confCam

      #--- Memorise
   }

   #
   # eventAude_GPS::coord_GPS
   # Permet d'obtenir les coordonnees GPS de l'observateur
   #
   proc coord_GPS { } {
      global caption
      global confCam

      #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
      set camNo $confCam($confCam(cam_item),camNo)
      set statusVariableName "::status_cam$camNo"
      if { [set $statusVariableName] != "exp" } {
         set confCam(coord_GPS_Observateur) [ cam$camNo gps ]
         set confCam(long_GPS_Observateur) [ mc_angle2dms [ lindex $confCam(coord_GPS_Observateur) 1 ] 180 ]
         set longi_est_ouest [ lindex $confCam(coord_GPS_Observateur) 2 ]
         if { $longi_est_ouest == "W" } {
            set longi_est_ouest "$caption(eventaude_gps,ouest)"
         } elseif { $longi_est_ouest == "E" } {
            set longi_est_ouest "$caption(eventaude_gps,est)"
         }
         set confCam(longi_GPS_Observateur) "$longi_est_ouest [ format "%2d� %2d' %4.2f''" [ lindex $confCam(long_GPS_Observateur) 0 ] [ lindex $confCam(long_GPS_Observateur) 1 ] [ lindex $confCam(long_GPS_Observateur) 2 ] ]"
         set confCam(lat_GPS_Observateur) [ mc_angle2dms [ lindex $confCam(coord_GPS_Observateur) 3 ] 90 ]
         set confCam(lati_GPS_Observateur) [ format "%2d� %2d' %4.2f''" [ lindex $confCam(lat_GPS_Observateur) 0 ] [ lindex $confCam(lat_GPS_Observateur) 1 ] [ lindex $confCam(lat_GPS_Observateur) 2 ] ]
         set confCam(alt_GPS_Observateur) [ lindex $confCam(coord_GPS_Observateur) 4 ]
         set confCam(alti_GPS_Observateur) [ format "%5.0f m" $confCam(alt_GPS_Observateur) ]
      }
   }

   #
   # eventAude_GPS::confirm_save_long_lat
   # Confirme la sauvegarde des coordonnees GPS en longitude et en latitude
   #
   proc confirm_save_long_lat { } {
      global audace
      global caption
      global confCam
      global confgene

      set choix [ tk_messageBox -type yesno -icon warning -title "$caption(eventaude_gps,maj_long+lat-)" \
         -message "$caption(eventaude_gps,confirm)" ]
      if { $choix == "yes" } {
         #--- Mise en forme et sauvegarde de la longitude
         set confgene(posobs,long) [lindex $confCam(coord_GPS_Observateur) 1]
         set confgene(posobs,long) [mc_angle2dms $confgene(posobs,long) 180 nozero 1 auto string]
         set confgene(posobs,estouest) [lindex $confCam(coord_GPS_Observateur) 2]
         if { $confgene(posobs,estouest) == "W" } {
            set confgene(posobs,estouest) "$caption(eventaude_gps,ouest)"
         } elseif { $confgene(posobs,estouest) == "E" } {
            set confgene(posobs,estouest) $caption(eventaude_gps,est)
         }

         #--- Mise en forme et sauvegarde de la latitude
         set confgene(posobs,lat) [lindex $confCam(coord_GPS_Observateur) 3]
         if { $confgene(posobs,lat) < 0 } {
            set confgene(posobs,nordsud) "$caption(eventaude_gps,sud)"
            set confgene(posobs,lat)     "[expr abs($confgene(posobs,lat))]"
         } else {
            set confgene(posobs,nordsud) "$caption(eventaude_gps,nord)"
            set confgene(posobs,lat)     "$confgene(posobs,lat)"
         }
         set confgene(posobs,lat) [mc_angle2dms $confgene(posobs,lat) 90 nozero 1 auto string]

         #--- Mise a jour de champs de la boite Position de l'observateur
         set confgene(posobs,ref_geodesique)         "WGS84"
         set confgene(posobs,station_uai)            ""
         set confgene(posobs,observateur,mpc)        ""
         $audace(base).confPosObs.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $audace(color,textColor)
         set confgene(posobs,observateur,mpcstation) ""
         $audace(base).confPosObs.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $audace(color,textColor)
         ::confPosObs::Position
      }
   }

   #
   # eventAude_GPS::confirm_save_alt
   # Confirme la sauvegarde des coordonnees GPS en altitude
   #
   proc confirm_save_alt { } {
      global audace
      global caption
      global confCam
      global confgene

      set choix [ tk_messageBox -type yesno -icon warning -title "$caption(eventaude_gps,maj_alt-)" \
         -message "$caption(eventaude_gps,confirm)" ]
      if { $choix == "yes" } {
         #--- Mise en forme et sauvegarde de l'altitude
         set confgene(posobs,altitude)               [ string trimleft [ format "%5.0f" $confCam(alt_GPS_Observateur) ] " " ]

         #--- Mise a jour de champs de la boite Position de l'observateur
         set confgene(posobs,ref_geodesique)         "WGS84"
         set confgene(posobs,station_uai)            ""
         set confgene(posobs,observateur,mpc)        ""
         $audace(base).confPosObs.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $audace(color,textColor)
         set confgene(posobs,observateur,mpcstation) ""
         $audace(base).confPosObs.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $audace(color,textColor)
         ::confPosObs::Position
      }
   }

}

