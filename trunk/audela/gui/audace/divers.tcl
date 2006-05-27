#
# Fichier divers.tcl
# Ce script regroupe diverses petites fonctions.
# Auteur : Beno�t Maugis
# Version : 1.18.3 ---> 1.18.4
# Date de mise a jour : 10 avril 2005 ---> 27 mai 2006
#

# Documentation : voir le fichier divers.htm dans le dossier doc_html.

######################################################
###############   Fonctions basiques   ###############
######################################################


proc charge {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

    if {[syntaxe_args $args 0 1 [list [list "-novisu" "-dovisu"] [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

    # Configuration des options
    set range_options [range_options $args]

    # Configuration des param�tres optionnels
    set params_optionnels [lindex $range_options 0]
    if {[llength $params_optionnels] == "0"} {
      set fichier "?"
    } else {
      set fichier [lindex $params_optionnels 0]
      }

    # Configuration des options sans param�tre
    set options_0param [lindex $range_options 1]
    set novisu_index [lsearch $options_0param "-novisu"]
    if {$novisu_index>=0} {
      set novisu "-novisu"
    } else {
      set novisu "-dovisu"
      }

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set buf_index [lsearch -regexp $options_1param "-buf"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
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

    # Proc�dure principale
    # 1er cas : pas de nom de fichier donn�, on doit donc afficher une bo�te de dialogue
    if {$fichier == "?"} {
      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la boite de choix des images
      set nom_complet [ ::tkutil::box_load $fenetre $rep $audace(bufNo) "1" ]
    # 2nd cas : selon $fichier, on rajoute ou pas les infos de nom de 
    # r�pertoire et d'extension pour former le nom complet.
    } else {
      # Nom relatif ou absolu...
      if {[file pathtype $fichier] == "absolute"} {
        set nom_complet $fichier
      } else {
        set nom_complet [file join "$rep" "$fichier"]
      }
      # Extension comprise ou pas...
      if {[file extension $fichier] == ""} {
        set nom_complet $nom_complet$ext
        }
      }

    # On n'ajoute le n� de plan couleur � ouvrir que si celui-ci est distinct du 1er
    if {$in_polyNo != "1"} {
      set nom_complet "$nom_complet;$in_polyNo"
      }

    if {[string compare $nom_complet ""] != 0 } {

      # Si le fichier est compress� par bzip2, on le copie dans le r�pertoire 
      # temporaire pour le d�compresser

      if {[file extension $nom_complet] == ".bz2"} {

#--- Debut Modif Robert
        switch $::tcl_platform(os) {
#--- Fin Modif Robert
        "Linux" {
          # Sous Linux, on copie le fichier dans un sous-r�pertoire de /tmp/.audela
          # on le d�compresse et on essaie de le recharger � partir de l�
          set dossier_tmp [cree_sousrep -nom_base [suppr_accents [file tail $fichier]] -rep "/tmp/.audela"]
          set fichier_tmp [file join $dossier_tmp [file tail $nom_complet]]
          file copy $nom_complet $fichier_tmp
          exec bunzip2 $fichier_tmp
          charge [file rootname $fichier_tmp] -buf $buf -novisu
          file delete [file rootname $fichier_tmp]
          file delete $dossier_tmp
          # Si chargement dans le buffer Aud'ACE :
          # on rafra�chit (�ventuellement) l'affichage du bandeau
          if {[string compare $buf $audace(bufNo)] == 0} {
            if {$novisu != "-novisu"} {
              wm title $audace(base) "$caption(divers,audace) - $nom_complet"
#--- Debut modif Robert
              audace::autovisu $audace(visuNo)
#--- Fin modif Robert
              }
            }
          }
        default {
          # Sous les autres syst�mes d'exploitation (dont Windows)
          # les fichiers .fit.bz2 ne sont pas pris en charge.

          }
        }

      } else {

        # On v�rifie que le nom de fichier est valide, ie ne comporte 
        # pas d'accents, sinon la librairie fitsio sera incapable de 
        # de le charger.

        if {[nom_valide $nom_complet]==1} {

          if {[string compare $buf $audace(bufNo)] == 0} {
             loadima "$nom_complet" $novisu
          } else {
             buf$buf load "$nom_complet"
            }
        } else {

          # Le nom complet de fichier comporte des caract�res accentu�s.
#--- Debut Modif Robert
          switch $::tcl_platform(os) {
#--- Fin Modif Robert
          "Linux" {
            # Sous Linux, on copie le fichier dans /tmp/.audela
            # en supprimant les caract�res accentu�s et on essaie 
            # de le recharger � partir de l�.
            set fichier_tmp [cree_fichier -nom_base [suppr_accents [file tail $fichier]] -rep "/tmp/.audela"]
            file delete $fichier_tmp
            file copy $fichier $fichier_tmp
            charge $fichier_tmp -buf $buf -novisu
            file delete $fichier_tmp
            # Si chargement dans le buffer Aud'ACE :
            # on rafra�chit (�ventuellement) l'affichage du bandeau
            if {[string compare $buf $audace(bufNo)] == 0} {
              if {$novisu != "-novisu"} {
                wm title $audace(base) "$caption(divers,audace) - $nom_complet"
#--- Debut modif Robert
                audace::autovisu $audace(visuNo)
#--- Fin modif Robert
                }
              }
            }
          default {
            # Sous les autres syst�mes d'exploitation (dont Windows)
            # faute d'un dossier temporaire bien d�fini, on signale 
            # le probl�me sans y rem�dier.
            console::affiche_resultat "${caption(divers,nom_invalide)}\n $nom_complet\n"
            }
          }
        }
      }
    }
  } else {
    error $caption(divers,syntax,charge)
    }
  }


proc sauve {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 0 1 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

    # Configuration des options
    set range_options [range_options $args]

    # Configuration des param�tres optionnels
    set params_optionnels [lindex $range_options 0]
    if {[llength $params_optionnels] == "0"} {
      set fichier "?"
    } else {
      set fichier [lindex $params_optionnels 0]
      }

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set buf_index [lsearch -regexp $options_1param "-buf"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }
    if {$polyNo_index>=0} {
      set polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set polyNo 1
      }

    # Proc�dure principale
    # 1er cas : pas de nom de fichier donn�, on doit donc afficher une bo�te de dialogue
    if {$fichier == "?"} {
      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la boite de choix des images
      set nom_complet [ ::tkutil::box_save $fenetre $rep $audace(bufNo) "1" ]

    # 2nd cas : selon $fichier, on rajoute ou pas les infos de nom de 
    # r�pertoire et d'extension pour former le nom complet.
    } else {
      # Nom relatif ou absolu...
      if {[file pathtype $fichier] == "absolute"} {
        set nom_complet $fichier
      } else {
        set nom_complet [file join "$rep" "$fichier"]
        }
      # Extension comprise ou pas...
      if {[file extension $fichier] == ""} {
        set nom_complet $nom_complet$ext
        }
      }

    if {[string compare $nom_complet ""] != 0 } {
      if { [ buf$buf imageready ] == "1" } {
        # Si le fichier de destination n'existe pas, on ne tient pas compte du n� de buffer dans lequel sauvegarder
        if {[file exist $nom_complet] == "0"} {
          set result [buf$buf save "$nom_complet"]
        } else {
          # Fichier existant avec �ventuellement plusieurs plans couleurs :

          # 1er cas : on veut sauvegarder sur un num�ro de plan couleur
          # sup�rieur � tous ceux existants : pas de probl�mes.
          set dern_num_buf [buf::create]
          if [catch {charge $nom_complet -buf $dern_num_buf -polyNo $polyNo}] {
            buf::delete $dern_num_buf
            set result [buf$buf save "$nom_complet;$polyNo"]
          } else {

            buf::delete $dern_num_buf

            # Second cas : on veut enregistrer sur un plan couleur 
            # d�j� existant, por �viter un bug on doit charger tous les plans couleurs, 
            # effacer le fichier existant et tout r�enregistrer dans l'ordre.

            # Chargement des plans couleurs dans des buffers temporaires
            set continuer "1"
            set liste_buf_tmp ""
            set no_plan 1
            while {$continuer==1} {
              set dern_num_buf [buf::create]
              if [catch {charge $nom_complet -buf $dern_num_buf -polyNo $no_plan}] {
                set continuer 0
                buf::delete $dern_num_buf
              } else {
                lappend liste_buf_tmp $dern_num_buf
                }
              incr no_plan
            }

            # Effacement du fichier
            file delete $nom_complet
            # Enregistrement des plans couleurs successifs et lib�ration des 
            # tampons images correspondant

            # On fait le premier plan � part...
            if {"1" == $polyNo} {
              set result [buf$buf save "$nom_complet"]
            } else {
              set result [buf[lindex $liste_buf_tmp 0] save "$nom_complet"]
              }
            buf::delete [lindex $liste_buf_tmp 0]

            # ... puis les autres.
            for {set no_plan 2} {$no_plan <= [llength $liste_buf_tmp]} {incr no_plan} {
              if {$no_plan == $polyNo} {
                set result [buf$buf save "$nom_complet;$no_plan"]
              } else {
                set result [buf[lindex $liste_buf_tmp [expr $no_plan-1]] save "$nom_complet;$no_plan"]
                }
              buf::delete [lindex $liste_buf_tmp [expr $no_plan-1]]
              }
            }
            set nom_complet "nom_complet;$polyNo"
          }
        if {$result == "" && [string compare $buf $audace(bufNo)] == 0} {
          wm title $audace(base) "$caption(divers,audace) - $nom_complet"
        }
      }
    }

  } else {
    error $caption(divers,syntax,sauve)
    }
  }


proc sauve_jpeg {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 0 1 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des options
    set range_options [range_options $args]

    # Configuration des param�tres optionnels
    set params_optionnels [lindex $range_options 0]
    if {[llength $params_optionnels] == "0"} {
      set fichier "?"
    } else {
      set fichier [lindex $params_optionnels 0]
      }

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$rep_index>=0} {
      set rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set rep $audace(rep_images)
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
    } else {
      set ext ".jpg"
      }

    # Proc�dure principale
    # 1er cas : pas de nom de fichier donn�, on doit donc afficher une bo�te de dialogue
    if {$fichier == "?"} {
      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la boite de choix des images
      set nom_complet [ ::tkutil::box_save $fenetre $rep $audace(bufNo) "2" ]
    } else {
      set nom_complet [file join "$rep" "$fichier$ext"]
      }

    if {[string compare $nom_complet ""] != 0 } {
      if { [ buf$audace(bufNo) imageready ] == "1" } {

        # Deux cas sont possibles : 
        # - si la palette est monochrome, on enregistre en jpeg N&B.
        # - si la palette est polychrome, on enregistre en jpeg couleurs

#--- Debut modif Robert
        if {$conf(visu_palette,visu$audace(visuNo),mode)<=2} {
#--- Fin modif Robert
          # Sauvegarde en jpeg monochrome

          # On r�cup�re la fonction de transfert
          set palette [file join [visu$audace(visuNo) paldir] [visu$audace(visuNo) pal].pal]
          set fileId [open $palette r]
          set palette_R ""
          for {set k 0} {$k<256} {incr k} {
            gets $fileId ligne
            lappend palette_R [lindex $ligne 0]
            }
          close $fileId

          # Cr�ation du buffer temporaire
          set num_buf_tmp [buf::create]
          buf$audace(bufNo) copyto $num_buf_tmp 

          bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_R}

          # Enregistrement de l'image
          buf$num_buf_tmp savejpeg $nom_complet $conf(jpegquality,defaut) [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0]

          # Suppression du buffer temporaire
          buf::delete $num_buf_tmp

      } else {

          # On r�cup�re la fonction de transfert
          set palette [file join [visu$audace(visuNo) paldir] [visu$audace(visuNo) pal].pal]
          set fileId [open $palette r]
          set palette_R ""
          set palette_V ""
          set palette_B ""
          for {set k 0} {$k<256} {incr k} {
            gets $fileId ligne
            lappend palette_R [lindex $ligne 0]
            lappend palette_V [lindex $ligne 1]
            lappend palette_B [lindex $ligne 2]
            }
          close $fileId

          # Cr�ation du buffer temporaire
          set num_buf_tmp [buf::create]

          # Cr�ation d'un r�pertoire temporaire
          set rep_tmp [cree_sousrep -nom_base "tmp_sauve_jpeg"]

          # Enregistrement des plans R, V et B
          # plan R
          buf$audace(bufNo) copyto $num_buf_tmp
          bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_R}
          sauve plan_R -buf $num_buf_tmp -rep $rep_tmp -ext $conf(extension,defaut)
          # plan V
          buf$audace(bufNo) copyto $num_buf_tmp
          bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_V}
          sauve plan_V -buf $num_buf_tmp -rep $rep_tmp -ext $conf(extension,defaut)
          # plan B
          buf$audace(bufNo) copyto $num_buf_tmp
          bm_hard2visu $num_buf_tmp [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] ${palette_B}
          sauve plan_B -buf $num_buf_tmp -rep $rep_tmp -ext $conf(extension,defaut)	

          # Suppression du buffer temporaire
          buf::delete $num_buf_tmp

          # Enregistrement de l'image
          fits2colorjpeg [file join $rep_tmp plan_R$conf(extension,defaut)] [file join $rep_tmp plan_V$conf(extension,defaut)] [file join $rep_tmp plan_B$conf(extension,defaut)] $nom_complet $conf(jpegquality,defaut) [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0] [lindex [visu$audace(visuNo) cut] 1] [lindex [visu$audace(visuNo) cut] 0]

          # Suppression des fichiers temporaires
          file delete [file join $rep_tmp plan_R$conf(extension,defaut)]
          file delete [file join $rep_tmp plan_V$conf(extension,defaut)]
          file delete [file join $rep_tmp plan_B$conf(extension,defaut)]
          file delete $rep_tmp
          }
        }
      }

  } else {
    error $caption(divers,syntax,sauve_jpeg)
    }
  }


