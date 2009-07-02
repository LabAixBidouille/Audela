#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2009-07-02 22:46:15 jberthier Exp $
#

package ifneeded bddimages 1.0 [ list source [ file join $dir bddimages_go.tcl ] ]

