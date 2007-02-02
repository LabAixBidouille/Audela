#
# Fichier : confeqt.tcl
# Description : Gere des objets 'equipement' a vocation astronomique
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: confeqt.tcl,v 1.8 2007-02-02 23:33:00 robertdelmas Exp $
#

namespace eval ::confEqt {

}

#------------------------------------------------------------
# ::confEqt::init ( est lance automatiquement au chargement de ce fichier tcl)
# initialise les variable conf(..) et caption(..)
# demarrer le driver selectionne par defaut
#------------------------------------------------------------
proc ::confEqt::init { } {
   variable private
   global audace
   global conf

   #--- charge le fichier caption
   uplevel #0 "source \"[ file join $audace(rep_caption) confeqt.cap ]\""

   #--- cree les variables dans conf(..) si elles n'existent pas
   if { ! [ info exists conf(confEqt) ] }          { set conf(confEqt)          "" }
   if { ! [ info exists conf(confEqt,start) ] }    { set conf(confEqt,start)    "0" }
   if { ! [ info exists conf(confEqt,position) ] } { set conf(confEqt,position) "+155+100" }

   #--- vaiables locales
   set private(namespaceList) ""
   set private(labelList)     ""
   set private(frm)           "$audace(base).confeqt"
   set private(focuser)       ""
   set private(variableSelectedFocuser)  ""

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
proc ::confEqt::run { { variableSelectedFocuser "" } } {
   if { [createDialog ]==0 } {
      set private(variableSelectedFocuser) $variableSelectedFocuser
      if { $variableSelectedFocuser != "" }  {
         select [set $variableSelectedFocuser]
      } else {
         set private(variableSelectedFocuser) ""
      }
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
   global conf

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le namespace correspondant au label
   set label "[Rnotebook:currentName $private(frm).usr.book ]"
   set index [lsearch -exact $private(labelList) $label ]
   if { $index != -1 } {
      set conf(confEqt) [lindex $private(namespacelist) $index]
   } else {
      set conf(confEqt) ""
   }

   #--- je demande a chaque driver de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(namespacelist) {
      ::confEqt::configurePlugin $pluginLabel
   }

   #--- Affichage d'un message d'alerte si necessaire
   ::confEqt::Connect_Equipement

   #--- je demarre le driver selectionne
   createPlugin $conf(confEqt)

   if { $private(variableSelectedFocuser) != "" } {
      set $private(variableSelectedFocuser) $conf(confEqt)
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
   global conf
   global help

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   $private(frm).cmd.aide configure -relief groove -state disabled

   #--- je recupere le label de l'onglet selectionne
   set private(conf_confEqt) [Rnotebook:currentName $private(frm).usr.book ]
   #--- je recupere le namespace correspondant au label
   set label "[Rnotebook:currentName $private(frm).usr.book ]"
   set index [lsearch -exact $private(labelList) $label ]
   if { $index != -1 } {
      set private(conf_confEqt) [lindex $private(namespacelist) $index]
   } else {
      set private(conf_confEqt) ""
   }
   #--- j'affiche la documentation
   set driver_doc [ $private(conf_confEqt)\:\:getHelp ]
   ::audace::showHelpPlugin equipment $private(conf_confEqt) "$driver_doc"

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

   ::confEqt::recup_position
   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -relief groove -state disabled
   destroy $private(frm)
}

#------------------------------------------------------------
# ::confEqt::recup_position
# Permet de recuperer et de sauvegarder la position de la
# fenetre de configuration de l'equipement
#------------------------------------------------------------
proc ::confEqt::recup_position { } {
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
# retrun 0 = OK , 1 = error (no driver found)
#------------------------------------------------------------
proc ::confEqt::createDialog { } {
   variable private
   global audace
   global conf
   global caption

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
   wm resizable $private(frm) 1 0
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confeqt,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confEqt::fermer"

   frame $private(frm).usr -borderwidth 0 -relief raised

   #--- creation de la fenetre a onglets
   set mainFrame $private(frm).usr.book

   #--- j'affiche les onglets dans la fenetre
   Rnotebook:create $mainFrame -tabs "$private(labelList)" -borderwidth 1

   #--- je demande a chaque driver d'afficher sa page de config
   set indexOnglet 1
   foreach name $private(namespacelist) {
      set drivername [ $name\:\:fillConfigPage [ Rnotebook:frame $mainFrame $indexOnglet ] ]
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
   bind $private(frm) <Key-F1> { $audace(console)::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)

   return 0
}

#------------------------------------------------------------
# ::confEqt::select [label]
# Selectionne un onglet en passant le label de l'onglet decrit dans la fenetre de configuration
# Si le label est omis ou inconnu, le premier onglet est selectionne
#------------------------------------------------------------
proc ::confEqt::select { { name "" } } {
   variable private

   #--- je recupere le label correspondant au namespace
   set index [ lsearch -exact $private(namespacelist) "$name" ]
   if { $index != -1 } {
      Rnotebook:select $private(frm).usr.book [ lindex $private(labelList) $index ]
   }
}

#------------------------------------------------------------
# ::confEqt::createPlugin
#    cree le plugin dont le nom est donne en parametre
#------------------------------------------------------------
proc ::confEqt::createPlugin { pluginLabel } {
   if { $pluginLabel != "" } {
      #--- je demarrer le driver
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
#  - le plugin doit retourner un namespace non nul quand on charge son source .tcl
#  - le plugin doit avoir une procedure getDriverType qui retourne "equipment" ou "focuser"
#  - le plugin doit avoir une procedure getlabel
#
# si le plugin remplit les conditions
#    son label est ajouté dans la liste labelList, et son namespace est ajoute dans namespacelist
#    sinon le fichier tcl est ignore car ce n'est pas un driver
#
# retrun 0 = OK , 1 = error (no driver found)
#------------------------------------------------------------
proc ::confEqt::findPlugin { } {
   variable private
   global audace
   global caption

   #--- j'initialise les listes vides
   set private(namespacelist)  ""
   set private(labelList)      ""
   set pluginPattern [ file join audace plugin equipment * pkgIndex.tcl ]

   #--- chargement des differentes fenetres de configuration des drivers
   set error [catch { glob -nocomplain $pluginPattern } filelist ]

   if { "$filelist" == "" } {
      #--- aucun fichier correct
      return 1
   }

   #--- je recherche les drivers repondant au filtre driverPattern
   foreach pkgIndex $filelist {
      catch {
        #--- je recupere le nom du package
         set packageName [uplevel #0 source "$pkgIndex"]
         #--- je charge le package
         package require $packageName

         set equipname $packageName
         if { [$equipname\:\:getPluginType] == "equipment"
              || [$equipname\:\:getPluginType] == "focuser" } {
            set pluginlabel "[$equipname\:\:getLabel]"
            #--- si c'est un plugin valide, je l'ajoute dans la liste
            lappend private(namespacelist) $equipname
            lappend private(labelList) $pluginlabel
            $audace(console)::affiche_prompt "#$caption(confeqt,equipement) $pluginlabel v[package present $equipname]\n"
         }
      } catchMessage
      #--- j'affiche le message d'erreur et je continu la recherche des plugins
      if { $catchMessage != "" } {
         console::affiche_erreur "::confEqt::findPlugin $catchMessage\n"
      }
   }
   $audace(console)::affiche_prompt "\n"

   if { [llength $private(namespacelist)] <1 } {
      #--- pas driver correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#------------------------------------------------------------
# ::confEqt::Connect_Equipement
# Affichage d'un message d'alerte pendant la connexion d'un equipement au demarrage
#------------------------------------------------------------
proc ::confEqt::Connect_Equipement { } {
   variable private
   global audace
   global caption
   global color

   if [ winfo exists $audace(base).connectEquipement ] {
      destroy $audace(base).connectEquipement
   }

   toplevel $audace(base).connectEquipement
   wm resizable $audace(base).connectEquipement 0 0
   wm title $audace(base).connectEquipement "$caption(confeqt,attention)"
   if { [ info exists private(frm) ] } {
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
   uplevel #0 { pack $audace(base).connectEquipement.labURL_1 -padx 10 -pady 2 }
   label $audace(base).connectEquipement.labURL_2 -text "$caption(confeqt,connexion_texte2)" \
      -font $audace(font,arial_10_b) -fg $color(red)
   uplevel #0 { pack $audace(base).connectEquipement.labURL_2 -padx 10 -pady 2 }
   update

   #--- La nouvelle fenetre est active
   focus $audace(base).connectEquipement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectEquipement
}

#------------------------------------------------------------
# ::confEqt::createFrameFocuser
#    Cree une frame pour selectionner le focuser
#    Cette frame est destinee a etre insere dans une fenetre.
# Parametres :
#    frm     : chemin TK de la frame a creer
#    variableSelectedFocuser : nom de la variable dans laquelle est copié le nom
#                              du focuser selectionné
# Return
#    nothing
# Exemple:
#    ::confEqt::createFrameFocuser $frm.focuserList ::confCam(audine,focuser)
#    pack $frm.focuserList -in $frm -anchor center -side right -padx 10
#
#------------------------------------------------------------
proc ::confEqt::createFrameFocuser { frm variableSelectedFocuser } {
   variable private
   global conf
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   #--- je recupere le nom de la variable
   set private(variableSelectedFocuser) $variableSelectedFocuser

   ComboBox $frm.list \
      -width 10         \
      -height [llength $private(namespaceList)] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable $::confEqt::private(variableSelectedFocuser) \
      -editable 0       \
      -values $private(namespaceList)
   pack $frm.list -in $frm -anchor center -side left -padx 0 -pady 10

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confeqt,configurer) ..." \
      -command {
         ::confEqt::run
      }
   pack $frm.configure -in $frm -anchor center -side top -padx 10 -pady 10 -ipadx 10 -ipady 5 -expand true

}

#------------------------------------------------------------
# ::confEqt::startDriver
#   lance tous les plugins
#
#------------------------------------------------------------
proc ::confEqt::startDriver { } {
   variable private

   #--- je demande a chaque driver de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(namespacelist) {
      if { [::$pluginLabel\::getStartFlag] == 1 } {
         set catchError [ catch { ::$pluginLabel\::createPlugin  } catchMessage ]
         if { $catchError == 1 } {
            #--- j'affiche un message d'erreur
            ::console::affiche_erreur "Error start equipment $pluginLabel : $catchMessage\n"
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

   #--- je demande a chaque driver de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(namespacelist) {
      if { [::$pluginLabel\::isReady] == 1 } {
         ::$pluginLabel\::deletePlugin
      }
   }
}

#--- connexion au demarrage du driver selectionne par defaut
::confEqt::init

