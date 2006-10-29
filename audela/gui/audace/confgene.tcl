#
# Fichier : confgene.tcl
# Description : Configuration generale d'AudeLA et d'Aud'ACE (general, editeurs, repertoires, position
#               de l'observateur, temps (heure systeme ou TU), fichiers image, alarme sonore de fin de 
#               pose, drift-scan et scan rapide, choix des panneaux, messages dans la Console, type de
#               fenetre, la fenetre A propos de ... et une fenetre de configuration generique)
# Auteur : Robert DELMAS
# Mise a jour $Id: confgene.tcl,v 1.12 2006-10-29 14:30:28 michelpujol Exp $
#

#
# PosObs
# Description : Position de l'observateur sur la Terre
#

namespace eval confPosObs {
   variable This
   global confgene

   #
   # confPosObs::run this
   # Cree la fenetre definissant la position de l'observateur
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confPosObs::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la position de l'observateur
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confPosObs::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      ::confPosObs::Position
      widgetToConf
   }

   #
   # confPosObs::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1050position.htm"
   }

   #
   # confPosObs::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      global conf
      global confgene

      set confgene(posobs,altitude)                $conf(posobs,altitude)
      set confgene(posobs,estouest)                $conf(posobs,estouest)
      set confgene(posobs,fichier_station_uai)     $conf(posobs,fichier_station_uai)
      set confgene(posobs,lat)                     $conf(posobs,lat)
      set confgene(posobs,long)                    $conf(posobs,long)
      set confgene(posobs,nordsud)                 $conf(posobs,nordsud)
      set confgene(posobs,observateur,gps)         $conf(posobs,observateur,gps)
      set confgene(posobs,observateur,mpc)         $conf(posobs,observateur,mpc)
      set confgene(posobs,observateur,mpcstation)  $conf(posobs,observateur,mpcstation)
      set confgene(posobs,ref_geodesique)          $conf(posobs,ref_geodesique)
      set confgene(posobs,station_uai)             $conf(posobs,station_uai)

      variable This
      destroy $This
   }

   #
   # confPosObs::initConf
   # Initialisation des variables de position pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(posobs,observateur,gps) ] } { set conf(posobs,observateur,gps) "GPS 1.376722 E 43.659778 142" }
      if { ! [ info exists conf(posobs,altitude) ] }        { set conf(posobs,altitude)        "142" }
      if { ! [ info exists conf(posobs,estouest) ] }        { set conf(posobs,estouest)        "E" }
      if { ! [ info exists conf(posobs,long) ] }            { set conf(posobs,long)            "1d22m36.2s" }
      if { ! [ info exists conf(posobs,lat) ] }             { set conf(posobs,lat)             "43d39m35.2s" }
      if { ! [ info exists conf(posobs,nordsud) ] }         { set conf(posobs,nordsud)         "N" }
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global color
      global confgene

      #--- initConf
      #--- Initialisation indispensable de 1 variable dans aud.tcl (::audace::Recup_Config)
      if { ! [ info exists conf(posobs,fichier_station_uai) ] }    { set conf(posobs,fichier_station_uai)    "obscodes.txt" }
      if { ! [ info exists conf(posobs,observateur,mpc) ] }        { set conf(posobs,observateur,mpc)        "" }
      if { ! [ info exists conf(posobs,observateur,mpcstation) ] } { set conf(posobs,observateur,mpcstation) "" }
      if { ! [ info exists conf(posobs,ref_geodesique) ] }         { set conf(posobs,ref_geodesique)         "WGS84" }
      if { ! [ info exists conf(posobs,station_uai) ] }            { set conf(posobs,station_uai)            "" }

      #--- confToWidget
      set confgene(posobs,altitude)                $conf(posobs,altitude)
      set confgene(posobs,estouest)                $conf(posobs,estouest)
      set confgene(posobs,fichier_station_uai)     $conf(posobs,fichier_station_uai)
      set confgene(posobs,lat)                     $conf(posobs,lat)
      set confgene(posobs,long)                    $conf(posobs,long)
      set confgene(posobs,nordsud)                 $conf(posobs,nordsud)
      set confgene(posobs,observateur,gps)         $conf(posobs,observateur,gps)
      set confgene(posobs,observateur,mpc)         $conf(posobs,observateur,mpc)
      set confgene(posobs,observateur,mpcstation)  $conf(posobs,observateur,mpcstation)
      set confgene(posobs,ref_geodesique)          $conf(posobs,ref_geodesique)
      set confgene(posobs,station_uai)             $conf(posobs,station_uai)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,position)
      wm protocol $This WM_DELETE_WINDOW ::confPosObs::fermer

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
      pack $This.frame6 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame5 -side left -fill both -expand 1

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in $This.frame5 -side left -fill both -expand 1

      frame $This.frame10 -borderwidth 0 -relief raised
      pack $This.frame10 -in $This.frame6 -side top -fill both -expand 1

      frame $This.frame11 -borderwidth 0 -relief raised
      pack $This.frame11 -in $This.frame6 -side top -fill both -expand 1

      frame $This.frame12 -borderwidth 0 -relief raised
      pack $This.frame12 -in $This.frame10 -side left -fill both -expand 1

      frame $This.frame13 -borderwidth 0 -relief raised
      pack $This.frame13 -in $This.frame10 -side left -fill both -expand 1

      frame $This.frame14 -borderwidth 0 -relief raised
      pack $This.frame14 -in $This.frame7 -side top -fill both -expand 1

      frame $This.frame15 -borderwidth 0 -relief raised
      pack $This.frame15 -in $This.frame7 -side top -fill both -expand 1

      frame $This.frame16 -borderwidth 0 -relief raised
      pack $This.frame16 -in $This.frame7 -side top -fill both -expand 1

      frame $This.frame17 -borderwidth 0 -relief raised
      pack $This.frame17 -in $This.frame9 -side top -fill both -expand 1

      frame $This.frame18 -borderwidth 0 -relief raised
      pack $This.frame18 -in $This.frame9 -side top -fill both -expand 1

      frame $This.frame19 -borderwidth 0 -relief raised
      pack $This.frame19 -in $This.frame9 -side top -fill both -expand 1

      frame $This.frame20 -borderwidth 0 -relief raised
      pack $This.frame20 -in $This.frame9 -side top -fill both -expand 1

      #--- Longitude observateur
      label $This.lab1 -text "$caption(confgene,position_longitude)"
      pack $This.lab1 -in $This.frame12 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,position_est) $caption(confgene,position_ouest) ]
      ComboBox $This.estouest \
         -width 2          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,estouest) \
         -values $list_combobox
      pack $This.estouest -in $This.frame13 -anchor e -side top -padx 10 -pady 5

      entry $This.long -textvariable confgene(posobs,long) -width 16
      pack $This.long -in $This.frame14 -anchor w -side top -padx 10 -pady 5

      #--- Latitude observateur
      label $This.lab2 -text "$caption(confgene,position_latitude)"
      pack $This.lab2 -in $This.frame12 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,position_nord) $caption(confgene,position_sud) ]
      ComboBox $This.nordsud \
         -width 2          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,nordsud) \
         -values $list_combobox
      pack $This.nordsud -in $This.frame13 -anchor e -side top -padx 10 -pady 5

      entry $This.lat -textvariable confgene(posobs,lat) -width 16
      pack $This.lat -in $This.frame14 -anchor w -side top -padx 10 -pady 5

      #--- Altitude observateur
      label $This.lab3 -text "$caption(confgene,position_altitude)"
      pack $This.lab3 -in $This.frame11 -anchor w -side top -padx 10 -pady 5

      entry $This.altitude -textvariable confgene(posobs,altitude) -width 6
      pack $This.altitude -in $This.frame15 -anchor w -side left -padx 10 -pady 5

      label $This.lab4 -text "$caption(confgene,position_metre)"
      pack $This.lab4 -in $This.frame15 -anchor w -side left -pady 5

      #--- Referentiel geodesique
      label $This.lab5 -text "$caption(confgene,position_ref_geodesique)"
      pack $This.lab5 -in $This.frame11 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,position_ref_geodesique_ed50) \
         $caption(confgene,position_ref_geodesique,wgs84) ]
      ComboBox $This.ref_geodesique \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,ref_geodesique) \
         -values $list_combobox
      pack $This.ref_geodesique -in $This.frame16 -anchor w -side top -padx 10 -pady 5

      #--- Cree le bouton 'Mise à jour du format GPS'
      button $This.but_gps -text "$caption(confgene,position_miseajour_gps)" -borderwidth 2 \
         -command { ::confPosObs::Position }
      pack $This.but_gps -in $This.frame4 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

      #--- Systeme de coordonnees au format GPS
      label $This.lab6 -text "$caption(confgene,position_gps)"
      pack $This.lab6 -in $This.frame8 -anchor w -side top -padx 10 -pady 5

      label $This.lab7 -text "$conf(posobs,observateur,gps)"
      pack $This.lab7 -in $This.frame17 -anchor w -side top -padx 10 -pady 5

      #--- Numero station UAI
      label $This.lab8 -text "$caption(confgene,position_station_uai)"
      pack $This.lab8 -in $This.frame8 -anchor w -side top -padx 10 -pady 10

      entry $This.station_uai -textvariable confgene(posobs,station_uai) -width 6
      pack $This.station_uai -in $This.frame18 -anchor w -side left -padx 10 -pady 5

      #--- Cree le bouton 'Mise à jour des formats MPC'
      button $This.but_mpc -text "$caption(confgene,position_miseajour_mpc)" -borderwidth 2 \
         -command { ::confPosObs::MPC }
      pack $This.but_mpc -in $This.frame18 -anchor center -side left -padx 10 -pady 3 -ipadx 10 -ipady 5 -expand true

      #--- Fichier des stations UAI
      label $This.lab9 -text "$caption(confgene,position_fichier_station_uai)"
      pack $This.lab9 -in $This.frame8 -anchor w -side top -padx 10 -pady 10

      entry $This.fichier_station_uai -textvariable confgene(posobs,fichier_station_uai) -width 16
      pack $This.fichier_station_uai -in $This.frame19 -anchor w -side left -padx 10 -pady 5

      #--- Cree le bouton 'Mise à jour' du fichier des stations UAI
      button $This.but_maj -text "$caption(confgene,position_miseajour)" -borderwidth 2 \
         -command { ::confPosObs::MaJ }
      pack $This.but_maj -in $This.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 10 -ipady 5 -expand true

      #--- Systeme de coordonnees au format MPC
      label $This.lab10 -text "$caption(confgene,position_mpc)"
      pack $This.lab10 -in $This.frame8 -anchor w -side top -padx 10 -pady 5

      label $This.labURLRed11 -borderwidth 1 -width 30 -anchor w -fg $audace(color,textColor)
      pack $This.labURLRed11 -in $This.frame20 -anchor w -side top -padx 10 -pady 5

      #--- Systeme de coordonnees au format MPCSTATION
      label $This.lab12 -text "$caption(confgene,position_mpcstation)"
      pack $This.lab12 -in $This.frame8 -anchor w -side top -padx 10 -pady 5

      label $This.labURLRed13 -borderwidth 1 -width 30 -anchor w -fg $audace(color,textColor)
      pack $This.labURLRed13 -in $This.frame20 -anchor w -side top -padx 10 -pady 5

      #--- Gestion des couleurs d'affichage des formats MPC et MPCSTATION
      if { ( $confgene(posobs,observateur,mpc) == "$caption(confgene,position_non_station_uai)" ) && ( $confgene(posobs,observateur,mpcstation) == "$caption(confgene,position_non_station_uai)" ) } {
         set fg $color(red)
      } else {
         set fg $audace(color,textColor)
      }

      #--- On utilise les valeurs contenues dans le tableau confgene pour l'initialisation
      $This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $fg
      $This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $fg

      #--- Cree le bouton 'OK' 
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confPosObs::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5 
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confPosObs::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confPosObs::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confPosObs::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc MaJ { } {
      global audace
      global color
      global caption
      global confgene

      if [winfo exists $audace(base).maj] {
         destroy $audace(base).maj
      }
      toplevel $audace(base).maj
      wm transient $audace(base).maj $audace(base).confPosObs
      wm title $audace(base).maj "$caption(confgene,position_miseajour)"
      set posx_maj [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 1 ]
      set posy_maj [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 2 ]
      wm geometry $audace(base).maj +[ expr $posx_maj + 10 ]+[ expr $posy_maj + 100 ]
      wm resizable $audace(base).maj 0 0

      #--- Cree l'affichage du message
      label $audace(base).maj.lab1 -text "$caption(confgene,fichier_uai_maj1) '$confgene(posobs,fichier_station_uai)'"
      uplevel #0 { pack $audace(base).maj.lab1 -padx 10 -pady 2 }
      label $audace(base).maj.lab2 -text "$caption(confgene,fichier_uai_maj2)"
      uplevel #0 { pack $audace(base).maj.lab2 -padx 10 -pady 2 }
      label $audace(base).maj.lab3 -text "$caption(confgene,fichier_uai_maj3)"
      uplevel #0 { pack $audace(base).maj.lab3 -padx 10 -pady 2 }
      label $audace(base).maj.labURL4 -text "$caption(confgene,fichier_uai_maj4)" -font $audace(font,url) \
         -fg $color(blue)
      uplevel #0 { pack $audace(base).maj.labURL4 -padx 10 -pady 2 }
      label $audace(base).maj.lab5 -text "$caption(confgene,fichier_uai_maj5) $confgene(posobs,fichier_station_uai)"
      uplevel #0 { pack $audace(base).maj.lab5 -padx 10 -pady 2 }

      #--- La nouvelle fenetre est active
      focus $audace(base).maj

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).maj

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $audace(base).maj.labURL4 <ButtonPress-1> {
         set filename "$caption(confgene,fichier_uai_maj4)"
         ::audace::Lance_Site_htm $filename
      }
      bind $audace(base).maj.labURL4 <Enter> {
         $audace(base).maj.labURL4 configure -fg $color(purple)
      } 
      bind $audace(base).maj.labURL4 <Leave> {
         $audace(base).maj.labURL4 configure -fg $color(blue)
      } 
   }

   proc Erreur { } {
      global audace
      global caption

      if [winfo exists $audace(base).erreur] {
         destroy $audace(base).erreur
      }
      toplevel $audace(base).erreur
      wm transient $audace(base).erreur $audace(base).confPosObs
      wm title $audace(base).erreur "$caption(confgene,position_miseajour_mpc)"
      set posx_erreur [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 1 ]
      set posy_erreur [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 2 ]
      wm geometry $audace(base).erreur +[expr $posx_erreur - 20 ]+[expr $posy_erreur + 120 ]
      wm resizable $audace(base).erreur 0 0

      #--- Cree l'affichage du message
      label $audace(base).erreur.lab1 -text "$caption(confgene,fichier_uai_erreur1)"
      uplevel #0 { pack $audace(base).erreur.lab1 -padx 10 -pady 2 }
      label $audace(base).erreur.lab2 -text "$caption(confgene,fichier_uai_erreur2)"
      uplevel #0 { pack $audace(base).erreur.lab2 -padx 10 -pady 2 }
      label $audace(base).erreur.lab3 -text "$caption(confgene,fichier_uai_erreur3)"
      uplevel #0 { pack $audace(base).erreur.lab3 -padx 10 -pady 2 }

      #--- La nouvelle fenetre est active
      focus $audace(base).erreur

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).erreur
   }

   #
   # Position
   # Fonction pour la mise a la forme GPS
   #
   proc Position { } {
      variable This
      global conf
      global caption
      global confgene

      #--- Localisation de l'observateur
      set estouest $confgene(posobs,estouest)
      if { $estouest == $caption(confgene,position_ouest) } {
         set estouest $caption(confgene,caractere_W)
      } elseif { $estouest == $caption(confgene,position_est) } {
         set estouest $caption(confgene,caractere_E)
      }
      set longitude "$confgene(posobs,long)"
      if { $confgene(posobs,nordsud) == $caption(confgene,position_sud) } {
         set signe $caption(confgene,caractere_tiret)
      } else {
         set signe ""
      }
      set latitude "$signe$confgene(posobs,lat)"
      #--- Si un format MPC existe je peux modifier l'altitude du format GPS sans modifier la longitude et la latitude
      if { $confgene(posobs,observateur,mpc) != "" } {
         if { $confgene(posobs,ref_geodesique) == "WGS84" } {
            set altitude $confgene(posobs,altitude)
            ::confPosObs::MPC
            set confgene(posobs,observateur,gps) "GPS [lindex $confgene(posobs,observateur,gps) 1] [lindex $confgene(posobs,observateur,gps) 2] [lindex $confgene(posobs,observateur,gps) 3] $altitude"
            set confgene(posobs,altitude) $altitude
         } elseif { $confgene(posobs,ref_geodesique) == "ED50" } {
            set confgene(posobs,observateur,gps-ed50) "GPS [mc_angle2deg $longitude] $estouest [mc_angle2deg $latitude] $confgene(posobs,altitude)"
            set confgene(posobs,observateur,ed50-wgs84) [mc_home2geosys $confgene(posobs,observateur,gps-ed50) ED50 WGS84]
            set longitude_ed50 [lindex $confgene(posobs,observateur,ed50-wgs84) 0]
            set confgene(posobs,observateur,gps) "GPS [expr abs($longitude_ed50)] [lindex $confgene(posobs,observateur,gps-ed50) 2] [lindex $confgene(posobs,observateur,ed50-wgs84) 1] [lindex $confgene(posobs,observateur,ed50-wgs84) 2]"
         }
      } else {
         if { $confgene(posobs,ref_geodesique) == "WGS84" } {
            set confgene(posobs,observateur,gps) "GPS [mc_angle2deg $longitude] $estouest [mc_angle2deg $latitude] $confgene(posobs,altitude)"
         } elseif { $confgene(posobs,ref_geodesique) == "ED50" } {
            set confgene(posobs,observateur,gps-ed50) "GPS [mc_angle2deg $longitude] $estouest [mc_angle2deg $latitude] $confgene(posobs,altitude)"
            set confgene(posobs,observateur,ed50-wgs84) [mc_home2geosys $confgene(posobs,observateur,gps-ed50) ED50 WGS84]
            set longitude_ed50 [lindex $confgene(posobs,observateur,ed50-wgs84) 0]
            set confgene(posobs,observateur,gps) "GPS [expr abs($longitude_ed50)] [lindex $confgene(posobs,observateur,gps-ed50) 2] [lindex $confgene(posobs,observateur,ed50-wgs84) 1] [lindex $confgene(posobs,observateur,ed50-wgs84) 2]"
         }
      }
      #--- Mise en forme et affichage de la position au format GPS
      set confgene(posobs,observateur,gps) "[lindex $confgene(posobs,observateur,gps) 0]\
         [lindex $confgene(posobs,observateur,gps) 1] [lindex $confgene(posobs,observateur,gps) 2]\
         [lindex $confgene(posobs,observateur,gps) 3] [lindex $confgene(posobs,observateur,gps) 4]"
      $This.lab7 configure -text "$confgene(posobs,observateur,gps)"
   }

   #
   # MPC
   # Fonction pour la mise a la forme MPC et MPCSTATION
   #
   proc MPC { } {
      variable This
      global audace
      global conf
      global caption
      global confgene
      global color

      #--- Effacement de la fenetre d'alerte
      bind $This.station_uai <Enter> { destroy $audace(base).erreur }

      #--- Traitement sur le numero de la station uai
      if { $confgene(posobs,station_uai) == "" } {
         set confgene(posobs,observateur,mpc) ""
         $This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $color(red)
         set confgene(posobs,observateur,mpcstation) ""
         $This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $color(red)
      } else {
         if {[string length $confgene(posobs,station_uai)]<"3"} {
            ::confPosObs::Erreur
         } else {
         #--- Ouverture du fichier des stations UAI
         set f [open [file join $audace(rep_audela) audace etc $confgene(posobs,fichier_station_uai)] r]
         #--- Creation d'une liste des stations UAI
         set mpc [split [read $f] "\n"]
         #--- Determine le nombre d'elements de la liste
         set long [llength $mpc]
         #--- Recherche le numero de la premiere ligne significative --> le site uai '000'
         for {set j 0} {$j <= $long} {incr j} {
            set ligne_station_mpc [lindex $mpc $j]
            if { [string compare [lindex $ligne_station_mpc 0] "000"] == "0" } {
               break
            }
         }
         #--- Supprime les (j-1) lignes de commentaires non significatifs
         set mpc [lreplace $mpc 0 [expr $j-1]]
         #--- Recherche et traitement du site uai demande
         for {set i 0} {$i <= $long} {incr i} {
            set ligne_station_mpc [lindex $mpc $i]
            if { [string compare [lindex $ligne_station_mpc 0] $confgene(posobs,station_uai)] == "0" } {
               #--- Formatage MPC
               set confgene(posobs,observateur,mpc) "MPC [lindex $ligne_station_mpc 1] [lindex $ligne_station_mpc 2] [lindex $ligne_station_mpc 3]"
               $This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $audace(color,textColor)
               #--- Formatage MPCSTATION
               set confgene(posobs,observateur,mpcstation) "MPCSTATION $confgene(posobs,station_uai) $confgene(posobs,fichier_station_uai)"
               $This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $audace(color,textColor)
               #--- Formatage GPS et mise a jour du 'frame' GPS
               #--- Longitude avec mise en forme
               set confgene(posobs,observateur,gps) [mc_home2gps $confgene(posobs,observateur,mpc)]
               set confgene(posobs,observateur,gps) "[lindex $confgene(posobs,observateur,gps) 0]\
                  [lindex $confgene(posobs,observateur,gps) 1] [lindex $confgene(posobs,observateur,gps) 2]\
                  [lindex $confgene(posobs,observateur,gps) 3] [lindex $confgene(posobs,observateur,gps) 4]"
               $This.lab7 configure -text "$confgene(posobs,observateur,gps)"
               set confgene(posobs,long) [lindex $confgene(posobs,observateur,gps) 1]
               set confgene(posobs,long) [mc_angle2dms $confgene(posobs,long) 180 nozero 1 auto string]
               set confgene(posobs,estouest) [lindex $confgene(posobs,observateur,gps) 2]
               if { $confgene(posobs,estouest) == "W" } {
                  set confgene(posobs,estouest) "$caption(confgene,position_ouest)"
               } elseif { $confgene(posobs,estouest) == "E" } {
                  set confgene(posobs,estouest) $caption(confgene,position_est)
               }
               #--- Latitude
               set confgene(posobs,lat) [lindex $confgene(posobs,observateur,gps) 3]
               if { $confgene(posobs,lat) < 0 } {
                  set confgene(posobs,nordsud) "$caption(confgene,position_sud)"
                  set confgene(posobs,lat)     "[expr abs($confgene(posobs,lat))]"
               } else {
                  set confgene(posobs,nordsud) "$caption(confgene,position_nord)"
                  set confgene(posobs,lat)     "$confgene(posobs,lat)"
               }
               set confgene(posobs,lat) [mc_angle2dms $confgene(posobs,lat) 90 nozero 1 auto string]
               #--- Altitude
               set confgene(posobs,altitude) [lindex $confgene(posobs,observateur,gps) 4]
               #--- Referentiel geodesique pour le calcul du format GPS
               set confgene(posobs,ref_geodesique) "WGS84"
               break
            } else {
               set confgene(posobs,observateur,mpc) "$caption(confgene,position_non_station_uai)"
               $This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $color(red)
               set confgene(posobs,observateur,mpcstation) "$caption(confgene,position_non_station_uai)"
               $This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $color(red)
            }
         }
         #--- Ferme le fichier des stations UAI
         close $f
         }
      }
   }

   #
   # confPosObs::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global confgene
      global conf

      set conf(posobs,altitude)               $confgene(posobs,altitude)
      set conf(posobs,estouest)               $confgene(posobs,estouest)
      set conf(posobs,fichier_station_uai)    $confgene(posobs,fichier_station_uai)
      set conf(posobs,lat)                    $confgene(posobs,lat)
      set conf(posobs,long)                   $confgene(posobs,long)
      set conf(posobs,nordsud)                $confgene(posobs,nordsud)
      set conf(posobs,observateur,gps)        $confgene(posobs,observateur,gps)
      set conf(posobs,observateur,mpc)        $confgene(posobs,observateur,mpc)
      set conf(posobs,observateur,mpcstation) $confgene(posobs,observateur,mpcstation)
      set conf(posobs,ref_geodesique)         $confgene(posobs,ref_geodesique)
      set conf(posobs,station_uai)                  $confgene(posobs,station_uai)
   }
}

