
# Procédures d'analyse spectrale
# source $audace(rep_scripts)/spcaudace/spc_analyse.tcl
# Mise a jour $Id: spc_analyse.tcl,v 1.4 2009-09-19 13:53:02 bmauclaire Exp $



#************* Liste des focntions **********************#
#
# spc_centergauss : détermination du centre d'une raie spectrale par calcul du centre de gravité.
# spc_centergauss : détermination du centre d'une raie spectrale modelisee par une gaussienne.
# spc_centergaussl : détermination du centre d'une raie spectrale calibrée modelisee par une gaussienne.
# spc_intensity : détermination de l'intensité d'une raie spectrale modelisee par une gaussienne.
# spc_ew : détermination de la largeur équivalente d'une raie spectrale modelisee par une gaussienne.
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
# Date de mise à jour : 21-12-2005/2007-04-27
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_centergauss { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     #- 2007-04-27 : int -> round
     set xdeb [ expr round([lindex $args 1 ]) ]
     set xfin [ expr round([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     #buf$audace(bufNo) load $fichier
     set listcoords [list $xdeb 1 $xfin 1]
     if { [string compare $type "a"] == 0 } {
         # fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
         buf$audace(bufNo) mult -1.0
         set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     } elseif { [string compare $type "e"] == 0 } {
         set lreponse [buf$audace(bufNo) fitgauss $listcoords]
     }
     #-- Le second element de la liste reponse est le centre X de la gaussienne
     set centre [lindex $lreponse 1]
     #-- BUG fitgauss : pas pour une lecture de pixel dans les spectres non calibres.
     # set centre [ expr $centre-1 ]

     ::console::affiche_resultat "Le centre de la raie est : $centre (pixels)\n"
     return $centre

   } else {
     ::console::affiche_erreur "Usage: spc_centergauss nom_fichier (de type fits) x_debut (pixels) x_fin (pixels) type_raie (a/e)\n\n"
   }
}
#****************************************************************#


##########################################################
# Procedure de détermination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21-12-2005/2007-04-27/2007-08-07
# Arguments : fichier .fit du profil de raie, x_debut (wavelength), x_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_centergaussl { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
     set fichier [ lindex $args 0 ]
     set ldeb [ lindex $args 1 ]
     set lfin [ lindex $args 2 ]
     set type [ lindex $args 3 ]

     #--- Récupère les mots clef de la calibration :
     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     set crval [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
     set cdelt [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         set flag_nonlin 1
         set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
         set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
         set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
         set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
     } else {
         set flag_nonlin 0
     }

     #--- Détermine les valaurs d'encadrement :
     #- 2007-04-27 : int -> round
     set xdeb [ expr round(($ldeb-$crval)/$cdelt) ]
     set xfin [ expr round(($lfin-$crval)/$cdelt) ]

     #--- Mesure le centre de la raie modéilsée par une gaussienne :
     set listcoords [list $xdeb 1 $xfin 1]
     if { [string compare $type "a"] == 0 } {
         #-- fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
         buf$audace(bufNo) mult -1.0
         # set lreponse [buf$audace(bufNo) fitgauss $listcoords -fwhmx 10]
         set lreponse [ buf$audace(bufNo) fitgauss $listcoords ]
     } elseif { [string compare $type "e"] == 0 } {
         set lreponse [ buf$audace(bufNo) fitgauss $listcoords ]
     }
     #-- Le second element de la liste reponse est le centre X de la gaussienne :
     set xcentre [lindex $lreponse 1]
     #-- BUG fitgauss :
     set xcentre [ expr $xcentre-1 ]


     #--- Converti le pixel en longueur d'onde :
     if { $flag_nonlin==1 } {
         set centre [ expr $spc_a+$spc_b*$xcentre+$spc_c*pow($xcentre,2)+$spc_d*pow($xcentre,3) ]
     } else {
         set centre [ expr $xcentre*$cdelt+$crval ]
     }

     #--- TRaitement du résultat :
     ::console::affiche_resultat "Le centre de la raie est : $centre Angstroms\n"
     return $centre
   } else {
     ::console::affiche_erreur "Usage: spc_centergaussl nom_profil_calibré_fits lambda_debut lambda_fin type_raie (a/e)\n\n"
   }
}
#****************************************************************#


##########################################################
#  Procedure de détermination du centre de gravité d'une raie spectrale d'un profil calibré.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-08-2005
# Date de mise à jour : 21-12-2005/2007-04-27
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel)
##########################################################

