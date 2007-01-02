
# Procédures d'exploitation astrophysique des spectres
# A130 : source $audace(rep_scripts)/spcaudace/spc_astrophys.tcl
# A140 : source [ file join $audace(rep_plugin) tool spectro spcaudace spc_astrophys.tcl ]

#************* Liste des focntions **********************#
#
# spc_vradiale : calcul la vitesse radiale à partir de la FWHM de la raie modélisée par une gaussienne
# spc_vexp : calcul la vitesse d'expansion à partir de la FWHM de la raie modélisée par une gaussienne
# spc_vrot : calcul la vitesse de rotation à partir de la FWHM de la raie modélisée par une gaussienne
# spc_npte : calcul la température électronique d'une nébuleuse
# spc_npne : calcul la densité électronique d'une nébuleuse
# spc_ne : calcul de la densité électronique. Fonction applicable pour les nébuleuses à spectre d'émission.
# spc_te : calcul de la température électronique. Fonction applicable pour les nébuleuses à spectre d'émission.
#
##########################################################



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-07-2006
# Date de mise à jour : 13-07-2006
# Arguments : delta_lambda lambda
##########################################################

proc spc_vradiale { args } {

   global audace
   global conf

   if { [llength $args] == 2 } {
       set delta_lambda [ lindex $args 0 ]
       set lambda [lindex $args 1 ]
       
       set vrad [ expr 299792.458*$delata_lambda/lambda ]
       ::console::affiche_resultat "La vitesse radiale de l'objet est : $vrad km/s\n"
       return $vrad
   } else {
       ::console::affiche_erreur "Usage: spc_vradiale delta_lambda lambda\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-2005
# Arguments : I_5007 I_4959 I_4363
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.104.
##########################################################

proc spc_npte { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
     set I_5007 [ lindex $args 0 ]
     set I_4959 [ expr int([lindex $args 1 ]) ]
     set I_4363 [ expr int([lindex $args 2]) ]

     set R [ expr ($I_5007+$I_4959)/$I_4363 ]
     set Te [ expr (3.29*1E4)/(log($R/8.30)) ]
     ::console::affiche_resultat "Le température électronique de la nébuleuse est : $Te Kelvin\n"
     return $Te
   } else {
     ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363\n\n"
   }

}
#*******************************************************************************#


##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-2005
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
##########################################################

proc spc_npne { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set Te [ lindex $args 0 ]
     set I_6584 [ lindex $args 1 ]
     set I_6548 [ expr int([lindex $args 2 ]) ]
     set I_5755 [ expr int([lindex $args 3]) ]

     set R [ expr ($I_6584+$I_6548)/$I_5755 ]
     set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt($Te)*10^(10800/$Te))/$R-1) ]
     ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne Kelvin\n"
     return $Ne
   } else {
     ::console::affiche_erreur "Usage: spc_npne Te I_6584 I_6548 I_5755\n\n"
   }

}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 10-05-2006
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_ewcourbe { args } {

    global audace
    global conf
	global tcl_platform
    set ewfile "ewcourbe"
	set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
	set ext ".dat"

    if {[llength $args] == 4} {
	set nom_generic [ lindex $args 0 ]
	set lambda [lindex $args 1 ]
	set largeur_raie [lindex $args 2 ]
	set type_raie [lindex $args 3 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ glob -dir $audace(rep_images) ${nom_generic}*$conf(extension,defaut) ]

	foreach fichier $fileliste {
	    set fichier [ file tail $fichier ]
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
	    # Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
	    lappend ldates [ expr int($date*10000.)/10000.-50000. ]
	    # lappend ldates [ expr $date-50000. ]
	    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	    set ldeb [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
	    set disp [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

	    set ldeb [ expr $lambda-0.5*$largeur_raie ]
	    set lfin [ expr $lambda+0.5*$largeur_raie ]
	    lappend list_ew [ spc_ew $fichier $ldeb $lfin $type_raie ]
	}

	#--- Création du fichier de données
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Création du script de tracage avec gnuplot
	set titre "Evolution de la largeur equivalente au cours du temps"
	set legendey "Largeur equivalente (A)"
	set legendex "Date (JD-50000)"
	set repertoire_gp [ file join $audace(rep_scripts) spcaudace gp ]
	#exec echo "call \"${repertoire_gp}/gpx11.cfg\" \"${spcfile}$ext\" \"$titre\" * * $xdeb $xfin $pas \"${spcfile}.png\" \"$legendex\" \"$legendey\" " > $repertoire_gp/run_gp
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"${repertoire_gp}/gp_points.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * * \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
	close $file_id2
	if { $tcl_platform(os)=="Linux" } {	
	    set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	} else {
	    #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
	    set answer [ catch { exec ${repertoire_gp}/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	}
	#set file_id3 [open "$audace(rep_images)/trace_gp.bat" w+]
	#puts $file_id3 "gnuplot \"${ewfile}.gp\" "
	#close $file_id3
	## exec gnuplot $repertoire_gp/run_gp
	#::console::affiche_resultat "\nExécuter dans un terminal : trace_gp.bat\n"

    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe nom_générique_profils_normalisés_fits lambda_raie largeur_raie a/e (absorption/émission)\n\n"
    }
}
#*******************************************************************************#



##########################################################
# Procedure de détermination de la largeur équivalente d'une raie spectrale modelisee par une gaussienne. 
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21/12/2005-18/04/2006
# Arguments : fichier .fit du profil de raie, l_debut (wavelength), l_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_ew { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       set fichier [ lindex $args 0 ]
       set ldeb [ expr int([lindex $args 1 ]) ]
       set lfin [ expr int([lindex $args 2]) ]
       set type [ lindex $args 3 ]

       #--- Conversion des longeurs d'onde/pixels en pixels 
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
       set xfin [ expr int(($lfin-$crval)/$cdelt) ]
       #-- coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
       set hauteur 1
       #-- pas mal : 26
       buf$audace(bufNo) scale [list 1 $hauteur]
       set listcoords [list $xdeb 1 $xfin $hauteur]

       #--- Mesure de la FWHM, I_continuum et de Imax
       if { [string compare $type "a"] == 0 } {
	   # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	   buf$audace(bufNo) mult -1.0
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   # Inverse de nouveau le spectre pour le rendre comme l'original
	   buf$audace(bufNo) mult -1.0
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ lindex $lreponse 0 ]
       } elseif { [string compare $type "e"] == 0 } {
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ expr $icontinuum+[ lindex $lreponse 0 ] ]
       }
       set sigma [ expr $fwhm/sqrt(8.0*log(2.0)) ]
       ::console::affiche_resultat "Imax=$imax, Icontinuum=$icontinuum, FWHM=$fwhm, sigma=$sigma.\n"

       #--- Calcul de EW
       #set aeqw [ expr sqrt(acos(-1.0)/log(2.0))*0.5*$fwhm ]
       # set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*$i_continuum ]
       #- 1.675x-0.904274 : coefficent de réajustement par rapport a Midas.
       #set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*1.6751-1.15 ]
       # Klotz : 060416, A=imax*sqrt(pi)*sigma, GOOD
       set aeqw [ expr sqrt(acos(-1.0)/(8.0*log(2.0)))*$fwhm*$imax ]
       # A=sqrt(sigma*pi)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(sqrt(8.0*log(2.0)))) ]
       # A=sqrt(sigma*pi/2) car exp(-x/sigma)^2 et non exp(-x^2/2*sigma^2)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(2*sqrt(8.0*log(2.0)))) ]
       # A=sqrt(pi/2)*sigma, vérité calculé pour exp(-x/sigma)^2
       #set aeqw [ expr sqrt(acos(-1.0)/(16.0*log(2.0)))*$fwhm ]

       if { [string compare $type "a"] == 0 } {
	   set eqw $aeqw
       } elseif { [string compare $type "e"] == 0 } {
	   set eqw [ expr (-1.0)*$aeqw ]
       }
       ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw angstroms\n"
       return $eqw
   } else {
       ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#

proc spc_ew_170406 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       set fichier [ lindex $args 0 ]
       set ldeb [ expr int([lindex $args 1 ]) ]
       set lfin [ expr int([lindex $args 2]) ]
       set type [ lindex $args 3 ]

       #--- Mesure de la FWHM, I_continuum et de Imax
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
       set xfin [ expr int(($lfin-$crval)/$cdelt) ]
       set listcoords [list $xdeb 1 $xfin 1]
       if { [string compare $type "a"] == 0 } {
	   # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	   buf$audace(bufNo) mult -1.0
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   # Inverse de nouveau le spectre pour le rendre comme l'original
	   buf$audace(bufNo) mult -1.0
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ lindex $lreponse 0 ]
       } elseif { [string compare $type "e"] == 0 } {
	   set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	   set fwhm [ expr $cdelt*[ lindex $lreponse 2 ] ]
	   set icontinuum [ lindex $lreponse 3 ]
	   set imax [ expr $icontinuum+[ lindex $lreponse 0 ] ]
       }
       set sigma [ expr $fwhm/sqrt(8.0*log(2.0)) ]
       ::console::affiche_resultat "Imax=$imax, Icontinuum=$icontinuum, FWHM=$fwhm, sigma=$sigma.\n"

       #--- Calcul de EW
       #set aeqw [ expr sqrt(acos(-1.0)/log(2.0))*0.5*$fwhm ]
       # set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*$i_continuum ]
       #- 1.675x-0.904274 : coefficent de réajustement par rapport a Midas.
       #set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*1.6751-1.15 ]
       # Klotz : 060416, A=imax*sqrt(pi)*sigma, GOOD
       set aeqw [ expr sqrt(acos(-1.0)/(8.0*log(2.0)))*$fwhm*$imax ]
       # A=sqrt(sigma*pi)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(sqrt(8.0*log(2.0)))) ]
       # A=sqrt(sigma*pi/2) car exp(-x/sigma)^2 et non exp(-x^2/2*sigma^2)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(2*sqrt(8.0*log(2.0)))) ]
       # A=sqrt(pi/2)*sigma, vérité calculé pour exp(-x/sigma)^2
       #set aeqw [ expr sqrt(acos(-1.0)/(16.0*log(2.0)))*$fwhm ]

       if { [string compare $type "a"] == 0 } {
	   set eqw $aeqw
       } elseif { [string compare $type "e"] == 0 } {
	   set eqw [ expr (-1.0)*$aeqw ]
       }
       ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw angstroms\n"
       return $eqw
   } else {
       ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#

proc spc_ew_211205 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ expr int([lindex $args 1 ]) ]
     set lfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     #buf$audace(bufNo) load $fichier
     set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
     set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
     set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
     set xfin [ expr int(($lfin-$crval)/$cdelt) ]

     set listcoords [list $xdeb 1 $xfin 1]
     if { [string compare $type "a"] == 0 } {
	 # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	 buf$audace(bufNo) mult -1.0
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	 set flag 1
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	 set flag 0
     }
     set I_continum [ lindex $lreponse 7 ]
     # Attention, $lreponse 2 est en pixels
     set if0 [ expr ([ lindex $lreponse 2 ]*$cdelt+$crval)*.601*sqrt(acos(-1)) ]
     set intensity [ expr [ lindex $lreponse 0 ]*$if0 ]
     if { $flag == 1 } {
	 set eqw [ expr (-1.0)*$intensity/$I_continum ]
     } else {
	 set eqw [ expr $intensity/$I_continum ]
     }
     ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw angstroms\n"
     return $eqw

   } else {
     ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



####################################################################
# Procédure de calcul d'intensité d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_ew2 { args } {
    global conf
    global audace

    if { [llength $args] == 3 } {
	set filename [ lindex $args 0 ]
	set xdeb [ lindex $args 1 ]
	set xfin [ lindex $args 2 ]

	#--- Conversion des données en liste :
	set listevals [ spc_fits2data $filename ]
	set xvals [ lindex $listevals 0 ]
	set yvals [ lindex $listevals 1 ]

	foreach xval $xvals yval $yvals {
	    if { $xval>=$xdeb && $xval<=$xfin } {
		lappend xsel $xval
		lappend ysel $yval
	    }
	}

	#--- Calcul de l'aire sous la raie :
	set valsselect [ list $xsel $ysel ]
	set intensity [ spc_aire $valsselect ]
	set ew [ expr $intensity-($xfin-$xdeb) ]

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set deltal [ expr abs($xfin-$xdeb) ]
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}


	#--- Affichage des résultats :
	::console::affiche_resultat "La largeur équivalente sur ($xdeb-$xfin) vaut $ew anstrom(s)\nsigma(EW)=$sigma angstrom\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_ew2 nom_profil_raies lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#


####################################################################
# Procédure de calcul d'intensité d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew { args } {
    global conf
    global audace
    set precision 0.01

    if { [llength $args] == 2 } {
	set filename [ file rootname [ lindex $args 0 ] ]
	set lambda_raie [ lindex $args 1 ]

	#--- Valeur par defaut des bornes :
	set lambda_deb [ expr $lambda_raie-20 ]
	set lambda_fin [ expr $lambda_raie+20 ]

	#--- Extraction des valeurs :
	set listevals [ spc_fits2data $filename ]
	set lambdas [ lindex $listevals 0 ]
	set intensities [ lindex $listevals 1 ]
	set len [ llength $lambdas ]

	#--- Trouve l'indice de la raie recherche dans la liste
	set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]
	# ::console::affiche_resultat "Indice de la raie : $i_lambda\n"

	#--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
	for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-1.0 ]<=$precision } {
		set lambda_fin [ lindex $lambdas $i ]
		break
	    }
	}

	#--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
	for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-1.0 ]<=$precision } {
		set lambda_deb [ lindex $lambdas $i ]
		break
	    }
	    #::console::affiche_resultat "$diff\n"
	}

	#--- Détermination de la largeur équivalente :
	set ew [ spc_ew2 $filename $lambda_deb $lambda_fin ]
	set deltal [ expr abs($lambda_fin-$lambda_deb) ]
	::console::affiche_resultat "Largeur d'intégration pour EW : $deltal\n"

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

	#--- Affichage des résultats :
	::console::affiche_resultat "Bornes de calcul de EW : $lambda_deb, $lambda_fin\n\n"
	::console::affiche_resultat "La largeur équivalente EW vaut $ew anstrom(s)\n"
	::console::affiche_resultat "SNR=$snr\n Sigma(EW)=$sigma angstrom\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_autoew nom_profil_raies lambda_raie\n"
    }
}
#***************************************************************************#

#-- CAlcul incertitude sur EW
#- le choix de lambda1 et lambda 2 est critique car il conditionne tout : largeur equivalente et incertitude;
#-idem pour les parametres de lissage qui te permettent de separer signal et bruit