
# Proc�dures d'analyse spectrale
# source $audace(rep_scripts)/spcaudace/spc_analyse.tcl

#************* Liste des focntions **********************#
#
# spc_centergauss : d�termination du centre d'une raie spectrale par calcul du centre de gravit�.
# spc_centergauss : d�termination du centre d'une raie spectrale modelisee par une gaussienne.
# spc_centergaussl : d�termination du centre d'une raie spectrale calibr�e modelisee par une gaussienne.
# spc_intensity : d�termination de l'intensit� d'une raie spectrale modelisee par une gaussienne.
# spc_ew : d�termination de la largeur �quivalente d'une raie spectrale modelisee par une gaussienne.
# lechant : r��chantillonne les valeurs d'un profil de raie.
# spc_norma : normalise un profil de raies  � un continuum avoisinant 1.
# spc_linear : lin�arise un profil de raies pour obtenir le continuum du profil.
# lselect : s�lection (crop) d'une partie d'un profil de raie
#
##########################################################


##########################################################
# centerv
#  SORTX [x1] [x2] [width] 
#SORTY [y1] [y2] [height]  


# centerg
# buf1 synthegauss {xc yc i0 fwhmx fwhmy} ?LimitAdu?

#    Ajoute une gaussienne sur l'image � la position (xc,yc), de largeur � mi hauteur fwhmx,fwhmy et d'intensit� i0. L'option LimitAdu permet de fixer une valeur seuil au dessus de laquelle les valeurs auront la valeur du seuil (permet de reproduire l'effet d'une saturation).
##########################################################


##########################################################
#  Procedure de d�termination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_centergauss { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set xdeb [ expr int([lindex $args 1 ]) ]
     set xfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     #buf$audace(bufNo) load $fichier
     set listcoords [list $xdeb 1 $xfin 1]
     if { [string compare $type "a"] == 0 } {
	 # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	 buf$audace(bufNo) mult -1.0
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     # Le second element de la liste reponse est le centre X de la gaussienne
     set centre [lindex $lreponse 1]
     ::console::affiche_resultat "Le centre de la raie est : $centre (pixels)\n"
     return $centre

   } else {
     ::console::affiche_erreur "Usage: spc_centergauss nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
# Procedure de d�termination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_centergaussl { args } {

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
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     # Le second element de la liste reponse est le centre X de la gaussienne
     set xcentre [lindex $lreponse 1]
     set centre [ expr $xcentre*$cdelt+$crval ]
     ::console::affiche_resultat "Le centre de la raie est : $centre Angstroms\n"
     return $centre

   } else {
     ::console::affiche_erreur "Usage: spc_centergaussl nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
#  Procedure de d�termination du centre de gravit� d'une raie spectrale.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 30-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel)
##########################################################

proc spc_centergrav { args } {

    global audace
    global conf

    if {[llength $args] == 3} {
	set fichier [ lindex $args 0 ]
	set xdeb [ expr int([lindex $args 1 ]) ]
	set xfin [ expr int([lindex $args 2]) ]

	buf$audace(bufNo) load $audace(rep_images)/$fichier
	set listcoords [list $xdeb 1 $xfin 1]
	set listecoefscale [ list 1 3 ]
	buf$audace(bufNo) scale $listecoefscale 1
	set lreponse [ buf$audace(bufNo) centro $listcoords ]
	set centre [lindex $lreponse 0]
	::console::affiche_resultat "Le centre de gravit� de la raie est : $centre (pixels)\n"
     return $centre
    } else {
	::console::affiche_erreur "Usage: spc_centergrav nom_fichier (de type fits) x_debut x_fin\n\n"
    }
}
#****************************************************************#


##########################################################
#  Procedure de d�termination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 21-12-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_centerauto { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
     set fichier [ lindex $args 0 ]
     set xcentre [ expr int([lindex $args 1 ]) ]
     set type [ lindex $args 2 ]

     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     #buf$audace(bufNo) load $fichier
     set listcoords [list $xdeb 1 $xfin 1]
     if { [string compare $type "a"] == 0 } {
	 # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	 buf$audace(bufNo) mult -1.0
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     # Le second element de la liste reponse est le centre X de la gaussienne
     set centre [lindex $lreponse 1]
     ::console::affiche_resultat "Le centre de la raie est : $centre (pixels)\n"
     return $centre

   } else {
     ::console::affiche_erreur "Usage: spc_centergauss nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
# Procedure de d�termination de l'intensit� d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_intensity { args } {

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
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     # Attention, $lreponse 2 est en pixels
     set if0 [ expr ([ lindex $lreponse 2 ]*$cdelt+$crval)*.601*sqrt(acos(-1)) ]
     set intensity [ expr [ lindex $lreponse 0 ]*$if0 ]
     ::console::affiche_resultat "L'intensit� de la raie est : $intensity ADU.Angstroms\n"
     return $intensity

   } else {
     ::console::affiche_erreur "Usage: spc_intensity nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de d�termination de la largeur �quivalente d'une raie spectrale modelisee par une gaussienne. 
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21-12-2005
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
     ::console::affiche_resultat "La largeur �quivalente de la raie est : $eqw Angstroms\n"
     return $eqw

   } else {
     ::console::affiche_erreur "Usage: spc_intensity nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#





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
     #buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save $audace(rep_images)/${fichier}_cont$conf(extension,defaut)
     ::console::affiche_resultat "Continuum sauv� sous ${fichier}_cont$conf(extension,defaut)\n"
   } elseif {[llength $args] == 1} {
     set fichier [ lindex $args 0 ]
     set lraie 20
     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     #buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save $audace(rep_images)/${fichier}_cont$conf(extension,defaut)
     ::console::affiche_resultat "Continuum sauv� sous $audace(rep_images)/${fichier}_cont$conf(extension,defaut)\n"
   } else {
     ::console::affiche_erreur "Usage : spc_linear nom_fichier ?largeur de raie?\n\n"
   }
}
##########################################################



