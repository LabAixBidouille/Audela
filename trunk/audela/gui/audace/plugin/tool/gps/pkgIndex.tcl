#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.8 2010-04-30 08:32:56 jacquesmichelet Exp $
#

package ifneeded gps 3.8 [ list source [ file join $dir gps.tcl ] ]

