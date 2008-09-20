

# Mise a jour $Id: spc_filter2.tcl,v 1.4 2008-09-20 17:20:05 bmauclaire Exp $


####################################################################
# Procedure de la fonction d'apodisation pour filtre passe bas a reponse impulsionnelle finie 
# Auteur : Patrick LAILLY
# Date creation : 18-4-07
# Date modification : 1-5-07
# Arguments : demilargeur de la reponse impulsionnelle du filtre, nombre d'echantillon du profil a # filtrer, type de fonction d'apodisation
# Algo : reprod. des formules donnees dans "Digital Signal Processing" par Oppenheim et Schafer
# La reponse impulsionnelle du filtre aura un nombre impair d'echantillons (2 * demilargeur + 1)
####################################################################
proc fonc_apod  { demilargeur nlen type_apod } {

	set nlarg [ expr 2*$demilargeur+1 ]
	set apod [ list ]
	for {set i 0} {$i<$nlen} {incr i} {
		lappend apod 0.
	}

	switch $type_apod {
	#set amplit [ expr 1./$nlarg ]
	#::console::affiche_resultat "nlen= $nlen\n"
	#::console::affiche_resultat "longueur filtre= [llength $filtr ]\n"

		rectangle {
		for {set i 0} {$i<=$demilargeur} {incr i} {
			set apod [ lreplace $apod $i $i 1 ]
		}
		#::console::affiche_resultat "longueur filtre= [llength $filtr ]\n"
		set redemar [ expr $nlen-$demilargeur ]
		#::console::affiche_resultat "redemar=$redemar\n"
		for {set i $redemar} {$i<$nlen} {incr i} {
			set apod [ lreplace $apod $i $i 1 ]
		}
		}

		blackman {
		set pi [ expr 2.*asin(1.) ]
		for {set i 0} {$i<=$demilargeur} {incr i} {
			set amplit [ expr 0.42-0.5*cos($pi*($i+$demilargeur)/$demilargeur)+0.08*cos(2.*$pi*($i+$demilargeur)/$demilargeur) ]
			set apod [ lreplace $apod $i $i $amplit ]
		}
		set redemar [ expr $nlen-$demilargeur ]
		for {set i $redemar} {$i<$nlen} {incr i} {
			set amplit [ expr 0.42-0.5*cos($pi*($i-$redemar)/$demilargeur)+0.08*cos(2.*$pi*($i-$redemar)/$demilargeur) ]
			set apod [ lreplace $apod $i $i $amplit ]
		}
		}
		
		hanning {
		set pi [ expr 2.*asin(1.) ]
		for {set i 0} {$i<=$demilargeur} {incr i} {
			set amplit [ expr 0.5-0.5*cos($pi*($i+$demilargeur)/$demilargeur) ]
			set apod [ lreplace $apod $i $i $amplit ]
		}
		set redemar [ expr $nlen-$demilargeur ]
		for {set i $redemar} {$i<$nlen} {incr i} {
			set amplit [ expr 0.5-0.5*cos($pi*($i-$redemar)/$demilargeur) ]
			set apod [ lreplace $apod $i $i $amplit ]
		}
		}
	}
	return $apod

}
#****************************************************************#


####################################################################
# Procedure de filtrage passe bas (filtre a reponse impulsionnelle
# finie avec fonctions d'apodisation diverses)
#
# Auteur : Patrick LAILLY
# Date creation : 18-4-07
# Date modification : 1-5-07
# Arguments : liste d'ordonnees, demilargeur de la
# fonction d'apodisation, periode maximale autorisee (en nb d'echantillons)
# c-a-d periode de coupure, type de fonction d'aposisation
# Algo : application (par passage dans l'espace de Fourier) d'un filtre
# passe-bas de r?ponse impulsionnelle finie. Trois types de filtres sont
# propos?s : rectangle, Hanning ou Blackman. Les donn?es filtr?es sont
# calcul?es sauf aux bords (dont l'?tendue est, de chaque cot?, ?gale ? la
# demi-largeur du filtre). Sur ces bords on reproduit les donn?es d'entr?e.
####################################################################
proc spc_passebas_pat { args } {
    global conf
    global audace
    if { [llength $args] <= 4  &&  [llength $args] > 0 } {
	if { [llength $args] == 4 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur [ lindex $args 1 ]
	    set period_max [ lindex $args 2 ]
	    set type_apod [ lindex $args 3 ]
	    #if { { $type_apod != blackman } || { $type_apod != rectangle } || { $type_apod != hanning } } {
	    #::console::affiche_erreur "Usage spc_passebas_pat : seules fonctions d'apodisation admises : blackman,
	    #hanning ou rectangle\n\n"
	    #return 0
	    #}
	} elseif { [llength $args] == 3 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur [ lindex $args 1 ]
	    set period_max [ lindex $args 2 ]
	    set type_apod blackman
	} elseif { [llength $args] == 2 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur [ lindex $args 1 ]
	    set period_max $demilargeur
	    set type_apod blackman
	} elseif { [llength $args] == 1 } {
	    set ordonnees [ lindex $args 0 ]
	    set demilargeur 25
            set period_max $demilargeur
	    set type_apod blackman
	}

#tests sur la compatibilite des donnees
	if { $period_max > [ expr 2.*$demilargeur+1 ] } {
	::console::affiche_erreur "Usage: spc_passebas la periode max doit etre plus petite que 2*demilargeur+1 \n\n"
	return 0
	} else {
	set nordonnees $ordonnees

# prolongement du spectre si le nombre d'echantillons est pair
	set len [ llength $ordonnees ]
	set nlen $len
	
	if {[ expr $len%2 ]==0} {
		lappend nordonnees  [ lindex $ordonnees [ expr $len-1 ] ]
		set nlen [ expr $nlen +1 ]
	}
	if { $nlen < [ expr 2.*$demilargeur+1 ] } {
		::console::affiche_erreur "Usage: spc_passebas le nombre d'echantillons doit etre plus grand que 2*demilargeur+1 \n\n"
		return 0
	} else {

# construction de la fonction d'apodisation
	set apod [ fonc_apod $demilargeur $nlen $type_apod ]
	#::console::affiche_resultat "longueur apod [ llength $apod ]\n"

# calcul reponse impulsionnelle filtre passe-bas
 	#set omega_coup [ expr 4.*$nlen*[ expr asin(1) ]/$period_max ]
	set omega_coup [ expr 4.*[ expr asin(1) ]/$period_max ]
	set nlarg [ expr 2*$demilargeur+1 ]

	set demilongueur [ expr $nlen/2 ]
	set impuls [ list ]
	lappend impuls [ expr $omega_coup/(2*[ expr asin(1) ]) ]
	for {set i 1} {$i<=$demilongueur} {incr i} {
		lappend impuls [ expr sin($omega_coup*$i) ]/(2*$i*[ expr asin(1) ])
	}
	for {set i 1} {$i<=$demilongueur} {incr i} {
		lappend impuls [ lindex $impuls [ expr $demilongueur - $i + 1 ] ]
	}

	# constructtion du noyau de convolution
	set filtr [ list ]
	set temps ""
	set lignezeros ""
	for {set i 0} {$i<$nlen} {incr i} {
		lappend filtr [ expr [ lindex $impuls $i ] * [ lindex $apod $i ] ]
		lappend lignezeros 0.
		lappend temps [ expr $i*1. ]
	}

	set filtrfft [ gsl_fft $filtr $temps]
	set refiltrfft [ lindex $filtrfft 0 ]
	set imfiltrfft [ lindex $filtrfft 1 ]
	if {$imfiltrfft != $lignezeros} {
		#::console::affiche_resultat "erreur (en general pas grave) part imag filtr\n"
	}

	#normalisation du filtre (conservation de la DC)
	set normal [ expr 1./ [ lindex $refiltrfft 0 ] ]

	for {set i 0} {$i<$nlen} {incr i} {
		set refiltrfft [ lreplace $refiltrfft $i $i [ expr [ lindex $refiltrfft $i ] * $normal ] ]
	}

	# filtrage des donnees

	set amplitfft [ gsl_fft $nordonnees $temps]
 	set reamplitfft [ lindex $amplitfft 0 ]
	set imamplitfft [ lindex $amplitfft 1 ]
	set reprod ""
	set improd ""
	for {set i 0} {$i<$nlen} {incr i} {
 		set prod1 [ expr [ lindex $refiltrfft $i ]*[ lindex $reamplitfft $i ] ]
		set prod2 [ expr [ lindex $refiltrfft $i ]*[ lindex $imamplitfft $i ] ]
		lappend reprod $prod1
		lappend improd $prod2
	}
	set result [ gsl_ifft $reprod $improd $temps ]
	set reconvol [ lindex $result 0 ]
	set imconvol [ lindex $result 1 ]
	if {$imconvol != $lignezeros} {
		#::console::affiche_resultat "erreur part (en general pas grave) imag filtr \n"
	}
	#::console::affiche_resultat "longueur r?sultat convolution= [ llength $reconvol ]\n"
	#?limination des effets de bord (remplacement par les valeurs d'origine)

	for {set i 0} {$i<$demilargeur} {incr i} {
		set reconvol [ lreplace $reconvol $i $i [ lindex $ordonnees $i ] ]
	}
	for {set i [expr $len-$demilargeur ]} {$i<$len} {incr i} {
		set reconvol [ lreplace $reconvol $i $i [ lindex $ordonnees $i ] ]
	}
	# retour aux dimensions d'origine
	if { $nlen != $len } {
		set reconvol [ lrange $reconvol 0  [expr $len-1 ] ]
	}

	#::console::affiche_resultat "longueur r?sultat filtrage= [ llength $reconvol ]\n"
	#::console::affiche_resultat "longueur ordonnees= [ llength $ordonnees ]\n"
	
       
	}
	}
	return $reconvol

} else {
	    ::console::affiche_erreur "Usage: spc_passebas liste d'ordonnees ? demilargeur du filtre (25)? , periode de coupure ? type fonction d'apodisation (blackmann) ?\n\n"
	    return 0
	}

}
#****************************************************************#