##########################################################
# Procedure d'adoucissement de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 31-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie
##########################################################

proc spc_smooth { args } {

   global audace
   global conf
   set lraie 30

   if { [llength $args] <= 2 } {
       if { [llength $args] == 1 } {
	   set infichier [ lindex $args 0 ]
	   set pourcent 0.95
       } elseif  { [llength $args] == 2 } {
	   set infichier [ lindex $args 0 ]
	   set pourcent [ lindex $args 1 ]
       }

       set fichier [ file rootname $infichier ]
       buf$audace(bufNo) load $audace(rep_images)/$fichier
       buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_smo$conf(extension,defaut)
       ::console::affiche_resultat "Spectre adoucis sauv� sous $audace(rep_images)/${fichier}_smo$conf(extension,defaut)\n"
   } else {
       ::console::affiche_erreur "Usage : spc_smooth nom_fichier ?pourcentage?\n\n"
   }
}
##########################################################



##########################################################
# Procedure de r��chantillonage d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 15-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, nouvelle dispersion
##########################################################

# Ne fonctionne pas : la bande passante est diminu�e lorsque l'on passe par exemple de 5 � 2.2 
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
       # r��chantillone selon l'axe X, donc facteur_y=1.
       # normaflux=1 permet de garder la dynamique initiale.
       set lfactor [ list $facteur 1 ]
       buf$audace(bufNo) scale  $lfactor 1
       buf$audace(bufNo) setkwd [list "CDELT1" "$newdisp" float "" ""]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_ech$conf(extension,defaut)
       ::console::affiche_resultat "Profil r��chantillonn� sauv� sous $audace(rep_images)/${fichier}_ech$conf(extension,defaut)\n"
       return ${fichier}_ech$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: lechant nom_fichier (de type fits) nouvelle_dispersion\n\n"
   }
}
##########################################################

# Arguments : fichier .fit du profil de raie, nbpixels, lambda0, nouvelle dispersion
proc spc_echant { args } {

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

       #--- Cr�ation de la liste des longueurs d'onde � obtenir
       for {set k 0} {$k<$nbpix} {incr k} {
	   lappend lambdasfinal[ expr lamdda0+$k*$newdisp ]
       }

       #--- Cr�ation de la liste des valeurs de l'intensite
       #-- Meth 1 :
       set coordonnees [ spc_fits2data $fichier ]
       set lambdas [ lindex $coordonnes 1 ]
       set intensites [ lindex $coordonnes 1 ]
       #-- Meth 2 :
       set falg 0
       if { $flag == 1 } {
       if { $lambdadeb != 1 } {
	   #-- Dispersion du spectre : =1 si profil non �talonn�
	   set xincr [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
	   #-- Pixel de l'abscisse centrale
	   set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
	   #-- Type de spectre : LINEAR ou NONLINEAR (elinine les espaces dans la valeur du mot cle.
	   set dtype [string trim [lindex [buf$audace(bufNo) getkwd "CTYPE1"] 1]]
	   #::console::affiche_resultat "Ici 1\n"
	   if { $dtype != "LINEAR" || $dtype == "" } {
	       ::console::affiche_resultat "Le spectre ne poss�de pas une dispersion lin�aire. Pas de conversion possible.\n"
	       exit
	   }
	   #-- Une liste commence � 0 ; Un vecteur fits commence � 1
	   for {set k 0} {$k<$naxis1} {incr k} {
	       lappend lambdas [expr $xdepart+($k)*$xincr*1.0]
	       lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   }
	   #-- Spectre non calibr� en lambda
       } else {
	   for {set k 0} {$k<$naxis1} {incr k} {
	       lappend lambdas [expr $k+1]
	       lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   }
       }
   }

       #--- Calcul les valeurs r��chantillonn�es
       foreach lambda $lambdas intensite $intensites {
       }

       #--- Sauvegarde du spectre r��chantillonn�
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_ech$conf(extension,defaut)
       ::console::affiche_resultat "Profil r��chantillonn� sauv� sous $audace(rep_images)/${fichier}_ech$conf(extension,defaut)\n"
       return ${fichier}_ech$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: lechant nom_fichier (de type fits) nouvelle_dispersion\n\n"
   }
}
##########################################################




