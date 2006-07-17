#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 21:00:40 robertdelmas Exp $
#

package ifneeded gps 3.3 [ list source [ file join $::audace(rep_plugin) tool gps gps.tcl ] ]

