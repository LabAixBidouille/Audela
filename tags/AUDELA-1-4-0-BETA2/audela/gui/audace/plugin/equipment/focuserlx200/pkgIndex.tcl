#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2007-02-07 18:56:34 robertdelmas Exp $
#

package ifneeded focuserlx200 1.0 [ list source [ file join $::audace(rep_plugin) equipment focuserlx200 focuserlx200.tcl ] ]
#--- je retourne le namespace du plugin
return "focuserlx200"
