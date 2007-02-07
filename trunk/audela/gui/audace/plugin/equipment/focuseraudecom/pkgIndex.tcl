#
# Fichier : pkgIndex.tcl
# Description : Definition du point d'entree du plugin
# Mise a jour $Id: pkgIndex.tcl,v 1.1 2007-02-07 20:39:05 robertdelmas Exp $
#

package ifneeded focuseraudecom 1.0 [ list source [ file join $::audace(rep_plugin) equipment focuseraudecom focuseraudecom.tcl ] ]
#--- je retourne le namespace du plugin
return "focuseraudecom"

