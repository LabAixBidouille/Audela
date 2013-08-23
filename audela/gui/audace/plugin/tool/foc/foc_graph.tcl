#
# Fichier : foc_graph.tcl
# Description : Script de construction des graphiques
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id$
#

namespace eval ::foc {

   #------------   gestion du graphique classique --------------

   #------------------------------------------------------------
   # updateFocGraphe
   #    sous processus de cmdAcq de mise a jour des 4 graphiques
   # Parametre : liste du n° d'image, intensite, fwhmx, fwhmy et contraste
   #------------------------------------------------------------
   proc updateFocGraphe { data } {
      global audace

      #--   raccourci
      set w $audace(base).visufoc

      lassign $data count inten fwhmx fwhmy contr

      #--   Met a jour les vecteurs
      ::vx append $count
      ::vyg_inten append $inten
      ::vyg_fwhmx append $fwhmx
      ::vyg_fwhmy append $fwhmy
      ::vyg_contr append $contr

      #--   Met a jour les graphiques

      #--- Affiche les 19 dernieres mesures glissantes + 1 vide
      if { [::vx length] > 19 } {
         lassign [ $w.g_fwhmx axis limits x ] xmin xmax
         set xmin [expr { $xmin+1 }]
         set xmax [expr { $xmax+1 }]
         foreach childGraph [list g_inten g_fwhmx g_fwhmy g_contr] {
            $w.$childGraph axis configure x -min $xmin -max $xmax
            $w.$childGraph axis configure x2 -min $xmin -max $xmax
         }
      }

      #--- Ajuste l'echelle de droite a celle de gauche
      foreach childGraph [list g_inten g_fwhmx g_fwhmy g_contr] {
         lassign [ $w.$childGraph axis limits y ] ymin ymax
         $w.$childGraph axis configure y2 -min $ymin -max $ymax
      }
   }

   #------------------------------------------------------------
   # focGraphe
   #    cree le fenetre graphique de suivi des parametres de focalisation
   #------------------------------------------------------------
   proc focGraphe { } {
      global audace caption conf panneau

      set this $audace(base).visufoc

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $this ] {
         ::foc::fermeGraphe
      }

