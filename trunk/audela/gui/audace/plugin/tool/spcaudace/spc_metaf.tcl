# Chargement en script :
# A130 : source $audace(rep_scripts)/spcaudace/spc_metaf.tcl
# A140 : source [ file join $audace(rep_plugin) tool spcaudace spc_metaf.tcl ]

# Mise a jour $Id: spc_metaf.tcl,v 1.3 2008-08-29 20:21:44 bmauclaire Exp $



###############################################################################
# Proc�dure de test d'ihm
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
    #::console::affiche_resultat "Param�tres : $audace(param_spc_audace,calibre2,config,xa1)\n"

    set xa1 $audace(param_spc_audace,calibre2,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2,config,xb2)
    set type1 $audace(param_spc_audace,calibre2,config,type1)
    set type2 $audace(param_spc_audace,calibre2,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
    ::console::affiche_resultat "Param�tres : $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2\n"
}
#****************************************************************************#


###############################################################################
# Proc�dure de traitement de spectres 2D : pr�traitement, vcrop, r�gistration, sadd, tilt, spc_profil. Pas de calibration en longueur d'onde ni en flux.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  27-08-2005
# Date de mise � jour : 28-10-2005/03-12-2005/21-12-2005
# M�thode : utilise bm_pretrait pour le pr�traitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu [yinf_crop]
###############################################################################

