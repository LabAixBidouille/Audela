#####################################################################
#
# Fichier     : calaphot.tcl
# Description : Script pour la photométrie d'astéroïdes ou d'étoiles variables
# Auteurs     : Olivier Thizy (thizy@free.fr)
#               Jacques Michelet (jacques.michelet@laposte.net)
# Mise a jour $Id: calaphot.tcl,v 1.7 2007-12-28 10:29:09 alainklotz Exp $

# Définition d'un espace réservé à ce script
catch {namespace delete ::Calaphot}
namespace eval ::CalaPhot {

    variable parametres
    variable texte_photo
    variable police
    variable demande_arret
    variable test
    variable data_script
    variable data_image
    variable parametres

# L'existence de test crée le ficher debug.log
#    set test 0

    set numero_version v3.4

    if {$tcl_platform(os)!="Linux"} {
        set police(gras) [font actual .audace]
        set police(italique) [font actual .audace]
        set police(normal) [font actual .audace]
        set police(titre) [font actual .audace]
    } else {
        set police(gras) {helvetica 9 bold}
        set police(italique) {helvetica 9 italic}
        set police(normal) {helvetica 9 normal}
        set police(titre) {helvetica 11 bold}
    }

    source [file join $audace(rep_scripts) calaphot calaphot.cap]

    #*************************************************************************#
    #*************  Principal  ***********************************************#
    #*************************************************************************#
    proc Principal {} {

        global audace color
        variable demande_arret
        variable parametres
        variable coord_aster
        variable nombre_etoile
        variable pos_theo
        variable pos_reel
        variable mag
        variable courbe
        variable fileId
        variable fileName
        variable data_image
        variable texte_photo
        variable data_script
        variable moyenne
        variable ecart_type
        variable nombre_indes
        variable liste_image
        variable vx_temp
        variable vy1_temp
        variable vy2_temp
        variable vy3_temp

        # Chargement des librairies ressources
        set librairie [Ressources]
        if {$librairie != 0} {return}

        # Initialisations diverses
        Initialisations

        Message console "-------------- calaphot-%s--------\n" $::CalaPhot::numero_version
        Message console "-- (c)2001-2004 O. Thizy & J. Michelet---\n"
        Message console "-----------------------------------------\n"

        # Lecture du fichier de paramètres
        RecuperationParametres

        set demande_arret 0
        SaisieParametres
        SauvegardeParametres
        if {$demande_arret == 1} {
            Message console "%s\n" $texte_photo(fin_anticipee)
            return
        }

        # Affichage de la bannière dans le fichier résultat
        set fileName [file join $audace(rep_images) $parametres(sortie)]
        if {[catch {open $fileName w} fid]} {
            Message console $fid
            return
        } else {
           close $fid
        }
        #if {[catch {open [file join $audace(rep_images) $parametres(sortie)] w} fileId]} {
        #    Message console $fileId
        #    return
        #}
        Message log "---------------calaphot-%s --------------\n" $::CalaPhot::numero_version
        Message log "-- (c)2001-2004 O. Thizy & J. Michelet---\n"
        Message log "-----------------------------------------\n"
        # Affiche l'heure du début de traitement
        Message consolog "%s %s\n\n" $texte_photo(heure_debut) [clock format [clock seconds]]

        # Vérification de l'existence des images
        set erreur [Verification]
        if {$erreur != 0} {
            Message consolog "%s\n" $texte_photo(fin_anticipee)
            #close $fileId
            return
        }

        # Récupération d'informations sur les images
        InformationsImages

        # Récapitulation des options choisies
        RecapitulationOptions

        # Tri des images par date croissante
        set liste_image [TriDateImage]
        set premier_liste [lindex $liste_image 0]
        set dernier_liste [lindex $liste_image end]

        # Création des images t1 et t2, copies de la première et de la dernière image
        loadima $parametres(source)$premier_liste
        saveima t1
        loadima $parametres(source)$dernier_liste
        saveima t2

        if {$parametres(type_images) == 0} {
            # Images non recalées
            # Recalage de la première et de la dernière image en u1 et u2
            register2 t u 2
            AffichageMenus u
            # Permet la sélection des étoiles et de l'astéroïde sur les images recalées
        } else {
            # Permet la sélection des étoiles et de l'astéroïde
            AffichageMenus t
        }

        if {$demande_arret == 1} {
            $audace(hCanvas) delete marqueurs
            Message consolog "%s\n" $texte_photo(fin_anticipee)
            return
        }
        set data_script(nombre_etoile) $nombre_etoile
        set data_script(nombre_indes) $nombre_indes

        # Recherche de l'étoile la plus brillante
        set eclat_max [RecherchePlusBrillante]

        # Calcul des dates extrêmes
        set temp [DatesReferences]
        set jd_premier [lindex $temp 0]
        set jd_dernier [lindex $temp 1]
        set delta_jd [lindex $temp 2]

        # Calcul de la vitesse apparente de l'astéroïde
        set temp [VitesseAsteroide $delta_jd]
        set vitesse_x [lindex $temp 0]
        set vitesse_y [lindex $temp 1]
        Message consolog "\n"
        Message consolog "%s %8.2f/%8.2f\n" $texte_photo(vitesse_asteroide) $vitesse_x $vitesse_y

        # Calcul de magnitude de la super-étoile
        CalculMagSuperEtoile
        Message consolog "%s %5.3f\n" $texte_photo(mag_superetoile) $data_script(mag_ref_0)
        Message consolog "%s %d\n" $texte_photo(calcul_ellipses) $eclat_max

        # Quelques initialisations
        set nombre_image [llength $liste_image]
        set data_script(nombre_image) $nombre_image

        # Affiche les titres des colonnes
        Entete

        # Mise en place du bouton d'arrêt
        BoutonArret

        # Affichage de la courbe de lumière dynamique
        ::CalaPhot::CourbeLumiereTemporaire vx_temp vy1_temp vy2_temp vy3_temp

        # Boucle principale sur les images de la série
        #----------------------------------------------
        foreach i $liste_image {
        # Détection de l'appui sur le bouton d'arrêt
            if {$demande_arret == 1} {
                ArretScript
                EffaceMotif astres
                Message consolog "%s\n" $texte_photo(fin_anticipee)
                return
            }

            # Détermination du décalage des images par rapport à la première
            if {$parametres(type_images) == 0} {
                # Images non recalées
                # recalage des images par rapport à la première image pour connaître le décalage en coordonnées
                loadima $parametres(source)$i
                saveima t2
                register2 t u 2
                loadima u2
                set decalage [DecalageImage]
                set decalage_x [lindex $decalage 0]
                set decalage_y [lindex $decalage 1]
            } else {
                # Les images sont recalées, pas de décalage entre elles
                set decalage_x 0.0
                set decalage_y 0.0
            }
            set data_image($i,decalage_x) $decalage_x
            set data_image($i,decalage_y) $decalage_y

            # chargement et visualisation de l'image traitée
            loadima $parametres(source)$i
            Visualisation rapide

            # Calcule la position de l'astéroïde par interpolation sur les dates (sans tenir compte du décalage des images)
            if {$delta_jd == 0} {
                set x_0 [expr [lindex $coord_aster(1) 0] + double($i - $premier_liste) * $vitesse_x]
                set y_0 [expr [lindex $coord_aster(1) 1] + double($i - $premier_liste) * $vitesse_y]
            } else {
                set x_0 [expr [lindex $coord_aster(1) 0] + ($data_image($i,date) - $jd_premier) * $vitesse_x]
                set y_0 [expr [lindex $coord_aster(1) 1] + ($data_image($i,date) - $jd_premier) * $vitesse_y]
            }
            set pos_theo(0) [list $x_0 $y_0]

            # Calcul de toutes les positions réelles des astres (astéroïde compris) à considérer ET à supprimer, en tenant compte du décalage en coordonnées des images
            set test [CalculPositionsReelles $i]
            if {$test != 0} {
                set data_image($i,valide) "N"
                continue
            }

            # Suppression de toutes les étoiles indésirables
            SuppressionIndesirables $i

            # Les astres (étoiles + astéroïde) sont modelisées dans TOUS les cas
            #  Un certain nombre de valeurs individuelles sont mises a jour dans data_image
            for {set j 0} {$j <= $nombre_etoile} {incr j} {
                # Dessin d un rectangle
                if {$j > 0} {
                   set couleur_etoile $color(green)
                } else {
                   set couleur_etoile $color(yellow)
                }
                Dessin rectangle $pos_reel($i,$j) [list $parametres(tailleboite) $parametres(tailleboite)] $couleur_etoile etoile_$j
                # Modélisation
                #::console::affiche_resultat "--------------------\nAPPEL Modelisation2D i=$i j=$j pos_reel=$pos_reel($i,$j)\n"
                Modelisation2D $i $j $pos_reel($i,$j)
            }


            if {$parametres(mode) == 1} {
                # Cas ouverture
                # Calcul des axes principaux des ellipses à partir des fwhm des étoiles de référence
                # NB : il faut pour cela connaitre les modèles de TOUTES les étoiles
                set ellipses [CalculEllipses $i]
                if {[lindex $ellipses 0] == 1} {
                    set r1x [lindex $ellipses 1]
                    set r1y [lindex $ellipses 2]
                    set r2 [lindex $ellipses 3]
                    set r3 [lindex $ellipses 4]

                    for {set j 0} {$j <= $nombre_etoile} {incr j} {
                       FluxOuverture $i $j
                    }
                } else {
                    set data_image($i,valide) "N"
                }
            }

            # Dessin des symboles
            for {set j 0} {$j <= $nombre_etoile} {incr j} {
                # Dessin des axes principaux
                if {$data_image($i,centroide_x_$j) >= 0} {
                    # La modélisation a reussi
                    Dessin2 $i $j $parametres(rayon1) $couleur_etoile etoile_$j
                } else {
                    # Pas de modélisation possible
                    Dessin verticale [list $data_image($i,centroide_x_$j) $data_image($i,centroide_y_$j)] [list $parametres(tailleboite) $parametres(tailleboite)] $color(red) etoile_$j
                    Dessin horizontale [list $data_image($i,centroide_x_$j) $data_image($i,centroide_y_$j)] [list $parametres(tailleboite) $parametres(tailleboite)] $color(red) etoile_$j
                }
            }

            FluxReference $i

            # Calcul des magnitudes et des incertitudes de tous les astres (astéroïde et étoiles)
            MagnitudesEtoiles $i

            # Premier filtrage sur les rapports signal à bruit
            FiltrageSB $i

            # Calcul d'incertitude global
            CalculErreurGlobal $i

            # Affiche le résultat dans la console
            AffichageResultatsBruts $i

            # Effacement des marqueurs d'étoile
            EffaceMotif astres

            # Calculs des vecteurs pour le pré-affichage de la courbe de lumière
            PreAffiche $i
         }
         # Fin de la boucle sur les images

         # Suppression du bouton d'arrêt
         destroy $audace(base).bouton_arret_color_invariant

         # Deuxième filtrage sur les images pour filtrer celles douteuses
         FiltrageConstanteMag

         # Statistiques sur les étoiles à partir des images validées
         Statistiques 1

         Message consolog "%s : %s %07.4f %s %6.4f\n" $texte_photo(asteroide)  $texte_photo(moyenne) $moyenne(0) $texte_photo(ecart_type) $ecart_type(0)
         for {set etoile 1} {$etoile <= $nombre_etoile} {incr etoile 1} {
             Message consolog "%s : %s %07.4f %s %6.4f\n" $texte_photo(etoile)  $texte_photo(moyenne) $moyenne($etoile) $texte_photo(ecart_type) $ecart_type($etoile)
         }

         # Sortie standardisée des valeurs
         if {$parametres(format_sortie) == 1} {
             AffichageCanopus
         } else {
             AffichageCDR
         }

         # Affichage de la courbe de lumière
         CourbeLumiere

         # Affiche l'heure de fin de traitement
         Message consolog "\n\n%s %s\n" $texte_photo(heure_fin) [clock format [clock seconds]]
         Message consolog "%s\n" $texte_photo(fin_normale)

         # Ferme le fichier de sortie des résultats...
         #close $fileId
    }

    #*************************************************************************#
    #*************  AffichageCanopus  ****************************************#
    #*************************************************************************#
    proc AffichageCanopus {} {
        variable texte_photo
        variable parametres
        variable data_image
        variable liste_image

        Message consolog "---------------------------------------------------------------------------------------\n"
        Message consolog "Format Canopus\n"
        Message consolog "---------------------------------------------------------------------------------------\n"
        Message consolog "Observation Data:\n"
        Message consolog "-----------------\n"
        Message consolog "    Date          UT           OM           C1         C2        C3         C4        C5         U          CA        O-C\n"

        foreach i $liste_image {
            set temps [mc_date2ymdhms $data_image($i,date)]
            Message consolog "%02d/%02d/%04d    " [lindex $temps 2] [lindex $temps 1] [lindex $temps 0]
            Message consolog "%02d:%02d:%02d    " [lindex $temps 3] [lindex $temps 4] [expr round([lindex $temps 5])]
            for {set etoile 0} {$etoile <= 5} {incr etoile} {
                if {[info exists data_image($i,mag_$etoile)]} {
                    Message consolog "%7.2f     " $data_image($i,mag_$etoile)
                } else {
                    Message consolog "99.99     "
                }
            }
            Message consolog "%s       " $data_image($i,valide)
            Message consolog "%7.2f    " $data_image($i,constante_mag)
            Message consolog "%7.2f\n" [expr $data_image($i,constante_mag) - $data_image($i,mag_0)]
        }
        # Fin de la boucle sur les images
    }

