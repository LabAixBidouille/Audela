#
# Fichier : confcat.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'chart'
# Auteur : Michel PUJOL
# Mise a jour $Id: confcat.tcl,v 1.25 2008-06-14 09:02:16 robertdelmas Exp $
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
   if { ! [ info exists conf(confCat,geometry) ] } { set conf(confCat,geometry) "500x350+15+15" }

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
   global caption conf

   #--- je verifie si le plugin existe dans la liste des onglets
   if { [ llength $private(pluginNamespaceList) ] > 0 } {
      ::confCat::createDialog
      set selectedPluginName "$conf(confCat)"
      if { $selectedPluginName != "" } {
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [ lsearch -exact $private(pluginNamespaceList) $selectedPluginName ] == -1 } {
            #--- si la valeur n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set selectedPluginName [ lindex $private(pluginNamespaceList) 0 ]
         }
      } else {
         set selectedPluginName [ lindex $private(pluginNamespaceList) 0 ]
      }
      selectNotebook $selectedPluginName
   } else {
      tk_messageBox -title "$caption(confcat,config)" -message "$caption(confcat,pas_carte)" -icon error
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

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le nom du plugin selectionne
   set selectedPluginName [ $private(frm).usr.onglet raise ]

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach name $private(pluginNamespaceList) {
      $name\::widgetToConf
   }

   #--- je demarre le plugin selectionne
   configurePlugin $selectedPluginName

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

   #--- j'affiche la documentation
   set selectedPluginName  [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp          [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
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

   #---
   if { [ winfo exists $private(frm) ] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      focus $private(frm)
      return 0
   }

   #---
   set private(confCat,geometry) $conf(confCat,geometry)

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(confCat,geometry)
   wm minsize $private(frm) 500 350
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confcat,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confCat::fermer"

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

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      checkbutton $private(frm).start.chk -text "$caption(confcat,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(confCat,start)
      pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x

   pack $private(frm).start -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $private(pluginNamespaceList) {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title    " -raisecmd "::confCat::onRaiseNotebook $namespace" ]
         ::$namespace\::fillConfigPage $frm
      }
      pack $notebook -fill both -expand 1 -padx 4 -pady 4

   pack $private(frm).usr -side top -fill both -expand 1

   #--- La fenetre est active
   focus $private(frm)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private(frm) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)

   return 0
}

#------------------------------------------------------------
# ::confCat::selectNotebook
# Selectionne un onglet
# Si le label est omis ou inconnu, le premier onglet est selectionne
#------------------------------------------------------------
proc ::confCat::selectNotebook { { chart "" } } {
   variable private

   if { $chart != "" } {
      set frm [ $private(frm).usr.onglet getframe $chart ]
      $private(frm).usr.onglet raise $chart
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#----------------------------------------------------------------------------
# ::confCat::onRaiseNotebook
# Affiche en gras le nom de l'onglet
#----------------------------------------------------------------------------
proc ::confCat::onRaiseNotebook { chartName } {
   variable private

   set font [$private(frm).usr.onglet.c itemcget "$chartName:text" -font]
   lappend font "bold"
   #--- remarque : il faut attendre que l'onglet soit redessine avant de changer la police
   after 200 $private(frm).usr.onglet.c itemconfigure "$chartName:text" -font [list $font]
}

#------------------------------------------------------------
# ::confCat::configurePlugin
# configure le plugin dont le label est dans $conf(confCat)
#------------------------------------------------------------
proc ::confCat::configurePlugin { pluginName } {
   global conf

   #--- j'arrete le plugin precedent
   if { $conf(confCat) != "" } {
      ::$conf(confCat)::deletePluginInstance
   }

   set conf(confCat) $pluginName

   #--- je cree le plugin
   if { $pluginName != "" } {
      ::$pluginName\::createPluginInstance
   }
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
# ::confCat::startPlugin
# lance le plugin
#------------------------------------------------------------
proc ::confCat::startPlugin { } {
   global conf

   if { $conf(confCat,start) == "1" } {
      ::confCat::configurePlugin $conf(confCat)
   }
}

#------------------------------------------------------------
# ::confCat::stopPlugin
# arrete le plugin selectionne
#
#  return rien
#------------------------------------------------------------
proc ::confCat::stopPlugin { } {
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
            if { $pluginInfo(type) == "chart" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
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
         } else {
            ::console::affiche_erreur "Error loading cat $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confCat::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphabetique des libelles
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