proc soustrait {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set fichier_aux [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set buf_index [lsearch -regexp $options_1param "-buf"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }
    if {$polyNo_index>=0} {
      set aux_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set aux_polyNo 1
      }

    # Proc�dure principale
    buf$buf sub [file join "$rep" "$fichier_aux$ext;$aux_polyNo"] 0
    
    # Si le buffer de travail est le buffer Aud'ACE, on refra�chit l'affichage
    if {$audace(bufNo) == $buf} {
#--- Debut modif Robert
      audace::autovisu $audace(visuNo)
#--- Fin modif Robert
      }

  } else {
    error $caption(divers,syntax,soustrait)
    }
  }


proc normalise {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set fichier_aux [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set buf_index [lsearch -regexp $options_1param "-buf"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }
    if {$polyNo_index>=0} {
      set aux_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set aux_polyNo 1
      }

    # Proc�dure principale
    # Cr�ation d'un tampon image temporaire
    set num_buf_tmp [buf::create]
    # On charge l'image auxiliaire pour d�terminer la moyenne de son fond de ciel
    charge $fichier_aux -buf $num_buf_tmp -rep "$rep" -ext $ext -polyNo $aux_polyNo
    set moy [lindex [buf$num_buf_tmp stat] 6]    
    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp
 
    # Normalisation
    buf$buf div [file join "$rep" "$fichier_aux$ext;$aux_polyNo"] $moy

    # Si le buffer de travail est le buffer Aud'ACE, on rafra�chit l'affichage
    if {$audace(bufNo) == $buf} {
#--- Debut modif Robert
      audace::autovisu $audace(visuNo)
#--- Fin modif Robert
      }

  } else {
    error $caption(divers,syntax,normalise)
    }
  }


######################################################
###############   Fonctions de s�ries  ###############
######################################################


proc suppr_serie {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {
    
    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]

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
    set index_corbeille [liste_index $nom_generique -rep "$rep" -ext $ext]
    foreach index $index_corbeille {file delete [file join "$rep" $nom_generique$index$ext]}
  } else {
    error $caption(divers,syntax,suppr_serie)
    }
  }


proc suppr_fin_serie {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]
    set index_fin [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]

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
    set index_cibles [lsort -integer [liste_index $nom_generique -rep "$rep" -ext $ext]]
    set index_fin [lsearch -regexp -exact $index_cibles $index_fin]
    if {$index_fin>=0} {
      set index_1 [expr $index_fin+1]
      set index_2 [expr [llength $index_cibles-1]]
      set index_corbeille [lrange $index_cibles $index_1 $index_2]
      foreach index $index_corbeille {file delete [file join "$rep" $nom_generique$index$ext]}
      }
  } else {
    error $caption(divers,syntax,suppr_fin_serie)
    }
  }


proc suppr_debut_serie {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]
    set index_debut [lindex $args 1]    

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]

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
    set index_cibles [lsort -integer [liste_index $nom_generique -rep "$rep" -ext $ext]]
    set index_debut [lsearch -exact $index_cibles $index_debut]
    if {$index_debut>=0} {
      set index_2 [expr $index_debut-1]
      set index_corbeille [lrange $index_cibles 0 $index_2]
      foreach index $index_corbeille {file delete [file join "$rep" $nom_generique$index$ext]}
      }
  } else {
    error $caption(divers,syntax,suppr_debut_serie)
    }
  }


proc renumerote {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]

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
    set index_serie [lsort [liste_index $nom_generique -rep "$rep" -ext $ext]]
    # Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
    if [catch [set index_serie [lsort -integer $index_serie]]] {}
    set k 1
    foreach oldindex $index_serie {
      if {[string compare $k $oldindex]!=0} {
        set oldfichier [file join "$rep" $nom_generique$oldindex$ext]
        set newfichier [file join "$rep" $nom_generique$k$ext]
        file rename $oldfichier $newfichier
        }
      incr k
      }
  } else {
    error $caption(divers,syntax,renumerote)
    }
  }


