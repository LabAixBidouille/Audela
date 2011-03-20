##
# @file photometrie.tcl
#
# @author Jacques Michelet (jacques.michelet@aquitania.org)
#
# @brief Outil pour l'analyse photométrique d'une image.
#
# $Id$
#

namespace eval ::Photometrie {
    variable photometrie
    global ::Photometrie::attente_aladin
    global ::Photometrie::selection_aladin

    catch { unset photometrie }

    ##
    # @brief Séquencement principal des opérations
    proc Principal {} {
        variable photometrie_texte
        variable photometrie

        Initialisations
        if { [ PresenceImage ] < 0 } { return }
        AnalyseEnvironnement
        AnalyseImage
        ChoixManuelAutomatique

        set erreur 0
        switch -exact -- $photometrie(choix_mode) {
            arret { return }
            auto_internet { set erreur [ ModeAutoInternet ] }
            manuel { set erreur [ ModeManuel ] }
        }

        if { $erreur != 0 } { return }
        PhotometrieEcran
    }

    ##
    # @brief initialisation de valeurs par défaut
    proc Initialisations {} {
        variable photometrie
        set photometrie(defaut,diametre,interieur) 2.25
        set photometrie(defaut,diametre,exterieur1) 6.0
        set photometrie(defaut,diametre,exterieur2) 8.0
        set photometrie(defaut,carre,modelisation) 3.0

        set photometrie(champ,nomad1) [ list RAJ2000 DEJ2000 NOMAD1 Bmag Rmag ]
        set photometrie(champ,usnob1) [ list RAJ2000 DEJ2000 USNO-B1.0 B1mag R1mag ]

        set photometrie(mode_debug) 0
        calaphot_niveau_traces 0
    }

    ##
    # @brief Vérifie que Java et Aladin sont utilisables sur la machine
    proc AnalyseEnvironnement {} {
        variable photometrie_texte
        variable photometrie

        set photometrie(internet) 0
        if { [ file exists $::conf(exec_aladin) ] } {
            if { ( [ file executable $::conf(exec_aladin) ] ) && ( [ file extension $::conf(exec_aladin) ] == ".exe" ) } {
                # Mode windows, avec aladin.exe
                set photometrie(internet) 1
                set photometrie(mode_aladin) exe
            } else {
                # On a un aladin.jar qui requiert java
                if { [ file exists $::conf(exec_java) ] && [ file executable $::conf(exec_java) ] } {
                    # On teste la version de aladin.jar
                    set retour_version [ exec $::conf(exec_java) -jar $::conf(exec_aladin) -version ]
                    set version_aladin [ string range [ lindex $retour_version 2 ] 1 end ]
                    if { $version_aladin > 7.0 } {
                        set photometrie(internet) 1
                        set photometrie(mode_aladin) jar
                    } else {
                        ::console::affiche_erreur "$photometrie_texte(err_version_aladin) \n"
                        set photometrie(internet) 0
                    }
                } else {
                    ::console::affiche_erreur "$photometrie_texte(err_java) \n"
                    set photometrie(internet) 0
                }
            }
        } else {
            ::console::affiche_erreur "$photometrie_texte(err_aladin) \n"
            set photometrie(internet) 0
        }
    }

    ##
    # @brief Détecte la présence d'une image valide
    # @param[out] photometrie(astrometrie) = 1 si l'image contient tous les mot-clés, 0 sinon
    # @return -1 si l'image est absente ou non pertinente
    proc PresenceImage {} {
        variable photometrie_texte
        variable photometrie

        #--- Recherche une image dans le buffer
        if { [ buf$::audace(bufNo) imageready ] == "0" } {
            tk_messageBox -message "$photometrie_texte(err_pas_d_image)" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }

        #--- Recherche du type d'image
        if { [ lindex [ buf$::audace(bufNo) getkwd NAXIS ] 1 ] == "1" } {
            tk_messageBox -message "$photometrie_texte(err_spectro)" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }
        return 0
    }

    ##
    # @brief Calcul du champ couvert par l'image
    # return : le champ en arcmin sur la plus grande dimension
    proc CalculChampImage {} {
        variable photometrie

        # Récupération des coordonnées et du champ
        set res [ buf$::audace(bufNo) xy2radec [ list [ expr $photometrie(naxis1) / 2 ] [ expr $photometrie(naxis2) / 2 ] ] ]
        set ra [ mc_angle2hms [ lindex $res 0 ] ]
        set dec [ mc_angle2dms [ lindex $res 1 ] 90 ]
        set coords "$ra $dec"

        set tgte1 [ expr $photometrie(naxis1) * $photometrie(pixsize1) * 1e-6 / $photometrie(foclen) ]
        set tgte2 [ expr $photometrie(naxis2) * $photometrie(pixsize2) * 1e-6 / $photometrie(foclen) ]
        set champ1 [ expr atan($tgte1) ]
        set champ2 [ expr atan($tgte2) ]
        # Conversion de radian en minutes d'arc
        if { $champ1 > $champ2 } {
            set champarcmin [ expr round( $champ1 * 3437.75 ) ]
        } else {
            set champarcmin [ expr round( $champ2 * 3437.75 ) ]
        }
        return $champarcmin
    }

    ##
    # @brief Recherche de mots-clés typiques d'une image recalée astrométriquement
    # @param[out] photometrie(astrometrie) = 1 si l'image contient tous les mot-clés, 0 sinon
    # @param[out] photometrie(internet) si le champ a une taille inférieure à 30 min d'arc
    proc AnalyseImage {} {
        variable photometrie_texte
        variable photometrie

        set photometrie(astrometrie) 1
        set liste_cle [ buf$::audace(bufNo) getkwds ]
        foreach cle_majuscule [ list NAXIS1 NAXIS2 CRVAL1 CRVAL2 CRPIX1 CRPIX2 CROTA2 PIXSIZE1 PIXSIZE2 FOCLEN ] {
            set cle [ string tolower $cle_majuscule ]
            if { [ lsearch -exact $liste_cle $cle_majuscule ] > 0 } {
                set photometrie($cle) [ lindex [ buf$::audace(bufNo) getkwd $cle_majuscule ] 1 ]
            } else {
                ::console::affiche_erreur "$photometrie_texte(err_pas_astrometrie) $cle_majuscule\n"
                set photometrie(astrometrie) 0
                break
            }
        }

        set fwhm [ buf$::audace(bufNo) fwhm [ list 1 1 $photometrie(naxis1) $photometrie(naxis1) ] ]
        set photometrie(fwhm) [ expr ( [ lindex $fwhm 0 ] + [ lindex $fwhm 1 ] ) / 2 ]

        # A SUPPRIMER
        # set photometrie(fwhm) 1.0


        if { $photometrie(astrometrie) == 1 } {
            set champ [ CalculChampImage ]
            # Limite à 30 minutes d'arc
            if { $champ > 30 } {
                ::console::affiche_erreur "$photometrie_texte(err_champ_trop_large) : $champ ' \n"
                set photometrie(internet) 0
            }
        }
    }


