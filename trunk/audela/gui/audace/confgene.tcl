#
# Fichier : confgene.tcl
# Description : Configuration generale d'AudeLA et d'Aud'ACE (langage, editeurs, repertoires, position
#               de l'observateur, temps (heure systeme ou TU), fichiers image, alarme sonore de fin de
#               pose, choix des plugins, type de fenetre, la fenetre A propos de ... et une fenetre de
#               configuration generique)
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

#
# PosObs
# Description : Position de l'observateur sur la Terre
#

namespace eval ::confPosObs {

   #
   # confPosObs::run this
   # Cree la fenetre definissant la position de l'observateur
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      ::confPosObs::createDialog
      tkwait visibility $This
   }

   #
   # confPosObs::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la position de l'observateur
   #
   proc ok { } {
      ::confPosObs::appliquer
      ::confPosObs::fermer
   }

   #
   # confPosObs::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      ::confPosObs::MPC
      ::confPosObs::Position
      ::confPosObs::widgetToConf
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
      variable This
      global conf confgene

      set confgene(posobs,nom_organisation)        $conf(posobs,nom_organisation)
      set confgene(posobs,nom_observateur)         $conf(posobs,nom_observateur)
      set confgene(posobs,nom_observatoire)        $conf(posobs,nom_observatoire)
      set confgene(posobs,estouest)                $conf(posobs,estouest)
      set confgene(posobs,long)                    $conf(posobs,long)
      set confgene(posobs,nordsud)                 $conf(posobs,nordsud)
      set confgene(posobs,lat)                     $conf(posobs,lat)
      set confgene(posobs,altitude)                $conf(posobs,altitude)
      set confgene(posobs,ref_geodesique)          $conf(posobs,ref_geodesique)
      set confgene(posobs,observateur,gps)         $conf(posobs,observateur,gps)
      set confgene(posobs,station_uai)             $conf(posobs,station_uai)
      set confgene(posobs,fichier_station_uai)     $conf(posobs,fichier_station_uai)
      set confgene(posobs,observateur,mpc)         $conf(posobs,observateur,mpc)
      set confgene(posobs,observateur,mpcstation)  $conf(posobs,observateur,mpcstation)

      destroy $This
   }

   #
   # confPosObs::initConf
   # Initialisation de variables dans aud.tcl (::audace::loadSetup) pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      #--- Initialisation indispensable de variables
      if { ! [ info exists conf(posobs,nom_organisation) ] } { set conf(posobs,nom_organisation) "" }
      if { ! [ info exists conf(posobs,nom_observateur) ] }  { set conf(posobs,nom_observateur)  "" }
      if { ! [ info exists conf(posobs,nom_observatoire) ] } { set conf(posobs,nom_observatoire) "Pic du Midi" }
      if { ! [ info exists conf(posobs,ref_geodesique) ] }   { set conf(posobs,ref_geodesique)   "WGS84" }
      if { ! [ info exists conf(posobs,station_uai) ] }      { set conf(posobs,station_uai)      "586" }

      #--- Observatoire du Pic du Midi
      if { ! [ info exists conf(posobs,estouest) ] }         { set conf(posobs,estouest)         "E" }
      if { ! [ info exists conf(posobs,long) ] }             { set conf(posobs,long)             "0d8m32s2" }
      if { ! [ info exists conf(posobs,nordsud) ] }          { set conf(posobs,nordsud)          "N" }
      if { ! [ info exists conf(posobs,lat) ] }              { set conf(posobs,lat)              "42d56m11s9" }
      if { ! [ info exists conf(posobs,altitude) ] }         { set conf(posobs,altitude)         "2890.5" }
      if { ! [ info exists conf(posobs,observateur,gps) ] }  { set conf(posobs,observateur,gps)  "GPS 0.142300 E 42.936639 2890.5" }

      #--- Concatenation de variables pour l'en-tete FITS
      set conf(posobs,estouest_long) $conf(posobs,estouest)$conf(posobs,long)
      set conf(posobs,nordsud_lat)   $conf(posobs,nordsud)$conf(posobs,lat)
   }

   #
   # confPosObs::initConf1
   # Initialisation d'autres variables de position
   #
   proc initConf1 { } {
      global conf

      #--- Initialisation indispensable d'autres variables
      if { ! [ info exists conf(posobs,fichier_station_uai) ] }    { set conf(posobs,fichier_station_uai)    "obscodes.txt" }
      if { ! [ info exists conf(posobs,observateur,mpc) ] }        { set conf(posobs,observateur,mpc)        "" }
      if { ! [ info exists conf(posobs,observateur,mpcstation) ] } { set conf(posobs,observateur,mpcstation) "" }

      #--- Observatoire du Pic du Midi - FRANCE
      if { ! [ info exists conf(posobs,config_observatoire,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set config_observatoire { }
         set config_observatoire(nom_observatoire) "Pic du Midi"
         set config_observatoire(estouest)         "E"
         set config_observatoire(long)             "0d8m32s2"
         set config_observatoire(nordsud)          "N"
         set config_observatoire(lat)              "42d56m11s9"
         set config_observatoire(altitude)         "2890.5"
         set config_observatoire(ref_geodesique)   "WGS84"
         set config_observatoire(station_uai)      "586"

         set conf(posobs,config_observatoire,0) [ array get config_observatoire ]
      }

      #--- Observatoire de Haute Provence - FRANCE
      if { ! [ info exists conf(posobs,config_observatoire,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set config_observatoire { }
         set config_observatoire(nom_observatoire) "Haute Provence"
         set config_observatoire(estouest)         "E"
         set config_observatoire(long)             "5d42m56s5"
         set config_observatoire(nordsud)          "N"
         set config_observatoire(lat)              "43d55m54s8"
         set config_observatoire(altitude)         "633.9"
         set config_observatoire(ref_geodesique)   "WGS84"
         set config_observatoire(station_uai)      "511"

         set conf(posobs,config_observatoire,1) [ array get config_observatoire ]
      }

      #---
      if { ! [ info exists conf(posobs,config_observatoire,2) ] } { set conf(posobs,config_observatoire,2) "" }
      if { ! [ info exists conf(posobs,config_observatoire,3) ] } { set conf(posobs,config_observatoire,3) "" }
      if { ! [ info exists conf(posobs,config_observatoire,4) ] } { set conf(posobs,config_observatoire,4) "" }
      if { ! [ info exists conf(posobs,config_observatoire,5) ] } { set conf(posobs,config_observatoire,5) "" }
      if { ! [ info exists conf(posobs,config_observatoire,6) ] } { set conf(posobs,config_observatoire,6) "" }
      if { ! [ info exists conf(posobs,config_observatoire,7) ] } { set conf(posobs,config_observatoire,7) "" }
      if { ! [ info exists conf(posobs,config_observatoire,8) ] } { set conf(posobs,config_observatoire,8) "" }
      if { ! [ info exists conf(posobs,config_observatoire,9) ] } { set conf(posobs,config_observatoire,9) "" }
   }

   #
   # confPosObs::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption color conf confgene

      #--- initConf
      ::confPosObs::initConf1

      #--- Initialisation d'autres variables
      set confgene(index_del)  "0"
      set confgene(index_copy) "0"

      #--- confToWidget
      ::confPosObs::confToWidget

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

      frame $This.frame2a -borderwidth 1 -relief raised
      pack $This.frame2a -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame2b -borderwidth 1 -relief raised
      pack $This.frame2b -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame2c -borderwidth 0 -relief raised
      pack $This.frame2c -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame2d -borderwidth 0 -relief raised
      pack $This.frame2d -in $This.frame1 -side top -fill both -expand 1

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

      #--- Nom de l'organisation
      label $This.lab0 -text "$caption(confgene,nom_organisation)"
      pack $This.lab0 -in $This.frame2a -anchor w -side top -padx 10 -pady 5

      entry $This.nom_organisation -textvariable confgene(posobs,nom_organisation) -width 70
      pack $This.nom_organisation -in $This.frame2a -anchor w -side top -padx 10 -pady 5

      #--- Nom de l'observateur
      label $This.lab0a -text "$caption(confgene,nom_observateur)"
      pack $This.lab0a -in $This.frame2b -anchor w -side top -padx 10 -pady 5

      entry $This.nom_observateur -textvariable confgene(posobs,nom_observateur) -width 70
      pack $This.nom_observateur -in $This.frame2b -anchor w -side top -padx 10 -pady 5

      #--- Nom de l'observatoire
      label $This.lab0b -text "$caption(confgene,nom_observatoire:)"
      pack $This.lab0b -in $This.frame2c -anchor w -side left -padx 10 -pady 5

      ComboBox $This.nom_observatoire \
         -width 42         \
         -height 10        \
         -relief sunken    \
         -borderwidth 2    \
         -editable 0       \
         -textvariable confgene(posobs,nom_observatoire) \
         -modifycmd "::confPosObs::cbCommand $This.nom_observatoire" \
         -values $confgene(posobs,nom_observatoire_liste)
      pack $This.nom_observatoire -in $This.frame2c -anchor w -side right -padx 10 -pady 5

      #--- Gestion des noms d'observatoire
      button $This.but_copy_obs -text "$caption(confgene,copier_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::copyObs }
      pack $This.but_copy_obs -in $This.frame2d -anchor center -side right -padx 5 -pady 5 -ipadx 5
      button $This.but_del_obs -text "$caption(confgene,supprimer_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::delObs }
      pack $This.but_del_obs -in $This.frame2d -anchor center -side right -padx 5 -pady 5 -ipadx 5
      button $This.but_add_obs -text "$caption(confgene,ajouter_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::addObs }
      pack $This.but_add_obs -in $This.frame2d -anchor center -side right -padx 5 -pady 5 -ipadx 5

      #--- Longitude observateur
      label $This.lab1 -text "$caption(confgene,position_longitude)"
      pack $This.lab1 -in $This.frame12 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,position_est) $caption(confgene,position_ouest) ]
      ComboBox $This.estouest \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
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
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
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

      entry $This.altitude -textvariable confgene(posobs,altitude) -width 7
      pack $This.altitude -in $This.frame15 -anchor w -side left -padx 10 -pady 5

      label $This.lab4 -text "$caption(confgene,position_metre)"
      pack $This.lab4 -in $This.frame15 -anchor w -side left -pady 5

      #--- Referentiel geodesique
      label $This.lab5 -text "$caption(confgene,position_ref_geodesique)"
      pack $This.lab5 -in $This.frame11 -anchor w -side top -padx 10 -pady 5

      set list_combobox [ list $caption(confgene,position_ref_geodesique_ed50) \
         $caption(confgene,position_ref_geodesique,wgs84) ]
      ComboBox $This.ref_geodesique \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,ref_geodesique) \
         -values $list_combobox
      pack $This.ref_geodesique -in $This.frame16 -anchor w -side top -padx 10 -pady 5

      #--- Cree le bouton 'Mise a jour du format GPS'
      button $This.but_gps -text "$caption(confgene,position_miseajour_gps)" -borderwidth 2 \
         -command { ::confPosObs::Position }
      pack $This.but_gps -in $This.frame4 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

      #--- Systeme de coordonnees au format GPS
      label $This.lab6 -text "$caption(confgene,position_gps)"
      pack $This.lab6 -in $This.frame8 -anchor w -side top -padx 10 -pady 5

      label $This.lab7 -text "$conf(posobs,observateur,gps)"
      pack $This.lab7 -in $This.frame17 -anchor w -side left -padx 10 -pady 5

      #--- Cree le bouton 'GOTO' pour aller sur l'observatoire via Google Earth
      button $This.but_goto -text "$caption(confgene,position_goto_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::gotoObservatory }
      pack $This.but_goto -in $This.frame17 -anchor center -side left -padx 5 -pady 5 -ipadx 5

      #--- Numero station UAI
      label $This.lab8 -text "$caption(confgene,position_station_uai)"
      pack $This.lab8 -in $This.frame8 -anchor w -side top -padx 10 -pady 10

      entry $This.station_uai -textvariable confgene(posobs,station_uai) -width 6
      pack $This.station_uai -in $This.frame18 -anchor w -side left -padx 10 -pady 5

      #--- Cree le bouton 'Mise a jour des formats MPC'
      button $This.but_mpc -text "$caption(confgene,position_miseajour_mpc)" -borderwidth 2 \
         -command { ::confPosObs::MPC }
      pack $This.but_mpc -in $This.frame18 -anchor center -side left -padx 10 -pady 3 -ipadx 10 -ipady 5 -expand true

      #--- Fichier des stations UAI
      label $This.lab9 -text "$caption(confgene,position_fichier_station_uai)"
      pack $This.lab9 -in $This.frame8 -anchor w -side top -padx 10 -pady 10

      entry $This.fichier_station_uai -textvariable confgene(posobs,fichier_station_uai) -width 16
      pack $This.fichier_station_uai -in $This.frame19 -anchor w -side left -padx 10 -pady 5

      #--- Cree le bouton 'Mise a jour' du fichier des stations UAI
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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confPosObs::addObs
   # Ajout d'un observatoire dans la liste
   #
   proc addObs { } {
      ::confPosObs::config::run "add"
   }

   #
   # confPosObs::delObs
   # Suppression d'un observatoire dans la liste
   #
   proc delObs { } {
      ::confPosObs::config::run "del"
   }

   #
   # confPosObs::copyObs
   # Copie d'un observatoire de la liste
   #
   proc copyObs { } {
      ::confPosObs::config::run "copy"
   }

   #--- Namespace pour les fenetres de gestion des noms d'observatoire
   namespace eval ::confPosObs::config {

      #
      # confPosObs::config::run
      #--- Cree les fenetres de gestion des noms d'observatoire
      #
      proc run { action } {
         global audace confgene

         set confgene(action) "$action"
         ::confGenerique::run "1" "$audace(base).nameObsSetup" "::confPosObs::config" -modal 0
         set posx_config [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 1 ]
         set posy_config [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 2 ]
         wm geometry $audace(base).nameObsSetup +[ expr $posx_config + 0 ]+[ expr $posy_config + 150 ]
      }

      #
      # confPosObs::config::getLabel
      #--- Retourne le nom de la fenetre de configuration
      #
      proc getLabel { } {
         global caption

         return "$caption(confgene,nom_observatoire)"
      }

      #
      # confPosObs::config::apply
      #--- Fonction 'Appliquer' pour memoriser et appliquer la configuration
      #
      proc apply { visuNo } {
         global conf confgene

         if { $confgene(action) == "add" } {
            if { $confgene(posobs,new_nom_observatoire) != "" } {
               set confgene(posobs,nom_observatoire) "$confgene(posobs,new_nom_observatoire)"
               #--- Mettre a vide le numero UAI sinon ::MPC va changer les informations
               set confgene(posobs,station_uai)      ""
               #--- Fonction pour la mise a la forme MPC et MPCSTATION
               ::confPosObs::MPC
               #--- Fonction pour la mise a la forme GPS
               ::confPosObs::Position
            }
         } elseif { $confgene(action) == "del" } {
            if { $confgene(posobs,del_nom_observatoire) != "" } {
               set index "$confgene(index_del)"
               set conf(posobs,config_observatoire,$index) ""
               if { $conf(posobs,config_observatoire,[ expr $index + 1 ]) != "" } {
                  for {set i $index} {$i < 9 } {incr i } {
                     set conf(posobs,config_observatoire,$i) $conf(posobs,config_observatoire,[ expr $i + 1 ])
                  }
               }
               #--- Je recupere les attributs de la configuration
               array set config_observatoire $conf(posobs,config_observatoire,0)
               set confgene(posobs,del_nom_observatoire) $config_observatoire(nom_observatoire)
               #--- Je prepare les valeurs de la combobox de configuration des noms d'observatoire
               set confgene(posobs,nom_observatoire_liste) ""
               foreach {key value} [ array get conf posobs,config_observatoire,* ] {
                  if { "$value" == "" } continue
                  #--- Je mets les valeurs dans un array (de-serialisation)
                  array set config_observatoire $value
                  #--- Je prepare la ligne a afficher dans la combobox
                  set line "$config_observatoire(nom_observatoire) $config_observatoire(estouest) $config_observatoire(long) \
                     $config_observatoire(nordsud) $config_observatoire(lat) $config_observatoire(altitude) \
                     $config_observatoire(ref_geodesique) $config_observatoire(station_uai)"
                  #--- Je supprime la ligne
                  lappend confgene(posobs,nom_observatoire_liste) "$line"
               }
               #--- Je mets a jour les combobox
               $confgene(frm).config.nom_observatoire_a_supprimer configure -values $confgene(posobs,nom_observatoire_liste)
               ::confPosObs::majListComboBox
            }
         } elseif { $confgene(action) == "copy" } {
            if { $confgene(posobs,copy_nom_observatoire) != "" } {
               set index "$confgene(index_copy)"
               #--- Je recupere les attributs de la configuration
               array set config_observatoire $conf(posobs,config_observatoire,$index)
               #--- Je copie les valeurs dans les widgets de la configuration choisie
               set confgene(posobs,nom_observatoire) "$confgene(posobs,nom_observatoire_copie)"
               set confgene(posobs,estouest)         "$config_observatoire(estouest)"
               set confgene(posobs,long)             "$config_observatoire(long)"
               set confgene(posobs,nordsud)          "$config_observatoire(nordsud)"
               set confgene(posobs,lat)              "$config_observatoire(lat)"
               set confgene(posobs,altitude)         "$config_observatoire(altitude)"
               set confgene(posobs,ref_geodesique)   "$config_observatoire(ref_geodesique)"
               #--- Mettre a vide le numero UAI sinon ::MPC va changer les informations
               set confgene(posobs,station_uai)      ""
               #--- Fonction pour la mise a la forme MPC et MPCSTATION
               ::confPosObs::MPC
               #--- Fonction pour la mise a la forme GPS
               ::confPosObs::Position
            }
         }
      }

      #
      # confPosObs::config::closeWindow
      #--- Fonction appellee lors de l'appui sur le bouton 'Fermer'
      #
      proc closeWindow { visuNo } {
      }

      #
      # confPosObs::config::cbCommand
      # Affiche les valeurs dans les widgets pour la configuration choisie
      # (appelee par la combobox a chaque changement de selection)
      #
      proc cbCommand { cb } {
         global conf confgene

         #--- Je recupere l'index de l'element selectionne
         set index [ $cb getvalue ]
         if { "$index" == "" } {
            set index 0
         }

         #--- Je recupere les attributs de la configuration
         array set configuration_observatoire $conf(posobs,config_observatoire,$index)

         #--- Je copie les valeurs dans les widgets de la configuration choisie
         if { $confgene(action) == "del" } {
            set confgene(posobs,del_nom_observatoire) $configuration_observatoire(nom_observatoire)
            set confgene(index_del) "$index"
         } elseif { $confgene(action) == "copy" } {
            set confgene(posobs,copy_nom_observatoire) $configuration_observatoire(nom_observatoire)
            set confgene(index_copy) "$index"
         }
      }

      #
      # confPosObs::config::fillConfigPage
      #--- Creation de l'interface graphique
      #
      proc fillConfigPage { frm visuNo } {
         global caption confgene

         #--- Initialisation
         set confgene(frm)                           $frm
         set confgene(posobs,new_nom_observatoire)   ""
         set confgene(posobs,del_nom_observatoire)   "$confgene(posobs,nom_observatoire)"
         set confgene(posobs,copy_nom_observatoire)  "$confgene(posobs,nom_observatoire)"
         set confgene(posobs,nom_observatoire_copie) ""

         #--- Frame de la gestion des noms de configuration
         frame $frm.config -borderwidth 0 -relief raised

            if { $confgene(action) == "add" } {

               label $frm.config.lab1 -text $caption(confgene,observatoire_a_ajouter)
               pack $frm.config.lab1 -anchor nw -side left -padx 10 -pady 10

               entry $frm.config.nom_observatoire_a_ajouter -textvariable confgene(posobs,new_nom_observatoire) -width 42
               pack $frm.config.nom_observatoire_a_ajouter -anchor w -side left -padx 10 -pady 5

            } elseif { $confgene(action) == "del" } {

               label $frm.config.lab2 -text $caption(confgene,observatoire_a_supprimer)
               pack $frm.config.lab2 -anchor nw -side left -padx 10 -pady 10

               ComboBox $frm.config.nom_observatoire_a_supprimer \
                  -width 42         \
                  -height 10        \
                  -relief sunken    \
                  -borderwidth 2    \
                  -editable 0       \
                  -textvariable confgene(posobs,del_nom_observatoire) \
                  -modifycmd "::confPosObs::config::cbCommand $frm.config.nom_observatoire_a_supprimer" \
                  -values $confgene(posobs,nom_observatoire_liste)
               pack $frm.config.nom_observatoire_a_supprimer -anchor w -side right -padx 10 -pady 5

            } elseif { $confgene(action) == "copy" } {

               frame $frm.config.frame1 -borderwidth 0 -relief raised

                  label $frm.config.frame1.lab3 -text $caption(confgene,observatoire_a_copier)
                  pack $frm.config.frame1.lab3 -anchor nw -side left -padx 10 -pady 10

                  ComboBox $frm.config.frame1.nom_observatoire_a_copier \
                     -width 42         \
                     -height 10        \
                     -relief sunken    \
                     -borderwidth 2    \
                     -editable 0       \
                     -textvariable confgene(posobs,copy_nom_observatoire) \
                     -modifycmd "::confPosObs::config::cbCommand $frm.config.frame1.nom_observatoire_a_copier" \
                     -values $confgene(posobs,nom_observatoire_liste)
                  pack $frm.config.frame1.nom_observatoire_a_copier -anchor w -side right -padx 10 -pady 5

               pack $frm.config.frame1 -side top -fill both -expand 1

               frame $frm.config.frame2 -borderwidth 0 -relief raised

                  label $frm.config.frame2.lab4 -text $caption(confgene,nom_observatoire)
                  pack $frm.config.frame2.lab4 -anchor nw -side left -padx 10 -pady 10

                  entry $frm.config.frame2.nom_observatoire_copie -textvariable confgene(posobs,nom_observatoire_copie) -width 42
                  pack $frm.config.frame2.nom_observatoire_copie -anchor w -side left -padx 10 -pady 5

               pack $frm.config.frame2 -side top -fill both -expand 1

            }

         pack $frm.config -side top -fill both -expand 1
      }

   }

   #
   # confPosObs::gotoObservatory
   # GOTO vers l'observatoire via Google Earth
   #
   proc gotoObservatory { } {
      global audace

      google_earth_home_goto $audace(posobs,observateur,gps)
   }

   #
   # confPosObs::MaJ
   # Creation de l'interface pour la mise a jour du fichier des observatoires
   #
   proc MaJ { } {
      variable This
      global audace caption confgene

      #--- Chargement du package http
      package require http

      #--- Gestion du bouton de Mise a jour
      $This.but_maj configure -relief groove -state disabled

      #--- Adresse web du catalogue des observatoires UAI
      set url "http://www.minorplanetcenter.net/iau/lists/ObsCodes.html"

      #--- Lecture du catalogue en ligne
      set err [ catch { ::http::geturl $url } token ]
      if { $err == 0 } {
         upvar #0 $token state
         set html_text [ split $state(body) \n ]
         set lignes ""
         foreach ligne $html_text {
            if { [ string length $ligne ] < 10 } {
               continue
            }
            #--- Traitement des lignes sans espace entre les donnees
            if { [ string range $ligne 13 13 ] != " " } {
               set b [ string replace $ligne 30 30 " [ string range $ligne 30 30 ]" ]
               set c [ string replace $b 21 21 " [ string range $b 21 21 ]" ]
               set ligne [ string replace $c 13 13 " [ string range $c 13 13 ]" ]
            }
            append lignes "$ligne\n"
         }
         #--- Mise a jour du catalogue sur le disque dur
         set mpcfile [ file join $audace(rep_home) $confgene(posobs,fichier_station_uai) ]
         set f [ open $mpcfile w ]
         puts -nonewline $f $lignes
         close $f
      } else {
         #--- Erreur de connexion a Internet
         tk_messageBox -title "$caption(confgene,position_miseajour)" -type ok \
            -message "$caption(confgene,fichier_uai_msg)" -icon error
      }

      #--- Gestion du bouton de Mise a jour
      $This.but_maj configure -relief raised -state normal
   }

   #
   # confPosObs::Erreur
   # Creation de l'interface graphique pour signifier une erreur
   #
   proc Erreur { } {
      global audace caption

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
      pack $audace(base).erreur.lab1 -padx 10 -pady 2
      label $audace(base).erreur.lab2 -text "$caption(confgene,fichier_uai_erreur2)"
      pack $audace(base).erreur.lab2 -padx 10 -pady 2
      label $audace(base).erreur.lab3 -text "$caption(confgene,fichier_uai_erreur3)"
      pack $audace(base).erreur.lab3 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).erreur

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).erreur
   }

   #
   # confPosObs::Position
   # Fonction pour la mise a la forme GPS
   #
   proc Position { } {
      variable This
      global caption confgene

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
   # confPosObs::MPC
   # Fonction pour la mise a la forme MPC et MPCSTATION
   #
   proc MPC { } {
      variable This
      global audace caption color confgene

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
         set f [open [file join $audace(rep_home) $confgene(posobs,fichier_station_uai)] r]
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
               #--- Formatage du nom de l'observatoire (c'est une textvariable)
               set nom ""
               for {set i 4} {$i <= [ llength $ligne_station_mpc ]} {incr i} {
                  set nom "$nom[lindex $ligne_station_mpc $i] "
               }
               set confgene(posobs,nom_observatoire) "$nom"
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
   # confPosObs::cbCommand
   # (appelee par la combobox a chaque changement de selection)
   # Affiche les valeurs dans les widgets pour la configuration choisie
   #
   proc cbCommand { cb } {
      global conf confgene

      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration
      array set config_observatoire $conf(posobs,config_observatoire,$index)

      #--- Je copie les valeurs dans les widgets de la configuration choisie
      set confgene(posobs,nom_observatoire) $config_observatoire(nom_observatoire)
      set confgene(posobs,estouest)         $config_observatoire(estouest)
      set confgene(posobs,long)             $config_observatoire(long)
      set confgene(posobs,nordsud)          $config_observatoire(nordsud)
      set confgene(posobs,lat)              $config_observatoire(lat)
      set confgene(posobs,altitude)         $config_observatoire(altitude)
      set confgene(posobs,ref_geodesique)   $config_observatoire(ref_geodesique)
      set confgene(posobs,station_uai)      $config_observatoire(station_uai)

      #--- Fonction pour la mise a la forme MPC et MPCSTATION
      ::confPosObs::MPC

      #--- Fonction pour la mise a la forme GPS
      ::confPosObs::Position
   }

   #
   # confPosObs::confToWidget
   # Copie les parametres du tableau conf() dans les variables des widgets
   #
   proc confToWidget { } {
      global conf confgene

      #--- confToWidget
      set confgene(posobs,nom_organisation)        $conf(posobs,nom_organisation)
      set confgene(posobs,nom_observateur)         $conf(posobs,nom_observateur)
      set confgene(posobs,nom_observatoire)        $conf(posobs,nom_observatoire)
      set confgene(posobs,estouest)                $conf(posobs,estouest)
      set confgene(posobs,long)                    $conf(posobs,long)
      set confgene(posobs,nordsud)                 $conf(posobs,nordsud)
      set confgene(posobs,lat)                     $conf(posobs,lat)
      set confgene(posobs,altitude)                $conf(posobs,altitude)
      set confgene(posobs,ref_geodesique)          $conf(posobs,ref_geodesique)
      set confgene(posobs,observateur,gps)         $conf(posobs,observateur,gps)
      set confgene(posobs,station_uai)             $conf(posobs,station_uai)
      set confgene(posobs,fichier_station_uai)     $conf(posobs,fichier_station_uai)
      set confgene(posobs,observateur,mpc)         $conf(posobs,observateur,mpc)
      set confgene(posobs,observateur,mpcstation)  $conf(posobs,observateur,mpcstation)

      #--- Je prepare les valeurs de la combobox de configuration des noms d'observatoire
      set confgene(posobs,nom_observatoire_liste) ""
      foreach {key value} [ array get conf posobs,config_observatoire,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set config_observatoire $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$config_observatoire(nom_observatoire) $config_observatoire(estouest) $config_observatoire(long) \
            $config_observatoire(nordsud) $config_observatoire(lat) $config_observatoire(altitude) \
            $config_observatoire(ref_geodesique) $config_observatoire(station_uai)"
         #--- J'ajoute la ligne
         lappend confgene(posobs,nom_observatoire_liste) "$line"
      }
   }

   #
   # confPosObs::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global audace conf confgene

      #--- J'ajoute l'observatoire en tete dans le tableau des observatoires precedents s'il n'y est pas deja
      array set config_observatoire { }
      set config_observatoire(nom_observatoire) [ string trimright $confgene(posobs,nom_observatoire) " " ]
      set config_observatoire(estouest)         $confgene(posobs,estouest)
      set config_observatoire(long)             $confgene(posobs,long)
      set config_observatoire(nordsud)          $confgene(posobs,nordsud)
      set config_observatoire(lat)              $confgene(posobs,lat)
      set config_observatoire(altitude)         $confgene(posobs,altitude)
      set config_observatoire(ref_geodesique)   $confgene(posobs,ref_geodesique)
      set config_observatoire(station_uai)      $confgene(posobs,station_uai)

      #--- Je copie conf dans templist en mettant l'observatoire courant en premier
      array set templist { }
      set templist(0) [ array get config_observatoire ]
      set j "1"
      foreach {key value} [ array get conf posobs,config_observatoire,* ] {
         if { "$value" == "" } {
            set templist($j) ""
            incr j
         } else {
            array set temp1 $value
            if { "$temp1(nom_observatoire)" != "$config_observatoire(nom_observatoire)" } {
               set templist($j) [ array get temp1 ]
               incr j
            }
         }
      }

      #--- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(posobs,config_observatoire,$i) $templist($i)
      }

      #--- Je mets a jour les valeurs dans la combobox
      set confgene(posobs,nom_observatoire_liste) ""
      foreach {key value} [ array get conf posobs,config_observatoire,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set config_observatoire $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$config_observatoire(nom_observatoire) $config_observatoire(estouest) $config_observatoire(long) \
            $config_observatoire(nordsud) $config_observatoire(lat) $config_observatoire(altitude) \
            $config_observatoire(ref_geodesique) $config_observatoire(station_uai)"
         #--- J'ajoute la ligne
         lappend confgene(posobs,nom_observatoire_liste) "$line"
      }
      $This.nom_observatoire configure -values $confgene(posobs,nom_observatoire_liste)

      #---
      set conf(posobs,nom_organisation)       $confgene(posobs,nom_organisation)
      set conf(posobs,nom_observateur)        $confgene(posobs,nom_observateur)
      set conf(posobs,nom_observatoire)       [ string trimright $confgene(posobs,nom_observatoire) " " ]
      set conf(posobs,estouest)               $confgene(posobs,estouest)
      set conf(posobs,long)                   $confgene(posobs,long)
      set conf(posobs,nordsud)                $confgene(posobs,nordsud)
      set conf(posobs,lat)                    $confgene(posobs,lat)
      set conf(posobs,altitude)               $confgene(posobs,altitude)
      set conf(posobs,ref_geodesique)         $confgene(posobs,ref_geodesique)
      set conf(posobs,observateur,gps)        $confgene(posobs,observateur,gps)
      set conf(posobs,fichier_station_uai)    $confgene(posobs,fichier_station_uai)
      set conf(posobs,station_uai)            $confgene(posobs,station_uai)
      set conf(posobs,observateur,mpc)        $confgene(posobs,observateur,mpc)
      set conf(posobs,observateur,mpcstation) $confgene(posobs,observateur,mpcstation)

      #---
      set audace(posobs,observateur,gps)      $conf(posobs,observateur,gps)

      #--- Concatenation de variables pour l'en-tete FITS
      set conf(posobs,estouest_long)          $conf(posobs,estouest)$conf(posobs,long)
      set conf(posobs,nordsud_lat)            $conf(posobs,nordsud)$conf(posobs,lat)
   }

   #
   # confPosObs::majListComboBox
   # Mise a jour de la liste de la combobox des observatoires
   #
   proc majListComboBox { } {
      variable This
      global audace conf confgene

      #--- Je configure la combobox des observatoires
      $This.nom_observatoire configure -values $confgene(posobs,nom_observatoire_liste)
      #--- Cas particulier du premier de la liste
      if { $confgene(index_del) == "0" } {
         #--- Je recupere le nouvel index 0
         set index 0
         #--- Je recupere les attributs de la configuration
         array set config_observatoire $conf(posobs,config_observatoire,$index)
         #--- Je copie les valeurs dans les widgets de la configuration choisie
         set confgene(posobs,nom_observatoire) $config_observatoire(nom_observatoire)
         set confgene(posobs,estouest)         $config_observatoire(estouest)
         set confgene(posobs,long)             $config_observatoire(long)
         set confgene(posobs,nordsud)          $config_observatoire(nordsud)
         set confgene(posobs,lat)              $config_observatoire(lat)
         set confgene(posobs,altitude)         $config_observatoire(altitude)
         set confgene(posobs,ref_geodesique)   $config_observatoire(ref_geodesique)
         set confgene(posobs,station_uai)      $config_observatoire(station_uai)
         #--- Fonction pour la mise a la forme MPC et MPCSTATION
         ::confPosObs::MPC
         #--- Fonction pour la mise a la forme GPS
         ::confPosObs::Position
         #--- Je copie les valeurs dans les variables de configuration
         set conf(posobs,nom_observatoire)       $confgene(posobs,nom_observatoire)
         set conf(posobs,estouest)               $confgene(posobs,estouest)
         set conf(posobs,long)                   $confgene(posobs,long)
         set conf(posobs,nordsud)                $confgene(posobs,nordsud)
         set conf(posobs,lat)                    $confgene(posobs,lat)
         set conf(posobs,altitude)               $confgene(posobs,altitude)
         set conf(posobs,ref_geodesique)         $confgene(posobs,ref_geodesique)
         set conf(posobs,observateur,gps)        $confgene(posobs,observateur,gps)
         set conf(posobs,station_uai)            $confgene(posobs,station_uai)
         set conf(posobs,observateur,mpc)        $confgene(posobs,observateur,mpc)
         set conf(posobs,observateur,mpcstation) $confgene(posobs,observateur,mpcstation)
         #---
         set audace(posobs,observateur,gps)      $conf(posobs,observateur,gps)
         #--- Concatenation de variables pour l'en-tete FITS
         set conf(posobs,estouest_long)          $conf(posobs,estouest)$conf(posobs,long)
         set conf(posobs,nordsud_lat)            $conf(posobs,nordsud)$conf(posobs,lat)
      }
   }

   #
   # confPosObs::addPosObsListener
   # Ajoute une procedure a appeler si on change un parametre
   #
   proc addPosObsListener { cmd } {
      trace add variable "::conf(posobs,nom_organisation)" write $cmd
      trace add variable "::conf(posobs,nom_observateur)" write $cmd
      trace add variable "::conf(posobs,nom_observatoire)" write $cmd
   }

   #
   # confPosObs::removePosObsListener
   # Supprime une procedure a appeler si on change un parametre
   #
   proc removePosObsListener { cmd } {
      trace remove variable "::conf(posobs,nom_observatoire)" write $cmd
      trace remove variable "::conf(posobs,nom_observateur)" write $cmd
      trace remove variable "::conf(posobs,nom_organisation)" write $cmd
   }
}

