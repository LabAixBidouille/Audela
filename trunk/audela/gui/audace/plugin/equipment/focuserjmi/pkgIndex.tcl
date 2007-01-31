#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-01-31 22:46:50 michelpujol Exp $
#

package ifneeded focuserjmi 1.0 [ list source [ file join $::audace(rep_plugin) equipment focuserjmi focuserjmi.tcl ] ]
#--- je retourne le namespace du plugin
return "focuserjmi"