    ##
    # @brief Colorie l'étoile sélectionnée en vert, les autres en rouge.
    # @detail Très important pour la suite : stocke l'id de l'étoile sélectionnée.
    proc AnimationSelectionCatalogue { fen id } {
        variable photometrie

        # Animation sur l'image
        $::audace(hCanvas) itemconfigure ovale_$photometrie(ancienne_selection) -outline red
        $::audace(hCanvas) itemconfigure texte_$photometrie(ancienne_selection) -fill red
        $::audace(hCanvas) itemconfigure ovale_$photometrie(selection_aladin) -outline green
        $::audace(hCanvas) itemconfigure texte_$photometrie(selection_aladin) -fill green

        # Animation sur la fenêtre de sélection
        ::confColor::applyColor $fen
        ${fen}.${photometrie(selection_aladin)}_$photometrie(selection_couleur) configure -foreground blue

        set photometrie(ancienne_selection) $photometrie(selection_aladin)
        set photometrie(selection,id) $id
    }

    ##
    # @brief Affichage des valeurs de photométrie (référence et variable)
    # @return id de la fenetre d'affichage
    proc CadreMesurePhotometrie {} {
        variable photometrie_texte
        variable photometrie
        variable data

        set zoom [ visu$::audace(visuNo) zoom ]
        set fwhm $photometrie(fwhm)

        set xy $photometrie(reference,xy)
        set x [ expr round( [ lindex $xy 0 ] ) ]
        set y [ expr round( [ lindex $xy 1 ] ) ]
        $::audace(hCanvas) create text \
            [ expr $x * $zoom ] \
            [ expr ( $photometrie(naxis2) - $y ) * $zoom - 3 * $fwhm ] \
            -text $photometrie(reference,nom) \
            -tag photom \
            -fill red \
            -anchor n \

        set tl [ toplevel $::audace(base).photometrie_mesure \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlf1 [ frame $tl.f1 ]

        set tlf1f1 [ frame $tlf1.f1 -borderwidth 1 -relief solid ]
        set tlf1f1l [ label $tlf1f1.l ]
        grid $tlf1f1l -columnspan 2
        set tlf1f1l00 [ label $tlf1f1.l00 ]
        set tlf1f1l01 [ label $tlf1f1.l01 \
            -text $photometrie_texte(nom) ]
        grid $tlf1f1l00 $tlf1f1l01
        set tlf1f1l10 [ label $tlf1f1.l10 \
            -text $photometrie_texte(reference) ]
        set tlf1f1l11 [ label $tlf1f1.l11 \
            -text $photometrie(reference,nom) ]
        grid $tlf1f1l10 $tlf1f1l11
        set tlf1f1l20 [ label $tlf1f1.l20 \
            -text $photometrie_texte(mesure) ]
        set tlf1f1l21 [ label $tlf1f1.l21 ]
        grid $tlf1f1l20 $tlf1f1l21

        set tlf1f2 [ frame $tlf1.f2  -borderwidth 1 -relief solid ]
        set tlf1f2l [ label $tlf1f2.l \
            -text $photometrie_texte(ouverture) ]
        grid $tlf1f2l -columnspan 2
        set tlf1f2l00 [ label $tlf1f2.l00 \
            -text $photometrie_texte(magnitude) ]
        set tlf1f2l01 [ label $tlf1f2.l01 \
            -text $photometrie_texte(flux) ]
        grid $tlf1f2l00 $tlf1f2l01
        set tlf1f2l10 [ label $tlf1f2.color_invariant_l10 \
            -text $photometrie(reference,magnitude) \
            -fg red \
            -bg $::audace(color,backColor) ]
        set tlf1f2l11 [ label $tlf1f2.color_invariant_l11 \
            -text "---" \
            -fg red \
            -bg black ]
        grid $tlf1f2l10 $tlf1f2l11
        set tlf1f2l20 [ label $tlf1f2.color_invariant_l20 \
            -text "---" \
            -fg red \
            -bg black ]
        set tlf1f2l21 [ label $tlf1f2.color_invariant_l21 \
            -text "---" \
            -fg red \
            -bg black ]
        grid $tlf1f2l20 $tlf1f2l21
        set photometrie(label_flux_ouv_ref) $tlf1f2l11
        set photometrie(label_flux_ouv_inc) $tlf1f2l21
        set photometrie(label_mag_ouv_inc) $tlf1f2l20

        set tlf1f3 [ frame $tlf1.f3  -borderwidth 1 -relief solid ]
        set tlf1f3l [ label $tlf1f3.l \
            -text $photometrie_texte(modelisation) ]
        grid $tlf1f3l -columnspan 2
        set tlf1f3l00 [ label $tlf1f3.l00 \
            -text $photometrie_texte(magnitude) ]
        set tlf1f3l01 [ label $tlf1f3.l01 \
            -text $photometrie_texte(flux) ]
        grid $tlf1f3l00 $tlf1f3l01
        set tlf1f3l10 [ label $tlf1f3.color_invariant_l10 \
            -text $photometrie(reference,magnitude) \
            -fg DarkGreen \
            -bg $::audace(color,backColor) ]
        set tlf1f3l11 [ label $tlf1f3.l_color_invariant_11 \
            -text "---" \
            -fg green \
            -bg black ]
        grid $tlf1f3l10 $tlf1f3l11
        set tlf1f3l20 [ label $tlf1f3.color_invariant_l20 \
            -text "---" \
            -fg green \
            -bg black ]
        set tlf1f3l21 [ label $tlf1f3.color_invariant_l21 \
            -text "---" \
            -fg green \
            -bg black ]
        grid $tlf1f3l20 $tlf1f3l21
        set photometrie(label_flux_mod_ref) $tlf1f3l11
        set photometrie(label_flux_mod_inc) $tlf1f3l21
        set photometrie(label_mag_mod_inc) $tlf1f3l20

        grid $tlf1f1 $tlf1f2 $tlf1f3
        grid $tlf1

        set tlf2 [ frame $tl.f2 \
            -borderwidth 1 \
            -relief solid ]
        set tlf2ltitre [ label $tlf2.ltitre \
            -text $photometrie_texte(param_ouv) ]
        grid $tlf2ltitre -columnspan 2
        foreach champ [ list interieur exterieur1 exterieur2 ] {
            label $tlf2.l$champ \
                -text $photometrie_texte($champ)
            entry $tlf2.e$champ \
                -textvariable ::Photometrie::photometrie(diametre,$champ) \
                -width -1 \
                -relief sunken
            $tlf2.e$champ delete 0 end
            $tlf2.e$champ insert 0 $photometrie(defaut,diametre,$champ)
            bind $tlf2.e$champ <Return> { ::Photometrie::ChangementsCercles %W }
            grid $tlf2.l$champ $tlf2.e$champ
        }
        grid $tlf2

        set tlf3 [ frame $tl.f3 \
            -borderwidth 5 \
            -relief groove ]

        set tlf3b [ button $tlf3.b \
            -text $photometrie_texte(fin) \
            -command {
                $::audace(hCanvas) delete photom
                bind $::audace(hCanvas) <Motion> {}
                bind $::audace(hCanvas) <ButtonRelease> {}
                $::audace(hCanvas) configure -cursor $::Photometrie::photometrie(fleche_souris)
                catch { unset ::Photometrie::data }
                unset ::Photometrie::photometrie
                destroy $::audace(base).photometrie_mesure
            } ]
        pack $tlf3b \
            -side left \
            -padx 10 \
            -pady 10
        grid $tlf3

        ::confColor::applyColor $tl
        update idletasks

        return $tl
    }

    ##
    # @brief Calcul sur l'objet pointé par la souris
    # @param canevas sur lequel s'éxécute le mouvement
    # @param abscisse de la souris dans le canevas (repère écran)
    # @param ordonnee de la souris dans le canevas (repère écran)
    proc CalculFluxMagnitude { canevas xe ye } {

        set xe [ $canevas canvasx $xe ]
        set ye [ $canevas canvasy $ye ]

        set xyi [ ConvEcranImage [ list $xe $ye ] ]
        MesureFlux inc $xyi
        CalculMagnitude
    }

    proc CalculMagnitude {} {
        variable photometrie

        if { ( [ lindex $photometrie(flux_mod_ref) 0 ] > 0 ) && ( [ lindex $photometrie(flux_mod_inc) 0 ]  > 0 ) } {
            set photometrie(magnitude_inc,mod) [ expr $photometrie(reference,magnitude) + 2.5 * log10( [ lindex $photometrie(flux_mod_ref) 0 ] / [ lindex $photometrie(flux_mod_inc) 0 ] ) ]
            $photometrie(label_mag_mod_inc) configure -text [ format "%.3f" $photometrie(magnitude_inc,mod) ]
        } else {
            set photometrie(magnitude_inc,mod) 99
            $photometrie(label_mag_mod_inc) configure -text "???"
        }

        if { ( $photometrie(flux_ouv_ref) > 0 ) && ( $photometrie(flux_ouv_inc)  > 0 ) } {
            set photometrie(magnitude_inc,ouv) [ expr $photometrie(reference,magnitude) + 2.5 * log10( $photometrie(flux_ouv_ref) / $photometrie(flux_ouv_inc) ) ]
            $photometrie(label_mag_ouv_inc) configure -text [ format "%.3f" $photometrie(magnitude_inc,ouv) ]
        } else {
            set photometrie(magnitude_inc,ouv) 99
            $photometrie(label_mag_ouv_inc) configure -text "???"
        }
    }

    ##
    # @brief Prise en compte des modifications de la taille des cercles d'ouverture
    proc ChangementsCercles { entree } {
        variable photometrie_texte
        variable photometrie

        set valeur_ok 1
        foreach cercle [ list interieur exterieur1 exterieur2 ] {
            set valeur $photometrie(diametre,$cercle)
            if { [ string is integer -strict $valeur ] || [ string is double -strict $valeur ] } {
                if { $valeur <= 0 } {
                    set valeur_ok 0
                }
            } else {
                set valeur_ok 0
            }
        }

        if { $valeur_ok == 0 } {
            tk_messageBox -message $photometrie_texte(err_nombre_positif) -title "$photometrie_texte(titre_menu)" -icon error
            $entree delete 0 end
            return
        }

        if { $photometrie(diametre,interieur) > $photometrie(diametre,exterieur1) } {
            tk_messageBox -message $photometrie_texte(err_dia_interieur) -title "$photometrie_texte(titre_menu)" -icon error
            $entree delete 0 end
            return
        }

        if { $photometrie(diametre,exterieur1) >= $photometrie(diametre,exterieur2) } {
            tk_messageBox -message $photometrie_texte(err_dia_exterieur) -title "$photometrie_texte(titre_menu)" -icon error
            $entree delete 0 end
            return
        }

        # Récupération des coordonnées des tags
        set boite [ $::audace(hCanvas) bbox ref ]
        set xe [ expr ( [ lindex $boite 0 ] + [ lindex $boite 2 ] ) / 2 ]
        set ye [ expr ( [ lindex $boite 1 ] + [ lindex $boite 3 ] ) / 2 ]
        DessinCercles ref [ list $xe $ye ]
        set xyi [ ConvEcranImage [ list $xe $ye ] ]
        MesureFlux ref $xyi

        set boite [ $::audace(hCanvas) bbox inc ]
        set xe [ expr ( [ lindex $boite 0 ] + [ lindex $boite 2 ] ) / 2 ]
        set ye [ expr ( [ lindex $boite 1 ] + [ lindex $boite 3 ] ) / 2 ]
        DessinCercles inc [ list $xe $ye ]
        set xyi [ ConvEcranImage [ list $xe $ye ] ]
        MesureFlux inc $xyi
        CalculMagnitude
    }

    ##
    # @brief Permet de choisir entre le catalogue internet
    # @return photometrie(cata_internet)
    proc ChoixCatalogueInternet {} {
        variable photometrie_texte
        variable photometrie

        set tl [ toplevel $::audace(base).photometrie_cata_internet \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlf1 [ frame $tl.f1 \
            -borderwidth 5 \
            -relief groove ]

        set photometrie(cata_internet) nomad1
        foreach cata_internet [ list usnob1 nomad1 ] {
            radiobutton $tlf1.rb_$cata_internet -variable ::Photometrie::photometrie(cata_internet) -text $photometrie_texte($cata_internet) -value $cata_internet
            pack $tlf1.rb_$cata_internet -fill both -expand true
        }

        set tlf2 [ frame $tl.f2 \
            -borderwidth 5 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command {
                destroy $::audace(base).photometrie_cata_internet
            } ]
        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(choix_mode) arret
                destroy $::audace(base).photometrie_cata_internet
            } ]
        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        pack $tlf1 $tlf2

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $tl
        update idletasks

        tkwait window $tl
    }

