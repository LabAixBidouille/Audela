#
# Fichier : confcat.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'chart'
# Auteur : Michel PUJOL
# Mise a jour $Id: confcat.tcl,v 1.20 2007-12-02 00:06:30 robertdelmas Exp $
#

namespace eval ::confCat {
}

#------------------------------------------------------------
# ::confCat::init (est lance automatiquement au chargement de ce fichier tcl)
# initialise les variable conf(..) et caption(..)
# demarrer le plugin selectionne par defaut
#------------------------------------------------------------
proc ::confCat::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" confcat.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   if { ! [ info exists conf(confCat) ] }          { set conf(confCat)          "" }
   if { ! [ info exists conf(confCat,start) ] }    { set conf(confCat,start)    "0" }
   if { ! [ info exists conf(confCat,geometry) ] } { set conf(confCat,geometry) "490x330+130+60" }

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confcat"

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" chart]
   #--- je recherche les plugin presents
   findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(confCat)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(confCat) ""
   }
}

#------------------------------------------------------------
# ::confCat::getLabel
# retourne le titre de la fenetre dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::confCat::getLabel { } {
   global caption

   return "$caption(confcat,config)"
}

#------------------------------------------------------------
# ::confCat::run
# Affiche la fenetre de choix et de configuration
#------------------------------------------------------------
proc ::confCat::run { } {
   variable private
   global conf

   if { [createDialog ] == 0 } {
      select $conf(confCat)
      catch { tkwait visibility $private(frm) }
   }
}

#------------------------------------------------------------
# ::confCat::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
# la configuration, et fermer la fenetre de reglage
#------------------------------------------------------------
proc ::confCat::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# ::confCat::appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer'
# pour memoriser et appliquer la configuration
#------------------------------------------------------------
proc ::confCat::appliquer { } {
   variable private
   global conf

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- j'arrete le plugin precedent
   if { "$conf(confCat)" != "" } {
      #--- je detruis le plugin danc catch, au cas ou il aurait ete supprime
      #--- depuis sa derniere selections
      catch {
         $conf(confCat)::deletePluginInstance
      }
   }

   #--- je recupere le label de l'onglet selectionne
   set conf(confCat) [Rnotebook:currentName $private(frm).usr.book ]
   #--- je recupere le namespace correspondant au label
   set label "[Rnotebook:currentName $private(frm).usr.book ]"
   set index [lsearch -exact $private(pluginLabelList) $label ]
   if { $index != -1 } {
      set conf(confCat) [lindex $private(pluginNamespaceList) $index]
   } else {
      set conf(confCat) ""
   }

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach name $private(pluginNamespaceList) {
      $name\::widgetToConf
   }

   #--- je demarre le plugin selectionne
   if { $conf(confCat) != "" } {
      $conf(confCat)::createPluginInstance
   }

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
# ::confCat::afficheAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confCat::afficheAide { } {
   variable private

   #--- je recupere l'index de l'onglet selectionne
   set index [Rnotebook:currentIndex $private(frm).usr.book ]
   if { $index != -1 } {
      set selectedPluginName [lindex $private(pluginNamespaceList) [expr $index -1]]
      #--- j'affiche la documentation
      set pluginHelp [ $selectedPluginName\::getPluginHelp ]
      set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
      ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
   }
}

#------------------------------------------------------------
# ::confCat::fermer
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confCat::fermer { } {
   variable private

   ::confCat::recupPosDim
   destroy $private(frm)
}

#------------------------------------------------------------
# ::confCat::recupPosDim
# Permet de recuperer et de sauvegarder la position et la
# dimension de la fenetre de configuration de la carte
#------------------------------------------------------------
proc ::confCat::recupPosDim { } {
   variable private
   global conf

   set private(confCat,geometry) [ wm geometry $private(frm) ]
   set conf(confCat,geometry) $private(confCat,geometry)
}

