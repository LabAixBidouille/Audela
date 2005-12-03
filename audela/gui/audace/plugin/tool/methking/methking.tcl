#
# Fichier : methking.tcl
# Description : panneau d'aide à la mise en station par la méthode de King.
# Auteurs : François Cochard et Jacques Michelet
# Date de mise a jour : 15 novembre 2005
#

package provide methking 1.14

namespace eval ::MethKing {
    global audace
    source [ file join $audace(rep_plugin) tool methking methking.cap ]

    variable This
    variable liste_motcle
    variable king_config
    variable fichier_log
    variable omega
    variable numero_version

    # Numéro de la version du logiciel
    set numero_version v1.14

    # Vitesse de rotation de la Terre (2*pi/86164.0905 rd/s)
    set omega 7.2921159e-5

    # Mots-clés et valeurs pour le fichier de configuration
    set liste_motcle [list config tempspose interpose binning poseparseq textex+ textex- textey+ textey- configdefaut focale pixel_x pixel_y nomking noir son test]
    set liste_valeur_defaut [list config 5 60 2 3 X+ X- X+ X- 0 0 0 0 king_ 0 0 0]
    set liste_valeur_max [list null 30 1200 2 15 null null null null 15 null null null null 1 60 20]
    set liste_valeur_min [list null 1 100 1 1 null null null null 0 null null null null 0 0 0]
    set liste_valeur_type [list 0 1 1 1 1 0 0 0 0 1 1 2 2 0 1 1 1] ; #vaut 1 si c'est une valeur entiere, 2 si c'est une valeur flottante

#-------------Partie Confking.tcl

    proc GetConfig {fichier tableau} {
    global caption
    global panneau
    global audace

    # passage de l'adresse du tableau de config
    upvar $tableau tableauConfig

    # Ouverture du fichier de config
    if ![file exists $fichier] {
        Message erreur "%s %s %s\n" $caption(king,fichier) $fichier $caption(king,non_existence)
        return
    }
    set file_id [open $fichier r]

    # Lecture des lignes et traitements
    set numero_ligne 1
    set numero_config -1

    while {[gets $file_id ligne] >= 0} {
        set motcle ""
        set valeur ""

        #    Message test "Ligne %02d : %s\n" $numero_ligne $ligne
        # Repérage des différents champs dans la ligne
        set resultat [BalayageLigne $ligne]
        if {$resultat == -1} {
        Message erreur "%s %02d : %s\n" $caption(king,ligne) $numero_ligne $caption(king,ecr_mot_cle)
        #    } elseif {$resultat == -2} {      ;# Cas de la ligne vide
        #        Message log "Ligne %02d OK : ligne de commentaires\n" $numero_ligne
        } elseif {$resultat == -3} {
        Message erreur "%s %02d : %s\n" $caption(king,ligne) $numero_ligne $caption(king,pas_valeur)
        } else { ;# Cas 'normal'

        # Verification de la syntaxe des commandes
        set resultat [FiltrageLigne]

        # Cas d'erreurs ou la ligne ne sera pas traitee
        if {$resultat == -1} {
            Message erreur "%s %02d : %s\n" $caption(king,ligne) $numero_ligne caption(king,mot_cle_invalide)
        } elseif {$resultat == -2} {
            Message erreur "%s %02d : %s\n" $caption(king,ligne) $numero_ligne $caption(king,valeur_non_entiere)
        } else { ;# Cas 'normal' ou la ligne sera effectivement traitee
            if {$resultat == -3} {
            # Ce n'est qu'un warning
            Message avertissement "%s %02d : %s %d\n" $caption(king,ligne) $numero_ligne $caption(king,recalage_min) $valeur
            } elseif {$resultat == -4} {  ;# Ce n'est qu'un warning
            Message avertissement "%s %02d : %s %d\n" $caption(king,ligne) $numero_ligne $caption(king,recalage_max) $valeur
            }
                    # Le mot clé et sa valeur associée sont déclarés corrects
                    # Recherche du mot clé 'Config'
                    switch -exact -- $motcle {
                        config {
                            incr numero_config
                            set tableauConfig($motcle,$numero_config) $valeur
                        }
                        configdefaut {set panneau(meth_king,config_defaut) $valeur}
                        nomking {set panneau(meth_king,nom_image_temp) $valeur}
                        default {
                            # Tant que le premier mot clé [Config] n'a pas été trouvé rien ne se passe
                            if {$numero_config >= 0} {
                                # Enfin ! On attribue la valeur au mot clé de la config
                                set tableauConfig($motcle,$numero_config) $valeur
                            }
                        }
                    }
                }
        }
        incr numero_ligne
        #    Message test "\n"
    }
    set panneau(meth_king,nombre_config) [expr $numero_config + 1]
    close $file_id

    # Vérification
    Message log "%s\n" $caption(king,recap_config)
    for {set i 0} {$i < $panneau(meth_king,nombre_config)} {incr i} {
        for {set j 0} {$j < [llength $::MethKing::liste_motcle]} {incr j} {
        set cle [lindex $::MethKing::liste_motcle $j]
        Message log "%s : %02d | %s : %s / %s : %s\n" $caption(king,config) $i $caption(king,mot_cle) $cle $caption(king,valeur) $tableauConfig($cle,$i)
        #        Message console "Config : %02d | Mot cle : %s / Valeur : %s\n" $i $cle $tableauConfig($cle,$i)
        }
        Message log "---------------------------------------------------------\n"
    }

    }

    proc FiltrageLigne {} {
        upvar motcle motcle
        upvar valeur valeur

        #    Message test "Motcle = %s  Valeur = %s\n" $motcle $valeur

        # Recherche si le mot clé est défini dans la liste
        set indice [lsearch $::MethKing::liste_motcle $motcle]
        if {$indice<0} {
            return -1
        }

        # Si la valeur n'est pas un entier, les tests sont finis.
        if {[lindex $::MethKing::liste_valeur_type $indice]==0} {
            return 0
        }

        if {[lindex $::MethKing::liste_valeur_type $indice]==1} {
            # Détection des valeurs entières
            if {![TestEntier $valeur]} {
                return -2
            }
        }

        if {[lindex $::MethKing::liste_valeur_type $indice]==2} {
            # Détection des valeurs flottantes
            if {![string is double $valeur]} {
                return -2
            }
        }

        # Recalage de la valeur min
        if {[lindex $::MethKing::liste_valeur_min $indice] != "null"} {
            if {$valeur < [lindex $::MethKing::liste_valeur_min $indice]} {
                set valeur [lindex $::MethKing::liste_valeur_min $indice]
                return -3
            }
        }
        # Recalage de la valeur max
        if {[lindex $::MethKing::liste_valeur_max $indice] != "null"} {
            if {$valeur > [lindex $::MethKing::liste_valeur_max $indice]} {
                set valeur [lindex $::MethKing::liste_valeur_max $indice]
                return -4
            }
        }
    }


