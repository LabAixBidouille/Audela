#
# Fichier : mauclaire.tcl
# Description : Scripts pour un usage aise des fonctions d'Aud'ACE
# Auteur : Benjamin MAUCLAIRE (bmauclaire@underlands.org)
#
# Mise a jour $Id: mauclaire.tcl,v 1.17 2008-02-04 22:47:28 robertdelmas Exp $
#

#
##--------------------- Liste des fonctions -----------------------------------#
#
# bm_ls                  : Liste les fichiers fits du r�pertoire de travail
# bm_sphot               : Extrait le contenu d'un mot clef d'une serie de fichiers
# bm_ovakwd              : Ajoute et initialise un mot clef et sa valeur pour les spectres LHIRES
# bm_addmotcleftxt       : Ajoute et initialise un mot clef et sa valeur
# bm_autoflat            : Trouve le temps de pose optimal pour faire un flat d'une intensite moyenne donnee
# bm_extractkwd          : Extrait le contenu d'un mot clef d'une serie de fichiers
# bm_datefrac            : Calcule la fraction de jour et retourne une date JJ.jjj-mm-yyyy
# bm_datefile            : Reconstitue la date jjmmyyyy de prise de vue d'un fichier fits
# bm_correctprism        : Met a la norme libfitsio les fichiers FITS issus de PRiSM
# bm_extract_radec       : Extrait le RA et DEC d'une image ou l'astrometrie est realisee
# bm_goodrep             : Se met dans le repertoire de travail d'Aud'ACE pour eviter de
#                          mettre le chemin des images devant chaque image
# bm_renumfile           : Renome les fichiers de numerotation collee au nom
# bm_renameext           : Renome l'extension de fichiers en extension par defaut d'Aud'ACE
# bm_registerplin        : Registration planetaire sur un point initial et final : translation lineaire
# bm_sflat               : Cree un flat synthetique (image d'intensite uniforme) de nxp pixels
# bm_pretraittot         : Effectue le pretraitement, l'appariement et les sommes d'une serie d'images brutes
# bm_pretrait            : Effectue le pretraitement d'une serie d'images brutes
# bm_register            : Effectue la registration d'une serie d'images brutes
# bm_sadd0               : Effectue la somme d'une serie d'images
# bm_sadd                : Effectue la somme d'une serie d'images
# bm_smed                : Effectue la somme mediane d'une serie d'images
# bm_smea                : Effectue la somme moyenne d'une serie d'images
# bm_somes               : Effectue la somme moyenne, mediane et ssk d'une serie d'images appariees
# bm_fwhm                : Calcule la largeur equivalente d'une etoile en secondes d'arc
# bm_cutima              : Decoupage d'une zone selectionnee a la souris d'une image chargee
# bm_zoomima             : Zoom de l'image ou d'une partie selectionnee de l'image chargee
# bm_exptime             : Calcule la duree totale d'exposition d'une serie
#-----------------------------------------------------------------------------#



###############################################################################
# Description : liste les fichiers du repertoire de travail
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-05-2007
# Date de mise a jour : 03-05-2007
# Arguments : aucun
###############################################################################

proc bm_ls { args } {
   global conf audace

   set nbargs [ llength $args ]
   if { $nbargs <= 1 } {
      if { $nbargs == 1 } {
         set prefixe [ lindex $args 0 ]
         set fliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $prefixe*$conf(extension,defaut) ] ]
      } elseif { $nbargs == 0 } {
         set fliste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]
      } else {
         console::affiche_erreur "Usage: bm_ls ?string_searched?\n"
         return ""
      }
      ::console::affiche_resultat "$fliste\n\n"
   } else {
      console::affiche_erreur "Usage: bm_ls ?string_searched?\n"
   }
}
#*****************************************************************************#



###############################################################################
# Description : Extrait le contenu d'un mot clef d'une serie de fichiers
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2007
# Date de mise a jour : 27-02-2007
# Arguments : nom generique, {x1 y1 x2 y2}, graphique_png (o/n)
###############################################################################

