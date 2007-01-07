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

## Fonctions généralistes

###############################################################################
#
# Description : se met dans le répertoire de travail d'Audace pour éviter de 
#  mettre le chemin des images devant chaque image
# Auteur : Benjamin MAUCLAIRE
# Date création : 17-12-2005
# Date de mise à jour : 17-12-2005
# Arguments : aucun
###############################################################################

proc spc_goodrep {} {
   global audace

   set repdflt [pwd]
   cd $audace(rep_images)
   return $repdflt
}

#--- Démarrage de SpcAudace :
if { [regexp {1.3.0} $audela(version) match resu ] } {
   set repertoire [ file join $audace(rep_scripts) spcaudace ]
   #--- Chargement de l'éditeur de profil :
   source [ file join $repertoire spc_ini.tcl ]
   source [ file join $repertoire spc_gui.tcl ]
} else {
   set repertoire [ file join $audace(rep_plugin) tool spectro spcaudace ]
}

#--- Chargement des fonctionnalités :
source [ file join $repertoire spc_io.tcl ]
source [ file join $repertoire spc_profil.tcl ]
source [ file join $repertoire spc_calibrage.tcl ]
source [ file join $repertoire spc_analyse.tcl ]
source [ file join $repertoire spc_operations.tcl ]
source [ file join $repertoire spc_geom.tcl ]
source [ file join $repertoire spc_astrophys.tcl ]
source [ file join $repertoire spc_numeric.tcl ]
source [ file join $repertoire spc_echelle.tcl ]
source [ file join $repertoire spc_metaf.tcl ]
source [ file join $repertoire spc_gui_boxes.tcl ]
source [ file join $repertoire spc_gui_runs.tcl ]
source [ file join $repertoire spc_var.tcl ]

#--- Chargement des plugins Spcaudace :
source [ file join $repertoire plugins specLhIII specLhIII.tcl ]


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
#*********************************************************#

