#
# Fichier : aud1.tcl
# Description : Fonctions de chargement/sauvegarde et traitement d'images
# Date de mise a jour : 17 fevrier 2006
#

#
# loadima [filename] [visuNo] [-novisu)
# Chargement d'une image : Sans arguments, ou avec "?" comme nom de fichier, ouvre une fenetre de selection
# avec l'option "-novisu" l'image n'est pas affichee
#
# Exemple :
# loadima                      #--- Ouvre une fenetre de selection, et affiche l'image dans la visu numero 1
# loadima m57                  #--- Charge l'image m57.fit (extension par defaut) et affiche l'image dans la visu numero 1
# loadima n4565.fits           #--- Charge l'image n4565.fits et affiche l'image dans la visu numero 1
# loadima n4565.fits 2         #--- Charge l'image n4565.fits et affiche l'image dans la visu numero 2
# loadima n4565.fits 1 -novisu #--- Charge l'image n4565.fits dans le buffer associe a la visu 1 sans afficher l'image
#
proc loadima { { filename "?" } { visuNo 1 } { affichage "-dovisu" } } {
   global conf
   global audace
   global caption

   #---
   set bufNo [ visu$visuNo buf ]

   #--- Recuperation de l'extension par defaut
   buf$bufNo extension "$conf(extension,defaut)"

   #--- Recuperation de l'information de compression ou non
   if { $conf(fichier,compres) == "1" } {
      buf$bufNo compress gzip
   } else {
      buf$bufNo compress none
   }

   #--- Suppression de la zone selectionnee avec la souris si elle existe
   if { [ lindex [ list [ ::confVisu::getBox $visuNo ] ] 0 ] != "" } {
      ::confVisu::deleteBox $visuNo
   }

   #--- Fenetre parent
   set fenetre [::confVisu::getBase $visuNo]

   if { $filename == "?" } {
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $bufNo "1" $visuNo ]
   } else {
      if {[file pathtype $filename] == "relative"} {
         set filename [file join $audace(rep_images) $filename]
      }
   }

   #---
   if { [ string compare $filename "" ] != "0" } {
      set result [ buf$bufNo load $filename ]
      if { $result == "" } {
         ::confVisu::autovisu $visuNo "-no" "$filename" 
      } else {
         #--- echec du chargement
         ::confVisu::autovisu $visuNo "-novisu"  ""
      }
      
      set calib 1
      if { [string compare [lindex [buf$bufNo getkwd CRPIX1] 0] ""] == 0 } {
         set calib 0
      }
      if { [string compare [lindex [buf$bufNo getkwd CRPIX2] 0] ""] == 0 } {
         set calib 0
      }
      if { [string compare [lindex [buf$bufNo getkwd CRVAL1] 0] ""] == 0 } {
         set calib 0
      }
      if { [string compare [lindex [buf$bufNo getkwd CRVAL2] 0] ""] == 0 } {
         set calib 0
      }
      set classic 0
      set nouveau 0
      if { [string compare [lindex [buf$bufNo getkwd CD1_1] 0] ""] != 0 } {
         incr nouveau
      }
      if { [string compare [lindex [buf$bufNo getkwd CD1_2] 0] ""] != 0 } {
         incr nouveau
      }
      if { [string compare [lindex [buf$bufNo getkwd CD2_1] 0] ""] != 0 } {
         incr nouveau
      }
      if { [string compare [lindex [buf$bufNo getkwd CD2_2] 0] ""] != 0 } {
         incr nouveau
      }
      if { [string compare [lindex [buf$bufNo getkwd CDELT1] 0] ""] != 0 } {
         incr classic
      }
      if { [string compare [lindex [buf$bufNo getkwd CDELT2] 0] ""] != 0 } {
         incr classic
      }
      if { [string compare [lindex [buf$bufNo getkwd CROTA1] 0] ""] != 0 } {
         incr classic
      }
      if { [string compare [lindex [buf$bufNo getkwd CROTA2] 0] ""] != 0 } {
         incr classic
      }
      if {(($calib == 1)&&($nouveau==4))||(($calib == 1)&&($classic>=3))} {
         ::confVisu::setAvailableScale $visuNo "xy_radec"
      } else {
         ::confVisu::setAvailableScale $visuNo "xy"
      }
   }
}

