#
# Fichier : foc_HFD.tcl
# Description : Script de mise en oeuvre du HFD
# Compatibilité : USB_Focus et AudeCom
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id$
#

namespace eval ::foc {

   #---------------------------------------------------------------------------
   # traceCurve
   #    processus de mesure pour differentes positions
   #---------------------------------------------------------------------------
   proc traceCurve { } {
      global audace panneau

#---  RZ : simulation

      set this $audace(base).hfd
      if {[winfo exists $this]} { closeHFDGraphe }
      ::foc::HFDGraphe

      #set this $audace(base).visufoc
      #if {[winfo exists $this]} { closeHFDGraphe }
      #::foc::focGraphe


      set visuNo $audace(visuNo)
      set ext .fit
      set rac [file join $audace(rep_images) t]
      set panneau(foc,compteur) "0"
      set panneau(foc,typefocuser) "1"
      set step 3000
      set audace(focus,currentFocus) "-3000"
      set panneau(foc,fichier) ""
      set buffer buf[visu$visuNo buf]

      for {set i 1} {$i<=9} {incr i} {

        loadima "$rac$i.fit"
        incr panneau(foc,compteur)
        incr audace(focus,currentFocus) $step
        vwait ::confVisu::private($visuNo,boxSize)

        #--- Statistiques
        set s [ stat ]
        set maxi [ lindex $s 2 ]
        set fond [ lindex $s 7 ]
        set contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
        set inten [ format "%.0f" [ expr $maxi-$fond ] ]
        #--- Fwhm
        set naxis1 [ expr [ lindex [ $buffer getkwd NAXIS1 ] 1 ]-0 ]
        set naxis2 [ expr [ lindex [ $buffer getkwd NAXIS2 ] 1 ]-0 ]
        set box [ list 1 1 $naxis1 $naxis2 ]
        lassign [ $buffer fwhm $box ] fwhmx fwhmy

        #--- Valeurs a l'ecran
        ::foc::qualiteFoc $inten $fwhmx $fwhmy $contr
        update

        #--- Actualise les donnees pour le fichier log
        append panneau(foc,fichier) "$inten $fwhmx $fwhmy $contr \n"

        ::foc::processHFD
        update idletasks

        #--- Suppression de la zone selectionnee avec la souris
        ::confVisu::deleteBox $audace(visuNo)
      }

      #--- Sauvegarde du fichier des traces
      ::foc::cmdSauveLog foc.log

#---  RZ : fin simulation
   }

   #---------------------------------------------------------------------------
   # computeSlope
   #    decoupe les vecteurs resultats en gauche et droite
   #    si le minimum est depasse
   #---------------------------------------------------------------------------
   proc computeSlope { } {

      set slopeLeft  "0.000000"
      set step0Left  "0.00"
      set slopeRight "0.000000"
      set step0Right "0.00"

      blt::vector create yleft yright xleft xright -watchunset 1
      yleft set ::VShfd          ; #-- copie le vecteur
      xleft set ::VSpos          ; #-- copie le vecteur
      set n [yleft length]       ; #-- nb total de mesures

      #--   liste les index (s'il y en a plusieurs) de la valeur minimale
      set listIndexMin [yleft search $yleft(min)]

      #--   rang du minimum (neglige les index plus eleves)
      set rankMin [lindex $listIndexMin 0]

      if {$rankMin != [expr { [yleft length]-1 }]} {

         #--   isole les mesures > minimum = vecteur des valeurs a droite
         yright set [yleft range [expr { $rankMin+1 }] end]
         xright set [xleft range [expr { $rankMin+1 }] end]

         #--   ignore le premier depassement (si moins de 2 valeurs)
         if {[yright length] == [xright length] && [yright length] >= 2} {
            set side right
            lassign [getParam $side $yright(:) $xright(:)] slopeRight step0Right
            set slopeRight [format "%0.6f" $slopeRight]
            set step0Right [format "%0.2f" $step0Right]
         }

         #--   raccourci le vecteur gauche
         yleft length [expr { $rankMin-1 }]
         xleft length [expr { $rankMin-1 }]

      }

      #--   traite le vecteur gauche
      if {[yleft length] == [xleft length] && [yleft length] >= 2} {
         set side left
         lassign [getParam $side $yleft(:) $xleft(:)] slopeLeft step0Left
         set slopeLeft [format "%0.6f" $slopeLeft]
         set step0Left [format "%0.2f" $step0Left]
      }

      #--   calcule de l'intersection
      #set diviseur [expr { -$slopeLeft+$slopeRight }]
      #if {$diviseur != 0} {
      #   set intersect [expr { ($constLeft-$constRight)/$diviseur }]
      #  ::console::affiche_resultat "$diviseur $intersect\n"
      #}

      blt::vector destroy yleft yright xleft xright

      return [list $slopeLeft $slopeRight $step0Left $step0Right]
   }

