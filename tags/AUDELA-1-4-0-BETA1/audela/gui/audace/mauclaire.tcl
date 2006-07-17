#-----------------------------------------------------------------------------#
#
# Fichier : mauclaire.tcl
# Description : Scripts pour un usage aise des fonctions d'AudeLA
# Auteur : Benjamin MAUCLAIRE (bmauclaire@underlands.org)
# Mise a jour $Id: mauclaire.tcl,v 1.4 2006-07-07 22:11:30 robertdelmas Exp $
#
#-----------------------------------------------------------------------------#

#--------------------- Liste des fonctions -----------------------------------#
#
# bm_extract_radec   : extrait le RA et DEC d'une image ou l'astrometrie est realisée
# bm_renameext       : renome l'extension de fichiers en extension par defaut d'Audela
# bm_renumfile       : renome les fichier de numérotation collée au nom
# bm_pregister_lin   : regsitration planetaire sur un point initial et finale : translation lineaire
# bm_sflat           : créée un flat synthétique (image d'intensité uniforme) de nxp pixels.
# bm_pretrait        : effectue le prétraitement d'une série d'images à l'aide du dark, plu, dark de plu.
# bm _sadd           : effectue la somme d'une série d'images.
# bm_somes           : effectue la somme moyenne, mediane et ssk d'une serie d'images appariees.
# bm_fwhm            : calcul la largeur équivalente d'une étoile en secondes d'arc.
#
#-----------------------------------------------------------------------------#

#---------------------- Artifice ---------------------------------------------#
#
# La variable "audace(artifice)" vaut toujours "@@@@" c'est un artifice qui
# permet d'attribuer cette valeur à la variable "fichier" dans le cas d'une
# image chargée en mémoire
# Cette variable "audace(artifice)" est définie dans le script "aud3.tcl"
#
#-----------------------------------------------------------------------------#


###############################################################################
#
# Descirption : extrait le RA et DEC d'une image ou l'astrometrie est realisée
# Auteur : Benjamin MAUCLAIRE
# Date création : 24-01-2006
# Date de mise à jour : 24-01-2006
# Arguments : aucun
###############################################################################

proc bm_extract_radec {} {
    global audace
    global conf
# Par defaut, travaille dans le rep images configuré dans Audela.
# Ne demande aucun arguments
set file_id [open "$audace(rep_images)/coordonnees.txt" w+]
set liste_fichiers [ glob *.fit ]

foreach fichier $liste_fichiers {
	buf$audace(bufNo) load $audace(rep_images)/$fichier
	#  RA of center of the image
	set ra [lindex [buf$audace(bufNo) getkwd "OBJCTRA"] 1]
	# DEC of center of the image
	set dec [lindex [buf$audace(bufNo) getkwd "OBJCTDEC"] 1]
	puts $file_id "$ra $dec"
}
close $file_id
}
#****************************************************************************#



###############################################################################
#
# Descirption : se met dans le répertoire de travail d'Audace pour éviter de 
#  mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date création : 17-12-2005
# Date de mise à jour : 17-12-2005
# Arguments : aucun
###############################################################################
proc bm_goodrep {} {

    global audace
    global conf
    set repdflt [pwd]
    cd $audace(rep_images)
    return $repdflt
}
#****************************************************************************#


###############################################################################
#
# Descirption : renome les fichier de numérotation collée au nom
# Auteur : Benjamin MAUCLAIRE
# Date création : 16-12-2005
# Date de mise à jour : 16-12-2005
# Arguments : nom générique
###############################################################################

proc bm_renumfile { args } {

    global audace
    global conf

    if { [llength $args] == 1 } {
	set nom_generique [lindex $args 0]
	#set liste_images [ glob ${nom_generique}*$conf(extension,defaut) ]
	set liste_images [ lsort -dictionary [glob ${nom_generique}*$conf(extension,defaut)] ]
	set nbimg [ llength $liste_images ]
	set nom1 [ lindex $liste_images 0 ]
	regexp {(.+)[0-9]{1,2}} $nom1 match pref_nom_generique
	::console::affiche_resultat "Prefixe : $pref_nom_generique\n"
	file mkdir sortie
	foreach fichier $liste_images {
	    # regexp {.+([0-9]{1,2})} $fichier match numero
	    regexp {.+[a-zA-Z]([0-9]+)} $fichier match numero
	    ::console::affiche_resultat "Copie de $fichier de buméro $numero vers sortie/${pref_nom_generique}-$numero$conf(extension,defaut)\n"
	    file copy ${fichier} sortie/${pref_nom_generique}-$numero$conf(extension,defaut)
	}
	::console::affiche_resultat "Fichiers renomés dans les le répertoire sortie.\n"
    } else {
	::console::affiche_erreur "Usage: bm_renumfile nom_générique de fichier à la numérotation collée.\n"
    }
}
#****************************************************************************#


