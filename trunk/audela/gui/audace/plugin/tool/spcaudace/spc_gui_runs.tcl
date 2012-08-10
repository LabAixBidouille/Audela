#*****************************************************************************#
#                                                                             #
# Boîtes graphiques TK de saisie des paramètres pour les fonctions Spcaudace  #
#                                                                             #
#*****************************************************************************#
# Chargement : source $audace(rep_scripts)/spcaudace/spc_gui_runs.tcl

# Mise a jour $Id$



########################################################################
# Interface pour l'appel de la fonction spc_buildhtml
#
# Auteurs : Benjamin Mauclaire
# Date de création : 07-08-2012
# Date de modification : 07-08-2012
########################################################################

proc spc_buildhtml_w {} {

   global audace

   spc_buildhtml
}
#**********************************************************************#


########################################################################
# PAsser en basse resolution
#
# Auteurs : Benjamin Mauclaire
# Date de création : 20-04-2010
# Date de modification : 20-04-2010
########################################################################

proc spc_br_w {} {

   global audace spcaudace

   set spcaudace(br) 1
   ::console::affiche_prompt "Mode basse résolution activé.\n\n"
}
#**********************************************************************#

########################################################################
# PAsser en haute resolution
#
# Auteurs : Benjamin Mauclaire
# Date de création : 20-04-2010
# Date de modification : 20-04-2010
########################################################################

