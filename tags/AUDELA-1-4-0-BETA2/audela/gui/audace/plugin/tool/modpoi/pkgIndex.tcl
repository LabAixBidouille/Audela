#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 21:04:59 robertdelmas Exp $
#

package ifneeded modpoi 1.0 [ list source [ file join $::audace(rep_plugin) tool modpoi modpoi_go.tcl ] ]

