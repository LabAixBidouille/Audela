
# Procedures des traitements g�om�triques
# Lancement en console : source $audace(rep_scripts)/spcaudace/spc_geom.tcl




####################################################################
# Procedure de rotation de 180� d'un profil de raies ou d'une image
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits du profil de raie spatial
####################################################################

proc spc_rot180 { args } {

    global audace caption
    global conf

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filenamespc [ lindex $args 0 ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filenamespc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n\n"
	    return 0
	}

	#-- Traitement :
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	buf$audace(bufNo) mirrorx
	#visu
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_flip$conf(extension,defaut)"
	::console::affiche_resultat "Image sauv�e sous ${filespc}_flip$conf(extension,defaut).\n"
	return ${filespc}_flip
    } else {
	::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n\n"
    }
}
#****************************************************************************


####################################################################
# Procedure de rotation de 180� d'un profil de raies ou d'une image
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 20-09-2006
# Arguments : fichier fits du profil de raie spatial
####################################################################

proc spc_flip { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	buf$audace(bufNo) mirrorx
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_flip$conf(extension,defaut)"
	::console::affiche_resultat "Image sauv�e sous ${filespc}_flip$conf(extension,defaut).\n"
	return ${filespc}_flip
    } else {
	::console::affiche_erreur "Usage: spc_flip fichier_fits\n\n"
    }
}
#****************************************************************************



####################################################################
# Procedure de rotation d'un angle alpha d'un spectre spatial 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits de l'image, coordonn�es de 2 points pris sur l'axe inclin� � redresser horizontalement 
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
    #--- Point M1 � gauche de M2
	#set xinf $x1
	set yinf $y1
	set angle [expr 180/$pi*atan(1.0*($y1-$y2)/($x2-$x1))]
    } else {
    #--- Point M1 � droite de M2
	#set xinf $x2
	set yinf $y2
	set angle [expr 180/$pi*atan(1.0*($y2-$y1)/($x1-$x2))]
    }

    #--- Angles>0 vers le haut de l'image
    set xinf 1
    #set newnaxis2 [expr $naxis2+int($naxis1*abs(tan($angle*$pi/180)))+1]
    #buf$audace(bufNo) setkwd [list "NAXIS2" "$newnaxis2" int "" ""]
    buf$audace(bufNo) rot $xinf $yinf $angle
    ::console::affiche_resultat "Rotation d'angle ${angle}� autour de ($xinf,$yinf).\n"

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
    ::console::affiche_resultat "Image sauv�e sous ${filespc}_tilt$conf(extension,defaut).\n"
  } else {
     ::console::affiche_erreur "Usage: spc_tilt fichier_fits x1 y1 x2 y2 (pris sur le spectre)\n\n"
  }
}
#****************************************************************************



####################################################################
# Correction g�om�trique du "spc_smile" d'un spectre spatial 2D
#  (d�formation en courbure)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 21-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits de l'image, coordonn�es de 3 points pris sur l'axe curv� � redresser horizontalement 
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

    # Calcul des coordonn�es du point extremum de la parabole
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
# Date modification : 27-12-2005/06-10-09
# Arguments : nom g�n�rique des fichiers .fit dont la forme est nom-n�.fit
####################################################################