###############################################################################
#
# Descirption : renome l'extension de fichiers en extension par defaut d'Audela
# Auteur : Benjamin MAUCLAIRE
# Date création : 17-12-2005
# Date de mise à jour : 17-12-2005
# Arguments : répertoire, extension actuelle des fichiers
###############################################################################

proc bm_renameext { args } {

    global audace
    global conf

    if { [llength $args] <= 2 } {
	set repdflt [pwd]
	if { [llength $args] == 2 } {
	    set repertoire [lindex $args 0]
	    set old_extension [ lindex $args 1 ]
	} elseif { [llength $args] == 1 } {
	    set old_extension [ lindex $args 0 ]
	    set repertoire $audace(rep_images)
	}

	cd $repertoire
	set liste_fichiers [ lsort -dictionary [glob *$old_extension] ]
	set nbimg [ llength $liste_fichiers ]
	::console::affiche_resultat "$nbimg fichiers à renomer.\n"

	foreach fichier $liste_fichiers {
	    #regexp {(.+)\.$old_extension} $fichier match prefixe_nom
	    set prefixe_nom [ file rootname $fichier ]
	    if { [file exists ${prefixe_nom}$conf(extension,defaut)] == 0 } {
		::console::affiche_resultat "${fichier} renomé en ${prefixe_nom}$conf(extension,defaut)\n"
		file copy $fichier $repertoire/${prefixe_nom}$conf(extension,defaut)
	    }
	}
	cd $repdflt
    } else {
	::console::affiche_erreur "Usage: bm_renameext \[répertoire\] extension_actuelle.\n"
    }
}
#****************************************************************************#



###############################################################################
#
# Descirption : regsitration planetaire sur un point initial et finale : translation lineaire
# Auteur : Benjamin MAUCLAIRE
# Date création : 16-12-2005
# Date de mise à jour : 16-12-2005
# Argument : nom_generique_fichier (sans extension)
###############################################################################


