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
# Charger en script : source $audace(rep_scripts)/spcaudace/spc_profil.tcl
#
#####################################################################################


# Remarque : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialis�es dans le fichier cap_mauclaire.tcl
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

proc spc_extract_profil_zone { {filenamespc_spacial ""} } {

    #****************************************************************#
    ## Chargement : source $audace(rep_scripts)/profil_raie.tcl
    ## Les var nommees audace_* sont globales
    global audace
    ## flag audace
    global conf
    global flag_ok


    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc
    set filespacialspc [ file tail [ file rootname $filenamespc_spacial ] ]
    #set filespacialspc $filenamespc_spacial
    ::console::affiche_resultat "Fichier traite : $filespacialspc \n"

    ## Verif existence
    #if {[file exist [file join $audace(rep_images)/$filespacialspc.$conf(extension,defaut)]]==1} {
	::console::affiche_resultat "Usage : extreact_profil_zone profil_raie\n"
	::console::affiche_resultat "Chargement du fichier $filespacialspc...\n"
	buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	## Algo
	::console::affiche_resultat "S�lection de la fenetre d'etude.\n"

	## On affiche un message demandant de s�lectionner la zone d'�tude
	## Lecture des coordonnees de la ligne centrale du spectre
	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)


	set flag_ok 0

	# Cr�ation de la fen�tre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace

	#--- Textes d'avertissement
	label .benji.lab -text "S�lectionnez la zone du spectre..."
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
	## ysup=ordonn�e max. de la bo�te s�lectionn�e
	## yinf=aordonn�e min. de la bo�te s�lectionn�e
	## ht_spectre="hauteur" en pixels du spectre
	## ht_dessus=hauteur d'image au dessus du spectre
	## ht_dessous=hauteur d'image au dessous du spectre
	## xmax_zone=abscisse max. de la zonne s�lectionn�e
	## xmin_zone=abscisse min. de la zonne s�lectionn�e
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
	#saveima ${filespacialspc}_zone
	
	##--------------- Traitement de la zone selectionnee -------------------#
	set listcoords [list $ht_spectre $yinf $ysup $xinf_zone $xsup_zone $ht_dessous $ht_dessus 7]
	spc_bin ${filespacialspc}_zone $filespacialspc $listcoords
   #}
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

    global audace
    global conf
    global flag_ok

    if {[llength $args] == 1} {
	set filespacialspc [ file rootname [lindex $args 0] ]
	# Retire l'extension .fit du nom du fichier
	# regsub -all .fit $filespacialspc - filespatialspc
	## Verif existence
	#if {[file exist [file join $audace(rep_images)/$filespacialspc.$conf(extension,defaut)]]==1} 
	buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	#loadima "$filespacialspc"
	::console::affiche_resultat "S�lection de la fenetre d'etude.\n"

	## On affiche un message demandant de s�lectionner la zone d'�tude
	## Lecture des coordonnees de la ligne centrale du spectre
	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)
	set flag_ok 0
	# Cr�ation de la fen�tre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace

	#--- Textes d'avertissement
	label .benji.lab -text "S�lectionnez la zone du spectre..."
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

	## Cr�ation d'un fichier contenant la zone selectionnee
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
# Soustrait le fond de ciel avec BACK et cr�e le profil de raie d'une zone d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 04-03-2006
# Date de mise a jour : 04-03-2006                               
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_profil_zone { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filespacialspc [ file rootname [lindex $args 0] ]

	#--- Soustrait le fond de ciel
	set sp_propre [ spc_subsky $filespacialspc auto moy ]
	#--- S�lectionne la zone � �tudier
	set sp_zone [ spc_extract_zone $sp_propre ]
	file delete $audace(rep_images)/$sp_propre$conf(extension,defaut)
	#--- Cr�e le profil de raies
	buf$audace(bufNo) load "$audace(rep_images)/$sp_zone"
	set ht_spectre [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	spc_bins "$sp_zone" $ht_spectre
    } else {
	::console::affiche_erreur "Usage: spc_profil_zone spectre_2D_fits\n\n"
    }
}
###############################################################



###############################################################
# D�termine le centre vertical et la largeur d'un spectre 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 27-08-2005
# Date de mise a jour : 27-08-2005                               
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_detect { {filenamespc_spacial ""} } {

    global audace
    global conf

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
}
###############################################################



