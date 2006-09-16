
# Procédures d'analyse spectrale
# source $audace(rep_scripts)/spcaudace/spc_analyse.tcl

#************* Liste des focntions **********************#
#
# spc_centergauss : détermination du centre d'une raie spectrale par calcul du centre de gravité.
# spc_centergauss : détermination du centre d'une raie spectrale modelisee par une gaussienne.
# spc_centergaussl : détermination du centre d'une raie spectrale calibrée modelisee par une gaussienne.
# spc_intensity : détermination de l'intensité d'une raie spectrale modelisee par une gaussienne.
# spc_ew : détermination de la largeur équivalente d'une raie spectrale modelisee par une gaussienne.
# lechant : rééchantillonne les valeurs d'un profil de raie.
# spc_norma : normalise un profil de raies  à un continuum avoisinant 1.
# spc_linear : linéarise un profil de raies pour obtenir le continuum du profil.
# lselect : sélection (crop) d'une partie d'un profil de raie
#
##########################################################


##########################################################
# centerv
#  SORTX [x1] [x2] [width] 
#SORTY [y1] [y2] [height]  


# centerg
# buf1 synthegauss {xc yc i0 fwhmx fwhmy} ?LimitAdu?

#    Ajoute une gaussienne sur l'image à la position (xc,yc), de largeur à mi hauteur fwhmx,fwhmy et d'intensité i0. L'option LimitAdu permet de fixer une valeur seuil au dessus de laquelle les valeurs auront la valeur du seuil (permet de reproduire l'effet d'une saturation).
##########################################################


##########################################################
#  Procedure de détermination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21-12-2005
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
# Procedure de détermination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21-12-2005
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
	 #-- fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
	 buf$audace(bufNo) mult -1.0
	 # set lreponse [buf$audace(bufNo) fitgauss $listcoords -fwhmx 10]
	 set lreponse [buf$audace(bufNo) fitgauss $listcoords ]
	 #-- Inverse de nouveau le spectre pour le rendre comme l'original
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
#  Procedure de détermination du centre de gravité d'une raie spectrale d'un profil calibré.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-08-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel)
##########################################################

proc spc_centergrav { args } {

    global audace
    global conf

    if {[llength $args] == 3} {
	set fichier [ lindex $args 0 ]
	set xdeb [ expr int([lindex $args 1 ]) ]
	set xfin [ expr int([lindex $args 2]) ]

	buf$audace(bufNo) load "$audace(rep_images)/$fichier"

	set listcoords [list $xdeb 1 $xfin 1]
	set listecoefscale [ list 1 3 ]
	buf$audace(bufNo) scale $listecoefscale 1
	set lreponse [ buf$audace(bufNo) centro $listcoords ]
	set centre [lindex $lreponse 0]
	::console::affiche_resultat "Le centre de gravité de la raie est : $centre (pixels)\n"
     return $centre
    } else {
	::console::affiche_erreur "Usage: spc_centergrav profil_de_raies (non calibré) x_debut x_fin\n\n"
    }
}
#****************************************************************#


##########################################################
#  Procedure de détermination du centre de gravité d'une raie spectrale.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-08-2005
# Date de mise à jour : 21-12-2005/21-08-06
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel)
##########################################################

proc spc_centergravl { args } {

    global audace
    global conf

    if {[llength $args] == 3} {
	set fichier [ lindex $args 0 ]
	set ldeb [ expr int([lindex $args 1 ]) ]
	set lfin [ expr int([lindex $args 2]) ]

	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
	set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
	set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
	set xfin [ expr int(($lfin-$crval)/$cdelt) ]

	set listcoords [list $xdeb 1 $xfin 1]
	set listecoefscale [ list 1 3 ]
	buf$audace(bufNo) scale $listecoefscale 1
	set lreponse [ buf$audace(bufNo) centro $listcoords ]
	set xcentre [lindex $lreponse 0]
	set centre [ expr $xcentre*$cdelt+$crval ]
	::console::affiche_resultat "Le centre de gravité de la raie est : $centre (pixels)\n"
     return $centre
    } else {
	::console::affiche_erreur "Usage: spc_centergravl profil_de_raies (calibré) x_debut x_fin\n\n"
    }
}
#****************************************************************#