#------------------------------------------------------------
# ::confCat::createDialog
# Affiche la fenetre a onglet
#
# retrun 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confCat::createDialog { } {
   variable private
   global caption conf

   #--- Je verifie qu'il y a des cartes
   if { [ llength $private(pluginNamespaceList) ] < 1 } {
      tk_messageBox -title "$caption(confcat,config)" -message "$caption(confcat,pas_carte)" -icon error
      return 1
   }

   #---
   if { [ winfo exists $private(frm) ] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      focus $private(frm)
      return 0
   }

   #---
   set private(confCat,geometry) $conf(confCat,geometry)

   toplevel $private(frm)
   wm geometry $private(frm) $private(confCat,geometry)
   wm minsize $private(frm) 490 330
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confcat,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confCat::fermer"

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set mainFrame $private(frm).usr.book

         #--- J'affiche les onglets dans la fenetre
         Rnotebook:create $mainFrame -tabs "$private(pluginLabelList)" -borderwidth 1

         #--- Je demande a chaque plugin d'afficher sa page de config
         set indexOnglet 1
         foreach name $private(pluginNamespaceList) {
            set drivername [ $name\:\:fillConfigPage [ Rnotebook:frame $mainFrame $indexOnglet ] ]
            incr indexOnglet
         }

      pack $mainFrame -fill both -expand 1

   pack $private(frm).usr -side top -fill both -expand 1

   #--- Frame du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      checkbutton $private(frm).start.chk -text "$caption(confcat,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(confCat,start)
      pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x

   pack $private(frm).start -side top -fill x

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(confcat,ok)" -relief raised -state normal -width 7 \
         -command "::confCat::ok"
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(confcat,appliquer)" -relief raised -state normal -width 8 \
         -command "::confCat::appliquer"
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(confcat,fermer)" -relief raised -state normal -width 7 \
         -command "::confCat::fermer"
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(confcat,aide)" -relief raised -state normal -width 8 \
         -command "::confCat::afficheAide"
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side top -fill x

   #---
   focus $private(frm)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private(frm) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)

   return 0
}

#------------------------------------------------------------
# ::confCat::select [label]
# Selectionne un onglet en passant le label de l'onglet decrit dans la fenetre de configuration
# Si le label est omis ou inconnu, le premier onglet est selectionne
#------------------------------------------------------------
proc ::confCat::select { { name "" } } {
   variable private

   #--- je recupere le label correspondant au namespace
   set index [ lsearch -exact $private(pluginNamespaceList) "$name" ]
   if { $index != -1 } {
      Rnotebook:select $private(frm).usr.book [ lindex $private(pluginLabelList) $index ]
   }
}

#------------------------------------------------------------
# ::confCat::configureDriver
# configure le plugin selectionne
#------------------------------------------------------------
proc ::confCat::configureDriver { } {

}

#------------------------------------------------------------
# ::confCat::createUrlLabel
# cree un widget "label" avec une URL du site WEB
#------------------------------------------------------------
proc ::confCat::createUrlLabel { tkparent title url } {
   global audace color

   label  $tkparent.labURL -text "$title" -font $audace(font,url) -fg $color(blue)
   bind   $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   bind   $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind   $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

#------------------------------------------------------------
# ::confCat::startDriver
# lance le plugin
#------------------------------------------------------------
proc ::confCat::startDriver { } {
   global conf

   if { $conf(confCat,start) == "1" } {
      ::confCat::configureDriver
   }
}

#------------------------------------------------------------
# ::confCat::stopDriver
# arrete le plugin selectionne
#
#  return rien
#------------------------------------------------------------
proc ::confCat::stopDriver { } {
   global conf

   if { "$conf(confCat)" != "" } {
      catch {
         $conf(confCat)::deletePluginInstance
      }
   }
}

#------------------------------------------------------------
# ::confCat::findPlugin
# recherche les plugins de type "chart"
#
# conditions :
#   - le plugin doit avoir une procedure getPluginType qui retourne "chart"
#   - le plugin doit avoir une procedure getPluginTitle
#   - etc.
#
# si le plugin remplit les conditions :
# son label est ajoute dans la liste pluginTitleList et son namespace est ajoute dans pluginNamespaceList
# sinon le fichier tcl est ignore car ce n'est pas un plugin
#
# return 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confCat::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers chart/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" chart * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "chart"} {
               foreach os $pluginInfo(os) {
                  if { $os == [ lindex $::tcl_platform(os) 0 ] } {
                     #--- je charge le package
                     package require $pluginInfo(name)
                     #--- j'initalise le plugin
                     $pluginInfo(namespace)::initPlugin
                     set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                     #--- je l'ajoute dans la liste des plugins
                     lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                     lappend private(pluginLabelList) $pluginlabel
                     ::console::affiche_prompt "#$caption(confcat,carte) $pluginlabel v$pluginInfo(version)\n"
                  }
               }
            }
         } else {
            ::console::affiche_erreur "Error loading cat $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confCat::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphabétique des libelles
   set pluginList ""
   for { set i 0} {$i< [llength $private(pluginLabelList)] } {incr i } {
      lappend pluginList [list [lindex $private(pluginLabelList) $i] [lindex $private(pluginNamespaceList) $i] ]
   }
   set pluginList [lsort -dictionary -index 0 $pluginList]
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   foreach plugin $pluginList {
      lappend private(pluginLabelList)     [lindex $plugin 0]
      lappend private(pluginNamespaceList) [lindex $plugin 1]
   }

   ::console::affiche_prompt "\n"

   if { [llength $private(pluginNamespaceList)] < 1 } {
      #--- aucun plugin correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#--- connexion au demarrage du plugin selectionne par defaut
::confCat::init

