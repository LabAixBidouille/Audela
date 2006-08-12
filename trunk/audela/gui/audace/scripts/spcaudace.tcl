####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 25-02-2005/03-12-2005
# Arguments : nom du fichier du spectre spatial
# Chargement du script : source [ file joint $audace(rep_scripts) spcaudace.tcl ]
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################

# Remarque : il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

global audace

## Fonctions généralistes

###############################################################################
#
# Descirption : se met dans le répertoire de travail d'Audace pour éviter de 
#  mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date création : 17-12-2005
# Date de mise à jour : 17-12-2005
# Arguments : aucun
###############################################################################
proc spc_goodrep {} {

    global audace
    global conf
    set repdflt [pwd]
    cd $audace(rep_images)
    return $repdflt
}


## Démarrage de SpcAudace :
source [ file join $audace(rep_scripts) spcaudace spc_var.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_ini.tcl ]
source [ file join $audace(rep_scripts) spcaudace spc_gui.tcl ]
## Chargement des plugins :
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
#--------- Lancement ---------------#


#extract_profil  $file_spectre_spatial
#spc_trace_profil ${file_spectre_spatial}.dat