proc spc_register { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
       set filename [ lindex $args 0 ]
       #- D�tection fragile : * doit etre un nombre de 0 a n. glob -nocomplain ?
       #- Am�lior�e le 14-08-2006
       set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${filename}\[0-9\]*$conf(extension,defaut) ] ]
       # Les fichiers de fileliste contiennent aussi le nom du repertoire
       set nb_file [ llength $fileliste ]
       set fichier1 [file tail [ lindex $fileliste 0 ]]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       #set windowcoords [ list 1 1 3 $naxis2 ]
       #-- Gestion des bordures lumineuses dues au pr�traitement :
       set y1 [ expr int(0.05*$naxis2) ]
       set y2 [ expr int(0.95*$naxis2) ]
       set windowcoords [ list 1 $y1 1 $y2 ]

       #-- Initialisation de variables :
       set ycoords ""
       set k 0
       set kk 1

       #::console::affiche_resultat "Liste : $fileliste\n"
       #--- Effectue le binning des colonnes et d�termine le centro�de en Y du spectre 2D
       set fichier ""
       foreach rfichier $fileliste {
	   set fichier [file tail $rfichier]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   #-- M�thode du 27-12-2005 :
	   # buf$audace(bufNo) binx 1 $naxis1 3
	   # set ycentre [lindex [buf$audace(bufNo) centro $windowcoords] 1]
	   #-- M�thode du 06-10-09 :
	   buf$audace(bufNo) imaseries "BINX x1=1 x2=$naxis1 height=1"
	   set ycentre [ lindex [ buf$audace(bufNo) fitgauss $windowcoords ] 5 ]
	   lappend ycoords $ycentre
       }
       
       # Recale chaque spectre 2D verticalement par rapport au premier
       ::console::affiche_resultat "Recalage de $nb_file images...\n"
       set ycentre [ lindex $ycoords 0 ]
       set fichier ""
       set rfichier ""
       foreach rfichier $fileliste {
	   set fichier [ file rootname [file tail $rfichier] ]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   set yi [ lindex $ycoords $k ]
	   set dy [ expr $ycentre-$yi ]
	   buf$audace(bufNo) imaseries "TRANS trans_x=0 trans_y=$dy"
	   #-- EXpreqssion reguliere pouvant etre fragile !
	   #regexp {(.+)\-?[0-9]+} $fichier match nomfichier
	   #buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_r-$kk$conf(extension,defaut)"
	   buf$audace(bufNo) save "$audace(rep_images)/${filename}-r-$kk$conf(extension,defaut)"
	   ::console::affiche_resultat "Spectre redress� sauv� sous ${filename}-r-$kk\n"
	   incr k
	   incr kk
       }
       #::console::affiche_resultat "Images sauv�es sous ${nomfichier}-r-x$conf(extension,defaut)\n"
       #return ${nomfichier}_r-
       ::console::affiche_resultat "Images sauv�es sous ${filename}-r-\n"
       return ${filename}-r-
   } else {
       ::console::affiche_erreur "Usage: spc_register nom_g�n�rique_fichiers\n\n"
   }
}
####################################################################


####################################################################
#  Procedure de rotation automatique de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 29-10-2005/27-12-2005/15-08-2006/13-02-07
# Arguments : fichier .fit
# Heuristique : si l'angle est sup�rieur a 6�, l'angle calcul� ne correspond pas � la r�alit� de l'inclinaison du spectre.
####################################################################

proc spc_tiltauto { args } {
   global audace caption
   global conf
   set pi [expr acos(-1.0)]
   #- anglelim avant : 1.5
   set anglelimit .746

   if {[llength $args] <= 1} {
       if {[llength $args] == 1} {
	   set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set filename $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
	   return 0
       }

       #--- Traitement :
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

       #--- Algo de detection : binx aux bords droit et gauche sur une largeur de 1/100 de celle de l'image.
       set largeur [ expr $naxis1/100 ]
       set windowcoords [ list 1 1 3 $naxis2 ]

       #--- Algo : determine le centre des taches du bord gauche et droit et calcul l'angle.
       #- Methode un peu fragile : trouve parfois un angle important (4 ou 15�) alors que ce n'est pas le cas.
       #-- Binning des colonnes � l'extr�me gauche de l'image
       buf$audace(bufNo) binx [expr $largeur+1] [expr 2*$largeur] 3
       set x1 [ expr int(1.5*$largeur) ]
       set y1 [lindex [buf$audace(bufNo) centro $windowcoords] 1]

       #-- Binning des colonnes � l'extr�me droite de l'image
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       buf$audace(bufNo) binx [expr $naxis1-2*$largeur] [expr $naxis1-$largeur] 3
       set x2 [ expr int($naxis1-1.5*$largeur) ]
       set y2 [ lindex [buf$audace(bufNo) centro $windowcoords ] 1]

       #-- Effectue la rotation d'angle "angle" et de centre=centre moyen de l'epaisseur du spectre :
       #- Angles>0 vers le haut de l'image
       set angle [expr 180/$pi*atan(1.0*($y1-$y2)/($x2-$x1))]
       ## Si l'angle est sup�rieur a 6�, l'angle calcul� ne correspond pas � la r�alit� de l'inclinaison du spectre
       if { $angle <= $anglelimit && $angle >= -$anglelimit } {
	   set yinf [ expr int(0.5*($y1+$y2)) ]
	   set xinf [ expr int($naxis1/2) ] 
	   buf$audace(bufNo) load "$audace(rep_images)/$filename"
	   #set newnaxis2 [expr $naxis2+int($naxis1*abs(tan($angle*$pi/180)))+1]
	   #buf$audace(bufNo) setkwd [list "NAXIS2" "$newnaxis2" int "" ""]
	   buf$audace(bufNo) rot $xinf $yinf $angle
	   ::console::affiche_resultat "Rotation d'angle ${angle}� autour de ($xinf,$yinf).\n"
	   buf$audace(bufNo) save "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
	   ::console::affiche_resultat "Image sauv�e sous ${filename}_tilt$conf(extension,defaut).\n"
	   return ${filename}_tilt
       } else {
	   ::console::affiche_resultat "Rotation d'angle 0� car angle=$angle est �rron�.\n"
	   file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_tilt0$conf(extension,defaut)"
	   ::console::affiche_resultat "Image sauv�e sous ${filename}_tilt0$conf(extension,defaut).\n"
	   return ${filename}_tilt0
       }
   } else {
       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
   }
}
####################################################################


