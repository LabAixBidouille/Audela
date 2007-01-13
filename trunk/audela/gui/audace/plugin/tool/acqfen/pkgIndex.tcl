#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-01-13 21:14:02 robertdelmas Exp $
#

package ifneeded acqfen 1.2.1 [ list source [ file join $::audace(rep_plugin) tool acqfen acqfen.tcl ] ]