    ##
    # @brief Permet de choisir entre le mode manuel, le mode catalogue local (plus tard) ou le mode catalogue internet
    proc ChoixManuelAutomatique {} {
        variable photometrie_texte
        variable photometrie

        # Si pas de racalage astrométrique, pas de possibilité de récupérer un catalogue local ou distant
        if { $photometrie(astrometrie) == 0 } {
            ::console::affiche_erreur "$photometrie_texte(err_pas_internet) \n"
            set photometrie(choix_mode) manuel
            return
        }

        # Temporaire en attendant le mode catalogue local qui pourra être valide
        if { $photometrie(internet) == 0 } {
            ::console::affiche_erreur "$photometrie_texte(err_pas_internet) \n"
            set photometrie(choix_mode) manuel
            return
        }

        set tl [ toplevel $::audace(base).photometrie_auto_manuel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlf1 [ frame $tl.f1 \
            -borderwidth 5 \
            -relief groove ]

        set photometrie(choix_mode) manuel
        set liste_choix [ list manuel ]
        if { $photometrie(internet) == 1 } {
            lappend liste_choix auto_internet
            set photometrie(choix_mode) auto_internet
        }

        # Si le choix est réduit, pas d'écran de sélection
        if { [ llength $liste_choix ] == 1 } {
            set photometrie(choix_mode) manuel
            destroy $tl
            return
        }

        foreach choix $liste_choix {
            radiobutton $tlf1.rb_$choix -variable ::Photometrie::photometrie(choix_mode) -text $photometrie_texte($choix) -value $choix
            pack $tlf1.rb_$choix -fill both -expand true
        }

        set tlf2 [ frame $tl.f2 \
            -borderwidth 5 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command {
                destroy $::audace(base).photometrie_auto_manuel
            } ]
        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(choix_mode) arret
                destroy $::audace(base).photometrie_auto_manuel
            } ]
        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        pack $tlf1 $tlf2

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $tl
        update idletasks

