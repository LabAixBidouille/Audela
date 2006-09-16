
# source $audace(rep_scripts)/spcaudace/spc_calibrage.tcl
# spc_fits2dat lmachholz_centre.fit
# buf1 load lmachholz_centre.fit


####################################################################
#  Procedure de calcul de dispersion moyenne
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2005
# Date modification : 27-02-2005
# Arguments : liste des lambdas, naxis1
####################################################################

proc spc_dispersion_moy { { lambdas ""} } {
    # Dispersion du spectre :
    set naxis1 [llength $lambdas]
    set l1 [lindex $lambdas 1]
    set l2 [lindex $lambdas [expr int($naxis1/10)]]
    set l3 [lindex $lambdas [expr int(2*$naxis1/10)]]
    set l4 [lindex $lambdas [expr int(3*$naxis1/10)]]
    set dl1 [expr ($l2-$l1)/(int($naxis1/10)-1)]
    set dl2 [expr ($l4-$l3)/(int($naxis1/10)-1)]
    set xincr [expr 0.5*($dl2+$dl1)]
    return $xincr
}
#****************************************************************#



####################################################################
#  Procedure de conversion d'�talonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-05 / 09-12-05 / 26-12-05
# Arguments : fichier .fit du profil de raie spatial pixel1 lambda1 pixel2 lambda2
####################################################################

proc spc_calibre2 { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 5} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set pixel2 [ lindex $args 3 ]
    set lambda2 [ lindex $args 4 ]
    
    #--- R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    #set spectre [ openspcncal "$filespc" ]
    #-- Modif faite le 26/12/2005
    set spectre [ spc_fits2data "$filespc" ]
    set intensites [lindex $spectre 0]
    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]

    #--- Calcul des parametres spectraux
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion Angstroms/pixel\n"
    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
    #set xcentre [expr int($lambda0+0.5*($dispersion*$naxis1)-1)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "Angstrom" string "Wavelength unit" ""]
    #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2 fichier_fits_du_profil x1 lambda1 x2 lambda2\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure de conversion d'�talonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-05/09-12-05/26-12-05/26-03-06
# Arguments : fichier .fit du profil de raie x1a x2a lambda_a type_raie (a/e) x1b x2b lambda_b type_raie (a/e)
####################################################################

proc spc_calibre2sauto { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 9} {
    set filespc [ lindex $args 0 ]
    set pixel1a [ expr int([ lindex $args 1 ]) ]
    set pixel1b [ expr int([ lindex $args 2 ]) ]
    set lambda1 [ lindex $args 3 ]
    set linetype1 [ lindex $args 4 ]
    set pixel2a [ expr int([ lindex $args 5 ]) ]
    set pixel2b [ expr int([ lindex $args 6 ]) ]
    set lambda2 [ lindex $args 7 ]
    set linetype2 [ lindex $args 8 ]
    
    #--- R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    #set spectre [ openspcncal "$filespc" ]
    #-- Modif faite le 26/12/2005
    #set spectre [ spc_fits2data "$filespc" ]
    #set intensites [lindex $spectre 0]
    ##set naxis1 [lindex $spectre 1]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]


    #--- D�termine le centre gaussien de la raie 1 et 2
    #-- Raie 1
    if { $linetype1 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    set listcoords [list $pixel1a 1 $pixel1b 1]
    set pixel1 [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1]
    #-- Redresse le spectre a l'endroit s'il avait ete invers� pr�c�dement
    if { $linetype1 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    #-- Raie 2
    if { $linetype2 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    set listcoords [list $pixel2a 1 $pixel2b 1]
    set pixel2 [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1] 
    #-- Redresse le spectre a l'endroit s'il avait ete invers� pr�c�dement
    if { $linetype2 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    ::console::affiche_resultat "Centre des raies 1 : $pixel1 et raie 2 : $pixel2\n"

    #--- Calcul des parametres spectraux
    #-- Dispersion :
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion Angstroms/pixel\n"
    #-- Longueur d'onde de d�part :
    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
    # set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1/$binning)] # FAUX

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "Angstrom" string "Wavelength unit" ""]
    #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save $audace(rep_images)/l${filespc}
    ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2sauto fichier_fits_du_profil x1a x2a lambda_a type_raie (a/e) x1b x2b lambda_b type_raie (a/e)\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure d'�talonnage en longueur d'onde � partir de la dispersion et d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-08-2005
# Date modification : 16-08-2005
# Arguments : profil de raie.fit, pixel, lambda, dispersion
####################################################################

proc spc_calibre2rd { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 4} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set dispersion [ lindex $args 3 ]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
    ::console::affiche_resultat "$naxis1\n"
      
    #--- Calcul des parametres spectraux
    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
    set xcentre [expr int($lambda0+0.5*($dispersion*$naxis1)-1.0)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "Angstrom" string "Wavelength unit" ""]
    #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    #--- Sauvegarde du profil calibr�
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2rd fichier_fits_du_profil x1 lambda1 dispersion\n\n"
  }
}
#****************************************************************#


####################################################################
# Procedure d'�talonnage en longueur d'onde � partir de la loi de dispersion
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-04-2006
# Date modification : 17-04-2006
# Arguments : profil de raie.fit, lambda_debut, dispersion
####################################################################

proc spc_calibre2loi { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 3} {
    set filespc [ lindex $args 0 ]
    set lambda0 [ lindex $args 1 ]
    set dispersion [ lindex $args 2 ]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "Angstrom" string "Wavelength unit" ""]
    #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    #--- Sauvegarde du profil calibr�
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2loi fichier_fits_du_profil lambda_debut dispersion\n\n"
  }
}
#****************************************************************#