###############################################################
# D�termine le centre vertical et la largeur d'un spectre 2D
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
	#-- n� du profil resultant
	set i 1
	for {set k $xpas} {$k <= $naxis1} {incr k} {
	    set fsortie [ file rootname [ spc_profilx $fichier $k ] ]
	    file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/profil-$i$conf(extension,defaut)"
	    set k [ expr $k+$xpas-1 ]
	    incr i
	}
	set nbimg [ expr $naxis1/$xpas ]
	sadd profil- ${fichier}_spcx $nbimg ]
	delete2 profil- $nbimg

	#--- D�termination des param�tres du de l'�paisseur du spectre
	buf$audace(bufNo) load "$audace(rep_images)/${fichier}_spcx"
	set windowcoords [ list 1 1 $naxis2 1 ]
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



###############################################################
# Soustrait le fond de ciel � un spectre 2D
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
	return ${filespacialspc}_fc
    } else {
	::console::affiche_erreur "Usage: spc_subskyfrac spectre_2D_fits\n\n"
    }
}
###############################################################


###############################################################
# Soustrait le fond de ciel sur une s�rie de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 06-03-2006
# Date de mise a jour : 06-03-2006                               
# Arguments : nom g�g�rique des fichiers fits du spectre spatial
###############################################################

proc spc_subskiesfrac { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set nom_generique [lindex $args 0]
	set liste_fichiers [ lsort -dictionary [glob ${nom_generique}*$conf(extension,defaut)] ]
	set nbimg [ llength $liste_fichiers ]
	::console::affiche_resultat "$nbimg fichiers � traiter.\n"
	set i 1

	foreach fichier $liste_fichiers {
	    buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	    buf$audace(bufNo) imaseries "BACK back_kernek=15 back_threshold=0.2 sub"
	    buf$audace(bufNo) save "$audace(rep_images)/${nom_generique}fc-$i"
	    incr i
	}
	return ${nom_generique}fc-
    } else {
	::console::affiche_erreur "Usage: spc_subskies nom g�n�rique spectres_2D_fits\n\n"
    }
}
###############################################################




###############################################################
# Extraction du profil a partir du spectre 2D en mode texte et autos�lection de zone 
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 26-02-2006
# Date de modification : 05-07-2006
# Arguments : fichier fits du spectre spatial ?m�thode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)? ?m�thode de d�tection du spectre (large, serre)? ?m�thode de bining (add)?
###############################################################

proc spc_profil { args } {

    global audace
    global conf

    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc
    if { [llength $args] <= 4 && [llength $args] != 0 } {
	if { [llength $args] == 1 } {
	    #--- Gestion avec options par d�faut :
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
	    ::console::affiche_erreur "Usage: spc_profil spectre_2D_fits ?m�thode soustraction fond de ciel (moy, moy2, med, sup, none, frac)? ?m�thode de d�tection du spectre (large, serre)? ?m�thode de bining (add)?\n\n"
	}

	#--- Chargement du spectre :
	if { [file exists "$audace(rep_images)/$spectre2d$conf(extension,defaut)" ] == 1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
	} else {
	    ::console::affiche_resultat "Le fichier $spectre2d n'existe pas.\n"
	    return 0
	}

	#--- D�tection de la zone o� se trouve le spectre :
	if { $methodedetect == "large" } {
	    set gauss_params [ spc_detect $spectre2d ]
	} elseif { $methodedetect == "serre" } {
	    set gauss_params [ spc_detectasym $spectre2d ]
	} else {
	    set gauss_params [ spc_detect $spectre2d ]
	}

	#--- D�coupage de la zone � biner et retrait du fond de ciel :
	set ycenter [ lindex $gauss_params 0 ] 
	set hauteur [ lindex $gauss_params 1 ]
	#-- Algo : set coords_zone [list 1 [expr int($ycenter-0.5*$largeur)] $naxis1 [expr int($ycenter+0.5*$largeur)]]
	set spectre_zone_fc [ spc_subsky $spectre2d $ycenter $hauteur $methodefc ]

	#--- Bining :
	if { $methodebin == "add" } {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	} else {
	    set profil_fc [ spc_bins $spectre_zone_fc ]
	}

	#--- Message de fin et nettoyage :
	::console::affiche_resultat "Profil de raies sauv� sous $profil_fc\n"
	file delete "$audace(rep_images)/${spectre2d}_zone$conf(extension,defaut)"
	return $profil_fc
   } else {
	::console::affiche_erreur "Usage: spc_profil spectre_2D_fits ?m�thode soustraction fond de ciel (moy, moy2, med, sup, inf, none, back)? ?m�thode de d�tection du spectre (large, serre)? ?m�thode de bining (add)?\n\n"
   }
}
#**************************************************************************#



