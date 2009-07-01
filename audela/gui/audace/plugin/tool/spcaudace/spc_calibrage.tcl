
# source $audace(rep_scripts)/spcaudace/spc_calibrage.tcl
# spc_fits2dat lmachholz_centre.fit
# buf1 load lmachholz_centre.fit

# Mise a jour $Id: spc_calibrage.tcl,v 1.9 2009-07-01 16:17:28 bmauclaire Exp $



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
  global caption

  if {[llength $args] == 5} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set pixel2 [ lindex $args 3 ]
    set lambda2 [ lindex $args 4 ]

      #--- Tri des raies par ordre coissant des abscisses :
      set coords [ list $pixel1 $lambda1 $pixel2 $lambda2 ]
      set couples [ list  ]
      set len 4
      for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ] } {
          lappend couples [ list [ lindex $coords $i ] [ lindex $coords [ expr $i+1 ] ] ]
      }
      set couples [ lsort -index 0 -increasing -real $couples ]

      #--- R�affecte les couples pixels,lambda :
      set i 1
      foreach element $couples {
          set pixel$i [ lindex $element 0 ]
          set lambda$i [ lindex $element 1 ]
          incr i
      }


    #--- R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    #set spectre [ openspcncal "$filespc" ]
    #-- Modif faite le 26/12/2005
    #set spectre [ spc_fits2data "$filespc" ]
    #set intensites [lindex $spectre 0]
    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]

    #--- Calcul des parametres spectraux
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion angstroms/pixel\n"
### modif michel
###    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
###    set xcentre [expr int($lambda0+0.5*($dispersion*$naxis1)-1)]
    set pixelRef  1.0
    set lambdaRef [expr 1.0*($lambda1-$dispersion*($pixel1-$pixelRef))]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
### modif michel
###    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" $pixelRef float "" ""]
    #-- Longueur d'onde de d�part
### modif michel
###    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 float "" "angstrom"]
    buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdaRef double "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    buf$audace(bufNo) bitpix short
    ::console::affiche_resultat "\nLoi de calibration : $lambdaRef+$dispersion*x\n"
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
  global caption

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
    ::console::affiche_resultat "La dispersion vaut : $dispersion angstroms/pixel\n"
    #-- Longueur d'onde de d�part :
    set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1)]
    # set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1/$binning)] # FAUX

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
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
  global caption

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
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
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
  global caption

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
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
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
# Date modification : 20-09-2006/04-01-07/07-04-2008
# Arguments : profil_de_reference_fits profil_a_etalonner_fits
####################################################################

proc spc_calibreloifile { args } {

  global conf
  global audace
  global profilspc
  global caption

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
      if { [ lsearch $listemotsclef "SPC_RESP" ] !=-1 } {
         set spc_res [ lindex [ buf$audace(bufNo) getkwd "SPC_RESP" ] 1 ]
      } else {
         set spc_res 0.
      }
      if { [ lsearch $listemotsclef "SPC_RESL" ] !=-1 } {
         set spc_resl [ lindex [ buf$audace(bufNo) getkwd "SPC_RESL" ] 1 ]
      } else {
         set spc_resl 0.
      }

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      #--- Initialisation des mots clefs du fichier fits de sortie
      # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
      #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
      buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
      #-- Longueur d'onde de d�part
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
      }
      #-- Dispersion
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "" "angstrom/pixel" ]
         buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" "" ]
      }
      #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X)
     buf$audace(bufNo) setkwd [ list "CTYPE1" "Wavelength" string "" "" ]
     buf$audace(bufNo) setkwd [ list "SPC_RESP" $spc_res double "Power of resolution at wavelength SPC_RESL" "" ]
     buf$audace(bufNo) setkwd [ list "SPC_RESL" $spc_resl double "Wavelength where power of resolution was computed" "angstrom" ]

      #--- Mots clefs de la calibration non-lin�aire :
      #-- A+B.x+C.x.x+D.x.x.x
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
          #-- Ancienne formulation < 04012007 :
          # buf$audace(bufNo) setkwd [list "SPC_DESC" "A.x.x+B.x+C" string "" ""]
          #-- Nouvelle formulation :
          buf$audace(bufNo) setkwd [ list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" "" ]
          buf$audace(bufNo) setkwd [ list "SPC_A" $spc_a double "" "angstrom" ]
          if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
              buf$audace(bufNo) setkwd [ list "SPC_B" $spc_b double "" "angstrom/pixel" ]
          }
          if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
              buf$audace(bufNo) setkwd [ list "SPC_C" $spc_c double "" "angstrom*angstrom/pixel*pilxe" ]
          }
          buf$audace(bufNo) setkwd [ list "SPC_D" $spc_d double "" "angstrom*angstrom*angstrom/pixel*pilxe*pixel" ]
          if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
              buf$audace(bufNo) setkwd [ list "SPC_RMS" $spc_rms double "" "angstrom" ]
          }

      }

      #--- Sauvegarde du profil calibr�
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
      ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filespc}\n"
      return l${filespc}
  } else {
      ::console::affiche_erreur "Usage: spc_calibreloifile profil_de_reference_fits profil_a_etalonner_fits\n\n"
  }
}
#****************************************************************#



####################################################################
# Procedure de d�calage de la longureur d'onde de d�part
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
  global caption

  if {[llength $args] == 2} {
      set filespc [file rootname [ lindex $args 0 ] ]
      set decalage [ lindex $args 1 ]

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
          if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
              set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
              set lambda_modifie [ expr $lambda0+$decalage ]
              buf$audace(bufNo) setkwd [list "CRVAL1" $lambda_modifie double "" "angstrom"]
          }
          set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
          set spc_a_modifie [ expr $spc_a+$decalage ]
          buf$audace(bufNo) setkwd [list "SPC_A" $spc_a_modifie double "" "angstrom"]
      } elseif { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
              set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
              set lambda_modifie [ expr $lambda0+$decalage ]
              buf$audace(bufNo) setkwd [list "CRVAL1" $lambda_modifie double "" "angstrom"]
      }

      #--- Sauvegarde du profil calibr�
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filespc}_dec"
      ::console::affiche_resultat "spc_calibredecal Spectre d�cal� $decalage CRVAL1=$lambda_modifie, sauv� sous ${filespc}_dec\n"
      return "${filespc}_dec"
  } else {
      ::console::affiche_erreur "Usage: spc_calibredecal profil_a_decaler_fits decalage\n\n"
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
  global caption

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
    ::console::affiche_resultat "La dispersion lin�aire vaut : $dispersion angstroms/Pixel.\n"
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

     #--- Calcul la disersion moyenne en faisant la moyenne des ecarts entre les lambdas : GOOD !
    set dispersionm 0
    for {set k 0} {$k<[expr $len-1]} {incr k} {
        set l1 [lindex $lambdas $k]
        set l2 [lindex $lambdas [expr $k+1]]
        set dispersionm [expr 0.5*($dispersionm+0.5*($l2-$l1))]
    }
    ::console::affiche_resultat "La dispersion non lin�aire vaut : $dispersionm angstroms/Pixel.\n"

    set lambda0 [expr $a+$b+$c]
    set lcentre [expr int($lambda0+0.5*($dispersionm*$naxis1)-1)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    #-- Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
    #-- Dispersion
    #buf$audace(bufNo) setkwd [list "CDELT1" "$dispersionm" float "" "Angtrom/pixel"]
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "" "Angtrom/pixel"]
    #-- Longueur d'onde centrale
    #buf$audace(bufNo) setkwd [list "CRPIX1" "$lcentre" int "" "angstrom"]
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
    set erreur 0.01

    set len [expr [ llength $args ]-1 ]
    if { [ expr $len+1 ] >= 2 } {
        set filename [ lindex $args 0 ]
        set coords [ lrange $args 1 $len ]
        #::console::affiche_resultat "$len Coords : $coords\n"

        #--- Tri des raies par ordre coissant des abscisses :
        for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ]} {
            lappend couples [ list [ lindex $coords $i ] [ lindex $coords [ expr $i+1 ] ] ]
        }
        set couples [ lsort -index 0 -increasing -real $couples ]
        set lencouples [ llength $couples ]

#::console::affiche_resultat "Couples : $couples\n"

        #--- Pr�paration des listes de donn�es :
        for {set i 0} {$i<$lencouples} {incr i} {
            lappend xvals [ lindex [ lindex $couples $i ] 0 ]
            lappend lambdas [ lindex [ lindex $couples $i ] 1 ]
            lappend errors $erreur
        }
        set nbraies [ llength $lambdas ]

        #--- Calcul des co�fficients du polynome de calibration :
        if { $nbraies == 2 } {
           set fileout [ spc_calibre2 $filename $coords ]
           return "$fileout"
        } elseif { $nbraies == 3 } {
           #-- Calcul du polyn�me de calibration a+bx+cx^2 :
           set sortie [ spc_ajustdeg2 $xvals $lambdas $errors ]
           set coeffs [ lindex $sortie 0 ]
           set chi2 [ lindex $sortie 1 ]
           set d 0.0
           set c [ lindex $coeffs 2 ]
           set b [ lindex $coeffs 1 ]
           set a [ lindex $coeffs 0 ]
        } elseif { $nbraies > 3 } {
           #-- Calcul du polyn�me de calibration a+b*x+c*x^2+d*x^3 :
           set sortie [ spc_ajustdeg3 $xvals $lambdas $errors ]
           set coeffs [ lindex $sortie 0 ]
           set chi2 [ lindex $sortie 1 ]
           set d [ lindex $coeffs 3 ]
           set c [ lindex $coeffs 2 ]
           set b [ lindex $coeffs 1 ]
           set a [ lindex $coeffs 0 ]
        } else {
           ::console::affiche_erreur "Il faut au moins deux raies pour calibrer.\n"
        }

        #-- Caclul crval1 :
        set lambda0deg2 [ expr $a+$b+$c ]
        set lambda0deg3 [ expr $a+$b+$c+$d ]
        #-- Calcul du RMS :
        set rms [ expr $lambda0deg3*sqrt($chi2/$nbraies) ]
        ::console::affiche_resultat "spc_calibren RMS=$rms angstrom\n"
        #--- Comment� par M. Pujol :
        #-- Calcul d'une s�rie de longueurs d'ondes passant par le polynome pour la lin�arisation :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
            lappend xpos $x
            lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x ]
        }

        #--- Calcul des co�fficients de lin�arisation de la calibration a1x+b1 (r�gression lin�aire sur les abscisses choisies et leur lambda issues du polynome) :
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
        if { $nbraies <=3 } {
            set lambda0 $lambda0deg2
        } else {
            set lambda0 $lambda0deg3
        }

        #--- Mise � jour des mots clefs :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
        #-- Longueur d'onde de d�part :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
        #-- Dispersion moyenne :
	#- Si le mot cl� n'existe pas :
	if { [ lsearch $listemotsclef "CDELT1" ] ==-1 } {
	    buf$audace(bufNo) setkwd [list "CDELT1" $a1 double "" "angstrom/pixel"]
	    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
	} elseif { [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 3 ] != "\[angstrom/pixel\]" } {
	    #- Si l'unit� du mot cl� montre qu'il n'a pas de valeur li�e a une calibration en longueur d'onde :
	    buf$audace(bufNo) setkwd [list "CDELT1" $a1 double "" "angstrom/pixel"]
	    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
	}
        #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X) :
        buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
        #-- Mots clefs du polyn�me :
        buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]

        #--- Fin du script :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "\nLoi de calibration : $a+$b*x+$c*x^2+$d*x^3\n"
        ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filename}\n"
        return l${filename}
    } else {
        ::console::affiche_erreur "Usage: spc_calibren nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
    }
}
#***************************************************************************#