proc spc_centergrav { args } {

    global audace
    global conf

    if {[llength $args] == 3} {
        set fichier [ lindex $args 0 ]
        #- 2007-04-27 : int -> round
        set xdeb [ expr round([lindex $args 1 ]) ]
        set xfin [ expr round([lindex $args 2]) ]

        buf$audace(bufNo) load "$audace(rep_images)/$fichier"

        set listcoords [list $xdeb 1 $xfin 1]
        set listecoefscale [ list 1 3 ]
        buf$audace(bufNo) scale $listecoefscale 1
        set lreponse [ buf$audace(bufNo) centro $listcoords ]
        set centre [lindex $lreponse 0]
        #-- BUG centro : pas pour non calibrés
        #set centre [ expr $centre-1 ]

        ::console::affiche_resultat "Le centre de gravité de la raie est : $centre (pixels)\n"
     return $centre
    } else {
        ::console::affiche_erreur "Usage: spc_centergrav profil_de_raies (non calibré) x_debut (pixels) x_fin (pixels)\n\n"
    }
}
#****************************************************************#


##########################################################
#  Procedure de détermination du centre de gravité d'une raie spectrale.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 30-08-2005
# Date de mise à jour : 21-12-2005/21-08-2006/2007-04-27/2007-08-07
# Arguments : fichier .fit du profil de raie, x_debut (pixel), x_fin (pixel)
##########################################################

proc spc_centergravl { args } {

    global audace
    global conf

    if {[llength $args] == 3} {
        set fichier [ file rootname [ lindex $args 0 ] ]
        set ldeb [ lindex $args 1 ]
        set lfin [ lindex $args 2 ]

        #--- Conversion des longeurs d'onde en pixels :
        buf$audace(bufNo) load "$audace(rep_images)/$fichier"
        set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
        set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
            set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
            set spc_c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
            } else {
                set spc_d 0.
            }
            set xdeb [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($ldeb))*$spc_c))/(2*$spc_c)) ]
            set xfin [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lfin))*$spc_c))/(2*$spc_c)) ]
        } else {
            set flag_spccal 0
            #- 2007-04-27 : int -> round
            set xdeb [ expr round(($ldeb-$crval)/$cdelt) ]
            set xfin [ expr round(($lfin-$crval)/$cdelt) ]
        }
        set listcoords [list $xdeb 1 $xfin 1]


        #--- Détermination du barycentre de la raie d'absorption :
        ##set listecoefscale [ list 1 3 ]
        ## buf$audace(bufNo) scale $listecoefscale 1
        buf$audace(bufNo) mult -1.0
        set lreponse [ buf$audace(bufNo) centro $listcoords ]
        set xcenter [ lindex $lreponse 0 ]
        #- BUG centro :
        set xcenter [ expr $xcenter-1 ]

        #--- Traduit la position en longueur d'onde :
        if { $flag_spccal } {
            set lcentre [ expr $spc_a+$xcenter*$spc_b+$xcenter*$xcenter*$spc_c+pow($xcenter,3)*$spc_d ]
        } else {
            set lcentre [ expr $xcenter*$cdelt+$crval ]
        }

        #--- Traitement du resultat :
        ::console::affiche_resultat "Le centre de gravité de la raie est : $lcentre A\n"
        return $lcentre
    } else {
        ::console::affiche_erreur "Usage: spc_centergravl profil_de_raies_calibré lambda_debut lambda_fin\n\n"
    }
}
#****************************************************************#



##########################################################
# Procedure de détermination du centre d'une raie spectrale modelisee par une gaussienne.
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : fichier .fit du profil de raie, lambda_centre, type_de_raie (a/e), ?largeur_raie?
##########################################################

