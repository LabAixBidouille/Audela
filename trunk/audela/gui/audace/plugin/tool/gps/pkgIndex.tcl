#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.7 2010-03-23 08:56:54 jacquesmichelet Exp $
#

package ifneeded gps 3.7 [ list source [ file join $dir gps.tcl ] ]