proc bm_pregister_lin { args } {

    global audace
    global conf
    global flag_ok

    if {[llength $args] == 1} {
	set nom_generique [ lindex $args 0 ]
	set repdflt [bm_goodrep]

	#--- Renumerote la série de fichier ----
	#renumerote $nom_generique
	#set liste_images [ glob ${nom_generique}*$conf(extension,defaut) ]
	set liste_images [ lsort -dictionary [glob ${nom_generique}*$conf(extension,defaut)] ]
	set nbimg [ llength $liste_images ]
	
	#--- Reperage du point de depart ----
	set image_depart [lindex $liste_images 0]
	loadima $image_depart
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Sélectionnez l'objet à suivre (boîte petite)"
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "Ok"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set coords_zone $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Determine le photocentre de la zone sélectionée
	set stats [ buf$audace(bufNo) stat ]
	#set point_depart [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ]
	set point_depart [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
	::console::affiche_resultat "Point A : $point_depart\n"


	#---------------------------------------------------------#
	#--- Reperage du point final ----
	set image_finale [lindex $liste_images [expr $nbimg-1] ]
	loadima $image_finale
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Sélectionnez l'objet à suivre (boîte petite)"
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "Ok"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set coords_zone $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Determine le photocentre de la zone sélectionée
	set stats [ buf$audace(bufNo) stat ]
	set point_final [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
	::console::affiche_resultat "Point B : $point_final\n"

	#--- Caclul le deplacement de la comete entre chaque image
	set erra [ lindex $point_depart 2 ]
	#set erra 0.1
	if { $erra >=0.3 } {
	    set x_depart [expr [lindex $point_depart 0]+$erra ]
	    set y_depart [expr [lindex $point_depart 1]+$erra ]
	} else {
	    set x_depart [ lindex $point_depart 0 ]
	    set y_depart [ lindex $point_depart 1 ]
	}
	set errb [ lindex $point_final 2 ]
	if { $erra >=0.3 } {
	    set x_final [expr [lindex $point_final 0]+$errb ]
	    set y_final [expr [lindex $point_final 1]+$errb ]
	} else {
	    set x_final [ lindex $point_final 0 ]
	    set y_final [ lindex $point_final 1 ]
	}
	#set x_final [ lindex $point_final 0 ]
	#set y_final [ lindex $point_final 1 ]
	set ecart_x [expr $x_final-$x_depart ]
	set ecart_y [expr $y_final-$y_depart ]
	::console::affiche_resultat "Écart total en x : $ecart_x ; Écart total en y : $ecart_y\n"
	set deplacement_x [ expr -1.0*$ecart_x/$nbimg ]
	set deplacement_y [ expr -1.0*$ecart_y/$nbimg ]
	::console::affiche_resultat "Déplacement sur chaque image : $deplacement_x ; $deplacement_y\n"

	#--- Recalage de chaque image (sauf n°1)
	#-- le deplacement de l'objet est suppose lineaire
	#-- Isole le préfixe des noms de fichiers
	regexp {(.+)\-} $nom_generique match pref_nom_generique
	::console::affiche_resultat "Appariement de $nbimg images...\n"
	#- trans2 est Buggé !
	#trans2 $nom_generique ${pref_nom_generique}_reg- $nbimg $deplacement_x $deplacement_y
	set i 1
	foreach fichier $liste_images {
	    set delta_x [expr $deplacement_x*($i-1)]
	    set delta_y [expr $deplacement_y*($i-1)]
	    buf$audace(bufNo) load $fichier
	    buf$audace(bufNo) imaseries "TRANS trans_x=$delta_x trans_y=$delta_y"
	    buf$audace(bufNo) save ${pref_nom_generique}_reg-$i
	    incr i
	}
	file delete ${pref_nom_generique}_reg-1$conf(extension,defaut)
	file copy ${pref_nom_generique}-1$conf(extension,defaut) ${pref_nom_generique}_reg-1$conf(extension,defaut)
	::console::affiche_resultat "Images recalées sauvées sous ${pref_nom_generique}_reg-n°$conf(extension,defaut)\n"

	#--- Somme des images :
	::console::affiche_resultat "Somme de $nbimg images... sauvées sous ${pref_nom_generique}_s$nbimg\n"
	sadd ${pref_nom_generique}_reg- ${pref_nom_generique}_s$nbimg $nbimg
	loadima ${pref_nom_generique}_s$nbimg
	delete2 ${pref_nom_generique}_reg- $nbimg
	cd $repdflt
    } else {
	::console::affiche_erreur "Usage : bm_pregister_lin nom_generique_images\n\n"
    }
}
#****************************************************************************#


###############################################################################
#
# Descirption : créée un flat synthétique (image d'intensité uniforme) de nxp pixels.
# Auteur : Benjamin MAUCLAIRE
# Date création : 08-09-2005
# Date de mise à jour : 03-12-2005
# Arguments : nom de l'image de sortie, naxis1, naxis2, valeur des pixels.
# Méthode : par soustraction du noir et sans offset.
#
###############################################################################

proc bm_sflat { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       set nom_flat [ lindex $args 0 ]
       set naxis1 [ lindex $args 1 ]
       set naxis2 [ lindex $args 2 ]
       set intensite [ lindex $args 3 ]

       buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $naxis2 FORMAT_USHORT COMPRESS_NONE 0
       buf$audace(bufNo) offset $intensite
       #for {set y 1} {$y<=$naxis2} {incr y} {
	#   for {set x 1} {$x<=$naxis1} {incr x} {
	 #      buf$audace(bufNo) setpix [ list $x $y ] $intensite
	  # }
       #}
       buf$audace(bufNo) save $nom_flat
       ::console::affiche_resultat "Flat artificiel sauvé sous $nom_flat\n"
       return $nom_flat
   } else {
       ::console::affiche_erreur "Usage: bm_sflat nom_flat_sortie largeur hauteur valeur\n"
   }
}
#****************************************************************************#



###############################################################################
#
# Descirption : effectue la somme moyenne, mediane et ssk d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date création : 27-08-2005
# Date de mise à jour : 21-12-2005
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu
# Méthode : par soustraction du noir et sans offset.
# Bug : Il faut travailler dans le rep parametre d'Audela, donc revoir toutes les operations !!
###############################################################################

proc bm_pretrait { args } {

   global audace
   global conf

   if {[llength $args] == 4} {
       #--- On se place dans le répertoire d'images configuré dans Audace
       set repdflt [ bm_goodrep ]
       set nom_stellaire [ lindex $args 0 ]
       set nom_dark [ lindex $args 1 ]
       set nom_flat [ lindex $args 2 ]
       set nom_darkflat [ lindex $args 3 ]

       ## Renumerote chaque série de fichier
       renumerote $nom_stellaire
       renumerote $nom_dark
       renumerote $nom_flat
       renumerote $nom_darkflat

       ## Isole le préfixe des noms de fichiers
       regexp {(.+)\-} $nom_stellaire match pref_stellaire
       regexp {(.+)\-} $nom_dark match pref_dark
       regexp {(.+)\-} $nom_flat match pref_flat
       regexp {(.+)\-} $nom_darkflat match pref_darkflat

       ## Détermine les listes de fichiers de chasue série
       set stellaire_liste [ glob -dir $audace(rep_images) ${nom_stellaire}*$conf(extension,defaut) ]
       set nb_stellaire [ llength $stellaire_liste ]
       set dark_liste [ glob -dir $audace(rep_images) ${nom_dark}*$conf(extension,defaut) ]
       set nb_dark [ llength $dark_liste ]
       set flat_liste [ glob -dir $audace(rep_images) ${nom_flat}*$conf(extension,defaut) ]
       set nb_flat [ llength $flat_liste ]
       set darkflat_liste [ glob -dir $audace(rep_images) ${nom_darkflat}*$conf(extension,defaut) ]
       set nb_darkflat [ llength $darkflat_liste ]

       ## Prétraitement des fichiers de darks, de flats, de darkflats
       if { $nb_dark == 1 } {
	   ::console::affiche_resultat "L'image de dark est $nom_dark$conf(extension,defaut)\n"
	   set pref_dark $nom_dark
	   file copy $nom_dark$conf(extension,defaut) ${pref_dark}_smd$nb_dark$conf(extension,defaut)
       } else {
	   ::console::affiche_resultat "Somme médiane de $nb_dark dark(s)...\n"
	   smedian "$nom_dark" "${pref_dark}_smd$nb_dark" $nb_dark
       }
       if { $nb_darkflat == 1 } {
	   ::console::affiche_resultat "L'image de dark de flat est $nom_darkflat$conf(extension,defaut)\n"
	   set pref_darkflat "$nom_darkflat"
	   file copy $nom_darkflat$conf(extension,defaut) ${pref_darkflat}_smd$nb_darkflat$conf(extension,defaut)
       } else {
	   ::console::affiche_resultat "Somme médiane de $nb_darkflat dark(s) associé(s) aux flat(s)...\n"
	   smedian "$nom_darkflat" "${pref_darkflat}_smd$nb_darkflat" $nb_darkflat
       }
       if { $nb_flat == 1 } {
	   set pref_flat $nom_flat
	   buf$audace(bufNo) load "$nom_flat"
	   sub "${pref_darkflat}_smd$nb_darkflat" 0
	   buf$audace(bufNo) save "${pref_flat}_smd$nb_flat"
       } else {
	   sub2 "$nom_flat" "${pref_darkflat}_smd$nb_darkflat" "${pref_flat}_moinsnoir-" 0 $nb_flat
	   set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-*$conf(extension,defaut) ] ] 0 ]
	   #set flat_traite_1 [ lindex [ glob ${pref_flat}_moinsnoir-*$conf(extension,defaut) ] 0 ]
       }

       if { $nb_flat == 1 } {
	   # Calcul du niveau moyen de la première image
	   #buf$audace(bufNo) load "${pref_flat}_moinsnoir-1"
	   #set intensite_moyenne [lindex [stat] 4]
	   ## Mise au même niveau de toutes les images de PLU
	   #::console::affiche_resultat "Mise au même niveau de l'image de PLU...\n"
	   #ngain $intensite_moyenne
	   #buf$audace(bufNo) save "${pref_flat}_smd$nb_flat"
	   #file copy ${pref_flat}_moinsnoir-$nb_flat$conf(extension,defaut) ${pref_flat}_smd$nb_flat$conf(extension,defaut)
	   ::console::affiche_resultat "Le flat prétraité est ${pref_flat}_smd$nb_flat\n"
       } else {
	   # Calcul du niveau moyen de la première image
	   buf$audace(bufNo) load "$flat_moinsnoir_1"
	   set intensite_moyenne [lindex [stat] 4]
	   # Mise au même niveau de toutes les images de PLU
	   ::console::affiche_resultat "Mise au même niveau de toutes les images de PLU...\n"
	   ngain2 "${pref_flat}_moinsnoir-" "${pref_flat}_auniveau-" $intensite_moyenne $nb_flat
	   ::console::affiche_resultat "Somme médiane des flat prétraités...\n"
	   smedian "${pref_flat}_auniveau-" "${pref_flat}_smd$nb_flat" $nb_flat
	   #file delete [ file join [ file rootname ${pref_flat}_auniveau-]$conf(extension,defaut) ]
	   delete2 "${pref_flat}_auniveau-" $nb_flat
	   delete2 "${pref_flat}_moinsnoir-" $nb_flat
       }

       ## Prétraitement des images stellaires
       # Soustraction du noir des images stellaires
       ::console::affiche_resultat "Soustraction du noir des images stellaires...\n"
       sub2 "$nom_stellaire" "${pref_dark}_smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire
       # Calcul du niveau moyen de la PLU traitée
       buf$audace(bufNo) load "${pref_flat}_smd$nb_flat"
       set intensite_moyenne [lindex [stat] 4]
       # Division des images stellaires par la PLU
       ::console::affiche_resultat "Division des images stellaires par la PLU...\n"
       div2 "${pref_stellaire}_moinsnoir-" "${pref_flat}_smd$nb_flat" "${pref_stellaire}_t-" $intensite_moyenne $nb_stellaire
       set image_traite_1 [ lindex [ lsort -dictionary [ glob ${pref_stellaire}_t-*$conf(extension,defaut) ] ] 0 ]
       loadima "$image_traite_1"
       ::console::affiche_resultat "Affichage de la première image prétraitée\n"
       delete2 "${pref_stellaire}_moinsnoir-" $nb_stellaire
       #--- Retour dans le répertoire de départ avnt le script
       cd $repdflt
       return ${pref_stellaire}_t-
   } else {
       ::console::affiche_erreur "Usage: bm_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu\n\n"
   }
}
#****************************************************************************#


