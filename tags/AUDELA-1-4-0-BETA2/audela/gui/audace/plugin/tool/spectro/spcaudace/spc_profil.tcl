####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : nom du fichier du spectre spatial
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
# Chargement en ligne :
# A130 : source $audace(rep_scripts)/spcaudace/spc_profil.tcl
# A140 : source [ file join $audace(rep_plugin) tool spectro spcaudace spc_profil.tcl ]
#
#####################################################################################


# Remarque : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialisées dans le fichier cap_mauclaire.tcl
# et renommer ce fichier mauclaire.tcl ;-)





###############################################################
#                                              
# Extraction du profil a partir du spectre x,y 
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005                                              
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_extract_profil_zone { args } {

    #****************************************************************#
    ## Chargement : source $audace(rep_scripts)/profil_raie.tcl
    ## Les var nommees audace_* sont globales
    global audace caption
    global audela
    ## flag audace
    global conf
    global flag_ok

    if { [ llength $args ]<=1 } {
	if { [ llength $args ]==1 } {
	    set filespacialspc [ file tail [ file rootname [ lindex $args 0 ] ] ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filespacialspc "$spctrouve"
	    } else {
		::console::affiche_erreur "Usage: spc_extract_profil_zone spectre_2D\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_extract_profil_zone spectre_2D\n\n"
	    return 0
	}


	#--- Sélection de la zone à binner :
	loadima "$filespacialspc"
	#-- Algo :
	::console::affiche_resultat "Sélection de la fenetre d'etude.\n"
	## On affiche un message demandant de sélectionner la zone d'étude
	## Lecture des coordonnees de la ligne centrale du spectre
	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)
	set flag_ok 0
	
	#-- Création de la fenêtre :
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace

	#--- Textes d'avertissement
	label .benji.lab -text "Sélectionnez la zone du spectre..."
	pack .benji.lab -expand true -expand true -fill both

	#--- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both

	#--- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "Ok"
	pack .benji.but.1 -side left -expand true -fill both
	#--- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both

	## Attend que la variable $flag_ok change
	vwait flag_ok

	if { $flag_ok == "1" } {
	    set coords_zone $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	    #### Bug ici - Affiche un profil quand on appuie sur le bouton Annuler de la boite "Get zone"
	}

	#::console::affiche_resultat "$flag_ok\n"
	## coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
	## set coords { 1 50 599 24 }

	## On initialise :
	## ysup=ordonnée max. de la boîte sélectionnée
	## yinf=aordonnée min. de la boîte sélectionnée
	## ht_spectre="hauteur" en pixels du spectre
	## ht_dessus=hauteur d'image au dessus du spectre
	## ht_dessous=hauteur d'image au dessous du spectre
	## xmax_zone=abscisse max. de la zonne sélectionnée
	## xmin_zone=abscisse min. de la zonne sélectionnée
	## naxis2=hauteur de l'image.
	if {[lindex $coords_zone 1]<[lindex $coords_zone 3]} {
	    set ysup [lindex $coords_zone 3]
	    set yinf [lindex $coords_zone 1]
	} else {
	    set yinf [lindex $coords_zone 3]
	    set ysup [lindex $coords_zone 1]
	}
	set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
	set ht_spectre [expr $ysup-$yinf]
	set ht_dessus [expr $naxis2-$ysup]
	set ht_dessous [expr $yinf]
	set xsup_zone [lindex $coords_zone 0]
	set xinf_zone [lindex $coords_zone 2]

	## creation d'un fichier contenant la zone selectionnee
	# buf$audace(bufNo) window $coords_zone
	if { [info exists audace(box)] == 1 } {
	    buf$audace(bufNo) window $coords_zone
	    #--- Suppression de la zone selectionnee avec la souris
	    catch {
		unset audace(box)
		$audace(hCanvas) delete $audace(hBox)
	    }
	} else {
	    ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
	}
	
	# ::console::affiche_resultat "$coords_zone ; ${filespacialspc}_zone\n"
	# ::audace::conserve_seuils
	buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_zone"
	
	##--------------- Traitement de la zone selectionnee -------------------#
	set listcoords [ list $ht_spectre $yinf $ysup $xinf_zone $xsup_zone $ht_dessous $ht_dessus ]
	set listeargs [ list "${filespacialspc}_zone" "$filespacialspc" $listcoords ]
	set fileout [ spc_bin "${filespacialspc}_zone" "$filespacialspc" $listcoords ]

	#--- Traitement des résultats :
	::console::affiche_resultat "Profil de raies de la zone sélectionnéé sauvé sous $fileout\n"
	return $fileout
    } else {
	::console::affiche_erreur "Usage: spc_extract_profil_zone spectre_2D\n\n"
    }
}
###############################################################


