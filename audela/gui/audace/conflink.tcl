#
# Fichier : confLink.tcl
# Description : Gere des objets 'liaison' pour la communication
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: conflink.tcl,v 1.18 2007-09-05 19:55:13 robertdelmas Exp $
#

namespace eval ::confLink {
}

#------------------------------------------------------------
# ::confLink::init ( est lance automatiquement au chargement de ce fichier tcl)
#    Initialise les variable conf(..) et caption(..)
#    Demarre le driver selectionne par defaut
#------------------------------------------------------------
proc ::confLink::init { } {
   variable private
   global audace
   global conf

   #---
   set private(namespace)     "confLink"
   set private(frm)           "$audace(base).confLink"
   set private(driverType)    "link"
   set private(driverPattern) ""
   set private(namespaceList) ""
   set private(pluginTitleList)    ""
   #--- cree les variables dans conf(..) si elles n'existent pas
   if { ! [ info exists conf(confLink,start) ] }    { set conf(confLink,start)    "0" }
   if { ! [ info exists conf(confLink,position) ] } { set conf(confLink,position) "+155+100" }

   #--- charge le fichier caption
   source [ file join $audace(rep_caption) conflink.cap ]
   #--- j'ajoute le repetoire des equipements dans la liste des
   #--- repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" link]
   #--- je charge la liste des plugins
   findPlugin

   #--- configure le driver selectionne par defaut
   #if { $conf(confLink,start) == "1" } {
   #   configureDriver
   #}
}

#------------------------------------------------------------
# ::confLink::afficheAide
#    Fonction appellee lors de l'appui sur le bouton 'Aide'
#------------------------------------------------------------
proc ::confLink::afficheAide { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   $private(frm).cmd.aide configure -relief groove -state disabled

   #--- je recupere l'index de l'onglet selectionne
   set index [Rnotebook:currentIndex $private(frm).usr.book ]
   if { $index != -1 } {
      set selectedPluginName [lindex $private(namespaceList) [expr $index -1]]
      #--- j'affiche la documentation
      set pluginHelp [ $selectedPluginName\::getPluginHelp ]
      set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
      ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
   }

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -state normal
   $private(frm).cmd.fermer configure -state normal
   $private(frm).cmd.aide configure -relief raised -state normal
}

