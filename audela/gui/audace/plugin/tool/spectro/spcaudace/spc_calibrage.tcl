
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
#  Procedure de conversion d'étalonnage en longueur d'onde d'ordre 2
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
    
    #--- Récupère la liste "spectre" contenant 2 listes : pixels et intensites
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
    ::console::affiche_resultat "La dispersion vaut : $dispersion angstroms/pixel\n"
    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
    #set xcentre [expr int($lambda0+0.5*($dispersion*$naxis1)-1)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2 fichier_fits_du_profil x1 lambda1 x2 lambda2\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure de conversion d'étalonnage en longueur d'onde d'ordre 2
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
    
    #--- Récupère la liste "spectre" contenant 2 listes : pixels et intensites
    #set spectre [ openspcncal "$filespc" ]
    #-- Modif faite le 26/12/2005
    #set spectre [ spc_fits2data "$filespc" ]
    #set intensites [lindex $spectre 0]
    ##set naxis1 [lindex $spectre 1]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]


    #--- Détermine le centre gaussien de la raie 1 et 2
    #-- Raie 1
    if { $linetype1 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    set listcoords [list $pixel1a 1 $pixel1b 1]
    set pixel1 [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1]
    #-- Redresse le spectre a l'endroit s'il avait ete inversé précédement
    if { $linetype1 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    #-- Raie 2
    if { $linetype2 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    set listcoords [list $pixel2a 1 $pixel2b 1]
    set pixel2 [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1] 
    #-- Redresse le spectre a l'endroit s'il avait ete inversé précédement
    if { $linetype2 == "a" } {
	  buf$audace(bufNo) mult -1
    }
    ::console::affiche_resultat "Centre des raies 1 : $pixel1 et raie 2 : $pixel2\n"

    #--- Calcul des parametres spectraux
    #-- Dispersion :
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion angstroms/pixel\n"
    #-- Longueur d'onde de départ :
    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
    # set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1/$binning)] # FAUX

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save $audace(rep_images)/l${filespc}
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2sauto fichier_fits_du_profil x1a x2a lambda_a type_raie (a/e) x1b x2b lambda_b type_raie (a/e)\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure d'étalonnage en longueur d'onde à partir de la dispersion et d'une raie
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
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    #--- Sauvegarde du profil calibré
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2rd fichier_fits_du_profil x1 lambda1 dispersion\n\n"
  }
}
#****************************************************************#


####################################################################
# Procedure d'étalonnage en longueur d'onde à partir de la loi de dispersion
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
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    #--- Sauvegarde du profil calibré
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2loi fichier_fits_du_profil lambda_debut dispersion\n\n"
  }
}
#****************************************************************#


####################################################################
# Procedure d'étalonnage en longueur d'onde à partir de la loi de dispersion
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-04-2006
# Date modification : 20-09-2006/04-01-07
# Arguments : profil_de_reference_fits profil_a_etalonner_fits
####################################################################

proc spc_calibreloifile { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 2} {
      set fileref [ lindex $args 0 ]
      set filespc [ lindex $args 1 ]

      buf$audace(bufNo) load "$audace(rep_images)/$fileref"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	  set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      }
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	  set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	  set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	  set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
	  set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
	  set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
      } else {
	  set spc_d 0.0
      }
      if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
	  set spc_rms [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 1 ]
      }

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      #--- Initialisation des mots clefs du fichier fits de sortie
      # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
      #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
      buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
      #-- Longueur d'onde de départ
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	  buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
      }
      #-- Dispersion
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	  buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "angstrom/pixel"]
	  buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
      }
      #-- Corrdonnée représentée sur l'axe 1 (ie X)
      buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

      #--- Mots clefs de la calibration non-linéaire :
      #-- A+B.x+C.x.x+D.x.x.x
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	  #-- Ancienne formulation < 04012007 :
	  # buf$audace(bufNo) setkwd [list "SPC_DESC" "A.x.x+B.x+C" string "" ""]
	  #-- Nouvelle formulation :
	  buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
	  buf$audace(bufNo) setkwd [list "SPC_A" $spc_a float "" "angstrom"]
	  if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	      buf$audace(bufNo) setkwd [list "SPC_B" $spc_b float "" "angstrom/pixel"]
	  }
	  if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
	      buf$audace(bufNo) setkwd [list "SPC_C" $spc_c float "" "angstrom*angstrom/pixel*pilxe"]
	  }
	  buf$audace(bufNo) setkwd [list "SPC_D" $spc_d float "" "angstrom*angstrom*angstrom/pixel*pilxe*pixel"]
	  if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
	      buf$audace(bufNo) setkwd [list "SPC_RMS" $spc_rms float "" "angstrom"]
	  }

      }
      
      #--- Sauvegarde du profil calibré
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
      ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
      return l${filespc}
  } else {
      ::console::affiche_erreur "Usage: spc_calibreloifile profil_de_reference_fits profil_a_etalonner_fits\n\n"
  }
}
#****************************************************************#



####################################################################
# Procedure de décalage de la longureur d'onde de départ
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-01-2007
# Date modification : 04-01-2007
# Arguments : profil_a_decaler_fits decalage
####################################################################

proc spc_calibredecal { args } {

  global conf
  global audace
  global profilspc
  global captionspc

  if {[llength $args] == 2} {
      set filespc [file rootname [ lindex $args 0 ] ]
      set decalage [ lindex $args 1 ]

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	  if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	      set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	      set lambda_modifie [ expr $lambda0+$decalage ]
	      buf$audace(bufNo) setkwd [list "CRVAL1" $lambda_modifie float "" "angstrom"]
	  }
	  set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
	  set spc_a_modifie [ expr $spc_a+$decalage ]
	  buf$audace(bufNo) setkwd [list "SPC_A" $spc_a_modifie float "" "angstrom"]
      } elseif { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	      set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	      set lambda_modifie [ expr $lambda0+$decalage ]
	      buf$audace(bufNo) setkwd [list "CRVAL1" $lambda_modifie float "" "angstrom"]
      }
      
      #--- Sauvegarde du profil calibré
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filespc}_dec"
      ::console::affiche_resultat "Spectre étalonné sauvé sous ${filespc}_dec\n"
      return "${filespc}_dec"
  } else {
      ::console::affiche_erreur "Usage: spc_calibredecal profil_a_decaler_fits decalage\n\n"
  }
}
#****************************************************************#




####################################################################
#  Procedure de conversion d'étalonnage en longueur d'onde d'ordre 2
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

    #--- Récupère la liste "spectre" contenant 2 listes : pixels et intensites
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
    ::console::affiche_resultat "La dispersion linéaire vaut : $dispersion angstroms/Pixel.\n"
    set lambda_0 [expr $lambda1-$dispersion*$x1]

    #--- Calcul les coefficients du polynôme interpolateur de Lagrange : lambda=a*x^2+b*x+c
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
    ::console::affiche_resultat "La dispersion non linéaire vaut : $dispersionm angstroms/Pixel.\n"

    set lambda0 [expr $a+$b+$c]
    set lcentre [expr int($lambda0+0.5*($dispersionm*$naxis1)-1)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
    #-- Dispersion
    #buf$audace(bufNo) setkwd [list "CDELT1" "$dispersionm" float "" "Angtrom/pixel"]
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion float "" "Angtrom/pixel"]
    #-- Longueur d'onde centrale
    #buf$audace(bufNo) setkwd [list "CRPIX1" "$lcentre" int "" "angstrom"]
    #-- Type de dispersion : LINEAR...
    #buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre3pil fichier_fits_du_profil x1 lambda1 x2 lambda2 x3 lambda3\n\n"
  }
}
#****************************************************************************



####################################################################
# Procédure de calibration par un polynôme de degré 2 (au moins 3 raies nécessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################

