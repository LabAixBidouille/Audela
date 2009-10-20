#
# Fichier : aud_proc.tcl
# Description : Fonctions de chargement, sauvegarde et traitement d'images
# Mise a jour $Id: aud_proc.tcl,v 1.11 2009-10-20 16:07:14 robertdelmas Exp $
#

#
# loadima [filename] [visuNo] [affichage]
# Chargement d'une image : Sans argument, ou avec "?" comme nom de fichier,
# ouvre une fenetre de selection pour demander le nom de fichier,
# avec l'option "-novisu" l'image n'est pas affichee
#
# return
#   nom du fichier si le chargement est OK
#   ""  si le chargement n'est pas fait
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
   set result ""

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
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $bufNo "1" $visuNo ]
   } else {
      if {[file pathtype $filename] == "relative"} {
         set filename [file join $audace(rep_images) $filename]
      }
   }

   #---
   if { [ string compare $filename "" ] != "0" } {
      ::confVisu::autovisu $visuNo "-no" $filename
      ###set result [ buf$bufNo load $filename ]
      ###if { $result == "" } {
      ###   ::confVisu::autovisu $visuNo "-no" $filename
      ###   ##::confVisu::setFileName $visuNo  $filename
      ###} else {
      ###   #--- Echec du chargement
      ###   ::confVisu::autovisu $visuNo "-novisu" "$filename"
      ###   ##::confVisu::setFileName $visuNo ""
      ###}

      ####--- Suppression de la zone selectionnee avec la souris si elle est hors de l'image
      ###if { [ lindex [ list [ ::confVisu::getBox $visuNo ] ] 0 ] != "" } {
      ###   set box [ ::confVisu::getBox $visuNo ]
      ###   set x1 [lindex  [confVisu::getBox $visuNo ] 0]
      ###   set y1 [lindex  [confVisu::getBox $visuNo ] 1]
      ###   set x2 [lindex  [confVisu::getBox $visuNo ] 2]
      ###   set y2 [lindex  [confVisu::getBox $visuNo ] 3]
      ###   if { $x1 > $::confVisu::private($visuNo,picture_w)
      ###     || $y1 > $::confVisu::private($visuNo,picture_h)
      ###     || $y2 > $::confVisu::private($visuNo,picture_w)
      ###     || $y2 > $::confVisu::private($visuNo,picture_h) } {
      ###      ::confVisu::deleteBox $visuNo
      ###   }
      ###}


      ####---
      ###set calib 1
      ###if { [string compare [lindex [buf$bufNo getkwd CRPIX1] 0] ""] == 0 } {
      ###   set calib 0
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CRPIX2] 0] ""] == 0 } {
      ###   set calib 0
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CRVAL1] 0] ""] == 0 } {
      ###   set calib 0
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CRVAL2] 0] ""] == 0 } {
      ###   set calib 0
      ###}
      ###set classic 0
      ###set nouveau 0
      ###if { [string compare [lindex [buf$bufNo getkwd CD1_1] 0] ""] != 0 } {
      ###   incr nouveau
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CD1_2] 0] ""] != 0 } {
      ###   incr nouveau
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CD2_1] 0] ""] != 0 } {
      ###   incr nouveau
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CD2_2] 0] ""] != 0 } {
      ###   incr nouveau
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CDELT1] 0] ""] != 0 } {
      ###   incr classic
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CDELT2] 0] ""] != 0 } {
      ###   incr classic
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CROTA1] 0] ""] != 0 } {
      ###   incr classic
      ###}
      ###if { [string compare [lindex [buf$bufNo getkwd CROTA2] 0] ""] != 0 } {
      ###   incr classic
      ###}
      ###if {(($calib == 1)&&($nouveau==4))||(($calib == 1)&&($classic>=3))} {
      ###   ::confVisu::setAvailableScale $visuNo "xy_radec"
      ###} else {
      ###   ::confVisu::setAvailableScale $visuNo "xy"
      ###}
   } else {
      set result ""
   }

   return ""
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

   #--- On sort immediatement s'il n'y a pas de nom pour l'image
   #--- Le menu 'Enregistrer' ne fonctionne que si on a charge
   #--- prealablement une premiere image avec le menu 'Charger'
   if { $filename == "" } {
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

   #--- J'affecte au buffer les seuils initiaux
   if { $conf(save_seuils_visu) == "0" } {
      set tmp_sh [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ]
      set tmp_sb [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ]
      buf$bufNo initialcut
   }

   #--- Je memorise les seuils initiaux dans des mots cles specifiques a chaque plan couleur
   if { [ lindex [ buf$audace(bufNo) getkwd NAXIS ] 1 ] == "3" } {
      #--- J'identifie les seuils de visualisation
      set listSeuils [ visu$audace(visuNo) cut ]
      set tmp_shR [ lindex $listSeuils 0 ]
      set tmp_sbR [ lindex $listSeuils 1 ]
      set tmp_shG [ lindex $listSeuils 2 ]
      set tmp_sbG [ lindex $listSeuils 3 ]
      set tmp_shB [ lindex $listSeuils 4 ]
      set tmp_sbB [ lindex $listSeuils 5 ]
      #--- Je les memorise dans des mots cles specifique a chaque plan couleur
      buf$bufNo setkwd [ list "MIPS-HIR" $tmp_shR float "Red Hight Cut" "ADU" ]
      buf$bufNo setkwd [ list "MIPS-LOR" $tmp_sbR float "Red Low Cut" "ADU" ]
      buf$bufNo setkwd [ list "MIPS-HIG" $tmp_shG float "Green Hight Cut" "ADU" ]
      buf$bufNo setkwd [ list "MIPS-LOG" $tmp_sbG float "Green Low Cut" "ADU" ]
      buf$bufNo setkwd [ list "MIPS-HIB" $tmp_shB float "Blue Hight Cut" "ADU" ]
      buf$bufNo setkwd [ list "MIPS-LOB" $tmp_sbB float "Blue Low Cut" "ADU" ]
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
      #--- je met a jour le nom du fichier dans confvisu
      ::confVisu::setFileName $visuNo "$filename"
   }

   #--- J'affecte au buffer les seuils de la visu
   if { $conf(save_seuils_visu) == "0" } {
      buf$bufNo setkwd [ list "MIPS-HI" $tmp_sh float "" "" ]
      buf$bufNo setkwd [ list "MIPS-LO" $tmp_sb float "" "" ]
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

#
# visu [cuts]
# Visualisation du buffer : Eventuellement on peut changer les seuils en passant
# une liste de deux elements entiers par plan image, le seuil haut et le seuil bas
# liste de 2 elements pour une image naxis 2 et de 6 elements pour une image naxis 3
#
# Exemple :
# visu
# visu {500 0}
#
proc visu { { cuts "autocuts" } } {
   global audace

   ::confVisu::visu $audace(visuNo) $cuts
}

#
# stat
# Renvoie une liste des statistiques de l'image
# Dans l'ordre : hicut, locut, datamax, datamin, mean, sigma, bgmean, bgsigma et contrast
#
proc stat { } {
   global audace

   buf$audace(bufNo) stat
}

#
# offset value
# Realise un offset sur l'image, tous les pixels de l'image sont decales de value
#
proc offset { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) offset [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: offset value"
   }
}

#
# mult value
# Multiplie tous les pixels de l'image en memoire par la valeur value
#
proc mult { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) mult [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mult value"
   }
}

