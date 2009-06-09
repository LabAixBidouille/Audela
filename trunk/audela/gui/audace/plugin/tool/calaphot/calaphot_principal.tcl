##
# @file calaphot_principal.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Script pour la photometrie d'asteroides ou d'etoiles variables.
#
# $Id: calaphot_principal.tcl,v 1.4 2009-06-09 07:56:36 jacquesmichelet Exp $
#

###catch {namespace delete ::Calaphot}


##
# @defgroup calaphot_notice_fr Calaphot
#
# @defgroup calaphot_presentation Presentation
# Calaphot est un script permettant de faire de la photometrie differentielle sur un lot d'images
# @ingroup calaphot_notice_fr
#
# @section calaphot_presentation Presentation
# Plusieurs méthodes de calcul de photometrie sont proposees
# - photometrie par ouverture : le flux de chaque astre est calcule dans une fenetre elliptique, auxquel est soustrait la flux de fond de ciel mesure dans un anneau elliptique entourant la fenetre precedente
# - photometrie par modelisation : les niveaux de gris de chaque astre sont modelises par une nappe gaussienne. On obtient ainsi directement le flux de chaque astre.
# - photometrie par @c sextractor : @c sextractor est un logiciel libre (developpe par Emmanuel Bertin) dont la finalite premiere est d'effectuer des mesures astrometriques sur les images. Il comporte aussi des fonctions de photometrie qui sont exploitees dans Calaphot.
# .
# Pour utiliser Calaphot, sont fournis :
# - @link calaphot_documentation_fr le mode d'emploi @endlink .
# - @link calaphot_documentation_technique_fr La documentation technique @endlink détaillant les calculs effectués.
# .
#
# @todo Choses a faire
# - Fonctionnel
#   - multiples asteroides en // : voir le tag MultAster pour retablir la fonctionnalite
#   - differencier les aster. par couleur dans le graph. de la cl.
#   - pouvoir les nommer individuellement dans le graph. de la cl.
#   - integration en tant que panneau (outil audace)
#   - nommer les etoiles de ref : voir le tag NomRef
#   - tenir compte de la masse d'air si les images sont recalées astrometriquement
#   .
# - Non fonctionnel
#   - faire une vraie routine jm_fitgauss2d
#   - virer les choix bases sur _0 ou _1 (lisibilité du code)
#   .
# .
#
# @bug Bogues connues a ce jour :
# - pas de suppression des fichiers de config sextractor en cas d'arret anticipe
# - plantage lors de l'affichage de la CL si aucune image n'est validee (premier n'existe pas)
# - mode sextractor ne marche pas si les repertoires ont des blancs dans leurs noms (exe, images ou configs)
# - pb d'affichage des valeurs numériques si on refait le pointage de l'astéroïde sur la 1ere image
# .
#
#

##
# @brief Calaphot est un script permettant de faire de la photometrie differentielle sur un lot d'images
# @namespace CalaPhot
namespace eval ::CalaPhot {
    ##
    # @brief Initialisation generale des variables par défaut
    # @return
    proc InitialisationStatique {} {
        global audace
        variable parametres
        variable calaphot
        variable police
        variable demande_arret
        variable trace_log
        variable data_script
        variable data_image
        variable parametres

# L'existence de trace_log cree le ficher debug.log et le mode d'affichage debug
        catch {unset trace_log}
##        set trace_log 1

        set numero_version v5.0

        set calaphot(niveau_debug) 0
        set calaphot(niveau_info) 1
        set calaphot(niveau_notice) 2
        set calaphot(niveau_probleme) 3
        set calaphot(niveau_erreur) 4

        set calaphot(texte,debug)               "debug"
        set calaphot(texte,info)                "info"
        set calaphot(texte,notice)              "notice"
        set calaphot(texte,probleme)            "probleme"
        set calaphot(texte,erreur)              "erreur"

        set calaphot(nom_fichier_ini)           [file join audace plugin tool calaphot calaphot.ini]
        set calaphot(nom_fichier_log)           [file join audace plugin tool calaphot trace_calaphot.log]

        set calaphot(sextractor,catalog)        [ file join audace plugin tool calaphot calaphot.cat ]
        set calaphot(sextractor,config)         [ file join audace plugin tool calaphot calaphot.sex ]
        set calaphot(sextractor,param)          [ file join audace plugin tool calaphot calaphot.param ]
        set calaphot(sextractor,neurone)        [ file join audace plugin tool calaphot calaphot.nnw ]
        set calaphot(sextractor,assoc)          [ file join audace plugin tool calaphot calaphot.assoc ]

        set calaphot(init,mode)                 ouverture
        set calaphot(init,operateur)            "Tycho Brahe"
        set calaphot(init,source)               kandrup
        set calaphot(init,indice_premier)       1
        set calaphot(init,indice_dernier)       100
        set calaphot(init,gain_camera)          3
        set calaphot(init,bruit_lecture)        20
        set calaphot(init,saturation)           32500
        set calaphot(init,tailleboite)          7
        set calaphot(init,rayon1)               1
        set calaphot(init,rayon2)               3
        set calaphot(init,rayon3)               6
        set calaphot(init,sortie)               "kandrup.txt"
        set calaphot(init,fichier_cl)           "kandrup.ps"
        set calaphot(init,objet)                Kandrup
        set calaphot(init,code_UAI)             615
        set calaphot(init,surechantillonage)    5
        set calaphot(init,type_capteur)         "Kaf401E"
        set calaphot(init,type_telescope)       "Schmidt-Cassegrain"
        set calaphot(init,diametre_telescope)   "0.203"
        set calaphot(init,focale_telescope)     "1.260"
        set calaphot(init,catalogue_reference)  "USNO B1,R"
        set calaphot(init,filtre_optique)       "-"
        set calaphot(init,niveau_message)       $calaphot(niveau_notice)
        set calaphot(init,tri_images)           "non"
        set calaphot(init,type_images)          "non_recalees"
        set calaphot(init,pose_minute)          "seconde"
        set calaphot(init,date_images)          "debut_pose"
        set calaphot(init,reprise_astres)       "non"
        set calaphot(init,format_sortie)        "cdr"
        set calaphot(init,signal_bruit)         20
        set calaphot(init,type_objet)           0
        set calaphot(init,version_ini)          $numero_version

        # couleur des affichages console
        foreach niveau { debug info notice probleme erreur } couleur_style { green orange blue purple red } {
            $audace(Console).txt1 tag configure calaphot(style_$niveau) -foreground $couleur_style
        }
    }

