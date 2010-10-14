#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-27 06:49:06 robertdelmas Exp $
#

package ifneeded bddimages 1.0 [ list source [ file join $dir bddimages_go.tcl ] ]