###############################################################
# Extrait une zone d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006                               
# Arguments : fichier fits du spectre spatial
###############################################################
proc spc_extract_zone { args } {

    global audace caption
    global conf
    global flag_ok

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filespacialspc [ file rootname [lindex $args 0] ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filespacialspc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_extract_zone spectre_2D_fits\n\n"
	       return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_extract_zone spectre_2D_fits\n\n"
	    return 0
	}

	#--- Traitement :
	# Retire l'extension .fit du nom du fichier
	# regsub -all .fit $filespacialspc - filespatialspc
	## Verif existence
	#if {[file exist [file join $audace(rep_images)/$filespacialspc.$conf(extension,defaut)]]==1} 
	# buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	loadima "$filespacialspc"
	::console::affiche_resultat "Sélection de la fenetre d'etude.\n"

	## On affiche un message demandant de sélectionner la zone d'étude
	## Lecture des coordonnees de la ligne centrale du spectre
	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)
	set flag_ok 0
	# Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace

	#--- Textes d'avertissement
	label .benji.lab -text "Sélectionnez la zone du spectre..."
	pack .benji.lab -expand true -expand true -fill both

	#--- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both

	#--- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "Ok"
	pack .benji.but.1 -side left -expand true -fill both
	#--- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both

	## Attend que la variable $flag_ok change
	vwait flag_ok

	if { $flag_ok == "1" } {
	    set coords_zone $audace(box)
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	    #### Bug ici - Affiche un profil quand on appuie sur le bouton Annuler de la boite "Get zone"
	}

	#::console::affiche_resultat "$flag_ok\n"
	## coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
	## set coords { 1 50 599 24 }

	## Création d'un fichier contenant la zone selectionnee
	if { [info exists audace(box)] == 1 } {
	    buf$audace(bufNo) window $coords_zone
	    #--- Suppression de la zone selectionnee avec la souris
	    catch {
		unset audace(box)
		$audace(hCanvas) delete $audace(hBox)
	    }
	} else {
	    ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
	}
	buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_zone"
	return "${filespacialspc}_zone"
    } else {
	::console::affiche_erreur "Usage: spc_extract_zone spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Soustrait le fond de ciel avec BACK et crée le profil de raie d'une zone d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006                               
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_profil_zone { args } {

    global audace caption
    global conf

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filespacialspc [ file rootname [lindex $args 0] ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filespacialspc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
	       return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
	    return 0
	}

	#--- Détermination de la zone du spectre :
	set results [ spc_detect $filespacialspc ]
	set ycenter [ lindex $results 0 ]
	set hauteur [ lindex $results 1 ]

	#--- Soustrait le fond de ciel
	set sp_propre [ spc_subsky $filespacialspc $ycenter $hauteur med ]
	#--- Sélectionne la zone à étudier
	set sp_zone [ spc_extract_zone $sp_propre ]
	file delete -force "$audace(rep_images)/$sp_propre$conf(extension,defaut)"
	#--- Crée le profil de raies
	buf$audace(bufNo) load "$audace(rep_images)/$sp_zone"
	set ht_spectre [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	set listeargs [ list "$sp_zone" $ht_spectre ]
	#set fileout [ spc_bins $listeargs ]
	set fileout [ spc_bins "$sp_zone" ]

	#--- Traitement des résultats :
	::console::affiche_resultat "Profil de raies sauvé sous $fileout\n"
	return $fileout
    } else {
	::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 27-08-2005
# Date de mise a jour : 27-08-2005                               
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_detect { args } {

    global audace
    global conf

    if { [ llength $args ] == 1 } {
	set filenamespc_spacial [ lindex $args 0 ]

	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spacial"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	set windowcoords [ list 1 1 1 $naxis2 ]
	
	#buf$audace(bufNo) binx 1 $naxis1 3
	#set ycentre [lindex [ buf$audace(bufNo) centro $windowcoords ] 1]
	buf$audace(bufNo) binx 1 $naxis1 1
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	# Choix : la largeur de la gaussienne est de 3*FWHM
	set largeur [ expr 3*[ lindex $gparams 6 ] ]
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detect spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Détermine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 23-06-2006
# Date de mise a jour : 23-06-2006                               
# Arguments : fichier fits du spectre 2D
###############################################################

proc spc_detectasym { args } {

    global audace
    global conf

    if { [ llength $args ] == 1 } {
	set fichier [ file rootname [lindex $args 0 ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]

	#--- Creations de profils de plusieurs colonnes
	set xpas [ expr int($naxis1/5) ]
	#-- n° du profil resultant
	::console::affiche_resultat "Pas entre chaque point de détection : $xpas\n"
	set i 1
	for {set k $xpas} {$k <= $naxis1} {incr k} {
	    set fsortie [ file rootname [ spc_profilx $fichier $k ] ]
	    # ::console::affiche_resultat "$fsortie\n"
	    file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/profil-$i$conf(extension,defaut)"
	    set k [ expr $k+$xpas-1 ]
	    incr i
	}
	set nbimg [ expr $naxis1/$xpas ]
	sadd profil- ${fichier}_spcx $nbimg
	delete2 profil- $nbimg

	#--- Détermination des paramètres du de l'épaisseur du spectre sur la coupe verticale
	buf$audace(bufNo) load "$audace(rep_images)/${fichier}_spcx"
	#set windowcoords [ list 1 1 $naxis2 1 ]
        set y1 [ expr int(.03*$naxis2) ]
        set y2 [ expr int(.97*$naxis2) ]
	set windowcoords [ list 1 $y1 1 $y2 ]
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 5 ]
	#-- Choix : la largeur de la gaussienne est de 1.9*FWHM
	set largeur [ expr 1.9*[ lindex $gparams 6 ] ]
	file delete "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detectasym spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# Soustrait le fond de ciel à un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006                               
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_subskyfrac { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filespacialspc [ file rootname [lindex $args 0] ]
	buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	buf$audace(bufNo) imaseries "BACK back_kernek=15 back_threshold=0.2 sub"
	# buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_fc"
	buf$audace(bufNo) bitpix short
	return ${filespacialspc}_fc
    } else {
	::console::affiche_erreur "Usage: spc_subskyfrac spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Soustrait le fond de ciel sur une série de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 06-03-2006
# Date de mise a jour : 06-03-2006                               
# Arguments : nom gégérique des fichiers fits du spectre spatial
###############################################################

proc spc_subskiesfrac { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set nom_generique [lindex $args 0]
	set liste_fichiers [ lsort -dictionary [glob ${nom_generique}\[0-9\]*$conf(extension,defaut)] ]
	set nbimg [ llength $liste_fichiers ]
	::console::affiche_resultat "$nbimg fichiers à traiter.\n"
	set i 1

	foreach fichier $liste_fichiers {
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    buf$audace(bufNo) imaseries "BACK back_kernek=15 back_threshold=0.2 sub"
	    buf$audace(bufNo) save "$audace(rep_images)/${nom_generique}fc-$i"
	    incr i
	}
	return ${nom_generique}fc-
    } else {
	::console::affiche_erreur "Usage: spc_subskies nom générique spectres_2D_fits\n\n"
    }
}
#*********************************************************************#



###############################################################
# Soustrait le fond de ciel sur une série de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-07-2006
# Date de mise a jour : 26-07-2006                               
# Arguments : nom du spectre 2D netoye du fond de ciel à binner
###############################################################

proc spc_binlopt { args } {

    global audace
    global conf

    if { [llength $args] == 3 } {
	set spectre2d [ lindex $args 0 ]
	set ycentre [ expr int([ lindex $args 1 ]) ]
	set ylargeur [ lindex $args 2 ]

	#--- Détermine les limites adaptées du binning :
	set dy [ expr int($ylargeur*.5-1)+1 ]
	set yinf [ expr $ycentre-int($dy) ]
	set ysup [ expr $ycentre+int($dy) ]
	set htr [ expr $dy*2 ]
	if { $dy != 0.5 } {
	    ::console::affiche_resultat "Hauteur de binning : $htr\n"
	}

	#--- Effectue le binning optimise par la mathode de Roberval (lopt de tt_user2.c)
	buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
	buf$audace(bufNo) imaseries "LOPT y1=$yinf y2=$ysup height=1"

	#--- SAuvegarde du profil 1D
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${spectre2d}_spc"
	buf$audace(bufNo) bitpix short
	::console::affiche_resultat "Profil de raies sauvé sous ${spectre2d}_spc$conf(extension,defaut)\n"
	return ${spectre2d}_spc
    } else {
	::console::affiche_erreur "Usage: spc_binlopt nom_spectres_2D_fits ycentre ylargeur_a_binner\n\n"
    }
}
#*********************************************************************#



###############################################################
# Extraction du profil a partir du spectre 2D en mode texte et autosélection de zone 
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-02-2006
# Date de modification : 05-07-2006
# Arguments : fichier fits du spectre spatial ?méthode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)? ?méthode de détection du spectre (large, serre)? ?méthode de bining (add)?
###############################################################

proc spc_profil { args } {

    global audace
    global audela
    global conf

    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc
    if { [llength $args] <= 4 && [llength $args] != 0 } {
	if { [llength $args] == 1 } {
	    #--- Gestion avec options par défaut :
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc "moy"
	    set methodedetect "serre"
	    set methodebin "add"
	} elseif { [llength $args] == 2 } {
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc [ lindex $args 1 ]
	    set methodedetect "serre"
	    set methodebin "add"
	} elseif { [llength $args] == 3 } {
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc [ lindex $args 1 ]
	    set methodedetect [ lindex $args 2 ]
	    set methodebin "add"
	} elseif { [llength $args] == 4} {
	    set spectre2d [ file rootname [lindex $args 0] ]
	    set methodefc [ lindex $args 1 ]
	    set methodedetect [ lindex $args 2 ]
	    set methodebin [ lindex $args 3 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profil spectre_2D_fits ?méthode soustraction fond de ciel (moy, moy2, med, sup, none, frac)? ?méthode de détection du spectre (large, serre)? ?méthode de bining (add, rober, horne)?\n\n"
	}

	#--- Chargement du spectre :
	if { [file exists "$audace(rep_images)/$spectre2d$conf(extension,defaut)" ] == 1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
	} else {
	    ::console::affiche_resultat "Le fichier $spectre2d n'existe pas.\n"
	    return 0
	}

	#--- Détection de la zone où se trouve le spectre :
	if { $methodedetect == "large" } {
	    set gauss_params [ spc_detect $spectre2d ]
	} elseif { $methodedetect == "serre" } {
	    set gauss_params [ spc_detectasym $spectre2d ]
	} else {
	    set gauss_params [ spc_detect $spectre2d ]
	}

	#--- Découpage de la zone à binner et retrait du fond de ciel :
	set ycenter [ lindex $gauss_params 0 ] 
	set hauteur [ lindex $gauss_params 1 ]
	#-- Algo : set coords_zone [list 1 [expr int($ycenter-0.5*$largeur)] $naxis1 [expr int($ycenter+0.5*$largeur)]]
	set spectre_zone_fc [ spc_subsky $spectre2d $ycenter $hauteur $methodefc ]

	#--- Bining :
	if { $methodebin == "add" } {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	    file delete "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	} elseif { $methodebin == "rober" } {
	    #-- Cas particulier de zone de binning : elle est decoupée et c'est $spectre_zone_fc
	    #-- au lieu de faire : [ spc_binlopt $spectre_zone_fc $ycenter $hauteur ]
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre_zone_fc"
	    set ylargeur [ expr [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]-1 ]
	    #-- Bizarement, lopt ne peut prendre la dimension totale d'une image :
	    buf$audace(bufNo) imaseries "LOPT y1=3 y2=$ylargeur height=1"
	    buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	    buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
	    buf$audace(bufNo) bitpix float
	    if { [regexp {1.3.0} $audela(version) match resu ] } {
		buf$audace(bufNo) save "$audace(rep_images)/${spectre_zone_fc}_spc"
	    } else {
		buf$audace(bufNo) save1d "$audace(rep_images)/${spectre_zone_fc}_spc"
	    }
	    buf$audace(bufNo) bitpix short
	    set profil_fc ${spectre_zone_fc}_spc
	    file delete "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	} else {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	    file delete "$audace(rep_images)/$spectre_zone_fc$conf(extension,defaut)"
	}

	#--- Message de fin et nettoyage :
	::console::affiche_resultat "Profil de raies sauvé sous $profil_fc\n"
	file delete "$audace(rep_images)/${spectre2d}_zone$conf(extension,defaut)"
	return $profil_fc
   } else {
	::console::affiche_erreur "Usage: spc_profil spectre_2D_fits ?méthode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)? ?méthode de détection du spectre (large, serre)? ?méthode de bining (add, rober, horne)?\n\n"
   }
}
#**************************************************************************#



###############################################################
# Procédure : soustrait le fond de ciel à la zone du spectre détectée
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 05-07-2006
# Date de modification : 05-07-2006
# Arguments : spectre_2D_fits y_centre_spectre hauteur_spectre méthode_soustraction_fond_de_ciel (moy, moy2, med, inf, sup, none, back)
###############################################################

proc spc_subsky { args } {

    global audace
    global conf

    if { [ llength $args ] == 4 } {
	set spectre [ lindex $args 0 ]
	set ycenter [ lindex $args 1 ]
	set hauteur [ lindex $args 2 ]
	set methodemoy [ lindex $args 3 ]

	::console::affiche_resultat "ycenter : $ycenter ; hauteur : $hauteur\n"
	#--- Initialisation de paramètres
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]

	#--- Passe en entier ycenter et hauteur pour le decoupage de zones de meme taille :
	## [ expr $ycenter+0.5*$hauteur-(int($ycenter+0.5*$hauteur)+1) ] >= 0.5 
	#if { [ expr $ycenter-int($ycenter) ] > 0.5 } {
	#    set ycenter [ expr int($ycenter)+1 ]
	#} else {
	#    set ycenter [ expr int($ycenter) ]
	#}
	#if { [ expr $hauteur-int($hauteur) ] > 0.5 } {
	#    set hauteur [ expr int($hauteur)+1 ]
	#} else {
	#    set hauteur [ expr int($hauteur) ]
	#}
	set ycenter [ expr round($ycenter) ]
	set hauteur [ expr round($hauteur) ]

	#--- Découpage de zone où se trouve le spectre :
	#--  -----------B
	#--  |          |
	#--  A-----------
	set coords_zone_spectre [ list 1 [expr round($ycenter-0.5*$hauteur)] $naxis1 [expr round($ycenter+0.5*$hauteur)] ]
	::console::affiche_resultat "Zone du spectre : $coords_zone_spectre\n"
	#--- Découpage de la zone où se trouve le spectre
	buf$audace(bufNo) window $coords_zone_spectre
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone"
	set hauteurzone [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]


	#--- Découpage de la zone supérieure pour le fond de ciel :
	set coords_zone_sup [ list 1 [expr round($ycenter+1.5*$hauteur)] $naxis1 [expr round($ycenter+2.5*$hauteur)] ]
	::console::affiche_resultat "Zone supérieure : $coords_zone_sup\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_sup
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesup"

	#--- Découpage de la zone inférieure pour le fond de ciel :
	set coords_zone_inf [ list 1 [expr round($ycenter-1.5*$hauteur)] $naxis1 [expr round($ycenter-2.5*$hauteur)] ]
	::console::affiche_resultat "Zone inférieure : $coords_zone_inf\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_inf
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zoneinf"

	#--- Calcul de la moyenne du fond de ciel et la soustrait :
	if { $methodemoy == "moy" } {

	    #--- Somme moyenne des zones sup et inf :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 zones.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zoneinf" 0
	    buf$audace(bufNo) mult -0.5
	    uncosmic 0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "med" } {

	    #--- Somme médiane des colonne pour chaque zone puis moyenne :
	    ::console::affiche_resultat "Soustraction du fond de ciel : médiane des colonnes de chaque zone.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteurzone"
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesupmed"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteurzone"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zonesupmed" 0
	    buf$audace(bufNo) mult -0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	    file delete "$audace(rep_images)/${spectre}_zonesupmed$conf(extension,defaut)"
	} elseif { $methodemoy == "moy2" } {

	    #--- Moyenne de la valeur des fonds de ciel tirés des 2 zones :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 fonds.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moysup [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moyinf [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    set moy [ expr -0.5*($moysup+$moyinf) ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    #buf$audace(bufNo) clear
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "back" } {

	    #--- Méthode du BACK :
	    ::console::affiche_resultat "Soustraction du fond de ciel : méthode fraction.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	    buf$audace(bufNo) imaseries "BACK back_kernek=30 back_threshold=0.2 sub"
	    buf$audace(bufNo) window $coords_zone_spectre
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "sup" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessus le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "inf" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessous le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "none" } {

	    #--- Aucune soustraction du fond de ciel
	    ::console::affiche_resultat "Aucune soustraction du fond de ciel.\n"
	    file copy "$audace(rep_images)/${spectre}_zone$conf(extension,defaut)" "$audace(rep_images)/${spectre}_zone_fc$conf(extension,defaut)"
	} else {
	    ::console::affiche_resultat "Mauvaise option de calcul du fond de ciel.\n"
	}

	#--- Sauvegarde et netoyages :
	::console::affiche_resultat "Spectre 2D nettoyé du fond de ciel sauvé sous ${spectre}_zone_fc.\n"
	# file delete $audace(rep_images)/${spectre}_zone$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zonesup$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zoneinf$conf(extension,defaut)
	return ${spectre}_zone_fc
    } else {
	::console::affiche_erreur "Usage: spc_subsky spectre_2D_fits y_centre_spectre hauteur_spectre méthode_soustraction_fond_de_ciel (moy, moy2, med, sup, inf, none, back)\n\n"
    }
}
#***************************************************************************#



###############################################################
# Effectue le binning de la zone selectionnee sur le spectre et soustrait le fond du ciel.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour n-2 : 31-01-2005
# Date de mise a jour n-1 : 29-11-2005 (buf1 load en loadima)
# Date de mise a jour : 27-12-05 (buf1 load rep/img
# Date MAJ : 07-01-24 (saisie des arguments avec la variable args)
# Arguments : 
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_bin { args } {

    global audace
    global audela
    global conf
    set extsp ".dat"

    ::console::affiche_resultat "[ llength $args ] ; $args\n"

    if { [ llength $args ]==3 } {
	set filenamespc_zone_rep [ lindex $args 0 ]
	set filenamespc_spatial_rep [ lindex $args 1 ]
	set listcoords [ lindex $args 2 ]

	#--- Initialisation des variables :
	set ht_spectre [lindex $listcoords 0]
	set yinf [lindex $listcoords 1]
	set ysup [lindex $listcoords 2]
	set xinf_zone [lindex $listcoords 3]
	set xsup_zone [lindex $listcoords 4]
	set ht_dessous [lindex $listcoords 5]
	set ht_dessus [lindex $listcoords 6]
	set filenamespc_zone [file tail $filenamespc_zone_rep]
	set filenamespc_spatial [file tail $filenamespc_spatial_rep]
	
	## On binne sur les colonnes dans la region de l'image correspondant au spectre et on sauvegarde le résultat dans ${filespacialspc}_sp :
	::console::affiche_resultat "Binning des colonnes de la région sélectionnée...\n"
	## Exemple de binning sur la totatlite de la totalite de la hauteur de l'image initiale
	## 
	##set ysup2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
	##buf$audace(bufNo) biny 1 $ysup2
	
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
	#buf$audace(bufNo) biny 1 [expr $ysup-$yinf]
	buf$audace(bufNo) biny 1 $ht_spectre 1
	## Pondération par la hauteur en pixels
	#buf$audace(bufNo) mult [expr 1.0/$ht_spectre]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_sp"
	}
	buf$audace(bufNo) bitpix short
	
	## ******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ****** ##
	##---- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#
	
	## Creation d'une image de largeur limiteée par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous
	set coords_zonev [list $xsup_zone [expr int($ysup+$ht_dessus)] [expr int($xinf_zone)] [expr int($yinf-$ht_dessous)+1]]
	## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
	#::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
	buf$audace(bufNo) window $coords_zonev
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
	buf$audace(bufNo) bitpix short

	## On binne sur les colonnes dans la région de l'image au dessus du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spsup	        
	buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"	
	buf$audace(bufNo) biny $ysup [expr $ysup+$ht_dessus-1] 1
	## Pondération par la hauteur en pixels
	buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spsup"
	}
	buf$audace(bufNo) bitpix short	
	
	
	## On binne sur les colonnes dans la région de l'image au dessous du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spinf
	::console::affiche_resultat "Binning des colonnes.\n"
	buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"
	buf$audace(bufNo) biny $yinf [expr $yinf-$ht_dessous+1] 1
	## Pondération par la hauteur en pixels
	buf$audace(bufNo) mult [expr 1.0/$ht_dessous]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spinf"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spinf"
	}
	buf$audace(bufNo) bitpix short
	
	## Calcul une moyenne du fond du ciel prit dessus et dessous le spectre.
	::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
	buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
	##~~~~~ BUG ICI : 25/04/2006 NON, PAS DE BUG
	buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0
	
	## Petites feintes : on multiplie l'image précédente par -0.5 pour avoir une moyenne, le chiffre négatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant à cette image : le spectre !
	buf$audace(bufNo) mult -0.5
	buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
	## Initialisation des mots-clef spectroscopie
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
	
	## On sauvegarde le spectre avec correction du fond du ciel
	::console::affiche_resultat "Profil de raies sauvé sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spc"
	}
	buf$audace(bufNo) bitpix short

	#--- Export au format dat :
	# ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_spatial${extsp}\n"
	# buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spc"
	# buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}_spc$extsp direction=x offset=1"
	
	#buf1 imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}.$extsp direction=x offset=1"
	
	##------- Effacement des fichiers temporaires ----------##
	## ${filenamespc_spatial}_zone ${filenamespc_spatial}_sp ${filenamespc_spatial}_spsup ${filenamespc_spatial}_spinf ${filenamespc_spatial}_profil 
	# catch {file delete -force "${filenamespc_spatial}_zone ${filenamespc_spatial}_sp ${filenamespc_spatial}_spsup ${filenamespc_spatial}_spinf ${filenamespc_spatial}_profil"}
	#--- Suppression des fichiers intermediaires
	## $conf(extension_default)
	::console::affiche_resultat "Effacement des fichiers temporaires...\n"
	file delete "$audace(rep_images)/${filenamespc_spatial}_sp$conf(extension,defaut)"
	file delete "$audace(rep_images)/${filenamespc_spatial}_spinf$conf(extension,defaut)"
	file delete "$audace(rep_images)/${filenamespc_spatial}_spsup$conf(extension,defaut)"
	file delete "$audace(rep_images)/${filenamespc_spatial}_zone$conf(extension,defaut)"
	file delete "$audace(rep_images)/${filenamespc_spatial}_zonev$conf(extension,defaut)"
	return ${filenamespc_spatial}_spc
    } else {
	::console::affiche_erreur "Usage: spc_bin spectre_2D_zone spectre_2D_entier liste_coordonnées_zone\n\n"
    }
}
###############################################################



###############################################################                
# Effectue le binning de la zone selectionnee sur le spectre SANS soustraire le fond du ciel.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-02-2006
# Date de mise a jour n-2 : 31-01-2005
# Arguments : 
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_bins { args } {

  global audace
  global audela
  global conf
  set extsp ".dat"

  if { [llength $args] == 1 } {
      set filenamespc_zone [ lindex $args 0 ]

      #--- Binning
      ::console::affiche_resultat "Binning des colonnes de la région sélectionnée...\n"
      buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
      set ht_spectre [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
      buf$audace(bufNo) biny 1 $ht_spectre 1
      buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
      buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
      buf$audace(bufNo) bitpix float
      if { [regexp {1.3.0} $audela(version) match resu ] } {
	  buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_zone}_spc"	
      } else {
	  buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_zone}_spc"
      }
      buf$audace(bufNo) bitpix short

      ::console::affiche_resultat "\nProfil de raies sauvé sous ${filenamespc_zone}_spc$conf(extension,defaut)\n"

      #--- Export au format dat
      # ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_zone${extsp}\n"
      # spc_fits2dat ${filenamespc_zone}_spc
      #buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_zone}_spc"
      # buf$audace(bufNo) imaseries "PROFILE filename=${filenamespc_zone}_spc$extsp direction=x offset=1"
      # buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_zone}_spc$extsp direction=x offset=1"

      #--- Efface les fichiers temporaires :
      file delete "$audace(rep_images)/$filenamespc_zone$conf(extension,defaut)"
      buf$audace(bufNo) bitpix short
      return ${filenamespc_zone}_spc
   } else {
	::console::affiche_erreur "Usage: spc_bins spectre_2D_zone\n\n"
   }
}
###############################################################



###############################################################                
# Effectue le binning de la zone selectionnee sur le spectre et soustrait le fond du ciel de la partie supérieure.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour n-2 : 31-01-2005
# Date de mise a jour n-1 : 29-11-2005 (buf1 load en loadima)
# Date de mise a jour : 27-12-05 (buf1 load rep/img)
# Date de mise a jour : 26-02-06 (soustrait que la partie supérieure du fond de ciel)
# Arguments : 
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_binsup { {filenamespc_zone_rep ""} {filenamespc_spatial_rep ""} {listcoords ""} } {

    global audace
    global audela
    global conf
    set extsp ".dat"

    set ht_spectre [lindex $listcoords 0]
    set yinf [lindex $listcoords 1]
    set ysup [lindex $listcoords 2]
    set xinf_zone [lindex $listcoords 3]
    set xsup_zone [lindex $listcoords 4]
    set ht_dessous [lindex $listcoords 5]
    set ht_dessus [lindex $listcoords 6]
    set filenamespc_zone [file tail $filenamespc_zone_rep]
    set filenamespc_spatial [file tail $filenamespc_spatial_rep]

    ## On binne sur les colonnes dans la region de l'image correspondant au spectre et on sauvegarde le résultat dans ${filespacialspc}_sp :
    ::console::affiche_resultat "Binning des colonnes de la région sélectionnée...\n"
    ## Exemple de binning sur la totatlite de la totalite de la hauteur de l'image initiale
    ## 
    ##set ysup2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
    ##buf$audace(bufNo) biny 1 $ysup2

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
    #buf$audace(bufNo) biny 1 [expr $ysup-$yinf]
    buf$audace(bufNo) biny 1 $ht_spectre 1
    ## Pondération par la hauteur en pixels
    #buf$audace(bufNo) mult [expr 1.0/$ht_spectre]
    buf$audace(bufNo) bitpix float
    if { [regexp {1.3.0} $audela(version) match resu ] } {
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"	
    } else {
	buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_sp"
    }
    buf$audace(bufNo) bitpix short


    ## ******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ****** ##
    ##-- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#

    ## Creation d'une image de largeur limiteée par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous
    set coords_zonev [list $xsup_zone [expr int($ysup+$ht_dessus)] [expr int($xinf_zone)] [expr int($yinf-$ht_dessous)+1]]
    ## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
    #::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
    buf$audace(bufNo) window $coords_zonev
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
    buf$audace(bufNo) bitpix short

    ## On binne sur les colonnes dans la région de l'image au dessus du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spsup	        
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"	
    buf$audace(bufNo) biny $ysup [expr $ysup+$ht_dessus-1] 1
    ## Pondération par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
    buf$audace(bufNo) bitpix float
    if { [regexp {1.3.0} $audela(version) match resu ] } {
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"
    } else {
	buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spsup"	
    }
    buf$audace(bufNo) bitpix short


    ## Calcul une moyenne du fond du ciel prit dessus et dessous le spectre.
    ::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
    ##~~~~~ BUG ICI
    # buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0
    
    ## Petites feintes : on multiplie l'image précédente par -0.5 pour avoir une moyenne, le chiffre négatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant à cette image : le spectre !
    buf$audace(bufNo) mult -1
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
    ## Initialisation des mots-clef spectroscopie
    buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
    buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
    #buf$audace(bufNo) setkwd [list "CRPIX1" "1" int "" ""]
    #buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
    buf$audace(bufNo) bitpix float

    ## On sauvegarde le spectre avec correction du fond du ciel
    ::console::affiche_resultat "Profil de raies sauvé sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
    if { [regexp {1.3.0} $audela(version) match resu ] } {
	buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"
    } else {
	buf$audace(bufNo) save1d "$audace(rep_images)/${filenamespc_spatial}_spc"
    }
    buf$audace(bufNo) bitpix short

    ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_spatial${extsp}\n"
    #loadima ${filenamespc_spatial}_spc
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spc"
    buf$audace(bufNo) imaseries "PROFILE filename=${filenamespc_spatial}_spc$extsp direction=x offset=1"
    #buf1 imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}.$extsp direction=x offset=1"

    ##------- Effacement des fichiers temporaires ----------##
    ::console::affiche_resultat "Effacement des fichiers temporaires...\n"

    file delete $audace(rep_images)/${filenamespc_spatial}_sp$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_spsup$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_zone$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_zonev$conf(extension,defaut)

    buf$audace(bufNo) bitpix short
    return ${filenamespc_spatial}_spc
}
###############################################################




###############################################################
#                                              
# Profil d'intensité d'une ligne de pixels d'ordonnée y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 13-05-2006
# Date de mise a jour : 13-05-2006                       
# Arguments : fichier fits du spectre spatial, ordonnée y de la ligne, ?hauteur à binner?
###############################################################

proc spc_profily { args } {
    global audace
    global audela
    global conf

    if { [llength $args] <= 3 } {
	if { [llength $args] == 2 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set y [ expr int([ lindex $args 1 ]) ]
	    set dy 0.5
	} elseif { [llength $args] == 3 } {
	    set fichier [ file rootname [ lindex $args 0 ] ]
	    set y [ expr int([ lindex $args 1 ]) ]
	    set hauteur [ expr int([ lindex $args 2 ]) ]
	    set dy [ expr int($hauteur*.5-1)+1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profily image_fits ordonnée_y_de_la_ligne ?hauteur à binner?\n\n"
	    return 0
    	}

	#--- Découpage de la ligne
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	#set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	## coords contient : { x1 y1 x2 y2 }
	##  -----------B
	##  |          |
	##  A-----------
	set coords_zone [ list 1 [ expr $y-int($dy) ] $naxis1 [ expr $y+int($dy) ] ]
	buf$audace(bufNo) window $coords_zone
	#--- Binning
	set htr [ expr $dy*2 ]
	if { $dy != 0.5 } {
	    ::console::affiche_resultat "Hauteur de binning : $htr\n"
	    buf$audace(bufNo) biny 1 $htr 1
	}

	#--- Sauvegarde du profil
	buf$audace(bufNo) setkwd [ list NAXIS 1 int "" "" ]
	buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
	buf$audace(bufNo) bitpix float
	if { [regexp {1.3.0} $audela(version) match resu ] } {
	    buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcy"
	} else {
	    buf$audace(bufNo) save1d "$audace(rep_images)/${fichier}_spcy"
	}
	buf$audace(bufNo) bitpix short

	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcy$conf(extension,defaut)\n"
	return ${fichier}_spcy
    } else {
	::console::affiche_erreur "Usage: spc_profily image_fits ordonnée_y_de_la_ligne ?hauteur à binner?\n\n"
    }
}
###############################################################


###############################################################
#                                              
# Profil d'intensité d'une colonne de pixels d'abscisse x
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 07-06-2006
# Date de mise a jour : 07-06-2006                       
# Arguments : fichier fits du spectre spatial, abscisse x de la colonne, ?largeur à binner?
###############################################################

proc spc_profilx { args } {
    global audace
    global conf
    set extsp ".dat"
    set nomprofil "profil_spcx"

    if { [llength $args] == 2 } {
	set fichier [ file rootname [ lindex $args 0 ] ]
	set x [ lindex $args 1 ]

	#--- Binning
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	#- Les commandes PROFILE et PROFILE2 n'accèptent pas les noms de fichier compliqués
	#buf$audace(bufNo) imaseries "PROFILE2 filename=$audace(rep_images)/$nomprofil$extsp direction=y offset=$x"
	buf$audace(bufNo) imaseries "BINX x1=$x x2=$x width=1"
	#--- Sauvegarde du profil
	#-- Enlève la première ligne du fichier dat (label des colonnes)
	#- J'ai modifié tt_user3 ligne 350 de la libtt.
	#set fsortie [ file rootname [ spc_dat2fits $nomprofil$extsp ] ]
	#file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	#file delete "$audace(rep_images)/$nomprofil$extsp"
	buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcx"
	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne\n\n"
    }
}
###############################################################




###############################################################
#                                              
# Extraction du profil a partir du spectre 2D 
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005                                      
# Arguments : fichier fits du spectre spatial
###############################################################

proc extract_profil_col { {filenamespc_spacial ""} } {
    ::console::affiche_resultat "Rien.\n"
}
###############################################################




##########################################################
#  Procedure du trace du profil de raie  
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 16-02-2005
# Date de mise à jour : 16-02-2005 / 17-12-2005
# Arguments : fichier .fit du profil de raie                                  
##########################################################

proc spc_loadfit_051217 { {filenamespc ""} } {

   global profilspc
   global captionspc
   global colorspc
   global audace
   global conf
    set rep_et_filename ""

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile *.fit

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      #--- Mémorise le répertoire et nom du fichier accolés dans la variable filenamespc
      ## set filenamespc [tk_getOpenFile -title $captionspc(loadspc) -filetypes [list [list "$captionspc(spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      # set filenamespc [tk_getOpenFile -title $captionspc(loadspcfit) -filetypes [list [list "$captionspc(spc_profile)" {$conf(extension,defaut)}]] -initialdir $idir -initialfile $ifile ]
      set rep_et_filename [tk_getOpenFile -title $captionspc(loadspcfit) -filetypes [list [list "$captionspc(spc_profile)" {.fit}]] -initialdir $idir -initialfile $ifile ]

      if {[string compare $rep_et_filename ""] == 0 } {
	  return 0
      }
   } else {
       #set repertoire [pwd]
       set repertoire $audace(rep_images)
       set rep_et_filename "$repertoire/$filenamespc"
   }
   #::console::affiche_resultat "$rep_et_filename\n"

   # $spectre = liste contenant : la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
   set spectre [openspc $rep_et_filename]

   #-- Ouverture meth 2 : Ajouté le 16/12/2005
   #set filename [ file tail $filenamespc ]
   #set spectre [openspc $filename]
   #--
   set profilspc(naxis2) [lindex $spectre 1]
   set profilspc(intensite) [lindex $spectre 0]
   set profilspc(pixels) ""
   set profilspc(object) "$filenamespc"

     buf$audace(bufNo) load "$rep_et_filename"
     set listemotsclef [ buf$audace(bufNo) getkwds ]
     if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
	 set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	 set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
     }
     if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	 set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
     }
     if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	 set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
     }
     if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
	 set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
     }

   if { [llength $spectre] == 2 } {
       # Spectre non calibré
       for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
	   append profilspc(pixels) "$k "
       }
   } else {
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   for {set k 0} {$k<$profilspc(naxis2)} {incr k} {
	       set pixel [expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
	       append profilspc(pixels) "$pixel "
	   }
	   #-- Calibration linéaire :
       } else {
	   # Spectre calibré linéairement
	   set xdepart [lindex $spectre 2]
	   set xincr [lindex $spectre 3]
	   for {set k 0} {$k < $profilspc(naxis2)} {incr k} {
	       set pixel [expr $xdepart+$k*$xincr]
	       append profilspc(pixels) "$pixel "
	   }
       }
   }

   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl 
   pvisu2 $spectre
}



