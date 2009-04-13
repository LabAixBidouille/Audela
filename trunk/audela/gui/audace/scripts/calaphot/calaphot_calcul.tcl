##
# @file calaphot_calcul.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Routines de calcul de photometrie de Calaphot
#
# $Id: calaphot_calcul.tcl,v 1.3 2009-04-13 08:47:37 jacquesmichelet Exp $

namespace eval ::CalaPhot {

    ##
    # @brief Calcul d'une ellipse moyenne pour déterminer la fenêtre d'ouverture
    # @details
    # Toutes les étoiles de référence ayant été modélisée, on calcule alors une fenêtre d'ouverture moyenne.@n
    # Formules generales : voir @ref doc_tech_mesure_flux_ouv_ellipse "Calcul de l'ellipse moyenne"
    # @param[in] image : numero de l'image a traiter
    # @pre Les variables suivantes doivent contenir
    # - data_script(nombre_reference) : nombre d'étoiles de référence
    # - data_image($i,ref,fwhm1_$k) : fwhm sur l'axe principal de l'étoile de référence k dans l'image i.
    # - data_image($i,ref,ro_$k) : facteur d'allongement de l'étoile de référence k dans l'image i.
    # - data_image($i,ref,alpha_$k) : angle entre les axes principaux de l'étoile de référence k dans l'image i et les bords de cette image.
    # @post Les variables suivantes contiendront
    # - data_image($i,r1x) grand axe de l'ellipse moyenne pour l'image i
    # - data_image($i,r1y) petit axe de l'ellipse moyenne pour l'image i
    # - data_image($i,r2) rayon interne de la couronne pour l'image i
    # - data_image($i,r3) rayon externe de la couronne pour l'image i
    # - data_image($i,ro) facteur d'allongement de l'ellipse moyenne pour l'image i
    # - data_image($i,alpha) angle des axes principaux de léllipse moyenne avec les bords de l'image i
    proc CalculEllipses {image} {
        global audace
        variable pos_theo
        variable parametres
        variable data_script
        variable data_image

        Message debug "%s\n" [info level [info level]]

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

        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            if {$data_image($image,ref,centroide_x_$etoile) >= 0} {
                set fwhm_x [expr $fwhm_x + $data_image($image,ref,fwhm1_$etoile)]
                set fwhm_y [expr $fwhm_y + $data_image($image,ref,fwhm2_$etoile)]
                set ro [expr $ro + $data_image($image,ref,ro_$etoile)]
                set alpha [expr $alpha + $data_image($image,ref,alpha_$etoile)]
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
        } else {
            set data_script($i,invalidation) [list ellipses]
        }

        set data_image($image,r1x) $r1x
        set data_image($image,r1y) $r1y
        set data_image($image,r2) $r2
        set data_image($image,r3) $r3
        set data_image($image,ro) $ro
        set data_image($image,alpha) $alpha

        Message debug "image %d: r1x=%10.4f r1y=%10.4f r2=%10.4f r3=%10.4f ro=%10.4f al=%10.4f\n" $image $r1x $r1y $r2 $r3 $ro $alpha
        return [list $bon $r1x $r1y $r2 $r3 $ro $alpha]
    }

