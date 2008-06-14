#****************************************************************************#
#                                                                            #
#               Fonctions d'acces et d'execution d'outils exterieus          #
#                                                                            #
#****************************************************************************#

# Mise a jour $Id: spc_external.tcl,v 1.1 2008-06-14 16:36:20 bmauclaire Exp $



###############################################################################
# Procédure de lancement du navigateur internet pour consulter la documentation d'SpcAudace
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-08-2006
# Date de mise à jour : 28-08-2006
################################################################################

proc spc_help {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	if { [ file exists $spcaudace(spcdoc) ] } {
	    set answer [ catch { exec $conf(editsite_htm) $spcaudace(spcdoc) & } ]
	} else {
	    set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitedoc) & } ]
	}
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#


###############################################################################
# Procédure de lancement du navigateur internet pour consulter le site d'SpcAudACE
# Auteur : Benjamin MAUCLAIRE
# Date création :  02-02-2008
# Date de mise à jour : 02-02-2008
################################################################################

proc spc_webpage {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(webpage) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#



###############################################################################
# Procédure de lancement du navigateur internet pour consulter la base UVES
# Auteur : Benjamin MAUCLAIRE
# Date création :  23-04-2007
# Date de mise à jour : 23-04-2007
################################################################################

proc spc_bess {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitebess) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#




###############################################################################
# Procédure de lancement du navigateur internet pour consulter la base UVES
# Auteur : Benjamin MAUCLAIRE
# Date création :  23-04-2007
# Date de mise à jour : 23-04-2007
################################################################################

proc spc_uves {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(siteuves) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#



###############################################################################
# Procédure de lancement du navigateur internet pour consulter la base UVES
# Auteur : Benjamin MAUCLAIRE
# Date création :  24-04-2007
# Date de mise à jour : 24-04-2007
################################################################################

proc spc_simbad {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitesimbad) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#



###############################################################################
# Procédure de lancement du navigateur internet pour consulter la base UVES
# Auteur : Benjamin MAUCLAIRE
# Date création :  24-04-2007
# Date de mise à jour : 24-04-2007
################################################################################

proc spc_surveys {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitesurveys) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#



###############################################################################
# Procédure de lancement du navigateur internet pour consulter la base UVES
# Auteur : Benjamin MAUCLAIRE
# Date création :  24-04-2007
# Date de mise à jour : 24-04-2007
################################################################################

proc spc_bebuil {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitebebuil) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#



###############################################################################
# Procédure de lancement du logiciel SPECTRUM
# Auteur : Benjamin MAUCLAIRE
# Date création :  23-04-2007
# Date de mise à jour : 23-04-2007
################################################################################

proc spc_spectrum {} {

    global spcaudace conf tcl_platform

    if { $tcl_platform(os)=="Linux" } {	
	#set answer [ catch { exec xterm -r -e $spcaudace(spectrum)/spectrum & } ]
	set answer [ catch { exec $spcaudace(spectrum)/spectrum_sh.tcl & } ]
	::console::affiche_resultat "$answer\n"
    } else {
	set answer [ catch { exec $spcaudace(spectrum)/setup.exe & } ]
	::console::affiche_resultat "$answer\n"
    }
}
#*********************************************************#
