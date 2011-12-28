#
# Fichier : aud_menu_5.tcl
# Description : Script regroupant les fonctionnalites du menu Analyse
# Mise à jour $Id$
#

namespace eval ::audace {
}

#
# Histo visuNo
# Visualisation de l'histogramme de l'image affichee dans la visu
#
proc ::audace::Histo { visuNo } {
   global caption

   set bufNo [ visu$visuNo buf ]
   if { [ buf$bufNo imageready ] == "1" } {
      buf$bufNo imaseries "CUTS lofrac=0.01 hifrac=0.99 hicut=SH locut=SB keytype=FLOAT"
      set mini [ lindex [ buf$bufNo getkwd SB ] 1 ]
      set maxi [ lindex [ buf$bufNo getkwd SH ] 1 ]
      set r    [ buf$bufNo histo 50 $mini $maxi ]
      set figureNo [ ::plotxy::figure $visuNo ]
      ::plotxy::clf $figureNo
      ::plotxy::title  "$caption(audace,histo_titre) (visu$visuNo)"
      ::plotxy::xlabel "$caption(audace,histo_adu)"
      ::plotxy::ylabel "$caption(audace,histo_nbpix)"
      ::plotxy::plot   [ lindex $r 1 ] [ lindex $r 0 ]
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor .audace.plotxy1
   }
}

############################# Fin du namespace audace #############################

