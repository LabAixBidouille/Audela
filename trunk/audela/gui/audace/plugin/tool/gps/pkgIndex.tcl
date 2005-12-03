#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 28 mars 2005
#

package ifneeded gps 3.3 [ list source [ file join $::audace(rep_plugin) tool gps gps.tcl ] ]

