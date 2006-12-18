####################################################################################
#
# Creation d'un profil de raie a partir du spectre spatial x,y
# Auteur : Benjamin MAUCLAIRE
# Date de creation : 17-08-2004
# Date de mise a jour : 25-02-2005/03-12-2005
# Arguments : nom du fichier du spectre spatial
# Chargement du script : source [ file joint $audace(rep_plugin) tool spectro spcaudace.tcl ]
# Remarque 1 : necessite le repere de coordonnnees a l'aide de la souris
# Remarque 2 : utilise la librairie blt pour le trace final du profil de raie
#
#####################################################################################

# Remarque : il faut remplacer toutes les variables textes par des variables caption(spcaudace,xxxxx)
# qui seront initialisees dans le fichier spcaudace.cap contenu dans le repertoire spcaudace

global audace
global audela

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


#--- Démarrage de SpcAudace :
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_var.tcl ]
#-- Partie à charger séparément dans Audela 1.4.0 :
if { [regexp {1.3.0} $audela(version) match resu ] } {
    source [ file join $audace(rep_plugin) tool spectro spcaudace spc_ini.tcl ]
    source [ file join $audace(rep_plugin) tool spectro spcaudace spc_gui.tcl ]
}

#--- Chargement des focntionalités :
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_io.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_profil.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_calibrage.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_analyse.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_operations.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_geom.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_astrophys.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_numeric.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_echelle.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_metaf.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_gui_boxes.tcl ]
source [ file join $audace(rep_plugin) tool spectro spcaudace spc_gui_runs.tcl ]

#--- Chargement des plugins :
#source [ file join $audace(rep_plugin) tool spectro spcaudace plugins specLhIII specLhIII.tcl ]


#--------- Lancement ---------------#

#extract_profil  $file_spectre_spatial
#spc_trace_profil ${file_spectre_spatial}.dat

#--- Amorcage d'initialisation de vecteurs pour la fonction BLT::spline qui bug :
proc spc_vectorini {} {
    blt::vector x(10) y(10) sy(10)
    for {set i 10} {$i>0} {incr i -1} { 
	set x($i-1) [expr $i*$i]
	set y($i-1) [expr sin($i*$i*$i)]
    }	
    x sort y	
    x populate sx 10
    blt::spline natural x y sx sy
}

spc_vectorini
