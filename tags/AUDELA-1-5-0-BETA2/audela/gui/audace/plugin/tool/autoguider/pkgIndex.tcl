#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.5 2007-09-14 13:38:11 michelpujol Exp $
#

package ifneeded autoguider 1.2 [ list source [ file join $dir autoguider.tcl ] ]

