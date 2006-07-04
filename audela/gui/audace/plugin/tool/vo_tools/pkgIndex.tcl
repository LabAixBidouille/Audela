#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-07-04 22:14:40 robertdelmas Exp $
#

package ifneeded vo_tools 1.0 [ list source [ file join $::audace(rep_plugin) tool vo_tools vo_tools_go.tcl ] ]

