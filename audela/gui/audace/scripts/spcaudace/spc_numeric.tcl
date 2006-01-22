# Fonctions de calculs numeriques : interpolation, ajustement...
# source $audace(rep_scripts)/spcaudace/spc_numeric.tcl

####################################################################
#  Procedure de détermination du maximum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 11-12-2005
# Arguments : valeur 1, valeur 2
####################################################################
proc bm_max { args } {

    if { [llength $args] == 2 } {
	set a [lindex $args 0]
	set b [lindex $args 1]

	if { $a<$b } {
	    return $b
	} else {
	    return $a
	}
    } else {
	::console::affiche_erreur "Usage: bm_max valeur_1 valeur_2\n\n"
    }
}
#****************************************************************#

####################################################################
#  Procedure de détermination du maximum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 11-12-2005
# Arguments : liste de valeurs
####################################################################
proc bm_lmax { args } {

    if { [llength $args] == 1 } {
	set liste [lindex $args 0]
	lsort $liste
	set len [llength $liste]
	return [lindex $liste $len]
    } else {
	::console::affiche_erreur "Usage: bm_lmax liste_valeurs\n\n"
    }
}
#****************************************************************#

	
####################################################################
#  Procedure de conversion d'étalonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : fichier .fit du profil de raie spatial
####################################################################

proc bm_pil2 { { x1 ""} { y1 ""} { x2 ""} { y2 ""} { x3 ""} { y3 ""} } {

    # Calcul les coefficients du polynôme interpolateur de Lagrange : lambda=a*x^2+b*x+c
    set a [expr $y1/(($x1-$x2)*($x1-$x2))+$y2/(($x2-$x1)*($x2-$x3))+$y3/(($x3-$x1)*($x3-$x2))]
    set b [expr -$y1*($x3+$x2)/(($x1-$x2)*($x1-$x2))-$y2*($x3+$x1)/(($x2-$x1)*($x2-$x3))-$y3*($x1+$x2)/(($x3-$x1)*($x3-$x2))]
    set c [expr $y1*$x3*$x2/(($x1-$x2)*($x1-$x2))+$y2*$x3*$x1/(($x2-$x1)*($x2-$x3))+$y3*$x1*$x2/(($x3-$x1)*($x3-$x2))]

    set listecoefs [list $a $b $c]
    return $listecoefs
}
#****************************************************************#


####################################################################
#  Procedure d'ajustement d'un nuage de points
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : fichier .fit du profil de raie erreur
####################################################################

proc spc_ajust { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set contenu [spc_openspcfits $filenamespc]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
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
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i 
	} 
	# - calcul de l'ajustement 
	set result [gsl_mfitmultilin $ordonnees $X $erreurs] 
	# - extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Crée les vecteur à tracer
	blt::vector x($len) y($len) yn($len)
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    #lappend yadj $yn($i-1)
	    lappend listeyn $yn($i-1)
	}
	#set yadj $listeyn

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	for {set j 0} {$j<$len} {incr j} {
	    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	}


	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	#set yadj ""
	#for {set j 0} {$j<$len} {incr j} {
	#    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	#}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue 
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red 

	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}

	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}


proc spc_ajust_ok_mais_sans_inversion { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set contenu [spc_openspcfits $filenamespc]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
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
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i 
	} 
	# - calcul de l'ajustement 
	set result [gsl_mfitmultilin $ordonnees $X $erreurs] 
	# - extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Crée les vecteur à tracer
	blt::vector x($len) y($len) yn($len)
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    lappend yadj $yn($i-1)
	}

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	#set yadj ""
	#for {set j 0} {$j<$len} {incr j} {
	#    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	#}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue 
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red 

	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}

	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}


