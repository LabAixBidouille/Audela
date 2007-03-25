#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 20:36:32 robertdelmas Exp $
#

package ifneeded acqcolor 1.0 [ list source [ file join $::audace(rep_plugin) tool acqcolor acqcolor_go.tcl ] ]

