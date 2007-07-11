
# Proc�dures d'exploitation astrophysique des spectres
# A130 : source $audace(rep_scripts)/spcaudace/spc_astrophys.tcl
# A140 : source [ file join $audace(rep_plugin) tool spectro spcaudace spc_astrophys.tcl ]

#************* Liste des focntions **********************#
#
# spc_vradiale : calcul la vitesse radiale � partir de la FWHM de la raie mod�lis�e par une gaussienne
# spc_vexp : calcul la vitesse d'expansion � partir de la FWHM de la raie mod�lis�e par une gaussienne
# spc_vrot : calcul la vitesse de rotation � partir de la FWHM de la raie mod�lis�e par une gaussienne
# spc_npte : calcul la temp�rature �lectronique d'une n�buleuse
# spc_npne : calcul la densit� �lectronique d'une n�buleuse
# spc_ne : calcul de la densit� �lectronique. Fonction applicable pour les n�buleuses � spectre d'�mission.
# spc_te : calcul de la temp�rature �lectronique. Fonction applicable pour les n�buleuses � spectre d'�mission.
#
##########################################################



##########################################################
# Procedure de determination de la vitesse radiale en km/s � l'aide du d�calage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-07-2006
# Date de mise � jour : 13-07-2006
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
       ::console::affiche_erreur "Usage: spc_vdoppler delta_lambda lambda_raie_r�f�rence\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de la vitesse h�liocentrique pour une correction de la vitesse radiale
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 08-02-2007
# Date de mise � jour : 08-02-2007
# Arguments : profil_raies_�talonn� lambda_raie_approch� lambda_r�f ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
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
	   ::console::affiche_erreur "Usage: spc_vhelio profil_raies_�talonn� ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }

       #--- Charge les mots clefs :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre"
       set listemotsclef [ buf$audace(bufNo) getkwds ]

       #--- D�termine les param�tres de date et de coordonn�es si n�cessaire :
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
	       ::console::affiche_resultat "Aucune corrdonn�es trouv�e.\n"
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

       #--- Calcul de la vitesse h�liocentrique :
       set vhelio [ lindex [ mc_baryvel $datef $raf $decf J2000.0 ] 0 ]
       set deltal [ expr round($vhelio*$lambda_ref/300000*$precision)/$precision ]
       #--- Recherche la dispersion :
       if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	   set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
	   set erreurv [ expr round($precision*$dispersion*300000/$lambda_ref)/$precision ]
       } else {
	   set erreurv 0
       }


       #--- Formatage du r�sultat :
       #::console::affiche_resultat "La vitesse h�liocentrique pour l'objet $raf ; $decf � la date du $datef vaut :\n$vhelio�$erreurv km/s=$deltal�$dispersion A\n"
       ::console::affiche_resultat "La vitesse h�liocentrique pour l'objet $raf ; $decf � la date du $datef vaut :\n$vhelio km/s <-> $deltal A\n"
       return $vhelio
   } else {
	   ::console::affiche_erreur "Usage: spc_vhelio profil_raies_�talonn� ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la vitesse radiale en km/s � l'aide du d�calage d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 08-02-2007
# Date de mise � jour : 08-02-2007
# Arguments : profil_raies_�talonn�, lambda_raie_approch�, ?
##########################################################

proc spc_vradiale { args } {

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
	   ::console::affiche_erreur "Usage: spc_vradiale profil_raies_�talonn� type_raie (e/a) lambda_raie_approch� lambda_r�f ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }


       #--- Calcul la correction h�liocentrique :
       # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
       if { [llength $args] == 4 } {
	   set vhelio [ spc_vhelio $spectre ]
       } elseif { [llength $args] == 10 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s ]
       } elseif { [llength $args] == 13 } {
	   set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s $dd $mm $aaaa ]
       } else {
	   ::console::affiche_erreur "Impossible de calculer vh�lio ; Usage: spc_vradiale profil_raies_�talonn� type_raie (e/a) lambda_raie_approch� lambda_r�f ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }

       #--- Centre gaussien de la raie �tudi� :
       set lambda_centre [ spc_autocentergaussl $spectre $lambda_approchee $typeraie ]
       set delta_lambda [ expr $lambda_centre-$lambda_ref ]

       #--- Calcul la vitesse radiale :
       set vrad [ expr 299792.458*$delta_lambda/$lambda_ref ]
       set vradcorrigee [ expr $vrad+$vhelio ]

       #--- Formatage du r�sultat :
       ::console::affiche_resultat "La vitesse radiale de l'objet est : $vradcorrigee km/s (Vrad=$vrad km/s, Vhelio=$vhelio km/s)\n"
       set results [ list $vradcorrigee $vrad $vhelio ]
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_vradiale profil_raies_�talonn� type_raie (e/a) lambda_raie_approch� lambda_r�f ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#




##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 13-08-2005
# Arguments : I_5007 I_4959 I_4363
# Mod�le utilis� : A. Acker, Astronomie, m�thodes et calculs, MASSON, p.104.
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

     #--- Calcul de la temp�rature : 
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
     ::console::affiche_resultat "Le temp�rature �lectronique de la n�buleuse est : $Te Kelvin ; dTe=$dTe\nR(OIII)=$R\n"
     set resul [ list $Te $dTe $R ]
     return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_npte I_5007 I_4959 I_4363 ?dI1 dI2 dI3?\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 23-01-2007
# Arguments : profil_de_raies_etalonne largeur_raie
# Mod�le utilis� : A. Acker, Astronomie, m�thodes et calculs, MASSON, p.104.
##########################################################

proc spc_te { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set fichier [ lindex $args 0 ]
       set largeur [ lindex $args 1 ]
       set dlargeur [ expr $largeur/2. ]

       #--- D�termination de la valeur du continuum de la raie :
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
       ::console::affiche_resultat "Le continuum trouv� pour ($continuum1 ; $continuum2) vaut $continuum\n"


       #--- Calcul de l'intensite des raies [OIII] :
       set I_5007 [ spc_integratec $fichier $ldeb1 $lfin1 $continuum ]
       set I_4959 [ spc_integratec $fichier $ldeb2 $lfin2 $continuum ]
       set dlargeur4363 [ expr 0.5625*$dlargeur ]
       set ldeb [ expr 4363-$dlargeur4363 ]
       set lfin [ expr 4363+$dlargeur4363 ]
       set I_4363 [ spc_integratec $fichier $ldeb $lfin $continuum ]

       #--- Calcul de la temp�reture �lectronique :
       set R [ expr ($I_5007+$I_4959)/$I_4363 ]
       set Te [ expr (3.29*1E4)/(log($R/8.30)) ]
       ::console::affiche_resultat "Le temp�rature �lectronique de la n�buleuse est : $Te Kelvin\nR(OIII)=$R\n"
       set resul [ list $Te $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_te profil_de_raies_etalonne largeur_raie\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 13-08-20052007-01-20
# Arguments : Te I_6584 I_6548 I_5755
# Mod�le utilis� : Practical Amateur Spectroscopy,�Stephen F. TONKIN, Springer, p.164.
#        set Ne [ expr 1/(2.9*1E(-3))*((8.5*sqrt($Te)*10^(10800/$Te))/$R-1) ]
# Nouveau modele : Astrnomie astrophysique, A. Acker, Dunod, 2005, p.278.
# REmarque importante : les raies de l'azote sont utilis�es pour le calcul de Te et pas Ne. Donc cette focntion n'est pas utilis�e pour l'instant.
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

       #--- Calcul du rapport des raies et de la densite �lectronique :
       set R [ expr ($I_6584+$I_6548)/$I_5755 ]
       set Ne [ expr sqrt($Te)*1E4/25*(6.91*exp(25000/$Te)/$R-1) ]

       #--- Calcul de l'erreur sur la densit� Ne :
       if {[llength $args] == 8} {
	   set dNe [ expr $Ne*(0.5*$dTe/$Te+(1/$R*(($dI1+$dI2)/($I_6584+$I_6548)+$dI3/$I_5755)+$dTe*25000/($R*$Te))*6.91*exp(25000/$Te)/(6.91/$R*exp(25000/$Te)-1)) ]
       } else {
	   ::console::affiche_resultat "Pas de calcul de dNe\n"
	   set dNe 0
       }
       

       #--- Affichage et formatage des resultats :
       ::console::affiche_resultat "Le densit� �lectronique de la n�buleuse est : $Ne e-/cm^3 ; dNe=$dNe\nR(NII)=$R\n"
       set resul [ list $Ne $dNe $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_npne2 Te I_6584 I_6548 I_5755 ?dTe dI1 dI2 dI3?\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 23-01-2007
# Arguments : Te I_6584 I_6548 I_5755
# Mod�le utilis� : Practical Amateur Spectroscopy,�Stephen F. TONKIN, Springer, p.164.
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

       #--- Calcul du rapport des raies et de la densit� �lectronique :
       set R [ expr $I_6717/$I_6731 ]
       set Ne [ expr 100*sqrt($Te)*($R-1.49)/(5.617-12.8*$R) ]

       #--- Calcul de l'incertitude sur Ne :
       if { [llength $args] == 6 } {
	   set dNe [ expr $Ne*(0.5*$dTe/$Te+$R*($dI_6717/$I_6717-$dI_6731/$I_6731)*(12.8/abs(5.617-12.8*$R)+1/abs($R-1.49))) ]
       } else {
	   set dNe 0.
       }

       #--- Formatage et affichage du r�sultat :
       ::console::affiche_resultat "Le densit� �lectronique de la n�buleuse est : $Ne e-/cm^3 ; R(SII)=$R ; dNe=$dNe\n"
       set resul [ list $Ne $dNe $R ]
       return $resul
   } else {
	   ::console::affiche_erreur "Usage: spc_npne Te I_6717 I_6731 ?dTe dI6717 dI6731?\n\n"
   }
}
#*******************************************************************************#



##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 23-01-2007
# Date de mise � jour : 23-01-2007
# Arguments : 
# Mod�le utilis� : A. Acker, Astronomie, m�thodes et calculs, MASSON, p.105.
##########################################################

proc spc_ne { args } {

   global audace
   global conf

   if {[llength $args] == 3} {
       set fichier [ lindex $args 0 ]
       set Te [ lindex $args 1 ]
       set largeur [ lindex $args 2 ]
       set dlargeur [ expr $largeur/2. ]

       #--- D�termination de la valeur du continuum de la raie :
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
       ::console::affiche_resultat "Le continuum trouv� pour ($continuum1 ; $continuum2) vaut $continuum\n"

       #--- Calcul de l'intensite des raies [OIII] :
       set I_6717 [ spc_integratec $fichier $ldeb1 $lfin1 $continuum ]
       set I_6731 [ spc_integratec $fichier $ldeb2 $lfin2 $continuum ]

       #--- Calcul de la temp�reture �lectronique :
       set R [ expr $I_6717/$I_6731 ]
       set Ne [ expr 100*sqrt($Te)*($R-1.49)/(5.617-12.8*$R) ]
       ::console::affiche_resultat "La densit� �lectronique de la n�buleuse est : $Ne e-/cm^3 ; R(SII)=$R ; \n"
       set resul [ list $Ne $R ]
       return $resul
   } else {
     ::console::affiche_erreur "Usage: spc_ne profil_de_raies_etalonne Te largeur_raie\n\n"
   }

}
#*******************************************************************************#



##########################################################
# Procedure de determination de la temp�rature �lectronique d'une n�buleuse � raies d'�mission
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 13-08-2005
# Date de mise � jour : 13-08-2005
# Arguments : Te I_6584 I_6548 I_5755
# Mod�le utilis� : Practical Amateur Spectroscopy,�Stephen F. TONKIN, Springer, p.164.
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
     ::console::affiche_resultat "Le densit� �lectronique de la n�buleuse est : $Ne Kelvin\n"
     return $Ne
   } else {
     ::console::affiche_erreur "Usage: spc_ne Te I_6584 I_6548 I_5755\n\n"
   }

}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur �quivalente pour une s�rie de spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 04-08-2005
# Date de mise � jour : 24-03-2007
# Arguments : nom g�n�rique des profils de raies normalis�s � 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
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
	set fileliste [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ]

	foreach fichier $fileliste {
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set date [ lindex [buf$audace(bufNo) getkwd "MJD-OBS"] 1 ]
	    # Ne tient que des 4 premi�res d�cimales du jour julien et retranche 50000 jours juliens
	    lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
	    # lappend ldates [ expr $date-50000. ]
	    #lappend list_ew [ expr -1.*[ spc_autoew $fichier $lambda ] ]
	    lappend list_ew [ spc_autoew $fichier $lambda ]
	}

	#--- Cr�ation du fichier de donn�es
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Cr�ation du script de tracage avec gnuplot
	set titre "Evolution de la largeur equivalente au cours du temps"
	set legendey "Largeur equivalente (A)"
	set legendex "Date (JD-2450000)"
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"$spcaudace(repgp)/gp_points.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * * \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
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


	#--- Traitement du r�sultat :
	return "ew_courbe.png"
    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe lambda_raie\n\n"
    }
}
#*******************************************************************************#


