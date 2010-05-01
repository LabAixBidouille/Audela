#
# Fichier : tutorial.tcl
# Description : Lancement du tutorial
# Auteur : Michel PUJOL
# Mise a jour $Id: tutorial.tcl,v 1.2 2010-05-01 08:11:19 robertdelmas Exp $
#

source version.tcl
set langage english
catch { source [ file join $::env(HOME) .audela langage.tcl ] }
cd ../gui/tutorial
source tuto.tcl

