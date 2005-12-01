
# Proc�dures d'analyse spectrale
# source $audace(rep_scripts)/spcaudace/spc_analyse.tcl

#************* Liste des focntions **********************#
#
# centergauss : d�termination du centre d'une raie spectrale par calcul du centre de gravit�.
# centergauss : d�termination du centre d'une raie spectrale modelisee par une gaussienne.
# centergaussl : d�termination du centre d'une raie spectrale calibr�e modelisee par une gaussienne.
# lintensity : d�termination de l'intensit� d'une raie spectrale modelisee par une gaussienne.
# spcew : d�termination de la largeur �quivalente d'une raie spectrale modelisee par une gaussienne.
# lechant : r��chantillonne les valeurs d'un profil de raie.
# lnorma : normalise un profil de raies  � un continuum avoisinant 1.
# llinear : lin�arise un profil de raies pour obtenir le continuum du profil.
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
# Date de mise � jour : 12-08-2005
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc centergauss { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set xdeb [ expr int([lindex $args 1 ]) ]
     set xfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
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
     ::console::affiche_erreur "Usage: centerg nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
# Procedure de d�termination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 12-08-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc centergaussl { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ expr int([lindex $args 1 ]) ]
     set lfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
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
     ::console::affiche_erreur "Usage: centergl nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
#  Procedure de d�termination du centre de gravit� d'une raie spectrale.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 30-08-2005
# Date de mise � jour : 30-08-2005
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel)
##########################################################

proc centergrav { args } {

    global audace
    global conf

    if {[llength $args] == 3} {
	set fichier [ lindex $args 0 ]
	set xdeb [ expr int([lindex $args 1 ]) ]
	set xfin [ expr int([lindex $args 2]) ]

	buf$audace(bufNo) load $fichier
	set listcoords [list $xdeb 1 $xfin 1]
	set listecoefscale [ list 1 3 ]
	buf$audace(bufNo) scale $listecoefscale 1
	set lreponse [ buf$audace(bufNo) centro $listcoords ]
	set centre [lindex $lreponse 0]
	::console::affiche_resultat "Le centre de gravit� de la raie est : $centre (pixels)\n"
     return $centre
    } else {
	::console::affiche_erreur "Usage: centerg nom_fichier (de type fits) x_debut x_fin\n\n"
    }
}
#****************************************************************#



##########################################################
# Procedure de d�termination de l'intensit� d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 12-08-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc lintensity { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ expr int([lindex $args 1 ]) ]
     set lfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
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
     ::console::affiche_erreur "Usage: lintensity nom_fichier (de type fits) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de d�termination de la largeur �quivalente d'une raie spectrale modelisee par une gaussienne. 
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 12-08-2005
# Arguments : fichier .fit du profil de raie, l_debut (wavelength), l_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spcew { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ expr int([lindex $args 1 ]) ]
     set lfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
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
     ::console::affiche_erreur "Usage: lintensity nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#


##########################################################
# Procedure de normalisation de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 15-08-2005
# Date de mise � jour : 15-08-2005
# Arguments : fichier .fit du profil de raie, largeur de raie (optionnelle)
##########################################################

proc lnorma { args } {

   global audace
   global conf
   set pourcent 0.95

   if {[llength $args] == 2} {
     set infichier [ lindex $args 0 ]
     set lraie [lindex $args 1 ]
     set fichier [ file rootname $infichier ]
     # buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save ${fichier}_norm$conf(extension,defaut)
     ::console::affiche_resultat "Profil normalis� sauv� sous ${fichier}_norm$conf(extension,defaut)\n"
   } elseif {[llength $args] == 1} {
     set fichier [ lindex $args 0 ]
     set lraie 20
     # buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent div"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save ${fichier}_norm$conf(extension,defaut)
     ::console::affiche_resultat "Profil normalis� sauv� sous ${fichier}_norm$conf(extension,defaut)\n"
   } else {
     ::console::affiche_erreur "Usage : lnorm nom_fichier ?largeur de raie?\n\n"
   }
}
##########################################################



##########################################################
# Procedure de lin�arisation de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 15-08-2005
# Date de mise � jour : 15-08-2005
# Arguments : fichier .fit du profil de raie, largeur de raie (optionnelle)
##########################################################

proc llinear { args } {

   global audace
   global conf
   set pourcent 0.95

   if {[llength $args] == 2} {
     set infichier [ lindex $args 0 ]
     set lraie [lindex $args 1 ]
     set fichier [ file rootname $infichier ]
     # buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save ${fichier}_cont$conf(extension,defaut)
     ::console::affiche_resultat "Continuum sauv� sous ${fichier}_cont$conf(extension,defaut)\n"
   } elseif {[llength $args] == 1} {
     set fichier [ lindex $args 0 ]
     set lraie 20
     # buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save ${fichier}_cont$conf(extension,defaut)
     ::console::affiche_resultat "Continuum sauv� sous ${fichier}_cont$conf(extension,defaut)\n"
   } else {
     ::console::affiche_erreur "Usage : llinear nom_fichier ?largeur de raie?\n\n"
   }
}
##########################################################