##########################################################
# Procedure de tracer de largeur �quivalente pour une s�rie de spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 04-08-2005
# Date de mise � jour : 10-05-2006
# Arguments : nom g�n�rique des profils de raies normalis�s � 1, longueur d'onde de la raie (A), largeur de la raie (A), type de raie (a/e)
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
	set fileliste [ glob -dir $audace(rep_images) ${nom_generic}*$conf(extension,defaut) ]

	foreach fichier $fileliste {
	    set fichier [ file tail $fichier ]
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set date [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ]
	    # Ne tient que des 4 premi�res d�cimales du jour julien et retranche 50000 jours juliens
	    lappend ldates [ expr int($date*10000.)/10000.-50000.+0.5 ]
	    # lappend ldates [ expr $date-50000. ]
	    set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	    set ldeb [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	    set disp [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	    set ldeb [ expr $lambda-0.5*$largeur_raie ]
	    set lfin [ expr $lambda+0.5*$largeur_raie ]
	    lappend list_ew [ spc_ew3 $fichier $ldeb $lfin ]
	}

	#--- Cr�ation du fichier de donn�es
	# ::console::affiche_resultat "$ldates \n $list_ew\n"
	set file_id1 [open "$audace(rep_images)/${ewfile}.dat" w+]
	foreach sdate $ldates ew $list_ew {
	    puts $file_id1 "$sdate\t$ew"
	}
	close $file_id1

	#--- Cr�ation du script de tracage avec gnuplot
	set titre "Evolution de la largeur equivalente au cours du temps"
	set legendey "Largeur equivalente (A)"
	set legendex "Date (JD-2450000)"
	set file_id2 [open "$audace(rep_images)/${ewfile}.gp" w+]
	puts $file_id2 "call \"$spcaudace(repgp)/gp_points.cfg\" \"$audace(rep_images)/${ewfile}.dat\" \"$titre\" * * * * * \"$audace(rep_images)/ew_courbe.png\" \"$legendex\" \"$legendey\" "
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

	#--- Traitement du r�sultat :
	return "ew_courbe.png"
    } else {
	::console::affiche_erreur "Usage: spc_ewcourbe_opt nom_g�n�rique_profils_normalis�s_fits lambda_raie largeur_raie\n\n"
    }
}
#*******************************************************************************#




