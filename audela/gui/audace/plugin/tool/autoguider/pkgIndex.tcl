#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.4 2007-07-06 22:29:49 michelpujol Exp $
#

package ifneeded autoguider 1.1 [ list source [ file join $dir autoguider.tcl ] ]

