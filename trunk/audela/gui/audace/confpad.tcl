#
# Fichier : confpad.tcl
# Description : Affiche la fenetre de configuration des plugins du type 'pad'
# Auteur : Michel PUJOL
# Mise a jour $Id: confpad.tcl,v 1.22 2007-11-03 19:05:06 robertdelmas Exp $
#

namespace eval ::confPad {
}

#------------------------------------------------------------
# ::confPad::init (est lance automatiquement au chargement de ce fichier tcl)
# initialise les variable conf(..) et caption(..)
# demarrer le plugin selectionne par defaut
#------------------------------------------------------------
proc ::confPad::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" confpad.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   if { ! [ info exists conf(confPad) ] }          { set conf(confPad)          "" }
   if { ! [ info exists conf(confPad,start) ] }    { set conf(confPad,start)    "0" }
   if { ! [ info exists conf(confPad,geometry) ] } { set conf(confPad,geometry) "440x265+155+100" }

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confPad"
   set private(variablePluginName)  ""

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" pad]
   #--- je recherche les plugin presents
   findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(confPad)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(confPad) ""
   }
}

#------------------------------------------------------------
# ::confPad::getLabel
# retourne le titre de la fenetre dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::confPad::getLabel { } {
   global caption

   return "$caption(confpad,config)"
}

#------------------------------------------------------------
# ::confPad::getCurrentPad
# retourne le nom de la raquette courante
#------------------------------------------------------------
proc ::confPad::getCurrentPad { } {
   global conf

   return $conf(confPad)
}

#------------------------------------------------------------
# ::confPad::run
# Affiche la fenetre de choix et de configuration
#
# Parametres :
#    variablePluginName : contient le nom de la variable dans laquelle
#                         sera copie le nom du plugin selectionn�
#------------------------------------------------------------
proc ::confPad::run { { variablePluginName "" } } {
   variable private
   global conf

   set private(variablePluginName) $variablePluginName

   if { [createDialog] == 0 } {
      if { $variablePluginName != "" } {
         #--- je recupere le nom du plugin pre-selectionne par l'appelant
         set pluginName [set $variablePluginName]
      } else {
         #--- je recupere le nom du plugin par defaut
         set pluginName $conf(confPad)
      }
      if { $pluginName != "" } {
         #--- je selectionne l'onglet du plugin
         select $pluginName
      }
   }
}

