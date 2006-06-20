#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 20:46:01 robertdelmas Exp $
#

package ifneeded animate 1.0 [ list source [ file join $::audace(rep_plugin) tool animate animate.tcl ] ]

