#
# Fichier : compute_stellaire.tcl
# Description : Fonction de prétraitement automatique
# Auteur : Benoît Maugis
# Date de MAJ : 9 octobre 2004
# Version : 1.03b


#  Documentation : voir le fichier compute_stellaire.htm dans le dossier doc_html.


# Procédure

proc compute_stellaire {args} {
  global audace caption conf confFichierIma

  if {[syntaxe_args $args 1 3 [list "" [list "-buf" "-rep" "-ext" "-polyNo" "-tri"]]]=="1"} {

    # Configuration des paramètres obligatoires
    set brutes [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des paramètres optionnels
    set params_optionnels [lindex $range_options 0]
    if {[llength $params_optionnels] >= 1} {
      set noirs [lindex $params_optionnels 0]
    } else {
      set noirs "pas_de_noirs"
      }
    if {[llength $params_optionnels] >= 2} {
      set PLUs [lindex $params_optionnels 1]
    } else {
      set PLUs "pas_de_PLUs"
      }
    if {[llength $params_optionnels] == 3} {
      set noirsdePLUs [lindex $params_optionnels 2]
    } else {
      set noirsdePLUs "pas_de_noirsdePLUs"
      }

    # Configuration des options à 1 paramètre
    set options_1param [lindex $range_options 2]

    set buf_index [lsearch -regexp $options_1param "-buf"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set tri_index [lsearch -regexp $options_1param "-tri"]

    if {$buf_index>=0} {
      set buf [lindex [lindex $options_1param $buf_index] 1]
    } else {
      set buf $audace(bufNo)
      }
    if {$rep_index>=0} {
      set rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set rep $audace(rep_images)
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
    } elseif {$confFichierIma(fichier,compres)==0} {
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$tri_index>=0} {
      set tri [lindex [lindex $options_1param $tri_index] 1]
    } else {
      set tri 80
      }

    # Procédure principale
    console::affiche_resultat "$caption(compute,debut)"

    # On vérifie que la série d'images brutes existe bien
    set index_brutes [lsort [liste_index $brutes -rep "$rep" -ext $ext]]
    # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
    if [catch [set index_brutes [lsort -integer $index_brutes]]] {}
    if {[llength $index_brutes]==0} {
      tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,nobrutes)
      console::affiche_resultat "$caption(compute,fin)"
      return
    } else {
      console::affiche_resultat "$caption(compute,brutesok) [llength $index_brutes]\n"
      }
         
    # On vérifie que la série d'images de noir existe bien
    if {$noirs!="pas_de_noirs"} {
      set index_noirs [lsort [liste_index $noirs -rep "$rep" -ext $ext]]
      # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
      if [catch [set index_noirs [lsort -integer $index_noirs]]] {}
      if {[llength $index_noirs]==0} {
        tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,nonoirs)
        console::affiche_resultat "$caption(compute,fin)"
        return
      } else {
        console::affiche_resultat "$caption(compute,noirsok) [llength $index_noirs]\n"
        }
      }
  
    # On vérifie que la série d'images de PLU existe bien
    if {$PLUs!="pas_de_PLUs"} {
      set index_PLUs [lsort [liste_index $PLUs -rep "$rep" -ext $ext]]
      # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
      if [catch [set index_PLUs [lsort -integer $index_PLUs]]] {}
      if {[llength $index_PLUs]==0} {
        tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,noPLUs)
        console::affiche_resultat "$caption(compute,fin)"
        return
      } else {
        console::affiche_resultat "$caption(compute,PLUsok) [llength $index_PLUs]\n"
        }
      }
  
    # On vérifie que la série d'images de noirs de PLUs existe bien
    if {$noirsdePLUs!="pas_de_noirsdePLUs"} {
      set index_noirsdePLUs [lsort [liste_index $noirsdePLUs -rep "$rep" -ext $ext]]
      # Si possible on trie par ordre croissant (sauf dans le cas d'indexation XXX par ex.)
      if [catch [set index_noirsdePLUs [lsort -integer $index_noirsdePLUs]]] {}
      if {[llength $index_noirsdePLUs]==0} {
        tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,nonoirsdePLUs)
        console::affiche_resultat "$caption(compute,fin)"
        return
      } else {
        console::affiche_resultat "$caption(compute,noirsdePLUsok) [llength $index_noirsdePLUs]\n"
        }
      }

    # On vérifie que le pourcentage d'images à conserver pour le compositage est cohérent
    # (réel strictement positif inférieur à 100)
    if {[TestReel $tri] == 0} {
      tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,pbpourcentage)
      console::affiche_resultat "$caption(compute,fin)"
      return
      }
    if {$tri>100} {
      tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,pbpourcentage)
      console::affiche_resultat "$caption(compute,fin)"
      return
      }  
    if {$tri<0} {
      tk_messageBox -title $caption(compute,pb) -type ok -message $caption(compute,pbpourcentage)
      console::affiche_resultat "$caption(compute,fin)"
      return
      }  

    # Création du répertoire temporaire
    set rep_tmp [cree_sousrep -nom_base tmp_compute_stellaire -rep $rep]

    # Création du buffer temporaire
    set num_buf_tmp [buf::create]

    if {$noirs!="pas_de_noirs"} {
      # Création de l'image de noir (par médiane) dans le buffer temporaire
      console::affiche_resultat "$caption(compute,tmp_noir)"
      mediane $noirs -rep "$rep" -ext $ext -buf $num_buf_tmp -polyNo $in_polyNo

      # Soustraction du noir
      console::affiche_resultat "$caption(compute,tmp_brute-noir_X)"
      serie_soustrait $brutes tmp_brute-noir_ -buf $num_buf_tmp -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo

      if {$PLUs!="pas_de_PLUs"} {

        if {$noirsdePLUs!="pas_de_noirsdePLUs"} {
          # Création de l'image de noir de PLUs (par médiane)
          console::affiche_resultat "$caption(compute,tmp_noirdePLUs)"
          # NB : on ne refait explicitement le calcul de médiane que si les noirs de PLUs sont différents des noirs, 
          # sinon le noir a déjà été calculé précédemment et figure toujours dans le buffer temporaire
          if {$noirs != $noirsdePLUs } {
            mediane $noirsdePLUs -rep "$rep" -ext $ext -buf $num_buf_tmp -polyNo $in_polyNo
	    }

          # Soustraction du noir de PLUs
          console::affiche_resultat "$caption(compute,tmp_PLU-noir_X)"
          serie_soustrait $PLUs tmp_PLU-noir_ -buf $num_buf_tmp -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo

          # Normalisation du gain des PLUs
          console::affiche_resultat "$caption(compute,tmp_PLUnorm_X)"
          normalise_gain tmp_PLU-noir_ tmp_PLUnorm_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

          # Suppression de la série temporaire de PLUs nettoyées du noir
          suppr_serie tmp_PLU-noir_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]
        
        } else {
          # Normalisation du gain des PLUs
          console::affiche_resultat "$caption(compute,tmp_PLUnorm_X)"
          normalise_gain $PLUs tmp_PLUnorm_ -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo
          }

        # Création de l'image de PLUs (par médiane)
        console::affiche_resultat "$caption(compute,tmp_PLU)"
        mediane tmp_PLUnorm_ -rep "$rep_tmp" -ext [lindex [decomp $ext] 3] -buf $num_buf_tmp

        # Suppression de la série temporaire de PLUs normalisées
        suppr_serie tmp_PLUnorm_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

        # Normalisation par PLU
        console::affiche_resultat "$caption(compute,tmp_pret_X)"
        serie_normalise tmp_brute-noir_ tmp_pret_ -buf $num_buf_tmp -rep $rep_tmp -ext [lindex [decomp $ext] 3]

        # Suppression des images temporaires nettoyées du noir
        suppr_serie tmp_brute-noir_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

        # Registration
        console::affiche_resultat "$caption(compute,tmp_registr_X)"
        aligne tmp_pret_ tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

        # Suppression des images prétraitées
        suppr_serie tmp_pret_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

      } else {
        # En l'absence de PLUs : on fait l'alignement sur les images nettoyées du noir
	aligne tmp_brute-noir_ tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

        # Suppression des images prétraitées
        suppr_serie tmp_brute-noir_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]
        }

    } else {
      # En l'absence d'images de noir : on fait la registration sur les images brutes.
      aligne $brutes tmp_registr_ -in_rep $rep -ex_rep $rep_tmp -in_ext $ext -ex_ext [lindex [decomp $ext] 3] -in_polyNo $in_polyNo
      }

    # Tri par FWHM
    console::affiche_resultat "$caption(compute,tri_FWHM)"
    foreach index [liste_index tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]] {
      charge tmp_registr_$index -rep $rep_tmp -ext [lindex [decomp $ext] 3] -buf $num_buf_tmp
      set fwhm [lindex [buf$num_buf_tmp getkwd "FWHM"] 1]
      lappend fwhm_list $fwhm
      lappend NoFwhm_list [list $index $fwhm]
      }
    set fwhm_list [lsort -increasing $fwhm_list]
    set NoMax [expr int(0.01*[llength $index_brutes]*$tri)]
    set fwhmMax [lindex $fwhm_list $NoMax]
    console::affiche_resultat "$caption(compute,FWHM_max) [string range $fwhmMax 0 3]...\n"
    foreach NoFwhm $NoFwhm_list {
      if {[lindex $NoFwhm 1]<=$fwhmMax} {
        set index [lindex $NoFwhm 0]
        file rename [file join $rep_tmp tmp_registr_$index[lindex [decomp $ext] 3]] [file join $rep_tmp tmp_tri_$index[lindex [decomp $ext] 3]]
        }
      }
    # Suppression des images non sélectionnées
    suppr_serie tmp_registr_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp

    # Renumérotation des images sélectionnées
    renumerote tmp_tri_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]

    # Compositage Sigma-Kappa
    console::affiche_resultat "$caption(compute,compositage)"
    ttscript2 "IMA/STACK \"$rep_tmp\" tmp_tri_ 1 [llength [liste_index tmp_tri_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]]] [lindex [decomp $ext] 3] \"$rep_tmp\" tmp_finale . [lindex [decomp $ext] 3] SK kappa=3 bitpix=-32"

    # Suppression des images triées temporaires
    suppr_serie tmp_tri_ -rep $rep_tmp -ext [lindex [decomp $ext] 3]
  
    # Chargement de l'image finale
    charge tmp_finale -rep $rep_tmp -ext [lindex [decomp $ext] 3]

    # MAJ en-tête audace
    wm title $audace(base) "$caption(compute,audace) - $caption(compute,imafinale)"

    # Suppression de l'image finale sauvée sur le disque
    file delete [file join $rep_tmp tmp_finale[lindex [decomp $ext] 3]]

    # Suppression du répertoire temporaire
    file delete $rep_tmp

    console::affiche_resultat "$caption(compute,fin)"

  } else {
    error $caption(compute,syntax,stellaire)

    }
  }


########## The end ##########

