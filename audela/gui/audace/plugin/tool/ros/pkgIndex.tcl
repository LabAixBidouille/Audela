#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.1 2011-02-19 20:43:49 fredvachier Exp $
#

package ifneeded ros 1.0 [ list source [ file join $dir ros_go.tcl ] ]

