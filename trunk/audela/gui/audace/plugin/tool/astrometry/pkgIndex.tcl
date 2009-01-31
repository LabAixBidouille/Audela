#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2009-01-31 08:20:11 robertdelmas Exp $
#

package ifneeded astrometry 1.0 [ list source [ file join $dir astrometry.tcl ] ]

