#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 17 octobre 2004
#

package ifneeded acqcolor 1.0 [ list source [ file join $::audace(rep_plugin) tool acqcolor acqcolor_go.tcl ] ]

