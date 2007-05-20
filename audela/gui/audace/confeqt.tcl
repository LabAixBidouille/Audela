#
# Fichier : confeqt.tcl
# Description : Gere des objets 'equipement' a vocation astronomique
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: confeqt.tcl,v 1.18 2007-05-20 15:51:15 robertdelmas Exp $
#

namespace eval ::confEqt {

}

#------------------------------------------------------------
# ::confEqt::init ( est lance automatiquement au chargement de ce fichier tcl)
# initialise les variable conf(..) et caption(..)
# demarrer le plugin selectionne par defaut
#------------------------------------------------------------
proc ::confEqt::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" confeqt.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   if { ! [ info exists conf(confEqt,start) ] }    { set conf(confEqt,start)    "0" }
   if { ! [ info exists conf(confEqt,position) ] } { set conf(confEqt,position) "+155+100" }

   #--- variables locales
   set private(namepaceList)       ""
   set private(notebookLabelList)  ""
   set private(notebookNameList)   ""
   set private(frm)                "$audace(base).confeqt"
   set private(variablePluginName) ""

   #--- j'ajoute le repetoire des equipements dans la liste des
   #--- repertoire pouvant contenir des plugins
   lappend ::auto_path "$::audace(rep_plugin)/equipment"
   #--- je charge la liste des plugins
   findPlugin
}

#------------------------------------------------------------
# ::confEqt::getLabel
#    retourne le titre de la fenetre
#
# return "Titre de la fenetre de choix (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::confEqt::getLabel { } {
   global caption

   return "$caption(confeqt,config)"
}

#------------------------------------------------------------
# ::confEqt::run
# Affiche la fenetre de choix et de configuration
#
#------------------------------------------------------------
proc ::confEqt::run { { variablePluginName "" } { authorizedPluginType "" } { configurationTitle "" } } {
   variable private

   #--- je memorise le nom de la variable contenant le nom du plugin selectionne
   #--- la procedure apply copira le nom du plugin selectionne dans cette variable
   set private(variablePluginName) $variablePluginName

   if { $::confEqt::private(variablePluginName) != "" } {
      set selectedPluginName [set $::confEqt::private(variablePluginName)]
   } else {
      set selectedPluginName ""
   }

   set private(notebookLabelList) [list ]
   set private(notebookNameList)  [list ]

   #--- Si authorizedPluginType est vide tous les onglets sont affiches
   if { $authorizedPluginType == "" } {
      #--- les plugin  de tous les types sont autorises
      set private(notebookNameList) $private(namespaceList)
      foreach pluginName $private(notebookNameList) {
         lappend private(notebookLabelList) [::$pluginName\::getPluginTitle]
      }
   } else {
      #--- je cree la liste des plugin dont le type est autorise
      foreach pluginName $private(namespaceList) {
         if { [lsearch -exact $authorizedPluginType [::$pluginName\::getPluginType]] != -1 } {
            lappend private(notebookNameList)  $pluginName
            lappend private(notebookLabelList) [::$pluginName\::getPluginTitle]
         }
      }
   }

   #--- je verifie si le plugin existe dans la liste des onglets
   if { [llength $private(notebookNameList) ] > 0 } {
      ::confEqt::createDialog
      if { $selectedPluginName != "" } {
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [lsearch -exact $private(notebookNameList) $selectedPluginName ] == -1 } {
            #--- si la valeur n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set selectedPluginName [lindex $private(notebookNameList) 0]
         }
         select $selectedPluginName
      }
   } else {
      console::disp " il n'y a pas de plugin present \n"
   }
}

#------------------------------------------------------------
# ::confEqt::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
# la configuration, et fermer la fenetre de reglage
#------------------------------------------------------------
proc ::confEqt::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# ::confEqt::appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
# memoriser et appliquer la configuration
#------------------------------------------------------------
proc ::confEqt::appliquer { } {
   variable private
   global audace

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le nom du plugin selectionné
   set index [expr [Rnotebook:currentIndex $private(frm).usr.book ] -1]
   set selectedPluginName  [lindex $private(notebookNameList) $index]

   #--- Affichage d'un message d'alerte si necessaire
   ::confEqt::connectEquipement

   #--- je configure le plugin
   ::confEqt::configurePlugin $selectedPluginName

   #--- je cree le plugin selectionne
   createPlugin $selectedPluginName

   #--- je copie le nom dans la variable de sortie
   if { $private(variablePluginName) != "" } {
      set $private(variablePluginName) $selectedPluginName
   }

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal

   #--- Effacement du message d'alerte s'il existe
   if [ winfo exists $audace(base).connectEquipement ] {
      destroy $audace(base).connectEquipement
   }
}

