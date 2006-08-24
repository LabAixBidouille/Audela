#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-08-24 21:52:28 robertdelmas Exp $
#

package ifneeded photometry 1.0 [ list source [ file join $::audace(rep_plugin) tool photometry photometry.tcl ] ]

