#
# Fichier : confgene.tcl
# Description : Configuration generale d'AudeLA et d'Aud'ACE (general, editeurs, repertoires, position
#               de l'observateur, temps (heure systeme ou TU), fichiers image, alarme sonore de fin de
#               pose, choix des panneaux, type de fenetre, la fenetre A propos de ... et une fenetre de
#               configuration generique)
# Auteur : Robert DELMAS
# Mise a jour $Id: confgene.tcl,v 1.40 2008-04-22 22:10:06 robertdelmas Exp $
#

#
# PosObs
# Description : Position de l'observateur sur la Terre
#

namespace eval confPosObs {

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
   # Initialisation de variables de position dans aud.tcl (::audace::Recup_Config) pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      #--- Observatoire du Pic du Midi
      if { ! [ info exists conf(posobs,estouest) ] }        { set conf(posobs,estouest)        "E" }
      if { ! [ info exists conf(posobs,long) ] }            { set conf(posobs,long)            "0d8m32s2" }
      if { ! [ info exists conf(posobs,nordsud) ] }         { set conf(posobs,nordsud)         "N" }
      if { ! [ info exists conf(posobs,lat) ] }             { set conf(posobs,lat)             "42d56m11s9" }
      if { ! [ info exists conf(posobs,altitude) ] }        { set conf(posobs,altitude)        "2890.5" }
      if { ! [ info exists conf(posobs,observateur,gps) ] } { set conf(posobs,observateur,gps) "GPS 0.142300 E 42.936639 2890.5" }
   }

   #
   # confPosObs::initConf1
   # Initialisation d'autres variables de position
   #
   proc initConf1 { } {
      global conf

      #--- Concatenation de variables pour l'en-tete FITS
      set conf(posobs,estouest_long) $conf(posobs,estouest)$conf(posobs,long)
      set conf(posobs,nordsud_lat)   $conf(posobs,nordsud)$conf(posobs,lat)

      #--- Initialisation indispensable d'autres variables
      if { ! [ info exists conf(posobs,nom_observateur) ] }        { set conf(posobs,nom_observateur)        "" }
      if { ! [ info exists conf(posobs,nom_observatoire) ] }       { set conf(posobs,nom_observatoire)       "Pic du Midi - France" }
      if { ! [ info exists conf(posobs,ref_geodesique) ] }         { set conf(posobs,ref_geodesique)         "WGS84" }
      if { ! [ info exists conf(posobs,station_uai) ] }            { set conf(posobs,station_uai)            "586" }
      if { ! [ info exists conf(posobs,fichier_station_uai) ] }    { set conf(posobs,fichier_station_uai)    "obscodes.txt" }
      if { ! [ info exists conf(posobs,observateur,mpc) ] }        { set conf(posobs,observateur,mpc)        "" }
      if { ! [ info exists conf(posobs,observateur,mpcstation) ] } { set conf(posobs,observateur,mpcstation) "" }

      #--- Observatoire du Pic du Midi - FRANCE
      if { ! [ info exists conf(posobs,config_observatoire,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set config_observatoire { }
         set config_observatoire(nom_observatoire) "Pic du Midi - France"
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
         set config_observatoire(nom_observatoire) "Haute Provence - France"
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

      frame $This.frame2b -borderwidth 0 -relief raised
      pack $This.frame2b -in $This.frame1 -side top -fill both -expand 1

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

      #--- Nom de l'observateur
      label $This.lab0a -text "$caption(confgene,nom_observateur)"
      pack $This.lab0a -in $This.frame2a -anchor w -side left -padx 10 -pady 5

      entry $This.nom_observateur -textvariable confgene(posobs,nom_observateur) -width 35
      pack $This.nom_observateur -in $This.frame2a -anchor w -side right -padx 10 -pady 5

      #--- Nom de l'observatoire
      label $This.lab0b -text "$caption(confgene,nom_observatoire)"
      pack $This.lab0b -in $This.frame2b -anchor w -side left -padx 10 -pady 5

      ComboBox $This.nom_observatoire \
         -width 42         \
         -height 10        \
         -relief sunken    \
         -borderwidth 2    \
         -editable 1       \
         -textvariable confgene(posobs,nom_observatoire) \
         -modifycmd "::confPosObs::cbCommand $This.nom_observatoire" \
         -values $confgene(posobs,nom_observatoire_liste)
      pack $This.nom_observatoire -in $This.frame2b -anchor w -side right -padx 10 -pady 5

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
         -width 7          \
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
      pack $This.lab7 -in $This.frame17 -anchor w -side top -padx 10 -pady 5

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
   # confPosObs::MaJ
   # Creation de l'interface pour la mise a jour du fichier des observatoires
   #
   proc MaJ { } {
      global audace caption color confgene

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
      pack $audace(base).maj.lab1 -padx 10 -pady 2
      label $audace(base).maj.lab2 -text "$caption(confgene,fichier_uai_maj2)"
      pack $audace(base).maj.lab2 -padx 10 -pady 2
      label $audace(base).maj.lab3 -text "$caption(confgene,fichier_uai_maj3)"
      pack $audace(base).maj.lab3 -padx 10 -pady 2
      label $audace(base).maj.labURL4 -text "$caption(confgene,fichier_uai_maj4)" -font $audace(font,url) \
         -fg $color(blue)
      pack $audace(base).maj.labURL4 -padx 10 -pady 2
      label $audace(base).maj.lab5 -text "$caption(confgene,fichier_uai_maj5) $confgene(posobs,fichier_station_uai)"
      pack $audace(base).maj.lab5 -padx 10 -pady 2

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
      global caption conf confgene

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
      global audace caption color conf confgene

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
      global conf confgene

      #--- J'ajoute l'observatoire en tete dans le tableau des observatoires precedents s'il n'y est pas deja
      array set config_observatoire { }
      set config_observatoire(nom_observatoire) "$confgene(posobs,nom_observatoire)"
      set config_observatoire(estouest)         "$confgene(posobs,estouest)"
      set config_observatoire(long)             "$confgene(posobs,long)"
      set config_observatoire(nordsud)          "$confgene(posobs,nordsud)"
      set config_observatoire(lat)              "$confgene(posobs,lat)"
      set config_observatoire(altitude)         "$confgene(posobs,altitude)"
      set config_observatoire(ref_geodesique)   "$confgene(posobs,ref_geodesique)"
      set config_observatoire(station_uai)      "$confgene(posobs,station_uai)"

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
      set conf(posobs,nom_observateur)        $confgene(posobs,nom_observateur)
      set conf(posobs,nom_observatoire)       $confgene(posobs,nom_observatoire)
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

      #--- Concatenation de variables pour l'en-tete FITS
      set conf(posobs,estouest_long)          $conf(posobs,estouest)$conf(posobs,long)
      set conf(posobs,nordsud_lat)            $conf(posobs,nordsud)$conf(posobs,lat)
   }
}

#
# Temps
# Description : Configuration du temps (heure systeme ou TU)
#

namespace eval confTemps {

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
      global caption conf confgene

      set confgene(temps,fushoraire) $conf(temps,fushoraire)
      set confgene(temps,hhiverete)  [ lindex "$caption(confgene,temps_aucune) $caption(confgene,temps_hiver) $caption(confgene,temps_ete)" "$conf(temps,hhiverete)" ]
      set confgene(temps,hsysteme)   [ lindex "$caption(confgene,temps_heurelegale) $caption(confgene,temps_universel)" "$conf(temps,hsysteme)" ]

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
      global audace caption conf confgene

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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # Temps_TU_TSL
   # Fonction qui met a jour TU, TSL cette fonction se re-appelle au bout d'une seconde
   #
   proc Temps_TU_TSL { } {
      variable This
      global caption conf confgene

      #--- Systeme d'heure utilise
      if { $confgene(temps,hsysteme) == "$caption(confgene,temps_heurelegale)" } {
         if { [ winfo exists $This.lab4 ] == 0 } {
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
         destroy $This.lab4
         destroy $This.fushoraire
         destroy $This.lab5
         destroy $This.hhiverete
      }
   }

   #
   # confTemps::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global caption conf confgene

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
      global audace conf confgene

      #---
      catch {
         buf1000 extension "$confgene(extension,new)"
         buf1001 extension "$confgene(extension,new)"
         buf1002 extension "$confgene(extension,new)"
         buf1003 extension "$confgene(extension,new)"
      }
      #---
      buf$audace(bufNo) extension "$confgene(extension,new)"
      if { $confgene(fichier,compres) == "0" } {
         buf$audace(bufNo) compress "none"
      } else {
         buf$audace(bufNo) compress "gzip"
      }
      $This.labURL2 configure -text "$confgene(extension,new)"
      $This.labURL5 configure -text "$confgene(jpegquality,new)"
      #---
      set listExtensionFile ""
      if { ( [ buf$audace(bufNo) extension ] != ".fit" ) && ( [ buf$audace(bufNo) extension ] != ".fts" ) &&
         ( [ buf$audace(bufNo) extension ] != ".fits" ) } {
         set listExtensionFile "[ buf$audace(bufNo) extension ] [ buf$audace(bufNo) extension ].gz"
      }
      set listExtensionFile "$listExtensionFile .fit .fit.gz .fts .fts.gz .fits .fits.gz .jpeg .jpg .crw .cr2 .nef .dng"
      set confgene(fichier,list_extension) $listExtensionFile
      #---
      widgetToConf
      #--- Mise a jour de l'extension des fichiers image pour toutes les visu disponibles
      foreach visuNo [ ::visu::list ] {
         ::confFichierIma::MAJ_Extension
      }
      #--- Mise a jour du format des fichiers image pour tous les buffers disponibles
      foreach visuNo [ ::visu::list ] {
         set bufNo [ visu$visuNo buf ]
         #--- Format entier ou flottant
         if { $conf(format_fichier_image) == "0" } {
            buf$bufNo bitpix ushort
         } else {
            buf$bufNo bitpix float
         }
      }
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
      if { ! [ info exists conf(save_seuils_visu) ] }     { set conf(save_seuils_visu)     "1" }
      if { ! [ info exists conf(format_fichier_image) ] } { set conf(format_fichier_image) "0" }
      if { ! [ info exists conf(extension,defaut) ] }     { set conf(extension,defaut)     ".fit" }
      if { ! [ info exists conf(fichier,compres) ] }      { set conf(fichier,compres)      "0" }
      if { ! [ info exists conf(jpegquality,defaut) ] }   { set conf(jpegquality,defaut)   "80" }
      if { ! [ info exists conf(list_extension) ] }       { set conf(list_extension)       ".fit .fit.gz .fts .fts.gz .fits .fits.gz .jpeg .jpg .crw .cr2 .nef .dng" }
      #---
      set conf(extension,new)   $conf(extension,defaut)
      set conf(jpegquality,new) $conf(jpegquality,defaut)
   }

   proc createDialog { } {
      variable This
      global audace caption color conf confgene

      #--- confToWidget
      set confgene(fichier,save_seuils_visu) $conf(save_seuils_visu)
      set confgene(fichier,format)           $conf(format_fichier_image)
      set confgene(extension,new)            $conf(extension,new)
      set confgene(fichier,compres)          $conf(fichier,compres)
      set confgene(jpegquality,new)          $conf(jpegquality,new)
      set confgene(fichier,list_extension)   $conf(list_extension)

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
      checkbutton $This.save_seuils_visu -text "$caption(confgene,fichier_images_seuils_visu)" -highlightthickness 0 \
         -variable confgene(fichier,save_seuils_visu)
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

      entry $This.newext -textvariable confgene(extension,new) -width 5 -justify center
      pack $This.newext -in $This.frame10 -anchor center -side right -padx 10 -pady 5

      #--- Ouvre le choix aux fichiers compresses
      checkbutton $This.compress -text "$caption(confgene,fichier_image_compres)" -highlightthickness 0 \
         -variable confgene(fichier,compres)
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

      set conf(save_seuils_visu)     $confgene(fichier,save_seuils_visu)
      set conf(format_fichier_image) $confgene(fichier,format)
      set conf(extension,defaut)     $confgene(extension,new)
      set conf(extension,new)        $confgene(extension,new)
      set conf(fichier,compres)      $confgene(fichier,compres)
      set conf(jpegquality,defaut)   $confgene(jpegquality,new)
      set conf(jpegquality,new)      $confgene(jpegquality,new)
      set conf(list_extension)       $confgene(fichier,list_extension)
   }

   proc MAJ_Extension { } {
      variable This
      global conf confgene panneau

      #---
      if { ( $conf(extension,new) == ".jpg" )  || ( $conf(extension,new) == ".jpeg" ) \
         || ( $conf(extension,new) == ".crw" ) || ( $conf(extension,new) == ".cr2" ) \
         || ( $conf(extension,new) == ".nef" ) || ( $conf(extension,new) == ".dng" ) } {
         set confgene(fichier,compres) "0"
         $This.compress configure -variable confgene(fichier,compres)
         set conf(fichier,compres) $confgene(fichier,compres)
      }

     ### if { ( $conf(extension,new) == ".bmp" ) || ( $conf(extension,new) == ".gif" ) || ( $conf(extension,new) == ".jpg" ) \
     ###    || ( $conf(extension,new) == ".jpeg" ) || ( $conf(extension,new) == ".png" ) || ( $conf(extension,new) == ".tif" ) \
     ###    || ( $conf(extension,new) == ".xbm" ) || ( $conf(extension,new) == ".xpm" ) || ( $conf(extension,new) == ".eps" ) \
     ###    || ( $conf(extension,new) == ".crw" ) || ( $conf(extension,new) == ".cr2" ) || ( $conf(extension,new) == ".nef" ) \
     ###    || ( $conf(extension,new) == ".dng" ) } {
     ###    set confgene(fichier,compres) "0"
     ###    $This.compress configure -variable confgene(fichier,compres)
     ###    set conf(fichier,compres) $confgene(fichier,compres)
     ### }

      #--- Mise a jour de l'extension des fichiers image pour toutes les visu disponibles
      foreach visuNo [ ::visu::list ] {
         if { $conf(fichier,compres) == "1" } {
            set panneau(acqfc,$visuNo,extension)  $conf(extension,new).gz
            set panneau(scan,extension_image)     $conf(extension,new).gz
            set panneau(scanfast,extension_image) $conf(extension,new).gz
         } else {
            set panneau(acqfc,$visuNo,extension)  $conf(extension,new)
            set panneau(scan,extension_image)     $conf(extension,new)
            set panneau(scanfast,extension_image) $conf(extension,new)
         }
      }
   }
}

#
# AlarmeFinPose
# Description : Configuration de l'alarme de fin de pose
#

namespace eval confAlarmeFinPose {

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
# Description : Choisir les outils a afficher dans le menu Outil
#

namespace eval confChoixOutil {

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
      global audace caption

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
      global caption color conf confgene panneau

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
      set liste   ""

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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # confChoixOutil::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global conf confgene

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
# TypeFenetre
# Description : Configuration du type de fenetre du menu 'Reglages'
#

namespace eval confTypeFenetre {

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
      global caption conf confgene

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
# General
# Description : Configuration generale pour l'acces au choix des langues, au tutorial et au message
# d'erreur genere lors de l'installation de Porttalk s'il y a eu un probleme
#

namespace eval confGeneral {

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
      global audace caption conf

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
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

#
# Version
# Description : Version du logiciel
#

namespace eval confVersion {

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
      global audace audela caption color conf

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
      label $This.lab1 -text "$audela(name) $audela(version)" -font $audace(font,arial_15_b)
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

namespace eval confGenerique {
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
      }
      set options [lrange $options 2 end]
   }

   createDialog $visuNo $NameSpace $This

   set private($visuNo,$NameSpace,modalResult) "0"
   if { $private($visuNo,$NameSpace,modal) == "1" } {
      #--- j'attends la fermeture de la fenetre avant de terminer
      tkwait window $This
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
proc ::confGenerique::ok { visuNo NameSpace This } {
   variable private

   set private($visuNo,$NameSpace,modalResult) "1"
   ::confGenerique::apply $visuNo $NameSpace
   ::confGenerique::closeWindow $visuNo $NameSpace $This
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
proc ::confGenerique::closeWindow { visuNo NameSpace This } {
   if { [info procs $NameSpace\:\:closeWindow ] != "" } {
      #--- appelle la procedure "closeWindow"
      set result [$NameSpace\:\:closeWindow $visuNo]
      if { $result == "0" } {
         return
      }
   }
   #--- supprime la fenetre
   destroy $This
   return
}

proc ::confGenerique::createDialog { visuNo NameSpace This} {
   global caption conf
   variable private

   if { [winfo exists $This] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm geometry $This $private($visuNo,$NameSpace,geometry)
   wm resizable $This $private($visuNo,$NameSpace,resizable) $private($visuNo,$NameSpace,resizable)
   wm title $This "[$NameSpace\:\:getLabel] (visu$visuNo)"
   wm protocol $This WM_DELETE_WINDOW "::confGenerique::closeWindow $visuNo $NameSpace $This"

   #--- Frame des parametres a configurer
   frame $This.frame1 -borderwidth 1 -relief raised
   $NameSpace\:\:fillConfigPage $This.frame1 $visuNo
   pack $This.frame1 -side top -fill both -expand 1

   #--- Frame des boutons OK, Appliquer et Fermer
   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side top -fill x

   if { [info commands "$NameSpace\::apply"] !=  "" } {
      #--- Cree le bouton 'OK' si la procedure NameSpace::apply existe
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command "::confGenerique::ok $visuNo $NameSpace $This"
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
         -command "::confGenerique::closeWindow $visuNo $NameSpace $This"
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Raccourci qui ferme la fenetre avec la touche ESCAPE
      bind $This <Key-Escape> "::confGenerique::closeWindow $visuNo $NameSpace $This"
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