####################################################################
#  Procedure de decoupage d'une tranche horizontale pour une s�rie d'images 2D
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
       ::console::affiche_resultat "$nbimg images � traiter...\n"

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
	   #::console::affiche_resultat "Image $kk trait�e\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauv�es sous $audace(rep_images)/${nomfichier}_hcrop-x$conf(extension,defaut)\n"
       return ${nomfichier}_hcrop-
   } else {
       ::console::affiche_erreur "Usage: spc_hcrop nom_g�g�rique_fichiers y_bas\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de decoupage d'une tranche verticale pour une s�rie d'images 2D
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
       ::console::affiche_resultat "$nbimg images � traiter...\n"

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
	   #::console::affiche_resultat "Image $kk trait�e\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauv�es sous $audace(rep_images)/${nomfichier}_vcrop-x$conf(extension,defaut)\n"
       return ${nomfichier}_vcrop-
   } else {
       ::console::affiche_erreur "Usage: spc_vcrop nom_g�g�rique_fichiers x_gauche\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de decoupage d'une zone sup�rieure droite pour une s�rie d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-11-2005
# Date modification : 22-12-2005/27-12-05
# Arguments : nom_g�n�rique x_gauche y_bas
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
       ::console::affiche_resultat "$nbimg images � traiter...\n"

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
	   #::console::affiche_resultat "Image $kk trait�e\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauv�es sous $audace(rep_images)/${filename}crop-x$conf(extension,defaut)\n"
       #-- 060223 : nomfichier -> filename
       # return ${nomfichier}_crop-
       return ${filename}crop-
   } else {
       ::console::affiche_erreur "Usage: spc_crop nom_g�g�rique_fichiers x_gauche y_bas\n\n"
   }
}
####################################################################



####################################################################
# Proc�dure de correction de raies courb�es (lampe de calibration) par rapport � l'axe vertical : smile selon l'axe x.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-05-2006
# Date modification : 06-06-2006/061220
# Arguments : fichier fits 2D d'une lampe de calibration
# ATTENTION : 2 parametres sont ici fixes en dur : la largeur des raies et la demi-largeur de la fenetre de decoupage autour de la raie choisie.
####################################################################

