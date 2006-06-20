#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 19:45:22 robertdelmas Exp $
#

package ifneeded telpad 1.0 [ list source [ file join $::audace(rep_plugin) pad telpad telpad.tcl ] ]