#
# Temps
# Description : Configuration du temps (heure systeme ou TU)
#

namespace eval confTemps {
   variable This
   global confgene

   #
   # confTemps::run this
   # Cree la fenetre de configuration du temps
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      Temps_TU_TSL
      tkwait visibility $This
   }

   #
   # confTemps::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration,
   # et fermer la fenetre de configuration du temps
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confTemps::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confTemps::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1040temps.htm"
   }

   #
   # confTemps::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This
      global caption
      global conf
      global confgene

      set confgene(temps,fushoraire) $conf(temps,fushoraire)
      set confgene(temps,hhiverete)  [ lindex "$caption(confgene,temps_aucune) $caption(confgene,temps_hiver) $caption(confgene,temps_ete)" "$conf(temps,hhiverete)" ]
      set confgene(temps,hsysteme)   [ lindex "$caption(confgene,temps_heurelegale) $caption(confgene,temps_universel)" "$conf(temps,hsysteme)" ]

      set confgene(espion) "1"

      destroy $This
   }

   #
   # confTemps::initConf
   # Initialisation des variables de temps pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(temps,fushoraire) ] } { set conf(temps,fushoraire) "1" }
      if { ! [ info exists conf(temps,hhiverete) ] }  { set conf(temps,hhiverete)  "2" }
      if { ! [ info exists conf(temps,hsysteme) ] }   { set conf(temps,hsysteme)   "0" }
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confgene

      #--- initConf
      #--- Initialisation indispensable de toutes les variables du temps dans aud.tcl (::audace::Recup_Config)

      #--- confToWidget
      set confgene(temps,fushoraire) $conf(temps,fushoraire)
      set confgene(temps,hhiverete)  [ lindex "$caption(confgene,temps_aucune) $caption(confgene,temps_hiver) $caption(confgene,temps_ete)" "$conf(temps,hhiverete)" ]
      set confgene(temps,hsysteme)   [ lindex "$caption(confgene,temps_heurelegale) $caption(confgene,temps_universel)" "$conf(temps,hsysteme)" ]

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,temps)
      wm protocol $This WM_DELETE_WINDOW ::confTemps::fermer

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
      pack $This.frame5 -in $This.frame4 -side left -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in $This.frame4 -side left -fill both -expand 1

      #--- Legendes
      label $This.lab1 -text "$caption(confgene,temps_heure_legale1) $caption(confgene,caractere_2points)\
         $caption(confgene,temps_heure_legale2)"
      pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 10 -pady 5

      label $This.lab2 -text "$caption(confgene,temps_universel1) $caption(confgene,caractere_2points)\
         $caption(confgene,temps_universel2)"
      pack $This.lab2 -in $This.frame3 -anchor center -side right -padx 10 -pady 5

      #--- Heure systeme = tu ou heure legale
      label $This.lab3 -text "$caption(confgene,temps_hsysteme)"
      pack $This.lab3 -in $This.frame5 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,temps_heurelegale) $caption(confgene,temps_universel) ]
      ComboBox $This.hsysteme \
         -width 3         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -modifycmd { ::confTemps::Temps_TU_TSL } \
         -textvariable confgene(temps,hsysteme) \
         -values $list_combobox
      pack $This.hsysteme -in $This.frame6 -anchor w -side top -padx 10 -pady 5

      #--- Fuseau horaire
      label $This.lab4 -text "$caption(confgene,temps_fushoraire1)"
      pack $This.lab4 -in $This.frame5 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list -12 -11 -10 -9 -8 -7 -6 -5 -4 -3:30 -3 -2 -1 0 1 2 3 3:30\
         4 4:30 5 5:30 6 7 8 9 9:30 10 11 12 ]
      ComboBox $This.fushoraire \
         -width 6          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -modifycmd { ::confTemps::Temps_TU_TSL } \
         -textvariable confgene(temps,fushoraire) \
         -values $list_combobox
      pack $This.fushoraire -in $This.frame6 -anchor w -side top -padx 10 -pady 5

      #--- Heure d'hiver / heure d'ete
      label $This.lab5 -text "$caption(confgene,temps_hhiverete)"
      pack $This.lab5 -in $This.frame5 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,temps_aucune) $caption(confgene,temps_hiver) \
         $caption(confgene,temps_ete) ]
      ComboBox $This.hhiverete \
         -width 8         \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -modifycmd { ::confTemps::Temps_TU_TSL } \
         -textvariable confgene(temps,hhiverete) \
         -values $list_combobox
      pack $This.hhiverete -in $This.frame6 -anchor w -side top -padx 10 -pady 5

      #--- Temps sideral local
      label $This.lab8 -text "$caption(confgene,temps_tsl)"
      pack $This.lab8 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab9 -borderwidth 1 -textvariable "audace(tsl,format,hmsint)" -width 12 -anchor w
      pack $This.lab9 -in $This.frame6 -anchor w -side bottom -padx 10 -pady 5

      #--- Temps universel
      label $This.lab6 -text "$caption(confgene,temps_tu)"
      pack $This.lab6 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab7 -borderwidth 1 -textvariable "audace(tu,format,hmsint)" -width 12 -anchor w
      pack $This.lab7 -in $This.frame6 -anchor w -side bottom -padx 10 -pady 5

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confTemps::ok } 
      if { $conf(ok+appliquer) == "1" } { 
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confTemps::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confTemps::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confTemps::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # Temps_TU_TSL
   # Fonction qui met a jour TU, TSL cette fonction se re-appelle au bout d'une seconde
   #
   proc Temps_TU_TSL { } {
      variable This
      global audace
      global conf
      global caption
      global confgene

      #--- Systeme d'heure utilise
      if { $confgene(temps,hsysteme) == "$caption(confgene,temps_heurelegale)" } {
         if { $confgene(espion) == "0" } {
            set confgene(espion) "1"
            #--- Fuseau horaire
            label $This.lab4 -text "$caption(confgene,temps_fushoraire1)"
            pack $This.lab4 -in $This.frame5 -anchor w -side top -padx 10 -pady 5
            set list_combobox [ list -12 -11 -10 -9 -8 -7 -6 -5 -4 -3:30 -3 -2 -1 0 1 2 3 3:30\
               4 4:30 5 5:30 6 7 8 9 9:30 10 11 12 ]
            ComboBox $This.fushoraire \
               -width 6          \
               -height [ llength $list_combobox ] \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -modifycmd { ::confTemps::Temps_TU_TSL } \
               -textvariable confgene(temps,fushoraire) \
               -values $list_combobox
            pack $This.fushoraire -in $This.frame6 -anchor w -side top -padx 10 -pady 5
            #--- Heure d'hiver / heure d'ete
            label $This.lab5 -text "$caption(confgene,temps_hhiverete)"
            pack $This.lab5 -in $This.frame5 -anchor w -side top -padx 10 -pady 5
            set list_combobox [ list $caption(confgene,temps_aucune) $caption(confgene,temps_hiver) \
               $caption(confgene,temps_ete) ]
            ComboBox $This.hhiverete \
               -width 8         \
               -height [ llength $list_combobox ]  \
               -relief sunken    \
               -borderwidth 1    \
               -editable 0       \
               -modifycmd { ::confTemps::Temps_TU_TSL } \
               -textvariable confgene(temps,hhiverete) \
               -values $list_combobox
            pack $This.hhiverete -in $This.frame6 -anchor w -side top -padx 10 -pady 5
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $This
         }
      } else {
         if { $confgene(espion) == "1" } {
            set confgene(espion) "0"
            destroy $This.lab4
            destroy $This.fushoraire
            destroy $This.lab5
            destroy $This.hhiverete
         }
      }
   }

   #
   # confTemps::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global caption
      global conf
      global confgene

      set conf(temps,fushoraire) $confgene(temps,fushoraire)
      set conf(temps,hhiverete)  [ lsearch "$caption(confgene,temps_aucune) $caption(confgene,temps_hiver) $caption(confgene,temps_ete)" "$confgene(temps,hhiverete)" ]
      set conf(temps,hsysteme)   [ lsearch "$caption(confgene,temps_heurelegale) $caption(confgene,temps_universel)" "$confgene(temps,hsysteme)" ]
   }
}

