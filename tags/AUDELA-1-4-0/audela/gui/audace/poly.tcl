#
# Fichier : poly.tcl
# Description : Ce script regroupe des fonctions pour g�rer des images FITS polychromes
# Auteur : Benoit MAUGIS
# Mise a jour $Id: poly.tcl,v 1.5 2007-06-14 21:22:19 robertdelmas Exp $
#

# Documentation : voir le fichier poly.htm dans le dossier doc_html.


proc seriesApoly {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set liste_series [lindex $args 0]
    set nom_poly [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    if {[compare_index_series $liste_series -rep $in_rep]==1} {

      # Cr�ation du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)
      set index_serie_max [llength $liste_series]
      foreach index [liste_index [lindex $liste_series 0] -rep $in_rep -ext $ext] {
        for {set k 1} {$k<$index_serie_max} {incr k} {
          buf$num_buf_tmp load [file join $in_rep [lindex $liste_series $k]$index$ext]
          sauve $nom_poly$index -polyNo $k -rep $ex_rep -ext $ext -buf buf$num_buf_tmp
          }
        }
      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp
    } else {
      console::affiche_resultat $caption(poly,erreur_seriesApoly)
      }
  } else {
    error $caption(poly,syntax,seriesApoly)
    }
  }


proc polyAserie {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-ex_polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_poly [lindex $args 0]
    set plan_couleur [lindex $args 1]
    set ex [lindex $args 2]

    # Configuration des options
    set options [lrange $args 3 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set ex_polyNo_index [lsearch -regexp $options_1param "-ex_polyNo"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
    } else {
      set ex_polyNo 1
      }

    # Proc�dure principale
    if {[poly_nbcouleurs $nom_poly -rep $in_rep -ext $ext]>=$plan_couleur} {

      # Cr�ation du buffer temporaire
      set num_buf_tmp [buf::create]
      buf$num_buf_tmp extension $conf(extension,defaut)
      foreach index [liste_index $nom_poly -rep $in_rep -ext $ext] {
        buf$num_buf_tmp load [file join $in_rep "$nom_poly$index$ext;$plan_couleur"]
        sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep $ex_rep -ext $ext
        }
      # Suppression du buffer temporaire
      buf::delete $num_buf_tmp
      }
  } else {
    error $caption(poly,syntax,polyAserie)
    }
  }


proc polyAseries {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_poly [lindex $args 0]
    set liste_series [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    if {[poly_nbcouleurs $nom_poly -rep $in_rep -ext $ext]==[llength $liste_series]} {

      set index_serie_max [llength $liste_series]
      for {set k 0} {$k<=$index_serie_max} {incr k} {
        polyAserie ${nom_poly} [expr $k+1] [lindex $liste_series $k] -in_rep $in_rep -ex_rep $ex_rep -ext $ext
        }
    } else {
      console::affiche_resultat $caption(poly,erreur_polyAseries)
      }
  } else {
    error $caption(poly,syntax,polyAseries)
    }
  }


proc poly_nbcouleurs {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set serie [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set rep $audace(rep_images)
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    # On s�lectionne le fichier que l'on va tester (le dernier de la s�rie)
    set liste_index [liste_index $serie -rep $rep -ext $ext]
    set index [lindex $liste_index [expr [llength $liste_index]-1]]
    set fichier [file join $rep $serie$index$ext]
    set k 1
    set continuer 1
    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]
    buf$num_buf_tmp extension $conf(extension,defaut)
    # Tests
    while {$continuer==1} {
      if [catch {buf$num_buf_tmp load "$fichier;[expr $k+1]"}] {
        set continuer 0
      } else {
        incr k
        }
      }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp

    return $k
  } else {
    error $caption(poly,syntax,poly_nbcouleurs)
    }
  }


proc poly_fenetre {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in [lindex $args 0]
    set ex [lindex $args 1]
    set coord [lindex $args 2]

    # Configuration des options
    set options [lrange $args 3 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    for {set k 1} {$k<=[poly_nbcouleurs $in -rep $in_rep]} {incr k} {
      serie_fenetre $in $ex $coord -in_rep $in_rep -ex_rep $ex_rep -ext $ext -polyNo $k
      }
  } else {
    error $caption(poly,syntax,poly_fenetre)
    }
  }


proc poly_souris_fenetre {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in [lindex $args 0]
    set ex [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    poly_fenetre $in $ex $audace(box) -in_rep $in_rep -ex_rep $ex_rep -ext $ext
  } else {
    error $caption(poly,syntax,poly_souris_fenetre)
    }
  }


proc poly_rot {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 5 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in [lindex $args 0]
    set ex [lindex $args 1]
    set x0 [lindex $args 2]
    set y0 [lindex $args 3]
    set angle [lindex $args 4]

    # Configuration des options
    set options [lrange $args 5 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    for {set k 1} {$k<=[poly_nbcouleurs $in -rep $in_rep]} {incr k} {
      serie_rot $in $ex $x0 $y0 $angle -in_rep $in_rep -ex_rep $ex_rep -ext $ext -polyNo $k
      }
  } else {
    error $caption(poly,syntax,poly_rot)
    }
  }


proc poly_trans {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 4 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in [lindex $args 0]
    set ex [lindex $args 1]
    set dx [lindex $args 2]
    set dy [lindex $args 3]

    # Configuration des options
    set options [lrange $args 4 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    for {set k 1} {$k<=[poly_nbcouleurs $in -rep $in_rep]} {incr k} {
      serie_trans $in $ex $dx $dy -in_rep $in_rep -ex_rep $ex_rep -ext $ext -polyNo $k
      }
  } else {
    error $caption(poly,syntax,poly_trans)
    }
  }