####################################################################
# Proc�dure de calibration par un polyn�me de degr� 2 ou 3 selon le nombre de raies
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

        #--- Pr�paration des listes de donn�es :
        for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ]} {
            lappend xvals [ lindex $coords $i ]
            lappend lambdas [ lindex $coords [ expr $i+1 ] ]
            lappend errors $erreur
        }
        set nbraies [ llength $lambdas ]

        #--- Calcul des co�fficients du polynome de calibration :
        if { $nbraies <=2 } {
            #-- Calcul du polyn�me de calibration a+bx+cx^2 :
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
            #-- Calcul d'une s�rie de longueurs d'ondes passant par le polynome pour la lin�arisation :
            buf$audace(bufNo) load "$audace(rep_images)/$filename"
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
            for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
                lappend xpos $x
                lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
            }
        } else {
            #-- Calcul du polyn�me de calibration a+bx+cx^2+dx^3 :
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
            #-- Calcul d'une s�rie de longueurs d'ondes passant par le polynome pour la lin�arisation :
            buf$audace(bufNo) load "$audace(rep_images)/$filename"
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
            for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
                lappend xpos $x
                lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x ]
            }
        }

        #--- Calcul des co�fficients de lin�arisation de la calibration a1x+b1 (r�gression lin�aire sur les abscisses choisies et leur lambda issues du polynome) :
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

        #--- Mise � jour des mots clefs :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
        #-- Longueur d'onde de d�part :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
        #-- Dispersion moyenne :
        buf$audace(bufNo) setkwd [list "CDELT1" $a1 double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
        #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X) :
        buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
        #-- Mots clefs du polyn�me :
        buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]

        #--- Fin du script :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
        ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filename}\n"
        return l${filename}
    } else {
        ::console::affiche_erreur "Usage: spc_calibren_deg3 nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
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
# Date modification : 25-04-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_linearcal { args } {
   global conf
   global audace

   if { [llength $args] == 1 } {
      set filename [ file rootname [ lindex $args 0 ] ]

      #--- Initialise les vecteurs et mots clefs � sauvegarder :
      set listevals [ spc_fits2data $filename ]
      set xvals [ lindex $listevals 0 ]
      set yvals [ lindex $listevals 1 ]
      set len [ llength $xvals ]


        #--- Initialise un vecteur des indices des pixels :
        for {set i 1} {$i<=$len} {incr i} {
            lappend indices $i
        }
        set valeurs [ list $indices $xvals ]

        #--- REcupere les co�fficients du polyn�me de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
           set spc_a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
           set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
           set spc_c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
           if { [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ] != "" } {
              set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
           } else {
              set spc_d 0.0
           }
           set flag_spccal 1
           #-- Calcul l'incertitude sur une lecture de longueur d'onde :
           set mes_incertitude [ expr 1.0/($spc_a*$spc_b) ]
        } else {
            set flag_spccal 0
        }


        #--- Calcul les longueurs �spac�es d'un pas constant :
        if { $flag_spccal } {
            #-- Calcul le pas del calibration lin�aire :
            set lambda_deb [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
            set lambda_fin [ expr $spc_a+$spc_b*$len+$spc_c*$len*$len+$spc_d*$len*$len*$len ]
            #- Benji le 20080317 :
            #set lambda_deb $spc_a
            #set lambda_fin [ expr $spc_a+$spc_b*$len+$spc_c*$len*$len ]
            #- modif michel
            # set pas [ expr ($lambda_fin-$lambda_deb)/$len ]
            set pas [ expr ($lambda_fin-$lambda_deb)/($len +1 ) ]

            #-- Calcul les longueurs d'onde (lin�aires) associ�es a chaque pixel :
            # set xlin [ list ]
            # set errors [ list ]
            set lambdas [ list ]
            for {set i 0} {$i<$len} {incr i} {
               lappend lambdas [ expr $pas*$i+$lambda_deb ]
               #lappend errors $mes_incertitude
               #lappend xlin $i
            }
            #-- R��chantillonne par spline les intensit�s sur la nouvelle �chelle en longueur d'onde :
	    #-- Verifier les valeurs des lambdas pour eviter un "monoticaly error de BLT".
            set new_intensities [ lindex  [ spc_spline $xvals $yvals $lambdas n ] 1 ]
            if { 1 == 0 } {
               #-- 20080317 : Calcule les coefficients de la droite moyenne lambda=f(xlin) :
               set sortie [ spc_ajustdeg1 $xlin $lambdas $errors ]
               #- lambda0 : lambda pour x=0
               set lambda0 [lindex [ lindex $sortie 0 ] 0]
               set cdelt1 [lindex [ lindex $sortie 0 ] 1]
               #- crval1 : lambda pour x=1
               set crval11 [expr $lambda0 + $cdelt1]
               set crval1 [ expr $lambda0-$pas ]
               ::console::affiche_resultat "pas=$pas ; cdelt1=$cdelt1 ; crval11=$crval11 ; crval1=$crval1 ; lambda0=$lambda0\n"
            }
            set crval1 [ expr $lambda_deb-$pas ]


            #-- Enregistrement au format fits :
            buf$audace(bufNo) load "$audace(rep_images)/$filename"
            for {set k 0} {$k<$len} {incr k} {
                set intensite [ lindex $new_intensities $k ]
                buf$audace(bufNo) setpix [ list [ expr $k+1 ] 1 ] $intensite
            }
            buf$audace(bufNo) setkwd [ list "CRVAL1" $crval1 double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "CDELT1" $pas double "" "angstrom/pixel" ]
            buf$audace(bufNo) delkwd "SPC_A"
            buf$audace(bufNo) delkwd "SPC_B"
            buf$audace(bufNo) delkwd "SPC_C"
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                buf$audace(bufNo) delkwd "SPC_D"
            }
            #if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
            #    buf$audace(bufNo) delkwd "SPC_RMS"
            #}
            if { [ lsearch $listemotsclef "SPC_DESC" ] !=-1 } {
                buf$audace(bufNo) delkwd "SPC_DESC"
            }
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}_linear"
            buf$audace(bufNo) bitpix short
#::console::affiche_erreur "\nLINEARCAL\n"
            ::console::affiche_resultat "\nLe profil r��chantillonn� lin�airement (pas=$pas A/pixel)\nest sauv� sous ${filename}_linear\n"
            return "${filename}_linear"
        } else {
            ::console::affiche_resultat "Profil d�j� lin�aris� mais sauv� sous ${filename}_linear\n"
	    #-- Bug : fichier original parfois efface dans les pipeline et spc_calibretelluric :
	    file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_linear$conf(extension,defaut)"
            return "${filename}_linear"
        }
    } else {
        ::console::affiche_erreur "Usage: spc_linearcal nom_profil_raies\n"
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
        buf$audace(bufNo) delkwd "NAXIS2"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${spetalon}_spc"
        buf$audace(bufNo) bitpix short

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


##########################################################
# Affiche l'image du profil du n�on de la biblioth�que
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 09-10-2007
# Date de mise � jour : 09-10-2007
# Arguments : aucun
##########################################################

proc spc_loadneon { args } {

   global spcaudace
   global conf

   #--- Affichage de l'image du neon de la biblioth�que de calibration :
   loadima $spcaudace(rep_spccal)/Neon.jpg
   visu1 zoom 1
   #::confVisu::setZoom 1 1
   ::confVisu::autovisu 1
   visu1 disp {251 -15}
}



##########################################################
# Effectue la calibration en longueur d'onde d'un spectre avec n raies et interface graphique
# Attention : GUI pr�sente !
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 17-09-2006
# Date de mise � jour : 20-09-2006
# Arguments : profil_lampe_calibration
##########################################################

proc spc_calibre { args } {

   global audace
   global conf caption
   #- spcalibre : nom de la variable retournee par la gui param_spc_audace_calibreprofil qui contient le nom du fichier de la lampe calibree
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

       spc_gdeleteall
       spc_loadfit $profiletalon
       #--- D�tection des raies dans le profil de raies de la lampe :
       set raies [ spc_findbiglines $profiletalon e ]
       #foreach raie $raies {
        #   lappend listeabscisses [ lindex $raie 0 ]
       #}
       set listeabscisses_i $raies

       #--- Elaboration des listes de longueurs d'onde :
       set listelambdaschem [ spc_readchemfiles ]
       #::console::affiche_resultat "Chim : $listelambdaschem\n"
       set listeargs [ list $profiletalon $listeabscisses_i $listelambdaschem ]

       #--- Affiche l'image du neon de biblioth�que :
       spc_loadneon

       #--- Bo�te de dialogue pour saisir les param�tres de calibration :
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
          #-- Teste si la calibration est viable : pas de dispersion negative !
          buf$audace(bufNo) load "$audace(rep_images)/$spcalibre"
          set listemotsclef [ buf$audace(bufNo) getkwds ]
          if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
             set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
          } else {
             ::console::affiche_erreur "Le spectre n'est pas calibr�\n"
             return ""
          }
          if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
             set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
          } else {
             ::console::affiche_erreur "Le spectre n'est pas calibr�\n"
             return ""
          }
          if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
             set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
          } else {
             set spc_b 0.0
          }

          if { $cdelt1>0 && $crval1>=0 && $spc_b>=0.0 } {
             loadima $spcalibre
             return $spcalibre
          } else {
             ::console::affiche_erreur "\nVous avez effectu� une mauvaise calibration.\n"
             ##-- Bo�te de dialogue pour REsaisir les param�tres de calibration :
             set fileout [ spc_calibre $profiletalon ]
          }
       } else {
          ::console::affiche_erreur "La calibration a �chou�e.\n"
          return ""
       }
   } else {
       ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer\n\n"
   }
}
#****************************************************************#


##########################################################
# CAlcul la resolution d'un spectre (pr�rablement sur un spectre de lampe de calibration)
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 07-04-2008
# Date de mise � jour : 07-04-2008
# Arguments : profil_lampe_calibration lambda_raie
##########################################################

proc spc_resolution { args } {

   global audace spcaudace
   global conf caption
   set ecart [ expr 0.5*$spcaudace(largeur_raie_detect) ]

   if { [ llength $args ] == 2 } {
      set sp_name [ lindex $args 0 ]
      set lambda_raie [ lindex $args 1 ]
      set flag_nl 0

      #--- R�cup�re les informaitons du sptectre :
      buf$audace(bufNo) load "$audace(rep_images)/$sp_name"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
         set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
         set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
         set flag_nl 1
      }
      if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
         set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
      } else {
         set spc_d 0.
      }
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      } else {
         set cdelt1 1.
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      } else {
         set crval1 1.
      }

      #--- D�termine les valeurs encadrants la raie :
      if { $flag_nl } {
         set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lambda_raie-$ecart))*$spc_c))/(2*$spc_c)) ]
         set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lambda_raie+$ecart))*$spc_c))/(2*$spc_c)) ]
      } else {
         set x1 [ expr round(($lambda_raie-$ecart-$crval1)/$cdelt1 +1) ]
         set x2 [ expr round(($lambda_raie+$ecart-$crval1)/$cdelt1 +1) ]
      }

      #--- Mesure la FWHM et le centre gaussien de la raie :
      set line_infos [ buf$audace(bufNo) fitgauss [ list $x1 1 $x2 1 ] ]
      set fwhm [ lindex $line_infos 2 ]
      set xcenter [ expr [ lindex $line_infos 1 ] -1 ]

      #--- Calcul de la resolution :
      set frac_lambda [ expr $lambda_raie-int($lambda_raie) ]
      if { $frac_lambda == 0 } {
         if { $flag_nl } {
            set lcenter [ expr $spc_a+$spc_b*$xcenter+$spc_c*$xcenter*$xcenter+$spc_d*$xcenter*$xcenter*$xcenter ]
            # set spc_res [ expr round($lcenter/($spc_b*$fwhm)) ]
            set spc_res [ expr round($lcenter/($cdelt1*$fwhm)) ]
         } else {
            set lcenter [ expr $crval1+$cdelt1*$xcenter ]
            set spc_res [ expr round($lcenter/($cdelt1*$fwhm)) ]
         }
      } else {
         set lcenter $lambda_raie
         set spc_res [ expr round($lcenter/($cdelt1*$fwhm)) ]
      }

      #--- Traitement des r�sultats :
      buf$audace(bufNo) setkwd [ list "SPC_RESP" $spc_res float "Power of resolution at wavelength SPC_RESL" "" ]
      buf$audace(bufNo) setkwd [ list "SPC_RESL" $lcenter double "Wavelength where power of resolution was computed" "angstrom" ]
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/$sp_name"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "\nLa r�solution pour la raie $lcenter vaut : $spc_res\n"
      return $spc_res
   } else {
       ::console::affiche_erreur "Usage: spc_resolution profil_de_raies longueur_d_onde_raie\n\n"
   }
}
#****************************************************************#



##########################################################
# CAlcul la resolution d'un spectre de lampe de calibration en trouvant la raie la plus proche du centre 
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 14-09-2008
# Date de mise � jour : 14-09-2008
# Arguments : profil_lampe_calibration
##########################################################

