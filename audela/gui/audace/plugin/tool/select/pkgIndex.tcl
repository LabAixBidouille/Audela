#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2009-02-07 10:54:37 robertdelmas Exp $
#

package ifneeded select 1.0 [ list source [ file join $dir select.tcl ] ]
