#
# Fichier : viseur_polaire_eq6.tcl
# Description : Positionne l'etoile polaire dans un viseau polaire de type EQ6 ou a constellations
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::viseurPolaireEQ6 {

   #
   # viseurPolaireEQ6::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This
      variable widget
      global viseurPolaireEQ6

      #--- Cree les variables dans conf(...) si elles n'existent pas
      ::viseurPolaireEQ6::initConf
      #--- Recupere les variables dans conf(...) si elles existent
      ::viseurPolaireEQ6::confToWidget
      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.but_fermer
      } else {
         if { [ info exists viseurPolaireEQ6(geometry) ] } {
            set deb [ expr 1 + [ string first + $viseurPolaireEQ6(geometry) ] ]
            set fin [ string length $viseurPolaireEQ6(geometry) ]
            set widget(viseur_polaire_eq6,position) "+[ string range $viseurPolaireEQ6(geometry) $deb $fin ]"
         }
         ::viseurPolaireEQ6::createDialog
         tkwait visibility $This
      }
   }

   #
   # viseurPolaireEQ6::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   #
   proc ok { } {
      ::viseurPolaireEQ6::recup_position
      ::viseurPolaireEQ6::widgetToConf
      ::viseurPolaireEQ6::fermer
   }

   #
   # viseurPolaireEQ6::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      global audace

      ::viseurPolaireEQ6::ok
      ::viseurPolaireEQ6::run "$audace(base).viseurPolaireEQ6"
   }

   #
   # viseurPolaireEQ6::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      ::viseurPolaireEQ6::recup_position
      destroy $This
      unset This
   }

   #
   #  viseurPolaireEQ6::initConf
   #  Initialise les parametres dans le tableau conf()
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(viseur_eq6,position) ] }         { set conf(viseur_eq6,position)         "+110+20" }
      if { ! [ info exists conf(viseur_eq6,taille) ] }           { set conf(viseur_eq6,taille)           "0.5" }
      if { ! [ info exists conf(viseur_eq6,couleur_fond) ] }     { set conf(viseur_eq6,couleur_fond)     "#000000" }
      if { ! [ info exists conf(viseur_eq6,couleur_reticule) ] } { set conf(viseur_eq6,couleur_reticule) "#FFFFFF" }
      if { ! [ info exists conf(viseur_eq6,couleur_etoile) ] }   { set conf(viseur_eq6,couleur_etoile)   "#FFFF00" }

      return
   }

   #
   #  viseurPolaireEQ6::confToWidget
   #  Copie les parametres du tableau conf() dans les variables des widgets
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(viseur_polaire_eq6,position)         $conf(viseur_eq6,position)
      set widget(viseur_polaire_eq6,taille)           $conf(viseur_eq6,taille)
      set widget(viseur_polaire_eq6,couleur_fond)     $conf(viseur_eq6,couleur_fond)
      set widget(viseur_polaire_eq6,couleur_reticule) $conf(viseur_eq6,couleur_reticule)
      set widget(viseur_polaire_eq6,couleur_etoile)   $conf(viseur_eq6,couleur_etoile)
   }

   #
   #  viseurPolaireEQ6::widgetToConf
   #  Copie les variables des widgets dans le tableau conf()
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(viseur_eq6,position)         $widget(viseur_polaire_eq6,position)
      set conf(viseur_eq6,taille)           $widget(viseur_polaire_eq6,taille)
      set conf(viseur_eq6,couleur_fond)     $widget(viseur_polaire_eq6,couleur_fond)
      set conf(viseur_eq6,couleur_reticule) $widget(viseur_polaire_eq6,couleur_reticule)
      set conf(viseur_eq6,couleur_etoile)   $widget(viseur_polaire_eq6,couleur_etoile)
   }

   #
   #  viseurPolaireEQ6::recup_position
   #  Recupere la position de la fenetre
   #
   proc recup_position { } {
      variable This
      variable widget
      global viseurPolaireEQ6

      set viseurPolaireEQ6(geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $viseurPolaireEQ6(geometry) ] ]
      set fin [ string length $viseurPolaireEQ6(geometry) ]
      set widget(viseur_polaire_eq6,position) "+[ string range $viseurPolaireEQ6(geometry) $deb $fin ]"
      #---
      ::viseurPolaireEQ6::widgetToConf
   }

   #
   # viseurPolaireEQ6::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace
      global conf
      global caption
      global color
      global viseurPolaireEQ6

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_eq6.cap ]

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm title $This $caption(viseur_eq6,titre)
      wm geometry $This $widget(viseur_polaire_eq6,position)
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW ::viseurPolaireEQ6::fermer

      #--- Je memorise la reference de la frame
      set widget(This) $This

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 1 -relief raised
      pack $This.frame3 -side top -fill x

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame2 -side top -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame2 -side top -fill both -expand 1

      #--- Texte et donnees
      label $This.lab1 -text "$caption(viseur_eq6,texte)"
      pack $This.lab1 -in $This.frame4 -anchor center -side left -padx 5 -pady 2

      set viseurPolaireEQ6(longitude) "$conf(posobs,estouest) $conf(posobs,long)"
      label $This.labURL3 -textvariable "viseurPolaireEQ6(longitude)" -fg $color(blue)
      pack $This.labURL3 -in $This.frame4 -anchor center -side right -padx 5 -pady 2

      label $This.lab2 -text "$caption(viseur_eq6,long)"
      pack $This.lab2 -in $This.frame4 -anchor center -side right -padx 0 -pady 2

      label $This.lab4 -text "$caption(viseur_eq6,ah_polaire)"
      pack $This.lab4 -in $This.frame5 -anchor center -side left -padx 5 -pady 2

      label $This.lab5 -anchor w
      pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 0 -pady 2

      #--- Creation d'un canvas pour l'affichage du viseur polaire
      canvas $This.image1_color_invariant -width [ expr $widget(viseur_polaire_eq6,taille)*500 ] \
         -height [ expr $widget(viseur_polaire_eq6,taille)*500 ] -bg $widget(viseur_polaire_eq6,couleur_fond)
      pack $This.image1_color_invariant -in $This.frame6 -side top -anchor center -padx 0 -pady 0
      set viseurPolaireEQ6(image1) $This.image1_color_invariant

      #--- Calcul de l'angle horaire de la Polaire et dessin du viseur polaire
      ::viseurPolaireEQ6::HA_Polaire

      #--- Taille du viseur polaire
      label $This.lab10 -text "$caption(viseur_eq6,taille)"
      pack $This.lab10 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

      #--- Definition de la taille de la raquette
      set list_combobox [ list 0.5 0.6 0.7 0.8 0.9 1.0 ]
      ComboBox $This.taille \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [llength $list_combobox ] \
         -relief sunken     \
         -borderwidth 1     \
         -editable 0        \
         -textvariable viseurPolaireEQ6::widget(viseur_polaire_eq6,taille) \
         -values $list_combobox
      pack $This.taille -in $This.frame7 -anchor center -side left -padx 5 -pady 5

      #--- Choix de la couleur du fond
      button $This.but_couleur_fond_color_invariant -relief raised -width 6 \
         -bg $widget(viseur_polaire_eq6,couleur_fond) -activebackground $widget(viseur_polaire_eq6,couleur_fond) \
         -command {
            set temp [tk_chooseColor -initialcolor ${viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_fond)} \
               -parent ${viseurPolaireEQ6::widget(This)} -title ${caption(viseur_eq6,couleur_fond)} ]
            if  { $temp != "" } {
               set viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_fond) "$temp"
               ${viseurPolaireEQ6::widget(This)}.but_couleur_fond_color_invariant configure \
                  -bg ${viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_fond)}
            }
         }
      pack $This.but_couleur_fond_color_invariant -in $This.frame7 -anchor center -side right -padx 5 -pady 5

      #--- Couleur du fond
      label $This.lab_couleur_fond -text "$caption(viseur_eq6,couleur_fond)"
      pack $This.lab_couleur_fond -in $This.frame7 -anchor center -side right -padx 5 -pady 5

      #--- Couleur du reticule
      label $This.lab_couleur_reticule -text "$caption(viseur_eq6,couleur_reticule)"
      pack $This.lab_couleur_reticule -in $This.frame8 -anchor center -side left -padx 5 -pady 5

      #--- Choix de la couleur du reticule
      button $This.but_couleur_reticule_color_invariant -relief raised -width 6 \
         -bg $widget(viseur_polaire_eq6,couleur_reticule) -activebackground $widget(viseur_polaire_eq6,couleur_reticule) \
         -command {
            set temp [tk_chooseColor -initialcolor ${viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_reticule)} \
               -parent ${viseurPolaireEQ6::widget(This)} -title ${caption(viseur_eq6,couleur_reticule)} ]
            if  { $temp != "" } {
               set viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_reticule) "$temp"
               ${viseurPolaireEQ6::widget(This)}.but_couleur_reticule_color_invariant configure \
                  -bg ${viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_reticule)}
            }
         }
      pack $This.but_couleur_reticule_color_invariant -in $This.frame8 -anchor center -side left -padx 5 -pady 5

      #--- Choix de la couleur des etoiles et des constellations
      button $This.but_couleur_etoile_color_invariant -relief raised -width 6 \
         -bg $widget(viseur_polaire_eq6,couleur_etoile) -activebackground $widget(viseur_polaire_eq6,couleur_etoile) \
         -command {
            set temp [tk_chooseColor -initialcolor ${viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_etoile)} \
               -parent ${viseurPolaireEQ6::widget(This)} -title ${caption(viseur_eq6,couleur_etoile)} ]
            if  { "$temp" != "" } {
               set viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_etoile) "$temp"
               ${viseurPolaireEQ6::widget(This)}.but_couleur_etoile_color_invariant configure \
                  -bg ${viseurPolaireEQ6::widget(viseur_polaire_eq6,couleur_etoile)}
            }
         }
      pack $This.but_couleur_etoile_color_invariant -in $This.frame8 -anchor center -side right -padx 5 -pady 5

      #--- Couleur des etoiles et des constellations
      label $This.lab_couleur_etoile -text "$caption(viseur_eq6,couleur_etoile)"
      pack $This.lab_couleur_etoile -in $This.frame8 -anchor center -side right -padx 5 -pady 5

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(viseur_eq6,ok)" -width 7 -borderwidth 2 \
         -command { ::viseurPolaireEQ6::ok }
      if { $conf(ok+appliquer)=="1" } {
         pack $This.but_ok -in $This.frame3 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(viseur_eq6,appliquer)" -width 8 -borderwidth 2 \
         -command { ::viseurPolaireEQ6::appliquer }
      pack $This.but_appliquer -in $This.frame3 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(viseur_eq6,fermer)" -width 7 -borderwidth 2 \
         -command { ::viseurPolaireEQ6::fermer }
      pack $This.but_fermer -in $This.frame3 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(viseur_eq6,aide)" -width 7 -borderwidth 2 \
         -command {
            ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::viseur_polaire::getPluginType ] ] \
                [ ::viseur_polaire::getPluginDirectory ] [ ::viseur_polaire::getPluginHelp ]
         }
      pack $This.but_aide -in $This.frame3 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #--- Bind sur la longitude
      bind $This.labURL3 <ButtonPress-1> {
         ::confPosObs::run "$audace(base).confPosObs"
         tkwait window $audace(base).confPosObs
         set viseurPolaireEQ6(longitude) "$conf(posobs,estouest) $conf(posobs,long)"
         catch {
            #--- Redessine le viseur EQ6
            ::viseurPolaireEQ6::HA_Polaire
            #--- Redessine le viseur Takahashi s'ils sont affiches tous les 2
            set viseurPolaireTaka(longitude) $viseurPolaireEQ6(longitude)
            ::viseurPolaireTaka::HA_Polaire
         }
      }
   }

   #
   # viseurPolaireEQ6::HA_Polaire
   # Calcule l'angle horaire de la Polaire et dessine le viseur polaire
   #
   proc HA_Polaire { } {
      variable This
      variable widget
      global audace
      global viseurPolaireEQ6

      #--- Coordonnees de la Polaire J2000.0
      set ad_LP  "2h31m51.267"
      set dec_LP "89d15m50.90"

      #--- Calcul des coordonnees vraies de la Polaire
      set pressure        $audace(meteo,obs,pressure)
      set temperature     $audace(meteo,obs,temperature)
      set now             [ ::audace::date_sys2ut now ]
      set hipRecord       [ list "1" "0.0" [ mc_angle2deg $ad_LP ] [ mc_angle2deg $dec_LP ] J2000.0 0 0 0 0 ]
      set ad_dec_v        [ mc_hip2tel $hipRecord $now $::audace(posobs,observateur,gps) $pressure $temperature ]
      set ad_LP_vrai      [ lindex $ad_dec_v 0 ]
      set dec_LP_vrai     [ lindex $ad_dec_v 1 ]
      set anglehoraire_LP [ lindex $ad_dec_v 2 ]

      #--- Angle horaire
      set anglehoraire_LP     [ mc_angle2hms $anglehoraire_LP 360 ]
      set anglehoraire_LP_sec [ lindex $anglehoraire_LP 2 ]
      set anglehoraire        [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_LP 0 ] [ lindex $anglehoraire_LP 1 ] \
         [ expr int($anglehoraire_LP_sec) ]]

      #--- Angle horaire en degre
      set anglehoraire_deg [ mc_angle2deg $anglehoraire ]

      #--- Affichage de l'angle horaire
      $This.lab5 configure -text "$anglehoraire"

      #--- Effacement des cercles, du reticule et de La Polaire
      $viseurPolaireEQ6(image1) delete cadres

      #--- Dessin des 2 cercles
      $viseurPolaireEQ6(image1) create oval [ expr $widget(viseur_polaire_eq6,taille) * 12 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 12 ] [ expr $widget(viseur_polaire_eq6,taille) * 487 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 487 ] -outline $widget(viseur_polaire_eq6,couleur_reticule) \
         -tags cadres -width 2.0
      $viseurPolaireEQ6(image1) create oval [ expr $widget(viseur_polaire_eq6,taille) * 212 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 212 ] [ expr $widget(viseur_polaire_eq6,taille) * 287 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 287 ] -outline $widget(viseur_polaire_eq6,couleur_reticule) \
         -tags cadres -width 1.0

      #--- Dessin de la Polaire
      set anglehoraire_rad [ mc_angle2rad $anglehoraire_deg ]
      set PLx [ expr $widget(viseur_polaire_eq6,taille) * ( 249.5 + 35.0 * sin($anglehoraire_rad) ) ]
      set PLy [ expr $widget(viseur_polaire_eq6,taille) * ( 249.5 + 35.0 * cos($anglehoraire_rad) ) ]
      set PLx1 [ expr ( $PLx + 2 ) ]
      set PLy1 [ expr ( $PLy + 2 ) ]
      set PLx2 [ expr ( $PLx - 2 ) ]
      set PLy2 [ expr ( $PLy - 2 ) ]
      $viseurPolaireEQ6(image1) create oval $PLx1 $PLy1 $PLx2 $PLy2 -outline $widget(viseur_polaire_eq6,couleur_etoile) \
         -tags cadres -width [ expr $widget(viseur_polaire_eq6,taille) * 4.0 ]

      #--- Dessin du reticule
      $viseurPolaireEQ6(image1) create line [ expr $widget(viseur_polaire_eq6,taille) * 248.5 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 232 ] [ expr $widget(viseur_polaire_eq6,taille) * 248.5 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 267 ] -fill $widget(viseur_polaire_eq6,couleur_reticule) \
         -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $widget(viseur_polaire_eq6,taille) * 232 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 250 ] [ expr $widget(viseur_polaire_eq6,taille) * 267 ] \
         [ expr $widget(viseur_polaire_eq6,taille) * 250 ] -fill $widget(viseur_polaire_eq6,couleur_reticule) \
         -tags cadres -width 1.0

      #--- Dessin des constellations de Cassiopee et de la Grande Ourse
      ::viseurPolaireEQ6::Affich_const
   }

   #
   # viseurPolaireEQ6::HA_Cas
   # Calcule l'angle horaire des etoiles de la constellation Cassiopee
   #
   proc HA_Cas { } {
      global audace

      #--- Constellation Cassiopee J2000.0
      #--- Epsilon Cas
      set ad_cas(1)  "1h54m23.752"
      set dec_cas(1) "63d40m11.78"
      #--- Delta Cas
      set ad_cas(2)  "1h25m49.426"
      set dec_cas(2) "60d14m6.47"
      #--- Gamma Cas
      set ad_cas(3)  "0h56m42.537"
      set dec_cas(3) "60d42m59.96"
      #--- Alpha Cas
      set ad_cas(4)  "0h40m30.568"
      set dec_cas(4) "56d32m13.65"
      #--- Beta Cas
      set ad_cas(5)  "0h9m11.427"
      set dec_cas(5) "59d8m57.06"

      for {set i 1} {$i <= 5} {incr i} {
         #--- Calcul des coordonnees vraies des etoiles de Cassiopee
         set pressure             $audace(meteo,obs,pressure)
         set temperature          $audace(meteo,obs,temperature)
         set now                  [ ::audace::date_sys2ut now ]
         set hipRecord($i)        [ list "1" "0.0" [ mc_angle2deg $ad_cas($i) ] [ mc_angle2deg $dec_cas($i) ] J2000.0 0 0 0 0 ]
         set ad_dec_v($i)         [ mc_hip2tel $hipRecord($i) $now $::audace(posobs,observateur,gps) $pressure $temperature ]
         set ad_cas_vrai($i)      [ lindex $ad_dec_v($i) 0 ]
         set dec_cas_vrai($i)     [ lindex $ad_dec_v($i) 1 ]
         set anglehoraire_cas($i) [ lindex $ad_dec_v($i) 2 ]

         #--- Angle horaire
         set anglehoraire_cas($i)     [ mc_angle2hms $anglehoraire_cas($i) 360 ]
         set anglehoraire_cas_sec($i) [ lindex $anglehoraire_cas($i) 2 ]
         set anglehoraire_cas($i)     [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_cas($i) 0 ] \
            [ lindex $anglehoraire_cas($i) 1 ] [ expr int($anglehoraire_cas_sec($i)) ] ]

         #--- Angle horaire en degre
         set anglehoraire_cas_deg($i) [ mc_angle2deg $anglehoraire_cas($i) ]
         set anglehoraire_cas_deg($i) [ expr $anglehoraire_cas_deg($i) + 180.0 ]
         if { $anglehoraire_cas_deg($i) >= "360.0" } {
            set anglehoraire_cas_deg($i) [ expr $anglehoraire_cas_deg($i) - 360.0 ]
         }
      }

      return [ list $anglehoraire_cas_deg(1) $dec_cas(1) $anglehoraire_cas_deg(2) $dec_cas(2) $anglehoraire_cas_deg(3) \
         $dec_cas(3) $anglehoraire_cas_deg(4) $dec_cas(4) $anglehoraire_cas_deg(5) $dec_cas(5) ]
   }

   #
   # viseurPolaireEQ6::HA_UMa
   # Calcule l'angle horaire des etoiles de la constellation la Grande Ourse
   #
   proc HA_UMa { } {
      global audace

      #--- Constellation Grande Ourse J2000.0
      #--- Eta UMa
      set ad_uma(1)  "13h47m32.267"
      set dec_uma(1) "49d18m47.87"
      #--- Dzeta UMa
      set ad_uma(2)  "13h23m55.651"
      set dec_uma(2) "54d55m30.79"
      #--- Epsilon UMa
      set ad_uma(3)  "12h54m1.842"
      set dec_uma(3) "55d57m34.93"
      #--- Delta UMa
      set ad_uma(4)  "12h15m25.737"
      set dec_uma(4) "57d1m57.10"
      #--- Gamma UMa
      set ad_uma(5)  "11h53m49.914"
      set dec_uma(5) "53d41m41.12"
      #--- Beta UMa
      set ad_uma(6)  "11h1m50.606"
      set dec_uma(6) "56d22m57.36"
      #--- Alpha UMa
      set ad_uma(7)  "11h3m43.520"
      set dec_uma(7) "61d45m2.27"

      for {set i 1} {$i <= 7} {incr i} {
         #--- Calcul des coordonnees vraies des etoiles de la Grande Ourse
         set pressure             $audace(meteo,obs,pressure)
         set temperature          $audace(meteo,obs,temperature)
         set now                  [ ::audace::date_sys2ut now ]
         set hipRecord($i)        [ list "1" "0.0" [ mc_angle2deg $ad_uma($i) ] [ mc_angle2deg $dec_uma($i) ] J2000.0 0 0 0 0 ]
         set ad_dec_v($i)         [ mc_hip2tel $hipRecord($i) $now $::audace(posobs,observateur,gps) $pressure $temperature ]
         set ad_uma_vrai($i)      [ lindex $ad_dec_v($i) 0 ]
         set dec_uma_vrai($i)     [ lindex $ad_dec_v($i) 1 ]
         set anglehoraire_uma($i) [ lindex $ad_dec_v($i) 2 ]

         #--- Angle horaire
         set anglehoraire_uma($i)     [ mc_angle2hms $anglehoraire_uma($i) 360 ]
         set anglehoraire_uma_sec($i) [ lindex $anglehoraire_uma($i) 2 ]
         set anglehoraire_uma($i)     [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_uma($i) 0 ] \
            [ lindex $anglehoraire_uma($i) 1 ] [ expr int($anglehoraire_uma_sec($i)) ] ]

         #--- Angle horaire en degre
         set anglehoraire_uma_deg($i) [ mc_angle2deg $anglehoraire_uma($i) ]
         set anglehoraire_uma_deg($i) [ expr $anglehoraire_uma_deg($i) + 180.0 ]
         if { $anglehoraire_uma_deg($i) >= "360.0" } {
            set anglehoraire_uma_deg($i) [ expr $anglehoraire_uma_deg($i) - 360.0 ]
         }
      }

      return [ list $anglehoraire_uma_deg(1) $dec_uma(1) $anglehoraire_uma_deg(2) $dec_uma(2) $anglehoraire_uma_deg(3) \
         $dec_uma(3) $anglehoraire_uma_deg(4) $dec_uma(4) $anglehoraire_uma_deg(5) $dec_uma(5) $anglehoraire_uma_deg(6) \
         $dec_uma(6) $anglehoraire_uma_deg(7) $dec_uma(7) ]
   }

   #
   # viseurPolaireEQ6::Affich_const
   # Affichage des constellations de Cassiopee et de la Grande Ourse
   #
   proc Affich_const { } {
      variable widget
      global viseurPolaireEQ6

      #--- Calcul de l'angle horaire des etoiles de Cassiopee et de leurs rayons sur le reticule
      set donnee_cas [ ::viseurPolaireEQ6::HA_Cas ]
      for {set j 0} {$j <= 4} {incr j} {
         set index_ah [ expr 2 * $j ]
         set index_r [ expr 2 * $j + 1 ]
         set i [ expr $j + 1 ]
         set anglehoraire_cas_deg($i) [ lindex $donnee_cas $index_ah ]
         set dec_cas($i) [ lindex $donnee_cas $index_r ]
      }

      #--- Dessin des etoiles de Cassiopee
      for {set i 1} {$i <= 5} {incr i} {
         set dec_cas_rad($i) [ mc_angle2rad $dec_cas($i) ]
         set r_cas($i) [ expr 237.5 * cos($dec_cas_rad($i)) ]
         set anglehoraire_cas_rad($i) [ mc_angle2rad $anglehoraire_cas_deg($i) ]
         set PLx_cas($i) [ expr $widget(viseur_polaire_eq6,taille) * \
            ( 249.5 + $r_cas($i) * sin($anglehoraire_cas_rad($i)) ) ]
         set PLy_cas($i) [ expr $widget(viseur_polaire_eq6,taille) * \
            ( 249.5 + $r_cas($i) * cos($anglehoraire_cas_rad($i)) ) ]
         set PLx_cas_1 [ expr ( $PLx_cas($i) + 2 ) ]
         set PLy_cas_1 [ expr ( $PLy_cas($i) + 2 ) ]
         set PLx_cas_2 [ expr ( $PLx_cas($i) - 2 ) ]
         set PLy_cas_2 [ expr ( $PLy_cas($i) - 2 ) ]
         $viseurPolaireEQ6(image1) create oval $PLx_cas_1 $PLy_cas_1 $PLx_cas_2 $PLy_cas_2 \
           -outline $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres \
           -width [ expr $widget(viseur_polaire_eq6,taille) * 4.0 ]
      }

      #--- Dessin de la constellation de Cassiopee
      $viseurPolaireEQ6(image1) create line [ expr $PLx_cas(1) ] [ expr $PLy_cas(1) ] [ expr $PLx_cas(2) ] \
         [ expr $PLy_cas(2) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_cas(2) ] [ expr $PLy_cas(2) ] [ expr $PLx_cas(3) ] \
         [ expr $PLy_cas(3) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_cas(3) ] [ expr $PLy_cas(3) ] [ expr $PLx_cas(4) ] \
         [ expr $PLy_cas(4) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_cas(4) ] [ expr $PLy_cas(4) ] [ expr $PLx_cas(5) ] \
         [ expr $PLy_cas(5) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0

      #--- Calcul de l'angle horaire des etoiles de la Grande Ourse et de leurs rayons sur le reticule
      set donnee_uma [ ::viseurPolaireEQ6::HA_UMa ]
      for {set j 0} {$j <= 6} {incr j} {
         set index_ah [ expr 2 * $j ]
         set index_r [ expr 2 * $j + 1 ]
         set i [ expr $j + 1 ]
         set anglehoraire_uma_deg($i) [ lindex $donnee_uma $index_ah ]
         set dec_uma($i) [ lindex $donnee_uma $index_r ]
      }

      #--- Dessin des etoiles de la Grande Ourse
      for {set i 1} {$i <= 7} {incr i} {
         set dec_uma_rad($i) [ mc_angle2rad $dec_uma($i) ]
         set r_uma($i) [ expr 237.5 * cos($dec_uma_rad($i)) ]
         set anglehoraire_uma_rad($i) [ mc_angle2rad $anglehoraire_uma_deg($i) ]
         set PLx_uma($i) [ expr $widget(viseur_polaire_eq6,taille) * \
            ( 249.5 + $r_uma($i) * sin($anglehoraire_uma_rad($i)) ) ]
         set PLy_uma($i) [ expr $widget(viseur_polaire_eq6,taille) * \
            ( 249.5 + $r_uma($i) * cos($anglehoraire_uma_rad($i)) ) ]
         set PLx_uma_1 [ expr ( $PLx_uma($i) + 2 ) ]
         set PLy_uma_1 [ expr ( $PLy_uma($i) + 2 ) ]
         set PLx_uma_2 [ expr ( $PLx_uma($i) - 2 ) ]
         set PLy_uma_2 [ expr ( $PLy_uma($i) - 2 ) ]
         $viseurPolaireEQ6(image1) create oval $PLx_uma_1 $PLy_uma_1 $PLx_uma_2 $PLy_uma_2 \
           -outline $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres \
           -width [ expr $widget(viseur_polaire_eq6,taille) * 4.0 ]
      }

      #--- Dessin de la constellation de la Grande Ourse
      $viseurPolaireEQ6(image1) create line [ expr $PLx_uma(1) ] [ expr $PLy_uma(1) ] [ expr $PLx_uma(2) ] \
         [ expr $PLy_uma(2) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_uma(2) ] [ expr $PLy_uma(2) ] [ expr $PLx_uma(3) ] \
         [ expr $PLy_uma(3) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_uma(3) ] [ expr $PLy_uma(3) ] [ expr $PLx_uma(4) ] \
         [ expr $PLy_uma(4) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_uma(4) ] [ expr $PLy_uma(4) ] [ expr $PLx_uma(5) ] \
         [ expr $PLy_uma(5) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_uma(5) ] [ expr $PLy_uma(5) ] [ expr $PLx_uma(6) ] \
         [ expr $PLy_uma(6) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
      $viseurPolaireEQ6(image1) create line [ expr $PLx_uma(6) ] [ expr $PLy_uma(6) ] [ expr $PLx_uma(7) ] \
         [ expr $PLy_uma(7) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   }

}