proc spc_ajust_051215a { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set contenu [spc_openspcfits $filenamespc]
	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement
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
	    #lappend ligne_i [expr $xi*$xi*$xi]
	    lappend X $ligne_i 
	} 
	# - calcul de l'ajustement 
	set result [gsl_mfitmultilin $ordonnees $X $erreurs] 
	# - extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"

	#--- Crée les vecteur à tracer
	blt::vector x($len) y($len) yn($len)
	set listeyn ""
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses [expr $i-1]]
	    set y($i-1) [lindex $ordonnees [expr $i-1]]
	    set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)]
	    #set yn($i-1) [expr $a+$b*$x($i-1)+$c*$x($i-1)*$x($i-1)+$d*$x($i-1)*$x($i-1)*$x($i-1)]
	    lappend listeyn $yn($i-1)
	}
	#set yadj $listeyn

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	set yadj ""
	for {set j 0} {$j<$len} {incr j} {
	    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue 
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red 

	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}

	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}
#****************************************************************#


####################################################################
#  Procedure d'ajustement d'un nuage de points
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-12-2005
# Date modification : 20-12-2005
# Arguments : fichier .fit du profil de raie erreur
####################################################################

proc spc_ajustfin { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set fichier [ lindex $args 0 ]
	set erreur [ lindex $args 1 ]
	set coordonnees_cont [spc_adjust $fichier 1]
	set abscisses_cont [lindex $coordonnees_cont 0]
	set ordonnees_cont [lindex $coordonnees_cont 1]
	set len [llength $ordonnees_cont]

	#--- Calcul la difference entre le continuum et le profil a ajuster (normaliser)
	set nom_fichier [ file rootname $fichier ]
	set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees "double" ]
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	buf$audace(bufNo) sub $audace(rep_images)/$nom_continuum 0
	buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_diffconti

	#--- Affinement de l'ajustement : enleve les valeur aberantes de la difference et ajoute la difference au continuum
	set coords_diffconti [spc_fits2data ${nom_fichier}_diffconti]
	set ordonnees [lindex [spc_fits2data $fichier] 1]
	set abs_diffconti [lindex $coords_diffconti 0]
	set ord_diffconti [lindex $coords_diffconti 1]
	for {set k 0} {$k<$len} {incr k} {
	    set y_dc [lindex $ord_diffconti $k]
	    set y [lindex $ordonnees $k]
	    #if {$y_dc == $y} { lappend y_aspline $y }
	    if {$y_dc == $y} { lappend yadj $y }
	}


	set flag_o 0
	if {$flag_o /= 0} {
	#--- Affichage du graphe
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [lsort $yadj]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue 
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red 
	}
	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}

	set adj_vals [list $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajust fichier_profil.fit erreur (1)\n\n"
    }
}



####################################################################
#  Procedure de lineratisation par spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 11-12-2005
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_spline { args } {
    global conf
    global audace

    if {[llength $args] == 1} {
	#set filenamespc [ lindex $args 0 ]
	#set contenu [spc_openspcfits $filenamespc]
	set contenu [ lindex $args 0 ]

	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Une liste commence à 0 ; Un vecteur fits commence à 1
	blt::vector x($len) y($len) 
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses $i]
	    set y($i-1) [lindex $ordonnees $i]
	}

	#--- Spline
	x sort y
	x populate sx $len
	blt::vector sy($len)
	blt::spline natural x y sx sy
	#blt::spline quadratic x y sx sy

	#--- Affichage
	#destroy .testblt
	#toplevel .testblt
	#blt::graph .testblt.g 
	#pack .testblt.g -in .testblt
	#.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
	#-- Meth2
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	set ly [lsort $ordonnees]
	.testblt.g legend configure -position bottom
	.testblt.g axis configure x -min [lindex $abscisses 0] -max [lindex $abscisses $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue 
	.testblt.g element create spline -symbol none -x sx -y sy -color red 
	#blt::table . .testblt

    } else {
	::console::affiche_erreur "Usage: spc_spline fichier_profil.fit\n\n"
    }
}
#****************************************************************#

