#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 27 mai 2006
#

package ifneeded photometry 1.0 [ list source [ file join $::audace(rep_plugin) tool photometry photometry.tcl ] ]

