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

###################################################################################


###################################################################################
#
# psfimcce visuNo
# Ajuste une psf dans une fenetre d'une image
#

proc psfimcce { visuNo } {

   variable private
   global caption conf

   #---
   set base [ ::confVisu::getBase $visuNo ]

   #---
   set private(psfimcce,$visuNo,frm) "$base.psfimcce$visuNo"
   set frm $private(psfimcce,$visuNo,frm)
   if [ winfo exists $frm ] {
      ferme_fenetre_analyse $visuNo $frm psfimcce
   }

   #--- Capture de la fenetre d'analyse
   set private(psfimcce,$visuNo,box) [ ::confVisu::getBox $visuNo ]
   if { $private(psfimcce,$visuNo,box) == "" } {
      return
   }

   #--- Initialisation de la position de la fenetre
   psf_init $visuNo
   
   #--- Creation de la fenetre
   toplevel $frm
   wm transient $frm $base
   wm resizable $frm 0 0
   wm title $frm "$caption(audace,menu,psfimcce) Visu$visuNo"
   wm geometry $frm $conf(psfimcce,$visuNo,position)
   wm protocol $frm WM_DELETE_WINDOW "psf_fermer $visuNo $frm"


   set onglets [frame $frm.onglets]
   pack $onglets -in $frm

         pack [ttk::notebook $onglets.nb] -expand yes -fill both 
#          set f1 [frame $onglets.nb.f1]
         set f_res  [frame $onglets.nb.f_res]
         set f_img  [frame $onglets.nb.f_img]
         set f_mark [frame $onglets.nb.f_mark]
         set f_comp [frame $onglets.nb.f_comp]

#         $onglets.nb add $f1 -text "Methode"
         $onglets.nb add $f_res -text "Mesures"
         $onglets.nb add $f_img -text "Image"
         $onglets.nb add $f_mark -text "Marques"
         $onglets.nb add $f_comp -text "Comparaison"

          $onglets.nb select $f_res
         ttk::notebook::enableTraversal $onglets.nb

         # onglets : methodes

         #set methodes [frame $f1.methodes]
         #pack $methodes -in $f1 -padx 5 -pady 5
              
         #     psf_gui_methodes $visuNo $methodes

         # onglets : mesures

         set results [frame $f_res.results]
         pack $results -in $f_res

              set block [frame $results.params]
              pack $block -in $results

                  set values [ frame $block.valuesleft]
                  pack $values -in $block -anchor n -side left
                          
                         foreach key [get_fields_current_psf_left]  {

                              set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                              pack $value -in $values -anchor n -side top -expand 1 -fill both -padx 0 -pady 0

                                   if {$key=="err_xsm"||$key=="err_ysm"||$key=="err_psf"} {
                                      set active disabled
                                   } else {
                                      set active active
                                   }
                                   button $value.graph -state $active -text "$key" -relief "raised" -width 8 -height 1\
                                      -command "psf_graph $visuNo $key" 
                                   label $value.lab1 -text " = " 
                                   label $value.lab2 -textvariable private(psfimcce,$visuNo,psf,$key) -width 8
                                   grid $value.graph $value.lab1 $value.lab2 -sticky nsw -pady 3
                         }

                  set values [ frame $block.valuesright]
                  pack $values -in $block -anchor n -side right

                         foreach key [get_fields_current_psf_right] {

                              set value [ frame $values.$key -borderwidth 0 -cursor arrow -relief groove ]
                              pack $value -in $values -anchor n -side top -padx 0 -pady 0

                                   if {$key=="err_flux"||$key=="radius"||$key=="err_sky"||$key=="pixmax"} {
                                      set active disabled
                                   } else {
                                      set active active
                                   }
                                   button $value.graph -state $active -text "$key" -relief "raised" -width 8 -height 1\
                                      -command "psf_graph $visuNo $key" 
                                   label $value.lab1 -text " = " 
                                   label $value.lab2 -textvariable private(psfimcce,$visuNo,psf,$key)  -width 8
                                   grid $value.graph $value.lab1 $value.lab2 -sticky nsw -pady 3
                         }

         # onglets : images

         set images [frame $f_img.images]
         pack $images -in $f_img -expand yes -fill both

              set block1 [frame $images.block1 -borderwidth 2 -relief groove]
              set block2 [frame $images.block2 -borderwidth 2 -relief groove]
              set block3 [frame $images.block3 -borderwidth 2 -relief groove]
              set block4 [frame $images.block4 -borderwidth 2 -relief groove]

              grid $block1 -in $images -row 0 -column 0 -sticky news
              grid $block2 -in $images -row 0 -column 1 -sticky news
              grid $block3 -in $images -row 1 -column 0 -sticky news
              grid $block4 -in $images -row 1 -column 1 -sticky news

              grid rowconfigure $images {0 1} -weight 1
              grid columnconfigure $images 0 -weight 1
              grid columnconfigure $images 1 -weight 1

              label $block1.lab -text "Image not\navailable" -justify center
              grid $block1.lab -in $block1 -row 0 -column 0 -sticky es -pady 10 -padx 10

              label $block2.lab -text "Image not\navailable"  -justify center -pady 10 -padx 10
              grid $block2.lab -in $block2 -row 0 -column 0 -sticky news

              label $block3.lab -text "Image not\navailable"  -justify center -pady 10 -padx 10
              grid $block3.lab -in $block3 -row 0 -column 0 -sticky news

         # onglets : Marques

         set marks [frame $f_mark.marks]
         pack $marks -in $f_mark -expand yes -fill both

              set block [frame $marks.marks]
              pack $block -in $marks

                  checkbutton $block.voir -text "Voir les cercles de mesures photometriques" \
                                    -variable private(psfimcce,$visuNo,marks,cercle)
                  button $block.delete -text "Nettoyer les marques" -relief "raised"  -height 1\
                                    -command "psf_clean_mark $visuNo" 
                  grid $block.voir     -sticky nsw -pady 8
                  grid $block.delete   -sticky nsw -pady 3

         # onglets : Comparaison

         set compar [frame $f_comp.compar]
         pack $compar -in $f_comp -expand yes -fill both

              set block [frame $compar.methodes]
              pack $block -in $compar

                  label       $block.lab        -text "Comparaison des methodes"  -justify left 
                  checkbutton $block.photom     -text "photom" -variable private(psfimcce,$visuNo,compar,photom)
                  checkbutton $block.fitgauss2D -text "fitgauss2D" -variable private(psfimcce,$visuNo,compar,fitgauss2D)
                  checkbutton $block.psfimcce   -text "psfimcce" -variable private(psfimcce,$visuNo,compar,psfimcce)

                  button $block.go -text "Go" -relief "raised" -width 8 -height 1\
                                    -command "psf_compar $visuNo $compar" 

                  grid $block.lab        -sticky nsw -pady 8
                  grid $block.photom     -sticky nsw -pady 3
                  grid $block.fitgauss2D -sticky nsw -pady 3
                  grid $block.psfimcce   -sticky nsw -pady 3
                  grid $block.go         -sticky nsw -pady 10

              set block [frame $compar.graph]
              pack $block -in $compar

                  button $block.xsm -state normal -text "xsm" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo xsm" 
                  button $block.ysm -state normal -text "ysm" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo ysm" 
                  button $block.fwhmx -state normal -text "fwhmx" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo fwhmx" 
                  button $block.fwhmy -state normal -text "fwhmy" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo fwhmy" 
                  button $block.fwhm -state normal -text "fwhm" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo fwhm" 
                  button $block.flux -state normal -text "flux" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo flux" 
                  button $block.sky -state normal -text "sky" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo sky" 
                  button $block.snint -state normal -text "snint" -relief "raised" -width 8 -height 1\
                                    -command "psf_graph_compar $visuNo snint" 
                          
                  grid $block.xsm $block.fwhmx  $block.fwhm $block.sky   -sticky nsw -pady 3
                  grid $block.ysm $block.fwhmy  $block.flux $block.snint -sticky nsw -pady 3


   #--- Creation d'une frame
   frame $frm.config -borderwidth 2 -relief raised
   pack $frm.config -side top -fill both -expand 1

         psf_gui_methodes $visuNo $frm.config

   #--- Creation d'une frame
   frame $frm.temps -borderwidth 2 -relief raised
   pack $frm.temps -side top -fill both -expand 1 -anchor c

         label $frm.temps.lab -text "Duree : "  -justify center -pady 1 -padx 1
         label $frm.temps.val -textvariable private(psfimcce,$visuNo,duree) -justify center -pady 1 -padx 1
         label $frm.temps.sec -text "sec"  -justify center -pady 1 -padx 1

         grid $frm.temps.lab $frm.temps.val $frm.temps.sec -sticky news

   #--- Creation d'une frame
   frame $frm.frame2 -borderwidth 2 -relief raised

      #--- Cree le checkbutton pour choisir le mode de rafraichissement
      checkbutton $frm.frame2.modeRefresh -text "$caption(audace,refreshAuto)" \
         -variable conf(psfimcce,$visuNo,modeRefresh) -command "::confFitgauss $visuNo"\
         -state disabled

      button $frm.frame2.buthelp -text "Aide" \
         -command "psf_help $visuNo" -width 10

      #--- Cree le bouton pour rafraichir l'ajustement de la gaussienne
      button $frm.frame2.butRefresh -text "$caption(audace,refreshManuel)" \
         -command "::refreshPSF $visuNo"

      #--- Cree le bouton pour rafraichir l'ajustement de la gaussienne
      button $frm.frame2.butFermer -text "Fermer" \
         -command "psf_fermer $visuNo $frm" -width 10

      grid $frm.frame2.modeRefresh -columnspan 3 -sticky news
      grid $frm.frame2.buthelp $frm.frame2.butRefresh $frm.frame2.butFermer -sticky news


   pack $frm.frame2 -side top -fill both -expand 1




   #--- Rafraichit les valeurs
   #::refreshPSF $visuNo
   ::refreshPSF_simple $visuNo

   #--- Rafraichit la fenetre
   #::confFitgauss $visuNo

   #--- La fenetre est active
   focus $frm
   

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-r> {catch {::console::affiche_erreur "ressource\n" ; source /srv/develop/audela/gui/audace/aud_menu_5.tcl}}
   bind $frm <Key-n> {catch {::console::affiche_erreur "edit source : \n nc /srv/develop/audela/gui/audace/aud_menu_5.tcl\n" }}
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}


   proc get_fields_current_psf { } {
      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "err_psf" "flux" "err_flux" "pixmax" \
                   "intensity" "sky" "err_sky" "snint" "radius" ]
   }
   proc get_fields_current_psf_left { } {
      return [list "xsm" "ysm" "err_xsm" "err_ysm" "fwhmx" "fwhmy" "fwhm" "err_psf" ]
   }

   proc get_fields_current_psf_right { } {
      return [list "flux" "err_flux" "pixmax" "intensity" "sky" "err_sky" "snint" "radius" ]
   }

   proc psf_get_methodes { } {
   
      return { fitgauss photom fitgauss2D psfimcce }
   
   }

   proc psf_gui_methodes { visuNo frm } {

   variable private

      set spinlist ""
      for {set i 1} {$i<$private(psfimcce,$visuNo,radius,max)} {incr i} {lappend spinlist $i}
      
      set actions [frame $frm.actions -borderwidth 0 -cursor arrow -relief groove]
      pack $actions -in $frm -anchor c -side top

           label $actions.lab1 -text "Methode pour PSF : " 
           menubutton $actions.b -menu $actions.b.m -textvar private(psfimcce,$visuNo,methode) -width 10 -relief groove
           menu $actions.b.m -tearoff 0
           foreach value [psf_get_methodes] { 
              $actions.b.m add command -label $value -command "psf_set_methode $visuNo $frm $value"
           }
           grid $actions.lab1 $actions.b
           #$actions.b.m select 

      set conf [frame $frm.config -borderwidth 0 -cursor arrow -relief groove]
      pack $conf -in $frm -anchor c -side top

      set glo [frame $frm.glo -borderwidth 0 -cursor arrow -relief groove]
      pack $glo -in $frm -anchor c -side top

         set glocheck [frame $glo.check -borderwidth 0 -cursor arrow -relief groove]
         pack $glocheck -in $glo -anchor c -side top
         set glocconf [frame $glo.conf -borderwidth 0 -cursor arrow -relief groove]
         pack $glocconf -in $glo -anchor c -side top

            checkbutton $glocheck.globale -text "Recherche globale" \
               -variable private(psfimcce,$visuNo,globale) \
               -command "psf_switch_globale $visuNo $glocconf $value"
            grid $glocheck.globale

      set ecr [frame $frm.ecr -borderwidth 0 -cursor arrow -relief groove]
      pack $ecr -in $frm -anchor c -side top

         set ecrcheck [frame $ecr.check -borderwidth 0 -cursor arrow -relief groove]
         pack $ecrcheck -in $ecr -anchor c -side top
         set ecrcconf [frame $ecr.conf -borderwidth 0 -cursor arrow -relief groove]
         pack $ecrcconf -in $ecr -anchor c -side top

            checkbutton $ecrcheck.ecrbale -text "Ecretage" \
               -variable private(psfimcce,$visuNo,ecretage) \
               -command "psf_switch_ecretage $visuNo $ecrcconf $value"
            grid $ecrcheck.ecrbale


   }

   proc psf_switch_globale { visuNo frm value }  {
  
      variable private

      set block $frm.here
      destroy $block
      set conf [frame $block -borderwidth 0 -cursor arrow -relief groove]
      pack $conf -in $frm -anchor c -side top

      if {$private(psfimcce,$visuNo,globale)==1} {

         label $block.radl1 -text "Limite min du Rayon : " 
         entry $block.radv1 -textvariable private(psfimcce,$visuNo,globale,min) -relief sunken -width 5

         label $block.radl2 -text "Limite max du Rayon : " 
         entry $block.radv2 -textvariable private(psfimcce,$visuNo,globale,max) -relief sunken -width 5

         checkbutton $block.arret -text " arret si" -variable private(psfimcce,$visuNo,globale,arret)

         set sav $private(psfimcce,$visuNo,globale,nberror)

         spinbox $block.nberror   -values [list 1 2 3 5 10] -from 1 -to 10 \
                                  -textvariable private(psfimcce,$visuNo,globale,nberror) -width 3
         set private(psfimcce,$visuNo,globale,nberror) $sav
         
         label $block.arretlab    -text "erreurs consecutives" 


         grid $block.radl1  $block.radv1 -sticky nsw -columnspan 2 -pady 3
         grid $block.radl2  $block.radv2 -sticky nsw -columnspan 2 -pady 3
         grid $block.arret  $block.nberror $block.arretlab -columnspan 1 -sticky nsw -pady 3
      }

   }

   proc psf_switch_ecretage { visuNo frm value }  {
  
      variable private

      set block $frm.here
      destroy $block
      set conf [frame $block -borderwidth 0 -cursor arrow -relief groove]
      pack $conf -in $frm -anchor c -side top

      if {$private(psfimcce,$visuNo,ecretage)==1} {

         label $block.satl -text "Saturation (ADU): " 
         entry $block.satv -textvariable private(psfimcce,$visuNo,saturation)  -relief sunken -width 5

         label $block.thrl -text "Threshold (pixel): " 
         entry $block.thrv -textvariable private(psfimcce,$visuNo,threshold) -relief sunken -width 5

         grid $block.satl  $block.satv -sticky nsw -pady 3
         grid $block.thrl  $block.thrv -sticky nsw -pady 3
      }

   }

   proc psf_set_methode { visuNo frm value }  {
  
      variable private

      set private(psfimcce,$visuNo,methode) $value

      set block $frm.config.here
      destroy $block
      set conf [frame $block -borderwidth 0 -cursor arrow -relief groove]
      pack $conf -in $frm.config -anchor c -side top

      set spinlist ""
      for {set i 1} {$i<$private(psfimcce,$visuNo,radius,max)} {incr i} {lappend spinlist $i}


      switch $value {
         "photom" {
                     label $block.radl -text "Rayon : " 
                     set sav $private(psfimcce,$visuNo,radius)
                     spinbox $block.radiusc -values $spinlist -from 1 -to $private(psfimcce,$visuNo,radius,max) \
                         -textvariable private(psfimcce,$visuNo,radius) -width 3 \
                         -command "refreshPSF_simple $visuNo"
                     pack  $block.radiusc -side left 
                     set private(psfimcce,$visuNo,radius) $sav
                     $block.radiusc set $private(psfimcce,$visuNo,radius)

                     LabelEntry $block.r1 -label "r1 = " -textvariable private(psfimcce,$visuNo,photom,r1) -relief sunken -width 5
                     label $block.r1s -text "x Rayon" 

                     LabelEntry $block.r2 -label "r2 = " -textvariable private(psfimcce,$visuNo,photom,r2) -relief sunken -width 5
                     label $block.r2s -text "x Rayon" 

                     LabelEntry $block.r3 -label "r3 = " -textvariable private(psfimcce,$visuNo,photom,r3) -relief sunken -width 5
                     label $block.r3s -text "x Rayon" 

                     grid $block.radl  $block.radiusc -sticky nsw -pady 0
                     grid $block.r1 $block.r1s -sticky nesw -pady 0 -padx 3 -columnspan 2
                     grid $block.r2 $block.r2s -sticky nesw -pady 0 -padx 3 -columnspan 2
                     grid $block.r3 $block.r3s -sticky nesw -pady 0 -padx 3 -columnspan 2
                  }

         "fitgauss2D" 
                    {
                     label $block.radl -text "Rayon : " 
                     set sav $private(psfimcce,$visuNo,radius)
                     spinbox $block.radiusc -values $spinlist -from 1 -to $private(psfimcce,$visuNo,radius,max) \
                         -textvariable private(psfimcce,$visuNo,radius) -width 3 \
                         -command "refreshPSF_simple $visuNo"
                     pack  $block.radiusc -side left 
                     set private(psfimcce,$visuNo,radius) $sav
                     $block.radiusc set $private(psfimcce,$visuNo,radius)

                     grid $block.radl  $block.radiusc -sticky nsw -pady 3
                  }
         "psfimcce" {
                     label $block.radl -text "Rayon : " 
                     set sav $private(psfimcce,$visuNo,radius)
                     spinbox $block.radiusc -values $spinlist -from 1 -to $private(psfimcce,$visuNo,radius,max) \
                         -textvariable private(psfimcce,$visuNo,radius) -width 3 \
                         -command "refreshPSF_simple $visuNo"
                     pack  $block.radiusc -side left 
                     set private(psfimcce,$visuNo,radius) $sav
                     $block.radiusc set $private(psfimcce,$visuNo,radius)

                     radiobutton $block.preclow  -text "Calcul rapide" -variable private(psfimcce,$visuNo,precision) -value low
                     radiobutton $block.prechigh -text "Haute Precision" -variable private(psfimcce,$visuNo,precision) -value high

                     grid $block.radl    $block.radiusc  -sticky nsw -pady 3
                     grid $block.preclow $block.prechigh -sticky nsw -pady 3
                  }

      }

      refreshPSF_simple $visuNo

   }

   proc refreshPSF { visuNo args } {

      variable private
      global caption

      #--- Capture de la fenetre d'analyse
      set private(center,box) [ ::confVisu::getBox $visuNo ]
      if { $private(center,box) == "" } {
         return
      }

      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set r [ buf$bufNo fitgauss $private(center,box) ]
      set x [lindex $r 1]
      set y [lindex $r 5]

      set tt0 [clock clicks -milliseconds]
      if { $private(psfimcce,$visuNo,globale) == 0 } {
         mesurePSF $visuNo $x $y
      } else {
         globalePSF $visuNo $x $y
      }
      set private(psfimcce,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]
      
      return
   }

   proc refreshPSF_simple { visuNo } {

      #--- Capture de la fenetre d'analyse
      set private(center,box) [ ::confVisu::getBox $visuNo ]
      if { $private(center,box) == "" } {
         return
      }

      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set r [ buf$bufNo fitgauss $private(center,box) ]
      set x [lindex $r 1]
      set y [lindex $r 5]

      set tt0 [clock clicks -milliseconds]
      mesurePSF $visuNo $x $y
      set private(psfimcce,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]

      return
   }



   proc mesurePSF { visuNo x y } {

      variable private

      $private(psfimcce,$visuNo,hcanvas) delete mesurePSF

      if { $private(psfimcce,$visuNo,globale) == 0 } {
         set tt0 [clock clicks -milliseconds]
      }
      set private(center,box) [ ::confVisu::getBox $visuNo ]
      if { $private(center,box) == "" } {
         return
      }

      set bufNo [ ::confVisu::getBufNo $visuNo ]
#      foreach key [get_fields_current_psf] {
#         set private(psfimcce,$visuNo,psf,$key) "-"
#      }

      switch $private(psfimcce,$visuNo,methode) {
         "fitgauss" {
            set r [ buf$bufNo fitgauss $private(center,box) ]
            set private(psfimcce,$visuNo,psf,xsm)       [format "%.4f" [lindex $r 1] ]
            set private(psfimcce,$visuNo,psf,ysm)       [format "%.4f" [lindex $r 5] ]
            set private(psfimcce,$visuNo,psf,err_xsm)   "-"
            set private(psfimcce,$visuNo,psf,err_ysm)   "-"
            set private(psfimcce,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
            set private(psfimcce,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
            set private(psfimcce,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,flux)      "-"
            set private(psfimcce,$visuNo,psf,err_flux)  "-"
            set private(psfimcce,$visuNo,psf,pixmax)    "-"
            set private(psfimcce,$visuNo,psf,intensity) [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 0],2 ) + pow ( [lindex $r 4],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,sky)       [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 3],2 ) + pow ( [lindex $r 7],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,err_sky)   "-"
            set private(psfimcce,$visuNo,psf,snint)     "-"
            set private(psfimcce,$visuNo,psf,radius)    "-"
            set private(psfimcce,$visuNo,psf,err_psf)   "-"

         }
         "photom" {
            set r [ buf$bufNo fitgauss $private(center,box) ]
            set xs0 [expr int($x - $private(psfimcce,$visuNo,radius))]
            set ys0 [expr int($y - $private(psfimcce,$visuNo,radius))]
            set xs1 [expr int($x + $private(psfimcce,$visuNo,radius))]
            set ys1 [expr int($y + $private(psfimcce,$visuNo,radius))]
            set r1  [expr int($private(psfimcce,$visuNo,photom,r1) * $private(psfimcce,$visuNo,radius))]
            set r2  [expr int($private(psfimcce,$visuNo,photom,r2) * $private(psfimcce,$visuNo,radius))]
            set r3  [expr int($private(psfimcce,$visuNo,photom,r3) * $private(psfimcce,$visuNo,radius))]
            set err [ catch { set photom [buf$bufNo photom [list $xs0 $ys0 $xs1 $ys1] square $r1 $r2 $r3 ] } msg ]
            if {$err} {
               set private(psfimcce,$visuNo,psf,err_psf)  "Erreur buf photom"
               return -code -1 "Erreur buf photom : $photom"
            }
            set err [ catch { set stat [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ] } msg ]
            if {$err} {
               set private(psfimcce,$visuNo,psf,err_psf)  "Erreur buf stat"
               return -code -1 "Erreur buf stat : $stat"
            }
            set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]
   
            set private(psfimcce,$visuNo,psf,xsm)       [format "%.4f" $x ]
            set private(psfimcce,$visuNo,psf,ysm)       [format "%.4f" $y ]
            set private(psfimcce,$visuNo,psf,err_xsm)   "-"
            set private(psfimcce,$visuNo,psf,err_ysm)   "-"
            set private(psfimcce,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
            set private(psfimcce,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
            set private(psfimcce,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,flux)      [format "%.2f" [lindex $photom 0] ]
            set private(psfimcce,$visuNo,psf,err_flux)  "-"
            set private(psfimcce,$visuNo,psf,pixmax)    [format "%.2f" [lindex $stat 2] ]
            set private(psfimcce,$visuNo,psf,intensity) [format "%.2f" [expr [lindex $stat 2] - [lindex $photom 2] ] ]
            set private(psfimcce,$visuNo,psf,sky)       [format "%.2f" [lindex $photom 2] ]
            set private(psfimcce,$visuNo,psf,err_sky)   [format "%.2f" [lindex $photom 3] ]
            set private(psfimcce,$visuNo,psf,snint)     [format "%.2f" [expr [lindex $photom 0] / sqrt ([lindex $photom 0]+[lindex $photom 4]*[lindex $photom 2] ) ] ]
            set private(psfimcce,$visuNo,psf,radius)    $private(psfimcce,$visuNo,radius)
            set private(psfimcce,$visuNo,psf,err_psf)   "-"


         }
         "fitgauss2D" {
            set xs0 [expr int($x - $private(psfimcce,$visuNo,radius))]
            set ys0 [expr int($y - $private(psfimcce,$visuNo,radius))]
            set xs1 [expr int($x + $private(psfimcce,$visuNo,radius))]
            set ys1 [expr int($y + $private(psfimcce,$visuNo,radius))]
            set r [buf$bufNo fitgauss2d [list $xs0 $ys0 $xs1 $ys1]]

            set err [ catch { set stat [buf$bufNo stat [list $xs0 $ys0 $xs1 $ys1] ] } msg ]
            if {$err} {
               set private(psfimcce,$visuNo,psf,err_psf)  "Erreur buf stat"
               return -code -1 "Erreur buf stat : $stat"
            }
            set npix [expr ($xs1 - $xs0 + 1) * ($ys1 - $ys0 + 1)]

            set private(psfimcce,$visuNo,psf,xsm)       [format "%.4f" [lindex $r  1] ]
            set private(psfimcce,$visuNo,psf,ysm)       [format "%.4f" [lindex $r  5] ]
            set private(psfimcce,$visuNo,psf,err_xsm)   "-"
            set private(psfimcce,$visuNo,psf,err_ysm)   "-"
            set private(psfimcce,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r 2] ]
            set private(psfimcce,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r 6] ]
            set private(psfimcce,$visuNo,psf,fwhm)      [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 2],2 ) + pow ( [lindex $r 6],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,flux)      [format "%.2f" [expr (([lindex $r 0])+([lindex $r 4])) / 2. * 2 * 3.14159265359 * [lindex $r 2] * [lindex $r 6] / 2.35482 / 2.35482] ]
            set private(psfimcce,$visuNo,psf,err_flux)  "-"
            set private(psfimcce,$visuNo,psf,pixmax)    [format "%.2f" [lindex $stat 2] ]
            set private(psfimcce,$visuNo,psf,intensity) [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 0],2 ) + pow ( [lindex $r 4],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,sky)       [format "%.2f" [expr sqrt ( ( pow ( [lindex $r 3],2 ) + pow ( [lindex $r 7],2 ) ) / 2.0 ) ] ]
            set private(psfimcce,$visuNo,psf,err_sky)   "-"
            set private(psfimcce,$visuNo,psf,snint)     [format "%.2f" [expr $private(psfimcce,$visuNo,psf,flux) / sqrt ($private(psfimcce,$visuNo,psf,flux)+$npix*$private(psfimcce,$visuNo,psf,sky) ) ] ]
            set private(psfimcce,$visuNo,psf,radius)    $private(psfimcce,$visuNo,radius)
            set private(psfimcce,$visuNo,psf,err_psf)   "-"
        
         }
         "psfimcce" {
            set xs0 [expr int($x - $private(psfimcce,$visuNo,radius))]
            set ys0 [expr int($y - $private(psfimcce,$visuNo,radius))]
            set xs1 [expr int($x + $private(psfimcce,$visuNo,radius))]
            set ys1 [expr int($y + $private(psfimcce,$visuNo,radius))]
            set r [buf$bufNo psfimcce [list $xs0 $ys0 $xs1 $ys1]]
            set private(psfimcce,$visuNo,psf,xsm)       [format "%.4f" [lindex $r  0] ]
            set private(psfimcce,$visuNo,psf,ysm)       [format "%.4f" [lindex $r  1] ]
            set private(psfimcce,$visuNo,psf,err_xsm)   "-"
            set private(psfimcce,$visuNo,psf,err_ysm)   "-"
            set private(psfimcce,$visuNo,psf,fwhmx)     [format "%.2f" [lindex $r  4] ]
            set private(psfimcce,$visuNo,psf,fwhmy)     [format "%.2f" [lindex $r  5] ]
            set private(psfimcce,$visuNo,psf,fwhm)      [format "%.2f" [lindex $r  6] ]
            set private(psfimcce,$visuNo,psf,flux)      [format "%.1f" [lindex $r  7] ]
            set private(psfimcce,$visuNo,psf,err_flux)  "-"
            set private(psfimcce,$visuNo,psf,pixmax)    [format "%d" [expr int([lindex $r  9])] ]
            set private(psfimcce,$visuNo,psf,intensity) [format "%.2f" [lindex $r 10] ]
            set private(psfimcce,$visuNo,psf,sky)       [format "%.2f" [lindex $r 11] ]
            set private(psfimcce,$visuNo,psf,err_sky)   "-"
            set private(psfimcce,$visuNo,psf,snint)     [format "%.2f" [lindex $r 13] ]
            set private(psfimcce,$visuNo,psf,radius)    [format "%d" [lindex $r 14] ]
            if {[lindex $r 15] ==0} {
               set private(psfimcce,$visuNo,psf,err_psf)   "-"
            } else {
               set private(psfimcce,$visuNo,psf,err_psf)   [format "%s" [lindex $r 15] ]
            }
         }
      }
      if { $private(psfimcce,$visuNo,ecretage) == 1 } {
         set rdiff [expr sqrt((($private(psfimcce,$visuNo,psf,xsm)-$x)**2 + ($private(psfimcce,$visuNo,psf,ysm)-$y)**2)) / 2.0] 
         
         if {$rdiff>$private(psfimcce,$visuNo,threshold)} {
            set private(psfimcce,$visuNo,psf,err_psf) "Too Far"
         }
         
         if {$private(psfimcce,$visuNo,psf,pixmax)>$private(psfimcce,$visuNo,saturation)} {
            set private(psfimcce,$visuNo,psf,err_psf) "Saturated"
         }
      }
      if { $private(psfimcce,$visuNo,globale) == 0 } {
         set private(psfimcce,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]
      }
      if { $private(psfimcce,$visuNo,marks,cercle) == 1 } {
         psf_display_circle $visuNo $private(psfimcce,$visuNo,psf,xsm) \
                           $private(psfimcce,$visuNo,psf,ysm) $private(psfimcce,$visuNo,radius) \
                           green mesurePSF
      }

   }

   proc globalePSF { visuNo x y } {

      variable private
      variable private_graph
      
      $private(psfimcce,$visuNo,hcanvas) delete globalePSF

      array unset private_graph
      set nberror 0
      for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
         set private(psfimcce,$visuNo,radius) $radius
         mesurePSF $visuNo $x $y
         if {$private(psfimcce,$visuNo,psf,err_psf)=="-"} {
            set nberror 0
            set x $private(psfimcce,$visuNo,psf,xsm)
            set y $private(psfimcce,$visuNo,psf,ysm)
            foreach key [get_fields_current_psf] {
               set private_graph($radius,$key) $private(psfimcce,$visuNo,psf,$key)
            }
         } else {
            incr nberror
         }
         update
         if {$private(psfimcce,$visuNo,globale,arret) && $nberror>=$private(psfimcce,$visuNo,globale,nberror)} {
            ::console::affiche_erreur "Arret de la methode globale suite a $nberror erreurs consecutives\n"
            break
         }
      }

      # on cherche les meilleurs rayons
      # par critere sur le fond du ciel minimal
      set sky "" 
      set flux "" 
      for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
         if {[info exists private_graph($radius,sky)]} {
            lappend sky [list $radius $private_graph($radius,sky)]
            lappend flux [list $radius $private_graph($radius,flux)]
         }
      }
      set sky [lsort -index 1  -real -increasing $sky]
      set n [expr [llength $sky]/2]
      set zsky [lrange $sky 0 $n]
      set data ""
      foreach v $zsky {
         lappend data [lindex $v 1]
      }
      set err [ catch {
         set mean [::math::statistics::mean $data]
         set stdev [::math::statistics::stdev $data]
      } msg ]
      
      if { $err } {
         ::console::affiche_erreur "determination du ciel impossible\n"
         return
      }
      
      set limit [expr $mean + 3*$stdev]
      
      set list_radius ""
      foreach v $sky {
         if {[lindex $v 1]<$limit} {
            lappend list_radius [lindex $v 0]
         }
      }
      
      # on calcule les moyennes et erreurs 
      foreach key [get_fields_current_psf] {
         if {$key in [list  "err_xsm" "err_ysm" "err_flux" "err_sky" "radius"]} {continue}
         set data ""
         foreach radius $list_radius {
            if {[info exists private_graph($radius,$key)]} {
               lappend data $private_graph($radius,$key)
            }
         }
         if {$key == "err_psf"} {
            if {[llength $data]>0} {
               set private(psfimcce,$visuNo,psf,err_psf) "-"
            } else {
               set private(psfimcce,$visuNo,psf,err_psf) "Globale no data"
            }
            continue
         }

         set err [ catch {
            set mean [::math::statistics::mean $data]
            set stdev [::math::statistics::stdev $data]
         } msg ]

         if { $err } {
            #::console::affiche_erreur "determination de $key impossible\n"
            set private(psfimcce,$visuNo,psf,$key) "-"
            continue
         }

         switch $key {
            "xsm" {
               set private(psfimcce,$visuNo,psf,xsm)      [format "%.4f" $mean]
               set private(psfimcce,$visuNo,psf,err_xsm)  [format "%.4f" [expr 3.0 * $stdev] ]
            }
            "ysm" {
               set private(psfimcce,$visuNo,psf,ysm)      [format "%.4f" $mean]
               set private(psfimcce,$visuNo,psf,err_ysm)  [format "%.4f" [expr 3.0 * $stdev] ]
            }
            "flux" {
               set private(psfimcce,$visuNo,psf,flux)     [format "%.2f" $mean]
               set private(psfimcce,$visuNo,psf,err_flux) [format "%.2f" [expr 3.0 * $stdev] ]
            }
            "sky" {
               set private(psfimcce,$visuNo,psf,sky)     [format "%.2f" $mean]
               set private(psfimcce,$visuNo,psf,err_sky) [format "%.2f" [expr 3.0 * $stdev] ]
            }
            "fwhmx" - "fwhmy" - "fwhm" - "intensity" - "snint"  {
               set private(psfimcce,$visuNo,psf,$key)     [format "%.2f" $mean]
            }
            "pixmax" {
               set private(psfimcce,$visuNo,psf,$key)     [format "%d" [expr int($mean)] ]
            }
         }
      }
      
      # calcul du meilleur radius
      set flux [lsort -index 0  -integer -increasing $flux]
      foreach v $flux {
         if {[lindex $v 1] > $private(psfimcce,$visuNo,psf,flux)} {
            set private(psfimcce,$visuNo,psf,radius) [lindex $v 0]
            break
         }
      }
      
      if { $private(psfimcce,$visuNo,marks,cercle) == 1 } {
      
         $private(psfimcce,$visuNo,hcanvas) delete mesurePSF

         set list_radius [lsort -integer -increasing $list_radius]
         set radius [lindex $list_radius 0]
         if {$radius == $private(psfimcce,$visuNo,globale,min)} { incr radius  }
         psf_display_circle $visuNo $private(psfimcce,$visuNo,psf,xsm) \
                           $private(psfimcce,$visuNo,psf,ysm) $radius \
                           yellow globalePSF
         set radius [lindex $list_radius end]
         if {$radius == $private(psfimcce,$visuNo,globale,max)} { incr radius -1 }
         psf_display_circle $visuNo $private(psfimcce,$visuNo,psf,xsm) \
                           $private(psfimcce,$visuNo,psf,ysm) $radius \
                           yellow globalePSF
         psf_display_circle $visuNo $private(psfimcce,$visuNo,psf,xsm) \
                           $private(psfimcce,$visuNo,psf,ysm) $private(psfimcce,$visuNo,psf,radius) \
                           green globalePSF
         psf_display_circle $visuNo $private(psfimcce,$visuNo,psf,xsm) \
                           $private(psfimcce,$visuNo,psf,ysm) $private(psfimcce,$visuNo,globale,min) \
                           blue globalePSF
         psf_display_circle $visuNo $private(psfimcce,$visuNo,psf,xsm) \
                           $private(psfimcce,$visuNo,psf,ysm) $private(psfimcce,$visuNo,globale,max) \
                           blue globalePSF
      }
      
      
   }

   proc psf_graph { visuNo key } {

      variable private
      variable private_graph

      set x ""
      set y ""
      for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
         if {[info exists private_graph($radius,$key)]} {
            if {$private_graph($radius,$key)!="-"} {
               lappend x $radius
               lappend y $private_graph($radius,$key)
            }
         }
      }

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "$key VS radius"
      ::plotxy::xlabel radius
      ::plotxy::ylabel $key

      if {[llength $y] == 0} { return }
      
      set h [::plotxy::plot $x $y .]
      plotxy::sethandler $h [list -color "#18ad86" -linewidth 1]

      ::console::affiche_erreur "y $private(psfimcce,$visuNo,psf,$key) $private(psfimcce,$visuNo,psf,$key)\n"
      # Affichage de la valeur obtenue sous forme d'une ligne horizontale
      set x0 [list 0 $private(psfimcce,$visuNo,globale,max)]
      set y0 [list $private(psfimcce,$visuNo,psf,$key) $private(psfimcce,$visuNo,psf,$key)]
      set h [::plotxy::plot $x0 $y0 .]
      plotxy::sethandler $h [list -color black -linewidth 2]

      # Affichage des barres d erreurs
      if {$key in [list "xsm" "ysm" "flux" "sky"]} {
         if { $private(psfimcce,$visuNo,psf,err_$key) == "-" } { return }
         ::console::affiche_erreur "$private(psfimcce,$visuNo,psf,$key) + $private(psfimcce,$visuNo,psf,err_$key)\n"
         
         set yl [expr $private(psfimcce,$visuNo,psf,$key) + $private(psfimcce,$visuNo,psf,err_$key)]
         set x0 [list 0 $private(psfimcce,$visuNo,globale,max)]
         set y0 [list $yl $yl]
         set h [::plotxy::plot $x0 $y0 .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 2]

         set yl [expr $private(psfimcce,$visuNo,psf,$key) - $private(psfimcce,$visuNo,psf,err_$key)]
         set x0 [list 0 $private(psfimcce,$visuNo,globale,max)]
         set y0 [list $yl $yl]
         set h [::plotxy::plot $x0 $y0 .]
         plotxy::sethandler $h [list -color "#808080" -linewidth 2]
      }
      
   }

   proc psf_compar { visuNo frm } {

      variable private
      variable graph_compar

      array unset graph_compar

      set tt0 [clock clicks -milliseconds]

      #--- Capture de la fenetre d'analyse
      set private(center,box) [ ::confVisu::getBox $visuNo ]
      if { $private(center,box) == "" } {
         return
      }

      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set r [ buf$bufNo fitgauss $private(center,box) ]

      set x [lindex $r 1]
      set y [lindex $r 5]

      if { $private(psfimcce,$visuNo,compar,photom) == 1} {
         set private(psfimcce,$visuNo,methode) "photom"
         for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
            set private(psfimcce,$visuNo,radius) $radius
            mesurePSF $visuNo $x $y
            if {$private(psfimcce,$visuNo,psf,err_psf)=="-"} {
               set x $private(psfimcce,$visuNo,psf,xsm)
               set y $private(psfimcce,$visuNo,psf,ysm)
               foreach key [get_fields_current_psf] {
                  set graph_compar(psfimcce,compar,photom,$radius,$key) $private(psfimcce,$visuNo,psf,$key)
               }
            }
            update
         }
      }

      set x [lindex $r 1]
      set y [lindex $r 5]

      if { $private(psfimcce,$visuNo,compar,fitgauss2D) == 1} {
         set private(psfimcce,$visuNo,methode) "fitgauss2D"
         for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
            set private(psfimcce,$visuNo,radius) $radius
            mesurePSF $visuNo $x $y
            if {$private(psfimcce,$visuNo,psf,err_psf)=="-"} {
               set x $private(psfimcce,$visuNo,psf,xsm)
               set y $private(psfimcce,$visuNo,psf,ysm)
               foreach key [get_fields_current_psf] {
                  set graph_compar(psfimcce,compar,fitgauss2D,$radius,$key) $private(psfimcce,$visuNo,psf,$key)
               }
            }
            update
         }
      }

      set x [lindex $r 1]
      set y [lindex $r 5]

      if { $private(psfimcce,$visuNo,compar,psfimcce) == 1} {
         set private(psfimcce,$visuNo,methode) "psfimcce"
         for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
            set private(psfimcce,$visuNo,radius) $radius
            mesurePSF $visuNo $x $y
            if {$private(psfimcce,$visuNo,psf,err_psf)=="-"} {
               set x $private(psfimcce,$visuNo,psf,xsm)
               set y $private(psfimcce,$visuNo,psf,ysm)
               foreach key [get_fields_current_psf] {
                  set graph_compar(psfimcce,compar,psfimcce,$radius,$key) $private(psfimcce,$visuNo,psf,$key)
               }
            }
            update
         }
      }

      set private(psfimcce,$visuNo,duree) [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.] ]

   }

   proc psf_graph_compar { visuNo key } {

      variable private
      variable graph_compar

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {0 0 600 400}
      ::plotxy::title "$key VS radius (green = photom, red = fitgauss2D, black = psfimcce)"
      ::plotxy::xlabel radius
      ::plotxy::ylabel $key
      
      if { $private(psfimcce,$visuNo,compar,photom) == 1} {
         set xphotom ""
         set yphotom ""
         for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
            if {[info exists graph_compar(psfimcce,compar,photom,$radius,$key)]} {
               if {$graph_compar(psfimcce,compar,photom,$radius,$key)!="-"} {
                  lappend xphotom $radius
                  lappend yphotom $graph_compar(psfimcce,compar,photom,$radius,$key)
               }
            }
         }
         set h1 [::plotxy::plot $xphotom $yphotom o]
         plotxy::sethandler $h1 [list -color "#18ad86" -linewidth 1]
      }
      
      if { $private(psfimcce,$visuNo,compar,fitgauss2D) == 1} {
         set xfitgauss2D ""
         set yfitgauss2D ""
         for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
            if {[info exists graph_compar(psfimcce,compar,fitgauss2D,$radius,$key)]} {
               if {$graph_compar(psfimcce,compar,fitgauss2D,$radius,$key)!="-"} {
                  lappend xfitgauss2D $radius
                  lappend yfitgauss2D $graph_compar(psfimcce,compar,fitgauss2D,$radius,$key)
               }
            }
         }
         set h2 [::plotxy::plot $xfitgauss2D $yfitgauss2D +]
         plotxy::sethandler $h2 [list -color red -linewidth 1]
      }
      
      if { $private(psfimcce,$visuNo,compar,psfimcce) == 1} {
         set xpsfimcce ""
         set ypsfimcce ""
         for {set radius $private(psfimcce,$visuNo,globale,min)} {$radius <= $private(psfimcce,$visuNo,globale,max)} {incr radius} {
            if {[info exists graph_compar(psfimcce,compar,psfimcce,$radius,$key)]} {
               if {$graph_compar(psfimcce,compar,psfimcce,$radius,$key)!="-"} {
                  lappend xpsfimcce $radius
                  lappend ypsfimcce $graph_compar(psfimcce,compar,psfimcce,$radius,$key)
               }
            }
         }
         set h3 [::plotxy::plot $xpsfimcce $ypsfimcce x]
         plotxy::sethandler $h3 [list -color black -linewidth 1]
      }
   }

   proc psf_display_circle { visuNo xpic ypic radius color tag } {

      variable private

      if {$xpic=="-" || $ypic=="-" || $radius=="-"} {return}
      
      set xi [expr $xpic - $radius]
      set yi [expr $ypic - $radius]
      set can_xy [::confVisu::picture2Canvas $visuNo [list $xi $yi]]
      set cxi [lindex $can_xy 0]
      set cyi [lindex $can_xy 1]

      set xs [expr $xpic + $radius]
      set ys [expr $ypic + $radius]
      set can_xy [::confVisu::picture2Canvas $visuNo [list $xs $ys]]
      set cxs [lindex $can_xy 0]
      set cys [lindex $can_xy 1]

      $private(psfimcce,$visuNo,hcanvas) create oval $cxi $cyi $cxs $cys \
                 -fill {} -outline $color -width 2 -activewidth 3 \
                 -tag $tag
      
   }

   proc psf_clean_mark { visuNo } {
   
      variable private
      
      $private(psfimcce,$visuNo,hcanvas) delete mesurePSF
      $private(psfimcce,$visuNo,hcanvas) delete globalePSF
      
   }

   proc psf_help { visuNo } {
      global help
      ::audace::showHelpItem $help(dir,analyse) "1110psf.htm"
   }

   proc  psf_fermer { visuNo frm } {

      variable private
      global conf

      set conf(psfimcce,$visuNo,radius)            $private(psfimcce,$visuNo,radius)         
      set conf(psfimcce,$visuNo,radius,min)        $private(psfimcce,$visuNo,radius,min)     
      set conf(psfimcce,$visuNo,radius,max)        $private(psfimcce,$visuNo,radius,max)     
      set conf(psfimcce,$visuNo,globale,min)       $private(psfimcce,$visuNo,globale,min)    
      set conf(psfimcce,$visuNo,globale,max)       $private(psfimcce,$visuNo,globale,max)    
      set conf(psfimcce,$visuNo,saturation)        $private(psfimcce,$visuNo,saturation)     
      set conf(psfimcce,$visuNo,threshold)         $private(psfimcce,$visuNo,threshold)      
      set conf(psfimcce,$visuNo,globale)           $private(psfimcce,$visuNo,globale)        
      set conf(psfimcce,$visuNo,ecretage)          $private(psfimcce,$visuNo,ecretage)       
      set conf(psfimcce,$visuNo,methode)           $private(psfimcce,$visuNo,methode)        
      set conf(psfimcce,$visuNo,precision)         $private(psfimcce,$visuNo,precision)      
      set conf(psfimcce,$visuNo,photom,r1)         $private(psfimcce,$visuNo,photom,r1)      
      set conf(psfimcce,$visuNo,photom,r2)         $private(psfimcce,$visuNo,photom,r2)      
      set conf(psfimcce,$visuNo,photom,r3)         $private(psfimcce,$visuNo,photom,r3)      
      set conf(psfimcce,$visuNo,marks,cercle)      $private(psfimcce,$visuNo,marks,cercle)   
      set conf(psfimcce,$visuNo,globale,arret)     $private(psfimcce,$visuNo,globale,arret)  
      set conf(psfimcce,$visuNo,globale,nberror)   $private(psfimcce,$visuNo,globale,nberror)

      ferme_fenetre_analyse $visuNo $frm psfimcce

   }

   proc  psf_init { visuNo } {

      variable private
      global conf

      if { ! [ info exists conf(psfimcce,$visuNo,position)    ] } { set conf(psfimcce,$visuNo,position)    "+350+75" }
      if { ! [ info exists conf(psfimcce,$visuNo,modeRefresh) ] } { set conf(psfimcce,$visuNo,modeRefresh) "0" }
 
      if { ! [ info exists conf(psfimcce,$visuNo,radius)          ] } { set private(psfimcce,$visuNo,radius)            15         } else { set private(psfimcce,$visuNo,radius)          $conf(psfimcce,$visuNo,radius)          }
      if { ! [ info exists conf(psfimcce,$visuNo,radius,min)      ] } { set private(psfimcce,$visuNo,radius,min)        1          } else { set private(psfimcce,$visuNo,radius,min)      $conf(psfimcce,$visuNo,radius,min)      }
      if { ! [ info exists conf(psfimcce,$visuNo,radius,max)      ] } { set private(psfimcce,$visuNo,radius,max)        300        } else { set private(psfimcce,$visuNo,radius,max)      $conf(psfimcce,$visuNo,radius,max)      }
      if { ! [ info exists conf(psfimcce,$visuNo,globale,min)     ] } { set private(psfimcce,$visuNo,globale,min)       5          } else { set private(psfimcce,$visuNo,globale,min)     $conf(psfimcce,$visuNo,globale,min)     }
      if { ! [ info exists conf(psfimcce,$visuNo,globale,max)     ] } { set private(psfimcce,$visuNo,globale,max)       40         } else { set private(psfimcce,$visuNo,globale,max)     $conf(psfimcce,$visuNo,globale,max)     }
      if { ! [ info exists conf(psfimcce,$visuNo,saturation)      ] } { set private(psfimcce,$visuNo,saturation)        65000      } else { set private(psfimcce,$visuNo,saturation)      $conf(psfimcce,$visuNo,saturation)      }
      if { ! [ info exists conf(psfimcce,$visuNo,threshold)       ] } { set private(psfimcce,$visuNo,threshold)         3          } else { set private(psfimcce,$visuNo,threshold)       $conf(psfimcce,$visuNo,threshold)       }
      if { ! [ info exists conf(psfimcce,$visuNo,globale)         ] } { set private(psfimcce,$visuNo,globale)           0          } else { set private(psfimcce,$visuNo,globale)         $conf(psfimcce,$visuNo,globale)         }
      if { ! [ info exists conf(psfimcce,$visuNo,ecretage)        ] } { set private(psfimcce,$visuNo,ecretage)          0          } else { set private(psfimcce,$visuNo,ecretage)        $conf(psfimcce,$visuNo,ecretage)        }
      if { ! [ info exists conf(psfimcce,$visuNo,methode)         ] } { set private(psfimcce,$visuNo,methode)           "fitgauss" } else { set private(psfimcce,$visuNo,methode)         $conf(psfimcce,$visuNo,methode)         }
      if { ! [ info exists conf(psfimcce,$visuNo,precision)       ] } { set private(psfimcce,$visuNo,precision)         high       } else { set private(psfimcce,$visuNo,precision)       $conf(psfimcce,$visuNo,precision)       }
      if { ! [ info exists conf(psfimcce,$visuNo,photom,r1)       ] } { set private(psfimcce,$visuNo,photom,r1)         1          } else { set private(psfimcce,$visuNo,photom,r1)       $conf(psfimcce,$visuNo,photom,r1)       }
      if { ! [ info exists conf(psfimcce,$visuNo,photom,r2)       ] } { set private(psfimcce,$visuNo,photom,r2)         2          } else { set private(psfimcce,$visuNo,photom,r2)       $conf(psfimcce,$visuNo,photom,r2)       }
      if { ! [ info exists conf(psfimcce,$visuNo,photom,r3)       ] } { set private(psfimcce,$visuNo,photom,r3)         2.6        } else { set private(psfimcce,$visuNo,photom,r3)       $conf(psfimcce,$visuNo,photom,r3)       }
      if { ! [ info exists conf(psfimcce,$visuNo,marks,cercle)    ] } { set private(psfimcce,$visuNo,marks,cercle)      1          } else { set private(psfimcce,$visuNo,marks,cercle)    $conf(psfimcce,$visuNo,marks,cercle)    }
      if { ! [ info exists conf(psfimcce,$visuNo,globale,arret)   ] } { set private(psfimcce,$visuNo,globale,arret)     1          } else { set private(psfimcce,$visuNo,globale,arret)   $conf(psfimcce,$visuNo,globale,arret)   }
      if { ! [ info exists conf(psfimcce,$visuNo,globale,nberror) ] } { set private(psfimcce,$visuNo,globale,nberror)   3          } else { set private(psfimcce,$visuNo,globale,nberror) $conf(psfimcce,$visuNo,globale,nberror) }

      set private(psfimcce,$visuNo,hcanvas) [::confVisu::getCanvas $visuNo]
      foreach key [get_fields_current_psf] {
         set private(psfimcce,$visuNo,psf,$key) "-"
      }
      set private(psfimcce,$visuNo,duree) ""

   }
