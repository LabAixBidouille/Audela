#
# Fichier : collector_german.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   # nom proc                          utilisee par
   # ::collector::refreshMyTel         computeCoordNow
   # ::collector::rotateItem           refreshMyTel
   # ::collector::rotateDec            refreshMyTel
   # ::collector::makeSafeTel          refreshMyTel
   # ::collector::shiftButee           binding
   # ::collector::buildOngletGerman    createMyNoteBook
   # ::collector::setColor             buildOngletPosTel
   # ::collector::initMyTel            doUnPark
   # ::collector::refreshMountSide     refreshMyTel
   # ::collector::getGermanSide        doUnPark et doPark

   #------------------------------------------------------------
   #  refreshMyTel
   #  Deplace la position du telescope sur le symbole d'une monture allemande
   #------------------------------------------------------------
   proc refreshMyTel { } {
      variable private

      set canv $private(canvas)
      set tags [$canv gettags myTelAD]
      if {[llength $tags] !=4} {
         return
      }

      set ha $private(haTel)
      set elev $private(elevTel)
      set dec [mc_angle2deg $private(decTel)]

      #--   module AD
      lassign $tags -> -> oldHa oldLhTel

      #--   par defaut, pas de changement
      set newLhTel $oldLhTel

      #--   calcul la difference d'angle horaire
      set deltaHa [mc_anglescomp $oldHa - $ha]

      if {$deltaHa > 350} {
         #--   franchissement de 360° -> 0°
         set deltaHa [expr { $deltaHa - 360. }]
      } elseif {$deltaHa < -350 } {
         #--   franchissement 0°-> 360°
         set deltaHa [expr { $deltaHa + 360. }]
      }

      if {[expr { abs($deltaHa) }] < 20} {

         #---  rotation de l'item autour du centre du canvas,
         rotateItem $canv telescope 100 100 $deltaHa

         set newLhTel [expr { $oldLhTel - $deltaHa/15 } ]
         if {$newLhTel < -12} {
            set newLhTel [expr { $newLhTel + 12 }]
         }

         #--   met a jour les tags
         $canv itemconfigure myTelAD -tags [lreplace $tags 2 3 $ha $newLhTel]

      } else {
         return
      }

      #--   calcule l'angle polaire = distance avec le pole Nord
      set thetaTel [expr { 90.0 - $dec }]

      #--   calcule l'angle polaire de l'horizon
      set decHrz [getHrzDec [lindex $private(gps) 3] $ha]
      set thetaHrz [expr { 90 - $decHrz }]

      #--   l'angle polaire est positif a l'Est, negatif a l'Ouest
      if {$private(lhTel) > 0} {
         set thetaTel [expr { -$thetaTel }]
         set thetaHrz [expr { -$thetaHrz }]
      }

      #--   coordonnnees de l'extremite mobile de myTelAD
      lassign [$canv coords myTelAD] xc yc

      #--   angle complementaire a 180° de lhTel
      set angleZ [expr { 180 - $newLhTel * 15 }]
      set angleZ [expr { fmod($angleZ,180) }]

      rotateDec $canv myTelDEC [mc_angle2rad $angleZ] $dec

      set private(lhTel) [format %0.2f $newLhTel]
      set private(thetaTel) [format %0.2f $thetaTel]
      set private(thetaHrz) [format %0.2f $thetaHrz]
      set private(side) [refreshMountSide $private(product)]

      makeSafeTel $newLhTel $private(buteeWest) $private(buteeEast) [expr { abs(90-$dec) }] [expr { abs($thetaHrz) }]
   }

   #------------------------------------------------------------
   #  rotateDec
   #
   #  Parametres :
   #       canv - Path name of the canvas
   #       tagOrId - what to rotate
   #       angleZ - radian
   #       dec - degrees
   #------------------------------------------------------------
   proc rotateDec { canv tagOrId angleZ dec} {

      set dec [mc_angle2rad $dec]

      lassign [$canv gettags $tagOrId] -> -> halfBase halfHeight
      lassign [$canv coords $tagOrId] x0 y0 x1 y1 x2 y2

      #--   centre de rotation
      set xc [expr { ($x0 + ($x1+$x2)/2)/2. }]
      set yc [expr { ($y0 + ($y1+$y2)/2)/2. }]

      #---  distance au centre du triangle
      set dX [expr { $halfHeight*cos($dec)*cos($angleZ) }]
      set dY [expr { $halfHeight*cos($dec)*sin($angleZ) }]

      #---  demi base du triangle
      set deltaX [expr { $halfBase*sin($angleZ) }]
      set deltaY [expr { $halfBase*cos($angleZ) }]

      #---  coordonnees de la pointe du triangle
      set x1 [expr { $xc + $dX }]
      set y1 [expr { $yc + $dY }]

      #---  coordonnees d'un point de la base
      set x2 [expr { $xc - $dX - $deltaX }]
      set y2 [expr { $yc - $dY + $deltaY }]

      #---  coordonnees du second point de la base
      set x3 [expr { $xc - $dX + $deltaX }]
      set y3 [expr { $yc - $dY - $deltaY }]

      $canv coord $tagOrId $x1 $y1 $x2 $y2 $x3 $y3
   }

   #----------------------------------------------------------------------
   # rotateItem -- Rotates a canvas item any angle about an arbitrary point.
   # Works by rotating the coordinates of the object. Thus it works with:
   #  o polygon
   #  o line
   # It DOES NOT work correctly with:
   #  o rectangle
   #  o oval and arcs
   #  o text
   #
   # Parameters:
   #       canv - Path name of the canvas
   #       tagOrId - what to rotate -- may be composite items
   #       Ox, Oy - origin to rotate around
   #       angle - degrees clockwise to rotate by
   #
   # Results:
   #       Returns nothing
   #
   # Side effects:
   #       Rotates a canvas item by ANGLE degrees clockwise
   #
   #  source : adapte de http://wiki.tcl.tk/8595 RotateItem
   #----------------------------------------------------------------------
   proc rotateItem { canv tagOrId Ox Oy angle} {

      set angle [mc_angle2rad $angle] ;# Radians

      foreach id [$canv find withtag $tagOrId] {     ;# Do each component separately
        set xy {}
        foreach {x y} [$canv coords $id] {
            # rotates vector (Ox,Oy)->(x,y) by angle clockwise
            set x [expr {$x - $Ox}]             ;# Shift to origin
            set y [expr {$y - $Oy}]

            set xx [expr {$x * cos($angle) - $y * sin($angle)}] ;# Rotate
            set yy [expr {$x * sin($angle) + $y * cos($angle)}]

            set xx [expr {$xx + $Ox}]           ;# Shift back
            set yy [expr {$yy + $Oy}]
            lappend xy $xx $yy
        }
        $canv coords $id $xy
      }
   }

   #------------------------------------------------------------
   #  makeSafeTel
   #  Arrete le telescope s'il atteint l'une des butees Est ou Ouest ou a l'Horizon
   #------------------------------------------------------------
   proc makeSafeTel { lhTel buteeWest buteeEast thetaTel thetaHrz} {
      global audace caption

      if {$lhTel >= $buteeWest || $lhTel <= $buteeEast || $thetaTel > $thetaHrz \
         && $audace(telescope,controle) eq "$caption(telescope,suivi_marche)"} {

         #--   rem : la fonction verifie que le telescope a la capacite de controler le suivi
         ::telescope::controleSuivi "$caption(telescope,suivi_marche)"
      }
   }

   #------------------------------------------------------------
   #  shiftButee
   #  Déplace la butée sur le cercle
   #  Binding associee aux deux butees
   #------------------------------------------------------------
   proc shiftButee { visuNo w x y } {
      variable private

      lassign [$w itemcget [$w find withtag current] -tags]  -> TagOrId

      set startOld [lindex [$w gettags West] 2]
      set endOld [lindex [$w gettags East] 2 ]

      set distanceX [expr { $x-100 }]
      set distanceY [expr { $y-100 }] ; # toujours >= 0 car en dessous du centre

      #--   identifie le centre de la butee
      lassign [::polydraw::center $visuNo $w $TagOrId] x1 y1

      #--   calcule l'angle reel en rad
      set angleRad [expr { acos($distanceX/hypot($distanceX,$distanceY)) }]

      #--   calcule la position sur le cercle
      set rayon 60
      set dx [expr { 100 + $rayon*cos($angleRad) - $x1 }]
      set dy [expr { 100 + $rayon*sin($angleRad) - $y1 }]

      #--   deplace la butee
      $w move $TagOrId $dx $dy

      #--   calcule l'angle retrograde, Est = 0°
      set newAngle [expr { 360 - $angleRad * 180/(4*atan(1.)) } ]

      #--   rafraichit la valeur de la butee
      if {$TagOrId eq "West"} {
         if {$newAngle <= 180 || $newAngle >= 270} {
            #--   arrete si pas dans le quadrant (180°,270°) sens direct
            return
         }
         set lh [expr { $newAngle/15 -6 }]
         set start $newAngle
         set extent [expr { $endOld - $newAngle }]
      } elseif {$TagOrId eq "East"} {
         if {$newAngle <= 270 || $newAngle >= 360} {
            #--   arrete si pas dans le quadrant (270°,360°) sens direct
            return
         }
         set lh [expr { -30 + $newAngle/15 }]
         set start $startOld
         set extent [expr { $newAngle - $startOld }]
      }

      #--   met a jour les donnees
      $w itemconfigure $TagOrId -tags [list butee $TagOrId $newAngle]
      $w itemconfigure sector -start $start -extent $extent
      set private(butee$TagOrId) [format "%02.2f" $lh]
   }

   #------------------------------------------------------------
   #  buildOngletGerman
   #  Cree l'onglet 'Monture Allemande'
   #------------------------------------------------------------
   proc buildOngletGerman { w visuNo } {
      variable private
      global conf caption

      #::console::affiche_resultat "$private(colFond) $private(colReticule) \
      #   $private(colTel) $private(colButee) $private(colSector)\n"

      set private(hautInf) $conf(cata,haut_inf)
      set private(hautSup) $conf(cata,haut_sup)

      label $w.postel -text "$caption(collector,postel)"
      grid $w.postel -row 0 -column 0 -columnspan 5 -sticky ew

      set r 1
      foreach z [list hautInf hautSup buteeWest buteeEast lhTel thetaTel thetaHrz] {
         label $w.lab_$z -text "$caption(collector,$z)"
         grid $w.lab_$z -row $r -column 0 -padx {5 0} -sticky w
         label $w.$z -textvariable ::collector::private($z)
         grid $w.$z -row $r -column 1 -padx {5 0} -sticky w
         incr r
      }
      label $w.side -textvariable ::collector::private(side)
      grid $w.side -row $r -column 0 -columnspan 2 -padx {5 0} -sticky w
      incr row
      grid columnconfigure $w {0 1} -pad 10

      set canv $w.gr_polaire_color_invariant
      set private(canvas) $canv

      #---  cree le canvas
      canvas $canv -width 200 -height 200 -borderwidth 2 -bg $private(colFond)
      grid $canv -row 1 -column 2 -rowspan 9 -padx 10

      #---  cree un cercle de centre {100,100}
      set xc 100
      set yc 100
      set rayon 60 ;
      $canv create oval [expr {$xc-$rayon}] [expr {$yc-$rayon}] [expr {$xc+$rayon}] [expr {$yc+$rayon}] \
         -outline $private(colReticule) -width 2 -tags [list cercle]

      #---   gradue en heures
      for {set angle_deg 0} {$angle_deg < 360} {incr angle_deg 15} {
         set angle_rad [mc_angle2rad $angle_deg]
         set x1 [expr { $xc+65*cos($angle_rad) }]
         set y1 [expr { $yc+65*sin($angle_rad) }]
         set x2 [expr { $xc+55*cos($angle_rad) }]
         set y2 [expr { $yc+55*sin($angle_rad) }]
         $canv create line $x1 $y1 $x2 $y2 -tags [list reticule traits] \
            -width 2 -fill $private(colReticule)
      }

      #---   gradue en chiffres
      for {set angle_deg 255} {$angle_deg >= -75} {incr angle_deg "-15"} {
         set angle_rad [mc_angle2rad $angle_deg]
         set x [expr { $xc+50*cos($angle_rad) }]
         set y [expr { $yc-50*sin($angle_rad) }]
         set nom [expr { $angle_deg/15-6 }]
         if {$angle_deg > 90} {
            #--   ajoute le signe +
            set nom +$nom
         }
         $canv create text $x $y -text "$nom" -tags [list reticule chiffres] \
            -fill $private(colReticule) -font {Arial 7 bold}
      }

      #---   annote Ouest et Est et Meridien
      $canv create text 10 100 -text "$caption(collector,west)" -tags [list reticule texte]\
         -fill $private(colReticule) -font {Arial 8}
      $canv create text 190 100 -text "$caption(collector,east)" -tags [list reticule texte] \
         -fill $private(colReticule) -font {Arial 8}
      $canv create line 100 0 100 200 -width 1 -dash {2 4} -tags [list reticule texte] \
         -fill $private(colReticule)

      #--   cree un ? pour marquer l'absence d'info
      $canv create bitmap 100 80 -bitmap question -state normal \
         -anchor center -foreground $private(colButee) \
         -tags question

      #--    cree les symboles du telescope en mode Zénith Ouest
      #--   axe horaire
      $canv create line 35 100 100 100 -fill "" -width 4 -smooth 1 \
         -tags [list telescope myTelAD]
      #--   symbole (triangle) du telescope
      set xc
      set yc 100
      #--   demi base du triangle (pixels)
      set halfbase 10
      #--   demi hauteur du triangle (pixels)
      set halfHeight 60
      $canv create polygon 35 160 25 40 45 40 -fill "" -width 20 \
         -tags [list telescope myTelDEC $halfbase $halfHeight]

      showTelescope $canv 0 $private(colButee) $private(colFond)

      #---   secteur interdit (angles comptes dans le sens retrograde)
      set angleStart [expr { (6+$private(buteeWest))*15 }]
      set angleEnd [expr { 450+$private(buteeEast)*15 }]

      #--   calcule la longueur de l'arc
      set extent [expr { $angleEnd - $angleStart }]
      $canv create arc [expr {$xc-$rayon+1}] [expr {$yc-$rayon+1}] [expr {$xc+$rayon-1}] [expr {$yc+$rayon-1}] \
         -style pieslice -width 1 -start $angleStart -extent $extent -fill $private(colSector) \
         -tags [list sector]

      #--   cree la butee Ouest
      set angleW [mc_angle2rad $angleStart]
      set x1 [expr { round($xc+$rayon*cos($angleW)) }]
      set y1 [expr { round(200-$yc-$rayon*sin($angleW)) }]
      $canv create oval [expr {$x1-5}] [expr {$y1-5}] [expr {$x1+5}] [expr {$y1+5}] \
         -fill $private(colButee) -tags [list butee West $angleStart]

      #--   cree la butee Est
      set angleE [mc_angle2rad $angleEnd]
      set x2 [expr { round($xc+$rayon*cos($angleE)) }]
      set y2 [expr { round(200-$yc-$rayon*sin($angleE)) }]
      $canv create oval [expr {$x2-5}] [expr {$y2-5}] [expr {$x2+5}] [expr {$y2+5}]  \
         -fill $private(colButee) -tags [list butee East $angleEnd]

      $canv bind butee <ButtonRelease-1> "::collector::shiftButee $visuNo %W %x %y"

      #--   affiche la legende des couleurs
      label $w.legende -text "$caption(collector,legende)"
      grid $w.legende -row 1 -column 3 -columnspan 2 -padx {5 0} -sticky w
      set row 2
      set colorItem [list colFond fond colReticule reticule colTel telescope \
         colButee butee colSector sector]
      foreach {col item} $colorItem {
         label $w.lab_$col -text "$caption(collector,$col)"
         grid $w.lab_$col -row $row -column 3 -padx {5 0} -sticky w
         button $w.but_${col}_color_invariant -relief raised -width 4 \
            -bg $private($col) -activebackground $private($col) \
            -command "::collector::setColor $w $item $col"
         grid $w.but_${col}_color_invariant -row $row -column 4 -padx {5 0} -sticky w
         incr row
      }
   }

   #------------------------------------------------------------
   #  setColor
   #  Selectionne et change la couleur a appliquer a un element
   #  Parametres : parent du bouton, nom de l'item et de la variable de couleur
   #  Commnade des boutons de selection des couleurs
   #------------------------------------------------------------
   proc setColor { parent item variable_color } {
      variable private
      global caption

      set w $private(canvas)

      set color [tk_chooseColor -initialcolor $private($variable_color) \
         -parent $parent -title $caption(collector,$variable_color)]

      if  {"$color" != ""} {

         set private($variable_color) "$color"
         $parent.but_${variable_color}_color_invariant configure \
            -bg $color -activebackground $color

         if {$item in [list butee sector telescope]} {
            $w itemconfigure $item -fill $color
         } elseif {$item eq "fond" } {
            $w configure -bg $color
         } elseif {$item eq "reticule" } {
            $w itemconfigure cercle -outline $color
            $w itemconfigure reticule -fill $color
         }
      }
   }

   #------------------------------------------------------------
   #  initMyTel
   #  Initialise la position du telescope sur le symbole d'une monture allemande
   #  Parametres : mode (index de la combobox du choix du mode d'initialisation)
   #     et side (côte ou se trouve le tube E ou W)
   #  Complete les tags avec l'angle horaire (hms) et la longitude horaire (en heures)
   #------------------------------------------------------------
   proc initMyTel { mode side } {
      variable private
      global conf

      set w $private(canvas)
      set dec [mc_angle2deg $private(decTel)]
      set ha $private(haTel)

      #--   repositionne le symbole en position Zénith Ouest
      $w coord myTelAD 35 100 100 100
      $w coord myTelDEC 35 160 25 40 45 40

      #--   deltaRot = difference d'angle (retrograde) graphique de AD
      #--   lhTel = difference d'angle (retrograde) graphique de AD

      if {$mode in [list 1 2 7 8]} {
         set lhTel 0.00
         set deltaRot 90
      } elseif {$mode in [list 0 3 4 5 6]} {
        if {$side eq "W" } {
            set lhTel 6.00
            set deltaRot 0
         } elseif {$side eq "E"} {
            set lhTel -6.00
            set deltaRot 180
         }
      } else {
         #--   mode Utilisateur
         set lhTel [expr { [mc_angle2deg $ha] / 15 }]
         set deltaRot [mc_anglescomp 24h00m00s - $ha]
      }

      showTelescope $w 1 $private(colTel) $private(colFond)

      #--   tourne les deux a partir de la position Zénith Ouest
      rotateItem $w telescope 100 100 $deltaRot
      $w itemconfigure myTelAD -tags [list telescope myTelAD $ha $lhTel]
   }

   #------------------------------------------------------------
   #  showTelescope
   #  Gere l'alternance de l'affichage entre item(s) et bitmap
   #  Parametres  : todo {1 = affiche | 0 = masque}
   #                unmaskColor couleur pour demasquer (couleur du bitmap , couleur de remplissage pour -fill)
   #                maskColor couleur pour masquer (couleur du fond pour un bitmap , "" pour -fill)
   #------------------------------------------------------------
   proc showTelescope { canv todo unmaskColor maskColor } {

   #::console::affiche_resultat "showTelescope todo $todo unmaskColor $unmaskColor maskColor $maskColor\n"

      if {$todo == 1} {
         #--   masque le ? et demasque le telescope
         $canv itemconfigure question -foreground $maskColor
         $canv itemconfigure telescope -fill $unmaskColor
      } else {
         #--   demasque le ? et masque le telescope
         $canv itemconfigure question -foreground $unmaskColor
         $canv itemconfigure telescope -fill $maskColor
      }
   }

   #------------------------------------------------------------
   #  refreshMountSide
   #  Retourne : cote de la monture
   #  Parametre : nom de la monture
   #------------------------------------------------------------
   proc refreshMountSide { mount {telNo 1} } {
      global caption

      switch -exact $mount {
            temma {  set telSide [tel$telNo german]
                     lassign $caption(collector,parkOptSide) ouest est
                     set side [string map [list W $ouest E $est ] $telSide]
                  }
            eqmod {  set telSide [tel$telNo orientation]
                     set ouest $caption(eqmod,tube_ouest)
                     set est $caption(eqmod,tube_est)
                     set side [string map [list w $ouest e $est ] $telSide]
                  }
            default { set side "?"}
      }

      return $side
   }

   #------------------------------------------------------------
   #  getGermanSide
   #  Retourne le cote ou se trouve le tube, l'index de la combobox
   #  et la position litterale pour un telescope Temma
   #------------------------------------------------------------
   proc getGermanSide { } {
      global audace caption

      set telNo $audace(telNo)
      set telSide [tel$telNo german]
      set sideIndex [string map [list W 0 E 1] $telSide]
      set side "[lindex $caption(collector,parkOptSide) $sideIndex]"

      return [list $telSide $sideIndex $side]
   }