###############################################################
# Proc�dure : soustrait le fond de ciel � la zone du spectre d�tect�e
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 05-07-2006
# Date de modification : 05-07-2006
# Arguments : spectre_2D_fits y_centre_spectre hauteur_spectre m�thode_soustraction_fond_de_ciel (moy, moy2, med, inf, sup, none, back)
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
	#--- Initialisation de param�tres
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]

	#--- Passe en entier ycenter et hauteur pour le decoupage de zones de meme taille :
	#[ expr $ycenter+0.5*$hauteur-(int($ycenter+0.5*$hauteur)+1) ] >= 0.5 
	if { [ expr $ycenter-int($ycenter) ] > 0.5 } {
	    set ycenter [ expr int($ycenter)+1 ]
	} else {
	    set ycenter [ expr int($ycenter) ]
	}
	if { [ expr $hauteur-int($hauteur) ] > 0.5 } {
	    set hauteur [ expr int($hauteur)+1 ]
	} else {
	    set hauteur [ expr int($hauteur) ]
	}

	#--- D�coupage de zone o� se trouve le spectre :
	#--  -----------B
	#--  |          |
	#--  A-----------
	set coords_zone_spectre [ list 1 [expr int($ycenter-0.5*$hauteur)] $naxis1 [expr int($ycenter+0.5*$hauteur)] ]
	::console::affiche_resultat "Zone du spectre : $coords_zone_spectre\n"
	#--- D�coupage de la zone o� se trouve le spectre
	buf$audace(bufNo) window $coords_zone_spectre
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone"


	#--- D�coupage de la zone sup�rieure pour le fond de ciel :
	set coords_zone_sup [ list 1 [expr int($ycenter+1.5*$hauteur)] $naxis1 [expr int($ycenter+2.5*$hauteur)] ]
	::console::affiche_resultat "Zone sup�rieure : $coords_zone_sup\n"
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) window $coords_zone_sup
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesup"

	#--- D�coupage de la zone inf�rieure pour le fond de ciel :
	set coords_zone_inf [ list 1 [expr int($ycenter-1.5*$hauteur)] $naxis1 [expr int($ycenter-2.5*$hauteur)] ]
	::console::affiche_resultat "Zone inf�rieure : $coords_zone_inf\n"
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

	    #--- Somme m�diane des colonne pour chaque zone puis moyenne :
	    ::console::affiche_resultat "Soustraction du fond de ciel : m�diane des colonnes de chaque zone.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$haut"
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zonesupmed"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set haut [ lindex [ buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
	    buf$audace(bufNo) imaseries "MEDIANY y1=1 y2=$haut height=$haut"
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zonesupmed" 0
	    buf$audace(bufNo) mult -0.5
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	    file delete "$audace(rep_images)/${spectre}_zonesupmed$conf(extension,defaut)"
	} elseif { $methodemoy == "moy2" } {

	    #--- Moyenne de la valeur des fonds de ciel des 2 zones :
	    ::console::affiche_resultat "Soustraction du fond de ciel : moyenne des 2 fonds.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moysup [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zoneinf"
	    set moyinf [ lindex [ buf$audace(bufNo) stat ] 6 ]
	    set moy [ expr -0.5*($moysup+$moyinf) ]
	    #-- Cr�e une image uniforme d'intensit� �gale � la moyenne des fonds de ciel
	    #buf$audace(bufNo) clear
	    set haut [ expr int($hauteur)+1 ]
	    buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $haut FORMAT_USHORT COMPRESS_NONE 0
	    buf$audace(bufNo) offset $moy
	    #-- Soustraction :
	    buf$audace(bufNo) add "$audace(rep_images)/${spectre}_zone" 0
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "back" } {

	    #--- M�thode du BACK :
	    ::console::affiche_resultat "Soustraction du fond de ciel : m�thode fraction.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	    buf$audace(bufNo) imaseries "BACK back_kernek=30 back_threshold=0.2 sub"
	    buf$audace(bufNo) window $coords_zone_spectre
	    buf$audace(bufNo) save "$audace(rep_images)/${spectre}_zone_fc"
	} elseif { $methodemoy == "sup" } {

	    #--- Soustraction du fond de ciel d'une zone dessus le spectre :
	    ::console::affiche_resultat "Soustraction du fond de ciel d'une zone dessus le spectre.\n"
	    buf$audace(bufNo) load "$audace(rep_images)/${spectre}_zonesup"
	    set moy [expr -1.*[ lindex [ buf$audace(bufNo) stat ] 6 ] ]
	    #-- Cr�e une image uniforme d'intensit� �gale � la moyenne des fonds de ciel
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
	    #-- Cr�e une image uniforme d'intensit� �gale � la moyenne des fonds de ciel
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
	::console::affiche_resultat "Spectre 2D netoy� du fond de ciel sauv� sous ${spectre}_zone_fc.\n"
	# file delete $audace(rep_images)/${spectre}_zone$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zonesup$conf(extension,defaut)
	file delete $audace(rep_images)/${spectre}_zoneinf$conf(extension,defaut)
	return ${spectre}_zone_fc
    } else {
	::console::affiche_erreur "Usage: spc_subsky spectre_2D_fits y_centre_spectre hauteur_spectre m�thode_soustraction_fond_de_ciel (moy, moy2, med, sup, inf, none, back)\n\n"
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
# Arguments : 
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_bin { {filenamespc_zone_rep ""} {filenamespc_spatial_rep ""} {listcoords ""} } {

    global audace
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

    ## On binne sur les colonnes dans la region de l'image correspondant au spectre et on sauvegarde le r�sultat dans ${filespacialspc}_sp :
    ::console::affiche_resultat "Binning des colonnes de la r�gion s�lectionn�e...\n"
    ## Exemple de binning sur la totatlite de la totalite de la hauteur de l'image initiale
    ## 
    ##set ysup2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
    ##buf$audace(bufNo) biny 1 $ysup2

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
    #buf$audace(bufNo) biny 1 [expr $ysup-$yinf]
    buf$audace(bufNo) biny 1 $ht_spectre 1
    ## Pond�ration par la hauteur en pixels
    #buf$audace(bufNo) mult [expr 1.0/$ht_spectre]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"


    ## ******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ****** ##
    ##---- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#

    ## Creation d'une image de largeur limite�e par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous
    set coords_zonev [list $xsup_zone [expr $ysup+$ht_dessus] $xinf_zone [expr $yinf-$ht_dessous+1]]
    ## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
    #::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
    buf$audace(bufNo) window $coords_zonev
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
  
    ## On binne sur les colonnes dans la r�gion de l'image au dessus du spectre et on sauvegarde le r�sultat dans ${filenamespc_spatial}_spsup	        
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"	
    buf$audace(bufNo) biny $ysup [expr $ysup+$ht_dessus-1] 1
    ## Pond�ration par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"

    ## On binne sur les colonnes dans la r�gion de l'image au dessous du spectre et on sauvegarde le r�sultat dans ${filenamespc_spatial}_spinf
    ::console::affiche_resultat "Binning des colonnes.\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"
    buf$audace(bufNo) biny $yinf [expr $yinf-$ht_dessous+1] 1
    ## Pond�ration par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessous]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spinf"

    ## Calcul une moyenne du fond du ciel prit dessus et dessous le spectre.
    ::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
    ##~~~~~ BUG ICI : 25/04/2006 NON, PAS DE BUG
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0
    
    ## Petites feintes : on multiplie l'image pr�c�dente par -0.5 pour avoir une moyenne, le chiffre n�gatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant � cette image : le spectre !
    buf$audace(bufNo) mult -0.5
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
    ## Initialisation des mots-clef spectroscopie
    buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
    buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]

    ## On sauvegarde le spectre avec correction du fond du ciel
    ::console::affiche_resultat "Profil de raies sauv� sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"

    #--- Export au format dat :
    # ::console::affiche_resultat "Extraction des valeurs et �criture du fichier ascii $filenamespc_spatial${extsp}\n"
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

    buf$audace(bufNo) bitpix short
    return ${filenamespc_spatial}_spc
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
  global conf
  set extsp ".dat"

  if { [llength $args] == 1 } {
      set filenamespc_zone [ lindex $args 0 ]

      #--- Binning
      ::console::affiche_resultat "Binning des colonnes de la r�gion s�lectionn�e...\n"
      buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
      set ht_spectre [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
      buf$audace(bufNo) biny 1 $ht_spectre 1
      buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
      buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_zone}_spc"
      ::console::affiche_resultat "\nProfil de raies sauv� sous ${filenamespc_zone}_spc$conf(extension,defaut)\n"

      #--- Export au format dat
      # ::console::affiche_resultat "Extraction des valeurs et �criture du fichier ascii $filenamespc_zone${extsp}\n"
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
# Effectue le binning de la zone selectionnee sur le spectre et soustrait le fond du ciel de la partie sup�rieure.
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour n-2 : 31-01-2005
# Date de mise a jour n-1 : 29-11-2005 (buf1 load en loadima)
# Date de mise a jour : 27-12-05 (buf1 load rep/img)
# Date de mise a jour : 26-02-06 (soustrait que la partie sup�rieure du fond de ciel)
# Arguments : 
#  * fichier fits de la zone selectionnee du spectre spatial
#  * fichier fits du spectre spatial
###############################################################

proc spc_binsup { {filenamespc_zone_rep ""} {filenamespc_spatial_rep ""} {listcoords ""} } {

    global audace
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

    ## On binne sur les colonnes dans la region de l'image correspondant au spectre et on sauvegarde le r�sultat dans ${filespacialspc}_sp :
    ::console::affiche_resultat "Binning des colonnes de la r�gion s�lectionn�e...\n"
    ## Exemple de binning sur la totatlite de la totalite de la hauteur de l'image initiale
    ## 
    ##set ysup2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
    ##buf$audace(bufNo) biny 1 $ysup2

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_zone"
    #buf$audace(bufNo) biny 1 [expr $ysup-$yinf]
    buf$audace(bufNo) biny 1 $ht_spectre 1
    ## Pond�ration par la hauteur en pixels
    #buf$audace(bufNo) mult [expr 1.0/$ht_spectre]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"


    ## ******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ****** ##
    ##-- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#

    ## Creation d'une image de largeur limite�e par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous
    set coords_zonev [list $xsup_zone [expr $ysup+$ht_dessus] $xinf_zone [expr $yinf-$ht_dessous+1]]
    ## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
    #::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
    buf$audace(bufNo) window $coords_zonev
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
  
    ## On binne sur les colonnes dans la r�gion de l'image au dessus du spectre et on sauvegarde le r�sultat dans ${filenamespc_spatial}_spsup	        
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"	
    buf$audace(bufNo) biny $ysup [expr $ysup+$ht_dessus-1] 1
    ## Pond�ration par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"

    ## Calcul une moyenne du fond du ciel prit dessus et dessous le spectre.
    ::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
    ##~~~~~ BUG ICI
    # buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0
    
    ## Petites feintes : on multiplie l'image pr�c�dente par -0.5 pour avoir une moyenne, le chiffre n�gatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant � cette image : le spectre !
    buf$audace(bufNo) mult -1
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
    ## Initialisation des mots-clef spectroscopie
    buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
    buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
    #buf$audace(bufNo) setkwd [list "CRPIX1" "1" int "" ""]
    #buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
    buf$audace(bufNo) bitpix float

    ## On sauvegarde le spectre avec correction du fond du ciel
    ::console::affiche_resultat "Profil de raies sauv� sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"

    ::console::affiche_resultat "Extraction des valeurs et �criture du fichier ascii $filenamespc_spatial${extsp}\n"
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
# Profil d'intensit� d'une ligne de pixels d'ordonn�e y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 13-05-2006
# Date de mise a jour : 13-05-2006                       
# Arguments : fichier fits du spectre spatial, ordonn�e y de la ligne, ?hauteur � binner?
###############################################################

proc spc_profily { args } {
    global audace
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
	    ::console::affiche_erreur "Usage: spc_profily image_fits ordonn�e_y_de_la_ligne ?hauteur � binner?\n\n"
	    return 0
    	}

	#--- D�coupage de la ligne
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
	buf$audace(bufNo) setkwd [list "CRVAL1" 1.0 float "" ""]
	buf$audace(bufNo) setkwd [list "CDELT1" 1.0 float "" ""]
	buf$audace(bufNo) bitpix float
	buf$audace(bufNo) save "$audace(rep_images)/${fichier}_spcy"
	::console::affiche_resultat "Profil d'intensit� de la ligne sauv� sous ${fichier}_spcy$conf(extension,defaut)\n"
	return ${fichier}_spcy
    } else {
	::console::affiche_erreur "Usage: spc_profily image_fits ordonn�e_y_de_la_ligne ?hauteur � binner?\n\n"
    }
}
###############################################################


###############################################################
#                                              
# Profil d'intensit� d'une colonne de pixels d'abscisse x
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 07-06-2006
# Date de mise a jour : 07-06-2006                       
# Arguments : fichier fits du spectre spatial, abscisse x de la colonne, ?largeur � binner?
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
	#- Les commandes PROFILE et PROFILE2 n'acc�ptent pas les noms de fichier compliqu�s
	buf$audace(bufNo) imaseries "PROFILE2 filename=$audace(rep_images)/$nomprofil$extsp direction=y offset=$x"

	#--- Sauvegarde du profil
	#-- El�ve la premi�re ligne du fichier dat (label des colonnes)
	#- J'ai modifi� tt_user3 ligne 350 de la libtt.
	set fsortie [ file rootname [ spc_dat2fits $nomprofil$extsp ] ]
	file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${fichier}_spcx$conf(extension,defaut)"
	file delete "$audace(rep_images)/$nomprofil$extsp"
	::console::affiche_resultat "Profil d'intensit� de la ligne sauv� sous ${fichier}_spcx$conf(extension,defaut)\n"
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
	    ::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne ?largeur � binner?\n\n"
	    return 0
    	}

	#*** Meth 1
	set flag 0
	if { $flag == 1 } {
	    #--- D�coupage de la ligne
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
		#-- L'image r�sultante de la somme n'est pas un fichier FITS 1D : naxis1=1 naxis2=old_naxis2 !
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
	::console::affiche_resultat "Profil d'intensit� de la ligne sauv� sous ${fichier}_spcx$conf(extension,defaut)\n"
	return ${fichier}_spcx
    } else {
	::console::affiche_erreur "Usage: spc_profilx image_fits abscisse_x_de_la_ligne ?largeur?\n\n"
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
# Date de cr�ation : 16-02-2005
# Date de mise � jour : 16-02-2005 / 17-12-2005
# Arguments : fichier .fit du profil de raie                                  
##########################################################

proc spc_loadfit { {filenamespc ""} } {

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
      #--- M�morise le r�pertoire et nom du fichier accol�s dans la variable filenamespc
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

   # liste contenant la liste des valeurs de l'intensit�, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
   set spectre [openspc $rep_et_filename]
   #-- Ouverture meth 2 : Ajout� le 16/12/2005
   #set filename [ file tail $filenamespc ]
   #set spectre [openspc $filename]
   #--
   set profilspc(naxis2) [lindex $spectre 1]
   set profilspc(intensite) [lindex $spectre 0]
   set profilspc(pixels) ""
   set profilspc(object) "$filenamespc"

   if { [llength $spectre] == 2 } {
       # Spectre non calibr�
       for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
	   append profilspc(pixels) "$k "
       }
   } else {
       # Spectre calibr� lin�airement
       set xdepart [lindex $spectre 2]
       set xincr [lindex $spectre 3]
       for {set k 0} {$k < $profilspc(naxis2)} {incr k} {
	   set pixel [expr $xdepart+$k*$xincr]
	   append profilspc(pixels) "$pixel "
       }
   }

   ## Appel de la procedure d'affichage de graphique "pvisu" dans le fichier spc_gui.tcl 
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


