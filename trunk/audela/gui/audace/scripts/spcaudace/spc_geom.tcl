
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
       # Les fichiers de fileliste contiennent aussi le nom du repertoire
       set nb_file [ llength $fileliste ]
       set fichier1 [file tail [ lindex $fileliste 0 ]]
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
       foreach rfichier $fileliste {
	   set fichier [file tail $rfichier]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) binx 1 $naxis1 3
	   set ycentre [lindex [buf$audace(bufNo) centro $windowcoords] 1]
	   lappend ycoords $ycentre
       }
       
       # Recale chaque spectre 2D verticalement par rapport au premier
       ::console::affiche_resultat "Recalage de $nb_file images..."
       set ycentre [ lindex $ycoords 0 ]
       set fichier ""
       foreach rfichier $fileliste {
	   set fichier [file tail $rfichier]
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
	   regexp {(.+)\-?[0-9]+} $nomfichierlg match nomfichier
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
       # Les fichiers de fileliste contiennent aussi le nom du repertoire !
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [file tail [ lindex $fileliste 0 ]]
       ::console::affiche_resultat "$fichier1\n"
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list $xgauche $ybas $naxis1 $naxis2 ]

       set fichier ""
       foreach rfichier $fileliste {
	   set fichier [file tail $rfichier]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   # 060223 : nom de fichier sortie incorrect -> impose
	   # set nomfichierlg [ file rootname $fichier ]
	   # set nomfichier [regexp {(.+)\-[0-9]+} $nomfichierlg match]
	   # buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_crop-$kk$conf(extension,defaut)"
	   buf$audace(bufNo) save "$audace(rep_images)/${filename}crop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${filename}crop-x$conf(extension,defaut)\n"
       #-- 060223 : nomfichier -> filename
       # return ${nomfichier}_crop-
       return ${filename}crop-
   } else {
       ::console::affiche_erreur "Usage: spc_crop nom_gégérique_fichiers x_gauche y_bas\n\n"
   }
}
####################################################################



####################################################################
# Procédure de correction de raies courbées (lampe de calibration) par rapport à l'axe vertical : smile selon l'axe x.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-05-2006
# Date modification : 06-06-2006
# Arguments : fichier fits 2D d'une lampe de calibration
####################################################################

