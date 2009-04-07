#
# Fichier : filtrage.tcl
# Description : Scripts pour un usage aise des fonctions d'AudeLA
# Auteur : Benjamin MAUCLAIRE (bmauclaire@underlands.org)
# Mise a jour $Id: filtrage.tcl,v 1.6 2009-04-07 09:20:02 jacquesmichelet Exp $
#

#--------------------- Liste des fonctions -----------------------------------#
#
# bm_masque_flou     : Convolution par un filtre passe-bas effectuant un masque flou d'une image
# bm_passe_bas       : Convolution par un filtre passe-bas "�liminant le bruit"
# bm_passe_haut      : Convolution par un filtre passe-haut "�liminant les formes"
# bm_filtre_median   : Convolution par un filtre median effectuant un genre de "moyenne"
# bm_filtre_min      : Convolution par un filtre minimum
# bm_filtre_max      : Convolution par un filtre maximum
# bm_filtre_gauss    : Convolution d'image par un filtre de forme gaussienne (lisse l'image)
# bm_ondelette_mor   : Convolution d'image par un filtre de forme chapeau type morlet
#                      (met en �vidence les d�tails noy�s dans la n�bulosit�)
# bm_ondelette_mex   : Convolution d'image par un filtre de forme chapeau type mexicain
#                      (met en �vidence les d�tails noy�s dans la n�bulosit�)
# bm_logima          : Logarithme d'une image avec des coeficients adpat�s a une image brillante
#
#-----------------------------------------------------------------------------#

#---------------------- Artifice ---------------------------------------------#
#
#--- La variable "audace(artifice)" vaut toujours "@@@@" c'est un artifice qui
#--- permet d'attribuer cette valeur � la variable "fichier" dans le cas d'une
#--- image charg�e en m�moire
#--- Cette variable "audace(artifice)" est d�finie dans le script "aud_menu_4.tcl"
#
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Convolution par un filtre passe-bas effectuant un masque flou d'une image
#
#*****************************************************************************#