##########################################################
# Procedure de tracer de largeur �quivalente pour une s�rie de spectres dans le r�pertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 18-03-2007
# Date de mise � jour : 18-03-2007
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

	#--- Cr�e le fichier des r�sultats :
	set file_id1 [open "$audace(rep_images)/$ewfile" w+]
	puts $file_id1 "NAME\tMJD date\tEW(wavelength's range)\tSigma(EW)\tSNR\r"
	foreach fichier $fileliste {
	    ::console::affiche_resultat "\nTraitement de $fichier\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set listemotsclef [ buf$audace(bufNo) getkwds ]
	    if { [ lsearch $listemotsclef "MJD-OBS" ] !=-1 } {
		set date [ lindex [ buf$audace(bufNo) getkwd "MJD-OBS" ] 1 ]
		#- Ne tient que des 4 premi�res d�cimales du jour julien
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
	    set mesure [ spc_autoew2 $fichier $lambda ]
	    set ew [ lindex $mesure 0 ]
	    set sigma_ew [ lindex $mesure 1 ]
	    set snr [ lindex $mesure 2 ]
	    puts $file_id1 "$fichier\t$jddate\t$ew\t$sigma_ew\t$snr\r"
	}
	close $file_id1

	#--- Fin de script :
	::console::affiche_resultat "Fichier des r�sultats sauv� sous $ewfile\n"
	return $ewfile
    } else {
	::console::affiche_erreur "Usage: spc_ewdirw lambda_raie \n\n"
    }
}
#*******************************************************************************#




