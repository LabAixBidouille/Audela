#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 01 fevrier 2006
#

package ifneeded photopc 1.0 [ list source [ file join $::audace(rep_plugin) link photopc photopc.tcl ] ]