#
# Temps
# Description : Configuration du temps (heure systeme ou TU)
#

namespace eval ::confTemps {

   #
   # confTemps::run this
   # Cree la fenetre de configuration du temps
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
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

      destroy $This
   }

   proc createDialog { } {
      variable This
      global audace caption conf confgene

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
      pack $This.frame4 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame3 -side left -fill both -expand 1

      #--- Temps sideral local
      label $This.lab1 -text "$caption(confgene,temps_tsl)"
      pack $This.lab1 -in $This.frame4 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab2 -borderwidth 1 -textvariable "audace(tsl,format,hmsint)" -width 12 -anchor w
      pack $This.lab2 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      #--- Temps universel
      label $This.lab3 -text "$caption(confgene,temps_tu)"
      pack $This.lab3 -in $This.frame4 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab4 -borderwidth 1 -textvariable "audace(tu,format,hmsint)" -width 12 -anchor w
      pack $This.lab4 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      #--- Temps local
      label $This.lab5 -text "$caption(confgene,temps_hl)"
      pack $This.lab5 -in $This.frame4 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab6 -borderwidth 1 -textvariable "audace(hl,format,hmsint)" -width 12 -anchor w
      pack $This.lab6 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

#
# FichierIma
# Description : Configuration des fichiers image
#

namespace eval ::confFichierIma {

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
      global audace confgene

      #--- Mises a jour pour tous les buffers disponibles
      foreach visuNo [ ::visu::list ] {
         set bufNo [ visu$visuNo buf ]
         #--- Extension par defaut associee au buffer
         buf$bufNo extension $confgene(extension,new)
         #--- Fichiers FITS compresses ou non
         if { $confgene(fichier,compres) == "0" } {
            buf$bufNo compress "none"
         } else {
            buf$bufNo compress "gzip"
         }
         #--- Format des fichiers image (entier ou flottant)
         if { $confgene(fichier,format) == "0" } {
            buf$bufNo bitpix ushort
         } else {
            buf$bufNo bitpix float
         }
      }

      #--- Mise a jour des widgets
      $This.labURL2 configure -text "$confgene(extension,new)"
      $This.labURL5 configure -text "$confgene(jpegquality,new)"

      #--- Mise a jour de la liste des extensions
      set listExtensionFile ""
      if { ( $confgene(extension,new) != ".fit" ) && ( $confgene(extension,new) != ".fts" ) &&
         ( $confgene(extension,new) != ".fits" ) } {
         set listExtensionFile "$confgene(extension,new) $confgene(extension,new).gz"
      }
      set listExtensionFile "$listExtensionFile .fit .fit.gz .fts .fts.gz .fits .fits.gz .jpg"
      set confgene(fichier,list_extension) $listExtensionFile

      #--- Sauvegarde de la configuration
      widgetToConf
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

      #--- Initialisation indispensable de 3 variables dans aud.tcl (::audace::loadSetup)
      if { ! [ info exists conf(save_seuils_visu) ] }          { set conf(save_seuils_visu)          "1" }
      if { ! [ info exists conf(format_fichier_image) ] }      { set conf(format_fichier_image)      "0" }
      if { ! [ info exists conf(extension,defaut) ] }          { set conf(extension,defaut)          ".fit" }
      if { ! [ info exists conf(fichier,compres) ] }           { set conf(fichier,compres)           "0" }
      if { ! [ info exists conf(jpegquality,defaut) ] }        { set conf(jpegquality,defaut)        "80" }
      #--- Initialisation de la liste des extensions
      set ::audace(extensionList) ".fit .fit.gz .fts .fts.gz .fits .fits.gz .jpg"
      #--- Compatibilite avec les versions anterieures
      if { [ info exists conf(list_extension) ] }              { unset conf(list_extension) }
      #--- Recopie de variables
      set conf(extension,new)   $conf(extension,defaut)
      set conf(jpegquality,new) $conf(jpegquality,defaut)
   }

   proc createDialog { } {
      variable This
      global audace caption color conf confgene

      #--- confToWidget
      set confgene(fichier,save_seuils_visu)          $conf(save_seuils_visu)
      set confgene(fichier,format)                    $conf(format_fichier_image)
      set confgene(extension,new)                     $conf(extension,new)
      set confgene(fichier,compres)                   $conf(fichier,compres)
      set confgene(jpegquality,new)                   $conf(jpegquality,new)
      set confgene(fichier,list_extension)            $::audace(extensionList)

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

      TitleFrame $This.frame3 -borderwidth 2 -relief ridge -text "$caption(confgene,fichier_image_fits)"
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1 -padx 2 -pady 2

      TitleFrame $This.frame4 -borderwidth 2 -relief ridge -text "$caption(confgene,fichier_image_jpg)"
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1 -padx 2 -pady 2

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame6 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame6 -side left -fill both -expand 1

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame10 -borderwidth 0 -relief raised
      pack $This.frame10 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame11 -borderwidth 0 -relief raised
      pack $This.frame11 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame12 -borderwidth 0 -relief raised
      pack $This.frame12 -in [ $This.frame4 getframe ] -side top -fill both -expand 1

      frame $This.frame13 -borderwidth 0 -relief raised
      pack $This.frame13 -in [ $This.frame4 getframe ] -side top -fill both -expand 1

      frame $This.frame14 -borderwidth 0 -relief raised
      pack $This.frame14 -in [ $This.frame4 getframe ] -side top -fill both -expand 1

      #--- Enregistrer une image en conservant ou non les seuils de la visu
      checkbutton $This.save_seuils_visu -text "$caption(confgene,fichier_images_seuils_visu)" \
         -highlightthickness 0 -variable confgene(fichier,save_seuils_visu)
      pack $This.save_seuils_visu -in $This.frame5 -anchor center -side left -padx 10 -pady 5

      #--- Enregistrer une image en choisissant le format
      label $This.lab2 -text "$caption(confgene,fichier_images_choix_format)"
      pack $This.lab2 -in $This.frame7 -anchor ne -side left -padx 10 -pady 5

      #--- Radio-bouton pour le format entier
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 \
         -text "$caption(confgene,fichier_images_entier)" -value 0 -variable confgene(fichier,format)
      pack $This.rad1 -in $This.frame8 -anchor w -side top -padx 5 -pady 5

      #--- Radio-bouton pour le format flottant
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 \
         -text "$caption(confgene,fichier_images_flottant)" -value 1 -variable confgene(fichier,format)
      pack $This.rad2 -in $This.frame8 -anchor w -side top -padx 5 -pady 5

      #--- Rappelle l'extension par defaut des fichiers image
      label $This.lab1 -text "$caption(confgene,fichier_image_ext_defaut)"
      pack $This.lab1 -in $This.frame9 -anchor center -side left -padx 10 -pady 5

      label $This.labURL2 -text "$conf(extension,defaut)" -fg $color(blue)
      pack $This.labURL2 -in $This.frame9 -anchor center -side right -padx 20 -pady 5

      #--- Cree la zone a renseigner de la nouvelle extension par defaut
      label $This.lab3 -text "$caption(confgene,fichier_image_new_ext)"
      pack $This.lab3 -in $This.frame10 -anchor center -side left -padx 10 -pady 5

      entry $This.newext -textvariable confgene(extension,new) -width 5 -justify center \
         -validate all -validatecommand { ::confFichierIma::extensionProhibited %W %V %P %s extension } \
         -invcmd bell
      pack $This.newext -in $This.frame10 -anchor center -side right -padx 10 -pady 5

      #--- Ouvre le choix aux fichiers compresses
      checkbutton $This.compress -text "$caption(confgene,fichier_image_compres)" \
         -highlightthickness 0 -variable confgene(fichier,compres)
      pack $This.compress -in $This.frame11 -anchor center -side left -padx 10 -pady 5

      #--- Rappelle le taux de qualite d'enregistrement par defaut des fichiers Jpeg
      label $This.lab4 -text "$caption(confgene,fichier_image_jpeg_quality)"
      pack $This.lab4 -in $This.frame12 -anchor center -side left -padx 10 -pady 5

      label $This.labURL5 -text "$conf(jpegquality,defaut)" -fg $color(blue)
      pack $This.labURL5 -in $This.frame12 -anchor center -side right -padx 20 -pady 5

      #--- Cree la glissiere de reglage pour la nouvelle valeur de qualite par defaut
      label $This.lab6 -text "$caption(confgene,fichier_image_jpeg_newquality)"
      pack $This.lab6 -in $This.frame13 -anchor center -side left -padx 10 -pady 5

      scale $This.efficacite_variant -from 5 -to 100 -length 300 -orient horizontal \
         -showvalue true -tickinterval 10 -resolution 1 -borderwidth 2 -relief groove \
         -variable confgene(jpegquality,new) -width 10
      pack $This.efficacite_variant -in $This.frame14 -side top -padx 10 -pady 5

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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confFichierIma::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(save_seuils_visu)          $confgene(fichier,save_seuils_visu)
      set conf(format_fichier_image)      $confgene(fichier,format)
      set conf(extension,defaut)          $confgene(extension,new)
      set conf(extension,new)             $confgene(extension,new)
      set conf(fichier,compres)           $confgene(fichier,compres)
      set conf(jpegquality,defaut)        $confgene(jpegquality,new)
      set conf(jpegquality,new)           $confgene(jpegquality,new)
      set ::audace(extensionList)         $confgene(fichier,list_extension)
   }

   #
   # confFichierIma::extensionProhibited
   # Controle la saisie au clavier de la nouvelle extension FITS
   #
   proc extensionProhibited { win event newValue oldValue class { errorVariable "" } } {
      set result 0
      if { $event == "key" || $event == "focusout" || $event == "forced" } {
         set ctrl [ string range $newValue 0 0 ]
         if { $ctrl == "." } {
            set result 1
            if {  ( $newValue == ".crw" ) || ( $newValue == ".CRW" ) \
               || ( $newValue == ".cr2" ) || ( $newValue == ".CR2" ) \
               || ( $newValue == ".nef" ) || ( $newValue == ".NEF" ) \
               || ( $newValue == ".dng" ) || ( $newValue == ".DNG" ) \
               || ( $newValue == ".jpg" ) || ( $newValue == ".jpeg" ) \
               || ( $newValue == ".bmp" ) || ( $newValue == ".gif" ) \
               || ( $newValue == ".tif" ) || ( $newValue == ".tiff" ) \
               || ( $newValue == ".png" ) || ( $newValue == ".ps" ) \
               || ( $newValue == ".pdf" ) || ( $newValue == ".txt" ) \
               || ( $newValue == ".htm" ) || ( $newValue == ".html" ) \
               || ( $newValue == ".tcl" ) || ( $newValue == ".cap" ) \
               || ( $newValue == ".jar" ) } {
               set result 0
            } else {
               set result 1
            }
         } else {
            set result 0
         }
         if { $result == 1 } {
            #--- j'accepte cette nouvelle extension
           ### $win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
         } else {
            #--- je refuse cette nouvelle extension
           ### $win configure -bg $::color(lightred) -fg $::color(red)
            bell
         }
      } else {
         #--- je ne traite pas l'evenement
         set result 1
      }
      return $result
   }
}

