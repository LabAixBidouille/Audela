#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-06-16 11:01:02 robertdelmas Exp $
#

package ifneeded webcam 1.0 [ list source [ file join $dir webcam.tcl ] ]

