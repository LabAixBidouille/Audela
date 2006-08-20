#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Date de mise a jour : 20 aout 2006
#

package ifneeded spectro 1.0 [ list source [ file join $::audace(rep_plugin) tool spectro spectro.tcl ] ]

