#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-04-07 00:35:18 michelpujol Exp $
#

package ifneeded photopc 1.0 [ list source [ file join $dir photopc.tcl ] ]

