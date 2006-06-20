#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 21:03:31 robertdelmas Exp $
#

package ifneeded methking 1.14 [ list source [ file join $::audace(rep_plugin) tool methking methking.tcl ] ]