    #*************************************************************************#
    #*************  AffichageCDR  ********************************************#
    #*************************************************************************#
    proc AffichageCDR {} {
        variable data_image
        variable parametres
        variable texte_photo
        variable data_script
        variable liste_image

        set premier [lindex $liste_image 0]
        set dernier [lindex $liste_image end]

        Message consolog "\n\n\n"
        Message consolog "---------------------------------------------------------------------------------------\n"
        Message consolog "Format CDR\n"
        Message consolog "---------------------------------------------------------------------------------------\n"
        Message consolog "NOM %s\n" $parametres(objet)
        if {[string length $parametres(code_UAI)] != 0} {
            Message consolog "MES %s @%s\n" $parametres(operateur) $parametres(code_UAI)
        } else {
            Message consolog "MES %s\n" $parametres(operateur)
        }
        Message consolog "POS 0 %5.2f\n" $data_image($premier,temps_expo)
        Message consolog "CAP %s\n" $parametres(type_capteur)
        Message consolog "TEL %s %s %s\n" $parametres(diametre_telescope) $parametres(focale_telescope) $parametres(type_telescope)
        Message consolog "CAT %s\n" $parametres(catalogue_reference)
        Message consolog "FIL %s\n" $parametres(filtre_optique)
        Message consolog "; %s %s %s\n" $texte_photo(banniere_CDR_1) $::CalaPhot::numero_version $texte_photo(banniere_CDR_2)
        set image 0

        foreach i $liste_image {
            if {$data_image($i,valide) == "Y"} {
                incr image
                Message consolog " 1 1"
                # Passage de la date en format amj,ddd
                set amjhms [mc_date2ymdhms $data_image($i,date)]
                set date_claire "[format %04d [lindex $amjhms 0]]"
                append date_claire "[format %02d [lindex $amjhms 1]]"
                append date_claire "[format %02d [lindex $amjhms 2]]"
                set hms [format %6.5f [expr double([lindex $amjhms 3])/24.0 + double([lindex $amjhms 4])/1440.0 + double([lindex $amjhms 5])/86400.0]]
                set hms [string range $hms [string first . $hms] end]
                append date_claire $hms
                Message consolog " %14.5f" $date_claire
                Message consolog " T"
                Message consolog " %6.3f" $data_image($i,mag_0)
                Message consolog " %6.3f" $data_image($i,incertitude_0)
                Message consolog "\n"
            }
        }
        Message consolog "---------------------------------------------------------------------------------------\n"
    }

    #*************************************************************************#
    #*************  AffichageMenus  ******************************************#
    #*************************************************************************#
    proc AffichageMenus {nom_image} {
        variable demande_arret

        AffichageMenuEtoile $nom_image
        if {$demande_arret == 0} {
            AffichageMenuAsteroide 1 $nom_image
            if {$demande_arret == 0} {
                AffichageMenuIndesirable $nom_image
            }
        }
    }

    #*************************************************************************#
    #*************  AffichageMenuAsteroide  **********************************#
    #*************************************************************************#
    proc AffichageMenuAsteroide {indice nom_image} {
        global audace
        variable texte_photo

        # Affichage de la première ou de la dernière image de la série
        loadima ${nom_image}${indice}
        Visualisation optimale

        toplevel $audace(base).selection_aster -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selection_aster 200x200+650+120
        wm resizable $audace(base).selection_aster 0 0
        wm title $audace(base).selection_aster $texte_photo(asteroide)
        wm transient $audace(base).selection_aster .audace
        wm protocol $audace(base).selection_aster WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(pos_aster_1) $texte_photo(pos_aster_1)
        set texte_bouton(pos_aster_2) $texte_photo(pos_aster_2)
        set texte_bouton(continuation) $texte_photo(continuation)
        set texte_bouton(retour) $texte_photo(retour)
        set texte_bouton(annulation) $texte_photo(annulation)

        set commande_bouton(pos_aster_1)  "::CalaPhot::SelectionneAsteroide $nom_image 1"
        set commande_bouton(pos_aster_2)  "::CalaPhot::SelectionneAsteroide $nom_image 2"
        set commande_bouton(continuation) "::CalaPhot::ContinuationAsteroide $indice $nom_image"
        set commande_bouton(retour) "::CalaPhot::Retour $nom_image"
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        if {$indice == 1} {
            set liste_champ {pos_aster_1 continuation annulation}
        } else {
            set liste_champ {pos_aster_2 continuation retour annulation}
        }

        #----- Création du contenu de la fenêtre
        foreach champ $liste_champ {
            button $audace(base).selection_aster.b$champ -text $texte_bouton($champ) -command $commande_bouton($champ) -bg $audace(color,backColor2)
            pack $audace(base).selection_aster.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selection_aster -anchor center -expand 1 -fill both -side top
        }
        tkwait window $audace(base).selection_aster
    }

    #*************************************************************************#
    #*************  AffichageMenuEtoile  *************************************#
    #*************************************************************************#
    proc AffichageMenuEtoile {nom_image} {
        global audace
        variable texte_photo
        variable nombre_etoile
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile

        # Affichage de la première image de la serie
        loadima ${nom_image}1
        Visualisation optimale

        toplevel $audace(base).selection_etoile -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selection_etoile 200x200+650+120
        wm resizable $audace(base).selection_etoile 0 0
        wm title $audace(base).selection_etoile $texte_photo(etoile_reference)
        wm transient $audace(base).selection_etoile .audace
        wm protocol $audace(base).selection_etoile WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(validation_etoile) $texte_photo(validation_etoile)
        set texte_bouton(devalidation_etoile) $texte_photo(devalidation_etoile)
        set texte_bouton(continuation) $texte_photo(continuation)
        set texte_bouton(annulation) $texte_photo(annulation)

        set commande_bouton(validation_etoile) ::CalaPhot::SelectionneEtoiles
        set commande_bouton(devalidation_etoile) ::CalaPhot::DeselectionneEtoiles
        set commande_bouton(continuation) ::CalaPhot::ContinuationEtoiles
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Création du contenu de la fenÃªtre
        foreach champ {validation_etoile devalidation_etoile continuation annulation} {
            button $audace(base).selection_etoile.b$champ -text $texte_bouton($champ) -command $commande_bouton($champ) -bg $audace(color,backColor2)
            pack $audace(base).selection_etoile.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selection_etoile -anchor center -expand 1 -fill both -side top
        }

        set nombre_etoile 0
        if {[info exists coord_etoile_x]} {
            unset coord_etoile_x
            list coord_etoile_x {}
        }
        if {[info exists coord_etoile_y]} {
            unset coord_etoile_y
            list coord_etoile_y {}
        }
        if {[info exists mag_etoile]} {
            unset mag_etoile
            list mag_etoile {}
        }
        tkwait window $audace(base).selection_etoile
    }

    #*************************************************************************#
    #*************  AffichageMenuIndesirable  ********************************#
    #*************************************************************************#
    proc AffichageMenuIndesirable {nom_image} {
        global audace
        variable texte_photo
        variable nombre_indes
        variable coord_indes_x
        variable coord_indes_y

        # Affichage de la première image de la serie
        loadima ${nom_image}1
        Visualisation optimale

        toplevel $audace(base).selection_indes -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selection_indes 200x200+650+120
        wm resizable $audace(base).selection_indes 0 0
        wm title $audace(base).selection_indes $texte_photo(etoile_a_supprimer)
        wm transient $audace(base).selection_indes .audace
        wm protocol $audace(base).selection_indes WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(validation_etoile) $texte_photo(validation_etoile)
        set texte_bouton(devalidation_etoile) $texte_photo(devalidation_etoile)
        set texte_bouton(continuation) $texte_photo(continuation)
        set texte_bouton(annulation) $texte_photo(annulation)

        set commande_bouton(validation_etoile) ::CalaPhot::SelectionneIndesirables
        set commande_bouton(devalidation_etoile) ::CalaPhot::DeselectionneIndesirables
        set commande_bouton(continuation) ::CalaPhot::ContinuationIndesirables
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Création du contenu de la fenêtre
        foreach champ {validation_etoile devalidation_etoile continuation annulation} {
            button $audace(base).selection_indes.b$champ -text $texte_bouton($champ) -command $commande_bouton($champ) -bg $audace(color,backColor2)
            pack $audace(base).selection_indes.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selection_indes -anchor center -expand 1 -fill both -side top
        }

        set nombre_indes 0
        if {[info exists coord_indes_x]} {
            unset coord_indes_x
            list coord_indes_x {}
        }
        if {[info exists coord_indes_y]} {
            unset coord_indes_y
            list coord_indes_y {}
        }
        tkwait window $audace(base).selection_indes
    }