proc spc_hr_w {} {

   global audace spcaudace

   set spcaudace(br) 0
   ::console::affiche_prompt "Mode haute résolution activé.\n\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_anim
#
# Auteurs : Benjamin Mauclaire
# Date de création : 20-04-2010
# Date de modification : 20-04-2010
########################################################################

proc spc_anim_w {} {

   global audace

   spc_anim
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_rmcosmics
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_rmcosmics_w {} {

   global audace

   spc_rmcosmics
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_scar
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_scar_w {} {

   global audace

   spc_scar
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_ajustplanck
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_ajustplanck_w {} {

   global audace

   spc_ajustplanck
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_offset
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_offset_w {} {

   global audace

   spc_offset
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommeadd_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_sommeadd_w {} {

   global audace spcaudace

   set spcaudace(meth_somme) "addi"
   ::console::affiche_prompt "Addition des spectres par une somme simple activée.\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommekappa_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_sommekappa_w {} {

   global audace spcaudace

   set spcaudace(meth_somme) "sigmakappa"
   ::console::affiche_prompt "Addition des spectres par une somme kappa-sigma activée.\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommekappa_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_hbinning_w { args } {
   global audace spcaudace

   if { [ llength $args ]==1 } {
      set hbin [ lindex $args 0 ]
      set spcaudace(hauteur_binning) $hbin
      ::console::affiche_prompt "Hauteur de binning fixée à $hbin.\n"
   } else {
      set spcaudace(hauteur_binning) 0
      ::console::affiche_prompt "Hauteur de binning remise à la valeur 0.\n"
      ::console::affiche_erreur "Usage: spc_hbinning_w hauteur_binning_en_pixels. Mettre 0 pour une gestion automatique (comportement par défaut).\n"
   }
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommekappa_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_cafwhmbinning_w { args } {
   global audace spcaudace

   if { [ llength $args ]==1 } {
      set cabin [ lindex $args 0 ]
      set spcaudace(cafwhm_binning) $cabin
      ::console::affiche_prompt "Coéfficient multiplicateur de la FWHM de binning fixé à $cabin.\n"
   } else {
      set spcaudace(cafwhm_binning) 1.9
      ::console::affiche_prompt "Coéfficient multiplicateur de la FWHM de binning remis à 1.9.\n"
      ::console::affiche_erreur "Usage: spc_cafwhmbinning_w coefficient_multiplicateur_fwhm_de_binning. 1.9 est la valeur par défaut.\n"
   }
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_multc
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_multc_w {} {

   global audace

   spc_multc
}
#**********************************************************************#



########################################################################
# Interface pour l'appel de la fonction spc_ajustpoints
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_ajustpoints_w {} {

   global audace

   spc_ajustpoints
}
#**********************************************************************#


########################################################################
# Interface pour l'appel du panneau de prétraitement de Francois Cochard
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
########################################################################

proc spc_pretraitementfc_w {} {

   global audace

   ::confVisu::selectTool $audace(visuNo) ::pretrfc
}
#**********************************************************************#



########################################################################
# Interface pour la réduction des spectres du Lhires III
#
# Auteurs : Benjamin Mauclaire
# Date de création : 19-08-2006
# Date de modification : 19-08-2006
########################################################################

proc spc_specLhIII_w {} {

    global conf
    global audace

    # source $audace(rep_scripts)/../plugin/tool/pretrfc/pretrfc.ini
    ::spbmfc::Demarragespbmfc
}


########################################################################
# Interface pour la calibration en longueur d'onde a partir de 2 raies
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traitecalibre (meta)
# Args :
########################################################################

proc spc_calibre2file_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_calibre2file::run
	tkwait window .param_spc_audace_calibre2file
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,calibre2file,config,spectre)
    set audace(param_spc_audace,calibre2file,config,xa1)
    set audace(param_spc_audace,calibre2file,config,xa2)
    set audace(param_spc_audace,calibre2file,config,xb1)
    set audace(param_spc_audace,calibre2file,config,xb2)
    set audace(param_spc_audace,calibre2file,config,type1)
    set audace(param_spc_audace,calibre2file,config,type2)
    set audace(param_spc_audace,calibre2file,config,lambda1)
    set audace(param_spc_audace,calibre2file,config,lambda2)

    set spectre $audace(param_spc_audace,calibre2file,config,spectre)
    set xa1 $audace(param_spc_audace,calibre2file,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2file,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2file,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2file,config,xb2)
    set type1 $audace(param_spc_audace,calibre2file,config,type1)
    set type2 $audace(param_spc_audace,calibre2file,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2file,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2file,config,lambda2)

    #--- Effectue la calibration du spectre 2D de la lampe spectrale :
    set fileout [ spc_calibre2sauto $spectre $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]
    return $fileout
}
#**************************************************************************#



########################################################################
# Interface pour la calibration en longueur d'onde a partir de 2 raies
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traitecalibre (meta)
# Args :
########################################################################

proc spc_calibre2loifile_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_calibre2loifile::run
	tkwait window .param_spc_audace_calibre2loifile
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,calibre2loifile,config,spectre)
    set audace(param_spc_audace,calibre2loifile,config,lampe)
    set audace(param_spc_audace,calibre2loifile,config,xa1)
    set audace(param_spc_audace,calibre2loifile,config,xa2)
    set audace(param_spc_audace,calibre2loifile,config,xb1)
    set audace(param_spc_audace,calibre2loifile,config,xb2)
    set audace(param_spc_audace,calibre2loifile,config,type1)
    set audace(param_spc_audace,calibre2loifile,config,type2)
    set audace(param_spc_audace,calibre2loifile,config,lambda1)
    set audace(param_spc_audace,calibre2loifile,config,lambda2)

    set spectre $audace(param_spc_audace,calibre2loifile,config,spectre)
    set lampe $audace(param_spc_audace,calibre2loifile,config,lampe)
    set xa1 $audace(param_spc_audace,calibre2loifile,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2loifile,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2loifile,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2loifile,config,xb2)
    set type1 $audace(param_spc_audace,calibre2loifile,config,type1)
    set type2 $audace(param_spc_audace,calibre2loifile,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2loifile,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2loifile,config,lambda2)

    #--- Effectue la calibration du spectre 2D de la lampe spectrale :
    set lampecalibree [ spc_calibre2sauto $spectre $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]
    ::console::affiche_resultat "\n**** Calibration en longueur d'onde du spectre de l'objet $spectre ****\n\n"
    set fcalibre [ spc_calibreloifile $lampecalibree $spectre ]
    return $fcalibre
}
#**************************************************************************#


########################################################################
# Interface pour le traitement des spectre : géométrie, calibration, correction réponse intrumentale, adoucissement
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_geom2calibre
# Args : nom_generique_spectres_pretraites (sans extension) nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) normalisation (o/n)
########################################################################

proc spc_geom2calibre_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_geom2calibre::run
	tkwait window .param_spc_audace_geom2calibre
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set flag 1
    if { $flag == 0 } {
    set audace(param_spc_audace,geom2calibre,config,spectres)
    set audace(param_spc_audace,geom2calibre,config,lampe)
    set audace(param_spc_audace,geom2calibre,config,etoile_ref)
    set audace(param_spc_audace,geom2calibre,config,etoile_cat)
    set audace(param_spc_audace,geom2calibre,config,methreg)
    set audace(param_spc_audace,geom2calibre,config,methsel)
    set audace(param_spc_audace,geom2calibre,config,methsky)
    set audace(param_spc_audace,geom2calibre,config,methbin)
    set audace(param_spc_audace,geom2calibre,config,smooth)
    }
    set spectres $audace(param_spc_audace,geom2calibre,config,spectres)
    set lampe $audace(param_spc_audace,geom2calibre,config,lampe)
    set etoile_ref $audace(param_spc_audace,geom2calibre,config,etoile_ref)
    set etoile_cat $audace(param_spc_audace,geom2calibre,config,etoile_cat)
    set methreg $audace(param_spc_audace,geom2calibre,config,methreg)
    set methsel $audace(param_spc_audace,geom2calibre,config,methsel)
    set methsky $audace(param_spc_audace,geom2calibre,config,methsky)
    set methbin $audace(param_spc_audace,geom2calibre,config,methbin)
    set smooth $audace(param_spc_audace,geom2calibre,config,smooth)

    #--- Lancement de la fonction spcaudace :
    # set fileout [ spc_geom2calibre $spectres $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $smooth ]
    ::console::affiche_resultat "$spectres, $lampe, $etoile_ref\n"
    return $fileout
}
#**************************************************************************#



########################################################################
# Interface pour le traitement des spectre : géométrie, calibration, correction réponse intrumentale, normalisation
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_geom2rinstrum
# Args : nom_generique_spectres_pretraites (sans extension) nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) normalisation (o/n)
########################################################################

proc spc_geom2rinstrum_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_geom2rinstrum::run
	tkwait window .param_spc_audace_geom2rinstrum
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,geom2rinstrum,config,spectres)
    set audace(param_spc_audace,geom2rinstrum,config,lampe)
    set audace(param_spc_audace,geom2rinstrum,config,etoile_ref)
    set audace(param_spc_audace,geom2rinstrum,config,etoile_cat)
    set audace(param_spc_audace,geom2rinstrum,config,methreg)
    set audace(param_spc_audace,geom2rinstrum,config,methsel)
    set audace(param_spc_audace,geom2rinstrum,config,methsky)
    set audace(param_spc_audace,geom2rinstrum,config,methbin)
    set audace(param_spc_audace,geom2rinstrum,config,norma)

    set brut $audace(param_spc_audace,geom2rinstrum,config,spectres)
    set lampe $audace(param_spc_audace,geom2rinstrum,config,lampe)
    set etoile_ref $audace(param_spc_audace,geom2rinstrum,config,etoile_ref)
    set etoile_cat $audace(param_spc_audace,geom2rinstrum,config,etoile_cat)
    set methreg $audace(param_spc_audace,geom2rinstrum,config,methreg)
    set methsel $audace(param_spc_audace,geom2rinstrum,config,methsel)
    set methsky $audace(param_spc_audace,geom2rinstrum,config,methsky)
    set methbin $audace(param_spc_audace,geom2rinstrum,config,methbin)
    set smooth $audace(param_spc_audace,geom2rinstrum,config,norma)

    #--- Lancement de la fonction spcaudace :
    set fileout [ spc_geom2rinstrum $spectres $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $norma ]
    return $fileout
}
#**************************************************************************#



########################################################################
# Interface pour le traitement des spectre : prétraiement, géométrie, calibration
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traite2calibre (meta)
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

proc spc_traite2calibre_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_traite2calibre::run
	tkwait window .param_spc_audace_traite2calibre
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,traite2calibre,config,brut)
    set audace(param_spc_audace,traite2calibre,config,noir)
    set audace(param_spc_audace,traite2calibre,config,plu)
    set audace(param_spc_audace,traite2calibre,config,noirplu)
    set audace(param_spc_audace,traite2calibre,config,lampe)
    set audace(param_spc_audace,traite2calibre,config,methreg)
    set audace(param_spc_audace,traite2calibre,config,methsel)
    set audace(param_spc_audace,traite2calibre,config,methsky)
    set audace(param_spc_audace,traite2calibre,config,methbin)
    set audace(param_spc_audace,traite2calibre,config,smooth)

    set brut $audace(param_spc_audace,traite2calibre,config,brut)
    set noir $audace(param_spc_audace,traite2calibre,config,noir)
    set plu $audace(param_spc_audace,traite2calibre,config,plu)
    set noirplu $audace(param_spc_audace,traite2calibre,config,noirplu)
    set lampe $audace(param_spc_audace,traite2calibre,config,lampe)
    set methreg $audace(param_spc_audace,traite2calibre,config,methreg)
    set methsel $audace(param_spc_audace,traite2calibre,config,methsel)
    set methsky $audace(param_spc_audace,traite2calibre,config,methsky)
    set methbin $audace(param_spc_audace,traite2calibre,config,methbin)
    set smooth $audace(param_spc_audace,traite2calibre,config,smooth)

    #--- Lancement de la fonction spcaudace :
    set fileout [ spc_traite2calibre $brut $noir $plu $noirplu $lampe $methreg $methsel $methsky $methbin $smooth ]
    return $fileout
}
#**************************************************************************#