#
# AlarmeFinPose
# Description : Configuration de l'alarme de fin de pose
#

namespace eval ::confAlarmeFinPose {

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
      global conf confgene

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
      global caption conf confgene

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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confAlarmeFinPose::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(acq,bell)      $confgene(alarme,delai)
      set conf(alarme,active) $confgene(alarme,active)
   }
}

#
# confChoixOutil
# Description : Choisir les plugins a afficher dans les menus
#

namespace eval ::confChoixOutil {

   #
   # confChoixOutil::run this visuNo
   # Cree la fenetre de configuration du choix des plugins a afficher dans les menus
   # this = chemin de la fenetre
   #
   proc run { this visuNo } {
      variable This

      set This $this
      createDialog $visuNo
      tkwait visibility $This
   }

   #
   # confChoixOutil::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre du choix des plugins a afficher dans les menus
   #
   proc ok { visuNo } {
      appliquer $visuNo
      fermer
   }

   #
   # confChoixOutil::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration sur toutes les visu
   #
   proc appliquer { visuNo } {
      variable private
      global conf panneau

      set conf(outilsActifsInactifs) ""
      foreach m [array names panneau menu_name,*] {
         set namespace [ lindex [ split $m "," ] 1 ]
         if { $private(affiche,$namespace) == "1" } {
            #--- Outils actifs
            lappend conf(outilsActifsInactifs) $namespace [ list 1 $private(raccourci,$namespace) ]
         } else {
            #--- Outils inactifs
            lappend conf(outilsActifsInactifs) $namespace [ list 0 $private(raccourci,$namespace) ]
         }
      }
      #--- Rafraichissement des menus contenant des outils
      ::confVisu::refreshMenu $visuNo
   }