#------------------------------------------------------------
# ::confPad::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
# la configuration, et fermer la fenetre de reglage
#------------------------------------------------------------
proc ::confPad::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# ::confPad::appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer'
# pour memoriser et appliquer la configuration
#------------------------------------------------------------
proc ::confPad::appliquer { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le namespace correspondant au label
   set label "[Rnotebook:currentName $private(frm).usr.book ]"
   set index [lsearch -exact $private(pluginLabelList) $label ]
   if { $index != -1 } {
      set padName [lindex $private(pluginNamespaceList) $index]
   } else {
      set padName ""
   }

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach name $private(pluginNamespaceList) {
      $name\::widgetToConf
   }

   #--- je copie le nom dans la variable de sortie
   if { $private(variablePluginName) != "" } {
      set $private(variablePluginName) $padName
   }

   #--- je demarre le plugin selectionne
   configureDriver $padName

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
# ::confPad::afficheAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confPad::afficheAide { } {
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
# ::confPad::fermer
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confPad::fermer { } {
   variable private

   ::confPad::recupPosDim
   destroy $private(frm)
}

#------------------------------------------------------------
# ::confPad::recupPosDim
# Permet de recuperer et de sauvegarder la position et la
# dimension de la fenetre de configuration de la raquette
#------------------------------------------------------------
proc ::confPad::recupPosDim { } {
   variable private
   global conf

   set private(confPad,geometry) [ wm geometry $private(frm) ]
   set conf(confPad,geometry) $private(confPad,geometry)
}

#------------------------------------------------------------
# ::confPad::createDialog
# Affiche la fenetre a onglet
#
# retrun 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confPad::createDialog { } {
   variable private
   global caption conf

   #--- Je verifie qu'il y a des raquettes
   if { [ llength $private(pluginNamespaceList) ] < 1 } {
      tk_messageBox -title "$caption(confpad,config)" -message "$caption(confpad,pas_raquette)" -icon error
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
   set private(confPad,geometry) $conf(confPad,geometry)

   toplevel $private(frm)
   wm geometry $private(frm) $private(confPad,geometry)
   wm minsize $private(frm) 440 265
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confpad,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confPad::fermer"

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

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(confpad,ok)" -relief raised -state normal -width 7 \
         -command "::confPad::ok"
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(confpad,appliquer)" -relief raised -state normal -width 8 \
         -command "::confPad::appliquer"
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(confpad,fermer)" -relief raised -state normal -width 7 \
         -command "::confPad::fermer"
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(confpad,aide)" -relief raised -state normal -width 8 \
         -command "::confPad::afficheAide"
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
# ::confPad::createFramePad
# Cree une frame pour selectionner le plugin dans une combobox
# Cette frame est destinee a etre inseree dans une fenetre.
# Parametres :
#    frm     : chemin TK de la frame a creer
#    variablePluginName : contient le nom de la variable dans laquelle sera
#                         copie le nom du plugin selectionn�
#
# Return
#    nothing
# Exemple:
#    ::confEqt::createFramePad $frm.padList ::confTel(audine,plugin)
#    pack $frm.pluginList -in $frm -anchor center -side right -padx 10
#------------------------------------------------------------
proc ::confPad::createFramePad { frm variablePluginName} {
   variable private
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   ComboBox $frm.list \
      -width 15       \
      -height [llength $private(pluginNamespaceList)] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable $variablePluginName \
      -editable 0     \
      -values $private(pluginNamespaceList)
   pack $frm.list -in $frm -anchor center -side left -padx 0 -pady 10

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confpad,configurer) ..." \
      -command "::confPad::run $variablePluginName"
   pack $frm.configure -in $frm -anchor center -side top -padx 10 -pady 10 -ipadx 10 -ipady 5 -expand true
}

#------------------------------------------------------------
# ::confPad::select [label]
# Selectionne un onglet en passant le label de l'onglet decrit dans la fenetre de configuration
# Si le label est omis ou inconnu, le premier onglet est selectionne
#------------------------------------------------------------
proc ::confPad::select { { name "" } } {
   variable private

   #--- je recupere le label correspondant au namespace
   set index [ lsearch -exact $private(pluginNamespaceList) "$name" ]
   if { $index != -1 } {
      Rnotebook:select $private(frm).usr.book [ lindex $private(pluginLabelList) $index ]
   }
}

#------------------------------------------------------------
# ::confPad::configureDriver
# configure le plugin dont le label est dans $conf(confPad)
#------------------------------------------------------------
proc ::confPad::configureDriver { pluginName } {
   variable private
   global conf

   #--- je ferme la raquette precedente
   if { $conf(confPad) != "" } {
      $conf(confPad)::deletePluginInstance
   }

   set conf(confPad) $pluginName

   #--- je cree le plugin
   if { $conf(confPad) != "" } {
      $conf(confPad)::createPluginInstance
   }
}

#------------------------------------------------------------
# ::confPad::stopDriver
# arrete le plugin selectionne
#
#  return rien
#------------------------------------------------------------
proc ::confPad::stopDriver { } {
   global conf

   if { "$conf(confPad)" != "" } {
      $conf(confPad)::deletePluginInstance
   }
}

#------------------------------------------------------------
# ::confPad::findPlugin
# recherche les plugins de type "pad"
#
# conditions :
#   - le plugin doit avoir une procedure getPluginType qui retourne "pad"
#   - le plugin doit avoir une procedure getPluginTitle
#   - etc.
#
# si le plugin remplit les conditions :
# son label est ajoute dans la liste pluginTitleList et son namespace est ajoute dans pluginNamespaceList
# sinon le fichier tcl est ignore car ce n'est pas un plugin
#
# return 0 = OK, 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confPad::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers pad/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" pad * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "pad"} {
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
                     ::console::affiche_prompt "#$caption(confpad,raquette) $pluginlabel v$pluginInfo(version)\n"
                  }
               }
            }
         } else {
            ::console::affiche_erreur "Error loading pad $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confPad::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphab�tique des libelles
   set pluginList ""
   for { set i 0} {$i< [llength $private(pluginLabelList)] } {incr i } {
      lappend pluginList [list [lindex $private(pluginLabelList) $i] [lindex $private(pluginNamespaceList) $i] ]
   }
   set pluginList [lsort -index 0 $pluginList]
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
::confPad::init

