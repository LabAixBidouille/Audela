#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl 7548 2011-08-20 08:07:36Z robertdelmas  $
#

package ifneeded acqfast 1.0 [ list source [ file join $dir acqfast.tcl ] ]

