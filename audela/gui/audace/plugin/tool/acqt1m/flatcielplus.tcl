#
# Fichier : flatcielplus.tcl
# Description : Acquisition de flat sur le ciel - Observation en automatique
# Camera : Script optimise pour une Andor ikon-L
# Auteur : Frédéric Vachier
# Mise à jour $Id$
#
# source audace/plugin/tool/acqt1m/acqt1m_flatcielplus.tcl
#

namespace eval ::acqt1m_flatcielplus {


















   proc ::acqt1m_flatcielplus::run { visuNo } {
      variable private

      #--- Initialisation de variables de configuration
      if { ! [ info exists ::conf(acqt1m,affichageChoixFiltres,position) ] } { set ::conf(acqt1m,affichageChoixFiltres,position) "+650+120" }
      if { ! [ info exists ::conf(acqt1m,acqAutoFlat,position) ] }           { set ::conf(acqt1m,acqAutoFlat,position)           "+650+120" }
      if { ! [ info exists ::conf(acqt1m,avancement1,position) ] }           { set ::conf(acqt1m,avancement1,position)           "+700+300" }

      if { [ winfo exists $::audace(base).selection_choix ] } {
         wm withdraw $::audace(base).selection_choix
         wm deiconify $::audace(base).selection_choix
         focus $::audace(base).selection_choix
      } else {
         ::acqt1m_flatcielplus::createDialog $visuNo
      }
      return
   }



