##########################################################
#  Procedure du trace du profil de raie  
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 16-02-2005
# Date de mise à jour : 16-02-2005 / 17-12-2005
# Arguments : fichier .fit du profil de raie                                  
##########################################################

proc spc_loadfit { {filenamespc ""} } {

   global profilspc
   global captionspc
   global colorspc
   global audace
   global conf
   #global confVersion
   global audela
   set rep_et_filename ""

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile *.fit

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      #--- Mémorise le répertoire et nom du fichier accolés dans la variable filenamespc
      ## set filenamespc [tk_getOpenFile -title $captionspc(loadspc) -filetypes [list [list "$captionspc(spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      # set filenamespc [tk_getOpenFile -title $captionspc(loadspcfit) -filetypes [list [list "$captionspc(spc_profile)" {$conf(extension,defaut)}]] -initialdir $idir -initialfile $ifile ]
      set rep_et_filename [tk_getOpenFile -title $captionspc(loadspcfit) -filetypes [list [list "$captionspc(spc_profile)" {.fit}]] -initialdir $idir -initialfile $ifile ]

      set filenamespc [ file rootname [ file tail $rep_et_filename ] ]
      if {[string compare $rep_et_filename ""] == 0 } {
	  return 0
      }
   } else {
       #set repertoire [pwd]
       set repertoire $audace(rep_images)
       set rep_et_filename "$repertoire/$filenamespc"
   }

   #============================================================================#
   #-- $spectre = liste contenant : la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
   #set spectre [openspc $rep_et_filename]

   #-- Ouverture meth 2 : Ajouté le 16/12/2005
   ##set filename [ file tail $filenamespc ]
   ##set spectre [openspc $filename]
   #--
   #set profilspc(naxis2) [lindex $spectre 1]
   #set profilspc(intensite) [lindex $spectre 0]
   #set intensites [lindex $spectre 0]
   #============================================================================#

   #--- Détermine les éléments de calcul des longueurs d'onde :
   buf$audace(bufNo) load "$rep_et_filename"
   set profilspc(pixels) ""
   set profilspc(intensite) ""
   set profilspc(object) "$filenamespc"
   set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
       set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
   }
   if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
       set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
       set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
       set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
       set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
       set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
   } else {
       set spc_d 0.0
   }

  #--- Gestion de la commande getpix selon la version d'Audela :
  if { [regexp {1.4.0} $audela(version) match resu ] } {
   if { [ lsearch $listemotsclef "CRVAL1" ] ==-1 || $dispersion == 1. } {
       # Spectre non calibré
       ::console::affiche_resultat "Ouverture d'un profil de raies non calibré...\n $filenamespc\n"
       for {set k 1} {$k<=$naxis1} {incr k} {
	   lappend profilspc(pixels) $k
	   lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
       }
   } else {
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré nonlinéairement...\n$filenamespc\n"
	   if { $spc_a < 0.01 } {
	       for {set k 1} {$k<=$naxis1} {incr k} {
		   #- Ancienne formulation < 070104 :
		   set pixel [expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
		   lappend profilspc(pixels) $pixel
		   lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
	       }
	   } else {
	       for {set k 1} {$k<=$naxis1} {incr k} {
		   set pixel [expr $spc_d*$k*$k*$k+$spc_c*$k*$k+$spc_b*$k+$spc_a ]
		   lappend profilspc(pixels) $pixel
		   lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
	       }
	   }
	   #-- Calibration linéaire :
       } else {
	   # Spectre calibré linéairement
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré linéairement...\n$filenamespc\n"
	   for {set k 1} {$k<=$naxis1} {incr k} {
	       set pixel [expr $lambda0+$k*$dispersion]
	       lappend profilspc(pixels) $pixel
	       lappend profilspc(intensite) [ lindex [ buf$audace(bufNo) getpix [list $k 1] ] 1 ]
	   }
       }
   }
  } elseif { [regexp {1.3.0} $audela(version) match resu ] } {
   if { [ lsearch $listemotsclef "CRVAL1" ] ==-1 || $dispersion == 1. } {
       # Spectre non calibré
       ::console::affiche_resultat "Ouverture d'un profil de raies non calibré...\n$filenamespc\n"
       #for {set k 1} {$k <= $naxis1} {incr k} {
	#   append profilspc(pixels) "$k "
	#   append profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
       #}
       for {set k 1} {$k<=$naxis1} {incr k} {
	   lappend profilspc(pixels) $k
	   lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
       }
   } else {
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré nonlinéairement...\n$filenamespc\n"
	   if { $spc_a < 0.01 } {
	       for {set k 1} {$k<=$naxis1} {incr k} {
		   #- Ancienne formulation < 070104 :
		   set pixel [expr $spc_a*$k*$k+$spc_b*$k+$spc_c ]
		   lappend profilspc(pixels) $pixel
		   lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
	       }
	   } else {
	       for {set k 1} {$k<=$naxis1} {incr k} {
		   set pixel [expr $spc_d*$k*$k*$k+$spc_c*$k*$k+$spc_b*$k+$spc_a ]
		   lappend profilspc(pixels) $pixel
		   lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
	       }
	   }
	   #-- Calibration linéaire :
       } else {
	   # Spectre calibré linéairement
	   ::console::affiche_resultat "Ouverture d'un profil de raies calibré linéairement...\n$filenamespc\n"
	   for {set k 1} {$k<=$naxis1} {incr k} {
	       set pixel [expr $lambda0+$k*$dispersion]
	       lappend profilspc(pixels) $pixel
	       lappend profilspc(intensite) [ buf$audace(bufNo) getpix [list $k 1] ]
	   }
       }
   }
  }
   #::console::affiche_resultat "$profilspc(intensite)\n"
   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl 
   #pvisu2 $intensites
   pvisu
}




