
# Procedures des traitements géométriques
# source $audace(rep_scripts)/spcaudace/spc_geom.tcl


####################################################################
# Procedure de rotation de 180° d'un profil de raies ou d'une image
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits du profil de raie spatial
####################################################################

proc spc_rot180 { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	buf$audace(bufNo) mirrorx
	#visu
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_flip$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_flip$conf(extension,defaut).\n"
    } else {
	::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n\n"
    }
}
#****************************************************************************


####################################################################
# Procedure de rotation d'un angle alpha d'un spectre spatial 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits de l'image, coordonnées de 2 points pris sur l'axe incliné à redresser horizontalement 
# A faire : determiner le photocentre autour des points M1 et M2 choisis.
####################################################################

proc spc_tilt { args } {
#proc spc_tilt { { filenamespc ""} { x1 ""} { y1 ""} { x2 ""} { y2 ""} } 

  global audace
  global conf
  set pi [expr acos(-1.0)]
  #--- Les angles pour les oprations trigonometriques sont en degres.

  if {[llength $args] == 5} {
    set filenamespc [ lindex $args 0 ]
    set x1 [ lindex $args 1 ]
    set y1 [ lindex $args 2 ]
    set x2 [ lindex $args 3 ]
    set y2 [ lindex $args 4 ]

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
    set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]

    if { $x1 < $x2 } {
    #--- Point M1 à gauche de M2
	#set xinf $x1
	set yinf $y1
	set angle [expr 180/$pi*atan(1.0*($y1-$y2)/($x2-$x1))]
    } else {
    #--- Point M1 à droite de M2
	#set xinf $x2
	set yinf $y2
	set angle [expr 180/$pi*atan(1.0*($y2-$y1)/($x1-$x2))]
    }

    #--- Angles>0 vers le haut de l'image
    set xinf 1
    #set newnaxis2 [expr $naxis2+int($naxis1*abs(tan($angle*$pi/180)))+1]
    #buf$audace(bufNo) setkwd [list "NAXIS2" "$newnaxis2" int "" ""]
    buf$audace(bufNo) rot $xinf $yinf $angle
    ::console::affiche_resultat "Rotation d'angle ${angle}° autour de ($xinf,$yinf).\n"

    #--- Visualisation du resultat
    #visu
    set listeseuils [buf$audace(bufNo) autocuts]
    set seuilb [expr 0.5*[lindex $listeseuils 0]]
    set seuilh [lindex $listeseuils 0]
    set seuils [list $seuilh $seuilb]
    #visu1 cut $seuils

    #--- Modification du nom du fichier de sortie
    set filespc [ file rootname $filenamespc ]
    buf$audace(bufNo) save "$audace(rep_images)/${filespc}_tilt$conf(extension,defaut)"
    #loadima ${filespc}_tilt$conf(extension,defaut)
    ::console::affiche_resultat "Image sauvée sous ${filespc}_tilt$conf(extension,defaut).\n"
  } else {
     ::console::affiche_erreur "Usage: spc_tilt fichier_fits x1 y1 x2 y2 (pris sur le spectre)\n\n"
  }
}
#****************************************************************************



####################################################################
# Correction géométrique du "spc_smile" d'un spectre spatial 2D
#  (déformation en courbure)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 21-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits de l'image, coordonnées de 3 points pris sur l'axe curvé à redresser horizontalement 
# A faire : determiner le photocentre autour des points M1, M2 et M3 choisis.
####################################################################

proc spc_smile { args } {
  global audace
  global conf

  if {[llength $args] == 7} {
    set filenamespc [ lindex $args 0 ]
    set x1 [ lindex $args 1 ]
    set y1 [ lindex $args 2 ]
    set x2 [ lindex $args 3 ]
    set y2 [ lindex $args 4 ]
    set x3 [ lindex $args 5 ]
    set y3 [ lindex $args 6 ]

    set listecoefs [ pil2 $x1 $y1 $x2 $y2 $x3 $y3 ]
    set a [ lindex $listecoefs 0 ]
    set b [ lindex $listecoefs 1 ]
    set c [ lindex $listecoefs 2 ]

    # Calcul des coordonnées du point extremum de la parabole
    set xextrem [ expr -1.0*$b/(2*$a) ]
    set yextrem [ expr ($b^2*($a-2)+4*$a*$c)/(4*$a) ]

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
    set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]

    # A TERMINER
  } else {
    ::console::affiche_erreur "Usage: spc_smile fichier_fits x1 y1 x2 y2 x3 y3 (pris sur le spectre)\n\n"
  }
}
#****************************************************************************



