####################################################################################
#
# Procedures d'opérations sur les spectres
# Auteur : Benjamin MAUCLAIRE
# Date de création : 01-04-2006
# Chargement en script : source $audace(rep_scripts)/spcaudace/spc_operations.tcl
#
#####################################################################################



##########################################################
# Procedure de normalisation de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 15-08-2005
# Date de mise à jour : 15-08-2005
# Arguments : fichier .fit du profil de raie, largeur de raie (optionnelle)
##########################################################

proc spc_norma { args } {

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
     buf$audace(bufNo) save "$audace(rep_images)/${fichier}_norm$conf(extension,defaut)"
     ::console::affiche_resultat "Profil normalisé sauvé sous ${fichier}_norm$conf(extension,defaut)\n"
   } elseif {[llength $args] == 1} {
     set fichier [ lindex $args 0 ]
     set lraie 20
     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent div"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save "$audace(rep_images)/${fichier}_norm$conf(extension,defaut)"
     ::console::affiche_resultat "Profil normalisé sauvé sous ${fichier}_norm$conf(extension,defaut)\n"
   } else {
     ::console::affiche_erreur "Usage : spc_norma nom_fichier ?largeur de raie?\n\n"
   }
}
#*****************************************************************#


####################################################################
# Procedure de normalisation automatique de profil de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-12-2005
# Date modification : 15-12-2005
# Arguments : fichier .fit du profil de raie normalisé
####################################################################

