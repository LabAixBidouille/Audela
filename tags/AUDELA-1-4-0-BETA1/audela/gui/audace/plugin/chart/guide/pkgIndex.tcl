#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 18:32:05 robertdelmas Exp $
#

package ifneeded guide 1.0 [ list source [ file join $::audace(rep_plugin) chart guide guide.tcl ] ]