proc spc_calibren { args } {
    global conf
    global audace
    set erreur 0.01

    set len [expr [ llength $args ]-1 ]
    if { [ expr $len+1 ] >= 1 } {
	set filename [ lindex $args 0 ]
	set coords [ lrange $args 1 $len ]
	#::console::affiche_resultat "$len Coords : $coords\n"

	#--- Préparation des listes de données :
	for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ]} {
	    lappend xvals [ lindex $coords $i ]
	    lappend lambdas [ lindex $coords [ expr $i+1 ] ]
	    lappend errors $erreur
	}
	set nbraies [ llength $lambdas ]

	#--- Calcul des coéfficients du polynome de calibration :
	#-- Calcul du polynôme de calibration a+bx+cx^2 :
	set sortie [ spc_ajustdeg2 $xvals $lambdas $errors ]
	set coeffs [ lindex $sortie 0 ]
	set chi2 [ lindex $sortie 1 ]
	set d 0.0
	set c [ lindex $coeffs 2 ]
	set b [ lindex $coeffs 1 ]
	set a [ lindex $coeffs 0 ]
	set lambda0deg2 [ expr $a+$b+$c ]
	set lambda0deg3 [ expr $a+$b+$c+$d ]
	#-- Calcul du RMS :
	set rms [ expr $lambda0deg2*sqrt($chi2/$nbraies) ]
	::console::affiche_resultat "RMS=$rms angstrom\n"
	#-- Calcul d'une série de longueurs d'ondes passant par le polynome pour la linéarisation :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
	    lappend xpos $x
	    lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
	}
	    
	#--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
	set listevals [ list $xpos $lambdaspoly ]
	set coeffsdeg1 [ spc_reglin $listevals ]
	set a1 [ lindex $coeffsdeg1 0 ]
	set b1 [ lindex $coeffsdeg1 1 ]
	set lambda0deg1 [ expr $a1+$b1 ]
	#set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
	#-- Reglages :
	#- 40 -10 l0deg1 : AB
	#- 40 -40 l0deg1 : AB+
	#- 20 -10 l0deg2 : AB++
	if { $nbraies <=2 } {
	    set lambda0 $lambda0deg2
	} else {
	    set lambda0 $lambda0deg3
	}

	#--- Mise à jour des mots clefs :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
	#-- Longueur d'onde de départ :
	buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
	#-- Dispersion moyenne :
	buf$audace(bufNo) setkwd [list "CDELT1" $a1 float "" "angstrom/pixel"]
	buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
	#-- Corrdonnée représentée sur l'axe 1 (ie X) :
	buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
	#-- Mots clefs du polynôme :
	buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
	buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
	buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "angstrom/pixel"]
	buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "angstrom.angstrom/pixel.pixel"]
	buf$audace(bufNo) setkwd [list "SPC_D" $d float "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
	buf$audace(bufNo) setkwd [list "SPC_RMS" $rms float "" "angstrom"]

	#--- Fin du script :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
	::console::affiche_resultat "Spectre étalonné sauvé sous l${filename}\n"
	return l${filename}
    } else {
	::console::affiche_erreur "Usage: spc_calibren nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calibration par un polynôme de degré 2 ou 3 selon le nombre de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-01-2007
# Date modification : 04-01-2007
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################

proc spc_calibren_deg3 { args } {
    global conf
    global audace
    set erreur 0.01

    set len [expr [ llength $args ]-1 ]
    if { [ expr $len+1 ] >= 1 } {
	set filename [ lindex $args 0 ]
	set coords [ lrange $args 1 $len ]
	#::console::affiche_resultat "$len Coords : $coords\n"

	#--- Préparation des listes de données :
	for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ]} {
	    lappend xvals [ lindex $coords $i ]
	    lappend lambdas [ lindex $coords [ expr $i+1 ] ]
	    lappend errors $erreur
	}
	set nbraies [ llength $lambdas ]

	#--- Calcul des coéfficients du polynome de calibration :
	if { $nbraies <=2 } {
	    #-- Calcul du polynôme de calibration a+bx+cx^2 :
	    set sortie [ spc_ajustdeg2 $xvals $lambdas $errors ]
	    set coeffs [ lindex $sortie 0 ]
	    set chi2 [ lindex $sortie 1 ]
	    set d 0.0
	    set c [ lindex $coeffs 2 ]
	    set b [ lindex $coeffs 1 ]
	    set a [ lindex $coeffs 0 ]
	    set lambda0deg2 [ expr $a+$b+$c ]
	    #-- Calcul du RMS :
	    set rms [ expr $lambda0deg2*sqrt($chi2/$nbraies) ]
	    ::console::affiche_resultat "RMS=$rms angstrom\n"
	    #-- Calcul d'une série de longueurs d'ondes passant par le polynome pour la linéarisation :
	    buf$audace(bufNo) load "$audace(rep_images)/$filename"
	    set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	    for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
		lappend xpos $x
		lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
	    }
	} else {
	    #-- Calcul du polynôme de calibration a+bx+cx^2+dx^3 :
	    set sortie [ spc_ajustdeg3 $xvals $lambdas $errors ]
	    set coeffs [ lindex $sortie 0 ]
	    set chi2 [ lindex $sortie 1 ]
	    set d [ lindex $coeffs 3 ]
	    set c [ lindex $coeffs 2 ]
	    set b [ lindex $coeffs 1 ]
	    set a [ lindex $coeffs 0 ]
	    set lambda0deg3 [ expr $a+$b+$c+$d ]
	    #--- Calcul du RMS :
	    set rms [ expr $lambda0deg3*sqrt($chi2/$nbraies) ]
	    ::console::affiche_resultat "RMS=$rms angstrom\n"
	    #-- Calcul d'une série de longueurs d'ondes passant par le polynome pour la linéarisation :
	    buf$audace(bufNo) load "$audace(rep_images)/$filename"
	    set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	    for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
		lappend xpos $x
		lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x ]
	    }
	}
	    
	#--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
	set listevals [ list $xpos $lambdaspoly ]
	set coeffsdeg1 [ spc_reglin $listevals ]
	set a1 [ lindex $coeffsdeg1 0 ]
	set b1 [ lindex $coeffsdeg1 1 ]
	set lambda0deg1 [ expr $a1+$b1 ]
	#set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
	#-- Reglages :
	#- 40 -10 l0deg1 : AB
	#- 40 -40 l0deg1 : AB+
	#- 20 -10 l0deg2 : AB++
	if { $nbraies <=2 } {
	    set lambda0 $lambda0deg2
	} else {
	    set lambda0 $lambda0deg3
	}

	#--- Mise à jour des mots clefs :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
	#-- Longueur d'onde de départ :
	buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
	#-- Dispersion moyenne :
	buf$audace(bufNo) setkwd [list "CDELT1" $a1 float "" "angstrom/pixel"]
	buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
	#-- Corrdonnée représentée sur l'axe 1 (ie X) :
	buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
	#-- Mots clefs du polynôme :
	buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
	buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
	buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "angstrom/pixel"]
	buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "angstrom.angstrom/pixel.pixel"]
	buf$audace(bufNo) setkwd [list "SPC_D" $d float "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
	buf$audace(bufNo) setkwd [list "SPC_RMS" $rms float "" "angstrom"]

	#--- Fin du script :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
	::console::affiche_resultat "Spectre étalonné sauvé sous l${filename}\n"
	return l${filename}
    } else {
	::console::affiche_erreur "Usage: spc_calibren_deg3 nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calibration par un polynôme de degré 2 (au moins 3 raies nécessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3
####################################################################

proc spc_autocalibren { args } {
    global conf
    global audace

    ::console::affiche_resultat "Pas encore implémentée\n"
}
#***************************************************************************#


####################################################################
# Procédure de rééchantillonnage linéaire d'un profil de raies a calibration non-linéaire
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
	set filename [ file rootname [ lindex $args 0 ] ]

	#--- Initialise les vecteurs et mots clefs à sauvegarder :
	set listevals [ spc_fits2data $filename ]
	set xvals [ lindex $listevals 0 ]
	set yvals [ lindex $listevals 1 ]
	set len [ llength $xvals ]


	#--- Initialise un vecteur des indices des pixels :
	for {set i 1} {$i<=$len} {incr i} {
	    lappend indices $i
	}
	set valeurs [ list $indices $xvals ]

	#--- Effectue la régression linéaire pour linéariser les longueurs d'onde :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set listemotsclef [ buf$audace(bufNo) getkwds ]
	if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	    set spc_a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
	    set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
	    set spc_c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
	    set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
	    set flag_spccal 1
	} else {
	    ::console::affiche_resultat "Profil déjà linéarisé\n"
	    return ""
	}

	for {set x 20} {$x<=[ expr $len-10 ]} { set x [ expr $x+20 ]} {
	    lappend xpos $x
	    #lappend lambdaspoly [ expr $spc_a+$spc_b*$x+$spc_c*$x*$x ]
	    lappend lambdaspoly [ lindex $xvals $x ]
	    #lappend errorsd1 $mes_incertitude
	}
	set listevals [ list $xpos $lambdaspoly ]
	#set sortie1 [ spc_ajustdeg1 $xpos $lambdaspoly $errorsd1 ]
	#-- lambda=a*x+b
	set coeffsdeg1 [ spc_reglin $listevals ]
	set a [ lindex $coeffsdeg1 0 ]
	set b [ lindex $coeffsdeg1 1 ]
	#-- Loi théorique :
	set lambda0deg1 [ expr $a+$b ]
	#-- Loi empirique :
	#set lambda0deg1 [ expr $b*1. ]
	for {set i 1} {$i<=$len} {incr i} {
	    lappend lambdas [ expr $a*$i+$b ] 
	}

	#--- Rééchantillonne par spline les intensités sur la nouvelle échelle en longueur d'onde :
	set new_intensities [ lindex  [ spc_spline $xvals $yvals $lambdas n ] 1 ]


	#--- Enregistrement au format fits
	#set fileout [ spc_data2fits ${filename}_linear $spectre ]
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	for {set k 0} {$k<$len} {incr k} {
	    set intensite [ lindex $new_intensities $k ]
	    buf$audace(bufNo) setpix [ list [ expr $k+1 ] 1 ] $intensite
	}
	buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda0deg1 float "" "angstrom" ]
	#buf$audace(bufNo) setkwd [ list "CRVAL1" $b float "" "angstrom" ]
	buf$audace(bufNo) setkwd [ list "CDELT1" $a float "" "angstrom/pixel" ]
	buf$audace(bufNo) delkwd "SPC_A"
	buf$audace(bufNo) delkwd "SPC_B"
	buf$audace(bufNo) delkwd "SPC_C"
	if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
	    buf$audace(bufNo) delkwd "SPC_D"
	}
	if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
	    buf$audace(bufNo) delkwd "SPC_RMS"
	}
	if { [ lsearch $listemotsclef "SPC_DESC" ] !=-1 } {
	    buf$audace(bufNo) delkwd "SPC_DESC"
	}


	#--- Traitement du résultat :
        buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filename}_linear"
        buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Le profil rééchantillonné linéairement est sauvé sous ${filename}_linear\n"
	return ${filename}_linear
    } else {
	::console::affiche_erreur "Usage: spc_echantlin nom_profil_raies\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calibration a partir d'un spectre etalon
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

	#--- Calcul du profil de raies du spectre étalon :
	set linecoords [ spc_detect $spcacalibrer ]
	set ysup [ expr int([ lindex $linecoords 0 ]+[ lindex $linecoords 1 ]) ]
	set yinf [ expr int([ lindex $linecoords 0 ]-[ lindex $linecoords 1 ]) ]
	buf$audace(bufNo) load "$audace(rep_images)/$spetalon"
	set intensite_fond [ lindex [ buf$audace(bufNo) stat ] 6 ]
	buf$audace(bufNo) imaseries "BINY y1=$yinf y2=$ysup height=1"
	buf$audace(bufNo) save "$audace(rep_images)/${spetalon}_spc"

	#--- Détemination du centre de chaque raies détectées dans le spectre étalon :
	set listemax [ spc_findlines ${spetalon}_spc 20 ]
	#-- Algo : fait avancer de 10 pixels un fitgauss {x1 1 x2 1}, recupere le Xmax et centreX, puis tri selon Xmax et garde les 6 plus importants 
	set nbraies [ llength $listemax ]

	#--- Calibration du spectre etalon ;
	#-- Algo : fait une premiere calibrae avec 2 raies, puis se sert de la loi pour associer une lambda aux autres raies (>=3) et fait une calibrtion polynomile si d'autres raies existent

	#--- Calibration du spectre à calibrer :
	if { $nbraies== 1 } {
	    ::console::affiche_resultat "Pas assez de raies calibrer en longueur d'onde\n"
	} elseif { $nbraies==2 } {
	    set fileout [ spc_calibre2loifile $l{spetalon}_spc $spacalibrer ]
	} else {
	    set fileout [ spc_calibre3loifile $l{spetalon}_spc $spacalibrer ]
	}

	#--- Affichage des résultats :
	::console::affiche_resultat "Le spectre calibré est sauvé sous $fileout\n"
	return $fileout
    } else {
       ::console::affiche_erreur "Usage: spc_calibrelampe profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#***************************************************************************#



##########################################################
# Effectue la calibration en longueur d'onde d'un spectre avec n raies et interface graphique
# Attention : GUI présente !
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 17-09-2006
# Date de mise à jour : 20-09-2006
# Arguments : profil_lampe_calibration
##########################################################

proc spc_calibre { args } {

   global audace spcaudace
   global conf caption
   #- spcalibre : nom de la variable retournee par la gui param_spc_audace_calibreprofil
   global spcalibre

   if { [llength $args] <= 1 } {
       if { [llength $args] == 1 } {
	   set profiletalon [ lindex $args 0 ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set profiletalon $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer\n\n"
	   return 0
       }

       spc_loadfit $profiletalon
       #--- Détection des raies dans le profil de raies de la lampe :
       set raies [ spc_findbiglines $profiletalon e ]
       #foreach raie $raies {
	#   lappend listeabscisses [ lindex $raie 0 ]
       #}
       set listeabscisses_i $raies

       #--- Elaboration des listes de longueurs d'onde :
       set listelambdaschem [ spc_readchemfiles ] 
       #::console::affiche_resultat "Chim : $listelambdaschem\n"
       set listeargs [ list $profiletalon $listeabscisses_i $listelambdaschem ]

       #--- Affichage de l'image du neon de la bibliothèque de calibration :
       loadima $spcaudace(rep_spccal)/Neon.jpg
       visu1 zoom 1
       #::confVisu::setZoom 1 1
       ::confVisu::autovisu 1
       visu1 disp {251 -15}


       #--- Boîte de dialogue pour saisir les paramètres de calibration :
       set err [ catch {
	   ::param_spc_audace_calibreprofil::run $listeargs
	   tkwait window .param_spc_audace_calibreprofil
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }

	
       #--- Effectue la calibration de la lampe spectrale : 
       # set etaloncalibre [ spc_calibren $profiletalon $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]
       # NON : file delete "$audace(rep_images)/$profiletalon$conf(extension,defaut)"
       visu1 zoom 0.5
       #::confVisu::setZoom 0.5 0.5
       ::confVisu::autovisu 1

       if { $spcalibre != "" } {
	   loadima $spcalibre
	   return $spcalibre
       } else {
	   ::console::affiche_erreur "La calibration a échouée.\n"
	   return ""
       }
   } else {
       ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction d'étalonnage à partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-04-2007
# Date modification : 21-04-2007/27-04-2007(int->round)
# Arguments : nom_profil_raies
####################################################################

proc spc_autocalibrehaeau { args } {
    global conf
    global audace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.5
    set ecart 1.0
    #set ecart 1.2
    #set erreur 0.01
    set ldeb 6528.0
    set lfin 6580.0
    #-- Liste C.Buil :
    ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
	if { $nbargs == 1 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set largeur 28
	} elseif { $nbargs == 2 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set largeur [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_autocalibrehaeau nom_profil_de_raies ?largeur_raie (pixel)?\n"
	    return 0
	}
	#set pas [ expr int($largeur/2) ]

	#--- Gestion des profils calibrés en longueur d'onde :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	#-- Retire les petites raies qui seraient des pixels chauds ou autre :
	#buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
	#-- Renseigne sur les parametres de l'image :
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
	set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
	#- CAs non-lineaire :
	set listemotsclef [ buf$audace(bufNo) getkwds ]
	if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	    set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
	    set flag_spccal 1
	    set spc_a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
	    set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
	    set spc_c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
	    if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
		set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
	    } else {
		set spc_d 0.
	    }
	} else {
	    set flag_spccal 0
	}
	#-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
	set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]

	#--- Calcul des xdeb et xfin bornant les 6 raies de l'eau :
	if { $ldeb>$crval1+2. && $lfin<[ expr $naxis1*$cdelt1+$crval1-2. ] } {
	    set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) ]
	    set xfin [ expr round(($lfin-$crval1)/$cdelt1) ]
	} else {
	    ::console::affiche_resultat "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
	    return ""
	}

	#--- Filtrage pour isoler le continuum :
	set ffiltered [ spc_smoothsg $filename $largeur ]
	set fcont1 [ spc_div $filename $ffiltered ]

	#--- Inversion et mise a 0 du niveau moyen :
	buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
	set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
	buf$audace(bufNo) mult -1.0
	buf$audace(bufNo) offset $icontinuum
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
	buf$audace(bufNo) bitpix short

	#--- Recherche des raies d'émission :
	::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
	#buf$audace(bufNo) scale {1 3} 1
	set nbraies [ llength $listeraies ]
	foreach raie $listeraies {
	    if { $flag_spccal } {
		set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)) ]
		set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)) ]
		set coords [ list $x1 1 $x2 1 ]
		set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
		##set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
		lappend listemesures $xcenter
		lappend listelmesurees [ expr $spc_a+$xcenter*$spc_b+$xcenter*$xcenter*$spc_c+pow($xcenter,3)*$spc_d ]
	    } else {
		set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1) ]
		set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1) ]
		set coords [ list $x1 1 $x2 1 ]
		set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
		#set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
		lappend listemesures $xcenter
		lappend listelmesurees [ expr $xcenter*$cdelt1+$crval1 ]
	    }
	    lappend errors $mes_incertitude


	  if { 1==0 } {
	    if { $largeur == 0 } {
		# set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
		set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 1 ]
		lappend listemesures $xcenter
		lappend listelmesurees [ expr $xcenter*$cdelt1+$crval1 ]
	    } else {
		#set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
		set xcenter [ lindex [ buf$audace(bufNo) centro $coords $largeur ] 1 ]
		lappend listemesures $xcenter
		lappend listelmesurees [ expr $xcenter*$cdelt1+$crval1 ]
	    }
	  }


	}
	::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
	# ::console::affiche_resultat "Liste des raies trouvées : $listemesures\n"
	::console::affiche_resultat "Liste des raies de référence :\n$listeraies\n"

	#--- Effacement des fichiers temporaires :
	file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

      if { 1==1} {
	#-------------------- Non utilisé ----------------------------#
	if { 0==1} {
	#--- Constitution de la chaine x_n lambda_n :
	#foreach mes $listemesures eau $listeraies {
	    # append listecoords "$mes $eau "
	#    append listecoords $mes
	#    append listecoords $eau
	#}
	#::console::affiche_resultat "Coords : $listecoords\n"
	set i 1
	foreach mes $listemesures eau $listeraies {
	    set x$i $mes
	    set l$i $eau
	    incr i
	}

	#--- Calibration en longueur d'onde :
	::console::affiche_resultat "Calibration du profil avec les raies de l'eau...\n"
	#set calibreargs [ list $filename $listecoords ]
	#set len [ llength $calibreargs ]
	#::console::affiche_resultat "$len args : $calibreargs\n"
	#set sortie [ spc_calibren $calibreargs ]
	set sortie [ spc_calibren $filename $x1 $l1 $x2 $l2 $x3 $l3 $x4 $l4 $x5 $l5 $x6 $l6 ]
	return $sortie
        }
	#------------------------------------------------------------#
	    
	#--- Calcul du polynôme de calibration a+bx+cx^2 :
	set sortie [ spc_ajustdeg2 $listemesures $listeraies $errors ]
 	set coeffs [ lindex $sortie 0 ]
	set c [ lindex $coeffs 2 ]
	set b [ lindex $coeffs 1 ]
	set a [ lindex $coeffs 0 ]
	set chi2 [ lindex $sortie 1 ]
	set covar [ lindex $sortie 2 ]
	::console::affiche_resultat "Chi2=$chi2\n"
	if { $flag_spccal } {
	    set lambda0deg2 [ expr $a+$b+$c ]
	    set lambda0deg2 [ expr $a+$spc_b+$spc_c ]
	} else {
	    set lambda0deg2 [ expr $a+$b+$c ]
	}
	set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
	::console::affiche_resultat "RMS=$rms angstrom\n"

	#--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
	    lappend xpos $x
	    #lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
	    lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
	    lappend errorsd1 $mes_incertitude
	}
	set listevals [ list $xpos $lambdaspoly ]
	#set sortie1 [ spc_ajustdeg1 $xpos $lambdaspoly $errorsd1 ]
	set coeffsdeg1 [ spc_reglin $listevals ]
	set a1 [ lindex $coeffsdeg1 0 ]
	set b1 [ lindex $coeffsdeg1 1 ]
	#-- Valeur théorique :
	set lambda0deg1 [ expr $a1+$b1 ]
	#-- Correction empirique :
	set lambda0deg1 [ expr 1.*$b1 ]


	#--- Nouvelle valeur de Lambda0 :
	#set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
	#-- Reglages :
	#- 40 -10 l0deg1 : AB
	#- 40 -40 l0deg1 : AB+
	#- 20 -10 l0deg2 : AB++

	#-- Valeur théorique :
	# set lambda0 $lambda0deg2
	#-- Correction empirique :
	set lambda0 [ expr $lambda0deg2-2.*$cdelt1 ]
	#set lambda0 $a


	if { 1==0 } {
	#--- Redonne le lambda du centre des raies apres réétalonnage :
	set ecart2 0.6
	foreach raie $listeraies {
	    set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1) ]
	    set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1) ]
	    set coords [ list $x1 1 $x2 1 ]
	    if { $largeur == 0 } {
		set x [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
		#lappend listemesures $xcenter
		# lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
		lappend listelmesurees2 [ expr $lambda0+$cdelt1*$x ]
	    } else {
		set x [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
		#lappend listemesures $xcenter
		lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
	    }
	}
	#::console::affiche_resultat "Liste des raies après réétalonnage :\n$listelmesurees2\nÀ comparer avec :\n$listeraies\n"
        }


	#--- Mise à jour des mots clefs :
	buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
	#-- Longueur d'onde de départ :
	buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0deg1 float "" "angstrom"]
	#-- Dispersion moyenne :
	#buf$audace(bufNo) setkwd [list "CDELT1" $a1 float "" "angstrom/pixel"]
	#buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
	#-- Corrdonnée représentée sur l'axe 1 (ie X) :
	#buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
	#-- Mots clefs du polynôme :
	if { $flag_spccal } {
	    buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
	    #buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
	    buf$audace(bufNo) setkwd [list "SPC_A" $lambda0 float "" "angstrom"]
	    buf$audace(bufNo) setkwd [list "SPC_RMS" $rms float "" "angstrom"]
	} else {
	    buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
	    #buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
	    buf$audace(bufNo) setkwd [list "SPC_A" $lambda0deg2 float "" "angstrom"]
	    buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "angstrom/pixel"]
	    buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "angstrom.angstrom/pixel.pixel"]
	    buf$audace(bufNo) setkwd [list "SPC_RMS" $rms float "" "angstrom"]
	}

	#--- Sauvegarde :
	set fileout "${filename}-ocal"
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/$fileout"

	#--- Fin du script :
	::console::affiche_resultat "Spectre étalonné sauvé sous $fileout\n"
	return $fileout
     }
   } else {
       ::console::affiche_erreur "Usage: spc_autocalibrehaeau profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#






####################################################################
# Procédure de recalage en longueur d'onde a partir d'une raie tellurique de l'eau
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-03-2007
# Date modification : 25-03-2007
# Arguments : profil_de_raies_étoile_référence profil_de_raies_a_calibrer lambda_eau_mesurée_6532
####################################################################

proc spc_calibrehaeau { args } {
    global conf
    global audace

    set ldeb 6528.0
    set lfin 6580.0
    #-- Liste C.Buil :
    ## set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    #set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    #-- Liste ESO-Pollman :
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]

    if { [llength $args]==3 } {
	set spreference [ lindex $args 0 ]
	set spacalibrer [ lindex $args 1 ]
	set leau [ lindex $args 2 ]


	#--- Affichage des résultats :
	::console::affiche_resultat "Le spectre calibré est sauvé sous $fileout\n"
	return ""
    } else {
       ::console::affiche_erreur "Usage: spc_calibrehaeau profil_de_raies_étoile_référence profil_de_raies_a_calibrer lambda_eau_mesurée_6532\n\n"
   }
}
#***************************************************************************#




