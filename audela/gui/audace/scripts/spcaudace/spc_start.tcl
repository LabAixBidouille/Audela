####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 18-02-2005
# Arguments : nom du fichier du spectre spatial
# Chargement en script : source $audace(rep_scripts)/spcaudace/spc_start.tcl
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################


# Remarque : il faut mettre remplacer toutes les variables textes par des variables caption(mauclaire,...)
# qui seront initialisées dans le fichier cap_mauclaire.tcl
# et renommer ce fichier mauclaire.tcl ;-)

global audace
global conf

source [ file join $audace(rep_scripts) spcaudace spc_var.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_ini.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_gui.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_io.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_profil.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_calibrage.tcl ]
# source [ file join $audace(rep_scripts) spcaudace spc_analyse.tcl ]
# source [ file join $audace(rep_scripts) spcaudace spc_geom.tcl ]

#--------- Lancement ---------------#


#extract_profil  $file_spectre_spatial
#trace_profil ${file_spectre_spatial}.dat