####################################################################
# Procedure d'ajustement de la largeur (nechant) des morceaux utilis?s
# dans spc_pwlri et spc_pwlfilter pour minimiser les effets de bords
# Auteur : Patrick LAILLY
# Date creation : 08-05-2007
# Date modification : 23-07-2007
# Arguments : longueur liste intensite non nulle, valeur approx nechant
# cette derniere est supposee superieure ou egale a 24
####################################################################
proc ajust_interv {args } {
global conf
global audace
if { [ llength $args ]==2 } {
	set len [ lindex $args 0 ]
	set nechant [ lindex $args 1 ]
	if { $nechant < 24 } {
		::console::affiche_erreur "Usage:  dans ajust_interv le deuxieme argument doit etre superieur ou egal a 24\n\n"
		return 0
	}
	set reste [ list ]
	for { set k [ expr $nechant - 6 ] } { $k <= [ expr $nechant + 6 ] } {incr k } {
		set restek [ expr $len % $k ]
		lappend reste $restek
	}
	set restetri [ lsort -integer -increasing $reste ]
	if { [ lindex $restetri 0 ] == 0 } {
		set npos [ lsearch -exact $reste 0 ]
		} else {
		set reste_max [ lindex $restetri 12 ]
		set npos [ lsearch -exact $reste $reste_max ]
	}
	set nechant [ expr $npos + $nechant - 6 ]
	::console::affiche_resultat "nechant ajuste = $nechant reste [ lindex $reste $npos ]\n"
	#::console::affiche_resultat "restes $restetri\n "
	return $nechant
} else {
	::console::affiche_erreur "Usage: ajust_interv nb echant profil ?largeur morceaux?\n\n"
	return 0
}
}
#****************************************************************#



####################################################################
# Procedure de calcul de la matrice B utilisee dans les algorithmes de 
# lissage par des fonctions linŽÃŽ©aires morceaux (spc_pwl...)
#
# Auteur : Patrick LAILLY
# Date creation : 15-05-2007
# Date modification : 23-07-2007
#
#     ***************************************************
# l'appel de cette procedure meriterait d'etre sortie de la partie algo
# on s'epargnerait ainsi plusieurs calculs de la matrice B dans spc_pwlri 
proc spc_calcmatB {args} {
global conf
global audace

if { [ llength $args ]==2 } {
	set nechant [ lindex $args 0 ]
	set nbase [ lindex $args 1 ]
	#::console::affiche_resultat "fonc gener\n"
 
        #-- calcul de la fonction generatrice
        set vpre [ list ]
        set vtop [ list ]
        set vpost [ list ]
        lappend vtop 1.
        #lappend vpre 0.
        #set nechant1 [ expr $nechant-1 ]
        for {set i 0} {$i<$nechant} {incr i} {
            set vi [ expr 1.*$i/$nechant ]
            lappend vpre $vi
        }
        for {set i 0} {$i<$nechant} {incr i} {
            set vi [ lindex $vpre [ expr $nechant - $i -1] ]
            lappend vpost $vi
        }
        #lappend vpost 0.

        
        #::console::affiche_resultat "vpre=$vpre\n"
        #::console::affiche_resultat "vtop=$vtop\n"
        #::console::affiche_resultat "vpost=$vpost\n"
	#-- calcul de la matrice BT (B transposee)
	set listezeros [ list ]
	for {set i 0} {$i<$nechant} {incr i} {
		lappend listezeros 0.
	}
	set B [ list ]
	#set BT [ list ]
	set listdeb [ list ]
	set listfin [ list ]
	for {set i 1} {$i<= [ expr $nbase -2 ]} {incr i} {
		set listfin [ concat $listfin $listezeros ]
	}
	set BTi [ concat $vtop $vpost $listfin ]
	
	lappend B $BTi
	#::console::affiche_resultat "long 0 eme ligne BT [llength $BTi] \n"
	set JJ [ expr $nbase -2 ]
	for {set i 1} {$i<= $JJ} {incr i} {
		set listdeb [ list ]
		set listfin [ list ]
		if { $i != 1 } {
			for {set j 1} {$j<= [ expr $i - 1 ]} {incr j} {
				set listdeb [ concat $listdeb $listezeros ]
			}
		}
		if { $i != $JJ } {
			for {set j 1} {$j<= [ expr $JJ - $i ]} {incr j} {
				set listfin [ concat $listfin $listezeros ]
			}
		}
		set BTi [concat $listdeb $vpre $vtop $vpost $listfin ]
		#::console::affiche_resultat "long $i eme ligne BT  [llength $listdeb]  [llength $vpre]   [llength $vtop]  [llength $vpost] [llength $listfin]\n"
		lappend B $BTi
	}
	# derniere ligne de B*
	set listdeb [ list ]
	set listfin [ list ]
	for {set i 1} {$i<= [ expr $nbase -2 ]} {incr i} {
		set listdeb [ concat $listdeb $listezeros ]
	}
	set BTi [ concat $listdeb $vpre $vtop ]
	#::console::affiche_resultat "long derniere ligne BT [llength $BTi] \n"
	lappend B $BTi
	#::console::affiche_resultat "longueur BT : [llength $BT]\n"
	#::console::affiche_resultat "longueur ligne de BT : [llength [lindex $BT 1]]\n"
	
	# transposition de B*
	
	set B [ gsl_mtranspose $B ]
	#::console::affiche_resultat "longueur B : [llength $B]\n"
	#::console::affiche_resultat "longueur ligne de B : [llength [lindex $B 1]]\n"
	return $B	 
	} else {
        ::console::affiche_erreur "Usage: spc_calcmatB 2 arguments requis\n\n"
	return 0
    }
}
#****************************************************************#

	

####################################################################
# Procedure (partie algorithmique) de calcul de l'approximation lineaire par
# morceaux de la partie reguliere du profil
#
# Auteur : Patrick LAILLY
# Date creation : 15-05-2007
# Date modification : 23-07-2007
# Arguments :
# -liste d'abscisses du profil de raie
# -liste d'ordonnees du profil de raie (ces 2 listes doivent avoir la meme longueur)
# - nechant est le nombre d'echantillons contenus dans un macro intervalle; a ce stade la longueur du profil moins un est supposee etre un multiple de nechant
# - tauxRMS specifie l'amplitude des residus (en % de la moyenne RMS) censes correspondre, apres filtrage, a des portions irregulieres du profil
# - demilargeur est la demi largeur (en echantillons) du filtre passe bas utilise
# - period_max est la periode maximale (en echantillons) definissant la frequence de coupure du #filtre passe bas utilise
# - larg_cosmet specifie la largeur de la reponse impulsionnelle du filtre cosmetique
# (rectangle) utilise en post traitement, cette largeur etant exprimee en % de la largeur nechant
# retourne la liste d'ordonnees lissee (la liste d'abscisses est inchangee)
####################################################################

proc spc_ajust_piecewiselinear_alg { args } {

global conf
global audace


if { [ llength $args ]==7 } {

	set abscisses [ lindex $args 0 ]
	set ordonnees [ lindex $args 1 ]
	set nechant [ lindex $args 2 ]
	set tauxRMS [ lindex $args 3 ]
	set demilargeur [ lindex $args 4 ]
	set period_max [ lindex $args 5 ]
	set larg_cosmet [ lindex $args 6 ]

        #-- Initialisation des param?tres :  

        set n [ llength $ordonnees ]
        set ordon_max [ lindex [ lsort -real -increasing $ordonnees ] [ expr $n -1 ] ]
        #::console::affiche_resultat "ordonnee max $ordon_max \n"
        if { [expr ($n % $nechant) ] != 1 } {
        	::console::affiche_resultat "erreur conflit de donnees n= $n nechant= $nechant \n"
        }
	::console::affiche_resultat "longueur ordonnees apres extraction partie effective: [ llength $ordonnees ]\n"

        #-- Param?tre d'ajustement :
        set ninter [expr int($n/$nechant)]
        set nbase [expr $ninter+1]
        #::console::affiche_resultat "nbase= $nbase\n"
        #::console::affiche_resultat "nechant= $nechant\n"

        
        #definition des poids
        set poids [ list ]
        for {set i 0} {$i<$n} {incr i} {
            set poidsi 1.
            if {[lindex $ordonnees $i]==0.} {set poidsi 0.}
            lappend poids $poidsi
        }
	
        

       

        #approx des donnees par une version filtree et mesure des ecarts (residus)
	set riliss [ spc_passebas_pat $ordonnees $demilargeur $period_max rectangle ]
	set resid [ gsl_msub $ordonnees $riliss ]
	#::console::affiche_resultat "longueur B : [llength $B]\n"
        #::console::affiche_resultat "longueur riliss : [llength $riliss]\n"
	set residtransp [ gsl_mtranspose $resid]

	# les calculs ci-dessous sont ? la louche : il faudrati faire intervenir les poids
	set rms_pat1  [ gsl_mmult $residtransp $resid ]
	set rms_pat [ lindex $rms_pat1 0 ]
	set rms_pat [ expr ($rms_pat/($n*1.)) ]
	set rms_pat [expr sqrt($rms_pat)]
	::console::affiche_resultat "residu moyen (RMS) apres filtrage : $rms_pat\n"
	set seuilres [ expr $rms_pat*$tauxRMS*.01 ]
	set poids1 [ list ]
	for {set i 0} {$i<$n} {incr i} {
		set poids1i 1.
		set residi [ lindex $resid $i ]
		if { [ expr abs($residi) ]>=$seuilres } {
		set poids1i 0.
		}
		lappend poids1 $poids1i
	}
	set B [ spc_calcmatB $nechant $nbase ]
	
	set nouvpoids [ list ]
	for {set i 0} {$i<$n} {incr i} {
		lappend nouvpoids [ expr [ lindex $poids $i ] * [ lindex $poids1 $i ] ]
        }
	#::console::affiche_resultat "longueur nouvpoids : [ llength $nouvpoids ] \n"
	#-- calcul de l'ajustement
	set result [ gsl_mfitmultilin $ordonnees $B $nouvpoids ]
        #-- extrait le resultat
        set coeffs [ lindex $result 0 ]
        set chi2 [ lindex $result 1 ]
        set covar [ lindex $result 2 ]

        set riliss [ gsl_mmult $B $coeffs ]

        #::console::affiche_resultat "longueur B : [llength $B]\n"
        #::console::affiche_resultat "longueur riliss : [llength $riliss]\n"
        #::console::affiche_resultat "longueur Coefficients : [llength $coeffs]\n"
        #::console::affiche_resultat "Coefficients : $coeffs\n"

	# lissage de la fonction lineaire par morceaux
	set demilargeur [ expr $nechant*$larg_cosmet/100 ]
	
	# extension a droite
	set dy [ expr  [ lindex $riliss [ expr $n-1 ] ] -[ lindex $riliss [ expr $n-2 ] ] ]
	set prevalue [ lindex $riliss [ expr $n-1 ] ]
	for { set i 1 } { $i<=$demilargeur } { incr i } {
	    set riliss [ linsert $riliss [ expr $n+$i ] [ expr $prevalue + $dy*$i ] ]
	}

	#extension a gauche
	set prevalue [ lindex $riliss 0 ]
	set postvalue [ lindex $riliss 1 ]

	set dy [ expr  $postvalue - $prevalue  ]
	
	for { set i 1 } { $i<=$demilargeur } { incr i } {
	    set riliss [ linsert $riliss 0 [ expr $prevalue - $dy*$i ] ]
	}
	#::console::affiche_resultat "demilargeur : $demilargeur\n"

	set period_max [ expr 2*$demilargeur ]
	set riliss [ spc_passebas_pat $riliss $demilargeur $period_max rectangle]
        #--- On rame?ne riliss et poids aux dumensions de d?part de l'image FITS :
        set riliss [ lrange $riliss $demilargeur [ expr $demilargeur + $n-1] ]
        set poids [ lrange $poids 0 [ expr $n-1] ]
        
	set nouvpoids [ lrange $nouvpoids 0 [ expr $n-1] ]
 	#::console::affiche_resultat "longueur nouvpoids : [llength $nouvpoids]\n"
	#::console::affiche_resultat "nouvpoids (0) : [lindex $nouvpoids 0]\n"
	#::console::affiche_resultat "nouvpoids (1) : [lindex $nouvpoids 1]\n"
	for {set i 0} {$i<$n} {incr i} {
		set nouvpoidsi [ lindex $nouvpoids $i ]
		set nouvpoidsi [ expr .05*$ordon_max*$nouvpoidsi]
		set nouvpoids [lreplace $nouvpoids $i $i $nouvpoidsi]
	}

	set list_result [ list $abscisses $riliss $nouvpoids ]
	return $list_result
	} else {
        ::console::affiche_erreur "Usage: spc_ajust_piecewiselinear_alg 7 arguments requis, les 2 premiers etant des listes de meme longueur\n\n"
	return 0
    }
}
#****************************************************************#