###############################################################################
#
# Descirption : effectue la somme moyenne, mediane et ssk d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date création : 06 aout 2005
# Date de mise à jour : 27-12-05
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_sadd { args } {

   global audace
   global conf

   if {[llength $args] == 1} {
       set repdflt [bm_goodrep]
       set nom_generique [ lindex $args 0 ]
       set nb_file [ llength [  glob -dir $audace(rep_images) ${nom_generique}*$conf(extension,defaut) ] ]
       regexp {(.+)\-} $nom_generique match pref_nom

       ::console::affiche_resultat "Somme de $nb_file images... sauvées sous ${pref_nom}_s$nb_file\n"
       sadd $nom_generique ${pref_nom}_s$nb_file $nb_file
       cd $repdflt
       return ${pref_nom}_s$nb_file
   } else {
       ::console::affiche_erreur "Usage: bm_sadd nom_generique_fichier (sans extension)\n\n"
   }
}
#*****************************************************************************#



###############################################################################
#
# Descirption : effectue la somme moyenne, mediane et ssk d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date création : 06 aout 2005
# Date de mise à jour : 06 aout 2005
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_somes { args } {

   global audace
   global conf

   if {[llength $args] == 1} {
       set nom_generique [ lindex $args 0 ]
       set nombre [ llength [  glob ${nom_generique}*$conf(extension,defaut) ] ]
       regexp {(.+)\-} $nom_generique match pref_nom

       ::console::affiche_resultat "smean $nom_generique ${pref_nom}_sme$nombre$conf(extension,defaut) $nombre...\n"
       smean "$nom_generique" "${pref_nom}_sme$nombre" $nombre
       ::console::affiche_resultat "smedian $nom_generique ${pref_nom}_smd$nombre$conf(extension,defaut) $nombre...\n"
       smedian "$nom_generique" "${pref_nom}_smd$nombre" $nombre
       ::console::affiche_resultat "ssk $nom_generique ${pref_nom}_ssk$nombre$conf(extension,defaut) $nombre 0,5...\n"
       ssk "$nom_generique" "${pref_nom}_ssk$nombre" $nombre 0.5
   } else {
     ::console::affiche_erreur "Usage: bm_somes nom_generique_fichier (sans extension)\n\n"
   }
}
###############################################################################



###############################################################################
#
# Descirption : calcul la largeur équivalente d'une étoile en secondes d'arc
# Auteur : Benjamin MAUCLAIRE
# Date création : 20 juillet 2005
# Date de mise à jour : 20 juillet 2005
#
###############################################################################

proc bm_fwhm { args } {
# arguments : fwhm de l'étoile en pixels, taille d'un pixel en micons, focale du téléscope en mm

   global audace
   global conf

   if {[llength $args] == 3} {
     set fwhm [ lindex $args 0 ]
     set tpixel [ lindex $args 1 ]
     set focale [ lindex $args 2 ]
		     
     set sfwhm [ expr atan($tpixel*$fwhm*1E-6/($focale/1000))*(180/acos(-1))*3600 ]
     ::console::affiche_resultat "FWHM étoile : $sfwhm secondes d'arc\n"
   } else {
     ::console::affiche_erreur "Usage: bm_fwhm fwhm-etoile taille-pixel(um) distance-focale(mm)\n\n"
   }
}
###############################################################################