      #--- Creation et affichage des graphes
      if { [ winfo exists $this ] == "0" } {
         package require BLT
         #--- Creation de la fenetre
         toplevel $this
         wm title $this "$caption(foc,titre_graphe)"
         if { $panneau(foc,exptime) > "2" } {
            wm transient $this $audace(base)
         }
         wm resizable $this 1 1
         wm geometry $this $conf(visufoc,position)
         wm protocol $this WM_DELETE_WINDOW { ::foc::fermeGraphe }
         #---
         ::foc::visuf $this g_inten "$caption(foc,intensite_adu)"
         ::foc::visuf $this g_fwhmx "$caption(foc,fwhm_x)"
         ::foc::visuf $this g_fwhmy "$caption(foc,fwhm_y)"
         ::foc::visuf $this g_contr "$caption(foc,contrast_adu)"
         update

         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $this
      }
   }

   #------------------------------------------------------------
   # visuf
   #    cree un graphique de suivi d'un parametre
   #------------------------------------------------------------
   proc visuf { base win_name title } {

      set frm $base.$win_name

      #--   ::vx (compteur) est commun a tous les graphes
      if {"::vx" ni [blt::vector names]} {
         ::blt::vector create ::vx -watchunset 1
      }
      blt::vector create ::vy$win_name -watchunset 1

      blt::graph $frm
      $frm element create line1 -xdata ::vx -ydata ::vy$win_name \
         -linewidth 1 -color black -symbol "scross" -hide no
      $frm axis configure x -hide no -min 1 -max 20 -subdivision 0 -stepsize 1
      $frm axis configure x2 -hide no -min 1 -max 20 -subdivision 0 -stepsize 1
      #--   laisse flotter le minimum et le maximum
      $frm axis configure y -title "$title" -hide no -min {} -max {}
      $frm axis configure y2 -hide no -min {} -max {}
      $frm legend configure -hide yes
      $frm configure -height 140
      pack $frm
   }

   #------------------------------------------------------------
   # fermeGraphe
   #    ferme la fenetre des graphes et sauve la position
   # Parametre : chemin de la fenetre
   #------------------------------------------------------------
   proc fermeGraphe { } {
      variable This
      global audace conf

      #--   Interdit la fermeture pendant le fenetrage
      if {[$This.fra3.focuser.list cget -state] eq "disabled"} {return}

      set w $audace(base).visufoc

      #--- Determination de la position de la fenetre
      regsub {([0-9]+x[0-9]+)} [wm geometry $w] "" conf(visufoc,position)

      #--- Detruit les vecteurs persistants
      blt::vector destroy ::vx ::vyg_fwhmx ::vyg_fwhmy ::vyg_inten ::vyg_contr

      #--- Fermeture de la fenetre
      destroy $w
   }

   #------------   gestion du graphique HFD -----------------

   #---------------------------------------------------------------------------
   # updateHFDGraphe
   #    Met a jour les graphiques
   # Parametres : limites et rayon
   #---------------------------------------------------------------------------
   proc updateHFDGraphe { limite1 limite2 rayon} {
      global audace caption panneau

      set this $audace(base).hfd

      #--   Met a jour la ligne au-dessus des graphiques
      set panneau(foc,hfd) [format "%.2f" [expr { 2*$rayon }]]
      set panneau(foc,resulthfd) [format $caption(foc,diamHFD) $panneau(foc,hfd)]
      $this.h.fr1.graph marker configure limite1 -coords [list $limite1 -Inf $limite1 Inf]
      $this.h.fr1.graph marker configure limite2 -coords [list $limite2 -Inf $limite2 Inf]

      #--   Deplace la ligne verticale du diametre
      $this.h.fr2.graph marker configure rayon -coords [list $rayon -Inf $rayon Inf]

      #--   Complete la serie HFD
      ::VShfd append $panneau(foc,hfd)
      ::VSpos append $audace(focus,currentFocus)

      #--   Identifie la derniere valeur
      set posMax [::VSpos index [expr { [::VSpos length]-1 }]]
      #--   Ajoute 5000 pas
      $this.l.fr3.graph axis configure x -min [::VSpos index 0] -max [expr { $posMax+5000 }]

      if {[::VShfd length] > 1} {
          lassign [::foc::computeSlope] slopeLeft slopeRight positionOPt
          if {$slopeLeft != 0} {
            set panneau(foc,slopeleft) "[format $caption(foc,slopeleft) $slopeLeft]"
         }
         if {$slopeRight != 0} {
            set panneau(foc,sloperight) "[format $caption(foc,sloperight) $slopeRight]"
         }
         if {$positionOPt !=0} {
            set panneau(foc,optimum) "[format $caption(foc,optimum) $positionOPt]"
         }
      }
      update
   }

   #---------------------------------------------------------------------------
   #  updateLocator
   #    Cree une representation de l'image et dela position de l'etoile
   # Parametres : naxis1 et naxis2 de l'image initiale, position x,y de l'etoile
   #---------------------------------------------------------------------------
   proc updateLocator { naxis1 naxis2 xstar ystar } {
      variable panneau
      global audace

      set grph0 $audace(base).hfd.h.fr0.graph

      if {$naxis1 > $naxis2} {
         set x2 99
         set xstar [expr { int($x2*$xstar/$naxis1) }]
         set y2 [expr { int(99*$naxis2/$naxis1) }]
         set ystar [expr { int($y2*$ystar/$naxis2) }]
      } else {
         set x2 [expr { int(99*$naxis1/$naxis2) }]
         set y2 99
         set xstar [expr { int($x2*$xstar/$naxis1) }]
         set ystar [expr { int($y2*$ystar/$naxis2) }]
      }

      $grph0 element create color_invariant_star -xdata $xstar -ydata $ystar \
         -symbol circle -fill yellow -hide no
      $grph0 marker create line -name vert1 -coords [list 1 1 1 $y2] \
         -linewidth 1 -outline blue -hide no
      $grph0 marker create line -name hrz2 -coords [list 1 $y2 $x2 $y2] \
         -linewidth 1 -outline blue -hide no
      $grph0 marker create line -name vert2 -coords [list $x2 1 $x2 $y2] \
         -linewidth 1 -outline blue -hide no
      $grph0 marker create line -name hrz1 -coords [list 1 2 $x2 2] \
         -linewidth 1 -outline blue -hide no
      update
   }

   #------------------------------------------------------------
   # HFDGraphe
   #    cree la fenetre
   #------------------------------------------------------------
   proc HFDGraphe { } {
      global audace conf caption

      set visuNo $::audace(visuNo)
      set this $audace(base).hfd

      if { [ winfo exists $this ] } {
         destroy $this
      }

      set panneau(foc,hfd) ""          ; #-- valeur de HFD
      set panneau(foc,resulthfd) ""    ; #-- titre HFD= du graphique
      set panneau(foc,slopeleft) ""    ; #-- affichage en bas du graphique
      set panneau(foc,sloperight) ""   ; #-- affichage en bas du graphique
      set panneau(foc,optimum) ""      ; #-- affichage en bas du graphique

      #--   cree les vecteurs du graphique s'ils n'existent pas deja
      if {"::Vradius" ni [blt::vector names]} {
         #--   cree les vecteurs du graphique s'ils n'existent pas deja
         blt::vector create ::Vx ::Vintx ::Vradius ::Vhfd ::VSpos ::VShfd -watchunset 1
      }

      #--- Creation de la fenetre
      toplevel $this
      wm title $this "$caption(foc,focalisationHFD)"
      wm resizable $this 0 0
      wm geometry $this $conf(visufoc,position)
      wm protocol $this WM_DELETE_WINDOW { ::foc::closeHFDGraphe }

      label $this.hfd -textvariable panneau(foc,resulthfd)
      pack $this.hfd -side top -fill x

      frame $this.h
      pack $this.h -side top -fill x

      frame $this.h.fr0 -width 100 -height 100

         set grph0 [::foc::createSimpleGraphe $this.h.fr0 100 100]
         $grph0 configure -plotborderwidth 0 -relief flat
         $grph0 axis configure x -min 1 -max 100 -hide yes
         $grph0 axis configure y -min 1 -max 100 -hide yes

      pack $this.h.fr0 -side left

      frame $this.h.fr1 -width 100 -height 100

         set grph1 [::foc::createSimpleGraphe $this.h.fr1 100 100]
         #--   configure le graphique
         $grph1 element create color_invariant_lineR -xdata ::Vx -ydata ::Vintx \
            -linewidth 1 -color red -symbol "" -hide no
         $grph1 element configure color_invariant_lineR -mapy y
         $grph1 marker create line -name limite1 -coords [list 0 -Inf 0 Inf] \
            -linewidth 1 -outline black
         $grph1 marker create line -name limite2 -coords [list 0 -Inf 0 Inf] \
            -linewidth 1 -outline black

         $grph1 axis configure x -hide yes
         $grph1 axis configure y -hide yes

      pack $this.h.fr1 -side left

      frame $this.h.fr2 -width 100 -height 100

         set grph2 [::foc::createSimpleGraphe $this.h.fr2 100 100]
         #--   configure le graphique
         $grph2 element create color_invariant_lineR -xdata ::Vradius -ydata ::Vhfd \
            -linewidth 1 -color red -symbol "" -hide no
         $grph2 element configure color_invariant_lineR -mapy y
         $grph2 axis configure x -min 0 -max {} -hide yes
         $grph2 axis configure y -min 0 -max 1 -hide yes
         $grph2 marker create line -name rayon -coords [list 0 -Inf 0 Inf] \
            -dashes dash -linewidth 1 -outline blue

      pack $this.h.fr2 -side right

      frame $this.l
         frame $this.l.fr3 -width 300 -height 300

            set grph3 [::foc::createSimpleGraphe $this.l.fr3 300 300]
            #--   configure le graphique
            $grph3 element create color_invariant_lineR -xdata ::VSpos -ydata ::VShfd \
               -linewidth 1 -color blue -symbol "scross" -hide no
            $grph3 axis configure x -title "$::caption(foc,pos_focus)" \
               -min 0 -max {} -hide no
            $grph3 axis configure y -title "$::caption(foc,hfd)" -stepsize 1 \
               -min 0 -max {} -hide no
         pack $this.l.fr3 -anchor e

      pack $this.l -side top -fill x

      frame $this.b
         label $this.b.slopeleft -textvariable panneau(foc,slopeleft)
         pack $this.b.slopeleft -side top -fill none -padx 4 -pady 2
         label $this.b.sloperight -textvariable panneau(foc,sloperight)
         pack $this.b.sloperight -side top -fill none -padx 4 -pady 2
         label $this.b.optimum -textvariable panneau(foc,optimum)
         pack $this.b.optimum -side top -fill none -padx 4 -pady 2
      pack $this.b -side top -fill x

      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #------------------------------------------------------------
   # createSimpleGraphe
   #    Cree une zone graphique
   # Parametre : nom du frame renfemant le graphique
   # Return : nom complet du graphe
   #------------------------------------------------------------
   proc createSimpleGraphe { frm width height } {

      set grph [ blt::graph $frm.graph -title "" \
         -width $width -height $height \
         -takefocus 0 -bd 0 -relief flat \
         -rightmargin 0 -leftmargin 0 \
         -topmargin 0 -bottommargin 0 \
         -plotborderwidth 2 -plotrelief sunken \
         -plotpadx 0 -plotpady 0 ]
      pack $grph -in $frm -side top -fill both -expand 1

      #--   masque la legende
      $grph legend configure -hide yes

      return $grph
   }

   #------------------------------------------------------------
   # closeHFDGraphe
   #    ferme le graphique
   #------------------------------------------------------------
   proc closeHFDGraphe { } {
      variable This
      global audace conf

      #--   Interdit la fermeture pendant le fenetrage
      if {[$This.fra3.focuser.list cget -state] eq "disabled"} {return}

      set visuNo $::audace(visuNo)
      set this $audace(base).hfd

      #--   detruit les vecteurs crees avec la  fenetre
      if {"::Vradius" in [blt::vector names]} {
         blt::vector destroy ::Vx ::Vintx ::Vradius ::Vhfd ::VSpos ::VShfd
      }

      #--   supprime la maj automatique
      if { [trace info variable ::confVisu::addFileNameListener] ne ""} {
         ::confVisu::removeFileNameListener $visuNo "::foc::updateHFDGraphe $visuNo $this"
      }

      #--   parametre de conf identique quel que soit le graphique
      regsub {([0-9]+x[0-9]+)} [wm geometry $this] "" conf(visufoc,position)

      destroy $this
   }

   #------------------------------------------------------------
   # razGraph
   #    RAZ des graphiques
   #-----------------------------------------------------------
   proc razGraph { } {
      global audace panneau

      set panneau(foc,compteur) "0"
      closeAllWindows $audace(base)
      #--   Destruction et reconstruction des graphiques
      if { $panneau(foc,typefocuser) == "0"} {
         ::foc::focGraphe
      } else {
         ::foc::HFDGraphe
      }
   }

   #------------   fenetre affichant les valeurs  --------------

   #------------------------------------------------------------
   # qualiteFoc
   #    affiche la valeur des parametres dans une fenetre
   # Parametres : les valeurs a afficher
   #------------------------------------------------------------
   proc qualiteFoc { inten fwhmx fwhmy contr } {
      global audace caption conf panneau

      set this $audace(base).parafoc

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $this ] {
         fermeQualiteFoc
      }

      #--- Creation de la fenetre
      toplevel $this
      wm transient $this $audace(base)
      wm resizable $this 0 0
      wm title $this "$caption(foc,focalisation)"
      wm geometry $this $conf(parafoc,position)
      wm protocol $this WM_DELETE_WINDOW { ::foc::fermeQualiteFoc }
      #--- Cree les etiquettes
      label $this.lab1 -text "$panneau(foc,compteur)"
      pack $this.lab1 -padx 10 -pady 2
      label $this.lab2 -text "$caption(foc,intensite) $caption(foc,egale) $inten"
      pack $this.lab2 -padx 5 -pady 2
      label $this.lab3 -text "$caption(foc,fwhm__x) $caption(foc,egale) $fwhmx"
      pack $this.lab3 -padx 5 -pady 2
      label $this.lab4 -text "$caption(foc,fwhm__y) $caption(foc,egale) $fwhmy"
      pack $this.lab4 -padx 5 -pady 2
      label $this.lab5 -text "$caption(foc,contraste) $caption(foc,egale) $contr"
     pack $this.lab5 -padx 5 -pady 2
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #------------------------------------------------------------
   # fermeQualiteFoc
   #    ferme la fenetre de la qualite et sauve sa position
   # Parametre : chemin de la fenetre
   #------------------------------------------------------------
   proc fermeQualiteFoc { } {
      global audace conf

      set w $audace(base).parafoc

      #--- Determination de la position de la fenetre
      regsub {([0-9]+x[0-9]+)} [wm geometry $w] "" conf(parafoc,position)

      #--- Fermeture de la fenetre
      destroy $w
   }

   #-----------  barre de progression de la pose  --------------

   #------------------------------------------------------------
   # avancementPose
   #    sous processus de cmdAcq et de dispTime
   #------------------------------------------------------------
   proc avancementPose { t } {
      global audace caption color conf panneau

      #--- Fenetre d'avancement de la pose non demandee
      if { $panneau(foc,avancement_acq) == "0" } {
         return
      }

      #--   raccourci
      set w $audace(base).progress_pose

      #--- Recuperation de la position de la fenetre
      ::foc::closePositionAvancementPose

      #--- Initialisation de la barre de progression
      set cpt "100"

      #---
      if { [ winfo exists $w ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel $w
         wm transient $w $audace(base)
         wm resizable $w 0 0
         wm title $w "$caption(foc,en_cours)"
         wm geometry $w $conf(foc,avancement,position)

         #--- Cree le widget et le label du temps ecoule
         label $w.lab_status -text "" -justify center
         pack $w.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $panneau(foc,demande_arret) == "1" } {
            $w.lab_status configure -text "$caption(foc,numerisation)"
         } else {
            if { $t < "0" } {
               destroy $w
            } elseif { $t > "0" } {
               $w.lab_status configure -text "$t $caption(foc,sec) / \
                  [ format "%d" [ expr int( $panneau(foc,exptime) ) ] ] $caption(foc,sec)"
               set cpt [ expr $t * 100 / int( $panneau(foc,exptime) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $w.lab_status configure -text "$caption(foc,numerisation)"
            }
         }

         #---
         if { [ winfo exists $audace(base).progress_pose ] == "1" } {
            #--- Cree le widget pour la barre de progression
            frame $w.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack $w.cadre -in $w -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8

            #--- Affiche de la barre de progression
            frame $w.cadre.barre_color_invariant -height 26 -bg $color(blue)
            place $w.cadre.barre_color_invariant -in $w.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if { [ winfo exists $w ] == "1" } {
            ::confColor::applyColor $w
         }

      } else {

         #---
         if { $panneau(foc,pose_en_cours) == "0" } {

            #--- Je supprime la fenetre s'il n'y a plus de pose en cours
            ::foc::closePositionAvancementPose

         } else {

            if { $panneau(foc,demande_arret) == "0" } {
               if { $t > "0" } {
                  $w.lab_status configure -text "$t $caption(foc,sec) / \
                     [ format "%d" [ expr int( $panneau(foc,exptime) ) ] ] $caption(foc,sec)"
                  set cpt [ expr $t * 100 / int( $panneau(foc,exptime) ) ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  $w.lab_status configure -text "$caption(foc,numerisation)"
               }
            } else {
               #--- J'affiche "Lecture" des qu'une demande d'arret est demandee
               $w.lab_status configure -text "$caption(foc,numerisation)"
            }
            #--- Affiche de la barre de progression
            place $w.cadre.barre_color_invariant -in $w.cadre \
               -x 0 -y 0 -relwidth [ expr $cpt / 100.0 ]
            update

         }

      }

   }

   #------------------------------------------------------------
   # closePositionAvancementPose
   #    ferme la fenetre d'avancement de la pose et sauve sa position
   #------------------------------------------------------------
   proc closePositionAvancementPose { } {
      global audace conf

      set w $audace(base).progress_pose
      if [ winfo exists $w ] {
         #--- Determination de la position de la fenetre
         regsub {([0-9]+x[0-9]+)} [ wm geometry $w ] "" conf(foc,avancement,position)

         #--- Je supprime la fenetre s'il n'y a plus de pose en cours
         destroy $w
      }
   }

   #------------------------------------------------------------
   # closeAllWindows
   #    ferme toutes les fenetres annexes
   # Parametre : chemin du parent
   #------------------------------------------------------------
   proc closeAllWindows { base } {

      if {[winfo exists $base.parafoc]} {
         ::foc::fermeQualiteFoc
      }
      if {[winfo exists $base.visufoc]} {
         ::foc::fermeGraphe
      }
      if {[winfo exists $base.hfd]} {
         ::foc::closeHFDGraphe
      }
   }

   #------------------------------------------------------------
   # cmdSauveLog
   #    sous processus de cmdStop
   # Parametre : chemin du fichier
   #------------------------------------------------------------
   proc cmdSauveLog { namefile } {
      global panneau

      if [ catch { open [ file join $::audace(rep_log) $namefile ] w } fileId ] {
         return
      } else {
         puts -nonewline $fileId $panneau(foc,fichier)
         close $fileId
      }
   }

}

