#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-04-07 00:38:36 robertdelmas Exp $
#

package ifneeded telshift 1.0 [ list source [ file join $dir telshift_go.tcl ] ]