proc spc_autocentergaussl { args } {

   global audace spcaudace
   global conf
   #-- largeur en pixels de la raie (8) :
   set largeur $spcaudace(largeur_raie_detect)

   if { [llength $args] == 3 || [llength $args] == 4 } {
       if { [llength $args] == 3 } {
           set fichier [ lindex $args 0 ]
           set lcentre [ expr [lindex $args 1 ] ]
           set type [ lindex $args 2 ]
           set dlargeur [ expr $largeur*0.5 ]
       } elseif { [llength $args] == 4 } {
           set fichier [ lindex $args 0 ]
           set lcentre [ expr [lindex $args 1 ] ]
           set type [ lindex $args 2 ]
           set dlargeur [ expr 0.5*[ lindex $args 3 ] ]
       } else {
           ::console::affiche_erreur "Usage: spc_autocentergaussl profil_raies_fits_calibré lambda_approchée type_raie (a/e) ?largeur_raie?\n\n"
           return 0
       }

       #--- Entoure la raie 4 A de largeur
       set ldeb [ expr $lcentre-$dlargeur ]
       set lfin [ expr $lcentre+$dlargeur ]

       #--- Charge la liste des mots clefs :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set listemotsclef [ buf$audace(bufNo) getkwds ]

       #--- Cas d'une calibration non-linéaire :
       if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
           #-- Polynome : lambda=a+bx+cx^2
           set a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
           set b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
           set c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
           #-- J'utilise la solution généralement positive de la méthode du discriminent :
           set xdeb [ expr round((-$b+sqrt($b*$b-4*$a*($c-$ldeb)))/(2*$a)) ]
           set xfin [ expr round((-$b+sqrt($b*$b-4*$a*($c-$lfin)))/(2*$a)) ]
       } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set lambda0 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
           set dispersion [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
           set xdeb [ expr round(($ldeb-$lambda0)/$dispersion) ]
           set xfin [ expr round(($lfin-$lambda0)/$dispersion) ]
       }

       #--- Détermine le centre gaussien de la raie :
       set listcoords [ list $xdeb 1 $xfin 1 ]
       if { [string compare $type "a"] == 0 } {
           #-- fitgauss ne fonctionne qu'avec les raies d'emission, on inverse donc le spectre d'absorption
           buf$audace(bufNo) mult -1.0
           # set lreponse [buf$audace(bufNo) fitgauss $listcoords -fwhmx 10]
           set lreponse [ buf$audace(bufNo) fitgauss $listcoords ]
           #-- Inverse de nouveau le spectre pour le rendre comme l'original
           buf$audace(bufNo) mult -1.0
       } elseif { [string compare $type "e"] == 0 } {
           set lreponse [ buf$audace(bufNo) fitgauss $listcoords ]
       }
       #-- Le second element de la liste reponse est le centre X de la gaussienne
       set xcentre [lindex $lreponse 1]
       #-- BUG fitgauss : non, car l'origine du fitgauss est 1 plutot que 0.
       set xcentre [ expr $xcentre-1 ]
       #set lreponse [ buf$audace(bufNo) centro $listcoords ]
       #set xcentre [lindex $lreponse 0]

       #--- Calcul la longueur de de la raie :
       if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
           set lambda_centre [ expr $a+$b*$xcentre+$c*$xcentre*$xcentre ]
       } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set lambda_centre [ expr $xcentre*$dispersion+$lambda0 ]
       }

       #--- Formatage du résultat :
       ::console::affiche_resultat "Le centre de la raie est : $lambda_centre Angstroms\n"
       return $lambda_centre
   } else {
       ::console::affiche_erreur "Usage: spc_autocentergaussl profil_raies_fits_calibré lambda_approchée type_raie (a/e) ?largeur_raie?\n\n"
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
     set ldeb [ expr round([lindex $args 1 ]) ]
     set lfin [ expr round([lindex $args 2]) ]
     set type [ lindex $args 3 ]

     buf$audace(bufNo) load "$audace(rep_images)/$fichier"
     set crval [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
     set cdelt [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
     set xdeb [ expr int(($ldeb-$crval)/$cdelt) ]
     set xfin [ expr int(($lfin-$crval)/$cdelt) ]
     set lcentre [ expr 0.5*($ldeb+$lfin) ]

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
     #set if0 1.
     set intensity [ expr [ lindex $lreponse 0 ]*$if0 ]
     ::console::affiche_resultat "L'intensité de la raie $lcentre est : $intensity ADU.Angstroms\n"
     return $intensity

   } else {
     ::console::affiche_erreur "Usage: spc_intensity nom_fichier (de type fits) x_debut x_fin a/e\n\n"
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
     #-- Le second element de la liste reponse est le centre X de la gaussienne
     set xfwhm [ lindex $lreponse 2]
     #set xfwhm [ expr $xfwhm*2.0 ]
     set fwhm [ expr $xfwhm*$cdelt ]
     ::console::affiche_resultat "La FWHM de la raie est : $fwhm Angstroms ($xfwhm pixels)\n"
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

       #-- Affichage des renseignements (MUET) :
       if { 1==0 } {
       ::console::affiche_resultat "Date de prise de vue : $date\n"
       if { $date2 != "" } {
           ::console::affiche_resultat "Date de prise de vue 2 : $date2\n"
       }
       ::console::affiche_resultat "Durée de la pose : $duree s\n"
       ::console::affiche_resultat "Longueur : $naxis1 pixels\n"
       ::console::affiche_resultat "Lambda début : $xdebut Angstroms\n"
       ::console::affiche_resultat "Lambda fin : $xfin Angstroms\n"
       ::console::affiche_resultat "Dispersion : $disp Angstroms/pixel\n"
       }

       #--- Création d'une liste de retour des résultats
       set infos [ list $date $duree $naxis1 $xdebut $xfin $disp ]
       return $infos

   } else {
       ::console::affiche_erreur "Usage: spc_info nom_fichier fits\n\n"
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

proc spc_coefscalibre { args } {

   global audace
   global conf

   if {[llength $args] == 1} {
       set fichier [ lindex $args 0 ]

       #--- Capture des renseignements
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
           set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
           if { $lambda0==1. } {
               set lambda0 0.
           }
       } else {
           set lambda0 0.
       }
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       } else {
           set dispersion 1.
       }
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
           set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
       } else {
           set spc_a $lambda0
       }
       if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
           set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
       } else {
           set spc_b $dispersion
       }
       if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
           set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
       } else {
           set spc_c 0.0
       }
       if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
           set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
       } else {
           set spc_d 0.0
       }

       #--- Fromatage du résultat
       ::console::affiche_resultat "Polynôme de calibration : $spc_a+$spc_b*x+$spc_c*x^2+$spc_d*x^3\n"
       set coefspoly [ list $spc_a $spc_b $spc_c $spc_d ]
       return $coefspoly
   } else {
       ::console::affiche_erreur "Usage: spc_coefscalibre nom_fichier_fits\n\n"
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
    global audace spcaudace
    # set pas 10
    set ecart 4.0

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
	if { $nbargs == 2 } {
	    set filename [ lindex $args 0 ]
	    set typeraies [ lindex $args 1 ]
	    set largeur $spcaudace(largeur_raie_detect)
	} elseif { $nbargs == 3 } {
	    set filename [ lindex $args 0 ]
	    set typeraies [ lindex $args 1 ]
	    set largeur [ expr int([ lindex $args 2 ]) ]
	} else {
	    ::console::affiche_erreur "Usage: spc_findbiglines nom_profil_de_raies type_raies ?largeur_raie?\n"
	    return 0
	}
	set pas [ expr int($largeur/2) ]

	#--- Gestion des profils calibrés en longueur d'onde :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          if { [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ] != 1 } {
             set ecartfitgauss 1.0
          } else {
             set ecartfitgauss 0.0
          }
       } else {
          set ecartfitgauss 0.0
       }

	#-- Retire les petites raies qui seraient des pixels chauds ou autre :
        # commenté le 2008-03-21
	# buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
        # A tester : uncosmic $spcaudace(uncosmic)
	#-- Renseigne sur les parametres de l'image :
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
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
	for { set i 1 } { $i<=[ expr $naxis1-2*$largeur ] } { set i [ expr $i+$pas ] } {
            set xdeb $i
            set xfin [ expr $i+$largeur-1 ]
            set coords [ list $xdeb 1 $xfin 1 ]
            #-- Meth 1 : fit gaussien
            ## set gauss [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ]
            #::console::affiche_resultat "Centre $i avant fitgauss\n"
            set gauss [ buf$audace(bufNo) fitgauss $coords ]
            #::console::affiche_resultat "Centre $i après fitgauss\n"
            lappend xcenters [ expr [ lindex $gauss 1 ] -$ecartfitgauss ]
            #lappend xcenters [ lindex $gauss 1 ]
            #-- Intensite en X :
            lappend intensites [ lindex $gauss 0 ]

            #set xc [ lindex $gauss 1 ]
            #::console::affiche_resultat "Centre $i trouvé; Xfin=$xfin\n"

            #-- Meth 2 : centroide
            ##lappend intensites [ lindex [ buf$audace(bufNo) flux $coords ]  0 ]
            #lappend intensites [ lindex [ buf$audace(bufNo) fitgauss $coords ] 0 ]
            #lappend xcenters [ lindex [ buf$audace(bufNo) centro $coords ]  0 ]
        }

        #--- Tri des intensités les plus intenses :
        ::console::affiche_resultat "Triage des raies trouvées...\n"
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
	for { set j 0 } { $j<$len } { incr j } {
	    set abscissej [ lindex [ lindex $doublelistesorted $j ] 0 ]
	    set abscissejj [ lindex [ lindex $doublelistesorted [ expr $j+1 ] ] 0 ]
	    set imaxj [ lindex [ lindex $doublelistesorted $j ] 1 ]
	    set imaxjj [ lindex [ lindex $doublelistesorted [ expr $j+1 ] ] 1 ]
	    if { [ expr $abscissejj-$abscissej ] <= $ecart && $imaxj>=$imaxjj } {
		set doublelistesorted [ lreplace $doublelistesorted [ expr $j+1 ] [ expr $j+1 ] [ list $abscissejj 0.0 ] ]
		#set toto [ lindex $doublelistesorted [ expr $j+1 ] ]
		#::console::affiche_resultat "$toto\n"
	    } elseif { [ expr $abscissejj-$abscissej ] <= $ecart && $imaxj<=$imaxjj } {
		set doublelistesorted [ lreplace $doublelistesorted [ expr $j ] [ expr $j ] [ list $abscissej 0.0 ] ]
		# [ list $abscissejj 0.0 ]
	    }
	}

	#::console::affiche_resultat "Double liste : $doublelistesorted\n"
	#::console::affiche_resultat "Double liste : $doubleliste\n"
	#::console::affiche_resultat "Double liste : $doublelistesorted2\n"

	#-- Meth 1 : mon tri (marche pas)
	set flag 0
	if { $flag==1 } {
	for { set j 0 } { $j<$len } { incr j } {
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
        for { set j 0 } { $j<$len } { incr j } {
            set abscissej [ lindex [ lindex $selection12 $j ] 0 ]
            set abscissejj [ lindex [ lindex $selection12 [ expr $j+1 ] ] 0 ]
            set imaxj [ lindex [ lindex $selection12 $j ] 1 ]
            set imaxjj [ lindex [ lindex $selection12 [ expr $j+1 ] ] 1 ]
            if { [ expr $abscissejj - $abscissej] <= $ecart && $imaxj>=$imaxjj } {
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
        #set selection6 [ lrange $selection12 0 6 ]
        set selection6 $selection12

        #--- Conversion des abscisses en longueur d'onde :
        set coefspoly [ spc_coefscalibre "$filename" ]
        set spc_a [ lindex $coefspoly 0 ]
        set spc_b [ lindex $coefspoly 1 ]
        set spc_c [ lindex $coefspoly 2 ]
        set spc_d [ lindex $coefspoly 3 ]
        set k 0
        foreach raie $selection6 {
            set x [ lindex $raie 0 ]
            set abscisse [ expr $spc_a+$spc_b*$x+$spc_c*$x*$x+$spc_d*$x*$x*$x ]
            set intensite [ lindex $raie 1 ]
            set selection6 [ lreplace $selection6 $k $k [ list $abscisse $intensite ] ]
            incr k
        }

        #--- Affichage du résultat :
        set selection6 [ lrange $selection6 0 6 ]
        set mylistabscisses $selection6
        ::console::affiche_resultat "Abscisse et I des raies les plus intenses : $mylistabscisses\n"
        return $mylistabscisses
    }
    ::console::affiche_erreur "Usage: spc_findbiglines nom_profil_de_raies type_raies ?largeur_raie?\n"
}
#***************************************************************************#



##########################################################
# Procedure de calcul du rapport signal sur bruit S/N
# Auteur : Benjamin MAUCLAIRE
# Date de création : 01-10-2006
# Date de mise à jour : 01-10-2006
# Arguments : fichier .fit du profil de raies
# Algo : SNR = mean / standard deviation, Where standard deviation is: std= sqrt( sum (pixel_value-m)^2)/nb_pixel)
##########################################################

proc spc_snr { args } {

   global audace
   global conf
   #- une raie de moins de 0.92 A est du bruit
   set largeur_bruit 0.92
   set nbtranches 10

   if { [llength $args]==1 } {
       set fichier [ file rootname [ lindex $args 0 ] ]

       #--- Capture des renseignements
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "NAXIS2" ] !=-1 } {
           set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       } else {
           set naxis2 1
       }
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       } else {
           set disp 1.
       }

       #--- Caclul du signal moyen sur l'interval du continuum  et determination de cet interval :
       #set S [ lindex [ buf$audace(bufNo) stat ] 4 ]
       #-- Détermine l'intensité moyenne sur chaque tranches :
       set largeur [ expr int($naxis1/$nbtranches) ]
       set listresults ""
       for {set i 0} {$i<$nbtranches} {incr i} {
           if { $i==0 } {
               set zone [ list 1 1 $largeur 1 ]
               set x1 1
               set x2 $largeur
           } else {
               set x1 [ expr $i*$largeur ]
               set x2 [ expr ($i+1)*$largeur ]
               set zone [ list $x1 1 $x2 1 ]
           }
           set result [ buf$audace(bufNo) stat $zone ]
           lappend listresults [ list [ lindex $result 4 ] [ lindex $result 5 ] $x1 $x2 ]
       }
       #-- Tri par ecart-type :
       set listresults [ lsort -increasing -real -index 1 $listresults ]
       set S [ lindex [ lindex $listresults 0 ] 0 ]
       set xdeb [ lindex [ lindex $listresults 0 ] 2 ]
       set xfin [ lindex [ lindex $listresults 0 ] 3 ]
       #::console::affiche_resultat "$xdeb ; $xfin ; $S\n"


       #--- Calcul la déviation standard :
       if { 1==0 } {
       set somme 0
       set intensites [ lindex [ spc_fits2data $fichier ] 1 ]
       for { set i [ expr $xdeb-1 ] } { $i<$xfin } { incr i } {
           set intensite [ lindex $intensites $i ]
           set somme [ expr $somme+pow($intensite-$S,2) ]
       }
       set N [ expr sqrt($somme/($xfin-$xdeb+1)) ]
       }
       set N [ lindex [ buf$audace(bufNo) stat [ list $xdeb 1 $xfin 1 ] ] 5 ]

       #--- Calcul de SNR :
       if { $N != 0 } {
           set SNR [ expr $S/$N ]
       } else {
           ::console::affiche_resultat "Le bruit N=0, donc SNR non calculable\n"
           set SNR 0
       }

       #--- Affichage des résultats :
       file delete -force "$audace(rep_images)/${fichier}_crop$conf(extension,defaut)"
       ::console::affiche_resultat "SNR=$S/$N=$SNR\n"
       return $SNR

   } else {
       ::console::affiche_erreur "Usage: spc_snr nom_fichier_fits\n\n"
   }
}
#****************************************************************#



