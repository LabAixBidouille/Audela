#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-22 17:52:35 robertdelmas Exp $
#

package ifneeded kitty 1.0 [ list source [ file join $dir kitty.tcl ] ]

