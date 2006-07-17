#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 22:01:28 robertdelmas Exp $
#

package ifneeded visio 2.6 [ list source [ file join $::audace(rep_plugin) tool visio visio.tcl ] ]