##########################################################
#  Procedure du trace du profil de raie  
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : fichier .dat du profil de raie                                  
##########################################################

proc spc_loaddat { {filenamespc ""} } {

   global profilspc
   global captionspc
   global colorspc
   global audace
   global conf
   set ext_spc .dat

   ## === Interfacage de l'ouverture du fichier profil de raie ===
   if {$filenamespc==""} {
      # set idir ./
      # set ifile *.spc
      set idir $audace(rep_images)
      set ifile *.dat

      if {[info exists profilspc(initialdir)] == 1} {
         set idir "$profilspc(initialdir)"
      }
      if {[info exists profilspc(initialfile)] == 1} {
         set ifile "$profilspc(initialfile)"
      }
      # set filenamespc [tk_getOpenFile -title $captionspc(loadspc) -filetypes [list [list "$captionspc(spc_profile)" {.spc}]] -initialdir $idir -initialfile $ifile ]
      set filenamespc [tk_getOpenFile -title $captionspc(loadspctxt) -filetypes [list [list "$captionspc(spc_profile)" {.dat}]] -initialdir $idir -initialfile $ifile ]
      if {[string compare $filenamespc ""] == 0 } {
         return 0
      }
   }

   ## === Lecture du fichier de profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $filenamespc]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$filenamespc" r]
   set contents [split [read $input] \n]
   close $input
   # set profilspc(naxis2) [expr [lindex $contents 2]]
   set profilspc(naxis2) [expr [llength $contents]-2]
   set profilspc(exptime) "?"
   set profilspc(object) "$filenamespc"
   set profilspc(intensite) ""
   set profilspc(pixels) ""

   set offset 1
   for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
      set ligne [lindex $contents $offset]
      append profilspc(pixels) "[lindex $ligne 0] "
      # append profilspc(lambda) "[lindex $ligne 1] "
      # append profilspc(intensite) "[lindex $ligne 2] "
      append profilspc(intensite) "[lindex $ligne 1] "
      # append profilspc(argon1) "[lindex $ligne 3] "
      # append profilspc(argon2) "[lindex $ligne 4] "
      # append profilspc(noir) "[lindex $ligne 5] "
      # append profilspc(repere) "[lindex $ligne 6] "
      incr offset
   }

   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl 
   pvisu
}