   #---------------------------------------------------------------------------
   # getParam
   #    calcule la variation de HFD en fonction de la position
   #    par ajustement lineaire
   #---------------------------------------------------------------------------
   proc getParam { side mHfd mPos } {
      global caption

      #set caption(foc,trend) "\nside %s : HFD = %s %s %s $caption(foc,pas) \nHF=0 pour %s $caption(foc,pas)"
      #::console::affiche_resultat "\nvecteur $side $mHfd\n$mPos\n"

      blt::vector create xLine yLine w -watchunset 1
      yLine set $mHfd
      xLine set $mPos
      set n [yLine length]

      #::console::affiche_resultat "$yLine(:)\n"
      #::console::affiche_resultat "$xLine(:)\n"
      #::console::affiche_resultat "n $n\n"

      #--   calcule les parametres de HFD= A + pente * pas de focuser
      w length $n             ; #--matrice de longueur n remplie de 0
      w expr { w == 0 }       ; #--matrice unitaire

      set X ""
      for { set i 0 } { $i <  $n } { incr i } {
         lappend X [list 1 [xLine index $i]]
      }

      #--   resoud le systeme y=a+b*x
      lassign [lindex [ gsl_mfitmultilin $yLine(:) $X $w(:) ] 0] constante slope

      #--   calcule l'intersection avec l'axe des abscisses (les pas)
      if {$slope != 0} {
         set step0 [expr { -1.*$constante/$slope }]
      } else {
         set step0 "ind"
      }

      #::console::affiche_resultat "\ngetParam $side $constante $slope -> step0 = $step0\n"

      blt::vector destroy xLine yLine w

      return [list $slope $step0]
   }

   #---------------------------------------------------------------------------
   # processHFD
   #    met a jour les graphiques
   # Parametres : N° de la visu contenant l'image source et le nom du frame global
   # Duree : entre 40 et 100 ms
   #---------------------------------------------------------------------------
   proc processHFD { args } {
      global audace panneau

      set visuNo $audace(visuNo)
      set this $audace(base).hfd
      set box [::confVisu::getBox $visuNo]

      #--   arrete si la box est vide
      if { $box eq ""} { return }

      #--   etape 1 : extraction de la boite et de la coupe horizontale
      #--   peuple les vecteurs abscisses (::Vx) et ordonnees(::Vint) du graphe1
      ::foc::createCoupeHoriz $box

      #--   extraction des limites d'analyse
      #--   1/e² = 0.135 du pic (1/e-Squared Halfwidth)
      lassign [getLimits ::Vintx 0.135] start end

      if {$start != 1 && $end != [::Vx length]} {

         #--   si les limites sont dans la boite
         #--   etape 2 : extraction du flux cumule en fonction du rayon
         #--   peuple les vecteurs abscisses (::Vradius) et ordonnees(::Vhfd) du graphe2
         set rayon [computeHFD ::Vintx $start $end]

         #--   etape 3 : met a jour les titres et les graphiques
         ::foc::updateHFDGraphe $start $end $rayon

      } else {
         ::console::affiche_resultat "mesure invalide\n"
      }
   }

   #---------------------------------------------------------------------------
   # createCoupeHoriz
   #    Extrait une image de la boite de selection
   #    binne l'image en Y
   # Parametres : boite de selection
   #---------------------------------------------------------------------------
   proc createCoupeHoriz { box } {
      global audace conf

      #--   recopie l'image vers le buffer dest
      set dest [::buf::create]
      set rep $audace(rep_images)
      set ext $conf(extension,defaut)
      set visuNo $audace(visuNo)

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
   # getLimits
   #    cherche les limites dans un vecteur de flux
   # Parametres : nom du vecteur a traiter et limite d'ecretage (en fraction du max)
   # Return : les limites robustes
   #---------------------------------------------------------------------------
   proc getLimits { vectorName limit } {

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

      set result [list $Vindex(1) $Vindex(end)]             ; # premier et dernier index de la serie sans trou

      blt::vector destroy Vindex

      return $result
   }

   #---------------------------------------------------------------------------
   # computeHFD
   #    calcule le rayon du cercle contenant 50% du flux
   # Parametres : limites d'exploration
   # Return : rayon
   #---------------------------------------------------------------------------
   proc computeHFD { vectorName lim1 lim2 } {

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

}