proc spc_traitea { args } {

   global audace
   global conf

   ## D�coupage de la zone � �tudier et pr�traitement puis profil :
   if { [llength $args] == 6 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set nbimg [ llength [ glob -dir $audace(rep_images) ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Pr�traitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** D�coupage de la zone de travail des images ****\n"
       set nom_generique_crop [ spc_crop $nom_generique_pretrait [lindex $args 4] [lindex $args 5] ]
       delete2 $nom_generique_pretrait $nbimg
       ::console::affiche_resultat "\n**** Appariement des images ****\n"
       set nom_generique_reg [ spc_register $nom_generique_crop ]
       delete2 $nom_generique_crop $nbimg
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ spc_somme $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy $fichier_final1$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
       set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       file copy $fichier_final2$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Cr�ation du profil de raies ****\n"
       set fichier_final3 [ spc_profil $fichier_final2 auto ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       # file copy $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   ## Pr�traitement des images seulement puis profil :
   } elseif { [llength $args] == 4 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set nbimg [ llength [ glob ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Pr�traitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Appariement des images ****\n"
       #set nom_generique_reg [ spc_register $nom_generique_pretrait ]
       set nom_generique_reg [ bm_register $nom_generique_pretrait ]
       delete2 $nom_generique_pretrait $nbimg
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ spc_somme $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy $fichier_final1$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
       set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       file copy $fichier_final2$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Cr�ation du profil de raies ****\n"
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
# Proc�dure de traitement de spectres 2D : pr�traitement, vcrop, r�gistration, sadd, tilt, spc_profil. Pas de calibration en longueur d'onde ni en flux.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  27-08-2005
# Date de mise � jour : 28-10-2005/03-12-2005/21-12-2005
# M�thode : utilise bm_pretrait pour le pr�traitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu [yinf_crop]
###############################################################################

proc spc_traiteaopt { args } {

   global audace
   global conf

   ## D�coupage de la zone � �tudier et pr�traitement puis profil :
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
       ::console::affiche_resultat "\n**** Pr�traitement des images ****\n"
       set nom_generique_pretrait [ spc_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** D�coupage de la zone de travail des images ****\n"
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
       set fichier_final1 [ spc_somme $nom_generique_reg ]
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

       #--- Cr�ation du profil de raies
       if { $meth_prof == "auto" } {
	   #-- Avec correction du fond de ciel par le BLACK
	   ::console::affiche_resultat "\n**** Cr�ation du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 auto ]
       } elseif { $meth_prof == "none" } {
	   #-- Sans correction du fond de ciel
	   ::console::affiche_resultat "\n**** Cr�ation du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 none ]
       } elseif { $meth_prof == "all" } {
	   #-- Avec correction du fond de ciel par les zones sup et inf au spectre
	   ::console::affiche_resultat "\n**** Cr�ation du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 all ]
       } elseif { $meth_prof == "sup" } {
	   #-- Avec correction du fond de ciel par la zones sup au spectre
	   ::console::affiche_resultat "\n**** Cr�ation du profil de raies ****\n"
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
       ::console::affiche_erreur "Usage: spc_traiteaopt nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu xinf_crop yinf_crop m�thode_fond_de_ciel (no, auto) m�thode r�gistration (reg, spc, no) m�thode_tilt (no, auto, man) m�thode_profil (none, auto, all, sup, inf, back, moy, moy2)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Proc�dure de traitement de spectres 2D : correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, smooth.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  13-07-2006
# Date de mise � jour : 13-07-2006
# Arguments : nom_generique_spectres_pretraites spectre_2D_lampe methode_reg (reg, spc) uncosmic (o/n) methode_d�tection_spectre (large, serre) methode_sub_sky (moy, moy2, med, inf, sup, ack, none) mirrorx (o/n) methode_binning (add, opt1, opt2) smooth (o/n)
###############################################################################

proc spc_geom2calibre { args } {

   global audace spcaudace
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
       ::console::affiche_resultat "\n**** �liminations des mauvaises images ****\n\n"
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
       set fsadd [ spc_somme $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       ::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   #-- Mirrorx du spectre pr�trait� :
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
       #-- Bo�te de dialogue pour saisir les param�tres de calibration :
       # tk.message "Selectionnez les corrdonn�es x de cahque bords de 2 raies"
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
       ::console::affiche_resultat "\n\nSpectre trait�, corrig� et calibr� sauv� sous $fsmooth\n\n"
       # tk.message "Affichage du spectre trait�, corrig� et calibr� $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_geom2calibre nom_generique_spectres_pretraites spectre_2D_lampe methode_reg (reg, spc) uncosmic (o/n) methode_d�tection_spectre (large, serre) methode_sub_sky (moy, moy2, med, inf, sup, ack, none) mirrorx (o/n) methode_binning (add, opt1, opt2) smooth (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Proc�dure de traitement de spectres 2D : correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  14-07-2006
# Date de mise � jour : 14-07-2006
# M�thode : utilise spc_pretrait pour le pr�traitement
# Arguments : nom_g�n�rique_spectres_pr�trait�s (sans extension) spectre_2D_lampe m�thode_reg (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre)  m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_bining (add, rober, horne) adoucissment (o/n) normalisation (o/n)
###############################################################################

proc spc_geom2rinstrum { args } {

   global audace spcaudace
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
       ::console::affiche_resultat "\n**** �liminations des mauvaises images ****\n\n"
       spc_reject $spectres
       set nbimg [ llength [ glob -dir $audace(rep_images) ${spectres}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Pr�traitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Pr�traitement de $nbimg images ****\n\n"
       set fpretrait [ spc_pretrait $img $dark $flat $dflat ]

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
       set fsadd [ spc_somme $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
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
       #-- Bo�te de dialogue pour saisir les param�tres de calibration :
       # tk.message "Selectionnez les corrdonn�es x de cahque bords de 2 raies"
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

       #--- Correction de la r�ponse instrumentale :
       ::console::affiche_resultat "\n\n**** Correction de la r�ponse intrumentale ****\n\n"
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
       ::console::affiche_resultat "\n\nSpectre trait�, corrig� et calibr� sauv� sous $fsmooth\n\n"
       # tk.message "Affichage du spectre trait�, corrig� et calibr� $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_geom2rinstrum nom_g�n�rique_spectres_pr�trait�s (sans extension) spectre_2D_lampe m�thode_reg (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre)  m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_bining (add, rober, horne) normalisation (o/n) adoucissement (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Proc�dure de traitement de spectres 2D : pr�traitement, correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  28-08-2006
# Date de mise � jour : 28-08-2006
# M�thode : utilise spc_pretrait pour le pr�traitement
# Arguments : nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_r�ponse_instrumentale m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)
###############################################################################

proc spc_traite2scalibre { args } {

   global audace spcaudace
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
	   ::console::affiche_resultat "\n**** �liminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Pr�traitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Pr�traitement de $nbimg images ****\n\n"
       set fpretrait [ spc_pretrait $img $dark $flat $dflat ]

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
       set fsadd [ spc_somme $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
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
       ::console::affiche_resultat "\n\nSpectre trait�, corrig� et calibr� sauv� sous $fsmooth\n\n"
       # tk.message "Affichage du spectre trait�, corrig� et calibr� $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_traite2scalibre nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_1D_lampe_calibr�e  m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Proc�dure de traitement de spectres 2D : pr�traitement, correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  28-02-2007
# Date de mise � jour : 28-02-2007
# M�thode : utilise spc_pretrait pour le pr�traitement
# Arguments : nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne), s�lection manuelle d'une raie pour la g�om�trie (o/n), effacer masters de pr�traitement (o/n)
###############################################################################

proc spc_lampe2calibre { args } {

   global audace spcaudace
   global conf
   global lampe2calibre_fileout

   set nbargs [ llength $args ]
   if { $nbargs <= 9 } {
       if { $nbargs == 8 } {
	   set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
	   set img [ file tail [ file rootname [ lindex $args 1 ] ] ]
	   set dark [ file tail [ file rootname [ lindex $args 2 ] ] ]
	   set methcos [ lindex $args 3 ]
	   set methsel [ lindex $args 4 ]
	   set methinv [ lindex $args 5 ]
	   set methbin [ lindex $args 6 ]
	   set methraie [ lindex $args 7 ]
       } elseif { $nbargs == 9 } {
	   set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
	   set img [ file tail [ file rootname [ lindex $args 1 ] ] ]
	   set dark [ file tail [ file rootname [ lindex $args 2 ] ] ]
	   set methcos [ lindex $args 3 ]
	   set methsel [ lindex $args 4 ]
	   set methinv [ lindex $args 5 ]
	   set methbin [ lindex $args 6 ]
	   set methraie [ lindex $args 7 ]
	   set wincoords [ lindex $args 8 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_lampe2calibre spectre_2D_lampe nom_g�n�rique_images_objet_(sans extension) nom_dark uncosmic (o/n) m�thode_d�tection_spectre (large, serre) mirrorx (o/n) m�thode_binning (add, rober, horne) s�lection_manuelle_raie_g�om�trie (o/n) ?liste_corrdonn�es_zone?\n\n"
       }

       #--- Prend la premi�re image et le premier dark ou le masterdark :
       # set img1 [ file rootname [ lindex [ glob -dir $audace(rep_images) -tails ${img}\[0-9\]*$conf(extension,defaut) ] 0 ] ]
       #set dark1 [ file rootname [ lindex [ glob -dir $audace(rep_images) -tails ${dark}\[0-9\]*$conf(extension,defaut) ${dark}*$conf(extension,defaut) ] 0 ] ]
       if { [ file exists "$audace(rep_images)/$img$conf(extension,defaut)" ] } {
	   set img1 $img
       } elseif { [ catch { glob -dir $audace(rep_images) ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set img1 [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   ::console::affiche_resultat "Le(s) fichier(s) $img n'existe(nt) pas.\n"
	   return ""
       }
       if { [ file exists "$audace(rep_images)/$dark$conf(extension,defaut)" ] } {
	   set darkmaster $dark
       } elseif { [ catch { glob -dir $audace(rep_images) ${dark}\[0-9\]$conf(extension,defaut) ${dark}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   renumerote $dark
	   set darkmaster [ bm_smed $dark ]
       } else {
	   ::console::affiche_resultat "Le(s) fichier(s) $dark n'existe(nt) pas.\n"
	   return ""
       }



       #--- Pr�traitement du 1ier spectre de l'objet donn� pour rep�rer l'ordonn�e du spectre :
       ::console::affiche_resultat "\n\n**** Pr�traitement du premier spectre donn� pour rep�rage du spectre ****\n\n"
       #buf$audace(bufNo) load "$audace(rep_images)/$plu1"
       #buf$audace(bufNo) sub "$audace(rep_images)/$dplu1" 0
       #set intensite_moyenne [ lindex [ buf$audace(bufNo) stat ] 4 ]
       #buf$audace(bufNo) ngain $intensite_moyenne
       #buf$audace(bufNo) save "$audace(rep_images)/${plu1}-t"
       buf$audace(bufNo) load "$audace(rep_images)/$img1"
       buf$audace(bufNo) sub "$audace(rep_images)/$darkmaster" 0
       #buf$audace(bufNo) div "$audace(rep_images)/${plu1}-t" $intensite_moyenne
       buf$audace(bufNo) save "$audace(rep_images)/${img}-t"
       #file delete -force "$audace(rep_images)/${plu1}-t$conf(extension,defaut)"
       loadima ${img}-t


       #--- Correction du l'inclinaison (tilt) :
       #::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) du 1ier spectre ****\n\n"
       #set ftilt [ spc_tiltautoimgs ${img}-t n ]
       #file delete -force "$audace(rep_images)/${img}-t"
       set ftilt ${img}-t

       #--- Retrait des cosmics :
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$ftilt"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$ftilt"
       }


       #--- Traitement du spectre de la lampe de calibration :
       ::console::affiche_resultat "\n\n**** Traitement du spectre de lampe de calibration ****\n\n"
       #-- Retrait du dark : engendre des problemes de d�tection des raies !
       if { 0==1 } {
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       set exposurel [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
       buf$audace(bufNo) load "$audace(rep_images)/$darkmaster"
       set exposured [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
       buf$audace(bufNo) mult [ expr $exposurel/$exposured*1. ]
       buf$audace(bufNo) bitpix short
       buf$audace(bufNo) save "$audace(rep_images)/${darkmaster}t"
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       buf$audace(bufNo) sub "$audace(rep_images)/${darkmaster}t" 0
       buf$audace(bufNo) bitpix short
       buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
       set lampet "${lampe}-t"
       file delete "$audace(rep_images)/${darkmaster}t$conf(extension,defaut)"
       }
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       buf$audace(bufNo) setkwd [ list SPC_LNM "$lampe" string "Initial name of calibration lampe file" "" ]
       buf$audace(bufNo) bitpix short
       buf$audace(bufNo) save "$audace(rep_images)/$lampe"
       file copy -force "$audace(rep_images)/$lampe$conf(extension,defaut)" "$audace(rep_images)/${lampe}-t$conf(extension,defaut)"
       set lampet "${lampe}-t"

       #-- Correction du smilex du spectre de lampe de calibration :
       set smilexcoefs [ spc_smilex $lampet $methraie ]
       set lampegeom [ lindex $smilexcoefs 0 ]
       #set ycenter [ lindex $smilexcoefs 1 ]
       #set adeg2 [ lindex $smilexcoefs 4 ]

       #-- Inversion gauche-droite :
       if { $methinv == "o" } {
	   set lampeflip [ spc_flip $lampegeom ]
	   file delete -force "$audace(rep_images)/$lampegeom$conf(extension,defaut)"
       } else {
	   set lampeflip "$lampegeom"
       }

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       #-- Cr�ation du profil de raie de la lampe :
       if { $nbargs==8 } {
	   set profillampe [ spc_profillampe $ftilt $lampeflip $methraie ]
       } elseif { $nbargs==9 } {
	   set profillampe [ spc_profillampezone $lampeflip $wincoords ]
       }
       #-- Calibration du profil de la lampe :
       set lampecalibree [ spc_calibre $profillampe ]
       file delete -force "$audace(rep_images)/$profillampe$conf(extension,defaut)"
       #set lampecalibree "lampe_redressee_calibree"
       file delete -force "$audace(rep_images)/${img}-t$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$lampet$conf(extension,defaut)"

       #--- Calcul la resolution du spectre � partir de la raie la plus brillante trouv�e et proche du centre du capteur :
      ::console::affiche_resultat "\nCalcul la r�solution du spectre...\n"
      # set lambda_raiemax [ lindex [ lindex [ spc_findbiglines $lampecalibree e ] 0 ] 0 ]
      set liste_raies [ spc_findbiglines $lampecalibree e ]
      #-- Recherhe de la raie la plus proche du centre, sinon prend la plus brillante :
      #- Reucpere les parametres du spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
      set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      } else {
         set cdelt1 1.
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      } else {
         set crval1 1.
      }
      set lambda_max [ expr $crval1+$naxis1*$cdelt1 ]
      set lambda_cent [ expr ($lambda_max+$crval1)/2. ]
      #- Recherche de la raie la plus proche du centre :
      set liste_comp [ list ]
      set i 0
      foreach raie $liste_raies {
         lappend liste_comp [ list [ expr abs($lambda_cent-[ lindex $raie 0 ]) ] $i ]
         incr i
      }
##::console::affiche_resultat "Avant tri: $liste_comp\n"
##::console::affiche_resultat "crval1=$crval1 ; cdelt1=$cdelt1 ; Lmax=$lambda_max ; Lc=$lambda_cent\n"
      set liste_comp [ lsort -real -increasing -index 0 $liste_comp ]
      set index_lproche [ lindex [ lindex $liste_comp 0 ] 1 ]
#::console::affiche_resultat "Index : $index_lproche ; Apres tri: $liste_comp\n"
      #- Prend la longueur d'onde de la raie la plus proche du centre, sinon la plus brillante :
      if { $index_lproche >= 4 } {
         #- Compare les intensites des deux raies les plus proches du centre et choisis la plus brillante :
         if { [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 1 ] >  [ lindex [ lindex $liste_raies $index_lproche ] 1 ] } {
            set lambda_raiemax [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 0 ]
         } else {
            set lambda_raiemax [ lindex [ lindex $liste_raies 0 ] 0 ]
         }
      } else {
         set lambda_raiemax [ lindex [ lindex $liste_raies $index_lproche ] 0 ]
      }
      ::console::affiche_resultat "Longueur d'onde la plus proche du centre du CCD est : $lambda_raiemax\n"

      #-- Calcul de la resolution et l'ecrit dans le header :
      set resolution [ spc_resolution $lampecalibree $lambda_raiemax ]


       #--- Message de fin du script :
       set nomimg [ string trim $img "-" ]
       file rename -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)" "$audace(rep_images)/lampe_spectre2D_redresse-$nomimg$conf(extension,defaut)"
       file rename -force "$audace(rep_images)/$lampecalibree$conf(extension,defaut)" "$audace(rep_images)/lampe_redressee_calibree-${nomimg}$conf(extension,defaut)"
       ::console::affiche_resultat "\n\nSpectre de lampe de calibration corrig� et calibr� sauv� sous lampe_redressee_calibree-${nomimg}$conf(extension,defaut)\n\n"
       spc_loadfit lampe_redressee_calibree-${nomimg}
       set lampe2calibre_fileout "lampe_redressee_calibree-${nomimg}"
       return lampe_redressee_calibree-${nomimg}
   } else {
      ::console::affiche_erreur "Usage: spc_lampe2calibre spectre_2D_lampe nom_g�n�rique_images_objet_(sans extension) nom_dark uncosmic (o/n) m�thode_d�tection_spectre (large, serre) mirrorx (o/n) m�thode_binning (add, rober, horne) s�lection_manuelle_raie_g�om�trie (o/n) ?liste_corrdonn�es_zone?\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Proc�dure de traitement de spectres 2D : pr�traitement, correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, correction r�ponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  14-07-2006
# Date de mise � jour : 14-07-2006/061230
# M�thode : utilise spc_pretrait pour le pr�traitement
# Arguments : nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_�toile_r�f�rence profil_�toile_catalogue m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n), s�lection manuelle d'une raie pour la g�om�trie (o/n), effacer masters de pr�traitement (o/n)
###############################################################################

proc spc_traite2rinstrum { args } {

   global audace spcaudace
   global conf

   if { [llength $args] == 21 } {
       set img [ lindex $args 0 ]
       set dark [ file rootname [ lindex $args 1 ] ]
       set flat [ lindex $args 2 ]
       set dflat [ file rootname [ lindex $args 3 ] ]
       set offset [ file rootname [ lindex $args 4 ] ]
       set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
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
       set methraie [ lindex $args 17 ]
       #set methmasters [ lindex $args 18 ]
       set rmfpretrait [ lindex $args 18 ]
       set flag_calibration [ lindex $args 19 ]
       set methcalo [ lindex $args 20 ]


       #--- Elimination des mauvaise images :
       if { $methejb == "o" } {
	   ::console::affiche_resultat "\n**** �liminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       renumerote $img

       #[ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

       #--- Comptage des images :
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

       #--- Renum�rotation et d�tection des darks :
       if { [ file exists "$audace(rep_images)/$dark$conf(extension,defaut)" ] } {
	   set darkmaster $dark
       } elseif { [ catch { glob -dir $audace(rep_images) ${dark}\[0-9\]$conf(extension,defaut) ${dark}\[0-9\]\[0-9\]$conf(extension,defaut) ${dark}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   renumerote $dark
	   set darkmaster [ bm_smed $dark ]
       } else {
	   ::console::affiche_resultat "Le(s) fichier(s) $dark n'existe(nt) pas.\n"
	   return ""
       }


       #--- Renum�rotation et d�tection des darks_flat : 070323
       if { [ file exists "$audace(rep_images)/$dflat$conf(extension,defaut)" ] } {
	   set darkflatmaster $dflat
       } elseif { [ catch { glob -dir $audace(rep_images) ${dflat}\[0-9\]$conf(extension,defaut) ${dflat}\[0-9\]\[0-9\]$conf(extension,defaut) ${dflat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   renumerote $dflat
	   set darkflatmaster [ bm_smed $dflat ]
       } else {
	   ::console::affiche_resultat "Le(s) fichier(s) $dflat n'existe(nt) pas.\n"
	   return ""
       }



       #--- Traitement du spectre de la lampe de calibration :
       if { $flag_calibration == 0 } {
	   ::console::affiche_resultat "\n\n**** Traitement du spectre de lampe de calibration ****\n\n"
	   #-- Retrait du dark :
	   buf$audace(bufNo) load "$audace(rep_images)/$lampe"
	   buf$audace(bufNo) sub "$audace(rep_images)/$darkmaster" 0
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
	   set lampet "${lampe}-t"

	   #-- Correction du smilex du spectre de lampe de calibration :
	   set smilexcoefs [ spc_smilex $lampet $methraie ]
	   file delete -force "$audace(rep_images)/$lampet$conf(extension,defaut)"
	   set lampegeom [ lindex $smilexcoefs 0 ]
	   #set ycenter [ lindex $smilexcoefs 1 ]
	   #set adeg2 [ lindex $smilexcoefs 4 ]

	   #-- Inversion gauche-droite :
	   if { $methinv == "o" } {
	       set lampeflip [ spc_flip $lampegeom ]
	       file delete -force "$audace(rep_images)/$lampegeom$conf(extension,defaut)"
	   } else {
	       set lampeflip "$lampegeom"
	   }

	   #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
	   ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
	   #-- Cr�ation du profil de raie de la lampe :
	   set profillampe [ spc_profillampe ${img}1 $lampeflip ]
	   #file delete -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)"
	   set lampecalibree [ spc_calibre $profillampe ]
	   set nomimg [ string trim $img "-" ]
	   file rename -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)" "$audace(rep_images)/lampe_spectre2D-traite-$nomimg$conf(extension,defaut)"
	   file delete -force "$audace(rep_images)/$profillampe$conf(extension,defaut)"
	   #- 04012007 :
	   file rename -force "$audace(rep_images)/$lampecalibree$conf(extension,defaut)" "$audace(rep_images)/lampe_redressee_calibree-$nomimg$conf(extension,defaut)"
	   set lampecalibree "lampe_redressee_calibree-$nomimg"
       } elseif { $flag_calibration == 1 } {
	   set lampecalibree "$lampe"
       }


       #--- Pr�traitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Pr�traitement de $nbimg images ****\n\n"
       set fpretrait [ spc_pretrait $img $dark $flat $dflat $offset $rmfpretrait ]

       #--- Corrections g�om�triques des raies (smile selon l'axe x ou slant) :
       ::console::affiche_resultat "\n\n**** Corrections g�om�triques du spectre 2D ****\n\n"
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
	   set fgeom [ spc_slant2imgs $fpretrait $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction g�om�trique n�cessaire. **\n"
	   set fgeom "$fpretrait"
       }


       #--- Correction du l'inclinaison (tilt) :
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fgeom o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fgeom n ]
       }


       #--- Effacement des images pr�trait�es : NON UTILISE
       #if { $rmfpretrait=="o" && [ file exists $audace(rep_images)/${fpretrait}-1$conf(extension,defaut) ] }
       delete2 $fpretrait $nbimg
       delete2 $fgeom $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]


       #::console::affiche_resultat "Sortie : $ftilt\n"
       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement vertical de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "n"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }


       #::console::affiche_resultat "Sortie : $freg\n"
       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ spc_somme $freg ]


       #--- Effacement des images pr�trait�es :
       if { $rmfpretrait=="o" } {
	   delete2 $ftilt $nbimg
       }
       if { $rmfpretrait=="o" } {
	   delete2 $freg $nbimg
       }


       #::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D pr�trait� (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]
       file rename -force "$audace(rep_images)/$fflip$conf(extension,defaut)" "$audace(rep_images)/${img}-spectre2D-traite$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fsadd$conf(extension,defaut)"


       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]
       file copy -force "$audace(rep_images)/$fprofil$conf(extension,defaut)" "$audace(rep_images)/${img}-profil_1a$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fprofil$conf(extension,defaut)"


       #--- Calibration avec les raies telluriques :
       if { $methcalo == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fcal"
	   set listemotsclef [ buf$audace(bufNo) getkwds ]
	   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques ****\n\n"
		   set fcalo [ spc_calibretelluric "$fcal" ]
	       } else {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques non r�alis�e car dispersion insuffisante ****\n\n"
		   set fcalo "$fcal"
	       }
	   } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques ****\n\n"
		   set fcalo [ spc_calibretelluric "$fcal" ]
	       } else {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques non r�alis�e car dispersion insuffisante ****\n\n"
		   set fcalo "$fcal"
	       }
	   }
       } else {
	   set fcalo "$fcal"
       }


       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fcalo e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fcalo a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fcalo"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Calcul de la r�ponse intrumentale :
       ::console::affiche_resultat "\n\n**** Calcul de la r�ponse intrumentale ****\n\n"
       file copy -force "$spcaudace(rep_spcbib)/$etoile_cat" "$audace(rep_images)"
       # set fricorr [ spc_rinstrumcorr $fcal $etoile_ref $etoile_cat ]
       set rep_instrum [ spc_rinstrum "$fcalo" "$etoile_cat" ]
       ::console::affiche_resultat "\nR�ponse instrumentale sauv�e sous $rep_instrum\n"

       #--- Correction de l'�toile de r�f�rence par la r�ponse instrumentale :
       if { [ file exists "$audace(rep_images)/${rep_instrum}3$conf(extension,defaut)" ] } {
	   set fricorr [ spc_divri "$fcalo" ${rep_instrum}3 ]
       } elseif { [ file exists "$audace(rep_images)/${rep_instrum}br$conf(extension,defaut)" ] } {
	   set fricorr [ spc_divri "$fcalo" ${rep_instrum}br ]
       } else {
	   set fricorr "$fcalo"
       }

       #--- Nettoyage des fichiers :
       file copy -force "$audace(rep_images)/$fcalo$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-traite_1b$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fcalo$conf(extension,defaut)"
       file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-traite_1c$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
       set etoile_cat [ file rootname $etoile_cat ]
       file delete -force "$audace(rep_images)/$etoile_cat$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${etoile_cat}_ech$conf(extension,defaut)"

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\n**** Spectre trait�, corrig� et calibr� sauv� sous ****\n${img}-profil-traite_1c\n\n"
       # tk.message "Affichage du spectre trait�, corrig� et calibr� $fsmooth"
       spc_loadfit "${img}-profil-traite_1c"
       loadima "$audace(rep_images)/${img}-spectre2D-traite"
       return "${img}-profil-traite_1c"
   } else {
       ::console::affiche_erreur "Usage: spc_traite2rinstrum nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_�toile_catalogue m�thode_appariement (reg, spc, n) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_bad_spectres (o/n) rejet_rotation_importante (o/n) s�lection_manuelle_raie_g�om�trie (o/n) effacer_masters (o/n)\n\n"
   }
}
#**********************************************************************************#





###############################################################################
# Proc�dure de traitement de spectres 2D : pr�traitement, correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, correction r�ponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation :  28-08-2006
# Date de mise � jour : 28-08-2006
# M�thode : utilise spc_pretrait pour le pr�traitement
# Arguments : nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_r�ponse_instrumentale m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traite2srinstrum { args } {

   global audace spcaudace
   global conf

   set nbargs [ llength $args ]
   if { $nbargs<=21 } {
       if { $nbargs == 20 } {
          set img [ lindex $args 0 ]
          set dark [ file rootname [ lindex $args 1 ] ]
          set flat [ lindex $args 2 ]
          set dflat [ file rootname [ lindex $args 3 ] ]
          set offset [ file rootname [ lindex $args 4 ] ]
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
          set rmfpretrait [ lindex $args 17 ]
          set export_png [ lindex $args 18 ]
          set flag_2lamps [ lindex $args 19 ]
          set flag_nonstellaire 0
       } elseif { $nbargs==21 } {
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
          set rmfpretrait [ lindex $args 17 ]
          set export_png [ lindex $args 18 ]
          set flag_2lamps [ lindex $args 19 ]
          set windowcoords [ lindex $args 20 ]
          set flag_nonstellaire 1
       } else {
          ::console::affiche_erreur "Usage: spc_traite2srinstrum nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_r�ponse_instrumentale m�thode_appariement (reg, spc, n) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) effacer_masters (o/n) export_PNG (o/n) ?2 spectres de calibration (o/n)? ?fen�tre_binning {x1 y1 x2 y2}?\n\n"
	   return ""
       }


       #--- Elimination des mauvaises images :
       if { $methejbad == "o" } {
	   ::console::affiche_resultat "\n**** �liminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

       #--- Pr�traitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Pr�traitement de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 } {
	   set fpretrait [ spc_pretrait $img $dark $flat $dflat $offset $rmfpretrait $windowcoords ]
       } else {
	   set fpretrait [ spc_pretrait $img $dark $flat $dflat $offset $rmfpretrait ]
       }


       #--- Corrections g�om�triques des raies (smile selon l'axe x ou slant) :
       ::console::affiche_resultat "\n\n**** Corrections g�om�triques du spectre 2D ****\n\n"
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
	   set fgeom [ spc_slant2imgs $fpretrait $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction g�om�trique n�cessaire. **\n"
	   set fgeom "$fpretrait"
       }


       #--- Correction du l'inclinaison (tilt) :
       if { $flag_nonstellaire==1 } {
	   #- Pas de correction de l'inclinaison pour les spectres non stellaires :
	   ::console::affiche_erreur "\n\nPAS DE CORRECTION DE L'INCLINAISON POUR LES SPECTRES NON STELLAIRES\n\n"
	   set ftilt "$fgeom"
       } else {
	   ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
	   if { $methejtilt == "o" } {
	       set ftilt [ spc_tiltautoimgs $fgeom o ]
	   } else {
	       set ftilt [ spc_tiltautoimgs $fgeom n ]
	   }
       }

       #--- Effacement des images pr�trait�es :
       if { $rmfpretrait=="o" } {
	   delete2 $fpretrait $nbimg
       }
       #if { $rmfpretrait=="o" && [ file exists $audace(rep_images)/${fgeom}-1$conf(extension,defaut) ] }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]


       #--- Appariement horizontal :
       ::console::affiche_resultat "\n\n**** Appariement horizontal de $nbimg images ****\n\n"
       if { $flag_2lamps == "o" } {
          set fhreg [ spc_registerh "$lampe" "$ftilt" ]
       } else {
          set fhreg "$ftilt"
       }

       #--- Appariement vertical de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement vertical de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 } {
	   ::console::affiche_resultat "\n Pas d'appariement vertical pour les spectres non stellaires \n"
	   set freg "$fhreg"
       } else {
	   if { $methreg == "spc" } {
	       set freg [ spc_register "$fhreg" ]
	   } elseif { $methreg == "reg" } {
	       set freg [ bm_register "$fhreg" ]
	   } elseif { $methreg == "n"} {
	       set freg "$fhreg"
	   } else {
	       ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
	   }
       }


       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 } {
          #-- Somme des images pour les spectres non-stellaires car faibles :
          set fsadd [ spc_somme "$freg" add ]
       } else {
          #-- Somme moyenne des images pour les spectres stellaires car brillants :
          set fsadd [ spc_somme "$freg" moy ]
       }

       if { $rmfpretrait=="o" } {
	   delete2 "$fgeom" $nbimg
       }


       #--- Effacement des images pr�trait�es :
       if { $rmfpretrait=="o" } {
	   delete2 "$ftilt" $nbimg
       }
       if { $rmfpretrait=="o" } {
	   delete2 "$fhreg" $nbimg
       }
       if { $rmfpretrait=="o" } {
	   delete2 "$freg" $nbimg
       }


       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   #uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) setkwd [ list BSS_COSM "Weighted median filter" string "Technic used for erasing cosmics" "" ]
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       } else {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) setkwd [ list BSS_COSM "None" string "Technic used for erasing cosmics" "" ]
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }


       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
	   file delete -force "$audace(rep_images)/$fsadd$conf(extension,defaut)"
       } else {
	   set fflip "$fsadd"
       }
       file copy -force "$audace(rep_images)/$fflip$conf(extension,defaut)" "$audace(rep_images)/${img}-spectre2D-traite$conf(extension,defaut)"


       #--- Soustraction du fond de ciel et binning :
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       if { $flag_nonstellaire==1 } {
	   set fprofil [ spc_profilzone $fflip $windowcoords $methsky $methbin ]
       } else {
	   set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]
       }
       file delete -force "$audace(rep_images)/$fflip$conf(extension,defaut)"


       #--- Calibration en longueur d'onde du spectre de l'objet (niveau 1b) :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       #- Pour les spectre d'objets non-stellaire, la calibration est faite a partir de la zone decoup�e de lampe.
       set fcal [ spc_calibreloifile "$lampe" "$fprofil" ]
       file copy -force "$audace(rep_images)/$fprofil$conf(extension,defaut)" "$audace(rep_images)/${img}-profil_1a$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fprofil$conf(extension,defaut)"
       file copy -force "$audace(rep_images)/$fcal$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-calibre_1b$conf(extension,defaut)"


       #--- Correction de la r�ponse intrumentale :
       if { $rinstrum=="none" } {
	   set fricorr "$fcal"
       } else {
          ::console::affiche_resultat "\n\n**** Correction de la r�ponse intrumentale ****\n\n"
          buf$audace(bufNo) load "$audace(rep_images)/$rinstrum"
          set naxis1 [  lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
          set cdelt1 [  lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
          set largeur_spectrale [ expr $cdelt1*$naxis1 ]
          if { $largeur_spectrale >= $spcaudace(bande_br) } {
             set imaxtol $spcaudace(imax_tolerence)
             set spcaudace(imax_tolerence) 1.10
          }
	   #-- Messge d'erreur en cas d'une s�lection de plage de longueur d'onde :
	   if { $flag_nonstellaire==1 } {
	       set xdeb [ lindex $windowcoords 0 ]
	       set xfin [ lindex $windowcoords 2 ]
	       if { $xdeb>1 || $xfin<$naxis1 } {
		   ::console::affiche_erreur "\nPAS DE CORRECTION DE LA R�PONSE INSTRUMENTALE LORS D'UNE S�LECTION DE LARGEUR SP�CIFIQUE DU SPECTRE.\n"
		   set fricorr "$fcal"
	       } else {
                  set fricorr [ spc_divri $fcal $rinstrum ]
	       }
	   } else {
              set fricorr [ spc_divri $fcal $rinstrum ]
	   }
          if { $largeur_spectrale >= $spcaudace(bande_br) } {
             set spcaudace(imax_tolerence) $imaxtol
          }


	   #-- Division du profil par la RI :
	   ## set rinstrum_ech [ spc_echant $rinstrum $fcal ]
	   ## set fricorr [ spc_div $fcal $rinstrum_ech ]
	   #- Beaucoup de mise a 0 si methode avec reechant avant. Methode courante est calibreloifile :
	   # set fricorr [ spc_divri $fcal $rinstrum ]
	   #- 040107 :
	   ## set fricorr [ spc_div $fcal $rinstrum ]

	   #-- Message d'erreur en cas d'�chec de la division :
	   if { $fricorr == 0 } {
	       ::console::affiche_resultat "\nLa division par la r�ponse intrumentale n'a pas pu peut �tre calcul�e.\n"
	       return 0
	   } else {
	       file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-calibre_1c$conf(extension,defaut)"
	   }
       }


       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr e ]
	   file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-calibre-norma_2bb$conf(extension,defaut)"
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr a ]
	   file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-calibre-norma_2bb$conf(extension,defaut)"
       } elseif { $methnorma == "o" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonorma $fricorr ]
	   file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-calibre-norma_2bb$conf(extension,defaut)"
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }



       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
	   file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }


       #--- Lin�arisation de la calibration en longueur d'onde :
       if { $spcaudace(linear_cal)=="o" } {
	   set flinearcal [ spc_linearcal "$fsmooth" ]
       } else {
	   set flinearcal "$fsmooth"
       }


       #--- Export au format PNG :
       if { $export_png=="o" } {
	   set fichier_png [ spc_export2png "$flinearcal" ]
       }


       #--- Message de fin du script :
       file copy -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-traite-final$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fsmooth$conf(extension,defaut)"
       ::console::affiche_resultat "\n\nSpectre trait�, corrig� et calibr� sauv� sous ${img}-profil-traite-final\n\n"
       file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
       if { "$flinearcal" != "${img}-profil-traite-final" } {
	   file delete -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)"
       }
       # tk.message "Affichage du spectre trait�, corrig� et calibr� $fsmooth"
       #spc_loadfit $fsmooth
       #return $fsmooth

       #--- Traitement du r�sultat :
       spc_loadfit "${img}-profil-traite-final"
       loadima "$audace(rep_images)/${img}-spectre2D-traite"
       ::console::affiche_resultat "\n\n**** Spectre trait�, corrig� et calibr� sauv� sous ****\n${img}-profil-traite-final\n\n"
       return "${img}-profil-traite-final"
   } else {
       ::console::affiche_erreur "Usage: spc_traite2srinstrum nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_r�ponse_instrumentale m�thode_appariement (reg, spc, n) uncosmic (o/n) m�thode_d�tection_spectre (large, serre, moy) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) effacer_masters (o/n)  export_PNG (o/n) 2_lampes_calibration (o/n) ?fen�tre_binning {x1 y1 x2 y2}?\n\n"
   }
}
#**********************************************************************************#





###############################################################################
# Proc�dure de traitement de spectres 2D stellaire : calibration, pr�traitement, correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, correction r�ponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation : 16-06-2007
# Date de mise � jour : 16-06-2007
# M�thode : utilise spc_pretrait pour le pr�traitement
# Arguments : nom_lampe nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_r�ponse_instrumentale m�thode_s�lection_raies m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traitestellaire { args } {

   global audace spcaudace
   global conf


   if { [llength $args] == 24 } {
       set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set brut [ lindex $args 1 ]
       set noir [ file rootname [ lindex $args 2 ] ]
       set plu [ lindex $args 3 ]
       set noirplu [ file rootname [ lindex $args 4 ] ]
       set offset [ file rootname [ lindex $args 5 ] ]
       set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set methraie [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methinv [ lindex $args 9 ]
       set methnorma [ lindex $args 10 ]
       set cal_eau [ lindex $args 11 ]
       set export_png [ lindex $args 12 ]
       set export_bess [ lindex $args 13 ]
       #--- Param�tres pr�d�finis :
       set methreg [ lindex $args 14 ]
       set methsel [ lindex $args 15 ]
       set methsky [ lindex $args 16 ]
       set methbin [ lindex $args 17 ]
       set methsmo [ lindex $args 18 ]
       set ejbad [ lindex $args 19 ]
       set ejtilt [ lindex $args 20 ]
       set rmfpretrait [ lindex $args 21 ]
       set flag_2lamps [ lindex $args 22 ]
       set flag_calibration [ lindex $args 23 ]


       #-- Rappel des options pr�d�finies par l'interface graphique :
       #set methreg "spc"
       #set methsky "med"
       #set methbin "rober"
       #set methsmo "n"
       #set ejbad "n"
       #set ejtilt "n"
       #set rmfpretrait "o"


       #--- Profil et calibration du spectre de la lampe et calibration :
       if { $flag_calibration==1 } {
          set lampe_traitee "$lampe"
       } else {
          set lampe_traitee [ spc_lampe2calibre "$lampe" "$brut" "$noir" $methcos $methsel $methinv $methbin $methraie ]
       }

       #--- Recherche des masters dark, flat et darkflat :
       #-- Noirs :
       if { [ file exists "$audace(rep_images)/$noir$conf(extension,defaut)" ] } {
	   set noir_master "$noir"
       } elseif { [ catch { glob -dir $audace(rep_images) $noir*-smd\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noir_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $noir*-smd\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noir_master "$noir"
       }

       #-- Noirs_plu :
       if { [ file exists "$audace(rep_images)/$noirplu$conf(extension,defaut)" ] } {
	   set noirplu_master "$noirplu"
       } elseif { [ catch { glob -dir $audace(rep_images) $noirplu*-smd\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noirplu_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $noirplu*-smd\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noirplu_master "$noirplu"
       }


       #--- Application aux spectre de l'�toile :
       #-- Export PNG plus tard dans ce pipe, donc option "n" passee en argument.
       set spectre_traite [ spc_traite2srinstrum "$brut" "$noir_master" "$plu" "$noirplu_master" "$offset" "$lampe_traitee" "$rinstrum" $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $rmfpretrait "n" $flag_2lamps ]
       #- L'export au format PNG est ici r�alis� en dehors de spc_traite2srinstrum

       #--- Calibration avec les raies telluriques :
       if { $cal_eau=="o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$spectre_traite"
	   set listemotsclef [ buf$audace(bufNo) getkwds ]
	   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques ****\n\n"
		   set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
	       } else {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques non r�alis�e car dispersion insuffisante ****\n\n"
		   set spectre_calo "$spectre_traite"
	       }
	   } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques ****\n\n"
		   set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
	       } else {
		   ::console::affiche_resultat "\n\n**** Calibration avec les raies telluriques non r�alis�e car dispersion insuffisante ****\n\n"
		   set spectre_calo "$spectre_traite"
	       }
	   }
	   ## set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
       } else {
	   set spectre_calo "$spectre_traite"
       }

       #--- Lin�arisation de la calibration en longueur d'onde :
       if { $spcaudace(linear_cal)=="o" } {
	   set flinearcal [ spc_linearcal "$spectre_calo" ]
	   # file delete -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)"
       } else {
	   set flinearcal "$spectre_calo"
       }


       #--- Export au format PNG :
       if { $export_png=="o" } {
	   set spectre_png [ spc_export2png "$flinearcal" ]
       } else {
	   set spectre_png "$flinearcal"
       }


       #--- Export au format Bess :
       if { $export_bess=="o" } {
	   #-- Recherche le spectre _1c :
	   if { [ catch { glob -dir $audace(rep_images) $brut*_1c$conf(extension,defaut) } ]==0 } {
	       set spectre_1c [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $brut*_1c$conf(extension,defaut) ] ]
	   } else {
	       ::console::affiche_resultat "Le spectre doit �tre corrig� de la r�ponse instrumentale pour �tre d�pos� dans la base BeSS\n"
	       return "$spectre_png"
	   }
	   #-- Calibrer avec l'eau si specifi� :
	   set spectre_calo1c [ spc_calibretelluric "$spectre_1c" ]
	   if { "$spectre_calo1c" != "" } {
	       #-- Lineariser le spectre :
	       set spectre_linear [ spc_linearcal "$spectre_calo1c" ]
	       #-- Cr�ation des mots clef BeSS :
	       #set spectre_bess [ spc_bessmodule  "$spectre_linear" ]
	       source [ file join $spcaudace(repspc)  plugins bess_module bess_module.tcl ]
	       set spectre_bess [ ::bess::Principal  "$spectre_linear" ]
	       #-- Ouverture du site Internet BeSS :
	       #spc_bess
	   } else {
	       set spectre_bess "$spectre_1c"
	   }
       } else {
	   set spectre_bess "$flinearcal"
       }


       #--- Traitements des r�sultats :
       if { "$flinearcal" != "${brut}-profil-traite-final" } {
          file copy -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-traite-final$conf(extension,defaut)"
          file delete -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)"
       }
       if { $cal_eau=="o" } {
	   ::console::affiche_resultat "\n\n**** Qualit� de la calibration en longueur d'onde ****\n\n"
	   spc_caloverif "${brut}-profil-traite-final"
       }
       ::console::affiche_resultat "\n\n**** Spectre trait�, corrig� et calibr� sauv� sous ****\n${brut}-profil-traite-final\n\n"
       return "${brut}-profil-traite-final"
   } else {
       ::console::affiche_erreur "Usage: spc_traitestellaire nom_lampe nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_r�ponse_instrumentale s�lection_manuelle_raies uncosmic (o/n) mirrorx (o/n) normalisation (o/n) calibration_raies_telluriques (o/n) export_png (o/n) export_bess (o/n) m�thode_appariement (reg, spc, n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none)m�thode_binning (add, rober, horne) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) efface_pretraitement (o/n) 2_lampes_calibration (o/n) lampe_calibr�e (1/0)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Proc�dure de traitement de spectres 2D non stellaires : calibration, pr�traitement, correction g�om�triques, r�gistration, sadd, spc_profil, calibration en longeur d'onde, correction r�ponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation : 16-06-2007
# Date de mise � jour : 16-06-2007
# M�thode : utilise spc_pretrait pour le pr�traitement
# Attention : usage d'une GUI pour le choix de la zone d'�tude
# Arguments : nom_lampe nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_r�ponse_instrumentale m�thode_s�lection_raies m�thode_appariement (reg, spc) uncosmic (o/n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) m�thode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traitenebula { args } {

   global audace spcaudace
   global conf
   global spc_windowcoords

#$lampe $brut $noir $plu $noirplu $offset $rinstrum $methraie $methcos $methinv $methnorma $export_png $methreg $methsky $methbin $methsmo $rmfpretrait

   if { [llength $args] == 19 } {
       set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set brut [ lindex $args 1 ]
       set noir [ file rootname [ lindex $args 2 ] ]
       set plu [ lindex $args 3 ]
       set noirplu [ file rootname [ lindex $args 4 ] ]
       set offset [ file rootname [ lindex $args 5 ] ]
       set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set methraie [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methinv [ lindex $args 9 ]
       set methnorma [ lindex $args 10 ]
       set export_png [ lindex $args 11 ]
       #--- Param�tres pr�d�finis :
       set methreg [ lindex $args 12 ]
       set methsky [ lindex $args 13 ]
       set methbin [ lindex $args 14 ]
       set methsmo [ lindex $args 15 ]
       set rmfpretrait [ lindex $args 16 ]
       set flag_2lamps [ lindex $args 17 ]
       set flag_calibration [ lindex $args 18 ]
       set ejbad "n"
       set ejtilt "n"
       set methsel "serre"


       #-- Rappel des options pr�d�finies par l'interface graphique :
       #set methreg "spc"
       #set methsky "med"
       #set methbin "rober"
       #set methsmo "n"
       #set rmfpretrait "o"



       #--- Recherche des masters dark, flat et darkflat :
       #-- Noirs :
       if { [ file exists "$audace(rep_images)/$noir$conf(extension,defaut)" ] } {
	   set noir_master "$noir"
       } elseif { [ catch { glob -dir $audace(rep_images) ${noir}\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noir_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${noir}\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noir_master "$noir"
       }

       #-- Noirs_plu :
       if { [ file exists "$audace(rep_images)/$noirplu$conf(extension,defaut)" ] } {
	   set noirplu_master "$noirplu"
       } elseif { [ catch { glob -dir $audace(rep_images) ${noirplu}\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noirplu_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${noirplu}\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noirplu_master "$noirplu"
       }


       #--- S�lection de la zone d'int�r�t du spectre :
       renumerote "$brut"
       set fsmea [ bm_smean "$brut" ]
       buf$audace(bufNo) load "$audace(rep_images)/$fsmea"
       buf$audace(bufNo) sub "$audace(rep_images)/$noir_master" 0
       buf$audace(bufNo) save "$audace(rep_images)/${fsmea}-t"

       set err [ catch {
	   ::param_spc_audace_selectzone::run "${fsmea}-t"
	   tkwait window .param_spc_audace_selectzone
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       file delete "$audace(rep_images)/$fsmea$conf(extension,defaut)"
       file delete "$audace(rep_images)/${fsmea}-t$conf(extension,defaut)"


       #--- Profil du spectre de la lampe et calibration :
       if { $flag_calibration==1 } {
	   set lampe_traitee "$lampe"
       } else {
	   set lampe_traitee [ spc_lampe2calibre "$lampe" "$brut" "$noir" $methcos $methsel $methinv $methbin $methraie $spc_windowcoords ]
       }

       #--- Application aux spectre de l'�toile :
       #-- L'export au format PNG est ici r�alis� en dehors de spc_traite2srinstrum : donc "n".
       #-- Pas de gestion de deux spectres de lampes de calibration : donc "n".
       set spectre_traite [ spc_traite2srinstrum "$brut" "$noir_master" "$plu" "$noirplu_master" "$offset" "$lampe_traitee" "$rinstrum" $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $rmfpretrait "n" $flag_2lamps $spc_windowcoords ]


       #--- Export au format PNG :
       if { $export_png=="o" } {
	   set spectre_png [ spc_export2png "$spectre_traite" ]
       } else {
	   set spectre_png "$spectre_traite"
       }


       #--- R�sultat des traitements :
       # file copy -force "$audace(rep_images)/$spectre_traite$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-traite-final$conf(extension,defaut)"
       # file delete -force "$audace(rep_images)/$spectre_traite$conf(extension,defaut)"
       ::console::affiche_resultat "\n\n**** Spectre trait�, corrig� et calibr� sauv� sous ****\n${brut}-profil-traite-final\n\n"
       return "${brut}-profil-traite-final"
   } else {
       ::console::affiche_erreur "Usage: spc_traitenebula nom_lampe nom_g�n�rique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_r�ponse_instrumentale s�lection_manuelle_raies uncosmic (o/n) mirrorx (o/n) normalisation (o/n) calibration_raies_telluriques (o/n) export_png (o/n) export_bess (o/n) m�thode_appariement (reg, spc, n) m�thode_d�tection_spectre (large, serre) m�thode_sub_sky (moy, moy2, med, inf, sup, back, none)m�thode_binning (add, rober, horne) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) efface_pretraitements (o/n) 2_lampes_calibration (o/n) lampe_calibr�e (1/0)\n\n"
   }
}
 #**********************************************************************************#
