#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 28 mars 2005
#

package ifneeded acqfen 1.2 [ list source [ file join $::audace(rep_plugin) tool acqfen acqfen.tcl ] ]

