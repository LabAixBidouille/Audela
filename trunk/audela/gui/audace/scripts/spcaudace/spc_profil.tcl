####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 31-01-2005
# Arguments : nom du fichier du spectre spatial
# Chargement en script : source $audace(rep_scripts)/spcaudace/spc_profil.tcl
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
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

proc spc_extract_profil_zone { {filenamespc_spacial ""} } {

    #****************************************************************#
    ## Chargement : source $audace(rep_scripts)/profil_raie.tcl
    ## Les var nommees audace_* sont globales
    global audace
    ## flag audace

    global flag_ok


    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc
    set filespacialspc [ file rootname $filenamespc_spacial ]
    #set filespacialspc $filenamespc_spacial
    ::console::affiche_resultat "Fichier traite : $filespacialspc \n"

    ## Verif existence
    #if {[file exist [file join $audace(rep_images)/$filespacialspc.$conf(extension,defaut)]]==1} {
	::console::affiche_resultat "Usage : extreact_profil_zone profil_raie\n"
	::console::affiche_resultat "Chargement du fichier $filespacialspc...\n"
	loadima $filespacialspc
	## Algo
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
	buf$audace(bufNo) save ${filespacialspc}_zone
	#saveima ${filespacialspc}_zone
	
	##--------------- Traitement de la zone selectionnee -------------------#
	set listcoords [list $ht_spectre $yinf $ysup $xinf_zone $xsup_zone $ht_dessous $ht_dessus 7]
	spc_bin ${filespacialspc}_zone ${filespacialspc} $listcoords
   #}
}
###############################################################


###############################################################
#                                              
# Extraction du profil a partir du spectre x,y en mode texte et autosélection de zone 
#
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 27-08-2005
# Date de mise a jour : 29-08-2005/27-12-05                                              
# Arguments : fichier fits du spectre spatial
###############################################################

proc spc_profil { args } {

    global audace
    global conf

    # Retire l'extension .fit du nom du fichier
    # regsub -all .fit $filespacialspc - filespatialspc

    if {[llength $args] == 1} {    
	#if {[file exist [file join $audace(rep_images)/$filespacialspc.$conf(extension,defaut)]]==1} 
	set filespacialspc [ file rootname [lindex $args 0] ]
	# buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spacial"
	## 07/01/05
	buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
	set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]

	## Cree une liste de nom coords contenant les coordonnes d'un rectangle scroole avec la souris (demarre a 0)	
	set gauss_params [ spc_detect $filenamespc_spacial ]
	#buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spacial"
	## 07/01/05
	buf$audace(bufNo) load "$audace(rep_images)/$filespacialspc"
	set ycenter [ lindex $gauss_params 0 ] 
	set largeur [ lindex $gauss_params 1 ]
	#set y1 [expr int($ycenter-0.5*$largeur)]
	#set y2 [expr int($ycenter+0.5*$largeur)]
	#::console::affiche_resultat "$y1 $y2\n"
	set coords_zone [list 1 [expr int($ycenter-0.5*$largeur)] $naxis1 [expr int($ycenter+0.5*$largeur)]]

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
	buf$audace(bufNo) window $coords_zone
	# ::console::affiche_resultat "$coords_zone ; ${filespacialspc}_zone\n"
	# ::audace::conserve_seuils
	buf$audace(bufNo) save "$audace(rep_images)/${filespacialspc}_zone"
	
	##--------------- Traitement de la zone selectionnee -------------------#
	set listcoords [list $ht_spectre $yinf $ysup $xinf_zone $xsup_zone $ht_dessous $ht_dessus 7]
	spc_bin "${filespacialspc}_zone" "$filespacialspc" $listcoords
   } else {
	::console::affiche_erreur "Usage: spc_profil spectre_2D_fits\n\n"
   }
}
###############################################################