#####################################################################
#  Procedure d'ouverture d'un profil de raie au format ascii
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : fichier .dat du profil de raie                                  
#####################################################################


proc open_profil {{filenamespc ""}} {
    ::console::affiche_resultat "Rien.\n"
}




#####################################################################
#  Procedure du trace du profil de raie dans la fenetre graphique 
# Autre methode
# **** Inutilisee ***** 
# Arguments : fichier .dat du profil de raie                                  
#####################################################################


proc spc_trace_profil {{filenamespc ""}} {

   global audace
   global conf
   global profilspc
   global captionspc
   global colorspc
   set extsp "dat"

   ## === Lecture du fichier de donnees du profil de raie ===
   catch {unset profilspc} {}
   set profilspc(initialdir) [file dirname $audace(rep_images)]
   set profilspc(initialfile) [file tail $filenamespc]
   set input [open "$audace(rep_images)/$filenamespc" r]
   set contents [split [read $input] \n]
   close $input

   ## === Extraction des numeros des pixels et des intensites ===
   #::console::affiche_resultat "ICI :\n $contents.\n"
   set profilspc(naxis2) [expr [llength $contents]-2]
   #::console::affiche_resultat "$profilspc(naxis2)\n"
   set offset 1
   for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
      set ligne [lindex $contents $offset]
      append profilspc(pixels) "[lindex $ligne 0] "
      append profilspc(intensite) "[lindex $ligne 1] "
      incr offset
   }
   #::console::affiche_resultat "$profilspc(pixels)\n"

   # === On prepare les vecteurs a afficher ===
   set len [llength $profilspc(pixels)]
   set pp ""
   set yy ""
   set kk 0
   for {set k 1} {$k<=$len} {incr k} {
         append pp " [lindex $profilspc(pixels) $k]"
         append yy " [lindex $profilspc(intensite) $k]"
         incr kk         
   }
   blt::vector create vx
   blt::vector create vy


   ## Tracer du profil de raie 
   toplevel .profil_ix
   # blt::graph .profil_ix.g -title "Profil de raie spatial de $filenamespc"
   blt::graph .profil_ix.g -title "Profil de raie spatial de $profilspc(initialfile)"
   .profil_ix.g configure -width 7.87i -height 5.51i
   .profil_ix.g legend configure -hide yes
   pack .profil_ix.g -in .profil_ix 
   vx set $pp
   vy set $yy
   .profil_ix.g element create "Profil spatial" -symbol none -xdata vx -ydata vy -smooth natural

   set div_x 10
   set div_y 5
   #set echellex [expr $len/10]
   set echellex [expr int($len/($div_x*10))*10]
   .profil_ix.g axis configure x -stepsize $echellex
   #scrollbar .hors -command {.profil_ix.g axis view x } -orient horizontal
   #.profil_ix.g axis configure x -stepsize $echellex -scrollcommand { .hors set }

   set tmp_i [lsort -real -decreasing $profilspc(intensite)]
   set i_max [lindex $tmp_i 0]
   #set echelley [expr $i_max/5]
   set echelley [expr int($i_max/($div_y*10))*10]
   .profil_ix.g axis configure y -stepsize $echelley
}
#****************************************************************#


