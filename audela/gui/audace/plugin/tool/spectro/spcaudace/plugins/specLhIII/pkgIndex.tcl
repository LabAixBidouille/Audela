#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-01-02 16:11:13 robertdelmas Exp $
#

package ifneeded specLhIII 1.0 [ list source [ file join $::audace(rep_plugin) tool specLhIII specLhIII.tcl ] ]