   #------------------------------------------------------------
   # createDialog
   #    Creation de l'interface graphique
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::createDialog { visuNo } {
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,titre1)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,titre2)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,titre3)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,titre4)\n"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,titre5)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,titre1)\n"

      set err [ ::acqt1m_flatcielplus::Initialisation $visuNo ]

      if {$err == 0} {
         ::acqt1m_flatcielplus::affichageChoixFiltres $visuNo
      }
      return
   }



















   proc ::acqt1m_flatcielplus::Initialisation { visuNo } {
      variable private

      # Activation du programme dans des conditions de test hors crepuscule : private(testprog) = 1
      # Activation du programme dans les conditions d'observation           : private(testprog) = 0
      set private(testprog) 0
     ### set private(testprog) 1

      # Par defaut : On fait les flats en debut de nuit
      set private(sensnuit) 0

      # Raccourcis pratiques lies a la camera
      set private($visuNo,camItem) [ ::confVisu::getCamItem $visuNo ]
      set private($visuNo,camNo)   [ ::confCam::getCamNo $private($visuNo,camItem) ]
      set private($visuNo,camera)  cam$private($visuNo,camNo)

      # Teste la presence d'une camera connectee
      set err [catch {$private($visuNo,camera) info} msg]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,pasCamera)\n\n"
         set choix [ tk_messageBox -title $::caption(acqt1m_flatcielplus,pb) -type ok \
            -message $::caption(acqt1m_flatcielplus,selcam) ]
         set integre non
         if { $choix == "ok" } {
            #--- Ouverture de la fenetre de selection des cameras
            ::confCam::run
         }
         return 1
      }

      # Attente entre les mesures du ciel si c'est trop tot
      set private(attente) 60

      # % de dynamique
      set private(mydynamique) 0.5

      # Temps d'exposition maximum
      set private(limitexptime) 35

      # Temps d'exposition minimum
      set private(exptimemini) 5

      # Initialisation de la liste des filtres
      ::t1m_roue_a_filtre::init

      # Initialisation du binning (identique a celui de l'interface principale)
      set private(mybin) $::panneau(acqt1m,$visuNo,binning)

      # Initialisation du nombre de flats
      set private(mynbflat) 10

      # Initialisation du carre d'analyse pour la dynamique du flat
      set private(mysquare) 50

      # Initialisation du nombre de photosites
      set private(nbcells) [$private($visuNo,camera) nbcells]

      # Initialisation de la dynamique maximale
      set private(maxdyn) [format "%6.f" [$private($visuNo,camera) maxdyn]]

      # Initialisation des listes
      set private(binning)   {"1x1" "2x2" "3x3" "4x4"}
      set private(nbflat)    {1 2 3 4 5 6 7 8 9 10 50 100}
      set private(square)    {10 20 30 40 50 60 70 80 90 100 200 300}
      set private(dynamique) {0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9}

      # Initialisation du repertoire
      set private(rep_images) [ file join $::audace(rep_images) "CALIB" ]
      if { [file exists $private(rep_images)]==0} {
         if { [ catch {file mkdir $private(rep_images)} msg] } {
             ::console::affiche_erreur "$::caption(acqt1m_flatcielplus,msgRepertoire) $private(rep_images)/n"
         }
      }

      # Initialisation des variables de surveillance
      set private(pose_en_cours) 0
      set private(demande_stop)  0

      # Initialisation des variables de gestion de l'avancement
      set private(avancement_acq)       1
      set private(dispTimeAfterId)      ""
      set private(avancement1,position) $::conf(acqt1m,avancement1,position)


      set private(working) 0

      return 0
   }



















   proc ::acqt1m_flatcielplus::listeSensFiltreActif { sensnuit } {
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



















   #------------------------------------------------------------
   # arretAcqFlat
   #    Arret de l'acquisition des flats
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::arretAcqFlat { visuNo } {
      variable private

      #--- Je positionne l'indicateur d'arret de la pose
      set private(demande_stop) 1

      #--- Arret de la capture de l'image
      ::camera::stopAcquisition $private($visuNo,camItem)
      #--- J'attends la fin de l'acquisition
      vwait ::acqt1m_flatcielplus::private(finAquisition)

      # Initialisation de la camera (image pleine trame et obturateur synchro)
      $private($visuNo,camera) window [list 1 1 [lindex $private(nbcells) 0] [lindex $private(nbcells) 1] ]
      $private($visuNo,camera) shutter synchro

      #--- Message
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,arretDemande)\n"
   }



















   proc ::acqt1m_flatcielplus::push { i } {
      variable private

      if {[lindex $::t1m_roue_a_filtre::private(filtre,$i) 0] == 0} {
         $::audace(base).selection_choix.a.b$i configure -bg $::audace(color,disabledTextColor)
         set ::t1m_roue_a_filtre::private(filtre,$i) [lreplace $::t1m_roue_a_filtre::private(filtre,$i) 0 0 1]
         } else {
         $::audace(base).selection_choix.a.b$i configure -bg $::audace(color,backColor2)
         set ::t1m_roue_a_filtre::private(filtre,$i) [lreplace $::t1m_roue_a_filtre::private(filtre,$i) 0 0 0]
      }
   }



















   proc ::acqt1m_flatcielplus::pushSensNuit { i } {
      variable private

      if {$i == 0} {
         $::audace(base).selection_choix.nuit.deb configure -bg $::audace(color,disabledTextColor)
         $::audace(base).selection_choix.nuit.fin configure -bg $::audace(color,backColor2)
         set private(sensnuit) 0
         set info_sens_nuit $::caption(acqt1m_flatcielplus,butDebutNuit)
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,debutNuit)\n"
      } else {
         $::audace(base).selection_choix.nuit.deb configure -bg $::audace(color,backColor2)
         $::audace(base).selection_choix.nuit.fin configure -bg $::audace(color,disabledTextColor)
         set private(sensnuit) 1
         set info_sens_nuit $::caption(acqt1m_flatcielplus,butFinNuit)
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,finNuit)\n"
      }
      if { [ winfo exists $::audace(base).selection_filtre.g.sens ] } {
         $::audace(base).selection_filtre.g.sens configure -text $info_sens_nuit
      }
   }



















   proc ::acqt1m_flatcielplus::initTexteBoutonChoix { } {
      variable private

      for {set x 1} {$x<10} {incr x} {
         set private(texte_bouton,$x) [concat "$::caption(acqt1m_flatcielplus,filtre) " [lindex $::t1m_roue_a_filtre::private(filtre,$x) 2] ]
      }
   }



















   #------------------------------------------------------------
   # affichageChoixFiltres
   #    Interface graphique de la fenetre de choix des filtres
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::affichageChoixFiltres { visuNo } {
      variable private

      if { [ info exists private(geometryAffichageChoixFiltres) ] } {
         set deb [ expr 1 + [ string first + $private(geometryAffichageChoixFiltres) ] ]
         set fin [ string length $private(geometryAffichageChoixFiltres) ]
         set ::conf(acqt1m,affichageChoixFiltres,position) "+[string range $private(geometryAffichageChoixFiltres) $deb $fin]"
      }
      toplevel $::audace(base).selection_choix -class Toplevel -borderwidth 2 -relief groove
      wm geometry $::audace(base).selection_choix $::conf(acqt1m,affichageChoixFiltres,position)
      wm resizable $::audace(base).selection_choix 1 1
      wm title $::audace(base).selection_choix $::caption(acqt1m_flatcielplus,choixFiltres)
      wm transient $::audace(base).selection_choix .audace
      wm protocol $::audace(base).selection_choix WM_DELETE_WINDOW "::acqt1m_flatcielplus::fermerAffichageChoixFiltres $visuNo"

      ::acqt1m_flatcielplus::initTexteBoutonChoix

      frame $::audace(base).selection_choix.a -borderwidth 0 -relief ridge
      pack  $::audace(base).selection_choix.a -in $::audace(base).selection_choix -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

      for {set x 1} {$x<10} {incr x} {
         button $::audace(base).selection_choix.a.b$x -text $private(texte_bouton,$x) -command "::acqt1m_flatcielplus::push $x" -bg $::audace(color,backColor2)
         pack   $::audace(base).selection_choix.a.b$x -in $::audace(base).selection_choix.a -side top -anchor n -fill x -padx 4 -pady 4 -expand 1
         }

      frame $::audace(base).selection_choix.nuit -borderwidth 0 -relief solid
      pack  $::audace(base).selection_choix.nuit -in $::audace(base).selection_choix -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         button $::audace(base).selection_choix.nuit.deb -text $::caption(acqt1m_flatcielplus,butDebutNuit) -command "::acqt1m_flatcielplus::pushSensNuit 0" -bg $::audace(color,disabledTextColor)
         pack   $::audace(base).selection_choix.nuit.deb -in $::audace(base).selection_choix.nuit -anchor center -side left -fill x -padx 4 -pady 4 -ipadx 30 -expand 1
         button $::audace(base).selection_choix.nuit.fin -text $::caption(acqt1m_flatcielplus,butFinNuit) -command "::acqt1m_flatcielplus::pushSensNuit 1" -bg $::audace(color,backColor2)
         pack   $::audace(base).selection_choix.nuit.fin -in $::audace(base).selection_choix.nuit -anchor center -side left -fill x -padx 4 -pady 4 -ipadx 30 -expand 1

      frame $::audace(base).selection_choix.fin -borderwidth 0 -relief solid
      pack  $::audace(base).selection_choix.fin -in $::audace(base).selection_choix -anchor center -side top -expand 1 -fill both -padx 3 -pady 0

         button $::audace(base).selection_choix.fin.stop -text $::caption(acqt1m_flatcielplus,fermer) -command "::acqt1m_flatcielplus::fermerAffichageChoixFiltres $visuNo" -bg $::audace(color,backColor2)
         pack $::audace(base).selection_choix.fin.stop -in $::audace(base).selection_choix.fin -anchor center -side bottom -fill x -padx 4 -pady 4 -expand 0

         button $::audace(base).selection_choix.fin.go -text $::caption(acqt1m_flatcielplus,goFlatsAuto) -command "::acqt1m_flatcielplus::acqAutoFlat $visuNo" -bg $::audace(color,backColor2)
         pack   $::audace(base).selection_choix.fin.go -in $::audace(base).selection_choix.fin -anchor center -side bottom -fill x -padx 4 -pady 4 -expand 0

      focus $::audace(base).selection_choix
      ::confColor::applyColor $::audace(base).selection_choix
   }



















   #------------------------------------------------------------
   # fermerAffichageChoixFiltres
   #    Ferme la fenetre affichageChoixFiltres
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::fermerAffichageChoixFiltres { visuNo } {
      ::acqt1m_flatcielplus::recupPositionAffichageChoixFiltres
      destroy $::audace(base).selection_choix
   }



















   #------------------------------------------------------------
   # recupPositionAffichageChoixFiltres
   #    Recupere la position de la fenetre affichageChoixFiltres
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::recupPositionAffichageChoixFiltres { } {
      variable private

      set private(geometryAffichageChoixFiltres) [ wm geometry $::audace(base).selection_choix ]
      set deb [ expr 1 + [ string first + $private(geometryAffichageChoixFiltres) ] ]
      set fin [ string length $private(geometryAffichageChoixFiltres) ]
      set ::conf(acqt1m,affichageChoixFiltres,position) "+[string range $private(geometryAffichageChoixFiltres) $deb $fin]"
   }



















   proc ::acqt1m_flatcielplus::initTexteBoutonFiltre { } {
      variable private

      for {set x 1} {$x<10} {incr x} {
         set private(texte_bouton,$x) [concat "($x) - $::caption(acqt1m_flatcielplus,filtre) " [lindex $::t1m_roue_a_filtre::private(filtre,$x) 1] " - $::caption(acqt1m_flatcielplus,nbre) =" 0]
         gren_info "private(filtre,$x) : $::t1m_roue_a_filtre::private(filtre,$x)\n"
      }
   }