#########################################################
# Créée le profil de raies de spectre d'une lampe de calibration adapte à la position du spectre d'une etoile
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 17-09-2006
# Date de mise à jour : 17-09-2006
# Arguments : spectre_2D_objet spectre_2D_lampe
##########################################################

proc spc_profillampe { args } {

   global audace
   global conf
   if { [llength $args] == 2 } {
       set spectre_objet [ lindex $args 0 ]
       set spectre_lampe [ lindex $args 1 ]

       #--- Crée le profil de raie du spectre de la lampe de étalon :
       set linecoords [ spc_detect $spectre_objet ]
       set y1 [ expr int([ lindex $linecoords 0 ]+0.5*[ lindex $linecoords 1 ]) ]
       set y2 [ expr int([ lindex $linecoords 0 ]-0.5*[ lindex $linecoords 1 ]) ]
       buf$audace(bufNo) load $audace(rep_images)/$spectre_lampe
       buf$audace(bufNo) imaseries "BINY y1=$y1 y2=$y2 height=1"
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
       buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
       buf$audace(bufNo) save $audace(rep_images)/${spectre_lampe}_spc
       buf$audace(bufNo) bitpix short
       ::console::affiche_resultat "\nProfil de raie de la lampe de calibration sauvé sous ${spectre_lampe}_spc\n"
       return ${spectre_lampe}_spc
   } else {
       ::console::affiche_erreur "Usage: spc_profillampe spectre_2D_objet spectre_2D_lampe\n\n"
   }
}
#****************************************************************#














