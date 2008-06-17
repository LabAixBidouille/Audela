#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-04-07 00:38:34 robertdelmas Exp $
#

package ifneeded obj_lune 1.0 [ list source [ file join $dir obj_lune_go.tcl ] ]

