#
# Fichier : tri_fwmh.tcl
# Description : Script pour le tri d'images par le critere de fwhm
# Auteurs : Francois Cochard et Jacques Michelet
# Mise a jour $Id: tri_fwhm.tcl,v 1.5 2008-05-01 07:18:37 jacquesmichelet Exp $
#

namespace eval ::TriFWHM {
    source [file join $audace(rep_scripts) tri_fwhm tri_fwhm.cap]

    set numero_version V2.9
    #--------------------------------------------------------------------------#
    #  Message                                                                 #
    #--------------------------------------------------------------------------#
    #  Permet l'affichage de messages format�s dans la console                 #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - niveau :                                                              #
    #     console : affichage dans la console                                  #
    #     test : mode debug                                                    #
    #                                                                          #
    # Param�tres de sortie : Aucun                                             #
    #                                                                          #
    # Algorithme :                                                             #
    #  si niveau console, affichage, puis attente que toutes les t�ches soient #
    #   �x�cut�es                                                              #
    #--------------------------------------------------------------------------#
    proc Message {niveau args} {
        switch -exact -- $niveau {
            console {
                ::console::disp [eval [concat {format} $args]]
                update idletasks
            }
        }
    }

    #---Fin de Message---------------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  RecuperationParametres                                                  #
    #--------------------------------------------------------------------------#
    #  Effectue la r�cup�ration des param�tres stock�s dans tri_fwhm.ini       #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - aucun                                                                 #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - parametres : tableau contenant tous les param�tres utiles             #
    #     --extension : extension des noms de fichier                          #
    #     --source : nom g�n�rique des fichiers � trier                        #
    #     --nombre : nombre de fichiers � trier                                #
    #     --indice_source : indice du premier fichier � trier                  #
    #     --destination : nom g�n�rique des fichiers tri�s                     #
    #     --indice destination : indice du premier fichier tri�                #
    #     --mode : automatique ou manuel                                       #
    #                                                                          #
    # Algorithme :                                                             #
    #  RAZ du tableau parametres                                               #
    #  Pour tous les champs stock�s                                            #
    #    -s 'il existent, lecture de leur valeur                               #
    #    - sinon, initialisation � une valeur standard                         #
    #--------------------------------------------------------------------------#
    proc RecuperationParametres {} {
        global audace
        variable parametres

        # Initialisation
        if {[info exists parametres]} {unset parametres}

        # Ouverture du fichier de param�tres
        set fichier [file join $audace(rep_scripts) tri_fwhm tri_fwhm.ini]

        if {[file exists $fichier]} {source $fichier}

        if {![info exists parametres(source)]} {set parametres(source) ""}
        if {![info exists parametres(destination)]} {set parametres(destination) ""}
        if {![info exists parametres(indice_source)]} {set parametres(indice_source) 1}
        if {![info exists parametres(nombre)]} {set parametres(nombre) 20}
        if {![info exists parametres(indice_destination)]} {set parametres(indice_destination) 1}
        if {![info exists parametres(mode)]} {set parametres(mode) "automatique"}
        if {![info exists parametres(extension)]} {set parametres(extension) [buf$audace(bufNo) extension]}
    }
    #--Fin de RecuperationParametres-------------------------------------------#

    proc SauvegardeParametres {} {
        global audace
        variable parametres

        set nom_fichier [file join $audace(rep_scripts) tri_fwhm tri_fwhm.ini]

        if [catch {open $nom_fichier w} fichier] {
#           Message console "%s\n" $fichier
        } else {
            foreach {a b} [array get parametres] {
                puts $fichier "set parametres($a) \"$b\""
            }
            close $fichier
        }
    }
    # Fin de SauvegardeParametres


