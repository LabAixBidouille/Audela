#
# Fichier : bifsconv.tcl
# Description : Ce script permet de convertir de multiples formats d'images vers du fits
# Auteur : Benoit MAUGIS
# Mise a jour $Id: bifsconv.tcl,v 1.11 2008-11-11 13:29:09 robertdelmas Exp $
#

#--- Documentation : Voir le fichier bifsconv.htm dans le dossier doc_html

proc bifsconv { {fichier} {arg1 ""} {arg2 ""} {arg3 ""} {arg4 ""} {arg5 ""} {arg6 ""} {arg7 ""} {arg8 ""} {arg9 ""} {arg10 ""} {arg11 ""} {arg12 ""} {arg13 ""} {arg14 ""} {arg15 ""} } {
   global audace

   bifsconv_full [file join $audace(rep_images) $fichier] $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 $arg10 $arg11 $arg12 $arg13 $arg14 $arg15
}

proc bifsconv_full { {fichier} {arg1 ""} {arg2 ""} {arg3 ""} {arg4 ""} {arg5 ""} {arg6 ""} {arg7 ""} {arg8 ""} {arg9 ""} {arg10 ""} {arg11 ""} {arg12 ""} {arg13 ""} {arg14 ""} {arg15 ""} } {
   global audace caption conf

   if {[file exist $fichier]=="1"} {
      #--- Choix de la version BifsConv selon le systeme d'exploitation
      set subdir_bifs "bin"
      if {$::tcl_platform(os)=="Linux"} {
         set bifs_version "bifsconv"
      } else {
         set bifs_version "bifsconv.exe"
      }

      #--- Petit message
      ::console::affiche_resultat "$caption(bifsconv,imaencours) $fichier\n"

      #--- Execution de BifsConv
      set error [ catch { exec [file join $audace(rep_install) $subdir_bifs $bifs_version] $fichier $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 $arg10 $arg11 $arg12 $arg13 $arg14 $arg15 } msg ]

      if [ string match "*Tfi=0*" $msg ] {
         ::console::affiche_resultat "$caption(bifsconv,formatpasbon)\n"
         return
      }

      set racine [file rootname $fichier]

      #--- Correction de l'extension si elle n'est pas ".fit"
      if {$conf(extension,defaut)!=".fit"} {
         file rename $racine.fit $racine$conf(extension,defaut)
      }

      #--- Compression si les fichiers sont compresses par defaut
      if {$conf(fichier,compres)==1} {
         gzip $racine$conf(extension,defaut)
      }

   } else {
      ::console::affiche_resultat "$caption(bifsconv,pasdefichier) $fichier\n"
   }
}

proc convert_fits { {nom_generique} {ext} {rep "audace(rep_images)"} } {
   global audace

   if {$rep=="audace(rep_images)"} {set rep $audace(rep_images)}
   set liste_index [liste_index $nom_generique -rep $rep -ext $ext]
   foreach index $liste_index {
      bifsconv_full [file join $rep $nom_generique$index$ext]
   }
}

proc convert_fits_all { {extension} {rep "audace(rep_images)"} } {
   global audace caption

   if {$rep=="audace(rep_images)"} {set rep $audace(rep_images)}
   ::console::affiche_resultat "$caption(bifsconv,repencours) $rep\n"
   set liste_cibles [glob -nocomplain [file join $rep *$extension]]
   foreach cible $liste_cibles {
      bifsconv_full $cible
   }
}

proc convert_fits_subdir { {extension} {rep "audace(rep_images)"} } {
  global audace

   if {$rep=="audace(rep_images)"} {set rep $audace(rep_images)}
   convert_fits_all $extension $rep
   set list_elts [glob -nocomplain [file join $rep *]]
   foreach subdir $list_elts {
      if {[file isdirectory $subdir]=="1"} {
         convert_fits_subdir $extension $subdir
      }
   }
}

proc loadima_nofits { {fichier} {rep "audace(rep_images)"} } {
   global audace caption

   if {$rep=="audace(rep_images)"} {set rep $audace(rep_images)}
   #--- Creation du repertoire temporaire
   set rep_tmp [cree_sousrep]
   #--- Copie de l'image dans le repertoire temporaire
   file copy [file join $rep $fichier] [file join $rep_tmp $fichier]
   #--- Conversion de l'image au format FITS
   bifsconv_full [file join $rep_tmp $fichier]
   set fichierfits [file join $rep_tmp [file rootname $fichier].fit]
   #--- Chargement de l'image et gestion des erreurs
   set error [ catch { buf$audace(bufNo) load $fichierfits } msg ]
   if { $error == "1" } {
      ::console::affiche_resultat "$caption(bifsconv,sortieconversion)"
      return
   }
   #--- Visualisation automatique
   audace::autovisu $audace(visuNo)
   #--- Mise a jour de l'en-tete audace
   wm title $audace(base) "$caption(bifsconv,audace) - [file join $rep $fichier]"
   #--- Suppression de l'image copiee
   file delete [file join $rep_tmp $fichier]
   #--- Suppression de l'image FITS temporaire
   file delete $fichierfits
   #--- Suppression du repertoire temporaire
   file delete $rep_tmp
}

########## The end ##########

