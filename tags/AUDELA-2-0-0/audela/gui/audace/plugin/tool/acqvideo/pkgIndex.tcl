#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-23 16:16:39 robertdelmas Exp $
#

package ifneeded acqvideo 1.0 [ list source [ file join $dir acqvideo.tcl ] ]