###############################################################
#                                              
# Détermine le centre vertical et la largeur d'un spectre 2D
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
#                                              
# Effectue le binning de la zone selectionnee sur le spectre
# et soustrait le fond du ciel.
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
# proc spc_bin { {filenamespc_zone ""} {filespacialspc ""} {ht_spectre ""} } {

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
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_sp"


    ## ******** Calcul une moyenne du fond du ciel prit dessus et dessous le spectre ****** ##
    ##--------------- Traitement d'une zone de longueur egale a la selection et de hauteur egale a celle de l'image initiale (par la suite ce sera sur une hauteur decidee a l'avance) -------------------#

    ## Creation d'une image de largeur limiteée par xinf_zone et xsup_zone et d'une hauteur ysup-yinf+ht_dessus+ht_dessous
    set coords_zonev [list $xsup_zone [expr $ysup+$ht_dessus] $xinf_zone [expr $yinf-$ht_dessous+1]]
    ## ::console::affiche_resultat "Coords_zone : $coords_zone\n"
    #::console::affiche_resultat "${filenamespc_spatial} ; Coords_zonev : $coords_zonev, ht_sup : $ht_dessus, ht_inf : $ht_dessous\n"
    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc_spatial"
    buf$audace(bufNo) window $coords_zonev
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_zonev"
  
    ## On binne sur les colonnes dans la région de l'image au dessus du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spsup	        
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"	
    buf$audace(bufNo) biny $ysup [expr $ysup+$ht_dessus-1] 1
    ## Pondération par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessus]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spsup"

    ## On binne sur les colonnes dans la région de l'image au dessous du spectre et on sauvegarde le résultat dans ${filenamespc_spatial}_spinf
    ::console::affiche_resultat "Binning des colonnes.\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_zonev"
    buf$audace(bufNo) biny $yinf [expr $yinf-$ht_dessous+1] 1
    ## Pondération par la hauteur en pixels
    buf$audace(bufNo) mult [expr 1.0/$ht_dessous]
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spinf"

    ## Calcul une moyenne du fond du ciel prit dessus et dessous le spectre.
    ::console::affiche_resultat "Calcul de la moyenne du fond du ciel pris dessus et dessous l'image...\n"
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spsup"
    ##~~~~~ BUG ICI
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_spinf" 0
    
    ## Petites feintes : on multiplie l'image précédente par -0.5 pour avoir une moyenne, le chiffre négatif permettant d'obtenir spectre-fond de ciel simplement en ajoutant à cette image : le spectre !
    buf$audace(bufNo) mult -0.5
    buf$audace(bufNo) add "$audace(rep_images)/${filenamespc_spatial}_sp" 0
    ## Initialisation des mots-clef spectroscopie
    buf$audace(bufNo) setkwd [list "CRVAL1" "1" int "" ""]
    buf$audace(bufNo) setkwd [list "CDELT1" "1" float "" ""]
    buf$audace(bufNo) setkwd [list "CRPIX1" "1" int "" ""]
    buf$audace(bufNo) setkwd [list "CTYPE1" "LINEAR" string "" ""]
    buf$audace(bufNo) bitpix float

    ## On sauvegarde le spectre avec correction du fond du ciel
    ::console::affiche_resultat "Profil de raies sauvé sous ${filenamespc_spatial}_spc$conf(extension,defaut)\n"
    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc_spatial}_spc"

    ::console::affiche_resultat "Extraction des valeurs et écriture du fichier ascii $filenamespc_spatial${extsp}\n"
    #loadima ${filenamespc_spatial}_spc
    buf$audace(bufNo) load "$audace(rep_images)/${filenamespc_spatial}_spc"
    buf$audace(bufNo) imaseries "PROFILE filename=${filenamespc_spatial}_spc$extsp direction=x offset=1"
    #buf1 imaseries "PROFILE filename=$audace(rep_images)/${filenamespc_spatial}.$extsp direction=x offset=1"

    ##------- Effacement des fichiers temporaires ----------##
    ## ${filenamespc_spatial}_zone ${filenamespc_spatial}_sp ${filenamespc_spatial}_spsup ${filenamespc_spatial}_spinf ${filenamespc_spatial}_profil 
    # catch {file delete -force "${filenamespc_spatial}_zone ${filenamespc_spatial}_sp ${filenamespc_spatial}_spsup ${filenamespc_spatial}_spinf ${filenamespc_spatial}_profil"}
    #--- Suppression des fichiers intermediaires
    ## $conf(extension_default)
    ::console::affiche_resultat "Effacement des fichiers temporaires...\n"

    #file delete [ file join [ file rootname $filenamespc_spatial ]_sp$conf(extension,defaut) ]
    #file delete [ file join [ file rootname $filenamespc_spatial ]_spinf$conf(extension,defaut) ]
    #file delete [ file join [ file rootname $filenamespc_spatial ]_spsup$conf(extension,defaut) ]
    #file delete [ file join [ file rootname $filenamespc_spatial ]_zone$conf(extension,defaut) ]
    #file delete [ file join [ file rootname $filenamespc_spatial ]_zonev$conf(extension,defaut) ]
    file delete $audace(rep_images)/${filenamespc_spatial}_sp$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_spinf$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_spsup$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_zone$conf(extension,defaut)
    file delete $audace(rep_images)/${filenamespc_spatial}_zonev$conf(extension,defaut)

    buf$audace(bufNo) bitpix short
    return ${filenamespc_spatial}_spc
    ## Tracer du profil de raie I=f(x)
    # trace_spec()
    #} else {
	#	::console::affiche_resultat "Le fichier n'existe pas.\n"
    #}
}
###############################################################



###############################################################
#                                              
# Extraction du profil a partir du spectre 2D 
#                                              
# Arguments : fichier fits du spectre spatial
#
###############################################################

proc extract_profil_line { {filenamespc_spacial ""} } {
    ::console::affiche_resultat "Rien.\n"
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

   # liste contenant la liste des valeurs de l'intensité, NAXIS1, CRVAL1, CDELT1, CRPIX1, CTYPE1.
   set spectre [openspc $rep_et_filename]
   #-- Ouverture meth 2 : Ajouté le 16/12/2005
   #set filename [ file tail $filenamespc ]
   #set spectre [openspc $filename]
   #--
   set profilspc(naxis2) [lindex $spectre 1]
   set profilspc(intensite) [lindex $spectre 0]
   set profilspc(pixels) ""
   set profilspc(object) "$filenamespc"

   if { [llength $spectre] == 2 } {
       # Spectre non calibré
       for {set k 1} {$k <= $profilspc(naxis2)} {incr k} {
	   append profilspc(pixels) "$k "
       }
   } else {
       # Spectre calibré linéairement
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