#------------------------------------------------------------
# ::confLink::appliquer
#    Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
#    memoriser et appliquer la configuration
#------------------------------------------------------------
proc ::confLink::appliquer { } {
   variable private
   global audace
   global caption
   global conf

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le label de l'onglet choisi
   set namespaceLabel "[Rnotebook:currentName $private(frm).usr.book ]"
   #--- je recherche le namespace ayant ce label
   foreach namespace $private(namespaceList) {
      if { [$namespace\:\:getPluginTitle] == $namespaceLabel } {
         set linkNamespace $namespace
         break
      }
   }

   #--- je recupere le link choisi
   set private(linkLabel) [$linkNamespace\:\:getSelectedLinkLabel]
   set $private(variableLinkLabel) $private(linkLabel)

   #--- j'arrete la liaison precedente
   #stopDriver

   #--- je demande a chaque driver de sauver sa config dans le tableau conf(..)
   foreach name $private(namespaceList) {
      set drivername [ $name\:\:widgetToConf ]
   }

   #--- Affichage d'un message d'alerte si necessaire
   #::confLink::displayConnectMessage

   #--- je demarre le driver selectionne
   configureDriver

   #--- Effacement du message d'alerte s'il existe
   #if [ winfo exists $audace(base).connectLiaison ] {
   #   destroy $audace(base).connectLiaison
   #}

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
# ::confLink::getLabel
#    Retourne le titre de la fenetre
#
# return "Titre de la fenetre de choix (dans la langue de l'utilisateur)"
#------------------------------------------------------------
proc ::confLink::getLabel { } {
   global caption

   return "$caption(conflink,config)"
}

#------------------------------------------------------------
# ::confLink::ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
#    la configuration, et fermer la fenetre de reglage
#------------------------------------------------------------
proc ::confLink::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
# ::confLink::fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer'
#------------------------------------------------------------
proc ::confLink::fermer { } {
   variable private

   ::confLink::recup_position
   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -relief groove -state disabled
   destroy $private(frm)
}

#------------------------------------------------------------
# ::confLink::recup_position
#    Permet de recuperer et de sauvegarder la position de la
#    fenetre de configuration de la liaison
#------------------------------------------------------------
proc ::confLink::recup_position { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set deb [ expr 1 + [ string first + $private(geometry) ] ]
   set fin [ string length $private(geometry) ]
   set private(position) "+[ string range $private(geometry) $deb $fin ]"
   #---
   set conf(confLink,position) $private(position)
}

#------------------------------------------------------------
# ::confLink::createDialog
#    Affiche la fenetre a onglet
#
# Parametres :
#    authorizedNamespaces : Liste des onglets a afficher
#      Si la chaine est vide tous les onglets sont affiches
#    configurationTitle : Titre complementaire de la fenetres de dialogue
# return 0 = OK , 1 = error (no driver found)
#------------------------------------------------------------
proc ::confLink::createDialog { authorizedNamespaces configurationTitle } {
   variable private
   global conf
   global caption

   if { [winfo exists $private(frm)] } {
      destroy $private(frm)
   }

   if { [llength $private(namespaceList)] <1 } {
      tk_messageBox -message "No plugin available" \
            -title "$caption(conflink,config) $configurationTitle              " -icon error
       return 1
   }


   #---
   set private(position) $conf(confLink,position)

   #---
   if { [ info exists private(geometry) ] } {
      set deb [ expr 1 + [ string first + $private(geometry) ] ]
      set fin [ string length $private(geometry) ]
      set private(position) "+[ string range $private(geometry) $deb $fin ]"
   }

   toplevel $private(frm)
   if { $::tcl_platform(os) == "Linux" } {
      wm geometry $private(frm) 620x370$private(position)
      wm minsize $private(frm) 620 370
   } else {
      wm geometry $private(frm) 580x370$private(position)
      wm minsize $private(frm) 580 370
   }
   wm resizable $private(frm) 1 0
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(conflink,config) $configurationTitle"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confLink::fermer"

   frame $private(frm).usr -borderwidth 0 -relief raised

   #--- creation de la fenetre a onglets
   set mainFrame $private(frm).usr.book

   if { $authorizedNamespaces == "" } {
      set  authorizedNamespaces $private(namespaceList)
   }

   set linkTypes [list]
   foreach linkNamespace $authorizedNamespaces {
      lappend linkTypes [getNamespaceLabel $linkNamespace]
   }

   #--- j'affiche les onglets dans la fenetre
   Rnotebook:create $mainFrame -tabs "$linkTypes" -borderwidth 1

   #--- je demande a chaque driver d'afficher sa page de config
   set indexOnglet 1
   foreach linkNamespace $authorizedNamespaces {
      #--- j'affiche l'onglet
      $linkNamespace\:\:fillConfigPage [ Rnotebook:frame $mainFrame $indexOnglet ]
      incr indexOnglet
   }

   pack $mainFrame -fill both -expand 1
   pack $private(frm).usr -side top -fill both -expand 1

   #--- frame checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised
      checkbutton $private(frm).start.chk -text "$caption(conflink,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(confLink,start)
      pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x
   pack $private(frm).start -side top -fill x

   #--- frame bouton ok, appliquer, fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised
   button $private(frm).cmd.ok -text "$caption(conflink,ok)" -relief raised -state normal -width 7 \
      -command " ::confLink::ok "
   if { $conf(ok+appliquer)=="1" } {
      pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
   }
   button $private(frm).cmd.appliquer -text "$caption(conflink,appliquer)" -relief raised -state normal -width 8 \
      -command " ::confLink::appliquer "
   pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
   button $private(frm).cmd.fermer -text "$caption(conflink,fermer)" -relief raised -state normal -width 7 \
      -command " ::confLink::fermer "
   pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
   button $private(frm).cmd.aide -text "$caption(conflink,aide)" -relief raised -state normal -width 8 \
      -command " ::confLink::afficheAide "
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
# ::confLink::create
#    Cree une liaison
#
#    Retourne le numero du link
#      Le numero du link est attribue automatiquement
#      Si ce link est deja cree, on retourne le numero du link existant
#
#    Retourne une chaine vide si le type du lien n'existe pas
#    Exemple :
#    ::confLink::create "quickaudine0" "cam1" "acquisition" "bit 1"
#    1
#    ::confLink::create "quickremote1" "cam1" "longuepose" "bit 1"
#    2
#    ::confLink::create "quickremote1" "cam2" "longuepose" "bit 2"
#    2
#------------------------------------------------------------
proc ::confLink::create { linkLabel deviceId usage comment } {
   set linkNamespace [getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      set linkno [$linkNamespace\::createPluginInstance $linkLabel $deviceId $usage $comment]
   } else {
      set linkno ""
   }
   return $linkno
}

#------------------------------------------------------------
# ::confLink::delete
#    Supprime une utilisation d'une liaison et supprime la
#    liaison si elle n'est plus utilisee par aucun autre peripherique
#
#    Retourne rien
#
#    Exemple :
#    ::confLink::delete "quickremote0" "cam1" "longuepose"
#------------------------------------------------------------
proc ::confLink::delete { linkLabel deviceId usage } {
   set linkNamespace [getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      $linkNamespace\:\:deletePluginInstance $linkLabel $deviceId $usage
   }
}

#------------------------------------------------------------
# ::confLink::select [label]
#    Selectionne un onglet correspondant au namespace donne en parametre
#    Si linkNamespace est omis ou inconnu, le premier onglet est selectionne
#------------------------------------------------------------
proc ::confLink::select { { linkNamespace "" } } {
   variable private

   if { $linkNamespace != "" } {
      #--- je recupere le label correspondant au namespace
      set namespaceLabel [getNamespaceLabel $linkNamespace]
      #--- je recupere l'index correspondant à l'onglet
      set index [ lsearch -exact $private(pluginTitleList) "$namespaceLabel" ]
      if { $index != -1 } {
         Rnotebook:select $private(frm).usr.book [ lindex $private(pluginTitleList) $index ]
      }
   }
}

#------------------------------------------------------------
# ::confLink::configureDriver
#    Configure le driver dont le label est dans private(linkLabel)
#------------------------------------------------------------
proc ::confLink::configureDriver { } {
   variable private

   if { $private(linkLabel) == "" } {
      #--- pas de driver selectionne par defaut
      return
   }

   #--- je configure le driver
   [getLinkNamespace $private(linkLabel)]\::configureDriver
}

#------------------------------------------------------------
# ::confLink::stopDriver
#    Arrete un link, si le nom d'un link est donne en parametre
#    Arrete tous les links, si aucun link est donne en parametre
# return rien
#------------------------------------------------------------
proc ::confLink::stopDriver { { linkLabel "" } } {
   if { $linkLabel != "" } {
      [getLinkNamespace )]\:\:stopDriver
   } else {
      #--- j'arrete tous les links
      ##### A FAIRE
   }
}

#------------------------------------------------------------
# ::confLink::findPlugin
#    Recherche les fichiers .tcl presents dans driverPattern
#
#    Conditions :
#      - Le driver doit retourner un namespace non nul quand on charge son source .tcl
#      - Le driver doit avoir une procedure getDriverType qui retourne une valeur egale a private(driverType)
#      - Le driver doit avoir une procedure getPluginTitle
#
#    Si le driver remplit les conditions :
#      Son label est ajoute dans la liste pluginTitleList, et son namespace est ajoute dans namespaceList
#      Sinon le fichier tcl est ignore car ce n'est pas un driver du type souhaite
#
# retrun 0 = OK , 1 = error (no driver found)
#------------------------------------------------------------
proc ::confLink::findPlugin { } {
   variable private
   global caption audace

   #--- j'initialise les listes vides
   set private(namespaceList)  ""
   set private(pluginTitleList)     ""

   #--- je recherche les fichiers link/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" link * pkgIndex.tcl ]
   #--- je recherche les drivers repondant au filtre driverPattern
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type)== "link"} {
               #--- je charge le package
               package require $pluginInfo(name)
               #--- j'initalise le plugin
               $pluginInfo(namespace)::initPlugin
               set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
               #--- je l'ajoute dans la liste des plugins
               lappend private(namespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
               lappend private(pluginTitleList) $pluginlabel
               ::console::affiche_prompt "#$caption(conflink,liaison) $pluginlabel v$pluginInfo(version)\n"
            }
         } else {
            ::console::affiche_erreur "Error loading link $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continu la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confLink::findPlugin $::errorInfo\n"
      }
   }
   ::console::affiche_prompt "\n"

   if { [llength $private(namespaceList)] <1 } {
      #--- pas driver correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#------------------------------------------------------------
# ::confLink::displayConnectMessage
#    Affichage d'un message d'alerte pendant la connexion d'une liaison au demarrage
#------------------------------------------------------------
proc ::confLink::displayConnectMessage { } {
   variable private
   global audace
   global caption
   global color

   if [ winfo exists $audace(base).connectLiaison ] {
      destroy $audace(base).connectLiaison
   }

   toplevel $audace(base).connectLiaison
   wm resizable $audace(base).connectLiaison 0 0
   wm title $audace(base).connectLiaison "$caption(conflink,attention)"
   if { [ info exists private(frm) ] } {
      set posx_connectLiaison [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
      set posy_connectLiaison [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
      wm geometry $audace(base).connectLiaison +[ expr $posx_connectLiaison + 50 ]+[ expr $posy_connectLiaison + 100 ]
      wm transient $audace(base).connectLiaison $private(frm)
   } else {
      wm geometry $audace(base).connectLiaison +200+100
      wm transient $audace(base).connectLiaison $audace(base)
   }

   #--- Cree l'affichage du message
   label $audace(base).connectLiaison.labURL_1 -text "$caption(conflink,connexion_texte1)" \
      -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).connectLiaison.labURL_1 -padx 10 -pady 2
   label $audace(base).connectLiaison.labURL_2 -text "$caption(conflink,connexion_texte2)" \
      -font $audace(font,arial_10_b) -fg $color(red)
   pack $audace(base).connectLiaison.labURL_2 -padx 10 -pady 2
   update

   #--- La nouvelle fenetre est active
   focus $audace(base).connectLiaison

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectLiaison
}

#------------------------------------------------------------
# ::confLink::getLinkLabels
#    Retourne les libelles des link disponibles correspondant aux
#    namespaces fourni en parametre
#
#    Retourne une liste vide si namespace n'existe pas
#
#    Exemple :
#    getLinkLabels { quickremote parallelport }
#      { "quickremote0" "quickremote1" "LPT1:" "LPT2:" }
#------------------------------------------------------------
proc ::confLink::getLinkLabels { namespaces } {
   variable private

   set labels [list]

   foreach namespace $namespaces {
      #--- je verifie que le namespace existe
      if { [lsearch -exact $private(namespaceList) $namespace] != -1 } {
         foreach linkLabel [$namespace\:\:getLinkLabels] {
            lappend labels $linkLabel
         }
      }
   }
   return $labels
}

#------------------------------------------------------------
# ::confLink::getNamespaceLabel
#    Retourne le libelle du namespace
#
#    Retourne une chaine vide si namespace n'existe pas
#
#    Exemple :
#    getNamespaceLabel "parallelport"
#      { "Port parallèle" }
#------------------------------------------------------------
proc ::confLink::getNamespaceLabel { namespace } {
   variable private

   #--- je verifie que le namespace existe
   if { [lsearch -exact $private(namespaceList) $namespace] != -1 } {
      return [$namespace\:\:getPluginTitle]
   } else {
      #--- je retourne une chaine vide
      return ""
   }
}

#------------------------------------------------------------
# ::confLink::getLinkNamespace
#    Retourne le namespace du link
#
#    Retourne une chaine vide si le link n'existe pas
#
#    Exemple :
#    getLinkNamespace "LPT1:"
#      parallelport
#------------------------------------------------------------
proc ::confLink::getLinkNamespace { linkLabel } {
   variable private

   foreach namespace $private(namespaceList) {
      #--- je verifie si on peut recuperer l'index
      if { [$namespace\::getLinkIndex $linkLabel] != "" } {
         return $namespace
      }
   }
   #--- je retourne une chaine vide
   return ""
}

#------------------------------------------------------------
# ::confLink::getLinkNo
#    Retourne le numero de la liaison
#
#    Retourne une chaine vide si la liaison est fermee
#
#    Exemple :
#    getLinkNo "quickremote0"
#      1
#------------------------------------------------------------
proc ::confLink::getLinkNo { linkLabel } {
   variable private

   #--- je recupere les linkNo ouverts
   set linkNoList [link::list]

   set linkNamespace [::confLink::getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      set linkIndex [$linkNamespace\::getLinkIndex $linkLabel]
      #--- je recherche la liaison deja ouverte qui a le meme namespace et le meme index
      foreach linkNo [link::list] {
         if {    "[link$linkNo drivername]" == $linkNamespace
              && "[link$linkNo index]" == $linkIndex } {
            return $linkNo
         }
      }
   }
   #--- je retourne une chaine vide si la liaison n'a pas de numero
   return ""
}

#------------------------------------------------------------
# ::confLink::run
#    Affiche la fenetre de choix et de configuration
#
#    Parametres :
#      linkLabel : link pre-selectionne
#      authorizedNamespaces : namespaces autorises (optionel)
#      configurationTitle : titre de la fenetre de configuration (optionel)
#------------------------------------------------------------
proc ::confLink::run { { variableLinkLabel "" } { authorizedNamespaces "" } { configurationTitle "" } } {
   variable private
   global conf

   if { $variableLinkLabel == "" } {
      set private(linkLabel) ""
      set private(variableLinkLabel) ""
   } else {
      set private(linkLabel) [set $variableLinkLabel]
      set private(variableLinkLabel) $variableLinkLabel
   }

   #--- je liste les packages qui sont presents parmi ceux qui sont autorises
   set authorizedPresentNamespaces [list ]
   foreach  name $authorizedNamespaces  {
       if { [lsearch $private(namespaceList) $name ] != -1 } {
         lappend authorizedPresentNamespaces $name
       }
   }

   if { [createDialog $authorizedPresentNamespaces $configurationTitle ]==0 } {
      set linkNamespace [getLinkNamespace $private(linkLabel) ]
      if { $linkNamespace != "" } {
         #--- je selectionne l'onglet correspondant au linkNamespace
         select $linkNamespace
         #--- je selectionne le link dans l'onglet
         $linkNamespace\::selectConfigLink $private(linkLabel)
      }
      #--- j'attends la fermeture de la fenetre
      tkwait window $private(frm)
      #--- je retourne le link choisi
      return $private(linkLabel)
   }
}

#--- Connexion au demarrage du driver selectionne par defaut
::confLink::init