#--- Dans ce fichier, les commandes des messages en console/caption sont commentes lorsqu'il est dans
#--- le repertoire des scripts
proc bm_masque_flou { args } {
   #--- arg : fichier coefg coefm
   #--- Arguments : coefg = coefficient du filtre gaussien (0.8 en general), coefm = coefficient de multiplication
   #--- des "details" (en general 1.3)
   #--- Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set fichier [ lindex $args 0 ]
      set coefg [ lindex $args 1 ]
      set coefm [ lindex $args 2 ]

      if { ($fichier == "") || ($coefg == "") || ($coefm == "") } {
         ::console::affiche_erreur "Usage: bm_masque_flou filename coef_gauss mult\n"
      } else {
         #--- Verif existence
         set filein   "$fichier$conf(extension,defaut)"
         set filetmp  "${fichier}_tmp$conf(extension,defaut)"
         set filetmp1 "${fichier}_tmp1$conf(extension,defaut)"
         #--- Algo
         if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               convgauss $coefg
               buf$audace(bufNo) save "$filetmp"
               buf$audace(bufNo) load "$filein"
               buf$audace(bufNo) sub $filetmp 0
               buf$audace(bufNo) mult $coefm
               buf$audace(bufNo) add "$filein" 0
               ::audace::autovisu $audace(visuNo)
               catch {file delete -force "$filetmp"}
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               buf$audace(bufNo) save "$filetmp1"
               convgauss $coefg
               buf$audace(bufNo) save "$filetmp"
               buf$audace(bufNo) load "$filetmp1"
               buf$audace(bufNo) sub $filetmp 0
               buf$audace(bufNo) mult $coefm
               buf$audace(bufNo) add "$filetmp1" 0
               ::audace::autovisu $audace(visuNo)
               catch {file delete -force "$filetmp"}
               catch {file delete -force "$filetmp1"}
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_masque_flou filename coef_gauss mult\n"
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Filtres passe-bas, passe-haut, median, min, max
#
#*****************************************************************************#

proc bm_filter { args } {
   #--- arg : type_filtre fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)
   #--- Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set type_filtre [ lindex $args 0 ]
      set fichier [ lindex $args 1 ]
      set efficacite [ lindex $args 2 ]

      if { ($fichier == "") || ($efficacite == "") } {
         if { $type_filtre == "fb" } {
            ::console::affiche_erreur "Usage: bm_passe_bas filename \[efficiency 0.1\]\n"
         } elseif { $type_filtre == "fh" } {
            ::console::affiche_erreur "Usage: bm_passe_haut filename \[efficiency 0.1\]\n"
         } elseif { $type_filtre == "med" } {
            ::console::affiche_erreur "Usage: bm_filtre_median filename \[efficiency 0.1\]\n"
         } elseif { $type_filtre == "min" } {
            ::console::affiche_erreur "Usage: bm_filtre_min filename \[efficiency 0.1\]\n"
         } elseif { $type_filtre == "max" } {
            ::console::affiche_erreur "Usage: bm_filtre_max filename \[efficiency 0.1\]\n"
         }
      } else {
         if { $type_filtre == "fb" } {
            set filter "filtre_passe-bas"
         } elseif { $type_filtre == "fh" } {
            set filter "filtre_passe-haut"
         } elseif { $type_filtre == "med" } {
            set filter "filtre_median"
         } elseif { $type_filtre == "min" } {
            set filter "filtre_minimum"
         } elseif { $type_filtre == "max" } {
            set filter "filtre_maximum"
         }
         #--- Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         #--- Algo

         if {  ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               buf$audace(bufNo) imaseries "FILTER kernel_type=$type_filtre kernel_coef=$efficacite"
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               buf$audace(bufNo) imaseries "FILTER kernel_type=$type_filtre kernel_coef=$efficacite"
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_filter filter_type filename efficiency\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_passe_bas { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter fb $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_passe_bas filename \[efficiency 0.1\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_passe_haut { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter fh $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_passe_haut filename \[efficiency 0.1\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_filtre_median { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter med $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_median filename \[efficiency 0.1\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_filtre_min { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter min $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_min filename \[efficiency 0.1\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_filtre_max { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set efficacite [ lindex $args 1 ]
      bm_filter max $fichier $efficacite
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_max filename \[efficiency 0.1\]\n"
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Filtres de convolution gaussian, morlet, mexican
#
#*****************************************************************************#

proc bm_convo { args } {
   #--- arg : fichier efficacite
   #--- Arguments : efficacite = efficacite du filtre (0=intense, 1=auncun effet)
   #--- Les variables nommees audace_* sont globales
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set type_filtre [ lindex $args 0 ]
      set fichier [ lindex $args 1 ]
      set largeur [ lindex $args 2 ]

      if { ($fichier == "") || ($largeur == "")} {
         if { $type_filtre == "gaussian" } {
            ::console::affiche_erreur "Usage: bm_filtre_gauss filename \[width 0.5\]\n"
         } elseif { $type_filtre == "morlet" } {
            ::console::affiche_erreur "Usage: bm_ondelette_mor filename \[width 2\]\n"
         } elseif { $type_filtre == "mexican" } {
            ::console::affiche_erreur "Usage: bm_ondelette_mex filename \[width 2\]\n"
         }
      } else {
         if { $type_filtre == "gaussian" } {
            set filter "filtre_gaussien"
         } elseif { $type_filtre == "morlet" } {
            set filter "ond_morlet"
         } elseif { $type_filtre == "mexican" } {
            set filter "ond_mexicain"
         }
         #--- Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         #--- Algo
         if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               if { [ lindex $args 2 ] == 0 } {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre"
               } else {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre sigma=$largeur"
               }
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               if { [ lindex $args 2 ] == 0 } {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre"
               } else {
                  buf$audace(bufNo) imaseries "CONV kernel_type=$type_filtre sigma=$largeur"
               }
               ::audace::autovisu $audace(visuNo)
               set traiteFilters(avancement) $caption(filtrage,fin_traitement)
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_convo filter_type filename width\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_filtre_gauss { args } {
   #--- arg : fichier largeur
   #--- Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo gaussian $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo gaussian $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_filtre_gauss filename \[width 0.5\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_ondelette_mor { args } {
   #--- arg : fichier largeur
   #--- Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo morlet $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo morlet $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_ondelette_mor filename \[width 2\]\n"
   }
}
#-----------------------------------------------------------------------------#

proc bm_ondelette_mex { args } {
   #--- arg : fichier largeur
   #--- Arguments : largeur = largeur du filtre

   if { [llength $args] == 2 } {
      set fichier [ lindex $args 0 ]
      set largeur [ lindex $args 1 ]
      bm_convo mexican $fichier $largeur
   } elseif { [llength $args] == 1 } {
      set fichier [ lindex $args 0 ]
      set largeur 0
      bm_convo mexican $fichier $largeur
   } else {
      ::console::affiche_erreur "Usage: bm_ondelette_mex filename \[width 2\]\n"
   }
}
#-----------------------------------------------------------------------------#

#*****************************************************************************#
#
# Description : Logarithme d'une image avec des coeficients adpates a une image
# brillante
# Evolution future : Fenetre avec reglage des coefficients a l'aide d'ascenseurs
#
#*****************************************************************************#

proc bm_logima { args } {
   #chaque pixel (intensit? p) prend la valeur coef*log10(p-offset).
   global audace
   global conf
   global caption
   global traiteFilters

   if { [llength $args] == 3 } {
      set fichier [ lindex $args 0 ]
      set mult [ lindex $args 1 ]
      set attenuation [ lindex $args 2 ]
      if { ($fichier == "") || ($mult == "") || ($attenuation == "") } {
         ::console::affiche_erreur "Usage: bm_logima mult attenuation\n"
      } else {
         #--- Verif existence
         set filein  "$fichier$conf(extension,defaut)"
         #--- Algo
         if { ( ![info exists audace(artifice)] ) || ( $fichier != "$audace(artifice)" ) } {
            if { [ file exist $filein ] == "1" } {
               ::console::affiche_resultat "$caption(filtrage,chargement) $fichier$conf(extension,defaut)\n\n"
               buf$audace(bufNo) load "$filein"
               set erreur [ catch { log $mult $attenuation } msg ]
               if { $erreur == "1" } {
                  ::console::affiche_erreur "$caption(filtrage,charge_image)\n"
               } else {
                  ::audace::autovisu $audace(visuNo)
                  set traiteFilters(avancement) $caption(filtrage,fin_traitement)
               }
            } else {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_de_fichier)
               set traiteFilters(avancement) ""
            }
         } else {
            if { [ buf[ ::confVisu::getBufNo $audace(visuNo) ] imageready ] == "0" } {
               tk_messageBox -title $caption(filtrage,attention) -type ok -message $caption(filtrage,pas_image_memoire)
               set traiteFilters(avancement) ""
            } else {
               set erreur [ catch { log $mult $attenuation } msg ]
               if { $erreur == "1" } {
                  ::console::affiche_erreur "$caption(filtrage,charge_image)\n"
               } else {
                  ::audace::autovisu $audace(visuNo)
                  set traiteFilters(avancement) $caption(filtrage,fin_traitement)
               }
            }
         }
      }
   } else {
      ::console::affiche_erreur "Usage: bm_logima mult attenuation\n"
   }
}
#-----------------------------------------------------------------------------#

