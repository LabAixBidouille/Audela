#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.6 2008-12-14 13:45:45 jacquesmichelet Exp $
#

package ifneeded gps 3.6 [ list source [ file join $dir gps.tcl ] ]

