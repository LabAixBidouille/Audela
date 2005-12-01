
# source $audace(rep_scripts)/spcaudace/spc_calibrage.tcl
# fits2dat lmachholz_centre.fit
# buf1 load lmachholz_centre.fit


####################################################################
#  Procedure de calcul de dispersion moyenne
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2005
# Date modification : 27-02-2005
# Arguments : liste des instensites, naxis1
####################################################################

proc dispersion_moy { { intensites ""} { naxis1 ""} } {
   # Dispersion du spectre : =1 si profil non �talonn�
   set l1 [lindex $intensites 1]
   set l2 [lindex $intensites [expr int($naxis1/10)]]
   set l3 [lindex $intensites [expr int(2*$naxis1/10)]]
   set l4 [lindex $intensites [expr int(3*$naxis1/10)]]
   set dl1 [expr ($l2-$l1)/(int($naxis1/10)-1)]
   set dl2 [expr ($l4-$l3)/(int($naxis1/10)-1)]
   set xincr [expr 0.5*($dl2+$dl1)]
   return $xincr
}



####################################################################
#  Procedure de conversion d'�talonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie spatial
####################################################################

proc pil2 { { x1 ""} { y1 ""} { x2 ""} { y2 ""} { x3 ""} { y3 ""} } {

    # Calcul les coefficients du polyn�me interpolateur de Lagrange : lambda=a*x^2+b*x+c
    set a [expr $y1/(($x1-$x2)*($x1-$x2))+$y2/(($x2-$x1)*($x2-$x3))+$y3/(($x3-$x1)*($x3-$x2))]
    set b [expr -$y1*($x3+$x2)/(($x1-$x2)*($x1-$x2))-$y2*($x3+$x1)/(($x2-$x1)*($x2-$x3))-$y3*($x1+$x2)/(($x3-$x1)*($x3-$x2))]
    set c [expr $y1*$x3*$x2/(($x1-$x2)*($x1-$x2))+$y2*$x3*$x1/(($x2-$x1)*($x2-$x3))+$y3*$x1*$x2/(($x3-$x1)*($x3-$x2))]

    set listecoefs [list $a $b $c]
    return $listecoefs
}




####################################################################
#  Procedure de conversion d'�talonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie spatial
####################################################################