proc spc_smilex { args } {

    global audace spcaudace
    global conf caption
    global flag_ok
    set pourcentimg 0.01

    if {[llength $args] <= 2} {
	if {[llength $args] == 1} {
	    set filenamespc [ file rootname [ lindex $args 0 ] ]
	    set flagmanuel "n"
	} elseif {[llength $args] == 2} {
	    set filenamespc [ file rootname [ lindex $args 0 ] ]
	    set flagmanuel [ lindex $args 1 ]
	} elseif { [llength $args] == 0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filenamespc $spctrouve
		set flagmanuel "n"
	    } else {
		::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration ?s�lection_manuelle (o/n)?\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration ?s�lection_manuelle (o/n)?\n\n"
	    return 0 
	}

	#set xdeb [ lindex $args 1 ]
	#set ydeb [ lindex $args 2 ]
	#set xfin [ lindex $args 3 ]
	#set yfin [ lindex $args 4 ]

	#--- Initialisation de variables li�es aux dimensions du spectre de la lampe de calibration
	#buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	loadima "$audace(rep_images)/$filenamespc"
	set naxis2i [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	# set pas [ expr $naxis2i/200 ]
	set pas [ expr int($pourcentimg*$naxis2i) ]

	#----- Si hauteur>hmax : on tient compte du smilex :
	if { $naxis2i > $spcaudace(hmax) } {
     #------------------------------------------------------------------------#
     #--- Selection d'une raie � la sourie
     if { $flagmanuel == "o" } {
	::console::affiche_resultat "S�lectionnez un cadre autour d'une raie...\n"
	set flag_ok 0
	# Cr�ation de la fen�tre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "S�lectionnez un cadre autour d'une raie..."
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
	if { $flag_ok==1 } {
	    set wincoords $audace(box)
	    ::console::affiche_resultat "Zone : $wincoords\n"
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok==2 } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- D�coupage de la zone
	if { [info exists audace(box)] == 1 } {
	    #--- D�termination du rayon et du centre de courbure du raie verticale
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
     } elseif { $flagmanuel == "n"} {
	 #------------------------------------------------------------------------#

	 #--- D�termine la zone � d�couper en tra�ant un profil en haut et en bas de l'image et d�termine la fwhm du profil gaussien de la raie la plus � gauche de chaque profils :
	 # fichier fits du spectre spatial, ordonn�e y de la ligne, ?hauteur � binner?
	 #-- Traitement du profil inf�rieur :
	 set hauteur 20
	 set yinf [ expr int($naxis2i*0.07) ]
	 if { [ expr $naxis2i-0.5*$hauteur ] >=1 } {
	     set profil_inf [ spc_profily $filenamespc $yinf $hauteur ]
	 } else {
	     set hauteur [ expr 2*int($yinf-1) ]
	     set profil_inf [ spc_profily $filenamespc $yinf $hauteur ]
	 }
	 set xinf 0
	 set raies [ lsort -real -increasing -index 0 [ spc_findbiglines $profil_inf e 10 ] ]
	 foreach raie $raies {
	     if { [ lindex $raie 1 ] != 0.0 } {
		 set xinf [ lindex $raie 0 ]
		 break
	     }
	 }
	 #- Si n'a pas trouve de raie, prend la raie d'abscisse la plus petite (id. la plus a gauche) :
	 if { $xinf==0 } {
	     set xinf [ lindex [ lindex $raies 0 ] 0 ]
	 }
	 file delete "$audace(rep_images)/$profil_inf$conf(extension,defaut)"
	 
	 #-- Traitement du profil inf�rieur :
	 set hauteur 20
	 set ysup [ expr int($naxis2i*0.95) ]
	 if { [ expr $naxis2i-$hauteur*0.5 ] >=1 } {
	     set profil_sup [ spc_profily $filenamespc $ysup $hauteur ]
	 } else {
	     set hauteur [ expr 2*int($naxis2i-$yinf-1) ]
	     set profil_sup [ spc_profily $filenamespc $ysup $hauteur ]
	 }
	 set raies [ lsort -real -increasing -index 0 [ spc_findbiglines $profil_sup e 10 ] ]
	 foreach raie $raies {
	     if { [ lindex $raie 1 ] != 0.0 } {
		 set xsup [ lindex $raie 0 ]
		 break
	     }
	 }
	 file delete "$audace(rep_images)/$profil_sup$conf(extension,defaut)"
	 
	 #-- Calcul des coordonnees du coin sup droit et inf gauche :
	 if { $xsup>$xinf } {
	     set xsupzone [ expr int($xsup+30) ]
	     set xinfzone [ expr int($xinf-30) ]
	 } else {
	     set xsupzone [ expr int($xsup+30) ]
	     set xinfzone [ expr int($xinf-30) ]
	 }
	 
	 #-- D�coupage de la zone :
	 ##  -----------B
	 ##  |          |
	 ##  A-----------
	 ##set wincoords [ list $xdeb 1 $xfin $naxis2 ]
	 #set wincoords [ list $xdeb $ydeb $xfin $yfin ]
	 set wincoords [ list $xinfzone $yinf $xsupzone $ysup ]
	 ::console::affiche_resultat "Zone : $wincoords\n"
	 buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	 buf$audace(bufNo) window $wincoords
     }
     
	#-- D�termination des dimensions de la zone s�lectionn�e
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	#-- Calcul de points pr�sents sur la raie courb�e par centrage gaussien sur une ligne
	::console::affiche_resultat "Traitement de [expr $naxis2/$pas] lignes.\n"
	set yline 1
	while {$yline<=$naxis2} {
	    set listcoords [list 1 $yline $naxis1 $yline]
	    lappend ycoords $yline
	    #::console::affiche_resultat "Fit gaussien de la ligne $yline.\n"
	    lappend xcoords [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1]
	    set yline [ expr $yline+$pas-1 ]
	}

	#-- Calcul du polynome d'ajustement de degr� 2 sur la raie courbee cx^2+bx+a :
	set coefssmilex [ lindex [ spc_ajustdeg2 $ycoords $xcoords 1 ] 0 ]
	set c [ lindex $coefssmilex 2 ]
	set b [ lindex $coefssmilex 1 ]

	#-- Pour l'instant (061220), evite de faire un slant :
	#if { $c == 0.0 } {
	#    set c 0.000001
	#}

	#--- Correction du smile selon l'axe horizontal X ou du slant :
	if { $c == 0.0 } {
	    ::console::affiche_resultat "Le spectre n'est pas affect� par un smile selon l'axe X.\n"
	    if { $b != 0.0 } {
		set pente $b
		::console::affiche_resultat "Correction du slant de pente $pente...\n"
		buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
		buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
		#-- Sauvegarde du spectre corrig� du slant :
		# buf$audace(bufNo) setkwd [list "SPC_SLX1" 0 float "ycenter smilex" ""]
		# buf$audace(bufNo) setkwd [list "SPC_SLX2" 0 float "adeg2 smilex" ""]
		buf$audace(bufNo) setkwd [list "SPC_SLA" $pente float "pente slant" ""]
		buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_slt$conf(extension,defaut)"
		loadima "$audace(rep_images)/${filenamespc}_slt$conf(extension,defaut)"
		::console::affiche_resultat "Image sauv�e sous ${filenamespc}_slt$conf(extension,defaut). Co�fficents du smilex : $ycenter, $c.\n Il faudra peut-�tre aussi corriger l'inclinaison du spectre.\n"
		set results [ list ${filenamespc}_slx $c $b [lindex $coefssmilex 0] $ycenter  ]
		return $results
	    } else {
		::console::affiche_resultat "Pas de correction du slant n�cessaire non plus.\n"
		return [ list $filenamespc ]
	    }
	} else {
	    set deltay [ expr 0.5*($naxis2i-$naxis2) ]
	    set ycenter [ expr -$b/(2*$c)+$deltay ]
	    ::console::affiche_resultat "Correction du smilex (ycenter=$ycenter, deg2=$c)...\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$c"
	    #--- Sauvegarde
	    buf$audace(bufNo) setkwd [list "SPC_SLX1" $ycenter float "ycenter smilex" ""]
	    buf$audace(bufNo) setkwd [list "SPC_SLX2" $c float "coef deg2 smilex" ""]
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_slx$conf(extension,defaut)"
	    loadima "$audace(rep_images)/${filenamespc}_slx$conf(extension,defaut)"
	    ::console::affiche_resultat "Image sauv�e sous ${filenamespc}_slx$conf(extension,defaut). Co�fficents du smilex : $ycenter, $c.\n Il faudra peut-�tre aussi corriger l'inclinaison du spectre.\n"
	    set results [ list ${filenamespc}_slx $c $b [lindex $coefssmilex 0] $ycenter  ]
	    return $results
	}
      } else {
	  ::console::affiche_resultat "La seule d�formation horisontale est du slant...\n"
	  set results [ spc_slant $filenamespc ]
	  return $results
      }
    } else {
	# ::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration xdeb ydeb xfin yfin\n\n"
	::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration ?s�lection_manuelle (o/n)?\n\n"
    }
}
#****************************************************************************


####################################################################
# Proc�dure de correction des spectres courb�s (stellaire) par rapport � l'axe horizontal : smile selon l'axe y.
#
# Proc�dure de correction de raies courb�es (lampe de calibration) par rapport � l'axe vertical : smile selon l'axe x d'une s�rie d'images connaissant les coefficients.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 21-09-2006
# Date modification : 21-09-2006
# Arguments : nom_g�n�rique_spectres_2D_fits ycenter a
####################################################################

proc spc_smileximgs { args } {

    global audace
    global conf
    set pourcentimg 0.01

    if { [llength $args] == 3 } {
	set filename [ lindex $args 0 ]
	set ycenter [ lindex $args 1 ]
	set a [ lindex $args 2 ]

	#--- Applique le smile au(x) spectre(s) incrimin�(s)
	::console::affiche_resultat "Co�fficients du smilex : ycenter=$ycenter, a=$a\n"
	set liste_images [ glob -dir "$audace(rep_images)" "${filename}\[0-9\]*$conf(extension,defaut)" ]
	set nbsp [ llength $liste_images ]
	if { $nbsp ==  1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$filename"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
	    buf$audace(bufNo) save "$audace(rep_images)/${filename}-slx$conf(extension,defaut)"
	    ::console::affiche_resultat "Spectre corrig� du smile en x sauv� sous ${filename}-slx$conf(extension,defaut)\n"
	    return ${filename}-slx
	} else {  
	    set i 1
	    ::console::affiche_resultat "Correction du smilex de $nbsp spectres...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file tail $lefichier ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
		#--- Sauvegarde
		buf$audace(bufNo) save "$audace(rep_images)/${filename}slx-$i$conf(extension,defaut)"
		incr i
	    }
	    #--- Messages d'information
	    ::console::affiche_resultat "Spectres corrig�s du smile en x sauv�s sous ${filename}slx-\*$conf(extension,defaut).\n"
	    return ${filename}slx-
	}
    } else {
	::console::affiche_erreur "Usage: spc_smileximgs nom_g�n�rique_spectres_2D_fits ycenter a\n\n"
    }
}
#********************************************************************************#




####################################################################
# Proc�dure de correction du raies courb�es (lampe de calibration) : smile selon l'axe x et l'applique au spectre 2D � traiter avec ces param�tres.
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

	#--- D�termine les co�fficients du smilex
	set results [ spc_smilex $spectrelampe ]
	#-- results : ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter
	set ycenter [ lindex $results 4 ]
	set a [ lindex $results 1 ]

	#--- Applique le smile au spectre incrimin�
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"

	#--- Sauvegarde
	set filespc [ file rootname $spectre ]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_slx$conf(extension,defaut)"
	::console::affiche_resultat "Spectre corrige du smile en x sauv� sous ${spectre}_slx$conf(extension,defaut).\n"
	return ${spectre}_slx
    } else {
	::console::affiche_erreur "Usage: spc_smilex2img spectre_2D_a_corriger spectre_lampe_calibration\n\n"
    }
}
#********************************************************************************#