#
# FichierIma
# Description : Configuration des fichiers image
#

namespace eval confFichierIma {
   variable This
   global confgene

   #
   # confFichierIma::run this
   # Cree la fenetre de configuration des fichiers image
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confFichierIma::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration des fichiers image
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confFichierIma::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      variable This
      global conf
      global audace
      global confgene

      catch { 
         buf1000 extension "$confgene(extension,new)"
         buf1001 extension "$confgene(extension,new)"
         buf1002 extension "$confgene(extension,new)"
         buf1003 extension "$confgene(extension,new)"
      }
      buf$audace(bufNo) extension "$confgene(extension,new)"
      if { $confgene(fichier,compres) == "0" } {
         buf$audace(bufNo) compress "none"
      } else {
         buf$audace(bufNo) compress "gzip"
      }
      $This.labURL2 configure -text "$confgene(extension,new)"
      $This.labURL5 configure -text "$confgene(jpegquality,new)"
      widgetToConf
      #--- Mise a jour de l'extension pour toutes les visu disponibles
      foreach visuNo [::visu::list] {
         ::confFichierIma::MAJ_Extension
      }
      #--- Mise a jour de la combobox pour la creation d'une extension personnalisee
      if { ( [ buf$audace(bufNo) extension ] == ".fit" ) || ( [ buf$audace(bufNo) extension ] == ".fts" ) || \
         ( [ buf$audace(bufNo) extension ] == ".fits" ) } {
         set confgene(liste_extension) [ list .fit .fts .fits .bmp .gif .jpg .png .tif .xbm .xpm .eps .crw .nef ]
      } else {
         set confgene(liste_extension) [ list [ buf$audace(bufNo) extension ] .fit .fts .fits .bmp .gif .jpg .png .tif .xbm .xpm .eps .crw .nef ]
      }
      $This.newext configure -height [ llength $confgene(liste_extension) ]
      $This.newext configure -values $confgene(liste_extension)
   }

   #
   # confFichierIma::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1060fichier_image.htm"
   }

   #
   # confFichierIma::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # confFichierIma::initConf
   # Initialisation des variables pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      #--- Initialisation indispensable de 3 variables dans aud.tcl (::audace::Recup_Config)
      if { ! [ info exists conf(extension,defaut) ] }   { set conf(extension,defaut)   ".fit" }
      if { ! [ info exists conf(fichier,compres) ] }    { set conf(fichier,compres)    "0" }
      if { ! [ info exists conf(jpegquality,defaut) ] } { set conf(jpegquality,defaut) "80" }
      if { ! [ info exists conf(save_seuils_visu) ] }   { set conf(save_seuils_visu)   "1" }
      #---
      set conf(extension,new)   $conf(extension,defaut)
      set conf(jpegquality,new) $conf(jpegquality,defaut)
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confgene
      global color

      #--- initConf
      if { ( [ buf$audace(bufNo) extension ] == ".fit" ) || ( [ buf$audace(bufNo) extension ] == ".fts" ) || \
         ( [ buf$audace(bufNo) extension ] == ".fits" ) } {
         set confgene(liste_extension) [ list .fit .fts .fits .bmp .gif .jpg .png .tif .xbm .xpm .eps .crw .nef ]
      } else {
         set confgene(liste_extension) [ list [ buf$audace(bufNo) extension ] .fit .fts .fits .bmp .gif .jpg .png .tif .xbm .xpm .eps .crw .nef ]
      }

      #--- confToWidget
      set confgene(extension,new)            $conf(extension,new)
      set confgene(fichier,compres)          $conf(fichier,compres)
      set confgene(jpegquality,new)          $conf(jpegquality,new)
      set confgene(fichier,save_seuils_visu) $conf(save_seuils_visu)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Destruction de la fenetre Selection d'images si elle existe
      if [winfo exists $audace(base).select] {
         destroy $audace(base).select
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,fichier_image)

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

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in $This.frame1 -side top -fill both -expand 1

      #--- Enregistrer une image en conservant ou non les seuils de la visu
      checkbutton $This.save_seuils_visu -text "$caption(confgene,fichier_images_seuils_visu)" -highlightthickness 0 \
         -variable confgene(fichier,save_seuils_visu)
      pack $This.save_seuils_visu -in $This.frame3 -anchor center -side left -padx 10 -pady 5

      #--- Rappelle l'extension par defaut des fichiers image
      label $This.lab1 -text "$caption(confgene,fichier_image_ext_defaut)"
      pack $This.lab1 -in $This.frame4 -anchor center -side left -padx 10 -pady 5

      label $This.labURL2 -text "$conf(extension,defaut)" -fg $color(blue)
      pack $This.labURL2 -in $This.frame4 -anchor center -side right -padx 10 -pady 5

      #--- Cree la zone a renseigner de la nouvelle extension par defaut
      label $This.lab3 -text "$caption(confgene,fichier_image_new_ext)"
      pack $This.lab3 -in $This.frame5 -anchor center -side left -padx 10 -pady 5

      ComboBox $This.newext \
         -width 7          \
         -height [llength $confgene(liste_extension)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 1       \
         -justify center   \
         -textvariable confgene(extension,new) \
         -values $confgene(liste_extension)
      pack $This.newext -in $This.frame5 -anchor center -side right -padx 10 -pady 5

      #--- Ouvre le choix aux fichiers compresses
      checkbutton $This.compress -text "$caption(confgene,fichier_image_compres)" -highlightthickness 0 \
         -variable confgene(fichier,compres)
      pack $This.compress -in $This.frame6 -anchor center -side left -padx 10 -pady 5

      #--- Rappelle le taux de qualite d'enregistrement par defaut des fichiers Jpeg
      label $This.lab4 -text "$caption(confgene,fichier_image_jpeg_quality)"
      pack $This.lab4 -in $This.frame7 -anchor center -side left -padx 10 -pady 5

      label $This.labURL5 -text "$conf(jpegquality,defaut)" -fg $color(blue)
      pack $This.labURL5 -in $This.frame7 -anchor center -side right -padx 10 -pady 5

      #--- Cree la glissiere de reglage pour la nouvelle valeur de qualite par defaut
      label $This.lab6 -text "$caption(confgene,fichier_image_jpeg_newquality)"
      pack $This.lab6 -in $This.frame8 -anchor center -side left -padx 10 -pady 5

      scale $This.efficacite_variant -from 5 -to 100 -length 300 -orient horizontal \
         -showvalue true -tickinterval 10 -resolution 1 -borderwidth 2 -relief groove \
         -variable confgene(jpegquality,new) -width 10
      pack $This.efficacite_variant -in $This.frame9 -side top -padx 10 -pady 5

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confFichierIma::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confFichierIma::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confFichierIma::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confFichierIma::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confFichierIma::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confgene

      set conf(extension,defaut)   $confgene(extension,new)
      set conf(extension,new)      $confgene(extension,new)
      set conf(fichier,compres)    $confgene(fichier,compres)
      set conf(jpegquality,defaut) $confgene(jpegquality,new)
      set conf(jpegquality,new)    $confgene(jpegquality,new)
      set conf(save_seuils_visu)   $confgene(fichier,save_seuils_visu)
   }

   proc MAJ_Extension { } {
      variable This
      global conf confgene panneau

      if { ( $conf(extension,new) == ".bmp" ) || ( $conf(extension,new) == ".gif" ) || ( $conf(extension,new) == ".jpg" ) \
         || ( $conf(extension,new) == ".png" ) || ( $conf(extension,new) == ".tif" ) || ( $conf(extension,new) == ".xbm" ) \
         || ( $conf(extension,new) == ".xpm" ) || ( $conf(extension,new) == ".eps" ) || ( $conf(extension,new) == ".crw" ) \
         || ( $conf(extension,new) == ".nef" ) } {
         set confgene(fichier,compres) "0"
         $This.compress configure -variable confgene(fichier,compres)
         set conf(fichier,compres) $confgene(fichier,compres)
      }

      #--- Mise a jour de l'extension pour toutes les visu disponibles
      foreach visuNo [::visu::list] {
         if { $conf(fichier,compres) == "1" } {
            set panneau(AcqFC,$visuNo,extension)  $conf(extension,new).gz
            set panneau(Dscan,extension_image)    $conf(extension,new).gz
            set panneau(Scanfast,extension_image) $conf(extension,new).gz
         } else {
            set panneau(AcqFC,$visuNo,extension)  $conf(extension,new)
            set panneau(Dscan,extension_image)    $conf(extension,new)
            set panneau(Scanfast,extension_image) $conf(extension,new)
         }
      }
   }
}

