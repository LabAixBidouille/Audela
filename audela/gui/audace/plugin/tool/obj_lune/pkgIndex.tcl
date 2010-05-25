#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-25 17:49:27 robertdelmas Exp $
#

package ifneeded obj_lune 1.0 [ list source [ file join $dir obj_lune_go.tcl ] ]

