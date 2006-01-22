# Chargement en script : source $audace(rep_scripts)/spcaudace/spc_metaf.tcl

###############################################################################
#
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
       set fichier_final3 [ spc_profil $fichier_final2 ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       file copy $fichier_final.dat traitees
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
       set nom_generique_reg [ spc_register $nom_generique_pretrait ]
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
       set fichier_final3 [ spc_profil $fichier_final2 ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       file copy $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   } else {
       ::console::affiche_erreur "Usage: spc_traitea nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?xinf_crop yinf_crop?\n\n"
   }
}
###############################################################################