#=====================================================================#
#                 Anciennes version des fonctions                     #
#=====================================================================#

#****************************************************************#
proc spc_profilx_060607 { args } {
    global audace
    global conf
    set extsp ".dat"
    set nomprofil "profil_spcx"

    if { [llength $args] == 2 } {
	set fichier [ file rootname [ lindex $args 0 ] ]
	set x [ lindex $args 1 ]

	#--- Binning
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	#- Les commandes PROFILE et PROFILE2 n'accèptent pas les noms de fichier compliqués
	buf$audace(bufNo) imaseries "PROFILE2 filename=$audace(rep_images)/$nomprofil$extsp direction=y offset=$x"
	#--- Sauvegarde du profil
	#-- Enlève la première ligne du fichier dat (label des colonnes)
	#- J'ai modifié tt_user3 ligne 350 de la libtt.
	set fsortie [ file rootname [ spc_dat2fits $nomprofil$extsp ] ]
	file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	file delete "$audace(rep_images)/$nomprofil$extsp"
	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne\n\n"
    }
}
###############################################################



proc spc_profilx_07062006 { args } {
    global audace
    global conf
    set extsp ".dat"

    if { [llength $args] <= 3 } {
	if { [llength $args] == 2 } {
	    set fichier [ lindex $args 0 ]
	    set x [ lindex $args 1 ]
	    set dx 0.5
	} elseif { [llength $args] == 3 } {
	    set fichier [ lindex $args 0 ]
	    set x [ lindex $args 1 ]
	    set largeur [ lindex $args 2 ]
	    set dx [ expr int($largeur*.5-1)+1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne ?largeur à binner?\n\n"
	    return 0
    	}

	#*** Meth 1
	set flag 0
	if { $flag == 1 } {
	    #--- Découpage de la ligne
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	    set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
	    ## coords contient : { x1 y1 x2 y2 }
	    ##  -----------B
	    ##  |          |
	    ##  A-----------
	    set coords_zone [ list [ expr $x-int($dx) ] 1 [ expr $x+int($dx) ] $naxis2 ]
	    buf$audace(bufNo) window $coords_zone
	    #--- Binning
	    set lgr [ expr $dx*2 ]
	    if { $dx != 0.5 } {
		::console::affiche_resultat "Hauteur de binning : $lgr\n"
		buf$audace(bufNo) binx 1 $lgr 1
	    }
	} else {
	    set lgr [ expr $dx*2 ]
	    if { $dx != 0.5 } {
		::console::affiche_resultat "Hauteur de binning : $lgr\n"
		set x1 [ expr $x-$dx ]
		set x2 [ expr $x+$dx ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		#-- L'image résultante de la somme n'est pas un fichier FITS 1D : naxis1=1 naxis2=old_naxis2 !
		# buf$audace(bufNo) binx $x1 $x2 1
		buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${fichier}_spcx$extsp direction=x offset=1"
	    } else {
		::console::affiche_resultat "Hauteur de binning : $lgr\n"
		set x1 [ expr $x-$dx ]
		set x2 [ expr $x+$dx ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		# buf$audace(bufNo) binx $x1 $x2 1
		buf$audace(bufNo) imaseries "PROFILE filename=$audace(rep_images)/${fichier}_spcx$extsp direction=x offset=1"
	    }
	}
	#--- Sauvegarde du profil
	set sortie [ spc_dat2fits ${fichier}_spcx$extsp ]
	#buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	#buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
	#buf$audace(bufNo) bitpix float
	#buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcx"
	::console::affiche_resultat "Profil d'intensité de la ligne sauvé sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne ?largeur?\n\n"
    }
}
###############################################################



proc spc_detectasym_060623 { args } {

    global audace
    global conf

    if { [ llength $args ] == 1 } {
	set fichier [ file rootname [lindex $args 0 ] ]
	buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]

	#--- Creations de profils de plusieurs colonnes
	set xpas [ expr int($naxis1/5) ]
	#-- n° du profil resultant
	::console::affiche_resultat "Pas entre chaque point de détection : $xpas\n"
	set i 1
	for {set k $xpas} {$k <= $naxis1} {incr k} {
	    set fsortie [ file rootname [ spc_profilx $fichier $k ] ]
	    # ::console::affiche_resultat "$fsortie\n"
	    file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/profil-$i$conf(extension,defaut)"
	    set k [ expr $k+$xpas-1 ]
	    incr i
	}
	set nbimg [ expr $naxis1/$xpas ]
	sadd profil- ${fichier}_spcx $nbimg ]
	delete2 profil- $nbimg

	#--- Détermination des paramètres du de l'épaisseur du spectre
	buf$audace(bufNo) load "$audace(rep_images)/${fichier}_spcx"
	#set windowcoords [ list 1 1 $naxis2 1 ]
        set y1 [ expr int(.03*$naxis2) ]
        set y2 [ expr int(.97*$naxis2) ]
	set windowcoords [ list 1 $y1 1 $y2 ]
	set gparams [ buf$audace(bufNo) fitgauss $windowcoords ]
	set ycenter [ lindex $gparams 1 ]
	#-- Choix : la largeur de la gaussienne est de 1.9*FWHM
	set largeur [ expr 1.9*[ lindex $gparams 2 ] ]
	return [ list $ycenter $largeur ]
    } else {
	::console::affiche_erreur "Usage: spc_detectasym spectre_2D_fits\n\n"
    }
}
###############################################################



proc spc_subsky_050700 { args } {

    global audace
    global conf

    if { [ llength $args ] == 4 } {
	set spectre [ lindex $args 0 ]
	set ycenter [ lindex $args 1 ]
	set hauteur [ lindex $args 2 ]
	set methodemoy [ lindex $args 3 ]

	::console::affiche_resultat "ycenter : $ycenter ; hauteur : $hauteur\n"
	#--- Initialisation de paramètres
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
	set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]

	#--- Passe en entier ycenter et hauteur pour le decoupage de zones de meme taille :
	## [ expr $ycenter+0.5*$hauteur-(int($ycenter+0.5*$hauteur)+1) ] >= 0.5 
	#if { [ expr $ycenter-int($ycenter) ] > 0.5 } {
	  #  set ycenter [ expr int($ycenter)+1 ]
	#} else {
	#    set ycenter [ expr int($ycenter) ]
	#}
	#if { [ expr $hauteur-int($hauteur) ] > 0.5 } {
	#    set hauteur [ expr int($hauteur)+1 ]
	#} else {
	#    set hauteur [ expr int($hauteur) ]
	#}
	set ycenter [ expr round($ycenter) ]
	set hauteur [ expr round($hauteur) ]

	#--- Découpage de zone où se trouve le spectre :
	#--  -----------B
	#--  |          |
	#--  A-----------
	set coords_zone_spectre [ list 1 [expr int($ycenter-0.5*$hauteur)] $naxis1 [expr int($ycenter+0.5*$hauteur)] ]
	::console::affiche_resultat "Zone du spectre : $coords_zone_spectre\n"
	#--- Découpage de la zone où se trouve le spectre
	buf$audace(bufNo) window $coords_zone_spectre
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone"


	#--- Découpage de la zone supérieure pour le fond de ciel :
	set coords_zone_sup [ list 1 [expr int($ycenter+1.5*$hauteur)] $naxis1 [expr int($ycenter+2.5*$hauteur)] ]
	::console::affiche_resultat "Zone supérieure : $coords_zone_sup\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_sup
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesup"

	#--- Découpage de la zone inférieure pour le fond de ciel :
	set coords_zone_inf [ list 1 [expr int($ycenter-1.5*$hauteur)] $naxis1 [expr int($ycenter-2.5*$hauteur)] ]
	::console::affiche_resultat "Zone inférieure : $coords_zone_inf\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_inf
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zoneinf"

	#--- Calcul de la moyenne du fond de ciel et la soustrait :
	if { $methodemoy == "moy" } {

	    #--- Somme moyenne des zones sup et inf :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 zones.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zoneinf" 0
	    buf$audace(bufNo) mult -0.5
	    uncosmic 0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "med" } {

	    #--- Somme médiane des colonne pour chaque zone puis moyenne :
	    ::console::affiche_resultat "Soustraction du fond de ciel : médiane des colonnes de chaque zone.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteur"
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesupmed"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$hauteur"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zonesupmed" 0
	    buf$audace(bufNo) mult -0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	    file delete "$audace(rep_images)/${spectre}_zonesupmed$conf(extension,defaut)"
	} elseif { $methodemoy == "moy2" } {

	    #--- Moyenne de la valeur des fonds de ciel tirés des 2 zones :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 fonds.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moysup [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moyinf [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    set moy [ expr -0.5*($moysup+$moyinf) ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    #buf$audace(bufNo) clear
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "back" } {

	    #--- Méthode du BACK :
	    ::console::affiche_resultat "Soustraction du fond de ciel : méthode fraction.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	    buf$audace(bufNo) imaseries "BACK back_kernek=30 back_threshold=0.2 sub"
	    buf$audace(bufNo) window $coords_zone_spectre
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "sup" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessus le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "inf" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessous le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Crée une image uniforme d'intensité égale à la moyenne des fonds de ciel
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "none" } {

	    #--- Aucune soustraction du fond de ciel
	    ::console::affiche_resultat "Aucune soustraction du fond de ciel.\n"
	    file copy "$audace(rep_images)/${spectre}_zone$conf(extension,defaut)" "$audace(rep_images)/${spectre}_zone_fc$conf(extension,defaut)"
	} else {
	    ::console::affiche_resultat "Mauvaise option de calcul du fond de ciel.\n"
	}

	#--- Sauvegarde et netoyages :
	::console::affiche_resultat "Spectre 2D nettoyé du fond de ciel sauvé sous ${spectre}_zone_fc.\n"
	# file delete $audace(rep_images)/${spectre}_zone$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zonesup$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zoneinf$conf(extension,defaut)
	return ${spectre}_zone_fc
    } else {
	::console::affiche_erreur "Usage: spc_subsky spectre_2D_fits y_centre_spectre hauteur_spectre méthode_soustraction_fond_de_ciel (moy, moy2, med, sup, inf, none, back)\n\n"
    }
}
#***************************************************************************#
