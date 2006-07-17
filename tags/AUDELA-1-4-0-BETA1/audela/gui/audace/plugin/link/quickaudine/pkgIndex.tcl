#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 19:24:40 robertdelmas Exp $
#

package ifneeded quickaudine 1.0 [ list source [ file join $::audace(rep_plugin) link quickaudine quickaudine.tcl ] ]

