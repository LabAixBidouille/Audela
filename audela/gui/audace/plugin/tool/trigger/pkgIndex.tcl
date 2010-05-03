#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.1 2010-05-03 17:55:52 robertdelmas Exp $
#

package ifneeded trigger 1.0 [ list source [ file join $dir trigger.tcl ] ]