####################################################################
# Proc�dure de calcul de la largeur �quivalente d'une raie
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
	set xdeb [ lindex $args 1 ]
	set xfin [ lindex $args 2 ]

	spc_ew3 $filename $xdeb $xfin
    } else {
	::console::affiche_erreur "Usage: spc_ew nom_profil_raies_calibr� lanmba_debutg lambda_fin\n"
    }
}
#***************************************************************************#



##########################################################
# Procedure de d�termination de la largeur �quivalente d'une raie spectrale modelisee par une gaussienne. 
#
# Auteur : Benjamin MAUCLAIRE
# Date de cr�ation : 12-08-2005
# Date de mise � jour : 21/12/2005-18/04/2006
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
       #- 1.675x-0.904274 : coefficent de r�ajustement par rapport a Midas.
       #set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*1.6751-1.15 ]
       # Klotz : 060416, A=imax*sqrt(pi)*sigma, GOOD
       set aeqw [ expr sqrt(acos(-1.0)/(8.0*log(2.0)))*$fwhm*$imax ]
       # A=sqrt(sigma*pi)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(sqrt(8.0*log(2.0)))) ]
       # A=sqrt(sigma*pi/2) car exp(-x/sigma)^2 et non exp(-x^2/2*sigma^2)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(2*sqrt(8.0*log(2.0)))) ]
       # A=sqrt(pi/2)*sigma, v�rit� calcul� pour exp(-x/sigma)^2
       #set aeqw [ expr sqrt(acos(-1.0)/(16.0*log(2.0)))*$fwhm ]

       if { [string compare $type "a"] == 0 } {
	   set eqw $aeqw
       } elseif { [string compare $type "e"] == 0 } {
	   set eqw [ expr (-1.0)*$aeqw ]
       }
       ::console::affiche_resultat "La largeur �quivalente de la raie est : $eqw angstroms\n"
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
       #- 1.675x-0.904274 : coefficent de r�ajustement par rapport a Midas.
       #set aeqw [ expr sqrt((acos(-1.0)*$fwhm)/(8.0*sqrt(log(2.0))))*1.6751-1.15 ]
       # Klotz : 060416, A=imax*sqrt(pi)*sigma, GOOD
       set aeqw [ expr sqrt(acos(-1.0)/(8.0*log(2.0)))*$fwhm*$imax ]
       # A=sqrt(sigma*pi)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(sqrt(8.0*log(2.0)))) ]
       # A=sqrt(sigma*pi/2) car exp(-x/sigma)^2 et non exp(-x^2/2*sigma^2)
       #set aeqw [ expr sqrt(acos(-1.0)*$fwhm/(2*sqrt(8.0*log(2.0)))) ]
       # A=sqrt(pi/2)*sigma, v�rit� calcul� pour exp(-x/sigma)^2
       #set aeqw [ expr sqrt(acos(-1.0)/(16.0*log(2.0)))*$fwhm ]

       if { [string compare $type "a"] == 0 } {
	   set eqw $aeqw
       } elseif { [string compare $type "e"] == 0 } {
	   set eqw [ expr (-1.0)*$aeqw ]
       }
       ::console::affiche_resultat "La largeur �quivalente de la raie est : $eqw angstroms\n"
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
     ::console::affiche_resultat "La largeur �quivalente de la raie est : $eqw angstroms\n"
     return $eqw

   } else {
     ::console::affiche_erreur "Usage: spc_ew nom_fichier (de type fits et sans extension) x_debut x_fin a/e\n\n"
   }
}
#****************************************************************#