proc poly_series_traligne {args} {
#--- Debut Modif Robert
  global audace caption conf script
#--- Fin Modif Robert

  if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set liste_in [lindex $args 0]
    set No_ref [lindex $args 1]
    set ex [lindex $args 2]

    # Configuration des options
    set options [lrange $args 3 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $rep_index] 1]
      set ex_rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set in_rep $audace(rep_images)
      set ex_rep $audace(rep_images)
      }
    if {$in_rep_index>=0} {
      set in_rep [lindex [lindex $options_1param $in_rep_index] 1]
      }
    if {$ex_rep_index>=0} {
      set ex_rep [lindex [lindex $options_1param $ex_rep_index] 1]
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }

    # Proc�dure principale
    # On supprime d'�ventuels fichiers d�j� pr�sents de la s�rie-cible
    suppr_serie $ex -rep $ex_rep -ext $ext

    # La s�rie de r�f�rence est recopi�e sans modifications
    set serie_ref [lindex $liste_in 0]
    copie $serie_ref $ex -in_rep $in_rep -ex_rep $ex_rep -ext $ext
    # Tout au plus on la renum�rote.
    renumerote $ex -rep $ex_rep -ext $ext

    # On garde en m�moire le nom du dernier fichier de cette s�rie, qui servira de
    # r�f�rence pour recaler la s�rie suivante
    set liste_index_ref [lsort -integer [liste_index $ex -rep $ex_rep -ext $ext]]
    set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
    set fichier_ref [file join $ex_rep "$ex$index_ref$ext;$No_ref"]

    # A pr�sent, on fait les transformations sur les autres s�ries :
    set series_amodif [lrange $liste_in 1 [expr [llength $liste_in]-1]]

    # Les fichiers temporaires sont stock�s dans un r�pertoire temporaire
    set rep_tmp [cree_sousrep -rep $ex_rep -nom_base "tmp_poly_series_traligne"]

    foreach serie $series_amodif {

      # On d�termine le cadre de r�f�rence ;
      console::affiche_resultat "$caption(poly,series_trreg_cadre-ref) $serie\n"
      loadima $fichier_ref

      # Cr�ation de la fen�tre
      set script(poly_series_traligne,attente) 0
      toplevel .poly_series_traligne
      label .poly_series_traligne.lab -text $caption(poly,tracebox)
      pack .poly_series_traligne.lab -expand true
      button .poly_series_traligne.but -command {set script(poly_series_traligne,attente) 0} -text "ok"
      pack .poly_series_traligne.but -expand true

      # On attend que l'utilisateur ait valid�
      vwait script(poly_series_traligne,attente)

      # On supprime la fen�tre
      destroy .poly_series_traligne

      # On enregistre les coordonn�es du cadre
      set cadre_ref $audace(box)

      console::affiche_resultat "$caption(poly,series_trreg_cadre-a-rec) $serie\n"
      # Chargement du premier fichier de la s�rie courante
      set liste_index [lsort -integer [liste_index $serie -rep $in_rep -ext $ext]]
      loadima [file join $in_rep "$serie[lindex $liste_index 0]$ext;$No_ref"]

      # Cr�ation de la fen�tre
      set script(poly_series_traligne,attente) 0
      toplevel .poly_series_traligne
      label .poly_series_traligne.lab -text $caption(poly,tracebox)
      pack .poly_series_traligne.lab -expand true
      button .poly_series_traligne.but -command {set script(poly_series_traligne,attente) 0} -text "ok"
      pack .poly_series_traligne.but -expand true
      # On attend que l'utilisateur ait valid�
      vwait script(poly_series_traligne,attente)
      # On supprime la fen�tre
      destroy .poly_series_traligne
      # On enregistre les coordonn�es du cadre
      set cadre_amodif $audace(box)
      # Calcul des modifications de translation / rotation
      set modifs [calcul_trzaligne $cadre_ref $cadre_amodif]

      # Translation (en entiers pour �viter de d�grader la r�solution)
      console::affiche_resultat "$caption(poly,series_trreg_transl) $serie\n"
      poly_trans $serie tmp_trans_$serie [expr round([lindex $modifs 0])] [expr round([lindex $modifs 1])] -in_rep $in_rep -ex_rep $rep_tmp -ext $ext
      # Rotation
      console::affiche_resultat "$caption(poly,series_trreg_rot) $serie\n"
      poly_rot tmp_trans_$serie tmp_rot_$serie [lindex $modifs 2] [lindex $modifs 3] [lindex $modifs 4] -rep $rep_tmp -ext $ext
      # Suppression de la s�rie temporaire de translation (si on n'avait pas cette s�rie temporaire,
      # l'auto-�crasement bugge)
      suppr_serie tmp_trans_$serie -rep $rep_tmp -ext $ext
      # On renomme vers la s�rie de destination
      renomme tmp_rot_$serie $ex -in_rep $rep_tmp -ex_rep $ex_rep -ext $ext

      # On garde en m�moire le nom du dernier fichier de cette s�rie, qui servira de
      # r�f�rence pour recaler la s�rie suivante
      set liste_index_ref [lsort -integer [liste_index $ex -rep $ex_rep -ext $ext]]
      set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
      set fichier_ref [file join $ex_rep "$ex$index_ref$ext;$No_ref"]
      }

    # Suppression du r�pertoire temporaire
    file delete $rep_tmp
  } else {
    error $caption(poly,syntax,poly_series_traligne)
    }
  }


########## The end ##########

