#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.3 2007-01-31 22:43:12 michelpujol Exp $
#

package ifneeded bermasaude 1.0 [ list source [ file join $::audace(rep_plugin) equipment bermasaude bermasaude.tcl ] ]
#--- je retourne le namespace du plugin
return "bermasaude"