#
# statwin visuNo
# Fournit les statistiques d'une fenetre d'une image
#
proc statwin { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(statwin,$visuNo,frm) "$base.statwin$visuNo"
   set frm $private(statwin,$visuNo,frm)
   if [ winfo exists $frm ] {
      ferme_fenetre_analyse $visuNo $frm statwin
   }

   #--- Initialisation de variables
   if { ! [ info exists conf(statwin,$visuNo,position) ] }    { set conf(statwin,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(statwin,$visuNo,modeRefresh) ] } { set conf(statwin,$visuNo,modeRefresh) "0" }

   #--- Capture de la fenetre d'analyse
   set private(statwin,box) [ ::confVisu::getBox $visuNo ]
   if { $private(statwin,box) == "" } {
      return
   }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,statwin)"
   wm geometry $frm $conf(statwin,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "ferme_fenetre_analyse $visuNo $frm statwin"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2
      label $frm.frame1.lab2 -text ""
      pack $frm.frame1.lab2 -padx 10 -pady 2
      label $frm.frame1.lab3 -text ""
      pack $frm.frame1.lab3 -padx 10 -pady 2
      label $frm.frame1.lab4 -text ""
      pack $frm.frame1.lab4 -padx 10 -pady 2
      label $frm.frame1.lab5 -text ""
      pack $frm.frame1.lab5 -padx 10 -pady 2
      label $frm.frame1.lab6 -text ""
      pack $frm.frame1.lab6 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(statwin,$visuNo,modeRefresh) -command "::confStatwin $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir les statistiques
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::refreshStatwin $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::refreshStatwin $visuNo

   #--- Rafraichit la fenetre
   ::confStatwin $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# refreshStatwin
# Rafraichit les valeurs de la fenetre
#
proc refreshStatwin { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(statwin,box) [ ::confVisu::getBox $visuNo ]
   if { $private(statwin,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set private(statwin,valeurs) [ buf[ ::confVisu::getBufNo $visuNo ] stat $private(statwin,box) ]

   #--- Mise a jour des variables
   set private(statwin,maxi)                 "$caption(audace,maxi) [ lindex $private(statwin,valeurs) 2 ]"
   set private(statwin,mini)                 "$caption(audace,mini) [ lindex $private(statwin,valeurs) 3 ]"
   set private(statwin,moyenne)              "$caption(audace,moyenne) [ lindex $private(statwin,valeurs) 4 ]"
   set private(statwin,ecart_type)           "$caption(audace,ecart_type) [ lindex $private(statwin,valeurs) 5 ]"
   set private(statwin,moyenne_fond_ciel)    "$caption(audace,moyenne_fond_ciel) [ lindex $private(statwin,valeurs) 6 ]"
   set private(statwin,ecart_type_fond_ciel) "$caption(audace,ecart_type_fond_ciel) [ lindex $private(statwin,valeurs) 7 ]"

   #--- Mise a jour des labels
   $private(statwin,$visuNo,frm).frame1.lab1 configure -text "$private(statwin,maxi)"
   $private(statwin,$visuNo,frm).frame1.lab2 configure -text "$private(statwin,mini)"
   $private(statwin,$visuNo,frm).frame1.lab3 configure -text "$private(statwin,moyenne)"
   $private(statwin,$visuNo,frm).frame1.lab4 configure -text "$private(statwin,ecart_type)"
   $private(statwin,$visuNo,frm).frame1.lab5 configure -text "$private(statwin,moyenne_fond_ciel)"
   $private(statwin,$visuNo,frm).frame1.lab6 configure -text "$private(statwin,ecart_type_fond_ciel)"
}

#
# confStatwin
# Rafraichit la fenetre
#
proc confStatwin { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(statwin,$visuNo,modeRefresh) == "0" } {
      $private(statwin,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::refreshStatwin $visuNo"
   } else {
      $private(statwin,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::refreshStatwin $visuNo"
   }
}

###################################################################################

#
# fwhm visuNo
# Fournit les fwhm en x et en y d'une fenetre d'une image
#
proc fwhm { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(fwhm,$visuNo,frm) "$base.fwhm$visuNo"
   set frm $private(fwhm,$visuNo,frm)
   if [ winfo exists $frm ] {
      ferme_fenetre_analyse $visuNo $frm fwhm
   }

   #--- Capture de la fenetre d'analyse
   set private(fwhm,box) [ ::confVisu::getBox $visuNo ]
   if { $private(fwhm,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(fwhm,$visuNo,position) ] }    { set conf(fwhm,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(fwhm,$visuNo,modeRefresh) ] } { set conf(fwhm,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,fwhm)"
   wm geometry $frm $conf(fwhm,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "ferme_fenetre_analyse $visuNo $frm fwhm"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2
      label $frm.frame1.lab2 -text ""
      pack $frm.frame1.lab2 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(fwhm,$visuNo,modeRefresh) -command "::confFwhm $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir les fwhm
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::refreshFwhm $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::refreshFwhm $visuNo

   #--- Rafraichit la fenetre
   ::confFwhm $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# refreshFwhm
# Rafraichit les valeurs de la fenetre
#
proc refreshFwhm { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(fwhm,box) [ ::confVisu::getBox $visuNo ]
   if { $private(fwhm,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set private(fwhm,valeurs) [ buf[ ::confVisu::getBufNo $visuNo ] fwhm $private(fwhm,box) ]

   #--- Mise a jour des variables
   set private(fwhm,x) "$caption(audace,fwhm_x) [ lindex $private(fwhm,valeurs) 0 ]"
   set private(fwhm,y) "$caption(audace,fwhm_y) [ lindex $private(fwhm,valeurs) 1 ]"

   #--- Mise a jour des labels
   $private(fwhm,$visuNo,frm).frame1.lab1 configure -text "$private(fwhm,x)"
   $private(fwhm,$visuNo,frm).frame1.lab2 configure -text "$private(fwhm,y)"
}

#
# confFwhm
# Rafraichit la fenetre
#
proc confFwhm { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(fwhm,$visuNo,modeRefresh) == "0" } {
      $private(fwhm,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::refreshFwhm $visuNo"
   } else {
      $private(fwhm,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::refreshFwhm $visuNo"
   }
}

###################################################################################

#
# fitgauss visuNo
# Ajuste une gaussienne dans une fenetre d'une image
#
proc fitgauss { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(fitgauss,$visuNo,frm) "$base.fitgauss$visuNo"
   set frm $private(fitgauss,$visuNo,frm)
   if [ winfo exists $frm ] {
      ferme_fenetre_analyse $visuNo $frm fitgauss
   }

   #--- Capture de la fenetre d'analyse
   set private(fitgauss,box) [ ::confVisu::getBox $visuNo ]
   if { $private(fitgauss,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(fitgauss,$visuNo,position) ] }    { set conf(fitgauss,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(fitgauss,$visuNo,modeRefresh) ] } { set conf(fitgauss,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,fitgauss)"
   wm geometry $frm $conf(fitgauss,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "ferme_fenetre_analyse $visuNo $frm fitgauss"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2

      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2

      label $frm.frame1.lab2 -text ""
      pack $frm.frame1.lab2 -padx 10 -pady 2

      label $frm.frame1.lab3 -text ""
      pack $frm.frame1.lab3 -padx 10 -pady 2

      label $frm.frame1.lab4 -text ""
      pack $frm.frame1.lab4 -padx 10 -pady 2

      label $frm.frame1.lab5 -text ""
      pack $frm.frame1.lab5 -padx 10 -pady 2

      label $frm.frame1.lab6 -text ""
      pack $frm.frame1.lab6 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(fitgauss,$visuNo,modeRefresh) -command "::confFitgauss $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir l'ajustement de la gaussienne
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::refreshFitgauss $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::refreshFitgauss $visuNo

   #--- Rafraichit la fenetre
   ::confFitgauss $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# refreshFitgauss
# Rafraichit les valeurs de la fenetre
#
proc refreshFitgauss { visuNo args } {
   variable private
   global audace caption color conf

   #--- Capture de la fenetre d'analyse
   set private(fitgauss,results) ""
   set private(fitgauss,box)     [ ::confVisu::getBox $visuNo ]
   if { $private(fitgauss,box) == "" } {
      return
   }

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #--- Lecture de la gaussienne d'ajustement
   set bufNo [ ::confVisu::getBufNo $visuNo ]
   set valeurs [ buf$bufNo fitgauss $private(fitgauss,box) ]
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
   set fitgauss_result ""
   lappend fitgauss_result [list xc $xc]
   lappend fitgauss_result [list yc $yc]
   lappend fitgauss_result [list fwhmx $fwhmx]
   lappend fitgauss_result [list fwhmy $fwhmy]
   lappend fitgauss_result [list intx $intx]
   lappend fitgauss_result [list inty $inty]
   lappend fitgauss_result [list flux $if0]
   lappend fitgauss_result [list dflux $dif]
   set private(fitgauss,results) $fitgauss_result
   set audace(fitgauss,results)  $fitgauss_result

   #--- Cree les etiquettes
   ::console::affiche_resultat "=== Visu$visuNo $caption(audace,titre_gauss)\n"
   ::console::affiche_resultat "$caption(audace,coord_box) : $private(fitgauss,box)\n"
   set texte "$caption(audace,center_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%.2f" $xc ] / [ format "%.2f" $yc ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%.2f" $xc ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%.2f" $yc ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab1 configure -text "$texte"
   set texte "$caption(audace,fwhm_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%.3f" $fwhmx ] / [ format "%.3f" $fwhmy ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%.3f" $fwhmx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%.3f" $fwhmy ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab2 configure -text "$texte"
   set texte "$caption(audace,intens_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%f" $intx ] / [ format "%f" $inty ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%f" $intx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%f" $inty ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab3 configure -text "$texte"
   set texte "$caption(audace,back_xy) : "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "[ format "%f" $bgx ] / [ format "%f" $bgy ]"
   } elseif {($naxis1>1)&&($naxis2==1)} {
      append texte "[ format "%f" $bgx ]"
   } elseif {($naxis1==1)&&($naxis2>1)} {
      append texte "[ format "%f" $bgy ]"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab4 configure -text "$texte"
   set texte "$caption(audace,integflux) : $if0 "
   if {($naxis1>1)&&($naxis2>1)} {
      append texte "+/- $dif"
   }
   ::console::affiche_resultat "$texte\n"
   $private(fitgauss,$visuNo,frm).frame1.lab5 configure -text "$texte"

   #---
   if {($naxis1==1)||($naxis2==1)} {
      set texte "$caption(audace,largeurequiv) : [ format "%f" $leq ] pixels"
      ::console::affiche_resultat "$texte\n"
      $private(fitgauss,$visuNo,frm).frame1.lab6 configure -text "$texte"
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
}

#
# confFitgauss
# Rafraichit la fenetre
#
proc confFitgauss { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(fitgauss,$visuNo,modeRefresh) == "0" } {
      $private(fitgauss,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::refreshFitgauss $visuNo"
   } else {
      $private(fitgauss,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::refreshFitgauss $visuNo"
   }
}

###################################################################################

#
# center visuNo
# Fournit le photocentre d'une fenetre d'une image
#
proc center { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(center,$visuNo,frm) "$base.center$visuNo"
   set frm $private(center,$visuNo,frm)
   if [ winfo exists $frm ] {
      ferme_fenetre_analyse $visuNo $frm center
   }

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(center,$visuNo,position) ] }    { set conf(center,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(center,$visuNo,modeRefresh) ] } { set conf(center,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,centro)"
   wm geometry $frm $conf(center,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "ferme_fenetre_analyse $visuNo $frm center"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(center,$visuNo,modeRefresh) -command "::confCenter $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir le photocentre
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::refreshCenter $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::refreshCenter $visuNo

   #--- Rafraichit la fenetre
   ::confCenter $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# refreshCenter
# Rafraichit les valeurs de la fenetre
#
proc refreshCenter { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(center,box) [ ::confVisu::getBox $visuNo ]
   if { $private(center,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set private(center,valeurs) [ buf[ ::confVisu::getBufNo $visuNo ] centro $private(center,box) ]

   #--- Mise a jour des variables
   set private(center,centro) "$caption(audace,center_xy) : ( [ format "%.2f" [ lindex $private(center,valeurs) 0 ] ] / [ format "%.2f" [ lindex $private(center,valeurs) 1 ] ] )"

   #--- Mise a jour des labels
   $private(center,$visuNo,frm).frame1.lab1 configure -text "$private(center,centro)"
}

#
# confCenter
# Rafraichit la fenetre
#
proc confCenter { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(center,$visuNo,modeRefresh) == "0" } {
      $private(center,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::refreshCenter $visuNo"
   } else {
      $private(center,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::refreshCenter $visuNo"
   }
}

###################################################################################

#
# photom visuNo
# Fournit la photometrie integrale d'une fenetre d'une image
#
proc photom { visuNo } {
   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(photom,$visuNo,frm) "$base.photom$visuNo"
   set frm $private(photom,$visuNo,frm)
   if [ winfo exists $frm ] {
      ferme_fenetre_analyse $visuNo $frm photom
   }

   #--- Capture de la fenetre d'analyse
   set private(photom,box) [ ::confVisu::getBox $visuNo ]
   if { $private(photom,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(photom,$visuNo,position) ] }    { set conf(photom,$visuNo,position)    "+350+75" }
   if { ! [ info exists conf(photom,$visuNo,modeRefresh) ] } { set conf(photom,$visuNo,modeRefresh) "0" }

   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,phot)"
   wm geometry $frm $conf(photom,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "ferme_fenetre_analyse $visuNo $frm photom"

   #--- Creation d'une frame
   frame $frm.frame1 -borderwidth 2 -relief raised

      #--- Cree les etiquettes
      label $frm.frame1.lab0 -text "Visu$visuNo"
      pack $frm.frame1.lab0 -padx 10 -pady 2
      label $frm.frame1.lab1 -text ""
      pack $frm.frame1.lab1 -padx 10 -pady 2

   pack $frm.frame1 -side top -fill both -expand 1

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(photom,$visuNo,modeRefresh) -command "::confPhotom $visuNo"
      pack $frm.frame2.modeRefresh -anchor w -side top -padx 3 -pady 3

      #--- Cree le bouton pour rafraichir la photometrie integrale
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::refreshPhotom $visuNo"
      pack $frm.frame2.butRefresh -side top -padx 6 -pady 10 -ipadx 20 -ipady 6

   pack $frm.frame2 -side top -fill both -expand 1

   #--- Rafraichit les valeurs
   ::refreshPhotom $visuNo

   #--- Rafraichit la fenetre
   ::confPhotom $visuNo

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#
# refreshPhotom
# Rafraichit les valeurs de la fenetre
#
proc refreshPhotom { visuNo args } {
   variable private
   global caption

   #--- Capture de la fenetre d'analyse
   set private(photom,box) [ ::confVisu::getBox $visuNo ]
   if { $private(photom,box) == "" } {
      return
   }

   #--- Lecture des parametres dans la fenetre
   set private(photom,valeurs) [ buf[ ::confVisu::getBufNo $visuNo ] phot $private(photom,box) ]

   #--- Mise a jour des variables
   set private(photom,integflux) "$caption(audace,integflux) : [ lindex $private(photom,valeurs) 0 ]"

   #--- Mise a jour des labels
   $private(photom,$visuNo,frm).frame1.lab1 configure -text "$private(photom,integflux)"
}

#
# confPhotom
# Rafraichit la fenetre
#
proc confPhotom { visuNo args } {
   variable private
   global conf

   #--- Configure le bouton pour le rafraichissement
   if { $conf(photom,$visuNo,modeRefresh) == "0" } {
      $private(photom,$visuNo,frm).frame2.butRefresh configure -state normal
      #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::removeFileNameListener $visuNo "::refreshPhotom $visuNo"
   } else {
      $private(photom,$visuNo,frm).frame2.butRefresh configure -state disabled
      #--- Je declare le rafraichissement automatique des valeurs si on charge une image
      ::confVisu::addFileNameListener $visuNo "::refreshPhotom $visuNo"
   }
}

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

#
# ferme_fenetre_analyse visuNo frm nom_conf
# Recupere les coordonnees des boites de dialogue ci-dessus
#
proc ferme_fenetre_analyse { visuNo frm nom_conf } {
   global conf

   #--- J'arrete le rafraichissement automatique des valeurs si on charge une image
   ::confVisu::removeFileNameListener $visuNo "::refreshStatwin $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::refreshFwhm $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::refreshFitgauss $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::refreshCenter $visuNo"
   ::confVisu::removeFileNameListener $visuNo "::refreshPhotom $visuNo"

   #--- Determination de la position de la fenetre
   set geometry [ wm geometry $frm ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set conf($nom_conf,$visuNo,position) "+[ string range $geometry $deb $fin ]"

   #--- Fermeture de la fenetre
   destroy $frm
}