   #
   # confChoixOutil::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config+)" "1010choix_outil.htm"
   }

   #
   # confChoixOutil::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # confChoixOutil::ordreMenuDeroulant
   # Tri dans l'ordre d'affichage des menus deroulants dans la barre des menus
   #
   proc ordreMenuDeroulant { m } {
      set nomMenu [ ::[ string trimleft [ string trimleft $m "menu_name" ] "," ]\::getPluginProperty function ]
      if { $nomMenu == "file" } {
         set rangMenu 1
      } elseif { $nomMenu == "display" } {
         set rangMenu 2
      } elseif { $nomMenu == "images" } {
         set rangMenu 3
      } elseif { $nomMenu == "analysis" } {
         set rangMenu 4
      } elseif { $nomMenu == "acquisition" } {
         set rangMenu 5
      } elseif { $nomMenu == "aiming" } {
         set rangMenu 6
      } elseif { $nomMenu == "setup" } {
         set rangMenu 7
      }
      return $rangMenu
   }

   proc createDialog { visuNo } {
      variable This
      variable private
      global caption color conf panneau

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
      set num   "0"
      set liste ""

      #--- Cree le frame pour les commentaires
      label $This.lab1 -text "$caption(confgene,choix_outils_1)"
      pack $This.lab1 -in $This.frame1 -side top -fill both -expand 1 -padx 5 -pady 8

      #--- Ouvre le choix a l'affichage ou non des plugins dans les menus
      foreach m [array names panneau menu_name,*] {
         lappend liste [ list [ ::confChoixOutil::ordreMenuDeroulant $m ] "$panneau($m) " $m ]
      }
      #--- Longueur de la liste
      set longList [ llength $liste ]
      #--- Nombre de lignes dans la fenetre
      set a [ expr $longList / 2.0 ]
      set b [ expr int($a) ]
      set c [ expr $a - $b ]
      if { $c == 0 } {
         set nblignes $b
      } else {
         set nblignes [ expr $b + 1 ]
      }
      #--- Je copie la liste dans un tableau affiche(namespace)
      array set affiche $conf(outilsActifsInactifs)
      #---
      foreach m [lsort -dictionary $liste] {
         set namespace [lindex [lindex [ split $m "," ] 1] 0]
         set num [expr $num + 1]
         if { [ info exist affiche($namespace) ] } {
            set private(affiche,$namespace)   [ lindex $affiche($namespace) 0 ]
            set private(raccourci,$namespace) [ lindex $affiche($namespace) 1 ]
         } else {
            set private(affiche,$namespace)   1
            set private(raccourci,$namespace) ""
         }
         #--- Affichage des noms des plugins a gauche, puis a droite, ...
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
         if { $num <= $nblignes } {
            frame $This.framea$num -borderwidth 0
               #--- Selection d'un plugin a afficher et du menu deroulant d'appartenance
               set function [ ::$namespace\::getPluginProperty function ]
               checkbutton $This.panneau$num -text "($caption(audace,menu,$function))   $panneau(menu_name,$namespace)" \
               -highlightthickness 0 -variable ::confChoixOutil::private(affiche,$namespace)
               pack $This.panneau$num -in $This.framea$num -side left -padx 5 -pady 0
               #--- Selection d'un raccourci
               set hauteur [llength $list_combobox]
               if { $hauteur > "5" } {
                  set hauteur "5"
               }
               ComboBox $This.raccourci$num \
                  -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
                  -height $hauteur  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable ::confChoixOutil::private(raccourci,$namespace) \
                  -values $list_combobox
               pack $This.raccourci$num -in $This.framea$num -side right -padx 5 -pady 0
            pack $This.framea$num -in $This.frame5 -side top -fill x -expand 0
         } else {
            frame $This.frameb$num -borderwidth 0
               #--- Selection d'un plugin a afficher et du menu deroulant d'appartenance
               set function [ ::$namespace\::getPluginProperty function ]
               checkbutton $This.panneau$num -text "($caption(audace,menu,$function))   $panneau(menu_name,$namespace)" \
                  -highlightthickness 0 -variable ::confChoixOutil::private(affiche,$namespace)
               pack $This.panneau$num -in $This.frameb$num -side left -padx 5 -pady 0
               #--- Selection d'un raccourci
               ComboBox $This.raccourci$num \
                  -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
                  -height $hauteur  \
                  -relief sunken    \
                  -borderwidth 1    \
                  -editable 0       \
                  -textvariable ::confChoixOutil::private(raccourci,$namespace) \
                  -values $list_combobox
               pack $This.raccourci$num -in $This.frameb$num -side right -padx 5 -pady 0
            pack $This.frameb$num -in $This.frame6 -side top -fill x -expand 0
         }
      }

      #--- Cree le frame pour les commentaires
      label $This.labURL3 -text "$caption(confgene,choix_outils_2)" -fg $color(red)
      pack $This.labURL3 -in $This.frame3 -side bottom -fill both -expand 1 -padx 5 -pady 2

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command "::confChoixOutil::ok $visuNo"
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command "::confChoixOutil::appliquer $visuNo"
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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

#
# TypeFenetre
# Description : Configuration du type de fenetre du menu 'Reglages'
#

namespace eval ::confTypeFenetre {

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
      ::audace::showHelpItem "$help(dir,config)" "1080type_fenetre.htm"
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
      global caption conf confgene

      #--- Initialisation indispensable de la variable du type de fenetre dans aud.tcl (::audace::loadSetup)
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
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -value 0 \
         -variable confgene(TypeFenetre,ok+appliquer)
      pack $This.rad1 -in $This.frame3 -anchor center -side top -fill x -padx 5 -pady 5
      #--- Type Appliquer + Annuler
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -value 1 \
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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confTypeFenetre::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(ok+appliquer) $confgene(TypeFenetre,ok+appliquer)
   }
}

