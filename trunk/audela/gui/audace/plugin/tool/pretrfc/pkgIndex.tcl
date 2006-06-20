#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 21:19:34 robertdelmas Exp $
#

package ifneeded pretrfc 1.38 [ list source [ file join $::audace(rep_plugin) tool pretrfc pretrfc.tcl ] ]

