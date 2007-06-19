#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-06-19 20:13:55 robertdelmas Exp $
#

package ifneeded celestron 1.0 [ list source [ file join $dir celestron.tcl ] ]