#------------------------------------------------------------
# ::confEqt::afficheAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confEqt::afficheAide { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   $private(frm).cmd.aide configure -relief groove -state disabled

   #--- je recupere le label de l'onglet selectionne
   set private(conf_confEqt) [Rnotebook:currentName $private(frm).usr.book ]

   #--- je recupere le nom du plugin selectionne
   set index [Rnotebook:currentIndex $private(frm).usr.book ]
   set index [ expr $index - 1 ]
   set selectedPluginName [lindex $private(notebookNameList) $index]

   #--- j'affiche la documentation
   set pluginHelp [ $selectedPluginName\::getHelp ]
   ::audace::showHelpPlugin equipment $selectedPluginName "$pluginHelp"

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -state normal
   $private(frm).cmd.fermer configure -state normal
   $private(frm).cmd.aide configure -relief raised -state normal
}

#------------------------------------------------------------
# ::confEqt::fermer
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confEqt::fermer { } {
   variable private

   ::confEqt::recupPosition
   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -relief groove -state disabled
   destroy $private(frm)

   #--- j'efface le nom de la variable de sortie
   set private(variablePluginName) ""
}

#------------------------------------------------------------
# ::confEqt::recupPosition
# Permet de recuperer et de sauvegarder la position de la
# fenetre de configuration de l'equipement
#------------------------------------------------------------
proc ::confEqt::recupPosition { } {
   variable private
   global conf

   set private(confEqt,geometry) [ wm geometry $private(frm) ]
   set deb [ expr 1 + [ string first + $private(confEqt,geometry) ] ]
   set fin [ string length $private(confEqt,geometry) ]
   set private(confEqt,position) "+[ string range $private(confEqt,geometry) $deb $fin ]"
   #---
   set conf(confEqt,position) $private(confEqt,position)
}