####################################################################
# Procedure d'�talonnage en longueur d'onde � partir de la loi de dispersion
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-04-2006
# Date modification : 17-04-2006
# Arguments : profil de raie.fit, lambda_debut, dispersion
####################################################################

proc spc_calibre2loifile { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 2} {
      set fileref [ lindex $args 0 ]
      set filespc [ lindex $args 1 ]

      buf$audace(bufNo) load "$audace(rep_images)/$fileref"
      set lambda0 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
      set dispersion [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      #--- Initialisation des mots clefs du fichier fits de sortie
      # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
      #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
      buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
      #-- Longueur d'onde de d�part
      buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
      #-- Dispersion
      buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angstrom/pixel"]
      buf$audace(bufNo) setkwd [list "CUNIT1" "Angstrom" string "Wavelength unit" ""]
      #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
      buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
      
      #--- Sauvegarde du profil calibr�
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
      ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
      return l${filespc}
  } else {
      ::console::affiche_erreur "Usage: spc_calibre2loifile profil_de_reference_fits profil_a_etalonner_fits\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure de conversion d'�talonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005 / 09-12-2005
# Arguments : fichier .fit du profil de raie spatial
####################################################################

proc spc_calibre3pil { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 7} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set pixel2 [ lindex $args 3 ]
    set lambda2 [ lindex $args 4 ]
    set pixel3 [ lindex $args 5 ]
    set lambda3 [ lindex $args 6 ]

    #--- R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    #-- Modif faite le 26/12/2005
    set spectre [ spc_fits2data "$filespc" ]
    set intensites [lindex $spectre 0]
    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]

    #--- Calcul des parametres spectraux
    set deltax [expr $x2-$x1]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion lin�aire vaut : $dispersion Angstroms/Pixel.\n"
    set lambda_0 [expr $lambda1-$dispersion*$x1]

    #--- Calcul les coefficients du polyn�me interpolateur de Lagrange : lambda=a*x^2+b*x+c
    set a [expr $lambda1/(($x1-$x2)*($x1-$x2))+$lambda2/(($x2-$x1)*($x2-$x3))+$lambda3/(($x3-$x1)*($x3-$x2))]
    set b [expr -$lambda1*($x3+$x2)/(($x1-$x2)*($x1-$x2))-$lambda2*($x3+$x1)/(($x2-$x1)*($x2-$x3))-$lambda3*($x1+$x2)/(($x3-$x1)*($x3-$x2))]
    set c [expr $lambda1*$x3*$x2/(($x1-$x2)*($x1-$x2))+$lambda2*$x3*$x1/(($x2-$x1)*($x2-$x3))+$lambda3*$x1*$x2/(($x3-$x1)*($x3-$x2))]
    ::console::affiche_resultat "$a, $b et $c\n"

    # set dispersionm [expr (sqrt(abs($b^2-4*$a*$c)))/$a]
    #set dispersionm [expr abs([ dispersion_moy $intensites $naxis1 ]) ]
    #--- Calcul les valeurs des longueurs d'ondes associees a chaque pixel
    set len [expr $naxis1-2]
    for {set x 1} {$x<=$len} {incr x} {
	lappend lambdas [expr $a*$x*$x+$b*$x+$c]
    }

    #--- Affichage du polynome :
    set file_id [open "$audace(rep_images)/polynome.txt" w+]
    for {set x 1} {$x<=$len} {incr x} {
	set lamb [lindex $lambdas [expr $x-1]]
	puts $file_id "$x $lamb"
    }
    close $file_id

    #--- Calcul la disersion moyenne en faisant la moyenne des ecarts entre les lambdas : GOOD ! 
    set dispersionm 0
    for {set k 0} {$k<[expr $len-1]} {incr k} {
	set l1 [lindex $lambdas $k]
	set l2 [lindex $lambdas [expr $k+1]]
	set dispersionm [expr 0.5*($dispersionm+0.5*($l2-$l1))]
    }
    ::console::affiche_resultat "La dispersion non lin�aire vaut : $dispersionm Angstroms/Pixel.\n"

    set lambda0 [expr $a+$b+$c]
    set lcentre [expr int($lambda0+0.5*($dispersionm*$naxis1)-1)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
    #-- Dispersion
    #buf$audace(bufNo) setkwd [list "CDELT1" "$dispersionm" float "" "Angtrom/pixel"]
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angtrom/pixel"]
    #-- Longueur d'onde centrale
    #buf$audace(bufNo) setkwd [list "CRPIX1" "$lcentre" int "" "Angstrom"]
    #-- Type de dispersion : LINEAR...
    #buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre3pil fichier_fits_du_profil x1 lambda1 x2 lambda2 x3 lambda3\n\n"
  }
}
#****************************************************************************



