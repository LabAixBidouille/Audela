#
# Fichier : flat_t1m_auto.tcl
# Description : Acquisition de flat sur le ciel - Observation en automatique
# Camera : Script optimise pour une Andor ikon-L
# Auteur : Frédéric Vachier
# Mise à jour $Id:  $
#
# source audace/plugin/tool/acqt1m/flat_t1m_auto.tcl
#

namespace eval ::acqt1m_flatciel {

   #--- Charge le fichier
   # source [ file join [file dirname [info script]] flat_t1m_auto.cap ]

   proc run { visuNo } {
      variable private

      #--- Initialisation de variables de configuration
      if { ! [ info exists ::conf(acqt1m,affichageChoixFiltres,position) ] } { set ::conf(acqt1m,affichageChoixFiltres,position) "+650+120" }
      if { ! [ info exists ::conf(acqt1m,acqAutoFlat,position) ] }           { set ::conf(acqt1m,acqAutoFlat,position)           "+650+120" }

      set private(entetelog) "flatauto"
      ::acqt1m_flatciel::createDialog $visuNo
      return
   }

   proc createDialog { visuNo } {

      ::console::affiche_resultat "$::caption(flat_t1m_auto,titre1)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,titre2)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,titre3)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,titre4)\n"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,titre5)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,titre1)\n"

      set err [ ::acqt1m_flatciel::Initialisation $visuNo ]

      if {$err == 0} {
         ::acqt1m_flatciel::affichageChoixFiltres $visuNo
      }
      return
   }

   proc Initialisation { visuNo } {
      variable private

      # Activation du test du programme dans les conditions hors crepuscule : private(testprog) = 1
      set private(testprog) 0
     ### set private(testprog) 1

      # Activation des sons
      set private(sound) 1

      # Par defaut : On fait les flat en debut de nuit
      set private(sensnuit) 0

      set private($visuNo,camItem) [ ::confVisu::getCamItem $visuNo ]
      set private($visuNo,camNo)   [ ::confCam::getCamNo $private($visuNo,camItem) ]
      set private($visuNo,camera)  cam$private($visuNo,camNo)

      set err [catch {$private($visuNo,camera) info} msg]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(flat_t1m_auto,pasCamera)\n\n"

         set choix [ tk_messageBox -title $::caption(acqt1m,pb) -type ok \
            -message $::caption(acqt1m,selcam) ]
         set integre non
         if { $choix == "ok" } {
            #--- Ouverture de la fenetre de selection des cameras
            ::confCam::run
         }
         return 1
      }

      # Attente entre les mesures du ciel si c'est trop tot
      set private(attente) 30

      # % de dynamique
      set private(dynamique) 0.7

      # Temps d exposition maximum
      set private(limitexptime) 25

      # Temps d exposition minimum
      set private(exptimemini) 5

      # Initialisation de la liste des filtres
      ::t1m_roue_a_filtre::init

      # Initialisation du binning
      set private(mybin) "1x1"

      # Initialisation du nombre de flats
      set private(mynbflat) 3

      # Initialisation du carre d'analyse pour la dynamique du flat
      set private(mysquare) 50

      # Initialisation du binning de la camera
      $private($visuNo,camera) bin [list [lindex [split $private(mybin) "x"] 0] [lindex [split $private(mybin) "x"] 1]]

      set private(nbpixmax) [$private($visuNo,camera) nbpix]

      set private(maxdyn) [format "%6.f" [$private($visuNo,camera) maxdyn]]

      # Initialisation des listes
      set private(binning) {"1x1" "2x2" "3x3" "4x4"}
      set private(nbflat)  {1 2 3 4 5 6 7 8 9 10 50 100}
      set private(square)  {10 20 30 40 50 60 70 80 90 100 200 300}

      set private(rep_images)  [ file join $::audace(rep_images) "FLAT"]
      if { [file exists $private(rep_images)]==0} {
         if { [ catch {file mkdir $private(rep_images)} msg] } {
             ::console::affiche_erreur "impossible de creer le repertoire $private(rep_images)"
         }
      }

      return 0
   }

   proc Liste_sens_filtre_actif { sensnuit } {
      variable private

      set l {}
      for {set x 1} {$x<10} {incr x} {
         for {set y 1} {$y<10} {incr y} {
            if {[lindex $::t1m_roue_a_filtre::private(filtre,$y) 4] == $x} {
               if {[lindex $::t1m_roue_a_filtre::private(filtre,$y) 0] == 1} {
                  lappend l $y
               }
            }
         }
      }

      if {$sensnuit == 1} {
         set res {}
         set i [llength $l]
         while {$i > 0} {lappend res [lindex $l [incr i -1]]}
         set l $res
      }
      return $l
   }

   proc ArretScript { visuNo } {
      variable private

      $private($visuNo,camera) stop
      $private($visuNo,camera) bin [list 1 1]
      $private($visuNo,camera) window [list 1 1 [lindex $private(nbpixmax) 0] [lindex $private(nbpixmax) 1] ]
      $private($visuNo,camera) shutter synchro
      set private(stop) 1
   }

   proc push { i } {
      variable private

      if {[lindex $::t1m_roue_a_filtre::private(filtre,$i) 0] == 0} {
         $::audace(base).selection_choix.a.b$i config -bg $::audace(color,disabledTextColor)
         set ::t1m_roue_a_filtre::private(filtre,$i) [lreplace $::t1m_roue_a_filtre::private(filtre,$i) 0 0 1]
         } else {
         $::audace(base).selection_choix.a.b$i config -bg $::audace(color,backColor2)
         set ::t1m_roue_a_filtre::private(filtre,$i) [lreplace $::t1m_roue_a_filtre::private(filtre,$i) 0 0 0]
      }
   }

   proc push_sens_nuit { i } {
      variable private

      if {$i == 0} {
         $::audace(base).selection_choix.nuit.deb config -bg $::audace(color,disabledTextColor)
         $::audace(base).selection_choix.nuit.fin config -bg $::audace(color,backColor2)
         set private(sensnuit) 0
         ::console::affiche_resultat "$::caption(flat_t1m_auto,debutNuit)\n"
      } else {
         $::audace(base).selection_choix.nuit.deb config -bg $::audace(color,backColor2)
         $::audace(base).selection_choix.nuit.fin config -bg $::audace(color,disabledTextColor)
         set private(sensnuit) 1
         ::console::affiche_resultat "$::caption(flat_t1m_auto,finNuit)\n"
      }
   }

   proc init_texte_bouton_choix { } {
      variable private

      for {set x 1} {$x<10} {incr x} {
         set private(texte_bouton,$x) [concat "Filtre " [lindex $::t1m_roue_a_filtre::private(filtre,$x) 2] ]
      }
   }

   proc affichageChoixFiltres { visuNo } {
      variable private

      if { [ winfo exists $::audace(base).selection_choix ] } {
         wm withdraw $::audace(base).selection_choix
         wm deiconify $::audace(base).selection_choix
         focus $::audace(base).selection_choix
      } else {
         if { [ info exists private(geometryAffichageChoixFiltres) ] } {
            set deb [ expr 1 + [ string first + $private(geometryAffichageChoixFiltres) ] ]
            set fin [ string length $private(geometryAffichageChoixFiltres) ]
            set ::conf(acqt1m,affichageChoixFiltres,position) "+[string range $private(geometryAffichageChoixFiltres) $deb $fin]"
         }
         toplevel $::audace(base).selection_choix -class Toplevel -borderwidth 2 -relief groove
         wm geometry $::audace(base).selection_choix $::conf(acqt1m,affichageChoixFiltres,position)
         wm resizable $::audace(base).selection_choix 1 1
         wm title $::audace(base).selection_choix "Choix des filtres - Pic du Midi - T1M"
         wm transient $::audace(base).selection_choix .audace
         wm protocol $::audace(base).selection_choix WM_DELETE_WINDOW "::acqt1m_flatciel::fermerAffichageChoixFiltres $visuNo"

         ::acqt1m_flatciel::init_texte_bouton_choix

         frame $::audace(base).selection_choix.a -borderwidth 0 -relief ridge
         pack  $::audace(base).selection_choix.a -in $::audace(base).selection_choix -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         for {set x 1} {$x<10} {incr x} {
            button $::audace(base).selection_choix.a.b$x -text $private(texte_bouton,$x) -command "::acqt1m_flatciel::push $x" -bg $::audace(color,backColor2)
            pack   $::audace(base).selection_choix.a.b$x -in $::audace(base).selection_choix.a -side top -anchor n -fill x -padx 4 -pady 4 -expand 1
            }

         frame $::audace(base).selection_choix.nuit -borderwidth 0 -relief solid
         pack  $::audace(base).selection_choix.nuit -in $::audace(base).selection_choix -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

            button $::audace(base).selection_choix.nuit.deb -text "Début de Nuit" -command "::acqt1m_flatciel::push_sens_nuit 0" -bg $::audace(color,disabledTextColor)
            pack   $::audace(base).selection_choix.nuit.deb -in $::audace(base).selection_choix.nuit -anchor center -side left -fill x -padx 4 -pady 4 -ipadx 30 -expand 1
            button $::audace(base).selection_choix.nuit.fin -text "Fin de Nuit" -command "::acqt1m_flatciel::push_sens_nuit 1" -bg $::audace(color,backColor2)
            pack   $::audace(base).selection_choix.nuit.fin -in $::audace(base).selection_choix.nuit -anchor center -side left -fill x -padx 4 -pady 4 -ipadx 30 -expand 1

         frame $::audace(base).selection_choix.fin -borderwidth 0 -relief solid
         pack  $::audace(base).selection_choix.fin -in $::audace(base).selection_choix -anchor center -side top -expand 1 -fill both -padx 3 -pady 0

            button $::audace(base).selection_choix.fin.stop -text "Fermer" -command "::acqt1m_flatciel::fermerAffichageChoixFiltres $visuNo" -bg $::audace(color,backColor2)
            pack $::audace(base).selection_choix.fin.stop -in $::audace(base).selection_choix.fin -anchor center -side bottom -fill x -padx 4 -pady 4 -anchor center -expand 0

            button $::audace(base).selection_choix.fin.go -text "GO FLATS AUTO" -command "::acqt1m_flatciel::acqAutoFlat $visuNo" -bg $::audace(color,backColor2)
            pack   $::audace(base).selection_choix.fin.go -in $::audace(base).selection_choix.fin -anchor center -side bottom -fill x -padx 4 -pady 4 -expand 0

         focus $::audace(base).selection_choix
         ::confColor::applyColor $::audace(base).selection_choix
      }
   }

   #------------------------------------------------------------
   # fermerAffichageChoixFiltres
   #    Ferme la fenetre affichageChoixFiltres
   #------------------------------------------------------------
   proc fermerAffichageChoixFiltres { visuNo } {
      ::acqt1m_flatciel::ArretScript $visuNo
      ::acqt1m_flatciel::recupPositionAffichageChoixFiltres
      destroy $::audace(base).selection_choix
   }

   #------------------------------------------------------------
   # recupPositionAffichageChoixFiltres
   #    Recupere la position de la fenetre affichageChoixFiltres
   #------------------------------------------------------------
   proc recupPositionAffichageChoixFiltres { } {
      variable private

      set private(geometryAffichageChoixFiltres) [ wm geometry $::audace(base).selection_choix ]
      set deb [ expr 1 + [ string first + $private(geometryAffichageChoixFiltres) ] ]
      set fin [ string length $private(geometryAffichageChoixFiltres) ]
      set ::conf(acqt1m,affichageChoixFiltres,position) "+[string range $private(geometryAffichageChoixFiltres) $deb $fin]"
   }

   proc init_texte_bouton_filtre { } {
      variable private

      for {set x 1} {$x<10} {incr x} {
         set private(texte_bouton,$x) [concat "($x) - Filtre " [lindex $::t1m_roue_a_filtre::private(filtre,$x) 1] " - Nbre =" [lindex $::t1m_roue_a_filtre::private(filtre,$x) 3]]
      }
   }

   proc Changebin { visuNo mybin } {
      variable private

      $private($visuNo,camera) bin [list [lindex [split $mybin "x"] 0] [lindex [split $mybin "x"] 1]]
      set nbpix [$private($visuNo,camera) nbpix]
      $::audace(base).selection_filtre.a2.lb4 config -text $nbpix
   }

   proc majbouton { i fin} {
      variable private

      set private(texte_bouton,$i) [concat "($i) - Filtre " [lindex $::t1m_roue_a_filtre::private(filtre,$i) 1] " - Nbre =" [lindex $::t1m_roue_a_filtre::private(filtre,$i) 3]]
      $::audace(base).selection_filtre.filtres.$i config -text $private(texte_bouton,$i)
      if {$fin == 1} {
         $::audace(base).selection_filtre.filtres.$i config -bg $::audace(color,disabledTextColor)
      }

   }

   proc acqAutoFlat { visuNo } {
      variable private

      if { [ winfo exists $::audace(base).selection_filtre ] } {
         destroy $::audace(base).selection_filtre
      }

      if { [ info exists private(geometryAcqAutoFlat) ] } {
         set deb [ expr 1 + [ string first + $private(geometryAcqAutoFlat) ] ]
         set fin [ string length $private(geometryAcqAutoFlat) ]
         set ::conf(acqt1m,acqAutoFlat,position) "+[string range $private(geometryAcqAutoFlat) $deb $fin]"
      }
      set listeFiltreActif [ ::acqt1m_flatciel::Liste_sens_filtre_actif $private(sensnuit) ]
      set sizey [expr 210 + [llength $listeFiltreActif] * 40]

      toplevel $::audace(base).selection_filtre -class Toplevel -borderwidth 2 -relief groove
      wm geometry $::audace(base).selection_filtre 530x$sizey$::conf(acqt1m,acqAutoFlat,position)
      wm resizable $::audace(base).selection_filtre 1 1
      wm title $::audace(base).selection_filtre "Acquisition des flats auto - Pic du Midi - T1M"
      wm transient $::audace(base).selection_filtre .audace
      wm protocol $::audace(base).selection_filtre WM_DELETE_WINDOW "::acqt1m_flatciel::fermerAcqAutoFlat $visuNo"

      ::acqt1m_flatciel::init_texte_bouton_filtre

      if {$private(sensnuit) == 0} {
         set info_sens_nuit "Début de nuit"
      } else {
         set info_sens_nuit "Fin de nuit"
      }

      set private(stop) 0

      set info [$private($visuNo,camera) info]
      set size [$private($visuNo,camera) nbcells]
      set nbcells [$private($visuNo,camera) nbcells]
      set gain [format "%4.2f" [$private($visuNo,camera) gain]]
      set temperature [format "%4.1f" [$private($visuNo,camera) temperature]]
      set nbpix [$private($visuNo,camera) nbpix]

      set info0 "Caméra : [$private($visuNo,camera) info]"
      set info1 "Pixels actifs : $nbcells / ADU max : $private(maxdyn) / Gain : $gain / Température : $temperature"

      frame $::audace(base).selection_filtre.a0 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.a0 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.a0.camval -text $info0 -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a0.camval -in $::audace(base).selection_filtre.a0 -side left -anchor w -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.ae2 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.ae2 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.ae2.repimg -text "Répertoire des images : $private(rep_images)" -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.ae2.repimg -in $::audace(base).selection_filtre.ae2 -side left -anchor w -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.a1 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.a1 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.a1.camval -text $info1 -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a1.camval -in $::audace(base).selection_filtre.a1 -side left -anchor w -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.b -borderwidth 0 -relief solid
      pack $::audace(base).selection_filtre.b -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

      #--- Binning
      menubutton $::audace(base).selection_filtre.b.bin -text "Binning" -relief raised \
         -menu $::audace(base).selection_filtre.b.bin.menu
      pack $::audace(base).selection_filtre.b.bin -side left
      set m [menu $::audace(base).selection_filtre.b.bin.menu -tearoff 0]
      foreach n $private(binning) {
         $m add radiobutton -label "$n" \
            -indicatoron "1" \
            -value "$n" \
            -variable ::acqt1m_flatciel::private(mybin) \
            -command "::acqt1m_flatciel::Changebin $visuNo $private(mybin)"
      }
      #--- Ligne de saisie
      entry $::audace(base).selection_filtre.b.val -width 4 -textvariable ::acqt1m_flatciel::private(mybin) \
         -relief groove -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $::audace(base).selection_filtre.b.val -side left -fill y

      #--- Nombre de Flat
      menubutton $::audace(base).selection_filtre.b.nbi -text "Nombre de flat" -relief raised \
         -menu $::audace(base).selection_filtre.b.nbi.menu
      pack $::audace(base).selection_filtre.b.nbi -side left
      set m [menu $::audace(base).selection_filtre.b.nbi.menu -tearoff 0]
      foreach n $private(nbflat) {
         $m add radiobutton -label "$n" \
            -indicatoron "1" \
            -value "$n" \
            -variable ::acqt1m_flatciel::private(mynbflat) \
            -command {::console::affiche_resultat "$::caption(flat_t1m_auto,nbFlat) $::acqt1m_flatciel::private(mynbflat)\n" }
      }
      #--- Ligne de saisie
      entry $::audace(base).selection_filtre.b.nbival -width 4 -textvariable ::acqt1m_flatciel::private(mynbflat) \
         -relief groove -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $::audace(base).selection_filtre.b.nbival -side left -fill y

      #--- Carre de mesure de l'intensite pour le calcul du temps de pose
      menubutton $::audace(base).selection_filtre.b.sqr -text "Size Square" -relief raised \
         -menu $::audace(base).selection_filtre.b.sqr.menu
      pack $::audace(base).selection_filtre.b.sqr -side left
      set m [menu $::audace(base).selection_filtre.b.sqr.menu -tearoff 0]
      foreach n $private(square) {
         $m add radiobutton -label "$n" \
            -indicatoron "1" \
            -value "$n" \
            -variable ::acqt1m_flatciel::private(mysquare) \
            -command { }
      }
      #--- Ligne de saisie
      entry $::audace(base).selection_filtre.b.sqrval -width 4 -textvariable ::acqt1m_flatciel::private(mysquare) \
         -relief groove -justify center \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      pack $::audace(base).selection_filtre.b.sqrval -side left -fill y

      frame $::audace(base).selection_filtre.a2 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.a2 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.a2.lb1 -text "Obturateur :" -borderwidth 0 -relief flat
         pack  $::audace(base).selection_filtre.a2.lb1 -in $::audace(base).selection_filtre.a2 -side left -anchor w -padx 4 -pady 4 -expand 0
         label $::audace(base).selection_filtre.a2.lb2 -text [$private($visuNo,camera) shutter] -borderwidth 0 -relief flat
         pack  $::audace(base).selection_filtre.a2.lb2 -in $::audace(base).selection_filtre.a2 -side left -anchor w -padx 4 -pady 4 -expand 0
         label $::audace(base).selection_filtre.a2.lb3 -text "           Nombre de pixels :" -borderwidth 0 -relief flat
         pack  $::audace(base).selection_filtre.a2.lb3 -in $::audace(base).selection_filtre.a2 -side left -anchor e -padx 4 -pady 4 -expand 0
         label $::audace(base).selection_filtre.a2.lb4 -text $nbpix -borderwidth 0 -relief flat
         pack  $::audace(base).selection_filtre.a2.lb4 -in $::audace(base).selection_filtre.a2 -side left -anchor e -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.filtres -borderwidth 0 -relief solid
      pack  $::audace(base).selection_filtre.filtres -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         foreach x $listeFiltreActif {
            button $::audace(base).selection_filtre.filtres.$x -text $private(texte_bouton,$x) -command "::acqt1m_flatciel::acqFlat $visuNo $x" -bg $::audace(color,backColor2)
            pack   $::audace(base).selection_filtre.filtres.$x -in $::audace(base).selection_filtre.filtres -side top -anchor center -fill x -padx 4 -pady 4 -expand 1
         }

      frame $::audace(base).selection_filtre.f -borderwidth 0 -relief solid
      pack $::audace(base).selection_filtre.f -in $::audace(base).selection_filtre -anchor s -side bottom -expand 0 -fill both -padx 3 -pady 0

         button $::audace(base).selection_filtre.f.fin -text "STOP" -command "::acqt1m_flatciel::fermerAcqAutoFlat $visuNo" -bg $::audace(color,backColor2)
         pack $::audace(base).selection_filtre.f.fin -in $::audace(base).selection_filtre.f -anchor center -side top -fill x -padx 4 -pady 4 -anchor center -expand 1

      frame $::audace(base).selection_filtre.g -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.g -in $::audace(base).selection_filtre -anchor s -side bottom -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.g.sens -text $info_sens_nuit -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.g.sens -in $::audace(base).selection_filtre.g -side left -anchor w -padx 4 -pady 4 -expand 0

      focus $::audace(base).selection_filtre
      ::confColor::applyColor $::audace(base).selection_filtre
   }

   #------------------------------------------------------------
   # fermerAcqAutoFlat
   #    Ferme la fenetre acqAutoFlat
   #------------------------------------------------------------
   proc fermerAcqAutoFlat { visuNo } {
      ::acqt1m_flatciel::ArretScript $visuNo
      ::acqt1m_flatciel::recupPositionAcqAutoFlat
      destroy $::audace(base).selection_filtre
   }

   #------------------------------------------------------------
   # recupPositionAcqAutoFlat
   #    Recupere la position de la fenetre acqAutoFlat
   #------------------------------------------------------------
   proc recupPositionAcqAutoFlat { } {
      variable private

      set private(geometryAcqAutoFlat) [ wm geometry $::audace(base).selection_filtre ]
      set deb [ expr 1 + [ string first + $private(geometryAcqAutoFlat) ] ]
      set fin [ string length $private(geometryAcqAutoFlat) ]
      set ::conf(acqt1m,acqAutoFlat,position) "+[string range $private(geometryAcqAutoFlat) $deb $fin]"
   }

   proc acqFlat { visuNo idfiltre } {
      variable private

      set attentems [expr $private(attente) * 1000]

      set nbpix [$private($visuNo,camera) nbpix]
      set xcent [expr [lindex $nbpix 0]/2]
      set ycent [expr [lindex $nbpix 1]/2]
      set xmin  [expr $xcent - $private(mysquare) / 2]
      set ymin  [expr $ycent - $private(mysquare) / 2]
      set xmax  [expr $xcent + $private(mysquare) / 2]
      set ymax  [expr $ycent + $private(mysquare) / 2]

      set fondflat [expr $private(maxdyn) * $private(dynamique)]

      ::console::affiche_saut "\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,debutAcq) [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2]\n"

      ::console::affiche_resultat "$::caption(flat_t1m_auto,tailleImage) $nbpix\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,nbFlatDemande) $private(mynbflat)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,tailleFenetre) $private(mysquare)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,limitexptime) $private(limitexptime)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,exptimemini) $private(exptimemini)\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,fondflat1) $fondflat\n"

      set buffer buf$::audace(bufNo)

      # Dark
      $private($visuNo,camera) exptime 1
      ::console::affiche_resultat "$::caption(flat_t1m_auto,mesureDark)\n"
      $private($visuNo,camera) window [list $xmin $ymin $xmax $ymax]
      $private($visuNo,camera) shutter closed
      $::audace(base).selection_filtre.a2.lb2 config -text [$private($visuNo,camera) shutter]
      $private($visuNo,camera) acq -blocking
      $buffer save "mesurefond"
      #--- Visualisation de l'image
      #::audace::autovisu $visuNo
      set stat  [$buffer stat]
      set dark  [lindex $stat 4]
      set stdev [lindex $stat 5]
      ::console::affiche_resultat "$::caption(flat_t1m_auto,fluxMoyen) $dark\n"
      ::console::affiche_resultat "$::caption(flat_t1m_auto,ecartType) $stdev\n"

      $private($visuNo,camera) shutter synchro
      $::audace(base).selection_filtre.a2.lb2 config -text [$private($visuNo,camera) shutter]

      # Boucle sur les images
      set num 1

      for {set id 0} {$id<$private(mynbflat)} {incr id} {

         set exptime 1

         if {$private(testprog) == 0} {
            while {$exptime > 0} {

               # Fond du ciel
               $private($visuNo,camera) exptime 1
               ::console::affiche_resultat "$::caption(flat_t1m_auto,mesureCiel) [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2] :\n"
               $private($visuNo,camera) window [list $xmin $ymin $xmax $ymax]
               $private($visuNo,camera) acq -blocking
               $buffer save "mesurefond"

               #--- Visualisation de l'image
               #::audace::autovisu $visuNo
               set stat  [$buffer stat]
               set ciel  [lindex $stat 4]
               set stdev [lindex $stat 5]
               ::console::affiche_resultat "$::caption(flat_t1m_auto,fluxMoyen) $ciel\n"
               ::console::affiche_resultat "$::caption(flat_t1m_auto,ecartType) $stdev\n"

               if {[expr $ciel+$stdev]<$private(maxdyn)} {

                  #--- image non saturee
                  set exptime [expr $fondflat/($ciel - $dark)]
                  if {$exptime<0} {
                     ::console::affiche_resultat "\n\n$::caption(flat_t1m_auto,probleme)\n"
                     ::console::affiche_resultat "$::caption(flat_t1m_auto,verification)\n"
                     exit
                  }

                  #--- depassement du temps d exposition limite
                  ::console::affiche_resultat "$::caption(flat_t1m_auto,estimationExptime) $private(exptimemini) < $exptime < $private(limitexptime)\n"

                  if {$exptime>$private(limitexptime)} {
                     set exptime $private(limitexptime)
                     if {$private(sensnuit) == 1} {
                        #--- il fait trop nuit, donc on attend
                        ::console::affiche_resultat "$::caption(flat_t1m_auto,tropNuit) $private(attente) $::caption(flat_t1m_auto,secondes)\n"
                        after $attentems
                     } else {
                        #--- il fait trop nuit, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(flat_t1m_auto,tropTard1)\n\n"
                        return
                     }
                  } else {
                     if {$exptime<$private(exptimemini)} {
                        if {$private(sensnuit) == 1} {
                           #--- il fait trop jour, donc c'est foutu
                           ::console::affiche_resultat "\n\n$::caption(flat_t1m_auto,tropTard2)\n\n"
                           return
                        } else {
                           #--- il fait trop jour, donc on attend
                           ::console::affiche_resultat "$::caption(flat_t1m_auto,tropJour) $private(attente) $::caption(flat_t1m_auto,secondes)\n"
                           after $attentems
                        }
                     } else {
                        #--- image non saturee, et limited exposition non atteinte -> ok on y va
                        break
                     }
                  }

               } else {

                  #--- Saturation on divise le temps d exposition par 3
                  set exptime [expr $exptime / 3.]

                  ::console::affiche_resultat "$::caption(flat_t1m_auto,estimationExptime) $exptime > $private(exptimemini)\n"
                  #--- si le temps d exposition est trop court
                  if {$exptime<$private(exptimemini)} {

                     if {$private(sensnuit) == 0} {
                        #--- il fait trop jour, donc on attend
                        set exptime $private(exptimemini)
                        ::console::affiche_resultat "$::caption(flat_t1m_auto,tropJour) $private(attente) $::caption(flat_t1m_auto,secondes)\n"
                        after $attentems
                     } else {
                        #--- il fait trop jour, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(flat_t1m_auto,tropTard2)\n\n"
                        return
                     }

                  }

               }

               if {$private(stop) == 1} {
                  ::console::affiche_resultat "$::caption(flat_t1m_auto,arretDemande)\n"
                  return
               }

            }
         }

         # Flat :
         #

         ::console::affiche_resultat "$::caption(flat_t1m_auto,parti) ([expr $id+1]/$private(mynbflat)) : $::caption(flat_t1m_auto,prochainExptime) $exptime\n"
         $private($visuNo,camera) exptime $exptime
         $private($visuNo,camera) window [list 1 1 [lindex $private(nbpixmax) 0] [lindex $private(nbpixmax) 1] ]
         $private($visuNo,camera) shutter synchro
         $private($visuNo,camera) acq -blocking

         #--- Visualisation de l'image
         ::audace::autovisu $visuNo
         set stat   [$buffer stat]
         set pixmin [lindex $stat 3]
         set pixmax [lindex $stat 2]
         set ciel   [lindex $stat 4]
         set stdev  [lindex $stat 5]
         ::console::affiche_resultat "$::caption(flat_t1m_auto,mesureFlat)\n"
         ::console::affiche_resultat "$::caption(flat_t1m_auto,fluxMoyen) $ciel\n"
         ::console::affiche_resultat "$::caption(flat_t1m_auto,ecartType) $stdev\n"
         ::console::affiche_resultat "$::caption(flat_t1m_auto,pixelMiniMaxi) $pixmax / $pixmin\n"

         set nouv   [expr $ciel / $private(maxdyn)]
         set offset [expr $private(dynamique) - ($ciel / $private(maxdyn))]

         ::console::affiche_resultat "$::caption(flat_t1m_auto,offset) $offset\n"
         ::console::affiche_resultat "$::caption(flat_t1m_auto,nouv) $nouv\n"
         ::console::affiche_resultat "$::caption(flat_t1m_auto,maxdyn) $private(maxdyn)\n"
         set fondflat [expr $private(maxdyn) * ($fondflat/$private(maxdyn) + $offset)]
         #49151,25/65535 = 0.75
         ::console::affiche_resultat "$::caption(flat_t1m_auto,fondflat2) $fondflat\n"

         set enr 0
         while {$enr == 0} {
            set entete [ mc_date2ymdhms [ ::audace::date_sys2ut now] ]
            set pos  [string first "." [lindex $entete 5]]
            set sec  [string range [lindex $entete 5] 0 [expr $pos-1]]
            set date [ format "%04d%02d%02dT%02d%02d%02d" [lindex $entete 0] [lindex $entete 1] [lindex $entete 2] [lindex $entete 3] [lindex $entete 4] $sec]
            set file [ file join $private(rep_images) "T1M.$date.FLAT_[lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 1]_$num" ]
            if {$private(testprog) == 1} {set file [ file join $private(rep_images) "$entete.TEST_[lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 1]_$num" ]}
            set filelong "$file$::conf(extension,defaut)"
            if {[file exists $filelong]==0} {
               #--- Rajoute des mots cles dans l'en-tete FITS
               foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqt1m,keywordConfigName) ] {
                  $buffer setkwd $keyword
               }
               #--- Rajoute d'autres mots cles
               $buffer setkwd [list "IMAGETYP" "Flat" string "" "" ]
               $buffer setkwd [list "TELESCOP" "t1m" string "Telescope name" ""]
               $buffer setkwd [list "OBJECT"   "FLAT" string "" "" ]
               $buffer setkwd [list "FILTER"   [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2] string "" "" ]
               saveima $filelong $visuNo
               ::console::affiche_resultat "$::caption(flat_t1m_auto,enregistre) $filelong\n"
               set enr 1
               incr num
            } else {
               incr num
            }
         }

         if {$num>$private(mynbflat)} {set num $private(mynbflat)}
         set ::t1m_roue_a_filtre::private(filtre,$idfiltre) [lreplace $::t1m_roue_a_filtre::private(filtre,$idfiltre) 3 3 $num]
         ::acqt1m_flatciel::majbouton $idfiltre 0
      }

      ::acqt1m_flatciel::majbouton $idfiltre 1
      ::console::affiche_resultat "$::caption(flat_t1m_auto,finAcq) [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2]\n\n"
   }


}