proc renomme {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 1 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set ancien_nom_generique [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des param�tres optionnels
    set params_optionnels [lindex $range_options 0]
    if {[llength $params_optionnels] >= 1} {
      set nouveau_nom_generique [lindex $params_optionnels 0]
    } else {
      set nouveau_nom_generique [lindex $args 0]
      }

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }

    # Proc�dure principale  
    # On ne continue que si l'on n'�crase pas la s�rie...
    if {[string compare $in_rep$ancien_nom_generique$in_ext $ex_rep$nouveau_nom_generique$ex_ext] != 0} {

      # On cherche si le nom de la s�rie courante existe d�j�.
      set index_newserie [liste_index $nouveau_nom_generique -rep $ex_rep -ext $ex_ext]
      set index_oldserie [lsort -integer [liste_index $ancien_nom_generique -rep $in_rep -ext $in_ext]]
      # 1er cas : le nom de la s�rie courante n'existe pas. On renomme sans se poser de questions
      if {[llength $index_newserie]==0} {
        # Deux cas sont possibles : 1) les deux s�ries ont le m�me type de compression, et alors pas de probl�me. 2) les deux s�ries n'ont pas le m�me type de compression, et alors il faut passer par un r�pertoire temporaire pour g�rer les compressions / d�compressions.

        if {[lindex [decomp $in_ext] 4] == [lindex [decomp $ex_ext] 4]} {
          foreach index $index_oldserie {
            file rename [file join $in_rep $ancien_nom_generique$index$in_ext] [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
            }
        } else {
          # Cr�ation d'un r�pertoire temporaire
          set rep_tmp [cree_sousrep -nom_base "tmp_renomme"]

          renomme $ancien_nom_generique $nouveau_nom_generique -in_rep $in_rep -ex_rep $rep_tmp -ext $in_ext
          switch [lindex [decomp $in_ext] 4] {
          "" {
            # Rien � faire (...)
            }
          ".gz" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext $in_ext] {
              gunzip [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
              }
            }
          ".bz2" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext $in_ext] {
              exec bunzip2 [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
              }
            }
          }

          switch [lindex [decomp $ex_ext] 4] {
          "" {
            # Rien � faire (...)
            }
          ".gz" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext [lindex [decomp $in_ext] 3]] {
              gzip [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
              }
            }
          ".bz2" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext [lindex [decomp $in_ext] 3]] {
              exec bzip2 [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
              }
            }
          }

          renomme $nouveau_nom_generique -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3][lindex [decomp $ex_ext] 4] -ex_rep $ex_rep

          # Suppression du r�pertoire temporaire (qui est vide car on vient d'en d�placer les fichiers qui y �taient temporairement).
          file delete [file join $rep_tmp]

          }
      } else {
        # 2nd cas : le nom de la s�rie courante existe d�j�. Il va donc falloir r�indexer
        # les deux s�ries et les concat�ner

        # On r�indexe la s�rie cible :
        renumerote $nouveau_nom_generique -rep $ex_rep -ext $ex_ext
        
        # On d�termine � quel index on continue la copie
        set index [expr [llength $index_newserie]+1]

        # Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
        if [catch [set index_oldserie [lsort -integer $index_oldserie]]] {}
        foreach k $index_oldserie {
          set oldfichier [file join $in_rep $ancien_nom_generique$k$in_ext]
          set newfichier [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
          file rename $oldfichier $newfichier
          incr index
          }
        }

      # Si la s�rie de destination est en lecture seule, on autorise l'utilisateur
      # en �criture
#--- Debut Modif Robert
      switch $::tcl_platform(os) {
#--- Fin Modif Robert
      "Linux" {
        foreach index [liste_index $nouveau_nom_generique -rep $ex_rep -ext $ex_ext] {
          if {[file writable [file join $ex_rep $nouveau_nom_generique$index$ex_ext]] == 0} {
            exec chmod u+w [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
            }
          }
        }
      default {
        }
      }
    }
  } else {
    error $caption(divers,syntax,renomme)
    }
  }


proc copie {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 1 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set ancien_nom_generique [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des param�tres optionnels
    set params_optionnels [lindex $range_options 0]
    if {[llength $params_optionnels] >= 1} {
      set nouveau_nom_generique [lindex $params_optionnels 0]
    } else {
      set nouveau_nom_generique [lindex $args 0]
      }

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      } 


    # Proc�dure principale  
    # On ne continue que si l'on n'�crase pas la s�rie...
    if {[string compare $in_rep$ancien_nom_generique$in_ext $ex_rep$nouveau_nom_generique$ex_ext] != 0} {

      # On cherche si le nom de la s�rie courante existe d�j�.
      set index_newserie [liste_index $nouveau_nom_generique -rep $ex_rep -ext $ex_ext]
      set index_oldserie [lsort -integer [liste_index $ancien_nom_generique -rep $in_rep -ext $in_ext]]
      # 1er cas : le nom de la s�rie courante n'existe pas. On renomme sans se poser de questions
      if {[llength $index_newserie]==0} {
        # Deux cas sont possibles : 1) les deux s�ries ont le m�me type de compression, et alors pas de probl�me. 2) les deux s�ries n'ont pas le m�me type de compression, et alors il faut passer par un r�pertoire temporaire pour g�rer les compressions / d�compressions.

        if {[lindex [decomp $in_ext] 4] == [lindex [decomp $ex_ext] 4]} {
          foreach index $index_oldserie {
            file copy [file join $in_rep $ancien_nom_generique$index$in_ext] [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
            }
        } else {
          # Cr�ation d'un r�pertoire temporaire
          set rep_tmp [cree_sousrep -nom_base "tmp_renomme"]

          copie $ancien_nom_generique $nouveau_nom_generique -in_rep $in_rep -ex_rep $rep_tmp -ext $in_ext
          switch [lindex [decomp $in_ext] 4] {
          "" {
            # Rien � faire (...)
            }
          ".gz" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext $in_ext] {
              gunzip [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
              }
            }
          ".bz2" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext $in_ext] {
              exec bunzip2 [file join $rep_tmp $nouveau_nom_generique$index$in_ext]
              }
            }
          }

          switch [lindex [decomp $ex_ext] 4] {
          "" {
            # Rien � faire (...)
            }
          ".gz" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext [lindex [decomp $in_ext] 3]] {
              gzip [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
              }
            }
          ".bz2" {
            foreach index [liste_index $nouveau_nom_generique -rep $rep_tmp -ext [lindex [decomp $in_ext] 3]] {
              exec bzip2 [file join $rep_tmp $nouveau_nom_generique$index[lindex [decomp $in_ext] 3]]
              }
            }
          }

          renomme $nouveau_nom_generique -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3][lindex [decomp $ex_ext] 4] -ex_ext $ex_ext

          # Suppression du r�pertoire temporaire (qui est vide car on vient d'en d�placer les fichiers qui y �taient temporairement).
          file delete [file join $rep_tmp]

          }
      } else {
        # 2nd cas : le nom de la s�rie courante existe d�j�. Il va donc falloir r�indexer
        # les deux s�ries et les concat�ner

        # On r�indexe la s�rie cible :
        renumerote $nouveau_nom_generique -rep $ex_rep -ext $ex_ext
        
        # On d�termine � quel index on continue la copie
        set index [expr [llength $index_newserie]+1]

        # Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
        if [catch [set index_oldserie [lsort -integer $index_oldserie]]] {}
        foreach k $index_oldserie {
          set oldfichier [file join $in_rep $ancien_nom_generique$k$in_ext]
          set newfichier [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
          file rename $oldfichier $newfichier
          incr index
          }
        }

      # Si la s�rie de destination est en lecture seule, on autorise l'utilisateur
      # en �criture
#--- Debut Modif Robert
      switch $::tcl_platform(os) {
#--- Fin Modif Robert
      "Linux" {
        foreach index [liste_index $nouveau_nom_generique -rep $ex_rep -ext $ex_ext] {
          if {[file writable [file join $ex_rep $nouveau_nom_generique$index$ex_ext]] == 0} {
            exec chmod u+w [file join $ex_rep $nouveau_nom_generique$index$ex_ext]
            }
          }
        }
      default {
        }
      }

    }
  } else {
    error $caption(divers,syntax,copie)
    }
  }


proc copie_partielle {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set ancien_nom_generique [lindex $args 0]
    set nouveau_nom_generique [lindex $args 1]
    set debut [lindex $args 2]
    set fin [lindex $args 3]

    # Configuration des options
    set options [lrange $args 4 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]

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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      } 

    # Proc�dure principale
    # On ne continue que si le vieux nom g�n�rique et le nouveau sont diff�rents
    if {$ancien_nom_generique!=$nouveau_nom_generique} {
      # On cherche si le nom de la s�rie courante existe d�j�.
      set index_newserie [liste_index $nouveau_nom_generique -rep $ex_rep -ext $ex_ext]
      set index_oldserie [lsort -integer [liste_index $ancien_nom_generique -rep $in_rep -ext $ex_ext]]
      # On ne garde de la vieille s�rie que les index que l'on veut copier
      set index_oldserie [lrange $index_oldserie [expr $debut-1] [expr $fin-1]]

      # Cr�ation d'un r�pertoire temporaire
      set rep_tmp [cree_sousrep -nom_base "tmp_renomme"]

      # On copie la sous-s�rie vers ce r�pertoire temporaire
      foreach index $index_oldserie {
        file copy [file join $in_rep $ancien_nom_generique$index$in_ext] [file join $rep_tmp $ancien_nom_generique$index$in_ext]
        }
      
      # On copie la sous-s�rie
      renomme $ancien_nom_generique $nouveau_nom_generique -in_rep $rep_tmp -ex_rep $ex_rep -in_ext $in_ext -ex_ext $ex_ext
     
      # Suppression du r�pertoire temporaire (qui est vide car on vient d'en d�placer les fichiers qui y �taient temporairement).
      file delete [file join $rep_tmp]

      }
  } else {
    error $caption(divers,syntax,copie_partielle)
    }
  }


proc serie_charge {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {
    
    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]

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
    set index_serie [liste_index $nom_generique -rep "$rep" -ext $ext]
    set index_buffers ""
    foreach index $index_serie {
      set num_buf [buf::create]
      lappend index_buffers $num_buf
      charge [file join "$rep" $nom_generique$index$ext] -buf $num_buf
      }
    return $index_buffers
  } else {
    error $caption(divers,syntax,serie_charge)
    }
  }


proc serie_fenetre {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 3 0 [list "" [list "-rep" "-ext" "-in_ext" "-ex_ext" "-in_rep" "-ex_rep" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      } 
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

    # Proc�dure principale
    # On r�cup�re la liste des index de la s�rie initiale...
    set liste_index [liste_index $in -rep $in_rep -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # Fen�trage des fichiers
    foreach index $liste_index {
      charge $in$index -buf $num_buf_tmp -rep $in_rep -ext $in_ext -polyNo $in_polyNo
      buf$num_buf_tmp window $coord
      sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep $ex_rep -ext $ex_ext
    }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp
  } else {
    error $caption(divers,syntax,serie_fenetre)
    }
  }


proc souris_fenetre {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      } 
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

    # Proc�dure principale
    serie_fenetre $in $ex $audace(box) -in_rep $in_rep -ex_rep $ex_rep -in_ext $in_ext -ex_ext $ex_ext -in_polyNo $in_polyNo -ex_polyNo $ex_polyNo
  } else {
    error $caption(divers,syntax,souris_fenetre)
    }
  }