proc spc_autoresolution { args } {

   global audace spcaudace
   global conf caption

   if { [ llength $args ] == 1 } {
      set lampecalibree [ lindex $args 0 ]

      #--- Calcul la resolution du spectre � partir de la raie la plus brillante trouv�e et proche du centre du capteur :
      ::console::affiche_resultat "\nCalcul la r�solution du spectre...\n"
      # set lambda_raiemax [ lindex [ lindex [ spc_findbiglines $lampecalibree e ] 0 ] 0 ]
      set liste_raies [ spc_findbiglines $lampecalibree e ]

      #-- Recherhe de la raie la plus proche du centre, sinon prend la plus brillante :
      #- Reucpere les parametres du spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
      set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      } else {
         set cdelt1 1.
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      } else {
         set crval1 1.
      }
      set lambda_max [ expr $crval1+$naxis1*$cdelt1 ]
      set lambda_cent [ expr ($lambda_max+$crval1)/2. ]
      #- Recherche de la raie la plus proche du centre :
      set liste_comp [ list ]
      set i 0
      foreach raie $liste_raies {
         lappend liste_comp [ list [ expr abs($lambda_cent-[ lindex $raie 0 ]) ] $i ]
         incr i
      }
      ##::console::affiche_resultat "Avant tri: $liste_comp\n"
      ##::console::affiche_resultat "crval1=$crval1 ; cdelt1=$cdelt1 ; Lmax=$lambda_max ; Lc=$lambda_cent\n"
      set liste_comp [ lsort -real -increasing -index 0 $liste_comp ]
      set index_lproche [ lindex [ lindex $liste_comp 0 ] 1 ]
      #::console::affiche_resultat "Index : $index_lproche ; Apres tri: $liste_comp\n"
      #- Prend la longueur d'onde de la raie la plus proche du centre, sinon la plus brillante :
      if { $index_lproche >= 4 } {
         #- Compare les intensites des deux raies les plus proches du centre et choisis la plus brillante :
         if { [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 1 ] >  [ lindex [ lindex $liste_raies $index_lproche ] 1 ] } {
            set lambda_raiemax [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 0 ]
         } else {
            set lambda_raiemax [ lindex [ lindex $liste_raies 0 ] 0 ]
         }
      } else {
         set lambda_raiemax [ lindex [ lindex $liste_raies $index_lproche ] 0 ]
      }
      ::console::affiche_resultat "Longueur d'onde la plus proche du centre du CCD est : $lambda_raiemax\n"

      #-- Calcul de la resolution et l'ecrit dans le header :
      set resolution [ spc_resolution $lampecalibree $lambda_raiemax ]
      return "$lampecalibree"
   } else {
       ::console::affiche_erreur "Usage: spc_autoresolution profil_de_raies_lampe\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction d'�talonnage � partir de raies de l'eau autour de Ha
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

        #--- Gestion des profils calibr�s en longueur d'onde :
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
### modif michel
###            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) ]
###            set xfin [ expr round(($lfin-$crval1)/$cdelt1) ]
            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) -1 ]
            set xfin [ expr round(($lfin-$crval1)/$cdelt1) -1 ]
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
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

        #--- Recherche des raies d'�mission :
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
### modif michel
###                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1) ]
###                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1) ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 -1) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 -1) ]
                set coords [ list $x1 1 $x2 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1)*$cdelt1+$crval1 ]
            }
            lappend errors $mes_incertitude


          if { 1==0 } {
            if { $largeur == 0 } {
                # set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1*$cdelt1+$crval1 ]
            } else {
                #set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords $largeur ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1*$cdelt1+$crval1 ]
            }
          }


        }
        ::console::affiche_resultat "Liste des raies trouv�es :\n$listelmesurees\n"
        # ::console::affiche_resultat "Liste des raies trouv�es : $listemesures\n"
        ::console::affiche_resultat "Liste des raies de r�f�rence :\n$listeraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

      if { 1==1} {
        #-------------------- Non utilis� ----------------------------#
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

        #--- Calcul du polyn�me de calibration a+bx+cx^2 :
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

        #--- Calcul des co�fficients de lin�arisation de la calibration a1x+b1 (r�gression lin�aire sur les abscisses choisies et leur lambda issues du polynome) :
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
        #-- Valeur th�orique :
        set lambda0deg1 [ expr $a1+$b1 ]
### modif michel
###        #-- Correction empirique :
###        set lambda0deg1 [ expr 1.*$b1 ]


        #--- Nouvelle valeur de Lambda0 :
        #set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
        #-- Reglages :
        #- 40 -10 l0deg1 : AB
        #- 40 -40 l0deg1 : AB+
        #- 20 -10 l0deg2 : AB++

        #-- Valeur th�orique :
        # set lambda0 $lambda0deg2
        #-- Correction empirique :
        set lambda0 [ expr $lambda0deg2-2.*$cdelt1 ]
        #set lambda0 $a


###        if { 1==0 } {
###        #--- Redonne le lambda du centre des raies apres r��talonnage :
###        set ecart2 0.6
###        foreach raie $listeraies {
###            set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1) ]
###            set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1) ]
###            set coords [ list $x1 1 $x2 1 ]
###            if { $largeur == 0 } {
###                set x [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
###                #lappend listemesures $xcenter
###                # lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
###                lappend listelmesurees2 [ expr $lambda0+$cdelt1*$x ]
###            } else {
###                set x [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
###                #lappend listemesures $xcenter
###                lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
###            }
###        }
###        #::console::affiche_resultat "Liste des raies apr�s r��talonnage :\n$listelmesurees2\n� comparer avec :\n$listeraies\n"
###        }


        #--- Mise � jour des mots clefs :
        buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
        #-- Longueur d'onde de d�part :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0deg1 double "" "angstrom"]
        #-- Dispersion moyenne :
        #buf$audace(bufNo) setkwd [list "CDELT1" $a1 float "" "angstrom/pixel"]
        #buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
        #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X) :
        #buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
        #-- Mots clefs du polyn�me :
        if { $flag_spccal } {
            buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
            #buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_A" $lambda0 double "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
        } else {
            buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
            #buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_A" $lambda0deg2 double "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
            buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
            buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
        }

        #--- Sauvegarde :
        set fileout "${filename}-ocal"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$fileout"
        buf$audace(bufNo) bitpix short

        #--- Fin du script :
        ::console::affiche_resultat "Spectre �talonn� sauv� sous $fileout\n"
        return "$fileout"
     }
   } else {
       ::console::affiche_erreur "Usage: spc_autocalibrehaeau profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#




####################################################################
# Fonction de calcul du RMS d'un calibration
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-09-2007
# Date modification : 12-09-2007
# Arguments : nom_profil_raies ?largeur_raie? ?liste_raies_ayant_serivies_a_la_calibration?
####################################################################

proc spc_caloverif { args } {
    global conf
    global audace spcaudace
    #-- Marge a partir du bord ou sont prises en compte les raies :
    set marge_bord 2.5
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.5
    # GOOD : set ecart 1.0
    #set ecart 1.2
    #set erreur 0.01

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur_raie [expr 2.0*$spcaudace(dlargeur_eau) ]
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur_raie [ lindex $args 1 ]
        } elseif { $nbargs == 3 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur_raie [ lindex $args 1 ]
            set listeraieseau [ lindex $args 2 ]
        } else {
            ::console::affiche_erreur "Usage: spc_caloverif nom_profil_de_raies ?largeur_raie (A)? ?liste_raies_r�f�rence?\n"
            return 0
        }
        set ecart [ expr $largeur_raie/2. ]

        #--- Gestion des profils selon loi de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
            set lmin_spectre [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
            set lmax_spectre [ expr $spc_a+$spc_b*$naxis1+$spc_c*pow($naxis1,2)+$spc_d*pow($naxis1,3) ]
        } else {
            set flag_spccal 0
            set lmin_spectre $crval1
            set lmax_spectre [ expr $crval1+$cdelt1*$naxis1 ]
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


        #--- Charge la liste des raies de l'eau :
        if { $nbargs <= 2 } {
            set listeraieseau [ list ]
            set file_id [ open "$spcaudace(filetelluric)" r ]
            set contents [ split [ read $file_id ] \n ]
            close $file_id
            set nbraiesbib 0
            foreach ligne $contents {
                lappend listeraieseau [ lindex $ligne 1 ]
                incr nbraiesbib
            }
            set nbraiesbib [ expr $nbraiesbib-2 ]
            set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
            set lmin_bib [ lindex $listeraieseau 0 ]
            set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        } else {
            set nbraiesbib [ llength $listeraieseau ]
            set lmin_bib [ lindex $listeraieseau 0 ]
            set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        }
        # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
        # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


        #--- Cre�e la liste de travail des raies de l'eau pour le spectre :
        if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
            #-- Recherche la longueur minimum des raies raies telluriques utilisables (2.5 A) :
            set index_min 0
            foreach raieo $listeraieseau {
                if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
                    break
                } else {
                    incr index_min
                }
            }
            # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
            #-- Recherche la longueur maximum des raies raies telluriques utilisables (2.5 A) :
            set index_max $nbraiesbib
            for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
                if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
                    break
                }
            }
            # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
            #-- Liste des raies telluriques utilisables :
            #- Enleve une raie sur chaque bords : 070910
            # set index_min [ expr $index_min+1 ]
            # set index_max [ expr $index_max-1 ]
            set listeraies [ lrange $listeraieseau $index_min $index_max ]
            ::console::affiche_resultat "Liste raies de r�f�rence : $listeraies\n"
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }

        #--- Calculs les param�tres de la qualit� de la calibration par rapport aux raies de la liste :
        #set cal_infos [ spc_rms "${filename}_conti" $listeraies $largeur_raie ]
        set cal_infos [ spc_rms "$filename" $listeraies $largeur_raie ]
        set chi2 [ lindex $cal_infos 0 ]
        set rms  [ lindex $cal_infos 1 ]
        set mean_shift [ lindex $cal_infos 2 ]

        #--- Traitement des r�sultats :
        ::console::affiche_resultat "\n\nQualit� de la calibration :\nChi2=$chi2\nRMS=$rms A\nEcart moyen=$mean_shift A\n"

        return $cal_infos
   } else {
       ::console::affiche_erreur "Usage: spc_caloverif profil_de_raies_a_calibrer ?largeur_raie (A)? ?liste_raies_r�f�rence?\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction de calcul du RMS d'un calibration
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 9-09-2007
# Date modification : 9-09-2007
# Arguments : nom_profil_raies liste_raies_ayant_serivies_a_la_calibration largeur_raie
####################################################################

proc spc_rms { args } {
    global conf
    global audace spcaudace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.5
### modif michel
    set ecart spcaudace(dlargeur_eau)
    # GOOD : set ecart 1.0
    #set ecart 1.2
    #set erreur 0.01
    #-- Largeur du filtre SaveGol : 28
    set largeur $spcaudace(largeur_savgol)

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
        if { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set listeraies [ lindex $args 1 ]
            set largeur_raie [ expr 2.0*$spcaudace(dlargeur_eau) ]
        } elseif { $nbargs == 3 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set listeraies [ lindex $args 1 ]
            set largeur_raie [ lindex $args 2 ]
        } else {
            ::console::affiche_erreur "Usage: spc_rms nom_profil_de_raies liste_raies_r�f�rence ?largeur_raie (A)?\n"
            return 0
        }
        set ecart [ expr $largeur_raie/2. ]

        #--- Extrait les mots clef utiles :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
        } else {
        #- Cas lin�aire :
            set flag_spccal 0
        }


        #--- Filtrage pour isoler le continuum :
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #- buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
        set ffiltered [ spc_smoothsg "$filename" $largeur ]
        set fcont1 [ spc_div "$filename" "$ffiltered" ]
        #-- Inversion et mise a 0 du niveau moyen :
        buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
        set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
        buf$audace(bufNo) mult -1.0
        buf$audace(bufNo) offset $icontinuum
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
        buf$audace(bufNo) bitpix short


        #--- D�termine la longueur d'onde centrale des raies ayant servies � la calibration :
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
        ### modif michel
        ### set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]

        set listelmesurees [ list ]
        #- Diff�rence moyenne :
        set sum_diff 0.
        #- Diff�rence moyenne au carr� :
        set sum_diffsq 0.
        #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
        #buf$audace(bufNo) load "$audace(rep_images)/$filename"
        foreach lambda_cat $listeraies {
            if { $flag_spccal } {
                set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lambda_cat-$ecart))*$spc_c))/(2*$spc_c)) ]
                set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lambda_cat+$ecart))*$spc_c))/(2*$spc_c)) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravit�
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravit�
                #set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #buf$audace(bufNo) mult -1.0
                #set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #buf$audace(bufNo) mult -1.0
                #set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                #::console::affiche_resultat "$xc1, $xc2, $xcenter\n"
                set lambda_mes [ expr $spc_a+$xcenter*$spc_b+$xcenter*$xcenter*$spc_c+pow($xcenter,3)*$spc_d ]
                set ldiff    [ expr $lambda_mes-$lambda_cat ]
                set sum_diff [ expr $sum_diff+$ldiff ]
                set sum_diffsq [ expr $sum_diffsq+pow($ldiff,2) ]
                lappend listelmesurees $lambda_mes
                lappend liste_ecart $ldiff
            } else {
                ### modif michel
                ### set x1 [ expr round(($lambda_cat-$ecart-$crval1)/$cdelt1) ]
                set x1 [ expr round(($lambda_cat-$ecart-$crval1)/$cdelt1 +1) ]
                set x2 [ expr round(($lambda_cat+$ecart-$crval1)/$cdelt1 +1) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravit�
                #set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravit�
                #set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #buf$audace(bufNo) mult -1.0
                #set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #buf$audace(bufNo) mult -1.0
                #set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                #::console::affiche_resultat "$xc1, $xc2, $xcenter\n"
                set lambda_mes [ expr ($xcenter -1) *$cdelt1+$crval1 ]
                set ldiff    [ expr $lambda_mes-$lambda_cat ]
                set sum_diff [ expr $sum_diff+$ldiff ]
                set sum_diffsq [ expr $sum_diffsq+pow($ldiff,2) ]
                lappend listelmesurees $lambda_mes
                lappend liste_ecart $ldiff
            }
            ### modif michel
            # lappend errors $mes_incertitude
        }
        #::console::affiche_resultat "Liste des raies de r�f�rence :\n$listeraies\n"
        ::console::affiche_resultat "Liste des raies trouv�es :\n$listelmesurees\n"
        ::console::affiche_resultat "Liste des �carts :\n$liste_ecart\n"

        #--- Calcul du RMS et ecart-type :
        set nbraies [ llength $listeraies ]
        set chi2 [ expr $sum_diffsq/($nbraies*pow($cdelt1,2)) ]
        #-- Multiplication de la valeur du RMS par CRDELT pour donner artificiellement une valeur qui est comparable � celle affich�e par les autres logiciels amateurs, mais reste proportionnelle au RMS. Le RMS reste un indicateur, qui permet de comparer des spectres avec spc_rms.
        #set rms [ expr sqrt($sum_diffsq/$nbraies) ]
        set rms [ expr $cdelt1*sqrt($sum_diffsq/$nbraies) ]
        set mean_shift [ expr $sum_diff/$nbraies ]
        set rmse [ expr sqrt(($sum_diffsq/$nbraies-pow($mean_shift,2))/$nbraies) ]

        #--- Traitement des r�sultats :
        #-- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
        ::console::affiche_resultat "Chi2=$chi2 ; RMS=$rms ; Ecart moyen=$mean_shift ; RMSE=$rmse\n"
        set cal_infos [ list $chi2 $rms $mean_shift ]
        return $cal_infos
   } else {
       ::console::affiche_erreur "Usage: spc_rms profil_de_raies_a_calibrer liste_raies_r�f�rence  ?largeur_raie (A)?\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction d'�talonnage � partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-09-2007
# Date modification : 12-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_calibretelluric { args } {
    global conf
    global audace spcaudace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.2
    #set ecart 1.5
    # set ecart 1.0
    set ecart $spcaudace(dlargeur_eau)
    set marge_bord 2.5
    #set erreur 0.01

    #--- Rappels des raies pour resneignements :
    #-- Liste C.Buil :
    ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    # GOOD : set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_calibretelluric profil_de_raies_a_calibrer ?largeur_raie_pixels (28)?\n"
            return ""
        }

        #--- Gestion des profils selon la loi de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
            set lmin_spectre [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
            set lmax_spectre [ expr $spc_a+$spc_b*$naxis1+$spc_c*pow($naxis1,2)+$spc_d*pow($naxis1,3) ]
        } else {
            set flag_spccal 0
            set lmin_spectre $crval1
            set lmax_spectre [ expr $crval1+$cdelt1*($naxis1 -1) ]
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :

        ### modif michel (mes_incertitude avait une valeur beaucoup trop elevee)
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


        #--- Charge la liste des raies de l'eau :
        set file_id [ open "$spcaudace(filetelluric)" r ]
        set contents [ split [ read $file_id ] \n ]
        close $file_id
        set nbraiesbib 0
        foreach ligne $contents {
            lappend listeraieseau [ lindex $ligne 1 ]
            incr nbraiesbib
        }
        set nbraiesbib [ expr $nbraiesbib-2 ]
        set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
        set lmin_bib [ lindex $listeraieseau 0 ]
        set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
        # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


        #--- Cre�e la liste de travail des raies de l'eau pour le spectre :
        if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
            #-- Recherche la longueur minimum des raies raies telluriques utilisables (2 A) :
            set index_min 0
            foreach raieo $listeraieseau {
                if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
                    break
                } else {
                    incr index_min
                }
            }
            # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
            #-- Recherche la longueur maximum des raies raies telluriques utilisables (2 A) :
            set index_max $nbraiesbib
            for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
                if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
                    break
                }
            }
            # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
            #-- Liste des raies telluriques utilisables :
            #- Enleve une raie sur chaque bords : 070910
            # set index_min [ expr $index_min+1 ]
            # set index_max [ expr $index_max-1 ]
            set listeraies [ lrange $listeraieseau $index_min $index_max ]
            # ::console::affiche_resultat "$listeraies\n"
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }


        #--- Filtrage pour isoler le continuum :
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
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

        #--- Recherche des raies telluriques en absorption :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        #set pas [ expr int($largeur/2) ]
        #buf$audace(bufNo) scale {1 3} 1
        #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
        #buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set nbraies [ llength $listeraies ]
        set listexraies [list ]
        set listexmesures [list ]
        set listelmesurees [list ]
        set listeldiff [list ]
        foreach raie $listeraies {
            if { $flag_spccal } {
                set x  [ expr (-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie))*$spc_c))/(2*$spc_c) ]
                set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)) ]
                set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravit�
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravit�
                # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                set lambda_mes [ expr ($xcenter -1)*$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies $x
                lappend listexmesures $xcenter
                lappend listelmesurees $lambda_mes
                lappend listeldiff $ldiff
            } else {
                set x  [ expr ($raie-$crval1)/$cdelt1 + 1 ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 +1 ) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 +1 ) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravit�
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravit�
                # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                set lambda_mes [ expr  ($xcenter -1) *$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies    $x
                lappend listexmesures  $xcenter
                lappend listelmesurees $lambda_mes
                lappend listeldiff     $ldiff

            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouv�es :\n$listelmesurees\n"
        ::console::affiche_resultat "Liste des x mesures :\n$listexmesures\n"
        ::console::affiche_resultat "Liste des raies du catalogue :\n$listeraies\n"
        ::console::affiche_resultat "Liste des x du catalogue :\n$listexraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

       #--- Methode 1 : spectre initial lin�aire :
       ::console::affiche_resultat "============ 1) spectre initial lin�aire ================\n"
       set spectre_linear [ spc_linearcal "$filename" ]
       set infos_cal [ spc_rms "$spectre_linear" $listeraies ]
       set rms_initial [ lindex $infos_cal 1 ]
       set mean_shift_initial [ lindex $infos_cal 2 ]
       set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set cdelt1_initial $cdelt1
       set crval1_initial $crval1
       ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"
              

       #--- Methode 2 : origine decalee du decalage moyen
       if { [ lsearch $spcaudace(calo_meths) 2 ] != -1 } {
          ::console::affiche_resultat "============ 2) D�calage du SHIFT du spectre inital lin�aris� ================\n"
          set spectre_lindec [ spc_calibredecal "$spectre_linear" [ expr -1.0*$mean_shift_initial ] ]
          set infos_cal [ spc_rms "$spectre_lindec" $listeraies ]
          set rms_lindec [ lindex $infos_cal 1 ]
          set mean_shift_lindec [ lindex $infos_cal 2 ]
          file rename -force "$audace(rep_images)/$spectre_lindec$conf(extension,defaut)" "$audace(rep_images)/${filename}_mshiftdec$conf(extension,defaut)"
          set spectre_lindec "${filename}_mshiftdec"
       }
          

       #--- Methode 5 : D�calage du spectre inital lin�aris� de la valeur du RMS : 
       if { [ lsearch $spcaudace(calo_meths) 5 ] != -1 } {
          ::console::affiche_resultat "============ 5) D�calage de RMS du spectre inital lin�aris� ================\n"
          #set rms_decalage [ expr $rms_initial/$cdelt1_initial/2. ]
          set rms_decalage [ expr $rms_initial/$cdelt1_initial ]
          if { $mean_shift_initial > 0. } {
             set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" [ expr -1.0*$rms_decalage ] ]
          } else {
             set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" $rms_decalage ]
          }
          set infos_cal [ spc_rms "$spectre_lindec_rms" $listeraies ]
          set rms_lindec_rms [ lindex $infos_cal 1 ]
          set mean_shift_lindec_rms [ lindex $infos_cal 2 ]
          file rename -force "$audace(rep_images)/$spectre_lindec_rms$conf(extension,defaut)" "$audace(rep_images)/${filename}_rmsdec$conf(extension,defaut)"
          set spectre_lindec_rms "${filename}_rmsdec"
       }


       #--- Methode 6 : D�calage du spectre inital lin�aris� de la valeur du RMS : 
       if { [ lsearch $spcaudace(calo_meths) 6 ] != -1 } {
          ::console::affiche_resultat "============ 7) D�calage de 0.5RMS du spectre inital lin�aris� ================\n"
          set rms_decalage [ expr $rms_initial/$cdelt1_initial/2. ]
          if { $mean_shift_initial > 0. } {
             set spectre_lindec_drms [ spc_calibredecal "$spectre_linear" [ expr -1.0*$rms_decalage ] ]
          } else {
             set spectre_lindec_drms [ spc_calibredecal "$spectre_linear" $rms_decalage ]
          }
          set infos_cal [ spc_rms "$spectre_lindec_drms" $listeraies ]
          set drms_dec [ lindex $infos_cal 1 ]
          set mean_shift_drms [ lindex $infos_cal 2 ]
          file rename -force "$audace(rep_images)/$spectre_lindec_drms$conf(extension,defaut)" "$audace(rep_images)/${filename}_drmsdec$conf(extension,defaut)"
          set spectre_lindec_drms "${filename}_drmsdec"
       }

          
       #--- Methode 3 : callibration avec les raies telluriques :
       if { [ lsearch $spcaudace(calo_meths) 3 ] != -1 } {
          ::console::affiche_resultat "============ 3) calibration sur l'eau ================\n"
          #-- Ajustement polynomial de degre 3 :
          set sortie [ spc_ajustdeg3 $listexmesures $listeraies $errors ]
          set coeffs [ lindex $sortie 0 ]
          set d [ lindex $coeffs 3 ]
          set c [ lindex $coeffs 2 ]
          set b [ lindex $coeffs 1 ]
          set a [ lindex $coeffs 0 ]
          set chi2 [ lindex $sortie 1 ]
          set covar [ lindex $sortie 2 ]
          set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
          #-- Sauvegarde le spectre calibr� non-lin�airement :
          buf$audace(bufNo) load "$audace(rep_images)/$filename"
          buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
          buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
          buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
          buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
          buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
          buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocalnl"
          buf$audace(bufNo) bitpix short
          #-- Recalage de la calibration grace aux raies telluriques :
          #- R��chantillonnage pour obtenir une loi de calibration lin�aire :
          set spectre_ocallin [ spc_linearcal "${filename}-ocalnl" ]
          #- Calcul de d�calage moyen+rms :
          set mean_shift [ lindex [ spc_rms "$spectre_ocallin" $listeraies ] 2 ]
          #- R�alise le d�calage sur la loi lin�aire :
          set spectre_ocalshifted [ spc_calibredecal "$spectre_ocallin" [ expr -1.*$mean_shift ] ]
          #- Calcul le d�calage moyen+rms du spectre final :
          # set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies 1.5 ]
          set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies ]
          set rms_calo [ lindex $infos_cal 1 ]
          set mean_shift_calo [ lindex $infos_cal 2 ]
          #- Effacement des fichiers temporaires :
          file rename -force "$audace(rep_images)/$spectre_ocalshifted$conf(extension,defaut)" "$audace(rep_images)/${filename}_caloshift$conf(extension,defaut)"
          set spectre_ocalshifted "${filename}_caloshift"
          if { $spectre_ocallin != "${filename}-ocalnl" } {
             file delete -force "$audace(rep_images)/${filename}-ocalnl$conf(extension,defaut)"
          }
          file delete -force "$audace(rep_images)/$spectre_ocallin$conf(extension,defaut)"
       }

          
       #--- Methode 4 : callibration 2 avec les raies telluriques
       if { [ lsearch $spcaudace(calo_meths) 4 ] != -1 } {
          ::console::affiche_resultat "============ 4) calibration sur l'eau bis ================\n"
          #-- Calcul du polyn�me de calibration xlin = a+bx+cx^2+cx^3
          ### spc_calibretelluric 94-bet-leo--profil-traite-final.fit
          set sortie [ spc_ajustdeg2 $listexmesures $listexraies $errors ]
          # set sortie [ spc_ajustdeg3 $listexmesures $listexraies $errors ]
          set coeffs [ lindex $sortie 0 ]
          # set d [ lindex $coeffs 3 ]
          set d 0.0
          set c [ lindex $coeffs 2 ]
          set b [ lindex $coeffs 1 ]
          set a [ lindex $coeffs 0 ]
          set chi2 [ lindex $sortie 1 ]
          set covar [ lindex $sortie 2 ]
          set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
          #-- je calcule les x linearises
          set listexlin [list]
          foreach x $listexmesures {
             lappend listexlin [ expr $a + $b*$x + $c*$x*$x + $d*$x*$x*$x ]
          }
          #-- je charge l'image calibree avec le neon :
          buf$audace(bufNo) load "$audace(rep_images)/$filename"
          #-- R��chantillonnage pour obtenir une loi de calibration lin�aire :
          set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
          set xorigin [list ]
          set xlinear [list ]
          set intensites [list ]
          for {set x 0 } {$x<$naxis1} {incr x} {
             lappend xorigin $x
             lappend xlinear [ expr $a + $b*$x + $c*$x*$x + $d*$x*$x*$x ]
             lappend intensities [lindex [ buf$audace(bufNo) getpix [list [expr $x +1] 1] ] 1]
          }
          set newIntensities [ lindex [ spc_spline $xlinear $intensities $xorigin n ] 1 ]
          for {set x 0 } {$x<$naxis1} {incr x} {
             buf$audace(bufNo) setpix [ list [expr $x +1] 1 ] [lindex $newIntensities $x]
          }
          #-- je calcule les coefficients de la droite moyenne lambda=f(xlin) :
          set sortie [ spc_ajustdeg1hp $listexlin $listeraies $errors ]
          #- lambda0 : lambda pour x=0
          set lambda0 [lindex [ lindex $sortie 0 ] 0]
          set cdelt1 [lindex [ lindex $sortie 0 ] 1]
          #- crval1 : lambda pour x=1
          set crval1 [expr $lambda0 + $cdelt1]
          buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 double "" "angstrom" ]
          buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1 double "" "angstrom/pixel" ]
          set listemotsclef [ buf$audace(bufNo) getkwds ]
          if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
             buf$audace(bufNo) delkwd "SPC_A"
             buf$audace(bufNo) delkwd "SPC_B"
             buf$audace(bufNo) delkwd "SPC_C"
             if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
		buf$audace(bufNo) delkwd "SPC_D"
             }
          }
          #-- j'enregistre l'image :
          set spectre_ocallinbis "${filename}_caloshift2"
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/$spectre_ocallinbis"
          buf$audace(bufNo) bitpix short
          #-- Calcul le d�calage moyen+rms du spectre final :
          set infos_cal   [ spc_rms $spectre_ocallinbis $listeraies ]
          set rms_calobis [ lindex $infos_cal 1 ]
          set mean_shift_calobis [ lindex $infos_cal 2 ]
          ::console::affiche_resultat "Loi de calibration lineaire calobis : $crval1+$cdelt1*x\n"
       }
          

       #--- Methode 7 : callibration avec les raies telluriques :
       if { [ lsearch $spcaudace(calo_meths) 7 ] != -1 } {
          ::console::affiche_resultat "====== 7) Recalage progressif par iterations ====\n"
          set nb_iteration 0
          set dl 0.01
          set rms_dec1 [ expr $rms_initial+$dl ]
          set tdl $dl
          set tdl_max [ expr 2.*abs($mean_shift_initial) ]
          if { $mean_shift_initial > 0 } { set signe "-" } else { set signe "" }
          set spectre_decini [ spc_calibredecal "$spectre_linear" "$signe$mean_shift_initial" ]
          set rms_dec2 [ lindex [ spc_rms "$spectre_decini" $listeraies ] 1 ]
          while { $tdl < $tdl_max } {
             #if { $rms_dec2 > $rms_dec1 &&  [ expr abs($rms_dec2-$rms_dec1) ] >= 0.01 } 
             if { $rms_dec2 > $rms_dec1 } {
                set spectre_dec [ spc_calibredecal "$spectre_decini" [ expr $signe$tdl-$dl ] ]
                set infos_cal [ spc_rms "$spectre_dec" $listeraies ]
                set rms_dec [ lindex $infos_cal 1 ]
                set mean_shift_dec [ lindex $infos_cal 2 ]
                file rename -force "$audace(rep_images)/$spectre_dec$conf(extension,defaut)" "$audace(rep_images)/${filename}_iterdec$conf(extension,defaut)"
                set spectre_dec "${filename}_iterdec"
                file delete -force "$audace(rep_images)/$spectre_decini$conf(extension,defaut)"
                ::console::affiche_resultat "\nNb iterations : $nb_iteration, dec=$tdl ; RMS2=$rms_dec2 ; RMS1=$rms_dec1\n"
                break
             } else {
                set rms_dec1 $rms_dec2
                set tdl [ expr $tdl+$dl ]
                incr nb_iteration
                set spectre_dec [ spc_calibredecal "$spectre_decini" "$signe$tdl" ]
                set rms_dec2 [ lindex [ spc_rms "$spectre_dec" $listeraies ] 1 ]
             }
          }
          set rms_dec [ lindex [ spc_rms "$spectre_dec" $listeraies ] 1 ]
       }



        #--- D�termine la meilleure calibration :
        ::console::affiche_resultat "============ D�termine la meilleure calibration ================\n"
        #-- Sauvera le spectre final recalibr� (lin�arirement) :
        # set liste_rms [ list [ list "calobis" $rms_calobis ] [ list "calo" $rms_calo ] [ list "lindec" $rms_lindec ] [ list "initial" $rms_initial ] ]
        #-- Gestion des m�thodes s�lectionn�es (car calo n�3 mauvaise selon la taille du capteur) :
        set liste_rms [ list ]
        if { [ lsearch $spcaudace(calo_meths) 1 ] != -1 } {
           lappend liste_rms [ list "initial" $rms_initial ]
        }
        if { [ lsearch $spcaudace(calo_meths) 2 ] != -1 } {
           lappend liste_rms [ list "lindec" $rms_lindec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 3 ] != -1 } {
           lappend liste_rms [ list "calo" $rms_calo ]
        }
        if { [ lsearch $spcaudace(calo_meths) 4 ] != -1 } {
           lappend liste_rms [ list "calobis" $rms_calobis ]
        }
        if { [ lsearch $spcaudace(calo_meths) 5 ] != -1 } {
           lappend liste_rms [ list "lindec_rms" $rms_lindec_rms ]
        }
        if { [ lsearch $spcaudace(calo_meths) 6 ] != -1 } {
           lappend liste_rms [ list "lindec_drms" $drms_dec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 7 ] != -1 } {
           lappend liste_rms [ list "iterdec" $rms_dec ]
        }

        #-- Tri par RMS croissant :
        set liste_rms [ lsort -index 1 -increasing -real $liste_rms ]
        set best_rms_name [ lindex [ lindex $liste_rms 0 ] 0 ]
        set best_rms_val [ lindex [ lindex $liste_rms 0 ] 1 ]

	#-- Compare et choisis la meilleure calibration a l'aide du RMS :
        if { $best_rms_name == "calobis" } {
            #-- Le spectre recalibr� avec l'eau (4) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocallinbis"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_calobis double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 4)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre recalibr� avec (4) les raies telluriques de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_calobis A\nEcart moyen=$mean_shift_calobis A\n\n"
        } elseif { $best_rms_name == "calo" } {
            #-- Le spectre recalibr� avec l'eau (3) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocalshifted"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_calo double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 3)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre recalibr� avec (3) les raies telluriques de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Loi de calibration tellutique trouv�e : $a+$b*x+$c*x^2\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_calo A\nEcart moyen=$mean_shift_calo A\n\n"
        } elseif { $best_rms_name == "lindec" } {
            #-- Le spectre lin�aris� juste d�cal� avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_lindec double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 2)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (2) de meilleure qualit� (dec de Meanshift).\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_lindec A\nEcart moyen=$mean_shift_lindec A\n\n"
        } elseif { $best_rms_name == "lindec_rms" } {
            #-- Le spectre lin�aris� juste d�cal� avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec_rms"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_lindec_rms double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 5)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (5) de meilleure qualit� (dec de RMS).\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_lindec_rms A\nEcart moyen=$mean_shift_lindec_rms A\n\n"
        } elseif { $best_rms_name == "lindec_drms" } {
            #-- Le spectre lin�aris� juste d�cal� avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec_drms"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $drms_dec double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 6)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (6) de meilleure qualit� (dec de 0.5RMS).\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$drms_dec A\nEcart moyen=$mean_shift_drms A\n\n"
        } elseif { $best_rms_name == "iterdec" } {
            #-- Le spectre lin�aris� juste d�cal� avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_dec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_dec double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 7)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (7) de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_dec A\nEcart moyen=$mean_shift_dec A\n\n"
        } elseif { $best_rms_name == "initial" } {
            #-- La calibration du spectre inital est meilleure :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_initial double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 1)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration (1) initiale de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_initial A\nEcart moyen=$mean_shift_initial A\n\n"
        }

        #--- Effacement des fichiers resultats des 4 methodes :
        if { $spectre_linear != $filename } {
           file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"
        }
        if { $spcaudace(flag_rmcalo) == "o" } {
           file delete -force "$audace(rep_images)/${filename}_caloshift2$conf(extension,defaut)"
           #file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_caloshift$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_mshiftdec$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_rmsdec$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_drmsdec$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_iterdec$conf(extension,defaut)"
        }
        return "${filename}-ocal"
   } else {
       ::console::affiche_erreur "Usage: spc_calibretelluric profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction d'�talonnage � partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-09-2007
# Date modification : 12-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_calibretelluric1 { args } {
    global conf
    global audace spcaudace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.2
    #set ecart 1.5
    # set ecart 1.0
    set ecart $spcaudace(dlargeur_eau)
    set marge_bord 2.5
    #set erreur 0.01

    #--- Rappels des raies pour resneignements :
    #-- Liste C.Buil :
    ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    # GOOD : set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_calibretelluric profil_de_raies_a_calibrer ?largeur_raie_pixels (28)?\n"
            return ""
        }

        #--- Gestion des profils selon la loi de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
            set lmin_spectre [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
            set lmax_spectre [ expr $spc_a+$spc_b*$naxis1+$spc_c*pow($naxis1,2)+$spc_d*pow($naxis1,3) ]
        } else {
            set flag_spccal 0
            set lmin_spectre $crval1
            set lmax_spectre [ expr $crval1+$cdelt1*($naxis1 -1) ]
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :

        ### modif michel (mes_incertitude avait une valeur beaucoup trop elevee)
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


        #--- Charge la liste des raies de l'eau :
        set file_id [ open "$spcaudace(filetelluric)" r ]
        set contents [ split [ read $file_id ] \n ]
        close $file_id
        set nbraiesbib 0
        foreach ligne $contents {
            lappend listeraieseau [ lindex $ligne 1 ]
            incr nbraiesbib
        }
        set nbraiesbib [ expr $nbraiesbib-2 ]
        set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
        set lmin_bib [ lindex $listeraieseau 0 ]
        set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
        # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


        #--- Cre�e la liste de travail des raies de l'eau pour le spectre :
        if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
            #-- Recherche la longueur minimum des raies raies telluriques utilisables (2 A) :
            set index_min 0
            foreach raieo $listeraieseau {
                if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
                    break
                } else {
                    incr index_min
                }
            }
            # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
            #-- Recherche la longueur maximum des raies raies telluriques utilisables (2 A) :
            set index_max $nbraiesbib
            for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
                if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
                    break
                }
            }
            # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
            #-- Liste des raies telluriques utilisables :
            #- Enleve une raie sur chaque bords : 070910
            # set index_min [ expr $index_min+1 ]
            # set index_max [ expr $index_max-1 ]
            set listeraies [ lrange $listeraieseau $index_min $index_max ]
            # ::console::affiche_resultat "$listeraies\n"
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }


        #--- Filtrage pour isoler le continuum :
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
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

        #--- Recherche des raies telluriques en absorption :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        #set pas [ expr int($largeur/2) ]
        #buf$audace(bufNo) scale {1 3} 1
        #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
        #buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set nbraies [ llength $listeraies ]
        set listexraies [list ]
        set listexmesures [list ]
        set listelmesurees [list ]
        set listeldiff [list ]
        foreach raie $listeraies {
            if { $flag_spccal } {
                set x  [ expr (-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie))*$spc_c))/(2*$spc_c) ]
                set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)) ]
                set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravit�
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravit�
                # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                set lambda_mes [ expr ($xcenter -1)*$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies $x
                lappend listexmesures $xcenter
                lappend listelmesurees $lambda_mes
                lappend listeldiff $ldiff
            } else {
                set x  [ expr ($raie-$crval1)/$cdelt1 + 1 ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 +1 ) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 +1 ) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravit�
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravit�
                # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                set lambda_mes [ expr  ($xcenter -1) *$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies    $x
                lappend listexmesures  $xcenter
                lappend listelmesurees $lambda_mes
                lappend listeldiff     $ldiff

            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouv�es :\n$listelmesurees\n"
        ::console::affiche_resultat "Liste des x mesures :\n$listexmesures\n"
        ::console::affiche_resultat "Liste des raies du catalogue :\n$listeraies\n"
        ::console::affiche_resultat "Liste des x du catalogue :\n$listexraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

        #--- Methode 1 : spectre initial lin�aire :
        ::console::affiche_resultat "============ 1) spectre initial lin�aire ================\n"
        set spectre_linear [ spc_linearcal "$filename" ]
        set infos_cal [ spc_rms "$spectre_linear" $listeraies ]
        set rms_initial [ lindex $infos_cal 1 ]
        set mean_shift_initial [ lindex $infos_cal 2 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        set cdelt1_initial $cdelt1
        set crval1_initial $crval1
        ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


        #--- Methode 2 : D�calage du spectre inital lin�aris� � l'aide des raies telluriques :
        ::console::affiche_resultat "============ 2) D�calage du SHIFT du spectre inital lin�aris� ================\n"
        set spectre_lindec [ spc_calibredecal "$spectre_linear" [ expr -1.0*$mean_shift_initial ] ]
        set infos_cal [ spc_rms "$spectre_lindec" $listeraies ]
        set rms_lindec [ lindex $infos_cal 1 ]
        set mean_shift_lindec [ lindex $infos_cal 2 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


        #--- Methode 5 : D�calage du spectre inital lin�aris� de la valeur du RMS : 
        ::console::affiche_resultat "============ 5) D�calage de RMS du spectre inital lin�aris� ================\n"
        #set rms_decalage [ expr $rms_initial/$cdelt1_initial/2. ]
        set rms_decalage [ expr $rms_initial/$cdelt1_initial ]
        if { $mean_shift_initial > 0. } {
           set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" [ expr -1.0*$rms_decalage ] ]
        } else {
           set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" $rms_decalage ]
        }
        set infos_cal [ spc_rms "$spectre_lindec" $listeraies ]
        set rms_lindec_rms [ lindex $infos_cal 1 ]
        set mean_shift_lindec_rms [ lindex $infos_cal 2 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


        #--- Methode 6 : callibration avec les raies telluriques :
        ::console::affiche_resultat "====== 6) Recalage sur la valeur de PDeg3 au pixel 1 ====\n"
        #-- Ajustement polynomial de degre 3 :
        set sortie [ spc_ajustdeg3 $listexmesures $listeraies $errors ]
        set coeffs [ lindex $sortie 0 ]
        set d [ lindex $coeffs 3 ]
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        #set crval1_deg3 [ expr $a+$b+$c+$d ]
        #-- Lineratistation de la loi polynomiale :
        for { set i 1 } { $i<=$naxis1 } { incr i 10 } {
          lappend abscisses $i
          lappend ordonnees [ expr $a+$b*$i+$c*pow($i,2)+$d*pow($i,3) ]
          lappend erreurs 1.
        }
        set sortie [ spc_ajustdeg1hp $abscisses $ordonnees $erreurs ]
	#- lambda0 : lambda pour x=0
        set lambda0 [ lindex [ lindex $sortie 0 ] 0 ]
        set cdelt1 [ lindex [ lindex $sortie 0 ] 1 ]
	#- crval1 : lambda pour x=1
        set crval1_deg3 [ expr $lambda0 + $cdelt1 ]
        buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
        buf$audace(bufNo) setkwd [list "CRVAL1" $crval1_deg3 double "" "angstrom" ]
        set spectre_deg3dec "${spectre_linear}_deg2dec"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$spectre_deg3dec"
        buf$audace(bufNo) bitpix short
        set infos_cal [ spc_rms "$spectre_deg3dec" $listeraies ]
        set rms_deg3dec [ lindex $infos_cal 1 ]
        set mean_shift_deg3dec [ lindex $infos_cal 2 ]


        #--- Methode 3 : callibration avec les raies telluriques :
        ::console::affiche_resultat "============ 3) calibration sur l'eau ================\n"
        #-- Ajustement polynomial de degre 3 :
        set sortie [ spc_ajustdeg3 $listexmesures $listeraies $errors ]
        set coeffs [ lindex $sortie 0 ]
        set d [ lindex $coeffs 3 ]
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        set chi2 [ lindex $sortie 1 ]
        set covar [ lindex $sortie 2 ]
        set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]

        #-- Sauvegarde le spectre calibr� non-lin�airement :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocalnl"
        buf$audace(bufNo) bitpix short

        #-- Recalage de la calibration grace aux raies telluriques :
        #- R��chantillonnage pour obtenir une loi de calibration lin�aire :
        set spectre_ocallin [ spc_linearcal "${filename}-ocalnl" ]

        #- Calcul de d�calage moyen+rms :
        set mean_shift [ lindex [ spc_rms "$spectre_ocallin" $listeraies ] 2 ]
        #- R�alise le d�calage sur la loi lin�aire :
        set spectre_ocalshifted [ spc_calibredecal "$spectre_ocallin" [ expr -1.*$mean_shift ] ]
        #- Calcul le d�calage moyen+rms du spectre final :
        # set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies 1.5 ]
        set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies ]
        set rms_calo [ lindex $infos_cal 1 ]
        set mean_shift_calo [ lindex $infos_cal 2 ]
        #- Effacement des fichiers temporaires :
        if { $spectre_ocallin != "${filename}-ocalnl" } {
            file delete -force "$audace(rep_images)/${filename}-ocalnl$conf(extension,defaut)"
        }
        file delete -force "$audace(rep_images)/$spectre_ocallin$conf(extension,defaut)"
        #- Enregistre les �l�ments de la calibration :
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]


        #--- Methode 4 : callibration 2 avec les raies telluriques
        ::console::affiche_resultat "============ 4) calibration sur l'eau bis ================\n"
        #-- Calcul du polyn�me de calibration xlin = a+bx+cx^2+cx^3
        ### spc_calibretelluric 94-bet-leo--profil-traite-final.fit
        set sortie [ spc_ajustdeg2 $listexmesures $listexraies $errors ]
        # set sortie [ spc_ajustdeg3 $listexmesures $listexraies $errors ]
        set coeffs [ lindex $sortie 0 ]
        # set d [ lindex $coeffs 3 ]
        set d 0.0
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        set chi2 [ lindex $sortie 1 ]
        set covar [ lindex $sortie 2 ]
        set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]

        #-- je calcule les x linearises
        set listexlin [list]
        foreach x $listexmesures {
            lappend listexlin [ expr $a + $b*$x + $c*$x*$x + $d*$x*$x*$x ]
        }

        #-- je charge l'image calibree avec le neon
        buf$audace(bufNo) load "$audace(rep_images)/$filename"

        #-- R��chantillonnage pour obtenir une loi de calibration lin�aire :
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        set xorigin [list ]
        set xlinear [list ]
        set intensites [list ]
        for {set x 0 } {$x<$naxis1} {incr x} {
            lappend xorigin $x
            lappend xlinear [ expr $a + $b*$x + $c*$x*$x + $d*$x*$x*$x ]
            lappend intensities [lindex [ buf$audace(bufNo) getpix [list [expr $x +1] 1] ] 1]
        }
        set newIntensities [ lindex [ spc_spline $xlinear $intensities $xorigin n ] 1 ]
        for {set x 0 } {$x<$naxis1} {incr x} {
            buf$audace(bufNo) setpix [ list [expr $x +1] 1 ] [lindex $newIntensities $x]
        }

        #-- je calcule les coefficients de la droite moyenne lambda=f(xlin)
        set sortie [ spc_ajustdeg1hp $listexlin $listeraies $errors ]
	#- lambda0 : lambda pour x=0
        set lambda0 [lindex [ lindex $sortie 0 ] 0]
        set cdelt1 [lindex [ lindex $sortie 0 ] 1]
	#- crval1 : lambda pour x=1
        set crval1 [expr $lambda0 + $cdelt1]
        buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 double "" "angstrom" ]
        buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1 double "" "angstrom/pixel" ]
	set listemotsclef [ buf$audace(bufNo) getkwds ]
	if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	    buf$audace(bufNo) delkwd "SPC_A"
	    buf$audace(bufNo) delkwd "SPC_B"
	    buf$audace(bufNo) delkwd "SPC_C"
	    if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
		buf$audace(bufNo) delkwd "SPC_D"
	    }
	}

        #-- j'enregistre l'image
        set spectre_ocallinbis "${filename}-ocalnlbis"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$spectre_ocallinbis"
        buf$audace(bufNo) bitpix short

        #-- Calcul le d�calage moyen+rms du spectre final :
        set infos_cal   [ spc_rms $spectre_ocallinbis $listeraies ]
        set rms_calobis [ lindex $infos_cal 1 ]
        set mean_shift_calobis [ lindex $infos_cal 2 ]
        ::console::affiche_resultat "Loi de calibration lineaire calobis : $crval1+$cdelt1*x\n"


        #--- D�termine la meilleure calibration :
        ::console::affiche_resultat "============ D�termine la meilleure calibration ================\n"
        #-- Sauvera le spectre final recalibr� (lin�arirement) :
        # set liste_rms [ list [ list "calobis" $rms_calobis ] [ list "calo" $rms_calo ] [ list "lindec" $rms_lindec ] [ list "initial" $rms_initial ] ]
        #-- Gestion des m�thodes s�lectionn�es (car calo n�3 mauvaise selon la taille du capteur) :
        set liste_rms [ list ]
        if { [ lsearch $spcaudace(calo_meths) 1 ] != -1 } {
           lappend liste_rms [ list "initial" $rms_initial ]
        }
        if { [ lsearch $spcaudace(calo_meths) 2 ] != -1 } {
           lappend liste_rms [ list "lindec" $rms_lindec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 3 ] != -1 } {
           lappend liste_rms [ list "calo" $rms_calo ]
        }
        if { [ lsearch $spcaudace(calo_meths) 4 ] != -1 } {
           lappend liste_rms [ list "calobis" $rms_calobis ]
        }
        if { [ lsearch $spcaudace(calo_meths) 5 ] != -1 } {
           lappend liste_rms [ list "lindec_rms" $rms_lindec_rms ]
        }
        if { [ lsearch $spcaudace(calo_meths) 6 ] != -1 } {
           lappend liste_rms [ list "deg3dec" $rms_deg3dec ]
        }

        #-- Tri par RMS croissant :
        set liste_rms [ lsort -index 1 -increasing -real $liste_rms ]
        set best_rms_name [ lindex [ lindex $liste_rms 0 ] 0 ]
        set best_rms_val [ lindex [ lindex $liste_rms 0 ] 1 ]

	#-- Compare et choisis la meilleure calibration a l'aide du RMS :
        if { $best_rms_name == "calobis" } {
            #-- Le spectre recalibr� avec l'eau (4) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocallinbis"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_calobis double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 4)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre recalibr� avec (4) les raies telluriques de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_calobis A\nEcart moyen=$mean_shift_calobis A\n\n"
        } elseif { $best_rms_name == "calo" } {
            #-- Le spectre recalibr� avec l'eau (3) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocalshifted"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_calo double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 3)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre recalibr� avec (3) les raies telluriques de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Loi de calibration tellutique trouv�e : $a+$b*x+$c*x^2\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_calo A\nEcart moyen=$mean_shift_calo A\n\n"
        } elseif { $best_rms_name == "lindec" } {
            #-- Le spectre lin�aris� juste d�cal� avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_lindec double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 2)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (2) d�calage de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_lindec A\nEcart moyen=$mean_shift_lindec A\n\n"
        } elseif { $best_rms_name == "lindec_rms" } {
            #-- Le spectre lin�aris� juste d�cal� avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec_rms"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_lindec_rms double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 5)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (5) d�calage de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_lindec_rms A\nEcart moyen=$mean_shift_lindec_rms A\n\n"
        } elseif { $best_rms_name == "deg3dec" } {
            #-- La calibration du spectre inital est meilleure :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_deg3dec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_deg3dec double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 6)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (6) de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_initial A\nEcart moyen=$mean_shift_initial A\n\n"
        } elseif { $best_rms_name == "initial" } {
            #-- La calibration du spectre inital est meilleure :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_initial double "" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 1)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des r�sultats :
            ::console::affiche_resultat "\nSpectre de calibration (1) initiale de meilleure qualit�.\n"
            ::console::affiche_resultat "Loi de calibration finale lin�aris�e : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualit� de la calibration :\nRMS=$rms_initial A\nEcart moyen=$mean_shift_initial A\n\n"
        }

        #--- Effacement des fichiers resultats des 4 methodes
        file delete -force "$audace(rep_images)/$spectre_ocallinbis$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_ocalshifted$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_lindec$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_lindec_rms$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_deg3dec$conf(extension,defaut)"
        if { $spectre_linear != $filename } {
           file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"
        }
        return "${filename}-ocal"
   } else {
       ::console::affiche_erreur "Usage: spc_calibretelluric1 profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#




####################################################################
# R�alise un diagnostique de la calibration par prapport aux raies de l'eau :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-09-2007
# Date modification : 23-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_calobilan { args } {
    global conf
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_calobilan nom_profil_de_raies_fits ?largeur_raie (pixel)?\n"
            return ""
        }

        #--- Met le spectre de l'eau au niveau du continuum du spectre �tidi� :
        #-- D�termine la valeur du continuum :
        set icontinuum [ spc_icontinuum "$filename" ]
        #-- Applique au spectre de l'eau :
        buf$audace(bufNo) load "$spcaudace(reptelluric)/$spcaudace(sp_eau)"
        buf$audace(bufNo) mult $icontinuum
        buf$audace(bufNo) save "$audace(rep_images)/eau_conti"

        #--- Affichage des renseignements :
        spc_gdeleteall
        spc_load "$filename"
        spc_loadmore "eau_conti" "green"
        set spcaudace(gcolor) [ expr $spcaudace(gcolor) + 1 ]
        spc_caloverif "$filename"
        file delete -force "$audace(rep_images)/eau_conti$conf(extension,defaut)"
   } else {
       ::console::affiche_erreur "Usage: spc_calobilan profil_de_raies_fits ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#


####################################################################
# R�alise un diagnostique de la calibration par prapport aux raies de l'eau :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-09-2007
# Date modification : 23-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_loadmh2o { args } {
    global conf caption
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } elseif { $nbargs == 0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set filename $spctrouve
	   } else {
              ::console::affiche_erreur "Le profil de raies doit se trouver dans le r�pertoire de travail.\nUsage: spc_loadmh2o nom_profil_de_raies_fits ?largeur_raie (pixel)?\n"
              return ""
	   }
        }

        #--- Met le spectre de l'eau au niveau du continuum du spectre �tidi� :
        #-- D�termine la valeur du continuum :
        set icontinuum [ spc_icontinuum "$filename" ]
        #-- Applique au spectre de l'eau :
        buf$audace(bufNo) load "$spcaudace(reptelluric)/$spcaudace(sp_eau)"
        buf$audace(bufNo) mult $icontinuum
        buf$audace(bufNo) save "$audace(rep_images)/eau_conti"

        #--- Affichage des renseignements :
        spc_gdeleteall
        if { [ llength $spcaudace(gloaded) ] == 0 } {
           spc_load "$filename"
        }
        spc_loadmore "eau_conti" "green"
        set spcaudace(gcolor) [ expr $spcaudace(gcolor) + 1 ]
        file delete -force "$audace(rep_images)/eau_conti$conf(extension,defaut)"
   } else {
       ::console::affiche_erreur "Usage: spc_loadmh2o profil_de_raies_fits ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#




####################################################################
# Visualise un spectre de l'au de la biblioth�que
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-09-2007
# Date modification : 23-09-2007
# Arguments : ?nom_profil_raies_eau_biblioth�que?
####################################################################

proc spc_loadh2o { args } {
    global conf
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs <= 1 } {
        if { $nbargs == 1 } {
            set fileselect [ file rootname [ lindex $args 0 ] ]
            set filename "${fileselect}.fit"
        } elseif { $nbargs == 0 } {
            set filename $spcaudace(sp_eau)
        } else {
            ::console::affiche_erreur "Usage: spc_loadh2o ?nom_profil_de_raies_telluric_bibliotheque?\n\n"
            return ""
        }

        #--- Cherche le spectre de l'eau :
        file copy -force "$spcaudace(reptelluric)/$filename" "$audace(rep_images)/$filename"
        #--- Affiche :
        if { [ llength $spcaudace(gloaded) ] == 0 } {
            spc_load "$filename"
        } else {
            spc_loadmore "$filename"
        }

        #--- Nettoie le r�petoire de travail :
        file delete -force "$audace(rep_images)/$filename"

    } else {
        ::console::affiche_erreur "Usage: spc_loadh2o ?nom_profil_de_raies_telluric_bibliotheque?\n\n"
    }
}
#****************************************************************#