proc spc_snr1 { args } {

   global audace
   global conf
   #- une raie de moins de 0.92 A est du bruit
   set largeur_bruit 0.92

   if { [llength $args]==1 } {
       set fichier [ file rootname [ lindex $args 0 ] ]

       #--- Capture des renseignements
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "NAXIS2" ] !=-1 } {
           set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       } else {
           set naxis2 1
       }
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
       } else {
           set disp 1.
       }

       #--- Crop de l'image : ne tient pas compte des 5% premier et derniers
       set xdeb [ expr int(0.05*$naxis1) ]
       set xfin [ expr int(0.95*$naxis1) ]
       buf$audace(bufNo) window [ list $xdeb 1 $xfin $naxis2 ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/${fichier}_crop"
       buf$audace(bufNo) bitpix short

       #--- Caclul du signal moyen "global sur l'image":
       set S [ lindex [ buf$audace(bufNo) stat ] 4 ]

       #--- Calcul du bruit moyen "écart-type global de l'image" :
       set dlargeur_pixel [ expr 0.5*$largeur_bruit/$disp ]
       buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=$dlargeur_pixel"
       buf$audace(bufNo) sub "$audace(rep_images)/${fichier}_crop" 0
       buf$audace(bufNo) mult -1.0
       set N [ lindex [ buf$audace(bufNo) stat ] 5 ]

       #--- Calcul de SNR :
       if { $N != 0 } {
           set SNR [ expr $S/$N ]
       } else {
           ::console::affiche_resultat "Le bruit N=0, donc SNR non calculable\n"
           set SNR O
       }

       #--- Affichage des résultats :
       file delete -force "$audace(rep_images)/${fichier}_crop$conf(extension,defaut)"
       ::console::affiche_resultat "SNR=$S/$N=$SNR\n"
       return $SNR

   } else {
       ::console::affiche_erreur "Usage: spc_snr1 nom_fichier_fits\n\n"
   }
}
#****************************************************************#



