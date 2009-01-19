#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-06-17 14:05:40 robertdelmas Exp $
#

package ifneeded kitty 1.0 [ list source [ file join $dir kitty.tcl ] ]