####################################################################
# Proc�dure de correction du raies courb�es (lampe de calibration) : smile selon l'axe x et l'applique au spectre 2D � traiter avec ces param�tres.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 13-06-2006
# Date modification : 14-06-2006
# Arguments : spectre_lampe_calibration, spectre_a_traiter ou nom g�n�rique des pectres � traiter
####################################################################

proc spc_smilex2imgs { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set filename [ file rootname [ lindex $args 1 ] ]

	#--- D�termine les co�fficients du smilex
	set results [ spc_smilex $spectrelampe ]
	#-- results : ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter
	set ycenter [ lindex $results 4 ]
	set a [ lindex $results 1 ]

	#--- Applique le smile au(x) spectre(s) incrimin�(s)
	set liste_images [ glob -dir "$audace(rep_images)" "${filename}\[0-9\]*$conf(extension,defaut)" ]
	set nbsp [ llength $liste_images ]
	if { $nbsp ==  1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$filename"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
	    buf$audace(bufNo) save "$audace(rep_images)/${filename}-slx$conf(extension,defaut)"
	    ::console::affiche_resultat "Spectre corrig� du smile en x sauv� sous ${filename}-slx$conf(extension,defaut)\n"
	    return ${filename}-slx
	} else {  
	    set i 1
	    ::console::affiche_resultat "Correction du smilex de $nbsp spectres...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file tail $lefichier ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
		#--- Sauvegarde
		buf$audace(bufNo) save "$audace(rep_images)/${filename}slx-$i$conf(extension,defaut)"
		incr i
	    }
	    #--- Messages d'information
	    ::console::affiche_resultat "Spectres corrig�s du smile en x sauv�s sous ${filename}slx-\*$conf(extension,defaut).\n"
	    return ${filename}slx-
	}
    } else {
	::console::affiche_erreur "Usage: spc_smilex2imgs spectre_2D_a_corriger spectre_lampe_calibration\n\n"
    }
}
#********************************************************************************#




