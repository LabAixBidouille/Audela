#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-25 21:20:30 robertdelmas Exp $
#

package ifneeded select 1.0 [ list source [ file join $dir select.tcl ] ]

