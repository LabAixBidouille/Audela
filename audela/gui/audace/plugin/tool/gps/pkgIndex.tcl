#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.4 2007-09-06 17:34:00 robertdelmas Exp $
#

package ifneeded gps 3.4 [ list source [ file join $dir gps.tcl ] ]

