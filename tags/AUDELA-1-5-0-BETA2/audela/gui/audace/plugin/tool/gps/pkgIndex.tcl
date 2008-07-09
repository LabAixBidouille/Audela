#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.5 2008-01-20 19:12:38 jacquesmichelet Exp $
#

package ifneeded gps 3.5 [ list source [ file join $dir gps.tcl ] ]