#
# Langage
# Description : Configuration pour le choix des langues
#

namespace eval ::confLangue {

   #
   # confLangue::run this
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
   # confLangue::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      for { set i 1 } { $i < 8 } { incr i } {
         image delete imageflag$i
      }
      destroy $This
   }

   #
   # confLangue::afficheAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1010langue.htm"
   }

   proc createDialog { } {
      variable This
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
      wm title $This $caption(confgene,langue_titre)

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

      #--- Cree le label pour le commentaire
      label $This.lab1 -text "$caption(confgene,langue_selection)"
      pack $This.lab1 -in $This.frame3 -side top -anchor w -padx 5 -pady 5

      #--- Drapeau French
      image create photo imageflag1
      imageflag1 configure -file [ file join $::audela_start_dir fr.gif ] -format gif
      button $This.french -image imageflag1 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue french }
      pack $This.french -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Italian
      image create photo imageflag2
      imageflag2 configure -file [ file join $::audela_start_dir it.gif ] -format gif
      button $This.italian -image imageflag2 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue italian }
      pack $This.italian -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Spanish
      image create photo imageflag3
      imageflag3 configure -file [ file join $::audela_start_dir sp.gif ] -format gif
      button $This.spanish -image imageflag3 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue spanish }
      pack $This.spanish -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau German
      image create photo imageflag4
      imageflag4 configure -file [ file join $::audela_start_dir de.gif ] -format gif
      button $This.german -image imageflag4 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue german }
      pack $This.german -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Portuguese
      image create photo imageflag5
      imageflag5 configure -file [ file join $::audela_start_dir pt.gif ] -format gif
      button $This.portuguese -image imageflag5 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue portuguese }
      pack $This.portuguese -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Danish
      image create photo imageflag6
      imageflag6 configure -file [ file join $::audela_start_dir da.gif ] -format gif
      button $This.danish -image imageflag6 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue danish }
      pack $This.danish -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Ukrainian
      image create photo imageflag7
      imageflag7 configure -file [ file join $::audela_start_dir ua.gif ] -format gif
      button $This.ukrainian -image imageflag7 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue ukrainian }
      pack $This.ukrainian -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Russian
      image create photo imageflag8
      imageflag8 configure -file [ file join $::audela_start_dir ru.gif ] -format gif
      button $This.russian -image imageflag8 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue russian }
      pack $This.russian -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau English
      image create photo imageflag9
      imageflag9 configure -file [ file join $::audela_start_dir gb.gif ] -format gif
      button $This.english -image imageflag9 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue english }
      pack $This.english -in $This.frame4 -side left -padx 5 -pady 5

      #--- Visualise la langue pre-selectionnee
      $This.$::langage configure -borderwidth 3

      #--- Cree le label pour le commentaire
      label $This.lab2 -text "$caption(confgene,langue_texte)"
      pack $This.lab2 -in $This.frame5 -side top -anchor w -padx 5 -pady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confLangue::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confLangue::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confLangue::choisirLangue
   # Selectionner un drapeau pour changer de langue
   #
   proc choisirLangue { langue } {
      variable This
      global audace caption

      #--- Mise a jour du drapeau selectionne et de la langue
      $This.$::langage configure -borderwidth 0
      set ::langage $langue
      $This.$langue configure -borderwidth 3
      set f [open [ file join $::audace(rep_home) langage.ini ] w]
      puts $f "set langage \"$langue\""
      close $f

      #--- Recharge confgene.cap pour que les textes soient dans la langue du drapeau selectionne
      source [ file join $audace(rep_caption) confgene.cap ]

      #--- Mise a jour des textes de la fenetre
      wm title $This $caption(confgene,langue_titre)
      $This.lab1 configure -text "$caption(confgene,langue_selection)"
      $This.lab2 configure -text "$caption(confgene,langue_texte)"

      #--- Mise a jour des boutons de la fenetre
      .audace.confLangue.but_fermer configure -text "$caption(confgene,fermer)"
      .audace.confLangue.but_aide configure -text "$caption(confgene,aide)" -state disabled
   }
}