####################################################################
# Procedure de lissage de la reponse instrumentale en basse resolution
#
# Auteur : Patrick LAILLY
# Date creation : 07-03-2007
# Date modification : 23-07-2007
# Algo : on cr?e une version lissee (a l'aide d'une representation 
# parametrique basee sur des fonctions continues lineaires par morceaux
# (macro-intervalles) de largeur fixee) du resultat de la division en limitant
# l'ajustement aux portions regulieres du fichier d'entree. Pour detecter
# les portions irregulieres on analyse les ecarts avec une version filtree
# du profil. En fait deux niveaux de filtrage sont testes creant ainsi les
# deux premiers fichier de sortie : le premier utilise un filtre 
# peu selectif, l'autre un filtre plus selectif. Enfin un troisieme resultat
# est produit par interpolation des 2 premiers, le parametre d'interpolation 
# dependant de la longueur d'onde : un poids plus important est donne au premier 
# fichier pour les faibles longueurs d'onde alors que c'est le second 
# fichier qui devient preponderant pour les grandes longueurs d'onde.
# Cette methode de compositage a ses motivations mais ne pretend pas 
# a l'universalite. Au final, l'utilisateur selectionnera (via la visualisation
# des 3 resultats la RI qui lui convient le mieux. 
# Precisons que l'approximation lineaire par morceaux fait l'objet 
# d'un post traitement : on lui applique un filtre (encore un !) avant
# tout pour des raisons cosmetiques.  
# Arguments : fichier .fit du profil de raie, largeur d'un macro intervalle (en nombre 
# d'echantillons + arguments optionnels (voir ci-dessous)
# NB la largeur d'un macro intervalle donnee en argument est legerement modifiee par l'algorithme # afin de minimiser les effets de bord
####################################################################

proc spc_pwlri { args } {

  global conf
  global audace
  global spcaudace
  #set spcaudace(nulpcent) 100

  # nechant est le nombre d'echantillons contenus dans un macro intervalle pour les 2 filtrages de  1er niveau
  # ce parametre est modifie de facon a minimiser les effets de bord; il faut eviter la situation ou, apres
  # modification de ce parametre, la fonction lin?aire par morceaux a un sommet localise dans une raie importante
  # period_max1 est la periode de coupure (en echantillons) donnant la frequence de coupure pour le 1er niveau de filtrage
  # period_max2 est la periode de coupure (en echantillons) donnant la frequence de coupure pour le 2eme niveau de filtrage
  # tauxRMS1 specifie l'amplitude des residus (en % de la moyenne RMS) censes correspondre a des portions irregulieres du profil pour le 1er niveau de filtrage
  # tauxRMS2 specifie l'amplitude des residus (en % de la moyenne RMS) censes correspondre a des #portions irregulieres du profil pour le 2eme niveau de filtrage
  # larg_cosmet specifie la largeur de la reponse impulsionnelle du filtre cosmetique (rectangle) utilise en post traitement, cette largeur etant exprimee en % de la largeur nechant des macrointervalles

  # Exemple : spc_pwlri resultat_division_150t.fit 50 11 51 70 50 100


  if { [ llength $args ]==2 || [ llength $args ]==7} {
	set filenamespc [ lindex $args 0 ]
	set nechant [ lindex $args 1 ]
	set period_max1 11
	set period_max2 51
	set tauxRMS1 70
	set tauxRMS2 50
	set larg_cosmet 40

	if { [ llength $args ]==7 } {
            set nechant [ lindex $args 1 ]
	    set period_max1 [ lindex $args 2 ]
	    set period_max2 [ lindex $args 3 ]
	    set tauxRMS1 [ lindex $args 4 ]
	    set tauxRMS2 [ lindex $args 5 ]
	    set larg_cosmet [ lindex $args 6 ]
	}

	set demilargeur1 [ expr $period_max1/2 ]
	set demilargeur2 [ expr $period_max2/2 ]

        #--- Extraction des donnees :

        set contenu [ spc_fits2data $filenamespc ]
        set abscissesorig [ lindex $contenu 0 ]
        set ordonneesorig [ lindex $contenu 1 ]
        set lenorig [llength $ordonneesorig ]
 
        
	#-- elimination des termes nuls au bord
	set limits [ spc_findnnul $ordonneesorig ]
	set i_inf [ lindex $limits 0 ]
	set i_sup [ lindex $limits 1 ]
	set nmilieu0 [ expr $i_sup -$i_inf +1 ]
	#-- nmilieu0 est le nb d'echantillons non nuls dans la partie effective du profil
	set abscisses [ list ]
	set ordonnees [ list ]
	set intens_moy 0.
	for { set i $i_inf } { $i<=$i_sup } { incr i } {
  		set xi [ lindex $abscissesorig $i ]
  		set yi [ lindex $ordonneesorig $i ]
  		lappend abscisses $xi
  		lappend ordonnees $yi
  		set intens_moy [ expr $intens_moy +$yi ]
	}
	set intens_moy [ expr $intens_moy/($nmilieu0*1.) ]

	set len [ llength $ordonnees ]
	::console::affiche_resultat "longueur profil apres extract part effective $len\n"

	#-- ajustement de nechant pour minimiser les effets de bord et prolongement "accordingly" du profil 
	set nechant [ ajust_interv [ expr $nmilieu0-1 ] $nechant ]
	set deltax [ expr [ lindex $abscisses 1 ] -[ lindex $abscisses 0 ] ]
	# set ordmoyen [ lindex $ordonnees [ expr $nmilieu0 -1 ] ] 
	set ordmoyen [ expr .5*([ lindex $ordonnees [ expr $nmilieu0 -1 ] ] + [ lindex $ordonnees [ expr $nmilieu0 -2 ] ]) ]

	if { [ expr ( $nmilieu0 - 1 ) % $nechant ] !=0  } {
		set nmilieu [ expr (( $nmilieu0 -1 ) /$nechant + 1 ) * $nechant +1]
		for { set i 1 } { $i<= [ expr $nmilieu - $nmilieu0 ] } { incr i } {
	
			lappend abscisses [ expr [ lindex $abscisses [ expr $lenorig - 1 ] ] + $deltax ] 
			lappend ordonnees $ordmoyen
		}
	} else {
	set nmilieu $nmilieu0
	}
	set len [ llength $ordonnees ]
	#::console::affiche_resultat "longueur profil apres traitement effets de bord $len\n"
	#::console::affiche_resultat "longueur profil apres traitement effets de bord $len\n"

	set list_result [ spc_ajust_piecewiselinear_alg $abscisses $ordonnees $nechant $tauxRMS1 $demilargeur1 $period_max1 $larg_cosmet ]

	# set abscisses [ lindex $list_result  0 ]
	set riliss1 [ lindex $list_result  1 ]
	set nouvpoids1 [ lindex $list_result 2 ]
	#::console::affiche_resultat "longueur riliss : [llength $riliss1] - longueur poids=[ llength $nouvpoids1 ]\n"


	set list_result [ spc_ajust_piecewiselinear_alg $abscisses $ordonnees $nechant $tauxRMS2 $demilargeur2 $period_max2 $larg_cosmet ]

	#set abscisses [ lindex $list_result  0 ]
	set riliss2 [ lindex $list_result  1 ]
	set nouvpoids2 [ lindex $list_result 2 ]
	#::console::affiche_resultat "longueur riliss : [llength $riliss2] - longueur poids=[ llength $nouvpoids2 ]\n"

        

	#--- post traitement : revenir au nb d'ecahntillons avant passage de nmilieu0 a nmilieu
	set nordonnees1 [ lrange $riliss1 0 [ expr $nmilieu0 - 1 ] ]
	set nordonnees2 [ lrange $riliss2 0 [ expr $nmilieu0 - 1 ] ]
	
	set nordonnees3 [ list ]
	for {set i 0} {$i<$nmilieu0} {incr i} {
            set riliss1i [ lindex $nordonnees1 $i ]
	    set riliss2i [ lindex $nordonnees2 $i ]
	    set theta [ expr $i*1./$nmilieu0 ]
	    set riliss3i [ expr $riliss1i*(1.-$theta) + $riliss2i*$theta ]
            lappend nordonnees3 $riliss3i
        }
        #::console::affiche_resultat "longueur result 3 : [llength $nordonnees3]\n"

	set nouvpoids1 [ lrange $nouvpoids1 0 [ expr $nmilieu0 - 1 ] ]
	set nouvpoids2 [ lrange $nouvpoids2 0 [ expr $nmilieu0 - 1 ] ]	
	
        #--- mise a zero d'eventuels echantillons tres petits
	set zero 0.
	set seuil_min [ expr $intens_moy*$spcaudace(nulpcent)/100. ]
	for { set i 0 } {$i<$nmilieu0} {incr i} {
		if { [ lindex $nordonnees1 $i ] < $seuil_min } { set nordonnees1 [ lreplace $nordonnees1 $i $i $zero ] }
		if { [ lindex $nordonnees2 $i ] < $seuil_min } { set nordonnees2 [ lreplace $nordonnees2 $i $i $zero ] }
		if { [ lindex $nordonnees3 $i ] < $seuil_min } { set nordonnees3 [ lreplace $nordonnees3 $i $i $zero ] } 
	}
	
	
        #--- Rajout des valeurs nulles en dbut et en fin pour retrouver la dimension initiale du fichier de dpart :
	set len_ini $lenorig
	set len_cut $nmilieu0
	set nb_insert_sup [ expr $lenorig-$i_inf-$nmilieu0 ]
	for { set i 1 } { $i<=$nb_insert_sup } { incr i } {
	    set nordonnees1 [ linsert $nordonnees1 [ expr $len_cut+$i ] 0.0 ]
	    set nordonnees2 [ linsert $nordonnees2 [ expr $len_cut+$i ] 0.0 ]
	    set nordonnees3 [ linsert $nordonnees3 [ expr $len_cut+$i ] 0.0 ]
	    set nouvpoids1 [ linsert $nouvpoids1 [ expr $len_cut+$i ] 0.0 ]
	    set nouvpoids2 [ linsert $nouvpoids2 [ expr $len_cut+$i ] 0.0 ]
	}
	for { set i 0 } { $i<$i_inf } { incr i } {
	    set nordonnees1 [ linsert $nordonnees1 0 0.0 ]
	    set nordonnees2 [ linsert $nordonnees2 0 0.0 ]
	    set nordonnees3 [ linsert $nordonnees3 0 0.0 ]
	    set nouvpoids1 [ linsert $nouvpoids1 0 0.0 ]
	    set nouvpoids2 [ linsert $nouvpoids2 0 0.0 ]
	}

	set len [ llength $nordonnees1 ]
	::console::affiche_resultat "longueur profil piecewiselinear $len\n"
	
	
	
        #--- CrŽÃŽ©e les fichiers fits de sortie
	set abscisses $abscissesorig 
        set filename [ file rootname $filenamespc ]
        
        #--- CrŽÃŽ©e le fichier fits de sortie nŽÂŽ°1 :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set k 1
        foreach x $abscisses {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees1 [ expr $k-1 ] ]
            incr k
        }
        #-- Sauvegarde du rŽÃŽ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti-1$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv? sous ${filename}_conti-1$conf(extension,defaut)\n"


        #return ${filename}_conti-1

        #--- CrŽÃŽ©e le fichier fits de sortie nŽÂŽ°2 :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set k 1
        foreach x $abscisses {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees2 [ expr $k-1 ] ]
            incr k
        }
        #-- Sauvegarde du rŽÃŽ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti-2$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv? sous ${filename}_conti-2$conf(extension,defaut)\n"


        #return ${filename}_conti-2

                
        #--- CrŽÃŽ©e le fichier fits de sortie nŽÂŽ°3 :

        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set k 1
        foreach x $abscisses {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees3 [ expr $k-1 ] ]
            incr k
        }
        #-- Sauvegarde du rŽÃŽ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti-3$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv? sous ${filename}_conti-3$conf(extension,defaut)\n"



        #--- Affichage du graphe
        #--- Meth1
	::plotxy::clf
        ::plotxy::figure 1
        ::plotxy::plot $abscissesorig $nordonnees1 r 1
        ::plotxy::hold on
        ::plotxy::plot $abscissesorig $ordonneesorig ob 0
	::plotxy::hold on
        ::plotxy::plot $abscissesorig $nouvpoids1 g 0
        ::plotxy::plotbackground #FFFFFF
        ##::plotxy::xlabel "x"
        ##::plotxy::ylabel "y"
        ::plotxy::title "bleu : orginal ; rouge : interpolation lineaire par morceaux de largeur $nechant echantillons"


	::plotxy::figure 2
        ::plotxy::plot $abscissesorig $nordonnees2 r 1
        ::plotxy::hold on
        ::plotxy::plot $abscissesorig $ordonneesorig ob 0
	::plotxy::hold on
        ::plotxy::plot $abscissesorig $nouvpoids2 g 0
        ::plotxy::plotbackground #FFFFFF
        ##::plotxy::xlabel "x"
        ##::plotxy::ylabel "y"
        ::plotxy::title "bleu : orginal ; rouge : interpolation lineaire par morceaux de largeur $nechant echantillons"



	::plotxy::figure 3
        ::plotxy::plot $abscissesorig $nordonnees3 r 1
        ::plotxy::hold on
        ::plotxy::plot $abscissesorig $ordonneesorig ob 0

        ::plotxy::plotbackground #FFFFFF
        ##::plotxy::xlabel "x"
        ##::plotxy::ylabel "y"
        ::plotxy::title "bleu : orginal ; rouge : interpolation lineaire par morceaux de largeur $nechant echantillons"

      return ${filename}_conti-3
  } else {
      ::console::affiche_erreur "Usage: spc_pwlri fichier_profil.fit nombre_Žéchantillons ?visualisation (o/n)? ?pŽériode_coupure amplitude_rŽésidus pourcent_largeur_cosmŽétique?\n\n"
      return 0
  }
}
#****************************************************************#



