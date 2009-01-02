# Fonctions de calculs numeriques : interpolation, ajustement...
# source $audace(rep_scripts)/spcaudace/spc_numeric.tcl

# Mise a jour $Id: spc_numeric.tcl,v 1.3 2009-01-02 21:23:29 bmauclaire Exp $



###################################################################
# Procedure de determination du minimum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 01-06-08
# Date modification : 01-06-08
# Arguments : valeur 1, valeur 2
#####################################################################

proc spc_resample { args } {


   if { [ llength $args ] == 3 } {
      set xvals [ lindex $args 0 ]
      set yvals [ lindex $args 1 ]
      set nxvals [ lindex $args 2 ]

      #--- Recupere les informations sur l'echantillon :
      set len [ llength $xvals ]
      set x_0 [ lindex $xvals 0 ]

      #--- Calcul
      set new_xvals [ list ]
      for {set i 0} {$i<$len} {incr i} {
         lappend new_xvals [ expr $pas*$i+$lambda_deb ]
      }

      #-- Rééchantillonne par spline les intensités sur la nouvelle échelle en longueur d'onde :
      #-- Verifier les valeurs des lambdas pour eviter un "monoticaly error de BLT".
      set new_intensities [ lindex  [ spc_spline $xvals $yvals $nxvals n ] 1 ]
      return $new_coordonnees
   } else {

   }
}

#****************************************************************#