proc serie_rot {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 5 0 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      } 
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

    # Proc�dure principale
    # On r�cup�re la liste des index de la s�rie initiale...	  
    set liste_index [liste_index $in -rep $in_rep -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # Rotation des fichiers
    foreach index $liste_index {
      charge $in$index -buf $num_buf_tmp -rep $in_rep -ext $in_ext -polyNo $in_polyNo
      buf$num_buf_tmp rot $x0 $y0 $angle
      sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep $ex_rep -ext $ex_ext
    }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp
  } else {
    error $caption(divers,syntax,serie_rot)
    }
  }


proc serie_trans {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 4 0 [list "" [list "-rep" "-in_rep" "-ex_rep" "-ext" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

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
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

    # Proc�dure principale
    # On r�cup�re la liste des index de la s�rie initiale...	  
    set liste_index [liste_index $in -rep $in_rep -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # Rotation des fichiers
    foreach index $liste_index {
      charge $in$index -buf $num_buf_tmp -rep $in_rep -ext $ext -polyNo $in_polyNo
      buf$num_buf_tmp imaseries "TRANS trans_x=$dx trans_y=$dy"
      sauve $ex$index -polyNo $ex_polyNo -buf $num_buf_tmp -rep $ex_rep -ext $ext
    }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp
  } else {
    error $caption(divers,syntax,serie_trans)
    }
  }


proc series_traligne {args} {
#--- Debut Modif Robert
  global audace caption conf script
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set liste_in [lindex $args 0]
    set ex [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]

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
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
    } else {
      set in_polyNo 1
      }

    # Proc�dure principale
    # On supprime d'�ventuels fichiers d�j� pr�sents de la s�rie-cible
    suppr_serie $ex -rep $ex_rep -ext $ext

    # La s�rie de r�f�rence est recopi�e sans modifications
    set serie_ref [lindex $liste_in 0]
    poly2serie $serie_ref $in_polyNo $ex -in_rep $in_rep -ex_rep $ex_rep -ext $ext
    # Tex au plus on la renum�rote.
    renumerote $ex -rep $ex_rep -ext $ext

    # On garde en m�moire le nom du dernier fichier de cette s�rie, qui servira de 
    # r�f�rence pour recaler la s�rie suivante
    set liste_index_ref [lsort -integer [liste_index $ex -rep $ex_rep -ext $ext]]
    set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
    set fichier_ref [file join $ex_rep $ex$index_ref$ext]

    # A pr�sent, on fait les transformations sur les autres s�ries :
    set series_amodif [lrange $liste_in 1 [expr [llength $liste_in]-1]]

    # Les fichiers temporaires sont stock�s dans un r�pertoire temporaire
    set rep_tmp [cree_sousrep -rep $ex_rep -nom_base "tmp_poly_series_traligne"]

    foreach serie $series_amodif {

      # On d�termine le cadre de r�f�rence ;       
      console::affiche_resultat "$caption(divers,series_trreg_cadre-ref) $serie\n"
      loadima "$fichier_ref"

      # Cr�ation de la fen�tre
      set script(series_traligne,attente) 0
      toplevel .series_traligne
      label .series_traligne.lab -text $caption(divers,tracebox)
      pack .series_traligne.lab -expand true
      button .series_traligne.but -command {set script(series_traligne,attente) 0} -text "ok"
      pack .series_traligne.but -expand true
    
      # On attend que l'utilisateur ait valid�
      vwait script(series_traligne,attente)

      # On supprime la fen�tre
      destroy .series_traligne

      # On enregistre les coordonn�es du cadre
      set cadre_ref $audace(box)

      console::affiche_resultat "$caption(divers,series_trreg_cadre-a-rec) $serie\n"
      # Chargement du premier fichier de la s�rie courante
      set liste_index [lsort -integer [liste_index $serie -rep $in_rep -ext $ext]]
      loadima [file join $in_rep "$serie[lindex $liste_index 0]$ext;$in_polyNo"]

      # Cr�ation de la fen�tre
      set script(series_traligne,attente) 0
      toplevel .series_traligne
      label .series_traligne.lab -text $caption(divers,tracebox)
      pack .series_traligne.lab -expand true
      button .series_traligne.but -command {set script(series_traligne,attente) 0} -text "ok"
      pack .series_traligne.but -expand true
      # On attend que l'utilisateur ait valid�
      vwait script(series_traligne,attente)
      # On supprime la fen�tre
      destroy .series_traligne
      # On enregistre les coordonn�es du cadre
      set cadre_amodif $audace(box)
      # Calcul des modifications de translation / rotation
      set modifs [calcul_trzaligne $cadre_ref $cadre_amodif]

      # Translation (en entiers pour �viter de d�grader la r�solution)
      console::affiche_resultat "$caption(divers,series_trreg_transl) $serie\n"
      serie_trans $serie tmp_trans_$serie [expr round([lindex $modifs 0])] [expr round([lindex $modifs 1])] -in_rep $in_rep -ex_rep $rep_tmp -ext $ext -in_polyNo $in_polyNo
      # Rotation
      console::affiche_resultat "$caption(divers,series_trreg_rot) $serie\n"
      serie_rot tmp_trans_$serie tmp_rot_$serie [lindex $modifs 2] [lindex $modifs 3] [lindex $modifs 4] -rep $rep_tmp -ext $ext
      # Suppression de la s�rie temporaire de translation (si on n'avait pas cette s�rie temporaire, 
      # l'auto-�crasement bugge)
      suppr_serie tmp_trans_$serie -rep $rep_tmp -ext $ext
      # On renomme vers la s�rie de destination
      renomme tmp_rot_$serie $ex -in_rep $rep_tmp -ex_rep $ex_rep -ext $ext

      # On garde en m�moire le nom du dernier fichier de cette s�rie, qui servira de 
      # r�f�rence pour recaler la s�rie suivante
      set liste_index_ref [lsort -integer [liste_index $ex -rep $ex_rep -ext $ext]]
      set index_ref [lindex $liste_index_ref [expr [llength $liste_index_ref]-1]]
      set fichier_ref [file join $ex_rep $ex$index_ref$ext]
      }

    # Suppression du r�pertoire temporaire
    file delete $rep_tmp
  } else {
    error $caption(divers,syntax,series_traligne)
    }
  }


proc serie_sauvejpeg {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-ex_name" "-qualitejpeg" "-seuils_type" "-rep" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-in_polyNo"] [list "-seuils_haut_bas" "-histo_haut_bas"]]] =="1"} {

    # Configuration des param�tres obligatoires
    set in [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set ex_name_index [lsearch -regexp $options_1param "-ex_name"]
    set qualitejpeg_index [lsearch -regexp $options_1param "-qualitejpeg"]
    set seuils_type_index [lsearch -regexp $options_1param "-seuils_type"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]

    if {$ex_name_index>=0} {
      set ex_name [lindex [lindex $options_1param $ex_name_index] 1]
    } else {
      set ex_name $in
      }
    if {$qualitejpeg_index>=0} {
      set qualitejpeg [lindex [lindex $options_1param $qualitejpeg_index] 1]
    } else {
      set qualitejpeg $conf(jpegquality,defaut)
      }
    if {$seuils_type_index>=0} {
      set seuils_type [lindex [lindex $options_1param $seuils_type_index] 1]
    } else {
      set seuils_type "loadima"
      }
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
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
    } else {
      set ex_ext ".jpg"
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
    } else {
      set in_polyNo 1
      }

    # Configuration des options � 2 param�tres
    set options_2param [lindex $range_options 3]

    set seuils_haut_bas_index [lsearch -regexp $options_2param "-seuils_haut_bas"]
    set histo_haut_bas_index [lsearch -regexp $options_2param "-histo_haut_bas"]

    if {$seuils_haut_bas_index>=0} {
      set seuils_type "fixe"
      set seuil_haut [lindex [lindex $options_2param $seuils_haut_bas_index] 1]
      set seuil_bas [lindex [lindex $options_2param $seuils_haut_bas_index] 2]
      }
    if {$histo_haut_bas_index>=0} {
      set seuils_type "histoauto"
      set histo_haut [lindex [lindex $options_2param $histo_haut_bas_index] 1]
      set histo_bas [lindex [lindex $options_2param $histo_haut_bas_index] 2]
      }

    # Proc�dure principale
    # On r�cup�re la liste des index de la s�rie initiale...	  
    set liste_index [liste_index $in -rep $in_rep -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # Sauvegarde des fichiers
    foreach index $liste_index {
      buf$num_buf_tmp load [file join $in_rep "$in$index$in_ext;$in_polyNo"]
      # Si on n'est pas en seuillage fixe, il faut calculer les seuils adapt�s.
      if {$seuils_type!="fixe"} {
        switch -exact -- $seuils_type {
        loadima {
          set list_seuils [lrange [buf$num_buf_tmp stat] 0 1]
          }
        autovisu {
          set list_seuils [lrange [buf$num_buf_tmp autocuts] 0 1]
          }
        iris {
          set moyenne [lindex [buf$num_buf_tmp stat] 4]
          set list_seuils [list [expr $moyenne+1000] [expr $moyenne-200]]
          }
        histoauto {
          buf$num_buf_tmp imaseries "CUTS lofrac=[expr 0.01 * $histo_bas] hifrac=[expr 0.01 * $histo_haut]"
          set list_seuils [list [lindex [buf$num_buf_tmp getkwd MIPS-HI] 1] [lindex [buf$num_buf_tmp getkwd MIPS-LO] 1]]
          }
        }
        set seuil_haut [lindex $list_seuils 0]
        set seuil_bas [lindex $list_seuils 1]
        }
      
      buf$num_buf_tmp savejpeg [file join $ex_rep $ex_name$index$ex_ext] $qualitejpeg $seuil_bas $seuil_haut
      }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp
  } else {
    error $caption(divers,syntax,serie_sauvejpeg)
    }
  }