#
# Version
# Description : Version du logiciel
#

namespace eval ::confVersion {

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
      global audela caption color

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
      label $This.lab1 -text "[ ::audela::getPluginTitle ] $audela(version)"
      pack $This.lab1 -in $This.frame1 -padx 30 -pady 2

      #--- Version Tcl/Tk utilisee
      if { $::tcl_platform(threaded) == "1" } {
         label $This.lab2 -text "$caption(en-tete,a_propos_de_version_Tcl/Tk)[ info patchlevel ] multithread"
      } else {
         label $This.lab2 -text "$caption(en-tete,a_propos_de_version_Tcl/Tk)[ info patchlevel ]"
      }
      pack $This.lab2 -in $This.frame1 -padx 30 -pady 2

      #--- Date de la mise a jour
      label $This.labURL2 -text "$caption(en-tete,a_propos_de_maj) $audela(date)." -fg $color(red)
      pack $This.labURL2 -in $This.frame1 -padx 30 -pady 2

      #--- Logiciel libre et gratuit
      label $This.lab3 -text "$caption(en-tete,a_propos_de_libre)"
      pack $This.lab3 -in $This.frame1 -padx 30 -pady 2

      #--- Site web officiel
      label $This.labURL4 -text "$caption(en-tete,a_propos_de_site)" -fg $color(blue)
      pack $This.labURL4 -in $This.frame1 -padx 30 -pady 2

