#
# Fichier : gps.tcl
# Description : Panneau de synchronisation GPS
# Auteur : Jacques MICHELET
# Mise a jour $Id: gps.tcl,v 1.6 2007-04-14 08:31:28 robertdelmas Exp $
#

namespace eval ::Gps {
    variable This
    variable parametres
    variable numero_version
    variable base

    package provide gps 3.3

    source [file join [file dirname [info script]] gps.cap]
    set numero_version v3.3

    ##############################################################
    ### AffichageAltitude ########################################
    ##############################################################
    proc AffichageAltitude {ligne} {
        variable position
        variable gps
        variable couleur
        variable base

        # Récupération des infos dans la ligne
        set altitude [string range $ligne 7 end]
        set virgule [string first "," $altitude]
        if {$virgule != 0} {
            set altitude [string range $altitude 0 [expr $virgule - 1]]
            # conversion en métres
            set altitude [expr $altitude/3.2808]
            set gps(somme_altitude) [expr $gps(somme_altitude) + $altitude]
            incr gps(nombre_altitude)
            set position(altitude) [expr round($gps(somme_altitude) / $gps(nombre_altitude))]
            $base.tableau_bord.trame1.color_invariant_altitude configure -text [format "%d" $position(altitude)] -fg $couleur(donnee,valide)
        } else {
            $base.tableau_bord.color_invariant_altitude configure -text [format "%d" $position(altitude)] -fg $couleur(donnee,invalide)
        }
    }

    ##############################################################
    ### AffichageHeure ###########################################
    ##############################################################
    proc AffichageHeure {ligne temps_pc} {
        variable gps
        variable parametres
        variable couleur
        variable base

        set AAAA_pc [string range $temps_pc 0 3]
        set BB_pc [string range $temps_pc 5 6]
        set JJ_pc [string range $temps_pc 8 9]
        set HH_pc [string range $temps_pc 11 12]
        set MM_pc [string range $temps_pc 14 15]
        set SS_pc [string range $temps_pc 17 18]
        set tt [expr double([clock scan "${AAAA_pc}${BB_pc}${JJ_pc}T${HH_pc}${MM_pc}${SS_pc}"])]
        scan [string range $temps_pc 20 22] "%3d" milli_pc
        set temps_pc [expr $tt + $milli_pc/1000.0]

        # Décodage de la ligne GPS
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} \
        $ligne match type heure_gps flag lat_brute nord_sud long_brute est_ouest q1 q2 date_gps