proc mediane {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-buf" "-rep" "-ext" "-polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set serie [lindex $args 0]

    # Configuration des options
    set options [lrange $args 1 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set buf_index [lsearch -regexp $options_1param "-buf"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]

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
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set ext $conf(extension,defaut)
    } else {
      set ext $conf(extension,defaut).gz
      }
    if {$polyNo_index>=0} {
      set aux_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set aux_polyNo 1
      }

    # Proc�dure principale

    # On v�rifie que la s�rie de d�part existe bien
    if {[serie_existe $serie -rep "$rep" -ext $ext] == 0} {
      return
      }

    # Cr�ation d'un r�pertoire temporaire
    set rep_tmp [cree_sousrep -nom_base "tmp_mediane"]

    # Cr�ation sur le disque de l'image m�diane
    set nb_images [llength [liste_index $serie -rep "$rep" -ext $ext]]
    # S�rie "bien" num�rot�e
    if {[numerotation_usuelle $serie -rep "$rep" -ext $ext] == 1} {
      # Cas d'une s�rie compress�e .bz2
      if {[file extension $ext] == ".bz2"} {
        copie $serie $serie -in_rep "$rep" -ex_rep $rep_tmp -ext $ext
        foreach fichier [glob [file join $rep_tmp ${serie}*$ext]] {
          exec chmod u+w $fichier
          exec bunzip2 $fichier
          }
        ttscript2 "IMA/STACK \"$rep_tmp\" $serie 1 $nb_images [file rootname $ext] \"$rep_tmp\" mediane . [file rootname $ext] MED"
        suppr_serie $serie -rep $rep_tmp -ext [file rootname $ext]
        exec bzip2 [file join $rep_tmp mediane[file rootname $ext]]
      } else {
        ttscript2 "IMA/STACK \"$rep\" $serie 1 $nb_images $ext \"$rep_tmp\" mediane . $ext MED"
        }
    # S�rie "mal" num�rot�e
    } else {
      copie $serie $serie -in_rep "$rep" -ex_rep $rep_tmp -ext $ext
      # Cas d'une s�rie compress�e .bz2
      if {[file extension $ext] == ".bz2"} {
        foreach fichier [glob [file join $rep_tmp ${serie}*$ext]] {
          exec chmod a+w $fichier
          }
        renumerote $serie -rep "$rep_tmp" -ext $ext
        foreach fichier [glob [file join $rep_tmp ${serie}*$ext]] {
          exec bunzip2 $fichier
          }
        exec bunzip2 [file join $rep_tmp ${serie}*$ext]
        ttscript2 "IMA/STACK \"$rep_tmp\" $serie 1 $nb_images [file rootname $ext] \"$rep_tmp\" mediane . [file rootname $ext] MED"
        suppr_serie $serie -rep $rep_tmp -ext [file rootname $ext]
        exec bzip2 [file join $rep_tmp mediane[file rootname $ext]]
      } else {
        renumerote $serie -rep "$rep" -ext $ext
        ttscript2 "IMA/STACK \"$rep_tmp\" $serie 1 $nb_images $ext \"$rep_tmp\" mediane . $ext MED"
        suppr_serie $serie -rep $rep_tmp -ext $ext
        }
      }

    # Chargement de l'image dans le buffer d�sir�
    charge mediane -rep $rep_tmp -ext $ext -buf $buf

    # Suppression de fichier / r�pertoire temporaire
#    file delete [file join $rep_tmp mediane$ext]
#    file delete [file join $rep_tmp]

  } else {
    error $caption(divers,syntax,mediane)

    }
  }


proc serie_soustrait {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo" "-buf"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in_serie [lindex $args 0]
    set ex_serie [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
    set ex_polyNo_index [lsearch -regexp $options_1param "-ex_polyNo"]
    set buf_index [lsearch -regexp $options_1param "-buf"]

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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }
    if {$buf_index>=0} {
      set buf [lindex [lindex $options_1param $buf_index] 1]
    } else {
      set buf $audace(bufNo)
      }

    # Proc�dure principale

    # On v�rifie que la s�rie de d�part existe bien
    if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
      return
      }

    # Cr�ation d'un r�pertoire temporaire
    set rep_tmp [cree_sousrep -nom_base "tmp_serie_soustrait"]

    # On enregistre sur le disque l'image � soustraire
    sauve soustrait -buf $buf -rep "$rep_tmp" -ext [lindex [decomp $ex_ext] 3]

    # On r�cup�re la liste des index de la s�rie initiale...	  
    set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # Soustraction
    foreach index $liste_index {
      charge $in_serie$index -rep $in_rep -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
      soustrait soustrait -buf $num_buf_tmp -rep $rep_tmp -ext [lindex [decomp $ex_ext] 3]
      sauve  $ex_serie$index -rep $ex_rep -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp
      }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp

    # Suppression de fichier / r�pertoire temporaire
    file delete [file join $rep_tmp soustrait$ex_ext]
    file delete [file join $rep_tmp]

  } else {
    error $caption(divers,syntax,serie_soustrait)

    }
  }


proc serie_normalise {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo" "-buf"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in_serie [lindex $args 0]
    set ex_serie [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
    set ex_polyNo_index [lsearch -regexp $options_1param "-ex_polyNo"]
    set buf_index [lsearch -regexp $options_1param "-buf"]

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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }
    if {$buf_index>=0} {
      set buf [lindex [lindex $options_1param $buf_index] 1]
    } else {
      set buf $audace(bufNo)
      }

    # Proc�dure principale

    # On v�rifie que la s�rie de d�part existe bien
    if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
      return
      }

    # Cr�ation d'un r�pertoire temporaire
    set rep_tmp [cree_sousrep -nom_base "tmp_serie_soustrait"]

    # On enregistre sur le disque l'image � soustrairepar laquelle normaliser
    sauve normalise -buf $buf -rep "$rep_tmp" -ext [lindex [decomp $ex_ext] 3]

    # On r�cup�re la liste des index de la s�rie initiale...	  
    set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # Soustraction
    foreach index $liste_index {
      charge $in_serie$index -rep $in_rep -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
      normalise normalise -buf $num_buf_tmp -rep $rep_tmp -ext $ex_ext
      sauve  $ex_serie$index -rep $ex_rep -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp
      }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp

    # Suppression de fichier / r�pertoire temporaire
    file delete [file join $rep_tmp normalise$ex_ext]
    file delete [file join $rep_tmp]

  } else {
    error $caption(divers,syntax,serie_normalise)

    }
  }


proc normalise_gain {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_rep" "-ex_rep" "-in_ext" "-ex_ext" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in_serie [lindex $args 0]
    set ex_serie [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

    # Proc�dure principale

    # On v�rifie que la s�rie de d�part existe bien
    if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
      return
      }

    # On r�cup�re la liste des index de la s�rie initiale...	  
    set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    # On enregistre le niveau de fond de ciel de la premi�re image
    set premier_index [lindex $liste_index 0]
    charge $in_serie$premier_index -rep $in_rep -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
    set stats [buf$num_buf_tmp stat]
    set gain_ref [lindex $stats 6]
    sauve $ex_serie$premier_index -rep $ex_rep -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp

    # Normalisation du gain de chaque image en se calant sur la premi�re
    foreach index [lrange $liste_index 1 [expr [llength $liste_index]-1]] {
      charge $in_serie$index -rep $in_rep -ext $in_ext -polyNo $in_polyNo -buf $num_buf_tmp
      set stats [buf$num_buf_tmp stat]
      set gain_encours [lindex $stats 6]
      buf$num_buf_tmp mult [expr 1.0*$gain_ref/$gain_encours]
      sauve $ex_serie$index -rep $ex_rep -ext $ex_ext -polyNo $ex_polyNo -buf $num_buf_tmp
      }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp

  } else {
    error $caption(divers,syntax,normalise_gain)

    }
  }


