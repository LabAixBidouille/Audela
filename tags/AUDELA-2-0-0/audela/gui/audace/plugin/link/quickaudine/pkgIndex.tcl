#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-22 16:54:44 robertdelmas Exp $
#

package ifneeded quickaudine 1.0 [ list source [ file join $dir quickaudine.tcl ] ]