########################################################################
# Interface pour le traitement des spectre : prétraiement, géométrie, calibration, correction réponse intrumentale, normalisation
#
# Auteurs : Benjamin Mauclaire
# Date de création : 13-07-2006
# Date de modification : 13-07-2006
# Utilisée par : spc_traite2rinstrum (meta)
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) normalisation (o/n)
########################################################################

proc spc_traite2rinstrum_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_traite2rinstrum::run
	tkwait window .param_spc_audace_traite2rinstrum
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,traite2rinstrum,config,brut)
    set audace(param_spc_audace,traite2rinstrum,config,noir)
    set audace(param_spc_audace,traite2rinstrum,config,plu)
    set audace(param_spc_audace,traite2rinstrum,config,noirplu)
    set audace(param_spc_audace,traite2rinstrum,config,lampe)
    set audace(param_spc_audace,traite2rinstrum,config,etoile_ref)
    set audace(param_spc_audace,traite2rinstrum,config,etoile_cat)
    set audace(param_spc_audace,traite2rinstrum,config,methreg)
    set audace(param_spc_audace,traite2rinstrum,config,methsel)
    set audace(param_spc_audace,traite2rinstrum,config,methsky)
    set audace(param_spc_audace,traite2rinstrum,config,methbin)
    set audace(param_spc_audace,traite2rinstrum,config,norma)

    set brut $audace(param_spc_audace,traite2rinstrum,config,brut)
    set noir $audace(param_spc_audace,traite2rinstrum,config,noir)
    set plu $audace(param_spc_audace,traite2rinstrum,config,plu)
    set noirplu $audace(param_spc_audace,traite2rinstrum,config,noirplu)
    set lampe $audace(param_spc_audace,traite2rinstrum,config,lampe)
    set etoile_ref $audace(param_spc_audace,traite2rinstrum,config,etoile_ref)
    set etoile_cat $audace(param_spc_audace,traite2rinstrum,config,etoile_cat)
    set methreg $audace(param_spc_audace,traite2rinstrum,config,methreg)
    set methsel $audace(param_spc_audace,traite2rinstrum,config,methsel)
    set methsky $audace(param_spc_audace,traite2rinstrum,config,methsky)
    set methbin $audace(param_spc_audace,traite2rinstrum,config,methbin)
    set smooth $audace(param_spc_audace,traite2rinstrum,config,norma)

    #--- Lancement de la fonction spcaudace :
    set fileout [ spc_traite2rinstrum $brut $noir $plu $noirplu $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $norma ]
    return $fileout
}
#**************************************************************************#



