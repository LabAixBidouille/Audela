#####################################################################
#
# Fichier     : bess_module.tcl
# Description : Script pour générer un fichier FITS de spectre conforme à la base de données bess
# Auteurs     : François Cochard (francois.cochard@wanadoo.fr)
#               Sur la forme, je suis parti du script calaphot de Jacques Michelet (jacques.michelet@laposte.net)
#               Par ailleurs, je m'appuie sur les routines spc_audace de Benjamin Mauclaire
# Mise à jour : 23 aout 2006
#
#####################################################################

# Définition d'un espace réservé à ce script
catch {namespace delete ::bess}
namespace eval ::bess {

    variable parametres
    variable text_bess
    variable police
    variable demande_arret
    variable test
    variable data_script
    variable data_image
    variable parametres

# L'existence de test crée le ficher debug.log
#    set test 0

    set numero_version v0.1

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

    source [file join $audace(rep_scripts) spcaudace bess_module bess_module.cap]
    source [file join $audace(rep_scripts) spcaudace spc_io.tcl]

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
        variable data_image
        variable text_bess
        variable data_script
        variable moyenne
        variable ecart_type
        variable nombre_indes
        variable liste_image
        variable vx_temp
        variable vy1_temp
        variable vy2_temp
        variable vy3_temp

#         # Chargement des librairies ressources
#         set librairie [Ressources]
#         if {$librairie != 0} {return}

#         # Initialisations diverses
#         Initialisations

        Message console "-------------- bess-%s--------\n" $::bess::numero_version
        Message console "-- (c)2006 F. Cochard --\n"
        Message console "-----------------------------------------\n"

        # Lecture du fichier de paramètres
        RecuperationParametres

        set demande_arret 0
        SaisieParametres
        SauvegardeParametres
        if {$demande_arret == 1} {
            Message console "%s\n" $text_bess(fin_anticipee)
            return
        }

        # Affichage de la bannière dans le fichier résultat
        if {[catch {open [file join $audace(rep_images) toto.log] w} fileId]} {
            Message console $fileId
            return
        }
        Message log "---------------bess-%s --------------\n" $::bess::numero_version
        Message log "-- (c)2006 F. Cochard --\n"
        Message log "-----------------------------------------\n"
        # Affiche l'heure du début de traitement
        Message consolog "%s %s\n\n" $text_bess(heure_debut) [clock format [clock seconds]]

#         # Vérification de l'existence des images
#         set erreur [Verification]
#         if {$erreur != 0} {
#             Message consolog "%s\n" $text_bess(fin_anticipee)
#             close $fileId
#             return
#         }

        # Affiche l'heure de fin de traitement
        Message consolog "\n\n%s %s\n" $text_bess(heure_fin) [clock format [clock seconds]]
        Message consolog "%s\n" $text_bess(fin_normale)