#--- Procedure de changement du binning
proc ::acqt1m_flatcielplus::changerBinningCent { { visuNo 1 } } {
   global audace caption panneau

   switch -exact -- $panneau(acqt1m,$visuNo,binning) {
      "1x1" {
         set panneau(acqt1m,$visuNo,binning) "2x2"
      }
      "2x2" {
         set panneau(acqt1m,$visuNo,binning) "4x4"
      }
      "4x4" {
         set panneau(acqt1m,$visuNo,binning) "1x1"
      }
   }
   #::console::affiche_resultat "bin = $caption(acqt1m,bin,$panneau(acqt1m,$visuNo,binning))\n"
   $panneau(acqt1m,$visuNo,This).binningt.but configure -text $caption(acqt1m,bin,$panneau(acqt1m,$visuNo,binning))
   if { [ winfo exists $audace(base).selection_filtre ] } {
      ::acqt1m_flatcielplus::changeBin $visuNo $panneau(acqt1m,$visuNo,binning)
   }
}









   #------------------------------------------------------------
   # changeBin
   #    Changement du binning
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::changeBin { visuNo mybin } {

      variable private

      $::audace(base).selection_filtre.b.bin configure -text $::caption(acqt1m,bin,$::panneau(acqt1m,$visuNo,binning))

      set mybin $::panneau(acqt1m,$visuNo,binning)

      $private($visuNo,camera) bin [list [lindex [split $mybin "x"] 0] [lindex [split $mybin "x"] 1]]
      set nbpix [$private($visuNo,camera) nbpix]
      $::audace(base).selection_filtre.a2.lb4 configure -text $nbpix

      set binning [$private($visuNo,camera) bin]
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,tailleImage) $nbpix\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,binning) $binning\n"
   }










   proc ::acqt1m_flatcielplus::majBouton2 { idfiltre nbimg} {

   variable private

      if {$nbimg==-1} {
         ::console::affiche_resultat "\n\n ** idfiltre = $idfiltre - nbimg =$nbimg ** \n\n"
         ::acqt1m_flatcielplus::majBouton $idfiltre 0
         return
      }
      ::console::affiche_erreur "\n\n ** idfiltre = $idfiltre - nbimg =$nbimg ** \n\n"
      if {$nbimg==0} {
         ::acqt1m_flatcielplus::majBouton $idfiltre 3
      }
      if {$nbimg==$private(mynbflat)} {
         ::acqt1m_flatcielplus::majBouton $idfiltre 2
      }
      if {$nbimg>0&&$nbimg<$private(mynbflat)} {
         ::acqt1m_flatcielplus::majBouton $idfiltre 1
      }

   }






   proc ::acqt1m_flatcielplus::majBouton { i fin} {
      variable private

      set private(texte_bouton,$i) [concat "($i) - $::caption(acqt1m_flatcielplus,filtre) " [lindex $::t1m_roue_a_filtre::private(filtre,$i) 1] " - $::caption(acqt1m_flatcielplus,nbre) =" [lindex $::t1m_roue_a_filtre::private(filtre,$i) 3]]
      if { [ winfo exists $::audace(base).selection_filtre ] } {
         # debut du Flat
         if {$fin == 0} {
            $::audace(base).selection_filtre.filtres.$i configure -text $private(texte_bouton,$i) -bg yellow
         }
         # fin du Flat : le compte n y est pas
         if {$fin == 1} {
            $::audace(base).selection_filtre.filtres.$i configure -text $private(texte_bouton,$i)  -bg orange
         }
         # fin du Flat : le compte y est
         if {$fin == 2} {
            $::audace(base).selection_filtre.filtres.$i configure -text $private(texte_bouton,$i)  -bg green
         }
         # fin du Flat : trop tard
         if {$fin == 3} {
            $::audace(base).selection_filtre.filtres.$i configure -text $private(texte_bouton,$i) -bg red
         }
      }
   }



















   #------------------------------------------------------------
   # acqAutoFlat
   #    Interface graphique de la fenetre d'acquisition des flats
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::acqAutoFlat { visuNo } {
      variable private

      ::acqt1m::push_gui $visuNo
      ::console::affiche_resultat "PUSH GUI\n"

      ::acqt1m_flatcielplus::initTexteBoutonFiltre

      if { [ winfo exists $::audace(base).selection_filtre ] } {
         destroy $::audace(base).selection_filtre
      }

      if { [ info exists private(geometryAcqAutoFlat) ] } {
         set deb [ expr 1 + [ string first + $private(geometryAcqAutoFlat) ] ]
         set fin [ string length $private(geometryAcqAutoFlat) ]
         set ::conf(acqt1m,acqAutoFlat,position) "+[string range $private(geometryAcqAutoFlat) $deb $fin]"
      }
      set listeFiltreActif [ ::acqt1m_flatcielplus::listeSensFiltreActif $private(sensnuit) ]
      set sizey [expr 300 + [llength $listeFiltreActif] * 40]

      toplevel $::audace(base).selection_filtre -class Toplevel -borderwidth 2 -relief groove
      wm geometry $::audace(base).selection_filtre 530x$sizey$::conf(acqt1m,acqAutoFlat,position)
      wm resizable $::audace(base).selection_filtre 1 1
      wm title $::audace(base).selection_filtre $::caption(acqt1m_flatcielplus,acqAutoFlat)
      wm transient $::audace(base).selection_filtre .audace
      wm protocol $::audace(base).selection_filtre WM_DELETE_WINDOW "::acqt1m_flatcielplus::fermerAcqAutoFlat $visuNo"

      if {$private(sensnuit) == 0} {
         set info_sens_nuit $::caption(acqt1m_flatcielplus,butDebutNuit)
      } else {
         set info_sens_nuit $::caption(acqt1m_flatcielplus,butFinNuit)
      }

      set info [$private($visuNo,camera) info]
      set size [$private($visuNo,camera) nbcells]
      set nbcells [$private($visuNo,camera) nbcells]
      set gain [format "%4.2f" [$private($visuNo,camera) gain]]
      set temperature [format "%4.1f" [$private($visuNo,camera) temperature]]
      $private($visuNo,camera) bin [list [lindex [split $::panneau(acqt1m,$visuNo,binning) "x"] 0] [lindex [split $::panneau(acqt1m,$visuNo,binning) "x"] 1]]
      set nbpix [$private($visuNo,camera) nbpix]

      set info0 "$::caption(acqt1m_flatcielplus,camera) [$private($visuNo,camera) info]"
      set info1 "$::caption(acqt1m_flatcielplus,nbPixelsMax) $nbcells / $::caption(acqt1m_flatcielplus,ADAmax) $private(maxdyn) / $::caption(acqt1m_flatcielplus,gain) $gain / $::caption(acqt1m_flatcielplus,temperature) $temperature"

      frame $::audace(base).selection_filtre.a0 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.a0 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.a0.camval -text $info0 -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a0.camval -in $::audace(base).selection_filtre.a0 -side left -anchor w -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.ae2 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.ae2 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.ae2.repimg -text "$::caption(acqt1m_flatcielplus,repImages) $private(rep_images)" -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.ae2.repimg -in $::audace(base).selection_filtre.ae2 -side left -anchor w -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.a1 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.a1 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.a1.camval -text $info1 -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a1.camval -in $::audace(base).selection_filtre.a1 -side left -anchor w -padx 4 -pady 4 -expand 0

      frame $::audace(base).selection_filtre.b -borderwidth 0 -relief solid
      pack $::audace(base).selection_filtre.b -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         #--- Binning
         button $::audace(base).selection_filtre.b.bin -borderwidth 1 -text $::caption(acqt1m,bin,$::panneau(acqt1m,$visuNo,binning)) \
            -command "::acqt1m_flatcielplus::changerBinningCent $visuNo"
         pack $::audace(base).selection_filtre.b.bin -side left -fill y

         #--- Nombre de Flat
         menubutton $::audace(base).selection_filtre.b.nbi -text $::caption(acqt1m_flatcielplus,nbFlats) -relief raised \
            -menu $::audace(base).selection_filtre.b.nbi.menu
         pack $::audace(base).selection_filtre.b.nbi -side left
         set m [menu $::audace(base).selection_filtre.b.nbi.menu -tearoff 0]
         foreach n $private(nbflat) {
            $m add radiobutton -label "$n" \
               -indicatoron "1" \
               -value "$n" \
               -variable ::acqt1m_flatcielplus::private(mynbflat) \
               -command {::console::affiche_resultat "$::caption(acqt1m_flatcielplus,nbFlatDemande) $::acqt1m_flatcielplus::private(mynbflat)\n" }
         }
         #--- Ligne de saisie
         entry $::audace(base).selection_filtre.b.nbival -width 4 -textvariable ::acqt1m_flatcielplus::private(mynbflat) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $::audace(base).selection_filtre.b.nbival -side left -fill y

         #--- Carre de mesure de l'intensite pour le calcul du temps de pose
         menubutton $::audace(base).selection_filtre.b.sqr -text $::caption(acqt1m_flatcielplus,mysquare1) -relief raised \
            -menu $::audace(base).selection_filtre.b.sqr.menu
         pack $::audace(base).selection_filtre.b.sqr -side left
         set m [menu $::audace(base).selection_filtre.b.sqr.menu -tearoff 0]
         foreach n $private(square) {
            $m add radiobutton -label "$n" \
               -indicatoron "1" \
               -value "$n" \
               -variable ::acqt1m_flatcielplus::private(mysquare) \
               -command { ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,mysquare) $::acqt1m_flatcielplus::private(mysquare)\n" }
         }
         #--- Ligne de saisie
         entry $::audace(base).selection_filtre.b.sqrval -width 4 -textvariable ::acqt1m_flatcielplus::private(mysquare) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $::audace(base).selection_filtre.b.sqrval -side left -fill y

      frame $::audace(base).selection_filtre.b1 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.b1 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         #--- Dynamique maxi des flats
         menubutton $::audace(base).selection_filtre.b1.menudynflat -text $::caption(acqt1m_flatcielplus,dynflat) -relief raised \
            -menu $::audace(base).selection_filtre.b1.menudynflat.menu
         pack $::audace(base).selection_filtre.b1.menudynflat -side left
         set m [menu $::audace(base).selection_filtre.b1.menudynflat.menu -tearoff 0]
         foreach n $private(dynamique) {
            $m add radiobutton -label "$n" \
               -indicatoron "1" \
               -value "$n" \
               -variable ::acqt1m_flatcielplus::private(mydynamique) \
               -command {::console::affiche_resultat "$::caption(acqt1m_flatcielplus,fondflat1) $::acqt1m_flatcielplus::private(mydynamique)\n" }
         }
         #--- Ligne de saisie
         entry $::audace(base).selection_filtre.b1.entdynflat -width 4 -textvariable ::acqt1m_flatcielplus::private(mydynamique) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $::audace(base).selection_filtre.b1.entdynflat -side left -fill y

      frame $::audace(base).selection_filtre.a2 -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.a2 -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         #--- Obturateur et nombre de pixels
         label $::audace(base).selection_filtre.a2.lb1 -text $::caption(acqt1m_flatcielplus,obturateur) -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a2.lb1 -in $::audace(base).selection_filtre.a2 -side left -anchor w -padx 4 -pady 4 -expand 0
         label $::audace(base).selection_filtre.a2.lb2 -text [$private($visuNo,camera) shutter] -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a2.lb2 -in $::audace(base).selection_filtre.a2 -side left -anchor w -padx 4 -pady 4 -expand 0
         label $::audace(base).selection_filtre.a2.lb3 -text "           $::caption(acqt1m_flatcielplus,nbPixels)" -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a2.lb3 -in $::audace(base).selection_filtre.a2 -side left -anchor e -padx 4 -pady 4 -expand 0
         label $::audace(base).selection_filtre.a2.lb4 -text $nbpix -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.a2.lb4 -in $::audace(base).selection_filtre.a2 -side left -anchor e -padx 4 -pady 4 -expand 0

         #--- Liste des Filtres
      frame $::audace(base).selection_filtre.filtres -borderwidth 0 -relief solid
      pack  $::audace(base).selection_filtre.filtres -in $::audace(base).selection_filtre -anchor center -side top -expand 0 -fill both -padx 3 -pady 0

         foreach x $listeFiltreActif {
            button $::audace(base).selection_filtre.filtres.$x -text $private(texte_bouton,$x) -command "::acqt1m_flatcielplus::acqFlatall $visuNo $x" -bg $::audace(color,backColor2)
            pack $::audace(base).selection_filtre.filtres.$x -in $::audace(base).selection_filtre.filtres -anchor center -side top -fill x -padx 4 -pady 4 -expand 1
         }

         #--- Derniers boutons
      frame $::audace(base).selection_filtre.h -borderwidth 0 -relief solid
      pack $::audace(base).selection_filtre.h -in $::audace(base).selection_filtre -anchor s -side bottom -expand 0 -fill both -padx 3 -pady 0

         button $::audace(base).selection_filtre.h.fin -text $::caption(acqt1m_flatcielplus,fermer) -command "::acqt1m_flatcielplus::fermerAcqAutoFlat $visuNo" -bg $::audace(color,backColor2)
         pack $::audace(base).selection_filtre.h.fin -in $::audace(base).selection_filtre.h -anchor center -side top -fill x -padx 4 -pady 4 -expand 1

      frame $::audace(base).selection_filtre.f -borderwidth 0 -relief solid
      pack $::audace(base).selection_filtre.f -in $::audace(base).selection_filtre -anchor s -side bottom -expand 0 -fill both -padx 3 -pady 0

         button $::audace(base).selection_filtre.f.fin -text $::caption(acqt1m_flatcielplus,stop) -command "::acqt1m_flatcielplus::arretAcqFlat $visuNo" -bg $::audace(color,backColor2) -state normal
         pack $::audace(base).selection_filtre.f.fin -in $::audace(base).selection_filtre.f -anchor center -side top -fill x -padx 4 -pady 4 -expand 1

      frame $::audace(base).selection_filtre.j -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.j -in $::audace(base).selection_filtre -anchor s -side bottom -expand 0 -fill both -padx 3 -pady 0

         checkbutton $::audace(base).selection_filtre.j.check -highlightthickness 0 \
            -text $::caption(acqt1m_flatcielplus,avancement_acq) -variable ::acqt1m_flatcielplus::private(avancement_acq)
         pack $::audace(base).selection_filtre.j.check -in $::audace(base).selection_filtre.j -anchor w -side left -expand 0 -fill both -padx 3 -pady 0

      frame $::audace(base).selection_filtre.g -borderwidth 0 -relief ridge
      pack $::audace(base).selection_filtre.g -in $::audace(base).selection_filtre -anchor s -side bottom -expand 0 -fill both -padx 3 -pady 0

         label $::audace(base).selection_filtre.g.sens -text $info_sens_nuit -borderwidth 0 -relief flat
         pack $::audace(base).selection_filtre.g.sens -in $::audace(base).selection_filtre.g -anchor w -side left -expand 0 -fill both -padx 4 -pady 4

      focus $::audace(base).selection_filtre

      ::confColor::applyColor $::audace(base).selection_filtre
   }



















   #------------------------------------------------------------
   # fermerAcqAutoFlat
   #    Ferme la fenetre acqAutoFlat
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::fermerAcqAutoFlat { visuNo } {
      variable private

      ::acqt1m::pop_gui $visuNo
      ::console::affiche_resultat "POP GUI\n"
      file delete -force mesurefond.fit
      ::acqt1m_flatcielplus::fermerAffichageChoixFiltres $visuNo
      set ::conf(acqt1m,avancement1,position) $private(avancement1,position)
      ::acqt1m_flatcielplus::recupPositionAcqAutoFlat
      destroy $::audace(base).selection_filtre
   }



















   #------------------------------------------------------------
   # recupPositionAcqAutoFlat
   #    Recupere la position de la fenetre acqAutoFlat
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::recupPositionAcqAutoFlat { } {
      variable private

      set private(geometryAcqAutoFlat) [ wm geometry $::audace(base).selection_filtre ]
      set deb [ expr 1 + [ string first + $private(geometryAcqAutoFlat) ] ]
      set fin [ string length $private(geometryAcqAutoFlat) ]
      set ::conf(acqt1m,acqAutoFlat,position) "+[string range $private(geometryAcqAutoFlat) $deb $fin]"
   }






   #------------------------------------------------------------
   # acqFlat
   #    Acquisition des flats en automatique
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::acqFlatall { visuNo idfiltre } {

      variable private
      global panneau

      set listeFiltreActif [ ::acqt1m_flatcielplus::listeSensFiltreActif $private(sensnuit) ]

      gren_info "*** listeFiltreActif  $listeFiltreActif\n"

      set pass "no"
      set private(demande_stop) 0
      foreach y $listeFiltreActif {

         if {$private(demande_stop)==1} {
            ::console::affiche_erreur "ARRET = private(demande_stop)=$private(demande_stop)\n"
            break
         }
         if {$private(working)==1} {
            ::console::affiche_erreur "ARRET = private(working)=$private(working)\n"
            break
         }


         set newfiltre [lindex $::t1m_roue_a_filtre::private(filtre,$y) 2]
         gren_info "NEWFILTRE $newfiltre ($y/$idfiltre) $private(demande_stop)...\n"

         if {$y==$idfiltre} {

            set filtre [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2]
            ::console::affiche_erreur "** je veux ce filtre : $filtre\n"

            set private(tourne_roue) 1
            $::audace(base).selection_filtre.f.fin configure -state disabled
            set result [::t1m_roue_a_filtre::verifFiltre $filtre]
            $::audace(base).selection_filtre.f.fin configure -state normal
            set private(tourne_roue) 0

            gren_info "verif : $result\n"

            if { $result=="no" && $private(demande_stop)==0 } {

               ::console::affiche_erreur "** c est pas le bon\n"
               set panneau(acqt1m,$visuNo,filtrecourant) $filtre
               set roue "no"
               while { $roue=="no" && $private(demande_stop)==0 } {
                  set private(tourne_roue) 1
                  $::audace(base).selection_filtre.f.fin configure -state disabled
                  set roue [::t1m_roue_a_filtre::changeFiltre $visuNo]
                  $::audace(base).selection_filtre.f.fin configure -state normal
                  set private(tourne_roue) 0
               }
            }
            set pass "yes"
         }
         if { $y!=$idfiltre && $pass=="yes" && $private(demande_stop)==0 } {

            set filtre [lindex $::t1m_roue_a_filtre::private(filtre,$y) 2]
            set panneau(acqt1m,$visuNo,filtrecourant) $filtre
            set roue "no"
            while {$roue=="no"&&$private(demande_stop)==0} {
               set private(tourne_roue) 1
               $::audace(base).selection_filtre.f.fin configure -state disabled
               set roue [::t1m_roue_a_filtre::changeFiltre $visuNo]
               $::audace(base).selection_filtre.f.fin configure -state normal
               set private(tourne_roue) 0
            }
         }

         if { $pass=="yes" && $private(demande_stop)==0 } {

           ::console::affiche_erreur "y = $y\n"
           foreach e $listeFiltreActif {
              if {$y==$e} {
                 gren_info "($y)\n"
              } else {
                 gren_info "$e\n"
              }
           }


           ::acqt1m_flatcielplus::acqFlat $visuNo $y
           gren_info "*** FIN  ACQ $private(demande_stop)...\n"

         }

      }

      ::console::affiche_erreur "--------------------------------\n"
      ::console::affiche_erreur "--------------------------------\n"
      ::console::affiche_erreur "--------  FINBOUCLE  ACQ  ------\n"
      ::console::affiche_erreur "--------------------------------\n"
      ::console::affiche_erreur "--------------------------------\n"
      gren_info "*** FINBOUCLE  ACQ $private(demande_stop)...\n"

      after 500
      bell
      after 200
      bell
      after 100
      bell
      after 100
      bell
      after 200
      bell
      after 400
      bell
      after 200
      bell

      set private(working) 0
      return
   }







   #------------------------------------------------------------
   # acqFlat
   #    Acquisition des flats en automatique
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::acqFlat { visuNo idfiltre } {

      variable private 
      global panneau

      # Comptage des flats
      ::acqt1m_flatcielplus::majBouton2 $idfiltre -1

      set attentems [expr $private(attente) * 1000]

      set nbpix    [$private($visuNo,camera) nbpix]
      set binning  [$private($visuNo,camera) bin]
      set xcent    [expr [lindex $nbpix 0]/2]
      set ycent    [expr [lindex $nbpix 1]/2]
      set xmin     [expr $xcent - $private(mysquare) / 2]
      set ymin     [expr $ycent - $private(mysquare) / 2]
      set xmax     [expr $xcent + $private(mysquare) / 2]
      set ymax     [expr $ycent + $private(mysquare) / 2]
      set fondflat [expr $private(maxdyn) * $private(mydynamique)]

      ::console::affiche_saut "\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,debutAcq) [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2]\n"

      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,tailleImage) $nbpix\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,binning) $binning\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,nbFlatDemande) $private(mynbflat)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,tailleFenetre) $private(mysquare)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,limitexptime) $private(limitexptime)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,exptimemini) $private(exptimemini)\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,fondflat1) $fondflat\n"

      set panneau(acqt1m,$visuNo,object) "FLAT"

      set buffer buf[ ::confVisu::getBufNo $visuNo ]

      # Dark (obturateur closed)
      set exptime 1
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,mesureDark)\n"
      $private($visuNo,camera) window [list $xmin $ymin $xmax $ymax]
      $private($visuNo,camera) shutter closed
      if [ winfo exists $::audace(base).selection_filtre ] {
         $::audace(base).selection_filtre.a2.lb2 configure -text [$private($visuNo,camera) shutter]
      }
      #--- Declenchement de l'acquisition
      puts "acquisition dark start"
      ::camera::acquisition $private($visuNo,camItem) "::acqt1m_flatcielplus::attendImage fen $visuNo" $exptime
      #--- J'attends la fin de l'acquisition
      vwait ::acqt1m_flatcielplus::private(finAquisition)
      puts "acquisition dark stop"
      $buffer save "mesurefond"
      puts "acquisition dark save"

      set stat  [$buffer stat]
      set dark  [lindex $stat 4]
      set stdev [lindex $stat 5]
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,fluxMoyen) $dark\n"
      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,ecartType) $stdev\n"

      # Image (obturateur synchro)
      $private($visuNo,camera) shutter synchro
      if [ winfo exists $::audace(base).selection_filtre ] {
         $::audace(base).selection_filtre.a2.lb2 configure -text [$private($visuNo,camera) shutter]
      }

      # Boucle sur les images
      set num 1

      # Initialisation a 1 pour le premier flat
      set ::t1m_roue_a_filtre::private(filtre,$idfiltre) [lreplace $::t1m_roue_a_filtre::private(filtre,$idfiltre) 3 3 0]

      for {set id 0} {$id<$private(mynbflat)} {incr id} {

      puts "flat start loop"

         if {$private(demande_stop)==1} {break}

         #--- Initialisation d'une variable
         set private(finAquisition) ""

         #--- Pose en cours
         set private(pose_en_cours) 1

         set exptime 1

         if {$private(testprog) == 0} {

            while {$exptime > 0&&$private(demande_stop)==0} {

               # Fond du ciel
               set exptime 1
               ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,mesureCiel) [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2] :\n"
      puts "acquisition window $xmin $ymin $xmax $ymax"
               $private($visuNo,camera) window [list $xmin $ymin $xmax $ymax]
               #--- Declenchement de l'acquisition
      puts "acquisition flat start"
               ::camera::acquisition $private($visuNo,camItem) "::acqt1m_flatcielplus::attendImage fen $visuNo" $exptime
               #--- J'attends la fin de l'acquisition
               vwait ::acqt1m_flatcielplus::private(finAquisition)
      puts "acquisition flat stop"
               $buffer save "mesurefond"
      puts "acquisition flat save"

               set stat  [$buffer stat]
               set ciel  [lindex $stat 4]
               set stdev [lindex $stat 5]
               ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,fluxMoyen) $ciel\n"
               ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,ecartType) $stdev\n"

               if {[expr $ciel+$stdev]<$private(maxdyn)} {

                  puts "[expr $ciel+$stdev] < $private(maxdyn)"
                  
                  #--- image non saturee
                  set exptime [format "%0.1f" [expr $fondflat/($ciel - $dark)]]
                  if {$exptime<0} {
                     ::console::affiche_resultat "\n\n$::caption(acqt1m_flatcielplus,probleme)\n"
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,verification)\n"
                     puts "exptime = $exptime"
                     set exptime 1
                     continue
                  }

                  #--- comparaison du temps d'exposition avec les limites mini et maxi
                  if { $exptime > $private(limitexptime) } {
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,estimationExptime)\n"
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,mini) $private(exptimemini) < $::caption(acqt1m_flatcielplus,maxi) $private(limitexptime) < $exptime\n"
                  } elseif { $exptime > $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,estimationExptime)\n"
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,mini) $private(exptimemini) < $exptime < $::caption(acqt1m_flatcielplus,maxi) $private(limitexptime)\n"
                  } elseif { $exptime < $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,estimationExptime)\n"
                     ::console::affiche_resultat "$exptime < $::caption(acqt1m_flatcielplus,mini) $private(exptimemini) < $::caption(acqt1m_flatcielplus,maxi) $private(limitexptime)\n"
                  }

                  #--- comparaison du temps d'exposition avec les limites mini et maxi
                  if {$exptime>$private(limitexptime)} {
                     set exptime $private(limitexptime)
                     if {$private(sensnuit) == 1} {
                        #--- On fait les flats en fin de nuit
                        #--- il fait trop nuit, donc on attend
                        ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,tropNuit) $private(attente) $::caption(acqt1m_flatcielplus,secondes)\n"
                        after $attentems
                     } else {
                        #--- On fait les flats en debut de nuit
                        #--- il fait trop nuit, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(acqt1m_flatcielplus,tropTard1)\n\n"
                        #--- Pose en cours
                        set private(pose_en_cours) 0
                        ::acqt1m_flatcielplus::majBouton2 $idfiltre $id
                        return
                     }
                  } elseif {$exptime<$private(exptimemini)} {
                     if {$private(sensnuit) == 1} {
                        #--- On fait les flats en fin de nuit
                        #--- il fait trop jour, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(acqt1m_flatcielplus,tropTard2)\n\n"
                        #--- Pose en cours
                        set private(pose_en_cours) 0
                        ::acqt1m_flatcielplus::majBouton2 $idfiltre $id
                        return
                     } else {
                        #--- On fait les flats en debut de nuit
                        #--- il fait trop jour, donc on attend
                        ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,tropJour) $private(attente) $::caption(acqt1m_flatcielplus,secondes)\n"
                        after $attentems
                     }
                  } else {
                     #--- image non saturee et temps d'exposition limite non atteint -> OK on y va
                     break
                  }

               } else {

                  puts "[expr $ciel+$stdev] >= $private(maxdyn)"
                  
                  
                  #--- Saturation on divise le temps d'exposition par 3
                  set exptime [format "%0.1f" [expr $exptime / 3.]]

                  #--- comparaison du temps d'exposition avec les limites mini et maxi
                  if { $exptime > $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,estimationExptime)\n"
                     ::console::affiche_resultat "$exptime > $::caption(acqt1m_flatcielplus,mini) $private(exptimemini)\n"
                  } elseif { $exptime < $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,estimationExptime)\n"
                     ::console::affiche_resultat "$exptime < $::caption(acqt1m_flatcielplus,mini) $private(exptimemini)\n"
                  }

                  #--- si le temps d'exposition est trop court
                  if {$exptime<$private(exptimemini)} {
                     if {$private(sensnuit) == 0} {
                        #--- On fait les flats en debut de nuit
                        #--- il fait trop jour, donc on attend
                        set exptime $private(exptimemini)
                        ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,tropJour) $private(attente) $::caption(acqt1m_flatcielplus,secondes)\n"
                        after $attentems
                     } else {
                        #--- On fait les flats en fin de nuit
                        #--- il fait trop jour, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(acqt1m_flatcielplus,tropTard2)\n\n"
                        #--- Pose en cours
                        set private(pose_en_cours) 0
                        ::acqt1m_flatcielplus::majBouton2 $idfiltre $id
                        return
                     }
                  }

               }

            }

         }

      puts "flat lo"

         #--- Bouton Stop Auto Flats actif
         if [ winfo exists $::audace(base).selection_filtre ] {
            $::audace(base).selection_filtre.f.fin configure -state normal
         }

         # Flat :
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,parti) ([expr $id+1]/$private(mynbflat))\n"
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,prochainExptime) $exptime $::caption(acqt1m_flatcielplus,secondes)\n"
         $private($visuNo,camera) window [list 1 1 [lindex $private(nbcells) 0] [lindex $private(nbcells) 1] ]
         $private($visuNo,camera) shutter synchro
         #--- Declenchement de l'acquisition
         ::camera::acquisition $private($visuNo,camItem) "::acqt1m_flatcielplus::attendImage img $visuNo" $exptime
         #--- Je lance la boucle d'affichage de l'avancement
         after 10 ::acqt1m_flatcielplus::dispTime $visuNo $exptime
         #--- J'attends la fin de l'acquisition
         vwait ::acqt1m_flatcielplus::private(finAquisition)

      puts "flat la"

         set stat   [$buffer stat]
         set pixmin [lindex $stat 3]
         set pixmax [lindex $stat 2]
         set ciel   [lindex $stat 4]
         set stdev  [lindex $stat 5]
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,mesureFlat)\n"
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,fluxMoyen) $ciel\n"
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,ecartType) $stdev\n"
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,pixelMiniMaxi) $pixmax / $pixmin\n"

         set nouv   [expr $ciel / $private(maxdyn)]
         set offset [expr $private(mydynamique) - ($ciel / $private(maxdyn))]

         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,offset) $offset\n"
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,nouv) $nouv\n"
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,maxdyn) $private(maxdyn)\n"
         set fondflat [expr $private(maxdyn) * ($fondflat/$private(maxdyn) + $offset)]
         ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,fondflat2) $fondflat\n"

      puts "flat ici et la"

         set enr 0
         while {$enr == 0 && $ciel>1} {
            set entete [ mc_date2ymdhms [ ::audace::date_sys2ut now] ]
            set pos  [string first "." [lindex $entete 5]]
            set sec  [string range [lindex $entete 5] 0 [expr $pos-1]]
            set date [ format "%04d%02d%02dT%02d%02d%02d" [lindex $entete 0] [lindex $entete 1] [lindex $entete 2] [lindex $entete 3] [lindex $entete 4] $sec]
            set file [ file join $private(rep_images) "T1M_${date}_FLAT_[lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 1]_$private(mybin)_$num" ]
            if {$private(testprog) == 1} {set file [ file join $private(rep_images) "$entete.TEST_[lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 1]_$num" ]}
            set filelong "$file$::conf(extension,defaut)"
            if {[file exists $filelong]==0} {
               #--- Rajoute des mots cles dans l'en-tete FITS
               foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqt1m,keywordConfigName) ] {
                  $buffer setkwd $keyword
               }
               #--- Rajoute d'autres mots cles
               $buffer setkwd [list "IMAGETYP" "Flat" string "Image type" "" ]
               $buffer setkwd [list "OBJECT"   "FLAT" string "" "" ]
               $buffer setkwd [list "FILTER"   [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2] string "" "" ]
               
               set nom   [lindex [::acqt1m::get_filename $visuNo] 1]
               saveima $nom $visuNo
               #saveima $filelong $visuNo
               
               ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,enregistre) $filelong\n"
               set enr 1
               incr num
               bell
            }
         }

      puts "flat sici"
         if {$num>$private(mynbflat)} {

            bell
            after 100
            bell
            after 100
            bell
            after 100
            bell
            after 100
            bell
         }
         set ::t1m_roue_a_filtre::private(filtre,$idfiltre) [lreplace $::t1m_roue_a_filtre::private(filtre,$idfiltre) 3 3 [expr $num-1]]
         #--- Bouton Stop Auto Flats inactif
         if [ winfo exists $::audace(base).selection_filtre ] {
            $::audace(base).selection_filtre.f.fin configure -state normal
         }

         #--- Pose en cours
         set private(pose_en_cours) 0

         #--- Effacement de la barre de progression quand la pose est terminee
         ::acqt1m_flatcielplus::avancementPose $visuNo -1

         #--- Arret de la pose et de la serie
         if {$private(demande_stop) == 1} {
            ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,arretDemande)\n"
            break
         }

      }

      ::acqt1m_flatcielplus::majBouton2 $idfiltre $id

      #--- Je positionne l'indicateur d'arret de la pose

      ::console::affiche_resultat "$::caption(acqt1m_flatcielplus,finAcq) [lindex $::t1m_roue_a_filtre::private(filtre,$idfiltre) 2]\n\n"
   }



















   #------------------------------------------------------------
   # attendImage
   #    Controle de la thread d'acquisition
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::attendImage { type visuNo message args } {
      variable private

      switch $message {
         "autovisu" {
            #--- ce message signale que l'image est prete dans le buffer
            #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
            if {$type == "img"} {::confVisu::autovisu $visuNo}
         }
         "acquisitionResult" {
            #--- ce message signale que la thread de la camera a termine completement l'acquisition
            #--- je peux traiter l'image
            set private(finAquisition) "acquisitionResult"
         }
         "error" {
            #--- ce message signale qu'une erreur est survenue dans la thread de la camera
            #--- j'affiche l'erreur dans la console
            ::console::affiche_erreur "acqt1m_flatcielplus::acqFlat error: $args\n"
            set private(finAquisition) "acquisitionResult"
         }
      }
   }



















   #------------------------------------------------------------
   # dispTime
   #    Timer de l'exposition
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::dispTime { visuNo exptime } {
      variable private

      #--- j'arrete le timer s'il est deja lance
      if { [ info exists private(dispTimeAfterId) ] && $private(dispTimeAfterId)!="" } {
         after cancel $private(dispTimeAfterId)
         set private(dispTimeAfterId) ""
      }

      set private(exptime) $exptime

      set t [ $private($visuNo,camera) timer -1 ]
      #--- je mets a jour le status
      if { $private(pose_en_cours) == 0 } {
         #--- je supprime la fenetre s'il n'y a plus de pose en cours
         set status ""
      } else {
         if { $private(demande_stop) == "0" } {
            if { [expr $t > 0] } {
               set status "[ expr $t ] / [ format "%d" [ expr int($exptime) ] ]"
            } else {
               set status "$::caption(acqt1m_flatcielplus,lecture)"
            }
         } else {
            set status "$::caption(acqt1m_flatcielplus,lecture)"
         }
      }
      update

      #--- je mets a jour la fenetre de progression
      ::acqt1m_flatcielplus::avancementPose $visuNo $t

      if { $t > 0 } {
         #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
         #--- (mode asynchone pour eviter l'empilement des appels recursifs)
         set private(dispTimeAfterId) [ after 1000 ::acqt1m_flatcielplus::dispTime $visuNo $exptime ]
      } else {
         #--- je ne relance pas le timer
         set private(dispTimeAfterId) ""
      }
   }



















   #------------------------------------------------------------
   # avancementPose
   #    Fenetre pour l'avancement de la pose
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::avancementPose { visuNo { t } } {
      variable private

      if { $private(avancement_acq) != "1" } {
         return
      }

      #--- Recuperation de la position de la fenetre
      ::acqt1m_flatcielplus::recupPositionAvancement $visuNo

      #--- Initialisation de la barre de progression
      set cpt "100"

      #---
      if { [ winfo exists $::audace(base).progress ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel $::audace(base).progress
         if [ winfo exists $::audace(base).selection_filtre ] {
            wm transient $::audace(base).progress $::audace(base).selection_filtre
         }
         wm resizable $::audace(base).progress 0 0
         wm title $::audace(base).progress "$::caption(acqt1m_flatcielplus,en_cours)"
         wm geometry $::audace(base).progress $private(avancement1,position)

         #--- Cree le widget et le label du temps ecoule
         label $::audace(base).progress.lab_status -text "" -justify center
         pack $::audace(base).progress.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $private(demande_stop) == "1" } {
            $::audace(base).progress.lab_status configure -text $::caption(acqt1m_flatcielplus,lecture)
         } else {
            if { $t < 0 } {
               destroy $::audace(base).progress
            } elseif { $t > 0 } {
               $::audace(base).progress.lab_status configure -text "$t $::caption(acqt1m_flatcielplus,sec) /\
                  [ format "%d" [ expr int( $private(exptime) ) ] ] $::caption(acqt1m_flatcielplus,sec)"
               set cpt [ expr $t * 100 / int( $private(exptime) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $::audace(base).progress.lab_status configure -text "$::caption(acqt1m_flatcielplus,lecture)"
           }
         }

         catch {
            #--- Cree le widget pour la barre de progression
            frame $::audace(base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack $::audace(base).progress.cadre -in $::audace(base).progress -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8

            #--- Affiche de la barre de progression
            frame $::audace(base).progress.cadre.barre_color_invariant -height 26 -bg $::color(blue)
            place $::audace(base).progress.cadre.barre_color_invariant -in $::audace(base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if { [ winfo exists $::audace(base).progress ] == "1" } {
            ::confColor::applyColor $::audace(base).progress
         }

      } else {

         if { $private(pose_en_cours) == 0 } {
            #--- je supprime la fenetre s'il n'y a plus de pose en cours
            destroy $::audace(base).progress
         } else {
            if { $private(demande_stop) == "0" } {
               if { $t > 0 } {
                  $::audace(base).progress.lab_status configure -text "[ expr $t ] $::caption(acqt1m_flatcielplus,sec) /\
                     [ format "%d" [ expr int( $private(exptime) ) ] ] $::caption(acqt1m_flatcielplus,sec)"
                  set cpt [ expr $t * 100 / int( $private(exptime) ) ]
                 set cpt [ expr 100 - $cpt ]
               } else {
                  $::audace(base).progress.lab_status configure -text "$::caption(acqt1m_flatcielplus,lecture)"
               }
            } else {
               #--- j'affiche "lecture" des qu'une demande d'arret est demandee
               $::audace(base).progress.lab_status configure -text "$::caption(acqt1m_flatcielplus,lecture)"
            }
            #--- Met a jour la barre de progression
            place $::audace(base).progress.cadre.barre_color_invariant -in $::audace(base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }

      }

   }



















   #------------------------------------------------------------
   # recupPositionAvancement
   #    Recupere la position de la fenetre d'avancement de la pose
   #------------------------------------------------------------
   proc ::acqt1m_flatcielplus::recupPositionAvancement { visuNo } {
      variable private

      if [ winfo exists $::audace(base).progress ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $::audace(base).progress ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set private(avancement1,position) "+[ string range $geometry $deb $fin ]"
      }
   }

}

