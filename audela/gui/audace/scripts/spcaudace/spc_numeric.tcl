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
#  Procedure de détermination de la valeur maximum contenue dans une liste
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
# Calcul les coéfficients du polynôme interpolateur de Lagrange de degré 2
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005
# Arguments : 3 couples (x,y)
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
# Calcul la valeur du polynôme interpolateur de Lagrange de degré 3 au point x
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-02-2006
# Date modification : 25-02-2006
# Arguments : 4 couples (x,y) et x
####################################################################

proc bm_pil3c { { x0 ""} { y0 ""} { x1 ""} { y1 ""} { x2 ""} { y2 ""} { x3 ""} { y3 ""} { x ""}} {

    set y [ expr $y0*($x-$x1)*($x-$x2)*($x-$x3)/(($x0-$x1)*($x0-$x2)*($x0-$x3))+$y1*($x-$x0)*($x-$x2)*($x-$x3)/(($x1-$x0)*($x1-$x2)*($x1-$x3))+$y2*($x-$x0)*($x-$x1)*($x-$x3)/(($x2-$x0)*($x2-$x1)*($x2-$x3))+$y3*($x-$x0)*($x-$x1)*($x-$x2)/(($x3-$x0)*($x3-$x1)*($x3-$x2)) ]

    return $y
}
#****************************************************************#

####################################################################
#  Procedure d'ajustement d'un nuage de points
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : fichier .fit du profil de raie, erreur
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
	#--- Meth1
	::plotxy::clf
	::plotxy::plot $abscisses $yadj r 1
	::plotxy::hold on
	::plotxy::plot $abscisses $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	#::plotxy::xlabel "x"
	#::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 2"

	#--- Meth2
	set flaga 0
	if { $flaga == 1} {
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
	}
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
# Date creation : 15-12-2005
# Date modification : 26-05-2005
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg2 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg2 { args } {
    global conf
    global audace

    if {[llength $args] == 3} {
	set abscisses [lindex $args 0]
	set ordonnees [lindex $args 1]
	set erreur [lindex $args 2]
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
	::plotxy::plot $abscisses $yadj

	set coefs [ list $a $b $c ]
	set adj_vals [list $coefs $abscisses $yadj]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg2 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
    }
}
#****************************************************************#


#****************************************************************#
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
#****************************************************************#


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
#  Procédure d'ajustement d'un nuage de points.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-12-2005
# Date modification : 20-12-2005
# Arguments : fichier .fit du profil de raie, erreur
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

	#--- Affinement de l'ajustement : enlève les valeurs abérantes de la différence et ajoute la différence au continuum
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
#  Procedure de linératisation par spline.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 28-03-2006
# Arguments : liste abscisses et liste ordonnées à rééchantillonner, liste absisses modèle d'échantilonnage, (o/n) représentation graphique
# Bug : a la premiere execution "# x vector "x" must be monotonically increasing"
####################################################################

proc spc_spline { args } {
    global conf
    global audace

    if {[llength $args] == 4} {
	#set fichier [ file rootname [ lindex $args 0 ] ]
	#set fichier_abscisses [ lindex $args 1 ]
	#set contenu [ spc_fits2data $fichier ]
	set abscisses [ lindex $args 0 ]
	set ordonnees [ lindex $args 1 ]
	set nabscisses [ lindex $args 2 ]
	set gflag [ lindex $args 3 ]
	set len [llength $ordonnees]
	set nlen [ llength $nabscisses ]

	#--- Une liste commence à 0 ; Un vecteur fits commence à 1
	blt::vector x($len) y($len) 
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses $i]
	    set y($i-1) [lindex $ordonnees $i]
	}
	x sort y

	#--- Création des abscisses des coordonnees interpolées
	blt::vector sx($nlen)
	for {set i 1} {$i <= $nlen} {incr i} { 
	    set sx($i-1) [lindex $nabscisses $i]
	}
	
	#--- Spline ---------------------------------------#
	blt::vector sy($len)
	# blt::spline natural x y sx sy
	# The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
	#blt::spline quadratic x y sx sy
	blt::spline natural x y sx sy

	#--- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
	for {set i 1} {$i <= $nlen} {incr i} { 
	    lappend nordonnees $sy($i-1)
	}
	set ncoordonnees [ list $nabscisses $nordonnees ]
	# ::console::affiche_resultat "Exportation au format fits des données interpolées sous ${fichier}_ech\n"
	# spc_data2fits ${fichier}_ech $ncoordonnees float

	#--- Affichage
	if { [ string compare $gflag "o" ] == 0 } {
	    #--- Meth1    
	    ::plotxy::plot $nabscisses $nordonnees
	    ::plotxy::plotbackground #FFFFFF

	    set flaga 0
	    if { $flaga == 1} {
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
	    }
	}

	return $ncoordonnees
    } else {
	::console::affiche_erreur "Usage: spc_spline absisses ordonnées abscisses_modèles o/n représentation graphique\n\n"
    }
}
#****************************************************************#


####################################################################
#  Procédure de construction d'une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-04-2006
# Date modification : 18-04-2006
# Arguments : nom du fichier de sortie
####################################################################

proc bm_gaussienne { args } {
    global conf
    global audace
    set len 100
    #set imax 10.0
    #set xm 50
    #set sigma 5

    if {[llength $args] == 4} {
	set filename [ lindex $args 0 ]
	set imax [ lindex $args 1 ]
	set xm [ lindex $args 2 ]
	set sigma [ lindex $args 3 ]

	buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0
	#-- Pas
	buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "" ""]
	#-- Longueur d'onde de départ
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	#-- Dispersion
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]

	for {set x 1} {$x <= $len} {incr x} {
	    #set y [ expr $imax*exp(-1.0*($x-$xm)^2/$sigma^2) ]
	    set y [ expr $imax*exp(-1.0*(($x-$xm)*($x-$xm))/(2.0*$sigma*$sigma)) ]
	    #set deltax2 [ expr ($x-$xm)*($x-$xm) ]
	    buf$audace(bufNo) setpix [list [expr $x] 1] $y
	    #::console::affiche_resultat "y=$y\n"
	}
	
	#--- Sauvegarde du profil calibré
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/$filename"
	::console::affiche_resultat "Courbe gaussienne sauvée sous $filename\n"
    } else {
	::console::affiche_erreur "Usage: bm_gaussienne nom_fichier_fit_sortie imax xmoy sigma.\n\n"
    }
}