
# Procédures d'exploitation astrophysique des spectres
# A130 : source $audace(rep_scripts)/spcaudace/spc_astrophys.tcl
# A140 : source [ file join $audace(rep_plugin) tool spectro spcaudace spc_astrophys.tcl ]

# Mise a jour $Id: spc_astrophys.tcl,v 1.1 2008-06-14 16:36:20 bmauclaire Exp $



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

proc spc_vdoppler { args } {

   global audace
   global conf

   if { [llength $args] == 2 } {
       set delta_lambda [ lindex $args 0 ]
       set lambda [lindex $args 1 ]
       
       set vrad [ expr 299792.458*$delta_lambda/$lambda ]
       ::console::affiche_resultat "La vitesse Doppler de l'objet est : $vrad km/s\n"
       return $vrad
   } else {
       ::console::affiche_erreur "Usage: spc_vdoppler delta_lambda lambda_raie_référence\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de la vitesse héliocentrique pour une correction de la vitesse radiale
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : profil_raies_étalonné lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
# Explication : la correciton héliocentrique possède déjà le bon signe tandis que la vitesse héliocentrique non.
#  La mesure de vitesse radiale nécessite d'être corrigée de la vitesse héliocentrique même si la calibration a été faite sur les raies telluriques car le centre du référentiel n'est pas la Terre mais le barycentre du Système Solaire.
##########################################################

proc spc_vhelio { args } {

   global audace
   global conf

   set lambda_ref 6562.82
   set precision 1000.

   if { [llength $args] == 1 || [llength $args] == 7 || [llength $args] == 10 } {
       if { [llength $args] == 1 } {
	   set spectre [ lindex $args 0 ]
       } elseif { [llength $args] == 7 } {
	   set spectre [ lindex $args 0 ]
	   set ra_h [ lindex $args 1 ]
	   set ra_m [ lindex $args 2 ]
	   set ra_s [ lindex $args 3 ]
	   set dec_d [ lindex $args 4 ]
	   set dec_m [ lindex $args 5 ]
	   set dec_s [ lindex $args 6 ]
       } elseif { [llength $args] == 10 } {
	   set spectre [ lindex $args 0 ]
	   set ra_h [ lindex $args 1 ]
	   set ra_m [ lindex $args 2 ]
	   set ra_s [ lindex $args 3 ]
	   set dec_d [ lindex $args 4 ]
	   set dec_m [ lindex $args 5 ]
	   set dec_s [ lindex $args 6 ]
	   set jj [ lindex $args 7 ]
	   set mm [ lindex $args 8 ]
	   set aaaa [ lindex $args 9 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_vhelio profil_raies_étalonné ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }

       #--- Charge les mots clefs :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set listemotsclef [ buf$audace(bufNo) getkwds ]

       #--- Détermine les paramètres de date et de coordonnées si nécessaire :
       # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
       if { [llength $args] == 1 } {
	   # OBJCTRA = '00 16 42.089'
	   if { [ lsearch $listemotsclef "OBJCTRA" ] !=-1 } {
	       set ra [ lindex [buf$audace(bufNo) getkwd "OBJCTRA"] 1 ]
	       set ra_h [ lindex $ra 0 ]
	       set ra_m [ lindex $ra 0 ]
	       set ra_s [ lindex $ra 0 ]
	       set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
	   } else {
	       ::console::affiche_resultat "Aucune corrdonnées trouvée.\n"
	       return ""
	   }
	   # OBJCTDEC= '-05 23 52.444'
	   if { [ lsearch $listemotsclef "OBJCTDEC" ] !=-1 } {
	       set dec [ lindex [buf$audace(bufNo) getkwd "OBJCTDEC"] 1 ]
	       set dec_d [ lindex $dec 0 ]
	       set dec_m [ lindex $dec 0 ]
	       set dec_s [ lindex $dec 0 ]
	       set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
	   }
	   # DATE-OBS : 2005-11-26T20:47:04
	   if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
	       set ladate [ lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1 ]
	       set ldate [ mc_date2ymdhms $ladate ]
	       set y [ lindex $ldate 0 ]
	       set mo [ lindex $ldate 1 ]
	       set d [ lindex $ldate 2 ]
	       set datef [ list $y $mo $d ]
	   }
       } elseif { [llength $args] == 7 } {
	   # DATE-OBS : 2005-11-26T20:47:04
	   if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
	       set ladate [ lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1 ]
	       set ldate [ mc_date2ymdhms $ladate ]
	       set y [ lindex $ldate 0 ]
	       set mo [ lindex $ldate 1 ]
	       set d [ lindex $ldate 2 ]
	       set datef [ list $y $mo $d ]
	   }
	   set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
	   set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
       } elseif { [llength $args] == 10 } {
	   set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
	   set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
	   set datef [ list $aaaa $mm $jj ]
       }

       #--- Calcul de la vitesse héliocentrique :
       set vhelio [ lindex [ mc_baryvel $datef $raf $decf J2000.0 ] 0 ]
       set deltal [ expr round($vhelio*$lambda_ref/299792.458*$precision)/$precision ]
       #--- Recherche la dispersion :
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	   set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
	   set erreurv [ expr round($precision*$dispersion*299792.458/$lambda_ref)/$precision ]
       } else {
	   set erreurv 0.
       }


       #--- Formatage du résultat :
       #::console::affiche_resultat "La vitesse héliocentrique pour l'objet $raf ; $decf à la date du $datef vaut :\n$vhelio±$erreurv km/s=$deltal±$dispersion A\n"
       ::console::affiche_resultat "La vitesse héliocentrique pour l'objet $raf ; $decf à la date du $datef vaut :\n$vhelio km/s <-> $deltal A +-$erreurv km/s\n"
       return $vhelio
   } else {
	   ::console::affiche_erreur "Usage: spc_vhelio profil_raies_étalonné ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : profil_raies_étalonné, lambda_raie_approché, ?
##########################################################

proc spc_vradiale { args } {

   global audace
   global conf

   if { [llength $args] == 4 } {
      set spectre [ lindex $args 0 ]
      set typeraie [ lindex $args 1 ]
      set lambda_approchee [lindex $args 2 ]
      set lambda_ref [lindex $args 3 ]

      #--- Recupere le jour julien :
      buf$audace(bufNo) load "$audace(rep_images)/$spectre"
      if { [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] != "" } {
         set jd [ expr [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] +2400000.5 ]
      }

      #--- Détermine l'erreur sur la mesure :
      set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

      #--- Centre gaussien de la raie étudié :
      set lambda_centre [ spc_autocentergaussl $spectre $lambda_approchee $typeraie ]
      
      #--- Calcul la vitesse radiale : Acker p.101 Dunod 2005.
      set delta_lambda [ expr $lambda_centre-$lambda_ref ]
      set vrad [ expr 299792.458*$delta_lambda/$lambda_ref ]
      #-- The correction hc has to apply to the measured radial velocity: Vrad, real = Vrad,measured + hc.
      #set vradcorrigee [ expr $vrad+$vhelio ]
      #-- Erreur sur le calcul :
      set vraderr [ expr 299792.458*$dispersion/$lambda_ref ]
      
      #--- Formatage du résultat :
      ::console::affiche_resultat "La vitesse radiale de l'objet le $jd JJ à la longueur d'onde $lambda_centre A :\n\# Vrad=$vrad +- $vraderr km/s\n"
      return $vrad
   } else {
       ::console::affiche_erreur "Usage: spc_vradiale profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s à l'aide du décalage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 08-02-2007
# Date de mise à jour : 08-02-2007
# Arguments : profil_raies_étalonné, lambda_raie_approché, ?
##########################################################

proc spc_vradialecorr { args } {

   global audace
   global conf

   if { [llength $args] == 4 || [llength $args] == 10 || [llength $args] == 13 } {
       if { [llength $args] == 4 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
       } elseif { [llength $args] == 10 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ra_h [ lindex $args 4 ]
	   set ra_m [ lindex $args 5 ]
	   set ra_s [ lindex $args 6 ]
	   set dec_d [ lindex $args 7 ]
	   set dec_m [ lindex $args 8 ]
	   set dec_s [ lindex $args 9 ]
       } elseif { [llength $args] == 13 } {
	   set spectre [ lindex $args 0 ]
	   set typeraie [ lindex $args 1 ]
	   set lambda_approchee [lindex $args 2 ]
	   set lambda_ref [lindex $args 3 ]
	   set ra_h [ lindex $args 4 ]
	   set ra_m [ lindex $args 5 ]
	   set ra_s [ lindex $args 6 ]
	   set dec_d [ lindex $args 7 ]
	   set dec_m [ lindex $args 8 ]
	   set dec_s [ lindex $args 9 ]
	   set jj [ lindex $args 10 ]
	   set mm [ lindex $args 12 ]
	   set aaaa [ lindex $args 12 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }


       #--- Calcul la correction héliocentrique :
       # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       if { [llength $args] == 4 } {
          if { [ lindex [ buf$audace(bufNo) getkwd "OBJCTRA" ] 1 ] == "" } {
             ::console::affiche_erreur "Il manque les coordonnées RA-DEC e l'objet.\nUsage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
             return 0
          } else {
             set vhelio [ spc_vhelio $spectre ]
          }
       } elseif { [llength $args] == 10 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s ]
       } elseif { [llength $args] == 13 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s $dd $mm $aaaa ]
       } else {
	   ::console::affiche_erreur "Impossible de calculer vhélio ; Usage: spc_vradiale profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }
       ::console::affiche_resultat "\n"

       #--- Centre gaussien de la raie étudié :
       set lambda_centre [ spc_autocentergaussl $spectre $lambda_approchee $typeraie ]

       #--- Calcul la vitesse radiale : Acker p.101 Dunod 2005.
       set delta_lambda [ expr $lambda_centre-$lambda_ref ]
       set vrad [ expr 299792.458*$delta_lambda/$lambda_ref ]
       set delta_vrad [ expr 299792.458*$cdelt1/$lambda_ref ]
       #-- The correction hc has to apply to the measured radial velocity: Vrad, real = Vrad,measured + hc.
       set vradcorrigee [ expr $vrad+$vhelio ]

       #--- Formatage du résultat :
       ::console::affiche_resultat "(Vrad=$vrad km/s, Vhelio=$vhelio km/s)\n\# La vitesse radiale de l'objet est :\n\# Vrad=$vradcorrigee +- $delta_vrad km/s\n"
       set results [ list $vradcorrigee $vrad $vhelio ]
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_vradialecorr profil_raies_étalonné type_raie (e/a) lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
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

   if { [llength $args] == 3 || [llength $args] == 6 } {
     if {[llength $args] == 3} {
	 set I_5007 [ lindex $args 0 ]
	 set I_4959 [ expr [lindex $args 1 ] ]
	 set I_4363 [ expr [lindex $args 2] ]
     } elseif {[llength $args] == 6} {
	 set I_5007 [ lindex $args 0 ]
	 set I_4959 [ expr [lindex $args 1 ] ]
	 set I_4363 [ expr [lindex $args 2] ]
	 set dI1 [ lindex $args 3 ]
	 set dI2 [ lindex $args 4 ]
	 set dI3 [ lindex $args 5 ]
     } else {
	 ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363 ?dI1 dI2 dI3?\n\n"
	 return 0
     }

     #--- Calcul de la température : 
     set R [ expr ($I_5007+$I_4959)/$I_4363 ]
     set Te [ expr (3.29*1E4)/(log($R/8.30)) ]

     #--- Calcul de l'erreur sur le calcul :
     if {[llength $args] == 6} {
	 set dTe [ expr $Te/(log($R)-log(8.32))*(($dI1+$dI2)/($I_5007+$I_4959)+$dI3/$I_4363) ]
     } else {
	 ::console::affiche_resultat "Pas de calcul de dTe\n"
	 set dTe 0
     }

     #--- Affichage du resultat :
     ::console::affiche_resultat "Le température électronique de la nébuleuse est : $Te Kelvin ; dTe=$dTe\nR(OIII)=$R\n"
     set resul [ list $Te $dTe $R ]
     return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363 ?dI1 dI2 dI3?\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 23-01-2007
# Arguments : profil_de_raies_etalonne largeur_raie
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.104.
##########################################################

proc spc_te { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set fichier [ lindex $args 0 ]
       set largeur [ lindex $args 1 ]
       set dlargeur [ expr $largeur/2. ]

       #--- Détermination de la valeur du continuum de la raie :
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
	   set lambda 1.
       }
       #-- Raie 1 :
       set ldeb1 [ expr 5006.8-$dlargeur ]
       set lfin1 [ expr 5006.8+$dlargeur ]
       set xdeb [ expr round(($ldeb1-$lambda0)/$disp) ]
       set xfin [ expr round(($lfin1-$lambda0)/$disp) ]
       set continuum1 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Raie 2 :
       set ldeb2 [ expr 4958.9-$dlargeur ]
       set lfin2 [ expr 4958.9+$dlargeur ]
       set xdeb [ expr round(($ldeb2-$lambda0)/$disp) ]
       set xfin [ expr round(($lfin2-$lambda0)/$disp) ]
       set continuum2 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Le continuum est choisi comme la plus petite des 2 valeurs :
       if { $continuum1<=$continuum2 } {
	   set continuum $continuum1
       } else {
	   set continuum $continuum2
       }
       #set continuum [ expr 0.5*($continuum1+$continuum2) ]
       ::console::affiche_resultat "Le continuum trouvé pour ($continuum1 ; $continuum2) vaut $continuum\n"


       #--- Calcul de l'intensite des raies [OIII] :
       set I_5007 [ spc_integratec $fichier $ldeb1 $lfin1 $continuum ]
       set I_4959 [ spc_integratec $fichier $ldeb2 $lfin2 $continuum ]
       set dlargeur4363 [ expr 0.5625*$dlargeur ]
       set ldeb [ expr 4363-$dlargeur4363 ]
       set lfin [ expr 4363+$dlargeur4363 ]
       set I_4363 [ spc_integratec $fichier $ldeb $lfin $continuum ]

       #--- Calcul de la tempéreture électronique :
       set R [ expr ($I_5007+$I_4959)/$I_4363 ]
       set Te [ expr (3.29*1E4)/(log($R/8.30)) ]
       ::console::affiche_resultat "Le température électronique de la nébuleuse est : $Te Kelvin\nR(OIII)=$R\n"
       set resul [ list $Te $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_te profil_de_raies_etalonne largeur_raie\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 13-08-20052007-01-20
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
#        set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt($Te)*10^(10800/$Te))/$R-1) ]
# Nouveau modele : Astrnomie astrophysique, A. Acker, Dunod, 2005, p.278.
# REmarque importante : les raies de l'azote sont utilisées pour le calcul de Te et pas Ne. Donc cette focntion n'est pas utilisée pour l'instant.
##########################################################

proc spc_npne2 { args } {

   global audace
   global conf

   if {[llength $args] == 4 ||[llength $args] == 8 } {
       if {[llength $args] == 4 } {
	   set Te [ lindex $args 0 ]
	   set I_6584 [ lindex $args 1 ]
	   set I_6548 [ expr int([lindex $args 2 ]) ]
	   set I_5755 [ expr int([lindex $args 3]) ]
       } elseif {[llength $args] == 8 } {
	   set Te [ lindex $args 0 ]
	   set I_6584 [ lindex $args 1 ]
	   set I_6548 [ expr int([lindex $args 2 ]) ]
	   set I_5755 [ expr int([lindex $args 3]) ]
	   set dTe [ lindex $args 4 ]
	   set dI1 [ lindex $args 4 ]
	   set dI2 [ lindex $args 4 ]
	   set dI3 [ lindex $args 4 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6584 I_6548 I_5755 ?dTe dI1 dI2 dI3?\n\n"
	   return 0
       }

       #--- Calcul du rapport des raies et de la densite électronique :
       set R [ expr ($I_6584+$I_6548)/$I_5755 ]
       set Ne [ expr sqrt($Te)*1E4/25*(6.91*exp(25000/$Te)/$R-1) ]

       #--- Calcul de l'erreur sur la densité Ne :
       if {[llength $args] == 8} {
	   set dNe [ expr $Ne*(0.5*$dTe/$Te+(1/$R*(($dI1+$dI2)/($I_6584+$I_6548)+$dI3/$I_5755)+$dTe*25000/($R*$Te))*6.91*exp(25000/$Te)/(6.91/$R*exp(25000/$Te)-1)) ]
       } else {
	   ::console::affiche_resultat "Pas de calcul de dNe\n"
	   set dNe 0
       }
       

       #--- Affichage et formatage des resultats :
       ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne e-/cm^3 ; dNe=$dNe\nR(NII)=$R\n"
       set resul [ list $Ne $dNe $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_npne2 Te I_6584 I_6548 I_5755 ?dTe dI1 dI2 dI3?\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 13-08-2005
# Date de mise à jour : 23-01-2007
# Arguments : Te I_6584 I_6548 I_5755
# Modèle utilisé : Practical Amateur Spectroscopy, Stephen F. TONKIN, Springer, p.164.
##########################################################

proc spc_npne { args } {

   global audace
   global conf

   if { [llength $args] == 3 || [llength $args] == 6 } {
       if { [llength $args] == 3 } {
	   set Te [ lindex $args 0 ]
	   set I_6717 [ lindex $args 1 ]
	   set I_6731 [ lindex $args 2 ]
       } elseif { [llength $args] == 6 } {
	   set Te [ lindex $args 0 ]
	   set I_6717 [ lindex $args 1 ]
	   set I_6731 [ lindex $args 2 ]
	   set dTe [ lindex $args 3 ]
	   set dI_6717 [ lindex $args 4 ]
	   set dI_6731 [ lindex $args 5 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6717 I_6731 ?dTe dI6717 dI6731?\n\n"
       }

       #--- Calcul du rapport des raies et de la densité électronique :
       set R [ expr $I_6717/$I_6731 ]
       set Ne [ expr 100*sqrt($Te)*($R-1.49)/(5.617-12.8*$R) ]

       #--- Calcul de l'incertitude sur Ne :
       if { [llength $args] == 6 } {
	   set dNe [ expr $Ne*(0.5*$dTe/$Te+$R*($dI_6717/$I_6717-$dI_6731/$I_6731)*(12.8/abs(5.617-12.8*$R)+1/abs($R-1.49))) ]
       } else {
	   set dNe 0.
       }

       #--- Formatage et affichage du résultat :
       ::console::affiche_resultat "Le densité électronique de la nébuleuse est : $Ne e-/cm^3 ; R(SII)=$R ; dNe=$dNe\n"
       set resul [ list $Ne $dNe $R ]
       return $resul
   } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6717 I_6731 ?dTe dI6717 dI6731?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la température électronique d'une nébuleuse à raies d'émission
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 23-01-2007
# Date de mise à jour : 23-01-2007
# Arguments : 
# Modèle utilisé : A. Acker, Astronomie, méthodes et calculs, MASSON, p.105.
##########################################################

proc spc_ne { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
       set fichier [ lindex $args 0 ]
       set Te [ lindex $args 1 ]
       set largeur [ lindex $args 2 ]
       set dlargeur [ expr $largeur/2. ]

       #--- Détermination de la valeur du continuum de la raie :
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
	   set lambda 1.
       }
       #-- Raie 1 :
       set ldeb1 [ expr 6717-$dlargeur ]
       set lfin1 [ expr 6717+$dlargeur ]
       set xdeb [ expr round(($ldeb1-$lambda0)/$disp) ]
       set xfin [ expr round(($lfin1-$lambda0)/$disp) ]
       set continuum1 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Raie 2 :
       set ldeb2 [ expr 6731-$dlargeur ]
       set lfin2 [ expr 6731+$dlargeur ]
       set xdeb [ expr round(($ldeb2-$lambda0)/$disp) ]
       set xfin [ expr round(($lfin2-$lambda0)/$disp) ]
       set continuum2 [ lindex [ buf$audace(bufNo) fitgauss [ list $xdeb 1 $xfin 1 ] ] 3 ]
       #-- Le continuum est choisi comme la plus petite des 2 valeurs :
       if { $continuum1<=$continuum2 } {
	   set continuum $continuum1
       } else {
	   set continuum $continuum2
       }
       #set continuum [ expr 0.5*($continuum1+$continuum2) ]
       ::console::affiche_resultat "Le continuum trouvé pour ($continuum1 ; $continuum2) vaut $continuum\n"

       #--- Calcul de l'intensite des raies [OIII] :
       set I_6717 [ spc_integratec $fichier $ldeb1 $lfin1 $continuum ]
       set I_6731 [ spc_integratec $fichier $ldeb2 $lfin2 $continuum ]

       #--- Calcul de la tempéreture électronique :
       set R [ expr $I_6717/$I_6731 ]
       set Ne [ expr 100*sqrt($Te)*($R-1.49)/(5.617-12.8*$R) ]
       ::console::affiche_resultat "La densité électronique de la nébuleuse est : $Ne e-/cm^3 ; R(SII)=$R ; \n"
       set resul [ list $Ne $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_ne profil_de_raies_etalonne Te largeur_raie\n\n"
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

proc spc_ne2 { args } {

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
     ::console::affiche_erreur "Usage: spc_ne Te I_6584 I_6548 I_5755\n\n"
   }

}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 24-03-2007
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_ewcourbe { args } {

    global audace spcaudace
    global conf
    global tcl_platform

    set ewfile "ewcourbe"
    set ext ".dat"

    if { [llength $args]==1 } {
	set lambda [lindex $args 0 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]

	foreach fichier $fileliste {
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    #set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
	    set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	    if { [ string length $ladate ]<=10 } {
		set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE" ] 1 ]
	    }
	    set date [ mc_date2jd $ladate ]
	    #- Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
	    #lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
	    #lappend ldates [ expr round($date*10000.)/10000.-2400000.5 ]
	    lappend ldates [ expr int(($date-2400000.5)*10000.)/10000. ]
	    set results [ spc_autoew2 $fichier $lambda ]
	    lappend list_ew [ lindex $results 0 ]
	    lappend list_sigmaew [ lindex $results 1 ]
	}

	#--- Création du fichier de données
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew sew $list_sigmaew {
	    puts $file_id1 "$sdate\t$ew\t$sew"
	}
	close $file_id1

	#--- Création du script de tracage avec gnuplot :
	set ew0 [ lindex $list_ew 0 ]
	if { $ew0<0 } {
	    set invert_opt "reverse"
	} else {
	    set invert_opt "noreverse"
	}
	set titre "Evolution de la largeur equivalente EW au cours du temps"
	set legendey "Largeur equivalente EW (A)"
	set legendex "Date (JD-2450000)"
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"$spcaudace(repgp)/gp_points_err.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * $invert_opt \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
	close $file_id2
	if { $tcl_platform(os)=="Linux" } {	
	    set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	} else {
	    #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
	    set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	}

	#--- Affichage du graphe PNG :
	if { $conf(edit_viewer)!="" } {
	    set answer [ catch { exec $conf(edit_viewer) "$audace(rep_images)/ew_courbe.png" & } ]
	} else {
	    ::console::affiche_resultat "Configurer \"Editeurs/Visualisateur d'images\" pour permettre l'affichage du graphique\n"
	}


	#--- Traitement du résultat :
	return "ew_courbe.png"
    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe lambda_raie\n\n"
    }
}
#*******************************************************************************#


##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 04-08-2005
# Date de mise à jour : 10-05-2006
# Arguments : nom générique des profils de raies normalisés à 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
##########################################################

proc spc_ewcourbe_opt { args } {

    global audace spcaudace
    global conf
    global tcl_platform

    set ewfile "ewcourbe"
    set ext ".dat"

    if { [llength $args]==3 } {
	set nom_generic [ lindex $args 0 ]
	set lambda [ lindex $args 1 ]
	set largeur_raie [ lindex $args 2 ]

	set ldates ""
	set list_ew ""
	set intensite_raie 1
	set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_generic}*$conf(extension,defaut) ] ]

	foreach fichier $fileliste {
	    set fichier [ file tail $fichier ]
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	    set date [ mc_date2jd $ladate ]
	    # Ne tient que des 4 premières décimales du jour julien et retranche 50000 jours juliens
	    #lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
	    lappend ldates [ expr int(($date-2400000.5)*10000.)/10000. ]
	    # lappend ldates [ expr $date-50000. ]
	    set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	    set ldeb [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	    set disp [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	    set ldeb [ expr $lambda-0.5*$largeur_raie ]
	    set lfin [ expr $lambda+0.5*$largeur_raie ]
	    lappend list_ew [ spc_ew3 $fichier $ldeb $lfin ]
	}

	#--- Création du fichier de données
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Création du script de tracage avec gnuplot :
	set ew0 [ lindex $list_ew 0 ]
	if { $ew0<0 } {
	    set invert_opt "reverse"
	} else {
	    set invert_opt "noreverse"
	}
	set titre "Evolution de la largeur equivalente au cours du temps"
	set legendey "Largeur equivalente (A)"
	set legendex "Date (JD-2450000)"
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"$spcaudace(repgp)/gp_points.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * $invert_opt \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
	close $file_id2
	if { $tcl_platform(os)=="Linux" } {	
	    set answer [ catch { exec gnuplot $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	} else {
	    #-- wgnuplot et pgnuplot doivent etre dans le rep gp de spcaudace
	    set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${ewfile}.gp } ]
	    ::console::affiche_resultat "$answer\n"
	}

	#--- Affichage du graphe PNG :
	if { $conf(edit_viewer)!="" } {
	    set answer [ catch { exec $conf(edit_viewer) "$audace(rep_images)/ew_courbe.png" & } ]
	} else {
	    ::console::affiche_resultat "Configurer \"Editeurs/Visualisateur d'images\" pour permettre l'affichage du graphique\n"
	}

	#--- Traitement du résultat :
	return "ew_courbe.png"
    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe_opt nom_générique_profils_fits lambda_raie largeur_raie\n\n"
    }
}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur équivalente pour une série de spectres dans le répertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 18-03-2007
# Date de mise à jour : 18-03-2007
# Arguments : longueur d'onde de la raie (A), largeur de la raie (A)
##########################################################

proc spc_ewdirw { args } {

    global audace
    global conf
    global tcl_platform
    set ewfile "ewcalculs.txt"
    set ext ".txt"

    if {[llength $args] == 1} {
	#set repertoire [ lindex $args 0 ]
	set lambda [lindex $args 0 ]
	set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]

	#--- Crée le fichier des résultats :
	set file_id1 [open "$audace(rep_images)/$ewfile" w+]
	puts $file_id1 "NAME\tMJD date\tEW(wavelength's range)\tSigma(EW)\tSNR\r"
	foreach fichier $fileliste {
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    if { 1==0 } {
	    set listemotsclef [ buf$audace(bufNo) getkwds ]
	    if { [ lsearch $listemotsclef "MJD-OBS" ] !=-1 } {
		set date [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ]
		#- Ne tient que des 4 premières décimales du jour julien
		set jddate [ expr int($date*10000.)/10000.+2400000.5 ]
	    } elseif { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
		set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
		set date [ mc_date2jd $ladate ]
		set jddate [ expr int($date*10000.)/10000. ]
	    } elseif { [ lsearch $listemotsclef "DATE" ] !=-1 } {
		set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE" ] 1 ]
		set date [ mc_date2jd $ladate ]
		set jddate [ expr int($date*10000.)/10000. ]
	    }
	    }
	    #- 070707 :
	    set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
	    set date [ mc_date2jd $ladate ]
	    set jddate [ expr int(($date-2400000.5)*10000.)/10000. ]
	    #--
	    set mesure [ spc_autoew2 $fichier $lambda ]
	    set ew [ lindex $mesure 0 ]
	    set sigma_ew [ lindex $mesure 1 ]
	    set snr [ lindex $mesure 2 ]
	    set largeur_mes [ lindex $mesure 3 ]
	    puts $file_id1 "$fichier\t$jddate\t$largeur_mes=$ew A\t$sigma_ew A\t$snr\r"
	}
	close $file_id1

	#--- Fin de script :
	::console::affiche_resultat "Fichier des résultats sauvé sous $ewfile\n"
	return $ewfile
    } else {
	::console::affiche_erreur "Usage: spc_ewdirw lambda_raie \n\n"
    }
}
#*******************************************************************************#




####################################################################
# Procédure de calcul de la largeur équivalente d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26/05/2007
# Date modification : 26/05/2007
# Arguments : nom_profil_raies lambda_deb lambda_fin
####################################################################

proc spc_ew { args } {
    global conf
    global audace

    if { [llength $args] == 3 } {
	set filename [ lindex $args 0 ]
	set lambda_deb [ lindex $args 1 ]
	set lambda_fin [ lindex $args 2 ]

	spc_ew3 $filename $lambda_deb $lambda_fin
    } else {
	::console::affiche_erreur "Usage: spc_ew nom_profil_raies_calibré lamba_debut lambda_fin\n"
    }
}
#***************************************************************************#



##########################################################
# Procedure de détermination de la largeur équivalente d'une raie spectrale modelisee par une gaussienne. 
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 12-08-2005
# Date de mise à jour : 21/12/2005-18/04/2006
# Arguments : fichier .fit du profil de raie, l_debut (wavelength), l_fin (wavelength), a/e (renseigne sur raie emission ou absorption)
##########################################################

proc spc_ew1 { args } {

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
       ::console::affiche_erreur "Usage: spc_ew1 nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
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
# Procédure de calcul de la largeur équivalente d'une raie
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
	#--- Détermine le type de raie : émission ou absorption et donne un signe à EW
	if { $intensity>=1 } {
	    set ew [ expr -1.*$ew ]
	}

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set deltal [ expr abs($xfin-$xdeb) ]
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

        #--- Formatage des résultats :
	set l_fin [ expr 0.01*round($xfin*100) ]
	set l_deb [ expr 0.01*round($xdeb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des résultats :
	::console::affiche_resultat "\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short anstrom(s).\n"
	::console::affiche_resultat "SNR=$snr_short.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew angstrom.\n\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_ew2 nom_profil_raies_normalisé lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#


####################################################################
# Procédure de calcul de la largeur équivalente d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 18-03-2007
# Arguments : nom_profil_raies lanmba_dep lambda_fin
####################################################################

proc spc_ew3 { args } {
    global conf
    global audace

    if { [llength $args] == 3 } {
	set filename [ lindex $args 0 ]
	set xdeb [ lindex $args 1 ]
	set xfin [ lindex $args 2 ]

	#--- Déterminiation de la valeur du continuum :
	set icont [ spc_icontinuum $filename ]

	#--- Conversion des données en liste :
	set listevals [ spc_fits2data $filename ]
	set xvals [ lindex $listevals 0 ]
	set yvals [ lindex $listevals 1 ]

	#--- Calcul de l'aire sous la raie :
	set aire 0.
	foreach xval $xvals yval $yvals {
	    if { $xval>=$xdeb && $xval<=$xfin } {
		lappend xsel $xval
		set aire [ expr $aire+$yval-$icont ]
		lappend ysel $yval
	    }
	}
	::console::affiche_resultat "L'aire sans le continuum vaut $aire\n"

	#--- Calcul la largeur équivalente :
	#set deltal [ expr abs($xfin-$xdeb) ]
	#set dispersion_locale [ expr 1.*$deltal/[ llength $xsel ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set dispersion_locale [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #set jd [ expr 2400000.5+ [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ] ]
        set ladate [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
        set jd [ mc_date2jd $ladate ]
	set ew [ expr -1.*$aire*$dispersion_locale/$icont ]

	#--- Détermine le type de raie : émission ou absorption et donne un signe à EW
	if { 1==0 } {
	  set valsselect [ list $xsel $ysel ]
	  set intensity [ spc_aire $valsselect ]
	  if { $intensity>=1 } {
	    set ew [ expr -1.*$ew ]
	  }
	}

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set deltal [ expr abs($xfin-$xdeb) ]
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

        #--- Formatage des résultats :
	set l_fin [ expr 0.01*round($xfin*100) ]
	set l_deb [ expr 0.01*round($xdeb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des résultats :
	::console::affiche_resultat "\n"
        ::console::affiche_resultat "Date: $ladate\n"
        ::console::affiche_resultat "JD: $jd\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
	::console::affiche_resultat "SNR=$snr_short.\n\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_ew3 nom_profil_raies_normalisé lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-05-31
# Date modification : 2008-06-1
# Arguments : nom_profil_raies ?lambda_raie/ldeb lfin?
# Algo : determine ldeb et lfin par intersection du spectre filtre passe-bas avec les valeurs du continuum du spectre normalise (2 normalisations necessaires)
####################################################################

proc spc_autoew4 { args } {
   global conf
   global audace
   set precision 0.001
   #- largeur en angstroms des raies a eliminer par passebas :
   set largeur 10
   #- largeur en pixels des motifs a gommer par passe bas :
   set largeur_pbas 10
   #- deg polynome du continuum :
   set degp_conti 4

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3} {
      if { $nb_args == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
      } elseif { $nb_args == 3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew4 nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
      }

      set filename_norma [ spc_autonorma $filename ]
      if { $nb_args == 2 } {
         #--- Extraction des valeurs :
         buf$audace(bufNo) load "$audace(rep_images)/$filename"
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

         #--- Creation d'un continuum du spectre normalise :
         set filename_norm_conti [ spc_extractcont $filename_norma $degp_conti ]
         set iconti [ lindex [ spc_fits2data $filename_norm_conti ] 1 ]

         #--- Calcul un profil lisse :
         set largeur_raie [ expr 10*$cdelt1 ]
         set filename_norma_pbas [ spc_passebas $filename_norma $largeur_pbas ]
         set listevals [ spc_fits2data $filename_norma_pbas ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]
         #--- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]

         #--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
            set ycont [ lindex $iconti $i ]
	    if { [ expr abs($yval-$ycont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
            set ycont [ lindex $iconti $i ]
	    if { [ expr abs($yval-$ycont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
         }
      }
      ::console::affiche_resultat "Limites trouvees : $lambda_deb $lambda_fin\n"

      #--- Détermination de la largeur équivalente :
      set ew [ spc_ew $filename_norma $lambda_deb $lambda_fin ]
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]
      
      #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
      set snr [ spc_snr $filename ]
      set rapport [ expr $ew/$deltal ]
      if { $rapport>=1.0 } {
         set deltal [ expr $ew+0.1 ]
         ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
      }
      if { $snr != 0 } {
         set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
         #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
      } else {
         ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
         set sigma 0
      }

   if { 1==0 } {      
      #--- Effacement des fichiers temporaires :
      file delete -force "$audace(rep_images)/$filename_norma$conf(extension,defaut)"
      if { $nb_args == 2 } {
         file delete -force "$audace(rep_images)/$filename_norma_pbas$conf(extension,defaut)"
         file delete -force "$audace(rep_images)/$filename_norm_conti$conf(extension,defaut)"
      }
   }
      #--- Formatage des résultats :
      set l_fin [ expr 0.01*round($lambda_fin*100) ]
      set l_deb [ expr 0.01*round($lambda_deb*100) ]
      set delta_l [ expr 0.01*round($deltal*100) ]
      set ew_short [ expr 0.01*round($ew*100) ]
      set sigma_ew [ expr 0.01*round($sigma*100) ]
      set snr_short [ expr round($snr) ]
      
      #--- Affichage des résultats :
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
      ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
      ::console::affiche_resultat "SNR=$snr_short.\n\n"
      #set resultats [ list $ew $sigma_ew ]
      #return $ew
      set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew4 nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
   }
}
#***************************************************************************#



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-05-31
# Date modification : 2008-05-31
# Arguments : nom_profil_raies ?lambda_raie/ldeb lfin?
# Algo : determine ldeb et lfin par intersection du spectre filtre passe bas avec la valeur icont du spectre normalisé.
####################################################################

proc spc_autoew3 { args } {
   global conf
   global audace
   set precision 0.001
   #- largeur en angstroms des raies a eliminer par passebas :
   set largeur 10

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3} {
      if { $nb_args == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
      } elseif { $nb_args == 3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew3 nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
      }

      set filename_norma [ spc_autonorma $filename ]
      if { $nb_args == 2 } {
         #--- Extraction des valeurs :
         buf$audace(bufNo) load "$audace(rep_images)/$filename"
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
         set icont [ spc_icontinuum $filename_norma ]
         #set icont [ spc_icontinuum ${filename}_conti $lambda_raie ]

         #--- Calcul un profil lisse :
         set largeur_raie [ expr 10*$cdelt1 ]
         set filename_norma_pbas [ spc_passebas $filename_norma $largeur ]
         set listevals [ spc_fits2data $filename_norma_pbas ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]
         #--- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]

         #--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
         }
      }

      #--- Détermination de la largeur équivalente :
      set ew [ spc_ew $filename_norma $lambda_deb $lambda_fin ]
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]
      
      
      #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
      set snr [ spc_snr $filename ]
      set rapport [ expr $ew/$deltal ]
      if { $rapport>=1.0 } {
         set deltal [ expr $ew+0.1 ]
         ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
      }
      if { $snr != 0 } {
         set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
         #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
      } else {
         ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
         set sigma 0
      }
      
      #--- Effacement des fichiers temporaires :
      file delete -force "$audace(rep_images)/$filename_norma$conf(extension,defaut)"
      if { $nb_args == 2 } {
         file delete -force "$audace(rep_images)/$filename_norma_pbas$conf(extension,defaut)"
         # file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
      }

      #--- Formatage des résultats :
      set l_fin [ expr 0.01*round($lambda_fin*100) ]
      set l_deb [ expr 0.01*round($lambda_deb*100) ]
      set delta_l [ expr 0.01*round($deltal*100) ]
      set ew_short [ expr 0.01*round($ew*100) ]
      set sigma_ew [ expr 0.01*round($sigma*100) ]
      set snr_short [ expr round($snr) ]
      
      #--- Affichage des résultats :
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
      ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
      ::console::affiche_resultat "SNR=$snr_short.\n\n"
      #set resultats [ list $ew $sigma_ew ]
      #return $ew
      set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew3 nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
   }
}
#***************************************************************************#




####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew1 { args } {
   global conf
   global audace
   set precision 0.01

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3} {
      if { $nb_args == 2 } {
         set filename_in [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
         set lambda_deb [ expr $lambda_raie-20 ]
         set lambda_fin [ expr $lambda_raie+20 ]
      } elseif { $nb_args == 3 } {
         set filename_in [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew1 nom_profil_raies lambda_raie/lambda_deb lambda_fin\n"
      }

      set filename [ spc_autonorma "$filename_in" ]
      if { $nb_args == 2 } {
         #--- Extraction des valeurs :
         set listevals [ spc_fits2data $filename ]
         set lambdas [ lindex $listevals 0 ]
         set intensities [ lindex $listevals 1 ]
         set len [ llength $lambdas ]
         
         #--- Trouve l'indice de la raie recherche dans la liste
         set i_lambda [ lsearch -glob $lambdas ${lambda_raie}* ]
         # ::console::affiche_resultat "Indice de la raie : $i_lambda\n"
         
         #--- Déterminiation de la valeur du continuum :
         # set icont 1.0
         set icont [ spc_icontinuum $filename ]

         #--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_fin [ lindex $lambdas $i ]
               break
	    }
         }

         #--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
         for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr abs($yval-$icont) ] <= $precision } {
               set lambda_deb [ lindex $lambdas $i ]
               break
	    }
	    #::console::affiche_resultat "$diff\n"
         }
      }

      #--- Détermination de la largeur équivalente :
      set ew [ spc_ew $filename $lambda_deb $lambda_fin ]
      set deltal [ expr abs($lambda_fin-$lambda_deb) ]
      
      
      #--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
      set snr [ spc_snr $filename ]
      set rapport [ expr $ew/$deltal ]
      if { $rapport>=1.0 } {
         set deltal [ expr $ew+0.1 ]
         ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
      }
      if { $snr != 0 } {
         set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
         #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
      } else {
         ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
         set sigma 0
      }
      
      #--- Formatage des résultats :
      set l_fin [ expr 0.01*round($lambda_fin*100) ]
      set l_deb [ expr 0.01*round($lambda_deb*100) ]
      set delta_l [ expr 0.01*round($deltal*100) ]
      set ew_short [ expr 0.01*round($ew*100) ]
      set sigma_ew [ expr 0.01*round($sigma*100) ]
      set snr_short [ expr round($snr) ]
      
      #--- Affichage des résultats :
      file delete -force "$audace(rep_images)/$filename$conf(extension,defaut)"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
      ::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
      ::console::affiche_resultat "SNR=$snr_short.\n\n"
      #set resultats [ list $ew $sigma_ew ]
      #return $ew
      set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_autoew1 nom_profil_raies lambda_raie/lambda_deb lambda_fin\n"
   }
}
#***************************************************************************#

#-- CAlcul incertitude sur EW
#- le choix de lambda1 et lambda 2 est critique car il conditionne tout : largeur equivalente et incertitude;
#-idem pour les parametres de lissage qui te permettent de separer signal et bruit



####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-04-2008
# Date modification : 04-04-2008
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew { args } {
   global conf
   global audace

   set nb_args [ llength $args ]
   if { $nb_args == 2 || $nb_args == 3} {
      if { $nb_args == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_raie [ lindex $args 1 ]
      } elseif { $nb_args == 3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set lambda_deb [ lindex $args 1 ]
         set lambda_fin [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_autoew nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
         return 0
      }

       #--- Normalisation par extraction du continuum :
       #-- Normalisation pour spc_autoew1 :
       # set sp_norma [ spc_autonorma "$filename" ]
       #-- autoew3 et 4 normalisent eux-meme.
       set sp_norma "$filename"

       #--- Mesure EW par intersection a I=1 :
       if { $nb_args == 2 } {
          set results_ew [ spc_autoew3 "$sp_norma" $lambda_raie ]
       } elseif  { $nb_args == 3 } {
          set results_ew [ spc_autoew3 "$sp_norma" $lambda_deb $lambda_fin ]
       }

       #--- Traitement des resultats :
       return $results_ew
    } else {
       ::console::affiche_erreur "Usage: spc_autoew nom_profil_raies_normalisé lambda_raie/lambda_deb lambda_fin\n"
    }
}
#***************************************************************************#




####################################################################
# Calcul la largeur equivalenbte d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-03-2007
# Date modification : 18-03-2007
# Arguments : nom_profil_raies lambda_raie
####################################################################

proc spc_autoew2 { args } {
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


	#--- Déterminiation de la valeur du continuum :
	# set icont 1.0
	set icont [ spc_icontinuum $filename ]

	#--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalisé à 1 :
	for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_fin [ lindex $lambdas $i ]
		break
	    }
	}

	#--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalisé à 1 :
	for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_deb [ lindex $lambdas $i ]
		break
	    }
	    #::console::affiche_resultat "$diff\n"
	}

	#--- Détermination de la largeur équivalente :
	set ew [ spc_ew3 $filename $lambda_deb $lambda_fin ]
	set deltal [ expr abs($lambda_fin-$lambda_deb) ]


	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'intégration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
	    set sigma 0
	}

        #--- Formatage des résultats :
	set l_fin [ expr 0.01*round($lambda_fin*100) ]
	set l_deb [ expr 0.01*round($lambda_deb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des résultats :
	#::console::affiche_resultat "\n"
	#::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short anstrom(s).\n"
	#::console::affiche_resultat "SNR=$snr_short.\n"
	#::console::affiche_resultat "Sigma(EW)=$sigma_ew angstrom.\n\n"
	set results [ list $ew_short $sigma_ew $snr_short "EW($delta_l=$l_deb-$l_fin)" ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_autoew2 nom_profil_raies_normalisé lambda_raie\n"
    }
}
#***************************************************************************#


####################################################################
# Procédure de calcul d'intensité d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 24-02-2008
# Date modification : 24-02-2008
# Arguments : nom_profil_raies lambda_raie_1 lambda_raie_2 largeur_raie
####################################################################

proc spc_vrmes { args } {
    global conf
    global audace
    set precision 0.01
    set nbargs [llength $args]
    if { $nbargs <= 5 } {
	if { $nbargs == 5 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set lambda_raie_1 [ lindex $args 1 ]
	    set lambda_raie_2 [ lindex $args 2 ]
	    set largeur [ lindex $args 3 ]
	    set prms [ lindex $args 4 ]
	} elseif { $nbargs == 4 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set lambda_raie_1 [ lindex $args 1 ]
	    set lambda_raie_2 [ lindex $args 2 ]
	    set largeur [ lindex $args 3 ]
	    set prms 150
	} else {
           ::console::affiche_erreur "Usage: spc_vrmes nom_profil_raies lambda_raie_Violet lambda_raie_Rouge largeur_raie ?pourcent_RMS_rejet (150)?\n"
           return ""
	}

	#--- Recuperation des infos du spectre :
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	set disper [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]

        #--- Extraction des donnees :
        set contenu [ spc_fits2data $filename ]
        set abscisses [ lindex $contenu 0 ]
        set intensites [ lindex $contenu 1 ]

	#--- Creation des donnees de la premiere raie :
	set xdeb [ expr $lambda_raie_1-0.5*$largeur ]
	set xfin [ expr $lambda_raie_1+0.5*$largeur ]
	set nabscisses1 ""
	set nintensites1 ""
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
		if { $abscisse <= $xfinl } {
		    lappend nabscisses1 $abscisse
		    lappend nintensites1 $intensite
		    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
		    incr k
		}
	    }
	}
	set len1 $k

	#--- Creation des donnees de la seconde raie :
	set xdeb [ expr $lambda_raie_2-0.5*$largeur ]
	set xfin [ expr $lambda_raie_2+0.5*$largeur ]
	set nabscisses2 ""
	set nintensites2 ""
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
		if { $abscisse <= $xfinl } {
		    lappend nabscisses2 $abscisse
		    lappend nintensites2 $intensite
		    # buf$audace(bufNo) setpix [list [expr $k+1] 1] $intensite
		    incr k
		}
	    }
	}
	set len2 $k

	#--- Détermination du maximum de la raie 1 par parabole :
	set coefs [ spc_ajustpolynome $nabscisses1 $nintensites1 2 150 o ]
	set a [ lindex $coefs 0 ]
	set b [ lindex $coefs 1 ]
	set c [ lindex $coefs 2 ]
	set xm1 [ expr -$b/(2.*$c) ]
	set imax1 [ expr $a+$b*$xm1+$c*$xm1*$xm1 ]

	#--- Détermination du maximum de la raie 1 par parabole :
	set coefs [ spc_ajustpolynome $nabscisses2 $nintensites2 2 150 o ]
	set a [ lindex $coefs 0 ]
	set b [ lindex $coefs 1 ]
	set c [ lindex $coefs 2 ]
	set xm2 [ expr -$b/(2.*$c) ]
	set imax2 [ expr $a+$b*$xm2+$c*$xm2*$xm2 ]

	#--- Utilisation des résultats :
	#-- Raie V :
	set ldeb1 [ lindex $nabscisses1 0 ]
	set lfin1 [ lindex $nabscisses1 [ expr $len1-1 ] ]
	set xc1 [ expr $xm1*($lfin1-$ldeb1)+$ldeb1 ]

	#-- Raie R :
	set ldeb2 [ lindex $nabscisses2 0 ]
	set lfin2 [ lindex $nabscisses2 [ expr $len2-1 ] ]
	set xc2 [ expr $xm2*($lfin2-$ldeb2)+$ldeb2 ]

	#-- V/R :
	set vr [ expr $imax1/$imax2 ]
	::console::affiche_resultat "\n\# Raie V de centre $xc1 et d'intensité $imax1.\n"
	::console::affiche_resultat "Raie R de centre $xc2 et d'intensité $imax2.\n"
	::console::affiche_resultat "V/R=$vr.\n"
 	return $vr
    } else {
	::console::affiche_erreur "Usage: spc_vrmes nom_profil_raies lambda_raie_Violet lambda_raie_Rouge largeur_raie ?pourcent_RMS_rejet (150)?\n"
    }
}
#***************************************************************************#    










#==========================================================================#
#           Acnciennes implémentations                                     #
#==========================================================================#