proc aligne {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 2 0 [list "" [list "-rep" "-ext" "-in_ext" "-ex_ext" "-in_rep" "-ex_rep" "-polyNo" "-in_polyNo" "-ex_polyNo"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set in_serie [lindex $args 0]
    set ex_serie [lindex $args 1]

    # Configuration des options
    set options [lrange $args 2 [expr [llength $args]-1]]
    set range_options [range_options $options]

    # Configuration des options � 1 param�tre
    set options_1param [lindex $range_options 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]
    set in_rep_index [lsearch -regexp $options_1param "-in_rep"]
    set ex_rep_index [lsearch -regexp $options_1param "-ex_rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]
    set in_ext_index [lsearch -regexp $options_1param "-in_ext"]
    set ex_ext_index [lsearch -regexp $options_1param "-ex_ext"]
    set polyNo_index [lsearch -regexp $options_1param "-polyNo"]
    set in_polyNo_index [lsearch -regexp $options_1param "-in_polyNo"]
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
      set in_ext [lindex [lindex $options_1param $ext_index] 1]
      set ex_ext [lindex [lindex $options_1param $ext_index] 1]
#--- Debut Modif Robert
    } elseif {$conf(fichier,compres)==0} {
#--- Fin Modif Robert
      set in_ext $conf(extension,defaut)
      set ex_ext $conf(extension,defaut)
    } else {
      set in_ext $conf(extension,defaut).gz
      set ex_ext $conf(extension,defaut).gz
      }
    if {$in_ext_index>=0} {
      set in_ext [lindex [lindex $options_1param $in_ext_index] 1]
      }
    if {$ex_ext_index>=0} {
      set ex_ext [lindex [lindex $options_1param $ex_ext_index] 1]
      }
    if {$polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
      set ex_polyNo [lindex [lindex $options_1param $polyNo_index] 1]
    } else {
      set in_polyNo 1
      set ex_polyNo 1
      }
    if {$in_polyNo_index>=0} {
      set in_polyNo [lindex [lindex $options_1param $in_polyNo_index] 1]
      }
    if {$ex_polyNo_index>=0} {
      set ex_polyNo [lindex [lindex $options_1param $ex_polyNo_index] 1]
      }

    # Proc�dure principale

    # On v�rifie que la s�rie de d�part existe bien
    if {[serie_existe $in_serie -rep "$in_rep" -ext $in_ext] == 0} {
      return
      }

    # On r�cup�re la liste des index de la s�rie initiale...
    set liste_index [liste_index $in_serie -rep "$in_rep" -ext $in_ext]

    # Cr�ation d'un r�pertoire temporaire
    set rep_tmp [cree_sousrep -nom_base "tmp_aligne" -rep $in_rep]

    # En cas de compression .bz2 : on d�compresse dans le r�pertoire temporaire
    if {[lindex [decomp $in_ext] 4] ==".bz2" } {
      copie $in_serie tmp_ima_ -in_rep $in_rep -ex_rep $rep_tmp -in_ext $in_ext -ex_ext [lindex [decomp $in_ext] 3]
      # On sauve dans le r�pertoire temporaire les images associ�es chacune � un catalogue d'objet qu'elles contiennent
      foreach index $liste_index {
        ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_ $index $index [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima_ $index [lindex [decomp $in_ext] 3] STAT objefile"
        }
    } else {
      # On sauve dans le r�pertoire temporaire les images associ�es chacune � un catalogue d'objet qu'elles contiennent
      foreach index $liste_index {
        ttscript2 "IMA/SERIES \"$in_rep\" $in_serie $index $index $in_ext \"$rep_tmp\" tmp_ima_ $index [lindex [decomp $in_ext] 3] STAT objefile"
        }
      }

    # Cr�ation du buffer temporaire
    set num_buf_tmp [buf::create]

    if {[numerotation_usuelle $in_serie -rep $in_rep -ext $in_ext] == "1"} {
      # Registration
      ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_ 1 [llength $liste_index] [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima2_ 1 [lindex [decomp $ex_ext] 3] REGISTER translate=only"

      # Fen�trage des images
      set depl_x ""
      set depl_y ""
      foreach index $liste_index {
        charge tmp_ima2_$index -ext [lindex [decomp $ex_ext] 3] -rep $rep_tmp -buf $num_buf_tmp
        set TT_num 1
        while {[lindex [buf$num_buf_tmp getkwd TT${TT_num}] 1] != "IMA/SERIES REGISTER"} {
          incr TT_num
          }
        lappend depl_x [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+1]] 1] 2]
        lappend depl_y [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+2]] 1] 2]
        }
      set naxis1 [lindex [buf$num_buf_tmp getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$num_buf_tmp getkwd NAXIS2] 1]
      serie_fenetre tmp_ima2_ tmp_ima2_ [list [expr -round([lmin $depl_x])] [expr -round([lmin $depl_y])] [expr $naxis1 - round([lmax $depl_x])] [expr $naxis2 - round([lmax $depl_y])]] -ext [lindex [decomp $ex_ext] 3] -rep $rep_tmp

      # D�placement des fichiers
      renomme tmp_ima2_ $ex_serie -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3] -ex_ext $ex_ext

    } else {

      renumerote tmp_ima_ -rep $rep_tmp -ext [lindex [decomp $in_ext] 3]

      # Registration
      ttscript2 "IMA/SERIES \"$rep_tmp\" tmp_ima_ 1 [llength $liste_index] [lindex [decomp $in_ext] 3] \"$rep_tmp\" tmp_ima2_ 1 [lindex [decomp $in_ext] 3] REGISTER translate=only"

      # Fen�trage des images
      set depl_x ""
      set depl_y ""
      for {set index 1} {$index <= [llength $liste_index]} {incr index} {
        charge tmp_ima2_$index -ext [lindex [decomp $ex_ext] 3] -rep $rep_tmp -buf $num_buf_tmp
        set TT_num 1
        while {[lindex [buf$num_buf_tmp getkwd TT${TT_num}] 1] != "IMA/SERIES REGISTER"} {
          incr TT_num
          }
        lappend depl_x [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+1]] 1] 2]
        lappend depl_y [lindex [lindex [buf$num_buf_tmp getkwd TT[expr ${TT_num}+2]] 1] 2]
        }
      set naxis1 [lindex [buf$num_buf_tmp getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$num_buf_tmp getkwd NAXIS2] 1]
      serie_fenetre tmp_ima2_ tmp_ima2_ [list [expr -round([lmin $depl_x])] [expr -round([lmin $depl_y])] [expr $naxis1 - round([lmax $depl_x])] [expr $naxis2 - round([lmax $depl_y])]] -ext [lindex [decomp $ex_ext] 3] -rep $rep_tmp

      # D�placement des fichiers
      renomme tmp_ima2_ $ex_serie -in_rep $rep_tmp -ex_rep $ex_rep -in_ext [lindex [decomp $in_ext] 3] -ex_ext $ex_ext
      }

    # Suppression du buffer temporaire
    buf::delete $num_buf_tmp

    # Suppression de fichier / r�pertoire temporaire
    suppr_serie tmp_ima_ -rep $rep_tmp -ext [lindex [decomp $in_ext] 3]
    file delete $rep_tmp

  } else {
    error $caption(divers,syntax,aligne)

    }
  }


######################################################
###############   Fonctions avanc�es   ###############
######################################################


proc TestEntier {args} {
  global caption
  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set valeur [lindex $args 0]

    # Proc�dure principale
    set test 1
    for {set i 0} {$i < [string length $valeur]} {incr i} {
      set a [string index $valeur $i]
      if {![string match {[0-9]} $a]} {
        set test 0
        }
      }
    if {$valeur==""} {set test 0}
    return $test
  } else {
    error $caption(divers,syntax,TestEntier)
    }
  }


proc TestReel {args} {
  global caption
  if {[syntaxe_args $args 1 0 ""]=="1"} {
    # Configuration des param�tres obligatoires
    set valeur [lindex $args 0]

    # Proc�dure principale
  set test 1
  for { set i 0 } { $i < [string length $valeur] } { incr i } {
    set a [string index $valeur $i]
    if { ![string match {[0-9.]} $a] } {
      set test 0
      }
    }
    return $test
  } else {
    error $caption(divers,syntax,TestReel)
    }
  }


proc dernier_est_chiffre {args} {
  global caption

  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set chaine [lindex $args 0]

    # Proc�dure principale
    # La proc�dure retourne "1" si le dernier caract�re du mot est un chiffre, "0" sinon.
    set caractere [string index $chaine [expr [string length $chaine]-1]]
    switch -exact -- $caractere {
    0 {return 1}
    1 {return 1}
    2 {return 1}
    3 {return 1}
    4 {return 1}
    5 {return 1}
    6 {return 1}
    7 {return 1}
    8 {return 1}
    9 {return 1}
    default {return 0}
    }
  } else {
    error $caption(divers,syntax,dernier_est_chiffre)
    }
  }


proc nom_valide {args} {
  global caption

  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set chaine [lindex $args 0]

    # Proc�dure principale
    # La proc�dure retourne "0" si le mot comporte des caract�res invalides, "1" sinon.
    set valide "1"
    set k 0
    set kmax [string length $chaine]
    while {$k<$kmax} {
      set caractere [string index $chaine $k]
      switch -exact -- $caractere {
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      � {
        return 0
        break
        }
      default {
        incr k
        }
      }
      }
    return 1
  } else {
    error $caption(divers,syntax,nom_valide)
    }
  }


proc suppr_accents {args} {
  global caption

  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set chaine [lindex $args 0]

    # Proc�dure principale
    # La proc�dure retourne la liste de caract�res nettoy�e de tout accentuation.

    if {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "a"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "a"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "e"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "e"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "e"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "i"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "o"]]
    } elseif {[string first "�" $chaine]>=0} {
      set index [string first "�" $chaine]
      return [suppr_accents [string replace $chaine $index $index "u"]]
    } else {
      return $chaine
      }
  } else {
    error $caption(divers,syntax,suppr_accents)
    }
  }


proc decomp {args} {
  global audace caption conf

  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set filename [lindex $args 0]

    # Proc�dure principale
    # A tout nom de fichier (avec ou sans le chemin) cette proc�dure renvoie [dossier nom_generique index extension compression]
    set dossier [file dirname $filename]
    # On ne garde que le nom du fichier
    set filename [file tail $filename]
    # On d�termine quelle est l'extension du fichier
    set ext [file extension $filename]
    switch $ext {
    ".gz" {
      # Cas o� le fichier est compress�
      set gz ".gz"
      # On tronque de l'extension .gz
      set filename [file rootname $filename]
      # On enregistre l'extension
      set extension [file extension $filename]
      } 
    ".bz2" {
      # Cas o� le fichier est compress�
      set gz ".bz2"
      # On tronque de l'extension .bz2
      set filename [file rootname $filename]
      # On enregistre l'extension
      set extension [file extension $filename]
      } 
    default {
      # Cas o� le fichier n'est pas compress�
      set gz ""
      set extension $ext
      }
    }

    set nom_fichier [file rootname $filename]
    # On s�pare � pr�sent le nom g�n�rique et l'index
    set index ""
    set continue [dernier_est_chiffre $nom_fichier]
    while {$continue==1} {
      set index [string index $nom_fichier [expr [string length $nom_fichier]-1]]$index
      set nom_fichier [string range $nom_fichier 0 [expr [string length $nom_fichier]-2]]
      set continue [dernier_est_chiffre $nom_fichier]
    }
    return [list $dossier $nom_fichier $index $extension $gz]
  } else {
    error $caption(divers,syntax,decomp)
    }
  }


