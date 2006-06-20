#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 21:11:01 robertdelmas Exp $
#

package ifneeded obj_lune 1.0 [ list source [ file join $::audace(rep_plugin) tool obj_lune obj_lune_go.tcl ] ]