#
# saveima [filename] [visuNo]
# Enregistrement d'une image : Sans arguments, ou avec "?" comme nom de fichier,
# ouvre une fenetre de selection pour demander le nom de fichier
#
# Exemple :
# saveima             #--- Ouvre une fenetre de selection, et affiche l'image
# saveima ?           #--- Idem precedent
# saveima m57         #--- Enregistre l'image sous le nom m57.fit (extension par defaut)
# saveima n4565.fits  #--- Enregistre l'image sous le nom n4565.fits
#
proc saveima { { filename "?" } { visuNo 1 } } {
   global conf
   global audace
   global caption

   #---
   set bufNo [ visu$visuNo buf ]

   #--- On sort immediatement s'il n'y a pas d'image dans le buffer
   if { [ buf$bufNo imageready ] == "0" } {
      return
   }

   #--- Recuperation de l'extension par defaut
   buf$bufNo extension "$conf(extension,defaut)"

   #--- Recuperation de l'information de compression ou non
   if { $conf(fichier,compres) == "1" } {
      buf$bufNo compress gzip
   } else {
      buf$bufNo compress none
   }

   #--- Fenetre parent
   set fenetre [::confVisu::getBase $visuNo]

   if { $filename == "?" } {
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_save $fenetre $audace(rep_images) $bufNo "1" $visuNo ]
   } else {
      if {[file pathtype $filename] == "relative"} {
         set filename [file join $audace(rep_images) $filename]
      }
   }
   if { [ string compare $filename "" ] != "0" } {
      if { [ buf$bufNo imageready ] == "1" } {
         set result [ buf$bufNo save $filename ]
         if { $result == "" } {
            wm title $fenetre "$caption(audace,titre) (visu$visuNo) - $filename"
         }
      }
   }
   return
}

#
# savejpeg [filename]
# Enregistrement d'une image : Sans arguments, ou avec "?" comme nom de fichier,
# ouvre une fenetre de selection pour demander le nom de fichier
#
# Exemple :
# saveima             #--- Ouvre une fenetre de selection, et affiche l'image
# saveima ?           #--- Idem precedent
# saveima m57         #--- Enregistre l'image sous le nom m57.jpg (extension par defaut)
#
proc savejpeg { { filename "?" } } {
   global conf
   global audace
   global caption

   #--- Fenetre parent
   set fenetre "$audace(base)"

   if { $filename == "?" } {
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_save $fenetre $audace(rep_images) $audace(bufNo) "2" ]
   } else {
      if { [ file pathtype $filename ] == "relative" } {
          set filename [ file join $audace(rep_images) $filename ]
      }
   }
   if { [ string compare $filename "" ] != 0 } {
      if { [ buf$audace(bufNo) imageready ] == "1" } {
         if { [ info exists conf(jpegquality,defaut) ] == "0" } {
            set result [ buf$audace(bufNo) savejpeg $filename ]
         } else {
            set quality "$conf(jpegquality,defaut)"
            set err [ catch { set quality [ expr $quality ] } ]
            if { $err == "1" } {
               set quality 80
            }
            set result [ buf$audace(bufNo) savejpeg $filename $quality ]
         }
         if { $result == "" } {
            wm title $audace(base) "$caption(audace,titre) (visu1) - $filename"
         }
      }
   }
   return
}

#------------------------------------------------------------
# visu
# Visualisation du buffer : Eventuellement on peut changer les seuils en passant une liste de
# deux elements entiers, le seuil haut et le seuil bas
#
# Exemple :
# visu
# visu {500 0}
#------------------------------------------------------------
proc visu { { cuts "autocuts" } } {
   global audace

   ::confVisu::visu $audace(visuNo) $cuts 
}

#
# stat
# Renvoie une liste des statistiques de l'image
# Dans l'ordre : hicut, locut, datamax, datamin, mean, sigma, bgmean, bgsigma, contrast
#
# Exemple :
# stat
#
proc stat { } {
   global audace

   buf$audace(bufNo) stat
}

#
# acq exptime binning
# Declenche l'acquisition, et affiche l'image une fois l'acquisition terminee
#
# Exemple :
# acq 10 2
#
proc acq { exptime binning } {
   global audace
   global caption

   #--- Petit raccourci
   set camera cam$audace(camNo)

   #--- La commande exptime permet de fixer le temps de pose de l'image
   $camera exptime $exptime

   #--- La commande bin permet de fixer le binning
   $camera bin [list $binning $binning]

   #--- Declenchement l'acquisition
   $camera acq

   #--- Attente de la fin de la pose
   vwait status_$camera

   #--- Visualisation de l'image
   ::audace::autovisu $audace(visuNo)

   wm title $audace(base) "$caption(audace,image,acquisition) $exptime s"
}