####################################################################
#  Procedure de registration de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 27-12-2005
# Arguments : nom générique des fichiers .fit dont la forme est nom-n°.fit
####################################################################

proc spc_register { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
       set filename [ lindex $args 0 ]
       # Détection fragile : * doit etre un nombre de 0 a n. glob -nocomplain ?
       set fileliste [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ]
       set nb_file [ llength $fileliste ]
       set fichier1 [ lindex $fileliste 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list 1 1 3 $naxis2 ]
       set ycoords ""
       set k 0
       set kk 1

       #::console::affiche_resultat "Liste : $fileliste\n"
       # Effectue le binning des colonnes et détermine le centroïde en Y du spectre 2D
       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) binx 1 $naxis1 3
	   set ycentre [lindex [buf$audace(bufNo) centro $windowcoords] 1]
	   lappend ycoords $ycentre
       }
       
       # Recale chaque spectre 2D verticalement par rapport au premier
       ::console::affiche_resultat "Recalage de $nb_file images..."
       set ycentre [ lindex $ycoords 0 ]
       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   set yi [ lindex $ycoords $k ]
	   set dy [ expr $ycentre-$yi ]
	   trans 0 $dy
	   set nomfichierlg [ file rootname $fichier ]
	   regexp {(.+)\-[0-9]+} $nomfichierlg match nomfichier
	   buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_r-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr k
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous ${nomfichier}_r-x$conf(extension,defaut)\n"
       return ${nomfichier}_r-
   } else {
       ::console::affiche_erreur "Usage: spc_register nom_générique_fichiers\n\n"
   }
}
####################################################################


####################################################################
#  Procedure de rotation automatique de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 29-10-2005/27-12-2005
# Arguments : fichier .fit
# Heuristique : si l'angle est supérieur a 6°, l'angle calculé ne correspond pas à la réalité de l'inclinaison du spectre.
####################################################################

