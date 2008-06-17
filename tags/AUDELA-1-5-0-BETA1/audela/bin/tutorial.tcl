#
# Fichier : tutorial.tcl
# Description : Lancement du tutorial
# Auteur : Michel PUJOL
# Mise a jour $Id: tutorial.tcl,v 1.1 2008-04-26 11:03:05 robertdelmas Exp $
#

source version.tcl
set langage english
catch { source langage.tcl }
cd ../gui/tutorial
source tuto.tcl

