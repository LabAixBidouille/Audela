#****************************************************************************#
#                                                                            #
#               Fonctions d'acces et d'execution d'outils exterieus          #
#                                                                            #
#****************************************************************************#

# Mise a jour $Id$


####################################################################
# Construit la liste des noms generiques des series dans le repertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20120808
# Date modification : 20120808
####################################################################

proc spc_nomsgeneriques {} {
   global audace
   set liste_noms_generiques [ liste_series ]
   if { [ glob -nocomplain -tail -dir $audace(rep_images) *smd* ]!="" } {
      set liste_additif [ glob *smd* ]
      foreach newfile $liste_additif { lappend liste_noms_generiques $newfile }
   }
   set liste_noms_generiques [ lsort -dictionary $liste_noms_generiques ]
   return $liste_noms_generiques
}



####################################################################
# Compare la version d'SpcAduace en cours d'execution et averti de la maj
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20120201
# Date modification : 20120201
####################################################################

proc spc_versionsite {} {
   global spcaudace flagvs_ok audace

   #--- Teste si la verification a deja ete effectuee :
   if { $spcaudace(flag_verifversion) } { return "" }

   #--- Recherche la version diponible sur le site d'Spcaudace :
   set pagecontent [ spc_read_url_contents $spcaudace(webpage) ]
   set spcaudace(flag_verifversion) 1

   if { $pagecontent!=0 } {
      regexp {KIT\s:\sspcaudace\-([0-9]+\.[0-9]+)} $pagecontent match version_site

      #--- Compare avec la version en cours d'exécution et signale la maj :
      if { $spcaudace(num_version)<$version_site } {
         ::console::affiche_erreur "A newer SpcAudace release is available. You should upgrade your SpcAudace!\n"

         #-- Création de la fenêtre :
         set flagvs_ok 0
         if { [ winfo exists .spcv ] } {
            destroy .spcv
         }
         toplevel .spcv
         wm geometry .spcv
         wm title .spcv "A newer SpcAudace release is available"
         wm transient .spcv .audace
   
         #--- Textes d'avertissement
         label .spcv.lab -text "You should upgrade your SpcAudace!"
         pack .spcv.lab -expand true -expand true -fill both
   
         #--- Sous-trame pour boutons
         frame .spcv.but
         pack .spcv.but -expand true -fill both
   
         #--- Bouton "Ok"
         button .spcv.but.1 -command {set flagvs_ok 1} -text "OK"
         pack .spcv.but.1 -side left -expand true -fill both

         #--- Attend le click user :
         vwait flagvs_ok

         if { $flagvs_ok == 1 } {
	    destroy .spcv
            #return ""
         }

      } else {
         ::console::affiche_prompt "\nYour SpcAudace release is up to date.\n"
      }
   }
}
#**********************************************************************************#


####################################################################
# Lecture d'une page HTML via http
#
# Version originale : Alain KLOTZ
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20120201
# Date modification : 20120201
####################################################################

proc spc_read_url_contents { url {fullfile_out ""} } {
   package require http

   if { [ spc_test_url $url ] } {
      set token [::http::geturl $url]
      upvar #0 $token state
      set res $state(body)
      set len [string length $res]
      if {$fullfile_out!=""} {
         set f [open $fullfile_out w]
         puts -nonewline $f "$res"
         close $f
      }
      return $res
   } else {
      return 0
   }
}
#**********************************************************************************#


####################################################################
# Lecture d'une page HTML via http
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20120201
# Date modification : 20120201
####################################################################

proc spc_test_url { url } {
   package require http

   if { [ catch { ::http::geturl $url -timeout 2000 } ] } { return 0 } else {  return 1 }
}
#**********************************************************************************#


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
# Procédure de lancement du navigateur internet pour consulter le site arasbeam
# Auteur : Benjamin MAUCLAIRE
# Date création :  20-09-2008
# Date de mise à jour : 20-09-2008
################################################################################

proc spc_arasbeam {} {

    global spcaudace conf

    if { $conf(editsite_htm)!="" } {
	set answer [ catch { exec $conf(editsite_htm) $spcaudace(sitearasbeam) & } ]
    } else {
	::console::affiche_resultat "Configurer \"Editeurs/Navigateur web\" pour permettre l'affichage de la documentation d'SpcAudACE\n"
    }
}
#*********************************************************#


###############################################################################
# Procédure de lancement du navigateur internet pour consulter la base BeSS
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
# Procédure de lancement du navigateur internet pour consulter la base Simbad
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
# Procédure de lancement du navigateur internet pour consulter la page des surveys
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
# Procédure de lancement du navigateur internet pour consulter la page Be de C. Buil
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
