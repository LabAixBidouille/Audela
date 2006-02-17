#
# Fichier bifsconv.tcl
# Ce script permet de convertir de multiples formats d'images vers du fits.
# Auteur : Beno�t Maugis
# Version : 1.3.1 ---> 1.3.2
# Date de mise a jour : 10 avril 2005 ---> 17 fevrier 2006
#

# Documentation : voir le fichier bifsconv.htm dans le dossier doc_html.

proc bifsconv {{fichier} {arg1 ""} {arg2 ""} {arg3 ""} {arg4 ""} {arg5 ""} {arg6 ""} {arg7 ""} {arg8 ""} {arg9 ""} {arg10 ""} {arg11 ""} {arg12 ""} {arg13 ""} {arg14 ""} {arg15 ""}} {
  global audace
  bifsconv_full [file join $audace(rep_images) $fichier] $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 $arg10 $arg11 $arg12 $arg13 $arg14 $arg15
  }

proc bifsconv_full {{fichier} {arg1 ""} {arg2 ""} {arg3 ""} {arg4 ""} {arg5 ""} {arg6 ""} {arg7 ""} {arg8 ""} {arg9 ""} {arg10 ""} {arg11 ""} {arg12 ""} {arg13 ""} {arg14 ""} {arg15 ""}} {
#--- Debut modif Robert
  global audace caption conf
#--- Fin modif Robert
  if {[file exist $fichier]=="1"} {
    # Choix de la version BifsConv selon le syst�me d'exploitation
    set subdir_bifs "bin"
#--- Debut modif Robert
    if {$::tcl_platform(os)=="Linux"} {
#--- Fin modif Robert
      set bifs_version "bifsconv"
    } else {
      set bifs_version "bifsconw.exe"
      }

    # Petit message
    console::affiche_resultat "$caption(bifsconv,imaencours) $fichier\n"

    # Ex�cution de BifsConv
    exec [file join $audace(rep_install) $subdir_bifs $bifs_version] $fichier $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 $arg10 $arg11 $arg12 $arg13 $arg14 $arg15

    set racine [file rootname $fichier]

    # Correction du l'extension si elle n'est pas ".fit"
    if {$conf(extension,defaut)!=".fit"} {
      file rename $racine.fit $racine$conf(extension,defaut)
      }

    # Compression si les fichiers sont compress�s par d�faut
#--- Debut modif Robert
    if {$conf(fichier,compres)==1} {
#--- Fin modif Robert
      gzip $racine$conf(extension,defaut)
      }

  } else {
    console::affiche_resultat "$caption(bifsconv,pasdefichier) $fichier\n"
    }
  }

proc convert_fits {{nom_generique} {ext} {rep "audace(rep_images)"}} {
  global audace
  if {$rep=="audace(rep_images)"} {set rep $audace(rep_images)}
  set liste_index [visio::liste_index $nom_generique $rep $ext]
  foreach index $liste_index {
    bifsconv_full [file join $rep $nom_generique$index$ext]}
  }

proc convert_fits_all {{extension} {rep "audace(rep_images)"}} {
  global audace caption
  if {$rep=="audace(rep_images)"} {set rep $audace(rep_images)}
  console::affiche_resultat "$caption(bifsconv,repencours) $rep\n"
  set liste_cibles [glob -nocomplain [file join $rep *$extension]]
  foreach cible $liste_cibles {
    bifsconv_full $cible}
  }

proc convert_fits_subdir {{extension} {rep "audace(rep_images)"}} {
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

proc loadima_nofits {{fichier} {rep "rep_images"}} {
  global audace caption conf
  if {$rep=="rep_images"} {set rep $audace(rep_images)}    
  set rep_tmp [cree_sousrep]
  file copy [file join $rep $fichier] [file join $rep_tmp $fichier]
  bifsconv_full [file join $rep_tmp $fichier]
  set fichierfits [file join $rep_tmp [file rootname $fichier].fit]
  buf$audace(bufNo) load $fichierfits
  # Visualisation automatique
#--- Debut modif Robert
  audace::autovisu $audace(visuNo)
#--- Fin modif Robert
  # MAJ en-t�te audace
  wm title $audace(base) "$caption(bifsconv,audace) - [file join $rep $fichier]"
  # Suppression du fichier copi�
  file delete [file join $rep_tmp $fichier]
  # Suppression du fichier FITS temporaire
  file delete $fichierfits
  # Suppression du r�pertoire temporaire
  file delete $rep_tmp
  }

########## The end ##########