        if {([info exists date_gps] > 0) && ([info exists heure_gps] > 0)} {
            set AA_gps [string range $date_gps 4 5]
            set BB_gps [string range $date_gps 2 3]
            set JJ_gps [string range $date_gps 0 1]
            set HH_gps [string range $heure_gps 0 1]
            set MM_gps [string range $heure_gps 2 3]
            set SS_gps [string range $heure_gps 4 5]

            set test 0
            incr test [TestEntier $AA_gps]
            incr test [TestEntier $BB_gps]
            incr test [TestEntier $JJ_gps]
            incr test [TestEntier $HH_gps]
            incr test [TestEntier $MM_gps]
            incr test [TestEntier $SS_gps]
            if {$test == 0} {
                set temps_gps [clock scan "20${AA_gps}${BB_gps}${JJ_gps}T${HH_gps}${MM_gps}${SS_gps}" -base [clock seconds]]

                set delta [expr $temps_gps - $temps_pc]
                set gps(somme_delta) [expr $gps(somme_delta) + $delta]
                incr gps(nombre_delta)
                set moyenne_delta [expr $gps(somme_delta) / $gps(nombre_delta)]
                if {([expr abs($moyenne_delta - $gps(moyenne_precedente))] < [expr $parametres(seuil_ok) / 1000.0]) && ($gps(synchro_position) == 1)} {
                    incr gps(nombre_ok)
                    if {$gps(nombre_ok) >= 10} {set gps(synchro_temps) 1} else {set gps(synchro_temps) 0}
                    if {$gps(nombre_ok) == 10} {bell}
                } else {
                    set gps(nombre_ok) 0
                    set gps(synchro_temps) 0
                }
                set gps(moyenne_precedente) $moyenne_delta

                set gps(correction) [expr ($parametres(decalage) / 1000.0) + $moyenne_delta]

                if {$gps(synchro_temps) == 0} {
                    set aspect $couleur(donnee,invalide)
                } else {
                    set aspect $couleur(donnee,valide)
                }
                $base.tableau_bord.trame1.color_invariant_temps_gps configure -text [format "%s:%s:%s" $HH_gps $MM_gps $SS_gps] -fg $aspect
                $base.tableau_bord.trame1.color_invariant_temps_pc configure -text [format "%s:%s:%s.%s" $HH_pc $MM_pc $SS_pc $milli_pc] -fg $aspect
                $base.tableau_bord.trame1.color_invariant_diff_temps configure -text [format "%9.3f" $delta] -fg $aspect
                $base.tableau_bord.trame1.color_invariant_moyenne configure -text [format "%9.3f" $moyenne_delta] -fg $aspect
                $base.tableau_bord.trame1.color_invariant_etat configure -text [format "%9.3f" [expr $parametres(decalage) / 1000.0]] -fg $aspect
                $base.tableau_bord.trame1.color_invariant_correction configure -text [format "%9.3f" $gps(correction)] -fg $aspect
            }
        }
    }

    ##############################################################
    ### AffichagePosition ########################################
    ##############################################################
    proc AffichagePosition {ligne} {
        variable gps
        variable position
        variable couleur
        variable base

        # Récupération des infos dans la ligne
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} $ligne match type heure flag lat_brute nord_sud long_brute est_ouest

        # Vérification de la synchro
        if {(![info exists lat_brute]) || (![info exists long_brute]) || (![info exists nord_sud]) || (![info exists est_ouest])} {
            set test 1
        } else {
            set test 0
            incr test [TestFlottant $lat_brute]
            incr test [TestFlottant $long_brute]
            if {[string length $nord_sud] != 1} {incr test}
            if {[string length $est_ouest] != 1} {incr test}
        }

        if {$test != 0} {
            $base.tableau_bord.trame1.color_invariant_latitude configure -text [format "%sd %s' %s\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)] -fg $couleur(donnee,invalide)
            $base.tableau_bord.trame1.color_invariant_longitude configure -text [format "%sd %s' %s\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)] -fg $couleur(donnee,invalide)
            set gps(synchro_position) 0
        } else {
            scan [string range $lat_brute 0 1] "%2d" position(DD_lat)
            scan [string range $lat_brute 2 3] "%2d" position(MM_lat)
            set position(NS) $nord_sud
            scan [string range $long_brute 0 2] "%3d" position(DD_lon)
            scan [string range $long_brute 3 4] "%2d" position(MM_lon)
            set position(EW) $est_ouest

            # Conversion des secondes (précision du 1/10 de seconde)
            scan [string range $lat_brute 5 end] "%d" ddd
            set l [string length [string range $lat_brute 5 end]]
            set position(SS_lat) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]
            scan [string range $long_brute 6 end] "%d" ddd
            set l [string length [string range $long_brute 6 end]]
            set position(SS_lon) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]

            $base.tableau_bord.trame1.color_invariant_latitude configure -text [format "%sd %s' %s\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)] -fg $couleur(donnee,valide)
            $base.tableau_bord.trame1.color_invariant_longitude configure -text [format "%sd %s' %s\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)] -fg $couleur(donnee,valide)
            set gps(synchro_position) 1
        }
    }

    ##############################################################
    ### ArretAuto ################################################
    ##############################################################
    proc ArretAuto {} {
        variable This
        variable gps
        variable etat
        variable serie
        global caption

        place forget $This.fautomatique.fautobis.barret_auto
        place $This.fautomatique.fautobis.bdemarrage_auto -x 4 -y 4 -width 76 -height 23 -anchor nw -bordermode ignore
        update idletasks

        set gps(confirmation_arret) 0
        set gps(demande_arret) 1
        if {$gps(confirmation_arret) != 1} {
            fconfigure $serie -blocking $gps(configuration_serie_blocking)
            fconfigure $serie -mode $gps(configuration_serie_mode)
            fconfigure $serie -buffering $gps(configuration_serie_buffering)
            close $serie
            Message log "%s\n" $caption(gps,fermeture_serie)
            set gps(confirmation_arret) 1
        }

        if {$gps(synchro_temps) == 0} {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled disabled normal normal disabled disabled disabled normal disabled
            }
        } else {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled normal disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled normal normal normal disabled disabled disabled normal disabled
            }
        }
        Message infos ""
        set etat repos
        set gps(heure_arret) [clock seconds]
    }

    ##############################################################
    ### ArretGPS #################################################
    ##############################################################
    proc ArretGPS {} {
        variable This
        variable base
        variable gps
        variable etat
        variable serie
        global caption

        place forget $This.fmanuel.fgps.barret_gps
        place $This.fmanuel.fgps.blancement_gps -x 4 -y 20 -width 76 -height 23 -anchor nw -bordermode ignore
        update idletasks

        set gps(confirmation_arret) 0
        set gps(demande_arret) 1
        if {$gps(confirmation_arret) != 1} {
            fconfigure $serie -blocking $gps(configuration_serie_blocking)
            fconfigure $serie -mode $gps(configuration_serie_mode)
            fconfigure $serie -buffering $gps(configuration_serie_buffering)
            close $serie
            Message consolog "%s\n" $caption(gps,fermeture_serie)
            set gps(confirmation_arret) 1
        }

        if {$gps(synchro_temps) == 0} {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled disabled normal normal disabled disabled disabled normal disabled
            }
        } else {
            if {$gps(synchro_position) == 0} {
                EtatBouton normal normal disabled normal disabled normal disabled disabled disabled normal disabled
            } else {
                EtatBouton normal normal disabled normal normal normal disabled disabled disabled normal disabled
            }
        }
        destroy $base.tableau_bord
        Message infos ""
        set etat repos
        set gps(heure_arret) [clock seconds]
    }

    ##############################################################
    ### ArretHorloge #############################################
    ##############################################################
    proc ArretHorloge {} {
        variable This
        variable horloge
        variable etat
        global caption
        global audace

        set horloge(confirmation_arret) 0
        set horloge(demande_arret) 1

        place forget $This.fmanuel.freg.barret_horloge
        place $This.fmanuel.freg.becoute_horloge -x 4 -y 20 -width 76 -height 23 -anchor nw -bordermode ignore
        update idletasks

        bind all <Key-Prior> {}
        bind all <Key-Next> {}

        EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled
        vwait ::Gps::horloge(confirmation_arret)
        Message infos ""
        Message consolog "%s %d ms\n" $caption(gps,decalage_horloge) $horloge(decalage_total)
        set etat repos
    }

    ##############################################################
    ### AvanceHorloge ############################################
    ##############################################################
    proc AvanceHorloge {} {
        variable parametres
        variable horloge

        jm_reglageheurepc [expr $parametres(reglage) + $parametres(temps_minimal)]
        incr horloge(decalage_total) $parametres(reglage)
        incr parametres(decalage) $parametres(reglage)
    }

    ##############################################################
    ### BoucleBip ################################################
    ##############################################################
    proc BoucleBip {} {
        variable horloge

        set bip 0
        while {$bip == 0} {
            set temps_pc [jm_heurepc]
            if {[string index $temps_pc 20] == "0"} {
                if {$horloge(demande_arret) != 1} {bell}
                set bip 1
            }
        }
        set heure_pc [string range $temps_pc 11 end]
        Message infos "%s:%s:%s.%s" [string range $heure_pc 0 1] [string range $heure_pc 3 4] [string range $heure_pc 6 7] [string range $heure_pc 9 end]
        if {$horloge(demande_arret) != 1} {
            after 950 ::Gps::BoucleBip
        } else {
            set horloge(confirmation_arret) 1
        }
    }

    ##############################################################
    ### Calibration ##############################################
    ##############################################################
    proc Calibration {} {
       global caption

       set catchResult [ catch {
          set temps [time {jm_reglageheurepc 0} 10]
          set micro [string first "micro" $temps]
          set milli [expr [string range $temps 0 [expr $micro - 2]] / 1000]
          if {$milli < 0} {
             return [expr -$milli]
          } else {
             return $milli
          }
       } ]
       if { $catchResult == "1" } {
          tk_messageBox -title $caption(gps,ecoute_horloge) -type ok -icon warning -message "$::errorInfo"
          ::Gps::ArretHorloge
          return "55"
       }
    }

    ##############################################################
    ### createPanel ##############################################
    ##############################################################
    proc createPanel {this} {
        global panneau caption conf audace color
        variable This
        variable parametres
        variable couleur
        variable police

        if {[catch {load libjm[info sharedlibextension]} chargement_lib]} {
            Message console "%s\n" $chargement_lib
            return 1
        }

        if {[catch {jm_versionlib} version_lib]} {
            Message console "%s\n" $caption(gps,mauvaise_version)
            return 1
        } else {
            if {[expr double([string range $version_lib 0 2])] < 3.0} {
                Message console "%s\n" $caption(gps,mauvaise_version)
                return 1
            }
        }

        set This $this

        set couleur(donnee,invalide) $color(red)
        set couleur(donnee,valide) $color(green)
        set couleur(fond,entree) $color(black)

        set police(gras) {arial 10 bold}
        set police(italique) {arial 10 italic}
        set police(normal) {arial 10 normal}

        CreationPanneauGPS $This

        # Si le répertoire gps n'existe pas, le créer
        if {![file exist [file join $audace(rep_plugin) tool gps]]} {
            file mkdir [file join $audace(rep_plugin) tool gps]
        }
    }

    ##############################################################
    ### CreationFenetreGPS #######################################
    ##############################################################
    proc CreationFenetreGPS {} {
        global conf
        global caption
        variable couleur
        variable police
        variable position
        variable base


        #  Affichage de la fenêtre, et des champs de saisie avec les valeurs par   #
        #   défaut.                                                                #
        set tb [toplevel $base.tableau_bord -borderwidth 2 -relief groove]
        wm geometry $tb +150+50
        wm title $tb $caption(gps,titre_fenetre_gps)
        wm transient $tb $base
        wm protocol $tb WM_DELETE_WINDOW ::Gps::Suppression

        # Trame des champs heure
        frame $tb.trame1
        frame $tb.trame1.temps

        set valeur_defaut(temps_gps) ""
        set valeur_defaut(temps_pc) ""
        set valeur_defaut(diff_temps) ""
        set valeur_defaut(moyenne) ""
        set valeur_defaut(ecart_type) ""
        set valeur_defaut(etat) ""
        set valeur_defaut(correction) ""
        set valeur_defaut(latitude) [format "%sd %s' %s\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)]
        set valeur_defaut(longitude) [format "%sd %s' %s\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)]
        set valeur_defaut(altitude) $position(altitude)

        set apparence(temps_gps) w
        set apparence(temps_pc) w
        set apparence(diff_temps) e
        set apparence(moyenne) e
        set apparence(ecart_type) e
        set apparence(etat) e
        set apparence(correction) e
        set apparence(latitude) e
        set apparence(longitude) e
        set apparence(altitude) w

        foreach champ {temps_gps temps_pc diff_temps moyenne etat correction latitude longitude altitude} {
            label $tb.trame1.l$champ -text $caption(gps,$champ) -font $police(normal)
            label $tb.trame1.color_invariant_$champ -text $valeur_defaut($champ) -bg $couleur(fond,entree) -fg $couleur(donnee,invalide) -relief sunken -font $police(gras) -anchor $apparence($champ)
            grid $tb.trame1.l$champ $tb.trame1.color_invariant_$champ -sticky news
        }
        ::pack $tb.trame1 -fill x -side left

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $tb
        update idletask
    }

    ##############################################################
    ### CreationPanneauGPS #######################################
    ##############################################################
    proc CreationPanneauGPS {This} {
        global audace
        global panneau
        global caption
        variable couleur
        variable police
        variable parametres

        # Partie graphique
        frame $This -borderwidth 2 -height 75 -width 101 -borderwidth 2 -relief groove
        #--- Frame du titre
        frame $This.fra1 -borderwidth 2 -height 75 -relief groove -width 92
        #--- Label du titre
        Button $This.fra1.but -borderwidth 2 -text $caption(gps,titre) -font $police(gras) \
           -command {
              ::audace::showHelpPlugin tool gps gps.htm
           }
        ::pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top
        DynamicHelp::add $This.fra1.but -text $caption(gps,help,titre)
        place $This.fra1 -x 4 -y 4 -width 92 -height 22 -anchor nw -bordermode ignore

        #Trame d'affichage des paramètres
        # Construction de la trame
        set t1 [frame $This.fparametre -borderwidth 1 -width 125 -relief groove]
        # Définition des menus
        menubutton $t1.mb -text $caption(gps,parametre) -menu $t1.mb.menu -height 1 -relief raised -font $police(gras)
        ::pack $t1.mb -in $t1 -pady 4
        set m1 [menu $t1.mb.menu -tearoff 0]
        # Menus et sous-menus
        $m1 add separator
        $m1 add cascade -label $caption(gps,port) -menu $m1.sm1
        $m1 add cascade -label $caption(gps,intervalle_synchro) -menu $m1.sm2
        $m1 add command -label $caption(gps,divers) -command {::Gps::EditionsDiverses}
        set sm1 [menu $m1.sm1 -tearoff 0]
        set sm2 [menu $m1.sm2 -tearoff 0]
        # Les sous-menus des ports et des intervalles de synchro sont créés plus tard pour tenir compte des paramétres initialisés ultérieurement
        # Positionnement de la trame
        place $t1 -x 4 -y 32 -width 92 -anchor nw -bordermode ignore

        #Trame Commande Manuel (t2)
        set t2 [frame $This.fmanuel -borderwidth 1 -relief groove -width 125]
        label $t2.l -text $caption(gps,manuel) -font $police(gras)
       ::pack $t2.l -fill x -side top

        #Trame du GPS (t21)
        set t21 [frame $t2.fgps -borderwidth 1 -relief groove -width 120]
        label $t21.l -text $caption(gps,titre_gps) -font $police(gras)
        ::pack $t21.l -fill x -side top
        # Génération des boutons
        set commande(lancement_gps) ::Gps::LancementGPS
        set commande(arret_gps) ::Gps::ArretGPS
        set commande(synchro_temps) ::Gps::SynchroTempsGPS
        set commande(synchro_position) ::Gps::SynchroPositionGPS
        set place(lancement_gps) 20
        set place(arret_gps) 20
        set place(synchro_temps) 47
        set place(synchro_position) 74

        foreach champ {lancement_gps arret_gps synchro_temps synchro_position} {
            button $t21.b$champ -text $caption(gps,$champ) -command $commande($champ) -font $police(gras)
            place $t21.b$champ -x 4 -y $place($champ) -width 76 -height 23 -anchor nw -bordermode ignore
        }
        place $t21 -x 4 -y 20 -width 84 -height 101 -anchor nw -bordermode ignore
        place forget $t21.barret_gps

        # Trame du réglage fin (t22)
        set t22 [frame $t2.freg -borderwidth 1 -relief groove -width 125]
        label $t22.l -text $caption(gps,titre_reglage_fin) -font $police(gras)
        ::pack $t22.l -fill x -side top
        set commande(ecoute_horloge) ::Gps::EcouteHorloge
        set commande(arret_horloge) ::Gps::ArretHorloge
        set commande(avance) {::Gps::AvanceHorloge}
        set commande(retard) {::Gps::RetardHorloge }
        set place(ecoute_horloge) 20
        set place(arret_horloge) 20
        set place(avance) 47
        set place(retard) 74
        foreach champ {ecoute_horloge arret_horloge avance retard} {
            button $t22.b$champ -text $caption(gps,$champ) -command $commande($champ) -font $police(gras)
            place $t22.b$champ -x 4 -y $place($champ) -width 76 -height 23 -anchor nw -bordermode ignore
        }
        place $t22 -x 4 -y 128 -width 84 -height 101 -anchor nw -bordermode ignore
        place forget $t22.barret_horloge

        place $t2 -x 4 -y 74 -width 92 -height 233 -anchor nw -bordermode ignore

        #Trame Commande Automatique (t3)
        set t3 [frame $This.fautomatique -borderwidth 1 -relief groove -width 125]
        label $t3.l -text $caption(gps,automatique) -font $police(gras)
        ::pack $t3.l -fill x -side top

        set t31 [frame $t3.fautobis -borderwidth 1 -relief groove -width 120]
        set commande(demarrage_auto) ::Gps::DemarrageAuto
        set commande(arret_auto) ::Gps::ArretAuto
        set place(demarrage_auto) 4
        set place(arret_auto) 4
        foreach champ {demarrage_auto arret_auto} {
            button $t31.b$champ -text $caption(gps,$champ) -command $commande($champ) -font $police(gras)
            place $t31.b$champ -x 4 -y $place($champ) -width 76 -height 23 -anchor nw -bordermode ignore
        }
        place $t31 -x 4 -y 20 -width 84 -height 31 -anchor nw -bordermode ignore
        place forget $t31.barret_auto

        place $t3 -x 4 -y 315 -width 92 -height 55 -anchor nw -bordermode ignore

        # Etats d'activation des boutons
        EtatBouton normal normal disabled disabled disabled normal disabled disabled disabled normal disabled

        # Trame des infos (couleurs fixes)
        set t4 [frame $This.finfos -borderwidth 1 -relief groove -width 125]
        label $t4.color_invariant -bg $couleur(fond,entree) -fg $couleur(donnee,valide) -font $police(gras)
        ::pack $t4.color_invariant -fill both -side top
        place $t4 -x 4 -y 380 -width 92 -height 20 -anchor nw -bordermode ignore

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $This
    }

    ##############################################################
    ### DemarrageAuto ############################################
    ##############################################################
    proc DemarrageAuto {} {
        global caption
        global gps_reveil_synchro
        variable This
        variable parametres
        variable serie
        variable gps
        variable etat
        variable test

        if {[catch {open $parametres(port_serie) r+} serie]} {
            tk_messageBox -type ok -message $caption(gps,conseil_serie) -title $caption(gps,erreur) -icon error
            return
        }

        set etat automatique

        place forget $This.fautomatique.fautobis.bdemarrage_auto
        place $This.fautomatique.fautobis.barret_auto -x 4 -y 4 -width 76 -height 23 -anchor nw -bordermode ignore
        update idletasks

        EtatBouton disabled disabled disabled disabled disabled disabled disabled disabled disabled disabled normal

        set gps(nombre_delta) 0
        set gps(somme_delta) 0
        set gps(nombre_ok) 0
        set gps(nombre_echec) 0
        set gps(moyenne_precedente) 0
        set gps(somme_altitude) 0.0
        set gps(nombre_altitude) 0
        set gps(synchro_temps) 0
        set gps(synchro_position) 0
        set gps(demande_arret) 0

        set gps(message_GPRMC) "\$GPRMC"
        set gps(message_PGRMZ) "\$PGRMZ"

        Message infos $caption(gps,attente_nmea)
        Message log "%s %s\n" $caption(gps,ouverture_serie) $parametres(port_serie)

        # Sauvegarde de la configuration du port série
        set gps(configuration_serie_blocking) [fconfigure $serie -blocking]
        set gps(configuration_serie_mode) [fconfigure $serie -mode]
        set gps(configuration_serie_buffering) [fconfigure $serie -buffering]

        # Changement de vitesse
        fconfigure $serie -mode "4800,n,8,1" -blocking 0 -buffering line

        set gps(erreur_lecture) 0
        set gps_reveil_synchro 0
        # Gestion de la liaison série par filevent
        fileevent $serie readable [list ::Gps::TraitementLigneMuet $serie]

        # Début de la boucle de synchro automatique
        SynchronisationAutomatique
    }

    ##############################################################
    ### EcouteHorloge ############################################
    ##############################################################
    proc EcouteHorloge {} {
        variable This
        variable horloge
        variable etat

        set etat horloge

        place forget $This.fmanuel.freg.becoute_horloge
        place $This.fmanuel.freg.barret_horloge -x 4 -y 20 -width 76 -height 23 -anchor nw -bordermode ignore
        update idletasks
        EtatBouton disabled disabled disabled disabled disabled disabled normal normal normal disabled disabled

        bind all <Key-Prior> {::Gps::AvanceHorloge}
        bind all <Key-Next> {::Gps::RetardHorloge}

        set horloge(demande_arret) 0
        set horloge(decalage_total) 0
        update idletasks
        # Calibration
        set parametres(temps_minimal) [Calibration]

        BoucleBip
    }

    ##############################################################
    ### EditionsDiverses #########################################
    ##############################################################
    proc EditionsDiverses {} {
        variable parametres
        global caption
        variable police
        variable base

        set d [toplevel $base.divers -borderwidth 2 -relief groove]
        wm geometry $d +150+50
        wm title $d $caption(gps,titre_parametres)
        wm transient $d $base
        wm protocol $d WM_DELETE_WINDOW ::Gps::Suppression

        set t1 [frame $d.trame1]
        foreach champ {decalage seuil_ok reglage} {
            label $t1.l$champ -text $caption(gps,$champ) -font $police(normal)
            entry $t1.e$champ -textvariable ::Gps::parametres($champ) -font $police(normal) -relief sunken -width 4
            grid $t1.l$champ $t1.e$champ -sticky news
        }

        set t2 [frame $d.trame2 -borderwidth 2 -relief groove]
        button $t2.b1 -text $caption(gps,valider) -command {::Gps::ValideSaisie} -font $police(gras) -height 1
        ::pack $t2.b1 -side top -padx 10 -pady 10

        ::pack $t1 $t2 -fill x

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $d
    }

    ##############################################################
    ### EtatBoutons ##############################################
    ##############################################################
    proc EtatBouton {e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 e10} {
        variable This

        $This.fparametre.mb configure -state $e0
        $This.fmanuel.fgps.blancement_gps configure -state $e1
        $This.fmanuel.fgps.barret_gps configure -state $e2
        $This.fmanuel.fgps.bsynchro_temps configure -state $e3
        $This.fmanuel.fgps.bsynchro_position configure -state $e4
        $This.fmanuel.freg.becoute_horloge configure -state $e5
        $This.fmanuel.freg.barret_horloge configure -state $e6
        $This.fmanuel.freg.bavance configure -state $e7
        $This.fmanuel.freg.bretard configure -state $e8
        $This.fautomatique.fautobis.bdemarrage_auto configure -state $e9
        $This.fautomatique.fautobis.barret_auto configure -state $e10
    }

    ##############################################################
    ### getPluginTitle ###########################################
    ##############################################################
    proc getPluginTitle { } {
        global caption

        return "$caption(gps,titre)"
    }

    ##############################################################
    ### getPluginType ############################################
    ##############################################################
    proc getPluginType { } {
        return "tool"
    }

    ##############################################################
    ### getPluginProperty ########################################
    ##############################################################
    proc getPluginProperty { propertyName } {
        switch $propertyName {
            function     { return "utility" }
            subfunction1 { return "gps" }
            display      { return "panel" }
        }
    }

    ##############################################################
    ### initPlugin ###############################################
    ##############################################################
    proc initPlugin { tkbase } {

    }

    ##############################################################
    ### createPluginInstance #####################################
    ##############################################################
    proc createPluginInstance { { in "" } { visuNo 1 } } {
        variable base

        set base $in
        createPanel $in.gps
    }

    ##############################################################
    ### deletePluginInstance #####################################
    ##############################################################
    proc deletePluginInstance { visuNo } {

    }

    ##############################################################
    ### Initialisation ###########################################
    ##############################################################
    proc Initialisation {This} {
        global audace
        global conf
        global caption
        variable position
        variable parametres
        variable numero_version
        variable etat

        if {[info exists etat]} {
            if {$etat == "automatique"} {return}
        }

        # Récupération des informations de position
        set d [string first "d" $conf(posobs,lat)]
        set m [string first "m" $conf(posobs,lat)]
        set s [string first "s" $conf(posobs,lat)]
        if {[expr $d * $m * $s] <= 0} {
            # il manque un champ
            set position(DD_lat) 45
            set position(MM_lat) 0
            set position(SS_lat) 0
        } else {
            set position(DD_lat) [string range $conf(posobs,lat) 0 [expr $d - 1]]
            set position(MM_lat) [string range $conf(posobs,lat) [expr $d + 1] [expr $m - 1]]
            set position(SS_lat) [string range $conf(posobs,lat) [expr $m + 1] [expr $s - 1]]
        }
        set position(NS) $conf(posobs,nordsud)

        set d [string first "d" $conf(posobs,long)]
        set m [string first "m" $conf(posobs,long)]
        set s [string first "s" $conf(posobs,long)]
        if {[expr $d * $m * $s] <= 0} {
            set position(DD_lon) 0
            set position(MM_lon) 0
            set position(SS_lon) 0
        } else {
            set position(DD_lon) [string range $conf(posobs,long) 0 [expr $d - 1]]
            set position(MM_lon) [string range $conf(posobs,long) [expr $d + 1] [expr $m - 1]]
            set position(SS_lon) [string range $conf(posobs,long) [expr $m + 1] [expr $s - 1]]
        }

        set position(EW) $conf(posobs,estouest)
        set position(altitude) $conf(posobs,altitude)

        # Ouverture du fichier de paramètres
        set fichier [file join $audace(rep_plugin) tool gps gps.ini]
        if {[file exists $fichier]} {
            source $fichier
        }
        if {![info exists parametres(os)]} {set parametres(os) $::tcl_platform(os)}
        if {![info exists parametres(port_serie)]} {set parametres(port_serie) [lindex $audace(list_com) 0]}
        # Cas du changement d'OS
        if {$parametres(os) != $::tcl_platform(os)} {set parametres(port_serie) [lindex $audace(list_com) 0]}
        if {![info exists parametres(seuil_ok)]} {set parametres(seuil_ok) 20}
        if {![info exists parametres(decalage)]} {set parametres(decalage) 0}
        if {![info exists parametres(reglage)]} {set parametres(reglage) 100}
        if {![info exists parametres(temps_minimal)]} {set parametres(temps_minimal) 55}
        if {![info exists parametres(mise_heure)]} {set parametres(mise_heure) [clock seconds]}
        if {![info exists parametres(choix_synchro)]} {set parametres(choix_synchro) [list 60 120 300 600 1800 3600 7200]}
        if {![info exists parametres(intervalle_synchro)]} {set parametres(intervalle_synchro) [lindex $parametres(choix_synchro) 0]}

        # Sous-menu des ports
        foreach port $audace(list_com) {
            $This.fparametre.mb.menu.sm1 add radio -label $port -variable ::Gps::parametres(port_serie) -value $port
        }
        # Sous-menu des intervalles de synchro
        foreach intervalle $parametres(choix_synchro) {
            $This.fparametre.mb.menu.sm2 add radio -label $intervalle -variable ::Gps::parametres(intervalle_synchro) -value $intervalle
        }


        Message consolog "----------%s %s ----------\n" $caption(gps,bienvenue) $numero_version
        Message consolog "%s\n" $caption(gps,copyright)
        set etat repos
    }

    ##############################################################
    ### LancementGPS #############################################
    ##############################################################
    proc LancementGPS {} {
        global caption
        variable This
        variable parametres
        variable serie
        variable gps
        variable etat
        variable test

        if {[catch {open $parametres(port_serie) r+} serie]} {
            tk_messageBox -type ok -message $caption(gps,conseil_serie) -title $caption(gps,erreur) -icon error
            return
        }

        # Sauvegarde de la configuration du port série
        if {[catch {fconfigure $serie -blocking} confserie]} {
            tk_messageBox -type ok -message $caption(gps,non_rs232) -title $caption(gps,erreur) -icon error
            return
        } else {
            set gps(configuration_serie_blocking) $confserie
        }

        if {[catch {fconfigure $serie -mode} confserie]} {
            tk_messageBox -type ok -message $caption(gps,non_rs232) -title $caption(gps,erreur) -icon error
            return
        } else {
            set gps(configuration_serie_mode) $confserie
        }

        if {[catch {fconfigure $serie -buffering} confserie]} {
            tk_messageBox -type ok -message caption(gps,non_rs232) -title $caption(gps,erreur) -icon error
            return
        } else {
            set gps(configuration_serie_buffering) $confserie
        }

        set etat gps

        place forget $This.fmanuel.fgps.blancement_gps
        place $This.fmanuel.fgps.barret_gps -x 4 -y 20 -width 76 -height 23 -anchor nw -bordermode ignore
        update idletasks

        EtatBouton disabled disabled normal disabled disabled disabled disabled disabled disabled disabled disabled

        CreationFenetreGPS

        set gps(nombre_delta) 0
        set gps(somme_delta) 0
        set gps(nombre_ok) 0
        set gps(moyenne_precedente) 0
        set gps(somme_altitude) 0.0
        set gps(nombre_altitude) 0
        set gps(synchro_temps) 0
        set gps(synchro_position) 0
        set gps(demande_arret) 0

        set gps(message_GPRMC) "\$GPRMC"
        set gps(message_PGRMZ) "\$PGRMZ"

        Message infos $caption(gps,attente_nmea)
        Message consolog "%s %s\n" $caption(gps,ouverture_serie) $parametres(port_serie)

        # Changement de vitesse
        fconfigure $serie -mode "4800,n,8,1" -blocking 0 -buffering line

        set gps(erreur_lecture) 0

        # Gestion par filevent
        fileevent $serie readable [list ::Gps::TraitementLigne $serie]
    }

    ##############################################################
    ### Message ##################################################
    ##############################################################
    proc Message {niveau args} {
        global audace
        variable This

        switch -exact -- $niveau {
            console {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
            }
           test {
                ::console::disp "Test : "
                ::console::disp [eval [concat {format} $args]]
            }
            infos {
                $This.finfos.color_invariant configure -text [eval [concat {format} $args]]
                update idletasks
            }
            consolog {
                ::console::disp [eval [concat {format} $args]]
                set nom_fichier [file join $audace(rep_plugin) tool gps gps.log]
                if [catch {open $nom_fichier a} fichier] {
                    ::console::disp $fichier
                    ::console::disp "\n"
                } else {
                    puts -nonewline $fichier $audace(tu,format,dmyhmsint)
                    puts -nonewline $fichier "  "
                    puts -nonewline $fichier [eval [concat {format} $args]]
                    close $fichier
                }
                update idletasks
            }
            log {
                set nom_fichier [file join $audace(rep_plugin) tool gps gps.log]
                if [catch {open $nom_fichier a} fichier] {
                    ::console::disp $fichier
                    ::console::disp "\n"
                } else {
                    puts -nonewline $fichier $audace(tu,format,dmyhmsint)
                    puts -nonewline $fichier "  "
                    puts -nonewline $fichier [eval [concat {format} $args]]
                    close $fichier
                }
                update idletasks
            }
            default {
                ::console::disp "Erreur dans la gestion des messages\n"
            }
        }
    }

    ##############################################################
    ### startTool ################################################
    ##############################################################
    proc startTool { visuNo } {
       variable This

        Initialisation $This
        pack $This -anchor center -expand 0 -fill y -side left
    }

    ##############################################################
    ### RetardHorloge ############################################
    ##############################################################
    proc RetardHorloge {} {
        variable parametres
        variable horloge

        jm_reglageheurepc [expr -$parametres(reglage) + $parametres(temps_minimal)]
        incr horloge(decalage_total) [expr -$parametres(reglage)]
        incr parametres(decalage) [expr -$parametres(reglage)]
    }

    ##############################################################
    ### Suppression ##############################################
    ##############################################################
    proc Suppression {} {
        # Empêche certaines fenêtres d'être effacées
    }

    ##############################################################
    ### SynchronisationAutomatique ###############################
    ##############################################################
    proc SynchronisationAutomatique {} {
        global audace
        global caption
        global gps_synchro_temps
        global gps_reveil_synchro
        variable gps
        variable parametres

        while {$gps(demande_arret) == 0} {
            Message log "Recherche synchro\n"
            set gps(temps_synchro) 0
            set gps(nombre_ok) 0
            set gps(nombre_delta) 0
            set gps(nombre_echec) 0
            set gps(somme_delta) 0.0
            # Attente de ce que l'écart t_gps - t_pc se stabilise ou bien
            # que la synchro ne s'est pas faite
            set heure_debut_synchro [clock seconds]
            set gps_synchro_temps 0
            vwait gps_synchro_temps

            if {$gps(synchro_temps) == 1} {
                # La synchro s'est faite

                # Mise à l'heure du PC
                # Le GPS est synchrone du PC, reste à le recaler
                set corr_milli [expr round($gps(correction) * 1000)]
                jm_reglageheurepc $corr_milli
                set message [concat $caption(gps,m_synchro_temps_1) [format "%9.3f" $gps(correction)] $caption(gps,m_synchro_temps_2)]
                Message log "%s\n" $message
                set gps(heure_arret) [clock seconds]

                # Calcul de la dérive
                set diff_temps [expr $gps(heure_arret) - $parametres(mise_heure)]
                set derive [expr 3600000.0 * $gps(correction) / $diff_temps]
                set message [concat $caption(gps,derive) [format "%9.3f" $derive] " ms/h"]
                Message log "%s\n" $message
                set parametres(mise_heure) [clock seconds]

                # Calcul du temps qu'a requis la synchro qui sera déduit du temps
                #  à attendre pour le réveil
                set heure_fin_synchro [clock seconds]
                set temps_requis_synchro [expr $heure_fin_synchro - $heure_debut_synchro]
                # Attente de la phase de réveil
                set gps(temps_synchro) [expr $gps(temps_gps) + $parametres(intervalle_synchro) - $temps_requis_synchro]
                set gps_reveil_synchro 0
                vwait gps_reveil_synchro
            } else {
                # La synchro ne s'est pas faite
                Message consolog "Pas de synchro\n"
            }
        }

    }

    ##############################################################
    ### SynchroPositionGPS #######################################
    ##############################################################
    proc SynchroPositionGPS {} {
        variable position
        global conf
        global caption
        global audace

        # Mise à jour des champs de configuration
        set conf(posobs,lat) $position(DD_lat)
        append conf(posobs,lat) "d" $position(MM_lat) "m" $position(SS_lat) "s"
        set conf(posobs,nordsud) $position(NS)
        set conf(posobs,long) $position(DD_lon)
        append conf(posobs,long)  "d" $position(MM_lon) "m" $position(SS_lon) "s"
        set conf(posobs,estouest) $position(EW)
        set conf(posobs,altitude) $position(altitude)

        # Mise à jour du format GPS
        set SDD_lat $position(DD_lat)
        if {$position(NS) == "S"} {
            set SDD_lat -$SDD_lat
        }
        set conf(posobs,observateur,gps) "GPS [mc_angle2deg [list $position(DD_lon) $position(MM_lon) $position(SS_lon)]] $position(EW) [mc_angle2deg [list $SDD_lat $position(MM_lat) $position(SS_lat)]] $position(altitude)"

        Message consolog "%s\n" $caption(gps,m_synchro_position_1)
        set message "\t"
        append message $caption(gps,m_synchro_position_2)
        append message [format " %2dd %2d' %3.1f\" %s" $position(DD_lat) $position(MM_lat) $position(SS_lat) $position(NS)]
        Message consolog "%s\n" $message
        set message "\t"
        append message $caption(gps,m_synchro_position_3)
        append message [format "%3dd %2d' %3.1f\" %s" $position(DD_lon) $position(MM_lon) $position(SS_lon) $position(EW)]
        Message consolog "%s\n" $message
        set message "\t"
        append message $caption(gps,m_synchro_position_4)
        append message [format "%3d m" $position(altitude)]
        Message consolog "%s\n" $message
        bell
    }

    ##############################################################
    ### SynchroTempsGPS ##########################################
    ##############################################################
    proc SynchroTempsGPS {} {
        variable gps
        variable parametres
        variable This
        global caption
        global audace

        if {$gps(synchro_temps) == 1} {
            set corr_milli [expr round($gps(correction) * 1000)]
            jm_reglageheurepc $corr_milli
            set gps(synchro_temps) 0
            $This.fmanuel.fgps.bsynchro_temps configure -state disabled
            set message [concat $caption(gps,m_synchro_temps_1) [format "%9.3f" $gps(correction)] $caption(gps,m_synchro_temps_2)]
            Message consolog "%s\n" $message
            bell

            # Calcul de la dérive
            set diff_temps [expr $gps(heure_arret) - $parametres(mise_heure)]
            set derive [expr 3600000.0 * $gps(correction) / $diff_temps]
            set message [concat $caption(gps,derive) [format "%9.3f" $derive] " ms/h"]
            Message consolog "%s\n" $message
            set parametres(mise_heure) [clock seconds]
        }
    }

    ##############################################################
    ### Terminaison ##############################################
    ##############################################################
    proc Terminaison {This} {
        global audace
        variable parametres
        variable etat
        global caption

        if {$etat == "automatique"} {return}
        if {$etat == "gps"} {ArretGPS}
        if {$etat == "horloge"} {ArretHorloge}

        Message consolog "----------%s -------------\n" $caption(gps,tchao)

        # Sauvegarde des paramètres
        set nom_fichier [file join $audace(rep_plugin) tool gps gps.ini]
        if [catch {open $nom_fichier w} fichier] {
            Message console "%s\n" $fichier
        } else {
            foreach {a b} [array get parametres] {
                puts $fichier "set parametres($a) \"$b\""
            }
            close $fichier
        }

        # Suppression des sous-menus
        $This.fparametre.mb.menu.sm1 delete 0 end
    }

    ##############################################################
    ### TestEntier #############################################
    ##############################################################
    proc TestEntier {valeur} {
        set test 0
        if {[string length $valeur] != 0} {
            for {set i 0} {$i < [string length $valeur]} {incr i} {
                set a [string index $valeur $i]
                if {![string match {[0-9]} $a]} {
                    set test 1
                }
            }
        } else {
            set test 1
        }
        return $test
    }

    ##############################################################
    ### TestFlottant #############################################
    ##############################################################
    proc TestFlottant {valeur} {
        # Envisager de le remplacer par [string is double]
        # Retourne 0 si c'est un entier, 1 dans le cas contraire
        set test 0
        if {[string length $valeur] != 0} {
            for {set i 0} {$i < [string length $valeur]} {incr i} {
                set a [string index $valeur $i]
                if {![string match {[0-9.]} $a]} {
                    set test 1
                }
            }
        } else {
            set test 1
        }
        return $test
    }

    ##############################################################
    ### TraitementHeure ###########################################
    ##############################################################
    proc TraitementHeure {ligne temps_pc} {
        global gps_synchro_temps
        global gps_reveil_synchro
        variable gps
        variable parametres

#        Message console "T_PC=%s\n" $temps_pc
        set AAAA_pc [string range $temps_pc 0 3]
        set BB_pc [string range $temps_pc 5 6]
        set JJ_pc [string range $temps_pc 8 9]
        set HH_pc [string range $temps_pc 11 12]
        set MM_pc [string range $temps_pc 14 15]
        set SS_pc [string range $temps_pc 17 18]
        set tt [expr double([clock scan "${AAAA_pc}${BB_pc}${JJ_pc}T${HH_pc}${MM_pc}${SS_pc}"])]
        scan [string range $temps_pc 20 22] "%3d" milli_pc
        set temps_pc [expr $tt + $milli_pc/1000.0]

        # Décodage de la ligne GPS
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} \
        $ligne match type heure_gps flag lat_brute nord_sud long_brute est_ouest q1 q2 date_gps

        if {([info exists date_gps] > 0) && ([info exists heure_gps] > 0)} {
            set AA_gps [string range $date_gps 4 5]
            set BB_gps [string range $date_gps 2 3]
            set JJ_gps [string range $date_gps 0 1]
            set HH_gps [string range $heure_gps 0 1]
            set MM_gps [string range $heure_gps 2 3]
            set SS_gps [string range $heure_gps 4 5]

            set test 0
            incr test [TestEntier $AA_gps]
            incr test [TestEntier $BB_gps]
            incr test [TestEntier $JJ_gps]
            incr test [TestEntier $HH_gps]
            incr test [TestEntier $MM_gps]
            incr test [TestEntier $SS_gps]
            if {$test == 0} {
                set temps_gps [clock scan "20${AA_gps}${BB_gps}${JJ_gps}T${HH_gps}${MM_gps}${SS_gps}" -base [clock seconds]]

                if {$temps_gps > $gps(temps_synchro)} {
                    set gps_reveil_synchro 1
                }
                set delta [expr $temps_gps - $temps_pc]
                set gps(somme_delta) [expr $gps(somme_delta) + $delta]
                incr gps(nombre_delta)
                set moyenne_delta [expr $gps(somme_delta) / $gps(nombre_delta)]
                if {([expr abs($moyenne_delta - $gps(moyenne_precedente))] < [expr $parametres(seuil_ok) / 1000.0]) && ($gps(synchro_position) == 1)} {
                    incr gps(nombre_ok)
                    if {$gps(nombre_ok) >= 10} {
                        set gps(synchro_temps) 1
                        # Signalisation pour le mode auto
                        set gps_synchro_temps 1
                    } else {
                        set gps(synchro_temps) 0
                    }
                    if {$gps(nombre_ok) == 10} {bell}
                } else {
                    set gps(nombre_ok) 0
                    set gps(synchro_temps) 0
                    incr gps(nombre_echec)
                    if {$gps(nombre_echec) > 50} {
                        # Signalisation pour le mode auto
                        set gps_synchro_temps 1
                    }
                }
                set gps(moyenne_precedente) $moyenne_delta
                set gps(temps_gps) $temps_gps

                set gps(correction) [expr ($parametres(decalage) / 1000.0) + $moyenne_delta]
            }
        } else {
            set gps(synchro_temps) 0
            incr gps(nombre_echec)
            if {$gps(nombre_echec) > 50} {
                # Signalisation pour le mode auto
                set gps_synchro_temps 1
            }
        }
    }

    ##############################################################
    ### TraitementLigne ##########################################
    ##############################################################
    proc TraitementLigne {serie} {
        variable gps
        variable parametres
        variable test

        if {[catch {gets $serie ligne} lecture]} {
            incr gps(erreur_lecture)

            if {$gps(erreur_lecture) > 9} {
                Message console "%s\n" $lecture
                ArretGPS
                return
            }
        } else {
            set gps(erreur_lecture) 0
            if {$lecture > 0} {
                set entete_gps [string range $ligne 0 5]
                if {[string compare $entete_gps $gps(message_GPRMC)] == 0} {
                    set temps_pc [jm_heurepc]
                    AffichageHeure $ligne $temps_pc
                    AffichagePosition $ligne
                }
                if {[string compare $entete_gps $gps(message_PGRMZ)] == 0} {
                    AffichageAltitude $ligne
                }
                if {[string index $entete_gps 0] == "\$"} {
                    Message infos $entete_gps
                }
                update idletasks
            }
        }
    }

    ##############################################################
    ### TraitementLigneMuet ######################################
    ##############################################################
    # Utilisé en mode automatique                                #
    ##############################################################
    proc TraitementLigneMuet {serie} {
        variable gps
        variable parametres
        variable test

        if {[catch {gets $serie ligne} lecture]} {
            incr gps(erreur_lecture)

            if {$gps(erreur_lecture) > 9} {
                Message console "%s\n" $lecture
                ArretGPS
                return
            }
        } else {
            set gps(erreur_lecture) 0
            if {$lecture > 0} {
                set entete_gps [string range $ligne 0 5]
                if {[string compare $entete_gps $gps(message_GPRMC)] == 0} {
                    set temps_pc [jm_heurepc]
                    TraitementHeure $ligne $temps_pc
                    TraitementPosition $ligne
                }
                if {[string index $entete_gps 0] == "\$"} {
                    Message infos $entete_gps
                }
                update idletasks
            }
        }
    }

    ##############################################################
    ### TraitementPosition ########################################
    ##############################################################
    proc TraitementPosition {ligne} {
        variable gps
        variable position

        # Récupération des infos dans la ligne
        regexp {([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)} $ligne match type heure flag lat_brute nord_sud long_brute est_ouest

        # Vérification de la synchro
        if {(![info exists lat_brute]) || (![info exists long_brute]) || (![info exists nord_sud]) || (![info exists est_ouest])} {
            set test 1
        } else {
            set test 0
            incr test [TestFlottant $lat_brute]
            incr test [TestFlottant $long_brute]
            if {[string length $nord_sud] != 1} {incr test}
            if {[string length $est_ouest] != 1} {incr test}
        }

        if {$test != 0} {
            set gps(synchro_position) 0
        } else {
            scan [string range $lat_brute 0 1] "%2d" position(DD_lat)
            scan [string range $lat_brute 2 3] "%2d" position(MM_lat)
            set position(NS) $nord_sud
            scan [string range $long_brute 0 2] "%3d" position(DD_lon)
            scan [string range $long_brute 3 4] "%2d" position(MM_lon)
            set position(EW) $est_ouest

            # Conversion des secondes (précision du 1/10 de seconde)
            scan [string range $lat_brute 5 end] "%d" ddd
            set l [string length [string range $lat_brute 5 end]]
            set position(SS_lat) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]
            scan [string range $long_brute 6 end] "%d" ddd
            set l [string length [string range $long_brute 6 end]]
            set position(SS_lon) [format "%3.1f" [expr $ddd * 60 * 1e-$l]]

            set gps(synchro_position) 1
        }
    }

    ##############################################################
    ### stopTool #################################################
    ##############################################################
    proc stopTool { visuNo } {
        variable This

        Terminaison $This
        pack forget $This
    }

    ##############################################################
    ### ValideSaisie #############################################
    ##############################################################
    proc ValideSaisie {} {
        global caption
        variable parametres
        variable base

        set test 0
        foreach champ {decalage seuil_ok reglage} {
            incr test [string is integer $parametres($champ)]
        }

        if {$test == 3} {
            destroy $base.divers
        } else {
            tk_messageBox -type ok -icon error -title $caption(gps,erreur) -message $caption(gps,type_non_entier)
        }
    }
    # fin du namespace
}

