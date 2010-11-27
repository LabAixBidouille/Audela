##
# @file calaphot_principal.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Script pour la photometrie d'asteroides ou d'etoiles variables.
#
# $Id: calaphot_principal.tcl,v 1.20 2010-11-27 15:55:12 jacquesmichelet Exp $
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
# - plantage lors de l'affichage de la CL si aucune image n'est validée (premier n'existe pas)
# - mode sextractor ne marche pas si les repertoires ont des blancs dans leurs noms (exe, images ou configs)
# - pb d'affichage des valeurs numériques si on refait le pointage de l'astéroïde sur la 1ere image
# .
#
#

##
# @brief Calaphot est un script permettant de faire de la photométrie différentielle sur un lot d'images
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
        variable trace_log
        variable pas_a_pas
        variable data_script
        variable parametres

        # L'existence de trace_log cree le ficher debug.log et le mode d'affichage debug
        catch {  unset trace_log }
#        set trace_log 1
        # L'existence de pas_a_pas permet permet de ne traiter une image que si on tape une séquence de caractères
        # Utile en mode debug
        catch {unset pas_a_pas}
#        set pas_a_pas 1

        calaphot_niveau_traces 4

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

        set calaphot(nom_fichier_ini)           [file join $::audace(rep_home) calaphot.ini]
        set calaphot(nom_fichier_log)           [file join $::audace(rep_log) calaphot.log]

        set calaphot(sextractor,catalog)        [ file join $::audace(rep_temp) calaphot.cat ]
        set calaphot(sextractor,config)         [ file join $::audace(rep_temp) calaphot.sex ]
        set calaphot(sextractor,param)          [ file join $::audace(rep_temp) calaphot.param ]
        set calaphot(sextractor,neurone)        [ file join $::audace(rep_temp) calaphot.nnw ]
        set calaphot(sextractor,assoc)          [ file join $::audace(rep_temp) calaphot.assoc ]

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
        set calaphot(init,sortie)               "kandrup"
        set calaphot(init,fichier_cl)           "kandrup"
        set calaphot(init,objet)                Kandrup
        set calaphot(init,code_UAI)             615
        set calaphot(init,surechantillonage)    5
        set calaphot(init,type_capteur)         "Kaf1600"
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
        set calaphot(init,defocalisation)       "non"
        set calaphot(init,version_ini)          $numero_version

        # couleur des affichages console
        foreach niveau { debug info notice probleme erreur } couleur_style { black purple blue orange red } {
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
        if { $librairie != 0 } { return }

        # Initialisations diverses
        Initialisations data_image data_script

        # Lecture du fichier de parametres
        RecuperationParametres

        Console notice "%s %s\n" $calaphot(texte,titre) $calaphot(init,version_ini)
        Console notice "%s\n" $calaphot(texte,copyright)

        PasAPas

        set demande_arret 0
        SaisieParametres
        SauvegardeParametres

        catch { file delete [ file join $::audace(rep_images) $parametres(sortie) ] }

        TraceFichier ${parametres(sortie)}.txt notice "%s %s\n" $calaphot(texte,titre) $calaphot(init,version_ini)
        TraceFichier ${parametres(sortie)}.txt notice "%s\n" $calaphot(texte,copyright)

        if { $demande_arret == 1 } {
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Affiche l'heure du début de traitement
        Message notice "%s %s\n\n" $calaphot(texte,heure_debut) [clock format [clock seconds]]

        # Vérification de l'existence des images
        set erreur [ Verification ]
        if { $erreur != 0 } {
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Initialisations spécifiques à Sextractor
        if {( $parametres(mode) == "sextractor" )} {
            CreationFichiersSextractor
        }

        # Récuperation d'informations sur les images
        InformationsImages

        # Recapitulation des options choisies
        RecapitulationOptions

        # Tri des images par date croissante et constitution de la liste des indices
        set liste_image [ TriDateImage ]

        # Récupération des décalages entre image (s'ils existent)
        RecuperationDecalages

        set images_initiales [ RecalageInitial t ]
        AffichageMenus $images_initiales

        # 2eme sauvegarde, avec les coordonnees graphiques des astres
        SauvegardeParametres

        if { $demande_arret == 1 } {
            $audace(hCanvas) delete marqueurs
            Message probleme "%s\n" $calaphot(texte,fin_anticipee)
            return
        }

        # Recherche de l'étoile la plus brillante
        set eclat_max [ RecherchePlusBrillante ]

        # Calcul des dates extremes
        set temp [ DatesReferences ]
        set jd_premier [ lindex $temp 0 ]
        set jd_dernier [ lindex $temp 1 ]
        set delta_jd [ lindex $temp 2 ]

        # Calcul de la vitesse apparente des astéroïdes
        VitesseAsteroide
        Message info "\n"
        for { set v 0 } { $v < $data_script(nombre_variable) } { incr v } {
            Message info "%s %8.2f/%8.2f\n" $calaphot(texte,vitesse_asteroide) $vitesse_variable($v,x) $vitesse_variable($v,y)
        }

        # Calcul de magnitude de la super-étoile
        CalculMagSuperEtoile
        Message notice "%s %5.3f\n" $calaphot(texte,mag_superetoile) $data_script(mag_ref_totale)
        Message notice "%s %d\n" $calaphot(texte,calcul_ellipses) $eclat_max

        # Quelques initialisations
        set nombre_image [ llength $liste_image ]
        set data_script(nombre_image) $nombre_image

        # Affiche les titres des colonnes
        Entete

        # Mise en place du bouton d'arret
        BoutonArret

        # Affichage de la courbe de lumiere dynamique
        set liste_courbes_temporaires [ ::CalaPhot::CourbeLumiereTemporaire ]

        set data_image(0,valide) "Y"
        Message debug "existence de data_image : %s\n" [ array exists data_image ]
        Message debug "indices de data_image : %s\n" [ array names data_image ]


        # Boucle principale sur les images de la série
        #----------------------------------------------
        foreach image $liste_image {
            Message debug "Traitement de l'image no %d\n" $image
            # A priori, l'image est bonne. On verra par la suite
            set indice $image
            set data_image($indice,valide) "Y"

            # Effacement des symboles mis sur l'image précédente
            EffaceMotif astres

            # Détection de l'appui sur le bouton d'arrêt
            if { $demande_arret == 1 } {
                ArretScript
                EffaceMotif astres
                Message probleme "%s\n" $calaphot(texte,fin_anticipee)
                return
            }

            # Chargement et visualisation de l'image traitée
            loadima $parametres(source)$image
            Visualisation rapide

            # Recherche la date de l'image dans l'entête FITS (déjà fait si les images étaient déclarées non triées)
            if { [ DateImage $image ] } {
                EliminationImage $image
                Message erreur "%s %i : %s\n" $calaphot(texte,image) $image $calaphot(texte,temps_pose_nul)
                ArretScript
                Message probleme "%s\n" $calaphot(texte,fin_anticipee)
                return
            }

            if { [ DateCroissante $image ] } {
                EliminationImage $image
                Message erreur "%s %i : %s\n" $calaphot(texte,image) $image $calaphot(texte,plus_jeune)
                ArretScript
                Message probleme "%s\n" $calaphot(texte,fin_anticipee)
                return
            }

            # Determination du décalage géometrique
            set test [ MesureDecalage $image ]
            if { $test != 0 } {
                EliminationImage $image
                AttentePasAPas
                continue
            }

            # Calcule la position des astéroides par interpolation sur les dates (sans tenir compte du décalage des images)
            CalculPositionsTheoriques $image

            # Calcul de toutes les positions réelles des astres (astéroides compris) à considérer ET à supprimer, en tenant compte du décalage en coordonnées des images
            set test [ CalculPositionsReelles $image ]
            if { $test != 0 } {
                EliminationImage $image
                AttentePasAPas
                continue
            }

            # Recalage astrometrique
#            RecalageAstrometrique $i

            # Calcul des coordonnees equatoriales
#            XyAddec $i

            # Calcul de la masse d'air
#            MasseAir $i

            # Suppression de toutes les etoiles indesirables
            SuppressionIndesirables $image

            # Les astres (etoiles + asteroides) sont modélisées dans TOUS les cas
            #  Un certain nombre de valeurs individuelles sont mises à jour dans data_image
            set test 0
            for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
                # Dessin d un rectangle
                Dessin rectangle $pos_reel($image,ref,$j) [ list $parametres(tailleboite) $parametres(tailleboite) ] $color(green) etoile_$j
                # Modélisation
                incr test [ Modelisation2D $image $j ref $pos_reel($image,ref,$j) ]
            }
            for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
                # Dessin d un rectangle
                Dessin rectangle $pos_reel($image,var,$j) [ list $parametres(tailleboite) $parametres(tailleboite) ] $color(yellow) etoile_$j
                # Modélisation
                incr test [ Modelisation2D $image $j var $pos_reel($image,var,$j) ]
            }
            if { $test != 0 } {
                # Au moins un astéroide ou une étoile de ref. n'a pas été modélisée correctement
                # Donc on élimine l'image
                EliminationImage $image
                AttentePasAPas
                continue
            }

            if { $parametres(mode) == "ouverture" } {
                # Cas ouverture
                # Calcul des axes principaux des ellipses a partir des fwhm des etoiles de reference
                # NB : il faut pour cela connaitre les modeles de TOUTES les etoiles
                set ellipses [ CalculEllipses $image ]
                if { [ lindex $ellipses 0 ] == 1 } {
                    set r1x [ lindex $ellipses 1 ]
                    set r1y [ lindex $ellipses 2 ]
                    set r2 [ lindex $ellipses 3 ]
                    set r3 [ lindex $ellipses 4 ]

                    for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
                       FluxOuverture $image ref $j
                    }
                    for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
                       FluxOuverture $image var $j
                    }
                } else {
                    set data_script($image,invalidation) [ list ellipses ]
                    EliminationImage $image
                    AttentePasAPas
                    continue
                }
            }

            if {($parametres(mode) == "sextractor")} {
                # Cas Sextractor
                set test [ Sextractor [file join $::audace(rep_images) $parametres(source)$image$conf(extension,defaut) ] ]
                if { $test != 0 } {
                    set data_script($image,invalidation) [ list sextractor ]
                    set data_image($image,valide) "N"
                    EliminationImage $image
                    AttentePasAPas
                    continue
                }
                for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
                    set temp [ RechercheCatalogue $image ref $j ]
                    if { [ llength $temp ] != 0 } {
                        FluxSextractor $image ref $j $temp
                    } else {
                        set data_script($image,invalidation) [ list sextractor ref $j ]
                        EliminationImage $image
                        AttentePasAPas
                        break
                    }
                }
                for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
                    set temp [ RechercheCatalogue $image var $j ]
                    Message debug "temp=%s (l=%d)\n" $temp [ llength $temp ]
                    if { [ llength $temp ] != 0 } {
                        FluxSextractor $image var $j $temp
                    } else {
                        set data_script($image,invalidation) [list sextractor var $j]
                        EliminationImage $image
                        AttentePasAPas
                        break
                    }
                }
            }

            if { $data_image($image,valide) == "N" } {
                EliminationImage $image
                AttentePasAPas
                continue
            }

            # Dessin des symboles
            for { set j 0 } { $j < $data_script(nombre_reference) } { incr j } {
                # Dessin des axes principaux
                if { $data_image($image,ref,centroide_x_$j) >= 0 } {
                    # La modélisation a réussi
                    Dessin2 $image ref $j $parametres(rayon1) $color(green) etoile_$j
                } else {
                    # Pas de modélisation possible
                    Dessin verticale [ list $data_image($image,ref,centroide_x_$j) $data_image($image,ref,centroide_y_$j) ] \
                        [ list $parametres(tailleboite) $parametres(tailleboite) ] \
                        $color(red) etoile_$j
                    Dessin horizontale [list $data_image($image,ref,centroide_x_$j) $data_image($image,ref,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                }
            }
            for { set j 0 } { $j < $data_script(nombre_variable) } { incr j } {
                # Dessin des axes principaux
                if {$data_image($image,var,centroide_x_$j) >= 0} {
                    # La modélisation a reussi
                    Dessin2 $image var $j $parametres(rayon1) $color(yellow) etoile_$j
                } else {
                    # Pas de modélisation possible
                    Dessin verticale [list $data_image($image,var,centroide_x_$j) $data_image($image,var,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                    Dessin horizontale [list $data_image($image,var,centroide_x_$j) $data_image($image,var,centroide_y_$j)] \
                        [list $parametres(tailleboite) $parametres(tailleboite)] \
                        $color(red) etoile_$j
                }
            }

            FluxReference $image

            # Calcul des magnitudes et des incertitudes de tous les astres (astéroïdes et étoiles)
            MagnitudesEtoiles $image

            # Premier filtrage sur les rapports signal à bruit
            FiltrageSB $image

            # Calcul d'incertitude global
            CalculErreurGlobal $image

            # Affiche le résultat dans la console
            AffichageResultatsBruts $image

            # Calculs des vecteurs pour le pré-affichage de la courbe de lumière
            PreAffiche $image

            # Mode pas à pas
            AttentePasAPas
        }
         # Effacement des marqueurs d'étoile
         EffaceMotif astres

        # Suppression du bouton d'arrêt
         destroy $audace(base).bouton_arret_color_invariant

         # Sauvegarde des décalages entre images
         SauvegardeDecalages

         # Deuxieme filtrage sur les images pour filtrer celles douteuses
         FiltrageConstanteMag

         # Calcul du coeff. d'extinction de la masse d'air
#         ExtinctionMasseAir

         # Statistiques sur les étoiles a partir des images validées
         Statistiques 1

        for { set etoile 0 } { $etoile < $data_script(nombre_variable) } { incr etoile 1 } {
            Message notice "%s : %s %07.4f %s %6.4f\n" $calaphot(texte,asteroide)  $calaphot(texte,moyenne) $moyenne(var,$etoile) $calaphot(texte,ecart_type) $ecart_type(var,$etoile)
         }
        for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile 1 } {
            Message notice "%s : %s %07.4f %s %6.4f\n" $calaphot(texte,etoile)  $calaphot(texte,moyenne) $moyenne(ref,$etoile) $calaphot(texte,ecart_type) $ecart_type(ref,$etoile)
         }

         # Sortie standardisée des valeurs
         if { $parametres(format_sortie) == "canopus" } {
            AffichageCanopus
         } else {
            GenerationFichierCDR
         }
        GenerationFichierCSV
        set origine_temps [GenerationFichierDAT]
        GenerationFichierGnuplot $origine_temps

        DestructionFichiersAuxiliaires

         # Affiche l'heure de fin de traitement
         Message notice "\n\n%s %s\n" $calaphot(texte,heure_fin) [clock format [clock seconds]]
         Message notice "%s\n" $calaphot(texte,fin_normale)

         # Destruction des courbes de lumière temporaires
         DestructionCourbesTemporaires $liste_courbes_temporaires

         # Affichage de la courbe de lumière
        ExecutionGnuplot

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
    # @brief Attente que l'utilisateur valide la suite du script. NE SERT QU'AU DEBOGAGE
    # @return
    proc AttentePasAPas {} {
        variable pas_a_pas
        if { [ info exists pas_a_pas ] } {
            vwait ::CalaPhot::calaphot(suite_du_script)
        }
    }

    ##
    # @brief Stockage des résultats avec le format CDR (cf site de Raoul Behrend)
    # @details Le contenu de ce fichier peut directement etre exporté pour le logiciel Courbrot
    # @return toujours 0
    proc GenerationFichierCDR {} {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        set nom_fichier [file join $::audace(rep_images) ${parametres(sortie)}.cdr]
        # effacement de la version précédente
        catch {[file delete -force $nom_fichier]}

        set premier [lindex $liste_image 0]

        set f [open $nom_fichier "w"]
        puts -nonewline $f [format "NOM %s\n" $parametres(objet)]
        puts -nonewline $f [format "MES %s" $parametres(operateur)]
        if {[string length $parametres(code_UAI)] != 0} {
            puts -nonewline $f [format " @%s\n" $parametres(code_UAI)]
        } else {
            puts $f "\n"
        }
        puts -nonewline $f [format "POS 0 %5.2f\n" $data_image($premier,temps_expo)]
        puts -nonewline $f [format "CAP %s\n" $parametres(type_capteur)]
        puts -nonewline $f [format "TEL %s %s %s\n" $parametres(diametre_telescope) $parametres(focale_telescope) $parametres(type_telescope)]
        puts -nonewline $f [format "CAT %s\n" $parametres(catalogue_reference)]
        puts -nonewline $f [format "FIL %s\n" $parametres(filtre_optique)]
        puts -nonewline $f [format "; %s %s %s\n" $calaphot(texte,banniere_CDR_1) $calaphot(init,version_ini) $calaphot(texte,banniere_CDR_2)]
        set image 0

        foreach i $liste_image {
            if {$data_image($i,valide) == "Y"} {
                incr image
                puts -nonewline $f " 1 1"
                # Passage de la date en format amj,ddd
                set amjhms [mc_date2ymdhms $data_image($i,date)]
                set date_claire "[format %04d [lindex $amjhms 0]]"
                append date_claire "[format %02d [lindex $amjhms 1]]"
                append date_claire "[format %02d [lindex $amjhms 2]]"
                set hms [format %6.5f [expr double([lindex $amjhms 3])/24.0 + double([lindex $amjhms 4])/1440.0 + double([lindex $amjhms 5])/86400.0]]
                set hms [string range $hms [string first . $hms] end]
                append date_claire $hms
                puts -nonewline $f [format " %14.5f" $date_claire]
                puts -nonewline $f " T"
                puts -nonewline $f [format " %6.3f" $data_image($i,var,mag_0)]
                puts -nonewline $f [format " %6.3f\n" $data_image($i,var,incertitude_0)]
            }
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec le format CSV (Comma Separated Values)
    # @details Le resultat de cet affichage peut directement etre importé par un tableur
    # @return toujours 0
    proc GenerationFichierCSV { } {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier [ file join $::audace(rep_images) ${parametres(sortie)}.csv ]
        # effacement de la version précédente
        catch { file delete -force $nom_fichier }
        if { [ catch { open $nom_fichier "w" } f ] } {
            Message erreur $f
            return
        }

        puts -nonewline $f [ format "year;month;day;hour;min;sec;" ]
        puts -nonewline $f [ format "JJ;Mag var;Inc var;" ]
        for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
            puts -nonewline $f [ format "Mag ref%d;+/-;" $etoile ]
        }
        puts -nonewline $f [ format "Const. mag;Valid\n" ]
        foreach i $liste_image {
            set temps [ mc_date2ymdhms $data_image($i,date) ]
            puts -nonewline $f [ format "%02d;%02d;%04d;" [lindex $temps 0] [lindex $temps 1] [lindex $temps 2] ]
            puts -nonewline $f [ format "%02d;%02d;%02d;" [lindex $temps 3] [lindex $temps 4] [expr round([lindex $temps 5])] ]
            puts -nonewline $f [ format "%04d;%15.5f;" $i $data_image($i,date) ]
            if { [ info exists data_image($i,var,mag_0) ] } {
                puts -nonewline $f [ format "%07.4f;%07.4f;" $data_image($i,var,mag_0) $data_image($i,var,incertitude_0) ]
                for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                    puts -nonewline $f [ format "%07.4f;%07.4f;" $data_image($i,ref,mag_$etoile) $data_image($i,ref,incertitude_$etoile) ]
                }
                puts -nonewline $f [ format "%7.4f;" $data_image($i,constante_mag) ]
            } else {
                puts -nonewline $f [ format "99.9999;00.0000\n" ]
            }
            puts -nonewline $f [ format "%s\n" $data_image($i,valide) ]
        }
        close $f
    }

    ##
    # @brief Stockage des résultats avec un format CSV pour Gnuplot
    # @details Le resultat de cet affichage peut directement etre importé lu par Gnuplot
    # @return la partie entière du jour julien de la première image
    proc GenerationFichierDAT { } {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [ info level [ info level ] ]

        set nom_fichier [file join $::audace(rep_images) ${parametres(sortie)}.dat]
        # effacement de la version précédente
        catch { file delete -force $nom_fichier }
        if { [ catch { open $nom_fichier "w" } f ] } {
            Message erreur $f
            return
        }

        if { $data_script(images_valides) == 0 } {
            return
        }

        set premier 1
        foreach i $liste_image {
            set temps [mc_date2ymdhms $data_image($i,date)]
            if { [ info exists data_image($i,var,mag_0) ] } {
                if { $premier != 0 } {
                    # Mise en mémoire de la première donnée
                    set orig_temps [ expr floor($data_image($i,date)) ]
                    set orig_mag_var_0 $data_image($i,var,mag_0)
                    for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                        set orig_mag_ref($etoile) $data_image($i,ref,mag_$etoile)
                    }
                    set orig_cste_mag $data_image($i,constante_mag)
                    set premier 0
                }
                # Enregistrement des données relatives à la première donnée
                # Pour que le diagramme soit plus lisible, les références ont un décalage de 1 mag, la cste des mag de 2
                puts -nonewline $f [ format "%04d;%15.5f;" $i [ expr $data_image($i,date) - $orig_temps ] ]
                puts -nonewline $f [ format "%07.4f;%07.4f;" [ expr $data_image($i,var,mag_0) - $orig_mag_var_0 ] $data_image($i,var,incertitude_0) ]
                for { set etoile 0 } { $etoile < $data_script(nombre_reference) } { incr etoile } {
                    puts -nonewline $f [ format "%07.4f;%07.4f;" [ expr $data_image($i,ref,mag_$etoile) - $orig_mag_ref($etoile) + 1.0 ] $data_image($i,ref,incertitude_$etoile) ]
                }
                puts -nonewline $f [ format "%7.4f\n" [ expr $data_image($i,constante_mag) - $orig_cste_mag + 2.0 ] ]
            }
        }
        close $f
        return $orig_temps
    }

    ##
    # @brief Création d'un fichier destiné à être exécuté par Gnuplot
    # @details Ce fichier script utilise le fichier DAT comme source des données
    # @return toujours 0
    proc GenerationFichierGnuplot {origine_temps} {
        global audace
        variable data_image
        variable parametres
        variable calaphot
        variable data_script
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        set nom_fichier_gplt [file join $::audace(rep_images) ${parametres(sortie)}.plt]
        set nom_fichier_dat [file join $::audace(rep_images) ${parametres(sortie)}.dat]
        # effacement de la version précédente
        catch {[file delete -force $nom_fichier_plt]}

        if { $data_script(images_valides) == 0 } {
            return
        }

        set f [open $nom_fichier_gplt "w"]
        puts $f "set datafile separator \";\""
        puts $f "set title \"$parametres(objet)\""
        puts $f "set xlabel \"$calaphot(texte,jour_julien) - $origine_temps\""
        puts $f "set ylabel \"$calaphot(texte,mag_relative)\""
        puts -nonewline $f "plot \'$nom_fichier_dat\' using 2:3:4 with errorlines title \"$parametres(objet)\""
        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            puts $f " , \\"
            puts -nonewline $f "    \'\' using 2:[expr 5 + 2 * $etoile]:[expr 6 + 2* $etoile] with errorline title \"$calaphot(texte,etoile_reference)  $etoile\""
        }
        puts $f " , \\"
        puts -nonewline $f "    \'\' using 2:[expr 5 + 2 * $etoile] with lines title \"$calaphot(texte,constante_mag)\""
        puts $f ""
        puts $f "pause -1"
        close $f
    }

    ##
    # @brief Execution du fichier Gnuplot créé par GenerationFichierGnuplot
    # @details Uniquement sous Linux
    # @return toujours 0
    proc ExecutionGnuplot {} {
        variable parametres
        variable data_script

        if { ( $::tcl_platform(os) == "Linux" ) && ( $data_script(images_valides) != 0 ) } {
            set nom_fichier_gplt [file join $::audace(rep_images) ${parametres(sortie)}.plt]
            catch { exec gnuplot $nom_fichier_gplt & }
        }
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

            if { [ info exists trace_log ] } {
                set filetest [ open [ file join $::audace(rep_log) trace_calaphot.log ] a ]
                if { $filetest != "" } {
                    puts $filetest [ concat [ string repeat "." [ expr [ info level ] - 1 ] ] [ eval [ concat { format } $args ] ] ]
                    flush $filetest
                }
                close $filetest
            }
        }
    }

    ##
    # @brief Verification que les images sont dans un ordre de date croissante
    # @param[in] i : numero de l'image dans la sequence
    # @return : -1 si le temps de l'image est plus petit que celui de l'image précédente, 0, dans le cas normal
    proc DateCroissante { i } {
        variable data_script
        variable liste_image
        variable data_image

        Message debug "%s\n" [ info level [ info level ] ]

        if { $i == $data_script(premier_liste) } {
            # On ne fait rien pour la 1ere image
            return 0
        } else {
            # Recherche de l'image précédente
            set index [ lsearch $liste_image $i ]
            incr index -1
            set j [ lindex $liste_image $index ]
            if { $data_image($i,date) > $data_image($j,date) } {
                return 0
            } else {
                Message probleme "Date image %d %f <= date image %d %f\n" $i $data_image($i,date) $j $data_image($j,date)
                return -1
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

        Message debug "Image %d: Temps exposition : %f\n" $i $expo
        if { ([string length $expo] == 0) || ($expo == 0) } {
            Message probleme "%s %i : %s\n" $calaphot(texte,image) $i $calaphot(texte,temps_pose_nul)
            return -1
        }

        if {$parametres(pose_minute) == "minute"} {
            set expo [expr $expo * 60.0]
        }
        set data_image($i,temps_expo) $expo

        # Calcul de la date exacte
        set jd [ JourJulienImage ]
        if {$parametres(date_images) == "debut_pose"} {
            # Cas debut de pose (on rajoute le 1/2 temps de pose converti en jour julien).
            set data_image($i,date) [expr $jd + ($expo / 172800.0)]
        } else {
            # Cas milieu de pose
            set data_image($i,date) $jd
        }
        Message debug "Image %d: Date %s\n" $i $data_image($i,date)

        return 0
    }


    ##
    # @brief Recherche des dates de la 1ère et de la dernière image de la séquence et calcul de la difference
    # @retval data_script(jd_premier) : date en jour julien de la 1ère image
    # @retval data_script(jd_dernier) : date en jour julien de la dernière image
    # @retval data_script(jd_delta) : difference des dates précédentes
    # @return liste des 3 paramètres de sortie
    proc DatesReferences {} {
        global audace
        variable parametres
        variable liste_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

        # Charge et affiche la premiere image
        set premier [ lindex $liste_image 0 ]
        set nom_fichier $parametres(source)$premier
        loadima $nom_fichier
        set jd_premiere [ JourJulienImage ]
        set data_script(jd_premier) $jd_premiere

        # Charge et affiche la derniere image
        set dernier [ lindex $liste_image end ]
        set nom_fichier $parametres(source)$dernier
        loadima $nom_fichier
        set jd_derniere [ JourJulienImage ]
        set data_script(jd_dernier) $jd_derniere

        set delta_jd [ expr $jd_derniere - $jd_premiere ]
        set data_script(delta_jd) $delta_jd

        return [list $jd_premiere $jd_derniere $delta_jd]
    }

    ##
    # @brief Lecture du décalage en (x,y) de l'image recalée préalablement
    # @details Le décalage est lu a partir du mot cle IMA/SERIES REGISTER dans l'entête FITS de l'image
    # @param[in] image : no de l'image dans la séquence
    # @return liste contenant le décalage en x et y
    proc DecalageImage { image } {
        Message debug "%s\n" [ info level [ info level ] ]

        # --- recupere la liste des mots cles de l'image FITS
        set listkey [ lsort -dictionary [ buf$::audace(bufNo) getkwds ] ]
        # Recherche de la dernière ligne contenant la chaîne IMA/SERIES REGISTER
        foreach key $listkey {
            set listligne [ buf$::audace(bufNo) getkwd $key ]
            set value [ lindex $listligne 1 ]
            if { $value == "IMA/SERIES REGISTER" } {
                # Extraction de l'indice du mot cle TT
                set keyname [ lindex $listligne 0 ]
                set indice [ string range $keyname 2 end ]
            }
        }

        if { ![ info exists indice ] } {
            set dec [ list 0 0 0 ]
        } else {
            # On a maintenant repéré la fonction TT qui pointe sur la dernière registration.
            # --- on recherche la ligne FITS contenant le mot clé indice + 1
            incr indice
            set listligne [ buf$::audace(bufNo) getkwd "TT$indice" ]
            set param [ lindex $listligne 1 ]
            set dx [ lindex $param 2 ]

            # --- on recherche la ligne FITS contenant le mot clé indice + 2
            incr indice
            set listligne [ buf$::audace(bufNo) getkwd "TT$indice" ]
            set param [ lindex $listligne 1 ]
            set dy [ lindex $param 2 ]

            # --- on recherche la ligne FITS contenant le mot clé indice + 2
            incr indice
            set listligne [ buf$::audace(bufNo) getkwd "TT$indice" ]
            set param [ lindex $listligne 1 ]
            set nbre_etoiles [ lindex $param 0 ]

            # Fin de la lecture du décalage
            set dec [ list $dx $dy $nbre_etoiles ]
        }
        return $dec
    }

    ##
    # @brief Destruction des fichiers auxiliaires
    # @return rien
    proc DestructionFichiersAuxiliaires { } {
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        catch { file delete $calaphot(sextractor,param) }
        catch { file delete $calaphot(sextractor,config) }
        catch { file delete $calaphot(sextractor,neurone) }
        catch { file delete $calaphot(sextractor,assoc) }
        catch { file delete $calaphot(sextractor,catalog) }
        catch { file delete [ file join $::audace(rep_images) t1.fit ] }
        catch { file delete [ file join $::audace(rep_images) t2.fit ] }
        catch { file delete [ file join $::audace(rep_images) u1.fit ] }
        catch { file delete [ file join $::audace(rep_images) u2.fit ] }
    }

    ##
    # @brief Conversion de degres sexagesimaux en degres decimaux
    # @param[in] dms : valeur en degres sexagesimaux a convertir
    # @return valeur en degres decimaux
    proc DmsDd {dms} {

        Message debug "%s\n" [info level [info level]]

        set d [ expr double( [ lindex $dms 0 ] ) ]
        set m [ expr double( [ lindex $dms 1 ] ) ]
        set s [ expr double( [ lindex $dms 2 ] ) ]
        return [ expr ( $d + $m/60.0 + $s/3600 ) ]
    }

    ##
    # @brief Elimination d'une image
    # @param[in] image : image à marquer invalide
    # @return
    proc EliminationImage { image } {
        variable data_image
        variable data_script
        variable calaphot

        Message debug "%s\n" [ info level [ info level ] ]

        set data_image($image,valide) "N"
        Message probleme "%04d " $image
        if { [ info exists data_script($image,invalidation) ] } {
            Message info "%s\ " $data_script($image,invalidation)
        }
        Message probleme "%s\n" $calaphot(texte,image_rejetee)
    }

    ##
    # @brief Fermeture de fichier
    # @details L'interet de ce code est de pouvoir tracer le nombre de fichier ouverts à un moment donné. Cela sert à détecter les "fuites de fileid", c'est-a-dire les fichiers qui sont ouverts et jamais fermes. On peut aussi tracer les fichiers qu'on tente de fermer alors qu'ils n'ont pas été ouverts.
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
    # - Suppression de fenêtres restantes.
    # - Initialisation de divers compteurs d'objets
    # .
    # @return
    # @todo Voir si cette routine ne peut être refondue dans InitialisationStatique
    proc Initialisations { data_image data_script } {

        upvar 1 data_script _data_script
        upvar 1 data_image _data_image
        catch { destroy $::audace(base).saisie }
        catch { destroy $::audace(base).selection_etoile }
        catch { destroy $::audace(base).selection_aster }
        catch { destroy $::audace(base).courbe_lumiere }
        catch { destroy $::audace(base).bouton_arret_color_invariant }
        catch { [ file delete trace_calaphot.log ] }

        if { [ array exist _data_script ] } {
            unset _data_script
        }
        if { [ array exist _data_image ] } {
            unset _data_image
        }
        set _data_script(nombre_variable) 0
        set _data_script(nombre_reference) 0
        set _data_script(nombre_indes) 0

        set _data_script(nombre_fichier_ouvert) 0
    }

    ##
    # @brief Calcule le jour julien de la date d'exposition d'une image affichée par AudACE
    #
    # @details La date d'exposition d'une image est definie comme étant l'instant du milieu de la pose
    #
    # Cette procedure récupère le jour julien de l'image active.
    # Elle marche pour les images des logiciels suivants:
    # - CCDSoft v5, Audela et Maxim-DL:
    #   - DATE-OBS = la date uniquement,
    #   - TIME-OBS = l'heure de debut en TU,
    #   - EXPOSURE = le temps d'exposition en secondes
    #   .
    # - PRISM v4  :
    #   - DATE-OBS = date & heure de début de pose (formt Y2K: 'aaaa-mm-jjThh:mm:ss.sss')
    #   - UT-START & UT-END sont valides mais non utilisés
    #   - EXPOSURE = le temps d'exposition en minutes !
    #   .
    # .
    # @return la date exprimée en jour julien
    proc JourJulienImage {} {
        global audace

        Message debug "%s\n" [info level [info level]]

        # Recherche du mot cle DATE-OBS dans l'en-tete FITS
        set date [ lindex [ buf$audace(bufNo) getkwd DATE-OBS ] 1 ]
        # Si la date n'est pas au format Y2K (date+heure)...
        if { ([ string range $date 10 10 ] != "T") \
            || ([ string range $date 4 4 ] != "-") \
            || ([ string range $date 7 7 ] != "-") } {
            # Recherche mot cle TIME-OBS
            set time [ lindex [ buf$audace(bufNo) getkwd TIME-OBS ] 1 ]
            if {[string length $time] != 0} {
                # ...convertit en format Y2K!
                set date [string range $date 0 9]
                set time [string range $time 0 7]
                append date "T"
                append date $time
            } else {
                set time [buf$audace(bufNo) getkwd UT-START]
                set time [lindex $time 1]
                if {[string length $time] != 0} {
                    # ...convertit en format Y2K!
                    set date [string range $date 0 9]
                    set time [string range $time 0 7]
                    append date "T"
                    append date $time
                } else {
                    Message erreur "Pas d'heure"
                    set date "0000-00-00T00:00:00"
                }
            }
        } else {
            set date [string range $date 0 22]
        }

        Message debug "Date=%s\n" $date
        # Conversion en jour julien (Julian Day)
        set jd_instant [mc_date2jd $date]
        return $jd_instant
    }

    ##
    # @brief Sortie de valeur sur la console et le fichier de log
    # @details @see @ref Console
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatté à afficher
    # @return
    proc Message { niveau_info args } {
        global audace
        variable parametres
        variable calaphot

        set param [ eval [ concat { format } $args ] ]
        if { $niveau_info == "debug" } {
            set niveau_pile [ info level ]
            incr niveau_pile -1
            if { $niveau_pile >= 0 } {
                set procedure [ lindex [ info level $niveau_pile ] 0 ]
            } else {
                set procedure ""
            }
            Console $niveau_info "$procedure :: $param"
            TraceFichier ${parametres(sortie)}.txt $niveau_info "$procedure :: $param"
        } else {
            Console $niveau_info $param
            TraceFichier ${parametres(sortie)}.txt $niveau_info $param
        }
    }

    ##
    # @brief Mesure du décalage (x,y) entre 2 images par recalage entre elles
    # @details Si cette valeur a été mesurée auparavant dans une session précédente de Calaphot
    # cette valeur sera extraite du fichier de décalage
    # Sinon le décalage est effectué par recalage (register) de l'image par rapport à une image t1.fit
    # La valeur du recalage est stockée dans l'entete FITS de l'image.
    # On mesure la qualité du recalage par le nombre d'objets ayant servi au recalage.
    # @param[in] i : numero de l'image dans la séquence
    # @retval data_image($i,decalage_x) : decalage en x
    # @retval data_image($i,decalage_y) : decalage en y
    # @return 0 si recalage correct, -1 sinon.
    proc MesureDecalage { i } {
        variable parametres
        variable liste_decalage
        variable data_image
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        set retour 0
        # Détermination du décalage des images par rapport à la première
        if { $parametres(type_images) == "non_recalees" } {
            # Images non recalees
            if [ info exist liste_decalage($i) ] {
                # Cette valeur existe dans le fichier .lst
                Message debug "Décalage déjà calcule\n"
                set data_image($i,decalage_x) [ lindex $liste_decalage($i) 0 ]
                set data_image($i,decalage_y) [ lindex $liste_decalage($i) 1 ]
            } else {
                # Recalage des images par rapport à la première image pour connaître le décalage en coordonnées
                Message debug "Décalage en cours de calcul\n"
                loadima $parametres(source)$i
                saveima t2
#                register2 t u 2
                register t u 2
                loadima u2
                set dec [ DecalageImage $i ]
                set data_image($i,decalage_x) [ lindex $dec 0 ]
                set data_image($i,decalage_y) [ lindex $dec 1 ]

                # Le nombre d'objets ayant servi au recalage doit être pifométrique supérieur au tiers du nombre initial
                Message debug "image %d : %d objets pour recaler \n" $i [ lindex $dec 2 ]
                set objets [ lindex $dec 2 ]
                if { $objets < [ expr $data_script(nombre_objets_recales) / 3 ] } {
                    set retour -1
                    set data_script($i,invalidation) "Seulement $objets objets pour recaler"
                }

                # Rétablissement de l'image sur laquelle seront faites les mesures
                loadima $parametres(source)$i
            }
        } else {
            # Les images sont déjà recalées, pas de décalage entre elles
            Message debug "Les images sont toutes recalées\n"
            set data_image($i,decalage_x) 0.0
            set data_image($i,decalage_y) 0.0
        }
        Message debug "image %d: decalage_x=%10.4f decalage_y=%10.4f\n" $i $data_image($i,decalage_x) $data_image($i,decalage_y)
        return $retour
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
    # @brief Recalage des première et dernière image (si nécessaire)
    # @details Extraction du nombre d'objets utilisés au recalage pour pouvoir qualifier le recalage des autres images
    # @param le nom des images à recaler (ou pas)
    # @retval le nom des images recalées (ou pas)
    proc RecalageInitial { t } {
        variable parametres
        variable data_script

        Message debug "%s\n" [ info level [ info level ] ]

        # Création des images t1 et t2, copies de la première et de la dernière image
        buf$::audace(bufNo) load [ file join $::audace(rep_images) $parametres(source)$data_script(premier_liste) ]
        buf$::audace(bufNo) save [ file join $::audace(rep_images) t1 ]
        buf$::audace(bufNo) load [ file join $::audace(rep_images) $parametres(source)$data_script(dernier_liste) ]
        buf$::audace(bufNo) save [ file join $::audace(rep_images) t2 ]

        if { $parametres(type_images) == "non_recalees" } {
            # Recalage de la première et de la dernière image en u1 et u2
            register2 t u 2
            buf$::audace(bufNo) load [ file join $::audace(rep_images) u2 ]
            set param_decalage [ DecalageImage u2 ]
            set data_script(nombre_objets_recales) [ lindex $param_decalage 2 ]
            Message debug "param_dec=%s\n" $param_decalage
            Message debug "%d objets utilisés au recalage \n" $data_script(nombre_objets_recales)
            return u
        } else {
            return t
        }
    }

    ##
    # @brief Lecture conditionnelle du fichier .lst qui,s'il existe, contient les décalages entre images calculés lors d'une session précédente de Calaphot
    # @return
    proc RecuperationDecalages {} {
        global audace
        variable parametres
        variable liste_decalage

        Message debug "%s\n" [ info level [ info level ] ]

        catch { unset liste_decalage }

        # On détecte des changements dans certains paramètres saisis.
        set changement 0
        foreach champ [ list \
            source \
            indice_premier \
            tri_images \
            type_images \
            pose_minute \
            date_images \
        ] {
            if { $parametres(origine,$champ) != $parametres($champ) } { set changement 1 }
        }

        # S'il y a eu un changement, on efface le fichier .lst
        if { $changement } {
            catch { [ file delete [ file join $::audace(rep_images) $parametres(source).lst ] ] }
            return
        }

        set fichier [ OuvertureFichier [ file join $::audace(rep_images) $parametres(source).lst ] r "non" ]
        if { $fichier != "" } {
            while { [ gets $fichier line ] >= 0 } {
                set image [ lindex $line 0 ]
                set dec_x [ lindex $line 1 ]
                set dec_y [ lindex $line 2 ]
                set liste_decalage($image) [ list $dec_x $dec_y ]
                Message debug "image %d: dec_x=%10.4f dec_y=%10.4f\n" $image $dec_x $dec_y
            }
            FermetureFichier $fichier
        }
    }

    #*************************************************************************#
    #*************  RecuperationParametres  **********************************#
    #*************************************************************************#
    ##
    # @brief Lecture des paramètres stockés dans calaphot.ini et initialisations
    # @details Si certains paramètres n'existent pas dans ce fichier, ou si ce fichier n'existe pas lui-même,
    # ou encore si on a changé de version de Calaphot,
    # les paramètres sont initialisés avec des valeurs par défaut (cf Calaphot::InitialisationStatique )
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
        if { [ info exists parametres ] } { unset parametres }

        # Ouverture du fichier de paramètres
        set fichier $calaphot(nom_fichier_ini)

        if {[file exists $fichier]} {
            source $fichier
            # Vérification de la version du calaphot.ini et invalidation éventuelle du contenu
            if { ( (![ info exists parametres(version_ini) ] ) \
                || ( [ string compare $parametres(version_ini) $calaphot(init,version_ini) ] != 0 ) ) } {
                set parametres(niveau_message) $calaphot(init,niveau_message)
                # Il n'est pas possible d'utiliser Message à cause de $parametres qui n'existe plus
                ::console::affiche_erreur $calaphot(texte,detection_ini)
                foreach { a b } [ array get parametres ] { unset parametres($a) }
            }
        }

        foreach choix { mode \
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
            defocalisation \
            version_ini } {
            if { ![ info exists parametres($choix) ] } {
                set parametres($choix) $calaphot(init,$choix)
            }
        }

        # parametres(origine,xxx) va contenir la même chose que parametres(xxx).
        # Le but est de détecter des changements dans les paramètres pour éviter d'utiliser un mauvais fichier .lst de décalage par exemple
        foreach { a b } [ array get parametres ] {
            set parametres(origine,$a) $b
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
            if {[expr double([string range $version_lib 0 2])] < 4.0} {
                Message console "%s\n" $calaphot(texte,mauvaise_version)
                return 1
            }
        }
        return 0
    }

    ##
    # @brief Sauvegarde dans un fichier des décalages entre images
    # @details Le but de ceci est d'accélérer les traitements lors d'un session Calaphot qui porterait sur les mêmes images
    # Le nom du fichier dépend du répertoire d'images et du nom générique des images
    # @return
    proc SauvegardeDecalages {} {
        global audace
        variable parametres
        variable data_image
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        if {$parametres(type_images) == "non_recalees"} {
            # On ne sauvegarde les décalages que si les images ne sont pas recalées à la base

            set fichier [ OuvertureFichier [ file join $::audace(rep_images) $parametres(source).lst ] w ]
            if { ( $fichier != "" ) } {
                foreach image $liste_image {
                    if { ( [ info exists data_image($image,decalage_x) ] ) && ( [ info exists data_image($image,decalage_x) ] ) } {
                        puts $fichier "$image $data_image($image,decalage_x) $data_image($image,decalage_y)"
                        Message debug "image %d: dec_x=%10.4f dec_y=%10.4f\n" $image $data_image($image,decalage_x) $data_image($image,decalage_y)
                    }
                }
            }
            FermetureFichier $fichier
        }
    }

    ##
    # @brief Sauvegarde dans un fichier des paramètres de la session courante
    # @details Ces paramètres ont été lus dans le fichier calaphot.ini, et éventuellement
    # modifiés dans l'écran de saisie
    # @return
    proc SauvegardeParametres {} {
        global audace
        variable parametres
        variable data_script
        variable coord_aster
        variable pos_theo
        variable calaphot

        Message debug "%s\n" [info level [info level]]

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
    # @brief Ecrit des messages dans un fichier de log
    # @details @see @ref Console
    # @param[in] niveau_info : le niveau d'affichage
    # @param[in] args : le message formatte a afficher
    # @return
    proc TraceFichier { fichier niveau_info args } {
        global audace
        variable calaphot
        variable parametres

        if { ( $calaphot(niveau_notice) <= $calaphot(niveau_$niveau_info) ) } {
            set fid [ open [ file join $::audace(rep_log) $fichier ] a ]
            puts -nonewline $fid [ eval [ concat { format } $args ] ]
            close $fid
        }
    }

    ##
    # @brief Tri des images par dates croissantes, et éliminant les doublons
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
            catch { file delete [ file join $::audace(rep_images) $parametres(source).lst ] }
        } else {
            # Images triées : la liste va juste reprendre les indices des images
            for { set i $parametres(indice_premier) } { $i <= $parametres(indice_dernier) } { incr i 1 } {
                lappend liste_image_triee $i
            }
        }
        set data_script(premier_liste) [ lindex $liste_image_triee 0 ]
        set data_script(dernier_liste) [ lindex $liste_image_triee end ]
        return $liste_image_triee
    }

    ##
    # @brief Vérification que tous les fichiers images de la séquence existent effectivement
    # @return
    proc Verification {} {
        global audace conf
        variable parametres
        variable calaphot

        Message debug "%s\n" [info level [info level]]

        # Vérification des indices
        if {$parametres(indice_premier) >= $parametres(indice_dernier)} {
            Message erreur "%s\n" $calaphot(texte,err_indice)
            EffaceMotif astres
            return (1)
        }

        # Vérification de ce que les images existent
        Message info $calaphot(texte,verification) $parametres(source) $parametres(indice_premier) $parametres(indice_dernier) "\n"
        for {set image $parametres(indice_premier)} {$image <= $parametres(indice_dernier)} {incr image} {
            set nom_fichier [file join $::audace(rep_images) $parametres(source)$image$conf(extension,defaut)]
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
    # @brief Réglage des seuils de visualisation d'une image dans AudACE
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