    #--------------------------------------------------------------------------#
    #  SaisieParametres                                                        #
    #--------------------------------------------------------------------------#
    #  Effectue la saisie de param�tres                                        #
    #  Param�tres d'entr�e :                                                   #
    #  - parametres : tableau contenant tous les param�tres stock�s lors d'une #
    #    session pr�c�dente                                                    #
    #                                                                          #
    #  Param�tres de sortie :                                                  #
    #  - parametres : tableau contenant tous les param�tres utiles             #
    #     --extension : extension des noms de fichier                          #
    #     --source : nom g�n�rique des fichiers � trier                        #
    #     --nombre : nombre de fichiers � trier                                #
    #     --indice_source : indice du premier fichier � trier                  #
    #     --destination : nom g�n�rique des fichiers tri�s                     #
    #     --indice destination : indice du premier fichier tri�                #
    #     --mode : automatique ou manuel                                       #
    #                                                                          #
    # Algorithme :                                                             #
    #  Affichage de la fen�tre, et des champs de saisie avec les valeurs par   #
    #   d�faut.                                                                #
    #  Cr�ation des boutons de validation et d'annulation, et des proc�dures   #
    #   correspondantes (bindings)                                             #
    #  Attente que cette fen�tre soit supprim�e (proc ValideSaisie et          #
    #   AnnuleSaisie)                                                          #
    #--------------------------------------------------------------------------#
    proc SaisieParametres {} {
        global audace
        variable parametres
        variable cap_tri

        #  Affichage de la fen�tre, et des champs de saisie avec les valeurs par   #
        #   d�faut.
        catch {destroy $audace(base).saisie_tri}
        toplevel $audace(base).saisie_tri -borderwidth 2 -relief groove
        wm geometry $audace(base).saisie_tri +638+0
        wm title $audace(base).saisie_tri $cap_tri(titre_saisie)
		wm transient $audace(base).saisie_tri $audace(base)

		frame $audace(base).saisie_tri.trame1

        foreach champ {extension source nombre indice_source destination indice_destination} {
            set texte_saisie($champ) $cap_tri($champ)
            set valeur_defaut($champ) $parametres($champ)
            label $audace(base).saisie_tri.trame1.l$champ -text $texte_saisie($champ)
            entry $audace(base).saisie_tri.trame1.e$champ -textvariable ::TriFWHM::parametres($champ) -relief sunken
            $audace(base).saisie_tri.trame1.e$champ delete 0 end
            $audace(base).saisie_tri.trame1.e$champ insert 0 $valeur_defaut($champ)
            grid $audace(base).saisie_tri.trame1.l$champ $audace(base).saisie_tri.trame1.e$champ -sticky news
        }
        frame $audace(base).saisie_tri.trame2 -borderwidth 2 -relief groove
        label $audace(base).saisie_tri.trame2.l -text $cap_tri(mode_tri) -justify center
        radiobutton $audace(base).saisie_tri.trame2.b1 -variable ::TriFWHM::parametres(mode) -text $cap_tri(automatique) -value automatique
        radiobutton $audace(base).saisie_tri.trame2.b2 -variable ::TriFWHM::parametres(mode) -text $cap_tri(manuel) -value manuel
        pack $audace(base).saisie_tri.trame2.l -in $audace(base).saisie_tri.trame2 -side left -fill x
        pack $audace(base).saisie_tri.trame2.b2 -in $audace(base).saisie_tri.trame2 -side right -fill x
        pack $audace(base).saisie_tri.trame2.b1 -in $audace(base).saisie_tri.trame2 -side right -fill x

        #  Cr�ation des boutons de validation et d'annulation, et des proc�dures   #
        #   correspondantes (bindings)                                             #
        frame $audace(base).saisie_tri.trame3 -borderwidth 2 -relief groove
        button $audace(base).saisie_tri.trame3.b1 -text $cap_tri(valider) -command {::TriFWHM::ValideSaisie}
        button $audace(base).saisie_tri.trame3.b2 -text $cap_tri(annuler) -command {::TriFWHM::AnnuleSaisie}
        pack $audace(base).saisie_tri.trame3.b1 -in $audace(base).saisie_tri.trame3 -side left -padx 10 -pady 10
        pack $audace(base).saisie_tri.trame3.b2 -in $audace(base).saisie_tri.trame3 -side right -padx 10 -pady 10

        pack $audace(base).saisie_tri.trame1 $audace(base).saisie_tri.trame2 $audace(base).saisie_tri.trame3 -in $audace(base).saisie_tri -fill x

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $audace(base).saisie_tri

        #  Attente que cette fen�tre soit supprim�e (proc ValideSaisie et          #
        #   AnnuleSaisie                                                           #
        tkwait window $audace(base).saisie_tri
    }
    #---Fin de SaisieParametres------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  ValideSaisie                                                            #
    #--------------------------------------------------------------------------#
    #  Valide la saisie des param�tres et permet ainsi la suite du programme   #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - .saisie : fen�tre de saisie                                           #
    #                                                                          #
    # Param�tres de sortie : Aucun                                             #
    #                                                                          #
    # Algorithme :                                                             #
    #  Efface la fen�tre de saisie                                             #
    #--------------------------------------------------------------------------#
    proc ValideSaisie {} {
        global audace
        destroy $audace(base).saisie_tri
    }
    #---Fin de ValideSaisie----------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  AnnuleSaisie                                                            #
    #--------------------------------------------------------------------------#
    #  Annule la saisie des param�tres et permet ainsi l'arr�t du programme    #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - .saisie : fen�tre de saisie                                           #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - demande_arr�t : variable d'�tat                                       #
    #                                                                          #
    # Algorithme :                                                             #
    #  Effectue la demande d'arr�t                                             #
    #  Efface la fen�tre de saisie                                             #
    #--------------------------------------------------------------------------#
    proc AnnuleSaisie {} {
        global audace
        variable demande_arret

        set demande_arret 1
        destroy $audace(base).saisie_tri
    }
    #---Fin de AnnuleSaisie----------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Verification                                                            #
    #--------------------------------------------------------------------------#
    #  V�rifications sur les fichiers                                          #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - parametres : param�tres saisis (proc SaisieParametres)                #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - mot d'erreur mis � 1 si une erreur est d�tect�e                       #
    #                                                                          #
    # Algorithme :                                                             #
    #  V�rification que les fichiers � trier existent vraiment.                #
    #  Si probl�me, sortie                                                     #
    #  V�rification que les noms des fichiers � trier et tri�s different       #
    #  Si probl�me, sortie                                                     #
    #--------------------------------------------------------------------------#
    proc Verification {} {
        global audace
        variable parametres
        variable cap_tri

        # Pour all�ger l'�criture
        set nom $parametres(source)
        set nom_reg ${nom}r
        set nombre_image $parametres(nombre)

        #  V�rification que les fichiers � trier existent vraiment.                #
        #  Si probl�me, sortie                                                     #
        Message console "%s %s\[%d...%d\]\n" $cap_tri(verification) $nom $parametres(indice_source) [expr $parametres(indice_source) + $nombre_image - 1]
        for {set image $parametres(indice_source)} {$image < [expr $parametres(indice_source) + $nombre_image]} {incr image} {
            set nom_fichier [file join $audace(rep_images) $nom$image$parametres(extension)]
            if {![file exists $nom_fichier]} {
                    # Recherche si le fichier existe en compress�
            append nom_fichier ".gz"
                        if {![file exists $nom_fichier]} {
                                Message console "%s %s %s\n" $cap_tri(erreur_verif_1) $nom$image $cap_tri(erreur_verif_2)
                                return 1
                        }
            }
        }

        #  V�rification que les noms des fichiers � trier et tri�s different       #
        #  Si probl�me, sortie                                                     #
        Message console "%s\n" $cap_tri(verification_nom)
        if {$parametres(source) == $parametres(destination)} {
            Message console "%s %s\n" $cap_tri(erreur_verification) $parametres(source)
            return 1
        }
        return 0
    }
    #---Fin de Verification----------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Recalage                                                                #
    #--------------------------------------------------------------------------#
    #  Recale les images pour pouvoir faciliter le calcul de d�calage et pour  #
    #   pouvoir tracer le cadre de s�lection (mode manuel)                     #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - parametres : param�tres saisis (proc SaisieParametres)                #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - cadre : rectangle d�limitant la zone dans laquelle seront s�lection-  #
    #   n�es les �toiles                                                       #
    #                                                                          #
    # Algorithme :                                                             #
    #  Recalage de toutes les images � trier (pour mettre � jour le champ      #
    #    REGISTER)                                                             #
    #  Recherche du d�calage entre la premi�re et la derni�re image � trier    #
    #  Recherche de la taille de l'image                                       #
    #  Determination de la zone commune (rectangle) aux 2 images               #
    #  M�morisation du rectangle                                               #
    #  Dessin du rectangle sur l'image                                         #
    #--------------------------------------------------------------------------#
    proc Recalage {} {
        global audace color
        variable cadre
        variable parametres
        variable cap_tri

        # Pour all�ger l'�criture
        set nom $parametres(source)
        set nom_reg ${nom}__
        set nombre_image $parametres(nombre)

        #  Recalage de toutes les images � trier (pour mettre � jour le champ      #
        #    REGISTER)                                                             #
        Message console "%s %d %s %s %s %s\n" $cap_tri(recalage_1) $nombre_image $cap_tri(recalage_2) $nom $cap_tri(recalage_3) $nom_reg
        register $nom $nom_reg $nombre_image

        #  Recherche du d�calage entre la premi�re et la derni�re image � trier    #
        Message console "%s\n" $cap_tri(recherche_decalage)
        buf$audace(bufNo) load [file join $audace(rep_images) $nom_reg$nombre_image]
        visu$audace(visuNo) disp [lrange [buf$audace(bufNo) stat] 0 1 ]
        set dec [Decalage]
        set dec_max_x [lindex $dec 0]
        set dec_max_x [expr int($dec_max_x)]
        set dec_max_y [lindex $dec 1]
        set dec_max_y [expr int($dec_max_y)]

        #  Recherche de la taille de l'image                                       #
        Message console "%s\n" $cap_tri(recherche_taille)
        set taille_image_x [lindex [buf$audace(bufNo) getkwd NAXIS1] 1 ]
        set taille_image_x [expr int($taille_image_x)]
        set taille_image_y [lindex [buf$audace(bufNo) getkwd NAXIS2] 1 ]
        set taille_image_y [expr int($taille_image_y)]

        #  Determination de la zone commune (rectangle) aux 2 images               #
        Message console "%s\n" $cap_tri(determination_cadre)
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

        #  M�morisation du rectangle                                               #
        set cadre(x1) $cadre_x1
        set cadre(y1) $cadre_y1
        set cadre(x2) $cadre_x2
        set cadre(y2) $cadre_y2

        #  Dessin du rectangle sur l'image                                         #
        append nom 1
        loadima $nom
        visu$audace(visuNo) disp [lrange [buf$audace(bufNo) stat] 0 1 ]
        DessineRectangle [list $cadre_x1 $cadre_y1 $cadre_x2 $cadre_y2] $color(green)
    }
    #---Fin de Recalage--------------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  AffichesBoutons                                                         #
    #--------------------------------------------------------------------------#
    #  Affiche les boutons qui vont permettre de s�lectionner les �toiles et   #
    #   poursuivre le calcul (mode manuel)                                     #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - audace (couleurs)                                                     #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - nombre_boite : initialisation � 0 de cette variable                   #
    #                                                                          #
    # Algorithme :                                                             #
    #  Trac� des 3 boutons et d�finition de leur bindings                      #
    #  Attente que cette fen�tre soit supprim�e (proc ValideSelection,         #
    #   et AnnuleSelection)                                                    #
    #--------------------------------------------------------------------------#
    proc AfficheBoutons {} {
        global audace
        variable nombre_boite
        variable fin_selection
        variable cap_tri

        toplevel $audace(base).selectetoile -class Toplevel -borderwidth 2 -relief groove
        wm geometry $audace(base).selectetoile +638+0
        wm resizable $audace(base).selectetoile 0 0
        wm title $audace(base).selectetoile $cap_tri(selection)
		wm transient $audace(base).selectetoile $audace(base)

        set texte_bouton(selection) $cap_tri(selection_etoile)
        set texte_bouton(lancement) $cap_tri(lancement_calcul)
        set texte_bouton(annulation) $cap_tri(annulation_calcul)

        set command_bouton(selection) ::TriFWHM::SelectionneEtoiles
        set command_bouton(lancement) ::TriFWHM::ValideSelection
        set command_bouton(annulation) ::TriFWHM::AnnuleSelection

        foreach champ {selection lancement annulation} {
            button $audace(base).selectetoile.b$champ -text $texte_bouton($champ) -command $command_bouton($champ)
            pack $audace(base).selectetoile.b$champ -anchor center -side top -fill x -padx 4 -pady 4 -in $audace(base).selectetoile  -anchor center -expand 1 -fill both -side top
        }

        set nombre_boite 0
        Message console "%s\n" $cap_tri(selection_etoile)
        set fin_selection 0

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $audace(base).selectetoile

        tkwait window $audace(base).selectetoile
    }
    #---Fin de AfficheBoutons--------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  SelectionneEtoiles                                                      #
    #--------------------------------------------------------------------------#
    #  Binding. V�rifie que l'objet s�lectionn� est une �toile, et le cas      #
    #   �ch�ant, met ses coordonn�es en m�moire (mode manuel)                  #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - [ ::confVisu::getBox $audace(visuNo) ] coordonn�es de la boite trac�e #
    #    par l'utilisateur.                                                    #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - nombre_boite : nombre de boites et donc d'�toiles valides             #
    #  - boite : tableau des coordon�es des boites                             #
    #                                                                          #
    # Algorithme :                                                             #
    #  D�tection de ce que l'utilisateur a bien trac� une boite                #
    #  R�cup�ration des coordonn�es (boite) retourn�e par la souris            #
    #  V�rification de ce que cette boite est bien dans le cadre g�n�ral       #
    #  Si ce n'est pas le cas                                                  #
    #  Alors message d'erreur et sortie                                        #
    #  Mise en m�moire de la boite                                             #
    #  Teste la validit� de l'�toile                                           #
    #  Si c'est une �toile valide                                              #
    #  Alors                                                                   #
    #     -incr�ment du nombre d'�toiles valides                               #
    #     -dessin d'un rectangle jaune autour de l'�toile                      #
    #     -sortie                                                              #
    #  Sinon affichage d'un message d'erreur et sortie                         #
    #--------------------------------------------------------------------------#
    proc SelectionneEtoiles {} {
        global audace
        variable cadre
        variable nombre_boite
        variable boite
        variable cap_tri

        #  D�tection de ce que l'utilisateur a bien trac� une boite                #
        set rect [ ::confVisu::getBox $audace(visuNo) ]
        if { $rect != "" } {
            #  R�cup�ration des coordonn�es (boite) retourn�e par la souris            #
            set x1 [lindex $rect 0]
            set y1 [lindex $rect 1]
            set x2 [lindex $rect 2]
            set y2 [lindex $rect 3]

            #  Recalage de la boite
            set xy [buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]]
            set x1 [expr round([lindex $xy 0] - 10)]
            set y1 [expr round([lindex $xy 1] - 10)]
            set x2 [expr round([lindex $xy 0] + 10)]
            set y2 [expr round([lindex $xy 1] + 10)]
            set rect [list $x1 $y1 $x2 $y2]

            #  V�rification de ce que cette boite est bien dans le cadre g�n�ral       #
            set hors_cadre 0
            if {$x1 < $cadre(x1)} {set hors_cadre 1}
            if {$x2 < $cadre(x1)} {set hors_cadre 1}
            if {$x1 > $cadre(x2)} {set hors_cadre 1}
            if {$x2 > $cadre(x2)} {set hors_cadre 1}
            if {$y1 < $cadre(y1)} {set hors_cadre 1}
            if {$y2 < $cadre(y1)} {set hors_cadre 1}
            if {$y1 > $cadre(y2)} {set hors_cadre 1}
            if {$y2 > $cadre(y2)} {set hors_cadre 1}
            #  Si ce n'est pas le cas                                                  #
            if {$hors_cadre == 1} {
                #  Alors message d'erreur et sortie                                        #
                tk_messageBox -message $cap_tri(etoile_hors_cadre) -icon error -title $cap_tri(probleme)
            } else {
                #  Mise en m�moire de la boite                                             #
                incr nombre_boite
                set i $nombre_boite
                set boite($i) $rect
                #  Teste la validit� de l'�toile                                           #
                set valide [Centroide $x1 $y1 $x2 $y2]
                set code_erreur [lindex $valide 2]
                #  Si c'est une �toile valide                                              #
                if {$code_erreur == 1} {
                    #  Alors                                                                   #
                    #     -incr�ment du nombre d'�toiles valides                               #
                    #     -dessin d'un rectangle jaune autour de l'�toile                      #
                    #     -sortie                                                              #
                    DessineRectangle $rect yellow
                    Message console "  %s  %s: %s %s\n" $cap_tri(etoile) $i [format "%4.2f" [lindex $valide 0]] [format "%4.2f" [lindex $valide 1]]
                } else {
                    #  Sinon affichage d'un message d'erreur et sortie                         #
                    set err(-1) $cap_tri(etoile_erreur_1)
                    set err(-2) $cap_tri(etoile_erreur_2)
                    set err(-3) $cap_tri(etoile_erreur_3)
                    tk_messageBox -message "$cap_tri(etoile_non_valide)\n$err($code_erreur)" -icon error -title $cap_tri(probleme)
                    incr nombre_boite -1
                }
            }
        }
    }
    #---Fin de SelectionneEtoile-----------------------------------------------#

    #--------------------------------------------------------------------------#
    #  ValideSelection                                                         #
    #--------------------------------------------------------------------------#
    #  Binding. Sert � valider la selection des �toiles (mode manuel)          #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - nombre_boite : nombre d'�toiles encadr�es.                            #
    #                                                                          #
    # Param�tres de sortie : aucun                                             #
    #                                                                          #
    # Algorithme :                                                             #
    #  Si aucune �toile n'a �t� encadr�e                                       #
    #  Alors affichage d'un message d'erreur et sortie                         #
    #  Sinon effacement de la fenetre de selection                             #
    #--------------------------------------------------------------------------#
    proc ValideSelection {} {
        global audace
        variable nombre_boite
        variable fin_selection
        variable cap_tri

        if {$nombre_boite == 0} {
            tk_messageBox -message $cap_tri(non_selection) -icon error -title $cap_tri(probleme)
        } else {
            destroy $audace(base).selectetoile
            set fin_selection 1
        }
    }
    #---Fin de ValideSelection-------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  AnnuleSelection                                                         #
    #--------------------------------------------------------------------------#
    #  Binding. Permet d'arr�ter le process de selection et le programme       #
    #   (mode manuel)                                                          #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #   audace(hCanvas) : canevas de l'image sous Audace                       #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  demande_arret : variable d'�tat qui permet de signaler une demande      #
    #   d'arr�t                                                                #
    #                                                                          #
    # Algorithme :                                                             #
    #  Effacement des cadres affich�s                                          #
    #  Valide la demande d'arr�t                                               #
    #  Effacement de la fenetre de selection                                   #
    #--------------------------------------------------------------------------#
    proc AnnuleSelection {} {
        global audace
        variable demande_arret

        #  Effacement des cadres affich�s                                          #
        $audace(hCanvas) delete cadres

        #  Valide la demande d'arr�t                                               #
        set demande_arret 1

        #  Effacement de la fenetre de selection                                   #
        destroy $audace(base).selectetoile
    }
    #---Fin de AnnuleSelection-------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  CalculeFWHMManuel                                                       #
    #--------------------------------------------------------------------------#
    #  Attribue � chaque image un FWHM en fonction de ceux des �toiles         #
    #   s�lectionn�es (mode manuel)                                            #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #   parametres : parametres des images                                     #
    #   nombre_boite : nombre d'�toiles s�lectionn�es                          #
    #   boite : tableau de coordonn�es des cadres entourant les �toiles selec- #
    #    tionn�ees.                                                            #
    #   audace(hCanvas) : canevas de l'image sous Audace                       #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #   fwhm_image : tableau contenant les FWHM calcul�s pour toutes les       #
    #    images � trier                                                        #
    #   liste_fwhm : liste de tous les FWHM calcul�s (sert au tri)             #
    #                                                                          #
    # Algorithme :                                                             #
    #  Effacement des cadres affich�s                                          #
    #  Pour toutes les images � trier                                          #
    #    - Chargement de l'image "registr�e" pour lire le d�calage dans son    #
    #       ent�te FITS                                                        #
    #    - Effacement de l'image "registr�e"                                   #
    #    - Chargement de l'image source pour les calculs de FWHM               #
    #    - Pour chacune des �toiles s�lectionn�es                              #
    #       - cr�ation d'un nouveau cadre par d�calage de sa boite de s�lection#
    #       - calcul du FWHM en x et y de l'�toile dans ce nouveau cadre       #
    #    - Calcul des moyennes en x et y de tous les FWHM des �toiles)         #
    #    - Calcul du FWHM de l'image (maximum des valeurs moyennes en x et y)  #
    #    - Cr�ation d'une liste qui va servir au calcul de l'histogramme       #
    #--------------------------------------------------------------------------#
    proc CalculeFWHMManuel {} {
        global audace color
        variable parametres
        variable nombre_boite
        variable boite
        variable liste_fwhm
        variable fwhm_image
        variable cap_tri

        # Pour am�liorer la lisibilit�...
        set nom $parametres(source)
        set nombre_image $parametres(nombre)

        # Initialisation de variables
        set nom_reg ${nom}__
        set nombre_etoile $nombre_boite
        set liste_fwhm [list]

        #  Effacement des cadres affich�s                                          #
        $audace(hCanvas) delete cadres

        Message console "%s %s\n" $nombre_etoile $cap_tri(etoiles_select)
        Message console "%s\n" $cap_tri(analyse)

        #  Pour toutes les images � trier                                          #
        for {set image 1} {$image <= $nombre_image} {incr image} {
            set fwhm_x 0.0
            set fwhm_y 0.0

            #    - Chargement de l'image "registr�e" pour lire le d�calage dans son    #
            #       ent�te FITS                                                        #
            loadima $nom_reg$image
            visu$audace(visuNo) disp [lrange [buf$audace(bufNo) stat] 0 1 ]

            # Lecture dans l'entete fits du decalage de l'image...
            set dec [Decalage]
            set dec_im_x [lindex $dec 0]
            set dec_im_y [lindex $dec 1]

            #    - Effacement de l'image "registr�e"                                   #
            file delete $nom_reg$image$parametres(extension)

            #    - Chargement de l'image source pour les calculs de FWHM               #
            buf$audace(bufNo) load [file join $audace(rep_images) $nom$image]
            visu$audace(visuNo) disp [lrange [buf$audace(bufNo) stat] 0 1 ]
            update idletasks

            #    - Pour chacune des �toiles s�lectionn�es                              #
            for {set etoile 1} {$etoile <= $nombre_etoile} {incr etoile} {
                set uneetoile $boite($etoile)

                #       - cr�ation d'un nouveau cadre par d�calage de sa boite de s�lection#
                set x1 [expr int([lindex $uneetoile 0] + $dec_im_x)]
                set y1 [expr int([lindex $uneetoile 1] + $dec_im_y)]
                set x2 [expr int([lindex $uneetoile 2] + $dec_im_x)]
                set y2 [expr int([lindex $uneetoile 3] + $dec_im_y)]

                #       - dessin du rectangle
                DessineRectangle [list $x1 $y1 $x2 $y2] $color(red)

                #       - calcul du FWHM en x et y de l'�toile dans ce nouveau cadre       #
                set fwhm_etoile [buf$audace(bufNo) fwhm [list $x1 $y1 $x2 $y2]]
                set fwhm_x [expr $fwhm_x + [lindex $fwhm_etoile 0]]
                set fwhm_y [expr $fwhm_y + [lindex $fwhm_etoile 1]]

            }
            #    - Calcul des moyennes en x et y de tous les FWHM des �toiles)         #
            set fwhm_x [expr $fwhm_x / $nombre_etoile]
            set fwhm_y [expr $fwhm_y / $nombre_etoile]

            #    - Calcul du FWHM de l'image (maximum des valeurs moyennes en x et y)  #
            if {$fwhm_y > $fwhm_x} {
                    set fwhm_image($image) $fwhm_y
            } else {
                    set fwhm_image($image) $fwhm_x
            }
            Message console "%s %d : %4.2f\n" $cap_tri(fwhm_image) $image $fwhm_image($image)

            #    - Constitution d'une liste qui va servir au calcul de l'histogramme   #
            lappend liste_fwhm $fwhm_image($image)

        #    - effacement des cadres affich�s                                      #
        $audace(hCanvas) delete cadres
        update idletasks
        }
    }
    #---Fin de CalculFWHMManuel------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  CalculeFWHMAutomatique                                                  #
    #--------------------------------------------------------------------------#
    #  Attribue � chaque image un FWHM en fonction de ceux des �toiles         #
    #   s�lectionn�es (mode manuel)                                            #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #   parametres : parametres des images                                     #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #   fwhm_image : tableau contenant les FWHM calcul�s pour toutes les       #
    #    images � trier                                                        #
    #   liste_fwhm : liste de tous les FWHM calcul�s (sert au tri)             #
    #                                                                          #
    # Algorithme :                                                             #
    #  Calcul des FWHM de toutes les images (librairie LibTT)                  #
    #  Pour toutes les images temporaires (cr��s par LibTT)                    #
    #    - Chargement de l'image                                               #
    #    - Lecture du FWHM dans son ent�te FITS                                #
    #    - Cr�ation d'une liste qui va servir au calcul de l'histogramme       #
    #    - Effacement de l'image temporaire                                    #
    #--------------------------------------------------------------------------#
    proc CalculeFWHMAutomatique {} {
        global audace
        variable parametres
        variable liste_fwhm
        variable fwhm_image
        variable cap_tri

        # Pour am�liorer la lisibilit�...
        set nom $parametres(source)
        set nombre_image $parametres(nombre)
        set indice_source $parametres(indice_source)
        set nom_temp ${nom}__

        set liste_fwhm [list]

        #  Calcul des FWHM de toutes les images (librairie LibTT)                  #
        Message console "%s\n" $cap_tri(calcul_principal)
        set ext [buf$audace(bufNo) extension]
        ttscript2 "IMA/SERIES $audace(rep_images) $nom $indice_source [expr $indice_source + $nombre_image -1] $ext $audace(rep_images) $nom_temp 1 $ext STAT fwhm"

        #  Pour toutes les images temporaires (cr��s par LibTT)                    #
        Message console "%s\n" $cap_tri(analyse)
        for {set image 1} {$image <= $nombre_image} {incr image} {
        #    - Chargement de l'image                                               #
                buf$audace(bufNo) load [file join $audace(rep_images) $nom_temp$image]
                visu$audace(visuNo) disp [lrange [buf$audace(bufNo) stat] 0 1 ]
            #    - Lecture du FWHM dans son ent�te FITS                                #
                set fwhm_image($image) [lindex [buf$audace(bufNo) getkwd FWHM] 1]
                Message console "%s %d : %4.2f\n" $cap_tri(fwhm_image) $image $fwhm_image($image)
            #    - Cr�ation d'une liste qui va servir au calcul de l'histogramme       #
                lappend liste_fwhm $fwhm_image($image)
            #    - Effacement de l'image temporaire                                    #
#                file delete [file join $audace(rep_images) $nom_temp$image$parametres(extension)]
        }
    }
    #---Fin de CalculFWHMAutomatique-------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Decalage                                                                #
    #--------------------------------------------------------------------------#
    #  R�cup�re dans l'ent�te FITS de l'image affich�e les informations        #
    #   de recadrage g�n�r�es par la commande register                         #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #   une image doit avoir �t� charg�e pr�alablement dans buf$audace(bufNo)  #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #   une liste de 2 �l�ments : le d�calage en x et celui en y               #
    #    images � trier                                                        #
    #                                                                          #
    # Algorithme :                                                             #
    #  A �crire                                                                #
    #--------------------------------------------------------------------------#
    proc Decalage {} {
            global audace

                # --- recupere la liste des mots cl�s de l'image FITS
                set listkey [buf$audace(bufNo) getkwds]
                # --- on evalue chaque (each) mot cl�
                foreach key $listkey {
                # --- on extrait les infos de la ligne FITS
                # --- qui correspond au mot cl�
                set listligne [buf$audace(bufNo) getkwd $key]
                # --- on �value la valeur de la ligne FITS
                set value [lindex $listligne 1]
                # --- si la valeur vaut IMA/SERIES REGISTER ...
                if {$value=="IMA/SERIES REGISTER"} {
                                # --- alors on extrait l'indice du mot cl� TT*
                                set keyname [lindex $listligne 0]
                                set lenkeyname [string length $keyname]
                                set indice [string range $keyname 2 [expr $lenkeyname] ]
                }
                }

                # On a maintenant repere la fonction TT qui pointe sur la derniere registration.
                # Recherche de la ligne FITS contenant le mot cl� indice+1
                incr indice
                set listligne [buf$audace(bufNo) getkwd "TT$indice"]

                # Evaluation de la valeur de la ligne FITS
                set param1 [lindex $listligne 1]
                set dx [lindex [split $param1] 3]

                # Recherche de la ligne FITS contenant le mot cl� indice+2
                incr indice
                set listligne [buf$audace(bufNo) getkwd "TT$indice"]

                # Evaluation la valeur de la ligne FITS
                set param2 [lindex $listligne 1]
                set dy [lindex $param2 2]

                # Fin de la lecture du decalage
                return [list $dx $dy]
    }
    #---Fin de D�calage--------------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  DessineRectangle                                                        #
    #--------------------------------------------------------------------------#
    #  Trace un rectangle sur une image                                        #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #   une image doit avoir �t� charg�e pr�alablement dans buf$audace(bufNo)               #
    #   rect : une liste des coordonn�es des 4 coins de l'image                #
    #   couleur : la couleur du rectangle                                      #
    #   (logiquement, le tag devrait �tre un param�tre)                        #
    #                                                                          #
    # Param�tres de sortie : aucun                                             #
    #                                                                          #
    # Algorithme :                                                             #
    #  Transformation des coordonn�es images en coordonn�es canvas et trac�    #
    #  Rafraichissement de l'image                                             #
    #--------------------------------------------------------------------------#
    proc DessineRectangle {rect couleur} {
        global audace
        # Recup�re les 4 coordonn�es du rectangle
        set x1 [lindex $rect 0]
        set y1 [lindex $rect 1]
        set x2 [lindex $rect 2]
        set y2 [lindex $rect 3]

        #  Transformation des coordonn�es images en coordonn�es canvas et trac�    #
        set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
        $audace(hCanvas) create rectangle [expr $x1-1] [expr $naxis2-$y1] [expr $x2-1] [expr $naxis2-$y2] -outline $couleur -tags cadres
        #  Rafraichissement de l'image                                             #
        visu$audace(visuNo) disp [lrange [buf$audace(bufNo) stat] 0 1 ]
        update idletasks
    }
    #---Fin de DessineRectangle------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Centroide                                                               #
    #--------------------------------------------------------------------------#
    #  Calcul ls coordonn�es du centre d'un objet ponctuel                     #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #   une image doit avoir �t� charg�e pr�alablement dans buf$audace(bufNo)               #
    #   x1, y1, x2 et y2 : les 4 coordonn�s des coins d'une fen�tre encadrant  #
    #    l'objet                                                               #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  Une liste contenant                                                     #
    #   - les coordonn�es en x et y du centre de l'objet                       #
    #   - un mot d'erreur valant :                                             #
    #      1 si le r�sultat est valide                                         #
    #      -1 si le rapport signal / bruit est trop faible                     #
    #      -2 si l'objet est trop �tal� (non isolable dans un carr� de 21 x21) #
    #      -3 si l'objet est trop ponctuel (pixel chaud)                       #
    #                                                                          #
    # Algorithme :                                                             #
    #  A �crire ...                                                            #
    #--------------------------------------------------------------------------#
    proc Centroide {x1 y1 x2 y2} {
            global audace
        # La fonction retourne les coordonn�es du centre, et un code d'erreur
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
                set pixel_intens [buf$audace(bufNo) getpix [list $hor $ver]]
                if { [ lindex $pixel_intens 0 ] == "1" } {
                    set pixel_courant [ lindex $pixel_intens 1 ]
                } elseif { [ lindex $pixel_intens 0 ] == "3" } {
                    set intensR [ lindex $pixel_intens 1 ]
                    set intensV [ lindex $pixel_intens 2 ]
                    set intensB [ lindex $pixel_intens 3 ]
                    set pixel_courant [ expr ( $intensR + $intensV + $intensB ) / 3. ]
                 }
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
                set pixel_intens [buf$audace(bufNo) getpix [list $hor $en_haut]]
                if { [ lindex $pixel_intens 0 ] == "1" } {
                    set pixel_haut [ lindex $pixel_intens 1 ]
                } elseif { [ lindex $pixel_intens 0 ] == "3" } {
                    set intensR [ lindex $pixel_intens 1 ]
                    set intensV [ lindex $pixel_intens 2 ]
                    set intensB [ lindex $pixel_intens 3 ]
                    set pixel_haut [ expr ( $intensR + $intensV + $intensB ) / 3. ]
                 }
                set matrice($hor,$en_haut) 0
                if {$pixel_haut > $seuil_mini} {
                    set matrice($hor,$en_haut) [expr $pixel_haut - $fond]
                    set couche_valide 1
                    incr nb_pixels_valides
                }
                set en_bas [expr $pixel_max_y - $couche]
                set pixel_intens [buf$audace(bufNo) getpix [list $hor $en_bas]]
                if { [ lindex $pixel_intens 0 ] == "1" } {
                    set pixel_bas [ lindex $pixel_intens 1 ]
                } elseif { [ lindex $pixel_intens 0 ] == "3" } {
                    set intensR [ lindex $pixel_intens 1 ]
                    set intensV [ lindex $pixel_intens 2 ]
                    set intensB [ lindex $pixel_intens 3 ]
                    set pixel_bas [ expr ( $intensR + $intensV + $intensB ) / 3. ]
                 }
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
                set pixel_intens [buf$audace(bufNo) getpix [list $a_droite $ver]]
                if { [ lindex $pixel_intens 0 ] == "1" } {
                    set pixel_droit [ lindex $pixel_intens 1 ]
                } elseif { [ lindex $pixel_intens 0 ] == "3" } {
                    set intensR [ lindex $pixel_intens 1 ]
                    set intensV [ lindex $pixel_intens 2 ]
                    set intensB [ lindex $pixel_intens 3 ]
                    set pixel_droit [ expr ( $intensR + $intensV + $intensB ) / 3. ]
                 }
                set matrice($a_droite,$ver) 0
                if {$pixel_droit > $seuil_mini} {
                    set matrice($a_droite,$ver) [expr $pixel_droit - $fond]
                    set couche_valide 1
                    incr nb_pixels_valides
                }
                set a_gauche [expr $pixel_max_x - $couche]
                set pixel_intens [buf$audace(bufNo) getpix [list $a_gauche $ver]]
                if { [ lindex $pixel_intens 0 ] == "1" } {
                    set pixel_gauche [ lindex $pixel_intens 1 ]
                } elseif { [ lindex $pixel_intens 0 ] == "3" } {
                    set intensR [ lindex $pixel_intens 1 ]
                    set intensV [ lindex $pixel_intens 2 ]
                    set intensB [ lindex $pixel_intens 3 ]
                    set pixel_gauche [ expr ( $intensR + $intensV + $intensB ) / 3. ]
                 }
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
                set pixel_intens [buf$audace(bufNo) getpix [list $hor $ver]]
                if { [ lindex $pixel_intens 0 ] == "1" } {
                    set pixel [ lindex $pixel_intens 1 ]
                } elseif { [ lindex $pixel_intens 0 ] == "3" } {
                    set intensR [ lindex $pixel_intens 1 ]
                    set intensV [ lindex $pixel_intens 2 ]
                    set intensB [ lindex $pixel_intens 3 ]
                    set pixel [ expr ( $intensR + $intensV + $intensB ) / 3. ]
                 }
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
    #---Fin de Centroide-------------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Histogramme                                                             #
    #--------------------------------------------------------------------------#
    # Calcule l'histogramme des FWHM                                           #
    #                                                                          #
    # Param�tres d'entr�e :                                                    #
    #  - fwhm image : tableau des fwhm des images                              #
    #  - liste_fwhm : liste des fwhm des images                                #
    #  - parametres : tableau des param�tres du logiciel                       #
    #                                                                          #
    # Param�tres de sortie :                                                   #
    #  - histo_fwhm : tableau contenant toutes les valeurs de fwhm tri�es par  #
    #    classe. Le dernier �l�ment de ce tableau contient le maximum de       #
    #    l'histogramme.                                                        #
    #  - taille_histo : le nombre de classes de l'histogramme                  #
    #  - extrema : une liste contenant le minimum et le maximum des fwhm des   #
    #    images                                                                #
    #                                                                          #
    # Algorithme :                                                             #
    #  - Tri de la liste liste_fwhm, et recherche des extrema                  #
    #  - D�termination du nombre de classes (fix� arbitrairement au nombre     #
    #   d'images � trier.                                                      #
    #  - Calcul des bornes des classes (r�gle de trois)                        #
    #  - Calcul de l'histogramme et recherche de son maximum                   #
    #--------------------------------------------------------------------------#
    proc Histogramme {} {
                variable fwmh_image
                variable liste_fwhm
                variable parametres
                variable histo_fwhm
                variable taille_histo
                variable extrema

                #  - Tri de la liste liste_fwhm, et recherche des extrema                  #
                set tri_fwhm [lsort -real $liste_fwhm]
                set minimum [lindex $tri_fwhm 0]
                set maximum [lindex $tri_fwhm end]
                set extrema [list $minimum $maximum]

                #  - D�termination du nombre de classes (fix� arbitrairement au nombre     #
                #   d'images � trier.                                                      #
#       set nombre_classe $parametres(nombre)
                # Changement : le nombre de classes est fonction du log du nombre d'images
                set nombre_classe [expr round(10 * log10($parametres(nombre)))]

                #  - Calcul des bornes des classes (r�gle de trois)                        #
                for {set i 0} {$i < $nombre_classe} {incr i} {
                set classe($i) [expr $minimum + ([expr $i + 1] * ($maximum - $minimum) / $nombre_classe)]
                set histo_fwhm($i) 0
                }

                #  - Calcul de l'histogramme et recherche de son maximum                   #
                set j 0
                set j_max [llength $tri_fwhm]
                set histo_max 0
                for {set i 0} {$i < $nombre_classe} {incr i} {
                while {([lindex $tri_fwhm $j] <= $classe($i)) && ($j < $j_max)} {
                                incr histo_fwhm($i)
                                if {$histo_max < $histo_fwhm($i)} {
                                set histo_max $histo_fwhm($i)
                                }
                                incr j
                }
                }
                set histo_fwhm($nombre_classe) $histo_max
                set taille_histo $nombre_classe
    }
    #---Fin de Histogramme-----------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Graphique                                                               #
    #--------------------------------------------------------------------------#
    #  Dessine l'histogramme des FWHM sous forme normale et cumul�e            #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - parametres : param�tres des images                                    #
    #  - histo_fwhm : tableau contenant toutes les valeurs de fwhm tri�es par  #
    #    classe. Le dernier �l�ment de ce tableau contient le maximum de       #
    #    l'histogramme.                                                        #
    #  - taille_histo : le nombre de classes de l'histogramme                  #
    #  - extrema : une liste contenant le minimum et le maximum des fwhm des   #
    #    images                                                                #
    #  - audace(color): tableau des couleurs sous Audace                       #
    #                                                                          #
    #  Param�tres de sortie :                                                  #
    #  - graphe : coordonn�es du graphe                                        #
    #  - curseur_x : position du curseur de s�lection du FWHM                  #
    #                                                                          #
    # Algorithme :                                                             #
    #  - Dessin de la fen�tre                                                  #
    #  - D�termination de constantes utiles au graphique                       #
    #  - Initialisations n�cessaires au curseur                                #
    #  - Dessin des histogrammmes                                              #
    #  - Dessin des axes                                                       #
    #  - Ecriture des l�gendes                                                 #
    #  - Trac� du curseur                                                      #
    #  - Attente que la fen�tre soit d�truite (proc�dure FixeFWHM)             #
    #--------------------------------------------------------------------------#
    proc Graphique {} {
        global audace color
        variable histo_fwhm
        variable taille_histo
        variable extrema
        variable curseur_x
        variable graphe
        variable parametres
        variable cap_tri

        # Simplification d'�criture
        set minimum [lindex $extrema 0]
        set maximum [lindex $extrema 1]

        #  - Dessin de la fen�tre                                                  #
        toplevel $audace(base).graphe_fwhm -borderwidth 2 -relief groove -cursor crosshair -class Toplevel
        wm geometry $audace(base).graphe_fwhm +140+0
        wm minsize $audace(base).graphe_fwhm 320 280
        wm resizable $audace(base).graphe_fwhm 0 0
        wm title $audace(base).graphe_fwhm $cap_tri(graphe_fwhm)
		wm transient $audace(base).graphe_fwhm $audace(base)
        canvas $audace(base).graphe_fwhm.fond -width 450 -height 350
        pack $audace(base).graphe_fwhm.fond -in $audace(base).graphe_fwhm -expand 1 -side top -anchor center -fill both

        #  - D�termination de constantes utiles au graphique                       #
        tkwait visibility $audace(base).graphe_fwhm
        set largeur_graphe [winfo reqwidth $audace(base).graphe_fwhm.fond]
        set hauteur_graphe [winfo reqheight $audace(base).graphe_fwhm.fond]
        set largeur [expr round($largeur_graphe * 0.9)]
        set hauteur [expr round($hauteur_graphe * 0.9)]
        set origine_x [expr round($largeur_graphe * 0.05)]
        set origine_y [expr round($hauteur_graphe * 0.95)]

        #  - Initialisations n�cessaires au curseur                                #
        set graphe(x1) $origine_x
        set graphe(x2) [expr $origine_x + $largeur]
        set graphe(y1) $origine_y
        set graphe(y2) [expr $origine_y - $hauteur]

        #  - Dessin des histogrammmes                                              #
        set cumul_histo 0
        for {set i 0} {$i < $taille_histo} {incr i} {
            set origine_x_barre [expr $origine_x + round($i * $largeur / $taille_histo) + 1]
            set hauteur_barre [expr $hauteur * $histo_fwhm($i) / $histo_fwhm($taille_histo)]
            set cumul_histo [expr 1.00* $cumul_histo + $histo_fwhm($i)]
            set hauteur_barre_2 [expr $hauteur * ($cumul_histo / $parametres(nombre))]
            $audace(base).graphe_fwhm.fond create rect $origine_x_barre [expr $origine_y - 1] [expr $origine_x_barre + round($largeur / $taille_histo)] [expr $origine_y - $hauteur_barre -2] -outline yellow -fill yellow
            $audace(base).graphe_fwhm.fond create rect $origine_x_barre [expr $origine_y - 1] [expr $origine_x_barre + round($largeur / $taille_histo)] [expr $origine_y - $hauteur_barre_2 -2] -outline $color(red) -fill $color(red) -stipple gray12
        }

        #  - Dessin des axes                                                       #
        $audace(base).graphe_fwhm.fond create line $origine_x $origine_y [expr $origine_x + $largeur + 1] $origine_y -fill $color(blue) -tag axe
        $audace(base).graphe_fwhm.fond create line $origine_x [expr $origine_y - (0.25 * ($hauteur + 2))] [expr $origine_x + $largeur + 1] [expr $origine_y - (0.25 * ($hauteur + 2))] -fill $color(red) -tag axe
        $audace(base).graphe_fwhm.fond create line $origine_x [expr $origine_y - (0.5 * ($hauteur + 2))] [expr $origine_x + $largeur + 1] [expr $origine_y - (0.5 * ($hauteur + 2))] -fill $color(red) -tag axe
        $audace(base).graphe_fwhm.fond create line $origine_x [expr $origine_y - (0.75 * ($hauteur + 2))] [expr $origine_x + $largeur + 1] [expr $origine_y - (0.75 * ($hauteur + 2))] -fill $color(red) -tag axe
        $audace(base).graphe_fwhm.fond create line $origine_x [expr $origine_y - ($hauteur + 2)] [expr $origine_x + $largeur + 1] [expr $origine_y - ($hauteur + 2)] -fill $color(red) -tag axe
        $audace(base).graphe_fwhm.fond create line $origine_x $origine_y $origine_x [expr $origine_y - $hauteur -2] -fill yellow -tag axe

        #  - Ecriture des l�gendes                                                 #
        $audace(base).graphe_fwhm.fond create text [expr $origine_x + ($largeur / 2)] [expr $hauteur_graphe - 2] -text "FWHM" -anchor s -fill $color(blue)
        $audace(base).graphe_fwhm.fond create text 0 [expr $origine_y - ($hauteur / 2)] -text " $cap_tri(nombre_graphe)\n $cap_tri(images)" -anchor w -fill $color(blue)
        $audace(base).graphe_fwhm.fond create text $origine_x [expr $hauteur_graphe - 2] -text [format "%4.2f" [lindex $extrema 0]] -anchor s -fill $color(blue)
        $audace(base).graphe_fwhm.fond create text [expr $origine_x + $largeur] [expr $hauteur_graphe - 2] -text [format "%4.2f" [lindex $extrema 1]] -anchor s -fill $color(blue)
        $audace(base).graphe_fwhm.fond create text $origine_x $origine_y -text "0 " -anchor e -fill yellow
        $audace(base).graphe_fwhm.fond create text $origine_x [expr $origine_y - $hauteur] -text [format "%d " $histo_fwhm($taille_histo)] -anchor e -fill yellow
        $audace(base).graphe_fwhm.fond create text $largeur_graphe [expr round($origine_y - (0.25 * ($hauteur + 2)))] -text "25% " -fill $color(red) -anchor e
        $audace(base).graphe_fwhm.fond create text $largeur_graphe [expr round($origine_y - (0.50 * ($hauteur + 2)))] -text "50% " -fill $color(red) -anchor e
        $audace(base).graphe_fwhm.fond create text $largeur_graphe [expr round($origine_y - (0.75 * ($hauteur + 2)))] -text "75% " -fill $color(red) -anchor e
        $audace(base).graphe_fwhm.fond create text $largeur_graphe [expr round($origine_y - (1.00 * ($hauteur + 2)))] -text "100%" -fill $color(red) -anchor e

        #  - Trac� du curseur                                                      #
        set curseur_x $largeur
        $audace(base).graphe_fwhm.fond create line $curseur_x $hauteur_graphe $curseur_x 0 -fill $color(green) -tag curseur
        set rapport [expr 1.00 * ($curseur_x - $graphe(x1)) / ($graphe(x2) - $graphe(x1))]
        set valeur_fwhm [expr $minimum + (($maximum - $minimum) * $rapport)]
        set valeur_fwhm [eval {format " %4.2f" $valeur_fwhm}]
        $audace(base).graphe_fwhm.fond create text $curseur_x [expr round($graphe(y2) * 1.1)] -text $valeur_fwhm -anchor w -fill $color(green) -tag valeur_curseur
        bind $audace(base).graphe_fwhm.fond <Motion> {::TriFWHM::TraceCurseur %x}
        bind $audace(base).graphe_fwhm.fond <ButtonRelease-1> {::TriFWHM::FixeFWHM}

        #--- Mise a jour dynamique des couleurs
        ::confColor::applyColor $audace(base).graphe_fwhm

        #  - Attente que la fen�tre soit d�truite (proc�dure FixeFWHM)             #
        tkwait window $audace(base).graphe_fwhm
    }
    #---Fin de Graphique-------------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  TraceCurseur                                                            #
    #--------------------------------------------------------------------------#
    #  Binding . G�re l'animation du curseur de s�lection du FWHM sur les      #
    #   histogrammes                                                           #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - graphe : coordonn�es du graphe                                        #
    #  - curseur_x : position du curseur de s�lection du FWHM                  #
    #  - extrema : une liste contenant le minimum et le maximum des fwhm des   #
    #    images                                                                #
    #  - cx : position du curseur dans le graphe                               #
    #                                                                          #
    #  Param�tres de sortie :                                                  #
    #  - valeur_fwhm : valeur du FWHM corresponadant � la position du curseur  #
    #  - curseur_x : position du curseur de s�lection du FWHM                  #
    #  Nota : curseur_x est � la fois en param�tre d'entr�e et de sortie       #
    #                                                                          #
    # Algorithme :                                                             #
    #  - Blocage de bout de course : si la souris sort du graphe, le curseur   #
    #   est contraint d'y rester.                                              #
    #  - D�placement du curseur                                                #
    #  - Calcul et affichage de la valeur de FWHM correspondante               #
    #--------------------------------------------------------------------------#
    proc TraceCurseur {cx} {
        global audace color
        variable curseur_x
        variable graphe
        variable extrema
        variable valeur_fwhm

        # Simplification d'�criture
        set minimum [lindex $extrema 0]
        set maximum [lindex $extrema 1]

        #  - Blocage de bout de course : si la souris sort du graphe, le curseur   #
        #   est contraint d'y rester.                                              #
        if {$cx < $graphe(x1)} {set cx $graphe(x1)}
        if {$cx > $graphe(x2)} {set cx $graphe(x2)}

        #  - D�placement du curseur                                                #
        set dx [expr $cx - $curseur_x]
        $audace(base).graphe_fwhm.fond move curseur $dx 0
        set curseur_x $cx

        #  - Calcul et affichage de la valeur de FWHM correspondante               #
        set rapport [expr 1.00 * ($cx - $graphe(x1)) / ($graphe(x2) - $graphe(x1))]
        set valeur_fwhm [expr $minimum + (($maximum - $minimum) * $rapport)]
        set valeur_fwhm [eval {format " %4.2f" $valeur_fwhm}]
        $audace(base).graphe_fwhm.fond delete valeur_curseur
        $audace(base).graphe_fwhm.fond create text $cx [expr round($graphe(y2) * 1.1)] -text $valeur_fwhm -anchor w -fill $color(green) -tag valeur_curseur
    }
    #---Fin de TraceCurseur----------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  FixeFWHM                                                                #
    #--------------------------------------------------------------------------#
    #  Binding . Valide le choix de la valeur du FWHM seuil                    #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - valeur_fwhm : valeur du FWHM correspondant � la position du curseur   #
    #                                                                          #
    #  Param�tres de sortie : aucun                                            #
    #                                                                          #
    # Algorithme :                                                             #
    #  - Blocage de toute animation                                            #
    #  - Demande de confirmation du choix du seuil                             #
    #  - Si la r�ponse est positive, effacement du graphe et sortie            #
    #  - Sinon r�tablissemnt de l'animation et sortie                          #
    #--------------------------------------------------------------------------#
    proc FixeFWHM {} {
        global audace
        variable valeur_fwhm
        variable cap_tri

        #  - Blocage de toute animation                                            #
        bind $audace(base).graphe_fwhm.fond <Motion> {}

        #  - Demande de confirmation du choix du seuil                             #
        set texte_message [concat $cap_tri(validation_seuil) [format "%4.2f" $valeur_fwhm] "?"]
        set choix [tk_messageBox -type yesno -default yes -message $texte_message -icon question -title $cap_tri(validation_fwhm) -parent $audace(base)]

        #  - Si la r�ponse est positive, effacement du graphe et sortie            #
        if {$choix == "yes"} {
            destroy $audace(base).graphe_fwhm
            update
        } else {
            #  - Sinon r�tablissemnt de l'animation et sortie                          #
            bind $audace(base).graphe_fwhm.fond <Motion> {::TriFWHM::TraceCurseur %x}
        }
    }
    #---Fin de FixeFWHM--------------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  RecopieImages                                                           #
    #--------------------------------------------------------------------------#
    #  Recopie les images dont le FWHM est inf�rieur ou �gal au FWHM seuil     #
    #                                                                          #
    #  Param�tres d'entr�e :                                                   #
    #  - parametres : param�tres des images                                    #
    #  - fwhm image : tableau des fwhm des images                              #
    #  - valeur_fwhm : valeur du FWHM correspondant � la position du curseur   #
    #                                                                          #
    #  Param�tres de sortie : aucun                                            #
    #                                                                          #
    # Algorithme :                                                             #
    #  - Copie les images dont le FWHM est inf�rieur ou �gal � la valeur seuil #
    #--------------------------------------------------------------------------#
    proc RecopieImages {} {
        global audace
        variable fwhm_image
        variable valeur_fwhm
        variable parametres
        variable cap_tri

        Message console "%s %s %s %4.2f %s %s\n" $cap_tri(recopie_1) $parametres(source) $cap_tri(recopie_2) $valeur_fwhm $cap_tri(recopie_3) $parametres(destination)

        #  - Copie les images dont le FWHM est inf�rieur ou �gal � la valeur seuil #
        set indice_destination $parametres(indice_destination)
        for {set image 1} {$image <= $parametres(nombre)} {incr image} {
            set source [file join $audace(rep_images) $parametres(source)[expr $image + $parametres(indice_source) - 1]$parametres(extension)]
            set destination [file join $audace(rep_images) $parametres(destination)$indice_destination$parametres(extension)]
            if {$fwhm_image($image) <= $valeur_fwhm } {
                loadima $source
                saveima $destination
#--- Debut modif Robert
                ::audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                incr indice_destination
            }
        }
        incr indice_destination -1

        Message console "%d %s %s\[%d...%d\] %s\n" $indice_destination $cap_tri(fin_recopie_1) $parametres(destination) $parametres(indice_destination) [expr $parametres(indice_destination) + $indice_destination -1] $cap_tri(fin_recopie_2)
    }
    #---Fin de RecopieImages---------------------------------------------------#

    #--------------------------------------------------------------------------#
    #  Principal                                                               #
    #--------------------------------------------------------------------------#
    #  Programme principal                                                     #
    #                                                                          #
    #  Param�tres d'entr�e : aucun                                             #
    #                                                                          #
    #  Param�tres de sortie : aucun                                            #
    #                                                                          #
    # Algorithme :                                                             #
    #  Effectue la saisie de param�tres                                        #
    #  Si l'utilisateur lance le calcul                                        #
    #  Alors                                                                   #
    #    V�rifications sur les fichiers                                        #
    #    Si aucune erreur n'est trouv�e                                        #
    #    Alors                                                                 #
    #      Si l'utilisateur a s�lectionn� le mode manuel                       #
    #      Alors                                                               #
    #        Recale les images pour pouvoir faciliter le calcul de d�calage    #
    #         et pour pouvoir tracer le cadre de s�lection (mode manuel)       #
    #        Affiche les boutons qui vont permettre de s�lectionner les �toiles#
    #         et poursuivre le calcul (mode manuel)                            #
    #        Si l'utilisateur valide ses s�lections                            #
    #        Alors                                                             #
    #          Attribue � chaque image un FWHM en fonction de ceux des �toiles #
    #           s�lectionn�es (mode manuel)                                    #
    #        Fin                                                               #
    #      Sinon                                                               #
    #        Attribue � chaque image un FWHM en fonction de ceux des �toiles   #
    #         s�lectionn�es (mode automatique)                                 #
    #      Fin                                                                 #
    #      Si l'utilisateur avait bien valid� ses s�lections                   #
    #      Alors                                                               #
    #        Calcule l'histogramme des FWHM                                    #
    #        Dessine l'histogramme des FWHM sous forme normale et cumul�e      #
    #        Recopie les images dont le FWHM est inf�rieur ou �gal au FWHM     #
    #         seuil                                                            #
    #      Fin                                                                 #
    #  Fin                                                                     #
    #--------------------------------------------------------------------------#
    proc principal {} {
        global audace
        variable cap_tri
        variable numero_version
        variable demande_arret
        variable parametres

        Message console "%s %s\n" $cap_tri(titre) $numero_version
        Message console "%s\n" $cap_tri(copyright)

        #  Effectue la r�cup�ration et la saisie de param�tres                     #
        set demande_arret 0
        RecuperationParametres
        SaisieParametres
        SauvegardeParametres

        if {$demande_arret == 0} {
            #  Si l'utilisateur lance le calcul                                        #

            Message console "%s %s\n" $cap_tri(selection_mode) $parametres(mode)

            #  V�rifications sur les fichiers                                          #
            set erreur [Verification]
            if {$erreur == 0} {
                #    Si aucune erreur n'est trouv�e                                        #
                if {$parametres(mode) == "manuel"} {
                    #      Si l'utilisateur a s�lectionn� le mode manuel                       #
                    #  Recale les images pour pouvoir faciliter le calcul de d�calage et pour  #
                    #   pouvoir tracer le cadre de s�lection (mode manuel)                     #
                    Recalage
                    #  Affiche les boutons qui vont permettre de s�lectionner les �toiles et   #
                    #   poursuivre le calcul (mode manuel)                                     #
                    AfficheBoutons
                    if {$demande_arret == 0} {
                        #        Si l'utilisateur valide ses s�lections                            #
                        #  Attribue � chaque image un FWHM en fonction de ceux des �toiles         #
                        #   s�lectionn�es (mode manuel)                                            #
                        CalculeFWHMManuel
                    } else {
                        Message console "%s\n" $cap_tri(arret_procedure)
                    }
                } else {
                    #        Attribue � chaque image un FWHM en fonction de ceux des �toiles   #
                    #         s�lectionn�es (mode automatique)                                 #
                    CalculeFWHMAutomatique
                }

                if {$demande_arret == 0} {
                    #      Si l'utilisateur avait bien valid� ses s�lections                   #
                    # Calcule l'histogramme des FWHM                                           #
                    Histogramme
                    #  Dessine l'histogramme des FWHM sous forme normale et cumul�e            #
                    Graphique
                    #  Recopie les images dont le FWHM est inf�rieur ou �gal au FWHM seuil     #
                    RecopieImages
                }
            } else {
                Message console "%s\n" $cap_tri(arret_procedure)
            }
        } else {
            Message console "%s\n" $cap_tri(arret_procedure)
        }
        Message console "%s\n" $cap_tri(fin)
        return
    }
}

::TriFWHM::principal

