#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-17 15:57:04 robertdelmas Exp $
#

package ifneeded telpad 1.0 [ list source [ file join $dir telpad.tcl ] ]

