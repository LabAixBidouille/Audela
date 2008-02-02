


# Mise a jour $Id: spc_filters.tcl,v 1.4 2008-02-02 21:53:25 bmauclaire Exp $



##########################################################
# Procedure de lin�arisation de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 15-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, largeur de raie (optionnelle)
##########################################################

proc spc_linear { args } {

   global audace
   global conf
   set pourcent 0.95

   if {[llength $args] == 2} {
     set infichier [ lindex $args 0 ]
     set lraie [lindex $args 1 ]
     set fichier [ file rootname $infichier ]
     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save $audace(rep_images)/${fichier}_cont$conf(extension,defaut)
     buf$audace(bufNo) bitpix short
     ::console::affiche_resultat "Continuum sauv� sous ${fichier}_cont$conf(extension,defaut)\n"
   } elseif {[llength $args] == 1} {
     set fichier [ lindex $args 0 ]
     set lraie 20
     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save $audace(rep_images)/${fichier}_cont$conf(extension,defaut)
     buf$audace(bufNo) bitpix short
     ::console::affiche_resultat "Continuum sauv� sous $audace(rep_images)/${fichier}_cont$conf(extension,defaut)\n"
     return ${fichier}_cont
   } else {
     ::console::affiche_erreur "Usage : spc_linear profil_de_raies_fits ?largeur de raie?\n\n"
   }
}
##########################################################



##########################################################
# Procedure d'adoucissement de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 31-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, sigma gaussienne
##########################################################

