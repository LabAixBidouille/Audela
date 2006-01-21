####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 25-02-2005
# Arguments : nom du fichier du spectre spatial
# Chargement du script : source [ file joint $audace(rep_scripts) spcaudace.tcl ]
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################


# Remarque : il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

global audace

source [ file join $audace(rep_scripts) spcaudace spc_var.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_ini.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_gui.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_io.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_profil.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_calibrage.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_analyse.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_geom.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_astrophys.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_echelle.tcl ]

#--------- Lancement ---------------#


#extract_profil  $file_spectre_spatial
#trace_profil ${file_spectre_spatial}.dat