proc liste_index {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]

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

    # NB : On renvoie les index des fichiers dont le nom g�n�rique correspond � {nom_generique}
    # Sous-entendu : on s'occupe d'une s�rie index�e...
    # On fait une premi�re s�lection
    set panier [glob -nocomplain [file join "$rep" $nom_generique*$ext]]
    # Attention ! Dans la liste r�f�renc�e "panier" on a trop de fichiers ! En effet on a en plus :
    # 1) Un �ventuel fichier nom_generique$ext (non index�) 
    # 2) Les fichiers dont le nom g�n�rique commence pareil mais est plus long
    # 3) Et m�me : des fichiers dont le nom g�n�rique commence pareil mais comprend des majuscules !!!!!!!!!!!!

    # On solutionne le point n�1 :  
    # Pour que la fonction lsearch ne se m�lange pas les crayons entre les extensions .FIT et .fit (par exemple)
    # on cr��e une nouvelle liste o� les noms de fichiers sont tronqu�s de l'extension

    set new_panier ""
    foreach name $panier {
      lappend new_panier [string range $name 0 [expr [string length $name]-[string length $ext]-1]]
      }
    set no_index [lsearch -exact $new_panier [file join "$rep" $nom_generique]]
    if {$no_index>=0} {
      set panier [concat [lrange $panier 0 [expr $no_index-1]] [lrange $panier [expr $no_index+1] [expr [llength $panier]-1]]]
      }

    # Pour �viter des probl�mes dans les cas o� le nom g�n�rique se termine par un chiffre, on rajoute dans ce cas 
    # un "_" dans tous les noms de fichiers
    if {[dernier_est_chiffre $nom_generique]=="1"} {
      set new_panier ""
      set borneinter [string length [file join "$rep" $nom_generique]]
      foreach name $panier {
        lappend new_panier [string range $name 0 [expr $borneinter-1]]_[string range $name $borneinter [expr [string length $name]-1]]
        }
      set panier $new_panier
      set nom_generique ${nom_generique}_
      }

    # On termine en r�solvant les points 2 et 3 :
    set index_list ""
    foreach fichier $panier {
      set decomp [decomp $fichier]
      if {[lindex $decomp 1]==$nom_generique} {
        lappend index_list [lindex $decomp 2]
        }
      }
    return $index_list
  } else {
    error $caption(divers,syntax,liste_index)
    }
  }


proc liste_series {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 0 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires

    # Configuration des options
    set options $args

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
 
    # On r�cup�re la liste des fichiers du r�pertoire courant
    set panier [glob -nocomplain [file join "$rep" *$ext]]

    # On parcours cette liste en enregistrant chaque nouvelle s�rie 
    set liste_series ""

    foreach fichier $panier {
      set decomp [decomp $fichier]
      if {[lsearch $liste_series [lindex $decomp 1]]==-1} {
        lappend liste_series [lindex $decomp 1]
        }
      }
    return $liste_series
  } else {
    error $caption(divers,syntax,liste_series)
    }
  }


proc liste_sousreps {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 0 0 [list "" [list "-rep"]]]=="1"} {

    # Configuration des param�tres obligatoires

    # Configuration des options
    set options $args

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set rep_index [lsearch -regexp $options_1param "-rep"]

    if {$rep_index>=0} {
      set rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set rep $audace(rep_images)
      }
       
    # Proc�dure principale  

    # On r�cup�re la liste des fichiers du r�pertoire courant
    set panier [glob -nocomplain [file join "$rep" *]]

    # On parcours cette liste en enregistrant chaque nouvelle s�rie 
    set liste_repertoires ""

    foreach entree $panier {
      if {[file isdirectory $entree]==1} {
        lappend liste_repertoires [file tail $entree]
        }
      }
    return $liste_repertoires
  } else {
    error $caption(divers,syntax,liste_sousreps)
    }
  }


proc serie_existe {args} {
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]

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
    if {[liste_index $nom_generique -rep "$rep" -ext $ext] == ""} {
      console::affiche_resultat "$caption(divers,erreur,serie_existe) [file join $rep $nom_generique*$ext]\n"
      return "0"
    } else {
      return "1"
      }  
  } else {
    error $caption(divers,syntax,serie_existe)
    }
  }


proc numerotation_usuelle {args} { 
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set nom_generique [lindex $args 0]

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
    # On r�cup�re les index
    set liste [liste_index $nom_generique -rep "$rep" -ext $ext]
    # On essaie de les ranger par ordre croissant
    catch [set liste [lsort -integer $liste]] {}
    
    set k 1
    foreach index $liste {
      if {$k!=$index} {
        return 0        
        break
        }
      incr k
      }
    return 1
  } else {
    error $caption(divers,syntax,numerotation_usuelle)
    }
  }


proc compare_index_series {args} { 
#--- Debut Modif Robert
  global audace caption conf
#--- Fin Modif Robert

  if {[syntaxe_args $args 1 0 [list "" [list "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires
    set liste_series [lindex $args 0]

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
    set nb_series [llength $liste_series]
    # On ne continue que si au moins deux noms de s�ries ont �t� indiqu�s
    if {$nb_series<2} {
      return 0
    } else {
      set sortie 1
      set liste_index_ref [lsort [liste_index [lindex $liste_series 0] -rep "$rep" -ext $ext]]
      foreach serie [lrange $liste_series 1 [expr $nb_series-1]] {
        if {$liste_index_ref != [lsort [liste_index $serie -rep "$rep" -ext $ext]]} {
          set sortie 0
          break
          }
        }
      return $sortie
      }
  } else {
    error $caption(divers,syntax,compare_index_series)
    }
  }


proc cree_sousrep {args} {
  global audace caption

  if {[syntaxe_args $args 0 0 [list "" [list "-nom_base" "-rep"]]]=="1"} {

    # Configuration des param�tres obligatoires

    # Configuration des options
    set options $args

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set nom_base_index [lsearch -regexp $options_1param "-nom_base"]
    set rep_index [lsearch -regexp $options_1param "-rep"]

    if {$nom_base_index>=0} {
      set nom_base [lindex [lindex $options_1param $nom_base_index] 1]
    } else {
      set nom_base "tmp"
      }
    if {$rep_index>=0} {
      set rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set rep $audace(rep_images)
      }

    # Si le r�pertoire indiqu� est prot�g� en �criture :
    if {[file writable $rep] == 0} {
#--- Debut Modif Robert
      switch $::tcl_platform(os) {
#--- Fin Modif Robert
      "Linux" {
        # Pour linux : le sous-r�pertoire est cr�� dans /tmp/.audela
        set rep [file join /tmp .audela]
        }
      default {
        # Sous les autres OS, pas de solution pour l'instant !
        }
      }
    }

    # Proc�dure principale
    set subdir [file join "$rep" $nom_base]
    set k 0
    while {[file exist $subdir]=="1"} {	
      incr k
      set subdir [file join "$rep" ${nom_base}_$k]
      }  
    file mkdir $subdir
    return $subdir
  } else {
    error $caption(divers,syntax,cree_sousrep)
    }
  }


proc cree_fichier {args} {
  global audace caption

  if {[syntaxe_args $args 0 0 [list "" [list "-nom_base" "-rep" "-ext"]]]=="1"} {

    # Configuration des param�tres obligatoires

    # Configuration des options
    set options $args

    # Configuration des options � 1 param�tre
    set options_1param [lindex [range_options $options] 2]

    set nom_base_index [lsearch -regexp $options_1param "-nom_base"]
    set rep_index [lsearch -regexp $options_1param "-rep"]
    set ext_index [lsearch -regexp $options_1param "-ext"]

    if {$nom_base_index>=0} {
      set nom_base [lindex [lindex $options_1param $nom_base_index] 1]
    } else {
      set nom_base "tmp"
      }
    if {$rep_index>=0} {
      set rep [lindex [lindex $options_1param $rep_index] 1]
    } else {
      set rep $audace(rep_images)
      }
    if {$ext_index>=0} {
      set ext [lindex [lindex $options_1param $ext_index] 1]
    } else {
      set ext ""
      }

    # Si le r�pertoire de destination n'existe pas, on le cr�e.
    if {[file exist $rep]=="0"} {
      file mkdir $rep
      }

    # Cas o� le r�pertoire indiqu� est prot�g� en �criture :
    if {[file writable $rep] == 0} {
#--- Debut Modif Robert
    switch $::tcl_platform(os) {
#--- Fin Modif Robert
    "Linux"} {
      # Pour linux : le fichier est cr�� dans /tmp/.audela
      if {[file exist [file join /tmp .audela]]=="0"} {
        file mkdir [file join /tmp .audela]
        exec "chmod a+w [file join /tmp .audela]"
        }
      set rep [file join /tmp .audela]
      }
    default {
      # Sous les autres OS, pas de solution pour l'instant !
      }
    }

    # Proc�dure principale
    set fichier [file join "$rep" $nom_base$ext]
    set k 0
    while {[file exist $fichier]=="1"} {	
      incr k
      set fichier [file join "$rep" ${nom_base}_$k$ext]
      }  
    set f [open $fichier w]
    close $f
    return $fichier
  } else {
    error $caption(divers,syntax,cree_fichier)
    }
  }


proc syntaxe_args {args} {
  global caption

  if {[llength $args]==4} {

    # Configuration des param�tres obligatoires
    set list_args_averifier [lindex $args 0]
    set nb_args_obligatoires [lindex $args 1]
    set nb_args_optionnels [lindex $args 2]
    set list_options_valides [lindex $args 3]

    # Proc�dure principale
    # On v�rifie que l'on a suffisamment d'arguments � se mettre sous la dent
    if {[llength $list_args_averifier]<$nb_args_obligatoires} {
      return 0
      break
      }
    # On d�termine le nombre d'arguments optionnels
    set args_optionnels_en_cours 0
    while {$args_optionnels_en_cours<$nb_args_optionnels} {
      if {[string index [lindex $list_args_averifier [expr $nb_args_obligatoires+$args_optionnels_en_cours]] 0]=="-"} {
        break
      } else {
        incr args_optionnels_en_cours
        }
      }
    # On passe � pr�sent aux options
    set list_opts_averifier [lrange $list_args_averifier [expr $nb_args_obligatoires+$args_optionnels_en_cours] [expr [llength $list_args_averifier]-1]]
    set index 0
    set ind_max [expr [llength $list_opts_averifier]-1]
    while {$index<=$ind_max} {
      # On v�rifie que l'on pointe sur une option qui existe bien
      set ou_est_loption [lsearch -regexp $list_options_valides [lindex $list_opts_averifier $index]]
      if {$ou_est_loption == "-1"} {
        console::affiche_resultat "$caption(divers,invalide_opt)[lindex $list_opts_averifier $index]\n"
        return 0
        break
      } else {
        # Donc l'option existe.
        # On v�rifie que :
        # 1) la liste des options � v�rifier est assez longue pour contenir tous les param�tres de l'option
        if {[expr $index+$ou_est_loption]>$ind_max} {
          console::affiche_resultat "$caption(divers,oubli_param_opt)[lindex $list_opts_averifier $index]\n"
          return 0
          break
        # 2) parmi les param�tres de l'option, il n'y a pas un truc qui commence par un "-" et qui serait donc une option
        } else {
          set k 0
          while {$k<=$ou_est_loption} {
            if {[string index [lindex $list_opts_averifier [expr $index+1]] 0]=="-"} {
              console::affiche_resultat "$caption(divers,oubli_param_opt)[lindex $list_opts_averifier $index]\n"
              return 0
              break
              }
            incr k
            }
          # Si on en est l�, c'est que c'est bon. On incr�mente l'index en cons�quence.
          incr index [expr $ou_est_loption+1]
          }
        }
      }
    # Tout s'est bien pass� !
    return 1
  } else {
    error $caption(divers,syntax,syntaxe_args)
    }
  }


proc range_options {args} {
  global caption

  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set list_opts [lindex $args 0]

    # Proc�dure principale
    set index 0
    set ind_max [expr [llength $list_opts]-1]
    # On commence par mettre dans une liste "list_args_opt" les arguments optionnels qui peuvent �tre pr�sents en d�but de liste
    while {$index<=$ind_max} {
      if {[string index [lindex $list_opts $index] 0]=="-"} {
        break
        }
      incr index
      }
    set list_args_opt [lrange $list_opts 0 [expr $index-1]]

    set option_en_cours ""
    # Une option et ses arguments consitue une sous-liste que l'on enregistre dans la liste list_X, o� X est le nombre 
    # d'entr�es pour l'option
 
    # On garde en m�moire dans la variable X le Xmax atteint.
    set X "-1"

    while {$index<=$ind_max} {
      set option_en_cours [lappend option_en_cours [lindex $list_opts $index]]
  
      # Si l'�l�ment en position index+1 commence par "-", ou si l'on est dans la derni�re boucle : 
      # on enregistre l'option en cours dans la liste list_X qui lui convient.
      if {([string index [lindex $list_opts [expr $index+1]] 0]=="-")||($index==$ind_max)} {
        set type_option [expr [llength $option_en_cours]-1]
        # Si besoin on initialise la liste list_X, et les sous-listes list_Y o� Y < X
        if {[info exist list_$type_option]==0} {
          for {set k [expr $X+1]} {$k<=$type_option} {incr k} {
            set list_$k ""
            }
          set X $type_option
          }
        lappend list_$type_option $option_en_cours
        set option_en_cours ""
        }
      # Sinon, on poursuit.

      # Dans tous les cas on incr�mente l'index.
      incr index
      }

    # On retourne une liste dont les �l�ments sont les listes list_X
    if {$X>10} {
      console::affiche_resultat "Option avec trop d'arguments, contacter B. Maugis pour mettre � jour la fontion range_options.\n"
      }
    switch -exact -- $X {
    "-1" {return [list $list_args_opt]}
    "0" {return [list $list_args_opt $list_0]}
    "1" {return [list $list_args_opt $list_0 $list_1]}
    "2" {return [list $list_args_opt $list_0 $list_1 $list_2]}
    "3" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3]}
    "4" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4]}
    "5" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5]}
    "6" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6]}
    "7" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7]}
    "8" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7 $list_8]}
    "9" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7 $list_8 $list_9]}
    "10" {return [list $list_args_opt $list_0 $list_1 $list_2 $list_3 $list_4 $list_5 $list_6 $list_7 $list_8 $list_9 $list_10]}
    default {return ""}
    }
    # fin -)
  } else {
    error $caption(divers,syntax,range_options)
    }
  }