###################################################################
#  Procedure de determination du minimum entre 2 valeurs
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 01-06-08
# Date modification : 01-06-08
# Arguments : valeur 1, valeur 2
#####################################################################
proc bm_min { args } {

    if { [llength $args] == 2 } {
	set a [lindex $args 0]
	set b [lindex $args 1]

	if { $a>$b } {
	    return $b
	} else {
	    return $a
	}
    } else {
	::console::affiche_erreur "Usage: bm_min valeur_1 valeur_2\n\n"
    }
}
#****************************************************************#


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
# Calcul la partie fractionnelle d'un reel
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 19-09-2006
# Date modification : 19-06-2006
# Arguments : nombre
####################################################################
proc bm_frac { args } {

    if { [llength $args] == 1 } {
	set nombre [lindex $args 0]
	return [ expr $nombre-int($nombre) ]
    } else {
	::console::affiche_erreur "Usage: bm_frac nombre_reel\n\n"
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
# Procedure d'ajustement d'un nuage de points
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
#  Procedure d'ajustement d'un nuage de points par une fonction affine (hp : nombre reels longs)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 28-12-2008
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg1 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg1hp { args } {
    global conf
    global audace

    if {[llength $args] == 3} {
       set abscisses_orig [lindex $args 0]
       set ordonnees [lindex $args 1]
       set erreur [lindex $args 2]
       set len [llength $ordonnees]
       set n [ llength $abscisses_orig ]
       set abscisses_rangees [ lsort -real -increasing $abscisses_orig ]
       set abs_min [ lindex $abscisses_rangees 0 ]
       set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
       ::console::affiche_resultat "$abs_min $abs_max\n"

       #--- Changement de variable (preconditionnement du systeme lineaire) :
       set aa [ expr 2. / ($abs_max - $abs_min ) ]
       #::console::affiche_resultat "aa= $aa\n"
       set bb [ expr 1. - $aa * $abs_max ]
       #::console::affiche_resultat "bb= $bb\n"
       set abscisses [ list ]
       for { set i 0 } { $i<$n } {incr i} {
          set xi [ expr $aa * [ lindex $abscisses_orig $i ] +$bb ]
          lappend abscisses $xi
       }

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
	    lappend X $ligne_i 
	} 
	# - calcul de l'ajustement 
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ] 
	# - extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a0 [lindex $coeffs 0]
	set b0 [lindex $coeffs 1]
       #--- Retour aux variables d'origine :
       set a [ expr $a0 + $b0 * $bb ]
       set b [ expr $aa * $b0 ]
	::console::affiche_resultat "Coefficients : $a+$b*x\nChi2=$chi2, Covar=$covar\n"

	set coefs [ list $a $b ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg1hp liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
    }
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par une fonction affine
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 01-10-2006
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg1 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg1 { args } {
    global conf
    global audace

    if {[llength $args] == 3} {
       set abscisses [lindex $args 0]
       set ordonnees [lindex $args 1]
       set erreur [lindex $args 2]

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
	    lappend X $ligne_i 
	} 
	# - calcul de l'ajustement 
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ] 
	# - extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	::console::affiche_resultat "Coefficients : $a+$b*x\nChi2=$chi2, Covar=$covar\n"

	set coefs [ list $a $b ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg1 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
    }
}
#****************************************************************#


####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005/14-09-2008-Lailly
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg2 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg2 { args } {
   global conf
   global audace

   if {[llength $args] == 3} {
      set abscisses_orig [lindex $args 0]
      set ordonnees [lindex $args 1]
      set erreur [lindex $args 2]
      set len [llength $ordonnees]
      set n [llength $abscisses_orig]
      set abscisses_rangees [ lsort -real -increasing $abscisses_orig ]
      set abs_min [ lindex $abscisses_rangees 0 ]
      set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
      ::console::affiche_resultat "$abs_min $abs_max\n"

      #--- Changement de variable (preconditionnement du systeme lineaire) :
      set aa [ expr 2. / ($abs_max - $abs_min ) ]
      #::console::affiche_resultat "aa= $aa\n"
      set bb [ expr 1. - $aa * $abs_max ]
      #::console::affiche_resultat "bb= $bb\n"
      set abscisses [ list ]
      for { set i 0 } { $i<$n } {incr i} {
	 set xi [ expr $aa * [ lindex $abscisses_orig $i ] +$bb ]
	 lappend abscisses $xi
      }


      #--- Calcul des coefficients du polynôme d'ajustement :
      #-- Calcul de la matrice X :
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
      #-- Calcul de l'ajustement :
      set result [ gsl_mfitmultilin $ordonnees $X $erreurs ] 
      #-- Extrait le resultat :
      set coeffs [lindex $result 0] 
      set chi2 [lindex $result 1] 
      set covar [lindex $result 2]
      ::console::affiche_resultat "Chi2=$chi2, Covar=$covar\n"
      set a0 [lindex $coeffs 0]
      set b0 [lindex $coeffs 1]
      set c0 [lindex $coeffs 2]

      #--- Retour aux variables d'origine :
      set a [ expr $a0 + $b0 * $bb + $c0 * $bb* $bb ]
      set b [ expr $aa * ( $b0 + 2. * $c0 * $bb ) ]
      set c [ expr $aa * $aa * $c0 ]
      ::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\n"
      set coefs [ list $a $b $c ]
	

      #-----------------------------------------------------------------------#
      #--- Crée les vecteur à tracer
      set flag 0
      if { $flag==1 } {
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
      }
      #-----------------------------------------------------------------------#

      #--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
      #set yadj ""
      #for {set j 0} {$j<$len} {incr j} {
      #    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
      #}
      ##for {set j $len} {$j>0} {incr j -1} {
      ##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
      ##}

      #--- Affichage du graphe
      #  ::plotxy::plot $abscisses $yadj

      set coefs [ list $a $b $c ]
      # set adj_vals [list $coefs $abscisses $yadj]
      set adj_vals [ list $coefs $chi2 $covar ]
      #set adj_vals [ list $coefs ]
      return $adj_vals
   } else {
      ::console::affiche_erreur "Usage: spc_ajustdeg2 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
   }
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 3
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005/14-09-2008-Lailly
# Arguments : liste abscisses, liste ordonnees, erreur
# Condition : il faut 4 couples de points !
####################################################################
#spc_ajustdeg3 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg3 { args } {
   global conf
   global audace

   if {[llength $args] == 3} {
      set abscisses_orig [lindex $args 0]
      set ordonnees [lindex $args 1]
      set erreur [lindex $args 2]
      set n [llength $abscisses_orig]
      set len [llength $ordonnees]
      set abscisses_rangees [ lsort -real -increasing $abscisses_orig ]
      set abs_min [ lindex $abscisses_rangees 0 ]
      set abs_max [ lindex $abscisses_rangees [ expr $n -1 ] ]
      ::console::affiche_resultat "$abs_min $abs_max\n"

      #--- Changement de variable (preconditionnement du systeme lineaire) :
      set aa [ expr 2. / ($abs_max - $abs_min ) ]
      #::console::affiche_resultat "aa= $aa\n"
      set bb [ expr 1. - $aa * $abs_max ]
      #::console::affiche_resultat "bb= $bb\n"
      set abscisses [ list ]
      for { set i 0 } { $i<$n } {incr i} {
	 set xi [ expr $aa * [ lindex $abscisses_orig $i ] +$bb ]
	 lappend abscisses $xi
      }

      #--- Calcul des coefficients du polynôme d'ajustement :
      #-- Calcul de la matrice X : calcul les monônes correspondant aux différents degrés à l'abscisse xi
      set x ""
      set X "" 
      for {set i 0} {$i<$n} {incr i} { 
	 set xi [lindex $abscisses $i] 
         set ligne_i 1
	 lappend erreurs $erreur
	 lappend ligne_i $xi 
	 lappend ligne_i [expr $xi*$xi]
	 lappend ligne_i [expr $xi*$xi*$xi]
	 lappend X $ligne_i 
      } 
      #-- Calcul de l'ajustement :
      set result [gsl_mfitmultilin $ordonnees $X $erreurs] 
      #-- Extrait le resultat :
      set coeffs [lindex $result 0] 
      set chi2 [lindex $result 1] 
      set covar [lindex $result 2]
      set a0 [lindex $coeffs 0]
      set b0 [lindex $coeffs 1]
      set c0 [lindex $coeffs 2]
      set d0 [lindex $coeffs 3]
      ::console::affiche_resultat "Chi2=$chi2, Covar=$covar\n"

      #--- Retour aux variables d'origine :
      set a [ expr $a0 + $b0 * $bb + $c0 * $bb* $bb + $d0 * $bb* $bb * $bb ]
      set b [ expr $aa * ( $b0 + 2. * $c0 * $bb + 3. * $d0 * $bb *$bb ) ]
      set c [ expr $aa * $aa * ($c0 + 3. * $d0 * $bb) ]
      set d [ expr $d0 * $aa * $aa *$aa ]
	
      ::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2+$d*x^3\n"
      set coefs [ list $a $b $c $d ]
      # set adj_vals [list $coefs $abscisses $yadj]
      set adj_vals [ list $coefs $chi2 $covar ]
      #set adj_vals [ list $coefs ]
      return $adj_vals
   } else {
      ::console::affiche_erreur "Usage: spc_ajustdeg3 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
   }
}
#****************************************************************#



####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005
# Arguments : liste abscisses, liste ordonnees, erreur
####################################################################
#spc_ajustdeg2 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg2v1 { args } {
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
	set result [ gsl_mfitmultilin $ordonnees $X $erreurs ] 
	# - extrait le resultat 
	set coeffs [lindex $result 0] 
	set chi2 [lindex $result 1] 
	set covar [lindex $result 2]

	set a [lindex $coeffs 0]
	set b [lindex $coeffs 1]
	set c [lindex $coeffs 2]
	#set d [lindex $coeffs 3]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2\nChi2=$chi2\n"

     #-----------------------------------------------------------------------#
	#--- Crée les vecteur à tracer
	set flag 0
	if { $flag==1 } {
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
     }
     #-----------------------------------------------------------------------#

	#--- Remet les valeurs calculees de listeyn dans l'ordre des abscisses (inverse)
	#set yadj ""
	#for {set j 0} {$j<$len} {incr j} {
	#    lappend yadj [ lindex $listeyn [expr $len-$j-1] ]
	#}
	##for {set j $len} {$j>0} {incr j -1} {
	##    lappend yadj [ lindex $listeyn [expr $j-$len-1] ]
	##}

	#--- Affichage du graphe
	#  ::plotxy::plot $abscisses $yadj

	set coefs [ list $a $b $c ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg2 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
    }
}
#****************************************************************#