    ##
    # @brief Programme principal (séquenceur)
    # @return 0 si tout va bien
    # @return !=0 en cas de demande d'arret, ou d'erreur dans le script
    proc Principal {} {
        global audace color conf
        variable demande_arret
        variable parametres
        variable coord_aster
        variable vitesse_variable
        variable pos_reel
        variable mag
        variable data_image
        variable data_script
        variable moyenne
        variable ecart_type
        variable liste_image
        variable calaphot

        # Initialisation generale
        InitialisationStatique

        # Chargement des librairies ressources
        set librairie [Ressources]
        if {$librairie != 0} {return}

        # Initialisations diverses
        Initialisations

        # Lecture du fichier de parametres
        RecuperationParametres

        Console notice "%s %s\n" $calaphot(texte,titre) $calaphot(init,version_ini)
        Console notice "%s\n" $calaphot(texte,copyright)

        set demande_arret 0
        SaisieParametres
        SauvegardeParametres

        catch {file delete [file join $audace(rep_images) $parametres(sortie)]}

        TraceFichier notice "%s %s\n" $calaphot(texte,titre) $calaphot(init,version_ini)
        TraceFichier notice "%s\n" $calaphot(texte,copyright)

        if {$demande_arret == 1} {
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Affiche l'heure du debut de traitement
        Message notice "%s %s\n\n" $calaphot(texte,heure_debut) [clock format [clock seconds]]

        # Verification de l'existence des images
        set erreur [Verification]
        if {$erreur != 0} {
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Initialisations specifiques a Sextractor
        if {( $parametres(mode) == "sextractor" )} {
            CreationFichiersSextractor
        }

        # Recuperation d'informations sur les images
        InformationsImages

        # Recapitulation des options choisies
        RecapitulationOptions

        # Tri des images par date croissante
        TriDateImage

        # Recuperation des decalages entre image (s'ils existent)
        RecuperationDecalages

        # Creation des images t1 et t2, copies de la premiere et de la derniere image
        loadima $parametres(source)$data_script(premier_liste)
        saveima t1
        loadima $parametres(source)$data_script(dernier_liste)
        saveima t2

        if {$parametres(type_images) == "non_recalees"} {
            # Images non recalees
            # Recalage de la premiere et de la derniere image en u1 et u2
            register2 t u 2
            AffichageMenus u
            # Permet la selection des etoiles et des asteroides sur les images recalees
        } else {
            # Permet la selection des etoiles et des asteroides
            AffichageMenus t
        }

        # 2eme sauvegarde, avec les coordonnees graphiques des astres
        SauvegardeParametres

        if {$demande_arret == 1} {
            $audace(hCanvas) delete marqueurs
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Recherche de l'etoile la plus brillante
        set eclat_max [RecherchePlusBrillante]

        # Calcul des dates extremes
        set temp [DatesReferences]
        set jd_premier [lindex $temp 0]
        set jd_dernier [lindex $temp 1]
        set delta_jd [lindex $temp 2]

        # Calcul de la vitesse apparente des asteroides
        VitesseAsteroide
        Message info "\n"
        for {set v 0} {$v < $data_script(nombre_variable)} {incr v} {
            Message info "%s %8.2f/%8.2f\n" $calaphot(texte,vitesse_asteroide) $vitesse_variable($v,x) $vitesse_variable($v,y)
        }

        # Calcul de magnitude de la super-etoile
        CalculMagSuperEtoile
        Message notice "%s %5.3f\n" $calaphot(texte,mag_superetoile) $data_script(mag_ref_totale)
        Message notice "%s %d\n" $calaphot(texte,calcul_ellipses) $eclat_max

        # Quelques initialisations
        set nombre_image [llength $liste_image]
        set data_script(nombre_image) $nombre_image

        # Affiche les titres des colonnes
        Entete

        # Mise en place du bouton d'arret
        BoutonArret

        # Affichage de la courbe de lumiere dynamique
        ::CalaPhot::CourbeLumiereTemporaire

        # Boucle principale sur les images de la serie
        #----------------------------------------------
        foreach i $liste_image {
            # A priori, l'image est bonne. On verra par la suite
            set data_image($i,valide) "Y"

            # Detection de l'appui sur le bouton d'arret
            if {$demande_arret == 1} {
                ArretScript
                EffaceMotif astres
                Message probleme "%s\n" $calaphot(texte,fin_anticipee)
                return
            }

            # Chargement et visualisation de l'image traitee
            loadima $parametres(source)$i
            Visualisation rapide

            # Recherche la date de l'image dans l'entete FITS (deja fait si les images etaient declarees non triees)
            if { [DateImage $i] } {
                Message probleme "%s %i : %s\n" $calaphot(texte,image) $i $calaphot(texte,temps_pose_nul)
                ArretScript
                EffaceMotif astres
                Message probleme "%s\n" $calaphot(texte,fin_anticipee)
                return
            }

            # Determination du decalage geometrique
            MesureDecalage $i

            # Calcule la position des asteroides par interpolation sur les dates (sans tenir compte du decalage des images)
            CalculPositionsTheoriques $i

            # Calcul de toutes les positions reelles des astres (asteroides compris) a considerer ET a supprimer, en tenant compte du decalage en coordonnees des images
            set test [CalculPositionsReelles $i]
            if {$test != 0} {
                set data_image($i,valide) "N"
                continue
            }

            # Recalage astrometrique
##            RecalageAstrometrique $i

            # Calcul des coordonnees equatoriales
##            XyAddec $i

            # Calcul de la masse d'air
##            MasseAir $i

            # Suppression de toutes les etoiles indesirables
            SuppressionIndesirables $i

            # Les astres (etoiles + asteroides) sont modelisees dans TOUS les cas
            #  Un certain nombre de valeurs individuelles sont mises a jour dans data_image
            set test 0
            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                # Dessin d un rectangle
                Dessin rectangle $pos_reel($i,ref,$j) [list $parametres(tailleboite) $parametres(tailleboite)] $color(green) etoile_$j
                # Modelisation
                incr test [Modelisation2D $i $j ref $pos_reel($i,ref,$j)]
            }
            for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
                # Dessin d un rectangle
                Dessin rectangle $pos_reel($i,var,$j) [list $parametres(tailleboite) $parametres(tailleboite)] $color(yellow) etoile_$j
                # Modelisation
##                incr test [Modelisation2D $i $j var $pos_reel($i,var,$j)]
                Modelisation2D $i $j var $pos_reel($i,var,$j)
            }
            if {$test != 0} {
                # Au moins un asteroide ou une etoile de ref. n'a pas ete modelisee correctement
                # Donc on elimine l'image
                set data_image($i,valide) "N"
                continue
            }


            if {$parametres(mode) == "ouverture"} {
                # Cas ouverture
                # Calcul des axes principaux des ellipses a partir des fwhm des etoiles de reference
                # NB : il faut pour cela connaitre les modeles de TOUTES les etoiles
                set ellipses [CalculEllipses $i]
                if {[lindex $ellipses 0] == 1} {
                    set r1x [lindex $ellipses 1]
                    set r1y [lindex $ellipses 2]
                    set r2 [lindex $ellipses 3]
                    set r3 [lindex $ellipses 4]

                    for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                       FluxOuverture $i ref $j
                    }
                    for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
                       FluxOuverture $i var $j
                    }
                } else {
                    set data_image($i,valide) "N"
                }
            }

            if {($parametres(mode) == "sextractor")} {
                # Cas Sextractor
                set test [Sextractor [file join $audace(rep_images) $parametres(source)$i$conf(extension,defaut) ] ]
                if {$test != 0} {
                    set data_script($i,invalidation) [list sextractor]
                    set data_image($i,valide) "N"
                    continue
                }
                for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                    set temp [RechercheCatalogue $i ref $j]
                    if {[llength $temp] != 0} {
                        FluxSextractor $i ref $j $temp
                    } else {
                        set data_script($i,invalidation) [list sextractor ref $j]
                        set data_image($i,valide) "N"
                        break
                    }
                }
                for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
                    set temp [RechercheCatalogue $i var $j]
                    Message debug "temp=%s (l=%d)\n" $temp [llength $temp]
                    if {[llength $temp] != 0} {
                        FluxSextractor $i var $j $temp
                    } else {
                        set data_script($i,invalidation) [list sextractor var $j]
                        set data_image($i,valide) "N"
                        break
                    }
                }
            }

            if {$data_image($i,valide) == "N"} {continue}

            # Dessin des symboles
            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                # Dessin des axes principaux
                if {$data_image($i,ref,centroide_x_$j) >= 0} {
                    # La modelisation a reussi
                    Dessin2 $i ref $j $parametres(rayon1) $color(green) etoile_$j
                } else {
                    # Pas de modelisation possible
                    Dessin verticale [list $data_image($i,ref,centroide_x_$j) $data_image($i,ref,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                    Dessin horizontale [list $data_image($i,ref,centroide_x_$j) $data_image($i,ref,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                }
            }
            for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
                # Dessin des axes principaux
                if {$data_image($i,var,centroide_x_$j) >= 0} {
                    # La modelisation a reussi
                    Dessin2 $i var $j $parametres(rayon1) $color(yellow) etoile_$j
                } else {
                    # Pas de modelisation possible
                    Dessin verticale [list $data_image($i,var,centroide_x_$j) $data_image($i,var,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                    Dessin horizontale [list $data_image($i,var,centroide_x_$j) $data_image($i,var,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                }
            }

            FluxReference $i

            # Calcul des magnitudes et des incertitudes de tous les astres (asteroides et etoiles)
            MagnitudesEtoiles $i

            # Premier filtrage sur les rapports signal a bruit
            FiltrageSB $i

            # Calcul d'incertitude global
            CalculErreurGlobal $i

            # Affiche le resultat dans la console
            AffichageResultatsBruts $i

            # Effacement des marqueurs d'etoile
            EffaceMotif astres

            # Calculs des vecteurs pour le pre-affichage de la courbe de lumiere
            PreAffiche $i
         }
         # Fin de la boucle sur les images

         # Suppression du bouton d'arret
         destroy $audace(base).bouton_arret_color_invariant

         # Sauvegarde des decalages entre images
         SauvegardeDecalages

         # Deuxieme filtrage sur les images pour filtrer celles douteuses
         FiltrageConstanteMag

         # Calcul du coeff. d'extinction de la masse d'air
#         ExtinctionMasseAir

         # Statistiques sur les etoiles a partir des images validees
         Statistiques 1

        for {set etoile 0} {$etoile < $data_script(nombre_variable)} {incr etoile 1} {
            Message notice "%s : %s %07.4f %s %6.4f\n" $calaphot(texte,asteroide)  $calaphot(texte,moyenne) $moyenne(var,$etoile) $calaphot(texte,ecart_type) $ecart_type(var,$etoile)
         }
        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile 1} {
            Message notice "%s : %s %07.4f %s %6.4f\n" $calaphot(texte,etoile)  $calaphot(texte,moyenne) $moyenne(ref,$etoile) $calaphot(texte,ecart_type) $ecart_type(ref,$etoile)
         }

         # Sortie standardisee des valeurs
         if {$parametres(format_sortie) == "canopus"} {
            AffichageCanopus
         } else {
            AffichageCDR
         }

        # Destruction des fichiers de configs Sextractor
        DestructionFichiersSextractor

         # Affiche l'heure de fin de traitement
         Message notice "\n\n%s %s\n" $calaphot(texte,heure_fin) [clock format [clock seconds]]
         Message notice "%s\n" $calaphot(texte,fin_normale)

         # Affichage de la courbe de lumiere
         CourbeLumiere

    }

    ##
    # @brief Affichage au format Canopus
    # @return
    proc AffichageCanopus {} {
        variable calaphot
        variable parametres
        variable data_image
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        Message notice "---------------------------------------------------------------------------------------\n"
        Message notice "Format Canopus\n"
        Message notice "---------------------------------------------------------------------------------------\n"
        Message notice "Observation Data:\n"
        Message notice "-----------------\n"
        Message notice "    Date          UT           OM           C1         C2        C3         C4        C5         U          CA        O-C\n"

        foreach i $liste_image {
            set temps [mc_date2ymdhms $data_image($i,date)]
            Message notice "%02d/%02d/%04d    " [lindex $temps 2] [lindex $temps 1] [lindex $temps 0]
            Message notice "%02d:%02d:%02d    " [lindex $temps 3] [lindex $temps 4] [expr round([lindex $temps 5])]
            for {set etoile 0} {$etoile <= 5} {incr etoile} {
                if {[info exists data_image($i,mag_$etoile)]} {
                    Message notice "%7.2f     " $data_image($i,mag_$etoile)
                } else {
                    Message notice "99.99     "
                }
            }
            Message notice "%s       " $data_image($i,valide)
            Message notice "%7.2f    " $data_image($i,constante_mag)
            Message notice "%7.2f\n" [expr $data_image($i,constante_mag) - $data_image($i,mag_0)]
        }
        # Fin de la boucle sur les images
    }

    ##
    # @brief Affichage avec le format CDR (cf site de Raoul Behrend)
    # @details Le resultat de cet affichage peut directement etre exporté pour le logiciel Courbrot
    # @return toujours 0
    proc AffichageCDR {} {
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        set premier [lindex $liste_image 0]
        set dernier [lindex $liste_image end]

        Message notice "\n\n\n"
        Message notice "---------------------------------------------------------------------------------------\n"
        Message notice "Format CDR\n"
        Message notice "---------------------------------------------------------------------------------------\n"
        Message notice "NOM %s\n" $parametres(objet)
        if {[string length $parametres(code_UAI)] != 0} {
            Message notice "MES %s @%s\n" $parametres(operateur) $parametres(code_UAI)
        } else {
            Message notice "MES %s\n" $parametres(operateur)
        }
        Message notice "POS 0 %5.2f\n" $data_image($premier,temps_expo)
        Message notice "CAP %s\n" $parametres(type_capteur)
        Message notice "TEL %s %s %s\n" $parametres(diametre_telescope) $parametres(focale_telescope) $parametres(type_telescope)
        Message notice "CAT %s\n" $parametres(catalogue_reference)
        Message notice "FIL %s\n" $parametres(filtre_optique)
        Message notice "; %s %s %s\n" $calaphot(texte,banniere_CDR_1) $calaphot(init,version_ini) $calaphot(texte,banniere_CDR_2)
        set image 0

        foreach i $liste_image {
            if {$data_image($i,valide) == "Y"} {
                incr image
                Message notice " 1 1"
                # Passage de la date en format amj,ddd
                set amjhms [mc_date2ymdhms $data_image($i,date)]
                set date_claire "[format %04d [lindex $amjhms 0]]"
                append date_claire "[format %02d [lindex $amjhms 1]]"
                append date_claire "[format %02d [lindex $amjhms 2]]"
                set hms [format %6.5f [expr double([lindex $amjhms 3])/24.0 + double([lindex $amjhms 4])/1440.0 + double([lindex $amjhms 5])/86400.0]]
                set hms [string range $hms [string first . $hms] end]
                append date_claire $hms
                Message notice " %14.5f" $date_claire
                Message notice " T"
                Message notice " %6.3f" $data_image($i,var,mag_0)
                Message notice " %6.3f" $data_image($i,var,incertitude_0)
                Message notice "\n"
            }
        }
        Message notice "---------------------------------------------------------------------------------------\n"
    }

    ##
    # @brief Affichage dans la console
    # @details Le niveau d'affichage est comparé au niveau defini dans la saisie des parametres. S'il est plus faible (plus grande priorite)
    # le message sera affiche. Les couleurs d'affichage sont definies par des 'tags' (cf InitialisationStatique)
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatte a afficher
    # @return
    proc Console {niveau_info args} {
        global audace
        variable trace_log
        variable calaphot
        variable parametres

        if {$parametres(niveau_message) <= $calaphot(niveau_$niveau_info)} {
            $audace(Console).txt1 insert end [string repeat " " [expr [info level] - 1]] calaphot(style_$niveau_info)
            $audace(Console).txt1 insert end [eval [concat {format} $args]] calaphot(style_$niveau_info)
            $audace(Console).txt1 see insert
            update

            if {[info exists trace_log]} {
                set filetest [open [file join $audace(rep_scripts) trace_calaphot.log] a]
                if {$filetest != ""} {
                    puts -nonewline $filetest [concat [string repeat "." [expr [info level] - 1]] [eval [concat {format} $args]] ]
                }
                close $filetest
            }
        }
    }

    ##
    # @brief Extraction de la date et du temps d'exposition d'une image a partir de l'entete FITS
    # @param[in] i : numero de l'image dans la sequence
    # @retval data_image($i,date) : date en jour julien
    # @retval data_image($i,temps_expo) : temps d'exposition en s
    # @return : -1 si le temps d'exposition trouvé est nul, 0, dans le cas normal
    proc DateImage {i} {
        global audace
        variable data_image
        variable data_script
        variable parametres
        variable liste_image
        variable trace_log
        variable parametres

        Message debug "%s\n" [info level [info level]]

        # Determination du temps de pose de l'image
        # !!! On suppose que la date stockee dans l'image est celle du DEBUT de la pose
        set expo [lindex [buf$audace(bufNo) getkwd "EXPTIME"] 1]
        if {[string length $expo] == 0} {
            set expo [lindex [buf$audace(bufNo) getkwd "EXPOSURE"] 1]
        }
        if {[string length $expo] == 0} {
            set expo [lindex [buf$audace(bufNo) getkwd "EXP_TIME"] 1]
        }

        Message debug "temps exposition : %d\n" $expo
        if { ([string length $expo] == 0) || ($expo == 0) } {
            return -1
        }

        if {$parametres(pose_minute) == "minute"} {
            set expo [expr $expo * 60.0]
        }
        set data_image($i,temps_expo) $expo

        # Calcul de la date exacte
        set jd [JourJulienImage]
        if {$parametres(date_images) == "debut_pose"} {
            # Cas debut de pose (on rajoute le 1/2 temps de pose converti en jour julien).
            set data_image($i,date) [expr $jd + ($expo / 172800.0)]
        } else {
            # Cas milieu de pose
            set data_image($i,date) $jd
        }
        Message debug "Image %d: date %s\n" $i $data_image($i,date)

        # Cas où des images sont mal classees
        if {$i == [lindex $liste_image 0]} {
            set data_script(date_max) $data_image($i,date)
        } else {
            if {($data_image($i,date) <= $data_script(date_max))} {
                Message debug "Date en recul !\n"
                set data_script($i,invalidation) [list date $data_image($i,date) "<" $data_script(date_max) ]
                set data_image($i,valide) "N"
            } else {
                set data_script(date_max) $data_image($i,date)
            }
        }
        return 0
    }


    ##
    # @brief Recherche des dates de la 1ere et de la derniere image de la sequence et calcul de la difference
    # @retval data_script(jd_premier) : date en jour julien de la 1ere image
    # @retval data_script(jd_dernier) : date en jour julien de la derniere image
    # @retval data_script(jd_delta) : difference des dates precedentes
    # @return liste des 3 parametres de sortie
    proc DatesReferences {} {
        global audace
        variable parametres
        variable liste_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

        # Charge et affiche la premiere image
        set premier [lindex $liste_image 0]
        set nom_fichier $parametres(source)$premier
        loadima $nom_fichier
        set jdFirst [JourJulienImage]
        set data_script(jd_premier) $jdFirst

        # Charge et affiche la derniere image
        set dernier [lindex $liste_image end]
        set nom_fichier $parametres(source)$dernier
        loadima $nom_fichier
        set jdLast [JourJulienImage]
        set data_script(jd_dernier) $jdLast

        set delta_jd [expr $jdLast-$jdFirst]
        set data_script(delta_jd) $delta_jd

        return [list $jdFirst $jdLast $delta_jd]
    }

    ##
    # @brief Lecture du decalage en (x,y) de l'image recalee prealablement
    # @details Le decalage est lu a partir du mot cle IMA/SERIES REGISTER dans l'entete FITS de l'image
    # @param[in] image : no de l'image dans la sequence
    # @return liste contenant le decalage en x et y
    proc DecalageImage {image} {
        global audace

        Message debug "%s\n" [info level [info level]]

        # --- recupere la liste des mots cle  de l'image FITS
        set listkey [lsort -dictionary [buf$audace(bufNo) getkwds]]
        # --- on evalue chaque mot cle
        foreach key $listkey {
            # --- on extrait les infos de la ligne FITS
            # --- qui correspond au mot cle...
            set listligne [buf$audace(bufNo) getkwd $key]
            # --- on evalue la valeur de la ligne FITS
            set value [lindex $listligne 1]
            # --- si la valeur vaut IMA/SERIES REGISTER ...
            if {$value == "IMA/SERIES REGISTER"} {
                # --- alors on extrait l'indice du mot cl� TT
                set keyname [lindex $listligne 0]
                set lenkeyname [string length $keyname]
                set indice [string range $keyname 2 [expr $lenkeyname] ]
            }
        }
        if {![info exists indice]} {
            set dec [list 0 0]
        } else {
            # On a maintenant repere la fonction TT qui pointe sur la derniere registration.
            # --- on recherche la ligne FITS contenant le mot cle indice+1
            incr indice
            set listligne [buf$audace(bufNo) getkwd "TT$indice"]

            # --- on evalue la valeur de la ligne FITS
            set param1 [lindex $listligne 1]
            set dx [lindex [split $param1] 3]

            # --- on recherche la ligne FITS contenant le mot cle indice+2
            incr indice
            set listligne [buf$audace(bufNo) getkwd "TT$indice"]

            # --- on �value la valeur de la ligne FITS
            set param2 [lindex $listligne 1]
            set dy [lindex $param2 2]

            # Fin de la lecture du d�calage
            set dec [list $dx $dy]
        }
        return $dec
    }

    ##
    # @brief Conversion de degres sexagesimaux en degres decimaux
    # @param[in] dms : valeur en degres sexagesimaux a convertir
    # @return valeur en degres decimaux
    proc DmsDd {dms} {

        Message debug "%s\n" [info level [info level]]

        set d [expr double([lindex $dms 0])]
        set m [expr double([lindex $dms 1])]
        set s [expr double([lindex $dms 2])]
        return [expr ($d + $m/60.0 + $s/3600)]
    }

    ##
    # @brief Fermeture de fichier
    # @details L'interet de ce code est de pouvoir tracer le nombre de fichier ouverts à un moment donne. Cela sert a detecter les "fuites de fileid", c'est-a-dire les fichiers qui sont ouverts et jamais fermes. On peut aussi tracer les fichiers qu'on tente de fermer alors qu'ils n'ont pas été ouverts.
    # @param[in] fid : 'channel' a fermer
    # @return
    proc FermetureFichier {fid} {
        variable data_script

        Message debug "%s\n" [info level [info level]]

        if {[catch {close $fid} retour]} {
            Message erreur $retour
        } else {
            incr data_script(nombre_fichier_ouvert) -1
            # A ne pas retablir sans modifier Message (risque de re-entrance infinie)
#            Message debug "nombre fichier ouvert : %d\n" $data_script(nombre_fichier_ouvert)
        }
    }

    ##
    # @brief Lecture de la taille d'une image affichée par AudACE
    # @retval data_script(naxis1) : taille de l'image sur l'axe 1 (X)
    # @retval data_script(naxis2) : taille de l'image sur l'axe 2 (Y)
    proc InformationsImages {} {
        global audace
        variable data_script

        Message debug "%s\n" [info level [info level]]

        set data_script(naxis1) [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
        set data_script(naxis2) [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
    }

    ##
    # @brief Initialisation de données diverses
    # @details
    # - Initialisation des vecteurs graphiques
    # - Suppression de fenetres restantes.
    # - Initialisation de divers compteurs d'objets
    # .
    # @return
    # @todo Voir si cette routine ne peut etre refondue dans InitialisationStatique
    proc Initialisations {} {
        global audace
        variable vx_temp
        variable vy1_temp
        variable vy2_temp
        variable vy3_temp
        variable flux_premiere_etoile
        variable data_script
        catch {destroy $audace(base).saisie}
        catch {destroy $audace(base).selection_etoile}
        catch {destroy $audace(base).selection_aster}
        catch {destroy $audace(base).courbe_lumiere}
        catch {destroy $audace(base).bouton_arret_color_invariant}
        catch {unset flux_premiere_etoile}
        catch {file delete trace_calaphot.log}
        catch {unset premier_temp}

        if {[array exist data_script]} {
            foreach {key} [array names data_script] {
                unset data_script($key)
            }
        }
        if {[array exist data_image]} {
            foreach {key} [array names data_script] {
                unset data_image($key)
            }
        }
        set data_script(nombre_variable) 0
        set data_script(nombre_reference) 0
        set data_script(nombre_indes) 0

        set data_script(nombre_fichier_ouvert) 0

    }

    ##
    # @brief Calcul le jour julien de la date d'exposition d'une image affichée par AudACE
    #
    # @details La date d'exposition d'une image est definie comme etant l'instant du milieu de la pose
    #
    # Cette procedure recupere le jour julien de l'image active.
    # Elle marche pour les images des logiciels suivants:
    # - CCDSoft v5, Audela et Maxim-DL:
    #   - DATE-OBS = la date uniquement,
    #   - TIME-OBS = l'heure de debut en TU,
    #   - EXPOSURE = le temps d'exposition en secondes
    #   .
    # - PRISM v4  :
    #   - DATE-OBS = date & heure de debut de pose (formt Y2K: 'aaaa-mm-jjThh:mm:ss.sss')
    #   - UT-START & UT-END sont valides mais non utilise
    #   - EXPOSURE = le temps d'exposition en minutes!
    #   .
    # .
    # @return la date exprimee en jour julien
    proc JourJulienImage {} {
        global audace

        Message debug "%s\n" [info level [info level]]

        # Recherche du mot clef DATE-OBS dans l'en-t� e FITS
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
        } else {
            set date [string range $date 0 22]
        }

        # Conversion en jour julien (Julian Day)
        set jd_instant [mc_date2jd $date]
        return $jd_instant
    }

    ##
    # @brief Sortie de valeur aur la console et le fichier de log
    # @details @see @ref Console
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatte a afficher
    # @return
    proc Message {niveau_info args} {
        global audace

        set param [eval [concat {format} $args]]
        Console $niveau_info $param
        TraceFichier $niveau_info $param
    }

    ##
    # @brief Mesure du decalage (x,y) entre 2 images par recalage entre elles
    # @details Si cette valeur a ete mesuree auparavant dans une session precedente de Calaphot
    # cette valeur sera extraite du fichier de decalage
    # Sinon le decalage est effectue par recalage (register) de l'image par rapport à une image t1.fit
    # La valeur du recalage est stockee dans l'entete FITS de l'image
    # @param[in] i : numero de l'image dans la sequence
    # @retval data_image($i,decalage_x) : decalage en x
    # @retval data_image($i,decalage_y) : decalage en y
    # @return
    proc MesureDecalage {i} {
        variable parametres
        variable liste_decalage
        variable data_image

        Message debug "%s\n" [info level [info level]]

        # Determination du decalage des images par rapport a la premiere
        if {$parametres(type_images) == "non_recalees"} {
            # Images non recalees
            if [info exist liste_decalage($i)] {
                # Cette valeur existe dans le fichier .lst
                Message debug "Decalage deja calcule\n"
                set data_image($i,decalage_x) [lindex $liste_decalage($i) 0]
                set data_image($i,decalage_y) [lindex $liste_decalage($i) 1]
            } else {
                # Recalage des images par rapport a la premiere image pour connaître le decalage en coordonnees
                Message debug "Decalage en cours de calcul\n"
                loadima $parametres(source)$i
                saveima t2
                register2 t u 2
                loadima u2
                set dec [DecalageImage $i]
                set data_image($i,decalage_x) [lindex $dec 0]
                set data_image($i,decalage_y) [lindex $dec 1]
                # Retablissement de l'image sur laquelle seront faites les mesures
                loadima $parametres(source)$i
            }
        } else {
            # Les images sont deja recalees, pas de decalage entre elles
            Message debug "Les images sont toutes recalees\n"
            set data_image($i,decalage_x) 0.0
            set data_image($i,decalage_y) 0.0
        }
        Message debug "image %d: decalage_x=%10.4f decalage_y=%10.4f\n" $i $data_image($i,decalage_x) $data_image($i,decalage_y)
    }


    ##
    # @brief Ouverture de fichier
    # @details L'interet de ce code est de pouvoir tracer le nombre de fichier ouverts à un moment donne. Cela sert a detecter les "fuites de fileid", c'est-a-dire les fichiers qui sont ouverts et jamais fermes. On peut aussi tracer les fichiers qu'on tente de fermer alors qu'ils n'ont pas été ouverts.
    # @param[in] nom_fichier : nom du fichier
    # @param[in] mode : mode d'ouverture comme defini par TCL
    # @param[in] fatal : drapeau. Si fatal = oui(defaut), affichage d'un message d'ereeur dans la console
    # @retval data_script(nombre_fichier_ouvert) : nombre de fichiers ouverts par ce script
    # @return 'channel' du fichier ouvert si l'ouverture a eu lieu
    # @return "" si l'ouverture a echoue
    proc OuvertureFichier {nom_fichier mode {fatal "oui"} } {
        variable data_script

        Message debug "%s\n" [info level [info level]]

        if {[catch {open $nom_fichier $mode} fid]} {
            if {$fatal == "oui"} {
                Message erreur $fid
            }
            return ""
        } else {
            incr data_script(nombre_fichier_ouvert)
            # A ne pas retablir sans modifir Message (risque de re-entrance infinie)
#            Message debug "nombre fichier ouvert : %d\n" $data_script(nombre_fichier_ouvert)
            return $fid
        }
    }

    ##
    # @brief Affichage des options et parametres qui ont ete saisis
    # @return
    proc RecapitulationOptions {} {
        variable parametres
        variable calaphot

        Message debug "%s\n" [info level [info level]]

        Message notice "\n--------------------------\n"
        Message notice "%s\n" $calaphot(texte,recapitulation)
        foreach champ {objet operateur code_UAI type_capteur type_telescope diametre_telescope focale_telescope catalogue_reference source indice_premier indice_dernier tailleboite signal_bruit gain_camera bruit_lecture sortie fichier_cl} {
            Message notice "\t%s : %s\n" $calaphot(texte,$champ) $parametres($champ)
        }
        foreach champ {mode type_images date_images pose_minute format_sortie} {
            Message notice "\t%s : %s\n" $calaphot(texte,$champ) $parametres($champ)
        }
        if {$parametres(mode) == "ouverture"} {
            foreach champ {surechantillonage rayon1 rayon2 rayon3} {
                Message notice "\t%s : %s\n" $calaphot(texte,o_$champ) $parametres($champ)
            }
        }
        # pas de parametre specifique a la modelisation
#        if {$parametres(mode) == "modelisation"} {
#        }
        if {$parametres(mode) == "sextractor"} {
            foreach champ {saturation} {
                Message notice "\t%s : %s\n" $calaphot(texte,s_$champ) $parametres($champ)
            }
        }
        Message notice "\n--------------------------\n"
    }

    ##
    # @brief Recherche de l'etoile selectionne la plus brillante
    # @details Parcours de la liste pos_theo(ref,i)
    # @return indice de l'etoile la plus brillante de la liste
    proc RecherchePlusBrillante {} {
        variable parametres
        variable data_script
        variable pos_theo

        Message debug "%s\n" [info level [info level]]

        set plus_brillante 0
        set mag_min [lindex $pos_theo(ref,0) 2]
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            if {[lindex $pos_theo(ref,$i) 2] < $mag_min} {
                set mag_min [lindex $pos_theo(ref,$i) 2]
                set plus_brillante $i
            }
        }
        return $plus_brillante
    }

    ##
    # @brief Lecture du fichier .lst qui,s'il existe, contient les decalages entre images calcules lors d'une session precedente de Calaphot
    # @return
    proc RecuperationDecalages {} {
        global audace
        variable parametres
        variable liste_decalage

        Message debug "%s\n" [info level [info level]]

        catch {unset liste_decalage}
        set fichier [OuvertureFichier [file join $audace(rep_images) $parametres(source).lst] r "non"]
        if {$fichier != ""} {
            while {[gets $fichier line] >= 0} {
                set image [lindex $line 0]
                set dec_x [lindex $line 1]
                set dec_y [lindex $line 2]
                set liste_decalage($image) [list $dec_x $dec_y]
                Message debug "image %d: dec_x=%10.4f dec_y=%10.4f\n" $image $dec_x $dec_y
            }
            FermetureFichier $fichier
        }
    }

    #*************************************************************************#
    #*************  RecuperationParametres  **********************************#
    #*************************************************************************#
    ##
    # @brief Lecture des parametres stockés dans calaphot.ini et initialisations
    # @details Si certains parametres n'existent pas dans ce fichier, ou si ce fichier n'existe pas lui-meme,
    # ou encore si on a changé de version de Calaphot,
    # les parametres sont initialises avec des valeurs par defaut (cf Calaphot::InitialisationStatique )
    # @retval parametres
    # @return 0
    proc RecuperationParametres {} {
        global audace
        variable parametres
        variable data_script
        variable pos_theo
        variable coord_aster
        variable calaphot

        # Initialisation
        if {[info exists parametres]} {unset parametres}

        # Ouverture du fichier de parametres
        set fichier $calaphot(nom_fichier_ini)

        if {[file exists $fichier]} {
            source $fichier
            # Verification de la version du calaphot.ini et invalidation eventuelle du contenu
            if { ( (![info exists parametres(version_ini)]) \
                || ([string compare $parametres(version_ini) $calaphot(init,version_ini)] != 0) ) } {
                set parametres(niveau_message) $calaphot(init,niveau_message)
                # Il n'est pas possible d'utiliser Message a cause de $parametres qui n'existe plus
                ::console::affiche_erreur $calaphot(texte,detection_ini)
                foreach {a b} [array get parametres] {unset parametres($a)}
            }
        }

        foreach choix {mode \
            operateur \
            source \
            indice_premier \
            indice_dernier \
            gain_camera \
            bruit_lecture \
            saturation \
            tailleboite \
            rayon1 \
            rayon2 \
            rayon3 \
            sortie \
            fichier_cl \
            objet \
            code_UAI \
            surechantillonage \
            type_capteur \
            type_telescope \
            diametre_telescope \
            focale_telescope \
            catalogue_reference \
            filtre_optique \
            niveau_message \
            tri_images \
            format_sortie \
            type_images \
            pose_minute \
            date_images \
            reprise_astres \
            signal_bruit \
            type_objet \
            version_ini} {
            if {![info exists parametres($choix)]} {set parametres($choix) $calaphot(init,$choix)}
        }
    }

    ##
    # @brief Verification que la libjm charge est d'une version correcte
    # @return 0 la libjm est de la bonne version
    # @return 1 cas contraire
    proc Ressources {} {
        global blt_version
        global audace
        variable calaphot

#        Message debug "%s\n" [info level [info level]]

        if {[catch {jm_versionlib} version_lib]} {
            Message console "%s\n" $calaphot(texte,mauvaise_version)
            return 1
        } else {
            if {[expr double([string range $version_lib 0 2])] < 3.0} {
                Message console "%s\n" $calaphot(texte,mauvaise_version)
                return 1
            }
        }
        return 0
    }

    ##
    # @brief Sauvegarde dans un fichier des decalages entre images
    # @details Le but de ceci est d'accelerer les traitements lors d'un session Calaphot qui porterait sur les memes images
    # Le nom du fichier depend du repertoire d'images et du nom generique des images
    # @return
    proc SauvegardeDecalages {} {
        global audace
        variable parametres
        variable data_image
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        if {$parametres(type_images) == "non_recalees"} {
            # On ne sauvegarde les decalages que si les images ne sont pas recalees a la base

            set fichier [OuvertureFichier [file join $audace(rep_images) $parametres(source).lst] w]
            if {($fichier != "")} {
                foreach image $liste_image {
                    puts $fichier "$image $data_image($image,decalage_x) $data_image($image,decalage_y)"
                    Message debug "image %d: dec_x=%10.4f dec_y=%10.4f\n" $image $data_image($image,decalage_x) $data_image($image,decalage_y)
                }
            }
            FermetureFichier $fichier
        }
    }

    ##
    # @brief Sauvegarde dans un fichier des parametre de la session courante
    # @details Ces parametres ont ete lus dans le fichier calaphot.ini, et eventuellement
    # modifies dans l'ecran de saisie
    # @return
    proc SauvegardeParametres {} {
        global audace
        variable parametres
        variable data_script
        variable coord_aster
        variable pos_theo
        variable calaphot

        Message debug "%s\n" [info level [info level]]

#        set fichier [OuvertureFichier [file join calaphot $calaphot(nom_fichier_ini)] w]
        set fichier [OuvertureFichier $calaphot(nom_fichier_ini) w]
        if {($fichier != "")} {
            foreach {a b} [array get parametres] {
                puts $fichier "set parametres($a) \"$b\""
            }
            puts $fichier "set data_script(nombre_variable) $data_script(nombre_variable)"
            for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
                puts $fichier "set coord_aster($i,1) \{$coord_aster($i,1)\}"
                puts $fichier "set coord_aster($i,2) \{$coord_aster($i,2)\}"
            }
            puts $fichier "set data_script(nombre_reference) $data_script(nombre_reference)"
            for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
                puts $fichier "set pos_theo(ref,$i) \{$pos_theo(ref,$i)\}"
            }
            puts $fichier "set data_script(nombre_indes) $data_script(nombre_indes)"
            for {set i 0} {$i < $data_script(nombre_indes)} {incr i} {
                puts $fichier "set pos_theo(indes,$i) \{$pos_theo(indes,$i)\}"
            }
        }
        FermetureFichier $fichier
    }

    ##
    # @brief Generation d'un script pour recreer la courbe de lumiere
    # @deprecated
    # @param[in] x : vecteur sur l'axe X
    # @param[in] y1 : vecteur sur l'axe Y
    # @param[in] y2 : vecteur sur l'axe Y
    # @param[in] y3 : vecteur sur l'axe Y
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

    ##
    # @brief Ecrit des messages dans un fichier de log
    # @details @see @ref Console
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatte a afficher
    # @return
    proc TraceFichier {niveau_info args} {
        global audace
        variable calaphot
        variable parametres

        if {($calaphot(niveau_notice) <= $calaphot(niveau_$niveau_info))} {
            set fid [open [file join $audace(rep_images) $parametres(sortie)] a]
            puts -nonewline $fid [eval [concat {format} $args]]
            close $fid
        }
    }

    ##
    # @brief Tri des images par dates croissantes, et eliminant les doublons
    # @retval liste_image : liste trieee de tous les indices des images
    # @retval data_script(premier_liste) : indice de la premiere image
    # @retval data_script(dernier_liste) : indice de la derniere image
    # @return
    proc TriDateImage {} {
        global audace
        variable parametres
        variable data_script
        variable data_image
        variable calaphot
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        if {$parametres(tri_images) == "oui"} {
            # Les images ne sont pas triees par date, il faut le faire
            Message info "%s\n" $calaphot(texte,tri_images)
            set liste_date [list]
            set liste_image_triee [list]
            catch {unset tableau_date}

            for {set i $parametres(indice_premier)} {$i <= $parametres(indice_dernier)} {incr i 1} {
                loadima $parametres(source)$i
                DateImage $i
                # Pour eviter les doublons
                if {![info exists tableau_date($data_image($i,date))]} {
                    set tableau_date($data_image($i,date)) $i
                    lappend liste_date $data_image($i,date)
                }
            }

            # Tri proprement dit
            set liste_date_triee [lsort -real -increasing $liste_date]
            # Creation de la liste triee
            foreach date $liste_date_triee {
                lappend liste_image_triee $tableau_date($date)
            }

            # On efface une liste de recalage, pour ne pas prendre de risque
            catch {file delete [file join $audace(rep_images) $parametres(source).lst]}
        } else {
            # Images triees : la liste va juste reprendre les indices des images
            for {set i $parametres(indice_premier)} {$i <= $parametres(indice_dernier)} {incr i 1} {
                lappend liste_image_triee $i
            }
        }
        set data_script(premier_liste) [lindex $liste_image_triee 0]
        set data_script(dernier_liste) [lindex $liste_image_triee end]
        set liste_image $liste_image_triee
    }

    ##
    # @brief Verification que tous les fichiers images de la sequence existent
    # @return
    proc Verification {} {
        global audace conf
        variable parametres
        variable calaphot

        Message debug "%s\n" [info level [info level]]

        # Verification des indices
        if {$parametres(indice_premier) >= $parametres(indice_dernier)} {
            Message erreur "%s\n" $calaphot(texte,err_indice)
            EffaceMotif astres
            return (1)
        }

        # Verification de ce que les images existent
        Message info $calaphot(texte,verification) $parametres(source) $parametres(indice_premier) $parametres(indice_dernier) "\n"
        for {set image $parametres(indice_premier)} {$image <= $parametres(indice_dernier)} {incr image} {
            set nom_fichier [file join $audace(rep_images) $parametres(source)$image$conf(extension,defaut)]
            if {![file exists $nom_fichier]} {
                # Recherche si le fichier existe en compresse
                set nom_fichier_gz $nom_fichier
                append nom_fichier_gz ".gz"
                if {![file exists $nom_fichier_gz]} {
                    Message erreur "%s %s %s\n" $calaphot(texte,err_existence_1) [file rootname [file tail $nom_fichier] ] $calaphot(texte,err_existence_2)
                    EffaceMotif astres
                    return (1)
                }
            }
        }
        return 0
    }

    ##
    # @brief Reglage des seuils de visualisation d'une image dans AudACE
    # @deprecated
    # @param[in] mode : optimal ou rapide
    # @bug : les 2 valeurs de mode sont identiques
    proc Visualisation {mode} {
        global audace
        variable data_script

        Message debug "%s\n" [info level [info level]]

        if {$mode == "optimale"} {
            set fond_ciel [lindex [buf$audace(bufNo) stat] 6]
            set data_script(seuil_haut) [expr $fond_ciel + 300]
            set data_script(seuil_bas) [expr $fond_ciel - 50]
        }
        if {$mode == "rapide"} {
            if {![info exist data_script(seuil_haut)]} {
                set fond_ciel [lindex [buf$audace(bufNo) stat] 6]
                set data_script(seuil_haut) [expr $fond_ciel + 300]
                set data_script(seuil_bas) [expr $fond_ciel - 50]
            }
        }
        visu$audace(visuNo) disp [list $data_script(seuil_haut) $data_script(seuil_bas)]
        update
    }


}
# Fin du namespace Calaphot