proc spc_smilex { args } {

    global audace
    global conf
    global flag_ok
    set pourcentimg 0.01

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]
	#set xdeb [ lindex $args 1 ]
	#set ydeb [ lindex $args 2 ]
	#set xfin [ lindex $args 3 ]
	#set yfin [ lindex $args 4 ]

	#--- Initialisation de variables liées aux dimensions du spectre de la lampe de calibration
	#buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	loadima "$audace(rep_images)/$filenamespc"
	set naxis2i [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	# set pas [ expr $naxis2i/200 ]
	set pas [ expr int($pourcentimg*$naxis2i) ]

	#--- Selection d'une raie à la sourie
	::console::affiche_resultat "Sélectionnez un cadre autour d'une raie...\n"
	set flag_ok 0
	# Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Sélectionnez un cadre autour d'une raie..."
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "OK"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    ::console::affiche_resultat "Zone : \n"
	    set wincoords $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Découpage de la zone
	if { [info exists audace(box)] == 1 } {
	    #--- Détermination du rayon et du centre de courbure du raie verticale
	    ##  -----------B
	    ##  |          |
	    ##  A-----------
	    ##set wincoords [ list $xdeb 1 $xfin $naxis2 ]
	    #set wincoords [ list $xdeb $ydeb $xfin $yfin ]
	    buf$audace(bufNo) window $wincoords
	    #-- Suppression de la zone selectionnee avec la souris
	    catch {
		unset audace(box)
		$audace(hCanvas) delete $audace(hBox)
	    }
	} else {
	    ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
	}

	#-- Détermination des dimensions de la zone sélectionnée
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	#-- Calcul de points présents sur la raie courbée par centrage gaussien sur une ligne
	::console::affiche_resultat "Traitement de [expr $naxis2/$pas] lignes.\n"
	set yline 1
	while {$yline<=$naxis2} {
	    set listcoords [list 1 $yline $naxis1 $yline]
	    lappend ycoords $yline
	    #::console::affiche_resultat "Fit gaussien de la ligne $yline.\n"
	    lappend xcoords [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1]
	    set yline [ expr $yline+$pas-1 ]
	}

	#-- Calcul du polynome d'ajustement de degré 2 sur la raie courbee
	set coefssmilex [ lindex [ spc_ajustdeg2 $ycoords $xcoords 1 ] 0 ]
	set a [ lindex $coefssmilex 2 ]
	set b [ lindex $coefssmilex 1 ]
	set deltay [ expr 0.5*($naxis2i-$naxis2) ]
	set ycenter [ expr -$b/(2*$a)+$deltay ]

	#--- Correction du smile selon l'axe horizontal X
	if { $a == 0 } {
	    ::console::affiche_resultat "Le spectre n'est pas affecté par un smile selon l'axe X.\n"
	    return 0
	} else {
	    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
	}

	#--- Sauvegarde
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_slx$conf(extension,defaut)"
	loadima "$audace(rep_images)/${filespc}_slx$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_slx$conf(extension,defaut). Coéfficents du smilex : $ycenter, $a.\n Il faudra peut-être aussi corriger l'inclinaison du spectre.\n"
	set results [ list ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter  ]
	return $results
    } else {
	# ::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration xdeb ydeb xfin yfin\n\n"
	::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration\n\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction des spectres courbés (stellaire) par rapport à l'axe horizontal : smile selon l'axe y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 06-06-2006
# Date modification : 06-06-2006
# Arguments : spectre 2D fits
####################################################################

proc spc_smiley { args } {

    global audace
    global conf
    set pourcentimg 0.01

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]

	#--- Initialisation de varaibles relatives aux dimentions de l'image
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	set pas [ expr int($pourcentimg*$naxis1) ]

	#--- Détermination des paramètres de courbure du spectre
	::console::affiche_resultat "Traitement de [expr $naxis1/$pas] colonnes.\n"
	set xline 1
	while {$xline<=$naxis1} {
	    ##  -----------B
	    ##  |          |
	    ##  A-----------
	    set listcoords [list $xline 1 $xline $naxis2 ]
	    lappend xcoords $xline
	    lappend ycoords [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 5]
	    set xline [ expr $xline+$pas-1 ]
	}

	#-- Calcul du polynome d'ajustement de degré 2 sur la raie courbee
	set coefssmiley [ lindex [ spc_ajustdeg2 $xcoords $ycoords 1 ] 0 ]
	set a [ lindex $coefssmiley 2 ]
	set b [ lindex $coefssmiley 1 ]
	#set deltay [ expr 0.5*($naxis2i-$naxis2) ]
	#set xcenter [ expr -$b/(2*$a)+$deltay ]
	set xcenter [ expr -$b/(2*$a) ]

	#--- Correction du smile selon l'axe vertical Y
	if { $a == 0 } {
	    ::console::affiche_resultat "Le spectre n'est pas affecté par un smile selon l'axe Y.\n"
	    return 0
	} else {
	    buf$audace(bufNo) imaseries "SMILEY xcenter=$xcenter coef_smile2=$a"
	}

	#--- Sauvegarde
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_sly$conf(extension,defaut)"
	loadima "$audace(rep_images)/${filespc}_sly$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_sly$conf(extension,defaut).\n"
	set results [ list ${filespc}_sly $a $b [lindex $coefssmiley 0] $xcenter ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction du raies inclinées dans le spectre : translations de lignes.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-06-2006
# Date modification : 08-06-2008
# Arguments : spectre 2D fits, type de raies a/e (absorption/émission)
# Remarque : cette commande pourrait s'appeler aussi "spc_tiltx"
####################################################################

proc spc_slant { args } {

    global audace
    global conf
    global flag_ok

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set type [ lindex $args 1 ]

	#--- Chargement du spectre et inversion si nécessaire
	loadima $filenamespc
	if { [string compare $type "a"] == 0 } {
	    buf$audace(bufNo) mult -1.0
	}

	#--- Repérage de la partie supérieure de la raie  ----
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Faites un cadre sur la partie supérieure d'une raie brillante (boîte petite)"
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "OK"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set coords_zone $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Determine le photocentre de la zone sélectionée
	set stats [ buf$audace(bufNo) stat ]
	#set point_depart [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ]
	set point_depart [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
	::console::affiche_resultat "Partir supérieure de la raie : $point_depart\n"


	#---------------------------------------------------------#
	#--- Repérage de la partie inférieure de la raie  ----
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Faites un cadre sur la partie inférieure de cette même raie (boîte petite)"
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "OK"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set coords_zone $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Determine le photocentre de la zone sélectionée
	set stats [ buf$audace(bufNo) stat ]
	set point_final [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
	::console::affiche_resultat "Extrémité inférieure de la raie : $point_final\n"

	#--- Correction du slant
	set erra [ lindex $point_depart 2 ]
	#set erra 0.1
	if { $erra >=0.3 } {
	    set x_depart [expr [lindex $point_depart 0]+$erra ]
	    set y_depart [expr [lindex $point_depart 1]+$erra ]
	} else {
	    set x_depart [ lindex $point_depart 0 ]
	    set y_depart [ lindex $point_depart 1 ]
	}
	set errb [ lindex $point_final 2 ]
	if { $erra >=0.3 } {
	    set x_final [expr [lindex $point_final 0]+$errb ]
	    set y_final [expr [lindex $point_final 1]+$errb ]
	} else {
	    set x_final [ lindex $point_final 0 ]
	    set y_final [ lindex $point_final 1 ]
	}
	set deltax [expr $x_final-$x_depart ]
	set deltay [expr $y_final-$y_depart ]
	#set deltax [ expr [ lindex $point_final 0 ]-[ lindex $point_depart 0 ] ]
	#set deltay [ expr [ lindex $point_final 1 ]-[ lindex $point_depart 1 ] ]
	# set cd [ expr $deltay/$deltax ]
	set cd [ expr $deltax/$deltay ]
	::console::affiche_resultat "Pente d'inclinaison de la raie : $cd pixels y/pixels x.\n"
	buf$audace(bufNo) imaseries "TILT trans_x=$cd trans_y=0"

	#--- Sauvegarde
	if { [string compare $type "a"] == 0 } {
	    buf$audace(bufNo) mult -1.0
	}
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_slant$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_slant$conf(extension,defaut).\n"
	set results [ list ${filespc}_slant $cd ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_slant spectre_2D_fits type_raie (a/e)\n\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction du raies inclinées dans le spectre : translations de lignes et l'applique au spectre déformé.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-06-2006
# Date modification : 08-06-2008
# Arguments : spectre 2D fits
# Remarque : cette commande pourrait s'appeler aussi "spc_tiltx"
####################################################################

proc spc_slant2img { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set spectre [ lindex $args 1 ]

	#--- Détermine les coéfficients du slant
	set cd [ lindex [ spc_slant $spectrelamp ] 1 ]

	#--- Applique le smile au spectre incriminé
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) imaseries "TILT trans_x=$cd trans_y=0"

	#--- Sauvegarde
	set filespc [ file rootname $spectre ]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_slant$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_slant$conf(extension,defaut).\n"
	return ${spectre}_slant
    } else {
	::console::affiche_erreur "Usage: spc_slant2img spectre_lampe_calibration spectre_2D_a_corriger\n\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction du raies courbées (lampe de calibration) : smile selon l'axe x et l'applique au spectre 2D à traiter avec ces paramètres.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-05-2006
# Date modification : 28-05-2006
# Arguments : spectre_lampe_calibration, spectre_a_traiter
####################################################################

proc spc_smilex2img { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set spectre [ lindex $args 1 ]

	#--- Détermine les coéfficients du smilex
	set results [ spc_smilex $spectrelampe ]
	#-- results : ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter
	set ycenter [ lindex $results 4 ]
	set a [ lindex $results 1 ]

	#--- Applique le smile au spectre incriminé
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"

	#--- Sauvegarde
	set filespc [ file rootname $spectre ]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_slx$conf(extension,defaut)"
	::console::affiche_resultat "Spectre corrige du smile en x sauvé sous ${spectre}_slx$conf(extension,defaut).\n"
	return ${spectre}_slx
    } else {
	::console::affiche_erreur "Usage: spc_smilex2img spectre_2D_a_corriger spectre_lampe_calibration\n\n"
    }
}
#********************************************************************************#



####################################################################
# Procédure de correction du raies courbées (lampe de calibration) : smile selon l'axe x et l'applique au spectre 2D à traiter avec ces paramètres.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 13-06-2006
# Date modification : 14-06-2006
# Arguments : spectre_lampe_calibration, spectre_a_traiter ou nom générique des pectres à traiter
####################################################################

proc spc_smilex2imgs { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set filename [ file rootname [ lindex $args 1 ] ]

	#--- Détermine les coéfficients du smilex
	set results [ spc_smilex $spectrelampe ]
	#-- results : ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter
	set ycenter [ lindex $results 4 ]
	set a [ lindex $results 1 ]

	#--- Applique le smile au(x) spectre(s) incriminé(s)
	set liste_images [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ]
	set nbsp [ llength $liste_images ]
	if { $nbsp ==  1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$filename"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
	    buf$audace(bufNo) save "$audace(rep_images)/${filename}-slx$conf(extension,defaut)"
	    ::console::affiche_resultat "Spectre corrigé du smile en x sauvé sous ${filename}-slx$conf(extension,defaut)\n"
	    return ${filename}-slx
	} else {  
	    set i 1
	    ::console::affiche_resultat "$nbsp spectres à traiter...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file tail $lefichier ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
		#--- Sauvegarde
		buf$audace(bufNo) save "$audace(rep_images)/${filename}slx-$i$conf(extension,defaut)"
		incr i
	    }
	    #--- Messages d'information
	    ::console::affiche_resultat "Spectres corrigés du smile en x sauvés sous ${filename}slx-\*$conf(extension,defaut).\n"
	    return ${filename}slx-
	}
    } else {
	::console::affiche_erreur "Usage: spc_smilex2imgs spectre_2D_a_corriger spectre_lampe_calibration\n\n"
    }
}
#********************************************************************************#



####################################################################
# Procédure de correction de l'inclinaison du spectre pour une série d'images
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-06-2006
# Date modification : 16-06-2006
# Arguments : nom générique des spectres à traiter
####################################################################

proc spc_tiltautoimgs { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filename [ file rootname [ lindex $args 0 ] ]

	#--- Applique le smile au(x) spectre(s) incriminé(s)
	set liste_images [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ]
	set nbsp [ llength $liste_images ]
	if { $nbsp ==  1 } {
	    set spectre_tilte [ spc_tiltauto $filename ]
	    ::console::affiche_resultat "Spectre corrigé sauvé sous $spectre_tilte$conf(extension,defaut)\n"
	    return $spectre_tilte
	} else {  
	    set i 1
	    ::console::affiche_resultat "$nbsp spectres à traiter...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file tail $lefichier ]
		set spectre_tilte [ spc_tiltauto $fichier ]
		file rename "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
		::console::affiche_resultat "Spectre corrigé sauvé sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		incr i
	    }
	    #--- Messages d'information
	    #::console::affiche_resultat "Spectre corrigés sauvés sous ${filename}tilt-\*$conf(extension,defaut).\n"
	    return ${filename}tilt-
	}
    } else {
	::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D\n\n"
    }
}
#********************************************************************************#