proc spc_autonorma { args } {

    global audace
    global conf
    set extsp ".dat"

    if {[llength $args] == 1} {
	set fichier [ lindex $args 0 ]
	set nom_fichier [ file rootname $fichier ]
	#::console::affiche_resultat "F : $fichier ; NF : $nom_fichier\n"
	#--- Ajustement de degré 2 pour déterùiner un continuum
	set coordonnees [spc_ajust $fichier 1]
	#-- vspc_data2fits retourne juste le nom de fichier créé
	#set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees "double" ]
	set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees "float" ]

	#--- Retablissemnt d'une dispersion identique entre continuum et le profil aà normaliser
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	set liste_dispersion [buf$audace(bufNo) getkwd "CDELT1"]
	set dispersion [lindex $liste_dispersion 1]
	set nbunit [lindex $liste_dispersion 2]
	#set unite [lindex $liste_dispersion 3]
	buf$audace(bufNo) load $audace(rep_images)/$nom_continuum
	buf$audace(bufNo) setkwd [list "CDELT1" "$dispersion" $nbunit "" "Angstrom/pixel"]
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save $audace(rep_images)/$nom_continuum

	#--- Normalisation par division
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	buf$audace(bufNo) div $audace(rep_images)/$nom_continuum 1
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_norm

	#-- Effacement des fichiers temporaires
	#file delete $audace(rep_images)/${nom_fichier}_continuum$conf(extension,defaut)
	return ${nom_fichier}_norm
    } else {
	::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#

proc spc_autonorma_051215b { args } {

    global audace
    global conf
    set extsp ".dat"

    if {[llength $args] == 1} {
	set fichier [ lindex $args 0 ]
	set nom_fichier [ file rootname $fichier ]
	#--- Ajustement de degré 2 pour déterùiner un continuum
	set coordonnees [spc_ajust $fichier 1]
	set nom_continuum [ spc_data2fits ${nom_fichier}_conti $coordonnees ]

	#set nx [llength [lindex $coordonnees 0]]
	#set ny [llength [lindex $coordonnees 1]]
	#::console::affiche_resultat "Nb points x : $nx ; y : $ny\n"
	
	#--- Normalisation par division
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	buf$audace(bufNo) div $audace(rep_images)/$nom_continuum 1
	#buf$audace(bufNo) bitpix float
	#buf$audace(bufNo) save $audace(rep_images)/${nom_fichier}_norm

	#-- Effacement des fichiers temporaires
	#file delete $audace(rep_images)/${nom_fichier}_continuum$conf(extension,defaut)
    } else {
	::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#

proc spc_autonorma_131205 { args } {

    global audace
    global conf
    set extsp ".dat"

    if {[llength $args] == 1} {
	set fichier [ lindex $args 0 ]

	# Ajustement de degré 2 pour déterùiner un continuum
	set coordonnees [spc_ajust $fichier 1]
	set lambdas [lindex $coordonnees 0]
	set intensites [lindex $coordonnees 1]
	set len [llength $lambdas]

	#--- Enregistrement du continuum au format fits
	set filename [ file rootname $fichier ]
	##set filename ${fileetalonnespc}_dat$extsp
	set fichier_conti ${filename}_conti$extsp
	set file_id [open "$audace(rep_images)/$fichier_conti" w+]
	for {set k 0} {$k<$len} {incr k} {
	    set lambda [lindex $lambdas $k]
	    set intensite [lindex $intensites $k]
	    #--- Ecrit les couples "Lambda Intensite" dans le fichier de sortie
	    puts $file_id "$lambda\t$intensite"
	}
	close $file_id
	#--- Conversion en fits
	spc_dat2fits $fichier_conti
	#-- Bisarrerie : le continuum fits est inverse gauche-droite
	buf$audace(bufNo) load $audace(rep_images)/${filename}_conti_fit
	buf$audace(bufNo) mirrorx
	buf$audace(bufNo) save $audace(rep_images)/${filename}_conti_fit

	#--- Normalisation par division
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	buf$audace(bufNo) div $audace(rep_images)/${filename}_conti_fit 1
	buf$audace(bufNo) save $audace(rep_images)/${filename}_norm

	#-- Effacement des fichiers temporaires
	file delete $audace(rep_images)/$fichier_conti$extsp
	file delete $audace(rep_images)/${filename}_conti_fit$conf(extension,defaut)
    } else {
	::console::affiche_erreur "Usage : spc_autonorma nom_profil_de_raies\n\n"
    }
}
#*****************************************************************#


##########################################################
# Normalisation d'un profil sur le continuum au voisinage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 24-03-2006
# Date de mise à jour : 24-03-2006
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_normaraie { args } {

   global audace
   global conf
   #set coeffajust 1.1848
   set coeffajust 1.0924


   if {[llength $args] == 4} {
     set fichier [ file rootname [ lindex $args 0 ] ]
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
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 # buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     #--- Le n°3 rendu par fitgauss est la valeur de fond selon X :
     # set continuum [lindex $lreponse 3]
     #--- Le n°7 rendu par fitgauss est la valeur de fond selon Y :
     set continuum [lindex $lreponse 7]
     #set centre [ expr $xcentre*$cdelt+$crval ]
     set continuum [ expr $continuum/$coeffajust ]
     ::console::affiche_resultat "Le continuum vaut $continuum\n"

     #--- Meth 1 : division de chaque valeur du profil par la valeur du continuum
     #set coords [ spc_fits2data $fichier ]
     #set lambdas [ lindex $coords 0 ]
     #set intensites [ lindex $coords 1 ]
     #foreach intensite $intensites {
	 #lappend newintensites [ expr $intensite/$continuum ]
     #}
     #set pref_fichier [ file rootname $fichier ]
     #set newcoords [ list $lambdas $newintensites ]
     #set ${pref_fichier}_lnorm [ spc_data2fits ${pref_fichier}_lnorm $newcoords double ]

     #--- Meth 2 (approuvé Buil) : coefmult=1/continuum
     set coeff [ expr 1./$continuum ]
     ::console::affiche_resultat "Coéfficient de normalisation : $coeff\n"
     buf$audace(bufNo) mult $coeff
     buf$audace(bufNo) save "$audace(rep_images)/${fichier}_lnorm"

     #--- Fin du script :
     ::console::affiche_resultat "Profil localement normalisé sauvé sous ${fichier}_lnorm.\n"
     return ${fichier}_lnorm
   } else {
     ::console::affiche_erreur "Usage: spc_normaraie nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
# Normalisation automatique d'un profil sur le continuum au voisinage d'une raie
# en tenant compte de la totalite du profil
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 26-08-2006
# Date de mise à jour : 26-08-2006
# Arguments : fichier .fit du profil de raies, type de raie
##########################################################

proc spc_autonormaraie { args } {

    global audace
    global conf
    #-- Ecart de 10 A sur les bords d'un profil couvrant 180 A : 5,56%
    set ecart 0.056

    if { [llength $args] == 2 } {
       set fichier [ file rootname [ lindex $args 0 ] ]
       set typeraie [ lindex $args 1 ]

       #--- Ramasse des renseignements :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

       #-- CAlcul Lambda deb et fin écartés du 10 A du bord
       set ldeb [ expr $crval ]
       set lfin [ expr $crval+$cdelt*$naxis1 ]
       set ecartzone [ expr $ecart*($lfin-$ldeb) ]
       set ldeb [ expr $ldeb+$ecartzone ]
       set lfin [ expr $lfin-$ecartzone ]

       #-- Normalise sur cette zone :
       set fileout [ spc_normaraie $fichier $ldeb $lfin $typeraie ]
       return $fileout
    } else {
	::console::affiche_erreur "Usage: spc_autonormaraie profil_de_raies type_raie (e/a)\n\n"
    }
}
#****************************************************************#



##########################################################
# Procedure de linéarisation de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 15-08-2005
# Date de mise à jour : 21-12-2005
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
     ::console::affiche_resultat "Continuum sauvé sous ${fichier}_cont$conf(extension,defaut)\n"
   } elseif {[llength $args] == 1} {
     set fichier [ lindex $args 0 ]
     set lraie 20
     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save $audace(rep_images)/${fichier}_cont$conf(extension,defaut)
     ::console::affiche_resultat "Continuum sauvé sous $audace(rep_images)/${fichier}_cont$conf(extension,defaut)\n"
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
# Date de création : 31-08-2005
# Date de mise à jour : 21-12-2005
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
       ::console::affiche_resultat "Spectre adoucis sauvé sous $audace(rep_images)/${fichier}_smo$conf(extension,defaut)\n"
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
# Date de création : 28-03-2006
# Date de mise à jour : 28-03-06/25-08-06
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
       ::console::affiche_resultat "Fichier très adoucis sauvé sous ${infichier}_bsmo$conf(extension,defaut)\n"
       return ${infichier}_bsmo
   } else {
       ::console::affiche_erreur "Usage : spc_bigsmooth profil_de_raies_fits ?coefficient?\n\n"
   }
}
##########################################################



##########################################################
# Procedure de sélection et découpage (crop) d'une partie d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, lambda_deb, lambda_fin
##########################################################

proc spc_select { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
       set infichier [ lindex $args 0 ]
       set xdeb [ lindex $args 1 ]
       set xfin [ lindex $args 2 ]
       set fichier [ file rootname $infichier ]
 
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
       set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       #--- Dispersion du spectre : =1 si profil non étalonné
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

       set abscisses ""
       set intensites ""
       for {set k 0} {$k<$naxis1} {incr k} {
	   #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
	   lappend abscisses [expr $xdepart+($k)*$disper*1.0]
	   #--- Lit la valeur des elements du fichier fit
	   lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   ##lappend profilspc(intensite) $intensite
       }

       #--- Sélection des longueurs d'onde à découper
       #set diff1 [ expr abs($xdeb-[ lindex $abscisses 0 ]) ] 
       #set diff2 [ expr abs($xfin-[ lindex $abscisses 0 ]) ]
       set nabscisses ""
       set k 0
       foreach abscisse $abscisses intensite $intensites {
	   #-- 060224 : gestion de lambda debut plus proche par defaut
	   set diff [ expr abs($xdeb-$abscisse) ]
	   if { $diff < $disper } {   
	       set xdebl [ expr $xdeb-$disper ]
	   } else {
	       set xdebl $xdeb
	   }
	   #-- 060326 : gestion de lambda fin plus proche par exces
	   set diff [ expr abs($xfin-$abscisse) ]
	   if { $diff < $disper } {   
	       set xfinl [ expr $xfin+$disper ]
	   } else {
	       set xfinl $xfin
	   }

	   #if { $abscisse >= $xdebl && $abscisse <= $xfin } {
	   #    lappend nabscisses $abscisse
	   #    lappend nintensites $intensite
	   #    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	   #    incr k
	   #}
	   if { $abscisse >= $xdebl } {
	       if {$abscisse <= $xfinl } {
		   lappend nabscisses $abscisse
		   lappend nintensites $intensite
		   # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
		   incr k
	       }
	   }
       }

       set len $k
       ::console::affiche_resultat "$k intensités sélectionnées.\n"
       #--- Initialisation à blanc d'un fichier fits
       #buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0

       for {set k 0} {$k<$len} {incr k} {
	   set intens [ lindex $nintensites $k ]
	   buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
	   #::console::affiche_resultat "Intensité $k : $intens\n"
       }

       #--- Initatialisation de l'entête
       buf$audace(bufNo) setkwd [list "NAXIS1" $len int "" ""]
       set xdepart [ lindex $nabscisses 0 ]
       buf$audace(bufNo) setkwd [list "CRVAL1" $xdepart float "" ""]
       set xfin [ lindex $nabscisses $len ]
       buf$audace(bufNo) setkwd [list "CDELT1" $disper float "" ""]

       #--- Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_sel$conf(extension,defaut)"
       ::console::affiche_resultat "Sélection sauvée sous $audace(rep_images)/${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel
   } else {
       ::console::affiche_erreur "Usage: spc_select nom_fichier (de type fits) x_début x_fin\n\n"
   }
}
##########################################################

proc spc_select0 { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
       set infichier [ lindex $args 0 ]
       set xdeb [ lindex $args 1 ]
       set xfin [ lindex $args 2 ]
       set fichier [ file rootname $infichier ]
 
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #--- Valeur minimale de l'abscisse : =0 si profil non étalonné
       set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       #--- Dispersion du spectre : =1 si profil non étalonné
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]

       set abscisses ""
       set intensites ""
       set nabscisses ""
       set nintensites ""
       for {set k 0} {$k<$naxis1} {incr k} {
	   #--- Donne les bonnes valeurs aux abscisses si le spectre est étalonné en longueur d'onde
	   set abscisse [expr $xdepart+($k)*$disper*1.0]
	   lappend abscisses $abscisse
	   #--- Lit la valeur des elements du fichier fit
	   set intensite [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   lappend intensites $intensite
	   #--- Alimente le nouveau spectre

	   if { $abscisse >= $xdeb && $abscisse <= $xfin } {
	       lappend nabscisses $abscisse
	       lappend nintensites $intensite
	       # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	       incr k
	   }
       }
       set longr [ llength $nabscisses ]
       ::console::affiche_resultat "Selection : $longr\n"
       #--- Sélection des longueurs d'onde à découper
       #set diff1 [ expr abs($xdeb-[ lindex $abscisses 0 ]) ] 
       #set diff2 [ expr abs($xfin-[ lindex $abscisses 0 ]) ]
       set nabscisses ""
       set nintensites ""
       set k 0
       foreach abscisse $abscisses intensite $intensites {
	   #-- 060224 : gestion de lambda debut plus proche par defaut
	   set diff [ expr abs($xdeb-$abscisse) ]
	   if { $diff < $disper } {   
	       set xdebl [ expr $xdeb-$disper ]
	   } else {
	       set xdebl $xdeb
	   }

	   if { $abscisse >= $xdebl && $abscisse <= $xfin } {
	       lappend nabscisses $abscisse
	       lappend nintensites $intensite
	       # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	       incr k
	   }
       }
       set len $k
	   

       ::console::affiche_resultat "$k intensités sélectionnées.\n"
       #--- Initialisation à blanc d'un fichier fits
       #buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_FLOAT COMPRESS_NONE 0

       for {set k 0} {$k<$len} {incr k} {
	   set intens [ lindex $nintensites $k ]
	   buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
	   ::console::affiche_resultat "Intensité $k : $intens\n"
       }

       #--- Initatialisation de l'entête
       buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
       set xdepart [ lindex $nabscisses 0 ]
       buf$audace(bufNo) setkwd [list "CRVAL1" "$xdepart" float "" ""]
       set xfin [ lindex $nabscisses $len ]
       buf$audace(bufNo) setkwd [list "CDELT1" "$disper" float "" ""]

       #--- Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_sel$conf(extension,defaut)"
       ::console::affiche_resultat "Sélection sauvée sous $audace(rep_images)/${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spc_select nom_fichier (de type fits) x_début x_fin\n\n"
   }
}
##########################################################


##########################################################
# Procedure de division de 2 profils de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-03-2006
# Date de mise à jour : 30-03-2006
# Arguments : profil de raies 1, profil de raies 2
##########################################################

proc spc_div { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set numerateur [ lindex $args 0 ]
	set denominateur [lindex $args 1 ]
	set fichier [ file tail [ file rootname $numerateur ] ]

	#--- Vérification de la compatibilité des 2 profils de raies : lambda_i, lambda_f et dispersion identiques
	if { [ spc_compare $numerateur $denominateur ] == 1 } {
	    #--- Récupération des mots clef de l'entéte FITS :
	    buf$audace(bufNo) load "$audace(rep_images)/$numerateur"
	    set dateobs [lindex [buf1 getkwd "DATE-OBS"] 1]
	    set mjdobs [lindex [buf1 getkwd "MJD-OBS"] 1]
	    set exposure [lindex [buf1 getkwd "EXPOSURE"] 1]

	    #--- Création des listes de valeur
	    set contenu1 [ spc_fits2data $numerateur ]
	    set contenu2 [ spc_fits2data $denominateur ]
	    set abscisses [ lindex $contenu1 0 ]
	    set ordonnees1 [ lindex $contenu1 1 ]
	    set ordonnees2 [ lindex $contenu2 1 ]

	    #--- Division
	    set nordos ""
	    set i 0
	    foreach ordo1 $ordonnees1 ordo2 $ordonnees2 {
		if { $ordo2 == 0.0 } {
		    lappend nordos 0.0
		    #::console::affiche_resultat "Val = $ordo2\n"
		    incr i
		} else {
		    lappend nordos [ expr 1.0*$ordo1/$ordo2 ]
		}
	    }
	    ::console::affiche_resultat "Fin de la division : $i divisions par 0.\n"

	    #--- Enregistrement du resultat au format fits
	    set ncontenu [ list $abscisses $nordos ]
	    set lenl [ llength $nordos ]
	    ::console::affiche_resultat "$lenl valeurs traitées.\n"
	    set fichier_out [ spc_data2fits ${fichier}_div $ncontenu ]

	    #--- Réintégration des mots clef FITS
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier_out"
	    buf$audace(bufNo) setkwd [ list "DATE-OBS" "$dateobs" string "Start of exposure. FITS standard" "Iso 8601" ]
	    buf$audace(bufNo) setkwd [ list "MJD-OBS" "$mjdobs" double "Start of exposure" "d" ]
	    buf$audace(bufNo) setkwd [ list "EXPOSURE" "$exposure" double "Total time of exposure" "s" ]
	    buf$audace(bufNo) save "$audace(rep_images)/$fichier_out"

	    #--- Fin du script :
	    ::console::affiche_resultat "Division des 2 profils sauvée sous ${fichier}_div$conf(extension,defaut)\n"
	    return ${fichier}_div
	} else {
	    ::console::affiche_resultat "\nLes 2 profils de raies ne sont pas divisibles.\n"
	    return 0
	}
    } else {
	::console::affiche_erreur "Usage : spc_div profil_de_raies_numérateur_fits profil_de_raies_dénominateur_fits\n\n"
    }
}
#*********************************************************************#