    ##
    # @brief Calcul d'incertitude sur toutes les étoiles de référence à étudier dans une image
    # @details
    # L' incertitude sur la magnitudes de la super-etoile est calculee a partir des incertitudes sur chacune des etoiles de reference. Il s'agit de @c data_image(image,incertitude_ref_total).
    # Mais pour chacune des autres super-etoiles (qui servent donc au calcul des magnitudes de ces etoiles de reference, a titre de verification), on effectue le meme calcul d incertitudes, stocke dans @c data_image(image,incertitude_ref_etoile). Voir doc_tech_incert_totale_super-etoile "la formule utilisée".
    # Ensuite est calculee l'incertitude generale sur l'etoile, en additionnant son incertitude propre (calculee par CalculErreur) et celle de son etoile de reference. @n
    # Formules generales : voir @ref doc_tech_incert_totale "incertitude totale"
    # @param[in] image : numero de l'image a traiter
    # @post Les variables suivantes contiendront
    # - @c data_image(image,incertitude_ref_i) : pour chaque etoile de reference i, la valeur de l'incertitude
    #
    proc CalculErreurGlobal {image} {

        variable data_script
        variable data_image
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        set inc1 0.0
        set inc2 0.0
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            set t [expr pow(10.0, -0.4 * $data_image($image,ref,mag_$i))]
            set inc1 [expr $inc1 + $t * $data_image($image,ref,erreur_mag_$i)]
            set inc2 [expr $inc2 + $t]
            if {[info exists trace_log]} {
                Message debug "image %d ref %d: mag=%10.4f inc=%10.4f t=%10.4e inc1=%10.4e inc2=%10.4e\n" $image $i $data_image($image,ref,mag_$i) $data_image($image,ref,erreur_mag_$i) $t $inc1 $inc2
            }
        }
        set data_image($image,incertitude_ref_total) [expr $inc1 / $inc2]

        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            set data_image($image,var,incertitude_$i) [expr $data_image($image,incertitude_ref_total) + $data_image($image,var,erreur_mag_$i)]
        }

        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            set inc1 0.0
            set inc2 0.0
            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                if {($i != $j)} {
                    set t [expr pow(10.0, -0.4 * $data_image($image,ref,mag_$j))]
                    set inc1 [expr $inc1 + $t * $data_image($image,ref,erreur_mag_$j)]
                    set inc2 [expr $inc2 + $t]
                    if {[info exists trace_log]} {
                        Message debug "image %d ref %d ref %d: t=%10.4e inc1=%10.4e inc2=%10.4e\n" $image $i $j $t $inc1 $inc2
                    }
                } else {
                    if {$data_script(nombre_reference) == 1} {
                        set inc1 $data_image($image,ref,erreur_mag_0)
                        set inc2 1
                        if {[info exists trace_log]} {
                            Message debug "image %d ref %d (i=j): t=%10.4e inc1=%10.4e inc2=%10.4e\n" $image $i $t $inc1 $inc2
                        }
                    }
                }
            }
            set data_image($image,ref,incertitude_ref_$i) [expr $inc1 / $inc2]
            set data_image($image,ref,incertitude_$i) [expr $data_image($image,ref,incertitude_ref_$i) + $data_image($image,ref,erreur_mag_$i)]
        }

    }

    #*************************************************************************#
    #*************  CalculErreurModelisation  ********************************#
    #*************************************************************************#
    proc CalculErreurModelisation {image classe etoile} {
        variable data_image

        set data_image($image,$classe,sb_$etoile) [expr $data_image($image,$classe,amplitude_$etoile) / $data_image($image,$classe,sigma_amplitude_$etoile)]
        set data_image($image,$classe,erreur_mag_$etoile) [expr 1.08574 * $data_image($image,$classe,sigma_flux_$etoile) / $data_image($image,$classe,flux_$etoile)]
        set data_image($image,$classe,bruit_flux_$etoile) $data_image($image,$classe,sigma_flux_$etoile)
    }

    ##
    # @brief Calcul d'incertitude pour un astre donne pour le mode ouverture
    # @details voir les @ref doc_tech_incert_mag_ouv
    # Valeurs de tests tirees du bouquin de Howell
    #    - set S 24013
    #    - set g 5
    #    - set n 1
    #    - set p 200
    #    - set b 620
    #    - On doit obtenir S/B = 342, erreur_mag=0.003
    #    .
    # @param[in] image : numero de l'image dans la sequence
    # @param[in] classe : ref pour les etoiles, var pour l'asteroide
    # @param[in] etoile : no de l'etoile
    # @return liste avec le rapport s/b, l'erreur sur la magnitude et l'erreur sur le flux
    proc CalculErreurOuverture {image classe etoile} {
        variable data_image
        variable parametres

        Message debug "%s\n" [info level [info level]]

        set S [expr double($data_image($image,$classe,flux_$etoile))]
        set n [expr double($data_image($image,$classe,nb_pixels_$etoile))]
        set p [expr double($data_image($image,$classe,nb_pixels_fond_$etoile))]
        set b [expr double($data_image($image,$classe,fond_$etoile))]
        set sigma [expr double($data_image($image,$classe,sigma_fond_$etoile))]

        set g [expr double($parametres(gain_camera))]
        set r [expr double($parametres(bruit_lecture))]


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
    #*************  CalculErreurSextractor  **********************************#
    #*************************************************************************#
    proc CalculErreurSextractor {image classe etoile} {
        variable data_image

        Message debug "%s\n" [info level [info level]]

        set data_image($image,$classe,sb_$etoile) [expr $data_image($image,$classe,amplitude_$etoile) / $data_image($image,$classe,sigma_amplitude_$etoile)]
        set data_image($image,$classe,erreur_mag_$etoile) [expr 1.08574 * $data_image($image,$classe,sigma_flux_$etoile) / $data_image($image,$classe,flux_$etoile)]
        set data_image($image,$classe,bruit_flux_$etoile) $data_image($image,$classe,sigma_flux_$etoile)
    }

    ##
    # @brief Calcul de la magnitude de la super-etoile a partir des magnitudes des etoiles de reference
    # @details La super-etoile est calculee a partir des magnitudes de toutes les etoiles de reference. Il s'agit de data_script(mag_ref_totale).
    # Mais pour chacune des etoiles de ref. est aussi calculee une super-etoile faite a partir des magnitudes des autres etoiles de ref., valeur stockee dans data_script(mag_ref_$etoile)@n
    # Formule générale : cf @ref doc_tech_calcul_mag_super_etoile "magnitude de la super-étoile"
    # @pre Les variables suivantes devront contenir :
    # - @c pos_theo(ref,i) : liste dont le 3eme element est la magnitude theorique de l'etoile de ref i
    # .
    # @post Les variables suivantes contiendront
    # - @c data_script(mag_ref_totale) : magnitude de la super etoile
    # - @c data_script(mag_ref_i) : magnitude d'une super etoile faite avec toutes les etoiles de ref. sauf i
    # .
    # @return
    proc CalculMagSuperEtoile {} {
        variable nombre_etoile
        variable pos_theo
        variable data_script
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        set nombre_reference $data_script(nombre_reference)

        # [lindex $pos_theo(ref,$i) 2] contient la magnitude saisie par l'utilisateur
        set mag_ref 0.0
        for {set i 0} {$i < $nombre_reference} {incr i} {
            set f [expr pow(10.0, -0.4 * [lindex $pos_theo(ref,$i) 2])]
            set mag_ref [expr $mag_ref + $f]
        }
        set data_script(mag_ref_totale) [expr -2.5 * log10($mag_ref)]

        for {set i 0} {$i < $nombre_reference} {incr i} {
            set mag_ref 0.0
            for {set j 0} {$j < $nombre_reference} {incr j} {
                if {($i != $j)} {
                    set f [expr pow(10.0, -0.4 * [lindex $pos_theo(ref,$j) 2])]
                    set mag_ref [expr $mag_ref + $f]
                } else {
                    if {($nombre_reference == 1)} {
                        set mag_ref [expr pow(10.0, -0.4 * [lindex $pos_theo(ref,0) 2])]
                    }
                }
            }
            set data_script(mag_ref_$i) [expr -2.5 * log10($mag_ref)]
        }

        for {set i 0} {$i < $nombre_reference} {incr i} {
            Message debug "ref %d: mag= %10.7f\n" $i [lindex $pos_theo(ref,$i) 2]
        }
        Message debug "mag_ref_totale= %10.7f\n" $data_script(mag_ref_totale)
        for {set i 0} {$i < $nombre_reference} {incr i} {
            Message debug "ref %d: mag_ref= %10.7f\n" $i $data_script(mag_ref_${i})
        }
    }

    ##
    # @brief Calcul de toutes les positions reelles des astres, en tenant compte du decalage entre images, pour les astres a mesurer
    # @details Pour tous les astres concernes (etoiles, asteroides, etc), calcul de la zone de recherche du centroide, et calcul rapide du centroide
    # @param image : numero de l'image dans la sequence
    # @pre Les variables suivantes devront contenir :
    # - @c data_script(nombre_reference) : nombre d'etoile de reference
    # - @c data_script(nombre_variable) : nombre d'asteroides
    # - @c data_script(nombre_indes) : nombre d'objet a ecarter
    # - @c pos_theo(c,j) : position theorique de l'objet de classe c (var,ref ou indes) a affiner
    # - @c parametres(tailleboite) : taille de la zone de calcul de centroide.
    # .
    # @post Les variables suivantes contiendront
    # - @c pos_reel(i,c,j) : liste des coord. (x,y) de l'objet j, de typec (var, ref ou indes) dans l'image i
    # .
    # @return 0 (OK) ou -1 si la recherche de centroide ne marche pas
    proc CalculPositionsReelles {image} {
        global audace
        variable pos_theo
        variable pos_reel
        variable parametres
        variable data_image
        variable data_script
        variable calaphot

        Message debug "%s\n" [info level [info level]]

        for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
            set x1 [expr round([lindex $pos_theo(ref,$j) 0] + $data_image($image,decalage_x) - $parametres(tailleboite))]
            set y1 [expr round([lindex $pos_theo(ref,$j) 1] + $data_image($image,decalage_y) - $parametres(tailleboite))]
            set x2 [expr round([lindex $pos_theo(ref,$j) 0] + $data_image($image,decalage_x) + $parametres(tailleboite))]
            set y2 [expr round([lindex $pos_theo(ref,$j) 1] + $data_image($image,decalage_y) + $parametres(tailleboite))]
            if {[info exists trace_log]} {
                Message debug "image %d ref %d: x1=%d y1=%d x2=%d y2=%d\n" $image $j $x1 $y1 $x2 $y2
            }

            # Affinage du centroide de l'etoile
            if {[catch {buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]} coordonnees]} {
                set data_script($i,invalidation) [list centro ref $j]
                return -1
            }
            set pos_reel($image,ref,$j) $coordonnees
            Message debug "image %d ref %d: pos_theo(x)=%10.4f pos_theo(y)=%10.4f\n" $image $j [lindex $pos_theo(ref,$j) 0] [lindex $pos_theo(ref,$j) 1]
            Message debug "image %d ref %d: dec(x)=%10.4f dec(y)=%10.4f\n" $image $j $data_image($image,decalage_x) $data_image($image,decalage_y)
            Message debug "image %d ref %d: pos_reel(x)=%10.4f pos_reel(y)=%10.4f\n" $image $j [lindex $pos_reel($image,ref,$j) 0] [lindex $pos_reel($image,ref,$j) 1]
        }

        for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
            set x1 [expr round([lindex $pos_theo(var,$j) 0] + $data_image($image,decalage_x) - $parametres(tailleboite))]
            set y1 [expr round([lindex $pos_theo(var,$j) 1] + $data_image($image,decalage_y) - $parametres(tailleboite))]
            set x2 [expr round([lindex $pos_theo(var,$j) 0] + $data_image($image,decalage_x) + $parametres(tailleboite))]
            set y2 [expr round([lindex $pos_theo(var,$j) 1] + $data_image($image,decalage_y) + $parametres(tailleboite))]
            Message debug "image %d ref %d: x1=%d y1=%d x2=%d y2=%d\n" $image $j $x1 $y1 $x2 $y2

            # Affinage du centroide de l'etoile
            if {[catch {buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]} coordonnees]} {
                set data_script($i,invalidation) [list centro var $j]
                return -1
            }
            set pos_reel($image,var,$j) $coordonnees
            Message debug "image %d var %d: pos_theo(x)=%10.4f pos_theo(y)=%10.4f\n" $image $j [lindex $pos_theo(var,$j) 0] [lindex $pos_theo(var,$j) 1]
            Message debug "image %d var %d: dec(x)=%10.4f dec(y)=%10.4f\n" $image $j $data_image($image,decalage_x) $data_image($image,decalage_y)
            Message debug "image %d var %d: pos_reel(x)=%10.4f pos_reel(y)=%10.4f\n" $image $j [lindex $pos_reel($image,var,$j) 0] [lindex $pos_reel($image,var,$j) 1]
        }

        for {set j 0} {$j < $data_script(nombre_indes)} {incr j} {
            set x1 [expr round([lindex $pos_theo(indes,$j) 0] + $data_image($image,decalage_x) - $parametres(tailleboite))]
            set y1 [expr round([lindex $pos_theo(indes,$j) 1] + $data_image($image,decalage_y) - $parametres(tailleboite))]
            set x2 [expr round([lindex $pos_theo(indes,$j) 0] + $data_image($image,decalage_x) + $parametres(tailleboite))]
            set y2 [expr round([lindex $pos_theo(indes,$j) 1] + $data_image($image,decalage_y) + $parametres(tailleboite))]
            Message debug "image %d ind %d: x1=%d y1=%d x2=%d y2=%d\n" $image $j $x1 $y1 $x2 $y2

            # Affinage du centroide de l'etoile
            set coordonnees [buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]]
            set pos_reel($image,indes,$j) $coordonnees
            Message debug "image %d indes %d: pos_theo(x)=%10.4f pos_theo(y)=%10.4f\n" $image $j [lindex $pos_theo(indes,$j) 0] [lindex $pos_theo(indes,$j) 1]
            Message debug "image %d indes %d: dec(x)=%10.4f dec(y)=%10.4f\n" $image $j $data_image($image,decalage_x) $data_image($image,decalage_y)
            Message debug "image %d indes %d: pos_reel(x)=%10.4f pos_reel(y)=%10.4f\n" $image $j [lindex $pos_reel($image,indes,$j) 0] [lindex $pos_reel($image,indes,$j) 1]
        }

        # Creation du fichier ASSOC pour la recherche rapide avec Sextractor
        if {$parametres(mode) == "sextractor"} {
            set assoc [OuvertureFichier $calaphot(sextractor,assoc) w]
            for {set j 0} {$j < $data_script(nombre_reference)} {incr j} {
                puts $assoc $pos_reel($image,ref,$j)
            }
            for {set j 0} {$j < $data_script(nombre_variable)} {incr j} {
                puts $assoc $pos_reel($image,var,$j)
            }
            FermetureFichier $assoc
        }

        return 0
    }

    ##
    # @brief Interpolation de la position a partir de la vitesse de deplacement de l'asteroide
    # @details Pour tous les objets variables , interpolation de la position a partir de la vitesse de deplacement de l'asteroide <b> sans tenir compte du décalage des images </b>.
    # Si les dates ne sont pas connues, on utilise les indices des images (en supposant qu'elles soient prises a intervalle constant...)
    # @param image : numero de l'image dans la sequence
    # @pre Les variables suivantes devront contenir :
    # - @c data_script(nombre_variable) : nbre d'asteroides
    # - @c delta_jd : nombre de jour julien separant la premiere de la derniere image
    # - @c jd_premier : jour julien de la 1ere image
    # - @c premier_liste : indice de la 1ere image
    # - @c data_image(i,date) : jour julien de l'image i
    # - @c coord_aster(i,1) : liste contenant les coordonnees de l'aster dans la premiere image de la serie
    # - @c vitesse_variable(i,c) : vitesse de deplacement de l'aster suivant l'axe c (x ou y)
    # .
    # @post Les variables suivantes contiendront
    # - @c pos_theo(var,i) : pour tous les asteroides i, la liste des coordonnées (x,y) de leur position dans l'image
    # .
    # @return
    proc CalculPositionsTheoriques {image} {
        variable data_script
        variable data_image
        variable pos_theo
        variable coord_aster
        variable vitesse_variable

        Message debug "%s\n" [info level [info level]]

        # Calcule la position des asteroides par interpolation sur les dates (sans tenir compte du decalage des images)
        for {set v 0} {$v < $data_script(nombre_variable)} {incr v} {
            if {$data_script(delta_jd) == 0} {
                set x_0 [expr [lindex $coord_aster($v,1) 0] + double($image - $data_script(premier_liste)) * $vitesse_variable($v,x)]
                set y_0 [expr [lindex $coord_aster($v,1) 1] + double($image - $data_script(premier_liste)) * $vitesse_variable($v,y)]
            } else {
                set x_0 [expr [lindex $coord_aster($v,1) 0] + ($data_image($image,date) - $data_script(jd_premier)) * $vitesse_variable($v,x)]
                set y_0 [expr [lindex $coord_aster($v,1) 1] + ($data_image($image,date) - $data_script(jd_premier)) * $vitesse_variable($v,y)]
            }
            set pos_theo(var,$v) [list $x_0 $y_0]
        }
    }

    ##
    # @brief Determination du centre d'un astre encadre dans le buffer AudACE
    # @details
    # Selon Alain Klotz, "buf$audace(bufNo) centro" fait les choses suivantes
    # -# recherche la position du pixel maximal dans la fenetre
    # -# effectue l\'histogramme des valeurs de pixels dans la fenetre
    # -# trie les valeurs de l\'histogramme et prend la valeur du fond
    #     comme la valeur a 20% (c'est a dire un peu moins que la mediane
    #     a 50%).
    # -# Calcule un seuil avec la formule suivante : seuil=fond+0.7*(maxi-fond)
    # -# Pour chaque pixel de la fenetre, on calcule la valeur = pixel - seuil
    #     et si cette valeur est positive, le pixel intervient dans le
    #     calcul du barycentre photometrique.
    # -# Le resultat consiste en trois valeurs :
    #   - Le barycentre X,
    #   - Le barycentre Y,
    #   - La difference (en pixels) entre la position du pixel de valeur maximale et la position du barycentre.
    #   .
    # .
    # @return la liste des 3 valeurs calculees (voir ci-dessus)
    proc Centroide {} {
        global audace

        Message debug "%s\n" [info level [info level]]

        set rect [ ::confVisu::getBox $audace(visuNo) ]
        if { $rect != "" } {
            # Recuperation des coordonnees de la boite de selection
            set x1 [lindex $rect 0]
            set y1 [lindex $rect 1]
            set x2 [lindex $rect 2]
            set y2 [lindex $rect 3]
            # Calcul du centre de l'etoile
            ::confVisu::deleteBox $audace(visuNo)
            return [buf$audace(bufNo) centro [list $x1 $y1 $x2 $y2]]
        } else {
            return [list]
        }
    }



    proc uniq {{val 0}} {

        Message debug "%s\n" [info level [info level]]

        incr val;
        proc ::CalaPhot::uniq "{val $val}" [info body ::CalaPhot::uniq]
        return $val;
    }


    #*************************************************************************#
    #*************  ExtinctionMasseAir  **************************************#
    #*************************************************************************#
    proc ExtinctionMasseAir {} {
        variable data_script
        variable data_image
        variable liste_image

        Message debug "%s\n" [info level [info level]]

        # Recherche de l'image dont la masse d'air est la plus faible
        set masse_air_min 20.0
        foreach image $liste_image {
            if {$data_image($image,valide) == "Y"} {
                if {$data_image($image,ref,masse_air_0) < $masse_air_min} {
                    set masse_air_min $data_image($image,ref,masse_air_0)
                    set image_min $image
                }
            }
        }

        # Recherche de l'image dont la masse d'air est la plus forte
        set masse_air_max 0.0
        foreach image $liste_image {
            if {$data_image($image,valide) == "Y"} {
                if {$data_image($image,ref,masse_air_0) > $masse_air_max} {
                    set masse_air_max $data_image($image,ref,masse_air_0)
                    set image_max $image
                }
            }
        }

        Message debug "Plus petite masse d'air %f dans l'image %d\n" $masse_air_min $image_min
        Message debug "Plus grande masse d'air %f dans l'image %d\n" $masse_air_max $image_max

        set nr 0
        set ksomme 0.0
        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            set delta_mair [expr $data_image($image_max,ref,masse_air_$etoile) - $data_image($image_min,ref,masse_air_$etoile)]
            set delta_mag [expr ( -2.5 * log10($data_image($image_max,ref,flux_$etoile))) - ( -2.5 * log10($data_image($image_min,ref,flux_$etoile)))]
            if {[expr abs($delta_mair)] > 0.01} {
                if {[expr $delta_mag * $delta_mair] > 0.0} {
                    set k($etoile) [expr $delta_mag / $delta_mair]
                    set ksomme [expr $ksomme + $k($etoile)]
                    incr nr
                    if {[info exists trace_log]} {
                        Message debug "Coeff ext etoile ref %d : %f (dma=%f dmg=%f)\n" $etoile $k($etoile) $delta_mair $delta_mag
                    }
                }
            }
        }

        if {$nr > 0} {
            set data_script(coeff_masse_air) [expr $ksomme / $nr]
        } else {
            set data_script(coeff_masse_air) 0.0
        }

        Message debug "Coeff ext general : %f\n" $data_script(coeff_masse_air)
    }

    ##
    # @brief Filtrage à partir de la constante des magnitudes
    # @details Pour l'algorithme, voir @ref doc_tech_filtrage_cm
    # @pre Les variables suivantes devront contenir :
    # - @c data_image($n,constante_mag) : la constante des magnitudes pour l'image n
    # - @c data_image($n,valide) : le drapeau de validité de l'image n
    # .
    # @post Les variables suivantes contiendront
    # - @c data_image($n,valide) : le drapeau de validité de l'image n (mis à jour)
    proc FiltrageConstanteMag {} {
        variable parametres
        variable data_image
        variable calaphot
        variable liste_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

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
                    set data_script($image,invalidation) [list filtrage_cm $ssg]
                    set data_image($image,valide) "N"
                    Message info "%s %05d\n" $calaphot(texte,image_rejetee) $image
                } else {
                    if {$data_image($image,valide) == "Y"} {
                        if {[expr abs($data_image($image,constante_mag) - $msg)] > [expr 3.0 * sqrt($ssg)]} {
                            set data_image($image,valide) "N"
                            Message info "%s %05d\n" $calaphot(texte,image_rejetee) $image
                        }
                    }
                }
            } else {
                set data_image($image,valide) "N"
                Message info "%s %05d\n" $calaphot(texte,image_rejetee) $image
            }
        }
        # Fin de la boucle sur les images
    }

	##
	# @brief Elimination de certaines images.
	# @details Pour plus de détail, voir le paragraphe @ref doc_tech_filtrage_sb
	# @param i : indice de l'image dans la séquence.
    # @pre Les variables suivantes doivent contenir :
	# - data_script(nombre_reference) : nbre d'étoile de référence.
	# - data_image(i,ref,sb_j) : rapport signal/bruit de l'étoile de référence j dans l'image i.
    # - parametres(signal_bruit) : rapport signal/bruit limite entré par l'utilisateur.
	# .
    # @post Les variables suivantes contiendront :
	# - data_image(i,valide) : drapeau de validite de l'image i.
	# .
    proc FiltrageSB {i} {
        variable parametres
        variable data_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            if {$data_image($i,ref,sb_$etoile) < $parametres(signal_bruit)} {
                set data_script($i,invalidation) [list filtrage_sb ref $etoile $$data_image($i,ref,sb_$etoile)]
                set data_image($i,valide) "N"
                break;
            }
        }
    }

    #*************************************************************************#
    #*************  jm_fitgauss2db  ******************************************#
    #*************************************************************************#
    # Note de Alain Klotz le 30 septembre 2007 :
    # Fonction pour inhiber les problemes de jm_fitgauss2d
    # (il faudra un jour analyser finement le code de jm_fitgauss2d
    # pour trouver pourquoi il ne converge pas sur des etoiles tres
    # etalees comme celles du T80 de l'OHP).
    # Note de Jacques Michelet (11 septembre 2008)
    # la fonction jm_fitgauss2d a ete profondement remaniee. Son taux d'echec
    # est devenu tres faible.
    proc jm_fitgauss2db { bufno box {moinssub ""} } {
      if {$moinssub == "-sub"} {
         set temp [jm_fitgauss2d $bufno $box -sub]
      } else {
         set temp [jm_fitgauss2d $bufno $box]
      }
      # test si le nombre d'iteration est non nul, et si l'erreur de modelisation
      # est acceptable (sur les images du T80, le seuil de 5 fait rejeter 3% des
      # objets vus par sextractor, et ce sont le plus souvent des objets non
      # stellaires)
      if {([lindex $temp 1] > 0) && ([lindex $temp 0] < 5.0)} {
         # La modelisation est correcte
         return $temp
      }
      # Echec de jm_fitgauss2d. On effectue une modelisation plus grossiere
        Message debug "jm_fitgauss2d a echoue\n"
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

	##
    # @brief Détermination du flux par ouverture centrée sur l'astre.
    # @details L'ensemble de l'algorithme est décrit dans la documentation technique, <i> à l'exception des calculs de correction de la masse d'air qui <b>ne sont pas activés</b> dans cette version du logiciel </i>.
    # - @ref doc_tech_mesure_flux_ouv_disque_interne "mesure du flux total de l'astre".
    # - @ref doc_tech_mesure_flux_ouv_couronne_externe "mesure du fond de ciel".
	# - @ref doc_tech_mesure_flux_ouv_flux "flux spécifique à l'astre".
	# .
	# @param i : indice de l'image .
    # @param classe : type de l'astre ( @b ref pour une étoile de référence, @b var pour les astéroides).
	# @param j : indice de l'astre dans sa classe.
    # @pre Les variables suivantes doivent contenir :
	# - @c data_image($i,$classe,centroide_x_$j) et data_image($i,$classe,centroide_y_$j) : coordonnées du centroide de l'astre d'indice j dans sa classe pour l'image i.
	# - @c data_image($i,r1x), $data_image($i,r1y) et data_image($i,ro) : paramètres (axe principaux et facteur d'allongement) de l'ellipse de la fenêtre d'ouverture du flux de l'astre.
	# - @c data_image($i,r2) et data_image($i,r3) : rayons interne et externe de la couronne destinée à la mesure du fond de ciel.
	# - @c parametres(surechantillonage) : facteur linéaire de suréchantillonage. Les pixels seront divisés en parametres(surechantillonage) * parametres(surechantillonage) sous-pixels carrés pour augmenter la précision des calculs.
	# .
    # @post Les variables suivantes contiendront :
	# - @c data_image($i,$classe,flux_$j) : flux de l'astre j dans sa classe pour l'image i.
	# - @c data_image($i,$classe,nb_pixels_$j) : nombre de pixels de l'ellipse qui a servi au calcul du flux de l'astre j dans sa classe pour l'image i.
    # - @c data_image($i,$classe,fond_$j) : valeur moyenne du fond de ciel pour l'astre j dans sa classe pour l'image i.
    # - @c data_image($i,$classe,nb_pixels_fond_$j) : nombre de pixels de la couronne qui a servià la mesure du fond de ciel pour l'astre j dans sa classe pour l'image i.
    # - @c data_image($i,$classe,sigma_fond_$j) : écart-type de valeur du fond de ciel pour l'astre j dans sa classe pour l'image i.
	# .
    proc FluxOuverture {i classe j} {
        global audace
        variable data_image
        variable data_script
        variable parametres
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        Message debug "x0=%f y0=%f\n" $data_image($i,$classe,centroide_x_$j) $data_image($i,$classe,centroide_y_$j)

        if {($data_image($i,$classe,centroide_y_$j) > 0) && ($data_image($i,$classe,centroide_x_$j) > 0)} {
            # Mesure du flux, et recuperation des donnees
            set temp [jm_fluxellipse $audace(bufNo) $data_image($i,$classe,centroide_x_$j) $data_image($i,$classe,centroide_y_$j) $data_image($i,r1x) $data_image($i,r1y) $data_image($i,ro) $data_image($i,r2) $data_image($i,r3) $parametres(surechantillonage)]
            set data_image($i,$classe,flux_$j) [lindex $temp 0]
            set data_image($i,$classe,nb_pixels_$j) [lindex $temp 1]
            set data_image($i,$classe,fond_$j) [lindex $temp 2]
            set data_image($i,$classe,nb_pixels_fond_$j) [lindex $temp 3]
            set data_image($i,$classe,sigma_fond_$j) [lindex $temp 4]

            if {[info exists data_script(correction_masse_air)]} {
                set coeff [expr pow(10.0, (0.4 * 0.801 * ($data_image($i,$classe,masse_air_$j) - 1.119333)))]

                set data_image($i,$classe,flux_$j) [expr $data_image($i,$classe,flux_$j) * $coeff]
                set data_image($i,$classe,fond_$j) [expr $data_image($i,$classe,fond_$j) * $coeff]
                set data_image($i,$classe,sigma_fond_$j) [expr $data_image($i,$classe,sigma_fond_$j) * $coeff]
            }
        } else {
            set data_image($i,$classe,flux_$j) 0
            set data_image($i,$classe,nb_pixels_$j) 0
            set data_image($i,$classe,fond_$j) 0
            set data_image($i,$classe,nb_pixels_fond_$j) 0
            set data_image($i,$classe,sigma_fond_$j) 0
        }

        if {[info exists data_script(correction_masse_air)]} {
            Message debug "flux corriges de la masse d'air (c=%f, ma=%f)\n" $coeff $data_image($i,$classe,masse_air_$j)
        }
        Message debug "image %d : %s %d  flux=%10.4f nb_pix=%10.4f fond=%10.4f nb_pix_fond=%10.4f sigma=%10.4f\n" $i $classe $j $data_image($i,$classe,flux_$j) $data_image($i,$classe,nb_pixels_$j) $data_image($i,$classe,fond_$j) $data_image($i,$classe,nb_pixels_fond_$j) $data_image($i,$classe,sigma_fond_$j)
    }

	##
	# @brief Calcul du flux de la super-étoile et des pseudo-super-étoiles.
	# @details Détails des calculs :
	# - pour la @ref doc_tech_calcul_flux_super_etoile "super-étoile".
	# - pour les @ref doc_tech_calcul_flux_pseudo-super_etoile "pseudo-super-étoiles".
	# .
	# @param image : indice de l'image courante
	# @pre Les variables suivantes doivent contenir :
	# - @c data_script(nombre_reference) : le nombre d'étoile de référence.
    # - @c data_image(image,ref,flux_j) : le flux de toutes les étoiles de référence j dans l'image courante.
	# .
	# @post Les variables suivantes contiendront :
	# - @c data_image(image, flux_ref_j) : flux de la pseudo-super-étoile pour l'étoile de référence j dans l'image courante.
    # - @c data_image(image, flux_ref_total) : flux de la super-étoile dans l'image courante.
	# .
    proc FluxReference {image} {
        variable data_script
        variable data_image

        Message debug "%s\n" [info level [info level]]

        set nombre_reference $data_script(nombre_reference)
        for {set i 0} {$i < $nombre_reference} {incr i} {
            Message debug "image %d flux ref %d : %10.3f\n" $image $i $data_image($image,ref,flux_$i)
            set flux_ref 0.0
            for {set j 0} {$j < $nombre_reference} {incr j} {
                if {($i != $j)} {
                    set flux_ref [expr $flux_ref + $data_image($image,ref,flux_$j)]
                } else {
                    if {$nombre_reference == 1} {
                        set flux_ref $data_image($image,ref,flux_0)
                    }
                }
            }
            set data_image($image,flux_ref_$i) $flux_ref
        }

        set flux_ref 0.0
        for {set i 0} {$i < $nombre_reference} {incr i} {
            set flux_ref [expr $flux_ref + $data_image($image,ref,flux_$i)]
        }
        set data_image($image,flux_ref_total) $flux_ref

        Message debug "image %d flux ref total : %10.3f\n" $image $data_image($image,flux_ref_total)
        for {set i 0} {$i < $nombre_reference} {incr i} {
            Message debug "image %d flux ref etoile %d : %10.3f\n" $image $i $data_image($image,flux_ref_$i)
        }
    }

    #*************************************************************************#
    #*************  FluxSextractor  ******************************************#
    #*************************************************************************#
    proc FluxSextractor {image classe etoile data} {
        variable data_script
        variable data_image

        Message debug "%s\n" [info level [info level]]

        set data_image($image,$classe,flux_$etoile) [lindex $data 1]
        set data_image($image,$classe,sigma_flux_$etoile) [lindex $data 2]
        set data_image($image,$classe,mag_sextractor_$etoile) [lindex $data 3]
        Message debug "image %d : %s %d  flux=%10.4f sigma=%10.4f\n" $image $classe $etoile $data_image($image,$classe,flux_$etoile) $data_image($image,$classe,sigma_flux_$etoile)
        Message debug "image %d : %s %d  mag_sextractor=%10.4f\n" $image $classe $etoile $data_image($image,$classe,mag_sextractor_$etoile)
    }


	##
	# @brief Calcul de magnitudes et des incertitudes associées
	# @details Ce calcul est fait pour l'astétoïde et pour les étoiles de référence. Est aussi calculé une constante des magnitudes, magnitude d'un astre dont le flux intégré sur une unité de temps (ici la seconde) correspond à 1 ADU au dessus du fond de ciel. @n
	# Formules de calcul :
	# - pour les astres, voir @ref doc_tech_calcul_mag_astre "magnitude des astres"
	# - pour la constante des magnitudes, voir @ref doc_tech_calcul_cste_mag "constante des magnitudes"
	# .
	# Les incertitudes sur la magnitude de l'astre sont aussi calculées depuis cette procédure. Voir @ref CalculErreurOuverture , @ref CalculErreurModelisation ou @ref CalculErreurSextractor.
	# @param i : numéro de l'image dans la liste
    # @pre Les variables suivantes devront contenir :
	# - @c data_script(nombre_variable) : nbre d'asteroïde.
	# - @c data_image(i,c,flux_j) : flux de l'astéroïde ou l'étoile de référence j dans l'image i.
    # - @c data_image(i,flux_ref_total) : flux de la super-étoile dans l'image i.
    # - @c data_script(mag_ref_totale) : magnitude de la super-étoile.
    # - @c data_image(i,temps_expo) : temps de pose de l'image i.
    # @post Les variables suivantes contiendront :
	# - @c data_image(i,c,mag_j) : magnitude de l'astéroide ou de l'étoile de référence j dans l'image i
	# - @c data_image(i,c,sb_j) : snr de l'etoile j de classe c dans l'image i
    # - @c data_image(i,c,erreur_mag_j) : incertitude sur la mag de l'étoile j de classe c dans l'image i
    # - @c data_image(i,c,bruit_flux_j) : bruit de photon de l'étoile j de classe c dans l'image i
    # - @c data_image(i,constante_mag) : constante des magnitudes
    proc MagnitudesEtoiles {i} {
        variable data_image
        variable data_script
        variable parametres

        Message debug "%s\n" [info level [info level]]

        # Calcul par la formule de Pogson
        for {set etoile 0} {$etoile < $data_script(nombre_variable)} {incr etoile} {
            if {([expr $data_image($i,var,flux_$etoile)] > 0) &&  ([expr $data_image($i,flux_ref_total)] > 0)} {
				# La formule principale de tout le script !
                set mag [expr $data_script(mag_ref_totale) -2.5 * log10($data_image($i,var,flux_$etoile) / $data_image($i,flux_ref_total))]
                set data_image($i,var,mag_$etoile) $mag

                if {$parametres(mode) == "modelisation"} {
                    CalculErreurModelisation $i var $etoile
                }
                if {$parametres(mode) == "ouverture"} {
                    set temp [CalculErreurOuverture $i var $etoile]
                    set data_image($i,var,sb_$etoile) [lindex $temp 0]
                    set data_image($i,var,erreur_mag_$etoile) [lindex $temp 1]
                    set data_image($i,var,bruit_flux_$etoile) [lindex $temp 2]
                }
                if {$parametres(mode) == "sextractor"} {
                    CalculErreurSextractor $i var $etoile
                    Message debug "diff mag = %10.4f\n" [expr $mag - $data_image($i,var,mag_sextractor_$etoile)]
                }
            } else {
                set data_image($i,var,mag_$etoile) 99.99
                set data_image($i,var,sb_$etoile) 0
                set data_image($i,var,erreur_mag_$etoile) 99.99
            }
        }

        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            if {([expr $data_image($i,ref,flux_$etoile)] > 0) &&  ([expr $data_image($i,flux_ref_$etoile)] > 0)} {
                set mag [expr $data_script(mag_ref_$etoile) - 2.5 * log10($data_image($i,ref,flux_$etoile) / $data_image($i,flux_ref_$etoile))]
                set data_image($i,ref,mag_$etoile) $mag

                if {$parametres(mode) == "modelisation"} {
                    CalculErreurModelisation $i ref $etoile
                }
                if {$parametres(mode) == "ouverture"} {
                    set temp [CalculErreurOuverture $i ref $etoile]
                    set data_image($i,ref,sb_$etoile) [lindex $temp 0]
                    set data_image($i,ref,erreur_mag_$etoile) [lindex $temp 1]
                    set data_image($i,ref,bruit_flux_$etoile) [lindex $temp 2]
                }
                if {$parametres(mode) == "sextractor"} {
                    CalculErreurSextractor $i ref $etoile
                    Message debug "diff mag = %10.4f\n" [expr $mag - $data_image($i,ref,mag_sextractor_$etoile)]
                }
            } else {
                set data_image($i,ref,mag_$etoile) 99.99
                set data_image($i,ref,sb_$etoile) 0
                set data_image($i,ref,erreur_mag_$etoile) 99.99
            }
        }
        if {[expr $data_image($i,flux_ref_total)] > 0} {
            # Calcul de la constante des magnitudes ramenee a 1s de pose
            set data_image($i,constante_mag) [expr $data_script(mag_ref_totale) + 2.5 * log10($data_image($i,flux_ref_total)) + 2.5 * log10(1.0 / $data_image($i,temps_expo))]
        } else {
            set data_image($i,constante_mag) 99.99
        }

        for {set etoile 0} {$etoile < $data_script(nombre_variable)} {incr etoile} {
            Message debug "image %d etoile var %d: mag= %10.4f\n" $i $etoile $data_image($i,var,mag_$etoile)
        }
        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            Message debug "image %d etoile ref %d: mag= %10.4f\n" $i $etoile $data_image($i,ref,mag_$etoile)
            Message debug "image %d etoile ref %d: sb=%10.4f\n" $i $etoile $data_image($i,ref,sb_$etoile)
        }
        Message debug "image %d constante mag=%10.4f\n" $i $data_image($i,constante_mag)
    }

    #*************************************************************************#
    #*************  MasseAir  ************************************************#
    #*************************************************************************#
    proc MasseAir {image} {
        variable data_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            set ad [lindex $data_image($image,ref,addec_$i) 0]
            set dec [lindex $data_image($image,ref,addec_$i) 1]
            set azalt [mc_radec2altaz [expr 15.0 * $ad] $dec $data_script(observatoire) $data_image($image,date)]
            set data_image($image,ref,hauteur_$i) [lindex $azalt 1]
            set data_image($image,ref,masse_air_$i) [expr 1.0/sin($data_image($image,ref,hauteur_$i) * 0.0174532925199433)]
        }
        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            set ad [lindex $data_image($image,var,addec_$i) 0]
            set dec [lindex $data_image($image,var,addec_$i) 1]
            set azalt [mc_radec2altaz [expr 15.0 * $ad] $dec $data_script(observatoire) $data_image($image,date)]
            set data_image($image,var,hauteur_$i) [lindex $azalt 1]
            set data_image($image,var,masse_air_$i) [expr 1.0/sin($data_image($image,var,hauteur_$i) * 0.0174532925199433)]
        }

        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            Message debug "Image %d ref %d : Haut=%f M.Air=%f\n" $image $i $data_image($image,ref,hauteur_$i) $data_image($image,ref,masse_air_$i)
        }
        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            Message debug "Image %d var %d : Haut=%f M.Air=%f\n" $image $i $data_image($image,var,hauteur_$i) $data_image($image,var,masse_air_$i)
        }
    }

    #*************************************************************************#
    #*************  Modelisation2D  ******************************************#
    #*************************************************************************#
    # Entree : i : no de l'image                                              #
    #          j : indice de l'astre (de 0 a ...                              #
    #          classe : type de l'objet (ref ou var)                          #
    #          coordonees : liste x et y de la position de l'objet            #
    #          parametres(taille_boite) : taille de la zone de modelisation   #
    # Sortie : data_image(i,classe,machin_j) avec machin representant le flux #
    #          le fond, etc... pour l'objet j du type classe                  #
    # Algo : modelisation en 2D, et stockage des parametres                   #
    #        si la mod. est impossible, les parametres retournes ont des      #
    #        valeurs volontairement aberrantes                                #
    #*************************************************************************#
    proc Modelisation2D {i j classe coordonnees} {
        global audace
        variable parametres
        variable data_image
        variable data_script
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        set x_etoile [lindex $coordonnees 0]
        set y_etoile [lindex $coordonnees 1]

        set x1 [expr round($x_etoile - $parametres(tailleboite))]
        set y1 [expr round($y_etoile - $parametres(tailleboite))]
        set x2 [expr round($x_etoile + $parametres(tailleboite))]
        set y2 [expr round($y_etoile + $parametres(tailleboite))]

        # Modelisation
        set temp [jm_fitgauss2d $audace(bufNo) [list $x1 $y1 $x2 $y2]]
        set temp [jm_fitgauss2db $audace(bufNo) [list $x1 $y1 $x2 $y2]]
        #::console::affiche_resultat "temp=$temp\n-------------------\n"

        # Recuperation des resultats
        if {([lindex $temp 1] != 0) && ([lindex $temp 15] != 0)} {
            # La modelisation est correcte (sigma_amplitude va etre utilise au denominateur, et parfois est nul...)
            set data_image($i,$classe,flux_$j) [lindex $temp 12]
            set data_image($i,$classe,fond_$j) [lindex $temp 5]
            set data_image($i,$classe,amplitude_$j) [lindex $temp 4]
            set data_image($i,$classe,sigma_amplitude_$j) [lindex $temp 15]
            set data_image($i,$classe,sigma_flux_$j) [lindex $temp 23]
            set data_image($i,$classe,centroide_x_$j) [lindex $temp 2]
            set data_image($i,$classe,centroide_y_$j) [lindex $temp 3]
            set data_image($i,$classe,alpha_$j) [lindex $temp 9]
            set data_image($i,$classe,ro_$j) [lindex $temp 8]
            set data_image($i,$classe,fwhm1_$j) [lindex $temp 10]
            set data_image($i,$classe,fwhm2_$j) [lindex $temp 11]
            # Determination d'un nombre de pixels equivalent a celui d'une ellipse d'axes 3 sigmas, pi*(3*0.600561*fwhm1)*(3*0.600561*fwhm2)
            set data_image($i,$classe,nb_pixels_$j) [expr 10.19781 * $data_image($i,$classe,fwhm1_$j) * $data_image($i,$classe,fwhm2_$j)]
            set data_image($i,$classe,nb_pixels_fond_$j) 0

#            if {[info exists data_script(correction_masse_air)]} {
#                set data_image($i,$classe,flux_$j) [expr $data_image($i,$classe,flux_$j) * $data_image($i,$classe,masse_air_$j)]
#                set data_image($i,$classe,fond_$j) [expr $data_image($i,$classe,fond_$j) * $data_image($i,$classe,masse_air_$j)]
#                set data_image($i,$classe,sigma_flux_$j) [expr $data_image($i,$classe,sigma_flux_$j) * $data_image($i,$classe,masse_air_$j)]
#            }
            set retour 0
        } else {
            # Attribution de valeurs bidons qui feront eliminer l'image
            set data_image($i,$classe,flux_$j) -1
            set data_image($i,$classe,fond_$j) 0
            set data_image($i,$classe,amplitude_$j) 0
            set data_image($i,$classe,sigma_amplitude_$j) 1
            set data_image($i,$classe,sigma_flux_$j) 1
            set data_image($i,$classe,centroide_x_$j) -1
            set data_image($i,$classe,centroide_y_$j) -1
            set data_image($i,$classe,alpha_$j) 0
            set data_image($i,$classe,ro_$j) 0
            set data_image($i,$classe,fwhm1_$j) 0
            set data_image($i,$classe,fwhm2_$j) 0
            set data_image($i,$classe,nb_pixels_$j) 0
            set data_image($i,$classe,nb_pixels_fond_$j) 0
            set data_script($i,invalidation) [list modelisation $classe $j]
            set retour -1
        }
#            if {[info exists data_script(correction_masse_air)]} {
#                Message debug "flux corriges de la masse d'air\n"
#            }
        Message debug "image %d flux individuel etoile %s %d = %10.4f +- %10.4f\n" $i $classe $j $data_image($i,$classe,flux_$j) $data_image($i,$classe,sigma_flux_$j)
        Message debug "retour %d\n" $retour
        return $retour
    }

    #*************************************************************************#
    #*************  PositionAsteroide  ***************************************#
    #*************************************************************************#
    # Entree : indice cad 1 pour 1ere image, 2 pour la derniere               #
    # Sortie : coord_aster($nombre_variable,$indice) : coord. de l'asteroide  #
    #*************************************************************************#
    proc PositionAsteroide {nom indice} {
        global audace color
        variable calaphot
        variable coord_aster
        variable coord_etoile_x
        variable coord_etoile_y
        variable parametres
        variable data_script

        Message debug "%s\n" [info level [info level]]

        # Calcul du centre de l'asteroide
        set coord_aster($data_script(nombre_variable),$indice) [Centroide]
        if {[llength $coord_aster($data_script(nombre_variable),$indice)] != 0} {
            set cx [lindex $coord_aster($data_script(nombre_variable),$indice) 0]
            set cy [lindex $coord_aster($data_script(nombre_variable),$indice) 1]
            # Recherche si l'etoile a ete deja selectionnee
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
                set taille $parametres(tailleboite)
                Dessin rectangle $coord_aster($data_script(nombre_variable),$indice) [list $taille $taille] $color(yellow) etoile_0
                Dessin verticale $coord_aster($data_script(nombre_variable),$indice) [list $taille $taille] $color(yellow) etoile_0
                Dessin horizontale $coord_aster($data_script(nombre_variable),$indice) [list $taille $taille] $color(yellow) etoile_0
            }
            if {$indice == 2} {
                incr data_script(nombre_variable)
            }
        } else {
            unset coord_aster($data_script(nombre_variable),$indice)
        }
    }

    #*************************************************************************#
    #*************  RecalageAstrometrique  ***********************************#
    #*************************************************************************#
    proc RecalageAstrometrique {image} {
        variable pos_theo
        variable pos_reel
        variable data_image
        variable data_script

        Message debug "%s\n" [info level [info level]]

        set liste_ad [list]
        set liste_dec [list]
        set liste_x [list]
        set liste_y [list]
        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            lappend liste_x [lindex $pos_reel($image,ref,$i) 0]
            lappend liste_y [lindex $pos_reel($image,ref,$i) 1]
            lappend liste_ad [lindex $pos_theo(ref,$i) 3]
            lappend liste_dec [lindex $pos_theo(ref,$i) 4]
        }
        set t [jm_fitastro $data_script(addec_centre_image) $liste_ad $liste_dec $liste_x $liste_y]
        Message debug "Matrice = %s\n" [lrange $t 0 5]
        Message debug "Residus = %s\n" [lrange $t 6 end]
        set data_image($image,matrice_astrometrie) [lrange $t 0 5]
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

        Message debug "%s\n" [info level [info level]]

        set premier [lindex $liste_image 0]
        set dernier [lindex $liste_image end]
        for {set etoile 0} {$etoile < $data_script(nombre_variable)} {incr etoile} {
            set somme_mag 0.0
            set somme2_mag 0.0
            set k 0

            if {$type == 0} {
            # Statistiques sur toutes les images (dont on a pu calculer la magnitude des astres)
                foreach i $liste_image {
                    if {$data_image($i,var,mag_$etoile) <= 90.0} {
                        incr k
                        set somme_mag [expr $somme_mag + $data_image($i,var,mag_$etoile)]
                        set somme2_mag [expr $somme2_mag + $data_image($i,var,mag_$etoile) * $data_image($i,var,mag_$etoile)]
                    }
                }
            } else {
                # Statistiques sur les images filtrees
                foreach i $liste_image {
                    if {$data_image($i,valide) == "Y"} {
                        incr k
                        set somme_mag [expr $somme_mag + $data_image($i,var,mag_$etoile)]
                        set somme2_mag [expr $somme2_mag + $data_image($i,var,mag_$etoile) * $data_image($i,var,mag_$etoile)]
                    }
                }
            }

            if {$k != 0} {
                set moyenne(var,$etoile) [expr $somme_mag / $k]
                # Calcul de l'ecart-type
                #  formule : sigma = sqrt(E(x^2) - [E(x)]^2)
                set s2 [expr ($somme2_mag / $k) - ($moyenne(var,$etoile) * $moyenne(var,$etoile))]
                if {$s2 < 0} {
                    # Ce cas ne devrait jamais se presenter. Mais il a deja ete vu. Pourquoi ? Mystere...
                    set moyenne(var,$etoile) 99.99
                    set ecart_type(var,$etoile) 99.99
                } else {
                    set ecart_type(var,$etoile) [expr sqrt($s2)]
                }
            } else {
                set moyenne(var,$etoile) 99.99
                set ecart_type(var,$etoile) 99.99
            }
        }

        for {set etoile 0} {$etoile < $data_script(nombre_reference)} {incr etoile} {
            set somme_mag 0.0
            set somme2_mag 0.0
            set k 0

            if {$type == 0} {
            # Statistiques sur toutes les images (dont on a pu calculer la magnitude des astres)
                foreach i $liste_image {
                    if {$data_image($i,ref,mag_$etoile) <= 90.0} {
                        incr k
                        set somme_mag [expr $somme_mag + $data_image($i,ref,mag_$etoile)]
                        set somme2_mag [expr $somme2_mag + $data_image($i,ref,mag_$etoile) * $data_image($i,ref,mag_$etoile)]
                    }
                }
            } else {
                # Statistiques sur les images filtrees
                foreach i $liste_image {
                    if {$data_image($i,valide) == "Y"} {
                        incr k
                        set somme_mag [expr $somme_mag + $data_image($i,ref,mag_$etoile)]
                        set somme2_mag [expr $somme2_mag + $data_image($i,ref,mag_$etoile) * $data_image($i,ref,mag_$etoile)]
                    }
                }
            }

            if {$k != 0} {
                set moyenne(ref,$etoile) [expr $somme_mag / $k]
                # Calcul de l'ecart-type
                #  formule : sigma = sqrt(E(x^2) - [E(x)]^2)
                set s2 [expr ($somme2_mag / $k) - ($moyenne(ref,$etoile) * $moyenne(ref,$etoile))]
                if {$s2 < 0} {
                    # Ce cas ne devrait jamais se presenter. Mais il a deja ete vu. Pourquoi ? Mystere...
                    set moyenne(ref,$etoile) 99.99
                    set ecart_type(ref,$etoile) 99.99
                } else {
                    set ecart_type(ref,$etoile) [expr sqrt($s2)]
                }
            } else {
                set moyenne(ref,$etoile) 99.99
                set ecart_type(ref,$etoile) 99.99
            }
        }
    }

    #*************************************************************************#
    #*************  VitesseAsteroide  ****************************************#
    #*************************************************************************#
    # Entree : data_script(delta_jd) : nombre de jj separant les 2 images     #
    #          extremes                                                       #
    # Sortie : vitesse_variable : nombre de pixels en x et y par jj (ou par   #
    #          image) pour chacun des asteroides.                             #
    # Algo : si la diff de JJ entre les images extremes est nulle calcul par  #
    #        image                                                            #
    #        sinon calcul par JJ                                              #
    #*************************************************************************#
    proc VitesseAsteroide {} {
        variable parametres
        variable coord_aster
        variable data_script
        variable vitesse_variable

        Message debug "%s\n" [info level [info level]]

        set premier $data_script(premier_liste)
        set dernier $data_script(dernier_liste)
        # Calcul la vitesse de l'asteroide en pixel/jour
        if {$data_script(delta_jd) == 0} {
            for {set v 0} {$v < $data_script(nombre_variable)} {incr v} {
                set vitesse_variable($v,x) [expr (([lindex $coord_aster($v,2) 0] - [lindex $coord_aster($v,1) 0]) / ($dernier - $premier))]
                set vitesse_variable($v,y) [expr (([lindex $coord_aster($v,2) 1] - [lindex $coord_aster($v,1) 1]) / ($dernier - $premier))]
#                Message debug "Var %d: c1x=%10.4f c2x=%10.4f\n" $v [lindex $coord_aster($v,1) 0] [lindex $coord_aster($v,2) 0]
#                Message debug "Var %d: c1y=%10.4f c2y=%10.4f\n" $v [lindex $coord_aster($v,1) 1] [lindex $coord_aster($v,2) 1]
            }
        } else {
            for {set v 0} {$v < $data_script(nombre_variable)} {incr v} {
                set vitesse_variable($v,x) [expr ([lindex $coord_aster($v,2) 0] - [lindex $coord_aster($v,1) 0]) / $data_script(delta_jd)]
                set vitesse_variable($v,y) [expr ([lindex $coord_aster($v,2) 1] - [lindex $coord_aster($v,1) 1]) / $data_script(delta_jd)]
#                Message debug "Var %d: c1x=%10.4f c2x=%10.4f\n" $v [lindex $coord_aster($v,1) 0] [lindex $coord_aster($v,2) 0]
#                Message debug "Var %d: c1y=%10.4f c2y=%10.4f\n" $v [lindex $coord_aster($v,1) 1] [lindex $coord_aster($v,2) 1]
            }
        }
    }

    #*************************************************************************#
    #*************  XyAddec  *************************************************#
    #*************************************************************************#
    proc XyAddec {image} {
        variable data_script
        variable data_image
        variable pos_reel
        variable trace_log

        Message debug "%s\n" [info level [info level]]

        set liste_ad0 $data_script(addec_centre_image)
        set matrice $data_image($image,matrice_astrometrie)

        for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
            set data_image($image,ref,addec_$i) [jm_xy2addec $liste_ad0 [lrange $pos_reel($image,ref,$i) 0 1] $matrice]
        }
        for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
            set data_image($image,var,addec_$i) [jm_xy2addec $liste_ad0 [lrange $pos_reel($image,var,$i) 0 1] $matrice]
        }

        if {[info exists trace_log]} {
            Message debug "-----------------------\n"
            Message debug "XyAddec\n"
            for {set i 0} {$i < $data_script(nombre_reference)} {incr i} {
                Message debug "Image %d ref %d : Ad=%f Dec=%f\n" $image $i [lindex $data_image($image,ref,addec_$i) 0] [lindex $data_image($image,ref,addec_$i) 1]
            }
            for {set i 0} {$i < $data_script(nombre_variable)} {incr i} {
                Message debug "Image %d var %d : Ad=%f Dec=%f\n" $image $i [lindex $data_image($image,var,addec_$i) 0] [lindex $data_image($image,var,addec_$i) 1]
            }
        }
    }
}