#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-01-01 11:55:17 robertdelmas Exp $
#

package ifneeded specLhIII 1.0 [ list source [ file join $::audace(rep_plugin) tool specLhIII specLhIII.tcl ] ]

