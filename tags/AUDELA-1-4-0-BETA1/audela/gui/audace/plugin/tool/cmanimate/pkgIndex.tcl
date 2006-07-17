#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 20:51:51 robertdelmas Exp $
#

package ifneeded cmanimate 1.0 [ list source [ file join $::audace(rep_plugin) tool cmanimate cmanimate.tcl ] ]