####################################################################
# Proc�dure de recalage en longueur d'onde a partir d'une raie tellurique de l'eau
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-03-2007
# Date modification : 25-03-2007
# Arguments : profil_de_raies_�toile_r�f�rence profil_de_raies_a_calibrer lambda_eau_mesur�e_6532
####################################################################

proc spc_calibrehaeau { args } {
    global conf
    global audace

    #-- Liste C.Buil :
    ## set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    #set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]

    if { [llength $args]==3 } {
        set spreference [ lindex $args 0 ]
        set spacalibrer [ lindex $args 1 ]
        set leau [ lindex $args 2 ]


        #--- Affichage des r�sultats :
        ::console::affiche_resultat "Le spectre calibr� est sauv� sous $fileout\n"
        return ""
    } else {
       ::console::affiche_erreur "Usage: spc_calibrehaeau profil_de_raies_�toile_r�f�rence profil_de_raies_a_calibrer lambda_eau_mesur�e_6532\n\n"
   }
}
#***************************************************************************#




####################################################################
# Fonction d'�talonnage � partir de raies de l'eau autour de Ha
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

        #--- Gestion des profils calibr�s en longueur d'onde :
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
### modif michel
###            set xdeb [ expr int(($lfin????-$crval1)/$cdelt1) ]
###            set xfin [ expr int(($lfin-$crval1)/$cdelt1) ]
            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) -1 ]
            set xfin [ expr round(($lfin-$crval1)/$cdelt1) -1 ]
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }

        #--- Recherche des raies d'�mission :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        buf$audace(bufNo) mult -1.0
        set nbraies [ llength $listeraies ]
        foreach raie $listeraies {
### modif michel
###            set x1 [ expr int(($raie-$ecart-$crval1)/$cdelt1) ]
###            set x2 [ expr int(($raie+$ecart-$crval1)/$cdelt1) ]
            set x1 [ expr int(($raie-$ecart-$crval1)/$cdelt1 -1) ]
            set x2 [ expr int(($raie+$ecart-$crval1)/$cdelt1 -1) ]
            set coords [ list $x1 1 $x2 1 ]
            if { $largeur == 0 } {
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1*$cdelt1+$crval1 ]
            } else {
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1)*$cdelt1+$crval1 ]
            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouv�es :\n$listelmesurees\n"
        # ::console::affiche_resultat "Liste des raies trouv�es : $listemesures\n"
        ::console::affiche_resultat "Liste des raies de r�f�rence :\n$listeraies\n"

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

        #--- Calcul du polyn�me de calibration a+bx+cx^2 :
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

        #--- Calcul des co�fficients de lin�arisation de la calibration a1x+b1 (r�gression lin�aire sur les abscisses choisies et leur lambda issues du polynome) :
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


        #--- Redonne le lambda du centre des raies apres r��talonnage :
        set ecart2 0.6
        foreach raie $listeraies {
### modif michel
###            set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1) ]
###            set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1) ]
            set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1 -1) ]
            set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1 -1) ]
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
        #::console::affiche_resultat "Liste des raies apr�s r��talonnage :\n$listelmesurees2\n� comparer avec :\n$listeraies\n"


        #--- Mise � jour des mots clefs :
        buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
        #-- Longueur d'onde de d�part :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
        #-- Dispersion moyenne :
        #buf$audace(bufNo) setkwd [list "CDELT1" $a1 float "" "angstrom/pixel"]
        #buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
        #-- Corrdonn�e repr�sent�e sur l'axe 1 (ie X) :
        #buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
        #-- Mots clefs du polyn�me :
        buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        #buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "angstrom/pixel"]
        #buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]

        #--- Sauvegarde :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
        buf$audace(bufNo) bitpix short

        #--- Fin du script :
        ::console::affiche_resultat "Spectre �talonn� sauv� sous l${filename}\n"
        return l${filename}

   } else {
       ::console::affiche_erreur "Usage: spc_autocalibrehaeau profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#









##########################################################
# Procedure de correction de la vitesse h�liocentrique de la calibration en longueur d'onde
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 05-03-2007
# Date de mise � jour : 05-03-2007
# Arguments : profil_raies_�talonn� lambda_calage ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
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
           #::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_�talonn� lambda_calage ?[[?RA_d RA_m RA_s DEC_h DEC_m DEC_s?] ?JJ MM AAAA?]?\n\n"
           ::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_�talonn� lambda_calage ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA??\n\n"
           return 0
       }

       #--- Calcul du d�calage en longueur d'onde pour lambda_ref :
       set deltal [ expr $lambda_cal*$vhelio/299792.458 ]
       #--- Recalage en longueur d'onde du spectre :
       set fileout [ spc_calibredecal $spectre $deltal ]

       #--- Traitement du r�sultat :
       buf$audace(bufNo) load "$audace(rep_images)/$fileout"
       buf$audace(bufNo) setkwd [ list BSS_VHEL $vhelio float "Heliocentric velocity at data date" "km/s" ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/$fileout"
       buf$audace(bufNo) bitpix short

       file rename -force "$audace(rep_images)/$fileout$conf(extension,defaut)" "$audace(rep_images)/${spectre}_vhel$conf(extension,defaut)"
       ::console::affiche_resultat "Spectre d�cal� de $deltal A sauv� sous ${spectre}_vhel\n"
       return ${spectre}_vhel
   } else {
       #::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_�talonn� lambda_calage ?[[?RA_d RA_m RA_s DEC_h DEC_m DEC_s?] ?JJ MM AAAA?]?\n\n"
       ::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_�talonn� lambda_calage ??RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA??\n\n"
       return 0
   }
}
#****************************************************************#