#
# AlarmeFinPose
# Description : Configuration de l'alarme de fin de pose
#

namespace eval confAlarmeFinPose {
   variable This
   global confgene

   #
   # confAlarmeFinPose::run this
   # Cree la fenetre de configuration de l'alarme de fin de pose
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confAlarmeFinPose::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration de l'alarme de fin de pose
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confAlarmeFinPose::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      variable This
      global conf
      global confgene

      if { $confgene(alarme,active) == "0" } {
         set conf(acq,bell) "-1"
      } else {
         set conf(acq,bell) $confgene(alarme,delai)
      }
      widgetToConf
   }

   #
   # confAlarmeFinPose::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1070alarme.htm"
   }

   #
   # confAlarmeFinPose::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confgene

      #--- initConf
      if { ! [ info exists conf(acq,bell) ] }      { set conf(acq,bell)      "2" }
      if { ! [ info exists conf(alarme,active) ] } { set conf(alarme,active) "1" }

      #--- confToWidget
      set confgene(alarme,delai)  $conf(acq,bell)
      set confgene(alarme,active) $conf(alarme,active)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,alarme)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      #--- Ouvre le choix a l'utilisation ou non de l'alarme sonore
      checkbutton $This.alarme -text "$caption(confgene,alarme_active)" -highlightthickness 0 \
         -variable confgene(alarme,active)
      pack $This.alarme -in $This.frame3 -anchor w -side left -padx 10 -pady 3

      #--- Cree la zone a renseigner du delai pour l'alarme de fin de pose
      entry $This.delai -textvariable confgene(alarme,delai) -width 3 -justify center
      pack $This.delai -in $This.frame4 -anchor w -side left -padx 20 -pady 3

      label $This.lab1 -text "$caption(confgene,alarme_delai)"
      pack $This.lab1 -in $This.frame4 -anchor w -side left -padx 0 -pady 3

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confAlarmeFinPose::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confAlarmeFinPose::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label 'Invisible' pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confAlarmeFinPose::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confAlarmeFinPose::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAlarmeFinPose::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confgene

      set conf(acq,bell)       $confgene(alarme,delai)
      set conf(alarme,active)  $confgene(alarme,active)
   }
}

