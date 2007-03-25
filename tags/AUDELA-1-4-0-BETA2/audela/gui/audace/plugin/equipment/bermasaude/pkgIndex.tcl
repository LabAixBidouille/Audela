#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.4 2007-02-07 18:55:53 robertdelmas Exp $
#

package ifneeded bermasaude 1.0 [ list source [ file join $::audace(rep_plugin) equipment bermasaude bermasaude.tcl ] ]
#--- je retourne le namespace du plugin
return "bermasaude"