proc spc_smooth { args } {

   global audace
   global conf
   set lraie 1

   if { [llength $args] <= 2 } {
       if { [llength $args] == 1 } {
	   set infichier [ lindex $args 0 ]
	   set sigma 0.9
       } elseif  { [llength $args] == 2 } {
	   set infichier [ lindex $args 0 ]
	   set sigma [ lindex $args 1 ]
       } else {
	   ::console::affiche_erreur "Usage : spc_smooth nom_fichier ?pourcentage?\n\n"
	   return 0
       }

       set fichier [ file rootname $infichier ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       #-- 060301 : la convolution par une gaussienne de largeur proche de 1 pixel donne un bon adoucissement
       # pourcent = 0.95
       # buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
       buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=$sigma"
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_smo$conf(extension,defaut)"
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "Spectre adoucis sauv� sous $audace(rep_images)/${fichier}_smo$conf(extension,defaut)\n"
       return ${fichier}_smo
   } else {
       ::console::affiche_erreur "Usage : spc_smooth nom_fichier ?pourcentage?\n\n"
   }
}
##########################################################


##########################################################
# Procedure d'adoucissement fort de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 16-10-2006
# Date de mise � jour : 16-10-06
# Arguments : fichier .fit du profil de raie, ?back_threshold?
##########################################################

proc spc_smooth2 { args } {

   global audace
   global conf
   set largeur 1

   if { [llength $args] <= 3 } {
       if { [llength $args] == 1 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set force 2
	   set back_threshold 0.8
       } elseif  { [llength $args] == 2 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set force [ lindex $args 1 ]
	   set back_threshold 0.8
       } elseif  { [llength $args] == 3 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set force [ lindex $args 1 ]
	   set back_threshold [ lindex $args 2 ]
       } else {
           ::console::affiche_erreur "Usage : spc_smooth2 profil_de_raies_fits ?force (1-6)? ?back_threshold (0-1)?\n\n"
	   return 0
       }

       #--- Calcul de l'adoucissement :
       buf$audace(bufNo) load "$audace(rep_images)/$infichier"
       for {set i 1} {$i<=$force} {incr i} {
	   buf$audace(bufNo) imaseries "BACK back_kernek=$largeur back_threshold=$back_threshold"
       }
       buf$audace(bufNo) save "$audace(rep_images)/${infichier}_smo$conf(extension,defaut)"

       #--- Nommage du r�sultat :
       ::console::affiche_resultat "Fichier tr�s adoucis sauv� sous ${infichier}_smo$conf(extension,defaut)\n"
       return ${infichier}_smo
   } else {
       ::console::affiche_erreur "Usage : spc_smooth2 profil_de_raies_fits ?force (1-6)? ?back_threshold (0-1)?\n\n"
   }
}
##########################################################




##########################################################
# Procedure d'adoucissement fort de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 28-03-2006
# Date de mise � jour : 28-03-06/25-08-06
# Arguments : fichier .fit du profil de raie, ?sigma gaussienne?
##########################################################

proc spc_bigsmooth { args } {

   global audace
   global conf
   set lraie 1

   if { [llength $args] <= 2 } {
       if { [llength $args] == 1 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set sigma 20
       } elseif  { [llength $args] == 2 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set sigma [ lindex $args 1 ]
       } else {
           ::console::affiche_erreur "Usage : spc_bigsmooth profil_de_raies_fits ?coefficient?\n\n"
	   return 0
       }
       set file_out [ spc_smooth $infichier 20 ]
       file rename -force "$audace(rep_images)/$file_out$conf(extension,defaut)" "$audace(rep_images)/${infichier}_bsmo$conf(extension,defaut)"
       ::console::affiche_resultat "Fichier tr�s adoucis sauv� sous ${infichier}_bsmo$conf(extension,defaut)\n"
       return ${infichier}_bsmo
   } else {
       ::console::affiche_erreur "Usage : spc_bigsmooth profil_de_raies_fits ?coefficient?\n\n"
   }
}
##########################################################




##########################################################
# Procedure d'adoucissement fort de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 16-10-2006
# Date de mise � jour : 16-10-06
# Arguments : fichier .fit du profil de raie, ?back_threshold?
##########################################################

proc spc_bigsmooth2 { args } {

   global audace
   global conf
   set largeur 10

   if { [llength $args] <= 2 } {
       if { [llength $args] == 1 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set back_threshold 0.8
       } elseif  { [llength $args] == 2 } {
	   set infichier [ file rootname [ lindex $args 0 ] ]
	   set back_threshold [ lindex $args 1 ]
       } else {
           ::console::affiche_erreur "Usage : spc_bigsmooth2 profil_de_raies_fits ?back_threshold?\n\n"
	   return 0
       }

       #--- Calcul de l'adoucissement :
       buf$audace(bufNo) load "$audace(rep_images)/$infichier"
       buf$audace(bufNo) imaseries "BACK back_kernek=$largeur back_threshold=$back_threshold"
       buf$audace(bufNo) imaseries "BACK back_kernek=$largeur back_threshold=$back_threshold"
       buf$audace(bufNo) imaseries "BACK back_kernek=$largeur back_threshold=$back_threshold"
       buf$audace(bufNo) imaseries "BACK back_kernek=$largeur back_threshold=$back_threshold"
       buf$audace(bufNo) imaseries "BACK back_kernek=$largeur back_threshold=$back_threshold"
       buf$audace(bufNo) save "$audace(rep_images)/${infichier}_bsmo$conf(extension,defaut)"

       #--- Nommage du r�sultat :
       ::console::affiche_resultat "Fichier tr�s adoucis sauv� sous ${infichier}_bsmo$conf(extension,defaut)\n"
       return ${infichier}_bsmo
   } else {
       ::console::affiche_erreur "Usage : spc_bigsmooth2 profil_de_raies_fits ?back_threshold?\n\n"
   }
}
##########################################################




####################################################################
#  Procedure de lineratisation par spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-10-2006
# Date modification : 14-10-2006
# Arguments : profil.fit � r��chantillonner, profil_modele.fit mod�le d'�chantilonnage
# Algo : spline cubique appliqu� au contenu d'un fichier fits
# Bug : a la premiere execution "# x vector "x" must be monotonically increasing"
####################################################################

proc spc_smooth0 { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set fichier_a_echant [ file rootname [ lindex $args 0 ] ]
	set contenu [ spc_fits2datadlin $fichier_a_echant ]

	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Une liste commence � 0 ; Un vecteur fits commence � 1
	blt::vector x($len) y($len) 
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses $i]
	    set y($i-1) [lindex $ordonnees $i]
	}
	x sort y

	#--- Cr�ation des abscisses des coordonnees interpol�es
	#set nabscisses [ lindex [ spc_fits2datadlin $fichier_modele ] 0]
	#set nlen [ llength $nabscisses ]
	set nlen [ expr int($len/1) ]
	blt::vector sx($nlen)
	for {set i 1} {$i <= $nlen} { incr i } { 
	    set sx($i-1) [lindex $abscisses $i]
	    lappend nabscisses [lindex $abscisses $i]
	}

	#--- Spline ---------------------------------------#
	blt::vector sy($nlen)
	# blt::spline natural x y sx sy
	# The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
	#blt::spline quadratic x y sx sy
	blt::spline natural x y sx sy

	#--- Exportation des vecteurs coordonn�es interpol�es en liste puis fichier dat
	for {set i 1} {$i <= $nlen} {incr i} { 
	    lappend nordonnees $sy($i-1)
	}
	set ncoordonnees [ list $nabscisses $nordonnees ]
	::console::affiche_resultat "Exportation au format fits des donn�es interpol�es sous ${fichier_a_echant}_line\n"
	#::console::affiche_resultat "$nabscisses\n"
	spc_data2fits ${fichier_a_echant}_line $ncoordonnees float

	#--- Affichage
	#destroy .testblt
	#toplevel .testblt
	#blt::graph .testblt.g 
	#pack .testblt.g -in .testblt
	#.testblt.g element create line1 -symbol none -xdata sx -ydata sy -smooth natural
	#-- Meth2
	set flag 0
	if { $flag==1 } {
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
	}
	#blt::table . .testblt
	return ${fichier_a_echant}_line
    } else {
	::console::affiche_erreur "Usage: spc_smooth2 profil_a_reechantillonner.fit\n\n"
    }
}
#****************************************************************#