    proc BalayageLigne {ligne} {
    # Passage des parametres de retour (motcle et valeur)
    upvar motcle motcle
    upvar valeur valeur

    # Isolation de la partie de la chaine situee a gauche du premier #
    set premier_dieze [string first \# $ligne]
    if {$premier_dieze != -1} {
        set ligne [string range $ligne 0 [expr $premier_dieze-1]]
    }

    # Nettoyage des characteres <espace> en trop
    set ligne [string trim $ligne]

    # Cas de la ligne constituee uniquement de commentaires (sans mot cle)
    if {[string length $ligne] == 0} {
        return -2
    }

    # Isolation du mot cle
    set cg [string first \[ $ligne]
    set cd [string first \] $ligne]
    # Erreurs de syntaxe
    if {($cg<0 && $cd>=0) || ($cg>=0 && $cd<0)} {
        return -1
    }
    set motcle [string tolower [string range $ligne [expr $cg+1] [expr $cd-1]]]

    # Isolation de la valeur associée, et nettoyage des caractères <espace> résiduels
    set valeur [string trim [string range $ligne [expr $cd+1] end]]
    if {[string length $valeur] == 0} {
        return -3
    }
    return 0
    }

    proc TestEntier {valeur} {
        set test 1
        for {set i 0} {$i < [string length $valeur]} {incr i} {
            set a [string index $valeur $i]
            if {![string match {[0-9]} $a]} {
            set test 0
            }
        }
        return $test
    }

    proc TestEntierSigne {valeur} {
        set test 1
        # Cas du premier caractère
        set a [string index $valeur 0]
        if {![string match {[0-9-+]} $a]} {
            set test 0
        }
        # Cas des caractères restants
        if {[string length $valeur] > 1} {
            for {set i 1} {$i < [string length $valeur]} {incr i} {
                set a [string index $valeur $i]
                if {![string match {[0-9]} $a]} {
                    set test 0
                }
            }
        }
        return $test
    }

#-------------Partie Scriking.tcl
    #----- Procedure KingPreparation ------------------------------------------------------
    # La procedure KingPreparation est appelee par KingTraitement.
    # (voir fichier methking.tcl)
    # Cette procedure a pour but de retourner les composantes du deplacement a effectuer sur
    # la monture (calcul de King proprement dit).
    proc KingPreparation {} {
        variable king_config
        global panneau audace caption color

        # Lance le fichier fichiertest.tcl si le parametre Test est valide dans la config active
        # (Test est un parametre du fichier methking.ini)
        if {$king_config(test,$panneau(meth_king,config_active)) != 0} {
            if {[file exists [file join $audace(rep_plugin) tool methking fichiertest.tcl]] == 1} {
                source [file join $audace(rep_audela) tool methking fichiertest.tcl]
            } else {
                tk_messageBox -title "Problème" -type ok \
                -message "Le fichier de test\n[ file join audace plugin tool methking fichiertest.tcl ]\nest introuvable."
            }
        }

        # Initialisation des variables
        set panneau(meth_king,nbboites) 0
        set nom $panneau(meth_king,nom_image)
        set nom_reg ${nom}reg
        set nb_im_par_seq $panneau(meth_king,nb_im_par_seq)
        set nb_images [expr $nb_im_par_seq * 2]

        # Etape 1: Registration de toutes les images.
        Message consolog $caption(king,etape_1)
        Message status $caption(king,status_reg)

        register [file tail $nom] [file tail $nom_reg] $nb_images
        Message consolog $caption(king,fin_etape_1)

        # Etape 2: Recherche du décalage entre premiere et derniere image.
        Message consolog $caption(king,etape_2)
        loadima $nom_reg$nb_images
        ::audace::autovisu visu$audace(visuNo)
        set dec [decalage]
        set dec_max_x [lindex $dec 0]
        set dec_max_x [expr int($dec_max_x)]
        set dec_max_y [lindex $dec 1]
        set dec_max_y [expr int($dec_max_y)]
        # ----- Recherche de la taille de l'image.
        set taille_image_x [lindex [buf$audace(bufNo) getkwd NAXIS1] 1 ]
        set taille_image_x [expr int($taille_image_x)]
        set taille_image_y [lindex [buf$audace(bufNo) getkwd NAXIS2] 1 ]
        set taille_image_y [expr int($taille_image_y)]
        # ----- Définition de la zone dans laquelle sélectionner les étoiles
        if {$dec_max_x >= 0} {
            set cadre_x1 10
            set cadre_x2 [expr $taille_image_x - 10 - $dec_max_x]
        } else {
            set cadre_x1 [expr 10 - $dec_max_x]
            set cadre_x2 [expr $taille_image_x - 10]
        }
        if {$dec_max_y >= 0} {
            set cadre_y1 10
            set cadre_y2 [expr $taille_image_y - 10 - $dec_max_y]
        } else {
            set cadre_y1 [expr 10 - $dec_max_y]
            set cadre_y2 [expr $taille_image_y - 10]
        }
        # Je mémorise le cadre dans panneau, pour pouvoir vérifier plus tard que les étoiles
        # sélectionnées sont bien dans ce cadre.
        set panneau(meth_king,cadre_x1) $cadre_x1
        set panneau(meth_king,cadre_y1) $cadre_y1
        set panneau(meth_king,cadre_x2) $cadre_x2
        set panneau(meth_king,cadre_y2) $cadre_y2
        Message consolog $caption(king,cadre) $cadre_x1 $cadre_y1 $cadre_x2 $cadre_y2
        Message consolog $caption(king,fin_etape_2)

        # Etape 3: Chargement de la première image de la série.
        Message consolog $caption(king,etape_3)
        Message status $caption(king,status_selection)
        append nom 1
        loadima $nom
        ::audace::autovisu visu$audace(visuNo)
        
	# Affichage du cadre delimitant la zone acceptable pour la selection d'etoiles
        DessineRectangle [list $cadre_x1 $cadre_y1 $cadre_x2 $cadre_y2] $color(green)
        Message consolog $caption(king,fin_etape_3) $nom
    }
    #----- Fin dela procedure KingPreparation ----------------------------

    #----- Procedure SelectionneEtoiles ---------------------------------
    proc SelectionneEtoiles {} {
        global audace panneau caption color
        if [info exists audace(box)] {
            # Je récupere les coordonnées de la boite de selection
            set rect $audace(box)
            set x1 [lindex $rect 0]
            set y1 [lindex $rect 1]
            set x2 [lindex $rect 2]
            set y2 [lindex $rect 3]
        }
        if [info exists audace(clickxy)] {
            set x1 [expr [lindex $audace(clickxy) 0] - 7]
            set x2 [expr [lindex $audace(clickxy) 0] + 7]
            set y1 [expr [lindex $audace(clickxy) 1] - 7]
            set y2 [expr [lindex $audace(clickxy) 1] + 7]
            set rect [list $x1 $y1 $x2 $y2]
        }
        if {([info exists audace(box)]) || ([info exists audace(clickxy)])} {
        # Je teste si l'étoile sélectionnee est bien dans le cadre
            set hors_cadre 0
            if {$x1 < $panneau(meth_king,cadre_x1)} {set hors_cadre 1}
            if {$x2 < $panneau(meth_king,cadre_x1)} {set hors_cadre 1}
            if {$x1 > $panneau(meth_king,cadre_x2)} {set hors_cadre 1}
            if {$x2 > $panneau(meth_king,cadre_x2)} {set hors_cadre 1}
            if {$y1 < $panneau(meth_king,cadre_y1)} {set hors_cadre 1}
            if {$y2 < $panneau(meth_king,cadre_y1)} {set hors_cadre 1}
            if {$y1 > $panneau(meth_king,cadre_y2)} {set hors_cadre 1}
            if {$y2 > $panneau(meth_king,cadre_y2)} {set hors_cadre 1}
            if {$hors_cadre == 1} {
                tk_messageBox -message $caption(king,hors_cadre) -icon error -title $caption(king,pb)
            } else {
                incr panneau(meth_king,nbboites)
                set i $panneau(meth_king,nbboites)
#        set panneau(meth_king,boite$i) $audace(box)
                set panneau(meth_king,boite$i) $rect
            # Je teste la validite de l'etoile...
                set valide [Centroide $x1 $y1 $x2 $y2]
                set code_erreur [lindex $valide 2]
                if {$code_erreur == 1} {
                    # Recentrage du rectangle
                    set xy [buf$audace(bufNo) centro $rect]
                    set x1 [expr round([lindex $xy 0] - 7)]
                    set y1 [expr round([lindex $xy 1] - 7)]
                    set x2 [expr round([lindex $xy 0] + 7)]
                    set y2 [expr round([lindex $xy 1] + 7)]
                    # Tracé du rectangle
                    DessineRectangle [list $x1 $y1 $x2 $y2] $color(yellow)
                    Message consolog $caption(king,etoile) $i [lindex $valide 0] [lindex $valide 1]
                } else {
                    set err(-1) $caption(king,sb_insuffisant)
                    set err(-2) $caption(king,et_non_isolee)
                    set err(-3) $caption(king,pixel_chaud)
                    tk_messageBox -message "$caption(king,et_non_valide)\n$err($code_erreur)" \
                    -icon error -title caption(king,pb)
                    incr panneau(meth_king,nbboites) -1
                }
            }
        }
    }
    #----- Fin dela procedure SelectionneEtoiles ------------------------

    #----- Procedure KingProcess ----------------------------------------
    proc KingProcess {} {
    global audace panneau caption conf
    # Pour ameliorer la lisibilite...
    set nom $panneau(meth_king,nom_image)
    set nom_reg ${nom}reg
    set nb_im_par_seq $panneau(meth_king,nb_im_par_seq)
    set nb_images [expr $nb_im_par_seq * 2]
    set nb_etoiles $panneau(meth_king,nbboites)
    buf$audace(bufNo) extension "$conf(extension,defaut)"
    set ext_fichier [buf$audace(bufNo) extension]

    if {$nb_etoiles == 0} {
        tk_messageBox -message $caption(king,pas_selectionne) \
            -icon error -title caption(king,pb)
        # Interruption du calcul !
        return
    } else {
        # J'efface les differents cadres (reperes par le tag "cadres")
        $audace(hCanvas) delete cadres

        Message consolog $caption(king,et_selectionnees) $nb_etoiles
        Message consolog $caption(king,fin_etape_4)

        # Etape 5: Epluchage de chaque image
        Message consolog $caption(king,etape_5) $nb_images
        Message status $caption(king,status_analyse)
        for {set image 1} {$image <= $nb_images} {incr image} {
        # Je charge l'image registree
        loadima $nom_reg$image
        ::audace::autovisu visu$audace(visuNo)
        Message consolog $caption(king,image_no) $image

        # Lecture dans l'entete fi..chuut du decalage de l'image...
        set dec [decalage]
        set dec_im_x [lindex $dec 0]
        set dec_im_y [lindex $dec 1]
        Message consolog $caption(king,decalage) $dec_im_x $dec_im_y

        # J'efface du disque l'image registrée, qui ne sert plus à rien.
        set a_effacer $nom_reg$image
        append a_effacer $ext_fichier
        file delete $a_effacer

        # Je charge l'image d'origine (Pas celle registree)
        loadima $nom$image

        # Extraction des date et heure de l'image
        set quand [DateHeureImage]
        set mesure(im_$image,date) $quand
        Message consolog $caption(king,jj) $quand [mc_date2ymdhms $quand]

        # Pour chaque etoile selectionnee:
        for {set etoile 1} {$etoile <= $nb_etoiles} {incr etoile} {
            set uneetoile $panneau(meth_king,boite$etoile)
            # J'applique le decalage de l'image sur chaque boite, pour encadrer l'etoile:
            set x1 [expr int([lindex $uneetoile 0] + $dec_im_x)]
            set y1 [expr int([lindex $uneetoile 1] + $dec_im_y)]
            set x2 [expr int([lindex $uneetoile 2] + $dec_im_x)]
            set y2 [expr int([lindex $uneetoile 3] + $dec_im_y)]
            # Calcul du centroide de l'etoile:
            set centre [Centroide $x1 $y1 $x2 $y2]
            set mesure(im_$image,et$etoile,centre_x) [lindex $centre 0]
            set mesure(im_$image,et$etoile,centre_y) [lindex $centre 1]
            set mesure(im_$image,et$etoile,code_erreur) [lindex $centre 2]
            Message consolog $caption(king,centre_etoile) $etoile [lindex $centre 0] [lindex $centre 1]
            if {[lindex $centre 2] != 1} {
            Message consolog $caption(king,non_val,[lindex $centre 2])
            }
        }
        }
        Message consolog $caption(king,fin_etape_5)

        # Etape 6: Pour chaque couple d'images...
        # J'initialise les variables contenant les corrections a apporter sur la monture
        # A la fin de la routine, je pourrai ainsi en faire la moyenne.
        set corr_king_x 0.0
        set corr_king_y 0.0
        set corr2_king_x 0.0
        set corr2_king_y 0.0
        # J'initialise le nombre de couple d'images valides
        set nb_couple_valide_par_seq $nb_im_par_seq
        # Pour chaque couple d'image, donc...
        Message consolog $caption(king,etape_6) $nb_im_par_seq
        Message status $caption(king,status_couple)
        for {set i 1} {$i <= $nb_im_par_seq} {incr i} {
        # k est l'indice de la ieme image dans la seconde sequence
        set k [expr $i + $nb_im_par_seq]
        # J'initialise les variables contenant le decalage de chaque etoile.
        # A la fin de la boucle, je pourrai ainsi en faire la moyenne.
        set dec_x 0.0
        set dec_y 0.0
        # J'initialise le compteur d'etoiles valides
        set nb_etoiles_valides $nb_etoiles
        # Pour chaque etoile, donc...
        for {set j 1} {$j <= $nb_etoiles} {incr j} {
            if {$mesure(im_$i,et$j,code_erreur) == 1 && $mesure(im_$k,et$j,code_erreur) == 1} {
            # Dans le cas ou l'etoile est valide dans les deux images, je calcule le decalage
            set dx [expr $mesure(im_$k,et$j,centre_x) - $mesure(im_$i,et$j,centre_x)]
            set dy [expr $mesure(im_$k,et$j,centre_y) - $mesure(im_$i,et$j,centre_y)]
            # Et je le cumule
            set dec_x [expr $dec_x + $dx]
            set dec_y [expr $dec_y + $dy]
            } else {
            # Dans ce cas, l'etoile est non valide
            incr nb_etoiles_valides -1
            }
        }
        # Je divise par le nb d'etoiles valides pour avoir la moyenne
        if {$nb_etoiles_valides == 0} {
            # Le couple n'est pas valide: Aucune etoile n'est exploitable.
            incr nb_couple_valide_par_seq -1
            Message consolog $caption(king,couple_aucune) $i $k
        } else {
            # Dans le cas ou le couple est valide.
            set mesure(im_$i,dec_x) [expr $dec_x / $nb_etoiles_valides]
            set mesure(im_$i,dec_y) [expr $dec_y / $nb_etoiles_valides]
            Message consolog $caption(king,couple_no) $i $k \
                $mesure(im_$i,dec_x) $mesure(im_$i,dec_y) $nb_etoiles_valides

            # Je calcule le temps écoule entre les deux images
            set dt [expr $mesure(im_$k,date) - $mesure(im_$i,date)]
            # Je convertis cette duree en secondes
            set dt [expr $dt * 86400.0]
            Message consolog $caption(king,tps_entre) $dt

            # Je fais le calcul de King proprement dit (correction a apporter sur la monture)
            set king [KingBase $mesure(im_$i,dec_x) $mesure(im_$i,dec_y) $dt]
            Message consolog $caption(king,correction) [lindex $king 0] [lindex $king 1]

            # Je calcule le temps ecoule entre l'image k (celle en cours de traitement, et
            # appartenant a la seconde sequence) et la derniere image de la sequence.
            set dt [expr $mesure(im_$nb_images,date) - $mesure(im_$k,date)]
            # Je convertis cette duree en secondes
            set dt [expr $dt * 86400.0]

            # Je fais tourner le vecteur "correction a apporter sur la monture" de ce dt
            set king_x [lindex $king 0]
            set king_y [lindex $king 1]
            set king_corrige [KingRattrapage $king_x $king_y $dt ]
            Message consolog $caption(king,correction_der) [lindex $king_corrige 0] [lindex $king_corrige 1]
            # Je cumule ces valeurs
            set corr_king_x [expr $corr_king_x + [lindex $king_corrige 0]]
            set corr_king_y [expr $corr_king_y + [lindex $king_corrige 1]]
            set corr2_king_x [expr $corr2_king_x + ([lindex $king_corrige 0] * [lindex $king_corrige 0])]
            set corr2_king_y [expr $corr2_king_y + ([lindex $king_corrige 1] * [lindex $king_corrige 1])]
        }
        }
        Message consolog $caption(king,fin_etape_6)

        Message consolog $caption(king,etape_7)
        Message status $caption(king,status_calc_king)
        # Dans le cas o aucun couple n'est valide:
        if {$nb_couple_valide_par_seq == 0} {
        tk_messageBox -message $caption(king,aucun_couple_ok) -icon error -title $caption(king,pb)
        Message consolog $caption(king,aucun_couple)
        set panneau(meth_king,status) 211
        } else {
        # Je divise maintenant par le nombre d'images, pour avoir la moyenne:
        set corr_king_x [expr +($corr_king_x / $nb_couple_valide_par_seq)]
        set corr_king_y [expr +($corr_king_y / $nb_couple_valide_par_seq)]

        #Et voila, j'ai mes valeurs de correction a apporter sur la monture:
        Message consolog $caption(king,corr_king) $corr_king_x $corr_king_y

        set corr2_king_x [expr +($corr2_king_x / $nb_couple_valide_par_seq)]
        set corr2_king_y [expr +($corr2_king_y / $nb_couple_valide_par_seq)]
        set sigma2_dx [expr $corr2_king_x - (($corr_king_x) * ($corr_king_x))]
        set sigma2_dy [expr $corr2_king_y - (($corr_king_y) * ($corr_king_y))]
        if {($sigma2_dx >= 0) && ($sigma2_dy >= 0)} {
            set panneau(meth_king,sigma_dx) [expr sqrt($sigma2_dx)]
            set panneau(meth_king,sigma_dy) [expr sqrt($sigma2_dy)]
            Message consolog $caption(king,ecart_type) $panneau(meth_king,sigma_dx) $panneau(meth_king,sigma_dy)
        }

        # Je stocke ces valeurs dans la variable globale "panneau".
        set panneau(meth_king,monture_dx) $corr_king_x
        set panneau(meth_king,monture_dy) $corr_king_y
        Message consolog $caption(king,fin_etape_7)

        # Je valide le tout, en positionnant la variable status à 200 (= calcul termine OK)
        set panneau(meth_king,status) 200
        }
    }
    }
    #----- Procedure KingProcess ----------------------------------------

    #----- Procedure Decalage -------------------------------------------
    # Cette procedure releve le decalage opéré sur l'image en cours
    # par la fonction register
    proc decalage {} {
        global audace

        # --- récupère la liste des mots clé de l'image Fi..chuuut
        set listkey [buf$audace(bufNo) getkwds]
        # --- on évalue chaque (each) mot clé
        foreach key $listkey {
            # --- on extrait les infos de la ligne
            # --- qui correspond au mot clé
            set listligne [buf$audace(bufNo) getkwd $key]
            set value [lindex $listligne 1]
            # --- si la valeur vaut IMA/SERIES REGISTER ...
            if {$value=="IMA/SERIES REGISTER"} {
                # --- alors on extrait l'indice du mot clé TT*
                set keyname [lindex $listligne 0]
                set lenkeyname [string length $keyname]
                set indice [string range $keyname 2 [expr $lenkeyname] ]
            }
        }
        # On a maintenant repéré la fonction TT qui pointe sur la dernière registration.
        # --- on recherche la ligne Fi..chuuuut contenant le mot clé indice+1
        incr indice
        set listligne [buf$audace(bufNo) getkwd "TT$indice"]

        # --- on évalue la valeur de la ligne
        set param1 [lindex $listligne 1]
        set dx [lindex [split $param1] 3]

        # --- on recherche la ligne contenant le mot clé indice+2
        incr indice
        set listligne [buf$audace(bufNo) getkwd "TT$indice"]

        set param2 [lindex $listligne 1]
        set dy [lindex $param2 2]

        # Fin de la lecture du décalage
        return [list $dx $dy]
    }
    #----- Fin dela procedure Decalage ---------------------------------------

    #----- Procedure DateHeureImage -------------------------------------------
    # Cette procedure Recupere la date et l'heure de l'image active.
    proc DateHeureImage {} {
    global audace

    # Je vais chercher la ligne de l'entete f... qui contient la date:
    set date [buf$audace(bufNo) getkwd DATE-OBS]
    # Je recupere le second champ, qui contient la chaine de date et heure:
    set date [lindex $date 1]
    # Je le transforme en jour julien...
    set instant [mc_date2jd $date]
    # Et j'affiche tout ca:
    return $instant
    }
    #----- Fin dela procedure DateHeureImage ----------------------------------

    # -------- Procedure KingBase ---------------------------------------------
    # 7 decembre 2000
    #
    # Cette fonction est le coeur de la methode de King. Elle retourne le
    # deplacement a faire sur la monture, a partir de la mesure du
    # decalages entre deux images prises a un intervalle de temps dt.
    #
    # Arguments:
    # - dx = Decalage en x mesure entre les deux images de reference.
    # - dy = Decalage en y mesure entre les deux images de reference.
    #        Pour dx et dy, l'unite de mesure est le pixel.
    # - dt = Intervalle de temps entre les deux images de reference.
    #
    # La valeur retournee est une liste avec deux elements:
    # - ciblex = correction a apporter en x (en pixels) sur la monture.
    # - cibley = correction a apporter en y (en pixels) sur la monture.
    #
    # Le calcul utilise est le calcul simplifie, sur la base des
    # developpements limites des fonction sin et cos.

    proc KingBase {dx dy dt} {
    # On attribue a omega la vitesse de rotation de la terre (rad/s)
    variable omega
    set angle [expr $omega * $dt]
    set ciblex [expr -($dx / 2) + (sin($angle) * $dy) / (2 * (1 - cos($angle)))]
    set cibley [expr -(sin($angle) * $dx) / (2 * (1 - cos($angle))) - ($dy / 2)]
    return [list $ciblex $cibley]
    }
    # -------- Fin de la procedure KingBase dx dy dt -------------------------

    #--------- Procedure KingRattrapage --------------------------------
    # 11 decembre 2000
    #
    # Cette fonction permet de compenser la correction a
    # apporter a la monture si le reglage est fait sensiblement
    # plus tard que le calcul lui-meme.
    #
    # Arguments:
    # - ciblex = Correction a apporter en x au moment de la seconde image.
    # - cibley = Correction a apporter en y au moment de la seconde image.
    #        Pour ciblex et cibley, l'unite de mesure est le pixel.
    # - dt = Intervalle de temps ecoule depuis la seconde image.
    #
    # La valeur retournee est une liste avec deux elements:
    # - ciblecorrx = nouvelle correction a apporter en x (en pixels).
    # - ciblecorry = nouvelle correction a apporter en y (en pixels).
    #
    proc KingRattrapage {ciblex cibley dt} {
    # On s'assure que les arguments sont des flottants.
    set ciblex double($ciblex)
    set cibley double($cibley)
    set dt double($dt)
    # On attribue a omega la vitesse de rotation de la terre (rad/s)
    variable omega
    # Pour simplifier les expressions, on attribue a angle la valeur omega*dt.
    set angle [expr ($omega * $dt)]
    set ciblecorrx [expr (($ciblex * cos($angle)) + ($cibley * sin($angle)))]
    set ciblecorry [expr (($cibley * cos($angle)) - ($ciblex * sin($angle)))]
    return [list $ciblecorrx $ciblecorry]
    }
    #--------- Fin de la procedure KingRattrapage -----------------------

    #--------- Procedure DessineRectangle -------------------------------
    proc DessineRectangle {rect couleur} {
    global audace

    # Recupère les 4 coordonnées du rectangle
    set x1 [lindex $rect 0]
    set y1 [lindex $rect 1]
    set x2 [lindex $rect 2]
    set y2 [lindex $rect 3]

    set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
    # Creation du cadre. Le tag "cadres" permettra par la suite de l'effacer facilement.
    $audace(hCanvas) create rectangle [expr $x1-1] [expr $naxis2-$y1] \
        [expr $x2-1] [expr $naxis2-$y2] -outline $couleur -tags cadres
    # Rafraichissement de l'image
    ::audace::autovisu visu$audace(visuNo)
    }
    #--------- Fin de la procedure DessineRectangle ---------------------

    #--------- Procedure Centroide -----------------------------------------
    proc Centroide {x1 y1 x2 y2} {
    global audace

    # La fonction retourne les coordonnées du centre, et un code d'erreur
    # Le code d'erreur peut prendre les valeurs suivantes:
    #  > 1 si le resultat est valide.
    #  > -1 si le rapport signal / bruit est insuffisant
    #  > -2 si l'etoile est trop etalee (non isolable dans un carre de 21*21 pixels)
    #  > -3 si l'etoile est ponctuelle (pixel chaud, cosmique)
    #
    # Definition du seuil de detection:
    set seuil 5.0

    # Recuperation le niveau de fond et le bruit de fond de l'image...
    set stat_image [stat]
    set fond [lindex $stat_image 6]
    set bruit_fond [lindex $stat_image 7]
    # Inverse les cood. en x si elles ne sont pas dans le bon ordre
    if {$x1 > $x2} {
        set echange $x1
        set x1 $x2
        set x2 $echange
    }
    # Inverse les cood. en y si elles ne sont pas dans le bon ordre
    if {$y1 > $y2} {
        set echange $y1
        set y1 $y2
        set y2 $echange
    }
    # Repere quel est le pixel le plus brillant
    set pixel_max 0
    set pixel_max_x 0
    set pixel_max_y 0
    for {set hor $x1} {$hor <= $x2} {incr hor} {
        for {set ver $y1} {$ver <= $y2} {incr ver} {
        set pixel_courant [buf$audace(bufNo) getpix [list $hor $ver]]
        if {$pixel_courant > $pixel_max} {
            set pixel_max $pixel_courant
            set pixel_max_x $hor
            set pixel_max_y $ver
        }
        }
    }
    # Calcul du rapport signal sur bruit
    set signal_bruit [expr ($pixel_max - $fond) / $bruit_fond]
    # Calcul invalide si signal sur bruit < seuil
    if {$signal_bruit < $seuil} {
        set code_erreur -1
        return [list 0 0 $code_erreur signal/bruit trop faible]
    }
    # Definition du seuil mini pour considerer qu'un pixel est significatif
    # set seuil_mini [expr int(($pixel_max - $fond) / 5.0 + $fond)]
    set seuil_mini [expr $fond + ($seuil * $bruit_fond)]
    set matrice($pixel_max_x,$pixel_max_y) [expr $pixel_max - $fond]

    # Identifie les pixels significatifs autour du sommet
    set couche 1
    set nb_pixels_valides 1
    while {$couche <= 10} {
        set couche_valide 0
        for {set hor [expr $pixel_max_x - $couche]} \
            {$hor <= [expr $pixel_max_x + $couche]} {incr hor} {
        set en_haut [expr $pixel_max_y + $couche]
        set pixel_haut [buf$audace(bufNo) getpix [list $hor $en_haut]]
        set matrice($hor,$en_haut) 0
        if {$pixel_haut > $seuil_mini} {
            set matrice($hor,$en_haut) [expr $pixel_haut - $fond]
            set couche_valide 1
            incr nb_pixels_valides
        }
        set en_bas [expr $pixel_max_y - $couche]
        set pixel_bas [buf$audace(bufNo) getpix [list $hor $en_bas]]
        set matrice($hor,$en_bas) 0
        if {$pixel_bas > $seuil_mini} {
            set matrice($hor,$en_bas) [expr $pixel_bas - $fond]
            set couche_valide 1
            incr nb_pixels_valides
        }
        }
        for {set ver [expr $pixel_max_y - $couche + 1]} \
            {$ver <= [expr $pixel_max_y + $couche - 1]} {incr ver} {
        set a_droite [expr $pixel_max_x + $couche]
        set pixel_droit [buf$audace(bufNo) getpix [list $a_droite $ver]]
        set matrice($a_droite,$ver) 0
        if {$pixel_droit > $seuil_mini} {
            set matrice($a_droite,$ver) [expr $pixel_droit - $fond]
            set couche_valide 1
            incr nb_pixels_valides
        }
        set a_gauche [expr $pixel_max_x - $couche]
        set pixel_gauche [buf$audace(bufNo) getpix [list $a_gauche $ver]]
        set matrice($a_gauche,$ver) 0
        if {$pixel_gauche > $seuil_mini} {
            set matrice($a_gauche,$ver) [expr $pixel_gauche - $fond]
            set couche_valide 1
            incr nb_pixels_valides
        }
        }
        set nb_couches $couche
        incr couche
        if {$couche_valide == 0} {set couche 100}
    }

    # Calcul invalide si 10 couches n'ont pas suffi a cerner l'etoile
    if {$couche == 11} {
        set code_erreur -2
        return [list 0 0 $code_erreur etoile non isolee]
    }

    # Calcul invalide si il n'y a pas au moins 9 pixels valides
    if {$nb_pixels_valides < 9} {
        set code_erreur -3
        return [list 0 0 $code_erreur pixel chaud]
    }

    # Calcul du centre...
    set centre_x 0.0
    set centre_y 0.0
    set flux 0
    for {set hor [expr $pixel_max_x - $nb_couches]} \
        {$hor <= [expr $pixel_max_x + $nb_couches]} {incr hor} {
        for {set ver [expr $pixel_max_y - $nb_couches + 1]} \
            {$ver <= [expr $pixel_max_y + $nb_couches - 1]} {incr ver} {
        set pixel [buf$audace(bufNo) getpix [list $hor $ver]]
        set centre_x [expr $centre_x + ($hor * $matrice($hor,$ver))]
        set centre_y [expr $centre_y + ($ver * $matrice($hor,$ver))]
        set flux [expr $flux + $matrice($hor,$ver)]
        }
    }
    set centre_x [expr $centre_x / $flux]
    set centre_y [expr $centre_y / $flux]
    set code_erreur 1
    return [list $centre_x $centre_y $code_erreur]
    }
    #----- Fin dela procedure Centroide ------------------------

#-------------Partie Autoking.tcl
#----- Procedure KingAuto------------------------------------------------------
    proc KingAuto {} {
    variable king_config
    global panneau
    global audace
    global caption
    global conf

    # Lance la procedure FichierTest si le parametre Test est valide dans la config active
    #   (Test est un parametre du fichier methking.ini)
    if {$king_config(test,$panneau(meth_king,config_active)) != 0} {
        if {[file exists [file join $audace(rep_plugin) tool methking fichiertest.tcl]] == 1} {
           source [file join $audace(rep_audela) tool methking fichiertest.tcl]
        } else {
        tk_messageBox -title "Problème" -type ok \
            -message "Le fichier de test\n[ file join audace plugin tool methking fichiertest.tcl ]\nest introuvable."
        }
    }

    set nom $panneau(meth_king,nom_image)
    set nom_reg ${nom}reg
    set nb_im_par_seq $panneau(meth_king,nb_im_par_seq)
    set nb_images [expr $nb_im_par_seq * 2]
    buf$audace(bufNo) extension "$conf(extension,defaut)"
    set ext_fichier [buf$audace(bufNo) extension]

    # Etape 1: Registration de toutes les images.
    Message consolog "%s\n" $caption(king,recalage)
    Message status $caption(king,recalage)
        register [file tail $nom] [file tail $nom_reg] $nb_images

    Message consolog "%s\n" $caption(king,status_analyse)
    Message status $caption(king,status_analyse)
    for {set image 1} {$image <= $nb_images} {incr image} {
        Message consolog "\t%s %s\n" $caption(king,image) $image
        buf$audace(bufNo) load "$nom$image"

        # Extraction des date et heure de l'image
        set mesure(im_$image,date) [DateHeureImage]
        Message consolog "\t\t%s %s (%s)\n" $caption(king,date) [mc_date2ymdhms $mesure(im_$image,date)] $mesure(im_$image,date)
    }

    set corr_king_x 0.0
    set corr_king_y 0.0
    set corr2_king_x 0.0
    set corr2_king_y 0.0

    # Pour chaque couple d'image, donc...
    Message consolog $caption(king,status_couple)
    Message status $caption(king,status_couple)
    for {set i 1} {$i <= $nb_im_par_seq} {incr i} {
        # k est l'indice de la ieme image dans la seconde sequence
        set k [expr $i + $nb_im_par_seq]

        Message consolog "\t%s %d / %d\n" $caption(king,couple) $i $k

        # Mesure du décalage
        set dec_x 0.0
        set dec_y 0.0

        buf$audace(bufNo) load "$nom_reg$i"
        set decal_1 [decalage]

        buf$audace(bufNo) load "$nom_reg$k"
        set decal_2 [decalage]

        set decal_x [expr [lindex $decal_2 0] - [lindex $decal_1 0]]
        set decal_y [expr [lindex $decal_2 1] - [lindex $decal_1 1]]
        Message consolog "\t\tDx=%5.2f / Dy=%5.2f\n" $decal_x $decal_y


        # Calcul du temps ecoule entre les deux images
        set dt [expr $mesure(im_$k,date) - $mesure(im_$i,date)]
        set dt [expr $dt * 86400.0]
        Message consolog "\t\tDt=%5.2f\n" $dt

        # Calcul de King proprement dit (correction a apporter sur la monture)
        set king [KingBase $decal_x $decal_y $dt]
        Message consolog "\t\t%s x=%5.2f / y=%5.2f\n" $caption(king,correction_brute) [lindex $king 0] [lindex $king 1]

        # Calcul du temps ecoule entre l'image k (celle en cours de traitement, et
        # appartenant a la seconde sequence) et la derniere image de la sequence.
        set dt [expr $mesure(im_$nb_images,date) - $mesure(im_$k,date)]
        set dt [expr $dt * 86400.0]

        # Calcul de la compensation à apporter sur la monture
        set king_x [lindex $king 0]
        set king_y [lindex $king 1]
        set king_corrige [KingRattrapage $king_x $king_y $dt ]
        Message consolog "\t\t%s x=%5.2f / y=%5.2f\n" $caption(king,corr_compensee) [lindex $king_corrige 0] [lindex $king_corrige 1]
        # Cumul des valeurs
        set corr_king_x [expr $corr_king_x + [lindex $king_corrige 0]]
        set corr_king_y [expr $corr_king_y + [lindex $king_corrige 1]]
        set corr2_king_x [expr $corr2_king_x + ([lindex $king_corrige 0] * [lindex $king_corrige 0])]
        set corr2_king_y [expr $corr2_king_y + ([lindex $king_corrige 1] * [lindex $king_corrige 1])]

        # Effacement des images registrées, qui ne servent plus à rien.
        set a_effacer $nom_reg$i
        append a_effacer $ext_fichier
        file delete $a_effacer
        set a_effacer $nom_reg$k
        append a_effacer $ext_fichier
        file delete $a_effacer
    }

    Message consolog "%s \n" $caption(king,status_calc_king)
    Message status $caption(king,status_calc_king)

    set corr_king_x [expr +($corr_king_x / $nb_im_par_seq)]
    set corr_king_y [expr +($corr_king_y / $nb_im_par_seq)]

    Message consolog "\t%s dx=%5.2f /  dy=%5.2f\n" $caption(king,corr_king_2) $corr_king_x $corr_king_y

    set corr2_king_x [expr +($corr2_king_x / $nb_im_par_seq)]
    set corr2_king_y [expr +($corr2_king_y / $nb_im_par_seq)]

    set sigma2_dx [expr $corr2_king_x - (($corr_king_x) * ($corr_king_x))]
    set sigma2_dy [expr $corr2_king_y - (($corr_king_y) * ($corr_king_y))]
    if {($sigma2_dx >= 0) && ($sigma2_dy >= 0)} {
        set panneau(meth_king,sigma_dx) [expr sqrt($sigma2_dx)]
        set panneau(meth_king,sigma_dy) [expr sqrt($sigma2_dy)]
        Message consolog "\t%s       sx = %5.2f /  sy = %5.2f\n" $caption(king,sigma_king) $panneau(meth_king,sigma_dx) $panneau(meth_king,sigma_dy)
    }
    # Stockage de ces valeurs dans la variable globale "panneau".
    set panneau(meth_king,monture_dx) $corr_king_x
    set panneau(meth_king,monture_dy) $corr_king_y
    Message consolog "%s\n\n" $caption(king,fin_calcul)

    #   Validation
    set panneau(meth_king,status) 200
    }
    #----- Procedure KingAuto ----------------------------------------

# --------------Partie MethKing.tcl
    #--------------------------------------------------------------------------#
    proc DemarrageKing {This} {
        variable fichier_config
        variable fichier_log
        variable king_config
        variable liste_motcle
        variable log_id
        variable numero_version
        global panneau audace caption conf

        # Gestion du fichier de log
        # Création du nom de fichier log
        set formatdate [clock format [clock seconds] -format %Y%m%d_%H%M]
        set fichier_log $audace(rep_images)
        append fichier_log /methking_ $formatdate ".log"

        # Ouverture
        if [catch {open $fichier_log w} log_id] {
            Message console "%s \n" $caption(king,erreur_fichier_log)
            unpack
            return
        }

        # Entête du fichier
        Message consolog "%s\n" $caption(king,titre_console_1)
        Message consolog "%s %s\n" $caption(king,titre_console_2) $numero_version
        Message consolog "%s\n" $caption(king,copyright)
        set temps [clock format [clock seconds] -format %Y%m%d]
        Message log "%s : %s\n" $caption(king,date) $temps

        # Prise en compte du mode de compression des fichiers
        if {$conf(fichier,compres)==1} {
            buf$audace(bufNo) compress gzip
        } else {
            buf$audace(bufNo) compress none
        }

        # Création et initialisation de quelques variables
        set panneau(meth_king,status) 0

        for {set i 0} {$i < 10} {incr i} {
            for {set j 0} {$j < [llength $liste_motcle]} {incr j} {
                set king_config([lindex $::MethKing::liste_motcle $j],$i) [lindex $::MethKing::liste_valeur_defaut $j]
            }
        }
        set king_config(nombre_config) 1
        set king_config(config_defaut) 0
        set fichier_config [file join $audace(rep_plugin) tool methking methking.ini]
        
	# Lecture du fichier de configuration
        Message log "%s\n" $caption(king,lecture_config)
        GetConfig $fichier_config king_config
        Message log "%s\n" $caption(king,fin_lecture_config)
        Message log "---------------------------------------------\n"
        set panneau(meth_king,config_active) $panneau(meth_king,config_defaut)
        set panneau(meth_king,nom_image) [file join $audace(rep_images) $panneau(meth_king,nom_image_temp)]

        # Création et initialisation de la fenêtre des paramètres
        CreeFenetreParametres
        ModifieFenetreParametres
        for {set i 0} {$i < $panneau(meth_king,nombre_config)} {incr i} {
            $audace(base).methking.flisteconfig.configmb.menu insert $i radiobutton -label $king_config(config,$i) -variable panneau(meth_king,config_active) -value $i -command ::MethKing::ModifieFenetreParametres
        }
    }

    #--------------------------------------------------------------------------#
    proc ArretKing {} {
        global panneau caption audace
        variable log_id

        # Effacement des entrées du menu Paramètre
        $audace(base).methking.flisteconfig.configmb.menu delete 0 [expr $panneau(meth_king,nombre_config) - 1]

        # Fermeture du fichier de log
        Message log "%s\n" $caption(king,fin_session)
        close $log_id

        # Fermeture de la fenetre des parametres
        destroy $audace(base).fenparam
    }

    #--------------------------------------------------------------------------#
    proc Init {{in ""}} {
        variable fichier_config
        variable fichier_log
        variable king_config
        variable liste_motcle
        variable log_id

        createPanel $in.methking king_config
    }

    #--------------------------------------------------------------------------#
    proc createPanel {this king_config} {
        variable This
        global panneau caption
        upvar $king_config tableau

        set This $this

        set panneau(menu_name,MethKing) $caption(king,titre)

        set panneau(meth_king,status) ""
        set panneau(meth_king,infos) ""
        set panneau(meth_king,selection_cercle) -1
        set panneau(meth_king,nom_image_temp) "king_"

        MethKingBuildIF $This tableau
    }

    #--------------------------------------------------------------------------#
    proc pack {} {
    global unpackFunction
    variable This

    DemarrageKing This
    set unpackFunction ::MethKing::unpack
    set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
    uplevel #0 $a_executer
    }

    #--------------------------------------------------------------------------#
    proc unpack {} {
    variable This
    ArretKing
    set a_executer "pack forget $This"
    uplevel #0 $a_executer
    }

    #--------------------------------------------------------------------------#
    proc CmdAcquisition {} {
    global panneau
    global audace
    global conf
    global caption
    variable This
    variable king_config
    variable camera

    # Initialisations
    set image_noire [file join [file dirname $panneau(meth_king,nom_image)] king_noir_]

    # Definitions pour alléger l' écriture du source
    set nom $panneau(meth_king,nom_image)
    set config_active $panneau(meth_king,config_active)

    if {[::cam::list]!=""} {
        # Mise en oeuvre du bouton d'arrêt
        $This.stop.b configure -command {::MethKing::ArretAcquisition} -state normal
        # Blocage de tous les boutons
        EtatBoutons disabled

        # Lecture du nom de la caméra
        set camera $conf(camera)

        #1ère séquence
        Message consolog "%s\n" $caption(king,sequence_1)
        set panneau(meth_king,demande_arret_acq) 0
        set t1 [clock second]
        cam$audace(camNo) buf 1
        cam$audace(camNo) shutter synchro
        for {set image 1} {$image <= $king_config(poseparseq,$config_active)} {incr image} {
        if {$panneau(meth_king,demande_arret_acq) == 0} {
            # Acquisition
            Message status "%s %d" $caption(king,acq_image) $image
            Message consolog "\t%s %d\n" $caption(king,acq_image_bis) $image
            set panneau(meth_king,status_acq) 1
            Message infos "%s" $caption(king,vidange)
            cam$audace(camNo) exptime $king_config(tempspose,$config_active)
            cam$audace(camNo) bin [list $king_config(binning,$config_active) $king_config(binning,$config_active)]
            cam$audace(camNo) acq
            ::MethKing::AfficheTimerAcq
            vwait status_cam$audace(camNo)
            Message infos ""
            set panneau(meth_king,status_acq) 0
            if {$conf($camera,mirx)==1} {
            buf$audace(bufNo) mirrorx
            }
            if {$conf($camera,miry)==1} {
            buf$audace(bufNo) mirrory
            }
            ::audace::autovisu visu$audace(visuNo)
            if {$panneau(meth_king,demande_arret_acq) == 0} {
            # --- sauvegarde de l'image sur le disque
            Message status "%s %s" $caption(king,sauv_image) [file tail ${nom}${image}]
            Message consolog "\t%s %s\n" $caption(king,sauv_image_bis) ${nom}${image}
            buf$audace(bufNo) save ${nom}${image}
            }
        }
        }

        #séquence des noirs
        if {$king_config(noir,$config_active) != 0} {
        if {$panneau(meth_king,demande_arret_acq) == 0} {
            Message consolog "%s\n" $caption(king,sequence_noirs)
            cam$audace(camNo) shutter closed
        }
        for {set image 1} {$image <= 3} {incr image} {
            if {$panneau(meth_king,demande_arret_acq) == 0} {
            # Acquisition
            Message status "%s %d" $caption(king,acq_noir) $image
            Message consolog "\t%s %d\n" $caption(king,acq_noir_bis) $image

            set panneau(meth_king,status_acq) 1
            Message infos "%s" $caption(king,vidange)
            cam$audace(camNo) exptime $king_config(tempspose,$config_active)
            cam$audace(camNo) bin [list $king_config(binning,$config_active) $king_config(binning,$config_active)]
            cam$audace(camNo) acq
            ::MethKing::AfficheTimerAcq
            vwait status_cam$audace(camNo)
            Message infos ""
            set panneau(meth_king,status_acq) 0

            if {$conf($camera,mirx)==1} {
                buf$audace(bufNo) mirrorx
            }
            if {$conf($camera,miry)==1} {
                buf$audace(bufNo) mirrory
            }
            ::audace::autovisu visu$audace(visuNo)
            if {$panneau(meth_king,demande_arret_acq) == 0} {
                # --- sauvegarde de l'image sur le disque
                Message status "%s %s" $caption(king,sauv_noir) ${image_noire}${image}
                Message consolog "\t%s %s\n" $caption(king,sauv_noir_bis) ${image_noire}${image}
                buf$audace(bufNo) save "${image_noire}${image}"
            }
            }
        }
        }

        if {$panneau(meth_king,demande_arret_acq) == 0} {
        # Attente entre les poses
        set t2 [clock second]
        set t3 [expr ($king_config(interpose,$config_active) - ($t2 - $t1) - 1)]
        if {$t3 > 0} {
            Message status "%s \n %d s" $caption(king,attente) $t3
            Message consolog "%s %d s\n" $caption(king,attente) $t3
            set panneau(meth_king,timer) $t3
            AfficheTimer
            vwait panneau(meth_king,timer_fin)
        }
        }

        # 2èm séquence
        if {$panneau(meth_king,demande_arret_acq) == 0} {
        Message consolog "%s\n" $caption(king,sequence_2)
        cam$audace(camNo) shutter synchro
        }
        for {set image [expr $king_config(poseparseq,$config_active) + 1]} {$image <= [expr 2*$king_config(poseparseq,$config_active)]} {incr image} {
        if {$panneau(meth_king,demande_arret_acq) == 0} {
            # Acquisition
            Message status "%s %d" $caption(king,acq_image) $image
            Message consolog "\t%s %d\n" $caption(king,acq_image_bis) $image

            set panneau(meth_king,status_acq) 1
            Message infos "%s" $caption(king,vidange)
            cam$audace(camNo) exptime $king_config(tempspose,$config_active)
            cam$audace(camNo) bin [list $king_config(binning,$config_active) $king_config(binning,$config_active)]
            cam$audace(camNo) acq
            ::MethKing::AfficheTimerAcq
            vwait status_cam$audace(camNo)
            Message infos ""
            set panneau(meth_king,status_acq) 0

            if {$conf($camera,mirx)==1} {
            buf$audace(bufNo) mirrorx
            }
            if {$conf($camera,miry)==1} {
            buf$audace(bufNo) mirrory
            }
            ::audace::autovisu visu$audace(visuNo)

            # --- sauvegarde de l'image sur le disque
            if {$panneau(meth_king,demande_arret_acq) == 0} {
            Message status "%s %s" $caption(king,sauv_image) [file tail ${nom}${image}]
            Message consolog "\t%s %s\n" $caption(king,sauv_image_bis) ${nom}${image}
            buf$audace(bufNo) save "${nom}${image}"
            }
        }
        }

        if {$king_config(noir,$config_active) != 0} {
        if {$panneau(meth_king,demande_arret_acq) == 0} {
            # Calcul du noir médian
            Message status "%s" $caption(king,noir_median)
            Message consolog "%s\n" $caption(king,noir_median_bis)
            smedian [file tail $image_noire] [file tail $image_noire] 3

            # Destruction des fichiers de noir
            # note :delete2 ne marche pas avec des fichiers .gz
            for {set image 1} {$image <= 3} {incr image} {
            set fichier_noir [file join $audace(rep_images) $image_noire]
            append fichier_noir $image "$conf(extension,defaut)"
            if {[buf$audace(bufNo) compress] == "gzip"} {
                append fichier_noir ".gz"
            }
            file delete -force $fichier_noir
            }

            # Soustraction du noir à toutes les images acquises
            Message status "%s" $caption(king,soust_noir)
            for {set image 1} {$image <= [expr 2*$king_config(poseparseq,$config_active)]} {incr image} {
            Message consolog "%s %d\n" $caption(king,soust_noir_bis) $image
            buf$audace(bufNo) load "${nom}${image}"
            buf$audace(bufNo) sub "$image_noire" 0
            buf$audace(bufNo) save "${nom}${image}"
            ::audace::autovisu visu$audace(visuNo)
            }

            # Destruction du fichier de noir médian
            set fichier_noir [file join $audace(rep_images) $image_noire]
            append fichier_noir "$conf(extension,defaut)"
            file delete -force $fichier_noir

        }
        }

        if {$panneau(meth_king,demande_arret_acq) == 0} {
        Message status "%s" $caption(king,fin_acquisition)
        Message consolog "%s\n" $caption(king,fin_acquisition)
        }

        # Bip pour réveiller l'observateur
        bell
        bell

        # Desactivation du bouton d'arrêt
        $This.stop.b configure -command {} -state disabled
        # Déblocage de tous les boutons
        EtatBoutons normal
    } else {
        Message status "%s" $caption(king,pas_camera)
        Message erreur "%s\n" $caption(king,pas_camera)
        BoiteMessage $caption(king,erreur) $caption(king,pas_camera)
    }
    }

    #--------------------------------------------------------------------------#
    proc ArretAcquisition {} {
        variable This
        global panneau caption audace

        # Bloque le bouton pour éviter de relancer ce binding
        $This.stop.b configure -state disabled

        Message status "%s" $caption(king,arret_acquisition)
        Message consolog "%s\n" $caption(king,arret_acquisition)
        set panneau(meth_king,demande_arret_acq) 1
        if {$panneau(meth_king,status_acq) == 1} {
            Message infos "%s" $caption(king,lecture_ccd)
            vwait status_cam$audace(camNo)
        }
        Message infos ""
        set panneau(meth_king,timer_fin) -1
        set panneau(meth_king,timer) 0

        # Débloque le bouton
        $This.stop.b configure -state normal
    }

    #--------------------------------------------------------------------------#
    proc AfficheTimerAcq {} {
    variable This
    global audace
    global caption
    global panneau

    set t "[cam$audace(camNo) timer -1]"
    if {$t>1} {
        Message infos "%s\n%d / %d" $caption(king,integration) $t [expr int([cam$audace(camNo) exptime])]
        after 1000 ::MethKing::AfficheTimerAcq
    } else {
        if {$panneau(meth_king,demande_arret_acq) == 0} {
        Message infos "%s" $caption(king,lecture_ccd)
        }
    }
    }

    #--------------------------------------------------------------------------#
    proc CmdCalcul {} {
    	global panneau audace caption conf
    	variable king_config
    	variable This

    	# Blocage de tous les boutons
    	EtatBoutons disabled

    	# Simplification des écritures
    	set config_active $panneau(meth_king,config_active)
    	set panneau(meth_king,nb_im_par_seq) $king_config(poseparseq,$config_active)
    	set nom $panneau(meth_king,nom_image)

    	# Vérification de la présence des fichiers
    	buf$audace(bufNo) extension "$conf(extension,defaut)"
    	for {set image 1} {$image <= [expr $king_config(poseparseq,$config_active) * 2]} {incr image} {
        	set nom_fichier $nom$image
        	append nom_fichier [buf$audace(bufNo) extension]
        	if {[buf$audace(bufNo) compress] == "gzip"} {
        		append nom_fichier ".gz"
        	}

        	if {(![file exists $nom_fichier])} {
        		set message $caption(king,fichier)
        		append message " " $nom_fichier " " $caption(king,non_existence)
        		Message erreur "%s\n" $message
        		BoiteMessage $caption(king,erreur) $message
        		EtatBoutons normal
        		return
        	}
    	}

    	# Sélection du mode de calcul
    	set mode_calcul [tk_dialog .calcul $caption(king,mode_calcul_1) $caption(king,mode_calcul_2) {} 0 $caption(king,bouton_auto) $caption(king,bouton_manuel)]
    	Message infos ""
    	if {$mode_calcul == 1} {
        	Message consolog "\n\n%s\n" $caption(king,king_manuel)
        	# Procédure manuelle
        	KingPreparation

        	# Sélection manuelle des etoiles.
        	Message consolog "%s\n" $caption(king,selection_etoile)
        	CreeFenetreSelection

        	# Attente de la fin des calculs
        	vwait panneau(meth_king,status)
        	destroy $audace(base).selectetoile
    	} else {
        	Message consolog "\n\n%s\n" $caption(king,king_auto)
        	KingAuto
    	}

    	if {$panneau(meth_king,status) == 200} {
        	if {[expr $king_config(focale,$config_active) * $king_config(pixel_x,$config_active)] != 0} {
        		set ecart_pole [CalculeEcartPole $panneau(meth_king,monture_dx) $panneau(meth_king,monture_dy) $king_config(pixel_x,$config_active) $king_config(focale,$config_active) $king_config(binning,$config_active)]
        		Message consolog "%s: %3.1f '\n" $caption(king,ecart_pole) $ecart_pole
        	} else {
        		set ecart_pole -1
        	}

        	# Isolation de la partie entière de Dx et Dy
        	set panneau(meth_king,monture_dx) [expr round($panneau(meth_king,monture_dx))]
        	set panneau(meth_king,monture_dy) [expr round($panneau(meth_king,monture_dy))]

        	# Affichage du DX et DY
        	set resultat $caption(king,resultat_dx)
        	append resultat ": " $panneau(meth_king,monture_dx) "\n" $caption(king,resultat_dy) ": " $panneau(meth_king,monture_dy)
        	Message status $resultat
        	set resultat $caption(king,ecart_pole_bis)
        	if {$ecart_pole >= 0} {
        		append resultat " " $ecart_pole "'"
        		Message infos $resultat
        	}

        	#Les réglages se feront en binning 2x2, il faut donc diviser dx et dy par 2 si les images de calcul ont été faites en binning 1x1. De plus, le temps de pose doit être divisé par 4
        	if {$king_config(binning,$config_active) == 1} {
        		set panneau(meth_king,monture_dx) [expr $panneau(meth_king,monture_dx) / 2]
        		set panneau(meth_king,monture_dy) [expr $panneau(meth_king,monture_dy) / 2]
        		set panneau(meth_king,monture_dx) [expr int($panneau(meth_king,monture_dx))]
        		set panneau(meth_king,monture_dy) [expr int($panneau(meth_king,monture_dy))]
        	}

        	# Récupération de la date et de l'heure de la dernière image valide
        	set panneau(meth_king,dateheure) [DateHeureImage]
    	}

    	# Déblocage de tous les boutons
    	EtatBoutons normal
    }

    #--------------------------------------------------------------------------#
    proc CmdReglage {} {
        global panneau conf caption audace
        variable king_config
        variable This

        # Définitions pour alléger l' écriture du source
        set config_active $panneau(meth_king,config_active)

        # Les réglages se feront en binning 2x2, il faut donc diviser le temps de pose par 4 si les images de calcul ont été faites en binning 1x1.
        if {$king_config(binning,$config_active) == 1} {
            set temps_pose_reglage [expr (int(1.00* $king_config(tempspose,$config_active) / 4)) + 1]
        } else {
            set temps_pose_reglage $king_config(tempspose,$config_active)
        }

        if {![info exists panneau(meth_king,monture_dx)]} {
            Message erreur "%s\n" $caption(king,calcul_pas_fait)
            set choix [tk_messageBox -icon error -title $caption(king,erreur) -message "$caption(king,calcul_pas_fait)\n$caption(king,prop_valeur)" -type yesno]
            update idletasks
            if {$choix == "yes"} {
                EntreeDxDy
                set panneau(meth_king,dateheure) [mc_date2jd now]
                tkwait window $audace(base).dxdy
            } else {return}
        }

        if {[::cam::list]!=""} {
            # Lecture du nom de la caméra
            set camera $conf(camera)
            # Création des buffers nécessaires aux acquisitions et visualisations
            set numero_buffer_1 [::buf::create]
            buf$numero_buffer_1 clear
            set numero_visu_1 [::visu::create $numero_buffer_1 $numero_buffer_1]
            set numero_buffer_2 [::buf::create]
            buf$numero_buffer_2 clear
            set numero_visu_2 [::visu::create $numero_buffer_2 $numero_buffer_2]

            # Effacement de l'image précédente
            visu$numero_visu_1 disp 0 0
            visu$numero_visu_2 disp 0 0

            # Mise en mémoire de ces infos (pour que ArretReglages puisse y accéder)
            set panneau(meth_king,numero_buffer_1) $numero_buffer_1
            set panneau(meth_king,numero_visu_1) $numero_visu_1
            set panneau(meth_king,numero_buffer_2) $numero_buffer_2
            set panneau(meth_king,numero_visu_2) $numero_visu_2

            # Mise en oeuvre du bouton d'arrêt
            $This.stop.b configure -command {::MethKing::ArretReglages}  -state normal
            # Blocage de tous les boutons
            EtatBoutons disabled

            Message status $caption(king,acq_im_ref)
            Message consolog "%s\n" $caption(king,acq_im_ref_bis)
            set panneau(meth_king,demande_arret_acq) 0
            set panneau(meth_king,attente_cercle) 0
            if {$panneau(meth_king,demande_arret_acq) == 0} {
                CreePremiereFenetreReglages $numero_buffer_1 $numero_visu_1 2
            }

            if {$panneau(meth_king,demande_arret_acq) == 0} {
                set panneau(meth_king,status_regl) 1

                Message infos $caption(king,vidange)
                cam$audace(camNo) buf $numero_buffer_1
                cam$audace(camNo) exptime $temps_pose_reglage
                cam$audace(camNo) bin {2 2}
                cam$audace(camNo) acq
                ::MethKing::AfficheTimerAcq
                vwait status_cam$audace(camNo)
                Message infos ""
                set panneau(meth_king,status_regl) 0
            }

            if {$panneau(meth_king,demande_arret_acq) == 0} {
                Message consolog "%s\n" $caption(king,calcul_correction)
                set date [buf$numero_buffer_1 getkwd DATE-OBS]
                set date [lindex $date 1]
                set t2 [mc_date2jd $date]
                set dt [expr [expr $t2 - $panneau(meth_king,dateheure)] * 86400.0]
                set ultime_correction [KingRattrapage $panneau(meth_king,monture_dx) $panneau(meth_king,monture_dy) $dt]
                set panneau(meth_king,monture_dx) [lindex $ultime_correction 0]
                set panneau(meth_king,monture_dy) [lindex $ultime_correction 1]
                set panneau(meth_king,monture_dx) [expr int($panneau(meth_king,monture_dx))]
                set panneau(meth_king,monture_dy) [expr int($panneau(meth_king,monture_dy))]
                Message consolog "%s %4.2f\n" $caption(king,nouveau_dx) $panneau(meth_king,monture_dx)
                Message consolog "%s %4.2f\n" $caption(king,nouveau_dy) $panneau(meth_king,monture_dy)
                CreeCurseurPremiereFenetre
            }

            if {$panneau(meth_king,demande_arret_acq) == 0} {
                if {$conf($camera,mirx)==1} {
                    buf$numero_buffer_1 mirrorx
                }
                if {$conf($camera,miry)==1} {
                    buf$numero_buffer_1 mirrory
                }
                visu$numero_visu_1 cut [lrange [buf$numero_buffer_1 stat] 0 1 ]
                visu$numero_visu_1 disp
                ValidationBindingsPremiereFenetre
            }

            if {$panneau(meth_king,demande_arret_acq) == 0} {
                Message status $caption(king,selection_etoile)
                set panneau(meth_king,attente_cercle) 1
                vwait panneau(meth_king,selection_cercle)
                set panneau(meth_king,attente_cercle) 0
            }

            if {$panneau(meth_king,demande_arret_acq) == 0} {
                CreeDeuxiemeFenetreReglages $numero_buffer_2 $numero_visu_2 2
            }

            cam$audace(camNo) buf $numero_buffer_2
            cam$audace(camNo) exptime $temps_pose_reglage
            cam$audace(camNo) bin {2 2}
            Message consolog "%s\n" $caption(king,acq_continue_bis)
            while {$panneau(meth_king,demande_arret_acq) == 0} {
                Message status $caption(king,acq_continue)
                set panneau(meth_king,status_regl) 1
                Message infos $caption(king,vidange)
                cam$audace(camNo) acq
                ::MethKing::AfficheTimerAcq
                vwait status_cam$audace(camNo)
                Message infos ""
                set panneau(meth_king,status_regl) 0
                if {$panneau(meth_king,demande_arret_acq) == 0} {
                    if {$conf($camera,mirx)==1} {
                        buf$numero_buffer_2 mirrorx
                    }
                    if {$conf($camera,miry)==1} {
                        buf$numero_buffer_2 mirrory
                    }
                    visu$numero_visu_2 cut [lrange [buf$numero_buffer_2 stat] 0 1 ]
                    visu$numero_visu_2 disp
                }
            }

            # Désactivation du bouton d'arrêt
            $This.stop.b configure -command {} -state disabled
            # Déblocage de tous les boutons
            EtatBoutons normal
        } else {
            Message status $caption(king,pas_de_camera)
            Message erreur "%s\n" $caption(king,pas_de_camera)
            BoiteMessage $caption(king,erreur) $caption(king,pas_de_camera)
        }
    }

    #--------------------------------------------------------------------------#
    proc ArretReglages {} {
        variable This
        global panneau caption audace

        # Bloque le bouton pour éviter de relancer ce binding
        $This.stop.b configure -state disabled

        Message status $caption(king,arret_reglage)
        #  Si l'utilisateur était en train de sélectionner une étoile, position-
        #  ner la variable indiquent que cette saisie est finie (qui va permettre
        #  au binding de regalge d'arrêter d'attendre cette sélection)
        if {$panneau(meth_king,attente_cercle) == 1} {
            set panneau(meth_king,selection_cercle) 1
        }
        #  Si l'utilisateur était en train de faire une acquisition d'image,
        #  attendre la fin de l'acquisition
        if {$panneau(meth_king,status_regl) == 1} {
            Message infos $caption(king,lecture_ccd)
            vwait status_cam$audace(camNo)
        }
        Message infos ""

        #  Faire la même chose pour le timer
        set panneau(meth_king,timer_fin) -1
        set panneau(meth_king,timer) 0
        #  Détruire les fenêtres de saisie
        destroy $audace(base).fenreglages
        destroy $audace(base).fenreglages2
        #  Libérer les ressources allouées (buffer et visu)
        ::buf::delete $panneau(meth_king,numero_buffer_1)
        ::buf::delete $panneau(meth_king,numero_buffer_2)
        ::visu::delete $panneau(meth_king,numero_visu_1)
        ::visu::delete $panneau(meth_king,numero_visu_2)
        #  Rétablir le buffer où pointe la caméra (1 par défaut)
        cam$audace(camNo) buf 1

        # Débloquer le bouton
        $This.stop.b configure -state normal

        #  Positionner une variable indiquant le mode arret (qui va permettre
        #  au binding de reglage d'arrêter les traitements en cours)
        set panneau(meth_king,demande_arret_acq) 1
    }

    #--------------------------------------------------------------------------#
    proc EntreeDxDy {} {
        global caption panneau audace
        variable This

        toplevel $audace(base).dxdy -borderwidth 2 -relief groove
        wm geometry $audace(base).dxdy +150+50
        wm title $audace(base).dxdy $caption(king,entreedxdy)
        wm transient $audace(base).dxdy $audace(base)
        wm protocol $audace(base).dxdy WM_DELETE_WINDOW ::MethKing::Suppression

        set t1 [frame $audace(base).dxdy.trame1]

        foreach champ {dx dy} {
            label $t1.l$champ -text $caption(king,entree$champ)
            entry $t1.e$champ -textvariable panneau(meth_king,monture_$champ) -relief sunken -width 4
            grid $t1.l$champ $t1.e$champ -sticky news
        }

        set t2 [frame $audace(base).dxdy.trame2 -borderwidth 2 -relief groove]
        button $t2.b1 -text $caption(king,valider) -command {::MethKing::ValideEntreeDxDy} -height 1
        ::pack $t2.b1 -side top -padx 10 -pady 10

        ::pack $t1 $t2 -fill x

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    #--------------------------------------------------------------------------#
    proc ValideEntreeDxDy {} {
        global panneau caption audace

        if {([TestEntierSigne $panneau(meth_king,monture_dx)] == 0) || ([TestEntierSigne $panneau(meth_king,monture_dy)] == 0)} {
            tk_messageBox -type ok -icon error -title $caption(king,erreur) -message $caption(king,valeur_illegale)
        } else {
            destroy $audace(base).dxdy
        }
    }

    #--------------------------------------------------------------------------#
    proc CreeFenetreParametres {} {
        global panneau audace caption
        variable This

        # Construction de la fenêtre des paramètres
        toplevel $audace(base).fenparam -borderwidth 2 -relief groove

        wm geometry $audace(base).fenparam +638+0
        wm title $audace(base).fenparam $caption(king,parametres)
        wm transient $audace(base).fenparam $audace(base)
        wm protocol $audace(base).fenparam WM_DELETE_WINDOW ::MethKing::Suppression

        set valeur "    "
        set unite(binning) ""
        set unite(tempspose) " s"
        set unite(poseparseq) ""
        set unite(entrepose) " s"
        set unite(noir) ""
        set unite(auto) ""

        foreach champ {binning tempspose poseparseq entrepose noir} {
            label $audace(base).fenparam.l1$champ -text $caption(king,$champ) -padx 0
            label $audace(base).fenparam.l2$champ -text "    " -relief sunken
            label $audace(base).fenparam.l3$champ -text $unite($champ)
            grid $audace(base).fenparam.l1$champ $audace(base).fenparam.l2$champ $audace(base).fenparam.l3$champ -sticky news
        }

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    #--------------------------------------------------------------------------#
    proc ModifieFenetreParametres {} {
        global panneau caption audace
        variable This

        set config $panneau(meth_king,config_active)

        if {[winfo exists $audace(base).fenparam] == 0} {
            CreeFenetreParametres
        }

        wm title $audace(base).fenparam $::MethKing::king_config(config,$config)

        switch -exact -- $::MethKing::king_config(binning,$config) {
            1 {set binning 1x1}
            2 {set binning 2x2}
            3 {set binning 3x3}
        }
        $audace(base).fenparam.l2binning configure -text $binning
        $audace(base).fenparam.l2tempspose configure -text $::MethKing::king_config(tempspose,$config)
        $audace(base).fenparam.l2poseparseq configure -text $::MethKing::king_config(poseparseq,$config)
        $audace(base).fenparam.l2entrepose configure -text $::MethKing::king_config(interpose,$config)
        if {$::MethKing::king_config(noir,$config) != 0} {
            set texte $caption(king,oui)
        } else {
            set texte $caption(king,non)
        }
        $audace(base).fenparam.l2noir configure -text $texte

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This

        update

        Message log "%s : %d %s\n" $caption(king,config_active) $config $::MethKing::king_config(config,$config)
    }

    #--------------------------------------------------------------------------#
    proc EditeConfig {} {
        global conf panneau caption audace
        variable This

        # Suppression de toutes les entrées de config du menu, puisque l'utilisateur peut en modifier le nombre et l'intitule
        $This.flisteconfig.configmb.menu delete 0 [expr $panneau(meth_king,nombre_config) - 1]

        # Edition
        set fichier_config [file join $audace(rep_plugin) tool methking methking.ini]

        catch {exec $conf(editscript) $fichier_config} resultat

        # Gestion des cas d'erreurs
        if {$resultat == ""} {
            Message log "%s\n" $caption(king,edite_config)
        } else {
            BoiteMessage $caption(king,pas_editeur) $caption(king,conseil_editeur)
            Message erreur "%s\n" $caption(king,pas_editeur)
        }
        Message log "%s\n" $caption(king,nouv_lect_config)

        # Nouvelle lecture du fichier
        GetConfig $fichier_config ::MethKing::king_config
        set panneau(meth_king,config_active) $panneau(meth_king,config_defaut)
        #affichage des modifications dans la fenetre de parametres
        ModifieFenetreParametres

        set panneau(meth_king,config_active) $panneau(meth_king,config_defaut)
        # Actualisation des entrées du menu
        for {set i 0} {$i < $panneau(meth_king,nombre_config)} {incr i} {
            $This.flisteconfig.configmb.menu insert $i radiobutton -label $::MethKing::king_config(config,$i) -variable panneau(meth_king,config_active) -value $i -command ::MethKing::ModifieFenetreParametres
        }
    }

    #--------------------------------------------------------------------------#
    proc CreeFenetreSelection {} {
        global audace caption
        variable This

        toplevel $audace(base).selectetoile -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selectetoile +638+130
        wm resizable $audace(base).selectetoile 0 0
        wm title $audace(base).selectetoile $caption(king,selection)
        wm transient $audace(base).selectetoile $audace(base)
        wm protocol $audace(base).selectetoile WM_DELETE_WINDOW ::MethKing::Suppression

        set texte_bouton(selection) $caption(king,validation_etoile)
        set texte_bouton(lancement) $caption(king,lancement_calcul)
        set texte_bouton(annulation) $caption(king,annulation_calcul)

        set command_bouton(selection) ::MethKing::SelectionneEtoiles
        set command_bouton(lancement) ::MethKing::KingProcess
        set command_bouton(annulation) ::MethKing::AnnuleKing

        #----- Creation du contenu de la fenetre
        foreach champ {selection lancement annulation} {
            button $audace(base).selectetoile.b$champ -text $texte_bouton($champ) -command $command_bouton($champ)
            ::pack $audace(base).selectetoile.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selectetoile  -anchor center -expand 1 -fill both -side top
        }
        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    #--------------------------------------------------------------------------#
    proc AnnuleKing {} {
        global panneau audace caption

        $audace(hCanvas) delete cadres
        set panneau(meth_king,status) 230
        Message console "%s\n" $caption(king,arret_calcul_king)
    }

    #--------------------------------------------------------------------------#
    proc CreePremiereFenetreReglages {num_buf num_visu binning} {
        global audace panneau caption
        variable This

        toplevel $audace(base).fenreglages -borderwidth 2 -relief groove -cursor crosshair

        if {$binning == 1} {
        wm geometry $audace(base).fenreglages 768x512+120+50
        } else {
            # normalement, la fenêtre a une taille de 386x272
            wm geometry $audace(base).fenreglages 386x356+120+50
        }
        wm title $audace(base).fenreglages $caption(king,fenetre_reglages_1)
        wm transient $audace(base).fenreglages $audace(base)
        wm protocol $audace(base).fenreglages WM_DELETE_WINDOW ::MethKing::Suppression


        # Explications et conseils
        label $audace(base).fenreglages.explication -height 1 -justify left
        label $audace(base).fenreglages.conseil -height 1 -justify left
        set a_executer "pack $audace(base).fenreglages.explication $audace(base).fenreglages.conseil -side top -fill x -anchor nw"
        uplevel #0 $a_executer

        canvas $audace(base).fenreglages.image1
        set a_executer "pack $audace(base).fenreglages.image1 -in $audace(base).fenreglages -expand 1 -side top -anchor center -fill both"
        uplevel #0 $a_executer

        # Par rapport à la façon "normale", image2 est créée dans la routine ::visu::create grace au 2ème paramètre de cette routine
        $audace(base).fenreglages.image1 create image 1 1 -image image$num_buf -anchor nw -tag image_ref
        tkwait visibility $audace(base).fenreglages

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    #--------------------------------------------------------------------------#
    proc CreeCurseurPremiereFenetre {} {
        global panneau caption audace color
        variable This

        # Définitions pour alléger l' écriture du source
        set config_active $panneau(meth_king,config_active)
        set dx $panneau(meth_king,monture_dx)
        set dy $panneau(meth_king,monture_dy)

        set panneau(meth_king,cercle_cx) -200 ;# Pour le premier tracé on le met à l'extérieur de la fenêtre
        set panneau(meth_king,cercle_cy) -200 ;# idem

        #  Récupération des dimensions de la fenetre
        set largeur [$audace(base).fenreglages.image1 cget -width]
        set hauteur [$audace(base).fenreglages.image1 cget -height]

        if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
            set texte $caption(king,explication_1)
        } else {
            set texte $caption(king,explication_2)
        }
        $audace(base).fenreglages.explication configure -text $texte
        if {$dx > 0} {
            if {$dy > 0} {
                set texte $caption(king,conseilx+y+)
            } else {
                set texte $caption(king,conseilx+y-)
            }
        } else {
            if {$dy > 0} {
                set texte $caption(king,conseilx-y+)
            } else {
                set texte $caption(king,conseilx-y-)
            }
        }
        $audace(base).fenreglages.conseil configure -text $texte

        # Pour alléger l'écriture
        set cx $panneau(meth_king,cercle_cx)
        set cy $panneau(meth_king,cercle_cy)

        #Tracé du premier cercle autour du curseur
        $audace(base).fenreglages.image1 create oval [expr $cx-15] [expr $cy-15] [expr $cx+16] [expr $cy+16] -outline $color(red) -width 2 -tag cercle_1 -tag cercle
        $audace(base).fenreglages.image1 create oval [expr $cx-5] [expr $cy-5] [expr $cx+6] [expr $cy+6] -outline $color(red) -width 2 -tag cercle_2 -tag cercle

        #Tracé des curseurs "esclave"
        # Le signe - pour $panneau(meth_king,monture_dy) est du à l'inversion du sens des y entre le canvas et l'image
        if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
            $audace(base).fenreglages.image1 create rect [expr $dx + $cx - 15] [expr $cy - 15 - $dy] [expr $dx + $cx + 16] [expr $cy + 16 - $dy] -outline $color(green) -width 2 -tag cercle_3 -tag cercle
            $audace(base).fenreglages.image1 create rect [expr $dx + $cx - 5] [expr $cy - 5 - $dy] [expr $dx + $cx + 6] [expr $cy + 6 - $dy] -outline $color(green) -width 1 -tag cercle_4 -tag cercle
        } else {
            $audace(base).fenreglages.image1 create line $cx $cy [expr $cx + $dx] [expr $cy - $dy] -fill $color(green) -width 2 -tag cercle_3 -tag cercle
        }

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    #--------------------------------------------------------------------------#
    proc TraceCurseur {cx cy} {
        global panneau audace

        set dx [expr $cx - $panneau(meth_king,cercle_cx)]
        set dy [expr $cy - $panneau(meth_king,cercle_cy)]
        $audace(base).fenreglages.image1 move cercle $dx $dy
        set panneau(meth_king,cercle_cx) $cx
        set panneau(meth_king,cercle_cy) $cy
    }

    #--------------------------------------------------------------------------#
    proc MemoriseCurseur {cx cy} {
        global panneau caption audace

        # Definitions pour alléger l' écriture du source
        set dx $panneau(meth_king,monture_dx)
        set dy $panneau(meth_king,monture_dy)

        #  Bloquer tout animation souris
        bind $audace(base).fenreglages.image1 <Motion> {}
        bind $audace(base).fenreglages.image1 <ButtonRelease-1> {}

        #  Récupération des dimensions de la fenetre
        set dimensions [wm geometry $audace(base).fenreglages]
        set largeur [string range $dimensions 0 [expr [string first "x" $dimensions] - 1]]
        set hauteur [string range $dimensions [expr [string first "x" $dimensions ] + 1] [expr [string first "+" $dimensions] - 1]]

        set position_x [expr $cx + $dx]
        # le signe - vient de l'inversion des coordonnées entre le canvas et l'image
        set position_y [expr $cy - $dy]

        #  Si l'étoile cible est en dehors de cette fenetre
        if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
            if {($position_x < 0) || ($position_y < 0) || ($position_x > $largeur) || ($position_y > $hauteur)} {
            #  Alors le signaler , rétablir l'animation souris et sortir
                ::MethKing::BoiteMessage $caption(king,etoile_fenetre) $caption(king,refaire_selection)
                bind $audace(base).fenreglages.image1 <Motion> {::MethKing::TraceCurseur %x %y}
                bind $audace(base).fenreglages.image1 <ButtonRelease-1> {::MethKing::MemoriseCurseur %x %y}
                return
            }
        }

        #  Sinon demander confirmation du choix de l'étoile
        set choix [tk_messageBox -type yesno -default yes -message $caption(king,valide_clic_1) -icon question -title $caption(king,valide_clic_2)]

        #  Si ce choix est confirmé
        if {$choix == "yes"} {
            #  Alors mettre les coordonnées en mémoire,
            set panneau(meth_king,cercle_cx) $cx
            set panneau(meth_king,cercle_cy) $cy
            # rétablir le curseur normal
            $audace(base).fenreglages configure -cursor crosshair
            # indiquer que la sélection est faite  et sortir
            set panneau(meth_king,selection_cercle) [expr -$panneau(meth_king,selection_cercle)]
        } else {
            #  Sinon rétablir l'animation souris et sortir                             #
            bind $audace(base).fenreglages.image1 <Motion> {::MethKing::TraceCurseur %x %y}
            bind $audace(base).fenreglages.image1 <ButtonRelease-1> {::MethKing::MemoriseCurseur %x %y}
        }
    }

    #--------------------------------------------------------------------------#
    proc ValidationBindingsPremiereFenetre {} {
        global audace

        $audace(base).fenreglages configure -cursor circle
        bind $audace(base).fenreglages.image1 <Motion> {::MethKing::TraceCurseur %x %y}
        bind $audace(base).fenreglages.image1 <ButtonRelease-1> {::MethKing::MemoriseCurseur %x %y}
    }


    #--------------------------------------------------------------------------#
    proc CreeDeuxiemeFenetreReglages {num_buf num_visu binning} {
        global audace panneau caption color
        variable This

        # Definitions pour alléger l' écriture du source
        set config_active $panneau(meth_king,config_active)
        set dx $panneau(meth_king,monture_dx)
        set dy $panneau(meth_king,monture_dy)
        set cx $panneau(meth_king,cercle_cx)
        set cy $panneau(meth_king,cercle_cy)

        toplevel $audace(base).fenreglages2 -borderwidth 2 -relief groove -cursor crosshair

        wm title $audace(base).fenreglages2 $caption(king,fenetre_reglages_2)
        wm transient $audace(base).fenreglages2 $audace(base)
        wm protocol $audace(base).fenreglages2 WM_DELETE_WINDOW ::MethKing::Suppression

        if {$binning == 1} {
            set position_x [expr 0.9*[winfo screenwidth $audace(base).fenreglages2] - 768]
            set position_x [expr int($position_x)]
            if {$position_x < 150} {
                set position_x 150
            }
            set position_y [expr 0.9*[winfo screenheight $audace(base).fenreglages2] - 612]
            set position_y [expr int($position_y)]
            if {$position_x < 60} {
                set position_x 60
            }
            wm geometry $audace(base).fenreglages2 768x612+$position_x+$position_y
        } else {
            set position_x [expr 0.9*[winfo screenwidth $audace(base).fenreglages2] - 386]
            set position_x [expr int($position_x)]
            if {$position_x < 150} {
                set position_x 150
            }
            set position_y [expr 0.9*[winfo screenheight $audace(base).fenreglages2] - 356]
            set position_y [expr int($position_y)]
            if {$position_x < 60} {
                set position_x 60
            }
            wm geometry $audace(base).fenreglages2 386x356+$position_x+$position_y
        }

        label $audace(base).fenreglages2.texte_x -height 1 -justify left
        label $audace(base).fenreglages2.texte_y -height 1 -justify left
        set texte "Axe X :"
        if {$dx > 0} {
            append texte $::MethKing::king_config(textex+,$config_active)
        } else {
            append texte $::MethKing::king_config(textex-,$config_active)
        }
        $audace(base).fenreglages2.texte_x configure -text $texte
        set texte "Axe Y :"
        if {$dy > 0} {
            append texte $::MethKing::king_config(textey+,$config_active)
        } else {
            append texte $::MethKing::king_config(textey-,$config_active)
        }
        $audace(base).fenreglages2.texte_y configure -text $texte
        set a_executer "pack $audace(base).fenreglages2.texte_x $audace(base).fenreglages2.texte_y -side top -fill x -anchor nw"
        uplevel #0 $a_executer

        canvas $audace(base).fenreglages2.image1
        set a_executer "pack $audace(base).fenreglages2.image1 -in $audace(base).fenreglages2 -expand 1 -side top -anchor center -fill both"
        uplevel #0 $a_executer

        #  Récupération des dimensions de la fenetre
        tkwait visibility $audace(base).fenreglages2
        set largeur [$audace(base).fenreglages2.image1 cget -width]
        set hauteur [$audace(base).fenreglages2.image1 cget -height]

        #Empêche que cette fenêtre soit détruite
        # NE MARCHE PAS
        bind $audace(base).fenreglages2 <Destroy> {}

        # Par rapport à la façon "normale", image3 est créée dans la routine ::visu::create grace au 2ème paramètre de cette routine
        $audace(base).fenreglages2.image1 create image 1 1 -image image$num_buf -anchor nw -tag image_reglage
        $audace(base).fenreglages2.image1 create oval [expr $cx-15] [expr $cy-15] [expr $cx+16] [expr $cy+16] -outline $color(red) -width 2 -tag cercle_1
        $audace(base).fenreglages2.image1 create oval [expr $cx-5] [expr $cy-5] [expr $cx+6] [expr $cy+6] -outline $color(red) -width 2 -tag cercle_2

        #Tracé des curseurs "esclave"
        # Le signe - pour $panneau(meth_king,monture_dy) est du à l'inversion du sens y entre le canvas et l'image
        if {([expr abs($dx)] < $largeur) && ([expr abs($dy)] < $hauteur)} {
            $audace(base).fenreglages2.image1 create rect [expr $dx + $cx - 15] [expr $cy - 15 - $dy] [expr $dx + $cx + 16] [expr $cy + 16 - $dy] -outline $color(green) -width 2 -tag cercle_3
            $audace(base).fenreglages2.image1 create rect [expr $dx + $cx - 5] [expr $cy - 5 - $dy] [expr $dx + $cx + 6] [expr $cy + 6 - $dy] -outline $color(green) -width 1 -tag cercle_4
        } else {
            set dy [expr -$dy]
            if {$dx >0} {set x1 $largeur; set y1 [expr $cy+(($largeur-$cx)*$dy/$dx)]}
            if {$dx <0} {set x1 0; set y1 [expr $cy-($cx*$dy/$dx)]}
            if {$dx == 0} {
                set x1 $cx
                if {$dy > 0} {set y1 $hauteur} else {set y1 0}
            }

            if {$dy >0} {set y2 $hauteur; set x2 [expr $cx+(($hauteur-$cy)*$dx/$dy)]}
            if {$dy <0} {set y2 0;set x2 [expr $cx-($cy*$dx/$dy)]}
            if {$dy == 0} {
                set y2 $cy
                if {$cx > 0} {set x2 $largeur} else {set x2 0}
            }

            if {($y1 > $hauteur) || ($y1 < 0)} {
                set bx $x2
                set by $y2
            } else {
                set bx $x1
                set by $y1
            }

            set rho 0.8
            set ax [expr $cx + $rho*($bx-$cx)]
            set ay [expr $cy + $rho*($by-$cy)]

            $audace(base).fenreglages2.image1 create line $cx $cy $ax $ay -fill $color(green) -width 2 -arrow last -arrowshape {16 20 6}
        }
        set panneau(meth_king,pare_au_reglages) 23

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    #--------------------------------------------------------------------------#
    proc AfficheTimer {} {
    global panneau
    variable king_config

    Message infos "%d s" $panneau(meth_king,timer)
    incr panneau(meth_king,timer) -1
    if {$king_config(son,$panneau(meth_king,config_active)) != 0} {
        if {$panneau(meth_king,timer) == $king_config(son,$panneau(meth_king,config_active))} {
        bell
        }
    }
    if {$panneau(meth_king,timer) >0} {
        after 960 ::MethKing::AfficheTimer
    } else {
        Message infos ""
        set panneau(meth_king,timer_fin) -1
    }
    }

    #--------------------------------------------------------------------------#
    proc CalculeEcartPole {delta_x delta_y taille_pixel focale binning} {
    set delta_r [expr {sqrt([expr $delta_x*$delta_x + $delta_y*$delta_y])}]
    set echantillonage [expr $taille_pixel * $binning * 0.001]
    set echantillonage [expr $echantillonage / $focale]
    set echantillonage [expr atan($echantillonage)]
    set echantillonage [expr 180*60*$echantillonage/3.14159265]
    set ecart [expr $delta_r * $echantillonage]
    set ecart [format "%3.1f" $ecart]
    return $ecart
    }

    #--------------------------------------------------------------------------#
    proc EtatBoutons {etat} {
        variable This
        $This.boutons.bacquisition configure -state $etat
        $This.boutons.bcalcul configure -state $etat
        $This.boutons.breglage configure -state $etat
        $This.flisteconfig.configmb configure -state $etat
    }

    #--------------------------------------------------------------------------#
    proc printf {args} {
    ::console::disp [eval [concat {format} $args]]
    }

    #--------------------------------------------------------------------------#
    proc Suppression {} {
    # Empêche certaines fenêtres d'être effacées
    }

    #--------------------------------------------------------------------------#
    proc BoiteMessage {titre message} {
    tk_messageBox -type ok -title $titre -message $message -icon warning
    }

    #--------------------------------------------------------------------------#
    proc Message {niveau args} {
        variable This
        global caption
        global audace

        switch -exact -- $niveau {
            console {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
            }
            log {
                set temps $audace(tu,format,dmyhmsint)
                append temps " "
                puts -nonewline $::MethKing::log_id $temps
                puts -nonewline $::MethKing::log_id [eval [concat {format} $args]]
            }
            consolog {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
                set temps $audace(tu,format,dmyhmsint)
                append temps " "
                puts -nonewline $::MethKing::log_id $temps
                puts -nonewline $::MethKing::log_id [eval [concat {format} $args]]
            }
            avertissement {
                ::console::disp $caption(king,attention)
                ::console::disp " : "
                ::console::disp [eval [concat {format} $args]]
                update idletasks
                puts -nonewline $::MethKing::log_id $caption(king,attention)
                puts -nonewline $::MethKing::log_id  " : "
                puts -nonewline $::MethKing::log_id [eval [concat {format} $args]]
            }
            erreur {
                ::console::disp $caption(king,erreur)
                ::console::disp " : "
                ::console::disp [eval [concat {format} $args]]
                update idletasks
                puts -nonewline $::MethKing::log_id $caption(king,erreur)
                puts -nonewline $::MethKing::log_id " : "
                puts -nonewline $::MethKing::log_id [eval [concat {format} $args]]
            }
            test {
                ::console::disp $caption(king,test)
                ::console::disp " : "
                ::console::disp [eval [concat {format} $args]]
                update idletasks
                puts -nonewline $::MethKing::log_id $caption(king,test)
                puts -nonewline $::MethKing::log_id " : "
                set temps $audace(tu,format,dmyhmsint)
                append temps " "
                puts -nonewline $::MethKing::log_id $temps
                puts -no newline $::MethKing::log_id [eval [concat {format} $args]]
            }
            status {
                set panneau(meth_king,status) [eval [concat {format} $args]]
                $This.fstatus.m configure -text $panneau(meth_king,status)
                update
            }
            infos {
                set panneau(meth_king,infos) [eval [concat {format} $args]]
                $This.finfos.m configure -text $panneau(meth_king,infos)
                update idletasks
            }
            default {
                ::console::disp $caption(king,erreur_message)
                ::console::disp "\n"
                update idletasks
            }
        }
    }
}
#-----Fin du namespace MethKing--------------------------------------------#


#--------------------------------------------------------------------------#
proc MethKingBuildIF {This tableau} {
    # ============================
    # === graphisme du panneau ===
    # ============================
    global audace panneau caption

    #--- Trame du panneau
    frame $This -borderwidth 2 -height 75 -width 101 -borderwidth 2 -relief groove

    #--- Trame du titre du panneau
    frame $This.ftitre -borderwidth 2 -height 75 -relief groove -width 92

    #--- Label du titre
    Button $This.ftitre.l -borderwidth 2 -text $panneau(menu_name,MethKing) \
       -command {
          ::audace::showHelpPlugin tool methking methking.htm
       }
    pack $This.ftitre.l -in $This.ftitre -anchor center -expand 1 -fill both -side top
    DynamicHelp::add $This.ftitre.l -text $caption(king,help,titre)
    place $This.ftitre -x 4 -y 4 -width 92 -height 22 -anchor nw -bordermode ignore

    #Trame d'affichage des paramètres
    set t1 [frame $This.flisteconfig -borderwidth 1 -height 100 -relief groove]

    menubutton $t1.configmb -text $caption(king,parametres) -menu $t1.configmb.menu -height 1 -relief raised
    bind $t1.configmb <Button-1> {+ ::MethKing::ModifieFenetreParametres}
    pack $t1.configmb -in $t1 -pady 4

    set mc [menu $t1.configmb.menu -tearoff 0]
    $mc add separator
    $mc add command -label $caption(king,edition) -command ::MethKing::EditeConfig

    place $t1 -x 4 -y 32 -width 92 -anchor nw -bordermode ignore

    # Trame des boutons
    set t2 [frame $This.boutons -borderwidth 1 -relief groove]
    set commande(acquisition) ::MethKing::CmdAcquisition
    set commande(calcul) ::MethKing::CmdCalcul
    set commande(reglage) ::MethKing::CmdReglage

    foreach champ {acquisition calcul reglage} {
    button $t2.b$champ -borderwidth 1 -text $caption(king,$champ) -command $commande($champ) -width 10 -relief raised
    pack $t2.b$champ -in $t2 -anchor center -fill none -pady 4 -ipady 4
    }
    place $t2 -x 4 -y 74 -width 92  -anchor nw -bordermode ignore

    # Bouton d'arrêt
    frame $audace(base).methking.stop -borderwidth 1 -relief groove
    button $audace(base).methking.stop.b -borderwidth 1 -text $caption(king,arret) -state disabled -width 10
    pack $audace(base).methking.stop.b -in $audace(base).methking.stop -anchor center -fill none -pady 4 -ipady 4
    place $audace(base).methking.stop -x 4 -y 209 -width 92  -anchor nw -bordermode ignore

    # Affichage des status
    frame $This.fstatus -borderwidth 1 -height 77 -relief groove
    label  $This.fstatus.l1 -text $caption(king,label_status) -font {times 12 bold} -relief flat -height 1
    pack   $This.fstatus.l1 -in $This.fstatus -anchor center -fill both -padx 0 -pady 0
    label  $This.fstatus.m -text $panneau(meth_king,status) -font {times 12 bold} -justify center -padx 0 -pady 0 -relief flat -width 11 -height 3 -wraplength 88
    pack   $This.fstatus.m -in $This.fstatus -anchor center -fill both -padx 0 -pady 0
    place $This.fstatus -x 4 -y 259 -width 92 -anchor nw -bordermode ignore

    # Affichage des infos
    frame $This.finfos -borderwidth 1 -relief groove
    label  $This.finfos.m -text $panneau(meth_king,infos) -justify center -padx 0 -pady 0 -relief flat -font {times 12 bold} -width 11 -height 2 -wraplength 88
    pack   $This.finfos.m -in $This.finfos -anchor center -fill both -padx 0 -pady 0
    place $This.finfos -x 4 -y 360 -width 92 -anchor nw -bordermode ignore
}

# =================================
# === initialisation du panneau ===
# =================================
global audace
::MethKing::Init $audace(base)

# === fin du fichier methking.tcl ===