#
# TempoScan
# Description : Configuration de la temporisation entre l'arret du moteur d'AD et le debut de la pose du scan
#

namespace eval confTempoScan {
   variable This
   global confgene

   #
   # confTempoScan::run this
   # Cree la fenetre de configuration de la temporisation entre l'arret du moteur d'AD et le debut de la pose
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confTempoScan::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration de la temporisation des scans
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confTempoScan::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confTempoScan::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1080scan.htm"
   }

   #
   # confTempoScan::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confgene

      #--- initConf
      if { ! [ info exists conf(tempo_scan,delai) ] }  { set conf(tempo_scan,delai)  "3" }
      if { ! [ info exists conf(tempo_scan,active) ] } { set conf(tempo_scan,active) "1" }

      #--- confToWidget
      set confgene(tempo_scan,delai)  $conf(tempo_scan,delai)
      set confgene(tempo_scan,active) $conf(tempo_scan,active)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,tempo_scan)

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

      #--- Commentaire sur la temporisation
      label $This.lab1 -text "$caption(confgene,tempo_scan_titre)"
      pack $This.lab1 -in $This.frame3 -anchor w -side top -padx 10 -pady 3

      #--- Radio-bouton 'sans temporisation'
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confgene,tempo_scan_sans)" -value 0 -variable confgene(tempo_scan,active)
      pack $This.rad1 -in $This.frame4 -anchor w -side top -padx 30 -pady 3

      #--- Radio-bouton 'avec temporisation'
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(confgene,tempo_scan_avec)" -value 1 -variable confgene(tempo_scan,active)
      pack $This.rad2 -in $This.frame4 -anchor w -side top -padx 30 -pady 3

      #--- Cree la zone a renseigner du delai entre l'arret du moteur d'A.D. et le debut de la pose
      label $This.lab3 -text "$caption(confgene,tempo_scan_delai)"
      pack $This.lab3 -in $This.frame5 -anchor w -side left -padx 10 -pady 3

      entry $This.delai -textvariable confgene(tempo_scan,delai) -width 3 -justify center
      pack $This.delai -in $This.frame5 -anchor w -side left -padx 0 -pady 2

      label $This.lab4 -text "$caption(confgene,tempo_scan_seconde)"
      pack $This.lab4 -in $This.frame5 -anchor w -side left -padx 0 -pady 3

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confTempoScan::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confTempoScan::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confTempoScan::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confTempoScan::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confTempoScan::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confgene

      set conf(tempo_scan,delai)  $confgene(tempo_scan,delai)
      set conf(tempo_scan,active) $confgene(tempo_scan,active)
   }
}