#------------------------------------------------------------
# ::confEqt::createUrlLabel
# cree un widget "label" avec une URL du site WEB
#------------------------------------------------------------
proc ::confEqt::createUrlLabel { tkparent title url } {
   global audace color

   label  $tkparent.labURL -text "$title" -font $audace(font,url) -fg $color(blue)
   bind   $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   bind   $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind   $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

#------------------------------------------------------------
# confEqt::configurePlugin
# configure le plugin
#------------------------------------------------------------
proc ::confEqt::configurePlugin { pluginLabel } {
   if { $pluginLabel != "" } {
      ::$pluginLabel\::configurePlugin
   }
}

#------------------------------------------------------------
# ::confEqt::createDialog
# Affiche la fenetre a onglet
#    authorizedEquipementType : Liste des types d'equipement a afficher
#       Si la liste est vide les onglets de tous les types d'equipements sont affiches
#    configurationTitle : Titre complementaire de la fenetre de dialogue
# retrun 0 = OK , 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confEqt::createDialog { } {
   variable private
   global caption conf

   if { [winfo exists $private(frm)] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      focus $private(frm)
      return 0
   }

   #---
   set private(confEqt,position) $conf(confEqt,position)

   #---
   if { [ info exists private(confEqt,geometry) ] } {
      set deb [ expr 1 + [ string first + $private(confEqt,geometry) ] ]
      set fin [ string length $private(confEqt,geometry) ]
      set private(confEqt,position) "+[ string range $private(confEqt,geometry) $deb $fin ]"
   }

   toplevel $private(frm)
   if { $::tcl_platform(os) == "Linux" } {
      wm geometry $private(frm) 620x405$private(confEqt,position)
      wm minsize $private(frm) 620 405
   } else {
      wm geometry $private(frm) 460x405$private(confEqt,position)
      wm minsize $private(frm) 460 405
   }
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confeqt,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confEqt::fermer"

   frame $private(frm).usr -borderwidth 0 -relief raised

   #--- creation de la fenetre a onglets
   set mainFrame $private(frm).usr.book

   #--- j'affiche les onglets dans la fenetre
   Rnotebook:create $mainFrame -tabs "$private(notebookLabelList)" -borderwidth 1

   #--- je demande a chaque plugin d'afficher sa page de config
   set indexOnglet 1
   foreach name $private(notebookNameList) {
      set pluginname [ $name\:\:fillConfigPage [ Rnotebook:frame $mainFrame $indexOnglet ] ]
      incr indexOnglet
   }

   pack $mainFrame -fill both -expand 1
   pack $private(frm).usr -side top -fill both -expand 1

   #--- frame bouton ok, appliquer, fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised
   button $private(frm).cmd.ok -text "$caption(confeqt,ok)" -relief raised -state normal -width 7 \
      -command " ::confEqt::ok "
   if { $conf(ok+appliquer)=="1" } {
      pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
   }
   button $private(frm).cmd.appliquer -text "$caption(confeqt,appliquer)" -relief raised -state normal -width 8 \
      -command " ::confEqt::appliquer "
   pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
   button $private(frm).cmd.fermer -text "$caption(confeqt,fermer)" -relief raised -state normal -width 7 \
      -command " ::confEqt::fermer "
   pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
   button $private(frm).cmd.aide -text "$caption(confeqt,aide)" -relief raised -state normal -width 8 \
      -command " ::confEqt::afficheAide "
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
# ::confEqt::select [label]
# Selectionne un onglet en passant le label de l'onglet decrit dans la fenetre de configuration
# Si le label est omis ou inconnu, le premier onglet est selectionne
#------------------------------------------------------------
proc ::confEqt::select { { equipment "" } } {
   variable private

   #--- je selectionne l'onglet qui contient le label de l'equipement
   if { $equipment != "" } {
      Rnotebook:select $private(frm).usr.book [::$equipment\::getPluginTitle]
   }
}

#------------------------------------------------------------
# ::confEqt::createPlugin
#    cree le plugin dont le nom est donne en parametre
#------------------------------------------------------------
proc ::confEqt::createPlugin { pluginLabel } {
   if { $pluginLabel != "" } {
      #--- je demarrer le plugin
      ::$pluginLabel\::createPlugin
   }
}

#------------------------------------------------------------
# ::confEqt::deletePlugin
#    supprime le plugin
#
# return rien
#------------------------------------------------------------
proc ::confEqt::deletePlugin { pluginLabel } {
   if { "$pluginLabel" != "" } {
      ::$pluginLabel\::deletePlugin
   }
}

#------------------------------------------------------------
# ::confEqt::findPlugin
#   recherche les plugins presents
#
# conditions :
#  - le plugin doit avoir une procedure getPluginType qui retourne "equipment" ou "focuser"
#  - le plugin doit avoir une procedure getPluginTitle
#
# si le plugin remplit les conditions
#    son namespace est ajoute dans namespaceList
#    sinon le fichier tcl est ignore car ce n'est pas un plugin
#
# retrun 0 = OK , 1 = error (no plugin found)
#------------------------------------------------------------
proc ::confEqt::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(namespaceList)  ""

   #--- chargement des differentes fenetres de configuration des plugins
   set filelist [glob -nocomplain -join "$audace(rep_plugin)" equipment * pkgIndex.tcl ]

   #--- je recherche les plugins repondant au filtre pluginPattern
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         ##set dir [file dirname $"pkgIndexFileName"]
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type)== "equipment" || $pluginInfo(type)== "focuser"} {
               #--- je charge le package
               package require $pluginInfo(name)
               #--- j'initalise le plugin
               $pluginInfo(namespace)::initPlugin
               set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
               #--- je l'ajoute dans la liste des plugins
               lappend private(namespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
               ::console::affiche_prompt "#$caption(confeqt,equipement) $pluginlabel v$pluginInfo(version)\n"
            }
         } else {
            ::console::affiche_erreur "Error loading equipment $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continu la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confEqt::findPlugin $::errorInfo\n"
      }
   }
   ::console::affiche_prompt "\n"

   if { [llength $private(namespaceList)] <1 } {
      #--- pas plugin correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#------------------------------------------------------------
# ::confEqt::connectEquipement
# Affichage d'un message d'alerte pendant la connexion d'un equipement au demarrage
#------------------------------------------------------------
proc ::confEqt::connectEquipement { } {
   variable private
   global audace caption color

   if [ winfo exists $audace(base).connectEquipement ] {
      destroy $audace(base).connectEquipement
   }

   toplevel $audace(base).connectEquipement
   wm resizable $audace(base).connectEquipement 0 0
   wm title $audace(base).connectEquipement "$caption(confeqt,attention)"
   if { [ winfo exists $audace(base).confeqt ] } {
      set posx_connectEquipement [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
      set posy_connectEquipement [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
      wm geometry $audace(base).connectEquipement +[ expr $posx_connectEquipement + 50 ]+[ expr $posy_connectEquipement + 100 ]
      wm transient $audace(base).connectEquipement $private(frm)
   } else {
      wm geometry $audace(base).connectEquipement +200+100
      wm transient $audace(base).connectEquipement $audace(base)
   }

   #--- Cree l'affichage du message
   label $audace(base).connectEquipement.labURL_1 -text "$caption(confeqt,connexion_texte1)" \
      -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).connectEquipement.labURL_1 -padx 10 -pady 2
   label $audace(base).connectEquipement.labURL_2 -text "$caption(confeqt,connexion_texte2)" \
      -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).connectEquipement.labURL_2 -padx 10 -pady 2
   update

   #--- La nouvelle fenetre est active
   focus $audace(base).connectEquipement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectEquipement
}

#------------------------------------------------------------
# ::confEqt::createFrameFocuser
#    Cree une frame pour selectionner le focuser
#    Cette frame est destinee a etre inseree dans une fenetre
# Parametres :
#    frm     : chemin TK de la frame a creer
#    variablePluginName : contient le nom de la variable dans laquelle sera
#                         copie le nom du focuser selectionné
# Return
#    nothing
# Exemple:
#    ::confEqt::createFrameFocuser $frm.focuserList ::confCam(audine,focuser)
#    pack $frm.focuserList -in $frm -anchor center -side right -padx 10
#
#------------------------------------------------------------
proc ::confEqt::createFrameFocuser { frm variablePluginName } {
   variable private
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   #--- je cree la liste des plugin de type "focuser"
   set pluginList [list ]
   foreach pluginName $private(namespaceList) {
      if {  [::$pluginName\::getPluginType] == "focuser" } {
         lappend pluginList $pluginName
      }
   }

   ComboBox $frm.list \
      -width 15       \
      -height [llength $pluginList] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable $variablePluginName \
      -editable 0     \
      -values $pluginList
   pack $frm.list -in $frm -anchor center -side left -padx 0 -pady 10

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confeqt,configurer) ..." \
      -command "::confEqt::run $variablePluginName focuser"
   pack $frm.configure -in $frm -anchor center -side top -padx 10 -pady 10 -ipadx 10 -ipady 5 -expand true

}