proc statwin { visuNo } {
   global conf
   global audace
   global caption

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
   label $This.lab1 -text "$caption(audace,image,max) [ lindex $valeurs 2 ]"
   pack $This.lab1 -padx 10 -pady 2
   label $This.lab2 -text "$caption(audace,image,min) [ lindex $valeurs 3 ]"
   pack $This.lab2 -padx 10 -pady 2
   label $This.lab3 -text "$caption(audace,image,moyenne:) [ lindex $valeurs 4 ]"
   pack $This.lab3 -padx 10 -pady 2
   label $This.lab4 -text "$caption(image,ecart,type) [ lindex $valeurs 5 ]"
   pack $This.lab4 -padx 10 -pady 2
   label $This.lab5 -text "$caption(moyenne,fond,ciel) [ lindex $valeurs 6 ]"
   pack $This.lab5 -padx 10 -pady 2
   label $This.lab6 -text "$caption(ecart,type,fond) [ lindex $valeurs 7 ]"
   pack $This.lab6 -padx 10 -pady 2
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { $audace(console)::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc fwhm { visuNo } {
   global conf
   global audace
   global caption

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
   label $This.lab1 -text "$caption(audace,fwhm,x) : [ lindex $valeurs 0 ]"
   pack $This.lab1 -padx 10 -pady 2
   label $This.lab2 -text "$caption(audace,fwhm,y) : [ lindex $valeurs 1 ]"
   pack $This.lab2 -padx 10 -pady 2
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { $audace(console)::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc fitgauss { visuNo } {
   global conf
   global audace
   global caption
   global color

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
   set valeurs [ buf[ ::confVisu::getBufNo $visuNo ] fitgauss $box ]
   #--- Cree les etiquettes
   label $This.lab0 -text "Visu$visuNo"
   pack $This.lab0 -padx 10 -pady 2
   ::console::affiche_resultat "Visu$visuNo $caption(audace,title_gauss)\n"
   ::console::affiche_resultat "$caption(audace,coord_box) : $box\n"
   set texte "$caption(audace,center,xy) : [ format "%.2f" [ lindex $valeurs 1 ] ] / [ format "%.2f" [ lindex $valeurs 5 ] ]"
   ::console::affiche_resultat "$texte\n"
   label $This.lab1 -text "$texte"
   pack $This.lab1 -padx 10 -pady 2
   set texte "$caption(audace,fwhm,xy) : [ format "%.3f" [ lindex $valeurs 2 ] ] / [ format "%.3f" [ lindex $valeurs 6 ] ]"
   ::console::affiche_resultat "$texte\n"
   label $This.lab2 -text "$texte"
   pack $This.lab2 -padx 10 -pady 2
   set texte "$caption(audace,intens,xy) : [ format "%f" [ lindex $valeurs 0 ] ] / [ format "%f" [ lindex $valeurs 4 ] ]"
   ::console::affiche_resultat "$texte\n"
   label $This.lab3 -text "$texte"
   pack $This.lab3 -padx 10 -pady 2
   set texte "$caption(audace,back,xy) : [ format "%f" [ lindex $valeurs 3 ] ] / [ format "%f" [ lindex $valeurs 7 ] ]"
   ::console::affiche_resultat "$texte\n"
   label $This.lab4 -text "$texte"
   pack $This.lab4 -padx 10 -pady 2
   set if0 [ expr [ lindex $valeurs 2 ]*[ lindex $valeurs 6 ]*.601*.601*3.14159265 ]
   set if1 [ expr [ lindex $valeurs 0 ]*$if0 ]
   set if2 [ expr [ lindex $valeurs 4 ]*$if0 ]
   set if0 [ expr ($if1+$if2)/2. ]
   set dif [ expr abs($if1-$if0) ]
   set texte "$caption(audace,integflux) : $if0 +/- $dif"
   ::console::affiche_resultat "$texte\n"
   label $This.lab5 -text "$texte"
   pack $This.lab5 -padx 10 -pady 2
   set mag1 [ expr -2.5*log10($if0+$dif) ]
   set mag2 [ expr -2.5*log10($if0-$dif) ]
   set mag0 [ expr ($mag1+$mag2)/2. ]
   set dmag [ expr abs($mag1-$mag0) ]
   set texte "$caption(audace,mag_instrument) : [ format %6.3f $mag0 ] +/- [ format %6.3f $dmag ]"
   ::console::affiche_resultat "$texte\n"
   if { [ $base.fra1.labURLX cget -fg ] == "$color(blue)" } {
      set radec [ buf[ ::confVisu::getBufNo $visuNo ] xy2radec [ list [ lindex $valeurs 1 ] [ lindex $valeurs 5 ] ] ]
      set ra [ lindex $radec 0 ]
      set dec [ lindex $radec 1 ]
      set rah [ mc_angle2hms $ra 360 zero 2 auto string ]
      set decd [ mc_angle2dms $dec 90 zero 2 + string ]
      set texte "$caption(caractere,RA) $caption(caractere,DEC) : $ra $dec"
      ::console::affiche_resultat "$texte\n"
      set texte "$caption(caractere,RA) $caption(caractere,DEC) : $rah $decd"
      ::console::affiche_resultat "$texte\n"
      # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
      #    Rab101    C2003 10 18.89848 01 33 53.74 +02 27 19.3          18.6        xxx
      #--- C2003 10 18.89848 : Indique la date du milieu de la pose pour l'image
      #--- (annee, mois, jour decimal --> qui permet d'avoir l'heure du milieu de la pose a la seconde pres)
      set mpc "$caption(audace,MPC_format)\n     .        C"
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
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "$mpc\n"
      #---
      if { $xxx != "xxx" } {
         ::console::affiche_erreur "$caption(audace,boite,attention)\n"
         ::console::affiche_erreur "[eval [concat {format} { $caption(audace,UAI_site_image) $conf(posobs,station_uai) } ] ]\n"
      }
   }
   ::console::affiche_resultat "\n\n"
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { $audace(console)::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc center { visuNo } {
   global conf
   global audace
   global caption

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
   label $This.lab1 -text "$caption(audace,center,xy) : ( [ format "%.2f" [ lindex $valeurs 0 ] ] / [ format "%.2f" [ lindex $valeurs 1 ] ] )"
   pack $This.lab1 -padx 10 -pady 2
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { $audace(console)::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

proc photom { visuNo } {
   global conf
   global audace
   global caption

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
   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { $audace(console)::GiveFocus }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

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

proc offset { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) offset [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: offset val"
   }
}

proc mult { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) mult [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mult val"
   }
}

proc noffset { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) noffset [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: noffset val"
   }
}

proc ngain { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) ngain [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: ngain val"
   }
}

proc add { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) add [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: add image val"
   }
}

proc sub { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) sub [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: sub image val"
   }
}

proc div { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) div [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: div image val"
   }
}

proc opt { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) opt [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: opt dark offset"
   }
}

proc deconvflat { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) unsmear [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: deconvflat coef"
   }
}