#
# confChoixOutil
# Description : Choisir les outils a afficher dans le menu Outil
#

namespace eval confChoixOutil {
   variable This
   global confgene

   #
   # confChoixOutil::run this
   # Cree la fenetre de configuration du choix des outils a afficher dans le menu Outil
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confChoixOutil::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre du choix des outils a afficher dans le menu Outil
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confChoixOutil::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      global audace
      global caption

      widgetToConf
      #--- Je supprime toutes les entrees du menu Outil
      Menu_Delete $audace(visuNo) "$caption(audace,menu,outils)" entries
      #--- Rafraichissement du menu Outil
      Menu_Command $audace(visuNo)  "$caption(audace,menu,outils)" "$caption(audace,menu,pas_outil)" "::confVisu::stopTool $audace(visuNo)"
      Menu_Separator $audace(visuNo) "$caption(audace,menu,outils)"
      ::audace::affiche_Outil $audace(visuNo) 
      Menu_Separator $audace(visuNo) "$caption(audace,menu,outils)"
      Menu_Command $audace(visuNo) "$caption(audace,menu,outils)" "$caption(confgene,choix_outils)" \
         { ::confChoixOutil::run "$audace(base).confChoixOutil" }
      #---
      set This "$audace(base)"
      Menu_Bind $audace(visuNo) $This <F12> "$caption(audace,menu,outils)" "$caption(audace,menu,pas_outil)" "$caption(touche,F12)"
   }

   #
   # confChoixOutil::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,tool)" "1900choix_outil.htm"
   }

   #
   # confChoixOutil::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global panneau
      global color
      global confgene

      #--- initConf
      #--- Initialisation indispensable dans aud.tcl --> ::audace::affiche_Outil

      #--- confToWidget
      for { set i 1 } { $i <= $confgene(Choix_Outil,nbre) } { incr i } {
         catch {
            set confgene(Choix_Outil,n$i)   $conf(panneau,n$i)
            set confgene(Choix_Outil,raccourci_n$i) $conf(raccourci,n$i)
         }
      }

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,choix_outils)

      #--- Creation des differents frames
      frame $This.frame0 -borderwidth 1 -relief raised
      pack $This.frame0 -side top -fill both -expand 1

      frame $This.frame1 -borderwidth 0 -relief raised
      pack $This.frame1 -in $This.frame0 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 0 -relief raised
      pack $This.frame2 -in $This.frame0 -side top -fill both -expand 1

      frame $This.frame3 -borderwidth 1 -relief raised
      pack $This.frame3 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 1 -relief raised
      pack $This.frame4 -side top -fill x 

      #--- Cree le frame (colonne) de gauche
      frame $This.frame5 -borderwidth 0
      pack $This.frame5 -in $This.frame2 -side left -fill both -expand 1

      #--- Cree le frame (colonne) de droite
      frame $This.frame6 -borderwidth 0
      pack $This.frame6 -in $This.frame2 -side right -fill both -expand 1

      #--- Initialisation des variables
      set num     "0"
      set i       "0"
      set colonne "0"

      #--- Cree le frame pour les commentaires
      label $This.lab1 -text "$caption(confgene,choix_outils_1)"
      pack $This.lab1 -in $This.frame1 -side top -fill both -expand 1 -padx 5 -pady 2

      label $This.lab2 -text "$caption(confgene,choix_outils_2)"
      pack $This.lab2 -in $This.frame1 -side top -fill both -expand 1 -padx 5 -pady 2

      #--- Ouvre le choix a l'affichage ou non des outils dans le menu Outil
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         set num [expr $num + 1]
         set i [expr $i + 1]
         #--- Affichage des noms des outils a gauche, puis a droite, ...
         set list_combobox [ list $caption(touche,pas_de_raccourci) \
            $caption(touche,F2) $caption(touche,F3) $caption(touche,F4) $caption(touche,F5) \
            $caption(touche,F6) $caption(touche,F7) $caption(touche,F8) $caption(touche,F9) \
            $caption(touche,F10) $caption(touche,F11) \
            $caption(touche,controle,A) $caption(touche,controle,B) $caption(touche,controle,C) \
            $caption(touche,controle,D) $caption(touche,controle,E) $caption(touche,controle,F) \
            $caption(touche,controle,G) $caption(touche,controle,H) $caption(touche,controle,I) \
            $caption(touche,controle,J) $caption(touche,controle,K) $caption(touche,controle,L) \
            $caption(touche,controle,M) $caption(touche,controle,N) $caption(touche,controle,P) \
            $caption(touche,controle,R) $caption(touche,controle,T) $caption(touche,controle,U) \
            $caption(touche,controle,V) $caption(touche,controle,W) $caption(touche,controle,X) \
            $caption(touche,controle,Y) $caption(touche,controle,Z) ]
         if { $colonne == "0" } {
            frame $This.framea$num -borderwidth 0
               #--- Selection d'un outil a afficher
               checkbutton $This.panneau$num -text "$panneau($m)" -highlightthickness 0 \
                  -variable confgene(Choix_Outil,n$i)
               pack $This.panneau$num -in $This.framea$num -side left -padx 5 -pady 0
               #--- Selection d'un raccourci
               set hauteur [llength $list_combobox]
               if { $hauteur > "5" } {
                  set hauteur "5"
               }
               ComboBox $This.raccourci$num \
                  -width 8          \
                  -height $hauteur \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confgene(Choix_Outil,raccourci_n$i) \
                  -values $list_combobox
               pack $This.raccourci$num -in $This.framea$num -side right -padx 5 -pady 0
            pack $This.framea$num -in $This.frame5 -side top -fill both -expand 1
            set colonne "1"
         } else {
            frame $This.frameb$num -borderwidth 0
               #--- Selection d'un outil a afficher
               checkbutton $This.panneau$num -text "$panneau($m)" -highlightthickness 0 \
                  -variable confgene(Choix_Outil,n$i)
               pack $This.panneau$num -in $This.frameb$num -side left -padx 5 -pady 0
               #--- Selection d'un raccourci
               ComboBox $This.raccourci$num \
                  -width 8          \
                  -height $hauteur \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable confgene(Choix_Outil,raccourci_n$i) \
                  -values $list_combobox
               pack $This.raccourci$num -in $This.frameb$num -side right -padx 5 -pady 0
            pack $This.frameb$num -in $This.frame6 -side top -fill both -expand 1
            set colonne "0"
         }
      }

      #--- Cree le frame pour les commentaires
      label $This.labURL3 -text "$caption(confgene,choix_outils_3)" -fg $color(red)
      pack $This.labURL3 -in $This.frame3 -side bottom -fill both -expand 1 -padx 5 -pady 2

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confChoixOutil::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confChoixOutil::appliquer }
      pack $This.but_appliquer -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confChoixOutil::fermer }
      pack $This.but_fermer -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confChoixOutil::afficheAide } 
      pack $This.but_aide -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confChoixOutil::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global conf
      global confgene

      for { set i 1 } { $i <= $confgene(Choix_Outil,nbre) } { incr i } {
         catch {
            set conf(panneau,n$i) $confgene(Choix_Outil,n$i)
            if { [expr fmod($i,2)] == "1.0" } {
               set conf(raccourci,n$i) [ $This.raccourci$i get ]
            } else {
               set conf(raccourci,n$i) [ $This.raccourci$i get ]
            }
         }
      }
   }
}

#
# Messages_Console
# Description : Choisir l'affichage ou non de messages sur la Console
#

namespace eval confMessages_Console {
   variable This
   global confgene