##########################################################
# Procedure de test si un spectre est un PROFIL qui est CALIBRE
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 03-08-2007
# Date de mise � jour : 03-08-2007
# Arguments : spectre
# Sortie : retourne 1 si c'est un profil de raies calibr�, sinon 0, si spectre 2D -1
##########################################################

proc spc_testcalibre { args } {

   global audace
   global conf

   if { [llength $args] == 1 } {
      set lampe [ lindex $args 0 ]
      set flag_calibration 0

      buf$audace(bufNo) load "$audace(rep_images)/$lampe"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      #--- NAXIS2 n'existe pas :
      if { [ lsearch $listemotsclef "NAXIS2" ] ==-1 } {
          if { [ lsearch $listemotsclef "CUNIT1" ] != -1 } {
              set cunit1 [ lindex [ buf$audace(bufNo) getkwd "CUNIT1" ] 1 ]
              if { $cunit1=="angstrom" || $cunit1=="Angstrom" || $cunit1=="angstroms" || $cunit1=="Angstroms" } {
                  set flag_calibration 1
              } else {
                  ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier.\n"
                  tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier."
                  set flag_calibration -1
              }
          } else {
          #-- CUNIT1 n'existe pas, donc test sur CRVAL1 :
              if { [ lsearch $listemotsclef "CRVAL1" ] != -1 } {
                  set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
                  if { $crval1 != 1. } {
                      set flag_calibration 1
                  } else {
                      ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier.\n"
                      tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier."
                      set flag_calibration -1
                  }
              } else {
                  ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier.\n"
                  tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier."
                  set flag_calibration -1
              }
          }
      } else {
      #--- NAXIS2 existe :
          set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
          #-- NAXIS2 est �gale � 1 :
          if { $naxis2==1 } {
              if { [ lsearch $listemotsclef "CUNIT1" ] != -1 } {
                  set cunit1 [ lindex [ buf$audace(bufNo) getkwd "CUNIT1" ] 1 ]
                  if { $cunit1=="angstrom" || $cunit1=="Angstrom" || $cunit1=="angstroms" || $cunit1=="Angstroms" } {
                      set flag_calibration 1
                  } else {
                      ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier.\n"
                      tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier."
                      set flag_calibration -1
                  }
              } else {
                      ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier.\n"
                      tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibr�.\nVeuillez choisir le bon fichier."
                      set flag_calibration -1
              }
          } else {
          #-- NAXIS2 est diff�rent de 1 : ce spectre est � traiter.
              set flag_calibration 0
          }
      }

      return $flag_calibration
   } else {
      ::console::affiche_erreur "Usage: spc_testcalibre spectre_fits_�_tester\n\n"
   }
}