proc spc_tiltauto { args } {
   global audace
   global conf
   set pi [expr acos(-1.0)]

   if {[llength $args] == 1} {
       set filename [ lindex $args 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set largeur [ expr $naxis1/100 ]
       set windowcoords [ list 1 1 3 $naxis2 ]

       ## Binning des colonnes à l'extrême gauche de l'image
       buf$audace(bufNo) binx [expr $largeur+1] [expr 2*$largeur] 3
       set x1 [ expr int(1.5*$largeur) ]
       set y1 [lindex [buf$audace(bufNo) centro $windowcoords] 1]

       ## Binning des colonnes à l'extrême droite de l'image
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       buf$audace(bufNo) binx [expr $naxis1-2*$largeur] [expr $naxis1-$largeur] 3
       set x2 [ expr int($naxis1-1.5*$largeur) ]
       set y2 [lindex [buf$audace(bufNo) centro $windowcoords] 1]

       ## Effectue la rotation
       # Angles>0 vers le haut de l'image
       set angle [expr 180/$pi*atan(1.0*($y1-$y2)/($x2-$x1))]
       ## Si l'angle est supérieur a 6°, l'angle calculé ne correspond pas à la réalité de l'inclinaison du spectre
       if { $angle <= 6 } {
	   set yinf [ expr int(0.5*($y1+$y2)) ]
	   set xinf [ expr int($naxis1/2) ] 
	   buf$audace(bufNo) load "$audace(rep_images)/$filename"
	   #set newnaxis2 [expr $naxis2+int($naxis1*abs(tan($angle*$pi/180)))+1]
	   #buf$audace(bufNo) setkwd [list "NAXIS2" "$newnaxis2" int "" ""]
	   buf$audace(bufNo) rot $xinf $yinf $angle
	   ::console::affiche_resultat "Rotation d'angle ${angle}° autour de ($xinf,$yinf).\n"
	   #-- Modification du nom du fichier de sortie
	   set filespc [ file rootname $filename ]
	   buf$audace(bufNo) save "$audace(rep_images)/${filespc}_tilt$conf(extension,defaut)"
	   #loadima ${filespc}_tilt$conf(extension,defaut)
	   ::console::affiche_resultat "Image sauvée sous ${filespc}_tilt$conf(extension,defaut).\n"
	   return ${filespc}_tilt
       } else {
	   ::console::affiche_resultat "Rotation d'angle 0° car angle=$angle est érroné.\n"
	   #-- Modification du nom du fichier de sortie
	   set filespc [ file rootname $filename ]
	   buf$audace(bufNo) save "$audace(rep_images)/${filespc}_tilt0$conf(extension,defaut)"
	   #loadima ${filespc}_tilt0$conf(extension,defaut)
	   ::console::affiche_resultat "Image sauvée sous ${filespc}_tilt0$conf(extension,defaut).\n"
	   return ${filespc}_tilt0
       }
   } else {
       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
   }
}
####################################################################


####################################################################
#  Procedure de decoupage d'une tranche horizontale pour une série d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 27-12-2005
# Arguments : nom y_inf
# Algorithme : cree une selction de l'image pour y>y_inf 
####################################################################


proc spc_hcrop { args } {
   global audace
   global conf
   set kk 1

   if {[llength $args] == 2} {
       set filename [ lindex $args 0 ]
       set ybas [ lindex $args 1 ]
       set fileliste [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ]
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [ lindex $fileliste 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list 1 $ybas $naxis1 $naxis2 ]

       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   set nomfichierlg [ file rootname $fichier ]
	   regexp {(.+)\-[0-9]+} $nomfichierlg match nomfichier
	   buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_hcrop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${nomfichier}_hcrop-x$conf(extension,defaut)\n"
       return ${nomfichier}_hcrop-
   } else {
       ::console::affiche_erreur "Usage: spc_hcrop nom_gégérique_fichiers y_bas\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de decoupage d'une tranche verticale pour une série d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-11-2005
# Date modification : 27-12-2005
# Arguments : nom x_inf
# Algorithme : cree une selction de l'image pour x>x_gauche 
####################################################################


proc spc_vcrop { args } {
   global audace
   global conf
   set kk 1

   if {[llength $args] == 2} {
       set filename [ lindex $args 0 ]
       set ybas [ lindex $args 1 ]
       set fileliste [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ]
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [ lindex $fileliste 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list $xgauche 1 $naxis1 $naxis2 ]

       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   set nomfichierlg [ file rootname $fichier ]
	   regexp {(.+)\-[0-9]+} $nomfichierlg match nomfichier
	   buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_vcrop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${nomfichier}_vcrop-x$conf(extension,defaut)\n"
       return ${nomfichier}_vcrop-
   } else {
       ::console::affiche_erreur "Usage: spc_vcrop nom_gégérique_fichiers x_gauche\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de decoupage d'une zone supérieure droite pour une série d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-11-2005
# Date modification : 22-12-2005/27-12-05
# Arguments : nom_générique x_gauche y_bas
# Algorithme : cree une selction de l'image pour x>x_gauche et y>y_bas 
####################################################################


proc spc_crop { args } {
   global audace
   global conf
   set kk 1

   if {[llength $args] == 3} {
       set filename [ lindex $args 0 ]
       set xgauche [ lindex $args 1 ]
       set ybas [ lindex $args 2 ]
       set fileliste [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ]
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [ lindex $fileliste 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list $xgauche $ybas $naxis1 $naxis2 ]

       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   set nomfichierlg [ file rootname $fichier ]
	   set nomfichier [regexp {(.+)\-[0-9]+} $nomfichierlg match]
	   buf$audace(bufNo) save $"audace(rep_images)/${nomfichier}_crop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${nomfichier}_crop-x$conf(extension,defaut)\n"
       return ${nomfichier}_crop-
   } else {
       ::console::affiche_erreur "Usage: spc_crop nom_gégérique_fichiers x_gauche y_bas\n\n"
   }
}
####################################################################