####################################################################
# Proc�dure de calcul de la largeur �quivalente d'une raie
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

	#--- Conversion des donn�es en liste :
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
	#--- D�termine le type de raie : �mission ou absorption et donne un signe � EW
	if { $intensity>=1 } {
	    set ew [ expr -1.*$ew ]
	}

	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollman) :
	set deltal [ expr abs($xfin-$xdeb) ]
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'int�gration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

        #--- Formatage des r�sultats :
	set l_fin [ expr 0.01*round($xfin*100) ]
	set l_deb [ expr 0.01*round($xdeb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des r�sultats :
	::console::affiche_resultat "\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short anstrom(s).\n"
	::console::affiche_resultat "SNR=$snr_short.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew angstrom.\n\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_ew2 nom_profil_raies_normalis� lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#


####################################################################
# Proc�dure de calcul de la largeur �quivalente d'une raie
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

	#--- D�terminiation de la valeur du continuum :
	set icont [ spc_icontinuum $filename ]

	#--- Conversion des donn�es en liste :
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

	#--- Calcul la largeur �quivalente :
	#set deltal [ expr abs($xfin-$xdeb) ]
	#set dispersion_locale [ expr 1.*$deltal/[ llength $xsel ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$filename"
	set dispersion_locale [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	set ew [ expr -1.*$aire*$dispersion_locale/$icont ]

	#--- D�termine le type de raie : �mission ou absorption et donne un signe � EW
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
	    ::console::affiche_resultat "Attention : largeur d'int�gration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n" ]
	    set sigma 0
	}

        #--- Formatage des r�sultats :
	set l_fin [ expr 0.01*round($xfin*100) ]
	set l_deb [ expr 0.01*round($xdeb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des r�sultats :
	::console::affiche_resultat "\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
	::console::affiche_resultat "SNR=$snr_short.\n\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_ew3 nom_profil_raies_normalis� lanmba_dep lambda_fin\n"
    }
}
#***************************************************************************#



####################################################################
# Proc�dure de calcul d'intensit� d'une raie
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


	#--- D�terminiation de la valeur du continuum :
	# set icont 1.0
	set icont [ spc_icontinuum $filename ]

	#--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalis� � 1 :
	for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_fin [ lindex $lambdas $i ]
		break
	    }
	}

	#--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalis� � 1 :
	for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_deb [ lindex $lambdas $i ]
		break
	    }
	    #::console::affiche_resultat "$diff\n"
	}

	#--- D�termination de la largeur �quivalente :
	set ew [ spc_ew3 $filename $lambda_deb $lambda_fin ]
	set deltal [ expr abs($lambda_fin-$lambda_deb) ]


	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'int�gration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
	    set sigma 0
	}

        #--- Formatage des r�sultats :
	set l_fin [ expr 0.01*round($lambda_fin*100) ]
	set l_deb [ expr 0.01*round($lambda_deb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des r�sultats :
	::console::affiche_resultat "\n"
	::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short A.\n"
	::console::affiche_resultat "Sigma(EW)=$sigma_ew A.\n"
	::console::affiche_resultat "SNR=$snr_short.\n\n"
	return $ew
    } else {
	::console::affiche_erreur "Usage: spc_autoew nom_profil_raies_normalis� lambda_raie\n"
    }
}
#***************************************************************************#

