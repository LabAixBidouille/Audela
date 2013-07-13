#
# Fichier : focHFD.tcl
# Description : Script de mise en oeuvre du HFD
# Compatibilité : USB_Focus et AudeCom
# Auteurs : Raymond ZACHANTKE
# Mise à jour $Id$
#

   #---------------------------------------------------------------------------
   #  ::foc::traceCurve : processus de mesure pour differentes positions
   #---------------------------------------------------------------------------
   proc ::foc::traceCurve { } {
      global audace

      set this $::audace(base).hfd
      if {![winfo exists $this]} {
         ::foc::initFocHFD
      }

      ::foc::updateHFDGraphe $::audace(visuNo) $this

      #--   au moins deux mesures pour calculer la pente
      #if {[::VShfd length] >=2} {
      #   ::foc::computeSlope
      #}

      #--   modifie la position du focaliseur
      #---incr audace(focus,targetFocus) 6000
      #---cmdSeDeplaceA
   }

   #---------------------------------------------------------------------------
   #  ::foc::computeSlope : calcule la variation de HFD en fonction de la position
   #     par ajustement lineaire
   #---------------------------------------------------------------------------
   proc ::foc::computeSlope { } {
      global caption

      blt::vector create y w -watchunset 1
      y set ::VShfd           ; #--copie le vecteur
      set n [::VShfd length]  ; #--nb d'elements
      w length $n             ; #--matrice remplie de longueur n remplie de 0
      w expr { w == 0 }       ; #--matrice unitaire

      set X ""
      for { set i 0 } { $i <  $n } { incr i } {
         lappend X [list 1 [::VSpos index $i]]
      }

      #--   resout le systeme y=a+b*x
      lassign [lindex [ gsl_mfitmultilin $y(:) $X $w(:) ] 0] constante slope
      set step0 [format "%0.2f" [expr { $constante/$slope }]]
      ::console::affiche_resultat "HFD = 0 pour $step0 $caption(foc,pas)\n"
      set constante [format "%0.2f" $constante]
      set slope [format "%0.2f" $slope]
      set text "HFD = $constante "
      if {$contante > 0} {
         append text "+"
      }
      append text "$slope" " * " $caption(foc,pas)
      ::console::affiche_resultat "$text\n"

      blt::vector destroy y w
   }

   #---------------------------------------------------------------------------
   #   updateHFDGraphe : met a jour les graphiques
   #   Parametres : N° de la visu contenant l'image source et le nom du frame global
   #   Duree : entre 40 et 100 ms
   #---------------------------------------------------------------------------
   proc ::foc::updateHFDGraphe { visuNo this args } {
      variable private

      set box [::confVisu::getBox $visuNo]

      #--   arrete si la box est vide
      if { $box eq ""} { return }

      #--   etape 1 : extraction de la boite et de la coupe horizontale
      #--   peuple les vecteurs abscisses (::Vx) et ordonnees(::Vint) du graphe1
      ::foc::createCoupeHoriz $visuNo $box

      #--   extraction des limites d'analyse
      #--   1/e² = 0.135 du pic (1/e-Squared Halfwidth)
      lassign [::foc::getLimits ::Vintx 0.135] start end

      if {$start != 1 && $end != [::Vx length]} {

         #--   si les limites sont dans la boite
         #--   etape 2 : extraction du flux cumule en fonction du rayon
         #--   peuple les vecteurs abscisses (::Vradius) et ordonnees(::Vhfd) du graphe2
         set rayon [::foc::computeHFD ::Vintx $start $end]

         #--   etape 3 : met a jour les titres et les graphiques
         incr private(count)
         ::foc::updateValues $this $start $end $rayon

      } else {
         ::console::affiche_resultat "mesure invalide\n"
      }
   }

   #---------------------------------------------------------------------------
   #   ::foc::createCoupeHoriz :
   #     Extrait une image de la boite de selection
   #     binne l'image en Y
   #   Parametres : N° de la visu et boite de selection
   #---------------------------------------------------------------------------
   proc ::foc::createCoupeHoriz { visuNo  box } {
      global audace conf

      #--   recopie l'image vers le buffer dest
      set dest [::buf::create]
      set rep $audace(rep_images)
      set ext $conf(extension,defaut)

      buf[visu$visuNo buf] copyto $dest

      #--   extrait la sous-image contenue dans la box
      lassign $box x1 y1 x2 y2
      buf$dest imaseries "WINDOW x1=$x1 y1=$y1 x2=$x2 y2=$y2"

      #--   normalise le fond du ciel a 0
      buf$dest noffset 0

      buf$dest save [file join  $rep extract.fit]

      set naxis1 [buf$dest getpixelswidth]
      set naxis2 [buf$dest getpixelsheight]

      ttscript2 "IMA/SERIES \"$rep\" extract . . $ext  \"$rep\" biny . $ext BINY y1=1 y2=$naxis2 height=1 bitpix=32"

      #--   peuple le vecteur intensite du profil en X (variation entre {0|1})
      blt::vector create temporaire -watchunset 1
      temporaire offset 1                             ; #-- fait correspondre les indices et le N° de pixel
      buf$dest load [file join $rep biny$ext]         ; #-- recupere le fichier binne
      for {set col 1} {$col <=$naxis1} {incr col} {
         temporaire append [lindex [buf$dest getpix [list $col 1]] 1]
      }
      temporaire expr { temporaire/$temporaire(max) } ; #-- maintenant max == 1.0
      ::Vintx set temporaire                          ; #-- trasnfert vers le vecteur graphique

      #--   peuple le vecteur ::Vx abscisse du graphe1
      ::Vx offset 1                                   ; #-- fait correspondre les indices et le N° de pixel
      ::Vx seq 1 $naxis1

      blt::vector destroy temporaire
      ::buf::delete $dest
      file delete [file join $rep extract$ext] [file join $rep biny$ext]
   }

   #---------------------------------------------------------------------------
   #   ::foc::getLimits : cherche les limites dans un vecteur de flux
   #   Parametres : nom du vecteur a traiter et limite d'ecretage (en fraction du max)
   #   Return : les limites robustes
   #---------------------------------------------------------------------------
   proc ::foc::getLimits { vectorName limit } {

      blt::vector create Vindex -watchunset 1

      #--    attention : le pemier indice de Vindex est 1
      Vindex expr { $vectorName >= $limit }                 ; #--   Vindex contient 1 si la valeur > $limit, sinon 0
      Vindex set [Vindex search 1.0]                        ; #--   Vindex contient la liste des index des valeurs > $limit
      set len [Vindex length]

      #--   la serie d'index est sans trou si la difference entre les index == 1
      #     dans ce cas le nombre d'elements est egal a
      #     la difference entre le dernier et le premier+1
      if {$len  != [expr { $Vindex(end)-$Vindex(1)+1 }]} {

         #--   filtre les index hors serie
         set listToDestroy [list]
         set middle [expr { int($len/2) }]

         #--   etablit la liste des index a supprimer
         for {set j 1} {$j < $len} {incr j} {
            set delta [expr { $Vindex($j+1)-$Vindex($j) }]  ; #--   difference entre deux index successifs
            if {$delta !=1 && $j < $middle} {
               lappend listToDestroy $j                     ; #--   index de l'element courant
            } elseif {$delta !=1 && $j > $middle} {
               lappend listToDestroy [expr { $j+1} ]        ; #--   index de l'element suivant
            }
         }

         set indexEnd [expr { [llength $listToDestroy]-1 }]
         #--   on commence par la fin du vecteur
         #--   (sens inverse ==  erreur assuree)
         for {set k $indexEnd} {$k >= 0} {incr k -1} {
            #--   supprime l'index dans le vecteur
            Vindex delete [lindex $listToDestroy $k]
         }
      }

      set result [list $Vindex(1) $Vindex(end)] ; # premier et dernier index de la serie sans trou

      blt::vector destroy Vindex

      return $result
   }

   #---------------------------------------------------------------------------
   #   ::foc::computeHFD : calcule le rayon du cercle contenant 50% du flux
   #   Parametres : limites d'exploration
   #   Return : rayon
   #---------------------------------------------------------------------------
   proc ::foc::computeHFD { vectorName lim1 lim2 } {

      set pi [expr { 4*atan(1) }]

      #--   transforme en indices
      set lim1 [expr { int($lim1) }]
      set lim2 [expr { int($lim2) }]

      set k [expr { int(($lim2-$lim1)/2) }]

      blt::vector create V1 temporaire -watchunset 1

      set sum 0
      for {set i $k} {$i >= 0} {incr i -1} {
         set first [expr { $lim1+$i }]                ; # index du premier element a sommer
         set second [expr { $lim2-$i }]               ; # index du second element
         if {$first != $second} {
            #--   calcule la somme des deux elements et le cumul
            set sum [expr { $sum+[$vectorName index $first]+[$vectorName index $second] }]
         }  else {
            #--   ne prend que l'element central (nb de mesures impair)
            set sum [expr { $sum+[$vectorName index $first] }]
         }
         V1 append $sum
      }

      #--   peuple l'axe des abscisses du graphique 2
      ::Vradius seq 0 [V1 length] 1

      #--   la surface d'un anneau vaut pi*(R2²-R1²)
      #--   pour des anneaux concentriques de rayon 1 2 3 4 ...
      #--   la différence R2²-R1² varie comme       1 3 5 7 ... (serie des nombres impairs, de pas 2)
      #     le pas de la surface vaut donc 2*pi
      set pas [expr { 2*$pi }]
      #--   calcule le poids de chaque anneau de 1 pixel
      temporaire seq $pi [expr { ($k+1)*$pas }] $pas

      #--   pondere chaque valeur par le coefficient surfacique
      V1 expr { V1*temporaire  }

      ::Vhfd expr { V1/$V1(max) }                     ; # transfert vers le vecteur graphique
      temporaire expr {::Vhfd < 0.5}                  ; #--  element == 1 si valeur < 0.5, sinon 0
      set start [lindex [temporaire search 1.0] end]  ; #--  extrait l'index du dernier element < 0.5
      set startValue [::Vhfd index $start]            ; #--  sa valeur
      set end [expr { $start+1 }]                     ; #--  index de la premiere valeur > 0.5
      set endValue [::Vhfd index $end]                ; #--  sa valeur

      #--   interpolation lineaire pour 0.5
      set rayon [expr { $start+(0.5-$startValue)/($endValue-$startValue) }]

      blt::vector destroy V1 temporaire

      return $rayon
   }

   #---------------------------------------------------------------------------
   #   ::foc::updateValues : Met a jour les graphiques
   #   Parametres : chemin de la fenetre, limites et rayon
   #---------------------------------------------------------------------------
   proc ::foc::updateValues { this limite1 limite2 rayon} {
      variable private

      #--   met a jour la ligne au-dessus des graphiques
      set diametre [format "%.2f" [expr { 2*$rayon }]]
      set private(hfd) "HFD=$diametre"

      $this.h.fr1.graph marker configure limite1 -coords [list $limite1 -Inf $limite1 Inf]
      $this.h.fr1.graph marker configure limite2 -coords [list $limite2 -Inf $limite2 Inf]

      #--   deplace la ligne verticale du diametre
      $this.h.fr2.graph marker configure rayon -coords [list $rayon -Inf $rayon Inf]

      #--   encore de la simulation pour distinguer les mesures
      set pos [::VSpos index [expr { $private(count)-1 }] ]
      set pos [expr { $pos+1000 }]
      set count $private(count)

      set ::VSpos($count) $pos ; # $::audace(focus,currentFocus)
      ::VShfd append $diametre

      if {[::VShfd length] > 1} {
         lassign [::foc::computeSlope] constante slope
         if {[string index $slope 0] eq "-"} {
            set texte "HFD=${constante}${slope}*step"
         } else {
            set texte "HFD=${constante}+${slope}*step"
         }
         #$this.l.fr3.graph marker create text -name slope -text $texte \
         #   -coords [list -Inf Inf] -justify center -anchor e

         ::console::affiche_resultat "$texte\n"
      }
   }

   #---------------------------------------------------------------------------
   #   ::foc::createHFDGraphe : cree la fenetre
   #   Parametres : N° visu et nom du frame
   #---------------------------------------------------------------------------
   proc ::foc::createHFDGraphe { visuNo this } {
      variable private

      if { [ winfo exists $this ] } {
         destroy $this
      }

      #--- Creation de la fenetre
      toplevel $this
      wm title $this "$::caption(foc,focalisationHFD)"
      wm resizable $this 1 1
      wm geometry $this $::conf(visufoc,position)
      wm protocol $this WM_DELETE_WINDOW "::foc::closeHFDGraphe"

      label $this.hfd -textvariable ::foc::private(hfd)
      pack $this.hfd -side top -fill x

      frame $this.h
      pack $this.h -side top -fill x

      frame $this.h.fr1 -width 100 -height 100

         set grph1 [createSimpleGraphe $this.h.fr1 100 100]
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

         set grph2 [createSimpleGraphe $this.h.fr2 100 100]
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
      pack $this.l -side bottom -fill x

      frame $this.l.fr3 -width 200 -height 200

         set grph3 [createSimpleGraphe $this.l.fr3 200 200]
         #--   configure le graphique
         $grph3 element create color_invariant_lineR -xdata ::VSpos -ydata ::VShfd \
            -linewidth 1 -color blue -symbol "scross" -hide no
         $grph3 axis configure x -title "$::caption(foc,pos_focus)" \
            -stepsize 2500 -min 0 -max 10000 -hide no
         $grph3 axis configure y -title "$::caption(foc,hfd)" -stepsize 1 -min 0 -max {} \
            -hide no

      pack $this.l.fr3 -side bottom -anchor e

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #---------------------------------------------------------------------------
   #   ::foc::createSimpleGraphe : Cree une zone graphique
   #   Parametre : nom du frame renfemant le graphique
   #   Return : nom complet du graphe
   #---------------------------------------------------------------------------
   proc ::foc::createSimpleGraphe { frm width height } {

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

   #---------------------------------------------------------------------------
   #  ::foc::closeHFDGraphe : ferme le graphique
   #---------------------------------------------------------------------------
   proc ::foc::closeHFDGraphe { } {

      set visuNo $::audace(visuNo)
      set this $::audace(base).hfd

      #--   detruit les vecteurs crees avec la  fenetre
      if {"::Vradius" in [blt::vector names]} {
         blt::vector destroy ::Vx ::Vintx ::Vradius ::Vhfd ::VSpos ::VShfd
      }

      #--   supprime la maj automatique
      if { [trace info variable ::confVisu::addFileNameListener] ne ""} {
         ::confVisu::removeFileNameListener $visuNo "::foc::updateHFDGraphe $visuNo $this"
      }

      regsub {([0-9]+x[0-9]+)} [wm geometry $this] "" ::conf(visufoc,position)

      destroy $this
   }

   #---------------------------------------------------------------------------
   #   ::foc::initFocHFD : initialise la fonction
   #   Parametre : aucun
   #---------------------------------------------------------------------------
   proc ::foc::initFocHFD { } {
      variable private

      set visuNo $::audace(visuNo)
      set this $::audace(base).hfd

      #--   cree les vecteurs du graphique s'ils n'existent pas deja
      if {"::Vradius" ni [blt::vector names]} {
         #--   cree les vecteurs du graphique s'ils n'existent pas deja
         blt::vector create ::Vx ::Vintx ::Vradius ::Vhfd ::VSpos ::VShfd -watchunset 1
      }

      #--   initialise le vecteur de la position
      ::VSpos seq 0 10000 1000

      set private(count) 0 ; # compteur de mesures

      #--   declare le rafraichissement automatique du graphique en fonction de l'image
      if { [trace info variable ::confVisu::addFileNameListener] eq ""} {
         ::confVisu::addFileNameListener $visuNo "::foc::updateHFDGraphe $visuNo $this"
      }

      #--   cree le graphique
      ::foc::createHFDGraphe $visuNo $this
   }