####################################################################
# Proc�dure de correction des spectres courb�s (stellaire) par rapport � l'axe horizontal : smile selon l'axe y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 06-06-2006
# Date modification : 06-06-2006
# Arguments : spectre 2D fits
####################################################################

proc spc_smiley { args } {

    global audace caption
    global conf
    set pourcentimg 0.01

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filenamespc [ lindex $args 0 ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filenamespc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
	    return 0
	}


	#--- Initialisation de varaibles relatives aux dimentions de l'image
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	set pas [ expr int($pourcentimg*$naxis1) ]

	#--- D�termination des param�tres de courbure du spectre
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

	#-- Calcul du polynome d'ajustement de degr� 2 sur la raie courbee
	set coefssmiley [ lindex [ spc_ajustdeg2 $xcoords $ycoords 1 ] 0 ]
	set a [ lindex $coefssmiley 2 ]
	set b [ lindex $coefssmiley 1 ]
	#set deltay [ expr 0.5*($naxis2i-$naxis2) ]
	#set xcenter [ expr -$b/(2*$a)+$deltay ]
	set xcenter [ expr -$b/(2*$a) ]

	#--- Correction du smile selon l'axe vertical Y
	if { $a == 0 } {
	    ::console::affiche_resultat "Le spectre n'est pas affect� par un smile selon l'axe Y.\n"
	    return 0
	} else {
	    buf$audace(bufNo) imaseries "SMILEY xcenter=$xcenter coef_smile2=$a"
	}

	#--- Sauvegarde
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_sly$conf(extension,defaut)"
	loadima "$audace(rep_images)/${filespc}_sly$conf(extension,defaut)"
	::console::affiche_resultat "Image sauv�e sous ${filespc}_sly$conf(extension,defaut).\n"
	set results [ list ${filespc}_sly $a $b [lindex $coefssmiley 0] $xcenter ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
    }
}
#****************************************************************************



