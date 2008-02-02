

# Mise a jour $Id: spc_filter2.tcl,v 1.3 2008-02-02 21:53:25 bmauclaire Exp $


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

####################################################################
# Procedure de calcul de la matrice B utilisee dans les algorithmes de 
# lissage par des fonctions linÃ©aires morceaux (spc_pwl...)
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
	
	
	
        #--- CrÃ©e les fichiers fits de sortie
	set abscisses $abscissesorig 
        set filename [ file rootname $filenamespc ]
        
        #--- CrÃ©e le fichier fits de sortie nÂ°1 :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set k 1
        foreach x $abscisses {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees1 [ expr $k-1 ] ]
            incr k
        }
        #-- Sauvegarde du rÃ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti-1$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv? sous ${filename}_conti-1$conf(extension,defaut)\n"


        #return ${filename}_conti-1

        #--- CrÃ©e le fichier fits de sortie nÂ°2 :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set k 1
        foreach x $abscisses {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees2 [ expr $k-1 ] ]
            incr k
        }
        #-- Sauvegarde du rÃ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti-2$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv? sous ${filename}_conti-2$conf(extension,defaut)\n"


        #return ${filename}_conti-2

                
        #--- CrÃ©e le fichier fits de sortie nÂ°3 :

        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set k 1
        foreach x $abscisses {
	    buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees3 [ expr $k-1 ] ]
            incr k
        }
        #-- Sauvegarde du rÃ©sultat :
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
      ::console::affiche_erreur "Usage: spc_pwlri fichier_profil.fit nombre_échantillons ?visualisation (o/n)? ?période_coupure amplitude_résidus pourcent_largeur_cosmétique?\n\n"
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
		
	#--- Rajout des valeurs nulles en début et en fin pour retrouver la dimension initiale du fichier de départ :
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

	::console::affiche_resultat "Nombre d'éléments traités : [llength $nordonnees1]\n"
	
        #--- CrÃ©e le fichier fits de sortie
	set abscisses $abscissesorig 
        set filename [ file rootname $filenamespc ]
        
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set k 1
        foreach x $abscisses {
		buf$audace(bufNo) setpix [list $k 1] [ lindex $nordonnees3 [ expr $k-1 ] ]
            	incr k
        }
        #-- Sauvegarde du rÃ©sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauvé sous ${filename}_conti$conf(extension,defaut)\n"


	
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
        ::console::affiche_erreur "Usage: spc_pwlfilter fichier_profil.fit nombre_échantillons ?visualisation (o/n)? période_coupure1? période_coupure2? tauxRMS1? tauxRMS2? pourcent_largeur_cosmétique?\n\n"
    }
}