####################################################################
#  Procedure de lineratisation par spline
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-12-2005
# Date modification : 28-03-2006
# Arguments : profil.fit à rééchantillonner, profil_modele.fit modèle d'échantilonnage
# Algo : spline cubique appliqué au contenu d'un fichier fits
# Bug : a la premiere execution "# x vector "x" must be monotonically increasing"
####################################################################

proc spc_echant { args } {
    global conf
    global audace

    if {[llength $args] == 2} {
	set fichier [ file rootname [ lindex $args 0 ] ]
	set fichier_abscisses [ lindex $args 1 ]
	##set contenu [spc_openspcfits $filenamespc]
	#set contenu [ lindex $args 0 ]
	set contenu [ spc_fits2data $fichier ]

	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Une liste commence à 0 ; Un vecteur fits commence à 1
	blt::vector x($len) y($len) 
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses $i]
	    set y($i-1) [lindex $ordonnees $i]
	}
	x sort y

	#--- Création des abscisses des coordonnees interpolées
	set nabscisses [ lindex [ spc_fits2data $fichier_abscisses ] 0]
	set nlen [ llength $nabscisses ]
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
	::console::affiche_resultat "Exportation au format fits des données interpolées sous ${fichier}_ech\n"
	spc_data2fits ${fichier}_ech $ncoordonnees float

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
	return ${fichier}_ech
    } else {
	::console::affiche_erreur "Usage: spc_echant profil_a_reechantillonner.fit profil_modele_echantillonnage.fit\n\n"
    }
}
#****************************************************************#

