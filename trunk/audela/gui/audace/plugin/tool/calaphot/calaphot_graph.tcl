##
# @file calaphot_graph.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Routines de gestion des affichages de Calaphot
#
# $Id: calaphot_graph.tcl,v 1.3 2009-06-09 07:56:36 jacquesmichelet Exp $

namespace eval ::CalaPhot {

    ##
    # @brief Affichage sequentiel des menus de selection des astres
    # @details si tracage active, init des valeurs de sortie directement @n
    #         sinon, passage par les ecrans de saisie (conditionne par
    #         par une eventuelle demande d'arret)
    # @param[in] nom_image : nom generique des images
    # @retval data_script(nombre_reference) : nombre d'etoile de reference
    # @retval data_script(nombre_variable) : nombre d'asteroide
    # @retval data_script(nombre_indes) : nombre d'etoile a supprimer
    proc AffichageMenus {nom_image} {
        variable demande_arret
        variable trace_log
        variable data_script
        variable pos_theo
        variable coord_aster
        variable parametres

        Message debug "%s\n" [info level [info level]]

        Message debug "ref=%d var=%d\n" $data_script(nombre_reference) $data_script(nombre_variable)
        if {($data_script(nombre_reference) == 0) \
            || ($data_script(nombre_variable) == 0) \
            || ($parametres(reprise_astres) == "non") } {
            # On nettoie
            for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
                set pos_theo(ref,$i) [list]
            }
            set data_script(nombre_reference) 0
            for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
                set coord_aster($i,1) [list]
                set coord_aster($i,2) [list]
            }
            set data_script(nombre_variable) 0
            set data_script(nombre_indes) 0
            AffichageMenuEtoile $nom_image
            if {$demande_arret == 0} {
                AffichageMenuAsteroide 1 $nom_image
                if {$demande_arret == 0} {
                    AffichageMenuIndesirable $nom_image
                }
            }
        }
    }

    ##
    # @brief Affichage de la boite de sélection d'un asteroide
    # @param indice : selecteur
    # - 0 : permet de passer à un asteroide suivant (quand on supportera les asteroides multiples)
    # - 1 : selection dans la 1ere image de la sequence
    # - 2 : selection dans la derniere image de la sequence
    # .
    # @param nom_image nom generique de l'image sur laquelle va se faire la selection
    # @return
    proc AffichageMenuAsteroide {indice nom_image} {
        global audace
        variable calaphot
        variable data_script

        Message debug "%s\n" [info level [info level]]

        catch {destroy $audace(base).selection_aster}

        toplevel $audace(base).selection_aster -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selection_aster 200x200+650+120
        wm resizable $audace(base).selection_aster 0 0
        wm title $audace(base).selection_aster $calaphot(texte,asteroide)
        wm transient $audace(base).selection_aster .audace
        wm protocol $audace(base).selection_aster WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(pos_aster_1) $calaphot(texte,pos_aster_1)
        set texte_bouton(pos_aster_2) $calaphot(texte,pos_aster_2)
        set texte_bouton(continuation) $calaphot(texte,continuation)
        set texte_bouton(retour) $calaphot(texte,retour)
        set texte_bouton(suivant) $calaphot(texte,suivant)
        set texte_bouton(annulation) $calaphot(texte,annulation)

        if {$indice == 0} {
            if {$data_script(nombre_variable) == 0} {
                set liste_champ {suivant annulation}
            } else {
                set liste_champ {suivant continuation annulation}
                set commande_bouton(continuation) "::CalaPhot::ContinuationAsteroide"
            }
        }
        if {$indice == 1} {
            # Affichage de la premiere ou de la derniere image de la serie
            loadima ${nom_image}1
            Visualisation optimale

            set liste_champ {pos_aster_1 continuation annulation}
            set commande_bouton(continuation) "::CalaPhot::AffichageMenuAsteroide 2 $nom_image"
        }
        if {$indice == 2} {
            # Affichage de la premiere ou de la derniere image de la serie
            loadima ${nom_image}2
            Visualisation optimale

            set liste_champ {pos_aster_2 continuation retour annulation}
        # MultAster : remettre
            #set commande_bouton(continuation) "::CalaPhot::AffichageMenuAsteroide 0 $nom_image"
        # /MultAster
        set commande_bouton(continuation) "::CalaPhot::ContinuationAsteroide"
        }

        # indice <- (indice + 1) mod 3
        if {$indice == 2} {set indice 1} else {incr indice}

        set commande_bouton(pos_aster_1)  "::CalaPhot::PositionAsteroide $nom_image 1"
        set commande_bouton(pos_aster_2)  "::CalaPhot::PositionAsteroide $nom_image 2"
        set commande_bouton(retour) "::CalaPhot::Retour $nom_image"
        set commande_bouton(suivant) "::CalaPhot::AffichageMenuAsteroide $indice $nom_image"
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Creation du contenu de la fenetre
        foreach champ $liste_champ {
            button $audace(base).selection_aster.b$champ \
                -text $texte_bouton($champ) \
                -command $commande_bouton($champ) \
                -bg $audace(color,backColor2)
            pack $audace(base).selection_aster.b$champ \
                -anchor center \
                -side top \
                -fill x \
                -padx 4 \
                -pady 4 \
                -in $audace(base).selection_aster \
                -anchor center \
                -expand 1 \
                -fill both \
                -side top
        }
        ::confColor::applyColor $audace(base).selection_aster

        tkwait window $audace(base).selection_aster
    }

    ##
    # @brief Affichage de la boite de sélection d'une etoile
    # @details Initialisation de certaines variables
    # - data_script(nombre_reference)
    # - coord_etoile_x
    # - coord_etoile_y
    # - mag_etoile
    # .
    # @param nom_image nom generique de l'image sur laquelle va se faire la selection
    # @return
    proc AffichageMenuEtoile {nom_image} {
        global audace
        variable calaphot
        variable data_script
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile

        Message debug "%s\n" [info level [info level]]

        # Affichage de la premiere image de la serie
        loadima ${nom_image}1
        Visualisation optimale

        toplevel $audace(base).selection_etoile -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selection_etoile 200x200+650+120
        wm resizable $audace(base).selection_etoile 0 0
        wm title $audace(base).selection_etoile $calaphot(texte,etoile_reference)
        wm transient $audace(base).selection_etoile .audace
        wm protocol $audace(base).selection_etoile WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(validation_etoile) $calaphot(texte,validation_etoile)
        set texte_bouton(devalidation_etoile) $calaphot(texte,devalidation_etoile)
        set texte_bouton(continuation) $calaphot(texte,continuation)
        set texte_bouton(annulation) $calaphot(texte,annulation)

        set commande_bouton(validation_etoile) ::CalaPhot::SelectionneEtoiles
        set commande_bouton(devalidation_etoile) ::CalaPhot::DeselectionneEtoiles
        set commande_bouton(continuation) ::CalaPhot::ContinuationEtoiles
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Creation du contenu de la fenetre
        foreach champ {validation_etoile devalidation_etoile continuation annulation} {
            button $audace(base).selection_etoile.b$champ \
                -text $texte_bouton($champ) \
                -command $commande_bouton($champ) \
                -bg $audace(color,backColor2)
            pack $audace(base).selection_etoile.b$champ \
                -anchor center \
                -side top \
                -fill x \
                -padx 4 \
                -pady 4 \
                -in $audace(base).selection_etoile \
                -anchor center \
                -expand 1 \
                -fill both \
                -side top
        }

        set data_script(nombre_reference) 0
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
        ::confColor::applyColor $audace(base).selection_etoile
        tkwait window $audace(base).selection_etoile
    }

    ##
    # @brief Affichage de la boite de suppression d'une etoile
    # @details Initialisation de certaines variables
    # - data_script(nombre_indes)
    # - coord_indes_x
    # - coord_indes_y
    # .
    # @param nom_image nom generique de l'image sur laquelle va se faire la selection
    # @return
    proc AffichageMenuIndesirable {nom_image} {
        global audace
        variable calaphot
        variable data_script
        variable coord_indes_x
        variable coord_indes_y

        Message debug "%s\n" [info level [info level]]

        # Affichage de la premiere image de la serie
        loadima ${nom_image}1
        Visualisation optimale

        toplevel $audace(base).selection_indes -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selection_indes 200x200+650+120
        wm resizable $audace(base).selection_indes 0 0
        wm title $audace(base).selection_indes $calaphot(texte,etoile_a_supprimer)
        wm transient $audace(base).selection_indes .audace
        wm protocol $audace(base).selection_indes WM_DELETE_WINDOW ::CalaPhot::Suppression

        set texte_bouton(validation_etoile) $calaphot(texte,validation_etoile)
        set texte_bouton(devalidation_etoile) $calaphot(texte,devalidation_etoile)
        set texte_bouton(continuation) $calaphot(texte,continuation)
        set texte_bouton(annulation) $calaphot(texte,annulation)

        set commande_bouton(validation_etoile) ::CalaPhot::SelectionneIndesirables
        set commande_bouton(devalidation_etoile) ::CalaPhot::DeselectionneIndesirables
        set commande_bouton(continuation) ::CalaPhot::ContinuationIndesirables
        set commande_bouton(annulation) ::CalaPhot::ArretScript

        #----- Creation du contenu de la fenetre
        foreach champ {validation_etoile devalidation_etoile continuation annulation} {
            button $audace(base).selection_indes.b$champ -text $texte_bouton($champ) -command $commande_bouton($champ) -bg $audace(color,backColor2)
            pack $audace(base).selection_indes.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selection_indes -anchor center -expand 1 -fill both -side top
        }

        set data_script(nombre_indes) 0
        if {[info exists coord_indes_x]} {
            unset coord_indes_x
            list coord_indes_x {}
        }
        if {[info exists coord_indes_y]} {
            unset coord_indes_y
            list coord_indes_y {}
        }
        ::confColor::applyColor $audace(base).selection_indes
        tkwait window $audace(base).selection_indes
    }

    ##
    # @brief Affichage console des informations sur les objets de l'image courante
    # @param i : indice de l'image dans la sequence
    # @return
    proc AffichageResultatsBruts {i} {
        variable parametres
        variable data_image
        variable data_script
        variable calaphot

        Message debug "%s\n" [info level [info level]]

        set ymdhms [mc_date2ymdhms $data_image($i,date)]
        set y [lindex $ymdhms 0]
        set m [lindex $ymdhms 1]
        set d [lindex $ymdhms 2]
        set h [lindex $ymdhms 3]
        set mn [lindex $ymdhms 4]
        set s [lindex $ymdhms 5]

        Message notice "%05u %f %04d/%02d/%02d %02d:%02d:%04.1f" $i $data_image($i,date) $y $m $d $h $mn $s
        for {set etoile 0} {$etoile < $data_script(nombre_variable)} {incr etoile} {
            Message notice " | %07.4f" $data_image($i,var,mag_$etoile)
            Message notice " %05.4f" $data_image($i,var,incertitude_$etoile)
            Message info " %07.0f" $data_image($i,var,flux_$etoile)
            Message info " %06.1f" $data_image($i,var,sb_$etoile)
            Message debug " N=%07.2f" $data_image($i,var,nb_pixels_$etoile)
            Message debug " B=%06.1f" $data_image($i,var,fond_$etoile)
            Message debug " Nb=%07.2f\n" $data_image($i,var,nb_pixels_fond_$etoile)
        }

        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            Message notice " | %07.4f" $data_image($i,ref,mag_$etoile)
            Message notice " %05.4f" $data_image($i,ref,incertitude_$etoile)
            Message info " %07.0f" $data_image($i,ref,flux_$etoile)
            Message info " %06.1f" $data_image($i,ref,sb_$etoile)
            Message debug " N=%07.2f" $data_image($i,ref,nb_pixels_$etoile)
            Message debug " B=%06.1f" $data_image($i,ref,fond_$etoile)
            Message debug " Nb=%07.2f\n" $data_image($i,ref,nb_pixels_fond_$etoile)
        }

        Message notice " | %07.4f | %s" $data_image($i,constante_mag) $data_image($i,valide)
        if {$data_image($i,valide) == "N"} {
            Message debug "( %s )\n" $data_script($i,invalidation)
        }
        Message notice "\n"
    }

    ##
    # @brief Affichage dynamique des trames de l'ecran de saisie des parametre et ajustement des ascenseurs en consequence
    # @param mode : mode de calcul choisi
    # @param c : handle du canvas qui contient ces trames
    # @param y : handle du scrollbar (ascenseur)
    # @param t : handle de la trame englobant les trames a afficher
    proc AffichageVariable {mode c y t} {
        global audace

        Message debug "%s\n" [info level [info level]]

        # Attention : le canevas $c fonctionne avec un grid manager !
        # Ne pas faire de mélange pack et grid
        catch {grid forget $t.trame1}
        catch {grid forget $t.trame2}
        catch {grid forget $t.trame_ouv}
        catch {grid forget $t.trame_mod}
        catch {grid forget $t.trame_sex}
        catch {grid forget $t.trame3}

        if {$mode == "ouverture"} {
            set fils $t.trame_ouv
        } elseif {$mode == "modelisation"} {
            set fils $t.trame_mod
        } elseif {$mode == "sextractor"} {
            set fils $t.trame_sex
        } else {
            Message erreur "mode=%s\n" $mode
            return
        }
        grid $t.trame1
        grid $t.trame2
        grid $fils
        grid $t.trame3

        # Il faut retailler les fenêtres avant de calculer leur largeur et hauteur
        ::confColor::applyColor $audace(base).saisie
        # Gestion dynamique de la taille du scrollbar
        # inspiré de Practical Programming in TclTk, exemple 34.13
        tkwait visibility $fils
        # L'instruction suivant semble servir pour reqwidth et reqheight
        # Ne pas effacer
        set bbox [grid bbox $t 0 0]
#        set incr [lindex $bbox 3]
        set largeur [winfo reqwidth $t]
        set hauteur [winfo reqheight $t]
        $c config -scrollregion "0 0 $largeur $hauteur"
        $c config -yscrollincrement 5
        set hauteur_max [expr [winfo screenheight .] * 3 / 4]
        if {$hauteur > $hauteur_max} {set hauteur $hauteur_max}
        $c config -width $largeur -height $hauteur
    }

    #*************************************************************************#
    #*************  AnnuleSaisie  ********************************************#
    #*************************************************************************#
    proc AnnuleSaisie {} {
        global audace
        variable demande_arret

        Message debug "%s\n" [info level [info level]]

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

        Message debug "%s\n" [info level [info level]]

        set demande_arret 1
        EffaceMotif astres
        catch {destroy $audace(base).selection_etoile}
        catch {destroy $audace(base).selection_aster}
        catch { destroy $audace(base).selection_indes}
        catch {destroy $audace(base).bouton_arret_color_invariant}
    }

    ##
    # @brief Mise en place du bouton permettant d'arreter les calculs.
    # @return
    proc BoutonArret {} {
        global color audace
        variable calaphot
        variable police

        Message debug "%s\n" [info level [info level]]

        set b [toplevel $audace(base).bouton_arret_color_invariant -class Toplevel -borderwidth 2 -bg $color(red) -relief groove]
        wm geometry $b +320+0
        wm resizable $b 0 0
        wm title $b ""
        wm transient $b .audace
        wm protocol $b WM_DELETE_WINDOW ::CalaPhot::Suppression

        frame $b.arret -borderwidth 5 \
            -relief groove \
            -bg $color(red)
        button $b.arret.b \
            -text $calaphot(texte,arret) \
            -command {set ::CalaPhot::demande_arret 1} \
            -bg $color(white) \
            -activebackground $color(red) \
            -fg $color(red)
        pack $b.arret.b -side left -padx 10 -pady 10
        pack $b.arret

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $b
    }

    #*************************************************************************#
    #*************  ContinuationAsteroide  ***********************************#
    #*************************************************************************#
    proc ContinuationAsteroide {} {
        global audace
        variable calaphot
        variable coord_aster
        variable data_script

        Message debug "%s\n" [info level [info level]]

        Message info "----------------------------\n"
        Message info "------------%s--------------\n" $calaphot(texte,asteroide)
        Message info "----------------------------\n"
        for {set a 0} {$a < $data_script(nombre_variable)} {incr a} {
            Message info "--- %u : (%4.2f %4.2f) -> (%4.2f %4.2f)\n" $a [lindex $coord_aster($a,1) 0] [lindex $coord_aster($a,1) 1] [lindex $coord_aster($a,2) 0] [lindex $coord_aster($a,2) 1]
        }
        destroy $audace(base).selection_aster
    }


    #*************************************************************************#
    #*************  ContinuationEtoiles  *************************************#
    #*************************************************************************#
    proc ContinuationEtoiles {} {
        global audace
        variable data_script
        variable calaphot
        variable pos_theo
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile

        Message debug "%s\n" [info level [info level]]

        if {$data_script(nombre_reference) <= 0} {
            tk_messageBox -message $calaphot(texte,pas_etoile) -icon error -title $calaphot(texte,probleme)
        } else {
            # On initialise le tableau pos_theo
            Message info "----------------------------\n"
            Message info "------------%s--------------\n" $calaphot(texte,etoile_reference)
            Message info "----------------------------\n"
            for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
                set cx [lindex $coord_etoile_x $i]
                set cy [lindex $coord_etoile_y $i]
                set m [lindex $mag_etoile $i]
                set pos_theo(ref,$i) [list $cx $cy $m]
                Message info "%s n%d: %4.2f %4.2f %4.2f\n" $calaphot(texte,etoile) $i $cx $cy $m
            }
            destroy $audace(base).selection_etoile
        }
    }

    #*************************************************************************#
    #*************  ContinuationIndesirables  ********************************#
    #*************************************************************************#
    proc ContinuationIndesirables {} {
        global audace
        variable data_script
        variable calaphot
        variable pos_theo
        variable coord_indes_x
        variable coord_indes_y

        Message debug "%s\n" [info level [info level]]

        # On initialise le tableau pos_theo_indes
        if {$data_script(nombre_indes) <= 0} {
            Message info "\n------------%s--------------\n" $calaphot(texte,pas_etoile_ind)
        } else {
            Message info "----------------------------\n"
            Message info "------------%s--------------\n" $calaphot(texte,et_indesirables)
            Message info "----------------------------\n"
            set j 0
            for {set i 0} {$i < $data_script(nombre_indes)} {incr i} {
                set cx [lindex $coord_indes_x $i]
                set cy [lindex $coord_indes_y $i]
                set pos_theo(indes,$j) [list $cx $cy]
                Message info "%s (%d): %4.2f %4.2f\n" $calaphot(texte,etoile) $j $cx $cy
                incr j
            }
        }
        EffaceMotif astres
        destroy $audace(base).selection_indes
    }

    ##
    # @brief Affichage de la courbe de lumiere finale
    # @return
    proc CourbeLumiere {} {
        global audace color
        variable parametres
        variable data_image
        variable calaphot
        variable liste_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

        set vecteur_x [list]
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            set vecteur_ref($i) [list]
        }
        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            set vecteur_var($i) [list]
        }
        set vecteur_cstemag [list]
        set data_script(trace_premier) 1

        foreach i $liste_image {
            if {$data_image($i,valide) == "Y"} {
                if {$data_script(trace_premier) == 1} {
                    for {set e 0} {$e < $data_script(nombre_reference)} {incr e} {
                        set data_script(trace_ref_premier_$e) $data_image($i,ref,mag_$e)
                    }
                    for {set e 0} {$e < $data_script(nombre_variable)} {incr e} {
                        set data_script(trace_var_premier_$e) $data_image($i,var,mag_$e)
                    }
                    set data_script(trace_cste_premier) $data_image($i,constante_mag)
                    set data_script(trace_premier) 0
                }
                lappend vecteur_x $data_image($i,date)
                for {set e 0} {$e < $data_script(nombre_reference)} {incr e} {
                    lappend vecteur_ref($e) [expr $data_image($i,ref,mag_$e) - $data_script(trace_ref_premier_$e)]
                }
                for {set e 0} {$e < $data_script(nombre_variable)} {incr e} {
                    lappend vecteur_var($e) [expr $data_image($i,var,mag_$e) - $data_script(trace_var_premier_$e)]
                }
                lappend vecteur_cstemag [expr $data_image($i,constante_mag) - $data_script(trace_cste_premier)]
            }
        }

        if { ![info exists data_script(trace_cste_premier)] } {
            # Aucune image n'est valide    
            tk_messageBox -message $calaphot(texte,pas_image_valide) -icon error -title $calaphot(texte,probleme)
            return
        }
        Message debug "trace cste premier= %10.4f\n" $data_script(trace_cste_premier)
        for {set e 0} {$e < $data_script(nombre_reference)} {incr e} {
            Message debug "trace ref premier= %10.4f\n" $data_script(trace_ref_premier_$e)
            Message debug "vecteur_ref_%d=%s\n" $e $vecteur_ref($e)
        }
        for {set e 0} {$e < $data_script(nombre_variable)} {incr e} {
            Message debug "trace var premier= %10.4f\n" $data_script(trace_var_premier_$e)
            Message debug "vecteur_var_%d=%s\n" $e $vecteur_var($e)
        }

        if {[llength $vecteur_x] == 0} {
            Message info "%s\n" $calaphot(texte,rien_a_voir)
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
        append titre $calaphot(init,version_ini)
        wm title $baseplotxy $titre

        ::blt::graph $baseplotxy.xy
        $baseplotxy.xy configure -title $parametres(objet)
        catch {::blt::vector destroy vx }
        catch {::blt::vector delete vy1 }
        catch {::blt::vector delete vy2 }
        catch {::blt::vector delete vy3 }
        ::blt::vector create vx
        vx set $vecteur_x
        set max_max 0.0
        set min_min 0.0
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            catch {::blt::vector destroy vy_ref_$i }
            ::blt::vector create vy_ref_$i
            set vecteur $vecteur_ref($i)
            vy_ref_$i set $vecteur
            # Passage par un vecteur temp, car les routines de vecteurs ne gerent pas les doubles indices
            ::blt::vector create vecteur_temp
            vecteur_temp set $vecteur
            set max $vecteur_temp(max)
            if {$max > $max_max} {set max_max $max}
            set min $vecteur_temp(min)
            if {$min < $min_min} {set min_min $min}
            ::blt::vector destroy vecteur_temp
        }
        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            catch {::blt::vector destroy vy_var_$i }
            ::blt::vector create vy_var_$i
            set vecteur $vecteur_var($i)
            vy_var_$i set $vecteur
            # Passage par un vecteur temp, car les routines de vecteurs ne gerent pas les doubles indices
            ::blt::vector create vecteur_temp
            vecteur_temp set $vecteur
            set max $vecteur_temp(max)
            if {$max > $max_max} {set max_max $max}
            set min $vecteur_temp(min)
            if {$min < $min_min} {set min_min $min}
            ::blt::vector destroy vecteur_temp
        }
        catch {::blt::vector destroy vy_cstemag }
        ::blt::vector create vy_cstemag
        vy_cstemag set $vecteur_cstemag
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            # NomRef : mettre
            # $baseplotxy.xy element create ref_$i -xdata vx -ydata vy_ref_$i -symbol "" -color $color(red) -label $data_script(nom_ref_$i)
            # /NomRef
            $baseplotxy.xy element create ref_$i -xdata vx -ydata vy_ref_$i -symbol "" -color $color(red)
        }

        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            $baseplotxy.xy element create var_$i -xdata vx -ydata vy_var_$i -symbol "" -color $color(blue) -linewidth 3 -label $data_script(nom_var_$i)
        }
