#
# Fichier : viseur_polaire_taka.tcl
# Description : Positionne l'etoile polaire dans un viseur polaire de type Takahashi ou a niveau
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::viseurPolaireTaka {

   #
   # viseurPolaireTaka::run this
   # Cree la fenetre de tests
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This
      variable widget
      global viseurPolaireTaka

      #--- Cree les variables dans conf(...) si elles n'existent pas
      ::viseurPolaireTaka::initConf
      #--- Recupere les variables dans conf(...) si elles existent
      ::viseurPolaireTaka::confToWidget
      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.but_fermer
      } else {
         if { [ info exists viseurPolaireTaka(geometry) ] } {
            set deb [ expr 1 + [ string first + $viseurPolaireTaka(geometry) ] ]
            set fin [ string length $viseurPolaireTaka(geometry) ]
            set widget(viseur_polaire_taka,position) "+[ string range $viseurPolaireTaka(geometry) $deb $fin ]"
         }
         ::viseurPolaireTaka::createDialog
         tkwait visibility $This
      }
   }

   #
   # viseurPolaireTaka::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   #
   proc ok { } {
      ::viseurPolaireTaka::recup_position
      ::viseurPolaireTaka::widgetToConf
      ::viseurPolaireTaka::fermer
   }

   #
   # viseurPolaireTaka::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      global audace

      ::viseurPolaireTaka::ok
      ::viseurPolaireTaka::run "$audace(base).viseurPolaireTaka"
   }

   #
   # viseurPolaireTaka::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      ::viseurPolaireTaka::recup_position
      destroy $This
      unset This
   }

   #
   #  viseurPolaireTaka::initConf
   #  Initialise les parametres dans le tableau conf()
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(viseur_taka,position) ] }         { set conf(viseur_taka,position)         "+110+20" }
      if { ! [ info exists conf(viseur_taka,taille) ] }           { set conf(viseur_taka,taille)           "0.5" }
      if { ! [ info exists conf(viseur_taka,couleur_fond) ] }     { set conf(viseur_taka,couleur_fond)     "#000000" }
      if { ! [ info exists conf(viseur_taka,couleur_reticule) ] } { set conf(viseur_taka,couleur_reticule) "#FFFFFF" }
      if { ! [ info exists conf(viseur_taka,couleur_etoile) ] }   { set conf(viseur_taka,couleur_etoile)   "#FFFF00" }

      return
   }

   #
   #  viseurPolaireTaka::confToWidget
   #  Copie les parametres du tableau conf() dans les variables des widgets
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(viseur_polaire_taka,position)         $conf(viseur_taka,position)
      set widget(viseur_polaire_taka,taille)           $conf(viseur_taka,taille)
      set widget(viseur_polaire_taka,couleur_fond)     $conf(viseur_taka,couleur_fond)
      set widget(viseur_polaire_taka,couleur_reticule) $conf(viseur_taka,couleur_reticule)
      set widget(viseur_polaire_taka,couleur_etoile)   $conf(viseur_taka,couleur_etoile)
   }

   #
   #  viseurPolaireTaka::widgetToConf
   #  Copie les variables des widgets dans le tableau conf()
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(viseur_taka,position)         $widget(viseur_polaire_taka,position)
      set conf(viseur_taka,taille)           $widget(viseur_polaire_taka,taille)
      set conf(viseur_taka,couleur_fond)     $widget(viseur_polaire_taka,couleur_fond)
      set conf(viseur_taka,couleur_reticule) $widget(viseur_polaire_taka,couleur_reticule)
      set conf(viseur_taka,couleur_etoile)   $widget(viseur_polaire_taka,couleur_etoile)
   }

   #
   #  viseurPolaireTaka::recup_position
   #  Recupere la position de la fenetre
   #
   proc recup_position { } {
      variable This
      variable widget
      global viseurPolaireTaka

      set viseurPolaireTaka(geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $viseurPolaireTaka(geometry) ] ]
      set fin [ string length $viseurPolaireTaka(geometry) ]
      set widget(viseur_polaire_taka,position) "+[ string range $viseurPolaireTaka(geometry) $deb $fin ]"
      #---
      ::viseurPolaireTaka::widgetToConf
   }

   #
   # viseurPolaireTaka::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      variable widget
      global audace
      global conf
      global caption
      global color
      global viseurPolaireTaka

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool viseur_polaire viseur_polaire_taka.cap ]

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm title $This $caption(viseur_taka,titre)
      wm geometry $This $widget(viseur_polaire_taka,position)
      wm resizable $This 0 0
      wm protocol $This WM_DELETE_WINDOW ::viseurPolaireTaka::fermer

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
      label $This.lab1 -text "$caption(viseur_taka,texte)"
      pack $This.lab1 -in $This.frame4 -anchor center -side left -padx 5 -pady 2

      set viseurPolaireTaka(longitude) "$conf(posobs,estouest) $conf(posobs,long)"
      label $This.labURL3 -textvariable "viseurPolaireTaka(longitude)" -fg $color(blue)
      pack $This.labURL3 -in $This.frame4 -anchor center -side right -padx 5 -pady 2

      label $This.lab2 -text "$caption(viseur_taka,long)"
      pack $This.lab2 -in $This.frame4 -anchor center -side right -padx 0 -pady 2

      label $This.lab4 -text "$caption(viseur_taka,ah_polaire)"
      pack $This.lab4 -in $This.frame5 -anchor center -side left -padx 5 -pady 2

      label $This.lab5 -anchor w
      pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 0 -pady 2

      #--- Creation d'un canvas pour l'affichage du viseur polaire
      canvas $This.image1_color_invariant -width [ expr $widget(viseur_polaire_taka,taille)*500 ] \
         -height [ expr $widget(viseur_polaire_taka,taille)*500 ] -bg $widget(viseur_polaire_taka,couleur_fond)
      pack $This.image1_color_invariant -in $This.frame6 -side top -anchor center -padx 0 -pady 0
      set viseurPolaireTaka(image1) $This.image1_color_invariant

      #--- Calcul de l'angle horaire de la Polaire et dessin du viseur polaire
      ::viseurPolaireTaka::HA_Polaire

      #--- Taille du viseur polaire
      label $This.lab10 -text "$caption(viseur_taka,taille)"
      pack $This.lab10 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

      #--- Definition de la taille de la raquette
      set list_combobox [ list 0.5 0.6 0.7 0.8 0.9 1.0 ]
      ComboBox $This.taille \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [llength $list_combobox ] \
         -relief sunken     \
         -borderwidth 1     \
         -textvariable viseurPolaireTaka::widget(viseur_polaire_taka,taille) \
         -editable 0        \
         -values $list_combobox
      pack $This.taille -in $This.frame7 -anchor center -side left -padx 5 -pady 5

      #--- Choix de la couleur du fond
      button $This.but_couleur_fond_color_invariant -relief raised -width 6 \
         -bg $widget(viseur_polaire_taka,couleur_fond) -activebackground $widget(viseur_polaire_taka,couleur_fond) \
         -command {
            set temp [tk_chooseColor -initialcolor ${viseurPolaireTaka::widget(viseur_polaire_taka,couleur_fond)} \
               -parent ${viseurPolaireTaka::widget(This)} -title ${caption(viseur_taka,couleur_fond)} ]
            if  { "$temp" != "" } {
               set viseurPolaireTaka::widget(viseur_polaire_taka,couleur_fond) "$temp"
               ${viseurPolaireTaka::widget(This)}.but_couleur_fond_color_invariant configure \
                  -bg ${viseurPolaireTaka::widget(viseur_polaire_taka,couleur_fond)}
            }
         }
      pack $This.but_couleur_fond_color_invariant -in $This.frame7 -anchor center -side right -padx 5 -pady 5

      #--- Couleur du fond
      label $This.lab_couleur_fond -text "$caption(viseur_taka,couleur_fond)"
      pack $This.lab_couleur_fond -in $This.frame7 -anchor center -side right -padx 5 -pady 5

      #--- Couleur du reticule
      label $This.lab_couleur_reticule -text "$caption(viseur_taka,couleur_reticule)"
      pack $This.lab_couleur_reticule -in $This.frame8 -anchor center -side left -padx 5 -pady 5

      #--- Choix de la couleur du reticule
      button $This.but_couleur_reticule_color_invariant -relief raised -width 6 \
         -bg $widget(viseur_polaire_taka,couleur_reticule) \
         -activebackground $widget(viseur_polaire_taka,couleur_reticule) \
         -command {
            set temp [tk_chooseColor -initialcolor ${viseurPolaireTaka::widget(viseur_polaire_taka,couleur_reticule)} \
               -parent ${viseurPolaireTaka::widget(This)} -title ${caption(viseur_taka,couleur_reticule)} ]
            if  { $temp != "" } {
               set viseurPolaireTaka::widget(viseur_polaire_taka,couleur_reticule) "$temp"
               ${viseurPolaireTaka::widget(This)}.but_couleur_reticule_color_invariant configure \
                  -bg ${viseurPolaireTaka::widget(viseur_polaire_taka,couleur_reticule)}
            }
         }
      pack $This.but_couleur_reticule_color_invariant -in $This.frame8 -anchor center -side left -padx 5 -pady 5

      #--- Choix de la couleur de la Polaire
      button $This.but_couleur_etoile_color_invariant -relief raised -width 6 \
         -bg $widget(viseur_polaire_taka,couleur_etoile) -activebackground $widget(viseur_polaire_taka,couleur_etoile) \
         -command {
            set temp [tk_chooseColor -initialcolor ${viseurPolaireTaka::widget(viseur_polaire_taka,couleur_etoile)} \
               -parent ${viseurPolaireTaka::widget(This)} -title ${caption(viseur_taka,couleur_etoile)} ]
            if  { $temp != "" } {
               set viseurPolaireTaka::widget(viseur_polaire_taka,couleur_etoile) "$temp"
               ${viseurPolaireTaka::widget(This)}.but_couleur_etoile_color_invariant configure \
                  -bg ${viseurPolaireTaka::widget(viseur_polaire_taka,couleur_etoile)}
            }
         }
      pack $This.but_couleur_etoile_color_invariant -in $This.frame8 -anchor center -side right -padx 5 -pady 5

      #--- Couleur de la Polaire
      label $This.lab_couleur_etoile -text "$caption(viseur_taka,couleur_etoile)"
      pack $This.lab_couleur_etoile -in $This.frame8 -anchor center -side right -padx 5 -pady 5

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(viseur_taka,ok)" -width 7 -borderwidth 2 \
         -command { ::viseurPolaireTaka::ok }
      if { $conf(ok+appliquer)=="1" } {
         pack $This.but_ok -in $This.frame3 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton 'Appliquer'
      button $This.but_appliquer -text "$caption(viseur_taka,appliquer)" -width 8 -borderwidth 2 \
         -command { ::viseurPolaireTaka::appliquer }
      pack $This.but_appliquer -in $This.frame3 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $This.but_fermer -text "$caption(viseur_taka,fermer)" -width 7 -borderwidth 2 \
         -command { ::viseurPolaireTaka::fermer }
      pack $This.but_fermer -in $This.frame3 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Aide'
      button $This.but_aide -text "$caption(viseur_taka,aide)" -width 7 -borderwidth 2 \
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
         set viseurPolaireTaka(longitude) "$conf(posobs,estouest) $conf(posobs,long)"
         catch {
            #--- Redessine le viseur Takahashi
            ::viseurPolaireTaka::HA_Polaire
            #--- Redessine le viseur EQ6 s'ils sont affiches tous les 2
            set viseurPolaireEQ6(longitude) $viseurPolaireTaka(longitude)
            ::viseurPolaireEQ6::HA_Polaire
         }
      }
   }

   #
   # viseurPolaireTaka::HA_Polaire
   # Calcule l'angle horaire de la Polaire et dessine le viseur polaire
   #
   proc HA_Polaire { } {
      variable This
      variable widget
      global audace
      global viseurPolaireTaka

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
      set anglehoraire        [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_LP 0 ] \
         [ lindex $anglehoraire_LP 1 ] [ expr int($anglehoraire_LP_sec) ] ]

      #--- Angle horaire en degre
      set anglehoraire_deg [ mc_angle2deg $anglehoraire ]

      #--- Affichage de l'angle horaire
      $This.lab5 configure -text "$anglehoraire"

      #--- Effacement des cercles, du reticule, des graduations et de La Polaire
      $viseurPolaireTaka(image1) delete cadres

      #--- Dessin des 3 cercles
      $viseurPolaireTaka(image1) create oval [ expr $widget(viseur_polaire_taka,taille) * 12 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 12 ] [ expr $widget(viseur_polaire_taka,taille) * 487 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 487 ] -outline $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 2.0
      $viseurPolaireTaka(image1) create oval [ expr $widget(viseur_polaire_taka,taille) * 32 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 32 ] [ expr $widget(viseur_polaire_taka,taille) * 467 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 467 ] -outline $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0
      $viseurPolaireTaka(image1) create oval [ expr $widget(viseur_polaire_taka,taille) * 52 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 52 ] [ expr $widget(viseur_polaire_taka,taille) * 447 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 447 ] -outline $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0

      #--- Dessin du reticule
      $viseurPolaireTaka(image1) create line [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 12 ] [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 245 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0
      $viseurPolaireTaka(image1) create line [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 255 ] [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 487 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0
      $viseurPolaireTaka(image1) create line [ expr $widget(viseur_polaire_taka,taille) * 12 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 250 ] [ expr $widget(viseur_polaire_taka,taille) * 245 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 250 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0
      $viseurPolaireTaka(image1) create line [ expr $widget(viseur_polaire_taka,taille) * 255 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 250 ] [ expr $widget(viseur_polaire_taka,taille) * 487 ] \
         [ expr $widget(viseur_polaire_taka,taille) * 250 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0

      #--- Coordonnees polaires et dessin des graduations longues
      for {set angle_deg 0} {$angle_deg <= 360} {incr angle_deg 15} {
         set angle_rad [ mc_angle2rad $angle_deg ]
         set x1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 237.5 * sin($angle_rad) ) ]
         set y1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 237.5 * cos($angle_rad) ) ]
         set x2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * sin($angle_rad) ) ]
         set y2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * cos($angle_rad) ) ]
         $viseurPolaireTaka(image1) create line $x1 $y1 $x2 $y2 -fill $widget(viseur_polaire_taka,couleur_reticule) \
            -tags cadres -width 1.0
      }

      #--- Coordonnees polaires et dessin des graduations courtes
      for {set angle_deg 0} {$angle_deg <= 360} {incr angle_deg 5} {
         set angle_rad [ mc_angle2rad $angle_deg ]
         set x1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * sin($angle_rad) ) ]
         set y1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * cos($angle_rad) ) ]
         set x2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * sin($angle_rad) ) ]
         set y2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * cos($angle_rad) ) ]
         $viseurPolaireTaka(image1) create line $x1 $y1 $x2 $y2 -fill $widget(viseur_polaire_taka,couleur_reticule) \
            -tags cadres -width 1.0
      }

      #--- Dessin de la position de la Polaire
      set anglehoraire_rad [ mc_angle2rad $anglehoraire_deg ]
      set PLx [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * sin($anglehoraire_rad) ) ]
      set PLy [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * cos($anglehoraire_rad) ) ]
      set PLx1 [ expr ( $PLx + 4 ) ]
      set PLy1 [ expr ( $PLy + 4 ) ]
      set PLx2 [ expr ( $PLx - 4 ) ]
      set PLy2 [ expr ( $PLy - 4 ) ]
      $viseurPolaireTaka(image1) create oval $PLx1 $PLy1 $PLx2 $PLy2 -outline $widget(viseur_polaire_taka,couleur_etoile) \
         -tags cadres -width [ expr $widget(viseur_polaire_taka,taille) * 6.0 ]
   }

}

