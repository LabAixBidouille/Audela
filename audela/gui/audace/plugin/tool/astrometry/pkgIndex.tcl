#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-24 15:16:16 robertdelmas Exp $
#

package ifneeded astrometry 1.0 [ list source [ file join $dir astrometry.tcl ] ]

