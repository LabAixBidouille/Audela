#
# Fichier : help.tcl
# Description : Aide d'Aud'ACE
# Auteur : Michel PUJOL
# Mise à jour $Id: help.tcl,v 1.12 2011-01-09 10:27:48 robertdelmas Exp $
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
set help(dir,images)        "05images"
set help(dir,analyse)       "07analysis"
set help(dir,cameras)       "08camera"
set help(dir,telescopes)    "09telescope"
set help(dir,config)        "10setup/01audace"
set help(dir,camera)        "10setup/02camera"
set help(dir,mount)         "10setup/03mount"
set help(dir,optic)         "10setup/04optic"
set help(dir,equipment)     "10setup/05equipment"
set help(dir,pad)           "10setup/06pad"
set help(dir,chart)         "10setup/07chart"
set help(dir,config+)       "10setup"
set help(dir,aide)          "11help"
set help(dir,divers)        "12misc"

# *************** Version française ***************************
if { [ string compare $langage "french" ] == "0" } {
   set help(dir,intro)      "01presentation"
   set help(dir,prog)       "02programmation"
   set help(dir,fichier)    "03fichier"
   set help(dir,affichage)  "04affichage"
   set help(dir,images)     "05images"
   set help(dir,analyse)    "07analyse"
   set help(dir,cameras)    "08camera"
   set help(dir,telescopes) "09telescope"
   set help(dir,config)     "10configuration/01audace"
   set help(dir,camera)     "10configuration/02camera"
   set help(dir,mount)      "10configuration/03monture"
   set help(dir,optic)      "10configuration/04optique"
   set help(dir,equipment)  "10configuration/05equipement"
   set help(dir,pad)        "10configuration/06raquette"
   set help(dir,chart)      "10configuration/07carte"
   set help(dir,config+)    "10configuration"
   set help(dir,aide)       "11aide"
   set help(dir,divers)     "12divers"
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
   #  exemple : ::audace::showHelpItem "$help(dir,prog)" "ttus1-fr.htm" "ADD"
   #  note : ne pas rajouter # devant item, il est rajoute automatiquement
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
   #  exemple : ::audace::showHelpScript $audace(rep_scripts) testaudela.htm
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
   #  ::audace::showMenus
   #
   #  ouvre la fenetre de l'inventaire des menus
   #------------------------------------------------------------
   proc ::audace::showMenus { } {
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

      ::HelpViewer::LoadFile $audace(help_window) [ file join $audace(help_dir) $help(dir,aide) "1020menus.htm" ] 1 ""

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