#        $baseplotxy.xy element create line_cste -xdata vx -ydata vy_cstemag -symbol "" -color $color(green) -label $calaphot(texte,constante_mag)
        $baseplotxy.xy axis configure x -title $calaphot(texte,jour_julien)
        $baseplotxy.xy axis configure y -title $calaphot(texte,magnitude)
        $baseplotxy.xy axis configure y -min $min_min
        $baseplotxy.xy axis configure y -max $max_max
        $baseplotxy.xy axis configure y -title $calaphot(texte,magnitude)

        $baseplotxy.xy legend configure -position bottom
        $baseplotxy.xy grid on

        $baseplotxy.xy crosshairs on
        $baseplotxy.xy crosshairs configure \
            -hide no \
            -color $color(black)
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
                %W marker create text \
                    -name cx \
                    -coords $xy_aff \
                    -text $X \
                    -anchor se \
                    -yoffset -10
                %W marker create text \
                    -name cy \
                    -coords $xy_aff \
                    -text $Y \
                    -anchor se \
                    -yoffset 10
            }
        }
        pack $baseplotxy.xy \
            -expand 1 \
            -fill both
        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $baseplotxy

        set nom_fichier [file join $audace(rep_images) [file rootname [file tail $parametres(fichier_cl)] ] ]
        append nom_fichier ".ps"

        catch {$baseplotxy.xy postscript output $nom_fichier -maxpect yes -decorations yes -landscape 1}

        # Attente de la fin de l'affichage de la courbe de lumiere
        update idletasks
        tkwait window $baseplotxy