    #*************************************************************************#
    #*************  AffichageResultatsBruts  *********************************#
    #*************************************************************************#
    proc AffichageResultatsBruts {i} {
        variable parametres
        variable data_image
        variable data_script

        set ymdhms [mc_date2ymdhms $data_image($i,date)]
        set y [lindex $ymdhms 0]
        set m [lindex $ymdhms 1]
        set d [lindex $ymdhms 2]
        set h [lindex $ymdhms 3]
        set mn [lindex $ymdhms 4]
        set s [lindex $ymdhms 5]

        switch -exact -- $parametres(affichage) {
            0 {
                # Minimal
                Message consolog "%05u %04d/%02d/%02d %02d:%02d:%04.1f" $i $y $m $d $h $mn $s
                for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
                    Message consolog " | %07.4f" $data_image($i,mag_$etoile)
                    Message consolog " %05.4f" $data_image($i,incertitude_$etoile)
                }
                Message consolog "\n"
            }
            1 {
                # Normal
                Message consolog "%05u %04d/%02d/%02d %02d:%02d:%04.1f" $i $y $m $d $h $mn $s
                for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
                    Message consolog " | %07.4f" $data_image($i,mag_$etoile)
                    Message consolog " %05.4f" $data_image($i,incertitude_$etoile)
                    Message consolog " %07.0f" $data_image($i,flux_$etoile)
                    Message consolog " %06.1f" $data_image($i,sb_$etoile)
                }
                Message consolog " | %07.4f | %s\n" $data_image($i,constante_mag) $data_image($i,valide)
            }
            2 {
                # Bavard
                Message consolog "%05u %04d/%02d/%02d %02d:%02d:%04.1f" $i $y $m $d $h $mn $s

                if {$parametres(mode) == 1} {
                    Message consolog " | %06.3f %06.3f %06.3f %06.3f" $data_image($i,r1x) $data_image($i,r1y) $data_image($i,r2) $data_image($i,r3)
                } else {
                    Message consolog " | ------ ------ ------ ------"
                }
                Message consolog " | M=%07.4f" $data_image($i,mag_0)
                Message consolog " +/-%05.4f" $data_image($i,incertitude_0)
                Message consolog " F=%07.0f" $data_image($i,flux_0)
                Message consolog " SNR=%06.1f" $data_image($i,sb_0)
                Message consolog " N=%07.2f" $data_image($i,nb_pixels_0)
                Message consolog " B=%06.1f" $data_image($i,fond_0)
                Message consolog " Nb=%07.2f" $data_image($i,nb_pixels_fond_0)
                Message consolog " | Cm=%07.4f | %s\n" $data_image($i,constante_mag) $data_image($i,valide)

                for {set etoile 1} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
                    Message consolog "                                                      "
                    Message consolog " M=%07.4f" $data_image($i,mag_$etoile)
                    Message consolog " +/-%05.4f" $data_image($i,incertitude_$etoile)
                    Message consolog " F=%07.0f" $data_image($i,flux_$etoile)
                    Message consolog " SNR=%06.1f" $data_image($i,sb_$etoile)
                    Message consolog " N=%07.2f" $data_image($i,nb_pixels_$etoile)
                    Message consolog " B=%06.1f" $data_image($i,fond_$etoile)
                    Message consolog " Nb=%07.2f\n" $data_image($i,nb_pixels_fond_$etoile)
                }
            }
        }
    }

    #*************************************************************************#
    #*************  AffichageVariable  ***************************************#
    #*************************************************************************#
    proc AffichageVariable {mode c y t} {
        global audace

        pack $t.trame1 $t.trame2

        # Le mode modélisation n'a plus de paramètres spécifiques
        # On garde le mécanisme de la trame dynamique, des fois qu'il faille
        # en remettre ...
        if {$mode == 1} {
            # Cas ouverture
            pack forget $t.trame_mod
            pack $t.trame_ouv -in $t
            set fils $t.trame_ouv
        } else {
            # Cas modélisation
            pack forget $t.trame_ouv
            pack $t.trame_mod -in $t
            set fils $t.trame_mod
        }

        pack $y -side right -fill y
        pack $c -side left -fill both -expand true
        pack $audace(base).saisie.listes -side top -fill both -expand true
        pack $audace(base).saisie.trame3 -side top -fill both -expand true

        # Réglage de la taille de la fenêtre et de l'ascenseur
        if {![catch {tkwait visibility $fils} visible]} {
            set bbox [grid bbox $t 0 0]
            set incr [lindex $bbox 3]
            set largeur [winfo reqwidth $t]
            set hauteur [winfo reqheight $t]
            $c config -scrollregion "0 0 $largeur $hauteur"
            $c config -yscrollincrement $incr
            set hauteur_max [expr [winfo screenheight .] * 3 / 4]
            if {$hauteur > $hauteur_max} {set hauteur $hauteur_max}
            $c config -width $largeur -height $hauteur
        }
    }

    #*************************************************************************#
    #*************  AnnuleSaisie  ********************************************#
    #*************************************************************************#
    proc AnnuleSaisie {} {
        global audace

        variable demande_arret

        set demande_arret 1
        EffaceMotif astres
        destroy $audace(base).saisie
        update idletasks
    }

    #*************************************************************************#
    #*************  ArretScript  *********************************************#
    #*************************************************************************#
    proc ArretScript {} {
        global audace
        variable demande_arret

        set demande_arret 1
        EffaceMotif astres
        catch {destroy $audace(base).selection_etoile}
        catch {destroy $audace(base).selection_aster}
        catch { destroy $audace(base).selection_indes}
        catch {destroy $audace(base).bouton_arret_color_invariant}
    }

    #*************************************************************************#
    #*************  BoutonArret  *********************************************#
    #*************************************************************************#
    # Mise en place du bouton permettant d'arrêter les calculs.               #
    #*************************************************************************#
    proc BoutonArret {} {
        global color audace
        variable texte_photo
        variable police

        set b [toplevel $audace(base).bouton_arret_color_invariant -class Toplevel -borderwidth 2 -bg $color(red) -relief groove]
        wm geometry $b +320+0
        wm resizable $b 0 0
        wm title $b ""
        wm transient $b .audace
        wm protocol $b WM_DELETE_WINDOW ::CalaPhot::Suppression

        frame $b.arret -borderwidth 5 -relief groove -bg $color(red)
        button $b.arret.b -text $texte_photo(arret) -command {set ::CalaPhot::demande_arret 1} -bg $color(white) -activebackground $color(red) -fg $color(red)
        pack $b.arret.b -side left -padx 10 -pady 10
        pack $b.arret

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $b
    }

    #*************************************************************************#
    #*************  CalculEllipses  ******************************************#
    #*************************************************************************#
    # Calcul des paramètres des ellipses des étoiles de reference             #
    #  Retourne la moyenne de ces paramètres, ou une liste nulle si toutes    #
    #  les modélisations ont echoués                                          #
    #*************************************************************************#
    proc CalculEllipses {image} {
        global audace
        variable pos_theo
        variable parametres
        variable data_script
        variable data_image

        set fwhm_x 0
        set fwhm_y 0
        set ro 0
        set alpha 0
        set n 0
        set r1x 0
        set r1y 0
        set r2 0
        set r3 0
        set bon 0

        for {set etoile 1} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
            if {$data_image($image,centroide_x_$etoile) >= 0} {
                set fwhm_x [expr $fwhm_x + $data_image($image,fwhm1_$etoile)]
                set fwhm_y [expr $fwhm_y + $data_image($image,fwhm1_$etoile)]
                set ro [expr $ro + $data_image($image,ro_$etoile)]
                set alpha [expr $alpha + $data_image($image,alpha_$etoile)]
                incr n
            }
        }

        if {$n > 0} {
            set fwhm_x [expr $fwhm_x / $n]
            set fwhm_y [expr $fwhm_y / $n]
            set ro [expr $ro / $n]
            set alpha [expr $alpha / $n]

            set r1x [expr $parametres(rayon1) * 0.600561 * $fwhm_x]
            set r1y [expr $parametres(rayon1) * 0.600561 * $fwhm_y]
            # r2 et r3 sont calcules par rapport au plus grand des 2 fwhm
            if {$fwhm_x > $fwhm_y} {
                set r2 [expr $parametres(rayon2) * 0.600561 * $fwhm_x]
                set r3 [expr $parametres(rayon3) * 0.600561 * $fwhm_x]
            } else {
                set r2 [expr $parametres(rayon2) * 0.600561 * $fwhm_y]
                set r3 [expr $parametres(rayon3) * 0.600561 * $fwhm_y]
            }
            set bon 1
        }

        set data_image($image,r1x) $r1x
        set data_image($image,r1y) $r1y
        set data_image($image,r2) $r2
        set data_image($image,r3) $r3
        set data_image($image,ro) $ro
        set data_image($image,alpha) $alpha
        return [list $bon $r1x $r1y $r2 $r3 $ro $alpha]
    }

    #*************************************************************************#
    #*************  CalculErreurGlobal  **************************************#
    #*************************************************************************#
    proc CalculErreurGlobal {image} {
        # L' incertitude sur la magnitudes de la super-étoile est calculé à partir des incertitudes sur chacune des étoiles de référence. Il s'agit de data_image(image,incertitude_ref_0).
        # Mais pour chacune des autres super-étoiles (qui servent aux calcul des magnitude de ces étoiles de référence, à titre de vérification), on effectue le même calcul d incertitudes, stocké dans data_image(image,incertitude_ref_etoile).
        # Ensuite est calculée l'incertitude générale sur l'étoile, en additionnant son incertitude propre (calculée par CalculErreur) et celle de son étoile de référence.
        # Formules générales :
        # incertitude_ref(etoile) = [somme(10^(-0.4*mag(etoile)) * incertitude_propre(etoile))] / [somme(10^(-0.4*mag(etoile)))]
        # incertitude(etoile) = incertitude_propre(etoile) + incertitude_ref(etoile)
        # Sortie : pour chaque etoile, data_image(image,incertitude_ref_etoile)

        variable nombre_etoile
        variable data_image

        for {set i 0} {$i <= $nombre_etoile} {incr i} {
            set inc1 0.0
            set inc2 0.0
            for {set j 1} {$j <= $nombre_etoile} {incr j} {
                if {($i != $j)} {
                    set t [expr pow(10.0, -0.4 * $data_image($image,mag_$j))]
                    set inc1 [expr $inc1 + $t * $data_image($image,erreur_mag_$j)]
                    set inc2 [expr $inc2 + $t]
                } else {
                    if {$nombre_etoile == 1} {
                        set inc1 $data_image($image,erreur_mag_1)
                        set inc2 1
                    }
                }
            }
            set data_image($image,incertitude_ref_$i) [expr $inc1 / $inc2]
            set data_image($image,incertitude_$i) [expr $data_image($image,incertitude_ref_$i) + $data_image($image,erreur_mag_$i)]
        }
    }

    #*************************************************************************#
    #*************  CalculErreurModelisation  ********************************#
    #*************************************************************************#
    proc CalculErreurModelisation {image etoile} {
        variable data_image

        set data_image($image,sb_$etoile) [expr $data_image($image,amplitude_$etoile) / $data_image($image,sigma_amplitude_$etoile)]
        set data_image($image,erreur_mag_$etoile) [expr 1.08574 * $data_image($image,sigma_flux_$etoile) / $data_image($image,flux_$etoile)]
        set data_image($image,bruit_flux_$etoile) $data_image($image,sigma_flux_$etoile)
    }

    #*************************************************************************#
    #*************  CalculErreurOuverture  ***********************************#
    #*************************************************************************#
    proc CalculErreurOuverture {image etoile} {
        variable data_image
        variable parametres
        # Formule tirée de Handbook of CCD astronomy, SB Howell (suggestion de A. Klotz)
#        Message test "CEO : Im %d Et %d\n" $image $etoile

        set S [expr double($data_image($image,flux_$etoile))]
        set n [expr double($data_image($image,nb_pixels_$etoile))]
        set p [expr double($data_image($image,nb_pixels_fond_$etoile))]
        set b [expr double($data_image($image,fond_$etoile))]
        set sigma [expr double($data_image($image,sigma_fond_$etoile))]

        set g [expr double($parametres(gain_camera))]
        set r [expr double($parametres(bruit_lecture))]

    # Valeurs de tests tirées du bouquin de Howell
#    set S 24013
#    set g 5
#    set n 1
#    set p 200
#    set b 620
# On doit obtenir S/B = 342, erreur_mag=0.003

        set nn [expr $n * (1 + $n / $p)]
        set t1 [expr $S * $g]
        set t2 [expr $nn * $b * $g]
        set t3 [expr $nn * $r * $r]
        set signal_bruit [expr $t1 / sqrt($t1 + $t2 + $t3)]
        set erreur_mag [expr 1.085 / $signal_bruit]
        set bruit_flux [expr $S / $signal_bruit]

        return [list $signal_bruit $erreur_mag $bruit_flux]
    }

    #*************************************************************************#
    #*************  CalculMagSuperEtoile  ************************************#
    #*************************************************************************#
    proc CalculMagSuperEtoile {} {
        # La super-étoile est calculée à partir des magnitudes de toutes les étoiles de réfé ence. Il s agit de data_script(mag_ref_0).
        # Mais pour chacune des étoiles de ref. est aussi calculée une super-étoile faite à partir des magnitudes des autres étoiles de ref., valeur stockée dans data_script(mag_ref_$etoile)
        # Formule générale : mag_ref = -2.5 log10 (somme (10 ^ (-0.4 * mag(etoile))))
        # Sortie : pour chaque étoile, data_image(etoile, mag_ref)

        variable nombre_etoile
        variable pos_theo
        variable data_script

        for {set i 0} {$i <= $nombre_etoile} {incr i} {
            set mag_ref 0.0
            for {set j 1} {$j <= $nombre_etoile} {incr j} {
                if {($i != $j)} {
                    set f [expr pow(10.0, -0.4 * [lindex $pos_theo($j) 2])]
                    set mag_ref [expr $mag_ref + $f]
                } else {
                    if {($nombre_etoile == 1)} {
                        set mag_ref [expr pow(10.0, -0.4 * [lindex $pos_theo(1) 2])]
                    }
                }
            }
            set data_script(mag_ref_$i) [expr -2.5 * log10($mag_ref)]
        }

#        for {set i 0} {$i <= $nombre_etoile} {incr i} {
#            Message console "MR_ %d = %10.7f\n" $i $data_script(mag_ref_${i})
#        }
    }

    #*************************************************************************#
    #*************  CalculPositionsReelles  **********************************#
    #*************************************************************************#
    proc CalculPositionsReelles {image} {
        global audace
        variable pos_theo
        variable pos_reel
        variable parametres
        variable data_image
        variable data_script
        variable pos_theo_indes
        variable pos_reel_indes

        # Calcul de toutes les positions réelles des astres (astéroïde compris), en tenant compte du décalage entre images, pour les astres à mesurer
        for {set j 0} {$j <= $data_script(nombre_etoile)} {incr j} {
            set x1 [expr round([lindex $pos_theo($j) 0] + $data_image($image,decalage_x) - $parametres(tailleboite))]
            set y1 [expr round([lindex $pos_theo($j) 1] + $data_image($image,decalage_y) - $parametres(tailleboite))]
            set x2 [expr round([lindex $pos_theo($j) 0] + $data_image($image,decalage_x) + $parametres(tailleboite))]
            set y2 [expr round([lindex $pos_theo($j) 1] + $data_image($image,decalage_y) + $parametres(tailleboite))]

            # Affinage du centroïde de l'étoile
            if {[catch {buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]} coordonnees]} {
                return -1
            }
            set pos_reel($image,$j) $coordonnees
        }

        for {set j 1} {$j <= $data_script(nombre_indes)} {incr j} {
            set x1 [expr round([lindex $pos_theo_indes($j) 0] + $data_image($image,decalage_x) - $parametres(tailleboite))]
            set y1 [expr round([lindex $pos_theo_indes($j) 1] + $data_image($image,decalage_y) - $parametres(tailleboite))]
            set x2 [expr round([lindex $pos_theo_indes($j) 0] + $data_image($image,decalage_x) + $parametres(tailleboite))]
            set y2 [expr round([lindex $pos_theo_indes($j) 1] + $data_image($image,decalage_y) + $parametres(tailleboite))]

            # Affinage du centroÃ¯de de l'étoile
            set coordonnees [buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]]
            set pos_reel_indes($image,$j) $coordonnees
        }
        return 0
    }

    #*************************************************************************#
    #*************  Centroide  ***********************************************#
    #*************************************************************************#
    proc Centroide {} {
        global audace
        set rect [ ::confVisu::getBox $audace(visuNo) ]
        if { $rect != "" } {
            # Récupération des coordonnées de la boite de sélection
            set x1 [lindex $rect 0]
            set y1 [lindex $rect 1]
            set x2 [lindex $rect 2]
            set y2 [lindex $rect 3]
            # Calcul du centre de l'étoile
            # Selon Alain Klotz, "buf$audace(bufNo) centro" fait les choses suivantes
            # 1. recherche la position du pixel maximal dans la fenetre
            # 2. effectue l\'histogramme des valeurs de pixels dans la fenetre
            # 3. trie les valeurs de l\'histogramme et prend la valeur du fond
            #     comme la valeur à 20% (c'est à dire un peu moins que la médiane
            #     à 50%).
            # 4. Calcule un seuil avec la formule suivante :
            #     seuil=fond+0.7*(maxi-fond)
            # 5. Pour chaque pixel de la fenetre, on calcule la valeur = pixel - seuil
            #     et si cette valeur est positive, le pixel intervient dans le
            #     calcul du barycentre photométrique.
            # 7. Le resultat consiste en trois valeurs :
            #     Le barycentre X,
            #     Le barycentre Y,
            #     La différence (en pixels) entre la position du pixel de valeur
            #     maximale et la position du barycentre.
            return [buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]]
        } else {
            return [list]
        }
    }

    #*************************************************************************#
    #*************  ContinuationAsteroide  ***********************************#
    #*************************************************************************#
    proc ContinuationAsteroide {indice nom_image} {
        global audace
        variable texte_photo
        variable coord_aster

        if {$indice == 2} {
            if {[array size coord_aster] != 2} {
                tk_messageBox -message $texte_photo(pas_asteroide) -icon error -title $texte_photo(probleme)
            } else {
                Message consolog "----------------------------\n"
                Message consolog "------------%s--------------\n" $texte_photo(asteroide)
                Message consolog "----------------------------\n"
                Message console "%s (%u): %4.2f %4.2f\n" $texte_photo(asteroide) 1 [lindex $coord_aster(1) 0] [lindex $coord_aster(1) 1]
                Message console "%s (%u): %4.2f %4.2f\n" $texte_photo(asteroide) 2 [lindex $coord_aster(2) 0] [lindex $coord_aster(2) 1]

                destroy $audace(base).selection_aster
            }
        } else {
            destroy $audace(base).selection_aster
            AffichageMenuAsteroide 2 $nom_image
        }
    }

    #*************************************************************************#
    #*************  ContinuationEtoiles  *************************************#
    #*************************************************************************#
    proc ContinuationEtoiles {} {
        global audace
        variable nombre_etoile
        variable texte_photo
        variable pos_theo
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile

        if {$nombre_etoile <= 0} {
        tk_messageBox -message $texte_photo(pas_etoile) -icon error -title $texte_photo(probleme)
        } else {
            # On initialise le tableau pos_theo
            Message consolog "----------------------------\n"
            Message consolog "------------%s--------------\n" $texte_photo(etoile_reference)
            Message consolog "----------------------------\n"
            set j 1
            for {set i 0} {$i < $nombre_etoile} {incr i} {
                set cx [lindex $coord_etoile_x $i]
                set cy [lindex $coord_etoile_y $i]
                set m [lindex $mag_etoile $i]
                set pos_theo($j) [list $cx $cy $m]
                Message consolog "%s n%d: %4.2f %4.2f %4.2f\n" $texte_photo(etoile) $j $cx $cy $m
                incr j
            }
            destroy $audace(base).selection_etoile
        }
    }

    #*************************************************************************#
    #*************  ContinuationIndesirables  ********************************#
    #*************************************************************************#
    proc ContinuationIndesirables {} {
        global audace
        variable nombre_indes
        variable texte_photo
        variable pos_theo_indes
        variable coord_indes_x
        variable coord_indes_y

        # On initialise le tableau pos_theo_indes
        if {$nombre_indes <= 0} {
            Message consolog "\n------------%s--------------\n" $texte_photo(pas_etoile_ind)
        } else {
            Message consolog "----------------------------\n"
            Message consolog "------------%s--------------\n" $texte_photo(et_indesirables)
            Message consolog "----------------------------\n"
            set j 1
            for {set i 0} {$i < $nombre_indes} {incr i} {
                set cx [lindex $coord_indes_x $i]
                set cy [lindex $coord_indes_y $i]
                set pos_theo_indes($j) [list $cx $cy]
                Message consolog "%s (%d): %4.2f %4.2f\n" $texte_photo(etoile) $j $cx $cy
                incr j
            }
        }
        EffaceMotif astres
        destroy $audace(base).selection_indes
    }

    #*************************************************************************#
    #*************  CourbeLumiere  *******************************************#
    #*************************************************************************#
    #  Affichage de la courbe de lumière finale                               #
    #*************************************************************************#
    proc CourbeLumiere {} {
        global audace color
        variable parametres
        variable data_image
        variable texte_photo
        variable liste_image

        set vecteur_x [list]
        set vecteur_y1 [list]
        set vecteur_y2 [list]
        set vecteur_y3 [list]
        set premier 1

        foreach i $liste_image {
            if {$data_image($i,valide) == "Y"} {
                if {$premier == 1} {
                    set mag_0_premier $data_image($i,mag_0)
                    set mag_1_premier $data_image($i,mag_1)
                    set cste_mag_premier $data_image($i,constante_mag)
                    set premier 0
                }
                lappend vecteur_x $data_image($i,date)
                lappend vecteur_y1 [expr $data_image($i,mag_0) - $mag_0_premier]
                lappend vecteur_y2 [expr $data_image($i,constante_mag) - $cste_mag_premier]
                lappend vecteur_y3 [expr $data_image($i,mag_1) - $mag_1_premier]
            }
        }

        if {[llength $vecteur_x] == 0} {
            Message console "%s\n" $texte_photo(rien_a_voir)
            return
        }

        set baseplotxy $audace(base)
        append baseplotxy ".calaphot"

        catch {destroy $baseplotxy}
        toplevel $baseplotxy
        wm geometry $baseplotxy 631x453+100+0
        wm maxsize $baseplotxy [winfo screenwidth .] [winfo screenheight .]
        wm minsize $baseplotxy 200 200
        wm resizable $baseplotxy 1 1

        set titre "Calaphot "
        append titre $::CalaPhot::numero_version
        wm title $baseplotxy $titre

        ::blt::graph $baseplotxy.xy
        $baseplotxy.xy configure -title $parametres(objet)
        catch {::blt::vector delete vx }
        catch {::blt::vector delete vy1 }
        catch {::blt::vector delete vy2 }
        catch {::blt::vector delete vy3 }
        ::blt::vector create vx
        vx set $vecteur_x
        ::blt::vector create vy1
        vy1 set $vecteur_y1
        ::blt::vector create vy2
        vy2 set $vecteur_y2
        ::blt::vector create vy3
        vy3 set $vecteur_y3

        $baseplotxy.xy element create line1 -xdata vx -ydata vy1 -symbol splus -color $color(red) -label $parametres(objet) -linewidth 3
        $baseplotxy.xy element create line2 -xdata vx -ydata vy2 -symbol splus -color $color(green) -label $texte_photo(constante_mag)
        $baseplotxy.xy element create line3 -xdata vx -ydata vy3 -symbol splus -color $color(blue) -label $texte_photo(reference_sacc)
        $baseplotxy.xy axis configure x -title $texte_photo(jour_julien)
        $baseplotxy.xy axis configure y -title $texte_photo(magnitude)

        $baseplotxy.xy legend configure -font {helvetica 10} -position bottom
        $baseplotxy.xy grid on

        $baseplotxy.xy crosshairs on
        $baseplotxy.xy crosshairs configure -hide no -color $color(black)
        bind $baseplotxy.xy <Motion> {
            set x_limites [%W axis limits x]
            set xmin [lindex $x_limites 0]
            set xmax [lindex $x_limites 1]
            set y_limites [%W axis limits y]
            set ymin [lindex $y_limites 0]
            set ymax [lindex $y_limites 1]
            %W crosshairs configure -position @%x,%y
            set XY [%W invtransform %x %y]
            set X [lindex $XY 0]
            set Y [lindex $XY 1]
            set xy_aff [list [expr $xmin + (($xmax - $xmin) / 4)] [expr $ymin + (($ymax - $ymin) / 4 ) ]]
            if {($X <= $xmax) && ($X >= $xmin) && ($Y <= $ymax) && ($Y >= $ymin)} {
                %W marker create text -name cx -coords $xy_aff -text $X -anchor se -yoffset -10 -font {helvetica 8}
                %W marker create text -name cy -coords $xy_aff -text $Y -anchor se -yoffset 10 -font {helvetica 8}
            }
        }
        pack $baseplotxy.xy -expand 1 -fill both
        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $baseplotxy

        set nom_fichier [file join $audace(rep_images) [file rootname [file tail $parametres(fichier_cl)] ] ]
        append nom_fichier ".ps"

        catch {$baseplotxy.xy postscript output $nom_fichier -maxpect yes -decorations yes -landscape 1}

        # Attente de la fin de l'affichage de la courbe de lumière
        update idletasks
        tkwait window $baseplotxy

#    ScriptCourbeLumiere vx vy1 vy2 vy3
    }

    #*************************************************************************#
    #*************  CourbeLumiereTemporaire  *********************************#
    #*************************************************************************#
    #  Affichage de la courbe de lumière en cours de traitement (sans         #
    #  filtrage des donnéees                                                  #
    #*************************************************************************#
    proc CourbeLumiereTemporaire {vx_temp vy1_temp vy2_temp vy3_temp} {
        global audace color
        variable texte_photo
        variable parametres

        set base $audace(base)
        append base ".calaphot"

        catch {destroy $base}
        toplevel $base
        wm geometry $base 631x453+50+50
        wm maxsize $base [winfo screenwidth .] [winfo screenheight .]
        wm minsize $base 200 200
        wm resizable $base 1 1

        set titre "Calaphot "
        append titre $::CalaPhot::numero_version
        wm title $base $titre

        set xy [graph $base.xy -title $parametres(objet)]

        $xy element create line1 -xdata vx_temp -ydata vy1_temp -symbol splus -color $color(red) -label $parametres(objet) -linewidth 3
        $xy element create line2 -xdata vx_temp -ydata vy2_temp -symbol splus -color $color(green) -label $texte_photo(constante_mag)
        $xy element create line3 -xdata vx_temp -ydata vy3_temp -symbol splus -color $color(blue) -label $texte_photo(reference_sacc)
        $xy axis configure x -title $texte_photo(jour_julien)
        $xy axis configure y -title $texte_photo(magnitude)

        $xy legend configure -font {helvetica 10} -position bottom
        $xy grid on
        pack $xy -expand 1 -fill both
        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $base
        update idletasks
    }

    #*************************************************************************#
    #*************  DateImage  ***********************************************#
    #*************************************************************************#
    proc DateImage {i} {
        global audace
        variable data_image
        variable parametres

        # Détermination du temps de pose de l'image
        # !!! On suppose que la date stockée dans l'image est celle du DEBUT de la pose
        set expo [lindex [buf$audace(bufNo) getkwd "EXPTIME"] 1]
        if {[string length $expo] == 0} {
            set expo [lindex [buf$audace(bufNo) getkwd "EXPOSURE"] 1]
        }
        if {[string length $expo] == 0} {
            set expo [lindex [buf$audace(bufNo) getkwd "EXP_TIME"] 1]
        }
        if {[string length $expo] == 0} {
            set expo 1
        }
        if {$parametres(pose_minute) == 1} {
            set expo [expr $expo * 60.0]
        }
        set data_image($i,temps_expo) $expo

        # Calcul de la date exacte
        set jd [JourJulienImage]
        if {$parametres(date_images) == 0} {
            # Cas début de pose (on rajoute le 1/2 temps de pose converti en jour julien).
            set data_image($i,date) [expr $jd + ($expo / 172800.0)]
        } else {
            # Cas milieu de pose
            set data_image($i,date) $jd
        }
    }

    #*************************************************************************#
    #*************  DateReferences  ******************************************#
    #*************************************************************************#
    proc DatesReferences {} {
        global audace
        variable parametres
        variable liste_image
        # Load & display first image
        set premier [lindex $liste_image 0]
        set nom_fichier $parametres(source)$premier
        loadima $nom_fichier
        set jdFirst [JourJulienImage]

        # Load & display last image
        set dernier [lindex $liste_image end]
        set nom_fichier $parametres(source)$dernier
        loadima $nom_fichier
        set jdLast [JourJulienImage]
        set delta_jd [expr $jdLast-$jdFirst]

        return [list $jdFirst $jdLast $delta_jd]
    }

    #*************************************************************************#
    #*************  DecalageImage  *******************************************#
    #*************************************************************************#
    proc DecalageImage {} {
        global audace

        # --- recupere la liste des mots clé  de l'image FITS
        set listkey [lsort -dictionary [buf$audace(bufNo) getkwds]]
        # --- on evalue chaque (each) mot clé
        foreach key $listkey {
            # --- on extrait les infos de la ligne FITS
            # --- qui correspond au mot clé...
            set listligne [buf$audace(bufNo) getkwd $key]
            # --- on évalue la valeur de la ligne FITS
            set value [lindex $listligne 1]
            # --- si la valeur vaut IMA/SERIES REGISTER ...
            if {$value == "IMA/SERIES REGISTER"} {
                # --- alors on extrait l'indice du mot clé TT
                set keyname [lindex $listligne 0]
                set lenkeyname [string length $keyname]
                set indice [string range $keyname 2 [expr $lenkeyname] ]
            }
        }
        if {![info exists indice]} {
            return [list 0 0]
        } else {
            # On a maintenant repere la fonction TT qui pointe sur la derniere registration.
            # --- on recherche la ligne FITS contenant le mot clé indice+1
            incr indice
            set listligne [buf$audace(bufNo) getkwd "TT$indice"]

            # --- on évalue la valeur de la ligne FITS
            set param1 [lindex $listligne 1]
            set dx [lindex [split $param1] 3]

            # --- on recherche la ligne FITS contenant le mot clé indice+2
            incr indice
            set listligne [buf$audace(bufNo) getkwd "TT$indice"]

            # --- on évalue la valeur de la ligne FITS
            set param2 [lindex $listligne 1]
            set dy [lindex $param2 2]

            # Fin de la lecture du decalage
            return [list $dx $dy]
        }
    }

    #**************************************************************************#
    #*************  DeselectionneEtoile  **************************************#
    #**************************************************************************#
    proc DeselectionneEtoiles {} {
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile
        variable texte_photo
        variable nombre_etoile

        if {![info exists nombre_etoile]} {
            set nombre_etoile 0
        }
        set pos [Centroide]
        if {([llength $pos] != 0) && ($nombre_etoile > 0)} {
            incr nombre_etoile -1
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]
            set ix [lsearch $coord_etoile_x $cx]
            set iy [lsearch $coord_etoile_y $cy]
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                set coord_etoile_x [lreplace $coord_etoile_x $ix $ix]
                set coord_etoile_y [lreplace $coord_etoile_y $iy $iy]
                set mag_etoile [lreplace $mag_etoile $iy $iy]
                EffaceMotif etoile_${cx}_${cy}
            } else {
                tk_messageBox -message $texte_photo(etoile_inconnue) -icon error -title $texte_photo(probleme)
            }
        }
    }

    #**************************************************************************#
    #*************  DeselectionneIndesirables  ********************************#
    #**************************************************************************#
    proc DeselectionneIndesirables {} {
        variable coord_indes_x
        variable coord_indes_y
        variable texte_photo
        variable nombre_indes

        if {![info exists nombre_indes]} {
            set nombre_indes 0
        }
        set pos [Centroide]
        if {([llength $pos] != 0) && ($nombre_indes > 0)} {
            incr nombre_indes -1
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]
            set ix [lsearch $coord_indes_x $cx]
            set iy [lsearch $coord_indes_y $cy]
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                set coord_indes_x [lreplace $coord_indes_x $ix $ix]
                set coord_indes_y [lreplace $coord_indes_y $iy $iy]
                EffaceMotif etoile_${cx}_${cy}
            } else {
                tk_messageBox -message $texte_photo(etoile_inconnue) -icon error -title $texte_photo(probleme)
            }
        }
    }

    #**************************************************************************#
    #*************  Dessin  ***************************************************#
    #**************************************************************************#
    proc Dessin {motif centre taille couleur marqueur} {
        global audace

        set x [lindex $centre 0]
        set y [lindex $centre 1]
        set rh [lindex $taille 0]
        set rv [lindex $taille 1]
        set x1 [expr round($x - $rh)]
        set y1 [expr round($y - $rv)]
        set x2 [expr round($x + $rh)]
        set y2 [expr round($y + $rv)]

        set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
        switch -exact -- $motif {
            "ovale" {
                $audace(hCanvas) create oval [expr $x1-1] [expr $naxis2-$y1] [expr $x2-1] [expr $naxis2-$y2] -outline $couleur -tags [list astres $marqueur]
            }
            "rectangle" {
                $audace(hCanvas) create rect [expr $x1-1] [expr $naxis2-$y1] [expr $x2-1] [expr $naxis2-$y2] -outline $couleur -tags [list astres $marqueur]
            }
            "verticale" {
                $audace(hCanvas) create line $x [expr $naxis2-$y1] $x [expr $naxis2-$y2] -fill $couleur -tags [list astres $marqueur]
            }
            "horizontale" {
                $audace(hCanvas) create line [expr $x1-1] [expr $naxis2-$y] [expr $x2] [expr $naxis2-$y] -fill $couleur -tags [list astres $marqueur]
            }
        }
        update idletasks
    }

    #**************************************************************************#
    #*************  Dessin2  **************************************************#
    #**************************************************************************#
    proc Dessin2 {image etoile facteur couleur marqueur} {
        global audace
        variable data_image

        set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]

        # centroïde
        set x0 $data_image($image,centroide_x_$etoile)
        set y0 $data_image($image,centroide_y_$etoile)

        # fwhms
        set f1 $data_image($image,fwhm1_$etoile)
        set f2 $data_image($image,fwhm2_$etoile)

        # angle
        set alpha $data_image($image,alpha_$etoile)

        # recupération de alpha en radian
        set alphar [expr $alpha * 0.017453]
