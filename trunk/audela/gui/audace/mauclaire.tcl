#-----------------------------------------------------------------------------#
#
# Fichier : mauclaire.tcl
# Description : Scripts pour un usage aise des fonctions d'audela
# Auteur : Benjamin MAUCLAIRE (bmauclaire@underlands.org)
# Date de mise a jour : 03 decembre 2004
#
#-----------------------------------------------------------------------------#

#--------------------- Liste des fonctions -----------------------------------#
#
# bm_masque_flou     : convolution par un filtre passe-bas effectuant un masque flou d'une image
# bm_passe_bas       : convolution par un filtre passe-bas "éliminant le bruit"
# bm_passe_haut      : convolution par un filtre passe-haut "éliminant les formes"
# bm_filtre_median   : convolution par un filtre median effectuant un genre de "moyenne"
# bm_filtre_min      : convolution par un filtre minimum
# bm_filtre_max      : convolution par un filtre maximum
# bm_filtre_gauss    : convolution d'image par un filtre de forme gaussienne (lisse l'image)
# bm_ondelette_mor   : convolution d'image par un filtre de forme chapeau type morlet 
#                      (met en évidence les détails noyés dans la nébulosité)
# bm_ondelette_mex   : convolution d'image par un filtre de forme chapeau type mexicain 
#                      (met en évidence les détails noyés dans la nébulosité)
# bm_cutima          : découpage d'une zone sélectionnée à la sourie d'une image chargée
# bm_zoomima         : zoom de l'image ou d'une partie sélectionnée de l'image chargée
# bm_logima          : logarithme d'une image avec des coeficients adpatés a une image brillante
#
#---------------------- Artifice ---------------------------------------------#
#
# La variable "audace(artifice)" vaut toujours "@@@@" c'est un artifice qui
# permet d'attribuer cette valeur à la variable "fichier" dans le cas d'une
# image chargée en mémoire
# Cette variable "audace(artifice)" est définie dans le script "aud3.tcl"
#
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Convolution par un filtre passe-bas effectuant un masque flou d'une image
# Date creation: 17 mai 2003
# Date de mise a jour : 30 novembre 2004
#
#*****************************************************************************#