####################################################################
# Proc�dure de calibration par un polyn�me de degr� 2 (au moins 3 raies n�cessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################

proc spc_calibren { args } {
    global conf
    global audace
    set error 0.01

    set len [expr [ llength $args ]-1 ]
    if { [ expr $len+1 ] >= 1 } {
	set filename [ lindex $args 0 ]
	set coords [ lrange $args 1 $len ]

	#--- Pr�paration des listes de donn�es :
	for {set i 0} {$i<[expr $len-1]} { incr i+2} {
	    lappend xvals [ lindex $coords $i ]
	    lappend lambdas [ lindex $coords [ expr $i+1 ] ]
	    lappend errors $error
	}

	#--- Calcul du polyn�me de calibration :
	set sortie [ spc_ajustdeg2 $xvals $lambdas $errors ]
	set coeffs [ lindex $sortie 0 ]
	set c [ lindex $coeffs 2 ]
	set b [ lindex $coeffs 1 ]
	set a [ lindex $coeffs 0 ]
	set lambda0 [ expr $a+$b+$c ]

	#--- Mise � jour des mots clefs :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
	#-- Longueur d'onde de d�part :
	buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "Angstrom"]
	#-- Dispersion moyenne :
	buf$audace(bufNo) setkwd [list "CDELT1" $b float "" "Angstrom/pixel"]
	buf$audace(bufNo) setkwd [list "CUNIT1" "Angstrom" string "Wavelength unit" ""]
	#-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X) :
	buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
	#-- Mots clefs du polyn�me :
	buf$audace(bufNo) setkwd [list "SPC_DESC" "A.x.x+B.x+C" string "" ""]
	buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "Angstrom"]
	buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "Angstrom/pixel"]
	buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "Angstrom.Angstrom/pixel.pixel"]

	#--- Fin du script :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
	::console::affiche_resultat "Spectre �talonn� sauv� sous l${filename}\n"
	return $l{filename}
    } else {
	::console::affiche_erreur "Usage: spc_calibren nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
    }
}
#***************************************************************************#