#    ScriptCourbeLumiere vx vy1 vy2 vy3
    }

    #*************************************************************************#
    #*************  CourbeLumiereTemporaire  *********************************#
    #*************************************************************************#
    #  Affichage de la courbe de lumiere en cours de traitement (sans         #
    #  filtrage des donnees                                                  #
    #*************************************************************************#
    proc CourbeLumiereTemporaire {} {
        global audace color
        variable calaphot
        variable parametres
        variable data_script
        variable TempVectors
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        set vector_list [list]
        catch {unset TempVectors}

        # On va creer autant de courbes de lumieres que de variables
        # Generation de la liste des vecteurs
        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            set vector_list [concat $vector_list [list temp.$i.var vector[uniq]]]
            set vector_list [concat $vector_list [list temp.$i.x vector[uniq]]]
            set vector_list [concat $vector_list [list temp.$i.cste vector[uniq]]]
            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                set vector_list [concat $vector_list [list temp.$i.ref.$j vector[uniq]]]
            }
        }

        array set TempVectors $vector_list

        # On rend tous ces vecteurs globaux pour pouvoir s'en servir depuis une autre procedure
        foreach v [array names TempVectors temp*] {
            global $TempVectors($v)
        }

        foreach {key value} [array get TempVectors] {
            Message debug "TempsVectors(%s)=%s\n" $key $value
        }

        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            catch {::blt::vector destroy $TempVectors(temp.$i.var)}
            ::blt::vector create $TempVectors(temp.$i.var)

            catch {::blt::vector destroy $TempVectors(temp.$i.x)}
            ::blt::vector create $TempVectors(temp.$i.x)
            $TempVectors(temp.$i.x) notify always
            catch {::blt::vector destroy $TempVectors(temp.$i.cste) }
            ::blt::vector create $TempVectors(temp.$i.cste)
            $TempVectors(temp.$i.cste) notify always

            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                catch {::blt::vector destroy $TempVectors(temp.$i.ref.$j)}
                ::blt::vector create $TempVectors(temp.$i.ref.$j)
            }
            set baseplotxy($i) $audace(base)
            append baseplotxy($i) ".calaphot_"
            append baseplotxy($i) $i
            catch {destroy $baseplotxy($i)}
            toplevel $baseplotxy($i)
            wm geometry $baseplotxy($i) 631x453
            wm maxsize $baseplotxy($i) [winfo screenwidth .] [winfo screenheight .]
            wm minsize $baseplotxy($i) 200 200
            wm resizable $baseplotxy($i) 1 1

            set titre "Variable "
            append titre $i
            wm title $baseplotxy($i) $titre

            ::blt::graph $baseplotxy($i).xy \
                -title $parametres(objet)

            $baseplotxy($i).xy element create var_$i \
                -xdata $TempVectors(temp.$i.x) \
                -ydata $TempVectors(temp.$i.var) \
                -symbol "" \
                -color $color(blue) \
                -linewidth 3 \
                -label $data_script(nom_var_$i)
            $baseplotxy($i).xy element create cste_$i \
                -xdata $TempVectors(temp.$i.x) \
                -ydata $TempVectors(temp.$i.cste) \
                -symbol "" \
                -color $color(green) \
                -label $calaphot(texte,constante_mag)

            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                # NomRef : mettre
                # $baseplotxy.xy element create ref_$i -xdata vx -ydata vy_ref_$i -symbol "" -color $color(red) -label $data_script(nom_ref_$i)
                # /NomRef
                $baseplotxy($i).xy element create ref_$j \
                    -xdata $TempVectors(temp.$i.x) \
                    -ydata $TempVectors(temp.$i.ref.$j) \
                    -symbol "" \
                    -color $color(red)
            }
            $baseplotxy($i).xy axis configure x -title $calaphot(texte,jour_julien)
            $baseplotxy($i).xy axis configure y -title $calaphot(texte,magnitude)
            $baseplotxy($i).xy legend configure -position bottom
            $baseplotxy($i).xy grid on
            pack $baseplotxy($i).xy -expand 1 -fill both
            set data_script(trace_premier,$i) 1

            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $baseplotxy($i).xy
            update idletasks
        }
    }

    #**************************************************************************#
    #*************  DeselectionneEtoile  **************************************#
    #**************************************************************************#
    proc DeselectionneEtoiles {} {
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile
        variable calaphot
        variable data_script
        variable flux_premiere_etoile

        Message debug "%s\n" [info level [info level]]

        if {![info exists data_script(nombre_reference)]} {
            set data_script(nombre_reference) 0
        }
        Message debug "nombre_reference=%d\n" $data_script(nombre_reference)
        set pos [Centroide]
        Message debug "centroide=%s\n" $pos
        if {([llength $pos] != 0) && ($data_script(nombre_reference) > 0)} {
            incr data_script(nombre_reference) -1
            # Va permettre de reprendre le recalage photometrique de l'image
            if {($data_script(nombre_reference) == 0)} {
                unset flux_premiere_etoile
            }
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
                tk_messageBox -message $calaphot(texte,etoile_inconnue) -icon error -title $calaphot(texte,probleme)
            }
        }
    }

    #**************************************************************************#
    #*************  DeselectionneIndesirables  ********************************#
    #**************************************************************************#
    proc DeselectionneIndesirables {} {
        variable coord_indes_x
        variable coord_indes_y
        variable calaphot
        variable data_script

        Message debug "%s\n" [info level [info level]]

        if {![info exists data_script(nombre_indes)]} {
            set data_script(nombre_indes) 0
        }
        set pos [Centroide]
        if {([llength $pos] != 0) && ($data_script(nombre_indes) > 0)} {
            incr data_script(nombre_indes) -1
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]
            set ix [lsearch $coord_indes_x $cx]
            set iy [lsearch $coord_indes_y $cy]
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                set coord_indes_x [lreplace $coord_indes_x $ix $ix]
                set coord_indes_y [lreplace $coord_indes_y $iy $iy]
                EffaceMotif etoile_${cx}_${cy}
            } else {
                tk_messageBox -message $calaphot(texte,etoile_inconnue) -icon error -title $calaphot(texte,probleme)
            }
        }
    }

    ##
    # @brief Dessin d'un motif geometrique sur l'image affichee
    # @param motif : motif a affiche. Les valeurs peuvent etre :
    # - ovale
    # - rectangle
    # - verticale (trait vertical)
    # - horizontale (trait horizontal)
    # .
    # @param centre : liste de corrdonnées en pixel du centre du motif [list x y]
    # @param taille : liste donnant la largeur et la hauteur du motif en pixels [list largeur hauteur]
    # @param couleur : couleur du motif. Voir la documentation de Tcl pour les valeurs possibles
    # @param marqueur : marqueur ("tag" au sens Tk) du motif
    # @return
    proc Dessin {motif centre taille couleur marqueur} {
        global audace

        Message debug "%s\n" [info level [info level]]

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
    proc Dessin2 {image classe etoile facteur couleur marqueur} {
        global audace
        variable data_image

        Message debug "%s\n" [info level [info level]]

        set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
        # centroide
        set x0 $data_image($image,$classe,centroide_x_$etoile)
        set y0 $data_image($image,$classe,centroide_y_$etoile)
        # fwhms
        set f1 $data_image($image,$classe,fwhm1_$etoile)
        set f2 $data_image($image,$classe,fwhm2_$etoile)

        # angle
        set alpha $data_image($image,$classe,alpha_$etoile)


        # recuperation de alpha en radian
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

        Message debug "%s\n" [info level [info level]]

        set ellipse [list]

        #Calcul de l'ellipse par son eq. parametrique :
        # x = a * cos(t), y = b * sin(t)
        # t varie de 0 a 2*pi, par pas de pi/100
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

        Message debug "%s\n" [info level [info level]]

        $audace(hCanvas) delete $marqueur
    }

    #*************************************************************************#
    #*************  Entete  **************************************************#
    #*************************************************************************#
    proc Entete {} {
        variable parametres
        variable data_script

        Message debug "%s\n" [info level [info level]]

        switch -exact -- $parametres(niveau_message) {
        0 {
            # Minimal
            Message notice "No      JJ          "
            for {set etoile 0} {$etoile <= $data_script(nombre_reference)} {incr etoile} {
                Message notice " |   Mag.   Err  "
            }
            Message notice "\n"
        }
        1 {
            # Normal
            Message notice "No      JJ          "
            for {set etoile 0} {$etoile <= $data_script(nombre_reference)} {incr etoile} {
                Message notice " |   Mag.       Err        Flux        S/N "
            }
            Message notice " | mag.abs    | v\n"
        }
        2 {
            # Maximal
            Message notice "No      JJ               r1x      r1y     r2     r3    "
            Message notice " |   Mag.       Err        Flux        S/N        N       Bg       NBg        "
            Message notice " | mag.abs    | v\n"
            }
        }
    }

    #**************************************************************************#
    #*************  PreAffiche  ***********************************************#
    #**************************************************************************#
    # Cree ce qu'il faut pour la courbe de lumiere temporaire                  #
    #**************************************************************************#
    proc PreAffiche {i} {
        global audace
        variable premier_temp
        variable data_image
        variable data_script
        variable TempVectors
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        foreach v [array names TempVectors temp*] {
            global $TempVectors($v)
        }

        if {$data_image($i,valide) == "Y"} {
            for {set var 0} {$var < $data_script(nombre_variable)} {incr var} {
                if {$data_image($i,var,mag_$var) > 99} {
                    continue
                }

                set $TempVectors(temp.$var.x)(++end) $data_image($i,date)

                if {$data_script(trace_premier,$var) == 1} {
                    for {set e 0} {$e < $data_script(nombre_reference)} {incr e} {
                        set data_script(trace_ref_premier_$e,$var) $data_image($i,ref,mag_$e)
                    }
                    set data_script(trace_var_premier,$var) $data_image($i,var,mag_$var)
                    set data_script(trace_cste_premier,$var) $data_image($i,constante_mag)
                    set data_script(trace_premier,$var) 0
                }
                for {set e 0} {$e < $data_script(nombre_reference)} {incr e} {
                    set $TempVectors(temp.$var.ref.$e)(++end) [expr $data_image($i,ref,mag_$e) - $data_script(trace_ref_premier_$e,$var)]
                }
                set $TempVectors(temp.$var.var)(++end) [expr $data_image($i,var,mag_$var) - $data_script(trace_var_premier,$var)]
                set $TempVectors(temp.$var.cste)(++end) [expr $data_image($i,constante_mag) - $data_script(trace_cste_premier,$var)]
                set sigma [expr sqrt([::blt::vector expr var($TempVectors(temp.$var.cste))])]
                if {$sigma != 0} {
                    $audace(base).calaphot_$var.xy axis configure y -min [expr -3.0 * $sigma] -max [expr 3.0 * $sigma]
                }
            }
        }
    }

    #*************************************************************************#
    #*************  Retour  **************************************************#
    #*************************************************************************#
    proc Retour {nom_image} {
        global audace

        Message debug "%s\n" [info level [info level]]

        destroy $audace(base).selection_aster
        AffichageMenuAsteroide 1 $nom_image
    }

    #*************************************************************************#
    #*************  SaisieParametres  ****************************************#
    #*************************************************************************#
    proc SaisieParametres {} {
        global audace
        variable parametres
        variable calaphot
        variable police
        variable calaphot
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        # Construction de la fenetre des parametres
        toplevel $audace(base).saisie -borderwidth 2 -relief groove
        set largeur_ecran_2 [expr [winfo screenwidth .] / 2]
        wm geometry $audace(base).saisie +320+0
        wm title $audace(base).saisie $calaphot(texte,titre_saisie)
        wm protocol $audace(base).saisie WM_DELETE_WINDOW ::CalaPhot::Suppression

        # Construction de la trame des listes qui contient les listes et l'ascenseur
        frame $audace(base).saisie.listes

        # Construction du canevas qui va contenir toutes les trames et des ascenseurs
        set c [canvas $audace(base).saisie.listes.canevas -yscrollcommand [list $audace(base).saisie.listes.yscroll set] -width 10 -height 10]
        set y [scrollbar $audace(base).saisie.listes.yscroll -orient vertical -command [list $audace(base).saisie.listes.canevas yview] ]

        pack $y \
            -side right \
            -fill y
        pack $c \
            -side left \
            -fill both \
            -expand true
        pack $audace(base).saisie.listes \
            -side top \
            -fill both \
            -expand true

        # Construction d'une trame qui va englober toutes les listes dans le canevas
        set t [frame $c.t]
        $c create window 0 0 \
            -anchor nw \
            -window $t

        #--------------------------------------------------------------------------------
        # Trame des renseignements d'ordre general
        frame $t.trame1 \
            -borderwidth 5 \
            -relief groove
        label $t.trame1.titre \
            -text $calaphot(texte,param_generaux)
        grid $t.trame1.titre \
            -in $t.trame1 \
            -columnspan 2 \
            -sticky ew
        foreach champ {objet \
            operateur \
            code_UAI \
            type_capteur \
            type_telescope \
            diametre_telescope \
            focale_telescope \
            catalogue_reference \
            filtre_optique \
            source \
            indice_premier \
            indice_dernier \
            tailleboite \
            signal_bruit \
            gain_camera \
            bruit_lecture \
            sortie \
            fichier_cl} {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame1.l$champ \
                -text $calaphot(texte,$champ)
            entry $t.trame1.e$champ \
                -textvariable ::CalaPhot::parametres($champ) \
                -relief sunken
            $t.trame1.e$champ delete 0 end
            $t.trame1.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame1.l$champ $t.trame1.e$champ
        }
        #--------------------------------------------------------------------------------
        # Trame du cliquodrome
        set t2 [frame $t.trame2 \
            -borderwidth 5 \
            -relief groove]

        set ligne 0
        set colonne 0
        label $t2.laffichage \
            -text $calaphot(texte,affichage)
        grid $t2.laffichage \
            -sticky w \
            -row $ligne \
            -column $colonne

        if {[ info exists trace_log ]} {
            set liste_niveau [ list erreur probleme notice info debug ]
        } else {
            set liste_niveau [ list erreur probleme notice info ]
            if { $parametres(niveau_message) == $calaphot(niveau_debug) } {
                set parametres(niveau_message) $calaphot(niveau_info)
            }
        }
        foreach champ $liste_niveau {
            radiobutton $t2.affichage$champ  \
                -variable ::CalaPhot::parametres(niveau_message) \
                -text $calaphot(texte,$champ) \
                -value $calaphot(niveau_$champ)
            incr colonne
            grid $t2.affichage$champ \
                -sticky w \
                -row $ligne \
                -column $colonne
        }

        set ligne 1
        set colonne 0
        label $t2.lmode \
            -text $calaphot(texte,mode)
        grid $t2.lmode \
            -sticky w \
            -row $ligne \
            -column $colonne
        foreach choix {modelisation ouverture sextractor} {
            radiobutton $t2.bmode$choix \
                -variable ::CalaPhot::parametres(mode) \
                -text $calaphot(texte,mode_$choix) \
                -value $choix \
                -command {::CalaPhot::AffichageVariable $::CalaPhot::parametres(mode) $audace(base).saisie.listes.canevas $audace(base).saisie.listes.yscroll $audace(base).saisie.listes.canevas.t}
            incr colonne
            grid $t2.bmode$choix \
                -sticky w \
                -row $ligne \
                -column $colonne
        }

        set ligne 2
        foreach champ {type_images date_images tri_images pose_minute format_sortie reprise_astres} \
                valeur(0) {non_recalees debut_pose non seconde cdr non} \
                valeur(1) {recalees milieu_pose oui minute canopus oui} {
                Message debug "choix=%s\n" $valeur(0)
            label $t2.l$champ \
                -text $calaphot(texte,$champ)
            set colonne 0
            grid $t2.l$champ \
                -row $ligne \
                -column $colonne \
                -sticky w
            for {set i 0} {$i <= 1} {incr i} {
                radiobutton $t.trame2.b$i$champ \
                    -variable ::CalaPhot::parametres($champ) \
                    -text $calaphot(texte,${champ}_${i}) \
                    -value $valeur($i)
                incr colonne
                grid $t2.b$i$champ \
                    -row $ligne \
                    -column $colonne \
                    -sticky w
            }
            incr ligne
        }
        #--------------------------------------------------------------------------------
        # Trame specifique au mode ouverture
        frame $t.trame_ouv \
            -borderwidth 5 \
            -relief groove
        label $t.trame_ouv.titre \
            -text $calaphot(texte,param_ouverture)
        grid $t.trame_ouv.titre \
            -in $t.trame_ouv \
            -columnspan 2

        foreach champ {surechantillonage rayon1 rayon2 rayon3} {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame_ouv.l$champ \
                -text $calaphot(texte,o_$champ)
            entry $t.trame_ouv.e$champ \
                -textvariable ::CalaPhot::parametres($champ) \
                -width 3 \
                -relief sunken
            $t.trame_ouv.e$champ delete 0 end
            $t.trame_ouv.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame_ouv.l$champ $t.trame_ouv.e$champ
        }
        #--------------------------------------------------------------------------------
        # Trame specifique au mode modelisation
        frame $t.trame_mod \
            -borderwidth 5 \
            -relief groove

        #--------------------------------------------------------------------------------
        # Trame specifique au mode sextractor
        frame $t.trame_sex \
            -borderwidth 5 \
            -relief groove
        label $t.trame_sex.titre \
            -text $calaphot(texte,param_sextractor)
        grid $t.trame_sex.titre \
            -in $t.trame_sex \
            -columnspan 2

        foreach champ {saturation} {
            set valeur_defaut($champ) $::CalaPhot::parametres($champ)
            label $t.trame_sex.l$champ \
                -text $calaphot(texte,s_$champ)
            entry $t.trame_sex.e$champ \
                -textvariable ::CalaPhot::parametres($champ) \
                -width 7 \
                -relief sunken
            $t.trame_sex.e$champ delete 0 end
            $t.trame_sex.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame_sex.l$champ $t.trame_sex.e$champ
        }

        #--------------------------------------------------------------------------------
        # Trame des boutons.
        set t3 [frame $t.trame3 \
            -borderwidth 5 \
            -relief groove]
        button $t3.b1 \
            -text $calaphot(texte,continuer) \
            -command {::CalaPhot::ValideSaisie}
        button $t3.b2 \
            -text $calaphot(texte,annuler) \
            -command {::CalaPhot::AnnuleSaisie}
        button $t3.b3 \
            -text $calaphot(texte,aide) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::CalaPhot::getPluginType ] ] \
               [ ::CalaPhot::getPluginDirectory ] [ ::CalaPhot::getPluginHelp ]"
        pack $t3.b1 $t3.b2 $t3.b3 \
            -side left \
            -padx 10 \
            -pady 10
        AffichageVariable $parametres(mode) $c $y $t

        tkwait window $audace(base).saisie
    }

    #*************************************************************************#
    #*************  SelectionneEtoiles  **************************************#
    #*************************************************************************#
    #                                                                         #
    # Variables modifiees                                                     #
    #  - nombre_reference : incremente si l'etoile de ref. n'a pas deja ete   #
    #    selectionnee                                                         #
    #  - coord_etoile_x et _y : liste des coord. des etoiles de ref.          #
    #  - flux_premiere_etoile : flux de la premiere etoile de ref. Sert au    #
    #    calcul des magnitudes semi-automatiques pour les autres ref.         #
    #  - mag_etoile :                                                         #
    #  - mag :                                                                #
    #                                                                         #
    #*************************************************************************#
    proc SelectionneEtoiles {} {
        global audace color
        variable data_script
        variable parametres
        variable mag
        variable calaphot
        variable coord_etoile_x
        variable coord_etoile_y
        variable mag_etoile
        variable flux_premiere_etoile

        Message debug "%s\n" [info level [info level]]

        if {[winfo exists $audace(base).saisie.magnitude]} {
            return
        }

        # Pour simplifier les ecritures
        set boite $parametres(tailleboite)

        set mag 0.0

        set pos [Centroide]
        if {[llength $pos] != 0} {
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]

            # Recherche si l'etoile a deja ete selectionnee
            if {[info exists coord_etoile_x]} {
                set ix [lsearch $coord_etoile_x $cx]
                set iy [lsearch $coord_etoile_y $cy]
            } else {
                set ix -1
                set iy -1
            }
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                tk_messageBox -message $calaphot(texte,etoile_prise) -icon error -title $calaphot(texte,probleme)
            } else {
                # Cas d'une nouvelle etoile
                lappend coord_etoile_x $cx
                lappend coord_etoile_y $cy

                # Calcul pour le pre-affichage des valeurs de magnitudes
                set cxx [expr int(round($cx))]
                set cyy [expr int(round($cy))]
                set q [jm_fitgauss2d $audace(bufNo) [list [expr $cxx - $boite] [expr $cyy - $boite] [expr $cxx + $boite] [expr $cyy + $boite]]]
                if {![info exists flux_premiere_etoile]} {
                    set mag_affichage 13.5
                    if {[lindex $q 1] != 0} {
                        set flux_premiere_etoile [lindex $q 12]
                    }
                } else {
                    if {[lindex $q 1] != 0} {
                        set mag_affichage [format "%4.1f" [expr [lindex $mag_etoile 0] - 2.5 * log10([lindex $q 12] / $flux_premiere_etoile)]]
                    } else {
                        set mag_affichage 13.5
                    }
                }

                # Dessin d'un symbole
                Dessin ovale [list $cx $cy] [list $boite $boite] $color(green) etoile_${cx}_${cy}
                Dessin verticale [list $cx $cy] [list $boite $boite] $color(green) etoile_${cx}_${cy}
                Dessin horizontale [list $cx $cy] [list $boite $boite] $color(green) etoile_${cx}_${cy}

                # Construction de la fenetre demandant la magnitude
                toplevel $audace(base).saisie_magnitude -borderwidth 2 -bg $audace(color,backColor) -relief groove
                wm geometry $audace(base).saisie_magnitude +650+300
                wm title $audace(base).saisie_magnitude $calaphot(texte,magnitude)
                wm transient $audace(base).saisie_magnitude .audace
                wm protocol $audace(base).saisie_magnitude WM_DELETE_WINDOW ::CalaPhot::Suppression

                frame $audace(base).saisie_magnitude.trame1
                label $audace(base).saisie_magnitude.trame1.lmagnitude -text $calaphot(texte,magnitude) -bg $audace(color,backColor)
                entry $audace(base).saisie_magnitude.trame1.emagnitude -width 5 -textvariable ::CalaPhot::mag -relief sunken
                $audace(base).saisie_magnitude.trame1.emagnitude delete 0 end
                $audace(base).saisie_magnitude.trame1.emagnitude insert 0 $mag_affichage
                grid $audace(base).saisie_magnitude.trame1.lmagnitude $audace(base).saisie_magnitude.trame1.emagnitude -sticky news

                frame $audace(base).saisie_magnitude.trame2 -borderwidth 2 -relief groove -bg $audace(color,backColor2)
                button $audace(base).saisie_magnitude.trame2.b1 -text $calaphot(texte,valider) -command {destroy $audace(base).saisie_magnitude}
                pack $audace(base).saisie_magnitude.trame2.b1 -in $audace(base).saisie_magnitude.trame2 -side left -padx 10 -pady 10

                pack $audace(base).saisie_magnitude.trame1 $audace(base).saisie_magnitude.trame2 -in $audace(base).saisie_magnitude -fill x
                ::confColor::applyColor $audace(base).saisie_magnitude
                focus $audace(base).saisie_magnitude.trame1.emagnitude
                grab $audace(base).saisie_magnitude
                tkwait window $audace(base).saisie_magnitude
                lappend mag_etoile $mag
                incr data_script(nombre_reference)
            }
        }
    }

    #*************************************************************************#
    #*************  SelectionneIndesirables  *********************************#
    #*************************************************************************#
    proc SelectionneIndesirables {} {
        global audace color
        variable data_script
        variable parametres
        variable calaphot
        variable coord_indes_x
        variable coord_indes_y

        Message debug "%s\n" [info level [info level]]

        set pos [Centroide]
        if {[llength $pos] != 0} {
            set cx [lindex $pos 0]
            set cy [lindex $pos 1]

            # Recherche si l'etoile a ete deselectionnee
            if {[info exists coord_indes_x]} {
                set ix [lsearch $coord_indes_x $cx]
                set iy [lsearch $coord_indes_y $cy]
            } else {
                set ix -1
                set iy -1
            }
            if {($ix >=0) && ($iy >=0) && ($ix == $iy)} {
                tk_messageBox -message $calaphot(texte,etoile_prise) -icon error -title $calaphot(texte,probleme)
            } else {
                # Cas d'une nouvelle etoile
                lappend coord_indes_x $cx
                lappend coord_indes_y $cy
                incr data_script(nombre_indes)
                set i $data_script(nombre_indes)

                # Dessin d'un symbole
                set taille $parametres(tailleboite)
                Dessin ovale [list $cx $cy] [list $taille $taille] $color(red) etoile_${cx}_${cy}
                Dessin verticale [list $cx $cy] [list $taille $taille] $color(red) etoile_${cx}_${cy}
                Dessin horizontale [list $cx $cy] [list $taille $taille] $color(red) etoile_${cx}_${cy}
                Message debug "Etoile indes n%d x=%f y=%f\n" $data_script(nombre_indes) $cx $cy
            }
        } else {
            Message debug "Etoile indesirable introuvable\n"
        }
    }

    #*************************************************************************#
    #*************  SuppressionEtoile  ***************************************#
    #*************************************************************************#
    proc SuppressionEtoile {image j} {
        global audace
        variable parametres
        variable pos_reel

        Message debug "%s\n" [info level [info level]]

        set largeur $parametres(tailleboite)

        set x1 [expr round([lindex $pos_reel($image,indes,$j) 0] - $largeur)]
        set y1 [expr round([lindex $pos_reel($image,indes,$j) 1] - $largeur)]
        set x2 [expr round([lindex $pos_reel($image,indes,$j) 0] + $largeur)]
        set y2 [expr round([lindex $pos_reel($image,indes,$j) 1] + $largeur)]

        set t [jm_fitgauss2d $audace(bufNo) [list $x1 $y1 $x2 $y2] -sub]
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
        variable pos_reel

        Message debug "%s\n" [info level [info level]]

        set nombre $data_script(nombre_indes)
        set largeur $parametres(tailleboite)

        for {set j 0} {$j < $nombre} {incr j} {
            Dessin rectangle $pos_reel($image,indes,$j) [list $largeur $largeur] $color(red) etoile_$j
            SuppressionEtoile $image $j
            Visualisation optimale
        }
    }

    #*************************************************************************#
    #*************  ValideSaisie  ********************************************#
    #*************************************************************************#
    ##
    # @brief Validation generale de la saisie des parametres
    #
    # Si manquent certains champs indispensables a ce script, la fenetre de saisie des parametres est maintenue
    # sinon, elle est detruite
    proc ValideSaisie {} {
        global audace
        variable calaphot
        variable parametres
        variable data_script

        Message debug "%s\n" [info level [info level]]

        # Recherche si tous les champs critiques sont remplis.
        set pas_glop 0
        foreach champ {source  indice_premier indice_dernier tailleboite signal_bruit gain_camera bruit_lecture sortie fichier_cl} {
            if {$parametres($champ) == ""} {
                set message_erreur $calaphot(texte,champ1)
                append message_erreur $calaphot(texte,$champ)
                append message_erreur $calaphot(texte,champ2)
                tk_messageBox -message $message_erreur -icon error -title $calaphot(texte,probleme)
                set pas_glop 1
                break;
            }
        }

        # MultAster : remplacer cette ligne par qque chose dans SaisieParametres
        set data_script(nom_var_0) $parametres(objet)
        # /MultAster

        if {$pas_glop == 0} {
            destroy $audace(base).saisie
            update
        }
    }

    #*************************************************************************#
    #*************  Suppression  *********************************************#
    #*************************************************************************#
    proc Suppression {} {
        #Procedure pour bloquer la suppression des fenetres esclaves
    }
}
