#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-01-13 21:14:29 robertdelmas Exp $
#

package ifneeded visio 2.6.2 [ list source [ file join $::audace(rep_plugin) tool visio visio.tcl ] ]