##########################################################
# Procedure de d�termination de la FWHM d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_fwhm { args } {

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
	 # Inverse de nouveau le spectre pour le rendre comme l'original
	 buf$audace(bufNo) mult -1.0
     } elseif { [string compare $type "e"] == 0 } {
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     # Le second element de la liste reponse est le centre X de la gaussienne
     set xfwhm [lindex $lreponse 2]
     #set fwhm [ expr $xfwhm*$cdelt+$crval ]
     set fwhm [ expr $xfwhm*$cdelt ]
     ::console::affiche_resultat "La FWHM de la raie est : $fwhm Angstroms\n"
     return $fwhm

   } else {
     ::console::affiche_erreur "Usage: spc_fwhm nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de s�lection et d�coupage (crop) d'une partie d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 21-12-2005
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
 
       buf$audace(bufNo) load $audace(rep_images)/$fichier
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       #--- Valeur minimale de l'abscisse : =0 si profil non �talonn�
       set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       #--- Dispersion du spectre : =1 si profil non �talonn�
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       #--- Pixel de l'abscisse centrale
       set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]

       set abscisses ""
       set intensites ""
       for {set k 0} {$k<$naxis1} {incr k} {
	   #--- Donne les bonnes valeurs aux abscisses si le spectre est �talonn� en longueur d'onde
	   lappend abscisses [expr $xdepart+($k)*$disper*1.0]
	   #--- Lit la valeur des elements du fichier fit
	   lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   ##lappend profilspc(intensite) $intensite
       }

       #--- S�lection des longueurs d'onde � d�couper
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
	   if { $abscisse >= $xdebl && $abscisse <= $xfin } {
	       lappend nabscisses $abscisse
	       lappend nintensites $intensite
	       # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	       incr k
	   }
       }
       set len $k

       #--- Initialisation � blanc d'un fichier fits
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0

       for {set k 0} {$k<$len} {incr k} {
	   buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
       }

       #--- Initatialisation de l'ent�te
       buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
       set xdepart [ lindex $nabscisses 0 ]
       buf$audace(bufNo) setkwd [list "CRVAL1" "$xdepart" float "" ""]
       set xfin [ lindex $nabscisses $len ]
       set xcenter [ lindex $nabscisses [ expr int($len/2) ] ]
       buf$audace(bufNo) setkwd [list "CRPIX1" "$xcenter" float "" ""]
       buf$audace(bufNo) setkwd [list "CDELT1" "$disper" float "" ""]

       #--- Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save $audace(rep_images)/${fichier}_sel$conf(extension,defaut)
       ::console::affiche_resultat "S�lection sauv�e sous $audace(rep_images)/${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spc_select nom_fichier (de type fits) x_d�but x_fin\n\n"
   }
}
##########################################################


##########################################################
# Procedure d'affichage des renseignenemts d'un profil de raies
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_info { args } {

   global audace
   global conf

   if {[llength $args] == 1} {
       set fichier [ lindex $args 0 ]

       #--- Capture des renseignements
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set xdebut [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set disp [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin [ expr $xdebut+$disp*$naxis1 ]

       #-- Affichage des renseignements
       ::console::affiche_resultat "Longueur : $naxis1 pixels\n"
       ::console::affiche_resultat "Lambda d�but : $xdebut Angstroms\n"
       ::console::affiche_resultat "Lambda fin : $xfin Angstroms\n"
       ::console::affiche_resultat "Dispersion : $disp Angstroms/pixel\n"

       #--- Cr�ation d'une liste de retour des r�sultats
       set infos [ list $naxis1 $xdebut $xfin $disp ]
       return $infos

   } else {
       ::console::affiche_erreur "Usage: spc_info nom_fichier fits\n\n"
   }
}
#****************************************************************#