proc calcul_trzaligne {args} {
  global caption

  if {[syntaxe_args $args 2 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set liste_coord1 [lindex $args 0]
    set liste_coord2 [lindex $args 1]

    # Proc�dure principale
    # On appelle (x1,y1) les coordonn�es du 1er point de la 1�re liste,
    # (x2,y2) les coordonn�es du 2nd point de la 1�re liste, (x'1,y'1) les 
    # coordonn�es du 1er point de la seconde liste, (x'2,y'2) les coordonn�es 
    # du 2nd point de la seconde liste.
    set x1 [lindex $liste_coord1 0]
    set y1 [lindex $liste_coord1 1]
    set x2 [lindex $liste_coord1 2]
    set y2 [lindex $liste_coord1 3]
    set x'1 [lindex $liste_coord2 0]
    set y'1 [lindex $liste_coord2 1]
    set x'2 [lindex $liste_coord2 2]
    set y'2 [lindex $liste_coord2 3]

    # Soient (xI,yI) les coordonn�es du milieu du segment (x1,y1), (x2,y2)
    set xI [expr 0.5*($x1+$x2)]
    set yI [expr 0.5*($y1+$y2)]

    # Soient (x'I,y'I) les coordonn�es du milieu du segment (x'1,y'1), (x'2,y'2)
    set x'I [expr 0.5*(${x'1}+${x'2})]
    set y'I [expr 0.5*(${y'1}+${y'2})]

    # Soient (v1,v2) les coordonn�es d'un vecteur directeur de la m�diatrice du 1er segment, 
    set v1 [expr $y2-$y1]
    set v2 [expr $x1-$x2]
    # On norme ce vecteur.
    set N [expr sqrt( pow( $v1 , 2) + pow( $v2 , 2) )]
    set v1 [expr 1.0 * $v1 / $N]
    set v2 [expr 1.0 * $v2 / $N]

    # Soient (v'1,v'2) les coordonn�es d'un vecteur directeur de la m�diatrice du 1er segment,
    # que l'on norme
    set v'1 [expr ${y'2}-${y'1}]
    set v'2 [expr ${x'1}-${x'2}]
    # On norme ce vecteur.
    set N [expr sqrt( pow( ${v'1} , 2) + pow( ${v'2} , 2) )]
    set v'1 [expr 1.0 * ${v'1} / $N]
    set v'2 [expr 1.0 * ${v'2} / $N]

    # Alors la correction de translation consiste � d�placer (x'I,y'I) sur (xI,yI) :
    set translx [expr $xI - ${x'I}]
    set transly [expr $yI - ${y'I}]

    # L'angle de rotation theta s'obtient par le produit scalaire de (v1,v2) et (v'1,v'2) qui vaut
    # cos(theta) puisque les vecteurs sont norm�s. On convertit directement theta en degr�s d�cimaux.
    set theta [expr 180*acos( $v1 * ${v'1} + $v2 * ${v'2} ) / 3.14159265359]

    # On a obtenu pour theta la solution comprise entre 0 et 180 degr�s. Pour traiter le cas d'un 
    # theta n�gatif, on calcule le produit vectoriel de (v1,v2) et (v'1,v'2) qui est un vecteur 
    # orthogonal de norme 1. Sa composante orthogonale vaut donc -1 (theta entre 0 et 180 degr�s) ou +1
    # (theta entre -180 et 0 degr�s).
    set prodvect [expr $v1 * ${v'2} - $v2 * ${v'1}]

    # On corrige theta en cons�quence
    if {$prodvect>0} {
      set theta [expr -1.0*$theta]
      }

    # Calcul du facteur de zoom : c'est la norme du 1er segment divis�e par la norme du 2nd.
    set zoom [expr sqrt( 1.0 *  ( pow( $x2 - $x1 , 2) + pow( $y2 - $y1 , 2) ) / ( pow( ${x'2} - ${x'1} , 2) + pow( ${y'2} - ${y'1} , 2) ) ) ]

    # On renvoie le r�sultat des corrections � apporter.
    return [list $translx $transly $xI $yI $theta $zoom]

  } else {
    error $caption(divers,syntax,calcul_trzaligne)
    }
  }


proc date_chiffresAlettres {args} {
  global caption

  if {[syntaxe_args $args 1 0 ""]=="1"} {

    # Configuration des param�tres obligatoires
    set date_chiffres [lindex $args 0]

    # Proc�dure principale
    set annee [lindex ${date_chiffres} 0]
    set mois_chiffre [lindex ${date_chiffres} 1]
    set jour [lindex ${date_chiffres} 2]

    switch ${mois_chiffre} {
    "1" {
      set mois_lettres "janvier"
      }
    "2" {
      set mois_lettres "f�vrier"
      }
    "3" {
      set mois_lettres "mars"
      }
    "4" {
      set mois_lettres "avril"
      }
    "5" {
      set mois_lettres "mai"
      }
    "6" {
      set mois_lettres "juin"
      }
    "7" {
      set mois_lettres "juillet"
      }
    "8" {
      set mois_lettres "ao�t"
      }
    "9" {
      set mois_lettres "septembre"
      }
    "10" {
      set mois_lettres "octobre"
      }
    "11" {
      set mois_lettres "novembre"
      }
    "12" {
      set mois_lettres "d�cembre"
      }
    }

    if {$jour == "1"} {
      set jour "1er"
      }
    
    return "$jour ${mois_lettres} $annee"    

  } else {
    error $caption(divers,syntax,date_chiffresAlettres)
    }
  }


proc lmin {liste} {
  if {[llength $liste] == 0} {
    return ""
  } else {
    set lmin [lindex $liste 0]
    foreach element $liste {
      if $element<$lmin {
        set lmin $element
        }
      }
    return $lmin
    }
  }


proc lmax {liste} {
  if {[llength $liste] == 0} {
    return ""
  } else {
    set lmax [lindex $liste 0]
    foreach element $liste {
      if $element>$lmax {
        set lmax $element
        }
      }
    return $lmax
    }
  }


########## The end ##########

