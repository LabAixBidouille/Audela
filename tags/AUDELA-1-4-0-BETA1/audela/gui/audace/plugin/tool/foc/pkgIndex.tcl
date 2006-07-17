#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 20:56:02 robertdelmas Exp $
#

package ifneeded foc 1.0 [ list source [ file join $::audace(rep_plugin) tool foc foc.tcl ] ]