# Dans ce fichier, les commandes des messages en console/caption sont commentes lorsqu'il est dans
# le repertoire des scripts
proc bm_masque_flou { args } {
   # arg : fichier coefg coefm
   # Arguments : coefg = coefficient du filtre gaussien (0.8 en general), coefm = coefficient de multiplication
   # des "details" (en general 1.3)
   # Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption

   if {[llength $args] == 3} {
      set fichier [ lindex $args 0 ]
      set coefg [ lindex $args 1 ]
      set coefm [ lindex $args 2 ]

      if {($fichier == "") || ($coefg == "") || ($coefm == "")} {
         ::console::affiche_erreur "Usage: bm_masque_flou filename coef_gauss mult\n\n"
      } else {
         ## Verif existence
         set filein   "$fichier$conf(extension,defaut)"
         set filetmp  "${fichier}_tmp$conf(extension,defaut)"
         set filetmp1 "${fichier}_tmp1$conf(extension,defaut)"
         ## Algo
         if { $fichier != "$audace(artifice)" } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(mauclaire,chargement) $fichier$conf(extension,defaut)\n"
               buf$audace(bufNo) load "$filein"
               convgauss $coefg
               buf$audace(bufNo) save "$filetmp"
               buf$audace(bufNo) load "$filein"
               buf$audace(bufNo) sub $filetmp 0
               buf$audace(bufNo) mult $coefm
               buf$audace(bufNo) add "$filein" 0
               ::audace::autovisu visu$audace(visuNo)
               catch {file delete -force "$filetmp"}
               ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
            } else {
               ::console::affiche_erreur "$caption(mauclaire,pas_de_fichier)\n"
            }
         } else {
            if { [ buf$audace(bufNo) imageready ] == "0" } {
               ::console::affiche_erreur "$caption(mauclaire,pas_image_memoire)\n\n"
            } else {
               buf$audace(bufNo) save "$filetmp1"
               convgauss $coefg
               buf$audace(bufNo) save "$filetmp"
               buf$audace(bufNo) load "$filetmp1"
               buf$audace(bufNo) sub $filetmp 0
               buf$audace(bufNo) mult $coefm
               buf$audace(bufNo) add "$filetmp1" 0
               ::audace::autovisu visu$audace(visuNo)
               catch {file delete -force "$filetmp"}
               catch {file delete -force "$filetmp1"}
               ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_masque_flou filename coef_gauss mult\n\n"
   }
}

#*****************************************************************************#
# Description : Filtres passe-bas, passe-haut, median, min, max
# Date creation : 29 aout 2003
# Date de mise a jour : 30 novembre 2004
#
#*****************************************************************************#

proc bm_filter { args } {
   ## arg : type_filtre fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)
   ## Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption

   if {[llength $args] == 3} {
      set type_filtre [ lindex $args 0 ]
      set fichier [ lindex $args 1 ]
      set efficacite [ lindex $args 2 ]

      if { ($fichier == "") || ($efficacite == "") } {
         if { $type_filtre == "fb" } {
            ::console::affiche_erreur "Usage: bm_passe_bas filename \[efficiency 0.1\]\n\n"
         } elseif { $type_filtre == "fh" } {
            ::console::affiche_erreur "Usage: bm_passe_haut filename \[efficiency 0.1\]\n\n"
         } elseif { $type_filtre == "med" } {
            ::console::affiche_erreur "Usage: bm_filtre_median filename \[efficiency 0.1\]\n\n"
         } elseif { $type_filtre == "min" } {
            ::console::affiche_erreur "Usage: bm_filtre_min filename \[efficiency 0.1\]\n\n"
         } elseif { $type_filtre == "max" } {
            ::console::affiche_erreur "Usage: bm_filtre_max filename \[efficiency 0.1\]\n\n"
         }          
      } else {
         ## Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         ## Algo
         if { $fichier != "$audace(artifice)" } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(mauclaire,chargement) $fichier$conf(extension,defaut)\n"
               buf$audace(bufNo) load "$filein"
               buf$audace(bufNo) imaseries "FILTER kernel_type=$type_filtre kernel_coef=$efficacite"
               ::audace::autovisu visu$audace(visuNo)
               ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
            } else {
               ::console::affiche_erreur "$caption(mauclaire,pas_de_fichier)\n"
            }
         } else {
            if { [ buf$audace(bufNo) imageready ] == "0" } {
               ::console::affiche_erreur "$caption(mauclaire,pas_image_memoire)\n\n"
            } else {
               buf$audace(bufNo) imaseries "FILTER kernel_type=$type_filtre kernel_coef=$efficacite"
               ::audace::autovisu visu$audace(visuNo)
               ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_filter filter_type filename efficiency\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_passe_bas { args } {
   ## arg : fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if {[llength $args] == 2} {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter fb $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_passe_bas filename \[efficiency 0.1\]\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_passe_haut { args } {
   ## arg : fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if {[llength $args] == 2} {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter fh $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_passe_haut filename \[efficiency 0.1\]\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_filtre_median { args } {
   ## arg : fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if {[llength $args] == 2} {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter med $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_median filename \[efficiency 0.1\]\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_filtre_min { args } {
   ## arg : fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if {[llength $args] == 2} {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter min $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_min filename \[efficiency 0.1\]\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_filtre_max { args } {
   ## arg : fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if {[llength $args] == 2} {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter max $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_max filename \[efficiency 0.1\]\n\n"
   }
}

#*****************************************************************************#
#
# Description : Filtres de convolution gaussian, morlet, mexican
# Date creation : 29 aout 2003
# Date de mise a jour : 30 novembre 2004
#
#*****************************************************************************#

proc bm_convo { args } {
   ## arg : fichier efficacite
   ## Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)
   ## Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption

   if {[llength $args] == 3} {
      set type_filtre [ lindex $args 0 ]
      set fichier [ lindex $args 1 ]
      set largeur [ lindex $args 2 ]

      if { ($fichier == "") || ($largeur == "")} {
         if { $type_filtre == "gaussian" } {
            ::console::affiche_erreur "Usage: bm_filtre_gauss filename \[width 0.5\]\n\n"
         } elseif { $type_filtre == "morlet" } {
            ::console::affiche_erreur "Usage: bm_ondelette_mor filename \[width 2\]\n\n"
         } elseif { $type_filtre == "mexican" } {
            ::console::affiche_erreur "Usage: bm_ondelette_mex filename \[width 2\]\n\n"
         }          
      } else {
         ## Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         ## Algo
         if { $fichier != "$audace(artifice)" } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(mauclaire,chargement) $fichier$conf(extension,defaut)\n"
               buf$audace(bufNo) load "$filein"
               if { [ lindex $args 2 ] == 0 } {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre"
               } else {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre sigma=$largeur"
               }
               ::audace::autovisu visu$audace(visuNo)
               ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
            } else {
               ::console::affiche_erreur "$caption(mauclaire,pas_de_fichier)\n"
            }
         } else {
            if { [ buf$audace(bufNo) imageready ] == "0" } {
               ::console::affiche_erreur "$caption(mauclaire,pas_image_memoire)\n\n"
            } else {
               if { [ lindex $args 2 ] == 0 } {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre"
               } else {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre sigma=$largeur"
               }
               ::audace::autovisu visu$audace(visuNo)
               ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_convo filter_type filename width\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_filtre_gauss { args } {
   ## arg : fichier largeur
   ## Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo gaussian $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo gaussian $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_gauss filename \[width 0.5\]\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_ondelette_mor { args } {
   ## arg : fichier largeur
   ## Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo morlet $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo morlet $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_ondelette_mor filename \[width 2\]\n\n"
   }
}

#-----------------------------------------------------------------------------#
proc bm_ondelette_mex { args } {
   ## arg : fichier largeur
   ## Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo mexican $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo mexican $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_ondelette_mex filename \[width 2\]\n\n"
   }
}

#*****************************************************************************#
#
# Description : Decoupage d'une zone selectionnee a la souris
# Date creation : 9 septembre 2003
# Date de mise a jour : 30 novembre 2004
#
#*****************************************************************************#

proc bm_cutima {} {
   global audace

   if { [info exists audace(box)] == 1 } {
      buf$audace(bufNo) window $audace(box)
      #--- Suppression de la zone selectionnee avec la souris
      catch {
         unset audace(box)
         $audace(hCanvas) delete $audace(hBox)
      }
      ::audace::autovisu visu$audace(visuNo)
   } else {
      ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
   }
}

#*****************************************************************************#
#
# Description : Zoom d'une image ou d'une zone selectionnee a la souris
# Date creation : 9 septembre 2003
# Date de mise a jour : 30 novembre 2004
#
#*****************************************************************************#

#buf$audace(bufNo) imaseries "RESAMPLE options"
#IMA/SERIES ... RESAMPLE "paramresample=$gross 0 0 0 $gross 0 normaflux=1"

proc bm_zoomima { args } {
   global audace

   if {[llength $args] == 1} {
      set gross $args
      set factor [list $gross $gross]
      if { [info exists audace(box)] == 0 } {
         set xmax [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
         set ymax [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
         buf$audace(bufNo) window "1 $ymax $xmax 1"
      } else {
         buf$audace(bufNo) window $audace(box)
         #--- Suppression de la zone selectionnee avec la souris
         catch {
            unset audace(box)
            $audace(hCanvas) delete $audace(hBox)
         }
      }
      buf$audace(bufNo) scale $factor 1
      ::audace::autovisu visu$audace(visuNo)
   } else {
      ::console::affiche_erreur "Usage: bm_zoomima mult\n\n"
   }
}

#*****************************************************************************#
#
# Description : Logarithme d'une image avec des coeficients adpates a une image
# brillante
# Evolution future : Fenetre avec reglage des coefficients a l'aide d'ascenseurs
# Date creation : 9 septembre 2003
# Date de mise a jour : 30 novembre 2004
#
#*****************************************************************************#

proc bm_logima { args } {
   #chaque pixel (intensit? p) prend la valeur coef*log10(p-offset).
   global audace
   global conf
   global caption

   if {[llength $args] == 3} {
      set fichier [ lindex $args 0 ]
      set mult [ lindex $args 1 ]
	set attenuation [ lindex $args 2 ]
      if { ($fichier == "") || ($mult == "") || ($attenuation == "")} {
         ::console::affiche_erreur "Usage: bm_logima mult attenuation\n\n"
      } else {
         ## Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         ## Algo
         if { $fichier != "$audace(artifice)" } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(mauclaire,chargement) $fichier$conf(extension,defaut)\n"
               buf$audace(bufNo) load "$filein"
               set erreur [ catch { log $mult $attenuation } msg ]
               if { $erreur == "1" } {
                  ::console::affiche_erreur "$caption(mauclaire,charge_image)\n"
               } else {
                  ::audace::autovisu visu$audace(visuNo)
                  ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
               }
            } else {
               ::console::affiche_erreur "$caption(mauclaire,pas_de_fichier)\n"
            }
         } else {
            if { [ buf$audace(bufNo) imageready ] == "0" } {
               ::console::affiche_erreur "$caption(mauclaire,pas_image_memoire)\n\n"
            } else {
               set erreur [ catch { log $mult $attenuation } msg ]
               if { $erreur == "1" } {
                  ::console::affiche_erreur "$caption(mauclaire,charge_image)\n"
               } else {
                  ::audace::autovisu visu$audace(visuNo)
                  ::console::affiche_resultat "$caption(mauclaire,fin_traitement)\n"
               }
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_logima mult attenuation\n\n"
   }
}

