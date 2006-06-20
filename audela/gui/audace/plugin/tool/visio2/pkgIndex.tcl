#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 22:02:07 robertdelmas Exp $
#

package ifneeded visio2 1.0 [ list source [ file join $::audace(rep_plugin) tool visio2 visio2.tcl ] ]

