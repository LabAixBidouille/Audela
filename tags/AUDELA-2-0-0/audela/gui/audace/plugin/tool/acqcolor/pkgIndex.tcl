#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-25 16:36:35 robertdelmas Exp $
#

package ifneeded acqcolor 1.0 [ list source [ file join $dir acqcolor_go.tcl ] ]

