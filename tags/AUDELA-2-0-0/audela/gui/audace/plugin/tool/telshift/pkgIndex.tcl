#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-26 05:33:35 robertdelmas Exp $
#

package ifneeded telshift 1.0 [ list source [ file join $dir telshift_go.tcl ] ]