####################################################################
# Proc�dure de correction du raies inclin�es dans le spectre : translations de lignes.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-06-2006
# Date modification : 08-06-2008/061220
# Arguments 061220 (a faire ?)  : spectre 2D fits
# Arguments 060806 : spectre 2D fits, type de raies a/e (absorption/�mission)
# Remarque : cette commande pourrait s'appeler aussi "spc_tiltx"
####################################################################

proc spc_slant { args } {

    global audace
    global conf
    global flag_ok

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set type [ lindex $args 1 ]

	#--- Chargement du spectre et inversion si n�cessaire
	loadima $filenamespc
	if { [string compare $type "a"] == 0 } {
	    buf$audace(bufNo) mult -1.0
	}

	#--- Rep�rage de la partie sup�rieure de la raie  ----
	set flag_ok 0
	#-- Cr�ation de la fen�tre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Faites un cadre sur la partie sup�rieure d'une raie brillante (bo�te petite)"
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
	#-- Determine le photocentre de la zone s�lection�e
	set stats [ buf$audace(bufNo) stat ]
	#set point_depart [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ]
	set point_depart [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
	::console::affiche_resultat "Partir sup�rieure de la raie : $point_depart\n"


	#---------------------------------------------------------#
	#--- Rep�rage de la partie inf�rieure de la raie  ----
	set flag_ok 0
	#-- Cr�ation de la fen�tre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Faites un cadre sur la partie inf�rieure de cette m�me raie (bo�te petite)"
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
	#-- Determine le photocentre de la zone s�lection�e
	set stats [ buf$audace(bufNo) stat ]
	set point_final [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
	::console::affiche_resultat "Extr�mit� inf�rieure de la raie : $point_final\n"

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
	set pente [ expr $deltax/$deltay ]
	::console::affiche_resultat "Pente d'inclinaison de la raie : $pente pixels y/pixels x.\n"
	buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
	buf$audace(bufNo) setkwd [list "SPC_SLA" $pente float "pente slant" ""]

	#--- Sauvegarde
	if { [string compare $type "a"] == 0 } {
	    buf$audace(bufNo) mult -1.0
	}
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_slant$conf(extension,defaut)"
	::console::affiche_resultat "Image sauv�e sous ${filespc}_slant$conf(extension,defaut).\n"
	loadima "$audace(rep_images)/${filespc}_slant$conf(extension,defaut)"
	set results [ list ${filespc}_slant $pente ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_slant spectre_2D_fits type_raie (a/e)\n\n"
    }
}
#****************************************************************************



####################################################################
# Proc�dure de correction du raies inclin�es dans le spectre : translations de lignes et l'applique au spectre d�form�. (inutile car applique la correction qu'� une image).
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

	#--- D�termine les co�fficients du slant
	set cd [ lindex [ spc_slant $spectrelamp ] 1 ]

	#--- Applique le smile au spectre incrimin�
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) imaseries "TILT trans_x=$cd trans_y=0"

	#--- Sauvegarde
	set filespc [ file rootname $spectre ]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_slant$conf(extension,defaut)"
	::console::affiche_resultat "Image sauv�e sous ${filespc}_slant$conf(extension,defaut).\n"
	return ${spectre}_slant
    } else {
	::console::affiche_erreur "Usage: spc_slant2img spectre_lampe_calibration spectre_2D_a_corriger\n\n"
    }
}
#****************************************************************************


####################################################################
# Proc�dure de correction du raies inclin�es dans le spectre : translations de lignes et l'applique � une s�rie d'images d�form�es.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-12-2006
# Date modification : 28-12-2006
# Arguments : nom g�n�rique des fichiers � corriger, pente du slant
####################################################################

proc spc_slant2imgs { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set nom_spectres [ file rootname [ lindex $args 0 ] ]
	set pente [ lindex $args 1 ]

	#--- Construit la liste des images � traiter :
	set liste_sp [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_spectres}\[0-9\]*$conf(extension,defaut) ] ]

	#--- Applique le smile aux spectres incrimin�s :
	set i 1
	foreach spectre $liste_sp {
	    set lespectre [ file tail $spectre ]
	    buf$audace(bufNo) load "$audace(rep_images)/$lespectre"
	    buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
	    buf$audace(bufNo) save "$audace(rep_images)/${nom_spectres}_slt-$i$conf(extension,defaut)"
	    ::console::affiche_resultat "Image corrig�e sauv�e sous ${nom_spectres}_slt-$i$conf(extension,defaut).\n"
	    incr i
	}

	return ${nom_spectres}_slt-
    } else {
	::console::affiche_erreur "Usage: spc_slant2imgs nom_g�n�rique_spectre2D_a_corriger pente_slant\n\n"
    }
}
#****************************************************************************





