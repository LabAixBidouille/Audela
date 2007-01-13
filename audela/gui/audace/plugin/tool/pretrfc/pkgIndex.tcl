#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-01-13 21:14:15 robertdelmas Exp $
#

package ifneeded pretrfc 1.40 [ list source [ file join $::audace(rep_plugin) tool pretrfc pretrfc.tcl ] ]