####################################################################
# Proc�dure de filtrage par la m�thode de Stavitzky-Golay
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-02-2007
# Date modification : 11-02-2007
# Arguments : nom_profil_raies ?largeur_filtre? ?ordre_filtrage?
# Remarque : NON UTILISEE -> voir spc_smoothsg
####################################################################

proc spc_smooth3 { args } {
    global conf
    global audace
    #- Ordre du filtrage : 2,4 ou 6.

    if { [llength $args] <= 3 } {
	if { [llength $args] == 1 } {
	    set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
	    set largeur 16
	    set ordre_filtre 2
	} elseif { [llength $args] == 2 } {
	    set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
	    set largeur [ lindex $args 1 ]
	    set ordre_filtre 2
	} elseif { [llength $args] == 3 } {
	    set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
	    set largeur [ lindex $args 1 ]
	    set ordre_filtre [ lindex $args 3 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_smooth3 nom_profil_raies ?largeur_filtre? ?ordre_filtrage?\n"
	    return 0
	}

	#--- Donn�es � traiter et param�tres :
	set flargeur [ expr $largeur+1 ]
	set listevals [ spc_fits2data $filename ]
	set abscisses [ lindex $listevals 0 ]
	set ordonnees [ lindex $listevals 1 ]
	set len [ llength $ordonnees ]

	#--- Calcul les co�fficients du polyn�me de Stavitzky-Golay :
	set coefssavgol [ spc_savgol $flargeur $dlargeur $dlargeur 0 $ordre_filtre ]
	set len2 [ llength $coefssavgol ]

	#--- Ajustement des indices des vetceurs :
	if {1==0} {
//seek shift index for given case nl, nr, m (see savgol).
int *index = intvector(1, np);
index[1]=0;
int j=3;
for (i=2; i<=nl+1; i++) 
        {// index(2)=-1; index(3)=-2; index(4)=-3; index(5)=-4; index(6)=-5
    index[i]=i-j;
    j += 2;
        }
j=2;
for (i=nl+2; i<=np; i++) 
        {// index(7)= 5; index(8)= 4; index(9)= 3; index(10)=2; index(11)=1
    index[i]=i-j;
    j += 2;
        }
	}

	#--- Applique le polyn�me de filtrage aux valeurs :
	for {set i 0} {$i<$len} { incr i } {
	    set nordonnee 0.
	    for {set j 1} {$j<$flargeur} { incr j } {
		set it [ expr $i+$j ]
		if { $it >= 0 && $it < $len } {
		    set nordonnee [ expr $nordonnee+[ lindex $coefssavgol $j ]*[ lindex $ordonnee [ expr $i+$j ]]]
		}
	    }
	    lappend nordonnees $nordonnee
	}

	#--- Formatage du r�sultat :
	set filesavgol [ spc_data2fits $abscisses $nordonnees ]
	::console::affiche_resultat "Profil de raies filtr� par Stavitzky-Golay sauv� sous $filesavgol\n"
	return $filesavgol
    } else {
	::console::affiche_erreur "Usage: spc_smooth3 nom_profil_raies ?largeur_filtre? ?ordre_filtrage?\n"
    }
}
#***************************************************************************#




####################################################################
# Procedure de filtrage passse bas (fonction porte)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 5-12-2006
# Date modification : 5-12-2006
# Arguments : fichier fits, ?largeur du motif � gommer?
####################################################################

proc spc_passebas1 { args } {
    global conf
    global audace

    if { [llength $args] <= 2 } {
	if { [llength $args] == 2 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set largeur [ lindex $args 1 ]
	} elseif { [llength $args] == 1 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set largeur 25
	} else {
	    ::console::affiche_erreur "Usage: spc_passebas profil_de_raies.fit ?largeur motif � gommer(25)?\n\n"
	    return 0
	}

	set datas [ spc_fits2data $fichier ]
	set abscisses [ lindex $datas 0 ]
	set ordonnees [ lindex $datas 1 ]
	
	#--- Calcul de la moyenne locale pour chaque points (id. filtre passe bas) :
	set len [ llength $abscisses ]
	for {set i 0} {$i<$len} {incr i} {
	    if { $i<=[expr 2*$largeur] || $i>=[expr $len-2*$largeur ] } {
		lappend nordonnees [ lindex $ordonnees $i ]
	    } else {
		set nordonnee 0
		for {set j [expr $i-$largeur]} {$j<=[expr $i+$largeur]} {incr j} {
		    set nordonnee [ expr $nordonnee+[lindex $ordonnees $j] ]
		}
		#lappend nordonnees [ expr $nordonnee/(2*$largeur) ]
		lappend nordonnees [ expr $nordonnee/(2.04*$largeur) ]
	    }
	}

	#--- Sauvegarde du fichier :
	set file_out [ spc_data2fits ${fichier}_pbas [ list $abscisses $nordonnees ] ]
	::console::affiche_resultat "Profil filtr� (passe bas) sauv� sous ${fichier}_pbas\n"
	return $file_out
    } else {
	::console::affiche_erreur "Usage: spc_passebas profil_de_raies.fit ?largeur motif � gommer(25)?\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure de filtrage passe bas (fonction rectangulaire ou "Blackman")
#
# Auteur : Patrick LAILLY
# Date creation : 18-3-07
# Date modification : 22-3-07
# Arguments : fichier fits, ?demi-largeur du motif � gommer?, type de filtre
# Algo : application (par passage dans l'espace de Fourier) d'un filtre
# passe-bas de r�ponse impulsionnelle finie. Deux types de filtres sont
# propos�s : rectangle ou Blackman. Les donn�es filtr�es sont calcul�es
# sauf aux bords (dont l'�tendue est �gale � la demi-largeur du filtre).
# Sur ces bords on reproduit les donn�es d'entr�e.
####################################################################

proc spc_passebas { args } {
    global conf
    global audace

    if { [llength $args] <= 2 } {
	if { [llength $args] == 2 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set demilargeur [ lindex $args 1 ]
	} elseif { [llength $args] == 1 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set demilargeur 25
	} else {
	    ::console::affiche_erreur "Usage: spc_passebas profil_de_raies.fit ?demi-largeur motif � gommer(25)?\n\n"
	    return 0
	}

	#--- Initialisation des listes de valeurs :
	set datas [ spc_fits2data $fichier ]
	set abscisses_ini [ lindex $datas 0 ]
	set ordonnees_ini [ lindex $datas 1 ]

	#--- D�limination � l'intervalle des valeurs pertientes (sans 0 au d�but et en fin) :
	set limits [ spc_findnnul $ordonnees_ini ]
	set i_inf [ lindex $limits 0 ]
	set i_sup [ lindex $limits 1 ]
	set len_ini [ llength $ordonnees_ini ]
	set abscisses_cut [ list  ] 
	set ordonnees_cut [ list  ] 
	for { set i $i_inf } { $i<$i_sup } { incr i } {
	    lappend abscisses_cut [ lindex $abscisses_ini $i ]
	    lappend ordonnees_cut [ lindex $ordonnees_ini $i ]
	}
	set len_cut [ llength $abscisses_cut ]
	set abscisses $abscisses_cut
	set ordonnees $ordonnees_cut
	set nordonnees $ordonnees
	set nabscisses $abscisses


	#test sur la parit� du nombre d'�cchantillons
	set len [ llength $abscisses ]
	set nlen $len
	set dx [ expr [ lindex $abscisses [ expr $nlen-1 ] ]-[ lindex $abscisses [ expr $nlen-2 ] ] ]
	#::console::affiche_resultat "dx=$dx\n"

	if { [ expr $len%2 ]==0 } {
	    lappend nordonnees 0.
	    lappend nabscisses [ expr [ lindex $abscisses [ expr $nlen-1 ] ] + $dx ]
	    set nlen [ expr $nlen +1 ]
	}

	# initialisation du filtre
	set nlarg [ expr 2*$demilargeur+1 ]
	::console::affiche_resultat "demi-largeur du filtre=$demilargeur\n"
	set amplit [ expr 1./$nlarg ]
	set filtr [ list ]
	set temps ""
	set lignezeros ""
	for {set i 0} {$i<$nlen} {incr i} {
	    lappend filtr 0.
	    lappend lignezeros 0.
	    lappend temps [ expr $i*1. ]
	}
	#::console::affiche_resultat "nlen= $nlen\n"
	#::console::affiche_resultat "longueur filtre= [llength $filtr ]\n"
	for {set i 0} {$i<=$demilargeur} {incr i} {
	    set filtr [ lreplace $filtr $i $i $amplit ]
	}
	#::console::affiche_resultat "longueur filtre= [llength $filtr ]\n"
	set redemar [ expr $nlen-$demilargeur ]
	#::console::affiche_resultat "redemar=$redemar\n"
	for {set i $redemar} {$i<$nlen} {incr i} {
	    set filtr [ lreplace $filtr $i $i $amplit ]
	}
	set filtrfft [ gsl_fft $filtr $temps]
	set refiltrfft [ lindex $filtrfft 0 ]
	set imfiltrfft [ lindex $filtrfft 1 ]
	#if {$imfiltrfft != $lignezeros} {
	#::console::affiche_resultat "erreur part imag filtr=$imfiltrfft\n"
	#}
	::console::affiche_resultat "longueur partie imag fft= [ llength $imfiltrfft ]\n"
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
	#if {$imconvol != $lignezeros} {
	#::console::affiche_resultat "erreur part imag filtr=$imfiltrfft\n"
	#}
	::console::affiche_resultat "longueur r�sultat convolution= [ llength $reconvol ]\n"
	#�limination des effets de bord (remplacement par les valeurs d'origine)

	for {set i 0} {$i<$demilargeur} {incr i} {
	    set reconvol [ lreplace $reconvol $i $i [ lindex $ordonnees $i ] ]
	}
	for {set i [expr $len-$demilargeur ]} {$i<$len} {incr i} {
	    set reconvol [ lreplace $reconvol $i $i [ lindex $ordonnees $i ] ]
	}

	set nordonnees [ lrange $reconvol 0 [ expr $len-1 ] ]
	

	::console::affiche_resultat "longueur r�sultat filtrage= [ llength $nordonnees ]\n"
	#set nordonnees [ concat nordonnees1 nordonnees2 nordonnees3 ]


	if { 1==0 } {
	#--- Affichage du graphe
        #--- Meth1
        ::plotxy::clf
        ::plotxy::plot $abscisses $nordonnees r 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ##::plotxy::xlabel "x"
        ##::plotxy::ylabel "y"
        ::plotxy::title "bleu : orginal ; rouge : passe bas largeur $demilargeur"
    }


	#--- Rajout des valeurs nulles en d�but et en fin pour retrouver la dimension initiale du fichier de d�part :
	set nb_insert_sup [ expr $len_ini-$i_inf-1-$len_cut ]
	for { set i 1 } { $i<=$nb_insert_sup } { incr i } {
	    set nordonnees [ linsert $nordonnees [ expr $len_cut+$i ] 0.0 ]
	}
	for { set i 0 } { $i<$i_inf } { incr i } {
	    set nordonnees [ linsert $nordonnees 0 0.0 ]
	}


	#--- Sauvegarde du fichier :
	set file_out [ spc_data2fits ${fichier}_pbas [ list $abscisses_ini $nordonnees ] ]
	::console::affiche_resultat "Profil filtr� (passe bas) sauv� sous ${fichier}_pbas\n"
	return $file_out
    } else {
	::console::affiche_erreur "Usage: spc_passebas profil_de_raies.fit ?demi-largeur motif � gommer(25)?\n\n"
    }
}
#****************************************************************#




####################################################################
#  Procedure de filtrage (lissage) par l'algorithme Savitzky-Golay
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-03-2007
# Date modification : 03-03-2007
# Arguments : profil_de_raies ??
####################################################################

proc spc_smoothsg { args } {
    global audace
    global conf

    if { [llength $args] <= 3 } {
	if { [llength $args] == 1 } {
	    set fichier [ file tail [ file rootname [ lindex $args 0 ] ] ]
	    set demi_largeur 100
	    set degre 2
	} elseif { [llength $args] == 2 } {
	    set fichier [ file tail [ file rootname [ lindex $args 0 ] ] ]
	    set demi_largeur [ expr int(0.5*[ lindex $args 1 ]) ]
	    set degre 2
	} elseif { [llength $args] == 3 } {
	    set fichier [ file tail [ file rootname [ lindex $args 0 ] ] ]
	    set demi_largeur [ expr int(0.5*[ lindex $args 1 ]) ]
	    set degre [ lindex $args 2 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_smoothsg profil_de_raies_fits ?largeur_filtre? ?degre_filtrage (2,1,3)]?\n\n"
	    return ""
	}

	#--- Filtrage du profil :
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	buf$audace(bufNo) imaseries "SMOOTHSG NL=$demi_largeur NR=$demi_largeur LD=0 M=$degre"

	#--- Retour du r�sultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${fichier}_linsg"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Profil de raies export� sous ${fichier}_lings\n"
	return "${fichier}_linsg"
    } else {
	::console::affiche_erreur "Usage: spc_smoothsg profil_de_raies_fits ?[[?largeur_filtre?] ?ordre_filtrage (2,4)?]?\n\n"
    }
}
####################################################################




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

        #-- Initialisation des param�tres :
        set erreur 1.
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set len [llength $ordonnees ]

        #-- Param�tre d'ajustement resultat_division2400t_regulus400:
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
	# les calculs ci-dessous sont � la louche : il faudrati faire intervenir les poids
	set rms_pat1  [ gsl_mmult $residtransp $resid ]
	set rms_pat [ lindex $rms_pat1 0 ]
	set rms_pat [ expr ($rms_pat/($n*1.)) ]
	set rms_pat [expr sqrt($rms_pat)]
	::console::affiche_resultat "R�sidu moyen (RMS) : $rms_pat\n"
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
	#initialisastion de poids1 � la valeur 1
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

        #--- On rame�ne riliss et poids aux dumensions de d�part de l'image FITS :
        set riliss [ lrange $riliss 0 [ expr $len-1] ]
        set poids [ lrange $poids 0 [ expr $len-1] ]
        ::console::affiche_resultat "longueur riliss : [llength $riliss] - longueur poids=[ llength $poids ]\n"


        #--- Mise � z�ro des valeurs n�gatives de riliss et celle correspondant aux intensit�s initialies nulles (poids(i)==0) :
        set i 0
        foreach valriliss $riliss valpoids $poids {
            if { $valriliss<0. || $valpoids==0. } {
                set riliss [ lreplace $riliss $i $i 0. ]
            }
            incr i
        }


        #--- Cr�e le fichier fits de sortie
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


        #--- Sauvegarde du r�sultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajust_piecewiselinear fichier_profil.fit ?largeur intervalle (pixel)? ?largeur raie (30 angstroms)?\n\n"
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

	#--- Calcul des coefficients du polyn�me d'ajustement
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

	#--- Cr�e le fichier fits de sortie
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


        #--- Sauvegarde du r�sultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
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

	#--- Calcul des coefficients du polyn�me d'ajustement
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

	#--- Cr�e le fichier fits de sortie
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


        #--- Sauvegarde du r�sultat :
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
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

proc spc_ajust_piecewiselinear-1 { args } {
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

	#-- Initialisation des param�tres :
	set erreur 1.
	set contenu [ spc_fits2data $filenamespc ]
	set abscisses [ lindex $contenu 0 ]
	set ordonnees [ lindex $contenu 1 ]
	set len [llength $ordonnees ]

	#-- Param�tre d'ajustement :
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

	#--- On rame�ne riliss et poids aux dumensions de d�part de l'image FITS :
	set riliss [ lrange $riliss 0 [ expr $len-1] ]
	set poids [ lrange $poids 0 [ expr $len-1] ]
	::console::affiche_resultat "longueur riliss : [llength $riliss] - longueur poids=[ llength $poids ]\n"


	#--- Mise � z�ro des valeurs n�gatives de riliss et celle correspondant aux intensit�s initialies nulles (poids(i)==0) :
	set i 0
	foreach valriliss $riliss valpoids $poids {
	    if { $valriliss<0. || $valpoids==0. } {
		set riliss [ lreplace $riliss $i $i 0. ]
	    }
	    incr i
	}


	#--- Cr�e le fichier fits de sortie
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


        #--- Sauvegarde du r�sultat :
	#buf$audace(bufNo) bitpix float
	#buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
	#buf$audace(bufNo) bitpix short
	#::console::affiche_resultat "Fichier fits sauv� sous ${filenamespc}_lin$conf(extension,defaut)\n"
	#return ${filenamespc}_lin
    } else {
	::console::affiche_erreur "Usage: spc_ajust_piecewiselinear fichier_profil.fit ?largeur?\n\n"
    }
}
#****************************************************************#
