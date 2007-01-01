#
# Fichier : spectro_accesBeSS.tcl
# Description : Lancement du script pour generer un fichier FITS de spectre conforme a la base de donnees bess
# Auteur : Alain Klotz
# Mise a jour $Id: spectro_accesBeSS.tcl,v 1.6 2007-01-01 16:45:03 robertdelmas Exp $
#

global audace

source [ file join $audace(rep_plugin) tool spectro spcaudace plugins bess_module bess_module.tcl ]