####################################################################
# Procedure de lissage d'un profil spectral via une fonction 
# lineaire par morceaux
# Auteur : Patrick LAILLY
# Date creation : 07-03-2007
# Date modification : 23-07-2007
# Algo : Il est similaire a spc_pwlri a ceci pres qu'un seul fichier (au lieu de 3) est 
# sauvegarde : c'est celui qui correspond a l'image composite. Si l'on prefere sauvegarder 
# le fichier correspondant a l'image 1 (resp. l'image 2), il suffit de repeter 2 fois les parametres  
# (period_max et tauxRMS) ayant permis la creation de l'image 1 (resp. de l'image 2) 
# Le parametre visu permet de s'assurer visuellement de la qualite du resultat.
# Arguments : fichier .fit du profil de raie  nechant visu period_max1 period_max2 tauxRMS1 tauxRMS2 larg_cosmet (voir 
# definition ci-dessous)
####################################################################

proc spc_pwlfilter { args } {

    global conf
    global audace
    global spcaudace
    #set spcaudace(nulpcent) 100.


    # nechant est le nombre d'echantillons contenus dans un macro intervalle; ce parametre est modifie de facon a minimiser les effets de bord; il faut eviter la situation o?, apres modification de ce parametre, la fonction lin?aire par morceaux a un sommet localise dans une raie importante
    # visu (=o ou n) indique si l'on veut ou non une visualisation du resultat
    # period_max1 est la periode de coupure (en echantillons) donnant la frequence de coupure pour le 1er niveau de filtrage
    # period_max2 est la periode de coupure (en echantillons) donnant la frequence de coupure pour le 2eme niveau de filtrage    
    # tauxRMS1 specifie l'amplitude des residus (en % de la moyenne RMS) censes correspondre a des portions irregulieres du profil pour le 1er niveau de filtrage
    # tauxRMS2 specifie l'amplitude des residus (en % de la moyenne RMS) censes correspondre a des portions irregulieres du profil pour le 2e niveau de filtrage
    # larg_cosmet specifie la largeur de la reponse impulsionnelle du filtre cosmetique (rectangle) utilise en post traitement, cette largeur etant exprimee en % de la largeur nechant des macrointervalles

    # Exemples :
    # spc_pwlfilter resultat_division_150t.fit 50 n 11 51 70 50 100
    

    set nb_args [ llength $args ]
    if { $nb_args==8 } {
	    set filenamespc [ lindex $args 0 ]
	    set nechant [ lindex $args 1 ]
	    set visu [ lindex $args 2 ]
	    set period_max1 [ lindex $args 3 ]
	    set period_max2 [ lindex $args 4 ]
	    set tauxRMS1 [ lindex $args 5 ]
	    set tauxRMS2 [ lindex $args 6 ]
	    set larg_cosmet [ lindex $args 7 ]
		
	set demilargeur1 [ expr $period_max1/2 ]
	set demilargeur2 [ expr $period_max2/2 ]

        #--- Extraction des donnees :
        set contenu [ spc_fits2data $filenamespc ]
        set abscissesorig [ lindex $contenu 0 ]
        set ordonneesorig [ lindex $contenu 1 ]
        set lenorig [llength $ordonneesorig ]
 
        
	#-- elimination des termes nuls au bord
	set limits [ spc_findnnul $ordonneesorig ]
	set i_inf [ lindex $limits 0 ]
	set i_sup [ lindex $limits 1 ]
	set nmilieu0 [ expr $i_sup -$i_inf +1 ]
	#-- nmilieu0 est le nb d'echantillons non nuls dans la partie effective du profil
	set abscisses [ list ]
	set ordonnees [ list ]
	set intens_moy 0.
	for { set i $i_inf } { $i<=$i_sup } { incr i } {
  		set xi [ lindex $abscissesorig $i ]
  		set yi [ lindex $ordonneesorig $i ]
  		lappend abscisses $xi
  		lappend ordonnees $yi
  		set intens_moy [ expr $intens_moy +$yi ]
	}
	set intens_moy [ expr $intens_moy/($nmilieu0*1.) ]
	# intens_moy est la valeur moyenne de l'intensite
	::console::affiche_resultat "intensite moyenne : $intens_moy \n"


	#-- ajustement de nechant pour minimiser les effets de bord et prolongement "accordingly" du profil 
	set nechant [ ajust_interv [ expr $nmilieu0-1 ] $nechant ]
	set deltax [ expr [ lindex $abscisses 1 ] -[ lindex $abscisses 0 ] ]
	# set ordmoyen [ lindex $ordonnees [ expr $nmilieu0 -1 ] ] 
	set ordmoyen [ expr .5*([ lindex $ordonnees [ expr $nmilieu0 -1 ] ] + [ lindex $ordonnees [ expr $nmilieu0 -2 ] ]) ]

	if { [ expr ( $nmilieu0 - 1 ) % $nechant ] !=0  } {
		set nmilieu [ expr (( $nmilieu0 -1 ) /$nechant + 1 ) * $nechant +1]
		for { set i 1 } { $i<= [ expr $nmilieu - $nmilieu0 ] } { incr i } {
	
			lappend abscisses [ expr [ lindex $abscisses [ expr $lenorig - 1 ] ] + $deltax ] 
			lappend ordonnees $ordmoyen
		}
	} else {
	set nmilieu $nmilieu0
	}
	set len [ llength $ordonnees ]
	
	set list_result [ spc_ajust_piecewiselinear_alg $abscisses $ordonnees $nechant $tauxRMS1 $demilargeur1 $period_max1 $larg_cosmet ]

	# set abscisses [ lindex $list_result 0 ]
	set riliss1 [ lindex $list_result 1 ]
	set nouvpoids1 [ lindex $list_result 2 ]
	#- ::console::affiche_resultat "Longueur riliss : [llength $riliss1] - longueur poids=[ llength $nouvpoids1 ]\n"

	set list_result [ spc_ajust_piecewiselinear_alg $abscisses $ordonnees $nechant $tauxRMS2 $demilargeur2 $period_max2 $larg_cosmet ]

	#set abscisses [ lindex $list_result  0 ]
	set riliss2 [ lindex $list_result  1 ]
	set nouvpoids2 [ lindex $list_result 2 ]
	#::console::affiche_resultat "longueur riliss : [llength $riliss2] - longueur poids=[ llength $nouvpoids2 ]\n"
		

	#-- post traitement : eliminer la prolongation effectuee pour limiter les effets de bord
	set nordonnees1 [ lrange $riliss1 0 [ expr $nmilieu0 - 1 ] ]
	set nouvpoids1 [ lrange $nouvpoids1 0 [ expr $nmilieu0 - 1 ] ]
	#- ::console::affiche_resultat "Longueur nordonnees : [llength $nordonnees1]\n"
	set nordonnees2 [ lrange $riliss2 0 [ expr $nmilieu0 - 1 ] ]
	set nouvpoids2 [ lrange $nouvpoids2 0 [ expr $nmilieu0 - 1 ] ]
	
	set nordonnees3 [ list ]
	for {set i 0} {$i<$nmilieu0} {incr i} {
            set riliss1i [ lindex $nordonnees1 $i ]
	    set riliss2i [ lindex $nordonnees2 $i ]
	    set theta [ expr $i*1./$nmilieu0 ]
	    set riliss3i [ expr $riliss1i*(1.-$theta) + $riliss2i*$theta ]
            lappend nordonnees3 $riliss3i
        }
        #::console::affiche_resultat "longueur result 3 : [llength $nordonnees3]\n"
	
	#-- mise a zero d'eventuels echantillons tres petits
	set zero 0.
	set seuil_min [ expr $intens_moy*$spcaudace(nulpcent)/100. ]
	for { set i 0 } {$i<$nmilieu0} {incr i} {
		if { [ lindex $nordonnees3 $i ] < $seuil_min } { set nordonnees3 [ lreplace $nordonnees3 $i $i $zero ] }
	}
		
	#--- Rajout des valeurs nulles en dŽébut et en fin pour retrouver la dimension initiale du fichier de dŽépart :
	set len_ini $lenorig
	set len_cut $nmilieu0
	set nb_insert_sup [ expr $lenorig-$i_inf-$nmilieu0 ]
	for { set i 1 } { $i<=$nb_insert_sup } { incr i } {
	    	set nordonnees3 [ linsert $nordonnees3 [ expr $len_cut+$i ] 0.0 ]
	    	#set nouvpoids1 [ linsert $nouvpoids1 [ expr $len_cut+$i ] 0.0 ]    
	}
	for { set i 0 } { $i<$i_inf } { incr i } {
	    	set nordonnees3 [ linsert $nordonnees3 0 0.0 ]
	    	#set nouvpoids1 [ linsert $nouvpoids1 0 0.0 ]
	}

	::console::affiche_resultat "Nombre d'ŽélŽéments traitŽés : [llength $nordonnees1]\n"
	
        #--- CrŽÃŽ©e le fichier fits de sortie
	set abscisses $abscissesorig 
        set filename [ file rootname $filenamespc ]
        
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set k 1
        foreach x $abscisses {
		buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees3 [ expr $k-1 ] ]
            	incr k
        }
        #-- Sauvegarde du rŽÃŽ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauvŽé sous ${filename}_conti$conf(extension,defaut)\n"


	
	#--- Affichage du resultat :
	set testvisu 'n'
	if { $visu != $testvisu } {       
	::plotxy::clf
        ::plotxy::figure 1
        ::plotxy::plot $abscissesorig $nordonnees3 r 1
        ::plotxy::hold on
        ::plotxy::plot $abscissesorig $ordonneesorig ob 0
	#::plotxy::hold on
	#::plotxy::plot $abscissesorig $nouvpoids1 g 0
        ::plotxy::plotbackground #FFFFFF
        ##::plotxy::xlabel "x"
       	##::plotxy::ylabel "y"
        ::plotxy::title "bleu : orginal ; rouge : interpolation lineaire par morceaux de largeur $nechant echantillons"
        }
	return ${filename}_conti

    } else {
        ::console::affiche_erreur "Usage: spc_pwlfilter fichier_profil.fit nombre_Žéchantillons ?visualisation (o/n)? pŽériode_coupure1? pŽériode_coupure2? tauxRMS1? tauxRMS2? pourcent_largeur_cosmŽétique?\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure de lissage d'un profil spectral via une fonction polynomiale 
# Auteur : Patrick LAILLY
# Date creation : 07-02-2008
# Date modification : 6-04-2008
# Algo : ajustement par moindres carrŽés des donnŽées (rŽésultat division) par une fonction polynomiale 
# L'ajustement se fait en 2 Žétapes : dans la premiere on estime l'ordre de grandeur des rŽésidus (RMS des rŽésidus). 
# Ceci permet de dŽétecter les donnŽées aberrantes (et notammant les restes de raies) : celles-ci sont recherchees automatiquement (absence de specification du dernier parametre taux_RMS) ou 
# conformŽément aux spŽécifications de l'utilisateur (via la specification du dernier parametre 
# taux_RMS). Dans ce cas  les donnŽées aberrantes sont dŽéfinies  comme les donnŽées dont les rŽésidus # sont en valeur absolue supŽérieurs au RMS prŽécŽédemment calculŽé multipliŽé
# par le parametre tauxRMS.
# Les donnŽées aberrantes ne sont pas prises en compte dans la deuxiŽème Žétape du lissage qui 
# fournit alors la rŽéponse instrumentale.
# elim en pour mille...................................3 erniers argument optionels
#si derlier arg specifie :pas de calcul automatique et les 2 arguments precedents n'ont pas #d'imporatnce
# Le parametre visu_RMS permet de controler visuellement la procedure de selection automatique des # donnees aberrantes. Enfin le controle de la qualite du resultat est donne via la courbe verte :
# les Žéchantillons non pris en compte dans la deuxieme etape du lissage sont ceux pour lesquels la # la courbe verte prend une valeur nulle. 
# Arguments : fichier .fit du profil de raie ndeg visus elim nbiter tauxRMS 
####################################################################

proc spc_extractcont { args } {
    global conf
    global audace spcaudace
    #global spc_audace(nul_pcent_intens)
    set nul_pcent_intens .65


   # ndeg est le degrŽé choisi pour le polynome (ce nombre doit etre inferieur a 5)   
    
   # visu_RMS (=o ou n) indique si l'on veut ou non une visualisation du resultat 
   # tauxRMS specifie l'amplitude des residus (en % de la moyenne RMS) a partir de laquelle 
   # les echantillons sont consirŽérŽés comme associŽés Žà des rŽésidus de raies (cas ou 		# l'utilisateur ne veut pas faire appel a la procedure automatique et specifier lui meme
   # le seuil de tri des donnŽées aberrantes)
   # Exemples :
   # spc_polynfilter resultat_division.fit 4 n 15 20 200
    

    set nb_args [ llength $args ]
    if { $nb_args<=6 } {
       if { $nb_args == 1 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg $spcaudace(degpoly_cont)
          set visus "n"
          set elim 15
          set nbiter 20
       } elseif { $nb_args == 2 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus "n"
          set elim 15
          set nbiter 20
       } elseif { $nb_args == 3 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus [ lindex $args 2 ]
          set elim 15
          set nbiter 20
       } elseif { $nb_args==5 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus [ lindex $args 2 ]
          set elim [ lindex $args 3 ]
          set nbiter [ lindex $args 4 ]
       } elseif { $nb_args==6 } {
          set filenamespc [ lindex $args 0 ]
          set ndeg [ lindex $args 1 ]
          set visus [ lindex $args 2 ]
          set elim [ lindex $args 3 ]
          set nbiter [ lindex $args 4 ]
          set tauxRMS [ lindex $args 5 ] 
       } else {
          ::console::affiche_erreur "Usage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?taux pour 1000 d'echantillon eliminz (15)? ?nb iteration (20)? ?tauxRMS?\n\n"
          return ""
       }


       #--- Test des arguments :
	if { $ndeg>5 } {
           ::console::affiche_erreur "Le degrŽé du polynome doit etre <=5.\nUsage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?tauxRMS?\n\n"
           return 0
        }
	if { [ expr pow ([ expr (1000-$elim)*.001 ],$nbiter) ]<0.7 } {
           ::console::affiche_erreur "Le nb d'echantillons qui seront elimines est trop grand : diminuer elim et/ou nbiter.\nUsage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?tauxRMS?\n\n"
           return 0
        }
	    
        #--- Extraction des donnees :
        set contenu [ spc_fits2data $filenamespc ]
        set abscissesorig [ lindex $contenu 0 ]
        set ordonneesorig [ lindex $contenu 1 ]
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
	#set poids [ list ]
	set intens_moy 0.
	for { set i $i_inf } { $i<=$i_sup } { incr i } {
  		set xi [ lindex $abscissesorig $i ]
		set xxi [ expr ($xi-$lambdamin)/$ecartlambda ]
  		set yi [ lindex $ordonneesorig $i ]
  		lappend abscisses $xi
		lappend xx $xxi
  		lappend ordonnees $yi
		#lappend poids 1.
  		set intens_moy [ expr $intens_moy +$yi ]
        }
	set intens_moy [ expr $intens_moy/($nmilieu0*1.) ]
	set intens_moy_2 [ expr $intens_moy*.5 ]
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
	# initialisation des poids
	set poids [ list ]
	for { set i $i_inf } { $i<=$i_sup } { incr i } {
		lappend poids 1.
        }
	

	#-- calcul du 1er ajustement
	set result [ gsl_mfitmultilin $ordonnees $B $poids ]
        #-- extrait le resultat
        set coeffs [ lindex $result 0 ]
        set chi2 [ lindex $result 1 ]
        set covar [ lindex $result 2 ]
        set riliss1 [ gsl_mmult $B $coeffs ]
	set resid [ gsl_msub $ordonnees $riliss1 ]
	
	#-- evaluation et analyse des residus
	#::console::affiche_resultat "longueur B : [llength $B]\n"
        #::console::affiche_resultat "longueur riliss : [llength $riliss1]\n"
	set residtransp [ gsl_mtranspose $resid ]
	set rms_pat1  [ gsl_mmult $residtransp $resid ]
	set rms_pat [ lindex $rms_pat1 0 ]
	set rms_pat [ expr ($rms_pat/($nmilieu0*1.)) ]
	set rms_pat [expr sqrt($rms_pat)]
	set chi2init $chi2
	set constinit [ lindex $coeffs 0 ]
	set penteinit [ lindex $coeffs 1 ]
	set RMSinit $rms_pat
	set som_poids 0.
	set RMS_iter [ list ]
	set chi2_iter [ list ]
	set const_iter [ list ]
	set pente_iter [ list ]
	set num_iter [ list ]
	lappend RMS_iter 1.
	lappend chi2_iter 1.
	lappend const_iter 1.
	lappend pente_iter 1.
	lappend num_iter 0
	for {set i 0} {$i<$nmilieu0} {incr i} {
		set som_poids [ expr $som_poids + [ lindex $poids $i ] ]  
        }
	::console::affiche_resultat " $som_poids\n"
	::console::affiche_resultat "residu moyen (RMS) apres premiere etape : $rms_pat\n"
	
	if { $nb_args<=5 } {
		for { set niter 1 } { $niter<=$nbiter } { incr niter } {
			set resid_pond [ list ]
			for {set i 0} {$i<$nmilieu0} {incr i} {
				set residi [ expr abs([ lindex $poids $i ]*[ lindex $resid $i ]) ]
				lappend resid_pond $residi
                        }
		 
			set residtri [ lsort -decreasing -real $resid_pond ]
			set R [ list ]
			set nnn [ list ]
			#calcul fonction R(n)
			#doit pouvoir etre simplifie : on ne veut que le dernier terme de R
			for {set nn 0} {$nn<=$elim} {incr nn} {
				set n1 [ expr int($nn*$nmilieu0*.001)]
				#::console::affiche_resultat " $n1\n"
				lappend nnn $nn
				lappend R [ expr [ lindex $residtri $n1 ]*100./$rms_pat ]	
                        }

			
        		#selection du seuil de troncature
        		
                   if { $nb_args < 6 } {
			set tauxRMS [ lindex $R $elim ]
                   }
			#::console::affiche_resultat " $tauxRMS\n"
			#--calcul des nouveaux poids censes eliminer les residus de raies
			set seuilres [ expr $rms_pat*$tauxRMS*.01 ]
			#set poids [ list ]
			set som_poids 0.
			for {set i 0} {$i<$nmilieu0} {incr i} {
				#set poidsi [ expr $intens_moy*.5 ]
				set residi [ lindex $resid $i ]
				if { [ expr abs($residi) ]>=$seuilres } {
					set poids [ lreplace $poids $i $i 0. ] 
					#::console::affiche_resultat " $som_poids\n"
                                }
				set som_poids [ expr $som_poids + [ lindex $poids $i ] ]  
                        }
			#::console::affiche_resultat " $som_poids\n"
			set result [ gsl_mfitmultilin $ordonnees $B $poids ]
        		#-- extrait le resultat
        		set coeffs [ lindex $result 0 ]
        		set chi2 [ lindex $result 1 ]
        		set covar [ lindex $result 2 ]
        		set riliss1 [ gsl_mmult $B $coeffs ]
			set resid [ gsl_msub $ordonnees $riliss1 ]
			lappend chi2_iter [ expr $chi2/$chi2init ]
			#lappend RMS_iter [ expr $chi2/$chi2init ]
			lappend const_iter [ expr [ lindex $coeffs 0 ]/$constinit ]
			lappend pente_iter [ expr [ lindex $coeffs 1 ]/$penteinit ]
			lappend num_iter $niter
			}
		}
		
		
	if { $visus == "o" } {
	# graphique des QC		
			::plotxy::clf
			::plotxy::figure 1
        		::plotxy::plot $num_iter $chi2_iter r 0
        		::plotxy::hold on
        		::plotxy::plot $num_iter $const_iter b 0
        		::plotxy::hold on
        		::plotxy::plot $num_iter $pente_iter g 0
        		::plotxy::xlabel " iterations "
       			::plotxy::ylabel "evolution normalisee"
        		::plotxy::title "QC : chi2 (r), constante (b), pente (v)"	
        }

	
	#-- derniere etape du lissage
	for {set i 0} {$i<$nmilieu0} {incr i} {
		#set poidsi [ expr $intens_moy*.5 ]
		set residi [ lindex $resid $i ]
		if { [ expr abs($residi) ]>=$seuilres } {
			set poids [ lreplace $poids $i $i 0. ] 
                }
        }
	#calcul matrice B
	set B [ list ]
	::console::affiche_resultat "\n"
		
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
		
	#-- evaluation et analyse des residus
	set resid [ gsl_msub $ordonnees $riliss ]
	#::console::affiche_resultat "longueur B : [llength $B]\n"
        #::console::affiche_resultat "longueur riliss : [llength $riliss]\n"
	set residtransp [ gsl_mtranspose $resid]
	
	for { set i 0 } { $i<$nmilieu0 } { incr i } {
		set residi [ expr [ lindex $resid $i ]*[ lindex $poids $i ] ]
		set resid [ lreplace $resid $i $i $residi ]		
        }
		
	#il serait peut etre judicieux de faire intervenir le chi2

	set rms_pat1  [ gsl_mmult $residtransp $resid ]
	set rms_pat [ lindex $rms_pat1 0 ]
	set rms_pat [ expr ($rms_pat/($som_poids)) ]
	set rms_pat [expr sqrt($rms_pat)]
	::console::affiche_resultat "residu moyen (RMS) apres deuxieme etape : $rms_pat\n"
	
	#normalisation des poids pour la visu
	for { set i 0 } { $i<$nmilieu0 } { incr i } {
		set poidsi [ expr [ lindex $poids $i ]*$intens_moy ]
		set poids [ lreplace $poids $i $i $poidsi ]		
		
        }
	
	#-- mise a zero d'eventuels echantillons tres petits
	set zero 0.
	set seuil_min [ expr $intens_moy*$nul_pcent_intens/100. ]
	for { set i 0 } {$i<$nmilieu0} {incr i} {
		if { [ lindex $riliss $i ] < $seuil_min } { 
			set riliss [ lreplace $riliss $i $i $zero ] 
                }
        }
       

	#--- Rajout des valeurs nulles en dŽébut et en fin pour retrouver la dimension initiale du fichier de dŽépart :
	set len_ini $lenorig
	set len_cut $nmilieu0
	set nb_insert_sup [ expr $lenorig-$i_inf-$nmilieu0 ]
	for { set i 1 } { $i<=$nb_insert_sup } { incr i } {
	    	set riliss [ linsert $riliss [ expr $len_cut+$i ] 0.0 ]
	    	#set nouvpoids1 [ linsert $nouvpoids1 [ expr $len_cut+$i ] 0.0 ]    
        }
	for { set i 0 } { $i<$i_inf } { incr i } {
	    	set riliss [ linsert $riliss 0 0.0 ]
	    	#set nouvpoids1 [ linsert $nouvpoids1 0 0.0 ]
        }
	
	::console::affiche_resultat "Nombre d'ŽélŽéments traitŽés : [ llength $riliss ]\n"
	
	

       #--- CrŽÃŽ©e le fichier fits de sortie
	set abscisses $abscissesorig 
        set filename [ file rootname $filenamespc ]
        
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set k 1
        foreach x $abscisses {
           buf$audace(bufNo) setpix [list $k 1] [ lindex $riliss [ expr $k-1 ] ]
           incr k
        }
        #-- Sauvegarde du rŽÃŽ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauvŽé sous ${filename}_conti$conf(extension,defaut)\n"

	
      #--- Affichage du resultat :
	if { $visus == "o" } {
		#::plotxy::clf
        	::plotxy::figure 2
        	::plotxy::plot $abscissesorig $riliss r 1
		#::plotxy::plot $abscissesorig $riliss1 o 1
        	::plotxy::hold on
        	::plotxy::plot $abscissesorig $ordonneesorig ob 0
		::plotxy::hold on
		::plotxy::plot $abscissesorig $poids g 0
        	::plotxy::plotbackground #FFFFFF
        	##::plotxy::xlabel "x"
       		##::plotxy::ylabel "y"
        	::plotxy::title "bleu : original ; rouge : lissage par polynome de degre $ndeg"
        }

       #--- Traitement des resultats :
       return ${filename}_conti
    } else {
        ::console::affiche_erreur "Usage: spc_extractcont fichier_profil.fit ?degre polynome? ?visualisation (o/n)? ?tauxRMS?\n\n"
    }
}
#****************************************************************#



#================================ SPC_DRY ===========================================#


####################################################################
# Procedure de modelisation du spectre de l'eau 
# Auteur : Patrick LAILLY
# Date creation : 18-10-07
# Date modification : 05-06-08

# Description :
# Cette procedure cree un fichier .fit modelisant le spectre en absorbtion de l'eau sur un
# continuum d'amplitude 1. Ce fichier est echantillone en conformite avec le profil donne par 
# l'utilisateur. Il fait apparaitre des raies de l'eau creusees en conformite avec les rŽÃŽ©sultats
# donnŽÃŽ©s, sur le profil utilisateur, par spc_fwhmo. Le profil utilisateur doit bien 
# entendu avoir ete prealablement calibre sur les raies de l'eau...
# 
# Arguments : 
# nom fichier spectre utilisateur, 1ere (sous)liste resultat de fwhmo, 2eme (sous)liste 
# resultat de fwhmo, nom du fichier de sortie et, optionnel, nom du fichier contenant les 
# infos  (longueur d'onde centrale et intensite de chaque raie) sur le spectre de l'eau tel que 
# celui construit par Ch. Buil. Ce fichier est suppose etre dans le repertoire des images.

# Sorties : 
# fichier donnant le spectre de l'eau modelisŽÃŽ© (et donc pret a servir de denominateur 
# en vue de l'adoucissement des raies de l'eau)


# Remarques diverses
# On utilise ici une definition un peu particuliere (definition de fwhm) de la gaussienne  
# servant a modeliser les raies 
# Cette procŽÃŽ©dure, bien qu'autonome, est utilisŽÃŽ©e surtout appelŽÃŽ©e par spc_dryprofile.
# Reste a faire : gerer les largeurs de raies variables dans fichier Ch. Buil, calculer des 
# profondeurs de raies a partir d'estimation sur l'ensemble du spectre donc par une procŽÃŽ©dure 
# autre que fwhmo 

# Exemple : model_H2O profile.fit liste1 liste_mots_cles profil_eau.fit 

####################################################################


proc model_H2O  { args } {
   global conf
   global audace spcaudace
   set nbargs [ llength $args ]
   
   # extraction des parametres
   if { $nbargs == 4 } {
      set nom_fich_data [ lindex $args 0 ]
      set results1_fwhmo [ lindex $args 1 ]
      #set fwhm [ expr $fwhm*1. ]
      set liste_mots_cles [ lindex $args 2 ] 
      #set denom1 [ lindex $args 2 ]
      set nom_fich_output [ lindex $args 3 ]
      #set lambdamin [ lindex $args 4 ]
      #set nax1 [ lindex $args 5 ]
      #set dispersion [ lindex $args 6 ]
      set nom_fich_default "$spcaudace(reptelluric)/H2O5.dat"
   } elseif { $nbargs == 5 } {
      set nom_fich_data [ lindex $args 0 ]
      set results1_fwhmo [ lindex $args 1 ]
      #set fwhm [ expr $fwhm*1. ]
      set liste_mots_cles [ lindex $args 2 ] 
      #set denom1 [ lindex $args 2 ]
      set nom_fich_output [ lindex $args 3 ]
      #set lambdamin [ lindex $args 4 ]
      #set nax1 [ lindex $args 5 ]
      #set dispersion [ lindex $args 6 ]
      set nom_fich [ lindex $args 4 ]
   } else {
      affiche_erreur "usage: model_H2O nom_fich_input results1_fwhmo liste_mots_cles nom_fich_denom H2O5.dat \n\n"
   }

   set dispersion [ lindex $liste_mots_cles 0 ]
   set lambdamin [ lindex $liste_mots_cles 1 ]
   set nax1 [ lindex $liste_mots_cles 2 ]
   set lambda_best [ lindex $results1_fwhmo 0 ]
   set profondeur [ lindex $results1_fwhmo 1 ]
   # Ci-dessous il faut comprendre que fwhmo renvoie sigma2 (et non fwhm) meme si, a la
   # console, on parle de de fwhm exprimee en angstroems 
   set sigma2 [ lindex $results1_fwhmo 2 ]
   set sigma2 [ expr $sigma2 * $dispersion ]
   set sigma [ expr sqrt ( $sigma2 ) ]
   
   #set fwhm [ expr $sigma *  2. * sqrt ( 2. * log (2.) ) ]
   set fwhm [ expr $sigma * 2.354820045 ]
   ::console::affiche_resultat " fwhm modelisation $fwhm \n"
   # le parametre ci dessous est un coefficient d'adoucissement redondant avec le coeff. utilisŽÃŽ©
   # comme argument dans spc_dryprofile
   set coefadouc 1.025

	#calculs preliminaires
	set lambdamax [ expr $lambdamin + ($nax1 - 1 ) *$dispersion ]
	::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
	#rajouter test dispersion assez petite notamment par rapport a fwhm
	#set scalingfactor [ expr $fwhm/.1 ]
	set scalingfactor [ expr $fwhm/.1 ] 
	set cent 100.
	set cent [ expr $cent/$scalingfactor ]
	set mille 1000.
	set mille [ expr $mille/$scalingfactor ]
	set unsurcent [ expr 1./$cent ]
	set unsurmille [ expr 1./$mille ]
	# la philosophie : si la largeur des raies observŽÃŽ©es ŽÃŽ  l'instrument (cette largeur
	# caractŽÃŽ©rise la rŽÃŽ©solution du dit instrument) ŽÃŽ©tait de .1 Angstroems, on creerait um profil
	# modŽÃŽ¨le ŽÃŽ©chantillonŽÃŽ© au pas de 1/100 Angstroem (un tel ŽÃŽ©chantillonage est motivŽÃŽ© par un
	# souci de prŽÃŽ©cision) en ayant habilllŽÃŽ© les raies par des gaussiennes analytiques centrŽÃŽ©es
	# sur les longueurs d'ondes d'absorbtion arrondies au milliŽÃŽ¨me d'Angstroem. On voit donc
	# apparaitre 2 ŽÃŽ©chelles de travail (dans un rapport de 1 ŽÃŽ  10). Si la fwhm donnŽÃŽ©e par
	# l'instrument est autre, on utilise la meme stratŽÃŽ©gie ŽÃŽ  un facteur d'ŽÃŽ©chelle
	# (scalingfactor) prŽÃŽ¨s. Dans un deuxime temps on reechantillone modelise selon la dispersion
	# indiquee dans le header du profil utilisateur.
	
	set ideb [ expr int($lambdamin*$cent+$unsurmille) ]
	set ifin [ expr int($lambdamax*$cent+$unsurmille) +1 ]
	set nechant [ expr $ifin-$ideb ]
	set deltalambdaref [ expr ($nechant-1)/$cent ]
	set deltalambdainit [ expr $lambdamax -$lambdamin ]
	::console::affiche_resultat "dlamdref= $deltalambdaref dlambdinit= $deltalambdainit \n"

	#creation du profile de reference

	#calculs preliminaires
	set profileref [ list ]
	set lambdaref [ list ]
	# la longueur d'onde (exprimee en centieme d'angstroem si fwhm=.1A ) d'un 
	# echant de profileref est le nŽÂŽ° d'echant (avec la convention premier indice nul) + ideb

	for {set k 0} { $k<$nechant} { incr k } {
		lappend profileref 0.
		set lambda_i [ expr $lambdamin + $k * $unsurcent ]
		lappend lambdaref $lambda_i
	}
	set lprofileref [ llength $profileref ]
	::console::affiche_resultat " longueur en echantillons du profil de reference modelise= $lprofileref \n"
	# dans l'echelle de reference (fwhm=0.1A) ninterv_raie serait la largeur, exprimee en
	# millieme d'A , du support de la raie modelisee
	set ninterv_raie [ expr int (5.*$fwhm*$cent) ]
	set fwhm_old $fwhm
	
	if {[ expr $ninterv_raie%2 ]!=0 } {
		#::console::affiche_erreur "ninterv_raie cense etre pair !\n\n"
		#return 0
		set ninterv_raie  [ expr $ninterv_raie + 1 ]
		set fwhm [ expr $ninterv_raie * $unsurcent * .2 ]
		::console::affiche_resultat " fwhm modifiee : ancien : $fwhm_old ; nouveau : $fwhm \n"
		}
	set ninterv_raie_2 [ expr $ninterv_raie/2 ]
	set sigma [ expr $fwhm*$mille/2.354820045 ]


# calcul des raies elementaires sous forme de tableau a 2 indices k et i. Dans l'ŽÃŽ©chelle de
# rŽÃŽ©fŽÃŽ©rence l'ecnatillonage en i est au centieme d'angstrom, le passage d'une ligne du tableau
# a l'autre (indice k) correspond a un dŽÃŽ©calage de un millieme d'angstrom)
# Toujours dans l'ŽÃŽ©chelle de rŽÃŽ©fŽÃŽ©rence et en adoptant la convention de numŽÃŽ©rotation Tcl, les
# ŽÃŽ©chantillons, indexŽÃŽ©s par i de la liste k donnent une gaussienne centrŽÃŽ©e sur
# (i-nintervraie_2)*10-k en milliŽÃŽ¨mes d'Angstroems.
	set raies_elem [ list ]
	set denom1 -1.
	set denom2 [ expr 2. * $sigma * $sigma ]
	set denom2 [ expr 1. / $denom2 ]
	::console::affiche_resultat " denom1=$denom1 denom2=$denom2 \n"
	for {set k 0} { $k<10} { incr k } {
		set raie_k [ list ]
		set l [list ]

		for {set i 0} { $i<=$ninterv_raie } { incr i } {
			set intens_i [ expr $denom1*exp(-$denom2*(($i-$ninterv_raie_2)*10-$k)*(($i-$ninterv_raie_2)*10-$k)) ]
			lappend l $i
			lappend raie_k $intens_i
		#::console::affiche_resultat " k= $k i=$i intens_i=$intens_i \n"
		}
	
		lappend raies_elem $raie_k
	}



#construction du profil de reference

## === Lecture du fichier de donnees du profil de raie ===
	if { $nbargs == 4 } {
   	set inputfile [open "$nom_fich_default" r]
	} else {
   	set inputfile [open "$audace(rep_images)/$nom_fich" r]
	}
	set contents [split [read $inputfile] \n]
	close $inputfile



## === Extraction des numeros des pixels et des intensites ===
	set abscisses_lin [ list ]
	set abscisses [ list ]
	set intensites [ list ]
	set kk 0
	foreach ligne $contents {
		set abscisse [ lindex $ligne 0 ]	
		set intensite [ lindex $ligne 1 ]
		if { $abscisse!="" } {
	   	if {$abscisse>=$lambdamin&&$abscisse<=$lambdamax} {
	    	# on ajoute ici la contribution de chaque raie
	    		set peak [ expr int ($abscisse*$cent) ]
	    		set reste [ expr int ($abscisse*$mille)% 10] 
	    	#::console::affiche_resultat " reste= $reste peak= $peak  \n"	
				if {$reste>=5} {
			#::console::affiche_resultat " $reste \n"	
			#peak correspond donc l'echantillon ninter_raie/2 +1 + deb (a ideb pres)
					set deb1 [ expr $peak -$ninterv_raie_2 -1 -$ideb ]
					set fin1 [ expr $peak +$ninterv_raie_2 -1-$ideb ]
					set deb [ bm_max 0 $deb1 ]
					set fin [ bm_min $fin1 $lprofileref ]	
			#::console::affiche_resultat "  deb= $deb fin= $fin \n"
					for { set j $deb} { $j<=$fin } { incr j} {
						set jj [ expr $j- $deb ]
						set j1 [expr $j-1 ]
				# prendre en compte la contrib de raie(reste,jj)
				#::console::affiche_resultat " $reste $j $jj \n"	
						set contrib_j [ lindex $raies_elem $reste $jj ]
						set contrib_j [ expr [ lindex $profileref $j1 ] + $intensite*$contrib_j ]
						set profileref [ lreplace $profileref $j1 $j1 $contrib_j ]
					}
				} else {
			#::console::affiche_resultat " $reste \n"	
			#peak correspond donc l'echantillon ninter_raie/2 + deb (a ideb pres)
					set deb1 [ expr $peak -$ninterv_raie_2 -$ideb ]
					set fin1 [ expr $peak +$ninterv_raie_2 - $ideb ]
					set deb [ bm_max 0 $deb1 ]
					set fin [ bm_min $fin1 $lprofileref ]
					for { set j $deb} { $j<=$fin } { incr j} {
						set jj [ expr $j- $deb ]
						set j1 [expr $j-1 ]
				# prendre en compte la contrib de raie(reste,jj)
				#::console::affiche_resultat " $reste $j $jj \n"		
						set contrib_j [ lindex $raies_elem $reste $jj ]
						set contrib_j [ expr [ lindex $profileref $j1 ] + $intensite*$contrib_j ]
						set profileref [ lreplace $profileref $j1 $j1 $contrib_j ]
					}
				}
				
			}
		#lappend abscisses_lin [ expr $k+1 ]
		#lappend abscisses $abscisse
		#lappend intensites $intensite
			incr kk
		#::console::affiche_resultat " $kk \n"	
		}
	}
	::console::affiche_resultat " [ llength $lambdaref] [ llength $profileref ] \n"
	# calcul de l'amplitude du profil de reference pour lambda_best
	set ibestmoins [ expr int( ( $lambda_best - $lambdamin) / $unsurcent ) ]
	set ibestplus [ expr $ibestmoins + 1 ]
	set lambdamoins [ lindex $lambdaref $ibestmoins ]
	set lambdaplus [ lindex $lambdaref $ibestplus ]
	set intensmoins [ lindex $profileref $ibestmoins ]
	set intensplus [ lindex $profileref $ibestplus ]
	set num  [ expr  $intensplus - $intensmoins ]
	set den  [ expr $lambdaplus - $lambdamoins ]
	set pente [ expr $num / $den ]
	set ampli_best [ expr $intensmoins + $pente * ( $lambda_best - $lambdamoins ) ]
	
	# reechantillonage du fichier selon dispersion indiquee par l'utilisateur : on passe ainsi 
	# de (lambdaref, profileref) a (lambda, profile)
	set lambda [ list ]
	set profile [ list ]
	for { set i 0 } { $i<$nax1 } {incr i} {
		set dlambda [ expr $i * $dispersion ]
		lappend lambda [ expr $lambdamin + $dlambda ]
		set imoins [ expr ( $dlambda / $unsurcent ) ]
		set imoins [ expr int ( $imoins ) ]
		set iplus [ expr $imoins + 1 ]
		#::console::affiche_resultat "  $i $imoins \n"
		set lambdamoins [ lindex $lambdaref $imoins ]
		set lambdaplus [ lindex $lambdaref $iplus ]
		set intensmoins [ lindex $profileref $imoins ]
		set intensplus [ lindex $profileref $iplus ]
		set num  [ expr  $intensplus - $intensmoins ]
		set den  [ expr $lambdaplus - $lambdamoins ]
		set pente [ expr $num / $den ]
		set inten [ expr $intensmoins + $pente * ( $lambdamin + $dlambda - $lambdamoins ) ]
		lappend profile $inten		
	}
	set lambdamax [ expr $lambdamin + $dlambda ]
	::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
# creation du profil d'absorption en ajustant les amplitudes sur la profondeur donnee par fwhmo
	
	
	set ratio [ expr $profondeur / ( $ampli_best * $coefadouc ) ]
	for {set k 0} { $k < $nax1 } {incr k} {
		set contrib_k [ expr 1. - $ratio * [ lindex $profile $k ] ]
		set profile [ lreplace $profile $k $k $contrib_k ]
	}
		
	
	
   
	::console::affiche_resultat " [ llength $lambda] [ llength $profile ]  \n"
	
        #fin programme patrick
#debut programme benji
 #--- CrŽÃŽ©ation du fichier fits
 	set nbunit "float"
 	set nbunit1 "double"
   buf$audace(bufNo) setpixels CLASS_GRAY $nax1 1 FORMAT_FLOAT COMPRESS_NONE 0
   buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
   buf$audace(bufNo) setkwd [list "NAXIS1" $nax1 int "" ""]
   buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
        #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non ŽÃŽ©talonnŽÃŽ©
   set xdepart [ expr 1.0*[lindex $lambda 0]]
   buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart $nbunit1 "" "Angstrom"]
        #-- Dispersion
        #set dispersion $unsurcent
   buf$audace(bufNo) setkwd [list "CDELT1" $dispersion $nbunit1 "" "Angstrom/pixel"]
        #--- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
        # Une liste commence ŽÃŽ  0 ; Un vecteur fits commence ŽÃŽ  1
        #set intensite [ list ]
   ::console::affiche_resultat " lambdamin= $lambdamin  lambdamax= $lambdamax \n"
   for {set k 0} { $k < $nax1 } {incr k} {
            #append intensite [lindex $profileref $k]
            #::console::affiche_resultat "$intensite\n"
            #if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {}
   	buf$audace(bufNo) setpix [list [expr $k+1] 1] [lindex $profile $k ]
                #set intensite 0
   }
        #--- Sauvegarde du fichier fits ainsi crŽÃŽ©ŽÃŽ©
   buf$audace(bufNo) setkwd [ list "BSS_TELL" "yes" string "Tellurics lines correction" "" ]
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save "$audace(rep_images)/$nom_fich_output"
   # ::console::affiche_resultat " nom fichier sortie $nom_fich_output \n"
   buf$audace(bufNo) bitpix short
   return $nom_fich_output
}


