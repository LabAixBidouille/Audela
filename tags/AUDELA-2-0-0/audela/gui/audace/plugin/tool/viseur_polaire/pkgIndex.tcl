#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-26 05:45:00 robertdelmas Exp $
#

package ifneeded viseur_polaire 1.0 [ list source [ file join $dir viseur_polaire_go.tcl ] ]

