# Chargement en script :
# A130 : source $audace(rep_scripts)/spcaudace/spc_metaf.tcl
# A140 : source [ file join $audace(rep_plugin) tool spectro spcaudace spc_metaf.tcl ]


###############################################################################
# Procédure de test d'ihm
# Auteur : Benjamin MAUCLAIRE
###############################################################################

proc spc_testihm {} {
    global caption
    global audace
    global conf

    #source [ file join $audace(rep_scripts) spcaudace spc_gui_boxes.tcl ]
    set err [ catch {
	::param_spc_audace_calibre2::run
	tkwait window .param_spc_audace_calibre2
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }
    
    set audace(param_spc_audace,calibre2,config,xa1)
    set audace(param_spc_audace,calibre2,config,xa2)
    set audace(param_spc_audace,calibre2,config,xb1)
    set audace(param_spc_audace,calibre2,config,xb2)
    set audace(param_spc_audace,calibre2,config,type1)
    set audace(param_spc_audace,calibre2,config,type2)
    set audace(param_spc_audace,calibre2,config,lambda1)
    set audace(param_spc_audace,calibre2,config,lambda2)
    #::console::affiche_resultat "Paramètres : $audace(param_spc_audace,calibre2,config,xa1)\n"
    
    set xa1 $audace(param_spc_audace,calibre2,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2,config,xb2)
    set type1 $audace(param_spc_audace,calibre2,config,type1)
    set type2 $audace(param_spc_audace,calibre2,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
    ::console::affiche_resultat "Paramètres : $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2\n"
}
#****************************************************************************#


###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, vcrop, régistration, sadd, tilt, spc_profil. Pas de calibration en longueur d'onde ni en flux.
# Auteur : Benjamin MAUCLAIRE
# Date création :  27-08-2005
# Date de mise à jour : 28-10-2005/03-12-2005/21-12-2005
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu [yinf_crop]
###############################################################################

proc spc_traitea { args } {

   global audace
   global conf

   ## Découpage de la zone à étudier et prétraitement puis profil :
   if { [llength $args] == 6 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set nbimg [ llength [ glob -dir $audace(rep_images) ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Prétraitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Découpage de la zone de travail des images ****\n"
       set nom_generique_crop [ spc_crop $nom_generique_pretrait [lindex $args 4] [lindex $args 5] ]
       delete2 $nom_generique_pretrait $nbimg
       ::console::affiche_resultat "\n**** Appariement des images ****\n"
       set nom_generique_reg [ spc_register $nom_generique_crop ]
       delete2 $nom_generique_crop $nbimg
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ bm_sadd $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy $fichier_final1$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
       set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       file copy $fichier_final2$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
       set fichier_final3 [ spc_profil $fichier_final2 auto ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       # file copy $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   ## Prétraitement des images seulement puis profil :
   } elseif { [llength $args] == 4 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set nbimg [ llength [ glob ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Prétraitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Appariement des images ****\n"
       #set nom_generique_reg [ spc_register $nom_generique_pretrait ]
       set nom_generique_reg [ bm_register $nom_generique_pretrait ]
       delete2 $nom_generique_pretrait $nbimg
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ bm_sadd $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy $fichier_final1$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
       set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       file copy $fichier_final2$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
       set fichier_final3 [ spc_profil $fichier_final2 auto ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       # file copy $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   } else {
       ::console::affiche_erreur "Usage: spc_traitea nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?xinf_crop yinf_crop?\n\n"
   }
}
###############################################################################


###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, vcrop, régistration, sadd, tilt, spc_profil. Pas de calibration en longueur d'onde ni en flux.
# Auteur : Benjamin MAUCLAIRE
# Date création :  27-08-2005
# Date de mise à jour : 28-10-2005/03-12-2005/21-12-2005
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu [yinf_crop]
###############################################################################

proc spc_traiteaopt { args } {

   global audace
   global conf

   ## Découpage de la zone à étudier et prétraitement puis profil :
   if { [llength $args] == 10 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set meth_fc [ lindex $args 6 ]
       set meth_reg [ lindex $args 7 ]
       set meth_tilt [ lindex $args 8 ]
       set meth_prof [ lindex $args 9 ]

       set nbimg [ llength [ glob -dir $audace(rep_images) ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Prétraitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Découpage de la zone de travail des images ****\n"
       set nom_generique_crop [ spc_crop $nom_generique_pretrait [lindex $args 4] [lindex $args 5] ]
       delete2 $nom_generique_pretrait $nbimg

       #--- Soustraction du fond de ciel
       if { $meth_fc == "auto" } {
	   ::console::affiche_resultat "\n**** Soustraction du fond de ciel des images ****\n"
	   set nom_generique_fc [ spc_subskies $nom_generique_crop ]
	   delete2 $nom_generique_crop $nbimg
       } elseif { $meth_fc == "no" } {
	   ::console::affiche_resultat "\n**** Pas de soustraction du fond de ciel ****\n"
	   set nom_generique_fc $nom_generique_crop
       }

       #--- Appariement des images
       if { $meth_reg == "reg" } {
	   ::console::affiche_resultat "\n**** Appariement des images ****\n"
	   set nom_generique_reg [ bm_register $nom_generique_fc ]
	   delete2 $nom_generique_fc $nbimg
       } elseif { $meth_reg == "spc" } {
	   ::console::affiche_resultat "\n**** Appariement des images ****\n"
	   set nom_generique_reg [ spc_register $nom_generique_fc ]
	   delete2 $nom_generique_fc $nbimg
       } elseif { $meth_reg == "no" } {
	   ::console::affiche_resultat "\n**** Pas d'appariement des images ****\n"
	   set nom_generique_reg $nom_generique_fc
       }

       #--- Addition des images
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ bm_sadd $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy -force $fichier_final1$conf(extension,defaut) traitees

       #--- Redressement (rot) de l'image finale
       if { $meth_tilt == "auto" } {
	   ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
	   set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       } elseif { $meth_tilt == "man" } {
	   ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
	   set fichier_final2 [ spc_tiltman $fichier_final1 ]
       } elseif { $meth_tilt == "no" } {
	   ::console::affiche_resultat "\n**** Pas de redressement (rot) de l'image ****\n"
	   set fichier_final2 $fichier_final1
       }
       file copy -force $fichier_final2$conf(extension,defaut) traitees

       #--- Création du profil de raies
       if { $meth_prof == "auto" } {
	   #-- Avec correction du fond de ciel par le BLACK
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 auto ]
       } elseif { $meth_prof == "none" } {
	   #-- Sans correction du fond de ciel
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 none ]
       } elseif { $meth_prof == "all" } {
	   #-- Avec correction du fond de ciel par les zones sup et inf au spectre
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 all ]
       } elseif { $meth_prof == "sup" } {
	   #-- Avec correction du fond de ciel par la zones sup au spectre
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 sup ]
       }
       spc_loadfit $fichier_final3

       #--- Rangement des fichiers
       set fichier_final [ file rootname $fichier_final3 ]
       file copy -force $fichier_final$conf(extension,defaut) traitees
       # file copy -force $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   } else {
       ::console::affiche_erreur "Usage: spc_traiteaopt nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu xinf_crop yinf_crop méthode_fond_de_ciel (no, auto) méthode régistration (reg, spc, no) méthode_tilt (no, auto, man) méthode_profil (none, auto, all, sup, inf, back, moy, moy2)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, smooth.
# Auteur : Benjamin MAUCLAIRE
# Date création :  13-07-2006
# Date de mise à jour : 13-07-2006
# Arguments : nom_generique_spectres_pretraites spectre_2D_lampe methode_reg (reg, spc) uncosmic (o/n) methode_détection_spectre (large, serre) methode_sub_sky (moy, moy2, med, inf, sup, ack, none) mirrorx (o/n) methode_binning (add, opt1, opt2) smooth (o/n)
###############################################################################

proc spc_geom2calibre { args } {

   global audace
   global conf

   if { [llength $args] == 9 } {
       set spectres [ lindex $args 0 ]
       set lampe [ file rootname [ lindex $args 1 ] ]
       set methreg [ lindex $args 2 ]
       set methcos [ lindex $args 3 ]
       set methsel [ lindex $args 4 ]
       set methsky [ lindex $args 5 ]
       set methinv [ lindex $args 6 ]
       set methbin [ lindex $args 7 ]
       set methsmo [ lindex $args 8 ]

       #--- Eliminatoin des mauvaise images :
       ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
       spc_reject $spectres
       set nbimg [ llength [ glob -dir $audace(rep_images) ${spectres}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       set fsmilex [ spc_smilex2imgs $lampe $spectres ]

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       set ftilt [ spc_tiltautoimgs $fsmilex ]
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       ::console::affiche_resultat "Sortie : $ftilt\n"
       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       ::console::affiche_resultat "Sortie : $freg\n"
       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       ::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   #-- Mirrorx du spectre prétraité :
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
	   #-- Mirrorx du spectre de la lampe de calibration :
	   buf$audace(bufNo) load "$audace(rep_images)/${lampe}_slx"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}_slx"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fsadd $methsky $methsel $methbin ]

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       spc_loadfit ${lampe}_slx
       loadima ${lampe}_slx
       #-- Boîte de dialogue pour saisir les paramètres de calibration :
       # tk.message "Selectionnez les corrdonnées x de cahque bords de 2 raies"
       # tk.boite1 xa1 xa2 xb1 xb2
       # tk.message "Donner la longueur d'onde et le type (a/e) des 2 raies"
       # tk.boite2 type1 lammbda1 type2 lambda2
       set err [ catch {
	   ::param_spc_audace_calibre2::run
	   tkwait window .param_spc_audace_calibre2
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       set audace(param_spc_audace,calibre2,config,xa1)
       set audace(param_spc_audace,calibre2,config,xa2)
       set audace(param_spc_audace,calibre2,config,xb1)
       set audace(param_spc_audace,calibre2,config,xb2)
       set audace(param_spc_audace,calibre2,config,type1)
       set audace(param_spc_audace,calibre2,config,type2)
       set audace(param_spc_audace,calibre2,config,lambda1)
       set audace(param_spc_audace,calibre2,config,lambda2)

       set xa1 $audace(param_spc_audace,calibre2,config,xa1)
       set xa2 $audace(param_spc_audace,calibre2,config,xa2)
       set xb1 $audace(param_spc_audace,calibre2,config,xb1)
       set xb2 $audace(param_spc_audace,calibre2,config,xb2)
       set type1 $audace(param_spc_audace,calibre2,config,type1)
       set type2 $audace(param_spc_audace,calibre2,config,type2)
       set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
       set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
       #-- Effectue la calibration du spectre 2D de la lampe spectrale : 
       set lampecalibree [ spc_calibre2sauto ${lampe}_slx $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $spectres ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fcal ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fcal"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_geom2calibre nom_generique_spectres_pretraites spectre_2D_lampe methode_reg (reg, spc) uncosmic (o/n) methode_détection_spectre (large, serre) methode_sub_sky (moy, moy2, med, inf, sup, ack, none) mirrorx (o/n) methode_binning (add, opt1, opt2) smooth (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  14-07-2006
# Date de mise à jour : 14-07-2006
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_générique_spectres_prétraités (sans extension) spectre_2D_lampe méthode_reg (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre)  méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_bining (add, rober, horne) adoucissment (o/n) normalisation (o/n)
###############################################################################

proc spc_geom2rinstrum { args } {

   global audace
   global conf

   if { [llength $args] == 12 } {
       #set repdflt [spc_goodrep]
       set spectres [ lindex $args 0 ]
       set lampe [ file tail [ file rootname [ lindex $args 1 ] ] ]
       set etoile_ref [ file tail [ file rootname [ lindex $args 2 ] ] ]
       set etoile_cat [ lindex $args 3 ]
       set methreg [ lindex $args 4 ]
       set methcos [ lindex $args 5 ]
       set methsel [ lindex $args 6 ]
       set methsky [ lindex $args 7 ]
       set methinv [ lindex $args 8 ]
       set methbin [ lindex $args 9 ]
       set methnorma [ lindex $args 10 ]
       set methsmo [ lindex $args 11 ]

       #--- Eliminatoin des mauvaise images :
       ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
       spc_reject $spectres
       set nbimg [ llength [ glob -dir $audace(rep_images) ${spectres}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ bm_pretrait $img $dark $flat $dflat ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       set fsmilex [ spc_smilex2imgs $lampe $fpretrait ]
       delete2 $fpretrait $nbimg

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       set ftilt [ spc_tiltautoimgs $fsmilex ]
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
	   #-- Mirrorx du spectre de la lampe de calibration :
	   buf$audace(bufNo) load "$audace(rep_images)/${lampe}_slx"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}_slx"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fsadd $methsky $methsel $methbin ]

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       spc_loadfit ${lampe}_slx
       loadima ${lampe}_slx
       #-- Boîte de dialogue pour saisir les paramètres de calibration :
       # tk.message "Selectionnez les corrdonnées x de cahque bords de 2 raies"
       # tk.boite1 xa1 xa2 xb1 xb2
       # tk.message "Donner la longueur d'onde et le type (a/e) des 2 raies"
       # tk.boite2 type1 lammbda1 type2 lambda2
       set err [ catch {
	   ::param_spc_audace_calibre2::run
	   tkwait window .param_spc_audace_calibre2
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       set audace(param_spc_audace,calibre2,config,xa1)
       set audace(param_spc_audace,calibre2,config,xa2)
       set audace(param_spc_audace,calibre2,config,xb1)
       set audace(param_spc_audace,calibre2,config,xb2)
       set audace(param_spc_audace,calibre2,config,type1)
       set audace(param_spc_audace,calibre2,config,type2)
       set audace(param_spc_audace,calibre2,config,lambda1)
       set audace(param_spc_audace,calibre2,config,lambda2)

       set xa1 $audace(param_spc_audace,calibre2,config,xa1)
       set xa2 $audace(param_spc_audace,calibre2,config,xa2)
       set xb1 $audace(param_spc_audace,calibre2,config,xb1)
       set xb2 $audace(param_spc_audace,calibre2,config,xb2)
       set type1 $audace(param_spc_audace,calibre2,config,type1)
       set type2 $audace(param_spc_audace,calibre2,config,type2)
       set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
       set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
       #-- Effectue la calibration du spectre 2D de la lampe spectrale : 
       set lampecalibree [ spc_calibre2sauto ${lampe}_slx $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $spectres ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]

       #--- Correction de la réponse instrumentale :
       ::console::affiche_resultat "\n\n**** Correction de la réponse intrumentale ****\n\n"
       # file copy $audace(rep_scripts)/spcaudace/data/bibliotheque_spectrale/$etoile_cat$conf(extension,defaut) $audace(rep_images)
       file copy $etoile_cat $audace(rep_images)
       set fricorr [ spc_rinstrumcorr $fcal $etoile_ref $etoile_cat ]
       file rename -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${fcal}_ricorr$conf(extension,defaut)"
       set fricorr "${fcal}_ricorr"


       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_normaraie $fricorr e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_normaraie $fricorr a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fsnorma]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fsnorma"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsnorma\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsnorma
       return $fsnorma
   } else {
       ::console::affiche_erreur "Usage: spc_geom2rinstrum nom_générique_spectres_prétraités (sans extension) spectre_2D_lampe méthode_reg (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre)  méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_bining (add, rober, horne) normalisation (o/n) adoucissement (o/n)\n\n"
   }
}
#**********************************************************************************#



###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, smooth.
# Auteur : Benjamin MAUCLAIRE
# Date création :  27-06-2006
# Date de mise à jour : 27-06-2006/15-08-06/27-08-06
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu offset spectre_2D_lampe methode_reg (reg, spc) uncomsic (o/n) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) methode_bining (add, rober, horne) smooth (o/n)
###############################################################################

proc spc_traite2calibre { args } {

   global audace
   global conf

   if { [llength $args] == 15 } {
       set img [ lindex $args 0 ]
       set dark [ lindex $args 1 ]
       set flat [ lindex $args 2 ]
       set dflat [ lindex $args 3 ]
       set offset [ lindex $args 4 ]
       set lampe [ file rootname [ lindex $args 5 ] ]
       set methreg [ lindex $args 6 ]
       set methcos [ lindex $args 7 ]
       set methsel [ lindex $args 8 ]
       set methsky [ lindex $args 9 ]
       set methinv [ lindex $args 10 ]
       set methbin [ lindex $args 11 ]
       set methsmo [ lindex $args 12 ]
       set methejb [ lindex $args 13 ]
       set methejt [ lindex $args 14 ]

       #--- Eliminatoin des mauvaise images :
       if { $methejb == "o" } {
	   ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Traitement du spectre de la lampe de calibration :
       ::console::affiche_resultat "\n\n**** Traitement du spectre de lampe de calibration ****\n\n"
       #-- Retrait du dark :
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       buf$audace(bufNo) sub "$audace(rep_images)/${dark}1" 0
       buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
       set lampet "${lampe}-t"
       
       #-- Correction du smilex du spectre de lampe de calibration :
       set smilexcoefs [ spc_smilex $lampet ]
       file delete "$audace(rep_images)/$lampet$conf(extension,defaut)"
       set lampeslx [ lindex $smilexcoefs 0 ]
       set ycenter [ lindex $smilexcoefs 1 ]
       set adeg2 [ lindex $smilexcoefs 4 ]

       #-- Inversion gauche-droite : 
       if { $methinv == "o" } {
	   set lampeflip [ spc_flip $lampeslx ]
	   file delete "$audace(rep_images)/$lampeslx$conf(extension,defaut)"
       } else {
	   set lampeflip "$lampeslx"
       }

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       #-- Création du profil de raie de la lampe :
       set profillampe [ spc_profillampe ${img}1 $lampeflip ]
       # file delete "$audace(rep_images)/$lampeflip$conf(extension,defaut)"
       set lampecalibree [ spc_calibre $profillampe ]
       file delete "$audace(rep_images)/$profillampe$conf(extension,defaut)"


       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       if { $offset == "none" } {
	   set fpretrait [ bm_pretrait $img $dark $flat $dflat ]
       } else {
	   ::console::affiche_resultat "Méthode pas encore programmée\n"
	   return 0
       }


       #::console::affiche_resultat "Sortie : $fpretrait\n"
       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       set fsmilex [ spc_smileximgs $fpretrait $adeg2 $ycenter ]
       delete2 $fpretrait $nbimg

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fsmilex o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fsmilex n ]
       }
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]


       #::console::affiche_resultat "Sortie : $ftilt\n"
       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }


       #::console::affiche_resultat "Sortie : $freg\n"
       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg


       #::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D prétraité (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]

       #--- Adoucissement du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fcal ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fcal"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       # $brut $noir $plu $noirplu $offset $lampe $methreg $methcos $methsel $methsky $methinv $methbin $smooth
       ::console::affiche_erreur "Usage: spc_traite2calibre nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) adoucissement (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  14-07-2006
# Date de mise à jour : 14-07-2006/061230
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_étoile_référence profil_étoile_catalogue méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)
###############################################################################

proc spc_traite2rinstrum { args } {

   global audace
   global conf
   set rep_speclib "$audace(rep_scripts)/spcaudace/data/bibliotheque_spectrale"

   if { [llength $args] == 17 } {
       set img [ lindex $args 0 ]
       set dark [ lindex $args 1 ]
       set flat [ lindex $args 2 ]
       set dflat [ lindex $args 3 ]
       set offset [ lindex $args 4 ]
       set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
       # set etoile_ref [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set etoile_cat [ lindex $args 6 ]
       # etoile_cat contient le chemin et le nom du fichier
       set methreg [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methsel [ lindex $args 9 ]
       set methsky [ lindex $args 10 ]
       set methinv [ lindex $args 11 ]
       set methbin [ lindex $args 12 ]
       set methnorma [ lindex $args 13 ]
       set methsmo [ lindex $args 14 ]
       set methejb [ lindex $args 15 ]
       set methejt [ lindex $args 16 ]

       #--- Elimination des mauvaise images :
       if { $methejb == "o" } {
	   ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Traitement du spectre de la lampe de calibration :
       ::console::affiche_resultat "\n\n**** Traitement du spectre de lampe de calibration ****\n\n"
       #-- Retrait du dark :
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       buf$audace(bufNo) sub "$audace(rep_images)/${dark}1" 0
       buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
       set lampet "${lampe}-t"
       
       #-- Correction du smilex du spectre de lampe de calibration :
       set smilexcoefs [ spc_smilex $lampet ]
       file delete "$audace(rep_images)/$lampet$conf(extension,defaut)"
       set lampeslx [ lindex $smilexcoefs 0 ]
       set ycenter [ lindex $smilexcoefs 1 ]
       set adeg2 [ lindex $smilexcoefs 4 ]

       #-- Inversion gauche-droite : 
       if { $methinv == "o" } {
	   set lampeflip [ spc_flip $lampeslx ]
	   file delete "$audace(rep_images)/$lampeslx$conf(extension,defaut)"
       } else {
	   set lampeflip "$lampeslx"
       }

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       #-- Création du profil de raie de la lampe :
       set profillampe [ spc_profillampe ${img}1 $lampeflip ]
       # file delete "$audace(rep_images)/$lampeflip$conf(extension,defaut)"
       set lampecalibree [ spc_calibre $profillampe ]
       file delete "$audace(rep_images)/$profillampe$conf(extension,defaut)"


       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       if { $offset == "none" } {
	   set fpretrait [ bm_pretrait $img $dark $flat $dflat ]
       } else {
	   ::console::affiche_resultat "Méthode pas encore programmée\n"
	   return 0
       }


       #--- Corrections géométriques des raies (smile selon l'axe x ou slant) :
       set rmfpretrait "o"
       ::console::affiche_resultat "\n\n**** Corrections géométriques du spectre 2D ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   ::console::affiche_resultat "\n** Correction de la courbure des raies (smile selon l'axe x)... **\n"
	   set fgeom [ spc_smileximgs $fpretrait $spc_ycenter $spc_cdeg2 ]
       } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
	   set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
	   ::console::affiche_resultat "\n** Correction de l'inclinaison des raies (slant)... **\n"
	   set fgeom [ spc_slantimgs $fpretrait $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction géométrique nécessaire. **\n"
	   set fgeom "$fpretrait"
	   set rmfpretrait "n"
       }

       #--- Effacement des images prétraitées :
       #- future option de conservation des fichiers prétraités
       if { $rmfpretrait=="o" && file exists $audace(rep_images)/${fpretrait}-1$conf(extension,defaut) } {
	   delete2 $fpretrait $nbimg
       }


       #--- Correction du l'inclinaison (tilt) :
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fgeom o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fgeom n ]
       }
       delete2 $fgeom $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]


       #::console::affiche_resultat "Sortie : $ftilt\n"
       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }


       #::console::affiche_resultat "Sortie : $freg\n"
       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg


       #::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D prétraité (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]


       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fcal e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fcal a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fcal"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Calcul de la réponse intrumentale :
       ::console::affiche_resultat "\n\n**** Calcul de la réponse intrumentale ****\n\n"
       file copy "$rep_speclib/$etoile_cat" "$audace(rep_images)"
       # set fricorr [ spc_rinstrumcorr $fcal $etoile_ref $etoile_cat ]
       set rep_instrum [ spc_rinstrum $fcal $etoile_cat ]
       ::console::affiche_resultat "\nRéponse instrumentale sauvée sous $rep_instrum\n"

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_traite2rinstrum nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_étoile_catalogue méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_bad_spectres (o/n) rejet_rotation_importante (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-08-2006
# Date de mise à jour : 28-08-2006
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)
###############################################################################

proc spc_traite2srinstrum { args } {

   global audace
   global conf

   if { [llength $args] == 17 } {
       set img [ lindex $args 0 ]
       set dark [ lindex $args 1 ]
       set flat [ lindex $args 2 ]
       set dflat [ lindex $args 3 ]
       set offset [ lindex $args 4 ]
       set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
       set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set methreg [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methsel [ lindex $args 9 ]
       set methsky [ lindex $args 10 ]
       set methinv [ lindex $args 11 ]
       set methbin [ lindex $args 12 ]
       set methnorma [ lindex $args 13 ]
       set methsmo [ lindex $args 14 ]
       set methejbad [ lindex $args 15 ]
       set methejtilt [ lindex $args 16 ]

       #--- Eliminatoin des mauvaise images :
       if { $methejbad == "o" } {
	   ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ bm_pretrait $img $dark $flat $dflat ]


       #--- Corrections géométriques des raies (smile selon l'axe x ou slant) :
       set rmfpretrait "o"
       ::console::affiche_resultat "\n\n**** Corrections géométriques du spectre 2D ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   ::console::affiche_resultat "\n** Correction de la courbure des raies (smile selon l'axe x)... **\n"
	   set fgeom [ spc_smileximgs $fpretrait $spc_ycenter $spc_cdeg2 ]
       } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
	   set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
	   ::console::affiche_resultat "\n** Correction de l'inclinaison des raies (slant)... **\n"
	   set fgeom [ spc_slantimgs $fpretrait $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction géométrique nécessaire. **\n"
	   set fgeom "$fpretrait"
	   set rmfpretrait "n"
       }

       #--- Effacement des images prétraitées :
       #- future option de conservation des fichiers prétraités
       if { $rmfpretrait=="o" && file exists $audace(rep_images)/${fpretrait}-1$conf(extension,defaut) } {
	   delete2 $fpretrait $nbimg
       }


       #--- Correction du l'inclinaison (tilt) :
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejtilt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fgeom o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fgeom n ]
       }
       delete2 $fgeom $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampe $fprofil ]

       #--- Correction de la réponse intrumentale :
       ::console::affiche_resultat "\n\n**** Correction de la réponse intrumentale ****\n\n"
       #set rinstrum_ech [ spc_echant $rinstrum $fcal ]
       #set fricorr [ spc_div $fcal $rinstrum_ech ]
       set fricorr [ spc_divri $fcal $rinstrum ]

       if { $fricorr == 0 } {
	   ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
	   return 0
       } else {
	   file rename -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${fcal}_ricorr$conf(extension,defaut)"
	   set fricorr "${fcal}_ricorr"
       }

       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_traite2srinstrum nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n)\n\n"
   }
}
#**********************************************************************************#



###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-08-2006
# Date de mise à jour : 28-08-2006
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)
###############################################################################

proc spc_traite2scalibre { args } {

   global audace
   global conf

   if { [llength $args] == 16 } {
       set img [ lindex $args 0 ]
       set dark [ lindex $args 1 ]
       set flat [ lindex $args 2 ]
       set dflat [ lindex $args 3 ]
       set offset [ lindex $args 4 ]
       set lampecalibree [ file tail [ file rootname [ lindex $args 5 ] ] ]
       set methreg [ lindex $args 6 ]
       set methcos [ lindex $args 7 ]
       set methsel [ lindex $args 8 ]
       set methsky [ lindex $args 9 ]
       set methinv [ lindex $args 10 ]
       set methbin [ lindex $args 11 ]
       set methnorma [ lindex $args 12 ]
       set methsmo [ lindex $args 13 ]
       set methejbad [ lindex $args 14 ]
       set methejtilt [ lindex $args 15 ]

       #--- Eliminatoin des mauvaise images :
       if { $methejbad == "o" } {
	   ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ bm_pretrait $img $dark $flat $dflat ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set a [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   set fsmilex [ spc_smileximgs $fpretrait $ycenter $a ]
       } else {
	   ::console::affiche_resultat "\nAucune correction de la courbure (smilex) des raies possible.\n"
	   set fsmilex "$fpretrait"
       }
       delete2 $fpretrait $nbimg

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejtilt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fsmilex o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fsmilex n ]
       }
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ bm_sadd $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic 0.5
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]
       set fricorr "$fcal"

       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }

       #--- Adoucissement du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsnorma\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_traite2scalibre nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_1D_lampe_calibrée  méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n)\n\n"
   }
}
#**********************************************************************************#
