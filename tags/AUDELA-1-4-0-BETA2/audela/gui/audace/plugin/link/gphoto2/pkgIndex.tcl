#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 19:23:54 robertdelmas Exp $
#

package ifneeded gphoto2 1.0 [ list source [ file join $::audace(rep_plugin) link gphoto2 gphoto2.tcl ] ]

