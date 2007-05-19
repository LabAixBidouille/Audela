####################################################################
# Procedure d'ajustement d'un nuage de points
#
# Auteur : Patrick LAILLY
# Date creation : 07-03-2007
# Date modification : 15-03-2007
# Arguments : fichier .fit du profil de raie
# Exemple BR : spc_ajust_piecewiselinear resultat_division_150t 60 30
#  suivi de : spc_passebas resultat_division_150t_lin 31
# Exemple HR : spc_ajust_piecewiselinear resultat_division2400t_castor1600 160 30
####################################################################

proc spc_ajust_piecewiselinear { args } {
    global conf
    global audace

    #--  nechant est le nombre d'intervalles contenus dans un macro intervalle

    if { [ llength $args ]==1 || [ llength $args ]==2 || [ llength $args ]==3} {
        if { [ llength $args ]==1 } {
            set filenamespc [ lindex $args 0 ]
            set nechant 80
	    set ecartlambda 30
        } elseif { [ llength $args ]==2 } {
            set filenamespc [ lindex $args 0 ]
            set nechant [ lindex $args 1 ]
	    set ecartlambda 30
	} elseif { [ llength $args ]==3 } {
            set filenamespc [ lindex $args 0 ]
            set nechant [ lindex $args 1 ]
	    #-- Largeur moyenne d'une raie=pix division en pixel :
    	    set ecartlambda [ lindex $args 2 ]
        } else {
            ::console::affiche_erreur "Usage: spc_ajust_piecewiselinear fichier_profil.fit ?largeur intervalle (pixel)? ?largeur raie (30 angstroms)?\n\n"
            return 0
        }

        #-- Initialisation des paramètres :
        set erreur 1.
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set len [llength $ordonnees ]

        #-- Paramètre d'ajustement resultat_division2400t_regulus400:
        set ninter [expr int($len/$nechant)+1]
        set nbase [expr $ninter+1]

        #extension du nombre de points de mesure
        set n [expr $nechant*$ninter+1]
	set nraisonable [ expr $n/5 ]
        set abscissesorig $abscisses
        set ordonneesorig $ordonnees
	::console::affiche_resultat "nombre d'abscisses : [ llength $abscisses ]\n"
	::console::affiche_resultat "nombre d'ordonnees : [ llength $ordonnees ]\n"
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
       # set nechant1 [ expr $nechant-1 ]
        for {set i 0} {$i<$nechant} {incr i} {
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
        if { 0==0 } {
        set nechant3 [ expr $nechant+1 ]
        for {set i 0} {$i<$n} {incr i} {
            set lignei ""
            for {set j 0} {$j<$nechant3} {incr j} {
                set elemj 0.
                if { [ expr abs($i+1-$j*$nechant) ]<=$nechant } {
                    set elemj [ lindex $v [ expr $i+1 -$j*$nechant+$nechant ] ]
                }
                lappend lignei $elemj
            }
            lappend B $lignei
        }
        }


        #-- Meth3 : version rapide
	if { 1==0 } {
        set nechant3 [ expr $nechant+1 ]
        #set lignei [ list ]
        #creation d'un ligne de zeros de largeur nechant + 1
        set lignezeros [ list ]
        for {set j 0} {$j<$nbase} {incr j} {
                lappend lignezeros 0.
        }

        for {set i 0} {$i<$n} {incr i} {
            set lignei $lignezeros
            #- jmin=max de 2 nombres :
            # set jmin [ expr [ lindex [ lsort -integer -decreasing [ list 0 [ expr $i/$nechant + 1 ] ] ] 0 ]+0 ]
            set jmin [ expr [ lindex [ lsort -integer -decreasing [ list 0 [ expr ($i+1)/$nechant-1 ] ] ] 0 ]+0 ]
            #- jmax=min de 2 nombres-1 :
            set jmax [ expr [ lindex [ lsort -integer -increasing [ list $ninter [ expr ($i+2)/$nechant-1 ] ] ] 0 ] +0 ]
            for {set j $jmin} {$j<=$jmax} {incr j} {
                #::console::affiche_resultat "v$j=[ lindex $v [ expr $i-($j-1)*$nechant ] ]\n"
                set lignei [ lreplace $lignei $j $j [ lindex $v [ expr $i+1-$j*$nechant+$nechant ] ] ]
            }
            lappend B $lignei
        }
	}
       


        #-- calcul de l'ajustement
        set result [ gsl_mfitmultilin $ordonnees $B $poids ]
        #-- extrait le resultat
        set coeffs [ lindex $result 0 ]
        set chi2 [ lindex $result 1 ]
        set covar [ lindex $result 2 ]

        set riliss [ gsl_mmult $B $coeffs ]
	set resid [ gsl_msub $ordonnees $riliss ]
	::console::affiche_resultat "longueur B : [llength $B]\n"
        ::console::affiche_resultat "longueur riliss : [llength $riliss]\n"
	set residtransp [ gsl_mtranspose $resid]
	#set rms_pat [ expr (sqrt( [ (gsl_mmult [ gsl_mtranspose $resid] $resid ] )/($n*1.) ]
	# les calculs ci-dessous sont à la louche : il faudrati faire intervenir les poids
	set rms_pat1  [ gsl_mmult $residtransp $resid ]
	set rms_pat [ lindex $rms_pat1 0 ]
	set rms_pat [ expr ($rms_pat/($n*1.)) ]
	set rms_pat [expr sqrt($rms_pat)]
	::console::affiche_resultat "Résidu moyen (RMS) : $rms_pat\n"
	set seuilres [ expr $rms_pat*10. ]
	set grandres ""

	for {set i 0} {$i<$n} {incr i} {
	    lappend grandres 0
	}
	for {set i 0} {$i<$n} {incr i} {
	    if { [ lindex $resid $i ]>=$seuilres } {
		set grandres [ lreplace $grandres $i $i 1 ]
	    }
	}
	::console::affiche_resultat "Longueur grandres : [ llength $grandres ]\n"
	set nechantelim 0
	set intervouvert 0
	#initialisastion de poids1 à la valeur 1
	set poids1 ""
	for {set i 0} {$i<$n} {incr i} {
	    lappend poids1 1.
	}
	::console::affiche_resultat "Longueur resid : [llength $resid]\n"
	for {set i 0} {$i< [ expr $len ]} {incr i} {
	    if { [ lindex $poids $i ] !=0. } {
		if { $intervouvert==0 } {
		    if { [ lindex $grandres $i ]==1 } {
			set intervouvert 1
			set ideb $i
		    }
		} else {
		    if { [ lindex $grandres $i ]==1 } {
			set ifin $i
		    } else {
			set intervouvert 0
			set ifin [ lindex [ lsort -integer -decreasing [ list $ideb $ifin] ] 0 ]
			set larglambda [ expr [ lindex $abscissesorig [ expr $ifin-1 ] ]-[ lindex $abscissesorig [ expr $ideb-1 ] ] ]
			#::console::affiche_resultat "larglambda : $larglambda\n"
			#::console::affiche_resultat "indice lambda : $ifin\n"
			if { $larglambda>$ecartlambda } {
			    for {set j $ideb} {$j<$ifin} {incr j} {
			    set poids1 [ lreplace $poids1 $j $j 0. ]
			    }
			    #::console::affiche_resultat "longueur poids1 : [ llength $poids1 ]\n"
			    set nechantelim [ expr $nechantelim+$ifin-$ideb+1 ]
			    #::console::affiche_resultat "nombre d'echantillons elimines : $nechantelim\n"
			}
		    }
		}

	    }
	}

	if { $nechantelim>$nraisonable } {
	    ::console::affiche_resultat "Attention nombre d'echantillons elimines peu raisonnable : $nechantelim\n"
	} else {
     ::console::affiche_resultat "Modif de poids...\n"
     ::console::affiche_resultat "longueur poids [ llength $poids ] \n"
     ::console::affiche_resultat "longueur poids1 [ llength $poids1 ] \n"
	    set i 0
	    foreach valpoids $poids valpoids1 $poids1 {
		set valpoids [ expr $valpoids*$valpoids1 ]
		set poids [ lreplace $poids $i $i $valpoids ]
		incr i
	    }
	}
	::console::affiche_resultat "longueur poids [ llength $poids ] \n"
	#-- calcul de l'ajustement
	::console::affiche_resultat "ajustement avec poids modifies\n"
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
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        #set k 1
        #foreach x $abscisses {
            #set y_lin [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x+$e*pow($x,4)+$f*pow($x,5) ]
            #lappend yadj $y_lin
            #buf$audace(bufNo) setpix [list $k 1] $y_lin
            #incr k
        #}
	for {set k 1} {$k<=$naxis1} {incr k} {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $riliss [ expr $k-1 ] ]
	}

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
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajust_piecewiselinear fichier_profil.fit ?largeur intervalle (pixel)? ?largeur raie (30 angstroms)?\n\n"
    }
}
#****************************************************************#