####################################################################
# Procédure de calcul d'intensité d'une raie par intgégration (méthode des trapèzes)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-01-19
# Date modification : 07-01-19
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_integrate { args } {
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
        #set ew [ expr $intensity-($xfin-$xdeb) ]

        if { 0==1 } {
        #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
        set deltal [ expr abs($xfin-$xdeb) ]
        set snr [ spc_snr $filename ]
        set rapport [ expr $intensity/$deltal ]
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
        }

        #--- Affichage des résultats :
        #::console::affiche_resultat "L'intensité de la raie sur ($xdeb-$xfin) vaut $intensity ADU.anstrom(s)\nsigma(I)=$sigma ADU.angstrom\n"
        ::console::affiche_resultat "L'intensité de la raie sur ($xdeb-$xfin) vaut $intensity ADU.anstrom(s)\n"
        return $intensity
    } else {
        ::console::affiche_erreur "Usage: spc_integrate nom_profil_raies lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calcul d'intensité d'une raie par intgégration (méthode des trapèzes)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-01-23
# Date modification : 07-01-23
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_integratec { args } {
    global conf
    global audace

    if { [llength $args]==3 || [llength $args]==4 } {
        if { [llength $args]==3 } {
            set filename [ lindex $args 0 ]
            set ldeb [ lindex $args 1 ]
            set lfin [ lindex $args 2 ]
        } elseif { [llength $args]==4 } {
            set filename [ lindex $args 0 ]
            set ldeb [ lindex $args 1 ]
            set lfin [ lindex $args 2 ]
            set continuum [ lindex $args 3 ]
        }

        #--- Conversion des données en liste :
        set listevals [ spc_fits2data $filename ]
        set xvals [ lindex $listevals 0 ]
        set yvals [ lindex $listevals 1 ]


        #--- Détermination de la valeur du continuum de la raie :
        if { [llength $args]==3 } {
            buf$audace(bufNo) load "$audace(rep_images)/$filename"
            set listemotsclef [ buf$audace(bufNo) getkwds ]
            if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
                set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
            } else {
                set disp 1.
            }
            if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
                set lambda0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            } else {
                set lambda 1.
            }
            set xdeb [ expr round(($ldeb-$lambda0)/$disp) ]
            set xfin [ expr round(($lfin-$lambda0)/$disp) ]
            set continuum [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
        } elseif { [llength $args]==4 } {
            set continuum $continuum
        }

        #--- Création de la liste des valeurs sélectionnées par l'intervalle :
        foreach xval $xvals yval $yvals {
            if { $xval>=$ldeb && $xval<=$lfin } {
                lappend xsel $xval
                lappend ysel [ expr $yval-$continuum ]
            }
        }

        #--- Retrait du continuum a chaque intensité sélectionnée :
        #foreach y $ysel {
        #    lappend yselc [ expr $y-$offset ]
        #}

        #--- Calcul de l'aire sous la raie :
        set valsselect [ list $xsel $ysel ]
        set intensity [ spc_aire $valsselect ]

        #--- Affichage des résultats :
        ::console::affiche_resultat "L'intensité de la raie sur ($ldeb-$lfin) vaut $intensity ADU.anstrom(s) ; Continuum à $continuum ADU\n"
        return $intensity
    } else {
        ::console::affiche_erreur "Usage: spc_integratec nom_profil_raies lanmba_dep lambda_fin ?valeur_continuum?\n"
    }
}
#***************************************************************************#