proc rot { args } {
   global audace

   if {[llength $args] == 3} {
      buf$audace(bufNo) rot [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: rot x0 y0 angle"
   }
}

proc log { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) log [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 3} {
      buf$audace(bufNo) log [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: log coef ?offset?"
   }
}

proc binx { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) binx [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 3} {
      buf$audace(bufNo) binx [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: binx x1 x2 ?width?"
   }
}

proc biny { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) biny [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 3} {
      buf$audace(bufNo) biny [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: biny y1 y2 ?height?"
   }
}

proc window { { args "" } } {
   global audace
   global caption

   if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] != "" } {
      if {$args == ""} {
         set args [ list [ ::confVisu::getBox $audace(visuNo) ] ]
      }
      if {[llength $args] == 1} {
         buf$audace(bufNo) window [lindex $args 0]
         ::confVisu::deleteBox $audace(visuNo)
         ::audace::autovisu $audace(visuNo)
      } else {
         error "Usage: window {x1 y1 x2 y2}"
      }
   } else {
      tk_messageBox -title $caption(audace,boite,attention) -type ok -message $caption(audace,boite,tracer)
   }
}

proc clipmin { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) clipmin [lindex $args 0]
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: clipmin value"
   }
}

proc clipmax { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) clipmax [lindex $args 0]
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: clipmax value"
   }
}

proc resample { args } {
   global audace

   if {[llength $args] >= 1} {
      if {[llength $args] >= 2} {
         buf$audace(bufNo) scale [ list [lindex $args 0] [lindex $args 1] ]
      } else {
         buf$audace(bufNo) scale [lindex $args 0] 1
      }
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: resample Factor_x Factor_y ?NormaFlux?"
   }
}

proc mirrorx { args } {
   global audace

   if {[llength $args] == 0} {
      buf$audace(bufNo) mirrorx
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mirrorx"
   }
}

proc mirrory { args } {
   global audace

   if {[llength $args] == 0} {
      buf$audace(bufNo) mirrory
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mirrory"
   }
}

