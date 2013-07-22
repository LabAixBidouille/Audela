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
   #    reserve à la simulation
   # Parametre : typefocuser { 0 | 1 } et mode { 0 | 1 }
   # typefocuser : 0 --> graphique normal, 1 --> graphique hfd
   # mode        : 0 --> fenetre manuelle, 1 --> fenetre automatique
   #---------------------------------------------------------------------------
   proc traceCurve { {typefocuser 1} {mode 1} } {
      global audace conf caption panneau

      set visuNo $audace(visuNo)
      set bufNo $audace(bufNo)
      set rep $audace(rep_images)
      set ext $conf(extension,defaut)
      set rac [file join $audace(rep_images) t]
      set panneau(foc,compteur) "0"
      set panneau(foc,typefocuser) $typefocuser

      #--   mode de fenetrage
      if {$mode ==1} {
         set panneau(foc,menu) "$caption(foc,fenetre_auto)"
      } else {
         set panneau(foc,menu) "$caption(foc,fenetre_man)"
      }

      switch -exact $panneau(foc,typefocuser) {
         0  {  #--   finalise la ligne de titre
               append panneau(foc,fichier) "\n"
               set this $audace(base).visufoc
               if {[winfo exists $this]} { fermeGraphe }
               ::foc::focGraphe
            }
         1  {  #--   finalise la ligne de titre
               append panneau(foc,fichier) "$caption(foc,hfd)\t${caption(foc,pos_focus)}\n"
               set this $audace(base).hfd
               if {[winfo exists $this]} { closeHFDGraphe }
               ::foc::HFDGraphe
               set step 3000
               set audace(focus,currentFocus) "-3000"
            }
      }

      #--   simule le chargement de la premiere image
      loadima "${rac}1$ext"
      update

      #--   dimension de l'image initiale
      set naxis1 [buf$bufNo getpixelswidth]
      set naxis2 [buf$bufNo getpixelsheight]

      if {$panneau(foc,menu) eq "$caption(foc,fenetre_auto)"} {

         lassign [searchBrightestStar] x y

         #--   calcule auto des cordonnees de la fenetre
         set x1 [expr { int(round($x)-25) }]
         set x2 [expr { int(round($x)+25) }]
         set y1 [expr { int(round($y)-25) }]
         set y2 [expr { int(round($y)+25) }]

         #--   coordonnees relatives a l'image initiale
         set panneau(foc,window) [list $x1 $y1 $x2 $y2]

         #--   attend 2 sec
         after 2000
         #--   dessine la boite
         ::confVisu::setBox $visuNo $panneau(foc,window)
         update
         #--   attend 1 sec
         after 1000

      } elseif {$panneau(foc,menu) eq "$caption(foc,fenetre_man)"} {

         vwait ::confVisu::private($visuNo,boxSize)
         set panneau(foc,window) [ ::confVisu::getBox $visuNo ]
      }

      #--   identifie le photocentre dans la box
      lassign [buf$bufNo centro $panneau(foc,window)] xc yc

      #--   supprime la boite
      ::confVisu::deleteBox $visuNo
      update

      #--   Calcule la boite contenant toute la fenetre
      lassign $panneau(foc,window) x1 y1 x2 y2
      set panneau(foc,box) [list 1 1 [expr { $x2-$x1+1 }] [expr { $y2-$y1+1 }]]

      if {$panneau(foc,typefocuser) == 1} {
         #--   Dessin du schema etoile/image
         ::foc::updateLocator $naxis1 $naxis2 $xc $yc
      }

      for {set i 1} {$i <=9} {incr i } {

         set panneau(foc,compteur) $i

         loadima "${rac}${i}$ext"

         if {$panneau(foc,typefocuser) ==1} {
            incr audace(focus,currentFocus) $step
         }

         buf$bufNo window $panneau(foc,window)

         #--   normalise le fond du ciel a 0
         buf$bufNo noffset 0

         ::confVisu::autovisu $visuNo

         set t0 [clock milliseconds]

         if {$panneau(foc,typefocuser) == "1"} {
            ::foc::extractBiny $bufNo
         }

         #--- Statistiques
         set s [ stat ]
         set maxi [ lindex $s 2 ]
         set fond [ lindex $s 7 ]
         set contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
         set inten [ format "%.0f" [ expr $maxi-$fond ] ]

         #--- Fwhm
         lassign [ buf$bufNo fwhm $panneau(foc,box) ] fwhmx fwhmy

         #--- Valeurs a l'ecran
         ::foc::qualiteFoc $inten $fwhmx $fwhmy $contr
         update

         if {$panneau(foc,typefocuser) ==0} {
            #--   Mise a jour des graphiques
            ::foc::updateFocGraphe [list $panneau(foc,compteur) $inten $fwhmx $fwhmy $contr]
            #--- Actualise les donnees pour le fichier log
            append panneau(foc,fichier) "$inten\t$fwhmx\t$fwhmy\t$contr\n"
         } else {
            ::foc::processHFD
            update idletasks
            #--- Actualise les donnees pour le fichier log
            append panneau(foc,fichier) "$inten\t$fwhmx\t$fwhmy\t$contr\t$panneau(foc,hfd)\t$audace(focus,currentFocus)\n"

         }
         set t1 [clock milliseconds]
         ::console::affiche_resultat "durée du traitement de l'image [expr { $t1-$t0 }] ms\n"
         #-- simule la pose puis le chargement
         after 2000
      }

      #--- Sauvegarde du fichier des traces
      ::foc::cmdSauveLog foc.log
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
      set positionOpt "0.00"

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
            lassign [getParam $side $yright(:) $xright(:)] constanteRight slopeRight step0Right
          }

         #--   raccourci le vecteur gauche
         yleft length [expr { $rankMin-1 }]
         xleft length [expr { $rankMin-1 }]
      }

      #--   traite le vecteur gauche
      if {[yleft length] == [xleft length] && [yleft length] >= 2} {
         set side left
         lassign [getParam $side $yleft(:) $xleft(:)] constanteLeft slopeLeft step0Left
      }

      #--   calcule de l'intersection
      if {$slopeLeft != 0 && $slopeRight != 0} {
         set xIntersect [expr { ($constanteLeft-$constanteRight)/($slopeRight-$slopeLeft) }]
         set positionOpt [format "%0.2f" $xIntersect]
      }

      set slopeLeft [format "%0.6f" $slopeLeft]
      set slopeRight [format "%0.6f" $slopeRight]

      blt::vector destroy yleft yright xleft xright

      return [list $slopeLeft $slopeRight $positionOpt]
   }

   #---------------------------------------------------------------------------
   # getParam
   #    calcule la variation de HFD en fonction de la position
   #    par ajustement lineaire
   #---------------------------------------------------------------------------
   proc getParam { side mHfd mPos } {

      blt::vector create xLine yLine w -watchunset 1
      yLine set $mHfd
      xLine set $mPos
      set n [yLine length]

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

      blt::vector destroy xLine yLine w

     return [list $constante $slope $step0]
   }

   #---------------------------------------------------------------------------
   # processHFD
   #    ordonnace la mise a jour des graphiques
   #---------------------------------------------------------------------------
   proc processHFD { args } {

      #--   etape 1 : extraction de la boite et de la coupe horizontale
      #--   peuple les vecteurs abscisses (::Vx) et ordonnees(::Vint) du graphe1
      ::foc::createCoupeHoriz

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
   # extractBiny
   #    binne l'image en Y et met les valeurs dans panneau(foc,biny)
   #  Parametre : N° du buffer contenant l'image normale
   #---------------------------------------------------------------------------
   proc extractBiny { bufNo } {
      global panneau

      #--   recopie l'image vers le buffer dest
      lassign $panneau(foc,box) -> -> naxis1 naxis2

      #--   recopie l'image vers un nouveau buffer
      set dest [::buf::create]
      buf$bufNo copyto $dest

      #--   somme toutes les lignes
      buf$dest biny 1 $naxis2 1

      set panneau(foc,biny) [list ]
      for {set col 1} {$col <=$naxis1} {incr col} {
         lappend panneau(foc,biny) [lindex [buf$dest getpix [list $col 1]] 1]
      }

      ::buf::delete $dest
   }

   #---------------------------------------------------------------------------
   # createCoupeHoriz
   #    Extrait une image de la boite de selection
   #    binne l'image en Y
   #---------------------------------------------------------------------------
   proc createCoupeHoriz { } {
      global panneau

      #--   peuple le vecteur intensite du profil en X (variation entre {0|1})
      blt::vector create temporaire -watchunset 1
      temporaire offset 1                             ; #-- fait correspondre les indices et le N° de pixel
      temporaire append $panneau(foc,biny)
      temporaire expr { temporaire/$temporaire(max) } ; #-- maintenant max == 1.0
      ::Vintx set temporaire                          ; #-- transfert vers le vecteur graphique

      #--   peuple le vecteur ::Vx abscisse du graphe1
      ::Vx offset 1                                   ; #-- fait correspondre les indices et le N° de pixel
      ::Vx seq 1 [::Vintx length]                     ; #-- graduation entre 1 et naxis1

      blt::vector destroy temporaire
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

   #---------------------------------------------------------------------------
   # searchBrightestStar
   #    cherche l'etoile la plus brillante
   #  Retourne : coordonnes les coordonnees x y de l'etoile la plus brillante
   #---------------------------------------------------------------------------
   proc searchBrightestStar { } {
      global audace

      set bufNo $audace(bufNo)
      set naxis1 [buf$bufNo getpixelswidth]
      set naxis2 [buf$bufNo getpixelsheight]
      lassign [ ::prtr::searchMax [list 1 1 $naxis1 $naxis2] $bufNo] x y

      return [list $x $y]
   }

}

