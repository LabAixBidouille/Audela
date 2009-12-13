#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2009-12-13 17:25:37 michelpujol Exp $
#

package ifneeded displaycoord 1.0 [ list source [ file join $dir displaycoord.tcl ] ]

