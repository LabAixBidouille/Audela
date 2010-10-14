#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-25 16:47:17 robertdelmas Exp $
#

package ifneeded displaycoord 1.0 [ list source [ file join $dir displaycoord.tcl ] ]