####################################################################
# Proc�dure de calibration par un polyn�me de degr� 2 (au moins 3 raies n�cessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3
####################################################################

proc spc_autocalibren { args } {
    global conf
    global audace

    ::console::affiche_resultat "Pas encore impl�ment�e\n"
}
#***************************************************************************#


####################################################################
# Proc�dure de r��chantillonnage lin�aire d'un profil de raies a calibration non-lin�aire
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies
####################################################################

proc spc_echantlin { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set filename [ lindex $args 0 ]

	#--- Initialise les vecteurs et mots clefs � sauvegarder :
	#-- ATTENTION : etpae a rettoucher pour disp non-lineaire
	set listevals [ spc_fits2data $filename ]
	set xvals [ lindex $listevals 0 ]
	set yvals [ lindex $listevals 1 ]
	set len [ llength $xvals ]


	#--- Initialise un vecteur des indices des pixels :
	for {set i 1} {$i<=$len} {incr i} {
	    lappend indices $i
	}
	set valeurs [ list $indices $xvals ]

	#--- Effectue la r�gression lin�aire :
	set coeffs [ spc_reglin $valeurs ]
	set a [ lindex $coeffs 0 ]
	set b [ lindex $coeffs 1 ]
	for {set i 0} {$i<$len} {incr i} {
	    lappend lambdas [ expr $a*($i+1)+$b ] 
	}

	#--- Enregistrement au format fits
	set spectre [ list $lambdas $yvals ]
	set fileout [ spc_data2fits ${filename}_linear $spectre ]
	::console::affiche_resultat "Le profil r��chantillonn� lin�airement est sauv� sous ${filename}_linear\n"
	return ${filename}_linear
    } else {
	::console::affiche_erreur "Usage: spc_echantlin nom_profil_raies\n"
    }
}
#***************************************************************************#



####################################################################
# Proc�dure de calibration a partir d'un spectre etalon
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 3-09-2006
# Date modification : 3-09-2006
# Arguments : profil_de_raies profil_de_raies_a_calibrer
####################################################################

proc spc_calibrelampe { args } {
    global conf
    global audace

    if { [llength $args] == 2 } {
	set spetalon [ lindex $args 0 ]
	set spacalibrer [ lindex $args 1 ]

	#--- Calcul du profil de raies du spectre �talon :
	set linecoords [ spc_detect $spcacalibrer ]
	set ysup [ expr int([ lindex $linecoords 0 ]+[ lindex $linecoords 1 ]) ]
	set yinf [ expr int([ lindex $linecoords 0 ]-[ lindex $linecoords 1 ]) ]
	buf$audace(bufNo) load "$audace(rep_images)/$spetalon"
	set intensite_fond [ lindex [ buf$audace(bufNo) stat ] 6 ]
	buf$audace(bufNo) imaseries "BINY y1=$yinf y2=$ysup height=1"
	buf$audace(bufNo) save "$audace(rep_images)/${spetalon}_spc"

	#--- D�temination du centre de chaque raies d�tect�es dans le spectre �talon :
	set listemax [ spc_findlines ${spetalon}_spc 20 ]
	#-- Algo : fait avancer de 10 pixels un fitgauss {x1 1 x2 1}, recupere le Xmax et centreX, puis tri selon Xmax et garde les 6 plus importants 
	set nbraies [ llength $listemax ]

	#--- Calibration du spectre etalon ;
	#-- Algo : fait une premiere calibrae avec 2 raies, puis se sert de la loi pour associer une lambda aux autres raies (>=3) et fait une calibrtion polynomile si d'autres raies existent

	#--- Calibration du spectre � calibrer :
	if { $nbraies== 1 } {
	    ::console::affiche_resultat "Pas assez de raies calibrer en longueur d'onde\n"
	} elseif { $nbraies==2 } {
	    set fileout [ spc_calibre2loifile $l{spetalon}_spc $spacalibrer ]
	} else {
	    set fileout [ spc_calibre3loifile $l{spetalon}_spc $spacalibrer ]
	}

	#--- Affichage des r�sultats :
	::console::affiche_resultat "Le spectre calibr� est sauv� sous $fileout\n"
	return $fileout
    } else {
       ::console::affiche_erreur "Usage: spc_calibrelampe profil_de_raies_mesur� profil_de_raies_de_r�f�rence\n\n"
   }
}
#***************************************************************************#