#        set c_alpha [expr cos($alphar)]
#        set s_alpha [expr sin($alphar)]

        set ellipse [DessinEllipse $x0 $y0 [expr $f1 * $facteur] [expr $f2 * $facteur] $alphar $naxis2]
        $audace(hCanvas) create line $ellipse -joinstyle round -fill $couleur -arrow none -smooth true -tags [list astres $marqueur]
    }

    #**************************************************************************#
    #*************  DessinEllipse  ********************************************#
    #**************************************************************************#
    proc DessinEllipse {x0 y0 a b alpha naxis2} {
        set ellipse [list]

        #Calcul de l'ellipse par son éq. paramétrique :
        # x = a * cos(t), y = b * sin(t)
        # t varie de 0 à 2*pi, par pas de pi/100
        # puis rotation d'angle a et translation  de (x0, y0)
        for {set t 0} {$t < 6.2831853} {set t [expr $t + .0314259265]} {
            set x [expr $a * cos($t)]
            set y [expr $b * sin($t)]
            set X [expr $x * cos($alpha) - $y * sin($alpha) + $x0]
            set Y [expr $x * sin($alpha) + $y * cos($alpha) + $y0]
            set px [expr int($X + 0.5) - 1]
            set py [expr $naxis2 - int($Y + 0.5)]
            lappend ellipse $px $py
        }
        return $ellipse
    }


    #*************************************************************************#
    #*************  EffaceMotif  *********************************************#
    #*************************************************************************#
    proc EffaceMotif {marqueur} {
        global audace
        $audace(hCanvas) delete $marqueur
    }

    #*************************************************************************#
    #*************  Entête  **************************************************#
    #*************************************************************************#
    proc Entete {} {
        variable parametres
        variable data_script

        switch -exact -- $parametres(affichage) {
        0 {
            # Minimal
            Message consolog "No      JJ          "
            for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
                Message consolog " |   Mag.   Err  "
            }
            Message consolog "\n"
        }
        1 {
            # Normal
            Message consolog "No      JJ          "
            for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
                Message consolog " |   Mag.       Err        Flux        S/N "
            }
            Message consolog " | mag.abs    | v\n"
        }
        2 {
            # Maximal
            Message consolog "No      JJ               r1x      r1y     r2     r3    "
            Message consolog " |   Mag.       Err        Flux        S/N        N       Bg       NBg        "
            Message consolog " | mag.abs    | v\n"
            }
        }
    }

    #*************************************************************************#
    #*************  FiltrageConstanteMag  ************************************#
    #*************************************************************************#
    proc FiltrageConstanteMag {} {
        variable parametres
        variable data_image
        variable texte_photo
        variable liste_image

        set l [llength $liste_image]

        for {set i 0} {$i < $l} {incr i} {
            set sg 0.0
            set sg2 0.0
            set ng 0
            for {set j -5} {$j <= -1} {incr j} {
                set image [lindex $liste_image $i]
                if {([expr $i + $j] >= 0)} {
                    set n [lindex $liste_image [expr $i + $j]]
                    if {$data_image($n,valide) == "Y"} {
                        set sg [expr $sg + $data_image($n,constante_mag)]
                        set sg2 [expr $sg2 + $data_image($n,constante_mag) * $data_image($n,constante_mag)]
                        incr ng
                    }
                }
            }
            for {set j 1} {$j <= 5} {incr j} {
                if {([expr $i + $j] < $l)} {
                    set n [lindex $liste_image [expr $i + $j]]
                    if {$data_image($n,valide) == "Y"} {
                        set sg [expr $sg + $data_image($n,constante_mag)]
                        set sg2 [expr $sg2 + $data_image($n,constante_mag) * $data_image($n,constante_mag)]
                        incr ng
                    }
                }
            }
            if {$ng != 0} {
                set msg [expr $sg / $ng]
                set ssg [expr (($sg2 / $ng) - ($msg * $msg))]
                if { $ssg < 0.0} {
                    set data_image($image,valide) "N"
                    Message console "%s %05d\n" $texte_photo(image_rejetee) $image
                } else {
                    if {$data_image($image,valide) == "Y"} {
                        if {[expr abs($data_image($image,constante_mag) - $msg)] > [expr 3.0 * sqrt($ssg)]} {
                            set data_image($image,valide) "N"
                            Message console "%s %05d\n" $texte_photo(image_rejetee) $image
                        }
                    }
                }
            } else {
                set data_image($image,valide) "N"
                Message console "%s %05d\n" $texte_photo(image_rejetee) $image
            }
        }
        # Fin de la boucle sur les images
        #set data_image($image,valide) "Y" ; # Klotz
    }

    #*************************************************************************#
    #*************  FiltrageSB  **********************************************#
    #*************************************************************************#
    proc FiltrageSB {i} {
        variable parametres
        variable data_image
        variable data_script

        # Algo simplissime : si un seul astre a un s/b < limite, l'image est invalidée
        #set data_image($i,valide) "Y"
        #for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
        #    if {$data_image($i,sb_$etoile) < $parametres(signal_bruit)} {
        #        set data_image($i,valide) "N"
        #        break;
        #    }
        #}
        # Algo plus complique : il faut au moins astre + l'asteroide avec a un s/b >= limite, pour aue l'image soit validée
        set data_image($i,valide) "N"
        set etoile 0
        if {$data_image($i,sb_$etoile) < $parametres(signal_bruit)} {
           return
        }
        set nvalid 0
        for {set etoile 1} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
            if {$data_image($i,sb_$etoile) >= $parametres(signal_bruit)} {
               incr nvalid
            }
        }
        if {$nvalid>0} {
           set data_image($i,valide) "Y"
        }
    }

    #*************************************************************************#
    #*************  jm_fitgauss2db  ******************************************#
    #*************************************************************************#
    # Note de Alain Klotz le 30 septembre 2007 :
    # Fonction pour inhiber les problemes de jm_fitgauss2d
    # (il faudra un jour analyser finement le code de jm_fitgauss2d
    # pour trouver pourquoi il ne converge pas sur des etoiles tres
    # etalées comme celles du T80 de l'OHP).
    proc jm_fitgauss2db { bufno box } {
      set temp [jm_fitgauss2d $bufno $box]
      if {[lindex $temp 0] != 0} {
         # La modélisation est correcte
         return $temp
      }
      # Echec de jm_fitgauss2d. On effectue une modelisation plus grossiere
      set valeurs [buf$bufno fitgauss $box]
      set dif 0.
      set intx [lindex $valeurs 0]
      set xc [lindex $valeurs 1]
      set fwhmx [lindex $valeurs 2]
      set bgx [lindex $valeurs 3]
      set inty [lindex $valeurs 4]
      set yc [lindex $valeurs 5]
      set fwhmy [lindex $valeurs 6]
      set bgy [lindex $valeurs 7]
      set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
      set if1 [ expr $intx*$if0 ]
      set if2 [ expr $inty*$if0 ]
      set if0 [ expr ($if1+$if2)/2. ]
      set dif [ expr abs($if1-$if0) ]
      set inte [expr ($intx+$inty)/2.]
      set dinte [expr abs($inte-$inty)]
      set bg [expr ($bgx+$bgy)/2.]
      set dbg [expr abs($bg-$bgy)]
      set convergence 1
      set iterations 1
      set valeurs_X0 $xc
      set valeurs_Y0 $yc
      set valeurs_Signal $inte
      set valeurs_Fond $bg
      set valeurs_Sigma_X $fwhmx
      set valeurs_Sigma_Y $fwhmy
      set valeurs_Ro 0.
      set valeurs_Alpha 0.
      set valeurs_Sigma_1 $fwhmx
      set valeurs_Sigma_2 $fwhmy
      set valeurs_Flux $if0
      set incertitudes_X0 0.1
      set incertitudes_Y0 0.1
      set incertitudes_Signal [expr 0.001*$inte]
      set incertitudes_Fond [expr 0.0001*$bg]
      set incertitudes_Sigma_X 0.01
      set incertitudes_Sigma_Y 0.01
      set incertitudes_Ro 0
      set incertitudes_Alpha 0
      set incertitudes_Sigma_1 0.01
      set incertitudes_Sigma_2 0.01
      set incertitudes_Flux [expr 0.001*$if0]
      return [list $convergence $iterations $valeurs_X0 $valeurs_Y0 $valeurs_Signal $valeurs_Fond $valeurs_Sigma_X $valeurs_Sigma_Y $valeurs_Ro $valeurs_Alpha $valeurs_Sigma_1 $valeurs_Sigma_2 $valeurs_Flux $incertitudes_X0 $incertitudes_Y0 $incertitudes_Signal $incertitudes_Fond $incertitudes_Sigma_X $incertitudes_Sigma_Y $incertitudes_Ro $incertitudes_Alpha $incertitudes_Sigma_1 $incertitudes_Sigma_2 $incertitudes_Flux]
    }

    #*************************************************************************#
    #*************  FluxOuverture  *******************************************#
    #*************************************************************************#
    proc FluxOuverture {i j} {
        global audace
        variable data_image
        variable parametres

        set temp [jm_fluxellipse $audace(bufNo) $data_image($i,centroide_x_$j) $data_image($i,centroide_y_$j) $data_image($i,r1x) $data_image($i,r1y) $data_image($i,ro) $data_image($i,r2) $data_image($i,r3) $parametres(surechantillonage)]
        set data_image($i,flux_$j) [lindex $temp 0]
        set data_image($i,nb_pixels_$j) [lindex $temp 1]
        set data_image($i,fond_$j) [lindex $temp 2]
        set data_image($i,nb_pixels_fond_$j) [lindex $temp 3]
        set data_image($i,sigma_fond_$j) [lindex $temp 4]
    }

    #*************************************************************************#
    #*************  FluxReference  *******************************************#
    #*************************************************************************#
    proc FluxReference {image} {
        # Le flux de la super-étoile est calculé à partir des flux de toutes les étoiles de référence. Il s'agit de data_image(image,flux_ref_0).
        # Mais pour chacune des étoiles de ref. est aussi calculé un flux de super-étoile fait à partir des flux des autres étoiles de ref., valeur stockée dans data_image(image,flux_ref_$etoile)
        # Formule générale : flux_ref = somme (flux(etoile))
        # Sortie : pour chaque étoile, data_image(etoile, flux_ref)

        variable nombre_etoile
        variable data_image

        for {set i 0} {$i <= $nombre_etoile} {incr i} {
            set flux_ref 0.0
            for {set j 1} {$j <= $nombre_etoile} {incr j} {
                if {($i != $j)} {
                    set flux_ref [expr $flux_ref + $data_image($image,flux_$j)]
                } else {
                    if {$nombre_etoile == 1} {
                        set flux_ref $data_image($image,flux_1)
                    }
                }
            }
            set data_image($image,flux_ref_$i) $flux_ref
        }
    }

    #*************************************************************************#
    #*************  InformationsImages  **************************************#
    #*************************************************************************#
    proc InformationsImages {} {
        global audace
        variable data_script

        set data_script(naxis1) [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
        set data_script(naxis2) [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
    }

    #*************************************************************************#
    #*************  Initialisations  *****************************************#
    #*************************************************************************#
    #  Initialisation des vecteurs. Suppression de fenêtres restantes         #
    #*************************************************************************#
    proc Initialisations {} {
        global audace
        variable vx_temp
        variable vy1_temp
        variable vy2_temp
        variable vy3_temp
        variable flux_premiere_etoile
        variable premier
        variable premier_temp

        catch {destroy $audace(base).saisie}
        catch {destroy $audace(base).selection_etoile}
        catch {destroy $audace(base).selection_aster}
        catch {destroy $audace(base).courbe_lumiere}
        catch {destroy $audace(base).bouton_arret_color_invariant}
        catch {unset flux_premiere_etoile}
        catch {unset premier}
        catch {unset premier_temp}

        catch {vector destroy vx_temp}
        catch {vector destroy vy1_temp}
        catch {vector destroy vy2_temp}
        catch {vector destroy vy3_temp}

        vector create vx_temp
        vector create vy1_temp
        vector create vy2_temp
        vector create vy3_temp
    }

    #**************************************************************************
    #*************************************************************************#
    #*************  JourJulienImage  *****************************************#
    # Cette procédure récupère le jour julien de l'image active.
    # Elle marche pour les images des logiciels suivants:
    # 1/ CCDSoft v5: DATE-OBS = la date uniquement,
    #               TIME-OBS = l'heure de dé ut en TU,
    #                 EXPOSURE = le temps d'exposition en secondes!
    # 2/ PRISM v4  : DATE-OBS = date & heure de dé ut de pose
    #                 (formt Y2K: 'aaaa-mm-jjThh:mm:ss.sss')
    #                 UT-START & UT-END sont valides mais non utilisé
    #                 EXPOSURE = le temps d'exposition en minutes!
    #*************************************************************************#
    proc JourJulienImage {} {
        global audace

        # Recherche du mot clef DATE-OBS dans l'en-té e FITS
        set date [buf$audace(bufNo) getkwd DATE-OBS]
        set date [lindex $date 1]
        # Si la date n'est pas au format Y2K (date+heure)...
        if {[string range $date 10 10] != "T"} {
            # Recherche mot clef TIME-OBS
            set time [buf$audace(bufNo) getkwd TIME-OBS]
            set time [lindex $time 1]
            if {[string length $time] != 0} {
                # ...convertit en format Y2K!
                set date [string range $date 0 9]
                set time [string range $time 0 7]
                append date "T"
                append date $time
        #        unset time
            } else {
                set time [buf$audace(bufNo) getkwd UT-START]
                set time [lindex $time 1]
                if {[string length $time] != 0} {
                    # ...convertit en format Y2K!
                    set date [string range $date 0 9]
                    set time [string range $time 0 7]
                    append date "T"
                    append date $time
        #            unset time
                } else {
                    Message console "Pas d 'heure"
                }
            }
        } else {set date [string range $date 0 22]}

        # Conversion en jour julien (Julian Day)
        set jd_instant [mc_date2jd $date]

        return $jd_instant
    }

    #*************************************************************************#
    #*************  MagnitudesEtoiles  ***************************************#
    #*************************************************************************#
    proc MagnitudesEtoiles {i} {
        variable data_image
        variable data_script
        variable parametres

        # Calcul par la formule de Pogson
        for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
            if {([expr $data_image($i,flux_$etoile)] > 0) &&  ([expr $data_image($i,flux_ref_$etoile)] > 0)} {
                set mag [expr $data_script(mag_ref_$etoile) - 2.5 * log10($data_image($i,flux_$etoile) / $data_image($i,flux_ref_$etoile))]
                set data_image($i,mag_$etoile) $mag

                if {$parametres(mode) == 0} {
                    # Modélisation
                    CalculErreurModelisation $i $etoile
                } else {
                    # Ouverture
                    set temp [CalculErreurOuverture $i $etoile]
                    set data_image($i,sb_$etoile) [lindex $temp 0]
                    set data_image($i,erreur_mag_$etoile) [lindex $temp 1]
                    set data_image($i,bruit_flux_$etoile) [lindex $temp 2]
                }
            } else {
#        Message test "ME i %d fe %d\n" $i [expr $data_image($i,flux_$etoile)]
                set data_image($i,mag_$etoile) 99.99
                set data_image($i,sb_$etoile) 0
                set data_image($i,erreur_mag_$etoile) 99.99
            set data_image($i,constante_mag) 99.99
            }
        }
        if {[expr $data_image($i,flux_ref_0)] > 0} {
            # Calcul de la constante des magnitudes ramenée à 1s de pose
            set data_image($i,constante_mag) [expr $data_script(mag_ref_0) + 2.5 * log10($data_image($i,flux_ref_0)) + 2.5 * log10(1.0 / $data_image($i,temps_expo))]
        }
    }

    #*************************************************************************#
    #*************  Message  *************************************************#
    #*************************************************************************#
    proc Message {niveau args} {
        variable test
        variable fileId
        variable fileName
        global audace

        switch -exact -- $niveau {
            console {
                ::console::disp [eval [concat {format} $args]]
                #::console::affiche_resultat [eval [concat {format} $args]]
                update idletasks
            }
            log {
                set fileId [open $fileName a]
                puts -nonewline $fileId [eval [concat {format} $args]]
                close $fileId
            }
            consolog {
                ::console::disp [eval [concat {format} $args]]
                #::console::affiche_resultat [eval [concat {format} $args]]
                update idletasks
                set fileId [open $fileName a]
                puts -nonewline $fileId [eval [concat {format} $args]]
                close $fileId
            }

            test {
                ::console::affiche_erreur [eval [concat {format} $args]]
                update idletasks
            }
        }

        if {[info exists test]} {
            if {[catch {open [file join $audace(rep_images) debug.log] a} filetest]} {
                Message console $filetest
                return
            } else {
                puts -nonewline $filetest [eval [concat {format} $args]]
                close $filetest
            }
        }
    }

    #*************************************************************************#
    #*************  Modelisation2D  ******************************************#
    #*************************************************************************#
    proc Modelisation2D {i j coordonnees} {
        global audace
        variable parametres
        variable data_image

        set x_etoile [lindex $coordonnees 0]
        set y_etoile [lindex $coordonnees 1]

        set x1 [expr round($x_etoile - $parametres(tailleboite))]
        set y1 [expr round($y_etoile - $parametres(tailleboite))]
        set x2 [expr round($x_etoile + $parametres(tailleboite))]
        set y2 [expr round($y_etoile + $parametres(tailleboite))]

        # Modélisation
        #::console::affiche_resultat "--------------------\nModelisation2D $i $j $coordonnees\n"
        set temp [jm_fitgauss2db $audace(bufNo) [list $x1 $y1 $x2 $y2]]
        #::console::affiche_resultat "temp=$temp\n-------------------\n"

        # Récupération des résultats
        if {[lindex $temp 0] != 0} {
            # La modélisation est correcte
            set data_image($i,flux_$j) [lindex $temp 12]
            set data_image($i,fond_$j) [lindex $temp 5]
            set data_image($i,amplitude_$j) [lindex $temp 4]
            set data_image($i,sigma_amplitude_$j) [lindex $temp 15]
            set data_image($i,sigma_flux_$j) [lindex $temp 23]
            set data_image($i,centroide_x_$j) [lindex $temp 2]
            set data_image($i,centroide_y_$j) [lindex $temp 3]
            set data_image($i,alpha_$j) [lindex $temp 9]
            set data_image($i,ro_$j) [lindex $temp 8]
            set data_image($i,fwhm1_$j) [lindex $temp 10]
            set data_image($i,fwhm2_$j) [lindex $temp 11]
            # Détermination d'un nombre de pixels équivalent à celui d'une ellipse d'axes 3 sigmas, pi*(3*0.600561*fwhm1)*(3*0.600561*fwhm2)
            set data_image($i,nb_pixels_$j) [expr 10.19781 * $data_image($i,fwhm1_$j) * $data_image($i,fwhm2_$j)]
            set data_image($i,nb_pixels_fond_$j) 0
        } else {
            # Attribution de valeurs bidons qui feront éliminer l'image
            set data_image($i,flux_$j) -1
            set data_image($i,fond_$j) 0
            set data_image($i,amplitude_$j) 0
            set data_image($i,sigma_amplitude_$j) 1
            set data_image($i,sigma_flux_$j) 1
            set data_image($i,centroide_x_$j) -1
            set data_image($i,centroide_y_$j) -1
            set data_image($i,alpha_$j) 0
            set data_image($i,ro_$j) 0
            set data_image($i,fwhm1_$j) 0
            set data_image($i,fwhm2_$j) 0
            set data_image($i,nb_pixels_$j) 0
            set data_image($i,nb_pixels_fond_$j) 0
        }
    }

    #**************************************************************************#
    #*************  PreAffiche  ***********************************************#
    #**************************************************************************#
    # Crée ce qu'il faut pour la courbe de lumière temporaire                  #
    #**************************************************************************#
    proc PreAffiche {i} {
        global audace
        variable premier_temp
        variable data_image
        variable mag_0_temp
        variable mag_1_temp
        variable mag_cste_temp
        variable vx_temp
        variable vy1_temp
        variable vy2_temp
        variable vy3_temp

        if {$data_image($i,valide) == "Y"} {
           if {![info exists premier_temp]} {
                set mag_0_temp $data_image($i,mag_0)
                set mag_1_temp $data_image($i,mag_1)
                set mag_cste_temp $data_image($i,constante_mag)
                set premier_temp 0
           }
           if {[info exists premier_temp]} {
                vx_temp append $data_image($i,date)
                vy1_temp append [expr $data_image($i,mag_0) - $mag_0_temp]
                vy2_temp append [expr $data_image($i,constante_mag) - $mag_cste_temp]
                vy3_temp append [expr $data_image($i,mag_1) - $mag_1_temp]
           }
           set sigma [expr sqrt([vector expr var(vy1_temp)])]
           if {$sigma != 0} {
               $audace(base).calaphot.xy axis configure y -min [expr -4.0 * $sigma] -max [expr 4.0 * $sigma]
           }
        }
    }

    #*************************************************************************#
    #*************  RecapitulationOptions  ***********************************#
    #*************************************************************************#
    proc RecapitulationOptions {} {
        variable parametres
        variable texte_photo

        Message consolog "\n--------------------------\n"
        Message consolog "%s\n" $texte_photo(recapitulation)
        foreach champ {objet operateur code_UAI type_capteur type_telescope diametre_telescope focale_telescope catalogue_reference source indice_premier indice_dernier tailleboite signal_bruit gain_camera bruit_lecture sortie fichier_cl} {
            Message consolog "%s : %s\n" $texte_photo($champ) $parametres($champ)
        }
        foreach champ {mode type_images date_images pose_minute format_sortie} {
            Message consolog "%s : %s\n" $texte_photo($champ) $texte_photo(${champ}_$parametres($champ))
        }
        if {$parametres(mode) == 1} {
            # Cas ouverture
            foreach champ {surechantillonage rayon1 rayon2 rayon3} {
                Message consolog "%s : %s\n" $texte_photo(o_$champ) $parametres($champ)
            }
        } else {
            # Cas modélisation
            foreach champ {rayon1 rayon2 rayon3} {
                Message consolog "%s : %s\n" $texte_photo(m_$champ) $parametres($champ)
            }
        }
        Message consolog "\n--------------------------\n"
    }

    #*************************************************************************#
    #*************  RecherchePlusBrillante  **********************************#
    #*************************************************************************#
    proc RecherchePlusBrillante {} {
        variable parametres
        variable nombre_etoile
        variable pos_theo

        set plus_brillante 1
        set mag_min [lindex $pos_theo(1) 2]
        for {set i 1} {$i <= $nombre_etoile} {incr i} {
            if {[lindex $pos_theo($i) 2] < $mag_min} {
                set mag_min [lindex $pos_theo($i) 2]
                set plus_brillante $i
            }
        }
        return $plus_brillante
    }

    #*************************************************************************#
    #*************  RecuperationParametres  **********************************#
    #*************************************************************************#
    proc RecuperationParametres {} {
        global audace
        variable parametres

        # Initialisation
        if {[info exists parametres]} {unset parametres}

        # Ouverture du fichier de paramètres
        set fichier [file join $audace(rep_scripts) calaphot calaphot.ini]

        if {[file exists $fichier]} {
            source $fichier
        }

        if {![info exists parametres(source)]} {set parametres(source) ""}
        if {![info exists parametres(indice_premier)]} {set parametres(indice_premier) 1}
        if {![info exists parametres(indice_dernier)]} {set parametres(indice_dernier) 20}
        if {![info exists parametres(tailleboite)]} {set parametres(tailleboite) 10}
        if {![info exists parametres(rayon1)]} {set parametres(rayon1) 3}
        if {![info exists parametres(rayon2)]} {set parametres(rayon2) 6}
        if {![info exists parametres(rayon3)]} {set parametres(rayon3) 9}
        if {![info exists parametres(sortie)]} {set parametres(sortie) "resultat.txt"}
        if {![info exists parametres(fichier_cl)]} {set parametres(fichier_cl) "resultat.ps"}
        if {![info exists parametres(mode)]} {set parametres(mode) 1}
        if {![info exists parametres(objet)]} {set parametres(objet) ""}
        if {![info exists parametres(operateur)]} {set parametres(operateur) ""}
        if {![info exists parametres(code_UAI)]} {set parametres(code_UAI) ""}
        if {![info exists parametres(surechantillonage)]} {set parametres(surechantillonage) 4}
        if {![info exists parametres(format_sortie)]} {set parametres(format_sortie) 0}
        if {![info exists parametres(type_images)]} {set parametres(type_images) 1}
        if {![info exists parametres(pose_minute)]} {set parametres(pose_minute) 0}
        if {![info exists parametres(signal_bruit)]} {set parametres(signal_bruit) 20}
        if {![info exists parametres(date_images)]} {set parametres(date_images) 0}
        if {![info exists parametres(affichage)]} {set parametres(affichage) 1}
        if {![info exists parametres(type_objet)]} {set parametres(type_objet) 0}
        if {![info exists parametres(gain_camera)]} {set parametres(gain_camera) 3}
        if {![info exists parametres(bruit_lecture)]} {set parametres(bruit_lecture) 20}
        if {![info exists parametres(type_capteur)]} {set parametres(type_capteur) "Kaf401E"}
        if {![info exists parametres(type_telescope)]} {set parametres(type_telescope) "Schmidt-Cassegrain"}
        if {![info exists parametres(diametre_telescope)]} {set parametres(diametre_telescope) "0.203"}
        if {![info exists parametres(focale_telescope)]} {set parametres(focale_telescope) "1.260"}
        if {![info exists parametres(catalogue_reference)]} {set parametres(catalogue_reference) "USNO B1,R"}
        if {![info exists parametres(filtre_optique)]} {set parametres(filtre_optique) "-"}
    }

    #*************************************************************************#
    #*************  Ressources  **********************************************#
    #*************************************************************************#
    proc Ressources {} {
        global blt_version
        global audace
        variable texte_photo

        if {[catch {jm_versionlib} version_lib]} {
            Message console "%s\n" $texte_photo(mauvaise_version)
            return 1
        } else {
            if {[expr double([string range $version_lib 0 2])] < 3.0} {
                Message console "%s\n" $texte_photo(mauvaise_version)
                return 1
            }
        }
        return 0
    }

    #*************************************************************************#
    #*************  Retour  **************************************************#
    #*************************************************************************#
    proc Retour {nom_image} {
#--- Debut modif Robert
        global audace
#--- Fin modif Robert
        destroy $audace(base).selection_aster
        AffichageMenuAsteroide 1 $nom_image
    }

    #*************************************************************************#
    #*************  SaisieParametres  ****************************************#
    #*************************************************************************#
    proc SaisieParametres {} {
        global audace
        variable parametres
        variable texte_photo
        variable police

        # Construction de la fenêtre des paramètres
        toplevel $audace(base).saisie -borderwidth 2 -relief groove
        set largeur_ecran_2 [expr [winfo screenwidth .] / 2]
        wm geometry $audace(base).saisie +320+0
        wm title $audace(base).saisie $texte_photo(titre_saisie)
        wm protocol $audace(base).saisie WM_DELETE_WINDOW ::CalaPhot::Suppression

        # Construction de la trame des listes qui contient les listes et l'ascenseur
        frame $audace(base).saisie.listes

        # Construction du canevas qui va contenir toutes les trames et des ascenseurs
        set c [canvas $audace(base).saisie.listes.canevas -yscrollcommand [list $audace(base).saisie.listes.yscroll set]]
        set y [scrollbar $audace(base).saisie.listes.yscroll -orient vertical -command [list $audace(base).saisie.listes.canevas yview] ]

        # Construction d'une trame qui va englober toutes les listes dans le canevas
        set t [frame $c.t]
        $c create window 0 0 -anchor nw -window $t

        #--------------------------------------------------------------------------------
        # Trame des renseignements généraux
        frame $t.trame1 -borderwidth 5 -relief groove
        label $t.trame1.titre -text $texte_photo(param_generaux) -font $police(titre)
        grid $t.trame1.titre -in $t.trame1 -columnspan 2 -sticky ew
        foreach champ {objet operateur code_UAI type_capteur type_telescope diametre_telescope focale_telescope catalogue_reference filtre_optique source indice_premier indice_dernier tailleboite signal_bruit gain_camera bruit_lecture sortie fichier_cl} {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame1.l$champ -text $texte_photo($champ) -font $police(gras)
            entry $t.trame1.e$champ -textvariable ::CalaPhot::parametres($champ) -font $police(normal) -relief sunken
            $t.trame1.e$champ delete 0 end
            $t.trame1.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame1.l$champ $t.trame1.e$champ
        }
        #--------------------------------------------------------------------------------
        # Trame du cliquodrome
        frame $t.trame2 -borderwidth 5 -relief groove
        label $t.trame2.laffichage -text $texte_photo(affichage) -font $police(gras)
        for {set i 0} {$i <= 2} {incr i} {
            radiobutton $t.trame2.b${i}affichage  -variable ::CalaPhot::parametres(affichage) -text $texte_photo(affichage_${i}) -value $i -font $police(gras)
        }
        grid $t.trame2.laffichage $t.trame2.b0affichage $t.trame2.b1affichage $t.trame2.b2affichage
        foreach champ {mode type_images date_images pose_minute format_sortie} {
            label $t.trame2.l$champ -text $texte_photo($champ) -font $police(gras)
            for {set i 0} {$i <= 1} {incr i} {
                radiobutton $t.trame2.b$i$champ -variable ::CalaPhot::parametres($champ) -text $texte_photo(${champ}_${i}) -value $i -command {::CalaPhot::AffichageVariable $::CalaPhot::parametres(mode) $audace(base).saisie.listes.canevas $audace(base).saisie.listes.yscroll $audace(base).saisie.listes.canevas.t} -font $police(gras)
            }
            grid $t.trame2.l$champ $t.trame2.b0$champ $t.trame2.b1$champ
        }
        #--------------------------------------------------------------------------------
        # Trame spécifique au mode ouverture
        frame $t.trame_ouv -borderwidth 5 -relief groove
        label $t.trame_ouv.titre -text $texte_photo(param_ouverture) -font $police(titre)
        grid $t.trame_ouv.titre -in $t.trame_ouv -columnspan 2

        foreach champ {surechantillonage rayon1 rayon2 rayon3} {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame_ouv.l$champ -text $texte_photo(o_$champ) -font $police(gras)
            entry $t.trame_ouv.e$champ -textvariable ::CalaPhot::parametres($champ) -width 3 -font $police(normal) -relief sunken
            $t.trame_ouv.e$champ delete 0 end
            $t.trame_ouv.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame_ouv.l$champ $t.trame_ouv.e$champ
        }
        #--------------------------------------------------------------------------------
        # Trame spécifique au mode modélisation
        frame $t.trame_mod -borderwidth 5 -relief groove
        # Le mode modelisation n'a plus de paramètres spécifiques
        # On garde le mécanisme de la trame dynamique, des fois qu'il faille
        # en remettre un jour ...
#        label $t.trame_mod.titre -text $texte_photo(param_modelisation) -font $police(titre)
#        grid $t.trame_mod.titre -in $t.trame_mod -columnspan 2

#        foreach champ {rayon1 rayon2 rayon3} {
#            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
#            label $t.trame_mod.l$champ -text $texte_photo(m_$champ) -font $police(gras)
#            entry $t.trame_mod.e$champ -textvariable ::CalaPhot::parametres($champ) -width 3 -font $police(normal) -relief sunken
#            $t.trame_mod.e$champ delete 0 end
#            $t.trame_mod.e$champ insert 0 $valeur_defaut($champ)
#            grid $t.trame_mod.l$champ $t.trame_mod.e$champ
#        }

        #--------------------------------------------------------------------------------
        # Trame des boutons. Ceux-ci sont fixes (pas d'ascenseur).
        frame $audace(base).saisie.trame3 -borderwidth 5 -relief groove
        button $audace(base).saisie.trame3.b1 -text $texte_photo(continuer) -command {::CalaPhot::ValideSaisie} -font $police(titre)
        button $audace(base).saisie.trame3.b2 -text $texte_photo(annuler) -command {::CalaPhot::AnnuleSaisie} -font $police(titre)
        pack $audace(base).saisie.trame3.b1 -side left -padx 10 -pady 10
        pack $audace(base).saisie.trame3.b2 -side right -padx 10 -pady 10

        AffichageVariable $parametres(mode) $c $y $t
        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $audace(base).saisie

        tkwait window $audace(base).saisie
    }

    #*************************************************************************#
    #*************  SauvegardeParametres  ************************************#
    #*************************************************************************#
    proc SauvegardeParametres {} {
        global audace
        variable parametres

        set nom_fichier [file join $audace(rep_scripts) calaphot calaphot.ini]
        if [catch {open $nom_fichier w} fichier] {
            #Message console "%s\n" $fichier
        } else {
            foreach {a b} [array get parametres] {
                puts $fichier "set parametres($a) \"$b\""
        }
        close $fichier
        }
    }

    #*************************************************************************#
    #*************  ScriptCourbeLumiere  *************************************#
    #*************************************************************************#
    proc ScriptCourbeLumiere {x y1 y2 y3} {
        set liste_commande [list { \
                      {package require BLT} \
                      {set baseplotxy ".calaphot"}
                      {catch {destroy $baseplotxy}} \
                      {toplevel $baseplotxy} \
                      {wm geometry $baseplotxy 631x453+100+0} \
                      {wm maxsize $baseplotxy [winfo screenwidth .] [winfo screenheight .]} \
                      {wm minsize $baseplotxy 200 200} \
                      {wm resizable $baseplotxy 1 1} \
                  }]

        foreach commande $liste_commande {
            Message console "%s\n" $commande
        }
    }

    #*************************************************************************#
    #*************  SelectionneAsteroide  ************************************#
    #*************************************************************************#
    proc SelectionneAsteroide {nom indice} {
        global audace color
        variable texte_photo
        variable coord_aster
        variable coord_etoile_x
        variable coord_etoile_y
        variable parametres

        # Calcul du centre de l'astéroïde
        set coord_aster($indice) [Centroide]
        if {[llength $coord_aster($indice)] != 0} {
            set cx [lindex $coord_aster($indice) 0]
            set cy [lindex $coord_aster($indice) 1]
            # Recherche si l'étoile a été désélectionnée
            if {[info exists coord_etoile_x]} {
                set ix [lsearch $coord_etoile_x $cx]
                set iy [lsearch $coord_etoile_y $cy]
            } else {
                set ix -1
            set iy -1
            }
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                tk_messageBox -message $texte_photo(etoile_prise) -icon error -title $texte_photo(probleme)
            } else {
                set taille $parametres(tailleboite)
                Dessin rectangle $coord_aster($indice) [list $taille $taille] $color(yellow) etoile_0
                Dessin verticale $coord_aster($indice) [list $taille $taille] $color(yellow) etoile_0
                Dessin horizontale $coord_aster($indice) [list $taille $taille] $color(yellow) etoile_0
            }
        } else {
            unset coord_aster($indice)
        }
    }

    #*************************************************************************#
    #*************  SelectionneEtoiles  **************************************#
    #*************************************************************************#
    proc SelectionneEtoiles {} {
        global audace color
        variable nombre_etoile
        variable parametres
        variable mag
        variable texte_photo
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile
        variable flux_premiere_etoile

        if {[winfo exists $audace(base).saisie.magnitude]} {
            return
        }

        # Pour simplifier les écritures
        set boite $parametres(tailleboite)

        set mag 0.0

        set pos [Centroide]
        if {[llength $pos] != 0} {
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]

            # Recherche si l'étoile a déjà été sélectionnée
            if {[info exists coord_etoile_x]} {
                set ix [lsearch $coord_etoile_x $cx]
                set iy [lsearch $coord_etoile_y $cy]
            } else {
                set ix -1
                set iy -1
            }
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                tk_messageBox -message $texte_photo(etoile_prise) -icon error -title $texte_photo(probleme)
            } else {
                # Cas d'une nouvelle étoile
                lappend coord_etoile_x $cx
                lappend coord_etoile_y $cy
                incr nombre_etoile

                # Calcul pour le pré affichage des valeurs de magnitudes
                set cxx [expr int(round($cx))]
                set cyy [expr int(round($cy))]
                set q [jm_fitgauss2db $audace(bufNo) [list [expr $cxx - $boite] [expr $cyy - $boite] [expr $cxx + $boite] [expr $cyy + $boite]]]
#            Message console "q= %s\n" $q
                if {![info exists flux_premiere_etoile]} {
                    set mag_affichage 13.5
                    if {[lindex $q 0] != 0} {
                        set flux_premiere_etoile [lindex $q 12]
#                Message console "AA\n"
                    }
                } else {
                    if {[lindex $q 0] != 0} {
                        set mag_affichage [format "%4.1f" [expr [lindex $mag_etoile 0] - 2.5 * log10([lindex $q 12] / $flux_premiere_etoile)]]
                    } else {
                        set mag_affichage 13.5
                    }
                }

                # Dessin d'un symbole
                set taille $parametres(tailleboite)
                Dessin ovale [list $cx $cy] [list $taille $taille] $color(green) etoile_${cx}_${cy}
                Dessin verticale [list $cx $cy] [list $taille $taille] $color(green) etoile_${cx}_${cy}
                Dessin horizontale [list $cx $cy] [list $taille $taille] $color(green) etoile_${cx}_${cy}

                # Construction de la fenêtre demandant la magnitude
                toplevel $audace(base).saisie_magnitude -borderwidth 2 -bg $audace(color,backColor) -relief groove
                wm geometry $audace(base).saisie_magnitude +650+300
                wm title $audace(base).saisie_magnitude $texte_photo(magnitude)
                wm transient $audace(base).saisie_magnitude .audace
                wm protocol $audace(base).saisie_magnitude WM_DELETE_WINDOW ::CalaPhot::Suppression

                frame $audace(base).saisie_magnitude.trame1
                label $audace(base).saisie_magnitude.trame1.lmagnitude -text $texte_photo(magnitude) -bg $audace(color,backColor)
                entry $audace(base).saisie_magnitude.trame1.emagnitude -width 5 -textvariable ::CalaPhot::mag -relief sunken
                $audace(base).saisie_magnitude.trame1.emagnitude delete 0 end
                $audace(base).saisie_magnitude.trame1.emagnitude insert 0 $mag_affichage
                grid $audace(base).saisie_magnitude.trame1.lmagnitude $audace(base).saisie_magnitude.trame1.emagnitude -sticky news

                frame $audace(base).saisie_magnitude.trame2 -borderwidth 2 -relief groove -bg $audace(color,backColor2)
                button $audace(base).saisie_magnitude.trame2.b1 -text $texte_photo(valider) -command {destroy $audace(base).saisie_magnitude}
                pack $audace(base).saisie_magnitude.trame2.b1 -in $audace(base).saisie_magnitude.trame2 -side left -padx 10 -pady 10

                pack $audace(base).saisie_magnitude.trame1 $audace(base).saisie_magnitude.trame2 -in $audace(base).saisie_magnitude -fill x
                focus $audace(base).saisie_magnitude.trame1.emagnitude
                grab $audace(base).saisie_magnitude
                tkwait window $audace(base).saisie_magnitude
                lappend mag_etoile $mag
            }
        }
    }

    #*************************************************************************#
    #*************  SelectionneIndesirables  *********************************#
    #*************************************************************************#
    proc SelectionneIndesirables {} {
        global audace color
        variable nombre_indes
        variable parametres
        variable texte_photo
        variable coord_indes_x
        variable coord_indes_y

        set pos [Centroide]
        if {[llength $pos] != 0} {
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]

            # Recherche si l'étoile a été désélectionnée
            if {[info exists coord_indes_x]} {
                set ix [lsearch $coord_indes_x $cx]
                set iy [lsearch $coord_indes_y $cy]
            } else {
                set ix -1
                set iy -1
            }
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                tk_messageBox -message $texte_photo(etoile_prise) -icon error -title $texte_photo(probleme)
            } else {
                # Cas d'une nouvelle étoile
                lappend coord_indes_x $cx
                lappend coord_indes_y $cy
                incr nombre_indes
                set i $nombre_indes

                # Dessin d'un symbole
                set taille $parametres(tailleboite)
                Dessin ovale [list $cx $cy] [list $taille $taille] $color(red) etoile_${cx}_${cy}
                Dessin verticale [list $cx $cy] [list $taille $taille] $color(red) etoile_${cx}_${cy}
                Dessin horizontale [list $cx $cy] [list $taille $taille] $color(red) etoile_${cx}_${cy}
            }
        }
    }

    #*************************************************************************#
    #*************  Statistiques  ********************************************#
    #*************************************************************************#
    proc Statistiques {type} {
        variable data_image
        variable data_script
        variable moyenne
        variable ecart_type
        variable parametres
        variable liste_image

        set premier [lindex $liste_image 0]
        set dernier [lindex $liste_image end]
        for {set etoile 0} {$etoile <= $data_script(nombre_etoile)} {incr etoile} {
            set somme_mag 0.0
            set somme2_mag 0.0
            set k 0

            if {$type == 0} {
            # Statistiques sur toutes les images (dont on a pu calculer la magnitude des astres)
                foreach i $liste_image {
                    if {$data_image($i,mag_$etoile) <= 90.0} {
                        incr k
                        set somme_mag [expr $somme_mag + $data_image($i,mag_$etoile)]
                        set somme2_mag [expr $somme2_mag + $data_image($i,mag_$etoile) * $data_image($i,mag_$etoile)]
                    }
                }
            } else {
                # Statistiques sur les images filtrées
                foreach i $liste_image {
                    if {$data_image($i,valide) == "Y"} {
                        incr k
                        set somme_mag [expr $somme_mag + $data_image($i,mag_$etoile)]
                        set somme2_mag [expr $somme2_mag + $data_image($i,mag_$etoile) * $data_image($i,mag_$etoile)]
                    }
                }
            }

            if {$k != 0} {
                set moyenne($etoile) [expr $somme_mag / $k]
                # Calcul de l'écart-type
                #  formule : sigma = sqrt(E(x^2) - [E(x)]^2)
                set s2 [expr ($somme2_mag / $k) - ($moyenne($etoile) * $moyenne($etoile))]
                if {$s2 < 0} {
                    # Ce cas ne devrait jamais se présenter. Mais il a déjà été vu. Pourquoi ? Mystère...
                    set moyenne($etoile) 99.99
                    set ecart_type($etoile) 99.99
                } else {
                    set ecart_type($etoile) [expr sqrt($s2)]
                }
            } else {
                set moyenne($etoile) 99.99
                set ecart_type($etoile) 99.99
            }
        }
    }

    #*************************************************************************#
    #*************  Suppression  *********************************************#
    #*************************************************************************#
    proc Suppression {} {
        #Procédure pour bloquer la suppression des fenêtres esclaves
    }

    #*************************************************************************#
    #*************  SuppressionEtoile  ***************************************#
    #*************************************************************************#
    proc SuppressionEtoile {image j} {
        global audace
        variable parametres
        variable pos_reel_indes

        set largeur $parametres(tailleboite)

        set x1 [expr round([lindex $pos_reel_indes($image,$j) 0] - $largeur)]
        set y1 [expr round([lindex $pos_reel_indes($image,$j) 1] - $largeur)]
        set x2 [expr round([lindex $pos_reel_indes($image,$j) 0] + $largeur)]
        set y2 [expr round([lindex $pos_reel_indes($image,$j) 1] + $largeur)]

        set t [jm_fitgauss2db $audace(bufNo) [list $x1 $y1 $x2 $y2] -sub]
        if {[lindex t 0] == 0} {
            buf$audace(bufNo) fitgauss [list $x1 $y1 $x2 $y2] -sub
        }
    }

    #*************************************************************************#
    #*************  SuppressionIndesirables  *********************************#
    #*************************************************************************#
    proc SuppressionIndesirables {image} {
        global color
        variable data_script
        variable parametres
        variable pos_reel_indes

        set nombre $data_script(nombre_indes)
        set largeur $parametres(tailleboite)

        for {set j 1} {$j <= $nombre} {incr j} {
            Dessin rectangle $pos_reel_indes($image,$j) [list $largeur $largeur] $color(red) etoile_$j
            SuppressionEtoile $image $j
            Visualisation optimale
        }
    }
    #*************************************************************************#
    #*************  TriDateImage  ********************************************#
    #*************************************************************************#
    # Sert à trier les images par dates croissantes, et éliminant les doublons#
    # Retourne une liste de numéro d'images triées                            #
    #**************************************************************************
    proc TriDateImage {} {
        variable parametres
        variable data_image
        variable texte_photo

        Message consolog "%s\n" $texte_photo(tri_images)
        set liste_date [list]
        set liste_image_triee [list]
        catch {unset tableau_date}

        for {set i $parametres(indice_premier)} {$i <= $parametres(indice_dernier)} {incr i 1} {
            loadima $parametres(source)$i
            after 50
            update
            DateImage $i
            # Pour éviter les doublons
            if {![info exists tableau_date($data_image($i,date))]} {
                set tableau_date($data_image($i,date)) $i
                lappend liste_date $data_image($i,date)
            }
        }

        set liste_date_triee [lsort -real -increasing $liste_date]
        foreach date $liste_date_triee {
            lappend liste_image_triee $tableau_date($date)
        }
        return $liste_image_triee
    }

    #*************************************************************************#
    #*************  ValideSaisie  ********************************************#
    #*************************************************************************#
    proc ValideSaisie {} {
        global audace
        variable texte_photo
        variable parametres

        # Recherche si tous les champs critiques sont remplis.
        set pas_glop 0
        foreach champ {source  indice_premier indice_dernier tailleboite signal_bruit gain_camera bruit_lecture sortie fichier_cl} {
            if {$parametres($champ) == ""} {
                set message_erreur $texte_photo(champ1)
                append message_erreur $texte_photo($champ)
                append message_erreur $texte_photo(champ2)
                tk_messageBox -message $message_erreur -icon error -title $texte_photo(probleme)
                set pas_glop 1
                break;
            }
        }

        if {$pas_glop == 0} {
        destroy $audace(base).saisie
        update
        }
    }

    #*************************************************************************#
    #*************  Verification  ********************************************#
    #*************************************************************************#
    proc Verification {} {
        global audace conf
        variable parametres
        variable texte_photo

        # Vérification des indices
        if {$parametres(indice_premier) >= $parametres(indice_dernier)} {
            Message console "%s\n" $texte_photo(err_indice)
            EffaceMotif astres
            return (1)
        }

        # Vérification de ce que les images existent
        Message console $texte_photo(verification) $parametres(source) $parametres(indice_premier) $parametres(indice_dernier) ""
        Message console "\n"
        for {set image $parametres(indice_premier)} {$image <= $parametres(indice_dernier)} {incr image} {
            set nom_fichier [file join $audace(rep_images) $parametres(source)$image$conf(extension,defaut)]
            if {![file exists $nom_fichier]} {
                # Recherche si le fichier existe en compressé
                set nom_fichier_gz $nom_fichier
                append nom_fichier_gz ".gz"
                if {![file exists $nom_fichier_gz]} {
                    Message console "%s %s %s\n" $texte_photo(err_existence_1) [file rootname [file tail $nom_fichier] ] $texte_photo(err_existence_2)
                    EffaceMotif astres
                    return (1)
                }
            }
        }
        return 0
    }

    #*************************************************************************#
    #*************  Visualisation  *******************************************#
    #*************************************************************************#
    proc Visualisation {mode} {
        global audace
        variable data_script

        if {$mode == "optimale"} {
            set fond_ciel [lindex [buf$audace(bufNo) stat] 6]
            set data_script(seuil_haut) [expr $fond_ciel + 300]
            set data_script(seuil_bas) [expr $fond_ciel - 50]
        }
        visu$audace(visuNo) disp [list $data_script(seuil_haut) $data_script(seuil_bas)]
        update
    }

    #*************************************************************************#
    #*************  VitesseAsteroide  ****************************************#
    #*************************************************************************#
    proc VitesseAsteroide {delta_jd} {
        variable parametres
        variable coord_aster
        variable liste_image

        set premier [lindex $liste_image 0]
        set dernier [lindex $liste_image end]
        # Calcul la vitesse de l'astéroïde en pixel/jour
        if {$delta_jd == 0} {
            set dx [expr (([lindex $coord_aster(2) 0] - [lindex $coord_aster(1) 0]) / ($dernier - $premier))]
            set dy [expr (([lindex $coord_aster(2) 1] - [lindex $coord_aster(1) 1]) / ($dernier - $premier))]
        } else {
            set dx [expr ([lindex $coord_aster(2) 0] - [lindex $coord_aster(1) 0]) / $delta_jd]
            set dy [expr ([lindex $coord_aster(2) 1] - [lindex $coord_aster(1) 1]) / $delta_jd]
        }
        return [list $dx $dy]
    }

}
# Fin du namespace Calaphot

if {[catch {load libjm[info sharedlibextension]} erreur]} {
    ::CalaPhot::Message console "%s\n" $erreur
    return 1
}

if {[catch {jm_versionlib} version_lib]} {
    Message console "%s\n" ::CalaPhot::Message console "%s\n" $version_lib
    return 1
} else {
    if {[expr double([string range $version_lib 0 2])] < 3.0} {
        Message console "LibJM version must be greater than 3.0\n"
        return 1
    }
}

catch {package require BLT} erreur
if {$erreur != "2.4"} {
    catch {load blt24[info sharedlibextension]} erreur
    if {$erreur !=    ""} {
        ::CalaPhot::Message console "%s\n" $erreur
        return 1
    } else {
        if {[catch {package require BLT} erreur]} {
            ::CalaPhot::Message console "%s\n" $erreur
            return 1
        }
    }
} else {
    namespace import -force blt::*
}

::CalaPhot::Principal

