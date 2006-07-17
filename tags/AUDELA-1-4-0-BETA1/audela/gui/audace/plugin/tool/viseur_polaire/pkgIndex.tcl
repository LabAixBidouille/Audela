#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.2 2006-06-20 22:01:17 robertdelmas Exp $
#

package ifneeded viseur_polaire 1.0 [ list source [ file join $::audace(rep_plugin) tool viseur_polaire \
   viseur_polaire_go.tcl ] ]

