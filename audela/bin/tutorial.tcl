#
# Fichier : tutorial.tcl
# Description : Lancement du tutorial
# Auteur : Michel PUJOL
# Mise à jour $Id: tutorial.tcl,v 1.3 2010-05-13 17:40:02 robertdelmas Exp $
#

#--- Prise en compte du codage UTF8
encoding system utf-8

#---
source version.tcl
set langage english
catch { source [ file join $::env(HOME) .audela langage.ini ] }
cd ../gui/tutorial
source tuto.tcl

