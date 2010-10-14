#
# Fichier : tutorial.tcl
# Description : Lancement du tutorial
# Auteur : Michel PUJOL
# Mise à jour $Id: tutorial.tcl,v 1.4 2010-05-18 16:30:59 robertdelmas Exp $
#

#--- Prise en compte du codage UTF8
encoding system utf-8

#---
source version.tcl
#--- Prise en compte de la langue
set langage english
if { $::tcl_platform(platform) == "unix" } {
   set repHome [ file join $::env(HOME) .audela ]
} else {
   set applicationData [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" AppData ]
   set repHome [ file normalize [ file join $applicationData AudeLA ] ]
}
catch { source [ file join $repHome langage.ini ] }

#--- Lancement du tutorial
cd ../gui/tutorial
source tuto.tcl
return