        tkwait window $tl
    }

    ##
    # @brief Transformation de coordonnées écran (canevas) en coordonnées image
    # @param liste des coordonnées dans le repère écran
    # @return liste des coordonnées dans le repère image
    proc ConvEcranImage { xye } {
        variable photometrie_texte
        variable photometrie

        set zoom [ visu$::audace(visuNo) zoom ]
        set xi [ expr [ lindex $xye 0 ] / $zoom ]
        set yi [ expr $photometrie(naxis2) - [ lindex $xye 1 ] / $zoom ]
        return [ list $xi $yi ]
    }

    ##
    # @brief Transformation de coordonnées image en coordonnées écran (canevas)
    # @param liste des coordonnées dans le repère image
    # @return liste des coordonnées dans le repère écran
    proc ConvImageEcran { xyi } {
        variable photometrie

        set zoom [ visu$::audace(visuNo) zoom ]
        set xe [ expr [ lindex $xyi 0 ] * $zoom ]
        set ye [ expr ( $photometrie(naxis2) - [ lindex $xyi 1 ] ) * $zoom ]
        return [ list $xe $ye ]
    }

    ##
    # @brief Lecture de la première ligne du fichier pour trouver la position des champs
    # @param canal du fichier catalogue
    # @return 0 si on trouve tous les champs, -1 sinon
    proc RecherchePositionDonnees { fichier } {
        variable photometrie

        set catalogue $photometrie(cata_internet)

        if { [ gets $fichier ligne ] <= 0 } {
            return -1
        }
        set liste_ligne [ split $ligne \t ]
        set probleme 0
        foreach champ_catalogue $photometrie(champ,$catalogue) champ_script [ list ad dec nom mag_b mag_r ] {
            set t [ lsearch -exact $liste_ligne $champ_catalogue ]
            if { $t < 0 } {
                set probleme -1
            } else {
                set photometrie(position,$catalogue,$champ_script) $t
            }
        }
        return $probleme
    }

    ##
    # @brief Lecture du catalogue, et création d'une base de donnée indexée par les magnitudes
    # @return -1 en cas de probleme, 0 sinon
    proc CreationBaseDonnées {} {
        variable photometrie
        variable photometrie_texte

        set catalogue $photometrie(cata_internet)

        catch { unset data }
        catch { unset index_rouge }
        catch { unset index_bleu }

        variable data
        variable index_rouge
        variable index_bleu

        set uid 0
        if { [ catch { open $photometrie(catalogue) r } f ] } {
            tk_messageBox -message "$f" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }
        if { [ RecherchePositionDonnees $f ] < 0 } {
            tk_messageBox -message "$photometrie_texte(err_champ_catalogue)" -title "$photometrie_texte(titre_menu)" -icon error
            close $f
            return -1
        }
        set indice 0
        while { [ gets $f ligne ] > 0 } {
            set liste_ligne [ split $ligne \t ]
            # Message console "%s\n" $liste_ligne
            set cle_rouge [ lindex $liste_ligne $photometrie(position,$catalogue,mag_r) ]
            set cle_bleue [ lindex $liste_ligne $photometrie(position,$catalogue,mag_b) ]
            # Message console "cr %s\n" $cle_rouge
            # Base à double clé
            # index_rouge a pour clé la magnitude rouge, et pour valeur un id unique (idem pour index_bleu)
            # data a pour clé l'id unique, et contient toutes les données du catalogue.
            # Donc, on peut, à partir de la magnitude rouge (ou bleue), retrouver toutes les données d'une étoile dans le catalogue.
            set data([ incr uid ]) $liste_ligne
            # Il faut que les 2 magnitudes rouge et bleue soient définies pour qu'on stocke l'id de l'étoile
            if { [ string is double -strict $cle_rouge ] && [ string is double -strict $cle_bleue ] } {
                lappend index_rouge($cle_rouge) $uid
                lappend index_bleu($cle_bleue) $uid
            }
        }
        close $f
        if { $photometrie(mode_debug) == 0 } {
            # Toutes les données sont dans data(), plus besoin du fichier catalogue
            file delete $photometrie(catalogue)
            # Là, on est sur que Aladin s'est bien terminé, puisqu'on a pu lire le catalogue
            file delete $photometrie(script_aladin)
        }

        return 0
    }

    ##
    # @brief Dessin des cercles représentant les ouvertures
    # @param liste des coordonnées dans le repère écran
    proc DessinCercles { tag xy } {
        variable photometrie

        $::audace(hCanvas) delete $tag

        set zoom [ visu$::audace(visuNo) zoom ]
        set fwhm $photometrie(fwhm)

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]
        foreach cercle [ list interieur exterieur1 exterieur2 ] {
            set rayon [ expr $photometrie(diametre,$cercle) * $fwhm / 2 *$zoom ]
            $::audace(hCanvas) create oval \
                [ expr $x - $rayon ] \
                [ expr $y + $rayon ] \
                [ expr $x + $rayon ] \
                [ expr $y - $rayon ] \
                -outline red \
                -width 1 \
                -tags [ list photom $tag $cercle ]
        }
        $::audace(hCanvas) itemconfigure exterieur1 -dash { 3 6 3 3 }
        $::audace(hCanvas) itemconfigure exterieur2 -dash { 3 6 3 3 }

        set demi_largeur [ expr $photometrie(defaut,carre,modelisation) * $fwhm / 2 *$zoom ]
        $::audace(hCanvas) create rectangle \
            [ expr $x - $demi_largeur ] \
            [ expr $y + $demi_largeur ] \
            [ expr $x + $demi_largeur ] \
            [ expr $y - $demi_largeur ] \
            -outline green \
            -width 1 \
            -tags [ list photom $tag carre ]
    }

    ##
    # @brief Gestion des retours de Aladin
    # @param canal : canal de comm (ou "pipe")
    # @param mode : fermé si la minuterie a déclenché, ouvert sinon
    #
    proc AttenteAladin { canal mode } {
        variable attente
        variable photometrie
        if { $mode == "ouvert" } {
            if { [ eof $canal ] } {
                if { [ file exists $photometrie(catalogue) ] } {
                    set ::Photometrie::attente ok
                } else {
                    set ::Photometrie::attente probleme
                }
                catch { close $canal }
            } else {
                if { [ gets $canal data ] > 0 } {
                    ::console::affiche_erreur "$data \n"
                }
            }
        } else {
            set ::Photometrie::attente trop_tard
            close $canal
        }
    }

    ##
    # @brief Exécution de Aladin en mode non bloquant
    # @param nom du fichier script Aladin à exécuter.
    # @return -1 en cas d'échec, 0 sinon
    proc ExecutionAladin { script_aladin temps_attente_max } {
        variable canal
        variable attente
        variable photometrie

        set attente rien
        if { $photometrie(mode_aladin) == "jar" } {
            set commande "\"$::conf(exec_java)\" -jar \"$::conf(exec_aladin)\" -script \"$script_aladin\" 2>@1"
        } else {
            # mode aladin.exe
            set commande "\"$::conf(exec_aladin)\" -script \"$script_aladin\" 2>@1"
        }
        set canal [ open "| $commande" r ]
        fconfigure $canal -blocking 0 -encoding binary
        fileevent $canal readable { ::Photometrie::AttenteAladin $::Photometrie::canal ouvert }
        set troptard [ after $temps_attente_max { ::Photometrie::AttenteAladin $::Photometrie::canal ferme } ]

        vwait ::Photometrie::attente
        after cancel $troptard
        if { $attente == "ok" } {
            return 0
        } else {
            return -1
        }

    }

    ##
    # @brief Mise en place des évènements souris
    proc GestionSouris {} {
        variable photometrie_texte
        variable photometrie

        set xy_image [ list 1 1 ]
        set xy_ecran [ ConvImageEcran $xy_image ]
        DessinCercles inc $xy_ecran
        set photometrie(coord_souris) $xy_ecran
        set photometrie(fleche_souris) [ $::audace(hCanvas) cget -cursor ]
        $::audace(hCanvas) configure -cursor { tcross blue }
        bind $::audace(hCanvas) <Motion> { ::Photometrie::MouvementSouris %W %x %y }
        bind $::audace(hCanvas) <ButtonRelease> { ::Photometrie::CalculFluxMagnitude %W %x %y }
    }

    ##
    # @brief Génération du script pour Aladin et lancement de l'exécution
    # @return -1 en cas d'échec, 0 sinon
    proc InterfaceAladin {} {
        global ::Photometrie::attente_aladin
        global ::Photometrie::selection_aladin
        variable photometrie_texte
        variable photometrie

        set erreur 0
        set photometrie(catalogue) [ file join $::audace(rep_travail) photometrie.txt ]
        file delete $photometrie(catalogue)

        # Récupération des coordonnées et du champ
        set res [ buf$::audace(bufNo) xy2radec [ list [ expr $photometrie(naxis1) / 2 ] [ expr $photometrie(naxis2) / 2 ] ] ]
        set ra [ mc_angle2hms [ lindex $res 0 ] ]
        set dec [ mc_angle2dms [ lindex $res 1 ] 90 ]
        set coords "$ra $dec"

        set tgte1 [ expr $photometrie(naxis1) * $photometrie(pixsize1) * 1e-6 / $photometrie(foclen) ]
        set tgte2 [ expr $photometrie(naxis2) * $photometrie(pixsize2) * 1e-6 / $photometrie(foclen) ]
        set champ1 [ expr atan($tgte1) ]
        set champ2 [ expr atan($tgte2) ]
        # Conversion de radian en minutes d'arc
        if { $champ1 > $champ2 } {
            set champarcmin [ expr round( $champ1 * 3437.75 ) ]
        } else {
            set champarcmin [ expr round( $champ2 * 3437.75 ) ]
        }

        switch -exact -- $photometrie(cata_internet) {
            usnob1 { set catalog Vizier(I/284) }
            ucac2 { set catalog Vizier(I/289) }
            nomad1 { set catalog VizieR(NOMAD1) }
        }

        # Création du script Aladin
        catch { unset texte }
        append texte "analyse_photo=get $catalog $coords ${champarcmin}'\n"
        append texte "sync\n"
        append texte "export analyse_photo $photometrie(catalogue)\n"
        append texte "quit\n"

        set script_aladin [ file join $::audace(rep_travail) photometrie.ajs ]
        set f [ open "$script_aladin" w ]
        puts -nonewline $f $texte
        close $f
        set photometrie(script_aladin) $script_aladin

        # Calcul du temps d'attente max
        # Empirisme : 2s pour minute d'arc
        set temps_attente_max [ expr $champarcmin * 2000 ]

        # Fenêtre informative pour faire patienter
        set tl [ toplevel $::audace(base).photometrie_exec_aladin \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace
        label $tl.l1 -text "$photometrie_texte(temps_attente_aladin) [ expr $temps_attente_max / 1000 ] s"
        label $tl.l2 -text $photometrie_texte(patience)
        pack $tl.l1 $tl.l2
        ::confColor::applyColor $tl
        update

        # Exécution de Aladin
        set erreur_aladin [ ExecutionAladin $script_aladin $temps_attente_max ]

        destroy $tl

        if { $erreur_aladin != 0 } {
            tk_messageBox -message "$photometrie_texte(err_exec_aladin)" -title "$photometrie_texte(titre_menu)" -icon error
            set erreur -1
        }

        return $erreur
    }

    proc Message { niveau args } {
        switch -exact -- $niveau {
            console {
                ::console::disp [ eval {format} $args ]
                update idletasks
            }
        }
    }

    ##
    # @brief Mesure et affichage des flux par modélisation et ouverture
    # @param tag de l'objet (reference ou inconnu)
    # @param liste des coordonnées dans le repère image
    #
    proc MesureFlux { tag xy } {
        variable photometrie

        set fwhm $photometrie(fwhm)
        set f $photometrie(defaut,carre,modelisation)
        if { $photometrie(mode_debug) != 0 } {
            Message console "fwhm=%f\n" $fwhm
            Message console "f=%f\n" $f
        }
        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]
        set x1 [ expr round( $x - $f * $fwhm / 2 ) ]
        set y1 [ expr round( $y - $f * $fwhm / 2 ) ]
        set x2 [ expr round( $x + $f * $fwhm / 2 ) ]
        set y2 [ expr round( $y + $f * $fwhm / 2 ) ]

        catch { calaphot_fitgauss2d $::audace(bufNo) [ list $x1 $y1 $x2 $y2 ] } mesure_mod
        if { $photometrie(mode_debug) != 0 } {
            Message console "Mod %s\n" [ list $x1 $y1 $x2 $y2 ]
            Message console "Mod %s\n" $mesure_mod
        }
        if { [ string is double [ lindex $mesure_mod 0 ] ] } {
            if { ( [ lindex $mesure_mod 1 ] > 0 ) && ( [ lindex $mesure_mod 12 ] > 0 ) } {
                # La modélisation est correcte
                set photometrie(flux_mod_$tag) [ list [ lindex $mesure_mod 12 ] [ lindex $mesure_mod 23 ] ]
                $photometrie(label_flux_mod_$tag) configure -text [ expr round( [ lindex $mesure_mod 12 ] ) ]
            } else {
                set photometrie(flux_mod_$tag) [ list 0.0 0.0 ]
                $photometrie(label_flux_mod_$tag) configure -text "???"
            }
        } else {
            # la valeur <0 va empêcher le calcul de la magnitude
            set photometrie(flux_mod_$tag) -1
            $photometrie(label_flux_mod_$tag) configure -text "???"
        }

        set xr [ expr round( $x + .5 ) ]
        set yr [ expr round( $y + .5 ) ]
        catch { calaphot_fluxellipse \
            $::audace(bufNo) \
            $xr $yr \
            [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] \
            0 \
            [ expr $photometrie(diametre,exterieur1) * $fwhm / 2 ] [ expr $photometrie(diametre,exterieur2) * $fwhm / 2 ] \
            10 } mesure_ouv
        if { $photometrie(mode_debug) != 0 } {
            Message console "Ouv %s\n" [ list $xr $yr  [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] [ expr $photometrie(diametre,interieur) * $fwhm / 2 ] [ expr $photometrie(diametre,exterieur1) * $fwhm / 2 ] [ expr $photometrie(diametre,exterieur2) * $fwhm / 2 ] ]
            Message console "Ouv %s\n" $mesure_ouv
        }
        if { [ string is double [ lindex $mesure_ouv 0 ] ] } {
            set photometrie(flux_ouv_$tag) [ lindex $mesure_ouv 0 ]
            if { $photometrie(flux_ouv_$tag) > 0 } {
                $photometrie(label_flux_ouv_$tag) configure -text [ expr round( [ lindex $mesure_ouv 0 ] ) ]
            } else {
                $photometrie(label_flux_ouv_$tag) configure -text "???"
            }
        } else {
            # la valeur <0 va empêcher le calcul de la magnitude
            set photometrie(flux_ouv_$tag) -1
            $photometrie(label_flux_ouv_$tag) configure -text "???"
        }
    }


    ##
    # @brief Séquencement du mode de sélection via un catalogue téléchargé par Internet
    # @return -1 si l'utilisateur veut arrêter, ou en cas d'erreur bloquante. 0 sinon.
    proc ModeAutoInternet {} {
        variable photometrie

        ChoixCatalogueInternet
        if { [ InterfaceAladin ] < 0 } { return -1 }
        if { [ CreationBaseDonnées ] < 0 } { return -1 }
        if { [ SelectionReference ] < 0 } { return -1 }
        return 0
    }

    ##
    # @brief Affichage de la boite de sélection d'une étoile
    # @return
    proc ModeManuel {} {
        variable photometrie_texte
        variable photometrie

        set photometrie(selection_manuelle) 0
        set tl [ toplevel $::audace(base).photometrie_selection_manuelle \
            -class Toplevel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm resizable $tl 0 0
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlfaide [ frame $tl.aide ]
        label $tlfaide.l -text $photometrie_texte(aide_mode_manuel)
        pack $tlfaide.l

        set tlf1 [ frame $tl.f1 \
            -borderwidth 2 \
            -relief groove ]

        set tlf1l [ label $tlf1.l -text $photometrie_texte(magnitude) ]
        set tlf1e [ entry $tlf1.e \
                -textvariable ::Photometrie::photometrie(reference,magnitude) \
                -width -1 \
                -relief sunken ]
        $tlf1.e delete 0 end
        $tlf1.e insert 0 13.5
        grid $tlf1l $tlf1e

        set tlf2 [ frame $tl.f2 \
            -borderwidth 2 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command { Photometrie::ValidationModeManuel } ]

        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(selection_manuelle) -1
                update idletasks
                destroy $::audace(base).photometrie_selection_manuelle
            } ]

        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        pack $tlfaide $tlf1 $tlf2

        ::confColor::applyColor $tl
        tkwait window $tl

        set photometrie(reference,nom) "---"

        return $photometrie(selection_manuelle)
    }

    proc Modelisation { xy } {
        variable photometrie_texte
        variable photometrie

        set fwhm $photometrie(fwhm)
        set f $photometrie(defaut,carre,modelisation)

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]
        set x1 [ expr round( $x - $f * $fwhm ) ]
        set y1 [ expr round( $y - $f * $fwhm ) ]
        set x2 [ expr round( $x + $f * $fwhm ) ]
        set y2 [ expr round( $y + $f * $fwhm ) ]

        if { ( $x1 <= 0 )
        || ( $y1 <= 0 )
        || ( $x2 >= $photometrie(naxis1) )
        || ( $y2 >= $photometrie(naxis2) ) } {
            tk_messageBox -message "$photometrie_texte(err_hors_clou)" -title "$photometrie_texte(titre_menu)" -icon error
            set mesure_mod [ list -1 -1 ]
        } else {
            set mm [ calaphot_fitgauss2d $::audace(bufNo) [ list $x1 $y1 $x2 $y2 ] ]
            if { ( [ lindex $mm 1 ] <= 0 ) || ( [ lindex $mm 12 ] <= 0 ) } {
                tk_messageBox -message "$photometrie_texte(err_etoile_faible)" -title "$photometrie_texte(titre_menu)" -icon error
                set mesure_mod [ list -1 -1 ]
            } else {
                set mesure_mod [ list [ lindex $mm 1 ] [ lindex $mm 12 ] ]
            }
        }
        return $mesure_mod
    }

    ##
    # @brief Gestion des mouvements de souris
    # @param canevas sur lequel s'éxécute le mouvement
    # @param abscisse de la souris dans le canevas (repère écran)
    # @param ordonnee de la souris dans le canevas (repère écran)
    proc MouvementSouris { canevas x y } {
        variable photometrie

        set x [ $canevas canvasx $x ]
        set y [ $canevas canvasy $y ]
        set dx [ expr $x - [ lindex $photometrie(coord_souris) 0 ] ]
        set dy [ expr $y - [ lindex $photometrie(coord_souris) 1 ] ]
        $canevas move inc $dx $dy
        set photometrie(coord_souris) [ list $x $y ]
    }

    proc SelectionReference {} {
        global ::Photometrie::selection_aladin
        variable photometrie_texte
        variable photometrie
        variable data
        variable index_rouge
        variable index_bleu

        set liste_rouge_triee [ lsort -real  [ array names index_rouge ] ]
        set liste_bleue_triee [ lsort -real  [ array names index_bleu ] ]

        set tl [ toplevel $::audace(base).photometrie_selection_internet \
            -class Toplevel \
            -borderwidth 2 \
            -relief groove ]
        wm title $tl $photometrie_texte(titre_menu)
        wm resizable $tl 0 0
        wm protocol $tl WM_DELETE_WINDOW ::Photometrie::Suppression
        wm transient $tl .audace

        set tlfaide [ frame $tl.aide ]
        label $tlfaide.l -text $photometrie_texte(aide_selection_reference)
        pack $tlfaide.l

        set tlf1 [ frame $tl.f1 \
            -borderwidth 2 \
            -relief groove ]

        set zoom 1

        label $tlf1.titre_selection -text ""
        label $tlf1.titre_id -text $photometrie_texte(numero)
        label $tlf1.titre_x -text "X"
        label $tlf1.titre_y -text "Y"
        label $tlf1.titre_nom -text $photometrie_texte(nom)
        label $tlf1.titre_mag_r -text $photometrie_texte(mag_r)
        label $tlf1.titre_mag_b -text $photometrie_texte(mag_b)
        label $tlf1.titre_mag_b_r -text $photometrie_texte(mag_b_r)
        grid $tlf1.titre_selection $tlf1.titre_id $tlf1.titre_x $tlf1.titre_y $tlf1.titre_nom $tlf1.titre_mag_r $tlf1.titre_mag_b $tlf1.titre_mag_b_r

        set ligne 1
        set photometrie(selection_couleur) mag_r
        set tlf1mr [ radiobutton $tlf1.mag_rouge \
            -variable ::Photometrie::photometrie(selection_couleur) \
            -value mag_r ]
        grid $tlf1mr -row $ligne -column 5
        set tlf1mb [ radiobutton $tlf1.mag_bleue \
            -variable ::Photometrie::photometrie(selection_couleur) \
            -value mag_b ]
        grid $tlf1mb -row $ligne -column 6

        set n 0
        set photometrie(selection_aladin) 1
        set photometrie(ancienne_selection) 1
        set premier_id 0
        set zoom [ visu$::audace(visuNo) zoom ]
        set fwhm $photometrie(fwhm)
        set f3 [ expr $fwhm * 3 ]
        set catalogue $photometrie(cata_internet)
        foreach cle $liste_rouge_triee {
            foreach id $index_rouge($cle) {
                set param $data($id)
                set ad [ expr [ lindex $param $photometrie(position,$catalogue,ad) ] * 1.0 ]
                set dec [ expr [ lindex $param $photometrie(position,$catalogue,dec) ] * 1.0 ]
                set nom [ lindex $param $photometrie(position,$catalogue,nom) ]
                set mag_r [ lindex $param $photometrie(position,$catalogue,mag_r) ]
                set mag_b [ lindex $param $photometrie(position,$catalogue,mag_b) ]
                # Message console "n:%s ad:%f dec:%f r:%f b:%f\n" $nom $ad $dec $mag_r $mag_b
                set xyi [ buf$::audace(bufNo) radec2xy [ list $ad $dec ] ]
                set x [ expr round( [ lindex $xyi 0 ] ) ]
                set y [ expr round( [ lindex $xyi 1 ] ) ]
                if { [ ValidationMotifs [ list $x $y ] ] == 0 } {
                    incr n
                    incr ligne
                    if { $n == 1 } {
                        set premier_id $id
                    }
                    set xye [ ConvImageEcran $xyi ]
                    set xe [ lindex $xye 0 ]
                    set ye [ lindex $xye 1 ]
                    $::audace(hCanvas) create oval \
                        [ expr $xe - $fwhm ] \
                        [ expr $ye + $fwhm ] \
                        [ expr $xe + $fwhm ] \
                        [ expr $ye - $fwhm ] \
                        -outline red \
                        -width 1 \
                        -tags [ list photom ovale_$n ]
                    $::audace(hCanvas) create text \
                        $xe \
                        [ expr $ye - 3 * $fwhm ] \
                        -text $n \
                        -tags [ list photom texte_$n ] \
                        -fill red \
                        -anchor n \
                        -tags [ list photom texte_$n ]

                    set val(n) $n
                    set val(x) $x
                    set val(y) $y
                    set val(nom) $nom
                    set val(mag_r) $mag_r
                    set val(mag_b) $mag_b
                    if { [ string is double -strict $mag_r ]
                    && [ string is double -strict $mag_b ] } {
                        set val(mag_b_r) [ expr $mag_b - $mag_r ]
                    } else {
                        set val(mag_b_r) "---"
                    }
                    set col 0
                    radiobutton ${tlf1}.${n}_cb \
                        -variable ::Photometrie::photometrie(selection_aladin) \
                        -command "::Photometrie::AnimationSelectionCatalogue $tlf1 $id" \
                        -value $n
                    grid ${tlf1}.${n}_cb -row $ligne -column $col
                    foreach champ { n x y nom mag_r mag_b mag_b_r } {
                        incr col
                        label ${tlf1}.${n}_$champ \
                            -text $val($champ) \
                            -relief solid
                        grid ${tlf1}.${n}_$champ -row $ligne -column $col -sticky news
                    }
                }

            }
            if { $n > 19 } { break }
        }

        if { $n == 0 } {
            destroy $tl
            tk_messageBox -message "$photometrie_texte(err_pas_de_ref)" -title "$photometrie_texte(titre_menu)" -icon error
            return -1
        }

        set tlf2 [ frame $tl.f2 \
            -borderwidth 2 \
            -relief groove ]

        set tlf2b1 [ button $tlf2.b1 \
            -text $photometrie_texte(ok) \
            -command {
                $::audace(hCanvas) delete photom
                update idletasks
                destroy $::audace(base).photometrie_selection_internet
            } ]

        set tlf2b2 [ button $tlf2.b2 \
            -text $photometrie_texte(arret) \
            -command {
                set ::Photometrie::photometrie(selection_aladin) -1
                $::audace(hCanvas) delete photom
                update idletasks
                destroy $::audace(base).photometrie_selection_internet
            } ]
        pack $tlf2b1 $tlf2b2 \
            -side left \
            -padx 10 \
            -pady 10

        unset index_rouge
        unset index_bleu

        pack $tlfaide $tlf1 $tlf2
        ::confColor::applyColor $tl

        AnimationSelectionCatalogue $tlf1 $premier_id
        $tlf1mr configure -command { ::Photometrie::AnimationSelectionCatalogue $::audace(base).photometrie_selection_internet.f1 $::Photometrie::photometrie(selection,id) }
        $tlf1mb configure -command { ::Photometrie::AnimationSelectionCatalogue $::audace(base).photometrie_selection_internet.f1 $::Photometrie::photometrie(selection,id) }

        tkwait window $tl

        # Récupération des informations sur la référence
        set id $photometrie(selection,id)
        set param $data($id)
        set photometrie(reference,nom) [ lindex $param $photometrie(position,$catalogue,nom) ]
        set photometrie(reference,xy) [ buf$::audace(bufNo) radec2xy [ list [ expr [ lindex $param $photometrie(position,$catalogue,ad) ] * 1.0 ] [ expr [ lindex $param $photometrie(position,$catalogue,dec) ] * 1.0 ] ] ]
        if { $photometrie(selection_couleur) == "mag_r" } {
            set photometrie(reference,magnitude) [ lindex $param $photometrie(position,$catalogue,mag_r) ]
        } else {
            set photometrie(reference,magnitude) [ lindex $param $photometrie(position,$catalogue,mag_b) ]
        }

        return $photometrie(selection_aladin)
    }

    ##
    # @brief Mesure de valeurs de magnitudes directement sur une image
    proc PhotometrieEcran {} {
        variable photometrie

        set tl [ CadreMesurePhotometrie ]

        set xy_ecran [ ConvImageEcran $photometrie(reference,xy) ]
        DessinCercles ref $xy_ecran
        MesureFlux ref $photometrie(reference,xy)

        GestionSouris

        tkwait window $tl
    }

    # @brief Procédure pour bloquer la suppression des fenêtres esclaves
    proc Suppression {} {

    }

    # @brief Validation de la saisie d'une étoile en mode manuel
    proc ValidationModeManuel {} {
        variable photometrie_texte
        variable photometrie

        set rect [ ::confVisu::getBox $::audace(visuNo) ]
        if { [ llength $rect ] <= 0 } {
            tk_messageBox -message "$photometrie_texte(err_pas_de_sel)" -title "$photometrie_texte(titre_menu)" -icon error
        } else {
            set photometrie(reference,xy) [ buf$::audace(bufNo) centro $rect ]
            if { [ ValidationMotifs $photometrie(reference,xy) ] < 0 } {
                tk_messageBox -message "$photometrie_texte(err_hors_clou)" -title "$photometrie_texte(titre_menu)" -icon error
            } else {
                set mm [ Modelisation $photometrie(reference,xy) ]
                if { [ lindex $mm 1 ] > 0 } {
                    destroy $::audace(base).photometrie_selection_manuelle
                }
            }
        }
    }

    # @brief Validation de ce que les cercles d'ouverture et la fenêtre de modélisation sont bien dans l'image
    # @param : liste des coordonnées dans le repère image
    # @return -1 si les motifs débordent de l'image, 0 dans le cas contraire
    proc ValidationMotifs { xy } {
        variable photometrie

        set x [ lindex $xy 0 ]
        set y [ lindex $xy 1 ]

        # Le cercle exterieur2 est le plus grand des 3 cercles, il y a juste à le comparer au carré de modélisation
        if { $photometrie(defaut,diametre,exterieur2) > $photometrie(defaut,carre,modelisation) } {
            set max $photometrie(defaut,diametre,exterieur2)
        } else {
            set max $photometrie(defaut,carre,modelisation)
        }

        set fwhm $photometrie(fwhm)
        if { ( [ expr $x - $max * $fwhm ] < 1 )
        || ( [ expr $x + $max * $fwhm ] > $photometrie(naxis1) )
        || ( [ expr $y - $max * $fwhm ] < 1 )
        || ( [ expr $y + $max * $fwhm ] > $photometrie(naxis2) ) } {
            return -1
        } else {
            return 0
        }
    }
}