        # Ferme le fichier de sortie des résultats
        close $fileId

    }

    #*************************************************************************#
    #*************  AnnuleSaisie  ********************************************#
    #*************************************************************************#
    proc AnnuleSaisie {} {
        global audace

        variable demande_arret

        set demande_arret 1
#        EffaceMotif astres
        destroy $audace(base).saisie
        update idletasks
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
        # Si la date n'est pas au format Y2K (date+heure)
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
    #*************  Message  *************************************************#
    #*************************************************************************#
    proc Message {niveau args} {
        variable test
        variable fileId
        global audace

        switch -exact -- $niveau {
            console {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
            }
            log {
                puts -nonewline $fileId [eval [concat {format} $args]]
            }
            consolog {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
                catch {puts -nonewline $fileId [eval [concat {format} $args]]}
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
    #*************  RecuperationParametres  **********************************#
    #*************************************************************************#
    proc RecuperationParametres {} {
        global audace
        variable parametres

        # Initialisation
        if {[info exists parametres]} {unset parametres}

        # Ouverture du fichier de paramètres
        set fichier [file join $audace(rep_scripts) bess_module bess_module]

        if {[file exists $fichier]} {
            source $fichier
        }

        if {![info exists parametres(objet)]} {set parametres(objet) ""}
        if {![info exists parametres(ra)]} {set parametres(ra) ""}
        if {![info exists parametres(dec)]} {set parametres(dec) ""}
        if {![info exists parametres(datedeb)]} {set parametres(datedeb) ""}
        if {![info exists parametres(heuredeb)]} {set parametres(heuredeb) ""}
        if {![info exists parametres(exptime)]} {set parametres(exptime) ""}
        if {![info exists parametres(equipement)]} {set parametres(equipement) ""}
        if {![info exists parametres(siteobs)]} {set parametres(siteobs) ""}
        if {![info exists parametres(obs1)]} {set parametres(obs1) ""}
        if {![info exists parametres(obs2)]} {set parametres(obs2) ""}
        if {![info exists parametres(obs3)]} {set parametres(obs3) ""}
        if {![info exists parametres(fich_in)]} {set parametres(fich_in) ""}
        if {![info exists parametres(fich_out)]} {set parametres(fich_out) ""}
    }

    #*************************************************************************#
    #*************  SaisieParametres  ****************************************#
    #*************************************************************************#
    proc SaisieParametres {} {
        global audace
        variable parametres
        variable text_bess
        variable police

        # Ferme la fentre si elle est deja ouverte
        if [ winfo exists $audace(base).saisie ] {
           ::bess::AnnuleSaisie
        }

        # Construction de la fenêtre des paramètres
        toplevel $audace(base).saisie -borderwidth 2 -relief groove
        wm geometry $audace(base).saisie 600x400+320+0
        wm title $audace(base).saisie $text_bess(titre_saisie)
        wm protocol $audace(base).saisie WM_DELETE_WINDOW ::bess::Suppression

        # Construction du canevas qui va contenir toutes les trames et des ascenseurs
        set c [canvas $audace(base).saisie.canevas]

        # Construction d'une trame qui va englober toutes les listes dans le canevas
        set t [frame $c.t]
        $c create window 0 0 -anchor nw -window $t

        #--------------------------------------------------------------------------------
        # Trame des renseignements généraux
        frame $t.trame1 -borderwidth 5 -relief groove
        label $t.trame1.titre -text $text_bess(param_generaux) -font $police(titre)
        grid $t.trame1.titre -in $t.trame1 -columnspan 3 -sticky ew
        foreach champ {objet ra dec datedeb heuredeb exptime equipement siteobs obs1 obs2 obs3 fich_in fich_out} {
            set valeur_defaut($champ) $::bess::parametres($champ)
            label $t.trame1.l$champ -text $text_bess($champ) -font $police(gras)
            entry $t.trame1.e$champ -textvariable ::bess::parametres($champ) -font $police(normal) -relief sunken
            label $t.trame1.lb$champ -text $text_bess(u_$champ) -font $police(gras)
            $t.trame1.e$champ delete 0 end
            $t.trame1.e$champ insert 0 $valeur_defaut($champ)
            grid $t.trame1.l$champ $t.trame1.e$champ $t.trame1.lb$champ
        }
        pack $t.trame1 -side top -fill both -expand true

        #--------------------------------------------------------------------------------
        # Trame des boutons. Ceux-ci sont fixes (pas d'ascenseur).
        frame $t.trame3 -borderwidth 5 -relief groove

        button $t.trame3.b1 -text $text_bess(continuer) -command {::bess::ValideSaisie} -font $police(titre)
        button $t.trame3.b2 -text $text_bess(annuler) -command {::bess::AnnuleSaisie} -font $police(titre)
        pack $t.trame3.b1 -side left -padx 10 -pady 10
        pack $t.trame3.b2 -side right -padx 10 -pady 10

        pack $t.trame3 -side top -fill both -expand true

        pack $c -side left -fill both -expand true

#                 AffichageVariable 1 $c $t
        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $audace(base).saisie

        Message console "---------------bess est Ok ----------\n" $::bess::numero_version

       ### tkwait window $audace(base).saisie
    }

    #*************************************************************************#
    #*************  SauvegardeParametres  ************************************#
    #*************************************************************************#
    proc SauvegardeParametres {} {
        global audace
        variable parametres

        set nom_fichier [file join $audace(rep_scripts) bess_module bess_module.ini]
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
    #*************  Suppression  *********************************************#
    #*************************************************************************#
    proc Suppression {} {
        #Procédure pour bloquer la suppression des fenêtres esclaves
    }

    #*************************************************************************#
    #*************  ValideSaisie  ********************************************#
    #*************************************************************************#
    proc ValideSaisie {} {
        global audace
        variable text_bess
        variable parametres

        # Recherche si tous les champs critiques sont remplis.
        set pas_glop 0
        foreach champ {objet datedeb heuredeb exptime equipement siteobs obs1 fich_in fich_out} {
            if {$parametres($champ) == ""} {
                set message_erreur $text_bess(champ1)
                append message_erreur $text_bess($champ)
                append message_erreur $text_bess(champ2)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
                break;
            }
        }
       
        # ------ test de validité des différents champs:
        # Test validité Objet
         # Vérifier qu'il n'y a pas d'espace ??
        # Test validité RA
        # C'est un réel
        if {$pas_glop == 0} {
            if {!([string is double $parametres(ra)])} {
                set message_erreur $text_bess(pb_ra)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }
         # Domaine de validité

        # Test validité DEC
         # C'est un réel
        if {$pas_glop == 0} {
            if {!([string is double $parametres(dec)])} {
                set message_erreur $text_bess(pb_dec)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }
         # Domaine de validité

        # Test que RA et DEC sont tous les deux présents OU absents
        if {$pas_glop == 0} {
            if {($parametres(ra) != "" && $parametres(dec) == "") || ($parametres(ra) == "" && $parametres(dec) != "")} {
                set message_erreur $text_bess(pb_coherence_dec_ra)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }
        # Test validité Date début
        
        # Test validité Exptime
        # C'est un réel
        if {$pas_glop == 0} {
            if {!([string is double $parametres(exptime)])} {
                set message_erreur $text_bess(pb_exptime)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }
        # Domaine de validité
        # Test validité Equipement
      # Test validité SiteObs
      # Test validité obs1
        # Vérifier qu'il n'y a pas de virgule dans le nom ?
      # Test validité obs2
        # Vérifier qu'il n'y a pas de virgule dans le nom ?
      # Test validité obs3
        # Vérifier qu'il n'y a pas de virgule dans le nom ?
      # Test validité fichier d'entrée
        # Vérifier que c'est du .dat ou du .spc ou du .fit
        if {$pas_glop == 0} {
            if {[file extension $parametres(fich_in)] != ".dat" &&
                [file extension $parametres(fich_in)] != ".spc" &&
                [file extension $parametres(fich_in)] != ".fit" } {
                set message_erreur $text_bess(pb_format_fich_in)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }
        # Vérifier que le fichier existe
        if {$pas_glop == 0} {
            if {!([file exists [file join $audace(rep_images) $parametres(fich_in)]])} {
                set message_erreur $text_bess(pb_fichier_absent)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }

        # Test validité fichier de sortie
        # Vérifier qu'il n'y a pas d'extension
        if {$pas_glop == 0} {
            if {[file extension $parametres(fich_out)] != "" } {
                set message_erreur $text_bess(pb_format_fich_out)
                tk_messageBox -message $message_erreur -icon error -title $text_bess(probleme)
                set pas_glop 1
            }
        }

        # A la fin de tous les tests, on ne poursuit que si tout est Ok
        if {$pas_glop == 0} {

        # A partir de là, je fais le traitement:
        # 1 - Je transforme le fichier d'entrée en fits (routine de Benjamin)
        set racine [file rootname $parametres(fich_in)]
        switch [file extension $parametres(fich_in)] {
            ".dat" {
                spc_dat2fits $parametres(fich_in)
                buf$audace(bufNo) load [file join $audace(rep_images) "$racine.fit"]
            }
            ".spc" {
                spc_spc2fits $parametres(fich_in)
                buf$audace(bufNo) load [file join $audace(rep_images) "$racine.fit"]
                # Corriger: virer l'extension _spc à la création du fichier (cf Benjamin)
            }
            ".fit" {
                # On se contente de charger le fichier
                buf$audace(bufNo) load [file join $audace(rep_images) $parametres(fich_in)]
            }
            default {
                break
            }
        }

        # 2 - J'ajoute le mot-clé OBJNAME
        buf$audace(bufNo) setkwd [list "OBJNAME" $parametres(objet) string "Current name of the object" ""]

        # 3 - J'ajoute le mot-clé RA si il existe
        if {$parametres(ra) != ""} {
            buf$audace(bufNo) setkwd [list "RA" $parametres(ra) float "Right ascension" "deg"]
        }

        # 4 - J'ajoute le mot-clé DEC si il existe
        if {$parametres(dec) != ""} {
            buf$audace(bufNo) setkwd [list "DEC" $parametres(dec) float "Declination" "deg"]
        }

        # 5 - J'ajoute le mot-clé DATE-OBS
        set dateobs [join [list $parametres(datedeb)T$parametres(heuredeb)]]
        buf$audace(bufNo) setkwd [list "DATE-OBS" $dateobs string "Date of observation start" ""]

        # 6 - j'ajoute le mot-clé EXPTIME
        buf$audace(bufNo) setkwd [list "EXPTIME" $parametres(exptime) float "Total time of exposure" "s"]

        # 7 - j'ajoute le mot-clé BSS_INST
        buf$audace(bufNo) setkwd [list "BSS_INST" "$parametres(equipement)" string "Equipment used for acquisition" ""]

        # 8 - j'ajoute le mot-clé BSS_OBS
        buf$audace(bufNo) setkwd [list "BSS_OBS" "$parametres(siteobs)" string "Observation site" ""]

        # 9 - j'ajoute le mot-clé OBSERVER
        set obs "$parametres(obs1)"
        if {$parametres(obs2) != ""} {
            append obs ", " "$parametres(obs2)"
        }
        if {$parametres(obs3) != ""} {
            append obs ", " "$parametres(obs3)"
        }
        buf$audace(bufNo) setkwd [list "OBSERVER" "$obs" string "Observer(s)" ""]

        # 10 - j'ajoute le mot-clé CUNIT1
        buf$audace(bufNo) setkwd [list "CUNIT1" "Angstroms" string "Wavelength unit" ""]

        # 11 - j'ajoute le mot-clé CTYPE1
        buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]

        # 12 - j'ajoute le mot-clé CRPIX1
        buf$audace(bufNo) setkwd [list "CRPIX1" 1.0 float "Reference pixel" ""]

        # 13 - j'ajoute le mot-clé BSS_VHEL
        buf$audace(bufNo) setkwd [list "BSS_VHEL" 0 float "Heliocentric speed" "km/s"]

        # 14 - j'ajoute le mot-clé BSS_OBS
        buf$audace(bufNo) setkwd [list "BSS_OBS" "$parametres(siteobs)" string "Observation site" ""]

        # 15 - Ne me reste plus qu'à sauvegarder l'image
        buf$audace(bufNo) save [file join "$audace(rep_images)" "$parametres(fich_out).fit"]
        # J'efface le fichier créé par spc_dat2fits ou spc_spc2fits
        if {$racine != $parametres(fich_out) && [file extension $parametres(fich_in)] != ".fit"} {
            file delete [file join $audace(rep_images) "$racine.fit"]
        }

        # Quand tous les traitements sont termines, je ferme la fenetre
#        destroy $audace(base).saisie
#         update

        }
    }

}
# Fin du namespace bess

::bess::Principal