      #--- Copyright
      label $This.lab5 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright1)"
      pack $This.lab5 -in $This.frame1 -padx 30 -pady 2

      label $This.lab6 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright2)"
      pack $This.lab6 -in $This.frame1 -padx 30 -pady 2

      label $This.lab7 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright3)"
      pack $This.lab7 -in $This.frame1 -padx 30 -pady 2

      label $This.lab8 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright4)"
      pack $This.lab8 -in $This.frame1 -padx 30 -pady 2

      label $This.lab9 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright5)"
      pack $This.lab9 -in $This.frame1 -padx 30 -pady 2

      label $This.lab10 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright6)"
      pack $This.lab10 -in $This.frame1 -padx 30 -pady 2

      label $This.lab11 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright7)"
      pack $This.lab11 -in $This.frame1 -padx 30 -pady 2

      label $This.lab12 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright8)"
      pack $This.lab12 -in $This.frame1 -padx 30 -pady 2

      label $This.lab13 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright9)"
      pack $This.lab13 -in $This.frame1 -padx 30 -pady 2

      label $This.lab14 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright10)"
      pack $This.lab14 -in $This.frame1 -padx 30 -pady 2

      label $This.lab15 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright11)"
      pack $This.lab15 -in $This.frame1 -padx 30 -pady 2

      label $This.lab16 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright12)"
      pack $This.lab16 -in $This.frame1 -padx 30 -pady 2

      label $This.lab17 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright13)"
      pack $This.lab17 -in $This.frame1 -padx 30 -pady 2

      label $This.lab18 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright14)"
      pack $This.lab18 -in $This.frame1 -padx 30 -pady 2

      label $This.lab19 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright15)"
      pack $This.lab19 -in $This.frame1 -padx 30 -pady 2

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confVersion::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

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
#  Cree une fenetre de configuration generique
#  Cette fenetre appelle les fonctions specifiques du namespace passe en parametre
#     namespace::apply            pour le bouton appliquer ou ok
#     namespace::closeWindow      pour le bouton fermer ou ok
#     namespace::getLabel         retourne le titre de la fenetre
#     namespace::fillConfigPage   pour la creation des widgets dans la fenetre
#     namespace::showHelp         pour le bouton d'aide
#