#------------------------------------------------------------
# ::confEqt::createFrameFocuserTool
#    Cree une frame pour selectionner le focuser pour un outil
#    Cette frame est destinee a etre inseree dans une fenetre
# Parametres :
#    frm     : chemin TK de la frame a creer
#    variablePluginName : contient le nom de la variable dans laquelle sera
#                         copie le nom du focuser selectionné
# Return
#    nothing
# Exemple:
#    ::confEqt::createFrameFocuserTool $frm.focuserList ::confCam(audine,focuser)
#    pack $frm.focuserList -in $frm -anchor center -side right -padx 10
#
#------------------------------------------------------------
proc ::confEqt::createFrameFocuserTool { frm variablePluginName } {
   variable private
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   #--- je cree la liste des plugin de type "focuser"
   set pluginList [list ]
   foreach pluginName $private(namespaceList) {
      if {  [::$pluginName\::getPluginType] == "focuser" } {
         lappend pluginList $pluginName
      }
   }

   ComboBox $frm.list \
      -width 15       \
      -height [llength $pluginList] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable $variablePluginName \
      -editable 0     \
      -values $pluginList
   pack $frm.list -in $frm -anchor center -side top -padx 0 -pady 2

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confeqt,configurer) ..." \
      -command "::confEqt::run $variablePluginName focuser"
   pack $frm.configure -in $frm -anchor center -side top -padx 0 -pady 2 -ipadx 10 -ipady 5 -expand true

}

#------------------------------------------------------------
# ::confEqt::startDriver
#   lance tous les plugins
#
#------------------------------------------------------------
proc ::confEqt::startDriver { } {
   variable private
   global audace

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(namespaceList) {
      if { [::$pluginLabel\::getStartFlag] == 1 } {
         #--- Affichage d'un message d'alerte si necessaire
         ::confEqt::connectEquipement
         #--- Lance les plugins equipements au demarrage
         set catchError [ catch { ::$pluginLabel\::createPlugin } catchMessage ]
         if { $catchError == 1 } {
            #--- j'affiche un message d'erreur
            ::console::affiche_erreur "Error start equipment $pluginLabel : $catchMessage\n"
         }
         #--- Effacement du message d'alerte s'il existe
         if [ winfo exists $audace(base).connectEquipement ] {
            destroy $audace(base).connectEquipement
         }
      }
   }
}

#------------------------------------------------------------
# ::confEqt::stopDriver
#   arrete tous les plugins qui sont en service
#
#------------------------------------------------------------
proc ::confEqt::stopDriver { } {
   variable private

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(namespaceList) {
      if { [::$pluginLabel\::isReady] == 1 } {
         ::$pluginLabel\::deletePlugin
      }
   }
}

#--- initialisation de la liste des plugins
::confEqt::init

