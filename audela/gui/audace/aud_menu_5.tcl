#
# Fichier : aud_menu_5.tcl
# Description : Script regroupant les fonctionnalites du menu Analyse
# Mise a jour $Id: aud_menu_5.tcl,v 1.5 2009-02-07 11:23:26 robertdelmas Exp $
#

namespace eval ::audace {
}

   #
   # Histo visuNo
   # Visualisation de l'histogramme de l'image affichee dans la visu
   #
   proc ::audace::Histo { visuNo } {
      global caption

      #---
      set bufNo [ visu$visuNo buf ]

      if { [ buf$bufNo imageready ] == "1" } {
         buf$bufNo imaseries "CUTS lofrac=0.01 hifrac=0.99 hicut=SH locut=SB keytype=FLOAT"
         set mini [ lindex [ buf$bufNo getkwd SB ] 1 ]
         set maxi [ lindex [ buf$bufNo getkwd SH ] 1 ]
         set r [ buf$bufNo histo 50 $mini $maxi ]
         ::plotxy::figure 1
         ::plotxy::plot [ lindex $r 1 ]  [ lindex $r 0 ]
         ::plotxy::xlabel "$caption(audace,histo_adu)"
         ::plotxy::ylabel "$caption(audace,histo_nbpix)"
         ::plotxy::title "$caption(audace,histo_titre) (visu$visuNo)"
      }
   }

############################# Fin du namespace audace #############################

