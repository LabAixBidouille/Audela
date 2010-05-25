#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-25 21:18:22 robertdelmas Exp $
#

package ifneeded scan 1.0 [ list source [ file join $dir scan.tcl ] ]