####################################################################
# Proc�dure de correction de l'inclinaison du spectre pour une s�rie d'images
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-06-2006
# Date modification : 15-08-2006/24-08-06
# Arguments : nom g�n�rique des spectres � traiter
####################################################################

proc spc_tiltautoimgs { args } {

    global audace
    global conf

    
    if { [llength $args] <= 2 } {
	if { [llength $args] == 1 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject "o"
	} elseif { [llength $args] == 2 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_tiltautoimgs nom_g�n�rique_spectre_2D ?flag_reject (o/n)?\n\n"
	    return 0
	}

	#--- Applique le smile au(x) spectre(s) incrimin�(s)
	set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" "${filename}\[0-9\]*$conf(extension,defaut)" ] ]
	set nbsp [ llength $liste_images ]
	if { $nbsp==1 } {
	    set spectre_tilt [ spc_tiltauto $filename ]
	    ::console::affiche_resultat "Spectre corrig� sauv� sous $spectre_tilt$conf(extension,defaut)\n"
	    return $spectre_tilt
	} else {
	    set i 1
	    set nbspbad 0
	    ::console::affiche_resultat "$nbsp spectres � traiter...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file rootname [ file tail $lefichier ] ]
		set spectre_tilte [ spc_tiltauto $fichier ]
		#-- Cas des spectres dont la rotation excede une valeur seuil :
		if { [ regexp {(.+)tilt0+} $spectre_tilte match spectrem ] } {
		    if { $reject == "o" } {
			file delete -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)"
			file copy -force "$audace(rep_images)/$fichier$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt0-$i$conf(extension,defaut)"
			::console::affiche_resultat "Spectre non corrig� sauv� sous ${filename}tilt0-$i$conf(extension,defaut).\n\n"
		    } elseif { $reject == "n" } {
			file delete -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)"
			file copy -force "$audace(rep_images)/$fichier$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
			::console::affiche_resultat "Spectre non corrig� sauv� sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		    } else {
			::console::affiche_resultat "Mauvaise option de rejet de spectre.\n"
			return 0
		    }
		    incr nbspbad
		} else {
		    file rename -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
		    ::console::affiche_resultat "Spectre corrig� sauv� sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		}
		incr i
	    }

	    #--- Renumerote si des spectres ont ete ecrates de la serie :
	    if { $nbspbad >= 1 } {
		renumerote ${filename}tilt-
	    }

	    #--- Messages d'information
	    #::console::affiche_resultat "Spectre corrig�s sauv�s sous ${filename}tilt-\*$conf(extension,defaut).\n"
	    return ${filename}tilt-
	}
    } else {
	::console::affiche_erreur "Usage: spc_tiltautoimgs nom_g�n�rique_spectre_2D ?flag_reject (o/n)?\n\n"
    }
}
#********************************************************************************#



####################################################################
# Proc�dure d'�limination des spectres bruts inexploitables : passage nuageux...
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-08-2006
# Date modification : 15-08-2006
# Arguments : nom g�n�rique des spectres � traiter
# Heuristique : si l'�paisseur du spectre est trop faible, l'image est consid�r�e comme alt�r�e.
####################################################################

proc spc_reject { args } {

    global audace
    global conf
    set hauteur_min 6.0

    if { [ llength $args ] == 1} {
	set nomgeneric [ lindex $args 0 ]
	set listeimg [ lsort -dictionary [ glob -dir $audace(rep_images) ${nomgeneric}\[0-9\]*$conf(extension,defaut) ] ]
	set nbimg [ llength $listeimg ]

	#--- Heuristique : si l'�paisseur du spectre est trop faible, l'image est consid�r�e comme alt�r�e.
	set i 0
	::console::affiche_resultat "V�rification de $nbimg spectres...\n"
	foreach spectre $listeimg {
	    set fichier [ file tail [ file rootname $spectre ] ]
	    set sp_hauteur [ lindex [ spc_detect $fichier ] 1 ]
	    if { $sp_hauteur < $hauteur_min } {
		incr i
		file rename $audace(rep_images)/$fichier$conf(extension,defaut) $audace(rep_images)/bad_$fichier$conf(extension,defaut)
		::console::affiche_resultat "Le spectre $fichier est alt�r� et est donc renom� en bad_$fichier\n"
	    }
	}

	#--- Renumerote les images dans le cas ou il y a au moins un rejet :
	if { $i >= 1 } {
	    renumerote $nomgeneric
	}
	::console::affiche_resultat "$i spectre(s) retir�(s) de la s�rie\n"
    } else {
	::console::affiche_erreur "Usage: spc_reject nom_g�n�rique_spectre_2D\n\n"
    }
}
#********************************************************************************#