#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#            Correction de la r�ponse instrumentale                          #
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


##########################################################
# Calcul la r�ponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 20-03-06/26-08-06/23-07-2007
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division
##########################################################

proc spc_rinstrum { args } {

   global audace spcaudace
   global conf
   set precision 0.0001

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]


       #--- R��chanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nR��chantillonnage du spectre de r�f�rence...\n"
       set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]

       #--- Divison des deux profils de raies pour obtention de la r�ponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la r�ponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       # set result_division_tot [ spc_divbrut $fmes_sortie $fref_sortie ]

       #--- Mise � 0 des bords par s�curit� et propret�, en attendant une gestion des effets de bords :
       # set result_division [ spc_bordsnuls $result_division_tot ]
       # file delete -force "$audace(rep_images)/$result_division_tot"

       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la r�ponse instrumentale...\n"
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

       #-- Meth 6 : filtrage lin�aire par mor�eaux -> RI 0 sp�ciale basse r�sulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"

       #--- Test si c'est un cas de basse r�olution () :
       #-- Meth 1 :
       # buf$audace(bufNo) load "$audace(rep_images)/$result_division"
       # set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       #if { $dispersion>=$spcaudace(dmax) } {
       #    set flag_br 1
       #} else {
       #    set flag_br 0
       #}
       #-- Meth 2 : (071009) g�re le cas o� CDELT1 n'est pas coh�rent avec SPC_B (spectre initalialement non-lin�aires issus de spc_calibren $a1)
       buf$audace(bufNo) load "$audace(rep_images)/$result_division"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
           set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
           set bp [ expr $dispersion*$naxis1 ]
           if { $bp >= $spcaudace(bp_br) } {
               set flag_br 1
           } else {
               set flag_br 0
           }
       } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
           set bp [ expr $dispersion*$naxis1 ]
           if { $bp >= $spcaudace(bp_br) } {
               set flag_br 1
           } else {
               set flag_br 0
           }
       }


       #--- Lissage du r�sultat de la division :
       if { $flag_br==0 } {
           #-- Meth 3 : interpolation polynomiale de degr� 1 -> RI 1
           set rinstrum [ spc_ajustrid1 $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-1$conf(extension,defaut)"

           #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
           #set rinstrum [ spc_ajustripbas $result_division ]
           #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"
           #-- Meth 6 : filtrage passe bas fort -> RI 2
           set rinstrum [ spc_ajustripbasfort $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-2$conf(extension,defaut)"
           #-- Meth 4 : interpolation polynomiale de 4 -> RI 3
           set rinstrum [ spc_polynomefilter $result_division 3 150 o ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"


       } elseif { $flag_br==1 } {
           if { $dispersion<=1. } {
               #-- Lhires3+r�sos 600 t/mm et 1200 t/mm-kaf1600 :
               set rinstrum [ spc_pwlfilter $result_division 280 o 51 201 10 2 50 ]
           } else {
           #-- Lhires3+r�sos 300 et 150 t/mm :
               ## set rinstrum [ spc_pwlfilter $result_division 50 o 11 51 70 50 100 ]
               # set rinstrum [ spc_pwlfilter $result_division 24 o 3 3 50 50 50 ]
              set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 10 { 1.0 2.0 } "o" 18 ]
           }
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)"
       }


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
           ::console::affiche_resultat "\nLa r�ponse intrumentale ne peut �tre calcul�e.\n"
           return 0
       } else {
          if { $flag_br == 1 } {
             ::console::affiche_erreur "R�ponse instrumentale sauv�e sous reponse_instrumentale-br$conf(extension,defaut)\n"
             #return reponse_instrumentale-br
             return reponse_instrumentale-
          } else {
             #-- R�sultat de la division :
             ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
             ::console::affiche_erreur "R�ponse instrumentale sauv�e sous reponse_instrumentale-3$conf(extension,defaut)\n"
             #-- Le postfix sera soit 1, 2, 3 :
             return reponse_instrumentale-
          }
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesur� profil_de_raies_de_r�f�rence ?option basse r�solution >800A (o/n)?\n\n"
   }
}
#****************************************************************#