####################################################################
# Fonction d'étalonnage à partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 30-09-2006
# Date modification : 03-10-2006
# Arguments : nom_profil_raies
####################################################################

proc spc_autocalibrehaeau1 { args } {
    global conf
    global audace
    # set pas 10
    #set ecart 4.0
    set ecart 1.5
    #set erreur 0.01
    set ldeb 6528.0
    set lfin 6580.0
    #-- Liste C.Buil :
    ## set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    #set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    #-- Liste ESO-Pollman :
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
	if { $nbargs == 1 } {
	    set filename [ lindex $args 0 ]
	    set largeur 0
	} elseif { $nbargs == 2 } {
	    set filename [ lindex $args 0 ]
	    set largeur [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_autocalibrehaeau nom_profil_de_raies ?largeur_raie (pixel)?\n"
	    return 0
	}
	#set pas [ expr int($largeur/2) ]

	#--- Gestion des profils calibrés en longueur d'onde :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	#-- Retire les petites raies qui seraient des pixels chauds ou autre :
	#buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
	#-- Renseigne sur les parametres de l'image :
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
	set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
	#-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
	set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]

	#--- Calcul des xdeb et xfin bornant les 6 raies de l'eau :
	if { $ldeb>$crval1+2. && $lfin<[ expr $naxis1*$cdelt1+$crval1-2. ] } {
	    set xdeb [ expr int(($lfin-$crval1)/$cdelt1) ]
	    set xfin [ expr int(($lfin-$crval1)/$cdelt1) ]
	} else {
	    ::console::affiche_resultat "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
	    return ""
	}

	#--- Recherche des raies d'émission :
	::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
	buf$audace(bufNo) mult -1.0
	set nbraies [ llength $listeraies ]
	foreach raie $listeraies {
	    set x1 [ expr int(($raie-$ecart-$crval1)/$cdelt1) ]
	    set x2 [ expr int(($raie+$ecart-$crval1)/$cdelt1) ]
	    set coords [ list $x1 1 $x2 1 ]
	    if { $largeur == 0 } {
		set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
		lappend listemesures $xcenter
		lappend listelmesurees [ expr $xcenter*$cdelt1+$crval1 ]
	    } else {
		set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
		lappend listemesures $xcenter
		lappend listelmesurees [ expr $xcenter*$cdelt1+$crval1 ]
	    }
	    lappend errors $mes_incertitude
	}
	::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
	# ::console::affiche_resultat "Liste des raies trouvées : $listemesures\n"
	::console::affiche_resultat "Liste des raies de référence :\n$listeraies\n"

	#------------------------------------------------------------#
	set flag 0
	if { $flag==1} {
	#--- Constitution de la chaine x_n lambda_n :
	#foreach mes $listemesures eau $listeraies {
	    # append listecoords "$mes $eau "
	#    append listecoords $mes
	#    append listecoords $eau
	#}
	#::console::affiche_resultat "Coords : $listecoords\n"
	set i 1
	foreach mes $listemesures eau $listeraies {
	    set x$i $mes
	    set l$i $eau
	    incr i
	}

	#--- Calibration en longueur d'onde :
	::console::affiche_resultat "Calibration du profil avec les raies de l'eau...\n"
	#set calibreargs [ list $filename $listecoords ]
	#set len [ llength $calibreargs ]
	#::console::affiche_resultat "$len args : $calibreargs\n"
	#set sortie [ spc_calibren $calibreargs ]
	set sortie [ spc_calibren $filename $x1 $l1 $x2 $l2 $x3 $l3 $x4 $l4 $x5 $l5 $x6 $l6 ]
	return $sortie
        }
	#------------------------------------------------------------#
	    
	#--- Calcul du polynôme de calibration a+bx+cx^2 :
	set sortie [ spc_ajustdeg2 $listemesures $listeraies $errors ]
 	set coeffs [ lindex $sortie 0 ]
	set c [ lindex $coeffs 2 ]
	set b [ lindex $coeffs 1 ]
	set a [ lindex $coeffs 0 ]
	set chi2 [ lindex $sortie 1 ]
	set covar [ lindex $sortie 2 ]
	::console::affiche_resultat "Chi2=$chi2\n"
	set lambda0deg2 [ expr $a+$b+$c ]
	set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
	::console::affiche_resultat "RMS=$rms angstrom\n"

	#--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
	    lappend xpos $x
	    lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
	    lappend errorsd1 $mes_incertitude
	}
	set listevals [ list $xpos $lambdaspoly ]
	#set sortie1 [ spc_ajustdeg1 $xpos $lambdaspoly $errorsd1 ]
	set coeffsdeg1 [ spc_reglin $listevals ]
	set a1 [ lindex $coeffsdeg1 0 ]
	set b1 [ lindex $coeffsdeg1 1 ]
	set lambda0deg1 [ expr $a1+$b1 ]


	#--- Nouvelle valeur de Lambda0 :
	#set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
	#-- Reglages :
	#- 40 -10 l0deg1 : AB
	#- 40 -40 l0deg1 : AB+
	#- 20 -10 l0deg2 : AB++
	set lambda0 $lambda0deg2


	#--- Redonne le lambda du centre des raies apres réétalonnage :
	set ecart2 0.6
	foreach raie $listeraies {
	    set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1) ]
	    set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1) ]
	    set coords [ list $x1 1 $x2 1 ]
	    if { $largeur == 0 } {
		set x [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
		#lappend listemesures $xcenter
		# lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
		lappend listelmesurees2 [ expr $lambda0+$cdelt1*$x ]
	    } else {
		set x [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
		#lappend listemesures $xcenter
		lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
	    }
	}
	#::console::affiche_resultat "Liste des raies après réétalonnage :\n$listelmesurees2\nÀ comparer avec :\n$listeraies\n"


	#--- Mise à jour des mots clefs :
	buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
	#-- Longueur d'onde de départ :
	buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
	#-- Dispersion moyenne :
	#buf$audace(bufNo) setkwd [list "CDELT1" $a1 float "" "angstrom/pixel"]
	#buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
	#-- Corrdonnée représentée sur l'axe 1 (ie X) :
	#buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
	#-- Mots clefs du polynôme :
	buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
	buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
	#buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "angstrom/pixel"]
	#buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "angstrom.angstrom/pixel.pixel"]
	buf$audace(bufNo) setkwd [list "SPC_RMS" $rms float "" "angstrom"]

	#--- Sauvegarde :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/l${filename}"

	#--- Fin du script :
	::console::affiche_resultat "Spectre étalonné sauvé sous l${filename}\n"
	return l${filename}

   } else {
       ::console::affiche_erreur "Usage: spc_autocalibrehaeau profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de correction de la vitesse héliocentrique de la calibration en longueur d'onde
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 05-03-2007
# Date de mise à jour : 05-03-2007
# Arguments : profil_raies_étalonné lambda_calage ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
##########################################################

proc spc_corrvhelio { args } {

   global audace
   global conf

   if { [llength $args] == 2 || [llength $args] == 8 || [llength $args] == 11 } {
       if { [llength $args] == 1 } {
	   set spectre [ lindex $args 0 ]
	   set lambda_cal [ lindex $args 1 ]
	   set vhelio [ spc_vhelio $spectre ]
       } elseif { [llength $args] == 8 } {
	   set spectre [ lindex $args 0 ]
	   set lambda_cal [ lindex $args 1 ]
	   set ra_h [ lindex $args 2 ]
	   set ra_m [ lindex $args 3 ]
	   set ra_s [ lindex $args 4 ]
	   set dec_d [ lindex $args 5 ]
	   set dec_m [ lindex $args 6 ]
	   set dec_s [ lindex $args 7 ]
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s ]
       } elseif { [llength $args] == 11 } {
	   set spectre [ lindex $args 0 ]
	   set lambda_cal [ lindex $args 1 ]
	   set ra_h [ lindex $args 2 ]
	   set ra_m [ lindex $args 3 ]
	   set ra_s [ lindex $args 4 ]
	   set dec_d [ lindex $args 5 ]
	   set dec_m [ lindex $args 6 ]
	   set dec_s [ lindex $args 7 ]
	   set jj [ lindex $args 8 ]
	   set mm [ lindex $args 9 ]
	   set aaaa [ lindex $args 10 ]
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s $jj $mm $aaaa ]
       } else {
	   #::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ?[[?RA_d RA_m RA_s DEC_h DEC_m DEC_s?] ?JJ MM AAAA?]?\n\n"
	   ::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA??\n\n"
	   return 0
       }

       #--- Calcul du décalage en longueur d'onde pour lambda_ref :
       set deltal [ expr $lambda_cal*$vhelio/299792.458 ]
       #--- Recalage en longueur d'onde du spectre :
       set fileout [ spc_calibredecal $spectre $deltal ]

       #--- Traitement du résultat :
       file rename -force "$audace(rep_images)/$fileout$conf(extension,defaut)" "$audace(rep_images)/${spectre}_vhel$conf(extension,defaut)"
       ::console::affiche_resultat "Spectre décalé de $deltal A sauvé sous ${spectre}_vhel\n"
       return ${spectre}_vhel
   } else {
       #::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ?[[?RA_d RA_m RA_s DEC_h DEC_m DEC_s?] ?JJ MM AAAA?]?\n\n"
       ::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ??RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA??\n\n"
       return 0
   }
}

















