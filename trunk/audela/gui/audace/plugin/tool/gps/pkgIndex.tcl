#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.9 2010-05-25 17:12:08 robertdelmas Exp $
#

package ifneeded gps 3.8 [ list source [ file join $dir gps.tcl ] ]