# ProcŽÃŽ©dure de caractŽÃŽ©risation de raies de l'eau prŽÃŽ©sentes sur un profil
# Les raies sont supposŽÃŽ©es isolŽÃŽ©es (par opposition ŽÃŽ  une superposition de raies voisines et
# rendues non sŽÃŽ©parables par manque de rŽÃŽ©solution)
proc spc_fwhmo { args } {
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
            ::console::affiche_erreur "Usage: spc_fwhmo profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n"
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


        #--- CreŽÃƒŽÂŽ©e la liste de travail des raies de l'eau pour le spectre :
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
                #-- Meth 2 : centre gaussien
		set infosline [ buf$audace(bufNo) fitgauss $coords ]
		set xcenter [ lindex $infosline 1 ]
		set intensity [ lindex $infosline 0 ]
                set lambda_mes [ expr ($xcenter -1)*$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies $x
                lappend listexmesures $xcenter
                lappend listelmesurees [ list $lambda_mes $intensity ]
                lappend listeldiff $ldiff
            } else {
                set x  [ expr ($raie-$crval1)/$cdelt1 + 1 ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 +1 ) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 +1 ) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 2 : centre gaussien
		set infosline [ buf$audace(bufNo) fitgauss $coords ]
                set xcenter [ lindex $infosline 1 ]
                set intensity [ lindex $infosline 0 ]
                set lambda_mes [ expr  ($xcenter -1) *$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies    $x
                lappend listexmesures  $xcenter
                lappend listelmesurees [ list $lambda_mes $intensity ]
                lappend listeldiff     $ldiff

            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouvŽÃŽ©es :\n$listelmesurees\n"
        #::console::affiche_resultat "Liste des x mesures :\n$listexmesures\n"
        ::console::affiche_resultat "Liste des raies du catalogue :\n$listeraies\n"
        #::console::affiche_resultat "Liste des x du catalogue :\n$listexraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"


	#--- Selection de la plus profonde :
	set bestline [ lindex [ lsort -real -index 1 -decreasing $listelmesurees ] 0 ]

	#--- Mesure de la fwhm :
        #set dwidth [ expr 1.1*$ecart ]
        set dwidth $ecart
	set lambdabest [ lindex $bestline 0 ]
	set lambda_imax [ lindex $bestline 1 ]
	set ldeb [ expr $lambdabest-$dwidth ]
	set lfin [ expr $lambdabest+$dwidth ]

        # ::console::affiche_resultat "$bestline ; dw=$dwidth ; ldeb=$ldeb ; lfin=$lfin\n"
	set fwhm [ spc_fwhm $filename $ldeb $lfin a ]
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

	#--- Traitement des resultats :
       set results1 [ list $lambdabest $lambda_imax $fwhm ]
       set liste_mots_cles [ list $cdelt1 $crval1 $naxis1 ]
       set results [ list $results1 $liste_mots_cles ]
       
	return $results
    } else {
       ::console::affiche_erreur "Usage: spc_fwhmo profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
    }
}