#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#            Correction de la r�ponse instrumentale                          #
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


##########################################################
# Calcul la r�ponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division 
##########################################################

proc spc_rinstrum { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- V�rifie s'il faut r��chantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
	   #-- D�termine le spectre de dispersion la plus pr�cise
	   set carac1 [ spc_info $fichier_mes ]
	   set carac2 [ spc_info $fichier_ref ]
	   set disp1 [ lindex $carac1 5 ]
	   set ldeb1 [ lindex $carac1 3 ]
	   set lfin1 [ lindex $carac1 4 ]
	   set disp2 [ lindex $carac2 5 ]
	   set ldeb2 [ lindex $carac2 3 ]
	   set lfin2 [ lindex $carac2 4 ]
	   if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- R��chantillonnage et crop du spectre de r�f�rence fichier_ref
	       ::console::affiche_resultat "\nR��chantillonnage et crop du spectre de r�f�rence...\n\n"
	       #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interf�rence, mais le continuum poss�de la dispersion du sepctre de r�f�rence :
	       #set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       #set fref_sel_ech [ spc_echant $fref_sel $fichier_mes ]
	       #set fref_sortie $fref_sel_ech
	       #set fmes_sortie $fichier_mes

	       #- Dans cet ordre, permet d'obtenir le vertiable continuum :
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_ech_sel [ spc_select $fref_ech $ldeb1 $lfin1 ]
	       set fref_sortie $fref_ech_sel
	       set fmes_sortie $fichier_mes
	   } elseif { $disp2<$disp1 && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- R��chantillonnage du spectre de r�f�rence fichier_ref et crop du spectre de mesure
	       ::console::affiche_resultat "\nR��chantillonnage du spectre mesur� fichier_mes et crop du spectre de r�f�rence...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_sortie $fref_ech
	       set fmes_sortie $fmes_sel
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Aucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de r�f�rence
	       ::console::affiche_resultat "\nAucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de r�f�rence...\n\n"
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sortie $fref_sel
	       set fmes_sortie $fichier_mes
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- Aucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de mesures
	       ::console::affiche_resultat "\nAucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de mesures...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_sortie $fichier_ref
	       set fmes_sortie $fmes_sel
	   } else {
	       #-- Le spectre de r�f�rence ne recouvre pas les longueurs d'onde du spectre mesur�
	       ::console::affiche_resultat "\nLe spectre de r�f�rence ne recouvre aucune plage de longueurs d'onde du spectre mesur�.\n\n"
	   }
       } else {
	   #-- Aucun r��chantillonnage ni red�coupage n�cessaire
	   ::console::affiche_resultat "\nAucun r��chantillonnage ni red�coupage n�cessaire.\n\n"
	   set fref_sortie $fichier_ref
	   set fmes_sortie $fichier_mes
       }

       #--- Lin�arisation des deux profils de raies
       ::console::affiche_resultat "Lin�arisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth $fref_sortie ]
       set fmes_ready [ spc_bigsmooth $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
	   file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       #set fref_ready "$fref_sortie"
       #set fmes_ready "$fmes_sortie"

       #--- Divison des deux profils de raies pour obtention de la r�ponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la r�ponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrum == 0 } {
	   ::console::affiche_resultat "\nLa r�ponse intrumentale ne peut �tre calcul�e.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${fichier_mes}_rinstrum$conf(extension,defaut)"
	   ::console::affiche_resultat "R�ponse instrumentale sauv�e sous ${fichier_mes}_rinstrum$conf(extension,defaut)\n"
	   return ${fichier_mes}_rinstrum
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesur� profil_de_raies_de_r�f�rence\n\n"
   }
}
#****************************************************************#



##########################################################
# Effectue la correction de la r�ponse intrumentale � l'aide du profil_a_corriger, profil_�toile_r�f�rence et profil_�toile_catalogue
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 14-07-2006
# Date de mise � jour : 14-07-2006
# Arguments : profil_a_corriger profil_�toile_r�f�rence profil_�toile_catalogue
##########################################################