#
# delete2 in nb
# Deletes files from $in1 to $in$nb
#
# Exemple : delete2 i 3 --> deletes files i1.fit, i2.fit, i3.fit
#
proc delete2 { args } {
   global conf
   global audace

   #--- Recuperation de l'extension par defaut
   buf$audace(bufNo) extension "$conf(extension,defaut)"
   set ext [buf$audace(bufNo) extension]

   if {[llength $args] == 2} {
      set in [lindex $args 0]
      set nb [lindex $args 1]
      for {set i 1} {$i <= $nb} {incr i} {file delete -force $in$i$ext}
   } else {
      error "Usage: delete2 in nb"
   }
}

#
# extract_flat in dark offset out nb
# Computes a flat from night sky images, requires CCD dark and offset clean frames
#
# Exemple : extract_flat sky drk off flat 5
# -> extracts flat.fit from the images sky1.fit to sky5.fit using drk.fit and off.fit as dark and
#    offset maps. Temporary files named flat-tmp-1.fit to flat-tmp-5.fit are generated and deleted
#
proc extract_flat { args } {
   if {[llength $args] == 5} {
      set in [lindex $args 0]
      set dark [lindex $args 1]
      set offset [lindex $args 2]
      set out [lindex $args 3]
      set nb [lindex $args 4]
      #---
      set tmp "$out-tmp-"; #--- Temporary files prototype
      opt2 $in $dark $offset $tmp $nb
      ngain2 $tmp $tmp 10000 $nb
      smedian $tmp $out $nb
      delete2 $tmp $nb
   } else {
      error "Usage: extract_flat in dark offset out nb"
   }
}

#
# fitsdate
# Renvoie la date courante au format FITS
#
proc fitsdate { args } {
   if {[llength $args] == 0} {
      clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S.00"
   } else {
      error "Usage: fitsdate"
   }
}

proc dir { { rgxp "*" } } {
   set res [glob $rgxp]
   set maxlen 0
   foreach elem $res {
      if {[string length $elem]>$maxlen} {
   set maxlen [string length $elem]
      }
   }
   foreach elem $res {
      if {[file isdirectory $elem]} {
   set comment "<DIR>"
      } else {
   set comment "([file size $elem])"
      }
      ::console::affiche_resultat [format "%-[subst $maxlen]s  %s\n" $elem $comment]
   }
}

proc animate { filename nb {millisecondes 200} {nbtours 10} } {
   #--- filename : Nom generique des fichiers filename*.fit a animer
   #--- nb : Nombre d'images (1 a nb)
   #--- millisecondes : Timer entre chaque image affichee
   #--- nbtours : Nombre de boucles sur les nb images
   #
   global conf
   global audace

   set len [string length $conf(rep_images)]
   set folder "$conf(rep_images)"
   if {$len>"0"} {
      set car [string index "$conf(rep_images)" [expr $len-1]]
      if {$car!="/"} {
         append folder "/"
      }
   }
   set basecanvas $audace(base).can1.canvas
   #--- Je sauvegarde le numero de l'image associe à la visu
   set imageNo [visu$audace(visuNo) image]
   #--- On va creer nb zones de visu a partir de 101
   set off 100
   #--- Cree les visu et les Tk_photoimage
   for {set k 1} {$k<=$nb} {incr k} {
      set kk [expr $k+$off]
      #--- Cree l'image si elle n'existe pas et l'associe a la visu
      visu$audace(visuNo) image $kk
      buf$audace(bufNo) load "$folder$filename$k"
      #--- Affiche l'image associee a la visu
      ::audace::autovisu $audace(visuNo)
   }
   #--- Animation
   for {set t 1} {$t<=$nbtours} {incr t} {
      for {set k 1} {$k<=$nb} {incr k} {
         set kk [expr $k+$off]
         $basecanvas itemconfigure display -image image$kk
         #--- Change l'image associee a la visu
         visu$audace(visuNo) image $kk
         update
         after $millisecondes
      }
   }
   #--- Detruit les Tk_photoimage
   for {set k 1} {$k<=$nb} {incr k} {
      set kk [expr $k+$off]
      image delete image$kk
   }
   #--- Reconfigure pour Aud'ACE normal
   $basecanvas itemconfigure display -image image$imageNo
   update
   #--- Je restaure le numero de l'image associe a la visu
   visu$audace(visuNo) image $imageNo
   buf$audace(bufNo) load $folder${filename}1
   ::audace::autovisu $audace(visuNo)
}