####################################################################
# La procŽÃŽ©dure ci-dessous a ŽÃŽ©tŽÃŽ© testŽÃŽ©e sur un certain nombre de profils ŽÃŽ  haute resolution
# (Lhires 3 2400 traits). Son comportement sur des donnŽÃŽ©es ŽÃŽ  moins haute rŽÃŽ©solution (Lhires 3
# 1200 traits par exemple) reste ŽÃŽ  ŽÃŽ©tudier. Par ailleurs un bon rapport signal sur bruit ne
# nuit pas...



# Procedure d'elimination (adoucissement) dans un profil des raies du spectre de l'eau 
# Auteurs : Benjamin Mauclaire et Patrick LAILLY
# Date creation : 01-05-08
# Date modification : 05-06-08
# Cette procedure cree un fichier .fit adoucissant, dans un profil, les raies d'absorption 
# correspondant au spectre de l'eau. Le fichier resultat est echantillone en conformite avec le 
# profil donne par l'utilisateur.  Le profil utilisateur doit bien entendu avoir ete 
# prealablement calibre sur les raies de l'eau... En option, un coefficient permet de moduler 
# l'adoucissement (en multipliant le denominateur par ce coeff.), la valeur par defaut est 1.
# Arguments : nom fichier profil utilisateur, coefficient de modulation
# 
# Sorties : fichier profil sans les raies de l'eau (denomme comme le fichier de donnŽÃŽ©es avec le
# suffixe_rmo) et fichier "profil_eau.fit" Ce dernier fichier, utilisŽÃŽ© pour la division du
# profil utilisateur, peut etre visualise pour verification

