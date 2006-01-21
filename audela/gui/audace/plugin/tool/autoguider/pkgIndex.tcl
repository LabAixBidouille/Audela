#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 28 mars 2005
#

package ifneeded autoguider 1.0 [ list source [ file join $::audace(rep_plugin) tool autoguider autoguider.tcl ] ]

