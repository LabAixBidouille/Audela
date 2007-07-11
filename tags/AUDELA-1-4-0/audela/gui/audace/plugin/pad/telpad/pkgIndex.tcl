#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-04-11 17:32:43 michelpujol Exp $
#

package ifneeded telpad 1.0 [ list source [ file join $dir telpad.tcl ] ]