#
# noffset value
# Normalise le fond du ciel par un offset a la valeur value
#
proc noffset { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) noffset [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: noffset value"
   }
}

#
# ngain value
# Normalise le fond du ciel a la valeur value
#
proc ngain { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) ngain [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: ngain value"
   }
}

#
# add image value
# Ajoute l'image contenue dans fichier a l'image du buffer et ajoute un offset de valeur value
#
proc add { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) add [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: add image value"
   }
}

#
# sub image value
# Soustrait l'image contenue dans image a l'image du buffer et ajoute un offset de valeur value
#
proc sub { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) sub [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: sub image value"
   }
}

#
# div image value
# Divise l'image courante par l'image contenue dans le fichier nom,
# et multiplie par la constante numerique value
#
proc div { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) div [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: div image value"
   }
}

#
# opt dark offset
# Optimise le noir sur le buffer
#
proc opt { args } {
   global audace

   if {[llength $args] == 2} {
      buf$audace(bufNo) opt [lindex $args 0] [lindex $args 1]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: opt dark offset"
   }
}

#
# deconvflat coef
# Retire l'effet de smearing d'une image
# Le coefficient coef correspond au rapport du temps de lecture d'une
# ligne par rapport a l'image entiere
#
proc deconvflat { args } {
   global audace

   if {[llength $args] == 1} {
      buf$audace(bufNo) unsmear [lindex $args 0]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: deconvflat coef"
   }
}