#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#            Correction de la réponse instrumentale                          #
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division 
##########################################################

proc spc_rinstrum { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

     #===================================================================#
     if { 1==0 } {
       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
	   #-- Détermine le spectre de dispersion la plus précise
	   set carac1 [ spc_info $fichier_mes ]
	   set carac2 [ spc_info $fichier_ref ]
	   set disp1 [ lindex $carac1 5 ]
	   set ldeb1 [ lindex $carac1 3 ]
	   set lfin1 [ lindex $carac1 4 ]
	   set disp2 [ lindex $carac2 5 ]
	   set ldeb2 [ lindex $carac2 3 ]
	   set lfin2 [ lindex $carac2 4 ]
	   if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Rééchantillonnage et crop du spectre de référence fichier_ref
	       ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
	       #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
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
	       #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
	       ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_sortie $fref_ech
	       set fmes_sortie $fmes_sel
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sortie $fref_sel
	       set fmes_sortie $fichier_mes
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_sortie $fichier_ref
	       set fmes_sortie $fmes_sel
	   } else {
	       #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
	       ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
	   }
       } else {
	   #-- Aucun rééchantillonnage ni redécoupage nécessaire
	   ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
	   set fref_sortie $fichier_ref
	   set fmes_sortie $fichier_mes
       }
    }
    #======================================================================#

       #--- Rééchanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nRééchantillonnage du spectre de référence...\n"
       set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]

    if {1==0} {
       #--- Recalage du profil de catalogue sur le pixel central du capteur :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier_mes"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set naxis1m [ expr int(0.5*[ lindex [buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]) ]
       set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set lambdam_mes [ expr $lambda0+$cdelt1*$naxis1m ]
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
	   set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	   set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
	   if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
	       set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
	   } else {
	       set spc_d 0.0
	   }
	   set lambdam_mes [ expr $spc_a+$spc_b*$naxis1m+$spc_c*pow($naxis1m,2)+$spc_d*pow($naxis1m,3) ]
       } else {
	   set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	   set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	   set lambdam_mes [ expr $lambda0+$cdelt1*$naxis1m ]
       }
       buf$audace(bufNo) load "$audace(rep_images)/$fref_sortie"
       set naxis1m [ expr int(0.5*[ lindex [buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]) ]
       set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set lambdam_ref [ expr $lambda0+$cdelt1*$naxis1m ]
       set deltal [ expr $lambdam_mes-$lambdam_ref ]
       if { $deltal>[ expr $cdelt1/10.] } {
	   ::console::affiche_resultat "Décalage de $deltal angstroms entre les 2 profils, recalage du profil de l'étoile du catalogue...\n"
	   buf$audace(bufNo) load "$audace(rep_images)/$fmes_sortie"
	   set listemotsclef [ buf$audace(bufNo) getkwds ]
	   set lambda0dec [ expr $lambda0+$deltal ]
	   buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda0dec float "" "angstrom" ]
	   if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	        buf$audace(bufNo) setkwd [list "SPC_A" $lambda0dec float "" "angstrom"]
	   }
	   buf$audace(bufNo) bitpix float
	   buf$audace(bufNo) save "$audace(rep_images)/${fmes_sortie}_dec"
	   buf$audace(bufNo) bitpix short
	   set fref_sortie [ spc_echant ${fmes_sortie}_dec $fichier_ref ]
	   #file delete -force "$audace(rep_images)/${fmes_sortie}_dec"
       }
   }
       
       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]


       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la réponse instrumentale...\n"
       #-- Meth 1 :
       #set rinstrum1 [ spc_smooth2 $rinstrum0 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 ]
       #set rinstrum [ spc_passebas $rinstrum3 ]

       #-- Meth2 pour 2400 t/mm : 3 passebas (110, 35, 10) + spc_smooth2.
       #set rinstrum1 [ spc_passebas $rinstrum0 110 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 35 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 10 ]
       #set rinstrum [ spc_smooth2 $rinstrum3 ]

       #-- Meth 6 : filtrage linéaire par morçeaux -> RI 0 spéciale basse résulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"


       #-- Meth 3 : interpolation polynomiale de degré 1 -> RI 1 
       set rinstrum [ spc_ajustrid1 $result_division ]
       file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale1$conf(extension,defaut)"
       #-- Meth 4 : interpolation polynomiale de 2 -> RI 2
       set rinstrum [ spc_ajustrid2 $result_division ]
       file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale2$conf(extension,defaut)"

       #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
       set rinstrum [ spc_ajustripbas $result_division ]
       file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale3$conf(extension,defaut)"


       #--- Nettoyage des fichiers temporaires :
       file rename -force "$audace(rep_images)/$result_division$conf(extension,defaut)" "$audace(rep_images)/resultat_division$conf(extension,defaut)"
       #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       
       if { $fmes_sortie != $fichier_mes } {
	   file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       if { $fref_sortie != $fichier_ref } {
	   #- A decommenter :
	   #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       }
       if { $rinstrum == 0 } {
	   ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   #-- Résultat de la division :
	   ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
	   ::console::affiche_resultat "Réponse instrumentale sauvée sous reponse_instrumentale3$conf(extension,defaut)\n"
	   return reponse_instrumentale3
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#



##########################################################
# Effectue la correction de la réponse intrumentale à l'aide du profil_a_corriger, profil_étoile_référence et profil_étoile_catalogue
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 14-07-2006
# Date de mise à jour : 14-07-2006
# Arguments : profil_a_corriger profil_étoile_référence profil_étoile_catalogue
##########################################################

proc spc_rinstrumcorr { args } {

   global audace
   global conf
   if { [llength $args] == 3 } {
       set spectre_acorr [ file rootname [ lindex $args 0 ] ]
       set etoile_ref [ file rootname [ lindex $args 1 ] ]
       set etoile_cat [ file rootname [ lindex $args 2 ] ]

       set rinstrum [ spc_rinstrum $etoile_ref $etoile_cat ]
       #set rinstrum_ech [ spc_echant $rinstrum $spectre_acorr ]
       #set spectre_corr [ spc_div $spectre_acorr $rinstrum_ech ]
       #file delete "$audace(rep_images)/$rinstrum_ech$conf(extension,defaut)"
       set spectre_corr [ spc_divri $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
	   ::console::affiche_resultat "\nLe profil corrigé de la réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_ricorr$conf(extension,defaut)"
	   ::console::affiche_resultat "\nProfil corrigé de la réponse intrumentale sauvé sous ${spectre_acorr}_ricorr.\n\n"
	   return ${spectre_acorr}_ricorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumcorr profil_a_corriger profil_étoile_référence profil_étoile_catalogue\n\n"
   }
}
#****************************************************************#




##########################################################
# Calcul la réponse intrumentale avec les raies telluriques de l'eau
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division 
##########################################################

proc spc_rinstrumeau { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
	   #-- Détermine le spectre de dispersion la plus précise
	   set carac1 [ spc_info $fichier_mes ]
	   set carac2 [ spc_info $fichier_ref ]
	   set disp1 [ lindex $carac1 5 ]
	   set ldeb1 [ lindex $carac1 3 ]
	   set lfin1 [ lindex $carac1 4 ]
	   set disp2 [ lindex $carac2 5 ]
	   set ldeb2 [ lindex $carac2 3 ]
	   set lfin2 [ lindex $carac2 4 ]
	   if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Rééchantillonnage et crop du spectre de référence fichier_ref
	       ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
	       #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
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
	       #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
	       ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_sortie $fref_ech
	       set fmes_sortie $fmes_sel
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sortie $fref_sel
	       set fmes_sortie $fichier_mes
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_sortie $fichier_ref
	       set fmes_sortie $fmes_sel
	   } else {
	       #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
	       ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
	   }
       } else {
	   #-- Aucun rééchantillonnage ni redécoupage nécessaire
	   ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
	   set fref_sortie $fichier_ref
	   set fmes_sortie $fichier_mes
       }

       #--- Linéarisation des deux profils de raies
       ::console::affiche_resultat "Linéarisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth $fref_sortie ]
       set fmes_ready [ spc_bigsmooth $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
	   file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]
       #-- Rééchantillonne le continuum avec l'eau pour obtenir la même dispersion que celle du spectre de mesures :
       #set rinstrumeau [ spc_echant $rinstrum $fichier_mes ]
       set rinstrumeau $rinstrum

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrumeau == 0 } {
	   ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$rinstrumeau$conf(extension,defaut)" "$audace(rep_images)/${fichier_mes}_rinstrumeau$conf(extension,defaut)"
	   ::console::affiche_resultat "Réponse instrumentale sauvée sous ${fichier_mes}_rinstrumeau$conf(extension,defaut)\n"
	   return ${fichier_mes}_rinstrumeau
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumeau profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#


##########################################################
# Effectue la correction de la réponse intrumentale à l'aide du profil_a_corriger, profil_étoile_référence et profil_étoile_catalogue *** tout en retirant les raies telluriques ***
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 25-08-2006
# Date de mise à jour : 25-08-2006
# Arguments : profil_a_corriger profil_étoile_référence profil_étoile_catalogue
##########################################################

proc spc_rinstrumeaucorr { args } {

   global audace
   global conf
   if { [llength $args] == 3 } {
       set spectre_acorr [ file rootname [ lindex $args 0 ] ]
       set etoile_ref [ file rootname [ lindex $args 1 ] ]
       set etoile_cat [ file rootname [ lindex $args 2 ] ]

       set rinstrum [ spc_rinstrumeau $etoile_ref $etoile_cat ]
       #set rinstrum_ech [ spc_echant $rinstrum $spectre_acorr ]
       #set spectre_corr [ spc_div $spectre_acorr $rinstrum_ech ]
       #file delete "$audace(rep_images)/$rinstrum_ech$conf(extension,defaut)"
       set spectre_corr [ spc_divri $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
	   ::console::affiche_resultat "\nLe profil corrigé de la réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_riocorr$conf(extension,defaut)"
	   ::console::affiche_resultat "\nProfil corrigé de la réponse intrumentale et des raies tellurtiques sauvé sous ${spectre_acorr}_riocorr.\n\n"
	   return ${spectre_acorr}_riocorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumeaucorr profil_a_corriger profil_étoile_référence profil_étoile_catalogue\n\n"
   }
}
#****************************************************************#




####################################################################
# Procedure d'ajustement d'un nuage de points de réponse instrumentale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2007
# Date modification : 27-02-2007
# Arguments : fichier .fit de la réponse instrumentale
# Algo : ajustement par un polynome de degré 1 avec abaissement global basé sur la moyenne de la difference des valeurs y_deb et y_fin de l'intervalle.
####################################################################

proc spc_ajustrid1 { args } {
    global conf
    global audace

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]

	#--- Initialisation des paramètres et des données :
	set erreur 1.
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement :
	# - calcul de la matrice X 
	set n [llength $abscisses]
	set x ""
	set X "" 
	for {set i 0} {$i<$n} {incr i} { 
	    set xi [lindex $abscisses $i] 
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi 
	    lappend X $ligne_i 
	} 
	#-- calcul de l'ajustement 
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ] 
	#-- extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	::console::affiche_resultat "Coefficients : $a+$b*x\n"

	#--- Calcul la valeur a retrancher : basée sur la difference moyenne y_deb et y_fin calculee par rapport aux mesures :
	set ecart 30
	set xdeb [ lindex $abscisses $ecart ]
	set xfin [ lindex $abscisses [ expr $len-$ecart-1 ] ]
	set ycalc_deb [ expr $a+$b*$xdeb ]
	set ycalc_fin [ expr $a+$b*$xfin ]
	set ymes_deb [ lindex $ordonnees $ecart ]
	set ymes_fin [ lindex $ordonnees [ expr $len-$ecart-1 ] ]
	#::console::affiche_resultat "$ycalc_deb ; $ycalc_fin ; $ymes_deb ; $ymes_fin\n"
	## set dy_moy [ expr 0.5*(abs($ycalc_deb-$ymes_deb)+abs($ycalc_fin-$ymes_fin)) ]
	set dy_moy [ expr 0.5*($ycalc_deb-$ymes_deb+$ycalc_fin-$ymes_fin) ]
	#::console::affiche_resultat "Offset à retrancher : $dy_moy\n"
	set aadj [ expr $a-$dy_moy ]
	#set aadj $a

	#--- Met a jour les nouvelles intensités :
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	for {set k 1} {$k<=$naxis1} {incr k} {
	    set x [ lindex $abscisses [ expr $k-1 ] ]
	    set y [ lindex $ordonnees [ expr $k-1 ] ]
	    if { $y==0 } {
		set yadj 0.
	    } else {
		set yadj [ expr $aadj+$b*$x ]
	    }
	    lappend yadjs $yadj
	    buf$audace(bufNo) setpix [list $k 1] $yadj
	}


	#--- Affichage du graphe
	::plotxy::figure 1
	#::plotxy::clf
	::plotxy::plot $abscisses $yadjs g 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	::plotxy::title "bleu : Résultat division - rouge : RI interpolée deg 1"
	::plotxy::hold off

        #--- Sauvegarde du résultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
	return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajustrid1 fichier_profil.fit\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points de réponse instrumentale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-02-2007
# Date modification : 26-02-2007
# Arguments : fichier .fit de la réponse instrumentale
# Algo : ajustement par un polynome de degré 2 avec abaissement global basé sur la moyenne de la difference des valeurs y_deb et y_fin de l'intervalle.
####################################################################

proc spc_ajustrid2 { args } {
    global conf
    global audace

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]

	#--- Initialisation des paramètres et des données :
	set erreur 1.
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement :
	# - calcul de la matrice X 
	set n [llength $abscisses]
	set x ""
	set X "" 
	for {set i 0} {$i<$n} {incr i} { 
	    set xi [lindex $abscisses $i] 
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi 
	    lappend ligne_i [expr $xi*$xi]
	    lappend X $ligne_i 
	} 
	#-- calcul de l'ajustement 
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ] 
	#-- extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Calcul la valeur a retrancher : basée sur la difference moyenne y_deb et y_fin calculee par rapport aux mesures :
	set ecart 30
	set xdeb [ lindex $abscisses $ecart ]
	set xfin [ lindex $abscisses [ expr $len-$ecart-1 ] ]
	set ycalc_deb [ expr $a+$b*$xdeb+$c*$xdeb*$xdeb ]
	set ycalc_fin [ expr $a+$b*$xfin+$c*$xfin*$xfin ]
	set ymes_deb [ lindex $ordonnees $ecart ]
	set ymes_fin [ lindex $ordonnees [ expr $len-$ecart-1 ] ]
	#::console::affiche_resultat "$ycalc_deb ; $ycalc_fin ; $ymes_deb ; $ymes_fin\n"
	## set dy_moy [ expr 0.5*(abs($ycalc_deb-$ymes_deb)+abs($ycalc_fin-$ymes_fin)) ]
	set dy_moy [ expr 0.5*($ycalc_deb-$ymes_deb+$ycalc_fin-$ymes_fin) ]
	#::console::affiche_resultat "Offset à retrancher : $dy_moy\n"
	set aadj [ expr $a-$dy_moy ]
	#set aadj $a

	#--- Met a jour les nouvelles intensités :
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	for {set k 1} {$k<=$naxis1} {incr k} {
	    set x [ lindex $abscisses [ expr $k-1 ] ]
	    set y [ lindex $ordonnees [ expr $k-1 ] ]
	    if { $y==0 } {
		set yadj 0.
	    } else {
		set yadj [ expr $aadj+$b*$x+$c*$x*$x ]
	    }
	    lappend yadjs $yadj
	    buf$audace(bufNo) setpix [list $k 1] $yadj
	}


	#--- Affichage du graphe
	#::plotxy::clf
	::plotxy::figure 2
	::plotxy::plot $abscisses $yadjs r 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	::plotxy::title "bleu : Résultat division - rouge : RI interpolée deg 2"
	::plotxy::hold off


        #--- Sauvegarde du résultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
	return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajustrid2 fichier_profil.fit\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points 
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-03-2007
# Date modification : 03-03-2007
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajustripbas { args } {
    global conf
    global audace

    if { [ llength $args ]==1 } {
	set filenamespc [ lindex $args 0 ]

	#--- Filtrages passe-bas :
	set rinstrum1 [ spc_passebas $filenamespc ]
	set rinstrum2 [ spc_passebas $rinstrum1 ]
	set rinstrum [ spc_smooth2 $rinstrum2 ]

	#--- Effacement des fichiers intermédiaires :
	file delete -force "$audace(rep_images)/$rinstrum1$conf(extension,defaut)"
	file delete -force "$audace(rep_images)/$rinstrum2$conf(extension,defaut)"

	#--- Extraction des données :
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set yadjs [ lindex [ spc_fits2data $rinstrum ] 1 ]

	#--- Affichage du graphe
	#::plotxy::clf
	::plotxy::figure 3
	::plotxy::plot $abscisses $yadjs r 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	::plotxy::title "bleu : Résultat division - rouge : RI filtrée passe bas"
	::plotxy::hold off

	#--- Retour du résultat :
	file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
	return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajustripbas fichier_profil.fit\n\n"
    }
}
#****************************************************************#




####################################################################
# Procedure d'ajustement d'un nuage de points 
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-02-2007
# Date modification : 28-02-2007
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajustd5 { args } {
    global conf
    global audace

    if { [ llength $args ]==1 } {
	set filenamespc [ lindex $args 0 ]
	set erreur 1.
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [ lindex $contenu 0 ]
	set ordonnees [ lindex $contenu 1 ]
	set len [llength $ordonnees ]

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X 
	#set n [llength $abscisses]
	set x ""
	set X "" 
	for {set i 0} {$i<$len} {incr i} { 
	    set xi [lindex $abscisses $i] 
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi 
	    lappend ligne_i [ expr $xi*$xi ]
	    lappend ligne_i [ expr $xi*$xi*$xi ]
	    lappend ligne_i [ expr $xi*$xi*$xi*$xi ]
	    lappend ligne_i [ expr $xi*$xi*$xi*$xi*$xi ]
	    lappend X $ligne_i 
	} 
	#-- calcul de l'ajustement 
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ]
	#-- extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	set d [lindex $coeffs 3]
	set e [lindex $coeffs 4]
	set f [lindex $coeffs 5]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2+$d*x^3+$e*x^4+$f*x^5\n"

	#--- Crée le fichier fits de sortie
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	#set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	set k 1
	foreach x $abscisses {
	    set y_lin [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x+$e*pow($x,4)+$f*pow($x,5) ]
	    lappend yadj $y_lin
	    buf$audace(bufNo) setpix [list $k 1] $y_lin
	    incr k
	}

	#--- Affichage du graphe
	#--- Meth1
	::plotxy::clf
	::plotxy::plot $abscisses $yadj r 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	#::plotxy::xlabel "x"
	#::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 5"


        #--- Sauvegarde du résultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
	return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajustd5 fichier_profil.fit\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points 
#
# Auteur : Benjamin MAUCLAIRE/PL
# Date creation : 28-02-2007
# Date modification : 28-02-2007
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajustd5pl { args } {
    global conf
    global audace
    if { [ llength $args ]==1 } {
	set filenamespc [ lindex $args 0 ]
	set erreur 1.
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [ lindex $contenu 0 ]
	set ordonnees [ lindex $contenu 1 ]
	set len [llength $ordonnees ]
	set x0  [lindex $abscisses 0]
	set xend  [lindex $abscisses [expr $len -1]]
	#set xnorm [expr 2/([ lindex $abscisses 0]+[ lindex $abscisses $len])]
 	set xmed [ expr ($x0+$xend)*.5 ]
	set contract [ expr 30000./($xend-$x0) ]

	#--- Calcul des coefficients du polynôme d'ajustement
	# - calcul de la matrice X 
	#set n [llength $abscisses]
	set x ""
	set X "" 
	for {set i 0} {$i<$len} {incr i} {
	    set xi [lindex $abscisses $i]
	    set erreuri $erreur
	    set xi [expr ($xi-$xmed)*$contract]
	    set yi [lindex $ordonnees $i]
	    if {$yi==0.} {set erreuri 0}
	    set ligne_i 1
	    lappend erreurs $erreuri
	    lappend ligne_i $xi 
	    lappend ligne_i [ expr $xi*$xi ]
	    lappend ligne_i [ expr $xi*$xi*$xi ]
	    lappend ligne_i [ expr $xi*$xi*$xi*$xi ]
	    lappend ligne_i [ expr $xi*$xi*$xi*$xi*$xi ]
	    lappend X $ligne_i 
	} 
	#-- calcul de l'ajustement 
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ]
	#-- extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	set d [lindex $coeffs 3]
	set e [lindex $coeffs 4]
	set f [lindex $coeffs 5]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2+$d*x^3+$e*x^4+$f*x^5\n"

	#--- Crée le fichier fits de sortie
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	#set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	set k 1
	foreach x $abscisses {
	    set y_lin [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x+$e*pow($x,4)+$f*pow($x,5) ]
	    lappend yadj $y_lin
	    buf$audace(bufNo) setpix [list $k 1] $y_lin
	    incr k
	}

	#--- Affichage du graphe
	#--- Meth1
	::plotxy::clf
	::plotxy::plot $abscisses $yadj r 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	#::plotxy::xlabel "x"
	#::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 5"


        #--- Sauvegarde du résultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
	return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajustd5pl fichier_profil.fit\n\n"
    }
}
#****************************************************************#


####################################################################
# Procedure d'ajustement d'un nuage de points
#
# Auteur : Patrick LAILLY
# Date creation : 07-03-2007
# Date modification : 11-03-2007
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajust_piecewiselinear { args } {
    global conf
    global audace
    #- nechant est le nombre d'intervalles contenus dans un macro intervalle

    if { [ llength $args ]==1 || [ llength $args ]==2 } {
	if { [ llength $args ]==1 } {
	    set filenamespc [ lindex $args 0 ]
	    set nechant 80
	} elseif { [ llength $args ]==2 } {
	    set filenamespc [ lindex $args 0 ]
	    set nechant [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_ajust_piecewiselinear fichier_profil.fit ?largeur?\n\n"
	    return 0
	}

	#-- Initialisation des paramètres :
	set erreur 1.
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [ lindex $contenu 0 ]
	set ordonnees [ lindex $contenu 1 ]
	set len [llength $ordonnees ]

	#-- Paramètre d'ajustement :
	set ninter [expr int($len/$nechant)+1]
	set nbase [expr $ninter+1]

	#extension du nombre de points de mesure
	set n [expr $nechant*$ninter+1]
	set abscissesorig $abscisses
	set ordonneesorig $ordonnees
	#if {$len<$n}
	for {set i $len} {$i<$n} {incr i} {
	    lappend abscisses 0.
	    lappend ordonnees 0.
	}

	#definition des poids
	set poids [ list ]
	for {set i 0} {$i<$n} {incr i} {
	    set poidsi 1.
	    if {[lindex $ordonnees $i]==0.} {set poidsi 0.}
	    lappend poids $poidsi
	}

	#-- calcul du vecteur v definissant la fonction generatrice
	set v [ list ]
	set nechant1 [ expr $nechant-1 ]
	for {set i 0} {$i<$nechant1} {incr i} {
	    lappend v [ expr 1.*$i/$nechant ]
	}

	set nechant2 [ expr 2*$nechant+1 ]
	for {set i $nechant} {$i<$nechant2} {incr i} {
	    lappend v [ expr 1.-1.*($i-$nechant)/$nechant ]
	}
	#::console::affiche_resultat "v=$v\n"


	#-- calcul de la matrice B
	set B ""
	#-- Meth 1 : marche mais lente
	if { 1==0 } {
	set nechant3 [ expr $nechant+1 ]
	for {set i 0} {$i<$n} {incr i} {
	    set lignei ""
	    for {set j 0} {$j<$nechant3} {incr j} {
		set elemj 0.
		if { [ expr abs($i-$j*$nechant) ]<=$nechant } {
		    set elemj [ lindex $v [ expr $i-($j+1)*$nechant ] ] 
		}
		lappend lignei $elemj
	    }
	    lappend B $lignei
	}
	}
	#-- Meth2 :
	if { 1==0 } {
	set nechant3 [ expr $nechant+1 ]
	set lignei [ list ]
	set lignezeros [ list ]
	for {set i 0} {$i<$nechant3} {incr i} {
	    lappend lignezeros 0.
	}
	for {set i 0} {$i<$n} {incr i} {
	    set lignei $lignezeros
	    #- jmin=max de 2 nombres :
	    set jmin [ expr [ lindex [ lsort -integer -decreasing [ list 0 [ expr $i-$nechant1 ] ] ] 0 ]+0 ]
	    #- jmax=min de 2 nombres-1 :
	    set jmax [ expr [ lindex [ lsort -integer -increasing [ list $nechant3 [ expr $i-$nechant+2 ] ] ] 0 ] -1 ]
	    for {set j $jmin} {$j<=$jmax} {incr j} {
		::console::affiche_resultat "v$j=[ lindex $v [ expr $i-$j*$nechant+$nechant ] ]\n"
		set lignei [ lreplace $lignei $j $j [ lindex $v [ expr $i-($j+1)*$nechant ] ] ]
	    }
	    lappend B $lignei
	}
	}

	#-- Meth3 :
	set nechant3 [ expr $nechant+1 ]
	#set lignei [ list ]
	#creation d'un ligne de zeros de largeur nechant + 1
	set lignezeros [ list ]
	for {set j 0} {$j<$nechant3} {incr j} {
		lappend lignezeros 0.
	}

	for {set i 0} {$i<$n} {incr i} {
	    set lignei $lignezeros
	    #- jmin=max de 2 nombres :
	    # set jmin [ expr [ lindex [ lsort -integer -decreasing [ list 0 [ expr $i/$nechant + 1 ] ] ] 0 ]+0 ]
	    set jmin [ expr [ lindex [ lsort -integer -decreasing [ list 0 [ expr $i/$nechant-1 ] ] ] 0 ]+0 ]
	    #- jmax=min de 2 nombres-1 :
	    set jmax [ expr [ lindex [ lsort -integer -increasing [ list $nechant3 [ expr ($i+1)/$nechant+1 ] ] ] 0 ] +0 ]
	    for {set j $jmin} {$j<=$jmax} {incr j} {
		#::console::affiche_resultat "v$j=[ lindex $v [ expr $i-($j-1)*$nechant ] ]\n"
		set lignei [ lreplace $lignei $j $j [ lindex $v [ expr $i-($j-1)*$nechant ] ] ]
	    }
	    lappend B $lignei
	}

	

	
	#-- calcul de l'ajustement
	set result [ gsl_mfitmultilin $ordonnees $B $poids ]
	#-- extrait le resultat
	set coeffs [ lindex $result 0 ]
	set chi2 [ lindex $result 1 ]
	set covar [ lindex $result 2 ]

	set riliss [ gsl_mmult $B $coeffs ]
	::console::affiche_resultat "longueur B : [llength $B]\n"
	::console::affiche_resultat "longueur riliss : [llength $riliss]\n"
	::console::affiche_resultat "longueur Coefficients : [llength $coeffs]\n"
	#::console::affiche_resultat "Coefficients : $coeffs\n"

	#--- On rameène riliss et poids aux dumensions de départ de l'image FITS :
	set riliss [ lrange $riliss 0 [ expr $len-1] ]
	set poids [ lrange $poids 0 [ expr $len-1] ]
	::console::affiche_resultat "longueur riliss : [llength $riliss] - longueur poids=[ llength $poids ]\n"


	#--- Mise à zéro des valeurs négatives de riliss et celle correspondant aux intensités initialies nulles (poids(i)==0) :
	set i 0
	foreach valriliss $riliss valpoids $poids {
	    if { $valriliss<0. || $valpoids==0. } {
		set riliss [ lreplace $riliss $i $i 0. ]
	    }
	    incr i
	}


	#--- Crée le fichier fits de sortie
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	#set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	#set k 1
	#foreach x $abscisses {
	#    set y_lin [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x+$e*pow($x,4)+$f*pow($x,5) ]
	#    lappend yadj $y_lin
	#    buf$audace(bufNo) setpix [list $k 1] $y_lin
	 #   incr k
	#}

	#--- Affichage du graphe
	#--- Meth1
	::plotxy::clf
	::plotxy::plot $abscissesorig $riliss r 1
        ::plotxy::hold on
	::plotxy::plot $abscissesorig $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	##::plotxy::xlabel "x"
	##::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 5 de largeur $nechant"


        #--- Sauvegarde du résultat :
	#buf$audace(bufNo) bitpix float
	#buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	#buf$audace(bufNo) bitpix short
	#::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
	#return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajust_piecewiselinear fichier_profil.fit ?largeur?\n\n"
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


####################################################################
# Procédure de calibration par un polynôme de degré 2 (au moins 3 raies nécessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################


if {1==0} {
proc spc_rinstrum_020905 { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set infichier_mes [ lindex $args 0 ]
       set infichier_ref [ lindex $args 1 ]
       set fichier_mes [ file rootname $infichier_mes ]
       set fichier_ref [ file rootname $infichier_ref ]

       # Récupère les caractéristiques des 2 spectres
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

       # Sélection de la bande de longueur d'onde du spectre de référence
       ## Le spectre de référence est supposé avoir une plus large bande de lambda
       set ${fichier_ref}_sel [ spc_select $fichier_ref $xdeb1 $xfin1 ]
       # Rééchantillonnage du spectre de référence : c'est un choix.
       ## Que disp1 < disp2 ou disp2 < disp1, la dispersion finale sera disp1
       set ${fichier_ref}_sel_rech [ spc_echant ${fichier_ref}_sel $disp1 ]
       file delete ${fichier_ref}_sel$conf(extension,defaut)
       # Calcul la réponse intrumentale : RP=spectre_mesure/spectre_ref
       buf$audace(bufNo) load $fichier_mes
       buf$audace(bufNo) div ${fichier_ref}_sel_rech 1.0
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save reponse_intrumentale
       ::console::affiche_resultat "Sélection sauvée sous ${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum fichier .fit du profil de raie, profil de raie de référence\n\n"
   }
}
#****************************************************************#


##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division 
##########################################################

proc spc_rinstrum_060826 { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
	   #-- Détermine le spectre de dispersion la plus précise
	   set carac1 [ spc_info $fichier_mes ]
	   set carac2 [ spc_info $fichier_ref ]
	   set disp1 [ lindex $carac1 5 ]
	   set ldeb1 [ lindex $carac1 3 ]
	   set lfin1 [ lindex $carac1 4 ]
	   set disp2 [ lindex $carac2 5 ]
	   set ldeb2 [ lindex $carac2 3 ]
	   set lfin2 [ lindex $carac2 4 ]
	   if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Rééchantillonnage et crop du spectre de référence fichier_ref
	       ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
	       #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
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
	       #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
	       ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_sortie $fref_ech
	       set fmes_sortie $fmes_sel
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sortie $fref_sel
	       set fmes_sortie $fichier_mes
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_sortie $fichier_ref
	       set fmes_sortie $fmes_sel
	   } else {
	       #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
	       ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
	   }
       } else {
	   #-- Aucun rééchantillonnage ni redécoupage nécessaire
	   ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
	   set fref_sortie $fichier_ref
	   set fmes_sortie $fichier_mes
       }

       #--- Linéarisation des deux profils de raies
       ::console::affiche_resultat "Linéarisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth $fref_sortie ]
       set fmes_ready [ spc_bigsmooth $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
	   file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       #set fref_ready "$fref_sortie"
       #set fmes_ready "$fmes_sortie"

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrum == 0 } {
	   ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${fichier_mes}_rinstrum$conf(extension,defaut)"
	   ::console::affiche_resultat "Réponse instrumentale sauvée sous ${fichier_mes}_rinstrum$conf(extension,defaut)\n"
	   return ${fichier_mes}_rinstrum
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#



proc spc_rinstrum_260806 { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
	   #-- Détermine le spectre de dispersion la plus précise
	   set carac1 [ spc_info $fichier_mes ]
	   set carac2 [ spc_info $fichier_ref ]
	   set disp1 [ lindex $carac1 5 ]
	   set ldeb1 [ lindex $carac1 3 ]
	   set lfin1 [ lindex $carac1 4 ]
	   set disp2 [ lindex $carac2 5 ]
	   set ldeb2 [ lindex $carac2 3 ]
	   set lfin2 [ lindex $carac2 4 ]
	   if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Rééchantillonnage et crop du spectre de référence fichier_ref
	       ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
	       #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
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
	       #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
	       ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
	       set fref_sortie $fref_ech
	       set fmes_sortie $fmes_sel
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
	       set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
	       set fref_sortie $fref_sel
	       set fmes_sortie $fichier_mes
	   } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
	       #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
	       ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
	       set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
	       set fref_sortie $fichier_ref
	       set fmes_sortie $fmes_sel
	   } else {
	       #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
	       ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
	   }
       } else {
	   #-- Aucun rééchantillonnage ni redécoupage nécessaire
	   ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
	   set fref_sortie $fichier_ref
	   set fmes_sortie $fichier_mes
       }

       #--- Linéarisation des deux profils de raies
       ::console::affiche_resultat "Linéarisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth2 $fref_sortie ]
       set fmes_ready [ spc_bigsmooth2 $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
	   file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       #set fref_ready "$fref_sortie"
       #set fmes_ready "$fmes_sortie"

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrum == 0 } {
	   ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale$conf(extension,defaut)"
	   ::console::affiche_resultat "Réponse instrumentale sauvée sous reponse_instrumentale$conf(extension,defaut)\n"
	   return reponse_instrumentale
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#
}