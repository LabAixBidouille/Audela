#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 20:41:33 robertdelmas Exp $
#

package ifneeded acqfc 2.1 [ list source [ file join $::audace(rep_plugin) tool acqfc acqfc.tcl ] ]