   #
   # confMessages_Console::run this
   # Cree la fenetre de configuration de l'affichage de messages sur la Console
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confMessages_Console::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre du choix de l'affichage ou non de messages sur la Console
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confMessages_Console::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # confMessages_Console::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1090msg_console.htm"
   }

   #
   # confMessages_Console::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global panneau
      global confgene

      #--- initConf
      if { ! [ info exists conf(messages_console_acqfc) ] }   { set conf(messages_console_acqfc)   "1" }
      if { ! [ info exists conf(messages_console_pretrfc) ] } { set conf(messages_console_pretrfc) "1" }

      #--- confToWidget
      set confgene(Messages_Console,acqfc)   $conf(messages_console_acqfc)
      set confgene(Messages_Console,pretrfc) $conf(messages_console_pretrfc)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,messages_console)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      frame $This.frame3 -borderwidth 0
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0
      pack $This.frame4 -in $This.frame1 -side left -fill both -expand 1

      frame $This.frame5 -borderwidth 0
      pack $This.frame5 -in $This.frame1 -side right -fill both -expand 1

      frame $This.frame6 -borderwidth 0
      pack $This.frame6 -in $This.frame4 -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0
      pack $This.frame7 -in $This.frame4 -side top -fill both -expand 1

      frame $This.frame8 -borderwidth 0
      pack $This.frame8 -in $This.frame5 -side top -fill both -expand 1

      frame $This.frame9 -borderwidth 0
      pack $This.frame9 -in $This.frame5 -side top -fill both -expand 1

      #--- Cree les labels pour les commentaires
      label $This.lab1 -text "$caption(confgene,messages_console_1)"
      pack $This.lab1 -in $This.frame3 -side top -fill both -expand 1 -padx 5 -pady 2

      label $This.lab2 -text "$caption(confgene,messages_console_2)"
      pack $This.lab2 -in $This.frame3 -side top -fill both -expand 1 -padx 5 -pady 2

      #--- Cree le label et les radio-boutons de l'outil d'acquisition
      if { [ info exists panneau(menu_name,AcqFC) ] == "1" } {
         label $This.lab3 -text "$panneau(menu_name,AcqFC)"
         pack $This.lab3 -in $This.frame6 -side left -anchor w -padx 5 -pady 5

         radiobutton $This.radio0 -anchor w -highlightthickness 0 \
            -text "$caption(confgene,messages_console_non)" -value 0 \
            -variable confgene(Messages_Console,acqfc)
         pack $This.radio0 -in $This.frame8 -side right -padx 5 -pady 5 -ipady 0

         radiobutton $This.radio1 -anchor w -highlightthickness 0 \
            -text "$caption(confgene,messages_console_oui)" -value 1 \
            -variable confgene(Messages_Console,acqfc)
         pack $This.radio1 -in $This.frame8 -side right -padx 5 -pady 5 -ipady 0
      } else {
         label $This.lab3 -text " "
         pack $This.lab3 -in $This.frame6 -side left -anchor w -padx 5 -pady 0
         label $This.lab3a -text " "
         pack $This.lab3a -in $This.frame8 -side right -anchor w -padx 5 -pady 0
      }

      #--- Cree le label et les radio-boutons de l'outil de pretraitement
      if { [ info exists panneau(menu_name,pretraitFC) ] == "1" } {
         label $This.lab4 -text "$panneau(menu_name,pretraitFC)"
         pack $This.lab4 -in $This.frame7 -side left -anchor w -padx 5 -pady 5

         radiobutton $This.radio2 -anchor w -highlightthickness 0 \
            -text "$caption(confgene,messages_console_non)" -value 0 \
            -variable confgene(Messages_Console,pretrfc)
         pack $This.radio2 -in $This.frame9 -side right -padx 5 -pady 5 -ipady 0

         radiobutton $This.radio3 -anchor w -highlightthickness 0 \
            -text "$caption(confgene,messages_console_oui)" -value 1 \
            -variable confgene(Messages_Console,pretrfc)
         pack $This.radio3 -in $This.frame9 -side right -padx 5 -pady 5 -ipady 0
      } else {
         label $This.lab4 -text ""
         pack $This.lab4 -in $This.frame7 -side left -anchor w -padx 5 -pady 0
         label $This.lab4a -text ""
         pack $This.lab4a -in $This.frame9 -side right -anchor w -padx 5 -pady 0
      }

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confMessages_Console::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confMessages_Console::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label 'Invisible' pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confMessages_Console::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confMessages_Console::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confMessages_Console::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confgene

      set conf(messages_console_acqfc)   $confgene(Messages_Console,acqfc)
      set conf(messages_console_pretrfc) $confgene(Messages_Console,pretrfc)
   }
}

#
# TypeFenetre
# Description : Configuration du type de fenetre du menu 'Reglages'
#

namespace eval confTypeFenetre {
   variable This
   global confgene

   #
   # confTypeFenetre::run this
   # Cree la fenetre de configuration du type de fenetre
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confTypeFenetre::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration du type de fenetre
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # confTypeFenetre::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
      rafraichissement
   }

   #
   # confTypeFenetre::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1100type_fenetre.htm"
   }

   #
   # confTypeFenetre::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # confTypeFenetre::rafraichissement
   # Fonction permettant le rafraichissement de la fenetre
   #
   proc rafraichissement { } {
      variable This
      global audace

      fermer
      ::confTypeFenetre::run "$audace(base).confTypeFenetre"
      focus $This
   }

   #
   # confTypeFenetre::initConf
   # Initialisation des variables pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(ok+appliquer) ] } { set conf(ok+appliquer) "1" }
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption
      global confgene

      #--- Initialisation indispensable de la variable du type de fenetre dans aud.tcl (::audace::Recup_Config)
      #--- initConf

      #--- confToWidget
      set confgene(TypeFenetre,ok+appliquer) $conf(ok+appliquer)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,type_fenetre)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side bottom -fill x 

      frame $This.frame3 -borderwidth 1 -relief raised
      pack $This.frame3 -in $This.frame1 -side left -fill y

      frame $This.frame4 -borderwidth 1 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill x

      frame $This.frame5 -borderwidth 1 -relief raised
      pack $This.frame5 -in $This.frame1 -side top -fill x

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confTypeFenetre::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confTypeFenetre::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confTypeFenetre::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confTypeFenetre::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un frame pour y mettre les radio-boutons de choix
      #--- Type OK + Appliquer + Annuler
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -value 0 \
         -variable confgene(TypeFenetre,ok+appliquer)
      pack $This.rad1 -in $This.frame3 -anchor center -side top -fill x -padx 5 -pady 5
      #--- Type Appliquer + Annuler
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -value 1 \
         -variable confgene(TypeFenetre,ok+appliquer)
      pack $This.rad2 -in $This.frame3 -anchor center -side bottom -fill x -padx 5 -pady 5

      #--- Affichage des boutons 'Appliquer' + 'Aide' + 'Fermer'
      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer_1 -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2
      pack $This.but_appliquer_1 -in $This.frame4 -side left -anchor w -padx 3 -pady 3  -ipady 5
      #--- Cree le bouton 'Fermer'
      button $This.but_fermer_1 -text "$caption(confgene,fermer)" -width 7 -borderwidth 2
      pack $This.but_fermer_1 -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree le bouton 'Aide'
      button $This.but_aide_1 -text "$caption(confgene,aide)" -width 7 -borderwidth 2
      pack $This.but_aide_1 -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Affichage des boutons 'OK' + 'Appliquer' + 'Aide' + 'Fermer'
      #--- Cree le bouton 'OK'
      button $This.but_ok_2 -text "$caption(confgene,ok)" -width 7 -borderwidth 2
      pack $This.but_ok_2 -in $This.frame5 -side left -anchor w -padx 3 -pady 3  -ipady 5
      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer_2 -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2
      pack $This.but_appliquer_2 -in $This.frame5 -side left -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree un label 'Invisible' pour simuler un espacement
      label $This.lab_invisible_2 -width 10
      pack $This.lab_invisible_2 -in $This.frame5 -side left -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree le bouton 'Fermer'
      button $This.but_fermer_2 -text "$caption(confgene,fermer)" -width 7 -borderwidth 2
      pack $This.but_fermer_2 -in $This.frame5 -side right -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree le bouton 'Aide'
      button $This.but_aide_2 -text "$caption(confgene,aide)" -width 7 -borderwidth 2
      pack $This.but_aide_2 -in $This.frame5 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confTypeFenetre::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf
      global confgene

      set conf(ok+appliquer) $confgene(TypeFenetre,ok+appliquer)
   }
}

#
# General
# Description : Configuration generale pour l'acces au choix des langues, au tutorial et au message
# d'erreur genere lors de l'installation de Porttalk s'il y a eu un probleme
#

namespace eval confGeneral {
   variable This

