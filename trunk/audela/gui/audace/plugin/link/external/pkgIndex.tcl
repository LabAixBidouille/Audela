#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2006-08-12 21:03:58 robertdelmas Exp $
#

package ifneeded external 1.0 [ list source [ file join $::audace(rep_plugin) link external external.tcl ] ]

