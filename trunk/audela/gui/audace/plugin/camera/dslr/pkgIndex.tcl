#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.2 2010-05-22 17:30:38 robertdelmas Exp $
#

package ifneeded dslr 1.0 [ list source [ file join $dir dslr.tcl ] ]

