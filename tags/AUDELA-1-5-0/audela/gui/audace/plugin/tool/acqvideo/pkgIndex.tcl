#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2008-04-17 20:39:34 robertdelmas Exp $
#

package ifneeded acqvideo 1.0 [ list source [ file join $dir acqvideo.tcl ] ]

