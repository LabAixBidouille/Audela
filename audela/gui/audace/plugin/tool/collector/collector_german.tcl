#
# Fichier : collector_german.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   # nom proc                          utilisee par
   # ::collector::refreshMyTel         refreshNotebook
   # ::collector::rotateCW             refreshMyTel
   # ::collector::rotateOTA            refreshMyTel
   # ::collector::makeSafeTel          refreshMyTel
   # ::collector::getMountSide         refreshMyTel
   # ::collector::showTelescope        buildOngletGerman et onChangeMount
   # ::collector::buildOngletGerman    createMyNoteBook
   # ::collector::buildShowValues      buildOngletGerman
   # ::collector::buildGrid            buildOngletGerman
   # ::collector::buildSector          buildOngletGerman
   # ::collector::shiftButee           binding
   # ::collector::builColorLegend      buildOngletGerman
   # ::collector::setColor             buildOngletPosTel

   #------------------------------------------------------------
   #  refreshMyTel
   #  Deplace la position du telescope sur le symbole d'une monture allemande
   #  Duree : < 400 microsecondes sauf si cote du tube est rafraichit
   #------------------------------------------------------------
   proc refreshMyTel { } {
      variable private
      global audace caption

      set canv $private(canvas)
      if {![winfo exists $canv]} {return}

      if {$private(haTel) ne "-"} {
         set haTel $private(haTel)
      } else {
         return
      }

      lassign [rotateCW $canv $haTel] xc yc
      set decTel [mc_angle2deg $private(decTel)]
      rotateOTA $canv $haTel $decTel $xc $yc

      #-- rafaichit le cote du tube toutes le 10 secondes
      regsub -all {[-T:]} $private(tu) " " horodate
      if {[expr { fmod([lindex $horodate 5],10) }] == 0} {
         set private(side) [getMountSide]
      }

      makeSafeTel
   }

   #----------------------------------------------------------------------
   # rotateCW
   #  Tourne l'axe des contrepoids CW
   #  Parametres  : canvas et angle de position (degres)
   #  Duree : 120 microsecondes
   #----------------------------------------------------------------------
   proc rotateCW { canv haTel } {

      set tagOrId CW
      set angle [expr { fmod($haTel+180,360) } ]
      set tags [$canv gettags $tagOrId]
      lassign $tags -> -> prevAngle x1 y1 xc yc

      #--   filtre les valeurs anormales
      if {[expr { abs($angle-$prevAngle) }] < 10} {

         set angle_rad [mc_angle2rad $angle] ;# radians

         #--   coordonnees de l'extremite mobile
         set x1 [expr { round($xc+65*cos($angle_rad)) }]
         set y1 [expr { round($yc-65*sin($angle_rad)) }]
         $canv coords $tagOrId $x1 $y1 $xc $yc

         #--   memorise la position et l'angle en degres
         $canv itemconfigure $tagOrId -tags [lreplace $tags 2 end $angle $x1 $y1 $xc $yc]
      }

      return [list $x1 $y1]
   }

   #------------------------------------------------------------
   #  rotateOTA
   #   Tourne le tube OTA
   #  Parametres : canv, angleZ (degres) et dec (degres) et
   #  coordonnes du centre de rotation de OTA
   #  Duree : 160 microsecondes
   #------------------------------------------------------------
   proc rotateOTA { canv haTel decTel xc yc } {

      set tagOrId OTA
      set tags [$canv gettags $tagOrId]
      lassign [$canv gettags $tagOrId] -> -> halfBase halfHeight xcBase ycBase prevDec

      if { [expr { abs($prevDec-$decTel) }] < 10} {

         set angleZ [mc_angle2rad [expr { fmod(450-$haTel,360) }]]
         set dec_rad [mc_angle2rad $decTel]

         #---  distance au centre du triangle
         set dX [expr { $halfHeight*cos($dec_rad)*cos($angleZ) }]
         set dY [expr { $halfHeight*cos($dec_rad)*sin($angleZ) }]

         #--   coordonnees de la pointe du triangle
         set x1 [expr { round($xc+$dX) }]
         set y1 [expr { round($yc+$dY) }]

         #---  ecart par rapport a la demi base du triangle
         set deltaX [expr { $halfBase*sin($angleZ) }]
         set deltaY [expr { $halfBase*cos($angleZ) }]

         #--   coordonnees du milieu de la base
         set xcBase [expr { $xc-$dX }]
         set ycBase [expr { $yc-$dY }]

         #--   coordonnees du premier point de la base
         set x2 [expr { round($xcBase-$deltaX) }]
         set y2 [expr { round($ycBase+$deltaY) }]

         #--   coordonnees du second point de la base
         set x3 [expr { round($xcBase+$deltaX) }]
         set y3 [expr { round($ycBase-$deltaY) }]

         $canv coord $tagOrId $x1 $y1 $x2 $y2 $x3 $y3
         set tags [lreplace $tags 4 6 $xcBase $ycBase $decTel]
         $canv itemconfigure $tagOrId -tags $tags
      }
   }

   #------------------------------------------------------------
   #  getMountSide
   #  Retourne : cote de la monture
   #  Duree : 250 millisecondes
   #------------------------------------------------------------
   proc getMountSide { {telNo 1} } {

      return [string map -nocase \
         [list W "$::caption(collector,west)" E "$::caption(collector,east)"]\
         [tel$telNo german]]
   }


   #------------------------------------------------------------
   #  makeSafeTel
   #  Arrete le telescope s'il atteint l'une des butees Est ou Ouest ou l'Horizon
   #  Duree : 30 microsecondes
   #------------------------------------------------------------
   proc makeSafeTel { } {
      variable private
      global audace caption

      #--   calcule les limites de haTel
      set haLimWest [expr { 360-$private(buteeWest)*15 }]
      set haLimEast [expr { abs($private(buteeEast)*15) }]

      #--   rem : la fonction verifie que le telescope a la capacite de controler le suivi
      if { ($private(elevTel) < $private(elevInf) || $private(haTel) >= $haLimEast  &&  $private(haTel) <= $haLimWest) \
         && $audace(telescope,controle) eq "$caption(telescope,suivi_marche)"} {
         ::telescope::controleSuivi "$caption(telescope,suivi_marche)"
      }
   }

   #------------------------------------------------------------
   #  showTelescope
   #  Gere l'alternance de l'affichage entre item(s) et bitmap
   #  Parametres  : todo {1 = affiche | 0 = masque}
   #                unmaskColor couleur pour demasquer (couleur du bitmap , couleur de remplissage pour -fill)
   #                maskColor couleur pour masquer (couleur du fond pour un bitmap , "" pour -fill)
   #------------------------------------------------------------
   proc showTelescope { canv todo unmaskColor maskColor } {

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
   #  buildOngletGerman
   #  Cree l'onglet 'Monture Allemande'
   #  Parametres : chemin et visuNo
   #------------------------------------------------------------
   proc buildOngletGerman { w visuNo } {
      variable private

      buildShowValues $w

      set anglePos [expr { fmod(0+180,360) } ]                     ; #--    degres
      set angleDec [lindex $::audace(posobs,observateur,gps) 3]    ; #--    degres

      #---  definit le centre {100,100} et le rayon de la grille
      set xc 100
      set yc 100
      set rayon 60
      set canv [buildGrid $w 200 200 $xc $yc $rayon]

      #--   axe du contrepoids (CW) en position horizontale (Zénith Ouest)
      set cwLength 65 ; # rayon+5
      $canv create line [expr { $xc-$cwLength }] $yc $xc $yc \
         -fill "" -width 4 -smooth 1 \
         -tags [list telescope CW $anglePos [expr { $xc-$cwLength }] $yc $xc $yc]

      #--   tube optique OTA
      #--   demi base du triangle (pixels)
      set halfbase 10
      #--   demi hauteur du triangle (pixels)
      set halfHeight 60
      #--   coordonnees du centre de la base du triangle
      set xcBase 35
      set ycBase 40
      set tags [list telescope OTA $halfbase $halfHeight $xcBase $ycBase $angleDec]
      $canv create polygon $xcBase [expr { $yc+$halfHeight}] \
         [expr { $xcBase-$halfbase }] [expr { $yc-$halfHeight}] \
         [expr { $xcBase+$halfbase }] [expr { $yc-$halfHeight}] \
         -fill "" -width 20 -tags $tags

      buildSector $visuNo $xc $yc $rayon ; #-- secteur interdit
      builColorLegend $w ; #-- legende des couleurs

      showTelescope $canv 0 $private(colButee) $private(colFond)
   }

   #------------------------------------------------------------
   #  buildShowValues
   #  Construit l'affichage des valeurs
   #  Parametres : chemin
   #------------------------------------------------------------
   proc buildShowValues { w } {
      variable private
      global conf caption

      label $w.postel -text "$caption(collector,postel)"
      grid $w.postel -row 0 -column 0 -columnspan 5 -sticky ew

      set r 1
      foreach z [list elevInf buteeWest buteeEast side] {
         label $w.lab_$z -text "$caption(collector,$z)"
         grid $w.lab_$z -row $r -column 0 -padx {5 0} -sticky w
         label $w.$z -textvariable ::collector::private($z)
         grid $w.$z -row $r -column 1 -padx {5 0} -sticky w
         incr r
      }
      grid columnconfigure $w {0 1} -pad 10

      set private(elevInf) $conf(cata,haut_inf)
      set private(side)
   }

   #------------------------------------------------------------
   #  buildGrid
   #  Construit la grille avec les annotations
   #  Parametres : largeur et hauteur du canvas,
   #  coordonnees du centre du cercle er rayon
   #------------------------------------------------------------
   proc  buildGrid { w x y xc yc rayon } {
      variable private
      global caption

      set canv $w.gr_polaire_color_invariant
      set private(canvas) $canv

      #---  cree le canvas
      canvas $canv -width $x -height $y -borderwidth 2 -bg $private(colFond)
      grid $canv -row 1 -column 2 -rowspan 9 -padx 10

      $canv create oval [expr {$xc-$rayon}] [expr {$yc-$rayon}] \
         [expr {$xc+$rayon}] [expr {$yc+$rayon}] \
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
      $canv create text 10 100 -text "$caption(collector,west)" -font {Arial 8} \
         -fill $private(colReticule) -tags [list reticule texte]
      $canv create text 190 100 -text "$caption(collector,east)" -font {Arial 8} \
         -fill $private(colReticule) -tags [list reticule texte]
      $canv create line 100 0 100 200 -width 1 -dash {2 4} -tags [list reticule texte] \
         -fill $private(colReticule)

      #--   cree un ? pour marquer l'absence d'info
      $canv create bitmap 100 80 -bitmap question -state normal \
         -anchor center -foreground $private(colButee) -tags question

      return $canv
   }

   #------------------------------------------------------------
   #  buildSector
   #  Construit les butees et le secteur interdit
   #  Parametres : rayon du cercle
   #------------------------------------------------------------
   proc buildSector { visuNo xc yc rayon } {
      variable private

      set canv $private(canvas)

      #---   secteur interdit (angles comptes dans le sens retrograde)
      set angleStart [expr { $private(buteeWest)*15+90 }]
      set angleEnd [expr { $private(buteeEast)*15+450 }]

      #--   calcule la longueur de l'arc
      set extent [expr { $angleEnd - $angleStart }]
      $canv create arc [expr {$xc-$rayon+1}] [expr {$yc-$rayon+1}] \
         [expr {$xc+$rayon-1}] [expr {$yc+$rayon-1}] \
         -style pieslice -fill $private(colSector) -width 1 \
         -start $angleStart -extent $extent -tags [list sector]

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
   }

   #------------------------------------------------------------
   #  shiftButee
   #  Déplace la butée sur le cercle
   #  Binding associee aux deux butees
   #------------------------------------------------------------
   proc shiftButee { visuNo w x y } {
      variable private

      lassign [$w itemcget [$w find withtag current] -tags]  -> TagOrId

      #--   recupere les HA des butees Ouest et Est
      set startOld [lindex [$w gettags West] 2]
      set endOld [lindex [$w gettags East] 2 ]

      set distanceX [expr { $x-100 }]
      set distanceY [expr { $y-100 }] ; # toujours >= 0 car en dessous du centre

      #--   calcule l'angle reel en rad
      set angleRad [expr { acos($distanceX/hypot($distanceX,$distanceY)) }]

      #--   identifie le centre de la butee active
      lassign [$w coord $TagOrId] x1 y1 x2 y2
      set x1 [expr  { ($x1+$x2)/2 }]
      set y1 [expr  { ($y1+$y2)/2 }]

      #--   calcule la position sur le cercle
      set rayon 60
      set dx [expr { 100 + $rayon*cos($angleRad) - $x1 }]
      set dy [expr { 100 + $rayon*sin($angleRad) - $y1 }]

      set angleDirect [expr { $angleRad * 180/(4*atan(1.)) } ]

      #--   calcule l'angle retrograde, Est = 0°
      set newAngle [expr { 360-$angleDirect } ]

      #--   rafraichit la valeur de la butee
      if {$TagOrId eq "West"} {
         if {$newAngle <= 180 || $newAngle >= 270} {
            #--   arrete si pas dans le quadrant (180°,270°) sens direct
            return
         }
         set dha [expr { fmod(270-$angleDirect,360)/15 }]
         set start $newAngle
         set extent [expr { $endOld - $newAngle }]
      } elseif {$TagOrId eq "East"} {
         if {$newAngle <= 270 || $newAngle >= 360} {
            #--   arrete si pas dans le quadrant (270°,360°) sens direct
            return
         }
         set dha [expr { -fmod(90+$angleDirect,360)/15 }]
         set start $startOld
         set extent [expr { $newAngle - $startOld }]
      }

      #--   deplace la butee
      $w move $TagOrId $dx $dy

      #--   met a jour les donnees
      $w itemconfigure $TagOrId -tags [list butee $TagOrId $newAngle]
      $w itemconfigure sector -start $start -extent $extent
      set private(butee$TagOrId) [format "%02.2f" $dha]
   }

   #------------------------------------------------------------
   #  builColorLegend
   #  Construit la legende des couleurs
   #  Parametres : chemin
   #------------------------------------------------------------
   proc builColorLegend { w } {
      variable private
      global caption

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