proc calibre2 { {filespc ""} {pixel1 ""} {lambda1 ""} {pixel2 ""} {lambda2 ""} } {

    global conf
    global audace
    global profilspc
    global captionspc

    # R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    set spectre [ openspcncal ${filespc} ]
    set intensites [lindex $spectre 0]
    set naxis1 [lindex $spectre 1]

    # Calcul des parametres spectraux
    set deltax [expr $pixel2-$pixel1]
    set dispersion [expr ($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion Angstroms/Pixel\n"
    set lambda0 [expr $lambda1-$dispersion*$pixel1]
    set xcentre [expr int($lambda0+0.5*($dispersion*$naxis1)-1)]

    # Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    # Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" "$lambda0" int "" "Angstrom"]
    # Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" "$dispersion" float "" "Angtrom/pixel"]
    # Longueur d'onde centrale
    buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" int "" "Angstrom"]
    # Type de dispersion : LINEAR...
    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]

    buf$audace(bufNo) save $audace(rep_images)/l${filespc}
    ::console::affiche_resultat "Spectre �talonn� souv� sous l${filespc}.\n"
}
#****************************************************************#



####################################################################
#  Procedure de conversion d'�talonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie spatial
####################################################################

proc calibre3 { {filespc ""} {x1 ""} {lambda1 ""} {x2 ""} {lambda2 ""}  {x3 ""} {lambda3 ""} } {

    global conf
    global audace
    global profilspc
    global captionspc

    # R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    set spectre [ openspcncal ${filespc} ]
    set intensites [lindex $spectre 0]
    set naxis1 [lindex $spectre 1]

    # Calcul des parametres spectraux
    set deltax [expr $x2-$x1]
    set dispersion [expr ($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion lin�aire vaut : $dispersion Angstroms/Pixel.\n"
    set lambda_0 [expr $lambda1-$dispersion*$x1]

    # Calcul les coefficients du polyn�me interpolateur de Lagrange : lambda=a*x^2+b*x+c
    set a [expr $lambda1/(($x1-$x2)*($x1-$x2))+$lambda2/(($x2-$x1)*($x2-$x3))+$lambda3/(($x3-$x1)*($x3-$x2))]
    set b [expr -$lambda1*($x3+$x2)/(($x1-$x2)*($x1-$x2))-$lambda2*($x3+$x1)/(($x2-$x1)*($x2-$x3))-$lambda3*($x1+$x2)/(($x3-$x1)*($x3-$x2))]
    set c [expr $lambda1*$x3*$x2/(($x1-$x2)*($x1-$x2))+$lambda2*$x3*$x1/(($x2-$x1)*($x2-$x3))+$lambda3*$x1*$x2/(($x3-$x1)*($x3-$x2))]
    ::console::affiche_resultat "$a, $b et $c\n"

    # set dispersionm [expr (sqrt(abs($b^2-4*$a*$c)))/$a]
    #set dispersionm [expr abs([ dispersion_moy $intensites $naxis1 ]) ]
    # Calcul les valeurs des longueurs d'ondes associees a chaque pixel
    set len [expr $naxis1-2]
    for {set x 1} {$x<=$len} {incr x} {
	lappend lambdas [expr $a*$x*$x+$b*$x+$c]
    }

    # Affichage du polynome :
    set file_id [open "$audace(rep_images)/polynome.txt" w+]
    for {set x 1} {$x<=$len} {incr x} {
	set lamb [lindex $lambdas [expr $x-1]]
	puts $file_id "$x $lamb"
    }
    close $file_id

    # Calcul la disersion moyenne en faisant la moyenne des ecarts entre les lambdas : GOOD ! 
    set dispersionm 0
    for {set k 0} {$k<[expr $len-1]} {incr k} {
	set l1 [lindex $lambdas $k]
	set l2 [lindex $lambdas [expr $k+1]]
	set dispersionm [expr 0.5*($dispersionm+0.5*($l2-$l1))]
    }
    ::console::affiche_resultat "La dispersion non lin�aire vaut : $dispersionm Angstroms/Pixel.\n"

    set lambda0 [expr $a+$b+$c]
    set lcentre [expr int($lambda0+0.5*($dispersionm*$naxis1)-1)]

    # Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    # Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" "$lambda0" int "" "Angstrom"]
    # Dispersion
    #buf$audace(bufNo) setkwd [list "CDELT1" "$dispersionm" float "" "Angtrom/pixel"]
    buf$audace(bufNo) setkwd [list "CDELT1" "$dispersion" float "" "Angtrom/pixel"]
    # Longueur d'onde centrale
    buf$audace(bufNo) setkwd [list "CRPIX1" "$lcentre" int "" "Angstrom"]
    # Type de dispersion : LINEAR...
    buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]

    buf$audace(bufNo) save $audace(rep_images)/l${filespc}
    ::console::affiche_resultat "Spectre �talonn� souv� sous l${filespc}.\n"
}
#****************************************************************************


####################################################################
#  Procedure d'�talonnage en longueur d'onde � partir de la dispersion
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-08-2005
# Date modification : 16-08-2005
# Arguments : profil de raie.fit, pixel, lambda, dispersion
####################################################################

proc calibred { {filespc ""} {pixel1 ""} {lambda1 ""} {dispersion ""} } {

    global conf
    global audace
    global profilspc
    global captionspc

    # R�cup�re la liste "spectre" contenant 2 listes : pixels et intensites
    set spectre [ openspcncal ${filespc} ]
    set intensites [lindex $spectre 0]
    set naxis1 [lindex $spectre 1]

    # Calcul des parametres spectraux
    set lambda0 [expr $lambda1-$dispersion*$pixel1]
    set xcentre [expr int($lambda0+0.5*($dispersion*$naxis1)-1)]

    # Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    # Longueur d'onde de d�part
    buf$audace(bufNo) setkwd [list "CRVAL1" "$lambda0" int "" "Angstrom"]
    # Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" "$dispersion" float "" "Angtrom/pixel"]
    # Longueur d'onde centrale
    buf$audace(bufNo) setkwd [list "CRPIX1" "$xcentre" int "" "Angstrom"]
    # Type de dispersion : LINEAR...
    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]

    #buf$audace(bufNo) save $audace(rep_images)/l${filespc}
    buf$audace(bufNo) save l${filespc}
    ::console::affiche_resultat "Spectre �talonn� souv� sous l${filespc}\n"
}
#****************************************************************#


##########################################################
# Calcul la r�ponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 02-09-2005
# Arguments : fichier .fit du profil de raie, profil de raie de r�f�rence
# Remarque : effectue le d�coupage, r��chantillonnage puis la division 
##########################################################

proc spcrinstrum { args } {

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
       set ${fichier_ref}_sel [ spcselect $fichier_ref $xdeb1 $xfin1 ]
       # R��chantillonnage du spectre de r�f�rence : c'est un choix.
       ## Que disp1 < disp2 ou disp2 < disp1, la dispersion finale sera disp1
       set ${fichier_ref}_sel_rech [ spcechant ${fichier_ref}_sel $disp1 ]
       file delete ${fichier_ref}_sel$conf(extension,defaut)
       # Calcul la r�ponse intrumentale : RP=spectre_mesure/spectre_ref
       buf$audace(bufNo) load $fichier_mes
       buf$audace(bufNo) div ${fichier_ref}_sel_rech 1.0
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save reponse_intrumentale
       ::console::affiche_resultat "S�lection sauv�e sous ${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spcrinstrum fichier .fit du profil de raie, profil de raie de r�f�rence\n\n"
   }
}
##########################################################