   #
   # confGeneral::run this
   # Cree la fenetre de configuration
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confGeneral::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # confGeneral::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1010general.htm"
   }

   proc createDialog { } {
      variable This
      global audace
      global conf
      global caption

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50 
      wm resizable $This 0 0
      wm title $This $caption(confgene,general_titre)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      frame $This.frame3 -borderwidth 0
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0
      pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame6 -borderwidth 0
      pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

      #--- Cree le label pour les commentaires
      label $This.lab1 -text "$caption(confgene,general_texte)"
      pack $This.lab1 -in $This.frame3 -side top -anchor w -padx 5 -pady 5

      #--- Cree les boutons et les labels pour permettre le choix
      label $This.lab2 -anchor nw -highlightthickness 0 -text "$caption(confgene,general_langues)" -padx 0 -pady 0
      pack $This.lab2 -in $This.frame4 -side left -padx 20 -pady 5

      if { [ file exist [ file join $audace(rep_install) bin audace.txt ] ] } {
         button $This.but1 -text "$caption(confgene,general_non)" -relief raised -state normal -command {
            #--- Acces au choix des langue et au tutorial au prochain demarrage
            catch {
               file delete [ file join $audace(rep_install) bin audace.txt ]
            }
            ::confGeneral::fermer
            ::confGeneral::run "$audace(base).confGeneral"
         }
         pack $This.but1 -in $This.frame4 -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
      } else {
         button $This.but1 -text "$caption(confgene,general_oui)" -relief raised -state normal -command {
            set f [ open "[ file join $audace(rep_install) bin audace.txt ]" w ]
            close $f
            ::confGeneral::fermer
            ::confGeneral::run "$audace(base).confGeneral"
         }
         pack $This.but1 -in $This.frame4 -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
      }

      label $This.lab3 -anchor nw -highlightthickness 0 -text "$caption(confgene,general_tutorial)" -padx 0 -pady 0
      pack $This.lab3 -in $This.frame5 -side left -padx 20 -pady 5

      if { [ file exist [ file join $audace(rep_install) bin audace.txt ] ] } {
         button $This.but2 -text "$caption(confgene,general_non)" -relief raised -state normal -command {
            #--- Acces au choix des langue et au tutorial au prochain demarrage
            catch {
               file delete [ file join $audace(rep_install) bin audace.txt ]
            }
            ::confGeneral::fermer
            ::confGeneral::run "$audace(base).confGeneral"
         }
         pack $This.but2 -in $This.frame5 -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
      } else {
         button $This.but2 -text "$caption(confgene,general_oui)" -relief raised -state normal -command {
            set f [ open "[ file join $audace(rep_install) bin audace.txt ]" w ]
            close $f
            ::confGeneral::fermer
            ::confGeneral::run "$audace(base).confGeneral"
         }
         pack $This.but2 -in $This.frame5 -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
      }

      if { $::tcl_platform(os) == "Windows NT" } {
         label $This.lab4 -anchor nw -highlightthickness 0 -text "$caption(confgene,general_porttalk)" -padx 0 -pady 0
         pack $This.lab4 -in $This.frame6 -side left -padx 20 -pady 5

         if { [ file exist [ file join $audace(rep_install) bin allowio.txt ] ] } {
            button $This.but3 -text "$caption(confgene,general_non)" -relief raised -state normal -command {
               #--- Acces au message d'erreur Porttalk au prochain demarrage
               catch {
                  file delete [ file join $audace(rep_install) bin allowio.txt ]
               }
               ::confGeneral::fermer
               ::confGeneral::run "$audace(base).confGeneral"
            }
            pack $This.but3 -in $This.frame6 -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
         } else {
            button $This.but3 -text "$caption(confgene,general_oui)" -relief raised -state normal -command {
               set f [ open "[ file join $audace(rep_install) bin allowio.txt ]" w ]
               close $f
               ::confGeneral::fermer
               ::confGeneral::run "$audace(base).confGeneral"
            }
            pack $This.but3 -in $This.frame6 -side right -padx 10 -pady 5 -ipadx 5 -ipady 5
         }
      }

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confGeneral::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confGeneral::afficheAide } 
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

#
# Version
# Description : Version du logiciel
#

namespace eval confVersion {
   variable This

   #
   # confVersion::run this
   # Cree la fenetre definissant la version du logiciel
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # confVersion::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace
      global audela
      global conf
      global caption
      global color

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+0
      wm resizable $This 0 0
      wm title $This $caption(en-tete,a_propos_de)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      #--- Nom du logiciel et sa version
      label $This.lab1 -text "$caption(en-tete,a_propos_de_version) $audela(version)" -font $audace(font,arial_15_b)
      pack $This.lab1 -in $This.frame1 -padx 30 -pady 5

      #--- Version Tcl/Tk utilisee
      label $This.lab2 -text "$caption(en-tete,a_propos_de_version_Tcl/Tk)[ info patchlevel ]" \
         -font $audace(font,arial_10_n)
      pack $This.lab2 -in $This.frame1 -padx 30 -pady 0

      #--- Date de la mise a jour
      label $This.labURL2 -text "$caption(en-tete,a_propos_de_maj) $audela(date)." -font $audace(font,arial_10_n) -fg $color(red)
      pack $This.labURL2 -in $This.frame1 -padx 30 -pady 5

      #--- Logiciel libre et gratuit
      label $This.lab3 -text "$caption(en-tete,a_propos_de_libre)" -font $audace(font,arial_10_n)
      pack $This.lab3 -in $This.frame1 -padx 30 -pady 5

      #--- Site web officiel
      label $This.labURL4 -text "$caption(en-tete,a_propos_de_site)" -font $audace(font,arial_10_n) -fg $color(blue)
      pack $This.labURL4 -in $This.frame1 -padx 30 -pady 5

      #--- Copyright
      label $This.lab5 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright1)" \
         -font $audace(font,arial_8_n)
      pack $This.lab5 -in $This.frame1 -padx 30 -pady 5

      label $This.lab6 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright2)" \
         -font $audace(font,arial_8_n)
      pack $This.lab6 -in $This.frame1 -padx 30 -pady 5

      label $This.lab7 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright3)" \
         -font $audace(font,arial_8_n)
      pack $This.lab7 -in $This.frame1 -padx 30 -pady 5

      label $This.lab8 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright4)" \
         -font $audace(font,arial_8_n)
      pack $This.lab8 -in $This.frame1 -padx 30 -pady 5

      label $This.lab9 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright5)" \
         -font $audace(font,arial_8_n)
      pack $This.lab9 -in $This.frame1 -padx 30 -pady 5

      label $This.lab10 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright6)" \
         -font $audace(font,arial_8_n)
      pack $This.lab10 -in $This.frame1 -padx 30 -pady 5

      label $This.lab11 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright7)" \
         -font $audace(font,arial_8_n)
      pack $This.lab11 -in $This.frame1 -padx 30 -pady 5

      label $This.lab12 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright8)" \
         -font $audace(font,arial_8_n)
      pack $This.lab12 -in $This.frame1 -padx 30 -pady 5

      label $This.lab13 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright9)" \
         -font $audace(font,arial_8_n)
      pack $This.lab13 -in $This.frame1 -padx 30 -pady 5

      label $This.lab14 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright10)" \
         -font $audace(font,arial_8_n)
      pack $This.lab14 -in $This.frame1 -padx 30 -pady 5

      label $This.lab15 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright11)" \
         -font $audace(font,arial_8_n)
      pack $This.lab15 -in $This.frame1 -padx 30 -pady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confVersion::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $This.labURL4 <ButtonPress-1> {
         set filename "$caption(en-tete,a_propos_de_site)"
         ::audace::Lance_Site_htm $filename
      }
      bind $This.labURL4 <Enter> {
         $::confVersion::This.labURL4 configure -fg $color(purple)
      }
      bind $This.labURL4 <Leave> {
         $::confVersion::This.labURL4 configure -fg $color(blue)
      }
   }
}

#
# confGenerique
# Description : Configuration generique
#    Affiche une fenetre de configuration generique et appelle la methode fillConfigPage du driver
#

namespace eval confGenerique {
   variable This
   variable NameSpace

   #
   # confGenerique::run this
   # Cree la fenetre de configuration generique
   # this = chemin de la fenetre
   #  
   #  retourne 1 si la fenetre est fermee avec le bouton OK
   #  retourne 0 si la fenetre est fermee avec le bouton FERMER
   #  
   proc run { this namespace { visuNo "1" } } {
      variable This
      variable NameSpace
      variable confResult

      set This $this
      set NameSpace $namespace
      set confResult "0"

      createDialog $visuNo
      #tkwait visibility $This
      tkwait window $This

      return $confResult
   }

   #
   # confGenerique::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration generique
   #
   proc ok { visuNo } {
      variable This
      variable confResult

      ::confGenerique::apply $visuNo
      set confResult "1"
      ::confGenerique::close $visuNo
   }

   #
   # confGenerique::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc apply { visuNo } {
      variable NameSpace

      if { [info procs $NameSpace\:\:apply ] != "" } {
         $NameSpace\:\:apply $visuNo
      }
   }

   #
   # confGenerique::afficherAide
   # Fonction 'afficherAide' pour afficher l'aide 
   #
   proc showHelp { } {
      variable NameSpace

      set result [ catch { $NameSpace\:\:showHelp } msg ]
      if { $result == "1" } {
         ::console::affiche_erreur "$msg\n"
         tk_messageBox -title "$NameSpace" -type ok -message "$msg" -icon error
         return
      }
   }

   #
   # confGenerique::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc close { visuNo } {
      variable This
      variable NameSpace

      if { [info procs $NameSpace\:\:close ] != "" } {
         #--- appelle la procedure "close"
         set result [$NameSpace\:\:close $visuNo]
         if { $result == "0" } {
            return
         }
      } 
      #--- supprime la fenetre
      destroy $This
   }

   proc createDialog { visuNo } {
      variable This
      variable NameSpace
      global audace
      global conf
      global caption

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut 
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This "[$NameSpace\:\:getLabel] (visu$visuNo)"

      #--- Frame des parametres a configurer
      frame $This.frame1 -borderwidth 1 -relief raised

      $NameSpace\:\:fillConfigPage $This.frame1 $visuNo

      pack $This.frame1 -side top -fill both -expand 1

      #--- Frame des boutons OK, Appliquer et Fermer
      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x 

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command "::confGenerique::ok $visuNo"
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3  -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command "::confGenerique::apply $visuNo"
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label 'Invisible' pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command "::confGenerique::close $visuNo"
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command "::confGenerique::showHelp"
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