####################################################################
# Procédure de calcul de l'amplitude (Imax) d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-01-20
# Date modification : 07-01-20
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_imax { args } {
    global conf
    global audace

    if { [llength $args] == 3 } {
        set fichier [ lindex $args 0 ]
        set lambda [ lindex $args 1 ]
        set largeur [ lindex $args 2 ]

        #--- Détermine les paramètres de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$fichier"
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
            set disp [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
        } else {
            set disp 1.
        }
        if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
            set lambda0 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        } else {
            set lambda0 1.
        }
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_nonlin 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
        } else {
            set flag_nonlin 0
        }

        #-- Calcul des limites de l'ajustement pour une dispersion linéaire :
        set xdeb [ expr round(($lambda-0.5*$largeur-$lambda0)/$disp) ]
        set xfin [ expr round(($lambda+0.5*$largeur-$lambda0)/$disp) ]

        #--- Ajustement gaussien:
        set gaussparams [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ]
        set imax [ lindex $gaussparams 0 ]
        set xcentre [ expr [ lindex $gaussparams 1 ] -1 ]

        #--- Converti le pixel en longueur d'onde :
        if { $flag_nonlin==1 } {
            set lcentre [ expr $spc_a+$spc_b*$xcentre+$spc_c*pow($xcentre,2)+$spc_d*pow($xcentre,3) ]
        } else {
            set lcentre [ expr $disp*$xcentre+$lambda0 ]
        }

        #--- Affichage des résultats :
        ::console::affiche_resultat "L'amplitude de la raie centrée en $lcentre vaut $imax ADU\n"
        set resul [ list $imax $lcentre ]
        return $resul
    } else {
        ::console::affiche_erreur "Usage: spc_imax nom_profil_raies longueur_d_onde_raie largeur\n"
    }
}
#***************************************************************************#