proc spc_rinstrumcorr { args } {

   global audace
   global conf
   if { [llength $args] == 3 } {
       set spectre_acorr [ file rootname [ lindex $args 0 ] ]
       set etoile_ref [ file rootname [ lindex $args 1 ] ]
       set etoile_cat [ file rootname [ lindex $args 2 ] ]

       set rinstrum [ spc_rinstrum $etoile_ref $etoile_cat ]
       set spectre_corr [ spc_div $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
	   ::console::affiche_resultat "\nLe profil corrig� de la r�ponse intrumentale ne peut �tre calcul�e.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_ricorr$conf(extension,defaut)"
	   ::console::affiche_resultat "\nProfil corrig� de la r�ponse intrumentale sauv� sous ${spectre_acorr}_ricorr.\n\n"
	   return ${spectre_acorr}_ricorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumcorr profil_a_corriger profil_�toile_r�f�rence profil_�toile_catalogue\n\n"
   }
}
#****************************************************************#




##########################################################
# Calcul la r�ponse intrumentale avec les raies telluriques de l'eau
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division 
##########################################################

proc spc_rinstrumeau { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- V�rifie s'il faut r��chantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
	   #-- D�termine le spectre de dispersion la plus pr�cise
	   set carac1 [ spc_info $fichier_mes ]
	   set carac2 [ spc_info $fichier_ref ]
	   set disp1 [ lindex $carac1 5 ]
	   set ldeb1 [ lindex $carac1 3 ]
	   set lfin1 [ lindex $carac1 4 ]
	   set disp2 [ lindex $carac2 5 ]
	   set ldeb2 [ lindex $carac2 3 ]
	   set lfin2 [ lindex $carac2 4 ]
	   if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- R��chantillonnage et crop du spectre de r�f�rence fichier_ref
	       ::console::affiche_resultat "\nR��chantillonnage et crop du spectre de r�f�rence...\n\n"
	       #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interf�rence, mais le continuum poss�de la dispersion du sepctre de r�f�rence :
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sel_ech [ spc_echant $fref_sel $fichier_mes ]
	       set fref_sortie $fref_sel_ech
	       set fmes_sortie $fichier_mes

	       #- Dans cet ordre, permet d'obtenir le vertiable continuum :
	       #set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       #set fref_ech_sel [ spc_select $fref_ech $ldeb1 $lfin1 ]
	       #set fref_sortie $fref_ech_sel
	       #set fmes_sortie $fichier_mes
	   } elseif { $disp2<$disp1 && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- R��chantillonnage du spectre de r�f�rence fichier_ref et crop du spectre de mesure
	       ::console::affiche_resultat "\nR��chantillonnage du spectre mesur� fichier_mes et crop du spectre de r�f�rence...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_sortie $fref_ech
	       set fmes_sortie $fmes_sel
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Aucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de r�f�rence
	       ::console::affiche_resultat "\nAucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de r�f�rence...\n\n"
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sortie $fref_sel
	       set fmes_sortie $fichier_mes
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- Aucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de mesures
	       ::console::affiche_resultat "\nAucun r��chantillonnage n�cessaire mais un red�coupage (crop) n�cessaire du spectre de mesures...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_sortie $fichier_ref
	       set fmes_sortie $fmes_sel
	   } else {
	       #-- Le spectre de r�f�rence ne recouvre pas les longueurs d'onde du spectre mesur�
	       ::console::affiche_resultat "\nLe spectre de r�f�rence ne recouvre aucune plage de longueurs d'onde du spectre mesur�.\n\n"
	   }
       } else {
	   #-- Aucun r��chantillonnage ni red�coupage n�cessaire
	   ::console::affiche_resultat "\nAucun r��chantillonnage ni red�coupage n�cessaire.\n\n"
	   set fref_sortie $fichier_ref
	   set fmes_sortie $fichier_mes
       }

       #--- Lin�arisation des deux profils de raies
       ::console::affiche_resultat "Lin�arisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth $fref_sortie ]
       set fmes_ready [ spc_bigsmooth $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
	   file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }

       #--- Divison des deux profils de raies pour obtention de la r�ponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la r�ponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]
       #-- R��chantillonne le continuum avec l'eau pour obtenir la m�me dispersion que celle du spectre de mesures :
       #set rinstrumeau [ spc_echant $rinstrum $fichier_mes ]
       set rinstrumeau $rinstrum

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrumeau == 0 } {
	   ::console::affiche_resultat "\nLa r�ponse intrumentale ne peut �tre calcul�e.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$rinstrumeau$conf(extension,defaut)" "$audace(rep_images)/${fichier_mes}_rinstrumeau$conf(extension,defaut)"
	   ::console::affiche_resultat "R�ponse instrumentale sauv�e sous ${fichier_mes}_rinstrumeau$conf(extension,defaut)\n"
	   return ${fichier_mes}_rinstrumeau
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumeau profil_de_raies_mesur� profil_de_raies_de_r�f�rence\n\n"
   }
}
#****************************************************************#


