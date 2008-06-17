#
# Fichier : help.tcl
# Description : Aide d'Aud'ACE
# Auteur : Michel PUJOL
# Mise a jour $Id: help.tcl,v 1.5 2007-09-01 11:13:42 robertdelmas Exp $
#

###########################################################################################
# namespace audace
#
#   ::audace::showHelpItem    affiche l'aide sur un sujet hors plugin
#   ::audace::showHelpPlugin  affiche l'aide sur un plugin
#
#   ::audace::showMain        affiche la page d'accueil de l'aide
#   ::audace::showFunctions   affiche la page de l'inventaire des fonctions du logiciel
#
##########################################################################################

global help

#--- sous-repertoires de l'aide (par langue)
set help(dir,intro)         "01presentation"
set help(dir,prog)          "02programming"
set help(dir,fichier)       "03file"
set help(dir,affichage)     "04view"
set help(dir,pretrait)      "05preprocessing"
set help(dir,trait)         "06processing"
set help(dir,analyse)       "07analysis"
set help(dir,tool)          "08tools"
set help(dir,config)        "09setup/01audace"
set help(dir,camera)        "09setup/02camera"
set help(dir,telescope)     "09setup/03mount"
set help(dir,optic)         "09setup/04optic"
set help(dir,equipment)     "09setup/05equipment"
set help(dir,pad)           "09setup/06pad"
set help(dir,chart)         "09setup/07chart"
set help(dir,aide)          "10help"
set help(dir,divers)        "11misc"

# *************** Version française ***************************
if { [ string compare $langage "french" ] == "0" } {
   set help(dir,intro)      "01presentation"
   set help(dir,prog)       "02programmation"
   set help(dir,fichier)    "03fichier"
   set help(dir,affichage)  "04affichage"
   set help(dir,pretrait)   "05pretraitement"
   set help(dir,trait)      "06traitement"
   set help(dir,analyse)    "07analyse"
   set help(dir,tool)       "08outils"
   set help(dir,config)     "09configuration/01audace"
   set help(dir,camera)     "09configuration/02camera"
   set help(dir,telescope)  "09configuration/03monture"
   set help(dir,optic)      "09configuration/04optique"
   set help(dir,equipment)  "09configuration/05equipement"
   set help(dir,pad)        "09configuration/06raquette"
   set help(dir,chart)      "09configuration/07carte"
   set help(dir,aide)       "10aide"
   set help(dir,divers)     "11divers"
}

namespace eval ::audace {

   #----------------------------------------------------------------------------------------
   #  ::audace::showHelpItem
   #
   #  ouvre la fenetre d'aide si elle n'est pas deja ouverte
   #  puis affiche la page HTML demandee
   #
   #  parametres :
   #     relativeFileName : repertoire du fichier d'aide
   #     tag              : balise anchor dans la page HTML (optionel)
   #
   #  exemple : ::audace::showHelpItem "$help(dir,affichage)" "1090selection_images.htm"
   #----------------------------------------------------------------------------------------
   proc ::audace::showHelpItem { { folderRelativeFileName "" } { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $relativeFileName != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(rep_doc_html) $audace(help_langage) \
            $folderRelativeFileName $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }

   #----------------------------------------------------------------------------------------
   #  ::audace::showHelpPlugin
   #
   #  ouvre la fenetre d'aide si elle n'est pas deja ouverte
   #  puis affiche la page HTML demandee
   #
   #  parametres :
   #     relativeFileName : repertoire du fichier d'aide
   #     tag              : balise anchor dans la page HTML (optionel)
   #
   #  exemple : ::audace::showHelpPlugin tool supernovae supernovae.htm
   #----------------------------------------------------------------------------------------
   proc ::audace::showHelpPlugin { { pluginType } { pluginName } { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $relativeFileName != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(rep_plugin) $pluginType $pluginName \
            $audace(help_langage) $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }

   #----------------------------------------------------------------------------------------
   #  ::audace::showHelpScript
   #
   #  affiche l'aide d'un script quelconque
   #  le fichier d'aide doit etre dans le repertoire
   #  scriptDirectory/langage/xxx.htm
   #
   #  parametres :
   #     scriptDirectory : repertoire du fichier d'aide
   #     relativeFileName : nom du fichier d'aide
   #     tag             : balise anchor dans la page HTML (optionel)
   #
   #  exemple : ::audace::showHelpScript $audace(rep_script) testaudela.htm
   #----------------------------------------------------------------------------------------
   proc ::audace::showHelpScript { scriptDirectory  { relativeFileName "" } { tag "" } } {
      global audace help

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      } else {
         if { [ winfo exists $audace(base).help ] } {
            wm deiconify $audace(base).help
         }
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      if { $scriptDirectory != "" } {
         #--- J'affiche le fichier d'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $scriptDirectory \
            $audace(help_langage) $relativeFileName ] 1 $tag
      } else {
         #--- Si le nom du fichier est absent, j'affiche le sommaire de l'aide
         ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
            "1010presentation.htm" ] 1 ""
      }

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   #  ::audace::showMain
   #
   #  ouvre la fenetre du sommaire de l'aide
   #------------------------------------------------------------
   proc ::audace::showMain { } {
      global audace help

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,intro) \
         "1010presentation.htm" ] 1 ""

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   #  ::audace::showFunctions
   #
   #  ouvre la fenetre de l'inventaire des fonctions
   #------------------------------------------------------------
   proc ::audace::showFunctions { } {
      global audace help

      #--- J'affiche la fenetre si ce n'est pas deja fait
      if { ! [ info exists audace(help_window) ] || ! [ winfo exists $audace(help_window) ] } {
         ::audace::initHelp
      }

      if { [ winfo exists $audace(base).help ] } {
         wm deiconify $audace(base).help
      }

      #--- J'attends que la fenetre d'aide soit creee
      update

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,prog) "interfa5c.htm" ] 1 ""

      #--- Focus
      focus $audace(help_window)

   }

   #------------------------------------------------------------
   #  ::audace::initHelp
   #  initalise l'acces au repertoire d'aide
   #
   #  cree les variables audace(help_dir) et audace(help_window)
   #------------------------------------------------------------
   proc ::audace::initHelp { } {
      global audace caption langage

      #--- Je verifie que les packages necessaires sont la
      package require helpviewer

      #--- Je prepare le nom du repertoire de l'aide en fonction de la langue
      if { ( $langage != "french" ) && ( $langage != "english" ) } {
         set audace(help_langage) "english"
      } else {
         set audace(help_langage) $langage
      }
      set audace(help_dir) [ file join $audace(rep_doc_html) $audace(help_langage) ]

      if { ! [ file exists $audace(help_dir) ] } {
         set message "$caption(audace,pas_repertoire_aide)\n$audace(help_dir)"
         ::console::affiche_erreur "$message \n"
         tk_messageBox -icon error -message $message -type ok
         return
      }

      #--- Je cree la fenetre d'aide
      set audace(help_window) [ ::HelpViewer::HelpWindow $audace(help_dir) "$audace(base).help" \
         "630x450+100+50" "$caption(audace,aide)" ]

      #--- J'attends que la fenetre d'aide soit creee
      update

      #--- Focus
      focus $audace(help_window)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).help <Key-F1> { ::console::GiveFocus }

   }

}

