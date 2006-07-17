#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 20:44:46 robertdelmas Exp $
#

package ifneeded acqfen 1.2 [ list source [ file join $::audace(rep_plugin) tool acqfen acqfen.tcl ] ]