proc spc_spline_051211 { args } {
    global conf
    global audace

    if {[llength $args] == 1} {
	set fichier [ lindex $args 0 ]
	##set contenu [spc_openspcfits $filenamespc]
	#set contenu [ lindex $args 0 ]
	set contenu [ spc_fits2data $fichier ]

	set abscisses [lindex $contenu 0]
	set ordonnees [lindex $contenu 1]
	set len [llength $ordonnees]

	#--- Une liste commence à 0 ; Un vecteur fits commence à 1
	blt::vector x($len) y($len) 
	for {set i $len} {$i > 0} {incr i -1} { 
	    set x($i-1) [lindex $abscisses $i]
	    set y($i-1) [lindex $ordonnees $i]
	}

	#--- Spline ---------------------------------------#
	x sort y
	x populate sx $len
	blt::vector sy($len)
	# blt::spline natural x y sx sy
	# The spline command computes a spline fitting a set of data points (x and y vectors) and produces a vector of the interpolated images (y-coordinates) at a given set of x-coordinates.
	#blt::spline quadratic x y sx sy
	blt::spline natural x y sx sy

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



##########################################################
# Procedure de rééchantillonage d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 15-08-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, nouvelle dispersion
##########################################################

# Arguments : fichier .fit du profil de raie, nbpixels, lambda0, nouvelle dispersion
proc spc_echant_21122005 { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       #--- Initialisation des variables de travail
       set infichier [ lindex $args 0 ]
       set nbpix [ lindex $args 1 ]
       set lambda0 [ lindex $args 2 ]
       set newdisp [ lindex $args 3 ]
       set fichier [ file tail $infichier ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set olddisp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       set facteur [ expr $newdisp/$olddisp ]
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set lambdadeb [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
       set lambdafin [ expr $lambdadeb+$olddisp*$naxis1 ]

       #--- Création de la liste des longueurs d'onde à obtenir
       for {set k 0} {$k<$nbpix} {incr k} {
	   lappend lambdasfinal[ expr lamdda0+$k*$newdisp ]
       }

       #--- Création de la liste des valeurs de l'intensite
       #-- Meth 1 :
       set coordonnees [ spc_fits2data $fichier ]
       set lambdas [ lindex $coordonnes 1 ]
       set intensites [ lindex $coordonnes 1 ]
       #-- Meth 2 :
       set falg 0
       if { $flag == 1 } {
       if { $lambdadeb != 1 } {
	   #-- Dispersion du spectre : =1 si profil non étalonné
	   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
	   #-- Pixel de l'abscisse centrale
	   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
	   #-- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
	   #set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
	   #::console::affiche_resultat "Ici 1\n"
	   #if { $dtype != "LINEAR" || $dtype == "" } {
	   #    ::console::affiche_resultat "Le spectre ne possède pas une dispersion linéaire. Pas de conversion possible.\n"
	   #    break
	   #}
	   #-- Une liste commence à 0 ; Un vecteur fits commence à 1
	   for {set k 0} {$k<$naxis1} {incr k} {
	       lappend lambdas [expr $xdepart+($k)*$xincr*1.0]
	       lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   }
	   #-- Spectre non calibré en lambda
       } else {
	   for {set k 0} {$k<$naxis1} {incr k} {
	       lappend lambdas [expr $k+1]
	       lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   }
       }
   }

       #--- Calcul les valeurs rééchantillonnées
       foreach lambda $lambdas intensite $intensites {
       }

       #--- Sauvegarde du spectre rééchantillonné
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_ech$conf(extension,defaut)
       ::console::affiche_resultat "Profil rééchantillonné sauvé sous $audace(rep_images)/${fichier}_ech$conf(extension,defaut)\n"
       return ${fichier}_ech
   } else {
       ::console::affiche_erreur "Usage: lechant nom_fichier (de type fits) nouvelle_dispersion\n\n"
   }
}
##########################################################

# Ne fonctionne pas : la bande passante est diminuée lorsque l'on passe par exemple de 5 à 2.2 
proc spc_echant0 { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set infichier [ lindex $args 0 ]
       set newdisp [ lindex $args 1 ]
       set fichier [ file tail $infichier ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       #buf$audace(bufNo) load $fichier
       set olddisp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       set facteur [ expr $newdisp/$olddisp ]
       # rééchantillone selon l'axe X, donc facteur_y=1.
       # normaflux=1 permet de garder la dynamique initiale.
       set lfactor [ list $facteur 1 ]
       buf$audace(bufNo) scale  $lfactor 1
       buf$audace(bufNo) setkwd [list "CDELT1" "$newdisp" float "" ""]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_ech$conf(extension,defaut)
       ::console::affiche_resultat "Profil rééchantillonné sauvé sous $audace(rep_images)/${fichier}_ech$conf(extension,defaut)\n"
       return ${fichier}_ech
   } else {
       ::console::affiche_erreur "Usage: lechant nom_fichier (de type fits) nouvelle_dispersion\n\n"
   }
}
##########################################################



####################################################################
# Procédure de calcul de la dérivée d'un profil de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies
####################################################################

proc spc_derive { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
	set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
	set listevals [ spc_fits2data $filename ]
	set listevalsdervie [ spc_derivation $listevals ]
	set filederive [ spc_data2fits ${filename}_deriv $listevalsdervie ]
	::console::affiche_resultat "Dérivée du profil de raies sauvée sous $filederive\n"
	return $filederive
    } else {
	::console::affiche_erreur "Usage: spc_derive nom_profil_raies\n"
    }
}
#***************************************************************************#
