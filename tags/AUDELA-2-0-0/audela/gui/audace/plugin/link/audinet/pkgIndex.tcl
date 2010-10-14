#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise à jour $Id: pkgIndex.tcl,v 1.4 2010-05-22 16:53:28 robertdelmas Exp $
#

package ifneeded audinet 1.0 [ list source [ file join $dir audinet.tcl ] ]

