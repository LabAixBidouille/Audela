#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id$
#

package ifneeded serialport 2.0 [ list source [ file join $dir serialport.tcl ] ]

