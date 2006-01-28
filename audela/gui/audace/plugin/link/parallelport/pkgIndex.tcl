#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 24 janvier 2006
#

package ifneeded parallelport 1.0 [ list source [ file join $::audace(rep_plugin) link parallelport parallelport.tcl ] ]