####################################################################
# Procédure de calcul de l'amplitude (Imax) d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-01-20
# Date modification : 07-01-20
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_imax0 { args } {
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

        #--- Calcul de la dérive de la raie :
        set valsselect [ list $xsel $ysel ]
        set valderiv [ spc_derivation $valsselect ]
        set yderiv [ lindex $valderiv 1 ]
::console::affiche_resultat "$yderiv\n"

        #--- Détermine la zéro :
        set i 0
        foreach x $xsel y $yderiv {
            if { $y==0 } {
                set ximax $x
                break
            }
            incr i
        }
        set yimax [ lindex $ysel $i ]

        #--- Affichage des résultats :
        ::console::affiche_resultat "L'amplitude de la raie sur ($xdeb-$xfin) vaut $yimax ADU\n"
        return $yimax
    } else {
        ::console::affiche_erreur "Usage: spc_imax nom_profil_raies lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#




####################################################################
# Procédure de calcul de l'amplitude (Imax) d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 1-06-2008
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_icontinuum { args } {
    global conf
    global audace
    set nbtranches 10
    #- demi-largeur d'etude en pixels :
    set dlargeur_etude 5

    set nbargs [ llength $args ]
    if { $nbargs  == 1 } {
        set fichier [ file rootname [ lindex $args 0 ] ]

        #--- Détermine les limites gauche et droite d'etude (valeurs != 0) :
        set limits [ spc_findnnul [ lindex [ spc_fits2data "$fichier" ] 1 ] ]
        buf$audace(bufNo) load "$audace(rep_images)/$fichier"
        buf$audace(bufNo) window [ list [ lindex $limits 0 ] 1 [ lindex $limits 1 ] 1 ]
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set largeur [ expr int($naxis1/$nbtranches) ]

        #--- Détermine l'intensité moyenne sur chaque tranches :
        set listresults ""
        for {set i 0} {$i<$nbtranches} {incr i} {
            if { $i==0 } {
                set zone [ list 1 1 $largeur 1 ]
            } else {
                set zone [ list [ expr $i*$largeur ] 1 [ expr ($i+1)*$largeur ] 1 ]
            }
            set result [ buf$audace(bufNo) stat $zone ]
            lappend listresults [ list [ lindex $result 4 ] [ lindex $result 5 ] ]
        }

        #--- Tri par ecart-type :
        set listresults [ lsort -increasing -real -index 1 $listresults ]
        set icontinuum [ lindex [ lindex $listresults 0 ] 0 ]

        #--- Affichage des résultats :
        ::console::affiche_resultat "Le continuum vaut $icontinuum\n"
        return $icontinuum
    } elseif { $nbargs == 2 } {
       set fichier [ file rootname [ lindex $args 0 ] ]
       set lambda [ lindex $args 1 ]

       #--- Determine le n° de pixel de la longueur d'onde demandee :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set xcenter [ expr ($lambda-$crval1)/$cdelt1 ]
       set xdeb [ expr round($xcenter-$dlargeur_etude) ]
       if { $xdeb < 1 } { set xdeb 1 }
       set xfin [ expr round($xcenter+$dlargeur_etude) ]
       if { $xfin > $naxis1 } { set xfin $naxis1 }
       set zone [ list $xdeb 1 $xfin 1 ]

       #--- Détermine la valeur du continuum autour de la lobgueur d'onde demandee :
       set icontinuum [ lindex [ buf$audace(bufNo) stat $zone ] 4 ]

       #--- Affichage des résultats :
       ::console::affiche_resultat "Le continuum à $lambda vaut $icontinuum\n"
       return $icontinuum
    } elseif { $nbargs == 3 } {
       set fichier [ file rootname [ lindex $args 0 ] ]
       set lambda_deb [ lindex $args 1 ]
       set lambda_fin [ lindex $args 2 ]

       #--- Determine le n° de pixel de la longueur d'onde demandee :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier"
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set xdeb [ expr round(($lambda_deb-$crval1)/$cdelt1) ]
       set xfin [ expr round(($lambda_fin-$crval1)/$cdelt1) ]
       if { $xdeb < 1 } { set xdeb 1 }
       if { $xfin > $naxis1 } { set xfin $naxis1 }
       set zone [ list $xdeb 1 $xfin 1 ]
       #::console::affiche_resultat "$xdeb, $xfin\n"

       #--- Détermine la valeur du continuum autour de la lobgueur d'onde demandee :
       set icontinuum [ lindex [ buf$audace(bufNo) stat $zone ] 4 ]

       #--- Affichage des résultats :
       ::console::affiche_resultat "Le continuum entre $lambda_deb-$lambda_fin vaut $icontinuum\n"
       return $icontinuum
    } else {
        ::console::affiche_erreur "Usage: spc_icontinuum nom_profil_raies ?lambda?/?lambda_deb lambda_fin?\n"
    }
}
#***************************************************************************#



####################################################################
# Procedure déterminant les bornes (indice) inf et sup d'un ensemble de valeurs où elles sont différentes de 0
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 14-07-2007
# Date modification : 14-07-2007
# Arguments : liste valeurs
# Sortie : les indices inf et sup de la liste
####################################################################

proc spc_findnnul { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
        set liste_intentites [ lindex $args 0 ]

        #--- Initialisations :
        set len [ llength $liste_intentites ]
        set i_inf 0
        set i_sup [ expr $len-1 ]

        #--- Recherche de i_inf :
        for {set i 0} {$i<$len} {incr i} {
            if { [ lindex $liste_intentites $i ]>0 } {
                set i_inf $i
                break
            }
        }

        #--- Recherche de i_sup :
        for {set i [ expr $len-1 ]} {$i>=0} {incr i -1} {
            if { [ lindex $liste_intentites $i ]>0 } {
                set i_sup $i
                break
            }
        }

        #--- Traitement des résultats :
        set results [ list $i_inf $i_sup ]
        return $results
    } else {
        ::console::affiche_erreur "Usage: spc_findnnul liste_intensites\n"
    }
}
#***************************************************************************#
