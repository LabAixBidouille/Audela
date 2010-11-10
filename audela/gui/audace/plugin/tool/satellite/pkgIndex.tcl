#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.1 2010-11-10 21:51:19 robertdelmas Exp $
#

package ifneeded satellite 1.0 [ list source [ file join $dir satellite.tcl ] ]