##########################################################
#  Procedure de détermination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 21-12-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raies, x_centre, a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_centergaussauto { args } {

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
     ::console::affiche_erreur "Usage: spc_centergaussauto profil_de_raies (non calibré) x_centre a/e\n\n"
   }
}
#****************************************************************#


##########################################################
# Procedure de détermination de l'intensité d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21-12-2005
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
     ::console::affiche_resultat "L'intensité de la raie est : $intensity ADU.Angstroms\n"
     return $intensity

   } else {
     ::console::affiche_erreur "Usage: spc_intensity nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



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
       ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw Angstroms\n"
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
       ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw Angstroms\n"
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
     ::console::affiche_resultat "La largeur équivalente de la raie est : $eqw Angstroms\n"
     return $eqw

   } else {
     ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de détermination de la FWHM d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21-12-2005
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
# Procedure d'affichage des renseignenemts d'un profil de raies
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21-12-2005
# Arguments : fichier .fit du profil de raies
##########################################################

proc spc_info { args } {

   global audace
   global conf

   if {[llength $args] == 1} {
       set fichier [ lindex $args 0 ]

       #--- Capture des renseignements
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set date [lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1]
       set date2 [lindex [buf$audace(bufNo) getkwd "DATE"] 1]
       set duree [lindex [buf$audace(bufNo) getkwd "EXPOSURE"] 1]
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set xdebut [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set disp [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin [ expr $xdebut+$disp*$naxis1 ]

       #-- Affichage des renseignements
       ::console::affiche_resultat "Date de prise de vue : $date\n"
       if { $date2 != "" } {
	   ::console::affiche_resultat "Date de prise de vue 2 : $date2\n"
       }
       ::console::affiche_resultat "Durée de la pose : $duree s\n"
       ::console::affiche_resultat "Longueur : $naxis1 pixels\n"
       ::console::affiche_resultat "Lambda début : $xdebut Angstroms\n"
       ::console::affiche_resultat "Lambda fin : $xfin Angstroms\n"
       ::console::affiche_resultat "Dispersion : $disp Angstroms/pixel\n"

       #--- Création d'une liste de retour des résultats
       set infos [ list $date $duree $naxis1 $xdebut $xfin $disp ]
       return $infos

   } else {
       ::console::affiche_erreur "Usage: spc_info nom_fichier fits\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de comparaison de 2 profils de raies
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-03-2006
# Date de mise à jour : 30-03-2006
# Arguments : profil de raies 1, profil de raies 2
##########################################################

proc spc_compare { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set f1 [ lindex $args 0 ]
	set f2 [lindex $args 1 ]

	#--- CAptage d'informations des 2 profils de raies : lambda_i, lambda_f et dispersion identiques
	set info [ spc_info $f1 ]
	set len1 [ lindex $info 2 ]
	set lambda_i1 [ lindex $info 3 ]
 	set lambda_f1 [ lindex $info 4 ]
	set disp1 [ lindex $info 5 ]
	set info [ spc_info $f2 ]
	set len2 [ lindex $info 2 ]
	set lambda_i2 [ lindex $info 3 ]
 	set lambda_f2 [ lindex $info 4 ]
	set disp2 [ lindex $info 5 ]

	#--- Réduction de la précision de comparaison des longueurs d'ondes au 1/10000 d'Angstrom :
	set lambda_i1 [ expr int($lambda_i1*10000.)/10000. ]
	set lambda_i2 [ expr int($lambda_i2*10000.)/10000. ]
	set disp1 [ expr int($disp1*10000.)/10000. ]
	set disp2 [ expr int($disp2*10000.)/10000. ]

	#--- Vérification de la compatibilité des 2 profils de raies : lambda_i, lambda_f et dispersion identiques
	#if { { $len1 == $len2 } && { $lambda_i1 == $lambda_i2 } && { $lambda_f1 == $lambda_f2 } && { $disp1 == $disp2 } } 
	if { $len1==$len2 && $lambda_i1==$lambda_i2 && $lambda_f1==$lambda_f2 && $disp1==$disp2 } {
	    ::console::affiche_resultat "Les 2 profils de raies ont les mêmes paramètres.\n"
	    return 1
	} else {
	    ::console::affiche_resultat "Les 2 profils de raies n'ont pas les mêmes paramètres.\n"
	    return 0
	}

    } else {
	::console::affiche_erreur "Usage : spc_compare profil_de_raies-1-fits profil_de_raies-2-fits\n\n"
    }
}
#*********************************************************************#


####################################################################
# Procédure de recherche des raies dans un profil
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 3-09-2006
# Date modification : 3-09-2006
# Arguments : nom_profil_raies largeur_raie
####################################################################

proc spc_findbiglines { args } {
    global conf
    global audace
    # set pas 10
    set ecart 4.0

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
	if { $nbargs == 2 } {
	    set filename [ lindex $args 0 ]
	    set typeraies [ lindex $args 1 ]
	    set largeur 10
	} elseif { $nbargs == 3 } {
	    set filename [ lindex $args 0 ]
	    set typeraies [ lindex $args 1 ]
	    set largeur [ expr int([ lindex $args 2 ]) ]
	} else {
	    ::console::affiche_erreur "Usage: spc_findbiglines nom_profil_de_raies type_raies ?largeur_raie?\n"
	}
	set pas [ expr int($largeur/2) ]

	#--- Gestion des profils calibrés en longueur d'onde :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	#-- Retire les petites raies qui seraient des pixels chauds ou autre :
	buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
	#-- Renseigne sur les parametres de l'image :
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
	set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
	set nbrange [ expr int($naxis1/$largeur) ]
	# ::console::affiche_resultat "nb intervalles : $nbrange\n"

	#--- Recherche des raies d'émission :
	if { $typeraies == "a" } {
	    buf$audace(bufNo) mult -1.0
	    ::console::affiche_resultat "Recherche des raies d'absorption...\n"
	} elseif { $typeraies == "e" } {
	    ::console::affiche_resultat "Recherche des raies d'émission...\n"
	} else {
	    ::console::affiche_resultat "Type de raie inconnu. Donner (e/a).\n"
	    return 0
	}
	for {set i 1} {$i<=[ expr $naxis1-2*$largeur ]} { set i [expr $i+$pas ]} {
	    set xdeb $i
	    set xfin [ expr $i+$largeur-1 ]
	    set coords [ list $xdeb 1 $xfin 1 ]
	    #-- Meth 1 : fit gaussien
	    # set gauss [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ]
	    set gauss [ buf$audace(bufNo) fitgauss $coords ]
	    lappend xcenters [ lindex $gauss 1 ]
	    #-- Intensite en X :
	    lappend intensites [ lindex $gauss 0 ]

	    #-- Meth 2 : centroide
	    ##lappend intensites [ lindex [ buf$audace(bufNo) flux $coords ]  0 ]
	    #lappend intensites [ lindex [ buf$audace(bufNo) fitgauss $coords ] 0 ]
	    #lappend xcenters [ lindex [ buf$audace(bufNo) centro $coords ]  0 ]
	}

	#--- Tri des intensités les plus intenses :
	set intensite 0
	set listimax [ list 0 ]
	set listabscisses [ list ]
	set len [ llength $xcenters ]
#::console::affiche_resultat "nb raies : $len\n"
	#-- Meth2 : super lsort
	foreach imax $intensites abscisse $xcenters {
	    lappend doubleliste [ list $abscisse $imax ]
	}
	# set doublelistesorted [ lsort -decreasing -real -index 1 $doubleliste ]

	#--- Retire une raie sur 2 des raies dont les abscisses proche 1 l'une de l'autre
	# set doublelistesorted [ lsort -decreasing -real -index 0 $doubleliste ]
	set doublelistesorted [ lsort -increasing -real -index 0 $doubleliste ]
#::console::affiche_resultat "Double liste : $doublelistesorted\n"
	set len [ expr [ llength $doublelistesorted ]-1 ]
	for {set j 0} {$j<$len} {incr j} {
	    set abscissej [ lindex [ lindex $doublelistesorted $j ] 0 ]
	    set abscissejj [ lindex [ lindex $doublelistesorted [ expr $j+1 ] ] 0 ]
	    set imaxj [ lindex [ lindex $doublelistesorted $j ] 1 ]
	    set imaxjj [ lindex [ lindex $doublelistesorted [ expr $j+1 ] ] 1 ]
	    if { [ expr $abscissej-$abscissejj ] <= $ecart && $imaxj>=$imaxjj } {
		set doublelistesorted [ lreplace $doublelistesorted [ expr $j+1 ] [ expr $j+1 ] [ list $abscissejj 0.0 ] ]
		#set toto [ lindex $doublelistesorted [ expr $j+1 ] ]
		#::console::affiche_resultat "$toto\n"
	    } elseif { [ expr $abscissej-$abscissejj ] <= $ecart && $imaxj<=$imaxjj } {
		set doublelistesorted [ lreplace $doublelistesorted [ expr $j ] [ expr $j ] [ list $abscissej 0.0 ] ]
		# [ list $abscissejj 0.0 ]
	    }
	}

	#::console::affiche_resultat "Double liste : $doubleliste\n"
	#::console::affiche_resultat "Double liste : $doublelistesorted2\n"

	#-- Meth 1 : mon tri (marche pas)
	set flag 0
	if { $flag==1 } {
	for {set j 0} {$j<$len} {incr j} {
	    set intensite [ lindex $intensites $j ]
	    # set imax [ lindex [ lsort -real -decreasing $listimax ] 0 ]
	    set imax [ lindex $listimax 0 ]
#::console::affiche_resultat "imax n°$j: $imax\n"
	    if { $intensite>$imax } {
		set listimax [ linsert $listimax 0 $intensite ]
		set listabscisses [ linsert $listabscisses 0 [ lindex $xcenters $j ] ]
	    } else {
		set listimax [ linsert $listimax $j $intensite ]
		set listabscisses [ linsert $listabscisses $j [ lindex $xcenters $j ] ]
	    }
	}
        }
        #::console::affiche_resultat "listimax : $listimax\n"
        #::console::affiche_resultat "xlistimax : $listabscisses\n"

	#--- Sélection des abscisses des 12 raies les plus intenses :
	set doublelistesorted2 [ lsort -decreasing -real -index 1 $doublelistesorted ]
	set selection12 [ lrange $doublelistesorted2 0 12 ]
#::console::affiche_resultat "Double liste : $selection12\n"

	#--- Retire dans la cette selection les raies détectées aui sont les mêmes en fait :
	set selection12 [ lsort -increasing -real -index 0 $selection12 ]
#::console::affiche_resultat "listimax : $selection12\n"
	set len [ expr [ llength $selection12 ]-1 ]
	for {set j 0} {$j<$len} {incr j} {
	    set abscissej [ lindex [ lindex $selection12 $j ] 0 ]
	    set abscissejj [ lindex [ lindex $selection12 [ expr $j+1 ] ] 0 ]
	    set imaxj [ lindex [ lindex $selection12 $j ] 1 ]
	    set imaxjj [ lindex [ lindex $selection12 [ expr $j+1 ] ] 1 ]
	    if { [ expr $abscissej-$abscissejj ] <= $ecart && $imaxj>=$imaxjj } {
		set selection12 [ lreplace $selection12 [ expr $j+1 ] [ expr $j+1 ] [ list $abscissejj 0.0 ] ]
		#set toto [ lindex $doublelistesorted [ expr $j+1 ] ]
		#::console::affiche_resultat "$toto\n"
	    } elseif { [ expr $abscissej-$abscissejj ] <= $ecart && $imaxj<=$imaxjj } {
		set selection12 [ lreplace $selection12 [ expr $j ] [ expr $j ] [ list $abscissej 0.0 ] ]
		# [ list $abscissejj 0.0 ]
	    }
	}

	#--- Sélection des abscisses des 6 raies les plus intenses :
	set selection12 [ lsort -decreasing -real -index 1 $selection12 ]
	set selection6 [ lrange $selection12 0 6 ]

	#--- Conversion des abscisses en longeueur d'onde :
	set k 0
	foreach raie $selection6 {
	    set abscisse [ expr $crval1+$cdelt1*[ lindex $raie 0 ] ]
	    set intensite [ lindex $raie 1 ]
	    set selection6 [ lreplace $selection6 $k $k [ list $abscisse $intensite ] ]
	    incr k
	}

	#--- Affichage du résultat :
	set mylistabscisses $selection6
	::console::affiche_resultat "Abscisse et I des raies les plus intenses : $mylistabscisses\n"
	return $mylistabscisses
    }
    ::console::affiche_erreur "Usage: spc_findbiglines nom_profil_de_raies type_raies ?largeur_raie?\n"
}
#***************************************************************************#
