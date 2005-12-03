#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 03 septembre 2005
#

package ifneeded vo_tools 1.0 [ list source [ file join $::audace(rep_plugin) tool vo_tools vo_tools_go.tcl ] ]