#
# statwin visuNo
# Fournit les statistiques d'une fenetre d'une image
#
proc statwin { visuNo } {
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]
   #---
   set This "$base.statwin"
   if [ winfo exists $This ] {
      ferme_fenetre_analyse $This statwin
   }
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(statwin,position) ] } { set conf(statwin,position) "+350+75" }
   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(audace,menu,statwin)"
   wm geometry $This $conf(statwin,position)
   wm protocol $This WM_DELETE_WINDOW "ferme_fenetre_analyse $This statwin"
   #--- Lecture des statistiques fenetre
   set valeurs [ buf[ ::confVisu::getBufNo $visuNo ] stat $box ]
   #--- Cree les etiquettes
   label $This.lab0 -text "Visu$visuNo"
   pack $This.lab0 -padx 10 -pady 2
   label $This.lab1 -text "$caption(audace,maxi) [ lindex $valeurs 2 ]"
   pack $This.lab1 -padx 10 -pady 2
   label $This.lab2 -text "$caption(audace,mini) [ lindex $valeurs 3 ]"
   pack $This.lab2 -padx 10 -pady 2
   label $This.lab3 -text "$caption(audace,moyenne) [ lindex $valeurs 4 ]"
   pack $This.lab3 -padx 10 -pady 2
   label $This.lab4 -text "$caption(audace,ecart_type) [ lindex $valeurs 5 ]"
   pack $This.lab4 -padx 10 -pady 2
   label $This.lab5 -text "$caption(audace,moyenne_fond_ciel) [ lindex $valeurs 6 ]"
   pack $This.lab5 -padx 10 -pady 2
   label $This.lab6 -text "$caption(audace,ecart_type_fond_ciel) [ lindex $valeurs 7 ]"
   pack $This.lab6 -padx 10 -pady 2
   #--- Cree le bouton pour recalculer les statistiques
   button $This.but_calculer -text "$caption(audace,calculer)" -width 7 -command "statwin $visuNo"
   pack $This.but_calculer -side bottom -padx 3 -pady 3 -ipady 5 -fill x
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# fwhm visuNo
# Fournit les fwhm en x et en y d'une fenetre d'une image
#
proc fwhm { visuNo } {
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]
   #---
   set This "$base.fwhm"
   if [ winfo exists $This ] {
      ferme_fenetre_analyse $This fwhm
   }
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(fwhm,position) ] } { set conf(fwhm,position) "+350+75" }
   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(audace,menu,fwhm)"
   wm geometry $This $conf(fwhm,position)
   wm protocol $This WM_DELETE_WINDOW "ferme_fenetre_analyse $This fwhm"
   #--- Lecture de fwhmx et fwhmy
   set valeurs [ buf[ ::confVisu::getBufNo $visuNo ] fwhm $box ]
   #--- Cree les etiquettes
   label $This.lab0 -text "Visu$visuNo"
   pack $This.lab0 -padx 10 -pady 2
   label $This.lab1 -text "$caption(audace,fwhm_x) : [ lindex $valeurs 0 ]"
   pack $This.lab1 -padx 10 -pady 2
   label $This.lab2 -text "$caption(audace,fwhm_y) : [ lindex $valeurs 1 ]"
   pack $This.lab2 -padx 10 -pady 2
   #--- Cree le bouton pour recalculer les fwhm
   button $This.but_calculer -text "$caption(audace,calculer)" -width 7 -command "fwhm $visuNo"
   pack $This.but_calculer -side bottom -padx 3 -pady 3 -ipady 5 -fill x
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# fitgauss visuNo
# Ajuste une gaussienne dans une fenetre d'une image
#
proc fitgauss { visuNo } {
   global caption color conf

   #---
   set base [ ::confVisu::getBase $visuNo ]
   #---
   set This "$base.fitgauss"
   if [ winfo exists $This ] {
      ferme_fenetre_analyse $This fitgauss
   }
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(fitgauss,position) ] } { set conf(fitgauss,position) "+350+75" }
   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(audace,menu,fitgauss)"
   wm geometry $This $conf(fitgauss,position)
   wm protocol $This WM_DELETE_WINDOW "ferme_fenetre_analyse $This fitgauss"
   #--- Lecture de la gaussienne d'ajustement
   set bufNo [ ::confVisu::getBufNo $visuNo ]
   set valeurs [ buf$bufNo fitgauss $box ]
   set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
   if {$naxis1=={}} { set naxis1 1 }
   set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]
   if {$naxis2=={}} { set naxis2 1 }
   set dif 0.
   set intx [lindex $valeurs 0]
   set xc [lindex $valeurs 1]
   set fwhmx [lindex $valeurs 2]
   set bgx [lindex $valeurs 3]
   set inty [lindex $valeurs 4]
   set yc [lindex $valeurs 5]
   set fwhmy [lindex $valeurs 6]
   set bgy [lindex $valeurs 7]
   if {$naxis1==1} {
      set if0 [ expr $inty*$fwhmy*.601*sqrt(3.14159265) ]
      set leq 0.
      if {$bgy!=0} {
         set leq [expr -$if0/$bgy]
      }
   } elseif {$naxis2==1} {
      set if0 [ expr $intx*$fwhmx*.601*sqrt(3.14159265) ]
      set leq 0.
      if {$bgx!=0} {
         set leq [expr -$if0/$bgx]
      }
   } else {
      set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
      set if1 [ expr $intx*$if0 ]
      set if2 [ expr $inty*$if0 ]
      set if0 [ expr ($if1+$if2)/2. ]
      set dif [ expr abs($if1-$if0) ]
   }
   #--- Cree les etiquettes
   label $This.lab0 -text "Visu$visuNo"
   pack $This.lab0 -padx 10 -pady 2
   ::console::affiche_resultat "=== Visu$visuNo $caption(audace,titre_gauss)\n"
   ::console::affiche_resultat "$caption(audace,coord_box) : $box\n"
   set texte "$caption(audace,center_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%.2f" $xc ] / [ format "%.2f" $yc ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%.2f" $xc ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%.2f" $yc ]"
   }
   ::console::affiche_resultat "$texte\n"
   label $This.lab1 -text "$texte"
   pack $This.lab1 -padx 10 -pady 2
   set texte "$caption(audace,fwhm_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%.3f" $fwhmx ] / [ format "%.3f" $fwhmy ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%.3f" $fwhmx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%.3f" $fwhmy ]"
   }
   ::console::affiche_resultat "$texte\n"
   label $This.lab2 -text "$texte"
   pack $This.lab2 -padx 10 -pady 2
   set texte "$caption(audace,intens_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%f" $intx ] / [ format "%f" $inty ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%f" $intx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%f" $inty ]"
   }
   ::console::affiche_resultat "$texte\n"
   label $This.lab3 -text "$texte"
   pack $This.lab3 -padx 10 -pady 2
   set texte "$caption(audace,back_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%f" $bgx ] / [ format "%f" $bgy ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%f" $bgx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%f" $bgy ]"
   }
   ::console::affiche_resultat "$texte\n"
   label $This.lab4 -text "$texte"
   pack $This.lab4 -padx 10 -pady 2
   set texte "$caption(audace,integflux) : $if0 "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "+/- $dif"
   }
   ::console::affiche_resultat "$texte\n"
   label $This.lab5 -text "$texte"
   pack $This.lab5 -padx 10 -pady 2
   #---
   if {($naxis1==1)||($naxis2==1)} {
      set texte "$caption(audace,largeurequiv) : [ format "%f" $leq ] pixels"
      ::console::affiche_resultat "$texte\n"
      label $This.lab6 -text "$texte"
      pack $This.lab6 -padx 10 -pady 2
   }
   #---
   if {[expr $if0+$dif]<=0} {
      set dif [expr $if0+1]
   }
   set mag1 [ expr -2.5*log10($if0+$dif) ]
   if {[expr $if0-$dif]<=0} {
      set dif [expr $if0-1]
   }
   set mag2 [ expr -2.5*log10($if0-$dif) ]
   set mag0 [ expr ($mag1+$mag2)/2. ]
   set dmag [ expr abs($mag1-$mag0) ]
   set texte "$caption(audace,mag_instrument) : [ format %6.3f $mag0 ] +/- [ format %6.3f $dmag ]"
   ::console::affiche_resultat "$texte\n"
   ::console::affiche_saut "\n"
   if { [ $base.fra1.labURLX cget -fg ] == "$color(blue)" } {
      set radec [ buf[ ::confVisu::getBufNo $visuNo ] xy2radec [ list [ lindex $valeurs 1 ] [ lindex $valeurs 5 ] ] ]
      set ra [ lindex $radec 0 ]
      set dec [ lindex $radec 1 ]
      set rah [ mc_angle2hms $ra 360 zero 2 auto string ]
      set decd [ mc_angle2dms $dec 90 zero 2 + string ]
      set texte "$caption(audace,RA) $caption(audace,DEC) : $ra $dec"
      ::console::affiche_resultat "$texte\n"
      set texte "$caption(audace,RA) $caption(audace,DEC) : $rah $decd"
      ::console::affiche_resultat "$texte\n"
      # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
      #    Rab101    C2003 10 18.89848 01 33 53.74 +02 27 19.3          18.6        xxx
      #--- C2003 10 18.89848 : Indique la date du milieu de la pose pour l'image
      #--- (annee, mois, jour decimal --> qui permet d'avoir l'heure du milieu de la pose a la seconde pres)
      set mpc "OLD $caption(audace,MPC_format)\n     .        C"
      set demiexposure [ expr ( [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]+0. )/86400./2. ]
      set d [mc_date2iso8601 [ mc_datescomp [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd DATE-OBS ] 1 ] + $demiexposure ] ]
      set annee [ string range $d 0 3 ]
      set mois  [ string range $d 5 6 ]
      set jour  [ string range $d 8 9 ]
      set h [ string range $d 11 12 ]
      set m [ string range $d 14 15 ]
      set s [ string range $d 17 22 ]
      set hh [ string trimleft $h 0 ] ; if { $hh == "" } { set hh "0" }
      set mm [ string trimleft $m 0 ] ; if { $mm == "" } { set mm "0" }
      set ss [ string trimleft $s 0 ] ; if { $ss == "" } { set ss "0" }
      set res [ expr ($hh+$mm/60.+$ss/3600.)/24. ]
      set res [ string range $res 1 6 ]
      append mpc "$annee $mois ${jour}${res} "
      set h [ string range $rah 0 1 ]
      set m [ string range $rah 3 4 ]
      set s [ string range $rah 6 10 ]
      set s [ string replace $s 2 2 . ]
      append mpc "$h $m $s "
      set d [ string range $decd 0 2 ]
      set m [ string range $decd 4 5 ]
      set s [ string range $decd 7 10 ]
      set s [ string replace $s 2 2 . ]
      append mpc "$d $m $s "
      append mpc "         "
      set cmagr [ expr ( [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd CMAGR ] 1 ]+0. ) ]
      if { $cmagr == "0" } { set cmagr "23" }
      set mag [ expr $cmagr+$mag0 ]
      append mpc "[ format %04.1f $mag ]"
      #---
      if { ! [ info exists conf(posobs,station_uai) ] } { set conf(posobs,station_uai) "" }
      if { $conf(posobs,station_uai) == "" } {
         set xxx "xxx"
      } else {
         set xxx $conf(posobs,station_uai)
      }
      #---
      append mpc "        $xxx"
      ::console::affiche_saut "\n"
      ::console::affiche_resultat "$mpc\n"
      ::console::affiche_saut "\n"
      #---
      if { $xxx != "xxx" } {
         ::console::affiche_erreur "$caption(audace,gauss_attention)\n"
         ::console::affiche_erreur "[eval [concat {format} { $caption(audace,UAI_site_image) $conf(posobs,station_uai) } ] ]\n"
         ::console::affiche_saut "\n"
      }
      #         1         2         3         4         5         6         7         8        9         10        11        12        13
      #123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 12
      #       J94R1234   1*C19940608.988773453 16 22 02.7812  -17 49 13.745   18.511R      1                                           0104
      #       J94R1234   2*C19940608.988773453 00.500 00.50            F.4000N             1.000                                       0104
      #       J94R1234   3*C19940608.988773453 2002.1234          +43.1234          148.0                                              0104
      #       .          1 C
      #set mpc "NEW $caption(audace,MPC_format)\n       .          1 C"
      # ---
      ::console::affiche_resultat "Use http://cfa-www.harvard.edu/iau/info/Astrometry.html for informations.\n"
      ::console::affiche_resultat "Use ::astrometry::mpc_provisional2packed to convert designation to MPC packed form.\n"
      ::console::affiche_saut "\n"
   }
   #--- Cree le bouton pour recalculer l'ajustement de la gaussienne
   button $This.but_calculer -text "$caption(audace,calculer)" -width 7 -command "fitgauss $visuNo"
   pack $This.but_calculer -side bottom -padx 3 -pady 3 -ipady 5 -fill x
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# center visuNo
# Fournit le photocentre d'une fenetre d'une image
#
proc center { visuNo } {
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]
   #---
   set This "$base.center"
   if [ winfo exists $This ] {
      ferme_fenetre_analyse $This center
   }
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(center,position) ] } { set conf(center,position) "+350+75" }
   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(audace,menu,centro)"
   wm geometry $This $conf(center,position)
   wm protocol $This WM_DELETE_WINDOW "ferme_fenetre_analyse $This centro"
   #--- Lecture de la fonction
   set valeurs [ buf[ ::confVisu::getBufNo $visuNo ] centro $box ]
   #--- Cree les etiquettes
   label $This.lab0 -text "Visu$visuNo"
   pack $This.lab0 -padx 10 -pady 2
   label $This.lab1 -text "$caption(audace,center_xy) : ( [ format "%.2f" [ lindex $valeurs 0 ] ] / [ format "%.2f" [ lindex $valeurs 1 ] ] )"
   pack $This.lab1 -padx 10 -pady 2
   #--- Cree le bouton pour recalculer le photocentre
   button $This.but_calculer -text "$caption(audace,calculer)" -width 7 -command "center $visuNo"
   pack $This.but_calculer -side bottom -padx 3 -pady 3 -ipady 5 -fill x
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# photom visuNo
# Fournit la photometrie integrale d'une fenetre d'une image
#
proc photom { visuNo } {
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]
   #---
   set This "$base.photom"
   if [ winfo exists $This ] {
      ferme_fenetre_analyse $This photom
   }
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(photom,position) ] } { set conf(photom,position) "+350+75" }
   #--- Creation de la fenetre
   toplevel $This
   wm transient $This $base
   wm resizable $This 0 0
   wm title $This "$caption(audace,menu,phot)"
   wm geometry $This $conf(photom,position)
   wm protocol $This WM_DELETE_WINDOW "ferme_fenetre_analyse $This photom"
   #--- Lecture de la fonction
   set valeurs [ buf[ ::confVisu::getBufNo $visuNo ] phot $box ]
   #--- Cree les etiquettes
   label $This.lab0 -text "Visu$visuNo"
   pack $This.lab0 -padx 10 -pady 2
   label $This.lab1 -text "$caption(audace,integflux) : [ lindex $valeurs 0 ]"
   pack $This.lab1 -padx 10 -pady 2
   #--- Cree le bouton pour recalculer la photometrie integrale
   button $This.but_calculer -text "$caption(audace,calculer)" -width 7 -command "photom $visuNo"
   pack $This.but_calculer -side bottom -padx 3 -pady 3 -ipady 5 -fill x
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# subfitgauss visuNo
# Ajuste et soustrait une gaussinne dans une fenetre d'une image
#
proc subfitgauss { visuNo } {
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #---
   set valeurs [ buf[ ::confVisu::getBufNo $visuNo ] fitgauss $box -sub ]
   ::confVisu::autovisu $visuNo
}

#
# scar visuNo
# Cicatrise l'interieur d'une fenetre d'une image
#
proc scar { visuNo } {
   #---
   set box [ ::confVisu::getBox $visuNo ]
   if { $box == "" } {
      return
   }
   #---
   set valeurs [ buf[::confVisu::getBufNo $visuNo] scar $box ]
   ::confVisu::autovisu $visuNo
}

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

#
# ferme_fenetre_analyse This nom_conf
# Recupere les coordonnees des boites de dialogue ci-dessus
#
proc ferme_fenetre_analyse { This nom_conf } {
   global conf

   #--- Determination de la position de la fenetre
   set geometry [ wm geometry $This ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set conf($nom_conf,position) "+[ string range $geometry $deb $fin ]"
   #--- Fermeture de la fenetre
   destroy $This
}