####################################################################
#  Procedure d'ajustement d'un nuage de points par un polynôme de degré 3
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 26-05-2005
# Arguments : liste abscisses, liste ordonnees, erreur
# Condition : il faut 4 couples de points !
####################################################################
#spc_ajustdeg3 {218.67 127.32 16.67} {211 208 210.1} 1
#{218.67 127.32 16.67} {211.022333817 208.007561837 210.100127057}

proc spc_ajustdeg3v1 { args } {
    global conf
    global audace

    if {[llength $args] == 3} {
	set abscisses [lindex $args 0]
	set ordonnees [lindex $args 1]
	set erreur [lindex $args 2]
	set len [llength $ordonnees]

	#--- Calcul des coefficients du polynôme d'ajustement :
	# - calcul de la matrice X : calcul les monônes correspondant aux différents degrés à l'abscisse xi
	set n [llength $abscisses]
       set lingne_i [ list ]
	#set X ""
       set X [ list ]
	for {set i 0} {$i<$n} {incr i} { 
	    set xi [lindex $abscisses $i] 
	    set ligne_i 1
	    lappend erreurs $erreur
	    lappend ligne_i $xi 
	    lappend ligne_i [expr $xi*$xi]
	    lappend ligne_i [expr $xi*$xi*$xi]
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
       set d [expr {double([lindex $coeffs 3])} ]
	::console::affiche_resultat "Coefficients : $a+$b*x+$c*x^2+$d*x^3\nChi2=$chi2, Covar=$covar\n"
  ::console::affiche_resultat "[ expr $d*1000000000000000000000000.0 ]\n"
	set coefs [ list $a $b $c $d ]
	# set adj_vals [list $coefs $abscisses $yadj]
	set adj_vals [ list $coefs $chi2 $covar ]
	#set adj_vals [ list $coefs ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustdeg3 liste_abscisses liste_ordonnees erreur (ex. 1)\n\n"
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

	#--- Extraction des données et 1ier ajustement :
	set coordonnees_cont [ spc_ajust $fichier 1 ]
	set abscisses_cont [ lindex $coordonnees_cont 0 ]
	set ordonnees_cont [ lindex $coordonnees_cont 1 ]
	set len [ llength $ordonnees_cont ]

	#--- Calcul la difference entre le continuum et le profil a ajuster (normaliser)
	set nom_fichier [ file rootname $fichier ]
	set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees_cont "double" ]
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	buf$audace(bufNo) sub $audace(rep_images)/$nom_continuum 0
	buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_diffconti

	#--- Affinement de l'ajustement : enlève les valeurs abérantes de la différence et ajoute la différence au continuum
	set coords_diffconti [ spc_fits2data ${nom_fichier}_diffconti ]
	set ordonnees [lindex [ spc_fits2data $fichier] 1 ]
	set abs_diffconti [ lindex $coords_diffconti 0 ]
	set ord_diffconti [ lindex $coords_diffconti 1 ]
	set yajuste [ list ]
	for {set k 0} {$k<$len} {incr k} {
	    set y_dc [ lindex $ord_diffconti $k ]
	    set y [ lindex $ordonnees $k ]
	    #if {$y_dc == $y} { lappend y_aspline $y }
	    if {$y_dc == $y} {
		lappend yajuste $y
	    } else {
		lappend yajuste [ lindex [ lindex $coordonnees_cont 1 ] $k ]
	    }
	}


	#--- Affichage du graphique :
	set flag_o 0
	if {$flag_o != 0} {
	destroy .testblt
	toplevel .testblt
	blt::graph .testblt.g
	pack .testblt.g -in .testblt
	.testblt.g legend configure -position bottom
	set ly [ lsort $yajuste ]
	#set ly [lsort $ordonnees]
	#set ymax [ bm_max [bm_lmax $ordonnees] [bm_lmax $yadj] ]
	.testblt.g axis configure x -min [lindex $abscissescont 0] -max [lindex $abscisses_cont $len]
	#.testblt.g axis configure y -min 1000 -max 5000
	##.testblt.g axis configure y -min 1000 -max [lindex $ly $len]
	.testblt.g axis configure y -min [lindex $ly 0] -max [lindex $ly $len]
	.testblt.g element create original -symbol none -x x -y y -color blue 
	.testblt.g element create interpolation_deg2 -symbol none -x x -y yn -color red 
	}

	::plotxy::clf
	::plotxy::plot $abscisses_cont $yajuste r 1
	::plotxy::hold on
	::plotxy::plot $abscisses_cont $ordonnees ob 0
	::plotxy::plotbackground #FFFFFF
	#::plotxy::xlabel "x"
	#::plotxy::ylabel "y"
	::plotxy::title "bleu : orginal ; rouge : interpolation deg 2"


	#--- Enregistrement des points du polynôme d'ajustement
	#set fileetalonnespc [ file rootname $filenamespc ]
	##set filename ${fileetalonnespc}_dat$extsp
	#set filename ${fileetalonnespc}$extsp
	#set file_id [open "$audace(rep_images)/$filename" w+]
	#for {set k 0} {$k<$naxis1} {incr k} {
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	#    puts $file_id "$lambda\t$intensite"
	#}

	set adj_vals [ list $abscisses_cont $yajuste ]
	return $adj_vals
    } else {
	::console::affiche_erreur "Usage: spc_ajustfin fichier_profil.fit erreur (1)\n\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calcul de la droite de régression linéaire par les moindres carrés
# http://www.bibmath.net/dico/index.php3?action=affiche&quoi=./r/reglin.html
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
# Exemple : spc_reglin {{0  0.1  0.4  1} {12 11 7 1}} doit trouver : -11.0699588477*x+11.9012345679 
####################################################################

proc spc_reglin { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	set len [ llength $valx ]

	#--- Calcul des termes intervenant dans les coéfficients :
	set somme_x 0
	set somme_y 0
	set somme_x2 0
	set somme_xy 0
	for {set i 0} { $i<$len } {incr i} {
	    set xi [ lindex $valx $i ]
	    set yi [ lindex $valy $i ]

	    set somme_x [ expr $somme_x+$xi ]
	    set somme_y [ expr $somme_y+$yi ]
	    set somme_x2 [ expr $somme_x2+$xi*$xi ]
	    set somme_xy [ expr $somme_xy+$xi*$yi ]
	}

	#--- Calcul des coéficients a et b :
	set a [ expr ($len*$somme_xy-$somme_x*$somme_y)/($len*$somme_x2-$somme_x*$somme_x) ]
	set b [ expr ($somme_y*$somme_x2-$somme_x*$somme_xy)/($len*$somme_x2-$somme_x*$somme_x) ]

	#--- Fin du script :
	::console::affiche_resultat "La droite de régression est : $a*x+$b\n"
	set coeffs [ list $a $b ]
	return $coeffs
    } else {
	::console::affiche_erreur "Usage: spc_reglin {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#



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

	#--- Nombre d'éléments : 
	set len [ llength $ordonnees ]
	set nlen [ llength $nabscisses ]

	if { 1==0 } {
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
    }

	blt::vector create x
	x set $abscisses
	blt::vector create y
	y set $ordonnees
	blt::vector create sx
	sx set $nabscisses	
	blt::vector create sy($nlen)

	# blt::spline natural x y sx sy
	# The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
	#blt::spline quadratic x y sx sy
	blt::spline natural x y sx sy

	#--- Exportation des vecteurs coordonnées interpolées en liste puis fichier dat
	for {set i 0} {$i<$nlen} {incr i} { 
	    lappend nordonnees $sy($i)
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
	::console::affiche_erreur "Usage: spc_spline absisses ordonnées abscisses_modèles représentation graphique (o/n)\n\n"
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

proc spc_gaussienne { args } {
    global conf
    global audace
    set len 100
    #set imax 10.0
    #set xm 50
    #set sigma 5

   if { [ llength $args ] == 5 } {
      set filename [ file rootname [ lindex $args 0 ] ]
      set lambda_c [ lindex $args 1 ]
      set imax [ lindex $args 2 ]
      set lfwhm [ lindex $args 3 ]
      set typeline [ lindex $args 4 ]
      #--- Determine la valeur du continuum :
      set icont [ spc_icontinuum $filename ]
   } elseif { [ llength $args ] == 6 } {
      set filename [ file rootname [ lindex $args 0 ] ]
      set lambda_c [ lindex $args 1 ]
      set imax [ lindex $args 2 ]
      set lfwhm [ lindex $args 3 ]
      set typeline [ lindex $args 4 ]
      set icont [ lindex $args 5 ]
   } else {
      ::console::affiche_erreur "Usage: spc_gaussienne nom_fichier_fit_modèle lambda_centre imax fwhm type_raie(a/e) ?icontinuum?.\n\n"
      return ""
   }



      #--- CAlcul les valeurs de la guaisiien :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      #-- Traduit en pixels les valeurs fournies en arguments :
      set xc [ expr ($lambda_c-$crval1)/$cdelt1 ]
      set fwhm [ expr $lfwhm/$cdelt1 ]

      #--- Calcul les valeurs dela gaussienne entre [+-4 fhhm ] :
      set coef 1.5
      set xdeb [ expr $xc-$coef*$fwhm ]
      set xfin [ expr $xc+$coef*$fwhm ]
      if { $xdeb < 1 } { set xdeb 1 }
      if { $xfin > $naxis1 } { set xfin $naxis1 }

      if { $typeline == "e" } {
         for { set x 0 } { $x < $naxis1 } { incr x } {
            if { ($x >= $xdeb) && ($x <= $xfin) } {
               # set y [ expr $imax*exp(-1.0*(($x-$xm)*($x-$xm))/(2.0*$sigma*$sigma)) ]
               # set y [ expr ($imax-$icont)*exp(-0.5*pow(($x-$xc)*2*sqrt(2*log(2))/$fwhm,2))+$icont ]
               #-- pour fwhm de spc_fwhm non multipliee par 2 et plus realiste :
               # set y [ expr ($imax-$icont)*exp(-1.0*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
               set y [ expr ($imax-$icont)*exp(-0.5*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
            } else {
               set y $icont
            }
            buf$audace(bufNo) setpix [ list [ expr $x+1 ] 1 ] $y
         }
      } elseif { $typeline == "a" } {
         for { set x 0 } { $x < $naxis1 } { incr x } {
            #::console::affiche_resultat "point n° $x\n"
            
            if { ($x >= $xdeb) && ($x <= $xfin) } {
               # set y [ expr $imax*exp(-1.0*(($x-$xm)*($x-$xm))/(2.0*$sigma*$sigma)) ]
               # set y [ expr -(-$imax+$icont)*exp(-0.5*pow(($x-$xc)*2*sqrt(2*log(2))/$fwhm,2))+$icont ]
               # set y [ expr -(-$imax+$icont)*exp(-1.0*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
               #-- pour fwhm de spc_fwhm non multipliee par 2 et plus realiste :
               set y [ expr -(-$imax+$icont)*exp(-0.5*($x-$xc)*($x-$xc)/$fwhm)+$icont ]
            } else {
               set y $icont
            }
            buf$audace(bufNo) setpix [ list [ expr $x+1 ] 1 ] $y
         }
      }

     
      #--- Sauvegarde du profil calibré
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filename}_gauss"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "Courbe gaussienne sauvée sous ${filename}_gauss\n"
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

proc spc_gaussienne0 { args } {
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
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 double "" ""]
	#-- Dispersion
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 double "" ""]

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
	::console::affiche_erreur "Usage: spc_gaussienne nom_fichier_fit_sortie imax xmoy sigma.\n\n"
    }
}
#****************************************************************#




####################################################################
# Procédure de calcul de la différence 2 à 2 de 2 liste de valeurs.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-10-2006
# Date modification : 14-=10-2006
# Arguments : 2 listes de valeurs 
####################################################################

proc spc_ajustverif { args } {
    global conf
    global audace

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
	if { $nbargs == 2 } {
	    set liste1 [ lindex $args 0 ]
	    set liste2 [ lindex $args 1 ]
	} elseif { $nbargs == 3 } {
	    set liste1 [ lindex $args 0 ]
	    set liste2 [ lindex $args 1 ]
	    set dispersion_spectrale [ lindex $args 2 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_ajustverif liste_valeurs_1 liste_valeurs_2 ?dispersion_spectrale?\n\n"
	    return 0
	}


	#-- Calcul la différence 2 à 2 :
	foreach xa $liste1 xb $liste2 {
	    set difference [ expr $xa-$xb ]
	    lappend diffs $difference
	    lappend sqdiffs [ expr $difference*$difference ]
	}

	#--- Calcul la moyenne et la norme des différence :
	set len [ llength $diffs ]
	set moy 0
	set norme 0
	foreach xd $diffs sqxd $sqdiffs {
	    set moy [ expr $moy+$xd ]
	    set norme [ expr $norme+$sqxd ]
	}
	set moy [ expr $moy/$len ]
	set normem [ expr $norme/$len ]

	#--- Calcul du  Chi2 et du RMS lors de la regression lineaire :
	set results1 [ spc_ajustdeg1 $liste1 $liste2 1 ]
	set chi2 [ lindex $results1 1 ]
	if { $nbargs == 3 } {
	    set rms [ expr $dispersion_spectrale*sqrt($chi2/$len) ]
	    ::console::affiche_resultat "RMS=$rms\n"
	}

	::console::affiche_resultat "Différences : $diffs\nValeur moyenne : $moy\nNorme : $normem\nChi2=$chi2\n"
	set result [ list $moy $norme ]
	return $result
    } else {
	::console::affiche_erreur "Usage: spc_ajustverif liste_valeurs_1 liste_valeurs_2 ?dispersion_spectrale?\n\n"
    }
}
#****************************************************************#



####################################################################
# Procédure d'intégration d'une fonction numérique par la méthode des trapèzes
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
####################################################################

proc spc_aire { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	set len [ expr [ llength $valx ]-1 ]

	set aire 0
	for {set i 0} { $i<$len } {incr i} {
	    set xi [ lindex $valx $i ]
	    set xii [ lindex $valx [ expr $i+1 ] ]
	    set yi [ lindex $valy $i ]
	    set yii [ lindex $valy [ expr $i+1 ] ]
	    set aire [ expr $aire+($xii-$xi)*0.5*($yii+$yi) ]
	    # ::console::affiche_resultat "aire $i : $aire\n"
	}
	::console::affiche_resultat "L'aire vaut : $aire\n"
	return $aire
    } else {
	::console::affiche_erreur "Usage: spc_aire {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de dérivation d'une fonction numérique
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
####################################################################

proc spc_derivation { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	set len [ expr [ llength $valx ]-1 ]

	for {set i 0} { $i<$len } {incr i} {
	    set xi [ lindex $valx $i ]
	    set xii [ lindex $valx [ expr $i+1 ] ]
	    set yi [ lindex $valy $i ]
	    set yii [ lindex $valy [ expr $i+1 ] ]
	    lappend derivey [ expr ($yii-$yi)/($xii-$xi) ]
	    lappend valxi $xi
	}
	set derivee [ list $valxi $derivey ]
	return $derivee
    } else {
	::console::affiche_erreur "Usage: spc_derivation {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#


####################################################################
# Interpolation par b-spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-11-2006
# Date modification : 25-11-2006
# Arguments : {{liste xi} {liste yi} {liste Xi}}
####################################################################

# valx : 0.9 1.3 1.9 2.1 2.6 3.0 3.9 4.4 4.7 5.0 6.0 7.0 8.0 9.2 10.5 11.3 11.6 12.0 12.6 13.0 13.3
# valy : 1.3 1.5 1.85 2.1 2.6 2.7 2.4 2.15 2.05 2.1 2.25 2.3 2.25 1.95 1.4 0.9 0.7 0.6 0.5 0.4 0.25

proc spc_bspline { args } {
    global conf
    global audace

    set Nu 20.

    if { [llength $args] == 1 } {
	set listevals [ lindex $args 0 ]
	set valx [ lindex $listevals 0 ]
	set valy [ lindex $listevals 1 ]
	#set valxs [ lindex $listevals 2 ]

	#--- Initialise les longueurs de listes :
	#-- Nombre de valeurs à interpoler
	set N [ llength $valx ]
	set Nu [ expr $N-3 ]
	#-- Nombre de valeurs qui seront calculées : échantillonnage de du spline
	set n [ expr 1+($N-3)*$Nu ]
	#-- du=x(i+1)-x(i)
	set du [ expr [ lindex $valx 1 ] - [ lindex $valx 0 ] ]


	#--- Calcul des valaurs interpolées :
	for {set i 1} { $i<[ expr $N-2] } {incr i} {
	    #-- Valeurs utilisées par le spline :
	    set x0 [ lindex $valx [ expr $i-1 ] ]
	    set x1 [ lindex $valx $i ]
 	    set x2 [ lindex $valx [ expr $i+1 ] ]
	    set x3 [ lindex $valx [ expr $i+2 ] ]
	    set y0 [ lindex $valy [ expr $i-1 ] ]
	    set y1 [ lindex $valy $i ]
 	    set y2 [ lindex $valy [ expr $i+1 ] ]
	    set y3 [ lindex $valy [ expr $i+2 ] ]

	    for {set j 0} { $j<=$Nu } {incr j} {
		#-- Initialise :
		set u [ expr $du*$j ]
		set v [ expr 1.0-$u ]

		#-- Initialise :
		set u2 [ expr $u*$u ]
		set u3 [ expr $u*$u*$u ]
		set v2 [ expr $v*$v ]
		set v3 [ expr $v*$v*$v ]

		#-- Calcul des valeurs interpolées :
		lappend xspline [ expr $x0*$v3/6.+$x1*(3.*$u3-6.*$u2+4.)/6.+$x2*(-3.*$u3+3.*$u2+3.*$u+1.)/6.+$x3*$u3/6. ]
		lappend yspline [ expr $y0*$v3/6.+$y1*(3.*$u3-6.*$u2+4.)/6.+$y2*(-3.*$u3+3.*$u2+3.*$u+1.)/6.+$y3*$u3/6. ]
	    }
	}

	#--- Affichage du plot :
	#::plotxy::plot $valx $valy
	## ::plotxy::plot $xspline $yspline
	#::plotxy::plotbackground #FFFFFF
	::plotxy::clf
	::plotxy::plot $valx $valy r 1
	::plotxy::hold on
	##::plotxy::plot $xspline $yspline ob 0
	::plotxy::plot $valx $yspline ob 0
	::plotxy::plotbackground #FFFFFF
	::plotxy::title "rouge : orginal - bleu : interpolation B-spline"

	set interpolee [ list $xspline $yspline ]
	return $interpolee
    } else {
	::console::affiche_erreur "Usage: spc_bspline {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#



####################################################################
# Procedure de lissage d'un profil spectral via une fonction polynomiale 
# Auteur : Patrick LAILLY, Benjamin MAUCLAIRE
# Date creation : 07-02-2008
# Date modification : 16-02-2008
# Algo : ajustement par moindres carr_s des donn_es (r_sultat division) par une fonction polynomiale 
# L'ajustement se fait en 2 _tapes : dans la premiere on estime l'ordre de grandeur des r_sidus (RMS des r_sidus). 
# Ceci permet de d_tecter les donn_es aberrantes (et notammant les restes de raies) : celles-ci sont d_finies  
# comme les donn_es dont les r_sidus sont en valeur absolue sup_rieurs au RMS pr_c_demment calcul_ multipli_
# par un param_tre (tauxRMS) d_fini ci-dessous.
# Les donn_es aberrantes ne sont pas prises en compte dans la deuxi_me _tape du lissage qui fournit alors la
# r_ponse instrumentale.
# Le parametre visu permet de s'assurer visuellement de la qualite du resultat et donnee via la courbe verte
# les _chantillons pris en compte dans la deuxieme etape du lissage (ce sont ceux pour lesquels la valeur de la 
# courbe verte prend une valeur non nulle. 
# Arguments : fichier .fit du profil de raie ndeg tauxRMS visu 
####################################################################

proc spc_ajustpolynome { args } {

    global conf
    global audace
    #global spc_audace(nul_pcent_intens)
    set nul_pcent_intens .65


    # ndeg est le degr_ choisi pour le polynome (ce nombre doit etre inferieur a 5)   
    # tauxRMS specifie l'amplitude des residus (en % de la moyenne RMS) censes correspondre a des r_sidus de raies
	# visu (=o ou n) indique si l'on veut ou non une visualisation du resultat 
    # Exemples :
    # spc_polynfilter resultat_division.fit 4 200 n
    

    set nb_args [ llength $args ]
    if { $nb_args<=5 } {
	if { $nb_args==5 } {
	    set abscissesorig [ lindex $args 0 ]
	    set ordonneesorig [ lindex $args 1 ]
	    set ndeg [ lindex $args 2 ]
	    set tauxRMS [ lindex $args 3 ]
	    set visu [ lindex $args 4 ]
	} elseif { $nb_args==4 } {
	    set abscissesorig [ lindex $args 0 ]
	    set ordonneesorig [ lindex $args 1 ]
	    set ndeg [ lindex $args 2 ]
	    set tauxRMS [ lindex $args 3 ]
	    set visu "n"	    
	} else {
	    ::console::affiche_erreur "Usage: spc_ajustpolynome liste_abscisses liste_ordonnees degré_polynome (<=5) pourcent_RMS_a_rejeter ?visualisation (o/n)?\n\n"
	    return ""
	}

	if { $ndeg>5 } {
	    ::console::affiche_erreur "Le degrè du polynome doit etre <=5 \n\n"
	    return 0
	}
	    
        #--- Extraction des donnees :
        set lenorig [llength $ordonneesorig ]
 
        
	#-- elimination des termes nuls au bord
	set limits [ spc_findnnul $ordonneesorig ]
	set i_inf [ lindex $limits 0 ]
	set i_sup [ lindex $limits 1 ]
	set nmilieu0 [ expr $i_sup -$i_inf +1 ]
	#-- nmilieu0 est le nb d'echantillons non nuls dans la partie effective du profil
	set lambdamin [ lindex $abscissesorig $i_inf ]
	set lambdamax [ lindex $abscissesorig $i_sup ]
	set ecartlambda [ expr $lambdamax-$lambdamin ]
	set abscisses [ list ]
	set ordonnees [ list ]
	set xx [ list ]
	set poids [ list ]
	set intens_moy 0.
	for { set i $i_inf } { $i<=$i_sup } { incr i } {
  		set xi [ lindex $abscissesorig $i ]
		set xxi [ expr ($xi-$lambdamin)/$ecartlambda ]
  		set yi [ lindex $ordonneesorig $i ]
  		lappend abscisses $xi
		lappend xx $xxi
  		lappend ordonnees $yi
		lappend poids 1.
  		set intens_moy [ expr $intens_moy +$yi ]
	}
	set intens_moy [ expr $intens_moy/($nmilieu0*1.) ]
	# intens_moy est la valeur moyenne de l'intensite
	::console::affiche_resultat "intensite moyenne : $intens_moy \n"
	
	#calcul matrice B
	set B [ list ]
	for { set i 0 } { $i<$nmilieu0 } { incr i } {
		set Bi [ list ]
		for { set j 0 } { $j<=1 } { incr j } {
		lappend Bi [ expr pow([ lindex $xx $i ],$j) ]
		}
	lappend B $Bi
	}
	

	#-- calcul de l'ajustement
	set result [ gsl_mfitmultilin $ordonnees $B $poids ]
        #-- extrait le resultat
        set coeffs [ lindex $result 0 ]
        set chi2 [ lindex $result 1 ]
        set covar [ lindex $result 2 ]
        set riliss1 [ gsl_mmult $B $coeffs ]
		

	#-- evaluation et analyse des residus
		
	set resid [ gsl_msub $ordonnees $riliss1 ]
	#::console::affiche_resultat "longueur B : [llength $B]\n"
        #::console::affiche_resultat "longueur riliss : [llength $riliss1]\n"
	set residtransp [ gsl_mtranspose $resid]

	# les calculs ci-dessous sont ? la louche : il faudrati faire intervenir les poids
	set rms_pat1  [ gsl_mmult $residtransp $resid ]
	set rms_pat [ lindex $rms_pat1 0 ]
	set rms_pat [ expr ($rms_pat/($nmilieu0*1.)) ]
	set rms_pat [expr sqrt($rms_pat)]
	::console::affiche_resultat "residu moyen (RMS) apres premiere etape : $rms_pat\n"
	#--calcul des nouveaux poids censes eliminer les residus de raies
	set seuilres [ expr $rms_pat*$tauxRMS*.01 ]
	set poids [ list ]
	for {set i 0} {$i<$nmilieu0} {incr i} {
		set poidsi [ expr $intens_moy*.5 ]
		set residi [ lindex $resid $i ]
		if { [ expr abs($residi) ]>=$seuilres } {
		set poidsi 0.
		}
		lappend poids $poidsi
	}
	
	
	#-- deuxieme etape du lissage
	#calcul matrice B
	set B [ list ]
	for { set i 0 } { $i<$nmilieu0 } { incr i } {
		set Bi [ list ]
		for { set j 0 } { $j<=$ndeg } { incr j } {
		lappend Bi [ expr pow([ lindex $xx $i ],$j) ]
		}
	lappend B $Bi
	}
	set riliss [ list ]
	set result [ gsl_mfitmultilin $ordonnees $B $poids ]
        #-- extrait le resultat
        set coeffs [ lindex $result 0 ]
        set chi2 [ lindex $result 1 ]
        set covar [ lindex $result 2 ]
	set riliss [ gsl_mmult $B $coeffs ]

        #--- Affichage du resultat :
	set testvisu "n"
	if { $visu == "o" } {
	    set numero_fig [ expr abs(int([lindex $coeffs 2 ]*10*rand())) ]
	    #::plotxy::clf
	    ::plotxy::figure $numero_fig
	    ::plotxy::plot $abscissesorig $riliss r 1
	    #::plotxy::plot $abscissesorig $riliss1 o 1
	    ::plotxy::hold on
	    ::plotxy::plot $abscissesorig $ordonneesorig ob 0
	    #::plotxy::hold on
	    #::plotxy::plot $abscissesorig $poids g 0
	    ::plotxy::plotbackground #FFFFFF
	    ::plotxy::title "bleu : original - rouge : lissage par polynome de degré $ndeg"
	    ::plotxy::hold off
        }
	return $coeffs	
    } else {
        ::console::affiche_erreur "Usage: spc_ajustpolynome liste_abscisses liste_ordonnees degré_polynome (<=5) pourcent_RMS_a_rejeter ?visualisation (o/n)?\n\n"
    }
}


















#======================================================================#
#
#======================================================================#


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


