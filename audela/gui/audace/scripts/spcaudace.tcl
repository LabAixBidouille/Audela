####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 16-09-2006
# Arguments : Nom du fichier du spectre spatial
# Chargement du script : source [ file joint $audace(rep_scripts) spcaudace.tcl ]
# Remarque 1 : Necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : Utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################

# Remarque : Il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

global audace

#--- Fonctions generalistes

###############################################################################
#
# Description : Se met dans le repertoire de travail d'Aud'ACE pour eviter de 
# mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-12-2005
# Date de mise a jour : 17-12-2005
# Arguments : Aucun
#
###############################################################################
proc spc_goodrep { } {
   global audace

   set repdflt [pwd]
   cd $audace(rep_images)
   return $repdflt
}

#--- Demarrage de SpcAudace :
source [ file join $audace(rep_scripts) spcaudace spc_var.tcl ]

#--- Chargement des fonctionalites :
source [ file join $audace(rep_scripts) spcaudace spc_io.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_profil.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_calibrage.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_analyse.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_operations.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_geom.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_astrophys.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_numeric.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_echelle.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_metaf.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_gui_boxes.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_gui_runs.tcl ]

#--- Chargement des plugins :
#source [ file join $audace(rep_scripts) spcaudace plugins specLhIII specLhIII.tcl ]

#--------- Lancement ---------------#

#extract_profil  $file_spectre_spatial
#spc_trace_profil ${file_spectre_spatial}.dat

