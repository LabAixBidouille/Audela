#
# Fichier : iris.tcl
# Description : Ce script permet d'exécuter des commandes Iris depuis un script tcl
# Auteur : Benoit MAUGIS
# Mise a jour $Id: iris.tcl,v 1.8 2008-06-01 16:29:41 robertdelmas Exp $
#

#--- Documentation : Voir la page iris.htm dans le dossier doc_html

proc iris_initlinux { } {
   global audace

   set fileId [ open [ file join $audace(rep_install) bin scriptis_init.tcl ] w ]
   puts -nonewline $fileId ">"
   close $fileId

   catch { exec wine scriptis.exe scriptis_init.tcl }

   file delete [ file join $audace(rep_install) bin scriptis_init.tcl ]
}

proc iris { {commande} {arg1 ""} {arg2 ""} {arg3 ""} {arg4 ""} {arg5 ""} {arg6 ""} {arg7 ""} {arg8 ""} {arg9 ""} {arg10 ""} {arg11 ""} {arg12 ""} {arg13 ""} {arg14 ""} {arg15 ""} } {
   global audace

   #--- Cas particuliers
   switch $commande {
      "bestof" {
         if {[file exist [file join $audace(rep_images) select.lst]]=="1"} {
            file delete [file join $audace(rep_images) select.lst]
         }
      }
      "pregister" {
         if {[file exist [file join $audace(rep_images) $arg2${arg4}.fit]]=="1"} {
            file delete [file join $audace(rep_images) $arg2${arg4}.fit]
         }
      }
      "file_trans" {
         if {[file exist [file join $audace(rep_images) $arg2${arg3}.fit]]=="1"} {
            file delete [file join $audace(rep_images) $arg2${arg3}.fit]
         }
      }
   }

   set vieuxrep [pwd]
   cd [ file join $audace(rep_install) bin ]
   set fileId [ open [ file join $audace(rep_install) bin scriptis.tcl ] w ]

   switch -regexp $::tcl_platform(os) {
      "Linux" {
         iris_initlinux
         set line ""
      }
      "Windows" {
         set line ""
      }
   }

   append line $commande " " $arg1 " " $arg2 " " $arg3 " " $arg4 " " $arg5 " " $arg6 " " $arg7 " " $arg8 " " $arg9 " " $arg10 " " $arg11 " " $arg12 " " $arg13 " " $arg14 " " $arg15

   #--- Suppression des blancs à la fin
   set nb_blocs [llength $line]
   set mine [lrange $line 0 [expr $nb_blocs-1]]

   puts -nonewline $fileId $mine

   switch -regexp $::tcl_platform(os) {
      "Linux" {
      }
      "Windows" {
         puts $fileId ""
      }
   }

   close $fileId
   switch -regexp $::tcl_platform(os) {
      "Linux" {
         catch {exec wine scriptis.exe scriptis.tcl}
      }
      "Windows" {
         exec scriptis.exe scriptis.tcl
      }
   }

   #--- Cas particuliers
   switch $commande {
      "bestof" {
         while {[file exist [file join $audace(rep_images) select.lst]]=="0"} {
            after 100
         }
      }
      "pregister" {
         while {[file exist [file join $audace(rep_images) $arg2${arg4}.fit]]=="0"} {
            after 100
         }
      }
      "file_trans" {
         while {[file exist [file join $audace(rep_images) $arg2${arg3}.fit]]=="0"} {
            after 100
         }
      }
   }

   cd $vieuxrep
   file delete [ file join $audace(rep_install) bin scriptis.tcl ]
   return ""
}

proc iris2_select { {nom_ini} {nom_final} {nombre} } {
   global audace

   #--- Suppression préalable si la série de destination est déjà existante
   suppr_serie $nom_final -ext .fit
   set nom_rep [file join $audace(rep_images) select.lst]
   set fileId [open $nom_rep r]
   for {set k 1} {$k<=$nombre} {incr k} {
      gets $fileId ind
      file copy [file join $audace(rep_images) $nom_ini$ind.fit] [file join $audace(rep_images) $nom_final$k.fit]
   }
   close $fileId
}

