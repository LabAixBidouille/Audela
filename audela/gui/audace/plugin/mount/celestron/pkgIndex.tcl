#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-23 15:46:11 robertdelmas Exp $
#

package ifneeded celestron 1.0 [ list source [ file join $dir celestron.tcl ] ]

