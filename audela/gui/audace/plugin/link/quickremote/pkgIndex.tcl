#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-01-13 21:13:50 robertdelmas Exp $
#

package ifneeded quickremote 1.1 [ list source [ file join $::audace(rep_plugin) link quickremote quickremote.tcl ] ]

