####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 02-01-2007
# Arguments : nom du fichier du spectre spatial
# Chargement du script : source [ file joint $audace(rep_scripts) spcaudace.tcl ]
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################

# Remarque : il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

global audace
global audela

## Fonctions g�n�ralistes

###############################################################################
#
# Description : se met dans le r�pertoire de travail d'Audace pour �viter de 
#  mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date cr�ation : 17-12-2005
# Date de mise � jour : 17-12-2005
# Arguments : aucun
###############################################################################

#--- D�marrage de SpcAudace :
if { [regexp {1.3.0} $audela(version) match resu ] } {
    set repspc [ file join $audace(rep_scripts) spcaudace ]
    #--- Chargement de l'�diteur de profil :
    source [ file join $repspc spc_ini.tcl ]
    source [ file join $repspc spc_gui.tcl ]
} else {
    set repspc [ file join $audace(rep_plugin) tool spectro spcaudace ]
}


#--- Chargement des fonctionnalit�s :
source [ file join $repspc spc_io.tcl ]
source [ file join $repspc spc_profil.tcl ]
source [ file join $repspc spc_calibrage.tcl ]
source [ file join $repspc spc_analyse.tcl ]
source [ file join $repspc spc_operations.tcl ]
source [ file join $repspc spc_geom.tcl ]
source [ file join $repspc spc_astrophys.tcl ]
source [ file join $repspc spc_numeric.tcl ]
source [ file join $repspc spc_echelle.tcl ]
source [ file join $repspc spc_metaf.tcl ]
source [ file join $repspc spc_gui_boxes.tcl ]
source [ file join $repspc spc_gui_runs.tcl ]
source [ file join $repspc spc_var.tcl ]

#--- Chargement des plugins Spcaudace :
source [ file join $repspc plugins specLhIII specLhIII.tcl ]


#--------- Lancement ---------------#
#extract_profil  $file_spectre_spatial
#spc_trace_profil ${file_spectre_spatial}.dat