proc bm_sphot { args } {
   global audace spcaudace
   global conf
   global tcl_platform
   global flag_ok

   set fileout "photom_serie"
   set nbargs [ llength $args ]
   if { $nbargs<=3 } {
      if { $nbargs==1 } {
         set nom_generique [ lindex $args 0 ]
         set flag_png "n"
      } elseif { $nbargs==2 } {
         set nom_generique [ lindex $args 0 ]
         set flag_png [ lindex $args 1 ]
      } elseif { $nbargs==3 } {
         set nom_generique [ lindex $args 0 ]
         set flag_png [ lindex $args 1 ]
         set coords_zone [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: bm_sphot nom_generique_fichiers ?[[?graphique_png (o/n)?] ?{x1 y1 x2 y2}?] ?\n"
         return 0
      }

      #--- Initialsie la lste des fichiers :
      #set liste_images [ glob ${nom_generique}*$conf(extension,defaut) ]
      #set liste_images [ lsort -dictionary [glob ${nom_generique}*$conf(extension,defaut)] ]
      set liste_images [ lsort -dictionary [glob -dir $audace(rep_images) -tails ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

      if { $nbargs<=2 } {
         #--- Creation de la zone de mesures :
         set fichier1 [ lindex $liste_images 0 ]
         loadima $fichier1
         set flag_ok 0
         #-- Creation de la fenetre
         if { [ winfo exists .benji ] } {
            destroy .benji
         }
         toplevel .benji
         wm geometry .benji
         wm title .benji "Get zone"
         wm transient .benji .audace
         #-- Textes d'avertissement
         label .benji.lab -text "S�lectionnez l'objet � suivre (bo�te petite)"
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
         if { $flag_ok==1 } {
            set coords_zone [ ::confVisu::getBox $audace(visuNo) ]
            set flag_ok 2
            destroy .benji
         } elseif { $flag_ok==2 } {
            set flag_ok 2
            destroy .benji
            return 0
         }
      }
      #::console::affiche_resultat "$coords_zone\n"

      #--- Ouvre le fichier ascii de d'enregistrement :
      set file_id [open "$audace(rep_images)/${fileout}.dat" w+]
      foreach fichier $liste_images {
         console::affiche_resultat "Traitement du fichier $fichier...\n"
         buf$audace(bufNo) load "$audace(rep_images)/$fichier"
         set heure [ split [ lindex [buf$audace(bufNo) getkwd "TIME-OBS"] 1 ] ":" ]
         set h [ lindex $heure 0 ]
         set min [ expr [ lindex $heure 1 ]/60. ]
         set sec [ expr [ lindex $heure 2 ]/3600. ]
         set lheure [ expr $h+$min+$sec ]
         #- Meth 1 : pb si images saturees (ne calcule que sur 1 pixel)
         #set mesure [ buf$audace(bufNo) phot $coords_zone ]
         #set fluxrelatif [ lindex $mesure 0 ]
         #set fluxfdc [ lindex $mesure 2 ]
         #set fluxabsolu [ expr $fluxrelatif+$fluxfdc ]
         #- Meth 2 : resultats tres variables selon la zone selectionnee
         #set mesure [ buf$audace(bufNo) stat $coords_zone ]
         #set intensite_moyenne [ lindex $mesure 4 ]
         #set intensite_fdc_moyenne [ lindex $mesure 6 ]
         #set fluxrelatif [ expr $intensite_moyenne-$intensite_fdc_moyenne ]
         #- Meth 3 : ma sauce a moi
         set mesure [ buf$audace(bufNo) flux $coords_zone ]
         set intensite_totale [ lindex $mesure 0 ]
         set nbpixels [ lindex $mesure 1 ]
         set intensite_moyenne [ expr $intensite_totale/$nbpixels ]
         set intensite_fdc [ lindex [ buf$audace(bufNo) stat ] 6 ]
         set fluxrelatif [ expr $intensite_moyenne-$intensite_fdc ]
         puts $file_id "$lheure\t$fluxrelatif\r"
      }
      close $file_id

      if { $flag_png=="o" } {
         #--- Creation du fichier batch pour Gnuplot :
         set file_id [open "$audace(rep_images)/${fileout}.gp" w+]
         set titre "Evolution du flux relatif au cours du temps"
         set legendex "Heure (h)"
         set legendey "Flux (ADU)"
         puts $file_id "call \"$spcaudace(repgp)/gp_points.cfg\" \"$audace(rep_images)/${fileout}.dat\" \"$titre\" * * * * * \"$audace(rep_images)/${fileout}.png\" \"$legendex\" \"$legendey\" "
         close $file_id

         #--- Trace du graphique png :
         if { $tcl_platform(os)=="Linux" } {
            set answer [ catch { exec gnuplot $audace(rep_images)/${fileout}.gp } ]
            ::console::affiche_resultat "gnuplot r�sultat : $answer\n"
         } else {
            set answer [ catch { exec $spcaudace(repgp)/gpwin32/pgnuplot.exe $audace(rep_images)/${fileout}.gp } ]
            ::console::affiche_resultat "gnuplot r�sultat : $answer\n"
         }
      }

      #--- Message de fin :
      file delete -force "$audace(rep_images)/${fileout}.gp"
      ::console::affiche_resultat "Donn�es enregistr�es dans le fichier $audace(rep_images)/${fileout}.dat et graphique sauv� sous ${fileout}.png\n"
      return ${fileout}.dat
   } else {
      ::console::affiche_erreur "Usage: bm_sphot nom_generique_fichiers ?[[?graphique_png (o/n)?] ?{x1 y1 x2 y2}?] ?\n"
   }
}
#****************************************************************************#

###################################################################
# Description : Ajoute et initialise un mot clef et sa valeur pour les spectres LHIRES
# Auteur : Benjamin MAUCLAIRE
# Date creation : 6-01-2007
# Date modification : 6-01-2007
# 06-01-07 : ne gere que des string comme valeur de mot clef
# Arguments : fichier_fits nom_motclef_a_jouter nb_traits_reseau
###################################################################

proc bm_ovakwd { args } {
   global conf
   global audace

   set type "string"
   if { [ llength $args ] == 2 } {
      set fichier [ lindex $args 0 ]
      set reso [ lindex $args 1 ]
      set date [ bm_datefile $fichier ]

      #bm_addmotcleftxt $fichier INSTRUME "Audine KAF1602E" "System which created data" "float"
      bm_addmotcleftxt $fichier CAMERA "Audine KAF1602E" "System which created data" "float"
      bm_addmotcleftxt $fichier EQUIPMEN "LHIRES3 $reso l/mm" "System which created data via the camera" "float"
      bm_addmotcleftxt $fichier TELESCOP "SCT 0.3m" "Telescop" "float"
      bm_addmotcleftxt $fichier CREATOR "SpcAudACE $date" "Software that create this FITS file" "float"
      bm_addmotcleftxt $fichier ORIGIN "O.V.A. Observatoire du Val de l Arc" "Origin place of FITS image" "float"
      bm_addmotcleftxt $fichier OBSERVER "Benjamin MAUCLAIRE" "Observer name" "float"
   } else {
      ::console::affiche_erreur "Usage: bm_ovakwd fichier_fits nb_traits_reseau\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Ajoute et initialise un mot clef et sa valeur
# Auteur : Benjamin MAUCLAIRE
# Date creation : 6-01-2007
# Date modification : 6-01-2007
# 06-01-07 : ne gere que des string comme valeur de mot clef
# Arguments : fichier_fits nom_motclef_a_jouter "valeur_mot" "description mot clef"
###############################################################################

proc bm_addmotcleftxt { args } {
   global conf
   global audace

   set type "string"
   if { [ llength $args ] == 3 || [ llength $args ] == 4 || [ llength $args ] == 5 } {
      if { [ llength $args ] == 3 } {
         set fichier [ lindex $args 0 ]
         set nom_mot_clef [ lindex $args 1]
         set val_mot_clef [ lindex $args 2 ]
         set legende ""
         set type_data "short"
      } elseif { [ llength $args ] == 4 } {
         set fichier [ lindex $args 0 ]
         set nom_mot_clef [ lindex $args 1]
         set val_mot_clef [ lindex $args 2 ]
         set legende [ lindex $args 3 ]
         set type_data "short"
      } elseif { [ llength $args ] == 5 } {
         set fichier [ lindex $args 0 ]
         set nom_mot_clef [ lindex $args 1]
         set val_mot_clef [ lindex $args 2 ]
         set legende [ lindex $args 3 ]
         set type_data [ lindex $args 4 ]
      } else {
         ::console::affiche_erreur "Usage: bm_addmotcleftxt fichier_fits nom_motclef_a_jouter \"valeur_mot\" ?[[?\" description mot clef\" ?] ?type_donn�es (float/short)?]?\n\n"
         return 0
      }

      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      buf$audace(bufNo) setkwd [ list "$nom_mot_clef" "$val_mot_clef" $type "$legende" "" ]

      if { [ llength $args ] == 5 } {
         if { $type_data=="float" } {
            buf$audace(bufNo) bitpix float
         } elseif { $type_data=="short" } {
            buf$audace(bufNo) bitpix short
         }
      }

      buf$audace(bufNo) save "$audace(rep_images)/$fichier"
      buf$audace(bufNo) bitpix short
   } else {
      ::console::affiche_erreur "Usage: bm_addmotcleftxt fichier_fits nom_motclef_a_jouter \"valeur_mot\" ?[[?\" description mot clef\" ?] ?type_donn�es_image (float/short)?]?\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Trouve le temps de pose optimal pour faire un flat d'une intensite moyenne donnee
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-11-2006
# Date de mise a jour : 28-11-2006
# Arguments : valeur moeynne desiree
###############################################################################

proc bm_autoflat { args } {
   global audace
   global conf

   if { [llength $args] == 4 } {
      set valmoy [ lindex $args 0 ]
      set tolerance [ lindex $args 1]
      set dureeini [ lindex $args 2 ]
      set binning [ lindex $args 3 ]

      #--- Conseil d'utilisation :
      console::affiche_resultat "\n*** Durant la proc�dure, il est n�cessire de maintenir constant l'�clairement du t�lescope. ***\n\n"

      #-- Premiere acquisition :
      console::affiche_resultat "Premi�re pose : ${dureeini}s...\n"
      cam$audace(camNo) bin [ list $binning $binning ]
      cam$audace(camNo) exptime $dureeini
      cam$audace(camNo) acq
      vwait status_cam$audace(camNo)
      set moymes [ lindex [ buf$audace(bufNo) stat ] 6 ]
      set testval [ expr $valmoy-$moymes ]
      console::affiche_resultat "Premi�re valeur moyenne : $moymes\n"
      set duree $dureeini

      #--- Boucle de recherche du temps par division ou multiplication par 2 du temps de pose
      #bind all <Key-Escape> "::autoguider::stopSuivi  $visuNo"
      while { [expr abs($testval) ]!=0 } {
         if { $testval==0 || [expr abs($testval)]<=$tolerance } {
            console::affiche_resultat "\n\nLa pose id�ale pour un flat de $moymes ADU vaut $duree\n"
            return $duree
         } elseif { [expr abs($testval)]>$tolerance && $testval>0 } {
            #set duree [ expr $duree*(1+pow(0.5,$i)) ]
            set duree [ expr $duree*(1.+$moymes/$valmoy) ]
            console::affiche_resultat "Augmentation de la pose : ${duree}s...\n"
            cam$audace(camNo) exptime $duree
            cam$audace(camNo) acq
            vwait status_cam$audace(camNo)
            set moymes [ lindex [ buf$audace(bufNo) stat ] 6 ]
            set testval [ expr $valmoy-$moymes ]
            console::affiche_resultat "Valeur moyenne : $moymes ; Dur�e : $duree\n"
         } elseif { [expr abs($testval)]>$tolerance && $testval<0 } {
            #-- Good 1 :
            #set duree [ expr $duree*(1-pow(0.5,$j)) ]
            #set duree [ expr $duree*(1-$moymes/$valmoy) ]
            set duree [ expr $duree/($moymes/$valmoy) ]
            console::affiche_resultat "Diminution de la pose : ${duree}s...\n"
            cam$audace(camNo) exptime $duree
            cam$audace(camNo) acq
            vwait status_cam$audace(camNo)
            set moymes [ lindex [ buf$audace(bufNo) stat ] 6 ]
            set testval [ expr $valmoy-$moymes ]
            console::affiche_resultat "Valeur moyenne : $moymes ; Dur�e : $duree\n"
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_autoflat valeur_moyenne_recherchee tolerance duree_exposition_depart binning.\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Extrait le contenu d'un mot clef d'une serie de fichiers
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-11-2006
# Date de mise a jour : 15-11-2006
# Arguments : nom generique, fichier_txt_sortie, mot clef header fits
###############################################################################

proc bm_extractkwd { args } {
   global audace
   global conf

   if { [llength $args] == 3 } {
      set nom_generique [ lindex $args 0 ]
      set fileout [ lindex $args 1 ]
      set motclef [ lindex $args 2 ]

      #--- Initialsie la lste des fichiers :
      #set liste_images [ glob ${nom_generique}*$conf(extension,defaut) ]
      set liste_images [ lsort -dictionary [glob ${nom_generique}*$conf(extension,defaut)] ]

      #--- Ouvre le fichier ascii de d'enregistrement :
      set file_id [open "$audace(rep_images)/$fileout.txt" w+]

      foreach fichier $liste_images {
         console::affiche_resultat "Traitement du fichier $fichier...\n"
         buf$audace(bufNo) load "$audace(rep_images)/$fichier"
         set ra [lindex [buf$audace(bufNo) getkwd "OBJCTRA"] 1]
         set dec [lindex [buf$audace(bufNo) getkwd "OBJCTDEC"] 1]
         set alt [lindex [buf$audace(bufNo) getkwd "OBJCTALT"] 1]
         set az [lindex [buf$audace(bufNo) getkwd "OBJCTAZ"] 1]
         set ha [lindex [buf$audace(bufNo) getkwd "OBJCTHA"] 1]
         set mot [lindex [buf$audace(bufNo) getkwd "$motclef"] 1]
         puts $file_id "$ra $dec $alt $az $ha $mot"
      }
      close $file_id

      #--- Message de fin :
      ::console::affiche_resultat "Donn�es enregistr�es dans le fichier $audace(rep_images)/$fileout.txt\n"
   } else {
      ::console::affiche_erreur "Usage: bm_extractkwd nom_generique_fichiers fichier_ascii_de_sortie mot_header_fits.\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Calcule la fraction de jour et retourne une date JJ.jjj-mm-yyyy
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-08-2006
# Date de mise a jour : 28-08-2006
# Arguments : nom fichier fits
###############################################################################

proc bm_datefrac { args } {
   global audace
   global conf

   if { [llength $args] == 1 } {
      set fichier [lindex $args 0]

      #--- CApture la date de l'entete fits
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      set ladate [lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1]
      #-- Exemple de date : 2006-08-22T01:37:34.46

      #--- Isole l'annee, le moi, le jour, l'heure, les minutes et les secondes
      #-- Meth1 :
      # regexp {([0-9][0-9][0-9][0-9])\-.} $ladate match y
      # regexp {[0-9][0-9][0-9][0-9]\-([0-9][0-9])\-.} $ladate match mo
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-([0-9][0-9])T.} $ladate match d
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]T([0-9][0-9]).} $ladate match h
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]T[0-9][0-9]:([0-9][0-9]).} $ladate match mi
      # regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:([0-9][0-9]).} $ladate match s
      #-- Meth2 :
      set ldate [ mc_date2ymdhms $ladate ]
      set y [ lindex $ldate 0 ]
      set mo [ lindex $ldate 1 ]
      set d [ lindex $ldate 2 ]
      set h [ lindex $ldate 3 ]
      set mi [ lindex $ldate 4 ]
      set s [ lindex $ldate 5 ]

      #--- Calcul la fraction de jour :
      set dfrac [ expr $d+$h/24.0+$mi/1440.0+$s/86400.0 ]

      #-- Ne tient compte que des 3 premieres decimales
      set cdfrac [ expr round($dfrac*1000.)/1000. ]

      #--- Affichage du resultat :
      ::console::affiche_resultat "La fraction de date est : $cdfrac/$mo/$y\n"
      return $cdfrac/$mo/$y
   } else {
      ::console::affiche_erreur "Usage: bm_datefrac nom_fichier_fits.\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Reconstitue la date jjmmyyyy de prise de vue d'un fichier fits
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-01-2007
# Date de mise a jour : 03-01-2007
# Arguments : nom fichier fits
###############################################################################

proc bm_datefile { args } {
   global audace
   global conf

   if { [llength $args] == 1 } {
      set fichier [lindex $args 0]

      #--- Capture la date de l'entete fits
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      set ladate [lindex [buf$audace(bufNo) getkwd "DATE-OBS"] 1]
      #-- Exemple de date : 2006-08-22T01:37:34.46

      #-- Meth2 :
      set ldate [ mc_date2ymdhms $ladate ]
      set y [ lindex $ldate 0 ]
      set mo [ lindex $ldate 1 ]
      set d [ lindex $ldate 2 ]
      set h [ lindex $ldate 3 ]
      set mi [ lindex $ldate 4 ]
      set s [ lindex $ldate 5 ]

      #--- Gestion des valeurs <=9 :
      if { [ expr $d/10. ] < 1. } {
         set d "0$d"
      }
      if { $mo<10 } {
         set mo "0$mo"
      }


      #--- Concatenation :
      set madate "$y$mo$d"

      #--- Affichage du resultat :
      ::console::affiche_resultat "La date de prise de vue est : $madate\n"
      return $madate
   } else {
      ::console::affiche_erreur "Usage: bm_datefile nom_fichier_fits.\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Met a la norme libfitsio les fichiers FITS issus de PRiSM
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-06-2006
# Date de mise a jour : 20-06-2006
# Arguments : nom generique
###############################################################################

proc bm_correctprism { args } {
   global audace
   global conf

   set ext ".fts"
   if { [llength $args] == 1 } {
      set nom_generique [lindex $args 0]

      #--- Renome l'extension pour bifsconv :
      set liste_fichiers [ lsort -dictionary [glob -dir $audace(rep_images) -tails ${nom_generique}\[0-9\]*$conf(extension,defaut)] ]
      set nbimg [ llength $liste_fichiers ]
      ::console::affiche_resultat "Renomage de $nbimg fichiers...\n"
      foreach fichier $liste_fichiers {
         set prefixe_nom [ file rootname $fichier ]
         #::console::affiche_resultat "${fichier} renom� en ${prefixe_nom}_c$conf(extension,defaut)\n"
         file rename -force $audace(rep_images)/$fichier $audace(rep_images)/${prefixe_nom}_c$ext
      }

      #--- Netoyage header fits avec bifsconv :
      ::console::affiche_resultat "Netoyage header fits avec bifsconv...\n"
      set liste_fichiers2 [ lsort -dictionary [glob -dir $audace(rep_images) -tails ${nom_generique}\[0-9\]*$ext] ]
      foreach fichier $liste_fichiers2 {
         set fichier [ file rootname  $fichier ]
         #bifsconv $fichier
         buf$audace(bufNo) load $audace(rep_images)/$fichier$conf(extension,defaut)
         buf$audace(bufNo) setkwd { COMMENT 0 int "" "" }
         buf$audace(bufNo) save $audace(rep_images)/$fichier$conf(extension,defaut)
      }

      #--- Fin script
      ::console::affiche_resultat "Fin de mise en conformit� des fichiers FITS de Prims.\n"
   } else {
      ::console::affiche_erreur "Usage: bm_correctprism nom_generique_fichiers_FITS_a_cooriger.\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Extrait le RA et DEC d'une image ou l'astrometrie est realisee
# Auteur : Benjamin MAUCLAIRE
# Date creation : 24-01-2006
# Date de mise a jour : 24-01-2006
# Arguments : aucun
###############################################################################

proc bm_extract_radec {} {
   global audace
   global conf

   # Par defaut, travaille dans le rep images configure dans Aud'ACE
   # Ne demande aucun arguments
   set file_id [open "$audace(rep_images)/coordonnees.txt" w+]
   set liste_fichiers [ glob *.fit ]

   foreach fichier $liste_fichiers {
      buf$audace(bufNo) load $audace(rep_images)/$fichier
      # RA of center of the image
      set ra [lindex [buf$audace(bufNo) getkwd "OBJCTRA"] 1]
      # DEC of center of the image
      set dec [lindex [buf$audace(bufNo) getkwd "OBJCTDEC"] 1]
      puts $file_id "$ra $dec"
   }
   close $file_id
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Se met dans le repertoire de travail d'Aud'ACE pour eviter de
# mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-12-2005
# Date de mise a jour : 17-12-2005
# Arguments : aucun
###############################################################################

proc bm_goodrep {} {
   global audace
   global conf

   set repdflt [pwd]
   cd $audace(rep_images)
   return $repdflt
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Renome les fichiers de numerotation collee au nom
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-12-2005
# Date de mise a jour : 16-12-2005
# Arguments : nom generique
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
          ::console::affiche_resultat "Copie de $fichier de num�ro $numero vers sortie/${pref_nom_generique}-$numero$conf(extension,defaut)\n"
          file copy ${fichier} sortie/${pref_nom_generique}-$numero$conf(extension,defaut)
      }
      ::console::affiche_resultat "Fichiers renom�s dans le r�pertoire sortie.\n"
   } else {
      ::console::affiche_erreur "Usage: bm_renumfile nom_generique de fichier � la num�rotation coll�e.\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Renome l'extension de fichiers en extension par defaut d'Aud'ACE
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-12-2005
# Date de mise a jour : 17-12-2005
# Arguments : ?repertoire? extension actuelle des fichiers
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
      } else {
         ::console::affiche_erreur "Usage: bm_renameext ?repertoire? extension_actuelle.\n"
      }


      cd $repertoire
      set liste_fichiers [ lsort -dictionary [glob -dir $repertoire *$old_extension] ]
      set nbimg [ llength $liste_fichiers ]
      ::console::affiche_resultat "$nbimg fichiers � renomer.\n"

      foreach fichier $liste_fichiers {
         #regexp {(.+)\.$old_extension} $fichier match prefixe_nom
         set prefixe_nom [ file rootname $fichier ]
         ::console::affiche_resultat "${fichier} renom� en ${prefixe_nom}_c$conf(extension,defaut)\n"
         file copy -force $fichier ${prefixe_nom}_c$conf(extension,defaut)
      }
      cd $repdflt
   } else {
      ::console::affiche_erreur "Usage: bm_renameext ?repertoire? extension_actuelle.\n"
   }
}
#-----------------------------------------------------------------------------#


###############################################################################
# Description : Renome l'extension de fichiers en extension par defaut d'Aud'ACE
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-12-2005
# Date de mise a jour : 17-12-2005
# Arguments : ?repertoire? extension actuelle des fichiers
###############################################################################

proc bm_renameext2 { args } {
   global audace
   global conf

   if { [llength $args] == 2 } {
      set old_extension [ lindex $args 0 ]
      set new_extension [ lindex $args 1 ]

      set repertoire $audace(rep_images)
      set liste_fichiers [ lsort -dictionary [ glob -dir $repertoire *$old_extension ] ]
      set nbimg [ llength $liste_fichiers ]
      ::console::affiche_resultat "$nbimg fichiers � renomer.\n"

      foreach fichier $liste_fichiers {
         #regexp {(.+)\.$old_extension} $fichier match prefixe_nom
         set prefixe_nom [ file rootname $fichier ]
         ::console::affiche_resultat "Fichier renom� en ${prefixe_nom}.$new_extension\n"
         file copy -force $fichier ${prefixe_nom}.$new_extension
         file delete -force $fichier
      }
   } else {
      ::console::affiche_erreur "Usage: bm_renameext2 extension_actuelle(fts) nouvelle_extension(fit).\n"
   }
}
#-----------------------------------------------------------------------------#




###############################################################################
# Description : Registration planetaire sur un point initial et final : translation lineaire
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-12-2005
# Date de mise a jour : 16-12-2005
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_registerplin { args } {
   global audace
   global conf
   global flag_ok

   if {[llength $args] == 1} {
      set nom_generique [ lindex $args 0 ]
      set repdflt [bm_goodrep]

      #--- Renumerote la serie de fichier ----
      #renumerote $nom_generique
      #set liste_images [ glob ${nom_generique}*$conf(extension,defaut) ]
      set liste_images [ lsort -dictionary [glob ${nom_generique}*$conf(extension,defaut)] ]
      set nbimg [ llength $liste_images ]

      #--- Reperage du point de depart ----
      set image_depart [lindex $liste_images 0]
      loadima $image_depart
      set flag_ok 0
      #-- Creation de la fenetre
      if { [ winfo exists .benji ] } {
         destroy .benji
      }
      toplevel .benji
      wm geometry .benji
      wm title .benji "Get zone"
      wm transient .benji .audace
      #-- Textes d'avertissement
      label .benji.lab -text "S�lectionnez l'objet � suivre (bo�te petite)"
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
      if { $flag_ok==1 } {
         set coords_zone [ ::confVisu::getBox $audace(visuNo) ]
         set flag_ok 2
         destroy .benji
      } elseif { $flag_ok==2 } {
         set flag_ok 2
         destroy .benji
         return 0
      }
      #-- Determine le photocentre de la zone selectionee
      set stats [ buf$audace(bufNo) stat ]
      #set point_depart [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ]
      set point_depart [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
      ::console::affiche_resultat "Point A : $point_depart\n"

      #---------------------------------------------------------#
      #--- Reperage du point final ----
      set image_finale [lindex $liste_images [expr $nbimg-1] ]
      loadima $image_finale
      set flag_ok 0
      #-- Creation de la fenetre
      if { [ winfo exists .benji ] } {
         destroy .benji
      }
      toplevel .benji
      wm geometry .benji
      wm title .benji "Get zone"
      wm transient .benji .audace
      #-- Textes d'avertissement
      label .benji.lab -text "Selectionnez l'objet � suivre (bo�te petite)"
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
      if { $flag_ok==1 } {
         set coords_zone [ ::confVisu::getBox $audace(visuNo) ]
         set flag_ok 2
         destroy .benji
      } elseif { $flag_ok==2 } {
         set flag_ok 2
         destroy .benji
         return 0
      }
      #-- Determine le photocentre de la zone selectionee
      set stats [ buf$audace(bufNo) stat ]
      set point_final [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
      ::console::affiche_resultat "Point B : $point_final\n"

      #--- Caclul le deplacement de l'objet entre chaque image
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
      ::console::affiche_resultat "Ecart total en x : $ecart_x ; Ecart total en y : $ecart_y\n"
      set deplacement_x [ expr -1.0*$ecart_x/$nbimg ]
      set deplacement_y [ expr -1.0*$ecart_y/$nbimg ]
      ::console::affiche_resultat "D�placement moyen entre chaque image : $deplacement_x ; $deplacement_y\n"

      #--- Recalage de chaque image (sauf n�1)
      #-- le deplacement de l'objet est suppose lineaire
      #-- Isole le prefixe des noms de fichiers
      regexp {(.+)\-} $nom_generique match pref_nom_generique
      ::console::affiche_resultat "Appariement de $nbimg images...\n"
      #- trans2 est Bugge !
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
      ::console::affiche_resultat "Images recal�es sauv�es sous ${pref_nom_generique}_reg-n�$conf(extension,defaut)\n"

      #--- Somme des images :
      ::console::affiche_resultat "Somme de $nbimg images... sauv�es sous ${pref_nom_generique}_s$nbimg\n"
      sadd ${pref_nom_generique}_reg- ${pref_nom_generique}_s$nbimg $nbimg
      loadima ${pref_nom_generique}_s$nbimg
      delete2 ${pref_nom_generique}_reg- $nbimg
      cd $repdflt
   } else {
      ::console::affiche_erreur "Usage : bm_registerplin nom_generique_images\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Cree un flat synthetique (image d'intensite uniforme) de nxp pixels
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-09-2005
# Date de mise a jour : 03-12-2005
# Arguments : nom de l'image de sortie, naxis1, naxis2, valeur des pixels
# Methode : par soustraction du noir et sans offset
################################################################################

proc bm_sflat { args } {
   global audace
   global conf

   if {[llength $args] == 5} {
      set nom_flat [ lindex $args 0 ]
      set naxis1 [ lindex $args 1 ]
      set naxis2 [ lindex $args 2 ]
      set intensite [ lindex $args 3 ]
      set duree_pose [ lindex $args 4 ]

      buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 $naxis2 FORMAT_USHORT COMPRESS_NONE 0
      buf$audace(bufNo) offset $intensite
      #for {set y 1} {$y<=$naxis2} {incr y} {
         #for {set x 1} {$x<=$naxis1} {incr x} {
            #buf$audace(bufNo) setpix [ list $x $y ] $intensite
         #}
      #}
      buf$audace(bufNo) setkwd [ list NAXIS 2 int "" "" ]
      buf$audace(bufNo) setkwd [ list NAXIS1 $naxis1 int "" "" ]
      buf$audace(bufNo) setkwd [ list NAXIS2 $naxis2 int "" "" ]
      buf$audace(bufNo) setkwd [ list EXPOSURE $duree_pose int "" "s" ]
      buf$audace(bufNo) setkwd [ list BIN1 1 int "" "" ]
      buf$audace(bufNo) setkwd [ list BIN2 1 int "" "" ]
      buf$audace(bufNo) save "$audace(rep_images)/$nom_flat"
      ::console::affiche_resultat "Flat artificiel sauv� sous $nom_flat\n"
      return $nom_flat
   } else {
      ::console::affiche_erreur "Usage: bm_sflat nom_flat_sortie largeur hauteur valeur(ADU) dur�e_pose(s)\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Effectue le pretraitement, l'appariement et les sommes d'une serie d'images brutes
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-08-2005
# Date de mise a jour : 21-12-2005/31-07-2007
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu
# Methode : par soustraction du noir et sans offset
# Bug : Il faut travailler dans le rep parametre d'Aud'ACE, donc revoir toutes les operations !!
###############################################################################

proc bm_pretraittot { args } {
   global audace
   global conf

      if { [llength $args] <= 6 } {
      if { [llength $args] == 4 } {
        set nom_stellaire [ lindex $args 0 ]
        set nom_dark [ lindex $args 1 ]
        set nom_flat [ lindex $args 2 ]
        set nom_darkflat [ lindex $args 3 ]
        set offset "none"
        set rmmasters "o"
      } elseif { [llength $args] == 5 } {
        set nom_stellaire [ lindex $args 0 ]
        set nom_dark [ lindex $args 1 ]
        set nom_flat [ lindex $args 2 ]
        set nom_darkflat [ lindex $args 3 ]
        set offset [ lindex $args 4 ]
        set rmmasters "o"
      } elseif { [llength $args] == 6 } {
        set nom_stellaire [ lindex $args 0 ]
        set nom_dark [ lindex $args 1 ]
        set nom_flat [ lindex $args 2 ]
        set nom_darkflat [ lindex $args 3 ]
        set offset [ lindex $args 4 ]
        set rmmasters [ lindex $args 5 ]
      } else {
        ::console::affiche_erreur "Usage: bm_pretraittot nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?offset (none)? ?effacement des masters (o/n)?\n\n"
      }

      #--- Pretraite les images brutes
      ::console::affiche_resultat "**** Pr�traitement des images ****...\n"
      set nom_pretrait [ bm_pretrait $nom_stellaire $nom_dark $nom_flat $nom_darkflat $offset $rmmasters ]

      #--- Effectue l'appariement des images pretraitees
      ::console::affiche_resultat "\n**** Appariement des images ****...\n"
      set nbimg [ llength [ glob -dir $audace(rep_images) ${nom_pretrait}*$conf(extension,defaut) ] ]
      register $nom_pretrait ${nom_stellaire}tr- $nbimg
      delete2 $nom_pretrait $nbimg

      #--- Calcul la somme, somme moyenne, somme mediane et la somme Kappa-Sigma
      ::console::affiche_resultat "\n**** Sommes des images pr�trait�es ****...\n"
      bm_somes ${nom_stellaire}tr-
      delete2 ${nom_stellaire}tr- $nbimg

   } else {
      ::console::affiche_erreur "Usage: bm_pretraittot nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?offset (none)? ?effacement des masters (o/n)?\n\n"
   }
}
#-----------------------------------------------------------------------------#


###############################################################################
# Descirption : effectue le pr�traitement d'une s�rie d'images brutes
#
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation : 27-08-2005
# Date de mise � jour : 21-12-2005/2007-01-03/2007-07-10
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu effacement des masters (O/n)
# M�thode : par soustraction du noir et sans offset.
# Bug : Il faut travailler dans le rep parametre d'Audela, donc revoir toutes les operations !!
###############################################################################

proc bm_pretrait { args } {

   global audace
   global conf

   if {[llength $args] <= 6} {
      if {[llength $args] == 4} {
         #--- On se place dans le r�pertoire d'images configur� dans Audace
         set repdflt [ spc_goodrep ]
         set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
         set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
         set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
         set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
         set nom_offset "none"
         set flag_rmmaster "o"
      } elseif {[llength $args] == 5} {
         #--- On se place dans le r�pertoire d'images configur� dans Audace
         set repdflt [ spc_goodrep ]
         set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
         set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
         set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
         set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
         set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
         set flag_rmmaster "o"
      } elseif {[llength $args] == 6} {
         #--- On se place dans le r�pertoire d'images configur� dans Audace
         set repdflt [ spc_goodrep ]
         set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
         set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
         set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
         set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
         set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
         set flag_rmmaster [ lindex $args 5 ]
      } else {
         ::console::affiche_erreur "Usage: bm_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?nom_offset (none)? ?effacement des masters (o/n)?\n\n"
         return ""
      }


      #--- Compte les images :
      ## Renumerote chaque s�rie de fichier
      #renumerote $nom_stellaire
      #renumerote $nom_dark
      #renumerote $nom_flat
      #renumerote $nom_darkflat

      ## D�termine les listes de fichiers de chasue s�rie
      #set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_dark}\[0-9\]*$conf(extension,defaut) ] ]
      #set nb_dark [ llength $dark_liste ]
      #set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_flat}\[0-9\]*$conf(extension,defaut) ] ]
      #set nb_flat [ llength $flat_liste ]
      #set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]*$conf(extension,defaut) ] ]
      #set nb_darkflat [ llength $darkflat_liste ]
      #---------------------------------------------------------------------------------#
      if { 1==0 } {
      set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
      set nb_stellaire [ llength $stellaire_liste ]
      #-- Gestion du cas des masters au lieu d'une s�rie de fichier :
      if { [ catch { glob -dir $audace(rep_images) ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
         set dark_list [ list $nom_dark ]
         set nb_dark 1
      } else {
         set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_dark [ llength $dark_liste ]
      }
      if { [ catch { glob -dir $audace(rep_images) ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
         set flat_list [ list $nom_flat ]
         set nb_flat 1
      } else {
         set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_flat [ llength $flat_liste ]
      }
      if { [ catch { glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
         set darkflat_list [ list $nom_darkflat ]
         set nb_darkflat 1
      } else {
         set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_darkflat [ llength $darkflat_liste ]
      }
      }
      #---------------------------------------------------------------------------------#

      #--- Compte les images :
      if { [ file exists "$audace(rep_images)/$nom_stellaire$conf(extension,defaut)" ] } {
         set stellaire_liste [ list $nom_stellaire ]
         set nb_stellaire 1
      } elseif { [ catch { glob -dir $audace(rep_images) ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
         renumerote $nom_stellaire
         set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_stellaire [ llength $stellaire_liste ]
      } else {
         ::console::affiche_resultat "Le(s) fichier(s) $nom_stellaire n'existe(nt) pas.\n"
         return ""
      }
      if { [ file exists "$audace(rep_images)/$nom_dark$conf(extension,defaut)" ] } {
         set dark_liste [ list $nom_dark ]
         set nb_dark 1
      } elseif { [ catch { glob -dir $audace(rep_images) ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
         renumerote $nom_dark
         set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_dark [ llength $dark_liste ]
      } else {
         ::console::affiche_resultat "Le(s) fichier(s) $nom_dark n'existe(nt) pas.\n"
         return ""
      }
      if { [ file exists "$audace(rep_images)/$nom_flat$conf(extension,defaut)" ] } {
         set flat_list [ list $nom_flat ]
         set nb_flat 1
      } elseif { [ catch { glob -dir $audace(rep_images) ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
         renumerote $nom_flat
         set flat_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_flat [ llength $flat_list ]
      } else {
         ::console::affiche_resultat "Le(s) fichier(s) $nom_flat n'existe(nt) pas.\n"
         return ""
      }
      if { [ file exists "$audace(rep_images)/$nom_darkflat$conf(extension,defaut)" ] } {
         set darkflat_list [ list $nom_darkflat ]
         set nb_darkflat 1
      } elseif { [ catch { glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
         renumerote $nom_darkflat
         set darkflat_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_darkflat [ llength $darkflat_list ]
      } else {
         ::console::affiche_resultat "Le(s) fichier(s) $nom_darkflat n'existe(nt) pas.\n"
         return ""
      }
      if { $nom_offset!="none" } {
         if { [ file exists "$audace(rep_images)/$nom_offset$conf(extension,defaut)" ] } {
            set offset_list [ list $nom_offset ]
            set nb_offset 1
         } elseif { [ catch { glob -dir $audace(rep_images) ${nom_offset}\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
            renumerote $nom_offset
            set offset_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_offset}\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
            set nb_offset [ llength $offset_list ]
         } else {
            ::console::affiche_resultat "Le(s) fichier(s) $nom_offset n'existe(nt) pas.\n"
            return ""
         }
      }


      #--- Isole le pr�fixe des noms de fichiers dans le cas ou ils possedent un "-" avant le n� :
      set pref_stellaire ""
      set pref_dark ""
      set pref_flat ""
      set pref_darkflat ""
      set pref_offset ""
      regexp {(.+)\-?[0-9]+} $nom_stellaire match pref_stellaire
      regexp {(.+)\-?[0-9]+} $nom_dark match pref_dark
      regexp {(.+)\-?[0-9]+} $nom_flat match pref_flat
      regexp {(.+)\-?[0-9]+} $nom_darkflat match pref_darkflat
      regexp {(.+)\-?[0-9]+} $nom_offset match pref_offset
      #-- En attendant de gerer le cas des fichiers avec des - au milieu du nom de fichier
      set pref_stellaire $nom_stellaire
      set pref_dark $nom_dark
      set pref_flat $nom_flat
      set pref_darkflat $nom_darkflat
      set pref_offset $nom_offset

      ::console::affiche_resultat "brut=$pref_stellaire, dark=$pref_dark, flat=$pref_flat, df=$pref_darkflat, offset=$pref_offset\n"
      #-- La regexp ne fonctionne pas bien pavec des noms contenant des "_"
      if {$pref_stellaire == ""} {
         set pref_stellaire $nom_stellaire
      }
      if {$pref_dark == ""} {
         set pref_dark $nom_dark
      }
      if {$pref_flat == ""} {
         set pref_flat $nom_flat
      }
      if {$pref_darkflat == ""} {
         set pref_darkflat $nom_darkflat
      }
      if {$pref_offset == ""} {
         set pref_offset $nom_offset
      }
      # ::console::affiche_resultat "Corr : b=$pref_stellaire, d=$pref_dark, f=$pref_flat, df=$pref_darkflat\n"


      #--- Pr�traitement des flats :
      #-- Somme m�diane des dark, dark_flat et offset :
      if { $nb_dark == 1 } {
         ::console::affiche_resultat "L'image de dark est $nom_dark$conf(extension,defaut)\n"
         set pref_dark $nom_dark
         file copy -force $nom_dark$conf(extension,defaut) ${pref_dark}-smd$nb_dark$conf(extension,defaut)
      } else {
         ::console::affiche_resultat "Somme m�diane de $nb_dark dark(s)...\n"
         smedian "$nom_dark" "${pref_dark}-smd$nb_dark" $nb_dark
      }
      if { $nb_darkflat == 1 } {
         ::console::affiche_resultat "L'image de dark de flat est $nom_darkflat$conf(extension,defaut)\n"
         set pref_darkflat "$nom_darkflat"
         file copy -force $nom_darkflat$conf(extension,defaut) ${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)
      } else {
         ::console::affiche_resultat "Somme m�diane de $nb_darkflat dark(s) associ�(s) aux flat(s)...\n"
         smedian "$nom_darkflat" "${pref_darkflat}-smd$nb_darkflat" $nb_darkflat
      }
      if { $nom_offset!="none" } {
         if { $nb_offset == 1 } {
            ::console::affiche_resultat "L'image de offset est $nom_offset$conf(extension,defaut)\n"
            set pref_offset $nom_offset
            file copy -force $nom_offset$conf(extension,defaut) ${pref_offset}-smd$nb_offset$conf(extension,defaut)
         } else {
            ::console::affiche_resultat "Somme m�diane de $nb_offset offset(s)...\n"
            smedian "$nom_offset" "${pref_offset}-smd$nb_offset" $nb_offset
         }
      }

      #-- Soustraction du master_dark aux images de flat :
      if { $nom_offset=="none" } {
         ::console::affiche_resultat "Soustraction des noirs associ�s aux plus...\n"
         if { $nb_flat == 1 } {
            set pref_flat $nom_flat
            buf$audace(bufNo) load "$nom_flat"
            buf$audace(bufNo) sub "${pref_darkflat}-smd$nb_darkflat" 0
            buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
         } else {
            sub2 "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_flat}_moinsnoir-" 0 $nb_flat
            set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
            #set flat_traite_1 [ lindex [ glob ${pref_flat}_moinsnoir-*$conf(extension,defaut) ] 0 ]
         }
      } else {
         ::console::affiche_resultat "Optimisation des noirs associ�s aux plus...\n"
         if { $nb_flat == 1 } {
            set pref_flat $nom_flat
            buf$audace(bufNo) load "$nom_flat"
            buf$audace(bufNo) opt "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset"
            buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
         } else {
            opt2 "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset" "${pref_flat}_moinsnoir-" $nb_flat
            set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
         }
      }

      #-- Harmonisation des flats et somme m�diane :
      if { $nb_flat == 1 } {
         # Calcul du niveau moyen de la premi�re image
         #buf$audace(bufNo) load "${pref_flat}_moinsnoir-1"
         #set intensite_moyenne [lindex [stat] 4]
         ## Mise au m�me niveau de toutes les images de PLU
         #::console::affiche_resultat "Mise au m�me niveau de l'image de PLU...\n"
         #ngain $intensite_moyenne
         #buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
         #file copy ${pref_flat}_moinsnoir-$nb_flat$conf(extension,defaut) ${pref_flat}-smd$nb_flat$conf(extension,defaut)
         ::console::affiche_resultat "Le flat pr�trait� est ${pref_flat}-smd$nb_flat\n"
      } else {
         # Calcul du niveau moyen de la premi�re image
         buf$audace(bufNo) load "$flat_moinsnoir_1"
         set intensite_moyenne [lindex [stat] 4]
         # Mise au m�me niveau de toutes les images de PLU
         ::console::affiche_resultat "Mise au m�me niveau de toutes les images de PLU...\n"
         ngain2 "${pref_flat}_moinsnoir-" "${pref_flat}_auniveau-" $intensite_moyenne $nb_flat
         ::console::affiche_resultat "Somme m�diane des flat pr�trait�s...\n"
         smedian "${pref_flat}_auniveau-" "${pref_flat}-smd$nb_flat" $nb_flat
         #file delete [ file join [ file rootname ${pref_flat}_auniveau-]$conf(extension,defaut) ]
         delete2 "${pref_flat}_auniveau-" $nb_flat
         delete2 "${pref_flat}_moinsnoir-" $nb_flat
      }


      #--- Pr�traitement des images stellaires :
      #-- Soustraction du noir des images stellaires :
      ::console::affiche_resultat "Soustraction du noir des images stellaires...\n"
      if { $nom_offset=="none" } {
         ::console::affiche_resultat "Soustraction des noirs associ�s aux images stellaires...\n"
         if { $nb_stellaire==1 } {
            set pref_stellaire "$nom_stellaire"
            buf$audace(bufNo) load "$nom_stellaire"
            buf$audace(bufNo) sub "${pref_dark}-smd$nb_dark" 0
            buf$audace(bufNo) save "${pref_stellaire}_moinsnoir"
         } else {
            sub2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire
         }
      } else {
         ::console::affiche_resultat "Optimisation des noirs associ�s aux images stellaires...\n"
         if { $nb_stellaire==1 } {
            set pref_stellaire "$nom_stellaire"
            buf$audace(bufNo) load "$nom_stellaire"
            buf$audace(bufNo) opt "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset"
            buf$audace(bufNo) save "${pref_stellaire}_moinsnoir"
         } else {
            opt2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset" "${pref_stellaire}_moinsnoir-" $nb_stellaire
         }
      }

      #-- Calcul du niveau moyen de la PLU trait�e :
      buf$audace(bufNo) load "${pref_flat}-smd$nb_flat"
      set intensite_moyenne [lindex [stat] 4]

      #-- Division des images stellaires par la PLU :
      ::console::affiche_resultat "Division des images stellaires par la PLU...\n"
      div2 "${pref_stellaire}_moinsnoir-" "${pref_flat}-smd$nb_flat" "${pref_stellaire}-t-" $intensite_moyenne $nb_stellaire
      set image_traite_1 [ lindex [ lsort -dictionary [ glob ${pref_stellaire}-t-\[0-9\]*$conf(extension,defaut) ] ] 0 ]


      #--- Affichage et netoyage :
      loadima "$image_traite_1"
      ::console::affiche_resultat "Affichage de la premi�re image pr�trait�e\n"
      delete2 "${pref_stellaire}_moinsnoir-" $nb_stellaire
      if { $flag_rmmaster == "o" } {
         # Le 06/02/19 :
         file delete -force "${pref_dark}-smd$nb_dark$conf(extension,defaut)"
         file delete -force "${pref_flat}-smd$nb_flat$conf(extension,defaut)"
         file delete -force "${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
      }

      #-- Effacement des fichiers copie des masters dark, flat et dflat dus a la copie automatique de pretrait :
      if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_dark}-smd$nb_dark match resul ] } {
         file delete -force "${pref_dark}-smd$nb_dark$conf(extension,defaut)"
      }
      if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_flat}-smd$nb_flat match resul ] } {
         file delete -force "${pref_flat}-smd$nb_flat$conf(extension,defaut)"
      }
      if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_darkflat}-smd$nb_darkflat match resul ] } {
         file delete -force "${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
      }


      #--- Retour dans le r�pertoire de d�part avnt le script
      return ${pref_stellaire}-t-
   } else {
      ::console::affiche_erreur "Usage: bm_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?nom_offset (none)? ?effacement des masters (o/n)?\n\n"
   }
}
#****************************************************************************#




###############################################################
# Description : Effectue la registration d'une serie d'images brutes
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 07-03-2006
# Date de mise a jour : 07-03-2006
# Arguments : nom generique des fichiers fits du spectre spatial
###############################################################

proc bm_register { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
       set nom_generique [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set liste_fichiers [ glob -dir $audace(rep_images) ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ]
       set nbimg [ llength $liste_fichiers ]

       ::console::affiche_resultat "$nbimg fichiers � apparier...\n"
       register $nom_generique ${nom_generique}-r- $nbimg
       return ${nom_generique}-r-
   } else {
       ::console::affiche_erreur "Usage: bm_register nom generique des images fits\n\n"
   }
}
#-----------------------------------------------------------------------------#



###############################################################################
# Description : Effectue la somme d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date creation : 06 aout 2005
# Date de mise a jour : 27-12-05
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_sadd { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
       set nom_generique [ file tail [ file rootname [ lindex $args 0 ] ] ]
      set liste_fichiers [ glob -dir $audace(rep_images) ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ]
      set nb_file [ llength $liste_fichiers ]

      #--- Gestion de la dur�e totale d'exposition :
      buf$audace(bufNo) load [ lindex $liste_fichiers 0 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "EXPOSURE" ] !=-1 } {
         set unit_exposure [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
      } elseif { [ lsearch $listemotsclef "EXPTIME" ] !=-1 } {
         set unit_exposure [ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]
      } else {
         set unit_exposure 0
      }
      set exposure [ expr $unit_exposure*$nb_file ]

      #--- Somme :
      ::console::affiche_resultat "Somme de $nb_file images...\n"
      renumerote "$nom_generique"
      sadd "$nom_generique" "${nom_generique}-s$nb_file" $nb_file

      #--- Mise a jour du motclef EXPTIME : calcul en fraction de jour
      set exptime [ bm_exptime $nom_generique ]
      buf$audace(bufNo) load "$audace(rep_images)/${nom_generique}-s$nb_file"
      buf$audace(bufNo) setkwd [ list "EXPTIME" $exptime float "Total duration: dobsN-dobs1+1 exposure" "second" ]
      buf$audace(bufNo) setkwd [ list "EXPOSURE" $exposure float "Total time of exposure" "s" ]
      buf$audace(bufNo) save "$audace(rep_images)/${nom_generique}-s$nb_file"

      #--- Traitement du resultat :
      ::console::affiche_resultat "Somme sauv�es sous ${nom_generique}-s$nb_file\n"
      return "${nom_generique}-s$nb_file"
   } else {
      ::console::affiche_erreur "Usage: bm_sadd nom_generique_fichier\n\n"
   }
}
#-----------------------------------------------------------------------------#


###############################################################################
# Description : Effectue la somme moyenne d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2007-07-25
# Date de mise a jour : 2007-07-25
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_smean { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
       set nom_generique [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set liste_fichiers [ glob -dir $audace(rep_images) ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ]
       set nb_file [ llength $liste_fichiers ]

      #--- Gestion de la dur�e totale d'exposition :
      buf$audace(bufNo) load [ lindex $liste_fichiers 0 ]
      #- Bug ici : pas de EXPOSURE dans certains fits
      #set unit_exposure [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
      #set exposure [ expr $unit_exposure*$nb_file ]

      #--- Somme :
      ::console::affiche_resultat "Somme moyenne de $nb_file images...\n"
      renumerote "$nom_generique"
      smean "$nom_generique" "${nom_generique}-sm$nb_file" $nb_file

      #--- Traitement du resultat :
      ::console::affiche_resultat "Somme moyenne sauv�es sous ${nom_generique}-sm$nb_file\n"
      return "${nom_generique}-sm$nb_file"
   } else {
      ::console::affiche_erreur "Usage: bm_smean nom_generique_fichier\n\n"
   }
}
#-----------------------------------------------------------------------------#



###############################################################################
# Description : Effectue la somme mediane d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2007-02-14
# Date de mise a jour : 2007-02-14
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_smed { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
      #set repdflt [bm_goodrep]
      set nom_generique [ file rootname [ lindex $args 0 ] ]
      set nb_file [ llength [ glob -dir $audace(rep_images) ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

      ::console::affiche_resultat "Somme m�diane de $nb_file images...\n"
      renumerote "$nom_generique"
      smedian "$nom_generique" "${nom_generique}-smd$nb_file" $nb_file
      ::console::affiche_resultat "Somme m�diane sauv�e sous ${nom_generique}-smd$nb_file\n"
      #cd $repdflt
      return "${nom_generique}-smd$nb_file"
   } else {
      ::console::affiche_erreur "Usage: bm_smed nom_generique_fichier\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Effectue la somme moyenne, mediane et ssk d'une serie d'images appariees
# Auteur : Benjamin MAUCLAIRE
# Date creation : 06 aout 2005
# Date de mise a jour : 06 aout 2005
# Argument : nom_generique_fichier (sans extension)
###############################################################################

proc bm_somes { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
      set nom_generique [ lindex $args 0 ]
      set nombre [ llength [  glob -dir "$audace(rep_images)" ${nom_generique}*$conf(extension,defaut) ] ]
      regexp {(.+)\-} $nom_generique match pref_nom

      ::console::affiche_resultat "sadd $nom_generique ${pref_nom}_s$nombre$conf(extension,defaut) $nombre...\n"
      sadd "$nom_generique" "${pref_nom}_s$nombre" $nombre
      ::console::affiche_resultat "smean $nom_generique ${pref_nom}_sme$nombre$conf(extension,defaut) $nombre...\n"
      smean "$nom_generique" "${pref_nom}_sme$nombre" $nombre
      ::console::affiche_resultat "smedian $nom_generique ${pref_nom}_smd$nombre$conf(extension,defaut) $nombre...\n"
      smedian "$nom_generique" "${pref_nom}_smd$nombre" $nombre
      ::console::affiche_resultat "ssk $nom_generique ${pref_nom}_ssk$nombre$conf(extension,defaut) $nombre 0,5...\n"
      ssk "$nom_generique" "${pref_nom}_ssk$nombre" $nombre 0.5

      ::console::affiche_resultat "Export des images au format jpeg...\n"
      buf$audace(bufNo) load "$audace(rep_images)/${pref_nom}_s$nombre"
      buf$audace(bufNo) savejpeg "$audace(rep_images)/${pref_nom}_s$nombre"
      buf$audace(bufNo) load "$audace(rep_images)/${pref_nom}_sme$nombre"
      buf$audace(bufNo) savejpeg "$audace(rep_images)/${pref_nom}_sme$nombre"
      buf$audace(bufNo) load "$audace(rep_images)/${pref_nom}_smd$nombre"
      buf$audace(bufNo) savejpeg "$audace(rep_images)/${pref_nom}_smd$nombre"
      buf$audace(bufNo) load "$audace(rep_images)/${pref_nom}_ssk$nombre"
      buf$audace(bufNo) savejpeg "$audace(rep_images)/${pref_nom}_ssk$nombre"
   } else {
      ::console::affiche_erreur "Usage: bm_somes nom_generique_fichier (sans extension)\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Calcule la largeur equivalente d'une etoile en secondes d'arc
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20 juillet 2005
# Date de mise a jour : 20 juillet 2005
################################################################################

proc bm_fwhm { args } {
# arguments : fwhm de l'etoile en pixels, taille d'un pixel en micons, focale du telescope en mm
   global audace
   global conf

   if {[llength $args] == 3} {
      set fwhm [ lindex $args 0 ]
      set tpixel [ lindex $args 1 ]
      set focale [ lindex $args 2 ]

      set sfwhm [ expr atan($tpixel*$fwhm*1E-6/($focale/1000))*(180/acos(-1))*3600 ]
      ::console::affiche_resultat "FWHM �toile : $sfwhm secondes d'arc\n"
   } else {
      ::console::affiche_erreur "Usage: bm_fwhm fwhm-etoile taille-pixel(um) distance-focale(mm)\n\n"
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
# Description : Decoupage d'une zone selectionnee a la souris
#*****************************************************************************#

proc bm_cutima { } {
   global audace
   global caption

   #--- Il faut une image affichee
   if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
      tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
      return
   }
   #---
   if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] != "" } {
      buf$audace(bufNo) window [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ]
      #--- Suppression de la zone selectionnee avec la souris
      ::confVisu::deleteBox $audace(visuNo)
      ::audace::autovisu $audace(visuNo)
   } else {
      tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,tracer)
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
# Description : Zoom d'une image ou d'une zone selectionnee a la souris
#*****************************************************************************#

proc bm_zoomima { args } {
   global audace
   global caption

   #--- Il faut une image affichee
   if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
      tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
      return
   }
   #---
   if { [llength $args] == 1 } {
      set gross $args
      set factor [list $gross $gross]
      if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] == "" } {
         set xmax [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
         set ymax [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
         buf$audace(bufNo) window "1 $ymax $xmax 1"
      } else {
         buf$audace(bufNo) window [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ]
         #--- Suppression de la zone selectionnee avec la souris
         ::confVisu::deleteBox $audace(visuNo)
      }
      buf$audace(bufNo) scale $factor 1
      ::audace::autovisu $audace(visuNo)
   } else {
      ::console::affiche_erreur "Usage: bm_zoomima mult\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Calcule la duree totale d'exposition d'une serie
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-03-2007
# Date de mise a jour : 25-03-2007
# Arguments : nom generique
###############################################################################

proc bm_exptime { args } {
   global audace
   global conf

   if { [ llength $args ]==1 } {
      set nom_generique [ lindex $args 0 ]

      #--- Liste des images :
      set liste_fichiers [ lsort -dictionary [glob -dir $audace(rep_images) ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
      set nb_file [ llength $liste_fichiers ]

      #--- Calcul de exptime :
      #-- Premiere image :
      buf$audace(bufNo) load [ lindex $liste_fichiers 0 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      set date_deb [ mc_date2ymdhms [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
      set d [ lindex $date_deb 2 ]
      set h [ lindex $date_deb 3 ]
      set mi [ lindex $date_deb 4 ]
      set s [ lindex $date_deb 5 ]
      set dfrac_deb [ expr $d+$h/24.0+$mi/1440.0+$s/86400.0 ]
      #-- Derniere image :
      buf$audace(bufNo) load [ lindex $liste_fichiers [ expr $nb_file-1 ] ]
      set date_fin [ mc_date2ymdhms [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
      set d [ lindex $date_fin 2 ]
      set h [ lindex $date_fin 3 ]
      set mi [ lindex $date_fin 4 ]
      set s [ lindex $date_fin 5 ]
      set dfrac_fin [ expr $d+$h/24.0+$mi/1440.0+$s/86400.0 ]
      #-- Difference et conversion en secondes :
      if { [ lsearch $listemotsclef "EXPOSURE" ] !=-1 } {
         set duree [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
      } elseif { [ lsearch $listemotsclef "EXPTIME" ] !=-1 } {
         set duree [ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]
      } else {
         set duree 0
      }
      set exptime [ expr ($dfrac_fin-$dfrac_deb)*86400.0+$duree ]

      #--- Traitement du resultat :
      ::console::affiche_resultat "Dur�e totale d'acquisition : $exptime s\n"
      return $exptime
   } else {
      ::console::affiche_erreur "Usage: bm_exptime nom_generique_s�rie\n\n"
   }
}
#*****************************************************************************#


#=============================================================================#
#                    Anciennes impl�mentations                                #
#=============================================================================#

proc bm_sadd_20060806 { args } {
   global audace
   global conf

   if {[llength $args] == 1} {
      set repdflt [bm_goodrep]
      set nom_generique [ lindex $args 0 ]
      set nb_file [ llength [  glob -dir $audace(rep_images) ${nom_generique}*$conf(extension,defaut) ] ]
      regexp {(.+)\-} $nom_generique match pref_nom

      ::console::affiche_resultat "Somme de $nb_file images... sauv�es sous ${pref_nom}_s$nb_file\n"
      sadd $nom_generique ${pref_nom}_s$nb_file $nb_file
      cd $repdflt
      return ${pref_nom}_s$nb_file
   } else {
      ::console::affiche_erreur "Usage: bm_sadd nom_generique_fichier (sans extension)\n\n"
   }
}




####################################################################################
#                  Anciennes impl�mentations                                       #
####################################################################################


if { 1== 0} {
###############################################################################
# Description : Effectue le pretraitement d'une serie d'images brutes
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-08-2005
# Date de mise a jour : 21-12-2005/070103
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu
# Methode : par soustraction du noir et sans offset
# Bug : Il faut travailler dans le rep parametre d'Aud'ACE, donc revoir toutes les operations !!
###############################################################################

proc bm_pretrait_070103 { args } {
   global audace
   global conf

   if {[llength $args] <= 5} {
      if {[llength $args] == 4} {
         #--- On se place dans le repertoire d'images configure dans Audace
         set repdflt [ bm_goodrep ]
         set nom_stellaire [ lindex $args 0 ]
         set nom_dark [ lindex $args 1 ]
         set nom_flat [ lindex $args 2 ]
         set nom_darkflat [ lindex $args 3 ]
         set flag_rmmaster "o"
      } elseif {[llength $args] == 5} {
         #--- On se place dans le repertoire d'images configure dans Audace
         set repdflt [ bm_goodrep ]
         set nom_stellaire [ lindex $args 0 ]
         set nom_dark [ lindex $args 1 ]
         set nom_flat [ lindex $args 2 ]
         set nom_darkflat [ lindex $args 3 ]
         set flag_rmmaster [ lindex $args 4 ]
      } else {
         ::console::affiche_erreur "Usage: bm_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?effacement des master (o/n)?\n\n"
      }

      ## Renumerote chaque serie de fichier
      renumerote $nom_stellaire
      renumerote $nom_dark
      renumerote $nom_flat
      renumerote $nom_darkflat

      ## Determine les listes de fichiers de chasue serie
      set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_stellaire}\[0-9\]*$conf(extension,defaut) ] ]
      set nb_stellaire [ llength $stellaire_liste ]
      set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_dark}\[0-9\]*$conf(extension,defaut) ] ]
      set nb_dark [ llength $dark_liste ]
      set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_flat}\[0-9\]*$conf(extension,defaut) ] ]
      set nb_flat [ llength $flat_liste ]
      set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]*$conf(extension,defaut) ] ]
      set nb_darkflat [ llength $darkflat_liste ]

      ## Isole le prefixe des noms de fichiers dans le cas ou ils possedent un "-" avant le n�
      set pref_stellaire ""
      set pref_dark ""
      set pref_flat ""
      set pref_darkflat ""
      regexp {(.+)\-?[0-9]+} $nom_stellaire match pref_stellaire
      regexp {(.+)\-?[0-9]+} $nom_dark match pref_dark
      regexp {(.+)\-?[0-9]+} $nom_flat match pref_flat
      regexp {(.+)\-?[0-9]+} $nom_darkflat match pref_darkflat
      #-- En attendant de gerer le cas des fichiers avec - aavnt n�
      set pref_stellaire $nom_stellaire
      set pref_dark $nom_dark
      set pref_flat $nom_flat
      set pref_darkflat $nom_darkflat

      ::console::affiche_resultat "brut=$pref_stellaire, dark=$pref_dark, flat=$pref_flat, df=$pref_darkflat\n"
      #-- La regexp ne fonctionne pas bien pavec des noms contenant des "_"
      if {$pref_stellaire == ""} {
         set pref_stellaire $nom_stellaire
      }
      if {$pref_dark == ""} {
         set pref_dark $nom_dark
      }
      if {$pref_flat == ""} {
         set pref_flat $nom_flat
      }
      if {$pref_darkflat == ""} {
         set pref_darkflat $nom_darkflat
      }
      # ::console::affiche_resultat "Corr : b=$pref_stellaire, d=$pref_dark, f=$pref_flat, df=$pref_darkflat\n"

      ## Pretraitement des fichiers de darks, de flats, de darkflats
      if { $nb_dark == 1 } {
         ::console::affiche_resultat "L'image de dark est $nom_dark$conf(extension,defaut)\n"
         set pref_dark $nom_dark
         file copy $nom_dark$conf(extension,defaut) ${pref_dark}_smd$nb_dark$conf(extension,defaut)
      } else {
         ::console::affiche_resultat "Somme m�diane de $nb_dark dark(s)...\n"
         smedian "$nom_dark" "${pref_dark}_smd$nb_dark" $nb_dark
      }
      if { $nb_darkflat == 1 } {
         ::console::affiche_resultat "L'image de dark de flat est $nom_darkflat$conf(extension,defaut)\n"
         set pref_darkflat "$nom_darkflat"
         file copy $nom_darkflat$conf(extension,defaut) ${pref_darkflat}_smd$nb_darkflat$conf(extension,defaut)
      } else {
         ::console::affiche_resultat "Somme m�diane de $nb_darkflat dark(s) associ�(s) aux flat(s)...\n"
         smedian "$nom_darkflat" "${pref_darkflat}_smd$nb_darkflat" $nb_darkflat
      }
      if { $nb_flat == 1 } {
         set pref_flat $nom_flat
         buf$audace(bufNo) load "$nom_flat"
         sub "${pref_darkflat}_smd$nb_darkflat" 0
         buf$audace(bufNo) save "${pref_flat}_smd$nb_flat"
      } else {
         sub2 "$nom_flat" "${pref_darkflat}_smd$nb_darkflat" "${pref_flat}_moinsnoir-" 0 $nb_flat
         set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
         #set flat_traite_1 [ lindex [ glob ${pref_flat}_moinsnoir-*$conf(extension,defaut) ] 0 ]
      }

      if { $nb_flat == 1 } {
         # Calcul du niveau moyen de la premiere image
         #buf$audace(bufNo) load "${pref_flat}_moinsnoir-1"
         #set intensite_moyenne [lindex [stat] 4]
         ## Mise au meme niveau de toutes les images de PLU
         #::console::affiche_resultat "Mise au m�me niveau de l'image de PLU...\n"
         #ngain $intensite_moyenne
         #buf$audace(bufNo) save "${pref_flat}_smd$nb_flat"
         #file copy ${pref_flat}_moinsnoir-$nb_flat$conf(extension,defaut) ${pref_flat}_smd$nb_flat$conf(extension,defaut)
         ::console::affiche_resultat "Le flat pr�trait� est ${pref_flat}_smd$nb_flat\n"
      } else {
         # Calcul du niveau moyen de la premiere image
         buf$audace(bufNo) load "$flat_moinsnoir_1"
         set intensite_moyenne [lindex [stat] 4]
         # Mise au meme niveau de toutes les images de PLU
         ::console::affiche_resultat "Mise au m�me niveau de toutes les images de PLU...\n"
         ngain2 "${pref_flat}_moinsnoir-" "${pref_flat}_auniveau-" $intensite_moyenne $nb_flat
         ::console::affiche_resultat "Somme m�diane des flat pr�trait�s...\n"
         smedian "${pref_flat}_auniveau-" "${pref_flat}_smd$nb_flat" $nb_flat
         #file delete [ file join [ file rootname ${pref_flat}_auniveau-]$conf(extension,defaut) ]
         delete2 "${pref_flat}_auniveau-" $nb_flat
         delete2 "${pref_flat}_moinsnoir-" $nb_flat
      }

      ## Pretraitement des images stellaires
      # Soustraction du noir des images stellaires
      ::console::affiche_resultat "Soustraction du noir des images stellaires...\n"
      sub2 "$nom_stellaire" "${pref_dark}_smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire
      # Calcul du niveau moyen de la PLU traitee
      buf$audace(bufNo) load "${pref_flat}_smd$nb_flat"
      set intensite_moyenne [lindex [stat] 4]
      # Division des images stellaires par la PLU
      ::console::affiche_resultat "Division des images stellaires par la PLU...\n"
      div2 "${pref_stellaire}_moinsnoir-" "${pref_flat}_smd$nb_flat" "${pref_stellaire}-t-" $intensite_moyenne $nb_stellaire
      set image_traite_1 [ lindex [ lsort -dictionary [ glob ${pref_stellaire}-t-\[0-9\]*$conf(extension,defaut) ] ] 0 ]

      #--- Affichage et netoyage
      loadima "$image_traite_1"
      ::console::affiche_resultat "Affichage de la premi�re image pr�trait�e\n"
      delete2 "${pref_stellaire}_moinsnoir-" $nb_stellaire
      if { $flag_rmmaster == "o" } {
         # Le 06/02/19 :
         file delete "${pref_dark}_smd$nb_dark$conf(extension,defaut)"
         file delete "${pref_flat}_smd$nb_flat$conf(extension,defaut)"
         file delete "${pref_darkflat}_smd$nb_darkflat$conf(extension,defaut)"
      }

      #--- Retour dans le repertoire de depart avnt le script
      cd $repdflt
      return ${pref_stellaire}-t-
   } else {
       ::console::affiche_erreur "Usage: bm_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?effacement des master (o/n)?\n\n"
   }
}
#-----------------------------------------------------------------------------#

###############################################################################
# Description : Effectue le pretraitement d'une serie d'images brutes
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-08-2005
# Date de mise a jour : 21-12-2005
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu
# Methode : par soustraction du noir et sans offset
# Bug : Il faut travailler dans le rep parametre d'Aud'ACE, donc revoir toutes les operations !!
###############################################################################

proc bm_pretrait_21-12-2005 { args } {
   global audace
   global conf

   if {[llength $args] == 4} {
      #--- On se place dans le repertoire d'images configure dans Audace
      set repdflt [ bm_goodrep ]
      set nom_stellaire [ lindex $args 0 ]
      set nom_dark [ lindex $args 1 ]
      set nom_flat [ lindex $args 2 ]
      set nom_darkflat [ lindex $args 3 ]

      ## Renumerote chaque serie de fichier
      renumerote $nom_stellaire
      renumerote $nom_dark
      renumerote $nom_flat
      renumerote $nom_darkflat

      ## Isole le prefixe des noms de fichiers
      set pref_stellaire ""
      set pref_dark ""
      set pref_flat ""
      set pref_darkflat ""
      regexp {(.+)\-} $nom_stellaire match pref_stellaire
      regexp {(.+)\-} $nom_dark match pref_dark
      regexp {(.+)\-} $nom_flat match pref_flat
      regexp {(.+)\-} $nom_darkflat match pref_darkflat
      ::console::affiche_resultat "b=$pref_stellaire, d=$pref_dark, f=$pref_flat, df=$pref_darkflat\n"
      #-- La regexp ne fonctionne pas bien pavec des noms contenant des "_"

      if {$pref_stellaire == ""} {
         set pref_stellaire $nom_stellaire
      }
      if {$pref_dark == ""} {
         set pref_dark $nom_dark
      }
      if {$pref_flat == ""} {
         set pref_flat $nom_flat
      }
      if {$pref_darkflat == ""} {
         set pref_darkflat $nom_darkflat
      }
      # ::console::affiche_resultat "Corr : b=$pref_stellaire, d=$pref_dark, f=$pref_flat, df=$pref_darkflat\n"

      ## Determine le nombre de fichiers de chaque serie
      set stellaire_liste [ glob -dir $audace(rep_images) ${nom_stellaire}*$conf(extension,defaut) ]
      set nb_stellaire [ llength $stellaire_liste ]
      set dark_liste [ glob -dir $audace(rep_images) ${nom_dark}*$conf(extension,defaut) ]
      set nb_dark [ llength $dark_liste ]
      set flat_liste [ glob -dir $audace(rep_images) ${nom_flat}*$conf(extension,defaut) ]
      set nb_flat [ llength $flat_liste ]
      set darkflat_liste [ glob -dir $audace(rep_images) ${nom_darkflat}*$conf(extension,defaut) ]
      set nb_darkflat [ llength $darkflat_liste ]

      ## Pretraitement des fichiers de darks, de flats, de darkflats
      if { $nb_dark == 1 } {
         ::console::affiche_resultat "L'image de dark est $nom_dark$conf(extension,defaut)\n"
         set pref_dark $nom_dark
         file copy $nom_dark$conf(extension,defaut) ${pref_dark}_smd$nb_dark$conf(extension,defaut)
      } else {
         ::console::affiche_resultat "Somme m�diane de $nb_dark dark(s)...\n"
         smedian "$nom_dark" "${pref_dark}_smd$nb_dark" $nb_dark
      }
      if { $nb_darkflat == 1 } {
         ::console::affiche_resultat "L'image de dark de flat est $nom_darkflat$conf(extension,defaut)\n"
         set pref_darkflat "$nom_darkflat"
         file copy $nom_darkflat$conf(extension,defaut) ${pref_darkflat}_smd$nb_darkflat$conf(extension,defaut)
      } else {
         ::console::affiche_resultat "Somme m�diane de $nb_darkflat dark(s) associ�(s) aux flat(s)...\n"
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
         # Calcul du niveau moyen de la premiere image
         #buf$audace(bufNo) load "${pref_flat}_moinsnoir-1"
         #set intensite_moyenne [lindex [stat] 4]
         ## Mise au meme niveau de toutes les images de PLU
         #::console::affiche_resultat "Mise au m�me niveau de l'image de PLU...\n"
         #ngain $intensite_moyenne
         #buf$audace(bufNo) save "${pref_flat}_smd$nb_flat"
         #file copy ${pref_flat}_moinsnoir-$nb_flat$conf(extension,defaut) ${pref_flat}_smd$nb_flat$conf(extension,defaut)
         ::console::affiche_resultat "Le flat pr�trait� est ${pref_flat}_smd$nb_flat\n"
      } else {
         # Calcul du niveau moyen de la premiere image
         buf$audace(bufNo) load "$flat_moinsnoir_1"
         set intensite_moyenne [lindex [stat] 4]
         # Mise au meme niveau de toutes les images de PLU
         ::console::affiche_resultat "Mise au m�me niveau de toutes les images de PLU...\n"
         ngain2 "${pref_flat}_moinsnoir-" "${pref_flat}_auniveau-" $intensite_moyenne $nb_flat
         ::console::affiche_resultat "Somme m�diane des flat pr�trait�s...\n"
         smedian "${pref_flat}_auniveau-" "${pref_flat}_smd$nb_flat" $nb_flat
         #file delete [ file join [ file rootname ${pref_flat}_auniveau-]$conf(extension,defaut) ]
         delete2 "${pref_flat}_auniveau-" $nb_flat
         delete2 "${pref_flat}_moinsnoir-" $nb_flat
      }

      ## Pretraitement des images stellaires
      # Soustraction du noir des images stellaires
      ::console::affiche_resultat "Soustraction du noir des images stellaires...\n"
      sub2 "$nom_stellaire" "${pref_dark}_smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire
      # Calcul du niveau moyen de la PLU traitee
      buf$audace(bufNo) load "${pref_flat}_smd$nb_flat"
      set intensite_moyenne [lindex [stat] 4]
      # Division des images stellaires par la PLU
      ::console::affiche_resultat "Division des images stellaires par la PLU...\n"
      div2 "${pref_stellaire}_moinsnoir-" "${pref_flat}_smd$nb_flat" "${pref_stellaire}_t-" $intensite_moyenne $nb_stellaire
      set image_traite_1 [ lindex [ lsort -dictionary [ glob ${pref_stellaire}_t-*$conf(extension,defaut) ] ] 0 ]

      #--- Affichage et netoyage
      loadima "$image_traite_1"
      ::console::affiche_resultat "Affichage de la premi�re image pr�trait�e\n"
      delete2 "${pref_stellaire}_moinsnoir-" $nb_stellaire
      # Le 06/02/19 :
      file delete "${pref_dark}_smd$nb_dark$conf(extension,defaut)"
      file delete "${pref_flat}_smd$nb_flat$conf(extension,defaut)"
      file delete "${pref_darkflat}_smd$nb_darkflat$conf(extension,defaut)"

      #--- Retour dans le repertoire de depart avnt le script
      cd $repdflt
      return ${pref_stellaire}_t-
   } else {
      ::console::affiche_erreur "Usage: bm_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu\n\n"
   }
}
#****************************************************************************#