##########################################################
# Calcul la r�ponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 20-03-06/26-08-06/23-07-2007
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division
##########################################################

proc spc_rinstrum2 { args } {

   global audace
   global conf
   set precision 0.0001

   set nbargs [ llength $args ]
   if { $nbargs<=3 } {
       if { $nbargs==2 } {
           set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
           set fichier_ref [ file rootname [ lindex $args 1 ] ]
           set ribr "n"
       } elseif { $nbargs==3 } {
           set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
           set fichier_ref [ file rootname [ lindex $args 1 ] ]
           set ribr [ lindex $args 2 ]
       } else {
           ::console::affiche_erreur "Usage: spc_rinstrum2 profil_de_raies_mesur� profil_de_raies_de_r�f�rence ?option basse r�solution >800A (o/n)?\n\n"
           return 0
       }


       #--- R��chanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nR��chantillonnage du spectre de r�f�rence...\n"
       set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]

       #--- Divison des deux profils de raies pour obtention de la r�ponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la r�ponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]


       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la r�ponse instrumentale...\n"
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

       #-- Meth 6 : filtrage lin�aire par mor�eaux -> RI 0 sp�ciale basse r�sulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"

       if { $ribr=="n" } {
           #-- Meth 3 : interpolation polynomiale de degr� 1 -> RI 1
           set rinstrum [ spc_ajustrid1 $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale1$conf(extension,defaut)"
           #-- Meth 4 : interpolation polynomiale de 2 -> RI 2
           set rinstrum [ spc_ajustrid2 $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale2$conf(extension,defaut)"

           #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
           set rinstrum [ spc_ajustripbas $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale3$conf(extension,defaut)"
       } elseif { $ribr=="o" } {
           set rinstrum [ spc_pwlfilter $result_division 50 o 11 51 70 50 100 ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"
       }


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
           ::console::affiche_resultat "\nLa r�ponse intrumentale ne peut �tre calcul�e.\n"
           return 0
       } else {
           #-- R�sultat de la division :
           ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
           ::console::affiche_resultat "R�ponse instrumentale sauv�e sous reponse_instrumentale3$conf(extension,defaut)\n"
           return reponse_instrumentale3
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum2 profil_de_raies_mesur� profil_de_raies_de_r�f�rence ?option basse r�solution >800A (o/n)?\n\n"
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
       #set rinstrum_ech [ spc_echant $rinstrum $spectre_acorr ]
       #set spectre_corr [ spc_div $spectre_acorr $rinstrum_ech ]
       #file delete "$audace(rep_images)/$rinstrum_ech$conf(extension,defaut)"
       set spectre_corr [ spc_divri $spectre_acorr $rinstrum ]

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
       #set rinstrum_ech [ spc_echant $rinstrum $spectre_acorr ]
       #set spectre_corr [ spc_div $spectre_acorr $rinstrum_ech ]
       #file delete "$audace(rep_images)/$rinstrum_ech$conf(extension,defaut)"
       set spectre_corr [ spc_divri $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
           ::console::affiche_resultat "\nLe profil corrig� de la r�ponse intrumentale ne peut �tre calcul�e.\n"
           return 0
       } else {
           file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_riocorr$conf(extension,defaut)"
           ::console::affiche_resultat "\nProfil corrig� de la r�ponse intrumentale et des raies tellurtiques sauv� sous ${spectre_acorr}_riocorr.\n\n"
           return ${spectre_acorr}_riocorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumeaucorr profil_a_corriger profil_�toile_r�f�rence profil_�toile_catalogue\n\n"
   }
}
#****************************************************************#




####################################################################
# Procedure d'ajustement d'un nuage de points de r�ponse instrumentale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2007
# Date modification : 27-02-2007
# Arguments : fichier .fit de la r�ponse instrumentale
# Algo : ajustement par un polynome de degr� 1 avec abaissement global bas� sur la moyenne de la difference des valeurs y_deb et y_fin de l'intervalle.
####################################################################

proc spc_ajustrid1 { args } {
    global conf
    global audace

    if {[llength $args] == 1} {
        set filenamespc [ lindex $args 0 ]

        #--- Initialisation des param�tres et des donn�es :
        set erreur 1.
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set len [ llength $ordonnees ]
        set limits [ spc_findnnul $ordonnees ]
        set i_inf [ lindex $limits 0 ]
        set i_sup [ lindex $limits 1 ]

        #--- Calcul des coefficients du polyn�me d'ajustement :
        # - calcul de la matrice X
        set ordonnees_cut [ list ]
        set X ""
        for {set i $i_inf} {$i<$i_sup} {incr i} {
            set xi [ lindex $abscisses $i ]
            set ligne_i 1
            lappend ordonnees_cut [ lindex $ordonnees $i ]
            lappend erreurs $erreur
            lappend ligne_i $xi
            lappend X $ligne_i
        }
        #-- calcul de l'ajustement
        set result [ gsl_mfitmultilin $ordonnees_cut $X $erreurs ]
        #-- extrait le resultat
        set coeffs [lindex $result 0]
        set chi2 [lindex $result 1]
        set covar [lindex $result 2]

        set a [lindex $coeffs 0]
        set b [lindex $coeffs 1]
        ::console::affiche_resultat "Coefficients de la droite d'interpolation : $a+$b*x\n"


        #--- Met a jour les nouvelles intensit�s :
        buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        for {set k 1} {$k<=$naxis1} {incr k} {
            set x [ lindex $abscisses [ expr $k-1 ] ]
            set y [ lindex $ordonnees [ expr $k-1 ] ]
            if { $y==0 } {
                set yadj 0.
            } else {
                set yadj [ expr $a+$b*$x ]
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
        ::plotxy::title "bleu : R�sultat division - rouge : RI interpol�e deg 1"
        ::plotxy::hold off

        #--- Sauvegarde du r�sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajustrid1 fichier_profil.fit\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points de r�ponse instrumentale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-02-2007
# Date modification : 26-02-2007
# Arguments : fichier .fit de la r�ponse instrumentale
# Algo : ajustement par un polynome de degr� 2 avec abaissement global bas� sur la moyenne de la difference des valeurs y_deb et y_fin de l'intervalle.
####################################################################

proc spc_ajustrid2 { args } {
    global conf
    global audace spcaudace

    if {[llength $args] == 1} {
        set filenamespc [ lindex $args 0 ]

        #--- Initialisation des param�tres et des donn�es :
        set erreur 1.
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $ordonnees]
        set limits [ spc_findnnul $ordonnees ]
        set i_inf [ lindex $limits 0 ]
        set i_sup [ lindex $limits 1 ]

        #--- Calcul des coefficients du polyn�me d'ajustement :
        # - calcul de la matrice X
        set n [llength $abscisses]
        set ordonnees_cut [ list ]
        set X ""
        for {set i $i_inf} {$i<$i_sup} {incr i} {
            set xi [lindex $abscisses $i]
            set ligne_i 1
            lappend ordonnees_cut [ lindex $ordonnees $i ]
            lappend erreurs $erreur
            lappend ligne_i $xi
            lappend ligne_i [expr $xi*$xi]
            lappend X $ligne_i
        }
        #-- calcul de l'ajustement
        set result [ gsl_mfitmultilin $ordonnees_cut $X $erreurs ]
        #-- extrait le resultat
        set coeffs [lindex $result 0]
        set chi2 [lindex $result 1]
        set covar [lindex $result 2]

        set a [lindex $coeffs 0]
        set b [lindex $coeffs 1]
        set c [lindex $coeffs 2]
        ::console::affiche_resultat "Coefficients du polyn�me : $a+$b*x+$c*x^2\n"

        #--- Calcul la valeur a retrancher : bas�e sur la difference moyenne y_deb et y_fin calculee par rapport aux mesures :
        set ecart [ expr round($len*$spcaudace(bordsnuls)) ]
        set xdeb [ lindex $abscisses $ecart ]
        set xfin [ lindex $abscisses [ expr $len-$ecart-1 ] ]
        set ycalc_deb [ expr $a+$b*$xdeb+$c*$xdeb*$xdeb ]
        set ycalc_fin [ expr $a+$b*$xfin+$c*$xfin*$xfin ]
        set ymes_deb [ lindex $ordonnees $ecart ]
        set ymes_fin [ lindex $ordonnees [ expr $len-$ecart-1 ] ]
        #::console::affiche_resultat "$ycalc_deb ; $ycalc_fin ; $ymes_deb ; $ymes_fin\n"
        ## set dy_moy [ expr 0.5*(abs($ycalc_deb-$ymes_deb)+abs($ycalc_fin-$ymes_fin)) ]
        set dy_moy [ expr 0.5*($ycalc_deb-$ymes_deb+$ycalc_fin-$ymes_fin) ]
        # Pujol 070930 : set dy_moy [ expr 0.29*($ycalc_deb-$ymes_deb+$ycalc_fin-$ymes_fin) ]
        #::console::affiche_resultat "Offset � retrancher : $dy_moy\n"
        set aadj [ expr $a-$dy_moy ]
        #set aadj $a

        #--- Met a jour les nouvelles intensit�s :
        buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        for {set k 1} {$k<=$naxis1} {incr k} {
            set x [ lindex $abscisses [ expr $k-1 ] ]
            set y [ lindex $ordonnees [ expr $k-1 ] ]
            if { $y==0 } {
                set yadj 0.
            } else {
                # set yadj [ expr $a+$b*$x+$c*$x*$x ]
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
        ::plotxy::title "bleu : R�sultat division - rouge : RI interpol�e deg 2"
        ::plotxy::hold off


        #--- Sauvegarde du r�sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
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

        #--- Effacement des fichiers interm�diaires :
        file delete -force "$audace(rep_images)/$rinstrum1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$rinstrum2$conf(extension,defaut)"

        #--- Extraction des donn�es :
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set yadjs [ lindex [ spc_fits2data $rinstrum ] 1 ]

        #--- Affichage du graphe
        #::plotxy::clf
        ::plotxy::figure 2
        ::plotxy::plot $abscisses $yadjs r 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ::plotxy::title "bleu : R�sultat division - rouge : RI filtr�e passe bas"
        ::plotxy::hold off

        #--- Retour du r�sultat :
        file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        ::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajustripbas fichier_profil.fit\n\n"
    }
}
#****************************************************************#


####################################################################
# Procedure d'ajustement d'un nuage de points avec fort lissage
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 13-02-2008
# Date modification : 13-02-2008
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajustripbasfort { args } {
    global conf
    global audace

    if { [ llength $args ]==1 } {
        set filenamespc [ lindex $args 0 ]

        #--- Filtrages passe-bas :
        set rinstrum1 [ spc_passebas $filenamespc 200 ]
        set rinstrum2 [ spc_smooth2 $rinstrum1 ]
        set rinstrum3 [ spc_passebas $rinstrum2 100 ]
        set rinstrum [ spc_passebas $rinstrum3 25 ]

        #--- Effacement des fichiers interm�diaires :
        file delete -force "$audace(rep_images)/$rinstrum1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$rinstrum2$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$rinstrum3$conf(extension,defaut)"

        #--- Extraction des donn�es :
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set yadjs [ lindex [ spc_fits2data $rinstrum ] 1 ]

        #--- Affichage du graphe
        #::plotxy::clf
        ::plotxy::figure 2
        ::plotxy::plot $abscisses $yadjs r 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ::plotxy::title "bleu : R�sultat division - rouge : filtrage passe bas fort"
        ::plotxy::hold off

        #--- Retour du r�sultat :
        file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        ::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajustripbasfort fichier_profil.fit\n\n"
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



if {1==0} {


##########################################################
# Calcul la r�ponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division
##########################################################

proc spc_rinstrum_23-07-2007 { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

     #===================================================================#
     if { 1==0 } {
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
    }
    #======================================================================#

       #--- R��chanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nR��chantillonnage du spectre de r�f�rence...\n"
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
           ::console::affiche_resultat "D�calage de $deltal angstroms entre les 2 profils, recalage du profil de l'�toile du catalogue...\n"
           buf$audace(bufNo) load "$audace(rep_images)/$fmes_sortie"
           set listemotsclef [ buf$audace(bufNo) getkwds ]
           set lambda0dec [ expr $lambda0+$deltal ]
           buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda0dec double "" "angstrom" ]
           if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_A" $lambda0dec double "" "angstrom"]
           }
           buf$audace(bufNo) bitpix float
           buf$audace(bufNo) save "$audace(rep_images)/${fmes_sortie}_dec"
           buf$audace(bufNo) bitpix short
           set fref_sortie [ spc_echant ${fmes_sortie}_dec $fichier_ref ]
           #file delete -force "$audace(rep_images)/${fmes_sortie}_dec"
       }
   }

       #--- Divison des deux profils de raies pour obtention de la r�ponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la r�ponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]


       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la r�ponse instrumentale...\n"
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

       #-- Meth 6 : filtrage lin�aire par mor�eaux -> RI 0 sp�ciale basse r�sulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"


       #-- Meth 3 : interpolation polynomiale de degr� 1 -> RI 1
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
           ::console::affiche_resultat "\nLa r�ponse intrumentale ne peut �tre calcul�e.\n"
           return 0
       } else {
           #-- R�sultat de la division :
           ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
           ::console::affiche_resultat "R�ponse instrumentale sauv�e sous reponse_instrumentale3$conf(extension,defaut)\n"
           return reponse_instrumentale3
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesur� profil_de_raies_de_r�f�rence\n\n"
   }
}
#****************************************************************#



####################################################################
# Proc�dure de calibration par un polyn�me de degr� 2 (au moins 3 raies n�cessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################

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


##########################################################
# Calcul la r�ponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division
##########################################################

proc spc_rinstrum_060826 { args } {

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



proc spc_rinstrum_260806 { args } {

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
       set fref_ready [ spc_bigsmooth2 $fref_sortie ]
       set fmes_ready [ spc_bigsmooth2 $fmes_sortie ]
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
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale$conf(extension,defaut)"
           ::console::affiche_resultat "R�ponse instrumentale sauv�e sous reponse_instrumentale$conf(extension,defaut)\n"
           return reponse_instrumentale
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesur� profil_de_raies_de_r�f�rence\n\n"
   }
}
#****************************************************************#


####################################################################
#  Proc�dure d'�valuation de la non-lin�arit� de la dispersion d'un spectre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-08-2006
# Date modification : 8-05-2007
# Arguments : nom_fichier_profil_de_raies ?liste_de_liste_intervalles_encadrant_raies?
####################################################################

proc spc_caloverif_08052007 { args } {
    global conf
    global audace

    if { [llength $args]<= 2 } {
        if { [llength $args]== 2 } {
            set spectre [ lindex $args 0 ]
            set raylist [ lindex $args 1 ]
        } elseif { [llength $args]==1 } {
            set spectre [ lindex $args 0 ]
            set raylist {{6531.781 6532.869 6532.359} {6543.4 6544.5 6543.907} {6548.1 6549.4 6548.622} {6552.1 6553.2 6552.629} {6571.7 6572.8 6572.072} {6574.3 6575.6 6574.847}}
        } else {
            ::console::affiche_erreur "Usage: spc_caloverif nom_fichier_profil_de_raies ?liste_de_liste_intervalles_encadrant_raies?\n\n"
            return ""
        }


        #--- D�termine le centre des raies mesur�es et calcul la difference avec celles duc atalogue :
        set chi2 0.
        set ecart_type 0.
        foreach ray $raylist {
            set xdeb [ lindex $ray 0 ]
            set xfin [ lindex $ray 1 ]
            set lambda_cat [ lindex $ray 2 ]
            #set lambda_mes [ spc_centergaussl $spectre $xdeb $xfin e ]
            set lambda_mes [ spc_centergravl $spectre $xdeb $xfin ]
            set ldiff [ expr $lambda_mes-$lambda_cat ]
            lappend results " [ list $lambda_cat $lambda_mes $ldiff ] \n"
            #set chi2 [ expr $chi2+pow($ldiff,2)/$lambda_cat ]
            set ecart_type [ expr $ecart_type+pow($ldiff,2) ]
        }


        #--- Calcul du RMS et ecart-type :
        set nbraies [ llength $raylist ]
        buf$audace(bufNo) load "$audace(rep_images)/$spectre"
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        set chi2 [ expr $ecart_type/($nbraies*pow($cdelt1,2)) ]
        set rms [ expr $cdelt1*sqrt($chi2) ]
        set ecart_type [ expr sqrt($ecart_type)/$nbraies ]


        #--- Affichage des r�sultats :
        ::console::affiche_resultat "Liste r�sultats (Lambda_cat Lambda_mes Diff) :\n $results\n"
        ::console::affiche_resultat "Sigma=$ecart_type A\nChi2=$chi2\nRMS=$rms A\n"
    } else {
        ::console::affiche_erreur "Usage: spc_caloverif nom_fichier_profil_de_raies ?liste_de_liste_intervalles_encadrant_raies?\n\n"
    }
}
#****************************************************************#

}