#
# rot x0 y0 angle
# Rotation de l'image autour du centre (x0,y0) et d'un angle angle en degres decimaux
#
proc rot { args } {
   global audace

   if {[llength $args] == 3} {
      buf$audace(bufNo) rot [lindex $args 0] [lindex $args 1] [lindex $args 2]
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: rot x0 y0 angle"
   }
}

#
# log coef [offset]
# Applique une transformation logarithmique a l'image
#
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

#
# binx x1 x2 [width]
# Cree une nouvelle image de dimensions width*NAXIS2 dont toutes les colonnes sont identiques
# et egales a la somme de toutes les colonnes comprises entre les abscisses x1 et x2 de l'image
#
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

#
# biny y1 y2 [height]
# Cree une nouvelle image de dimensions height*NAXIS1 dont toutes les lignes sont identiques
# et egales a la somme de toutes les lignes comprises entre les ordonnées y1 et y2 de l'image
#
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

#
# window
# Extrait une sous-image de l'image du buffer
# L'argument est une liste de quatre valeurs numeriques indiquant les coordonnees
# de deux des coins opposes : [list $x1 $y1 $x2 $y2]
#
proc window { { args "" } } {
   global audace caption

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
      tk_messageBox -title $caption(confVisu,attention) -type ok -message $caption(confVisu,tracer_boite)
   }
}

#
# clipmin value
# Remplace toutes les valeurs inferieures a value par value (ecretage)
#
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

#
# clipmax value
# Remplace toutes les valeurs superieures a value par value (ecretage)
#
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

#
# resample Factor_x Factor_y [NormaFlux]
# Reechantillonne (bilineaire) l'image en tenant compte de facteurs d'echelle sur chaque axe
#
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

#
# mirrorx
# Retourne l'image par un effet de miroir horizontal
#
proc mirrorx { args } {
   global audace

   if {[llength $args] == 0} {
      buf$audace(bufNo) mirrorx
      ::audace::autovisu $audace(visuNo)
   } else {
      error "Usage: mirrorx"
   }
}

#
# mirrory
# Retourne l'image par un effet de miroir vertical
#
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
# Supprime les fichiers de $in1 a $in$nb
#
# Exemple :
# delete2 i 3 --> Supprime les fichiers i1.fit, i2.fit et i3.fit
#
proc delete2 { args } {
   global audace conf

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
# Calcule un flat directement a partir des images de la nuit
# Il est necessaire d'avoir un offset et un noir
#
# Exemple :
# extract_flat sky dark offset flat 5
# Extrait une image flat.fit des 5 images sky1.fit to sky5.fit en utilisant
# un noir dark.fit et un offset off.fit
# Temporairement les fichiers flat-tmp-1.fit a flat-tmp-5.fit sont crees puis supprimes
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

#
# dir [rgxp]
# Liste le contenu d'un repertoire, telle la commande DOS DIR
# Pour lister les images du sous repertoire nuit, il faut utiliser
# la commande "dir nuit/*.fit"
#
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

#
# animate filename nb [millisecondes] [nbtours] [liste_index]
# Creation d'animation d'images
# filename      : Nom generique des fichiers image filename*.fit a animer
# nb            : Nombre d'images (1 a nb)
# millisecondes : Temps entre chaque image affichee
# nbtours       : Nombre de boucles sur les nb images
# liste_index   : Liste des index des nb images
#
proc animate { filename nb {millisecondes 200} {nbtours 10} {liste_index ""} } {
   global audace

   #--- Repertoire des images
   set len [ string length $audace(rep_images) ]
   set folder "$audace(rep_images)"
   if { $len > "0" } {
      set car [ string index "$audace(rep_images)" [ expr $len-1 ] ]
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
      set index [ lindex $liste_index [ expr $k - 1 ] ]
      set kk [expr $k+$off]
      #--- Creation de l'image et association a la visu
      visu$audace(visuNo) image $kk
      #--- Affichage de l'image avec gestion des erreurs
      set error [ catch { buf$audace(bufNo) load "$folder$filename$index" } msg ]
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
      set index1 [ lindex $liste_index 0 ]
      buf$audace(bufNo) load "$folder${filename}$index1"
      ::audace::autovisu $audace(visuNo)
   }

   #--- Variable error pour la gestion des erreurs
   return $error
}

