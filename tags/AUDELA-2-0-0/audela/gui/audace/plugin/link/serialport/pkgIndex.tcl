#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-22 17:08:22 robertdelmas Exp $
#

package ifneeded serialport 1.0 [ list source [ file join $dir serialport.tcl ] ]

