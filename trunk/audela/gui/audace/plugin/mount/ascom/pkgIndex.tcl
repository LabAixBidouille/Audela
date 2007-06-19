#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-06-19 20:11:51 robertdelmas Exp $
#

package ifneeded ascom 1.0 [ list source [ file join $dir ascom.tcl ] ]