##########################################################
# Procedure d'adoucissement de profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 31-08-2005
# Date de mise � jour : 31-08-2005
# Arguments : fichier .fit du profil de raie
##########################################################

proc spcsmooth { args } {

   global audace
   global conf
   set pourcent 0.95
   set lraie 1

   if {[llength $args] == 1} {
     set infichier [ lindex $args 0 ]
     set fichier [ file rootname $infichier ]
     buf$audace(bufNo) load $fichier
     buf$audace(bufNo) imaseries "BACK kernel=$lraie threshold=$pourcent"
     buf$audace(bufNo) bitpix float
     buf$audace(bufNo) save ${fichier}_smo$conf(extension,defaut)
     ::console::affiche_resultat "Spectre adoucis sauv� sous ${fichier}_smo$conf(extension,defaut)\n"
   } else {
     ::console::affiche_erreur "Usage : spcsmooth nom_fichier\n\n"
   }
}
##########################################################



##########################################################
# Procedure de r��chantillonage d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 15-08-2005
# Date de mise � jour : 15-08-2005
# Arguments : fichier .fit du profil de raie, nouvelle dispersion
##########################################################

proc spcechant { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set infichier [ lindex $args 0 ]
       set newdisp [lindex $args 1 ]
       set fichier [ file rootname $infichier ]
       # buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       buf$audace(bufNo) load $fichier
       set olddisp [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set facteur [ expr $newdisp/$olddisp ]
       # r��chantillone selon l'axe X, donc facteur_y=1.
       # normaflux=1 permet de garder la dynamique initiale.
       set factors [ list $facteur 1 ]
       buf$audace(bufNo) scale  $factors 1
       buf$audace(bufNo) setkwd [list "CDELT1" "$newdisp" float "" ""]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save ${fichier}_ech$conf(extension,defaut)
       ::console::affiche_resultat "Profil r��chantillonn� sauv� sous ${fichier}_ech$conf(extension,defaut)\n"
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
# Date de mise � jour : 12-08-2005
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc lfwhm { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ expr int([lindex $args 1 ]) ]
     set lfin [ expr int([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     #buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     buf$audace(bufNo) load $fichier
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
     ::console::affiche_erreur "Usage: lfwhm nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



##########################################################
# Procedure de s�lection et d�coupage (crop) d'une partie d'un profil de raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 02-09-2005
# Date de mise � jour : 02-09-2005
# Arguments : fichier .fit du profil de raie, lambda_deb, lambda_fin
##########################################################

proc spcselect { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
       set infichier [ lindex $args 0 ]
       set xdeb [ lindex $args 1 ]
       set xfin [ lindex $args 2 ]
       set fichier [ file rootname $infichier ]

       buf$audace(bufNo) load $fichier
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       # Valeur minimale de l'abscisse : =0 si profil non �talonn�
       set xdepart [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       # Dispersion du spectre : =1 si profil non �talonn�
       set disper [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       # Pixel de l'abscisse centrale
       set xcenter [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]

       set abscisses ""
       set intensites ""
       for {set k 0} {$k<$naxis1} {incr k} {
	   # Donne les bonnes valeurs aux abscisses si le spectre est �talonn� en longueur d'onde
	   lappend abscisses [expr $xdepart+($k)*$disper*1.0]
	   # Lit la valeur des elements du fichier fit
	   lappend intensites [buf$audace(bufNo) getpix [list [expr $k+1] 1]]
	   ##lappend profilspc(intensite) $intensite
       }

       ## S�lection des longueurs d'onde � d�couper
       #set diff1 [ expr abs($xdeb-[ lindex $abscisses 0 ]) ] 
       #set diff2 [ expr abs($xfin-[ lindex $abscisses 0 ]) ] 
       set nabscisses ""
       set k 0
       foreach abscisse $abscisses intensite $intensites {
	   if { $abscisse >= $xdeb && $abscisse <= $xfin } {
	       lappend nabscisses $abscisse
	       lappend nintensites $intensite
	       # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
	       incr k
	   }
       }
       set len $k

       # Initialisation � blanc d'un fichier fits
       buf$audace(bufNo) setpixels CLASS_GRAY $len 1 FORMAT_USHORT COMPRESS_NONE 0

       for {set k 0} {$k<$len} {incr k} {
	   buf$audace(bufNo) setpix [list [expr $k+1] 1] [ lindex $nintensites $k ]
       }


       # Initatialisation de l'ent�te
       buf$audace(bufNo) setkwd [list "NAXIS1" "$len" int "" ""]
       set xdepart [ lindex $nabscisses 0 ]
       buf$audace(bufNo) setkwd [list "CRVAL1" "$xdepart" float "" ""]
       set xfin [ lindex $nabscisses $len ]
       set xcenter [ lindex $nabscisses [ expr int($len/2) ] ]
       buf$audace(bufNo) setkwd [list "CRPIX1" "$xcenter" float "" ""]
       buf$audace(bufNo) setkwd [list "CDELT1" "$disper" float "" ""]

       # Enregistrement du fichier fits final
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save ${fichier}_sel$conf(extension,defaut)
       ::console::affiche_resultat "S�lection sauv�e sous ${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spcselect nom_fichier (de type fits) x_d�but x_fin\n\n"
   }
}
##########################################################