proc iris2_compute_trichro1 { {maitre} {r} {v} {b} {taille} {nb_select} {nb_total} } {
   global audace caption conf

   #--- Création du sous-répertoire de traitement
   console::affiche_resultat $caption(iris,subdir)
   set subdir [cree_sousrep -nom_base "iris2_compute_trichro1"]
   console::affiche_resultat ${subdir}\n
   #--- Normalisation de l'offset de la séquence maître
   console::affiche_resultat $caption(iris,normoffset_maitre)
   noffset2 $maitre "tmp_maitre_" "0" $nb_total
   #--- Réhaussement du contraste de la séquence maître par masque flou
   console::affiche_resultat $caption(iris,mf)
   iris "unsharp2" "tmp_maitre_" "tmp_unsharp_" "3" "6" "0" $nb_total
   #--- Bestof sur la séquence maître de contraste réhaussé
   console::affiche_resultat $caption(iris,bestof)
   iris "bestof" "tmp_unsharp_" $nb_total
   #--- Suppression de la séquence maître de contraste réhaussé
   suppr_serie "tmp_unsharp_"
   #--- On ne garde que les meilleures images de la séquence maître
   suppr_serie "tmp_maitre2_"
   iris2_select "tmp_maitre_" "tmp_maitre2_" $nb_select
   #--- Suppression des images non triées
   suppr_serie "tmp_maitre_"
   #--- Chargement de la première image maître dans Iris pour sélectionner le centre de la planète
   console::affiche_resultat $caption(iris,selectmsg)
   iris "load" "tmp_maitre2_1"
   #--- NB : On ajuste les seuils pour bien la voir
   set num_buf_tmp [buf::create]
   buf$num_buf_tmp extension $conf(extension,defaut)
   buf$num_buf_tmp load [file join $audace(rep_images) tmp_maitre2_1$conf(extension,defaut)]
   set stats [buf$num_buf_tmp stat]
   buf::delete $num_buf_tmp
   iris "visu" [lrange $stats 0 1]
   tk_messageBox -type ok -message $caption(iris,select)
   #--- Registration des images maîtres triées
   console::affiche_resultat $caption(iris,registr_maitre)
   iris "pregister" "tmp_maitre2_" "tmp_maitre3_" $taille $nb_select
   #--- Addition de ces images
   sadd "tmp_maitre3_" "tmp_maitre" $nb_select
   #--- Suppression des fichiers maîtres temporaires
   suppr_serie "tmp_maitre2_"
   #--- Traitement des images rouges
   console::affiche_resultat $caption(iris,ima_r)
   if {$maitre==$r} {
      file rename [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)] [file join $subdir r$conf(extension,defaut)]
   } else {
      suppr_serie "tmp_r_"
      iris2_select $r "tmp_r_" $nb_select
      noffset2 "tmp_r_" "tmp_r_" "0" $nb_select
      iris "file_trans" "tmp_r_" "tmp_r2_" $nb_select
      suppr_serie "tmp_r_"
      sadd "tmp_r2_" "tmp_r" $nb_select
      suppr_serie "tmp_r2_"
      file rename [file join $audace(rep_images) tmp_r$conf(extension,defaut)] [file join $subdir r$conf(extension,defaut)]
   }
   #--- Traitement des images vertes
   console::affiche_resultat $caption(iris,ima_v)
   if {$maitre==$v} {
      file rename [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)] [file join $subdir v$conf(extension,defaut)]
   } else {
      suppr_serie "tmp_v_"
      iris2_select $v "tmp_v_" $nb_select
      noffset2 "tmp_v_" "tmp_v_" "0" $nb_select
      iris "file_trans" "tmp_v_" "tmp_v2_" $nb_select
      suppr_serie "tmp_v_"
      sadd "tmp_v2_" "tmp_v" $nb_select
      suppr_serie "tmp_v2_"
      file rename [file join $audace(rep_images) tmp_v$conf(extension,defaut)] [file join $subdir v$conf(extension,defaut)]
   }
   #--- Traitement des images bleues
   console::affiche_resultat $caption(iris,ima_b)
   if {$maitre==$b} {
      file rename [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)] [file join $audace(rep_images) b$conf(extension,defaut)]
   } else {
      suppr_serie "tmp_b_"
      iris2_select $b "tmp_b_" $nb_select
      noffset2 "tmp_b_" "tmp_b_" "0" $nb_select
      iris "file_trans" "tmp_b_" "tmp_b2_" $nb_select
      suppr_serie "tmp_b_"
      sadd "tmp_b2_" "tmp_b" $nb_select
      suppr_serie "tmp_b2_"
      file rename [file join $audace(rep_images) tmp_b$conf(extension,defaut)] [file join $subdir b$conf(extension,defaut)]
   }
   #--- Suppression, si ce n'est déjà fait, du dernier fichier maître temporaire
   if {[file exist [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)]]=="1"} {
      file delete [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)]
   }
   #--- Inscription dans un fichier texte des caractéristiques du traitement
   set fileId [open [file join $subdir iris2_compute_trichro1.txt] w]
   puts $fileId $caption(iris,nom_maitre)$maitre
   puts $fileId $caption(iris,nom_rouge)$r
   puts $fileId $caption(iris,nom_vert)$v
   puts $fileId $caption(iris,nom_bleu)$b
   puts $fileId $caption(iris,taille_pregistr)$taille
   puts $fileId $caption(iris,nb_tot)$nb_total
   puts $fileId $caption(iris,nb_select)$nb_select
   close $fileId
}

