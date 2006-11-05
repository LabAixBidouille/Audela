#
# Fichier : aud1.tcl
# Description : Fonctions de chargement/sauvegarde et traitement d'images
# Mise a jour $Id: aud1.tcl,v 1.20 2006-11-05 07:43:32 robertdelmas Exp $
#

#
# loadima [filename] [visuNo] [-novisu)
# Chargement d'une image : Sans argument, ou avec "?" comme nom de fichier,
# ouvre une fenetre de selection pour demander le nom de fichier,
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
   global audace conf

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
         #--- Echec du chargement
         ::confVisu::autovisu $visuNo "-novisu" ""
      }
      #---
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
# Enregistrement d'une image : Sans argument, ou avec "?" comme nom de fichier,
# ouvre une fenetre de selection pour demander le nom de fichier
#
# Exemple :
# saveima             #--- Ouvre une fenetre de selection, et affiche l'image
# saveima ?           #--- Idem precedent
# saveima m57         #--- Enregistre l'image sous le nom m57.fit (extension par defaut)
# saveima n4565.fits  #--- Enregistre l'image sous le nom n4565.fits
#
proc saveima { { filename "?" } { visuNo 1 } } {
   global audace caption conf

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

   #--- J'affecte au buffer les seuils de la visu
   if { $conf(save_seuils_visu) == "1" } {
      set cuts [visu$visuNo cut]
      buf$bufNo setkwd [list "MIPS-HI" [lindex $cuts 0] float "" ""]
      buf$bufNo setkwd [list "MIPS-LO" [lindex $cuts 1] float "" ""]
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
# Enregistrement d'une image : Sans argument, ou avec "?" comme nom de fichier,
# ouvre une fenetre de selection pour demander le nom de fichier
#
# Exemple :
# saveima             #--- Ouvre une fenetre de selection, et affiche l'image
# saveima ?           #--- Idem precedent
# saveima m57         #--- Enregistre l'image sous le nom m57.jpg (extension par defaut)
#
proc savejpeg { { filename "?" } } {
   global audace caption conf

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

   if {[llength $args] == 1} {
      buf$audace(bufNo) log [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } elseif {[llength $args] == 2} {
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
   #--- filename : Nom generique des fichiers image filename*.fit a animer
   #--- nb : Nombre d'images (1 a nb)
   #--- millisecondes : Temps entre chaque image affichee
   #--- nbtours : Nombre de boucles sur les nb images
   #
   global conf
   global audace

   #--- Repertoire des images
   set len [ string length $conf(rep_images) ]
   set folder "$conf(rep_images)"
   if { $len > "0" } {
      set car [ string index "$conf(rep_images)" [ expr $len-1 ] ]
      if { $car != "/" } {
         append folder "/"
      }
   }

   #--- Je sauvegarde le canvas
   set basecanvas $audace(base).can1.canvas

   #--- Je sauvegarde le numero de l'image associe a la visu
   set imageNo [visu$audace(visuNo) image]

   #--- Initialisation des visu
   set off 100

   #--- Creation de nb visu a partir de la visu numero 101 (100 + 1) et des Tk_photoimage
   for {set k 1} {$k<=$nb} {incr k} {
      set kk [expr $k+$off]
      #--- Creation de l'image et association a la visu
      visu$audace(visuNo) image $kk
      #--- Affichage de l'image avec gestion des erreurs
      set error [ catch { buf$audace(bufNo) load "$folder$filename$k" } msg ]
      ::audace::autovisu $audace(visuNo)
   }

   #--- Animation
   if { $error == "0" } {
      for {set t 1} {$t<=$nbtours} {incr t} {
         for {set k 1} {$k<=$nb} {incr k} {
            set kk [expr $k+$off]
            $basecanvas itemconfigure display -image image$kk
            #--- Chargement de l'image associee a la visu
            visu$audace(visuNo) image $kk
            update
            after $millisecondes
         }
      }
   }

   #--- Destruction des Tk_photoimage
   for {set k 1} {$k<=$nb} {incr k} {
      set kk [expr $k+$off]
      image delete image$kk
   }

   #--- Reconfiguration pour Aud'ACE normal
   $basecanvas itemconfigure display -image image$imageNo
   update

   #--- Restauration du numero de l'image associe a la visu
   visu$audace(visuNo) image $imageNo

   #--- Affichage de la premiere image de l'animation si elle existe
   if { $error == "0" } {
      buf$audace(bufNo) load "$folder${filename}1"
      ::audace::autovisu $audace(visuNo)
   }

   #--- Variable error pour la gestion des erreurs
   return $error

}