##########################################################
# Effectue la correction de la r�ponse intrumentale � l'aide du profil_a_corriger, profil_�toile_r�f�rence et profil_�toile_catalogue *** tout en retirant les raies telluriques ***
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 25-08-2006
# Date de mise � jour : 25-08-2006
# Arguments : profil_a_corriger profil_�toile_r�f�rence profil_�toile_catalogue
##########################################################

proc spc_rinstrumeaucorr { args } {

   global audace
   global conf
   if { [llength $args] == 3 } {
       set spectre_acorr [ file rootname [ lindex $args 0 ] ]
       set etoile_ref [ file rootname [ lindex $args 1 ] ]
       set etoile_cat [ file rootname [ lindex $args 2 ] ]

       set rinstrum [ spc_rinstrumeau $etoile_ref $etoile_cat ]
       set spectre_corr [ spc_div $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
	   ::console::affiche_resultat "\nLe profil corrig� de la r�ponse intrumentale ne peut �tre calcul�e.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_riocorr$conf(extension,defaut)"
	   ::console::affiche_resultat "\nProfil corrig� de la r�ponse intrumentale et des raies tellurtiques sauv� sous ${spectre_acorr}_riocorr.\n\n"
	   return ${spectre_acorr}_riocorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumcorr profil_a_corriger profil_�toile_r�f�rence profil_�toile_catalogue\n\n"
   }
}
#****************************************************************#



















#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



####################################################################################
# Ancienne version des fonctions
####################################################################################

proc spc_rinstrum_020905 { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set infichier_mes [ lindex $args 0 ]
       set infichier_ref [ lindex $args 1 ]
       set fichier_mes [ file rootname $infichier_mes ]
       set fichier_ref [ file rootname $infichier_ref ]

       # R�cup�re les caract�ristiques des 2 spectres
       buf$audace(bufNo) load $fichier_mes
       set naxis1a [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set xdeb1 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set disper1 [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin1 [ expr $xdeb1+$naxis1a*$disper1*1.0 ]
       buf$audace(bufNo) load $fichier_ref
       set naxis1b [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set xdeb2 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set disper2 [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin2 [ expr $xdeb2+$naxis1b*$disper2*1.0 ]

       # S�lection de la bande de longueur d'onde du spectre de r�f�rence
       ## Le spectre de r�f�rence est suppos� avoir une plus large bande de lambda
       set ${fichier_ref}_sel [ spc_select $fichier_ref $xdeb1 $xfin1 ]
       # R��chantillonnage du spectre de r�f�rence : c'est un choix.
       ## Que disp1 < disp2 ou disp2 < disp1, la dispersion finale sera disp1
       set ${fichier_ref}_sel_rech [ spc_echant ${fichier_ref}_sel $disp1 ]
       file delete ${fichier_ref}_sel$conf(extension,defaut)
       # Calcul la r�ponse intrumentale : RP=spectre_mesure/spectre_ref
       buf$audace(bufNo) load $fichier_mes
       buf$audace(bufNo) div ${fichier_ref}_sel_rech 1.0
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save reponse_intrumentale
       ::console::affiche_resultat "S�lection sauv�e sous ${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum fichier .fit du profil de raie, profil de raie de r�f�rence\n\n"
   }
}
#****************************************************************#