namespace eval ::confGenerique {
}

#
# confGenerique::run
#   Cree la fenetre de configuration generique
#
# Parametres :
#  visuNo    : numero de la visu courante
#  tkName    : chemin TK de la fenetre
#  namespace : namespace des fonctions specifiques
#  -modal 0|1 : 1=modal (attend la fermeture de la fenetre) ou 0=nomodal (retourne immediatement)
#              valeur par defaut = 1
#  -geometry 200x100+180+50 : taille et position relative de la fenetre
#              valeur par defaut = 200x100+180+50
#  -resizable 0|1 : 1=redimmensionnement possible ou 0=redimensionnement interdit
#              valeur par defaut = 1
#  -close 0|1 : 1=fermeture de la fenetre possible ou 0=fermeture de la fenetre interdit
#              valeur par defaut = 1
# return
#  si mode=modal
#     retourne 1 si la fenetre est fermee avec le bouton OK
#     retourne 0 si la fenetre est fermee avec le bouton Fermer
#  si mode=nomodal
#     retourne 0
#
proc ::confGenerique::run { args } {
   variable private

   set visuNo   [lindex $args 0]
   set This     [lindex $args 1]
   set NameSpace [lindex $args 2]
   set options  [lrange $args 3 end]

   #--- valeur par defaut des options
   set private($visuNo,$NameSpace,modal)     "1"
   set private($visuNo,$NameSpace,geometry)  "+180+50"
   set private($visuNo,$NameSpace,resizable) "0"
   set private($visuNo,$NameSpace,close)     "1"
   set private($visuNo,$NameSpace,this)      $This

   #--- je traite les options
   while {[llength $options] > 0} {
      set arg [lindex $options 0]
      switch -- "$arg" {
         "-modal" {
            set private($visuNo,$NameSpace,modal) [lindex $options 1]
         }
         "-geometry" {
            set private($visuNo,$NameSpace,geometry) [lindex $options 1]
         }
         "-resizable" {
            set private($visuNo,$NameSpace,resizable) [lindex $options 1]
         }
         "-close" {
            set private($visuNo,$NameSpace,close) [lindex $options 1]
         }
      }
      set options [lrange $options 2 end]
   }

   createDialog $visuNo $NameSpace

   set private($visuNo,$NameSpace,modalResult) "0"
   if { $private($visuNo,$NameSpace,modal) == "1" } {
      #--- j'attends la fermeture de la fenetre avant de terminer
      tkwait window $private($visuNo,$NameSpace,this)
      return $private($visuNo,$NameSpace,modalResult)
   } else {
      return "0"
   }
}

#
# confGenerique::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
# et fermer la fenetre de configuration generique
#
proc ::confGenerique::ok { visuNo NameSpace } {
   variable private

   set private($visuNo,$NameSpace,modalResult) "1"
   ::confGenerique::apply $visuNo $NameSpace
   ::confGenerique::closeWindow $visuNo $NameSpace
}

#
# confGenerique::apply
# Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour memoriser et appliquer la configuration
#
proc ::confGenerique::apply { visuNo NameSpace } {
   #--- je copie le resultat de la procedure
   $NameSpace\:\:apply $visuNo
}

#
# confGenerique::showHelp
# Fonction 'showHelp' pour afficher l'aide
#
proc ::confGenerique::showHelp { visuNo NameSpace } {
   set result [ catch { $NameSpace\:\:showHelp } msg ]
   if { $result == "1" } {
      ::console::affiche_erreur "$msg\n"
      tk_messageBox -title "$NameSpace" -type ok -message "$msg" -icon error
      return
   }
}

#
# confGenerique::closeWindow
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
# Ferme la fenetre si la procedure namepace::closeWindow retourne une valeur
# differente de "0"
#
proc ::confGenerique::closeWindow { visuNo NameSpace  } {
   variable private

   if { $private($visuNo,$NameSpace,close) == "1" } {
      if { [winfo exists $private($visuNo,$NameSpace,this)] } {
         if { [info procs $NameSpace\:\:closeWindow ] != "" } {
            #--- appelle la procedure "closeWindow"
            set result [$NameSpace\:\:closeWindow $visuNo]
            if { $result == "0" } {
               return
            }
         }
         #--- supprime la fenetre
         destroy $private($visuNo,$NameSpace,this)
      }
     ### array unset private $visuNo,$NameSpace,*
   }
   return
}

proc ::confGenerique::createDialog { visuNo NameSpace } {
   variable private
   global caption conf

   if { [winfo exists $private($visuNo,$NameSpace,this)] } {
      wm withdraw $private($visuNo,$NameSpace,this)
      wm deiconify $private($visuNo,$NameSpace,this)
      focus $private($visuNo,$NameSpace,this)
      return
   }

   #--- Cree la fenetre private($visuNo,$NameSpace,this) de niveau le plus haut
   set This $private($visuNo,$NameSpace,this)
   toplevel $This -class Toplevel
   wm geometry $This $private($visuNo,$NameSpace,geometry)
   wm resizable $This $private($visuNo,$NameSpace,resizable) $private($visuNo,$NameSpace,resizable)
   wm title $This "[$NameSpace\:\:getLabel] (visu$visuNo)"
   wm protocol $This WM_DELETE_WINDOW "::confGenerique::closeWindow $visuNo $NameSpace"

   #--- Frame des boutons OK, Appliquer et Fermer
   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side bottom -fill x

   #--- Frame des parametres a configurer
   frame $This.frame1 -borderwidth 1 -relief raised
   $NameSpace\:\:fillConfigPage $This.frame1 $visuNo
   pack $This.frame1 -side top -fill both -expand 1

   #--- Si elle est modale, je fais apparaitre la fenetre toujours au dessus de
   #--- la fenetre parent
   if { $private($visuNo,$NameSpace,modal) == 1 } {
      wm transient $This [winfo parent $This]
   }

   if { [info commands "$NameSpace\::apply"] !=  "" } {
      #--- Cree le bouton 'OK' si la procedure NameSpace::apply existe
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command "::confGenerique::ok $visuNo $NameSpace"
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3  -ipady 5
      }

      if { $private($visuNo,$NameSpace,modal) == "0" } {
         #--- Cree le bouton 'Appliquer' si la procedure NameSpace::apply existe
         button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
            -command "::confGenerique::apply $visuNo $NameSpace "
         pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }
   }
   #--- Cree un label 'Invisible' pour simuler un espacement
   label $This.lab_invisible -width 10
   pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Fermer'
   if { [info commands "$NameSpace\::closeWindow"] !=  "" } {
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command "::confGenerique::closeWindow $visuNo $NameSpace"
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Raccourci qui ferme la fenetre avec la touche ESCAPE
      bind $This <Key-Escape> "::confGenerique::closeWindow $visuNo $NameSpace"
   }

   #--- Cree le bouton 'Aide'
   if { [info commands "$NameSpace\::showHelp"] !=  "" } {
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command "::confGenerique::showHelp $visuNo $NameSpace"
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5
   }

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