# Remarque : le fichier denominateur est cense s'appeler profil_eau.fit, ŽÃŽªtre situŽÃŽ© dans le 
# rŽÃŽ©pertoire des images. Il est cense permettre la division par spc_div. L'utilisation
# habituelle est la fabrication de ce fichier par la procŽÃŽ©dure model_H2O. A prevoir : un 
# suffixe spŽÃŽ©cifique pour fichier apres ŽÃŽ©limination des raies de l'eau.
# Exemple : spc_dryprofile profile_input.fit .8
####################################################################

proc spc_dry { args } {
   global conf
   global audace

   set nbargs [ llength $args ]
   if { $nbargs == 1 } {
      set nom_fich_input [ file rootname [ lindex $args 0 ] ]
      set coef_profondeur 1.0
      set flag_rmo "o"
   } elseif { $nbargs == 2 } {
      set nom_fich_input [ file rootname [ lindex $args 0 ] ]
      set coef_profondeur [ lindex $args 1 ]
      set flag_rmo "o"
   } elseif { $nbargs == 3 } {
      set nom_fich_input [ file rootname [ lindex $args 0 ] ]
      set coef_profondeur [ lindex $args 1 ]
      set flag_rmo [ lindex 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_dry profil_de_raies_calibre_avec_eau ?coeff multiplicateur profondeur (1.0)? ?effacement_fichier_eau (o)?\n\n"
      return ""
   }

   # set nom_fich_output [ lindex $args 1 ]
   set results_fwhmo [ spc_fwhmo $nom_fich_input ]
   set results1_fwhmo [ lindex $results_fwhmo 0 ]

   set lambdabest [ lindex $results1_fwhmo 0 ]
   set imax [ expr $coef_profondeur*[ lindex $results1_fwhmo 1 ] ]
   set fwhm [ lindex $results1_fwhmo 2 ]
   set results1_fwhmo [ list $lambdabest $imax $fwhm ]

   set liste_mots_cles [ lindex $results_fwhmo 1 ]
   set nom_fich_denom "profil_eau"
   set nom_fich_denom [ model_H2O $nom_fich_input $results1_fwhmo $liste_mots_cles $nom_fich_denom ]
   set sortie_rmo [ spc_div $nom_fich_input $nom_fich_denom ]
   file copy -force "$audace(rep_images)/$sortie_rmo$conf(extension,defaut)" "$audace(rep_images)/${nom_fich_input}-rmo$conf(extension,defaut)" 
   file delete -force "$audace(rep_images)/$sortie_rmo$conf(extension,defaut)"
   if { $flag_rmo == "o" } {
      file delete -force "$audace(rep_images)/$nom_fich_denom$conf(extension,defaut)"
   }
   ::console::affiche_resultat "Profil nettoye des raies de l'eau sauve sous ${nom_fich_input}-rmo \n"
   return ${nom_fich_input}-rmo
}