#-- CAlcul incertitude sur EW
#- le choix de lambda1 et lambda 2 est critique car il conditionne tout : largeur equivalente et incertitude;
#-idem pour les parametres de lissage qui te permettent de separer signal et bruit



####################################################################
# Proc�dure de calcul d'intensit� d'une raie
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


	#--- D�terminiation de la valeur du continuum :
	# set icont 1.0
	set icont [ spc_icontinuum $filename ]

	#--- Recherche la longueur d'onde d'intersection du bord rouge de la raie avec le continuum normalis� � 1 :
	for { set i $i_lambda } { $i<$len } { incr i } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_fin [ lindex $lambdas $i ]
		break
	    }
	}

	#--- Recherche la longueur d'onde d'intersection du bord bleu de la raie avec le continuum normalis� � 1 :
	for { set i $i_lambda } { $i>=0 } { set i [ expr $i-1 ] } { 
	    set yval [ lindex $intensities $i ]
	    if { [ expr $yval-$icont ]<=$precision } {
		set lambda_deb [ lindex $lambdas $i ]
		break
	    }
	    #::console::affiche_resultat "$diff\n"
	}

	#--- D�termination de la largeur �quivalente :
	set ew [ spc_ew3 $filename $lambda_deb $lambda_fin ]
	set deltal [ expr abs($lambda_fin-$lambda_deb) ]


	#--- Calcul de l'erreur (sigma) sur la mesure (doc Ernst Pollmann) :
	set snr [ spc_snr $filename ]
	set rapport [ expr $ew/$deltal ]
	if { $rapport>=1.0 } {
	    set deltal [ expr $ew+0.1 ]
	    ::console::affiche_resultat "Attention : largeur d'int�gration<EW !\n"
	}
	if { $snr != 0 } {
	    set sigma [ expr sqrt(1+1/(1-$ew/$deltal))*(($deltal-$ew)/$snr) ]
	    #set sigma [ expr sqrt(1+1/(1-abs($ew)/$deltal))*(($deltal-abs($ew))/$snr) ]
	} else {
	    ::console::affiche_resultat "Incertitude non calculable car SNR non calculable\n"
	    set sigma 0
	}

        #--- Formatage des r�sultats :
	set l_fin [ expr 0.01*round($lambda_fin*100) ]
	set l_deb [ expr 0.01*round($lambda_deb*100) ]
	set delta_l [ expr 0.01*round($deltal*100) ]
	set ew_short [ expr 0.01*round($ew*100) ]
	set sigma_ew [ expr 0.01*round($sigma*100) ]
	set snr_short [ expr round($snr) ]

	#--- Affichage des r�sultats :
	#::console::affiche_resultat "\n"
	#::console::affiche_resultat "EW($delta_l=$l_deb-$l_fin)=$ew_short anstrom(s).\n"
	#::console::affiche_resultat "SNR=$snr_short.\n"
	#::console::affiche_resultat "Sigma(EW)=$sigma_ew angstrom.\n\n"
	set results [ list "EW($delta_l=$l_deb-$l_fin)=$ew_short A" "$sigma_ew A" $snr_short ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_autoew2 nom_profil_raies_normalis� lambda_raie\n"
    }
}
#***************************************************************************#














#==========================================================================#
#           Acnciennes impl�mentations                                     #
#==========================================================================#

